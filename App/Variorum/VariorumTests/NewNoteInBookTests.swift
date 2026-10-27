//
//  NewNoteInBookTests.swift
//  VariorumTests
//
//  VX-570 (the VX-439 run, A-439-4 + C-570-1) — ⌥⌘N "New Note in This
//  Book": her 10-21 note, "command for new note within a book". A FEATURE, so
//  its pins are the state-transition and registry kind: the key mints a member
//  of the book the focused pane shows through the SAME act the book's own foot
//  door runs (a note; an entry on a journal-trait book; the planner's note on
//  a gathering), its refusals are that door's (the operations layer's words,
//  on the book's line), the request is the focused book's alone, and the door
//  is declared once with its chord and grey wherever no book is in focus.
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
private func withMintSession<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // LIVE uuids: the book's DEBUG oracle doors key on these ids, and
        // suites run in parallel (BookOpenDoorTests' reason).
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 570))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func pump(_ seconds: TimeInterval = 0.02) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 150
) async {
    for _ in 0..<maxTurns {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
        if predicate() { return }
    }
}

@MainActor
@Suite("VX-570 — ⌥⌘N mints inside the book in focus, through the book's own foot act", .serialized)
struct NewNoteInBookTests {
    // MARK: - The door (P-1 / P-2)

    @Test func theDoorIsDeclaredOnceWithItsChordAndGreyWithoutABook() {
        let door = CapabilityRegistry.capability(.newNoteInBook)
        #expect(door.verb == "New Note in This Book")
        #expect(Set(door.doors) == [.menuBar, .palette, .surface])
        #expect(door.shortcutLabel == "\u{2325}\u{2318}N")
        let key = EditorCommands.keyEquivalent(for: .newNoteInBook)
        #expect(key?.0 == "n" && key?.1 == [.command, .option])
        #expect(CapabilityRegistry.all.filter { $0.shortcutLabel == "\u{2325}\u{2318}N" }.map(\.id)
                == [.newNoteInBook])
        #expect(EditorCommands.menuRendered.contains(.newNoteInBook))
        #expect(ShellActions.paletteActs.contains(.newNoteInBook))
        #expect(BookView.surfaceCapabilities.contains(.newNoteInBook), "the book foot's doors, declared")
        #expect(HelperView.shortcutKeysShown.contains("\u{2325}\u{2318}N"))
        // Acts wherever the focused pane shows a book; grey everywhere else —
        // a note in its own pane (Write, Takes) is not a book context (C-570-1).
        #expect(CapabilityRegistry.availability(
            .newNoteInBook, in: CapabilityContext(focusedPaneShowsBook: true)) == .act)
        for mode in [PostMode.write, .takes, .read] {
            #expect(CapabilityRegistry.availability(
                .newNoteInBook, in: CapabilityContext(mode: mode, writeEditorAttached: true)) == .unavailable)
        }
        #expect(CapabilityRegistry.availability(.newNoteInBook, in: CapabilityContext()) == .unavailable)
    }

    /// C-570-1: the key is the book's OWN foot door — never a second act.
    @Test func theKeyRunsTheFootDoorTheBookDraws() {
        func reading(_ kind: ReadingKind, _ profile: String?) -> Reading {
            Reading(
                id: "r", name: "r", kind: kind, profile: profile,
                createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
        }
        #expect(BookView.footMint(for: reading(.book, nil)) == .note)
        #expect(BookView.footMint(for: reading(.book, "book")) == .note)
        #expect(BookView.footMint(for: reading(.book, Queries.journalTraitProfile)) == .entry)
        #expect(BookView.footMint(for: reading(.book, Queries.dailyJournalBookProfile)) == .entry)
        #expect(BookView.footMint(for: reading(.gathering, nil)) == .gathering)
        // A gathering is the planner's whatever its trait (its navigator foot
        // never draws "+ new entry").
        #expect(BookView.footMint(for: reading(.gathering, Queries.journalTraitProfile)) == .gathering)
    }

    @Test func theRequestIsTheFocusedBooksAndAPlaceSpeaksTheNote() async throws {
        try await withMintSession { session, _ in
            let book = try session.operations.createReading(name: "a book", kind: .book)
            let shell = ShellRouter()
            shell.workspace.select(.reading(book.id))
            ShellActions(session: session, shell: shell).newNoteInThisBook()
            #expect(shell.bookMintRequest?.bookID == book.id)
            let first = shell.bookMintRequest?.token
            ShellActions(session: session, shell: shell).newNoteInThisBook()
            #expect(shell.bookMintRequest?.token != first, "a second press is a second request")

            let elsewhere = ShellRouter()
            elsewhere.workspace.select(.library)
            ShellActions(session: session, shell: elsewhere).newNoteInThisBook()
            #expect(elsewhere.bookMintRequest == nil)
            #expect(session.status.spoken?.text
                    == CapabilityRegistry.capability(.newNoteInBook).unavailableNote)
            #expect(session.status.spoken?.kind == .refusal)
        }
    }

    // MARK: - The act, on a mounted book

    private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
        try await db.read {
            try String.fetchAll($0, sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                ORDER BY position, id
                """, arguments: [readingID])
        }
    }

    /// Mounts the book (its models loaded by hand — hosted `.task`s don't
    /// fire under the test host), then hands it ONE ⌥⌘N request.
    private func pressKey(
        on readingID: String, session: AppSession, db: AppDatabase,
        until done: @escaping @MainActor (BookViewModel, BookStructureModel) -> Bool
    ) async throws -> (BookViewModel, BookStructureModel, consumed: Int) {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
        let structure = BookStructureModel(session: session, readingID: readingID)
        let reading = try await db.read { try Queries.reading($0, id: readingID) }
        structure.adopt(.init(
            reading: reading, sections: [], deletedSections: [], assignments: [:],
            gatheringMint: try await db.read { db in
                try reading.flatMap { $0.kind == .gathering ? try GatheringMintFace.read(db, gathering: $0) : nil }
            }))
        var consumed = 0
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1100, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        func view(_ token: UUID?) -> some View {
            BookView(
                session: session, readingID: readingID, model: model, structure: structure,
                mintRequest: token, onMintRequestConsumed: { consumed += 1 })
                .environment(ThemeStore(session: session))
        }
        let hosting = NSHostingView(rootView: AnyView(view(nil)))
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: { false }, maxTurns: 10)
        hosting.rootView = AnyView(view(UUID()))
        await settle(window, hosting, until: { done(model, structure) })
        return (model, structure, consumed)
    }

    @Test func onABookTheKeyMintsAMemberAndFocusesIt() async throws {
        try await withMintSession { session, db in
            let book = try session.operations.createReading(name: "a book", kind: .book)
            let existing = try session.operations.createPost(title: "already here")
            try session.operations.addPostToReading(existing.id, to: book.id)
            let before = try await members(db, book.id)

            let (model, _, consumed) = try await pressKey(on: book.id, session: session, db: db) { model, _ in
                model.focusedPostID != nil
            }
            let after = try await members(db, book.id)
            #expect(after.count == before.count + 1, "one member minted INSIDE the book")
            let minted = try #require(after.first { !before.contains($0) })
            #expect(model.focusedPostID == minted, "the new note is focused, as the foot door focuses it")
            #expect(consumed == 1, "the request is taken once")
        }
    }

    @Test func onAGatheringTheKeyRunsThePlannersMint() async throws {
        try await withMintSession { session, db in
            let poems = try session.operations.createTag(name: "poems")
            let gathering = try session.operations.createReading(
                name: "poems", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(poems.id)))
            let (model, _, _) = try await pressKey(on: gathering.id, session: session, db: db) { model, _ in
                model.focusedPostID != nil
            }
            let minted = try #require(model.focusedPostID)
            let tags = try await db.read { try Queries.postTags($0, postID: minted).map(\.path) }
            #expect(tags == ["poems"], "the note wears what the rule asks, so the gathering shows it")
            #expect(try await members(db, gathering.id).isEmpty, "a gathering holds nothing")
        }
    }

    @Test func onAFinishedBookTheKeyRefusesInTheOperationsWords() async throws {
        try await withMintSession { session, db in
            let book = try session.operations.createReading(name: "done book", kind: .book)
            let member = try session.operations.createPost(title: "the one")
            try session.operations.addPostToReading(member.id, to: book.id)
            try session.operations.lockReading(book.id)
            let notesBefore = try await db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            let (_, structure, _) = try await pressKey(on: book.id, session: session, db: db) { _, structure in
                structure.lastError != nil
            }
            #expect(structure.lastError == ReadingsViewModel.message(OperationError.lockedReading(id: book.id)),
                    "the foot door's own refusal line, in the operations layer's words")
            let notesAfter = try await db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            #expect(notesAfter == notesBefore, "a refusal mints no stray note")
        }
    }
}
