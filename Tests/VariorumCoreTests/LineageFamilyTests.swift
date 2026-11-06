//
//  LineageFamilyTests.swift
//  VariorumCoreTests
//
//  VX-801 (VX-827 U3b — `notes/plans/fixes/vx-827-lineage.md`, THE DESIGN
//  MEMO's Lineage face) — `LineageFamily.members` and `.opening` over real
//  trees (`Queries.lineageTree`, U1's read) and `Queries.lineageFamilyCounts`:
//  older above in generation bands, each member's place, the acts its header
//  carries by state (Put back only where placeable, a Trash member muted with
//  none, another wing named and go-to only, no words across), a block met twice
//  shown once, and where the face opens.
//
//  A PRODUCT row: the projection did not exist, so the suite does not compile
//  on the pre-U3b tree.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func family(_ db: AppDatabase, _ block: String) throws -> [LineageFamily.Member] {
    try db.read { db in
        let tree = try #require(try Queries.lineageTree(db, blockID: block))
        let ids = [tree.origin.blockID] + tree.nodes.map(\.blockID)
        return LineageFamily.members(tree, counts: try Queries.lineageFamilyCounts(db, blockIDs: ids))
    }
}

@Suite("VX-801 — the Lineage face's family (U3b)")
struct LineageFamilyTests {
    /// A DIVIDE CHAIN read from its last block: the grandparent on top, the
    /// parent, this block — older above, one generation per band — and from
    /// the middle, the descendant below it.
    @Test func olderIsAboveInGenerationBands() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let a = try ops.seedBlock(in: n.id, text: "Paragraph seam has words. And a second sentence follows here.")
            let c = try ops.divide(a.block.id, cut: 26)
            let d = try ops.divide(c.block.id, cut: 4)

            let fromEnd = try family(db, d.block.id)
            #expect(fromEnd.map(\.blockID) == [a.block.id, c.block.id, d.block.id])
            #expect(fromEnd.map(\.generation) == [-2, -1, 0])
            #expect(fromEnd.map(\.originOp) == ["divide", "divide", nil])
            #expect(fromEnd.last?.place == .thisBlock && fromEnd.last?.acts == [])

            let fromMiddle = try family(db, c.block.id)
            #expect(fromMiddle.map(\.blockID) == [a.block.id, c.block.id, d.block.id])
            #expect(fromMiddle.map(\.generation) == [-1, 0, 1])
            #expect(fromMiddle.map(\.direction) == [.ancestor, .origin, .descendant])
            // All three live in this note: placed, the same note, readable.
            for member in fromMiddle where member.direction != .origin {
                guard case .placed(let home, let sameNote) = member.place else {
                    Issue.record("\(member.blockID) should be placed"); continue
                }
                #expect(home.containerID == n.id && sameNote)
                #expect(member.acts == [.bringBackAsTake, .compareWithNow], "placed: no Put back")
                #expect(member.selectable)
            }
        }
    }

    /// A MERGE's two sources are kept as lineage: Put back (their note still
    /// stands), Bring back as take, Compare with now; counted; and the face
    /// opens on the first of them (the block it came out of).
    @Test func aMergesSourcesAreKeptPlaceableAndCounted() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let x = try ops.seedBlock(in: n.id, text: "Ex.")
            let y = try ops.seedBlock(in: n.id, text: "Why.")
            _ = try ops.commit(x.variant.id, message: "first")
            _ = try ops.branchVariant(x.block.id, from: x.variant.id)
            let m = try ops.merge(x.block.id, y.block.id)

            let members = try family(db, m.block.id)
            #expect(Set(members.prefix(2).map(\.blockID)) == [x.block.id, y.block.id])
            for source in members.prefix(2) {
                #expect(source.place == .keptAsLineage(home: Queries.LineageHome(
                    containerID: n.id, kind: .post, title: "N", wingID: "", isDeleted: false,
                    isSavedVersion: false)))
                #expect(source.acts == [.putBack, .bringBackAsTake, .compareWithNow])
                #expect(source.originOp == "merge" && source.generation == -1)
            }
            let xMember = try #require(members.first { $0.blockID == x.block.id })
            #expect(xMember.counts == LineageFamily.Counts(takes: 2, commits: 1))
            #expect(members.last?.counts == LineageFamily.Counts(takes: 1, commits: 0), "this block's own")
            #expect(LineageFamily.opening(members, prefer: nil) == members.first?.blockID,
                    "the nearest ancestor, first drawn")
            #expect(LineageFamily.opening(members, prefer: y.block.id) == y.block.id,
                    "the origin door's original")
            #expect(LineageFamily.opening(members, prefer: "no-such-block") == members.first?.blockID)
        }
    }

    /// A Trash member is muted with no acts and cannot be selected; an
    /// ARCHIVED (set-aside) block is placeable by its own road.
    @Test func aTrashMemberIsMutedAndASetAsideBlockIsPlaceable() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let a = try ops.seedBlock(in: n.id, text: "Paragraph seam has words. And a second sentence follows here.")
            let c = try ops.divide(a.block.id, cut: 26)
            let d = try ops.divide(c.block.id, cut: 4)
            try ops.deleteBlock(c.block.id)
            try ops.archiveBlock(d.block.id)

            let members = try family(db, a.block.id)
            let trashed = try #require(members.first { $0.blockID == c.block.id })
            #expect(trashed.isMuted && trashed.acts.isEmpty && !trashed.selectable)
            #expect(trashed.counts == nil)
            let aside = try #require(members.first { $0.blockID == d.block.id })
            guard case .setAside = aside.place else {
                Issue.record("an archived block is set aside, got \(aside.place)"); return
            }
            #expect(aside.acts == [.putBack, .bringBackAsTake, .compareWithNow] && aside.selectable)
            #expect(LineageFamily.opening(members, prefer: c.block.id) == a.block.id,
                    "a Trash member is never opened on; no ancestor ⇒ this block")
        }
    }

    /// ANOTHER WING: named with its wing, go-to only, no words and no counts;
    /// the SCRAPS are the one shared room, so a pool ancestor is an ordinary
    /// readable member wherever the face stands.
    @Test func anotherWingIsNamedOnlyAndTheScrapsAreShared() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let home = try ops.createPost(title: "N")
            let away = try ops.createPost(title: "R", wingId: studio.id)
            let e = try ops.seedBlock(in: home.id, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(e.block.id, span: 11..<26)
            try ops.moveBlock(extracted.block.id, to: away.id)

            let members = try family(db, e.block.id)
            let across = try #require(members.first { $0.blockID == extracted.block.id })
            #expect(across.place == .otherWing(wingID: studio.id))
            #expect(across.acts == [.goToWing(studio.id)] && !across.selectable)
            #expect(across.text == nil && across.counts == nil, "no words cross a wing")

            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.seedBlock(in: pool.id, text: "A scrap.")
            let copy = try ops.poolDragCopy(scrap.block.id, to: away.id)
            let fromCopy = try family(db, copy.block.id)
            let scrapMember = try #require(fromCopy.first { $0.blockID == scrap.block.id })
            guard case .placed(let scrapHome, false) = scrapMember.place else {
                Issue.record("the scrap is placed in the scraps, got \(scrapMember.place)"); return
            }
            #expect(scrapHome.kind == .pool)
            #expect(scrapMember.text == "A scrap." && scrapMember.acts == [.bringBackAsTake, .compareWithNow])
            #expect(scrapMember.originOp == "pool_copy")
        }
    }

    /// A DUPLICATE's copy is both a descendant and a version sibling — it is
    /// drawn ONCE, as the descendant; another note of the same wing is
    /// `placed`, not the same note.
    @Test func aBlockMetTwiceIsDrawnOnce() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let one = try ops.seedBlock(in: n.id, text: "One.")
            let dup = try ops.duplicateAsVersion(n.id)
            let copied = try #require(dup.blockCopies.first { $0.source == one.block.id }?.copy)

            let members = try family(db, one.block.id)
            #expect(members.filter { $0.blockID == copied }.count == 1)
            let copy = try #require(members.first { $0.blockID == copied })
            #expect(copy.direction == .descendant && copy.generation == 1)
            guard case .placed(let home, let sameNote) = copy.place else {
                Issue.record("placed in the duplicate, got \(copy.place)"); return
            }
            #expect(home.containerID == dup.post.id && !sameNote)
        }
    }

    /// The counts read: active takes and the commits of live takes, by id; a
    /// block with no row counts zero; nothing asked, nothing read.
    @Test func theCountsAreExact() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let a = try ops.seedBlock(in: n.id, text: "Words.")
            _ = try ops.commit(a.variant.id)
            let spare = try ops.branchVariant(a.block.id, from: a.variant.id)
            _ = try ops.commit(spare.id, message: "spare")
            try ops.archiveVariant(spare.id)
            let gone = try ops.newBlankVariant(a.block.id)
            try ops.deleteVariant(gone.id)
            let counts = try db.read { try Queries.lineageFamilyCounts($0, blockIDs: [a.block.id, "none"]) }
            #expect(counts[a.block.id] == LineageFamily.Counts(takes: 1, commits: 2),
                    "one active take; the archived take's commit counts, the deleted take is gone")
            #expect(counts["none"] == LineageFamily.Counts(takes: 0, commits: 0))
            #expect(try db.read { try Queries.lineageFamilyCounts($0, blockIDs: []) }.isEmpty)
        }
    }

    /// P1: the counts read seeks its rows by index — the statement the read
    /// really runs, captured and explained: no store table scanned.
    @Test func theCountsReadNeverScansAStoreTable() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let a = try ops.seedBlock(in: n.id, text: "Words.")
            let statements: [String] = try db.read { database in
                let captured = LockIsolated<[String]>([])
                database.trace(options: .statement) { event in
                    guard case .statement(let statement) = event else { return }
                    let sql = statement.expandedSQL
                    captured.withValue { $0.append(sql) }
                }
                _ = try Queries.lineageFamilyCounts(database, blockIDs: [a.block.id])
                database.trace(options: .statement, nil)
                return captured.value.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("SELECT") }
            }
            #expect(statements.count == 1, "one statement")
            let plan = try db.read { database in
                try statements.flatMap { sql in
                    try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)").map { ($0["detail"] as String?) ?? "" }
                }
            }
            let scans = plan.filter { $0.hasPrefix("SCAN ") && !$0.contains("VIRTUAL TABLE") }  // json_each is the read's own set
            #expect(scans.isEmpty, "store-table scans \(scans); plan:\n\(plan.joined(separator: "\n"))")
        }
    }
}
