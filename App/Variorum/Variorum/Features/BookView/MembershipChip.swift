//
//  MembershipChip.swift
//  Variorum
//
//  Phase 13, B3 — the R35 UI REQUIREMENT (her "nail this down", resolved
//  sitting 5): when a post appears in multiple books, the editor SAYS so,
//  and duplicate-as-version is presented as THE way to separate this
//  book's copy from what shows elsewhere — the divergence door made
//  discoverable at the moment it matters. Membership is not ownership:
//  editing a post edits THE post, everywhere (R31).
//

import SwiftUI
import VariorumCore

struct MembershipChip: View {
    let session: AppSession
    let postID: String
    var onOpenBook: ((String) -> Void)?

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var books: [Reading] = []
    @State private var popoverShown = false
    @State private var status: String?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme)
            ?? VoiceTokens.resolve(voice: .terminal, dark: scheme == .dark)
    }

    var body: some View {
        Button {
            popoverShown.toggle()
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(books.count > 1 ? tokens.accent : tokens.muted)
        }
        .buttonStyle(.borderless)
        .help("Which books hold this post — and the door to diverge a copy")
        .popover(isPresented: $popoverShown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                if books.isEmpty {
                    Text("This post is in no book — it lives in the Pool.")
                        .font(.callout)
                } else {
                    Text("This post appears in \(books.count) book\(books.count == 1 ? "" : "s"):")
                        .font(.callout.weight(.semibold))
                    ForEach(books, id: \.id) { book in
                        Button(book.name) {
                            popoverShown = false
                            onOpenBook?(book.id)
                        }
                        .buttonStyle(.link)
                    }
                }
                Divider()
                Text("Editing here edits the post everywhere it appears. To make this a separate post that can diverge:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 260, alignment: .leading)
                Button("Duplicate as Version") {
                    duplicate()
                }
                if let status {
                    Text(status).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(12)
        }
        .task(id: postID) { await refresh() }
        .onChange(of: popoverShown) { _, shown in
            if shown { Task { await refresh() } }
        }
    }

    private var label: String {
        switch books.count {
        case 0: "in no book"
        case 1: "in \(books[0].name)"
        default: "in \(books.count) books"
        }
    }

    private func refresh() async {
        books = (try? await session.database.read { [postID] db in
            try Queries.readingsContaining(db, postID: postID)
        }) ?? []
    }

    private func duplicate() {
        Task {
            do {
                _ = try await session.runner.run { [postID] ops in
                    try ops.duplicateAsVersion(postID)
                }
                status = "Duplicated — the copy is in the Pool until you shelve it."
            } catch {
                status = "Refused: \(error)"
            }
        }
    }
}
