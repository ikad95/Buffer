import Foundation
import SwiftData

@Model
class HistoryItemContent {
  var type: String = ""
  private var encryptedValue: Data?
  var isEncrypted: Bool = false

  @Relationship
  var item: HistoryItem?

  /// Gets decrypted value
  var value: Data? {
    get {
      guard let data = encryptedValue else { return nil }

      if isEncrypted {
        return try? EncryptionManager.shared.decrypt(data)
      }
      return data
    }
    set {
      guard let data = newValue else {
        encryptedValue = nil
        isEncrypted = false
        return
      }

      if let encrypted = try? EncryptionManager.shared.encrypt(data) {
        encryptedValue = encrypted
        isEncrypted = true
      } else {
        // Fallback to unencrypted if encryption fails
        encryptedValue = data
        isEncrypted = false
      }
    }
  }

  init(type: String, value: Data? = nil) {
    self.type = type
    self.value = value
  }
}
