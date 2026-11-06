//
//  BookMastheadModeRow.swift
//  Variorum (Mac)
//
//  VX-887 (the VX-878 run, batch 4) — **the book masthead goes one line.**
//  Her three rulings (2026-11-05, "the area in books is a bit crowded and
//  lacks visual hierarchy"): (1) the order control moves onto the MODE ROW's
//  one line — the modes leading (Outline · Index · Book · Read), the order
//  dial at the row's trailing end — so the masthead's standing three-row
//  stack (title / modes / "order · Manual order ▾") loses its third text row;
//  (2) the doubled word goes — the dial's face says "Manual order ▾", never
//  "order · Manual order ▾"; (3) *"make sure that when the area is more
//  compressed that order still goes to the second line smoothly."*
//
//  **The Library controls-row law is the precedent** (SurfaceContracts, The
//  Library; `LibraryControlsFlow`, VX-175/VX-350): ONE `Layout` over ONE set
//  of views — never `ViewThatFits` — whose wrap is a width-class decision at
//  WHOLE POINTS from STABLE widths only: the tab row at the widest it reads
//  across the four active tabs (`BookMastheadStableWidths.tabs`), the dial at
//  the WIDEST of every face it can draw (`.dial` — every stored field ×
//  direction, "as collected", "book's order"). So typing a title, a view
//  order picked, a mode switched or a row landing never changes the line
//  count: the class is a function of the width (and the voice) alone.
//
//  ONE LINE: the tabs at the leading edge, the dial at the trailing end,
//  first text baselines aligned. TWO LINES: the tabs, then the dial on a line
//  below at the row's trailing end — it drops straight down rather than
//  jumping to the left (PROVISIONAL D-887-2; the record names the
//  alternative). The row record is `notes/plans/fixes/vx-878-book-doors-faces.md`
//  (BATCH 4 RECORD).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The pure half

/// **The row's rule, pure** — what the layout asks; the pins drive it with
/// abstract children.
nonisolated enum BookMastheadModeRowRule {
    /// Between two tabs (the shipped `HStack(spacing: 8)`).
    static let tabSpacing: CGFloat = 8
    /// The least air between the last tab and the dial on one line — the
    /// tabs' own spacing (the dial is counted at its widest form, so with any
    /// shorter face the air it shows is wider).
    static let gap: CGFloat = 8
    /// Between the tab line and the dial's line when it wraps — the
    /// navigator's own row spacing, so the two-line look is today's rows
    /// minus the doubled word.
    static let lineSpacing: CGFloat = 6

    enum WidthClass: Equatable, Sendable {
        /// modes · · · dial
        case oneLine
        /// modes / · · · dial
        case twoLines
    }

    /// One subview as the row sees it: its size and its first text baseline
    /// when offered a width (nil = its ideal).
    struct Child {
        var size: (CGFloat?) -> CGSize
        var baseline: (CGFloat?) -> CGFloat
    }

    /// The row placed: each subview's frame in the row's own space (y down).
    struct Arrangement: Equatable, Sendable {
        var widthClass: WidthClass
        var tabs: CGRect
        var dial: CGRect
        var size: CGSize
        var lineCount: Int { widthClass == .oneLine ? 1 : 2 }
    }

    /// The width the row is decided and arranged at (the VX-348 U3 fix leg's
    /// rule): the offered width floored to a whole point; zero and an
    /// unbounded offer (the minimum and ideal queries) as they are.
    static func decidingWidth(_ offered: CGFloat) -> CGFloat {
        offered.isFinite && offered > 0 ? offered.rounded(.down) : offered
    }

    /// The one line, COUNTED: the tabs at their stable width, the gap, the
    /// dial at its widest form.
    static func countedLine(tabs: CGFloat, dialWidest: CGFloat, gap: CGFloat = gap) -> CGFloat {
        tabs + gap + dialWidest
    }

    /// **The class, decided** from the counted (stable) widths alone — never
    /// a live label. An unbounded width (the ideal query) is one line.
    static func widthClass(
        width: CGFloat, tabs: CGFloat, dialWidest: CGFloat, gap: CGFloat = gap
    ) -> WidthClass {
        guard width.isFinite else { return .oneLine }
        return countedLine(tabs: tabs, dialWidest: dialWidest, gap: gap) <= width ? .oneLine : .twoLines
    }

    /// **The row's arrangement**, decided and arranged at `decidingWidth`.
    /// The row reports the WHOLE width it was offered (the dial sits at its
    /// trailing end) — or its own line's width when that is wider (a tab row
    /// truly wider than its room; the minimum query) — so the container
    /// places it at a whole-point width and the placement pass, flooring the
    /// same number, re-decides exactly what the sizing pass measured. The
    /// ideal query answers the COUNTED one-line width, so a host sizing the
    /// row at its ideal places one line there.
    static func arrange(
        width offered: CGFloat, tabs: Child, dial: Child,
        tabsWidth: CGFloat, dialWidest: CGFloat,
        gap: CGFloat = gap, lineSpacing: CGFloat = lineSpacing
    ) -> Arrangement {
        let width = decidingWidth(offered)
        let decided = widthClass(width: width, tabs: tabsWidth, dialWidest: dialWidest, gap: gap)
        let rowWidth = width.isFinite
            ? max(0, width) : countedLine(tabs: tabsWidth, dialWidest: dialWidest, gap: gap)
        let tabsSize = tabs.size(rowWidth)
        switch decided {
        case .oneLine:
            // The dial is offered the room right of the tabs — never less
            // than its widest form while the class holds, so it never
            // truncates on one line.
            let room = max(0, rowWidth - tabsSize.width - gap)
            let dialSize = dial.size(room)
            let tabsBaseline = tabs.baseline(rowWidth)
            let dialBaseline = dial.baseline(room)
            let baseline = max(tabsBaseline, dialBaseline)
            let tabsY = baseline - tabsBaseline
            let dialY = baseline - dialBaseline
            let lineWidth = max(rowWidth, tabsSize.width + gap + dialSize.width)
            return Arrangement(
                widthClass: .oneLine,
                tabs: CGRect(origin: CGPoint(x: 0, y: tabsY), size: tabsSize),
                dial: CGRect(origin: CGPoint(x: lineWidth - dialSize.width, y: dialY), size: dialSize),
                size: CGSize(width: lineWidth, height: max(tabsY + tabsSize.height, dialY + dialSize.height)))
        case .twoLines:
            // The dial's line is as wide as the row — or as the tab line, when
            // the tabs alone are wider than the room (they never wrap), so a
            // placement at the reported width offers the dial the same room.
            let lineRoom = max(rowWidth, tabsSize.width)
            let dialSize = dial.size(lineRoom)
            let lineWidth = max(lineRoom, dialSize.width)
            let dialY = tabsSize.height + lineSpacing
            return Arrangement(
                widthClass: .twoLines,
                tabs: CGRect(origin: .zero, size: tabsSize),
                dial: CGRect(origin: CGPoint(x: lineWidth - dialSize.width, y: dialY), size: dialSize),
                size: CGSize(width: lineWidth, height: dialY + dialSize.height))
        }
    }
}

// MARK: - The layout

/// **The masthead's mode row** (VX-887): exactly two subviews — the tab row,
/// then the order dial — one line when the rule says it fits, else two.
struct BookMastheadModeRow: Layout {
    /// The tab row's STABLE width (`BookMastheadStableWidths.tabs`).
    var tabsWidth: CGFloat
    /// The dial's WIDEST form (`BookMastheadStableWidths.dial`).
    var dialWidest: CGFloat
    var gap: CGFloat = BookMastheadModeRowRule.gap
    var lineSpacing: CGFloat = BookMastheadModeRowRule.lineSpacing
    /// The DEBUG probe's key (the book's id) — nil records nothing.
    var probeKey: String? = nil

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangement(width: proposal.width ?? .infinity, subviews: subviews)?.size ?? .zero
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard let arranged = arrangement(width: bounds.width, subviews: subviews) else {
            for subview in subviews {
                subview.place(at: bounds.origin, anchor: .topLeading, proposal: .unspecified)
            }
            return
        }
        for (subview, frame) in zip(subviews, [arranged.tabs, arranged.dial]) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
        #if DEBUG
        if let probeKey {
            BookMastheadProbe.record(probeKey, .init(
                boundsWidth: bounds.width,
                decidedWidth: BookMastheadModeRowRule.decidingWidth(bounds.width),
                arrangement: arranged, tabsWidth: tabsWidth, dialWidest: dialWidest))
        }
        #endif
    }

    private func arrangement(width: CGFloat, subviews: Subviews) -> BookMastheadModeRowRule.Arrangement? {
        guard subviews.count == 2 else { return nil }
        func child(_ subview: LayoutSubview) -> BookMastheadModeRowRule.Child {
            BookMastheadModeRowRule.Child(
                size: { subview.sizeThatFits(ProposedViewSize(width: $0, height: nil)) },
                baseline: {
                    subview.dimensions(in: ProposedViewSize(width: $0, height: nil))[VerticalAlignment.firstTextBaseline]
                })
        }
        return BookMastheadModeRowRule.arrange(
            width: width, tabs: child(subviews[0]), dial: child(subviews[1]),
            tabsWidth: tabsWidth, dialWidest: dialWidest, gap: gap, lineSpacing: lineSpacing)
    }
}

// MARK: - The stable widths (the controls-row law's P-U3-5)

/// **What the wrap decision counts**: the tab row at the widest it can read
/// (whichever tab is active wears the semibold face) and the order dial at
/// its WIDEST form — measured in the voice's own `small` face, each word
/// rounded UP to a whole point as a SwiftUI `Text` sizes itself. Numbers that
/// move only when the voice does, never with what the book shows.
struct BookMastheadStableWidths: Equatable {
    var tabs: CGFloat
    var dial: CGFloat

    /// The masthead's stable widths in this voice — the tabs' own words
    /// (`BookView.tabOrder` / `tabLabel`) and every face the dial can draw
    /// (`BookOrderChoices.everyName` through `BookOrderDial.face`), resolved
    /// in the view's own font context; memoized per face, so a render never
    /// re-measures.
    static func row(tokens: VoiceTokens, in context: Font.Context) -> Self {
        let regular = tokens.small.resolve(in: context).ctFont as NSFont
        let active = tokens.small.weight(.semibold).resolve(in: context).ctFont as NSFont
        return measure(
            tabLabels: BookView.tabOrder.map { tokens.chromeLabel(BookView.tabLabel($0)) },
            dialFaces: BookOrderChoices.everyName.map { BookOrderDial.face(tokens, order: $0) },
            regular: regular, active: active, spacing: BookMastheadModeRowRule.tabSpacing)
    }

    private struct MemoKey: Hashable {
        var regular: String
        var active: String
        var size: CGFloat
        var tabLabels: [String]
        var dialFaces: [String]
        var spacing: CGFloat
    }

    private static var memo: [MemoKey: BookMastheadStableWidths] = [:]

    /// The measurement itself: the tab row as the `HStack` lays it (every
    /// word at its own width, `spacing` between) with each tab in turn in the
    /// active face, the widest of those; and the widest dial face.
    static func measure(
        tabLabels: [String], dialFaces: [String], regular: NSFont, active: NSFont, spacing: CGFloat
    ) -> Self {
        let key = MemoKey(
            regular: regular.fontName, active: active.fontName, size: regular.pointSize,
            tabLabels: tabLabels, dialFaces: dialFaces, spacing: spacing)
        if let known = memo[key] { return known }
        func width(_ text: String, _ font: NSFont) -> CGFloat {
            (text as NSString).size(withAttributes: [.font: font]).width.rounded(.up)
        }
        let plain = tabLabels.map { width($0, regular) }
        let bold = tabLabels.map { width($0, active) }
        let base = plain.reduce(0, +) + spacing * CGFloat(max(0, tabLabels.count - 1))
        let tabs = tabLabels.indices.map { base - plain[$0] + bold[$0] }.max() ?? base
        let measured = BookMastheadStableWidths(
            tabs: max(base, tabs), dial: dialFaces.map { width($0, regular) }.max() ?? 0)
        memo[key] = measured
        return measured
    }
}

// MARK: - The two faces the row lays out

/// **One mode tab's words** (the note masthead's grammar): the active mode
/// wears the semibold face and the accent, every other a muted word. The
/// tab's Button — its action and help — stays the book view's own
/// (`BookView.modeTab`); this is the face the stable width measures.
struct BookModeTabLabel: View {
    let tokens: VoiceTokens
    let label: String
    let active: Bool

    var body: some View {
        Text(tokens.chromeLabel(label))
            .font(active ? tokens.small.weight(.semibold) : tokens.small)
            .foregroundStyle(active ? tokens.accent : tokens.muted)
            // P-8: a chrome label never wraps — a compressed row must yield
            // elsewhere, not split a word.
            .lineLimit(1)
            .fixedSize()
    }
}

/// **The order dial** (13c 2D — A31: *"see a book either by its saved custom
/// order or by an attribute like time to freely change the order of it -
/// should be more like lenses where the order can be saved."*). The lens
/// grammar, exactly: picking an attribute is a way of LOOKING (view-local,
/// writes nothing, every other reader still sees the book's own order); "Save
/// as This Book's Order" is the adopt door (`setReadingSort`). A FINISHED book
/// browses freely and cannot save — its order is part of what "done" froze,
/// and the op refuses anyway.
///
/// Its FACE names the order and nothing else (VX-887 ruling 2 — the doubled
/// "order" gone; PROVISIONAL D-887-1): "Manual order ▾", "Entry date ↑ ▾",
/// "as collected ▾". Deliberately NOT `VoicedMenu`: that control carries
/// `.fixedSize()`, and a label forced to its ideal once pushed the whole
/// 190-pt navigator wider than its frame (the b6dae25 chrome-sizing class) —
/// this label TRUNCATES under a narrower offer instead (the menu still says
/// everything in full). The mode row offers it at least its widest form on
/// one line, so it truncates only on a line of its own narrower than it.
struct BookOrderDial: View {
    let tokens: VoiceTokens
    /// The book's own order, named (`BookOrderChoices.storedLabel`).
    let stored: String
    /// The way she is looking when it is not the book's own; nil = the
    /// book's order.
    let viewOrder: Queries.ReadingOrder?
    /// Whether "Save as This Book's Order" may draw (a finished book cannot
    /// save).
    let canSave: Bool
    /// A look picked (nil = back to the book's own order).
    let onLook: (Queries.ReadingOrder?) -> Void
    /// The adopt door.
    let onSave: (Queries.ReadingOrder) -> Void

    /// **The dial's face for an order's name** — the ONE spelling the dial
    /// draws and the stable width measures.
    static func face(_ tokens: VoiceTokens, order: String) -> String {
        tokens.chromeLabel(order) + " \u{25BE}"
    }

    /// The order the face names: the look, else the book's own.
    var shownOrder: String {
        viewOrder.map(BookOrderChoices.label(for:)) ?? stored
    }

    var body: some View {
        Menu {
            Button {
                onLook(nil)
            } label: {
                if viewOrder == nil {
                    Label("This book's order (\(stored))", systemImage: "checkmark")
                } else {
                    Text("This book's order (\(stored))")
                }
            }
            Divider()
            ForEach(BookOrderChoices.all) { choice in
                Button {
                    onLook(choice.order)
                } label: {
                    if viewOrder == choice.order {
                        Label(choice.label, systemImage: "checkmark")
                    } else {
                        Text(choice.label)
                    }
                }
            }
            if let order = viewOrder, canSave {
                Divider()
                Button("Save as This Book's Order") { onSave(order) }
            }
        } label: {
            Text(Self.face(tokens, order: shownOrder))
                .font(tokens.small)
                .foregroundStyle(viewOrder == nil ? tokens.muted : tokens.accent)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .help("Look at this book in a different order — nothing is written until "
            + "you save it as the book's own order.")
    }
}

// MARK: - The DEBUG probe

#if DEBUG
/// **VX-887 — the mode row as the layout PLACED it**, keyed by the book's id
/// (the `BookNameProbe` / `LibraryControlsFlowTrace` pattern: DEBUG only,
/// silent unless a host hands a key). Recorded by the layout's placement pass
/// — the arrangement the row actually drew — plus the dial's drawn face.
/// `nonisolated(unsafe)`: the layout's entry points are nonisolated
/// (`Layout`'s requirements) and SwiftUI runs them on the main thread, where
/// the pins read them.
nonisolated enum BookMastheadProbe {
    struct Placement: Equatable, Sendable {
        /// The width the row was placed in, and the whole point it decided at.
        var boundsWidth: CGFloat
        var decidedWidth: CGFloat
        var arrangement: BookMastheadModeRowRule.Arrangement
        /// The stable widths the decision counted.
        var tabsWidth: CGFloat
        var dialWidest: CGFloat
    }

    /// The LAST placement per book — one entry per book a session opens (a
    /// Debug app records on every layout pass, so nothing here may grow with
    /// them; a sweep pin reads this after each step).
    nonisolated(unsafe) static var placed: [String: Placement] = [:]
    /// The dial's face as drawn, keyed by the book's id.
    nonisolated(unsafe) static var dialFace: [String: String] = [:]

    static func record(_ key: String, _ placement: Placement) {
        placed[key] = placement
    }

    static func reset(_ key: String) {
        placed[key] = nil
        dialFace[key] = nil
    }
}
#endif

extension View {
    /// Records the order dial's drawn face for `key` (a no-op outside DEBUG).
    @ViewBuilder
    func bookOrderDialProbe(_ key: String, face: String) -> some View {
        #if DEBUG
        onAppear { BookMastheadProbe.dialFace[key] = face }
            .onChange(of: face) { _, now in BookMastheadProbe.dialFace[key] = now }
        #else
        self
        #endif
    }
}
