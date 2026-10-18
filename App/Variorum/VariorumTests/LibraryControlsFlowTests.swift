//
//  LibraryControlsFlowTests.swift
//  VariorumTests (Mac)
//
//  VX-175 (the VX-283 run, U3 — P-U3-2 as RULED, 2026-10-15): at the app's
//  own 1240-pt default window with the info panel open, the Library's
//  controls row (search · scope · mode · sort ▾ · when ▾) was wider than the
//  list column — the search field squeezed to a sliver and the panel pushed
//  off the window's right edge (the 13n-c walk's F-R1-1: ≈92 pt Study, ≈136
//  pt Terminal at a 230-pt sidebar). THE MECHANISM: the row was one
//  `HStack(spacing: 10)` whose minimum width is the sum of its controls'
//  minimums (≈709 / ≈753 pt measured against a 617–631-pt room); an
//  overflowing HStack widens the column, and the column's HStack with the
//  panel overflows the window.
//
//  THE RULED FIX: `LibraryControlsFlow` — one line when it fits (placed
//  exactly as the HStack placed it), else search · scope over mode · sort ·
//  when, over ONE set of views; the wrap decision pure
//  (`LibraryControlsFlowRule`).
//
//  THE PINS: the rule, pure (guards — the HStack's own distribution, the
//  decision, both arrangements); and a GEOMETRY ORACLE — the real catalog
//  mounted at the default window's library width (1240 − the 210-pt sidebar
//  − its seam = 1029 pt) with the panel open, both voices: the panel stays
//  inside the window, the row inside the list column, the field at least
//  its own prompt's width. RED ON OLD by behavioural revert **R-L**
//  (`LibraryControlsFlow(spacing: 10, lineSpacing: 8) {` back to the old
//  `HStack(spacing: 10) {` in `LibraryCatalogView.header`): that cell. The
//  panel-closed and wide-window cells are GUARDS (one line, as before).
//
//  **U3b — P-U3-5, the orchestrator's ruling on the walk's W2** (F-1: typing
//  with the panel open collapsed the row to one line, the field a ~57-pt
//  sliver and the relevance label wrapped onto three lines; F-2: Terminal's
//  closed row at 1240 flipped on incidental state). THE MECHANISM: the
//  decision read the field's IDEAL — its cell's size, the typed text's width
//  once she types (211.5 → 40.5 pt in Terminal, measured offscreen) — and the
//  relevance label carried no line limit. THE RULED FIX: the decision reads
//  STABLE widths only — the field at its PROMPT (`fieldFloor`, a layout value
//  handed down), the sort slot at its WIDEST form (`sortWidest`) — and the
//  label holds one line. THE PINS ADDED: the rule's stability (one answer per
//  width whatever the slot shows, one threshold, the field never under its
//  floor on one line); the stable widths against SwiftUI's own measures; and,
//  mounted, typing with the panel open never changes the line count (the
//  walker's F-1) and one answer per width across typing, sorts and a sweep of
//  rooms through the old flip band (F-2). RED ON OLD by behavioural revert
//  **R-S** (the layout's floor read back from the field's own ideal, the
//  widest dropped, the relevance label's line policy removed).
//
//  **U3c — P-U3c-1, the orchestrator's ruling on the trace leg's T3** (the
//  sweep stayed red in a band: Terminal 940–960, Study 840–880). THE
//  MECHANISM, read off the probe's trace (`LibraryControlsU3cProbe` below):
//  the two SEGMENTED PICKERS answer in two modes in one model state — RIGID
//  (their minimum is their natural width: Terminal scope 262 / mode 224,
//  Study 264 / 230) or COMPRESSIBLE (the AppKit control squeezed: 228.5 /
//  180, Study 233 / 189); a landed search turns COMPRESSIBLE on, nothing the
//  cleared search does turns it off, a sort pick turns it off — moving the
//  width each picker takes at its share (and, in Study, the order the
//  distribution serves them). THE RULED FIX: each picker is fixed
//  horizontally before its frame, so it answers its ideal in every state.
//  THE PINS ADDED: mounted, a search never squeezes the segmented controls
//  and never flips the row (inside the old band, both voices); pure, the
//  rule over the probe's in-app widths — the default window one line closed,
//  the thresholds (a GUARD). RED ON OLD by behavioural revert **R-P** (the
//  two `fixedSize` lines deleted): the new mounted pin and the sweep.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, pure

@Suite("VX-175 — the controls row's flow rule (pure)")
struct LibraryControlsFlowRuleTests {
    typealias Rule = LibraryControlsFlowRule

    /// A control that takes any width in `lo…hi` (a flexible frame), with a
    /// fixed height — and, for the field, its prompt FLOOR; for the sort
    /// slot, the WIDEST it can read (P-U3-5).
    static func child(
        _ lo: CGFloat, _ hi: CGFloat, floor: CGFloat? = nil, widest: CGFloat? = nil, height: CGFloat = 24
    ) -> Rule.Child {
        Rule.Child(
            flexibility: hi - lo,
            width: { max(lo, min(hi, $0)) }, height: { _ in height },
            floor: floor, widest: widest)
    }

    /// The row's five controls in their order, at the harness's Terminal
    /// numbers: the field (a sliver floor, 320 cap, its prompt 211 wide),
    /// scope (228…280), mode (180…230), sort and when (fixed). *(U3b: the
    /// field's 211 is now its `floor` rather than its ideal, and the sort
    /// slot — "edited · newest first ▾", 174 — is counted at its widest,
    /// 181, "created · newest first ▾": P-U3-5, the numbers otherwise as U3
    /// pinned them.)*
    static var row: [Rule.Child] {
        Self.row(sort: 174)
    }

    /// The row with the sort slot showing a label `sort` wide.
    static func row(sort: CGFloat) -> [Rule.Child] {
        [child(75, 320, floor: 211, height: 22), child(228, 280), child(180, 230),
         child(sort, sort, widest: 181, height: 18), child(53, 53, height: 18)]
    }

    /// **The offscreen-measured rows** (U3b — NSHostingController in the
    /// voices' own `small` faces): the field at 0…320 with its prompt's floor
    /// (Terminal 211.5 · Study 175 — the empty field's own ideal), scope and
    /// mode at their narrowest…widest, the sort slot at its widest form
    /// (Terminal 181 · Study 134, "created · newest first ▾"), `when ▾`.
    static func measured(_ voice: ThemeVoice, sort: CGFloat? = nil) -> [Rule.Child] {
        switch voice {
        case .terminal:
            [child(0, 320, floor: 211.5, height: 22), child(228.5, 280), child(180, 230),
             child(sort ?? 174, sort ?? 174, widest: 181, height: 18), child(53, 53, height: 18)]
        case .study:
            [child(0, 320, floor: 175, height: 22), child(233, 280), child(189, 230),
             child(sort ?? 127, sort ?? 127, widest: 134, height: 18), child(48, 48, height: 18)]
        }
    }

    @Test func aWideLineGivesEveryControlItsWidestAsTheHStackDid() {
        #expect(Rule.distribute(Self.row, in: 1181, spacing: 10) == [320, 280, 230, 174, 53])
    }

    /// The HStack's order — the least flexible first, each an equal share of
    /// what is left — squeezes the FIELD first and the fixed doors never.
    @Test func aNarrowLineSqueezesTheFieldFirst() {
        let widths = Rule.distribute(Self.row, in: 900, spacing: 10)
        #expect(widths[3] == 174 && widths[4] == 53, "the fixed doors keep their words")
        #expect(widths[0] < 211, "the field is the one squeezed (\(widths))")
    }

    /// *(U3b — CHANGED IN PLACE BY THE RULING P-U3-5: the decision now takes
    /// the CHILDREN, with the field's floor and the sort slot's widest on
    /// them, rather than the line's widths and the field's live ideal. The
    /// three claims are the same.)*
    @Test func oneLineOnlyWhileTheFieldKeepsItsPromptAndTheLineFits() {
        #expect(Rule.fitsOneLine(Self.row, width: 1181, spacing: 10))
        #expect(!Rule.fitsOneLine(Self.row, width: 900, spacing: 10),
                "the field below its prompt — two lines")
        #expect(!Rule.fitsOneLine(Self.row, width: 700, spacing: 10),
                "the line wider than the room — two lines")
    }

    /// **P-U3-5 — one answer per width, whatever the sort slot shows.** Every
    /// form the slot can take (title · A–Z, date · …, edited · …, created · …,
    /// the relevance label) gives the SAME decision at every width — the
    /// slot is counted at its widest — and the decision has ONE threshold:
    /// two lines below it, one line from it on (never a flip back).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theDecisionIsOneAnswerPerWidthWhateverTheSortSlotShows(voice: ThemeVoice) {
        let forms: [CGFloat] = voice == .terminal ? [103, 157, 160, 174, 181] : [72, 112, 117, 127, 134]
        var width: CGFloat = 300
        var seenOneLine = false
        var flips: [CGFloat] = []
        var unstable: [CGFloat] = []
        while width <= 1400 {
            let answers = Set(forms.map { Rule.fitsOneLine(Self.measured(voice, sort: $0), width: width, spacing: 10) })
            if answers.count != 1 { unstable.append(width) }
            let answer = answers.contains(true)
            if seenOneLine && !answer { flips.append(width) }
            seenOneLine = seenOneLine || answer
            width += 0.5
        }
        #expect(unstable.isEmpty, "\(voice): the sort slot's words moved the decision at \(unstable.prefix(5))")
        #expect(flips.isEmpty, "\(voice): the row went back to two lines at \(flips.prefix(5))")
        #expect(seenOneLine, "\(voice): a wide room is one line")
    }

    /// **P-U3-5 — a line judged to fit places the field at its floor.** The
    /// decision counts the sort slot at its widest; the placement uses the
    /// slot's LIVE words, which are never wider — and in the HStack's order a
    /// narrower fixed label only leaves the field more. So across every width
    /// and every form, a one-line row never puts the field under its prompt
    /// and never overflows the room.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aOneLineRowNeverPutsTheFieldUnderItsFloor(voice: ThemeVoice) {
        let forms: [CGFloat] = voice == .terminal ? [103, 157, 160, 174, 181] : [72, 112, 117, 127, 134]
        let floor: CGFloat = voice == .terminal ? 211.5 : 175
        var width: CGFloat = 300
        var violations: [String] = []
        while width <= 1400 {
            for form in forms {
                let arranged = Rule.arrange(
                    Self.measured(voice, sort: form), lineOneCount: 2, width: width, spacing: 10, lineSpacing: 8)
                guard arranged.oneLine else { continue }
                if arranged.frames[0].width < floor - 0.5 || arranged.size.width > width + 0.5 {
                    violations.append("\(width)/\(form): field \(arranged.frames[0].width), row \(arranged.size.width)")
                }
            }
            width += 0.5
        }
        #expect(violations.isEmpty, "\(voice): \(violations.prefix(5))")
    }

    /// **At the offscreen-measured widths** (P-U3-5's "one stable answer per
    /// voice and panel state"): the default window with the panel OPEN (631
    /// pt for the row) is two lines in both voices; with it CLOSED (981 pt),
    /// one. The thresholds sit at ≈934 pt (Terminal) and ≈834 pt (Study) —
    /// the in-app Terminal row measures ≈20 pt wider than this harness (U3's
    /// first window: the field 222 where these numbers give 242), so a wider
    /// sidebar can take Terminal's closed row to two lines; stable either way.
    /// *(U3c — ANNOTATED, not rewritten: "≈934 / ≈834" are this OFFSCREEN
    /// harness's thresholds. In the app the segmented pickers measure wider —
    /// rigid at Terminal scope 262 / mode 224, Study 264 / 230, the U3c probe's
    /// reading (P-U3c-1 fixes them there) — and the "≈20 pt wider" Terminal row
    /// was the scope picker. The in-app thresholds, ≈977 (Terminal) and ≈891
    /// (Study), are pinned by `atTheProbesInAppWidthsTheDefaultWindowIsOneLineClosed`
    /// below; this pin keeps its own numbers.)*
    @Test func atTheMeasuredWidthsTheDefaultWindowHasOneAnswerPerPanelState() {
        for voice in [ThemeVoice.terminal, .study] {
            #expect(!Rule.fitsOneLine(Self.measured(voice), width: 631, spacing: 10), "\(voice): open — two lines")
            #expect(Rule.fitsOneLine(Self.measured(voice), width: 981, spacing: 10), "\(voice): closed — one line")
        }
        #expect(!Rule.fitsOneLine(Self.measured(.terminal), width: 930, spacing: 10))
        #expect(Rule.fitsOneLine(Self.measured(.terminal), width: 936, spacing: 10))
        #expect(!Rule.fitsOneLine(Self.measured(.study), width: 830, spacing: 10))
        #expect(Rule.fitsOneLine(Self.measured(.study), width: 836, spacing: 10))
    }

    /// **The IN-APP rows** (U3c — the probe's reading, `u3c/logs/probe-lines.txt`):
    /// the segmented pickers RIGID at their natural widths, as P-U3c-1 fixes
    /// them (Terminal scope 262…280 · mode 224…230; Study 264…280 · mode 230),
    /// the field 0…320 with its floor, the sort slot counted at its widest,
    /// `when ▾`.
    static func inApp(_ voice: ThemeVoice, sort: CGFloat? = nil) -> [Rule.Child] {
        switch voice {
        case .terminal:
            [child(0, 320, floor: 211.5, height: 22), child(262, 280), child(224, 230),
             child(sort ?? 174, sort ?? 174, widest: 181, height: 18), child(53, 53, height: 18)]
        case .study:
            [child(0, 320, floor: 175, height: 22), child(264, 280), child(230, 230),
             child(sort ?? 127, sort ?? 127, widest: 134, height: 18), child(48, 48, height: 18)]
        }
    }

    /// **GUARD (U3c, P-U3c-1) — the default window's answer at the in-app
    /// widths.** With the pickers rigid, the rule's thresholds are ≈977 pt of
    /// row (Terminal) and ≈891 (Study) — exactly 977.0 and 890.5 with the
    /// floor's half-point slack — so the 1240-pt default with a 210-pt sidebar
    /// (row 981) is ONE line closed in both voices (Terminal by ≈4 pt) and two
    /// lines open (631); the old band's rooms (Terminal 950, Study 860) are
    /// two lines; and the decision never flips back above its threshold. A
    /// guard, not red-on-old: the rule is unchanged by the fix — it documents
    /// the margin the default window keeps.
    @Test func atTheProbesInAppWidthsTheDefaultWindowIsOneLineClosed() {
        for voice in [ThemeVoice.terminal, .study] {
            #expect(Rule.fitsOneLine(Self.inApp(voice), width: 981, spacing: 10), "\(voice): closed — one line")
            #expect(!Rule.fitsOneLine(Self.inApp(voice), width: 631, spacing: 10), "\(voice): open — two lines")
        }
        #expect(!Rule.fitsOneLine(Self.inApp(.terminal), width: 950, spacing: 10), "the old band: two lines")
        #expect(!Rule.fitsOneLine(Self.inApp(.study), width: 860, spacing: 10), "the old band: two lines")
        #expect(!Rule.fitsOneLine(Self.inApp(.terminal), width: 976, spacing: 10))
        #expect(Rule.fitsOneLine(Self.inApp(.terminal), width: 978, spacing: 10))
        #expect(!Rule.fitsOneLine(Self.inApp(.study), width: 889, spacing: 10))
        #expect(Rule.fitsOneLine(Self.inApp(.study), width: 892, spacing: 10))
        for voice in [ThemeVoice.terminal, .study] {
            var width: CGFloat = 300
            var seenOneLine = false
            var flips: [CGFloat] = []
            while width <= 1400 {
                let answer = Rule.fitsOneLine(Self.inApp(voice), width: width, spacing: 10)
                if seenOneLine && !answer { flips.append(width) }
                seenOneLine = seenOneLine || answer
                width += 0.5
            }
            #expect(flips.isEmpty, "\(voice): back to two lines at \(flips.prefix(5))")
        }
    }

    /// The default window with the panel open (631 pt for the row): search ·
    /// scope over mode · sort · when, each line as the HStack places it.
    @Test func atTheDefaultWindowWithThePanelOpenTheRowWrapsAfterScope() {
        let arranged = Rule.arrange(Self.row, lineOneCount: 2, width: 631, spacing: 10, lineSpacing: 8)
        #expect(!arranged.oneLine)
        #expect(arranged.frames.map(\.minX) == [0, 330, 0, 240, 424])
        #expect(arranged.frames.map(\.width) == [320, 280, 230, 174, 53])
        #expect(arranged.frames[0].minY == 1 && arranged.frames[1].minY == 0, "line 1, centred on it")
        #expect(arranged.frames[2].minY == 32 && arranged.frames[3].minY == 35, "line 2, below the line spacing")
        #expect(arranged.size == CGSize(width: 610, height: 56))
        #expect(arranged.size.width <= 631, "the row fits the room")
    }

    /// A wide room: one line, every control where the HStack put it.
    @Test func aWideRoomIsOneLineExactlyAsBefore() {
        let arranged = Rule.arrange(Self.row, lineOneCount: 2, width: 1181, spacing: 10, lineSpacing: 8)
        #expect(arranged.oneLine)
        #expect(arranged.frames.map(\.minX) == [0, 330, 620, 860, 1044])
        #expect(arranged.size == CGSize(width: 1097, height: 24))
    }

    /// The default window with the panel CLOSED (981 pt): one line.
    @Test func theDefaultWindowWithThePanelClosedIsOneLine() {
        #expect(Rule.arrange(Self.row, lineOneCount: 2, width: 981, spacing: 10, lineSpacing: 8).oneLine)
    }

    /// The ideal query (no width offered) is one line at every control's
    /// widest; the minimum query (zero) is two lines at their narrowest — the
    /// row's honest minimum is its wider LINE, never the sum.
    @Test func theIdealIsOneLineAndTheMinimumIsTheWiderLine() {
        let ideal = Rule.arrange(Self.row, lineOneCount: 2, width: .infinity, spacing: 10, lineSpacing: 8)
        #expect(ideal.oneLine && ideal.size.width == 1097)
        let minimum = Rule.arrange(Self.row, lineOneCount: 2, width: 0, spacing: 10, lineSpacing: 8)
        #expect(!minimum.oneLine)
        // Typed CGFloat on purpose: left to itself, `max` of integer literals
        // is an `Int` inside `#expect`, and the macro's CGFloat-vs-Int
        // comparison answers false on equal values (the first window's red).
        let widerLine: CGFloat = max(75 + 10 + 228, 180 + 10 + 174 + 10 + 53)
        #expect(minimum.size.width == widerLine)
    }

    /// Timeline hides sort and when: line 2 is the mode alone.
    @Test func inTimelineLineTwoIsTheModeAlone() {
        let timeline = Array(Self.row.prefix(3))
        let arranged = Rule.arrange(timeline, lineOneCount: 2, width: 500, spacing: 10, lineSpacing: 8)
        #expect(!arranged.oneLine)
        #expect(arranged.frames[2].minX == 0 && arranged.frames[2].minY == 32)
        #expect(Rule.arrange(timeline, lineOneCount: 2, width: 900, spacing: 10, lineSpacing: 8).oneLine)
    }
}

// MARK: - The stable widths (P-U3-5), against SwiftUI's own measures

@MainActor
@Suite("VX-175 — the controls row's stable widths (P-U3-5)")
struct LibraryControlsStableWidthsTests {
    private static func ideal<V: View>(_ view: V) -> CGFloat {
        NSHostingController(rootView: view.fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 10_000)).width
    }

    private static func field(_ tokens: VoiceTokens, text: String) -> some View {
        TextField(tokens.chromeLabel(LibraryCatalogView.searchPrompt), text: .constant(text))
            .textFieldStyle(.roundedBorder)
            .font(tokens.small)
            .frame(maxWidth: LibraryCatalogView.searchFieldMaxWidth)
    }

    private static func stable(_ tokens: VoiceTokens) -> LibraryControlsStableWidths {
        LibraryControlsStableWidths.row(
            tokens: tokens, prompt: LibraryCatalogView.searchPrompt,
            fieldMaxWidth: LibraryCatalogView.searchFieldMaxWidth,
            in: EnvironmentValues().fontResolutionContext)
    }

    /// The voice's `small` face, resolved as the header resolves it.
    private static func smallFont(_ tokens: VoiceTokens) -> NSFont {
        tokens.small.resolve(in: EnvironmentValues().fontResolutionContext).ctFont as NSFont
    }

    /// The floor IS the empty field's own ideal (the width at which it shows
    /// its whole prompt) — and the TYPED field's ideal is not: it follows
    /// the text (F-1's mechanism, said as a fact so the floor can never
    /// quietly become that road again).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theFloorIsTheEmptyFieldsOwnIdealNeverTheTypedText(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let floor = Self.stable(tokens).fieldFloor
        let empty = Self.ideal(Self.field(tokens, text: ""))
        let typed = Self.ideal(Self.field(tokens, text: "wing"))
        #expect(abs(floor - empty) < 0.5, "\(voice): the floor \(floor) vs the empty field's ideal \(empty)")
        #expect(typed < floor - 50, "\(voice): typed text moves the field's ideal (\(typed) of \(floor))")
    }

    /// The sort slot is counted at its WIDEST: every form the slot can take —
    /// the `sort ▾` door at every sort × direction, the relevance label as
    /// the header draws it — measures no wider than `sortWidest`, and the
    /// widest of them measures exactly it (which keeps `voicedMenuChrome`
    /// and the rounding honest against the real door).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theSortSlotIsCountedAtItsWidestForm(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let widest = Self.stable(tokens).sortWidest
        var measured: [String: CGFloat] = [:]
        for sort in LibrarySortFace.offered {
            for direction in [SortDirection.desc, .asc] {
                let door = LibrarySortMenu(
                    tokens: tokens, sort: sort, direction: direction, onPick: { _ in }, onDirection: { _ in })
                measured[LibrarySortFace.doorLabel(sort, direction)] = Self.ideal(door)
            }
        }
        measured["relevance"] = Self.ideal(
            Text(tokens.chromeLabel(LibrarySearchCopy.relevance)).font(tokens.small).lineLimit(1))
        let over = measured.filter { $0.value > widest + 0.5 }
        #expect(over.isEmpty, "\(voice): forms wider than the counted \(widest): \(over)")
        let top = measured.values.max() ?? 0
        #expect(abs(top - widest) < 1, "\(voice): the widest form \(top) vs the counted \(widest) — \(measured)")
    }

    /// **The floor never asks more than the field's cap** (the VX-283
    /// ladder's R1-6 — a GUARD: no reachable red-on-old exists, since the
    /// prompt is one constant and both voices' `small` faces are fixed). Each
    /// voice's floor is within the cap, AND the prompt measured UNCLAMPED is
    /// already inside it — so the clamp does not engage today and the floor
    /// is still the width at which the field shows its whole prompt.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theFloorIsWithinTheFieldsCap(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let cap = LibraryCatalogView.searchFieldMaxWidth
        let floor = Self.stable(tokens).fieldFloor
        let whole = LibraryControlsStableWidths.measure(
            prompt: tokens.chromeLabel(LibraryCatalogView.searchPrompt), sortForms: [],
            font: Self.smallFont(tokens), fieldMaxWidth: .infinity).fieldFloor
        #expect(floor <= cap, "\(voice): the floor \(floor) within the field's cap \(cap)")
        #expect(whole <= cap, "\(voice): the whole prompt \(whole) fits the cap — the clamp is not engaged")
        #expect(abs(floor - whole) < 0.01, "\(voice): the floor \(floor) is the whole prompt \(whole)")
    }

    /// **A prompt measuring past the cap is clamped to it, so the row can
    /// still be one line** (R1-6's guard, by construction: red with the
    /// clamp removed from `measure`). The premise, stated: unclamped, such a
    /// floor exceeds anything the capped field can take, so the decision is
    /// false at EVERY width — the row pinned at two lines forever.
    @Test func aPromptPastTheCapIsClampedSoTheRowCanStillBeOneLine() {
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let cap = LibraryCatalogView.searchFieldMaxWidth
        let long = Array(repeating: tokens.chromeLabel(LibraryCatalogView.searchPrompt), count: 3)
            .joined(separator: " ")
        let unclamped = LibraryControlsStableWidths.measure(
            prompt: long, sortForms: [], font: Self.smallFont(tokens), fieldMaxWidth: .infinity).fieldFloor
        let clamped = LibraryControlsStableWidths.measure(
            prompt: long, sortForms: [], font: Self.smallFont(tokens), fieldMaxWidth: cap).fieldFloor
        #expect(unclamped > cap, "premise: the long prompt measures past the cap (\(unclamped))")
        #expect(clamped == cap, "the floor clamped at the cap (\(clamped))")
        func row(floor: CGFloat) -> [LibraryControlsFlowRule.Child] {
            var children = LibraryControlsFlowRuleTests.measured(.terminal)
            children[0] = LibraryControlsFlowRuleTests.child(0, cap, floor: floor, height: 22)
            return children
        }
        let widths = stride(from: CGFloat(300), through: 3000, by: 10)
        #expect(widths.allSatisfy { !LibraryControlsFlowRule.fitsOneLine(row(floor: unclamped), width: $0, spacing: 10) },
                "premise: unclamped, two lines at every width")
        #expect(LibraryControlsFlowRule.fitsOneLine(row(floor: clamped), width: 1400, spacing: 10),
                "clamped, a wide room is one line")
    }
}

// MARK: - The catalog, mounted (the geometry oracle)

@MainActor
@Suite("VX-175 — the Library's controls row fits the default window with the panel open", .serialized)
struct LibraryControlsGeometryTests {
    /// The library's width at the app's 1240-pt default window: the window −
    /// the sidebar's ideal − its seam (`LibraryBulkRowGeometryTests.room`'s
    /// arithmetic, one step earlier).
    static var defaultLibraryWidth: CGFloat {
        1240 - CGFloat(ShellSplit<EmptyView, EmptyView>.idealWidth)
            - ShellSplit<EmptyView, EmptyView>.dividerWidth
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        await Self.settle(window, hosting, seconds)
    }

    fileprivate static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The field's own ideal — its prompt, in the voice's small face (the
    /// header's construction).
    fileprivate static func promptWidth(_ tokens: VoiceTokens) -> CGFloat {
        let field = TextField(tokens.chromeLabel(LibraryCatalogView.searchPrompt), text: .constant(""))
            .textFieldStyle(.roundedBorder)
            .font(tokens.small)
            .frame(maxWidth: LibraryCatalogView.searchFieldMaxWidth)
        return NSHostingController(rootView: field.fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 10_000)).width
    }

    fileprivate struct Read {
        let root: CGRect
        let controls: CGRect
        let field: CGRect
        let panel: CGRect?
        let divider: CGRect?
        let prompt: CGFloat
        /// P-U3-5: the sort slot (the door, or the relevance label).
        var sortSlot: CGRect? = nil
    }

    private func mounted(
        voice: ThemeVoice, width: CGFloat, panelOpen: Bool, _ body: (Read) throws -> Void
    ) async throws {
        try await withCatalog(voice: voice, width: width, panelOpen: panelOpen) { rig in
            let read = try rig.read()
            print("[VX-175 controls] \(voice) · width \(width) · panel \(panelOpen) · root \(read.root) · controls \(read.controls) · field \(read.field) · panel \(String(describing: read.panel)) · prompt \(read.prompt)")
            try body(read)
        }
    }

    /// U3b: the mounted catalog, held open for a pin that changes its state
    /// (types, picks a sort, resizes) and reads the row after each change.
    @MainActor
    fileprivate final class Rig {
        let model: LibraryCatalogModel
        let window: NSWindow
        let hosting: NSView
        let tokens: VoiceTokens

        init(model: LibraryCatalogModel, window: NSWindow, hosting: NSView, tokens: VoiceTokens) {
            self.model = model
            self.window = window
            self.hosting = hosting
            self.tokens = tokens
        }

        func settle(_ seconds: TimeInterval = 0.35) async {
            await LibraryControlsGeometryTests.settle(window, hosting, seconds)
        }

        func read() throws -> Read {
            Read(
                root: try #require(LibraryPanelOracle.rootFrame, "the catalog reported its frame"),
                controls: try #require(LibraryPanelOracle.controlsFrame, "the controls row reported"),
                field: try #require(LibraryPanelOracle.searchFieldFrame, "the search field reported"),
                panel: LibraryPanelOracle.panelFrame,
                divider: LibraryPanelOracle.dividerFrame,
                prompt: LibraryControlsGeometryTests.promptWidth(tokens),
                sortSlot: LibraryPanelOracle.sortSlotFrame)
        }

        /// The library column at `width` (the window and the host with it).
        func resize(to width: CGFloat) async {
            window.setContentSize(NSSize(width: width, height: 700))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 700)
            await settle(0.5)
        }

        /// The question, through the field's own binding road (the model the
        /// field's text is bound to), and the search the field's setter runs.
        func ask(_ query: String) async {
            model.query = query
            await model.search()
            await settle()
        }

        /// A sort pick, as the `sort ▾` door makes it (its natural direction,
        /// then `direction` if given).
        func pick(_ sort: Queries.LibrarySort, _ direction: SortDirection? = nil) async {
            model.setSort(sort)
            if let direction { model.setDirection(direction) }
            await settle()
        }

        /// The mounted search field — the editable field showing the prompt.
        func searchField() -> NSTextField? {
            let prompt = tokens.chromeLabel(LibraryCatalogView.searchPrompt)
            func walk(_ view: NSView) -> NSTextField? {
                if let field = view as? NSTextField, field.isEditable, field.placeholderString == prompt {
                    return field
                }
                for sub in view.subviews { if let found = walk(sub) { return found } }
                return nil
            }
            return walk(hosting)
        }

        /// TYPING, for real: the field first responder, `chunk` inserted
        /// through its field editor — the binding's own road. Returns false
        /// if the keystrokes did not reach the model (the pin then says so).
        func type(_ chunk: String, into field: NSTextField) async -> Bool {
            let before = model.query
            window.makeKey()
            window.makeFirstResponder(field)
            guard let editor = field.currentEditor() as? NSTextView else { return false }
            editor.insertText(chunk, replacementRange: editor.selectedRange())
            await settle(0.6)
            return model.query == before + chunk
        }
    }

    /// The mount, held for `body`. The notes' titles carry several words, so
    /// a typed question matches every one of them and the row a click
    /// selected stays listed — the panel stays open while she types (the
    /// walker's F-1 state).
    fileprivate func withCatalog(
        voice: ThemeVoice, width: CGFloat, panelOpen: Bool, _ body: (Rig) async throws -> Void
    ) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx175-controls-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 175))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for index in 0..<6 {
                let note = try session.operations.createPost(title: "A note to pick from the listing \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            }
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            await model.search()
            LibraryPanelOracle.reset()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: width, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await settle(window, hosting, 1.2)
            if panelOpen {
                let first = try #require(model.listedNoteIDs.first, "the notes listed")
                model.clickNoteRow(first, modifiers: .none)
                await settle(window, hosting, 1.0)
            }
            let tokens = theme.tokens(for: .light)
            try await body(Rig(model: model, window: window, hosting: hosting, tokens: tokens))
        }
        #endif
    }

    /// **RED ON OLD (R-L).** The default window, the panel open: nothing is
    /// pushed off the window and the field is never a sliver.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheDefaultWindowWithThePanelOpenNothingIsPushedOff(voice: ThemeVoice) async throws {
        let width = Self.defaultLibraryWidth
        try await mounted(voice: voice, width: width, panelOpen: true) { read in
            let panel = try #require(read.panel, "\(voice): the info panel opened")
            #expect(read.root.width <= width + 0.5,
                    "\(voice): the catalog fits the window (\(read.root.width) of \(width) pt)")
            #expect(panel.maxX <= width + 0.5,
                    "\(voice): the panel's right edge stays inside the window (\(panel.maxX) of \(width) pt)")
            if let divider = read.divider {
                #expect(read.controls.maxX <= divider.minX + 0.5,
                        "\(voice): the controls stay in the list column (\(read.controls.maxX) vs the divider at \(divider.minX))")
            }
            #expect(read.field.width >= read.prompt - 0.5,
                    "\(voice): the search field keeps its own prompt's width (\(read.field.width) of \(read.prompt) pt)")
        }
    }

    /// GUARD: the default window with the panel closed — one line, as before.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheDefaultWindowWithThePanelClosedTheRowIsOneLine(voice: ThemeVoice) async throws {
        try await mounted(voice: voice, width: Self.defaultLibraryWidth, panelOpen: false) { read in
            #expect(read.controls.height < 40, "\(voice): one line (\(read.controls.height) pt tall)")
            #expect(read.field.width >= read.prompt - 0.5, "\(voice): the field whole (\(read.field.width))")
        }
    }

    /// GUARD: a wide window (1440 pt) — one line, the field at its 320 and the
    /// header's 24-pt inset, exactly as before.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atAWideWindowTheRowIsOneLineAsBefore(voice: ThemeVoice) async throws {
        let width = 1440 - CGFloat(ShellSplit<EmptyView, EmptyView>.idealWidth)
            - ShellSplit<EmptyView, EmptyView>.dividerWidth
        try await mounted(voice: voice, width: width, panelOpen: false) { read in
            #expect(read.controls.height < 40, "\(voice): one line (\(read.controls.height) pt tall)")
            #expect(abs(read.field.width - LibraryCatalogView.searchFieldMaxWidth) < 0.5,
                    "\(voice): the field at its 320 (\(read.field.width))")
            #expect(abs(read.field.minX - 24) < 0.5, "\(voice): at the header's inset (\(read.field.minX))")
        }
    }

    // MARK: U3b — P-U3-5, the walk's W2

    /// **RED ON OLD (R-S) — the walker's F-1, typed for real.** The default
    /// window, the panel open (two lines): keystrokes into the field — a
    /// word, then more words, until the question is longer than the prompt —
    /// never change the line count, never leave the field under its prompt,
    /// and the relevance label stays one line. (Before: the first word
    /// collapsed the row to one line, the field a sliver at the typed word's
    /// width, the label wrapped onto three lines.) Also the floor the row
    /// counts IS the mounted field's own empty measure (its cell's).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func typingWithThePanelOpenNeverChangesTheLineCount(voice: ThemeVoice) async throws {
        try await withCatalog(voice: voice, width: Self.defaultLibraryWidth, panelOpen: true) { rig in
            let field = try #require(rig.searchField(), "\(voice): the search field is mounted")
            let stable = LibraryControlsStableWidths.row(
                tokens: rig.tokens, prompt: LibraryCatalogView.searchPrompt,
                fieldMaxWidth: LibraryCatalogView.searchFieldMaxWidth,
                in: EnvironmentValues().fontResolutionContext)
            let own = try #require(field.cell?.cellSize.width)
            #expect(abs(stable.fieldFloor - own) < 0.5,
                    "\(voice): the counted floor \(stable.fieldFloor) is the mounted empty field's own \(own)")
            let before = try rig.read()
            #expect(before.controls.height > 40, "\(voice): the panel open — two lines (\(before.controls.height) pt)")
            var typed = ""
            for chunk in ["pick", " from", " listing", " note pick note"] {
                let reached = await rig.type(chunk, into: field)
                if !reached {
                    // The field editor's road did not reach the binding in
                    // this host — the same text through the binding itself,
                    // said so in the log (the layout reads the field's text
                    // either way).
                    print("[VX-175 U3b] \(voice): typing fell back to the binding for \"\(chunk)\"")
                    await rig.ask(typed + chunk)
                }
                typed += chunk
                let after = try rig.read()
                print("[VX-175 U3b typed] \(voice) · \"\(rig.model.query)\" · controls \(after.controls) · field \(after.field) · sort \(String(describing: after.sortSlot)) · panel \(String(describing: after.panel))")
                try #require(after.panel != nil, "\(voice): the panel stayed open while she typed \"\(typed)\"")
                #expect(abs(after.controls.height - before.controls.height) < 0.5,
                        "\(voice): \"\(typed)\" changed the line count (\(before.controls.height) → \(after.controls.height) pt)")
                #expect(after.field.width >= after.prompt - 0.5,
                        "\(voice): \"\(typed)\" left the field under its prompt (\(after.field.width) of \(after.prompt) pt)")
                let slot = try #require(after.sortSlot, "\(voice): the sort slot reported")
                #expect(slot.height <= 20, "\(voice): the relevance label is one line (\(slot.height) pt tall)")
                #expect(after.controls.maxX <= (after.divider?.minX ?? after.root.maxX) + 0.5,
                        "\(voice): the row stays in the list column")
            }
        }
    }

    /// The row's states the stability pins cycle through: the sort slot's
    /// narrowest and widest door forms and the default one, then a typed word
    /// and a question longer than the prompt (both through the field's
    /// binding road), then back to empty.
    private static let states: [(name: String, act: (Rig) async -> Void)] = [
        ("edited · newest", { await $0.pick(.lastTouched) }),
        ("title · A–Z", { await $0.pick(.title) }),
        ("created · newest", { await $0.pick(.createdAt) }),
        ("created · oldest", { await $0.pick(.createdAt, .asc) }),
        ("typed a word", { await $0.ask("pick") }),
        ("typed past the prompt", { await $0.ask("note pick from listing note pick") }),
        ("empty again", { await $0.ask("") }),
    ]

    /// **RED ON OLD (R-S) — the walker's F-2: one answer per width.** The
    /// panel CLOSED, the library column swept through the band where the old
    /// decision flipped (rooms of 760…1000 pt, in steps of 20): at every
    /// width the row's height is the same whatever the sort slot shows and
    /// whatever is typed; one line never leaves the field under its prompt.
    /// (Before: in the band, a short sort label made one line and a long
    /// one two; an empty field two and a typed word one.)
    @Test(arguments: [ThemeVoice.terminal, .study])
    func withThePanelClosedEachWidthHasOneLineCount(voice: ThemeVoice) async throws {
        try await withCatalog(voice: voice, width: Self.defaultLibraryWidth, panelOpen: false) { rig in
            var unstable: [String] = []
            for room in stride(from: CGFloat(760), through: 1000, by: 20) {
                await rig.resize(to: room + 48)
                var heights: [String: CGFloat] = [:]
                for state in Self.states {
                    await state.act(rig)
                    let read = try rig.read()
                    // The premise: the column really is this wide (a window
                    // that refused the resize would test one width thirteen
                    // times and prove nothing).
                    if abs(read.root.width - (room + 48)) > 1 {
                        unstable.append("\(room) \(state.name): the catalog is \(read.root.width) wide, not \(room + 48)")
                    }
                    heights[state.name] = read.controls.height
                    if read.controls.height < 40 && read.field.width < read.prompt - 0.5 {
                        unstable.append("\(room) \(state.name): one line, the field \(read.field.width) of \(read.prompt)")
                    }
                }
                let lines = Set(heights.values.map { ($0 * 2).rounded() / 2 })
                print("[VX-175 U3b sweep] \(voice) · room \(room) · heights \(heights.sorted { $0.key < $1.key })")
                if lines.count != 1 { unstable.append("\(room): \(heights.sorted { $0.key < $1.key })") }
            }
            #expect(unstable.isEmpty, "\(voice): the line count moved with state — \(unstable)")
        }
    }

    /// **RED ON OLD (R-S) — the panel OPEN at the default window: one answer.**
    /// Every sort × direction, the relevance label, a typed word and a
    /// question longer than the prompt: the row's height never moves (two
    /// lines), the field never under its prompt, the sort slot one line.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func withThePanelOpenTheDefaultWindowHasOneLineCount(voice: ThemeVoice) async throws {
        try await withCatalog(voice: voice, width: Self.defaultLibraryWidth, panelOpen: true) { rig in
            var acts = Self.states
            for sort in LibrarySortFace.offered {
                for direction in [SortDirection.desc, .asc] {
                    acts.append(("\(sort) \(direction)", { await $0.pick(sort, direction) }))
                }
            }
            var heights: [String: CGFloat] = [:]
            var faults: [String] = []
            for state in acts {
                await state.act(rig)
                let read = try rig.read()
                try #require(read.panel != nil, "\(voice): the panel stayed open through \(state.name)")
                heights[state.name] = read.controls.height
                if read.field.width < read.prompt - 0.5 {
                    faults.append("\(state.name): the field \(read.field.width) of \(read.prompt)")
                }
                if let slot = read.sortSlot, slot.height > 20 {
                    faults.append("\(state.name): the sort slot \(slot.height) pt tall")
                }
            }
            print("[VX-175 U3b open] \(voice) · heights \(heights.sorted { $0.key < $1.key })")
            #expect(Set(heights.values.map { ($0 * 2).rounded() / 2 }).count == 1,
                    "\(voice): the line count moved — \(heights.sorted { $0.key < $1.key })")
            #expect(faults.isEmpty, "\(voice): \(faults)")
        }
    }

    // MARK: U3c — P-U3c-1, the segmented pickers

    /// The mounted row's segmented controls (scope: four segments; mode:
    /// three) — AppKit's own views, found as the U3c probe found them.
    fileprivate static func segmentedControls(in view: NSView) -> [NSSegmentedControl] {
        var found: [NSSegmentedControl] = []
        func walk(_ view: NSView) {
            if let control = view as? NSSegmentedControl { found.append(control) }
            for sub in view.subviews { walk(sub) }
        }
        walk(view)
        return found
    }

    /// **RED ON OLD (R-P) — U3c, P-U3c-1: a search never squeezes the
    /// segmented controls, so it never flips the row.** The panel closed, ONE
    /// room per voice inside the old band (Terminal 950, Study 860 — the U3c
    /// probe's rooms); created · oldest, then a typed word, then the field
    /// cleared, then a sort pick (the probe's states 4, 5, 7, 8, through the
    /// sweep's own acts): the row's height never moves, and each segmented
    /// control draws at no less than its own natural (intrinsic) width.
    /// (Before: the landed search turned the pickers COMPRESSIBLE — the scope
    /// control drawn at 227 / 220.5 of its 254, Terminal — the row went to one
    /// line, and only the sort pick brought the two lines back.)
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aSearchNeverSqueezesTheSegmentedControlsOrFlipsTheRow(voice: ThemeVoice) async throws {
        let room: CGFloat = voice == .terminal ? 950 : 860
        try await withCatalog(voice: voice, width: Self.defaultLibraryWidth, panelOpen: false) { rig in
            await rig.resize(to: room + 48)
            let acts: [(name: String, act: (Rig) async -> Void)] = [
                ("created · oldest", { await $0.pick(.createdAt, .asc) }),
                ("typed a word", { await $0.ask("pick") }),
                ("empty again", { await $0.ask("") }),
                ("a sort pick", { await $0.pick(.lastTouched) }),
            ]
            var first: (name: String, height: CGFloat)?
            for step in acts {
                await step.act(rig)
                let read = try rig.read()
                // The premise: the column really is this wide.
                #expect(abs(read.root.width - (room + 48)) <= 1,
                        "\(voice) \(step.name): the catalog is \(read.root.width) wide, not \(room + 48)")
                let controls = Self.segmentedControls(in: rig.hosting)
                let faces = controls.map {
                    "\($0.label(forSegment: 0) ?? "?") \($0.frame.width) of \($0.intrinsicContentSize.width)"
                }
                print("[VX-175 U3c pin] \(voice) · room \(room) · \(step.name) · controls \(read.controls) · segmented \(faces)")
                #expect(controls.count == 2, "\(voice) \(step.name): both segmented controls are mounted (\(faces))")
                for control in controls {
                    #expect(control.frame.width >= control.intrinsicContentSize.width - 0.5,
                            "\(voice) \(step.name): a segmented control squeezed — \(control.label(forSegment: 0) ?? "?") drawn \(control.frame.width) of its \(control.intrinsicContentSize.width)")
                }
                if let first {
                    #expect(abs(read.controls.height - first.height) < 0.5,
                            "\(voice): \(step.name) changed the line count (\(first.name) \(first.height) → \(read.controls.height) pt)")
                } else {
                    first = (step.name, read.controls.height)
                }
            }
        }
    }
}

// MARK: - VX-350 — the Library at narrow widths (the VX-348 run, U3)

/// **VX-350 — the R-P/R-S harness extended to the narrow widths** (her words:
/// the side pane "is not adjusting, as you make the window smaller it just
/// gets steadily cut off"; the empty pill left of All is "just what search
/// collapses down to when the side pane is open"). THE MECHANISM (traced):
/// VX-175's row has two classes, and its narrowest — two lines — still needs
/// the field beside scope and mode · sort · when on one line (Terminal ≈478,
/// Study ≈432 of row); below that the row is wider than its column, the field
/// squeezes toward its own ≈75-pt sliver (the pill), and the column's minimum
/// (the row + 48) with the panel's fixed 280 overflows the catalog — the
/// panel is pushed past the window's edge, its Close with it.
///
/// THE PINS, RED ON OLD BY BEHAVIOUR (pre-fix APIs only — the U3b/U3c rig):
/// at rooms of 300…480 pt with the panel closed, every state (three sorts, a
/// typed word, a question past the prompt, empty again) — the row fits its
/// room, the field is never a pill (shown at its prompt, or not shown), one
/// line count per room; and at library widths of 1029 down to 560 with the
/// panel open — the catalog fits the window, the panel stays whole inside it
/// at no less than its floor, the controls stay left of its divider.
@MainActor
@Suite("VX-350 — the Library's controls and panel at narrow widths", .serialized)
struct VX350NarrowLibraryTests {
    private static let states: [(name: String, act: (LibraryControlsGeometryTests.Rig) async -> Void)] = [
        ("edited · newest", { await $0.pick(.lastTouched) }),
        ("title · A–Z", { await $0.pick(.title) }),
        ("created · oldest", { await $0.pick(.createdAt, .asc) }),
        ("typed a word", { await $0.ask("pick") }),
        ("typed past the prompt", { await $0.ask("note pick from listing note pick") }),
        ("empty again", { await $0.ask("") }),
    ]

    /// **RED ON OLD — the empty pill.** The panel closed, the library column
    /// swept through the narrow rooms: the row fits its room, the field is
    /// either not shown (placed outside the catalog) or at least its prompt
    /// wide, and every state gives the room ONE line count.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atNarrowRoomsTheFieldIsNeverAPillAndTheRowFits(voice: ThemeVoice) async throws {
        try await LibraryControlsGeometryTests().withCatalog(
            voice: voice, width: LibraryControlsGeometryTests.defaultLibraryWidth, panelOpen: false
        ) { rig in
            var faults: [String] = []
            for room in stride(from: CGFloat(300), through: 480, by: 20) {
                await rig.resize(to: room + 48)
                var heights: [String: CGFloat] = [:]
                for state in Self.states {
                    await state.act(rig)
                    let read = try rig.read()
                    if abs(read.root.width - (room + 48)) > 1 {
                        faults.append("\(room) \(state.name): the catalog is \(read.root.width) wide, not \(room + 48)")
                    }
                    heights[state.name] = read.controls.height
                    if read.controls.width > room + 0.5 {
                        faults.append("\(room) \(state.name): the row is \(read.controls.width) wide in a \(room)-pt room")
                    }
                    // The row keeps the header's 24-pt inset whatever else in
                    // the column (the search band's chips) outgrows the room.
                    if abs(read.controls.minX - (read.root.minX + 24)) > 0.5 {
                        faults.append("\(room) \(state.name): the row starts at \(read.controls.minX), not the header's inset")
                    }
                    let shown = read.field.maxX > read.root.minX
                    if shown && read.field.width < read.prompt - 0.5 {
                        faults.append("\(room) \(state.name): the field is a pill — \(read.field.width) of its \(read.prompt)")
                    }
                }
                let lines = Set(heights.values.map { ($0 * 2).rounded() / 2 })
                print("[VX-350 narrow] \(voice) · room \(room) · heights \(heights.sorted { $0.key < $1.key })")
                if lines.count != 1 { faults.append("\(room): the line count moved — \(heights.sorted { $0.key < $1.key })") }
            }
            #expect(faults.isEmpty, "\(voice): \(faults.prefix(8))")
        }
    }

    /// **RED ON OLD — the panel pushed off.** The panel open, the library
    /// narrowed from the default window's 1029 pt to 560: the catalog never
    /// grows past the window, the panel's right edge stays inside it at no
    /// less than its floor (200 pt), and the controls row stays left of the
    /// panel's divider — the list column, never the panel, gives way.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atNarrowWindowsThePanelStaysWhole(voice: ThemeVoice) async throws {
        try await LibraryControlsGeometryTests().withCatalog(
            voice: voice, width: LibraryControlsGeometryTests.defaultLibraryWidth, panelOpen: true
        ) { rig in
            var faults: [String] = []
            for width: CGFloat in [1029, 900, 800, 700, 640, 600, 560] {
                await rig.resize(to: width)
                let read = try rig.read()
                guard let panel = read.panel else {
                    faults.append("\(width): the panel closed")
                    continue
                }
                print("[VX-350 panel] \(voice) · width \(width) · root \(read.root) · panel \(panel) · controls \(read.controls) · divider \(String(describing: read.divider))")
                if read.root.width > width + 0.5 { faults.append("\(width): the catalog is \(read.root.width) wide") }
                if panel.maxX > width + 0.5 { faults.append("\(width): the panel ends at \(panel.maxX), past the window") }
                if panel.width < 200 - 0.5 { faults.append("\(width): the panel is \(panel.width), under its floor") }
                if let divider = read.divider, read.controls.maxX > divider.minX + 0.5 {
                    faults.append("\(width): the controls end at \(read.controls.maxX), past the divider at \(divider.minX)")
                }
            }
            #expect(faults.isEmpty, "\(voice): \(faults)")
        }
    }
}

// MARK: - U3c — the trace leg's probe (env-gated; asserts nothing)

/// **VX-283 U3c — the closed-panel band, probed** (the record's "U3c — THE
/// ORCHESTRATOR'S RULING ON THE CLOSED-PANEL RED", T2). The sweep above
/// (`withThePanelClosedEachWidthHasOneLineCount`) found a band — Terminal
/// 940–960, Study 840–880 — where the four sort states read TWO lines and a
/// typed word, a question past the prompt and EMPTY AGAIN read ONE; "empty
/// again" is the same view state as "created · oldest" (the field empty, the
/// door shown, the same sort), so the row's answer followed its history.
///
/// This replays the sweep's road at ONE room per voice inside the band
/// (Terminal 950, Study 860) through the sweep's own mount and acts, and
/// prints per state: the model's facts (`isSearching`, the slot's branch,
/// the query, the sort, the read generations), the row's height as the
/// SWEEP read it (right after the act's own settle) and again after a settle
/// that waits for the search to land and the row to hold still; AppKit's own
/// account of the two segmented controls and the field (frame, intrinsic and
/// fitting widths, distribution, segment widths); and the layout's trace
/// (`LibraryControlsFlowTrace`, DEBUG): every distinct arrangement computed
/// since the act — its pass and proposal, the decision's steps (each child's
/// offered share and what it took), its answer, the frames, and every
/// child's narrowest / widest / flexibility / ideal / floor / widest.
///
/// Three roads, the same states: `fromBelow` (the sweep's approach — the room
/// reached from a narrower, two-line room), `fromAbove` (the room reached
/// straight from the mount's wide one-line room — does the starting line
/// count persist?), and `fromBelowUntraced` (the sweep's approach with the
/// trace OFF, so the layout runs byte-for-byte as in use — does tracing
/// perturb the band?). The states: the sweep's seven, verbatim, then the
/// ruling's sort pick after "empty again", then a relayout at the same width
/// with no state change (an addition: a resize away and back — does a fresh
/// proposal alone bring the two lines back?).
///
/// Run with `TEST_RUNNER_VARIORUM_U3C_PROBE=1`; every line is prefixed
/// `[VX-175 U3c`. Asserts nothing: a trace leg's instrument.
@MainActor
@Suite("VX-175 U3c — the closed-panel band, probed (env-gated; asserts nothing)", .serialized,
       .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_U3C_PROBE"] != nil))
struct LibraryControlsU3cProbe {
    fileprivate typealias Rig = LibraryControlsGeometryTests.Rig

    /// One room per voice inside the sweep's band (the row's width, as the
    /// sweep names it: the catalog is this + the header's 2 × 24).
    static func room(_ voice: ThemeVoice) -> CGFloat { voice == .terminal ? 950 : 860 }

    /// The sweep's seven states VERBATIM (`LibraryControlsGeometryTests.states`
    /// is private to its suite), then the ruling's sort pick after "empty
    /// again", then the relayout at the same width.
    fileprivate static func states(room: CGFloat) -> [(name: String, act: (Rig) async -> Void)] {
        [
            ("edited · newest", { await $0.pick(.lastTouched) }),
            ("title · A–Z", { await $0.pick(.title) }),
            ("created · newest", { await $0.pick(.createdAt) }),
            ("created · oldest", { await $0.pick(.createdAt, .asc) }),
            ("typed a word", { await $0.ask("pick") }),
            ("typed past the prompt", { await $0.ask("note pick from listing note pick") }),
            ("empty again", { await $0.ask("") }),
            ("sort pick after empty again (edited · newest)", { await $0.pick(.lastTouched) }),
            ("relayout at the same width (resize +20, back)", { rig in
                await rig.resize(to: room + 48 + 20)
                await rig.resize(to: room + 48)
            }),
        ]
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func fromBelow(voice: ThemeVoice) async throws {
        try await probe(voice: voice, road: "fromBelow", traced: true)
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func fromAbove(voice: ThemeVoice) async throws {
        try await probe(voice: voice, road: "fromAbove", traced: true)
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func fromBelowUntraced(voice: ThemeVoice) async throws {
        try await probe(voice: voice, road: "fromBelowUntraced", traced: false)
    }

    /// The trace's lines since the last state (nonisolated: the layout's
    /// trace sink is called from its nonisolated entry points, on the main
    /// thread).
    private nonisolated final class Buffer {
        var lines: [String] = []
    }

    private func probe(voice: ThemeVoice, road: String, traced: Bool) async throws {
        #if DEBUG
        let room = Self.room(voice)
        let tag = "[VX-175 U3c] \(voice) · \(road) · room \(room)"
        try await LibraryControlsGeometryTests().withCatalog(
            voice: voice, width: LibraryControlsGeometryTests.defaultLibraryWidth, panelOpen: false
        ) { rig in
            let buffer = Buffer()
            if traced { LibraryControlsFlowTrace.sink = { buffer.lines.append($0) } }
            defer { LibraryControlsFlowTrace.sink = nil }
            try report(rig, tag: tag, step: "mount (row \(LibraryControlsGeometryTests.defaultLibraryWidth - 48))",
                       sweepRead: nil, loops: 0, buffer: buffer)
            if road != "fromAbove" {
                // The sweep reached each room from the room 20 below, where
                // every state read two lines; 40 below is two lines in both
                // voices on the sweep's own log (Terminal 910 — between 900
                // and 920; Study 820).
                buffer.lines = []
                await rig.resize(to: room - 40 + 48)
                await rig.pick(.lastTouched)
                let loops = await settleLanded(rig)
                try report(rig, tag: tag, step: "pre-room \(room - 40) · edited · newest",
                           sweepRead: nil, loops: loops, buffer: buffer)
            }
            buffer.lines = []
            await rig.resize(to: room + 48)
            let loops = await settleLanded(rig)
            try report(rig, tag: tag, step: "resized to the room", sweepRead: nil, loops: loops, buffer: buffer)
            for (index, state) in Self.states(room: room).enumerated() {
                buffer.lines = []
                await state.act(rig)
                // What the sweep read: the act's own settle, then the read.
                let sweepRead = LibraryPanelOracle.controlsFrame
                let loops = await settleLanded(rig)
                try report(rig, tag: tag, step: "state \(index + 1) \"\(state.name)\"",
                           sweepRead: sweepRead, loops: loops, buffer: buffer)
            }
        }
        #endif
    }

    /// **The settle that waits for the search to land:** at least two more
    /// of the rig's own settles, until no read is in flight (the listed
    /// answer is the newest question's) and the row's frame held still
    /// across the last two — at most twelve.
    private func settleLanded(_ rig: Rig) async -> Int {
        var loops = 0
        var last: CGRect?
        while loops < 12 {
            await rig.settle()
            loops += 1
            let now = LibraryPanelOracle.controlsFrame
            if loops >= 2, now == last, rig.model.listedGeneration == rig.model.searchGeneration { break }
            last = now
        }
        return loops
    }

    private func report(
        _ rig: Rig, tag: String, step: String, sweepRead: CGRect?, loops: Int, buffer: Buffer
    ) throws {
        let model = rig.model
        let read = try rig.read()
        let slot = !model.showsCatalogControls ? "none (timeline)" : (model.isSearching ? "relevance label" : "sort door")
        let sweep = sweepRead.map { "\(LibraryControlsFlowTrace.text($0.height)) pt" } ?? "—"
        print("\(tag) · \(step) · isSearching \(model.isSearching) · slot \(slot) · query \"\(model.query)\""
              + " · sort \(model.sort) \(model.direction) · generations \(model.searchGeneration)/\(model.listedGeneration)"
              + " · height as the sweep read it \(sweep) · after \(loops) landed settles \(LibraryControlsFlowTrace.text(read.controls.height)) pt"
              + " · controls \(read.controls) · field \(read.field) · slot \(String(describing: read.sortSlot))"
              + " · root \(read.root.width) · prompt \(read.prompt)")
        print("[VX-175 U3c ax] \(step) · \(Self.appKitFacts(rig.hosting))")
        var counts: [String: Int] = [:]
        var order: [String] = []
        for line in buffer.lines {
            if counts[line] == nil { order.append(line) }
            counts[line, default: 0] += 1
        }
        print("[VX-175 U3c flow] \(step) · \(buffer.lines.count) arrangements, \(order.count) distinct")
        for line in order { print("[VX-175 U3c flow]   ×\(counts[line] ?? 0) \(line)") }
        if let lastLine = buffer.lines.last { print("[VX-175 U3c flow]   LAST \(lastLine)") }
    }

    /// AppKit's own account of the controls behind the row: the segmented
    /// controls (scope: four segments; mode: three) and the search field.
    private static func appKitFacts(_ hosting: NSView) -> String {
        var segmented: [NSSegmentedControl] = []
        var fields: [NSTextField] = []
        func walk(_ view: NSView) {
            if let control = view as? NSSegmentedControl { segmented.append(control) }
            if let field = view as? NSTextField, field.isEditable { fields.append(field) }
            for sub in view.subviews { walk(sub) }
        }
        walk(hosting)
        func f(_ value: CGFloat) -> String { LibraryControlsFlowTrace.text(value) }
        let distributions = ["fit", "fill", "fillEqually", "fillProportionally"]
        let segs = segmented.map { control -> String in
            let widths = (0..<control.segmentCount).map { f(control.width(forSegment: $0)) }
            let labels = (0..<control.segmentCount).map { control.label(forSegment: $0) ?? "?" }
            let distribution = control.segmentDistribution.rawValue
            return "seg\(labels) frame \(f(control.frame.width)) intrinsic \(f(control.intrinsicContentSize.width))"
                + " fitting \(f(control.fittingSize.width))"
                + " dist \(distribution < distributions.count ? distributions[distribution] : "\(distribution)")"
                + " widths \(widths) font \(control.font?.fontName ?? "nil") \(f(control.font?.pointSize ?? 0))"
                + " size \(control.controlSize.rawValue)"
        }
        let texts = fields.map { field -> String in
            "field \"\(field.placeholderString ?? "")\" text \(field.stringValue.count) chars frame \(f(field.frame.width))"
                + " intrinsic \(f(field.intrinsicContentSize.width)) cell \(f(field.cell?.cellSize.width ?? -1))"
                + " editing \(field.currentEditor() != nil)"
        }
        return (segs.isEmpty ? ["no NSSegmentedControl found"] : segs).joined(separator: " | ")
            + " || " + (texts.isEmpty ? "no editable NSTextField found" : texts.joined(separator: " | "))
    }
}
