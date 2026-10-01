import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **13k K4 — the SMART books collecting a PAGE of notes.**
///
/// Her ruling, 2026-08-02, reversing the shipped curated-only note card
/// (QUESTIONS #51(c)): *"the number of specifically defined smart books you
/// have is probably small, no? you still have to choose to deliberately
/// create a smart book."*
///
/// The suite has two halves and both matter. The first is ordinary
/// correctness (it is `readingsContaining`'s per-post probe generalised to a
/// page, so it must agree with it row for row). The second is **P1, pinned on
/// the STATEMENT'S PLAN** — the measurement at the proposal gate found that
/// the obvious `WHERE c.id IN (SELECT value FROM json_each(?))` shape lets
/// SQLite drive from `idx_container_kind` and scan the whole corpus, so the
/// join order is not a style choice and the pin guards exactly that.
@Suite("Smart-book membership for a page (13k K4)")
struct SmartBookMembershipTests {
    private func seedTag(_ ops: Operations, path: String) throws -> VariorumCore.Tag {
        // `Tag` is also a Swift Testing type — qualify, as the house does.
        var parent: VariorumCore.Tag?
        for segment in path.split(separator: "/") {
            parent = try ops.createTag(parent: parent?.id, name: String(segment))
        }
        return parent!
    }

    // MARK: - Correctness

    @Test func aPagesNotesNameTheSmartBooksThatCollectThem() throws {
        try withOperations { ops, db in
            let stars = try seedTag(ops, path: "stars")
            let dreams = try seedTag(ops, path: "dreams")
            let starBook = try ops.createReading(name: "star-notes", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            try ops.setReadingQuerySpec(
                starBook.id,
                querySpec: Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            let dreamBook = try ops.createReading(name: "dream-notes", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            try ops.setReadingQuerySpec(
                dreamBook.id,
                querySpec: Queries.SmartQuerySpec(tags: ["dreams"]).encodedJSON())

            let both = try ops.createPost(title: "Both")
            _ = try ops.applyTag(stars.id, toPost: both.id)
            _ = try ops.applyTag(dreams.id, toPost: both.id)
            let starred = try ops.createPost(title: "Starred")
            _ = try ops.applyTag(stars.id, toPost: starred.id)
            let plain = try ops.createPost(title: "Plain")

            let page = [both.id, starred.id, plain.id]
            let membership = try db.read {
                try Queries.smartBookMembership($0, postIDs: page)
            }
            // Alphabetical by the readings listing's own (name, id) order.
            #expect(membership[both.id] == ["dream-notes", "star-notes"])
            #expect(membership[starred.id] == ["star-notes"])
            #expect(membership[plain.id] == nil)
        }
    }

    /// It is `readingsContaining` generalised, so it must AGREE with it —
    /// otherwise the card and the membership chip would tell one note two
    /// different stories.
    @Test func theBoundedReadAgreesWithThePerNoteChipRowForRow() throws {
        try withOperations { ops, db in
            let stars = try seedTag(ops, path: "life/stars")
            let book = try ops.createReading(name: "starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            // Subtree semantics: a tag AT or UNDER the path matches.
            try ops.setReadingQuerySpec(
                book.id,
                querySpec: Queries.SmartQuerySpec(tags: ["life"]).encodedJSON())
            let curated = try ops.createReading(name: "hand-made", kind: .book)

            let tagged = try ops.createPost(title: "Tagged")
            _ = try ops.applyTag(stars.id, toPost: tagged.id)
            try ops.addPostToReading(tagged.id, to: curated.id)
            let untagged = try ops.createPost(title: "Untagged")

            try db.read { database in
                for id in [tagged.id, untagged.id] {
                    let chip = try Queries.readingsContaining(database, postID: id)
                        .filter { $0.kind == .gathering }.map(\.name)
                    let page = try Queries.smartBookMembership(
                        database, postIDs: [tagged.id, untagged.id])[id] ?? []
                    #expect(chip == page, "the card and the chip must agree for \(id)")
                }
            }
        }
    }

    /// The ambient-view rule, inherited rather than re-decided: an ARCHIVED
    /// note matches no smart book (its curated rows still list — the recovery
    /// surfaces show where things belonged).
    @Test func anArchivedNoteMatchesNoSmartBook() throws {
        try withOperations { ops, db in
            let stars = try seedTag(ops, path: "stars")
            let book = try ops.createReading(name: "starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            try ops.setReadingQuerySpec(
                book.id,
                querySpec: Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            let post = try ops.createPost(title: "Filed away")
            _ = try ops.applyTag(stars.id, toPost: post.id)

            #expect(try db.read {
                try Queries.smartBookMembership($0, postIDs: [post.id])
            }[post.id] == ["starred"])

            try ops.archiveContainer(post.id)
            #expect(try db.read {
                try Queries.smartBookMembership($0, postIDs: [post.id])
            }[post.id] == nil)
        }
    }

    /// A MALFORMED spec is skipped, never crashes — the ratified fail-closed
    /// rule `assembleReading` and `readingsContaining` already keep. An empty
    /// page reads as nothing rather than as everything.
    @Test func aMalformedSpecIsSkippedAndAnEmptyPageReadsAsNothing() throws {
        try withOperations { ops, db in
            let broken = try ops.createReading(name: "broken", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            try db.write { database in
                try database.execute(
                    sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                    arguments: ["{not json", broken.id])
            }
            let post = try ops.createPost(title: "Anything")
            #expect(try db.read {
                try Queries.smartBookMembership($0, postIDs: [post.id])
            }.isEmpty)
            #expect(try db.read {
                try Queries.smartBookMembership($0, postIDs: [])
            }.isEmpty)
        }
    }

    /// A note NOT on the page is never reported, whatever it matches — the
    /// whole point of the bound.
    @Test func onlyThePagesOwnNotesComeBack() throws {
        try withOperations { ops, db in
            let stars = try seedTag(ops, path: "stars")
            let book = try ops.createReading(name: "starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            try ops.setReadingQuerySpec(
                book.id,
                querySpec: Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
            let onPage = try ops.createPost(title: "On the page")
            _ = try ops.applyTag(stars.id, toPost: onPage.id)
            let offPage = try ops.createPost(title: "Off the page")
            _ = try ops.applyTag(stars.id, toPost: offPage.id)

            let membership = try db.read {
                try Queries.smartBookMembership($0, postIDs: [onPage.id])
            }
            #expect(membership.keys.sorted() == [onPage.id])
        }
    }

    // MARK: - P1: the PAGE drives, pinned on the plan

    /// **The mechanism pin, and it is deliberately the PLAN rather than a
    /// clock.** The proposal gate MEASURED the two shapes: driving from
    /// `json_each` costs the same at 10× the corpus (0.15 ms for a 200-row
    /// page at one book), and the `c.id IN (SELECT …)` shape costs 4× more at
    /// 10× the corpus because SQLite picks `idx_container_kind` and scans
    /// every post. A timing pin would restate that finding noisily; the join
    /// ORDER is what makes it true, so the join order is what is asserted —
    /// read off the REAL statement (`smartMembershipSQL`), never a copy that
    /// could drift from what ships.
    ///
    /// DISCRIMINATING REVERT (verified): rewrite `smartMembershipSQL` as
    /// `FROM container c WHERE c.id IN (SELECT value FROM json_each(?)) AND …`
    /// and this test fails on both expectations — the plan drives from
    /// `idx_container_kind` and the container is no longer a PK seek.
    @Test func thePAGEDrivesAndTheContainerIsAPrimaryKeySeek() throws {
        try withOperations { ops, db in
            let stars = try seedTag(ops, path: "stars")
            let post = try ops.createPost(title: "Anything")
            _ = try ops.applyTag(stars.id, toPost: post.id)

            // 13i-a: the statement takes the v2 rule (the tag by ID) + the
            // wing scope; the plan pin's subject — the join order — is
            // unchanged.
            let statement = Queries.smartMembershipSQL(
                .tag(stars.id), wingID: "", starredNoteIDs: [])
            let json = String(
                decoding: try JSONEncoder().encode([post.id]), as: UTF8.self)
            let plan = try db.read { database in
                try Row.fetchAll(
                    database, sql: "EXPLAIN QUERY PLAN \(statement.sql)",
                    arguments: StatementArguments([json] + statement.arguments))
                    .map { ($0["detail"] as String?) ?? "" }
            }
            let joined = plan.joined(separator: "\n")
            // The page is the OUTER loop…
            // (SQLite names the ALIAS, not the function: "SCAN j VIRTUAL
            // TABLE INDEX 1:". Under the IN-subquery shape this first row
            // reads "SEARCH c USING INDEX idx_container_kind (kind=?)".)
            #expect(plan.first?.hasPrefix("SCAN j VIRTUAL TABLE") == true,
                    "the page must drive the join; plan was:\n\(joined)")
            // …and the container is reached by its PRIMARY KEY, never by a
            // corpus-wide index scan.
            #expect(joined.contains("SEARCH c USING INDEX sqlite_autoindex_container_1"),
                    "the container must be a PK seek; plan was:\n\(joined)")
            #expect(!joined.contains("SEARCH c USING INDEX idx_container_kind"),
                    "driving from kind scans the corpus (the measured P1 loss)")
        }
    }
}
