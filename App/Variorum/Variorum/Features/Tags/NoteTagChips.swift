//
//  NoteTagChips.swift
//  Variorum (Mac)
//
//  Phase 13g, batch 7 — her ruling R6-1, from round 5's ask: *"I also want
//  better ergonomics on the tags - I'm open to suggestions on how to achieve
//  that, but I like it when there are little tag cards that are different
//  colors and it's easier to add and remove them and they might belong on
//  the top bar."*
//
//  So: coloured tag cards on the CONTEXT BAR — the pane's own top bar, which
//  already answers "where is this note" and now answers "what is it about"
//  in the same line. `＋` opens a popover that types-to-apply with
//  autocomplete over the live taxonomy; `✕` on a chip removes it. The bottom
//  bar's `tags…` sheet door retires with this (R6-1's letter, "tags leave
//  the bottom bar entirely"); every OTHER tag door is untouched — the
//  Library row's Tags…, the Pool's, and the tag manager in Settings (R52).
//
//  ── THE COLOUR IS THE TAG'S, FOREVER ────────────────────────────────────
//  Derived from the tag's PATH through `BlockTint.stableHash` — the 9d
//  stable-colour family, chosen deliberately over an index into a palette:
//  the same tag is the same colour in every note, across launches and across
//  devices, and applying a new tag never re-ripples the colours of the ones
//  already there (the never-re-ripple rule the tint mode was built on).
//
//  ── IT FOLDS WITH THE BAR ───────────────────────────────────────────────
//  Collapsed (the default since WT-2) the chips become ONE glyph door
//  carrying the count — the bar's own grammar, where every half keeps a
//  glyph so a fold is never a one-way door. Recorded as a build-time call
//  (QUESTIONS #52): always-visible chips are one line away.
//

import SwiftUI
import VariorumCore

/// **What a chip SAYS** — her ruling K3 (13k, 2026-08-02, overturning the
/// 13g build-time call at QUESTIONS #52(e)): *"chips should show leaf
/// only"*, the alternative that entry offered — shorter cards, the full path
/// in the tooltip.
///
/// Keyed on the PATH rather than read off `tag.name` deliberately: the chip
/// already has exactly one input, and the colour beside it is keyed on the
/// whole path (`TagChipColor`), so the two rules read together — **the label
/// narrows, the colour does not**. `life/goals` and `work/goals` therefore
/// both say "goals" and stay two different colours, which is the whole point
/// of leaving the colour alone. Hierarchy stays surfaced (R45) in the
/// tooltip, in the adder's suggestions, and in the tag manager.
nonisolated enum TagChipLabel {
    /// The last segment of a hierarchical path. A path with no separator is
    /// its own leaf; a degenerate path (empty, or trailing "/") reads as
    /// itself rather than as nothing — a chip must never be blank.
    static func leaf(of path: String) -> String {
        guard let last = path.split(separator: "/").last else { return path }
        return String(last)
    }
}

/// The stable per-tag colour (the `LineageStripe` rule, keyed on path).
nonisolated enum TagChipColor {
    /// Hue in 0..<1 from the tag's path. Same path, same hue, always.
    static func hue(forPath path: String) -> Double {
        Double(BlockTint.stableHash(path) % 360) / 360.0
    }

    static func color(forPath path: String, dark: Bool) -> Color {
        Color(
            hue: hue(forPath: path),
            saturation: dark ? 0.45 : 0.55,
            brightness: dark ? 0.72 : 0.86)
    }
}

/// The note's tags, as cards, with their add and remove doors.
struct NoteTagChips: View {
    let tokens: VoiceTokens
    let tags: [Tag]
    /// The live taxonomy — the popover's autocomplete pool. Typing a path
    /// that is not in it CREATES it (through the standing ops), which is
    /// `TagAssignmentViewModel.applyTypedPath`'s long-shipped behaviour.
    let allTags: [Tag]
    let collapsed: Bool
    /// A typed path — applied (and created on the way) by the caller.
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void

    @State private var adding = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 4) {
            if collapsed {
                foldedGlyph
            } else {
                ForEach(tags, id: \.id) { chip($0) }
                addDoor
            }
        }
        .popover(isPresented: $adding, arrowEdge: .bottom) {
            TagChipAdder(
                tokens: tokens, allTags: allTags, applied: Set(tags.map(\.path)),
                onApply: { path in
                    adding = false
                    onApply(path)
                })
        }
    }

    /// One card: the tag's own colour (keyed on the WHOLE path), its LEAF
    /// (her K3 ruling — the path rides the tooltip), and the ✕ that takes it
    /// off this note.
    private func chip(_ tag: Tag) -> some View {
        let tint = TagChipColor.color(forPath: tag.path, dark: scheme == .dark)
        return HStack(spacing: 3) {
            Text(tokens.chromeLabel(TagChipLabel.leaf(of: tag.path)))
                .font(tokens.small)
                .foregroundStyle(tint)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 150, alignment: .leading)
            Button {
                onRemove(tag)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(tokens.faint)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Take “\(tag.path)” off this note")
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 1)
        .background(tint.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(tint.opacity(0.45), lineWidth: 1))
        .help("Tagged \(tag.path)")
    }

    private var addDoor: some View {
        Button { adding = true } label: {
            Text("＋")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Tag this note — type a path (“/” nests: life/goals)")
    }

    /// Folded: still a door, still says how many (the bar's own rule).
    private var foldedGlyph: some View {
        Button { adding = true } label: {
            HStack(spacing: 2) {
                Image(systemName: "number")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                if !tags.isEmpty {
                    Text(tokens.chromeLabel("\(tags.count)"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .overlay(Capsule().stroke(tokens.line, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help(tags.isEmpty
            ? "Tag this note"
            : "Tagged \(tags.map(\.path).joined(separator: ", ")) — click to add another")
    }
}

/// The `＋` popover: type a path, ⏎ applies. Suggestions are the live
/// taxonomy filtered by what has been typed, already-applied paths dropped —
/// clicking one applies it.
struct TagChipAdder: View {
    let tokens: VoiceTokens
    let allTags: [Tag]
    let applied: Set<String>
    let onApply: (String) -> Void

    @State private var typed = ""
    @FocusState private var focused: Bool

    /// The autocomplete list — case-insensitive substring over paths, the
    /// already-applied removed, capped so the popover never grows into a
    /// scroll of a whole taxonomy.
    var suggestions: [Tag] {
        Self.suggestions(allTags, typed: typed, applied: applied)
    }

    /// Pure, so the matching rule is pinnable without a popover.
    static func suggestions(
        _ all: [Tag], typed: String, applied: Set<String>, limit: Int = 8
    ) -> [Tag] {
        let needle = typed.trimmingCharacters(in: .whitespaces).lowercased()
        return all
            .filter { !applied.contains($0.path) }
            .filter { needle.isEmpty || $0.path.lowercased().contains(needle) }
            .prefix(limit)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("tag — ⏎ applies it (“/” nests: life/goals)", text: $typed)
                .textFieldStyle(.roundedBorder)
                .frame(width: 240)
                .focused($focused)
                .onSubmit { apply(typed) }
            if suggestions.isEmpty {
                Text(allTags.isEmpty
                    ? "No tags yet — type one and ⏎ makes it."
                    : "⏎ makes “\(typed.trimmingCharacters(in: .whitespaces))” a new tag.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                    .frame(width: 240, alignment: .leading)
            } else {
                ForEach(suggestions, id: \.id) { tag in
                    Button { apply(tag.path) } label: {
                        Text(tokens.chromeLabel(tag.path))
                            .font(tokens.small)
                            .foregroundStyle(
                                TagChipColor.color(forPath: tag.path, dark: false))
                            .lineLimit(1)
                            .frame(width: 234, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .task { focused = true }
    }

    private func apply(_ path: String) {
        let trimmed = path.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onApply(trimmed)
    }
}
