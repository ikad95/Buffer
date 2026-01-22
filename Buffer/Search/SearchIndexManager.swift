import Foundation
import SQLite3

/// Manages FTS5 full-text search indexing for clipboard history
final class SearchIndexManager {
    static let shared = SearchIndexManager()

    private var db: OpaquePointer?
    private let dbPath: URL

    private init() {
        dbPath = URL.applicationSupportDirectory
            .appending(path: "Buffer")
            .appending(path: "SearchIndex.sqlite")

        setupDatabase()
    }

    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }

    // MARK: - Setup

    private func setupDatabase() {
        // Ensure directory exists
        try? FileManager.default.createDirectory(
            at: dbPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // Open database
        if sqlite3_open(dbPath.path, &db) != SQLITE_OK {
            print("SearchIndexManager: Failed to open database")
            return
        }

        // Create FTS5 virtual table
        let createTableSQL = """
            CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
                item_id,
                title,
                content,
                application,
                tokenize='porter unicode61'
            );
        """

        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            print("SearchIndexManager: Failed to create FTS5 table")
        }

        // Create metadata table for tracking indexed items
        let createMetaSQL = """
            CREATE TABLE IF NOT EXISTS index_meta (
                item_id TEXT PRIMARY KEY,
                indexed_at REAL,
                content_hash TEXT
            );
        """

        if sqlite3_exec(db, createMetaSQL, nil, nil, nil) != SQLITE_OK {
            print("SearchIndexManager: Failed to create metadata table")
        }
    }

    // MARK: - Indexing

    /// Index a single item
    func indexItem(id: String, title: String, content: String, application: String?) {
        // First remove any existing entry
        removeItem(id: id)

        let insertSQL = """
            INSERT INTO search_index (item_id, title, content, application)
            VALUES (?, ?, ?, ?);
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(statement, 2, title, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(statement, 3, content, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_text(statement, 4, application ?? "", -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)

        // Update metadata
        let metaSQL = """
            INSERT OR REPLACE INTO index_meta (item_id, indexed_at, content_hash)
            VALUES (?, ?, ?);
        """

        if sqlite3_prepare_v2(db, metaSQL, -1, &statement, nil) == SQLITE_OK {
            let hash = content.hashValue
            sqlite3_bind_text(statement, 1, id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_bind_double(statement, 2, Date.now.timeIntervalSince1970)
            sqlite3_bind_text(statement, 3, String(hash), -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    /// Remove an item from the index
    func removeItem(id: String) {
        let deleteSQL = "DELETE FROM search_index WHERE item_id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)

        let deleteMetaSQL = "DELETE FROM index_meta WHERE item_id = ?;"
        if sqlite3_prepare_v2(db, deleteMetaSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    /// Clear the entire index
    func clearIndex() {
        sqlite3_exec(db, "DELETE FROM search_index;", nil, nil, nil)
        sqlite3_exec(db, "DELETE FROM index_meta;", nil, nil, nil)
    }

    // MARK: - Searching

    /// Search for items matching the query
    /// Returns array of item IDs sorted by relevance
    func search(query: String) -> [SearchResult] {
        guard !query.isEmpty else { return [] }

        var results: [SearchResult] = []

        // Use FTS5 MATCH with BM25 ranking
        let searchSQL = """
            SELECT item_id, title, snippet(search_index, 2, '<mark>', '</mark>', '...', 32),
                   bm25(search_index) as rank
            FROM search_index
            WHERE search_index MATCH ?
            ORDER BY rank
            LIMIT 1000;
        """

        var statement: OpaquePointer?
        let ftsQuery = formatFTSQuery(query)

        if sqlite3_prepare_v2(db, searchSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, ftsQuery, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))

            while sqlite3_step(statement) == SQLITE_ROW {
                let itemId = String(cString: sqlite3_column_text(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let snippet = String(cString: sqlite3_column_text(statement, 2))
                let rank = sqlite3_column_double(statement, 3)

                results.append(SearchResult(
                    itemId: itemId,
                    title: title,
                    snippet: snippet,
                    score: -rank // BM25 returns negative scores, lower is better
                ))
            }
        }
        sqlite3_finalize(statement)

        return results
    }

    /// Format query for FTS5
    private func formatFTSQuery(_ query: String) -> String {
        // Split into words and add prefix matching
        let words = query
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .map { "\($0)*" } // Add prefix matching

        return words.joined(separator: " ")
    }

    // MARK: - Maintenance

    /// Optimize the search index
    func optimize() {
        sqlite3_exec(db, "INSERT INTO search_index(search_index) VALUES('optimize');", nil, nil, nil)
    }

    /// Get index statistics
    func statistics() -> IndexStatistics {
        var count = 0
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM search_index;", -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: dbPath.path)[.size] as? Int) ?? 0

        return IndexStatistics(itemCount: count, sizeBytes: fileSize)
    }
}

// MARK: - Models

struct SearchResult {
    let itemId: String
    let title: String
    let snippet: String
    let score: Double
}

struct IndexStatistics {
    let itemCount: Int
    let sizeBytes: Int

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeBytes), countStyle: .file)
    }
}
