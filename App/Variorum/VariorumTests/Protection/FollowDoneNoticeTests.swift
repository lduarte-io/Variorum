//
//  FollowDoneNoticeTests.swift
//  VariorumTests — VX-309 U2 piece 2: VX-457 — THE FOLLOW'S DONE IS A DURABLE PANE NOTICE UNTIL OK (her ruling 2026-10-19 on
//  P-VX308-U2-7: "I agree with B"). The other-device sentence (VX-107's) was a one-shot RECEIPT on the status seam, so
//  `receipt_style` off hid it and a quit before she looked lost it. Now it is the export notice's idiom: a durable mark in
//  this Mac's defaults, KEYED BY LIBRARY (`variorum.calmAsks.followDone.<libraryID>.kind`), written where the Done was
//  owed (the press that landed whole; the open whose settle finished the follow), read at every refresh of the account
//  section, cleared only by its OK — and never written on today's road (no new-road face exists there). Also runs headless
//  in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U2 — VX-457: the follow's Done, a durable pane notice until OK")
@MainActor
struct FollowDoneNoticeTests {
    /// RED ON OLD: an open whose settle finished a follow owed the Done as a one-shot receipt (VX-107's), which
    /// `receipt_style` off hides and a quit loses. It is no receipt any more — the durable notice carries it.
    @Test func theSettlesDoneIsNoReceiptAnyMore() {
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            var report = RoadOpenReport()
            report.settledFollow = kind
            #expect(!RoadStandingFaces.derive(report).receipts.contains(ProtectionWords.followDone(kind)),
                    "\(kind): the Done rides the durable notice, never a one-shot receipt")
        }
    }
}
