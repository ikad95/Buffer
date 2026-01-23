# Technical Documentation

This document covers the technical architecture and implementation details of Buffer.

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

## Search Implementation

- **Full-text search** — FTS5 with BM25 ranking and Porter stemming
- **Fuzzy matching** — Find items even with typos
- **Regex support** — Power-user search patterns
- **Instant results** — Sub-millisecond search across your entire history

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

- **Option+Click** menu icon — Disable until re-enabled
- **Option+Shift+Click** menu icon — Ignore next copy only

Or via terminal:

```sh
defaults write org.codexvault.Buffer ignoreEvents true
```

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

## Verification

The source code is fully auditable. Encryption implementation is in the `Encryption/` directory using Apple's CryptoKit framework.

---

## Enterprise Deployment

Buffer requires no accounts, servers, or network access. Deploy the `.app` bundle via MDM. Configuration can be managed via `defaults` commands.
