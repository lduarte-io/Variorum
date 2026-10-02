import Dependencies
import Foundation
import GRDB

// THE BOOK MOVE AND THE BULK WING MOVE (13i-d U5b — R-13id-6, the architect's
// ruling of the U5 RECORD's BOOK-MOVE PROPOSAL, every recommendation adopted;
// R-13id-4, her backdoor: "maybe build a 'move all wing contents to another
// wing' … if you regret separating them, you can delete them and move them
// back to home or whatever" — "by whatever i mean another wing of your
// choice").
//
// Both ops compose U5's ONE relocation (`relocateNote`, `Operations+WingMove`)
// over a book's members / a whole wing, and its ONE adoption (`adopt` — a
// carried tag resolves BY PATH in the destination, R-13ia-1's rider: the live
// same-path tag adopts, a missing path is minted). Each is ONE transaction —
// a refusal anywhere rolls the whole act back — and neither registers a
// structural-undo entry (item 8: "NO undo on either door — the symmetric door
// is the net", P-13ic-1's precedent). No intake fires in the destination: a
// wing move is not an applying act (the note move's row-copy letter,
// P-13id-U5-7; PROVISIONAL P-13id-U5b-1).
extension Operations {
    /// What a book move did — the receipt's facts.
    public struct BookWingMove: Equatable, Sendable {
        /// The member notes that came with the book (archived ones included).
        public let notes: Int
        /// Each stay-behind MEMBERSHIP the move severed — "“note” also leaves
        /// “book”" — in the confirm's order (`Queries.bookWingMovePreview`).
        public let alsoLeft: [Queries.AlsoLeaves]
        /// The book's own pending arrivals, dismissed in the move (item 5(a)).
        public let dismissedArrivals: Int
        public let adoptedTags: Int
        public let mintedTags: Int
    }

    /// **MOVE A BOOK (OR A GATHERING) TO ANOTHER WING** — R-13id-6 items 1–7,
    /// ONE transaction:
    ///
    /// - **Refuses** the daily Journal (item 7 — `dailyJournalIsHomeOnly`;
    ///   the designation OR the 'daily' marker), the wing it already lives in
    ///   (`readingAlreadyInWing`), a destination that is not live
    ///   (`wingNotFound`).
    /// - **Item 5(a) — its pending ARRIVALS are DISMISSED** (the waiting notes
    ///   are not members; they stay behind): the finish's own predicate
    ///   (`dismissPendingArrivals` — tombstoned decision rows; a FRESH act in
    ///   the book's new wing still re-poses a dismissed pair). The confirm's N
    ///   is `Queries.pendingArrivalCount`, the same rows.
    /// - **Items 1(a) + 4 — the book moves WITH its member notes**, archived
    ///   ones included (they stay archived): each relocates by the note
    ///   move's rules with this book KEPT, so a member's membership in a book
    ///   that STAYS behind is SEVERED (`movePostIntoReading`'s precedent — a
    ///   recoverable tombstone, listed in the confirm), and a stay-behind
    ///   MEMBER row in a FINISHED or SEALED book refuses the whole move
    ///   (item 3(a)'s own clause).
    /// - **Item 3(a) — the book itself moves WHOLE**: finished stays finished,
    ///   sealed stays sealed, every member's exact-stamp seal untouched (a wing
    ///   move is metadata, never authoring). Chapters, dismissal records and
    ///   the owned flag ride (no wing of their own).
    /// - **Item 2(a) — its rule's tag terms, its outflow and its grouping tag
    ///   ADOPT BY PATH**, a missing path MINTED in the destination, so the rule
    ///   keeps its meaning (a gathering shows the destination's matches the
    ///   moment it lands). Only LIVE tags of the source wing re-point; a dead
    ///   term stays dead (PROVISIONAL P-13id-U5b-10).
    /// - **Item 6 — it lands UNSHELVED** (`shelf_id`, `shelf_position`
    ///   cleared — shelves are per-wing and never cross); its star stays.
    @discardableResult
    public func moveReadingToWing(_ readingID: String, to wingID: String) throws -> BookWingMove {
        try database.write { db in
            var reading = try liveReading(db, readingID)
            if try Queries.isTheDailyJournal(db, reading) {
                throw OperationError.dailyJournalIsHomeOnly(id: readingID)
            }
            try requireLiveWing(db, wingID)
            guard try !sameEffectiveWing(db, reading.wingId, wingID) else {
                throw OperationError.readingAlreadyInWing(readingID: readingID, wingID: wingID)
            }
            let now = date.now
            let sourceWing = reading.wingId

            // Item 5(a): the waiting notes stay behind — their rows decided.
            let waiting = try Queries.pendingArrivalCount(db, readingID: readingID)
            if waiting > 0 {
                try dismissPendingArrivals(db, readingID: readingID, now: now)
            }

            // Items 1(a) + 4: the members come along, each by the note move.
            var adoption = TagAdoption(wing: wingID)
            var alsoLeft: [Queries.AlsoLeaves] = []
            let members = try Queries.bookMoveMembers(db, readingID: readingID)
            for member in members {
                let severed = try relocateNote(
                    db, postID: member.postID, to: wingID, keeping: [readingID],
                    adoption: &adoption, now: now)
                alsoLeft += severed.map {
                    Queries.AlsoLeaves(noteID: member.postID, note: member.title, book: $0.name)
                }
            }

            // Item 2(a): the rule, the outflow, the grouping — by path.
            try adoptReadingTags(db, &reading, sourceWing: sourceWing, adoption: &adoption)

            // Items 3(a) + 6: the book itself, whole, unshelved.
            reading.wingId = wingID
            reading.shelfId = nil
            reading.shelfPosition = nil
            reading.updatedAt = now
            try reading.update(db)
            return BookWingMove(
                notes: members.count, alsoLeft: alsoLeft, dismissedArrivals: waiting,
                adoptedTags: adoption.adopted, mintedTags: adoption.minted)
        }
    }

    /// What the bulk move did — the receipt's facts.
    public struct WingContentsMove: Equatable, Sendable {
        /// What moved, counted as `Queries.wingContents` counts it (notes
        /// exclude saved versions, which ride their notes).
        public let moved: Queries.WingContents
        /// The source wing's tags the act retired (every one of them).
        public let tagsRetired: Int
        public let adoptedTags: Int
        public let mintedTags: Int
    }

    /// **MOVE EVERYTHING TO ANOTHER WING** — her R-13id-4 backdoor, built to
    /// R-13id-6 item 8 and the kickoff sketch. ONE transaction:
    ///
    /// - **Refuses** Home or a dead wing as the SOURCE (`wingNotFound` — the
    ///   door lives on ADDITIONAL wings only; Home is virtual and holds the
    ///   daily Journal, so the road around item 7's guard is impossible by
    ///   construction — and a belt: a daily-marked book among the movers
    ///   refuses unless the destination is Home, P-13id-U5b-11), a dead
    ///   destination, the source itself (`wingMoveIntoItself`).
    /// - **Every live note of the wing** (archived included; saved versions
    ///   ride their notes) relocates with EVERY reading of the wing kept — so
    ///   memberships, waiting arrivals and dismissal records ride untouched
    ///   (the waiting notes move with everything, item 5).
    /// - **Every live reading** — books and gatherings, finished and sealed
    ///   ones whole (item 3(a)) — adopts its rule/outflow/grouping by path and
    ///   lands UNSHELVED (item 6; the source's shelves stay for the wing
    ///   delete's stamp).
    /// - **Every remaining live application of the wing's tags** re-points by
    ///   path (`repointStrayApplications` — P-13id-U5b-7).
    /// - **Every live tag of the wing is then TOMBSTONED** — each is left with
    ///   no live application — so the wing ends GENUINELY EMPTY and Delete
    ///   Wing succeeds. Said in the confirm (`WingTagCarry`'s buckets).
    /// - **The wing's TRASH rows stay** (item 8(a)): they list in Home's Trash
    ///   once the wing is deleted, and a Put back re-homes them — reviving a
    ///   membership only within one wing (F-U5b-1).
    /// - **Book names that collide** in the destination proceed (item 8(a) —
    ///   no op refuses for a name, E13's letter); the confirm names them.
    @discardableResult
    public func moveWingContents(from sourceID: String, to wingID: String) throws -> WingContentsMove {
        try database.write { db in
            _ = try liveWingRow(db, sourceID)
            try requireLiveWing(db, wingID)
            guard try !sameEffectiveWing(db, sourceID, wingID) else {
                throw OperationError.wingMoveIntoItself(wingID: sourceID)
            }
            let moved = try Queries.wingContents(db, wingID: sourceID)
            let readings = try Reading.fetchAll(
                db,
                sql: "SELECT * FROM reading WHERE wing_id = ? AND deleted_at IS NULL ORDER BY name, id",
                arguments: [sourceID])
            // The belt (P-13id-U5b-11): the daily Journal never leaves Home —
            // were one ever found here, it may only go home.
            if !wingID.isEmpty {
                for reading in readings where try Queries.isTheDailyJournal(db, reading) {
                    throw OperationError.dailyJournalIsHomeOnly(id: reading.id)
                }
            }
            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            var adoption = TagAdoption(wing: wingID)
            let keeping = Set(readings.map(\.id))

            // The notes — each by the note move, every book of the wing kept.
            for postID in try Queries.wingMoveNoteIDs(db, wingID: sourceID) {
                _ = try relocateNote(
                    db, postID: postID, to: wingID, keeping: keeping,
                    adoption: &adoption, now: now)
            }
            // Anything the loop could not reach (a saved version whose note
            // is not a live note of the wing) still leaves: the wing ends
            // empty of live notes by construction.
            try db.execute(
                sql: """
                    UPDATE container SET wing_id = ?, updated_at = ?
                    WHERE kind = 'post' AND deleted_at IS NULL AND wing_id = ?
                    """,
                arguments: [wingID, stamp, sourceID])

            // The readings — whole, by path, unshelved.
            for var reading in readings {
                try adoptReadingTags(db, &reading, sourceWing: sourceID, adoption: &adoption)
                reading.wingId = wingID
                reading.shelfId = nil
                reading.shelfPosition = nil
                reading.updatedAt = now
                try reading.update(db)
            }

            // The strays, then the wing's whole vocabulary retires.
            try repointStrayApplications(db, ofWing: sourceID, adoption: &adoption, now: now)
            let retired = try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM tag WHERE wing_id = ? AND deleted_at IS NULL",
                arguments: [sourceID]) ?? 0
            try db.execute(
                sql: """
                    UPDATE tag SET deleted_at = ?, updated_at = ?
                    WHERE wing_id = ? AND deleted_at IS NULL
                    """,
                arguments: [stamp, stamp, sourceID])
            return WingContentsMove(
                moved: moved, tagsRetired: retired,
                adoptedTags: adoption.adopted, mintedTags: adoption.minted)
        }
    }

    // MARK: - Internals

    /// Item 2(a): a reading's rule terms, outflow ids and grouping tag
    /// re-point BY PATH into the adoption's wing — only where they name a LIVE
    /// tag of `sourceWing` (as surfaces read it); a dead or foreign id stays
    /// exactly as it was (a dead term matches nothing in any wing). Each
    /// column is rewritten only when an id actually changed, so an untouched
    /// rule keeps its stored bytes.
    func adoptReadingTags(
        _ db: Database, _ reading: inout Reading, sourceWing: String,
        adoption: inout TagAdoption
    ) throws {
        var resolved: [String: String] = [:]
        func resolve(_ id: String) throws -> String {
            if let known = resolved[id] { return known }
            guard !id.isEmpty, let tag = try Tag.fetchOne(db, key: id), tag.deletedAt == nil,
                  try sameEffectiveWing(db, tag.wingId, sourceWing)
            else {
                resolved[id] = id
                return id
            }
            let target = try adopt(db, tag, &adoption).id
            resolved[id] = target
            return target
        }
        if case .rule(let term) = RuleGrammar.read(reading.querySpec) {
            let mapped = try RuleGrammar.mapTagIDs(term, resolve)
            if mapped != term { reading.querySpec = try RuleGrammar.encode(mapped) }
        }
        let outflow = reading.autoTagIDs
        if !outflow.isEmpty {
            let mapped = try outflow.map(resolve)
            if mapped != outflow { reading.autoTagIds = Reading.encodeOutflow(mapped) }
        }
        if let grouping = reading.groupingTagId {
            let mapped = try resolve(grouping)
            if mapped != grouping { reading.groupingTagId = mapped }
        }
    }
}

extension Queries {
    /// One severed stay-behind membership, as the confirm and the receipt
    /// name it: "“note” also leaves “book”".
    public struct AlsoLeaves: Equatable, Sendable {
        /// The note's id — the confirm groups a note's books by IDENTITY,
        /// never by its display name (13i-d U5b walk W-1: untitled notes are
        /// named by their day, so three different notes can all read
        /// "2026-10-01").
        public let noteID: String
        public let note: String
        public let book: String

        public init(noteID: String, note: String, book: String) {
            self.noteID = noteID
            self.note = note
            self.book = book
        }
    }

    /// A member a book move carries: its id and its display name
    /// (`DisplayTitle.note` — the one naming rule).
    struct BookMoveMember {
        let postID: String
        let title: String
        let archived: Bool
    }

    /// **THE BOOK MOVE'S MEMBERS** — the act's own read (and the confirm's):
    /// the book's live MEMBER rows whose note is live, archived ones included
    /// (item 4), in the book's order `(position, id)`.
    static func bookMoveMembers(_ db: Database, readingID: String) throws -> [BookMoveMember] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at, c.archived_at IS NOT NULL AS archived
                FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.position, rp.id
                """,
            arguments: [readingID]
        ).map { row in
            BookMoveMember(
                postID: row["id"],
                title: DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"],
                    createdAt: row["created_at"]),
                archived: row["archived"])
        }
    }

    /// **THE BULK MOVE'S NOTES** — every live note of the wing that is not a
    /// saved version (versions ride their notes), oldest first.
    static func wingMoveNoteIDs(_ db: Database, wingID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT c.id FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.wing_id = ?
                  AND NOT (\(versionHistoryPredicate(alias: "c", of: .anyLiveNote)))
                ORDER BY c.created_at, c.id
                """,
            arguments: [wingID])
    }

    /// **Is this THE daily Journal?** — the designation OR the 'daily' marker
    /// (13i-a M-3 moves the marker with the designation, so the two agree;
    /// both are read so neither can slip past item 7's guard).
    public static func isTheDailyJournal(_ db: Database, _ reading: Reading) throws -> Bool {
        if isDailyJournalMintShape(reading) { return true }
        return try dailyJournalBookID(db) == reading.id
    }

    /// **What a book move would do — its confirm's read** (each field the
    /// act's own predicate, so the confirm and the act agree by
    /// construction).
    public struct BookWingMovePreview: Equatable, Sendable {
        /// The notes that come with it, archived ones included…
        public let notes: Int
        /// …of which this many are archived (they stay archived).
        public let archived: Int
        /// Each stay-behind membership the move would sever, members in the
        /// book's order, each one's books earliest first.
        public let alsoLeaves: [AlsoLeaves]
        /// The first stay-behind membership in a FINISHED or SEALED book — the
        /// one the act would refuse on (the door refuses naming it, P-2).
        public let frozen: AlsoLeaves?
        /// Its pending arrivals, which the move dismisses (item 5(a)).
        public let waiting: Int
        /// A live book or gathering in the destination already wearing this
        /// name (E13's key) — named, never refused (item 8(a)'s letter).
        public let nameTakenBy: String?
        /// The daily Journal never moves (item 7) — the door is not drawn.
        public let isDailyJournal: Bool
    }

    public static func bookWingMovePreview(
        _ db: Database, readingID: String, to wingID: String
    ) throws -> BookWingMovePreview? {
        guard let reading = try Queries.reading(db, id: readingID) else { return nil }
        let members = try bookMoveMembers(db, readingID: readingID)
        var alsoLeaves: [AlsoLeaves] = []
        var frozen: AlsoLeaves?
        for member in members {
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT r.name AS name, r.locked AS locked, r.sealed_at AS sealed
                    FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                      AND rp.reading_id <> ?
                    ORDER BY rp.created_at, rp.id
                    """,
                arguments: [member.postID, readingID])
            for row in rows {
                let leaves = AlsoLeaves(noteID: member.postID, note: member.title, book: row["name"])
                alsoLeaves.append(leaves)
                let locked = (row["locked"] as Int?) == 1
                let sealed = (row["sealed"] as String?) != nil
                if frozen == nil, locked || sealed { frozen = leaves }
            }
        }
        let key = BookNaming.key(reading.name)
        let scope = wingScope(column: "wing_id", wingID: wingID)
        let destinationNames = try String.fetchAll(
            db,
            sql: "SELECT name FROM reading WHERE deleted_at IS NULL AND id <> ? AND \(scope.sql)",
            arguments: StatementArguments([readingID] + scope.arguments))
        return BookWingMovePreview(
            notes: members.count,
            archived: members.filter(\.archived).count,
            alsoLeaves: alsoLeaves,
            frozen: frozen,
            waiting: try pendingArrivalCount(db, readingID: readingID),
            nameTakenBy: destinationNames.first { BookNaming.key($0) == key },
            isDailyJournal: try isTheDailyJournal(db, reading))
    }

    /// **What the bulk move would do — its confirm's read.**
    public struct WingContentsMovePreview: Equatable, Sendable {
        /// What moves — and the wing's tags, every one retired by the act.
        public let contents: WingContents
        /// What becomes of each source tag's NAME (joins · made · let go),
        /// and every path the act will mint (`WingTagCarry`).
        public let tags: WingTagCarry.Plan
        /// The moving books and gatherings whose names the destination
        /// already wears (E13's key), A–Z — named, never refused.
        public let nameCollisions: [String]
    }

    public static func wingContentsMovePreview(
        _ db: Database, from sourceID: String, to wingID: String
    ) throws -> WingContentsMovePreview {
        let contents = try wingContents(db, wingID: sourceID)
        let sourcePaths = try String.fetchAll(
            db, sql: "SELECT path FROM tag WHERE wing_id = ? AND deleted_at IS NULL",
            arguments: [sourceID])
        let destinationScope = wingScope(column: "wing_id", wingID: wingID)
        let destinationPaths = Set(try String.fetchAll(
            db,
            sql: "SELECT path FROM tag WHERE deleted_at IS NULL AND wing_id = ?",
            arguments: [wingID]))
        // Carried: (a) every live tag a moving note or its placed blocks
        // wear (any wing — the relocation re-points them all); (b) every live
        // tag of the wing with ANY live application (the strays); (c) every
        // live tag of the wing a moving reading's rule, outflow or grouping
        // names.
        let noteIDs = try wingMoveNoteIDs(db, wingID: sourceID)
        var carried: Set<String> = []
        for postID in noteIDs {
            carried.formUnion(try String.fetchAll(
                db,
                sql: """
                    SELECT t.path FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                    UNION
                    SELECT t.path FROM container_block cb
                    JOIN block_tag bt ON bt.block_id = cb.block_id AND bt.deleted_at IS NULL
                    JOIN tag t ON t.id = bt.tag_id AND t.deleted_at IS NULL
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                    """,
                arguments: [postID, postID]))
        }
        carried.formUnion(try String.fetchAll(
            db,
            sql: """
                SELECT t.path FROM tag t
                WHERE t.wing_id = ? AND t.deleted_at IS NULL
                  AND (EXISTS (SELECT 1 FROM post_tag pt WHERE pt.tag_id = t.id AND pt.deleted_at IS NULL)
                    OR EXISTS (SELECT 1 FROM block_tag bt WHERE bt.tag_id = t.id AND bt.deleted_at IS NULL))
                """,
            arguments: [sourceID]))
        let readings = try Reading.fetchAll(
            db, sql: "SELECT * FROM reading WHERE wing_id = ? AND deleted_at IS NULL",
            arguments: [sourceID])
        var named: Set<String> = []
        for reading in readings {
            named.formUnion(RuleGrammar.tagIDs(of: RuleGrammar.decode(reading.querySpec)))
            named.formUnion(reading.autoTagIDs)
            if let grouping = reading.groupingTagId { named.insert(grouping) }
        }
        for id in named.sorted() {
            if let tag = try Tag.fetchOne(db, key: id), tag.deletedAt == nil,
               tag.wingId == sourceID {
                carried.insert(tag.path)
            }
        }
        var collisions: [String] = []
        let destinationNames = try String.fetchAll(
            db,
            sql: "SELECT name FROM reading WHERE deleted_at IS NULL AND \(destinationScope.sql)",
            arguments: StatementArguments(destinationScope.arguments))
        let destinationKeys = Set(destinationNames.map(BookNaming.key))
        for reading in readings where destinationKeys.contains(BookNaming.key(reading.name)) {
            if !collisions.contains(reading.name) { collisions.append(reading.name) }
        }
        return WingContentsMovePreview(
            contents: contents,
            tags: WingTagCarry.plan(
                sourcePaths: sourcePaths, carriedPaths: carried,
                destinationPaths: destinationPaths),
            nameCollisions: collisions.sorted { BookNaming.key($0) < BookNaming.key($1) })
    }
}
