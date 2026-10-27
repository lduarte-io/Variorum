import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's WRITE ACTS (13n-b U2 — the SUGGEST and WRITE NEW rungs of
// R-13n-4; the paper trail of R-13n-6). A connected client's writes are
// ORDINARY OPERATIONS: each act below is the operations layer's own work (the
// same fan, comment, lens, mint, application and membership roads her doors
// use), wrapped so that it registers exactly ONE structural-undo entry
// labeled with THE CLIENT'S NAME — her words, carried: "undoing AI writing …
// in a single command." The server decides WHETHER a client may act (the
// pure grant rule, per call); these ops decide nothing about clients — they
// are the acts, each with its exact-row inverse and redo.
//
// **Why every act registers here, including the ones her own doors do not**
// (a comment, a tag, a lens, a book — AppSpec §9's exclusion class): R-13n-6
// rules that EVERY MCP write registers structural undo, so ⌥⌘Z walks an AI
// session back one act at a time. Her own gestures keep their own undo
// posture unchanged — these are separate entry points (P-13nb-U2-4).
//
// **What the SUGGEST acts can touch, by construction** (the verification
// bar's heart — R-13n-4's "PROVABLY cannot modify an existing take", pinned
// in `MCPSuggestProofTests`/`MCPServerTests`): `addTake` INSERTS one take at
// the fan's end (never chosen, never locked, never the default — no existing
// row is updated); `addComment` inserts a comment row; `saveLens` inserts a
// lens and its sparse choices (a lens is never rendering truth). None of the
// three issues an UPDATE against `variant` or `container_block`.
//
// Inverse/redo doctrine (`Operations+UndoInverses`'): exact rows from the
// do-time ids, never a re-run; resolvable refusals THROW and keep the entry
// (a sealed note, a take she has since chosen); divergence is QUIET (a row
// already gone stays gone, a row already back stays).
extension Operations {
    /// The acts the door can take, for their undo labels. The words are the
    /// app's voice (P-13n-1's boundary — the label is an app-wide face) and
    /// sweepable at 13s-a (PROVISIONAL, P-13nb-U2-5): "Undo claude-code's
    /// take" in the Edit menu, "Undid: claude-code's take" as the receipt.
    public enum MCPWriteAct: String, Sendable, CaseIterable {
        case take, comment, lens, note, importNote = "import", importBook = "book import", tag, book
        case bookAdd = "add to a book"
        // 13n-b U3 — the edit rung's acts and the chapter (write new).
        case chapter
        case edit, divide, merge, move, delete
        case blockName = "block name"
        // 13n-b U4 — the carriage's acts (P-13nb-U4: the words extend
        // P-13nb-U2-5's family, 13s-a sweepable).
        case putBack = "put back"
        case version
        case entryDate = "date"
        case filing = "chapter filing"
        case bookRule = "book rule"
        // 13n-c U6 — the per-item note move across wings (VX-160; brief §10's
        // U1: "Undo claude-code's wing move").
        case wingMove = "wing move"
        // VX-168 U2 — the edit rung's deliberate acts: VX-169's `save_commit`
        // (a commit — append-only, I5: it registers NO undo entry, exactly as
        // her own ⌘S registers none — R-13n-6's "exactly as her gestures do")
        // and VX-174's `choose_take` / `adopt_lens` (R-MERGE-1: pointer moves,
        // ONE undo entry each). Words P-13nb-U2-5's family, 13s-a sweepable.
        case commit
        case choice = "take choice"
        case lensAdoption = "lens adoption"
        // VX-184 U3 — VX-173's batch doors (`add_takes`, `add_comments`): ONE
        // entry per batch, its label plural ("Undo claude-code's takes"); the
        // receipt counts the batch's items (`MCPWriteReceipt.count`).
        case takes, comments
        // VX-336 U5b — VX-255's `insert_blocks` (write new at the note's end,
        // edit anywhere): ONE entry per call, its label plural ("Undo
        // claude-code's blocks" — the takes batch's twin); the receipt counts
        // the blocks (`MCPWriteReceipt.count`).
        case blocks
        // VX-336 U6a — VX-311's `duplicate_note` (her Duplicate as Version on
        // the wire): ONE entry ("Undo claude-code's duplicate"); the receipt
        // names the copy and opens it (PROVISIONAL words, her copy pass).
        case duplicate
        // VX-184 U3 — VX-188's suggest-rung delete of a client's OWN comment
        // ("Undo claude-code's comment deletion").
        case commentDelete = "comment deletion"
        // VX-184 U3 — VX-190's edit-rung un-tag ("Undo claude-code's tag removal").
        case untag = "tag removal"
        // VX-184 U3 — VX-187's named-pair version link ("Undo claude-code's version link").
        case versionLink = "version link"
        // VX-184 U4 — VX-195's edit parity inside a note (R-VX184-1): every act
        // ONE client-named entry (P-13nb-U2-4; the record's call 1). A block's
        // LAST take deleted rides `.delete` — `delete_block`'s own entry and
        // words, the receipt's detail saying why (R-VX184-1). PROVISIONAL words
        // (P-U4-WORDS), 13s-a sweepable.
        case commentEdit = "comment edit"
        case commentRestore = "comment restore"
        case takeDelete = "take deletion"
        case takeArchive = "take archiving"
        case takeUnarchive = "take unarchiving"
        case takeLabel = "take label"
        case takeLock = "take lock"
        case takeUnlock = "take unlock"
        case commitRestore = "commit restore"
        case commitRename = "commit name"
        case noteTitle = "note title"
        case lensDelete = "lens deletion"
        // VX-184 U5 — VX-196's edit parity across the library (R-VX184-1): every
        // act ONE client-named entry (P-VX196-1). An OWNED book's removal reads
        // "release" — her door's own word (§20). PROVISIONAL words
        // (P-U5-WORDS), 13s-a sweepable.
        case bookName = "book name"
        case bookFinish = "finish"
        case bookReopen = "reopen"
        case bookArchive = "book archiving"
        case bookUnarchive = "book unarchiving"
        case bookDelete = "book deletion"
        case bookRemove = "removal from a book"
        case bookRelease = "release from a book"
        case bookOrder = "move in a book"
        case chapterName = "chapter name"
        case chapterDelete = "chapter deletion"
        case chapterMove = "chapter move"
        case noteDelete = "note deletion"
        case noteArchive = "note archiving"
        case noteUnarchive = "note unarchiving"

        public func undoLabel(client: String) -> String { "\(client)'s \(rawValue)" }

        /// **Does ⌥⌘Z walk this act back?** Every act but a commit: a commit is
        /// append-only (I5), `commit_point` has no tombstone to flip, and her
        /// own commit is outside structural undo (AppSpec §9) — so a receipt
        /// may say "⌥⌘Z undoes" only over a run that holds an act it undoes.
        public var isUndoable: Bool { self != .commit }
    }

    /// Where a minted note lands: inside a book (a member at its end, in the
    /// book's wing) or bookless in a wing (the Pool of that wing).
    public enum MCPNoteDestination: Equatable, Sendable {
        case book(String)
        case wing(String)
    }

    // MARK: - SUGGEST: a take at the fan's end

    /// **One new take at the END of a block's fan**, holding `text`
    /// verbatim, labeled `label` (nil/blank = unlabeled), PARENTLESS (a
    /// fresh text, not a branch of hers), never chosen (no placement's
    /// `chosen_variant_id` moves), never the block's default, never locked.
    /// Fan growth's conventions: no touch, no churn (`branchVariant`'s);
    /// a sealed note refuses (`insertFanVariant`'s). ONE undo entry: the
    /// take tombstoned (refused while she has CHOSEN it — choose another
    /// first, `deleteVariant`'s guard), the redo flipping the same row back.
    @discardableResult
    public func addTake(
        toBlock blockID: String, text: String, label: String?, undoLabel: String
    ) throws -> Variant {
        let take: Variant = try database.write { db in
            try insertSuggestedTake(db, blockID: blockID, text: text, label: label)
        }
        let takeID = take.id
        // VX-246 U2: the redo revives the take only on the stamp its own undo
        // wrote (the F1 shape) — a take that died since on another stamp (her
        // delete after a Put back, a sync tombstone) is not the undo's.
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertAddedTake(takeID) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyAddedTake(takeID, undoneOn: undoneOn.value) })
        return take
    }

    /// `addTake`'s row work inside the caller's transaction (VX-184 U3 —
    /// extracted byte-for-byte so `addTakes`, the batch door, lands each of
    /// its takes through the SAME body): one take at the block's fan END,
    /// parentless, unlocked, labeled `label` (nil/blank = unlabeled).
    func insertSuggestedTake(_ db: Database, blockID: String, text: String, label: String?) throws -> Variant {
        _ = try liveBlock(db, blockID)
        try ensurePlacementUnlocked(db, blockID: blockID)
        let now = date.now
        // VX-357: U+0000 removed from the text and the label (`StoredText`),
        // so the returned row — what the wire digests — is what is stored.
        let trimmed = StoredText.stripped(label)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let take = Variant(
            id: newID(), blockId: blockID, parentVariantId: nil,
            workingText: StoredText.stripped(text), status: .active, locked: false,
            label: (trimmed?.isEmpty ?? true) ? nil : trimmed,
            fanPosition: try fanPosition(db, blockID: blockID, at: .end),
            createdAt: now, updatedAt: now)
        try take.insert(db)
        return take
    }

    /// Returns the stamp it tombstoned on — nil when already gone (VX-246 U2).
    func revertAddedTake(_ takeID: String) throws -> String? {
        try database.write { db in try revertAddedTake(db, takeID) }
    }

    /// `revertAddedTake`'s body inside the caller's transaction (VX-184 U3 —
    /// the batch's ONE inverse walks every take back in one transaction).
    @discardableResult
    func revertAddedTake(_ db: Database, _ takeID: String) throws -> String? {
        guard var take = try Variant.fetchOne(db, key: takeID), take.deletedAt == nil
        else { return nil }  // already gone — the world moved past this entry
        try ensurePlacementUnlocked(db, blockID: take.blockId)
        let chosenBy = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM container_block WHERE chosen_variant_id = ? AND deleted_at IS NULL",
            arguments: [takeID]) ?? 0
        guard chosenBy == 0 else { throw OperationError.variantIsChosen(id: takeID) }
        try ensureNotLastActive(db, take)
        let now = date.now
        take.deletedAt = now
        take.updatedAt = now
        try take.update(db)
        try reassignDefaultIfNeeded(db, blockID: take.blockId, removing: takeID, now: now)
        return DateFormatter.variorumISO8601.string(from: now)
    }

    /// Revives the take only while it is dead on `stamp` — the stamp its own
    /// undo wrote (VX-246 U2); returns whether it did.
    func reapplyAddedTake(_ takeID: String, undoneOn stamp: String?) throws -> Bool {
        try database.write { db in try reapplyAddedTake(db, takeID, undoneOn: stamp) }
    }

    /// `reapplyAddedTake`'s body inside the caller's transaction (VX-184 U3).
    @discardableResult
    func reapplyAddedTake(_ db: Database, _ takeID: String, undoneOn stamp: String?) throws -> Bool {
        guard let stamp,
              var take = try Variant.fetchOne(db, key: takeID),
              take.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp,
              let block = try Block.fetchOne(db, key: take.blockId), block.deletedAt == nil
        else { return false }
        try ensurePlacementUnlocked(db, blockID: take.blockId)
        take.deletedAt = nil
        take.updatedAt = date.now
        try take.update(db)
        try voidPurgeIntents(db, table: "variant", rowID: takeID)
        return true
    }

    // MARK: - SUGGEST: a comment

    /// `addBlockComment`'s act (its refusals: a dead block, a sealed note,
    /// blank text), with the undo entry: the comment tombstoned (it stays on
    /// the block's deleted-comments surface), the redo flipping it back.
    ///
    /// VX-184 U3 (VX-188, R-VX188-1): `author` — the client, as it names
    /// itself — is put on file as the comment's writer in the SAME transaction
    /// (`mcp_comment_author`, local-only), so the suggest rung's
    /// `delete_comment` can later know the comment as the client's own. The
    /// record outlives an undo (it is a fact of who wrote it).
    @discardableResult
    public func addComment(
        toBlock blockID: String, text: String, author client: String, undoLabel: String
    ) throws -> BlockComment {
        let comment = try database.write { db in
            let comment = try insertBlockComment(db, to: blockID, text: text)
            try recordMCPCommentAuthor(db, commentID: comment.id, client: client, text: comment.text)
            return comment
        }
        let commentID = comment.id
        // VX-246 U2: the stamp-keyed revive (`addTake`'s reason).
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertAddedComment(commentID) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyAddedComment(commentID, undoneOn: undoneOn.value) })
        return comment
    }

    /// Returns the stamp it tombstoned on — nil when already gone (VX-246 U2).
    func revertAddedComment(_ commentID: String) throws -> String? {
        try database.write { db in try revertAddedComment(db, commentID) }
    }

    /// `revertAddedComment`'s body inside the caller's transaction (VX-184 U3).
    @discardableResult
    func revertAddedComment(_ db: Database, _ commentID: String) throws -> String? {
        guard var comment = try BlockComment.fetchOne(db, key: commentID), comment.deletedAt == nil
        else { return nil }
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        let now = date.now
        comment.deletedAt = now
        comment.updatedAt = now
        try comment.update(db)
        return DateFormatter.variorumISO8601.string(from: now)
    }

    /// Revives the comment only while it is dead on `stamp` — the stamp its
    /// own undo wrote (VX-246 U2); returns whether it did.
    func reapplyAddedComment(_ commentID: String, undoneOn stamp: String?) throws -> Bool {
        try database.write { db in try reapplyAddedComment(db, commentID, undoneOn: stamp) }
    }

    /// `reapplyAddedComment`'s body inside the caller's transaction (VX-184 U3).
    @discardableResult
    func reapplyAddedComment(_ db: Database, _ commentID: String, undoneOn stamp: String?) throws -> Bool {
        guard let stamp,
              var comment = try BlockComment.fetchOne(db, key: commentID),
              comment.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp,
              let block = try Block.fetchOne(db, key: comment.blockId), block.deletedAt == nil
        else { return false }
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        comment.deletedAt = nil
        comment.updatedAt = date.now
        try comment.update(db)
        // VX-179: the redo is a REVIVE road for a comment, and a comment
        // the undo tombstoned can be given "Delete forever…" in the fold
        // before ⇧⌥⌘Z — so the B1 belt rides here exactly as it does on
        // `reapplyAddedTake` and `restoreBlockComment`.
        try voidPurgeIntents(db, table: "block_comment", rowID: commentID)
        return true
    }

    // MARK: - SUGGEST: a saved lens

    /// **A new lens on a note, with its picks** — `picks` maps a block to
    /// the take the lens shows there (one per block by construction). Every
    /// pick is validated exactly as `setLensChoice` validates it (the take
    /// live and ACTIVE, of a block live-placed in THIS note). Lens CRUD's
    /// seal posture rides (allowed under a seal — "a saved way of looking").
    /// A lens is NEVER rendering truth: nothing here touches a placement's
    /// chosen take. ONE transaction, ONE undo entry: the lens tombstoned
    /// (its choices cascade on its exact stamp by trigger), the redo flipping
    /// the lens and those stamp-matched choices back.
    @discardableResult
    public func saveLens(
        post postID: String, name: String, picks: [String: String], undoLabel: String
    ) throws -> Lens {
        let lens: Lens = try database.write { db in
            _ = try livePost(db, postID)
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            guard !trimmed.isEmpty else { throw OperationError.invalidLensName(name: name) }
            for (blockID, takeID) in picks {
                _ = try liveBlock(db, blockID)
                guard let placement = try livePlacement(db, blockID: blockID),
                      placement.containerId == postID
                else { throw OperationError.blockNotInContainer(blockID: blockID, containerID: postID) }
                let take = try liveVariant(db, takeID)
                guard take.blockId == blockID else { throw OperationError.variantNotFound(id: takeID) }
                guard take.status == .active else { throw OperationError.archivedVariant(id: takeID) }
            }
            let now = date.now
            let lens = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: postID,
                name: trimmed, createdAt: now, updatedAt: now)
            try lens.insert(db)
            for blockID in picks.keys.sorted() {
                try LensChoice(
                    id: newID(), lensId: lens.id, blockId: blockID, variantId: picks[blockID] ?? "",
                    createdAt: now, updatedAt: now
                ).insert(db)
            }
            return lens
        }
        let lensID = lens.id
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertSavedLens(lensID) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplySavedLens(lensID, undoneOn: undoneOn.value) })
        return lens
    }

    /// Tombstones the lens (its live choices cascade on the same stamp);
    /// returns the stamp written, nil when it was already gone.
    func revertSavedLens(_ lensID: String) throws -> String? {
        try database.write { db in try tombstoneSavedLens(db, lensID) }
    }

    /// The lens back, with exactly the choices that died on the undo's stamp.
    @discardableResult
    func reapplySavedLens(_ lensID: String, undoneOn stamp: String?) throws -> Bool {
        guard let stamp else { return false }
        return try database.write { db in try reviveSavedLens(db, lensID, undoneOn: stamp) }
    }

    /// `revertSavedLens`' body inside the caller's transaction (VX-168 U2 —
    /// the lens adoption's undo tombstones its preservation lens in the SAME
    /// transaction as its pointers).
    func tombstoneSavedLens(_ db: Database, _ lensID: String) throws -> String? {
        guard var lens = try Lens.fetchOne(db, key: lensID), lens.deletedAt == nil else { return nil }
        let now = date.now
        lens.deletedAt = now
        lens.updatedAt = now
        try lens.update(db)
        return DateFormatter.variorumISO8601.string(from: now)
    }

    /// `reapplySavedLens`' body inside the caller's transaction (VX-168 U2).
    @discardableResult
    func reviveSavedLens(_ db: Database, _ lensID: String, undoneOn stamp: String) throws -> Bool {
        guard var lens = try Lens.fetchOne(db, key: lensID),
              let deletedAt = lens.deletedAt,
              DateFormatter.variorumISO8601.string(from: deletedAt) == stamp,
              try Container.fetchOne(db, key: lens.containerId)?.deletedAt == nil
        else { return false }
        let now = DateFormatter.variorumISO8601.string(from: date.now)
        lens.deletedAt = nil
        lens.updatedAt = date.now
        try lens.update(db)
        try db.execute(
            sql: """
                UPDATE lens_choice SET deleted_at = NULL, updated_at = ?
                WHERE lens_id = ? AND deleted_at = ?
                """,
            arguments: [now, lensID, stamp])
        return true
    }

    // MARK: - WRITE NEW: a note (plain prose, or one Level 0 document)

    /// **A note from plain prose**: `text` segments into blocks by the bulk
    /// rule under the library's own default (`SegmentationRules.bulkSegments`
    /// + `Queries.defaultSegmentation` — paste's road, so a client's note
    /// reads exactly as hers would pasted); an empty text mints an empty
    /// note (⌘N's shape). Lands per `destination`; ONE undo entry.
    ///
    /// `entryDate` (13n-b U3 — R-13nb-26 (b), her words: *"agents should be
    /// able to set the date on a note"*): the minted note's date, `yyyy-MM-dd`
    /// (a malformed key refuses `invalidEntryDate` and mints nothing), set in
    /// the same transaction.
    ///
    /// `section` (VX-252 — VX-336 U5b D2): file the new membership under that
    /// CHAPTER of the destination book in the same transaction — a live section
    /// of THAT book (`sectionNotFound` / `sectionNotInReading`, checked before
    /// anything is minted; a wing destination has no chapter). The note's ONE
    /// undo entry takes the filing with it, and the redo returns it filed.
    @discardableResult
    public func createNote(
        title: String?, text: String, entryDate: String? = nil, in destination: MCPNoteDestination,
        section: String? = nil, undoLabel: String
    ) throws -> DocumentImport {
        try mintNoteEntry(undoLabel: undoLabel, section: section) { db in
            // VX-357: U+0000 removed before segmenting and trimming
            // (`StoredText`) — `importPost`'s reason, paste's road.
            let blocks = SegmentationRules
                .bulkSegments(StoredText.stripped(text), mode: try Queries.defaultSegmentation(db))
                .map { VariorumDocument.Block(text: $0) }
            let trimmed = StoredText.stripped(title)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return VariorumDocument.NamedDocument(
                fallbackTitle: "",
                document: VariorumDocument.Document(
                    title: (trimmed?.isEmpty ?? true) ? nil : trimmed, tagPaths: [], blocks: blocks))
        } destination: { destination } finish: { db, minted in
            try stampEntryDate(db, entryDate, on: minted.post.id)
        }
    }

    // MARK: - WRITE NEW: a note from the wire document (13n-b U3)

    /// One block of a STRUCTURED note — the wire-document subset (R-13nb-11
    /// G-2): its shown text (multi-paragraph welcome — a blank line inside it
    /// is content, never a boundary), an optional name, and labeled takes
    /// joining its fan unchosen.
    public struct MCPNoteBlock: Equatable, Sendable {
        public var text: String
        public var name: String?
        public var takes: [VariorumDocument.Take]

        public init(text: String, name: String? = nil, takes: [VariorumDocument.Take] = []) {
            self.text = text
            self.name = name
            self.takes = takes
        }
    }

    /// **`create_note`'s structured payload** (R-13nb-11 G-2 + R-13nb-26
    /// (b)): the note minted through the SAME road as a Level 0 import
    /// (`mintDocument` — each block's text chosen AND default, its takes at
    /// the fan's end unchosen with their labels, touch without churn), with
    /// what the text format cannot carry set in the same transaction: each
    /// block's NAME and the note's ENTRY DATE. Lands per `destination`
    /// exactly as `createNote`; ONE undo entry (the minted note, whole).
    ///
    /// VX-168 U3 (VX-171 — R-VX171-2, her word, door-only): a take whose text
    /// is EMPTY mints a BLANK take at its place in the fan — a legal take (the
    /// Mac's own blank-take gesture), the one a lens points at to show the
    /// block as an empty line. Until this unit it was silently DROPPED (the
    /// format's rule, P-13nb-U3-9's "empty-text takes drop" — superseded at
    /// this door only; the file doors keep it).
    ///
    /// `section` (VX-252): `createNote`'s — the chapter of the destination book.
    @discardableResult
    public func createStructuredNote(
        title: String?, entryDate: String?, blocks: [MCPNoteBlock],
        in destination: MCPNoteDestination, section: String? = nil, undoLabel: String
    ) throws -> DocumentImport {
        // VX-357: the title's and each block name's U+0000 removed here
        // (`StoredText`); the takes' texts and labels at the row (`mintFanBlock`).
        let trimmed = StoredText.stripped(title)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let document = VariorumDocument.NamedDocument(
            fallbackTitle: "",
            document: VariorumDocument.Document(
                title: (trimmed?.isEmpty ?? true) ? nil : trimmed, tagPaths: [],
                blocks: blocks.map { VariorumDocument.Block(text: $0.text, alternates: $0.takes) }))
        return try mintNoteEntry(
            undoLabel: undoLabel, keepingBlankTakes: true, section: section
        ) { _ in document } destination: { destination } finish: { db, minted in
            for (blockID, block) in zip(minted.blockIDs, blocks) {
                let name = StoredText.stripped(block.name)?.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let name, !name.isEmpty else { continue }
                try db.execute(sql: "UPDATE block SET name = ? WHERE id = ?", arguments: [name, blockID])
            }
            try stampEntryDate(db, entryDate, on: minted.post.id)
        }
    }

    /// The day key's boundary is the op's own (Phase 9b — `setEntryDate`,
    /// `createOrOpenJournalEntry`): canonical `yyyy-MM-dd` or a refusal that
    /// rolls the whole mint back, never a permissive door.
    private func stampEntryDate(_ db: Database, _ entryDate: String?, on postID: String) throws {
        guard let entryDate else { return }
        guard JournalDay.isValid(entryDate) else { throw OperationError.invalidEntryDate(entryDate) }
        try db.execute(sql: "UPDATE container SET entry_date = ? WHERE id = ?", arguments: [entryDate, postID])
    }

    /// **One Level 0 document as a note** — `importDocument`'s mint (the
    /// format's exact inverse: in-place text chosen AND default, labeled
    /// alternates joining the fan unchosen, header tags adopted-or-minted by
    /// path through the one application road), landing per `destination`
    /// (a book's member at its end — the hand-add's choke point, its gates
    /// and outflow riding — or bookless in a wing). ONE undo entry.
    @discardableResult
    public func importNote(
        _ named: VariorumDocument.NamedDocument, in destination: MCPNoteDestination, undoLabel: String
    ) throws -> DocumentImport {
        try mintNoteEntry(undoLabel: undoLabel, document: { _ in named }, destination: { destination })
    }

    /// `finish` (13n-b U3): what the format cannot carry (block names, the
    /// entry date), written on the minted rows in the SAME transaction,
    /// before the note joins a book (so the hand-add's gates see the note
    /// as it will stand).
    /// `section` (VX-252): the chapter of the destination BOOK the membership
    /// is filed under — her New Note in a Book's order (`newPostInReading`):
    /// the book's gates, then the chapter, checked BEFORE the mint; the pointer
    /// rides the membership row the hand-add wrote, in this transaction.
    private func mintNoteEntry(
        undoLabel: String,
        keepingBlankTakes: Bool = false,
        section sectionID: String? = nil,
        document: (Database) throws -> VariorumDocument.NamedDocument,
        destination: () -> MCPNoteDestination,
        finish: (Database, MintedDocument) throws -> Void = { _, _ in }
    ) throws -> DocumentImport {
        let result: DocumentImport = try database.write { db in
            let named = try document(db)
            let wing: String
            var bookID: String?
            var outflow: [String] = []
            switch destination() {
            case .book(let id):
                let book = try liveReading(db, id)
                guard book.kind == .book else { throw OperationError.wrongReadingKind(id: id, expected: .book) }
                guard !book.locked else { throw OperationError.lockedReading(id: id) }
                if let sectionID {
                    let section = try liveSection(db, sectionID)
                    guard section.readingId == id else {
                        throw OperationError.sectionNotInReading(sectionID: sectionID, readingID: id)
                    }
                }
                wing = try Queries.wingIsLive(db, id: book.wingId) ? book.wingId : ""
                bookID = id
                outflow = book.autoTagIDs
            case .wing(let id):
                // A wing holds no chapters: a section here names none.
                if let sectionID { throw OperationError.sectionNotFound(id: sectionID) }
                try requireLiveWing(db, id)
                wing = id
            }
            let now = date.now
            let minted = try mintDocument(db, named, wingId: wing, now: now, keepingBlankTakes: keepingBlankTakes)
            try finish(db, minted)
            if let bookID {
                // The hand-add's ONE choke point (its capacity and ownership
                // gates, its outflow) — BEFORE the header's tags, so this
                // book's own pair is decided and the tagging act is heard by
                // the OTHER living books (`newPostInReading`'s order).
                var membership = try addPostToReading(db, minted.post.id, to: bookID, at: .end)
                if let sectionID {
                    membership.sectionId = sectionID
                    try membership.update(db)
                }
            }
            let header = try applyDocumentTags(
                db, named.document.tagPaths, to: minted.post.id, wingId: wing, now: now)
            let worn = try mintedNoteTags(db, postID: minted.post.id, header: header.map(\.id), outflow: outflow)
            return DocumentImport(
                post: minted.post, blockIDs: minted.blockIDs, alternateCount: minted.alternateCount,
                tagIDs: worn.map(\.id), tagPaths: worn.map(\.path), blocks: minted.blocks)
        }
        let postID = result.post.id
        registerMintedContainerEntry(label: undoLabel, postID)
        return result
    }

    /// **VX-361 — every tag the minted note wears when the act lands** (the
    /// VX-336 run record's U9 D1 + F-1 (a), PROVISIONAL P-VX361-1): the
    /// header's tags in header order — one the book's outflow also applied is
    /// listed once, at its header place — then the rest in the destination
    /// book's OUTFLOW order (`autoTagIDs`), and last (a belt: nothing else in
    /// this act tags the note — intake SEATS, it never applies an outflow) any
    /// other by path. Read inside the act's transaction from the note's own
    /// live applications: ∝ what this act applied, never the corpus (P1), and
    /// never a read after the commit (no race — U5b's D1).
    ///
    /// VX-371 (VX-383 U2): shared with `duplicate_note`, whose "header" is the
    /// tags its copy was APPLIED from the source (application order) — so the
    /// two answers list a note's tags by ONE rule (P-VX361-1's shape).
    func mintedNoteTags(
        _ db: Database, postID: String, header: [String], outflow: [String]
    ) throws -> [(id: String, path: String)] {
        var paths: [String: String] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT t.id, t.path FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                """,
            arguments: [postID]) {
            paths[row["id"]] = row["path"]
        }
        var worn: [(id: String, path: String)] = []
        func list(_ id: String) {
            guard let path = paths.removeValue(forKey: id) else { return }
            worn.append((id, path))
        }
        header.forEach(list)
        outflow.forEach(list)
        paths.sorted { ($0.value, $0.key) < ($1.value, $1.key) }.forEach { worn.append(($0.key, $0.value)) }
        return worn
    }

    // MARK: - WRITE NEW: a whole book (the bulk door)

    /// `importBook`'s act (a new unshelved book in `wingId`, chapters and
    /// seated notes, the E13 name guard) with its ONE entry relabeled for the
    /// client — the bulk door that undoes in a single press (R-13n-6).
    /// VX-363: `namesCountedBy` — the readings the name guard counts (the wire
    /// passes the ones the client can READ, VX-259's rule); nil counts every
    /// reading.
    @discardableResult
    public func importBook(
        _ book: VariorumDocument.Book, wingId: String, undoLabel: String, namesCountedBy reach: BookNameReach? = nil
    ) throws -> BookImport {
        guard let undoStack else { return try importBook(book, wingId: wingId, shelfId: nil, namesCountedBy: reach) }
        return try undoStack.withCompound(label: undoLabel, operations: self) {
            try importBook(book, wingId: wingId, shelfId: nil, namesCountedBy: reach)
        }
    }

    // MARK: - WRITE NEW: a tag

    /// **A tag applied to a note BY PATH** — adopted-else-minted in the
    /// note's wing (R-13ia-1's one rule, `adoptPath`), applied through the
    /// ONE application road (`insertPostTag` — every living book whose rule
    /// hears the tag decides by it, exactly as when she tags). Refuses a path
    /// naming nothing (`invalidTagName`) and a tag already applied
    /// (`alreadyTagged`). ONE undo entry: the APPLICATION tombstoned — the
    /// un-tag road, a non-event for intake (§19: removing a tag never evicts;
    /// a seat the tagging caused stays, PROVISIONAL P-13nb-U2-6), and a tag
    /// the act minted stays as vocabulary (13n-a's precedent, AppSpec §9).
    @discardableResult
    public func applyTagPath(_ path: String, toPost postID: String, undoLabel: String) throws -> PostTag {
        let application: PostTag = try database.write { db in
            let post = try livePost(db, postID)
            let segments = TagPath.segments(path)
            guard !segments.isEmpty else { throw OperationError.invalidTagName(name: path) }
            let wing = try Queries.wingIsLive(db, id: post.wingId) ? post.wingId : ""
            var adoption = TagAdoption(wing: wing)
            guard let tag = try adoptPath(db, segments.joined(separator: "/"), &adoption) else {
                throw OperationError.invalidTagName(name: path)
            }
            guard try liveApplication(db, table: "post_tag", tagID: tag.id,
                                      targetColumn: "post_id", targetID: postID) == nil
            else { throw OperationError.alreadyTagged(tagID: tag.id, targetID: postID) }
            return try insertPostTag(db, tagID: tag.id, postID: postID, now: date.now)
        }
        let applicationID = application.id
        // VX-246 U2: the redo revives the application only on the stamp its
        // own undo wrote — her un-tag since tombstoned the very row on HER
        // stamp, and that is not the undo's to bring back.
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertAppliedTag(applicationID) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyAppliedTag(applicationID, undoneOn: undoneOn.value) })
        return application
    }

    // MARK: - EDIT: a tag removed (VX-184 U3 — VX-190)

    /// What `removeTagForClient` took off.
    public struct MCPTagRemoval: Equatable, Sendable {
        public let applicationID: String
        public let tagID: String
        /// The tag's path as the library stores it.
        public let path: String
    }

    /// **`remove_tag`'s act — her un-tag, by PATH**: the caller's guard first;
    /// the note live; the path resolved among the LIVE tags of the note's own
    /// wing (as `applyTagPath` adopts — never minted here; a path naming none
    /// is `tagNotApplied`, the same answer as a tag the note doesn't wear; a
    /// path with no segment is `invalidTagName`); then `removeTag`'s own row
    /// body (`removePostTagApplication`) — the application tombstoned, the
    /// tag kept as vocabulary, NO intake (un-tag is a non-event, §19). Tags
    /// stay free under a seal, as her own un-tag does. ONE undo entry,
    /// `undoLabel`: the inverse revives the very application (`apply_tag`'s
    /// redo body — an exact-row revival is no applying act, so it seats
    /// nothing), the redo tombstones it again.
    @discardableResult
    public func removeTagForClient(
        path: String, fromNote postID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTagRemoval {
        let (removal, removedAt): (MCPTagRemoval, String?) = try database.write { db in
            try guardian?(db)
            let post = try livePost(db, postID)
            let segments = TagPath.segments(path)
            guard !segments.isEmpty else { throw OperationError.invalidTagName(name: path) }
            let normalized = segments.joined(separator: "/")
            let wing = try Queries.wingIsLive(db, id: post.wingId) ? post.wingId : ""
            guard let tagID = try String.fetchOne(
                db, sql: "SELECT id FROM tag WHERE path = ? AND wing_id = ? AND deleted_at IS NULL",
                arguments: [normalized, wing])
            else { throw OperationError.tagNotApplied(tagID: normalized, targetID: postID) }
            let applicationID = try removePostTagApplication(db, tagID: tagID, postID: postID)
            let removedAt = try String.fetchOne(
                db, sql: "SELECT deleted_at FROM post_tag WHERE id = ?", arguments: [applicationID])
            return (MCPTagRemoval(applicationID: applicationID, tagID: tagID, path: normalized), removedAt)
        }
        let applicationID = removal.applicationID
        // VX-246 U2 — the mirror of `applyTagPath`'s entry: the undo revives
        // the application only while it is dead on the stamp the act (then
        // each redo) wrote; the redo re-removes it and records its own stamp.
        let removedOn = LockIsolated(removedAt)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reapplyAppliedTag(applicationID, undoneOn: removedOn.value) },
            redo: { ops in
                guard let stamp = try ops.revertAppliedTag(applicationID) else { return false }
                removedOn.setValue(stamp)
                return true
            })
        return removal
    }

    /// Tombstones the live application; returns the stamp it wrote — nil
    /// when the row was already dead (VX-246 U2: a quiet half).
    func revertAppliedTag(_ applicationID: String) throws -> String? {
        try database.write { db in
            let stamp = DateFormatter.variorumISO8601.string(from: date.now)
            try db.execute(
                sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                arguments: [stamp, applicationID])
            return db.changesCount > 0 ? stamp : nil
        }
    }

    /// Revives the application only while it is dead on `stamp` — the
    /// stamp its partner half wrote (VX-246 U2); returns whether it did.
    @discardableResult
    func reapplyAppliedTag(_ applicationID: String, undoneOn stamp: String?) throws -> Bool {
        guard let stamp else { return false }
        return try database.write { db in
            guard let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT pt.tag_id, pt.post_id FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    JOIN container c ON c.id = pt.post_id AND c.deleted_at IS NULL
                    WHERE pt.id = ? AND pt.deleted_at = ?
                    """,
                arguments: [applicationID, stamp])
            else { return false }
            // A live twin (re-applied by hand since) keeps the pair; this
            // row stays dead (`uq_post_tag_live`).
            guard try liveApplication(db, table: "post_tag", tagID: row["tag_id"],
                                      targetColumn: "post_id", targetID: row["post_id"]) == nil
            else { return false }
            try db.execute(sql: "UPDATE post_tag SET deleted_at = NULL WHERE id = ?", arguments: [applicationID])
            try voidPurgeIntents(db, table: "post_tag", rowID: applicationID)
            return true
        }
    }

    // MARK: - WRITE NEW: a book

    /// **A new, empty, unshelved BOOK in a wing** — no rule, not owned, not
    /// private; the E13 door guard (`requireBookNameFree`, inside the act's
    /// transaction) refuses a name a live book wears; a blank name reads as
    /// the placeholder (`importBook`'s precedent). ONE undo entry: the book
    /// tombstoned (memberships filed since die with it on its stamp and come
    /// back with it — `revertImportedBook`'s body over no notes), the redo
    /// reviving exactly that stamp.
    /// VX-259: `namesCountedBy` — the readings the guard counts (the wire
    /// passes the ones the client can READ — her ruling: an accidental
    /// duplicate is fine, an oracle is not); nil counts every reading.
    @discardableResult
    public func createBook(
        named name: String, inWing wingId: String, undoLabel: String, namesCountedBy reach: BookNameReach? = nil
    ) throws -> Reading {
        let reading: Reading = try database.write { db in
            try requireLiveWing(db, wingId)
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            let bookName = trimmed.isEmpty ? DisplayTitle.placeholder : trimmed
            try requireBookNameFree(db, bookName, counting: reach)
            let now = date.now
            let reading = Reading(
                id: newID(), ownerId: currentOwnerID(), name: bookName, kind: .book,
                wingId: wingId, createdAt: now, updatedAt: now)
            try reading.insert(db)
            return reading
        }
        let readingID = reading.id
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertImportedBook(readingID, posts: []) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyImportedBook(readingID, posts: [], undoneOn: undoneOn.value) })
        return reading
    }

    // MARK: - WRITE NEW: a note into a book

    /// **`addPostToReading`'s act** — the ONE hand-add choke point, every
    /// gate and refusal its own (a gathering, a finished book, capacity, a
    /// note of another wing, and the ownership consult's
    /// `noteMemberedElsewhere` / `noteOwnedElsewhere`, which speak to the
    /// client as to her). ONE undo entry, exact-row: a fresh membership is
    /// tombstoned (member-class — the remove road); a waiting ARRIVAL the add
    /// seated goes back to waiting where it waited. The book's outflow tags
    /// stay (removing from a book never untags). Redo: the same row back.
    ///
    /// **`section` (13n-b U3 — R-13nb-11 G-1):** file the new membership
    /// under that CHAPTER in the same transaction — a live section of THIS
    /// book (`assignPostToSection`'s checks: `sectionNotFound` /
    /// `sectionNotInReading`); the entry's exact rows carry it, so undo
    /// and redo take the chapter with the membership.
    @discardableResult
    public func addNoteToBook(
        _ postID: String, book bookID: String, section sectionID: String? = nil, undoLabel: String
    ) throws -> ReadingPost {
        try addNoteToBookForClient(postID, book: bookID, section: sectionID, undoLabel: undoLabel).membership
    }

    /// **What `add_note_to_book` landed** (VX-365 — RUN VX-548 batch 2a; the
    /// VX-336 U9 record's OWED 4): the membership, and EVERY tag the note
    /// wears once the act lands — VX-361's one rule (`mintedNoteTags`,
    /// P-VX361-1's shape): the note's own tags first, in the order they were
    /// applied (read BEFORE the add), then the book's OUTFLOW in its order
    /// (the hand-add's `applyAutoTag`), each listed once at its first place;
    /// `tagPaths` parallel. Read inside the act's transaction — ∝ the note's
    /// own applications, never a read after the commit (U5b's D1: no race).
    public struct MCPBookAdd: Equatable, Sendable {
        public let membership: ReadingPost
        public let tagIDs: [String]
        public let tagPaths: [String]
    }

    /// `addNoteToBook`'s act with its answered facts (VX-365) — the SAME body
    /// and the SAME one undo entry; `addNoteToBook` is this act's membership.
    @discardableResult
    public func addNoteToBookForClient(
        _ postID: String, book bookID: String, section sectionID: String? = nil, undoLabel: String
    ) throws -> MCPBookAdd {
        let (membership, prior, worn): (ReadingPost, ReadingPost?, [(id: String, path: String)]) =
            try database.write { db in
            let prior = try livePairRow(db, postID: postID, readingID: bookID)
            // The note's own tags, in application order, as they stand BEFORE
            // the add's outflow lands (`liveTagIDs`' order, any wing — what
            // the note wears is what the answer says).
            let own = try String.fetchAll(
                db,
                sql: """
                    SELECT pt.tag_id FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                    ORDER BY pt.created_at, pt.id
                    """,
                arguments: [postID])
            var membership = try addPostToReading(db, postID, to: bookID, at: .end)
            if let sectionID {
                let section = try liveSection(db, sectionID)
                guard section.readingId == bookID else {
                    throw OperationError.sectionNotInReading(sectionID: sectionID, readingID: bookID)
                }
                membership.sectionId = sectionID
                try membership.update(db)
            }
            let outflow = try liveReading(db, bookID).autoTagIDs
            let worn = try mintedNoteTags(db, postID: postID, header: own, outflow: outflow)
            return (membership, prior, worn)
        }
        let landed = membership
        // VX-246 U2: the redo re-applies only over what its undo left — the
        // row back at the door as `prior` (the seat case), or dead on the
        // undo's own stamp (a fresh membership). Her dismissal at the door,
        // or a tombstone on another stamp, since the undo is hers to keep.
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let undone = try ops.revertAddedMembership(landed, waitingAs: prior) else { return false }
                undoneOn.setValue(undone)
                return true
            },
            redo: { try $0.reapplyAddedMembership(landed, waitingAs: prior, undoneOn: undoneOn.value) })
        return MCPBookAdd(membership: membership, tagIDs: worn.map(\.id), tagPaths: worn.map(\.path))
    }

    ///
    /// Returns what it did, for the redo (VX-246 U2): the stamp it tombstoned
    /// a fresh membership on, `""` when it demoted a seat back to the door,
    /// nil when it found nothing of the act's to undo (quiet).
    func revertAddedMembership(_ landed: ReadingPost, waitingAs prior: ReadingPost?) throws -> String? {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: landed.id), row.deletedAt == nil,
                  row.status == .member
            else { return nil }
            let book = try liveReading(db, row.readingId)
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            if let prior {
                row.status = prior.status
                row.position = prior.position
                row.sectionId = prior.sectionId
                try row.update(db)
                return ""
            }
            let now = date.now
            row.deletedAt = now
            try row.update(db)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }

    ///
    /// Keyed on what its undo did (VX-246 U2): a fresh membership revives
    /// only while it is dead on the undo's own stamp (`undoneOn`); a seat
    /// re-seats only while the row still waits at the door exactly as the
    /// undo left it (live, `prior`'s status). Anything else since — her
    /// dismissal, her own removal, another stamp — is not the undo's result,
    /// and the redo is quiet. Returns whether it re-applied.
    @discardableResult
    func reapplyAddedMembership(
        _ landed: ReadingPost, waitingAs prior: ReadingPost?, undoneOn: String?
    ) throws -> Bool {
        guard let undoneOn else { return false }
        return try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: landed.id),
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil,
                  try Container.fetchOne(db, key: row.postId)?.deletedAt == nil
            else { return false }
            if let prior {
                guard row.deletedAt == nil, row.status == prior.status, row.status != .member else { return false }
            } else {
                guard row.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == undoneOn
                else { return false }
            }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            if row.deletedAt != nil {
                // A live twin for the pair (added again since) keeps it.
                guard try livePairRow(db, postID: row.postId, readingID: row.readingId) == nil else { return false }
                row.deletedAt = nil
            }
            row.status = .member
            row.position = landed.position
            row.sectionId = landed.sectionId
            try row.update(db)
            try enforceOwnershipAfterRevival(db, postIDs: [row.postId], now: date.now)
            return true
        }
    }
}
