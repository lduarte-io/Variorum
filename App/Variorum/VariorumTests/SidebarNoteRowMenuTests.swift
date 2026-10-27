//
//  SidebarNoteRowMenuTests.swift
//  VariorumTests
//
//  **VX-425 (the VX-439 run, A-439-16) — the sidebar's note rows get a real
//  menu.** Her ask (2026-10-18) and a beta tester's: a two-finger click on an
//  Open row (and the sidebar's other note rows) offers Rename, Delete note,
//  Close; widened at her word (2026-10-26) with Move to Wing / Copy to Wing and
//  Export — her "empowered note sidebar". Single-row (several rows is VX-344's).
//
//  A context menu cannot be mounted or pressed headlessly, so the menu's
//  WIRING is read from the source (the `theLibraryNoteRowMenuRendersItsDeclared
//  Doors` / `theOpenRowMenuRendersCloseAllFromTheRegistry` precedent), the
//  declarations are read from the registry, and the acts' own state
//  transitions run on an in-memory store: the rename's seed is the STORED
//  title, the rename road writes it, and the wing doors' read names only the
//  notes of another wing. The walk (the orchestrator's) right-clicks the rows.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-425 — the sidebar's note rows: Rename · Move/Copy to Wing · Export · Close · Delete")
struct SidebarNoteRowMenuTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ path: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: path), encoding: .utf8)
    }

    /// A function's body, read from the source: from `header` to the first
    /// line closing at four spaces' indent.
    private static func body(of header: String, in source: String) throws -> String {
        let start = try #require(source.range(of: header), "\(header) is in the source")
        let rest = source[start.upperBound...]
        let end = rest.range(of: "\n    }\n")?.lowerBound ?? rest.endIndex
        return String(rest[..<end])
    }

    // MARK: - The declarations (P-1)

    /// Rename… is declared ONCE and both row families read its verb: the
    /// Library's note rows (whose undeclared "Rename…" it now is) and the
    /// sidebar's note rows; Export Note… gains the row door.
    @Test func renameIsDeclaredOnceAndEveryRowFamilyRendersItFromTheRegistry() throws {
        let rename = CapabilityRegistry.capability(.renameNote)
        #expect(rename.verb == "Rename\u{2026}")
        #expect(rename.scope == .post)
        #expect(rename.doors == [.contextMenu])
        #expect(rename.shortcutLabel == nil)
        #expect(CapabilityRegistry.availability(.renameNote, in: CapabilityContext()) == .act,
                "the door carries its row — no context gates it")
        #expect(SidebarView.noteRowMenuCapabilities == [.renameNote, .exportNote])
        #expect(LibraryCatalogView.contextMenuCapabilities.contains(.renameNote))
        #expect(CapabilityRegistry.capability(.exportNote).doors.contains(.contextMenu))
        // The shared grammar the Open rows now render too (the reversal of the
        // recorded "the Open strip does not render Delete", at her ask).
        for id: CapabilityID in [.deleteNote, .moveNoteToWing, .copyNoteToWing] {
            #expect(SidebarView.contextMenuCapabilities.contains(id), "\(id)")
        }
        let library = try Self.source("Variorum/Features/Library/LibraryCatalogView.swift")
        #expect(!library.contains("Button(\"Rename\u{2026}\")"), "the Library's literal is retired for the verb")
        #expect(library.contains(".noteRenameAlert(target: $renameTarget, title: $renameTitle)"),
                "the Library presents the ONE rename ask")
    }

    // MARK: - The Open row's menu, read

    /// The Open row's menu: the note's acts (Rename… · Move/Copy to Wing ▸ ·
    /// Export Note…), then the row's (Close · Close All Notes), then Delete
    /// Note… LAST, set apart by a divider — and the ✕ stays close-only.
    @Test func theOpenRowMenuCarriesTheNoteActsThenCloseThenDeleteLast() throws {
        let sidebar = try Self.source("Variorum/Features/Library/SidebarView.swift")
        let row = try Self.body(of: "private func openRow(", in: sidebar)
        let menu = try #require(row.range(of: ".contextMenu {"), "the row has a menu")
        let tail = String(row[menu.lowerBound...])
        let acts = try #require(tail.range(of: "noteRowActs(noteID, title: workspace.label(for: destination))"))
        let close = try #require(tail.range(of: "Button(\"Close\")"))
        let closeAll = try #require(tail.range(of: "CapabilityRegistry.capability(.closeAllNotes).verb"))
        let delete = try #require(tail.range(of: "deleteNoteDoor(noteID)"))
        #expect(acts.lowerBound < close.lowerBound && close.lowerBound < closeAll.lowerBound
                && closeAll.lowerBound < delete.lowerBound, "acts · Close · Close All · Delete")
        #expect(tail[closeAll.upperBound..<delete.lowerBound].contains("Divider()"),
                "Delete is set apart from the row's Close by a divider")
        // The ✕ is unchanged: it closes the row and says the note is untouched.
        let before = String(row[..<menu.lowerBound])
        #expect(before.contains("Button(\"\\u{2715}\") { Self.closeRow(noteID, in: workspace, selection: $selection) }"))
        #expect(before.contains(".help(Self.closeRowHelp)"))
        #expect(SidebarView.closeRowHelp.contains("the note itself is untouched"))
        #expect(!before.contains("deleteNoteDoor"), "no delete outside the menu")
    }

    /// The note acts' one builder: Rename… asks with the STORED title, the
    /// wing doors list the wings other than the note's OWN, Export Note… runs
    /// VX-125's one act on THIS row's note; Delete Note… asks the one shared
    /// confirm.
    @Test func theNoteActsRunTheSharedRoads() throws {
        let sidebar = try Self.source("Variorum/Features/Library/SidebarView.swift")
        let acts = try Self.body(of: "private func noteRowActs(", in: sidebar)
        #expect(acts.contains("CapabilityRegistry.capability(.renameNote).verb"))
        #expect(acts.contains("NoteRename.storedTitle(session: session, postID: noteID)"),
                "the seed is the stored title (R6-3)")
        #expect(acts.contains("WingNoteDoors(") && acts.contains("fromWing: noteRowWingIDs[noteID]"),
                "Move/Copy to Wing ▸ from the note's own wing")
        #expect(acts.contains("CapabilityRegistry.capability(.exportNote).verb"))
        #expect(acts.contains("NoteExport.export(postID: noteID, session: session)"), "this row's note")
        let delete = try Self.body(of: "private func deleteNoteDoor(", in: sidebar)
        #expect(delete.contains("Button(RecoveryCopy.deleteNoteTitle, role: .destructive)"))
        #expect(delete.contains("NoteDeletion.ask(session: session, postIDs: [noteID])"))
        // The column hosts the three asks — each shared with the Library's rows.
        #expect(sidebar.contains(".noteRenameAlert(target: $renameTarget, title: $renameTitle)"))
        #expect(sidebar.contains("await model.rename(postID: postID, title: title)"))
        #expect(sidebar.contains(".deleteNoteConfirmDialog($pendingDelete)"))
        #expect(sidebar.contains("NoteDeletion.fire(session: session, postIDs: confirm.postIDs)"))
        #expect(sidebar.contains(".wingMoveConfirm($wingMove, wings: wings)"))
        let root = try Self.source("Variorum/RootView.swift")
        #expect(root.contains("wings: wings)"), "the shell hands the column its wings")
    }

    /// Starred's NOTE rows carry the same acts and Delete; a starred BOOK's
    /// row keeps the book row menu (17y B3 (l)), untouched.
    @Test func aStarredNotesRowCarriesTheNoteActsAndABooksKeepsItsMenu() throws {
        let sidebar = try Self.source("Variorum/Features/Library/SidebarView.swift")
        let row = try Self.body(of: "private func starredRow(", in: sidebar)
        let menu = try #require(row.range(of: ".contextMenu {"))
        let tail = String(row[menu.lowerBound...])
        #expect(tail.contains("BookRowMenu("), "a book keeps its row menu")
        let note = try #require(tail.range(of: "if item.target.kind == .post {"))
        let rest = tail[note.upperBound...]
        #expect(rest.contains("noteRowActs(item.target.id"))
        #expect(rest.contains("deleteNoteDoor(item.target.id)"))
    }

    // MARK: - The acts' state

    /// **The rename's seed is the STORED title, never the display answer**
    /// (R6-3): a titled note seeds its title; an untitled one — shown by its
    /// date — seeds nothing. And the one rename road writes it: trimmed; a
    /// blank stores NULL (the note reads "Untitled" again).
    @Test func theRenameSeedIsTheStoredTitleAndTheRoadWritesIt() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let titled = try ops.createPost(title: "Kept")
            let untitled = try ops.createPost(entryDate: "2026-10-27")
            #expect(await NoteRename.storedTitle(session: session, postID: titled.id) == "Kept")
            #expect(await NoteRename.storedTitle(session: session, postID: untitled.id) == "")
            let shown = try await db.read { try Queries.noteDisplayTitle($0, id: untitled.id) }
            #expect(shown?.isEmpty == false, "it is SHOWN by its date — which the seed must not take: \(String(describing: shown))")
            let library = LibraryViewModel(session: session)
            await library.rename(postID: untitled.id, title: "  A name  ")
            #expect(try await db.read { try Queries.containerTitle($0, id: untitled.id) } == "A name")
            await library.rename(postID: titled.id, title: "   ")
            #expect(try await db.read { try Queries.containerTitle($0, id: titled.id) } == nil, "blank → NULL")
            #expect(library.lastError == nil)
        }
    }

    /// The wing doors' read: only a note living in ANOTHER wing is named (its
    /// wing's id), so its doors list the wings other than its own; a note of
    /// the current wing is absent (its doors read the current wing).
    @Test func theRowsWingReadNamesOnlyOtherWingNotes() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let homeNote = try ops.createPost(title: "home note")
            let studioNote = try ops.createPost(title: "studio note", wingId: studio.id)
            let fromHome = try await db.read { db in
                try WingFollow.crossWingIDs(db, noteIDs: [homeNote.id, studioNote.id], current: "")
            }
            #expect(fromHome == [studioNote.id: studio.id])
            let fromStudio = try await db.read { db in
                try WingFollow.crossWingIDs(db, noteIDs: [homeNote.id, studioNote.id], current: studio.id)
            }
            #expect(fromStudio == [homeNote.id: ""], "Home is the virtual wing ''")
        }
    }

    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 425))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }
}
