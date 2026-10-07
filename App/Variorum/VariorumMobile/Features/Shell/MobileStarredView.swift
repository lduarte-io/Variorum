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
//  (the Phase 10 discipline). This one is bounded by the DATA instead:
//  `Operations.setStarred` refuses past `Operations.starLimit`, and
//  `Queries.starred` returns live targets only — so the list is at most
//  `Operations.starLimit` rows (15 since her #112(b) ruling) by
//  construction, which is the argument `MobileStarsModel`'s
//  own observation already makes (*"Held: at most `starLimit` rows by
//  construction"*). A render window over a list that can never reach it,
//  and a marker that can never render, would be exactly the dead guard the
//  6c cold review named (m3: *"a dead guard reads as a rule and is not
//  one"*). The bound is pinned instead of drawn.
//

import SwiftUI
import VariorumCore

struct MobileStarredView<TabBar: View>: View {
    /// The ONE stars model the shell threads to every surface carrying a
    /// star door (the Mac StarDoor's one-value discipline).
    @Bindable var stars: MobileStarsModel
    let tokens: VoiceTokens
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
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
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
            if let error = stars.error(on: .starred) {
                // D2's rule: a refusal speaks at ITS OWN door's root. An
                // un-star fired from this page reports here, and a homeless
                // (store-read) error reports on every root including this one.
                Text(tokens.chromeLabel(error))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
    }

    /// "~/starred" (terminal) / "Starred" (study) — the two sibling roots'
    /// own path-line shape. No doors trail it: nothing is minted here, and
    /// the P38 crowding lesson says a strip earns its doors.
    private var pathLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(tokens.path([MobileStarsModel.pageName]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
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
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel(stars.displayName(item)))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(item.target.kind == .reading ? "book" : "note"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
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
