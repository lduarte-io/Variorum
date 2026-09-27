//
//  FlowStoryHeightOneBrainTests.swift
//  VariorumTests
//
//  **18l-b UNIT U4, item 3 — a flow story stands at the manifest's OWN height
//  (the post-13u health review's D1, §1.3 item 2).** Read ▸ Scroll's
//  `FlowStoryRow` stood at `FlowHeightEstimate.honestHeight` (remembered at
//  this width, else the estimate) while the same file's column manifest — the
//  offsets every flow landing aims by — resolved the story through
//  `BookHeightManifest.resolve` (measured > remembered > derived, a
//  non-positive or non-finite answer falling through). *"They agree today only
//  by accident of a nil argument"*: a story's manifest input has no measured
//  arm, and no production road remembers a non-positive story height
//  (`StableSurface` remembers only above its placeholder ceiling; the empty
//  read remembers 20; a persisted record refuses ≤ 0). Two precedence rules
//  for one height is KnownIssues row 58's drift class — a row standing at one
//  number while the landing aims by another.
//
//  What this pins is the contract the collapse makes true by construction:
//  **for EVERY input, the row's height IS the manifest's height** for that
//  story. RED ON OLD only on the degenerate inputs (a remembered height of 0
//  or less at this width: the row stood at it, the manifest fell through to
//  the estimate) — inputs no production road produces today, stated plainly:
//  this is the drift made visible, not a user-visible defect. The proof the
//  collapse moved nothing she sees is `ReadingFlowLandingTests` +
//  `BookOutlineLandingTests` + `ReadingFlowEstimateTests` riding unmodified.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@Suite("18l-b U4 — a flow story stands at the manifest's own height (D1: one brain)")
struct FlowStoryHeightOneBrainTests {
    @Test @MainActor func theRowsHeightIsTheManifestsHeightForEveryInput() {
        let widths: [CGFloat] = [450, 600]
        let memories: [CGSize?] = [
            nil,
            CGSize(width: 600, height: 20_000),  // at 600 — applies there
            CGSize(width: 450, height: 12_000),  // at 450 — applies there
            CGSize(width: 600.5, height: 9_000), // within the 1-pt tolerance of 600
            CGSize(width: 600, height: 0),       // degenerate: no production road writes it
            CGSize(width: 450, height: -5),      // degenerate: likewise
        ]
        let estimates: [CGFloat] = [26_000, FlowHeightEstimate.unknownHeight, FlowHeightEstimate.emptyNoteHeight]
        var disagreements: [String] = []
        for width in widths {
            for remembered in memories {
                for estimate in estimates {
                    let row = FlowHeightEstimate.honestHeight(
                        remembered: remembered, columnWidth: width, estimate: estimate)
                    // The column's manifest input for a story, exactly as the
                    // column builds it (`ReadingFlowView.heightManifest`): the
                    // remembered size only at THIS width, the estimate as the
                    // derived arm, no measured arm.
                    let manifest = BookHeightManifest(
                        width: width, spacing: ReadingFlowView.rowSpacing,
                        leading: ReadingFlowView.columnLead,
                        inputs: [BookHeightManifest.Input(
                            id: "flow-story",
                            remembered: remembered.flatMap {
                                FlowHeightEstimate.remembered($0, appliesAt: width) ? $0.height : nil
                            },
                            derived: estimate)])
                    let column = manifest.height(of: "flow-story")
                    if column != row {
                        disagreements.append(
                            "width \(width) · remembered \(String(describing: remembered)) · "
                                + "estimate \(estimate): row \(row), manifest \(String(describing: column))")
                    }
                }
            }
        }
        #expect(disagreements.isEmpty, Comment(rawValue:
            "the row and the manifest are ONE height rule — disagreements: \(disagreements)"))
    }
}
