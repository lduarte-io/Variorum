import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Pre-13u Act 0, the Fable `Sync/` half (R-pre13u-8): the sample-library
// pristine-copy dedupe. Shares the furniture-repair plumbing in
// FurnitureConvergenceRepairTests.swift (same birth defect, same trio of
// SyncSpec §7 assertions).

// MARK: - The sample-library pristine-copy dedupe (R-pre13u-8)

/// Two seeded sample libraries meeting: identified by the seeder's own
/// discover predicate (the reserved book name, injected), classified per
/// NOTE against the bundled manifest's hashes. Both pristine → deterministic
/// keeper (smaller id); exactly one edited → the EDITED copy is kept; both
/// edited → both survive. An edited copy is NEVER silently retired.
@Suite("Sample-library pristine-copy dedupe (pre-13u Act 0, R-pre13u-8)")
struct SampleLibraryDedupeRepairTests {
    static let bookName = "the adventures of sherlock holmes"
    static let tagPath = "sherlock holmes"
    /// A tiny stand-in library: the manifest's per-note rule is what is
    /// under test, not half a megabyte of Doyle. One multi-paragraph note
    /// exercises the importPost → renderedText round-trip the real
    /// manifest's hashes ride on.
    static let notes: [(title: String, text: String)] = [
        ("About this book", "Attribution text."),
        ("A Scandal in Bohemia", "To Sherlock Holmes she is always THE woman.\n\nSecond paragraph."),
    ]

    static func facts(seedTagPaths: [String] = []) -> SampleLibraryDedupeFacts {
        let hashes = Dictionary(
            uniqueKeysWithValues: notes.map { ($0.title, BridgeHash.body($0.text)) })
        return SampleLibraryDedupeFacts(
            bookName: bookName, tagPath: tagPath,
            loadNoteHashes: { hashes }, hash: BridgeHash.body(_:),
            seedTagPaths: seedTagPaths)
    }

    /// The manifest hash recipe, pinned to independently computed vectors
    /// (carried from the retired bridge's `FragmentsContractTests` at the
    /// 2026-09-04 retirement — `BridgeHash` moved to core `Domain/` with the
    /// name kept). The BUNDLED manifest's hashes were computed with it: a
    /// drift would mark every shipped copy EDITED and never pristine again.
    @Test func theManifestHashRecipeIsStableSHA256Hex() {
        // Independently computed: echo -n "hello" | shasum -a 256
        #expect(BridgeHash.body("hello")
                == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        #expect(BridgeHash.body("")
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(BridgeHash.body("hello") != BridgeHash.body("hello "))
    }

    private func pairWithFacts() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()
        return (a, b, server)
    }

    /// Seeds one copy, mirroring `SampleLibrarySeeder.seed`'s exact shape:
    /// curated book (profile "book"), one section per note, membership +
    /// section assignment + the reserved tag per note.
    @discardableResult
    private func seedCopy(
        _ client: SyncClient
    ) throws -> (bookID: String, postIDs: [String: String]) {
        try client.with { ops, _ in
            let book = try ops.createReading(
                name: Self.bookName, kind: .book, profile: "book")
            let tag = try ops.createTag(name: Self.tagPath)
            var postIDs: [String: String] = [:]
            for note in Self.notes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(
                    title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(
                    minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tag.id, toPost: minted.container.id)
                postIDs[note.title] = minted.container.id
            }
            return (book.id, postIDs)
        }
    }

    private func renderedText(_ client: SyncClient, postID: String) throws -> String {
        try client.db.read { db in try Queries.renderedText(db, containerID: postID) }
    }

    private func liveCopyIDs(_ client: SyncClient) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
                arguments: [Self.bookName])
        }
    }

    private func firstVariantID(
        _ client: SyncClient, postID: String
    ) throws -> String {
        try client.db.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                      AND v.deleted_at IS NULL
                    ORDER BY cb.position, v.id LIMIT 1
                    """,
                arguments: [postID])!
        }
    }

    @Test func twoPristineCopiesConvergeToTheSmallerIDKeeper() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        try await a.push()
        try await b.push()
        let arrival = try await b.pull()

        // On B, the batch that BROUGHT A's copy defers the pass (the ladder's
        // F2: a copy whose book arrived this batch is indeterminate — its
        // engagement signals may still be in the pusher's next chunk) and
        // leaves the one-shot marker; both copies stand for now.
        #expect(try liveCopyIDs(b) == [copyA.bookID, copyB.bookID].sorted())
        // (The reserved TAG collides too — its tag.path repair rides this
        // batch; the dedupe itself wrote nothing, as the live ids show.)
        #expect(arrival.applied > 0)
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'sample_dedupe_pending'") == "1",
            "the deferral leaves its marker")
        // The next pull — an EMPTY window, nothing else arriving — is the
        // quiescent moment: the pass runs, and the marker is spent.
        let quiescent = try await b.pull()
        #expect(quiescent.applied == 0)
        #expect(quiescent.repairs > 0, "positive activity: the deferred pass ran at the empty window")
        #expect(try b.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'sample_dedupe_pending'") == nil)

        // On B: both copies are byte-identical to the manifest, so the
        // smaller id (A's) keeps and B's whole FAMILY retires — the book,
        // its memberships, and its posts — each write enqueued.
        #expect(try liveCopyIDs(b) == [copyA.bookID])
        #expect(try b.db.deletedAt("reading", copyB.bookID) != nil)
        #expect(try b.outboxContains("reading", copyB.bookID))
        for (_, postID) in copyB.postIDs {
            #expect(try b.db.deletedAt("container", postID) != nil,
                    "the loser's posts retire with the book (nothing lost — byte-identical)")
            #expect(try b.outboxContains("container", postID))
        }

        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID])
            // The retirement leaves no live bookless posts behind: the
            // loser's notes went with their book, not into the Pool.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL
                  AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                  WHERE rp.post_id = c.id AND rp.deleted_at IS NULL)
                """) == 0)
        }

        // Idempotence: further rounds change nothing.
        let settled = try a.syncedDump()
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == settled)
    }

    /// **13i-d U7, F-U7-1 (the architect's Sync/ half — the ruled #classics
    /// letter):** an application of a DECLARED seed-tag path on a shipped
    /// note is the seeder's own act, so two fresh devices that each seeded
    /// the triad (reserved tag + classics on every story) still classify
    /// both copies PRISTINE and converge to the smaller-id keeper. RED ON
    /// OLD by behavioural revert of the classifier's seed-tag skip: both
    /// copies then read EDITED (both-survive) and the keeper assertion
    /// fails with two live ids.
    @Test func aSeedAuthoredClassicsTagNeverMarksACopyEditedAndTheCopiesStillConverge() async throws {
        let (a, b, server) = try furniturePair()
        let classicsFacts = Self.facts(seedTagPaths: ["classics"])
        a.sampleLibraryFacts = classicsFacts
        b.sampleLibraryFacts = classicsFacts
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        // The seeder's OWN classics act, mirrored on both devices: one tag,
        // applied to every shipped note (the triad's shape).
        for client in [a, b] {
            try client.with { ops, _ in
                let classics = try ops.createTag(name: "classics")
                let posts = client === a ? copyA.postIDs : copyB.postIDs
                for (_, postID) in posts {
                    _ = try ops.applyTag(classics.id, toPost: postID)
                }
            }
        }

        try await a.push()
        try await b.push()
        _ = try await b.pull()
        _ = try await b.pull()  // the quiescent window: the deferred pass runs

        #expect(try liveCopyIDs(b) == [copyA.bookID],
                "both copies pristine despite classics — the smaller-id keeper stands")
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID])
            // The keeper's notes still wear the seed's classics tag.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id
                JOIN reading_post rp ON rp.post_id = pt.post_id
                WHERE rp.reading_id = '\(copyA.bookID)' AND rp.deleted_at IS NULL
                  AND pt.deleted_at IS NULL AND t.path = 'classics' AND t.deleted_at IS NULL
                """) ?? 0 > 0, "the keeper keeps the seed's classics applications")
        }
    }

    /// The skip is BOUNDED to the declared set (the err-toward-EDITED
    /// letter everywhere else): a tag at any OTHER path is her hands, the
    /// copy carrying it reads EDITED, and it SURVIVES while the pristine
    /// twin retires — whatever the ids.
    @Test func aTagOutsideTheSeedSetStillProtectsTheCopy() async throws {
        let (a, b, server) = try furniturePair()
        let classicsFacts = Self.facts(seedTagPaths: ["classics"])
        a.sampleLibraryFacts = classicsFacts
        b.sampleLibraryFacts = classicsFacts
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try b.with { ops, _ in
            let hers = try ops.createTag(name: "her-own")
            _ = try ops.applyTag(hers.id, toPost: copyB.postIDs[Self.notes[1].title]!)
        }

        try await a.push()
        try await b.push()
        _ = try await b.pull()
        _ = try await b.pull()

        #expect(try liveCopyIDs(b) == [copyB.bookID],
                "her-own marks B's copy EDITED; the pristine twin retires whatever the ids")
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        #expect(try liveCopyIDs(a) == [copyB.bookID])
    }

    /// **13i-d LADDER B — round 1's MINOR 1, ruled (b): the DOCUMENTED
    /// RESIDUAL, pinned so it is never a surprise** (the SyncSpec
    /// review-finding-#6 idiom — a test that DOCUMENTS a converged outcome,
    /// endorsing nothing). The Welcome arrangement is the Mac's alone today
    /// (P-13id-U7-14), so a dedupe meeting can be ASYMMETRIC: one copy
    /// arranged (its stories wear the seed's `classics` tag — the skip reads
    /// those applications as the seeder's hands), the other RAW (a phone
    /// seed, or a pre-U7 build's). Both read PRISTINE, the smaller id keeps —
    /// and when the raw copy wins the toss the arranged copy's demo state
    /// retires with its family (here the #classics applications; in the app
    /// also the owned flag and the Welcome placement, which this classifier
    /// deliberately never reads). Nothing of HERS is lost (both copies are
    /// byte-identical seeds; a restore door re-arranges), and the window is
    /// the dedupe's own — a second device seeding before its first clean
    /// sync. The closure is the phone's arrangement catch-up (the KnownIssues
    /// row, 2026-10-02); the remedy alternatives — a keeper-preference arm
    /// (changes the ruled R-pre13u-8 matrix) or arranging in the shared
    /// seeder (decides phone seed content) — are HERS, QUESTIONS #178.
    @Test func documentedResidual_aRawCopyCanRetireAnArrangedOnesDemoState() async throws {
        let (a, b, server) = try furniturePair()
        let classicsFacts = Self.facts(seedTagPaths: ["classics"])
        a.sampleLibraryFacts = classicsFacts
        b.sampleLibraryFacts = classicsFacts
        let copyA = try seedCopy(a)  // raw — and minted first: the smaller ids
        let copyB = try seedCopy(b)  // "arranged": its stories wear #classics
        try b.with { ops, _ in
            let classics = try ops.createTag(name: "classics")
            for (_, postID) in copyB.postIDs {
                _ = try ops.applyTag(classics.id, toPost: postID)
            }
        }

        try await a.push()
        try await b.push()
        _ = try await b.pull()
        _ = try await b.pull()  // the quiescent window: the deferred pass runs

        #expect(try liveCopyIDs(b) == [copyA.bookID],
                "both pristine — the RAW, smaller-id copy keeps")
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID])
            // THE RESIDUAL, documented: no live #classics application
            // survives anywhere — the arrangement's state rode the family.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.deleted_at IS NULL AND t.path = 'classics'
                """) == 0,
                "documented, not endorsed — the arranged state died with its copy")
        }
    }

    @Test func anEditedCopySurvivesAndThePristineOneRetiresWhateverTheIDs() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        // B (the LARGER ids) rewrites one story — the edited copy must be
        // the keeper even though smaller-id would pick A.
        let editedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let variant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(variant, text: "Rewritten in her own words.", charDelta: 20)
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the EDITED copy is kept; the pristine one is retired")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
            #expect(try renderedText(client, postID: editedPost)
                .contains("Rewritten in her own words."))
        }
    }

    @Test func herPrivateMarkOnTheBookIsEngagementAndTheMarkedCopyIsTheKeeper() async throws {
        // 13n-b U2 ladder round 1, F1: the Private mark (R-13nb-4, v1_25)
        // is her hand on a copy — EDITED, so the marked copy is the KEEPER
        // (the "exactly one edited" arm), never silently retired to an
        // unmarked twin. RED ON OLD: the book-level read carried no
        // `ai_private_at`, a marked copy classified pristine, and the mark
        // — a disclosure fence — folded away with the smaller-id toss.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        // B (the LARGER ids) marks its copy's BOOK Private — the marked
        // copy must be the keeper even though smaller-id would pick A.
        try b.with { ops, _ in try ops.setBookPrivate(copyB.bookID, true) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the MARKED copy is kept — the mark is engagement")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
            let fenceStands = try client.with { _, db in
                try db.read { try Queries.isBookPrivate($0, readingID: copyB.bookID) }
            }
            #expect(fenceStands, "and the fence stands on every device")
        }
    }

    @Test func herPrivateMarkOnAMemberNoteProtectsTheCopyToo() async throws {
        // The note-level arm of the same F1 fix: a member note's own mark
        // is engagement on the copy that holds it. RED ON OLD: the per-note
        // read carried no `ai_private_at`.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let marked = copyB.postIDs["A Scandal in Bohemia"]!
        try b.with { ops, _ in try ops.setNotePrivate(marked, true) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the copy holding her marked note is the keeper")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
            let fenceStands = try client.with { _, db in
                try db.read { try Queries.isNotePrivate($0, postID: marked) }
            }
            #expect(fenceStands)
        }
    }

    @Test func twoEditedCopiesBothSurvive() async throws {
        // The documented outcome (the §7 concurrent-divide class): an edited
        // copy is NEVER silently retired, so two edited copies coexist and
        // the shown-once display absorbs the shared name.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        for (client, copy) in [(a, copyA), (b, copyB)] {
            let post = copy.postIDs["About this book"]!
            let variant = try firstVariantID(client, postID: post)
            try client.with { ops, _ in
                try ops.autosave(variant, text: "My own attribution note.", charDelta: 5)
            }
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID, copyB.bookID].sorted(),
                    "both edited copies survive")
        }
    }

    @Test func anUnrenderedTakeCountsAsEngagementAndProtectsTheCopy() async throws {
        // A fanned take does not change rendered text, so the hash rule
        // alone would read the copy as pristine and silently retire her
        // take. Engagement counts as editing: the copy survives.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let fannedPost = copyB.postIDs["A Scandal in Bohemia"]!
        try b.with { ops, db in
            let (blockID, variantID) = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT v.block_id AS b, v.id AS v FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        ORDER BY cb.position, v.id LIMIT 1
                        """,
                    arguments: [fannedPost]).map { ($0["b"] as String, $0["v"] as String) }!
            }
            _ = try ops.branchVariant(blockID, from: variantID)
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the copy carrying her take survives; the untouched one retires")
        }
    }

    @Test func aNoteTheManifestDoesNotKnowMarksTheCopyEdited() async throws {
        // A note she ADDED to the book is her own writing — the copy that
        // holds it is edited and must be the survivor.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let added: String = try b.with { ops, _ in
            let note = try ops.importPost(
                title: "My reading notes", text: "Watson is the narrator.", undoLabel: "Import")
            _ = try ops.addPostToReading(note.container.id, to: copyB.bookID)
            return note.container.id
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID])
            #expect(try client.db.deletedAt("container", added) == nil,
                    "her added note survives with its copy")
        }
        _ = copyA
    }

    /// **RED ON OLD (the ladder's F5, MAJOR):** the "a savepoint = engagement"
    /// signal counted AUTO commits, which the system mints on untouched
    /// seeded text — `closeAutoCommit` runs on every note that stops being
    /// shown, and `isDirty` reads a never-committed take as dirty — so merely
    /// READING a story on each device stamped both copies EDITED and the
    /// ruled dedupe degraded to both-survive in essentially every real store.
    /// Engagement is her hand: MANUAL savepoints only.
    @Test func anAutoSavepointFromReadingAndLeavingIsNotEngagement() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        // Each reader opens one story and leaves — the everyday occasion.
        for (client, copy) in [(a, copyA), (b, copyB)] {
            let minted = try client.with { ops, _ in
                try ops.closeAutoCommit(copy.postIDs["A Scandal in Bohemia"]!)
            }
            #expect(!minted.isEmpty, "positive activity: the leaving occasion DID mint an auto savepoint")
            #expect(minted.allSatisfy { $0.kind == .auto })
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID],
                    "both copies are still pristine — ONE survives (old: both, forever)")
        }
        _ = copyB
    }

    /// …and a MANUAL savepoint is still her hand: the copy carrying it is
    /// the survivor whatever the ids.
    @Test func aManualSavepointStillProtectsTheCopy() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let savedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let variant = try firstVariantID(b, postID: savedPost)
        try b.with { ops, _ in _ = try ops.commit(variant) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the copy she deliberately saved survives; the untouched one retires")
        }
        _ = copyA
    }

    /// **RED ON OLD (the ladder's F3, MINOR):** a PRUNED copy — one story
    /// removed from the book, its membership tombstoned — is her act, and the
    /// ruled outcome is "edited kept, pristine retired". The final guard
    /// returned `.indeterminate` for it (contradicting its own comment), so
    /// the whole pass deferred forever and BOTH copies survived.
    @Test func aPrunedCopyIsEditedAndTheUntouchedOneRetires() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let pruned = copyB.postIDs["About this book"]!
        try b.with { ops, _ in try ops.removePostFromReading(pruned, from: copyB.bookID) }
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NOT NULL",
            [copyB.bookID]) == 1, "positive activity: the pruning left its tombstone evidence")

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the pruned copy is hers and survives; the untouched one retires (old: both)")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
            #expect(try client.db.deletedAt("container", pruned) == nil,
                    "the note she took out of the book is untouched — bookless, hers")
        }
    }

    /// **RED ON OLD (the ladder's F2, MINOR):** the engagement signals the
    /// classifier reads — post_tag, block_tag, reference, block_comment —
    /// sort AFTER reading_post in the push order and can travel in a later
    /// chunk than the memberships. A pull landing between those chunks read
    /// an edited-by-comment copy as PRISTINE and retired it; the comment
    /// then arrived under a dead block and died with it — "an edited copy
    /// is NEVER silently retired" violated. Now the batch that brings a
    /// copy's book defers the pass; the comment lands; the pass then reads
    /// the copy as hers.
    @Test func aCommentTravellingBehindTheMembershipsStillProtectsTheCopy() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, clockOffset: 1000, seed: 2)
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        // B annotates a story — engagement the rendered text cannot see.
        let annotated = copyB.postIDs["A Scandal in Bohemia"]!
        let commentID: String = try b.with { ops, db in
            let blockID = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL ORDER BY position LIMIT 1",
                    arguments: [annotated])!
            }
            return try ops.addBlockComment(to: blockID, text: "Irene Adler, always THE woman.").id
        }

        try await a.push()
        // B's push dies after every row through reading_post — the tag
        // applications and the comment stay in B's outbox.
        let split = try outboxRowsAhead(of: "post_tag", in: b)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await b.push() }
        #expect(await server.currentRow(table: "block_comment", rowID: commentID) == nil,
                "the comment has not reached the server yet")

        let between = try await a.pull()
        #expect(between.applied > 0)
        // Old: A read B's copy as pristine (no comment in sight), kept its
        // own smaller-id copy and retired B's. Now: deferred, both stand.
        #expect(try liveCopyIDs(a) == [copyA.bookID, copyB.bookID].sorted(),
                "a copy whose book arrived THIS batch is never classified")
        #expect(try a.db.deletedAt("reading", copyB.bookID) == nil)

        // B's retry lands the rest; A's next pull brings the comment, and the
        // deferred pass reads B's copy as hers.
        try await b.push()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the annotated copy survives; the untouched one retires")
            #expect(try client.db.deletedAt("block_comment", commentID) == nil,
                    "her comment lives (old: died under the retired copy's block)")
        }
    }

    // MARK: Round 2 — the pins run PRODUCTION'S round shape (pull → push)

    /// Production's one round (`SyncScheduler.runOneRound`, the A3 pin):
    /// pull, THEN push. Round 1's pins passed on sequences production never
    /// runs; these do not.
    @discardableResult
    private func round(
        _ client: SyncClient
    ) async throws -> (pull: SyncEngine.PullReport, push: SyncEngine.PushReport) {
        let pull = try await client.pull()
        let push = try await client.push()
        return (pull, push)
    }

    private func marker(_ client: SyncClient) throws -> String? {
        try client.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'sample_dedupe_pending'")
    }

    private struct SplitAnnotatedWorld {
        let a: SyncClient
        let b: SyncClient
        let server: FakeSyncServer
        let copyA: (bookID: String, postIDs: [String: String])
        let copyB: (bookID: String, postIDs: [String: String])
        let commentID: String
        var both: [String] { [copyA.bookID, copyB.bookID].sorted() }
    }

    /// The F2 world: both seed; B annotates a story (engagement the rendered
    /// text cannot see); A's copy is fully on the server; B's push dies after
    /// every row through `reading_post` — the reserved-tag applications and
    /// the comment stay in B's outbox, exactly the between-chunks state.
    private func splitAnnotatedWorld() async throws -> SplitAnnotatedWorld {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: transport, clockOffset: 1000, seed: 2)
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let annotated = copyB.postIDs["A Scandal in Bohemia"]!
        let commentID: String = try b.with { ops, db in
            let blockID = try db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL ORDER BY position LIMIT 1",
                    arguments: [annotated])!
            }
            return try ops.addBlockComment(to: blockID, text: "Irene Adler, always THE woman.").id
        }
        try await a.push()
        let split = try outboxRowsAhead(of: "post_tag", in: b)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await b.push() }
        #expect(await server.currentRow(table: "block_comment", rowID: commentID) == nil,
                "the comment has not reached the server yet")
        #expect(await server.currentRow(table: "reading", rowID: copyB.bookID) != nil,
                "but B's book and memberships have")
        return SplitAnnotatedWorld(
            a: a, b: b, server: server, copyA: copyA, copyB: copyB, commentID: commentID)
    }

    /// **RED ON OLD (round 2, R2-1 — MAJOR):** F2's deferral held only for a
    /// pull followed by another pull. Production's round is pull → PUSH, and
    /// the push path ran `runPostApplyRepairs` per chunk with the marker
    /// honored and an empty `touched.readingIDs`: the deferring device
    /// always has dirty rows after that pull (the reserved tag's collision
    /// repair), so the pass CLASSIFIED at the first push chunk of the same
    /// round — B's tag applications and comment still in flight, B's copy
    /// read PRISTINE, retired, and the comment landed under a dead block.
    /// Now the dedupe fires only under a pull, which is the only road that
    /// can land what an in-flight copy is missing.
    @Test func theDeferralSurvivesTheRoundsOwnPush() async throws {
        let w = try await splitAnnotatedWorld()

        // A's round, production's shape: the pull brings B's first chunk and
        // defers (the one-shot marker); the same round's PUSH carries A's
        // dirty rows — and must not run the pass.
        let (pull, push) = try await round(w.a)
        #expect(pull.applied > 0)
        #expect(push.accepted > 0, "positive activity: the round's push had rows to carry")
        #expect(try liveCopyIDs(w.a) == w.both,
                "both copies stand after the round's push (old: B's retired at that push's first chunk)")
        #expect(try w.a.db.deletedAt("reading", w.copyB.bookID) == nil)
        #expect(try marker(w.a) == "1",
                "the push never consumes the marker — only a pull can land what is missing")

        // B's retry lands the rest; A's next round reads B's copy as hers.
        try await w.b.push()
        try await round(w.a)
        #expect(try liveCopyIDs(w.a) == [w.copyB.bookID],
                "with the comment in sight the annotated copy is the survivor")
        try await assertFurnitureConverged(w.a, w.b, w.server)
        for client in [w.a, w.b] {
            #expect(try liveCopyIDs(client) == [w.copyB.bookID])
            #expect(try client.db.deletedAt("block_comment", w.commentID) == nil,
                    "her comment lives (old: died under the retired copy's block)")
        }
    }

    /// **RED ON OLD (round 2, R2-6 — MINOR; the reserved-tag completeness
    /// guard of R2-1):** with the push path fixed, a pull between the
    /// pusher's chunks that carries NOTHING OF THE PUSHER'S — the deferring
    /// device's own echo, or an empty window — still re-fired the deferred
    /// pass on the marker and classified a copy whose engagement rows were
    /// in flight: an apply that cannot carry them. Now a shipped note with
    /// no reserved-tag application at all proves the tag chunk has not
    /// landed: the copy is indeterminate, the marker is not re-armed, and
    /// the pass is re-examined at the apply that lands those applications —
    /// the third occasion — where the comment behind them is in sight too.
    @Test func aPullBetweenTheChunksDefersOnTheReservedTagEvidence() async throws {
        let w = try await splitAnnotatedWorld()
        try await round(w.a)  // deferred on arrival; the push carries A's repairs

        // The next pull carries only A's own echo — nothing of B's. The
        // marker re-fires the pass, which defers AGAIN: B's members carry no
        // reserved-tag row yet.
        let echo = try await w.a.pull()
        #expect(echo.applied > 0, "positive activity: the round's push echoes back")
        #expect(await w.server.currentRow(table: "block_comment", rowID: w.commentID) == nil,
                "still nothing of B's second chunk on the server")
        #expect(try liveCopyIDs(w.a) == w.both,
                "both copies stand through a pull that brought nothing of B's (old: B's retired here)")
        #expect(try marker(w.a) == nil,
                "the guard's deferral does not re-arm the one-shot marker — it waits for its evidence")
        // A truly empty window now does no work at all: the marker is spent.
        let empty = try await w.a.pull()
        #expect(empty.applied == 0)
        #expect(empty.repairs == 0)
        #expect(try liveCopyIDs(w.a) == w.both)
        try await w.a.push()

        // B's retry lands the tag applications and the comment. A's next
        // pull carries them: the reserved-path applications ARE the
        // occasion — no book touched, no marker, and the pass still runs.
        try await w.b.push()
        let evidence = try await w.a.pull()
        #expect(evidence.applied > 0)
        #expect(try liveCopyIDs(w.a) == [w.copyB.bookID],
                "the arriving reserved-tag applications re-examined the copy; the annotated one survives")
        #expect(try w.a.outboxContains("reading", w.copyA.bookID),
                "the retirement reaches the outbox (SyncSpec §7)")
        try await assertFurnitureConverged(w.a, w.b, w.server)
        for client in [w.a, w.b] {
            #expect(try liveCopyIDs(client) == [w.copyB.bookID])
            #expect(try client.db.deletedAt("block_comment", w.commentID) == nil)
        }
    }

    /// **RED ON OLD (round 2, R2-3 — MINOR):** the marker leaked past its
    /// one-shot contract. `guard copies.count > 1` returned BEFORE the
    /// clear, so on the common convergence — the other device's retirement
    /// arriving in a non-empty pull, leaving ONE live copy — the pass ran
    /// with count 1, returned, and never spent the marker: every later
    /// empty pull opened an apply-mode transaction and (pre-R2-1) every
    /// push chunk re-ran the pass, forever. Now a pass spends the marker
    /// first, whatever it decides.
    @Test func theMarkerIsSpentWhenTheOtherDevicesRetirementLands() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try await a.push()
        try await b.push()
        try await b.pull()
        #expect(try marker(b) == "1", "B deferred on A's copy arriving")
        try await a.pull()
        #expect(try marker(a) == "1", "A deferred on B's copy arriving")
        // A's next round: the pull is an empty window (its marker re-fires
        // the pass — both pristine, A's smaller id keeps, B's retires) and
        // the push carries the retirement.
        try await round(a)
        #expect(try liveCopyIDs(a) == [copyA.bookID])
        #expect(try marker(a) == nil)
        // B's pull brings the retirement: its own copy dead, ONE live copy
        // left. The pass runs on the touched book and stands down — and
        // spends the marker doing so.
        let arrival = try await b.pull()
        #expect(arrival.applied > 0)
        #expect(try liveCopyIDs(b) == [copyA.bookID])
        #expect(try marker(b) == nil,
                "spent by the pass that found one copy (old: leaked forever)")
        // A truly empty window opens nothing: no marker, no transaction.
        let empty = try await b.pull()
        #expect(empty.applied == 0)
        #expect(empty.repairs == 0)
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try marker(client) == nil)
            #expect(try liveCopyIDs(client) == [copyA.bookID])
        }
        _ = copyB
    }

    // MARK: Round 2 — R2-5: the acts the rendered text cannot see

    /// Her acts on a copy that leave the rendered text byte-identical to the
    /// manifest — every one must read as EDITED, or the copy carrying it is
    /// retired when the other device's id is smaller.
    enum HerAct: String, CaseIterable, Sendable {
        case lockedATake
        case namedABlock
        case framedABlockAsACallout
        case changedTheBooksSort
        case reorderedAChapter
        case reorderedANote

        func perform(on client: SyncClient, copy: (bookID: String, postIDs: [String: String])) throws {
            let post = copy.postIDs["A Scandal in Bohemia"]!
            try client.with { ops, db in
                let (blockID, variantID) = try db.read { db in
                    try Row.fetchOne(
                        db,
                        sql: """
                            SELECT v.block_id AS b, v.id AS v FROM variant v
                            JOIN container_block cb ON cb.block_id = v.block_id
                            WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                              AND v.deleted_at IS NULL
                            ORDER BY cb.position, v.id LIMIT 1
                            """,
                        arguments: [post]).map { ($0["b"] as String, $0["v"] as String) }!
                }
                switch self {
                case .lockedATake:
                    try ops.lockVariant(variantID)
                case .namedABlock:
                    try ops.setBlockName(blockID, name: "the opening")
                case .framedABlockAsACallout:
                    try ops.setBlockPresentation(blockID, BlockPresentation())
                case .changedTheBooksSort:
                    try ops.setReadingSort(copy.bookID, field: .entryDate, direction: .desc)
                case .reorderedAChapter:
                    let last = try db.read { db in
                        try String.fetchOne(
                            db,
                            sql: "SELECT id FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position DESC LIMIT 1",
                            arguments: [copy.bookID])!
                    }
                    try ops.reorderSection(last, to: .start)
                case .reorderedANote:
                    try ops.reorderReadingPost(post, in: copy.bookID, to: .start)
                }
            }
        }
    }

    /// **RED ON OLD (round 2, R2-5 — MINOR):** the never-covered class — a
    /// LOCKED take (pre-F5 its insurance auto-commit counted by accident;
    /// `kind = 'manual'` removed that and nothing read `locked`), a block
    /// NAME, a callout FRAME, the book's SORT, a REORDERED chapter or note.
    /// Each is her act; each left the rendered text untouched; each read as
    /// PRISTINE, and B's copy — the larger ids — retired with the act in it.
    @Test(arguments: HerAct.allCases)
    func herInvisibleActProtectsTheCopy(_ act: HerAct) async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        try act.perform(on: b, copy: copyB)
        #expect(try renderedText(b, postID: copyB.postIDs["A Scandal in Bohemia"]!)
                == Self.notes[1].text,
                "positive activity: the act left the rendered text byte-identical")

        try await a.push()
        try await b.push()
        try await round(b)
        try await round(a)
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "\(act.rawValue): the copy carrying her act survives; the untouched one retires (old: hers retired)")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
        }
    }

    @Test func noInjectedFactsMeansNoDedupe() async throws {
        // An engine nobody wired facts into cannot misidentify anything —
        // the repair is inert by default (the keyProvider pattern).
        let (a, b, server) = try furniturePair()
        _ = try seedCopy(a)
        _ = try seedCopy(b)
        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        #expect(try liveCopyIDs(a).count == 2)
    }
}

// MARK: - pre-13x 5a: the facts as a LIST — a second seeded book (*Encryption Explained*)

/// pre-13x 5a (the batch's one `Sync/` touch, ruled): the engine takes the
/// dedupe facts as a LIST, one entry per seeded book, and the pass runs per
/// entry exactly as it ran for one. Two seeded copies of the SECOND book
/// meeting via sync converge by the same rules — both pristine → the
/// smaller id; one edited → the edited survives — while a lone copy of the
/// FIRST book beside them is untouched. RED-ON-OLD: with the single-facts
/// engine (Sherlock's facts alone) the second book's copies never met a
/// pass and both stood forever.
@Suite("Sample-library dedupe — the facts list (pre-13x 5a)")
struct SampleLibraryDedupeListTests {
    static let encryptionBookName = "Encryption Explained"
    static let encryptionTagPath = "encryption explained"
    static let encryptionNotes: [(title: String, text: String)] = [
        ("About this book", "Plain credential words, each defined the first time it appears."),
        ("Chapter 1 — What is encrypted, and with what",
         "Your library is one file.\n\nSync is end-to-end encrypted in both modes."),
    ]

    static func encryptionFacts() -> SampleLibraryDedupeFacts {
        let hashes = Dictionary(
            uniqueKeysWithValues: encryptionNotes.map { ($0.title, BridgeHash.body($0.text)) })
        return SampleLibraryDedupeFacts(
            bookName: encryptionBookName, tagPath: encryptionTagPath,
            loadNoteHashes: { hashes }, hash: BridgeHash.body(_:))
    }

    private func pairWithBothBooksFacts() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let (a, b, server) = try furniturePair()
        for client in [a, b] {
            client.sampleLibraryFacts = SampleLibraryDedupeRepairTests.facts()
            client.additionalSampleLibraryFacts = [Self.encryptionFacts()]
        }
        return (a, b, server)
    }

    /// Mirrors `SampleLibrarySeeder.seed`'s shape for the second book.
    @discardableResult
    private func seedEncryptionCopy(_ client: SyncClient) throws -> (bookID: String, postIDs: [String: String]) {
        try client.with { ops, _ in
            let book = try ops.createReading(name: Self.encryptionBookName, kind: .book, profile: "book")
            let tag = try ops.createTag(name: Self.encryptionTagPath)
            var postIDs: [String: String] = [:]
            for note in Self.encryptionNotes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tag.id, toPost: minted.container.id)
                postIDs[note.title] = minted.container.id
            }
            return (book.id, postIDs)
        }
    }

    /// A lone Sherlock copy (the FIRST book's facts) beside the second book.
    @discardableResult
    private func seedSherlockCopy(_ client: SyncClient) throws -> String {
        try client.with { ops, _ in
            let book = try ops.createReading(
                name: SampleLibraryDedupeRepairTests.bookName, kind: .book, profile: "book")
            let tag = try ops.createTag(name: SampleLibraryDedupeRepairTests.tagPath)
            for note in SampleLibraryDedupeRepairTests.notes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tag.id, toPost: minted.container.id)
            }
            return book.id
        }
    }

    private func firstVariantID(_ client: SyncClient, postID: String) throws -> String {
        try client.db.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND v.deleted_at IS NULL
                    ORDER BY cb.position, v.id LIMIT 1
                    """,
                arguments: [postID])!
        }
    }

    private func liveCopyIDs(_ client: SyncClient, named name: String) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db, sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
                arguments: [name])
        }
    }

    @Test func twoPristineCopiesOfTheSecondBookConvergeToTheSmallerIDAndTheFirstBookStands() async throws {
        let (a, b, server) = try pairWithBothBooksFacts()
        let sherlock = try seedSherlockCopy(a)
        let copyA = try seedEncryptionCopy(a)
        let copyB = try seedEncryptionCopy(b)

        try await a.push()
        try await b.push()
        // The arrival batch defers (the book arrived this batch); the empty
        // window then runs the pass — the one-shot marker's road, unchanged.
        try await b.pull()
        #expect(try liveCopyIDs(b, named: Self.encryptionBookName) == [copyA.bookID, copyB.bookID].sorted())
        try await b.pull()
        #expect(try liveCopyIDs(b, named: Self.encryptionBookName) == [copyA.bookID],
                "both pristine → the smaller id keeps; the other's family retires")
        for (_, postID) in copyB.postIDs {
            #expect(try b.db.deletedAt("container", postID) != nil)
            #expect(try b.outboxContains("container", postID))
        }
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client, named: Self.encryptionBookName) == [copyA.bookID])
            #expect(try liveCopyIDs(client, named: SampleLibraryDedupeRepairTests.bookName) == [sherlock],
                    "the lone Sherlock copy is untouched by the second book's pass")
        }
        let settled = try a.syncedDump()
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == settled)
    }

    @Test func anEditedCopyOfTheSecondBookSurvivesAndThePristineOneRetires() async throws {
        let (a, b, server) = try pairWithBothBooksFacts()
        let copyA = try seedEncryptionCopy(a)
        let copyB = try seedEncryptionCopy(b)
        // B (the larger ids) rewrites a chapter — the EDITED copy must keep.
        let editedPost = copyB.postIDs["Chapter 1 — What is encrypted, and with what"]!
        let variant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(variant, text: "Rewritten in her own words.", charDelta: 20)
        }
        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client, named: Self.encryptionBookName) == [copyB.bookID],
                    "the EDITED copy is kept; the pristine one is retired")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
        }
    }
}
