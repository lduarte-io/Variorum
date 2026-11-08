//
//  BookMastheadModeRowTests.swift
//  VariorumTests (Mac)
//
//  VX-887 (the VX-878 run, batch 4) — **the book masthead goes one line.**
//  Her rulings (2026-11-05): (1) the order dial joins the MODE ROW's one line,
//  the modes leading and the dial at the trailing end; (2) the doubled word
//  goes ("Manual order ▾", never "order · Manual order ▾"); (3) *"make sure
//  that when the area is more compressed that order still goes to the second
//  line smoothly"* — the Library controls-row law as the precedent: a
//  width-class decision at WHOLE POINTS from STABLE widths, never
//  `ViewThatFits`, so nothing but the width moves the line count.
//
//  An Improvement on her ask, so no red-on-old is owed; these pins and the
//  closing window's walk are its evidence:
//  - the rule, pure — one line at rest with the dial trailing, the wrap below
//    the width class, one answer per width whatever the dial shows and
//    whichever tab is active, one threshold, the dial never truncated on one
//    line, whole points in both passes, the ideal and minimum queries;
//  - the stable widths against SwiftUI's own measures of the REAL faces
//    (`BookModeTabLabel`, `BookOrderDial`) — and the dial's every name, the
//    doubled word gone;
//  - the row MOUNTED with the real faces — a resize sweep (up and down) whose
//    line count is the width's own answer, every order form and every active
//    tab at the threshold and a point under it, fractional widths;
//  - the book view MOUNTED — the masthead's row decides by the rule at
//    whatever width the host gives it, and a long title, every view order and
//    the mode switches never move its counted widths or its line count;
//  - the source legs — one Layout, no `ViewThatFits`, the tabs' action
//    identity (`switchMode(to: mode)` — VX-808's review close rides it), the
//    Arrivals door untouched.
//
//  The record: `notes/plans/fixes/vx-878-book-doors-faces.md` (BATCH 4 RECORD).
//
//  **VX-896 (the VX-914 run, batch 3 — A DELIBERATE RE-WRITE of this family's
//  threshold, her Nov 7 ruling):** *"it should go on the row above as soon as
//  it would have standard spacing that the others have, it's weird it needs
//  such a wide gap to go up."* The dial is counted at the face it SHOWS
//  (PROVISIONAL F-896 (1), ruled), no longer at the widest face it could ever
//  draw (R-878-K4's strict count, superseded). Old → new one-line thresholds
//  for "Manual order ▾" (pt of masthead): Study 257 → 240, Terminal 304 →
//  276; her -210400 seat (≈ 252, Study) was two lines and is one; the widest
//  face ("Major revision ↓ ▾") keeps 257 / 304 for itself. Each re-written pin
//  says so in place; every claim that does not depend on the counted face is
//  kept as it was (whole points, both passes, the active tab, the title, the
//  modes, the dial never truncated on one line). The ACCEPTED consequence is
//  pinned too: at a fixed width a wider LOOK can move the line count.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// One run-loop pump — a SYNC helper, because `RunLoop.run(until:)` is
/// unavailable from async contexts (BookRenameRepaintTests' shape).
@MainActor
private func pump(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

// MARK: - The rule, pure

@Suite("VX-887 — the masthead mode row's rule (pure)")
struct BookMastheadModeRowRuleTests {
    typealias Rule = BookMastheadModeRowRule

    /// A rigid tab row `width` wide (an `HStack` of fixed tabs answers its
    /// natural width at every offer).
    static func tabs(_ width: CGFloat) -> Rule.Child {
        Rule.Child(size: { _ in CGSize(width: width, height: 14) }, baseline: { _ in 11 })
    }

    /// The dial showing a face `ideal` wide — a truncating label: it takes
    /// its ideal, or what it is offered when that is less.
    static func dial(_ ideal: CGFloat) -> Rule.Child {
        Rule.Child(size: { offered in CGSize(width: min(ideal, offered ?? ideal), height: 14) },
                   baseline: { _ in 11 })
    }

    /// The voices' measured numbers (SwiftUI's own `sizeThatFits`, offscreen,
    /// the 11.5-pt `small` faces — the record's survey): the tab row, and the
    /// dial's every face ("Manual order", "Manual order ↓", the two entry
    /// dates, the two created, the two last touched, the two major revisions,
    /// "as collected", "book's order" — each with " ▾").
    struct Voice {
        var tabs: CGFloat
        var faces: [CGFloat]
        var widest: CGFloat { faces.max() ?? 0 }
    }

    static func measured(_ voice: ThemeVoice) -> Voice {
        switch voice {
        case .terminal: Voice(tabs: 168, faces: [100, 114, 100, 100, 79, 79, 114, 114, 128, 128, 100, 100])
        case .study: Voice(tabs: 151, faces: [81, 93, 78, 78, 65, 65, 93, 93, 98, 98, 75, 78])
        }
    }

    /// VX-896: the dial is COUNTED at the face it shows — `face` both draws
    /// and counts (the masthead hands the row the shown face's stable width).
    static func arrange(_ voice: Voice, face: CGFloat, width: CGFloat, tabsLive: CGFloat? = nil) -> Rule.Arrangement {
        Rule.arrange(
            width: width, tabs: tabs(tabsLive ?? voice.tabs), dial: dial(face),
            tabsWidth: voice.tabs, dialCounted: face)
    }

    /// Ruling 1, at rest: a wide masthead is ONE line — the modes at the
    /// leading edge, the dial at the trailing end, on the same line.
    @Test func aWideMastheadIsOneLineWithTheDialAtTheTrailingEnd() {
        let study = Self.measured(.study)
        let row = Self.arrange(study, face: 81, width: 300)
        #expect(row.widthClass == .oneLine && row.lineCount == 1)
        #expect(row.tabs.minX == 0 && row.tabs.minY == 0, "the modes lead")
        #expect(row.dial.maxX == 300, "the dial at the row's trailing end")
        #expect(row.dial.minY == row.tabs.minY, "on the modes' line")
        #expect(row.dial.width == 81, "the dial whole")
        #expect(row.size == CGSize(width: 300, height: 14))
    }

    /// Ruling 3: compressed, the dial wraps BELOW the modes — a second line,
    /// at the row's trailing end (PROVISIONAL D-887-2), the navigator's own
    /// 6-pt row spacing between.
    @Test func aCompressedMastheadWrapsTheDialBelowTheModes() {
        let study = Self.measured(.study)
        let row = Self.arrange(study, face: 81, width: 200)
        #expect(row.widthClass == .twoLines && row.lineCount == 2)
        #expect(row.tabs == CGRect(x: 0, y: 0, width: 151, height: 14))
        #expect(row.dial == CGRect(x: 200 - 81, y: 14 + Rule.lineSpacing, width: 81, height: 14),
                "\(row.dial)")
        #expect(row.size == CGSize(width: 200, height: 14 + Rule.lineSpacing + 14))
    }

    /// **One threshold per face, at that face's own counted line** (VX-896 —
    /// A DELIBERATE RE-WRITE: this pin said every face decided the same at
    /// every width, the dial counted at its widest). Every face the dial can
    /// show goes one line EXACTLY where the tabs + the standard gap + that
    /// face fit — two lines below, one line from there on, never back — so
    /// the air at its threshold is the standard spacing, and a narrower face
    /// joins the modes sooner than the widest.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func eachFaceGoesOneLineAtItsOwnCountedLine(voice: ThemeVoice) {
        let measured = Self.measured(voice)
        var wrong: [String] = []
        for face in Set(measured.faces) {
            var width: CGFloat = 120
            var seenOneLine = false
            var firstOneLine: CGFloat?
            var flips: [CGFloat] = []
            while width <= 480 {
                let oneLine = Self.arrange(measured, face: face, width: width).lineCount == 1
                if seenOneLine && !oneLine { flips.append(width) }
                if oneLine && firstOneLine == nil { firstOneLine = width }
                seenOneLine = seenOneLine || oneLine
                width += 0.25
            }
            let counted: CGFloat = Rule.countedLine(tabs: measured.tabs, dialCounted: face)
            if firstOneLine != counted || !flips.isEmpty {
                wrong.append("face \(face): one line from \(String(describing: firstOneLine)), not \(counted); flips \(flips.prefix(3))")
            }
        }
        #expect(wrong.isEmpty, "\(voice): \(wrong.prefix(4))")
        let manual = measured.faces[0]
        #expect(Rule.countedLine(tabs: measured.tabs, dialCounted: manual)
                < Rule.countedLine(tabs: measured.tabs, dialCounted: measured.widest),
                "\(voice): \"Manual order\" joins the modes before the widest face would")
    }

    /// **VX-896's ACCEPTED consequence, pinned** (the orchestrator's ruling,
    /// for her bundle): at a fixed width a LOOK whose face is wider than the
    /// room left can move the line count — the dial drops to its own line
    /// rather than sit closer than standard spacing or truncate — and the
    /// book's own order brings it back up. (R-878-K4's "a pick never moves
    /// the line count" is superseded at exactly this one input.)
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aWiderLookCanMoveTheLineCountAtAFixedWidth(voice: ThemeVoice) {
        let measured = Self.measured(voice)
        let manual = measured.faces[0]
        let widest = measured.widest
        let between = Rule.countedLine(tabs: measured.tabs, dialCounted: manual)
        #expect(Self.arrange(measured, face: manual, width: between).lineCount == 1, "\(voice): at rest, one line")
        #expect(Self.arrange(measured, face: widest, width: between).lineCount == 2,
                "\(voice): the widest look at the same width drops to its own line")
        #expect(Self.arrange(measured, face: widest, width: between).dial.width == widest,
                "\(voice): … whole, never truncated")
    }

    /// **Mode changes:** the active tab wears the semibold face, so the live
    /// tab row can read a point narrower or wider — the decision counts the
    /// stable (widest-active) width, so whichever tab is active, a width's
    /// answer is the same.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func whicheverTabIsActiveTheAnswerIsTheSame(voice: ThemeVoice) {
        let measured = Self.measured(voice)
        let lives: [CGFloat] = [measured.tabs - 1, measured.tabs - 0.5, measured.tabs]
        var unstable: [CGFloat] = []
        for width in stride(from: CGFloat(120), through: 480, by: 0.5) {
            let answers = Set(lives.map { Self.arrange(measured, face: 81, width: width, tabsLive: $0).lineCount })
            if answers.count != 1 { unstable.append(width) }
        }
        #expect(unstable.isEmpty, "\(voice): the active tab moved the decision at \(unstable.prefix(5))")
    }

    /// **A one-line row never squeezes the dial**: across every width and
    /// every face, on one line the dial shows its whole face, after at least
    /// the gap, and the row never overflows its width.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aOneLineRowNeverTruncatesTheDial(voice: ThemeVoice) {
        let measured = Self.measured(voice)
        var violations: [String] = []
        for width in stride(from: CGFloat(120), through: 480, by: 0.5) {
            for face in measured.faces {
                let row = Self.arrange(measured, face: face, width: width)
                guard row.widthClass == .oneLine else { continue }
                let whole = width.rounded(.down)
                if row.dial.width != face || row.dial.minX < row.tabs.maxX + Rule.gap - 0.01
                    || row.size.width > whole + 0.01 {
                    violations.append("\(width)/\(face): dial \(row.dial), row \(row.size)")
                }
            }
        }
        #expect(violations.isEmpty, "\(voice): \(violations.prefix(5))")
    }

    /// **Whole points, both passes:** the row decides at the offered width
    /// floored to a whole point and reports a whole width; placed at what it
    /// reported, it re-decides to EXACTLY the same arrangement — so the
    /// placement pass draws what the sizing pass measured, at any sub-point
    /// offer (a dragged navigator's width).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func whatTheSizingPassMeasuresThePlacementPassDraws(voice: ThemeVoice) {
        let measured = Self.measured(voice)
        var mismatches: [String] = []
        for width in stride(from: CGFloat(100.05), through: 460, by: 0.35) {
            for face in [measured.faces[0], measured.widest] {
                let sized = Self.arrange(measured, face: face, width: width)
                let placed = Self.arrange(measured, face: face, width: sized.size.width)
                if sized != placed || sized.size.width != sized.size.width.rounded(.down) {
                    mismatches.append("\(width)/\(face): \(sized.widthClass) \(sized.size.width) → \(placed.widthClass)")
                }
            }
        }
        #expect(mismatches.isEmpty, "\(voice): \(mismatches.prefix(5))")
        // The decision is at the whole point: half a point short of the
        // counted line is still two lines; the counted line plus a fraction
        // is one.
        // VX-896 (re-written deliberately): the counted line is the shown
        // face's — "Manual order" here.
        let face = measured.faces[0]
        let counted: CGFloat = Rule.countedLine(tabs: measured.tabs, dialCounted: face)
        #expect(Self.arrange(measured, face: face, width: counted - 0.5).widthClass == .twoLines)
        #expect(Self.arrange(measured, face: face, width: counted + 0.9).widthClass == .oneLine)
        #expect(Self.arrange(measured, face: face, width: counted + 0.9).size.width == counted)
    }

    /// The ideal query (no width offered) answers the COUNTED one-line width
    /// — so a host sizing the row at its ideal places one line there — and
    /// the minimum query (zero) is two lines as wide as the tab line (the
    /// tabs never wrap; the row's honest minimum).
    @Test func theIdealIsTheCountedLineAndTheMinimumIsTheTabLine() {
        let study = Self.measured(.study)
        // VX-896: the counted line is the shown face's (81 — "Manual order").
        let counted: CGFloat = Rule.countedLine(tabs: study.tabs, dialCounted: 81)
        let ideal = Self.arrange(study, face: 81, width: .infinity)
        #expect(ideal.widthClass == .oneLine && ideal.size.width == counted)
        #expect(Self.arrange(study, face: 81, width: ideal.size.width).widthClass == .oneLine)
        let minimum = Self.arrange(study, face: 81, width: 0)
        #expect(minimum.widthClass == .twoLines)
        #expect(minimum.size.width == study.tabs, "\(minimum.size)")
        // A room narrower than the tabs: the tab line sets the row's width,
        // and the dial's line is that wide (the both-passes rule holds there).
        let narrow = Self.arrange(study, face: 81, width: 140)
        #expect(narrow.size.width == study.tabs && narrow.dial.maxX == study.tabs)
    }

    /// **GUARD — the thresholds at the measured widths** (documents the
    /// margins; the rule is the pins above). **VX-896 — A DELIBERATE RE-WRITE,
    /// the old and new values named:** "Manual order ▾" (81 Study / 100
    /// Terminal) goes one line at Study 151 + 8 + 81 = **240** pt of masthead
    /// (was 257 — a navigator ≥ 264, was 281; its 12-pt sides) and Terminal
    /// 168 + 8 + 100 = **276** (was 304 — ≥ 300, was 328). Her screenshots'
    /// masthead widths (≈258 and ≈252 pt, Study): BOTH one line now (≈252 was
    /// two — the record's D-887-4, her VX-896 ask). The widest face, "Major
    /// revision ↓ ▾" (98 / 128), keeps the old numbers for itself (257 /
    /// 304); "as collected ▾" (75 / 100) goes at 234 / 276. The navigator's
    /// floor (166) still wraps in both voices.
    @Test func atTheMeasuredWidthsTheThresholdsAreTheCountedLines() {
        let study = Self.measured(.study)
        let terminal = Self.measured(.terminal)
        #expect(Self.arrange(study, face: 81, width: 240).widthClass == .oneLine, "Study: 257 → 240")
        #expect(Self.arrange(study, face: 81, width: 239).widthClass == .twoLines)
        #expect(Self.arrange(terminal, face: 100, width: 276).widthClass == .oneLine, "Terminal: 304 → 276")
        #expect(Self.arrange(terminal, face: 100, width: 275).widthClass == .twoLines)
        #expect(Self.arrange(study, face: 81, width: 258).widthClass == .oneLine, "her -204301 seat")
        #expect(Self.arrange(study, face: 81, width: 252).widthClass == .oneLine,
                "her -210400 seat — two lines before VX-896, one line now")
        #expect(Self.arrange(study, face: 98, width: 257).widthClass == .oneLine, "the widest face keeps 257")
        #expect(Self.arrange(study, face: 98, width: 256).widthClass == .twoLines)
        #expect(Self.arrange(terminal, face: 128, width: 304).widthClass == .oneLine, "… and 304")
        #expect(Self.arrange(terminal, face: 128, width: 303).widthClass == .twoLines)
        #expect(Self.arrange(study, face: 75, width: 234).widthClass == .oneLine, "as collected, Study")
        #expect(Self.arrange(study, face: 75, width: 233).widthClass == .twoLines)
        #expect(Self.arrange(study, face: 81, width: 166).widthClass == .twoLines, "the navigator's floor")
        #expect(Self.arrange(terminal, face: 100, width: 166).widthClass == .twoLines, "the navigator's floor")
        #expect(Self.arrange(terminal, face: 128, width: 336).widthClass == .oneLine, "the navigator's ceiling")
    }
}

// MARK: - The dial's names (pure)

@MainActor
@Suite("VX-887 — the order dial's names")
struct BookOrderDialNamesTests {
    /// Every field a stored order can name is the schema's: `sort_field`'s
    /// CHECK values (AppSpec §7) — so the dial's widest form is counted over
    /// every order a book can hold.
    @Test func everyFieldIsTheSchemasSortFields() {
        #expect(BookOrderChoices.everyField.map(\.rawValue)
                == ["manual", "entry_date", "created_at", "last_touched", "last_major_revision"])
    }

    /// D-887-3: an unlisted stored pair speaks the LIST's own names (the
    /// listed labels unchanged — `theOrderListIsTheRetiredSidebarsListVerbatim`).
    @Test func theUnlistedPairsSpeakTheListsOwnNames() {
        #expect(BookOrderChoices.label(for: .init(field: .lastTouched, direction: .asc)) == "Last touched ↑")
        #expect(BookOrderChoices.label(for: .init(field: .lastMajorRevision, direction: .asc)) == "Major revision ↑")
        #expect(BookOrderChoices.label(for: .init(field: .manual, direction: .desc)) == "Manual order ↓")
        for choice in BookOrderChoices.all {
            #expect(BookOrderChoices.label(for: choice.order) == choice.label)
        }
    }

    /// The set the dial's widest form is counted over: every field ×
    /// direction's name, the gathering's "as collected" and the not-yet-landed
    /// "book's order" — exactly the names `storedLabel` and the view order can
    /// produce.
    @Test func theDialsNamesAreEveryNameItCanShow() {
        let names = BookOrderChoices.everyName
        #expect(names.count == 12, "\(names)")
        #expect(Set(names).count == names.count, "no name twice")
        for choice in BookOrderChoices.all {
            #expect(names.contains(choice.label), "the listed \(choice.label)")
        }
        for name in ["as collected", "book's order", "Last touched ↑", "Major revision ↑", "Manual order ↓"] {
            #expect(names.contains(name), "\(name)")
        }
        #expect(BookOrderChoices.storedLabel(for: nil) == BookOrderChoices.unloadedName)
    }

    /// Ruling 2 — **the doubled word is gone**: the dial's face names the
    /// order alone, and no name the dial can show says "order" twice.
    @Test func theDialSaysOrderOnce() {
        let study = VoiceTokens.resolve(voice: .study, dark: false)
        let terminal = VoiceTokens.resolve(voice: .terminal, dark: false)
        #expect(BookOrderDial.face(study, order: "Manual order") == "Manual order \u{25BE}")
        #expect(BookOrderDial.face(terminal, order: "Manual order") == "manual order \u{25BE}")
        for name in BookOrderChoices.everyName {
            let face = BookOrderDial.face(study, order: name)
            let orders = face.lowercased().components(separatedBy: "order").count - 1
            #expect(orders <= 1, "\(face)")
            #expect(!face.contains("order \u{00B7}"), "\(face)")
        }
    }
}

// MARK: - The stable widths, against SwiftUI's own measures

@MainActor
@Suite("VX-887 — the mode row's stable widths (the controls-row law)")
struct BookMastheadStableWidthsTests {
    private static func ideal<V: View>(_ view: V) -> CGFloat {
        NSHostingController(rootView: view.fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 10_000)).width
    }

    /// VX-896: the stable widths for the masthead showing `order` (default
    /// "Manual order" — a fresh book's face).
    static func stable(_ tokens: VoiceTokens, order: String = "Manual order") -> BookMastheadStableWidths {
        BookMastheadStableWidths.row(
            tokens: tokens, in: EnvironmentValues().fontResolutionContext,
            face: BookOrderDial.face(tokens, order: order))
    }

    /// The tab row exactly as the book view builds it (`modeTab`'s plain
    /// Button around the one face), `active` the semibold tab.
    static func tabRow(_ tokens: VoiceTokens, active: BookStructureModel.ViewMode) -> some View {
        HStack(spacing: BookMastheadModeRowRule.tabSpacing) {
            ForEach(BookView.tabOrder, id: \.self) { mode in
                Button {} label: {
                    BookModeTabLabel(tokens: tokens, label: BookView.tabLabel(mode), active: mode == active)
                }
                .buttonStyle(.plain)
            }
        }
    }

    static func dial(_ tokens: VoiceTokens, stored: String, viewOrder: Queries.ReadingOrder? = nil) -> BookOrderDial {
        BookOrderDial(tokens: tokens, stored: stored, viewOrder: viewOrder, canSave: true,
                      onLook: { _ in }, onSave: { _ in })
    }

    /// The tab row is counted at its WIDEST active state: whichever tab is
    /// active, the real row measures no wider than the counted width, and the
    /// widest of them measures it (within the rounding).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theTabRowIsCountedAtItsWidestActiveState(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let counted = Self.stable(tokens).tabs
        var measured: [String: CGFloat] = [:]
        for mode in BookView.tabOrder {
            measured[BookView.tabLabel(mode)] = Self.ideal(Self.tabRow(tokens, active: mode))
        }
        let over = measured.filter { $0.value > counted + 0.5 }
        #expect(over.isEmpty, "\(voice): rows wider than the counted \(counted): \(over)")
        let top = measured.values.max() ?? 0
        #expect(abs(top - counted) < 1, "\(voice): the widest row \(top) vs the counted \(counted) — \(measured)")
    }

    /// **The dial is counted at the face it SHOWS** (VX-896 — A DELIBERATE
    /// RE-WRITE: this pin counted every face at the widest of them). Every
    /// name it can show — as the book's own order and as a look picked — is
    /// counted at its OWN stable width, which is the real control's measure
    /// within the rounding and never narrower than it (so one line never
    /// truncates it).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func everyFaceIsCountedAtItsOwnWidth(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        var wrong: [String] = []
        // VX-896: at a face's own threshold the dial is offered EXACTLY its
        // counted width, so the counted width must never be narrower than
        // the real control (else one line would truncate it there) — strict,
        // where the widest-face count could allow the precedent's half point.
        func check(_ label: String, counted: CGFloat, drawn: CGFloat) {
            if drawn > counted + 0.01 || abs(drawn - counted) >= 1 {
                wrong.append("\(label): drawn \(drawn) vs counted \(counted)")
            }
        }
        for name in BookOrderChoices.everyName {
            check(name, counted: Self.stable(tokens, order: name).dial,
                  drawn: Self.ideal(Self.dial(tokens, stored: name)))
        }
        for choice in BookOrderChoices.all {
            let shown = BookOrderDial.shownOrder(stored: "Manual order", viewOrder: choice.order)
            #expect(shown == choice.label, "a look names its own order")
            check("look: \(choice.label)", counted: Self.stable(tokens, order: shown).dial,
                  drawn: Self.ideal(Self.dial(tokens, stored: "Manual order", viewOrder: choice.order)))
        }
        #expect(wrong.isEmpty, "\(voice): \(wrong.prefix(5))")
    }

    /// GUARD — the numbers the pure suite's thresholds are written in (the
    /// record's survey), within a point: the tabs 151 Study / 168 Terminal;
    /// VX-896 — the dial counted at the shown face: "Manual order" 81 / 100,
    /// the widest ("Major revision ↓") 98 / 128.
    @Test func theStableWidthsAreTheSurveysNumbers() {
        let studyTokens = VoiceTokens.resolve(voice: .study, dark: false)
        let terminalTokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let study = Self.stable(studyTokens)
        let terminal = Self.stable(terminalTokens)
        #expect(abs(study.tabs - 151) < 1 && abs(study.dial - 81) < 1, "\(study)")
        #expect(abs(terminal.tabs - 168) < 1 && abs(terminal.dial - 100) < 1, "\(terminal)")
        #expect(abs(Self.stable(studyTokens, order: "Major revision \u{2193}").dial - 98) < 1)
        #expect(abs(Self.stable(terminalTokens, order: "Major revision \u{2193}").dial - 128) < 1)
    }
}

// MARK: - The row, mounted (the real layout and faces)

@MainActor
@Observable
fileprivate final class RowState {
    var active: BookStructureModel.ViewMode = .outline
    var stored = "Manual order"
    var viewOrder: Queries.ReadingOrder?
    /// The width the navigator's stack is offered — EXACTLY, sub-points
    /// included (a SwiftUI frame, never a window size the display rounds or
    /// a hosting view's minimum-size constraint clamps).
    var width: CGFloat = 166
}

/// The masthead's row as the book view composes it — the real layout, the
/// tab row built as `modeTab` builds it, the real dial — in a leading
/// `VStack` (the navigator's own stack, its 6-pt spacing), offered exactly
/// `state.width`.
private struct RowHarness: View {
    let tokens: VoiceTokens
    let key: String
    let state: RowState

    var body: some View {
        // VX-896: the row counts the face the dial SHOWS, as the book view
        // hands it.
        let stable = BookMastheadStableWidthsTests.stable(
            tokens, order: BookOrderDial.shownOrder(stored: state.stored, viewOrder: state.viewOrder))
        VStack(alignment: .leading, spacing: 6) {
            BookMastheadModeRow(tabsWidth: stable.tabs, dialCounted: stable.dial, probeKey: key) {
                BookMastheadStableWidthsTests.tabRow(tokens, active: state.active)
                BookMastheadStableWidthsTests.dial(tokens, stored: state.stored, viewOrder: state.viewOrder)
            }
            Spacer(minLength: 0)
        }
        .frame(width: state.width, alignment: .topLeading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

@MainActor
@Suite("VX-887 — the mode row, mounted with its real faces", .serialized)
struct BookMastheadModeRowMountedTests {
    typealias Rule = BookMastheadModeRowRule

    @MainActor
    fileprivate final class Rig {
        let window: NSWindow
        let hosting: NSView
        let key: String
        let state: RowState
        let tokens: VoiceTokens

        init(window: NSWindow, hosting: NSView, key: String, state: RowState, tokens: VoiceTokens) {
            self.window = window
            self.hosting = hosting
            self.key = key
            self.state = state
            self.tokens = tokens
        }

        /// VX-896: the stable widths for the face the dial shows NOW.
        var stable: BookMastheadStableWidths {
            BookMastheadStableWidthsTests.stable(
                tokens, order: BookOrderDial.shownOrder(stored: state.stored, viewOrder: state.viewOrder))
        }

        func settle(turns: Int = 4) async {
            for _ in 0..<turns {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump(0.01)
                await Task.yield()
            }
        }

        /// The navigator's width, as a drag sets it (the host window stays
        /// wider than every width swept).
        func resize(to width: CGFloat) async {
            state.width = width
            await settle()
        }

        #if DEBUG
        var placed: BookMastheadProbe.Placement? { BookMastheadProbe.placed[key] }
        #endif

        /// The line count the rule gives the width the row was placed at.
        func ruled(_ width: CGFloat) -> Int {
            Rule.widthClass(width: width, tabs: stable.tabs, dialCounted: stable.dial) == .oneLine ? 1 : 2
        }

        var counted: CGFloat { Rule.countedLine(tabs: stable.tabs, dialCounted: stable.dial) }
    }

    /// Ruling 1, mounted: at the navigator's ceiling (336 pt of masthead) the
    /// modes and the dial share ONE line — the dial at the trailing end, on
    /// the modes' line — in both voices.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheNavigatorsCeilingTheModesAndTheDialShareOneLine(voice: ThemeVoice) async throws {
        try await mount(voice: voice, width: 336) { rig in
            #if DEBUG
            let placed = try #require(rig.placed, "\(voice): the row reported its placement")
            let row = placed.arrangement
            #expect(row.lineCount == 1, "\(voice): one line at 336 (\(row))")
            #expect(abs(row.dial.maxX - row.size.width) < 0.5, "\(voice): the dial at the trailing end (\(row.dial) of \(row.size))")
            #expect(row.dial.minY < row.tabs.maxY && row.tabs.minY < row.dial.maxY, "\(voice): on the modes' line")
            #expect(row.dial.minX >= row.tabs.maxX + Rule.gap - 0.5, "\(voice): apart from the modes")
            #expect(BookMastheadProbe.dialFace[rig.key] == nil, "the harness records no book's face")
            #endif
        }
    }

    /// Ruling 3, mounted: at the navigator's floor (166 pt) the dial wraps
    /// below the modes, at the row's trailing end.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func atTheNavigatorsFloorTheDialWrapsBelowTheModes(voice: ThemeVoice) async throws {
        try await mount(voice: voice, width: 166) { rig in
            #if DEBUG
            let row = try #require(rig.placed, "\(voice): the row reported").arrangement
            #expect(row.lineCount == 2, "\(voice): two lines at 166 (\(row))")
            #expect(row.dial.minY >= row.tabs.maxY + Rule.lineSpacing - 0.5, "\(voice): below the modes (\(row))")
            #expect(abs(row.dial.maxX - row.size.width) < 0.5, "\(voice): at the trailing end")
            #endif
        }
    }

    /// **Resize — the line count is the width's own answer, both ways.** One
    /// mount, the host swept up across the navigator's whole range (and in
    /// half points through the threshold band) and back down: at every width
    /// the placed line count is the rule's at the whole point it decided, the
    /// row reports a whole width, and there is exactly ONE threshold each way
    /// — at the counted line, never a history-dependent flip.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aResizeSweepHasOneAnswerPerWidthBothWays(voice: ThemeVoice) async throws {
        try await mount(voice: voice, width: 166) { rig in
            #if DEBUG
            let band = stride(from: rig.counted - 6, through: rig.counted + 6, by: 0.5).map { $0 }
            let coarse = stride(from: CGFloat(160), through: 400, by: 8).map { $0 }
            let up = (coarse + band).sorted()
            var wrong: [String] = []
            var flips: [Int] = []
            for sweep in [up, Array(up.reversed())] {
                var last: Int?
                var changes = 0
                for width in sweep {
                    await rig.resize(to: width)
                    guard let placed = rig.placed else { wrong.append("\(width): no placement"); continue }
                    let lines = placed.arrangement.lineCount
                    if lines != rig.ruled(placed.decidedWidth) {
                        wrong.append("\(width): drew \(lines) at \(placed.decidedWidth)")
                    }
                    if placed.decidedWidth != placed.decidedWidth.rounded(.down) {
                        wrong.append("\(width): decided at a fraction \(placed.decidedWidth)")
                    }
                    if let last, last != lines { changes += 1 }
                    last = lines
                }
                flips.append(changes)
            }
            #expect(wrong.isEmpty, "\(voice): \(wrong.prefix(5))")
            #expect(flips == [1, 1], "\(voice): one threshold each way, not \(flips)")
            #endif
        }
    }

    /// **Every order form decides at its OWN counted line, and no active tab
    /// moves the line count** (VX-896 — A DELIBERATE RE-WRITE: this pin held
    /// every form to ONE count at the widest face). Mounted with the real
    /// faces: each name the dial can show — as the book's own order and as
    /// every look — draws one line at its own counted line (the tabs + the
    /// standard gap + its face) and two a point under it; at the book's own
    /// order's line, every active tab draws the same; and there, the WIDEST
    /// look drops the dial to its own line and the book's order brings it back
    /// — the accepted consequence, live.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func everyOrderFormDecidesAtItsOwnLineAndNoActiveTabMovesIt(voice: ThemeVoice) async throws {
        try await mount(voice: voice, width: 300) { rig in
            #if DEBUG
            var wrong: [String] = []
            @MainActor func expectLines(_ step: String, at width: CGFloat, _ expected: Int) async {
                await rig.resize(to: width)
                let lines = rig.placed?.arrangement.lineCount
                if lines != expected { wrong.append("\(step) at \(width): \(String(describing: lines))") }
            }
            for name in BookOrderChoices.everyName {
                rig.state.viewOrder = nil
                rig.state.stored = name
                await rig.settle()
                let line = rig.counted
                await expectLines("stored \(name)", at: line, 1)
                await expectLines("stored \(name)", at: line - 1, 2)
            }
            rig.state.stored = "Manual order"
            for choice in BookOrderChoices.all {
                rig.state.viewOrder = choice.order
                await rig.settle()
                let line = rig.counted
                await expectLines("look \(choice.label)", at: line, 1)
                await expectLines("look \(choice.label)", at: line - 1, 2)
            }
            rig.state.viewOrder = nil
            await rig.settle()
            let manualLine = rig.counted
            for (width, expected) in [(manualLine, 1), (manualLine - 1, 2)] {
                await rig.resize(to: width)
                for mode in BookView.tabOrder {
                    rig.state.active = mode
                    await rig.settle()
                    let lines = rig.placed?.arrangement.lineCount
                    if lines != expected { wrong.append("\(width) tab \(mode): \(String(describing: lines))") }
                }
            }
            rig.state.active = .outline
            // The accepted consequence: at the book's own order's line, the
            // widest look is two lines; back to the book's order, one.
            await rig.resize(to: manualLine)
            let widest = BookOrderChoices.all.max { a, b in
                BookMastheadStableWidthsTests.stable(rig.tokens, order: a.label).dial
                    < BookMastheadStableWidthsTests.stable(rig.tokens, order: b.label).dial
            }
            if let widest {
                rig.state.viewOrder = widest.order
                await rig.settle()
                if rig.placed?.arrangement.lineCount != 2 { wrong.append("the widest look \(widest.label) stayed up") }
                rig.state.viewOrder = nil
                await rig.settle()
                if rig.placed?.arrangement.lineCount != 1 { wrong.append("back to the book's order: not one line") }
            } else {
                wrong.append("no look to pick")
            }
            #expect(wrong.isEmpty, "\(voice): \(wrong.prefix(6))")
            #endif
        }
    }

    /// **A sub-point width places what it measured:** a host width half a
    /// point under the counted line decides at the whole point below it (two
    /// lines); a fraction over decides at the counted line (one line) — the
    /// row placed at the whole width it reported.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aFractionalWidthDecidesAtItsWholePoint(voice: ThemeVoice) async throws {
        try await mount(voice: voice, width: 300) { rig in
            #if DEBUG
            await rig.resize(to: rig.counted - 0.5)
            let under = try #require(rig.placed)
            #expect(under.decidedWidth == rig.counted - 1 && under.arrangement.lineCount == 2, "\(voice): \(under)")
            await rig.resize(to: rig.counted + 0.5)
            let over = try #require(rig.placed)
            #expect(over.decidedWidth == rig.counted && over.arrangement.lineCount == 1, "\(voice): \(over)")
            #expect(over.boundsWidth == over.decidedWidth, "\(voice): placed at the whole width it reported (\(over.boundsWidth))")
            #endif
        }
    }

    private func mount(voice: ThemeVoice, width: CGFloat, _ body: (Rig) async throws -> Void) async throws {
        #if DEBUG
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let key = "vx887-row-\(UUID().uuidString)"
        let state = RowState()
        state.width = width
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 520, height: 120),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        let hosting = NSHostingView(rootView: RowHarness(tokens: tokens, key: key, state: state))
        hosting.frame = NSRect(x: 0, y: 0, width: 520, height: 120)
        window.contentView = hosting
        window.orderFrontRegardless()
        defer {
            window.orderOut(nil)
            window.contentView = nil
            window.close()
            BookMastheadProbe.reset(key)
        }
        let rig = Rig(window: window, hosting: hosting, key: key, state: state, tokens: tokens)
        await rig.settle(turns: 8)
        try await body(rig)
        #endif
    }
}

// MARK: - The book's masthead, mounted (BookView)

@MainActor
private func withMastheadBook(
    voice: ThemeVoice,
    _ body: @MainActor (_ session: AppSession, _ readingID: String, _ model: BookViewModel,
                        _ structure: BookStructureModel, _ theme: ThemeStore) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    try await withDependencies {
        $0.database = db
        // The LIVE generator (OutlineRoomTests' reason): parallel suites
        // mounting books must never share a probe key.
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 887))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "app writing", kind: .book)
        let post = try session.operations.createPost(title: "about this text")
        _ = try session.operations.newBlock(in: post.id, text: "A line of prose in the book.")
        try session.operations.addPostToReading(post.id, to: reading.id)
        try session.operations.setThemeVoice(voice)
        let theme = ThemeStore(session: session)
        let observing = Task { await theme.start() }
        defer { observing.cancel() }
        let model = BookViewModel(session: session, readingID: reading.id)
        await model.adopt([Queries.ReadingEntry(
            postID: post.id, title: "about this text", entryDate: nil, sectionPath: nil)])
        let structure = BookStructureModel(session: session, readingID: reading.id)
        structure.adopt(.init(
            reading: try await db.read { [id = reading.id] in try Queries.reading($0, id: id) },
            sections: [], deletedSections: [], assignments: [:]))
        structure.mode = .outline
        try await body(session, reading.id, model, structure, theme)
    }
}

@MainActor
@Suite("VX-887 — the book's masthead, mounted", .serialized)
struct BookMastheadMountedTests {
    typealias Rule = BookMastheadModeRowRule

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 12, until done: () -> Bool = { false }) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if done() { return }
        }
    }

    /// **The masthead's row, at whatever width the host gives it, then
    /// through every state that must not move it.** The navigator's width is
    /// the host's (a remembered drag in the test host's own defaults, or the
    /// shipped 190) — so every claim is relative to the width actually
    /// placed: the line count is the rule's at that whole point, the dial
    /// sits on its line's trailing end, and a long title and the mode switches
    /// (Book, Read — the navigator host; Index — the index column's) never
    /// change the COUNTED widths, so at an unchanged width the line count
    /// never changes. **VX-896 (A DELIBERATE RE-WRITE):** the dial is counted
    /// at the face it DRAWS — every view order's counted width is its drawn
    /// face's stable width (so a look may move the line count; the pure and
    /// row suites pin that consequence), and back at the book's order the
    /// counted widths are the first ones again. The dial's face says "order"
    /// once.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theMastheadsRowIsTheWidthsOwnAnswerThroughEveryState(voice: ThemeVoice) async throws {
        try await withMastheadBook(voice: voice) { session, readingID, model, structure, theme in
            #if DEBUG
            BookMastheadProbe.reset(readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: .aqua)
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(theme))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
                BookMastheadProbe.reset(readingID)
            }
            await settle(window, hosting, turns: 40, until: {
                theme.settings.voice == voice && BookMastheadProbe.placed[readingID] != nil
            })
            await settle(window, hosting, turns: 4)
            let first = try #require(BookMastheadProbe.placed[readingID], "\(voice): the masthead's row placed")
            let tokens = theme.tokens(for: .light)
            let expectedStable = BookMastheadStableWidthsTests.stable(tokens)
            #expect(abs(first.tabsWidth - expectedStable.tabs) < 1 && abs(first.dialCounted - expectedStable.dial) < 1,
                    "\(voice): the row counts the voice's stable widths (\(first.tabsWidth)/\(first.dialCounted) vs \(expectedStable))")
            #expect(BookMastheadProbe.dialFace[readingID] == BookOrderDial.face(tokens, order: "Manual order"),
                    "\(voice): the dial names the order once (\(String(describing: BookMastheadProbe.dialFace[readingID])))")

            var wrong: [String] = []
            @MainActor func check(_ step: String, look: String? = nil) {
                guard let placed = BookMastheadProbe.placed[readingID] else {
                    wrong.append("\(step): no placement"); return
                }
                let row = placed.arrangement
                let ruled = Rule.widthClass(
                    width: placed.decidedWidth, tabs: placed.tabsWidth, dialCounted: placed.dialCounted)
                if row.widthClass != ruled { wrong.append("\(step): drew \(row.widthClass) at \(placed.decidedWidth)") }
                if placed.tabsWidth != first.tabsWidth {
                    wrong.append("\(step): the tabs' counted width moved (\(placed.tabsWidth))")
                }
                if let look {
                    // VX-896: a look is counted at the face it draws.
                    let drawn = BookMastheadStableWidthsTests.stable(tokens, order: look).dial
                    if abs(placed.dialCounted - drawn) >= 1 {
                        wrong.append("\(step): counted \(placed.dialCounted), not the drawn face's \(drawn)")
                    }
                } else if placed.dialCounted != first.dialCounted {
                    wrong.append("\(step): the dial's counted width moved (\(placed.dialCounted))")
                }
                if abs(row.dial.maxX - row.size.width) > 0.5 { wrong.append("\(step): the dial off the trailing end \(row.dial)") }
                if row.widthClass == .oneLine, row.dial.minY >= row.tabs.maxY {
                    wrong.append("\(step): one line but the dial below the modes")
                }
                if row.widthClass == .twoLines, row.dial.minY < row.tabs.maxY {
                    wrong.append("\(step): two lines but the dial beside the modes")
                }
                if placed.decidedWidth == first.decidedWidth, placed.dialCounted == first.dialCounted,
                   row.lineCount != first.arrangement.lineCount {
                    wrong.append("\(step): the line count moved at an unchanged width")
                }
            }
            check("at rest")

            // A long title (the title line truncates; the row never hears it).
            var renamed = try #require(structure.reading)
            renamed.name = String(repeating: "a very long book name ", count: 8)
            structure.adopt(.init(reading: renamed, sections: [], deletedSections: [], assignments: [:]))
            await settle(window, hosting, turns: 6)
            check("a long title")

            // Every view order (VX-896: the dial's face changes and its counted
            // width follows the face it draws).
            for choice in BookOrderChoices.all {
                model.viewOrder = choice.order
                await settle(window, hosting, turns: 4)
                check("look \(choice.label)", look: choice.label)
                if BookMastheadProbe.dialFace[readingID] != BookOrderDial.face(tokens, order: choice.label) {
                    wrong.append("look \(choice.label): the face drew \(String(describing: BookMastheadProbe.dialFace[readingID]))")
                }
            }
            model.viewOrder = nil
            await settle(window, hosting, turns: 4)
            check("back to the book's order")

            // The modes on the navigator host (the active tab moves), then
            // Index (the index column hosts the masthead), then back.
            for mode in [BookStructureModel.ViewMode.spread, .read, .outline] {
                structure.mode = mode
                await settle(window, hosting, turns: 8)
                check("mode \(mode)")
            }
            structure.mode = .index
            await settle(window, hosting, turns: 10)
            check("mode index (the index column)")
            #expect(wrong.isEmpty, "\(voice): \(wrong.prefix(6))")
            #endif
        }
    }
}

// MARK: - The source legs

@Suite("VX-887 — the masthead's source legs")
struct BookMastheadSourceTests {
    private static func code(_ relative: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let text = try String(contentsOf: root.appending(path: relative), encoding: .utf8)
        return text.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    /// One Layout over one set of views, never `ViewThatFits`; the dial drawn
    /// once, inside the row; the doubled word gone from the book view's code.
    @Test func theMastheadIsOneLayoutOverOneSetOfViews() throws {
        let book = try Self.code("Variorum/Features/BookView/BookView.swift")
        let row = try Self.code("Variorum/Features/BookView/BookMastheadModeRow.swift")
        #expect(book.components(separatedBy: "BookMastheadModeRow(").count == 2, "the row composed once")
        #expect(!book.contains("ViewThatFits") && !row.contains("ViewThatFits"))
        #expect(book.components(separatedBy: "orderControl").count == 3, "the dial: its definition and its one use")
        #expect(book.contains("            orderControl\n        }\n"), "the dial is the row's second view")
        #expect(!book.contains("order \u{00B7} "), "the doubled word is gone")
    }

    /// The tabs keep their ACTION IDENTITY — each tab's press is
    /// `switchMode(to: mode)`, the one road a mode press takes (VX-808's
    /// Arrivals review closes inside it) — and the title line's doors are
    /// untouched (the Arrivals door drawn once, the gear beside it).
    @Test func theTabsAndTheTitleLineKeepTheirRoads() throws {
        let book = try Self.code("Variorum/Features/BookView/BookView.swift")
        #expect(book.contains("Button {\n            switchMode(to: mode)\n        } label: {"))
        #expect(book.contains("modeTab(Self.tabLabel(mode), mode)"))
        #expect(book.components(separatedBy: "BookArrivalsDoor(model: arrivals, structure: structure)").count == 2)
        #expect(book.contains("Text(tokens.path([bookName]))"), "the title line as VX-804 pinned it")
    }
}
