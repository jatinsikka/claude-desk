const { app, BrowserWindow, ipcMain, screen, session } = require('electron')
const path = require('path')

let widgetWin = null
let claudeWin = null
let usageData = null
let pollTimer = null

const POLL_INTERVAL = 5 * 60 * 1000 // 5 minutes
const CLAUDE_PARTITION = 'persist:claude'

// ─── Window creation ──────────────────────────────────────────────────────────

function createWidgetWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize

  widgetWin = new BrowserWindow({
    width: 270,
    height: 210,
    x: width - 290,
    y: height - 230,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    skipTaskbar: false,
    hasShadow: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
    }
  })

  widgetWin.loadFile('index.html')
  widgetWin.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true })
}

function createClaudeWindow() {
  claudeWin = new BrowserWindow({
    width: 1100,
    height: 800,
    show: false,
    title: 'DeskPulse — Sign in to Claude',
    webPreferences: {
      partition: CLAUDE_PARTITION,
    }
  })

  claudeWin.loadURL('https://claude.ai')

  // After navigation, check if now logged in and hide if so
  claudeWin.webContents.on('did-navigate', async (e, url) => {
    if (url.startsWith('https://claude.ai') && !url.includes('login') && !url.includes('auth')) {
      // Give cookies a moment to settle
      await sleep(1500)
      const loggedIn = await checkLoggedIn()
      if (loggedIn) {
        claudeWin.hide()
        startPolling()
      }
    }
  })

  // Prevent actual close — just hide
  claudeWin.on('close', (e) => {
    e.preventDefault()
    claudeWin.hide()
  })
}

// ─── Auth & session ───────────────────────────────────────────────────────────

async function checkLoggedIn() {
  const claudeSession = session.fromPartition(CLAUDE_PARTITION)
  const cookies = await claudeSession.cookies.get({ url: 'https://claude.ai' })
  // Logged in if we have any session-like cookie
  return cookies.some(c =>
    c.value.startsWith('sk-ant-') ||
    c.name.toLowerCase().includes('session') ||
    c.name.toLowerCase().includes('auth') ||
    c.name.toLowerCase().includes('token')
  )
}

async function getSessionHeaders() {
  const claudeSession = session.fromPartition(CLAUDE_PARTITION)

  const claudeCookies = await claudeSession.cookies.get({ url: 'https://claude.ai' })
  const anthropicCookies = await claudeSession.cookies.get({ url: 'https://anthropic.com' })
  const apiCookies = await claudeSession.cookies.get({ url: 'https://api.anthropic.com' })

  const allCookies = [...claudeCookies, ...anthropicCookies, ...apiCookies]
  const cookieHeader = allCookies.map(c => `${c.name}=${c.value}`).join('; ')

  // Look for a bearer token (sk-ant-... value anywhere in cookies)
  const bearerCookie = allCookies.find(c => c.value.startsWith('sk-ant-'))

  const headers = {
    'anthropic-beta': 'oauth-2025-04-20',
    'Cookie': cookieHeader,
    'Referer': 'https://claude.ai/',
    'Origin': 'https://claude.ai',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  }

  if (bearerCookie) {
    headers['Authorization'] = `Bearer ${bearerCookie.value}`
  }

  return headers
}

// ─── Usage fetching ───────────────────────────────────────────────────────────

async function fetchUsage() {
  const headers = await getSessionHeaders()

  const resp = await fetch('https://api.anthropic.com/api/oauth/usage', { headers })

  if (resp.status === 401 || resp.status === 403) {
    throw new Error('NOT_LOGGED_IN')
  }

  if (resp.status === 429) {
    throw new Error('RATE_LIMITED')
  }

  if (!resp.ok) {
    throw new Error(`HTTP_${resp.status}`)
  }

  const data = await resp.json()
  console.log('Usage API response:', JSON.stringify(data, null, 2))
  return data
}

async function doFetch() {
  try {
    const data = await fetchUsage()
    usageData = { ...data, fetchedAt: Date.now(), error: null }
    widgetWin?.webContents.send('usage-update', usageData)
  } catch (err) {
    console.error('Fetch failed:', err.message)
    const errorData = {
      ...(usageData || {}),
      error: err.message,
      fetchedAt: usageData?.fetchedAt ?? Date.now(),
    }
    usageData = errorData
    widgetWin?.webContents.send('usage-update', errorData)
  }
}

function startPolling() {
  if (pollTimer) clearInterval(pollTimer)
  doFetch() // immediate
  pollTimer = setInterval(doFetch, POLL_INTERVAL)
}

// ─── IPC handlers ─────────────────────────────────────────────────────────────

ipcMain.on('open-claude', () => {
  claudeWin.show()
  claudeWin.focus()
})

ipcMain.on('refresh', () => {
  doFetch()
})

ipcMain.on('quit', () => {
  app.exit(0)
})

// ─── App lifecycle ────────────────────────────────────────────────────────────

app.whenReady().then(async () => {
  createWidgetWindow()
  createClaudeWindow()

  const loggedIn = await checkLoggedIn()
  if (!loggedIn) {
    // Show Claude window for login on first launch
    await sleep(500)
    claudeWin.show()
    claudeWin.focus()
    widgetWin.webContents.send('usage-update', { error: 'NOT_LOGGED_IN' })
  } else {
    startPolling()
  }
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})

app.on('before-quit', () => {
  // Allow the claude window to close on real quit
  claudeWin?.removeAllListeners('close')
})

// ─── Helpers ──────────────────────────────────────────────────────────────────

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms))
}
