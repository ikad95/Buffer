# AGENTS.md - AI Agent Guidelines for Buffer Codebase

## For AI Agents Working on This Codebase

This document provides essential guidelines and philosophy for AI agents contributing to the Buffer project. Following these principles ensures consistency, maintainability, and alignment with the project's core values.

## Core Philosophy

### 1. **Kernighan's Law is Sacred**
> *"Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it."* - Brian Kernighan

**This is the #1 principle for all AI agents working on this codebase.**

- Prioritize READABILITY over cleverness
- Write code that humans can easily understand
- Choose explicit over implicit
- Document everything thoroughly
- Never write "clever" one-liners
- Never sacrifice clarity for brevity

### 2. **AI-Generated Code Must Be Human-Readable**

When AI generates code, it often prioritizes sophistication over clarity. This project deliberately fights against this tendency:

- **Clear variable names**: `clipboardContent` not `cc`, `isEncrypted` not `enc`
- **Explicit logic**: Use if/else instead of complex ternary operators
- **Comprehensive comments**: Explain the "why", not just the "what"
- **Simple functions**: One responsibility per function
- **Readable error messages**: Help developers understand what went wrong

### 3. **Security is Non-Negotiable**

Buffer handles sensitive clipboard data. Security must never be compromised:

- All clipboard data MUST be encrypted at rest
- Encryption keys MUST be stored in macOS Keychain
- ZERO network connections - no telemetry, no updates, no external calls
- Never log sensitive clipboard content
- Validate all inputs

## Development Guidelines

### Code Style & Structure

1. **File Naming**
   - Use descriptive names: `EncryptionManager.swift` not `Crypto.swift`
   - Group by feature: `Security/`, `Search/`, `Settings/`
   - Be specific about purpose: `KeychainManager.swift`

2. **Function & Property Naming**
   ```swift
   // Good
   func encryptClipboardContent(_ content: Data) throws -> Data
   var isEncryptionEnabled: Bool
   private let encryptionKey: SymmetricKey

   // Bad
   func encrypt(_ d: Data) throws -> Data
   var encEnabled: Bool
   private let key: SymmetricKey
   ```

3. **Error Handling**
   ```swift
   // Good - Explicit and helpful
   enum EncryptionError: LocalizedError {
       case keyNotInitialized
       case encryptionFailed
       case decryptionFailed

       var errorDescription: String? {
           switch self {
           case .keyNotInitialized:
               return "Encryption key has not been initialized"
           case .encryptionFailed:
               return "Failed to encrypt data"
           case .decryptionFailed:
               return "Failed to decrypt data - data may be corrupted"
           }
       }
   }

   // Bad - Cryptic
   throw NSError(domain: "enc", code: 1)
   ```

4. **Documentation**
   ```swift
   // Good
   /// Encrypts the provided data using AES-256-GCM.
   ///
   /// The encryption uses a random nonce for each operation, ensuring
   /// that identical plaintext produces different ciphertext each time.
   ///
   /// - Parameter data: The plaintext data to encrypt
   /// - Returns: The encrypted data (nonce + ciphertext + tag)
   /// - Throws: `EncryptionError.keyNotInitialized` if key is not set
   /// - Throws: `EncryptionError.encryptionFailed` if encryption fails
   func encrypt(_ data: Data) throws -> Data
   ```

### SwiftUI & Architecture

1. **View Composition**
   - Keep views small and focused
   - Extract reusable components
   - Use @Observable for state management
   - Prefer composition over inheritance

2. **Data Flow**
   ```swift
   // Good - Clear data flow
   @Observable
   final class History {
       private(set) var items: [HistoryItemDecorator] = []

       func add(_ item: HistoryItem) {
           // Clear, explicit logic
       }
   }

   // Bad - Unclear state management
   class History {
       var items = [Any]()  // Type unclear
   }
   ```

3. **SwiftData Models**
   - Use explicit property names
   - Document relationships
   - Handle migrations carefully

### Testing Philosophy

1. **Test Coverage Target**: 90%+ for critical paths (encryption, search, storage)

2. **Test Naming**: Describe what is being tested
   ```swift
   // Good
   func testEncryptDecryptRoundTrip_withUnicodeContent_preservesData()
   func testLRUEviction_withExpiredItems_removesOldest()

   // Bad
   func testEncrypt()
   func testLRU()
   ```

3. **Test Organization**
   - Group related tests in classes
   - Test both success and failure scenarios
   - Include edge cases (empty data, large data, unicode)

### Security Guidelines

1. **Encryption**
   - Use AES-256-GCM (CryptoKit's standard)
   - Store keys in Keychain only
   - Use random nonces for each encryption
   - Never hardcode keys or secrets

2. **Data Handling**
   - Encrypt all clipboard content before storage
   - Clear sensitive data from memory when done
   - Never log clipboard content
   - Sanitize error messages

3. **Network**
   - ZERO outbound connections
   - No analytics, telemetry, or crash reporting
   - No auto-update mechanisms
   - No external links in UI

## What NOT to Do

### Code Anti-Patterns

1. **Don't Write Clever Code**
   ```swift
   // Bad - Clever but unreadable
   let filtered = items.filter { $0.isPinned || Date.now.timeIntervalSince($0.lastCopiedAt) < 86400 * 7 }

   // Good - Clear and explicit
   let filteredItems: [HistoryItem] = []
   for item in items {
       if item.isPinned {
           filteredItems.append(item)
           continue
       }

       let daysSinceLastCopy = Calendar.current.dateComponents([.day], from: item.lastCopiedAt, to: Date.now).day ?? 0
       if daysSinceLastCopy < keepDays {
           filteredItems.append(item)
       }
   }
   ```

2. **Don't Use Generic Names**
   ```swift
   // Bad
   func process(_ data: Any)
   var manager: AnyObject

   // Good
   func encryptClipboardData(_ data: Data) throws -> Data
   var encryptionManager: EncryptionManager
   ```

3. **Don't Skip Error Handling**
   ```swift
   // Bad - Force unwrap
   let key = try! KeychainManager.shared.getOrCreateKey()

   // Good - Proper error handling
   do {
       let key = try KeychainManager.shared.getOrCreateKey()
       // Use key
   } catch {
       logger.error("Failed to retrieve encryption key: \(error)")
       // Handle gracefully
   }
   ```

## Project-Specific Guidelines

### Buffer Service Specifics

1. **Clipboard Monitoring**
   - Poll at reasonable intervals
   - Ignore empty clipboard
   - Handle all pasteboard types
   - Deduplicate consecutive copies

2. **Search Implementation**
   - Support multiple search modes (exact, fuzzy, regex, FTS)
   - Index content for fast retrieval
   - Handle unicode properly
   - Respect user privacy in search index

3. **Storage Management**
   - Implement LRU eviction
   - Support unlimited history option
   - Encrypt all stored data
   - Provide size statistics

### Performance Considerations

1. **Database Operations**
   - Use FTS5 for full-text search
   - Batch operations where possible
   - Use proper indexes
   - Handle large histories gracefully

2. **Memory Management**
   - Don't load entire history into memory
   - Use lazy loading for images
   - Clear decrypted data when not needed

## Tooling & Automation

### Required Tools
- **Xcode 15+**: For building and debugging
- **XCTest**: For unit and integration tests
- **SwiftLint**: For code style enforcement

### Build & Test Commands
```bash
# Build
xcodebuild build -project Buffer.xcodeproj -scheme Buffer

# Run tests
xcodebuild test -project Buffer.xcodeproj -scheme Buffer -destination 'platform=macOS'
```

## Key Files to Understand

- `BufferApp.swift`: App entry point and lifecycle
- `AppDelegate.swift`: App delegate and global handlers
- `Security/EncryptionManager.swift`: AES-256-GCM encryption
- `Security/KeychainManager.swift`: Keychain key storage
- `Search/SearchIndexManager.swift`: FTS5 search implementation
- `Observables/History.swift`: History management and LRU
- `Models/HistoryItem.swift`: Core data model
- `Models/HistoryItemContent.swift`: Encrypted content storage

## Success Metrics

An AI agent is successful when:
- Code is immediately understandable to human developers
- All tests pass with good coverage
- Documentation is comprehensive and clear
- Error handling is robust and informative
- Security best practices are followed
- Zero network connections maintained
- Performance is optimized without sacrificing readability

## Remember

> **"The code you write today is the code you'll debug tomorrow."**

In AI-assisted development, prioritizing readability and simplicity isn't just good practice - it's essential for long-term maintainability. Buffer handles sensitive user data; every line of code must be secure, readable, and trustworthy.

---
