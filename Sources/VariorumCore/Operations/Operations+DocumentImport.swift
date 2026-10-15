import Dependencies
import Foundation
import GRDB

// THE IMPORT DOOR OF THE VARIORUM DOCUMENT FORMAT (13n-a — Level 0 of the MCP
// door; the sitting record's R-13n-6/R-13n-8, P-13n-2).
//
// A file is BULK ENTRY, never reconciled truth: import mints fresh rows
// through ordinary operations and never reads anything back out of the
// store to merge with (the export pin stands — no export writes a row, and
// no import edits an existing one). The parsed `VariorumDocument` is the
// whole input; the face parses (fail-honest, line-numbered) before any op
// runs, so a malformed file never reaches here.
//
// - **`importDocument`** — ONE note from one document, in ONE transaction:
//   a block per paragraph (the in-place text is each block's chosen take AND
//   its `default_variant_id`'s), each block's Alternates joining its fan at
//   the end in document order (never chosen, never locked, labels riding),
//   the header's tags adopted/minted BY PATH in the destination wing
//   (R-13ia-1's one rule, `adoptPath`) and applied through the ONE
//   application road (`insertPostTag` — so a living book whose rule hears a
//   tag picks the note up, exactly as the capture microsyntax's tags do,
//   R-13u4-1). The title is the header's `{t:"…"}`, else the filename. A
//   single file lands BOOKLESS (the Pool — P-13n-2, provisional). A
//   block-less document (a stub — ladder F4) mints an EMPTY note.
// - **`importBook`** — a FOLDER as a book, in ONE transaction (the
//   resiliency/size call is the unit record's: one transaction, so a book
//   either lands whole or not at all): the book unshelved — or, from the
//   Bookcase's drop, on the shelf the board is solo'd on (the context mint,
//   ladder F2) — kind `book`, no rule, in the given wing; a chapter (`reading_section`) per subfolder in
//   the plan's order; every note minted as above and SEATED — a member of
//   its chapter, in book order. The folder's name is the book's, and the
//   duplicate-name door guard (E13) refuses a name a live book already wears.
//
// **Undo (R-13n-6): one import = ONE structural-undo entry.** Each op
// registers exactly one; the face folds a multi-item gesture into one
// compound. The inverse tombstones EVERYTHING THE IMPORT MINTED on one stamp
// — the note (the container cascade takes its placements, blocks, takes,
// edges, tag applications and memberships), or every imported note plus the
// book (whose cascade takes its chapters and memberships) — and the redo
// revives those exact rows through the restore doors' own exact-stamp
// bodies (`restoreContainer`, `restoreReading`). Tags the import MINTED stay
// as vocabulary across the undo (AppSpec §9: tags are excluded from
// structural undo; the applications die and revive with their notes).
//
// Stamps (the structural-op convention): `last_touched_at` stamps, churn
// stays untouched; the note starts "clean" — baseline = its rendered length
// (`copyPost`'s precedent), so her first edits accumulate against real
// content.
extension Operations {
    /// What one document import minted.
    public struct DocumentImport: Equatable, Sendable {
        public let post: Container
        /// In document order.
        public let blockIDs: [String]
        /// The takes that rode Alternates sections (chosen takes not counted).
        public let alternateCount: Int
        /// **Every tag the note wears when the act lands** (VX-361 — the
        /// VX-336 run record's U9, F-1 (a), PROVISIONAL P-VX361-1): the
        /// header's tags in header order (adopted or minted; one the note
        /// already wore is listed, never applied twice), then — for a note
        /// minted into a book (`mintNoteEntry`) — the tags the book's OUTFLOW
        /// applied that the header didn't name, in outflow order. A file
        /// import's note is bookless, so its list is exactly the header's.
        public let tagIDs: [String]
        /// `tagIDs`' paths, parallel — the wire's tag word (VX-361).
        public let tagPaths: [String]
        /// VX-252 (VX-336 U5b): every minted block with EVERY take it was born
        /// with, in document order — what the act minted, said back so a caller
        /// never reads the note again to learn an id the write itself made.
        public let blocks: [MintedBlockTakes]
    }

    /// **One minted block, as the act minted it** (VX-252 — the run record's
    /// U5b D1, the shared answer shape's core half): its id, the take it SHOWS
    /// (at mint the in-place text — chosen AND default), and every take in fan
    /// order, the shown one included. Built from the rows the mint returned,
    /// never a second read (no race, ∝ the write).
    public struct MintedBlockTakes: Equatable, Sendable {
        public let blockID: String
        public let shownTakeID: String
        public let takes: [MintedTake]
        /// VX-311 (VX-336 U6a — the run record's D-311-4, F-4 (a)): the block
        /// this one was COPIED from, so a client that read the source with ids
        /// edits "the copy of block X" without positional guessing. nil for
        /// every mint (`create_note`, `import_document`, `insert_blocks` —
        /// their answers byte-unchanged); set only by the copy machine
        /// (`copyPlacements`).
        public let sourceBlockID: String?

        init(_ minted: MintedFanBlock, shownIndex: Int = 0) {
            self.init(
                blockID: minted.block.id, shownTakeID: minted.variants[shownIndex].id,
                takes: minted.variants.map { MintedTake(id: $0.id, label: $0.label, text: $0.workingText) },
                sourceBlockID: nil)
        }

        init(blockID: String, shownTakeID: String, takes: [MintedTake], sourceBlockID: String?) {
            self.blockID = blockID
            self.shownTakeID = shownTakeID
            self.takes = takes
            self.sourceBlockID = sourceBlockID
        }
    }

    /// One minted take: its id, its stored label (nil = unlabeled), and —
    /// VX-254 (VX-336 U7, D-254-2) — the text the mint STORED, the minted
    /// row's own `working_text` (never a second read). It never rides a wire
    /// answer: the door hashes it (`MCPTextDigest`), so a client proves its
    /// words landed byte for byte.
    public struct MintedTake: Equatable, Sendable {
        public let id: String
        public let label: String?
        public let text: String
    }

    /// What one folder import minted.
    public struct BookImport: Equatable, Sendable {
        public let reading: Reading
        /// In chapter order.
        public let sectionIDs: [String]
        /// Every minted note, in book order (chapters in order, then the
        /// unfiled ones).
        public let postIDs: [String]
    }

    /// One document → one bookless note in `wingId` (P-13n-2).
    @discardableResult
    public func importDocument(
        _ named: VariorumDocument.NamedDocument, wingId: String = ""
    ) throws -> DocumentImport {
        let result: DocumentImport = try database.write { db in
            try requireLiveWing(db, wingId)
            let now = date.now
            let minted = try mintDocument(db, named, wingId: wingId, now: now)
            let tags = try applyDocumentTags(
                db, named.document.tagPaths, to: minted.post.id, wingId: wingId, now: now)
            return DocumentImport(
                post: minted.post, blockIDs: minted.blockIDs, alternateCount: minted.alternateCount,
                tagIDs: tags.map(\.id), tagPaths: tags.map(\.path), blocks: minted.blocks)
        }
        let postID = result.post.id
        registerMintedContainerEntry(label: Self.importUndoLabel, postID)
        return result
    }

    /// A folder → one book in `wingId`, every note seated in its chapter.
    ///
    /// `shelfId` — THE CONTEXT MINT (ladder round 1, F2; AppSpec §12 "a
    /// context mint lands on the solo'd shelf", the sitting record §19.1):
    /// the Bookcase's drop passes the shelf the board is solo'd on, so the
    /// book appears where she dropped it; every other door passes nil and the
    /// book lands UNSHELVED (§19). Validated exactly as `createReading`
    /// validates it — live, and in this book's wing — and never placed (it
    /// appends at the end of the shelf's order).
    @discardableResult
    public func importBook(
        _ book: VariorumDocument.Book, wingId: String = "", shelfId: String? = nil
    ) throws -> BookImport {
        let result: BookImport = try database.write { db in
            try requireLiveWing(db, wingId)
            if let shelfId {
                let shelf = try liveShelf(db, shelfId)
                guard shelf.wingId == wingId else {
                    throw OperationError.shelfNotFound(id: shelfId)
                }
            }
            guard book.noteCount > 0 else { throw OperationError.emptyImport }
            let trimmedName = book.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = trimmedName.isEmpty ? DisplayTitle.placeholder : trimmedName
            // E13 — the door guard, inside the act's own transaction: the
            // import names a book, so it refuses a name a live book wears.
            try requireBookNameFree(db, name)
            let now = date.now
            let reading = Reading(
                id: newID(), ownerId: currentOwnerID(), name: name, kind: .book,
                wingId: wingId, shelfId: shelfId, createdAt: now, updatedAt: now)
            try reading.insert(db)

            var sectionIDs: [String] = []
            var postIDs: [String] = []
            var sectionPosition: String?
            var memberPosition: String?
            func seat(_ note: VariorumDocument.NamedDocument, in sectionID: String?) throws {
                let minted = try mintDocument(db, note, wingId: wingId, now: now)
                let position = FractionalIndex.between(memberPosition, nil)
                memberPosition = position
                try ReadingPost(
                    id: newID(), readingId: reading.id, postId: minted.post.id,
                    position: position, sectionId: sectionID, createdAt: now
                ).insert(db)
                // Tags AFTER the membership (`newPostInReading`'s order): the
                // tagging act is heard by the OTHER living books.
                _ = try applyDocumentTags(
                    db, note.document.tagPaths, to: minted.post.id, wingId: wingId, now: now)
                postIDs.append(minted.post.id)
            }
            for chapter in book.chapters {
                let chapterName = chapter.name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !chapterName.isEmpty else {
                    throw OperationError.invalidSectionName(name: chapter.name)
                }
                let position = FractionalIndex.between(sectionPosition, nil)
                sectionPosition = position
                let section = ReadingSection(
                    id: newID(), readingId: reading.id, name: chapterName,
                    position: position, createdAt: now, updatedAt: now)
                try section.insert(db)
                sectionIDs.append(section.id)
                for note in chapter.notes {
                    try seat(note, in: section.id)
                }
            }
            for note in book.unfiled {
                try seat(note, in: nil)
            }
            return BookImport(reading: reading, sectionIDs: sectionIDs, postIDs: postIDs)
        }
        let readingID = result.reading.id
        let postIDs = result.postIDs
        // The redo keys on the stamp the INVERSE wrote (ladder round 1, F1):
        // the undo hands it over through this box, the P-13ib-6 shape
        // (`convertSmartReadingToCurated`'s undo-time box). Never the book's
        // own tombstone — a book she deleted by hand before the undo carries
        // HER stamp, and reviving it would land in a state that never existed.
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: Self.importUndoLabel,
            inverse: { ops in
                // Ladder round 2, R2-1: a RETRIED undo that tombstoned
                // nothing returns nil and must not overwrite the stamp the
                // real deletion wrote — the redo would otherwise look for
                // rows that died on the fresh stamp and leave the first
                // undo's books in the Trash.
                // (VX-246 U2: and the nil answers the stack — nothing
                // tombstoned retires the entry.)
                guard let stamp = try ops.revertImportedBook(readingID, posts: postIDs) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reapplyImportedBook(readingID, posts: postIDs, undoneOn: undoneOn.value) })
        return result
    }

    /// The undo entry's words — "Undo Import" / "Redo Import", the File
    /// door's own name (the bulk import's label, kept).
    public static let importUndoLabel = "Import"

    // MARK: - Internals

    struct MintedDocument {
        let post: Container
        let blockIDs: [String]
        let alternateCount: Int
        /// VX-252: each block with every take it was born with.
        let blocks: [MintedBlockTakes]
    }

    /// The note and its blocks, inside the caller's transaction. A document
    /// with NO block — a stub (ladder F4, option (b), PROVISIONAL: a
    /// header-only file, or a blank file inside a folder) — mints an EMPTY
    /// note: ⌘N's own shape (`createPost` — a post with no block yet), named
    /// by its header else its file, its tags applied as ever.
    ///
    /// `keepingBlankTakes` (VX-168 U3 — R-VX171-2, her word, door-only): the
    /// structured `create_note`'s takes mint a BLANK take (`""`, the Mac's
    /// own blank-take gesture) instead of dropping it. Every FILE door keeps
    /// the default — the format cannot carry a blank take (its sections skip
    /// them), so one format keeps one meaning (R-13nb-11 G-2).
    func mintDocument(
        _ db: Database, _ named: VariorumDocument.NamedDocument, wingId: String, now: Date,
        keepingBlankTakes: Bool = false
    ) throws -> MintedDocument {
        let document = named.document
        let fallback = named.fallbackTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = document.title ?? (fallback.isEmpty ? nil : fallback)
        var post = try insertPost(db, title: title, profile: nil, entryDate: nil, wingId: wingId)

        var blockIDs: [String] = []
        var blocks: [MintedBlockTakes] = []
        var alternateCount = 0
        var renderedLength = 0
        var position: String?
        for block in document.blocks {
            let takes = keepingBlankTakes ? block.alternates : block.alternates.filter { !$0.text.isEmpty }
            let slot = FractionalIndex.between(position, nil)
            position = slot
            // The in-place text is take 0 — chosen AND default; the
            // Alternates follow it in document order, unchosen and unlocked,
            // each keeping its label (a numbered take is unlabeled).
            let minted = try mintFanBlock(
                db, texts: [block.text] + takes.map(\.text), in: post.id, position: slot,
                defaultIndex: 0, chosenIndex: 0,
                labels: [nil] + takes.map(\.label), now: now)
            blockIDs.append(minted.block.id)
            blocks.append(MintedBlockTakes(minted))
            alternateCount += takes.count
            renderedLength += block.text.count
        }
        // Touch, never churn (the structural convention); the note starts
        // clean — baseline = its rendered length (`copyPost`'s precedent).
        post.lastTouchedAt = now
        post.baselineLength = renderedLength
        post.updatedAt = now
        try post.update(db)
        return MintedDocument(post: post, blockIDs: blockIDs, alternateCount: alternateCount, blocks: blocks)
    }

    /// The header's tags onto the note: each path's segments (`TagPath` —
    /// slash noise collapses; a path naming nothing is passed over),
    /// adopted-else-minted in the wing, applied once through the one
    /// application road (intake hears it). Returns the header's tags, in
    /// header order.
    ///
    /// **VX-361 — a tag the note ALREADY wears is reported, never applied
    /// again** (the outflow's own rule, `applyAutoTag`): the wire mints a note
    /// INTO a book whose outflow tags it in the same act, before the header's
    /// tags, so a header naming an outflow tag met `uq_post_tag_live` and the
    /// whole import refused. The application exists and its intake already
    /// ran; the note wears the tag, so the header's list names it. A file
    /// import's note is fresh and untagged here — byte-unchanged for it.
    func applyDocumentTags(
        _ db: Database, _ paths: [String], to postID: String, wingId: String, now: Date
    ) throws -> [Tag] {
        var adoption = TagAdoption(wing: wingId)
        var applied: [Tag] = []
        for raw in paths {
            let segments = TagPath.segments(raw)
            guard !segments.isEmpty,
                  let tag = try adoptPath(db, segments.joined(separator: "/"), &adoption),
                  !applied.contains(where: { $0.id == tag.id })
            else { continue }
            if try liveApplication(
                db, table: "post_tag", tagID: tag.id, targetColumn: "post_id", targetID: postID) == nil {
                try insertPostTag(db, tagID: tag.id, postID: postID, now: now)
            }
            applied.append(tag)
        }
        return applied
    }

    /// The INVERSE of a folder import: every imported note still live, and
    /// the book, tombstoned on ONE stamp (`deleteReadingWithNotes`' shape,
    /// over exactly the notes the import minted — a note of hers she filed
    /// in the book since keeps living; its membership dies with the book and
    /// comes back with it). A book that has since become THE daily Journal
    /// refuses (`dailyJournalCannotBeDeleted` — the delete doors' own guard;
    /// the entry stays on the stack). Already dead ⇒ obsolete, quiet.
    ///
    /// Returns the stamp it wrote (the store's own spelling of it), which the
    /// entry hands to its redo (ladder round 1, F1) — and NIL when it
    /// tombstoned nothing (ladder round 2, R2-1: a retried undo whose rows
    /// are already dead writes no stamp, so the entry keeps the one the real
    /// deletion wrote and the redo still finds those rows).
    func revertImportedBook(_ readingID: String, posts postIDs: [String]) throws -> String? {
        try database.write { db in
            let reading = try Reading.fetchOne(db, key: readingID)
            if let reading, reading.deletedAt == nil, Queries.isDailyJournalMintShape(reading) {
                throw OperationError.dailyJournalCannotBeDeleted(id: readingID)
            }
            let now = date.now
            var tombstonedAnything = false
            for postID in postIDs {
                guard let post = try Container.fetchOne(db, key: postID), post.deletedAt == nil
                else { continue }
                try tombstoneNoteFamily(db, id: postID, now: now)
                tombstonedAnything = true
            }
            if var reading, reading.deletedAt == nil {
                reading.deletedAt = now
                reading.updatedAt = now
                try reading.update(db)
                tombstonedAnything = true
            }
            return tombstonedAnything ? DateFormatter.variorumISO8601.string(from: now) : nil
        }
    }

    /// The RE-APPLY, keyed on `undoneOn` — the stamp the undo's inverse
    /// wrote (ladder round 1, F1): the imported notes that died on THAT stamp
    /// come back (`restoreContainer`'s exact-stamp body — their blocks,
    /// takes, tags, and their memberships in other books), then the book —
    /// ONLY when its own tombstone is that stamp (`restoreReading`'s body —
    /// its chapters and every membership whose note is live) — in one
    /// transaction. So undo↔redo returns exactly the rows the undo took
    /// (AppSpec §9's round trip): a book she deleted by hand BEFORE the undo
    /// died on her own stamp and stays in the Trash, its notes come back
    /// bookless, as they were; a note she deleted by hand stays deleted. What
    /// has come back meanwhile (Put back from the Trash) is live and passes
    /// over — obsolete, quiet; nil (no inverse ever ran) is obsolete too.
    @discardableResult
    func reapplyImportedBook(
        _ readingID: String, posts postIDs: [String], undoneOn stamp: String?
    ) throws -> Bool {
        guard let stamp else { return false }
        func diedOnTheUndo(_ deletedAt: Date?) -> Bool {
            deletedAt.map { DateFormatter.variorumISO8601.string(from: $0) } == stamp
        }
        return try database.write { db in
            var revived: [String] = []
            for postID in postIDs {
                guard let post = try Container.fetchOne(db, key: postID),
                      diedOnTheUndo(post.deletedAt)
                else { continue }
                try restoreNoteFamily(db, id: postID)
                revived.append(postID)
            }
            var revivedBook = false
            if let reading = try Reading.fetchOne(db, key: readingID),
               diedOnTheUndo(reading.deletedAt) {
                try restoreReadingRows(db, id: readingID)
                revivedBook = true
            }
            try enforceOwnershipAfterRevival(db, postIDs: revived, now: date.now)
            return revivedBook || !revived.isEmpty
        }
    }
}
