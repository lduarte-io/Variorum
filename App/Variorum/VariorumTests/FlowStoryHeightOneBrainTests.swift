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
//  **What this pins, and why it binds PRODUCTION on both sides** (the U4
//  ladder's round 1, MINOR-1 — the first cut read a hand-built column input and
//  a static the row no longer called, so a row reverted to its own rule stayed
//  green): the ROW's side is `FlowHeightEstimate.honestHeight` — the one rule
//  `FlowStoryRow` calls (it holds none of its own); the COLUMN's side is
//  `FlowHeightEstimate.storyInput` — the builder `ReadingFlowView.heightManifest`
//  calls — resolved by the manifest. **For EVERY input, the row's height IS the
//  manifest's height.** Green by construction on this tree (the row's rule is
//  `resolve` of that builder); it REDS the day the row's rule gets a precedence
//  of its own — shown at the ladder's fix pass by restoring the pre-U4 two-arm
//  rule in the working tree (red on exactly the 6 degenerate combinations below,
//  a remembered height ≤ 0 at the matching width). Those inputs are ones no
//  production road writes today, stated plainly: this is the drift made
//  visible, not a user-visible defect. The proof that the collapse moved
//  nothing she sees is `ReadingFlowLandingTests` + `BookOutlineLandingTests` +
//  `ReadingFlowEstimateTests` riding unmodified.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

// (The residual is TWO-SIDED — a rule typed into the private row OR a hand-built
// input in `heightManifest`'s `.post` case would each pass this pin; the defence
// on both sides is structural: one call, one builder — the U4 ladder's NIT-R2-3.)
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
                    // The ROW: the one rule `FlowStoryRow` calls.
                    let row = FlowHeightEstimate.honestHeight(
                        remembered: remembered, columnWidth: width, estimate: estimate)
                    // The COLUMN: the builder `ReadingFlowView.heightManifest`
                    // calls for a story, resolved by the manifest itself.
                    let manifest = BookHeightManifest(
                        width: width, spacing: ReadingFlowView.rowSpacing,
                        leading: ReadingFlowView.columnLead,
                        inputs: [FlowHeightEstimate.storyInput(
                            id: "flow-story", remembered: remembered,
                            columnWidth: width, estimate: estimate)])
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
