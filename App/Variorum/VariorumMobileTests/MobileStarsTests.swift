//
//  MobileStarsTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C3 — stars (her sitting ruling 10:
//  "CROSS — act + starred face"). The mechanism is the Mac's own,
//  reused THROUGH CORE (13f W4: the synced 'starred' setting list,
//  `Operations.setStarred` + `Queries.starred`); these tests drive the
//  phone model and read the store.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile stars (parity C3 — her ruling 10)")
struct MobileStarsTests {
    /// Star a note and a book through the model: the store's 'starred'
    /// setting holds them in STAR ORDER (the core's append rule);
    /// un-star removes exactly; the door words and the route brain are
    /// pinned beside the acts.
    @Test func starAndUnstarLandAsStoreTruthInStarOrder() async throws {
        try await withEditorWorld { session, db in
            let (noteID, bookID) = try await session.runner.run { ops -> (String, String) in
                (try ops.createPost(title: "Harbor").id,
                 try ops.createReading(name: "Poems", kind: .curated).id)
            }
            let model = MobileStarsModel(session: session)
            await model.refresh()
            #expect(model.items.isEmpty)

            await model.toggle(.post(noteID))
            await model.toggle(.reading(bookID))
            #expect(model.items.map(\.target) ==
                    [.post(noteID), .reading(bookID)],
                    "star order — star time is the order, the core's rule")
            #expect(model.isStarred(.post(noteID)))
            #expect(model.isStarred(.reading(bookID)))
            #expect(model.lastError == nil)

            // The store truth: the synced 'starred' setting (the Mac's
            // own mechanism — ZERO schema, the shelf_pins class).
            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT value FROM setting WHERE key = 'starred'")
            }
            #expect(stored == #"["post:\#(noteID)","reading:\#(bookID)"]"#)

            await model.toggle(.post(noteID))
            #expect(model.items.map(\.target) == [.reading(bookID)],
                    "un-star removes exactly; the book's star survives")

            // The door words (the Mac StarCopy's own) and the route
            // brain, pinned.
            #expect(MobileStarsModel.doorTitle(starred: false) == "Star")
            #expect(MobileStarsModel.doorTitle(starred: true) == "Unstar")
            #expect(MobileStarsModel.route(for: .reading(bookID)) == .book(bookID))
            #expect(MobileStarsModel.route(for: .post(noteID))
                == .note(noteID, focus: false))
        }
    }

    /// The cap refuses HONESTLY in PHONE words: the sixth star speaks
    /// the phone's own road (the starred list at the top of the SHELF —
    /// never the Mac's sidebar), and nothing is evicted.
    @Test func theCapRefusalSpeaksPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let ids = try await session.runner.run { ops -> [String] in
                try (0..<6).map { try ops.createPost(title: "Note \($0)").id }
            }
            let model = MobileStarsModel(session: session)
            for id in ids.prefix(5) {
                await model.toggle(.post(id))
            }
            #expect(model.items.count == 5)
            #expect(model.lastError == nil)

            await model.toggle(.post(ids[5]))
            #expect(model.items.count == 5, "the cap evicts nothing")
            #expect(!model.isStarred(.post(ids[5])))
            let refusal = try #require(model.lastError)
            #expect(refusal == MobileStarsModel.capRefusal(limit: 5))
            #expect(refusal.contains("top of the shelf"), "the phone's own road is named")
            #expect(!refusal.contains("sidebar"), "never the Mac's surface")
            #expect(!refusal.contains("Mac"))
        }
    }

    /// Starred names ride the ONE display brain (the C2 one-chain
    /// doctrine): an untitled, undated note's star shows its created
    /// day — never a blank, never a bare placeholder while a day
    /// exists; a titled note shows its title; a book its stored name.
    @Test func starredNamesRideTheOneDisplayBrain() async throws {
        try await withEditorWorld { session, db in
            let (bareID, titledID, bookID) = try await session.runner.run {
                ops -> (String, String, String) in
                (try ops.createPost(title: nil).id,
                 try ops.createPost(title: "Harbor Light").id,
                 try ops.createReading(name: "Poems", kind: .curated).id)
            }
            let model = MobileStarsModel(session: session)
            await model.toggle(.post(bareID))
            await model.toggle(.post(titledID))
            await model.toggle(.reading(bookID))

            let header = try #require(await session.database.read { db in
                try Queries.containerHeader(db, containerID: bareID)
            })
            let expectedDay = DisplayTitle.note(
                title: nil, entryDate: nil, createdAt: header.createdAt)
            let bareRow = try #require(model.items.first { $0.target == .post(bareID) })
            #expect(model.displayName(bareRow) == expectedDay,
                    "the untitled star reads its created day — the one chain")
            let titledRow = try #require(model.items.first { $0.target == .post(titledID) })
            #expect(model.displayName(titledRow) == "Harbor Light")
            let bookRow = try #require(model.items.first { $0.target == .reading(bookID) })
            #expect(model.displayName(bookRow) == "Poems")
        }
    }
}
