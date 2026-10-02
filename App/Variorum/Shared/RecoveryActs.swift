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
        /// 13i-c U4 (§18.3): a book that went to the Trash WITH its notes
        /// comes back whole — the receipt counts them (read on the book's
        /// exact stamp BEFORE the put back clears it).
        case bookWhole(notes: Int)
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
        let database = session.database
        let outcome = try await session.runner.run { ops -> Outcome in
            switch item.kind {
            case .note:
                try ops.restoreContainer(item.id)
                return .plain
            // pre-13u Act 10 wave 2b (item 17): a snippet group is a
            // container, so its Put back is the note's own road — the
            // exact-stamp cascade revives its snippets with it.
            case .snippetGroup:
                try ops.restoreContainer(item.id)
                return .plain
            case .book:
                // 13i-c U4: how many notes went in WITH it — the count reads
                // the exact stamp, so it must be read before the stamp clears.
                let notes = try database.read { db in
                    try Queries.trashBookNoteCount(db, readingID: item.id)
                }
                try ops.restoreReading(item.id)
                return notes > 0 ? .bookWhole(notes: notes) : .plain
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
        case .bookWhole(let notes): return RecoveryCopy.bookPutBackWhole(item.title, notes: notes)
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
            // 13i-d U6 (KnownIssues row 106): no book in hand, so both true
            // roads — a SEALED book's is Unseal (Reopen refuses there).
            // Platform-neutral words: the phone speaks this arm too.
            return "This book is finished \u{2014} reopen it first; if it\u{2019}s sealed, unseal it."
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
        /// `savedVersions` is how many of THIS note's saved moments are in
        /// the Trash beside it (the ladder's LR1-4): the purge takes a
        /// container's own family and never another container, so they stay
        /// — and the door says so. Defaulted, so a block, a book, a take and
        /// every shipped pin construct it exactly as before.
        case deleteNow(Queries.TrashItem, savedVersions: Int = 0)
        /// `versions` is how many of the `.note` rows are somebody's saved
        /// moment (batch 6's rider): they ARE notes to the store and they DO
        /// go, so the total is unchanged — what changes is that the sentence
        /// names them, instead of counting a note's past as another note.
        case emptyTrash(counts: [Queries.TrashItem.Kind: Int], versions: Int)

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
            case .deleteNow(let item, let savedVersions):
                return RecoveryCopy.deleteNowConfirm(
                    item.kind, isVersion: item.isVersion, savedVersions: savedVersions)
            case .emptyTrash(let counts, let versions):
                return RecoveryCopy.emptyTrashConfirm(counts, versions: versions)
            }
        }
    }

    /// The per-row door's rule: an original has no purge door of its own —
    /// it rides its family (her round-8b ruling). The row renders none, so
    /// this is the belt behind that face, on both platforms.
    nonisolated static func deleteNowConfirm(
        for item: Queries.TrashItem, savedVersions: Int = 0
    ) -> Confirm? {
        item.kind == .preservedOriginal
            ? nil
            : .deleteNow(item, savedVersions: savedVersions)
    }

    /// The bulk door's ask-time read: the UNWINDOWED counts (both listings
    /// are windowed), then the confirm with the full count by kind. `nil` =
    /// there is nothing this door takes, and the caller says so quietly
    /// instead of confirming nothing.
    ///
    /// **It reads EVERY kind and then decides** (ledger row 21, her G6
    /// ruling): the takes are counted so the confirm can say honestly that
    /// they stay and that staying is not keeping, and `TrashScope` — not this
    /// read — is what decides which of them the door actually takes.
    static func emptyTrashConfirm(session: AppSession) async throws -> Confirm? {
        let now = session.now
        // 13i-d U5: the Trash a wing SHOWS is the Trash its door empties.
        let wing = session.wing.readScope
        let everything = try await session.database.read { db in
            try Queries.trash(db, now: now, wingID: wing)
        }
        var counts: [Queries.TrashItem.Kind: Int] = [:]
        for item in everything { counts[item.kind, default: 0] += 1 }
        guard counts.filter({ TrashScope.emptyTrashTakes($0.key) })
            .values.reduce(0, +) > 0
        else { return nil }
        // The moments among the notes (batch 6's rider) — the row itself knows,
        // through the `version_of` link its projection already carries, so
        // nothing is re-derived here.
        return .emptyTrash(
            counts: counts, versions: everything.count { $0.isVersion })
    }

    /// The confirmed act: ONE op (`requestPurge` — the intent write; rows
    /// leave every surface at once through the read-side fence), then the
    /// local sweep, and the RECEIPT to show. Refusals throw.
    @discardableResult
    static func confirm(session: AppSession, _ confirm: Confirm) async throws -> String {
        let synced = session.syncConfigured()
        let receipt: String
        switch confirm {
        case .deleteNow(let item, _):
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
            let wing = session.wing.readScope  // 13i-d U5: this wing's Trash
            let everything = try await session.database.read { db in
                try Queries.trash(db, now: now, wingID: wing)
            }
            // Ledger row 21 (G6): exactly what the surface ROWS — notes,
            // books, blocks and their families. An original rides its family
            // (round 8b) and a take on a living block is spared, because the
            // Trash never showed it and a door may not take what it does not
            // show. The clock still runs on a spared take; the confirm says so.
            let taken = everything.filter { TrashScope.emptyTrashTakes($0.kind) }
            let targets = taken
                .map { SyncPurgeTarget(table: $0.kind.purgeTable, rowID: $0.id) }
            // Read from the ACT-time listing, like the count beside it: the
            // receipt says what really went, never what the confirm guessed.
            let versionsTaken = taken.count { $0.isVersion }
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
                targets.count, synced: synced, anyFamilyEverSynced: anyFamilySynced,
                versions: versionsTaken)
        }
        // On a local-only install the cleanup IS the app's — run it now, so
        // Delete Now means what it says the moment she reads it (a configured
        // chain's janitor owns the road instead).
        await session.sweepLocalPurge()
        return receipt
    }
}

/// **WHAT THE GLOBAL TRASH IS FOR — ONE DECISION, BOTH SURFACES** (the
/// post-13l polish round, ledger rows 11 and 21).
///
/// Two of her rulings meet here, and both are about the same thing: a
/// deadline surface must show exactly what is leaving, and a door must take
/// exactly what it shows.
///
/// **D1 — takes never row here.** Her words: *"I feel like takes should
/// never appear in trash or archived alone — even if their parent block is
/// live, it's really hard without context and a take alone is so small."* A
/// take's ONE past-home is its block's History face; the note-level trash
/// section audits them per note. Nothing about the DATA changes: a deleted
/// take is still deleted, still on its own 30-day clock, still restorable
/// where it lives. What comes out is the LISTING.
///
/// **G6 — Empty Trash purges exactly what it rows.** Her words: *"a deleted
/// take on a living block might be the one item a user does want to keep. I
/// think that delete everything, including takes not displayed here, should
/// be an alternative button if it even exists."* So the bulk door takes
/// notes · books · blocks and their families (a rowed block's own takes go
/// with it — family-complete and all rowed), and individually-deleted takes
/// on LIVING blocks are untouched. **This supersedes 13j round-8's
/// "everything, always"**, deliberately and by her ruling.
///
/// The honesty caveat rides the confirm's copy, because sparing is not
/// keeping: a spared take still runs out its own 30 days, and putting it
/// back is the way to keep it.
nonisolated enum TrashScope {
    /// The kinds the GLOBAL Trash lists. Preserved originals are here
    /// because they ride a family clock and the deadline surface must show
    /// what is leaving; takes are not, per D1.
    static let listedKinds: Set<Queries.TrashItem.Kind> = [
        .note, .book, .block, .snippetGroup, .preservedOriginal,
    ]

    /// The filter picker's rows, in the order both surfaces show them.
    /// `.snippetGroup` joined at pre-13u Act 10 wave 2b (item 17) — the
    /// delete-group door's road must be listable, filterable, and bulk-
    /// purgeable exactly like every other deleted thing.
    static let filterKinds: [Queries.TrashItem.Kind] = [
        .note, .book, .block, .snippetGroup, .preservedOriginal,
    ]

    /// What ONE listing asks the query for: the picked kind, or everything
    /// the Trash lists. A filter can never widen the listing past D1.
    static func kinds(filter: Queries.TrashItem.Kind?) -> Set<Queries.TrashItem.Kind> {
        guard let filter, listedKinds.contains(filter) else { return listedKinds }
        return [filter]
    }

    /// Does Empty Trash take this row? A preserved original rides its family
    /// (her round-8b ruling — never separately purged), and a take is spared
    /// entirely (G6).
    static func emptyTrashTakes(_ kind: Queries.TrashItem.Kind) -> Bool {
        switch kind {
        case .note, .book, .block, .snippetGroup: return true
        case .take, .preservedOriginal: return false
        }
    }
}

/// **THE TRASH'S SHAPE ON SCREEN — ONE BRAIN, BOTH SURFACES** (the post-13l
/// polish round, ledger rows 3 and 22).
///
/// **A3 (her ruling):** *"a deleted take definitely needs to name both note
/// & block or it's kinda useless"* — rows must name their context. For the
/// global Trash that is the note a block came out of, and the honest way to
/// say it once for many rows is a **header**, not a suffix repeated on every
/// line.
///
/// **G7:** block rows gather under a small note-name header (the note itself
/// rows only if IT is deleted — then its own row heads the group), so a note
/// with many deleted blocks reads as one group rather than clutter.
///
/// **G7's tenth-sitting extension:** an original stranded onto the family
/// clock nests UNDER the block whose deletion stranded it — *"going to trash
/// shows you what you just deleted rather than suddenly being overwhelmed by
/// 31 random items"*. The anchor is the query's own answer
/// (`TrashItem.anchorBlockID`), never guessed from stamps here.
///
/// Presentation only: the rows, their order and every act on them are
/// unchanged — this decides what sits under what.
nonisolated enum TrashGrouping {
    /// One listed row, with the ancestors that died with it.
    struct Row: Equatable {
        let item: Queries.TrashItem
        /// Preserved originals whose family clock is THIS row's deletion.
        var nested: [Queries.TrashItem] = []
    }

    /// Rows that came out of one note, under its name.
    struct Group: Equatable {
        let noteID: String
        /// The note's OWN Trash row, when the note is in the Trash too — it
        /// heads its group instead of standing apart from its blocks.
        var noteRow: Queries.TrashItem?
        var rows: [Row] = []
    }

    /// The listing, in the order the query gave it, with groups placed where
    /// their first row fell.
    enum Entry: Equatable, Identifiable {
        case group(Group)
        /// A row with no note to gather under: a book, or a note whose blocks
        /// are not separately listed.
        case row(Row)

        /// **A STABLE IDENTITY, NOT A POSITION** (the ladder's LR1-10). The
        /// listing REORDERS under her hands — a Put back or a Delete Now
        /// removes a row and everything below it shifts up — so identifying
        /// entries by their index tells SwiftUI that every row below the
        /// change became a different row. The store's ids never move.
        /// (Prefixed, because a group is named by its note and that note may
        /// also be a row somewhere else in the listing.)
        var id: String {
            switch self {
            case .group(let group): return "group:\(group.noteID)"
            case .row(let row): return "row:\(row.item.id)"
            }
        }
    }

    /// **How many of this row's saved moments are in the Trash beside it**
    /// (the ladder's LR1-4): a note's Delete Now purges its own family and
    /// never another container, so its versions stay — and the confirm says
    /// so. Read from the listing she is looking at, which is also the listing
    /// showing her those rows under this one's name (G7's grouping), so the
    /// sentence and the screen can never disagree.
    ///
    /// Zero for anything that is not a note, and zero for a saved version
    /// (a moment has no moments of its own).
    ///
    /// **RECORDED, because it is deliberate and would otherwise be
    /// rediscovered** (the ladder's LR2-3): the listing it counts from is the
    /// WINDOWED one (`observeTrash`'s bound — the `observeLibrary` P1
    /// discipline, and the truncation marker that rides it). So a note whose
    /// moments fall past the window can be UNDER-counted, and its Delete Now
    /// confirm would then name fewer saved versions than really stay behind.
    /// Counting the true total would mean a second corpus-shaped read on the
    /// confirm's own path, which is exactly what the window exists to refuse —
    /// and the sentence's PURPOSE is that the screen and the words agree, which
    /// reading the screen's own listing guarantees by construction. The honest
    /// fix belongs with the windowing affordance itself (KnownIssues' bounded-
    /// view-windows row, owner 12) or with search's scoped reads (13o).
    static func savedVersions(of item: Queries.TrashItem, in items: [Queries.TrashItem]) -> Int {
        guard item.kind == .note, !item.isVersion else { return 0 }
        return items.count { $0.isVersion && $0.versionOfNoteID == item.id }
    }

    static func entries(_ items: [Queries.TrashItem]) -> [Entry] {
        // A note only becomes a HEADER when something else in the listing
        // points at it — otherwise a lone deleted note would render as a
        // group of one, which says less than the row itself does.
        //
        // **A SAVED VERSION IS THE ONE NOTE ROW THAT HAS A HOME** (the
        // post-13l polish round, ledger row 23 — FOUND-ITEM 1): it is a
        // container, so it rides the `.note` arm and every `.note` door
        // unchanged, but it is a MOMENT OF another note and gathers under it.
        // So the question a row is asked here is not "are you a note" but
        // "do you point at one", which is what `isVersion` answers.
        let homes = Set(items.compactMap {
            ($0.kind == .note && !$0.isVersion) ? nil : $0.noteID
        })
        let listedBlockIDs = Set(items.filter { $0.kind == .block }.map(\.id))
        var nestedUnder: [String: [Queries.TrashItem]] = [:]
        for item in items where item.kind == .preservedOriginal {
            guard let anchor = item.anchorBlockID, listedBlockIDs.contains(anchor)
            else { continue }
            nestedUnder[anchor, default: []].append(item)
        }
        let nestedIDs = Set(nestedUnder.values.joined().map(\.id))

        var entries: [Entry] = []
        var groupIndex: [String: Int] = [:]

        func groupSlot(_ noteID: String) -> Int {
            if let index = groupIndex[noteID] { return index }
            entries.append(.group(Group(noteID: noteID)))
            groupIndex[noteID] = entries.count - 1
            return entries.count - 1
        }

        for item in items {
            if nestedIDs.contains(item.id) { continue }  // it rides its anchor
            if item.kind == .note, !item.isVersion, homes.contains(item.id) {
                let slot = groupSlot(item.id)
                guard case .group(var group) = entries[slot] else { continue }
                group.noteRow = item
                entries[slot] = .group(group)
                continue
            }
            let row = Row(item: item, nested: nestedUnder[item.id] ?? [])
            guard let noteID = item.noteID, homes.contains(noteID) else {
                entries.append(.row(row))
                continue
            }
            let slot = groupSlot(noteID)
            guard case .group(var group) = entries[slot] else { continue }
            group.rows.append(row)
            entries[slot] = .group(group)
        }
        // A GROUP OF ONE says less than the row it wraps: the header repeats
        // what the row's own "from ‹note›" already carries, and her G7 concern
        // was clutter, not ceremony. So a lone block from a live note stays a
        // plain row — grouping earns its header at two rows, or at one when
        // the note itself is in the Trash and heads its own group.
        return entries.map { entry in
            guard case .group(let group) = entry,
                  group.noteRow == nil, group.rows.count == 1
            else { return entry }
            return .row(group.rows[0])
        }
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
