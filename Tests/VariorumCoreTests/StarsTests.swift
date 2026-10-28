import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13f, W4 — STARS (her sitting ruling, round 3: *"stars = a synced
/// `setting` list + a Starred sidebar section … up to 5 notes or books"*).
///
/// The whole feature is list arithmetic over one `setting` row — the
/// `shelf_pins` precedent, ZERO schema — so this is where it is pinned:
/// star order, the cap's honest refusal, and the read rule that makes both
/// of them true (a star whose target died renders nothing, and the next
/// write heals the stored list).
@Suite("Stars (13f W4)")
struct StarsTests {
    @Test func starsAppendInStarTimeAndAreIdempotent() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the storm", profile: .generic)
            let book = try ops.createReading(name: "Orbit", kind: .book)

            try ops.setStarred(.post(note.id), starred: true)
            try ops.setStarred(.reading(book.id), starred: true)
            try ops.setStarred(.post(note.id), starred: true)  // idempotent

            let starred = try db.read { try Queries.starred($0) }
            #expect(starred.map(\.target) == [.post(note.id), .reading(book.id)],
                    "star TIME is the order, and notes and books share one list")
            #expect(starred.map(\.name) == ["the storm", "Orbit"])
            // Synced document semantics, like every other setting row.
            #expect(try db.outboxContains("setting", "starred"))
            #expect(try db.fetchInt("SELECT COUNT(*) FROM setting WHERE key = 'starred'") == 1,
                    "upsert-only — never a second row")
        }
    }

    /// **VX-643 — THE CAP IS GONE** (her word 2026-10-28: "getting rid of the 15
    /// star cap - seems weird and the rules of a book / the AI go past it anyway
    /// and i'm not convinced it should exist anymore"). THE DELIBERATE FLIP of
    /// 13f W4's `theCapRefusesTheSixthAndNamesItsLimit` (5, then 15 at #112(b)):
    /// forty stars — notes and books on the one list — all land, each APPENDED in
    /// star order, nothing evicted, still ONE upsert-only setting row; an
    /// un-star and re-star still moves the thing to the end. RED ON OLD: the
    /// sixteenth star refused `starLimitReached`.
    @Test func starringPastFifteenLandsEveryStarInStarOrder() throws {
        try withOperations { ops, db in
            var targets: [StarTarget] = []
            for index in 0..<40 {
                let target: StarTarget = index % 8 == 7
                    ? .reading(try ops.createReading(name: "book \(index)", kind: .book).id)
                    : .post(try ops.createPost(title: "n\(index)", profile: .generic).id)
                #expect(throws: Never.self, "star \(index + 1) lands") {
                    try ops.setStarred(target, starred: true)
                }
                targets.append(target)
            }
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == targets,
                    "every star, in star TIME order — nothing evicted, nothing refused")
            #expect(try db.read { try Queries.starredTargets($0) } == targets)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM setting WHERE key = 'starred'") == 1,
                    "upsert-only — still one row")

            // Un-star from the middle and star again: it moves to the end.
            try ops.setStarred(targets[3], starred: false)
            try ops.setStarred(targets[3], starred: true)
            var moved = targets
            moved.remove(at: 3)
            moved.append(targets[3])
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == moved)
        }
    }

    @Test func aDeadTargetRendersNothingAndTheNextWriteHealsTheStoredList() throws {
        try withOperations { ops, db in
            let kept = try ops.createPost(title: "kept", profile: .generic)
            let doomedNote = try ops.createPost(title: "doomed note", profile: .generic)
            let doomedBook = try ops.createReading(name: "doomed book", kind: .book)
            try ops.setStarred(.post(kept.id), starred: true)
            try ops.setStarred(.post(doomedNote.id), starred: true)
            try ops.setStarred(.reading(doomedBook.id), starred: true)

            try ops.deleteContainer(doomedNote.id)
            try ops.deleteReading(doomedBook.id)

            // THE READ RULE: a dead target renders nothing…
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == [.post(kept.id)])
            // …while the STORED value still carries all three until a write.
            #expect(try db.read { try Queries.starredTargets($0) }.count == 3)

            // THE SELF-HEAL: the next star write persists what she can see.
            let fresh = try ops.createPost(title: "fresh", profile: .generic)
            try ops.setStarred(.post(fresh.id), starred: true)
            #expect(try db.read { try Queries.starredTargets($0) }
                    == [.post(kept.id), .post(fresh.id)],
                    "the dead entries are gone from the stored list")
        }
    }

    // (`theCapCountsOnlyWhatSheCanSee` — "a ghost star must never spend a slot
    // she cannot free" — RETIRED at VX-643 with the cap: there are no slots.
    // The self-heal it leaned on stays pinned by
    // `aDeadTargetRendersNothingAndTheNextWriteHealsTheStoredList` above.)

    @Test func unstarringRemovesAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "n", profile: .generic)
            try ops.setStarred(.post(note.id), starred: true)
            try ops.setStarred(.post(note.id), starred: false)
            #expect(try db.read { try Queries.starred($0) }.isEmpty)

            // The identity-metadata convention: a write that changes nothing
            // writes nothing — no setting update, no outbox row.
            try db.clearOutbox()
            try ops.setStarred(.post(note.id), starred: false)  // already unstarred
            try ops.setStarred(.reading("never-starred"), starred: false)
            #expect(try db.outboxContains("setting", "starred") == false)
        }
    }

    @Test func malformedAndUnreadableEntriesReadAsNoStars() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "n", profile: .generic)
            try ops.setStarred(.post(note.id), starred: true)

            try db.write { db in
                try db.execute(sql: "UPDATE setting SET value = 'not json' WHERE key = 'starred'")
            }
            #expect(try db.read { try Queries.starred($0) }.isEmpty,
                    "malformed stars read as none — presentation, never truth")

            // An entry this version cannot read is DROPPED, not fatal, and
            // the readable ones around it survive.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE setting SET value = ? WHERE key = 'starred'",
                    arguments: [#"["nebula:x","post:\#(note.id)","bare-id",""]"#])
            }
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == [.post(note.id)])
        }
    }

    @Test func starringSomethingDeadOrAbsentRefuses() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "n", profile: .generic)
            try ops.deleteContainer(note.id)
            #expect(throws: OperationError.containerNotFound(id: note.id)) {
                try ops.setStarred(.post(note.id), starred: true)
            }
            #expect(throws: OperationError.readingNotFound(id: "nowhere")) {
                try ops.setStarred(.reading("nowhere"), starred: true)
            }
            // A scraps container is not a note, and cannot be starred.
            let pool = try ops.createPool(title: "scraps")
            #expect(throws: OperationError.containerNotFound(id: pool.id)) {
                try ops.setStarred(.post(pool.id), starred: true)
            }
            #expect(try db.read { try Queries.starred($0) }.isEmpty)
        }
    }

    @Test func anUntitledNoteCarriesNoNameSoTheAppsOneBrainNamesIt() throws {
        // The query reports the STORED title (nil where there is none), so
        // "Untitled" stays `WorkspaceNaming.label`'s single answer rather
        // than a second fallback growing in the core.
        try withOperations { ops, db in
            let note = try ops.createPost(title: nil, profile: .generic)
            try ops.setStarred(.post(note.id), starred: true)
            #expect(try db.read { try Queries.starred($0) }.first?.name == nil)
        }
    }

    @Test func theStoredKeyIsTheModelsWordAndRoundTrips() throws {
        // K5's letter: the sweep renames UI STRINGS, and can never reach a
        // stored value — so the key stays `post:` / `reading:`.
        #expect(StarTarget.post("abc").key == "post:abc")
        #expect(StarTarget.reading("abc").key == "reading:abc")
        #expect(StarTarget(key: "post:abc") == .post("abc"))
        #expect(StarTarget(key: "reading:abc") == .reading("abc"))
        // An id containing the separator survives (UUIDs never do, but the
        // decoder splits on the FIRST colon, so nothing depends on that).
        #expect(StarTarget(key: "post:a:b") == .post("a:b"))
        #expect(StarTarget(key: "note:abc") == nil, "the UI's word is not the stored word")
        #expect(StarTarget(key: "post:") == nil)
        #expect(StarTarget(key: "abc") == nil)
    }
}
