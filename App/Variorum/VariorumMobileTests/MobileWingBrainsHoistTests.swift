//
//  MobileWingBrainsHoistTests.swift
//  VariorumMobileTests
//
//  **VM-63 (the VM-55 run, "Wings underneath", batch 3) — the phone builds the
//  wing brains the Mac's code moved to `Shared/`.** A compile-level pin with
//  teeth: it constructs each hoisted brain against a real test session on the
//  phone target and reads it back — the wings' rows (Home first), names and
//  destinations; the switcher's order and its "next wing"
//  (`WingSwitcherBrain.next(after:in:)`) with the picker's shared query rule;
//  the cross-wing follow's rule and words; the destination selector over the
//  wings' own rows; the book move's ask (the brain's shared book-move half).
//  And the one seam the hoist added that a phone composition must use: the
//  refusal words are the ones the caller HANDS IN, said as a refusal — while an
//  act that lands says a RECEIPT, which the phone's one line does not draw (a
//  `removal` would), so the brain kept its Mac kinds on the phone too.
//
//  No phone face is built here, and no phone surface constructs these brains
//  yet (batch 4 composes them); this proves only that the phone COMPILES and
//  can RUN them. The Mac's behaviour is pinned by the Mac's own wing suites
//  (the batch record lists them by type).
//
//  **How a regression trips it:** a hoisted file that names a Mac-only type
//  stops the phone target from building at all; a brain that read its rows,
//  order or destinations differently on the phone reds the reads; a refusal
//  spoken in any words but the handed-in ones, or as another kind, reds the
//  seam pin; a landed act that said a `removal` would draw on the phone and
//  reds it.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-63 — the phone builds and runs the wing brains hoisted from the Mac", .serialized)
struct MobileWingBrainsHoistTests {
    /// The phone's own refusal road, as a phone composition would hand it
    /// (nonisolated: the brain's seam is a plain `(Error) -> String`).
    nonisolated private static func phoneWords(_ error: Error) -> String {
        OpsRefusalCopy.sentence(for: error, roads: .phone)
    }

    /// `WingsModel` on the phone: Home alone before a read; after one, Home
    /// first and then the live wings, the count on the shared `WingState`, the
    /// names (a dangling id reads as Home's), the destinations and the next
    /// wing, wrapping.
    @Test func theWingsBrainReadsItsRowsOnThePhone() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let wings = WingsModel(session: session, refusalWords: Self.phoneWords)
            #expect(wings.rows == [WingsModel.Row(id: "", name: "Home")], "before a read: Home alone")

            await wings.load()
            #expect(wings.rows.map(\.name) == ["Home", "Work"], "Home first, then the live wings")
            #expect(wings.rows.map(\.id) == ["", world.work])
            #expect(wings.switcherRows.map(\.id) == ["", world.work])
            #expect(session.wing.wingCount == 2, "the brain notes the count on the shared state")
            #expect(wings.currentName == "Home")
            #expect(wings.name(of: world.work) == "Work")
            #expect(wings.name(of: "no-such-wing") == "Home", "a dangling id reads as Home's")
            #expect(wings.destinations(from: "").map(\.id) == [world.work])
            #expect(wings.destinations(from: world.work).map(\.id) == [""])
            #expect(wings.destinations(from: "no-such-wing").map(\.id) == [world.work],
                    "a dead wing's book lives in Home, so Home is never offered")
            #expect(wings.nextWing?.id == world.work)

            session.wing.switchTo(world.work)
            #expect(wings.currentName == "Work")
            #expect(wings.nextWing?.id == "", "the next wing wraps back to Home")
        }
    }

    /// `WingSwitcherBrain` on the phone: the next wing in the switcher's order
    /// (wrapping, nil with one wing), the open highlight, and the filter that
    /// reads the picker's shared query rule (`SearchPickerBrain.normalized`).
    @Test func theSwitcherBrainStepsAndFiltersOnThePhone() {
        let rows = [
            WingSwitcherBrain.Row(id: "", name: "Home"),
            WingSwitcherBrain.Row(id: "w", name: "Work"),
            WingSwitcherBrain.Row(id: "t", name: "Trips"),
        ]
        #expect(WingSwitcherBrain.next(after: "", in: rows)?.id == "w")
        #expect(WingSwitcherBrain.next(after: "w", in: rows)?.id == "t")
        #expect(WingSwitcherBrain.next(after: "t", in: rows)?.id == "", "it wraps to Home")
        #expect(WingSwitcherBrain.next(after: "gone", in: rows)?.id == "", "an unknown current steps to the first")
        #expect(WingSwitcherBrain.next(after: "", in: [rows[0]]) == nil, "one wing: nothing to step to")

        var brain = WingSwitcherBrain(rows: rows, currentID: "w")
        #expect(brain.highlight == "w", "it opens on the current wing")
        brain.type("#tri")
        #expect(brain.visible.map(\.id) == ["t"], "a leading # is dropped, case-insensitively")
        #expect(brain.returnPressed() == .commit("t"))
        #expect(SearchPickerBrain.normalized("  ##Work ") == "Work")
    }

    /// `WingFollow`'s rule and its words on the phone.
    @Test func theFollowRuleAndItsWordsOnThePhone() {
        #expect(WingFollow.decision(current: "", subjectWing: "w") == .switchTo("w"))
        #expect(WingFollow.decision(current: "w", subjectWing: "w") == .stay)
        #expect(WingFollow.decision(current: "w", subjectWing: nil) == .stay)
        #expect(WingFollow.nowIn("Work", isHome: false) == "Now in \u{201C}Work\u{201D}.")
        #expect(WingFollow.nowIn("Home", isHome: true) == "Now in Home.")
    }

    /// The destination selector over the wings' own rows, and the book move's
    /// ask (the brain's shared book-move half) — an ask says nothing.
    @Test func theDestinationSelectorAndTheBookMoveAskBuildOnThePhone() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let wings = WingsModel(session: session, refusalWords: Self.phoneWords)
            await wings.load()

            let selector = WingDestinationModel(
                act: .moveNote(postID: world.homeNote, title: "Field notes"), fromWing: "", wings: wings)
            #expect(selector.brain.rows.map(\.id) == [world.work], "the note's own wing is never listed")
            #expect(selector.brain.highlight == world.work)
            #expect(selector.fromWingName == "Home")
            #expect(selector.prompt == WingCopy.moveDestinationPrompt)
            #expect(selector.foot == WingCopy.destinationFoot(subject: "Field notes", in: "Home"))

            let read = try await session.database.read { db in try Queries.reading(db, id: world.workBook) }
            let book = try #require(read)
            let ask = try #require(await wings.bookMoveAsk(reading: book, to: ""))
            #expect(ask.name == "Essays" && ask.wingName == "Home" && !ask.isGathering)
            #expect(ask.preview.notes == 0)
            #expect(ask.preview.nameTakenBy == "Essays", "Home's own “Essays” is named, never refused")
            #expect(session.status.current == nil, "an ask says nothing")
        }
    }

    /// The hoist's one seam, on the phone: a refusal speaks the words the
    /// caller handed in, as a refusal (and the act changed nothing); a landed
    /// act speaks a receipt — which the phone's one line does not draw, so the
    /// line stays empty (a `removal` would have drawn).
    @Test func aRefusalSpeaksTheHandedInWordsAndALandedActSaysAReceipt() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let wings = WingsModel(session: session, refusalWords: { _ in "the handed-in words" })
            await wings.load()

            await wings.rename(world.work, to: "Home")
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text == "the handed-in words")
            #expect(wings.name(of: world.work) == "Work", "the refused rename changed nothing")

            session.status.clear()
            #expect(await wings.mint(named: "Trips"))
            #expect(wings.rows.map(\.name) == ["Home", "Work", "Trips"])
            #expect(session.wing.currentID == wings.rows[2].id, "a new wing is switched to")
            #expect(session.status.current == nil,
                    "the mint's line is a receipt — the phone draws none for an ordinary act")
        }
    }
}
