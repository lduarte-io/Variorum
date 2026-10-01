import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U1 — the 13i-a §9 hand-off (a): the rule predicate's tag term walks
/// APPLIED tags by PATH, so before this hardening an application of ANOTHER
/// WING's same-path tag satisfied a Home rule's term. No door can mint that
/// state yet (cross-wing move/copy are 13i-c's), which is why 13i-a recorded
/// it as unpinnable; it IS pinnable by direct row insertion, and the wings
/// ruling ("nothing should cross wings" — the sitting record §9) makes the
/// answer certain: `applied.wing_id = root.wing_id`.
///
/// Both pins below go RED on the pre-hardening tree (the gathering shows the
/// foreign-wing application; the collect door's single-post probe believes
/// it) and green after.
@Suite("13i-b U1 — rule tag terms are wing-scoped (13i-a §9 hand-off a)")
struct RuleWingScopingTests {
    /// A Home tag `work`, a Home gathering on it, a Home note — and a SECOND
    /// wing's twin tag `work` (legal: tag uniqueness is per-wing since
    /// v1_18) applied to that Home note by a direct row write.
    private func crossWingFixture(
        _ ops: Operations, _ db: AppDatabase
    ) throws -> (gathering: Reading, note: Container, homeTag: VariorumCore.Tag) {
        let homeTag = try ops.createTag(name: "work")
        let gathering = try ops.createReading(
            name: "work", kind: .gathering,
            querySpec: try RuleGrammar.encode(.tag(homeTag.id)))
        let note = try ops.createPost(title: "a Home note")
        try db.write { db in
            try db.execute(
                sql: """
                    INSERT INTO tag (id, owner_id, parent_id, name, path, wing_id,
                                     created_at, updated_at)
                    VALUES ('twin-tag', NULL, NULL, 'work', 'work', 'other-wing',
                            '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                    """)
            try db.execute(
                sql: """
                    INSERT INTO post_tag (id, tag_id, post_id, created_at)
                    VALUES ('twin-application', 'twin-tag', ?, '2026-07-01T00:00:00.000Z')
                    """,
                arguments: [note.id])
        }
        return (gathering, note, homeTag)
    }

    @Test func aForeignWingTwinTagNeverSatisfiesAHomeRule() throws {
        try withOperations { ops, db in
            let (gathering, note, _) = try crossWingFixture(ops, db)
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: gathering.id).map(\.postID)
            }
            #expect(!shown.contains(note.id))
            // The same rule SQL serves the Pool's exclusion: the note is
            // NOT shown by any gathering, so the Pool keeps it.
            let pool = try db.read { try Queries.poolPosts($0, limit: 50).map(\.postID) }
            #expect(pool.contains(note.id))
        }
    }

    @Test func aHomeApplicationStillSatisfiesTheRule() throws {
        // The control: the hardening scopes, it does not break matching.
        try withOperations { ops, db in
            let (gathering, note, homeTag) = try crossWingFixture(ops, db)
            _ = try ops.applyTag(homeTag.id, toPost: note.id)
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: gathering.id).map(\.postID)
            }
            #expect(shown == [note.id])
        }
    }

    @Test func theCollectDoorsProbeIsWingScopedToo() throws {
        // `collectPostIntoSmartReading`'s single-post twin of the tag test:
        // on the old tree it believed the foreign twin satisfied the term
        // and reported `alreadyMatched` while the gathering showed nothing.
        try withOperations { ops, db in
            let (gathering, note, homeTag) = try crossWingFixture(ops, db)
            let result = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            #expect(result.alreadyMatched == false)
            #expect(result.appliedTagPaths == ["work"])
            let homeApplied = try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE tag_id = ? AND post_id = ? AND deleted_at IS NULL",
                [homeTag.id, note.id])
            #expect(homeApplied == 1)
        }
    }
}
