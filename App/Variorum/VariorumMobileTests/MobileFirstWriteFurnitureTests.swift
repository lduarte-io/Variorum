//
//  MobileFirstWriteFurnitureTests.swift
//  VariorumMobileTests
//
//  Pre-13u round, Act 0 — THE FIRST-WRITE OCCASION (R-pre13u-1 / R-pre13u-8).
//
//  These pins carry the behaviour CHANGE, so each names what it would have
//  said before it. The verification method is behavioural revert (the
//  hallucination guard's form for a ruled change rather than a bug fix):
//  restore the old behaviour in the implementation and the named pin reds.
//  The reverts that were actually run are recorded in the round's Act 0
//  record; the sentence on each pin says which one drives it.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
private final class FakeAccount {
    var belongsToAnAccount = false
    var gate: MobileStarterJournal.SyncGate {
        .init(belongsToAnAccount: { [self] in belongsToAnAccount })
    }
}

/// Both marks, living in the test rather than in this machine's defaults.
@MainActor
private final class Marks {
    var journal = false
    var sample = false
    /// The composition that lets a pin ignore the sample library entirely:
    /// its mark reads "already seeded", so the ~0.5 MB parse and thirteen
    /// note mints never run. Used by every pin whose subject is the
    /// Journal or the occasion itself.
    var withoutSample: MobileFirstWriteFurniture.Marks {
        .init(loadJournal: { [self] in journal },
              saveJournal: { [self] in journal = $0 },
              loadSample: { true }, saveSample: { _ in })
    }
    var both: MobileFirstWriteFurniture.Marks {
        .init(loadJournal: { [self] in journal },
              saveJournal: { [self] in journal = $0 },
              loadSample: { [self] in sample },
              saveSample: { [self] in sample = $0 })
    }
    // (The Jekyll marks helper left with the phone's Jekyll seed —
    // 17y B-DEDUPE, R-17y-8; the encryption book's left with ITS seed —
    // 13s-b U1b, R-13s-5/37.)
}

@Suite("The first-write occasion (R-pre13u-1 / R-pre13u-8)")
struct MobileFirstWriteFurnitureTests {

    // MARK: The occasion itself

    /// **THE RULING, PINNED: PRIMING SEEDS NOTHING.** `prime()` is
    /// everything the launch path does now — one cheap local read — and
    /// after it the store must be exactly as empty as it was.
    ///
    /// *Red on the old behaviour:* the launch used to call
    /// `MobileStarterJournal.seedIfNeeded` directly, so a store observed
    /// after the launch task held a Journal book, a designation, a pin and
    /// a note. Reverting `prime()` to seed reds this pin on its first
    /// assertion.
    @Test func primingSeedsNothing() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: marks.withoutSample)

            await furniture.prime()

            let afterLaunch = try await db.read { db in try Queries.readings(db) }
            #expect(afterLaunch.isEmpty, "launch alone must mint nothing")
            #expect(!marks.journal, "and must not spend the one seed")

            // …and then she writes.
            _ = await furniture.run()
            let afterWrite = try await db.read { db in try Queries.readings(db) }
            #expect(afterWrite.count == 1, "the WRITE is what mints it")
            #expect(marks.journal)
        }
    }

    /// The signal is idempotent: several doors firing (a quick note, then
    /// Today's Entry, then a book) spend ONE occasion between them.
    @Test func theOccasionIsSpentOnce() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: marks.withoutSample)
            await furniture.prime()

            let first = await furniture.run()
            guard case .ran = first else {
                Issue.record("expected the occasion to run, got \(first)")
                return
            }
            #expect(await furniture.run() == .alreadyRan)
            #expect(await furniture.run() == .alreadyRan)

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    /// `noteFirstWrite()` is a SIGNAL: it returns without awaiting what it
    /// starts, and what it starts still lands. (The pin waits on the
    /// occasion explicitly — production never does, which is the point.)
    @Test func theSignalReturnsWithoutAwaitingTheSeed() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: marks.withoutSample)
            await furniture.prime()

            furniture.noteFirstWrite()
            _ = await furniture.run()   // join whatever the signal started

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    /// An occasion whose launch verdict was never taken skips the JOURNAL
    /// (the guess that seeds is the one that duplicates her book) while
    /// still running the sample library's seeder. (VX-633 U2b: that seeder
    /// now reads its own untaken launch fact as NOT fresh for the fresh-only
    /// Prince — `anExistingPhoneStoreNeverGainsThePrince` pins the decline;
    /// here its mark short-circuits first, as before.)
    @Test func anUnprimedOccasionSkipsTheJournalOnly() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: marks.withoutSample)

            guard case .ran(let journal, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            #expect(journal == nil, "no verdict, no Journal — never a guess")
            #expect(sample == .alreadySeeded, "the sample half still ran")

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty)
        }
    }

    // MARK: The account gate — one reading, both seeds

    /// An account-owned store seeds NOTHING: her Journal and her sample
    /// library both arrive by sync (R-pre13u-1 and R-pre13u-8's shared
    /// rule). Nothing is marked, so signing out asks again.
    @Test func anAccountOwnedStoreSeedsNothing() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let account = FakeAccount()
            account.belongsToAnAccount = true
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, gate: account.gate,
                marks: marks.both)
            await furniture.prime()

            #expect(await furniture.run() == .accountOwned)
            #expect(!marks.journal)
            #expect(!marks.sample)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty)
        }
    }

    /// **THE 20-SECOND WAIT IS GONE.** The old gate polled for a signed-in
    /// device's first clean round before declining, so a signed-in phone's
    /// furniture decision took up to twenty seconds. The account question
    /// is now answered outright.
    ///
    /// *Red on the old behaviour:* restoring the bounded wait makes this
    /// occasion take ~20 s and blow the budget. The budget is deliberately
    /// generous (5 s against a path that does no I/O at all) so that a
    /// loaded machine cannot make it flake — it is a pin against a
    /// twenty-second wait, not a latency benchmark.
    @Test func anAccountOwnedStoreDoesNotWait() async throws {
        try await withEditorWorld { session, _ in
            let marks = Marks()
            let account = FakeAccount()
            account.belongsToAnAccount = true
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, gate: account.gate,
                marks: marks.both)
            await furniture.prime()

            let started = ContinuousClock.now
            #expect(await furniture.run() == .accountOwned)
            let elapsed = ContinuousClock.now - started
            #expect(elapsed < .seconds(5),
                    "the bounded wait is deleted — the answer is a fact, not a poll")
        }
    }

    // MARK: R-pre13u-8 — the phone's sample library

    /// **HER RULING: A PHONE-ONLY STORE GETS SHERLOCK.** *"some people will
    /// be phone only users and they should get to experience it."* Same
    /// occasion, same gate, and the same library the Mac seeds — book,
    /// chapters, the attribution front matter, and the `sherlock holmes`
    /// tag on every note. **JUSTIFIED EDIT (VX-633, R-633-6):** the library
    /// the Mac seeds is *The Prince*, bilingual — the launch book — so a
    /// phone-only store gets the Prince: 27 chapters in the front matter's
    /// section, the Dedication's own (U2b, R-633-17) and four parts, every
    /// note wearing `machiavelli`. RED ON OLD:
    /// the occasion named no book and seeded Sherlock by the default.
    ///
    /// *Red on the old behaviour:* before this act the phone had no sample
    /// library at all — `SampleLibrarySeeder` was Mac-app-local code the
    /// mobile target could not even name.
    @Test func aPhoneOnlyStoreGetsTheSampleLibrary() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()

            guard case .ran(_, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            guard case .seeded(let readingID, let stories) = sample else {
                Issue.record("expected a sample seed, got \(sample)")
                return
            }
            let book = SampleLibrarySeeder.Book.launchBook
            #expect(book == .prince)
            #expect(stories == 27, "the dedication and twenty-six chapters")
            #expect(marks.sample)

            let facts = try await db.read { db -> (Int, Int, Bool, Int, Int) in
                let members = try Queries.assembleReading(db, readingID: readingID)
                let chapters = try Queries.readingSections(db, readingID: readingID)
                let tag = try #require(
                    Queries.allTags(db)
                        .first { $0.path == book.tagName })
                let tagged = try Queries.everythingTagged(db, tagID: tag.id)
                let italian = try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE label = ? AND deleted_at IS NULL",
                    arguments: [SampleLibraryPrinceBook.italianTakeLabel]) ?? 0
                return (members.count, chapters.count,
                        members.contains { $0.title == book.frontMatterTitle },
                        tagged.postIDs.count, italian)
            }
            #expect(facts.0 == stories + 1, "every chapter, plus the attribution")
            // U2b (R-633-17): the Dedication's own chapter joins them — six.
            #expect(facts.1 == 6, "the front matter's section, the Dedication's and the four parts")
            #expect(facts.2, "the attribution ships with the public-domain text")
            #expect(facts.3 == facts.0, "every note wears her tag")
            #expect(facts.4 == 200, "every paragraph carries its Italian take — the same brain as the Mac")
        }
    }

    /// **RED ON OLD (the ladder's F12, MINOR) — an ORDERING pin, never a
    /// timing.** The Sherlock seed runs on the SAME serial runner as her
    /// autosaves, at the moment of her first write; each story import is one
    /// turn, and an autosave reaching the runner behind it waited the whole
    /// turn. Now the seed holds every turn while any open note still has
    /// unlanded text: with an autosave PENDING, no sample turn runs — the
    /// book does not even exist — and the moment the text lands, the seed
    /// proceeds to completion. Old code minted the book and its first
    /// stories immediately, pending autosave or not.
    /// **JUSTIFIED EDIT (VX-633 U2b — R-633-16, "FRESH STORES ONLY"):** the
    /// launch is PRIMED on the empty store FIRST and her note is written
    /// after — the real order (`prime` at launch, the occasion at her first
    /// write). Primed after her note, the launch-time fact read a store that
    /// already held writing, and the fresh-only Prince would — correctly —
    /// decline it; the subject (the pacing) is unchanged.
    @Test func theSampleSeedWaitsForPendingWritingToLand() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()

            // Her note, with text sitting in its autosave debounce (a sleep
            // that never wakes — the pin flushes explicitly, deterministically).
            let (postID, variantID) = try await session.runner.run { ops in
                let post = try ops.createPost(title: "my first note")
                let block = try ops.newBlock(in: post.id, text: "Dear diary")
                return (post.id, block.variant.id)
            }
            let autosave = session.autosave(
                forPost: postID, sleep: { _ in throw CancellationError() })
            autosave.record(variantID: variantID, text: "Dear diary, today", charDelta: 7)
            #expect(session.hasPendingAutosave, "positive activity: her text is pending")

            let occasion = Task { await furniture.run() }

            // While her text has not landed, NOTHING of the library exists —
            // polled well inside the per-turn cap, so this cannot pass by
            // the seed simply being slow.
            let watch = ContinuousClock.now.advanced(by: .milliseconds(400))
            var sampleBookSeen = false
            while ContinuousClock.now < watch {
                try await Task.sleep(for: .milliseconds(25))
                let books = try await db.read { db in try Queries.readings(db) }
                if books.contains(where: { $0.name == SampleLibrarySeeder.Book.launchBook.name }) {
                    sampleBookSeen = true
                    break
                }
            }
            #expect(!sampleBookSeen, "no story turn may run while her autosave is pending")

            // Her text lands; the seed proceeds and completes.
            await autosave.flushNow()
            #expect(!session.hasPendingAutosave)
            guard case .ran(_, let sample) = await occasion.value,
                  case .seeded(let readingID, let stories) = sample
            else {
                Issue.record("expected the paced seed to complete")
                return
            }
            #expect(stories == 27)
            let facts = try await db.read { db -> (Int, String?) in
                (try Queries.assembleReading(db, readingID: readingID).count,
                 try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [variantID]))
            }
            #expect(facts.0 == stories + 1)
            #expect(facts.1 == "Dear diary, today", "and her text is exactly what landed")
        }
    }

    /// …and an account-owned store does NOT seed it locally: it arrives
    /// with the rest of the account's content (her ruled arrive-by-sync).
    @Test func theSampleLibraryIsSkippedForAnAccount() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let account = FakeAccount()
            account.belongsToAnAccount = true
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, gate: account.gate,
                marks: marks.both)
            await furniture.prime()
            _ = await furniture.run()

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(!books.contains { $0.name == SampleLibrarySeeder.Book.launchBook.name })
        }
    }

    /// The two seeds are ORDERED, and the order is why the Journal
    /// survives: the sample library mints a book, and the Journal's live
    /// guard declines against any book. Pinned as behaviour so a later
    /// reordering announces itself instead of quietly costing her the
    /// starter Journal.
    @Test func theJournalIsSeededBeforeTheSampleLibrary() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()
            _ = await furniture.run()

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.contains { $0.name == MobileStarterJournal.bookName },
                    "the starter Journal survived the library's book")
            #expect(books.contains { $0.name == SampleLibrarySeeder.Book.launchBook.name })
        }
    }

    // MARK: VX-633 U2b (R-633-16) — the Prince seeds a FRESH phone store only

    /// **RED ON OLD — AN EXISTING PHONE STORE NEVER GAINS THE PRINCE BY
    /// UPDATE** (her word: "the phone mirrors: its first-write occasion seeds
    /// the launch book on a fresh store only"). A phone store an earlier build
    /// furnished — its first write minted Sherlock and spent the Journal's
    /// occasion; her note since — meets this build's launch: `prime` reads a
    /// store that has held writing, and her next first write DECLINES the
    /// Prince (`.existingStore`, recorded), leaving the store as it was.
    /// *Old (behavioural revert: `seedsFreshStoresOnly: false` on the
    /// Prince):* the occasion seeded the Prince — its own mark was unset.
    @Test func anExistingPhoneStoreNeverGainsThePrince() async throws {
        try await withEditorWorld { session, db in
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            // The earlier build's furniture: Sherlock, then her own note.
            let sherlock = SampleLibrarySeeder.Book.sherlock
            let stories = try SampleLibrarySeeder.loadStories(for: sherlock)
            let found = try await db.read { db in try SampleLibrarySeeder.discover(db, book: sherlock) }
            _ = try await SampleLibrarySeeder.seed(
                session: session, book: sherlock, stories: stories, existing: found)
            _ = try await session.runner.run { ops in
                let post = try ops.createPost(title: "my phone note")
                return try ops.newBlock(in: post.id, text: "From before the Prince.").variant.id
            }

            let marks = Marks()
            marks.journal = true    // that build spent the Journal's occasion
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()
            guard case .ran(_, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            #expect(sample == .existingStore, "\(sample)")
            #expect(marks.sample, "the decision is recorded on this device")
            let (names, princeEver) = try await db.read { db in
                (try Queries.readings(db).map(\.name),
                 try Queries.readingTombstoneExists(db, name: SampleLibrarySeeder.Book.launchBook.name))
            }
            #expect(!names.contains(SampleLibrarySeeder.Book.launchBook.name) && !princeEver,
                    "no Prince — not a row of its name")
            #expect(names.contains(sherlock.name), "her Sherlock untouched")
        }
    }

    /// **RED ON OLD — NEVER A GUESS THAT SEEDS.** An occasion whose launch
    /// facts were never taken (`prime` never ran, or its read failed) reads
    /// the store as NOT fresh — the starter Journal's never-a-guess rule —
    /// so even an empty store gets no Prince from it: `.existingStore`.
    /// *Old:* the Prince seeded regardless (no guard).
    @Test func anUnprimedOccasionSeedsNoPrince() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            guard case .ran(let journal, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            #expect(journal == nil, "no verdict, no Journal")
            #expect(sample == .existingStore, "\(sample)")
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty, "nothing minted")
        }
    }

    /// **GUARD — a fresh phone store's STOPPED first write resumes.** The
    /// first write's seed stopped after thirteen notes (a lock killed the
    /// occasion's task: no mark). At the next launch `prime` reads a store
    /// that holds writing — the seed's own rows and her note — but the
    /// Prince's OWN partial copy is completed, never stranded: the next
    /// first write mints the missing fourteen into the same book.
    @Test func aStoppedFirstWriteSeedResumesThePrince() async throws {
        try await withEditorWorld { session, db in
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            let book = SampleLibrarySeeder.Book.launchBook
            let stories = try SampleLibrarySeeder.loadStories(for: book)
            let fresh = try await db.read { db in try SampleLibrarySeeder.discover(db, book: book) }
            let partial = try await SampleLibrarySeeder.seed(
                session: session, book: book, stories: Array(stories.prefix(13)), existing: fresh)
            _ = try await session.runner.run { ops in
                let post = try ops.createPost(title: "the note that summoned it")
                return try ops.newBlock(in: post.id, text: "Hello.").variant.id
            }

            let marks = Marks()
            marks.journal = true
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()
            guard case .ran(_, let sample) = await furniture.run(),
                  case .seeded(let readingID, let minted) = sample
            else {
                Issue.record("the stopped seed resumes")
                return
            }
            #expect(readingID == partial.readingID && minted == 14, "the same book, the missing fourteen")
            #expect(marks.sample)
            let members = try await db.read { db in
                try Queries.assembleReading(db, readingID: readingID).count
            }
            #expect(members == 28, "the whole book")
        }
    }

    // MARK: 13s-b U1b (R-13s-5/37) — Encryption Explained left the default seed

    /// **JUSTIFIED EDIT of pre-13x 5a's seeds-the-encryption-book pin — the
    /// SUBJECT RETIRED at her R-13s-37 ("encryption explained not present
    /// and not restorable"), on the R-17y-8 Jekyll precedent (her ruling
    /// names people's libraries, and a phone-seeded copy re-arrives
    /// everywhere by sync):** the first-write occasion seeds NO *Encryption
    /// Explained* — no reading of the name, no tombstone of the name (never
    /// minted-then-removed). An existing store that already holds it keeps
    /// it (nothing retrofits — the seed simply never asks). The Mac's
    /// launch pin (`aFreshLaunchSeedsTheFinalSet`) is the class's
    /// red-on-old.
    @Test func theOccasionSeedsNoEncryptionBook() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            guard case .ran = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            let (book, tombstoned) = try await db.read { db in
                (try Queries.readings(db).first {
                    $0.name == SampleLibraryEncryptionBook.name && $0.deletedAt == nil
                 },
                 try Queries.readingTombstoneExists(
                    db, name: SampleLibraryEncryptionBook.name))
            }
            #expect(book == nil, "no Encryption Explained in a fresh phone library (R-13s-37)")
            #expect(!tombstoned, "never minted at all")
        }
    }

    // MARK: 17y B-DEDUPE (R-17y-8) — Jekyll left the phone's default seed

    /// **JUSTIFIED EDIT of 18l-c U6's seeds-Jekyll pin — the SUBJECT
    /// RETIRED at her R-17y-8 ("I don't want it in people's libraries
    /// anymore"):** the first-write occasion seeds the DEFAULT SUBSET and
    /// NO Jekyll — no reading of the name, no tombstone of the name (never
    /// minted-then-removed), takemania nowhere. The Mac's launch pin
    /// (`aFreshLaunchSeedsTheSubsetWithoutJekyll`) is the class's
    /// red-on-old; an existing store that already holds Jekyll keeps it
    /// (nothing retrofits — the seed simply never asks).
    @Test func theOccasionSeedsNoJekyll() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            guard case .ran = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            let (jekyll, tombstoned, takemania) = try await db.read { db in
                (try Queries.readings(db).first {
                    $0.name == SampleLibraryJekyllBook.name && $0.deletedAt == nil
                 },
                 try Queries.readingTombstoneExists(db, name: SampleLibraryJekyllBook.name),
                 try String.fetchOne(
                    db,
                    sql: "SELECT id FROM container WHERE title = ? AND deleted_at IS NULL",
                    arguments: [Takemania.title]))
            }
            #expect(jekyll == nil, "no Jekyll in a fresh phone library (R-17y-8)")
            #expect(!tombstoned, "never minted at all")
            #expect(takemania == nil, "takemania left with its book")
        }
    }
}
