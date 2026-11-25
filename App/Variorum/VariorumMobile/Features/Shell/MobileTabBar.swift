//
//  MobileTabBar.swift
//  VariorumMobile
//
//  VM-52 (the VM-47 run, batch 4) — THE BOTTOM BAR.
//
//  The ticket: "The bar is three 11.5 pt words about 14 pt tall, the
//  inactive ones faint, and it disappears on every pushed screen, so changing
//  room means backing out first." Her ruling, LK-5 — "Words on a chip": three
//  words at 17 pt (Starred · Bookcase · Library), the current one on a chip,
//  56 pt targets; shown on roots and lists, hidden inside a note ("Roots and
//  lists, not notes"). The Shelf is called Bookcase (SW-1, the Mac's word).
//
//  THE FACE, on the phone layer (batch 1's roles and metrics, batch 2's
//  hit-area helper — no private control build):
//  · the words are the `tab` role — 17 pt, chrome: they follow the text size
//    to xxxLarge and hold there, and are never under 13 pt;
//  · the current word is semibold in her ink on a chip — the palette's wash,
//    near-square: the chips' corner (`Radius.small`, the Mac's 4 — VM-273,
//    S-260-3: the Bookcase strip's chip; it was 12), 8 above and below the
//    word, 16 to each side where the cell allows;
//  · the others are regular in the corrected muted ink (no longer the faint
//    the ticket names), with no shape;
//  · each word sits centred in a cell a third of the bar wide and at least
//    56 tall, and the WHOLE cell answers (LK-5's 56 pt targets; sheet §B:
//    "the whole cell answers, not the word");
//  · the bar sits on the room, its ground reaching down past the home
//    indicator, with the hairline above it in the palette's line.
//
//  THE FIT. At xxxLarge the words are ~23 pt, and a third of a 402 pt phone
//  is 134 pt: "Bookcase" semibold with 16 pt sides does not fit there. The
//  chip's sides step 16 → 8 → 4 (the spacing scale), the widest that lets the
//  word fit its cell; only where even 4 cannot (Terminal at 320 pt and
//  xxxLarge) does the word shrink, never below the floor. The rule is pure
//  (`MobileTabBarMetrics.chipSide`) and pinned over every width, voice and
//  size the phone ships.
//
//  WHERE IT SHOWS is the shell's (`MobileShellView`), and since VM-253 the
//  shell DRAWS it, once, outside the paged band: her words, "the bar should
//  stay still and just the highlighted pill should change." Before, each root
//  drew its own copy at its foot and each root rides the band's offset, so a
//  swipe slid one copy out and the next one in. Now every page that stands
//  over the bar — the three roots and each pushed LIST (a book's contents,
//  Trash, Archived, Versions' listing) — only RESERVES its place at its foot
//  (`MobileTabBarSpace`: the bar itself, never drawn, heard or touched, so the
//  page's layout is exactly what it was), and the shell lays the one bar over
//  the band's foot wherever the visible stack's top screen is a root or a list
//  (`MobileTabBarPlace`). Inside a note, on Read, Versions' reader and
//  Protection there is none.
//

import SwiftUI
import UIKit
import VariorumCore

/// The bar's numbers, in one place (the pins read them).
nonisolated enum MobileTabBarMetrics {
    /// LK-5's target: each cell answers across a third of the bar and at
    /// least this tall.
    static let target: CGFloat = 56
    /// The chip's air above and below its word (the spacing scale's 8).
    static let chipVertical: CGFloat = PhoneMetrics.Space.s8
    /// The cell's air around the chip, so a chip grown with the text size
    /// never meets the hairline or the bar's foot.
    static let cellVertical: CGFloat = PhoneMetrics.Space.s8
    /// The chip's side padding, widest first (the spacing scale's 16, 8, 4).
    static let chipSides: [CGFloat] = [PhoneMetrics.Space.s16, PhoneMetrics.Space.s8, PhoneMetrics.Space.s4]
    /// The chip's corner — the chips' near-square (VM-273: it was the boxes'
    /// standard radius, 12).
    static let chipRadius: CGFloat = PhoneMetrics.Radius.small
    /// The rule above the bar.
    static let hairline: CGFloat = 1

    /// **The fit rule:** the widest side padding that lets a word of this
    /// width sit on its chip inside a cell this wide; nil when even the
    /// narrowest cannot — the word then shrinks (never below the floor).
    static func chipSide(wordWidth: CGFloat, cellWidth: CGFloat) -> CGFloat? {
        chipSides.first { wordWidth + 2 * $0 <= cellWidth }
    }

    /// A word's drawn width at a text size — measured SEMIBOLD, the current
    /// word's face and the widest, so a word's chip never changes its fit
    /// when the choice moves to it. Main-actor, as the layer's UIKit forms are.
    @MainActor
    static func wordWidth(
        _ rendered: String, voice: ThemeVoice, at category: UIContentSizeCategory
    ) -> CGFloat {
        let role = PhoneType.spec(.tab, voice: voice)
        let current = PhoneTypeSpec(
            family: role.family, weight: .semibold, size: role.size,
            lineHeight: role.lineHeight, anchor: role.anchor, scaling: role.scaling)
        let font = PhoneType.baseUIFont(
            current, voice: voice, pointSize: PhoneType.pointSize(role, at: category))
        return ceil((rendered as NSString).size(withAttributes: [.font: font]).width)
    }
}

/// **The bottom bar** — the band's index: its doors in `MobileShellBand.pages`
/// order, so what the bar shows and what a swipe traverses are one arrangement.
struct MobileTabBar: View {
    /// The page on screen — its word sits on the chip.
    let current: MobileTab
    let tokens: VoiceTokens
    /// The shell's tab road (`MobileShellView.tabSelected`).
    let select: (MobileTab) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize
    /// The bar's own width, for the fit (zero before the first layout pass,
    /// when the widest sides are assumed).
    @State private var width: CGFloat = 0

    /// Her words for the three rooms (LK-5; SW-1: the Shelf is the Bookcase).
    /// Spoken as written in both voices; drawn voice-cased (Terminal lowercases
    /// its chrome — LK-6).
    static func word(_ page: MobileTab) -> String {
        switch page {
        case .starred: MobileStarsModel.pageName
        case .shelf: "Bookcase"
        case .library: "Library"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MobileShellBand.pages, id: \.self) { page in
                door(page)
            }
        }
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        // The room, down past the home indicator: on a pushed list the screen
        // under it is the paper, and the bar is chrome (R-47-1).
        .background(tokens.room.ignoresSafeArea(.container, edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(tokens.line).frame(height: MobileTabBarMetrics.hairline)
        }
    }

    private func door(_ page: MobileTab) -> some View {
        let word = Self.word(page)
        let chosen = page == current
        return Button {
            select(page)
        } label: {
            chip(tokens.chromeLabel(word), chosen: chosen)
                .padding(.vertical, MobileTabBarMetrics.cellVertical)
                .frame(maxWidth: .infinity, minHeight: MobileTabBarMetrics.target)
                .phoneHitArea()
        }
        .buttonStyle(.plain)
        // The door's NAME, not its rendered casing — the only way an
        // assistive reader hears the same word in both voices.
        .accessibilityLabel(word)
        .accessibilityAddTraits(chosen ? .isSelected : [])
    }

    private func chip(_ rendered: String, chosen: Bool) -> some View {
        let side = chipSide(rendered)
        return Text(rendered)
            .phoneType(
                .tab, tokens, weight: chosen ? .semibold : .regular,
                shrinkingToFloor: side == nil)
            .foregroundStyle(chosen ? tokens.ink : tokens.phone.muted)
            .lineLimit(1)
            .padding(.horizontal, side ?? MobileTabBarMetrics.chipSides.last ?? 0)
            .padding(.vertical, MobileTabBarMetrics.chipVertical)
            .background(
                RoundedRectangle(cornerRadius: MobileTabBarMetrics.chipRadius)
                    .fill(chosen ? tokens.wash : Color.clear))
    }

    /// The fit for one word at this bar's width and the current text size.
    private func chipSide(_ rendered: String) -> CGFloat? {
        guard width > 0 else { return MobileTabBarMetrics.chipSides.first }
        return MobileTabBarMetrics.chipSide(
            wordWidth: MobileTabBarMetrics.wordWidth(
                rendered, voice: tokens.voice, at: typeSize.phoneCategory),
            cellWidth: width / CGFloat(MobileShellBand.pages.count))
    }
}

/// **The bar's place at a page's foot** (VM-253). A root or a pushed list keeps
/// the bar's height at its foot so its layout is exactly what it was when it drew
/// its own copy — and the shell draws the ONE bar over that place, outside the
/// band, so the pages move and the bar does not. It IS the bar (the same view, the
/// same words and text size, so the same height by construction), never drawn,
/// never heard by an assistive reader, never touched.
struct MobileTabBarSpace: View {
    let current: MobileTab
    let tokens: VoiceTokens

    var body: some View {
        MobileTabBar(current: current, tokens: tokens, select: { _ in })
            .hidden()
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }
}

/// **Where the one bar stands** (VM-253; her LK-5, "Roots and lists, not notes").
/// The visible stack's top screen decides: a root (nil) or a pushed LIST stands
/// over the bar; a note, a book's Read page and Protection do not; Versions stands
/// over it while its listing shows and not while a moment's words are read (the
/// reader is her words, not a list — the screen reports which it shows).
@MainActor
enum MobileTabBarPlace {
    static func stands(over top: MobileRoute?, versionsListingShowing: Bool) -> Bool {
        guard let top else { return true }
        switch top {
        case .book, .trash, .archive: return true
        case .versions: return versionsListingShowing
        case .bookRead, .note, .protection: return false
        }
    }
}
