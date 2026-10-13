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
        wingId: String = "",
        intakeSeating: IntakeSeating? = nil,
        autoTagId: String? = nil,
        autoTagIDs: [String] = [],
        shelfId: String? = nil
    ) throws -> Reading {
        let now = date.now
        // 13i-c (R-13ic-1): the OUTFLOW is a set; the single-tag parameter
        // is a forwarding convenience (the 13i-b call sites and pins ride
        // unmodified — the 3C parity proof), merged in front of the set.
        let outflow = (autoTagId.map { [$0] } ?? []) + autoTagIDs
        return try database.write { db -> Reading in
            let id = newID()
            // 13i-b U1: the two Collecting settings are a BOOK's (a gathering
            // has no membership to seat and no notes written "here").
            if intakeSeating != nil || !outflow.isEmpty, kind != .book {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            // 13i-d U5 rider R1 (F-U4-5, RULED — the (c) arm's letter at the
            // mint: the sitting record §3, "a gathering has NO finish, word
            // target or capacity"): a gathering is never BORN with an extent.
            // No face passes one; the guard closes the door's shape first.
            if kind == .gathering, maxPosts != nil || wordTarget != nil {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            // 13i-d U5: a book is born in a LIVE wing (Home always is).
            try requireLiveWing(db, wingId)
            for tagID in outflow {
                let tag = try liveTag(db, tagID)
                guard tag.wingId == wingId else {
                    throw OperationError.tagNotFound(id: tagID)
                }
            }
            let spec = try normalizedRuleSpec(db, querySpec, wingID: wingId)
            // 13i-c (R-13ic-4): a GATHERING is born WITH a rule — "I just
            // don't think that a rule-less gathering makes sense." (A rule
            // that normalizes to NULL counts as none; undecodable bytes are
            // a malformed rule, stored raw — that letter stands.)
            if kind == .gathering, spec == nil {
                throw OperationError.gatheringRequiresRule(id: id)
            }
            // 13i-d U1 — THE CONTEXT MINT (the sitting record §19.1, ratified
            // §24): a book minted while a shelf is solo'd lands ON that shelf
            // ("you're looking at where you're filing"); every other door
            // passes nil and the book lands UNSHELVED (§19's ruling). The
            // shelf must be live and in this book's wing. Never placed — it
            // appends at the end of the shelf's "my order" (§24).
            if let shelfId {
                let shelf = try liveShelf(db, shelfId)
                guard shelf.wingId == wingId else {
                    throw OperationError.shelfNotFound(id: shelfId)
                }
            }
            let reading = Reading(
                id: id, ownerId: currentOwnerID(), name: name, kind: kind,
                profile: profile, sortField: sortField, sortDir: sortDir,
                groupingTagId: groupingTagId,
                querySpec: spec,
                maxPosts: maxPosts,
                wordTarget: wordTarget, wingId: wingId, shelfId: shelfId,
                intakeSeating: intakeSeating,
                autoTagIds: Reading.encodeOutflow(outflow),
                createdAt: now, updatedAt: now)
            try reading.insert(db)
            // CREATION-TIME BACKFILL (the 13i-b plan §2.3, the sitting §4): a
            // BOOK born with a rule — the spawn door, the from-tag mint —
            // seats its current matches directly (birth = intent). Silent
            // for a gathering or a rule-less book (the sweep's own guard).
            try intakeSweep(db, book: reading, occasion: .backfill, now: now)
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
    ///
    /// 13i-d U4 ACT 0 (F-U3-1, RULED — the sitting record §3's letter: a
    /// gathering has NO word target): a NON-NIL value on a gathering refuses
    /// `wrongReadingKind`, answered FIRST (Reopen would not help — a gathering
    /// has no extent at all). CLEARING stays legal: a gathering targeted
    /// before 13i-d (or so synced from another device) keeps its way out.
    public func setReadingWordTarget(_ id: String, wordTarget: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            try refuseExtentOnGathering(reading, value: wordTarget)
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
    ///
    /// 13i-d U4 ACT 0: a gathering has no capacity (§3) — the word target's
    /// rule exactly (a non-nil value refuses first; clearing stays legal).
    public func setReadingMaxPosts(_ id: String, maxPosts: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            try refuseExtentOnGathering(reading, value: maxPosts)
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

    /// THE (c) ARM's extent half (13i-d U4 ACT 0): a gathering takes no
    /// extent VALUE; nil (clearing) passes through to the setter's own
    /// guards unchanged — the legacy way out.
    private func refuseExtentOnGathering(_ reading: Reading, value: Int?) throws {
        guard value != nil, reading.kind == .gathering else { return }
        throw OperationError.wrongReadingKind(id: reading.id, expected: .book)
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

    /// The ONE rule write (the choke point every face routes through). On a
    /// BOOK it is also an intake occasion (13i-b U1, the plan §2.3): a rule
    /// set on a RULE-LESS book is creation-time BACKFILL (seats directly —
    /// birth = intent); a rule EDIT on a book that had one (readable or
    /// malformed — a malformed rule ran no intake, so its gap is judgment
    /// too) is a CATCH-UP (the gap's matches wait at Arrivals). Removing or
    /// breaking the rule never untags and never evicts (ruled). A write
    /// that leaves the stored rule byte-identical is no occasion at all. A
    /// finished book's intake is paused — the un-finish catches it up.
    public func setReadingQuerySpec(_ id: String, querySpec: String?) throws {
        try database.write { db in
            try writeReadingQuerySpec(db, id, querySpec: querySpec)
        }
    }

    /// `setReadingQuerySpec`'s row work inside a caller's transaction
    /// (13n-b U4 — the MCP book-rule act runs her Save's three writes in ONE
    /// transaction; byte-identical behaviour).
    ///
    /// `sweepOccasion` (13n-b U4 ladder round 1, F-1 — PROVISIONAL
    /// P-13nb-U4-16, hers at the merge bundle): the caller's OVERRIDE of the
    /// sweep's occasion classification. Her doors pass nothing — a rule set
    /// on a rule-less book stays creation-time BACKFILL (seats; birth =
    /// intent, HER authorship). The MCP book-rule act passes `.catchUp` so an
    /// AGENT-written rule always BELLS: backfill's warrant is her intent,
    /// which a client's call does not carry — and a seat would pull every
    /// matching unshared note into the client's own book-grant reach (the
    /// pull `noteIntoBook`'s double decision exists to prevent).
    func writeReadingQuerySpec(
        _ db: Database, _ id: String, querySpec: String?,
        sweepOccasion override: IntakeDecision.Occasion? = nil
    ) throws {
        do {
            var reading = try liveReading(db, id)
            let previous = reading.querySpec
            let normalized = try normalizedRuleSpec(db, querySpec, wingID: reading.wingId)
            // 13i-c (R-13ic-4): a gathering KEEPS a rule — clearing it is
            // refused here (the editor's empty-save refusal + its "Delete
            // this gathering…" offer stand on this guard). A book may be
            // cleared: that is its kill switch ("collects nothing by itself").
            if reading.kind == .gathering, normalized == nil {
                throw OperationError.gatheringRequiresRule(id: id)
            }
            reading.querySpec = normalized
            let now = date.now
            reading.updatedAt = now
            try reading.update(db)
            guard reading.kind == .book, reading.querySpec != previous else { return }
            let occasion: IntakeDecision.Occasion =
                override ?? (RuleGrammar.read(previous) == .none ? .backfill : .catchUp)
            try intakeSweep(db, book: reading, occasion: occasion, now: now)
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
    /// FINISHING DISMISSES PENDING ARRIVALS (13i-b U1 — the sitting record
    /// §24, her overrule of §19.5): the book's live arrival rows tombstone in
    /// this transaction, on the finish's stamp — the decision record. The
    /// finish CONFIRM's "N waiting at the door will be dismissed" line is
    /// 13i-c's face.
    ///
    /// 13i-c U2 (the plan §5): on a SEALED book this is a no-op — a sealed
    /// book is finished already (Sealed = Finished + text immutability).
    ///
    /// 13i-d U4 ACT 0 (F-U3-1, RULED — the sitting record §3's letter: a
    /// gathering has NO finish): a GATHERING refuses `wrongReadingKind`,
    /// answered first — a legacy finished one included (the kind, not the
    /// state, is the answer). `unlockReading` stays legal on a gathering: a
    /// gathering finished before 13i-d (or so synced) keeps its Reopen.
    public func lockReading(_ id: String) throws {
        try database.write { db in
            _ = try finishReadingRows(db, id)
        }
    }

    /// `lockReading`'s row work inside a caller's transaction (VX-184 U5 —
    /// the MCP door's `finish_book` runs it under its guard, and its undo's
    /// redo and a reopen's undo run it too). Byte-identical behaviour: the
    /// whole body moved, nothing in it did. Returns the FINISH's stamp — the
    /// one the pending arrivals were dismissed on — or nil for a sealed book
    /// (finished already: nothing written).
    @discardableResult
    func finishReadingRows(_ db: Database, _ id: String) throws -> Date? {
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            guard reading.sealedAt == nil else { return nil }
            let now = date.now
            reading.locked = true
            reading.updatedAt = now
            try reading.update(db)
            try dismissPendingArrivals(db, readingID: id, now: now)
            return now
    }

    /// Un-finishing a living book RESUMES its intake with a CATCH-UP (13i-b
    /// U1, the plan §2.3): the matches that arrived while it was finished —
    /// and only those, since every pair it had decided stays decided —
    /// wait at Arrivals (gap = judgment). Un-finishing a book that was not
    /// finished is no occasion.
    ///
    /// 13i-c U2 (R-13ic-3): a SEALED book refuses (`readingSealed`) — the ONE
    /// door down from Sealed is Unseal, which reopens the book too; the two
    /// states never contradict.
    public func unlockReading(_ id: String) throws {
        try database.write { db in
            try reopenReadingRows(db, id)
        }
    }

    /// `unlockReading`'s row work inside a caller's transaction (VX-184 U5 —
    /// `reopen_book`, and a finish's undo). Byte-identical behaviour.
    func reopenReadingRows(_ db: Database, _ id: String) throws {
            var reading = try liveReading(db, id)
            guard reading.sealedAt == nil else {
                throw OperationError.readingSealed(id: id)
            }
            let wasFinished = reading.locked
            let now = date.now
            reading.locked = false
            reading.updatedAt = now
            try reading.update(db)
            if wasFinished {
                try intakeSweep(db, book: reading, occasion: .catchUp, now: now)
            }
    }

    /// Tombstone; the reading triggers cascade to its memberships
    /// (v1_core) and its chapters (v1_10), all stamped with the reading's
    /// exact `deleted_at`. Recoverable via `restoreReading` below.
    /// "Delete book only" (13i-c — the sitting record §6): an OWNED book's
    /// notes are released by the cascade and land in the Pool ("nothing of
    /// hers destroyed"); a plain book's delete never touches a note.
    ///
    /// **13i-e — THE DAILY JOURNAL CAN BE ARCHIVED, NEVER DELETED** (the
    /// sitting record §10, on the ⌘J ground): a book wearing the 'daily'
    /// marker refuses `dailyJournalCannotBeDeleted`, read from the row INSIDE
    /// this transaction (a caller-side check would read a stale projection).
    /// The road is `archiveReading` — it returns when a day arrives.
    public func deleteReading(_ id: String) throws {
        try database.write { db in
            _ = try deleteReadingRow(db, id)
        }
    }

    /// `deleteReading`'s row work inside a caller's transaction (VX-184 U5 —
    /// `delete_book`, and its undo's redo). Byte-identical behaviour, the
    /// daily Journal's guard included. Returns the tombstone's stamp (the
    /// one the cascade stamps the chapters and memberships with).
    @discardableResult
    func deleteReadingRow(_ db: Database, _ id: String) throws -> Date {
            var reading = try liveReading(db, id)
            try refuseDeletingTheDailyJournal(reading)
            let now = date.now
            reading.deletedAt = now
            reading.updatedAt = now
            try reading.update(db)
            return now
    }

    /// THE GUARD, one line for both delete doors (13i-e): keyed on the
    /// marker (`isDailyJournalMintShape` — kind book + profile 'daily'),
    /// never the name or the cached setting. Two marker-bearers meeting
    /// mid-convergence both refuse; the keeper repair's apply-mode tombstone
    /// is not an operation and is untouched.
    private func refuseDeletingTheDailyJournal(_ reading: Reading) throws {
        guard Queries.isDailyJournalMintShape(reading) else { return }
        throw OperationError.dailyJournalCannotBeDeleted(id: reading.id)
    }

    /// **"Delete book and its N notes"** (13i-c U2 — the sitting record §6's
    /// two-choice confirm; the 13i-c plan §6): ONE STAMP for the whole act —
    /// each live MEMBER note goes to the Trash through `deleteContainer`'s own
    /// body (its saved versions ride, that door's letter), then the book's
    /// tombstone on the same `now` (the cascade stamps the remaining rows —
    /// its arrivals, its chapters — with it). So `restoreReading` returns the
    /// book WHOLE, and each note also rows in the Trash with its own Put back
    /// (a note put back alone comes back bookless until the book returns).
    ///
    /// The DOOR offers this only on an OWNED book (ruled — "the asymmetry is
    /// the ownership concept, visible at the door"); the op refuses a
    /// gathering (`wrongReadingKind` — it holds no notes) and — 13i-e — the
    /// DAILY JOURNAL (`dailyJournalCannotBeDeleted`, the same guard as
    /// `deleteReading`, inside this transaction, before any note is touched).
    /// Returns the notes it deleted, in the book's order. Clears the redo
    /// future (`deleteContainer`'s own rule — a note's content left).
    @discardableResult
    public func deleteReadingWithNotes(_ id: String) throws -> [String] {
        let deleted: [String] = try database.write { db in
            var reading = try liveReading(db, id)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            try refuseDeletingTheDailyJournal(reading)
            let now = date.now
            let postIDs = try String.fetchAll(
                db,
                sql: """
                    SELECT rp.post_id FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                     AND c.kind = 'post'
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.position, rp.id
                    """,
                arguments: [id])
            var deleted: [String] = []
            for postID in postIDs {
                // A member that died earlier in this loop (a version of a
                // fellow member, riding its note) is already on the stamp.
                guard try Container.fetchOne(db, key: postID)?.deletedAt == nil else { continue }
                try tombstoneNoteFamily(db, id: postID, now: now)
                deleted.append(postID)
            }
            reading.deletedAt = now
            reading.updatedAt = now
            try reading.update(db)
            return deleted
        }
        undoStack?.clearRedoFuture()
        return deleted
    }

    /// What a duplicate made.
    public struct BookDuplicateResult: Equatable, Sendable {
        /// The new book.
        public let reading: Reading
        /// DEEP only: each member's ceremony copy (original → copy), in the
        /// book's order. Empty for a shallow duplicate.
        public let copied: [OwnershipFork]
    }

    /// **DUPLICATE BOOK** (13i-c U2 — the sitting record §6; the 13i-c plan §6):
    /// a NEW book row carrying the source's CONFIGURATION, never its STATE
    /// (PROVISIONAL P-13ic-7): name as given (the door asserts it free, E13);
    /// profile, sort, grouping tag, rule, extents, the join dial and the
    /// OUTFLOW copied; the same wing; born UNSHELVED, unstarred, open,
    /// unsealed and NOT owned ("the duplicate born non-owned" — ruled). Its
    /// live chapters are copied (fresh ids, positions and names kept) and each
    /// live MEMBER row is copied at its position, re-pointed at the copied
    /// chapter (arrivals never — they are the source's judgment, not its
    /// contents).
    ///
    /// - **Shallow** (`deep: false`): the same notes — a sibling pointing at
    ///   them. Refuses on an OWNED source (`ownedBookDuplicatesDeep` — a
    ///   second pointer is exactly what owning forbids).
    /// - **Deep** (`deep: true`, "with copies"): each member's ceremony copy
    ///   (tags riding) becomes the member — the divergent fork; the only shape
    ///   for an owned source.
    ///
    /// A gathering refuses (`wrongReadingKind` — §3: "why would we be able to
    /// duplicate a gathering?"). THE DAILY JOURNAL's duplicate wears the
    /// journal TRAIT, never the `'daily'` marker — the marker names THE one
    /// daily book (the identity memo §3) and only `setDailyJournalBook` moves
    /// it (PROVISIONAL P-13ic-U2-5). No creation-time backfill (the copied
    /// membership IS the state) and no structural-undo entry (the Trash is the
    /// road — the `createReading` class).
    @discardableResult
    public func duplicateReading(
        _ id: String, name: String, deep: Bool
    ) throws -> BookDuplicateResult {
        try database.write { db in
            let source = try liveReading(db, id)
            guard source.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            if source.owned && !deep {
                throw OperationError.ownedBookDuplicatesDeep(id: id)
            }
            let now = date.now
            let profile = source.profile == Queries.dailyJournalBookProfile
                ? Queries.journalTraitProfile : source.profile
            let duplicate = Reading(
                id: newID(), ownerId: currentOwnerID(), name: name, kind: .book,
                profile: profile, sortField: source.sortField, sortDir: source.sortDir,
                groupingTagId: source.groupingTagId, querySpec: source.querySpec,
                maxPosts: source.maxPosts, wordTarget: source.wordTarget,
                wingId: source.wingId, intakeSeating: source.intakeSeating,
                autoTagIds: source.autoTagIds,
                createdAt: now, updatedAt: now)
            try duplicate.insert(db)

            var chapterMap: [String: String] = [:]
            let chapters = try ReadingSection.fetchAll(
                db,
                sql: """
                    SELECT * FROM reading_section
                    WHERE reading_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [id])
            for chapter in chapters {
                let copy = ReadingSection(
                    id: newID(), readingId: duplicate.id, name: chapter.name,
                    position: chapter.position, createdAt: now, updatedAt: now)
                try copy.insert(db)
                chapterMap[chapter.id] = copy.id
            }

            let memberships = try ReadingPost.fetchAll(
                db,
                sql: """
                    SELECT rp.* FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                     AND c.kind = 'post'
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.position, rp.id
                    """,
                arguments: [id])
            var copied: [OwnershipFork] = []
            for membership in memberships {
                var postID = membership.postId
                if deep {
                    postID = try ceremonyCopy(db, sourceID: membership.postId, now: now).id
                    copied.append(OwnershipFork(
                        originalID: membership.postId, copyID: postID,
                        elsewhereNames: [source.name]))
                }
                try ReadingPost(
                    id: newID(), readingId: duplicate.id, postId: postID,
                    position: membership.position,
                    sectionId: membership.sectionId.flatMap { chapterMap[$0] },
                    createdAt: now
                ).insert(db)
            }
            return BookDuplicateResult(reading: duplicate, copied: copied)
        }
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
        try database.write { db in try restoreReadingRows(db, id: id) }
    }

    /// `restoreReading`'s body at db level (13n-a: an imported book's REDO
    /// revives its notes and then the book in ONE transaction —
    /// `reapplyImportedBook`). Byte-identical to the body it was.
    func restoreReadingRows(_ db: Database, id: String) throws {
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
        // 13i-d U5 — RE-HOME on Put back (PROVISIONAL P-13id-U5-2): a book
        // whose wing was deleted while it lay in the Trash comes back to
        // HOME, unshelved (its shelf died with the wing).
        if try !Queries.wingIsLive(db, id: reading.wingId) {
            reading.wingId = ""
            reading.shelfId = nil
            reading.shelfPosition = nil
        }
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

        // 13i-c U2 — the book RETURNS WHOLE (the sitting record §18.3:
        // "the delete-book-and-notes road (one stamp) returns WHOLE"):
        // the notes deleted WITH the book (`deleteReadingWithNotes` — the
        // book's own member rows and each note on this exact stamp) come
        // back first, versions and all, through `restoreContainer`'s own
        // body — so the live-post guard below passes for them. A note
        // deleted independently carries a different stamp and stays dead
        // (the standing documented corner); a note put back alone earlier
        // is live already, and its membership revives below.
        let notesDeletedWithBook = try String.fetchAll(
            db,
            sql: """
                SELECT DISTINCT rp.post_id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at = ?
                WHERE rp.reading_id = ? AND rp.deleted_at = ? AND rp.status = 'member'
                ORDER BY rp.post_id
                """,
            arguments: [stamp, id, stamp])
        for postID in notesDeletedWithBook {
            try restoreNoteFamily(db, id: postID)
        }

        // Memberships: exact-stamp victims whose post is still LIVE.
        // (A post deleted independently stamps its own memberships via
        // the container cascade — different stamp, doubly safe; a post
        // that died AFTER this reading did matches the stamp and is
        // exactly what the live-post guard keeps dead.)
        // 13i-c U2 (P-13ic-U2-6): a SEALED book takes back only SEALED
        // members — a note whose seal was lifted by hand while the book
        // lay in the Trash does not rejoin the edition (P-13ic-6's other
        // half: "Put back restores a sealed book whose stamps still match").
        let sealedOnly = reading.sealedAt != nil ? " AND locked = 1" : ""
        // 13i-d U5b (F-U5b-1, PROVISIONAL P-13id-U5b-5): only notes of the
        // book's OWN wing, read AFTER the re-home above — a note that
        // moved to another wing while the book lay in the Trash stays
        // where it went, and its row stays decided-dead (a book never
        // spans wings, §9). The one predicate both revival sites read.
        let sameWing = Queries.revivalWingScope(wingID: reading.wingId)
        let revivalArguments: [(any DatabaseValueConvertible)?] = [id, stamp] + sameWing.arguments
        try db.execute(
            sql: """
                UPDATE reading_post SET deleted_at = NULL
                WHERE reading_id = ? AND deleted_at = ?
                  AND post_id IN (SELECT id FROM container WHERE deleted_at IS NULL\(sealedOnly)
                                    AND \(sameWing.sql))
                """,
            arguments: StatementArguments(revivalArguments))

        // 13i-c U2 — OWNERSHIP holds after the revival (the 13i-c plan §4
        // row 7): a note added elsewhere while this book (or the note)
        // lay in the Trash keeps its EARLIEST membership; the later one
        // bells or goes — R2's shape, applied locally.
        let revivedMembers = try String.fetchAll(
            db,
            sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                """,
            arguments: [id])
        try enforceOwnershipAfterRevival(
            db, postIDs: revivedMembers + notesDeletedWithBook, now: now)

        // 13i-b U1 — RESUME CATCH-UP (the plan §2.3): a living book back
        // from the Trash routes the gap's matches through Arrivals. The
        // exact-stamp revival above came FIRST, so every pair the book
        // had decided (members, waiting arrivals — both revived — and
        // its older tombstones) stays decided. A finished book restores
        // finished, its intake still paused.
        try intakeSweep(db, book: reading, occasion: .catchUp, now: now)
    }

    // MARK: - Curated membership

    /// A HAND-ADD — THE ONE CHOKE POINT every face's add routes through
    /// (13i-c U2: the 13i-c plan §4 row 1). It CONSULTS OWNERSHIP
    /// (`OwnershipDecision`) after the standing gates: where a plain pointer
    /// would break an ownership promise it refuses with the choice the door
    /// must offer — `noteMemberedElsewhere` (an OWNED book meeting a note
    /// that lives in other books: copy in / move in) or `noteOwnedElsewhere`
    /// (a PLAIN book meeting a note an owned book holds: copy in). A bookless
    /// note moves in clean anywhere; an ordinary note joins a plain book
    /// beside its other books. The capacity gate speaks FIRST — a full book
    /// cannot take a copy either, so offering one would be a door that can
    /// never act (P-2).
    ///
    /// Two 13i-b U1 additions, both in this transaction:
    /// - a note WAITING at this book's door (a live arrival) is SEATED — the
    ///   same row flips to member at the place she asked (her judgment "add
    ///   it"; refusing "already in this book" would be false — an arrival is
    ///   never a member). PROVISIONAL P-13ib-U1-2.
    /// - the book's AUTO-TAG rides the add (P-13ib-1 — "adding to a book is
    ///   real membership, with auto-tag covering the tagging", sitting
    ///   §14.6), through the one application road.
    @discardableResult
    public func addPostToReading(
        _ postID: String, to readingID: String, at insert: InsertPosition = .end
    ) throws -> ReadingPost {
        try database.write { db in
            try addPostToReading(db, postID, to: readingID, at: insert)
        }
    }

    /// The hand-add's body at db level (13i-e: shared with
    /// `shelveInDailyJournalBook`, whose filing runs inside the SAME
    /// transaction as the daily Journal's comes-back — under a savepoint, so
    /// a refused filing rolls back alone). Every refusal below is raised
    /// BEFORE the first write.
    @discardableResult
    func addPostToReading(
        _ db: Database, _ postID: String, to readingID: String, at insert: InsertPosition
    ) throws -> ReadingPost {
        let reading = try liveReading(db, readingID)
        guard reading.kind == .book else {
            throw OperationError.wrongReadingKind(id: readingID, expected: .book)
        }
        guard !reading.locked else {
            throw OperationError.lockedReading(id: readingID)
        }
        // 13i-d U5 (F-U5-2): a book never spans wings (§9) — the one
        // choke point refuses a note of another wing.
        try requireSameWing(db, post: try livePost(db, postID), book: reading)

        let liveCount = try liveMemberCount(db, readingID: readingID)
        if try liveMembership(db, postID: postID, readingID: readingID) != nil {
            throw OperationError.alreadyInReading(postID: postID, readingID: readingID)
        }
        // The extent constraint (fixed-length journals).
        if let maxPosts = reading.maxPosts, liveCount >= maxPosts {
            throw OperationError.readingAtCapacity(id: readingID)
        }
        // 13i-c U2 — the ownership consult (both arms below: a fresh row
        // AND a waiting arrival's seat — "a waiting ARRIVAL's seating
        // path inside the same op consults the same table", the plan §3).
        try consultOwnership(db, book: reading, postID: postID)

        let now = date.now
        let membership: ReadingPost
        if var waiting = try livePairRow(db, postID: postID, readingID: readingID) {
            // Only an arrival can be live here (a member threw above).
            waiting.status = .member
            waiting.sectionId = nil
            waiting.position = try readingPosition(db, readingID: readingID, at: insert)
            try waiting.update(db)
            membership = waiting
        } else {
            membership = ReadingPost(
                id: newID(), readingId: readingID, postId: postID,
                position: try readingPosition(db, readingID: readingID, at: insert),
                createdAt: now)
            try membership.insert(db)
        }
        try applyAutoTag(db, book: reading, postID: postID, now: now)
        return membership
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
                    sql: """
                    SELECT COUNT(*) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                      AND status = 'member'
                    """,
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
            // 13i-c (R-13ic-2's one-line fix of 13i-b U1 F-5): the note is
            // born in the BOOK's wing — a book never spans wings (§9).
            let post = try insertPost(
                db, title: title, profile: profile, entryDate: entryDate,
                wingId: reading.wingId)
            let now = date.now
            try ReadingPost(
                id: newID(), readingId: readingID, postId: post.id,
                position: try readingPosition(db, readingID: readingID, at: .end),
                sectionId: sectionID,
                createdAt: now)
                .insert(db)
            // AUTO-TAG (13i-b U1, the sitting §4 — "notes minted inside the
            // book get the tag"): in the mint's transaction, AFTER the
            // membership, so this book's own pair is already decided and the
            // tagging act is heard by the OTHER living books.
            try applyAutoTag(db, book: reading, postID: post.id, now: now)
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
                    sql: """
                    SELECT COUNT(*) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                      AND status = 'member'
                    """,
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
    /// **13i-e — and an ARCHIVED book does not count either** — the other
    /// half of her words, which had nothing to bite on until books could be
    /// archived (QUESTIONS' 13e batch-1 entry (a): "books have no archive").
    /// An unarchive can re-create a collision exactly as a Put back can; the
    /// same tolerance covers it (PROVISIONAL P-13ie-U1-11).
    ///
    /// ── COST ─────────────────────────────────────────────────────────────
    /// One indexless scan of the `reading` table — bounded by the number of
    /// BOOKS, which is a shelf, never a corpus (P1: nothing here scales with
    /// posts, blocks or takes). The comparison runs in Swift rather than SQL
    /// because SQLite's `NOCASE` collation folds ASCII only, and a rule that
    /// silently stopped applying to a non-ASCII name would be worse than no
    /// rule.
    public func assertBookNameIsFree(_ name: String, excluding readingID: String? = nil) throws {
        try database.read { db in
            try requireBookNameFree(db, name, excluding: readingID)
        }
    }

    /// The guard's body at db level (13n-a: the folder IMPORT is a door that
    /// names a book — the folder's name — so `importBook` asks this inside
    /// its own transaction, before it mints anything). Byte-identical rule.
    func requireBookNameFree(
        _ db: Database, _ name: String, excluding readingID: String? = nil
    ) throws {
        let key = BookNaming.key(name)
        let rows = try Row.fetchAll(
            db, sql: "SELECT id, name FROM reading WHERE deleted_at IS NULL AND archived_at IS NULL")
        for row in rows {
            let id: String = row["id"]
            guard id != readingID else { continue }
            let existing: String = row["name"]
            if BookNaming.key(existing) == key {
                throw OperationError.duplicateBookName(name: existing)
            }
        }
    }

    /// REMOVE FROM THIS BOOK — on an owned book the same door reads
    /// "Release from this book" (§20; the vocabulary is the faces'). A
    /// membership tombstone, member-class (tombstone-means-decided keeps
    /// intake from re-adding); the note lives on in its other books or the
    /// Pool, tags untouched. 13i-c U2: RETURNS whether the note is now
    /// BOOKLESS (no live member row in any live book — on an owned book that
    /// is true by construction), so the receipt can say "Released — it's in
    /// the Pool now." A gathering has no remove door (no membership — the
    /// honest door is removing the tag, `removeTag`).
    @discardableResult
    public func removePostFromReading(_ postID: String, from readingID: String) throws -> Bool {
        try database.write { db in
            try removeMembershipRow(db, postID: postID, readingID: readingID).bookless
        }
    }

    /// `removePostFromReading`'s row work inside a caller's transaction
    /// (VX-184 U5 — `remove_note_from_book`). Byte-identical behaviour.
    /// Returns the tombstoned member row (its `deletedAt` is the act's stamp)
    /// and whether the note is now bookless.
    func removeMembershipRow(
        _ db: Database, postID: String, readingID: String
    ) throws -> (row: ReadingPost, bookless: Bool) {
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            membership.deletedAt = date.now
            try membership.update(db)
            return (membership, try isBookless(db, postID: postID))
    }

    public func reorderReadingPost(
        _ postID: String, in readingID: String, to insert: InsertPosition
    ) throws {
        try database.write { db in
            _ = try reorderMembershipRow(db, postID: postID, readingID: readingID, to: insert)
        }
    }

    /// `reorderReadingPost`'s row work inside a caller's transaction (VX-184
    /// U5 — `move_note_in_book`). Byte-identical behaviour. Returns the member
    /// row's id and its position before and after.
    func reorderMembershipRow(
        _ db: Database, postID: String, readingID: String, to insert: InsertPosition
    ) throws -> (rowID: String, from: String, to: String) {
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            let from = membership.position
            membership.position = try readingPosition(db, readingID: readingID, at: insert)
            try membership.update(db)
            return (membership.id, from, membership.position)
    }

    /// **A BOOK NEVER SPANS WINGS** (13i-d U5 — the sitting record §9; the
    /// identity brief's "books never span libraries"): every
    /// membership-creating road — the hand-add choke point, copy in, move in,
    /// an arrival's seat — refuses a note whose wing is not the book's
    /// (`crossWingMembership`). The book choosers list only the note's own
    /// wing's books, so no face reaches this; it is the invariant's belt.
    /// Compared as surfaces READ the wings (a dangling pointer is Home's).
    func requireSameWing(_ db: Database, post: Container, book: Reading) throws {
        guard try sameEffectiveWing(db, post.wingId, book.wingId) else {
            throw OperationError.crossWingMembership(postID: post.id, readingID: book.id)
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

    /// The pair's live MEMBERSHIP — a live `status='member'` row. Every
    /// membership door (add's duplicate check, remove, reorder, diverge,
    /// chapter assignment) asks THIS question: an arrival is never a member
    /// (13i-a's schema note; 13i-b U1 made arrival rows real, and pinned the
    /// doors — `ArrivalMemberHygieneTests`).
    func liveMembership(
        _ db: Database, postID: String, readingID: String
    ) throws -> ReadingPost? {
        try ReadingPost
            .filter(Column("reading_id") == readingID && Column("post_id") == postID
                && Column("deleted_at") == nil && Column("status") == MembershipStatus.member)
            .fetchOne(db)
    }

    /// The pair's live row of EITHER status — the `uq_reading_post_live`
    /// question (the smart→curated conversion and its re-apply skip a pair
    /// that already has one; a hand-add seats a waiting arrival).
    func livePairRow(
        _ db: Database, postID: String, readingID: String
    ) throws -> ReadingPost? {
        try ReadingPost
            .filter(Column("reading_id") == readingID && Column("post_id") == postID
                && Column("deleted_at") == nil)
            .fetchOne(db)
    }
}
