//
//  BookReadTitles.swift
//  Variorum (Mac)
//
//  **VX-881 (the VX-1036 run, batch 4) — a note's title while reading.** Her
//  words at sitting 2, on the round-1 mockup's frame 10: *"the title note
//  switching looks good"* (R-1036-21); her pick at sitting 3: "A quiet line"
//  (R-1036-40). RT-1: a per-book switch on Read's own controls, remembered per
//  book on this device — a way of looking — that shows each note's title as a
//  quiet muted line in Read ▸ Scroll (the line itself is `FlowNoteTitle`, in
//  `ReadingFlowView.swift`, inside each story row).
//
//  What lives here (P-9 — its own concern, never more of `BookView` or
//  `BookViewModel`):
//  - `BookNoteTitlesPrefs` — the switch's memory, per book on this Mac (the
//    note-memory domain, `BookTagsShownPrefs`' class, its own key family);
//  - `BookReadTitlesModel` — the switch's state, observed by the book view;
//  - `BookReadTitlesCopy` + `BookReadTitlesSwitch` — the chip's words and face
//    (the round-1 mockup's frame 10d: "note titles: shown", beside Scroll ·
//    Pages);
//  - `BookReadControlsRule` + `BookReadControlsRow` — Read's controls' line:
//    the chip beside the picker when both fit at their STABLE widths, under it
//    otherwise (VX-896's law — never `ViewThatFits`; the navigator's floor since
//    batch 3 is 229 pt in Terminal and 203 in Study, where the two do not fit).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The line's rule and its face

/// **What the quiet title line says, and what it adds to its story row** — see
/// `ReadingFlowView.swift`'s VX-881 section for where the line lives and why.
nonisolated enum FlowNoteTitle {
    /// The line's box — the mockup's 13-px serif at the page's line height,
    /// fixed so its height is a constant the geometry can count on (one line,
    /// cut with "…" when long).
    static let lineHeight: CGFloat = 20
    /// The gap between the line and the note's first paragraph (the mockup's
    /// 5 px under the caption).
    static let gap: CGFloat = 5
    /// What the line adds to its story row: the box and its gap.
    static var lead: CGFloat { lineHeight + gap }
    /// The page's caption size (the mockup's `.rt-a`: 13 px, the chapter ink).
    static let fontSize: CGFloat = 13

    /// **The words the line says, or nil for no line.** Nil while the book
    /// hides titles; nil for an UNTITLED note (PROVISIONAL P-1036-B4-1 — the
    /// calm default: the line names a note its author named; the alternatives,
    /// recorded: the note's first words, the Library's derivation; or the
    /// book's display title, the day for a dated note). A title is the stored
    /// one, trimmed — the book's own row, no read.
    static func line(for entry: Queries.ReadingEntry, shown: Bool) -> String? {
        guard shown else { return nil }
        let title = (entry.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? nil : title
    }

    /// What a story row carries above its prose for this entry.
    static func lead(for entry: Queries.ReadingEntry, shown: Bool) -> CGFloat {
        line(for: entry, shown: shown) == nil ? 0 : lead
    }
}

/// **The line itself** — the page's serif at the caption size, in the chapter
/// headings' muted ink (the round-1 mockup's `.rt-a`), one line in a fixed box
/// so its height is the constant the geometry counts (`FlowNoteTitle.lead`). A
/// click wakes the note as a whole (the empty note's own road — the prose's
/// clicks wake at their block). Drawn by `FlowStoryRow`, inside the story's row,
/// above its measured surface.
struct FlowNoteTitleLine: View {
    let title: String
    let page: ReadingPageTokens
    let onWake: () -> Void
    /// The flow's DEBUG counter (`ReadingFlowMaterialization.titleLines`).
    var onRealized: (() -> Void)? = nil

    var body: some View {
        Text(title)
            .font(.system(size: FlowNoteTitle.fontSize, design: .serif))
            .foregroundStyle(page.chapterInk)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, minHeight: FlowNoteTitle.lineHeight,
                   maxHeight: FlowNoteTitle.lineHeight, alignment: .bottomLeading)
            .padding(.bottom, FlowNoteTitle.gap)
            .contentShape(Rectangle())
            .onTapGesture { onWake() }
            .accessibilityAddTraits(.isHeader)
            .onAppear { onRealized?() }
    }
}

// MARK: - The switch's memory (per book, this Mac)

/// The per-book memory. `UserDefaults` INJECTED (the app passes the note-memory
/// domain, `NoteMemoryDefaults.store` — the tags switch's and the Index
/// grouping's own; every pin a scratch suite). Hidden — the default, today's
/// page — is stored as no key at all.
struct BookNoteTitlesPrefs {
    let defaults: UserDefaults

    static func key(_ readingID: String) -> String { "book.noteTitlesShown." + readingID }

    func shown(for readingID: String) -> Bool {
        defaults.bool(forKey: Self.key(readingID))
    }

    func setShown(_ shown: Bool, for readingID: String) {
        if shown {
            defaults.set(true, forKey: Self.key(readingID))
        } else {
            defaults.removeObject(forKey: Self.key(readingID))
        }
    }
}

// MARK: - The model

/// **The switch's state for ONE book** — read from its memory at the book's
/// open, written back at each choice. Observed by the book view, which hands
/// the flow `shown` (`ReadingFlowView.noteTitles`).
@MainActor
@Observable
final class BookReadTitlesModel {
    let readingID: String
    @ObservationIgnored private let prefs: BookNoteTitlesPrefs

    /// Hidden until she chooses otherwise (today's page).
    private(set) var shown: Bool

    init(readingID: String, defaults: UserDefaults = NoteMemoryDefaults.store) {
        self.readingID = readingID
        self.prefs = BookNoteTitlesPrefs(defaults: defaults)
        self.shown = BookNoteTitlesPrefs(defaults: defaults).shown(for: readingID)
    }

    /// Choose — remembered for this book on this Mac. A no-op writes nothing.
    func setShown(_ shown: Bool) {
        guard shown != self.shown else { return }
        self.shown = shown
        prefs.setShown(shown, for: readingID)
    }

    /// The chip's one act.
    func toggle() { setShown(!shown) }
}

// MARK: - The words (public copy, sentence case; Terminal lowers its chrome)

/// PROVISIONAL with the face (§4f names it only in words — "the chip 'note
/// titles: shown' beside Scroll · Pages"): the chip says its state, the
/// round-1 mockup's frame 10d words.
nonisolated enum BookReadTitlesCopy {
    static func chip(shown: Bool) -> String {
        shown ? "note titles: shown" : "note titles: hidden"
    }
    static let help =
        "Show each note\u{2019}s title as a quiet line above it while you read the book as one "
        + "scroll. A way of looking: remembered for this book on this Mac."
}

// MARK: - The face

/// **The per-book switch** — a chip beside Scroll · Pages, drawn only while
/// Read shows the scroll (Pages already starts each note under its title, so
/// there the switch could never act — P-2). A click turns it. Its face is the
/// tags switch's (`BookTagsSwitch` — a muted capsule at rest, the accent while
/// on), and it stands at its STABLE width — the wider of its two faces — so
/// turning it never moves the line it shares.
struct BookReadTitlesSwitch: View {
    let tokens: VoiceTokens
    let shown: Bool
    let toggle: () -> Void

    @Environment(\.fontResolutionContext) private var fontContext

    /// The chip's horizontal padding (the tags switch's).
    static let padding: CGFloat = 7

    var body: some View {
        Button(action: toggle) {
            Text(tokens.chromeLabel(BookReadTitlesCopy.chip(shown: shown)))
                .font(tokens.small)
                .foregroundStyle(shown ? tokens.accent : tokens.muted)
                .lineLimit(1)
                .padding(.horizontal, Self.padding)
                .padding(.vertical, 1)
                .overlay(Capsule().stroke(shown ? tokens.accent.opacity(0.5) : tokens.line, lineWidth: 1))
                .fixedSize()
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .frame(width: Self.stableWidth(tokens: tokens, in: fontContext), alignment: .leading)
        .help(BookReadTitlesCopy.help)
        .accessibilityLabel(BookReadTitlesCopy.chip(shown: shown))
    }

    /// The wider of the chip's two faces in this voice, resolved in the view's
    /// own font context (the mode row's stable-width method), memoized.
    static func stableWidth(tokens: VoiceTokens, in context: Font.Context) -> CGFloat {
        let font = tokens.small.resolve(in: context).ctFont as NSFont
        let faces = [true, false].map { tokens.chromeLabel(BookReadTitlesCopy.chip(shown: $0)) }
        let key = MemoKey(font: font.fontName, size: font.pointSize, faces: faces)
        if let known = memo[key] { return known }
        let widest = faces.map {
            ($0 as NSString).size(withAttributes: [.font: font]).width.rounded(.up)
        }.max() ?? 0
        let measured = widest + 2 * padding
        memo[key] = measured
        return measured
    }

    private struct MemoKey: Hashable {
        var font: String
        var size: CGFloat
        var faces: [String]
    }

    private static var memo: [MemoKey: CGFloat] = [:]
}

// MARK: - Read's controls' line

/// **One line or two** — pure, so the rule is pinned without a window: the
/// switch rides beside the picker when the picker, the gap and the switch's
/// stable width fit the room at whole points; else it goes under the picker.
nonisolated enum BookReadControlsRule {
    static let spacing: CGFloat = 8
    static let lineSpacing: CGFloat = 6

    static func oneLine(available: CGFloat, leading: CGFloat, trailing: CGFloat) -> Bool {
        guard available.isFinite else { return true }
        return leading.rounded(.up) + spacing + trailing.rounded(.up) <= available.rounded(.down)
    }
}

/// **Read's controls** — Scroll · Pages, then (in Scroll) the titles switch.
/// ONE layout over the same views, decided from the subviews' ideal widths,
/// which are stable by construction (the segmented picker's never changes; the
/// switch frames itself to its wider face). A lone subview (Pages — no switch)
/// is laid as itself.
struct BookReadControlsRow: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        // A lone subview (Pages) takes the proposal it would have had without
        // this layout — today's face, unchanged.
        guard subviews.count >= 2 else {
            return subviews.first?.sizeThatFits(proposal) ?? .zero
        }
        let lead = subviews[0].sizeThatFits(.unspecified)
        let trail = subviews[1].sizeThatFits(.unspecified)
        let available = proposal.width ?? .infinity
        if BookReadControlsRule.oneLine(available: available, leading: lead.width, trailing: trail.width) {
            return CGSize(
                width: lead.width + BookReadControlsRule.spacing + trail.width,
                height: max(lead.height, trail.height))
        }
        return CGSize(
            width: max(lead.width, trail.width),
            height: lead.height + BookReadControlsRule.lineSpacing + trail.height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard subviews.count >= 2 else {
            subviews.first?.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
            return
        }
        let lead = subviews[0].sizeThatFits(.unspecified)
        let trail = subviews[1].sizeThatFits(.unspecified)
        if BookReadControlsRule.oneLine(available: bounds.width, leading: lead.width, trailing: trail.width) {
            let height = max(lead.height, trail.height)
            subviews[0].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + (height - lead.height) / 2),
                proposal: ProposedViewSize(lead))
            subviews[1].place(
                at: CGPoint(
                    x: bounds.minX + lead.width + BookReadControlsRule.spacing,
                    y: bounds.minY + (height - trail.height) / 2),
                proposal: ProposedViewSize(trail))
        } else {
            subviews[0].place(at: bounds.origin, proposal: ProposedViewSize(lead))
            subviews[1].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + lead.height + BookReadControlsRule.lineSpacing),
                proposal: ProposedViewSize(trail))
        }
    }
}
