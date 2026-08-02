//
//  ScrapsPanel.swift
//  Variorum
//
//  13b Stage 3, Batch 3D (N19): the scrap→draft drag finally gets real
//  GEOMETRY. The drag payload (`PoolViewModel.dragProvider`) and the
//  editor's ⌥-aware `performDragOperation` have existed since Phase 10 —
//  but no layout ever put a scrap list and a draft on screen together
//  (the Blocks area and the post detail are both the detail pane). This
//  panel is the scraps' side seat in the post detail's inspector — the
//  ReferencePanel precedent ("sources beside the draft"), scraps-flavored:
//  drag a scrap into the page and it lands as EXACTLY `poolDragCopy`
//  (copy + lineage, the scrap stays home; ⌥ carries the whole fan — the
//  ratified semantics).
//
//  Drops land where an editor is live: Write's page (or a book's open
//  inline post). The note says so — the panel never pretends a Takes
//  board accepts drops.
//

import SwiftUI
import VariorumCore

/// Shared pool-title grammar (the picker in the Blocks area + this panel).
///
/// 13k K2 (her ruling — *"i think pools can show their created day, i think
/// that would be helpful"*): a nameless pool is named by the day it was
/// created, through the ONE display brain rather than a local literal. With
/// no pool at all there is still nothing to name, which is the only case the
/// old "untitled pool" wording now covers.
enum PoolNaming {
    static func title(_ pool: Container?) -> String {
        guard let pool else { return "no pool" }
        return DisplayTitle.pool(title: pool.title, createdAt: pool.createdAt)
    }
}

struct ScrapsPanel: View {
    let session: AppSession
    @State private var model: PoolViewModel
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// 13b 4D (N32(c) — S4-15): the panel rows' TAG door, registry-walked.
    static let surfaceCapabilities: [CapabilityID] = [.tagBlock]
    @State private var tagSheetBlock: CanvasView.TagSheetBlock?

    init(session: AppSession) {
        self.session = session
        _model = State(initialValue: PoolViewModel(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["scraps"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                if model.pools.count > 1 {
                    VoicedMenu(
                        tokens: tokens,
                        label: PoolNaming.title(model.activePool)
                    ) {
                        ForEach(model.pools, id: \.id) { pool in
                            Button(PoolNaming.title(pool)) { model.select(poolID: pool.id) }
                        }
                    }
                    .help("Which scraps container the panel shows")
                }
                Spacer()
            }
            Text(tokens.chromeLabel(
                "drag a scrap into the page — it lands as a copy with lineage; "
                + "the scrap stays here. ⌥-drag carries its whole fan. "
                + "Drops land where you can type: Write, or a book's open note."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Divider().overlay(tokens.line)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.items, id: \.block.blockID) { item in
                        scrapRow(item)
                        Divider().overlay(tokens.line.opacity(0.6))
                    }
                    if model.items.isEmpty {
                        Text(tokens.chromeLabel(
                            "No scraps in this pool — the Snippets area (sidebar) mints them."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 16)
                    }
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(tokens.surface)
        .task { await model.start() }
        .sheet(item: $tagSheetBlock) { target in
            BlockTagAssignmentSheet(
                session: session, blockID: target.id, preview: target.preview)
        }
    }

    private func scrapRow(_ item: Queries.PoolItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 6) {
                Text("⠿")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                Text(preview(item))
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            if item.block.hasFan {
                Text(tokens.chromeLabel(
                    "⑂\(item.block.activeVariantCount) — ⌥-drag carries all takes"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.leading, 16)
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onDrag { PoolViewModel.dragProvider(blockID: item.block.blockID) }
        // 13b 4D (N32(c) — S4-15): the tag door on the panel rows too —
        // the same sheet as the Blocks area and the canvas card.
        .contextMenu {
            Button("Tags…") {
                tagSheetBlock = CanvasView.TagSheetBlock(
                    id: item.block.blockID, preview: item.block.text)
            }
        }
        .help("Drag into the page — a copy with lineage; ⌥ carries the whole fan; "
            + "right-click to tag")
    }

    private func preview(_ item: Queries.PoolItem) -> String {
        let text = item.block.text ?? ""
        return text.isEmpty ? "(empty block)" : text
    }
}
