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
    /// pre-13x 5a: the encryption book's OWN mark beside Sherlock's, with
    /// Sherlock's reading "already seeded" (the half-megabyte parse skipped).
    var encryptionBook = false
    var encryptionBookOnly: MobileFirstWriteFurniture.Marks {
        .init(loadJournal: { [self] in journal },
              saveJournal: { [self] in journal = $0 },
              loadSample: { true }, saveSample: { _ in },
              loadEncryptionBook: { [self] in encryptionBook },
              saveEncryptionBook: { [self] in encryptionBook = $0 })
    }
    // (The Jekyll marks helper left with the phone's Jekyll seed —
    // 17y B-DEDUPE, R-17y-8.)
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
    /// still running the sample library, which has no virgin-store guard.
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
    /// tag on every note.
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
            #expect(stories >= 12, "the twelve adventures")
            #expect(marks.sample)

            let facts = try await db.read { db -> (Int, Int, Bool, Int) in
                let members = try Queries.assembleReading(db, readingID: readingID)
                let chapters = try Queries.readingSections(db, readingID: readingID)
                let tag = try #require(
                    Queries.allTags(db)
                        .first { $0.path == SampleLibrarySeeder.tagName })
                let tagged = try Queries.everythingTagged(db, tagID: tag.id)
                return (members.count, chapters.count,
                        members.contains { $0.title == SampleLibrarySeeder.frontMatterTitle },
                        tagged.postIDs.count)
            }
            #expect(facts.0 == stories + 1, "every story, plus the attribution")
            #expect(facts.1 == facts.0, "one chapter per note — the front matter has one too")
            #expect(facts.2, "the attribution ships with the public-domain text")
            #expect(facts.3 == facts.0, "every note wears her tag")
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
    @Test func theSampleSeedWaitsForPendingWritingToLand() async throws {
        try await withEditorWorld { session, db in
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

            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.both)
            await furniture.prime()
            let occasion = Task { await furniture.run() }

            // While her text has not landed, NOTHING of the library exists —
            // polled well inside the per-turn cap, so this cannot pass by
            // the seed simply being slow.
            let watch = ContinuousClock.now.advanced(by: .milliseconds(400))
            var sampleBookSeen = false
            while ContinuousClock.now < watch {
                try await Task.sleep(for: .milliseconds(25))
                let books = try await db.read { db in try Queries.readings(db) }
                if books.contains(where: { $0.name == SampleLibrarySeeder.bookName }) {
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
            #expect(stories >= 12)
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
            #expect(!books.contains { $0.name == SampleLibrarySeeder.bookName })
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
            #expect(books.contains { $0.name == SampleLibrarySeeder.bookName })
        }
    }

    // MARK: pre-13x 5a — the second seeded book rides the same occasion

    /// *Encryption Explained* seeds on the phone's first-write occasion
    /// beside Sherlock, under its OWN mark; an injected Sherlock mark alone
    /// stands for both (every pin above skips both parses), and the
    /// encryption book's mark, when injected, is its own.
    @Test func theOccasionSeedsTheEncryptionBookUnderItsOwnMark() async throws {
        try await withEditorWorld { session, db in
            let marks = Marks()
            let furniture = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev,
                marks: marks.encryptionBookOnly)
            guard case .ran(_, let sample) = await furniture.run() else {
                Issue.record("expected the occasion to run")
                return
            }
            #expect(sample == .alreadySeeded, "Sherlock's injected mark stands")
            guard case .seeded(let bookID, let chapters) = furniture.encryptionBookOutcome else {
                Issue.record("expected the encryption book to seed, got \(String(describing: furniture.encryptionBookOutcome))")
                return
            }
            #expect(chapters == 8 && marks.encryptionBook)
            let book = try await db.read { db in try Queries.reading(db, id: bookID) }
            #expect(book?.name == SampleLibraryEncryptionBook.name)
            // A second occasion with the mark set seeds nothing more.
            let again = MobileFirstWriteFurniture(
                session: session, storeVariant: .dev, marks: marks.encryptionBookOnly)
            _ = await again.run()
            #expect(again.encryptionBookOutcome == .alreadySeeded)
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
