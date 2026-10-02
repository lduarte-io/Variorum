//
//  SpawnAndBindLimbTests.swift
//  VariorumTests
//
//  13i-c U3 — THE SPAWN SHEET'S OUTFLOW CHOOSER (her item (i): the spawn
//  OFFERS the outflow choice, prefilled with the rule's positive tags, and
//  she may edit it before the mint) and THE BIND SHEET'S OWNED-NOTES LIMB
//  (the 13i-c plan §3: "the sheet gains the limb in U3"; the sitting record
//  §3: "owned notes in the assembly can't materialize, so the confirm lists
//  them: copy in / leave out"; P-13ic-4 — leave out is the default).
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
private func withLimbWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.1) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 720),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
@Suite("The spawn's outflow chooser and the bind's owned-notes limb (13i-c U3)", .serialized)
struct SpawnAndBindLimbTests {
    // MARK: - The spawn

    /// The sheet's item carries the PREFILL — the rule's positive tags, in
    /// tree order, live-filtered — and the wing's live tags to choose from.
    @Test func theSpawnOfferPrefillsThePositiveLiveTags() async throws {
        try await withLimbWorld { session, _ in
            let ops = session.operations
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let avoid = try ops.createTag(name: "avoid")
            let dead = try ops.createTag(name: "dead")
            let gathering = try ops.createReading(
                name: "fan", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([
                    .or([.tag(a.id), .tag(b.id), .tag(dead.id)]), .not(.tag(avoid.id)),
                ])))
            try ops.deleteTag(dead.id)
            let offer = await SpawnOffer.load(session, gathering: gathering)
            #expect(offer.prefill == [a.id, b.id],
                    "every positive tag in order; never the excluded one; the dead one dropped")
            #expect(Set(offer.tags.map(\.id)) == Set([a.id, b.id, avoid.id]))
            #expect(offer.defaultName == "fan (book)")
        }
    }

    @Test func theMountedSpawnSheetDrawsThePrefilledChooser() async throws {
        try await withLimbWorld { session, _ in
            let ops = session.operations
            let a = try ops.createTag(name: "writing")
            let b = try ops.createTag(name: "poetry")
            let gathering = try ops.createReading(
                name: "verse", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(a.id), .tag(b.id)])))
            let offer = await SpawnOffer.load(session, gathering: gathering)
            SpawnSheetProbe.shown = nil
            try await mounted(SpawnBookSheet(offer: offer) { _, _ in }) {
                let shown = try #require(SpawnSheetProbe.shown)
                #expect(shown.outflow == ["#writing", "#poetry"])
                #expect(shown.name == "verse (book)")
            }
        }
    }

    /// Her edit of the prefill is what the book gets: a narrower set, none at
    /// all, or a tag that died meanwhile dropped at the act.
    @Test func theSpawnMintsWithTheChosenSetNotThePrefill() async throws {
        try await withLimbWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let c = try ops.createTag(name: "c")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering,
                querySpec: try RuleGrammar.encode(.or([.tag(a.id), .tag(b.id)])))
            let shelf = ShelfViewModel(session: session)

            let narrowed = try #require(
                await shelf.spawnBook(from: gathering.id, named: "one", outflow: [b.id, c.id]))
            #expect(try await db.read { try Queries.reading($0, id: narrowed)?.autoTagIDs }
                    == [b.id, c.id], "her choice — even a tag the rule never named")

            let none = try #require(await shelf.spawnBook(from: gathering.id, named: "none", outflow: []))
            #expect(try await db.read { try Queries.reading($0, id: none)?.autoTagIDs } == [],
                    "none is legal")

            try ops.deleteTag(c.id)
            let dropped = try #require(
                await shelf.spawnBook(from: gathering.id, named: "dropped", outflow: [c.id, a.id]))
            #expect(try await db.read { try Queries.reading($0, id: dropped)?.autoTagIDs } == [a.id],
                    "a chosen tag that died meanwhile is dropped, never a silent no-op")

            let defaulted = try #require(await shelf.spawnBook(from: gathering.id, named: "default"))
            #expect(try await db.read { try Queries.reading($0, id: defaulted)?.autoTagIDs }
                    == [a.id, b.id], "no answer = the prefill")
        }
    }

    // MARK: - The bind's owned-notes limb

    @Test func theLimbsWordsAndCounts() {
        let note = BindCopy.OwnedNote(title: "Sherlock", owner: "Holmes")
        #expect(BindCopy.ownedLine(note) == "Sherlock \u{2014} owned by \u{201C}Holmes\u{201D}")
        #expect(BindCopy.memberCount(shown: 5, owned: 2, choice: .leaveOut) == 3)
        #expect(BindCopy.memberCount(shown: 5, owned: 2, choice: .copyIn) == 5,
                "a copy is a member")
        #expect(BindCopy.bound("g", count: 2)
                == "\u{201C}g\u{201D} is a book now \u{2014} 2 notes bound in, in the order you had "
                + "them. It keeps collecting.", "the plain bind reads exactly as before")
        #expect(BindCopy.bound("g", count: 2, leftOut: 1).contains(
            "(1 was left out \u{2014} another book owns it)"))
        #expect(BindCopy.bound("g", count: 3, copied: 1).contains("(1 came in as a copy)"))
    }

    /// A gathering showing a note another book OWNS: the offer lists it with
    /// its owner, the mounted sheet draws the limb with LEAVE OUT chosen, and
    /// the promise counts the members leave-out will make.
    private func ownedWorld(_ session: AppSession, _ db: AppDatabase) throws
        -> (gathering: Reading, free: Container, owned: Container)
    {
        let ops = session.operations
        let tag = try ops.createTag(name: "case")
        let gathering = try ops.createReading(
            name: "cases", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
        let owner = try ops.createReading(name: "Holmes", kind: .book)
        let free = try ops.createPost(title: "free note")
        let owned = try ops.createPost(title: "Sherlock")
        _ = try ops.addPostToReading(owned.id, to: owner.id)
        try ops.setReadingOwned(owner.id, owned: true)
        _ = try ops.applyTag(tag.id, toPost: free.id)
        _ = try ops.applyTag(tag.id, toPost: owned.id)
        return (try #require(try db.read { try Queries.reading($0, id: gathering.id) }),
                free, owned)
    }

    @Test func theBindOfferListsTheOwnedNotesAndTheSheetDrawsTheLimb() async throws {
        try await withLimbWorld { session, db in
            let (gathering, _, _) = try ownedWorld(session, db)
            let offer = await BindOffer.load(session, reading: gathering)
            #expect(offer.count == 2, "the gathering SHOWS both (hide-owned's default is SHOW)")
            #expect(offer.ownedElsewhere == [BindCopy.OwnedNote(title: "Sherlock", owner: "Holmes")])
            BindDoorProbe.shown = nil
            try await mounted(BindIntoBookSheet(offer: offer) { _ in }) {
                let shown = try #require(BindDoorProbe.shown)
                #expect(shown.owned == ["Sherlock \u{2014} owned by \u{201C}Holmes\u{201D}"])
                #expect(shown.ownedChoice == .leaveOut, "copies are ceremonies, never silent (P-13ic-4)")
                #expect(shown.body.contains("the 1 note it shows becomes a member"),
                        "the promise counts what leave-out makes")
            }
        }
    }

    @Test func bindingLeavesTheOwnedNoteOutOrCopiesItInAndSaysWhich() async throws {
        try await withLimbWorld { session, db in
            let (gathering, free, owned) = try ownedWorld(session, db)
            let shelf = ShelfViewModel(session: session)
            await shelf.bind(gathering.id)   // the default: leave out
            let members = try await db.read { try Queries.assembleReading($0, readingID: gathering.id) }
            #expect(members.map(\.postID) == [free.id], "the owned note is left out")
            #expect(shelf.lastReport == BindCopy.bound("cases", count: 1, leftOut: 1))
            _ = owned
        }
        try await withLimbWorld { session, db in
            let (gathering, free, owned) = try ownedWorld(session, db)
            let shelf = ShelfViewModel(session: session)
            await shelf.bind(gathering.id, ownedNotes: .copyIn)
            let members = try await db.read { try Queries.assembleReading($0, readingID: gathering.id) }
            #expect(members.count == 2)
            #expect(members.map(\.postID).contains(free.id))
            #expect(!members.map(\.postID).contains(owned.id), "a COPY stands in its slot")
            #expect(shelf.lastReport == BindCopy.bound("cases", count: 2, copied: 1))
        }
    }
}
