//
//  PlaintextExportImportTests.swift
//  VariorumCoreTests — VX-309 U1b piece 3: T-8, A PLAINTEXT EXPORT BROUGHT IN AS A NEW LIBRARY, its content through the
//  import road (the mapping ruled at the plan's §5b-R: "Content and its placement ride — including its kept-out-of-view-ness;
//  configuration does not"). A library with books (chapters, a note in two books, an archived book, an empty book), notes
//  (titled, untitled-but-dated, archived, a fanned take, tags, one in a second wing), a saved version, a deleted note, a
//  snippet group and a gathering is exported plain, READ into a plan on a private staged copy, and APPLIED to a fresh
//  library: every row fresh; each note once, membered in each book in the export's order and chapter; archived things
//  archived; the empty book left out and named; the wing minted, its tags its own; versions, the Trash and the gathering never
//  cross. New API — red by construction on the pre-unit tree. VX-502 (her ratified rule, 2026-10-27; supersedes
//  P-VX309-U1b-7): an export of an EARLIER build's schema — its applied migrations a subset of this build's — reads whole
//  and imports; a NEWER build's refuses.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-309 U1b — T-8: a plaintext export's content through the import road, into a new library")
struct PlaintextExportImportTests {
    /// The ops over `database`, the real clock and fresh UUIDs (no undo stack — a library's birth).
    static func ops<T>(_ database: AppDatabase, _ body: (Operations) throws -> T) rethrows -> T {
        try withDependencies {
            $0.database = database
            $0.uuid = .init { UUID() }
            $0.date = .init { Date() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            try body(Operations())
        }
    }

    struct Source {
        let url: URL
        let ids: [String: String]
    }

    /// The source library, exported plain into a temp folder.
    static func source() throws -> Source {
        let source = try AppDatabase.inMemory()
        var ids: [String: String] = [:]
        try ops(source) { ops in
            let studio = try ops.createWing(name: "studio")
            let alpha = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "x",
                document: try VariorumDocument.parse("""
                    {t:"Alpha"} {#travel/lisbon}

                    The first paragraph.

                    --- Alternates for this block ---

                    take: "english"

                    The first, in English.

                    --- end alternates ---

                    The second paragraph.
                    """)))
            ids["alpha"] = alpha.post.id
            let beta = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "Beta", document: try VariorumDocument.parse("{#studio/sketch}\n\nIn the studio.")),
                wingId: studio.id)
            ids["beta"] = beta.post.id
            let dated = try ops.createPost(title: nil, entryDate: "2026-03-04")
            _ = try ops.newBlock(in: dated.id, text: "An untitled day.")
            ids["dated"] = dated.id
            let delta = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "Delta", document: try VariorumDocument.parse("Put away.")))
            ids["delta"] = delta.post.id
            let gone = try ops.importDocument(VariorumDocument.NamedDocument(
                fallbackTitle: "Gone", document: try VariorumDocument.parse("Deleted.")))
            _ = try ops.saveNoteVersion(alpha.post.id)
            // Books: Zeta (two chapters; the dated note unfiled first, Alpha in "Two"), Eta (Alpha again), an empty one,
            // an archived one (Delta), and a gathering.
            let zeta = try ops.createReading(name: "Zeta", kind: .book)
            _ = try ops.createSection(in: zeta.id, name: "One")
            let two = try ops.createSection(in: zeta.id, name: "Two")
            _ = try ops.addPostToReading(dated.id, to: zeta.id)
            _ = try ops.addPostToReading(alpha.post.id, to: zeta.id)
            try ops.assignPostToSection(alpha.post.id, in: zeta.id, section: two.id)
            let eta = try ops.createReading(name: "Eta", kind: .book)
            _ = try ops.addPostToReading(alpha.post.id, to: eta.id)
            _ = try ops.createReading(name: "Empty", kind: .book)
            let old = try ops.createReading(name: "Old", kind: .book)
            _ = try ops.addPostToReading(delta.post.id, to: old.id)
            try ops.archiveReading(old.id)
            try ops.archiveContainer(delta.post.id)
            try ops.deleteContainer(gone.post.id)
            let tagID = try #require(alpha.tagIDs.first)
            _ = try ops.createReading(
                name: "Everything travel", kind: .gathering, querySpec: RuleGrammar.encode(.tag(tagID)))
            let pool = try ops.createPool(title: "Scraps")
            _ = try ops.importBlocks(into: pool.id, text: "A loose line.")
            ids["pool"] = pool.id
        }
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("vx309-t8-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("export.sqlite")
        try StorePlaintextExport.export(from: source, to: url)
        return Source(url: url, ids: ids)
    }

    /// THE READ: the plan holds the living notes (no version, no deleted note), the books a–z with their chapters and
    /// members in the export's order (the gathering never — configuration), the snippet group, the wing.
    @Test func theReadPlansTheExportsContentAndNothingElse() throws {
        let source = try Self.source()
        defer { try? FileManager.default.removeItem(at: source.url.deletingLastPathComponent()) }
        let plan = try PlaintextExportReading.read(exportAt: source.url)
        #expect(Set(plan.notes.map(\.id)) == Set(["alpha", "beta", "dated", "delta"].compactMap { source.ids[$0] }),
                "the living notes, archived included — no version, no deleted note")
        #expect(plan.books.map(\.name) == ["Empty", "Eta", "Old", "Zeta"], "books only, digit-aware a–z")
        let zeta = try #require(plan.books.last)
        #expect(zeta.chapters.map(\.name) == ["One", "Two"])
        #expect(zeta.members.map(\.noteID) == [source.ids["dated"], source.ids["alpha"]].compactMap { $0 },
                "members in the export's (position, id) order")
        #expect(plan.books.first { $0.name == "Old" }?.archived == true)
        #expect(plan.pools.map(\.title) == ["Scraps"] && plan.pools.first?.scraps == ["A loose line."])
        #expect(plan.wings.map(\.name) == ["studio"])
        let dated = try #require(plan.notes.first { $0.id == source.ids["dated"] })
        #expect(dated.document.document.title == nil && dated.document.fallbackTitle == "2026-03-04",
                "an untitled note is named by its day")
    }

    /// THE APPLY into a fresh library — the ruled mapping, row by row.
    @Test func theApplyMintsTheContentFreshAsRuled() throws {
        let source = try Self.source()
        defer { try? FileManager.default.removeItem(at: source.url.deletingLastPathComponent()) }
        let plan = try PlaintextExportReading.read(exportAt: source.url)
        let target = try AppDatabase.inMemory()
        let landing = try Self.ops(target) { try $0.importPlaintextExport(plan) }
        #expect(landing.notes == 4 && landing.books == 3 && landing.snippets == 1 && landing.wings == 1)
        #expect(landing.emptyBooks == ["Empty"], "the empty book left out and named")
        #expect(landing.membershipsLeftOut == 0)
        try target.read { db in
            // Every row fresh: no id of the export's.
            let postIDs = try String.fetchAll(db, sql: "SELECT id FROM container WHERE deleted_at IS NULL")
            #expect(Set(postIDs).isDisjoint(with: Set(source.ids.values)), "rows minted fresh")
            // Alpha ONCE, its fan and its tag riding.
            let alphaIDs = try String.fetchAll(db, sql: "SELECT id FROM container WHERE title = 'Alpha' AND deleted_at IS NULL")
            #expect(alphaIDs.count == 1, "a note in two books lands once")
            let alpha = try #require(alphaIDs.first)
            let takes = try Int.fetchOne(db, sql: """
                SELECT count(*) FROM variant v JOIN container_block cb ON cb.block_id = v.block_id
                WHERE cb.container_id = ? AND v.deleted_at IS NULL
                """, arguments: [alpha]) ?? 0
            #expect(takes == 3, "two blocks, the first carrying its second take")
            #expect(try String.fetchAll(db, sql: """
                SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                """, arguments: [alpha]) == ["travel/lisbon"])
            // Membered in BOTH books; in Zeta under "Two", after the dated note.
            let books = try String.fetchAll(db, sql: """
                SELECT r.name FROM reading_post rp JOIN reading r ON r.id = rp.reading_id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL ORDER BY r.name
                """, arguments: [alpha])
            #expect(books == ["Eta", "Zeta"])
            let zetaMembers = try Row.fetchAll(db, sql: """
                SELECT c.title, c.id, s.name AS chapter FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.name = 'Zeta'
                JOIN container c ON c.id = rp.post_id
                LEFT JOIN reading_section s ON s.id = rp.section_id
                WHERE rp.deleted_at IS NULL ORDER BY rp.position, rp.id
                """)
            #expect(zetaMembers.map { $0["title"] as String? } == ["2026-03-04", "Alpha"],
                    "the export's member order; the untitled note named by its day")
            #expect(zetaMembers.map { $0["chapter"] as String? } == [nil, "Two"])
            #expect(try String.fetchAll(db, sql: """
                SELECT s.name FROM reading_section s JOIN reading r ON r.id = s.reading_id AND r.name = 'Zeta'
                WHERE s.deleted_at IS NULL ORDER BY s.position
                """) == ["One", "Two"])
            // Kept out of view, as it was.
            #expect(try String.fetchOne(db, sql: "SELECT archived_at FROM reading WHERE name = 'Old'") != nil)
            #expect(try String.fetchOne(db, sql: "SELECT archived_at FROM container WHERE title = 'Delta'") != nil)
            #expect(try Int.fetchOne(db, sql: """
                SELECT count(*) FROM reading_post rp JOIN reading r ON r.id = rp.reading_id AND r.name = 'Old'
                WHERE rp.deleted_at IS NULL
                """) == 1, "the archived book keeps its member")
            // The wing minted, Beta in it, its tag in the wing's own vocabulary (R-13ia-1).
            let studio = try #require(try String.fetchOne(db, sql: "SELECT id FROM wing WHERE name = 'studio' AND deleted_at IS NULL"))
            #expect(try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE title = 'Beta'") == studio)
            #expect(try String.fetchOne(db, sql: "SELECT wing_id FROM tag WHERE path = 'studio/sketch'") == studio)
            // Never: a version, the deleted note, the gathering, the empty book.
            #expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM container WHERE title = 'Gone'") == 0)
            #expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM container WHERE kind = 'post'") == 4, "no version")
            #expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM reading WHERE kind = 'gathering'") == 0)
            #expect(try Int.fetchOne(db, sql: "SELECT count(*) FROM reading WHERE name = 'Empty'") == 0)
            // The snippet group, its scrap.
            let pool = try #require(try String.fetchOne(db, sql: "SELECT id FROM container WHERE kind = 'pool' AND title = 'Scraps'"))
            #expect(try String.fetchAll(db, sql: """
                SELECT v.working_text FROM container_block cb JOIN variant v ON v.id = cb.chosen_variant_id
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL ORDER BY cb.position
                """, arguments: [pool]) == ["A loose line."])
        }
    }

    // MARK: - VX-502 — the subset rule (her ratified rule, 2026-10-27; supersedes P-VX309-U1b-7): an export whose applied
    // migration set is a SUBSET of this build's known set is accepted; a newer build's (an identifier this build has never
    // heard of) still refuses. The old two-arm `anExportOfAnotherBuildsSchemaRefuses` split: its earlier-build arm FLIPPED
    // DELIBERATELY into pin 1, its newer arm kept as pin 3.

    /// `identifiers` struck from the export's `grdb_migrations`, the physical schema untouched — for the last identifier
    /// (`v1_32`, one local-only table the export drops) exactly the file the build before it wrote; for deeper strikes, the
    /// gate's own arithmetic (the reader's tolerance of older physical schemas is the VX-502 record's D-A2 verification,
    /// not these pins'). The remaining set is checked to be the known set minus them, so a pin can never pass on a delete
    /// that took nothing.
    static func forgetMigrations(_ identifiers: [String], in url: URL) throws {
        let queue = try DatabaseQueue(path: url.path, configuration: AppDatabase.configuration(key: nil))
        defer { try? queue.close() }
        let remaining = try queue.write { db in
            for identifier in identifiers {
                try db.execute(sql: "DELETE FROM grdb_migrations WHERE identifier = ?", arguments: [identifier])
            }
            return try Set(String.fetchAll(db, sql: "SELECT identifier FROM grdb_migrations"))
        }
        #expect(remaining == Set(AppDatabase.migrator.migrations).subtracting(identifiers), "a strict subset now")
    }

    /// VX-502 PIN 1 — THE F6 SCENE (red on the pre-fix tree): an export whose `grdb_migrations` lacks this build's LAST
    /// identifier (today `v1_32_sync_pull_stage` — a local-only table the export drops anyway: exactly the shape of every
    /// export 0.10 (9093) wrote) READS WHOLE — the very plan the unaltered file gives — and imports. The pre-fix gate
    /// (`applied == known`) threw `schemaNotCurrent(newer: false)` here.
    @Test func anExportMissingThisBuildsLastMigrationReadsWholeAndImports() throws {
        let source = try Self.source()
        defer { try? FileManager.default.removeItem(at: source.url.deletingLastPathComponent()) }
        let whole = try PlaintextExportReading.read(exportAt: source.url)
        let last = try #require(AppDatabase.migrator.migrations.last)
        try Self.forgetMigrations([last], in: source.url)
        let plan = try PlaintextExportReading.read(exportAt: source.url)
        #expect(plan == whole, "read whole — the same plan as the unaltered export")
        let landing = try Self.ops(try AppDatabase.inMemory()) { try $0.importPlaintextExport(plan) }
        #expect(landing.notes == 4 && landing.books == 3 && landing.snippets == 1 && landing.wings == 1, "and it imports")
        #expect(landing.emptyBooks == ["Empty"] && landing.membershipsLeftOut == 0)
    }

    /// VX-502 PIN 2 — THE DEEPER SUBSET (red on the pre-fix tree): several identifiers gone — the last three and one from
    /// the middle, a set that is no prefix of the known list — and the export still reads whole. The rule is SUBSET, never
    /// "behind by the last one".
    @Test func anExportMissingSeveralMigrationsStillReadsWhole() throws {
        let source = try Self.source()
        defer { try? FileManager.default.removeItem(at: source.url.deletingLastPathComponent()) }
        let whole = try PlaintextExportReading.read(exportAt: source.url)
        let known = AppDatabase.migrator.migrations
        let forgotten = Array(known.suffix(3)) + [known[known.count / 2]]
        #expect(Set(forgotten).count == 4, "four distinct identifiers, one of them mid-list")
        try Self.forgetMigrations(forgotten, in: source.url)
        #expect(try PlaintextExportReading.read(exportAt: source.url) == whole, "read whole")
    }

    /// VX-502 PIN 3 — THE NEWER GUARD, KEPT: an identifier this build has never heard of (a newer Variorum wrote it) refuses
    /// before anything is planned — alone, and beside an identifier this build knows but the file lacks (newer wins). Green
    /// on the pre-fix tree by design; its teeth are the behavioral revert RV-A2 (the gate deleted whole → this pin red: the
    /// future export would read).
    @Test func anExportOfANewerBuildsSchemaRefuses() throws {
        let source = try Self.source()
        defer { try? FileManager.default.removeItem(at: source.url.deletingLastPathComponent()) }
        let queue = try DatabaseQueue(path: source.url.path, configuration: AppDatabase.configuration(key: nil))
        try queue.write { try $0.execute(sql: "INSERT INTO grdb_migrations (identifier) VALUES ('v9_99_from_the_future')") }
        try queue.close()
        #expect(throws: PlaintextExportReading.Failure.schemaNewer) {
            _ = try PlaintextExportReading.read(exportAt: source.url)
        }
        // Beside a lag: the file now also lacks this build's last identifier.
        let last = try #require(AppDatabase.migrator.migrations.last)
        let lagging = try DatabaseQueue(path: source.url.path, configuration: AppDatabase.configuration(key: nil))
        let struck = try lagging.write { db in
            try db.execute(sql: "DELETE FROM grdb_migrations WHERE identifier = ?", arguments: [last])
            return db.changesCount
        }
        try lagging.close()
        #expect(struck == 1)
        #expect(throws: PlaintextExportReading.Failure.schemaNewer) {
            _ = try PlaintextExportReading.read(exportAt: source.url)
        }
    }

    // MARK: - VX-502 ladder round 1, F-1 — THE ERA-FROZEN PIN (the standing feature-detect duty, mechanized)

    /// The oldest era a content-bearing export can carry. VX-461's fix (the export's journal kept in memory) reached users
    /// in the VX-329 merge — release 0.10 — whose schema runs through this identifier; every app-written export before it
    /// is a 0-byte file (the VX-502 record's D-A2). FROZEN: never move it forward.
    static let oldestExportEra = "v1_31_protection_record"

    /// VX-502 F-1 (ladder round 1) — THE ERA-FROZEN PIN: a file migrated only up to the oldest export era, seeded by raw
    /// SQL in that era's own columns, with the writer's local-only drop applied — the very shape of a 0.10 export — must
    /// still plan whole under THIS build's reader, and import. A GUARD pin (the pin-3 class; no red-on-old applies): it
    /// goes red the moment a future migration changes a table the reader touches — a column `plan()`'s SQL names, a column
    /// a record decodes non-optionally — without a feature-detect (the `hasStatus` precedent), which pins 1–2 cannot see:
    /// they strike only `grdb_migrations` rows of a current-schema file. FROZEN: the seed names only the era's columns and
    /// is never edited to follow a later schema — if this goes red, the READER owes a feature-detect, not this pin an edit.
    @Test func anExportOfTheOldestExportEraStillReadsWhole() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("vx502-era-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("export.sqlite")
        let queue = try DatabaseQueue(path: url.path)
        try AppDatabase.migrator.migrate(queue, upTo: Self.oldestExportEra)
        let t = "2026-10-22T12:00:00.000Z"
        try queue.write { db in
            // A wing; a note in it — one block of two takes (the chosen one and a labeled alternate) and a tag.
            try db.execute(sql: """
                INSERT INTO wing (id, name, position, created_at, updated_at) VALUES ('W1', 'studio', 'a0', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, wing_id, created_at, updated_at)
                VALUES ('N1', 'post', 'Era note', 'W1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "INSERT INTO block (id, created_at, updated_at) VALUES ('B1', ?, ?)", arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO variant (id, block_id, working_text, label, fan_position, created_at, updated_at)
                VALUES ('V1', 'B1', 'The era''s prose.', NULL, 'a0', ?, ?),
                       ('V2', 'B1', 'Another take.', 'second', 'a1', ?, ?)
                """, arguments: [t, t, t, t])
            try db.execute(sql: "UPDATE block SET default_variant_id = 'V1' WHERE id = 'B1'")
            try db.execute(sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES ('P1', 'N1', 'B1', 'a0', 'V1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO tag (id, name, path, wing_id, created_at, updated_at) VALUES ('T1', 'sketch', 'sketch', 'W1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES ('PT1', 'T1', 'N1', ?)",
                           arguments: [t])
            // A book in the wing with one chapter, the note membered under it.
            try db.execute(sql: """
                INSERT INTO reading (id, name, kind, wing_id, created_at, updated_at) VALUES ('R1', 'Era book', 'book', 'W1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO reading_section (id, reading_id, name, position, created_at, updated_at)
                VALUES ('S1', 'R1', 'One', 'a0', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO reading_post (id, reading_id, post_id, position, section_id, status, created_at)
                VALUES ('RP1', 'R1', 'N1', 'a0', 'S1', 'member', ?)
                """, arguments: [t])
            // A snippet group with one scrap.
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at) VALUES ('PL1', 'pool', 'Scraps', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "INSERT INTO block (id, created_at, updated_at) VALUES ('B2', ?, ?)", arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
                VALUES ('V3', 'B2', 'A loose line.', 'a0', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "UPDATE block SET default_variant_id = 'V3' WHERE id = 'B2'")
            try db.execute(sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES ('P2', 'PL1', 'B2', 'a0', 'V3', ?, ?)
                """, arguments: [t, t])
            // The writer's own drop (`StorePlaintextExport`): the local-only tables stay behind.
            for table in StorePlaintextExport.localOnlyTables.sorted() {
                try db.execute(sql: "DROP TABLE IF EXISTS \"\(table.replacingOccurrences(of: "\"", with: "\"\""))\"")
            }
        }
        let applied = try queue.read { try String.fetchAll($0, sql: "SELECT identifier FROM grdb_migrations") }
        try queue.close()
        let known = AppDatabase.migrator.migrations
        let era = try #require(known.firstIndex(of: Self.oldestExportEra))
        #expect(Set(applied) == Set(known[...era]), "the file is of the frozen era")

        let plan = try PlaintextExportReading.read(exportAt: url)
        #expect(plan.wings == [PlaintextExportPlan.Wing(id: "W1", name: "studio")])
        #expect(plan.notes.count == 1)
        let note = try #require(plan.notes.first)
        #expect(note.id == "N1" && note.wingID == "W1" && !note.archived)
        #expect(note.document.document.title == "Era note" && note.document.document.tagPaths == ["sketch"])
        #expect(note.document.document.blocks.map(\.text) == ["The era's prose."])
        #expect(note.document.document.blocks.first?.alternates
            == [VariorumDocument.Take(label: "second", text: "Another take.")], "the alternate take rides")
        #expect(plan.books == [PlaintextExportPlan.Book(
            name: "Era book", wingID: "W1", archived: false,
            chapters: [.init(id: "S1", name: "One")], members: [.init(noteID: "N1", chapterID: "S1")])])
        #expect(plan.pools == [PlaintextExportPlan.Pool(title: "Scraps", archived: false, scraps: ["A loose line."])])
        let landing = try Self.ops(try AppDatabase.inMemory()) { try $0.importPlaintextExport(plan) }
        #expect(landing.notes == 1 && landing.books == 1 && landing.snippets == 1 && landing.wings == 1, "and it imports")
        #expect(landing.membershipsLeftOut == 0 && landing.emptyBooks.isEmpty)
    }
}
