import Foundation
import GRDB

/// Shared conformances for all table records: snake_case column mapping and
/// the canonical ISO-8601 timestamp encoding (AppSpec §6).
///
/// Records are plain value types — they mint nothing. IDs (random UUIDv4 via
/// `@Dependency(\.uuid)`, SyncSpec §9) and timestamps (`@Dependency(\.date)`)
/// are supplied by the operations layer (Phase 2), which is also where every
/// mutation lives.
public protocol VariorumRecord: Codable, Equatable, Sendable, FetchableRecord, PersistableRecord {}

extension VariorumRecord {
    public static var databaseColumnEncodingStrategy: DatabaseColumnEncodingStrategy { .convertToSnakeCase }
    public static var databaseColumnDecodingStrategy: DatabaseColumnDecodingStrategy { .convertFromSnakeCase }
    public static func databaseDateEncodingStrategy(for column: String) -> DatabaseDateEncodingStrategy {
        .formatted(.variorumISO8601)
    }
    public static func databaseDateDecodingStrategy(for column: String) -> DatabaseDateDecodingStrategy {
        .formatted(.variorumISO8601)
    }
}

extension DateFormatter {
    /// The canonical timestamp format: ISO-8601, millisecond precision, UTC —
    /// byte-identical to SQLite's `strftime('%Y-%m-%dT%H:%M:%fZ', 'now')`, so
    /// trigger-written and Swift-written timestamps sort together. Display
    /// semantics only; sync ordering authority is `server_seq` (SyncSpec §9).
    // DateFormatter is documented thread-safe on modern OS versions; the
    // annotation just isn't in the SDK.
    nonisolated(unsafe) public static let variorumISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
}
