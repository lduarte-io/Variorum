//
//  LibraryViewModel.swift
//  Variorum
//
//  Minimal library sidebar model (Phase 7 Step 1): a bounded live listing
//  plus post creation. Chrome only — no business rules; the operations layer
//  enforces everything.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@Observable
@MainActor
final class LibraryViewModel {
    private let session: AppSession

    private(set) var posts: [Queries.TimelineItem] = []
    private(set) var lastError: String?

    /// Bounded on purpose: a held observation's fetch must be viewport-shaped
    /// (P1) — `observeLibrary` requires a limit for exactly this reason.
    private let listingLimit = 200

    init(session: AppSession) {
        self.session = session
    }

    /// Runs for the view's lifetime (`.task`); fetches happen on GRDB's
    /// reader queues (P2), only the assignment lands back here.
    func start() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: listingLimit
            ) {
                posts = items
            }
        } catch is CancellationError {
            // View went away; nothing to do.
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Creates a post and returns its id so the view can select it.
    func createPost() async -> String? {
        do {
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "Untitled")
            }
            return post.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// Renames a post (9d — `renameContainer`'s first UI face; the op
    /// shipped in Phase 2). A blank title stores NULL, rendering "Untitled".
    func rename(postID: String, title: String) async {
        do {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            try await session.runner.run { ops in
                try ops.renameContainer(postID, title: trimmed.isEmpty ? nil : trimmed)
            }
        } catch {
            lastError = String(describing: error)
        }
    }
}
