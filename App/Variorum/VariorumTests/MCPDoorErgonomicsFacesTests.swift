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

    // MARK: - VX-943 (the VX-915 run, batch 6 — APPENDED; nothing above modified)

    /// `unlink_versions`, the link's opposite, in the app's voice (PROVISIONAL
    /// words, her copy pass): ONE client-named undo entry — so its receipt says
    /// "⌥⌘Z undoes" — the receipt naming both notes, and Activity in words for
    /// the landed, the counted and the refused row. Red on old by absence (the
    /// act, the tool and the words did not exist).
    @Test func theUnlinkSaysWhatLandedAndIsOneUndoAtEdit() {
        // A JUSTIFIED EDIT (the VX-915 gate36 disposition): the first words, "removed
        // the version link between “one” and “two”", made a 73-character line against
        // `MCPReceiptCopy.budget` (72), so `line()` always spoke its count fallback
        // ("made a change") — red here at gate36's first run. The two-note line is now
        // the link's mirror, 61 characters at these titles (PROVISIONAL words, her bundle).
        #expect(MCPReceiptCopy.line([receipt(.versionUnlink, title: "one", detail: "two")])
                == "claude-code unlinked \u{201C}one\u{201D} and \u{201C}two\u{201D} as versions" + undoes)
        #expect(MCPReceiptCopy.line([receipt(.versionUnlink, title: "one", detail: "two"),
                                     receipt(.versionUnlink, title: "one", detail: "two")])
                == "claude-code removed 2 version links" + undoes)
        // A JUSTIFIED EDIT (the VX-915 ladder's F-7 — appended): a link inside ONE
        // note arrives with the note once (no far side — `detail` nil, the wire
        // pin `MCPUnlinkVersionsServerTests.aLinkInsideOneNoteCarriesTheNoteOnceOnItsReceipt`)
        // and says so, never "between “one” and “one”" (PROVISIONAL words, her bundle).
        #expect(MCPReceiptCopy.line([receipt(.versionUnlink, title: "one", detail: nil)])
                == "claude-code removed a version link inside \u{201C}one\u{201D}" + undoes)
        #expect(Operations.MCPWriteAct.versionUnlink.undoLabel(client: "claude-code")
                == "claude-code's version link removal")
        #expect(Operations.MCPWriteAct.versionUnlink.isUndoable, "one undo for her puts the link back")
        #expect(line("unlink_versions", allowed: true) == "a-client removed a version link from \u{201C}a letter\u{201D}")
        #expect(line("unlink_versions", allowed: true, count: 3)
                == "a-client removed 3 version links from \u{201C}a letter\u{201D}")
        #expect(line("unlink_versions", allowed: false)
                == "a-client was refused removing a version link from \u{201C}a letter\u{201D}")
        // VX-977 (the VX-981 run, batch 2 — A JUSTIFIED EDIT; the test renamed from
        // "…AtWriteNew"): her ruling on P-915-B6-1 — edit on both notes.
        #expect(MCPToolFacts.rung(of: "unlink_versions") == .edit,
                "her ruling: \"i imagine with edit to both, they should also be able to unlink something a user made\"")
        #expect(MCPToolFacts.rung(of: "link_versions") == .writeNew, "making the link stays write new (R-VX187-1)")
    }

    // MARK: - VX-979 (the VX-981 run, batch 2 — APPENDED): the title-free arm

    /// **VX-979 — a version link or unlink too long for the bar keeps WHAT it did** (her words,
    /// QUESTIONS #273 addendum 2: "A title free arm might be nice in the longrun"): past
    /// `MCPReceiptCopy.budget` the two titles go — "unlinked two notes as versions" (hers), the
    /// link's plain mirror "linked two notes as versions" and the one-note unlink's "removed a
    /// version link inside a note" (PROVISIONAL P-981-B2-1, -2) — never the generic "made a
    /// change". At the boundary: the longest pair that fits keeps its titled form byte for byte
    /// (72 characters with "claude-code"); one character more takes the title-free arm. RED ON OLD
    /// by mechanism: past the budget the old line said "claude-code made a change · ⌥⌘Z undoes".
    @Test func aVersionLinkOrUnlinkTooLongForTheBarKeepsWhatItDidWithoutTheTitles() {
        func t(_ n: Int, _ c: Character) -> String { String(repeating: c, count: n) }
        // The unlink — titles totalling 17 fit (55 + 17 = 72); 18 do not.
        let fits = MCPReceiptCopy.line([receipt(.versionUnlink, title: t(9, "a"), detail: t(8, "b"))])
        #expect(fits == "claude-code unlinked \u{201C}\(t(9, "a"))\u{201D} and \u{201C}\(t(8, "b"))\u{201D} as versions"
                + undoes, "the longest pair that fits keeps its titled form: \(fits)")
        #expect(fits.count == MCPReceiptCopy.budget, "the boundary is exact: \(fits.count)")
        #expect(MCPReceiptCopy.line([receipt(.versionUnlink, title: t(9, "a"), detail: t(9, "b"))])
                == "claude-code unlinked two notes as versions" + undoes, "one character more: title-free")
        // The link — titles totalling 19 fit (53 + 19 = 72); 20 do not.
        let linkFits = MCPReceiptCopy.line([receipt(.versionLink, title: t(10, "a"), detail: t(9, "b"))])
        #expect(linkFits == "claude-code linked \u{201C}\(t(10, "a"))\u{201D} and \u{201C}\(t(9, "b"))\u{201D} as versions"
                + undoes, "the link's longest fitting pair keeps its titled form: \(linkFits)")
        #expect(linkFits.count == MCPReceiptCopy.budget)
        #expect(MCPReceiptCopy.line([receipt(.versionLink, title: t(10, "a"), detail: t(10, "b"))])
                == "claude-code linked two notes as versions" + undoes, "the link's twin")
        // A link inside ONE note (the VX-915 ladder's F-7): a title of 15 fits (57 + 15 = 72); 16 not.
        let insideFits = MCPReceiptCopy.line([receipt(.versionUnlink, title: t(15, "a"), detail: nil)])
        #expect(insideFits == "claude-code removed a version link inside \u{201C}\(t(15, "a"))\u{201D}" + undoes)
        #expect(insideFits.count == MCPReceiptCopy.budget)
        #expect(MCPReceiptCopy.line([receipt(.versionUnlink, title: t(16, "a"), detail: nil)])
                == "claude-code removed a version link inside a note" + undoes)
        // The generic fallback is no longer reachable from this pair, at any title length.
        for (act, detail) in [(Operations.MCPWriteAct.versionUnlink, t(400, "b")), (.versionLink, t(400, "b")),
                              (.versionUnlink, nil)] {
            let line = MCPReceiptCopy.line([receipt(act, title: t(400, "a"), detail: detail)])
            #expect(!line.contains("made a change") && line.count <= MCPReceiptCopy.budget, "\(act): \(line)")
        }
        // A GUARD: every other single act past the budget keeps the count fallback (D-U6-1).
        #expect(MCPReceiptCopy.line([receipt(.note, title: t(80, "a"))]) == "claude-code made a change" + undoes)
    }
}
