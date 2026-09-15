//
//  IndexProseColumnTests.swift
//  VariorumTests
//
//  **13u2 UNIT B — her item 19 (R-13u-10):** *"the text indents in index mode
//  where you're editing it, which should not be happening the second you
//  click into a block."*
//
//  The arithmetic behind the mounted pin
//  (`BookIndexEditingTests.clickingIntoABlockDoesNotMoveItsProseSideways`):
//  one number per surface, both tiers derived from it, so a future edit that
//  pads one tier and forgets the other fails here rather than at her eye.
//

import AppKit
import CoreGraphics
import Testing

@testable import Variorum

@Suite("The index surfaces' prose column (13u2 UNIT B)")
struct IndexProseColumnTests {
    /// The claim, for both surfaces at once: the read tier's leading padding
    /// equals the live pane HOST's plus the pane's own inset — which is to
    /// say the prose starts at the same x either way.
    @Test func bothTiersPutTheProseAtTheSameColumn() {
        let cases: [(name: String, resting: CGFloat)] = [
            ("the book Index pane", IndexProseColumn.bookIndexResting),
            ("the note's Read ▸ edit", IndexProseColumn.readEditResting),
        ]
        // Every inset a pane could plausibly have, including ones larger and
        // smaller than each surface's resting padding.
        for inset in [CGFloat(0), 1, 5, 6, 11, 14, 20] {
            for (name, resting) in cases {
                let read = IndexProseColumn.readTierLeading(resting: resting, paneInset: inset)
                let live = IndexProseColumn.livePaneLeading(resting: resting, paneInset: inset)
                #expect(read == live + inset, "\(name): the prose lands at one x")
                #expect(live >= 0, "\(name): the pane is never pushed outside its row")
                #expect(read >= resting, "\(name): the read tier never moves left of where it sat")
            }
        }
    }

    /// The same split on the vertical axis, so a block's first LINE sits at
    /// the same height in both tiers.
    @Test func bothTiersPutTheFirstLineAtTheSameHeight() {
        for inset in [CGFloat(0), 4, 6, 9] {
            for resting in [CGFloat(3), 6, 10] {
                let read = IndexProseColumn.readTierTop(resting: resting, paneInset: inset)
                let live = IndexProseColumn.livePaneTop(resting: resting, paneInset: inset)
                #expect(read == live + inset)
                #expect(live >= 0)
                #expect(read >= resting)
            }
        }
    }

    /// **THE MEASURED TERM.** The pane's own prose inset is read off a real
    /// surface, not assumed — the container inset the app chooses plus
    /// AppKit's own `lineFragmentPadding`. If a point release changes either,
    /// this says so instead of the hosts silently drifting apart again (the
    /// TEXTKIT2 §5 matrix's kind of fact).
    @MainActor
    @Test func aPanesOwnProseInsetIsWhatTheHostsPayBack() {
        let probe = PaneTextView.makeTakeSurface()
        #expect(PaneTextView.proseLeadingInset
                == probe.textContainerInset.width + (probe.textContainer?.lineFragmentPadding ?? 0))
        #expect(PaneTextView.proseTopInset == probe.textContainerInset.height)
        // Measured on macOS 26.x at 13u2: 6 (ours) + 5 (AppKit's) = 11.
        #expect(PaneTextView.proseLeadingInset == 11,
                "the measured inset moved — re-check the hosts' columns (it is \(PaneTextView.proseLeadingInset))")
    }
}
