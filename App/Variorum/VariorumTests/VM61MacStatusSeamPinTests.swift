//
//  VM61MacStatusSeamPinTests.swift
//  VariorumTests
//
//  **VM-61 — the Mac's status seam is byte-identical after it moved to shared
//  code** (umbrella VM-55, batch 2a). `StatusCenter` left `Registry/` for
//  `Shared/` so the phone speaks through the same `session.status`; the
//  phone's placement is a new branch of the ONE routing rule, and the new
//  doors (`removal`, `withdraw`) are the phone's. This pins that the Mac took
//  none of it:
//
//  · the Mac's placement is her receipt style, by the build (no caller sets it);
//  · the routing table — every kind × every receipt style — is the shipped one,
//    and a removal said on the Mac routes exactly as a receipt;
//  · the slots behave as shipped (toast · quiet · off, one message at a time,
//    the 6 s clock, the standing offer on the quiet line);
//  · no Mac door says `removal`, `withdraw`s, or sets the placement.
//
//  **How a regression trips it:** a Mac build defaulting to the phone's
//  placement reds the first pin and the slot pins (a quiet receipt would be
//  dropped); an edit to the shared rule's Mac branch reds the table; a Mac door
//  adopting the phone's doors reds the source scan — a deliberate adoption
//  updates this pin in the same commit, so the change is seen.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VM-61 — the Mac's status seam is unchanged by the move to shared code")
struct VM61MacStatusSeamPinTests {
    @Test func theMacsPlacementIsHerReceiptStyle() {
        #expect(StatusCenter().placement == .receiptStyle)
    }

    /// The shipped rule, written out: refusals and offers toast under every
    /// style; a receipt toasts, sits on the quiet line, or is dropped, as her
    /// style says — and a receipt that left the page is still just a receipt.
    @Test func theMacsRoutingTableIsTheShippedOne() {
        let receiptAnswer: [ReceiptStyle: StatusCenter.Slot?] = [
            .toast: .toast, .quiet: .quiet, .off: nil,
        ]
        for style in ReceiptStyle.allCases {
            for leaves in [false, true] {
                #expect(StatusCenter.slot(
                    kind: .refusal, leavesPage: leaves, placement: .receiptStyle,
                    receiptStyle: style) == .toast)
                #expect(StatusCenter.slot(
                    kind: .offer, leavesPage: leaves, placement: .receiptStyle,
                    receiptStyle: style) == .toast)
                #expect(StatusCenter.slot(
                    kind: .receipt, leavesPage: leaves, placement: .receiptStyle,
                    receiptStyle: style) == receiptAnswer[style] ?? nil,
                        "\(style), leavesPage \(leaves)")
            }
        }
    }

    @Test func theMacsSlotsBehaveAsShipped() throws {
        let status = StatusCenter()
        #expect(status.dismissAfter == .seconds(6), "the one auto-dismiss policy")
        #expect(status.receiptStyle == .quiet, "her default, before the settings land")

        status.receipt("Blocks joined.")
        #expect(status.quietLine?.text == "Blocks joined.")
        #expect(status.current == nil)

        status.refuse("Refused.")
        #expect(status.current?.kind == .refusal)
        #expect(status.quietLine == nil, "a new message clears the other slot")

        status.receiptStyle = .toast
        status.receipt("Landed.")
        #expect(status.current?.kind == .receipt)
        #expect(status.quietLine == nil)

        status.receiptStyle = .off
        status.clear()
        status.receipt("Dropped.")
        #expect(status.current == nil && status.quietLine == nil)
        #if DEBUG
        #expect(status.lastDroppedReceipt == "Dropped.")
        #endif

        status.offer("Diverge?", action: .init(label: "Diverge", perform: {}))
        #expect(status.current?.kind == .offer)
        #expect(status.current?.action?.label == "Diverge")
        #expect(status.current?.leavesPage == false)
        #expect(status.current?.owner == nil)

        let id = try #require(status.stand(
            "Show me this?", action: .init(label: "Open", perform: {}),
            dismiss: .init(label: "Dismiss", perform: {})))
        #expect(status.current?.id == id)
        status.clear()
        #expect(status.lineItem?.id == id, "the standing offer holds the quiet line")
        status.endStanding(id)
        #expect(status.lineItem == nil)
    }

    /// **Byte-identical by construction**: no Mac door takes the phone's roads.
    @Test func noMacDoorSaysRemovalWithdrawsOrSetsThePlacement() throws {
        let macRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum")
        let walker = try #require(FileManager.default.enumerator(
            at: macRoot, includingPropertiesForKeys: nil))
        let files = walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        #expect(!files.isEmpty, "the scan reached the Mac app's sources")
        let forbidden = ["status.removal(", ".withdraw(owner:", ".placement ="]
        var hits: [String] = []
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for (number, line) in text.components(separatedBy: "\n").enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.hasPrefix("//") else { continue }
                for word in forbidden where line.contains(word) {
                    hits.append("\(file.lastPathComponent):\(number + 1): \(word)")
                }
            }
        }
        #expect(hits.isEmpty, "the Mac took a phone road: \(hits)")
    }
}
