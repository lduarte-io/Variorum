//
//  LineageTreeTests.swift
//  VariorumCoreTests
//
//  VX-827 U1 (the read VX-801's lineage door draws, U3) — `Queries.lineageTree`:
//  one block's ancestors and descendants over `derived_from`, transitively,
//  plus its `version_of` siblings; each node's depth, connecting edge, state,
//  home and shown text. Exact trees over every structural shape the brief
//  names (a divide chain, a merge, an extract, a pool copy, a duplicate's
//  `version_of`, cross-note, cross-wing, a tombstoned edge, a dead block, an
//  archived take's block, a released original, a cycle), then the P1 pins:
//  linear in the block's own lineage (a seam history), flat as the LIBRARY
//  grows, and a plan that never scans a store table (`LineageReadP1Tests`'
//  precedent).
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private typealias Node = Queries.LineageTreeNode
private typealias TreeEdge = Queries.LineageTreeEdge
private typealias Home = Queries.LineageHome

private final class TreeInstructionCounter: @unchecked Sendable { var value = 0 }

private func instructions(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    try db.read { database in
        let counter = TreeInstructionCounter()
        let context = Unmanaged.passRetained(counter).toOpaque()
        defer { Unmanaged<TreeInstructionCounter>.fromOpaque(context).release() }
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<TreeInstructionCounter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
        defer { sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil) }
        try body(database)
        return counter.value
    }
}

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

private let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

private func tree(_ db: AppDatabase, _ block: String) throws -> Queries.LineageTree? {
    try db.read { try Queries.lineageTree($0, blockID: block, calendar: utc) }
}

/// The edge between two blocks of a type as the store holds it (live or
/// cascade-dead) — the facts an exact tree carries that the fixture does not
/// choose: its id and stamps.
private func edge(_ db: AppDatabase, _ source: String, _ target: String, _ type: EdgeType) throws -> TreeEdge {
    try db.read { db in
        let row = try #require(try Row.fetchOne(
            db,
            sql: """
                SELECT id, origin_op, created_at, deleted_at FROM edge
                WHERE source_block_id = ? AND target_block_id = ? AND type = ?
                ORDER BY created_at DESC, id DESC LIMIT 1
                """,
            arguments: [source, target, type.rawValue]))
        return TreeEdge(
            id: row["id"], sourceBlockID: source, targetBlockID: target, type: type,
            originOp: row["origin_op"], createdAt: row["created_at"], deletedAt: row["deleted_at"])
    }
}

private func versionEdge(_ db: AppDatabase, _ a: String, _ b: String) throws -> TreeEdge {
    try edge(db, min(a, b), max(a, b), .versionOf)
}

/// A take's stored text.
private func text(_ db: AppDatabase, _ variant: String) throws -> String? {
    try db.fetchString("SELECT working_text FROM variant WHERE id = ?", [variant])
}

/// The take a block shows by AppSpec §7's read rule — the very read
/// `renderPost` makes (placed), else the default (unplaced or dead).
private func defaultTake(_ db: AppDatabase, _ block: String) throws -> String {
    try #require(try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [block]))
}

private func home(
    _ id: String, _ title: String, kind: ContainerKind = .post, wing: String = "", deleted: Bool = false,
    version: Bool = false
) -> Home {
    Home(containerID: id, kind: kind, title: title, wingID: wing, isDeleted: deleted, isSavedVersion: version)
}

private let twoSentences = "Paragraph seam has words. And a second sentence follows here."

@Suite("VX-827 U1 — one block's lineage tree: the whole family, bounded by itself")
struct LineageTreeTests {

    // MARK: - Exact trees

    /// A DIVIDE CHAIN, its last half moved to another note: up from the end,
    /// down from the start, each node at its depth with the edge that reached
    /// it and the note it stands in.
    @Test func aDivideChainsTreeIsExactBothWays() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let p = try ops.createPost(title: "P")
            let seeded = try ops.seedBlock(in: n.id, text: twoSentences)
            let a = seeded.block.id
            let c = try ops.divide(a, cut: 24)
            let d = try ops.divide(c.block.id, cut: 10)
            try ops.moveBlock(d.block.id, to: p.id)
            let ca = try edge(db, c.block.id, a, .derivedFrom), dc = try edge(db, d.block.id, c.block.id, .derivedFrom)
            #expect(ca.originOp == "divide" && dc.originOp == "divide" && ca.deletedAt == nil)

            let up = try #require(try tree(db, d.block.id))
            #expect(up.origin == Node(
                blockID: d.block.id, direction: .origin, depth: 0, via: nil, state: .placed(containerID: p.id),
                home: home(p.id, "P"), shownTakeID: d.variant.id, text: try text(db, d.variant.id)))
            #expect(up.nodes == [
                Node(blockID: c.block.id, direction: .ancestor, depth: 1, via: dc, state: .placed(containerID: n.id),
                     home: home(n.id, "N"), shownTakeID: c.variant.id, text: try text(db, c.variant.id)),
                Node(blockID: a, direction: .ancestor, depth: 2, via: ca, state: .placed(containerID: n.id),
                     home: home(n.id, "N"), shownTakeID: seeded.variant.id, text: try text(db, seeded.variant.id)),
            ])
            #expect(up.edges == [ca, dc].sorted { $0.id < $1.id })
            #expect(up.nodes.map(\.originOp) == ["divide", "divide"])

            let down = try #require(try tree(db, a))
            #expect(down.ancestors.isEmpty && down.versions.isEmpty)
            #expect(down.descendants.map { [$0.blockID, "\($0.depth)", $0.via?.id ?? ""] }
                    == [[c.block.id, "1", ca.id], [d.block.id, "2", dc.id]])
            #expect(down.descendants.last?.state == .placed(containerID: p.id))
        }
    }

    /// A MERGE's sources and a DIVIDE-W's whole original are PRESERVED AS
    /// LINEAGE — live, unplaced, released from the note they name — and show
    /// the take they keep.
    @Test func aMergeAndADivideWsReleasedOriginalsArePreservedLineage() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let x = try ops.seedBlock(in: n.id, text: "Ex.")
            let y = try ops.seedBlock(in: n.id, text: "Why.")
            let m = try ops.merge(x.block.id, y.block.id)
            let mx = try edge(db, m.block.id, x.block.id, .derivedFrom)
            let my = try edge(db, m.block.id, y.block.id, .derivedFrom)

            let merged = try #require(try tree(db, m.block.id))
            #expect(merged.nodes == [
                Node(blockID: x.block.id, direction: .ancestor, depth: 1, via: mx,
                     state: .preserved(lastContainerID: n.id), home: home(n.id, "N"),
                     shownTakeID: x.variant.id, text: "Ex."),
                Node(blockID: y.block.id, direction: .ancestor, depth: 1, via: my,
                     state: .preserved(lastContainerID: n.id), home: home(n.id, "N"),
                     shownTakeID: y.variant.id, text: "Why."),
            ].sorted { $0.blockID < $1.blockID })
            #expect(merged.nodes.allSatisfy { $0.originOp == "merge" })
            let source = try #require(try tree(db, x.block.id))
            #expect(source.origin.state == .preserved(lastContainerID: n.id))
            #expect(source.descendants.map(\.blockID) == [m.block.id])

            let fanned = try ops.seedBlock(in: n.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            let first = try #require(try tree(db, w.first.block.id))
            #expect(first.nodes == [
                Node(blockID: fanned.block.id, direction: .ancestor, depth: 1,
                     via: try edge(db, w.first.block.id, fanned.block.id, .derivedFrom),
                     state: .preserved(lastContainerID: n.id), home: home(n.id, "N"),
                     shownTakeID: fanned.variant.id, text: "Alpha one. Beta one."),
            ])
            let original = try #require(try tree(db, fanned.block.id))
            #expect(Set(original.descendants.map(\.blockID)) == [w.first.block.id, w.second.block.id])
            #expect(original.descendants.allSatisfy { $0.depth == 1 && $0.state == .placed(containerID: n.id) })
        }
    }

    /// An EXTRACT moved to another WING and a POOL COPY: each node names its
    /// home — the note in its wing, the pool as a pool.
    @Test func anExtractAcrossWingsAndAPoolCopyNameTheirHomes() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let n = try ops.createPost(title: "N")
            let r = try ops.createPost(title: "R", wingId: studio.id)
            let e = try ops.seedBlock(in: n.id, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(e.block.id, span: 11..<26)
            try ops.moveBlock(extracted.block.id, to: r.id)
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.seedBlock(in: pool.id, text: "A scrap.")
            let copy = try ops.poolDragCopy(scrap.block.id, to: r.id)

            let source = try #require(try tree(db, e.block.id))
            #expect(source.nodes == [
                Node(blockID: extracted.block.id, direction: .descendant, depth: 1,
                     via: try edge(db, extracted.block.id, e.block.id, .derivedFrom),
                     state: .placed(containerID: r.id), home: home(r.id, "R", wing: studio.id),
                     shownTakeID: extracted.variant.id, text: try text(db, extracted.variant.id)),
            ])
            #expect(source.nodes.first?.originOp == "extract")
            let copied = try #require(try tree(db, copy.block.id))
            #expect(copied.nodes == [
                Node(blockID: scrap.block.id, direction: .ancestor, depth: 1,
                     via: try edge(db, copy.block.id, scrap.block.id, .derivedFrom),
                     state: .placed(containerID: pool.id), home: home(pool.id, "scraps", kind: .pool),
                     shownTakeID: scrap.variant.id, text: "A scrap."),
            ])
            #expect(copied.nodes.first?.originOp == "pool_copy")
        }
    }

    /// A DUPLICATE's block is both a DESCENDANT (its derived_from) and a
    /// VERSION SIBLING (the one anchor edge) of the source's first block; a
    /// SAVED VERSION's block is a descendant whose home says it is one.
    @Test func aDuplicateIsADescendantAndAVersionSiblingASavedVersionSaysSo() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let n1 = try ops.seedBlock(in: n.id, text: "One.")
            let dup = try ops.duplicateAsVersion(n.id)
            let d1 = try #require(dup.blockCopies.first { $0.source == n1.block.id }?.copy)
            let saved = try ops.saveNoteVersion(n.id)
            let v1 = try #require(saved.blockCopies.first { $0.source == n1.block.id }?.copy)

            let family = try #require(try tree(db, n1.block.id))
            let expectedDescendants = [
                Node(blockID: d1, direction: .descendant, depth: 1,
                     via: try edge(db, d1, n1.block.id, .derivedFrom), state: .placed(containerID: dup.post.id),
                     home: home(dup.post.id, "N"), shownTakeID: try defaultTake(db, d1), text: "One."),
                Node(blockID: v1, direction: .descendant, depth: 1,
                     via: try edge(db, v1, n1.block.id, .derivedFrom), state: .placed(containerID: saved.post.id),
                     home: home(saved.post.id, "N", version: true), shownTakeID: try defaultTake(db, v1), text: "One."),
            ].sorted { $0.blockID < $1.blockID }
            #expect(family.descendants == expectedDescendants)
            #expect(family.versions.map(\.blockID).sorted() == [d1, v1].sorted(),
                    "each copy's anchor edge makes it a version sibling too")
            let dupSibling = try #require(family.versions.first { $0.blockID == d1 })
            let anchorEdge = try versionEdge(db, n1.block.id, d1)
            #expect(dupSibling.via == anchorEdge && dupSibling.depth == 1)
            #expect(family.ancestors.isEmpty)
        }
    }

    /// THE TRASH IS IN THE TREE: a deleted middle block is a node (its edges
    /// died WITH it — the cascade's exact stamp — and revive with it), and the
    /// walk goes through it; an edge TAKEN APART on its own (a stamp no
    /// endpoint shares; the unmark door's version link) is not lineage. A
    /// deleted ORIGIN still answers; an id with no row answers nil.
    @Test func theTrashIsInTheTreeAndAnEdgeTakenApartIsNot() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let seeded = try ops.seedBlock(in: n.id, text: twoSentences)
            let a = seeded.block.id
            let c = try ops.divide(a, cut: 24)
            let d = try ops.divide(c.block.id, cut: 10)
            try ops.deleteBlock(c.block.id)
            let stamp = try #require(try db.deletedAt("block", c.block.id))
            let ca = try edge(db, c.block.id, a, .derivedFrom), dc = try edge(db, d.block.id, c.block.id, .derivedFrom)
            #expect(ca.deletedAt == stamp && dc.deletedAt == stamp, "the cascade's exact stamp")

            let down = try #require(try tree(db, a))
            #expect(down.nodes == [
                Node(blockID: c.block.id, direction: .descendant, depth: 1, via: ca,
                     state: .deleted(deletedAt: stamp, lastContainerID: n.id), home: home(n.id, "N"),
                     shownTakeID: c.variant.id, text: try text(db, c.variant.id)),
                Node(blockID: d.block.id, direction: .descendant, depth: 2, via: dc,
                     state: .placed(containerID: n.id), home: home(n.id, "N"),
                     shownTakeID: d.variant.id, text: try text(db, d.variant.id)),
            ])
            let dead = try #require(try tree(db, c.block.id), "a deleted block's tree answers")
            #expect(dead.origin.state == .deleted(deletedAt: stamp, lastContainerID: n.id))
            #expect(dead.ancestors.map(\.blockID) == [a] && dead.descendants.map(\.blockID) == [d.block.id])
            #expect(try tree(db, "no-such-block") == nil)

            // Put back: the edges revive and the tree reads them live.
            _ = try ops.restoreBlock(c.block.id)
            #expect(try tree(db, a)?.descendants.map(\.via?.deletedAt) == [nil, nil])

            // Taken apart on its own: a derived_from tombstoned on a stamp no
            // endpoint shares (sync debris) and an unmarked version link.
            let p = try ops.seedBlock(in: n.id, text: twoSentences).block.id
            let q = try ops.divide(p, cut: 24).block.id
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE edge SET deleted_at = '2026-07-01T05:00:00.000Z'
                        WHERE source_block_id = ? AND target_block_id = ? AND type = 'derived_from'
                        """,
                    arguments: [q, p])
            }
            #expect(try tree(db, p)?.nodes == [])
            let one = try ops.createPost(title: "one"), two = try ops.createPost(title: "two")
            let anchor = try ops.seedBlock(in: one.id, text: "Linked.").block.id
            _ = try ops.seedBlock(in: two.id, text: "Then not.")
            _ = try ops.markPostsAsVersions(one.id, two.id)
            #expect(try tree(db, anchor)?.versions.count == 1)
            try ops.unmarkPostsAsVersions(one.id, two.id)
            #expect(try tree(db, anchor)?.nodes == [])
        }
    }

    /// An ARCHIVED TAKE's block shows its default take (the read rule's
    /// fallback); an ARCHIVED BLOCK is set aside, never "preserved".
    @Test func anArchivedTakesBlockShowsItsDefaultAndAnArchivedBlockIsSetAside() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let a = try ops.seedBlock(in: n.id, text: twoSentences).block.id
            let c = try ops.divide(a, cut: 24)
            let take2 = try ops.branchVariant(c.block.id, from: c.variant.id)
            try ops.autosave(take2.id, text: "An archived take's words.", charDelta: 0)
            try ops.chooseVariant(c.block.id, variantID: take2.id)
            try ops.archiveVariant(take2.id)
            let other = try ops.seedBlock(in: n.id, text: twoSentences).block.id
            let half = try ops.divide(other, cut: 24).block.id
            try ops.archiveBlock(half)

            let fallback = try #require(try tree(db, a)?.descendants.first)
            #expect(fallback.blockID == c.block.id && fallback.state == .placed(containerID: n.id))
            let defaultText = try text(db, c.variant.id)
            #expect(fallback.shownTakeID == c.variant.id && fallback.text == defaultText,
                    "the archived chosen take falls back to the default")
            let setAside = try #require(try tree(db, other)?.descendants.first)
            #expect(setAside.blockID == half && setAside.state == .archived(lastContainerID: n.id))
        }
    }

    /// A CYCLE and a DANGLING id, on a hand-built graph (no operation makes
    /// these; the read must still terminate and answer exactly): a missing row
    /// is walked through and named `.missing`; a block on a cycle through the
    /// origin is its ancestor AND its descendant; the origin is never its own
    /// node.
    @Test func aCycleAndADanglingRowAnswerExactly() throws {
        try withOperations { ops, db in
            _ = ops
            let t = "2026-07-01T00:10:00.000Z"
            try db.writeWithoutTransaction { db in
                try db.execute(sql: "PRAGMA foreign_keys = OFF")
                for id in ["k-origin", "k-far", "k-loop"] {
                    try db.execute(
                        sql: "INSERT INTO block (id, created_at, updated_at) VALUES (?, ?, ?)", arguments: [id, t, t])
                }
                // (source derived_from target)
                for (n, source, target) in [
                    (1, "k-origin", "k-ghost"), (2, "k-ghost", "k-far"),     // origin ← ghost ← far
                    (3, "k-origin", "k-loop"), (4, "k-loop", "k-origin"),    // origin ⇄ loop
                ] {
                    try db.execute(
                        sql: """
                            INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                            VALUES (?, ?, ?, 'derived_from', 'divide', ?)
                            """,
                        arguments: ["k-edge-\(n)", source, target, t])
                }
                try db.execute(sql: "PRAGMA foreign_keys = ON")
            }
            let looped = try #require(try tree(db, "k-origin"))
            #expect(looped.nodes.map { "\($0.direction.rawValue) \($0.blockID) \($0.depth) \($0.via?.id ?? "-")" } == [
                "ancestor k-ghost 1 k-edge-1",
                "ancestor k-loop 1 k-edge-3",
                "ancestor k-far 2 k-edge-2",
                "descendant k-loop 1 k-edge-4",
            ])
            #expect(looped.nodes.first?.state == .missing && looped.nodes.first?.text == nil)
            #expect(looped.nodes.dropFirst().allSatisfy { $0.state == .preserved(lastContainerID: nil) && $0.home == nil })
            #expect(looped.edges.map(\.id) == ["k-edge-1", "k-edge-2", "k-edge-3", "k-edge-4"])
            #expect(try tree(db, "k-ghost") == nil, "an id with no row is no tree")
        }
    }

    // MARK: - P1

    /// One SEAM ROUND (⏎ mid-paragraph, ⌫ at the seam): both halves released.
    private func seamNote(_ ops: Operations, rounds: Int) throws -> [String] {
        let note = try ops.createPost(title: "the seam note")
        try ops.seedBlock(in: note.id, text: "A paragraph above.")
        var a = [try ops.seedBlock(in: note.id, text: twoSentences).block.id]
        try ops.seedBlock(in: note.id, text: "A paragraph below.")
        for _ in 0..<rounds {
            let divided = try ops.divide(a[a.count - 1], cut: 24)
            a.append(try ops.merge(a[a.count - 1], divided.block.id, joining: .deleteKeystroke).block.id)
        }
        return a
    }

    /// **RED ON NAIVE** — a seam history is the chain a note deepens by one per
    /// ⏎/⌫ round, and every path length reaches each old block: a walk that
    /// carries depth in its recursion revisits a node once per length, the
    /// VX-654 square. This read's work must grow with the history, never its
    /// square.
    @Test func theTreeGrowsWithTheSeamHistoryNeverItsSquare() throws {
        func work(rounds: Int) throws -> Int {
            try withOperations { ops, db in
                let a = try seamNote(ops, rounds: rounds)
                let family = try #require(try tree(db, a[rounds]))
                #expect(family.ancestors.count == 2 * rounds, "every round's first and second half")
                #expect(family.ancestors.map(\.depth).max() == rounds)
                return try instructions(db) { _ = try Queries.lineageTree($0, blockID: a[rounds]) }
            }
        }
        let short = try work(rounds: 20)
        let long = try work(rounds: 60)
        print("VX-827 lineageTree VM instructions: 20 rounds \(short), 60 rounds \(long)")
        #expect(Double(long) < Double(short) * 3.9,
                "seam rounds ×3: \(short) → \(long) VM instructions — linear is ≤ ×3, the square ×9")
    }

    /// P1's other half: the same block's tree, in a library fifteen times
    /// thicker, costs the same.
    @Test func theTreeDoesNotGrowWithTheLibrary() throws {
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
                let a = try seamNote(ops, rounds: 10)
                #expect(try tree(db, a[10])?.ancestors.count == 20)
                return try instructions(db) { _ = try Queries.lineageTree($0, blockID: a[10]) }
            }
        }
        let thin = try work(blocksEach: 2)
        let thick = try work(blocksEach: 30)
        print("VX-827 lineageTree VM instructions: library ×1 \(thin), ×15 \(thick)")
        #expect(Double(thick) < Double(thin) * 1.5,
                "library ×15: \(thin) → \(thick) VM instructions — the library must not drive the tree (P1)")
    }

    /// The plan: every store table SEARCHed by index, only the read's own sets
    /// scanned — from either end of the history, with a deleted block in it.
    @Test func theTreeNeverScansAStoreTable() throws {
        try withOperations { ops, db in
            let a = try seamNote(ops, rounds: 3)
            try ops.deleteBlock(a[3])
            for block in [a[0], a[3]] {
                let plan = try capturedPlan(db) { _ = try Queries.lineageTree($0, blockID: block) }
                let scans = lineageStoreTableScans(plan)
                #expect(scans.isEmpty, "store-table scans \(scans); plan was:\n\(plan)")
            }
        }
    }
}
