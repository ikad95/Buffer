import Foundation
import Security

/// Manages secure storage of encryption keys in macOS Keychain
final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "org.codexvault.Buffer"
    private let account = "EncryptionKey"
    private let keySize = 32 // 256 bits for AES-256

    private init() {}

    /// Retrieves or generates the encryption key
    func getOrCreateKey() throws -> Data {
        if let existingKey = try? retrieveKey() {
            return existingKey
        }

        let newKey = generateKey()
        try storeKey(newKey)
        return newKey
    }

    /// Generates a cryptographically secure random key
    private func generateKey() -> Data {
        var bytes = [UInt8](repeating: 0, count: keySize)
        let status = SecRandomCopyBytes(kSecRandomDefault, keySize, &bytes)

        guard status == errSecSuccess else {
            fatalError("Failed to generate secure random key")
        }

        return Data(bytes)
    }

    /// Stores the key in Keychain
    private func storeKey(_ key: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing key first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unableToStore(status)
        }
    }

    /// Retrieves the key from Keychain
    private func retrieveKey() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unableToRetrieve(status)
        }

        return data
    }

    /// Deletes the key from Keychain (use with caution - data will be unrecoverable)
    func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status)
        }
    }
}

enum KeychainError: Error, LocalizedError {
    case unableToStore(OSStatus)
    case unableToRetrieve(OSStatus)
    case unableToDelete(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unableToStore(let status):
            return "Unable to store key in Keychain: \(status)"
        case .unableToRetrieve(let status):
            return "Unable to retrieve key from Keychain: \(status)"
        case .unableToDelete(let status):
            return "Unable to delete key from Keychain: \(status)"
        }
    }
}
