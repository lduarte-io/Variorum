import Foundation
import GRDB

/// Global/document key-value. Synced (document semantics — segmentation must
/// match on iOS capture), upsert-only, never tombstoned (AppSpec §7).
public struct Setting: VariorumRecord {
    public static let databaseTableName = "setting"

    public var key: String
    public var value: String
    public var syncVersion: Int

    public init(key: String, value: String, syncVersion: Int = 0) {
        self.key = key
        self.value = value
        self.syncVersion = syncVersion
    }
}
