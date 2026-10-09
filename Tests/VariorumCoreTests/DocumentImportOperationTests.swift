import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13n-a — THE IMPORT DOOR's operations (the plan's acceptance, second half
/// of the first bullet): `importDocument` / `importBook`, exact rows —
/// chosen, default, fan order, labels, tags by path, sections, membership
/// order — and the ONE undo entry whose inverse tombstones exactly what the
/// import minted on one stamp, whose redo revives those exact rows.
@Suite("Document import operations (13n-a)")
struct DocumentImportOperationTests {
    private typealias Doc = VariorumDocument

    private func named(_ text: String, file: String = "file name.md") throws -> Doc.NamedDocument {
        try VariorumDocumentFolder.note(named: file, contents: text)
    }

    /// Every live variant of a block in fan order.
    private func fan(_ db: AppDatabase, _ blockID: String) throws -> [Variant] {
        try db.read {
            try Variant.fetchAll(
                $0, sql: """
                    SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """, arguments: [blockID])
        }
    }

    private let sample = """
        {t:"o ladrão de raios — ch 1"} {#percy/pt-en} {#bilingual} {#percy/pt-en}

        Eu não pedi para herdar o observatório.

        --- Alternates for this block ---

        take: "english"

        Honestly, I never asked for the observatory.

        take: 2

        Je ne voulais pas.

        --- end alternates ---

        Cuidar de um observatório dá trabalho.
        """

    // MARK: - importDocument

    @Test func aDocumentMintsOneBooklessNoteWithChosenDefaultFanAndLabels() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let undoable = Operations(undoStack: stack)
            let result = try undoable.importDocument(try named(sample))

            // The note: the header's title, the Pool (no membership), Home.
            #expect(result.post.title == "o ladrão de raios — ch 1")
            #expect(result.post.kind == .post)
            #expect(result.post.wingId == "")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [result.post.id]) == 0)
            #expect(result.blockIDs.count == 2)
            #expect(result.alternateCount == 2)

            // Block 1: the in-place text is take 0 — chosen AND default; the
            // alternates follow in document order, unchosen, unlocked,
            // labeled (a numbered take is unlabeled).
            let first = try fan(db, result.blockIDs[0])
            #expect(first.map(\.workingText) == [
                "Eu não pedi para herdar o observatório.\n",
                "Honestly, I never asked for the observatory.",
                "Je ne voulais pas.",
            ])
            #expect(first.map(\.label) == [nil, "english", nil])
            #expect(first.allSatisfy { !$0.locked && $0.status == .active })
            let chosen = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [result.blockIDs[0]])
            let defaultID = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [result.blockIDs[0]])
            #expect(chosen == first[0].id)
            #expect(defaultID == first[0].id)
            // Block 2: fanless.
            #expect(try fan(db, result.blockIDs[1]).map(\.workingText) == ["Cuidar de um observatório dá trabalho."])

            // Tags by path: the missing chain minted in the wing, each applied
            // ONCE (the header named percy/pt-en twice).
            let paths = try db.read { try Queries.postTags($0, postID: result.post.id).map(\.path) }
            #expect(paths == ["bilingual", "percy/pt-en"])
            #expect(result.tagIDs.count == 2)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM tag WHERE path = 'percy' AND deleted_at IS NULL") == 1)

            // Touch, never churn; the note starts clean.
            let row = try db.read { try Container.fetchOne($0, key: result.post.id) }
            #expect(row?.lastTouchedAt != nil)
            #expect(row?.churnAccumulator == 0)
            #expect(row?.baselineLength == "Eu não pedi para herdar o observatório.\n".count
                + "Cuidar de um observatório dá trabalho.".count)

            // ONE undo entry.
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Import")
        }
    }

    @Test func noTitleTokenNamesTheNoteByItsFileAndExistingTagsAreAdopted() throws {
        try withOperations { ops, db in
            let existing = try ops.createTag(name: "bilingual")
            let result = try ops.importDocument(
                try named("{#bilingual} {#///}\n\nBody.", file: "Chapter 1/03 the oracle.md"))
            #expect(result.post.title == "03 the oracle")
            // Adopted, never a twin; a token naming nothing passes over.
            #expect(result.tagIDs == [existing.id])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM tag WHERE deleted_at IS NULL") == 1)
        }
    }

    @Test func importingAnExportRendersTheSameExportBack() throws {
        try withOperations { ops, db in
            // A note made by hand: a labeled + an unlabeled take, a plain
            // block, internal newlines in a take.
            let post = try ops.createPost(title: "Original")
            let one = try ops.seedBlock(in: post.id, text: "First block.")
            let english = try ops.branchVariant(one.block.id, from: one.variant.id)
            try ops.autosave(english.id, text: "In english,\nover two lines.", charDelta: 10)
            try ops.setTakeLabel(english.id, label: "english")
            let other = try ops.branchVariant(one.block.id, from: one.variant.id)
            try ops.autosave(other.id, text: "unlabeled", charDelta: 9)
            try ops.seedBlock(in: post.id, text: "Second block.")

            let export = try db.read { try Queries.exportPost($0, postID: post.id, includeVariants: true) }
            let imported = try ops.importDocument(.init(
                fallbackTitle: "Copy", document: try VariorumDocument.parse(export)))
            let again = try db.read {
                try Queries.exportPost($0, postID: imported.post.id, includeVariants: true)
            }
            #expect(again == export)
        }
    }

    @Test func undoTombstonesTheNoteWholeAndRedoRevivesTheSameRows() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let result = try ops.importDocument(try named(sample))
            let variantIDs = try result.blockIDs.flatMap { try fan(db, $0).map(\.id) }

            #expect(try stack.undo(with: ops) == "Import")
            #expect(try db.deletedAt("container", result.post.id) != nil)
            for blockID in result.blockIDs {
                #expect(try db.deletedAt("block", blockID) != nil)
            }
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                [result.post.id]) == 0)
            // The tags the import minted stay as vocabulary (AppSpec §9).
            #expect(try db.fetchInt("SELECT COUNT(*) FROM tag WHERE deleted_at IS NULL") == 3)

            #expect(try stack.redo(with: ops) == "Import")
            #expect(try db.deletedAt("container", result.post.id) == nil)
            #expect(try result.blockIDs.flatMap { try fan(db, $0).map(\.id) } == variantIDs)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                [result.post.id]) == 2)
        }
    }

    @Test func anEmptyDocumentRefusesAndMintsNothing() throws {
        try withOperations { ops, db in
            #expect(throws: OperationError.emptyImport) {
                try ops.importDocument(.init(fallbackTitle: "x", document: .init(blocks: [])))
            }
            let containers = try db.fetchInt("SELECT COUNT(*) FROM container")
            #expect(containers == 0)
        }
    }

    @Test func aTagHeardByALivingBookSeatsTheImportedNote() throws {
        try withOperations { ops, db in
            // R-13u4-1's rule, through the one application road: a living
            // book whose rule names the tag picks the note up.
            let tag = try ops.createTag(name: "dream")
            let book = try ops.createReading(
                name: "dream journal", kind: .book,
                querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let result = try ops.importDocument(try named("{#dream}\n\nI was flying."))
            #expect(try db.read { try Queries.assembleReading($0, readingID: book.id).map(\.postID) }
                == [result.post.id])
        }
    }

    // MARK: - importBook

    private func folder() throws -> VariorumDocument.Book {
        try VariorumDocumentFolder.plan(
            folderName: "o ladrão de raios",
            files: [
                .init(relativePath: "2 Chapter two/1 opening.md", contents: "Dois.\n\nMais."),
                .init(relativePath: "1 Chapter one/10 later.md", contents: "Depois."),
                .init(relativePath: "1 Chapter one/2 first.md", contents: sample),
                .init(relativePath: "afterword.md", contents: "{t:\"Posfácio\"}\n\nFim."),
            ])
    }

    @Test func aFolderMintsABookWithChaptersAndSeatedNotesInBookOrder() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let result = try ops.importBook(try folder())

            // The book: named by the folder, a book, unshelved, no rule, Home.
            #expect(result.reading.name == "o ladrão de raios")
            #expect(result.reading.kind == .book)
            #expect(result.reading.shelfId == nil)
            #expect(result.reading.querySpec == nil)
            #expect(result.reading.wingId == "")

            // Chapters in the plan's order.
            let chapters = try db.read { try Queries.readingSections($0, readingID: result.reading.id) }
            #expect(chapters.map(\.name) == ["1 Chapter one", "2 Chapter two"])
            #expect(chapters.map(\.id) == result.sectionIDs)

            // Members in book order, each seated in its chapter.
            let rows = try db.read {
                try ReadingPost.fetchAll(
                    $0, sql: """
                        SELECT * FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL
                        ORDER BY position, id
                        """, arguments: [result.reading.id])
            }
            #expect(rows.map(\.postId) == result.postIDs)
            #expect(rows.allSatisfy { $0.status == .member })
            #expect(rows.map(\.sectionId) == [
                result.sectionIDs[0], result.sectionIDs[0], result.sectionIDs[1], nil,
            ])
            let titles = try db.read { database in
                try result.postIDs.map { try Container.fetchOne(database, key: $0)?.title }
            }
            #expect(titles == ["o ladrão de raios — ch 1", "10 later", "1 opening", "Posfácio"])

            // ONE undo entry for the whole folder.
            #expect(stack.depth == 1)
        }
    }

    @Test func undoTakesTheWholeBookOnOneStampAndRedoBringsItBackWhole() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let result = try ops.importBook(try folder())
            // A note of HER OWN, filed in the imported book afterwards.
            let hers = try ops.createPost(title: "mine")
            try ops.addPostToReading(hers.id, to: result.reading.id)

            try stack.undo(with: ops)
            let stamp = try #require(try db.deletedAt("reading", result.reading.id))
            for postID in result.postIDs {
                #expect(try db.deletedAt("container", postID) == stamp)
            }
            for sectionID in result.sectionIDs {
                #expect(try db.deletedAt("reading_section", sectionID) == stamp)
            }
            // Her note lives; only its membership went with the book.
            #expect(try db.deletedAt("container", hers.id) == nil)

            try stack.redo(with: ops)
            #expect(try db.deletedAt("reading", result.reading.id) == nil)
            for postID in result.postIDs {
                #expect(try db.deletedAt("container", postID) == nil)
            }
            for sectionID in result.sectionIDs {
                #expect(try db.deletedAt("reading_section", sectionID) == nil)
            }
            let members = try db.read {
                try String.fetchAll(
                    $0, sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                        ORDER BY position, id
                        """, arguments: [result.reading.id])
            }
            #expect(members == result.postIDs + [hers.id])

            // …and undo↔redo ping-pongs on the same rows.
            try stack.undo(with: ops)
            #expect(try db.deletedAt("reading", result.reading.id) != nil)
            try stack.redo(with: ops)
            #expect(try db.deletedAt("reading", result.reading.id) == nil)
        }
    }

    @Test func aFolderNamedLikeALiveBookRefusesAndMintsNothing() throws {
        try withOperations { ops, db in
            try ops.createReading(name: "O Ladrão de Raios", kind: .book)
            #expect(throws: OperationError.duplicateBookName(name: "O Ladrão de Raios")) {
                try ops.importBook(try folder())
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading") == 1)
        }
    }

    @Test func undoRefusesWhenTheImportedBookBecameTheDailyJournal() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let result = try ops.importBook(try folder())
            try ops.setDailyJournalBook(result.reading.id)
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: result.reading.id)) {
                try stack.undo(with: ops)
            }
            // Nothing died, and the entry waits on the stack.
            #expect(try db.deletedAt("reading", result.reading.id) == nil)
            #expect(stack.depth == 1)
        }
    }
}
