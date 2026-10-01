import Dependencies
import Foundation
import GRDB

// Readings: books/chapters/on-demand collections — ordered, non-exclusive
// pointer lists over posts (the deliberate asymmetry with blocks).
extension Operations {
    @discardableResult
    public func createReading(
        name: String,
        kind: ReadingKind,
        profile: String? = nil,
        sortField: SortField = .manual,
        sortDir: SortDirection = .asc,
        groupingTagId: String? = nil,
        querySpec: String? = nil,
        maxPosts: Int? = nil,
        wordTarget: Int? = nil,
        wingId: String = ""
    ) throws -> Reading {
        let now = date.now
        return try database.write { db -> Reading in
            let reading = Reading(
                id: newID(), ownerId: currentOwnerID(), name: name, kind: kind,
                profile: profile, sortField: sortField, sortDir: sortDir,
                groupingTagId: groupingTagId,
                querySpec: try normalizedRuleSpec(db, querySpec, wingID: wingId),
                maxPosts: maxPosts,
                wordTarget: wordTarget, wingId: wingId,
                createdAt: now, updatedAt: now)
            try reading.insert(db)
            return reading
        }
    }

    /// STORAGE IS v2 (13i-a; Domain/RuleGrammar): the rule-builder faces
    /// still hand this layer the v1 DRAFT encoding until 13i-b's grammar
    /// faces land, so the ONE write choke point normalizes — a v2 value
    /// stores as-is; a v1 draft converts (paths resolve to tag IDs in the
    /// reading's wing, live first, else the smallest-id tombstone, else the
    /// deliberate dead term); anything else stores as NO RULE (the standing
    /// malformed tolerance).
    private func normalizedRuleSpec(
        _ db: Database, _ json: String?, wingID: String
    ) throws -> String? {
        guard let json, !json.isEmpty else { return nil }
        if RuleGrammar.decode(json) != nil { return json }
        guard let v1 = try? JSONDecoder().decode(
            Queries.SmartQuerySpec.self, from: Data(json.utf8))
        else {
            // Undecodable bytes store AS THEY ARE: the read side fails
            // CLOSED on malformed (the v1 letter) — laundering to NULL
            // would silently flip a broken rule to match-all.
            return json
        }
        let v2 = RuleGrammar.fromLegacy(
            tags: v1.tags, tagsAll: v1.tagsAll, profile: v1.profile,
            entryDateFrom: v1.entryDateFrom, entryDateTo: v1.entryDateTo
        ) { path in
            (try? String.fetchOne(db, sql: """
                SELECT id FROM tag WHERE path = ? AND wing_id = ?
                ORDER BY (deleted_at IS NOT NULL), id LIMIT 1
                """, arguments: [path, wingID])) ?? nil
        }
        return try RuleGrammar.encode(v2)
    }

    // MARK: - Extent faces (Phase 13, A1/A2 — the bounded-notebook thread)

    /// Sets (or clears, with nil) the words-based extent TARGET (v1_11).
    /// A display/progress semantic, never an add-time refusal — word counts
    /// change with every edit, so membership can't enforce them; the shelf
    /// face shows progress and the boundary offers extend-or-start-new.
    /// Non-positive targets refuse; a LOCKED (finished) reading refuses —
    /// extending a bounded notebook is un-finishing it first (the
    /// setReadingSort parallel; PROVISIONAL, QUESTIONS bundle).
    public func setReadingWordTarget(_ id: String, wordTarget: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            if let wordTarget, wordTarget <= 0 {
                throw OperationError.invalidExtent(value: wordTarget)
            }
            guard reading.wordTarget != wordTarget else { return }
            reading.wordTarget = wordTarget
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// Sets (or clears) the post-count extent — `max_posts` has had NO
    /// setter since v1 (the brief's "no UI face at all" finding starts
    /// here). Same guards as the word target. Lowering the cap below the
    /// current live membership is legal: existing memberships stand;
    /// further adds refuse at the standing `readingAtCapacity` gate.
    public func setReadingMaxPosts(_ id: String, maxPosts: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            if let maxPosts, maxPosts <= 0 {
                throw OperationError.invalidExtent(value: maxPosts)
            }
            guard reading.maxPosts != maxPosts else { return }
            reading.maxPosts = maxPosts
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    public func renameReading(_ id: String, name: String) throws {
        try updateLiveReading(id) { $0.name = name }
    }

    /// For non-manual readings the sort field IS the order, so a locked
    /// reading ("declared done" — order frozen) refuses this too (review
    /// finding 2026-07-05).
    public func setReadingSort(_ id: String, field: SortField, direction: SortDirection) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            reading.sortField = field
            reading.sortDir = direction
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    public func setReadingQuerySpec(_ id: String, querySpec: String?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            reading.querySpec = try normalizedRuleSpec(
                db, querySpec, wingID: reading.wingId)
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// THE JOURNAL TRAIT's per-book setter (13i-a; the sitting record §10's
    /// ruling — "let's do create journal book for daily notebooks as a
    /// setting"; the Collecting pane's sentence is 13i-e's face): ON writes
    /// `profile='journal'` ("entries date-stamped at creation, named by
    /// their day, sorted by entry date"), OFF writes `profile='book'`.
    /// Flipping it never rewrites existing entries (ruled). The DAILY book
    /// refuses — its marker is constitutive (the memo §3). A finished
    /// (locked) book refuses: the trait governs the book's ordering
    /// semantics, `setReadingSort`'s own rule (PROVISIONAL, plan §9).
    /// No-op-guarded like every identity-level metadata setter.
    public func setJournalTrait(_ id: String, on: Bool) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard reading.profile != Queries.dailyJournalBookProfile else {
                throw OperationError.dailyJournalTraitIsConstitutive(id: id)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            let target = on ? Queries.journalTraitProfile : "book"
            guard reading.profile != target else { return }
            reading.profile = target
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// "Declared done" — freezes membership and order below; reversible.
    public func lockReading(_ id: String) throws {
        try updateLiveReading(id) { $0.locked = true }
    }

    public func unlockReading(_ id: String) throws {
        try updateLiveReading(id) { $0.locked = false }
    }

    /// Tombstone; the reading triggers cascade to its memberships
    /// (v1_core) and its chapters (v1_10), all stamped with the reading's
    /// exact `deleted_at`. Recoverable via `restoreReading` below.
    public func deleteReading(_ id: String) throws {
        let now = date.now
        try updateLiveReading(id, now: now) { $0.deletedAt = now }
    }

    /// Undo a `deleteReading` (13b Stage 4, 4F — N37, the author's
    /// S4-28.2 ruling: "I feel like readings should have a restore door?
    /// at least the curated ones if they're deleted" — DELIBERATELY
    /// reversing the standing pre-13 "readings have no restore door"
    /// boundary). The `restoreContainer` pattern: clear the reading's
    /// tombstone, then revive every cascade victim carrying its EXACT
    /// stamp — its `reading_section` chapters and its `reading_post`
    /// memberships. Rows whose story diverged stay dead: an independently
    /// deleted chapter or removed membership carries a different stamp,
    /// and a membership whose POST has since died stays dead even at the
    /// matching stamp (a live pointer at a dead post helps nobody — the
    /// restoreContainer live-parent guard, applied to the post side).
    /// Chapter assignments reattach for FREE (the dangle rule never
    /// rewrote `section_id`). Smart readings restore by the flip alone —
    /// their membership is derived, so the sweeps match nothing; the op
    /// deliberately does not refuse them (recorded reading). A finished
    /// (locked) book restores finished. NO undo entry — this door IS the
    /// recovery (the restoreContainer/restoreSection class). Outbox rows
    /// ride the ordinary triggers (this is a local write, never apply
    /// mode). Uniqueness is safe by construction: no live membership can
    /// exist for a dead reading (every add refuses through liveReading).
    public func restoreReading(_ id: String) throws {
        try database.write { db in
            guard var reading = try Reading.fetchOne(db, key: id) else {
                throw OperationError.readingNotFound(id: id)
            }
            guard let deletedAt = reading.deletedAt else {
                throw OperationError.readingNotDeleted(id: id)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now
            let nowStamp = DateFormatter.variorumISO8601.string(from: now)

            reading.deletedAt = nil
            reading.updatedAt = now
            try reading.update(db)
            // 13j ladder B (B1): a restored row voids any live intent
            // naming it — a leftover intent must never claim it later.
            try voidPurgeIntents(db, table: "reading", rowID: id)

            // Chapters: exact-stamp cascade victims revive; independently
            // deleted chapters (different stamp) stay dead — and now have
            // a working `restoreSection` door, because the reading is
            // live again (the boundary reversal's second half).
            try db.execute(
                sql: """
                    UPDATE reading_section SET deleted_at = NULL, updated_at = ?
                    WHERE reading_id = ? AND deleted_at = ?
                    """,
                arguments: [nowStamp, id, stamp])

            // Memberships: exact-stamp victims whose post is still LIVE.
            // (A post deleted independently stamps its own memberships via
            // the container cascade — different stamp, doubly safe; a post
            // that died AFTER this reading did matches the stamp and is
            // exactly what the live-post guard keeps dead.)
            try db.execute(
                sql: """
                    UPDATE reading_post SET deleted_at = NULL
                    WHERE reading_id = ? AND deleted_at = ?
                      AND post_id IN (SELECT id FROM container WHERE deleted_at IS NULL)
                    """,
                arguments: [id, stamp])
        }
    }

    // MARK: - Curated membership

    @discardableResult
    public func addPostToReading(
        _ postID: String, to readingID: String, at insert: InsertPosition = .end
    ) throws -> ReadingPost {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            _ = try livePost(db, postID)

            let liveCount = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                arguments: [readingID]) ?? 0
            if try liveMembership(db, postID: postID, readingID: readingID) != nil {
                throw OperationError.alreadyInReading(postID: postID, readingID: readingID)
            }
            // The extent constraint (fixed-length journals).
            if let maxPosts = reading.maxPosts, liveCount >= maxPosts {
                throw OperationError.readingAtCapacity(id: readingID)
            }

            let membership = ReadingPost(
                id: newID(), readingId: readingID, postId: postID,
                position: try readingPosition(db, readingID: readingID, at: insert),
                createdAt: date.now)
            try membership.insert(db)
            return membership
        }
    }

    /// NEW POST IN A BOOK (taste checkpoint, Sitting 9 — R62/R75: "it needs
    /// to be easy to make a post inside of a book"): mint the post AND its
    /// membership in ONE transaction, so a refusal (locked, at capacity,
    /// wrong kind, dead section) leaves NO stray post behind — the round-3
    /// `assertReadingAcceptsPosts` doctrine, now with the mint inside the
    /// same guard. Optional chapter assignment rides the membership row.
    /// No undo entry (createPost's class — deleteContainer is the inverse,
    /// recoverable via restoreContainer).
    @discardableResult
    public func newPostInReading(
        _ readingID: String, section sectionID: String? = nil,
        title: String? = nil, profile: Profile? = nil, entryDate: String? = nil
    ) throws -> Container {
        if let entryDate, !JournalDay.isValid(entryDate) {
            throw OperationError.invalidEntryDate(entryDate)
        }
        return try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            if let maxPosts = reading.maxPosts {
                let liveCount = try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [readingID]) ?? 0
                if liveCount >= maxPosts {
                    throw OperationError.readingAtCapacity(id: readingID)
                }
            }
            if let sectionID {
                let section = try liveSection(db, sectionID)
                guard section.readingId == readingID else {
                    throw OperationError.sectionNotInReading(
                        sectionID: sectionID, readingID: readingID)
                }
            }
            let post = try insertPost(db, title: title, profile: profile, entryDate: entryDate)
            try ReadingPost(
                id: newID(), readingId: readingID, postId: post.id,
                position: try readingPosition(db, readingID: readingID, at: .end),
                sectionId: sectionID,
                createdAt: date.now)
                .insert(db)
            return post
        }
    }

    /// The `addPostToReading` GATE without a post (Phase 13, round 3): a
    /// door that MINTS a post destined for a reading can refuse BEFORE
    /// minting, inside one serialized runner closure (the
    /// `dailyJournalBookID` read-inside-the-runner precedent — a pre-check
    /// outside the runner would race a concurrent lock and strand the
    /// mint). Throws exactly the add-side refusals a fresh post would hit:
    /// missing/tombstoned reading, wrong kind, locked, at capacity.
    public func assertReadingAcceptsPosts(_ readingID: String) throws {
        try database.read { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            if let maxPosts = reading.maxPosts {
                let liveCount = try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [readingID]) ?? 0
                if liveCount >= maxPosts {
                    throw OperationError.readingAtCapacity(id: readingID)
                }
            }
        }
    }

    /// **THE DUPLICATE-BOOK-NAME DOOR GUARD** (Phase 13e, E13 — her
    /// kickoff-sitting round-3 ruling: *REFUSE at the door*).
    ///
    /// Throws `duplicateBookName` when a LIVE reading already wears this name
    /// under `BookNaming`'s rule (ends-trimmed, case-folded), carrying that
    /// book's stored name so the door can name it back to her. `excluding` is
    /// the RENAME door's own row — renaming a book to the name it already has
    /// (or only changing its casing) is not a collision with itself.
    ///
    /// ── WHY IT IS A SEPARATE READ AND NOT A GUARD INSIDE THE OPS ──────────
    /// `createReading` and `renameReading` stay byte-unchanged on purpose.
    /// Three callers must never refuse for a name reason: the seeders (the
    /// tutorial book, the mobile fixtures), `shelveInDailyJournalBook`'s
    /// create-and-pin (AppSpec §9 — "it NEVER throws"), and the sync apply
    /// path, which lands whatever another device wrote. Her ruling is about
    /// what a DOOR does when she types a name, which is exactly the scope of
    /// an assert a door calls (the `assertReadingAcceptsPosts` precedent
    /// above: the same shape, for the same reason — a door refusing BEFORE
    /// it mints anything).
    ///
    /// ── WHAT COUNTS AS "LIVE" ────────────────────────────────────────────
    /// `deleted_at IS NULL`, and nothing narrower. A FINISHED (locked) book
    /// counts: it is on the shelf, in the palette and on every note card, so
    /// a second book wearing its name is exactly the confusion her ruling is
    /// about. A DELETED book does not — her words, "archived/deleted books
    /// don't count" — so a name is free again the moment its book is gone
    /// (recovering that book via `restoreReading` can therefore re-create the
    /// collision; the offline-race tolerance covers it, and no repair rule
    /// exists to invent).
    ///
    /// ── COST ─────────────────────────────────────────────────────────────
    /// One indexless scan of the `reading` table — bounded by the number of
    /// BOOKS, which is a shelf, never a corpus (P1: nothing here scales with
    /// posts, blocks or takes). The comparison runs in Swift rather than SQL
    /// because SQLite's `NOCASE` collation folds ASCII only, and a rule that
    /// silently stopped applying to a non-ASCII name would be worse than no
    /// rule.
    public func assertBookNameIsFree(_ name: String, excluding readingID: String? = nil) throws {
        let key = BookNaming.key(name)
        try database.read { db in
            let rows = try Row.fetchAll(
                db, sql: "SELECT id, name FROM reading WHERE deleted_at IS NULL")
            for row in rows {
                let id: String = row["id"]
                guard id != readingID else { continue }
                let existing: String = row["name"]
                if BookNaming.key(existing) == key {
                    throw OperationError.duplicateBookName(name: existing)
                }
            }
        }
    }

    public func removePostFromReading(_ postID: String, from readingID: String) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            membership.deletedAt = date.now
            try membership.update(db)
        }
    }

    public func reorderReadingPost(
        _ postID: String, in readingID: String, to insert: InsertPosition
    ) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            membership.position = try readingPosition(db, readingID: readingID, at: insert)
            try membership.update(db)
        }
    }

    private func updateLiveReading(
        _ id: String, now: Date? = nil, _ mutate: (inout Reading) -> Void
    ) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            mutate(&reading)
            reading.updatedAt = now ?? date.now
            try reading.update(db)
        }
    }

    /// Internal (not private) since 13c 2D: the smart→curated conversion
    /// and its re-apply consult the same "is this pair already live?"
    /// question `addPostToReading` does — one rule, one implementation.
    func liveMembership(
        _ db: Database, postID: String, readingID: String
    ) throws -> ReadingPost? {
        try ReadingPost
            .filter(Column("reading_id") == readingID && Column("post_id") == postID
                && Column("deleted_at") == nil)
            .fetchOne(db)
    }
}
