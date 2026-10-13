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
        // VX-184 U3 — VX-188's suggest-rung delete of a client's OWN comment
        // ("Undo claude-code's comment deletion").
        case commentDelete = "comment deletion"
        // VX-184 U3 — VX-190's edit-rung un-tag ("Undo claude-code's tag removal").
        case untag = "tag removal"
        // VX-184 U3 — VX-187's named-pair version link ("Undo claude-code's version link").
        case versionLink = "version link"

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
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAddedTake(takeID) },
            redo: { try $0.reapplyAddedTake(takeID) })
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
        let trimmed = label?.trimmingCharacters(in: .whitespacesAndNewlines)
        let take = Variant(
            id: newID(), blockId: blockID, parentVariantId: nil,
            workingText: text, status: .active, locked: false,
            label: (trimmed?.isEmpty ?? true) ? nil : trimmed,
            fanPosition: try fanPosition(db, blockID: blockID, at: .end),
            createdAt: now, updatedAt: now)
        try take.insert(db)
        return take
    }

    func revertAddedTake(_ takeID: String) throws {
        try database.write { db in try revertAddedTake(db, takeID) }
    }

    /// `revertAddedTake`'s body inside the caller's transaction (VX-184 U3 —
    /// the batch's ONE inverse walks every take back in one transaction).
    func revertAddedTake(_ db: Database, _ takeID: String) throws {
        guard var take = try Variant.fetchOne(db, key: takeID), take.deletedAt == nil
        else { return }  // already gone — the world moved past this entry
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
    }

    func reapplyAddedTake(_ takeID: String) throws {
        try database.write { db in try reapplyAddedTake(db, takeID) }
    }

    /// `reapplyAddedTake`'s body inside the caller's transaction (VX-184 U3).
    func reapplyAddedTake(_ db: Database, _ takeID: String) throws {
        guard var take = try Variant.fetchOne(db, key: takeID), take.deletedAt != nil,
              let block = try Block.fetchOne(db, key: take.blockId), block.deletedAt == nil
        else { return }
        try ensurePlacementUnlocked(db, blockID: take.blockId)
        take.deletedAt = nil
        take.updatedAt = date.now
        try take.update(db)
        try voidPurgeIntents(db, table: "variant", rowID: takeID)
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
            try recordMCPCommentAuthor(db, commentID: comment.id, client: client)
            return comment
        }
        let commentID = comment.id
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAddedComment(commentID) },
            redo: { try $0.reapplyAddedComment(commentID) })
        return comment
    }

    func revertAddedComment(_ commentID: String) throws {
        try database.write { db in try revertAddedComment(db, commentID) }
    }

    /// `revertAddedComment`'s body inside the caller's transaction (VX-184 U3).
    func revertAddedComment(_ db: Database, _ commentID: String) throws {
        guard var comment = try BlockComment.fetchOne(db, key: commentID), comment.deletedAt == nil
        else { return }
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        let now = date.now
        comment.deletedAt = now
        comment.updatedAt = now
        try comment.update(db)
    }

    func reapplyAddedComment(_ commentID: String) throws {
        try database.write { db in try reapplyAddedComment(db, commentID) }
    }

    /// `reapplyAddedComment`'s body inside the caller's transaction (VX-184 U3).
    func reapplyAddedComment(_ db: Database, _ commentID: String) throws {
        guard var comment = try BlockComment.fetchOne(db, key: commentID), comment.deletedAt != nil,
              let block = try Block.fetchOne(db, key: comment.blockId), block.deletedAt == nil
        else { return }
        try ensurePlacementUnlocked(db, blockID: comment.blockId)
        comment.deletedAt = nil
        comment.updatedAt = date.now
        try comment.update(db)
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
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
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
                if let stamp = try ops.revertSavedLens(lensID) { undoneOn.setValue(stamp) }
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
    func reapplySavedLens(_ lensID: String, undoneOn stamp: String?) throws {
        guard let stamp else { return }
        try database.write { db in try reviveSavedLens(db, lensID, undoneOn: stamp) }
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
    func reviveSavedLens(_ db: Database, _ lensID: String, undoneOn stamp: String) throws {
        guard var lens = try Lens.fetchOne(db, key: lensID),
              let deletedAt = lens.deletedAt,
              DateFormatter.variorumISO8601.string(from: deletedAt) == stamp,
              try Container.fetchOne(db, key: lens.containerId)?.deletedAt == nil
        else { return }
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
    @discardableResult
    public func createNote(
        title: String?, text: String, entryDate: String? = nil, in destination: MCPNoteDestination,
        undoLabel: String
    ) throws -> DocumentImport {
        try mintNoteEntry(undoLabel: undoLabel) { db in
            let blocks = SegmentationRules
                .bulkSegments(text, mode: try Queries.defaultSegmentation(db))
                .map { VariorumDocument.Block(text: $0) }
            let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
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
    @discardableResult
    public func createStructuredNote(
        title: String?, entryDate: String?, blocks: [MCPNoteBlock],
        in destination: MCPNoteDestination, undoLabel: String
    ) throws -> DocumentImport {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let document = VariorumDocument.NamedDocument(
            fallbackTitle: "",
            document: VariorumDocument.Document(
                title: (trimmed?.isEmpty ?? true) ? nil : trimmed, tagPaths: [],
                blocks: blocks.map { VariorumDocument.Block(text: $0.text, alternates: $0.takes) }))
        return try mintNoteEntry(
            undoLabel: undoLabel, keepingBlankTakes: true
        ) { _ in document } destination: { destination } finish: { db, minted in
            for (blockID, block) in zip(minted.blockIDs, blocks) {
                let name = block.name?.trimmingCharacters(in: .whitespacesAndNewlines)
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
    private func mintNoteEntry(
        undoLabel: String,
        keepingBlankTakes: Bool = false,
        document: (Database) throws -> VariorumDocument.NamedDocument,
        destination: () -> MCPNoteDestination,
        finish: (Database, MintedDocument) throws -> Void = { _, _ in }
    ) throws -> DocumentImport {
        let result: DocumentImport = try database.write { db in
            let named = try document(db)
            let wing: String
            var bookID: String?
            switch destination() {
            case .book(let id):
                let book = try liveReading(db, id)
                guard book.kind == .book else { throw OperationError.wrongReadingKind(id: id, expected: .book) }
                guard !book.locked else { throw OperationError.lockedReading(id: id) }
                wing = try Queries.wingIsLive(db, id: book.wingId) ? book.wingId : ""
                bookID = id
            case .wing(let id):
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
                _ = try addPostToReading(db, minted.post.id, to: bookID, at: .end)
            }
            let tagIDs = try applyDocumentTags(
                db, named.document.tagPaths, to: minted.post.id, wingId: wing, now: now)
            return DocumentImport(
                post: minted.post, blockIDs: minted.blockIDs,
                alternateCount: minted.alternateCount, tagIDs: tagIDs)
        }
        let postID = result.post.id
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertMintedContainer(postID) },
            redo: { try $0.reapplyMintedContainer(postID) })
        return result
    }

    // MARK: - WRITE NEW: a whole book (the bulk door)

    /// `importBook`'s act (a new unshelved book in `wingId`, chapters and
    /// seated notes, the E13 name guard) with its ONE entry relabeled for the
    /// client — the bulk door that undoes in a single press (R-13n-6).
    @discardableResult
    public func importBook(
        _ book: VariorumDocument.Book, wingId: String, undoLabel: String
    ) throws -> BookImport {
        guard let undoStack else { return try importBook(book, wingId: wingId, shelfId: nil) }
        return try undoStack.withCompound(label: undoLabel, operations: self) {
            try importBook(book, wingId: wingId, shelfId: nil)
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
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAppliedTag(applicationID) },
            redo: { try $0.reapplyAppliedTag(applicationID) })
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
        let removal: MCPTagRemoval = try database.write { db in
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
            return MCPTagRemoval(applicationID: applicationID, tagID: tagID, path: normalized)
        }
        let applicationID = removal.applicationID
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.reapplyAppliedTag(applicationID) },
            redo: { try $0.revertAppliedTag(applicationID) })
        return removal
    }

    func revertAppliedTag(_ applicationID: String) throws {
        try database.write { db in
            try db.execute(
                sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), applicationID])
        }
    }

    func reapplyAppliedTag(_ applicationID: String) throws {
        try database.write { db in
            guard let row = try Row.fetchOne(
                db,
                sql: """
                    SELECT pt.tag_id, pt.post_id FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    JOIN container c ON c.id = pt.post_id AND c.deleted_at IS NULL
                    WHERE pt.id = ? AND pt.deleted_at IS NOT NULL
                    """,
                arguments: [applicationID])
            else { return }
            // A live twin (re-applied by hand since) keeps the pair; this
            // row stays dead (`uq_post_tag_live`).
            guard try liveApplication(db, table: "post_tag", tagID: row["tag_id"],
                                      targetColumn: "post_id", targetID: row["post_id"]) == nil
            else { return }
            try db.execute(sql: "UPDATE post_tag SET deleted_at = NULL WHERE id = ?", arguments: [applicationID])
            try voidPurgeIntents(db, table: "post_tag", rowID: applicationID)
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
    @discardableResult
    public func createBook(named name: String, inWing wingId: String, undoLabel: String) throws -> Reading {
        let reading: Reading = try database.write { db in
            try requireLiveWing(db, wingId)
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let bookName = trimmed.isEmpty ? DisplayTitle.placeholder : trimmed
            try requireBookNameFree(db, bookName)
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
                if let stamp = try ops.revertImportedBook(readingID, posts: []) { undoneOn.setValue(stamp) }
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
        let (membership, prior): (ReadingPost, ReadingPost?) = try database.write { db in
            let prior = try livePairRow(db, postID: postID, readingID: bookID)
            var membership = try addPostToReading(db, postID, to: bookID, at: .end)
            if let sectionID {
                let section = try liveSection(db, sectionID)
                guard section.readingId == bookID else {
                    throw OperationError.sectionNotInReading(sectionID: sectionID, readingID: bookID)
                }
                membership.sectionId = sectionID
                try membership.update(db)
            }
            return (membership, prior)
        }
        let landed = membership
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAddedMembership(landed, waitingAs: prior) },
            redo: { try $0.reapplyAddedMembership(landed) })
        return membership
    }

    func revertAddedMembership(_ landed: ReadingPost, waitingAs prior: ReadingPost?) throws {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: landed.id), row.deletedAt == nil,
                  row.status == .member
            else { return }
            let book = try liveReading(db, row.readingId)
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            if let prior {
                row.status = prior.status
                row.position = prior.position
                row.sectionId = prior.sectionId
            } else {
                row.deletedAt = date.now
            }
            try row.update(db)
        }
    }

    func reapplyAddedMembership(_ landed: ReadingPost) throws {
        try database.write { db in
            guard var row = try ReadingPost.fetchOne(db, key: landed.id),
                  let book = try Reading.fetchOne(db, key: row.readingId), book.deletedAt == nil,
                  try Container.fetchOne(db, key: row.postId)?.deletedAt == nil
            else { return }
            guard !book.locked else { throw OperationError.lockedReading(id: book.id) }
            if row.deletedAt != nil {
                // A live twin for the pair (added again since) keeps it.
                guard try livePairRow(db, postID: row.postId, readingID: row.readingId) == nil else { return }
                row.deletedAt = nil
            } else if row.status == .member {
                return
            }
            row.status = .member
            row.position = landed.position
            row.sectionId = landed.sectionId
            try row.update(db)
            try enforceOwnershipAfterRevival(db, postIDs: [row.postId], now: date.now)
        }
    }
}
