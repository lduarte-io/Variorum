import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 17y B-DEDUPE (R-17y-5 to the design memo): the seeded-furniture PAIRWISE
// fold's convergence suites — the two-client fake-server harness, the
// SyncSpec §7 standing rules asserted per scenario (deterministic keeper,
// explicit outbox rows, idempotence, stragglers defer, nil facts inert).

@Suite("Seeded-furniture pairwise fold (17y B-DEDUPE, R-17y-5)")
struct SeededFurnitureDedupeTests {
    // Test-local reserved identities — the suite pins the MECHANISM; the
    // app-side builder (`SampleLibrarySeeder.furnitureDedupeFacts`) reads
    // the minting code's own constants by construction.
    static let classicsName = "classics"
    static let classicsPath = "classics"
    static let starredName = "starred notes"
    static let quicknotesName = "Quicknotes"
    static let quicknotePath = "quicknote"
    static let quicknoteTitle = "a first quick note"
    static let quicknoteText = "Jot a thought from anywhere."
    static let guideName = "the field guide"
    static let guidePath = "tutorial"
    static let poolTitle = "tutorial scraps"

    static func facts(guide: Bool = true) -> SeededFurnitureDedupeFacts {
        SeededFurnitureDedupeFacts(
            guideBookName: guide ? guideName : nil,
            guideTagPath: guide ? guidePath : nil,
            gatherings: [
                .init(name: classicsName, rule: .tagPath(classicsPath)),
                .init(name: starredName, rule: .star),
                .init(
                    name: quicknotesName, rule: .tagPath(quicknotePath),
                    designationKey: "quicknote_book", bornStarred: true),
            ],
            containers: [
                .init(title: quicknoteTitle, kind: "post", seedTagPaths: [quicknotePath]),
            ] + (guide ? [
                .init(title: poolTitle, kind: "pool", seedTagPaths: [guidePath]),
            ] : []),
            hash: BridgeHash.body(_:))
    }

    private func pairWithFacts(guide: Bool = true) throws
        -> (a: SyncClient, b: SyncClient, server: FakeSyncServer)
    {
        let (a, b, server) = try furniturePair()
        a.furnitureFacts = Self.facts(guide: guide)
        b.furnitureFacts = Self.facts(guide: guide)
        return (a, b, server)
    }

    /// Seeds the three gatherings exactly as their mints shape them
    /// (classics ON a welcome shelf; starred notes unshelved; Quicknotes
    /// unshelved, BORN STARRED, designated).
    @discardableResult
    private func seedGatherings(
        _ client: SyncClient
    ) throws -> (classics: String, starred: String, quicknotes: String, tagIDs: [String: String]) {
        try client.with { ops, db in
            let welcome = try ops.ensureWelcomeShelf().shelf
            let classicsTag = try ops.createTag(name: Self.classicsPath)
            let quicknoteTag = try ops.createTag(name: Self.quicknotePath)
            let classics = try ops.createReading(
                name: Self.classicsName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .asc,
                querySpec: try RuleGrammar.encode(.tag(classicsTag.id)),
                shelfId: welcome.id)
            let starred = try ops.createReading(
                name: Self.starredName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.star))
            let quicknotes = try ops.createReading(
                name: Self.quicknotesName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(quicknoteTag.id)))
            try ops.setShelfPinned(quicknotes.id, pinned: true)
            try db.write { db in
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES ('quicknote_book', ?)",
                    arguments: [quicknotes.id])
            }
            return (classics.id, starred.id, quicknotes.id,
                    [Self.classicsPath: classicsTag.id, Self.quicknotePath: quicknoteTag.id])
        }
    }

    @discardableResult
    private func seedQuicknote(_ client: SyncClient) throws -> String {
        try client.with { ops, db in
            let tagID = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
                    arguments: [Self.quicknotePath])
            } ?? (try ops.createTag(name: Self.quicknotePath)).id
            let minted = try ops.importPost(
                title: Self.quicknoteTitle, text: Self.quicknoteText,
                undoLabel: "Quick note")
            _ = try ops.applyTag(tagID, toPost: minted.container.id)
            return minted.container.id
        }
    }

    /// A small guide with the real seed's structural richness: two
    /// chapters, two member notes (one FANNED with a chosen take, one
    /// wearing a callout frame), every member tagged, plus the scraps
    /// pool with a fanned snippet.
    @discardableResult
    private func seedGuide(
        _ client: SyncClient
    ) throws -> (bookID: String, noteIDs: [String], poolID: String) {
        try client.with { ops, db in
            let tag = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
                    arguments: [Self.guidePath])
            } ?? (try ops.createTag(name: Self.guidePath)).id
            // The SHIPPED shape (the round-1 BLOCKER's three legs): the
            // mint's word target, a seed-authored comment, a sealed lesson.
            let book = try ops.createReading(
                name: Self.guideName, kind: .book, profile: "collection",
                wordTarget: 4000)
            let welcome = try ops.createSection(in: book.id, name: "welcome")
            let takes = try ops.createSection(in: book.id, name: "takes")
            let one = try ops.importPost(
                title: "getting around", text: "The first lesson.\n\nIts second paragraph.",
                undoLabel: "Tutorial")
            _ = try ops.addPostToReading(one.container.id, to: book.id)
            try ops.assignPostToSection(one.container.id, in: book.id, section: welcome.id)
            _ = try ops.applyTag(tag, toPost: one.container.id)
            let two = try ops.importPost(
                title: "takes teach by doing", text: "A lesson with a fan.",
                undoLabel: "Tutorial")
            _ = try ops.addPostToReading(two.container.id, to: book.id)
            try ops.assignPostToSection(two.container.id, in: book.id, section: takes.id)
            _ = try ops.applyTag(tag, toPost: two.container.id)
            // The fan + the callout — the structures the Sherlock
            // classifier reads as EDITED and this fold must read as the
            // seed's own shape.
            let fanned = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT cb.block_id AS block, v.id AS variant FROM container_block cb
                        JOIN variant v ON v.block_id = cb.block_id
                        WHERE cb.container_id = ? ORDER BY cb.position LIMIT 1
                        """,
                    arguments: [two.container.id])!
            }
            _ = try ops.branchVariant(fanned["block"] as String, from: fanned["variant"] as String)
            let framed = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? ORDER BY position LIMIT 1",
                    arguments: [one.container.id])!
            }
            try ops.setBlockPresentation(
                framed, BlockPresentation(color: "tipTint"))
            _ = try ops.addBlockComment(
                to: framed,
                text: "a comment lives in the margin — the seed's own hands")
            let sealed = try ops.importPost(
                title: "the seal", text: "A sealed lesson, the mint's own act.",
                undoLabel: "Tutorial")
            _ = try ops.addPostToReading(sealed.container.id, to: book.id)
            try ops.assignPostToSection(sealed.container.id, in: book.id, section: takes.id)
            _ = try ops.applyTag(tag, toPost: sealed.container.id)
            try ops.lockPost(sealed.container.id)
            let pool = try ops.createPool(title: Self.poolTitle)
            let scrap = try ops.newBlock(
                in: pool.id, text: "a scrap with two takes.", at: .end)
            _ = try ops.branchVariant(scrap.block.id, from: scrap.variant.id)
            return (book.id, [one.container.id, two.container.id, sealed.container.id], pool.id)
        }
    }

    private func liveIDs(
        _ client: SyncClient, table: String, where clause: String, _ args: [String]
    ) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM \(table) WHERE \(clause) AND deleted_at IS NULL ORDER BY id",
                arguments: StatementArguments(args))
        }
    }

    private func liveGatherings(_ client: SyncClient, named: String) throws -> [String] {
        try liveIDs(client, table: "reading", where: "name = ?", [named])
    }

    /// Push both, cross-pull with the quiescent second pull each side (the
    /// F2 cadence: arrival batch defers, the empty window decides).
    private func converge(_ a: SyncClient, _ b: SyncClient) async throws {
        try await a.push()
        try await b.push()
        _ = try await b.pull()
        _ = try await b.pull()
        try await b.push()
        _ = try await a.pull()
        _ = try await a.pull()
        try await a.push()
        _ = try await b.pull()
    }

    // MARK: - inert

    @Test func nilFactsAreInert() async throws {
        let (a, b, _) = try furniturePair()
        try seedGatherings(a)
        try seedGatherings(b)
        try await converge(a, b)
        #expect(try liveGatherings(b, named: Self.classicsName).count == 2,
                "no facts, no fold — the standing nil-inert shape")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'furniture_dedupe_pending'") == nil)
    }

    // MARK: - the gathering grain

    @Test func theSeededGatheringTrioConvergesToTheSmallerIDKeepers() async throws {
        let (a, b, server) = try pairWithFacts(guide: false)
        let mintsA = try seedGatherings(a)
        let mintsB = try seedGatherings(b)

        try await converge(a, b)

        for (name, winner, loser) in [
            (Self.classicsName, mintsA.classics, mintsB.classics),
            (Self.starredName, mintsA.starred, mintsB.starred),
            (Self.quicknotesName, mintsA.quicknotes, mintsB.quicknotes),
        ] {
            #expect(try liveGatherings(a, named: name) == [winner], "\(name): A converged")
            #expect(try liveGatherings(b, named: name) == [winner], "\(name): B converged")
            #expect(try b.db.deletedAt("reading", loser) != nil)
        }
        // The keeper's rule resolves to a LIVE tag of the declared path on
        // BOTH devices (the tag fold + the re-point leave no dead term).
        for client in [a, b] {
            let spec = try client.db.fetchString(
                "SELECT query_spec FROM reading WHERE id = ?", [mintsA.classics])
            guard case .rule(.tag(let tagID)) = RuleGrammar.read(spec) else {
                Issue.record("classics keeper carries a tag rule")
                return
            }
            let path = try client.db.fetchString(
                "SELECT path FROM tag WHERE id = ? AND deleted_at IS NULL", [tagID])
            #expect(path == Self.classicsPath, "the keeper's rule names a live classics tag")
        }
        // The designation converged to the keeper on both devices.
        for client in [a, b] {
            #expect(try client.db.fetchString(
                "SELECT value FROM setting WHERE key = 'quicknote_book'") == mintsA.quicknotes)
        }
        try await assertFurnitureConverged(a, b, server)
    }

    @Test func herEngagementKeepsBothGatherings() async throws {
        let (a, b, _) = try pairWithFacts(guide: false)
        try seedGatherings(a)
        let mintsB = try seedGatherings(b)
        try b.with { ops, _ in
            // A rename (classics) and an un-star (Quicknotes) — each the
            // smallest act of hers on that object.
            try ops.renameReading(mintsB.classics, name: "favorites")
            try ops.setShelfPinned(mintsB.quicknotes, pinned: false)
        }

        try await converge(a, b)

        // classics: B's copy is renamed — signature still matches by RULE,
        // but it is no longer the seed's own; BOTH stand everywhere.
        #expect(try liveGatherings(b, named: Self.classicsName).count
                + (try liveGatherings(b, named: "favorites").count) == 2)
        // Quicknotes: the un-starred copy is engaged; both stand.
        #expect(try liveGatherings(b, named: Self.quicknotesName).count == 2)
        // starred notes: untouched on both sides — still folds to one.
        #expect(try liveGatherings(b, named: Self.starredName).count == 1)
    }

    @Test func theKeeperRuleRepointsAndTheDesignationFollows() async throws {
        // A single staged store (repairs are ordinary operations): the
        // keeper gathering's rule names a DEAD tag of the declared path
        // beside a live twin, and the designation names the loser.
        let (a, _, _) = try pairWithFacts(guide: false)
        let staged = try a.with { ops, db -> (keeper: String, loser: String, liveTag: String) in
            let deadTag = try ops.createTag(name: Self.quicknotePath)
            let keeper = try ops.createReading(
                name: Self.quicknotesName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(deadTag.id)))
            try ops.setShelfPinned(keeper.id, pinned: true)
            let liveTag = try ops.createTag(name: "qtmp")
            let loser = try ops.createReading(
                name: Self.quicknotesName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(liveTag.id)))
            try ops.setShelfPinned(loser.id, pinned: true)
            try db.write { db in
                // The tag fold's residue, staged: the keeper's term is dead,
                // a live twin of the path stands.
                try db.execute(
                    sql: "UPDATE tag SET deleted_at = '2026-10-05T00:00:00Z' WHERE id = ?",
                    arguments: [deadTag.id])
                try db.execute(
                    sql: "UPDATE tag SET path = ?, name = ? WHERE id = ?",
                    arguments: [Self.quicknotePath, Self.quicknotePath, liveTag.id])
                // The loser's rule must also read as the seed's shape.
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES ('quicknote_book', ?)",
                    arguments: [loser.id])
            }
            return (keeper.id, loser.id, liveTag.id)
        }
        // Order the pair so the staged "keeper" holds the smaller id.
        let (keeperID, loserID) = staged.keeper < staged.loser
            ? (staged.keeper, staged.loser) : (staged.loser, staged.keeper)

        let engine = a.engine()
        let repairs = try await a.withAsync { db in
            try await db.write { db -> Int in
                var touched = TouchedRows()
                touched.isPullBatch = true
                touched.readingIDs = [keeperID]
                return try engine.dedupeSeededFurniture(db, touched: touched)
            }
        }
        #expect(repairs > 0)
        #expect(try a.db.deletedAt("reading", loserID) != nil)
        #expect(try a.outboxContains("reading", loserID))
        let spec = try a.db.fetchString(
            "SELECT query_spec FROM reading WHERE id = ?", [keeperID])
        guard case .rule(.tag(let tagID)) = RuleGrammar.read(spec) else {
            Issue.record("the keeper keeps a tag rule")
            return
        }
        let live = try a.db.fetchString(
            "SELECT deleted_at FROM tag WHERE id = ?", [tagID])
        #expect(live == nil, "the keeper's rule re-pointed to the live twin")
        #expect(try a.outboxContains("reading", keeperID), "the re-point pushes")
        #expect(try a.db.fetchString(
            "SELECT value FROM setting WHERE key = 'quicknote_book'") == keeperID)
        #expect(try a.outboxContains("setting", "quicknote_book"))
    }

    // MARK: - the note grain

    @Test func twoIdenticalQuicknotesFoldToTheSmallerID() async throws {
        let (a, b, server) = try pairWithFacts(guide: false)
        let noteA = try seedQuicknote(a)
        let noteB = try seedQuicknote(b)

        try await a.push()
        try await b.push()
        _ = try await b.pull()   // arrival: defers, marker armed
        _ = try await b.pull()   // the empty window: the fold runs on B

        let keeper = min(noteA, noteB)
        let loser = max(noteA, noteB)
        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]) == [keeper])
        #expect(try b.db.deletedAt("container", loser) != nil)
        #expect(try b.outboxContains("container", loser),
                "the retirement reaches the outbox explicitly (SyncSpec §7)")

        try await b.push()
        _ = try await a.pull()
        _ = try await a.pull()
        #expect(try liveIDs(
            a, table: "container", where: "title = ?", [Self.quicknoteTitle]) == [keeper])
        try await a.push()
        _ = try await b.pull()
        try await assertFurnitureConverged(a, b, server)
    }

    @Test func anEditedQuicknoteKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts(guide: false)
        try seedQuicknote(a)
        let noteB = try seedQuicknote(b)
        try b.with { ops, db in
            let variant = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.id FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? LIMIT 1
                        """,
                    arguments: [noteB])!
            }
            try ops.autosave(variant, text: "Her own words now.", charDelta: 5)
        }

        try await converge(a, b)

        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "an edited copy is never retired — content differs, both stand")
    }

    @Test func herStarKeepsBothCopiesOnEveryGrain() async throws {
        // 13s U1b ladder round 1, MAJOR-1 (#186(a)'s recorded rule —
        // "starred/un-starred … never merged — both stay, visibly" — and
        // the R-17y-5 letter's "a star change"): HER STAR is engagement on
        // every grain. A note's star lives in the synced 'starred' setting
        // list (the union star's list half); a book's is ALSO its
        // `reading.starred` column. RED ON OLD: neither the container nor
        // the book verdict read either store, so a starred copy classified
        // foldable, could lose the smaller-id toss, and the star folded
        // away silently.
        let (a, b, _) = try pairWithFacts()
        let noteA = try seedQuicknote(a)
        _ = try seedQuicknote(b)
        let guideA = try seedGuide(a)
        _ = try seedGuide(b)
        try a.with { ops, _ in
            try ops.setStarred(.post(noteA), starred: true)
            try ops.setStarred(.reading(guideA.bookID), starred: true)
        }

        try await converge(a, b)

        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "a starred note copy is hers — both stay, visibly (#186(a))")
        #expect(try liveIDs(
            b, table: "reading", where: "name = ?", [Self.guideName]).count == 2,
            "a starred guide copy is hers — both stay")
        #expect(try liveIDs(
            a, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "…and the deciding is deterministic on BOTH devices")
    }

    @Test func herPrivateMarkKeepsBothCopiesOnEveryGrain() async throws {
        // 13n-b U2 ladder round 1, F1 (R-13nb-4 meets the fold's ruled
        // letter — "HER ENGAGEMENT always keeps both"): the Private mark is
        // her hand on a copy, and a fold must never clear a disclosure
        // fence. RED ON OLD: neither `guideVerdict` nor `noteVerdict` read
        // `ai_private_at` (v1_25), so a marked-but-otherwise-pristine copy
        // classified foldable, could lose the smaller-id toss, and the mark
        // folded away silently — the book or note became reachable by
        // standing MCP grants again, on every device.
        let (a, b, _) = try pairWithFacts()
        let noteA = try seedQuicknote(a)
        _ = try seedQuicknote(b)
        let guideA = try seedGuide(a)
        _ = try seedGuide(b)
        try a.with { ops, _ in
            try ops.setNotePrivate(noteA, true)
            try ops.setBookPrivate(guideA.bookID, true)
        }

        try await converge(a, b)

        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "a Private-marked note copy is hers — both stay, the fence stands")
        #expect(try liveIDs(
            b, table: "reading", where: "name = ?", [Self.guideName]).count == 2,
            "a Private-marked guide copy is hers — both stay")
        let marksStand = try a.with { _, db in
            try db.read { db in
                (try Queries.isNotePrivate(db, postID: noteA),
                 try Queries.isBookPrivate(db, readingID: guideA.bookID))
            }
        }
        #expect(marksStand.0, "and the mark itself survives convergence")
        #expect(marksStand.1)
    }

    @Test func aMarkedGatheringRowKeepsBothAsDefense() async throws {
        // Defense only: gatherings REFUSE the mark operations-side
        // (`wrongReadingKind`), so this state needs a raw write — a future
        // peer's bug, not a door. The family's letter is err-toward-keep
        // ("any doubt keeps both"), so a gathering row CARRYING the column
        // is not the seed's own. RED ON OLD: the candidates read ignored it
        // and the marked copy could fold away.
        let (a, b, _) = try pairWithFacts(guide: false)
        try seedGatherings(a)
        let mintsB = try seedGatherings(b)
        try b.with { _, db in
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET ai_private_at = '2026-10-09T00:00:00.000Z' WHERE id = ?",
                    arguments: [mintsB.classics])
            }
        }

        try await converge(a, b)

        #expect(try liveGatherings(b, named: Self.classicsName).count == 2,
                "a marked gathering row is a doubt — both stand")
        #expect(try liveGatherings(b, named: Self.starredName).count == 1,
                "the untouched grain still folds")
    }

    @Test func theSameCommentOnADifferentBlockKeepsBoth() async throws {
        // The round-2 MINOR's pin: the comment tuple carries the block's
        // REAL placement index, so an identical comment TEXT attached to a
        // DIFFERENT block never reads identical. RED ON OLD: the ordinal
        // was first-seen-among-comment-bearers, and this exact pair folded.
        let (a, b, _) = try pairWithFacts(guide: false)
        let twoParagraphs = "First thought.\n\nSecond thought."
        let noteA = try a.with { ops, db -> String in
            let tag = try ops.createTag(name: Self.quicknotePath)
            let minted = try ops.importPost(
                title: Self.quicknoteTitle, text: twoParagraphs, undoLabel: "Quick note")
            _ = try ops.applyTag(tag.id, toPost: minted.container.id)
            let block = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? ORDER BY position LIMIT 1",
                    arguments: [minted.container.id])!
            }
            _ = try ops.addBlockComment(to: block, text: "the same words")
            return minted.container.id
        }
        _ = noteA
        try b.with { ops, db in
            let tag = try ops.createTag(name: Self.quicknotePath)
            let minted = try ops.importPost(
                title: Self.quicknoteTitle, text: twoParagraphs, undoLabel: "Quick note")
            _ = try ops.applyTag(tag.id, toPost: minted.container.id)
            let secondBlock = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? ORDER BY position",
                    arguments: [minted.container.id])[1]
            }
            _ = try ops.addBlockComment(to: secondBlock, text: "the same words")
        }

        try await converge(a, b)

        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "same text, different block — the pair differs, both stand")
    }

    @Test func aForeignTagOnTheQuicknoteKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts(guide: false)
        try seedQuicknote(a)
        let noteB = try seedQuicknote(b)
        try b.with { ops, _ in
            let hers = try ops.createTag(name: "mine")
            _ = try ops.applyTag(hers.id, toPost: noteB)
        }

        try await converge(a, b)

        #expect(try liveIDs(
            b, table: "container", where: "title = ?", [Self.quicknoteTitle]).count == 2,
            "a tag beyond the seed's paths is her organising — engagement")
    }

    // MARK: - the book and pool grains

    @Test func twoIdenticalGuidesFoldWholeFamilyWithTheF2Cadence() async throws {
        let (a, b, server) = try pairWithFacts()
        let guideA = try seedGuide(a)
        let guideB = try seedGuide(b)

        try await a.push()
        try await b.push()
        let arrival = try await b.pull()
        #expect(arrival.applied > 0)
        // The arrival batch DEFERS (the F2 quiescence arm) and leaves the
        // one-shot marker; both copies stand for now.
        #expect(try liveGatherings(b, named: Self.guideName).count == 2)
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'furniture_dedupe_pending'") == "1")

        // The quiescent empty window decides: the fold runs whole.
        let quiescent = try await b.pull()
        #expect(quiescent.repairs > 0, "positive activity at the empty window")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'furniture_dedupe_pending'") == nil)

        let keeper = min(guideA.bookID, guideB.bookID)
        let loser = max(guideA.bookID, guideB.bookID)
        #expect(try liveGatherings(b, named: Self.guideName) == [keeper])
        #expect(try b.db.deletedAt("reading", loser) != nil)
        #expect(try b.outboxContains("reading", loser))
        let loserNotes = loser == guideB.bookID ? guideB.noteIDs : guideA.noteIDs
        for noteID in loserNotes {
            #expect(try b.db.deletedAt("container", noteID) != nil,
                    "the loser's family retires whole (byte-identical — nothing lost)")
            #expect(try b.outboxContains("container", noteID))
        }
        // The scraps POOL folds at its own grain, same keeper rule.
        let poolKeeper = min(guideA.poolID, guideB.poolID)
        #expect(try liveIDs(
            b, table: "container", where: "title = ? AND kind = 'pool'",
            [Self.poolTitle]) == [poolKeeper])

        try await b.push()
        _ = try await a.pull()
        _ = try await a.pull()
        #expect(try liveGatherings(a, named: Self.guideName) == [keeper])
        try await a.push()
        _ = try await b.pull()
        try await assertFurnitureConverged(a, b, server)

        // IDEMPOTENCE: another empty pull decides nothing and writes nothing.
        let again = try await b.pull()
        #expect(again.applied == 0 && again.repairs == 0)
    }

    @Test func herCommentOnAGuideLessonKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts()
        try seedGuide(a)
        let guideB = try seedGuide(b)
        try b.with { ops, db in
            let block = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? ORDER BY position LIMIT 1",
                    arguments: [guideB.noteIDs[1]])!
            }
            _ = try ops.addBlockComment(to: block, text: "her margin note")
        }
        try await converge(a, b)
        #expect(try liveGatherings(b, named: Self.guideName).count == 2,
                "her comment is a tuple the other copy lacks — the pair differs, both stand")
    }

    @Test func herManualSavepointOnAGuideLessonKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts()
        try seedGuide(a)
        let guideB = try seedGuide(b)
        try b.with { ops, db in
            let variant = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.id FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? LIMIT 1
                        """,
                    arguments: [guideB.noteIDs[0]])!
            }
            try ops.commit(variant)
        }
        try await converge(a, b)
        #expect(try liveGatherings(b, named: Self.guideName).count == 2,
                "a MANUAL savepoint is her hand — engagement, both stand")
    }

    @Test func herChapterRenameKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts()
        try seedGuide(a)
        let guideB = try seedGuide(b)
        try b.with { ops, db in
            let chapter = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT id FROM reading_section WHERE reading_id = ? ORDER BY position LIMIT 1",
                    arguments: [guideB.bookID])!
            }
            try ops.renameSection(chapter, name: "her chapter")
        }
        try await converge(a, b)
        #expect(try liveGatherings(b, named: Self.guideName).count == 2,
                "a chapter name rides the identity — the pair differs, both stand")
    }

    @Test func aRemovedMemberKeepsBoth() async throws {
        let (a, b, _) = try pairWithFacts()
        try seedGuide(a)
        let guideB = try seedGuide(b)
        try b.with { ops, _ in
            try ops.removePostFromReading(guideB.noteIDs[0], from: guideB.bookID)
        }
        try await converge(a, b)
        #expect(try liveGatherings(b, named: Self.guideName).count == 2,
                "a dead membership is her act — engagement, both stand")
    }

    @Test func aMemberWhosePostIsGoneMidConvergenceDefers() async throws {
        // The reachable straggler shape under real FKs: a LIVE membership
        // whose post row is TOMBSTONED (cascade timing mid-convergence).
        // The classifier must read STRAGGLING — defer, never judge.
        let (a, _, _) = try pairWithFacts()
        let guide = try seedGuide(a)
        try await a.withAsync { db in
            try await db.write { db in
                try db.execute(
                    sql: "UPDATE container SET deleted_at = '2026-10-05T00:00:00Z' WHERE id = ?",
                    arguments: [guide.noteIDs[0]])
            }
        }
        let halfDead = try await a.db.read { db in
            try SeededFurnitureClassifier.guideVerdict(
                db, copyID: guide.bookID, tagPath: Self.guidePath, hash: BridgeHash.body(_:))
        }
        // The cascade tombstones the membership WITH the post, so a
        // half-killed copy reads ENGAGED — errs to keep, never folds.
        #expect(halfDead == .engaged, "a half-dead copy keeps both, never folds")

        // The TRUE straggler shape (a block whose variant rows have not
        // arrived — the SyncSpec §5 class): STRAGGLING, defer.
        let (c, _, _) = try pairWithFacts()
        let fresh = try seedGuide(c)
        try await c.withAsync { db in
            try await db.write { db in
                try db.execute(
                    sql: """
                        UPDATE variant SET deleted_at = '2026-10-05T00:00:00Z'
                        WHERE block_id IN (SELECT block_id FROM container_block
                                           WHERE container_id = ?)
                        """,
                    arguments: [fresh.noteIDs[0]])
            }
        }
        let straggling = try await c.db.read { db in
            try SeededFurnitureClassifier.guideVerdict(
                db, copyID: fresh.bookID, tagPath: Self.guidePath, hash: BridgeHash.body(_:))
        }
        #expect(straggling == .straggling, "a variant-less block defers, never judges")
    }

    @Test func aDesignationNamingAThirdThingIsLeftAlone() async throws {
        // Single-store (the repair's own promise, apart from the setting's
        // ordinary CAS): two seed-own Quicknotes fold; the designation
        // names HER OWN notebook — neither keeper nor loser — and the
        // repair leaves it byte-alone (§20: re-point ONLY loser→keeper).
        let (a, _, _) = try pairWithFacts(guide: false)
        let staged = try a.with { ops, db -> (hers: String, reading: String) in
            let tag = try ops.createTag(name: Self.quicknotePath)
            let first = try ops.createReading(
                name: Self.quicknotesName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(tag.id)))
            try ops.setShelfPinned(first.id, pinned: true)
            let second = try ops.createReading(
                name: Self.quicknotesName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(tag.id)))
            try ops.setShelfPinned(second.id, pinned: true)
            let hers = try ops.createReading(name: "her own notebook", kind: .book)
            try db.write { db in
                try db.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES ('quicknote_book', ?)",
                    arguments: [hers.id])
            }
            return (hers.id, first.id)
        }
        let engine = a.engine()
        _ = try await a.withAsync { db in
            try await db.write { db -> Int in
                var touched = TouchedRows()
                touched.isPullBatch = true
                touched.readingIDs = [staged.reading]
                return try engine.dedupeSeededFurniture(db, touched: touched)
            }
        }
        #expect(try a.db.fetchString(
            "SELECT value FROM setting WHERE key = 'quicknote_book'") == staged.hers,
            "a third value is hers — the repair never touches it (§20)")
        #expect(try liveGatherings(a, named: Self.quicknotesName).count == 1,
                "…while the fold itself still ran")
    }

    @Test func aRuleNamingANeverArrivedTagDefersThenFolds() async throws {
        // The round-1 MAJOR-3: an ABSENT tag row under a rule is in-flight
        // evidence — the grain defers with its marker (never guesses
        // "not seed's own"), and decides when the row lands.
        let (a, _, _) = try pairWithFacts(guide: false)
        let ghost = "0000ghost-0000-4000-8000-000000000000"
        let staged = try a.with { ops, _ -> (first: String, second: String, live: String) in
            let live = try ops.createTag(name: Self.classicsPath)
            let first = try ops.createReading(
                name: Self.classicsName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .asc,
                querySpec: try RuleGrammar.encode(.tag(ghost)))
            let second = try ops.createReading(
                name: Self.classicsName, kind: .gathering, profile: "collection",
                sortField: .createdAt, sortDir: .asc,
                querySpec: try RuleGrammar.encode(.tag(live.id)))
            return (first.id, second.id, live.id)
        }
        let engine = a.engine()
        let deferredRepairs = try await a.withAsync { db in
            try await db.write { db -> Int in
                var touched = TouchedRows()
                touched.isPullBatch = true
                touched.readingIDs = [staged.first]
                return try engine.dedupeSeededFurniture(db, touched: touched)
            }
        }
        #expect(deferredRepairs == 0, "the absent row defers — nothing judged")
        #expect(try liveGatherings(a, named: Self.classicsName).count == 2)
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'furniture_dedupe_pending'") == "1",
            "…and the marker is armed (the old reading guessed and armed nothing)")

        // The tag row lands — already folded by the tag.path repair in the
        // same apply (DEAD beside the live twin, the readable residue this
        // classifier is built for): the next pass — the marker's own
        // occasion — reads the path off the dead row and folds.
        try await a.withAsync { db in
            try await db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO tag (id, name, path, wing_id, created_at, updated_at, deleted_at)
                        VALUES (?, ?, ?, '', '2026-10-05T00:00:00Z', '2026-10-05T00:00:00Z',
                                '2026-10-05T00:00:01Z')
                        """,
                    arguments: [ghost, Self.classicsPath, Self.classicsPath])
            }
        }
        let folded = try await a.withAsync { db in
            try await db.write { db -> Int in
                try engine.dedupeSeededFurniture(db, touched: TouchedRows(isPullBatch: true))
            }
        }
        #expect(folded > 0)
        #expect(try liveGatherings(a, named: Self.classicsName).count == 1)
    }

    @Test func anEditedLessonKeepsBothGuides() async throws {
        let (a, b, _) = try pairWithFacts()
        try seedGuide(a)
        let guideB = try seedGuide(b)
        try b.with { ops, db in
            // Her edit on an UNCHOSEN take — invisible to rendered text,
            // visible to the structural skeleton.
            let unchosen = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.id FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ?
                          AND v.id NOT IN (
                            SELECT chosen_variant_id FROM container_block
                            WHERE container_id = ? AND chosen_variant_id IS NOT NULL)
                        ORDER BY v.fan_position DESC LIMIT 1
                        """,
                    arguments: [guideB.noteIDs[1], guideB.noteIDs[1]])!
            }
            try ops.autosave(unchosen, text: "her quiet rewrite", charDelta: 3)
        }

        try await converge(a, b)

        #expect(try liveGatherings(b, named: Self.guideName).count == 2,
                "content differs (an unchosen take) — both survive")
        #expect(try liveGatherings(a, named: Self.guideName).count == 2)
    }
}
