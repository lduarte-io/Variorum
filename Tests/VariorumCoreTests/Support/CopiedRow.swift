import GRDB

/// A `Sendable` copy of one fetched GRDB `Row` — 19a, the Xcode 27 / Swift
/// 6.4 migration. ONE FILE, THREE CONSUMERS (19b, the orchestrator's option
/// A): the core test target compiles it here, in place (SwiftPM); the Mac
/// (`VariorumTests`) and mobile (`VariorumMobileTests`) test targets compile
/// THIS SAME FILE through one explicit file reference in
/// `App/Variorum/Variorum.xcodeproj` (the `TestSupport` group, a build file in
/// each test target's Sources phase). Each test bundle gets its own internal
/// copy of the type from these bytes. Moving or renaming this file breaks the
/// two Xcode test builds loudly — re-point the reference with it.
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
/// missing-column behaviour are GRDB's own, never re-implemented here.
/// DUPLICATED COLUMN NAMES: an EXACT duplicate keeps the leftmost (GRDB's own
/// lookup rule); duplicates differing only in CASE are NOT supported — the
/// rebuilt row comes from an unordered dictionary, so which of them GRDB's
/// case-insensitive lookup finds is unspecified. Every live site reads a
/// single-table row, whose column names are unique. Equality is GRDB's
/// `Row ==` for rows without scopes or prefetched rows — which no raw-SQL
/// fetch has: names compared case-sensitively, in order, values by
/// `DatabaseValue ==`.
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
