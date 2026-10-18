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
    /// **A SUCCESS SAYS SO** (the post-13l polish round, ledger row 25 — the
    /// review pass's FOUND-ITEM 2). Kept apart from `lastError` for row 6's
    /// reason one surface over: a receipt rendered in the error slot reads as
    /// a failure. The only writers today are archive and unarchive, whose
    /// visible effect is that the note LEAVES the list she is looking at —
    /// the one shape that most needs a sentence.
    private(set) var receipt: String?

    /// **VX-384 (the VX-348 run, U4) — how many times the held listing's
    /// MEMBERSHIP has moved** since this listing started: a note came into
    /// the wing's newest window or left it (a mint, a duplicate, a delete, an
    /// archive, a revival — from any door, any pane, any window, the AI's or
    /// a sync apply). The Library's catalog — a ONE-SHOT `search()` answer —
    /// follows it (`LibraryCatalogModel.followListingMove`), which is VX-231's
    /// road one surface over: the held observation that already moves
    /// exactly when membership does, followed by its one-shot twin; no new
    /// signal. Typing never moves it (the same notes, re-ordered), so the
    /// follow runs at membership rate, never keystroke rate (P1).
    private(set) var listingMoves = 0
    /// The ids the last held delivery listed; nil before the first (which is
    /// the baseline — the catalog's own appearance read covers it).
    @ObservationIgnored private var heldIDs: Set<String>?

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
        // A (re)started listing — a wing switch — takes its own baseline.
        heldIDs = nil
        do {
            // 13i-d U5: the CURRENT WING's notes (§9 — a separate library);
            // the shell restarts this task when the wing switches.
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: listingLimit,
                wingID: session.wing.currentID
            ) {
                posts = items
                adoptHeldMembership(items)
            }
        } catch is CancellationError {
            // View went away; nothing to do.
        } catch {
            lastError = String(describing: error)
        }
    }

    /// One held delivery's membership, compared with the last (VX-384) — the
    /// observation's body, and the pins' seam.
    func adoptHeldMembership(_ items: [Queries.TimelineItem]) {
        let ids = Set(items.map(\.postID))
        if LibraryListingFollow.moved(previous: heldIDs, current: ids) { listingMoves += 1 }
        heldIDs = ids
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
        // 13i-d U5: a new note is born in the wing she is standing in.
        let wing = session.wing.currentID
        do {
            let post = try await session.runner.run { ops in
                // 13g batch 7 (R6-3): NO stored placeholder. A note with no name has
                // a NULL title, and `DisplayTitle` shows its date — a title she
                // never typed was never hers.
                try ops.createPost(title: nil, wingId: wing)
            }
            return post.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// The notebook rule's Mac door: "today's entry" creates OR opens (the
    /// operations layer decides — one entry per calendar day), and — Phase
    /// 13 B3, R50 — ensures the DAILY JOURNAL BOOK holds it (created +
    /// pinned + designated on first use; the journal lives on the shelf as
    /// ordinary membership). A finished/full daily book never wedges the
    /// door: the entry still opens and the NOTE speaks (round 2, MAJOR 2 —
    /// surfaced through `lastError`, the overlay that exists without an
    /// editor). `day` is injectable for tests.
    func openJournalEntry(day: String? = nil) async -> String? {
        do {
            let outcome = try await JournalBooks.openToday(session: session, day: day)
            lastError = outcome.note
            // 13i-e U2 (F-U1-6's ruling): the Journal came back — a RECEIPT on
            // the one status seam (quiet by default).
            if let receipt = outcome.receipt {
                session.status.receipt(receipt)
            }
            return outcome.postID
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

    /// Archive: kept, out of ambient view; the **Archived** sidebar surface
    /// lists it (the post-13l polish round, ledger row 8 — her B2 direction
    /// gave archive its own room).
    ///
    /// **It says where the note went** (ledger row 25): the act removes the
    /// row from the list she is standing in, and it had been doing that in
    /// silence — which on the Library's own rows reads exactly like a
    /// deletion. The sentence names the surface AND the absence of a clock,
    /// because that is the whole difference from the verb beside it.
    func archive(postID: String) async {
        await run(receipt: RecoveryCopy.archivedNoteReceipt) { ops in
            try ops.archiveContainer(postID)
        }
    }

    func unarchive(postID: String) async {
        await run(receipt: RecoveryCopy.unarchivedNoteReceipt) { ops in
            try ops.unarchiveContainer(postID)
        }
    }

    /// Delete: a tombstone, recoverable via `restore` until GC (S2).
    ///
    /// **13l Act 2 (item 3): it FORWARDS to `NoteDeletion` now, and that is
    /// the point rather than plumbing.** This method was the one road from a
    /// face to a container tombstone, and it did nothing but write it — no
    /// flush, so keystrokes inside the autosave debounce were tombstoned with
    /// the row they never reached; no signal, so every pane showing the note
    /// stayed mounted over it and the Open strip kept a row ⌘⇧n would
    /// re-open. Leaving it beside the new act would have left a SECOND road
    /// with none of that, which is the drift class exactly: the next door
    /// would find this one.
    ///
    /// The CONFIRM stays at the face, deliberately — it is a question asked of
    /// a person, and a view model is the wrong place for one (the Library's
    /// and the Pool's rows and both `note ▾` menus ask it through the one
    /// shared host).
    func delete(postID: String) async {
        do {
            _ = try await NoteDeletion.run(session: session, postIDs: [postID])
            lastError = nil
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    func restore(postID: String) async {
        await run { ops in try ops.restoreContainer(postID) }
    }

    // MARK: - Versions (Phase 11, A2 — door 1)

    /// "Mark as Versions" from the library — emits the SAME operation the
    /// side-by-side door emits (both doors, one op — pinned).
    func markAsVersions(_ postAID: String, _ postBID: String) async {
        await run { ops in _ = try ops.markPostsAsVersions(postAID, postBID) }
    }

    /// Sitting 9 (R60/R68): the mark's inverse, same door shape. Picking a
    /// pair that isn't linked speaks its refusal (fire-and-speak, never a
    /// silent no-op).
    func unmarkVersions(_ postAID: String, _ postBID: String) async {
        await run { ops in try ops.unmarkPostsAsVersions(postAID, postBID) }
    }

    /// Duplicate-as-version from anywhere (the spike's ruling: the post
    /// exactly as it is — unambiguous from any surface).
    ///
    /// 13e E10: through the copy family's ONE flush-first entry
    /// (`AppSession.runCopying`) — a row duplicated while its post is open
    /// and dirty must carry what she just typed. The library and pool rows
    /// can name a post that is not open at all; the flush is a no-op there.
    ///
    /// VX-372 (VX-383 U1 — D-C-2): the rows' two doors run the ONE act every
    /// duplicate door runs (`NoteDuplicate` — the same flush-first entry, her
    /// tag choice, the receipt saying where the copy landed with its Open ›,
    /// and a refusal in the app's words on the status centre, where this used
    /// to keep a raw error dump nothing rendered). With tags is the default.
    func duplicateAsVersion(postID: String, tags: Operations.DuplicateTags = .applied) async {
        lastError = nil
        await NoteDuplicate.perform(postID: postID, tags: tags, session: session)
    }

    /// `receipt` (ledger row 25) is what to SAY when the act lands. It is a
    /// parameter rather than something derived after the fact because only
    /// the caller knows which sentence its act earned; a nil one clears any
    /// previous receipt, so a later silent act never leaves an older one
    /// standing under it.
    private func run(
        receipt: String? = nil, _ body: @escaping @Sendable (Operations) throws -> Void
    ) async {
        do {
            try await session.runner.run(body)
            lastError = nil
            self.receipt = receipt
        } catch {
            self.receipt = nil
            lastError = String(describing: error)
        }
    }
}

/// **VX-384 — when the held listing's membership MOVED** (pure, pinned): a
/// delivery after the first whose set of notes differs from the last one's.
/// Order is not membership — typing re-orders the newest-first window and
/// moves nothing here.
nonisolated enum LibraryListingFollow {
    static func moved(previous: Set<String>?, current: Set<String>) -> Bool {
        guard let previous else { return false }
        return previous != current
    }
}
