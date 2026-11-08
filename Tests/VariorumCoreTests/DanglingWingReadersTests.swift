//
//  DanglingWingReadersTests.swift
//  VariorumCoreTests
//
//  VX-892 (the VX-912 run, batch B2 — `notes/plans/fixes/vx-912-open-source-
//  gating.md`, "## B2 record") — THE TWO RAW READERS. Every listing reads a
//  wing pointer naming a DEAD wing row, or naming NO wing row at all, as Home
//  (R-13ia-2 · P-13id-U5-2 — `Queries.wingScope`). Two readers compared the
//  RAW stored ids instead:
//    1. the lineage fence (`Operations.lineageCrossesWing` over the tree's
//       homes — the op's `notInLineage` and the face's "in another library");
//    2. `Queries.liveTagIDs` (a tag whose wing id names no wing row at all was
//       probed by neither Home nor the every-wing form).
//  Both erred CLOSED. The states are sync-minted — no local operation leaves a
//  live note or tag pointing at a dead or absent wing (a wing deletes only
//  empty) — so every world here is HAND-BUILT on raw rows: a tombstoned wing
//  row (another device deleted the wing while this one filled it), and a wing
//  id no row carries (a row that landed ahead of its wing's row).
//
//  Red on old, per reader: each reader's pins fail on the pre-fix tree and
//  under the behavioral revert of THAT reader's change alone (the record).
//

import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

private let deadStamp = "2026-06-30T00:00:00.000Z"
/// A wing id no `wing` row carries (the absent-row state).
private let absentWing = "0ABSENT0-0000-4000-8000-0000000000AB"

private func tombstoneWing(_ db: AppDatabase, _ wingID: String) throws {
    try db.write { try $0.execute(
        sql: "UPDATE wing SET deleted_at = ? WHERE id = ?", arguments: [deadStamp, wingID]) }
}

private func pointContainer(_ db: AppDatabase, _ containerID: String, atWing wingID: String) throws {
    try db.write { try $0.execute(
        sql: "UPDATE container SET wing_id = ? WHERE id = ?", arguments: [wingID, containerID]) }
}

private func place(
    _ db: AppDatabase, of blockID: String, seenFrom faceBlockID: String
) throws -> LineageFamily.Place? {
    let tree = try #require(try db.read { try Queries.lineageTree($0, blockID: faceBlockID) })
    return LineageFamily.members(tree, counts: [:]).first { $0.blockID == blockID }?.place
}

private func isPlacedElsewhere(_ place: LineageFamily.Place?) -> Bool {
    if case .placed(_, sameNote: false)? = place { return true }
    return false
}

// MARK: - Reader 1: the lineage fence

@Suite("VX-892 — the lineage fence reads a dangling wing as Home")
struct DanglingWingLineageFenceTests {
    /// A note in Home and a relative's note in Studio; the relative is an
    /// extracted block moved across (the fence's own fixture shape).
    private struct World {
        let studio: String
        let home: String
        let away: String
        let source: (block: String, take: String)
        let relative: (block: String, take: String)
    }

    private func world(_ ops: Operations) throws -> World {
        let studio = try ops.createWing(name: "Studio")
        let home = try ops.createPost(title: "N")
        let away = try ops.createPost(title: "R", wingId: studio.id)
        let e = try ops.seedBlock(in: home.id, text: "Kept part. Extracted part. Far part.")
        let extracted = try ops.extract(e.block.id, span: 11..<36)
        try ops.moveBlock(extracted.block.id, to: away.id)
        return World(
            studio: studio.id, home: home.id, away: away.id,
            source: (e.block.id, e.variant.id), relative: (extracted.block.id, extracted.variant.id))
    }

    /// The premise (green both sides): while Studio lives, the fence holds
    /// both ways and the face names the wing.
    @Test func whileTheWingLivesTheFenceHolds() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            #expect(throws: OperationError.notInLineage(sourceBlockID: w.relative.block, targetBlockID: w.source.block)) {
                try ops.bringBackFromLineage(.take(w.relative.take), onto: w.source.block)
            }
            #expect(try place(db, of: w.relative.block, seenFrom: w.source.block) == .otherWing(wingID: w.studio))
            #expect(try place(db, of: w.source.block, seenFrom: w.relative.block) == .otherWing(wingID: ""))
        }
    }

    /// A DEAD wing row (another device deleted Studio while this one still
    /// held a note in it): the relative's note lists under Home, so the fence
    /// lets it through BOTH ways and the face draws it as an ordinary member
    /// of another note — never "in another library". RED ON OLD: `notInLineage`
    /// and `.otherWing(wingID: <the dead id>)`.
    @Test func aDeadWingsNoteIsHomesOnBothSidesOfTheFence() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try tombstoneWing(db, w.studio)
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: w.away) } == "", "the premise: it lists under Home")

            let back = try ops.bringBackFromLineage(.take(w.relative.take), onto: w.source.block)
            #expect(back.blockId == w.source.block && back.workingText == "Extracted part. Far part.")
            let there = try ops.bringBackFromLineage(.take(w.source.take), onto: w.relative.block)
            #expect(there.blockId == w.relative.block)

            #expect(isPlacedElsewhere(try place(db, of: w.relative.block, seenFrom: w.source.block)),
                    "an ordinary member of another note")
            #expect(isPlacedElsewhere(try place(db, of: w.source.block, seenFrom: w.relative.block)))
        }
    }

    /// A wing id NO row carries (the note's row landed ahead of its wing's):
    /// the same — Home's, both ways. RED ON OLD.
    @Test func anAbsentWingsNoteIsHomesOnBothSidesOfTheFence() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try pointContainer(db, w.away, atWing: absentWing)
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: w.away) } == "", "the premise: it lists under Home")

            let back = try ops.bringBackFromLineage(.take(w.relative.take), onto: w.source.block)
            #expect(back.blockId == w.source.block)
            let there = try ops.bringBackFromLineage(.take(w.source.take), onto: w.relative.block)
            #expect(there.blockId == w.relative.block)
            #expect(isPlacedElsewhere(try place(db, of: w.relative.block, seenFrom: w.source.block)))
            #expect(isPlacedElsewhere(try place(db, of: w.source.block, seenFrom: w.relative.block)))
        }
    }

    /// The fence still holds against a LIVE wing from a dangling note — and
    /// the dangling note, seen from that live wing, is named as HOME's (the
    /// wing id it lists under), never by the dead or absent id. RED ON OLD:
    /// the dangling side was named by its raw id.
    @Test func aDanglingNoteFacingALiveWingIsFencedAndNamedAsHomes() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let attic = try ops.createWing(name: "Attic")
            let far = try ops.createPost(title: "F", wingId: attic.id)
            let more = try ops.extract(w.relative.block, span: 16..<25)   // "Far part." — the relative's own descendant
            try ops.moveBlock(more.block.id, to: far.id)
            try tombstoneWing(db, w.studio)

            #expect(throws: OperationError.notInLineage(sourceBlockID: more.block.id, targetBlockID: w.relative.block)) {
                try ops.bringBackFromLineage(.take(more.variant.id), onto: w.relative.block)
            }
            #expect(try place(db, of: more.block.id, seenFrom: w.relative.block) == .otherWing(wingID: attic.id))
            #expect(try place(db, of: w.relative.block, seenFrom: more.block.id) == .otherWing(wingID: ""),
                    "named as Home's — the wing it lists under")
        }
    }
}

// MARK: - Reader 2: liveTagIDs

@Suite("VX-892 — the live tags at a path read a dangling wing as Home")
struct DanglingWingTagPathTests {
    private struct World {
        let homeIdea: String
        let studio: String
        let studioIdea: String
        let stray: String          // a tag whose wing id names NO wing row
        let atHome: String
        let inStudio: String
        let strayNote: String      // a note wearing the stray tag, in the same absent wing
    }

    private func world(_ ops: Operations, _ db: AppDatabase) throws -> World {
        let homeIdea = try ops.createTag(name: "idea")
        let atHome = try ops.createPost(title: "at home")
        _ = try ops.applyTag(homeIdea.id, toPost: atHome.id)
        let studio = try ops.createWing(name: "Studio")
        let studioIdea = try ops.createTag(name: "idea", wingID: studio.id)
        let inStudio = try ops.createPost(title: "in the studio", wingId: studio.id)
        _ = try ops.applyTag(studioIdea.id, toPost: inStudio.id)
        // The stray: minted in a scratch wing, then both rows re-pointed at a
        // wing id no row carries (the scratch row itself deleted — physically,
        // the absent-row state a straggling wing leaves).
        let scratch = try ops.createWing(name: "scratch")
        let stray = try ops.createTag(name: "idea", wingID: scratch.id)
        let strayNote = try ops.createPost(title: "stray", wingId: scratch.id)
        _ = try ops.applyTag(stray.id, toPost: strayNote.id)
        try db.write { db in
            try db.execute(sql: "UPDATE tag SET wing_id = ? WHERE id = ?", arguments: [absentWing, stray.id])
            try db.execute(sql: "UPDATE container SET wing_id = ? WHERE id = ?", arguments: [absentWing, strayNote.id])
            try db.execute(sql: "DELETE FROM wing WHERE id = ?", arguments: [scratch.id])
        }
        #expect(try db.fetchInt("SELECT COUNT(*) FROM wing WHERE id = ?", [absentWing]) == 0, "the premise: no row")
        return World(
            homeIdea: homeIdea.id, studio: studio.id, studioIdea: studioIdea.id, stray: stray.id,
            atHome: atHome.id, inStudio: inStudio.id, strayNote: strayNote.id)
    }

    /// Home holds the tag whose wing names no row (as Home lists its note),
    /// and the every-wing form holds it too. RED ON OLD: both missed it.
    @Test func anAbsentWingsTagIsHomesAndEveryWingsToo() throws {
        try withOperations { ops, db in
            let w = try world(ops, db)
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: "") }
                    == [w.homeIdea, w.stray].sorted())
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: nil) }
                    == [w.homeIdea, w.studioIdea, w.stray].sorted())
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: w.studio) } == [w.studioIdea],
                    "a live wing: its own tag alone (control)")
            // The wearer listing downstream (the wire's `list_notes` tag).
            #expect(try db.read { try Queries.notesWearingTag($0, path: "idea", wingID: "") }
                    == [w.atHome, w.strayNote].sorted())
            #expect(try db.read { try Queries.notesWearingTag($0, path: "idea", wingID: nil) }
                    == [w.atHome, w.inStudio, w.strayNote].sorted())
            #expect(try db.read { try Queries.notesWearingTag($0, path: "idea", wingID: w.studio) } == [w.inStudio])
        }
    }

    /// A DEAD wing's tags read as Home's (the old probe already walked dead
    /// `wing` rows — red on old only for the absent-row stray beside them),
    /// and asking for a wing that is not live asks for the wing it reads as:
    /// Home. RED ON OLD for the two asked-for arms (the raw id was probed
    /// alone).
    @Test func aDeadWingIsHomesWhetherItHoldsTheTagOrIsAskedFor() throws {
        try withOperations { ops, db in
            let w = try world(ops, db)
            try tombstoneWing(db, w.studio)
            let home = [w.homeIdea, w.studioIdea, w.stray].sorted()
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: "") } == home)
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: w.studio) } == home,
                    "a dead wing asked for is Home asked for")
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: absentWing) } == home,
                    "an absent wing asked for is Home asked for")
        }
    }
}
