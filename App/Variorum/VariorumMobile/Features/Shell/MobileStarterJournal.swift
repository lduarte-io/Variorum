//
//  MobileStarterJournal.swift
//  VariorumMobile
//
//  Mobile Round 2, batch 5 — R27b: A STARTER JOURNAL BOOK FOR NEW USERS.
//
//  Her ruling, verbatim (`mobile-round-2.md` §41): *"I would also make a
//  journal book with one entry in it for new users introducing users to
//  their journal - and then if they delete that journal book or archive
//  it, it just doesn't appear at all. i think that's fine"*.
//
//  ── SEED ONCE, AND NEVER RE-SEED ──────────────────────────────────────
//  The whole difficulty is her second clause. A discover-by-name seeder
//  (`MobileTutorialSeeder`'s shape) would look for a book called
//  "Journal", find none after she deleted it, and put it back — which is
//  precisely what she ruled out. So "deleted or archived" must be
//  distinguishable from "never seeded", and TWO independent guards do it:
//
//  1. **A per-device, PER-STORE-VARIANT mark** (`UserDefaults`, the
//     `IdleCommitScheduler` precedent — debug and release share a
//     defaults domain, so an unscoped key would let a dev-store seed
//     suppress the real store's). Set only after the seed lands.
//  2. **A virgin-store guard**: the store must hold NO live book and NO
//     live note. A store that already has content is not a new user's,
//     however this device's mark reads — which is what protects a phone
//     that syncs an existing account down, and what makes a seed
//     interrupted halfway (app killed mid-seed) safe to re-attempt
//     without ever minting a second Journal.
//
//  3. **THE SYNC GATE** (the batch-5 cold review's MAJOR). The two guards
//     above are both LOCAL reads, and the seed used to run from the
//     shell's own `.task`, concurrently with — and in practice long
//     before — the sync chain that brings her corpus down: a bare-store
//     read is milliseconds, a first pull is a network round trip. So a
//     phone joining an EXISTING account minted a second `Journal`,
//     designated it, pinned it and minted a note, and every one of those
//     is an ordinary synced insert (SyncSpec §3's trigger-fed outbox)
//     that propagates to her Mac. Nothing in the merge matrix converges a
//     duplicate book away, and by design nothing should.
//
//     So the store is only judged NEW once sync has had its say. If this
//     device's store belongs to an ACCOUNT — a composed sync chain, or a
//     signed-in session whose chain has not composed yet — the seed waits
//     for the first CLEAN round (bounded), then re-asks `storeIsNew`.
//     Timing out means "we still don't know", and the seed declines: the
//     mark is not set, so the next launch simply asks again. Furniture is
//     the one thing in this app that can always wait.
//
//  **The honest residual, recorded rather than papered over:** a user who
//  deletes the starter book AND its entry, leaving a genuinely empty
//  store, and THEN deletes and reinstalls the app, gets it once more —
//  the mark dies with the install and the store looks new again. Closing
//  that needs a synced marker, and the `setting` table has no public
//  write door from app code (`upsertSetting` is internal), which would be
//  a `Sources/` change this batch is fenced from. Narrow, non-destructive,
//  and named.
//
//  **The SECOND honest residual, and it is the author's call, not this
//  file's:** a genuinely fresh install where nobody is signed in seeds at
//  once — correctly, because the store really is this device's — and if
//  she THEN signs into an existing account from Settings, her own Journal
//  arrives beside the starter one. The gate cannot close that: the only
//  surface offering sign-in lives inside the shell the seed launches with.
//  Closing it needs a product decision (an explicit first-run moment she
//  can see, or a post-sign-in reconciliation), which is hers. What the
//  gate DOES close is every case where the account was already known at
//  launch — the reinstall, the second device, the relaunch — which is the
//  one that reaches her real corpus without her doing anything at all.
//
//  ── WHY THE ENTRY CARRIES NO `entry_date` ─────────────────────────────
//  A journal entry stamped with TODAY would be the note
//  `createOrOpenJournalEntry` hands her when she first presses Today's
//  Entry — so her first real entry would open onto introduction copy.
//  The starter note is minted through `importPost`, which mints with
//  `entryDate: nil` by construction: it lives IN the Journal book as an
//  ordinary member and can never be mistaken for a day.
//
//  ── THE COPY IS HERS ──────────────────────────────────────────────────
//  **PROVISIONAL (batch 5).** Per the 13s row she writes the app's corpus
//  in her own voice; what is below is a draft standing in until she does,
//  and it is on her list. It deliberately teaches ONE thing — what this
//  book is and how a day gets into it — rather than becoming a second
//  pocket guide.
//

import Foundation
import VariorumCore

@MainActor
enum MobileStarterJournal {

    /// The book's name — the SAME constant the core's own first-press
    /// creation uses, so the seeded book and a core-minted one cannot
    /// drift apart in name.
    nonisolated static let bookName = Operations.defaultDailyJournalBookName

    /// The undo label the seed's mint would carry if it were undoable.
    /// It is not: the seed runs on the QUIET facade (no undo stack), the
    /// `MobileTutorialSeeder` precedent — a first launch must not leave a
    /// structural undo entry pointing at furniture she never placed.
    nonisolated static let undoLabel = "Starter Journal"

    /// PROVISIONAL copy — hers to rewrite (13s).
    nonisolated static let entryTitle = "Your journal"

    /// PROVISIONAL copy — hers to rewrite (13s).
    nonisolated static let entryText = """
        This is your journal. Every day you write gets its own entry here, \
        and they stay in date order.

        Tap Today's Entry — the little ✎ beside this book — to open today. \
        If today has no entry yet, that makes one; if it does, that opens \
        it. One day, one entry.

        You can delete this note, and you can delete the whole book. \
        Nothing here is furniture you are stuck with.
        """

    /// What a seed attempt did. Every case is a real outcome, and none of
    /// them throws: a first launch must never be blocked by furniture.
    enum Outcome: Equatable {
        /// This device has already seeded this store variant.
        case alreadySeeded
        /// The store is not a new user's — it holds books or notes.
        case storeNotNew
        /// This store belongs to an account whose first clean round has
        /// not landed, so whether it is new is not yet knowable. NOT a
        /// failure and NOT marked: the next launch asks again.
        case awaitingFirstSync
        case seeded(readingID: String)
        /// The store said no. Recorded, never surfaced — nothing the user
        /// asked for failed.
        case refused(String)
    }

    /// Marks are scoped by store variant, exactly like
    /// `IdleCommitScheduler.markDefaultsKey`.
    nonisolated static func seededDefaultsKey(
        for variant: AppDatabase.StoreVariant
    ) -> String {
        "MobileStarterJournalSeeded.\(variant.rawValue)"
    }

    /// **What the seed needs to know about sync, and nothing more** (guard
    /// 3). Two facts, injected as closures so a pin drives every state
    /// without composing a transport, and so this file never learns what a
    /// scheduler is.
    struct SyncGate {
        /// True when this store's contents are defined by an ACCOUNT
        /// rather than by this launch — a composed sync chain, OR a
        /// signed-in session whose chain has not composed yet (owner
        /// adoption can fail and leave a signed-in device unconfigured;
        /// that device's store still belongs to the account).
        var belongsToAnAccount: @MainActor () -> Bool
        /// True once a round has finished WITHOUT error — i.e. a
        /// pull-to-head has landed and the store now shows what the
        /// account holds. A FAILED round is not an answer.
        var hasSyncedCleanly: @MainActor () -> Bool

        /// The composition with no account anywhere — a dev store, or a
        /// caller that has no services yet. The store genuinely is this
        /// device's, so the seed proceeds on the two local guards alone.
        static let unowned = SyncGate(
            belongsToAnAccount: { false }, hasSyncedCleanly: { true })
    }

    /// How long the seed waits for a signed-in device's first clean round
    /// before declining. Generous, because declining is free: nothing is
    /// marked, and the next launch asks again.
    static let firstRoundWait: Duration = .seconds(20)

    /// The whole door. `loadMark`/`saveMark` are injectable so the pins
    /// drive a real store without touching this machine's defaults; `gate`
    /// is guard 3 (above), and its default is the no-account composition.
    @discardableResult
    static func seedIfNeeded(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SyncGate = .unowned,
        firstRoundWait: Duration? = nil,
        pollInterval: Duration = .milliseconds(100),
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil
    ) async -> Outcome {
        let key = seededDefaultsKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.bool(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }

        guard !load() else { return .alreadySeeded }

        do {
            // The cheap local answer first: a store that ALREADY holds
            // content is not a new user's whatever sync says, and asking
            // costs milliseconds. This is also what keeps the wait below
            // off every ordinary launch — it is only ever paid on a store
            // that currently looks empty.
            guard try await storeIsNew(session) else { return .storeNotNew }

            if gate.belongsToAnAccount() {
                guard await waitForFirstCleanRound(
                    gate: gate,
                    limit: firstRoundWait ?? Self.firstRoundWait,
                    poll: pollInterval)
                else { return .awaitingFirstSync }
                // Her corpus has landed if there was one. Ask again.
                guard try await storeIsNew(session) else { return .storeNotNew }
            }

            let readingID = try await mint(session)
            save(true)
            return .seeded(readingID: readingID)
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// Waits for the gate's clean-round fact, bounded. Polled rather than
    /// subscribed on purpose: `SyncSession.onRoundCompleted` is a SINGLE
    /// closure already owned by `AppServices` (it is what triggers the
    /// Fragments bridge after every round), so a second subscriber would
    /// have to displace the first — furniture must not be able to break
    /// the bridge. The cost is one cheap main-actor read every 100 ms, on
    /// a virgin store only, at most once per launch.
    private static func waitForFirstCleanRound(
        gate: SyncGate, limit: Duration, poll: Duration
    ) async -> Bool {
        if gate.hasSyncedCleanly() { return true }
        let deadline = ContinuousClock.now.advanced(by: limit)
        while ContinuousClock.now < deadline {
            do { try await Task.sleep(for: poll) } catch { return false }
            if gate.hasSyncedCleanly() { return true }
        }
        return gate.hasSyncedCleanly()
    }

    /// A new user's store: no live book, and no live unarchived note.
    /// Deliberately a READ of what the shelf and the library would SHOW —
    /// the same two listings she would be looking at.
    static func storeIsNew(_ session: AppSession) async throws -> Bool {
        try await session.database.read { db in
            guard try Queries.readings(db).isEmpty else { return false }
            return try Queries.library(db, limit: 1).isEmpty
        }
    }

    /// The seed itself — ordinary operations only, on the quiet facade
    /// (`Operations(undoStack: nil)`, the tutorial seeder's shape), inside
    /// ONE runner turn so nothing else can interleave a Journal of its own.
    ///
    /// The book is built to the SAME shape the core's own
    /// `insertDailyJournalBook` builds (curated · `profile: "journal"` ·
    /// `entry_date` ascending · designated · pinned), so a phone that
    /// seeded and a phone that pressed Today's Entry first end up with the
    /// same book.
    private static func mint(_ session: AppSession) async throws -> String {
        // Captured as locals: the runner's body is `@Sendable` and runs
        // off this actor, so it must not reach back for isolated state.
        let name = bookName
        let title = entryTitle
        let text = entryText
        let label = undoLabel
        return try await session.runner.run { _ in
            let quiet = Operations(undoStack: nil)
            let book = try quiet.createReading(
                name: name, kind: .curated, profile: "journal",
                sortField: .entryDate, sortDir: .asc)
            try quiet.setDailyJournalBook(book.id)
            try quiet.setShelfPinned(book.id, pinned: true)
            let entry = try quiet.importPost(
                title: title, text: text, undoLabel: label)
            _ = try quiet.addPostToReading(entry.container.id, to: book.id)
            return book.id
        }
    }
}
