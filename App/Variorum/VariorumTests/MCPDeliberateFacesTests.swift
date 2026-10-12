//
//  MCPDeliberateFacesTests.swift
//  VariorumTests
//
//  VX-168 U2 — THE DELIBERATE ACTS' FACES: VX-169's `save_commit` and VX-174's
//  `choose_take` / `adopt_lens` (R-MERGE-1), said in the app's voice (P-13n-1).
//  The receipt line names each act, and "⌥⌘Z undoes" is said ONLY over a run
//  holding an act ⌥⌘Z walks back: a client's commit is append-only, as her
//  own (no undo entry — the run record's UNIT 2 RECORD), so a run of commits
//  alone makes no undo claim. Activity speaks each act in words (W-UX-13 —
//  never a tool id). PROVISIONAL words, her copy pass.
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

private func receipt(
    _ act: Operations.MCPWriteAct, detail: String? = nil, client: String = "claude-code"
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: client, act: act, targetID: "n1", targetTitle: "ch 1", detail: detail)
}

private func line(_ tool: String, allowed: Bool, count: Int = 1, title: String? = "a letter") -> String {
    MCPPaneCopy.activityLine(MCPActivityFace.Line(
        id: 1, clientName: "a-client", act: tool, targetKind: "note", targetID: "x",
        targetTitle: title, allowed: allowed, count: count, at: "2026-10-12T00:00:00.000Z"))
}

@Suite("VX-168 U2 — the deliberate acts' receipts and Activity words")
struct MCPDeliberateFacesTests {
    // MARK: - The receipt line

    @Test func aCommitSaysWhatLandedAndMakesNoUndoClaim() {
        #expect(MCPReceiptCopy.line([receipt(.commit)]) == "claude-code committed a take",
                "append-only, as her own commit: ⌥⌘Z would undo something else")
        #expect(MCPReceiptCopy.line([receipt(.commit), receipt(.commit)]) == "claude-code made 2 commits")
        #expect(!MCPReceiptCopy.line([receipt(.commit), receipt(.commit)]).contains("\u{2325}\u{2318}Z"))
    }

    @Test func thePointerActsAreOneUndoEachAndSayItInHerDoorsWords() {
        #expect(MCPReceiptCopy.line([receipt(.choice)]) == "claude-code chose a take \u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(MCPReceiptCopy.line([receipt(.choice), receipt(.choice)])
                == "claude-code chose 2 takes \u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(MCPReceiptCopy.line([receipt(.lensAdoption, detail: "the bold cut")])
                == "claude-code made the lens \u{201C}the bold cut\u{201D} the note \u{00B7} \u{2325}\u{2318}Z undoes",
                "her “Make this the note”, said back")
    }

    /// A run that holds an undoable act keeps the claim — ⌥⌘Z walks the
    /// run's acts back, newest first, and a commit among them stays (as
    /// `edit_take`'s own brackets stay — P-13nb-U3-2).
    @Test func aMixedRunKeepsTheUndoClaimForWhatItCanUndo() {
        #expect(MCPReceiptCopy.line([receipt(.edit), receipt(.commit)])
                == "claude-code edited a take and committed a take \u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(Operations.MCPWriteAct.allCases.filter { !$0.isUndoable } == [.commit],
                "the commit is the one act without an undo entry")
    }

    // MARK: - Activity (W-UX-13: in words, never a tool id)

    @Test func activitySaysEachDeliberateActInWords() {
        #expect(line("save_commit", allowed: true) == "a-client committed a take in \u{201C}a letter\u{201D}")
        #expect(line("save_commit", allowed: true, count: 3) == "a-client made 3 commits in \u{201C}a letter\u{201D}")
        #expect(line("save_commit", allowed: false) == "a-client was refused committing a take in \u{201C}a letter\u{201D}")
        #expect(line("choose_take", allowed: true) == "a-client chose a take in \u{201C}a letter\u{201D}")
        #expect(line("choose_take", allowed: true, count: 2) == "a-client chose 2 takes in \u{201C}a letter\u{201D}")
        #expect(line("choose_take", allowed: false) == "a-client was refused choosing a take in \u{201C}a letter\u{201D}")
        #expect(line("adopt_lens", allowed: true) == "a-client made a lens of \u{201C}a letter\u{201D} the note")
        #expect(line("adopt_lens", allowed: true, count: 2)
                == "a-client made a lens of \u{201C}a letter\u{201D} the note (2 times)")
        #expect(line("adopt_lens", allowed: false)
                == "a-client was refused making a lens of \u{201C}a letter\u{201D} the note")
        // An unresolved title falls back on the logged kind's noun.
        #expect(line("choose_take", allowed: false, title: nil) == "a-client was refused choosing a take in a note")
    }
}
