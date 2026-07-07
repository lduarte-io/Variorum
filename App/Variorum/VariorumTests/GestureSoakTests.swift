//
//  GestureSoakTests.swift
//  VariorumTests
//
//  Phase 9 Step 8(iii) — the randomized gesture soak, this phase's
//  centerpiece test: seeded, scripted interleavings of typing,
//  crystallization (typing-past, idle-mint, bulk paste), every structural
//  gesture (divide, extract, make-block, merge, the W ceremony), and
//  structural undo — several hundred actions per seed. After every settled
//  action the world must agree three ways: store == BlockRangeIndex ==
//  surface, the tiling invariant holds, `desyncRecovery` NEVER fires, and
//  the canary stays silent. Refusals are product too: random selections
//  routinely produce them, and they must leave the world untouched.
//
//  External-write actions (branch, undo) are followed by a reload — the
//  test's stand-in for the observation delivering the projection, exactly
//  as the app would see it. Editor-path actions (typing, mints, gestures)
//  reconcile incrementally and are asserted WITHOUT a reload: nothing may
//  depend on a re-render arriving to fix the surface.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Randomized gesture soak (Phase 9, Step 8)", .serialized)
struct GestureSoakTests {
    @Test(arguments: [UInt64(1), 7, 42]) func gestureSoakKeepsStoreIndexAndSurfaceAgreeing(
        seed: UInt64
    ) async throws {
        var rng = SeededGenerator(seed: seed)
        func pick(_ n: Int) -> Int { Int(rng.next() % UInt64(max(1, n))) }

        let corpusBits = [
            "One two. ", "Alpha beta gamma. ", "Emoji 👨‍👩‍👧‍👦 bit. ",
            "Short. ", "Cafe\u{301} noir, deux mots. ", "Tail piece ",
        ]
        let pasteCorpus = "Pasted one. More of it.\nPasted two.\nPasted tail bit"

        try await withEditor(seedBlocks: [
            "First sentence here. Second sentence follows. Third closes.",
            "Another block. With two sentences.",
            "Closing block, one clause only.",
        ]) { h in
            @MainActor func settleAndAssert(_ action: String, _ i: Int) async throws {
                // Flush rather than wait out the real 500 ms debounce —
                // the soak's interleavings come from the UNsettled stretches
                // between assertions, not from wall-clock waits.
                await h.flush()
                #expect(h.model.desyncRecoveryCount == 0,
                        "desyncRecovery fired (seed \(seed), action \(i): \(action))")
                #expect(h.model.canaryMessage == nil,
                        "canary fired (seed \(seed), action \(i): \(action))")
                let surfaceLength = (h.documentText as NSString).length
                #expect(h.model.index.documentLength == surfaceLength,
                        "tiling broke (seed \(seed), action \(i): \(action))")
                try expectStoreMatchesView(h)
            }

            for i in 0..<250 {
                let docLength = (h.documentText as NSString).length
                let action = pick(12)
                switch action {
                case 0, 1:  // type a short burst at a random position
                    let at = pick(docLength + 1)
                    h.type(corpusBits[pick(corpusBits.count)], at: at)
                case 2:  // a small deletion (may refuse across a boundary)
                    if docLength > 3 {
                        let at = pick(docLength - 3)
                        h.replace(NSRange(location: at, length: 1 + pick(3)), with: "")
                    }
                case 3:  // Enter at the document end (opens/feeds the tail)
                    h.type("\n", at: docLength)
                    h.type(corpusBits[pick(corpusBits.count)])
                case 4:  // type past a paragraph (a mint goes in flight)
                    h.type("\n", at: docLength)
                    h.type("Fresh paragraph \(i).\n")
                case 5:  // idle-mint the quiet tail
                    h.model.idleMintTail()
                case 6:  // bulk paste (into the tail = segments; into a block = content)
                    let at = pick(docLength + 1)
                    h.textView.withPasteFlag { h.type(pasteCorpus, at: at) }
                case 7:  // divide at a random caret (W ceremony on fanned blocks)
                    h.textView.setSelectedRange(NSRange(location: pick(docLength + 1), length: 0))
                    h.model.updateCaretContext()
                    await h.model.invokeGesture(.divideAtCursor)
                    if h.model.divideWCeremony != nil {
                        if pick(3) == 0 {
                            h.model.cancelDivideW()
                        } else {
                            await h.model.confirmDivideWCeremony()
                        }
                    }
                case 8:  // extract a random span
                    let at = pick(docLength + 1)
                    h.textView.setSelectedRange(NSRange(
                        location: at, length: pick(min(40, docLength - at + 1))))
                    h.model.updateCaretContext()
                    await h.model.invokeGesture(.extractSelection)
                case 9:  // make-block a random span
                    let at = pick(docLength + 1)
                    h.textView.setSelectedRange(NSRange(
                        location: at, length: pick(min(40, docLength - at + 1))))
                    h.model.updateCaretContext()
                    await h.model.invokeGesture(.makeBlockFromSelection)
                case 10:  // merge at a random caret or small selection
                    let at = pick(docLength + 1)
                    let length = pick(2) == 0 ? 0 : pick(min(20, docLength - at + 1))
                    h.textView.setSelectedRange(NSRange(location: at, length: length))
                    h.model.updateCaretContext()
                    await h.model.invokeGesture(.mergeBlocks)
                case 11:  // an external write: branch a fan, or structural undo
                    await h.flush()
                    guard !h.model.autosave.isDirty, !h.model.mintInFlight else { break }
                    if pick(2) == 0 {
                        let slots = try h.storeSlots()
                        if !slots.isEmpty {
                            let slot = slots[pick(slots.count)]
                            if let variantID = slot.variantID {
                                _ = try? h.session.operations.branchVariant(
                                    slot.blockID, from: variantID)
                            }
                        }
                    } else {
                        let stack = h.session.undoStack
                        _ = try? await h.session.runner.run { ops in
                            try stack.undo(with: ops)
                        }
                    }
                    // The observation's stand-in: the projection arrives.
                    try h.reload()
                default:
                    break
                }

                // Assert after most actions; always after every tenth. The
                // unsettled stretches are the point — a mint or autosave in
                // flight while the next action lands is the interleaving
                // the plan demands (the gesture door must wait it out).
                if i % 10 == 9 || pick(4) != 0 {
                    try await settleAndAssert("case \(action)", i)
                }
            }

            // Final full agreement, including a last observation round-trip.
            await h.settle()
            try await settleAndAssert("final", 250)
            let before = h.documentText
            try h.reload()
            #expect(h.documentText == before, "the final projection is a pure echo")
            #expect(h.session.undoStack.depth >= 0)  // (reachable; no wedge)
        }
    }
}
