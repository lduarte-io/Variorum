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
                "Eu não pedi para herdar o observatório.",
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
            #expect(row?.baselineLength == "Eu não pedi para herdar o observatório.".count
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

    // MARK: - R-ARCH-13na-1: rows round-trip (export → import → the same store shape)

    /// One placed block as the store holds it: its live takes in fan order
    /// (text + label), and which of them is chosen and which is the default.
    private struct SlotShape: Equatable {
        let texts: [String]
        let labels: [String?]
        let chosen: Int?
        let defaultTake: Int?
    }

    private func storeShape(_ db: AppDatabase, _ postID: String) throws -> [SlotShape] {
        try db.read { database in
            try Row.fetchAll(
                database, sql: """
                    SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id
                    FROM container_block cb JOIN block b ON b.id = cb.block_id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                    ORDER BY cb.position, cb.id
                    """, arguments: [postID]
            ).map { row in
                let blockID: String = row["block_id"]
                let chosen: String? = row["chosen_variant_id"]
                let defaultID: String? = row["default_variant_id"]
                let fan = try Variant.fetchAll(
                    database, sql: """
                        SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL
                        ORDER BY fan_position, id
                        """, arguments: [blockID])
                return SlotShape(
                    texts: fan.map(\.workingText), labels: fan.map(\.label),
                    chosen: fan.firstIndex { $0.id == chosen },
                    defaultTake: fan.firstIndex { $0.id == defaultID })
            }
        }
    }

    /// A take on a seeded block, optionally labeled — never chosen.
    private func take(
        _ ops: Operations, on seeded: Operations.NewBlockResult, _ text: String, label: String? = nil
    ) throws {
        let take = try ops.branchVariant(seeded.block.id, from: seeded.variant.id)
        try ops.autosave(take.id, text: text, charDelta: text.count)
        if let label { try ops.setTakeLabel(take.id, label: label) }
    }

    /// export → parse → `importDocument`: the original's shape and the copy's.
    private func reimport(
        _ ops: Operations, _ db: AppDatabase, _ postID: String
    ) throws -> (original: [SlotShape], imported: [SlotShape]) {
        let export = try db.read { try Queries.exportPost($0, postID: postID, includeVariants: true) }
        let imported = try ops.importDocument(.init(
            fallbackTitle: "Copy", document: try VariorumDocument.parse(export)))
        return (try storeShape(db, postID), try storeShape(db, imported.post.id))
    }

    @Test func anUnspacedNoteRoundTripsRowForRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Unspaced")
            let first = try ops.seedBlock(in: post.id, text: "Eu não pedi para herdar o observatório.")
            try take(ops, on: first, "I never asked to inherit the observatory.", label: "english")
            try take(ops, on: first, "Je ne voulais pas.")
            try ops.seedBlock(in: post.id, text: "A plain block between.")
            try ops.seedBlock(in: post.id, text: "A block with\na line break inside it.")
            let last = try ops.seedBlock(in: post.id, text: "Cuidar de um observatório dá trabalho.")
            try take(ops, on: last, "Running an observatory is hard work.\nMost nights.", label: "english")

            let (original, imported) = try reimport(ops, db, post.id)
            #expect(original.count == 4)
            #expect(imported == original)
        }
    }

    @Test func aSpacedNoteRoundTripsRowForRow() throws {
        try withOperations { ops, db in
            // Stored spacing of 2, 3 and 4 newlines (a 3-, 4- and 5-newline
            // paste), beside unspaced neighbours, a fanned block whose spacing
            // sits between its text and its section, and single newlines
            // inside a surface block.
            let post = try ops.createPost(title: "Spaced")
            try ops.seedBlock(in: post.id, text: "Opening.\n\n")
            try ops.seedBlock(in: post.id, text: "Tight.")
            let wide = try ops.seedBlock(in: post.id, text: "A wide gap after me.\n\n\n\n")
            try take(ops, on: wide, "Um intervalo largo.", label: "pt")
            try ops.seedBlock(in: post.id, text: "Wrapped\nand spaced.\n\n\n")
            try ops.seedBlock(in: post.id, text: "Closing.")

            let (original, imported) = try reimport(ops, db, post.id)
            #expect(original.map { $0.texts[0] } == [
                "Opening.\n\n", "Tight.", "A wide gap after me.\n\n\n\n",
                "Wrapped\nand spaced.\n\n\n", "Closing.",
            ])
            #expect(imported == original)
        }
    }

    @Test func aHardWrappedFileImportsOneBlockPerParagraph() throws {
        try withOperations { ops, db in
            // The old-txt / Gutenberg shape (her Percy Jackson case): every
            // paragraph hard-wrapped near seventy columns, a blank line between
            // paragraphs, and the file's own final newline.
            let wrapped = """
                The house at the end of the lane had been empty for as long as
                anyone in the village could remember, and the children who dared
                each other to touch its gate never stayed to see whether it opened.

                Nobody could say who kept the garden. The roses came back every
                June regardless.

                """
            let result = try ops.importDocument(try named(wrapped, file: "chapter one.txt"))
            #expect(try storeShape(db, result.post.id).map(\.texts) == [
                ["The house at the end of the lane had been empty for as long as\n"
                    + "anyone in the village could remember, and the children who dared\n"
                    + "each other to touch its gate never stayed to see whether it opened."],
                ["Nobody could say who kept the garden. The roses came back every\n"
                    + "June regardless."],
            ])
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
