//
//  SpaceEaterTests.swift
//  VariorumTests
//
//  13u2 UNIT D — item 2, "the eager space-eater", BOTH platforms.
//
//  Her words (the master plan's `### 13u` item 2, verbatim): *"it's really
//  annoying in both variorum and variorum mobile when you typed a space but
//  are sitting there thinking of a word and the program eagerly eats your
//  space"*.
//
//  THE TRACED MECHANISM. The durability mint — the 2 s idle tick
//  (`EditorViewModel.idleMintTail`, `MobileEditorViewModel.idleMintTail`) and
//  the teardown/quit finalize — plans `CrystallizationPlanner.Kind.idle`,
//  whose segments come from `SegmentationRules.bulkSegments`, which runs
//  every piece through `trimmedPiece` and so strips the TRAILING horizontal
//  whitespace of the piece under her caret. The planned region text then
//  differs from the tail by exactly that space, so `finishMint` takes the
//  `normalized != tailText` branch and issues a `programmaticReplace` over
//  her live text — and clears the text view's undo stack in the same breath,
//  so ⌘Z cannot bring the character back either.
//
//  Why the `.idle` kind is the RIGHT place for the fix and `.bulk` is not:
//  the `.idle` kind exists for exactly this reason already. It was split off
//  from `.bulk` at the author's 2026-07-12 ruling (Phase 10 review round 1,
//  MAJOR 2) so that the DURABILITY mint "never collapses a pending typed
//  gap — the trailing newline run survives ... byte-identical region, no
//  visible collapse at mint". A trailing SPACE she has just typed is the
//  same class of typed text as a trailing NEWLINE she has just typed. Bulk
//  entry (a paste, an import, a pool drop) keeps its edge trim unchanged —
//  that trim is the K8-aligned law and nothing here touches it.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Item 2 — the eager space-eater (the durability mint)")
struct SpaceEaterTests {
    // MARK: - The shared brain (both platforms consume this plan)

    @Test func theDurabilityMintKeepsTheSpaceUnderHerCaret() {
        // RED ON OLD: mints read ["the quick brown"] and the normalized
        // region drops the space, which is what makes `finishMint` rewrite
        // her live text.
        let plan = CrystallizationPlanner.plan(.idle(.paragraph), tail: "the quick brown ")
        #expect(plan?.mints == ["the quick brown "])
        #expect(plan?.remainingTail == nil)
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "the quick brown ",
                "byte-identical to the tail ⇒ the view needs no programmatic edit")
    }

    @Test func aWholeRunOfTypedSpacesSurvivesTheDurabilityMint() {
        let plan = CrystallizationPlanner.plan(.idle(.paragraph), tail: "thinking   ")
        #expect(plan?.mints == ["thinking   "])
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "thinking   ")
    }

    @Test func onlyThePieceUnderTheCaretKeepsItsTrailingSpace() {
        // The interior pieces are paragraphs she has typed PAST; they keep
        // the shipped trim (the narrow reading — QUESTIONS #112(a)).
        let plan = CrystallizationPlanner.plan(
            .idle(.paragraph), tail: "first line \nstill typing ")
        #expect(plan?.mints == ["first line", "still typing "])
    }

    @Test func aTailEndingInANewlineRunIsUNCHANGED() {
        // PRESERVED behaviour (green on both trees): the r−1 rule owns the
        // trailing-newline case and the last piece is not the tail's end.
        let plan = CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\n\n")
        #expect(plan?.mints == ["A"])
        #expect(plan?.remainingTail == "\n")
    }

    @Test func bulkEntryStillTrimsEveryEdge() {
        // PRESERVED behaviour (green on both trees): a PASTE is not her
        // caret. The K8 trim law is untouched.
        let plan = CrystallizationPlanner.plan(.bulk(.paragraph), tail: "pasted line \nand another ")
        #expect(plan?.mints == ["pasted line", "and another"])
    }

    @Test func typeTimeCrystallizationStillTrimsACompletedParagraph() {
        // PRESERVED behaviour (green on both trees): `.typing` mints a
        // paragraph she typed PAST, never the one under the caret.
        let plan = CrystallizationPlanner.plan(.typing, tail: "finished line \nnext")
        #expect(plan?.mints == ["finished line"])
    }

    // MARK: - The Mac, end to end through the real input path

    @Test func typingASpaceAndPausingKeepsItOnTheSurfaceAndInTheStore() async throws {
        try await withEditor { harness in
            // A fresh note is all tail — this is the surface her report
            // names (typing, mid-thought, nothing minted yet).
            harness.type("the quick brown ")
            #expect(harness.documentText == "the quick brown ")

            // The 2 s clock is disabled under test; fire the tick it would.
            harness.model.idleMintTail()
            await harness.flush()

            // RED ON OLD: the surface reads "the quick brown" — the space
            // was eaten in front of her, by a programmatic replace.
            #expect(harness.documentText == "the quick brown ")
            let stored = try harness.storeSlots().map(\.text)
            #expect(stored == ["the quick brown "])
        }
    }

    @Test func theSpaceSurvivesTheTeardownMintToo() async throws {
        // The other durability occasion: leaving the note / quitting.
        try await withEditor { harness in
            harness.type("still thinking ")
            await harness.model.finalizeWork()?.value
            await harness.flush()
            let stored = try harness.storeSlots().map(\.text)
            #expect(stored == ["still thinking "])
        }
    }

    @Test func aPasteIntoTheTailStillTrimsItsLines() async throws {
        // PRESERVED behaviour: the bulk road is untouched by the fix.
        try await withEditor { harness in
            harness.textView.withPasteFlag {
                harness.type("pasted line \nand another \n")
            }
            harness.model.idleMintTail()
            await harness.flush()
            let stored = try harness.storeSlots().map(\.text)
            #expect(stored == ["pasted line", "and another"])
        }
    }
}
