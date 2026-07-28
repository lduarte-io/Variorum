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
