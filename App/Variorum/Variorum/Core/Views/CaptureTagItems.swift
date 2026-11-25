//
//  CaptureTagItems.swift
//  Variorum (MAC ONLY) — Core/Views: the capture doors' tag button
//
//  **VX-1078 (the VX-1036 run, batch 4) — tags on a quick note.** Her words at
//  sitting 3 (R-1036-37): *"there should be a tag adding button where it
//  suggests the title so you can add things from there and file it if you'd
//  like, and on the quick note capture that lives on the macos menu bar too."*
//  So: a ＋ beside the title suggestion on BOTH capture doors — the new-note box
//  (`QuickEntryBar`, whose two hosts are the Bookcase's band and the Library's
//  foot) and the menu-bar quick note pad (`QuickNoteView`) — with the picked
//  tags as pills and the field a book's "+" opens. Batch 2's components
//  exactly: `TagChipCard` (the drawn ×), `TagInlineField` (the suggest brain,
//  most-used first). Shared home at birth: two features render it (CLAUDE.md).
//
//  The picks are PATHS until the filing (`CaptureTagPicks`, Shared): nothing is
//  written while she picks, so this is no registry act — the title chip's class
//  (the filing is the door's own act, `.quickNote` / the band's). A face only:
//  the host owns the picks, the field's open state and the vocabulary's read
//  (`CaptureTagVocabulary` — the landing wing's live tags, read once per
//  opening), so this renders without a store.
//

import SwiftUI
import VariorumCore

/// The capture tag button's words (public copy).
nonisolated enum CaptureTagCopy {
    /// The button — the book card's "+" (batch 2's face).
    static let plus = "+"
    static let plusHelp =
        "Tag this note \u{2014} pick a tag or type one (\u{201C}/\u{201D} nests: life/goals); "
        + "it goes on when the note is filed"
    static let plusAccessibility = "Add a tag"

    /// **A pick's hover words** (the VX-1036 ladder's R2-3): a pick is on no
    /// note until the filing, so its card never says "Tagged" and its × never
    /// takes a tag "off" a note — the words a filed note's card says
    /// (`TagChipHelp.filed`). True of a pick, before and as it is filed.
    static func pickHelp(_ path: String) -> TagChipHelp {
        TagChipHelp(
            card: "\u{201C}\(path)\u{201D} goes on when the note is filed",
            remove: "Leave \u{201C}\(path)\u{201D} off this note")
    }
}

/// **The picked tags' pills, then the ＋ — or, while it is open, the field in
/// the ＋'s place** (the round-2 mockup's frame 8a, third state). ITEMS of the
/// row the host lays them in: a leading `TrailingFlow` after the title
/// suggestion, so the ＋ sits beside the suggestion and the field wraps to the
/// next line when the pad is narrow (its body is a bare list of views, so the
/// row's layout sees each one — batch 2's `BookCardPills` shape).
struct CaptureTagItems: View {
    let tokens: VoiceTokens
    /// The picked paths, in order (`CaptureTagPicks.paths`).
    let picks: [String]
    /// The landing wing's live vocabulary and its use counts (VX-576's
    /// most-used-first) — read by the host when the field opens.
    let vocabulary: [Tag]
    let uses: [String: Int]
    @Binding var fieldOpen: Bool
    /// The hang of the field's suggestions: above for the band at the window's
    /// foot, under for the pad.
    var suggestionsAbove = false
    let onPick: (String) -> Void
    let onRemove: (String) -> Void
    /// The field went away by her hand (an apply, ⎋) — the host hands the
    /// caret back to the words, so ⏎ files.
    let onFieldClosed: () -> Void

    /// A pick drawn as the one tag card. A pick may name a path the wing does
    /// not have yet (it is minted at the filing), so its card is drawn from the
    /// path alone: the card's colour and leaf are the path's (`TagChipColor`,
    /// `TagChipLabel`), never a row's.
    static func pill(_ path: String) -> Tag {
        Tag(id: "capture-pick:" + path, name: TagChipLabel.leaf(of: path), path: path,
            createdAt: .distantPast, updatedAt: .distantPast)
    }

    var body: some View {
        ForEach(picks, id: \.self) { path in
            // R2-3: a pick's own words — it is on no note yet.
            TagChipCard(
                tokens: tokens, tag: Self.pill(path), onRemove: { onRemove($0.path) },
                help: CaptureTagCopy.pickHelp(path))
        }
        if fieldOpen {
            TagInlineField(
                tokens: tokens, allTags: vocabulary, applied: Set(picks),
                onApply: { path in
                    onPick(path)
                    // The masthead's rule (her row 40): a tag went on, so the
                    // field does not sit open beside it — the ＋ is right there.
                    fieldOpen = false
                    onFieldClosed()
                },
                onFocusLost: {
                    // Row 40, verbatim in shape: with a tag already picked the
                    // field collapses when she clicks out of it; with none it
                    // stays for the first click.
                    if !picks.isEmpty { fieldOpen = false }
                },
                onDismiss: {
                    fieldOpen = false
                    onFieldClosed()
                },
                uses: uses,
                suggestionsAbove: suggestionsAbove)
        } else {
            Button {
                fieldOpen = true
            } label: {
                Text(CaptureTagCopy.plus)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // Never a key-view stop (the band's File button's rule): a Tab from
            // the box never lands here, so the box's own keys stay whole.
            .focusEffectDisabled()
            .focusable(false)
            .help(CaptureTagCopy.plusHelp)
            .accessibilityLabel(CaptureTagCopy.plusAccessibility)
        }
    }
}
