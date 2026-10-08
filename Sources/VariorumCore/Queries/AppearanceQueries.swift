import Foundation
import GRDB

// The theme layer's read side (Phase 13, B1). One small fetch of the
// appearance keys — the `setting` table is tiny and the observation is
// bounded by construction.
extension Queries {
    /// The resolved appearance settings, defaults applied where unseeded.
    /// Defaults are the sittings' letter: a store with no voice reads STUDY
    /// (13s-b U1a — her 2026-10-05 ruling, `unsetStoreVoice` below; R1's
    /// Terminal stays the PLACEHOLDER `voice` holds before a store answers), seams
    /// hidden at rest (§12/R42), editing indicator OFF (R14/R22), margin
    /// comments (R7 — inline is the opt-in), follow-the-scroll off until
    /// asked for (R25 is an OPTION), receipts QUIET (18i — her R-Q5:
    /// *"Quiet should be the default, but toast should still be an
    /// option"*).
    public struct ThemeSettings: Equatable, Sendable {
        /// **The PLACEHOLDER voice** — what a host draws before any store has
        /// answered (a `ThemeStore` before its first emission), and what a
        /// host with no store at all draws (previews, mounted test surfaces —
        /// `themeStore?.settings ?? ThemeSettings()`): the leading voice, R1's
        /// Terminal, `VoiceTokens.fallback`'s twin. NOT what a store reads —
        /// that is `unsetStoreVoice`, applied by `themeSettings(_:)` alone.
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
        /// 13i-c U2 (the sitting record §6): the GLOBAL hide-owned default —
        /// whether gatherings (that do not say otherwise) and tag listings
        /// HIDE notes an owned book holds. OFF by default — "Global default =
        /// SHOW, badged (the Welcome lesson depends on it)". Stored "1"/"0";
        /// only "1" hides, so an unrecognized value is her default. Library
        /// is EXEMPT (R32), whatever this says.
        public var hideOwnedByDefault = false
        /// 13i-c U2 (§6 — "toggleable as a set; silence the common case"):
        /// the ownership BADGE family on or off as one switch. ON by default
        /// (PROVISIONAL P-13ic-10 — a synced setting, the `arrival_flash`
        /// class); anything but "0" reads ON.
        public var ownershipBadges = true

        /// **THE VOICE A STORE READS WHEN IT CARRIES NONE: STUDY** (13s-b
        /// U1a — her ruling 2026-10-05, verbatim: *"default mode study is an
        /// explicit ruling"*; the record is the 13s intake's flags section).
        /// A fresh store wakes in Study; a store that CARRIES a voice keeps it,
        /// by construction — a stored value always wins the read. A default
        /// flip at READ time, never a migration: nothing is written, no
        /// `setting` row is seeded, nothing syncs. The consequence, said
        /// plainly: an EXISTING store that never chose a voice (no row — it
        /// read Terminal until this build) reads Study from this build on; the
        /// U1a RECORD says which stores were checked for that.
        ///
        /// Deliberately NOT the memberwise `voice` default above: that one is
        /// the pre-landing / storeless placeholder, and moving it would
        /// re-voice every host that has no store to ask.
        public static let unsetStoreVoice: ThemeVoice = .study

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
                              'theme_accent_tint', 'arrival_flash',
                              'hide_owned_default', 'ownership_badges')
                """)
        var settings = ThemeSettings()
        // 13s-b U1a: the store's own default (no row, or an unreadable one).
        settings.voice = ThemeSettings.unsetStoreVoice
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
            case "hide_owned_default":
                settings.hideOwnedByDefault = value == "1"
            case "ownership_badges":
                settings.ownershipBadges = value != "0"
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

    /// The STARRED books (13i-a — starred absorbs pins, sitting record §7).
    /// The name survives until 13i-d's vocabulary sweep. Order: (name, id) —
    /// starred books float first under the shelf's own chosen order (§24), so
    /// this list is a SET in a stable order, not a pin-time sequence.
    ///
    /// **13i-d U2 ACT 0 — THE UNION** (F-U1-2 (A), ruled): a book is starred
    /// iff its `reading.starred` column is set OR its key is in the 13f
    /// `starred` list — the ONE truth `starredReadingIDs` states. Before this
    /// the float read the column alone, so a book starred from its row's ★
    /// door (which wrote only the list) never floated.
    public static func shelfPins(_ db: Database) throws -> [String] {
        try starredReadingRows(db).map(\.id)
    }

    /// **THE ONE STAR TRUTH FOR A READING** (13i-d U2 ACT 0): the live
    /// readings whose column is set OR whose key the list holds — by (name,
    /// id), case-insensitive. Every reader of "is this book starred" — the
    /// Bookcase's float, the phone's pins, the Starred section's column-only
    /// tail, the cap — asks THIS, so the two stores can never disagree about
    /// a book again. Cost: one pass over the live readings (author-scale)
    /// with an `IN` list bounded by the cap.
    static func starredReadingRows(_ db: Database) throws -> [(id: String, name: String)] {
        let listed = try starredTargets(db).compactMap { $0.kind == .reading ? $0.id : nil }
        var clause = "starred = 1"
        if !listed.isEmpty {
            let placeholders = Array(repeating: "?", count: listed.count).joined(separator: ",")
            clause = "(starred = 1 OR id IN (\(placeholders)))"
        }
        return try Row.fetchAll(
            db,
            sql: """
                SELECT id, name FROM reading
                WHERE deleted_at IS NULL AND \(clause)
                ORDER BY name COLLATE NOCASE, id
                """,
            arguments: StatementArguments(listed)
        ).map { (id: $0["id"], name: $0["name"]) }
    }

    /// The union, as a set — the Bookcase snapshot's per-row answer.
    public static func starredReadingIDs(_ db: Database) throws -> Set<String> {
        Set(try starredReadingRows(db).map(\.id))
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
    /// corpus: at most fifteen ids, resolved in two indexed reads — plus,
    /// since 13i-d U2, one pass over the live readings for the column-only
    /// tail (author-scale).
    ///
    /// **13i-d U2 ACT 0 — THE UNION** (F-U1-2 (A), ruled; R-13id-5): the
    /// list's live entries in STAR ORDER, then every live reading starred by
    /// its COLUMN alone, A–Z — the 13i-a-migrated shelf pins, and the daily
    /// Journal and Quicknotes (born starred, and kept so by her ruling), made
    /// visible in the section at last (§7: "pinned books become starred").
    public static func starred(_ db: Database) throws -> [StarredItem] {
        let listed = try starredListItems(db)
        let listedReadings = Set(listed.compactMap {
            $0.target.kind == .reading ? $0.target.id : nil
        })
        // Ladder A round 1, NIT 4: the tail's A–Z is the BOARD'S OWN rule
        // (`BookcaseOrdering.nameAscending` — Finder's digit-aware compare),
        // never the SQL collation, so "Book 2" precedes "Book 10" in the
        // Starred section exactly as on the Bookcase (one A–Z, two surfaces).
        let columnOnly = try starredReadingRows(db)
            .filter { !listedReadings.contains($0.id) }
            .sorted { BookcaseOrdering.nameAscending(($0.name, $0.id), ($1.name, $1.id)) }
            .map { StarredItem(target: .reading($0.id), name: $0.name) }
        return listed + columnOnly
    }

    /// **The Starred section of ONE wing** (13i-d U5 — PROVISIONAL
    /// P-13id-U5-10: §9's total isolation reaches the sidebar's Starred too —
    /// a star belongs to its thing, and the thing lives in one library). The
    /// union above, filtered to the targets that live in `wingID` as surfaces
    /// read wings (a dangling pointer is Home's). The cap stays STORE-WIDE —
    /// one star list, fifteen stars across every wing (the cap is about the
    /// list she keeps, not a room). Cost ∝ the cap (≤ 15 point reads).
    public static func starred(_ db: Database, wingID: String) throws -> [StarredItem] {
        try starred(db).filter { item in
            let table = item.target.kind == .post ? "container" : "reading"
            guard let stored = try String.fetchOne(
                db, sql: "SELECT wing_id FROM \(table) WHERE id = ?",
                arguments: [item.target.id])
            else { return false }
            return (try wingIsLive(db, id: stored) ? stored : "") == wingID
        }
    }

    /// The LIST half of the union: its live entries, in star order (the 13f
    /// read rule exactly — a dead target renders nothing). Internal: the
    /// write side's self-heal persists exactly this, and nothing outside the
    /// star machinery should see one store without the other.
    static func starredListItems(_ db: Database) throws -> [StarredItem] {
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

    /// The LIVE starred NOTES' ids, in star order — the rule grammar's STAR
    /// term context (`ruleMatchSQL`'s `starredNoteIDs`; the 13i-a plan §9
    /// hand-off c). Bounded by the cap, never the corpus. 13i-b U1's intake
    /// is its first consumer; the gathering assembly's call sites are U4's.
    public static func starredNoteIDs(_ db: Database) throws -> [String] {
        // Notes live in the LIST alone (the column is a reading's), so the
        // union's reading tail is never consulted here.
        try starredListItems(db).compactMap { $0.target.kind == .post ? $0.target.id : nil }
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

    /// **THE daily Journal — DERIVED from its marker** (13i-e; the sitting
    /// record §10, the identity memo §3 BUILT): the live reading wearing the
    /// `'daily'` marker, by the Journal-keeper repair's OWN pick — the
    /// smallest id among `dailyJournalBookCandidates` — so this read and the
    /// §7 convergence can never name two different books. An ARCHIVED Journal
    /// is live and is found (it "returns when a day arrives" —
    /// `shelveInDailyJournalBook` un-archives it); a tombstoned one is not, and
    /// none reads as nil (the next daily door mints one fresh).
    ///
    /// The `daily_journal_book` SETTING retires-as-read here: its writers
    /// (`setDailyJournalBook`, the daily mint, the keeper repair) keep it
    /// fresh as a cache — the memo §3's blessed letter — but no CAS race on
    /// it can decide which book ⌘J files into any more. *(Before 13i-e this
    /// read the setting: a dangling value beside a live marker-bearer read as
    /// "no Journal" and the next ⌘J minted a second one; a setting another
    /// device wrote could name a book that was not the marker-bearer. Both
    /// pinned red-on-old in `DailyJournalRulingsTests`.)* Cost ∝ the
    /// marker-bearing books — one or, mid-convergence, two.
    public static func dailyJournalBookID(_ db: Database) throws -> String? {
        try dailyJournalBookCandidates(db).first
    }

    /// **The ONE journal-profile string** (pre-13u Act 0, R-pre13u-1; made
    /// the single writer at the ladder's F9). Every door that mints a
    /// journal-profile book stamps THIS constant — the daily mint
    /// (`insertDailyJournalBook`), the Mac Shelf's "Create Journal Book",
    /// the phone's `.journal` book kind — and the Journal-keeper predicate
    /// below filters on it, so no door can drift into a profile spelling
    /// the repair does not recognise.
    ///
    /// 13i-a: this is THE DAILY JOURNAL'S OWN MARKER (the identity memo
    /// §3) — exactly one live book wears it per converged account; the ONE
    /// daily mint stamps it and `setDailyJournalBook` moves it with the
    /// designation. The deliberate-notebook doors mint the journal TRAIT
    /// (`journalTraitProfile`, next) instead.
    public static let dailyJournalBookProfile = "daily"

    /// The JOURNAL TRAIT's profile (13i-a; the sitting record §10): "entries
    /// date-stamped at creation, named by their day, sorted by entry date" —
    /// what `profile='journal'` has always meant, now distinct from THE
    /// daily Journal's own marker above. The deliberate-second-notebook
    /// doors (the Mac's "Create Journal Book", the phone's journal kind)
    /// mint THIS; only the one daily mint writes 'daily'. 13i-e's Collecting
    /// pane exposes it as the per-book settings row.
    public static let journalTraitProfile = "journal"

    /// THE one journal-trait predicate (13i-a ladder R1 M-2): "entries
    /// date-stamped at creation, named by their day, sorted by entry date"
    /// is TRUE of a trait book AND of the daily Journal — 'daily' implies
    /// the trait by construction (sitting record §10). Every FACE keying
    /// the trait consults this, never a raw profile compare: the recast
    /// made the designated book 'daily', and a face comparing to "journal"
    /// alone silently dropped the daily Journal from its own rule (the
    /// + new entry doors, the entries unit, the shelf's journal group).
    public static func hasJournalTrait(_ profile: String?) -> Bool {
        profile == journalTraitProfile || profile == dailyJournalBookProfile
    }

    /// **The daily mint's SIGNATURE — the Journal-keeper repair's "same
    /// book" predicate, as one pure function** (pre-13u Act 0, R-pre13u-1;
    /// name-shape at the F6 interim; RE-KEYED ON THE MARKER at 13i-a — the
    /// identity memo §3 built): a reading is the daily Journal iff it is a
    /// book wearing `profile='daily'`. Names are never keys.
    ///
    /// Why the marker suffices where F6's name shape could not: the ONE
    /// daily door (`insertDailyJournalBook` — ⌘J, Today's Entry, the
    /// phone's furniture) stamps `'daily'` and NOTHING ELSE ever does
    /// (the deliberate doors stamp the TRAIT; `setJournalTrait` refuses
    /// the marker as constitutive; `setDailyJournalBook` moves it), so
    /// two offline mints both wear it and converge, a deliberate notebook
    /// never wears it and survives, and a RENAME changes nothing —
    /// QUESTIONS #85(a)'s corner is CLOSED, the pin flipped to say so.
    public static func isDailyJournalMintShape(_ reading: Reading) -> Bool {
        isDailyJournalMintShape(kind: reading.kind, profile: reading.profile, name: reading.name)
    }

    /// The same predicate over the three columns — for a row that has not
    /// landed yet (the sync engine reads an ARRIVING reading's shape from
    /// its wire columns when no local row exists to fetch).
    public static func isDailyJournalMintShape(
        kind: ReadingKind, profile: String?, name: String
    ) -> Bool {
        // 13i-a RE-KEY (the identity memo §3, built at the sitting's §10
        // ruling): the marker IS the identity — kind + profile='daily',
        // the NAME LEG DROPPED (names are never keys; a RENAMED daily
        // Journal now converges with a fresh phone mint, closing
        // QUESTIONS #85(a)'s corner). The `name` parameter stays so the
        // wire-column call sites read unchanged; it is deliberately
        // unread.
        _ = name
        return kind == .book && profile == dailyJournalBookProfile
    }

    /// **The Journal-keeper repair's candidate set**: every live reading
    /// satisfying `isDailyJournalMintShape`, sorted by id, so index 0 is the
    /// deterministic keeper everywhere. Two rows here is the offline-race
    /// state the repair heals. The Swift-side `.filter` through the ONE
    /// predicate is kept (13i-a: it is the no-drift seam, even though the
    /// marker-only predicate makes it coincide with the SQL filter today).
    /// Cost ∝ the marker-bearing books, never the corpus.
    public static func dailyJournalBookCandidates(_ db: Database) throws -> [String] {
        try Reading.fetchAll(
            db,
            sql: """
                SELECT * FROM reading
                WHERE kind = 'book' AND profile = ? AND deleted_at IS NULL
                ORDER BY id
                """,
            arguments: [dailyJournalBookProfile])
            .filter(isDailyJournalMintShape)
            .map(\.id)
    }

    /// The designated QUICKNOTES book (13g batch 7 — her R6-4). An id
    /// pointing at a deleted book reads as none (the dangling rule). Since
    /// 13i-b U4 that no longer licenses a fresh mint: §20 rules Quicknotes
    /// ordinary, so a deleted one stays deleted
    /// (`quicknotesBookWasDesignated`, `Operations.ensureQuicknotesBook`).
    public static func quicknotesBookID(_ db: Database) throws -> String? {
        try designatedBookID(db, key: "quicknote_book")
    }

    /// Whether this store was EVER given a Quicknotes book — the designation
    /// row exists, live target or not (13i-b U4: a designation that names a
    /// dead reading is her deletion, never an invitation to mint a twin —
    /// `Operations.ensureQuicknotesBook`). The setting travels with the store
    /// (synced), so the decision does too.
    static func quicknotesBookWasDesignated(_ db: Database) throws -> Bool {
        try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM setting WHERE key = 'quicknote_book')") ?? false
    }

    /// The one designation read (the `setting` key → a LIVE reading id). Since
    /// 13i-e its only consumer is Quicknotes — the daily Journal's
    /// designation is derived from its marker (`dailyJournalBookID`).
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
