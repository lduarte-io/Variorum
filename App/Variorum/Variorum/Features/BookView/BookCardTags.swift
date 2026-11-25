//
//  BookCardTags.swift
//  Variorum (Mac)
//
//  **VX-1038 (the VX-1036 run, batch 2) — a note's tags inside a book.** Her
//  words (sitting 2, R-1036-18): *"I'd rather that the tags start out by being
//  on the line next to open and then go down to a second line if there are too
//  many of them … that way they're still part of the header"*; *"if the title
//  is taking up the full length the tags can be on the next line down, but I
//  think that they should be in a deliberate area and always show as a pill"*;
//  *"a small + for if you want to add tags on a new note, if showing tags is on
//  for the book."* And sitting 3: every outline card wears them behind the
//  per-book switch (R-1036-30), which has three positions — hidden · other
//  tags · all tags (R-1036-39).
//
//  What lives here (P-9 — the book's tags are their own concern, never more of
//  `BookViewModel`):
//  - `BookTagsShownPrefs` — the switch's memory, per book on this Mac (the
//    Index `group ▾` memory's class — a way of looking; PROVISIONAL);
//  - `BookCardTagsModel` — the switch's position, the window's notes' tags
//    (ONE held read over `post_tag` + `tag`, and only while the switch shows
//    tags — hidden reads nothing), the wing's vocabulary for the "+" field,
//    and the gathering rule's tags for "other tags" (`NotePlacingTags`);
//  - `BookCardHeaderPlan` + `BookCardHeaderLine` — T-1's layout: the pills on
//    the title line at its trailing side, wrapping inside that area when many;
//    a title that fills the line puts them on their own row under it — a
//    fixed place, never floating (the round-2 mockup's frame 1, five states);
//  - `BookCardPills` — the pills and the "+" as the header's items.
//
//  Batch 3's List rows read the SAME model's `pills(for:)` (the read seam is
//  the model, never this file's views).
//

import GRDB
import SwiftUI
import VariorumCore

// MARK: - The switch's memory (per book, this Mac)

/// The per-book memory. `UserDefaults` INJECTED (the app passes the note-memory
/// domain, `NoteMemoryDefaults.store` — the Index grouping's own; every pin a
/// scratch suite). Hidden is the default and is stored as no key at all.
struct BookTagsShownPrefs {
    let defaults: UserDefaults

    static func key(_ readingID: String) -> String { "book.tagsShown." + readingID }

    func position(for readingID: String) -> BookTagsShown {
        BookTagsShown(stored: defaults.string(forKey: Self.key(readingID)))
    }

    func setPosition(_ position: BookTagsShown, for readingID: String) {
        if position == .initial {
            defaults.removeObject(forKey: Self.key(readingID))
        } else {
            defaults.set(position.rawValue, forKey: Self.key(readingID))
        }
    }
}

// MARK: - The model

@MainActor
@Observable
final class BookCardTagsModel {
    let readingID: String
    @ObservationIgnored private let prefs: BookTagsShownPrefs

    /// The switch (T-5 / R-1036-39) — hidden until she chooses otherwise.
    private(set) var position: BookTagsShown
    /// The ONE note whose "+" field is open, or nil (T-3).
    var fieldPostID: String?
    /// Each shown note's own live tags (the held read's), by path.
    private(set) var worn: [String: [Tag]] = [:]
    /// The book's wing's live vocabulary — what the "+" field suggests.
    private(set) var vocabulary: [Tag] = []
    /// The gathering rule's live tags, by id — what "other tags" matches on.
    private(set) var ruleTags: [String: Tag] = [:]
    /// How many live notes wear each tag (VX-576's order key) — read ONCE
    /// when a field opens, never held.
    private(set) var uses: [String: Int] = [:]
    /// The rule "other tags" leaves the placing tags of — a GATHERING's
    /// (R-1036-39: "the gathering's own and its lane's"); nil in a book.
    /// Set by `track` from the book's row (internal, so a pin sets it).
    var rule: RuleTerm?

    init(readingID: String, defaults: UserDefaults = NoteMemoryDefaults.store) {
        self.readingID = readingID
        self.prefs = BookTagsShownPrefs(defaults: defaults)
        self.position = BookTagsShownPrefs(defaults: defaults).position(for: readingID)
    }

    /// Choose a position — remembered for this book on this Mac. Hidden puts
    /// any open field away (there is no "+" to hang it from).
    func setPosition(_ position: BookTagsShown) {
        guard position != self.position else { return }
        self.position = position
        prefs.setPosition(position, for: readingID)
        if position == .hidden { fieldPostID = nil }
    }

    /// **The pills a note wears in the header** — nil while the book hides
    /// tags (no pills, no "+"), else its tags minus, under "other tags", the
    /// ones that place it in this gathering. An empty answer is the "+" alone.
    /// This is the READ SEAM batch 3's List rows use too.
    func pills(for postID: String) -> [Tag]? {
        let worn = worn[postID] ?? []
        let placing: Set<String> = position == .otherTags
            ? NotePlacingTags.placing(rules: rule.map { [$0] } ?? [], worn: worn, ruleTags: ruleTags)
            : []
        return position.pills(worn: worn, placing: placing, id: \.id)
    }

    /// The note's applied paths — the field never suggests what it wears.
    func appliedPaths(_ postID: String) -> Set<String> {
        Set((worn[postID] ?? []).map(\.path))
    }

    // MARK: The read

    /// What one read returns.
    nonisolated struct Snapshot: Equatable, Sendable {
        var worn: [String: [Tag]]
        var vocabulary: [Tag]
        var ruleTags: [String: Tag]
    }

    /// The task's key: the read restarts when what it covers changes — the
    /// position's shown/hidden, the notes the window holds, the book's wing,
    /// and the rule (a gathering's rule edit re-reads its tags).
    nonisolated struct Key: Equatable, Hashable, Sendable {
        var shows: Bool
        var postIDs: [String]
        var wingID: String
        var querySpec: String?
    }

    /// The ONE fetch — `post_tag` and `tag` only (and `wing` through the
    /// wing scope), never `container` or `variant`: a keystroke's autosave
    /// never wakes it. ∝ the window's notes' applications + the wing's
    /// vocabulary (author-scale) + the rule's tags.
    nonisolated static func fetch(
        _ db: Database, postIDs: [String], wingID: String, ruleTagIDs: [String]
    ) throws -> Snapshot {
        Snapshot(
            worn: try Queries.wornTagRows(db, noteIDs: postIDs),
            vocabulary: try Queries.allTags(db, wingID: wingID),
            ruleTags: Dictionary(
                try Queries.liveTags(db, ids: ruleTagIDs).map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }))
    }

    /// The book's read, HELD while the switch shows tags (the `.task(id:)`
    /// that runs it cancels it when the key moves). Hidden reads nothing and
    /// keeps nothing.
    func track(session: AppSession, key: Key, isGathering: Bool) async {
        rule = isGathering ? RuleGrammar.decode(key.querySpec) : nil
        guard key.shows else {
            adopt(Snapshot(worn: [:], vocabulary: [], ruleTags: [:]))
            return
        }
        let ruleTagIDs = Array(RuleGrammar.tagIDs(of: rule)).sorted()
        do {
            for try await snapshot in session.database.observe({ db in
                try Self.fetch(db, postIDs: key.postIDs, wingID: key.wingID, ruleTagIDs: ruleTagIDs)
            }) {
                adopt(snapshot)
            }
        } catch {
            // Cancellation (the key moved, the book left) or a store refusal:
            // what is in hand stays until the next read.
        }
    }

    /// Internal so a pin drives it by hand (the `MastheadTagsModel.adopt`
    /// precedent). A superseded read's late delivery never lands.
    func adopt(_ snapshot: Snapshot) {
        guard !Task.isCancelled else { return }
        worn = snapshot.worn
        vocabulary = snapshot.vocabulary
        ruleTags = snapshot.ruleTags
    }

    // MARK: The acts

    /// Open the "+" field on one note (the only one open) and read the use
    /// counts once, for the suggestions' most-used-first order (VX-576).
    func openField(on postID: String, session: AppSession, wingID: String) {
        fieldPostID = postID
        Task {
            let counts = try? await session.database.read { db in
                try Queries.tagUseCounts(db, wingID: wingID)
            }
            if let counts { uses = counts }
        }
    }

    /// The field's ⏎ or a suggestion's click: adopt-or-mint the typed path in
    /// the NOTE's wing and apply it through the ONE application road
    /// (`TagAssignmentViewModel.applyTypedPath` → `TypedTagPath` →
    /// `Operations.applyTag`), so a living book that collects it hears it —
    /// seat or bell, as when she tags anywhere else. The field closes after
    /// (the masthead's row-40 rule: the "+" is right there for the next one).
    func apply(_ path: String, to postID: String, session: AppSession) {
        fieldPostID = nil
        let door = TagAssignmentViewModel(session: session, postID: postID)
        Task {
            if await door.applyTypedPath(path) == nil, let error = door.lastError {
                session.status.refuse(error)
            }
        }
    }

    /// A pill's ×: the standing op (`removeTag`) — in a gathering, taking off
    /// a tag that places the note takes the note out, by definition.
    func remove(_ tag: Tag, from postID: String, session: AppSession) {
        Task {
            do {
                try await session.runner.run { ops in
                    try ops.removeTag(tag.id, fromPost: postID)
                }
            } catch {
                session.status.refuse(TagsViewModel.message(error))
            }
        }
    }

    /// The field resigned the keyboard: a note that already wears a tag puts
    /// it away (the masthead's row-40 rule, her words: "it should collapse
    /// after you click out of it"); a tagless note keeps it.
    func fieldLostFocus(on postID: String) {
        guard fieldPostID == postID, !(worn[postID] ?? []).isEmpty else { return }
        fieldPostID = nil
    }
}

// (T-1's layout — `BookCardHeaderPlan` + `BookCardHeaderLine` — is its own
// file, `BookCardHeaderLine.swift`: pure geometry, no model.)

// MARK: - The pills and the "+" (the header's items)

/// The words the header's tag doors say (public copy, sentence case).
nonisolated enum BookCardTagsCopy {
    static let plus = "+"
    static let plusHelp = "Tag this note \u{2014} type a path (\u{201C}/\u{201D} nests: life/goals), \u{23CE} applies"
}

/// A note's pills, its "+", and the field's anchor — handed to a
/// `BookCardHeaderLine` as its `.pill` / `.anchor` items. Draws nothing while
/// the book hides tags.
struct BookCardPills: View {
    let session: AppSession
    let tags: BookCardTagsModel
    let postID: String
    let wingID: String
    let tokens: VoiceTokens

    var body: some View {
        if let pills = tags.pills(for: postID) {
            ForEach(pills, id: \.id) { tag in
                TagChipCard(tokens: tokens, tag: tag, onRemove: {
                    tags.remove($0, from: postID, session: session)
                })
                .bookCardHeaderRole(.pill)
            }
            plus
                .bookCardHeaderRole(.pill)
            Color.clear
                .frame(width: 0)
                .bookCardHeaderRole(.anchor)
                .overlay(alignment: .trailing) {
                    if tags.fieldPostID == postID {
                        TagInlineField(
                            tokens: tokens, allTags: tags.vocabulary,
                            applied: tags.appliedPaths(postID),
                            onApply: { tags.apply($0, to: postID, session: session) },
                            onFocusLost: { tags.fieldLostFocus(on: postID) },
                            onDismiss: { tags.fieldPostID = nil },
                            uses: tags.uses)
                        .offset(x: -MastheadTagCluster.fieldGap)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
        }
    }

    /// T-3's "+": opens the field in place on THIS note (one field at a time);
    /// pressed again, it puts the field away.
    private var plus: some View {
        Button {
            if tags.fieldPostID == postID {
                tags.fieldPostID = nil
            } else {
                tags.openField(on: postID, session: session, wingID: wingID)
            }
        } label: {
            Text(BookCardTagsCopy.plus)
                .font(tokens.small)
                .foregroundStyle(tags.fieldPostID == postID ? tokens.accent : tokens.faint)
                .lineLimit(1)
                .padding(.horizontal, 4)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(BookCardTagsCopy.plusHelp)
    }
}
