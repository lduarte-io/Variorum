//
//  VX350ControlsWidthClassTests.swift
//  VariorumTests (Mac)
//
//  **VX-350 (the VX-348 run, U3) — the Library at narrow widths: the new
//  seam's own pins, pure.** Her words: the side pane "is not adjusting, as
//  you make the window smaller it just gets steadily cut off"; the empty pill
//  is "just what search collapses down to when the side pane is open"; "it
//  should at least turn into a search icon like magnifying glass and clicking
//  on it should still do something, even if just opening it in the pane
//  below."
//
//  The rule (`LibraryControlsFlowRule.widthClass` / `arrangeRow`) on VX-175's
//  base — ONE Layout, never `ViewThatFits`; the class read from STABLE widths
//  only (P-U3-5): one line → two lines (VX-175's ruled (C)) → COLLAPSED (🔍 ·
//  scope / mode · sort · when, each group wrapping in its own order, the field
//  on its own last line while she has it open). The panel's width rule
//  (`LibraryPanelLayout`) beside it.
//
//  New API — not in the red product. The red-on-old pins are the mounted ones
//  (`VX350NarrowLibraryTests`, in `LibraryControlsFlowTests.swift`).
//

import CoreGraphics
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-350 — the controls row's width classes (pure)")
struct VX350ControlsWidthClassTests {
    typealias Rule = LibraryControlsFlowRule
    typealias Flow = LibraryControlsFlowRuleTests

    /// The 🔍 door: rigid, its one size.
    static var toggle: Rule.Child {
        Flow.child(LibrarySearchToggle.size.width, LibrarySearchToggle.size.width,
                   height: LibrarySearchToggle.size.height)
    }

    /// The in-app row (U3c's probe numbers, P-U3c-1's rigid pickers) by role,
    /// the sort slot showing `sort` (counted at its widest either way).
    static func row(_ voice: ThemeVoice, sort: CGFloat? = nil, timeline: Bool = false) -> Rule.Row {
        let flat = Flow.inApp(voice, sort: sort)
        return Rule.Row(field: flat[0], toggle: toggle, scope: flat[1],
                        rest: timeline ? [flat[2]] : Array(flat[2...]))
    }

    static let forms: [ThemeVoice: [CGFloat]] = [
        .terminal: [103, 157, 160, 174, 181],
        .study: [72, 112, 117, 127, 134],
    ]

    /// The order a narrowing width walks the classes in.
    static func rank(_ widthClass: Rule.WidthClass) -> Int {
        switch widthClass {
        case .collapsed: 0
        case .twoLines: 1
        case .oneLine: 2
        }
    }

    /// **One class per width, whatever the sort slot shows — and one walk.**
    /// Over 200…1400 pt by half points: every sort form gives the same class
    /// at every width (the slot counted at its widest), and as the width grows
    /// the class only widens (collapsed → two lines → one line, never back).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func oneClassPerWidthWhateverTheSortSlotShows(voice: ThemeVoice) {
        var width: CGFloat = 200
        var last = -1
        var unstable: [CGFloat] = []
        var backwards: [CGFloat] = []
        while width <= 1400 {
            let classes = Set((Self.forms[voice] ?? []).map {
                Self.rank(Rule.widthClass(Self.row(voice, sort: $0), width: width, spacing: 10))
            })
            if classes.count != 1 { unstable.append(width) }
            let now = classes.max() ?? 0
            if now < last { backwards.append(width) }
            last = max(last, now)
            width += 0.5
        }
        #expect(unstable.isEmpty, "\(voice): the slot's words moved the class at \(unstable.prefix(5))")
        #expect(backwards.isEmpty, "\(voice): the class narrowed as the width grew at \(backwards.prefix(5))")
    }

    /// **The two wide classes are VX-175's row, frame for frame** — the 🔍
    /// not shown. (A wide window is byte-for-byte as before.)
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theWideClassesAreVX175sArrangeFrameForFrame(voice: ThemeVoice) {
        for width in stride(from: CGFloat(500), through: 1400, by: 7) {
            let row = Self.row(voice)
            let placed = Rule.arrangeRow(row, width: width, spacing: 10, lineSpacing: 8, searchOpen: false)
            guard placed.widthClass != .collapsed else { continue }
            let old = Rule.arrange(Flow.inApp(voice), lineOneCount: 2, width: width, spacing: 10, lineSpacing: 8)
            #expect(placed.frames[1] == nil, "\(voice) \(width): the 🔍 is not shown in a wide class")
            #expect(placed.frames[0] == old.frames[0] && placed.frames[2] == old.frames[1]
                    && Array(placed.frames[3...]) == old.frames[2...].map { Optional($0) },
                    "\(voice) \(width): the frames moved from VX-175's")
            #expect(placed.size == old.size && placed.lineCount == (old.oneLine ? 1 : 2))
        }
    }

    /// **The thresholds at the in-app widths:** two lines hold while field ·
    /// scope fits with the field at its floor (Terminal 211.5 + 10 + 262 =
    /// 483.5; Study 175 + 10 + 264 = 449); below that, collapsed.
    @Test func theRowCollapsesWhereTheFieldsFloorNoLongerFitsBesideScope() {
        #expect(Rule.widthClass(Self.row(.terminal), width: 484, spacing: 10) == .twoLines)
        #expect(Rule.widthClass(Self.row(.terminal), width: 482, spacing: 10) == .collapsed)
        #expect(Rule.widthClass(Self.row(.study), width: 450, spacing: 10) == .twoLines)
        #expect(Rule.widthClass(Self.row(.study), width: 448, spacing: 10) == .collapsed)
        // The default window, panel open (631) and closed (981): unchanged.
        #expect(Rule.widthClass(Self.row(.terminal), width: 631, spacing: 10) == .twoLines)
        #expect(Rule.widthClass(Self.row(.terminal), width: 981, spacing: 10) == .oneLine)
    }

    /// **Collapsed: the field is never shown under its floor, and the row
    /// fits its room** — at every width from the row's floor (its widest
    /// rigid control) up to the collapse, field open or not; the field closed
    /// is not shown at all and the 🔍 is.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aCollapsedRowFitsItsRoomAndNeverSqueezesTheField(voice: ThemeVoice) {
        let floor: CGFloat = voice == .terminal ? 211.5 : 175
        var faults: [String] = []
        for width in stride(from: CGFloat(270), through: 483, by: 0.5) {
            for open in [false, true] {
                for sort in Self.forms[voice] ?? [] {
                    let placed = Rule.arrangeRow(Self.row(voice, sort: sort), width: width, spacing: 10,
                                                 lineSpacing: 8, searchOpen: open)
                    guard placed.widthClass == .collapsed else { continue }
                    if placed.size.width > width + 0.5 { faults.append("\(width) open \(open): row \(placed.size.width)") }
                    if placed.frames[1] == nil { faults.append("\(width): the 🔍 not shown") }
                    if open {
                        guard let field = placed.frames[0] else { faults.append("\(width): open, no field"); continue }
                        if field.width < floor - 0.5 { faults.append("\(width): the field \(field.width) of \(floor)") }
                        let others = placed.frames.enumerated().compactMap { $0.offset == 0 ? nil : $0.element }
                        if others.contains(where: { $0.maxY > field.minY + 0.5 }) {
                            faults.append("\(width): the field is not on the last line")
                        }
                    } else if placed.frames[0] != nil {
                        faults.append("\(width): closed, but the field is shown")
                    }
                }
            }
        }
        #expect(faults.isEmpty, "\(voice): \(faults.prefix(6))")
    }

    /// **Her state, not the text, adds the field's line:** at a collapsed
    /// width the open field is exactly ONE line more than the closed row; in
    /// the wide classes `searchOpen` changes nothing.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func openingTheFieldAddsExactlyOneLineAndOnlyWhenCollapsed(voice: ThemeVoice) {
        for width in stride(from: CGFloat(270), through: 1300, by: 13) {
            let closed = Rule.arrangeRow(Self.row(voice), width: width, spacing: 10, lineSpacing: 8, searchOpen: false)
            let open = Rule.arrangeRow(Self.row(voice), width: width, spacing: 10, lineSpacing: 8, searchOpen: true)
            if closed.widthClass == .collapsed {
                #expect(open.lineCount == closed.lineCount + 1, "\(voice) \(width): \(closed.lineCount) → \(open.lineCount)")
            } else {
                #expect(open == closed, "\(voice) \(width): a wide class moved with searchOpen")
            }
        }
    }

    /// **The collapsed row's groups wrap in their own order:** just under the
    /// collapse, 🔍 · scope over mode · sort · when (Terminal 478 holds the
    /// group on one line); narrower, the group breaks where its counted
    /// widths stop fitting (mode, then sort · when); the narrowest each
    /// control on a line of its own.
    @Test func theGroupsWrapInTheirOwnOrder() {
        let terminal = Self.row(.terminal)
        let at480 = Rule.arrangeRow(terminal, width: 480, spacing: 10, lineSpacing: 8, searchOpen: false)
        #expect(at480.widthClass == .collapsed && at480.lineCount == 2, "\(at480)")
        #expect(at480.frames[1]?.midY == at480.frames[2]?.midY, "🔍 and scope share line 1")
        #expect(at480.frames[3]?.midY == at480.frames[5]?.midY, "mode … when share line 2")
        let at400 = Rule.arrangeRow(terminal, width: 400, spacing: 10, lineSpacing: 8, searchOpen: false)
        #expect(at400.lineCount == 3, "🔍 · scope / mode / sort · when (\(at400.lineCount))")
        #expect(at400.frames[4]?.midY == at400.frames[5]?.midY && (at400.frames[3]?.midY ?? 0) < (at400.frames[4]?.midY ?? 0))
        let narrowest = Rule.arrangeRow(terminal, width: 0, spacing: 10, lineSpacing: 8, searchOpen: false)
        #expect(narrowest.lineCount == 5, "each control alone at the minimum query (\(narrowest.lineCount))")
        #expect(narrowest.size.width == 262, "the row's floor is its widest control, scope (\(narrowest.size.width))")
    }

    /// **The placement pass arranges what the sizing pass measured.** The row's
    /// container places it at its REPORTED width and `placeSubviews` re-decides
    /// there (U3c's T1 §7): at every width and class, both voices, field open
    /// or not, arranging again at the reported width gives the same frames.
    /// (Measured offscreen before the collapsed class reported its whole
    /// offered width: offered 432, reported 369, and at 369 the groups broke
    /// differently — the placed lines were not the measured ones.)
    @Test(arguments: [ThemeVoice.terminal, .study])
    func placingAtTheReportedWidthArrangesTheSameRow(voice: ThemeVoice) {
        var faults: [String] = []
        for width in stride(from: CGFloat(270), through: 1400, by: 0.5) {
            for open in [false, true] {
                let row = Self.row(voice)
                let measured = Rule.arrangeRow(row, width: width, spacing: 10, lineSpacing: 8, searchOpen: open)
                let placed = Rule.arrangeRow(row, width: measured.size.width, spacing: 10, lineSpacing: 8,
                                             searchOpen: open)
                if placed != measured {
                    faults.append("\(width) open \(open): \(measured.widthClass) re-placed at \(measured.size.width)")
                }
            }
        }
        #expect(faults.isEmpty, "\(voice): \(faults.prefix(6))")
    }

    /// The Timeline (sort and when stand down): 🔍 · scope / mode.
    @Test func inTheTimelineTheCollapsedRowIsTheModeAlone() {
        let placed = Rule.arrangeRow(Self.row(.terminal, timeline: true), width: 400, spacing: 10,
                                     lineSpacing: 8, searchOpen: false)
        #expect(placed.widthClass == .collapsed && placed.lineCount == 2 && placed.frames.count == 4)
    }

    // MARK: - The panel's width (VX-350)

    /// **The panel adjusts as the window narrows** (P-VX350-4): a third of
    /// the library down to 200 pt (was the note-side column's 280), its 420
    /// ideal above, never wider than the library itself. Above ≈823 pt of
    /// library the numbers are what they were.
    @Test func thePanelShrinksWithTheLibraryAndIsNeverWiderThanIt() {
        #expect(LibraryPanelLayout.width(total: 0) == 420, "unmeasured: the ideal")
        #expect(LibraryPanelLayout.width(total: 1488) == 420)
        #expect(LibraryPanelLayout.width(total: 1029) == 349, "the default window, unchanged")
        #expect(LibraryPanelLayout.width(total: 900) == 306)
        #expect(LibraryPanelLayout.width(total: 823) == 279, "where 280 used to hold it")
        #expect(LibraryPanelLayout.width(total: 700) == 238)
        #expect(LibraryPanelLayout.width(total: 560) == 200, "the floor")
        #expect(LibraryPanelLayout.width(total: 150) == 149, "never wider than the library")
        var last: CGFloat = 0
        for total in stride(from: CGFloat(1), through: 2000, by: 1) {
            let width = LibraryPanelLayout.width(total: total)
            #expect(width <= total - 1 + 0.001, "\(total): the panel \(width) wider than the room")
            #expect(width >= last, "\(total): the panel narrowed as the library grew")
            last = width
        }
    }
}
