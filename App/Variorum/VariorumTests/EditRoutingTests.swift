//
//  EditRoutingTests.swift
//  VariorumTests
//
//  Mobile round 2, batch 1 — the MAC TWINS of the crash fix's pins, plus
//  the shared binding rule's own unit pins.
//
//  WHY THE MAC HAS TWINS AT ALL: `BlockRangeIndex` lives in
//  `App/Variorum/Shared/EditorBrain/` and `EditorViewModel.storageDidEdit`
//  is `MobileEditorViewModel.storageDidEdit`'s shape line for line — the
//  same two sources (identity from the parked gate answer, magnitude from
//  the storage report) with nothing binding them. The crash has only ever
//  been OBSERVED on iOS; the Mac survived on three accidents, not a
//  guarantee (the trace's §9 verdict: latent, not prevented). A shared
//  brain gaining a guard is exactly where both platforms collect at once
//  (MobileSoul §3; this round's M-B).
//
//  The process-killing reproductions live in `EditRoutingCrashTests.swift`
//  for the same reason as the phone's.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The shared binding rule (pure)

@Suite("ArmedEdit — the binding rule (round 2, M1 part 3)")
struct ArmedEditTests {
    private func armed(_ range: NSRange, documentLength: Int = 27) -> ArmedEdit {
        ArmedEdit(verdict: .block(index: 0), range: range, documentLength: documentLength)
    }

    @Test func anOrdinaryInsertionIsDescribed() {
        let edit = armed(NSRange(location: 12, length: 0))
        #expect(edit.describes(
            editedRange: NSRange(location: 12, length: 1), delta: 1, documentLength: 27))
    }

    @Test func anOrdinaryDeletionIsDescribed() {
        let edit = armed(NSRange(location: 11, length: 1))
        #expect(edit.describes(
            editedRange: NSRange(location: 11, length: 0), delta: -1, documentLength: 27))
    }

    @Test func aReplacementWidenedByAttributeFixingIsStillDescribed() {
        // The measured iOS wrinkle (a 5→6 replacement reporting length 7):
        // widening only grows the report, and the guards are about the
        // approved range's SIZE and the landing's START, so an ordinary
        // widened report still binds.
        let edit = armed(NSRange(location: 7, length: 3))
        #expect(edit.describes(
            editedRange: NSRange(location: 7, length: 4), delta: 1, documentLength: 27))
    }

    @Test func aDeletionWiderThanTheApprovedRangeIsRejected() {
        // Her crash, in one line: the gate approved five characters and a
        // coalesced transaction removed fifteen.
        let edit = armed(NSRange(location: 22, length: 5))
        #expect(!edit.describes(
            editedRange: NSRange(location: 12, length: 0), delta: -15, documentLength: 27))
    }

    @Test func aLandingOutsideTheApprovedRangeIsRejected() {
        let edit = armed(NSRange(location: 0, length: 1))
        #expect(!edit.describes(
            editedRange: NSRange(location: 8, length: 1), delta: 1, documentLength: 27))
    }

    @Test func aMovedIndexIsRejected() {
        let edit = armed(NSRange(location: 22, length: 0))
        #expect(!edit.describes(
            editedRange: NSRange(location: 22, length: 1), delta: 1, documentLength: 22),
            "the tiling changed under the arming (a render or a crystallization)")
    }
}

// MARK: - The Mac editor's binding

@MainActor
@Suite("Mac edit routing — the verdict is bound to its edit (round 2, M1)")
struct MacEditRoutingTests {
    /// The crash trace's §5 document, Mac-side: three blocks + a
    /// freshly-typed open tail (entries 5 / 9 / 5, tail 5, length 27).
    private func fixture(_ harness: EditorHarness) {
        harness.type("\n", at: harness.model.index.documentLength)
        harness.type("delta")
    }

    @Test func theFixtureIsTheTracesDocument() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            fixture(harness)
            #expect(harness.documentText == "Alpha\nBeta beta\nGamma\ndelta")
            #expect(harness.model.index.entries.map(\.length) == [5, 9, 5])
            #expect(harness.model.index.tailLength == 5)
            #expect(harness.model.index.documentLength == 27)
            #expect(harness.model.desyncRecoveryCount == 0)
        }
    }

    /// The Mac twin of the phone's headline pin: a verdict armed for an
    /// edit that never lands must not be applied to the edit that lands
    /// next. RED ON THE PRE-FIX TREE with no process death (the stale
    /// `.block(0)` grows the wrong entry).
    @Test func aStaleVerdictIsNotAppliedToTheNextEdit() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                fixture(harness)
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)

                // Arm a verdict for an edit that never reaches storage.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 0, length: 1), replacement: "X"))

                // …then land an unrelated insertion inside block 1 through
                // a path that consults no gate.
                storage.replaceCharacters(in: NSRange(location: 8, length: 0), with: "!")

                #expect(harness.documentText == "Alpha\nBe!ta beta\nGamma\ndelta")
                #expect(model.index.entries[1].length == 10, "the edit's own block grew")
                #expect(model.index.entries[0].length == 5,
                        "the stale verdict's block is untouched")
                #expect(model.index.documentLength == storage.length)
                #expect(model.desyncRecoveryCount == 0)
            }
        }
    }

    /// The other half: an arming that still describes its edit is honored,
    /// so the fix is a binding and not a blanket discard.
    @Test func anArmingThatStillDescribesItsEditIsHonored() async throws {
        try await withEditor(seedBlocks: ["Alpha beta."]) { harness in
            harness.type("!", at: 5)
            #expect(harness.documentText == "Alpha! beta.")
            #expect(harness.model.index.entries[0].length == 12)
            #expect(harness.model.desyncRecoveryCount == 0)
            await harness.flush()
            let stored = try harness.storeSlots().compactMap(\.text)
            #expect(stored == ["Alpha! beta."])
        }
    }
}

/// Spins the main actor until `condition` holds or the budget runs out
/// (`desyncRecovery` heals through an async read).
@MainActor
func settleMacEditor(until condition: () -> Bool, spins: Int = 400) async {
    for _ in 0..<spins {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

/// The Mac's mute helper (the phone's twin — `EditorAssertionSeam` is
/// shared, so the pattern is one).
@MainActor
func withMacEditorAssertionsMuted<T>(_ body: () async throws -> T) async rethrows -> T {
    let original = EditorAssertionSeam.handler
    EditorAssertionSeam.handler = { _ in }
    defer { EditorAssertionSeam.handler = original }
    return try await body()
}
