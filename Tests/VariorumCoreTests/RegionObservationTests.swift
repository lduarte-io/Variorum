import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-c Stage B R2-1 — `AppDatabase.observe(tracking:_:)`, the observation
// woken by NAMED regions only (the waiting-ask watch's road). The trace it
// answers: `observe` tracks what its fetch reads, and an autosave stamps the
// note's `container` row with a FULL-RECORD update (`registerTextChange`), so
// any fetch reading `container` re-runs per edit. Measured here, the limit
// that shapes the watch: that same update compiles the tombstone cascade
// (`cascade_container_tombstone` — block, container_block, reading_post, …)
// and writes the FTS index's shadow tables, which GRDB treats as touching
// every interested observer — so NO table a note's deletion writes can be told
// apart from an autosave. `reading` and `wing` are outside that set: a watch
// named on them never wakes for a keystroke and wakes for a book's or a
// wing's death.

/// A counted fetch that READS `container` (as the ask watch's
/// `askStanding` does).
private func liveNote(_ id: String, counting: LockIsolated<Int>) -> @Sendable (Database) throws -> Bool {
    { db in
        counting.withValue { $0 += 1 }
        return try Bool.fetchOne(
            db, sql: "SELECT deleted_at IS NULL FROM container WHERE id = ?", arguments: [id]) ?? false
    }
}

/// Polls until the counter moves past `value` (≤1 s), then returns it.
private func moved(_ counter: LockIsolated<Int>, past value: Int) async throws -> Int {
    for _ in 0..<100 where counter.value == value { try await Task.sleep(for: .milliseconds(10)) }
    return counter.value
}

/// A note with one block, and its block's take (an autosave's target).
private func noteWithTake(_ ops: Operations, _ db: AppDatabase) async throws -> (note: String, take: String) {
    let note = try ops.createPost(title: "ch 7")
    _ = try ops.newBlock(in: note.id, text: "a line", registeringUndo: false)
    let take = try #require(try await db.read { try Queries.renderPost($0, containerID: note.id) }.first?.variantID)
    return (note.id, take)
}

@Suite("13n-c Stage B R2-1 — a region-tracked observation wakes on its named tables only", .serialized)
struct RegionObservationTests {
    /// The ask watch's own shape: named on `reading` + `wing`, reading
    /// `container`. Four autosaves wake nothing; a book's write wakes it; a
    /// wing's death wakes it.
    @Test func aReadingAndWingWatchSleepsThroughAutosavesAndWakesForABookOrAWing() async throws {
        try await withOperationsAsync { ops, db in
            let (note, take) = try await noteWithTake(ops, db)
            let wing = try ops.createWing(name: "variorum")
            let fetches = LockIsolated(0)
            var values = db.observe(tracking: [Table("reading"), Table("wing")], liveNote(note, counting: fetches))
                .makeAsyncIterator()
            #expect(try await values.next() == true)
            let first = fetches.value
            for index in 0..<4 {
                try ops.autosave(take, text: "a line, edited \(index)", charDelta: 2)
            }
            try await Task.sleep(for: .milliseconds(300))
            #expect(fetches.value == first, "an autosave writes container + variant (+ their triggers) — no re-run")
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let afterBook = try await moved(fetches, past: first)
            #expect(afterBook == first + 1, "a book's write wakes it")
            try ops.deleteReading(book.id)
            let afterDelete = try await moved(fetches, past: afterBook)
            #expect(afterDelete == afterBook + 1, "a book's death wakes it")
            try ops.deleteWing(wing.id)
            #expect(try await moved(fetches, past: afterDelete) == afterDelete + 1, "a wing's death wakes it")
        }
    }

    /// The control: the read-tracked `observe` over the same fetch DOES re-run
    /// on an autosave (the full-record container stamp) — the reason the
    /// region-tracked twin exists.
    @Test func theReadTrackedTwinReRunsOnAnAutosave() async throws {
        try await withOperationsAsync { ops, db in
            let (note, take) = try await noteWithTake(ops, db)
            let fetches = LockIsolated(0)
            var values = db.observe(liveNote(note, counting: fetches)).makeAsyncIterator()
            #expect(try await values.next() == true)
            let first = fetches.value
            try ops.autosave(take, text: "a line, edited", charDelta: 2)
            #expect(try await moved(fetches, past: first) > first, "reading container means waking with every edit")
        }
    }

    /// THE MEASURED LIMIT (why a note's death is not in the watch's region):
    /// even named on `container_block` — the table the Trash tombstones a
    /// note's placements in — an autosave wakes the observation. If this ever
    /// goes quiet (a GRDB or trigger change), the ask watch may name
    /// `container_block` and catch a note's trip to the Trash too.
    @Test func thePlacementTableCannotTellATrashFromAnAutosave() async throws {
        try await withOperationsAsync { ops, db in
            let (note, take) = try await noteWithTake(ops, db)
            let fetches = LockIsolated(0)
            var values = db.observe(tracking: [Table("container_block")], liveNote(note, counting: fetches))
                .makeAsyncIterator()
            #expect(try await values.next() == true)
            let first = fetches.value
            try ops.autosave(take, text: "a line, edited", charDelta: 2)
            #expect(try await moved(fetches, past: first) > first, "an autosave reads as a placement write")
        }
    }
}
