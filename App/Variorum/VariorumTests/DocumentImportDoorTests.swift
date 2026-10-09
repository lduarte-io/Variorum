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

    // MARK: - The words

    @Test func theReceiptsCountWhatLanded() {
        #expect(DocumentImportCopy.bookCounts(notes: 12, chapters: 3) == "12 notes in 3 chapters")
        #expect(DocumentImportCopy.bookCounts(notes: 1, chapters: 1) == "1 note in 1 chapter")
        #expect(DocumentImportCopy.bookCounts(notes: 4, chapters: 0) == "4 notes")
        #expect(DocumentImportCopy.receipt([.book(readingID: "r", name: "o ladrão de raios", notes: 12, chapters: 3)])
            == "Imported \u{201C}o ladrão de raios\u{201D} \u{2014} 12 notes in 3 chapters \u{00B7} \u{2325}\u{2318}Z undoes")
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
        #expect(copy.verb == "Copy for AI")
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
        }
    }
}
