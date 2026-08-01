//
//  FolderView.swift
//  Variorum
//
//  The folder view (Phase 10 Step 5 — AppSpec §12): posts tagged at or
//  under one tag, the tag-subtree traversal rendered (Phase 4's
//  `taggedPostItems` — archived posts appear because tag lookups still
//  find them; that is the ratified reading, not this view's choice). Item
//  affordance: open-in-editor only (interpretation 2, PROVISIONAL —
//  previews are Phase 13 material). Functional, unstyled.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class FolderViewModel {
    @ObservationIgnored private let session: AppSession
    let tagID: String

    /// The bounded window (the library's 200 — review round 1, MINOR 3);
    /// +1 probe so the marker never false-positives (round 2 NIT).
    static let window = 200

    private(set) var posts: [Queries.TimelineItem] = []
    private(set) var tagPath: String?
    private(set) var lastError: String?
    private(set) var truncated = false

    init(session: AppSession, tagID: String) {
        self.session = session
        self.tagID = tagID
    }

    func start() async {
        do {
            tagPath = try await session.database.read { [tagID] db in
                try Queries.allTags(db).first { $0.id == tagID }?.path
            }
            // Bounded like the library (review round 1): the folder
            // listing is corpus-shaped; the standing fetch stays viewport-shaped.
            for try await value in session.database.observeTaggedPosts(
                tagID, limit: Self.window + 1
            ) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Verbatim adoption up to the window; the +1 probe row becomes the
    /// truncation marker (round 2 NIT: never a silent cut, the book-view
    /// parity).
    func adopt(_ new: [Queries.TimelineItem]) {
        truncated = new.count > Self.window
        posts = truncated ? Array(new.prefix(Self.window)) : new
    }
}

struct FolderView: View {
    let session: AppSession
    let tagID: String
    /// Open-in-editor only (interpretation 2, PROVISIONAL).
    var openPost: (String) -> Void
    @State private var model: FolderViewModel

    init(session: AppSession, tagID: String, openPost: @escaping (String) -> Void) {
        self.session = session
        self.tagID = tagID
        self.openPost = openPost
        _model = State(initialValue: FolderViewModel(session: session, tagID: tagID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(model.tagPath.map { "Tagged “\($0)” (and below)" } ?? "Folder")
                .font(.headline)
                .padding(8)
            if model.posts.isEmpty {
                Text("No notes carry this tag yet.")
                    .foregroundStyle(.secondary)
                    .padding(8)
                Spacer()
            } else {
                List {
                    ForEach(model.posts, id: \.postID) { item in
                        Button {
                            openPost(item.postID)
                        } label: {
                            HStack {
                                Text(item.displayTitle)
                                if let date = item.entryDate {
                                    Text(date).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    if model.truncated {
                        Text("Showing the \(FolderViewModel.window) most recently touched notes with this tag — older ones aren't listed.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.start() }
    }
}
