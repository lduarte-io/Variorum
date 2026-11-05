//
//  EmptyBlockSweepTests.swift
//  VariorumCoreTests
//
//  VX-800 (the VX-828 run, batch D) — the Trash's sweep of every empty block
//  with no history. Her ask, verbatim: *"delete all empty blocks with no
//  history from trash."* The predicate is R-828-1, read row by row at the
//  batch's design fork and RULED there (P-828-7 (a) any edge row to a living
//  block, whatever the edge's own tombstone · P-828-8 (a) zero-length is
//  empty · P-828-9 (a) a block tag is not history) —
//  `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch D — THE FORK'S
//  RULING".
//
//  What these pin, exact rows throughout:
//  · the pure rule (`EmptyBlockSweep.qualifies`) — six facts, all clear;
//  · the facts' row-level readings (`Queries.emptyBlockSweepFacts`) and the
//    candidate set (`Queries.emptyTrashBlocks` — the Trash's own block rows,
//    cascade victims, the window, the intent fence and the wing fence
//    inherited);
//  · the held observation's named region, exact;
//  · the act (`Operations.sweepEmptyTrashBlocks`) — one intent per taken
//    block, confirm ids ∩ still-qualifying, the horizon honored, nothing
//    written when nothing is left, and never a living block taken.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// MARK: - Helpers

private func sweepable(
    _ db: AppDatabase, now: Date = harnessNow, wingID: String? = nil
) throws -> [String] {
    try db.read { try Queries.emptyTrashBlocks($0, now: now, wingID: wingID) }
}

private func facts(_ db: AppDatabase, _ ids: [String]) throws -> [EmptyBlockSweep.Facts] {
    try db.read { try Queries.emptyBlockSweepFacts($0, blockIDs: ids) }
}

/// The Trash's listed ids (every kind), as of the harness's now.
private func trashIDs(_ db: AppDatabase) throws -> [String] {
    try db.read { try Queries.trash($0, now: harnessNow).map(\.id) }
}

/// Marks a row as accepted by the server (what keeps its family off the
/// local purge road until the horizon passes it).
private func markSynced(_ db: AppDatabase, table: String, _ id: String) throws {
    try db.write { database in
        try database.execute(
            sql: "INSERT INTO sync_row_seq (table_name, row_id, server_seq) VALUES (?, ?, 7)",
            arguments: [table, id])
    }
}

/// Hand-builds one edge row between two existing blocks.
private func insertEdge(
    _ db: AppDatabase, id: String, from source: String, to target: String,
    type: String = "derived_from", deletedAt: String? = nil
) throws {
    try db.write { database in
        try database.execute(
            sql: """
                INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op,
                                  created_at, deleted_at)
                VALUES (?, ?, ?, ?, 'manual', '2026-07-01T00:00:00.000Z', ?)
                """,
            arguments: [id, source, target, type, deletedAt])
    }
}

@Suite("VX-800 — the Trash's empty-block sweep")
struct EmptyBlockSweepTests {

    // MARK: - The pure rule

    /// Six facts, all clear — and any ONE of them keeps the block out.
    @Test func theRuleIsSixFactsAllClear() {
        #expect(EmptyBlockSweep.qualifies(.init(blockID: "b")))
        let each: [(String, EmptyBlockSweep.Facts)] = [
            ("a worded take", .init(blockID: "b", wordedTakes: 1)),
            ("a savepoint", .init(blockID: "b", savepoints: 1)),
            ("a comment row", .init(blockID: "b", comments: 1)),
            ("a name", .init(blockID: "b", name: "kept")),
            ("an empty-string name (unreachable through the ops — conservative)",
             .init(blockID: "b", name: "")),
            ("a callout frame", .init(blockID: "b", presentation: #"{"kind":"callout"}"#)),
            ("a malformed frame that reads as plain", .init(blockID: "b", presentation: "{")),
            ("a link to a living block", .init(blockID: "b", livingLinks: 1)),
        ]
        for (why, fact) in each {
            #expect(!EmptyBlockSweep.qualifies(fact), "\(why) keeps the block out")
        }
    }

    // MARK: - Empty (P-828-8 (a): zero-length, every take)

    /// The junk shape — an empty block, and an empty fan — qualifies; any
    /// take with text, in ANY status or tombstone state, keeps it out:
    /// whitespace and a lone newline are content (zero-length is the one
    /// meaning of empty), an archived take's words and a take deleted on its
    /// own earlier are words the purge family would take with the block.
    @Test func theJunkShapeQualifiesAndAnyWordedTakeStaysOut() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let junk = try ops.seedBlock(in: note.id, text: "").block.id
            let fan = try ops.seedBlock(in: note.id, text: "")
            _ = try ops.newBlankVariant(fan.block.id)
            let worded = try ops.seedBlock(in: note.id, text: "words").block.id
            let space = try ops.seedBlock(in: note.id, text: " ").block.id
            let newline = try ops.seedBlock(in: note.id, text: "\n").block.id
            let archived = try ops.seedBlock(in: note.id, text: "")
            let archivedTake = try ops.newBlankVariant(archived.block.id)
            try ops.autosave(archivedTake.id, text: "an archived take's words", charDelta: 24)
            try ops.archiveVariant(archivedTake.id)
            let earlier = try ops.seedBlock(in: note.id, text: "")
            let earlierTake = try ops.newBlankVariant(earlier.block.id)
            try ops.autosave(earlierTake.id, text: "deleted on its own", charDelta: 18)
            try ops.deleteVariant(earlierTake.id)
            let all = [junk, fan.block.id, worded, space, newline, archived.block.id, earlier.block.id]
            for id in all { try ops.deleteBlock(id) }

            #expect(try sweepable(db) == [fan.block.id, junk],
                    "exactly the two empty shapes, the Trash's order (newest first)")
            #expect(try facts(db, all).map(\.wordedTakes) == [0, 0, 1, 1, 1, 1, 1],
                    "worded = non-zero-length text on ANY variant row of the block")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NOT NULL AND deleted_at <> (SELECT deleted_at FROM block WHERE id = ?)",
                [earlier.block.id, earlier.block.id]) == 1,
                    "premise: the earlier take died on its OWN stamp, not the block's")
        }
    }

    // MARK: - History (savepoints, comments, name, frame — and what is not)

    /// A savepoint (even of empty text), any comment row (live, or deleted on
    /// its own — the fold can still bring it back), a name and a frame each
    /// keep an empty block out. A block tag (P-828-9 (a)), a take label and a
    /// lock are not history: those blocks qualify.
    @Test func historyKeepsAnEmptyBlockOutAndMetadataDoesNot() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let saved = try ops.seedBlock(in: note.id, text: "")
            _ = try ops.commit(saved.variant.id)
            let quietSaved = try ops.seedBlock(in: note.id, text: "")
            _ = try ops.commit(quietSaved.variant.id, kind: .auto)
            let commented = try ops.seedBlock(in: note.id, text: "").block.id
            _ = try ops.addBlockComment(to: commented, text: "a thought")
            let uncommented = try ops.seedBlock(in: note.id, text: "").block.id
            let gone = try ops.addBlockComment(to: uncommented, text: "deleted on its own")
            try ops.deleteBlockComment(gone.id)
            let named = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.setBlockName(named, name: "a handle")
            let framed = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.setBlockPresentation(framed, BlockPresentation(emoji: "💡"))
            let tagged = try ops.seedBlock(in: note.id, text: "").block.id
            let tag = try ops.createTag(name: "scraps")
            _ = try ops.applyTag(tag.id, toBlock: tagged)
            let labeled = try ops.seedBlock(in: note.id, text: "")
            try ops.setTakeLabel(labeled.variant.id, label: "draft")
            let locked = try ops.seedBlock(in: note.id, text: "")
            try ops.lockVariant(locked.variant.id)
            let all = [
                saved.block.id, quietSaved.block.id, commented, uncommented, named, framed,
                tagged, labeled.block.id, locked.block.id,
            ]
            for id in all { try ops.deleteBlock(id) }

            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [locked.variant.id]) == 0,
                    "premise: locking an untouched empty take writes no savepoint")
            #expect(try sweepable(db) == [locked.block.id, labeled.block.id, tagged],
                    "only the metadata-only blocks qualify")
            let byID = Dictionary(uniqueKeysWithValues: try facts(db, all).map { ($0.blockID, $0) })
            #expect(byID[saved.block.id]?.savepoints == 1)
            #expect(byID[quietSaved.block.id]?.savepoints == 1, "a quiet savepoint is a savepoint")
            #expect(byID[commented]?.comments == 1)
            #expect(byID[uncommented]?.comments == 1, "a comment deleted on its own still counts")
            #expect(byID[named]?.name == "a handle")
            #expect(byID[framed]?.presentation != nil)
            #expect(byID[tagged] == EmptyBlockSweep.Facts(blockID: tagged), "a tag counts for nothing")
        }
    }

    // MARK: - Lineage (P-828-7 (a))

    /// A divide's empty second half that is deleted keeps its `derived_from`
    /// to the living first half — tombstoned on its OWN stamp by the cascade,
    /// still a link to a living block: out. Once the first half dies too, the
    /// link reaches only a dead block: in.
    @Test func aLinkToALivingBlockKeepsItOutAndALinkToADeadOneDoesNot() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let source = try ops.seedBlock(in: note.id, text: "Hello world.")
            let half = try ops.divide(source.block.id, cut: 6)
            try ops.autosave(half.variant.id, text: "", charDelta: 6)
            try ops.deleteBlock(half.block.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM edge WHERE id = ? AND deleted_at = (SELECT deleted_at FROM block WHERE id = ?)",
                [half.edge.id, half.block.id]) == 1,
                    "premise: the cascade tombstoned the edge on the half's own stamp")
            #expect(try facts(db, [half.block.id]).first?.livingLinks == 1)
            #expect(try sweepable(db).isEmpty, "linked to a living block: out")

            try ops.deleteBlock(source.block.id)
            #expect(try facts(db, [half.block.id]).first?.livingLinks == 0)
            #expect(try sweepable(db) == [half.block.id],
                    "edges among dead blocks don't save it (and the worded source never qualifies)")
        }
    }

    /// Every edge shape, hand-built between real blocks: any TYPE, either
    /// DIRECTION, and the edge row's own tombstone never consulted — a live
    /// `version_of`, the trashed block as the ANCESTOR of a living one, a
    /// link tombstoned on a third stamp (a peer's), a link to an ARCHIVED
    /// block (archived is alive) all keep it out; a self-edge and a link to
    /// a dead block do not.
    @Test func everyEdgeShapeIsReadByTheOtherSidesLifeAlone() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let living = try ops.seedBlock(in: note.id, text: "A living block.").block.id
            let kept = try ops.seedBlock(in: note.id, text: "An archived block.").block.id
            try ops.archiveBlock(kept)
            let dead = try ops.seedBlock(in: note.id, text: "A dead block.").block.id
            try ops.deleteBlock(dead)
            func emptyTrashed() throws -> String {
                let id = try ops.seedBlock(in: note.id, text: "").block.id
                try ops.deleteBlock(id)
                return id
            }
            let versioned = try emptyTrashed()
            try insertEdge(db, id: "e-version", from: living, to: versioned, type: "version_of")
            let ancestor = try emptyTrashed()
            try insertEdge(db, id: "e-ancestor", from: living, to: ancestor)
            let peerTomb = try emptyTrashed()
            try insertEdge(db, id: "e-peer", from: peerTomb, to: living,
                           deletedAt: "2026-06-01T00:00:00.000Z")
            let toArchived = try emptyTrashed()
            try insertEdge(db, id: "e-archived", from: toArchived, to: kept)
            let selfLinked = try emptyTrashed()
            try insertEdge(db, id: "e-self", from: selfLinked, to: selfLinked)
            let toDead = try emptyTrashed()
            try insertEdge(db, id: "e-dead", from: toDead, to: dead)

            #expect(try facts(db, [versioned, ancestor, peerTomb, toArchived, selfLinked, toDead])
                .map(\.livingLinks) == [1, 1, 1, 1, 0, 0])
            #expect(try sweepable(db) == [toDead, selfLinked])
        }
    }

    /// An edge whose other side has no block row at all (a ghost — no
    /// operation makes one; FKs off) reaches nothing living: it doesn't count.
    @Test func aLinkToAnAbsentBlockReachesNothingLiving() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let id = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.deleteBlock(id)
            try db.writeWithoutTransaction { database in
                try database.execute(sql: "PRAGMA foreign_keys = OFF")
                try database.execute(
                    sql: """
                        INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op,
                                          created_at, deleted_at)
                        VALUES ('e-ghost', ?, 'no-such-block', 'derived_from', 'manual',
                                '2026-07-01T00:00:00.000Z', NULL)
                        """,
                    arguments: [id])
                try database.execute(sql: "PRAGMA foreign_keys = ON")
            }
            #expect(try facts(db, [id]).first?.livingLinks == 0)
            #expect(try sweepable(db) == [id])
        }
    }

    // MARK: - The candidate set (the Trash's own block rows)

    /// Only what the Trash rows as a BLOCK is a candidate: a block that died
    /// WITH its note (the note's one row) never is — sweeping it alone would
    /// break the note's whole Put back; a block deleted from a note BEFORE
    /// the note went is its own row and is; a live empty block never is;
    /// past the window and behind a standing intent, nothing is.
    @Test func onlyTheTrashsOwnBlockRowsAreCandidates() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let earlier = try ops.seedBlock(in: note.id, text: "").block.id
            let victim = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.deleteBlock(earlier)
            try ops.deleteContainer(note.id)
            let home = try ops.createPost(title: "home")
            _ = try ops.seedBlock(in: home.id, text: "")  // live, empty: never a candidate
            let fenced = try ops.seedBlock(in: home.id, text: "").block.id
            try ops.deleteBlock(fenced)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: fenced)])

            #expect(try db.deletedAt("block", victim) == db.deletedAt("container", note.id),
                    "premise: the victim died on its note's stamp")
            #expect(try sweepable(db) == [earlier],
                    "the earlier block's own row only — not the cascade victim, not the fenced one")
            #expect(try sweepable(db, now: harnessNow.addingTimeInterval(31 * 86_400)).isEmpty,
                    "past the 30-day window the Trash rows nothing")
        }
    }

    /// The wing fence is the listing's own: a note's wing places its blocks;
    /// Home's Trash (`""`) never shows another wing's; nil is every wing.
    @Test func theWingFenceIsTheListingsOwn() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Far")
            let far = try ops.createPost(title: "far", wingId: wing.id)
            let farJunk = try ops.seedBlock(in: far.id, text: "").block.id
            let home = try ops.createPost(title: "home")
            let homeJunk = try ops.seedBlock(in: home.id, text: "").block.id
            try ops.deleteBlock(farJunk)
            try ops.deleteBlock(homeJunk)
            #expect(try sweepable(db, wingID: wing.id) == [farJunk])
            #expect(try sweepable(db, wingID: "") == [homeJunk])
            #expect(try sweepable(db) == [homeJunk, farJunk])
        }
    }

    /// The facts answer in the order asked, once per id; an unknown id is
    /// simply absent.
    @Test func factsAnswerInTheOrderAskedOncePerID() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let a = try ops.seedBlock(in: note.id, text: "").block.id
            let b = try ops.seedBlock(in: note.id, text: "b").block.id
            #expect(try facts(db, [b, "missing", a, b]).map(\.blockID) == [b, a])
            #expect(try facts(db, []).isEmpty)
        }
    }

    // MARK: - The act (`Operations.sweepEmptyTrashBlocks`)

    /// One intent per taken block, nothing else written, no undo entry; the
    /// taken rows leave the Trash at once (the stamp-aware fence) while a
    /// worded neighbour stays; a never-synced family's bytes then go with the
    /// local sweep — and a Put back that still names one finds nothing to
    /// count back.
    @Test func theSweepMintsOneIntentPerTakenBlockAndTheBytesFollow() async throws {
        try await withOperationsAsync { ops, db in
            let stacked = Operations(undoStack: UndoStack())
            let note = try ops.createPost(title: "home")
            let a = try ops.seedBlock(in: note.id, text: "")
            let b = try ops.seedBlock(in: note.id, text: "")
            let worded = try ops.seedBlock(in: note.id, text: "words").block.id
            for id in [a.block.id, b.block.id, worded] { try ops.deleteBlock(id) }
            #expect(try sweepable(db) == [b.block.id, a.block.id])

            let taken = try stacked.sweepEmptyTrashBlocks([a.block.id, b.block.id])
            #expect(taken == [a.block.id, b.block.id], "the order given")
            #expect(stacked.undoStack?.depth == 0, "no ⌥⌘Z entry — the confirm is the guard")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM purge_intent") == 2)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE table_name = 'block' AND deleted_at IS NULL AND row_id IN (?, ?)",
                [a.block.id, b.block.id]) == 2, "one live intent per taken block")
            #expect(try trashIDs(db) == [worded],
                    "the taken rows left the Trash at the intent write; the worded block stays")
            #expect(try sweepable(db).isEmpty)

            let report = try await LocalPurge(database: db).sweep()
            #expect(report.familiesPurged == 2)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id IN (?, ?)", [a.block.id, b.block.id]) == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE id IN (?, ?)", [a.variant.id, b.variant.id]) == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block WHERE id = ?", [worded]) == 1)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE deleted_at IS NULL") == 0, "intents completed")
            #expect(throws: OperationError.blockNotFound(id: a.block.id)) {
                _ = try ops.restoreBlock(a.block.id)
            }
        }
    }

    /// The horizon is honored: a family the server has seen (a `sync_row_seq`
    /// row) is never removed by the LOCAL road — its intent stands, its bytes
    /// wait for the janitor, and the Trash already lists it no more.
    @Test func aSyncedFamilyWaitsForTheHorizon() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "home")
            let synced = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.deleteBlock(synced)
            try markSynced(db, table: "block", synced)
            #expect(try ops.sweepEmptyTrashBlocks([synced]) == [synced])
            _ = try await LocalPurge(database: db).sweep()
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block WHERE id = ?", [synced]) == 1,
                    "the bytes wait for every device to have seen the deletion")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE row_id = ? AND deleted_at IS NULL", [synced]) == 1)
            #expect(try trashIDs(db).isEmpty)
        }
    }

    /// **confirm ids ∩ still-qualifying, re-read inside the transaction.** In
    /// the pause between the confirm and the act: one block is put back; one
    /// is put back and then dies again WITH its note (now the note's cascade
    /// victim — never swept alone); one takes words through a sync-apply-
    /// shaped write; one is already fenced by another door's intent; and a
    /// NEW junk block lands in the Trash. Only the untouched confirmed block
    /// is taken — never more than she confirmed, never a stale row.
    @Test func theActTakesOnlyWhatTheConfirmShowedThatStillQualifies() throws {
        try withOperations { ops, db in
            let home = try ops.createPost(title: "home")
            let other = try ops.createPost(title: "other")
            let kept = try ops.seedBlock(in: home.id, text: "").block.id
            let putBack = try ops.seedBlock(in: home.id, text: "").block.id
            let victim = try ops.seedBlock(in: other.id, text: "").block.id
            let worded = try ops.seedBlock(in: home.id, text: "")
            let fenced = try ops.seedBlock(in: home.id, text: "").block.id
            for id in [kept, putBack, victim, worded.block.id, fenced] { try ops.deleteBlock(id) }
            let confirmed = try sweepable(db)
            #expect(Set(confirmed) == [kept, putBack, victim, worded.block.id, fenced])

            _ = try ops.restoreBlock(putBack)
            _ = try ops.restoreBlock(victim)
            try ops.deleteContainer(other.id)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE variant SET working_text = 'arrived by sync' WHERE id = ?",
                    arguments: [worded.variant.id])
            }
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: fenced)])
            let newcomer = try ops.seedBlock(in: home.id, text: "").block.id
            try ops.deleteBlock(newcomer)
            let intentsBefore = try db.fetchInt("SELECT COUNT(*) FROM purge_intent")

            #expect(try ops.sweepEmptyTrashBlocks(confirmed + [kept, "no-such-block"]) == [kept])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM purge_intent") == (intentsBefore ?? 0) + 1,
                    "exactly one intent written — the kept block's")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM purge_intent WHERE row_id = ? AND deleted_at IS NULL", [kept]) == 1)
            #expect(try sweepable(db) == [newcomer], "the newcomer waits for its own confirm")
        }
    }

    /// Nothing left at act time ⇒ NOTHING WRITTEN, and an empty answer the
    /// door speaks as a refusal.
    @Test func nothingLeftWritesNothing() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "home")
            let junk = try ops.seedBlock(in: note.id, text: "").block.id
            try ops.deleteBlock(junk)
            let confirmed = try sweepable(db)
            _ = try ops.restoreBlock(junk)
            try db.clearOutbox()
            #expect(try ops.sweepEmptyTrashBlocks(confirmed).isEmpty)
            #expect(try ops.sweepEmptyTrashBlocks([]).isEmpty)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM purge_intent") == 0)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0, "not one row written")
        }
    }

    /// **Why the edge clause reads every edge row (P-828-7 (a)) — the sweep
    /// can never take a living block.** A merge's fresh block, emptied and
    /// deleted, is the only descendant of its two LIVE released originals: the
    /// sweep refuses it (a link to a living block), and the CONTRAST shows
    /// what a purge of it would do — the purge family takes a stranded
    /// original with its last descendant, so both originals' words would go.
    /// One level down, an empty block whose link reaches only the dead merged
    /// block IS swept, and the originals stay whole: a dead, present
    /// descendant still protects them.
    @Test func theSweepNeverTakesALivingBlock() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "home")
            let source = try ops.seedBlock(in: note.id, text: "Alpha beta.")
            let half = try ops.divide(source.block.id, cut: 6)
            let merged = try ops.merge(source.block.id, half.block.id)
            let originals = [source.block.id, half.block.id]
            let tail = try ops.divide(merged.block.id, cut: 6)
            try ops.autosave(tail.variant.id, text: "", charDelta: 5)
            try ops.deleteBlock(tail.block.id)
            try ops.deleteBlock(merged.block.id)
            #expect(try sweepable(db) == [tail.block.id],
                    "the tail's one link reaches the dead merged block; the merged block is worded")
            #expect(try ops.sweepEmptyTrashBlocks([tail.block.id]) == [tail.block.id])
            _ = try await LocalPurge(database: db).sweep()
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block WHERE id = ?", [tail.block.id]) == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE deleted_at IS NULL AND id IN (?, ?)", originals) == 2,
                    "both living originals stand — the dead merged block still protects them")

            // The merged block itself, emptied: linked to two living originals.
            let emptied = try ops.seedBlock(in: note.id, text: "Gamma delta.")
            let half2 = try ops.divide(emptied.block.id, cut: 6)
            let merged2 = try ops.merge(emptied.block.id, half2.block.id)
            try ops.autosave(merged2.variant.id, text: "", charDelta: 13)
            try ops.deleteBlock(merged2.block.id)
            #expect(try facts(db, [merged2.block.id]).first?.livingLinks == 2)
            #expect(try ops.sweepEmptyTrashBlocks([merged2.block.id]).isEmpty, "never swept")

            // CONTRAST — the hazard (a) forecloses: purge it anyway.
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: merged2.block.id)])
            _ = try await LocalPurge(database: db).sweep()
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE id IN (?, ?)", [emptied.block.id, half2.block.id]) == 0,
                    "the purge family took both LIVING originals with their last descendant")
        }
    }

    // MARK: - The held observation's region

    /// The named region is COMPLETE (a table read and not named would leave
    /// the door's count stale on its writes) and EXACT (a table named and not
    /// read wakes it for nothing), against the regions GRDB derives from
    /// every statement the read runs — every fence, every fact answering.
    @Test func theSweepsNamedTablesAreExactlyTheTablesItReads() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Far")
            let far = try ops.createPost(title: "far", wingId: wing.id)
            let home = try ops.createPost(title: "home")
            let a = try ops.seedBlock(in: home.id, text: "")
            _ = try ops.commit(a.variant.id)
            let b = try ops.seedBlock(in: far.id, text: "").block.id
            _ = try ops.addBlockComment(to: b, text: "kept")
            let source = try ops.seedBlock(in: home.id, text: "Hello world.")
            let half = try ops.divide(source.block.id, cut: 6)
            for id in [a.block.id, b, half.block.id] { try ops.deleteBlock(id) }

            let region: DatabaseRegion = try db.read { database in
                let captured = LockIsolated<[String]>([])
                let capturing = LockIsolated(true)
                database.trace(options: .statement) { event in
                    guard capturing.value, case .statement(let statement) = event else { return }
                    let sql = statement.sql
                    captured.withValue { $0.append(sql) }
                }
                for wingID in [nil, "", wing.id] as [String?] {
                    _ = try Queries.emptyTrashBlocks(database, now: harnessNow, wingID: wingID)
                }
                capturing.setValue(false)
                var region = DatabaseRegion()
                for sql in captured.value {
                    region = region.union(try database.makeStatement(sql: sql).databaseRegion)
                }
                return region
            }
            let tables = try db.read { database in
                try String.fetchAll(
                    database,
                    sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
            }
            let read = Set(tables.filter { region.isModified(byEventsOfKind: .insert(tableName: $0)) })
            let unnamed = read.subtracting(Queries.emptyBlockSweepTables).sorted()
            let unread = Set(Queries.emptyBlockSweepTables).subtracting(read).sorted()
            #expect(read == Set(Queries.emptyBlockSweepTables),
                    "read but not named: \(unnamed); named but not read: \(unread)")
        }
    }
}
