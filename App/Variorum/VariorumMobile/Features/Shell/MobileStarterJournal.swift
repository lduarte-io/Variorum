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
//  distinguishable from "never seeded", and the guards below do it.
//
//  ── R-pre13u-1: SEED ON FIRST WRITE, NOT FIRST LAUNCH ─────────────────
//  **Her ruling (2026-08-31, "First write + repair"), and it replaced the
//  whole sync-gate apparatus this file used to carry.** The furniture is
//  minted by her first WRITE — sign in before typing and the real Journal
//  simply arrives — so the 20-second bounded wait and its polling are
//  DELETED, and the launch-time seed call is gone from
//  `VariorumMobileApp`. The occasion is now `MobileFirstWriteFurniture`,
//  which the write doors announce to and nothing on a write path awaits.
//
//  **THE CORRECTION THIS HEADER OWED (dated 2026-08-31, the Act 0
//  obligation).** What stood here claimed the virgin-store guard "protects
//  a phone that syncs an existing account down". **That was FALSE, and the
//  residual proved it:** the only sign-in surface lives inside the shell
//  the seed launched with, so on a fresh install there was no ordering in
//  which the account could be known first — install on a new phone against
//  her existing account and it minted a Journal, designated it, pinned it
//  and minted a note, every one an ordinary synced insert that propagated
//  to every device. A local read of an empty store cannot tell "you have
//  nothing" from "your things have not arrived yet", and no amount of
//  waiting makes it able to: waiting only narrows the window.
//
//  **What actually protects it now** is that the question is asked at a
//  moment when the answer exists. By the time she WRITES, sign-in either
//  happened or did not, so `belongsToAnAccount` is a fact rather than a
//  race — and a store that belongs to an account is simply not seeded at
//  all (her accepted corner: an account whose sync never lands gets its
//  Journal when sync first lands, and nothing before).
//
//  Three guards remain, and each answers a different question:
//
//  1. **A per-device, PER-STORE-VARIANT mark** (`UserDefaults`, the
//     `IdleCommitScheduler` precedent — debug and release share a
//     defaults domain, so an unscoped key would let a dev-store seed
//     suppress the real store's). Set only after the seed lands. This is
//     what makes her "delete it and it stays deleted" ruling real.
//  2. **THE ACCOUNT GATE** — one fact, read AT THE WRITE: does this
//     store's content belong to an account rather than to this launch?
//     True for a composed sync chain OR a signed-in session whose chain
//     has not composed yet (owner adoption can fail and leave a signed-in
//     device unconfigured; that device's store still belongs to the
//     account, and `isConfigured` alone reads the unsafe direction).
//  3. **The virgin verdict, taken at LAUNCH and spent at the write.** A
//     store that already holds her writing is not a new user's. It has to
//     be read at launch because by the write moment her own first note may
//     already have landed — reading it late would decline on the strength
//     of the very keystroke that summoned the furniture. Reading is not
//     seeding; what her ruling moved off the launch path is the MINT.
//     Beside it, a **live re-check inside the mint's own runner turn**:
//     if any book exists by then, nothing is minted. That guard cannot be
//     read stale (AppSpec's `deleteBlock` precondition doctrine — a
//     precondition evaluated inside the write's transaction), and it is
//     what makes Today's Entry racing the furniture safe: `shelveInDaily
//     JournalBook` creates and pins the Journal book itself, so whichever
//     turn runs first, exactly one Journal book exists after both.
//
//  **The honest residual, recorded rather than papered over:** a user who
//  deletes the starter book AND its entry, leaving a genuinely empty
//  store, and THEN deletes and reinstalls the app, gets it once more —
//  the mark dies with the install and the store looks new again. Closing
//  that needs a synced marker, and the `setting` table has no public
//  write door from app code (`upsertSetting` is internal). Narrow,
//  non-destructive, and named.
//
//  **The residual her ruling deliberately leaves open, and its answer:**
//  seed while signed out, then sign in, and two designated Journal books
//  meet. That is the SECOND half of "First write + repair" — a SyncSpec
//  §7-class convergence repair (deterministic keeper, memberships
//  re-pointed, loser tombstoned), which is `Sources/VariorumCore/Sync/`
//  work and belongs to this round's Fable half. It is the only shape that
//  also heals a device where the duplication already happened.
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
    /// them throws: a first write must never be blocked by furniture.
    enum Outcome: Equatable {
        /// This device has already seeded this store variant.
        case alreadySeeded
        /// The store is not a new user's — it held books or notes when the
        /// app opened, or a book exists by the time the mint runs.
        case storeNotNew
        /// This store's content belongs to an ACCOUNT, so the real Journal
        /// is the account's to deliver. NOT marked: if she signs out and
        /// starts fresh, the next write asks again — **across LAUNCHES**
        /// (clarified 2026-08-31, the midpoint review's n2). Within one
        /// launch the occasion is spent the moment it runs:
        /// `MobileFirstWriteFurniture` holds a single `occasion` task, so
        /// every later write joins it and returns `.alreadyRan`. Signing in
        /// or out mid-session therefore changes nothing until the next
        /// launch, which is deliberate — the account question is read ONCE
        /// per launch, at the first write, and re-reading it per keystroke
        /// is exactly the churn the occasion exists to avoid.
        case accountOwned
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
    /// 2). ONE fact now, injected as a closure so a pin drives every state
    /// without composing a transport, and so this file never learns what a
    /// scheduler is.
    ///
    /// **`hasSyncedCleanly` is GONE with the wait it served** (R-pre13u-1).
    /// It existed to answer *"has the account's content arrived yet?"*, a
    /// question only a seed racing the first pull has to ask. Asking at the
    /// write instead means the account's content does not need to have
    /// arrived: an account-owned store is simply never seeded, so a failed
    /// round, a long offline stretch and a §12 lockstep refusal all reach
    /// the same correct answer with nothing waiting on them.
    struct SyncGate {
        /// True when this store's contents are defined by an ACCOUNT
        /// rather than by this launch — a composed sync chain, OR a
        /// signed-in session whose chain has not composed yet (owner
        /// adoption can fail and leave a signed-in device unconfigured;
        /// that device's store still belongs to the account, and
        /// `isConfigured` alone reads the unsafe direction).
        var belongsToAnAccount: @MainActor () -> Bool

        /// The composition with no account anywhere — a dev store, or a
        /// caller that has no services yet. The store genuinely is this
        /// device's, so the seed proceeds on the local guards alone.
        static let unowned = SyncGate(belongsToAnAccount: { false })
    }

    /// The whole door, spent at her FIRST WRITE.
    ///
    /// `storeWasEmptyAtLaunch` is guard 3's launch half — see
    /// `MobileFirstWriteFurniture.prime()` for why it is taken then and
    /// spent here. `loadMark`/`saveMark` are injectable so the pins drive a
    /// real store without touching this machine's defaults; `gate`'s
    /// default is the no-account composition.
    @discardableResult
    static func seedIfNeeded(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant = .real,
        gate: SyncGate = .unowned,
        storeWasEmptyAtLaunch: Bool,
        loadMark: (() -> Bool)? = nil,
        saveMark: ((Bool) -> Void)? = nil
    ) async -> Outcome {
        let key = seededDefaultsKey(for: storeVariant)
        let load = loadMark ?? { UserDefaults.standard.bool(forKey: key) }
        let save = saveMark ?? { UserDefaults.standard.set($0, forKey: key) }

        guard !load() else { return .alreadySeeded }
        // Read at the WRITE, where the answer exists. This is the guard the
        // old header wrongly credited to the virgin-store read.
        guard !gate.belongsToAnAccount() else { return .accountOwned }
        guard storeWasEmptyAtLaunch else { return .storeNotNew }

        do {
            guard let readingID = try await mint(session) else {
                return .storeNotNew
            }
            save(true)
            return .seeded(readingID: readingID)
        } catch {
            return .refused(String(describing: error))
        }
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
    ///
    /// **Returns nil when a book already exists by the time the turn runs**
    /// — guard 3's live half, read INSIDE the write it authorizes rather
    /// than before it. The occasion that makes this real is Today's Entry:
    /// `shelveInDailyJournalBook` creates and pins the Journal book itself
    /// (AppSpec §9), so her very first act can be a door that mints the
    /// same book this one would. The runner is serial, so one of the two
    /// turns sees the other's book and declines — and exactly one Journal
    /// exists either way, without either door knowing about the other.
    private static func mint(_ session: AppSession) async throws -> String? {
        // Captured as locals: the runner's body is `@Sendable` and runs
        // off this actor, so it must not reach back for isolated state.
        let name = bookName
        let title = entryTitle
        let text = entryText
        let label = undoLabel
        return try await session.runner.run { _ -> String? in
            let quiet = Operations(undoStack: nil)
            // Guard 3's live half, read inside the turn that acts on it.
            // Two questions, both cheap and both shelf-bounded (P1: books,
            // never a corpus): is a daily journal book already DESIGNATED
            // (what Today's Entry does), and is the name already taken (a
            // book she made herself, or a restored one)?
            guard try quiet.dailyJournalBookID() == nil else { return nil }
            do { try quiet.assertBookNameIsFree(name) }
            catch let error as OperationError {
                guard case .duplicateBookName = error else { throw error }
                return nil
            }
            let book = try quiet.createReading(
                name: name, kind: .curated, profile: Queries.dailyJournalBookProfile,
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
