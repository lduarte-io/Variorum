//
//  LibraryViewModel.swift
//  Variorum
//
//  The sidebar's model (Phase 7 Step 1; grown at Phase 10 Step 5): bounded
//  live listings — the flat library and the JOURNAL lens (the author's
//  binding 9c-sitting input: journal entries need an obvious dated home;
//  the profile is a UI lens over one container table, never a separate
//  model — CoreDescription pillar 8) — plus post creation and the
//  notebook-rule door (`createOrOpenJournalEntry`'s first Mac face).
//  Chrome only — no business rules; the operations layer enforces.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@Observable
@MainActor
final class LibraryViewModel {
    private let session: AppSession

    private(set) var posts: [Queries.TimelineItem] = []
    private(set) var journal: [Queries.TimelineItem] = []
    private(set) var lastError: String?

    /// Bounded on purpose: a held observation's fetch must be viewport-shaped
    /// (P1) — `observeLibrary` requires a limit for exactly this reason.
    private let listingLimit = 200
    private let journalLimit = 120

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

    /// The journal lens: entries by their user-set day, newest first —
    /// the dated home (strict semantics are the query's: journal-profile,
    /// live, non-archived).
    func startJournal() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: .entryDate, direction: .desc, limit: journalLimit,
                profile: .journal
            ) {
                journal = items
            }
        } catch is CancellationError {
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

    /// The notebook rule's Mac door: "today's entry" creates OR opens (the
    /// operations layer decides — one entry per calendar day). `day` is
    /// injectable for tests; the default is the local calendar date.
    func openJournalEntry(day: String? = nil) async -> String? {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        do {
            let result = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: entryDay)
            }
            return result.container.id
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

    // MARK: - Post lifecycle (Phase 10 Step 8 — brief item 4)

    /// Archive: kept, out of ambient view; the recovery surface lists it.
    func archive(postID: String) async {
        await run { ops in try ops.archiveContainer(postID) }
    }

    func unarchive(postID: String) async {
        await run { ops in try ops.unarchiveContainer(postID) }
    }

    /// Delete: a tombstone, recoverable via `restore` until GC (S2).
    func delete(postID: String) async {
        await run { ops in try ops.deleteContainer(postID) }
    }

    func restore(postID: String) async {
        await run { ops in try ops.restoreContainer(postID) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }
}
