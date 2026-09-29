//
//  MobileEditRouteArmsTests.swift
//  VariorumMobileTests
//
//  **18m U1 — the phone's gate walks the phone's DECLARED cross-block
//  ladder.** The route itself is one pure decision in
//  `Shared/EditorBrain/EditorEditRoute.swift`, pinned for both platforms'
//  lists by the Mac target's `EditorEditRouteTableTests`; this is the
//  phone-target half: that `MobileEditorViewModel` walks `phoneArms` and
//  nothing else, that the list carries no seam carves (KnownIssues row 51 —
//  declared absent, never built here), and that its list cannot fire the
//  find fence even if the fact were true (the 18m U1 ruling's condition 6 —
//  the gate passes `false` besides).
//
//  NEW-BEHAVIOR pins for the table; the ROUTE-EQUIVALENCE claim rides the
//  phone's unmodified gesture pins (`MobileCrossBlockEditTests`,
//  `MobileWholeBlockDeleteTests`).
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("The phone walks its declared cross-block ladder (18m U1)")
@MainActor
struct MobileEditRouteArmsTests {

    @Test func thePhoneGateWalksThePhonesDeclaredList() {
        #expect(MobileEditorViewModel.routeArms == EditorEditRoute.phoneArms)
        #expect(MobileEditorViewModel.routeArms == [
            .wholeBlockDelete, .clampedInBlockEdit, .gapFence, .crossBlockCompound,
        ])
        #expect(EditorEditRoute.violations(of: MobileEditorViewModel.routeArms).isEmpty)
    }

    /// Row 51, as a declared fact: no seam carve, no find fence.
    @Test func thePhonesListDeclaresNoSeamCarvesAndNoFindFence() {
        for absent: EditorEditRoute.Arm in [.emptyBlockCarve, .textedSeamMerge, .findReplaceFence] {
            #expect(!MobileEditorViewModel.routeArms.contains(absent), "\(absent)")
        }
    }

    /// A seam backspace beside an EMPTY block — the Mac's carve — declines
    /// every phone arm and speaks the diagnosis, fence fact or no fence fact.
    @Test func aSeamKeystrokeOnThePhoneIsTheDiagnosisEvenUnderAFindFact() {
        let index = BlockRangeIndex(
            entries: [
                BlockRangeIndex.Entry(blockID: "b0", variantID: "v0", length: 5, editable: true),
                BlockRangeIndex.Entry(blockID: "b1", variantID: "v1", length: 0, editable: true),
            ],
            tailLength: nil)
        let surface = "alpha\n" as NSString
        for fact in [false, true] {
            let route = EditorEditRoute.route(
                range: NSRange(location: 5, length: 1), replacement: "",
                index: index, slots: [],
                findReplacing: fact,
                arms: MobileEditorViewModel.routeArms,
                surfaceText: { surface.substring(with: $0) })
            #expect(route == .refuse(.seamKeystrokeDeclined), "findReplacing: \(fact)")
        }
    }
}
