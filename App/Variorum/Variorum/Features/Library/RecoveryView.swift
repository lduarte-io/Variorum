//
//  RecoveryView.swift
//  Variorum
//
//  The recovery surfaces (Phase 10 Step 8 — brief item 4): archived posts
//  (kept-out-of-view, one click back — the face the Phase 4 closeout
//  promised `unarchiveContainer`) and deleted posts (tombstones, one
//  `restoreContainer` away — the 2026-07-05 author decision's read side).
//  Functional, unstyled.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class RecoveryViewModel {
    @ObservationIgnored private let session: AppSession

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var deleted: [Queries.TimelineItem] = []
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    func startArchived() async {
        do {
            for try await value in session.database.observeArchivedPosts(limit: 500) {
                archived = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func startDeleted() async {
        do {
            for try await value in session.database.observeDeletedPosts(limit: 500) {
                deleted = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Internal so tests drive listings deterministically.
    func adopt(archived: [Queries.TimelineItem], deleted: [Queries.TimelineItem]) {
        self.archived = archived
        self.deleted = deleted
    }
}

struct RecoveryView: View {
    let session: AppSession
    let library: LibraryViewModel
    var openPost: (String) -> Void
    @State private var model: RecoveryViewModel

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    var body: some View {
        List {
            Section("Archived") {
                if model.archived.isEmpty {
                    Text("Nothing archived.").foregroundStyle(.secondary)
                }
                ForEach(model.archived, id: \.postID) { item in
                    HStack {
                        title(item)
                        Spacer()
                        Button("Open") { openPost(item.postID) }
                        Button("Unarchive") {
                            Task { await library.unarchive(postID: item.postID) }
                        }
                    }
                }
            }
            Section("Recently Deleted") {
                if model.deleted.isEmpty {
                    Text("Nothing deleted.").foregroundStyle(.secondary)
                }
                ForEach(model.deleted, id: \.postID) { item in
                    HStack {
                        title(item)
                        Text(item.stamp)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Button("Restore") {
                            Task { await library.restore(postID: item.postID) }
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.startArchived() }
        .task { await model.startDeleted() }
    }

    private func title(_ item: Queries.TimelineItem) -> some View {
        HStack(spacing: 6) {
            Text(item.title?.isEmpty == false ? item.title! : "Untitled")
            if let date = item.entryDate {
                Text(date).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
