# Buffer Database Improvements Plan

## Current State

- **Storage**: SwiftData with SQLite backend
- **Limit**: 999 items (artificial)
- **Eviction**: Manual clear only
- **Encryption**: AES-256-GCM (just added)

## Goals

1. Remove artificial 999 item limit
2. Implement LRU (Least Recently Used) eviction
3. Add settings for storage management
4. Evaluate better embedded databases

---

## Option 1: Enhanced SwiftData (Recommended for Phase 1)

### Pros
- No new dependencies
- Native Apple framework
- Already integrated
- Works with existing encryption

### Cons
- Limited query performance at scale
- No built-in LRU

### Implementation

```swift
// Settings
@Default(.maxHistoryItems) var maxItems: Int // 0 = unlimited
@Default(.enableLRU) var enableLRU: Bool

// LRU Eviction
func evictLRU() {
    guard enableLRU, maxItems > 0 else { return }

    let descriptor = FetchDescriptor<HistoryItem>(
        sortBy: [SortDescriptor(\.lastCopiedAt, order: .forward)]
    )

    let items = try? context.fetch(descriptor)
    let excess = (items?.count ?? 0) - maxItems

    if excess > 0 {
        items?.prefix(excess).forEach { context.delete($0) }
    }
}
```

### Effort: Low (1-2 days)

---

## Option 2: SQLite with FTS5 (Full-Text Search)

### Pros
- Already using SQLite via SwiftData
- Fast full-text search
- Proven at scale

### Cons
- Need to manage raw SQL alongside SwiftData
- More complex migration

### Implementation
- Add FTS5 virtual table for searchable content
- Keep SwiftData for relationships
- Index: title, text content

### Effort: Medium (3-5 days)

---

## Option 3: RocksDB

### Pros
- Extremely fast writes
- Efficient for key-value with TTL
- Built-in compression
- Handles millions of records

### Cons
- C++ library (need Swift wrapper)
- Adds ~5MB to app size
- Learning curve
- Migration complexity

### Use Case
Best for: Very high volume clipboard usage (10K+ items)

### Libraries
- [ObjectBox](https://objectbox.io) - Swift-native, RocksDB-like
- [Realm](https://realm.io) - Mature, but heavier
- Custom RocksDB wrapper via SPM

### Effort: High (1-2 weeks)

---

## Option 4: LMDB (Lightning Memory-Mapped Database)

### Pros
- Zero-copy reads (very fast)
- ACID compliant
- Small footprint
- Good for read-heavy workloads

### Cons
- Fixed database size (must pre-allocate)
- Less flexible queries

### Effort: Medium-High (1 week)

---

## Option 5: DuckDB

### Pros
- Columnar storage (great for analytics)
- SQL support
- Fast aggregations

### Cons
- Overkill for clipboard manager
- Larger footprint

### Effort: Medium (1 week)

---

## Recommendation

### Phase 1: Quick Win (This Sprint)
- Remove 999 limit
- Add LRU with SwiftData
- Add settings UI

### Phase 2: Performance (Future)
- Add SQLite FTS5 for search
- Benchmark at 10K, 50K, 100K items
- Migrate to RocksDB/ObjectBox only if needed

---

## Settings UI Design

```
Storage Settings
├── Maximum Items
│   ├── [ ] Unlimited
│   ├── [x] Limited: [____] items
│   └── Current: 2,847 items (12.3 MB)
│
├── Auto-Cleanup (LRU)
│   ├── [x] Enabled
│   └── Keep at least: [___] days of history
│
└── [Clear All] [Export] [Import]
```

---

## Database Comparison

| Feature | SwiftData | SQLite+FTS | RocksDB | LMDB |
|---------|-----------|------------|---------|------|
| Read Speed | Good | Good | Excellent | Excellent |
| Write Speed | Good | Good | Excellent | Good |
| Search | Basic | Excellent | Manual | Manual |
| Compression | No | No | Yes | No |
| Max Items | ~100K | ~1M | ~10M+ | ~1M |
| Dependencies | None | None | Yes | Yes |
| Migration | N/A | Easy | Hard | Medium |

---

## Security Considerations

- All options must integrate with existing AES-256-GCM encryption
- Encryption key remains in Keychain
- No plaintext should ever hit disk
- Consider: encrypt database file itself (SQLCipher)

---

## Next Steps

1. [ ] Remove 999 limit in `Defaults.Keys`
2. [ ] Add `maxHistoryItems` and `enableLRU` settings
3. [ ] Implement LRU eviction in `History.swift`
4. [ ] Add Settings UI for storage management
5. [ ] Benchmark with 10K items
6. [ ] Decide on Phase 2 database
