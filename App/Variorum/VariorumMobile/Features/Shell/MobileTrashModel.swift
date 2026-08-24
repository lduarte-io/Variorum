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
                trashTruncated = value.count > window
                trash = trashTruncated ? Array(value.prefix(window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
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
                archivedTruncated = value.count > window
                archived = archivedTruncated ? Array(value.prefix(window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
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

    /// What the surface is asking her to confirm. Delete Now asks EVERY
    /// time (her round-10 ruling — there is no don't-ask state anywhere in
    /// the code and none may be added); Empty Trash asks once, naming the
    /// full count by kind (round 8).
    enum PurgeConfirm: Equatable {
        case deleteNow(Queries.TrashItem)
        case emptyTrash(counts: [Queries.TrashItem.Kind: Int])

        var title: String {
            switch self {
            case .deleteNow:
                return RecoveryCopy.deleteNowVerb
            case .emptyTrash:
                return RecoveryCopy.emptyTrashVerb
            }
        }

        /// The confirm BUTTON's word, per act — the bulk door must not say
        /// "Delete Now" over a question about emptying the whole Trash
        /// (caught in the visual capture).
        var confirmVerb: String {
            switch self {
            case .deleteNow: return RecoveryCopy.deleteNowVerb
            case .emptyTrash: return "Empty Trash"
            }
        }

        var message: String {
            switch self {
            case .deleteNow(let item):
                return RecoveryCopy.deleteNowConfirm(item.kind)
            case .emptyTrash(let counts):
                return RecoveryCopy.emptyTrashConfirm(counts)
            }
        }
    }

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

    /// The per-row door: raises the confirm — never acts directly.
    func requestDeleteNow(_ item: Queries.TrashItem) {
        // A preserved original has no purge door of its own — it rides its
        // family (her round-8b ruling). The row renders none, so this is a
        // belt, not a face.
        guard item.kind != .preservedOriginal else { return }
        pendingConfirm = .deleteNow(item)
    }

    /// The bulk door: reads the UNWINDOWED counts AT ASK TIME (the listing
    /// is windowed; "everything, always" means everything), then raises the
    /// confirm with the full count by kind.
    func requestEmptyTrash() async {
        lastError = nil
        receipt = nil
        do {
            let now = session.now
            let everything = try await session.database.read { db in
                try Queries.trash(db, now: now)
            }
            var counts: [Queries.TrashItem.Kind: Int] = [:]
            for item in everything { counts[item.kind, default: 0] += 1 }
            if counts.filter({ $0.key != .preservedOriginal }).values.reduce(0, +) == 0 {
                receipt = RecoveryCopy.emptyTrashConfirm([:])
                return
            }
            pendingConfirm = .emptyTrash(counts: counts)
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
            let synced = session.syncConfigured()
            switch confirm {
            case .deleteNow(let item):
                let target = SyncPurgeTarget(table: item.kind.purgeTable, rowID: item.id)
                // The third population (signed OUT, with synced history):
                // read the family's truth bit BEFORE the intent lands, so
                // the local wording never claims a cleanup `LocalPurge`
                // will defer forever.
                var familySynced = false
                if !synced {
                    familySynced = try await session.database.read { db in
                        try PurgeJanitor.anyFamilyEverSynced(db, targets: [target])
                    }
                }
                try await session.runner.run { ops in
                    _ = try ops.requestPurge([target])
                }
                receipt = RecoveryCopy.deleteNowReceipt(
                    item.kind, synced: synced, familyEverSynced: familySynced)
            case .emptyTrash:
                // Re-read at ACT time (a confirm is a pause; the listing is
                // a projection — the R3-1 lesson): everything currently in
                // the Trash, unwindowed, minted in one transaction.
                let now = session.now
                let everything = try await session.database.read { db in
                    try Queries.trash(db, now: now)
                }
                let targets = everything
                    .filter { $0.kind != .preservedOriginal }
                    .map { SyncPurgeTarget(table: $0.kind.purgeTable, rowID: $0.id) }
                var anyFamilySynced = false
                if !synced {
                    anyFamilySynced = try await session.database.read { db in
                        try PurgeJanitor.anyFamilyEverSynced(db, targets: targets)
                    }
                }
                try await session.runner.run { ops in
                    _ = try ops.requestPurge(targets)
                }
                receipt = RecoveryCopy.emptyTrashReceipt(
                    targets.count, synced: synced, anyFamilyEverSynced: anyFamilySynced)
            }
            // On a local-only install the cleanup IS the app's — run it now,
            // so Delete Now means what it says the moment she reads it (a
            // configured chain's janitor owns the road instead).
            await session.sweepLocalPurge()
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
