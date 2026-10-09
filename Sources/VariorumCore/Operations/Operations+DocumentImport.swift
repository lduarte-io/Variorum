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
//   single file lands BOOKLESS (the Pool — P-13n-2, provisional).
// - **`importBook`** — a FOLDER as a book, in ONE transaction (the
//   resiliency/size call is the unit record's: one transaction, so a book
//   either lands whole or not at all): the book unshelved, kind `book`, no
//   rule, in the given wing; a chapter (`reading_section`) per subfolder in
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
        /// The tags applied, in header order (adopted or minted).
        public let tagIDs: [String]
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
            let tagIDs = try applyDocumentTags(
                db, named.document.tagPaths, to: minted.post.id, wingId: wingId, now: now)
            return DocumentImport(
                post: minted.post, blockIDs: minted.blockIDs,
                alternateCount: minted.alternateCount, tagIDs: tagIDs)
        }
        let postID = result.post.id
        undoStack?.register(
            label: Self.importUndoLabel,
            inverse: { try $0.revertMintedContainer(postID) },
            redo: { try $0.reapplyMintedContainer(postID) })
        return result
    }

    /// A folder → one book in `wingId`, every note seated in its chapter.
    @discardableResult
    public func importBook(
        _ book: VariorumDocument.Book, wingId: String = ""
    ) throws -> BookImport {
        let result: BookImport = try database.write { db in
            try requireLiveWing(db, wingId)
            guard book.noteCount > 0 else { throw OperationError.emptyImport }
            let trimmedName = book.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = trimmedName.isEmpty ? DisplayTitle.placeholder : trimmedName
            // E13 — the door guard, inside the act's own transaction: the
            // import names a book, so it refuses a name a live book wears.
            try requireBookNameFree(db, name)
            let now = date.now
            let reading = Reading(
                id: newID(), ownerId: currentOwnerID(), name: name, kind: .book,
                wingId: wingId, createdAt: now, updatedAt: now)
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
        undoStack?.register(
            label: Self.importUndoLabel,
            inverse: { try $0.revertImportedBook(readingID, posts: postIDs) },
            redo: { try $0.reapplyImportedBook(readingID, posts: postIDs) })
        return result
    }

    /// The undo entry's words — "Undo Import" / "Redo Import", the File
    /// door's own name (the bulk import's label, kept).
    public static let importUndoLabel = "Import"

    // MARK: - Internals

    private struct MintedDocument {
        let post: Container
        let blockIDs: [String]
        let alternateCount: Int
    }

    /// The note and its blocks, inside the caller's transaction.
    private func mintDocument(
        _ db: Database, _ named: VariorumDocument.NamedDocument, wingId: String, now: Date
    ) throws -> MintedDocument {
        let document = named.document
        guard !document.blocks.isEmpty else { throw OperationError.emptyImport }
        let fallback = named.fallbackTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = document.title ?? (fallback.isEmpty ? nil : fallback)
        var post = try insertPost(db, title: title, profile: nil, entryDate: nil, wingId: wingId)

        var blockIDs: [String] = []
        var alternateCount = 0
        var renderedLength = 0
        var position: String?
        for block in document.blocks {
            let takes = block.alternates.filter { !$0.text.isEmpty }
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
            alternateCount += takes.count
            renderedLength += block.text.count
        }
        // Touch, never churn (the structural convention); the note starts
        // clean — baseline = its rendered length (`copyPost`'s precedent).
        post.lastTouchedAt = now
        post.baselineLength = renderedLength
        post.updatedAt = now
        try post.update(db)
        return MintedDocument(post: post, blockIDs: blockIDs, alternateCount: alternateCount)
    }

    /// The header's tags onto the note: each path's segments (`TagPath` —
    /// slash noise collapses; a path naming nothing is passed over),
    /// adopted-else-minted in the wing, applied once through the one
    /// application road (intake hears it).
    private func applyDocumentTags(
        _ db: Database, _ paths: [String], to postID: String, wingId: String, now: Date
    ) throws -> [String] {
        var adoption = TagAdoption(wing: wingId)
        var applied: [String] = []
        for raw in paths {
            let segments = TagPath.segments(raw)
            guard !segments.isEmpty,
                  let tag = try adoptPath(db, segments.joined(separator: "/"), &adoption),
                  !applied.contains(tag.id)
            else { continue }
            try insertPostTag(db, tagID: tag.id, postID: postID, now: now)
            applied.append(tag.id)
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
    func revertImportedBook(_ readingID: String, posts postIDs: [String]) throws {
        try database.write { db in
            let reading = try Reading.fetchOne(db, key: readingID)
            if let reading, reading.deletedAt == nil, Queries.isDailyJournalMintShape(reading) {
                throw OperationError.dailyJournalCannotBeDeleted(id: readingID)
            }
            let now = date.now
            for postID in postIDs {
                guard let post = try Container.fetchOne(db, key: postID), post.deletedAt == nil
                else { continue }
                try tombstoneNoteFamily(db, id: postID, now: now)
            }
            if var reading, reading.deletedAt == nil {
                reading.deletedAt = now
                reading.updatedAt = now
                try reading.update(db)
            }
        }
    }

    /// The RE-APPLY: the imported notes that died on the book's stamp come
    /// back (`restoreContainer`'s exact-stamp body — their blocks, takes,
    /// tags, and their memberships in other books), then the book
    /// (`restoreReading`'s body — its chapters and every membership whose
    /// note is live), in one transaction. The book live again (Put back from
    /// the Trash meanwhile) ⇒ obsolete, quiet.
    func reapplyImportedBook(_ readingID: String, posts postIDs: [String]) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID),
                  let stamp = reading.deletedAt
            else { return }
            var revived: [String] = []
            for postID in postIDs {
                guard let post = try Container.fetchOne(db, key: postID),
                      post.deletedAt == stamp
                else { continue }
                try restoreNoteFamily(db, id: postID)
                revived.append(postID)
            }
            try restoreReadingRows(db, id: readingID)
            try enforceOwnershipAfterRevival(db, postIDs: revived, now: date.now)
        }
    }
}
