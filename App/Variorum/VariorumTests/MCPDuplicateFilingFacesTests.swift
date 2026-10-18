//
//  MCPDuplicateFilingFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-371 (VX-383 U2 — the run record `notes/plans/fixes/vx-383-duplicate-note.md`, D-C-4):
//  `duplicate_note` can FILE its copy into a book, and her faces say where it went. Activity
//  names the book (the book road's row is logged on the BOOK — PROVISIONAL P-U2-2), its
//  refused book side says so as itself (UXR1-1's two-sided rule), and the write receipt says
//  "duplicated “X” into “B”", keeping the book when the line is too long for the bar (the wing
//  move's precedent). The wing road's lines are unchanged. Pure faces — red on the tree before
//  the fix BY ASSERTION (the book kind fell to the note's phrase, the receipt ignored `detail`).
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@Suite("VX-371 — a filed duplicate, said in her faces")
struct MCPDuplicateFilingFacesTests {
    private func line(
        _ kind: String, title: String?, allowed: Bool = true, count: Int = 1
    ) -> String {
        MCPPaneCopy.activityLine(MCPActivityFace.Line(
            id: 1, clientName: "claude-code", act: "duplicate_note", targetKind: kind, targetID: "x",
            targetTitle: title, allowed: allowed, count: count, at: "2026-10-17T00:00:00.000Z"))
    }

    private func receipt(title: String, book: String?) -> MCPWriteReceipt {
        MCPWriteReceipt(
            clientName: "claude-code", act: .duplicate, targetID: "copy", targetTitle: title, detail: book,
            show: .note(noteID: "copy", blockID: nil, select: nil))
    }

    /// The book road's row names the BOOK (allowed, once and many times); the refused book side
    /// says the book as itself; the note and wing sides are unchanged.
    @Test func activityNamesTheBookAFiledCopyWentInto() {
        #expect(line("book", title: "drafts") == "claude-code duplicated a note into \u{201C}drafts\u{201D}")
        #expect(line("book", title: "drafts", count: 3)
                == "claude-code duplicated 3 notes into \u{201C}drafts\u{201D}")
        #expect(line("book", title: "drafts", allowed: false)
                == "claude-code was refused duplicating a note into \u{201C}drafts\u{201D}")
        #expect(line("book", title: nil, allowed: false) == "claude-code was refused duplicating a note into a book")
        // Unchanged (VX-311): the wing road logs the source note; its refusals name their side.
        #expect(line("note", title: "the essay") == "claude-code duplicated \u{201C}the essay\u{201D}")
        #expect(line("note", title: "the essay", allowed: false)
                == "claude-code was refused duplicating \u{201C}the essay\u{201D}")
        #expect(line("wing", title: "Home", allowed: false)
                == "claude-code was refused duplicating a note in \u{201C}Home\u{201D}")
    }

    /// The receipt says the book the copy was filed into; a copy filed nowhere says what it
    /// always said; a line past the bar's budget keeps the BOOK and drops the note's title.
    @Test func theReceiptSaysTheBookAndKeepsItWhenTheLineIsLong() {
        #expect(MCPReceiptCopy.line([receipt(title: "the essay", book: "drafts")])
                == "claude-code duplicated \u{201C}the essay\u{201D} into \u{201C}drafts\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(MCPReceiptCopy.line([receipt(title: "the essay", book: nil)])
                == "claude-code duplicated \u{201C}the essay\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes")
        let long = MCPReceiptCopy.line([receipt(
            title: "a rather long essay title about the lighthouse keeper's daughter", book: "drafts")])
        #expect(long == "claude-code duplicated a note into \u{201C}drafts\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes",
                "\(long)")
        #expect(long.count <= MCPReceiptCopy.budget)
    }
}
