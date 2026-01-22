import XCTest
import Defaults
@testable import Buffer

class StorageTests: XCTestCase {

    let savedSize = Defaults[.size]
    let savedUnlimited = Defaults[.unlimitedHistory]
    let savedEnableLRU = Defaults[.enableLRU]
    let savedLRUDays = Defaults[.lruKeepDays]

    override func tearDown() {
        super.tearDown()
        // Restore original settings
        Defaults[.size] = savedSize
        Defaults[.unlimitedHistory] = savedUnlimited
        Defaults[.enableLRU] = savedEnableLRU
        Defaults[.lruKeepDays] = savedLRUDays
    }

    // MARK: - Settings Tests

    func testDefaultStorageSettings() {
        // Default values
        XCTAssertEqual(Defaults[.size], 200)
        XCTAssertFalse(Defaults[.unlimitedHistory])
        XCTAssertTrue(Defaults[.enableLRU])
        XCTAssertEqual(Defaults[.lruKeepDays], 7)
    }

    func testUnlimitedHistorySetting() {
        Defaults[.unlimitedHistory] = true
        XCTAssertTrue(Defaults[.unlimitedHistory])

        Defaults[.unlimitedHistory] = false
        XCTAssertFalse(Defaults[.unlimitedHistory])
    }

    func testLRUSetting() {
        Defaults[.enableLRU] = false
        XCTAssertFalse(Defaults[.enableLRU])

        Defaults[.enableLRU] = true
        XCTAssertTrue(Defaults[.enableLRU])
    }

    func testLRUKeepDays() {
        Defaults[.lruKeepDays] = 30
        XCTAssertEqual(Defaults[.lruKeepDays], 30)

        Defaults[.lruKeepDays] = 1
        XCTAssertEqual(Defaults[.lruKeepDays], 1)

        Defaults[.lruKeepDays] = 365
        XCTAssertEqual(Defaults[.lruKeepDays], 365)
    }

    func testSizeCanExceed999() {
        // Test that size is no longer limited to 999
        Defaults[.size] = 1000
        XCTAssertEqual(Defaults[.size], 1000)

        Defaults[.size] = 100_000
        XCTAssertEqual(Defaults[.size], 100_000)

        Defaults[.size] = 1_000_000
        XCTAssertEqual(Defaults[.size], 1_000_000)
    }

    // MARK: - LRU Logic Tests

    func testLRUEvictionLogic() {
        // This tests the date comparison logic used in LRU eviction
        let keepDays = 7
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -keepDays, to: Date.now)!

        // Item from 10 days ago should be evicted
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date.now)!
        XCTAssertTrue(oldDate < cutoffDate, "Old item should be before cutoff")

        // Item from 3 days ago should not be evicted
        let recentDate = Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!
        XCTAssertFalse(recentDate < cutoffDate, "Recent item should be after cutoff")

        // Item from exactly 7 days ago
        let exactDate = Calendar.current.date(byAdding: .day, value: -7, to: Date.now)!
        // This could go either way depending on time of day, so we just verify it's close
        XCTAssertTrue(abs(exactDate.timeIntervalSince(cutoffDate)) < 86400)
    }

    // MARK: - Integration Tests

    @MainActor
    func testStorageWithEncryption() async {
        // Verify that storage works with encryption enabled
        let testContent = "Test clipboard content for encryption"
        let testData = testContent.data(using: .utf8)

        // Create a history item content
        let content = HistoryItemContent(
            type: NSPasteboard.PasteboardType.string.rawValue,
            value: testData
        )

        // Verify encryption happened (value should be encrypted)
        XCTAssertTrue(content.isEncrypted, "Content should be encrypted")

        // Verify we can still read the original value
        if let decryptedData = content.value,
           let decryptedString = String(data: decryptedData, encoding: .utf8) {
            XCTAssertEqual(decryptedString, testContent)
        } else {
            XCTFail("Failed to decrypt content")
        }
    }
}
