//
//  MobileStarredView.swift
//  VariorumMobile
//
//  Round 2, batch 10 — **THE STARRED PAGE**, her words (2026-08-23):
//  *"we have the ability to star a note but I don't like where it appears
//  above the shelf, I think it's awkward placing. maybe you should be able
//  to swipe from your shelf to a list of starred notes on the home page?
//  … however, DO build a different way to see starred notes on the
//  homescreen."*
//
//  **What this is NOT, by her explicit fence:** *"there could also be a
//  smart book of starred notes - matter of fact, add smart book of starred
//  notes to the 13i phase and **don't build it yourself**."* So nothing
//  book-shaped is built here. This is a FACE over the existing star — the
//  same `Queries.starred` read the retired shelf section used, the same
//  `MobileStarsModel`, the same rows, in a place she can reach without
//  the books list paying for it.
//
//  **It shows BOTH kinds**, notes and books, because that is what a star
//  IS in this app (`StarTarget` covers `.post` and `.reading`, and the
//  shelf's book rows have carried a Star door since parity C3). Her
//  sentence says *"starred notes"*; showing only notes would silently
//  strand every starred book with no surface at all, which is the
//  see-your-data principle inverted. PROVISIONAL, recorded.
//
//  ── P1, and why there is no window here ───────────────────────────────
//  Every held listing on this phone is windowed with a truncation marker
//  (the Phase 10 discipline). This one was bounded by the DATA instead —
//  `Operations.setStarred` refused past `Operations.starLimit` (15) — until
//  VX-643 retired the cap (her 2026-10-28 word). It is now bounded by HER
//  OWN LIST: the rows are exactly the things she starred, one deliberate
//  press each, never a corpus listing — the Mac's Open list's class (also
//  unwindowed, also ∝ her own acts). The read costs ∝ the stars, never the
//  corpus (`StarsP1Tests`, core), and the `LazyVStack` below renders only
//  the rows on screen (P3). No window and no marker: a truncation marker on
//  a list she builds one press at a time would hide her own stars from her.
//  (VX-643's record names this for the cold reviewer.)
//

import SwiftUI
import VariorumCore

struct MobileStarredView<TabBar: View>: View {
    /// The ONE stars model the shell threads to every surface carrying a
    /// star door (the Mac StarDoor's one-value discipline).
    @Bindable var stars: MobileStarsModel
    let tokens: VoiceTokens
    /// VM-56 — the wing the phone stands in, named (her SW-1: the wing's
    /// name is the title on every root); nil while unknown.
    var wingName: String? = nil
    /// VM-225 — the wing's name in the path line is the interim wing door
    /// (the shell opens the list); nil in harness use draws the plain line.
    var onWingDoor: (() -> Void)? = nil
    /// The bar's place at the foot (VM-253: the shell hands its reserved place
    /// and draws the one bar over it, outside the band; a harness hands nothing).
    @ViewBuilder let tabBar: () -> TabBar
    /// A row's destination, through the model's own route brain — the
    /// Library's callback shape.
    let onOpen: (MobileRoute) -> Void

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            ScrollView {
                LazyVStack(spacing: 0) {
                    if stars.items.isEmpty {
                        Text(tokens.chromeLabel(MobileStarsModel.emptyLine))
                            .phoneType(.meta, tokens)
                            .foregroundStyle(tokens.phone.muted)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 24)
                            .accessibilityLabel(MobileStarsModel.emptyLine)
                    }
                    ForEach(stars.items, id: \.target) { item in
                        row(item)
                    }
                }
                .padding(.horizontal, 8)
            }
            // VM-51 (R-47-1, "prose should not be on the tint"): her list on
            // the paper; the path line and the tab bar stay on the room.
            .background(tokens.surface)
            // VM-61: a star refusal speaks on the shell's one line
            // (`MobileMessageLine`), never here.
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        // VM-47 (the walk's W-A1, redone): the strips beyond the shell's band —
        // the path line's room above, the bar's room below.
        .mobileEdgeGrounds(top: tokens.room, bottom: tokens.room)
    }

    /// **The top line** (VM-255): the wing's name ALONE, the wing door (R-260-1
    /// — "Home · Starred" was her example of the page word she does not need;
    /// Study "Home", Terminal "~/home"). Nothing is minted here (P38: a strip
    /// earns its doors), so the one door trailing it is the Settings gear
    /// (S-260-1). No trash door (the Library only).
    private var pathLine: some View {
        // VM-50: the same 44 pt line as its two siblings' (whose doors are
        // 44 pt hit areas), so the three roots' content starts level as the
        // band pages between them.
        HStack(alignment: .center, spacing: 16) {
            MobileWingPath(tokens: tokens, wing: wingName, onDoor: onWingDoor)
            Spacer()
            MobileSettingsGear(tokens: tokens)
        }
        .frame(minHeight: PhoneMetrics.touchMinimum)
        .padding(.horizontal, PhoneMetrics.gutter)
        .padding(.top, PhoneMetrics.Space.s4)
    }

    /// One starred row — **the retired shelf section's row, MOVED, not
    /// copied** (MobileSoul §3: mobile never forks a brain, and a row that
    /// existed in two places would be the drift class). The names ride
    /// `MobileStarsModel.displayName`, which resolves notes through the ONE
    /// display brain and books through their stored name.
    private func row(_ item: Queries.StarredItem) -> some View {
        Button {
            onOpen(MobileStarsModel.route(for: item.target))
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("★")
                    .phoneType(.meta, tokens)
                    // VM-51: the star's OWN token ("i like the blue star" —
                    // blue in every voice, `VoiceTokens.star`), never the accent
                    // (green in Terminal, the palette's hue under a palette).
                    .foregroundStyle(tokens.star)
                Text(tokens.chromeLabel(stars.displayName(item)))
                    .phoneType(.rowTitle, tokens)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(item.target.kind == .reading ? "book" : "note"))
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .phoneHitArea(alignment: .leading)
        }
        .buttonStyle(.plain)
        // The row's own act, in the phone's established row grammar (the
        // shelf book row's and the Library note row's long-press). One
        // grammar, three surfaces — never a second star affordance.
        .contextMenu {
            Button(tokens.chromeLabel(MobileStarsModel.doorTitle(starred: true))) {
                let stars = stars
                let target = item.target
                Task { await stars.toggle(target, from: .starred) }
            }
        }
        .accessibilityLabel(MobileStarsModel.spokenRow(
            name: stars.displayName(item), kind: item.target.kind))
    }
}
