import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 13i-c U1 — THE OUTFLOW EVENT (v1_20, marker 10→11; the plan
// `notes/plans/phase-13i-c-owned-finished-sealed.md` §2). Her two kickoff
// rulings pinned end to end: R-13ic-1 (the outflow is a CHOSEN, OPTIONAL SET
// stored as one JSON column) and R-13ic-4 (a gathering REQUIRES a rule;
// rule-less ones go to the Trash at migration; NO rule = shows NOTHING).
@Suite("13i-c U1 — the outflow event: migration · ops · readers · convergence")
struct Phase13icOutflowTests {
    private static let now = "2026-10-01T00:00:00.000Z"

    // MARK: - The migration (an old marker-10 store runs v1_20)

    private func oldStore(_ seed: (Database) throws -> Void) throws -> DatabaseQueue {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_19_journals_newest_first")
        try queue.write(seed)
        return queue
    }

    private func reading(
        _ db: Database, id: String, kind: String, spec: String? = nil,
        autoTagId: String? = nil, deletedAt: String? = nil
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO reading (id, name, kind, query_spec, auto_tag_id,
                                     deleted_at, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [id, id, kind, spec, autoTagId, deletedAt, Self.now, Self.now])
    }

    @Test func theColumnLandsAndEveryLiveSingleOutflowIsCarried() throws {
        let queue = try oldStore { db in
            try db.execute(sql: """
                INSERT INTO tag (id, name, path, created_at, updated_at)
                VALUES ('T1', 't1', 't1', '\(Self.now)', '\(Self.now)')
                """)
            try reading(db, id: "B-flows", kind: "book", autoTagId: "T1")
            try reading(db, id: "B-plain", kind: "book")
            try reading(db, id: "B-dead", kind: "book", autoTagId: "T1",
                        deletedAt: "2026-09-01T00:00:00.000Z")
            try db.execute(sql: "DELETE FROM sync_outbox")
        }
        try AppDatabase.migrator.migrate(queue)
        let rows = try queue.read { db in
            try Row.fetchAll(
                db, sql: "SELECT id, auto_tag_id, auto_tag_ids FROM reading ORDER BY id")
        }
        let byID = Dictionary(uniqueKeysWithValues: rows.map { ($0["id"] as String, $0) })
        #expect((byID["B-flows"]?["auto_tag_ids"] as String?) == #"["T1"]"#,
                "a live book's single outflow is carried into a one-element array")
        #expect((byID["B-flows"]?["auto_tag_id"] as String?) == "T1",
                "the old column is left as it is — retired-as-read, never rewritten")
        #expect((byID["B-plain"]?["auto_tag_ids"] as String?) == nil)
        #expect((byID["B-dead"]?["auto_tag_ids"] as String?) == nil,
                "a dead row is not rewritten (its value is irrelevant; an UPDATE would repush a tombstone)")
        // The carried row reaches the outbox (the triggers fire on UPDATE);
        // the untouched rows do not.
        let queued = try queue.read { db in
            try String.fetchAll(db, sql: "SELECT row_id FROM sync_outbox WHERE table_name = 'reading' ORDER BY row_id")
        }
        #expect(queued == ["B-flows"])
    }

    @Test func liveRuleLessGatheringsGoToTheTrashAndNothingElseMoves() throws {
        let ruled = try RuleGrammar.encode(.tag("T1"))
        let queue = try oldStore { db in
            try reading(db, id: "G-ruleless", kind: "gathering")
            try reading(db, id: "G-ruled", kind: "gathering", spec: ruled)
            try reading(db, id: "G-broken", kind: "gathering", spec: "{not json")
            try reading(db, id: "B-ruleless", kind: "book")
            try reading(db, id: "G-dead", kind: "gathering",
                        deletedAt: "2026-09-01T00:00:00.000Z")
            try db.execute(sql: "DELETE FROM sync_outbox")
        }
        try AppDatabase.migrator.migrate(queue)
        let rows = try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT id, deleted_at, updated_at FROM reading")
        }
        let byID = Dictionary(uniqueKeysWithValues: rows.map { ($0["id"] as String, $0) })
        let swept = try #require(byID["G-ruleless"]?["deleted_at"] as String?)
        #expect(swept > Self.now, "a REAL clock stamps the tombstone (the Trash's 30-day window reads it)")
        #expect((byID["G-ruleless"]?["updated_at"] as String?) == swept)
        #expect((byID["G-ruled"]?["deleted_at"] as String?) == nil, "a ruled gathering stands")
        #expect((byID["G-broken"]?["deleted_at"] as String?) == nil,
                "a MALFORMED rule is untouched — it already fails closed and the editor shows it")
        #expect((byID["B-ruleless"]?["deleted_at"] as String?) == nil,
                "a rule-less BOOK is legal — 'collects nothing by itself'")
        #expect((byID["G-dead"]?["deleted_at"] as String?) == "2026-09-01T00:00:00.000Z",
                "an already-dead row keeps its own stamp")
        // The swept row reaches the outbox, and the Trash lists it as a book
        // row with Put back available.
        #expect(try queue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox WHERE table_name = 'reading' AND row_id = 'G-ruleless'")
        } == 1)
        let trashed = try queue.read { db in
            try Queries.trash(db, now: Date(), kinds: [.book]).map(\.id)
        }
        #expect(trashed == ["G-ruleless"])
    }

    // MARK: - The ops (the outflow setter, the mint, the rule write, the apply)

    @Test func theOutflowSetterIsBookOnlyWingScopedOrderedDedupedAndNoOpGuarded() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let book = try ops.createReading(name: "book", kind: .book)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(a.id)))
            #expect(throws: OperationError.wrongReadingKind(id: gathering.id, expected: .book)) {
                try ops.setReadingOutflow(gathering.id, tagIDs: [a.id])
            }
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO tag (id, name, path, wing_id, created_at, updated_at)
                    VALUES ('far', 'far', 'far', 'elsewhere',
                            '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                    """)
            }
            #expect(throws: OperationError.tagNotFound(id: "far")) {
                try ops.setReadingOutflow(book.id, tagIDs: [a.id, "far"])
            }
            // Order preserved, duplicates dropped, stored as ONE JSON array.
            try ops.setReadingOutflow(book.id, tagIDs: [b.id, a.id, b.id])
            let set = try #require(try db.read { try Queries.reading($0, id: book.id) })
            #expect(set.autoTagIDs == [b.id, a.id])
            #expect(set.autoTagIds == "[\"\(b.id)\",\"\(a.id)\"]")
            #expect(set.autoTagId == nil, "the retired column is never written")
            // The no-op guard compares the DECODED set.
            try db.clearOutbox()
            try ops.setReadingOutflow(book.id, tagIDs: [b.id, a.id, a.id])
            #expect(!(try db.outboxContains("reading", book.id)))
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.updatedAt == set.updatedAt)
            // Empty clears to NULL — one spelling of "no outflow".
            try ops.setReadingOutflow(book.id, tagIDs: [])
            #expect(try db.fetchString("SELECT auto_tag_ids FROM reading WHERE id = ?", [book.id]) == nil)
            // The 13i-b forwarder writes a one-element set.
            try ops.setReadingAutoTag(book.id, tagID: a.id)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.autoTagIDs == [a.id])
        }
    }

    @Test func aBookBornWithASetAndTheForwardingParameterMergeInFront() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let book = try ops.createReading(name: "b", kind: .book, autoTagId: a.id, autoTagIDs: [b.id])
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.autoTagIDs == [a.id, b.id])
            #expect(throws: OperationError.self) {
                try ops.createReading(name: "g", kind: .gathering,
                                      querySpec: try RuleGrammar.encode(.tag(a.id)),
                                      autoTagIDs: [a.id])
            }
        }
    }

    @Test func everyOutflowTagRidesAMintAndAHandAddAndADeadOneIsSkipped() throws {
        try withOperations { ops, db in
            let writing = try ops.createTag(name: "writing")
            let poetry = try ops.createTag(name: "poetry")
            let gone = try ops.createTag(name: "gone")
            let book = try ops.createReading(
                name: "verse", kind: .book, autoTagIDs: [writing.id, poetry.id, gone.id])
            try ops.deleteTag(gone.id)
            let minted = try ops.newPostInReading(book.id)
            let worn = { (postID: String) in
                try db.read { db in
                    Set(try String.fetchAll(
                        db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                        arguments: [postID]))
                }
            }
            #expect(try worn(minted.id) == [writing.id, poetry.id],
                    "her example: 'my writing, poetry' — both ride; the dead one is skipped")
            let added = try ops.createPost(title: "by hand")
            _ = try ops.applyTag(poetry.id, toPost: added.id)
            try ops.addPostToReading(added.id, to: book.id)
            #expect(try worn(added.id) == [writing.id, poetry.id], "a hand-add wears what it lacks")
        }
    }

    @Test func tagAllMembersWithNilMeansEveryOutflowTagAndTheOfferCountsMembersMissingAny() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let book = try ops.createReading(name: "book", kind: .book)
            var members: [Container] = []
            for i in 0..<3 {
                let post = try ops.createPost(title: "m\(i)")
                try ops.addPostToReading(post.id, to: book.id)
                members.append(post)
            }
            #expect(throws: OperationError.readingHasNoAutoTag(id: book.id)) {
                try ops.tagAllMembers(book.id)
            }
            #expect(try db.read { try Queries.membersMissingAnyOutflowTag($0, readingID: book.id) } == 0,
                    "no outflow — nothing to offer")
            try ops.setReadingOutflow(book.id, tagIDs: [a.id, b.id])
            // m0 wears both already; m1 wears a only; m2 wears nothing.
            _ = try ops.applyTag(a.id, toPost: members[0].id)
            _ = try ops.applyTag(b.id, toPost: members[0].id)
            _ = try ops.applyTag(a.id, toPost: members[1].id)
            #expect(try db.read { try Queries.membersMissingAnyOutflowTag($0, readingID: book.id) } == 2)
            let touched = try ops.tagAllMembers(book.id)
            #expect(touched == 2, "NOTES newly wearing at least one tag (P-13ic-11)")
            for member in members {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    [member.id]) == 2)
            }
            #expect(try db.read { try Queries.membersMissingAnyOutflowTag($0, readingID: book.id) } == 0)
        }
    }

    @Test func aGatheringIsMintedWithARuleAndKeepsOneWhileABookMayBeCleared() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            #expect(throws: OperationError.self) {
                try ops.createReading(name: "ruleless", kind: .gathering)
            }
            #expect(throws: OperationError.self) {
                try ops.createReading(name: "empty-v1", kind: .gathering, querySpec: "")
            }
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(t.id)))
            #expect(throws: OperationError.gatheringRequiresRule(id: gathering.id)) {
                try ops.setReadingQuerySpec(gathering.id, querySpec: nil)
            }
            #expect(try db.read { try Queries.reading($0, id: gathering.id) }?.querySpec
                    == (try RuleGrammar.encode(.tag(t.id))), "the refusal leaves the rule as it was")
            // The seeders pass rules (the two seeded gatherings are born legal).
            #expect(RuleGrammar.read(try RuleGrammar.encode(.star)) == .rule(.star))
            // A BOOK's kill switch stands: NULL is "collects nothing by itself".
            let book = try ops.createReading(
                name: "b", kind: .book, querySpec: try RuleGrammar.encode(.tag(t.id)))
            try ops.setReadingQuerySpec(book.id, querySpec: nil)
            #expect(try db.read { try Queries.reading($0, id: book.id) }?.querySpec == nil)
        }
    }

    // MARK: - The readers: NO rule on a gathering shows NOTHING (R-13ic-4)

    @Test func aRuleLessGatheringAssemblesEmptyListsNowhereAndRefusesTheCollectDoor() throws {
        try withOperations { ops, db in
            let t = try ops.createTag(name: "t")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(t.id, toPost: note.id)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(t.id)))
            #expect(try db.read { try Queries.assembleReading($0, readingID: gathering.id) }
                        .map(\.postID) == [note.id])
            // The only road to a live rule-less gathering is the Trash: the
            // sweep's shape, reproduced by hand.
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET query_spec = NULL WHERE id = ?",
                               arguments: [gathering.id])
            }
            #expect(try db.read { try Queries.assembleReading($0, readingID: gathering.id) }.isEmpty)
            #expect(try db.read { try Queries.readingsContaining($0, postID: note.id) }.isEmpty,
                    "the chip lists no rule-less gathering")
            #expect(throws: OperationError.self) {
                try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            }
            // And the Trash road round-trips: deleted, listed, restored —
            // still empty until it gets a rule; then it shows again.
            try ops.deleteReading(gathering.id)
            #expect(try db.read { try Queries.trash($0, now: harnessNow, kinds: [.book]) }
                        .map(\.id) == [gathering.id])
            try ops.restoreReading(gathering.id)
            #expect(try db.read { try Queries.assembleReading($0, readingID: gathering.id) }.isEmpty)
            try ops.setReadingQuerySpec(gathering.id, querySpec: try RuleGrammar.encode(.tag(t.id)))
            #expect(try db.read { try Queries.assembleReading($0, readingID: gathering.id) }
                        .map(\.postID) == [note.id])
        }
    }

    @Test func aNoteMintedInABookIsBornInTheBooksWing() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "far", kind: .book, wingId: "W1")
            let post = try ops.newPostInReading(book.id)
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [post.id]) == "W1",
                    "13i-b U1 F-5 closed: the mint lands in the BOOK's wing")
            let home = try ops.createPost(title: "home")
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [home.id]) == "")
        }
    }

    // MARK: - Sync: the column converges by ordinary CAS; old rows read as no outflow

    @Test func twoDevicesEditingOneBooksOutflowConvergeByServerWins() async throws {
        let (a, b, server) = try furniturePair()
        let bookID = try a.with { ops, _ in
            try ops.createReading(name: "shared", kind: .book).id
        }
        try await assertFurnitureConverged(a, b, server)
        let tagA = try a.with { ops, _ in try ops.createTag(parent: nil, name: "from-a") }
        let tagB = try b.with { ops, _ in try ops.createTag(parent: nil, name: "from-b") }
        try await assertFurnitureConverged(a, b, server)
        // Both edit the same book's outflow OFFLINE, then meet.
        try a.with { ops, _ in try ops.setReadingOutflow(bookID, tagIDs: [tagA.id]) }
        try b.with { ops, _ in try ops.setReadingOutflow(bookID, tagIDs: [tagB.id]) }
        try await assertFurnitureConverged(a, b, server)
        let landed = try a.db.fetchString("SELECT auto_tag_ids FROM reading WHERE id = ?", [bookID])
        #expect(landed != nil, "one edit stands (the documented metadata class — whole-set CAS)")
        #expect(try b.db.fetchString("SELECT auto_tag_ids FROM reading WHERE id = ?", [bookID]) == landed)
    }

    @Test func aPreWindowRowWithNoOutflowColumnLandsAsNoOutflow() throws {
        let db = try AppDatabase.inMemory()
        try db.write { database in
            try database.execute(sql: """
                INSERT INTO tag (id, name, path, created_at, updated_at)
                VALUES ('T-OLD', 'old', 'old', '\(Self.now)', '\(Self.now)')
                """)
            let row = SyncRow(
                table: "reading", rowID: "OLD-BOOK",
                columns: [
                    "id": .text("OLD-BOOK"), "owner_id": .null, "name": .text("old"),
                    "kind": .text("book"), "profile": .null, "sort_field": .text("manual"),
                    "sort_dir": .text("asc"), "grouping_tag_id": .null, "query_spec": .null,
                    "max_posts": .null, "word_target": .null, "locked": .integer(0),
                    "wing_id": .text(""), "shelf_id": .null, "shelf_position": .null,
                    "starred": .integer(0), "owned": .integer(0), "sealed_at": .null,
                    "hide_owned": .null, "intake_seating": .null,
                    "auto_tag_id": .text("T-OLD"),  // the retired column, still carried
                    "auto_tag_ids": .null,          // the pre-window mirror's explicit null
                    "created_at": .text(Self.now), "updated_at": .text(Self.now),
                    "deleted_at": .null,
                ], syncVersion: 3)
            try row.apply(database)
        }
        let landed = try db.read { try Queries.reading($0, id: "OLD-BOOK") }
        #expect(landed?.autoTagIDs == [], "no outflow — the retired single tag is never read")
        #expect(landed?.autoTagId == "T-OLD")
    }
}

/// The retirement walk (13i-c, R-13ic-1): NO production code reads the
/// retired single-tag column — only the model (the column still exists), the
/// migration (the carry-over) and the serializer (it still crosses the wire)
/// may name it. A reader creeping back would split the outflow's truth.
@Suite("13i-c — the retired outflow column has no reader")
struct OutflowRetirementTests {
    @Test func noProductionReadOfTheRetiredColumnSurvives() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let allowed: Set<String> = [
            "Sources/VariorumCore/Models/Reading.swift",
            "Sources/VariorumCore/Persistence/Migrations.swift",
            "Sources/VariorumCore/Sync/SyncSchema.swift",
        ]
        var offenders: [String] = []
        for dir in ["Sources", "App/Variorum/Shared", "App/Variorum/Variorum", "App/Variorum/VariorumMobile"] {
            let base = root.appendingPathComponent(dir)
            guard let walker = FileManager.default.enumerator(atPath: base.path) else { continue }
            while let rel = walker.nextObject() as? String {
                guard rel.hasSuffix(".swift") else { continue }
                let path = "\(dir)/\(rel)"
                guard !allowed.contains(path) else { continue }
                let text = try String(contentsOf: base.appendingPathComponent(rel), encoding: .utf8)
                let reads = text.range(of: #"\.autoTagId\b"#, options: .regularExpression) != nil
                    || text.contains("auto_tag_id ")
                    || text.contains("auto_tag_id,")
                    || text.contains("auto_tag_id)")
                if reads { offenders.append(path) }
            }
        }
        #expect(offenders.isEmpty, "readers of the retired column: \(offenders)")
    }
}
