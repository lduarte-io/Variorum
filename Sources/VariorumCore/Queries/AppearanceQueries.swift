import Foundation
import GRDB

// The theme layer's read side (Phase 13, B1). One small fetch of the
// appearance keys — the `setting` table is tiny and the observation is
// bounded by construction.
extension Queries {
    /// The resolved appearance settings, defaults applied where unseeded.
    /// Defaults are the sittings' letter: Terminal leads (R1), seams
    /// hidden at rest (§12/R42), editing indicator OFF (R14/R22), margin
    /// comments (R7 — inline is the opt-in), follow-the-scroll off until
    /// asked for (R25 is an OPTION).
    public struct ThemeSettings: Equatable, Sendable {
        public var voice: ThemeVoice = .terminal
        public var seamsVisible = false
        public var editingIndicator: EditingIndicatorStyle = .off
        public var inlineComments = false
        public var followTheScroll = false
        public var fanStyle: FanStyle = .stack

        public init() {}
    }

    public static func themeSettings(_ db: Database) throws -> ThemeSettings {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT key, value FROM setting
                WHERE key IN ('theme_voice', 'seams_visible', 'editing_indicator',
                              'inline_comments', 'follow_the_scroll', 'fan_style')
                """)
        var settings = ThemeSettings()
        for row in rows {
            let value: String = row["value"]
            switch row["key"] as String {
            case "theme_voice":
                settings.voice = ThemeVoice(rawValue: value) ?? settings.voice
            case "seams_visible":
                settings.seamsVisible = value == "1"
            case "editing_indicator":
                settings.editingIndicator =
                    EditingIndicatorStyle(rawValue: value) ?? settings.editingIndicator
            case "inline_comments":
                settings.inlineComments = value == "1"
            case "follow_the_scroll":
                settings.followTheScroll = value == "1"
            case "fan_style":
                settings.fanStyle = FanStyle(rawValue: value) ?? settings.fanStyle
            default:
                break
            }
        }
        return settings
    }

    /// The DOCUMENT-GLOBAL segmentation default (13d batch 4 — A16's read
    /// half; the setter is `Operations.setDefaultSegmentation`). Absent or
    /// unrecognized reads as `.paragraph` — the schema's own seed and the
    /// same fallback `containerHeader` has applied since Phase 7, stated
    /// once here so the settings face and the editor can never disagree
    /// about what "unset" means.
    public static func defaultSegmentation(_ db: Database) throws -> Segmentation {
        try String
            .fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'default_segmentation'")
            .flatMap(Segmentation.init(rawValue:)) ?? .paragraph
    }

    /// The shelf's pin list (R38), in pin order. Malformed JSON reads as
    /// no pins (fail-open — pins are presentation, never truth).
    public static func shelfPins(_ db: Database) throws -> [String] {
        guard let json = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'shelf_pins'")
        else { return [] }
        return (try? JSONDecoder().decode([String].self, from: Data(json.utf8))) ?? []
    }

    // MARK: - Stars (13f W4)

    /// One starred row, ready to render: what it points at and the name it
    /// wears. `name` is the STORED title — nil where the row has none, so
    /// the app's ONE naming brain (`WorkspaceNaming.label`) supplies
    /// "Untitled"/"Book" exactly as it does for every other chrome label,
    /// instead of a second fallback growing here.
    public struct StarredItem: Equatable, Sendable {
        public let target: StarTarget
        public let name: String?

        public init(target: StarTarget, name: String?) {
            self.target = target
            self.name = name
        }
    }

    /// The starred notes and books, in STAR ORDER (star time — her ruling's
    /// insertion order), each with its display name.
    ///
    /// **THE READ RULE, stated once and pinned:** a star whose target is not
    /// a LIVE note or book renders NOTHING — a deleted, archived-to-death or
    /// never-arrived target is simply absent from this list, the
    /// `dailyJournalBookID` fallback class. Unreadable entries and malformed
    /// JSON read as no stars (fail-open: stars are presentation, never
    /// truth — the `shelfPins` rule).
    ///
    /// The list's SELF-HEAL is the write side's: `Operations.setStarred`
    /// persists exactly what this returns, so a dead entry disappears from
    /// the stored value the next time she stars or un-stars anything — which
    /// is also what keeps the cap counting only what she can see.
    ///
    /// Cost is bounded by the cap (`Operations.starLimit`), not by the
    /// corpus: at most five ids, resolved in two indexed reads.
    public static func starred(_ db: Database) throws -> [StarredItem] {
        let targets = try starredTargets(db)
        guard !targets.isEmpty else { return [] }

        /// One indexed read per kind, keyed by id. The placeholder idiom is
        /// `PageExtents`' (the repo's one shape for an `IN` list).
        func names(_ ids: [String], from table: String, titleColumn: String,
                   filter: String) throws -> [String: String?] {
            guard !ids.isEmpty else { return [:] }
            let placeholders = Array(repeating: "?", count: ids.count).joined(separator: ",")
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT id, \(titleColumn) AS name FROM \(table)
                    WHERE id IN (\(placeholders)) \(filter) AND deleted_at IS NULL
                    """,
                arguments: StatementArguments(ids))
            return Dictionary(
                rows.map { ($0["id"] as String, $0["name"] as String?) },
                uniquingKeysWith: { first, _ in first })
        }

        let posts = try names(
            targets.filter { $0.kind == .post }.map(\.id),
            from: "container", titleColumn: "title", filter: "AND kind = 'post'")
        let readings = try names(
            targets.filter { $0.kind == .reading }.map(\.id),
            from: "reading", titleColumn: "name", filter: "")

        return targets.compactMap { target in
            let table = target.kind == .post ? posts : readings
            // `table[id]` is `String??` — the OUTER optional answers "is it
            // live", the inner one "does it have a title". Only the outer
            // one decides whether the row renders.
            guard let name = table[target.id] else { return nil }
            return StarredItem(target: target, name: name)
        }
    }

    /// The stored star list, decoded but NOT liveness-filtered. Internal:
    /// the write side needs it to tell a no-op write from a self-healing
    /// one, and nothing else should ever see a star whose target is gone.
    static func starredTargets(_ db: Database) throws -> [StarTarget] {
        guard let json = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'starred'")
        else { return [] }
        let keys = (try? JSONDecoder().decode([String].self, from: Data(json.utf8))) ?? []
        var seen = Set<StarTarget>()
        return keys.compactMap(StarTarget.init(key:)).filter { seen.insert($0).inserted }
    }

    /// The designated daily journal book, when one exists (Phase 13 B3,
    /// PROVISIONAL). A dangling id (book deleted) reads as none — the
    /// fallback class.
    public static func dailyJournalBookID(_ db: Database) throws -> String? {
        guard let id = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'daily_journal_book'")
        else { return nil }
        let live = try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM reading WHERE id = ? AND deleted_at IS NULL)",
            arguments: [id]) ?? false
        return live ? id : nil
    }
}
