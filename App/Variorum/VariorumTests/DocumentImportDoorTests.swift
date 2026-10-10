//
//  DocumentImportDoorTests.swift
//  VariorumTests
//
//  13n-a — THE IMPORT DOOR and COPY FOR AI, app side (the format, its
//  round trips and the import ops' exact rows are core-pinned:
//  `VariorumDocumentTests`, `DocumentFormatRoundTripTests`,
//  `DocumentImportOperationTests`). Here: the door end to end over a REAL
//  folder on disk — what it reads, what it says, that the gesture is ONE
//  undo entry, that a malformed file anywhere refuses the whole gesture
//  naming the file and the line, that a name collision refuses before
//  anything is minted — the registry's declarations, and Copy for AI.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withDoorSession<T>(
    _ body: @MainActor (AppSession) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

@MainActor
@Suite("Document import door + Copy for AI (13n-a)")
struct DocumentImportDoorTests {
    private let header = VariorumDocument.alternatesHeader
    private let footer = VariorumDocument.alternatesFooter

    /// A fresh folder under the temp dir: `files` maps folder-relative paths
    /// to contents; returns the folder's URL.
    private func folder(_ name: String, _ files: [String: String]) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13na-\(UUID().uuidString)")
            .appendingPathComponent(name)
        for (path, contents) in files {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(contents.utf8).write(to: url)
        }
        return root
    }

    private func count(_ session: AppSession, _ sql: String) async throws -> Int {
        try await session.database.read { try Int.fetchOne($0, sql: sql) ?? -1 }
    }

    private var chapterOne: String {
        """
        {t:"abertura"} {#percy/pt-en}

        Eu não pedi para herdar o observatório.

        \(header)

        take: "english"

        Honestly, I never asked for the observatory.

        \(footer)
        """
    }

    // MARK: - The door, end to end

    @Test func aDroppedOrPickedFolderBecomesABookInOneUndoableGesture() async throws {
        try await withDoorSession { session in
            let url = try folder("o ladrão de raios", [
                "1 capítulo um/01 abertura.md": chapterOne,
                "1 capítulo um/02 segundo.txt": "Segundo.",
                "2 capítulo dois/01 fim.variorum": "Fim.",
                "posfácio.md": "Depois.",
                "capa.png": "not text",
                ".DS_Store": "hidden",
            ])
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

            let speech = await DocumentImporter.importURLs([url], session: session)
            #expect(speech.kind == .receipt)
            #expect(speech.text
                == "Imported \u{201C}o ladrão de raios\u{201D} \u{2014} 4 notes in 2 chapters \u{00B7} \u{2325}\u{2318}Z undoes")
            let book = try #require(try await session.database.read { db in
                try Reading.fetchOne(db, sql: "SELECT * FROM reading WHERE name = 'o ladrão de raios'")
            })
            #expect(speech.opens == .reading(book.id))
            #expect(try await count(session, "SELECT COUNT(*) FROM reading_section WHERE deleted_at IS NULL") == 2)
            #expect(try await count(session, """
                SELECT COUNT(*) FROM reading_post WHERE deleted_at IS NULL AND status = 'member'
                """) == 4)

            // ONE gesture, ONE entry — and it takes the whole book.
            #expect(session.undoStack.depth == 1)
            let stack = session.undoStack
            _ = try await session.runner.run { ops in try stack.undo(with: ops) }
            #expect(try await count(session, "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 0)
            #expect(try await count(session, "SELECT COUNT(*) FROM container WHERE deleted_at IS NULL") == 0)

            // The source is one-way: nothing on disk changed.
            let chapter = try String(
                contentsOf: url.appendingPathComponent("1 capítulo um/01 abertura.md"), encoding: .utf8)
            #expect(chapter == chapterOne)
        }
    }

    @Test func aPickedFileBecomesANoteInThePoolAndSeveralItemsAreOneGesture() async throws {
        try await withDoorSession { session in
            let a = try folder("loose", ["note one.md": "One.", "note two.md": "{t:\"Two\"}\n\nTwo."])
            defer { try? FileManager.default.removeItem(at: a.deletingLastPathComponent()) }
            let one = await DocumentImporter.importURLs(
                [a.appendingPathComponent("note one.md")], session: session)
            #expect(one.text == "Imported \u{201C}note one\u{201D} to the Pool \u{00B7} \u{2325}\u{2318}Z undoes")
            if case .post? = one.opens {} else { Issue.record("a lone note opens itself") }

            let both = await DocumentImporter.importURLs(
                [a.appendingPathComponent("note two.md"), a], session: session)
            #expect(both.kind == .receipt)
            #expect(both.text == "Imported 1 book and 1 note to the Pool \u{00B7} \u{2325}\u{2318}Z undoes")
            #expect(both.opens == nil)
            #expect(session.undoStack.depth == 2)
        }
    }

    @Test func aMalformedFileAnywhereRefusesTheWholeFolderNamingFileAndLine() async throws {
        try await withDoorSession { session in
            let url = try folder("broken book", [
                "ok.md": "Fine.",
                "Chapter 1/bad.md": "A\n\n\(header)\n\ntake: 2\n\nnever ends",
            ])
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
            let speech = await DocumentImporter.importURLs([url], session: session)
            #expect(speech.kind == .refusal)
            #expect(speech.text == "Couldn\u{2019}t import \u{201C}broken book\u{201D} \u{2014} "
                + "\u{201C}Chapter 1/bad.md\u{201D}, line 3: this alternates section never ends "
                + "\u{2014} it needs a \u{201C}\(footer)\u{201D} line.")
            #expect(try await count(session, "SELECT COUNT(*) FROM container") == 0)
            #expect(try await count(session, "SELECT COUNT(*) FROM reading") == 0)
            #expect(session.undoStack.depth == 0)
        }
    }

    @Test func aNameCollisionRefusesBeforeAnythingIsMinted() async throws {
        try await withDoorSession { session in
            _ = try await session.runner.run { ops in
                try ops.createReading(name: "Second Book", kind: .book)
            }
            let first = try folder("first book", ["a.md": "A."])
            let second = try folder("second book", ["b.md": "B."])
            defer {
                try? FileManager.default.removeItem(at: first.deletingLastPathComponent())
                try? FileManager.default.removeItem(at: second.deletingLastPathComponent())
            }
            let speech = await DocumentImporter.importURLs([first, second], session: session)
            #expect(speech.kind == .refusal)
            #expect(speech.text.hasPrefix("Couldn\u{2019}t import \u{201C}Second Book\u{201D}"))
            // Not even the first folder's book is minted (or left in the Trash).
            #expect(try await count(session, "SELECT COUNT(*) FROM container") == 0)
            #expect(try await count(session, "SELECT COUNT(*) FROM reading") == 1)
            #expect(session.undoStack.depth == 0)
        }
    }

    @Test func aFileTheDoorDoesNotReadRefusesByName() async throws {
        try await withDoorSession { session in
            let url = try folder("pics", ["photo.jpg": "x"]).appendingPathComponent("photo.jpg")
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent().deletingLastPathComponent()) }
            let speech = await DocumentImporter.importURLs([url], session: session)
            #expect(speech == DocumentImportSpeech(
                kind: .refusal,
                text: "Couldn\u{2019}t import \u{201C}photo.jpg\u{201D} \u{2014} only .md, .txt and .variorum files import.",
                opens: nil))
        }
    }

    // MARK: - Ladder round 1 (F2, F3, F6, F7)

    /// F2: the Bookcase drop is a CONTEXT MINT (AppSpec §12 — "a context mint
    /// lands on the solo'd shelf"; the sitting record §19.1, "you're looking
    /// at where you're filing"): a folder dropped while a shelf is solo'd
    /// lands on that shelf, so the book appears on the board it was dropped
    /// on; dropped from All it lands unshelved (§19). The delegate is built
    /// exactly as `ShelfView` builds it, from the board's `mintShelfID`.
    @Test func aFolderDroppedOnASoloedShelfLandsOnThatShelf() async throws {
        try await withDoorSession { session in
            let suite = "variorum-13na-door-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let work = try #require(await model.createShelf(named: "Work"))
            for _ in 0..<200 where model.shelves.count != 1 {
                try? await Task.sleep(for: .milliseconds(10))
            }

            let filed = try folder("filed here", ["a.md": "A."])
            let loose = try folder("loose book", ["b.md": "B."])
            defer {
                try? FileManager.default.removeItem(at: filed.deletingLastPathComponent())
                try? FileManager.default.removeItem(at: loose.deletingLastPathComponent())
            }
            func shelf(of name: String) async throws -> String? {
                try await session.database.read {
                    try String.fetchOne($0, sql: "SELECT shelf_id FROM reading WHERE name = ?", arguments: [name])
                }
            }

            model.scope = .shelf(work)
            let soloDrop = BookcaseImportDrop(
                session: session, shelfID: model.mintShelfID, targeted: .constant(false), deliver: { _ in })
            #expect(await soloDrop.land([filed]).kind == .receipt)
            #expect(try await shelf(of: "filed here") == work, "dropped on Work, solo'd — it lands on Work")

            model.scope = .all
            let allDrop = BookcaseImportDrop(
                session: session, shelfID: model.mintShelfID, targeted: .constant(false), deliver: { _ in })
            #expect(await allDrop.land([loose]).kind == .receipt)
            #expect(try await shelf(of: "loose book") == nil, "dropped from All — unshelved")
        }
    }

    /// F3: a receipt says "to the Pool" only about a note that IS in the Pool
    /// (bookless). A living book whose rule hears the imported `{#dream}`
    /// seats the note (IC-8, the one application road), so the receipt names
    /// the book that took it.
    @Test func aNoteCollectedByALivingBookIsNotSaidToLandInThePool() async throws {
        try await withDoorSession { session in
            _ = try await session.runner.run { ops in
                let tag = try ops.createTag(name: "dream")
                return try ops.createReading(
                    name: "dream journal", kind: .book,
                    querySpec: try RuleGrammar.encode(.tag(tag.id))).id
            }
            let dir = try folder("loose", [
                "flying.md": "{#dream}\n\nI was flying.",
                "grocery list.md": "Eggs.",
            ])
            defer { try? FileManager.default.removeItem(at: dir.deletingLastPathComponent()) }

            let one = await DocumentImporter.importURLs(
                [dir.appendingPathComponent("flying.md")], session: session)
            #expect(one.kind == .receipt)
            #expect(one.text
                == "Imported \u{201C}flying\u{201D} \u{2014} collected by \u{201C}dream journal\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes")

            let two = await DocumentImporter.importURLs(
                [dir.appendingPathComponent("grocery list.md"), dir.appendingPathComponent("flying.md")],
                session: session)
            #expect(two.text == "Imported 1 note to the Pool and 1 note collected by "
                + "\u{201C}dream journal\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes")
        }
    }

    /// F6: a chapter folder whose name trims to nothing refuses in the plan,
    /// before item one mints — so a refused gesture leaves nothing behind,
    /// not even the earlier items rolled back into the Trash.
    @Test func aBlankChapterFolderRefusesBeforeAnythingIsMinted() async throws {
        try await withDoorSession { session in
            let loose = try folder("loose", ["a.md": "A."])
            let book = try folder("spaced book", ["b.md": "B.", " /c.md": "C."])
            defer {
                try? FileManager.default.removeItem(at: loose.deletingLastPathComponent())
                try? FileManager.default.removeItem(at: book.deletingLastPathComponent())
            }
            let speech = await DocumentImporter.importURLs(
                [loose.appendingPathComponent("a.md"), book], session: session)
            #expect(speech.kind == .refusal)
            #expect(speech.text == "Couldn\u{2019}t import \u{201C}spaced book\u{201D} \u{2014} "
                + "one of its folders has a blank name, and a chapter needs one.")
            #expect(try await count(session, "SELECT COUNT(*) FROM container") == 0, "the Trash stays empty")
            #expect(try await count(session, "SELECT COUNT(*) FROM reading") == 0)
            #expect(session.undoStack.depth == 0)
        }
    }

    /// F7: a PACKAGE inside a folder (an `.rtfd`, a system-declared package)
    /// is neither a chapter nor a file — the walk skips its contents, and the
    /// package itself must not become an empty chapter named after it.
    @Test func aPackageInsideAFolderIsNeitherAChapterNorAFile() async throws {
        try await withDoorSession { session in
            let url = try folder("with a package", [
                "a.rtfd/TXT.rtf": "{\\rtf1\\ansi x}",
                "b.md": "B.",
            ])
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
            let speech = await DocumentImporter.importURLs([url], session: session)
            #expect(speech.text
                == "Imported \u{201C}with a package\u{201D} \u{2014} 1 note \u{00B7} \u{2325}\u{2318}Z undoes")
            #expect(try await count(session, "SELECT COUNT(*) FROM reading_section") == 0)
        }
    }

    // MARK: - The words

    @Test func theReceiptsCountWhatLanded() {
        #expect(DocumentImportCopy.bookCounts(notes: 12, chapters: 3) == "12 notes in 3 chapters")
        #expect(DocumentImportCopy.bookCounts(notes: 1, chapters: 1) == "1 note in 1 chapter")
        #expect(DocumentImportCopy.bookCounts(notes: 4, chapters: 0) == "4 notes")
        #expect(DocumentImportCopy.receipt([.book(readingID: "r", name: "o ladrão de raios", notes: 12, chapters: 3)])
            == "Imported \u{201C}o ladrão de raios\u{201D} \u{2014} 12 notes in 3 chapters \u{00B7} \u{2325}\u{2318}Z undoes")
    }

    @Test func theReceiptsSayWhereEachNoteWent() {
        // Ladder F3's copy: "to the Pool" only for a bookless note; a
        // collected one names the book(s) that took it.
        let undo = " \u{00B7} \u{2325}\u{2318}Z undoes"
        #expect(DocumentImportCopy.receipt([.note(postID: "p", title: "t", collectedBy: [])])
            == "Imported \u{201C}t\u{201D} to the Pool" + undo)
        #expect(DocumentImportCopy.receipt([.note(postID: "p", title: "t", collectedBy: ["a", "b"])])
            == "Imported \u{201C}t\u{201D} \u{2014} collected by \u{201C}a\u{201D} and \u{201C}b\u{201D}" + undo)
        #expect(DocumentImportCopy.receipt([.note(postID: "p", title: "t", collectedBy: ["a", "b", "c"])])
            == "Imported \u{201C}t\u{201D} \u{2014} collected by \u{201C}a\u{201D} and 2 other books" + undo)
        #expect(DocumentImportCopy.receipt([
            .book(readingID: "r", name: "b", notes: 2, chapters: 0),
            .note(postID: "p1", title: "x", collectedBy: []),
            .note(postID: "p2", title: "y", collectedBy: ["a"]),
            .note(postID: "p3", title: "z", collectedBy: ["c"]),
        ]) == "Imported 1 book, 1 note to the Pool and 2 notes collected by your books" + undo)
    }

    @Test func everyDocumentRefusalNamesItsLineInSentenceCase() {
        let reasons: [VariorumDocument.Failure.Reason] = [
            .empty, .alternatesWithoutParagraph, .unterminatedAlternates, .textBeforeFirstTake,
            .alternatesInsideAlternates(openedAt: 3), .endWithoutAlternates,
        ]
        for reason in reasons {
            let text = DocumentImportCopy.refusal(.init(reason, line: 9, file: "a.md"), folder: nil)
            #expect(text.hasPrefix("Couldn\u{2019}t import \u{201C}a.md\u{201D} \u{2014} line 9: "))
            #expect(text.hasSuffix("."))
        }
        #expect(DocumentImportCopy.refusal(.init(.noImportableFiles, file: "Empty"), folder: "Empty")
            == "Couldn\u{2019}t import \u{201C}Empty\u{201D} \u{2014} it holds no .md, .txt or .variorum files.")
    }

    // MARK: - The registry

    @Test func theDoorsAreDeclaredAndRendered() {
        let importDoor = CapabilityRegistry.capability(.importFiles)
        #expect(importDoor.verb == "Import\u{2026}")
        #expect(importDoor.doors == [.menuBar, .palette, .surface])
        #expect(ShelfView.surfaceCapabilities.contains(.importFiles))

        let copy = CapabilityRegistry.capability(.copyForAI)
        #expect(copy.verb == "Copy full text")
        #expect(copy.doors == [.bottomBar, .palette])
        #expect(CommitBar.renderedCapabilities.contains(.copyForAI))
        #expect(TakesBottomBar.renderedCapabilities.contains(.copyForAI))
        #expect(ShellActions.paletteActs.contains(.copyForAI))
        // Available wherever a note is; honestly grey (and speaking) where none is.
        #expect(CapabilityRegistry.availability(.copyForAI, in: CapabilityContext(mode: .write)) == .act)
        #expect(CapabilityRegistry.availability(.copyForAI, in: CapabilityContext(mode: nil)) == .unavailable)
    }

    // MARK: - Copy for AI

    @Test func copyForAIPutsTheDocumentOnTheClipboardAndWritesNothing() async throws {
        try await withDoorSession { session in
            let post = try await session.runner.run { ops in
                let post = try ops.createPost(title: "o ladrão de raios — ch 1")
                let block = try ops.newBlock(
                    in: post.id, text: "Eu não pedi para herdar o observatório.", registeringUndo: false)
                let take = try ops.branchVariant(block.block.id, from: block.variant.id)
                try ops.autosave(take.id, text: "Honestly, I never asked for the observatory.", charDelta: 5)
                try ops.setTakeLabel(take.id, label: "english")
                return post
            }
            let board = NSPasteboard(name: .init("variorum-13na-\(UUID().uuidString)"))
            defer { board.releaseGlobally() }
            try await session.database.write { try $0.execute(sql: "DELETE FROM sync_outbox") }

            await CopyForAI.copy(postID: post.id, session: session, pasteboard: board)
            let expected = try await session.database.read {
                try Queries.variorumDocumentText($0, postID: post.id)
            }
            #expect(board.string(forType: .string) == expected)
            #expect(expected.hasPrefix("{t:\"o ladrão de raios — ch 1\"}\n\nEu não pedi para herdar o observatório."))
            #expect(expected.contains("take: \"english\"\n\nHonestly, I never asked for the observatory."))
            // The export pin: copying wrote no row.
            #expect(try await count(session, "SELECT COUNT(*) FROM sync_outbox") == 0)

            // …and what it copied imports back as the same document.
            let parsed = try VariorumDocument.parse(expected)
            #expect(VariorumDocument.serialize(parsed) == expected)

            // WA-2 (the 13n-a walk, W5 — the orchestrator's PROVISIONAL copy
            // ruling): the receipt says what happened and nothing more, so
            // it never truncates in a bar (the long sentence did, in
            // Terminal). Teaching lives elsewhere.
            #expect(session.status.spoken?.text == "Copied full text.")
            #expect(session.status.spoken?.kind == .receipt)
        }
    }

    // MARK: - Where the import's receipt lands (WA-1)

    /// **WA-1 (the 13n-a walk, W1):** File ▸ Import… OPENS the book it made
    /// (fire-and-DO), and a freshly opened book stands in Outline — where the
    /// quiet receipt sat in the navigator's ~200 pt foot and truncated
    /// ("Imported “o ladrão de…"; the counts and ⌥⌘Z never showed). The book
    /// surfaces' ONE placement rule now puts it at the MAIN column's
    /// trailing foot: the page's foot in Outline and Read's flow, the mode's
    /// own bottom bar in Book and Read's pages (the page foot again while an
    /// empty book draws no bar), Index's column footer unchanged, and the
    /// live note box's bar while a note is live. No case is the navigator.
    /// A design row — the orchestrator's re-walk is its evidence; this pins
    /// the rule every host asks.
    @Test func theImportsReceiptLandsAtTheMainColumnsFootNeverTheNavigator() async throws {
        try await withDoorSession { session in
            let url = try folder("o ladrão de raios", ["1 o semideus/01 abertura.md": chapterOne])
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
            let speech = await DocumentImporter.importURLs([url], session: session)
            guard case .reading(let bookID)? = speech.opens else {
                Issue.record("the door opens the book it made")
                return
            }
            // The book it opens stands in Outline, with no note selected.
            let structure = BookStructureModel(session: session, readingID: bookID)
            #expect(structure.mode == .outline)
            #expect(BookNoteBox.quietReceiptHome(
                mode: structure.mode, pagedRead: false, modeBarShown: true, box: .empty)
                == .pageFoot)
        }
        typealias Home = BookNoteBox.QuietReceiptHome
        func home(
            _ mode: BookStructureModel.ViewMode, paged: Bool = false, bar: Bool = true,
            _ box: NoteBoxState?
        ) -> Home {
            BookNoteBox.quietReceiptHome(mode: mode, pagedRead: paged, modeBarShown: bar, box: box)
        }
        #expect(home(.outline, .selected("n")) == .pageFoot)
        #expect(home(.read, nil) == .pageFoot, "Read's flow: no bar, no box")
        #expect(home(.read, paged: true, nil) == .modeBottomBar)
        #expect(home(.read, paged: true, bar: false, nil) == .pageFoot, "an empty book draws no bar")
        #expect(home(.spread, .empty) == .modeBottomBar)
        #expect(home(.spread, bar: false, .empty) == .pageFoot)
        #expect(home(.index, .selected("n")) == .indexColumnFooter)
        for mode in [BookStructureModel.ViewMode.outline, .spread, .index] {
            #expect(home(mode, .live("n")) == .liveNoteBox, "one receipt never draws twice")
        }
    }

    // MARK: - Undo with a note on screen (WA-3)

    /// Bounded async settle (the standing poll rule — never a RunLoop pump).
    private func settle(_ predicate: () -> Bool) async {
        for _ in 0..<2000 where !predicate() {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// **WA-3 (the 13n-a walk, W3):** ⌥⌘Z on an import while one of its
    /// notes is open left the pane live on the tombstoned note ("in no book",
    /// empty, "open tail") and the note in the Open strip. The navigate-away
    /// road already exists — the Trash door's `.variorumNotesDeleted` signal,
    /// which every window turns into `WorkspaceModel.notesDeleted` (the pane
    /// leaves, the strip drops it) and a note-only window turns into a close
    /// — so the undo door rides it for every note it left dead that a pane,
    /// a strip, or any window's surface was showing. Red on the pre-fix
    /// tree: the undo posted nothing.
    @Test func undoingAnImportGetsEveryPaneAndTheOpenStripOffItsNotes() async throws {
        try await withDoorSession { session in
            let url = try folder("o ladrão de raios", [
                "1 o semideus/01 abertura.md": chapterOne,
                "posfácio.md": "Depois.",
            ])
            defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            #expect(await DocumentImporter.importURLs([url], session: session).kind == .receipt)
            let notes = try await session.database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT id FROM container
                    WHERE kind = 'post' AND deleted_at IS NULL ORDER BY title
                    """)
            }
            try #require(notes.count == 2)
            // "abertura" open in this window's pane (and so in its Open
            // strip); "posfácio" held by a surface in ANOTHER window — the
            // session's holder registry is the only thing that knows it.
            shell.workspace.select(.post(notes[0]))
            _ = session.autosave(forPost: notes[1])
            defer { _ = session.releaseAutosave(forPost: notes[1]) }

            let heard = LockIsolated<[String]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumNotesDeleted, object: nil, queue: .main
            ) { note in
                let ids = (note.userInfo?["postIDs"] as? [String]) ?? []
                heard.withValue { $0 += ids }
            }
            defer { NotificationCenter.default.removeObserver(token) }

            actions.structuralUndo()
            await settle {
                session.status.spoken?.text.contains("Undid") == true && !heard.value.isEmpty
            }
            #expect(session.status.spoken?.text == "Undid: Import")
            #expect(Set(heard.value) == Set(notes), "every shown note the undo left dead")

            // The window's own listener's act (RootView composes exactly this).
            _ = shell.workspace.notesDeleted(heard.value)
            #expect(shell.workspace.selections[.primary] == .library)
            #expect(shell.workspace.openNotes.ids.isEmpty)

            // A redo that leaves nothing dead says nothing on that road.
            heard.withValue { $0 = [] }
            actions.structuralRedo()
            await settle { session.status.spoken?.text.contains("Redid") == true }
            #expect(session.status.spoken?.text == "Redid: Import")
            #expect(heard.value.isEmpty)
        }
    }
}
