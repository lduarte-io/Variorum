//
//  DivideArrangementTests.swift
//  VariorumTests
//
//  **THE ARRANGEMENT ROW** — her rulings U-3 and U-5 (2026-09-06 use-report
//  round, 18f batch 1), the divide sheet's FIRST control:
//
//  U-3, verbatim: *"Takes should automatically be selected in the divide
//  ceremony to come along with and should automatically have the scissors at
//  the end."*
//  U-5, verbatim: *"three options … 1. all takes stay with the top block
//  2. all takes stay with the bottom block 3. all takes go on both. I think
//  those options should feel easily available in the divide ceremony for ease
//  and the custom selector should be something you really have to choose to
//  do."*
//
//  The two claims that matter most are pinned here as EQUIVALENCES rather
//  than as re-derived arithmetic: the "keep on top" preset's cuts dict IS
//  `KeepOnTopDivide.compose`'s, byte-for-byte, and confirming the sheet
//  unchanged lands the same ROWS the instant ⌘⇧D door lands on the same
//  fixture. That is the whole promise of "the default the instant divide
//  uses is the one selected on open".
//
//  RED-ON-OLD (procedure for the verifier): these describe behaviour that did
//  not exist before 18f batch 1 — the pre-batch sheet had no arrangement at
//  all, opened with only the SEED take marked, and seeded the other takes
//  from `CutPropagation`. Reverting `DivideWCeremony.arranged` out of `open`
//  reds `theSheetOpensKeptOnTopWithEveryTakeCheckedAndTheScissorsAtTheEnd`,
//  `theKeepOnTopPresetsCutsAreTheInstantDefaultsOwnComposition` and
//  `confirmingTheSheetUnchangedReproducesTheInstantDivide`.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The divide sheet's arrangement row (U-3 · U-5)")
struct DivideArrangementTests {
    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    private func fan(_ h: EditorHarness, _ blockID: String) throws -> [Variant] {
        try h.database.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.deletedAt == nil && $0.status == .active }
        }
    }

    /// A block carrying `takes` takes, the first "Alpha one. Alpha two.".
    /// Returns the block id.
    @discardableResult
    private func fanned(
        _ h: EditorHarness, others: [String] = ["Beta one. Beta two."]
    ) throws -> String {
        let slot = try #require(try h.storeSlots().first)
        for text in others {
            let variant = try h.session.operations.branchVariant(
                slot.blockID, from: try #require(slot.variantID))
            try h.session.operations.autosave(variant.id, text: text, charDelta: 0)
        }
        try h.reload()
        return slot.blockID
    }

    // MARK: - U-3 / U-5: what the sheet opens as

    /// **THE OPENING STATE** — her U-3 and the first half of U-5 in one
    /// assertion: the row is on "Keep takes on the top block", EVERY take is
    /// checked, the seed carries the gesture's cut, and every other ✂ sits
    /// at its take's very END (the parking position that rides a take whole
    /// onto the top block).
    @Test func theSheetOpensKeptOnTopWithEveryTakeCheckedAndTheScissorsAtTheEnd() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let blockID = try fanned(h, others: ["Beta one. Beta two.", "Gamma alone."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)

            let state = try #require(h.model.divideWCeremony)
            #expect(state.arrangement == .keepOnTop, "her U-2 default is the one selected")
            #expect(state.takes.count == 3)
            #expect(state.takes.allSatisfy { $0.marked }, "U-3: every take checked")
            let seed = try #require(state.seedTake)
            #expect(seed.cut == 11, "the seed keeps the gesture's own cut")
            for take in state.otherTakes {
                #expect(take.cut == take.variant.workingText.utf16.count,
                        "U-3: the ✂ at the very end of \(take.variant.workingText.debugDescription)")
                #expect(take.parkedAtEnd, "…which IS the ride-whole-onto-the-top parking")
            }
            #expect(state.confirmBlocker == nil, "and it is confirmable as it stands")
            _ = blockID
        }
    }

    /// **THE EQUIVALENCE, at the arguments.** The preset does not re-derive
    /// the instant default's arithmetic — it goes THROUGH
    /// `KeepOnTopDivide.compose`, so the two cuts dicts are the same object's
    /// answer. This pin holds that promise where it can be read.
    @Test func theKeepOnTopPresetsCutsAreTheInstantDefaultsOwnComposition() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let blockID = try fanned(h, others: ["Beta one. Beta two.", "Gamma alone."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let state = try #require(h.model.divideWCeremony)

            let live = try fan(h, blockID)
            let composition = try #require(KeepOnTopDivide.compose(
                displayedID: state.activeVariantID, cut: 11, fan: live))
            #expect(state.markedCuts == composition.cuts,
                    "byte-for-byte the instant default's cuts")

            // …and the mirror preset is the mirror composition.
            h.model.divideWCeremonyController.setArrangement(.keepOnBottom)
            let below = try #require(h.model.divideWCeremony)
            let mirror = try #require(KeepOnTopDivide.compose(
                keepBelow: state.activeVariantID, cut: 11, fan: live))
            #expect(below.markedCuts == mirror.cuts)
            #expect(below.otherTakes.allSatisfy { $0.parkedAtStart },
                    "the others park at their START — they ride into the bottom block")
        }
    }

    /// **THE EQUIVALENCE, at the rows.** Two identical fixtures: one divided
    /// through the instant ⌘⇧D door, one through the sheet confirmed
    /// unchanged. The store ends in the same shape — same texts, same fan
    /// sizes, same labels, same chosen take on each side. (Ids differ by
    /// construction; everything the author can see does not.)
    @Test func confirmingTheSheetUnchangedReproducesTheInstantDivide() async throws {
        func shape(_ h: EditorHarness) throws -> [[String]] {
            try h.storeSlots().map { slot in
                try fan(h, slot.blockID).map {
                    "\($0.label ?? "-")|\($0.workingText)|\($0.id == slot.variantID ? "chosen" : "")"
                }
            }
        }

        var instant: [[String]] = []
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor)
            #expect(h.model.divideWCeremony == nil, "the instant door asks nothing")
            instant = try shape(h)
        }

        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            #expect(h.model.divideWCeremony != nil, "the ⌥⌘⇧D door asks")
            await h.model.divideWCeremonyController.confirm()
            #expect(h.model.divideWCeremony == nil, "and it landed")
            let viaSheet = try shape(h)
            #expect(viaSheet == instant,
                    "confirming the sheet unchanged IS the instant divide")
        }
        #expect(instant.count == 2, "non-vacuity: the fixture really divided")
        #expect(instant[0].count == 2, "…the top block kept the other take")
        #expect(instant[1].count == 1, "…the bottom block carries one")
    }

    // MARK: - The presets' own roads

    /// **"Copy takes to both" confirms through `divideDuplicating`** — the
    /// 13j J4 shape her U-2 retired as the DEFAULT and U-5 keeps as the third
    /// preset. Both successors end up carrying the other take whole.
    @Test func copyTakesToBothLandsTheDuplicateShape() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let ceremony = h.model.divideWCeremonyController
            ceremony.setArrangement(.copyToBoth)

            let state = try #require(h.model.divideWCeremony)
            #expect(state.takes.allSatisfy { $0.marked }, "every take comes along")
            #expect(state.otherTakes.allSatisfy { $0.cut == nil },
                    "…and none of them is CUT — there is no ✂ in a duplicate")
            #expect(state.confirmBlocker == nil)

            await ceremony.confirm()
            #expect(h.model.divideWCeremony == nil, "it landed")
            let after = try h.storeSlots()
            #expect(after.count == 2)
            #expect(after.map(\.text) == ["Alpha one.", "Alpha two."])
            #expect(after[0].activeVariantCount == 2, "the top block carries the copy")
            #expect(after[1].activeVariantCount == 2, "and so does the bottom block")
            for slot in after {
                let takes = try fan(h, slot.blockID).map(\.workingText)
                #expect(takes.contains("Beta one. Beta two."),
                        "the other take rode WHOLE onto both")
            }
        }
    }

    /// **"Choose per take…" is the checklist, and it inherits U-3's shape.**
    /// Every take checked, the non-seed ✂ at the end — the hand-placement
    /// surface opens where the preset left it rather than at a propagated
    /// guess, and a hand-placed cut survives switching back to it.
    @Test func choosePerTakeRevealsTheChecklistAtTheEnds() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let ceremony = h.model.divideWCeremonyController
            ceremony.setArrangement(.perTake)

            let state = try #require(h.model.divideWCeremony)
            #expect(state.arrangement == .perTake)
            #expect(state.takes.allSatisfy { $0.marked }, "U-3 holds here too")
            #expect(state.otherTakes.allSatisfy { $0.parkedAtEnd }, "…✂ at the ends")

            // A hand placement, then the round trip through a preset and back.
            let other = try #require(state.otherTakes.first)
            ceremony.placeCut(takeID: other.id, cut: 10)
            #expect(h.model.divideWCeremony?.otherTakes.first?.cut == 10)
            ceremony.setArrangement(.keepOnTop)
            #expect(h.model.divideWCeremony?.otherTakes.first?.parkedAtEnd == true,
                    "a preset re-places every ✂ — that is what choosing one means")
            ceremony.setArrangement(.perTake)
            #expect(h.model.divideWCeremony?.otherTakes.first?.parkedAtEnd == true,
                    "and the checklist opens where the preset left it")
        }
    }

    /// An UNCHECKED take under "Choose per take" still stays on the original
    /// block — the shipped rule, unmoved by the row.
    @Test func anUncheckedTakeUnderChoosePerTakeStaysOnTheOriginal() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            let blockID = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let ceremony = h.model.divideWCeremonyController
            ceremony.setArrangement(.perTake)
            let other = try #require(h.model.divideWCeremony?.otherTakes.first)
            ceremony.toggleTake(other.id)
            #expect(h.model.divideWCeremony?.otherTakes.first?.marked == false)

            await ceremony.confirm()
            let after = try h.storeSlots()
            #expect(after.count == 2)
            #expect(after.allSatisfy { $0.activeVariantCount == 1 },
                    "neither successor got the unchecked take")
            let onA = try fan(h, blockID).count
            #expect(onA == 2, "…it is still on A, preserved whole in lineage")
        }
    }

    // MARK: - The empty take (KeepOnTopDivide's `unparkable`, in the sheet)

    /// An EMPTY other take has no legal cut at all, so a preset leaves it
    /// UNCHECKED — it stays on the original block, exactly as the instant
    /// road reports it — and the sentence under the row says so.
    @Test func anEmptyOtherTakeIsLeftUnplacedAndNamedInTheSentence() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two.", ""])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let state = try #require(h.model.divideWCeremony)

            #expect(state.unparkableTakes.count == 1)
            let empty = try #require(state.takes.first { $0.variant.workingText.isEmpty })
            #expect(!empty.marked, "an empty take cannot park — it stays on the original")
            #expect(state.markedCuts.count == 2, "the seed and the one placeable other")

            let sentence = DivideWCeremony.arrangementSentence(
                .keepOnTop, others: state.otherTakes.count,
                unparkable: state.unparkableTakes.count)
            // 18f ladder R1-3 (fable-reviewer): the PARKED count — the fan
            // has two other takes, but the empty one cannot park and the
            // sentence already says so; this pin used to certify the double
            // count ("2 other takes stay whole … 1 empty take can't be placed").
            #expect(sentence.contains("1 other take stays whole on the top block"),
                    "the parked count, not the fan's: \(sentence)")
            #expect(!sentence.contains("2 other takes"))
            #expect(sentence.contains("1 empty take can't be placed"))
        }
    }

    // MARK: - The sentence (a pure function of the state, per the mockup)

    @Test func theSentenceUnderTheRowSaysWhatWillHappenInCounts() {
        let top = DivideWCeremony.arrangementSentence(.keepOnTop, others: 2, unparkable: 0)
        #expect(top == "The take you were in splits at the \u{2702}. 2 other takes stay whole "
                + "on the top block; the bottom block starts with one take. "
                + "Reversible — \u{2325}\u{2318}Z.",
                "the mockup's own sentence")
        // 18f ladder R1-3 (fable-reviewer): the singular is CONJUGATED — this
        // pin used to certify "1 other take stay whole", which every two-take
        // divide showed her (the J8 doctrine's own failure mode: a pin that
        // certifies copy instead of checking it).
        let bottom = DivideWCeremony.arrangementSentence(.keepOnBottom, others: 1, unparkable: 0)
        #expect(bottom.contains("1 other take stays whole on the bottom block"),
                "singular counts, conjugated: \(bottom)")
        let both = DivideWCeremony.arrangementSentence(.copyToBoth, others: 3, unparkable: 0)
        #expect(both.contains("3 other takes ride whole onto BOTH blocks"))
        let bothOne = DivideWCeremony.arrangementSentence(.copyToBoth, others: 1, unparkable: 0)
        #expect(bothOne.contains("1 other take rides whole onto BOTH blocks"),
                "copy-to-both keeps the fan's count — an empty take is duplicated too")
        // Every other take empty: nothing parks, and the sentence says what
        // each block starts with instead of counting zero takes.
        let allEmpty = DivideWCeremony.arrangementSentence(.keepOnTop, others: 1, unparkable: 1)
        #expect(allEmpty.contains("Each new block starts with one take."))
        #expect(allEmpty.contains("1 empty take can't be placed"))
        #expect(!allEmpty.contains("0 other takes"))
        let hand = DivideWCeremony.arrangementSentence(.perTake, others: 3, unparkable: 0)
        #expect(hand.contains("An unchecked take is not cut"),
                "the hand-placement surface says its own rule instead of counts")
    }

    // MARK: - The confirm gate, per arrangement

    /// Each preset's blocker is the OPERATION's own refusal, said before the
    /// fact: keep-on-top with the seed parked at its end would leave the
    /// bottom block takeless (`divideSideWouldBeEmpty`), keep-on-bottom is
    /// the mirror, and copy-to-both needs a cut inside the take
    /// (`divideDuplicating`'s `invalidCut`).
    @Test func eachPresetsBlockerIsItsOperationsOwnRefusal() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two."]) { h in
            _ = try fanned(h, others: ["Beta one. Beta two."])
            caret(h, entry: 0, offset: 11)
            await h.model.invokeGesture(.divideAtCursor, ceremony: true)
            let ceremony = h.model.divideWCeremonyController
            let seedID = try #require(h.model.divideWCeremony?.activeVariantID)
            let end = "Alpha one. Alpha two.".utf16.count

            ceremony.placeCut(takeID: seedID, cut: end)
            let blockedTop = try #require(h.model.divideWCeremony?.confirmBlocker)
            #expect(blockedTop.contains("bottom block would be born without a take"))

            ceremony.setArrangement(.copyToBoth)
            let blockedBoth = try #require(h.model.divideWCeremony?.confirmBlocker)
            #expect(blockedBoth.contains("needs a cut INSIDE this take"))

            ceremony.setArrangement(.keepOnBottom)
            #expect(h.model.divideWCeremony?.confirmBlocker == nil,
                    "the seed parked at its END is legal keeping the takes BELOW")

            ceremony.placeCut(takeID: seedID, cut: 0)
            let blockedBottom = try #require(h.model.divideWCeremony?.confirmBlocker)
            #expect(blockedBottom.contains("top block would be born without a take"))

            // And the hand-placed surface keeps its own four rules verbatim.
            ceremony.setArrangement(.perTake)
            ceremony.placeCut(takeID: seedID, cut: 11)
            #expect(h.model.divideWCeremony?.confirmBlocker == nil)
            for take in try #require(h.model.divideWCeremony?.takes) {
                ceremony.toggleTake(take.id)
            }
            #expect(h.model.divideWCeremony?.confirmBlocker
                == "Check at least one take to carry the cut through.")
        }
    }
}
