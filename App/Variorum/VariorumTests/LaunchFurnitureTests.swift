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
private func pollUntil(_ condition: @MainActor () -> Bool, turns: Int = 600) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// The live readme's id, if one seeded.
private func readmeID(_ db: AppDatabase) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT id FROM container WHERE kind = 'post' AND title = ? AND deleted_at IS NULL",
            arguments: [ReadmeSeeder.title])
    }
}

/// **Her text, from the package it arrived in** (VX-105, R-105-6 — "the
/// read-me.txt paragraphs as the file carries them"): `read-me.txt` in the
/// repo, its working header line (`{t:"readmev5"} {#readme}`) dropped, split
/// at its blank lines. The test reads the FILE rather than a transcription, so
/// the oracle is the package itself.
private func herReadmeFileParagraphs() throws -> [String] {
    let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum
        .deletingLastPathComponent()  // App
        .deletingLastPathComponent()  // the repo
        .appendingPathComponent("notes/plans/vx-105-letter-content/read-me.txt")
    var lines = try String(contentsOf: url, encoding: .utf8).components(separatedBy: "\n")
    let header = lines.removeFirst()
    #expect(header.hasPrefix("{t:\"readmev5\"}"), "the file still opens on its working header line")
    return lines.joined(separator: "\n").trimmingCharacters(in: .newlines).components(separatedBy: "\n\n")
}

/// **Her store's manifest** — each block's chosen take's SHA-256 as the
/// package README records it (note `DC4D224B-…`, captured 2026-10-29), in
/// block order. Taken WITH the trailing space her store carried on all but
/// blocks 2, 12, 16, 17 — interior-fidelity evidence since R-105-6.
private let herStoresManifest: [String] = [
    "16abee4da8b6a06f26cbd9ea8f8a0a8b1cc5666c9d453e482c625bf515761029",  // 1
    "ccc3c95f6e13fc2d38de5be8625922adffa68f5fbe7db0e6503b49ac0fa213f0",  // 2
    "b684f8384171bc9ca84de39494b22578fa21fae1f1b15ee4d18dc3c5ae6925d4",  // 3
    "1a4ea53a08d9a69cb1ce7013dfe07028e69f51df46fa638bbd8663e6271cb1fb",  // 4
    "3bfd662c51e944e7f11180ac43ec9a39cbe8bf604fab36fcc2edd6f31e561e9c",  // 5
    "1a1a15367fd80dda20c95f30a9599352f82c12ad2d4aacadaec9bdd43d4ba4df",  // 6
    "9b1070bdd6642cd65c1598a51da3d62d96ef2d6e9ddedd72474341a7e558ca3a",  // 7
    "26212229de860063770888effdbf1bda8ed67d5b90828218e69a409f1495db66",  // 8
    "5f3b8ae589fa4dbe8006d51e73f6af96d9946b246c13b941872df87621f3cd12",  // 9
    "c8c5d42ff67d2d23bd81a9df84f2a06d850b5357a8c71babf4c963b2be8b536b",  // 10
    "aa946c04fca9b97aab94694b0a1bba3fb62cc2e802c16328000dda03bb8fc66f",  // 11
    "4f0f248de944d3bd9a24a0067f8547cdbade1da3f565e34ed6564a49e4005cdb",  // 12
    "6f643c73a5b89846e6c46db0c56a05b6483e28b7d075c32b5f78daba1e6728b0",  // 13
    "d957a9205336a3314f324f0d73805c7545ee1f121713626ee060daacea690482",  // 14
    "c4b9b25f51055411afd0f1bfc62cae145c27dd09384c494a0bccf4c56531696a",  // 15
    "16f428caf18e8e6fa5eeb16fbca497fdef6669045b63b15c98cc9fa075d83d5a",  // 16
    "eabcdcdaaff8c65b717b1223c99c02c84d890935b8309357ac391d2c46217aa6",  // 17
]

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
            // set's own pin is aFreshLaunchSeedsTheFinalSet below. VX-633
            // (R-633-6): the launch's book is the Prince now — read from the
            // launch set itself, so the next swap needs no edit here.)
            for name in SampleLibrarySeeder.Book.launchSet.map(\.name) {
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
    /// the launch's seeded book, OWNED · the starred-notes gathering, empty ·
    /// the example snippet. And NOTHING of the retired seed — no Jekyll
    /// (R-17y-8), no *Encryption Explained*, no classics gathering, no
    /// Quicknotes, no seeded quicknote; none of them minted-then-removed
    /// either. RED ON OLD, per retired fact: the old launch seeded EE, and the
    /// old arrangement minted the classics gathering and the quicknote (which
    /// minted Quicknotes); the old tree had no example snippet.
    /// **JUSTIFIED EDIT (VX-633, R-633-6 — "sherlock and jekyll and hyde are
    /// still restorable"):** the launch's book is *The Prince*, bilingual,
    /// OWNED and on Welcome, its notes wearing #classics; Sherlock joins the
    /// retired list (absent, never minted — restore-only). RED ON OLD: the
    /// old launch seeded Sherlock and no Prince existed.
    @Test func aFreshLaunchSeedsTheFinalSet() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let prince = try #require(
                try await reading(db, named: SampleLibrarySeeder.Book.prince.name),
                "the Prince seeds (R-633-6)")
            #expect(prince.owned, "…owned (the §7 ladder, extended to the Prince)")
            let welcome = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL")
            }
            #expect(prince.shelfId != nil && prince.shelfId == welcome, "…on Welcome")
            let unclassic = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM reading_post rp
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                          AND NOT EXISTS (SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                                          WHERE pt.post_id = rp.post_id AND t.path = ?
                                            AND pt.deleted_at IS NULL AND t.deleted_at IS NULL)
                        """,
                    arguments: [prince.id, SampleLibrarySeeder.classicsTagPath]) ?? -1
            }
            #expect(unclassic == 0, "…every note wearing #classics")
            let starred = try #require(
                try await reading(db, named: Operations.starredNotesGatheringName),
                "the starred-notes gathering seeds")
            #expect(starred.kind == .gathering && starred.shelfId == nil)
            // The retired seed: absent, and never minted at all.
            for name in [SampleLibrarySeeder.Book.sherlock.name,
                         SampleLibrarySeeder.Book.jekyllAndHyde.name,
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
            #expect(SampleLibrarySeeder.Book.all.contains(.sherlock), "Sherlock stays restorable (R-633-6)")
            #expect(SampleLibrarySeeder.Book.all.contains(.jekyllAndHyde))
            #expect(SampleLibrarySeeder.Book.all.contains(.encryptionExplained))
            #expect(SampleLibrarySeeder.Book.launchSet == [.prince])
        }
    }

    /// **HER README, WHOLE (VX-105 — R-13s-28; R-105-6 trimmed; the
    /// standalone shape, her disposition 3).** A fresh launch leaves ONE
    /// bookless, untagged Home note titled "readme" whose seventeen blocks are
    /// `read-me.txt`'s paragraphs BYTE FOR BYTE (the oracle is the IN-REPO FILE,
    /// read here — the package her text arrived in, never a second transcription),
    /// ONE take each, chosen, nothing archived; the page is those seventeen
    /// joined. RED ON OLD by construction: the old seeder seeded nine blocks
    /// (her placeholder's five, the four Start Here passages) with takes on two.
    @Test func aFreshLaunchSeedsHerReadmeByteForByteOneTakePerBlock() async throws {
        let file = try herReadmeFileParagraphs()
        #expect(file.count == 17, "her text is seventeen blocks")
        #expect(ReadmeSeeder.paragraphs == file, "the seeder's literals ARE the file's paragraphs")
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let id = try #require(try await readmeID(db), "the readme seeds")
            let shape = try await db.read { db -> (membered: Bool, tagged: Bool, entryDate: String?, wing: String,
                                                    title: String?, rendered: String) in
                (try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM reading_post WHERE post_id = ? AND deleted_at IS NULL)",
                    arguments: [id]) ?? false,
                 try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM post_tag WHERE post_id = ? AND deleted_at IS NULL)",
                    arguments: [id]) ?? false,
                 try String.fetchOne(db, sql: "SELECT entry_date FROM container WHERE id = ?", arguments: [id]),
                 try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [id]) ?? "?",
                 try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = ?", arguments: [id]),
                 try Queries.renderedText(db, containerID: id))
            }
            #expect(shape.title == "readme", "her word, lowercase")
            #expect(!shape.membered, "standalone: no book memberships (her disposition 3)")
            #expect(!shape.tagged, "standalone: no tags")
            #expect(shape.entryDate == nil, "undated — the created stamp carries her moment")
            #expect(shape.wing == "", "in Home")
            // `renderedText` joins blocks with a blank line (`joinRenderedTexts`).
            #expect(shape.rendered == file.joined(separator: "\n\n"), "the page is her text")
            // Block by block: ONE live take each (no fan, nothing archived), the
            // chosen one, its stored bytes the file's paragraph.
            let blocks = try await db.read { db -> [(texts: [String], chosenIsIt: Bool)] in
                let rows = try Row.fetchAll(
                    db,
                    sql: """
                        SELECT block_id, chosen_variant_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [id])
                return try rows.map { row in
                    let blockID: String = row["block_id"]
                    let takes = try Row.fetchAll(
                        db,
                        sql: "SELECT id, working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                        arguments: [blockID])
                    return (takes.map { $0["working_text"] as String },
                            takes.count == 1 && (takes.first?["id"] as String?) == (row["chosen_variant_id"] as String?))
                }
            }
            #expect(blocks.count == file.count, "seventeen blocks")
            for (index, block) in blocks.enumerated() where index < file.count {
                #expect(block.texts == [file[index]], "block \(index + 1): one take, byte for byte the file's")
                #expect(block.chosenIsIt, "block \(index + 1): its one take is the chosen one")
            }
        }
    }

    /// **THE MANIFEST IS INTERIOR-FIDELITY EVIDENCE ONLY (R-105-6).** The
    /// package README's SHA-256s were read from her store, whose blocks carried
    /// ONE trailing space on all but blocks 2, 12, 16 and 17; her ruling seeds
    /// them trimmed. So each seeded block hashes to its manifest value AS-IS on
    /// exactly those four, and WITH the one space her store carried on the other
    /// thirteen — every interior byte hers, the bare mismatch EXPECTED and never
    /// drift. RED ON OLD by construction (the old literals were her placeholder);
    /// a single interior byte off on any block reds it.
    @Test func herReadmesInteriorBytesAreHerStoresPerTheManifest() {
        let blocks = ReadmeSeeder.paragraphs
        #expect(blocks.count == herStoresManifest.count)
        var bare: [Int] = []
        for (index, (block, hash)) in zip(blocks, herStoresManifest).enumerated() {
            let asIs = BridgeHash.body(block) == hash
            let withTheStoresSpace = BridgeHash.body(block + " ") == hash
            #expect(asIs || withTheStoresSpace, "block \(index + 1): an interior byte differs from her store")
            #expect(block == block.trimmingCharacters(in: .whitespaces), "block \(index + 1) lands trimmed (R-105-6)")
            if asIs { bare.append(index + 1) }
        }
        #expect(bare == [2, 12, 16, 17], "the four blocks her store kept bare; the other thirteen lost only a space")
    }

    /// **BORN STARRED, CREATED AT HER MOMENT, EDITED AT BIRTH, SEEDED LAST
    /// (VX-105 — her "yeah make it born starred"; R-105-3).** The readme's
    /// `created_at` is October 29, 2026, 4:44:00 am in THIS device's zone
    /// (Gregorian); its edited stamps are the seed moment — `last_touched_at`
    /// the last block's mint, `last_major_revision_at` one of its blocks' mints
    /// (the churn crossing), `updated_at` with the touch; it is starred through
    /// the one star list; and it is the FIRST note of the Library's default
    /// sort (edited, newest first) — nothing the launch seeds comes after it.
    /// RED ON OLD per fact: the old seed stamped `created_at` at the seed moment
    /// (revert: drop the `withDependencies` scope around `createPost`) and never
    /// starred (revert: drop the `setStarred` line).
    @Test func theReadmeIsBornStarredCreatedAtHerMomentAndSeededLast() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let id = try #require(try await readmeID(db), "the readme seeds")
            let stamps = try await db.read { db -> (created: String, touched: String?, major: String?, updated: String,
                                                     blockStamps: [String], starred: Bool, first: String?) in
                let row = try #require(try Row.fetchOne(
                    db,
                    sql: """
                        SELECT created_at, last_touched_at, last_major_revision_at, updated_at
                        FROM container WHERE id = ?
                        """,
                    arguments: [id]))
                let blockStamps = try String.fetchAll(
                    db,
                    sql: """
                        SELECT created_at FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """,
                    arguments: [id])
                return (row["created_at"], row["last_touched_at"], row["last_major_revision_at"], row["updated_at"],
                        blockStamps,
                        try Queries.starred(db).contains { $0.target == .post(id) },
                        try Queries.catalogNotesPage(db, query: "", limit: 1).hits.first?.id)
            }
            // Created at her moment, read in this device's own calendar.
            #expect(stamps.created == DateFormatter.variorumISO8601.string(from: ReadmeSeeder.writtenAt()))
            let created = try #require(DateFormatter.variorumISO8601.date(from: stamps.created))
            var gregorian = Calendar(identifier: .gregorian)
            gregorian.timeZone = .current
            let local = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: created)
            #expect(local.year == 2026 && local.month == 10 && local.day == 29, "October 29, 2026")
            #expect(local.hour == 4 && local.minute == 44 && local.second == 0, "4:44 am, local")
            // Edited at birth: the text's landing, never her moment.
            #expect(stamps.blockStamps.count == 17)
            #expect(stamps.touched == stamps.blockStamps.last, "last_touched_at is the last block's mint")
            #expect(stamps.updated == stamps.blockStamps.last, "updated_at rides the touch")
            #expect(stamps.major.map { stamps.blockStamps.contains($0) } == true,
                    "last_major_revision_at is a block's mint (the churn crossing)")
            #expect(stamps.touched != stamps.created && stamps.major != stamps.created)
            // Born starred, through the one star list.
            #expect(stamps.starred, "born starred (her ruling)")
            // Seeded LAST and topping the Library's default sort.
            #expect(stamps.first == id, "the readme leads the Library (edited, newest first — R-13s-29)")
            let (later, newerTouch) = try await db.read { db in
                (try String.fetchAll(
                    db,
                    sql: """
                        SELECT COALESCE(title, '') FROM container
                        WHERE deleted_at IS NULL AND id <> ? AND created_at >= ?
                        """,
                    arguments: [id, stamps.blockStamps.first ?? ""]),
                 try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container
                        WHERE deleted_at IS NULL AND id <> ? AND last_touched_at >= ?
                        """,
                    arguments: [id, stamps.touched ?? ""]) ?? -1)
            }
            #expect(later.isEmpty, "nothing seeds after the readme: \(later)")
            #expect(newerTouch == 0, "no note was touched after the readme's last block")
        }
    }

    /// **"EVERY READER SEES 4:44 AM" — the local reading of R-105-3
    /// (PROVISIONAL), stated as instants.** The same wall time in three zones
    /// is three UTC stamps; Gregorian whatever the device's own calendar. RED ON
    /// OLD by construction (no such moment existed).
    @Test func herMomentIsFourFortyFourOnEachReadersOwnClock() throws {
        func stamp(_ zone: String) throws -> String {
            DateFormatter.variorumISO8601.string(
                from: ReadmeSeeder.writtenAt(in: try #require(TimeZone(identifier: zone))))
        }
        #expect(try stamp("UTC") == "2026-10-29T04:44:00.000Z")
        #expect(try stamp("America/Los_Angeles") == "2026-10-29T11:44:00.000Z")
        #expect(try stamp("Asia/Tokyo") == "2026-10-28T19:44:00.000Z")
    }

    /// **EVERY STORE SEEDS THE SAME README (VX-329's both-variants pin, carried
    /// to VX-105's text).** The release switch put every store on one road
    /// (`ReadmeSeeder.paragraphs` is every store's), so a fresh store of EITHER
    /// variant is born with her seventeen blocks, the real variant's page
    /// byte-identical to the dev variant's. Driven through the PRODUCTION
    /// composition per variant, each in its own fresh world (the marks injected
    /// — no defaults are touched). RED ON OLD by construction (nine blocks).
    @Test func aFreshStoreOfEitherVariantSeedsHerSameSeventeenBlocks() async throws {
        let file = try herReadmeFileParagraphs()
        var pages: [AppDatabase.StoreVariant: String] = [:]
        for variant in AppDatabase.StoreVariant.allCases {
            pages[variant] = try await withLaunchWorld { session, db -> String in
                let device = DeviceMarks()
                _ = await LaunchFurniture.seed(
                    session: session, storeVariant: variant,
                    gate: gate(account: false, clean: true), marks: device.marks)
                let id = try #require(try await readmeID(db), "the readme seeds on the \(variant) variant")
                let (blocks, rendered) = try await db.read { db in
                    (try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                        arguments: [id]) ?? 0,
                     try Queries.renderedText(db, containerID: id))
                }
                #expect(blocks == file.count, "the \(variant) variant seeded \(blocks) blocks — every store seeds 17")
                #expect(rendered == file.joined(separator: "\n\n"), "the \(variant) variant: her text, byte for byte")
                return rendered
            }
        }
        #expect(pages.count == AppDatabase.StoreVariant.allCases.count)
        #expect(pages[.real] == pages[.dev], "the real variant's readme is the dev variant's, byte for byte")
    }

    // MARK: - VX-105 (R-105-8) — Help ▸ Restore “readme”

    /// The readme's seed shape, as the store holds it — what the birth seed
    /// and the door must both leave (one mint body).
    private func readmeShape(_ db: AppDatabase, _ id: String) async throws -> (
        blocks: [String], oneTakeEach: Bool, starred: Bool, created: String,
        membered: Bool, tagged: Bool, wing: String
    ) {
        try await db.read { db in
            let blockIDs = try String.fetchAll(
                db,
                sql: """
                    SELECT block_id FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                    """,
                arguments: [id])
            let takeCounts = try blockIDs.map { blockID in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]) ?? 0
            }
            let created = try String.fetchOne(
                db, sql: "SELECT created_at FROM container WHERE id = ?", arguments: [id]) ?? ""
            return (
                try Queries.renderedText(db, containerID: id).components(separatedBy: "\n\n"),
                takeCounts.allSatisfy { $0 == 1 },
                try Queries.starred(db).contains { $0.target == .post(id) },
                created,
                try Bool.fetchOne(
                    db, sql: "SELECT EXISTS (SELECT 1 FROM reading_post WHERE post_id = ? AND deleted_at IS NULL)",
                    arguments: [id]) ?? true,
                try Bool.fetchOne(
                    db, sql: "SELECT EXISTS (SELECT 1 FROM post_tag WHERE post_id = ? AND deleted_at IS NULL)",
                    arguments: [id]) ?? true,
                try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [id]) ?? "?")
        }
    }

    private func liveReadmeCount(_ db: AppDatabase) async throws -> Int {
        try await db.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND title = ? AND deleted_at IS NULL",
                arguments: [ReadmeSeeder.title]) ?? -1
        }
    }

    /// **THE DOOR'S MINT ARM — her deletion does not stop a press** (R-105-8:
    /// "a deleted chapter comes back fresh" is the seeded doors' rule). She
    /// deletes the seeded readme: the BIRTH road keeps honouring that quietly
    /// (`seedAtBirth` answers `.deletedByTheReader`), but Help ▸ Restore
    /// “readme” MINTS the exact seed shape anew — her seventeen blocks, one take
    /// each, starred, created at her 4:44 moment, bookless, untagged, Home —
    /// opens it, and speaks the receipt; the deleted copy stays in the Trash.
    /// RED ON OLD by construction: no such door (`.restoreReadme`) existed.
    @Test func theReadmeDoorMintsTheSeedShapeEvenAfterHerDeletion() async throws {
        let file = try herReadmeFileParagraphs()
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let seeded = try #require(try await readmeID(db))
            try session.operations.deleteContainer(seeded)
            #expect(await ReadmeSeeder.seedAtBirth(session: session) == .deletedByTheReader,
                    "the birth road still honours her deletion quietly")
            #expect(try await liveReadmeCount(db) == 0)

            let shell = ShellRouter()
            ShellActions(session: session, shell: shell).restoreReadme()
            await pollUntil { session.status.spoken != nil }
            #expect(session.status.spoken?.text == ReadmeDoorCopy.restored())
            #expect(session.status.spoken?.kind == .receipt, "a mint is a receipt")
            let fresh = try #require(try await readmeID(db), "the door minted a readme")
            #expect(fresh != seeded, "a fresh note — the deleted one stays deleted")
            #expect(shell.pendingSelection == .post(fresh), "fire-and-DO: the door opens it")
            #expect(try await liveReadmeCount(db) == 1)
            let shape = try await readmeShape(db, fresh)
            #expect(shape.blocks == file, "her seventeen blocks, byte for byte")
            #expect(shape.oneTakeEach && shape.starred && !shape.membered && !shape.tagged && shape.wing == "",
                    "one take each, starred, standalone, Home")
            #expect(shape.created == DateFormatter.variorumISO8601.string(from: ReadmeSeeder.writtenAt()),
                    "created at her moment, like the seed's")
            #expect(session.undoStack.depth == 0, "no ⌥⌘Z entry, like every restore door")
        }
    }

    /// **THE DOOR'S REFUSAL ARM.** While a live readme stands the door changes
    /// nothing: no second readme, a refusal in the family's voice, and the
    /// existing note opened. RED ON OLD by construction (no such door).
    @Test func theReadmeDoorRefusesWhileALiveReadmeStands() async throws {
        try await withLaunchWorld { session, db in
            let device = DeviceMarks()
            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: device.marks)
            let standing = try #require(try await readmeID(db))
            let shell = ShellRouter()
            ShellActions(session: session, shell: shell).restoreReadme()
            await pollUntil { session.status.spoken != nil }
            #expect(session.status.spoken?.text == ReadmeDoorCopy.alreadyPresent())
            #expect(session.status.spoken?.kind == .refusal, "a door that did nothing speaks a refusal")
            #expect(shell.pendingSelection == .post(standing), "…and still opens the readme she has")
            #expect(try await liveReadmeCount(db) == 1, "never a second readme")
        }
    }

    /// **TWO QUICK PRESSES MINT ONE** — the door's read and its mint share one
    /// serialized runner turn, so a second press finds the first's readme.
    /// RED ON OLD by construction (no such door).
    @Test func twoQuickPressesOfTheReadmeDoorMintOne() async throws {
        try await withLaunchWorld { session, db in
            let first = Task { @MainActor in try await ReadmeSeeder.restore(session: session) }
            let second = Task { @MainActor in try await ReadmeSeeder.restore(session: session) }
            let outcomes = [try await first.value, try await second.value]
            let minted = outcomes.filter { if case .restored = $0 { true } else { false } }
            #expect(minted.count == 1, "exactly one press mints: \(outcomes)")
            #expect(try await liveReadmeCount(db) == 1)
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
    /// **JUSTIFIED EDIT of (c) (VX-633 U2b — R-633-16, her word: "FRESH
    /// STORES ONLY … existing stores are untouched"):** (c) read "fresh" off
    /// the LAUNCH BOOK's absence, which held while every library carried
    /// Sherlock; now every existing library lacks the launch book, so that
    /// reading would seed the Prince into her account's library and ARRANGE
    /// it on any new device. An account corpus holding anything — here, her
    /// guide — is an EXISTING library: the launch declines it (`declined`,
    /// recorded), no Prince is minted, nothing is arranged, and her guide
    /// stands alone. RED ON OLD: `.arranged`, the Prince minted and owned.
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
            let declined = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: true, clean: true), marks: device.marks)
            #expect(declined == .declined, "a corpus holding writing is an existing library (R-633-16)")
            #expect(device.welcome == "declined")
            #expect(device.books[SampleLibrarySeeder.Book.prince.name] == true,
                    "the launch book's decision is recorded")
            #expect(try await reading(db, named: SampleLibrarySeeder.Book.prince.name) == nil,
                    "no Prince minted into her library")
            let facts = try await guideFacts(db)
            #expect(facts.guides.map(\.id) == [hers], "never a second guide beside hers")
            #expect(facts.welcomeIDs.isEmpty, "nothing arranged — her guide stands where it was")
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
