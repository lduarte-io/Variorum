import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U2 Q5 — THE MCP DOOR's WRITE ACTS (R-13n-4's suggest + write-new
// rungs; R-13n-6's paper trail): exact state transitions, and for EVERY act
// one undo entry labeled with the client's name whose inverse and redo
// round-trip the same rows. (Who may act is the server's per-call rule —
// `MCPServerTests`; the suggest PROOF is `MCPSuggestProofTests`.)

@Suite("13n-b U2 — the MCP write acts and their undo (R-13n-6)")
struct MCPWriteActsTests {
    private let client = "claude-code"

    /// The world with a structural-undo stack, as the app's session runs it.
    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    // MARK: - add take

    @Test func aTakeLandsAtTheFansEndLabeledUnchosenUnlockedAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "Eu não pedi para herdar o observatório.")
            let second = try ops.branchVariant(seeded.block.id, from: seeded.variant.id)
            let before = try [seeded.variant.id, second.id].map { try db.snapshotRow("variant", $0, excluding: []) }
            let placementBefore = try db.snapshotRow("container_block", seeded.placement.id, excluding: [])
            let touched = try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            stack.removeAll()

            let take = try ops.addTake(
                toBlock: seeded.block.id, text: "I never asked for the observatory.",
                label: "  english ", undoLabel: label(.take))
            #expect(take.label == "english")
            #expect(take.parentVariantId == nil && !take.locked && take.status == .active)
            let order = try db.read { try String.fetchAll(
                $0, sql: "SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id",
                arguments: [seeded.block.id]) }
            #expect(order.last == take.id, "the fan's END")
            #expect(try [seeded.variant.id, second.id].map { try db.snapshotRow("variant", $0, excluding: []) } == before,
                    "no existing take's row moves")
            #expect(try db.snapshotRow("container_block", seeded.placement.id, excluding: []) == placementBefore,
                    "never chosen")
            #expect(try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [seeded.block.id])
                    == seeded.variant.id, "never the default")
            #expect(try db.fetchString("SELECT last_touched_at FROM container WHERE id = ?", [note.id]) == touched,
                    "fan growth: no touch, no churn")
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's take")

            #expect(try stack.undo(with: ops) == "claude-code's take")
            #expect(try db.deletedAt("variant", take.id) != nil)
            #expect(try stack.redo(with: ops) == "claude-code's take")
            #expect(try db.deletedAt("variant", take.id) == nil, "the SAME row comes back")
        }
    }

    @Test func aTakeSheChoseSinceRefusesTheUndoAndASealRefusesTheAct() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "text")
            let take = try ops.addTake(toBlock: seeded.block.id, text: "ai", label: nil, undoLabel: label(.take))
            try ops.chooseVariant(seeded.block.id, variantID: take.id)
            #expect(throws: OperationError.variantIsChosen(id: take.id)) { try stack.undo(with: ops) }
            #expect(stack.depth == 1, "a resolvable refusal keeps the entry")
            try ops.chooseVariant(seeded.block.id, variantID: seeded.variant.id)
            #expect(try stack.undo(with: ops) != nil)

            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.addTake(toBlock: seeded.block.id, text: "x", label: nil, undoLabel: label(.take))
            }
        }
    }

    // MARK: - add comment

    @Test func aCommentUndoesToItsDeletedSurfaceAndRedoesTheSameRow() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let seeded = try ops.seedBlock(in: note.id, text: "text")
            // VX-184 U3 (A JUSTIFIED EDIT, the ritual — VX-188): the door's
            // comment now names its writer (`author:`), put on file with it.
            let comment = try ops.addComment(
                toBlock: seeded.block.id, text: "Fact check: true.", author: client, undoLabel: label(.comment))
            #expect(stack.topLabel == "claude-code's comment")
            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.deletedAt("block_comment", comment.id) != nil)
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("block_comment", comment.id) == nil)
            #expect(throws: OperationError.invalidCommentText) {
                try ops.addComment(toBlock: seeded.block.id, text: "  ", author: client, undoLabel: label(.comment))
            }
        }
    }

    // MARK: - save lens

    @Test func aLensSavesItsPicksTouchesNoChosenAndUndoesWithItsChoices() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "ch 1")
            let one = try ops.seedBlock(in: note.id, text: "one")
            let two = try ops.seedBlock(in: note.id, text: "two")
            let take1 = try ops.addTake(toBlock: one.block.id, text: "uno", label: "english", undoLabel: label(.take))
            let take2 = try ops.addTake(toBlock: two.block.id, text: "dos", label: "english", undoLabel: label(.take))
            let chosenBefore = try db.read { try String.fetchAll(
                $0, sql: "SELECT chosen_variant_id FROM container_block WHERE container_id = ? ORDER BY id",
                arguments: [note.id]) }

            let lens = try ops.saveLens(
                post: note.id, name: " english readings ",
                picks: [one.block.id: take1.id, two.block.id: take2.id], undoLabel: label(.lens))
            #expect(lens.name == "english readings")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL", [lens.id]) == 2)
            #expect(try db.read { try String.fetchAll(
                $0, sql: "SELECT chosen_variant_id FROM container_block WHERE container_id = ? ORDER BY id",
                arguments: [note.id]) } == chosenBefore, "a lens is never rendering truth")
            #expect(stack.topLabel == "claude-code's lens")

            #expect(try stack.undo(with: ops) == "claude-code's lens", "ONE press walks the last act back")
            #expect(try db.deletedAt("lens", lens.id) != nil)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL", [lens.id]) == 0)
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("lens", lens.id) == nil)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL", [lens.id]) == 2)
        }
    }

    @Test func aLensRefusesAPickFromAnotherNoteAndAnArchivedTake() throws {
        try withUndo { ops, _, _ in
            let note = try ops.createPost(title: "mine")
            let other = try ops.createPost(title: "other")
            let block = try ops.seedBlock(in: note.id, text: "a")
            let foreign = try ops.seedBlock(in: other.id, text: "b")
            #expect(throws: OperationError.blockNotInContainer(blockID: foreign.block.id, containerID: note.id)) {
                try ops.saveLens(post: note.id, name: "x", picks: [foreign.block.id: foreign.variant.id], undoLabel: "l")
            }
            let spare = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.archiveVariant(spare.id)
            #expect(throws: OperationError.archivedVariant(id: spare.id)) {
                try ops.saveLens(post: note.id, name: "x", picks: [block.block.id: spare.id], undoLabel: "l")
            }
            #expect(throws: OperationError.invalidLensName(name: " ")) {
                try ops.saveLens(post: note.id, name: " ", picks: [:], undoLabel: "l")
            }
        }
    }

    // MARK: - create note / import note

    @Test func aNoteFromProseSegmentsByTheBulkRuleAndLandsInTheBookOrTheWing() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "lessons", kind: .book)
            stack.removeAll()
            let inBook = try ops.createNote(
                title: "lesson 3", text: "Question one.\n\nQuestion two.\n\nQuestion three.",
                in: .book(book.id), undoLabel: label(.note))
            #expect(inBook.blockIDs.count == 3)
            #expect(try db.read { try Queries.renderedText($0, containerID: inBook.post.id) }
                    == "Question one.\n\nQuestion two.\n\nQuestion three.")
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ?
                  AND deleted_at IS NULL AND status = 'member'
                """, [book.id, inBook.post.id]) == 1, "a member of the book")
            let bookless = try ops.createNote(title: nil, text: "", in: .wing(""), undoLabel: label(.note))
            #expect(bookless.blockIDs.isEmpty, "an empty text mints an empty note")
            #expect(stack.depth == 2 && stack.topLabel == "claude-code's note")

            #expect(try stack.undo(with: ops) != nil)
            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.deletedAt("container", inBook.post.id) != nil)
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL
                """, [inBook.post.id]) == 0, "the membership dies with the note")
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("container", inBook.post.id) == nil)
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'
                """, [inBook.post.id]) == 1, "and comes back with it")

            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.createNote(title: nil, text: "x", in: .book(book.id), undoLabel: label(.note))
            }
        }
    }

    @Test func aLevelZeroDocumentImportsWithItsAlternatesUnchosenAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            let raw = """
                {t:"o ladrão de raios — ch 1"} {#percy/pt-en}

                Eu não pedi para herdar o observatório.

                --- Alternates for this block ---

                take: "english"

                I never asked for the observatory.

                --- end alternates ---

                Cuidar de um observatório dá trabalho.
                """
            let document = try VariorumDocument.parse(raw)
            let result = try ops.importNote(
                .init(fallbackTitle: "", document: document), in: .wing(""), undoLabel: label(.importNote))
            #expect(result.blockIDs.count == 2 && result.alternateCount == 1 && result.tagIDs.count == 1)
            #expect(try db.read { try Queries.variorumDocumentText($0, postID: result.post.id) } == raw)
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's import")
            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.deletedAt("container", result.post.id) != nil)
        }
    }

    @Test func aWholeBookImportIsOneEntryUnderTheClientsLabel() throws {
        try withUndo { ops, stack, db in
            let note = { (title: String) in
                VariorumDocument.NamedDocument(
                    fallbackTitle: title, document: .init(blocks: [.init(text: "\(title) text")]))
            }
            let book = VariorumDocument.Book(
                name: "worksheets", chapters: [.init(name: "week 1", notes: [note("a"), note("b")])],
                unfiled: [note("c")])
            let result = try ops.importBook(book, wingId: "", undoLabel: label(.importBook))
            #expect(result.postIDs.count == 3)
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's book import")
            #expect(try stack.undo(with: ops) == "claude-code's book import")
            #expect(try db.deletedAt("reading", result.reading.id) != nil)
            #expect(try result.postIDs.allSatisfy { try db.deletedAt("container", $0) != nil },
                    "a whole imported book comes back out in a single press")
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("reading", result.reading.id) == nil)
        }
    }

    // MARK: - apply tag

    @Test func aTagByPathAdoptsOrMintsIsHeardByLivingBooksAndUndoesTheApplicationOnly() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "lesson")
            let tag = try ops.createTag(name: "percy")
            let living = try ops.createReading(
                name: "percy", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            stack.removeAll()

            let application = try ops.applyTagPath("percy", toPost: note.id, undoLabel: label(.tag))
            #expect(application.tagId == tag.id, "an existing path adopts")
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                """, [living.id, note.id]) == 1, "the ONE application road: the living book heard it")
            let minted = try ops.applyTagPath("/grammar//verbs/", toPost: note.id, undoLabel: label(.tag))
            #expect(try db.fetchString("SELECT path FROM tag WHERE id = ?", [minted.tagId]) == "grammar/verbs",
                    "a missing path mints its chain in the note's wing")
            #expect(throws: OperationError.alreadyTagged(tagID: tag.id, targetID: note.id)) {
                try ops.applyTagPath("percy", toPost: note.id, undoLabel: label(.tag))
            }
            #expect(throws: OperationError.invalidTagName(name: "//")) {
                try ops.applyTagPath("//", toPost: note.id, undoLabel: label(.tag))
            }

            #expect(try stack.undo(with: ops) != nil)
            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.deletedAt("post_tag", application.id) != nil)
            #expect(try db.deletedAt("tag", minted.tagId) == nil, "a minted tag stays as vocabulary")
            #expect(try db.fetchInt("""
                SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                """, [living.id, note.id]) == 1, "un-tagging is a non-event for intake (PROVISIONAL P-13nb-U2-6)")
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("post_tag", application.id) == nil)
        }
    }

    // MARK: - create book

    @Test func aBookIsBornEmptyUnshelvedNameGuardedAndUndoesInOne() throws {
        try withUndo { ops, stack, db in
            _ = try ops.createReading(name: "Percy", kind: .book)
            stack.removeAll()
            #expect(throws: OperationError.duplicateBookName(name: "Percy")) {
                try ops.createBook(named: " percy ", inWing: "", undoLabel: label(.book))
            }
            let book = try ops.createBook(named: "lessons", inWing: "", undoLabel: label(.book))
            #expect(book.kind == .book && book.shelfId == nil && !book.owned && book.querySpec == nil)
            #expect(try stack.undo(with: ops) == "claude-code's book")
            #expect(try db.deletedAt("reading", book.id) != nil)
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("reading", book.id) == nil)
        }
    }

    // MARK: - add note to book

    @Test func addingANoteUndoesAFreshMembershipAndReturnsASeatedArrivalToTheDoor() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "lessons", kind: .book)
            let fresh = try ops.createPost(title: "fresh")
            let waiting = try ops.createPost(title: "waiting")
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('arrival-w', ?, ?, 'a5', 'arrival', '2026-07-01T00:00:00.000Z')
                    """, arguments: [book.id, waiting.id])
            }
            stack.removeAll()

            let added = try ops.addNoteToBook(fresh.id, book: book.id, undoLabel: label(.bookAdd))
            let seated = try ops.addNoteToBook(waiting.id, book: book.id, undoLabel: label(.bookAdd))
            #expect(seated.id == "arrival-w" && seated.status == .member, "the hand-add seats a waiting arrival")
            #expect(stack.topLabel == "claude-code's add to a book")

            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.fetchString("SELECT status FROM reading_post WHERE id = 'arrival-w'") == "arrival",
                    "back at the door, where it waited")
            #expect(try db.fetchString("SELECT position FROM reading_post WHERE id = 'arrival-w'") == "a5")
            #expect(try stack.undo(with: ops) != nil)
            #expect(try db.deletedAt("reading_post", added.id) != nil)
            #expect(try stack.redo(with: ops) != nil)
            #expect(try stack.redo(with: ops) != nil)
            #expect(try db.deletedAt("reading_post", added.id) == nil)
            #expect(try db.fetchString("SELECT status FROM reading_post WHERE id = 'arrival-w'") == "member")
        }
    }

    @Test func theOwnershipConsultSpeaksToTheClientAsToHer() throws {
        try withUndo { ops, _, _ in
            let owned = try ops.createReading(name: "owned", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let note = try ops.createPost(title: "shared")
            _ = try ops.addPostToReading(note.id, to: plain.id)
            #expect(throws: OperationError.self) {
                try ops.addNoteToBook(note.id, book: owned.id, undoLabel: "l")
            }
        }
    }
}
