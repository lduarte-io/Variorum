//
//  RecoveryActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE DELETION STORY'S ACTS — ONE DECISION LAYER, BOTH RECOVERY
//  SURFACES** (13l Act 2, ledger item 4; it finishes what mobile round 2's
//  batch 4.5b deliberately stopped at half).
//
//  The half that shipped: `TrashPutBack`, hoisted because the two surfaces
//  had ALREADY drifted on it — the phone read `restoreBlock`'s landing and
//  said where the block went while the Mac discarded it and landed
//  silently. The half that did not: `PurgeConfirm`, `requestDeleteNow`,
//  `requestEmptyTrash`, `confirmPendingPurge` and the listing windows were
//  left as a near-verbatim copy in `MobileTrashModel`, reported honestly as
//  half rather than claimed as a layer, because finishing it refactors a
//  Mac view model and 13l opens on exactly that surface. This is that
//  finish, and 13l's own first item is the evidence for why it mattered:
//  the confirm→act edge was broken in FIVE hosts across the two apps, and
//  each was found separately.
//
//  **What is shared and what is not.** The DECISION is shared — which rows
//  a purge covers, which receipt population is true, when the local sweep
//  runs, how a windowed listing decides it was truncated. The VOICE is not:
//  refusals throw, and each platform words them (the Mac's `TrayRefusalCopy`
//  for put-back, the shared `DeletionRefusal` elsewhere). The STATE is not
//  either: each model keeps its own observable properties, which is why this
//  is a set of `@MainActor` statics over `AppSession` rather than a base
//  class — the shape `TrashPutBack` established.
//
//  **A1-NIT-2 (13l Act 1's cold review):** these compositions used to live
//  in `RecoveryCopy.swift`, a `…Copy` file carrying two `@MainActor` act
//  compositions beside the sentences. Its disposition said they split out
//  "when that item grows the decision layer" — which is this item, so they
//  did. `RecoveryCopy.swift` is sentences again.
//

import Foundation
import VariorumCore

/// A recovery refusal that is not an `OperationError` — nothing was even
/// attempted, so no operation ran to refuse it.
enum RecoveryRefusal: Error {
    /// A preserved original with no note recorded: placing needs somewhere
    /// to place, and there is none.
    case originalHasNoNote

    var sentence: String {
        switch self {
        case .originalHasNoNote: return RecoveryCopy.originalHasNoNote
        }
    }
}

/// **PUT BACK — ONE DECISION, BOTH RECOVERY SURFACES** (batch 4.5b, §49's
/// MAJOR: *`MobileTrashModel` is a near-verbatim copy of `RecoveryViewModel`
/// and it is already drifting on day one*).
///
/// The drift the finding named was exactly here. Both surfaces ran the same
/// five-road switch, but the phone read `restoreBlock`'s LANDING and said
/// where the block went, while the Mac wrote `_ = try ops.restoreBlock(…)`
/// and threw the answer away — so its Put back landed **silently**, and the
/// two recovery surfaces already answered *"where did it go?"* two different
/// ways in the same week. A shared vocabulary of sentences could not prevent
/// that, because the divergence was in the DECISION about which sentence to
/// say, one layer under the words batch 4 hoisted.
///
/// It is a HOIST, not a byte-copy: `MobileTrashModel.landingReceipt` and
/// `.putBackReceipt` stay as forwards so the phone's pins ride unmodified
/// (the 3C pattern), and the Mac adopts this road rather than keeping its
/// own.
///
/// Refusals THROW — `OperationError` for anything an operation refused, and
/// `RecoveryRefusal` for the one case where nothing was attempted — so each
/// platform keeps its own voice for wording them, which is a face, not a
/// decision.
///
/// **The take case discarded its answer too** (13l Act 1, A1-MAJOR-1). The
/// hoist above fixed the BLOCK half and left the same shape one line down:
/// `case .take: _ = try ops.restoreVariant(item.id)`, falling to the generic
/// receipt. `restoreVariant` reports the revived take's STATUS for the same
/// reason `restoreBlock` reports its landing, and the same drift followed —
/// an archived take was told to her as *"Take put back."* while it landed in
/// the archived listing. So the road now carries EVERY op's own answer out of
/// the write, and the words are chosen after it, from one place.
@MainActor
enum TrashPutBack {
    /// **What the act ANSWERED.** The ops that report where a thing went say
    /// so here; the ones that have nothing of their own to report say `plain`.
    /// Keeping this out of the write body is deliberate: the transaction picks
    /// no words, and adding a kind that answers something forces a case here
    /// rather than allowing a silent fall-through to the generic sentence —
    /// which is exactly how both halves of this drift happened.
    nonisolated enum Outcome: Equatable, Sendable {
        /// `restoreBlock` names WHERE the block went (its old place, the end
        /// of its note, or unplaced).
        case block(Operations.BlockRestoreLanding)
        /// `restoreVariant` names WHAT came back — active into the fan,
        /// archived into the archived listing (the exact flip, #68(b)).
        case take(VariantStatus)
        /// The op reports no landing of its own.
        case plain
    }

    /// Puts one Trash row back; returns the RECEIPT to show.
    static func run(session: AppSession, item: Queries.TrashItem) async throws -> String {
        // A preserved original was never DELETED — putting it back means
        // PLACING it, which is the shared composition's job (it re-reads its
        // landing at act time, because a listing is a projection).
        if item.kind == .preservedOriginal {
            guard let noteID = item.noteID else { throw RecoveryRefusal.originalHasNoNote }
            return try await PreservedOriginPutBack.run(
                session: session, postID: noteID, blockID: item.id)
        }
        let outcome = try await session.runner.run { ops -> Outcome in
            switch item.kind {
            case .note:
                try ops.restoreContainer(item.id)
                return .plain
            case .book:
                try ops.restoreReading(item.id)
                return .plain
            case .block:
                return .block(try ops.restoreBlock(item.id))
            case .take:
                return .take(try ops.restoreVariant(item.id))
            case .preservedOriginal:
                return .plain  // handled above
            }
        }
        switch outcome {
        case .block(let landing): return RecoveryCopy.landingReceipt(landing)
        case .take(let status): return RecoveryCopy.takeRestoredReceipt(status)
        case .plain: return RecoveryCopy.putBackReceipt(item.kind)
        }
    }
}

/// **THE DELETION STORY'S REFUSALS, IN ONE HOME** (batch 4.5b — A1-18).
///
/// Batch 4's stated purpose was one home for the deletion vocabulary, and it
/// hoisted the sentences above. The REFUSALS stayed behind in three separate
/// mappings — `MobileEditorViewModel.deleteNoteRefusal`,
/// `MobileTrashModel.refusal`, `MobileBookDetailsModel.refusal` (which the
/// shelf's delete door borrowed) — each covering a *different subset* of
/// `OperationError` and each falling back to a bare `String(describing:)`.
/// So one refused act read three ways depending on which door she used, and
/// any case none of the three had thought of reached her as a raw enum dump.
///
/// This is that home. Two rules it keeps:
///
/// - **The ACT decides the sentence, not just the error.** A sealed note
///   refusing a *put back* and a sealed note refusing a *delete* are the same
///   `OperationError` and want different words, so `Act` is a parameter
///   rather than three functions with three overlapping tables.
/// - **The fallback is a SENTENCE that still carries the technical name.**
///   Never a bare dump (she should not read `lockedVariant` alone), and never
///   a swallow either — a case arriving here is the signal to name it above.
///   It deliberately claims nothing about what did or did not change: some
///   callers are compositions, not single transactions.
nonisolated enum DeletionRefusal {
    /// Which door is speaking. The error is the same; the way out differs.
    enum Act {
        case delete
        case putBack
    }

    static func words(_ error: Error, act: Act = .delete) -> String {
        if let refusal = error as? RecoveryRefusal { return refusal.sentence }
        guard let error = error as? OperationError else { return fallback(error) }
        switch error {
        case .lockedPost:
            return act == .putBack
                ? RecoveryCopy.sealedPutBackRefusal
                : "This note is marked complete — unseal it first."
        case .lockedReading:
            return "This book is finished — reopen it first."
        case .containerNotFound:
            return "That note is already gone."
        case .readingNotFound:
            return "That book is already gone."
        case .blockNotFound:
            return "That block is already gone."
        case .variantNotFound:
            return "That take is already gone."
        // **The "already BACK" family** (13l Act 1, A1-NIT-1): the mirror of
        // the four above, and the ordinary double-click-Put-back race — she
        // presses twice, the first restore lands, the second meets a row
        // that is no longer deleted. Foreseeable and harmless, and it was
        // falling to the technical-name fallback.
        case .containerNotDeleted:
            return "That note is already back."
        case .readingNotDeleted:
            return "That book is already back."
        case .blockNotDeleted:
            return "That block is already back."
        case .variantNotDeleted:
            return "That take is already back."
        // A purge target that is no longer in the Trash — the same race one
        // act over (Delete Now pressed after a Put back landed). Only the
        // Trash can purge, so the sentence names that rule.
        case .purgeTargetNotDeleted:
            return "That's not in the \(RecoveryCopy.trashSection) any more — "
                + "only things in the \(RecoveryCopy.trashSection) can be deleted for good."
        default:
            return fallback(error)
        }
    }

    /// The last resort — a sentence, with the name kept.
    static func fallback(_ error: Error) -> String {
        if let refusal = error as? RecoveryRefusal { return refusal.sentence }
        return "That couldn't be done — \(String(describing: error))."
    }
}


/// **The preserved original's PUT BACK, in ONE place** (13j batch 3; hoisted
/// cross-platform at round 2 batch 4): the Mac tray's originals section, the
/// J3 peek, and the phone's Trash are three doors onto one act, and a second
/// copy of the composition is a second place for the landing rule to drift.
///
/// It is a face-level composition over `placeBlock` — the W-reversibility
/// primitive, exactly as the ceremony's "reversible by re-pointing at A"
/// promises — and NO operation's semantics change for it.
///
/// Putting a preserved original back is PLACING it, not flipping a tombstone.
/// The landing is re-read HERE, at act time, rather than taken from a
/// listing: a listing is a projection, and an argument read from a projection
/// is read from a snapshot (13c R3-1's lesson, applied at the only place it
/// can bite — the successor could have moved or gone since the panel last
/// rendered). The recorded corner is unchanged: if it moves in the
/// sub-millisecond window between this read and the write, `placeBlock`
/// refuses by name and she retries.
@MainActor
enum PreservedOriginPutBack {
    /// Returns the receipt; refusals throw for the caller to word.
    static func run(
        session: AppSession, postID: String, blockID: String
    ) async throws -> String {
        // 13l row 26: the home's KIND rides the same read the landing does —
        // the "at the end" sentence names what it landed IN, and a scraps
        // area is not a note. `.post` is the fallback only where the row has
        // vanished between the listing and the act, which is the corner
        // `placeBlock` refuses by name one line later anyway.
        let (landing, home) = try await session.database.read {
            db -> (String?, ContainerKind) in
            (try Queries.preservedOriginals(db, postID: postID)
                .first { $0.blockID == blockID }?.landAfterBlockID,
             try Queries.containerHeader(db, containerID: postID)?.kind ?? .post)
        }
        let insert: Operations.InsertPosition = landing.map { .after($0) } ?? .end
        try await session.runner.run { ops in
            _ = try ops.placeBlock(blockID, in: postID, at: insert)
        }
        return landing == nil ? RecoveryCopy.putBackAtEnd(home) : RecoveryCopy.putBackBeside
    }
}

/// **TRUE DELETE — ONE DECISION, BOTH RECOVERY SURFACES** (13l Act 2,
/// ledger item 4 — the half batch 4.5b left, named in 13l's manifest as
/// *"still a near-verbatim copy … `PurgeConfirm`, `requestDeleteNow`,
/// `requestEmptyTrash`, `confirmPendingPurge` (identical including the
/// synced/familySynced reads and `sweepLocalPurge`)"*).
///
/// Everything here is a RULE about the store, which is why neither platform
/// may own it alone:
///
/// - **what a purge covers** — everything currently in the Trash, re-read at
///   ACT time because a confirm is a pause and a listing is a projection
///   (13c's R3-1 lesson), minus preserved originals, which ride their family
///   (her round-8b ruling) and have no door of their own;
/// - **which receipt is TRUE** — the three populations 13j ladder B and its
///   round 2 established (synced · never-synced · signed-out-with-synced-
///   history), read BEFORE the intent lands because the intent write changes
///   no seq rows;
/// - **when the local sweep runs** — on a local-only install the cleanup IS
///   the app's, so Delete Now means what it says the moment she reads it
///   (her round-11 ruling).
///
/// Each surface keeps its own observable state, its own alert host, and its
/// own refusal voice. **Refusals THROW**, exactly as `TrashPutBack` does.
@MainActor
enum TrashPurge {
    /// What the surface is asking her to confirm. Delete Now asks EVERY
    /// time (her round-10 ruling — there is no don't-ask state anywhere in
    /// the code and none may be added); Empty Trash asks once, naming the
    /// full count by kind (round 8).
    ///
    /// **It is the ONE type now** (13l Act 2): both models nested an
    /// identical copy, and the phone's had grown two members the Mac's had
    /// not. Each model keeps a `typealias PurgeConfirm` so both suites ride
    /// unmodified — the 3C parity pattern.
    nonisolated enum Confirm: Equatable, Sendable {
        case deleteNow(Queries.TrashItem)
        case emptyTrash(counts: [Queries.TrashItem.Kind: Int])

        var title: String {
            switch self {
            case .deleteNow: return RecoveryCopy.deleteNowVerb
            case .emptyTrash: return RecoveryCopy.emptyTrashVerb
            }
        }

        /// The confirm BUTTON's word, per act — the bulk door must not say
        /// "Delete Now" over a question about emptying the whole Trash
        /// (caught in the phone's visual capture).
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

    /// The per-row door's rule: an original has no purge door of its own —
    /// it rides its family (her round-8b ruling). The row renders none, so
    /// this is the belt behind that face, on both platforms.
    nonisolated static func deleteNowConfirm(for item: Queries.TrashItem) -> Confirm? {
        item.kind == .preservedOriginal ? nil : .deleteNow(item)
    }

    /// The bulk door's ask-time read: the UNWINDOWED counts ("everything,
    /// always" means everything, and both listings are windowed), then the
    /// confirm with the full count by kind. `nil` = there is nothing to
    /// purge, and the caller says so quietly instead of confirming nothing.
    static func emptyTrashConfirm(session: AppSession) async throws -> Confirm? {
        let now = session.now
        let everything = try await session.database.read { db in
            try Queries.trash(db, now: now)
        }
        var counts: [Queries.TrashItem.Kind: Int] = [:]
        for item in everything { counts[item.kind, default: 0] += 1 }
        guard counts.filter({ $0.key != .preservedOriginal }).values.reduce(0, +) > 0
        else { return nil }
        return .emptyTrash(counts: counts)
    }

    /// The confirmed act: ONE op (`requestPurge` — the intent write; rows
    /// leave every surface at once through the read-side fence), then the
    /// local sweep, and the RECEIPT to show. Refusals throw.
    @discardableResult
    static func confirm(session: AppSession, _ confirm: Confirm) async throws -> String {
        let synced = session.syncConfigured()
        let receipt: String
        switch confirm {
        case .deleteNow(let item):
            let target = SyncPurgeTarget(table: item.kind.purgeTable, rowID: item.id)
            // The third population (signed OUT, with synced history): read
            // the family's truth bit BEFORE the intent lands, so the local
            // wording never claims a cleanup `LocalPurge` will defer forever.
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
            // Re-read at ACT time (a confirm is a pause; the listing is a
            // projection — the R3-1 lesson): everything currently in the
            // Trash, unwindowed, minted in one transaction.
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
        // On a local-only install the cleanup IS the app's — run it now, so
        // Delete Now means what it says the moment she reads it (a configured
        // chain's janitor owns the road instead).
        await session.sweepLocalPurge()
        return receipt
    }
}

/// **THE WINDOW'S +1 PROBE, IN ONE PLACE** (13l Act 2, ledger item 4).
///
/// Both recovery surfaces observe with `limit: window + 1` and then decide
/// truncation from the extra row — the Phase 10 bounded-listing discipline,
/// whose whole subtlety is that the probe row must be DROPPED before display
/// or the marker is right and the listing is one row too long. Two copies of
/// a rule whose bug would be silent is the drift class; here it is one.
nonisolated enum TrashListing {
    static func windowed<T>(_ value: [T], window: Int) -> (rows: [T], truncated: Bool) {
        value.count > window ? (Array(value.prefix(window)), true) : (value, false)
    }
}
