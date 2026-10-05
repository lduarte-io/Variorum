//
//  BookcaseStrip.swift
//  Variorum (Mac)
//
//  13i-d U1 — **THE SHELF STRIP** (the sitting record §7, §21, §23, §24;
//  mockup v5's State A — its SHAPE and idiom, the app's own tokens, never its
//  rounded edges, §22).
//
//  ONE line under the masthead, nothing above it (§23: *"the shelf options
//  themselves can't have anything above them — they're a STRONG
//  subheading"*):
//
//      All · Welcome · The Work · ☾ Night …  ⋯  + shelf      № · order ▾ · details
//
//  - The names are a MODE ROW (§21): muted words, the active one in ink and
//    weight — no underline, no pills, no fills. Counts are whispered on
//    hover. The line never wraps; past the room it has it scrolls
//    horizontally under a trailing edge fade, and a pinned ⋯ opens the
//    type-to-filter shelf panel (§24).
//  - Every name is a DROP TARGET (a book re-shelves onto it; a dragged name
//    reorders before it) and the only rectangle the strip ever draws is the
//    hairline outline while something hovers over a name (§7).
//  - Right-click a name: Rename · Set Glyph · Make Default · Move to Start ·
//    Move to End · Delete (§7, §24) — `ShelfMenu`, ONE builder the strip, the
//    ⋯ panel and All's section headers all render.
//  - The utility run (§23): № (the census, collapsed by default to just the
//    mark) · order ▾ (§24) · details (§21/§23). Clear air before it (her
//    build note, spaced by the app's own measure).
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

// MARK: - Dragging books and shelves (one in-app payload)

/// What a Bookcase drag carries: a BOOK (re-shelve / place by hand) or a
/// SHELF (reorder the strip).
nonisolated enum BookcaseDrag: Equatable, Sendable {
    case book(String)
    case shelf(String)
}

/// **The transport** — its own transfer type, the `OpenNoteDragToken`
/// precedent exactly (SwiftUI's `Transferable` road, the one every drag in
/// the app rides): deliberately not a plain String, so a dragged book can
/// never be mistaken for a NOTE's id by the book rows' `.plainText` drop, and
/// never imported as a note's text by the sidebar's file/text drop.
///
/// *(The walk's finding, recorded so it is not re-met: a first build carried
/// the payload on a hand-registered `NSItemProvider` + `onDrop(of:)`; the drag
/// session STARTED — the row's image followed the pointer — but no target
/// ever lit, so nothing landed. The `Transferable` road is the proven one.)*
nonisolated struct BookcaseDragToken: Codable, Transferable, Sendable {
    let kind: String
    let id: String

    init(_ drag: BookcaseDrag) {
        switch drag {
        case .book(let id): (kind, self.id) = ("book", id)
        case .shelf(let id): (kind, self.id) = ("shelf", id)
        }
    }

    var drag: BookcaseDrag? {
        switch kind {
        case "book": .book(id)
        case "shelf": .shelf(id)
        default: nil
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: UTType(exportedAs: "io.lduarte.variorum.bookcase-item"))
    }
}

/// The one drop-site modifier every Bookcase target wears (strip names, the
/// ⋯ panel's rows, All's section headers, the book rows in my order): it
/// decodes the token and reports hover for the hairline.
private struct BookcaseDropSite: ViewModifier {
    let enabled: Bool
    let onHover: (Bool) -> Void
    let onDrop: @MainActor (BookcaseDrag) -> Void

    func body(content: Content) -> some View {
        if enabled {
            content.dropDestination(for: BookcaseDragToken.self) { tokens, _ in
                guard let drag = tokens.first?.drag else { return false }
                onDrop(drag)
                return true
            } isTargeted: { onHover($0) }
        } else {
            content
        }
    }
}

extension View {
    /// A Bookcase drop target (a no-op when `enabled` is false — the book
    /// rows outside my order, P-2).
    func bookcaseDropSite(
        enabled: Bool = true, onHover: @escaping (Bool) -> Void,
        onDrop: @escaping @MainActor (BookcaseDrag) -> Void
    ) -> some View {
        modifier(BookcaseDropSite(enabled: enabled, onHover: onHover, onDrop: onDrop))
    }
}

// MARK: - The shelf menu (one builder, three renderers)

/// What a shelf menu can ask its host to present (the alerts and the glyph
/// sheet live in `ShelfView`, which owns the presentation state).
struct ShelfMenuActions {
    let rename: (Shelf) -> Void
    let setGlyph: (Shelf) -> Void
    let delete: (Shelf) -> Void
}

struct ShelfMenu: View {
    let shelf: Shelf
    let model: ShelfViewModel
    let actions: ShelfMenuActions

    var body: some View {
        Button(CapabilityRegistry.capability(.renameShelf).verb) { actions.rename(shelf) }
        Button(CapabilityRegistry.capability(.setShelfGlyph).verb) { actions.setGlyph(shelf) }
        if model.defaultShelfID == shelf.id {
            // The same act's other direction — the default is a toggle.
            Button(BookcaseCopy.openOnAllVerb) { model.makeDefault(nil) }
        } else {
            Button(CapabilityRegistry.capability(.makeDefaultShelf).verb) { model.makeDefault(shelf.id) }
        }
        // P-2: a door that cannot act is not rendered — the first shelf has
        // no "start" to move to, the last no "end".
        if model.shelves.first?.id != shelf.id {
            Button(CapabilityRegistry.capability(.moveShelfToStart).verb) {
                Task { await model.moveShelf(shelf.id, to: .start) }
            }
        }
        if model.shelves.last?.id != shelf.id {
            Button(CapabilityRegistry.capability(.moveShelfToEnd).verb) {
                Task { await model.moveShelf(shelf.id, to: .end) }
            }
        }
        Divider()
        Button(CapabilityRegistry.capability(.deleteShelf).verb, role: .destructive) {
            actions.delete(shelf)
        }
    }
}

// MARK: - The strip

struct BookcaseStrip: View {
    /// P-1's walk: the acts the shelf menu renders (strip names, the ⋯
    /// panel's rows and All's section headers — one builder, `ShelfMenu`).
    static let contextMenuCapabilities: [CapabilityID] = [
        .renameShelf, .setShelfGlyph, .makeDefaultShelf,
        .moveShelfToStart, .moveShelfToEnd, .deleteShelf,
    ]
    /// The one inline door: the "+ shelf" word.
    static let surfaceCapabilities: [CapabilityID] = [.newShelf]

    let model: ShelfViewModel
    let tokens: VoiceTokens
    let menuActions: ShelfMenuActions
    let onNewShelf: () -> Void

    @State private var contentWidth: CGFloat = 0
    @State private var visibleWidth: CGFloat = 0
    @State private var dropTarget: String?
    @State private var panelShown = false

    private var overflowed: Bool { contentWidth > visibleWidth + 0.5 }

    var body: some View {
        // CENTER, not baseline: a ScrollView publishes no text baseline, so a
        // baseline row set the names above the rest of the line (the walk).
        HStack(alignment: .center, spacing: 14) {
            names
            if overflowed {
                Button("\u{22EF}") { panelShown.toggle() }
                    .buttonStyle(.plain)
                    .font(tokens.navigation)
                    .foregroundStyle(tokens.muted)
                    .help("Every shelf — type to find one")
                    .popover(isPresented: $panelShown, arrowEdge: .bottom) {
                        ShelfOverflowPanel(
                            model: model, tokens: tokens, menuActions: menuActions,
                            close: { panelShown = false })
                    }
            }
            Button(tokens.chromeLabel("+ shelf")) { onNewShelf() }
                .buttonStyle(.plain)
                .font(tokens.navigation)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
                .fixedSize()
                .help("Make a new shelf at the end of the strip")
            // Clear air between the shelf names and the utility run (her
            // build note, §24) — the app's own measure, never a pixel copy.
            Spacer(minLength: 36)
            utilityRun
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // MARK: The names (one line; scrolls; fades at the trailing edge)

    private var names: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .firstTextBaseline, spacing: 22) {
                word(
                    "All", active: model.effectiveScope == .all,
                    help: "Every shelf, stacked in strip order — unshelved books on top"
                ) { model.scope = .all }
                ForEach(model.shelves, id: \.id) { shelf in
                    shelfName(shelf)
                }
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 4)
            .lineLimit(1)  // 19g: the strip is one line by contract (P-8)
            .fixedSize()
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { contentWidth = $0 }
        }
        .frame(maxWidth: contentWidth > 0 ? contentWidth : nil, alignment: .leading)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { visibleWidth = $0 }
        .mask {
            // The trailing edge FADE, only while the line overflows (§24).
            if overflowed {
                LinearGradient(
                    stops: [.init(color: .black, location: 0),
                            .init(color: .black, location: max(0, 1 - 28 / max(visibleWidth, 1))),
                            .init(color: .clear, location: 1)],
                    startPoint: .leading, endPoint: .trailing)
            } else {
                Rectangle()
            }
        }
        .layoutPriority(-1)
    }

    private func shelfName(_ shelf: Shelf) -> some View {
        let count = model.shelfCounts[shelf.id] ?? 0
        let isDefault = model.defaultShelfID == shelf.id
        return word(
            ShelfFace.label(shelf), active: model.effectiveScope == .shelf(shelf.id),
            help: "\(count) \(count == 1 ? "book" : "books")" + (isDefault ? " · opens here" : "")
        ) { model.scope = .shelf(shelf.id) }
        .overlay {
            // §7: the ONLY rectangle the strip draws — a hairline while a
            // book or a name hovers over this one.
            if dropTarget == shelf.id {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(tokens.line, lineWidth: 1)
                    .padding(-4)
            }
        }
        .draggable(BookcaseDragToken(.shelf(shelf.id)))
        .bookcaseDropSite(
            onHover: { dropTarget = $0 ? shelf.id : (dropTarget == shelf.id ? nil : dropTarget) }
        ) { payload in
            switch payload {
            case .book(let readingID):
                Task { await model.reshelve(readingID, to: shelf.id) }
            case .shelf(let draggedID):
                guard draggedID != shelf.id else { return }
                Task { await model.moveShelf(draggedID, to: .before(shelf.id)) }
            }
        }
        .contextMenu { ShelfMenu(shelf: shelf, model: model, actions: menuActions) }
    }

    /// One strip word (the mode-row idiom, §21): muted, or ink + weight.
    private func word(
        _ text: String, active: Bool, help: String, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(tokens.chromeLabel(text))
                .font(tokens.navigation)
                .fontWeight(active ? .semibold : .regular)
                .foregroundStyle(active ? tokens.ink : tokens.muted)
                .lineLimit(1)
                .fixedSize()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }

    // MARK: The utility run — № · order ▾ · details

    private var utilityRun: some View {
        HStack(alignment: .center, spacing: 10) {
            Button("\u{2116}") { model.censusOpen.toggle() }
                .buttonStyle(.plain)
                .font(tokens.small)
                // A solo in force is never invisible: the mark wears ink and
                // weight while the board is filtered.
                .fontWeight(model.solo != nil ? .semibold : .regular)
                .foregroundStyle(model.solo != nil || model.censusOpen ? tokens.ink : tokens.muted)
                .lineLimit(1)
                .fixedSize()
                .help(censusHelp)
            StatusDot(tokens: tokens)
            VoicedMenu(
                tokens: tokens, label: "order \u{00B7} \(model.orderMode.label)", role: .quiet
            ) {
                // An inline picker: the menu's native checkmark marks the
                // order in force (a `Label` image drew nothing — the walk).
                Picker("", selection: Binding(
                    get: { model.orderMode },
                    set: { mode in
                        model.orderMode = mode
                        if mode == .lastEdited { Task { await model.refreshAggregates() } }
                    })
                ) {
                    ForEach(BookcaseOrderMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .help("A\u{2013}Z · last edited · my order — "
                + "\u{201C}my order\u{201D} is where you place books by hand")
            StatusDot(tokens: tokens)
            Button(tokens.chromeLabel("details")) { model.detailsShown.toggle() }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(model.detailsShown ? tokens.muted : tokens.faint)
                .lineLimit(1)
                .fixedSize()
                .help(model.detailsShown
                    ? "Hide the counts, words and status at each row's end"
                    : "Show the counts, words and status at each row's end")
        }
        .lineLimit(1)  // 19g: a one-line counts row (P-8)
        .fixedSize()
    }

    /// Hover reveals the counts while the № is collapsed (§19(c)'s "hover to
    /// reveal while collapsed", carried onto the № by §23).
    private var censusHelp: String {
        let census = model.census
        let line = BookcaseSolo.allCases
            .map { $0.label(count: census[$0] ?? 0) }
            .joined(separator: " · ")
        if let solo = model.solo {
            return "Showing only: \(solo.label(count: census[solo] ?? 0)) — \(line)"
        }
        return line
    }
}

// MARK: - The № census panel (§23)

/// Every count, each row a SOLO filter — click to solo, again to clear. A
/// zero row is faint and inert (P-2: it could only empty the board).
struct BookcaseCensusPanel: View {
    let model: ShelfViewModel
    let tokens: VoiceTokens

    var body: some View {
        let census = model.census
        VStack(alignment: .leading, spacing: 0) {
            ForEach(BookcaseSolo.allCases, id: \.self) { solo in
                let count = census[solo] ?? 0
                let active = model.solo == solo
                Button {
                    model.toggleSolo(solo)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text(tokens.chromeLabel(solo.label(count: count)))
                            .fontWeight(active ? .semibold : .regular)
                            .foregroundStyle(active ? tokens.ink : (count == 0 ? tokens.faint : tokens.muted))
                            .lineLimit(1)
                        Spacer(minLength: 12)
                        Text(tokens.chromeLabel(active ? "clear" : "solo"))
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .opacity(count == 0 && !active ? 0 : 1)
                    }
                    .font(tokens.small)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(count == 0 && !active)
            }
        }
        .padding(.vertical, 5)
        .frame(width: 220)
        // The BOARD's own ground (`surface`), so the panel reads as part of
        // the page under a hairline — never a tinted card (the walk).
        .background(tokens.surface)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1))
    }
}

// MARK: - The ⋯ shelf panel (type-to-filter, §7/§24)

struct ShelfOverflowPanel: View {
    let model: ShelfViewModel
    let tokens: VoiceTokens
    let menuActions: ShelfMenuActions
    let close: () -> Void

    @State private var filter = ""
    @State private var dropTarget: String?
    @FocusState private var focused: Bool

    private var matches: [Shelf] {
        let query = filter.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return model.shelves }
        return model.shelves.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Find a shelf", text: $filter)
                .textFieldStyle(.plain)
                .font(tokens.small)
                .focused($focused)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .onSubmit {
                    if let first = matches.first {
                        model.scope = .shelf(first.id)
                        close()
                    }
                }
            Divider().overlay(tokens.line)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(matches, id: \.id) { shelf in
                        row(shelf)
                    }
                    if matches.isEmpty {
                        Text(tokens.chromeLabel("No shelf matches."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .padding(10)
                    }
                }
            }
            .frame(maxHeight: 280)
            // Hug a short list; scroll a long one (the Starred section's
            // shape, `SidebarView`).
            .fixedSize(horizontal: false, vertical: matches.count <= 9)
        }
        .padding(.vertical, 6)
        .frame(width: 240)
        .background(tokens.room)
        .onAppear { focused = true }
    }

    private func row(_ shelf: Shelf) -> some View {
        let active = model.effectiveScope == .shelf(shelf.id)
        let count = model.shelfCounts[shelf.id] ?? 0
        return Button {
            model.scope = .shelf(shelf.id)
            close()
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Text(tokens.chromeLabel(ShelfFace.label(shelf)))
                    .fontWeight(active ? .semibold : .regular)
                    .foregroundStyle(active ? tokens.ink : tokens.muted)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text("\(count)")
                    .foregroundStyle(tokens.faint)
            }
            .font(tokens.navigation)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay {
            if dropTarget == shelf.id {
                RoundedRectangle(cornerRadius: 3).stroke(tokens.line, lineWidth: 1)
            }
        }
        // Reorder by dragging the panel's rows (§7, ruled) — and a book
        // dropped here re-shelves, exactly as on a strip name.
        .draggable(BookcaseDragToken(.shelf(shelf.id)))
        .bookcaseDropSite(
            onHover: { dropTarget = $0 ? shelf.id : (dropTarget == shelf.id ? nil : dropTarget) }
        ) { payload in
            switch payload {
            case .book(let readingID):
                Task { await model.reshelve(readingID, to: shelf.id) }
            case .shelf(let draggedID):
                guard draggedID != shelf.id else { return }
                Task { await model.moveShelf(draggedID, to: .before(shelf.id)) }
            }
        }
        .contextMenu { ShelfMenu(shelf: shelf, model: model, actions: menuActions) }
    }
}

// MARK: - A shelf's face (glyph + name)

nonisolated enum ShelfFace {
    /// "☾ Night" — the glyph inherits the text's ink (§7: monochrome); the
    /// name is hers, set as she typed it.
    static func label(_ shelf: Shelf) -> String {
        if let glyph = shelf.glyph, !glyph.isEmpty { return glyph + "\u{2009}" + shelf.name }
        return shelf.name
    }
}
