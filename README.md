# Buffer

**Enterprise-grade clipboard manager for macOS**

Buffer keeps your clipboard history secure and accessible. Copy once, access anytime—with military-grade encryption and zero data transmission.

[![Download](https://img.shields.io/badge/Download-v1.0.0-blue)](https://github.com/ikad95/Buffer/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Sonoma%2014+-black)](https://www.apple.com/macos/)

---

## Why Buffer?

| Concern | Buffer's Answer |
|---------|-----------------|
| **Data Privacy** | 100% local. Your data never leaves your device. |
| **Encryption** | AES-256-GCM encryption for all stored content. |
| **Network Security** | Zero outbound connections. No telemetry. No analytics. |
| **Compliance** | Auditable open-source code. MIT licensed. |
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

## Security Architecture

Buffer is designed for security-conscious users and organizations.

### Encryption

| Layer | Implementation |
|-------|----------------|
| Algorithm | AES-256-GCM |
| Framework | Apple CryptoKit |
| Key Storage | macOS Keychain (hardware-backed on Apple Silicon) |
| Data at Rest | Fully encrypted SQLite database |

### Network Isolation

- **Zero outbound connections** — Buffer never contacts any server
- **No update mechanism** — No Sparkle or auto-update frameworks
- **No analytics** — No usage tracking, crash reporting, or telemetry
- **No accounts** — No registration, login, or cloud sync

### Sensitive Data Handling

Buffer automatically ignores clipboard content from:

- 1Password (`com.agilebits.onepassword`)
- KeeWeb (`net.antelle.keeweb`)
- TypeIt4Me (`com.typeit4me.clipping`)
- System-flagged transient/concealed content

You can configure additional ignored applications in Preferences.

---

## Features

### Clipboard Management
- **Unlimited history** — Store millions of items with no arbitrary limits
- **Pin important items** — Keep frequently used snippets at the top
- **Auto-cleanup** — LRU-based retention policies (configurable 1-365 days)

### Search
- **Full-text search** — FTS5 with BM25 ranking and Porter stemming
- **Fuzzy matching** — Find items even with typos
- **Regex support** — Power-user search patterns
- **Instant results** — Sub-millisecond search across your entire history

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

## Data Storage

All data is stored locally:

| Location | Purpose |
|----------|---------|
| `~/Library/Application Support/Buffer/Storage.sqlite` | Encrypted clipboard history |
| `~/Library/Application Support/Buffer/SearchIndex.sqlite` | Search index |
| macOS Keychain | Encryption key |

To completely remove Buffer and all data:

```sh
rm -rf ~/Library/Application\ Support/Buffer
# Encryption key is automatically removed when app is deleted
```

---

## Configuration

### Storage Settings

| Option | Description |
|--------|-------------|
| Unlimited History | Remove item count limits |
| History Limit | Set custom limit (1 to 1,000,000) |
| Auto-Cleanup | Enable LRU-based cleanup |
| Retention Period | Days to keep items (1-365) |

### Ignore Settings

Temporarily disable Buffer for sensitive operations:

- **Option+Click** menu icon → Disable until re-enabled
- **Option+Shift+Click** menu icon → Ignore next copy only

Or via terminal:

```sh
defaults write org.codexvault.Buffer ignoreEvents true
```

---

## FAQ

**Why doesn't paste work automatically?**

1. Enable "Paste automatically" in Preferences
2. Add Buffer to System Settings → Privacy & Security → Accessibility

**How do I verify the encryption?**

The source code is fully auditable. Encryption implementation is in the `Encryption/` directory using Apple's CryptoKit framework.

**Can IT deploy this across the organization?**

Yes. Buffer requires no accounts, servers, or network access. Deploy the `.app` bundle via MDM. Configuration can be managed via `defaults` commands.

---

## Build from Source

For organizations requiring source verification:

```sh
git clone https://github.com/ikad95/Buffer.git
cd Buffer
open Buffer.xcodeproj
```

1. Select your signing team in project settings
2. Build and run (`⌘R`)

```sh
# Run tests
xcodebuild test -project Buffer.xcodeproj -scheme Buffer -destination 'platform=macOS'
```

---

## License

[MIT](./LICENSE) — Free for personal and commercial use.

---

## Acknowledgements

Built on the foundation of [Maccy](https://github.com/p0deje/Maccy) by Alex Rodionov.
