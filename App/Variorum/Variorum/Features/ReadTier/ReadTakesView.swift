//
//  ReadTakesView.swift
//  Variorum (Mac)
//
//  13g batch 6 (R5-1) — the read-only TAKES projection, her L5 word:
//  *"having a takes projection first would be fine - i honestly don't think
//  that lenses or compare need to be a side by side mode option for now or
//  potentially ever. takes is more of a main editing space so it's more
//  important to see that rpeserved."*
//
//  WHY THIS FILE EXISTS AT ALL. An unfocused pane may not mount an authority
//  owner or a routed-command handler (`PaneMount`'s whole rule), and every
//  non-Write board is one or both — so batch 1's L5 could only give the
//  un-live pane a mode LABEL, and a pane she left in Takes still rendered
//  plain read text. This is the FIRST read-only twin P-3 has grown since
//  `ReadPostView`, built to the same shape and for the same reason
//  (`SpreadBookView`'s non-live takes page is the shipped precedent).
//
//  WHAT IT DELIBERATELY IS NOT: it owns no `PaneTextAuthority`, registers no
//  command handler, mounts no TK2 surface and offers no gesture — so the
//  mount rule is untouched (exactly one live surface, ever) and nothing here
//  can become a second liveness mechanism. Clicking anywhere in the pane
//  makes it live through the pane's own `PaneFocusCatcher` (batch 1, L6) and
//  the real board takes over, in the mode it was already showing.
//
//  P1: one read keyed on the note (the `PaneHost`/`PostTitleLabel` one-shot
//  precedent, and for the same reason — a held observation on an unfocused
//  pane would re-read at the LIVE pane's autosave rate), and a `LazyVStack`
//  so drawing costs the cards on screen.
//

import SwiftUI
import VariorumCore

struct ReadTakesView: View {
    let session: AppSession
    let postID: String

    /// Whether an UNFOCUSED pane holding this note should render the takes
    /// projection rather than plain read prose. Her L5 word was TAKES-FIRST
    /// and nothing else — so this asks exactly one question, of the one
    /// source the pane's name line and the detail's restore both read
    /// (`PostDetailView.rememberedMode`), and every other mode falls through
    /// to `ReadPostView` deliberately.
    static func holdsTakes(postID: String, defaults: UserDefaults = .standard) -> Bool {
        PostDetailView.rememberedMode(postID: postID, defaults: defaults) == .takes
    }

    /// **VX-574 — her words: *"I need Takes to not be a weird light font
    /// compared to anything else."*** A take's WORDS here wear the voice's
    /// prose register — `tokens.body` in the voice's INK, the face every
    /// other reader of her prose draws (the board's panes and Write through
    /// `EditorTypography.ink`, this view's own precedent `ReadPostView`
    /// through `applyVoiceChrome`). It used to be `tokens.muted`: built at
    /// 13g batch 6 to the brief's "dimmed/read styling" (the architect's
    /// line, not a ruling of hers — R5-1 ruled only takes-first), so every
    /// unfocused pane or non-key window holding a note in Takes showed her
    /// words a grey lighter than anywhere else in the app, while the same
    /// note left in Write showed them in ink. The chrome around the words
    /// (the ✓ chosen mark, a label) keeps its quiet colours.
    static func proseInk(_ tokens: VoiceTokens) -> Color { tokens.ink }

    @State private var projection = Queries.TakesProjection()
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(projection.slots, id: \.blockID) { slot in
                    block(slot)
                }
                if projection.slots.isEmpty {
                    Text(tokens.chromeLabel("no blocks yet"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tokens.surface)
        .task(id: postID) { await load() }
    }

    @ViewBuilder
    private func block(_ slot: Queries.RenderedBlock) -> some View {
        let takes = projection.fans[slot.blockID] ?? []
        VStack(alignment: .leading, spacing: 6) {
            if takes.count > 1 {
                ForEach(takes, id: \.id) { take in
                    card(take, chosen: take.id == slot.variantID)
                }
            } else {
                // A block with no fan reads as prose, exactly as it does on
                // the board — a one-take "card" would be a box around every
                // paragraph.
                Text(slot.text ?? "")
                    .font(tokens.body)
                    .foregroundStyle(Self.proseInk(tokens))  // VX-574
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func card(_ take: Variant, chosen: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                if chosen {
                    Text(tokens.chromeLabel("✓ chosen"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.8))
                }
                if let label = take.label, !label.isEmpty {
                    Text(tokens.chromeLabel(label))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            Text(take.workingText)
                .font(tokens.body)
                .foregroundStyle(Self.proseInk(tokens))  // VX-574
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(chosen ? tokens.wash : Color.clear))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(tokens.line, lineWidth: 1))
    }

    private func load() async {
        projection = (try? await session.database.read { [postID] db in
            try Queries.takesProjection(db, post: postID)
        }) ?? Queries.TakesProjection()
    }
}
