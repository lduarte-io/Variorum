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
//  across the four active tabs (`BookMastheadStableWidths.tabs`), and the
//  dial at the stable width of the FACE IT SHOWS (`.dial` — that face's words
//  measured in the voice's own font, never the live control's size).
//
//  **VX-896 (the VX-914 run, batch 3 — her Nov 7 walkthrough):** *"it should
//  go on the row above as soon as it would have standard spacing that the
//  others have, it's weird it needs such a wide gap to go up."* The dial was
//  counted at the WIDEST face it could ever draw ("Major revision ↓ ▾"), so
//  "Manual order ▾" joined the modes only past 257 pt of masthead in Study
//  (304 in Terminal) — ≈ 25 pt of air at the threshold. It is counted at the
//  face it SHOWS now (PROVISIONAL F-896 (1), ruled): one line from 240 pt in
//  Study (276 in Terminal) for "Manual order ▾", at standard spacing (the
//  8-pt gap — the tabs' own). Typing a title, a mode switched or the active
//  tab still never changes the line count; a LOOK picked whose face is wider
//  than the room can (the dial then needs more than standard spacing allows)
//  — the input R-878-K4's strict count held still, superseded there (the
//  record names it) — and so can the book's own stored order changing to a
//  wider or narrower face, whether saved here or arriving by sync from
//  another device (the same consequence, one input over). It never truncates
//  on one line.
//
//  **The VX-914 ladder's F1:** the book's row LANDING never moves it — the
//  row (tabs and dial, one decision) is drawn only once `BookView` holds the
//  book's row, so its first paint counts the real face and the placeholder
//  "book's order ▾" is never counted (`BookView.bookMasthead`).
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
    /// tabs' own spacing, "the standard spacing that the others have" (VX-896:
    /// the dial is counted at the face it shows, so at the threshold the air
    /// it shows IS this gap).
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
    /// dial at its counted width (VX-896: the stable width of the face it
    /// shows).
    static func countedLine(tabs: CGFloat, dialCounted: CGFloat, gap: CGFloat = gap) -> CGFloat {
        tabs + gap + dialCounted
    }

    /// **The class, decided** from the counted (stable) widths alone — never
    /// a live label. An unbounded width (the ideal query) is one line.
    static func widthClass(
        width: CGFloat, tabs: CGFloat, dialCounted: CGFloat, gap: CGFloat = gap
    ) -> WidthClass {
        guard width.isFinite else { return .oneLine }
        return countedLine(tabs: tabs, dialCounted: dialCounted, gap: gap) <= width ? .oneLine : .twoLines
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
        tabsWidth: CGFloat, dialCounted: CGFloat,
        gap: CGFloat = gap, lineSpacing: CGFloat = lineSpacing
    ) -> Arrangement {
        let width = decidingWidth(offered)
        let decided = widthClass(width: width, tabs: tabsWidth, dialCounted: dialCounted, gap: gap)
        let rowWidth = width.isFinite
            ? max(0, width) : countedLine(tabs: tabsWidth, dialCounted: dialCounted, gap: gap)
        let tabsSize = tabs.size(rowWidth)
        switch decided {
        case .oneLine:
            // The dial is offered the room right of the tabs — never less
            // than its counted face while the class holds, so it never
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
    /// The dial's COUNTED width — the stable width of the face it shows
    /// (`BookMastheadStableWidths.dial`, VX-896).
    var dialCounted: CGFloat
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
                arrangement: arranged, tabsWidth: tabsWidth, dialCounted: dialCounted))
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
            tabsWidth: tabsWidth, dialCounted: dialCounted, gap: gap, lineSpacing: lineSpacing)
    }
}

// MARK: - The stable widths (the controls-row law's P-U3-5)

/// **What the wrap decision counts**: the tab row at the widest it can read
/// (whichever tab is active wears the semibold face) and the order dial at
/// the face it SHOWS (VX-896 — it was the widest face it could ever draw) —
/// measured in the voice's own `small` face, each word rounded UP to a whole
/// point as a SwiftUI `Text` sizes itself. The tab number moves only when the
/// voice does; the dial's only when its face's WORDS do (a look picked, the
/// book's own order saved here or arriving by sync) — never with a title, a
/// mode or a landing (the row waits for the book's row — the ladder's F1).
struct BookMastheadStableWidths: Equatable {
    var tabs: CGFloat
    var dial: CGFloat

    /// The masthead's stable widths in this voice — the tabs' own words
    /// (`BookModeTabs` — `BookView.tabOrder` / `tabLabel`) and the dial's drawn `face`
    /// (`BookOrderDial.face` of `BookOrderDial.shownOrder` — the ONE spelling
    /// the dial draws), resolved in the view's own font context; memoized per
    /// face, so a render never re-measures.
    static func row(tokens: VoiceTokens, in context: Font.Context, face: String) -> Self {
        let regular = tokens.small.resolve(in: context).ctFont as NSFont
        let active = tokens.small.weight(.semibold).resolve(in: context).ctFont as NSFont
        return measure(
            tabLabels: BookModeTabs.order.map { tokens.chromeLabel(BookModeTabs.label($0)) },
            dialFaces: [face],
            regular: regular, active: active, spacing: BookMastheadModeRowRule.tabSpacing)
    }

    /// **VX-1091 — the tab row's stable width alone** (the navigator's floor
    /// reads it): the same measure, memoized, with no dial face.
    static func tabs(tokens: VoiceTokens, in context: Font.Context) -> CGFloat {
        let regular = tokens.small.resolve(in: context).ctFont as NSFont
        let active = tokens.small.weight(.semibold).resolve(in: context).ctFont as NSFont
        return measure(
            tabLabels: BookModeTabs.order.map { tokens.chromeLabel(BookModeTabs.label($0)) },
            dialFaces: [],
            regular: regular, active: active, spacing: BookMastheadModeRowRule.tabSpacing).tabs
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
    /// active face, the widest of those; and the widest of the dial faces
    /// given (the masthead hands the one it shows).
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
/// (VX-896: "at least its widest form" became "at least the face it shows" —
/// still never truncated on one line.)
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
    /// **VX-1040 (D-1, R-1036-33) — what a pick means on this book**
    /// (`Grammar.of`, over the pure `BookOrderPick`). Defaulted to the
    /// browse grammar that stood before it (a book whose row has not landed).
    var grammar: Grammar = .browse
    /// The book's own stored order — the check on a menu whose picks save.
    var storedOrder: Queries.ReadingOrder? = nil
    /// A gathering's dial: its `manual` reads "As collected" (it has no hand
    /// order — `BookOrderChoices.storedLabel`'s rule).
    var gathering: Bool = false

    /// **VX-1040 — the dial's three grammars.**
    enum Grammar: Equatable, Sendable {
        /// A pick is a look; "Save as This Book's Order" draws where the book
        /// can save — the A31 grammar as it stood, kept for a FINISHED book
        /// (which looks and can never save) and a book not yet loaded.
        case browse
        /// A pick IS the book's order, saved at once (a gathering; a book
        /// whose stored order is not manual) — the receipt says so.
        case pickSaves
        /// A HAND-ORDERED book: a pick stays a look, and while one is on,
        /// "Save as This Book's Order" and "Back to manual order" both stand in
        /// plain sight — in the menu and under the mode row.
        case handOrdered

        static func of(_ reading: Reading?) -> Grammar {
            guard let reading else { return .browse }
            switch BookOrderPick.meaning(for: reading) {
            case .save: return .pickSaves
            case .look: return reading.locked ? .browse : .handOrdered
            }
        }
    }

    /// What one menu row does.
    enum Act: Equatable, Sendable {
        /// Look through this order (nil: the book's own).
        case look(Queries.ReadingOrder?)
        /// Save this order as the book's own.
        case save(Queries.ReadingOrder)
    }

    /// One row of the dial's menu, as the menu draws it.
    enum MenuItem: Equatable, Sendable {
        case item(label: String, checked: Bool, act: Act)
        case divider
    }

    /// The words the hand-ordered grammar's two doors speak (the menu's and
    /// the masthead's quiet pair under the mode row — mockup frame 9b).
    static let saveVerb = BookOrderDialCopy.saveVerb
    static let backToManual = BookOrderDialCopy.backToManual

    /// **The menu, pure** — the rows `body` draws, in order, so a pin reads
    /// each book kind's menu without opening one.
    static func menu(
        grammar: Grammar, stored: String, storedOrder: Queries.ReadingOrder?,
        viewOrder: Queries.ReadingOrder?, canSave: Bool, gathering: Bool
    ) -> [MenuItem] {
        let ownRow = "This book's order (\(stored))"
        switch grammar {
        case .browse:
            var rows: [MenuItem] = [.item(label: ownRow, checked: viewOrder == nil, act: .look(nil)), .divider]
            rows += BookOrderChoices.all.map {
                .item(label: $0.label, checked: viewOrder == $0.order, act: .look($0.order))
            }
            if let viewOrder, canSave {
                rows += [.divider, .item(label: saveVerb, checked: false, act: .save(viewOrder))]
            }
            return rows
        case .pickSaves:
            var rows: [MenuItem] = []
            let shown = viewOrder ?? storedOrder
            // A look left standing (the stored order changed under it — a save
            // elsewhere, or sync) is let go from here; an UNLISTED stored order
            // (the wire may store any pair) is named so it can be seen.
            if viewOrder != nil {
                rows += [.item(label: ownRow, checked: false, act: .look(nil)), .divider]
            } else if let storedOrder, !BookOrderChoices.all.contains(where: { $0.order == storedOrder }) {
                rows += [.item(label: ownRow, checked: true, act: .look(nil)), .divider]
            }
            rows += BookOrderChoices.all.map { choice in
                let label = gathering && choice.order.field == .manual
                    ? BookOrderChoices.asCollectedLabel : choice.label
                // The book's own order is no pick to save: it lets a look go.
                let act: Act = choice.order == storedOrder ? .look(nil) : .save(choice.order)
                return .item(label: label, checked: shown == choice.order, act: act)
            }
            return rows
        case .handOrdered:
            var rows: [MenuItem] = [
                viewOrder == nil
                    ? .item(label: ownRow, checked: true, act: .look(nil))
                    : .item(label: backToManual, checked: false, act: .look(nil)),
                .divider,
            ]
            // Manual is the book's own order — its row leads; the list offers
            // the looks.
            rows += BookOrderChoices.all.filter { $0.order.field != .manual }.map {
                .item(label: $0.label, checked: viewOrder == $0.order, act: .look($0.order))
            }
            if let viewOrder, canSave {
                rows += [.divider, .item(label: saveVerb, checked: false, act: .save(viewOrder))]
            }
            return rows
        }
    }

    /// The hover, by grammar.
    static func help(_ grammar: Grammar, gathering: Bool) -> String {
        switch grammar {
        case .browse:
            return "Look at this book in a different order \u{2014} nothing is written until "
                + "you save it as the book\u{2019}s own order."
        case .pickSaves:
            return gathering
                ? "Choose the order this gathering reads in \u{2014} your pick is saved as its order."
                : "Choose this book\u{2019}s order \u{2014} your pick is saved as the book\u{2019}s order."
        case .handOrdered:
            return "Look at this book in a different order \u{2014} your hand order stays until "
                + "you save the look as the book\u{2019}s order."
        }
    }

    /// **The dial's face for an order's name** — the ONE spelling the dial
    /// draws and the stable width measures.
    static func face(_ tokens: VoiceTokens, order: String) -> String {
        tokens.chromeLabel(order) + " \u{25BE}"
    }

    /// The order the face names: the look, else the book's own.
    var shownOrder: String { Self.shownOrder(stored: stored, viewOrder: viewOrder) }

    /// VX-896: the ONE rule for the order the face names — the dial draws it
    /// and the mode row counts it (`BookMastheadStableWidths.row(face:)`), so
    /// the two can never disagree.
    static func shownOrder(stored: String, viewOrder: Queries.ReadingOrder?) -> String {
        viewOrder.map(BookOrderChoices.label(for:)) ?? stored
    }

    var body: some View {
        Menu {
            let items = Self.menu(
                grammar: grammar, stored: stored, storedOrder: storedOrder,
                viewOrder: viewOrder, canSave: canSave, gathering: gathering)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                switch item {
                case .divider:
                    Divider()
                case .item(let label, let checked, let act):
                    Button {
                        switch act {
                        case .look(let order): onLook(order)
                        case .save(let order): onSave(order)
                        }
                    } label: {
                        if checked {
                            Label(label, systemImage: "checkmark")
                        } else {
                            Text(label)
                        }
                    }
                }
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
        .help(Self.help(grammar, gathering: gathering))
    }
}

/// **VX-1040 — the order dial's words** (nonisolated, so the registry's
/// declaration reads the very words the dial draws — `.saveBookOrder`).
nonisolated enum BookOrderDialCopy {
    static let saveVerb = "Save as This Book's Order"
    static let backToManual = "Back to manual order"
    static let unavailableNote =
        "A finished book\u{2019}s order can\u{2019}t be saved \u{2014} reopen the book to change its order."
}

/// **VX-1040 — the hand-ordered book's two doors in plain sight** (D-1 as
/// drawn — the round-1 mockup's frame 9b): while a look is on, under the mode
/// row at its trailing edge, "save as this book's order" (the accent) over
/// "back to manual order" (muted) — the menu's two rows, the same acts. Drawn
/// only in the hand-ordered grammar with a look on and a book that can save;
/// "it costs two short lines on the masthead while a look is on".
struct BookOrderLookDoors: View {
    let tokens: VoiceTokens
    let onSave: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            Button(tokens.chromeLabel("Save as this book's order"), action: onSave)
                .foregroundStyle(tokens.accent)
                .help("Save this look as the order every reader of the book sees")
            Button(tokens.chromeLabel(BookOrderDial.backToManual), action: onBack)
                .foregroundStyle(tokens.muted)
                .help("Back to the order you set by hand \u{2014} it was kept all along")
        }
        .buttonStyle(.borderless)
        .font(tokens.small)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .trailing)
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
        /// The stable widths the decision counted (VX-896: the dial's is the
        /// face it showed).
        var tabsWidth: CGFloat
        var dialCounted: CGFloat
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
