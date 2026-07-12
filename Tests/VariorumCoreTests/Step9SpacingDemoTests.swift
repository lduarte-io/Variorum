//
//  Step9SpacingDemoTests.swift
//  VariorumCoreTests
//
//  PHASE 10 STEP 9 — THE AUTHOR-GATE DEMO (QUESTIONS #12). This file SHIPS
//  NO BEHAVIOR: it documents today's spacing treatment exactly, and
//  prototypes option (a)'s mechanism as a TEST-LOCAL pure function so the
//  options walk is concrete. Whichever mechanism the author rules for is
//  implemented AFTER her ruling; this file is then superseded by the real
//  pins (and says so here to the cold reviewer: the demo is deliberately
//  not a pin — there is nothing ratified to pin yet).
//

import Foundation
import Testing
@testable import VariorumCore

// MARK: - Option (a)'s prototype (test-local; NOT shipped)

/// Option (a): inter-piece whitespace becomes BLOCK CONTENT — for a
/// separator run of k newlines between pasted pieces, the preceding block
/// keeps k-1 trailing newlines and the editor's single-"\n" separator
/// re-creates the last, so the SURFACE reproduces the paste byte-for-byte.
/// I4-clean (newlines are content), syncs for free, no schema change.
private func spacingPreservingParagraphSegments(_ text: String) -> [String] {
    guard !text.allSatisfy(\.isWhitespace) else { return [] }
    var blocks: [String] = []
    var current = ""
    var separatorRun = 0
    for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
        if line.allSatisfy(\.isWhitespace) {
            if !current.isEmpty { separatorRun += 1 }
            continue
        }
        if current.isEmpty {
            current = String(line)
        } else if separatorRun == 0 {
            // Adjacent lines (k=1): separate blocks, like today.
            blocks.append(current)
            current = String(line)
        } else {
            // k = separatorRun + 1 newlines separated the pieces: keep
            // k-1 as trailing content; the editor separator adds the last.
            blocks.append(current + String(repeating: "\n", count: separatorRun))
            current = String(line)
            separatorRun = 0
        }
    }
    if !current.isEmpty { blocks.append(current) }
    return blocks
}

/// Option (a)'s companion renderedText join rule (the merge precedent —
/// "a single space at the join UNLESS either side's edge already carries
/// whitespace"): join with "\n\n" as today, UNLESS the left block already
/// ends in a newline — then only complete it to the stored width + 1.
private func spacingAwareRenderedText(_ blocks: [String]) -> String {
    var result = ""
    for (i, block) in blocks.enumerated() {
        if i > 0 {
            result += result.hasSuffix("\n") ? "\n" : "\n\n"
        }
        result += block
    }
    return result
}

@Suite("STEP 9 DEMO — paste/newline spacing (QUESTIONS #12; ships nothing)")
struct Step9SpacingDemoTests {
    // MARK: - Today's behavior, documented exactly

    @Test func todayASingleNewlinePasteIsFaithful() {
        // "A\nB" (no blank line) → two blocks; the surface's single-"\n"
        // separator reproduces the paste exactly. k=1 was never the problem.
        let blocks = SegmentationRules.bulkSegments("A\nB", mode: .paragraph)
        #expect(blocks == ["A", "B"])
        #expect(blocks.joined(separator: "\n") == "A\nB")  // the editor surface
    }

    @Test func todayBlankLinesVanishFromTheSurface() {
        // "A\n\nB" (one blank line) → the same two blocks — the blank line
        // is GONE from the surface (the author's complaint).
        let blocks = SegmentationRules.bulkSegments("A\n\nB", mode: .paragraph)
        #expect(blocks == ["A", "B"])
        #expect(blocks.joined(separator: "\n") == "A\nB")  // paste said A\n\nB
        // And a THREE-newline run collapses identically:
        #expect(SegmentationRules.bulkSegments("A\n\n\nB", mode: .paragraph) == ["A", "B"])
    }

    @Test func todayExportNormalizesEveryBoundaryToOneBlankLine() {
        // renderedText joins with "\n\n" regardless of what the paste had:
        // k=2 comes back exact BY COINCIDENCE, k=1 GAINS a blank line, k=3
        // LOSES one. Export is not faithful today either — it's uniform.
        let blocks = ["A", "B"]
        let export = blocks.joined(separator: Queries.blockJoinSeparator)
        #expect(export == "A\n\nB")  // whether the paste was A\nB, A\n\nB, or A\n\n\nB
    }

    // MARK: - Option (a), demonstrated end to end

    @Test func optionAReproducesThePasteOnTheSurfaceExactly() {
        for paste in ["A\nB", "A\n\nB", "A\n\n\nB", "One.\n\nTwo.\n\n\n\nThree."] {
            let blocks = spacingPreservingParagraphSegments(paste)
            let surface = blocks.joined(separator: "\n")  // the editor separator
            #expect(surface == paste, "surface must reproduce the paste: \(paste.debugDescription)")
        }
    }

    @Test func optionAStoresTheSpacingAsTrailingContent() {
        // k newlines between pieces → k-1 trailing newlines on the left
        // block (content under I4; the separator re-creates the last).
        #expect(spacingPreservingParagraphSegments("A\nB") == ["A", "B"])
        #expect(spacingPreservingParagraphSegments("A\n\nB") == ["A\n", "B"])
        #expect(spacingPreservingParagraphSegments("A\n\n\nB") == ["A\n\n", "B"])
    }

    @Test func optionAExportFollowsWithTheMergeStylePrecedentJoin() {
        // The companion renderedText rule: "\n\n" unless the left edge
        // already carries a newline (exactly the ratified merge-join
        // shape). Exports then reproduce the paste too.
        #expect(spacingAwareRenderedText(["A", "B"]) == "A\n\nB")        // unchanged today's shape
        #expect(spacingAwareRenderedText(["A\n", "B"]) == "A\n\nB")      // k=2 paste → k=2 export
        #expect(spacingAwareRenderedText(["A\n\n", "B"]) == "A\n\n\nB")  // k=3 paste → k=3 export
    }

    @Test func optionAIsAPureSupersetOfTodayForUnspacedText() {
        // Text with no blank lines segments IDENTICALLY — the mechanism
        // only activates where spacing exists to preserve.
        let plain = "One paragraph.\nAnother paragraph.\nA third."
        #expect(spacingPreservingParagraphSegments(plain)
                == SegmentationRules.bulkSegments(plain, mode: .paragraph))
    }
}
