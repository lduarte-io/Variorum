import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U4 — F-U3-3, carried: **the star term's context reaches every site
/// that can meet it.** The rule grammar has a ★ term since 13i-a; its SQL is
/// `c.id IN (<the starred notes>)`, and the list comes from the 'starred'
/// setting (`Queries.starredNoteIDs` — live NOTE targets, star order, bounded
/// by `Operations.starLimit` on the write side). Until U4 only INTAKE passed the
/// list (U1); every other caller took `ruleMatchSQL`'s old `= []` default, so a
/// gathering's ★ term matched NOTHING — silently — in its assembly, the bind
/// that materializes that assembly, the shelf's word count, the Pool's
/// exclusion, the membership chip, the Library card's gathering list and the
/// collect door's probe.
///
/// One pin per SITE CLASS. Each went RED on the pre-U4 tree (the old behaviour
/// was the silent nothing: an empty assembly, zero bound, zero words, the note
/// still in the Pool, no chip, no card line, the collect door refusing) and is
/// green after.
@Suite("13i-b U4 — the star term's context, every site (F-U3-3)")
struct StarContextTests {
    /// Three notes, a tag, and a gathering on `rule`: `starredTagged` wears the
    /// tag AND the star, `taggedOnly` the tag alone, `starredOnly` the star alone.
    private struct World {
        let gathering: Reading
        let starredTagged: Container
        let taggedOnly: Container
        let starredOnly: Container
        let tag: VariorumCore.Tag
    }

    private func world(
        _ ops: Operations, rule: (VariorumCore.Tag) -> RuleTerm
    ) throws -> World {
        let tag = try ops.createTag(name: "drafts")
        let starredTagged = try ops.importPost(title: "a", text: "one two three").container
        let taggedOnly = try ops.importPost(title: "b", text: "four five").container
        let starredOnly = try ops.importPost(title: "c", text: "six").container
        _ = try ops.applyTag(tag.id, toPost: starredTagged.id)
        _ = try ops.applyTag(tag.id, toPost: taggedOnly.id)
        try ops.setStarred(.post(starredTagged.id), starred: true)
        try ops.setStarred(.post(starredOnly.id), starred: true)
        let gathering = try ops.createReading(
            name: "the gathering", kind: .gathering,
            querySpec: try RuleGrammar.encode(rule(tag)))
        return World(
            gathering: gathering, starredTagged: starredTagged, taggedOnly: taggedOnly,
            starredOnly: starredOnly, tag: tag)
    }

    // MARK: - The assembly (the book view, export, the shelf count, the phone)

    @Test func aStarGatheringsAssemblyShowsTheStarredNotesAndUnstarringEvictsAtOnce() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: w.gathering.id).map(\.postID)
            }
            // created_at ascending (a gathering's manual fallback order).
            #expect(shown == [w.starredTagged.id, w.starredOnly.id])

            // Derived, by definition: un-starring is not an act, it is a
            // change of state — the next read simply does not show it.
            try ops.setStarred(.post(w.starredTagged.id), starred: false)
            let afterUnstar = try db.read {
                try Queries.assembleReading($0, readingID: w.gathering.id).map(\.postID)
            }
            #expect(afterUnstar == [w.starredOnly.id])
            // …and no row was ever written for it.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?", [w.gathering.id]) == 0)
        }
    }

    @Test func aTagAndStarRuleNeedsBoth() throws {
        try withOperations { ops, db in
            let w = try world(ops) { .and([.tag($0.id), .star]) }
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: w.gathering.id).map(\.postID)
            }
            #expect(shown == [w.starredTagged.id])
            // NOT ★ — the negation needs the real list too (with the old
            // empty context `NOT (0)` matched EVERY tagged note).
            let notStarred = try ops.createReading(
                name: "unstarred drafts", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(w.tag.id), .not(.star)])))
            let unstarredShown = try db.read {
                try Queries.assembleReading($0, readingID: notStarred.id).map(\.postID)
            }
            #expect(unstarredShown == [w.taggedOnly.id])
        }
    }

    /// Bounded by a ONE-MINUTE time limit on purpose: on the pre-U4 tree the
    /// assembly never read the 'starred' setting, so an un-star re-emitted
    /// NOTHING and the second `next()` would wait forever — the limit turns
    /// that into a failure. Awaiting the observation's own `next()` (the
    /// `ObservationQueryTests` shape) rather than polling a deadline keeps the
    /// pin honest under a full suite's parallel load (a 5 s poll starved there
    /// once — the first emission arrived late, not never).
    @Test(.timeLimit(.minutes(1)))
    func aHeldObservationOfAStarGatheringHearsTheUnstar() async throws {
        try await withOperationsAsync { ops, db in
            let w = try world(ops) { _ in .star }
            var values = db.observeReading(w.gathering.id).makeAsyncIterator()
            let initial = try await values.next()
            #expect(initial?.map(\.postID) == [w.starredTagged.id, w.starredOnly.id])
            // The assembly READ the 'starred' setting, so the observation
            // tracks it: un-starring re-emits without any other write.
            try ops.setStarred(.post(w.starredOnly.id), starred: false)
            let afterUnstar = try await values.next()
            #expect(afterUnstar?.map(\.postID) == [w.starredTagged.id],
                    "un-starring alone re-emitted the gathering")
        }
    }

    // MARK: - The bind (materializes the assembly — F-U3-3's sharpest edge)

    @Test func bindingATagAndStarGatheringBindsItsStarMatches() throws {
        try withOperations { ops, db in
            let w = try world(ops) { .and([.tag($0.id), .star]) }
            // The sheet's count reads the same assembly.
            let count = try db.read {
                try Queries.assembleReading($0, readingID: w.gathering.id).count
            }
            #expect(count == 1)
            try ops.convertSmartReadingToCurated(w.gathering.id)
            let members = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                        """,
                    arguments: [w.gathering.id])
            }
            #expect(members == [w.starredTagged.id])
        }
    }

    // MARK: - The shelf's word counts

    @Test func theWordCountsCountAStarGatheringsNotes() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let counts = try db.read { try Queries.bookWordCounts($0) }
            // "one two three" + "six".
            #expect(counts[w.gathering.id] == 4)
        }
    }

    // MARK: - The Pool's exclusion

    @Test func thePoolDoesNotListANoteAStarGatheringShows() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let pool = try db.read { try Queries.poolPosts($0, limit: 50).map(\.postID) }
            #expect(!pool.contains(w.starredTagged.id))
            #expect(!pool.contains(w.starredOnly.id))
            #expect(pool.contains(w.taggedOnly.id))
        }
    }

    // MARK: - The membership chip

    @Test func theChipListsTheStarGatheringForAStarredNoteOnly() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let (starred, plain) = try db.read { db in
                (try Queries.readingsContaining(db, postID: w.starredOnly.id).map(\.id),
                 try Queries.readingsContaining(db, postID: w.taggedOnly.id).map(\.id))
            }
            #expect(starred == [w.gathering.id])
            #expect(plain.isEmpty)
        }
    }

    // MARK: - The Library card's gathering list

    @Test func theLibraryCardNamesTheStarGatheringOnAStarredNote() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let membership = try db.read {
                try Queries.smartBookMembership(
                    $0, postIDs: [w.starredTagged.id, w.taggedOnly.id, w.starredOnly.id])
            }
            #expect(membership[w.starredTagged.id] == [w.gathering.name])
            #expect(membership[w.starredOnly.id] == [w.gathering.name])
            #expect(membership[w.taggedOnly.id] == nil)
        }
    }

    // MARK: - The collect door's probes

    @Test func theCollectDoorKnowsAStarredNoteAlreadyMatches() throws {
        try withOperations { ops, db in
            let w = try world(ops) { .and([.tag($0.id), .star]) }
            // starredOnly needs the tag: the door applies it and the end
            // probe — which must hear the star — passes.
            let result = try ops.collectPostIntoSmartReading(w.starredOnly.id, into: w.gathering.id)
            #expect(result.alreadyMatched == false)
            #expect(result.appliedTagPaths == ["drafts"])
            #expect(!result.starred, "already starred — never starred again (VX-249)")
            // starredTagged already matches — the FIRST probe says so.
            let again = try ops.collectPostIntoSmartReading(w.starredTagged.id, into: w.gathering.id)
            #expect(again.alreadyMatched)
            // VX-249 (JUSTIFIED EDIT — her answer to the star asymmetry,
            // QUESTIONS #217): this slot pinned the old control, "tagging
            // alone can never satisfy a ★ — an unstarred note still hears the
            // standing honest refusal". The collect door now SETS the star:
            // the unstarred, tagged note collects by starring alone.
            let starring = try ops.collectPostIntoSmartReading(w.taggedOnly.id, into: w.gathering.id)
            #expect(starring.starred)
            #expect(starring.appliedTagPaths.isEmpty)
            #expect(try db.read { try Queries.starredNoteIDs($0) }.contains(w.taggedOnly.id))
        }
    }

    // MARK: - The context's own boundaries

    @Test func theStarTermStaysInsideTheGatheringsWingAndOutOfTheArchive() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            // A starred note moved to another wing by a direct row write (no
            // door crosses wings yet) leaves a Home gathering's assembly;
            // an archived starred note is out of view (the ambient rule).
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET wing_id = 'other-wing' WHERE id = ?",
                    arguments: [w.starredTagged.id])
            }
            try ops.archiveContainer(w.starredOnly.id)
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: w.gathering.id).map(\.postID)
            }
            #expect(shown.isEmpty)
        }
    }

    @Test func aStarredBookIsNeverANoteTarget() throws {
        try withOperations { ops, db in
            let w = try world(ops) { _ in .star }
            let book = try ops.createReading(name: "a book", kind: .book)
            try ops.setStarred(.reading(book.id), starred: true)
            let ids = try db.read { try Queries.starredNoteIDs($0) }
            #expect(ids == [w.starredTagged.id, w.starredOnly.id])
        }
    }
}
