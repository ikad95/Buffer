import Foundation
import CryptoKit

/// Handles encryption/decryption of clipboard data using AES-256-GCM
final class EncryptionManager {
    static let shared = EncryptionManager()

    private var symmetricKey: SymmetricKey?

    private init() {
        initializeKey()
    }

    private func initializeKey() {
        do {
            let keyData = try KeychainManager.shared.getOrCreateKey()
            symmetricKey = SymmetricKey(data: keyData)
        } catch {
            fatalError("Failed to initialize encryption key: \(error.localizedDescription)")
        }
    }

    /// Encrypts data using AES-256-GCM
    /// Returns: Combined nonce + ciphertext + tag
    func encrypt(_ data: Data) throws -> Data {
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotInitialized
        }

        let sealedBox = try AES.GCM.seal(data, using: key)

        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }

        return combined
    }

    /// Decrypts data that was encrypted with encrypt()
    func decrypt(_ data: Data) throws -> Data {
        guard let key = symmetricKey else {
            throw EncryptionError.keyNotInitialized
        }

        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    /// Encrypts a string and returns base64 encoded ciphertext
    func encryptString(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.invalidInput
        }

        let encrypted = try encrypt(data)
        return encrypted.base64EncodedString()
    }

    /// Decrypts a base64 encoded ciphertext back to string
    func decryptString(_ base64String: String) throws -> String {
        guard let data = Data(base64Encoded: base64String) else {
            throw EncryptionError.invalidInput
        }

        let decrypted = try decrypt(data)

        guard let string = String(data: decrypted, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }

        return string
    }

    /// Securely wipes data from memory
    func secureWipe(_ data: inout Data) {
        data.withUnsafeMutableBytes { buffer in
            if let baseAddress = buffer.baseAddress {
                memset_s(baseAddress, buffer.count, 0, buffer.count)
            }
        }
        data = Data()
    }
}

enum EncryptionError: Error, LocalizedError {
    case keyNotInitialized
    case encryptionFailed
    case decryptionFailed
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .keyNotInitialized:
            return "Encryption key not initialized"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .invalidInput:
            return "Invalid input data"
        }
    }
}
