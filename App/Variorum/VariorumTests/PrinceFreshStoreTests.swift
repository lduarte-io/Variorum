//
//  PrinceFreshStoreTests.swift
//  VariorumTests
//
//  VX-633 U2b — R-633-16, her D1 ruling (2026-10-28 sitting): **FRESH STORES
//  ONLY.** "Existing stores are untouched at the release — the Prince seeds
//  only on a fresh store's launch road; an existing store (hers, the testers')
//  gets it via Help ▸ Restore "the prince", which arranges it properly."
//  (`notes/plans/vx-633-prince-book.md`; the rule and its reasons:
//  `SampleLibraryFreshStore.swift`.)
//
//  Driven through the PRODUCTION composition where the subject is the launch
//  (`LaunchFurniture.seed`, the very function `VariorumApp`'s window task
//  calls) and through the seeder's own door where it is the brain. Marks are
//  injected everywhere — the test host IS the Debug app's defaults domain.
//
//  The verification method is BEHAVIOURAL REVERT (a ruled change, not a bug):
//  set `seedsFreshStoresOnly: false` on `Book.prince` and every pin marked RED
//  ON OLD reds — the U2 tree's behaviour, which seeded the Prince into every
//  existing store at its next launch (plain under its marks; ARRANGED under
//  lost ones). The fresh side of the ruling is `LaunchFurnitureTests`'
//  `aFreshLaunchSeedsTheFinalSet` (the Prince owned, on Welcome, #classics),
//  green on both trees, plus the gathering guard below.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withFreshStoreWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1633))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // Both session mark leaves injected (the restore road reads and
        // WRITES them; production's write the test host's defaults).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

/// One DEVICE's marks, defaults-free. A new device holds none.
@MainActor
private final class Device {
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

    func load(_ book: SampleLibrarySeeder.Book) -> () -> Bool { { [self] in books[book.name] ?? false } }
    func save(_ book: SampleLibrarySeeder.Book) -> (Bool) -> Void { { [self] in books[book.name] = $0 } }
}

@MainActor
private final class FirstRound {
    var started = false
    var landed = false
}

private func signedOut() -> SampleLibrarySeeder.SyncGate {
    SampleLibrarySeeder.SyncGate(belongsToAnAccount: { false }, hasSyncedCleanly: { true })
}

private let prince = SampleLibrarySeeder.Book.prince

@MainActor
private func poll(_ condition: @MainActor () -> Bool, turns: Int = 600) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// **An EXISTING store as an earlier build left it** — that build's launch
/// seeded Sherlock (on `device` when one is given: its mark set), and she has
/// written a note of her own. Returns her note.
@MainActor
private func anEarlierBuildsStore(_ session: AppSession, device: Device? = nil) async throws -> String {
    let sherlock = SampleLibrarySeeder.Book.sherlock
    let marks = device ?? Device()   // nil: that device's marks are gone
    let outcome = await SampleLibrarySeeder.seedIfNeeded(
        session: session, book: sherlock, loadMark: marks.load(sherlock), saveMark: marks.save(sherlock))
    guard case .seeded = outcome else {
        Issue.record("the earlier build's launch seeded Sherlock: \(outcome)")
        return ""
    }
    let note = try session.operations.createPost(title: "my own note")
    _ = try session.operations.newBlock(in: note.id, text: "Mine, from before the Prince.", registeringUndo: false)
    return note.id
}

/// What the store holds of the Prince: a live copy's id, and whether a row
/// of its name was EVER minted (live or tombstoned).
private func princeFacts(_ db: AppDatabase) async throws -> (live: String?, everMinted: Bool) {
    try await db.read { db in
        let live = try Queries.readings(db).first { $0.name == prince.name }?.id
        let dead = try Queries.readingTombstoneExists(db, name: prince.name)
        return (live, live != nil || dead)
    }
}

private func readingNamed(_ db: AppDatabase, _ name: String) async throws -> Reading? {
    try await db.read { db in try Queries.readings(db).first { $0.name == name } }
}

private func welcomeShelves(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL") ?? 0
    }
}

@MainActor
@Suite("The Prince seeds fresh stores only — R-633-16 (VX-633 U2b)")
struct PrinceFreshStoreTests {

    // MARK: - The rule itself

    /// **What "fresh" reads** (`SampleLibraryFreshStore`): never held a note,
    /// a snippet or a book — live OR in the Trash — but a gathering never
    /// counts and the seed's own book row never counts; and the decision
    /// table: a settled store never mints, the seed's own partial copy
    /// resumes, a fresh store seeds.
    @Test func theFreshStoreRuleReadsWritingNeverFurniture() async throws {
        func fresh(_ db: AppDatabase) async throws -> Bool {
            try await db.read { db in try SampleLibraryFreshStore.storeIsFresh(db, ownBook: prince.name) }
        }
        try await withFreshStoreWorld { session, db in
            let ops = session.operations
            #expect(try await fresh(db), "an empty store")
            _ = ops.ensureStarredNotesGathering()
            #expect(try await fresh(db), "a gathering holds nothing — the launch's own furniture never counts")
            let own = try ops.createReading(name: prince.name, kind: .book)
            #expect(try await fresh(db), "the seed's own book row never counts")
            try ops.deleteReading(own.id)
            let hers = try ops.createReading(name: "my reading list", kind: .book)
            #expect(try await !fresh(db), "a book of hers, even empty")
            try ops.deleteReading(hers.id)
            #expect(try await !fresh(db), "…even in the Trash")
        }
        try await withFreshStoreWorld { session, db in
            let note = try session.operations.createPost(title: "a note")
            #expect(try await !fresh(db), "a note")
            try session.operations.deleteContainer(note.id)
            #expect(try await !fresh(db), "…even in the Trash")
        }
        // The decision table.
        typealias R = SampleLibraryFreshStore
        #expect(!R.mayMint(.settled, resuming: true) { true }, "a settled store never mints — not even a resume")
        #expect(R.mayMint(.readAtDecision, resuming: false) { true })
        #expect(!R.mayMint(.readAtDecision, resuming: false) { false })
        #expect(R.mayMint(.readAtDecision, resuming: true) { false }, "the seed's own partial copy completes")
        #expect(R.mayMint(.takenAtLaunch(true), resuming: false) { false }, "the phone's fact, not a read")
        #expect(!R.mayMint(.takenAtLaunch(false), resuming: false) { true })
        #expect(R.mayMint(.takenAtLaunch(false), resuming: true) { false })
        #expect(R.isResuming(bookExists: true, presentTitles: ["about this text"], shippedTitles: ["about this text", "Dedication"]))
        #expect(!R.isResuming(bookExists: true, presentTitles: ["her note"], shippedTitles: ["about this text", "Dedication"]),
                "a book of hers sharing the name is not the seed's copy")
        #expect(!R.isResuming(bookExists: false, presentTitles: [], shippedTitles: ["about this text"]))
        // Scoped to the Prince: every other book keeps the no-guard doctrine.
        #expect(prince.seedsFreshStoresOnly)
        for book in SampleLibrarySeeder.Book.all where book != prince {
            #expect(!book.seedsFreshStoresOnly, "\(book.name): byte-unchanged")
        }
    }

    // MARK: - Existing stores are untouched (the Mac's launch)

    /// **RED ON OLD — HER STORE, AND THE TESTERS'.** An existing store on the
    /// device that has launched it before (Sherlock's mark set, the Welcome
    /// mark settled — `declined` on a store older than the arrangement, `done`
    /// on one born arranged): the release's launch mints NO Prince — never a
    /// row of its name — and records the decision; nothing is arranged. Then
    /// her road: Help ▸ Restore “the prince” mints it whole and arranges it
    /// (owned, on Welcome, every note #classics). *Old:* the launch minted
    /// the Prince PLAIN — unowned, unshelved, its notes without #classics.
    @Test(arguments: ["declined", "done"])
    func anExistingStoreNeverGainsThePrinceAtLaunch(_ settled: String) async throws {
        try await withFreshStoreWorld { session, db in
            let device = Device()
            _ = try await anEarlierBuildsStore(session, device: device)
            device.welcome = settled

            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks)
            #expect(outcome == .alreadySettled)
            #expect(try await princeFacts(db).everMinted == false, "no Prince — not a row of its name")
            #expect(device.books[prince.name] == true, "the decision is recorded on this device")
            let sherlock = try #require(try await readingNamed(db, SampleLibrarySeeder.Book.sherlock.name))
            #expect(!sherlock.owned && sherlock.shelfId == nil, "nothing arranged")

            // A second launch reads the mark and stops before the parse.
            #expect(await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks) == .alreadySettled)
            #expect(try await princeFacts(db).everMinted == false)

            // HER ROAD: Help ▸ Restore “the prince”, arranged by the door.
            guard settled == "declined" else { return }
            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.restorePrinceBook()
            await poll { session.status.spoken != nil || session.status.current != nil }
            #expect(session.status.spoken?.text.hasPrefix(
                SeededBookReceipt.restored(book: prince.name, unit: .chapter, minted: 27)) == true,
                    "the receipt: \(session.status.spoken?.text ?? "nil")")
            try await db.read { db in
                let book = try #require(try Queries.readings(db).first { $0.name == prince.name })
                #expect(book.owned, "owned — the arrangement the door composes")
                let welcome = try #require(try Shelf.fetchOne(
                    db, sql: "SELECT * FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL"))
                #expect(book.shelfId == welcome.id, "on Welcome")
                let notes = try Queries.assembleReading(db, readingID: book.id).map(\.postID)
                #expect(notes.count == 28, "the whole book: the front note and 27 chapters")
                let unclassic = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM reading_post rp
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                          AND NOT EXISTS (SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                                          WHERE pt.post_id = rp.post_id AND t.path = ?
                                            AND pt.deleted_at IS NULL AND t.deleted_at IS NULL)
                        """,
                    arguments: [book.id, SampleLibrarySeeder.classicsTagPath]) ?? -1
                #expect(unclassic == 0, "every note #classics")
            }
        }
    }

    /// **RED ON OLD — THE LOST-MARKS STORE** (a reinstall, or her store moved
    /// to a new Mac: the store comes back, this device's defaults do not).
    /// Store truth decides: it holds writing, so the launch declines — no
    /// Prince, the decision recorded — and the Welcome arrangement is NOT a
    /// birth: no Welcome shelf, no field guide grown, Sherlock untouched.
    /// *Old:* the Prince minted all 27, which the birth decision reads as a
    /// fresh store's — so her existing library was silently ARRANGED (Welcome
    /// minted, the field guide seeded, Sherlock owned): the retrofit the
    /// arrangement exists to refuse.
    @Test func anExistingStoreWithLostMarksIsNeitherSeededNorArranged() async throws {
        try await withFreshStoreWorld { session, db in
            _ = try await anEarlierBuildsStore(session)   // its device marks are gone
            let device = Device()                          // a new device: no marks at all

            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks)
            #expect(outcome == .declined, "an existing store's launch is not a birth")
            #expect(device.welcome == "declined")
            #expect(device.books[prince.name] == true, "the Prince's decision is recorded")
            #expect(try await princeFacts(db).everMinted == false, "no Prince")
            #expect(try await welcomeShelves(db) == 0, "nothing arranged")
            #expect(try await readingNamed(db, TutorialSeeder.bookName) == nil, "no field guide grown")
            #expect(try await readingNamed(db, SampleLibrarySeeder.Book.sherlock.name)?.owned == false,
                    "Sherlock untouched")
        }
    }

    /// **RED ON OLD — A NEW LIBRARY ON A USED MAC** (the per-Mac seeding
    /// doctrine her R-510-25 kept: a device that has seeded does not seed
    /// again — before VX-633 its Sherlock mark said so). The device settled
    /// its launch before, so even an EMPTY store gets no Prince at launch;
    /// the doors are its road. *Old:* the Prince minted plain (its own mark
    /// was unset), unarranged.
    @Test func aDeviceThatSettledItsLaunchSeedsNoPrinceIntoANewLibrary() async throws {
        try await withFreshStoreWorld { session, db in
            let device = Device()
            device.books[SampleLibrarySeeder.Book.sherlock.name] = true
            device.welcome = "done"
            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks)
            #expect(outcome == .alreadySettled)
            let facts = try await princeFacts(db)
            #expect(facts.everMinted == false)
            #expect(device.books[prince.name] == true)
        }
    }

    /// **RED ON OLD — HER OWN BOOK OF THE SAME NAME.** Discovery finds a book
    /// by its reserved name, so a store holding her own "the prince" (her
    /// note in it) used to have the 27 chapters poured INTO her book. Now her
    /// book is not the seed's partial copy (it holds none of the titles the
    /// seed ships) and the store has held writing: declined, recorded, her
    /// book exactly as she left it.
    @Test func herOwnBookOfTheSameNameIsNeverFilled() async throws {
        try await withFreshStoreWorld { session, db in
            let ops = session.operations
            let hers = try ops.createReading(name: prince.name, kind: .book)
            let note = try ops.createPost(title: "notes on machiavelli")
            _ = try ops.newBlock(in: note.id, text: "Read it in school.", registeringUndo: false)
            _ = try ops.addPostToReading(note.id, to: hers.id)
            let device = Device()

            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince, loadMark: device.load(prince), saveMark: device.save(prince))
            #expect(outcome == .existingStore, "\(outcome)")
            #expect(device.books[prince.name] == true)
            let members = try await db.read { db in
                try Queries.assembleReading(db, readingID: hers.id).map(\.postID)
            }
            #expect(members == [note.id], "her book, exactly as she left it")
        }
    }

    // MARK: - The account road (judged after the sync gate)

    /// **RED ON OLD — THE EARLY READ DECLINES.** An account store already
    /// holding writing declines at the launch's FIRST read — it neither
    /// spends the gate's wait nor leaves the decision unrecorded. *Old:*
    /// `.awaitingFirstSync`, nothing recorded (and, once a round landed, the
    /// Prince minted into her library).
    @Test func anAccountStoreHoldingWritingDeclinesWithoutWaiting() async throws {
        try await withFreshStoreWorld { session, db in
            _ = try session.operations.createPost(title: "hers")
            let device = Device()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince,
                gate: SampleLibrarySeeder.SyncGate(belongsToAnAccount: { true }, hasSyncedCleanly: { false }),
                firstRoundWait: .milliseconds(30), pollInterval: .milliseconds(5),
                loadMark: device.load(prince), saveMark: device.save(prince))
            #expect(outcome == .existingStore, "\(outcome)")
            #expect(device.books[prince.name] == true, "recorded now")
            #expect(try await princeFacts(db).everMinted == false)
        }
    }

    /// **RED ON OLD — A NEW DEVICE JOINING HER LIBRARY.** The store is empty
    /// when the launch first looks; her library arrives IN the first clean
    /// round the gate waits for. The latch's deciding read is taken after the
    /// wait, so the store is judged by what the round brought — an existing
    /// library — and the Prince is never seeded into it (nor, at the launch,
    /// arranged). *Old:* `.seeded` — the Prince minted into her library, to
    /// travel to every device.
    @Test func anAccountStoreIsJudgedByWhatItsFirstRoundBrought() async throws {
        try await withFreshStoreWorld { session, db in
            let device = Device()
            let round = FirstRound()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true },
                    hasSyncedCleanly: {
                        // The first ask starts "the round": her library lands.
                        if !round.started {
                            round.started = true
                            Task { @MainActor in
                                let note = try? session.operations.createPost(title: "from her other Mac")
                                if let note {
                                    _ = try? session.operations.newBlock(
                                        in: note.id, text: "Synced.", registeringUndo: false)
                                }
                                round.landed = true
                            }
                        }
                        return round.landed
                    }),
                firstRoundWait: .seconds(60), pollInterval: .milliseconds(5),
                loadMark: device.load(prince), saveMark: device.save(prince))
            #expect(round.landed, "the round landed before the launch decided")
            #expect(outcome == .existingStore, "\(outcome)")
            #expect(device.books[prince.name] == true)
            let facts = try await princeFacts(db)
            #expect(facts.everMinted == false)
        }
    }

    // MARK: - Fresh stores (green on both trees — the guards)

    /// **GUARD — the launch's own furniture never makes a store existing.** A
    /// fresh store whose first launch seeded only its starred-notes gathering
    /// (its Prince seed refused before minting anything — the gathering
    /// seeds right after the launch book) is still FRESH at the next launch:
    /// the Prince seeds whole and the birth is arranged — owned, on Welcome.
    @Test func aFreshStoreHoldingOnlyTheLaunchsGatheringStillGetsThePrinceArranged() async throws {
        try await withFreshStoreWorld { session, db in
            _ = await StarredGatheringSeeder.seedIfNeeded(session: session, loadMark: { false }, saveMark: { _ in })
            let device = Device()
            device.starred = true
            let outcome = await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks)
            guard case .arranged(let arranged) = outcome else {
                Issue.record("a fresh store is arranged at birth: \(String(describing: outcome))")
                return
            }
            #expect(arranged.prince == .owned)
            let book = try #require(try await readingNamed(db, prince.name))
            #expect(book.owned && book.shelfId != nil, "owned, on Welcome")
            #expect(try await db.read { db in try Queries.assembleReading(db, readingID: book.id).count } == 28)
        }
    }

    /// **GUARD — a fresh store's STOPPED launch resumes.** The first launch
    /// stopped after thirteen notes (the window closed mid-seed: no mark, no
    /// Welcome decision). Its own rows now read as writing, but they are the
    /// seed's own partial copy, so the next launch completes the book — every
    /// chapter, every one bilingual. (Whether that launch then ARRANGES is
    /// U7's own rule — a resumed seed is not a birth, `SampleLibraryWelcome
    /// Tests.theLaunchMarksDecideAndResume` — not this ruling's.)
    @Test func aFreshStoresStoppedLaunchResumesThePrince() async throws {
        try await withFreshStoreWorld { session, db in
            let stories = try SampleLibrarySeeder.loadStories(for: prince)
            let fresh = try await db.read { db in try SampleLibrarySeeder.discover(db, book: prince) }
            let partial = try await SampleLibrarySeeder.seed(
                session: session, book: prince, stories: Array(stories.prefix(13)), existing: fresh)
            #expect(partial.minted == 13)
            #expect(try await db.read { db in
                try SampleLibraryFreshStore.storeIsFresh(db, ownBook: prince.name)
            } == false, "its own rows read as writing — only the resume road completes it")

            let device = Device()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev, gate: signedOut(), marks: device.marks)
            #expect(device.books[prince.name] == true)
            let readingID = partial.readingID
            try await db.read { db in
                let entries = try Queries.assembleReading(db, readingID: readingID)
                #expect(entries.count == 28, "the whole book")
                let last = try #require(entries.last)
                #expect(last.title == "XXVI. An exhortation to liberate Italy from the barbarians")
                let italian = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                        WHERE cb.container_id = ? AND v.label = ? AND v.deleted_at IS NULL
                        """,
                    arguments: [last.postID, SampleLibraryPrinceBook.italianTakeLabel]) ?? 0
                #expect(italian == 11, "a resumed chapter carries its Italian on every block")
            }
        }
    }

    /// **GUARD — every other book keeps the no-guard doctrine, byte-unchanged.**
    /// A store already holding her writing still seeds Sherlock and Jekyll
    /// (their own launch-road behaviour; neither is in the launch set now,
    /// but their road is untouched), and the Prince alone declines.
    @Test func everyOtherBookStillSeedsAStoreHoldingWriting() async throws {
        try await withFreshStoreWorld { session, db in
            _ = try session.operations.createPost(title: "hers")
            let device = Device()
            for book in [SampleLibrarySeeder.Book.sherlock, .jekyllAndHyde] {
                let outcome = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book, loadMark: device.load(book), saveMark: device.save(book))
                guard case .seeded = outcome else {
                    Issue.record("\(book.name) still seeds an existing store: \(outcome)")
                    continue
                }
            }
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince, loadMark: device.load(prince), saveMark: device.save(prince))
            #expect(outcome == .existingStore)
            #expect(try await princeFacts(db).everMinted == false)
        }
    }
}
