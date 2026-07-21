//
//  BlocksAreaView.swift
//  Variorum
//
//  Batch 12 (Sitting 9, her ruling): "blocks should just be a 4th area
//  and you should be able to make blocks as stand alone entries, not just
//  appended to one entry." The Blocks AREA: every scrap listed on its own
//  page, a quick block-entry bar that mints a STANDALONE block (⏎ keeps
//  it as a scrap — no post involved), drag-out preserved (the block-ID
//  payload; the drop is still exactly `poolDragCopy`), drop-in import
//  preserved. Supersedes the rows-in-the-sidebar build-time call — the
//  sidebar was "way too crowded"; the recorded consequence: sidebar-to-
//  editor scrap dragging retires with the rows (the pool editor and the
//  canvas remain the side-by-side scrap surfaces).
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

struct BlocksAreaView: View {
    let session: AppSession
    let model: PoolViewModel
    /// Opens the scraps container in the detail editor.
    var openPool: (String) -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var importer: ImportModel?
    @State private var entryText = ""
    @State private var cursorOn = true
    @FocusState private var entryFocused: Bool
    @State private var lastError: String?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.items, id: \.block.blockID) { item in
                        scrapRow(item)
                        Divider().overlay(tokens.line.opacity(0.6))
                    }
                    if model.items.isEmpty {
                        Text(tokens.chromeLabel(
                            "No blocks yet — type one below, or drop text here."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(24)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
            }
            .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
                guard let pool = model.activePool else { return false }
                let importModel = importer ?? ImportModel(session: session)
                importer = importModel
                return importModel.handleDrop(providers, into: .pool(pool.id))
            }
            entryBar
        }
        .background(tokens.surface)
        .task { await model.start() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.path(["Blocks"]))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
            Text(tokens.chromeLabel("· \(model.items.count) blocks · standalone scraps"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            // 13b Stage 3 (3D — N19): several pools are all REACHABLE now —
            // the area used to show only the oldest, so any later pool
            // ("tutorial scraps") rendered nowhere.
            if model.pools.count > 1 {
                VoicedMenu(
                    tokens: tokens,
                    label: "pool: \(PoolNaming.title(model.activePool))"
                ) {
                    ForEach(model.pools, id: \.id) { pool in
                        Button(PoolNaming.title(pool)) { model.select(poolID: pool.id) }
                    }
                }
                .help("Which scraps container this area shows — every pool is here")
            }
            Spacer()
            if let pool = model.activePool {
                Button(tokens.chromeLabel("open as editor")) { openPool(pool.id) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .help("The scraps container in the full editor — type, split, fan takes")
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
    }

    private func scrapRow(_ item: Queries.PoolItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(scrapPreview(item))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            if !item.tagPaths.isEmpty {
                Text(item.tagPaths.map { "#\($0)" }.joined(separator: " "))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onDrag { PoolViewModel.dragProvider(blockID: item.block.blockID) }
        .onTapGesture {
            if let pool = model.activePool { openPool(pool.id) }
        }
        .help("Drag into an open editor to copy it in (⌥ carries the whole fan); "
            + "click to open the Blocks editor")
    }

    /// The standalone-block entry (the quick-entry idiom, block-flavored):
    /// ⏎ mints ONE block in the scraps container — born standalone, never
    /// appended to a post.
    private var entryBar: some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider().overlay(tokens.line)
            Text(tokens.chromeLabel("new block — start typing · ⏎ keeps it as a standalone block"))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.top, 10)
            HStack(spacing: 2) {
                TextField("", text: $entryText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .focused($entryFocused)
                    .lineLimit(1...4)
                    .onSubmit { submit() }
                if tokens.showsBlockCursor && entryText.isEmpty && !entryFocused {
                    Rectangle()
                        .fill(tokens.accent)
                        .frame(width: 8, height: 16)
                        .opacity(cursorOn ? 1 : 0)
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .milliseconds(550))
                                cursorOn.toggle()
                            }
                        }
                }
                Spacer()
            }
            .padding(.bottom, lastError == nil ? 12 : 2)
            if let lastError {
                // lineLimit is LOAD-BEARING beside fixedSize in bottom
                // chrome (the wedged-window class rule).
                Text(lastError)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 28)
        .background(tokens.card)
        .onTapGesture { entryFocused = true }
    }

    private func scrapPreview(_ item: Queries.PoolItem) -> String {
        let text = item.block.text ?? ""
        return text.isEmpty ? "(empty block)" : text
    }

    private func submit() {
        let text = entryText
        entryText = ""
        lastError = nil
        Task {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            var poolID = model.activePool?.id
            if poolID == nil { poolID = await model.createPool() }
            guard let poolID else {
                lastError = "No blocks container could be created."
                return
            }
            do {
                _ = try await session.runner.run { ops in
                    try ops.newBlock(in: poolID, text: text)
                }
            } catch {
                lastError = "New block refused: \(error)"
            }
        }
    }
}
