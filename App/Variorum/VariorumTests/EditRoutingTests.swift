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
    private func armed(
        _ range: NSRange, replacing replacementLength: Int, documentLength: Int = 27
    ) -> ArmedEdit {
        ArmedEdit(
            verdict: .block(index: 0), range: range, documentLength: documentLength,
            replacementLength: replacementLength)
    }

    @Test func anOrdinaryInsertionIsDescribed() {
        let edit = armed(NSRange(location: 12, length: 0), replacing: 1)
        #expect(edit.describes(
            editedRange: NSRange(location: 12, length: 1), delta: 1, documentLength: 27))
    }

    @Test func anOrdinaryDeletionIsDescribed() {
        let edit = armed(NSRange(location: 11, length: 1), replacing: 0)
        #expect(edit.describes(
            editedRange: NSRange(location: 11, length: 0), delta: -1, documentLength: 27))
    }

    @Test func aReplacementWidenedByAttributeFixingIsStillDescribed() {
        // The measured iOS wrinkle (a 5→6 replacement reporting length 7):
        // attribute fixing widens the reported RANGE and never the DELTA,
        // so an ordinary widened report still binds. This is the pin the
        // finding-1 fix had to keep passing — the net change is policed,
        // the extent deliberately is not.
        let edit = armed(NSRange(location: 7, length: 3), replacing: 4)
        #expect(edit.describes(
            editedRange: NSRange(location: 7, length: 4), delta: 1, documentLength: 27))
    }

    @Test func aDeletionWiderThanTheApprovedRangeIsRejected() {
        // Her crash, in one line: the gate approved five characters and a
        // coalesced transaction removed fifteen.
        let edit = armed(NSRange(location: 22, length: 5), replacing: 0)
        #expect(!edit.describes(
            editedRange: NSRange(location: 12, length: 0), delta: -15, documentLength: 27))
    }

    /// **Round-2 ladder round 1, MAJOR 1 — the hole the magnitude bound
    /// left open.** A transaction that BEGINS inside the approved range and
    /// runs PAST the region's end, replacing more than was approved with
    /// fewer characters, satisfies every one of the old guards: it starts
    /// where it should, and it deletes fewer characters than the approved
    /// range held. The old predicate said yes, and the wrong block's length
    /// was then recorded — silently, because the totals still agreed.
    ///
    /// RED ON THE PRE-FIX PREDICATE (`-delta <= range.length`): −4 ≤ 5.
    @Test func aComposedTransactionWiderThanTheApprovalIsRejected() {
        let edit = armed(NSRange(location: 16, length: 5), replacing: 0)
        #expect(!edit.describes(
            editedRange: NSRange(location: 16, length: 7), delta: -4, documentLength: 27),
            "a delete composed with a reinsertion nets to something the approval never described")
    }

    /// The insertion half of the same hole: for `delta >= 0` the old
    /// magnitude bound was VACUOUSLY true, so an arming could absorb
    /// unbounded growth. RED ON THE PRE-FIX PREDICATE.
    @Test func anInsertionLargerThanTheApprovedReplacementIsRejected() {
        let edit = armed(NSRange(location: 12, length: 0), replacing: 1)
        #expect(!edit.describes(
            editedRange: NSRange(location: 12, length: 40), delta: 40, documentLength: 27),
            "one approved character cannot license forty")
    }

    /// **Round-2 ladder round 2, M15 Q2(b) — the delta-0 half of the same
    /// class.** Guard 3's upper bound used to be inclusive for every
    /// approval, so a report starting exactly at a NON-EMPTY approval's
    /// `upperBound` — i.e. at the separator after the last approved
    /// character, the first offset that is no longer the approved block's —
    /// still bound. At `delta == 0` nothing downstream can see it: the
    /// mutator succeeds (a zero delta is always legal), `documentLength`
    /// still agrees with storage, and `recordAutosave` then records the
    /// APPROVED block's text while the block that actually changed is never
    /// written. The bound is now strict for a non-empty approval.
    ///
    /// RED ON THE PRE-FIX PREDICATE (`location <= range.upperBound`):
    /// 15 ≤ 15 passed, and every other guard passes on its own terms.
    ///
    /// The inclusive bound for an EMPTY approval is not collateral damage
    /// of this fix and is pinned by `anOrdinaryInsertionIsDescribed` above,
    /// whose report starts at `location == upperBound` by construction.
    @Test func aLandingAtTheEndOfANonEmptyApprovalIsRejected() {
        let edit = armed(NSRange(location: 14, length: 1), replacing: 1)
        #expect(!edit.describes(
            editedRange: NSRange(location: 15, length: 7), delta: 0, documentLength: 27),
            "the character after the approval is a different block's, whatever the net")
    }

    @Test func aLandingOutsideTheApprovedRangeIsRejected() {
        // The replacement length matches the delta, so ONLY the location
        // guard can reject this one — the pin keeps its original subject.
        let edit = armed(NSRange(location: 0, length: 1), replacing: 2)
        #expect(!edit.describes(
            editedRange: NSRange(location: 8, length: 1), delta: 1, documentLength: 27))
    }

    @Test func aMovedIndexIsRejected() {
        let edit = armed(NSRange(location: 22, length: 0), replacing: 1)
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

    /// The Mac twin of the round-2 ladder's MAJOR 1: a coalesced
    /// transaction that begins inside the approved range and runs PAST the
    /// region's end is not consumed. The Mac's arm-then-hand-off sites
    /// (`MarkdownActs.apply`, `toggleCheckbox`,
    /// `insertNewlineContinuingLists`, `deleteWithoutNewline`) are one
    /// refactor from separating an arming from its `replaceCharacters`, and
    /// the binding is what makes that harmless — so it is pinned here for
    /// the same reason batch 1's twins were.
    ///
    /// RED ON THE PRE-FIX PREDICATE (no process death): the stale
    /// `.block(2)` is consumed, `entries[2]` becomes 1, and the totals
    /// still agree — so nothing announces it.
    @Test func aComposedTransactionWiderThanItsApprovalIsNotConsumed() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                fixture(harness)
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)

                #expect(model.shouldChangeText(
                    in: NSRange(location: 16, length: 5), replacement: ""))
                storage.beginEditing()
                storage.replaceCharacters(
                    in: NSRange(location: 16, length: 11), with: "Gamma??")
                storage.endEditing()

                #expect(model.desyncRecoveryCount == 1,
                        "the un-described transaction took the honest road")
                await settleMacEditor(until: {
                    model.index.documentLength == (harness.textView.textStorage?.length ?? -1)
                })
                #expect(harness.documentText == "Alpha\nBeta beta\nGamma\ndelta",
                        "the store is truth: the un-routable transaction did not stand")
                await harness.flush()
                let stored = try harness.storeSlots().compactMap(\.text)
                #expect(stored == ["Alpha", "Beta beta", "Gamma"],
                        "her paragraph was not overwritten with one character")
            }
        }
    }

    /// The BEHAVIOURAL twin of `aLandingAtTheEndOfANonEmptyApprovalIsRejected`
    /// (round-2 ladder round 2, M15 Q2(b)): the same predicate hole, traced
    /// to its consequence in the store.
    ///
    /// The gate approves the last character of block 1 (`(14,1)` → "A"),
    /// so the approval's `upperBound` is 15 — the separator, which belongs
    /// to no entry. A gate-less transaction then replaces `(15,7)`
    /// ("\nGamma\n") with seven other characters: it starts exactly at 15
    /// and nets to zero, which is exactly what the approval's own
    /// arithmetic predicts.
    ///
    /// RED ON THE PRE-FIX PREDICATE, and MEASURED there (the fix reverted
    /// to `<=`, this pin run): the arming binds,
    /// `applyBlockEdit(at: 1, lengthDelta: 0)` succeeds, `documentLength`
    /// still equals `storage.length`, block 1's ID is stamped over block 2's
    /// characters, and `recordAutosave` writes block 1's UNCHANGED text.
    /// The recorded reds are exactly the two halves of the harm:
    /// `desyncRecoveryCount == 0` (nothing announced it) and the surface
    /// reading **"Alpha\nBeta beta\nWORDS\ndelta"** while the store still
    /// says "Gamma" — a silent divergence, which the delta-0 shape makes
    /// invisible to every totals oracle. Today the arming is refused, the
    /// report falls through to `fallbackVerdict`, which sees a span crossing
    /// a boundary and takes the honest road.
    @Test func aLandingAtTheEndOfAnApprovedBlockIsNotConsumed() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                fixture(harness)
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)

                #expect(model.shouldChangeText(
                    in: NSRange(location: 14, length: 1), replacement: "A"))
                storage.beginEditing()
                storage.replaceCharacters(
                    in: NSRange(location: 15, length: 7), with: "\nWORDS\n")
                storage.endEditing()

                #expect(model.desyncRecoveryCount == 1,
                        "the landing at the approval's end took the honest road")
                // Settle on the TEXT, not on the totals: this transaction
                // nets to ZERO, so `documentLength == storage.length` holds
                // the whole time and a totals-settle would return before the
                // heal ever landed. That is the same blindness the fix is
                // about, so the pin must not lean on it either.
                await settleMacEditor(until: {
                    harness.documentText == "Alpha\nBeta beta\nGamma\ndelta"
                })
                #expect(harness.documentText == "Alpha\nBeta beta\nGamma\ndelta",
                        "the store is truth: the un-routable transaction did not stand")
                #expect(model.index.documentLength == (harness.textView.textStorage?.length ?? -1))
                await harness.flush()
                let stored = try harness.storeSlots().compactMap(\.text)
                // With the surface assertion above it: surface and store
                // AGREE, which is exactly the half the pre-fix tree lost.
                #expect(stored == ["Alpha", "Beta beta", "Gamma"],
                        "the store is unchanged, and still agrees with the surface")
            }
        }
    }

    /// **The Mac twin of the VM-5 stability pass's MAJOR 2** (the phone's
    /// `aStaleOpenTailArmingNeverBindsAGateLessCharacter`). `ArmedEdit` is
    /// the shared brain both `storageDidEdit`s consume through, so the
    /// content hole was both platforms' — the round-2 crash fix's own
    /// precedent (this file's header: a shared brain gaining a guard is
    /// where both platforms collect at once).
    ///
    /// The gate approves the tail-opening `"\n"` at the document end and
    /// arms `.openTail`; a gate-less `"x"` lands at the same spot instead.
    /// RED ON THE PRE-FIX TREE: the arming binds on geometry alone, the
    /// index opens an empty tail over a visible character, the audit fires,
    /// and nothing ever records the character — the store keeps "Alpha".
    @Test func aStaleOpenTailArmingNeverBindsAGateLessCharacter() async throws {
        try await withEditor(seedBlocks: ["Alpha"]) { harness in
            try await withMacEditorAssertionsMuted {
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)
                #expect(model.index.tailLength == nil, "precondition: no tail yet")

                #expect(model.shouldChangeText(
                    in: NSRange(location: 5, length: 0), replacement: "\n"))
                storage.replaceCharacters(in: NSRange(location: 5, length: 0), with: "x")

                #expect(harness.documentText == "Alphax")
                #expect(model.index.tailLength == nil,
                        "no tail opened: the landed character is not the newline the verdict means")
                #expect(model.index.entries.map(\.length) == [6])
                #expect(model.index.documentLength == storage.length)
                #expect(model.identityAuditFailures == 0)
                #expect(model.desyncRecoveryCount == 0)
                await harness.flush()
                #expect(try harness.storeSlots().compactMap(\.text) == ["Alphax"],
                        "the character reached the store instead of being stranded")
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
///
/// The mute is TASK-SCOPED (round-2 ladder round 1, MINOR 4): a
/// process-global handler held across this body's hundreds of `await`s
/// would disable the editor's Debug assertions inside whatever OTHER
/// parallel suite happened to be scheduled during a suspension. The
/// task-local binding reaches exactly what it should — this body, and the
/// tasks the recovery road spawns inside it.
@MainActor
func withMacEditorAssertionsMuted<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ _, _, _ in }) {
        try await body()
    }
}
