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

    init(id: String, label: String, annotation: String? = nil, searchText: String? = nil) {
        self.id = id
        self.label = label
        self.annotation = annotation
        self.searchText = searchText
    }
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

    @State private var shown = false
    @State private var query = ""
    @FocusState private var focused: Bool

    private var canCreate: Bool { createLabel != nil && onCreate != nil }

    var body: some View {
        Button(tokens.chromeLabel(label)) {
            query = ""
            shown = true
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: role))
        .lineLimit(1)
        .fixedSize()
        .popover(isPresented: $shown, arrowEdge: .bottom) { panel }
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

    private func pick(_ id: String) {
        shown = false
        onPick(id)
    }

    private func create(_ typed: String) {
        shown = false
        onCreate?(typed)
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
