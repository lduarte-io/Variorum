import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **THE NOTE-SCOPED DELETED TAKES** (the post-13l polish round, ledger row
/// 20 — her G5 ruling: *"the tray of a note should have an honest trash
/// section with everything being deleted, so it's never a surprise — and
/// takes can be shown in that per note trash, albeit maybe not shown by
/// default, so you can always see a list of what will be deleted"*).
///
/// Takes left the GLOBAL Trash at her D1 ruling — *"a take alone is so
/// small"* — so this listing is what keeps the capability findable and the
/// audit complete. Every fence below is a rule about what a Put back can
/// honour, not a taste call.
@Suite("The note's deleted takes (the post-13l polish round, G5)")
struct NoteTrayTakesTests {
    /// The everyday case, end to end: a take deleted on its own from a live
    /// block in this note lists, wearing its own tombstone and naming the
    /// block it came out of.
    @Test func aTakeDeletedOnItsOwnListsUnderItsNoteAndNamesItsBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "three ways")
            let minted = try ops.newBlock(in: post.id, text: "The sea took the boat.")
            let chosen = try #require(minted.variant.id as String?)
            let second = try ops.branchVariant(minted.block.id, from: chosen)
            try ops.autosave(second.id, text: "The sea took everything.", charDelta: 0)
            try ops.deleteVariant(second.id)

            let takes = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(takes.map(\.variantID) == [second.id])
            let row = try #require(takes.first)
            #expect(row.blockID == minted.block.id)
            #expect(row.text == "The sea took everything.")
            // The block's identity rides the row, so the face can run it
            // through the ONE block-naming rule rather than inventing a
            // second one (`tocHandle`: the name, else the first sentence).
            #expect(Queries.tocHandle(name: row.blockName, text: row.blockText)
                == "The sea took the boat.")
        }
    }

    /// **A take that died WITH its block is NOT here** — and this is the
    /// arm the whole listing's honesty rides on. Such a take carries the
    /// BLOCK's stamp and comes back with `restoreBlock`, so it is already
    /// represented one section up by the block's own row; listing it would
    /// offer a Put back that refuses. (The global Trash's cascade-victim
    /// rule, applied per note.)
    @Test func aTakeThatDiedWithItsBlockIsRepresentedByTheBlockNotByItself() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "cascade")
            let minted = try ops.newBlock(in: post.id, text: "First.")
            let chosen = try #require(minted.variant.id as String?)
            let second = try ops.branchVariant(minted.block.id, from: chosen)
            try ops.deleteBlock(minted.block.id)

            let takes = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(takes.isEmpty, "the block's own tray row stands for its whole family")
            // …and the take really IS tombstoned — nothing is hidden, only
            // represented at the grain that has a door.
            let dead = try db.read { db in
                try Bool.fetchOne(
                    db, sql: "SELECT deleted_at IS NOT NULL FROM variant WHERE id = ?",
                    arguments: [second.id])
            }
            #expect(dead == true)
        }
    }

    /// One note's audit never reaches another note's takes.
    @Test func theListingIsScopedToItsOwnNote() throws {
        try withOperations { ops, db in
            let mine = try ops.createPost(title: "mine")
            let theirs = try ops.createPost(title: "theirs")
            let here = try ops.newBlock(in: mine.id, text: "Here.")
            let there = try ops.newBlock(in: theirs.id, text: "There.")
            let hereSecond = try ops.branchVariant(
                here.block.id, from: try #require(here.variant.id as String?))
            let thereSecond = try ops.branchVariant(
                there.block.id, from: try #require(there.variant.id as String?))
            try ops.deleteVariant(hereSecond.id)
            try ops.deleteVariant(thereSecond.id)

            let takes = try db.read {
                try Queries.trayTakes($0, postID: mine.id, now: harnessNow)
            }
            #expect(takes.map(\.variantID) == [hereSecond.id])
        }
    }

    /// The 30-day clock is the same read-side clock every other recovery
    /// surface reads: past the window the row has left every surface, and a
    /// listing that kept offering Put back would make the clock a lie.
    @Test func aTakePastTheWindowHasLeftThisSurfaceToo() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "expiring")
            let minted = try ops.newBlock(in: post.id, text: "Body.")
            let second = try ops.branchVariant(
                minted.block.id, from: try #require(minted.variant.id as String?))
            try ops.deleteVariant(second.id)

            let inside = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(inside.count == 1)
            let after = try db.read {
                try Queries.trayTakes(
                    $0, postID: post.id,
                    now: harnessNow.addingTimeInterval(Double(TrashWindow.days + 1) * 86_400))
            }
            #expect(after.isEmpty)
        }
    }

    /// A purge intent takes the row off every surface at once — the standing
    /// read-side fence, which this listing inherits rather than re-deciding.
    @Test func aPurgedTakeLeavesTheAuditImmediately() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "purged")
            let minted = try ops.newBlock(in: post.id, text: "Body.")
            let second = try ops.branchVariant(
                minted.block.id, from: try #require(minted.variant.id as String?))
            try ops.deleteVariant(second.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "variant", rowID: second.id)])

            let takes = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(takes.isEmpty)
        }
    }

    /// An ARCHIVED take that is then deleted still lists — the audit is
    /// about the clock, not about the status, and `restoreVariant`'s exact
    /// flip is what puts it back where it was.
    @Test func anArchivedTakeThatWasDeletedIsOnTheClockLikeAnyOther() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "archived then deleted")
            let minted = try ops.newBlock(in: post.id, text: "Body.")
            let second = try ops.branchVariant(
                minted.block.id, from: try #require(minted.variant.id as String?))
            try ops.autosave(second.id, text: "Another way of saying it.", charDelta: 0)
            try ops.archiveVariant(second.id)
            try ops.deleteVariant(second.id)

            let takes = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(takes.map(\.variantID) == [second.id])
        }
    }

    /// A RELEASED original (live, unplaced) audits in the note it was
    /// released from — the same note whose tray already holds its row, so
    /// the two never disagree about where it belongs.
    @Test func aReleasedOriginalsDeletedTakesAuditWhereItsRowIs() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "divided")
            let minted = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
            let chosen = try #require(minted.variant.id as String?)
            let second = try ops.branchVariant(minted.block.id, from: chosen)
            try ops.autosave(second.id, text: "Alpha two. Beta two.", charDelta: 0)
            let third = try ops.branchVariant(minted.block.id, from: chosen)
            // A W divide preserves A whole and releases it to lineage.
            _ = try ops.divideW(minted.block.id, cuts: [chosen: 10, second.id: 10])
            try ops.deleteVariant(third.id)

            let takes = try db.read {
                try Queries.trayTakes($0, postID: post.id, now: harnessNow)
            }
            #expect(takes.map(\.variantID) == [third.id])
            #expect(takes.first?.blockID == minted.block.id)
        }
    }
}
