//
//  MobileFirstWriteFurniture.swift
//  VariorumMobile
//
//  Pre-13u round, Act 0 — THE FIRST-WRITE OCCASION.
//
//  **Her ruling R-pre13u-1, "First write + repair":** the phone's starter
//  furniture is minted by her first WRITE, never by launch — *"sign in
//  before typing and the real Journal simply arrives"* — and the 20-second
//  bounded wait it replaces is deleted. **Her ruling R-pre13u-8** puts the
//  sample library on the same occasion and through the same gate: *"some
//  people will be phone only users and they should get to experience it."*
//
//  ── WHY A WRITE IS A BETTER MOMENT THAN A LAUNCH ──────────────────────
//  Not because it is later. Because it is the first moment at which the
//  question has an answer.
//
//  The sign-in door lives inside the shell, so at launch on a fresh
//  install there is no ordering in which the account could already be
//  known — a launch-time seeder is asking "is this store yours or an
//  account's?" of a store that cannot yet say. Waiting only narrows that
//  window; it never closes it, and a network stumble reads exactly like
//  "nothing is here, seed away". By the time she writes, sign-in either
//  happened or it did not. One boolean, read once, no clock involved.
//
//  ── THE THREE FACTS, AND WHEN EACH IS TAKEN ───────────────────────────
//  1. **Does the store belong to an account?** — at the WRITE. The whole
//     reason the occasion moved. An account-owned store seeds NOTHING:
//     her Journal and the sample library both arrive by sync. Her accepted
//     corner, ruled: an account whose sync never lands simply waits.
//  2. **Was the store empty when the app opened?** — at LAUNCH (`prime`).
//     It has to be, because by the write moment her own first note may
//     already have landed, and reading it late would decline on the
//     strength of the very keystroke that summoned the furniture. Reading
//     is not seeding; what her ruling moved off the launch path is the
//     MINT. This one gates the starter Journal only — the sample library
//     is not new-user furniture (her Act 3 ruling: every reader's store).
//  3. **Has this device seeded before?** — the per-store-variant marks,
//     each seeder's own. Deleting the furniture keeps it deleted.
//
//  ── IT IS A SIGNAL, NEVER A BARRIER ───────────────────────────────────
//  `noteFirstWrite()` returns immediately and starts a task nobody awaits.
//  A write door announces and moves on. Two things follow from that and
//  both are deliberate: the seeds can land AFTER her note (harmless — the
//  furniture is a book, and the mint re-checks for one inside its own
//  runner turn), and the ~0.5 MB sample parse plus thirteen note mints are
//  never on a keystroke's path. `session.noteFirstWrite()` is the one line
//  a door adds; idempotence is entirely this object's problem, so no door
//  has to know whether it is the first.
//

import Foundation
import OSLog
import VariorumCore

@MainActor
final class MobileFirstWriteFurniture {

    /// Injected marks, so a pin drives a real store without touching this
    /// machine's defaults. Nil means "use the device's own key" — each
    /// seeder's `seededDefaultsKey(for:)`, scoped per store variant.
    struct Marks {
        var loadJournal: (() -> Bool)?
        var saveJournal: ((Bool) -> Void)?
        var loadSample: (() -> Bool)?
        var saveSample: ((Bool) -> Void)?
        /// pre-13x 5a: *Encryption Explained*'s own mark (nil = the device
        /// defaults under its own key, beside Sherlock's).
        var loadEncryptionBook: (() -> Bool)?
        var saveEncryptionBook: ((Bool) -> Void)?
        // (The Jekyll book's marks left with its seed — 17y B-DEDUPE,
        // R-17y-8: Jekyll is out of the DEFAULT seed on both platforms;
        // `Book.launchSet` is the launch vocabulary, `Book.all` the doors'.)

        static let deviceDefaults = Marks()
    }

    /// What one first-write occasion did. Recorded rather than surfaced:
    /// furniture never speaks to her, so without this there is no way to
    /// tell "already seeded" from "the account owns this store" — which is
    /// exactly the question asked the first time it does not appear.
    enum Outcome: Equatable {
        /// A previous write already spent this launch's occasion.
        case alreadyRan
        /// The store's content belongs to an ACCOUNT. Neither seed runs;
        /// both arrive by sync. Nothing is marked.
        case accountOwned
        /// The occasion ran. `journal` is nil when the launch verdict was
        /// never taken (`prime` never ran, or its read failed) — the
        /// starter Journal is skipped rather than guessed at, while the
        /// sample library, which has no virgin-store guard, still runs.
        case ran(journal: MobileStarterJournal.Outcome?,
                 sample: SampleLibrarySeeder.Outcome)
    }

    private let session: AppSession
    private let storeVariant: AppDatabase.StoreVariant
    private let gate: MobileStarterJournal.SyncGate
    private let marks: Marks

    /// Fact 2, taken at launch and spent at the write. Nil until `prime`.
    private var storeWasEmptyAtLaunch: Bool?
    /// pre-13x 5a: what the occasion did for *Encryption Explained* — beside
    /// `Outcome.ran`'s two, not inside it (the phone's pins match that
    /// case's shape; the second book records its own line).
    private(set) var encryptionBookOutcome: SampleLibrarySeeder.Outcome?
    /// The one in-flight occasion. Held (rather than a bare bool) so a
    /// second door firing mid-seed joins the first instead of starting a
    /// second, and so a pin can await deterministically what production
    /// deliberately does not.
    private var occasion: Task<Outcome, Never>?

    /// **Why an occasion nobody can see logs one line** (the midpoint
    /// review's m3): every outcome here is silent by design — furniture
    /// never speaks to her — so without this there is no way to tell
    /// "already seeded" from "the account owns this store" from "the store
    /// refused", which is exactly the question asked the first time the
    /// Journal or Sherlock does not appear. It matters most for
    /// `.accountOwned`, which short-circuits BEFORE either seeder and so
    /// produced no line anywhere: `SampleLibrarySeeder` logs its own
    /// outcomes, but only when it is reached.
    ///
    /// `log show --predicate 'subsystem == "io.lduarte.Variorum" AND
    /// category == "first-write-furniture"'` — the `SampleLibrarySeeder`
    /// precedent, verbatim. `.public` is safe by inspection: `Outcome`
    /// carries case names and reading ids, never a word she wrote.
    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "first-write-furniture")

    init(
        session: AppSession,
        storeVariant: AppDatabase.StoreVariant,
        gate: MobileStarterJournal.SyncGate = .unowned,
        marks: Marks = .deviceDefaults
    ) {
        self.session = session
        self.storeVariant = storeVariant
        self.gate = gate
        self.marks = marks
    }

    /// **Fact 2, at launch.** One cheap local read of the two listings the
    /// shelf and the library would show. Never mints, never waits, never
    /// touches the network — the launch cost this replaced was a 20-second
    /// poll, and what remains is a single indexed read of an empty store.
    ///
    /// A read that throws leaves the verdict UNTAKEN rather than guessing
    /// `true`: the guess that seeds is the one that duplicates her Journal.
    func prime() async {
        storeWasEmptyAtLaunch = try? await MobileStarterJournal.storeIsNew(session)
    }

    /// **The signal.** Called by every door that puts content in the store;
    /// returns instantly, and what it starts is awaited by nobody.
    func noteFirstWrite() {
        guard occasion == nil else { return }
        Task { _ = await run() }
    }

    /// The occasion itself. Public to the pins and to `noteFirstWrite`;
    /// safe to call repeatedly — the first call owns the work and every
    /// later one joins it.
    @discardableResult
    func run() async -> Outcome {
        if let occasion {
            _ = await occasion.value
            Self.log.notice("first write: alreadyRan")
            return .alreadyRan
        }
        let task = Task { await perform() }
        occasion = task
        let outcome = await task.value
        // ONE line per occasion, naming every case: `.accountOwned`, or
        // `.ran` with BOTH seeders' own outcomes inside it (seeded /
        // alreadySeeded / alreadyPresent / storeNotNew / refused).
        Self.log.notice(
            "first write: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private func perform() async -> Outcome {
        // Fact 1, and it decides for BOTH seeds. Her ruled shape: an
        // account-owned store is never seeded locally — arrive-by-sync is
        // the account path for the Journal and for Sherlock alike.
        guard !gate.belongsToAnAccount() else { return .accountOwned }

        // The Journal first, deliberately: the sample library mints a book
        // of its own, and the starter Journal's live guard declines when a
        // book is already there. Ordering them is cheaper and clearer than
        // teaching that guard which books to ignore.
        var journal: MobileStarterJournal.Outcome?
        if let wasEmpty = storeWasEmptyAtLaunch {
            journal = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: storeVariant,
                // The account question is already answered above; handing
                // the seeder `.unowned` keeps ONE reading of one fact per
                // occasion rather than two that could disagree.
                gate: .unowned,
                storeWasEmptyAtLaunch: wasEmpty,
                loadMark: marks.loadJournal, saveMark: marks.saveJournal)
        }

        // R-pre13u-8: the phone gets the sample library on the same
        // occasion, through the same gate — and with NO virgin-store guard,
        // exactly as the Mac has none (her Act 3 ruling is every reader's
        // store, not every new reader's). `.unowned` again, for the reason
        // above, and it also makes the Mac's bounded wait structurally
        // unreachable from the phone: this occasion never waits.
        //
        // **Paced behind her writing** (the ladder's F12). The occasion fires
        // at her FIRST WRITE — she is typing — and the thirteen story imports
        // share the ONE serial runner her autosaves go through: each import
        // is one turn (hundreds of milliseconds on a phone), and an autosave
        // reaching the runner behind one waits the whole turn. So the seed
        // runs at `.utility` (the runner prefers her writes when both are
        // queued) and, before every turn, holds while any open note still
        // has text that has not landed — up to `storyPacingCap` per turn,
        // so a reader who never pauses still gets her library, at worst
        // one story per cap. The first note's own autosaves therefore never
        // queue behind a story turn.
        let session = self.session
        let storeVariant = self.storeVariant
        let marks = self.marks
        let sample = await Task(priority: .utility) { @MainActor in
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, storeVariant: storeVariant, gate: .unowned,
                loadMark: marks.loadSample, saveMark: marks.saveSample,
                pacing: { await Self.holdWhileWritingLands(session) })
        }.value

        // pre-13x 5a: *Encryption Explained* on the same occasion, the same
        // gate, its own mark — paced the same way (eight short notes).
        // An injected SAMPLE mark stands for both books unless the
        // encryption book's own mark is injected too (production injects
        // neither — each book reads its own defaults key): a pin that says
        // "Sherlock is already seeded" to skip the half-megabyte parse skips
        // this book's eight mints for the same reason.
        let loadEncryption = marks.loadEncryptionBook ?? marks.loadSample
        let saveEncryption = marks.saveEncryptionBook ?? (marks.loadEncryptionBook == nil ? marks.saveSample : nil)
        let encryptionBook = await Task(priority: .utility) { @MainActor in
            await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .encryptionExplained,
                storeVariant: storeVariant, gate: .unowned,
                loadMark: loadEncryption, saveMark: saveEncryption,
                pacing: { await Self.holdWhileWritingLands(session) })
        }.value
        encryptionBookOutcome = encryptionBook
        Self.log.notice(
            "first write (Encryption Explained): \(String(describing: encryptionBook), privacy: .public)")

        // (The Jekyll/takemania seed ran here 18l-c U6 → 17y B-DEDUPE.
        // R-17y-8 removed it from the DEFAULT seed on both platforms — a
        // fresh phone is born without it, an existing store keeps what it
        // has, and the Mac's Help ▸ Restore still mints it on demand; a
        // restored copy then arrives here by sync like any book.)

        return .ran(journal: journal, sample: sample)
    }

    /// How long one story turn may be held behind her pending writing
    /// before it runs anyway — a cap, not a budget: with it, continuous
    /// typing costs at most one story per cap; without it a reader who
    /// never pauses would never get her library.
    static let storyPacingCap: Duration = .seconds(3)
    static let storyPacingPoll: Duration = .milliseconds(20)

    /// The pacing wait itself: returns the moment no open note holds
    /// unlanded text, or at the cap.
    static func holdWhileWritingLands(_ session: AppSession) async {
        let deadline = ContinuousClock.now.advanced(by: storyPacingCap)
        while session.hasPendingAutosave, ContinuousClock.now < deadline {
            do { try await Task.sleep(for: storyPacingPoll) } catch { return }
        }
    }
}
