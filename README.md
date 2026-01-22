# Buffer

Buffer is a lightweight clipboard manager for macOS. It keeps the history of what you copy
and lets you quickly navigate, search, and use previous clipboard contents.

**100% local. Zero network connections. AES-256 encrypted.**

Buffer works on macOS Sonoma 14 or higher.

<!-- vim-markdown-toc GFM -->

* [Features](#features)
* [Install](#install)
* [Usage](#usage)
* [Security](#security)
* [Storage](#storage)
* [Search Modes](#search-modes)
* [Advanced](#advanced)
  * [Ignore Copied Items](#ignore-copied-items)
  * [Ignore Custom Copy Types](#ignore-custom-copy-types)
* [FAQ](#faq)
  * [Why doesn't it paste when I select an item in history?](#why-doesnt-it-paste-when-i-select-an-item-in-history)
  * [How do I enable unlimited history?](#how-do-i-enable-unlimited-history)
  * [How does encryption work?](#how-does-encryption-work)
* [Build from Source](#build-from-source)
* [Run Tests](#run-tests)
* [License](#license)
* [Acknowledgements](#acknowledgements)

<!-- vim-markdown-toc -->

## Features

* Lightweight and fast
* Keyboard-first
* Secure and private
* **AES-256 encrypted storage**
* **Zero network connections**
* **Unlimited history support**
* **FTS5 full-text search**
* **LRU auto-cleanup**
* Native UI
* Open source and free

## Install

Clone the repository and build from source:

```sh
git clone <repo>
cd Buffer
open Buffer.xcodeproj
```

1. Select your signing team in project settings
2. Build and run (<kbd>COMMAND (⌘)</kbd> + <kbd>R</kbd>)

## Usage

1. <kbd>SHIFT (⇧)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>C</kbd> to popup Buffer or click on its icon in the menu bar.
2. Type what you want to find.
3. To select the history item you wish to copy, press <kbd>ENTER</kbd>, or click the item, or use <kbd>COMMAND (⌘)</kbd> + `n` shortcut.
4. To choose the history item and paste, press <kbd>OPTION (⌥)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + `n` shortcut.
5. To choose the history item and paste without formatting, press <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>ENTER</kbd>, or <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + <kbd>CLICK</kbd> the item, or use <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> + `n` shortcut.
6. To delete the history item, press <kbd>OPTION (⌥)</kbd> + <kbd>DELETE (⌫)</kbd>.
7. To see the full text of the history item, wait a couple of seconds for tooltip.
8. To pin the history item so that it remains on top of the list, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd>. The item will be moved to the top with a random but permanent keyboard shortcut. To unpin it, press <kbd>OPTION (⌥)</kbd> + <kbd>P</kbd> again.
9. To clear all unpinned items, select _Clear_ in the menu, or press <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>. To clear all items including pinned, select _Clear_ in the menu with <kbd>OPTION (⌥)</kbd> pressed, or press <kbd>SHIFT (⇧)</kbd> + <kbd>OPTION (⌥)</kbd> + <kbd>COMMAND (⌘)</kbd> + <kbd>DELETE (⌫)</kbd>.
10. To disable Buffer and ignore new copies, click on the menu icon with <kbd>OPTION (⌥)</kbd> pressed.
11. To ignore only the next copy, click on the menu icon with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.
12. To customize the behavior, check "Preferences…" window, or press <kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd>.

## Security

Buffer is built with enterprise-grade security:

| Feature | Implementation |
|---------|----------------|
| Encryption | AES-256-GCM via CryptoKit |
| Key Storage | macOS Keychain |
| Data at Rest | Encrypted SQLite |
| Network | Zero outbound connections |
| Updates | Disabled (no Sparkle) |
| Analytics | None |

All clipboard content is encrypted before being written to disk. The encryption key is stored in the macOS Keychain and never leaves your device.

## Storage

Buffer provides flexible storage management in Preferences:

* **Unlimited History** - Toggle to remove item limits (supports millions of items)
* **Custom Limit** - Set any limit from 1 to 1,000,000 items
* **Auto-Cleanup (LRU)** - Automatically remove items older than X days
* **Keep Days** - Configure retention period (1-365 days)

Data is stored in:

| File | Purpose |
|------|---------|
| `~/Library/Application Support/Buffer/Storage.sqlite` | Encrypted clipboard history |
| `~/Library/Application Support/Buffer/SearchIndex.sqlite` | FTS5 search index |
| macOS Keychain | AES-256 encryption key |

## Search Modes

Buffer supports multiple search modes:

| Mode | Description |
|------|-------------|
| Exact | Case-insensitive substring match |
| Fuzzy | Typo-tolerant fuzzy matching |
| Regex | Regular expression search |
| Mixed | Tries exact, then regex, then fuzzy |
| Full-Text | FTS5 full-text search with BM25 ranking |

Full-text search uses SQLite FTS5 with Porter stemming for intelligent matching.

## Advanced

### Ignore Copied Items

You can tell Buffer to ignore all copied items:

```sh
defaults write org.codexvault.Buffer ignoreEvents true # default is false
```

This is useful if you have some workflow for copying sensitive data. You can set `ignoreEvents` to true, copy the data and set `ignoreEvents` back to false.

You can also click the menu icon with <kbd>OPTION (⌥)</kbd> pressed. To ignore only the next copy, click with <kbd>OPTION (⌥)</kbd> + <kbd>SHIFT (⇧)</kbd> pressed.

### Ignore Custom Copy Types

By default Buffer will ignore certain copy types that are considered to be confidential
or temporary. The default list always includes the following types:

* `org.nspasteboard.TransientType`
* `org.nspasteboard.ConcealedType`
* `org.nspasteboard.AutoGeneratedType`

Also, default configuration includes the following types but they can be removed
or overwritten:

* `com.agilebits.onepassword`
* `com.typeit4me.clipping`
* `de.petermaurer.TransientPasteboardType`
* `Pasteboard generator type`
* `net.antelle.keeweb`

You can add additional custom types using settings.

## FAQ

### Why doesn't it paste when I select an item in history?

1. Make sure you have "Paste automatically" enabled in Preferences.
2. Make sure "Buffer" is added to System Settings -> Privacy & Security -> Accessibility.

### How do I enable unlimited history?

1. Open Preferences (<kbd>COMMAND (⌘)</kbd> + <kbd>,</kbd>)
2. Go to Storage settings
3. Toggle "Unlimited History" on

### How does encryption work?

Buffer uses AES-256-GCM encryption via Apple's CryptoKit framework. When you copy something:

1. The clipboard content is encrypted using a 256-bit key
2. The encrypted data is stored in SQLite
3. The encryption key is stored securely in macOS Keychain
4. When you access an item, it's decrypted on-the-fly

The encryption key never leaves your device. There are zero network connections.

## Build from Source

```sh
git clone <repo>
cd Buffer
open Buffer.xcodeproj
```

1. Select your signing team in project settings
2. Build and run (<kbd>COMMAND (⌘)</kbd> + <kbd>R</kbd>)

## Run Tests

```sh
xcodebuild test -project Buffer.xcodeproj -scheme Buffer -destination 'platform=macOS'
```

## License

[MIT](./LICENSE)

## Acknowledgements

Built on the foundation of [Maccy](https://github.com/p0deje/Maccy) by Alex Rodionov
