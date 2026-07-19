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
    /// marker; Study's marker is empty, so this is Terminal's alone.
    private func markerLabel(_ title: String, _ target: SidebarSelection) -> String {
        selection == target ? tokens.selectionMarker + title : title
    }

    var body: some View {
        List(selection: $selection) {
            Section {
                // Batch 7 (her audit: "there's no little › to show the
                // way") — the R1 selection-marker idiom, wired at last:
                // the selected row wears the voice's marker.
                Label {
                    Text(tokens.chromeLabel(markerLabel("Shelf", .shelf)))
                } icon: {
                    Image(systemName: "books.vertical")
                }
                .tag(SidebarSelection.shelf)
                Label {
                    Text(tokens.chromeLabel(markerLabel("Library", .library)))
                } icon: {
                    Image(systemName: "text.book.closed")
                }
                .tag(SidebarSelection.library)
                Label {
                    Text(tokens.chromeLabel(markerLabel("Pool", .poolPosts)))
                } icon: {
                    Image(systemName: "tray")
                }
                .tag(SidebarSelection.poolPosts)
            } header: {
                Text(tokens.chromeLabel("Variorum"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            PoolSection(session: session, model: pool) { poolID in
                selection = .pool(poolID)
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
