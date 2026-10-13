//
//  MCPEditParityFacesTests.swift
//  VariorumTests
//
//  VX-184 U4 — VX-195, EDIT PARITY INSIDE A NOTE, IN THE APP'S VOICE (P-13n-1):
//  the twelve new acts' receipts (each one undo — "⌥⌘Z undoes"), their undo
//  labels, and Activity's words for every new tool, allowed and refused — a
//  block's LAST take deleted said as the BLOCK going (R-VX184-1). W-UX-13's
//  every-tool walk (`MCPWingFacesTests`) covers the no-raw-id rule for them by
//  construction. PROVISIONAL words (P-U4-WORDS), her copy pass.
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

private func receipt(
    _ act: Operations.MCPWriteAct, title: String? = "ch 1", detail: String? = nil
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: "claude-code", act: act, targetID: "n1", targetTitle: title, detail: detail)
}

private func line(_ tool: String, allowed: Bool, count: Int = 1, kind: String = "note") -> String {
    MCPPaneCopy.activityLine(MCPActivityFace.Line(
        id: 1, clientName: "a-client", act: tool, targetKind: kind, targetID: "x",
        targetTitle: "a letter", allowed: allowed, count: count, at: "2026-10-13T00:00:00.000Z"))
}

private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

@Suite("VX-184 U4 — edit parity inside a note: receipts, undo labels and Activity words")
struct MCPEditParityFacesTests {
    /// Every act says what landed, and every one is one undo for her.
    @Test func eachActsReceiptSaysWhatLandedAndThatItUndoes() {
        let expected: [(MCPWriteReceipt, String)] = [
            (receipt(.commentEdit), "edited a comment"),
            (receipt(.commentRestore), "restored a comment"),
            (receipt(.takeDelete), "deleted a take"),
            (receipt(.delete, detail: "its last take"), "deleted a block (its last take)"),
            (receipt(.delete), "deleted a block"),
            (receipt(.takeArchive), "archived a take"),
            (receipt(.takeUnarchive), "unarchived a take"),
            (receipt(.takeLabel, detail: "english"), "labeled a take \u{201C}english\u{201D}"),
            (receipt(.takeLabel), "cleared a take's label"),
            (receipt(.takeLock), "locked a take"),
            (receipt(.takeUnlock), "unlocked a take"),
            (receipt(.commitRestore), "restored a commit"),
            (receipt(.commitRename, detail: "the first draft"), "renamed a commit \u{201C}the first draft\u{201D}"),
            (receipt(.commitRename), "cleared a commit's name"),
            (receipt(.noteTitle, detail: "Chapter one"), "renamed the note \u{201C}Chapter one\u{201D}"),
            (receipt(.noteTitle), "cleared the note's title"),
            (receipt(.lensDelete, detail: "the bold cut"), "deleted the lens \u{201C}the bold cut\u{201D}"),
        ]
        for (one, words) in expected {
            #expect(MCPReceiptCopy.line([one]) == "claude-code \(words)" + undoes, "\(one.act)")
        }
        #expect(MCPReceiptCopy.line([receipt(.takeDelete), receipt(.takeDelete)])
                == "claude-code deleted 2 takes" + undoes, "a run counts its acts")
    }

    @Test func eachActIsOneClientNamedUndo() {
        let labels: [(Operations.MCPWriteAct, String)] = [
            (.commentEdit, "claude-code's comment edit"), (.commentRestore, "claude-code's comment restore"),
            (.takeDelete, "claude-code's take deletion"), (.takeArchive, "claude-code's take archiving"),
            (.takeUnarchive, "claude-code's take unarchiving"), (.takeLabel, "claude-code's take label"),
            (.takeLock, "claude-code's take lock"), (.takeUnlock, "claude-code's take unlock"),
            (.commitRestore, "claude-code's commit restore"), (.commitRename, "claude-code's commit name"),
            (.noteTitle, "claude-code's note title"), (.lensDelete, "claude-code's lens deletion"),
            // R-VX184-1: the last take ⇒ the block — delete_block's own entry.
            (.delete, "claude-code's delete"),
        ]
        for (act, label) in labels {
            #expect(act.undoLabel(client: "claude-code") == label)
            #expect(act.isUndoable, "\(act) is one undo for her")
        }
    }

    /// Activity says each new act in words (W-UX-13), allowed and refused.
    @Test func activitySaysEachNewActInWords() {
        let allowed: [(String, String)] = [
            ("edit_comment", "edited a comment in"), ("restore_comment", "restored a comment in"),
            ("delete_take", "deleted a take in"), ("archive_take", "archived a take in"),
            ("unarchive_take", "unarchived a take in"), ("set_take_label", "labeled a take in"),
            ("lock_take", "locked a take in"), ("unlock_take", "unlocked a take in"),
            ("restore_commit", "restored a commit in"), ("rename_commit", "renamed a commit in"),
            ("rename_note", "renamed a note to"), ("delete_lens", "deleted a lens of"),
        ]
        for (tool, words) in allowed {
            #expect(line(tool, allowed: true) == "a-client \(words) \u{201C}a letter\u{201D}", "\(tool)")
        }
        let refused: [(String, String)] = [
            ("edit_comment", "editing a comment in"), ("restore_comment", "restoring a comment in"),
            ("delete_take", "deleting a take in"), ("archive_take", "archiving a take in"),
            ("unarchive_take", "unarchiving a take in"), ("set_take_label", "labeling a take in"),
            ("lock_take", "locking a take in"), ("unlock_take", "unlocking a take in"),
            ("restore_commit", "restoring a commit in"), ("rename_commit", "renaming a commit in"),
            ("delete_lens", "deleting a lens of"),
        ]
        for (tool, words) in refused {
            #expect(line(tool, allowed: false) == "a-client was refused \(words) \u{201C}a letter\u{201D}", "\(tool)")
        }
        #expect(line("rename_note", allowed: false) == "a-client was refused renaming \u{201C}a letter\u{201D}")
        // R-VX184-1: a block's last take deleted is logged on the BLOCK — said so.
        #expect(line("delete_take", allowed: true, kind: "block")
                == "a-client deleted a block in \u{201C}a letter\u{201D} (its last take)")
        #expect(line("delete_take", allowed: true, count: 3) == "a-client deleted 3 takes in \u{201C}a letter\u{201D}")
    }

    /// Every new tool sits on EDIT (R-VX184-1 — "as capable as you at the
    /// keyboard"); `delete_comment` stays suggest's, its edit clause inside.
    @Test func eachNewToolSitsOnTheEditRung() {
        for tool in ["edit_comment", "restore_comment", "delete_take", "archive_take", "unarchive_take",
                     "set_take_label", "lock_take", "unlock_take", "restore_commit", "rename_commit",
                     "rename_note", "delete_lens"] {
            #expect(MCPToolFacts.rung(of: tool) == .edit, "\(tool)")
        }
        #expect(MCPToolFacts.rung(of: "delete_comment") == .suggest)
        // R-VX184-2: Private, Seal and Own stay hers alone — no tool mints them.
        for tool in MCPToolFacts.toolNames {
            for hers in ["private", "seal", "own"] {
                #expect(!tool.contains(hers), "\(tool) — \(hers) is hers alone")
            }
        }
    }
}
