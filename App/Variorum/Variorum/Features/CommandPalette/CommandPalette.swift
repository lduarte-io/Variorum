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
    /// Block rows: the home container to open (round 2, MINOR — a block
    /// hit must NAVIGATE; caret-precise landing is Stage C's).
    var homeContainerID: String?
    var homeIsPool = false

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

    /// Set by the view's binding, which also spawns `refresh()` — no
    /// hidden didSet task, so tests drive the model deterministically and
    /// the generation guard only has the UI's unordered tasks to order.
    var query = ""
    private(set) var items: [PaletteItem] = []
    /// Generation-stamped adoption (round 2, MINOR — the Phase 8 ruling).
    private var generation = 0

    /// 13b Stage 3, 3E (N11): keyboard row-stepping. The › marker sits on
    /// the SELECTED row (not always the first), ↓/↑ move it, ⏎ runs it.
    /// Every refresh resets to the top (a new query is a new list — the
    /// pre-N11 ⏎-runs-first behavior is the selection's DEFAULT, no longer
    /// its only truth).
    private(set) var selectedIndex = 0

    var selectedItem: PaletteItem? {
        items.indices.contains(selectedIndex) ? items[selectedIndex] : nil
    }

    func moveSelection(by delta: Int) {
        guard !items.isEmpty else { return }
        selectedIndex = min(max(selectedIndex + delta, 0), items.count - 1)
    }

    init(session: AppSession) {
        self.session = session
    }

    func refresh() async {
        generation += 1
        let mine = generation
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
        guard mine == generation else { return }  // a newer keystroke won
        result += hits.map { hit in
            PaletteItem(
                id: "\(hit.kind)-\(hit.id)",
                kind: hit.kind == .book ? .book : (hit.kind == .post ? .post : .block),
                title: hit.title, detail: hit.detail,
                homeContainerID: hit.homeContainerID, homeIsPool: hit.homeIsPool)
        }
        items = result
        selectedIndex = 0  // N11: a fresh list selects its top row
    }

    /// Executes a row. Block hits carry their block ID beside the home
    /// selection (Stage C: the caret lands ON the block, not just in the
    /// right post — the round-2 MINOR's recorded remainder).
    func execute(
        _ item: PaletteItem,
        onOpen: (SidebarSelection, _ blockID: String?) -> Void
    ) {
        switch item.kind {
        case .command:
            if let index = Int(item.id.dropFirst("command-".count)),
               commands.indices.contains(index) {
                commands[index].action()
            }
        case .book:
            onOpen(.reading(String(item.id.dropFirst("book-".count))), nil)
        case .post:
            onOpen(.post(String(item.id.dropFirst("post-".count))), nil)
        case .block:
            // A block opens its HOME surface with the caret seeded at the
            // block itself (fire-and-speak on the legibility surface).
            if let home = item.homeContainerID {
                onOpen(
                    item.homeIsPool ? .pool(home) : .post(home),
                    String(item.id.dropFirst("block-".count)))
            }
        }
    }
}

struct CommandPaletteView: View {
    let model: PaletteModel
    let onOpen: (SidebarSelection, _ blockID: String?) -> Void
    @Environment(\.dismiss) private var dismiss
    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @FocusState private var fieldFocused: Bool

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField(tokens.chromeLabel("Find anything — posts, books, commands…"),
                      text: Binding(get: { model.query }, set: { value in
                          model.query = value
                          Task { await model.refresh() }
                      }))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .padding(12)
                .focused($fieldFocused)
                // 13b 3E (N11): ↓/↑ step the › marker through the rows
                // while the field keeps the keyboard; ⏎ runs the SELECTED
                // row (the field's caret never needed the arrows — this is
                // a one-line list navigator, the ⌘K grammar everywhere).
                .onKeyPress(.downArrow) {
                    model.moveSelection(by: 1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    model.moveSelection(by: -1)
                    return .handled
                }
                .onSubmit {
                    if let selected = model.selectedItem {
                        model.execute(selected) { selection, blockID in
                            onOpen(selection, blockID)
                        }
                        dismiss()
                    }
                }
            Divider().overlay(tokens.line)
            List(model.items) { item in
                Button {
                    model.execute(item) { selection, blockID in
                        onOpen(selection, blockID)
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        // N11 (13b 3E): ⏎ runs the SELECTED row — the ›
                        // marker rides the selection, moved by ↓/↑.
                        Text(item.id == model.selectedItem?.id
                            ? tokens.selectionMarker.trimmingCharacters(in: .whitespaces)
                            : " ")
                            .font(tokens.body.weight(.bold))
                            .foregroundStyle(tokens.accent)
                            .frame(width: 10)
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
