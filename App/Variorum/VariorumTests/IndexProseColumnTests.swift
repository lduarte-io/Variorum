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
import VariorumCore

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

    // MARK: - 18l-c U5: the trailing edge, the foot, and the line metrics

    /// The claim on the two edges 13u2 B left: the pane's prose ENDS where
    /// the read tier's does (the read tier pads `resting`; the pane host pads
    /// the remainder, which may be negative — a bleed), and its last line
    /// stands as far above the next block.
    @Test func bothTiersEndTheProseAtTheSameColumnAndFoot() {
        for inset in [CGFloat(0), 1, 5, 6, 11, 14, 20] {
            for resting in [IndexProseColumn.bookIndexResting, IndexProseColumn.readEditResting] {
                let live = IndexProseColumn.livePaneTrailing(resting: resting, paneInset: inset)
                #expect(resting == live + inset, "the prose ends at one x (resting \(resting), inset \(inset))")
            }
            for resting in [IndexProseColumn.bookIndexRestingTop, IndexProseColumn.readEditRestingTop] {
                let read = IndexProseColumn.readTierBottom(resting: resting, paneInset: inset)
                let live = IndexProseColumn.livePaneBottom(resting: resting, paneInset: inset)
                #expect(read == live + inset, "the last line stands one distance above the next block")
                #expect(live >= 0, "the pane never overlaps the block below")
                #expect(read >= resting, "the read tier's foot never shrinks below where it sat")
            }
        }
        // Today's numbers, said out loud: the trailing bleeds are 5 and 1 pt,
        // the live foot 0, the read foot its resting 6 (unchanged by U5).
        #expect(IndexProseColumn.livePaneTrailing(
            resting: IndexProseColumn.bookIndexResting, paneInset: 11) == -5)
        #expect(IndexProseColumn.livePaneTrailing(
            resting: IndexProseColumn.readEditResting, paneInset: 11) == -1)
        #expect(IndexProseColumn.readTierBottom(
            resting: IndexProseColumn.bookIndexRestingTop, paneInset: 6) == 6)
    }

    /// **THE MEASURED TERMS on the other two edges** — a pane's placement is
    /// symmetric, so its trailing and bottom insets are its leading and top
    /// ones; read off a real surface's own placement rule and container.
    @MainActor
    @Test func aPanesTrailingAndBottomInsetsAreMeasuredToo() {
        let probe = PaneTextView.makeTakeSurface()
        let padding = probe.textContainer?.lineFragmentPadding ?? 0
        let placed = probe.proseGutter.insets(viewWidth: 400)
        #expect(PaneTextView.proseTrailingInset == placed.trailing + padding)
        #expect(PaneTextView.proseLeadingInset == placed.leading + padding)
        #expect(PaneTextView.proseBottomInset == probe.textContainerInset.height)
    }

    /// **THE TEXTKIT 2 FACT the vocabulary's style rests on** (measured on
    /// 27.0 at U5 — a TEXTKIT2 §5 tripwire): laid out with
    /// `IndexProseColumn.lines.paragraphStyle`, a paragraph's lines sit
    /// `lineSpacing` apart and two paragraphs `paragraphGap` apart — exactly
    /// what the read tier's `Text.lineSpacing(4)` in a `VStack(spacing: 8)`
    /// draws. TK2 lays a paragraph's `lineSpacing` above the NEXT paragraph's
    /// first line too, which is why the style carries `gap − lineSpacing`;
    /// if a point release stops doing that, this goes red rather than the
    /// tiers drifting 4 pt a paragraph under her pointer.
    @MainActor
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theVocabularysStyleDrawsTheReadTiersSpacing(_ voice: ThemeVoice) {
        let font = EditorTypography.resolve(voice: voice, inlineComments: false).font
        let metrics = IndexProseColumn.lines
        let paragraph = String(repeating: "word ", count: 60)
        let text = paragraph + "\n" + paragraph
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttributes(
            [.font: font, .paragraphStyle: metrics.paragraphStyle],
            range: NSRange(location: 0, length: (text as NSString).length))
        let content = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        content.addTextLayoutManager(manager)
        let container = NSTextContainer(size: CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        manager.textContainer = container
        content.attributedString = attributed
        var paragraphs: [[(top: CGFloat, bottom: CGFloat)]] = []
        manager.enumerateTextLayoutFragments(
            from: manager.documentRange.location, options: [.ensuresLayout]
        ) { fragment in
            let y = fragment.layoutFragmentFrame.minY
            paragraphs.append(fragment.textLineFragments.map {
                (y + $0.typographicBounds.minY, y + $0.typographicBounds.maxY)
            })
            return true
        }
        #expect(paragraphs.count == 2 && paragraphs.allSatisfy { $0.count > 2 },
                "two wrapped paragraphs laid out")
        guard paragraphs.count == 2 else { return }
        for lines in paragraphs {
            for (upper, lower) in zip(lines, lines.dropFirst()) {
                #expect(abs(lower.top - upper.bottom - metrics.lineSpacing) < 0.01,
                        "\(voice): lines \(lower.top - upper.bottom) apart, the tier's \(metrics.lineSpacing)")
            }
        }
        if let last = paragraphs[0].last, let first = paragraphs[1].first {
            #expect(abs(first.top - last.bottom - metrics.paragraphGap) < 0.01,
                    "\(voice): paragraphs \(first.top - last.bottom) apart, the tier's \(metrics.paragraphGap)")
        }
    }
}
