import GRDB

/// A `Sendable` copy of one fetched GRDB `Row` — 19a, the Xcode 27 / Swift
/// 6.4 migration (the Mac test target carries the same type in
/// `App/Variorum/VariorumTests/CopiedRow.swift`).
///
/// GRDB 7 declares `Row`'s `Sendable` conformance UNAVAILABLE (a row may wrap
/// a live statement). Swift 6.2 treated that as "not Sendable" and silently
/// resolved `try await db.read { … Row … }` to the SYNCHRONOUS read; Swift
/// 6.4 selects the async `AppDatabase.read<T: Sendable>` and refuses the
/// `Row`. So a test that wants a row out of an async read copies it INSIDE the
/// closure — `try Row.fetchOne(…).map(CopiedRow.init)` — and keeps reading it
/// with `Row`'s own spellings, so no assertion changes a byte:
/// - `copy["col"] == nil` / `!= nil` — nil for a missing column or SQL NULL;
/// - `copy["col"] as String?`, `copy["col"] == "x"` — decoded to the asked type;
/// - `copies == otherCopies` — same columns, same order, same values.
///
/// Both subscripts READ THROUGH A REBUILT `Row`, so decoding, NULL and
/// missing-column behaviour are GRDB's own, never re-implemented here. The
/// rebuilt row keeps the LEFTMOST of any duplicated column name (GRDB's own
/// lookup rule); every site reads a single-table row, whose names are unique.
/// Equality is GRDB's `Row ==` for rows without scopes or prefetched rows —
/// which no raw-SQL fetch has: names compared case-sensitively, in order,
/// values by `DatabaseValue ==`.
struct CopiedRow: Sendable, Equatable {
    let columns: [String]
    let values: [DatabaseValue]

    init(_ row: Row) {
        columns = Array(row.columnNames)
        values = Array(row.databaseValues)
    }

    subscript(_ column: String) -> (any DatabaseValueConvertible)? {
        row[column]
    }

    subscript<Value: DatabaseValueConvertible>(_ column: String) -> Value {
        row[column]
    }

    private var row: Row {
        Row(Dictionary(
            zip(columns, values.map { $0 as (any DatabaseValueConvertible)? }),
            uniquingKeysWith: { leftmost, _ in leftmost }))
    }
}
