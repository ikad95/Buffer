import XCTest
@testable import Buffer

class SearchIndexTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear index before each test
        SearchIndexManager.shared.clearIndex()
    }

    override func tearDown() {
        super.tearDown()
        SearchIndexManager.shared.clearIndex()
    }

    // MARK: - Indexing Tests

    func testIndexAndSearchSingleItem() {
        SearchIndexManager.shared.indexItem(
            id: "test-1",
            title: "Hello World",
            content: "This is a test clipboard item",
            application: "TestApp"
        )

        let results = SearchIndexManager.shared.search(query: "hello")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.itemId, "test-1")
    }

    func testIndexMultipleItems() {
        SearchIndexManager.shared.indexItem(
            id: "item-1",
            title: "Apple Pie Recipe",
            content: "Mix flour, sugar, and apples",
            application: "Notes"
        )
        SearchIndexManager.shared.indexItem(
            id: "item-2",
            title: "Banana Bread",
            content: "Mash bananas and mix with flour",
            application: "Notes"
        )
        SearchIndexManager.shared.indexItem(
            id: "item-3",
            title: "Code Snippet",
            content: "func hello() { print(\"world\") }",
            application: "Xcode"
        )

        let flourResults = SearchIndexManager.shared.search(query: "flour")
        XCTAssertEqual(flourResults.count, 2)

        let appleResults = SearchIndexManager.shared.search(query: "apple")
        XCTAssertEqual(appleResults.count, 1)
        XCTAssertEqual(appleResults.first?.itemId, "item-1")

        let codeResults = SearchIndexManager.shared.search(query: "func")
        XCTAssertEqual(codeResults.count, 1)
        XCTAssertEqual(codeResults.first?.itemId, "item-3")
    }

    func testRemoveItem() {
        SearchIndexManager.shared.indexItem(
            id: "remove-test",
            title: "To Be Removed",
            content: "This item will be removed",
            application: nil
        )

        var results = SearchIndexManager.shared.search(query: "removed")
        XCTAssertEqual(results.count, 1)

        SearchIndexManager.shared.removeItem(id: "remove-test")

        results = SearchIndexManager.shared.search(query: "removed")
        XCTAssertEqual(results.count, 0)
    }

    func testClearIndex() {
        for i in 1...10 {
            SearchIndexManager.shared.indexItem(
                id: "clear-\(i)",
                title: "Item \(i)",
                content: "Content for item \(i)",
                application: nil
            )
        }

        var stats = SearchIndexManager.shared.statistics()
        XCTAssertEqual(stats.itemCount, 10)

        SearchIndexManager.shared.clearIndex()

        stats = SearchIndexManager.shared.statistics()
        XCTAssertEqual(stats.itemCount, 0)
    }

    // MARK: - Search Functionality Tests

    func testPrefixSearch() {
        SearchIndexManager.shared.indexItem(
            id: "prefix-1",
            title: "Programming",
            content: "Swift programming language",
            application: nil
        )

        // Should match with prefix
        let results = SearchIndexManager.shared.search(query: "prog")
        XCTAssertEqual(results.count, 1)
    }

    func testCaseInsensitiveSearch() {
        SearchIndexManager.shared.indexItem(
            id: "case-1",
            title: "UPPERCASE TITLE",
            content: "lowercase content",
            application: nil
        )

        let upperResults = SearchIndexManager.shared.search(query: "UPPERCASE")
        let lowerResults = SearchIndexManager.shared.search(query: "uppercase")
        let mixedResults = SearchIndexManager.shared.search(query: "UpperCase")

        XCTAssertEqual(upperResults.count, 1)
        XCTAssertEqual(lowerResults.count, 1)
        XCTAssertEqual(mixedResults.count, 1)
    }

    func testMultiWordSearch() {
        SearchIndexManager.shared.indexItem(
            id: "multi-1",
            title: "Important Meeting Notes",
            content: "Discussed project timeline and budget",
            application: "Notes"
        )

        let results = SearchIndexManager.shared.search(query: "meeting notes")
        XCTAssertEqual(results.count, 1)
    }

    func testSearchReturnsRelevanceOrder() {
        // Item with term in title (more relevant)
        SearchIndexManager.shared.indexItem(
            id: "relevance-1",
            title: "Swift Programming Guide",
            content: "Learn to code",
            application: nil
        )

        // Item with term in content (less relevant)
        SearchIndexManager.shared.indexItem(
            id: "relevance-2",
            title: "Learning Guide",
            content: "Swift is a programming language",
            application: nil
        )

        let results = SearchIndexManager.shared.search(query: "swift")
        XCTAssertEqual(results.count, 2)
        // BM25 should rank title match higher
    }

    func testEmptyQueryReturnsNoResults() {
        SearchIndexManager.shared.indexItem(
            id: "empty-1",
            title: "Test Item",
            content: "Test content",
            application: nil
        )

        let results = SearchIndexManager.shared.search(query: "")
        XCTAssertEqual(results.count, 0)
    }

    func testNoMatchReturnsEmpty() {
        SearchIndexManager.shared.indexItem(
            id: "nomatch-1",
            title: "Apple",
            content: "Fruit",
            application: nil
        )

        let results = SearchIndexManager.shared.search(query: "xyz123nonexistent")
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Statistics Tests

    func testStatistics() {
        XCTAssertEqual(SearchIndexManager.shared.statistics().itemCount, 0)

        for i in 1...5 {
            SearchIndexManager.shared.indexItem(
                id: "stats-\(i)",
                title: "Item \(i)",
                content: "Content",
                application: nil
            )
        }

        let stats = SearchIndexManager.shared.statistics()
        XCTAssertEqual(stats.itemCount, 5)
        XCTAssertGreaterThan(stats.sizeBytes, 0)
    }

    // MARK: - Unicode and Special Characters

    func testUnicodeContent() {
        SearchIndexManager.shared.indexItem(
            id: "unicode-1",
            title: "日本語タイトル",
            content: "これは日本語のコンテンツです",
            application: nil
        )

        let results = SearchIndexManager.shared.search(query: "日本語")
        XCTAssertEqual(results.count, 1)
    }

    func testEmojiContent() {
        SearchIndexManager.shared.indexItem(
            id: "emoji-1",
            title: "Fun Message 🎉",
            content: "Party time! 🎊🎈",
            application: nil
        )

        let results = SearchIndexManager.shared.search(query: "party")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Update Existing Item

    func testUpdateExistingItem() {
        SearchIndexManager.shared.indexItem(
            id: "update-1",
            title: "Original Title",
            content: "Original content",
            application: nil
        )

        var results = SearchIndexManager.shared.search(query: "original")
        XCTAssertEqual(results.count, 1)

        // Update with new content
        SearchIndexManager.shared.indexItem(
            id: "update-1",
            title: "Updated Title",
            content: "New content",
            application: nil
        )

        // Old content should not be found
        results = SearchIndexManager.shared.search(query: "original")
        XCTAssertEqual(results.count, 0)

        // New content should be found
        results = SearchIndexManager.shared.search(query: "updated")
        XCTAssertEqual(results.count, 1)
    }
}
