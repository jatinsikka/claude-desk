# Claude Desk

A tiny always-on-top desktop widget that shows your **Claude.ai subscription usage limits** in real time.

![Claude Desk Widget](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/license-MIT-purple)

## What it shows

- **5-Hour Window** — how much of your rolling 5-hour usage you've burned through
- **7-Day Usage** — weekly consumption at a glance
- Color-coded bars: purple → amber (70%) → red (90%)
- Countdown to reset

## Setup

**Prerequisites:** Node.js 18+

```bash
git clone https://github.com/jatinsikka/claude-desk.git
cd claude-desk
npm install
npm start
```

On first launch, a Claude.ai window appears — log in normally. It hides itself and the widget appears in the bottom-right corner of your screen.

## How it works

Claude Desk loads a hidden Claude.ai session in Electron, extracts your session cookies, and calls Anthropic's internal usage endpoint (`/api/oauth/usage`) every 5 minutes. No passwords are stored — it uses the same browser session as Claude.ai.

## Controls

| Button | Action |
|--------|--------|
| `↻` | Refresh now |
| `⚙` | Open Claude.ai (re-login if needed) |
| `✕` | Quit |

Drag the widget anywhere on your screen.

## Notes

- This uses an **undocumented internal API endpoint**. It may break if Anthropic changes their infrastructure.
- The widget polls every 5 minutes to avoid rate limiting (429s).
- Your session is stored locally in Electron's partition store — never sent anywhere else.

## License

MIT
