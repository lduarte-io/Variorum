//
//  MCPStarFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-596 — `set_starred`, HER STAR ON THE WIRE, IN THE APP'S VOICE (P-13n-1).
//  Her ruling (2026-10-27): "let's add the star over the wire, it might as well
//  be included" — a tool at the EDIT rung, one ⌥⌘Z entry naming the client like
//  every write. The receipts (her door's verbs, `StarCopy`), the undo labels,
//  Activity's words for the one tool both ways (the coarse log keeps no
//  direction), and the cap's refusal through the wire's ONE chain in HER words.
//  PROVISIONAL words (the VX-620 record's bundle, her copy pass). Red on old by
//  construction: no such act, tool or words.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMCP
@testable import Variorum

@Suite("VX-596 — set_starred: receipts, undo labels, Activity words, the cap in her words")
struct MCPStarFacesTests {
    private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

    private func receipt(_ act: Operations.MCPWriteAct, _ title: String = "a starry note") -> MCPWriteReceipt {
        MCPWriteReceipt(clientName: "claude-code", act: act, targetID: "n1", targetTitle: title)
    }

    private func line(allowed: Bool, kind: String, count: Int = 1) -> String {
        MCPPaneCopy.activityLine(MCPActivityFace.Line(
            id: 1, clientName: "a-client", act: "set_starred", targetKind: kind, targetID: "x",
            targetTitle: "a letter", allowed: allowed, count: count, at: "2026-10-27T00:00:00.000Z"))
    }

    @Test func eachActsReceiptSaysWhichWayAndThatItUndoes() {
        #expect(MCPReceiptCopy.line([receipt(.star)]) == "claude-code starred \u{201C}a starry note\u{201D}" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.unstar)])
                == "claude-code unstarred \u{201C}a starry note\u{201D}" + undoes)
        // A run is ONE target (the door's key): a star, its un-star, a star again.
        #expect(MCPReceiptCopy.line([receipt(.star, "orbit"), receipt(.unstar, "orbit"), receipt(.star, "orbit")])
                == "claude-code starred \u{201C}orbit\u{201D} 2 times and unstarred \u{201C}orbit\u{201D}" + undoes)
    }

    @Test func eachActIsOneClientNamedUndo() {
        #expect(Operations.MCPWriteAct.star.undoLabel(client: "claude-code") == "claude-code's star")
        #expect(Operations.MCPWriteAct.unstar.undoLabel(client: "claude-code") == "claude-code's unstar")
        #expect(Operations.MCPWriteAct.star.isUndoable && Operations.MCPWriteAct.unstar.isUndoable)
    }

    /// W-UX-13: Activity says the act in words, never `set_starred` — one tool
    /// both ways, and the log keeps no direction, so the line says neither
    /// (the receipt says which).
    @Test func activitySaysTheActInWordsAllowedAndRefused() {
        for kind in ["note", "book"] {
            #expect(line(allowed: true, kind: kind) == "a-client changed the star on \u{201C}a letter\u{201D}")
            #expect(line(allowed: false, kind: kind)
                    == "a-client was refused changing the star on \u{201C}a letter\u{201D}")
        }
        #expect(line(allowed: true, kind: "note", count: 3)
                == "a-client changed the star on \u{201C}a letter\u{201D} (3 times)")
        #expect(!line(allowed: true, kind: "note").contains("set_starred")
                && !line(allowed: true, kind: "note").contains("set starred"))
    }

    /// The tool sits on EDIT at every scope (a note under any grant that reaches
    /// it, a book under a book or wing grant) — and is no hers-alone act.
    @Test func theToolSitsOnEditAtEveryScope() {
        #expect(MCPToolFacts.rung(of: "set_starred") == .edit)
        #expect(MCPToolFacts.scopes(of: "set_starred") == [.note, .book, .gathering, .wing])
    }

    /// The cap refuses through the wire's ONE chain (`MCPWireRefusalCopy.spoken`
    /// with the Mac door's hook) in HER words — the road the refusal names —
    /// never a raw case (`MCPWireRefusalSweepTests` walks every case; this is
    /// the star's own leg, said whole).
    @Test func theCapRefusesInHerWordsOnTheWire() {
        let spoken = MCPWireRefusalCopy.spoken(OperationError.starLimitReached(limit: Operations.starLimit)) {
            OpsRefusalCopy.message(for: $0)
        }
        #expect(spoken == OpsRefusalCopy.message(for: OperationError.starLimitReached(limit: Operations.starLimit)))
        #expect(spoken.hasPrefix("You can star \(Operations.starLimit) things at a time"))
        #expect(!spoken.contains("starLimitReached"))
    }
}
