//
//  LibraryControlsFlow.swift
//  Variorum (Mac)
//
//  VX-175 (the VX-283 run, U3 — P-U3-2 as RULED by the orchestrator,
//  2026-10-15): **the Library's controls row is one line when it fits,
//  otherwise two — search · scope on the first, mode · sort · when on the
//  second.** At the app's own 1240-pt default window with the info panel
//  open the row's single line (search · scope · mode · sort ▾ · when ▾) was
//  wider than the list column: the search field squeezed to a sliver and the
//  panel was pushed off the window's right edge (≈92 pt Study, ≈136 pt
//  Terminal — the 13n-c walk's F-R1-1). The ruled split keeps the one-line
//  ORDER (the row wraps after scope) and falls where the controls already
//  group: the field and scope say what is searched; mode, sort and when say
//  how it is shown (sort and when stand down WITH the mode in Timeline).
//
//  **A `Layout` over ONE set of views — never `ViewThatFits`** (the ruling):
//  `ViewThatFits` builds each candidate separately, so the row would hold two
//  search fields and swap them on the re-flow the info panel's opening
//  triggers — dropping her caret. Here the field is one view in either
//  arrangement. A line that fits places its controls exactly as the row's
//  old `HStack` did (`LibraryControlsFlowRule.distribute` — the HStack's own
//  least-flexible-first sharing), so a wide window is unchanged.
//
//  **The wrap decision reads STABLE widths only** (P-U3-5, the orchestrator's
//  ruling on U3's walk, W2's F-1 and F-2). The first build asked the field for
//  its ideal (`sizeThatFits(.unspecified)`), which a `.roundedBorder` field
//  answers with its cell's size — the PROMPT's width while empty, the TYPED
//  TEXT's once she types (measured offscreen: 211.5 → 40.5 pt in Terminal for
//  "wing"). So typing with the panel open made "the field keeps its ideal"
//  true of a 40-pt field: the row collapsed to one line, the field a sliver,
//  and the relevance label (no line limit) wrapped onto three lines (F-1);
//  and Terminal's closed row at 1240, a few points from the threshold, flipped
//  with the field's state and the sort's words (F-2). Now the decision counts
//  the field at its PROMPT (`LibraryControlsStableWidths.fieldFloor`, handed
//  down as a layout value — never the field's own answer) and the sort slot
//  at the WIDEST it can read (every sort × direction, and search's relevance
//  form), so it is a function of the column's width alone: typing, a sort pick
//  or a search never changes the line count.
//
//  **VX-350 (the VX-348 run, U3) — the narrow widths.** Below VX-175's two
//  lines the row was wider than its column: the field squeezed to its own
//  sliver (her "empty pill") and, with the info panel open, the column's
//  minimum and the panel's together pushed the panel off the window. A third
//  class, decided the same way (stable widths only): COLLAPSED — the field
//  becomes the 🔍 door (`LibrarySearchToggle`) beside scope, mode · sort ·
//  when wrap in their own order, and the field opens on its own last line
//  while she has it open (her state, never the text — so typing or a search
//  still never changes the line count). Still ONE Layout over one set of
//  views; a control a class does not show is placed outside the row.
//

import AppKit
import SwiftUI
import VariorumCore

/// **The pure half** (VX-175): the HStack's distribution and the wrap
/// decision, over abstract children — what the layout asks, the pins drive.
nonisolated enum LibraryControlsFlowRule {
    /// One control as the row sees it: how flexible it is (its widest less
    /// its narrowest), the width and height it takes when offered a width —
    /// and, for the two controls whose own answers move with state, the
    /// STABLE width the wrap decision counts instead (P-U3-5).
    struct Child {
        var flexibility: CGFloat
        var width: (CGFloat) -> CGFloat
        var height: (CGFloat) -> CGFloat
        /// **The field's floor** — its prompt's width in its own face, cell
        /// chrome included: one line only while the field keeps at least
        /// this. nil for every control but the field. Never the field's own
        /// ideal, which follows the typed text (F-1).
        var floor: CGFloat? = nil
        /// **The widest this control can read** — the sort slot, whose words
        /// change with the sort, the direction and the search: the decision
        /// counts it at this width, rigid, so a pick never flips the row.
        /// nil = the control's own width is already stable.
        var widest: CGFloat? = nil
    }

    struct Arrangement: Equatable {
        var oneLine: Bool
        /// Each child's frame, in the row's own space (y down), in child order.
        var frames: [CGRect]
        var size: CGSize
    }

    /// **The HStack's distribution:** the least flexible child first, each
    /// offered an equal share of the width that is left (a child that cannot
    /// shrink to its share takes what it needs, and the rest get less).
    static func distribute(_ children: [Child], in width: CGFloat, spacing: CGFloat) -> [CGFloat] {
        guard !children.isEmpty else { return [] }
        var widths = Array(repeating: CGFloat(0), count: children.count)
        var remaining = width - spacing * CGFloat(children.count - 1)
        let order = children.indices.sorted {
            (children[$0].flexibility, $0) < (children[$1].flexibility, $1)
        }
        for (placed, index) in order.enumerated() {
            let share = max(0, remaining) / CGFloat(children.count - placed)
            let taken = children[index].width(share)
            widths[index] = taken
            remaining -= taken
        }
        return widths
    }

    /// A child as the DECISION counts it: a control with a `widest` is a rigid
    /// control of exactly that width; every other child is itself.
    static func counted(_ child: Child) -> Child {
        guard let widest = child.widest else { return child }
        return Child(flexibility: 0, width: { _ in widest }, height: child.height,
                     floor: child.floor, widest: widest)
    }

    /// **The wrap decision** (the ruling: one line only if the field keeps at
    /// least its placeholder width — P-U3-5: read from STABLE widths only):
    /// the line, with every changing label counted at its widest and placed
    /// as the HStack places it, fits `width` AND leaves the field at least its
    /// floor. Nothing here reads the typed text or the current sort's words,
    /// so the answer is a function of `width` (and the voice's widths) alone.
    ///
    /// The placement then uses the LIVE widths (`arrange`), never wider than
    /// what was counted — and a narrower fixed label only leaves the field
    /// MORE room in the HStack's order, so a line judged to fit places the
    /// field at no less than its floor (pinned).
    static func fitsOneLine(_ children: [Child], width: CGFloat, spacing: CGFloat) -> Bool {
        let counted = children.map(counted)
        let widths = distribute(counted, in: width, spacing: spacing)
        let total = widths.reduce(0, +) + spacing * CGFloat(max(0, widths.count - 1))
        guard total <= width + 0.5 else { return false }
        return zip(counted, widths).allSatisfy { child, taken in
            child.floor.map { taken >= $0 - 0.5 } ?? true
        }
    }

    /// The whole arrangement: one line when it fits, else the first
    /// `lineOneCount` children on line 1 and the rest on line 2, each line
    /// distributed as an HStack, left-aligned, its children centred on it.
    static func arrange(
        _ children: [Child], lineOneCount: Int, width: CGFloat,
        spacing: CGFloat, lineSpacing: CGFloat
    ) -> Arrangement {
        guard !children.isEmpty else { return Arrangement(oneLine: true, frames: [], size: .zero) }
        let oneLine = children.count <= lineOneCount
            || fitsOneLine(children, width: width, spacing: spacing)
        let single = distribute(children, in: width, spacing: spacing)
        let lines: [Range<Int>] = oneLine
            ? [children.indices]
            : [0..<lineOneCount, lineOneCount..<children.count]
        var frames = Array(repeating: CGRect.zero, count: children.count)
        var y: CGFloat = 0
        var rowWidth: CGFloat = 0
        for (number, line) in lines.enumerated() {
            let members = Array(children[line])
            let widths = oneLine ? single : distribute(members, in: width, spacing: spacing)
            let heights = zip(members, widths).map { $0.height($1) }
            let lineHeight = heights.max() ?? 0
            var x: CGFloat = 0
            for (offset, index) in line.enumerated() {
                frames[index] = CGRect(
                    x: x, y: y + (lineHeight - heights[offset]) / 2,
                    width: widths[offset], height: heights[offset])
                x += widths[offset] + spacing
            }
            rowWidth = max(rowWidth, x - spacing)
            y += lineHeight + (number < lines.count - 1 ? lineSpacing : 0)
        }
        return Arrangement(oneLine: oneLine, frames: frames, size: CGSize(width: rowWidth, height: y))
    }

    // MARK: VX-350 — the narrow widths: the field collapses to 🔍

    /// **The row's width classes** (VX-350, the VX-348 run's U3 — her words:
    /// the search field squeezed to "an empty pill" left of All when the info
    /// panel was open; *"it should at least turn into a search icon like
    /// magnifying glass and clicking on it should still do something, even if
    /// just opening it in the pane below"*). Widest to narrowest, each decided
    /// from STABLE widths only (P-U3-5 — the field at its floor, the sort slot
    /// at its widest, the rigid controls at their natural widths), so a
    /// width's class never moves with what is typed, picked or searched:
    enum WidthClass: Equatable, Sendable {
        /// field · scope · mode · sort · when — VX-175's one line.
        case oneLine
        /// field · scope / mode · sort · when — VX-175's ruled (C) wrap.
        case twoLines
        /// 🔍 · scope / mode · sort · when — the field's floor no longer fits
        /// beside scope, so the field becomes the 🔍 door and opens on a line
        /// of its own BELOW the controls when she asks for it (never a
        /// squeezed field); each group wraps in its own order as the room
        /// narrows further (🔍 · scope, then mode · sort · when).
        case collapsed
    }

    /// The row by role (VX-350): the field, the 🔍 door, scope, then the
    /// rest in the row's order (mode, and sort · when where they show).
    struct Row {
        var field: Child
        var toggle: Child
        var scope: Child
        var rest: [Child]
    }

    /// The row placed: each child's frame in the flat order field · toggle ·
    /// scope · rest — nil for a child this class does not show (the layout
    /// places it outside the row, never squeezed: the empty pill WAS a
    /// squeezed field).
    struct RowArrangement: Equatable {
        var widthClass: WidthClass
        var frames: [CGRect?]
        var size: CGSize
        var lineCount: Int
    }

    /// **The class, decided** — from the counted (stable) widths alone: one
    /// line while VX-175's line fits; two while field · scope (the field at
    /// its floor) and mode · sort · when each fit a line; else collapsed.
    static func widthClass(_ row: Row, width: CGFloat, spacing: CGFloat) -> WidthClass {
        if fitsOneLine([row.field, row.scope] + row.rest, width: width, spacing: spacing) { return .oneLine }
        if fitsOneLine([row.field, row.scope], width: width, spacing: spacing),
           fitsOneLine(row.rest, width: width, spacing: spacing) {
            return .twoLines
        }
        return .collapsed
    }

    /// **The row's arrangement** (VX-350). The two wide classes are VX-175's
    /// `arrange`, frame for frame (the 🔍 not shown). Collapsed: the 🔍 and
    /// scope flow onto as few lines as they fit, then mode · sort · when the
    /// same way — each line's breaks counted at the STABLE widths (the sort
    /// slot at its widest, so a sort pick never moves a break), placed at the
    /// live ones — then, while `searchOpen`, the field on its own last line
    /// (as wide as the row lets it be, up to its own cap). `searchOpen` is HER
    /// state (the 🔍 pressed, or the field holding the keyboard) — never the
    /// text — so typing or a search never adds or removes that line.
    static func arrangeRow(
        _ row: Row, width: CGFloat, spacing: CGFloat, lineSpacing: CGFloat, searchOpen: Bool
    ) -> RowArrangement {
        let decided = widthClass(row, width: width, spacing: spacing)
        switch decided {
        case .oneLine, .twoLines:
            let wide = arrange([row.field, row.scope] + row.rest, lineOneCount: 2, width: width,
                               spacing: spacing, lineSpacing: lineSpacing)
            let frames: [CGRect?] = [wide.frames[0], nil, wide.frames[1]] + wide.frames.dropFirst(2).map { $0 }
            return RowArrangement(widthClass: decided, frames: frames, size: wide.size,
                                  lineCount: wide.oneLine ? 1 : 2)
        case .collapsed:
            let flat = [row.field, row.toggle, row.scope] + row.rest
            // Each group flows on its own lines, its own order kept: a line
            // takes the next control while the COUNTED widths fit. Every
            // control here is rigid (the pickers fixed by P-U3c-1, the doors
            // and labels fixed): each is counted, and placed, at its
            // narrowest — its natural width (the sort slot counted at its
            // widest form, placed at its live words).
            var lines: [[Int]] = []
            func flow(_ members: [Int]) {
                var line: [Int] = []
                var used: CGFloat = 0
                for index in members {
                    let counted = counted(flat[index]).width(0)
                    if line.isEmpty {
                        line = [index]
                        used = counted
                    } else if used + spacing + counted <= width + 0.5 {
                        line.append(index)
                        used += spacing + counted
                    } else {
                        lines.append(line)
                        line = [index]
                        used = counted
                    }
                }
                if !line.isEmpty { lines.append(line) }
            }
            flow([1, 2])
            flow(Array(3..<flat.count))
            if searchOpen { lines.append([0]) }
            var frames: [CGRect?] = Array(repeating: nil, count: flat.count)
            var y: CGFloat = 0
            var rowWidth: CGFloat = 0
            for (number, line) in lines.enumerated() {
                // The field (alone on its line) as wide as the row lets it be
                // — up to its own cap; every other control at its narrowest.
                let widths = line.map { $0 == 0 ? flat[0].width(width) : flat[$0].width(0) }
                let heights = zip(line, widths).map { flat[$0].height($1) }
                let lineHeight = heights.max() ?? 0
                var x: CGFloat = 0
                for (offset, index) in line.enumerated() {
                    frames[index] = CGRect(
                        x: x, y: y + (lineHeight - heights[offset]) / 2,
                        width: widths[offset], height: heights[offset])
                    x += widths[offset] + spacing
                }
                rowWidth = max(rowWidth, x - spacing)
                y += lineHeight + (number < lines.count - 1 ? lineSpacing : 0)
            }
            return RowArrangement(widthClass: .collapsed, frames: frames,
                                  size: CGSize(width: rowWidth, height: y), lineCount: lines.count)
        }
    }
}

/// **The controls row's layout** (VX-175): the search field FIRST, scope
/// second, then mode · sort · when — one line when the rule says it fits,
/// else the first two on line 1 and the rest on line 2. **VX-350:** with a
/// 🔍 door among its subviews (`Role.toggle`) the row has a third, narrow
/// class — 🔍 · scope / mode · sort · when, the field on its own last line
/// while `searchOpen` (`LibraryControlsFlowRule.arrangeRow`).
struct LibraryControlsFlow: Layout {
    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 8
    /// Search · scope.
    var lineOneCount: Int = 2
    /// VX-350: whether the field shows in the collapsed class — HER state
    /// (the 🔍 pressed, or the field holding the keyboard), never the text.
    var searchOpen: Bool = false

    /// The field's floor, handed down by the header (P-U3-5 — the field's
    /// own ideal follows the typed text, so the layout never asks it).
    struct FloorKey: LayoutValueKey {
        static let defaultValue: CGFloat? = nil
    }

    /// The widest a changing label can read (the sort slot, both its forms).
    struct WidestKey: LayoutValueKey {
        static let defaultValue: CGFloat? = nil
    }

    /// VX-350: which subview is the field and which the 🔍 door; every other
    /// subview is scope, then the rest, in the row's order.
    enum Role: Equatable, Sendable { case field, toggle, other }

    struct RoleKey: LayoutValueKey {
        static let defaultValue: Role = .other
    }

    /// Where a subview the class does not show is placed: outside the row
    /// (and every window), at its own size — never squeezed to a sliver.
    static let unshownOffset: CGFloat = -100_000

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        #if DEBUG
        if LibraryControlsFlowTrace.sink != nil {
            LibraryControlsFlowTrace.pass = "size p=\(LibraryControlsFlowTrace.text(proposal.width))"
        }
        #endif
        return arrangement(width: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        #if DEBUG
        if LibraryControlsFlowTrace.sink != nil {
            LibraryControlsFlowTrace.pass =
                "place b=\(LibraryControlsFlowTrace.text(bounds.width)) p=\(LibraryControlsFlowTrace.text(proposal.width))"
        }
        #endif
        let arranged = arrangement(width: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if let frame = arranged.frames[index] {
                subview.place(
                    at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: frame.width, height: frame.height))
            } else {
                // VX-350: not shown in this class — outside the row at its
                // own size (the field keeps its identity, text and caret road).
                subview.place(
                    at: CGPoint(x: bounds.minX + Self.unshownOffset, y: bounds.minY),
                    anchor: .topLeading, proposal: .unspecified)
            }
        }
    }

    /// The row as the layout arranged it: frames in SUBVIEW order (nil = not
    /// shown), its size.
    struct Placed {
        var frames: [CGRect?]
        var size: CGSize
    }

    private func arrangement(width: CGFloat, subviews: Subviews) -> Placed {
        let children = subviews.map { subview in
            let narrowest = subview.sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
            let widestWidth = subview.sizeThatFits(ProposedViewSize(width: .infinity, height: nil)).width
            return LibraryControlsFlowRule.Child(
                flexibility: widestWidth - narrowest,
                width: { subview.sizeThatFits(ProposedViewSize(width: $0, height: nil)).width },
                height: { subview.sizeThatFits(ProposedViewSize(width: $0, height: nil)).height },
                floor: subview[FloorKey.self],
                widest: subview[WidestKey.self])
        }
        let roles = subviews.map { $0[RoleKey.self] }
        guard let fieldIndex = roles.firstIndex(of: .field),
              let toggleIndex = roles.firstIndex(of: .toggle) else {
            // No 🔍 door among the subviews: VX-175's two classes, as shipped.
            let arranged = LibraryControlsFlowRule.arrange(
                children, lineOneCount: lineOneCount, width: width,
                spacing: spacing, lineSpacing: lineSpacing)
            return Placed(frames: arranged.frames.map { $0 }, size: arranged.size)
        }
        let others = roles.indices.filter { roles[$0] == .other }
        guard let scopeIndex = others.first else {
            return Placed(frames: Array(repeating: nil, count: subviews.count), size: .zero)
        }
        let restIndices = Array(others.dropFirst())
        let row = LibraryControlsFlowRule.Row(
            field: children[fieldIndex], toggle: children[toggleIndex], scope: children[scopeIndex],
            rest: restIndices.map { children[$0] })
        let arranged = LibraryControlsFlowRule.arrangeRow(
            row, width: width, spacing: spacing, lineSpacing: lineSpacing, searchOpen: searchOpen)
        // The rule's flat order (field · toggle · scope · rest) back to the
        // subviews' own.
        let order = [fieldIndex, toggleIndex, scopeIndex] + restIndices
        var frames: [CGRect?] = Array(repeating: nil, count: subviews.count)
        for (flat, index) in order.enumerated() { frames[index] = arranged.frames[flat] }
        #if DEBUG
        if LibraryControlsFlowTrace.sink != nil {
            LibraryControlsFlowTrace.record(
                width: width, subviews: subviews, row: row, arranged: arranged, spacing: spacing)
        }
        #endif
        return Placed(frames: frames, size: arranged.size)
    }
}

#if DEBUG
/// **VX-283 U3c — the trace leg's probe (DEBUG only; silent unless a probe
/// sets `sink`).** The closed-panel sweep found a band where the row's line
/// count followed its HISTORY, not its width (the record's "U2 + U3b — THE
/// STAGE WINDOW"). This reports, for every arrangement the layout computes,
/// the pass (sizing or placing, with its proposal), every child's own
/// answers (narrowest at a zero proposal, widest at an infinite one, the
/// flexibility the distribution orders by, its ideal at an unspecified
/// proposal, the floor and widest the header hands down), the DECISION's
/// distribution step by step (each child's offered share and what it took —
/// recorded by wrapping the children's own width answers around the real
/// `fitsOneLine`, so no rule logic is copied here), its answer, and the
/// arrangement's frames and size. The architect's ruling decides whether it
/// stays as an oracle or goes (the `SidebarSectionTrace` precedent).
/// `nonisolated(unsafe)`: the layout's entry points are nonisolated
/// (`Layout`'s requirements), and SwiftUI runs them on the main thread —
/// the probe that sets `sink` runs there too.
nonisolated enum LibraryControlsFlowTrace {
    nonisolated(unsafe) static var sink: ((String) -> Void)?
    /// The pass the next arrangement belongs to (set by the layout's two
    /// entry points just before they arrange).
    nonisolated(unsafe) static var pass = ""

    nonisolated static func text(_ value: CGFloat?) -> String {
        guard let value else { return "nil" }
        return value.isFinite ? String(format: "%.1f", value) : "inf"
    }

    static func record(
        width: CGFloat, subviews: LayoutSubviews, row: LibraryControlsFlowRule.Row,
        arranged: LibraryControlsFlowRule.RowArrangement, spacing: CGFloat
    ) {
        guard let sink else { return }
        // The decision, replayed through the real rule with each child's
        // width answer recorded as it is asked (a counted child — the sort
        // slot — never asks; it is its widest, rigid). VX-350: the replay is
        // the row's class (`widthClass`), over the rule's flat order —
        // [0] field · [1] 🔍 · [2] scope · [3…] the rest.
        var steps: [String] = []
        func recorded(_ child: LibraryControlsFlowRule.Child, _ index: Int) -> LibraryControlsFlowRule.Child {
            var copy = child
            copy.width = { offered in
                let taken = child.width(offered)
                steps.append("[\(index)] \(text(offered))→\(text(taken))")
                return taken
            }
            return copy
        }
        let replay = LibraryControlsFlowRule.Row(
            field: recorded(row.field, 0), toggle: recorded(row.toggle, 1), scope: recorded(row.scope, 2),
            rest: row.rest.enumerated().map { recorded($1, $0 + 3) })
        let decided = LibraryControlsFlowRule.widthClass(replay, width: width, spacing: spacing)
        let readings = subviews.enumerated().map { index, subview in
            let narrowest = subview.sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
            let widest = subview.sizeThatFits(ProposedViewSize(width: .infinity, height: nil)).width
            let ideal = subview.sizeThatFits(.unspecified).width
            return "[\(index)] n=\(text(narrowest)) w=\(text(widest)) flex=\(text(widest - narrowest))"
                + " ideal=\(text(ideal)) floor=\(text(subview[LibraryControlsFlow.FloorKey.self]))"
                + " widest=\(text(subview[LibraryControlsFlow.WidestKey.self]))"
                + " role=\(subview[LibraryControlsFlow.RoleKey.self])"
        }
        let frames = arranged.frames.map { frame in
            frame.map { "\(text($0.minX))+\(text($0.width))@\(text($0.minY))" } ?? "unshown"
        }
        sink("\(pass) w=\(text(width)) · decided=\(decided) arranged.class=\(arranged.widthClass)"
             + " lines=\(arranged.lineCount)"
             + " size=\(text(arranged.size.width))x\(text(arranged.size.height))"
             + " · decision steps \(steps.joined(separator: " "))"
             + " · frames \(frames.joined(separator: " "))"
             + " · children \(readings.joined(separator: " | "))")
    }
}
#endif

extension View {
    /// The search field's floor for `LibraryControlsFlow`'s wrap decision.
    func libraryControlsFloor(_ width: CGFloat) -> some View {
        layoutValue(key: LibraryControlsFlow.FloorKey.self, value: width)
    }

    /// The widest a changing label in `LibraryControlsFlow` can read.
    func libraryControlsWidest(_ width: CGFloat) -> some View {
        layoutValue(key: LibraryControlsFlow.WidestKey.self, value: width)
    }

    /// VX-350: this subview's role in `LibraryControlsFlow` (the field, or
    /// the 🔍 door; every other subview is `.other`).
    func libraryControlsRole(_ role: LibraryControlsFlow.Role) -> some View {
        layoutValue(key: LibraryControlsFlow.RoleKey.self, value: role)
    }
}

// MARK: - The 🔍 door (VX-350)

/// **The search field's narrow face** (VX-350): a magnifying glass that
/// opens the field on its own line below the controls, the caret in it.
/// Shown only in the row's collapsed class (`LibraryControlsFlow`); it says
/// when the field is open (the voice's wash behind it) and when a question
/// is asked while the field is closed (the glyph in the voice's accent).
struct LibrarySearchToggle: View {
    let tokens: VoiceTokens
    /// The field is open below the controls.
    let open: Bool
    /// A question is asked (the band says it) — worth a mark while the field
    /// is closed.
    let asking: Bool
    let onPress: () -> Void

    /// The door's one size — a stable width for the row's decision.
    nonisolated static let size = CGSize(width: 28, height: 22)

    var body: some View {
        Button(action: onPress) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(asking && !open ? tokens.accent : tokens.muted)
                .frame(width: Self.size.width, height: Self.size.height)
                .background {
                    if open {
                        RoundedRectangle(cornerRadius: 5).fill(tokens.wash)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .help(tokens.chromeLabel(LibraryCatalogView.searchPrompt))
        .accessibilityLabel(LibraryCopy.searchToggleLabel)
    }
}

// MARK: - The stable widths (P-U3-5)

/// **What the wrap decision counts** (P-U3-5): the field at its PROMPT and the
/// sort slot at its WIDEST, measured in the voice's own small face — numbers
/// that move only when the voice does, never with what she types or picks.
struct LibraryControlsStableWidths: Equatable {
    /// **The field's floor:** the prompt, in the field's own font, through the
    /// cell the field draws with — exactly the width at which the field shows
    /// its whole prompt. (A `.roundedBorder` field's ideal IS its cell's size:
    /// with the prompt while empty, with the text once typed — measured equal
    /// offscreen; the empty case is pinned against the mounted field itself.)
    /// CLAMPED at the field's own cap (`LibraryCatalogView.searchFieldMaxWidth`
    /// — the VX-283 ladder's R1-6, a guard): a prompt measuring past what the
    /// field can ever be given would leave `fitsOneLine` false at every width,
    /// pinning the row at two lines forever. Both voices' prompts measure far
    /// inside the cap today (211.5 / 175 of 320), so the clamp never engages.
    var fieldFloor: CGFloat
    /// **The sort slot at the widest it can read:** every sort × direction as
    /// the `sort ▾` door draws it, and the search's relevance label.
    var sortWidest: CGFloat

    /// One form of a label: its words and the chrome drawn around them.
    struct LabelForm: Hashable {
        var text: String
        var chrome: CGFloat
    }

    /// `VoicedMenu`'s horizontal chrome around its words (`Theme/
    /// VoiceControls.swift`: `.padding(.horizontal, 5)` each side; the menu
    /// itself adds none — measured offscreen, every form). Kept honest by the
    /// pin that measures the real door at every form.
    static let voicedMenuChrome: CGFloat = 10

    /// Every form the sort slot can take, in the voice's words: the `sort ▾`
    /// door's label for every offered sort × direction, then the search's
    /// relevance label (no chrome — a plain label).
    static func sortForms(_ tokens: VoiceTokens) -> [LabelForm] {
        let doors = LibrarySortFace.offered.flatMap { sort in
            [SortDirection.desc, .asc].map { direction in
                LabelForm(text: tokens.chromeLabel(LibrarySortFace.doorLabel(sort, direction)) + " \u{25BE}",
                          chrome: voicedMenuChrome)
            }
        }
        return doors + [LabelForm(text: tokens.chromeLabel(LibrarySearchCopy.relevance), chrome: 0)]
    }

    /// The row's stable widths in this voice — `prompt` is the field's own
    /// (`LibraryCatalogView.searchPrompt`, before the voice's casing) and
    /// `fieldMaxWidth` the field's own cap (`LibraryCatalogView.
    /// searchFieldMaxWidth`), resolved from the voice's `small` face (the
    /// field's font and the labels') in the view's own font context;
    /// memoized per face, so a keystroke re-renders without re-measuring.
    static func row(
        tokens: VoiceTokens, prompt: String, fieldMaxWidth: CGFloat, in context: Font.Context
    ) -> Self {
        let font = tokens.small.resolve(in: context).ctFont as NSFont
        return measure(prompt: tokens.chromeLabel(prompt), sortForms: sortForms(tokens), font: font,
                       fieldMaxWidth: fieldMaxWidth)
    }

    private struct MemoKey: Hashable {
        var font: String
        var size: CGFloat
        var prompt: String
        var forms: [LabelForm]
        var fieldMaxWidth: CGFloat
    }

    private static var memo: [MemoKey: LibraryControlsStableWidths] = [:]

    /// The measurement itself: the prompt through a rounded-bezel field cell
    /// in `font`, clamped at `fieldMaxWidth` (R1-6), each label form's words
    /// in `font` (rounded UP to a whole point, as a SwiftUI `Text` sizes
    /// itself) plus its chrome.
    static func measure(
        prompt: String, sortForms: [LabelForm], font: NSFont, fieldMaxWidth: CGFloat
    ) -> Self {
        let key = MemoKey(font: font.fontName, size: font.pointSize, prompt: prompt, forms: sortForms,
                          fieldMaxWidth: fieldMaxWidth)
        if let known = memo[key] { return known }
        let cell = NSTextFieldCell(textCell: "")
        cell.isEditable = true
        cell.isBezeled = true
        cell.bezelStyle = .roundedBezel
        cell.font = font
        cell.placeholderString = prompt
        let widest = sortForms.map { form in
            (form.text as NSString).size(withAttributes: [.font: font]).width.rounded(.up) + form.chrome
        }.max() ?? 0
        let measured = LibraryControlsStableWidths(
            fieldFloor: min(cell.cellSize.width, fieldMaxWidth), sortWidest: widest)
        memo[key] = measured
        return measured
    }
}
