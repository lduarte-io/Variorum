//
//  TrashListingRestartTests.swift
//  VariorumTests
//
//  VX-1016 (the VX-1082 run, batch D; `notes/plans/fixes/vx-1082-nov-24-fixes.md`
//  BATCH D) — **a Trash listing whose question changed has not answered yet,
//  and never speaks the empty sentence for the old question's rows.**
//
//  Her word on the ticket: *"a test that makes it happen comes first, and if
//  none can, it closes as not real."* These pins were WRITTEN FIRST, against
//  the pre-fix tree (test-only commit), before any line of the fix.
//
//  THE MECHANISM (traced in the record): the flag `trashListingLoaded` is
//  documented as "Lowered whenever the listing's query restarts (a filter, a
//  sort, a wing)", but only `ask(_:)` (VX-980 round 1's MINOR-1) and
//  `startTrash` itself lower it and move the question token. The kind
//  filter's and the order's `didSet`s only bump `restartToken`, and the wing
//  has no door in the model at all (the view's `.task(id:)` carries it). The
//  view's restart runs `startTrash` a main-actor job LATER, so (a) the render
//  the change itself causes reads the new filter or wing over the old,
//  still-answered listing — "The Trash is empty." over a Trash holding rows —
//  and (b) an answer of the old question already in flight still passes
//  `answers(_:)` and lands. Each pin drives exactly that beat: the change,
//  with NO new `startTrash` run (the view's restart has not run yet).
//
//  RED ON OLD, by the fix commit's behavioural revert (its product diff,
//  `RecoveryView.swift` only, reverse-applied): every test here but the
//  tails (which run the restart) — see each test's own note.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// One turn of the main run loop (a sync helper — `TrashSearchModelTests`'
/// shape).
@MainActor
private func pump(_ seconds: TimeInterval = 0.02) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Pumps the run loop and yields until `done`, or the bound passes.
@MainActor
private func settle(until done: () -> Bool, seconds: TimeInterval = 10) async {
    let deadline = Date().addingTimeInterval(seconds)
    while !done(), Date() < deadline {
        pump()
        for _ in 0..<10 { await Task.yield() }
    }
}

/// A box the DEBUG answer gate parks one continuation in (holds once).
@MainActor
private final class HeldAnswer {
    var continuation: CheckedContinuation<Void, Never>?
    var used = false

    /// The gate: holds the first answer `question` delivers, once.
    func gate(for question: UInt64) -> @MainActor (UInt64) async -> Void {
        { [self] asked in
            guard asked == question, !used else { return }
            used = true
            await withCheckedContinuation { continuation = $0 }
        }
    }

    func release() {
        continuation?.resume()
        continuation = nil
    }
}

/// Home's Trash: two deleted notes and a deleted block — NO snippet group, so
/// the Snippet Groups filter lists nothing while the Trash holds three rows.
private struct HomeTrash: Sendable {
    let rows: Int

    @MainActor
    static func make(_ editor: EditorHarness) async throws -> HomeTrash {
        try await editor.session.runner.run { (ops: Operations) -> HomeTrash in
            let garden = try ops.createPost(title: "garden plans")
            _ = try ops.newBlock(in: garden.id, text: "We moved the rhubarb.")
            let orchard = try ops.createPost(title: "apple orchard")
            let kitchen = try ops.createPost(title: "kitchen")
            let crumble = try ops.newBlock(in: kitchen.id, text: "rhubarb crumble")
            try ops.deleteContainer(garden.id)
            try ops.deleteContainer(orchard.id)
            try ops.deleteBlock(crumble.block.id)
            return HomeTrash(rows: 3)
        }
    }
}

/// A second wing whose Trash holds one deleted note, while Home's holds
/// nothing.
@MainActor
private func atticWithADeletedNote(_ editor: EditorHarness) async throws -> String {
    try await editor.session.runner.run { (ops: Operations) -> String in
        let attic = try ops.createWing(name: "attic")
        let boxes = try ops.createPost(title: "boxes", wingId: attic.id)
        try ops.deleteContainer(boxes.id)
        return attic.id
    }
}

@MainActor
@Suite("VX-1016 — a restarted Trash listing never claims an empty Trash before it answers", .serialized)
struct TrashListingRestartTests {

    // MARK: - The kind filter

    /// **The ticket's own case — the render beat.** The Snippet Groups filter
    /// over a Trash holding none (its two-facts line), then "all kinds"
    /// picked: the render that pick causes, before the view's restart runs,
    /// must say nothing — never "The Trash is empty." over three rows.
    /// **Red on old:** the flag stays raised from the filtered answer, `trash`
    /// is `[]` and the filter is nil, so the line reads "The Trash is empty."
    /// (two expectations).
    @Test func pickingAllKindsSpeaksNoEmptyLineBeforeTheListingAnswers() async throws {
        try await withEditor { editor in
            let world = try await HomeTrash.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.kindFilter = .snippetGroup
            let total = Task { await model.startTrashTotal() }
            defer { total.cancel() }
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded && model.trashTotalLoaded })
            #expect(model.trash.isEmpty, "premise: no snippet group is in the Trash")
            #expect(!model.trashIsEmptyUnfiltered, "premise: the Trash holds other things")
            #expect(model.trashEmptyStateLine
                == RecoveryCopy.trashEmptyLine(filteredBy: .snippetGroup, holdsOtherKinds: true),
                    "premise: the filter's two-facts line")

            // Her pick — "all kinds" — and the render it causes, BEFORE the
            // view's `.task(id:)` restart has run the next `startTrash`.
            model.kindFilter = nil
            #expect(!model.trashListingLoaded, "the changed question has not answered")
            #expect(model.trashEmptyStateLine == nil,
                    "never \"The Trash is empty.\" over a Trash holding rows: \(String(describing: model.trashEmptyStateLine))")

            // The restart answers: every row, no sentence.
            listing.cancel()
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded && model.trash.count == world.rows })
            #expect(model.trash.count == world.rows)
            #expect(model.trashEmptyStateLine == nil)
        }
    }

    /// **The in-flight answer.** The filtered question's first answer (empty)
    /// is held at the DEBUG gate while the filter goes back to "all kinds"
    /// with no restart run; released, it must not land. **Red on old:** the
    /// filter's `didSet` never moved the question, so the held answer still
    /// answers it — `adoptListing([])` raises the flag, blanks the three rows
    /// and the line reads "The Trash is empty." (three expectations).
    @Test func anAnswerInFlightWhenTheFilterChangesIsDropped() async throws {
        try await withEditor { editor in
            let world = try await HomeTrash.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let total = Task { await model.startTrashTotal() }
            defer { total.cancel() }
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded && model.trashTotalLoaded })
            #expect(model.trash.count == world.rows, "premise: the whole Trash is on screen")

            // Snippet Groups picked: the view's restart cancels the plain
            // listing and starts the filtered one, whose answer is held.
            model.kindFilter = .snippetGroup
            listing.cancel()
            let held = HeldAnswer()
            // Read AFTER the pick: a pick may be a question of its own.
            model.listingAnswerGate = held.gate(for: model.listingQuestion &+ 1)
            listing = Task { await model.startTrash() }
            await settle(until: { held.continuation != nil })
            #expect(held.continuation != nil, "premise: the filtered answer is held")
            #expect(model.trash.count == world.rows && !model.trashListingLoaded,
                    "premise: the rows stay drawn, the question unanswered")

            // "all kinds" again — and the view's restart has NOT run yet.
            model.kindFilter = nil
            held.release()
            await settle(until: { model.trashListingLoaded || model.trash.isEmpty }, seconds: 0.5)
            #expect(!model.trashListingLoaded, "the filtered answer never answered the whole Trash's question")
            #expect(model.trash.count == world.rows, "its empty answer never blanked the rows")
            #expect(model.trashEmptyStateLine == nil,
                    "never \"The Trash is empty.\" over three rows: \(String(describing: model.trashEmptyStateLine))")

            // The restart answers the question asked.
            listing.cancel()
            model.listingAnswerGate = nil
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.count == world.rows)
            #expect(model.trashEmptyStateLine == nil)
        }
    }

    // MARK: - The order

    /// **The order's door — the flag's own contract.** Flipping the order
    /// lowers the listing until the new order answers; the rows stay drawn
    /// and no sentence speaks. The order never changes the listed SET, so
    /// the sentence it could leave standing would still be true — this pins
    /// the flag the doc promises ("Lowered whenever the listing's query
    /// restarts (a filter, a sort, a wing)"). **Red on old:** the flag stays
    /// raised through the beat (one expectation).
    @Test func flippingTheOrderLowersTheListingUntilItAnswers() async throws {
        try await withEditor { editor in
            let world = try await HomeTrash.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.count == world.rows, "premise: the whole Trash is on screen")
            let listed = Set(model.trash.map(\.id))

            model.oldestFirst = true
            #expect(!model.trashListingLoaded, "the flipped order has not answered")
            #expect(model.trash.count == world.rows, "the rows stay drawn")
            #expect(model.trashEmptyStateLine == nil)

            listing.cancel()
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded })
            #expect(Set(model.trash.map(\.id)) == listed, "the restart answers the same rows")
        }
    }

    // MARK: - The wing

    /// **The wing's door — the render beat.** Home's Trash is empty and
    /// answered ("The Trash is empty." — true there); the app's wing switches
    /// in place (the cross-wing follow) to a wing whose Trash holds a note.
    /// Before the view's restart answers for the new wing, nothing is said.
    /// **Red on old:** the model has no wing door, so the line still reads
    /// Home's "The Trash is empty." over the attic's Trash (one expectation).
    @Test func aWingSwitchSpeaksNoEmptyLineBeforeTheNewWingAnswers() async throws {
        try await withEditor { editor in
            let attic = try await atticWithADeletedNote(editor)
            let model = RecoveryViewModel(session: editor.session)
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.isEmpty, "premise: Home's Trash holds nothing")
            #expect(model.trashEmptyStateLine == RecoveryCopy.trashEmptyLine(filteredBy: nil, holdsOtherKinds: false),
                    "premise: the sentence is true for Home")

            editor.session.wing.switchTo(attic)
            #expect(model.trashEmptyStateLine == nil,
                    "never Home's empty sentence over the attic's Trash: \(String(describing: model.trashEmptyStateLine))")

            // The view's restart (its `.task(id:)` carries the wing) answers
            // for the attic.
            listing.cancel()
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded && !model.trash.isEmpty })
            #expect(model.trash.count == 1)
            #expect(model.trashEmptyStateLine == nil)
        }
    }

    /// **The wing's in-flight answer.** Home's first answer (empty) is held at
    /// the gate while the wing switches to the attic, with no restart run;
    /// released, it must not answer the attic's question. **Red on old:**
    /// nothing in the question names its wing, so Home's answer lands — the
    /// flag rises and the line reads "The Trash is empty." over the attic's
    /// note (two expectations).
    @Test func anAnswerInFlightWhenTheWingSwitchesIsDropped() async throws {
        try await withEditor { editor in
            let attic = try await atticWithADeletedNote(editor)
            let model = RecoveryViewModel(session: editor.session)
            let held = HeldAnswer()
            model.listingAnswerGate = held.gate(for: model.listingQuestion &+ 1)
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { held.continuation != nil })
            #expect(held.continuation != nil, "premise: Home's answer is held")

            editor.session.wing.switchTo(attic)
            held.release()
            await settle(until: { model.trashListingLoaded }, seconds: 0.5)
            #expect(!model.trashListingLoaded, "Home's answer never answered the attic's question")
            #expect(model.trashEmptyStateLine == nil,
                    "never Home's empty sentence over the attic's Trash: \(String(describing: model.trashEmptyStateLine))")

            listing.cancel()
            model.listingAnswerGate = nil
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.count == 1, "the restart answers for the attic")
            #expect(model.trashEmptyStateLine == nil)
        }
    }
}
