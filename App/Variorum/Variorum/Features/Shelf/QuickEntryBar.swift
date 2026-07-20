//
//  QuickEntryBar.swift
//  Variorum
//
//  The R3 quick-entry bar, extracted (Sitting 9 batch 8 — her directive:
//  the Library page gets the type-immediately-creates-a-post bar exactly
//  as the round-2 mockup drew it): the hint line, the field, the blinking
//  block cursor (Terminal's idiom), ⏎ mints the typed text as a whole
//  segmented post AND OPENS it. One component, every host (Shelf,
//  Library) — the mockup's shape is the contract.
//

import SwiftUI
import VariorumCore

struct QuickEntryBar: View {
    let session: AppSession
    let onOpen: (SidebarSelection) -> Void
    /// Batch 9 (R102): the shelf is the terminal home — it opens with the
    /// cursor already in the bar, so "start typing" is literal. Library
    /// leaves focus alone.
    var autofocus = false

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var entryText = ""
    @FocusState private var entryFocused: Bool
    @State private var cursorOn = true
    @State private var lastError: String?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel("new post — start typing · ⏎ opens it as a post"))
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
                // lineLimit is LOAD-BEARING beside fixedSize — an unlimited
                // fixedSize text in non-scrolling chrome inflates the WINDOW
                // minimum during the near-zero-width min-size probe (the
                // wedged-window root cause; see SyncStatusRow).
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
        .task {
            if autofocus { entryFocused = true }
        }
    }

    private func submit() {
        let text = entryText
        entryText = ""
        lastError = nil
        Task {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            do {
                let result = try await session.runner.run { ops in
                    try ops.importPost(title: nil, text: text)
                }
                onOpen(.post(result.container.id))
            } catch {
                lastError = "New post refused: \(error)"
            }
        }
    }
}
