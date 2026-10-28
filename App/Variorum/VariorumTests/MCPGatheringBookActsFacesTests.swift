//
//  MCPGatheringBookActsFacesTests.swift
//  VariorumTests
//
//  VX-639 — the faces (the VX-648 run, batch 2; her ruling 2026-10-28, QUESTIONS
//  #245 RB-7: a gathering takes a book's acts at edit, the rule staying hers).
//  The wire half is `MCPGatheringBookActsServerTests` (headless). Here: a
//  gathering's acts are SAID as a gathering's — the receipts, the undo labels
//  (one each, ⌥⌘Z), Activity's rename line — never as a book's; the book acts'
//  words unchanged. PROVISIONAL words (the record's bundle). Red on old by
//  construction: no gathering act existed (every act on one was refused).
//

import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

private func receipt(
    _ act: Operations.MCPWriteAct, title: String? = "gathered", detail: String? = nil
) -> MCPWriteReceipt {
    MCPWriteReceipt(clientName: "claude-code", act: act, targetID: "g1", targetTitle: title, detail: detail)
}

private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

@Suite("VX-639 — a gathering's acts are said as a gathering's")
struct MCPGatheringBookActsFacesTests {
    @Test func eachGatheringActsReceiptAndUndoSayGathering() {
        let expected: [(MCPWriteReceipt, String, String)] = [
            (receipt(.gatheringName, detail: "percy, gathered"),
             "renamed the gathering \u{201C}percy, gathered\u{201D}", "claude-code's gathering name"),
            (receipt(.gatheringArchive), "archived \u{201C}gathered\u{201D}", "claude-code's gathering archiving"),
            (receipt(.gatheringUnarchive), "unarchived \u{201C}gathered\u{201D}", "claude-code's gathering unarchiving"),
            (receipt(.gatheringDelete), "deleted the gathering \u{201C}gathered\u{201D}", "claude-code's gathering deletion"),
        ]
        for (one, words, label) in expected {
            #expect(MCPReceiptCopy.line([one]) == "claude-code \(words)" + undoes, "\(one.act)")
            #expect(one.act.undoLabel(client: "claude-code") == label)
            #expect(one.act.isUndoable)
        }
        #expect(MCPReceiptCopy.line([receipt(.gatheringArchive), receipt(.gatheringArchive, title: "other")])
                == "claude-code archived 2 gatherings" + undoes)
        // The book acts keep their words.
        #expect(MCPReceiptCopy.line([receipt(.bookName, title: "drafts", detail: "drafts")])
                == "claude-code renamed the book \u{201C}drafts\u{201D}" + undoes)
    }

    @Test func activitySaysAGatheringsRenameAsOne() {
        func line(kind: String, allowed: Bool = true) -> String {
            MCPPaneCopy.activityLine(MCPActivityFace.Line(
                id: 1, clientName: "a-client", act: "rename_book", targetKind: kind, targetID: "g1",
                targetTitle: "percy, gathered", allowed: allowed, count: 1, at: "2026-10-28T00:00:00.000Z"))
        }
        #expect(line(kind: "gathering") == "a-client renamed a gathering to \u{201C}percy, gathered\u{201D}")
        #expect(line(kind: "book") == "a-client renamed a book to \u{201C}percy, gathered\u{201D}")
        // A refused row logs the argument's noun (`book`) — the refusal reads the same either way.
        #expect(line(kind: "book", allowed: false) == "a-client was refused renaming \u{201C}percy, gathered\u{201D}")
    }

    /// The scopes the grant faces read: the four acts a gathering takes act
    /// under a gathering grant; the rule never does.
    @Test func theCatalogSaysWhereEachActActs() {
        for tool in ["rename_book", "archive_book", "unarchive_book", "delete_book", "set_starred"] {
            #expect(MCPToolFacts.scopes(of: tool)?.contains(.gathering) == true, "\(tool)")
            #expect(MCPToolFacts.rung(of: tool) == .edit, "\(tool)")
        }
        #expect(MCPToolFacts.scopes(of: "set_book_rule")?.contains(.gathering) == false)
        #expect(MCPToolFacts.scopes(of: "finish_book")?.contains(.gathering) == false)
    }
}
