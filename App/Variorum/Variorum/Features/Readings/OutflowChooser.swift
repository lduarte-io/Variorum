//
//  OutflowChooser.swift
//  Variorum
//
//  13i-c U3 — THE OUTFLOW CHOOSER (her kickoff ruling R-13ic-1 and the
//  13i-b closing sitting's charter: the outflow is "a CHOSEN, OPTIONAL SET
//  of tags on a book, independent of the intake rule — you should be able to
//  choose if you want a, b, a but not b, tag c, whatever"). It replaces the
//  13i-b rule editor's single auto-tag row (which, since U1, showed the
//  set's FIRST tag and would have overwritten a two-tag set with one —
//  F-U1-1) and serves the spawn sheet too (the spawn OFFERS the choice,
//  prefilled with the rule's positive tags — her item (i)).
//
//  Two pieces: the DRAFT (`OutflowDraft` — pure: ordered as chosen,
//  de-duplicated, each removable, "none" legal, a dead id dropped at the
//  write) and the FACE (`OutflowChooser` — a row per chosen tag in the
//  rule editor's own term-row grammar, and one "+ tag" menu of the wing's
//  live tags not yet chosen).
//

import SwiftUI
import VariorumCore

/// The outflow as edited — an ORDERED set of tag ids (append order is the
/// order she chose; `setReadingOutflow` stores it as given).
nonisolated struct OutflowDraft: Equatable, Sendable {
    private(set) var ids: [String]

    init(_ ids: [String]) {
        var seen = Set<String>()
        self.ids = ids.filter { seen.insert($0).inserted }
    }

    var isEmpty: Bool { ids.isEmpty }

    /// Appends — a tag already chosen stays where it is.
    mutating func add(_ id: String) {
        guard !ids.contains(id) else { return }
        ids.append(id)
    }

    mutating func remove(_ id: String) {
        ids.removeAll { $0 == id }
    }

    /// What a save writes: the chosen ids, in order, minus any that are no
    /// longer live tags of the wing (a "(deleted tag)" row drops on the next
    /// save — `setReadingOutflow` refuses a dead id, by design).
    func written(live: Set<String>) -> [String] {
        ids.filter(live.contains)
    }
}

/// The chooser's face: "Notes written here are tagged:" then one row per
/// chosen tag (its live path, or "(deleted tag)"; a quiet "remove"), or
/// "nothing" — and a "+ tag" menu of the wing's live tags not yet chosen.
struct OutflowChooser: View {
    let tokens: VoiceTokens
    @Binding var draft: OutflowDraft
    /// The wing's live tags — the menu's choices.
    let tags: [Tag]
    /// A chosen id's words: "#path", or "(deleted tag)".
    let label: (String) -> String
    /// 17y B3 item (g): make a tag in place from the picker (the host's road
    /// — the rule editor's `createTag`, in the book's wing); returns the new
    /// tag's id. nil = the picker searches only (the spawn sheet's — it
    /// adopts create at its next touch, R-17y-3).
    var onCreate: ((String) async -> String?)? = nil

    /// The picker's options: the wing's live tags not yet chosen, by path.
    private var offered: [SearchPickerOption] {
        tags.filter { !draft.ids.contains($0.id) }.map { tag in
            SearchPickerOption(
                id: tag.id, label: RuleEditorCopy.tag(path: tag.path), searchText: tag.path)
        }
    }

    /// The create row's words — only where the host can make a tag.
    private var createLabel: ((String) -> String)? {
        onCreate == nil ? nil : { SearchPickerCopy.newTag($0) }
    }

    /// The create act: make it through the host, then choose it.
    private var createAct: ((String) -> Void)? {
        guard let make = onCreate else { return nil }
        let binding = $draft
        return { typed in
            Task { @MainActor in
                if let id = await make(typed) { binding.wrappedValue.add(id) }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(RuleEditorCopy.autoTagLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                if draft.isEmpty {
                    Text(tokens.chromeLabel(RuleEditorCopy.outflowNone))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                // 17y B3 item (g) — THE ONE PICKER (R-17y-3): type-to-filter
                // over the wing's tags not yet chosen, and (with a host road)
                // a 'New tag "#x"' row that makes it in place and chooses it.
                SearchPicker(
                    tokens: tokens, label: RuleEditorCopy.addTag,
                    prompt: SearchPickerCopy.tagPrompt,
                    options: offered,
                    emptyText: RuleEditorCopy.noTagsYet,
                    createLabel: createLabel,
                    key: SearchPickerCopy.tagKey(_:),
                    onPick: { id in draft.add(id) },
                    onCreate: createAct)
            }
            ForEach(draft.ids, id: \.self) { id in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    // A tag's path is her vocabulary — never `chromeLabel`'d.
                    Text(label(id))
                        .font(tokens.small)
                        .foregroundStyle(label(id) == RuleEditorCopy.deadTag
                                         ? tokens.faint : tokens.ink)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer(minLength: 8)
                    Button(tokens.chromeLabel(RuleEditorCopy.remove)) { draft.remove(id) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                }
                .padding(.leading, 18)
            }
        }
    }
}
