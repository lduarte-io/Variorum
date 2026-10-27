//
//  NoteExportTests.swift
//  VariorumTests
//
//  VX-125 (the VX-439 run, A-439-1 + C-125-1) — EXPORT NOTE…: the note as a
//  `.md` file in the Variorum simple format. A FEATURE, so its pins are the
//  state-transition and registry kind (the brief): the file the act writes is
//  Copy full text's text BYTE FOR BYTE (one serializer), it re-imports whole,
//  it writes no row, a cancel says nothing, an empty note refuses in the
//  door's words, archived and sealed notes export, and the door is declared
//  once with its chord and rendered where it is declared (the registry walk's
//  own tables carry the declared ⇔ rendered half).
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
private func withExportSession<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 125))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

@MainActor
@Suite("VX-125 — Export Note… writes Copy full text's text as a .md file")
struct NoteExportTests {
    private func scratchFile(_ name: String) throws -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx125-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(name)
    }

    private func outboxCount(_ session: AppSession) async throws -> Int {
        try await session.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1 }
    }

    /// A titled, tagged note with a labeled and an unlabeled take.
    private func fannedNote(_ session: AppSession) async throws -> Container {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "o ladrão de raios — ch 1")
            let block = try ops.newBlock(
                in: post.id, text: "Eu não pedi para herdar o observatório.", registeringUndo: false)
            let english = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(english.id, text: "Honestly, I never asked for the observatory.", charDelta: 5)
            try ops.setTakeLabel(english.id, label: "english")
            let other = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(other.id, text: "Je ne voulais pas.", charDelta: 3)
            _ = try ops.newBlock(in: post.id, text: "Cuidar de um observatório dá trabalho.", registeringUndo: false)
            let parent = try ops.createTag(name: "percy")
            try ops.applyTag(try ops.createTag(parent: parent.id, name: "pt-en").id, toPost: post.id)
            return post
        }
    }

    @Test func theFileIsCopyFullTextsTextByteForByteAndWritesNoRow() async throws {
        try await withExportSession { session in
            let post = try await fannedNote(session)
            try await session.database.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
            let target = try scratchFile("export.md")
            var offered: String?

            await NoteExport.export(postID: post.id, session: session) { name in
                offered = name
                return target
            }

            let written = try String(contentsOf: target, encoding: .utf8)
            let copied = try await session.database.read {
                try Queries.variorumDocumentText($0, postID: post.id)
            }
            #expect(written == copied, "the file IS Copy full text's text — one serializer")
            #expect(written.hasPrefix("{t:\"o ladrão de raios — ch 1\"} {#percy/pt-en}\n\nEu não pedi para herdar o observatório."))
            #expect(written.contains("take: \"english\"\n\nHonestly, I never asked for the observatory."))
            #expect(offered == "o ladrão de raios — ch 1.md", "the panel offers the note's own name")
            // It re-imports as the same document (the round trip's letter).
            let reread = try VariorumDocumentFolder.note(named: "export.md", contents: written)
            #expect(reread.document.title == "o ladrão de raios — ch 1")
            #expect(reread.document.tagPaths == ["percy/pt-en"])
            #expect(VariorumDocument.serialize(reread.document) == written)
            // The export pin: reading for the file wrote nothing.
            #expect(try await outboxCount(session) == 0)
            #expect(session.status.spoken?.text == "Exported \u{201C}export.md\u{201D}.")
            #expect(session.status.spoken?.kind == .receipt)
        }
    }

    @Test func theDefaultNameIsTheDisplayBrainsAndSanitized() async throws {
        #expect(NoteExport.defaultFileName(displayTitle: "a/b: c") == "a-b- c.md")
        #expect(NoteExport.defaultFileName(displayTitle: "///") == "---.md")
        #expect(NoteExport.defaultFileName(displayTitle: "...") == "\(DisplayTitle.placeholder).md")
        #expect(NoteExport.defaultFileName(displayTitle: nil) == "\(DisplayTitle.placeholder).md")
        try await withExportSession { session in
            // A note she never named exports as its DATE — the masthead's and
            // the bulk export's own answer.
            let dated = try await session.runner.run { ops in
                let post = try ops.createPost(title: nil, entryDate: "2026-07-10")
                _ = try ops.newBlock(in: post.id, text: "Dated body.", registeringUndo: false)
                return post
            }
            let contents = try await session.database.read {
                try NoteExport.contents($0, postID: dated.id)
            }
            #expect(contents.defaultFileName == "2026-07-10.md")
            #expect(contents.text == "Dated body.", "no title token for a name she never typed")
        }
    }

    @Test func aCancelWritesNothingAndSaysNothing() async throws {
        try await withExportSession { session in
            let post = try await fannedNote(session)
            var asked = false
            await NoteExport.export(postID: post.id, session: session) { _ in
                asked = true
                return nil
            }
            #expect(asked)
            #expect(session.status.spoken == nil, "her cancel is an answer, not a refusal")
        }
    }

    @Test func anEmptyNoteRefusesBeforeThePanel() async throws {
        try await withExportSession { session in
            let empty = try await session.runner.run { ops in try ops.createPost(title: nil) }
            var asked = false
            await NoteExport.export(postID: empty.id, session: session) { _ in
                asked = true
                return nil
            }
            #expect(!asked, "nothing to write — no panel")
            #expect(session.status.spoken?.text == NoteExport.nothingToExport)
            #expect(session.status.spoken?.kind == .refusal)
        }
    }

    /// A-439-1: export is read-only, so an archived note and a sealed one
    /// export like any other.
    @Test func archivedAndSealedNotesExport() async throws {
        try await withExportSession { session in
            let (archived, sealed) = try await session.runner.run { ops in
                let archived = try ops.createPost(title: "kept")
                _ = try ops.newBlock(in: archived.id, text: "Kept body.", registeringUndo: false)
                try ops.archiveContainer(archived.id)
                let sealed = try ops.createPost(title: "done")
                _ = try ops.newBlock(in: sealed.id, text: "Done body.", registeringUndo: false)
                try ops.lockPost(sealed.id)
                return (archived, sealed)
            }
            for (post, body) in [(archived, "{t:\"kept\"}\n\nKept body."), (sealed, "{t:\"done\"}\n\nDone body.")] {
                let target = try scratchFile("\(post.id).md")
                await NoteExport.export(postID: post.id, session: session) { _ in target }
                #expect(try String(contentsOf: target, encoding: .utf8) == body)
                #expect(session.status.spoken?.kind == .receipt)
            }
        }
    }

    // MARK: - The door (P-1)

    @Test func theDoorIsDeclaredOnceWithItsChordAndRenderedWhereDeclared() {
        let door = CapabilityRegistry.capability(.exportNote)
        #expect(door.verb == "Export Note\u{2026}")
        #expect(door.scope == .post)
        #expect(Set(door.doors) == [.menuBar, .palette, .bottomBar])
        #expect(door.shortcutLabel == "\u{2325}\u{2318}S")
        let key = EditorCommands.keyEquivalent(for: .exportNote)
        #expect(key?.0 == KeyEquivalent("s") && key?.1 == [.command, .option])
        // C-125-1: the ruled ⇧⌘E stays Extract's — no second act on that key.
        #expect(EditorCommands.keyEquivalent(for: .extract)?.0 == KeyEquivalent("e"))
        #expect(CapabilityRegistry.all.filter { $0.shortcutLabel == "\u{2325}\u{2318}S" }.map(\.id) == [.exportNote])
        #expect(EditorCommands.menuRendered.contains(.exportNote))
        #expect(ShellActions.paletteActs.contains(.exportNote))
        #expect(CommitBar.renderedCapabilities.contains(.exportNote))
        #expect(TakesBottomBar.renderedCapabilities.contains(.exportNote))
        #expect(HelperView.shortcutKeysShown.contains("\u{2325}\u{2318}S"))
        // Available wherever a note is (Copy full text's rule); honestly grey where none is.
        #expect(CapabilityRegistry.availability(.exportNote, in: CapabilityContext(mode: .write)) == .act)
        #expect(CapabilityRegistry.availability(.exportNote, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .exportNote, in: CapabilityContext(mode: nil, writeEditorAttached: true)) == .act)
        #expect(CapabilityRegistry.availability(.exportNote, in: CapabilityContext(mode: nil)) == .unavailable)
    }
}
