import Dependencies
import Foundation
import GRDB

// INTAKE — the living book's mechanics (13i-b U1; the sitting record §4,
// §14.1–6, §19, §24; the 13i-b plan §2). One pure decision
// (`Domain/IntakeDecision`), event hooks here, and materialization in the
// SAME transaction as the act that fires it.
//
// What fires intake (and nothing else does):
// - an APPLYING act: a tag applied to a note (`insertPostTag` — the one road
//   every door's application takes: `applyTag(toPost:)`, the gathering's
//   collect door, auto-tag, `tagAllMembers`), or a note STARRED;
// - a book's BIRTH with a rule, or a rule set on a rule-less book
//   (BACKFILL — seats directly);
// - a book RESUMING — restored, un-finished, its rule edited (CATCH-UP —
//   through Arrivals).
// Un-tagging and un-starring are NON-EVENTS (§19, ratified §24): rows are
// truth, intake never evicts. Intake only ever INSERTS.
//
// Cost (P1): an act walks the live, unfinished BOOKS that carry a rule in
// the note's wing — reading rows are author-scale metadata — and probes the
// one note per candidate; a backfill/catch-up enumerates the rule's current
// matches exactly as a gathering's assembly does. Never a corpus walk per
// keystroke: no text edit fires intake.
//
// Sync (zero `Sync/` lines, the plan §2.7): every write is an ordinary row
// through this layer (S1). Two devices reacting to one act converge through
// the shipped status-aware pair dedupe (SyncSpec §7, R1); a dismissal racing
// a seat is the documented tombstones-win coexistence.
extension Operations {
    // MARK: - The applying act

    /// Inserts a live application of `tagID` to `postID` and fires intake
    /// for it — the ONE `post_tag` insert road, so no door can apply a tag
    /// without the act being heard. The caller has already proved the tag
    /// and the post live and the application absent.
    @discardableResult
    func insertPostTag(
        _ db: Database, tagID: String, postID: String, now: Date
    ) throws -> PostTag {
        let application = PostTag(id: newID(), tagId: tagID, postId: postID, createdAt: now)
        try application.insert(db)
        try intakeAfterTagging(db, postID: postID, appliedTagID: tagID, now: now)
        return application
    }

    /// The tagging EVENT: every living book whose rule references the
    /// applied tag's subtree — a term at-or-above the applied tag, the
    /// subtree-matching rule (§19) — hears it, and decides by its rule.
    func intakeAfterTagging(
        _ db: Database, postID: String, appliedTagID: String, now: Date
    ) throws {
        guard let post = try Container.fetchOne(db, key: postID),
              post.deletedAt == nil, post.kind == .post
        else { return }
        var starred: [String]?
        for (book, term) in try livingBooks(db, wingID: post.wingId) {
            guard try appliedTag(db, appliedTagID, fallsUnderAnyOf: RuleGrammar.tagIDs(of: term))
            else { continue }
            if starred == nil { starred = try Queries.starredNoteIDs(db) }
            try intakeEvent(db, book: book, term: term, postID: postID,
                            starredNoteIDs: starred ?? [], now: now)
        }
    }

    /// The starring EVENT: every living book whose rule carries a star term
    /// hears it (the plan §2.2's "or any star term").
    func intakeAfterStarring(_ db: Database, postID: String, now: Date) throws {
        guard let post = try Container.fetchOne(db, key: postID),
              post.deletedAt == nil, post.kind == .post
        else { return }
        let books = try livingBooks(db, wingID: post.wingId)
            .filter { RuleGrammar.referencesStar($0.term) }
        guard !books.isEmpty else { return }
        let starred = try Queries.starredNoteIDs(db)
        for (book, term) in books {
            try intakeEvent(db, book: book, term: term, postID: postID,
                            starredNoteIDs: starred, now: now)
        }
    }

    /// One pair, one event, through the table.
    private func intakeEvent(
        _ db: Database, book: Reading, term: RuleTerm, postID: String,
        starredNoteIDs: [String], now: Date
    ) throws {
        let facts = try intakeBookFacts(db, book)
        guard IntakeDecision.intakeRuns(facts) else { return }
        let matches = try matchesRule(
            db, postID: postID, term: term, wingID: book.wingId,
            starredNoteIDs: starredNoteIDs)
        guard matches else { return }
        let elsewhere = try membershipElsewhere(db, postID: postID, readingID: book.id)
        let note = IntakeDecision.NoteFacts(
            matchesRule: true,
            pair: try intakePairState(db, readingID: book.id, postID: postID),
            memberedElsewhere: elsewhere.membered,
            ownedElsewhere: elsewhere.owned)
        try materializeIntake(
            db, readingID: book.id, postID: postID,
            verdict: IntakeDecision.verdict(book: facts, note: note, occasion: .event),
            now: now)
    }

    // MARK: - Backfill and catch-up (the plan §2.3)

    /// Runs the book's rule over its CURRENT matches that have no pair row
    /// of any kind (tombstone-means-decided: a removed member, a dismissal,
    /// a seat or a bell all stand), and decides each with `occasion` —
    /// BACKFILL seats (birth = intent), CATCH-UP bells (gap = judgment).
    /// Matches seat in creation order (the gathering's own manual-fallback
    /// order, so a book born from a gathering's rule reads as it did).
    /// No-op unless the book's intake runs (P-13ib-5).
    func intakeSweep(
        _ db: Database, book: Reading, occasion: IntakeDecision.Occasion, now: Date
    ) throws {
        guard case .rule(let term) = RuleGrammar.read(book.querySpec) else { return }
        var facts = try intakeBookFacts(db, book)
        guard IntakeDecision.intakeRuns(facts) else { return }
        let match = Queries.ruleMatchSQL(
            term, wingID: book.wingId, starredNoteIDs: try Queries.starredNoteIDs(db))
        let conditions = [
            "c.deleted_at IS NULL", "c.archived_at IS NULL", "c.kind = 'post'",
        ] + match.conditions + [
            "NOT EXISTS (SELECT 1 FROM reading_post rp WHERE rp.reading_id = ? AND rp.post_id = c.id)",
        ]
        let postIDs = try String.fetchAll(
            db,
            sql: "SELECT c.id FROM container c WHERE "
                + conditions.joined(separator: " AND ")
                + " ORDER BY c.created_at, c.id",
            arguments: StatementArguments(match.arguments + [book.id]))
        for postID in postIDs {
            let elsewhere = try membershipElsewhere(db, postID: postID, readingID: book.id)
            let verdict = IntakeDecision.verdict(
                book: facts,
                note: IntakeDecision.NoteFacts(
                    matchesRule: true, pair: .fresh,
                    memberedElsewhere: elsewhere.membered,
                    ownedElsewhere: elsewhere.owned),
                occasion: occasion)
            try materializeIntake(
                db, readingID: book.id, postID: postID, verdict: verdict, now: now)
            if verdict == .seat { facts.memberCount += 1 }
        }
    }

    // MARK: - Materialization

    /// Inserts the verdict's row: a member or an arrival, at the END of the
    /// book's list, unsectioned (§4, §14.2 — the unsectioned bin already
    /// renders last). Insert-only by construction.
    private func materializeIntake(
        _ db: Database, readingID: String, postID: String,
        verdict: IntakeDecision.Verdict, now: Date
    ) throws {
        let status: MembershipStatus
        switch verdict {
        case .nothing: return
        case .seat: status = .member
        case .arrival: status = .arrival
        }
        try ReadingPost(
            id: newID(), readingId: readingID, postId: postID,
            position: try readingPosition(db, readingID: readingID, at: .end),
            status: status, createdAt: now
        ).insert(db)
    }

    // MARK: - The facts the table reads

    /// The live, unfinished, UNARCHIVED BOOKS with a READABLE rule in one
    /// wing — the candidates any act can reach (a gathering never
    /// materializes; a malformed rule runs nothing; an archived book's
    /// auto-ingestion is paused — 13i-e, R-13ie-4, the same truth
    /// `IntakeDecision.intakeRuns` states, filtered here as the cheap
    /// pre-filter). Ordered by id so a multi-book act writes
    /// deterministically.
    private func livingBooks(
        _ db: Database, wingID: String
    ) throws -> [(book: Reading, term: RuleTerm)] {
        try Reading.fetchAll(
            db,
            sql: """
                SELECT * FROM reading
                WHERE deleted_at IS NULL AND kind = 'book' AND locked = 0
                  AND archived_at IS NULL
                  AND query_spec IS NOT NULL AND wing_id = ?
                ORDER BY id
                """,
            arguments: [wingID]
        ).compactMap { book in
            guard case .rule(let term) = RuleGrammar.read(book.querySpec) else { return nil }
            return (book, term)
        }
    }

    /// Is the applied tag at-or-under any of the rule's referenced tags —
    /// the subtree rule, wing-scoped exactly as `ruleSQL` is?
    private func appliedTag(
        _ db: Database, _ appliedTagID: String, fallsUnderAnyOf roots: Set<String>
    ) throws -> Bool {
        guard !roots.isEmpty else { return false }
        let ids = Array(roots).sorted()
        let marks = Array(repeating: "?", count: ids.count).joined(separator: ",")
        var arguments: [(any DatabaseValueConvertible)?] = [appliedTagID]
        arguments += ids
        return try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM tag root
                  JOIN tag applied ON applied.id = ? AND applied.deleted_at IS NULL
                 WHERE root.id IN (\(marks)) AND root.deleted_at IS NULL
                   AND applied.wing_id = root.wing_id
                   AND (applied.path = root.path
                        OR substr(applied.path, 1, length(root.path) + 1) = root.path || '/'))
                """,
            arguments: StatementArguments(arguments)) ?? false
    }

    func intakeBookFacts(_ db: Database, _ book: Reading) throws -> IntakeDecision.BookFacts {
        let rule: IntakeDecision.RuleState = switch RuleGrammar.read(book.querySpec) {
        case .none: .none
        case .malformed: .malformed
        case .rule: .readable
        }
        return IntakeDecision.BookFacts(
            isLive: book.deletedAt == nil,
            isBook: book.kind == .book,
            rule: rule,
            locked: book.locked,
            seating: book.intakeSeating,
            maxPosts: book.maxPosts,
            memberCount: try liveMemberCount(db, readingID: book.id),
            owned: book.owned,
            archived: book.archivedAt != nil)
    }

    /// Live `status='member'` rows — THE count capacity reads (arrivals are
    /// never counted, §14.3).
    func liveMemberCount(_ db: Database, readingID: String) throws -> Int {
        try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                """,
            arguments: [readingID]) ?? 0
    }

    /// The pair's decision record, read whole (tombstones included).
    func intakePairState(
        _ db: Database, readingID: String, postID: String
    ) throws -> IntakeDecision.PairState {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) AS total,
                       COALESCE(SUM(deleted_at IS NULL), 0) AS live,
                       COALESCE(SUM(deleted_at IS NOT NULL AND status = 'member'), 0) AS left
                FROM reading_post WHERE reading_id = ? AND post_id = ?
                """,
            arguments: [readingID, postID])
        else { return .fresh }
        let total: Int = row["total"]
        let live: Int = row["live"]
        let left: Int = row["left"]
        if live > 0 { return .live }
        if left > 0 { return .leftAsMember }
        return total > 0 ? .dismissed : .fresh
    }

    /// Is the note a MEMBER of some other live BOOK — and of an OWNED one?
    /// (§6's two ownership facts; `idx_reading_post_post` keeps it per-note.)
    /// 13i-c U2 (13i-b ladder F-R1-7, one of the three readers ruled
    /// together): only a BOOK's row is membership — a sync-stray member row
    /// on a gathering is never "a second place it lives" (a gathering holds
    /// nothing, the sitting record §1), so it can never make an owned book
    /// bell a free note.
    func membershipElsewhere(
        _ db: Database, postID: String, readingID: String
    ) throws -> (membered: Bool, owned: Bool) {
        let row = try Row.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) AS membered, COALESCE(SUM(r.owned), 0) AS owned
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                 AND r.kind = 'book'
                WHERE rp.post_id = ? AND rp.reading_id <> ?
                  AND rp.deleted_at IS NULL AND rp.status = 'member'
                """,
            arguments: [postID, readingID])
        let membered: Int = row?["membered"] ?? 0
        let owned: Int = row?["owned"] ?? 0
        return (membered > 0, owned > 0)
    }

    // MARK: - AUTO-TAG (the outflow, the plan §2.6)

    /// A note MINTED inside the book, or ADDED to it by hand (P-13ib-1),
    /// wears the book's OUTFLOW — EVERY tag of the set (13i-c, R-13ic-1: her
    /// "my writing, poetry, and horror … that's still two tags") — in the
    /// caller's transaction, each through the one application road, so each
    /// tagging act fires intake on OTHER books (this book's own pair is
    /// already decided). Silent per tag when there is nothing to do: a
    /// DANGLING id (a deleted tag — the read-time fallback class), a tag of
    /// another wing (unreachable — the belt), or a note already wearing it.
    func applyAutoTag(_ db: Database, book: Reading, postID: String, now: Date) throws {
        let outflow = book.autoTagIDs
        guard !outflow.isEmpty,
              let post = try Container.fetchOne(db, key: postID), post.deletedAt == nil
        else { return }
        for tagID in outflow {
            guard let tag = try Tag.fetchOne(db, key: tagID), tag.deletedAt == nil,
                  post.wingId == tag.wingId,
                  try liveApplication(db, table: "post_tag", tagID: tagID,
                                      targetColumn: "post_id", targetID: postID) == nil
            else { continue }
            try insertPostTag(db, tagID: tagID, postID: postID, now: now)
        }
    }

    /// **"Also tag the N current members now"** (the sitting record §4,
    /// ruled; also its bulk door, "apply a tag to every member"): applies
    /// `tagID` — nil means EVERY tag of the book's OUTFLOW (13i-c,
    /// PROVISIONAL P-13ic-11) — to every live MEMBER not already wearing it,
    /// in ONE transaction (one receipt at the door), each application
    /// through the one road (so each fires intake on other books). Arrivals
    /// are not members and are not tagged. Returns how many NOTES newly wear
    /// at least one of the tags (the receipt's number). A finished book is
    /// allowed — finishing freezes the assembly, never the notes' tags.
    @discardableResult
    public func tagAllMembers(_ readingID: String, tagID: String? = nil) throws -> Int {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            let tagIDs = tagID.map { [$0] } ?? reading.autoTagIDs
            guard !tagIDs.isEmpty else {
                throw OperationError.readingHasNoAutoTag(id: readingID)
            }
            let now = date.now
            var touched: Set<String> = []
            for tagID in tagIDs {
                let tag = try liveTag(db, tagID)
                guard tag.wingId == reading.wingId else {
                    throw OperationError.tagNotFound(id: tagID)
                }
                let postIDs = try String.fetchAll(
                    db,
                    sql: """
                        SELECT rp.post_id FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                         AND c.kind = 'post' AND c.wing_id = ?
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                          AND NOT EXISTS (SELECT 1 FROM post_tag pt
                                          WHERE pt.post_id = rp.post_id AND pt.tag_id = ?
                                            AND pt.deleted_at IS NULL)
                        ORDER BY rp.position, rp.id
                        """,
                    arguments: [tag.wingId, readingID, tagID])
                for postID in postIDs {
                    try insertPostTag(db, tagID: tagID, postID: postID, now: now)
                    touched.insert(postID)
                }
            }
            return touched.count
        }
    }

    // MARK: - The book's two Collecting settings (faces: U3; the sentences: 13i-d)

    /// The JOIN DIAL (§4): new matches join quietly at the end (`.auto`, and
    /// nil — P-13ib-5) or wait at Arrivals (`.arrivals`). Books only (a
    /// gathering has no membership to seat). Identity-level metadata:
    /// no-op-guarded. Changing it never moves a row already decided — the
    /// arrivals already waiting keep waiting for judgment.
    public func setReadingIntakeSeating(_ id: String, _ seating: IntakeSeating?) throws {
        try database.write { db in
            try writeReadingIntakeSeating(db, id, seating)
        }
    }

    /// The row work, inside a caller's transaction (13n-b U4 — the MCP
    /// book-rule act; byte-identical behaviour).
    func writeReadingIntakeSeating(_ db: Database, _ id: String, _ seating: IntakeSeating?) throws {
        do {
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            guard reading.intakeSeating != seating else { return }
            reading.intakeSeating = seating
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// THE OUTFLOW (§4; 13i-c R-13ic-1 — a CHOSEN, OPTIONAL SET, independent
    /// of the intake rule): the tags notes written here wear. Every id a
    /// live tag of the book's own wing (another wing's tag does not exist
    /// from here — §9's total isolation; `tagNotFound`); de-duplicated,
    /// ORDER PRESERVED (the chooser's order is hers); `[]` clears to NULL.
    /// Books only. No-op-guarded on the decoded set. Setting it tags
    /// NOTHING by itself — the "also tag the N current members" offer is
    /// `tagAllMembers`; clearing it never untags (ruled).
    public func setReadingOutflow(_ id: String, tagIDs: [String]) throws {
        try database.write { db in
            try writeReadingOutflow(db, id, tagIDs: tagIDs)
        }
    }

    /// The row work, inside a caller's transaction (13n-b U4 — the MCP
    /// book-rule act; byte-identical behaviour).
    func writeReadingOutflow(_ db: Database, _ id: String, tagIDs: [String]) throws {
        do {
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            for tagID in tagIDs {
                let tag = try liveTag(db, tagID)
                guard tag.wingId == reading.wingId else {
                    throw OperationError.tagNotFound(id: tagID)
                }
            }
            let encoded = Reading.encodeOutflow(tagIDs)
            guard reading.autoTagIds != encoded else { return }
            reading.autoTagIds = encoded
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    // (13i-c U3: `setReadingAutoTag` — the 13i-b single-tag setter, kept by
    // U1 as a FORWARDER onto the set so the 13i-b rule-editor row rode until
    // its rebuild — RETIRED with that row (F-U1-1): the rule editor writes
    // the outflow chooser's whole set through `setReadingOutflow`, and no
    // door names a single tag any more.)

    // MARK: - The judgment ops (the plan §2.5)

    /// **Add** — seat a waiting arrival: the SAME row flips to
    /// `status='member'`, positioned at the END, unsectioned (§4). Refuses
    /// when the row is not a live arrival (`arrivalNotFound`), the book is
    /// gone (`readingNotFound`) or finished (`lockedReading` — a sealed
    /// book is finished too), the note is gone, or the book is at capacity
    /// (`readingAtCapacity` — the bell keeps ringing). No auto-tag: an
    /// arrival came through the rule (intake's own seats never tag either —
    /// PROVISIONAL P-13ib-U1-3).
    ///
    /// 13i-c U2 (the plan §4 row 2): the seat CONSULTS OWNERSHIP after the
    /// capacity gate, exactly as a hand-add does — an owned book's bell for a
    /// note that lives elsewhere refuses `noteMemberedElsewhere` (the face
    /// offers Copy in / Move in / Dismiss — `copyPostIntoReading(answering:)`,
    /// `movePostIntoReading(answering:)`, `dismissArrival`), and a plain
    /// book's bell for a note an owned book holds refuses `noteOwnedElsewhere`
    /// (Copy in / Dismiss). The arrival stands untouched either way.
    @discardableResult
    public func seatArrival(_ pairID: String) throws -> ReadingPost {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: pairID),
                  row.deletedAt == nil, row.status == .arrival
            else { throw OperationError.arrivalNotFound(id: pairID) }
            let reading = try liveReading(db, row.readingId)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: reading.id, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: reading.id)
            }
            try requireSameWing(db, post: try livePost(db, row.postId), book: reading)
            if let cap = reading.maxPosts,
               try liveMemberCount(db, readingID: reading.id) >= cap {
                throw OperationError.readingAtCapacity(id: reading.id)
            }
            try consultOwnership(db, book: reading, postID: row.postId)
            row.position = try readingPosition(db, readingID: reading.id, at: .end)
            row.sectionId = nil
            row.status = .member
            try row.update(db)
            return row
        }
    }

    /// **Dismiss** — tombstone the arrival row: the decision record (§4 —
    /// the born-tombstoned-equivalent; synced as an ordinary row, deduped by
    /// R1). The note returns to this book only on a FRESH tagging/starring
    /// act, and then only to Arrivals (P-13ib-U1-1). Allowed on a finished
    /// book (the only way an arrival exists there is a sync race against
    /// the finish, and dismissing is exactly what finishing does).
    public func dismissArrival(_ pairID: String) throws {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: pairID),
                  row.deletedAt == nil, row.status == .arrival
            else { throw OperationError.arrivalNotFound(id: pairID) }
            _ = try liveReading(db, row.readingId)
            row.deletedAt = date.now
            try row.update(db)
        }
    }

    /// FINISHING DISMISSES PENDING ARRIVALS (§24, her overrule — "it would be
    /// cluttered for arrivals to hang out on a finished book"): every live
    /// arrival row of the book is tombstoned on the finish's stamp, in the
    /// finish's transaction. Consequence, recorded: a dismissed arrival
    /// returns only on a FRESH act; the un-finish catch-up covers the gap
    /// only (it never resurrects a decided pair).
    ///
    /// 13i-c ladder round 1 (the MAJOR): the WHERE is
    /// `Queries.pendingArrivalRowsWhere`, SHARED with the confirm's
    /// `pendingArrivalCount` — the confirm's N and this act's rows are one
    /// set by construction. An ARCHIVED note's waiting row is in it, so
    /// §24's line counts it instead of the finish deciding it silently — and
    /// since 13i-d U4 (her #169(a)(3), P-13ib-U2-2 reversed) the door SHOWS
    /// it too, marked archived: every waiter the finish takes is visible.
    func dismissPendingArrivals(_ db: Database, readingID: String, now: Date) throws {
        try db.execute(
            sql: "UPDATE reading_post SET deleted_at = ? WHERE \(Queries.pendingArrivalRowsWhere)",
            arguments: [DateFormatter.variorumISO8601.string(from: now), readingID])
    }
}
