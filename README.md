# DeskPulse

A tiny always-on-top desktop widget that shows your **AI usage limits in real time** — right on your desktop, all the time.

Currently tracks **Claude.ai** subscription usage (5-hour window + 7-day). Built with Electron, no login credentials stored — uses your existing browser session.

![platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey)
![license](https://img.shields.io/badge/license-MIT-purple)

---

## What it shows

- **5-Hour Window** — rolling usage % with countdown to reset
- **7-Day Usage** — weekly consumption meter
- Color-coded bars: purple → amber at 70% → red at 90%
- Live "updated X ago" timestamp

## Setup

**Requires:** Node.js 18+

```bash
git clone https://github.com/jatinsikka/deskpulse.git
cd deskpulse
npm install
npm start
```

On first launch a Claude.ai window appears — sign in normally. It hides itself and the widget appears in the bottom-right corner of your screen.

## How it works

DeskPulse loads a hidden Claude.ai session inside Electron, reads session cookies, and calls an internal usage endpoint every 5 minutes. Your credentials never leave your machine — the same session your browser uses.

## Controls

| Button | Action |
|--------|--------|
| `↻` | Refresh now |
| `⚙` | Open Claude.ai (re-login if needed) |
| `✕` | Quit |

Drag anywhere on screen.

## Hardware

Interested in a physical version — a tiny glowing desk screen? The enclosure design (OpenSCAD) and bill of materials are in [`/hardware`](./hardware). Built around the LILYGO T-Display-S3 (~$12).

## Notes

- Uses an undocumented internal API. May break if Anthropic changes their infrastructure.
- Polls every 5 minutes to stay within rate limits.
- No data is sent anywhere — fully local.

## License

MIT
