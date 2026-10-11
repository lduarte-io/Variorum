//
//  SearchPicker.swift
//  Variorum (Mac) — Core/Views (the shared home: the rule editor, the outflow
//  chooser and the add-to-book door all render it)
//
//  17y items (g) + (o) — **THE ONE PICKER CONTROL** (R-17y-3: one control,
//  type-to-filter + create-in-place, on the ruled three surfaces; every
//  other tag picker adopts it at its next touch — the B3 RECORD lists them).
//  Her words at the walk, of the rule editor's "+ tag ▾" menu: "this is the
//  exact sort of selector that looks really bad when you have a lot of
//  different options — we should build for the need to search through tags
//  now."
//
//  The control is a quiet word (the menu's old face — "+ tag", "Add to
//  Book") that opens a POPOVER: a search field (focused), the options the
//  query matches, and — when the host can make one — a CREATE row naming
//  exactly what it will make ('New tag "#x"', 'New book "X"'). Return takes
//  the first match, or the create row when nothing matches; Escape closes.
//
//  Two pieces, split by concern (P-9): the BRAIN (`SearchPickerBrain` — pure:
//  which options a query shows, and whether a create row is offered — pinned)
//  and the FACE (`SearchPicker` — renders and sends).
//
//  13n-c U2 (VX-156 item 1 — the grant road adopts the ONE picker at its next
//  touch, R-17y-3) — OPTIONAL SECTIONS, for a list of hundreds: a host may
//  hand ARRANGEMENTS (each a list of titled sections — the grant sheet's "by
//  shelf" and "a–z") instead of a flat list. QUICK sections ("Recently
//  edited", "Starred") repeat rows that live in a home section and show only
//  before typing; once she types, every home section filters and a match
//  shows ONCE, under its home. A host may instead hand an async SOURCE (the
//  note feed — bounded, queried per keystroke, latest wins). A row may carry
//  a second DETAIL line (a book's context, a note's snippet) and an
//  EMPHASIZED annotation (the distinguisher). The trigger may be a FIELD (the
//  chosen value with its annotation, ▾) rather than the quiet word. Every
//  addition defaults off: the flat hosts render byte-for-byte as before (the
//  parity proof is their suites, unedited).
//

import SwiftUI
import VariorumCore

/// One option the picker offers.
nonisolated struct SearchPickerOption: Identifiable, Equatable, Sendable {
    let id: String
    /// What the row says (a tag's "#path", a book's name — hers, never chrome).
    let label: String
    /// The quiet context beside it ("archived", "by tagging", "finished").
    var annotation: String?
    /// What the query is matched against (defaults to the label).
    var searchText: String?
    /// 13n-c U2 — a second, quieter line under the row (a book's context
    /// line, a note's snippet); nil = the one-line row as ever.
    var detail: String?
    /// 13n-c U2 — the annotation is the fact that TELLS this row apart (the
    /// collision ladder's distinguisher): drawn in accent ink, not faint.
    var emphasized: Bool = false

    init(
        id: String, label: String, annotation: String? = nil, searchText: String? = nil,
        detail: String? = nil, emphasized: Bool = false
    ) {
        self.id = id
        self.label = label
        self.annotation = annotation
        self.searchText = searchText
        self.detail = detail
        self.emphasized = emphasized
    }
}

/// 13n-c U2 — one titled group of options (a shelf, "Starred", "Recently
/// edited").
nonisolated struct SearchPickerSection: Identifiable, Equatable, Sendable {
    let id: String
    /// The header; nil draws none.
    let title: String?
    let options: [SearchPickerOption]
    /// A QUICK section repeats rows whose HOME is another section; it shows
    /// only before typing (so a match never shows twice).
    var isQuick: Bool = false

    init(id: String, title: String?, options: [SearchPickerOption], isQuick: Bool = false) {
        self.id = id
        self.title = title
        self.options = options
        self.isQuick = isQuick
    }
}

/// 13n-c U2 — one way of laying the same options out ("by shelf", "a–z").
nonisolated struct SearchPickerArrangement: Identifiable, Equatable, Sendable {
    let id: String
    /// The toggle's word (sentence case).
    let label: String
    let sections: [SearchPickerSection]
}

/// **THE BRAIN** — pure, so the pins read it without a window.
nonisolated enum SearchPickerBrain {
    /// The query as the picker reads it: trimmed; a leading "#" dropped (she
    /// may type a tag the way it reads).
    static func normalized(_ query: String) -> String {
        var trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasPrefix("#") { trimmed.removeFirst() }
        return trimmed.trimmingCharacters(in: .whitespaces)
    }

    /// The options a query shows, in the host's order: an empty query shows
    /// them all; otherwise every option whose text CONTAINS the query,
    /// case- and diacritic-insensitively.
    static func filter(_ options: [SearchPickerOption], query: String) -> [SearchPickerOption] {
        let needle = normalized(query)
        guard !needle.isEmpty else { return options }
        return options.filter {
            ($0.searchText ?? $0.label).range(
                of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }

    /// **Whether a CREATE row is offered**, and for what: the normalized
    /// query when it is non-empty and no option already IS it (compared by
    /// `key` — case-insensitively, the host's own identity rule: a tag's
    /// path, a book's name). nil = no create row.
    static func createOffer(
        query: String, options: [SearchPickerOption],
        key: (String) -> String = { $0 }
    ) -> String? {
        let typed = normalized(query)
        guard !typed.isEmpty else { return nil }
        let wanted = key(typed).lowercased()
        let exists = options.contains {
            key($0.searchText ?? $0.label).lowercased() == wanted
        }
        return exists ? nil : typed
    }

    /// What Return does: the first match, else the create offer.
    enum Choice: Equatable { case pick(String), create(String), nothing }

    /// One drawn line of the sectioned panel: a section's title or one of its
    /// rows, identified by its SECTION and its option (13n-c walk D-W2 — a
    /// quick section repeats rows whose home is another section, so the
    /// option id alone names a row twice).
    struct Line: Identifiable, Equatable, Sendable {
        enum Kind: Equatable, Sendable {
            case title(String)
            case row(SearchPickerOption)
        }
        let id: String
        let kind: Kind
    }

    /// The panel's lines, in order: each section's title (when it has one),
    /// then its rows.
    static func lines(_ sections: [SearchPickerSection]) -> [Line] {
        var lines: [Line] = []
        for section in sections {
            if let title = section.title {
                lines.append(Line(id: "\(section.id)\u{1F}title", kind: .title(title)))
            }
            for option in section.options {
                lines.append(Line(id: "\(section.id)\u{1F}row\u{1F}\(option.id)", kind: .row(option)))
            }
        }
        return lines
    }

    static func returnChoice(
        query: String, options: [SearchPickerOption], canCreate: Bool,
        key: (String) -> String = { $0 }
    ) -> Choice {
        if let first = filter(options, query: query).first { return .pick(first.id) }
        if canCreate, let typed = createOffer(query: query, options: options, key: key) {
            return .create(typed)
        }
        return .nothing
    }

    // MARK: - Sections (13n-c U2)

    /// **The sections a query shows.** Before typing: every non-empty
    /// section, in the host's order (quick ones included). Once she types:
    /// the HOME sections only (quick sections repeat rows that live
    /// elsewhere), each filtered by the one `filter`, empty ones dropped —
    /// so a match shows exactly once, under its home.
    static func visible(_ sections: [SearchPickerSection], query: String) -> [SearchPickerSection] {
        let typing = !normalized(query).isEmpty
        return sections.compactMap { section in
            if typing, section.isQuick { return nil }
            let options = filter(section.options, query: query)
            guard !options.isEmpty else { return nil }
            return SearchPickerSection(
                id: section.id, title: section.title, options: options, isQuick: section.isQuick)
        }
    }

    /// What Return does over sections: the first row the query shows (a
    /// sectioned picker makes nothing).
    static func returnChoice(sections: [SearchPickerSection], query: String) -> Choice {
        visible(sections, query: query).first?.options.first.map { .pick($0.id) } ?? .nothing
    }

    // MARK: - The empty panel (13n-c Stage B R1 B8)

    /// What an EMPTY panel says.
    enum EmptyState: Equatable, Sendable {
        /// Nothing is offered and nothing was typed — the host's own sentence
        /// ("No notes in this wing yet.").
        case empty
        /// A typed query matched nothing.
        case noMatch
    }

    /// **What an empty panel says, decided purely.** A SOURCED panel (the note
    /// feed — an async answer per query) says nothing at all until its first
    /// answer lands (before B8, "Nothing matches." flashed during that first
    /// load, before she typed a thing), and then speaks exactly as a flat one:
    /// the host's empty sentence before typing, "Nothing matches." after
    /// (before B8 a sourced panel could never show its empty sentence).
    static func emptyState(query: String, sourced: Bool, loaded: Bool) -> EmptyState? {
        if sourced, !loaded { return nil }
        return query.isEmpty ? .empty : .noMatch
    }
}

/// **THE FACE** — a quiet word that opens the search popover.
struct SearchPicker: View {
    let tokens: VoiceTokens
    /// The door's word ("+ tag", "Add to Book").
    let label: String
    /// The search field's prompt.
    let prompt: String
    let options: [SearchPickerOption]
    /// The sentence when nothing is offered and nothing typed.
    let emptyText: String
    /// The create row's words for a typed value; nil = this picker makes
    /// nothing (search only).
    var createLabel: ((String) -> String)? = nil
    /// The host's identity rule for "already exists" (see the brain).
    var key: (String) -> String = { $0 }
    let onPick: (String) -> Void
    var onCreate: ((String) -> Void)? = nil
    /// The door's role (the old menus were `.quiet` voiced menus).
    var role: VoicedButtonStyle.Role = .quiet
    /// 13n-c U2 — sectioned layouts (more than one ⇒ a quiet toggle in the
    /// panel); nil = the flat `options` as ever.
    var arrangements: [SearchPickerArrangement]? = nil
    /// 13n-c U2 — an async feed instead of in-memory options (the note
    /// feed): the query in, the sections to show out; latest query wins.
    var source: ((String) async -> [SearchPickerSection])? = nil
    /// 13n-c U2 — the trigger as a FIELD: the chosen value (hers — never
    /// chrome-cased) with its annotation and ▾; nil = the quiet word.
    var field: Field? = nil
    /// 13n-c U2 — the popover's width (the flat hosts keep 300).
    var panelWidth: CGFloat = 300

    /// The field trigger's contents.
    struct Field: Equatable {
        /// The chosen value's words, or nil while nothing is chosen.
        var value: String?
        /// Quiet words beside it (the distinguisher, "connected now").
        var annotation: String?
        var emphasized: Bool = false
        /// What the empty field says.
        var placeholder: String
    }

    @State private var shown = false
    @State private var query = ""
    @FocusState private var focused: Bool

    private var canCreate: Bool { createLabel != nil && onCreate != nil }

    var body: some View {
        Group {
            if let field {
                Button {
                    query = ""
                    shown = true
                } label: {
                    fieldLabel(field)
                }
                .buttonStyle(.plain)
            } else {
                Button(tokens.chromeLabel(label)) {
                    query = ""
                    shown = true
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: role))
                .lineLimit(1)
                .fixedSize()
            }
        }
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            if arrangements != nil || source != nil {
                SearchPickerPanel(
                    tokens: tokens, prompt: prompt, emptyText: emptyText,
                    arrangements: arrangements, source: source, width: panelWidth,
                    onPick: { pick($0) }, onClose: { shown = false })
            } else {
                panel
            }
        }
    }

    private var panel: some View {
        let matches = SearchPickerBrain.filter(options, query: query)
        let offer = canCreate
            ? SearchPickerBrain.createOffer(query: query, options: options, key: key) : nil
        return VStack(alignment: .leading, spacing: 6) {
            TextField(prompt, text: $query)
                .textFieldStyle(.plain)
                .font(tokens.small)
                .focused($focused)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .onSubmit { submit() }
                .onExitCommand { shown = false }
            Divider().overlay(tokens.line)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let offer, let createLabel {
                        row(text: createLabel(offer), annotation: nil, emphasis: true) {
                            create(offer)
                        }
                    }
                    ForEach(matches) { option in
                        row(text: option.label, annotation: option.annotation, emphasis: false) {
                            pick(option.id)
                        }
                    }
                    if matches.isEmpty, offer == nil {
                        Text(tokens.chromeLabel(
                            options.isEmpty && query.isEmpty ? emptyText : SearchPickerCopy.noMatch))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(2)
                            .padding(10)
                    }
                }
            }
            .frame(maxHeight: 300)
            .fixedSize(horizontal: false, vertical: matches.count <= 10)
        }
        .padding(.vertical, 6)
        .frame(width: 300)
        .background(tokens.surface)
        .onAppear { focused = true }
    }

    private func row(
        text: String, annotation: String?, emphasis: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // Her vocabulary (a tag's path, a book's name) — never chrome.
                Text(text)
                    .foregroundStyle(emphasis ? tokens.accent : tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer(minLength: 8)
                if let annotation {
                    Text(tokens.chromeLabel(annotation))
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .font(tokens.small)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        switch SearchPickerBrain.returnChoice(
            query: query, options: options, canCreate: canCreate, key: key) {
        case .pick(let id): pick(id)
        case .create(let typed): create(typed)
        case .nothing: break
        }
    }

    // MARK: - 13n-c U2: the field trigger

    private func fieldLabel(_ field: Field) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            // Her vocabulary (a book's name, a note's title) — never chrome.
            Text(field.value ?? tokens.chromeLabel(field.placeholder))
                .foregroundStyle(field.value == nil ? tokens.faint : tokens.ink)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 8)
            if let annotation = field.annotation {
                Text(tokens.chromeLabel(annotation))
                    .foregroundStyle(field.emphasized ? tokens.accent : tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
            }
            Text("\u{25BE}")
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
        .font(tokens.small)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(tokens.line, lineWidth: 1))
        .contentShape(Rectangle())
    }

    private func pick(_ id: String) {
        shown = false
        onPick(id)
    }

    private func create(_ typed: String) {
        shown = false
        onCreate?(typed)
    }
}

/// **THE SECTIONED PANEL** (13n-c U2) — what a sectioned or sourced
/// `SearchPicker` shows in its popover: the search field (focused), the
/// layout toggle when there is more than one ("by shelf" · "a–z"), and the
/// titled sections the brain (or the source) answers. Its own view so a
/// capture harness can draw the open picker offscreen (a popover is another
/// window) — `initialQuery` is that seam; in use it opens empty.
struct SearchPickerPanel: View {
    /// The list's height cap (the popover's scrolling room).
    static let listHeight: CGFloat = 360

    let tokens: VoiceTokens
    let prompt: String
    let emptyText: String
    var arrangements: [SearchPickerArrangement]?
    var source: ((String) async -> [SearchPickerSection])?
    let width: CGFloat
    let onPick: (String) -> Void
    let onClose: () -> Void

    @State private var query: String
    @State private var arrangementID: String?
    @State private var sourced: [SearchPickerSection] = []
    /// 13n-c Stage B R1 B8: the source's first answer has landed.
    @State private var loaded = false
    @State private var generation = 0
    @FocusState private var focused: Bool

    init(
        tokens: VoiceTokens, prompt: String, emptyText: String,
        arrangements: [SearchPickerArrangement]? = nil,
        source: ((String) async -> [SearchPickerSection])? = nil,
        width: CGFloat, initialQuery: String = "", initialArrangementID: String? = nil,
        onPick: @escaping (String) -> Void, onClose: @escaping () -> Void
    ) {
        self.tokens = tokens
        self.prompt = prompt
        self.emptyText = emptyText
        self.arrangements = arrangements
        self.source = source
        self.width = width
        self.onPick = onPick
        self.onClose = onClose
        _query = State(initialValue: initialQuery)
        _arrangementID = State(initialValue: initialArrangementID)
    }

    private var currentArrangement: SearchPickerArrangement? {
        guard let arrangements, !arrangements.isEmpty else { return nil }
        return arrangements.first { $0.id == arrangementID } ?? arrangements[0]
    }

    /// What the panel shows: the source's answer as given (it already
    /// matched the query), or the arrangement's sections through the brain.
    private var shownSections: [SearchPickerSection] {
        if source != nil { return sourced }
        return SearchPickerBrain.visible(currentArrangement?.sections ?? [], query: query)
    }

    var body: some View {
        let sections = shownSections
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                TextField(prompt, text: $query)
                    .textFieldStyle(.plain)
                    .font(tokens.small)
                    .focused($focused)
                    .onSubmit { submit() }
                    .onExitCommand { onClose() }
                if let arrangements, arrangements.count > 1 {
                    HStack(spacing: 2) {
                        ForEach(arrangements) { arrangement in
                            Button(tokens.chromeLabel(arrangement.label)) { arrangementID = arrangement.id }
                                .buttonStyle(VoicedButtonStyle(
                                    tokens: tokens,
                                    role: arrangement.id == currentArrangement?.id ? .primary : .quiet))
                        }
                    }
                    .fixedSize()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            Divider().overlay(tokens.line)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // 13n-c walk D-W2: ONE flat list of lines, each named by its
                    // SECTION and its option — the quick sections repeat rows
                    // whose home is a shelf, and a bare option id put one
                    // identity in this lazy stack twice (the later slot drew
                    // blank).
                    ForEach(SearchPickerBrain.lines(sections)) { line in
                        switch line.kind {
                        case .title(let title):
                            // A shelf's name is hers — never chrome-cased.
                            Text(title)
                                .font(tokens.small.weight(.semibold))
                                .foregroundStyle(tokens.muted)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .padding(.horizontal, 10)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                        case .row(let option):
                            row(option) { onPick(option.id) }
                        }
                    }
                    if sections.isEmpty, let empty = SearchPickerBrain.emptyState(
                        query: query, sourced: source != nil, loaded: loaded) {
                        Text(tokens.chromeLabel(empty == .empty ? emptyText : SearchPickerCopy.noMatch))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(2)
                            .padding(10)
                    }
                }
            }
            // 13n-c walk D-W1: a SOURCED panel's first frame has no rows (its
            // feed has not answered), and the popover sizes itself ONCE from
            // that frame — so the list takes its full room from the start and
            // the rows that land after have somewhere to show.
            .frame(minHeight: source != nil ? Self.listHeight : nil, maxHeight: Self.listHeight)
        }
        .padding(.vertical, 6)
        .frame(width: width)
        .background(tokens.surface)
        .onAppear { focused = true }
        .task(id: query) { await runSource() }
    }

    private func row(_ option: SearchPickerOption, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    // Her vocabulary — never chrome.
                    Text(option.label)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer(minLength: 8)
                    if let annotation = option.annotation {
                        Text(tokens.chromeLabel(annotation))
                            .fontWeight(option.emphasized ? .semibold : .regular)
                            .foregroundStyle(option.emphasized ? tokens.accent : tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
                if let detail = option.detail {
                    Text(detail)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .font(tokens.small)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        if source != nil {
            if let first = sourced.first?.options.first { onPick(first.id) }
            return
        }
        if case .pick(let id) = SearchPickerBrain.returnChoice(
            sections: currentArrangement?.sections ?? [], query: query) {
            onPick(id)
        }
    }

    /// The feed's cadence (the note picker's own): one bounded read per typed
    /// query, latest keystroke wins.
    private func runSource() async {
        guard let source else { return }
        generation += 1
        let mine = generation
        let result = await source(query)
        guard mine == generation else { return }
        sourced = result
        loaded = true
    }
}

/// The control's own words (13s re-voices).
nonisolated enum SearchPickerCopy {
    static let noMatch = "Nothing matches."
    /// The tag pickers' (g).
    static let tagPrompt = "Find or make a tag"
    static func newTag(_ typed: String) -> String {
        "New tag \u{201C}#\(TypedTagPath.segments(typed).joined(separator: "/"))\u{201D}"
    }
    /// A tag's identity for "already exists": its slash-collapsed path.
    static func tagKey(_ text: String) -> String {
        TypedTagPath.segments(SearchPickerBrain.normalized(text)).joined(separator: "/")
    }
}
