//
//  MCPLibraryParityFacesTests.swift
//  VariorumTests
//
//  VX-184 U5 — VX-196, EDIT PARITY ACROSS THE LIBRARY, IN THE APP'S VOICE
//  (P-13n-1): the fourteen new tools' receipts (each one undo — "⌥⌘Z undoes"),
//  their undo labels (an owned book's removal reads "release", her door's own
//  word), and Activity's words for every new tool, allowed and refused — the
//  two-sided acts saying the side that refused (UXR1-1). W-UX-13's every-tool
//  walk (`MCPWingFacesTests`) covers the no-raw-id rule for them by
//  construction, and U4's R-VX184-2 pin (no tool NAMED for Private, Seal or Own)
//  walks every tool, these included. PROVISIONAL words (P-U5-WORDS).
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

private func receipt(
    _ act: Operations.MCPWriteAct, title: String? = "drafts", detail: String? = nil
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: "claude-code", act: act, targetID: "b1", targetTitle: title, detail: detail)
}

private func line(_ tool: String, allowed: Bool, count: Int = 1, kind: String = "book") -> String {
    MCPPaneCopy.activityLine(MCPActivityFace.Line(
        id: 1, clientName: "a-client", act: tool, targetKind: kind, targetID: "x",
        targetTitle: "a letter", allowed: allowed, count: count, at: "2026-10-13T00:00:00.000Z"))
}

private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

@Suite("VX-184 U5 — edit parity across the library: receipts, undo labels and Activity words")
struct MCPLibraryParityFacesTests {
    /// Every act says what landed, and every one is one undo for her.
    @Test func eachActsReceiptSaysWhatLandedAndThatItUndoes() {
        let expected: [(MCPWriteReceipt, String)] = [
            (receipt(.bookName, title: "Drafts, done", detail: "Drafts, done"), "renamed the book \u{201C}Drafts, done\u{201D}"),
            (receipt(.bookFinish), "finished \u{201C}drafts\u{201D}"),
            (receipt(.bookReopen), "reopened \u{201C}drafts\u{201D}"),
            (receipt(.bookArchive), "archived \u{201C}drafts\u{201D}"),
            (receipt(.bookUnarchive), "unarchived \u{201C}drafts\u{201D}"),
            (receipt(.bookDelete), "deleted the book \u{201C}drafts\u{201D}"),
            (receipt(.bookDelete, title: "ab", detail: "its notes are in the Pool"),
             "deleted the book \u{201C}ab\u{201D} \u{2014} its notes are in the Pool"),
            (receipt(.bookRemove, title: "ch 1", detail: "drafts"), "took \u{201C}ch 1\u{201D} out of \u{201C}drafts\u{201D}"),
            (receipt(.bookRelease, title: "ch 1", detail: "the novel"),
             "released \u{201C}ch 1\u{201D} from \u{201C}the novel\u{201D}"),
            (receipt(.bookOrder), "moved a note in \u{201C}drafts\u{201D}"),
            (receipt(.chapterName, detail: "the coda"), "renamed a chapter \u{201C}the coda\u{201D}"),
            (receipt(.chapterDelete, detail: "one"), "deleted the chapter \u{201C}one\u{201D}"),
            (receipt(.chapterMove, detail: "one"), "moved the chapter \u{201C}one\u{201D}"),
            (receipt(.noteDelete, title: "ch 1"), "deleted \u{201C}ch 1\u{201D} (it's in the Trash)"),
            (receipt(.noteArchive, title: "ch 1"), "archived \u{201C}ch 1\u{201D}"),
            (receipt(.noteUnarchive, title: "ch 1"), "unarchived \u{201C}ch 1\u{201D}"),
        ]
        for (one, words) in expected {
            #expect(MCPReceiptCopy.line([one]) == "claude-code \(words)" + undoes, "\(one.act)")
        }
        // Stage-window find (red first, justified edit): a longer book name runs
        // the owned delete past the bar's budget — the line keeps where the
        // notes went and drops the name, never "made a change".
        #expect(MCPReceiptCopy.line([receipt(.bookDelete, title: "drafts", detail: "its notes are in the Pool")])
                == "claude-code deleted a book \u{2014} its notes are in the Pool" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.bookOrder), receipt(.bookOrder)])
                == "claude-code moved 2 notes in \u{201C}drafts\u{201D}" + undoes, "a run counts its acts")
    }

    @Test func eachActIsOneClientNamedUndo() {
        let labels: [(Operations.MCPWriteAct, String)] = [
            (.bookName, "claude-code's book name"), (.bookFinish, "claude-code's finish"),
            (.bookReopen, "claude-code's reopen"), (.bookArchive, "claude-code's book archiving"),
            (.bookUnarchive, "claude-code's book unarchiving"), (.bookDelete, "claude-code's book deletion"),
            (.bookRemove, "claude-code's removal from a book"), (.bookRelease, "claude-code's release from a book"),
            (.bookOrder, "claude-code's move in a book"), (.chapterName, "claude-code's chapter name"),
            (.chapterDelete, "claude-code's chapter deletion"), (.chapterMove, "claude-code's chapter move"),
            (.noteDelete, "claude-code's note deletion"), (.noteArchive, "claude-code's note archiving"),
            (.noteUnarchive, "claude-code's note unarchiving"),
        ]
        for (act, label) in labels {
            #expect(act.undoLabel(client: "claude-code") == label)
            #expect(act.isUndoable, "\(act) is one undo for her")
        }
    }

    /// Activity says each new act in words (W-UX-13), allowed and refused.
    @Test func activitySaysEachNewActInWords() {
        let allowed: [(String, String, String)] = [
            ("rename_book", "book", "renamed a book to"), ("finish_book", "book", "finished"),
            ("reopen_book", "book", "reopened"), ("archive_book", "book", "archived"),
            ("unarchive_book", "book", "unarchived"), ("delete_book", "book", "deleted"),
            ("move_note_in_book", "book", "moved a note in"),
            ("rename_chapter", "book", "renamed a chapter of"), ("delete_chapter", "book", "deleted a chapter of"),
            ("move_chapter", "book", "moved a chapter of"),
            ("delete_note", "note", "deleted"), ("archive_note", "note", "archived"),
            ("unarchive_note", "note", "unarchived"),
        ]
        for (tool, kind, words) in allowed {
            #expect(line(tool, allowed: true, kind: kind) == "a-client \(words) \u{201C}a letter\u{201D}", "\(tool)")
        }
        #expect(line("remove_note_from_book", allowed: true, kind: "note")
                == "a-client took \u{201C}a letter\u{201D} out of a book")
        let refused: [(String, String, String)] = [
            ("rename_book", "book", "renaming"), ("finish_book", "book", "finishing"),
            ("reopen_book", "book", "reopening"), ("archive_book", "book", "archiving"),
            ("unarchive_book", "book", "unarchiving"), ("delete_book", "book", "deleting"),
            ("rename_chapter", "book", "renaming a chapter of"), ("delete_chapter", "book", "deleting a chapter of"),
            ("move_chapter", "book", "moving a chapter of"),
            ("delete_note", "note", "deleting"), ("archive_note", "note", "archiving"),
            ("unarchive_note", "note", "unarchiving"),
        ]
        for (tool, kind, words) in refused {
            #expect(line(tool, allowed: false, kind: kind) == "a-client was refused \(words) \u{201C}a letter\u{201D}",
                    "\(tool)")
        }
        // The two-sided acts say the side that refused (UXR1-1).
        #expect(line("remove_note_from_book", allowed: false, kind: "book")
                == "a-client was refused taking a note out of \u{201C}a letter\u{201D}")
        #expect(line("remove_note_from_book", allowed: false, kind: "note")
                == "a-client was refused taking \u{201C}a letter\u{201D} out of a book")
        #expect(line("move_note_in_book", allowed: false, kind: "book")
                == "a-client was refused moving a note in \u{201C}a letter\u{201D}")
        #expect(line("move_note_in_book", allowed: false, kind: "note")
                == "a-client was refused moving \u{201C}a letter\u{201D} in a book")
        #expect(line("move_note_in_book", allowed: true, count: 3) == "a-client moved 3 notes in \u{201C}a letter\u{201D}")
    }

    /// Every new tool sits on EDIT (R-VX184-1 — "as capable as you at the
    /// keyboard"); the book and chapter tools act under a book or wing grant
    /// only (a note grant never names a book), the note tools under any.
    @Test func eachNewToolSitsOnTheEditRungAtItsScopes() {
        let bookTools = ["rename_book", "finish_book", "reopen_book", "archive_book", "unarchive_book", "delete_book",
                         "remove_note_from_book", "move_note_in_book", "rename_chapter", "delete_chapter", "move_chapter"]
        for tool in bookTools {
            #expect(MCPToolFacts.rung(of: tool) == .edit, "\(tool)")
            #expect(MCPToolFacts.scopes(of: tool) == [.book, .wing], "\(tool)")
        }
        for tool in ["delete_note", "archive_note", "unarchive_note"] {
            #expect(MCPToolFacts.rung(of: tool) == .edit, "\(tool)")
            #expect(MCPToolFacts.scopes(of: tool) == [.note, .book, .wing], "\(tool)")
        }
        // R-VX184-2: Private, Seal and Own stay hers alone — and so do her
        // owned book's second choices (book AND notes): no tool mints them.
        for tool in MCPToolFacts.toolNames {
            for hers in ["private", "seal", "own", "with_notes"] {
                #expect(!tool.contains(hers), "\(tool) — \(hers) is hers alone")
            }
        }
    }
}
