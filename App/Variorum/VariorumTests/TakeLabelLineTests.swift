//
//  TakeLabelLineTests.swift
//  VariorumTests (Mac)
//
//  VX-352 (RUN VX-548, batch 2a — the run record
//  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`; PROVISIONAL MB-4) — THE
//  TAKE CARD'S LABEL, AS THE REAL HEADER LAYS IT OUT. Her capture (the VX-336 U5
//  STAGE RUN, step 12): Terminal's margin-grid card read "choose claude-code · e…".
//  The rule is pure and pinned headlessly, red on old (`TakeLabelFaceTests` in the
//  core: the old face is the reading-order allocation and reproduces the capture
//  exactly). These pins are its GEOMETRY ORACLE on the real view: `TakeChooseHeader`
//  mounted in Terminal and in Study, swept across widths, each mount's placed part
//  widths read from `TakeLabelLayoutProbe` (DEBUG) — so whatever the header's stack
//  offers the label, the label's own words are never cut while the line has room for
//  them, and the client's name is what gives way.
//
//  Red-on-old for THESE pins is by construction (the old header had one `Text` — no
//  line, no probe); the red leg is the core's.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-352 — the take card's header keeps the label's own words (placed widths)", .serialized)
struct TakeLabelLineTests {
    private static let label = "claude-code \u{00B7} english"

    private func header(_ label: String, _ tokens: VoiceTokens) -> some View {
        TakeChooseHeader(tokens: tokens, isChosen: false, label: label, onChoose: {})
    }

    /// The header's ideal width (everything whole, nothing to spare).
    private func idealWidth(_ label: String, _ tokens: VoiceTokens) -> CGFloat {
        NSHostingView(rootView: header(label, tokens)).fittingSize.width
    }

    /// Mount the header at `width` and read what its label line placed.
    private func placement(
        _ label: String, _ tokens: VoiceTokens, width: CGFloat
    ) -> TakeLabelLayoutProbe.Placement? {
        TakeLabelLayoutProbe.forget(label)
        let hosting = NSHostingView(rootView: header(label, tokens).frame(width: width, alignment: .leading))
        let frame = NSRect(x: 0, y: 0, width: width, height: 40)
        let window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = hosting
        hosting.frame = frame
        for _ in 0..<3 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        let placed = TakeLabelLayoutProbe.placements[label]
        window.contentView = nil
        window.close()
        return placed
    }

    /// Terminal (where her capture was): across a sweep from the header's
    /// ideal width down past where the client's name has gone, the label's
    /// own part (" · english") is placed at its WHOLE width every time the
    /// line has room for it — and there are widths where the name is cut
    /// ("claud… · english"), so the case is exercised, not skirted.
    @Test func terminalsNarrowHeaderKeepsTheLabelsOwnWordsWholeAndTheNameYields() throws {
        let tokens = VoiceTokens.terminalLight
        let ideal = idealWidth(Self.label, tokens)
        let wide = try #require(placement(Self.label, tokens, width: ideal + 40), "the line laid out")
        #expect(wide.placed.count == 2 && wide.ideals.count == 2, "two parts: the name, then its own words")
        let (nameIdeal, ownIdeal) = (wide.ideals[0], wide.ideals[1])
        #expect(abs(wide.placed[0] - nameIdeal) < 0.5 && abs(wide.placed[1] - ownIdeal) < 0.5,
                "with room, both whole — the face as it was (\(wide))")

        var nameCut = 0
        var width = ideal
        while width > ideal - nameIdeal - ownIdeal / 2 {
            let at = try #require(placement(Self.label, tokens, width: width), "laid out at \(width)")
            let line = at.placed.reduce(0, +)
            if line >= ownIdeal - 0.5 {
                #expect(at.placed[1] >= ownIdeal - 0.5,
                        "at \(width) pt the line had room for its own words — kept whole (\(at))")
            }
            if at.placed[0] > 0.5, at.placed[0] < nameIdeal - 0.5, at.placed[1] >= ownIdeal - 0.5 {
                nameCut += 1
            }
            width -= 2
        }
        #expect(nameCut > 0, "the sweep reached widths where the client's name gives way first")
    }

    /// Study (proportional) shows it whole at its own ideal — unchanged.
    @Test func studyShowsTheWholeLabelWhenItFits() throws {
        let tokens = VoiceTokens.studyLight
        let at = try #require(placement(Self.label, tokens, width: idealWidth(Self.label, tokens) + 20))
        #expect(at.placed.count == 2)
        for (placed, ideal) in zip(at.placed, at.ideals) {
            #expect(abs(placed - ideal) < 0.5, "whole: \(at)")
        }
    }

    /// **Fix leg 2a-F2 (FINDING MID-4 — MB-4's hover half).** The label draws
    /// inside the choose button, met as ONE element whose help is the
    /// button's own, so the whole label rides THAT help: its own line, then
    /// the band's sentence exactly as before. A take with no label hears the
    /// band's sentences byte for byte. (The tooltip itself can't be raised
    /// in-process — the final window's walker reads the button's AX help.)
    @Test func theHeadersHoverCarriesTheWholeLabelAndKeepsTheChooseSentence() {
        #expect(TakeChooseHeader.chooseHelp
                == "Choose this take \u{2014} the note shows it (everywhere); \u{2318}\u{23CE} from the keyboard",
                "the band's choose sentence, unchanged")
        #expect(TakeChooseHeader.chosenHelp == "The note shows this take (everywhere)", "unchanged")
        #expect(TakeChooseHeader.bandHelp(isChosen: false, label: nil) == TakeChooseHeader.chooseHelp)
        #expect(TakeChooseHeader.bandHelp(isChosen: true, label: nil) == TakeChooseHeader.chosenHelp)
        #expect(TakeChooseHeader.bandHelp(isChosen: false, label: Self.label)
                == Self.label + "\n" + TakeChooseHeader.chooseHelp, "the whole label, then the act")
        #expect(TakeChooseHeader.bandHelp(isChosen: true, label: Self.label)
                == Self.label + "\n" + TakeChooseHeader.chosenHelp)
    }

    /// A label with no separator is ONE part — exactly the face it had.
    @Test func aLabelWithNoSeparatorIsOnePart() throws {
        let label = "english, but longer than a narrow card"
        let tokens = VoiceTokens.terminalLight
        let at = try #require(placement(label, tokens, width: 120))
        #expect(at.placed.count == 1 && at.ideals.count == 1, "one part: \(at)")
        #expect(at.placed[0] < at.ideals[0], "cut at its tail, as before")
    }
}
