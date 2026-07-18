//
//  CommandPalette.swift
//  Variorum
//
//  Phase 13, B2 — ⌘K (R15, ratified: "every buried capability should
//  absolutely be typeable and shortcutable"): one keystroke that searches
//  everything the app can do — posts, books, blocks (the catalog query)
//  and COMMANDS (the buried capabilities: recovery, tutorial, settings,
//  voice/seam toggles, the export/import doors). The legibility mandate's
//  concrete mechanism (R10).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

/// One executable palette row.
struct PaletteItem: Identifiable, Equatable {
    enum Kind: Equatable {
        case command
        case book
        case post
        case block
    }
    let id: String
    let kind: Kind
    let title: String
    let detail: String?

    static func == (lhs: PaletteItem, rhs: PaletteItem) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
@Observable
final class PaletteModel {
    @ObservationIgnored let session: AppSession
    /// The command vocabulary — injected by the shell (actions live in
    /// composition; the palette only lists and picks).
    @ObservationIgnored var commands: [(title: String, action: @MainActor () -> Void)] = []

    var query = "" {
        didSet { Task { await refresh() } }
    }
    private(set) var items: [PaletteItem] = []

    init(session: AppSession) {
        self.session = session
    }

    func refresh() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        var result: [PaletteItem] = []
        // Commands first — matching ones only once a query exists.
        for (index, command) in commands.enumerated() {
            if trimmed.isEmpty || command.title.lowercased().contains(trimmed) {
                result.append(PaletteItem(
                    id: "command-\(index)", kind: .command,
                    title: command.title, detail: nil))
            }
        }
        let query = query
        let hits = (try? await session.database.read { db in
            try Queries.searchCatalog(db, query: query, limitPerKind: 12)
        }) ?? []
        result += hits.map { hit in
            PaletteItem(
                id: "\(hit.kind)-\(hit.id)",
                kind: hit.kind == .book ? .book : (hit.kind == .post ? .post : .block),
                title: hit.title, detail: hit.detail)
        }
        items = result
    }

    func execute(_ item: PaletteItem, onOpen: (SidebarSelection) -> Void) {
        switch item.kind {
        case .command:
            if let index = Int(item.id.dropFirst("command-".count)),
               commands.indices.contains(index) {
                commands[index].action()
            }
        case .book:
            onOpen(.reading(String(item.id.dropFirst("book-".count))))
        case .post:
            onOpen(.post(String(item.id.dropFirst("post-".count))))
        case .block:
            // A block opens its home surface — the Library's block hits
            // carry the home container; navigating block-precise is Stage
            // C's caret-seed work. For now: nothing better than ignoring a
            // missing home quietly.
            break
        }
    }
}

struct CommandPaletteView: View {
    let model: PaletteModel
    let onOpen: (SidebarSelection) -> Void
    @Environment(\.dismiss) private var dismiss
    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @FocusState private var fieldFocused: Bool

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme)
            ?? VoiceTokens.resolve(voice: .terminal, dark: scheme == .dark)
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField(tokens.chromeLabel("Find anything — posts, books, commands…"),
                      text: Binding(get: { model.query }, set: { model.query = $0 }))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .padding(12)
                .focused($fieldFocused)
                .onSubmit {
                    if let first = model.items.first {
                        model.execute(first) { selection in
                            onOpen(selection)
                        }
                        dismiss()
                    }
                }
            Divider().overlay(tokens.line)
            List(model.items) { item in
                Button {
                    model.execute(item) { selection in
                        onOpen(selection)
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: icon(for: item.kind))
                            .foregroundStyle(tokens.muted)
                            .frame(width: 16)
                        Text(item.title)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                        if let detail = item.detail {
                            Text(tokens.chromeLabel(detail))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 260, maxHeight: 340)
        }
        .frame(width: 560)
        .background(tokens.card)
        .task {
            model.query = ""
            await model.refresh()
            fieldFocused = true
        }
    }

    private func icon(for kind: PaletteItem.Kind) -> String {
        switch kind {
        case .command: "command"
        case .book: "book"
        case .post: "doc.text"
        case .block: "square.on.square"
        }
    }
}
