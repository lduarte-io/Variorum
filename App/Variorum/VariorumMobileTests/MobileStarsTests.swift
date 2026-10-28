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
                 try ops.createReading(name: "Poems", kind: .book).id)
            }
            let model = MobileStarsModel(session: session)
            await model.refresh()
            #expect(model.items.isEmpty)

            await model.toggle(.post(noteID), from: .shelf)
            await model.toggle(.reading(bookID), from: .shelf)
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

            await model.toggle(.post(noteID), from: .shelf)
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

    /// **VX-643 — THE DELIBERATE FLIP** of `theCapRefusalSpeaksPhoneWords`
    /// (her word 2026-10-28 — the cap is gone, on the phone too): the
    /// sixteenth star LANDS from the phone's door, silently, in star order.
    /// RED ON OLD: it spoke the phone's cap sentence and stayed unstarred.
    @Test func theSixteenthStarLandsOnThePhone() async throws {
        try await withEditorWorld { session, db in
            let ids = try await session.runner.run { ops -> [String] in
                try (0..<16).map { try ops.createPost(title: "Note \($0)").id }
            }
            let model = MobileStarsModel(session: session)
            for id in ids {
                await model.toggle(.post(id), from: .shelf)
            }
            #expect(model.items.map(\.target) == ids.map { .post($0) },
                    "all sixteen, in star order")
            #expect(model.lastError == nil, "no refusal anywhere")
            #expect(model.isStarred(.post(ids[15])))
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
                 try ops.createReading(name: "Poems", kind: .book).id)
            }
            let model = MobileStarsModel(session: session)
            await model.toggle(.post(bareID), from: .shelf)
            await model.toggle(.post(titledID), from: .shelf)
            await model.toggle(.reading(bookID), from: .shelf)

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

    /// The refusal's ONE HOME + clearing cadence (parity D2 — the
    /// routed C3 R1-7 mechanism): `lastError` was one field on the one
    /// shared model and BOTH tab roots rendered it, so a refusal
    /// fired from the Library also sat at the shelf's bottom — and it
    /// never cleared passively. Now: a door refusal renders at ITS
    /// root only, a fresh success clears it at once, and an untouched
    /// refusal clears itself after the cadence. A HOMELESS store-read
    /// error still renders everywhere (it is not door-fired) and never
    /// auto-clears — pinned so the gating can't over-reach.
    ///
    /// JUSTIFIED EDIT (VX-643): the cap's refusal was this pin's trigger, and
    /// the cap is gone — so the refusal is now the op's own for a star whose
    /// note was deleted under the press (`containerNotFound`); the subject
    /// (where a refusal speaks, and when it clears) is unchanged.
    @Test func aRefusalSpeaksAtItsOwnDoorAndClearsAfterABeat() async throws {
        try await withEditorWorld { session, db in
            let (dead, live) = try await session.runner.run { ops -> (String, String) in
                let dead = try ops.createPost(title: "gone").id
                let live = try ops.createPost(title: "Note").id
                try ops.deleteContainer(dead)
                return (dead, live)
            }
            let model = MobileStarsModel(session: session)
            model.errorClearDelay = .milliseconds(40)
            #expect(model.lastError == nil)

            // A refused star, fired from the LIBRARY's door: the refusal
            // renders there and ONLY there.
            await model.toggle(.post(dead), from: .library)
            #expect(model.error(on: .library) != nil)
            #expect(model.error(on: .shelf) == nil,
                    "the refusal speaks where its door fired — never on the other root")

            // The cadence: an untouched refusal clears itself.
            await settle { model.lastError == nil }
            #expect(model.lastError == nil, "the refusal clears after a beat")
            #expect(model.error(on: .library) == nil)

            // A success clears immediately (no stale ghost): refuse
            // again, then star a live note — the refusal is gone at once.
            model.errorClearDelay = .seconds(60) // the cadence must not be what clears it
            await model.toggle(.post(dead), from: .library)
            #expect(model.error(on: .library) != nil)
            await model.toggle(.post(live), from: .shelf)
            #expect(model.lastError == nil, "a successful toggle clears the refusal at once")

            // (The HOMELESS arm — a store-read failure rendering on
            // every root, never auto-clearing — is a one-line brain
            // (`errorHome == nil` in `error(on:)`) whose failure state
            // is not stageable through this harness's live store;
            // code-read, recorded rather than fake-pinned.)
        }
    }
}
