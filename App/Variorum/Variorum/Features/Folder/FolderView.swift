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

    private(set) var posts: [Queries.TimelineItem] = []
    private(set) var tagPath: String?
    private(set) var lastError: String?

    init(session: AppSession, tagID: String) {
        self.session = session
        self.tagID = tagID
    }

    func start() async {
        do {
            tagPath = try await session.database.read { [tagID] db in
                try Queries.allTags(db).first { $0.id == tagID }?.path
            }
            for try await value in session.database.observeTaggedPosts(tagID) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Verbatim adoption — the query's membership and order ARE the view's.
    func adopt(_ new: [Queries.TimelineItem]) {
        posts = new
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
                Text("No posts carry this tag yet.")
                    .foregroundStyle(.secondary)
                    .padding(8)
                Spacer()
            } else {
                List(model.posts, id: \.postID) { item in
                    Button {
                        openPost(item.postID)
                    } label: {
                        HStack {
                            Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                            if let date = item.entryDate {
                                Text(date).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
