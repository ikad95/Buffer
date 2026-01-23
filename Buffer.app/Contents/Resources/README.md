# Buffer

**Clipboard manager for macOS**

Buffer keeps your clipboard history secure and accessible. Copy once, access anytime—with encryption and zero data transmission.

[![Download](https://img.shields.io/badge/Download-v1.0.0-blue)](https://github.com/ikad95/Buffer/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Sonoma%2014+-black)](https://www.apple.com/macos/)

---

## Why Buffer?

| Concern | Buffer's Answer |
|---------|-----------------|
| **Data Privacy** | 100% local. Your data never leaves your device. |
| **Encryption** | All stored content is encrypted. |
| **Network Security** | Zero outbound connections. No telemetry. No analytics. |
| **Vendor Lock-in** | No subscriptions. No accounts. No cloud dependencies. |

---

## Download

**[Download Buffer v1.0.0](https://github.com/ikad95/Buffer/releases/download/v1.0.0/Buffer.app.zip)**

### Installation

1. Download `Buffer.app.zip`
2. Unzip and drag `Buffer.app` to your Applications folder
3. On first launch, right-click the app and select **Open** (required for unsigned apps)
4. Grant Accessibility permissions when prompted

**System Requirements:** macOS Sonoma 14 or higher

---

## Features

### Clipboard Management
- **Unlimited history** — Store as many items as you want
- **Pin important items** — Keep frequently used snippets at the top
- **Auto-cleanup** — Configurable retention policies

### Search
- **Full-text search** — Find anything instantly
- **Fuzzy matching** — Find items even with typos

### Workflow
- **Keyboard-first** — `⇧⌘C` to open, type to search, `Enter` to paste
- **Native macOS UI** — Feels like a system feature
- **Menu bar access** — Always one click away

---

## Quick Start

| Action | Shortcut |
|--------|----------|
| Open Buffer | `⇧⌘C` |
| Search | Just start typing |
| Copy selected item | `Enter` |
| Paste selected item | `⌥Enter` |
| Paste without formatting | `⌥⇧Enter` |
| Pin/Unpin item | `⌥P` |
| Delete item | `⌥Delete` |
| Open Preferences | `⌘,` |

---

## Build from Source

```sh
git clone https://github.com/ikad95/Buffer.git
cd Buffer
sh setup.sh
```

---

## FAQ

**Why doesn't paste work automatically?**

1. Enable "Paste automatically" in Preferences
2. Add Buffer to System Settings → Privacy & Security → Accessibility

---

## Technical Documentation

For security architecture, data storage details, build instructions, and enterprise deployment, see [TECH.md](./TECH.md).

---

## License

[MIT](./LICENSE) — Free for personal and commercial use.

---

## Acknowledgements

Built on the foundation of [Maccy](https://github.com/p0deje/Maccy) by Alex Rodionov.
