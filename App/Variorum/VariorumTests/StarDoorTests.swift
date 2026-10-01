//
//  StarDoorTests.swift
//  VariorumTests
//
//  Phase 13f, batch 6 — W4's app half (her sitting ruling, round 3:
//  *"stars = a synced `setting` list + a Starred sidebar section … up to 5
//  notes or books, star/unstar via context menu + ⌘K, section at the
//  sidebar's top"*).
//
//  The list arithmetic — star order, the cap, the read rule, the self-heal
//  — is the CORE's and is pinned there (`StarsTests`). What is pinned here
//  is everything the app decides: the target rule ⌘K uses, the row word,
//  the registry declaration and its honest grey, the cap refusal reaching
//  her in words, and the two doors acting end to end against a real store.
//
//  What is deliberately NOT claimed: how the Starred section LOOKS at the
//  sidebar's top — that is on the batch record's visual-verification list.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure rules

@Suite("The star target rule (13f W4)")
struct StarTargetingTests {
    @Test func onlyNotesAndBooksAreThingsAStarCanPointAt() {
        #expect(StarTargeting.target(for: .post("p1")) == .post("p1"))
        #expect(StarTargeting.target(for: .reading("b1")) == .reading("b1"))
        // Places, not things — ⌘K is honestly grey at every one of them.
        for place: SidebarSelection in [.shelf, .library, .poolPosts, .blocks, .recovery] {
            #expect(StarTargeting.target(for: place) == nil, "\(place) is a place")
        }
        // A scraps container and a tag folder are places too (the Open
        // strip's notes-only scope, applied to the same question).
        #expect(StarTargeting.target(for: .pool("scraps")) == nil)
        #expect(StarTargeting.target(for: .tag("t1")) == nil)
        #expect(StarTargeting.target(for: nil) == nil)
    }

    @Test func aStarredRowNavigatesBackToWhatItPointsAt() {
        // The Starred rows are ordinary tagged List rows: this is the tag
        // they carry, so the round trip is the whole of their routing.
        for target: StarTarget in [.post("p1"), .reading("b1")] {
            #expect(StarTargeting.target(for: StarTargeting.selection(for: target)) == target)
        }
        #expect(StarTargeting.selection(for: .post("p1")) == .post("p1"))
        #expect(StarTargeting.selection(for: .reading("b1")) == .reading("b1"))
    }

    /// `StarDoor` is MainActor (its closures read the observed model and
    /// spawn the write), so its one pure claim is pinned from there.
    @MainActor
    @Test func theRowWordSaysWhichDirectionItWouldGo() {
        let door = StarDoor(isStarred: { $0 == .post("starred") }, toggle: { _ in })
        #expect(door.title(for: .post("starred")) == StarCopy.unstarRow)
        #expect(door.title(for: .post("plain")) == StarCopy.starRow)
        #expect(StarCopy.verb == "Toggle Star",
                "the registry declares the ACT once; the rows say the direction")
    }

    @Test func theCapRefusalNamesUnStarringAsTheRoad() {
        let message = OpsRefusalCopy.message(
            for: OperationError.starLimitReached(limit: Operations.starLimit))
        #expect(message.contains("\(Operations.starLimit)"), "it names the number")
        #expect(message.lowercased().contains("un-star"), "…and the road out")
        #expect(message.contains(StarCopy.sectionHeader), "…and where to walk it")
        #expect(!message.hasPrefix("Refused:"), "never the raw enum dump")
    }
}

// MARK: - The declaration (P-1)

@MainActor
@Suite("The star door's declaration (13f W4)")
struct StarDeclarationTests {
    @Test func theActIsDeclaredWithItsTwoDoorFamiliesAndNoKey() {
        let capability = CapabilityRegistry.capability(.toggleStar)
        #expect(capability.doors == [.contextMenu, .palette],
                "her ruling: the row menus and ⌘K by name — no menu-bar item, no chord")
        #expect(capability.shortcutLabel == nil,
                "an invented chord would owe a collision sweep no ruling asked for")
        #expect(capability.scope == .app)
        #expect(capability.takesAccess == nil, "a workspace act, not an editing one")
    }

    @Test func itIsHonestlyGreyWhereNothingCanBeStarred() {
        // The gate governs the ⌘K door: at the shelf there is nothing to
        // star, so a palette row there could only refuse.
        let atAPlace = CapabilityContext(mode: nil, canStarCurrent: false)
        let atANote = CapabilityContext(mode: .write, canStarCurrent: true)
        #expect(CapabilityRegistry.capability(.toggleStar).availability(atAPlace) == .unavailable)
        #expect(CapabilityRegistry.capability(.toggleStar).availability(atANote) == .act)
        #expect(CapabilityRegistry.isEnabled(.toggleStar, in: atANote))
        #expect(!CapabilityRegistry.isEnabled(.toggleStar, in: atAPlace))
    }

    @Test func fourSurfacesRenderTheOneDeclaration() {
        // The note-row family (Open strip · Library catalog · Pool) declares
        // it once; the shelf's BOOK rows declare it themselves. The walk
        // asserts declared ⇔ rendered over both statics; this pins that the
        // star is in both, so removing either is a failing test rather than
        // a quietly missing door.
        #expect(SidebarView.contextMenuCapabilities.contains(.toggleStar))
        #expect(ShelfView.contextMenuCapabilities.contains(.toggleStar))
        #expect(ShellActions.paletteActs.contains(.toggleStar))
    }
}

// MARK: - The doors, acting (end to end)

@MainActor
@Suite("Starring, end to end (13f W4)")
struct StarActingTests {
    /// The row door: `StarsModel.toggle` in both directions, over a real
    /// store, with the observed list following.
    @Test func theRowDoorStarsAndUnStarsAndTheSectionFollows() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (note, book) = try await session.runner.run { ops in
                (try ops.createPost(title: "The Long Way Home"),
                 try ops.createReading(name: "Field Notes", kind: .book))
            }
            let stars = StarsModel(session: session)
            let task = Task { await stars.start() }
            defer { task.cancel() }

            await stars.toggle(.post(note.id))
            await stars.toggle(.reading(book.id))
            try await settle { stars.items.count == 2 }
            #expect(stars.items.map(\.target) == [.post(note.id), .reading(book.id)],
                    "star time is the order — a note and a book in one list")
            #expect(stars.isStarred(.post(note.id)))
            #expect(stars.titles[note.id] == "The Long Way Home")
            #expect(stars.titles[book.id] == "Field Notes")

            await stars.toggle(.post(note.id))
            try await settle { stars.items.count == 1 }
            #expect(stars.items.map(\.target) == [.reading(book.id)])
            #expect(!stars.isStarred(.post(note.id)))
        }
    }

    /// The CAP reaching her IN WORDS — the whole reason it is a refusal and
    /// not a silent eviction (P-2, and her ruling's "refuses honestly").
    @Test func theSixthStarSpeaksTheOperationsOwnRefusal() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try await session.runner.run { ops in
                try (0...Operations.starLimit).map { try ops.createPost(title: "n\($0)") }
            }
            let stars = StarsModel(session: session)
            let task = Task { await stars.start() }
            defer { task.cancel() }

            for note in notes.prefix(Operations.starLimit) {
                await stars.toggle(.post(note.id))
            }
            try await settle { stars.items.count == Operations.starLimit }
            // 18i: silence means BOTH slots empty.
            #expect(session.status.spoken == nil, "five stars say nothing at all")

            await stars.toggle(.post(notes[Operations.starLimit].id))
            let spoken = session.status.spoken?.text ?? ""
            #expect(spoken.lowercased().contains("un-star"),
                    "the door FIRED and named the road: \(spoken)")
            #expect(stars.items.count == Operations.starLimit,
                    "and nothing was evicted to make room")
        }
    }

    /// ⌘K's door: it stars what the FOCUSED pane is showing, and speaks
    /// where nothing starrable is open (reachable only by a race — the
    /// menu row is grey there — but never a silent no-op).
    @Test func theCommandPaletteDoorStarsWhatThePaneIsShowing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let note = try await session.runner.run { ops in try ops.createPost(title: "n") }
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)

            // At a PLACE: it speaks rather than acting.
            shell.workspace.select(.shelf)
            actions.toggleStarForCurrent()
            #expect(session.status.current?.text == StarCopy.unavailableNote)
            session.status.clear()

            // At a NOTE: it stars it, and toggles back off.
            shell.workspace.select(.post(note.id))
            actions.toggleStarForCurrent()
            try await settle {
                try await db.read { try Queries.starred($0) }.map(\.target) == [.post(note.id)]
            }
            actions.toggleStarForCurrent()
            try await settle {
                try await db.read { try Queries.starred($0) }.isEmpty
            }
        }
    }

    /// THE READ RULE, where she can see it: a starred note that is deleted
    /// leaves the section on its own — no dead row, and no door needed to
    /// clear it (the core heals the stored list at the next write).
    @Test func aDeletedNoteLeavesTheStarredSectionByItself() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let note = try await session.runner.run { ops in try ops.createPost(title: "doomed") }
            let stars = StarsModel(session: session)
            let task = Task { await stars.start() }
            defer { task.cancel() }

            await stars.toggle(.post(note.id))
            try await settle { stars.items.count == 1 }

            try await session.runner.run { ops in try ops.deleteContainer(note.id) }
            try await settle { stars.items.isEmpty }
            #expect(!stars.isStarred(.post(note.id)))
        }
    }
}

/// Poll until a condition holds (never a sync RunLoop pump — the standing
/// harness rule for settle hops through an observation).
@MainActor
private func settle(
    within seconds: Double = 3, _ condition: () async throws -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if try await condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(try await condition(), "condition never settled")
}
