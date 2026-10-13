//
//  MCPDoorErgonomicsFacesTests.swift
//  VariorumTests
//
//  VX-184 U3 — THE DOOR'S NEW ACTS, IN THE APP'S VOICE (P-13n-1): VX-173's batch
//  doors (a batch is ONE act — its receipt counts its items, a run of batches
//  sums them), VX-188's own-comment delete, VX-190's un-tag and VX-187's
//  version link. Every one is undoable (one client-named entry each), so each
//  receipt says "⌥⌘Z undoes"; Activity says each act in words, never a tool id
//  (W-UX-13 — `MCPWingFacesTests` walks the whole catalog for the id rule).
//  PROVISIONAL words (P-U3-WORDS), her copy pass.
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

private func receipt(
    _ act: Operations.MCPWriteAct, count: Int = 1, title: String? = "ch 1", detail: String? = nil
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: "claude-code", act: act, targetID: "n1", targetTitle: title, detail: detail, count: count)
}

private func line(_ tool: String, allowed: Bool, count: Int = 1) -> String {
    MCPPaneCopy.activityLine(MCPActivityFace.Line(
        id: 1, clientName: "a-client", act: tool, targetKind: "note", targetID: "x",
        targetTitle: "a letter", allowed: allowed, count: count, at: "2026-10-13T00:00:00.000Z"))
}

private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

@Suite("VX-184 U3 — the door's new acts: receipts, undo labels and Activity words")
struct MCPDoorErgonomicsFacesTests {
    @Test func aBatchIsOneActWhoseReceiptCountsItsItems() {
        #expect(MCPReceiptCopy.line([receipt(.takes, count: 6)]) == "claude-code added 6 takes" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.takes, count: 3), receipt(.takes, count: 2)])
                == "claude-code added 5 takes" + undoes, "a run of batches sums its items")
        #expect(MCPReceiptCopy.line([receipt(.takes, count: 1)]) == "claude-code added a take" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.comments, count: 3)]) == "claude-code left 3 comments" + undoes)
        #expect(Operations.MCPWriteAct.takes.undoLabel(client: "claude-code") == "claude-code's takes")
        #expect(Operations.MCPWriteAct.comments.undoLabel(client: "claude-code") == "claude-code's comments")
    }

    @Test func theDeleteTheUntagAndTheLinkSayWhatLanded() {
        #expect(MCPReceiptCopy.line([receipt(.commentDelete)]) == "claude-code deleted a comment" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.untag, detail: "percy/pt-en")])
                == "claude-code removed the tag #percy/pt-en" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.versionLink, title: "one", detail: "two")])
                == "claude-code linked \u{201C}one\u{201D} and \u{201C}two\u{201D} as versions" + undoes)
        #expect(Operations.MCPWriteAct.commentDelete.undoLabel(client: "claude-code") == "claude-code's comment deletion")
        #expect(Operations.MCPWriteAct.untag.undoLabel(client: "claude-code") == "claude-code's tag removal")
        #expect(Operations.MCPWriteAct.versionLink.undoLabel(client: "claude-code") == "claude-code's version link")
        for act in [Operations.MCPWriteAct.takes, .comments, .commentDelete, .untag, .versionLink] {
            #expect(act.isUndoable, "\(act) is one undo for her")
        }
    }

    @Test func activitySaysEachNewActInWords() {
        #expect(line("add_takes", allowed: true) == "a-client added takes to \u{201C}a letter\u{201D}")
        #expect(line("add_takes", allowed: false) == "a-client was refused adding takes to \u{201C}a letter\u{201D}")
        #expect(line("add_comments", allowed: true, count: 2)
                == "a-client left comments in \u{201C}a letter\u{201D} (2 times)")
        #expect(line("add_comments", allowed: false) == "a-client was refused leaving comments in \u{201C}a letter\u{201D}")
        #expect(line("delete_comment", allowed: true) == "a-client deleted a comment in \u{201C}a letter\u{201D}")
        #expect(line("delete_comment", allowed: true, count: 3) == "a-client deleted 3 comments in \u{201C}a letter\u{201D}")
        #expect(line("delete_comment", allowed: false)
                == "a-client was refused deleting a comment in \u{201C}a letter\u{201D}")
        #expect(line("remove_tag", allowed: true) == "a-client removed a tag from \u{201C}a letter\u{201D}")
        #expect(line("remove_tag", allowed: false) == "a-client was refused removing a tag from \u{201C}a letter\u{201D}")
        #expect(line("link_versions", allowed: true)
                == "a-client linked \u{201C}a letter\u{201D} and another note as versions")
        #expect(line("link_versions", allowed: false)
                == "a-client was refused linking \u{201C}a letter\u{201D} and another note as versions")
    }

    /// Each new tool is declared where the run's rulings put it.
    @Test func eachNewToolSitsOnItsRung() {
        #expect(MCPToolFacts.rung(of: "add_takes") == .suggest)
        #expect(MCPToolFacts.rung(of: "add_comments") == .suggest)
        #expect(MCPToolFacts.rung(of: "delete_comment") == .suggest, "R-VX188-1: a client's own, at suggest")
        #expect(MCPToolFacts.rung(of: "remove_tag") == .edit)
        #expect(MCPToolFacts.rung(of: "link_versions") == .writeNew, "R-VX187-1: write new on both notes")
    }
}
