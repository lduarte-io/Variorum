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
    /// asked for (R25 is an OPTION), receipts QUIET (18i — her R-Q5:
    /// *"Quiet should be the default, but toast should still be an
    /// option"*).
    public struct ThemeSettings: Equatable, Sendable {
        public var voice: ThemeVoice = .terminal
        public var seamsVisible = false
        public var editingIndicator: EditingIndicatorStyle = .off
        public var inlineComments = false
        public var followTheScroll = false
        public var fanStyle: FanStyle = .stack
        /// 18i (R-Q5): what a RECEIPT does. Refusals and offers always
        /// toast whatever this says — `ReceiptStyle` carries the reasoning.
        public var receiptStyle: ReceiptStyle = .quiet
        /// 18g (R-Q6/R-Q11/R-Q13): the colour palette layered UNDER the
        /// voice. `.default` is each voice's shipped colours, byte-identical.
        public var palette: ThemePalette = .default
        /// 18g: the `custom` palette's ROOM seed — six hex digits, or nil.
        /// Validated on the read through the ONE rule (`ThemeTint`), so a
        /// value that is not a colour reads as ABSENT and `custom` falls
        /// back to the voice's own family rather than to half a palette.
        public var customRoom: String?
        /// 18g: the `custom` palette's optional ACCENT seed (her R-Q13's
        /// "an optional second"). Absent means DERIVED — the room hue
        /// deepened, which is exactly what a pastel preset does.
        public var customAccent: String?
        /// 18l-c U8 (her R-18l-7 — *"you should also be able to turn this
        /// flash where your cursor is setting off, but it should default to
        /// on"*): the brief highlight a MODE SWITCH leaves on the caret's line /
        /// the landed block. ON by default, resolved here (no seed — the
        /// `receipt_style` precedent); stored "1"/"0" (a token, never prose —
        /// `setting.value`'s PLAIN classification holds); anything but "0"
        /// reads as ON, so an unrecognized value is her default, never a
        /// silent OFF.
        public var arrivalFlash = true

        public init() {}
    }

    public static func themeSettings(_ db: Database) throws -> ThemeSettings {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT key, value FROM setting
                WHERE key IN ('theme_voice', 'seams_visible', 'editing_indicator',
                              'inline_comments', 'follow_the_scroll', 'fan_style',
                              'receipt_style', 'theme_palette', 'theme_tint',
                              'theme_accent_tint', 'arrival_flash')
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
            case "receipt_style":
                settings.receiptStyle = ReceiptStyle(rawValue: value) ?? settings.receiptStyle
            case "theme_palette":
                settings.palette = ThemePalette(rawValue: value) ?? settings.palette
            // 18g: the two seeds go through the ONE validation rule on the
            // way IN, so nothing downstream ever has to ask whether a
            // stored tint is a colour (`ThemeTint` carries the reasoning).
            case "theme_tint":
                settings.customRoom = ThemeTint.normalize(value)
            case "theme_accent_tint":
                settings.customAccent = ThemeTint.normalize(value)
            case "arrival_flash":
                settings.arrivalFlash = value != "0"
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
        try designatedBookID(db, key: "daily_journal_book")
    }

    /// **The ONE journal-profile string** (pre-13u Act 0, R-pre13u-1; made
    /// the single writer at the ladder's F9). Every door that mints a
    /// journal-profile book stamps THIS constant — the daily mint
    /// (`insertDailyJournalBook`), the Mac Shelf's "Create Journal Book",
    /// the phone's `.journal` book kind — and the Journal-keeper predicate
    /// below filters on it, so no door can drift into a profile spelling
    /// the repair does not recognise.
    ///
    /// What the profile means: *a dated notebook* (entries in `entry_date`
    /// order). It does NOT mean "the daily Journal" — the product
    /// deliberately mints ADDITIONAL journal-profile notebooks through two
    /// user doors (AppSpec §14 item 10's "starting a 'new' journal as a
    /// separate notebook"), which is why the predicate below needs a
    /// second leg.
    public static let dailyJournalBookProfile = "journal"

    /// **The daily mint's SIGNATURE — the Journal-keeper repair's "same
    /// book" predicate, as one pure function** (pre-13u Act 0, R-pre13u-1;
    /// NARROWED at the ladder's F6). A reading is the daily Journal's shape
    /// when it is curated, wears the journal profile, AND wears the daily
    /// mint's default name under `BookNaming`'s key (ends-trimmed,
    /// case-folded — the E13 rule, reused rather than re-derived).
    ///
    /// Why all three legs: `insertDailyJournalBook` — the one shared daily
    /// door (⌘J, Today's Entry, the phone's furniture; the retired bridge
    /// until 2026-09-04) — stamps
    /// exactly this triple, so two devices each minting the Journal offline
    /// produce two rows that BOTH satisfy it and converge. A deliberate
    /// second notebook never does: the Mac's "Create Journal Book" and the
    /// phone's `.journal` kind mint the profile but refuse the name
    /// (`assertBookNameIsFree` at their doors, against the live Journal),
    /// and the F6 finding was exactly the profile-only predicate merging
    /// those notebooks into the Journal. E13's objection was to keying on
    /// the name ALONE ("would delete a book she made on her phone") — a
    /// plain `profile:'book'` book named "Journal" still fails the profile
    /// leg and survives.
    ///
    /// The honest consequence of the name leg, recorded at QUESTIONS #85(a):
    /// a daily Journal she RENAMED no longer converges with a fresh phone
    /// mint — the two stand as separate journal-profile books until she
    /// merges them by hand. The repair heals the race it was built for
    /// (two untouched mints) and never touches a book whose name she chose.
    public static func isDailyJournalMintShape(_ reading: Reading) -> Bool {
        isDailyJournalMintShape(kind: reading.kind, profile: reading.profile, name: reading.name)
    }

    /// The same predicate over the three columns — for a row that has not
    /// landed yet (the sync engine reads an ARRIVING reading's shape from
    /// its wire columns when no local row exists to fetch).
    public static func isDailyJournalMintShape(
        kind: ReadingKind, profile: String?, name: String
    ) -> Bool {
        kind == .curated
            && profile == dailyJournalBookProfile
            && BookNaming.sameName(name, Operations.defaultDailyJournalBookName)
    }

    /// **The Journal-keeper repair's candidate set**: every live reading
    /// satisfying `isDailyJournalMintShape`, sorted by id, so index 0 is the
    /// deterministic keeper everywhere. Two rows here is the offline-race
    /// state the repair heals. The name leg is applied in Swift so the ONE
    /// key (`BookNaming.key`) serves — SQLite's `LOWER` is ASCII-only and
    /// its `TRIM` trims spaces only, and a second folding rule would be a
    /// second predicate. Cost ∝ the shelf's journal-profile books, never
    /// the corpus.
    public static func dailyJournalBookCandidates(_ db: Database) throws -> [String] {
        try Reading.fetchAll(
            db,
            sql: """
                SELECT * FROM reading
                WHERE kind = 'curated' AND profile = ? AND deleted_at IS NULL
                ORDER BY id
                """,
            arguments: [dailyJournalBookProfile])
            .filter(isDailyJournalMintShape)
            .map(\.id)
    }

    /// The designated QUICKNOTES book (13g batch 7 — her R6-4). The daily
    /// book's twin in every respect, including the dangling rule: an id
    /// pointing at a deleted book reads as none, which is exactly what lets
    /// `ensureQuicknotesBook` mint a fresh one rather than resurrect a book
    /// she threw away.
    public static func quicknotesBookID(_ db: Database) throws -> String? {
        try designatedBookID(db, key: "quicknote_book")
    }

    /// The one designation read (the `setting` key → a LIVE reading id).
    private static func designatedBookID(_ db: Database, key: String) throws -> String? {
        guard let id = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = ?", arguments: [key])
        else { return nil }
        let live = try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM reading WHERE id = ? AND deleted_at IS NULL)",
            arguments: [id]) ?? false
        return live ? id : nil
    }
}
