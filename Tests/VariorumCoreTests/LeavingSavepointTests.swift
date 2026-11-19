import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VM-71 (the VM-64 run, batch 7) — a leaving's savepoint, asked as a read
/// first.** The record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4
/// batch 7; §7 its closeout).
///
/// The phone asks for a leaving savepoint on every road out of a note — and a
/// Castle backgrounding asks up to three times for one leaving (audit F 6C).
/// Each ask was `closeAutoCommit`, a write transaction on the ONE serial runner
/// that decodes every take of the note to find the dirty ones. The phone now
/// asks the store first, on a reader (`Queries.leavingSavepointCandidates`),
/// and hands the runner only the takes owed (`closeAutoCommit(_:takes:)`).
///
/// What these pins hold, the Core half:
/// · the read lists EXACTLY what a leaving savepoint would write, across every
///   kind of take the op's rule names — and nothing for a gone, sealed or
///   cadence-off note;
/// · the narrowed op writes the SAME rows as the whole one when handed the
///   read's list (two identical worlds, row for row);
/// · the narrowed op re-checks each listed take inside its own transaction —
///   a take that has since become clean, moved, been locked or tombstoned is
///   skipped, never committed;
/// · byte-different but canonically-equal text is listed by the read and
///   committed by neither op (the read is a superset, never a subset);
/// · the narrowed op's statements scale with the takes listed, the whole op's
///   with the note.
@Suite("VM-71 — a leaving's savepoint, read first, written for exactly the takes owed")
struct LeavingSavepointTests {

    /// A note holding one take of every kind `closeAutoCommit`'s rule names.
    private struct Matrix {
        let postID: String
        /// The takes a leaving savepoint must write.
        let owed: Set<String>
        /// The takes it must not.
        let notOwed: Set<String>
    }

    private func seedMatrix(_ ops: Operations, _ db: AppDatabase) throws -> Matrix {
        let post = try ops.createPost(title: "matrix", profile: .blog)
        // Savepointed and untouched since → not owed.
        let settled = try ops.seedBlock(in: post.id, text: "settled")
        // Savepointed, then edited → owed.
        let edited = try ops.seedBlock(in: post.id, text: "before")
        // Savepointed, then emptied → owed (the empty text differs).
        let emptied = try ops.seedBlock(in: post.id, text: "will be cleared")
        // Savepointed, locked, then changed underneath (as a sync apply can) →
        // not owed: a locked take is skipped (its lock insured its buffer).
        let locked = try ops.seedBlock(in: post.id, text: "frozen words")
        // A block carrying a second take (a fan) → the new take is owed.
        let fanned = try ops.seedBlock(in: post.id, text: "first take")
        // An ARCHIVED take under the placement, never savepointed → owed (the
        // op's rule names live, unlocked takes; archive is not a tombstone).
        let archivedHost = try ops.seedBlock(in: post.id, text: "host")
        // A deleted take → not owed.
        let deletedHost = try ops.seedBlock(in: post.id, text: "host two")
        // A block deleted from the note (its placement gone) → not owed.
        let gone = try ops.seedBlock(in: post.id, text: "deleted block")

        _ = try ops.closeAutoCommit(post.id)  // everything above savepointed once

        // Never savepointed, holding text → owed.
        let fresh = try ops.seedBlock(in: post.id, text: "fresh words")
        // Never savepointed, empty → not owed (nothing to keep).
        let empty = try ops.seedBlock(in: post.id, text: "")
        try ops.autosave(edited.variant.id, text: "before, and after", charDelta: 11)
        try ops.autosave(emptied.variant.id, text: "", charDelta: 15)
        try ops.lockVariant(locked.variant.id)
        try db.write { db in
            try db.execute(
                sql: "UPDATE variant SET working_text = ? WHERE id = ?",
                arguments: ["frozen words, changed elsewhere", locked.variant.id])
        }
        let fanTake = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
        let archivedTake = try ops.branchVariant(archivedHost.block.id, from: archivedHost.variant.id)
        try ops.archiveVariant(archivedTake.id)
        let deletedTake = try ops.branchVariant(deletedHost.block.id, from: deletedHost.variant.id)
        try ops.deleteVariant(deletedTake.id)
        try ops.autosave(gone.variant.id, text: "deleted block, edited", charDelta: 8)
        try ops.deleteBlock(gone.block.id)

        return Matrix(
            postID: post.id,
            owed: [fresh.variant.id, edited.variant.id, emptied.variant.id, fanTake.id, archivedTake.id],
            notOwed: [settled.variant.id, empty.variant.id, locked.variant.id, fanned.variant.id,
                      archivedHost.variant.id, deletedHost.variant.id, deletedTake.id, gone.variant.id])
    }

    // MARK: The read lists exactly what the op writes

    @Test func theReadListsExactlyTheTakesALeavingSavepointWrites() throws {
        try withOperations { ops, db in
            let matrix = try seedMatrix(ops, db)
            let listed = try db.read { db in
                try Queries.leavingSavepointCandidates(db, containerID: matrix.postID)
            }
            #expect(Set(listed) == matrix.owed, "listed \(listed)")
            #expect(listed == listed.sorted(), "in id order, as the op commits")
            #expect(Set(listed).isDisjoint(with: matrix.notOwed))

            let written = try ops.closeAutoCommit(matrix.postID)
            #expect(Set(written.map(\.variantId)) == Set(listed),
                    "the whole op wrote exactly the takes the read listed")

            // The dedupe, as a read: after the leaving, nothing is owed.
            #expect(try db.read { try Queries.leavingSavepointCandidates($0, containerID: matrix.postID) }.isEmpty)
        }
    }

    @Test func aGoneSealedOrCadenceOffNoteOwesNothing() throws {
        try withOperations { ops, db in
            let sealed = try ops.createPost(title: "finished", profile: .blog)
            _ = try ops.seedBlock(in: sealed.id, text: "done")
            try ops.lockPost(sealed.id)
            let gone = try ops.createPost(title: "gone", profile: .blog)
            _ = try ops.seedBlock(in: gone.id, text: "typed")
            try ops.deleteContainer(gone.id)
            let open = try ops.createPost(title: "open", profile: .blog)
            _ = try ops.seedBlock(in: open.id, text: "typed")

            func listed(_ id: String) throws -> [String] {
                try db.read { try Queries.leavingSavepointCandidates($0, containerID: id) }
            }
            #expect(try listed(sealed.id).isEmpty, "a sealed note: the seal already insured it")
            #expect(try listed(gone.id).isEmpty, "a gone note")
            #expect(try listed("no-such-container").isEmpty)
            #expect(try listed(open.id).count == 1)

            // The take stays dirty throughout (nothing is committed here): only
            // the cadence decides whether a leaving owes it a savepoint.
            for mode in SavepointCadence.allCases {
                try ops.setSavepointCadence(mode)
                #expect(try listed(open.id).isEmpty != mode.savesOnLeaving,
                        "the cadence gate, \(mode.rawValue)")
            }
        }
    }

    // MARK: The narrowed op writes the whole op's rows

    /// Two worlds built by the same script (incrementing ids, the same ticking
    /// clock): one leaves through `closeAutoCommit(_:)`, the other through the
    /// read and `closeAutoCommit(_:takes:)`. Every savepoint row is the same
    /// row — id, take, text, kind, name, stamp.
    @Test func theNarrowedLeavingWritesTheSameRowsAsTheWholeOne() throws {
        func rows(narrowed: Bool) throws -> [[String: DatabaseValue]] {
            try withOperations { ops, db in
                let matrix = try seedMatrix(ops, db)
                if narrowed {
                    let listed = try db.read {
                        try Queries.leavingSavepointCandidates($0, containerID: matrix.postID)
                    }
                    _ = try ops.closeAutoCommit(matrix.postID, takes: listed)
                } else {
                    _ = try ops.closeAutoCommit(matrix.postID)
                }
                return try db.read { db in
                    try Row.fetchAll(db, sql: "SELECT * FROM commit_point ORDER BY id").map { row in
                        Dictionary(uniqueKeysWithValues: row.map { ($0.0, $0.1) })
                    }
                }
            }
        }
        let whole = try rows(narrowed: false)
        let narrowed = try rows(narrowed: true)
        #expect(whole.count > 0)
        #expect(whole == narrowed, "the narrowed leaving wrote a different history")
    }

    // MARK: Each listed take is re-checked inside the transaction

    @Test func aListedTakeIsReCheckedAndSkippedWhenItIsNoLongerOwed() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let other = try ops.createPost(title: "elsewhere", profile: .blog)
            let cleanSince = try ops.seedBlock(in: post.id, text: "a")
            let lockedSince = try ops.seedBlock(in: post.id, text: "b")
            let deletedSince = try ops.seedBlock(in: post.id, text: "c")
            let movedSince = try ops.seedBlock(in: post.id, text: "d")
            let stillOwed = try ops.seedBlock(in: post.id, text: "e")
            let foreign = try ops.seedBlock(in: other.id, text: "not this note's")

            let listed = try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }
            #expect(Set(listed) == Set([cleanSince, lockedSince, deletedSince, movedSince, stillOwed].map(\.variant.id)))

            // Between the read and the write, the world moves:
            _ = try ops.closeAutoCommit(post.id, takes: [cleanSince.variant.id])  // savepointed by another ask
            try ops.lockVariant(lockedSince.variant.id)                            // locked (its own insurance)
            try ops.deleteBlock(deletedSince.block.id)                             // its block deleted
            try ops.moveBlock(movedSince.block.id, to: other.id, at: .end)         // moved to another note

            let written = try ops.closeAutoCommit(
                post.id,
                takes: listed + [listed[0], foreign.variant.id, "no-such-take"])
            #expect(written.map(\.variantId) == [stillOwed.variant.id],
                    "only the take still owed — once, whatever the list held")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [cleanSince.variant.id]) == 1,
                    "the take already savepointed got no second savepoint")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [foreign.variant.id]) == 0,
                    "a take of another note is never written by this note's leaving")
        }
    }

    @Test func aGoneSealedOrCadenceOffNoteWritesNothingWhateverIsListed() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let take = try ops.seedBlock(in: post.id, text: "typed")
            try ops.setSavepointCadence(.onlyOnCommit)
            #expect(try ops.closeAutoCommit(post.id, takes: [take.variant.id]).isEmpty)
            try ops.setSavepointCadence(.everySession)
            try ops.lockPost(post.id)
            #expect(try ops.closeAutoCommit(post.id, takes: [take.variant.id]).isEmpty)
            let gone = try ops.createPost(title: "gone", profile: .blog)
            let goneTake = try ops.seedBlock(in: gone.id, text: "typed")
            try ops.deleteContainer(gone.id)
            #expect(try ops.closeAutoCommit(gone.id, takes: [goneTake.variant.id]).isEmpty)
            #expect(try ops.closeAutoCommit("no-such-container", takes: ["x"]).isEmpty)
            #expect(try ops.closeAutoCommit(post.id, takes: []).isEmpty)
            _ = db
        }
    }

    // MARK: Canonical equivalence — the read lists, neither op commits

    @Test func byteDifferentButEqualTextIsListedAndCommittedByNeither() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "accents", profile: .blog)
            let precomposed = "caf\u{E9}"
            let decomposed = "cafe\u{301}"
            #expect(precomposed == decomposed, "Swift reads these as one text")
            let take = try ops.seedBlock(in: post.id, text: precomposed)
            _ = try ops.closeAutoCommit(post.id)
            try ops.autosave(take.variant.id, text: decomposed, charDelta: 0)

            let listed = try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }
            #expect(listed == [take.variant.id], "the read compares bytes, so it lists the take")
            #expect(try ops.closeAutoCommit(post.id, takes: listed).isEmpty,
                    "the narrowed op re-checks as the whole op does, and writes nothing")
            #expect(try ops.closeAutoCommit(post.id).isEmpty, "…as the whole op writes nothing")
        }
    }

    // MARK: Cost shape — the narrowed op scales with the takes listed

    /// One edited take in a note of 100 blocks, then of 300: the narrowed op
    /// runs the SAME number of statements in both (the transaction, the note's
    /// checks, the one take's re-check and its savepoint with its triggers);
    /// the whole op runs one more last-savepoint read per block.
    @Test func theNarrowedOpsStatementsScaleWithTheTakesNotTheNote() throws {
        func counts(blocks: Int) throws -> (narrowed: Int, whole: Int) {
            try withOperations { ops, db in
                let post = try ops.createPost(title: "long", profile: .blog)
                var takes: [String] = []
                for index in 0..<blocks {
                    takes.append(try ops.seedBlock(in: post.id, text: "block \(index) of a long note").variant.id)
                }
                _ = try ops.closeAutoCommit(post.id)
                try ops.autosave(takes[17], text: "block 17, edited", charDelta: 8)

                func statements(_ body: () throws -> Void) throws -> Int {
                    let log = LockIsolated(0)
                    try db.writeWithoutTransaction { db in
                        db.trace(options: .statement) { _ in log.withValue { $0 += 1 } }
                    }
                    defer { try? db.writeWithoutTransaction { $0.trace(options: .statement, nil) } }
                    try body()
                    return log.value
                }
                let listed = try db.read { try Queries.leavingSavepointCandidates($0, containerID: post.id) }
                #expect(listed == [takes[17]])
                let narrowed = try statements { _ = try ops.closeAutoCommit(post.id, takes: listed) }
                try ops.autosave(takes[17], text: "block 17, edited again", charDelta: 6)
                let whole = try statements { _ = try ops.closeAutoCommit(post.id) }
                return (narrowed, whole)
            }
        }
        let short = try counts(blocks: 100)
        let long = try counts(blocks: 300)
        #expect(short.narrowed == long.narrowed,
                "the narrowed op does not grow with the note: \(short.narrowed) at 100 blocks, \(long.narrowed) at 300")
        #expect(long.whole - short.whole >= 200,
                "the whole op reads every take's last savepoint: \(short.whole) at 100 blocks, \(long.whole) at 300")
        #expect(long.narrowed * 10 < long.whole, "\(long.narrowed) vs \(long.whole)")
    }
}
