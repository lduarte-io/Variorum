//
//  SidebarView.swift
//  Variorum
//
//  Phase 13, B2 — THE SIDEBAR, FINAL (R44, sitting 6): **Shelf · Library ·
//  Pool · Blocks.** The Journal folded INTO the shelf (R38); the Tags tab
//  DROPPED (R39/R45 — hierarchy stays surfaced in context + the Settings
//  manager, R52); Canvas off the sidebar (R40 — a view on a post/scraps);
//  Timeline folded into Library as a view mode (sitting 1). The Blocks
//  section keeps its scrap ROWS (drag-into-draft needs scrap and draft
//  visible together — the ratified Phase 10 reason survives the rename;
//  recorded build-time call). Voiced through the token layer.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

/// What the shell can show; the detail pane switches on it.
enum SidebarSelection: Hashable {
    /// Home — the bookshelf (R38/R44).
    case shelf
    /// Everything, sortable and searchable (R32); timeline is a view mode.
    case library
    /// The bookless-posts surface (R29/R44).
    case poolPosts
    /// Batch 12 (her ruling — supersedes the rows-in-sidebar build-time
    /// call): Blocks is a 4TH AREA, not inline sidebar rows ("way too
    /// crowded"); standalone blocks are made THERE.
    case blocks
    case post(String)
    case tag(String)
    case reading(String)
    /// A scraps container ("Blocks"), opened in the detail editor.
    case pool(String)
    /// The archived + deleted recovery surfaces (⌘K / Library-reachable).
    case recovery
    /// The modes tutorial (⌘K / Library-reachable).
    case tutorial
}

struct SidebarView: View {
    let session: AppSession
    let model: LibraryViewModel
    let pool: PoolViewModel
    @Binding var selection: SidebarSelection?
    /// Batch 14: the open post's current mode (the rail's › marker) —
    /// broadcast by PostDetailView, tracked by the shell.
    var postMode: String = PostDetailView.Mode.takes.rawValue
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme
    /// Phase 11b (B2): the drop-in import model, created on first drop.
    @State private var importer: ImportModel?

    struct TagSheetTarget: Identifiable {
        let id: String
        let title: String?
    }

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    /// The `›` idiom (R1): the selected row's label wears the voice's
    /// marker in the ACCENT color; unselected rows carry none. Study's
    /// marker is empty, so this is Terminal's alone.
    @ViewBuilder
    private func markedTitle(_ title: String, _ target: SidebarSelection) -> some View {
        HStack(spacing: 2) {
            if selection == target, !tokens.selectionMarker.isEmpty {
                Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                    .foregroundStyle(tokens.accent)
                    .fontWeight(.bold)
            }
            Text(tokens.chromeLabel(title))
        }
    }

    var body: some View {
        List(selection: $selection) {
            Section {
                // Batch 7/8 (her audit: "there's no little › to show the
                // way … it being a color ›") — the R1 selection-marker
                // idiom, wired: the selected row alone wears the voice's
                // marker, in the ACCENT color.
                Label {
                    markedTitle("Shelf", .shelf)
                } icon: {
                    Image(systemName: "books.vertical")
                }
                .tag(SidebarSelection.shelf)
                Label {
                    markedTitle("Library", .library)
                } icon: {
                    Image(systemName: "text.book.closed")
                }
                .tag(SidebarSelection.library)
                Label {
                    markedTitle("Pool", .poolPosts)
                } icon: {
                    Image(systemName: "tray")
                }
                .tag(SidebarSelection.poolPosts)
                // Batch 12: Blocks joins as the FOURTH AREA — R44's
                // sidebar, finally literal. The inline scrap rows are
                // gone ("way too crowded"); the area page holds them.
                Label {
                    markedTitle("Blocks", .blocks)
                } icon: {
                    Image(systemName: "square.on.square")
                }
                .tag(SidebarSelection.blocks)
            } header: {
                Text(tokens.chromeLabel("Variorum"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            // Batch 14 (her ruling — supersedes the bottom mode line):
            // the post MODES live here, "in the same verticle pane as
            // shelf / library / pools, but with a separator so it's clear
            // that it's only for when you're within a post."
            if case .post(let postID) = selection {
                Section {
                    ForEach(PostDetailView.Mode.allCases, id: \.self) { m in
                        Button {
                            // 13b 1b (P-4): composed routing — the rail
                            // asks the router, which reaches the mounted
                            // detail (or speaks; never a dropped
                            // broadcast).
                            session.commandRouter.requestMode(m, postID: postID)
                        } label: {
                            HStack(spacing: 2) {
                                if m.rawValue == postMode, !tokens.selectionMarker.isEmpty {
                                    Text(tokens.selectionMarker
                                        .trimmingCharacters(in: .whitespaces))
                                        .fontWeight(.bold)
                                        .foregroundStyle(tokens.accent)
                                }
                                Text(tokens.chromeLabel(m.rawValue))
                                    .font(tokens.mono)
                                    .fontWeight(m.rawValue == postMode ? .semibold : .regular)
                                    .foregroundStyle(
                                        m.rawValue == postMode ? tokens.accent : tokens.muted)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("\(m.rawValue) (⌘\((PostDetailView.Mode.allCases.firstIndex(of: m) ?? 0) + 1))")
                    }
                } header: {
                    Text(tokens.chromeLabel("this post"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(tokens.room)
        // The library import door (Phase 11b, B2): drop `.md`/plain text
        // anywhere on the sidebar → new post(s). The Blocks rows carry
        // their own, deeper drop target, so a drop there lands as scraps.
        .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
            let model = importer ?? ImportModel(session: session)
            importer = model
            return model.handleDrop(providers, into: .library)
        }
        .toolbar {
            ToolbarItem {
                Button("New Post", systemImage: "square.and.pencil") {
                    Task {
                        if let id = await model.createPost() {
                            selection = .post(id)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? importer?.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            } else if let status = importer?.lastReport {
                Text(status)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }
}
