//
//  WingSwitcherTests.swift
//  VariorumTests
//
//  13i-d U5 — THE WINGS on the Mac (the sitting record §9; §21 Direction C;
//  R-13id-2). The shared brain (`WingsModel`) over a real session: the
//  switcher's rows and acts, the delete door's refusal NAMING what remains,
//  the note doors (move asks / acts / refuses; copy), the current wing every
//  mint and scoped read follows, the remembered wing (an injected scratch
//  suite — never the Debug app's defaults), and the registry rows.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWingSession<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13i-d U5 — the wing switcher and the cross-wing doors (Mac)", .serialized)
struct WingSwitcherTests {
    private func spoken(_ session: AppSession) -> String? { session.status.spoken?.text }

    /// Home first, then the switcher order; a note's destinations are every
    /// OTHER wing (none while Home stands alone — the doors are not drawn).
    @Test func theRowsListHomeFirstAndTheDestinationsExcludeTheCurrentWing() async throws {
        try await withWingSession { session, _ in
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(wings.rows.map(\.name) == ["Home"])
            #expect(wings.destinations(from: "").isEmpty, "one library — no move/copy doors")
            let a = try session.operations.createWing(name: "Imports")
            let b = try session.operations.createWing(name: "Work")
            await wings.load()
            #expect(wings.rows.map(\.id) == ["", a.id, b.id])
            #expect(wings.destinations(from: a.id).map(\.id) == ["", b.id])
        }
    }

    /// New Wing… mints, switches to it and speaks a receipt; Home's name and a
    /// live wing's name refuse at the door (nothing minted).
    @Test func mintingSwitchesAndATakenNameRefuses() async throws {
        try await withWingSession { session, db in
            let wings = WingsModel(session: session)
            #expect(await wings.mint(named: "  Imports "))
            let minted = try #require(try await db.read { try Queries.wings($0) }.first)
            #expect(session.wing.currentID == minted.id, "the new wing is where she stands")
            #expect(wings.currentName == "Imports")
            #expect(spoken(session) == WingCopy.minted("Imports"))
            #expect(await wings.mint(named: "home") == false)
            #expect(spoken(session) == "Home is the built-in wing's name — pick another.")
            #expect(await wings.mint(named: "IMPORTS") == false)
            #expect(try await db.read { try Queries.wings($0) }.count == 1)
        }
    }

    /// R-13id-2 at the DOOR: a non-empty wing's Delete speaks the refusal
    /// naming exactly what remains (no confirm); an emptied wing confirms,
    /// deletes, and the app returns HOME.
    @Test func deleteNamesWhatRemainsThenAnEmptyWingGoesAndHomeReturns() async throws {
        try await withWingSession { session, db in
            let wings = WingsModel(session: session)
            let wing = try session.operations.createWing(name: "Imports")
            await wings.load()
            wings.switchTo(wing.id)
            let note = try session.operations.createPost(title: "n", wingId: wing.id)
            let tag = try session.operations.createTag(name: "imported", wingID: wing.id)
            _ = try session.operations.createReading(name: "b", kind: .book, wingId: wing.id)
            #expect(await wings.deleteAsk(wing.id) == false)
            // 13i-d U5b (A JUSTIFIED EDIT — R-13id-6 item 9, P-2: the refusal's
            // words gain the bulk road now that the door exists; RED on the
            // old words by construction).
            #expect(spoken(session)
                    == "“Imports” still holds 1 book, 1 note and 1 tag — move or delete them first, "
                        + "then the empty wing can go — or move everything to another wing.")
            // Empty it by hand: move the note home, delete the tag and the book.
            _ = try session.operations.moveNoteToWing(note.id, to: "")
            try session.operations.deleteTag(tag.id)
            for reading in try await db.read({ try Queries.readings($0, wingID: wing.id) }) {
                try session.operations.deleteReading(reading.id)
            }
            #expect(await wings.deleteAsk(wing.id))
            await wings.delete(wing.id)
            #expect(session.wing.currentID == "", "deleting the wing you are in returns you Home")
            #expect(spoken(session) == WingCopy.deleted("Imports"))
            #expect(try await db.read { try Queries.wings($0) }.isEmpty)
        }
    }

    /// The note doors: a bookless note moves at once (receipt); a membered one
    /// returns the confirm LISTING its books; a FINISHED book refuses with the
    /// road; Copy lands bookless in the destination.
    @Test func theNoteDoorsAskActAndRefuseHonestly() async throws {
        try await withWingSession { session, db in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            let loose = try ops.createPost(title: "loose")
            #expect(await wings.moveAsk(postID: loose.id, title: "loose", to: wing.id) == nil)
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: loose.id) } == wing.id)
            #expect(spoken(session) == WingCopy.moved("loose", to: "Imports", left: 0))

            let kept = try ops.createPost(title: "kept")
            let book = try ops.createReading(name: "Alpha", kind: .book)
            _ = try ops.addPostToReading(kept.id, to: book.id)
            let ask = try #require(await wings.moveAsk(postID: kept.id, title: "kept", to: wing.id))
            #expect(ask.leaves == ["Alpha"] && ask.wingName == "Imports")
            #expect(WingCopy.moveMessage(leaves: ask.leaves).hasPrefix("It leaves “Alpha”"))
            try ops.lockReading(book.id)
            #expect(await wings.moveAsk(postID: kept.id, title: "kept", to: wing.id) == nil)
            #expect(spoken(session) == WingCopy.frozen("kept", book: "Alpha"))
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: kept.id) } == "")

            await wings.copy(postID: kept.id, title: "kept", to: wing.id)
            #expect(spoken(session) == WingCopy.copied("kept", to: "Imports"))
            let copies = try await db.read { try Queries.library($0, wingID: wing.id) }
            #expect(copies.count == 2, "the moved note and the copy")
        }
    }

    /// The CURRENT WING is where a new note, book and root tag are born, and
    /// what the scoped surfaces read.
    @Test func newThingsAreBornInTheCurrentWing() async throws {
        try await withWingSession { session, db in
            let wing = try session.operations.createWing(name: "Imports")
            session.wing.switchTo(wing.id)
            let library = LibraryViewModel(session: session)
            let noteID = try #require(await library.createPost())
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: noteID) } == wing.id)
            let readings = ReadingsViewModel(session: session)
            let bookID = try #require(await readings.create(name: "w book", kind: .book))
            #expect(try await db.read { try Queries.reading($0, id: bookID) }?.wingId == wing.id)
            let tags = TagsViewModel(session: session)
            await tags.createTag(parentID: nil, name: "roomy")
            #expect(try await db.read { try Queries.allTags($0, wingID: wing.id) }.map(\.path)
                    == ["roomy"])
            // A typed tag on a HOME note lands in Home's vocabulary — the
            // NOTE's wing, never the one she happens to stand in.
            let home = try session.operations.createPost(title: "home note")
            _ = await TypedTagPath.apply("writing/draft", toPost: home.id, session: session)
            #expect(try await db.read { try Queries.allTags($0, wingID: "") }.map(\.path)
                    == ["writing", "writing/draft"])
        }
    }

    /// F-U5-3 — EMPTY TRASH takes only what THIS wing's Trash shows (the
    /// Trash's own G6 letter: "a door may not take what it does not show").
    /// With per-wing Trash views, the act-time re-read was store-wide — it
    /// would have purged another wing's deleted notes from a wing whose
    /// Trash never listed them. The confirm counts, and the act takes, the
    /// current wing's rows alone; the other wing's row survives the act.
    @Test func emptyTrashTakesOnlyTheCurrentWingsRows() async throws {
        try await withWingSession { session, db in
            let ops = session.operations
            let wing = try ops.createWing(name: "Imports")
            let home = try ops.createPost(title: "home gone")
            let away = try ops.createPost(title: "away gone", wingId: wing.id)
            try ops.deleteContainer(home.id)
            try ops.deleteContainer(away.id)
            session.wing.switchTo(wing.id)
            let confirm = try #require(try await TrashPurge.emptyTrashConfirm(session: session))
            guard case .emptyTrash(let counts, _) = confirm else {
                Issue.record("expected the empty-trash confirm, got \(confirm)")
                return
            }
            #expect(counts[.note] == 1, "the confirm counts this wing's Trash only")
            try await TrashPurge.confirm(session: session, confirm)
            let intents = try await db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT row_id FROM purge_intent WHERE table_name = 'container'")
            }
            #expect(intents == [away.id], "the act took this wing's row and no other")
        }
    }

    /// The memory: a session never touches defaults unless the bootstrap
    /// attaches one; attached, a switch writes through and a dead wing
    /// revalidates to Home.
    @Test func theRememberedWingIsLocalAndRevalidates() throws {
        let suite = "wing-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let state = WingState()
        state.switchTo("w1")
        #expect(defaults.string(forKey: WingState.memoryKey) == nil, "no memory attached")
        defaults.set("w2", forKey: WingState.memoryKey)
        state.attachMemory(defaults)
        #expect(state.currentID == "w2")
        state.switchTo("w3")
        #expect(defaults.string(forKey: WingState.memoryKey) == "w3")
        state.revalidate { $0.isEmpty || $0 == "w1" }
        #expect(state.currentID == "")
        #expect(defaults.string(forKey: WingState.memoryKey) == "")
    }

    /// P-1: the switcher's three acts and the two note doors are declared and
    /// rendered by their surfaces (the registry walk's union carries the
    /// switcher's line; the note doors ride the note-row grammar).
    @Test func theWingActsAreDeclaredAndRendered() {
        // 13i-d U5b (A JUSTIFIED EDIT — a new act on the same renderer):
        // the switcher carries the bulk move too.
        // 13n-c U4 (A JUSTIFIED EDIT, the same class — new acts on the same
        // renderer): the masthead word's CYCLING click (`.switchWing`'s
        // surface door, R-AIR-5/15) and the wing asks' pending glyph
        // (`.mcpOpenAsk`).
        #expect(Set(WingSwitcherMenu.surfaceCapabilities)
                == [.newWing, .renameWing, .deleteWing, .moveWingContents, .switchWing, .mcpOpenAsk])
        let noteRow = Set(SidebarView.contextMenuCapabilities)
        #expect(noteRow.isSuperset(of: [.moveNoteToWing, .copyNoteToWing]))
        for id in [CapabilityID.newWing, .renameWing, .deleteWing] {
            #expect(CapabilityRegistry.capability(id).doors == [.surface])
        }
        // 13i-d U6 (k) (A JUSTIFIED EDIT — a new renderer of the same acts):
        // the note ▾ menu in BOTH bars renders them too (R6-2's one grammar).
        for id in [CapabilityID.moveNoteToWing, .copyNoteToWing] {
            #expect(CapabilityRegistry.capability(id).doors == [.contextMenu, .bottomBar])
            #expect(CommitBar.renderedCapabilities.contains(id))
            #expect(TakesBottomBar.renderedCapabilities.contains(id))
        }
        // The words the faces say come from the declarations.
        #expect(CapabilityRegistry.capability(.newWing).verb == "New Wing…")
        #expect(WingWords.contents(.init(notes: 12, books: 2, gatherings: 1, tags: 4))
                == "2 books, 1 gathering, 12 notes and 4 tags")
    }
}
