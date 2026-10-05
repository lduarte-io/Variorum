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
//  ── 13k K12: THE CARDS ARE VISIBLE BY DEFAULT, AND THE FOLD LEFT THIS
//     FILE ────────────────────────────────────────────────────────────────
//  Her ruling flipped #52(d): *"tag cards should fold into the bar if you
//  deliberately choose that but it should default to visible."* So the
//  cards render at rest, and the ＃ door that folds them is the CONTEXT
//  BAR's — it belongs to the constant icon row (← · book · ＃ · →), not to
//  the variable-width run of chips it hides. This view therefore renders
//  the cards and their `＋`, and nothing else: it is mounted only when they
//  are showing.
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

/// **What a chip is SHAPED like** — her round-4 ruling, after flicking the
/// batch-3 captures: *"i also think that it shouldn't be such rounded pill
/// shape - i want to experiment with having a boxier look around it (maybe
/// still with rounded corners, but a little more box like)"*.
///
/// So the `Capsule` retires for a small-radius rounded box. The radius is a
/// CONSTANT rather than a literal in the view for two reasons: the fill and
/// the border must never disagree about the shape (they read the same value),
/// and her framing was an EXPERIMENT — the variants below are what the
/// capture harness renders for her to pick from, and picking one is editing
/// a single number here.
nonisolated enum TagChipShape {
    /// The shipped default. Small enough to read as a box rather than a
    /// pill (a pill at this chip's height would be ~9), large enough not to
    /// look like a mistake at 2×.
    static let cornerRadius: CGFloat = 3

    /// The propose-only set, rendered side by side in the round-4 capture
    /// strip: sharp · barely-eased · shipped · softest-still-boxy.
    static let variants: [CGFloat] = [0, 2, 3, 5]
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
    /// A typed path — applied (and created on the way) by the caller.
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void
    /// R4-3: the shipped default, overridable so the capture harness can
    /// render her radius variants without a second copy of the chip.
    var cornerRadius: CGFloat = TagChipShape.cornerRadius
    /// What the add door SAYS. The dense listing rows keep the bare ＋.
    var addLabel: String = "＋"
    /// Whether the cards carry their own ＋ (the listing rows do). The
    /// masthead cluster passes `false` since the correction round (row 15):
    /// its ONE door is the ＃ beside the cards, which opens the inline field.
    var showsAddDoor = true
    /// The correction round (rows 10/11): a DEBUG baseline probe prefix —
    /// the first chip's text reports under `<prefix>.chip`, the ＋ under
    /// `<prefix>.plus`, in the row's named space. nil (the default) probes
    /// nothing.
    var baselineProbePrefix: String? = nil
    var baselineProbeSpace: String = ""

    @State private var adding = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        // Rows 10/11 (the correction round): the row aligns on the FIRST
        // TEXT BASELINE all the way down — this stack, each chip's stack —
        // so the baseline the listing row aligns to IS the chip text's. The
        // old `.center` stacks handed up a symbol image's bottom edge as the
        // "baseline", and the chip text landed ~2 pt under the title's.
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            ForEach(Array(tags.enumerated()), id: \.element.id) { index, tag in
                chip(tag, probe: index == 0 ? baselineProbePrefix.map { "\($0).chip" } : nil)
            }
            if showsAddDoor { addDoor }
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
    ///
    /// **R4-2 — IT FITS ITS TEXT.** Her round-4 report: *"i don't like how
    /// the tags have so much whitespace in them, it's like goals and just
    /// very stretched out. i think the tag chip should fit to the length of
    /// the tag."* The mechanism was one modifier: the label carried
    /// `.frame(maxWidth: 150)`, and `maxWidth` in SwiftUI does not mean "cap
    /// it" — it means *flexible, up to* — so in a row with space to spare a
    /// five-character tag claimed all 150 points and the chip drew around
    /// the claim. Removing the frame lets the `Text` ask for its ideal
    /// width, which is what "fits the tag" is. Long tags are still safe:
    /// `Text` compresses under a tight proposal and `truncationMode(.tail)`
    /// is still what it does when it must.
    private func chip(_ tag: Tag, probe: String? = nil) -> some View {
        TagChipCard(
            tokens: tokens, tag: tag, cornerRadius: cornerRadius, onRemove: onRemove,
            baselineProbeID: probe, baselineProbeSpace: baselineProbeSpace)
    }
}

/// **ONE tag card** — the body every renderer of the cards draws (the
/// listing rows and note cards through `NoteTagChips`; the masthead's
/// cluster directly, one card per flow item — the correction round's row
/// 58, where the cards became items of a wrapping row and so needed to be
/// views of their own). The card is the tag's own colour (keyed on the
/// WHOLE path), its LEAF (her K3 ruling — the path rides the tooltip), and
/// the ✕ that takes it off this note.
///
/// **R4-2 — IT FITS ITS TEXT.** Her round-4 report: *"i don't like how
/// the tags have so much whitespace in them, it's like goals and just
/// very stretched out. i think the tag chip should fit to the length of
/// the tag."* The mechanism was one modifier: the label carried
/// `.frame(maxWidth: 150)`, and `maxWidth` in SwiftUI does not mean "cap
/// it" — it means *flexible, up to* — so in a row with space to spare a
/// five-character tag claimed all 150 points and the chip drew around
/// the claim. Removing the frame lets the `Text` ask for its ideal
/// width, which is what "fits the tag" is. Long tags are still safe:
/// `Text` compresses under a tight proposal and `truncationMode(.tail)`
/// is still what it does when it must.
struct TagChipCard: View {
    let tokens: VoiceTokens
    let tag: Tag
    var cornerRadius: CGFloat = TagChipShape.cornerRadius
    let onRemove: (Tag) -> Void
    /// Rows 10/11's DEBUG baseline probe (nil probes nothing).
    var baselineProbeID: String? = nil
    var baselineProbeSpace: String = ""

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let tint = TagChipColor.color(forPath: tag.path, dark: scheme == .dark)
        // Rows 10/11: the card's stack aligns on the FIRST TEXT BASELINE,
        // so the baseline a row aligns to IS the chip text's.
        return HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(tokens.chromeLabel(TagChipLabel.leaf(of: tag.path)))
                .font(tokens.small)
                .foregroundStyle(tint)
                .lineLimit(1)
                .truncationMode(.tail)
                .baselineProbe(baselineProbeID, in: baselineProbeSpace)
            Button {
                onRemove(tag)
            } label: {
                // A `Text` around the symbol, not a bare `Image`: a Text
                // carries a real text baseline, so the ✕ sits on the chip's
                // line and never becomes the stack's "baseline" itself.
                Text(Image(systemName: "xmark"))
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(tokens.faint)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Take “\(tag.path)” off this note")
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 1)
        // R4-3: ONE radius, read by both the fill and the border, so the
        // box and its outline can never disagree.
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(tint.opacity(0.45), lineWidth: 1))
        .help("Tagged \(tag.path)")
    }
}

extension NoteTagChips {

    private var addDoor: some View {
        Button { adding = true } label: {
            Text(addLabel)
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .baselineProbe(baselineProbePrefix.map { "\($0).plus" }, in: baselineProbeSpace)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Tag this note — type a path (“/” nests: life/goals)")
    }
}

/// **13e E8 — the same cards, on a LISTING row.** Her 13f round-11 ask was
/// two halves: *"a quick and intuitive area where you can see the posts at a
/// high level and remove / add them"*, and *"does it exist within the
/// post?"*. The second half shipped at 13g R6-1 (these chips, on the context
/// bar) and 13k K12/K3 (visible by default, leaf labels). The FIRST half —
/// the high-level area — had a tags column that could only ADD, and only
/// from tags that already existed: plain `#path` text, a `＋` menu of the
/// taxonomy, and no way to take one off without opening a sheet.
///
/// So the listing row wears the note's own grammar: the tag's colour, its
/// leaf, `✕` to take it off, `＋` to type one on (creating it if it is new).
/// This is deliberately NOT a third tag mechanism — it is `NoteTagChips`,
/// the one the context bar renders, given a row's worth of room:
///
///   - `compact` drops the row when a note carries no tags AND nothing is
///     hovered, so a listing of untagged notes stays as calm as it is today
///     (the `＋` appears with the pointer — the margin-hover discipline E7
///     brings to comments, one surface over);
///   - the doors are the caller's, so the Library's model owns every write
///     and this view stays chrome.
struct NoteTagsRow: View {
    let tokens: VoiceTokens
    let tags: [Tag]
    let allTags: [Tag]
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void
    /// True on rows that must stay quiet until pointed at (the note-card
    /// listing); false where the row always shows (the List mode's column).
    var revealsOnHover = false
    /// The DEBUG baseline probe, passed through to the chips (rows 10/11).
    var baselineProbePrefix: String? = nil
    var baselineProbeSpace: String = ""

    /// The chip row's height, RESERVED even when nothing is drawn, so a card
    /// does not jump the moment the pointer arrives (the N40 jumping class:
    /// a hover that re-heights its row is worse than the affordance is
    /// worth). It costs one small constant on untagged cards and nothing at
    /// all on the List mode's column, which always shows its `＋`.
    static let reservedHeight: CGFloat = 18

    @State private var hovering: Bool

    init(
        tokens: VoiceTokens, tags: [Tag], allTags: [Tag],
        onApply: @escaping (String) -> Void, onRemove: @escaping (Tag) -> Void,
        revealsOnHover: Bool = false,
        baselineProbePrefix: String? = nil, baselineProbeSpace: String = "",
        initiallyHovering: Bool = false
    ) {
        self.tokens = tokens
        self.tags = tags
        self.allTags = allTags
        self.onApply = onApply
        self.onRemove = onRemove
        self.revealsOnHover = revealsOnHover
        self.baselineProbePrefix = baselineProbePrefix
        self.baselineProbeSpace = baselineProbeSpace
        _hovering = State(initialValue: initiallyHovering)
    }

    var body: some View {
        if revealsOnHover {
            // **17y B1 (k) — the hover target is the ROW, never what it is
            // drawing.** Measured on the Cards view: with the pointer resting
            // on an untagged card's chip row the app ran at 100 % CPU forever
            // (pre-existing, 13e E8's shape): the quiet state's room spans the
            // row, the revealed `＋` is narrow, so revealing moved the pointer
            // OUT of the hovered view, which hid the `＋`, which put the
            // pointer back IN — a loop at display rate. One frame for both
            // states (the row's width, the reserved height), one hit shape.
            chips
                .frame(maxWidth: .infinity, minHeight: Self.reservedHeight, alignment: .leading)
                .contentShape(Rectangle())
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    NoteTagsRowProbe.hoverRegions[hovering] = $0
                }
                #endif
                .onHover { hovering = $0 }
        } else {
            chips
        }
    }

    @ViewBuilder
    private var chips: some View {
        if tags.isEmpty && revealsOnHover && !hovering {
            // Nothing to say and nothing being pointed at: the room the
            // chips would take, held open and empty.
            Color.clear.frame(height: Self.reservedHeight)
        } else {
            NoteTagChips(
                tokens: tokens, tags: tags, allTags: allTags,
                onApply: onApply, onRemove: onRemove,
                baselineProbePrefix: baselineProbePrefix,
                baselineProbeSpace: baselineProbeSpace)
        }
    }
}

#if DEBUG
/// 17y B1 (k): the hover region a reveal-on-hover row tracks, by state
/// (quiet · revealed) — the pin holds the two to one rectangle.
@MainActor
enum NoteTagsRowProbe {
    static var hoverRegions: [Bool: CGRect] = [:]
}
#endif

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
