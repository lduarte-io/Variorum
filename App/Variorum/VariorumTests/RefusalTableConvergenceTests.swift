//
//  RefusalTableConvergenceTests.swift
//  VariorumTests
//
//  18m U3 — **one refusal table, Mac side: the CONVERGENCE pins** (red on the
//  hoist-only tree, green once the collapse lands — the unit's red-first
//  evidence for every sentence whose WORDS its ruling changed).
//
//  Before 18m U3 Write's editor kept a private second switch
//  (`EditorViewModel.operationMessage`) beside `OpsRefusalCopy`, and the two
//  disagreed — on the sealed-note sentence above all (the conductor map found
//  four spellings; the unit's trace found the family). The ruling (the 18m
//  plan's U3 CLASSIFICATION RULING): the private switch is DELETED onto the
//  table; the seal is ONE sentence shape — "This note is sealed — unseal it
//  first.", a door that knows its act filling it in ("…unseal it to edit.") —
//  with each platform's door words its own; `lastActiveVariant` speaks one
//  sentence naming BOTH real roads (FORK L-c), because each old sentence was
//  wrong at the other's door. All PROVISIONAL (copy is hers — QUESTIONS #159).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("18m U3 — Write speaks the one refusal table; the seal is one sentence")
struct RefusalTableConvergenceTests {
    static let sealedFirst = "This note is sealed — unseal it first."
    /// FORK L-c: both roads, because the one guard behind this error serves
    /// ⌘⇧A's archive, the delete door, and E5's move-out alike.
    static let onlyTake = "This block has only one take — a block keeps at least one take, "
        + "so delete the block instead, or divide it (⌘⇧D) to split it into blocks."

    private struct NotAnOperationError: Error {}

    @Test func theTablesSealSentenceIsTheOneSentence() {
        #expect(OpsRefusalCopy.message(for: OperationError.lockedPost(id: "p")) == Self.sealedFirst)
    }

    /// The deletion itself, as a fact: whatever Write's error voice is handed,
    /// it says what the table says — every case the two switches used to
    /// disagree on, the ones only Write had words for, and both fallbacks.
    @Test func writesErrorVoiceSpeaksTheTable() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let errors: [Error] = [
                OperationError.lockedPost(id: "p"),
                OperationError.lockedVariant(id: "v"),
                OperationError.lastActiveVariant(id: "v"),
                OperationError.variantIsChosen(id: "v"),
                OperationError.archivedVariant(id: "v"),
                OperationError.bufferChangedSinceGesture(variantID: "v"),
                OperationError.blockCarriesUnshownText(id: "b"),
                OperationError.fannedBlock(id: "b"),
                OperationError.divideSideWouldBeEmpty(blockID: "b"),
                OperationError.mergedBlockWouldHaveNoTake(first: "b", second: "c"),
                OperationError.takePairedTwice(variantID: "v"),
                OperationError.blockNotFound(id: "b"),
                OperationError.invalidCut(variantID: "v", cut: 3),
                OperationError.containerNotFound(id: "c"),
                NotAnOperationError(),
            ]
            for error in errors {
                h.model.showOperationError(error)
                #expect(h.model.statusMessage == OpsRefusalCopy.message(for: error),
                        "Write and the table disagree on \(error)")
            }
        }
    }

    /// The words the table GAINED — the cases only Write's private switch had
    /// words for (the table dumped "Refused: …" at every other door), plus the
    /// two sentences both platforms already spoke byte-identically.
    @Test func theTableSpeaksTheWordsOnlyOneSwitchHad() {
        let expected: [(OperationError, String)] = [
            (.bufferChangedSinceGesture(variantID: "v"),
             "The text changed while that gesture was landing — nothing was altered; "
                + "try it again on the current text."),
            (.divideSideWouldBeEmpty(blockID: "b"),
             "Every checked take is parked at the same end — one of the two new blocks "
                + "would have no takes. Split at least one take, or park one at the other end."),
            (.mergedBlockWouldHaveNoTake(first: "b", second: "c"),
             "The merged block needs at least one take — pair takes with ＋, or check "
                + "“carry” on one."),
            (.takePairedTwice(variantID: "v"),
             "A take can sit in only one pairing (and a paired take can't also carry) — "
                + "remove the duplicate first."),
            (.invalidCut(variantID: "v", cut: 3),
             "No legal cut spot for that here — cuts land between words, at sentence "
                + "ends, and at line breaks."),
            (.invalidCommentText, "A comment needs some text."),
            (.lastActiveVariant(id: "v"), Self.onlyTake),
        ]
        for (error, words) in expected {
            #expect(OpsRefusalCopy.message(for: error) == words, "\(error)")
        }
        // FORK L-c's sentence keeps each old sentence's FACT (the pins that
        // guard them read fragments: E5's "only one take", I10's "keeps at
        // least one take").
        #expect(Self.onlyTake.contains("only one take"))
        #expect(Self.onlyTake.contains("keeps at least one take"))
    }

    /// Spelling 1 of the four: the typing gate names the Mac's own door
    /// ("Unseal"), with the act it refused. The gate is a BELT: a sealed
    /// note's view is not editable (`adoptHeader`), so AppKit's typing never
    /// asks it — it answers the roads that consult the model's gate directly
    /// (the one input path's own door, a find-driven edit). So the pin asks
    /// the gate itself.
    @Test func writesTypingGateSpeaksTheStemWithItsAct() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            let allowed = h.model.shouldChangeText(
                in: NSRange(location: 2, length: 0), replacement: "x")
            #expect(!allowed, "the seal refuses the keystroke")
            #expect(h.model.statusMessage == "This note is sealed — unseal it to edit.")
            #expect(h.documentText == "alpha")
        }
    }

    /// The gate's two gesture-worded siblings (R1+ — the same "unlock" verb
    /// the Mac has no note door for).
    @Test func theGatesTwoSiblingsSpeakTheStemToo() async throws {
        #expect(RefusalCopy.message(for: .sealed) == "This note is sealed — unseal it to restructure.")
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let pool = try h.session.operations.createPool(title: "P")
            let scrap = try h.session.operations.newBlock(in: pool.id, text: "a loose idea")
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            let consumed = h.model.poolDrop(blockID: scrap.block.id, atOffset: 0, includeFan: false)
            #expect(consumed)
            #expect(h.model.statusMessage == "This note is sealed — unseal it to add to it.")
        }
    }

    /// FORK L's wrong-door case, both doors: ⌘⇧A (archive) on a block's only
    /// take, and Write's E5 move-out on it — which used to be told "delete the
    /// block instead" for a gesture that wanted to move text out.
    @Test func theOnlyTakeRefusalNamesBothRoadsAtBothDoors() async throws {
        try await withEditor(seedBlocks: ["only take"]) { h in
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            h.model.updateCaretContext()
            h.model.archiveCaretTake()
            for _ in 0..<2000 {
                if h.model.statusMessage != nil { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(h.model.statusMessage == Self.onlyTake, "⌘⇧A")
        }
        try await withEditor(seedBlocks: ["only take"]) { h in
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            h.model.updateCaretContext()
            await h.model.structural.moveCaretTakeIntoBlockBelow()
            #expect(h.model.statusMessage == Self.onlyTake, "E5, Write side")
            let slots = try h.storeSlots()
            #expect(slots.count == 1, "nothing moved")
        }
    }
}
