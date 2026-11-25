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
//  · no Mac door says `removal`, `withdraw`s, or sets the placement — nor reads
//    the phone face's direction fact (VM-265, `Item.isDirection`), says or
//    reads a refusal's headline, or holds the clock (VM-277).
//
//  **How a regression trips it:** a Mac build defaulting to the phone's
//  placement reds the first pin and the slot pins (a quiet receipt would be
//  dropped); an edit to the shared rule's Mac branch reds the table; a Mac door
//  adopting the phone's doors reds the source scan — a deliberate adoption
//  updates this pin in the same commit, so the change is seen.
//

import Foundation
import Testing
import VariorumCore
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

        // VM-265 (the VM-260 run, batch 1b): `direct` builds its own item now
        // (to mark it a direction for the PHONE's face) — on the Mac it still
        // lands exactly as before: the toast, the refusal's class, trimmed,
        // and nothing for blank words.
        status.receipt("Quiet first.")
        status.direct("  Finish the ceremony, then run this again.  ")
        #expect(status.current?.kind == .refusal)
        #expect(status.current?.text == "Finish the ceremony, then run this again.")
        #expect(status.quietLine == nil, "a direction clears the quiet slot, as a refusal does")
        let shown = status.current?.id
        status.direct("   ")
        #expect(status.current?.id == shown, "blank words say nothing")

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
    ///
    /// *Narrowed in batch 2's window (VM-55 batch 2b, a 2a follow-up):* the bare
    /// `.placement =` matched `WingLabelPlacementView`'s own layout property
    /// (`self.placement = placement`, VX-833) — a false positive. The words are
    /// now the seam's own spelling, `status.placement =`, plus the one harmful
    /// value, `.phoneLine`: the scan still catches a Mac door that sets the
    /// seam's placement through `status`, or names the phone's placement
    /// anywhere; it no longer catches one that sets it through a binding not
    /// named `status` to a value other than `.phoneLine`.
    ///
    /// *Extended in VM-63 (VM-55 batch 3 — the wing brains' hoist):* a Mac brain
    /// that moved to `Shared/` left this walk of `Variorum/`, so the scan also
    /// reads each HOISTED file by name (`hoistedMacBrains`) for the same four
    /// words. A hoisted brain speaks on BOTH platforms through the one seam, so
    /// a phone road said there would be said on the Mac too. Each name must
    /// exist, so a rename or a stale entry trips here rather than leaving a
    /// moved brain unscanned.
    @Test func noMacDoorSaysRemovalWithdrawsOrSetsThePlacement() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let macRoot = appRoot.appendingPathComponent("Variorum")
        let walker = try #require(FileManager.default.enumerator(
            at: macRoot, includingPropertiesForKeys: nil))
        var files = walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        #expect(!files.isEmpty, "the scan reached the Mac app's sources")
        let shared = appRoot.appendingPathComponent("Shared")
        for name in Self.hoistedMacBrains {
            let file = shared.appendingPathComponent(name)
            #expect(FileManager.default.fileExists(atPath: file.path),
                    "the hoisted brain is where this pin reads it: \(name)")
            files.append(file)
        }
        // VM-265: `isDirection` is the phone face's fact — no Mac face reads it.
        // VM-277: the refusal's short form and the reading hold are the phone's
        // too — no Mac door says a headline, reads one, or holds the clock.
        let forbidden = [
            "status.removal(", ".withdraw(owner:", "status.placement =", ".phoneLine", "isDirection",
            "refusalHeadline", "refuse(headline:", "holdForReading",
        ]
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

    /// **VM-63 — the Mac brains that moved to `Shared/`**, by file (the hoist's
    /// record: `notes/plans/fixes/vm-55-wings-underneath.md` ▸ "Batch 3
    /// record"). Each speaks on the Mac exactly as it did from `Variorum/`, so
    /// each stays in the scan above.
    static let hoistedMacBrains = [
        "WingsModel.swift",
        "WingBookMoveBrain.swift",
        "WingDestinationModel.swift",
        "WingSwitcherBrain.swift",
        "WingFollowRule.swift",
        "SearchPickerBrain.swift",
    ]
}
