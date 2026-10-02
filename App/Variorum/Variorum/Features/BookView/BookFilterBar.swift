//
//  BookFilterBar.swift
//  Variorum (Mac)
//
//  13i-d U3 — THE IN-BOOK FILTER BAR's FACE (the sitting record §18.1, her
//  ORIGINAL sitting ask, verbatim: *"being able to either filter a book within
//  itself for a subset of the tags, or make a new book to look at just the
//  tags, is important."*). RULED: a view-local filter bar on a book's (and a
//  gathering's) Index — filter the view by tags/star, NEVER mutating
//  membership — plus the "Save this filter as a gathering" door (rule = the
//  book's tag association ∧ the filter). The MECHANICS shipped at 13i-b U4
//  (`Queries.assembleReading(…, filter:)`, `Operations.saveFilterAsGathering`);
//  this file is the face.
//
//  The shape (PROVISIONAL P-13id-U3-5 — the face is this unit's design): under
//  the Index column's title filter, ONE quiet word, `by tag ▾` — the tags the
//  book's notes wear and ★ starred. Each chosen term is a line of its own,
//  "with #draft" or "without #old" (the first word flips it), with a × to drop
//  it; two or more combine by `match all ▾ / any`; `clear` empties it;
//  `save as gathering…` mints one. The bar holds the DRAFT; the book's model
//  holds the RULE the assembly reads (`BookViewModel.viewFilter`), and the
//  Index clears it when it leaves — the bar is its only face.
//

import SwiftUI
import VariorumCore

// MARK: - The draft (pure)

/// One chosen term: a tag or the star, with or without.
nonisolated struct BookFilterTerm: Equatable, Sendable {
    enum Target: Equatable, Hashable, Sendable {
        case tag(String)
        case star
    }

    var target: Target
    var without = false
}

nonisolated enum BookFilterMatch: Equatable, Sendable {
    case all, any
}

/// **The bar's state, and the ONE map onto the rule grammar** — pinned
/// without a window. Empty ⇒ no filter (nil): the book as it is.
nonisolated struct BookFilterDraft: Equatable, Sendable {
    var terms: [BookFilterTerm] = []
    var match: BookFilterMatch = .all

    var isEmpty: Bool { terms.isEmpty }

    func contains(_ target: BookFilterTerm.Target) -> Bool {
        terms.contains { $0.target == target }
    }

    /// A target joins once (her append order).
    mutating func add(_ target: BookFilterTerm.Target) {
        guard !contains(target) else { return }
        terms.append(BookFilterTerm(target: target))
    }

    mutating func remove(_ target: BookFilterTerm.Target) {
        terms.removeAll { $0.target == target }
    }

    /// "with" ⇄ "without".
    mutating func flip(_ target: BookFilterTerm.Target) {
        guard let index = terms.firstIndex(where: { $0.target == target }) else { return }
        terms[index].without.toggle()
    }

    /// The rule the assembly reads — the gathering grammar itself, so "Save
    /// this filter as a gathering" mints exactly what she was looking through.
    var rule: RuleTerm? {
        let parts: [RuleTerm] = terms.map { term in
            let base: RuleTerm = switch term.target {
            case .tag(let id): .tag(id)
            case .star: .star
            }
            return term.without ? .not(base) : base
        }
        switch parts.count {
        case 0: return nil
        case 1: return parts[0]
        default: return match == .all ? .and(parts) : .or(parts)
        }
    }
}

// MARK: - The words

/// Every word the filter bar says. Wording PROVISIONAL (13s re-voices); the
/// TRUTHS are ruled (§18.1: it filters the VIEW; saving mints a gathering).
nonisolated enum BookFilterCopy {
    /// The registry's verb — §18.1's own words.
    static let saveVerb = "Save This Filter as a Gathering\u{2026}"
    static let unavailableNote =
        "The filter lives on a book's Index \u{2014} choose a tag there, then save it as a "
        + "gathering."
    static let addEmpty = "by tag"
    static let addMore = "+ tag"
    static let with = "with"
    static let without = "without"
    static let clear = "clear"
    static let saveDoor = "save as gathering\u{2026}"
    static let noTags = "no tags on this book's notes"
    static func match(_ match: BookFilterMatch) -> String {
        match == .all ? "match all" : "match any"
    }
    static let matchAll = "all of them"
    static let matchAny = "any of them"
    static let addHelp =
        "Show only this book's notes with (or without) a tag or the star \u{2014} a way of "
        + "looking: no note leaves the book."
    static let removeHelp = "Stop filtering by this"

    static func target(_ target: BookFilterTerm.Target, paths: [String: String]) -> String {
        switch target {
        case .tag(let id): RuleEditorCopy.tag(path: paths[id])
        case .star: RuleEditorCopy.starred
        }
    }

    /// The save prompt's title and its default name.
    static let saveTitle = "Save This Filter as a Gathering"
    static func defaultName(book: String, filter: String) -> String { "\(book) \u{00B7} \(filter)" }

    /// **What the new gathering will gather from** — said BEFORE it mints
    /// (the op's own instruction: "the door's face must say so").
    static func association(
        _ kind: Operations.FilterAssociation, associationWords: String?, filterWords: String
    ) -> String {
        switch kind {
        case .rule:
            return "It shows the notes this book gathers (\(associationWords ?? "its rule")) that "
                + "also match \(filterWords) \u{2014} and keeps up as tags change. No note moves."
        case .autoTag:
            return "It shows the notes tagged \(associationWords ?? "as this book tags them") "
                + "\u{2014} what notes written here wear \u{2014} that also match \(filterWords). "
                + "No note moves."
        case .none:
            // The walk's W-4: "no tag of its own" read oddly beside the
            // Bookcase row's tag column; this says exactly what is absent.
            return "This book neither gathers by a tag nor tags what's written in it, so the "
                + "gathering shows every note in this library that matches \(filterWords) "
                + "\u{2014} not only this book's. No note moves."
        }
    }

    static func saved(_ name: String) -> String {
        "Saved \u{201C}\(name)\u{201D} as a gathering \u{2014} it's on the Bookcase, unshelved."
    }
}

// MARK: - The save door

/// What the save prompt shows: the name she may edit and the sentence about
/// what the gathering will gather from.
struct BookFilterSaveOffer: Identifiable, Equatable {
    let readingID: String
    let filter: RuleTerm
    let suggestedName: String
    let message: String
    var id: String { readingID }
}

/// The save door's one brain: preview → prompt → mint, refusals spoken.
@MainActor
enum BookFilterDoor {
    /// The prompt's item: the association read FRESH (a rule edited meanwhile
    /// is what the op will conjoin), worded with the live paths. nil + a
    /// spoken refusal when the book cannot carry a filter (a malformed
    /// gathering rule).
    static func offer(
        session: AppSession, reading: Reading, filter: RuleTerm, paths: [String: String]
    ) async -> BookFilterSaveOffer? {
        let id = reading.id
        do {
            let (term, kind) = try await session.database.read { db in
                guard let fresh = try Queries.reading(db, id: id) else {
                    throw OperationError.readingNotFound(id: id)
                }
                return try Queries.filterAssociation(db, source: fresh)
            }
            let filterWords = CollectingCopy.ruleWords(filter, paths: paths)
            return BookFilterSaveOffer(
                readingID: id, filter: filter,
                suggestedName: BookFilterCopy.defaultName(book: reading.name, filter: filterWords),
                message: BookFilterCopy.association(
                    kind, associationWords: term.map { CollectingCopy.ruleWords($0, paths: paths) },
                    filterWords: filterWords))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return nil
        }
    }

    /// Mint it — the name guard at the door (E13's ruled shape), then the op.
    /// Returns the new gathering's id, or nil after a spoken refusal.
    @discardableResult
    static func save(
        session: AppSession, readingID: String, filter: RuleTerm, name: String
    ) async -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            session.status.refuse("A gathering needs a name.")
            return nil
        }
        do {
            let saved = try await session.runner.run { ops in
                try ops.assertBookNameIsFree(trimmed)
                return try ops.saveFilterAsGathering(readingID, filter: filter, name: trimmed)
            }
            session.status.receipt(BookFilterCopy.saved(saved.reading.name))
            return saved.reading.id
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return nil
        }
    }
}

// MARK: - The bar

struct BookFilterBar: View {
    /// P-1's walk: the bar's one WRITE — saving the filter as a gathering.
    /// The terms themselves are view-local looks, never acts.
    static let surfaceCapabilities: [CapabilityID] = [.saveFilterAsGathering]

    let tokens: VoiceTokens
    let session: AppSession
    let structure: BookStructureModel
    /// The Index's held tag read (the grouped-by control's): the tags the
    /// book's notes wear — tracked over the UNFILTERED book while a filter
    /// narrows it, so the menu never shrinks to the notes already shown — and
    /// every live tag's path. Passed as the MODEL so its deliveries re-render
    /// this bar and nothing around it.
    let grouping: BookIndexGroupingModel
    @Binding var draft: BookFilterDraft

    private var tags: [VariorumCore.Tag] {
        let wing = structure.reading?.wingId ?? ""
        return grouping.worn.filter { $0.wingId == wing }
    }

    private var paths: [String: String] {
        Dictionary(grouping.live.map { ($0.id, $0.path) }, uniquingKeysWith: { first, _ in first })
    }

    @State private var offer: BookFilterSaveOffer?
    @State private var nameField = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(Array(draft.terms.enumerated()), id: \.offset) { _, term in
                termLine(term)
            }
            HStack(spacing: 6) {
                addMenu
                if draft.terms.count >= 2 {
                    VoicedMenu(tokens: tokens, label: BookFilterCopy.match(draft.match), role: .quiet) {
                        Button(BookFilterCopy.matchAll) { draft.match = .all }
                        Button(BookFilterCopy.matchAny) { draft.match = .any }
                    }
                }
                Spacer(minLength: 4)
                if !draft.isEmpty {
                    Button(tokens.chromeLabel(BookFilterCopy.clear)) { draft = BookFilterDraft() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    Button(tokens.chromeLabel(BookFilterCopy.saveDoor)) { openSave() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                        .help(CapabilityRegistry.capability(.saveFilterAsGathering).verb)
                }
            }
        }
        .alert(
            BookFilterCopy.saveTitle,
            isPresented: Binding(get: { offer != nil }, set: { if !$0 { offer = nil } }),
            presenting: offer
        ) { offer in
            TextField("Name", text: $nameField)
            Button("Save") {
                let name = nameField
                Task {
                    await BookFilterDoor.save(
                        session: session, readingID: offer.readingID, filter: offer.filter,
                        name: name)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { offer in
            Text(offer.message)
        }
        #if DEBUG
        .onAppear { BookFilterProbe.drawn[structure.readingID] = draft }
        .onChange(of: draft) { _, now in BookFilterProbe.drawn[structure.readingID] = now }
        #endif
    }

    /// One chosen term: "with/without" (a click flips it), its words, ×.
    private func termLine(_ term: BookFilterTerm) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Button(tokens.chromeLabel(term.without ? BookFilterCopy.without : BookFilterCopy.with)) {
                draft.flip(term.target)
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            Text(BookFilterCopy.target(term.target, paths: paths))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 4)
            Button("\u{00D7}") { draft.remove(term.target) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(BookFilterCopy.removeHelp)
        }
    }

    private var addMenu: some View {
        let open = tags.filter { !draft.contains(.tag($0.id)) }
        return VoicedMenu(
            tokens: tokens,
            label: draft.isEmpty ? BookFilterCopy.addEmpty : BookFilterCopy.addMore,
            role: .quiet
        ) {
            if !draft.contains(.star) {
                Button(RuleEditorCopy.starred) { draft.add(.star) }
                Divider()
            }
            if open.isEmpty {
                Text(BookFilterCopy.noTags)
            } else {
                ForEach(open, id: \.id) { tag in
                    Button(RuleEditorCopy.tag(path: tag.path)) { draft.add(.tag(tag.id)) }
                }
            }
        }
        .help(BookFilterCopy.addHelp)
    }

    private func openSave() {
        guard let reading = structure.reading, let filter = draft.rule else { return }
        Task {
            if let made = await BookFilterDoor.offer(
                session: session, reading: reading, filter: filter, paths: paths) {
                nameField = made.suggestedName
                offer = made
            }
        }
    }
}

#if DEBUG
/// What the mounted bar's draft is (the probe pattern).
@MainActor
enum BookFilterProbe {
    static var drawn: [String: BookFilterDraft] = [:]
}
#endif
