//
//  MobileArchiveModel.swift
//  VariorumMobile
//
//  **THE ARCHIVE ROOM'S MODEL** (round 2, batch 6c — the Two-rooms IA, her
//  QUESTIONS #84 ruling). Batch 4's archived listing, moved WHOLE out of
//  `MobileTrashModel` and given its own room.
//
//  **Why a second model and not a second `.task` on one** — *"nothing
//  shared"* is the ruling's own last clause, and the two rooms exist because
//  a countdown and a kept-forever list must never be read as one thing. A
//  model holding both keeps a shared error slot and a shared receipt slot,
//  so an act in one room could speak in the other; and the two listings'
//  windows would be one object's business when they are two rooms' P1
//  discipline. The split costs one small file and removes a whole class of
//  crossing.
//
//  **Everything else moved unchanged:** the core's own
//  `observeArchivedPosts` wrapper (never a rolled `observe { … }` — §49's
//  MINOR), the window+probe bound (P1, the Phase 10 discipline), the two
//  message slots kept apart so a landed act is never rendered in the red
//  one, and the ONE deletion-refusal home (A1-18).
//
//  **NO PURGE DOOR LIVES HERE, and that is structural rather than
//  remembered:** this model has no `requestPurge` road at all. Her round-3
//  rider — Delete Now and Empty Trash live in TRASH SURFACES only — is
//  therefore true of the Archive room by construction, which is the strongest
//  form of that promise short of the pin that also asserts it.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileArchiveModel {
    @ObservationIgnored private let session: AppSession
    /// Bounded on purpose (P1), the Trash room's twin: phone-scale, read on
    /// a 393 pt column.
    @ObservationIgnored private let window: Int

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var truncated = false
    private(set) var lastError: String?
    /// A landed act's own words — kept apart from `lastError` so a success
    /// is never rendered in the red slot.
    private(set) var receipt: String?

    init(session: AppSession, window: Int = 200) {
        self.session = session
        self.window = window
    }

    /// **Through the CORE's own wrapper**, not a rolled `observe { … }` over
    /// the same query (§49's MINOR). `observeArchivedPosts` exists beside
    /// `observeLibrary` and `observeTrash`, and rolling this one by hand
    /// would make one of three sibling reads take a different road for no
    /// reason.
    func start() async {
        do {
            let limit = window + 1
            for try await value in session.database.observeArchivedPosts(limit: limit) {
                (archived, truncated) = TrashListing.windowed(value, window: window)
            }
        } catch is CancellationError {
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// Un-archive a note — this room's ONE act. Archive has no clock, so
    /// this is a plain state flip and says so.
    func unarchive(_ item: Queries.TimelineItem) async {
        lastError = nil
        receipt = nil
        do {
            try await session.runner.run { ops in
                try ops.unarchiveContainer(item.postID)
            }
            receipt = Self.unarchivedReceipt
        } catch let error as OperationError {
            lastError = Self.refusal(error)
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    // MARK: - Words (phone voice over the shared vocabulary)

    /// Moved with the act, byte-identical to what batch 4 shipped.
    static let unarchivedReceipt = "Unarchived — it's back in the library."

    /// **Forwards to the ONE deletion-refusal home** (A1-18) — the same
    /// forward `MobileTrashModel` keeps, so the two rooms cannot word one
    /// refusal two ways.
    static func refusal(_ error: OperationError) -> String {
        DeletionRefusal.words(error, act: .putBack)
    }
}
