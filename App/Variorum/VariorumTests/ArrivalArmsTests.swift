//
//  ArrivalArmsTests.swift
//  VariorumTests
//
//  13i-c U4 — THE ARRIVALS LINE'S OWNERSHIP ARMS (the 13i-c plan §4 row 19;
//  the sitting record §4 "copy in / dismiss" and "claim-move / copy in /
//  leave", §18.4 — competing owned books).
//
//  What is pinned: the arms TABLE per fact (data — the one ownership verdict
//  `seatArrival` consults, so a row never offers an Add the seat refuses);
//  the row's line ("owned by “X”" / "also in “X”"); the two acts through
//  `copyPostIntoReading(answering:)` / `movePostIntoReading(answering:)`
//  with their receipts; and the MOUNTED line drawing each row's arms.
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
private func withArmsWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The two bells: an OWNED living book "Mine" on #t ringing for `shared`
/// (a member of "Other"), and a PLAIN living book "Plain" on #t ringing for
/// `claimed` (owned by "Owner").
private struct Bells {
    let mine: Reading
    let plain: Reading
    let other: Reading
    let owner: Reading
    let shared: Container
    let claimed: Container
}

@MainActor
private func bells(_ session: AppSession) throws -> Bells {
    let ops = session.operations
    let tag = try ops.createTag(name: "t")
    let rule = try RuleGrammar.encode(.tag(tag.id))
    let mine = try ops.createReading(name: "Mine", kind: .book, querySpec: rule)
    try ops.setReadingOwned(mine.id, owned: true)
    let plain = try ops.createReading(
        name: "Plain", kind: .book, querySpec: rule, intakeSeating: .auto)
    let other = try ops.createReading(name: "Other", kind: .book)
    let owner = try ops.createReading(name: "Owner", kind: .book)
    try ops.setReadingOwned(owner.id, owned: true)
    let shared = try ops.createPost(title: "shared")
    _ = try ops.addPostToReading(shared.id, to: other.id)
    let claimed = try ops.createPost(title: "claimed")
    _ = try ops.addPostToReading(claimed.id, to: owner.id)
    // The applying acts: each bells where a plain seat would break a promise.
    _ = try ops.applyTag(tag.id, toPost: shared.id)
    _ = try ops.applyTag(tag.id, toPost: claimed.id)
    return Bells(
        mine: mine, plain: plain, other: other, owner: owner, shared: shared, claimed: claimed)
}

private func pump(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func door(_ db: AppDatabase, _ readingID: String) async throws -> Queries.BookArrivals {
    try await db.read { try Queries.bookArrivals($0, readingID: readingID, limit: 30) }
}

@MainActor
private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { try Queries.assembleReading($0, readingID: readingID) }.map(\.postID)
}

@MainActor
@Suite("The Arrivals line's ownership arms (13i-c U4)", .serialized)
struct ArrivalArmsTests {
    @Test func theArmsAreTheOwnershipVerdictPerRow() {
        let x = Queries.BookRef(id: "x", name: "X")
        let y = Queries.BookRef(id: "y", name: "Y")
        // An ordinary note: Add · Dismiss, no line.
        #expect(ArrivalArms.of(bookOwned: false, facts: nil)
                == ArrivalArms(acts: [.seatArrival, .dismissArrival], line: nil))
        #expect(ArrivalArms.of(bookOwned: true, facts: nil).acts == [.seatArrival, .dismissArrival],
                "a free note moves into an owned book clean")
        // Multi-membership is legal at a plain door — still a plain Add.
        #expect(ArrivalArms.of(
            bookOwned: false, ownedBy: nil, otherBooks: [x])
                == ArrivalArms(acts: [.seatArrival, .dismissArrival], line: nil))
        // An OWNED book meets a membered note: Copy In · Move In · Dismiss.
        #expect(ArrivalArms.of(
            bookOwned: true, ownedBy: nil, otherBooks: [x, y])
                == ArrivalArms(
                    acts: [.copyIn, .moveIn, .dismissArrival],
                    line: "also in \u{201C}X\u{201D} and \u{201C}Y\u{201D}"))
        // A PLAIN book meets a note another book owns: Copy In · Dismiss.
        #expect(ArrivalArms.of(
            bookOwned: false, ownedBy: x, otherBooks: [x])
                == ArrivalArms(acts: [.copyIn, .dismissArrival], line: "owned by \u{201C}X\u{201D}"))
        // §18.4 — COMPETING owned books: the row says who claimed it first.
        #expect(ArrivalArms.of(
            bookOwned: true, ownedBy: x, otherBooks: [x])
                == ArrivalArms(
                    acts: [.copyIn, .moveIn, .dismissArrival], line: "owned by \u{201C}X\u{201D}"))
        // Every arm is a declared act, its word the registry's.
        #expect(ArrivalArms.verb(.copyIn) == "Copy In")
        #expect(ArrivalArms.verb(.moveIn) == "Move In")
        #expect(ArrivalArms.verb(.seatArrival) == ArrivalsCopy.addVerb)
        #expect(BookArrivalsList.surfaceCapabilities.contains(.copyIn))
        #expect(BookArrivalsList.surfaceCapabilities.contains(.moveIn))
    }

    @Test func theModelReadsEachRowsFactsAndCopyInAnswersTheBell() async throws {
        try await withArmsWorld { session, db in
            let world = try bells(session)
            let model = BookArrivalsModel(session: session, readingID: world.mine.id)
            model.adopt(try await door(db, world.mine.id))
            await model.loadFacts()
            let arrival = try #require(model.door.rows.first)
            #expect(arrival.postID == world.shared.id, "the owned book belled the membered note")
            let arms = model.arms(for: arrival, bookOwned: true)
            #expect(arms.acts == [.copyIn, .moveIn, .dismissArrival])
            // It lives in Other — and in Plain, whose intake seated it quietly
            // (an ordinary note at a plain door).
            #expect(arms.line == "also in \u{201C}Other\u{201D} and \u{201C}Plain\u{201D}")

            await model.copyIn(arrival, book: world.mine)
            #expect(session.status.spoken?.text == ArrivalsCopy.copiedIn("shared"))
            let mineNow = try await members(db, world.mine.id)
            #expect(mineNow.count == 1 && mineNow[0] != world.shared.id, "a copy joined")
            #expect(try await members(db, world.other.id) == [world.shared.id],
                    "the original keeps its life in Other")
            #expect(try await door(db, world.mine.id).rows.map(\.postID) == [world.claimed.id],
                    "the bell is answered; the other arrival still waits")
        }
    }

    @Test func moveInClaimsTheNoteAndNamesWhatItLeft() async throws {
        try await withArmsWorld { session, db in
            let world = try bells(session)
            let model = BookArrivalsModel(session: session, readingID: world.mine.id)
            model.adopt(try await door(db, world.mine.id))
            let arrival = try #require(model.door.rows.first)
            await model.moveIn(arrival, book: world.mine)
            // It also lived in Plain — Plain's intake seated it quietly (an
            // ordinary note at a plain door) — so it leaves both.
            #expect(session.status.spoken?.text
                    == ArrivalsCopy.movedIn("shared", left: ["Other", "Plain"]))
            #expect(try await members(db, world.mine.id) == [world.shared.id])
            #expect(try await members(db, world.other.id).isEmpty)
            #expect(!(try await members(db, world.plain.id)).contains(world.shared.id))
        }
    }

    @Test func aPlainBooksBellForAnOwnedNoteOffersCopyInOnly() async throws {
        try await withArmsWorld { session, db in
            let world = try bells(session)
            let model = BookArrivalsModel(session: session, readingID: world.plain.id)
            model.adopt(try await door(db, world.plain.id))
            await model.loadFacts()
            // The plain book auto-seated the ordinary `shared`; `claimed` waits.
            let arrival = try #require(model.door.rows.first { $0.postID == world.claimed.id })
            let arms = model.arms(for: arrival, bookOwned: false)
            #expect(arms == ArrivalArms(
                acts: [.copyIn, .dismissArrival], line: "owned by \u{201C}Owner\u{201D}"))
            await model.copyIn(arrival, book: world.plain)
            #expect(try await members(db, world.owner.id) == [world.claimed.id],
                    "the owner keeps its note — only a copy came in")
        }
    }

    @Test func theMountedLineDrawsEachRowsArms() async throws {
        ArrivalsLineProbe.reset()
        try await withArmsWorld { session, db in
            let world = try bells(session)
            let readingID = world.mine.id
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read {
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: readingID) },
                sections: [], deletedSections: [], assignments: [:]))
            structure.mode = .index
            let arrivals = BookArrivalsModel(session: session, readingID: readingID)
            arrivals.adopt(try await door(db, readingID))
            arrivals.toggle()
            arrivals.adopt(try await door(db, readingID))
            await arrivals.loadFacts()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            // 17y B3 (h) — A JUSTIFIED EDIT: the rows are the masthead door's
            // POPOVER content now (`BookArrivalsList`); a popover does not
            // render under the test host, so the rows mount on their own. The
            // subject — each row draws its arms — is unchanged.
            _ = model
            let hosting = NSHostingView(rootView: BookArrivalsList(
                model: arrivals, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where ArrivalsLineProbe.drawn[readingID]?.rows.isEmpty ?? true {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                pump(0.03)
                await Task.yield()
            }
            let drawn = try #require(ArrivalsLineProbe.drawn[readingID])
            #expect(drawn.rows.values.first == ["Copy In", "Move In", ArrivalsCopy.dismissVerb],
                    "an owned book's bell for a membered note draws Copy In · Move In · Dismiss")
        }
    }
}
