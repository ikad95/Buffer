import XCTest
@testable import Buffer

class EncryptionTests: XCTestCase {

    // MARK: - EncryptionManager Tests

    func testEncryptDecryptData() throws {
        let originalData = "Hello, World! This is sensitive clipboard data.".data(using: .utf8)!

        let encrypted = try EncryptionManager.shared.encrypt(originalData)
        let decrypted = try EncryptionManager.shared.decrypt(encrypted)

        XCTAssertEqual(originalData, decrypted)
        XCTAssertNotEqual(originalData, encrypted, "Encrypted data should differ from original")
    }

    func testEncryptDecryptString() throws {
        let originalString = "Secret clipboard content 🔐"

        let encrypted = try EncryptionManager.shared.encryptString(originalString)
        let decrypted = try EncryptionManager.shared.decryptString(encrypted)

        XCTAssertEqual(originalString, decrypted)
        XCTAssertNotEqual(originalString, encrypted, "Encrypted string should differ from original")
    }

    func testEncryptedDataIsDifferentEachTime() throws {
        let originalData = "Same data".data(using: .utf8)!

        let encrypted1 = try EncryptionManager.shared.encrypt(originalData)
        let encrypted2 = try EncryptionManager.shared.encrypt(originalData)

        // AES-GCM uses random nonce, so same plaintext produces different ciphertext
        XCTAssertNotEqual(encrypted1, encrypted2, "Each encryption should produce unique ciphertext due to random nonce")

        // But both should decrypt to the same value
        let decrypted1 = try EncryptionManager.shared.decrypt(encrypted1)
        let decrypted2 = try EncryptionManager.shared.decrypt(encrypted2)
        XCTAssertEqual(decrypted1, decrypted2)
    }

    func testDecryptInvalidDataThrows() {
        let invalidData = "not valid encrypted data".data(using: .utf8)!

        XCTAssertThrowsError(try EncryptionManager.shared.decrypt(invalidData)) { error in
            // Should throw a CryptoKit error
            XCTAssertNotNil(error)
        }
    }

    func testEncryptEmptyData() throws {
        let emptyData = Data()

        let encrypted = try EncryptionManager.shared.encrypt(emptyData)
        let decrypted = try EncryptionManager.shared.decrypt(encrypted)

        XCTAssertEqual(emptyData, decrypted)
    }

    func testEncryptLargeData() throws {
        // 1MB of random data
        var largeData = Data(count: 1_000_000)
        _ = largeData.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
        }

        let encrypted = try EncryptionManager.shared.encrypt(largeData)
        let decrypted = try EncryptionManager.shared.decrypt(encrypted)

        XCTAssertEqual(largeData, decrypted)
    }

    func testEncryptUnicodeContent() throws {
        let unicodeString = "Hello 世界 🌍 مرحبا Привет 日本語"

        let encrypted = try EncryptionManager.shared.encryptString(unicodeString)
        let decrypted = try EncryptionManager.shared.decryptString(encrypted)

        XCTAssertEqual(unicodeString, decrypted)
    }

    // MARK: - KeychainManager Tests

    func testKeychainKeyConsistency() throws {
        // Get key twice - should be the same
        let key1 = try KeychainManager.shared.getOrCreateKey()
        let key2 = try KeychainManager.shared.getOrCreateKey()

        XCTAssertEqual(key1, key2, "Keychain should return the same key on subsequent calls")
    }

    func testKeychainKeySize() throws {
        let key = try KeychainManager.shared.getOrCreateKey()

        XCTAssertEqual(key.count, 32, "Key should be 256 bits (32 bytes) for AES-256")
    }

    // MARK: - Integration Tests

    func testEncryptedHistoryItemContent() throws {
        let originalText = "Sensitive clipboard data that should be encrypted"
        let originalData = originalText.data(using: .utf8)

        // Simulate what HistoryItemContent does
        let encrypted = try EncryptionManager.shared.encrypt(originalData!)
        let decrypted = try EncryptionManager.shared.decrypt(encrypted)

        XCTAssertEqual(originalData, decrypted)
        XCTAssertEqual(originalText, String(data: decrypted, encoding: .utf8))
    }
}
