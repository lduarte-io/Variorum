//
//  MobileTrashModel.swift
//  VariorumMobile
//
//  **THE PHONE'S RECOVERY SURFACE** (round 2, batch 4 — PR2). Until this
//  batch nothing the phone deleted could ever come back on the phone: a
//  grep of `VariorumMobile/` for the whole 13j vocabulary — `TrashWindow`,
//  `Queries.trash`, `restoreBlock`, `restoreVariant`, `requestPurge` —
//  returned ZERO hits. The brains were all inherited and none of them had
//  a door.
//
//  **TWO SECTIONS, NEVER ONE LIST** (the inventory's correction, and her
//  round-3 ruling before it): the **Trash** is deleted things on the
//  30-day clock; **Archived** is kept-forever with no clock at all.
//  Conflating them would make archive read as a deletion, which is the one
//  thing the two states must never do to each other.
//
//  Everything here composes existing core reads and ops — `Queries.trash`
//  (filtered and sorted IN SQL, per-arm limited), `Queries.archivedPosts`,
//  the five put-back roads, `Operations.requestPurge`, the local sweep.
//  The words are `RecoveryCopy`'s, shared with the Mac since this batch.
//
//  **The filter and the sort restart the observation** rather than sorting
//  in memory, because both are applied in SQL: a window applied before a
//  filter would window the wrong set (`observeReading`'s own lesson, and
//  the 13j ladder-B B4 tiebreak-coherence rule the core query documents).
//
//  **P1:** the listing is bounded + a probe row, the Phase 10 discipline,
//  and the surface is deliberately PUSHED rather than held open — the
//  Trash's stranded-originals arm walks lineage families, which is exactly
//  why the Mac treats it as a summoned surface and not a per-keystroke one.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileTrashModel {
    @ObservationIgnored private let session: AppSession
    /// Bounded on purpose (P1). Phone-scale: the Mac holds 500, and this
    /// listing is read on a 393 pt column.
    @ObservationIgnored private let window: Int

    private(set) var trash: [Queries.TrashItem] = []
    private(set) var trashTruncated = false
    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var archivedTruncated = false
    private(set) var lastError: String?
    /// A landed act's own words — kept apart from `lastError` so a success
    /// is never rendered in the red slot.
    private(set) var receipt: String?

    /// nil = every kind (the standing default).
    private(set) var kindFilter: Queries.TrashItem.Kind?
    private(set) var oldestFirst = false
    /// Bumped whenever the query's SHAPE changes; the view's `.task(id:)`
    /// restarts the observation on it.
    private(set) var restartToken: UInt64 = 0

    init(session: AppSession, window: Int = 200) {
        self.session = session
        self.window = window
    }

    // MARK: - Ways of looking (nothing is written)

    func setKindFilter(_ kind: Queries.TrashItem.Kind?) {
        guard kind != kindFilter else { return }
        kindFilter = kind
        restartToken &+= 1
    }

    func setOldestFirst(_ oldest: Bool) {
        guard oldest != oldestFirst else { return }
        oldestFirst = oldest
        restartToken &+= 1
    }

    // MARK: - The two listings

    func startTrash() async {
        let kinds: Set<Queries.TrashItem.Kind> = kindFilter.map { [$0] }
            ?? Set(Queries.TrashItem.Kind.allCases)
        do {
            for try await value in session.database.observeTrash(
                now: session.now, kinds: kinds, oldestFirst: oldestFirst,
                limit: window + 1
            ) {
                (trash, trashTruncated) = TrashListing.windowed(value, window: window)
            }
        } catch is CancellationError {
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// **Through the CORE's own wrapper**, not a rolled `observe { … }` over
    /// the same query (§49's MINOR). `observeArchivedPosts` exists beside
    /// `observeLibrary` and `observeTrash`, which this model already uses —
    /// rolling the third by hand made one of three sibling reads take a
    /// different road for no reason, and a change to the core observation's
    /// shape would have reached two of them.
    func startArchived() async {
        do {
            let limit = window + 1
            for try await value in session.database.observeArchivedPosts(limit: limit) {
                (archived, archivedTruncated) = TrashListing.windowed(
                    value, window: window)
            }
        } catch is CancellationError {
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// "N days left" for a row, against the SESSION's clock (the read-side
    /// clock every recovery query already takes — never a fresh `Date()`,
    /// so a test standing on day 29 and one standing on day 31 are both one
    /// line).
    func daysLeft(_ item: Queries.TrashItem) -> Int? {
        TrashWindow.daysLeft(item.deletedAt, now: session.now)
    }

    // MARK: - Put back (one verb, each kind's own road)

    /// **The act is the SHARED one** (`TrashPutBack` — batch 4.5b's hoist of
    /// §49's named drift). This model keeps only the phone's face on it: the
    /// two slots (receipt vs the red one) and the phone's refusal voice.
    func putBack(_ item: Queries.TrashItem) async {
        lastError = nil
        receipt = nil
        do {
            receipt = try await TrashPutBack.run(session: session, item: item)
        } catch let error as OperationError {
            lastError = Self.refusal(error)
        } catch {
            // Includes `RecoveryRefusal` — nothing was attempted, so it is a
            // refusal and never the `putBackUnplaced` RECEIPT the shipped
            // code put in the red slot (§49's MINOR).
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// Un-archive a note — the Archived section's one act. Archive has no
    /// clock, so this is a plain state flip and says so.
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

    // MARK: - True delete (IN-TRASH ONLY, confirm every time)

    /// What the surface is asking her to confirm. **The type is the SHARED
    /// one now** (13l Act 2's hoist — `TrashPurge.Confirm`, which took this
    /// copy's two extra members with it); the alias keeps this batch's pins
    /// riding unmodified, the 3C parity pattern.
    typealias PurgeConfirm = TrashPurge.Confirm

    private(set) var pendingConfirm: PurgeConfirm?

    /// The alert host's binding.
    ///
    /// **THE RULE, and it names the property that matters rather than a
    /// shape** (batch 4.5b, the confirm BLOCKER): *a binding setter must
    /// never clear state that an action's continuation will read back.*
    ///
    /// SwiftUI's contract is that tapping an alert action sets `isPresented`
    /// to `false` — synchronously, inside tap handling — while an action's
    /// `Task { … }` cannot resume until that handling yields. So a confirm
    /// that opened `guard let confirm = pendingConfirm else { return }`
    /// guarded on state this setter had already cleared: **the door
    /// presented, she tapped Delete Now, and nothing was purged.**
    ///
    /// The rule this round had been citing — *never a computed
    /// `Binding(get:set:)` over an `@Observable` property* — names a SYNTAX,
    /// and this site obeyed it to the letter (`@Bindable`-projected, the
    /// getter read in `body`) and was dead anyway. The fix is therefore not
    /// a different binding shape: **the act's value rides into the action
    /// closure** (`alert(_:isPresented:presenting:)`) and
    /// `confirmPendingPurge(_:)` takes it as a parameter, so there is no
    /// read-back left for any setter to beat.
    var purgeConfirmPresented: Bool {
        get { pendingConfirm != nil }
        set { if !newValue { pendingConfirm = nil } }
    }

    /// The per-row door: raises the confirm — never acts directly. The
    /// original-rides-its-family belt (her round-8b ruling) is the shared
    /// rule's.
    func requestDeleteNow(_ item: Queries.TrashItem) {
        guard let confirm = TrashPurge.deleteNowConfirm(for: item) else { return }
        pendingConfirm = confirm
    }

    /// The bulk door: reads the UNWINDOWED counts AT ASK TIME (the listing
    /// is windowed; "everything, always" means everything), then raises the
    /// confirm with the full count by kind.
    func requestEmptyTrash() async {
        lastError = nil
        receipt = nil
        do {
            guard let confirm = try await TrashPurge.emptyTrashConfirm(session: session)
            else {
                receipt = RecoveryCopy.emptyTrashConfirm([:])
                return
            }
            pendingConfirm = confirm
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    func cancelPendingPurge() {
        pendingConfirm = nil
    }

    /// The confirmed act: ONE op (`requestPurge` — the intent write; rows
    /// leave every surface at once through the read-side fence), and the
    /// receipt tells the truth about the NOW/janitor split.
    ///
    /// **The confirm is PASSED IN, never read back** — see the rule at
    /// `purgeConfirmPresented`. The alert's action closure carries it in
    /// (`presenting:`), so this method cannot be beaten by the dismissal.
    func confirmPendingPurge(_ confirm: PurgeConfirm) async {
        pendingConfirm = nil
        lastError = nil
        receipt = nil
        do {
            receipt = try await TrashPurge.confirm(session: session, confirm)
        } catch {
            // A PURGE refusal, never a put-back one — the seal's way out
            // differs by act, which is why `Act` is a parameter (A1-18).
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    // MARK: - Words (phone voice over the shared vocabulary)

    static let unarchivedReceipt = "Unarchived — it's back in the library."

    /// **Forwards to the shared home** — hoisted at 4.5b so the Mac cannot
    /// keep answering *"where did it go?"* differently. Kept as a forward so
    /// this batch's pins ride unmodified (the 3C parity pattern).
    nonisolated static func landingReceipt(
        _ landing: Operations.BlockRestoreLanding
    ) -> String {
        RecoveryCopy.landingReceipt(landing)
    }

    static func putBackReceipt(_ kind: Queries.TrashItem.Kind) -> String {
        RecoveryCopy.putBackReceipt(kind)
    }

    /// **Forwards to the ONE deletion-refusal home** (A1-18): the seal said
    /// as a diagnosis with the way out (the J8 doctrine), and everything else
    /// in the shared table rather than a fourth private copy of it.
    static func refusal(_ error: OperationError) -> String {
        DeletionRefusal.words(error, act: .putBack)
    }
}
