//
//  SearchSavepointFacetTests.swift
//  VariorumCoreTests
//
//  VX-72 (the 13o follow-up run's U-C — her R-VX83-5, "search what you
//  saved"; the chip `+ commits`, R-VX83-9), P3 — the COMPOSER's half:
//
//  - THE FENCE (the unit's most load-bearing pin, the §U-C RULINGS'
//    condition 2): off the commits facet a savepoint NEVER lists — on every
//    statement the one composer builds (passages, groups, counts, the worn
//    notes' group facts), in every scope and under every visibility, the
//    archived facet included — and every default statement carries the
//    doc-row kind fence itself;
//  - the facet's road: a savepoint lists under its take's block's home, with
//    its day, ranked under the living take (P-VX83-C2), counted as its own
//    kind (P-VX83-C3), its `rendered` its TAKE's (the landing's rule,
//    P-VX83-C4);
//  - its liveness BY KEY at query time (FORK 1 = A): a dead take's, a dead
//    block's and a released block's savepoints never list, and Put back
//    brings them back with no machinery;
//  - orthogonal to the archived facet (P-VX83-C1), the version fence, the
//    wing, the scraps family; and the plan (EXPLAIN).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private var utc: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}

private func question(
    _ text: String, visibility: SearchVisibility = .living, savepoints: Bool
) -> SearchQuery {
    var query = SearchQueryParser.parse(text, typeAhead: true, visibility: visibility,
                                        locale: Locale(identifier: "en_US"), calendar: utc)
    query.includesSavepoints = savepoints
    return query
}

private func passages(
    _ db: AppDatabase, _ text: String, wing: String = "", within: SearchScope.Within = .library,
    visibility: SearchVisibility = .living, savepoints: Bool
) throws -> [SearchPassage] {
    try db.read { db in
        try Queries.searchPassages(
            db, query: question(text, visibility: visibility, savepoints: savepoints),
            scope: SearchScope(wingID: wing, within: within), limit: 200, calendar: utc).passages
    }
}

private func ids(_ passages: [SearchPassage]) -> [String] { passages.map(\.id).sorted() }

@Suite("VX-72 — the commits facet (the fence, the road, liveness by key)")
struct SearchSavepointFacetTests {
    // MARK: - THE FENCE — a savepoint never lists without the facet

    /// **The unit's most load-bearing pin.** A word that lives ONLY in
    /// savepoints — a take's old text, kept by ⌘S and by a quiet auto
    /// savepoint, in a note that is in a book — is invisible to every road
    /// the one composer serves when the facet is off: the passage page in
    /// every scope (library · the note · the book) under every visibility,
    /// the answer sheet's groups, the band's counts (no note, no passage, no
    /// savepoint counted, no archived place added). The facet ON finds both.
    @Test func aSavepointNeverListsWithoutTheFacet() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "lanterns along the quay")
            let manual = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "lanterns along the shore", charDelta: 5)
            let quiet = try #require(try ops.closeAutoCommit(post.id).first)
            try ops.autosave(minted.variant.id, text: "the take moved on entirely", charDelta: 20)
            let book = try ops.createReading(name: "Sea Book", kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)

            for visibility in SearchVisibility.allCases {
                for within: SearchScope.Within in [.library, .note(id: post.id), .book(id: book.id)] {
                    #expect(try passages(db, "lanterns ", within: within, visibility: visibility, savepoints: false)
                        .isEmpty, "never without the facet — \(visibility), \(within)")
                }
                let (groups, counts) = try db.read { db in
                    (try Queries.searchGroups(db, query: question("lanterns ", visibility: visibility, savepoints: false),
                                              scope: SearchScope(wingID: ""), calendar: utc),
                     try Queries.searchCounts(db, query: question("lanterns ", visibility: visibility, savepoints: false),
                                              scope: SearchScope(wingID: ""), calendar: utc))
                }
                #expect(groups.groups.isEmpty, "the answer sheet lists no group — \(visibility)")
                let kinds = try #require(counts)
                #expect(kinds.living.isEmpty && kinds.all.isEmpty && kinds.archivedPlaces == 0,
                        "the band counts nothing — \(visibility): \(kinds)")
            }

            // The facet ON: both savepoints, in their note, under their block.
            let found = try passages(db, "lanterns ", savepoints: true)
            #expect(ids(found) == ["savepoint:\(manual.id)", "savepoint:\(quiet.id)"].sorted())
            #expect(found.allSatisfy { $0.noteID == post.id && $0.blockID == minted.block.id && $0.family == .notes })
        }
    }

    /// The fence is the DOC-ROW KIND predicate on every default statement
    /// (condition 2's letter): off the facet the composer's statements carry
    /// `d.kind <> 'savepoint'` and never seek a take; under it they seek the
    /// take by key instead. Structural, so the fence itself is pinned — not
    /// only its effect (a savepoint doc also carries no home fact, a second
    /// line of defense the behavioral pin cannot tell apart from the first).
    @Test func everyDefaultStatementCarriesTheKindFence() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            for savepoints in [false, true] {
                for visibility in SearchVisibility.allCases {
                    for within: SearchScope.Within in [.library, .note(id: "n"), .book(id: "b")] {
                        let query = question("harbor lig", visibility: visibility, savepoints: savepoints)
                        let scope = SearchScope(wingID: "w", within: within)
                        let statements = try [
                            try SearchComposer.passages(query, scope: scope, after: nil, limit: 50, environment: environment),
                            try SearchComposer.groups(query, scope: scope, after: nil, limit: 25, perGroup: 3,
                                                      environment: environment),
                            try SearchComposer.counts(query, scope: scope, wornLivingNoteIDs: "[]", wornAllNoteIDs: "[]",
                                                      wornArchivedNoteIDs: "[]", environment: environment),
                            try SearchComposer.wornGroupFacts(query, scope: scope, homeIDsJSON: "[]",
                                                              environment: environment),
                        ].map { try #require($0).sql }
                        for sql in statements {
                            if savepoints {
                                #expect(sql.contains("(d.kind <> 'savepoint' OR sv.id IS NOT NULL)"))
                                #expect(sql.contains("LEFT JOIN variant sv ON sv.id = d.variant_id AND sv.deleted_at IS NULL"))
                            } else {
                                #expect(sql.contains("AND d.kind <> 'savepoint'\n"), "the fence — \(visibility), \(within)")
                                #expect(!sql.contains(" sv.") && !sql.contains("commit_point"),
                                        "off the facet no statement seeks a take or a savepoint's day")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - The facet's road

    @Test func underTheFacetASavepointListsWithItsDayRankedUnderTheLivingTake() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Tides")
            let minted = try ops.newBlock(in: post.id, text: "the tide turns at noon")
            let shown = try ops.commit(minted.variant.id)          // same words as the take
            let branch = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(branch.id, text: "the tide turns at midnight", charDelta: 4)
            let unshown = try ops.commit(branch.id)

            let found = try passages(db, "tide ", savepoints: true)
            // Ranking (P-VX83-C2): the living takes lead, their savepoints follow.
            let kinds = found.map(\.kind)
            #expect(kinds.firstIndex(of: .savepoint)! > kinds.lastIndex(of: .take)!,
                    "every savepoint ranks under the living takes holding the same words: \(found.map(\.id))")
            let byID = Dictionary(uniqueKeysWithValues: found.map { ($0.sourceID, $0) })
            let shownHit = try #require(byID[shown.id])
            let unshownHit = try #require(byID[unshown.id])
            #expect(shownHit.isRenderedTake, "a savepoint of the take the note shows (the landing STEPS)")
            #expect(!unshownHit.isRenderedTake, "a savepoint of an unrendered take (the landing ARMS)")
            #expect(shownHit.savedAt == DateFormatter.variorumISO8601.string(from: shown.createdAt)
                    && unshownHit.savedAt == DateFormatter.variorumISO8601.string(from: unshown.createdAt),
                    "its moment rides the page row (the commit's own stamp)")
            #expect(found.filter { $0.kind != .savepoint }.allSatisfy { $0.savedAt == nil })

            // The counts: the savepoints are their own kind; passages stay living.
            let counts = try #require(try db.read { db in
                try Queries.searchCounts(db, query: question("tide ", savepoints: true),
                                         scope: SearchScope(wingID: ""), calendar: utc)
            })
            #expect(counts.living == .init(books: 0, notes: 1, passages: 2, scraps: 0, savepoints: 2), "\(counts)")

            // The answer sheet's group carries them among its lines.
            let groups = try db.read { db in
                try Queries.searchGroups(db, query: question("tide ", savepoints: true),
                                         scope: SearchScope(wingID: ""), perGroup: 10, calendar: utc)
            }
            #expect(groups.groups.count == 1 && groups.groups[0].lineCount == 4)
            #expect(groups.groups[0].lines.filter { $0.kind == .savepoint }.allSatisfy { $0.savedAt != nil })

            // A note found ONLY through a savepoint counts as a note.
            try ops.autosave(minted.variant.id, text: "calm water", charDelta: 10)
            try ops.autosave(branch.id, text: "calm water", charDelta: 10)
            let only = try #require(try db.read { db in
                try Queries.searchCounts(db, query: question("noon ", savepoints: true),
                                         scope: SearchScope(wingID: ""), calendar: utc)
            })
            #expect(only.living == .init(books: 0, notes: 1, passages: 0, scraps: 0, savepoints: 1))
        }
    }

    // MARK: - Liveness by key (FORK 1 = A)

    @Test func aSavepointListsOnlyWhileItsTakeAndItsPlacementLive() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Reach")
            let first = try ops.newBlock(in: post.id, text: "x")
            let branch = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.autosave(branch.id, text: "a branched beacon", charDelta: 10)
            let onBranch = try ops.commit(branch.id)
            try ops.autosave(first.variant.id, text: "the main beacon", charDelta: 10)
            let onMain = try ops.commit(first.variant.id)
            func listed() throws -> [String] {
                try passages(db, "beacon ", savepoints: true).filter { $0.kind == .savepoint }.map(\.sourceID).sorted()
            }
            #expect(try listed() == [onBranch.id, onMain.id].sorted())

            // A dead take's savepoints never list (indexed, P2 — never listed).
            try ops.deleteVariant(branch.id)
            #expect(try listed() == [onMain.id])

            // A dead block's; then Put back — they list again, no machinery.
            try ops.deleteBlock(first.block.id)
            #expect(try listed().isEmpty)
            _ = try ops.restoreBlock(first.block.id)
            #expect(try listed() == [onMain.id], "the block's Put back revives its takes; the branch died on its own")

            // A RELEASED block (merged into a fresh one — lineage) never lists:
            // no home to land in (P-13o-U1-8's letter).
            let second = try ops.newBlock(in: post.id, text: "a second paragraph")
            _ = try ops.merge(first.block.id, second.block.id)
            #expect(try listed().isEmpty, "a released block's savepoints have no home")
        }
    }

    // MARK: - Orthogonal facets, the version fence, wings, scraps

    @Test func theFacetComposesWithArchivedWingsScrapsAndTheVersionFence() throws {
        try withOperations { ops, db in
            // An archived TAKE's savepoint is archived history (P-VX83-C1).
            let post = try ops.createPost(title: "Ledger")
            let minted = try ops.newBlock(in: post.id, text: "x")
            let shelved = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(shelved.id, text: "an ember kept", charDelta: 10)
            let kept = try ops.commit(shelved.id)
            try ops.archiveVariant(shelved.id)
            // An archived NOTE's savepoint, likewise.
            let stored = try ops.createPost(title: "Stored")
            let storedBlock = try ops.newBlock(in: stored.id, text: "an ember stored")
            let storedSave = try ops.commit(storedBlock.variant.id)
            try ops.archiveContainer(stored.id)

            func found(_ visibility: SearchVisibility, wing: String = "") throws -> Set<String> {
                Set(try passages(db, "ember ", wing: wing, visibility: visibility, savepoints: true)
                    .filter { $0.kind == .savepoint }.map(\.sourceID))
            }
            #expect(try found(.living).isEmpty, "archived history waits for + archived too")
            #expect(try found(.includingArchived) == [kept.id, storedSave.id])
            #expect(try found(.archivedOnly) == [kept.id, storedSave.id])
            let archivedHit = try #require(try passages(db, "ember ", visibility: .includingArchived, savepoints: true)
                .first { $0.sourceID == kept.id })
            #expect(archivedHit.isArchived, "the line says it is archived")

            // A saved VERSION never lists under any facet (the ruled posture):
            // sealing it insures its dirty takes — those savepoints are the
            // version's and stay fenced.
            let live = try ops.createPost(title: "Versioned")
            let liveBlock = try ops.newBlock(in: live.id, text: "a cinder saved")
            _ = try ops.commit(liveBlock.variant.id)
            let version = try ops.saveNoteVersion(live.id)
            #expect(try db.fetchInt("""
                SELECT count(*) FROM search_doc d JOIN variant v ON v.id = d.variant_id
                JOIN container_block pl ON pl.block_id = v.block_id AND pl.deleted_at IS NULL
                WHERE d.kind = 'savepoint' AND pl.container_id = ?
                """, [version.post.id]) ?? 0 > 0, "the version's seal DID save its takes — the fence is exercised")
            let all = try passages(db, "cinder ", visibility: .includingArchived, savepoints: true)
            #expect(!all.contains { $0.noteID == version.post.id }, "no hit of the version, savepoint or not")
            #expect(all.contains { $0.kind == .savepoint && $0.noteID == live.id })

            // Wings isolate; the scraps room is shared (P-13o-U1-5).
            let wing = try ops.createWing(name: "Away")
            let away = try ops.createPost(title: "Away", wingId: wing.id)
            let awayBlock = try ops.newBlock(in: away.id, text: "a spark abroad")
            let awaySave = try ops.commit(awayBlock.variant.id)
            let pool = try ops.createPool(title: "Scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "a spark in the scraps")
            let scrapSave = try ops.commit(scrap.variant.id)
            func sparks(_ wing: String) throws -> [SearchPassage] {
                try passages(db, "spark ", wing: wing, savepoints: true).filter { $0.kind == .savepoint }
            }
            #expect(Set(try sparks("").map(\.sourceID)) == [scrapSave.id], "another wing's savepoint never crosses")
            #expect(Set(try sparks(wing.id).map(\.sourceID)) == [awaySave.id, scrapSave.id])
            #expect(try sparks("").first?.family == .scraps, "a scrap's savepoint is in the scraps family")
        }
    }

    // MARK: - The plan

    /// The facet's road SEEKS: the take by key, the placement through I2, the
    /// block, the home — never a walk of the takes or the placements; and a
    /// savepoint's day is read by its key for the page rows only.
    @Test func theFacetsRoadSeeksTheTakeByKey() throws {
        let db = try AppDatabase.inMemory()
        let plan: [String] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            let statement = try #require(try SearchComposer.passages(
                question("harbor lights", savepoints: true), scope: SearchScope(wingID: ""),
                after: nil, limit: 50, environment: environment))
            return try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                arguments: Queries.arguments(statement.arguments)).map { $0["detail"] as String }
        }
        let text = plan.joined(separator: "\n")
        #expect(text.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "the FTS index drives:\n\(text)")
        for seek in ["SEARCH d USING INTEGER PRIMARY KEY",
                     "SEARCH sv USING INDEX sqlite_autoindex_variant_1 (id=?)",
                     "SEARCH pl USING INDEX uq_cblock_ownership (block_id=?)",
                     "SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)",
                     "SEARCH b USING INDEX sqlite_autoindex_block_1 (id=?)",
                     "SEARCH cp USING INDEX sqlite_autoindex_commit_point_1 (id=?)"] {
            #expect(text.contains(seek), "\(seek) — missing:\n\(text)")
        }
        for alias in ["d", "sv", "pl", "c", "b", "cp", "variant", "commit_point", "container_block"] {
            #expect(!plan.contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                    "SCAN \(alias) is a corpus walk:\n\(text)")
        }
    }
}
