//
//  LaunchFurnitureTests.swift
//  VariorumTests
//
//  17y B-SEED (item (q), the tutorial-seed trace) — THE LAUNCH'S FURNITURE,
//  driven through the PRODUCTION composition: `LaunchFurniture.seed` is the
//  very function `VariorumApp`'s window task calls, so these pins read what
//  a real first launch leaves in the store (the U7 fresh-birth pin composes
//  its own replica of a launch — which is how a fresh store born without its
//  field guide went unseen; the batch record carries the trace).
//
//  Her report (the 2026-10-04 evening sitting): on a fresh store the field
//  guide was the ONE seeded thing missing — Welcome held the books, the
//  classics gathering and the quicknote, and the guide had to come from
//  Help ▸ Restore Tutorial…. The contract these pins hold:
//
//    · A FRESH store's first launch leaves ONE whole field guide, on the
//      Welcome shelf (the sitting record §19.3 — "Welcome = the field guide +
//      the classics trio"; the 13i-d U7 brief — "fresh stores get it at
//      birth"), silently: no receipt, no ask (R-13r-11), nothing on ⌥⌘Z.
//    · NEVER A RETROFIT: a store that already had its library (`declined`) or
//      was born on an earlier build (`done`) grows no guide at launch — the
//      doors are an existing store's road.
//    · THE SIGNED-IN ROAD mints no guide ahead of its corpus: while the first
//      clean round is pending nothing seeds; once the corpus has arrived its
//      own guide stands alone.
//    · A resumed birth honours her deletion, never replaces tutorial residue
//      silently, and never races a tutorial door already in flight.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withLaunchWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1886))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // The seeded-book marks the restore roads read and write are
        // INJECTED — a headless run never touches the test host's defaults
        // (the test host IS the Debug app's domain).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

/// One DEVICE's marks, defaults-free. A fresh install's device holds none.
@MainActor
private final class DeviceMarks {
    var books: [String: Bool] = [:]
    var starred = false
    var welcome: String?

    var marks: LaunchFurniture.Marks {
        LaunchFurniture.Marks(
            book: { [self] book in
                (load: { self.books[book.name] ?? false },
                 save: { self.books[book.name] = $0 })
            },
            starred: (load: { [self] in starred }, save: { [self] in starred = $0 }),
            welcome: (load: { [self] in welcome }, save: { [self] in welcome = $0 }))
    }
}

private func gate(account: Bool, clean: Bool) -> SampleLibrarySeeder.SyncGate {
    SampleLibrarySeeder.SyncGate(belongsToAnAccount: { account }, hasSyncedCleanly: { clean })
}

/// The guide as the store holds it: every LIVE reading of the reserved name,
/// the role'd Welcome shelves, and the first guide's chapters and lessons in
/// book order (the `TutorialBookShapeTests` reading).
private struct GuideFacts {
    var guides: [Reading]
    var welcomeIDs: [String]
    var chapters: [String]
    var lessons: [String]
}

private func guideFacts(_ db: AppDatabase) async throws -> GuideFacts {
    try await db.read { db in
        let guides = try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName }
        let welcomes = try String.fetchAll(
            db,
            sql: "SELECT id FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL ORDER BY id")
        var chapters: [String] = []
        var lessons: [String] = []
        if let guide = guides.first {
            chapters = try Queries.readingSections(db, readingID: guide.id).map(\.name)
            lessons = try String.fetchAll(
                db,
                sql: """
                    SELECT c.title FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.position, rp.id
                    """,
                arguments: [guide.id])
        }
        return GuideFacts(guides: guides, welcomeIDs: welcomes, chapters: chapters, lessons: lessons)
    }
}

/// A book of the store by its reserved name.
private func reading(_ db: AppDatabase, named name: String) async throws -> Reading? {
    try await db.read { db in try Queries.readings(db).first { $0.name == name } }
}

@MainActor
@Suite("The launch's furniture — the field guide at a fresh store's birth (17y B-SEED)")
struct LaunchFurnitureTests {

    /// **THE DEFECT'S PIN.** A fresh store's FIRST launch, through the
    /// production composition, signed out (no account — every new user, and
    /// every fresh install: the session is device-bound): the field guide is
    /// there, whole, ON the Welcome shelf beside the seeded books — and it
    /// arrived silently. RED ON OLD: nothing on the launch path seeded the
    /// guide, so Welcome held the books and no guide.
    @Test func aFreshStoresFirstLaunchPutsTheFieldGuideOnWelcome() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            guard case .arranged = outcome else {
                Issue.record("a fresh store is arranged at birth: \(String(describing: outcome))")
                return
            }
            #expect(device.welcome == "done")

            let facts = try await guideFacts(db)
            #expect(facts.guides.count == 1, "ONE field guide, born with the store")
            let guide = try #require(facts.guides.first)
            let welcome = try #require(facts.welcomeIDs.first)
            #expect(facts.welcomeIDs.count == 1)
            #expect(guide.shelfId == welcome, "the guide sits on Welcome (§19.3)")
            #expect(guide.wingId == "", "in Home")
            #expect(facts.chapters == TutorialSeeder.plan.map(\.chapter), "every chapter, in order")
            #expect(facts.lessons == TutorialSeeder.plan.flatMap(\.lessons), "every lesson, whole")
            // …beside the rest of the seeded content, unchanged. (Justified
            // edit, 17y B-DEDUPE R-17y-8: Jekyll left the DEFAULT seed;
            // justified again at 13s-b U1b, R-13s-5/37: *Encryption
            // Explained* and the classics gathering left it too — the final
            // set's own pin is aFreshLaunchSeedsTheFinalSet below.)
            for name in [SampleLibrarySeeder.Book.sherlock.name] {
                #expect(try await reading(db, named: name)?.shelfId == welcome, "\(name) on Welcome")
            }
            // Silent furniture: nothing spoken, nothing asked, nothing on ⌥⌘Z.
            #expect(session.status.current == nil && session.status.spoken == nil,
                    "a first launch says nothing (R-13r-11)")
            #expect(session.undoStack.depth == 0, "furniture never lands on her ⌥⌘Z")
            #expect(!session.tutorialDoorInFlight, "the doors' latch is released")

            // The next launch on this device is settled: still ONE guide.
            let again = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            #expect(again == .alreadySettled)
            #expect(try await guideFacts(db).guides.count == 1)
        }
    }

    /// **THE FINAL SET's PIN (13s-b U1b — R-13s-5/26/27/37, her launch list
    /// verbatim: "field guide, sherlock holmes, and a starred notes empty
    /// gathering… quicknotes and journal are created at first mint"; the
    /// example snippet joins at her Q17 disposition).** A fresh store's
    /// first launch leaves EXACTLY: the field guide (the birth pin above) ·
    /// Sherlock, OWNED · the starred-notes gathering, empty · the example
    /// snippet. And NOTHING of the retired seed — no Jekyll (R-17y-8), no
    /// *Encryption Explained*, no classics gathering, no Quicknotes, no
    /// seeded quicknote; none of them minted-then-removed either. RED ON
    /// OLD, per retired fact: the old launch seeded EE, and the old
    /// arrangement minted the classics gathering and the quicknote (which
    /// minted Quicknotes); the old tree had no example snippet.
    @Test func aFreshLaunchSeedsTheFinalSet() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let sherlock = try #require(
                try await reading(db, named: SampleLibrarySeeder.Book.sherlock.name),
                "Sherlock still seeds")
            #expect(sherlock.owned, "…owned (the §7 ladder)")
            let starred = try #require(
                try await reading(db, named: Operations.starredNotesGatheringName),
                "the starred-notes gathering seeds")
            #expect(starred.kind == .gathering && starred.shelfId == nil)
            // The retired seed: absent, and never minted at all.
            for name in [SampleLibrarySeeder.Book.jekyllAndHyde.name,
                         SampleLibrarySeeder.Book.encryptionExplained.name,
                         SampleLibraryWelcome.classicsGatheringName,
                         Operations.defaultQuicknoteBookName] {
                #expect(try await reading(db, named: name) == nil,
                        "no \(name) in a fresh library (R-13s-5/37)")
                let everExisted = try await db.read { db in
                    try Queries.readingTombstoneExists(db, name: name)
                }
                #expect(!everExisted, "\(name) was never minted at all")
            }
            let quicknotes = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND title = ?",
                    arguments: [SampleLibraryWelcome.quicknoteTitle]) ?? 0
            }
            #expect(quicknotes == 0, "no seeded quicknote, live or dead (R-13s-5)")
            // The example snippet: one group, one snippet, her ruled line
            // EXACTLY (R-13s-26) — and the OLDEST group, so the Snippets
            // rail leads with it.
            let (groups, snippetTexts) = try await db.read { db -> ([Container], [String]) in
                let pools = try Queries.pools(db)
                let scrap = pools.first { $0.title == ExampleSnippetSeeder.groupTitle }
                let texts = try scrap.map { pool in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT v.working_text FROM container_block cb
                            JOIN variant v ON v.block_id = cb.block_id AND v.deleted_at IS NULL
                            WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                            ORDER BY cb.position, cb.id
                            """,
                        arguments: [pool.id])
                } ?? []
                return (pools, texts)
            }
            #expect(groups.first?.title == ExampleSnippetSeeder.groupTitle,
                    "the example group is the oldest — the rail's first")
            #expect(snippetTexts == [ExampleSnippetSeeder.snippetText],
                    "one snippet, the standard disclaimer line, byte-exact")
            // The retired books stay in `Book.all` — the dedupe facts' and
            // the surviving doors' vocabulary for the installed base.
            #expect(SampleLibrarySeeder.Book.all.contains(.jekyllAndHyde))
            #expect(SampleLibrarySeeder.Book.all.contains(.encryptionExplained))
            #expect(SampleLibrarySeeder.Book.launchSet == [.sherlock])
        }
    }

    /// **THE README PLACEHOLDER (13s-b U1b — R-13s-39, her exact content;
    /// R-13s-27 the lowercase title; R-13s-29's order with the letter
    /// absent).** A fresh launch leaves ONE bookless Home note titled
    /// "readme", seeded LAST so it tops the Library by recency: her
    /// reference's first half as five blocks, the alternates as REAL takes
    /// on the take-icon block and the "This is the point…" block (displayed
    /// text chosen), her dictated closer the final block — and NOTHING else
    /// (no letter note). RED ON OLD by construction: the old tree seeded no
    /// readme.
    @Test func aFreshLaunchSeedsTheReadmePlaceholderLastWithItsTakes() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let readme = try await db.read { db -> (id: String, created: String)? in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT id, created_at FROM container
                        WHERE kind = 'post' AND title = ? AND deleted_at IS NULL
                        """,
                    arguments: [ReadmeSeeder.title]
                ).map { (id: $0["id"] as String, created: $0["created_at"] as String) }
            }
            let (id, created) = try #require(readme, "the readme placeholder seeds")
            // Bookless, undated, in Home — a standalone note (R-13s-27).
            let (membered, entryDate, wing, rendered) = try await db.read { db in
                (try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM reading_post WHERE post_id = ? AND deleted_at IS NULL)",
                    arguments: [id]) ?? false,
                 try String.fetchOne(
                    db, sql: "SELECT entry_date FROM container WHERE id = ?", arguments: [id]),
                 try String.fetchOne(
                    db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [id]) ?? "",
                 try Queries.renderedText(db, containerID: id))
            }
            #expect(!membered, "bookless — Pool/Library, no book")
            #expect(entryDate == nil && wing == "")
            // The DISPLAYED page is the five paragraphs, byte-exact (the
            // chosen takes are the originals). The window's first run
            // corrected this ORACLE: `renderedText` joins blocks with a
            // BLANK line (`joinRenderedTexts`' separator — the page reads
            // with paragraph breaks), not "\n"; the stored text was
            // byte-exact all along.
            #expect(rendered == ReadmeSeeder.paragraphs.joined(separator: "\n\n"))
            // The alternates are REAL takes on their ruled blocks, in fan
            // order after the chosen original, byte-exact.
            let fans = try await db.read { db -> [Int: [String]] in
                let blocks = try String.fetchAll(
                    db,
                    sql: """
                        SELECT block_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        ORDER BY position, id
                        """,
                    arguments: [id])
                var fans: [Int: [String]] = [:]
                for (index, blockID) in blocks.enumerated() {
                    fans[index] = try String.fetchAll(
                        db,
                        sql: """
                            SELECT working_text FROM variant
                            WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                            ORDER BY fan_position, id
                            """,
                        arguments: [blockID])
                }
                return fans
            }
            #expect(fans.count == ReadmeSeeder.paragraphs.count, "her five blocks + the four Start Here passages (VX-306, P-VX306-W-1)")
            for (index, texts) in fans {
                let expected = [ReadmeSeeder.paragraphs[index]] + (ReadmeSeeder.takes[index] ?? [])
                #expect(texts == expected, "block \(index)'s fan, chosen first, byte-exact")
            }
            // Seeded LAST: the newest seeded thing a fresh Library meets —
            // every other container of the seed was created strictly before.
            let newest = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT MAX(created_at) FROM container
                        WHERE deleted_at IS NULL AND id <> ?
                        """,
                    arguments: [id])
            }
            #expect(newest.map { $0 < created } == true, "the readme tops the Library by recency")
            // And no letter note (R-13s-39: "no letter and nothing else").
            let posts = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT COALESCE(title, '') FROM container
                        WHERE kind = 'post' AND deleted_at IS NULL
                          AND created_at >= ?
                        """,
                    arguments: [created])
            }
            #expect(posts == [ReadmeSeeder.title], "nothing seeds after the readme")
        }
    }

    /// **NEVER A RETROFIT** (the `declined` mark's contract). An existing
    /// store that already had its library is declined at launch and grows no
    /// guide; a store born on an earlier build (`done`, no guide) stays as it
    /// is too — the doors (Help ▸ Open the Tutorial, Help ▸ Restore
    /// Tutorial…) are an existing store's road.
    @Test func anExistingStoreGrowsNoGuideAtLaunch() async throws {
        try await withLaunchWorld { session, db in
            // An older build's launch: the books seeded, this device marked.
            let device = DeviceMarks()
            for book in SampleLibrarySeeder.Book.all {
                _ = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book,
                    loadMark: { false }, saveMark: { device.books[book.name] = $0 })
            }
            let declined = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            #expect(declined == .declined)
            let facts = try await guideFacts(db)
            #expect(facts.guides.isEmpty, "no guide grows on an existing store")
            #expect(facts.welcomeIDs.isEmpty, "and nothing is arranged")
        }
        try await withLaunchWorld { session, db in
            // A store born on a U7–13r build: arranged (`done`) without a guide.
            let device = DeviceMarks()
            device.welcome = "done"
            let settled = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            #expect(settled == .alreadySettled)
            let facts = try await guideFacts(db)
            #expect(facts.guides.isEmpty, "a settled store is never retrofitted")
        }
    }

    /// **THE SIGNED-IN ROAD.** (a) While the store's first clean round is
    /// pending, nothing seeds — no books, no guide — and nothing is marked
    /// (the next launch asks again). (b) Once her corpus has arrived (the
    /// books and her own field guide), the launch declines and her guide
    /// stands ALONE. (c) An account whose corpus holds a guide but no
    /// Sherlock reads fresh — and the birth seed finds her guide and seeds
    /// none: one guide, now on Welcome.
    @Test func theSignedInRoadMintsNoGuideAheadOfItsCorpus() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            let pending = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: true, clean: false), marks: device.marks,
                firstRoundWait: .milliseconds(20))
            #expect(pending == .undecided)
            #expect(device.welcome == nil && device.books.isEmpty, "nothing marked")
            let readings = try await db.read { db in try Queries.readings(db) }
            #expect(readings.isEmpty, "no books and no guide ahead of the corpus")
        }
        try await withLaunchWorld { session, db in
            // Her corpus, arrived by sync: the books and her own guide.
            for book in SampleLibrarySeeder.Book.all {
                _ = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book, loadMark: { false }, saveMark: { _ in })
            }
            let hers = try await TutorialSeeder.restore(session: session)
            let device = DeviceMarks()      // a NEW device: no marks at all
            let declined = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: true, clean: true), marks: device.marks)
            #expect(declined == .declined)
            #expect(try await guideFacts(db).guides.map(\.id) == [hers], "her guide, alone")
        }
        try await withLaunchWorld { session, db in
            let hers = try await TutorialSeeder.restore(session: session)
            let device = DeviceMarks()
            let arranged = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: true, clean: true), marks: device.marks)
            guard case .arranged = arranged else {
                Issue.record("no Sherlock in the corpus reads fresh: \(String(describing: arranged))")
                return
            }
            let facts = try await guideFacts(db)
            #expect(facts.guides.map(\.id) == [hers], "never a second guide beside hers")
            #expect(facts.guides.first?.shelfId == facts.welcomeIDs.first, "hers, on Welcome")
        }
    }

    /// **A RESUMED BIRTH** (the `pending` mark — a first launch cut short)
    /// honours what happened in between: (a) a guide she DELETED is never
    /// re-made — the whole guide (book, lessons, scraps: nothing live is
    /// left, so the TOMBSTONE alone is her word) and the book alone (its
    /// lessons survive tagged — residue); (b) tutorial RESIDUE — a note
    /// tagged exactly `tutorial`, no guide book — is never replaced silently
    /// (that is the doors' confirmed road), and her note is untouched; (c) a
    /// guide the interrupted launch already made is not made twice.
    @Test func aResumedBirthHonoursHerDeletionAndLeavesResidueAlone() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            device.welcome = "pending"
            _ = try await TutorialSeeder.restore(session: session)
            // She deletes the WHOLE guide — the book, every lesson, the
            // scraps pool (the doors' own cleanup, i.e. tombstones only).
            let everything = try await db.read { db in try TutorialSeeder.discover(db) }
            TutorialSeeder.cleanup(ops: session.operations, existing: everything)
            let left = try await db.read { db in try TutorialSeeder.discover(db) }
            #expect(left.isEmpty, "no live trace of the guide is left — only its tombstones")
            let resumed = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            guard case .arranged = resumed else {
                Issue.record("a pending mark resumes: \(String(describing: resumed))")
                return
            }
            let facts = try await guideFacts(db)
            #expect(facts.guides.isEmpty, "her deletion stands — the tombstone is her word")
        }
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            device.welcome = "pending"
            let guide = try await TutorialSeeder.restore(session: session)
            try session.operations.deleteReading(guide)
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let facts = try await guideFacts(db)
            #expect(facts.guides.isEmpty, "the book alone deleted: still not re-made")
        }
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            device.welcome = "pending"
            let tag = try session.operations.createTag(name: TutorialSeeder.tagName)
            let hers = try session.operations.createPost(title: "my notes on the tutorial")
            _ = try session.operations.newBlock(in: hers.id, text: "mine", registeringUndo: false)
            _ = try session.operations.applyTag(tag.id, toPost: hers.id)
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            #expect(try await guideFacts(db).guides.isEmpty, "residue is never replaced silently")
            let stillHers = try await db.read { db in
                try Queries.everythingTagged(db, tagID: tag.id, includeSubtree: false).postIDs
            }
            #expect(stillHers == [hers.id], "her tagged note is untouched")
        }
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            device.welcome = "pending"
            let made = try await TutorialSeeder.restore(session: session)
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            #expect(try await guideFacts(db).guides.map(\.id) == [made], "never twice")
        }
    }

    /// **NEVER RACES A DOOR.** A tutorial door already in flight (it seeds
    /// and arranges the guide itself) makes the launch's guide seed yield —
    /// the doors' own latch, so the two can never mint two guides.
    @Test func aTutorialDoorInFlightIsNeverRacedByTheLaunch() async throws {
        try await withLaunchWorld { session, db in
            #expect(session.beginTutorialDoor(), "a door holds the latch")
            defer { session.endTutorialDoor() }
            let device = DeviceMarks()
            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            guard case .arranged = outcome else {
                Issue.record("the arrangement still runs: \(String(describing: outcome))")
                return
            }
            let facts = try await guideFacts(db)
            #expect(facts.guides.isEmpty, "the launch left the guide to the door")
            #expect(session.tutorialDoorInFlight, "and never released the door's latch")
        }
    }

    /// **THE BIRTH SEED'S DECISION TABLE, branch by branch** (driven direct,
    /// so each guard is pinned on its own rather than masked by its
    /// neighbour — a deleted book leaves tagged lessons, which is also
    /// residue): a store with no trace seeds; a live guide is found; the
    /// whole guide deleted is her word; residue is left alone; a door in
    /// flight is never raced.
    @Test func theBirthSeedNamesWhatItFound() async throws {
        try await withLaunchWorld { session, _ in
            guard case .seeded = await TutorialSeeder.seedAtBirth(session: session) else {
                Issue.record("an empty store is seeded")
                return
            }
            #expect(await TutorialSeeder.seedAtBirth(session: session) == .alreadyPresent)
            let everything = try await session.database.read { db in try TutorialSeeder.discover(db) }
            TutorialSeeder.cleanup(ops: session.operations, existing: everything)
            #expect(await TutorialSeeder.seedAtBirth(session: session) == .deletedByTheReader)
        }
        try await withLaunchWorld { session, _ in
            let tag = try session.operations.createTag(name: TutorialSeeder.tagName)
            let hers = try session.operations.createPost(title: "mine")
            _ = try session.operations.applyTag(tag.id, toPost: hers.id)
            #expect(await TutorialSeeder.seedAtBirth(session: session) == .residue)
            #expect(session.beginTutorialDoor())
            #expect(await TutorialSeeder.seedAtBirth(session: session) == .doorInFlight)
            session.endTutorialDoor()
        }
    }
}
