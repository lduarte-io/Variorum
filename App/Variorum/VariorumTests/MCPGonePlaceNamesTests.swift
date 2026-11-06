//
//  MCPGonePlaceNamesTests.swift
//  VariorumTests (Mac)
//
//  VX-858 (the VX-878 run, batch 3 — the record
//  `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): A MOVED
//  NOTE'S GONE PLACE IS NAMED, NEVER THE WING IT MOVED TO. Bug class, red on
//  old. The traced mechanism: a wire `move_note_to_wing`'s receipt is keyed on
//  the DESTINATION WING (`targetID`/`targetTitle` — so a sweep's moves coalesce
//  into one line) while its landing is the NOTE; `MCPDoor.landReceipt` named
//  the change her press can open by `receipt.targetTitle`, so when the note
//  died her Open › (and ⌥⌘O) said "“Studio” is gone, …" — the wing, which
//  stands. The class: every receipt whose landing is not its target (a copy
//  to a wing, a book moved to a wing, a note added to or taken out of a book,
//  a block moved across notes). The fix names the landing through the trail's
//  ONE brain (`MCPTrail.placeTitle`); every other receipt's words are
//  byte-unchanged (`MCPShowOfferFacesTests`' gone pins hold them).
//
//  Every pin drives the door's REAL roads (`landReceipt`, the quiet line's
//  Open ›, `showLastChange`). Every read is bound before an assertion reads
//  it (the VX-677 record's F-B3-1 — no closure inside a testing macro in these
//  nested closures).
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 858))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Polls `condition` on the main actor until it holds or `timeout` passes.
@MainActor
private func eventually(_ timeout: Duration = .seconds(3), _ condition: () async throws -> Bool) async rethrows -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while clock.now < deadline {
        if try await condition() { return true }
        try? await Task.sleep(for: .milliseconds(20))
    }
    return try await condition()
}

/// A door attached to `session`, one FULL window registered (her press's
/// `creationRouter`).
@MainActor
private struct Rig {
    let door: MCPDoor
    let windows: WindowRegistry
    let router: ShellRouter

    init(_ session: AppSession) {
        door = MCPDoor(serverAllowed: false)
        windows = WindowRegistry()
        router = ShellRouter()
        windows.register(UUID(), router: router, kind: .full)
        door.attach(session: session, windows: windows)
        let router = router
        door.standingProvider = { (.notFrontmost, router) }
    }

    /// ⌥⌘O on the last change, and the refusal it speaks ("nothing" when none).
    func chordWords(_ session: AppSession) async -> String {
        session.status.clear()
        door.showLastChange()
        _ = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
        try? await Task.sleep(for: .milliseconds(100))  // past any delivery
        return session.status.current?.kind == .refusal ? session.status.current?.text ?? "nothing" : "nothing"
    }
}

@MainActor
@Suite("VX-858 — a gone place's refusal names the landing, never another place", .serialized)
struct MCPGonePlaceNamesTests {
    /// **THE EXACT REPRO — RED ON OLD.** A client moved "draft" to the wing
    /// "Studio" (the wire's `.wingMove` receipt, as `MCPWriteTools+WingMove`
    /// builds it); the note was deleted; her press on the receipt line's
    /// Open › — and ⌥⌘O on the last change — says the NOTE is gone. Old: both
    /// said "“Studio” is gone, …" (the wing, which stands).
    @Test func aMovedNotesGonePlaceNamesTheNoteNotTheWing() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let studio = try session.operations.createWing(name: "Studio")
            let rig = Rig(session)
            defer { rig.door.detach() }
            let resting = rig.router.workspace.focusedSelection

            // The receipt line's own Open ›.
            let draft = try session.operations.createPost(title: "draft")
            let draftID = draft.id
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .wingMove, targetID: studio.id, targetTitle: "Studio",
                detail: "draft", show: .note(noteID: draftID, blockID: nil, select: nil), leftBooks: 0))
            let open = try #require(session.status.quietLine?.action)
            try session.operations.deleteContainer(draftID)  // the moved note dies
            open.perform()
            let refused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            try? await Task.sleep(for: .milliseconds(100))
            let lineWords = session.status.current?.text ?? "nothing"
            let afterLine = rig.router.workspace.focusedSelection
            #expect(refused && lineWords == "\u{201C}draft\u{201D} is gone, so claude-code's change can't be opened.",
                    "RED ON OLD: the moved NOTE is named, never the wing it moved to — said: \(lineWords)")
            #expect(!lineWords.contains("Studio"), "RED ON OLD: the wing stands; it is not what is gone")
            #expect(afterLine == resting, "nothing opened")

            // ⌥⌘O's last-change arm — the same change, another client.
            let second = try session.operations.createPost(title: "second")
            let secondID = second.id
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "codex", act: .wingMove, targetID: studio.id, targetTitle: "Studio",
                detail: "second", show: .note(noteID: secondID, blockID: nil, select: nil), leftBooks: 0))
            try session.operations.deleteContainer(secondID)
            let chord = await rig.chordWords(session)
            #expect(chord == "\u{201C}second\u{201D} is gone, so codex's change can't be opened.",
                    "RED ON OLD: ⌥⌘O names the moved note — said: \(chord)")
        }
    }

    /// **THE CLASS — RED ON OLD.** Every receipt whose landing is not its
    /// target names its LANDING: a note copied to a wing (the copy), a book
    /// moved to a wing (the book), a note added to or taken out of a book (the
    /// book); a block moved into another note names no other note (the place's
    /// noun). Old: the wing, the wing, the note, the note, the SOURCE note.
    @Test func everyReceiptKeyedElsewhereNamesItsLanding() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let studio = try session.operations.createWing(name: "Studio")
            let rig = Rig(session)
            defer { rig.door.detach() }

            // A note copied to a wing: the copy dies.
            let copy = try session.operations.createPost(title: "copy of draft")
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .wingCopy, targetID: studio.id, targetTitle: "Studio",
                detail: "copy of draft", show: .note(noteID: copy.id, blockID: nil, select: nil)))
            try session.operations.deleteContainer(copy.id)
            let copied = await rig.chordWords(session)
            #expect(copied == "\u{201C}copy of draft\u{201D} is gone, so claude-code's change can't be opened.",
                    "RED ON OLD: the copy, never the wing — said: \(copied)")

            // A book moved to a wing: the book dies.
            let moved = try session.operations.createReading(name: "lessons", kind: .book, wingId: studio.id)
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .bookWingMove, targetID: studio.id, targetTitle: "Studio",
                detail: "lessons", count: 0, show: .book(bookID: moved.id, sectionID: nil)))
            try session.operations.deleteReading(moved.id)
            let bookMoved = await rig.chordWords(session)
            #expect(bookMoved == "\u{201C}lessons\u{201D} is gone, so claude-code's change can't be opened.",
                    "RED ON OLD: the book, never the wing — said: \(bookMoved)")

            // A note added to a book, and one taken out of a book: the BOOK dies.
            let note = try session.operations.createPost(title: "a note")
            for act in [Operations.MCPWriteAct.bookAdd, .bookRemove, .bookRelease] {
                let book = try session.operations.createReading(name: "shelf \(act)", kind: .book)
                rig.door.landReceipt(MCPWriteReceipt(
                    clientName: "claude-code", act: act, targetID: note.id, targetTitle: "a note",
                    detail: "shelf \(act)", show: .book(bookID: book.id, sectionID: nil)))
                try session.operations.deleteReading(book.id)
                let words = await rig.chordWords(session)
                #expect(words == "\u{201C}shelf \(act)\u{201D} is gone, so claude-code's change can't be opened.",
                        "RED ON OLD: \(act) names the book it landed in, never the note — said: \(words)")
            }

            // A block moved into ANOTHER note: the destination dies — the
            // receipt carries no name for it, so the place's noun, never the
            // source's title.
            let source = try session.operations.createPost(title: "source")
            let destination = try session.operations.createPost(title: "destination")
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .move, targetID: source.id, targetTitle: "source",
                show: .note(noteID: destination.id, blockID: nil, select: nil)))
            try session.operations.deleteContainer(destination.id)
            let blockMoved = await rig.chordWords(session)
            #expect(blockMoved == "That note is gone, so claude-code's change can't be opened.",
                    "RED ON OLD: never the SOURCE's name for a gone destination — said: \(blockMoved)")
        }
    }

    /// **The one brain, read the same by both roads.** `MCPTrail.placeTitle`
    /// names a remove/release receipt's landing — the book (its `detail`, as a
    /// book add's) — so the trail's row and the gone words name it alike.
    /// RED ON OLD: the remove/release arms answered nil (the trail's row said
    /// "a book").
    @Test func theBrainNamesARemovedNotesBook() {
        for act in [Operations.MCPWriteAct.bookRemove, .bookRelease] {
            let receipt = MCPWriteReceipt(
                clientName: "c", act: act, targetID: "n1", targetTitle: "a note", detail: "lessons",
                show: .book(bookID: "b1", sectionID: nil))
            #expect(MCPTrail.placeTitle(of: receipt) == "lessons", "RED ON OLD: \(act) names its book")
        }
        // The guard: a receipt whose landing IS its target keeps its title.
        let take = MCPWriteReceipt(
            clientName: "c", act: .take, targetID: "n1", targetTitle: "draft",
            show: .takes(noteID: "n1", blockID: "b"))
        #expect(MCPTrail.placeTitle(of: take) == "draft")
        // A filing carries its CHAPTER's name, not the book's: the noun.
        let filing = MCPWriteReceipt(
            clientName: "c", act: .filing, targetID: "n1", targetTitle: "a note", detail: "chapter one",
            show: .book(bookID: "b1", sectionID: "s1"))
        #expect(MCPTrail.placeTitle(of: filing) == nil)
    }
}
