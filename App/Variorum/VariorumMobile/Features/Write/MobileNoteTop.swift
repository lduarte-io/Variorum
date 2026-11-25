//
//  MobileNoteTop.swift
//  VariorumMobile
//
//  VM-260 batch 4b (R-260-13 as picked, ratified R-260-14) — **THE NOTE'S TOP:
//  THE TITLE ON ITS OWN ROW, ONE ROW OF ICONS UNDER IT, AND ONLY THAT ROW
//  STAYS.** Her words (2026-11-25): "maybe it would be best for the title to get
//  more space on top and then there's one row of icons, and just that row of
//  icons is what stays with you as you scroll." Her pick: "A — the title on top,
//  one icon row that stays … I don't think there should be a verticle line
//  between the options. i'd make sure it's easy to click on tags to see them
//  expand and then click on the tag icon so tags close again too." The drawing
//  is `notes/plans/vm-260/note-top-options.html`, frame P; the record is BATCH
//  4b in `notes/plans/fixes/vm-260-phone-look.md`.
//
//  The pieces `MobileWriteScreen` composes (the phone target only — nothing
//  seam-side, nothing in `Shared/`, no line in the editor's text view):
//  · `MobileNoteTitleGiveWay` — THE RULE, pure: when the note's own scroll
//    takes the title away and when it gives it back.
//  · `MobileNoteTitleTracker` — the text view's scroll, READ (key-value
//    observation of its offset — nothing of the editor's changes); only the
//    gone/back fact is observed, so the screen's body is asked again only when
//    the title flips, never per scrolled frame (P3).
//  · `MobileNoteTopDoors` — the row's glyphs and every moved door's words.
//  · `MobileNoteTagStrip` — the note's tags, opened in place under the row.
//  · `MobileNoteStackMenu` — the one door's three rows: blocks · lens · more info.
//

import Observation
import SwiftUI
import UIKit
import VariorumCore

// MARK: - The rule

/// **When the note's title gives way** — the drawing's own mechanics read as a
/// rule over the note's scroll. In the drawing the title is the top of the
/// note's content: it scrolls away with her text and is back only when the top
/// of her text is. The text view is the editor's own scroll view, so the title
/// cannot ride inside it frame by frame without a seam change (the record's
/// C-4b-1); it leaves as soon as the page has really scrolled, and returns only
/// at the page's rest — so the title and her text move together at the flip.
///
/// The numbers are batch 4a's (`MobileTopGiveWay`, P-260-4a-1 — one set): the
/// title leaves once the page stands past a wobble (24 pt) from its rest, and
/// is back within 8 pt of it; between the two nothing changes (the
/// hysteresis). Unlike the roots' tops, an upward nudge mid-note does NOT bring
/// it back: the title is the top of her text, and giving it back mid-note
/// would push the line she is reading down a title's height (the jump batch
/// 4a's spacer exists to avoid on the Library).
nonisolated enum MobileNoteTitleGiveWay {
    /// The page stands past this from its rest → the title has gone.
    static let leave: CGFloat = MobileTopGiveWay.wobble
    /// Within this of its rest the page wears its title.
    static let rest: CGFloat = MobileTopGiveWay.rest

    /// **One reading**: whether the title is gone, given where the page now
    /// stands (its travel — `MobileTopGiveWay.travel`, the clamp that makes a
    /// rubber-band no travel) and whether it was gone.
    static func gone(_ wasGone: Bool, travel: CGFloat) -> Bool {
        if travel <= rest { return false }
        if travel > leave { return true }
        return wasGone
    }
}

// MARK: - The text view's scroll, read

/// **The note's scroll, read for its title.** The tracker watches the editor's
/// text view's content offset by key-value observation (a READ: no delegate,
/// no line of the editor), feeds every reading to the rule, and publishes the
/// one observed fact — the title gone or back — only when it flips, a turn
/// later (so a flip landing inside a layout pass never writes the screen's
/// state from inside it). Under Reduce Motion the flip is immediate; else the
/// title and her text slide together over 0.2 s.
@MainActor
@Observable
final class MobileNoteTitleTracker {
    /// The title has given way — the one fact the screen reads.
    private(set) var gone = false
    /// The rule's latest answer (unobserved; `gone` follows it a turn later).
    @ObservationIgnored private var ruled = false
    @ObservationIgnored private var publishing = false
    @ObservationIgnored private var observation: NSKeyValueObservation?
    @ObservationIgnored private weak var watched: UIScrollView?

    /// Starts reading `view`'s scroll (idempotent for the same view).
    func watch(_ view: UIScrollView?) {
        guard let view, view !== watched else { return }
        watched = view
        observation = view.observe(\.contentOffset, options: [.initial, .new]) { [weak self] view, _ in
            MainActor.assumeIsolated { self?.read(view) }
        }
    }

    /// One reading of the scroll view as it stands.
    func read(_ view: UIScrollView) {
        let insets = view.adjustedContentInset
        observe(travel: MobileTopGiveWay.travel(
            offset: view.contentOffset.y, insetTop: insets.top, insetBottom: insets.bottom,
            content: view.contentSize.height, container: view.bounds.height))
    }

    /// The page's travel moved.
    func observe(travel: CGFloat) {
        ruled = MobileNoteTitleGiveWay.gone(ruled, travel: travel)
        guard ruled != gone, !publishing else { return }
        publishing = true
        Task { @MainActor [weak self] in self?.publish() }
    }

    private func publish() {
        publishing = false
        guard ruled != gone else { return }
        let next = ruled
        if UIAccessibility.isReduceMotionEnabled {
            gone = next
        } else {
            withAnimation(.easeOut(duration: MobileNoteTopDoors.flipSeconds)) { gone = next }
        }
    }
}

// MARK: - The doors' glyphs and words

/// **The note top's doors** — the row's glyphs (the Mac's own symbol choices
/// where it has one: its book door's `book`, its masthead ＃'s `number`; S-260-2)
/// and the moved doors' names. Every moved door keeps the name it answered to
/// as a chip or a tool (P-1): "Books holding this note", "Tags", "Blocks",
/// "Lenses", "More Info", "Entry Date", "Lock Note" / "Unlock Note".
enum MobileNoteTopDoors {
    static let bookSymbol = "book"
    static let tagsSymbol = "number"
    static let stackSymbol = "square.3.layers.3d"
    static let calendarSymbol = "calendar"

    /// The one door for blocks · lens · more info (C-13-3). Its name lists the
    /// three it holds, so VoiceOver says what is behind it; the three rows keep
    /// the chips' own names (`blocksName`, `lensesName`, `moreInfoName`).
    static let stackName = "Blocks, Lenses and More Info"
    static let blocksName = "Blocks"
    static let lensesName = "Lenses"
    static let moreInfoName = "More Info"
    /// The stack door's value while the active lens has a pick that fell back —
    /// the chip's own "say loudly" marker (13j's gate ruling (5)), still said on
    /// the page the lens drives.
    static let fellBackValue = "a pick fell back"

    /// The open tag strip's add door: drawn "+ tag", spoken "Add Tag" (the
    /// drawn word inside the name — label in name).
    static let addTagWord = "+ tag"
    static let addTagName = "Add Tag"

    /// The Note sheet's head: the seal's words are the act (the spoken names
    /// "Lock Note" / "Unlock Note" hold them — label in name), the date's the
    /// day when set, else the old chip's "no date".
    static let lockWord = "Lock"
    static let unlockWord = "Unlock"
    static let noDateWord = "no date"
    static let dateName = "Entry Date"

    /// The title's flip: how long the slide takes (not under Reduce Motion).
    static let flipSeconds: Double = 0.2

    /// **The book door's ink**: the corrected faint while the note is in no
    /// book (the glyph still reads — the faint clears 3:1 on every ground, and
    /// the faint is for glyphs, PhoneInks' rule), her ink in one book, the
    /// accent in several (the membership line's own "accent when it appears in
    /// several", carried to the glyph).
    static func bookInk(count: Int, tokens: VoiceTokens) -> Color {
        switch count {
        case 0: tokens.phone.faint
        case 1: tokens.ink
        default: tokens.accent
        }
    }
}

// MARK: - The tags, opened in place

/// **The note's tags, opened in place** (R-260-13: "# opens the note's tags in
/// place and the same # closes them"): a centred strip under the row — the
/// tags as near-square chips in her ink on the wash (the drawing's), then the
/// add door; every one opens the note's tags sheet, where tags are applied and
/// taken off (adding stays one press away). It travels with the row while
/// open (C-13-2): it is part of the note's top that stays.
struct MobileNoteTagStrip: View {
    let model: MobileNoteTagsModel
    let tokens: VoiceTokens
    let openSheet: () -> Void

    var body: some View {
        MobileChipFlow(hSpacing: PhoneMetrics.Space.s8, vSpacing: 0, centred: true) {
            ForEach(model.applied, id: \.id) { tag in
                let word = "#\(MobileShelfFaces.leaf(tag.path))"
                Button(tokens.chromeLabel(word), action: openSheet)
                    .buttonStyle(PhoneChipStyle(tokens: tokens, selected: true))
                    .accessibilityLabel(word)
            }
            Button(tokens.chromeLabel(MobileNoteTopDoors.addTagWord), action: openSheet)
                .buttonStyle(PhoneInlineActStyle(tokens: tokens))
                .accessibilityLabel(MobileNoteTopDoors.addTagName)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - The one door's three rows

/// What the stack door's menu opens — each its chip's own sheet.
enum MobileNoteStackChoice {
    case blocks, lens, moreInfo
}

/// **The stack door's menu** (C-13-3): three rows — blocks · lens · more info —
/// each opening what its chip opened. Drawn as a small popover of the phone's
/// menu rows, not the system `Menu`: a SwiftUI `Menu`'s rows present into a
/// context-menu hierarchy no pin can reach (`MobileNoteActionsSheet`'s recorded
/// probe), and every moved door keeps a pin that drives it. The rows draw the
/// chips' own words (so "blocks ▸ leaving" and the guide's sentences still name
/// a door on screen) and speak the chips' own names; the lens row keeps the
/// chip's states — the active lens named, the fallback in the alarm with ⚠.
struct MobileNoteStackMenu: View {
    let tokens: VoiceTokens
    let lensWord: String
    let lensFellBack: Bool
    let referenceCount: Int
    let choose: (MobileNoteStackChoice) -> Void

    var body: some View {
        VStack(spacing: 0) {
            PhoneMenuRow(tokens.chromeLabel(MobileBlockListModel.chipWord), tokens: tokens) {
                choose(.blocks)
            }
            .accessibilityLabel(MobileNoteTopDoors.blocksName)
            Divider().overlay(tokens.line)
            PhoneMenuRow(
                tokens.chromeLabel(lensWord + (lensFellBack ? " \u{26A0}" : "")),
                tone: lensFellBack ? .alarm : .ink, tokens: tokens
            ) {
                choose(.lens)
            }
            .accessibilityLabel(lensFellBack ? MobileWriteScreen.lensFallbackChipLabel : MobileNoteTopDoors.lensesName)
            Divider().overlay(tokens.line)
            PhoneMenuRow(
                tokens.chromeLabel(MobileReferencesModel.chipLabel(count: referenceCount)), tokens: tokens
            ) {
                choose(.moreInfo)
            }
            .accessibilityLabel(MobileNoteTopDoors.moreInfoName)
            .accessibilityValue(referenceCount > 0 ? "\(referenceCount)" : "")
        }
        .padding(.horizontal, PhoneMetrics.Space.s16)
        .padding(.vertical, PhoneMetrics.Space.s4)
        .frame(minWidth: MobileNoteStackMenu.width)
        .background(tokens.surface)
        .presentationBackground(tokens.surface)
        .presentationCompactAdaptation(.popover)
    }

    /// The popover's width — about the drawing's (190), room for "more info · 12".
    static let width: CGFloat = 220
}
