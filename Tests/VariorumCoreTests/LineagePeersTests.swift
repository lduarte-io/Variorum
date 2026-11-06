//
//  LineagePeersTests.swift
//  VariorumCoreTests
//
//  VX-827 U1 (VX-817's source) — `Queries.lineagePeers`: a note's lineage
//  peers, one hop at the block level, both ends live and placed in live notes.
//  Exact rows over every structural shape the brief names (a divide chain, a
//  merge, an extract, a pool copy, a duplicate's `version_of`, cross-note,
//  cross-wing, a tombstoned edge, a dead block, an archived take's block, a
//  released original, a cycle), then the P1 pins: the read's work is flat as
//  the LIBRARY grows, linear in the note's own lineage, and its plan never
//  scans a store table (the VX-654 precedent, `LineageReadP1Tests`).
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private typealias Link = Queries.LineageLink
private typealias Peer = Queries.LineagePeer

private final class PeersInstructionCounter: @unchecked Sendable { var value = 0 }

/// Every SQLite VM instruction the connection executes while `body` runs.
private func instructions(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    try db.read { database in
        let counter = PeersInstructionCounter()
        let context = Unmanaged.passRetained(counter).toOpaque()
        defer { Unmanaged<PeersInstructionCounter>.fromOpaque(context).release() }
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<PeersInstructionCounter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
        defer { sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil) }
        try body(database)
        return counter.value
    }
}

/// The joined query plan of every SELECT `body` ran.
private func capturedPlan(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> String {
    let statements: [String] = try db.read { database in
        let captured = LockIsolated<[String]>([])
        let capturing = LockIsolated(true)
        database.trace(options: .statement) { event in
            guard capturing.value, case .statement(let statement) = event else { return }
            let sql = statement.expandedSQL
            captured.withValue { $0.append(sql) }
        }
        try body(database)
        capturing.setValue(false)
        return captured.value.filter {
            let head = $0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6).uppercased()
            return head.hasPrefix("SELECT") || head.hasPrefix("WITH")
        }
    }
    return try db.read { database in
        try statements.flatMap { sql in
            try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }.joined(separator: "\n")
    }
}

/// A plan line that SCANs a store table (any alias the lineage reads use for
/// one) — the only legal SCANs are the query's own CTEs and `json_each`.
func lineageStoreTableScans(_ plan: String) -> [String] {
    let storeAliases = [
        "e", "b", "cb", "far", "theirs", "peer", "edge", "block", "container_block", "container",
        "variant", "chosen", "dflt", "home", "cascaded", "placed", "o", "d",
    ]
    return plan.split(separator: "\n").map(String.init).filter { line in
        storeAliases.contains { line == "SCAN \($0)" || line.hasPrefix("SCAN \($0) ") }
    }
}

/// The live edge between two blocks of a type — its id and stamp, the two
/// facts an exact `LineageLink` carries that the fixture does not choose.
private func edge(_ db: AppDatabase, _ source: String, _ target: String, _ type: String) throws -> (id: String, at: String) {
    try db.read { db in
        let row = try #require(try Row.fetchOne(
            db,
            sql: """
                SELECT id, created_at FROM edge
                WHERE source_block_id = ? AND target_block_id = ? AND type = ? AND deleted_at IS NULL
                """,
            arguments: [source, target, type]))
        return (row["id"], row["created_at"])
    }
}

/// The link from `mine`'s side: `relation` names how `theirs` stands to it.
private func link(
    _ db: AppDatabase, _ mine: String, _ theirs: String, _ relation: Link.Relation, _ op: String?
) throws -> Link {
    let found: (id: String, at: String)
    switch relation {
    case .derivedFrom: found = try edge(db, mine, theirs, "derived_from")
    case .derivedInto: found = try edge(db, theirs, mine, "derived_from")
    case .versionOf: found = try edge(db, min(mine, theirs), max(mine, theirs), "version_of")
    }
    return Link(blockID: mine, peerBlockID: theirs, relation: relation, originOp: op, edgeID: found.id, at: found.at)
}

private func peers(_ db: AppDatabase, _ note: String) throws -> [Peer] {
    try db.read { try Queries.lineagePeers($0, noteID: note) }
}

private let twoSentences = "Paragraph seam has words. And a second sentence follows here."

@Suite("VX-827 U1 — a note's lineage peers: one hop, both ends live and placed")
struct LineagePeersTests {

    // MARK: - Exact rows

    /// A DIVIDE CHAIN across three notes: N's block is divided and its half
    /// moved to P; P's half is divided and ITS half moved to Q. One hop at the
    /// block level — N peers P, P peers both, Q peers P; N and Q never meet.
    @Test func aDivideChainPeersEachNoteWithItsNeighboursOnly() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let p = try ops.createPost(title: "P")
            let q = try ops.createPost(title: "Q")
            let a = try ops.seedBlock(in: n.id, text: twoSentences).block.id
            let c = try ops.divide(a, cut: 24).block.id
            try ops.moveBlock(c, to: p.id)
            let d = try ops.divide(c, cut: 10).block.id
            try ops.moveBlock(d, to: q.id)

            #expect(try peers(db, n.id) == [
                Peer(noteID: p.id, wingID: "", archivedAt: nil, links: [try link(db, a, c, .derivedInto, "divide")]),
            ])
            #expect(try peers(db, p.id) == [
                Peer(noteID: n.id, wingID: "", archivedAt: nil, links: [try link(db, c, a, .derivedFrom, "divide")]),
                Peer(noteID: q.id, wingID: "", archivedAt: nil, links: [try link(db, c, d, .derivedInto, "divide")]),
            ].sorted { $0.noteID < $1.noteID })
            #expect(try peers(db, q.id) == [
                Peer(noteID: p.id, wingID: "", archivedAt: nil, links: [try link(db, d, c, .derivedFrom, "divide")]),
            ])
            let chain = try peers(db, p.id)
            #expect(chain.first { $0.noteID == n.id }?.holdsAnOriginal == true)
            #expect(chain.first { $0.noteID == q.id }?.holdsACopy == true)
        }
    }

    /// A MERGE and a divide-W release their sources: a RELEASED ORIGINAL is in
    /// no note, so the successor that moved to another note is joined to
    /// nothing there — its lineage runs through a block neither note holds.
    @Test func aReleasedOriginalJoinsNeitherNote() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let p = try ops.createPost(title: "P")
            let x = try ops.seedBlock(in: n.id, text: "Ex.").block.id
            let y = try ops.seedBlock(in: n.id, text: "Why.").block.id
            let merged = try ops.merge(x, y).block.id
            try ops.moveBlock(merged, to: p.id)
            let fanned = try ops.seedBlock(in: n.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            try ops.moveBlock(w.second.block.id, to: p.id)

            #expect(try peers(db, n.id) == [], "the merge's sources and the W's original are released, not N's")
            #expect(try peers(db, p.id) == [])
        }
    }

    /// An EXTRACT whose span moved to a note in ANOTHER WING: a peer there,
    /// with that wing named.
    @Test func anExtractMovedAcrossWingsIsAPeerInItsWing() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let n = try ops.createPost(title: "N")
            let r = try ops.createPost(title: "R", wingId: studio.id)
            let e = try ops.seedBlock(in: n.id, text: "Kept part. Extracted part.").block.id
            let extracted = try ops.extract(e, span: 11..<26).block.id
            try ops.moveBlock(extracted, to: r.id)

            #expect(try peers(db, n.id) == [
                Peer(noteID: r.id, wingID: studio.id, archivedAt: nil,
                     links: [try link(db, e, extracted, .derivedInto, "extract")]),
            ])
            #expect(try peers(db, r.id) == [
                Peer(noteID: n.id, wingID: "", archivedAt: nil,
                     links: [try link(db, extracted, e, .derivedFrom, "extract")]),
            ])
        }
    }

    /// A POOL COPY: the scrap stays in the pool, and a pool is not a note —
    /// the edge exists, the peer does not.
    @Test func aPoolCopyIsNoPeer() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let pool = try ops.createPool()
            let scrap = try ops.seedBlock(in: pool.id, text: "A scrap.").block.id
            let copy = try ops.poolDragCopy(scrap, to: n.id).block.id
            #expect(try edge(db, copy, scrap, "derived_from").id.isEmpty == false, "the fixture's edge")
            #expect(try peers(db, n.id) == [])
            // Asked of the POOL itself (no caller does — the read is
            // container-agnostic about its subject, never about its peers):
            // N holds the copy.
            #expect(try peers(db, pool.id) == [
                Peer(noteID: n.id, wingID: "", archivedAt: nil,
                     links: [try link(db, scrap, copy, .derivedInto, "pool_copy")]),
            ])
        }
    }

    /// A DUPLICATE is a peer by every block (each copy derived from its
    /// source, origin 'manual') and by its ONE `version_of` anchor; Copy to
    /// Wing is the same family copy in another wing. A SAVED VERSION is no
    /// peer — Note ▸ Versions is its one home.
    @Test func aDuplicateIsAPeerByEveryBlockAndItsVersionLinkAndASavedVersionIsNot() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let n = try ops.createPost(title: "N")
            let n1 = try ops.seedBlock(in: n.id, text: "One.").block.id
            let n2 = try ops.seedBlock(in: n.id, text: "Two.").block.id
            _ = try ops.saveNoteVersion(n.id)
            let dup = try ops.duplicateAsVersion(n.id)
            let copies = Dictionary(uniqueKeysWithValues: dup.blockCopies.map { ($0.source, $0.copy) })
            let d1 = try #require(copies[n1]), d2 = try #require(copies[n2])
            let away = try ops.copyNoteToWing(n.id, to: studio.id)
            let awayBlocks = try db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """, arguments: [away.id])
            }
            #expect(awayBlocks.count == 2)

            let expected = [
                Peer(noteID: dup.post.id, wingID: "", archivedAt: nil, links: [
                    try link(db, n1, d1, .derivedInto, "manual"),
                    try link(db, n1, d1, .versionOf, "manual"),
                    try link(db, n2, d2, .derivedInto, "manual"),
                ]),
                Peer(noteID: away.id, wingID: studio.id, archivedAt: nil, links: [
                    try link(db, n1, awayBlocks[0], .derivedInto, "manual"),
                    try link(db, n1, awayBlocks[0], .versionOf, "manual"),
                    try link(db, n2, awayBlocks[1], .derivedInto, "manual"),
                ]),
            ].sorted { $0.noteID < $1.noteID }
            #expect(try peers(db, n.id) == expected, "no saved version among them")
            let fromCopy = try #require(try peers(db, dup.post.id).first)
            #expect(fromCopy.noteID == n.id && fromCopy.holdsAnOriginal && fromCopy.isAVersion && !fromCopy.holdsACopy)
        }
    }

    /// The liveness rules: a TOMBSTONED edge (taken apart on its own — sync
    /// debris for `derived_from`, the unmark door for `version_of`), a DEAD
    /// block and a DEAD note are absent; a block whose chosen take was
    /// ARCHIVED stays a peer (the block is live and placed); an ARCHIVED note
    /// is a peer and says so; an archived (set-aside) block is absent.
    @Test func tombstonedEdgesDeadBlocksAndDeadNotesAreAbsentArchivedThingsAnswerExactly() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            var halves: [String: (mine: String, theirs: String)] = [:]
            var notes: [String: String] = [:]
            for name in ["debris", "deadBlock", "deadNote", "archivedTake", "archivedNote", "setAside"] {
                let other = try ops.createPost(title: name)
                notes[name] = other.id
                let a = try ops.seedBlock(in: n.id, text: twoSentences).block.id
                let c = try ops.divide(a, cut: 24)
                try ops.moveBlock(c.block.id, to: other.id)
                halves[name] = (a, c.block.id)
            }
            let unmarked = try ops.createPost(title: "unmarked")
            _ = try ops.seedBlock(in: unmarked.id, text: "Linked, then not.")
            _ = try ops.markPostsAsVersions(n.id, unmarked.id)
            try ops.unmarkPostsAsVersions(n.id, unmarked.id)

            let debris = try #require(halves["debris"])
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE edge SET deleted_at = '2026-07-01T05:00:00.000Z'
                        WHERE source_block_id = ? AND target_block_id = ? AND type = 'derived_from'
                        """,
                    arguments: [debris.theirs, debris.mine])
            }
            try ops.deleteBlock(try #require(halves["deadBlock"]).theirs)
            try ops.deleteContainer(try #require(notes["deadNote"]))
            let archivedTake = try #require(halves["archivedTake"])
            let first = try db.read { db in
                try #require(try String.fetchOne(
                    db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [archivedTake.theirs]))
            }
            _ = try ops.branchVariant(archivedTake.theirs, from: first)
            try ops.archiveVariant(first)
            #expect(try db.fetchString("SELECT status FROM variant WHERE id = ?", [first]) == "archived")
            let archivedNoteID = try #require(notes["archivedNote"])
            try ops.archiveContainer(archivedNoteID)
            try ops.archiveBlock(try #require(halves["setAside"]).theirs)
            let archivedAt = try db.fetchString("SELECT archived_at FROM container WHERE id = ?", [archivedNoteID])
            #expect(archivedAt != nil)

            let archivedNote = try #require(halves["archivedNote"])
            #expect(try peers(db, n.id) == [
                Peer(noteID: try #require(notes["archivedTake"]), wingID: "", archivedAt: nil,
                     links: [try link(db, archivedTake.mine, archivedTake.theirs, .derivedInto, "divide")]),
                Peer(noteID: archivedNoteID, wingID: "", archivedAt: archivedAt,
                     links: [try link(db, archivedNote.mine, archivedNote.theirs, .derivedInto, "divide")]),
            ].sorted { $0.noteID < $1.noteID })
        }
    }

    /// A CYCLE (no operation makes one; the read must still answer exactly):
    /// X in N and Y in P derive from each other — one link each way.
    @Test func aCycleBetweenTwoNotesReadsBothWays() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let p = try ops.createPost(title: "P")
            let x = try ops.seedBlock(in: n.id, text: "Ex.").block.id
            let y = try ops.seedBlock(in: p.id, text: "Why.").block.id
            try db.write { db in
                for (id, source, target) in [("cycle-1", x, y), ("cycle-2", y, x)] {
                    try db.execute(
                        sql: """
                            INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                            VALUES (?, ?, ?, 'derived_from', 'divide', '2026-07-01T00:30:00.000Z')
                            """,
                        arguments: [id, source, target])
                }
            }
            #expect(try peers(db, n.id) == [
                Peer(noteID: p.id, wingID: "", archivedAt: nil, links: [
                    Link(blockID: x, peerBlockID: y, relation: .derivedFrom, originOp: "divide",
                         edgeID: "cycle-1", at: "2026-07-01T00:30:00.000Z"),
                    Link(blockID: x, peerBlockID: y, relation: .derivedInto, originOp: "divide",
                         edgeID: "cycle-2", at: "2026-07-01T00:30:00.000Z"),
                ]),
            ])
        }
    }

    /// No lineage, an empty note, a missing id: nothing.
    @Test func noLineageAnEmptyNoteAndAMissingIDAnswerNothing() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            _ = try ops.seedBlock(in: n.id, text: "Alone.")
            let empty = try ops.createPost(title: "empty")
            #expect(try peers(db, n.id) == [])
            #expect(try peers(db, empty.id) == [])
            #expect(try peers(db, "no-such-note") == [])
        }
    }

    // MARK: - P1

    /// A note whose `count` blocks each have a copy in their own note.
    private func copiedNote(_ ops: Operations, count: Int) throws -> String {
        let n = try ops.createPost(title: "N")
        for k in 0..<count {
            let a = try ops.seedBlock(in: n.id, text: twoSentences).block.id
            let c = try ops.divide(a, cut: 24).block.id
            let away = try ops.createPost(title: "away \(k)")
            try ops.moveBlock(c, to: away.id)
        }
        return n.id
    }

    /// P1's other half: the read must not grow with the LIBRARY — the same
    /// note, in a library fifteen times thicker (more notes, blocks and
    /// lineage edges elsewhere), costs the same.
    @Test func theReadDoesNotGrowWithTheLibrary() throws {
        func work(blocksEach: Int) throws -> Int {
            try withOperations { ops, db in
                for n in 0..<20 {
                    let other = try ops.createPost(title: "library \(n)")
                    for b in 0..<blocksEach {
                        let minted = try ops.seedBlock(
                            in: other.id, text: "Library paragraph \(b) of note \(n). And a second sentence.")
                        if b % 2 == 0 { _ = try ops.divide(minted.block.id, cut: 8) }
                    }
                }
                let note = try copiedNote(ops, count: 6)
                #expect(try peers(db, note).count == 6)
                return try instructions(db) { _ = try Queries.lineagePeers($0, noteID: note) }
            }
        }
        let thin = try work(blocksEach: 2)
        let thick = try work(blocksEach: 30)
        print("VX-827 lineagePeers VM instructions: library ×1 \(thin), ×15 \(thick)")
        #expect(Double(thick) < Double(thin) * 1.5,
                "library ×15: \(thin) → \(thick) VM instructions — the library must not drive the read (P1)")
    }

    /// The read grows with the NOTE's own lineage, linearly.
    @Test func theReadGrowsWithTheNotesOwnLineageLinearly() throws {
        func work(count: Int) throws -> Int {
            try withOperations { ops, db in
                let note = try copiedNote(ops, count: count)
                #expect(try peers(db, note).count == count)
                return try instructions(db) { _ = try Queries.lineagePeers($0, noteID: note) }
            }
        }
        let short = try work(count: 20)
        let long = try work(count: 60)
        print("VX-827 lineagePeers VM instructions: 20 links \(short), 60 links \(long)")
        #expect(Double(long) < Double(short) * 3.9, "links ×3: \(short) → \(long) — linear is ≤ ×3")
    }

    /// The plan, as the claims' mechanism: every store table is SEARCHed by
    /// index — only the query's own sets are scanned.
    @Test func theReadNeverScansAStoreTable() throws {
        try withOperations { ops, db in
            let note = try copiedNote(ops, count: 3)
            let plan = try capturedPlan(db) { _ = try Queries.lineagePeers($0, noteID: note) }
            let scans = lineageStoreTableScans(plan)
            #expect(scans.isEmpty, "store-table scans \(scans); plan was:\n\(plan)")
        }
    }
}
