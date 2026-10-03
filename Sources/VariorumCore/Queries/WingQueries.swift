import Foundation
import GRDB

// WINGS — the reads (13i-d U5; the sitting record §9: "nothing should cross
// wings — the entire point is that it's basically a whole separate library").
//
// THE HOME WING IS VIRTUAL (R-13ia-2): `wing` rows are the ADDITIONAL wings;
// every `wing_id` of '' means Home. One read-time rule joins it here:
//
// **A DANGLING WING POINTER READS AS HOME** (PROVISIONAL P-13id-U5-2 — the
// dangling-shelf rule one level up, §19). A wing can only be deleted EMPTY
// (R-13id-2), so locally nothing live is ever left pointing at a dead wing —
// but its TRASH rows are (a note deleted inside the wing, then the wing
// emptied and deleted), and so is a row another device added to the wing
// while this one deleted it (a sync race). Reading those as Home keeps every
// one of them on a surface — the Trash's Put back, the Library — instead of
// silently nowhere, with no repair class: it is a read-time rule, exactly as
// a dangling shelf pointer reads as unshelved. (A Put back RE-HOMES such a row
// — `Operations.restoreContainer`/`restoreReading` — so it comes back as an
// ordinary Home row rather than a permanently dangling one.)
extension Queries {
    /// The one wing-scope fragment every scoped read composes. `column` is a
    /// compile-time column reference (`c.wing_id`), never user data.
    ///
    /// - a non-Home wing: `column = ?`
    /// - HOME (`''`): `(column = '' OR column NOT IN (live wing ids))` — the
    ///   dangling reading above. The subquery is over the `wing` table alone
    ///   (author-scale — a handful of rows; P1-trivial).
    public static func wingScope(
        column: String, wingID: String
    ) -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        if wingID.isEmpty {
            return ("(\(column) = '' OR \(column) NOT IN "
                    + "(SELECT w.id FROM wing w WHERE w.deleted_at IS NULL))", [])
        }
        return ("\(column) = ?", [wingID])
    }

    /// **THE REVIVAL'S WING RULE** (13i-d U5b — F-U5b-1, PROVISIONAL
    /// P-13id-U5b-5): a Put back revives a membership only when the note and
    /// the book live in the SAME wing as surfaces read them — a book never
    /// spans wings (§9). `restoreContainerRows` scopes the reading side by the
    /// note's wing, `restoreReading` the note side by the book's, each read
    /// AFTER its own re-home (a row whose wing died comes back to Home, so a
    /// pair that lay in a dead wing's Trash together comes home together).
    /// The fragment is `wingScope` over an UNALIASED `wing_id` (the
    /// subqueries name one table each), named once so both sites and the
    /// architect's F-U5b-2 proposal read the same rule.
    static func revivalWingScope(
        wingID: String
    ) -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        wingScope(column: "wing_id", wingID: wingID)
    }

    /// **THE UNDO/REDO REVIVAL'S WING RULE** (13i-d U6 ACT 0 — F-U5b-2,
    /// RULED (a) at the adjudication after U5b): whether reviving `postID`'s
    /// membership row in `readingID` keeps the pair in ONE wing as surfaces
    /// read them — the note's EFFECTIVE wing (a dangling pointer is Home's,
    /// which is also where a Put back would re-home it), the book side
    /// through `revivalWingScope`, the one fragment the two Put-back sites
    /// read. A structural replay recorded BEFORE a wing move (the moves
    /// register no entry and clear nothing) can otherwise revive a row across
    /// wings; the guarded roads — `revertDiverge`, `reapplyDiverge`,
    /// `reapplySmartConversion` — ask this before any write and, on false,
    /// treat their entry as OBSOLETE (each road's own "book deleted
    /// meanwhile" bucket: quiet, nothing written). Callers have already
    /// guarded the book's liveness; an unknown note answers true (the roads'
    /// own live-post guards decide it).
    static func membershipRevivalStaysInOneWing(
        _ db: Database, postID: String, readingID: String
    ) throws -> Bool {
        guard let noteWing = try effectiveWing(db, ofPost: postID) else { return true }
        let scope = revivalWingScope(wingID: noteWing)
        return try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM reading WHERE id = ? AND \(scope.sql))",
            arguments: StatementArguments([readingID] + scope.arguments)) ?? false
    }

    /// The live ADDITIONAL wings in switcher order — `(position, id)`, the
    /// fractional-index sort key (AppSpec §6). Home is virtual and never a
    /// row; the switcher lists it first by itself.
    public static func wings(_ db: Database) throws -> [Wing] {
        try Wing.fetchAll(
            db,
            sql: "SELECT * FROM wing WHERE deleted_at IS NULL ORDER BY position, id")
    }

    /// One live wing, or nil (dead, unknown, or Home's '').
    public static func liveWing(_ db: Database, id: String) throws -> Wing? {
        guard !id.isEmpty else { return nil }
        return try Wing.fetchOne(
            db, sql: "SELECT * FROM wing WHERE id = ? AND deleted_at IS NULL", arguments: [id])
    }

    /// Whether `wingID` names a wing a surface can stand in: Home always, any
    /// other id only while its row is live. The current-wing memory reads
    /// through this, so a wing deleted elsewhere returns the app to Home.
    public static func wingIsLive(_ db: Database, id: String) throws -> Bool {
        guard !id.isEmpty else { return true }
        return try liveWing(db, id: id) != nil
    }

    /// **What a wing still holds** (R-13id-2 — "Delete Wing refuses while the
    /// wing holds any live note, book or tag, NAMING what remains"). Counted
    /// exactly as the delete's own guard counts (ONE read, so the refusal's
    /// words and the act can never disagree).
    public struct WingContents: Equatable, Sendable {
        /// Live notes — ARCHIVED ones included (they are kept, not gone);
        /// saved VERSIONS excluded (a version's one home is its note's
        /// Versions listing — `versionHistoryPredicate` — and it moves and
        /// dies with its note).
        public let notes: Int
        /// Live books (`kind='book'`).
        public let books: Int
        /// Live gatherings (`kind='gathering'`).
        public let gatherings: Int
        /// Live tags.
        public let tags: Int
        /// 13i-e U2 (F-U1-8's copy rider): how many of `books` / `gatherings`
        /// are ARCHIVED — kept, counted above, but off the Bookcase, so the
        /// refusal that names them can say where they are. Never part of
        /// `isEmpty` (they are already inside the two counts).
        public let archivedBooks: Int
        public let archivedGatherings: Int

        public init(
            notes: Int, books: Int, gatherings: Int, tags: Int,
            archivedBooks: Int = 0, archivedGatherings: Int = 0
        ) {
            self.notes = notes
            self.books = books
            self.gatherings = gatherings
            self.tags = tags
            self.archivedBooks = archivedBooks
            self.archivedGatherings = archivedGatherings
        }

        public var isEmpty: Bool { notes == 0 && books == 0 && gatherings == 0 && tags == 0 }
    }

    /// The contents count of one wing (`''` = Home, which is never deleted,
    /// but answers honestly). Cost: four COUNTs over the wing's own rows —
    /// the container count is ∝ the wing's notes (no `wing_id` index exists;
    /// this is a deliberately-opened confirm's read, never a held one).
    public static func wingContents(_ db: Database, wingID: String) throws -> WingContents {
        let notes = wingScope(column: "c.wing_id", wingID: wingID)
        let readings = wingScope(column: "r.wing_id", wingID: wingID)
        let tags = wingScope(column: "t.wing_id", wingID: wingID)
        let noteCount = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND \(notes.sql)
                  AND NOT (\(versionHistoryPredicate(alias: "c", of: .anyLiveNote)))
                """,
            arguments: StatementArguments(notes.arguments)) ?? 0
        let readingRows = try Row.fetchAll(
            db,
            sql: """
                SELECT r.kind AS kind, COUNT(*) AS n,
                       SUM(r.archived_at IS NOT NULL) AS archived FROM reading r
                WHERE r.deleted_at IS NULL AND \(readings.sql)
                GROUP BY r.kind
                """,
            arguments: StatementArguments(readings.arguments))
        var books = 0
        var gatherings = 0
        var archivedBooks = 0
        var archivedGatherings = 0
        for row in readingRows {
            switch row["kind"] as String {
            case ReadingKind.gathering.rawValue:
                gatherings = row["n"]
                archivedGatherings = row["archived"] ?? 0
            default:
                books += row["n"] as Int
                archivedBooks += (row["archived"] as Int?) ?? 0
            }
        }
        let tagCount = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM tag t WHERE t.deleted_at IS NULL AND \(tags.sql)",
            arguments: StatementArguments(tags.arguments)) ?? 0
        return WingContents(
            notes: noteCount, books: books, gatherings: gatherings, tags: tagCount,
            archivedBooks: archivedBooks, archivedGatherings: archivedGatherings)
    }

    /// The wing a note lives in, as surfaces READ it — the stored id, or Home
    /// when that id dangles (the rule above). nil when the note is unknown.
    public static func effectiveWing(_ db: Database, ofPost postID: String) throws -> String? {
        guard let stored = try String.fetchOne(
            db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [postID])
        else { return nil }
        return try wingIsLive(db, id: stored) ? stored : ""
    }

    /// A wing's display name: Home for `''`, the row's name while it is live,
    /// nil otherwise (the lineage line and the move confirms speak this).
    public static func wingName(_ db: Database, id: String, home: String = "Home") throws -> String? {
        guard !id.isEmpty else { return home }
        return try liveWing(db, id: id)?.name
    }

    /// **THE LINEAGE DOOR ACROSS WINGS** (#166(e), RULED — "it can say it was
    /// in a different wing but I don't think we should have much more
    /// detailed linking than that … I don't want to encourage too much cross
    /// wing behavior"). A note's version peers (`versionPeerPosts` — the
    /// `version_of` link a cross-wing copy carries), SPLIT by wing: the peers
    /// in the note's OWN wing (a surface may offer them as notes), and the
    /// OTHER wings that hold one (a surface only NAMES those — no preview, no
    /// content across, no deep link). Wing ids as surfaces read them (a
    /// dangling pointer is Home's), distinct, Home first then by switcher
    /// order.
    public struct VersionPeerSplit: Equatable, Sendable {
        public let sameWing: [String]
        public let otherWings: [String]

        public init(sameWing: [String], otherWings: [String]) {
            self.sameWing = sameWing
            self.otherWings = otherWings
        }
    }

    public static func versionPeerSplit(_ db: Database, of postID: String) throws -> VersionPeerSplit {
        let mine = try effectiveWing(db, ofPost: postID) ?? ""
        var same: [String] = []
        var others: Set<String> = []
        for peer in try versionPeerPosts(db, of: postID) {
            let wing = try effectiveWing(db, ofPost: peer) ?? ""
            if wing == mine { same.append(peer) } else { others.insert(wing) }
        }
        let order = try wings(db).map(\.id)
        let sorted = others.sorted { a, b in
            if a.isEmpty != b.isEmpty { return a.isEmpty }
            return (order.firstIndex(of: a) ?? .max) < (order.firstIndex(of: b) ?? .max)
        }
        return VersionPeerSplit(sameWing: same, otherWings: sorted)
    }
}
