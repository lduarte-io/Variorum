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
            let book = try ops.createReading(name: "Orbit", kind: .curated)

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

    @Test func theCapRefusesTheSixthAndNamesItsLimit() throws {
        try withOperations { ops, db in
            var ids: [String] = []
            for index in 0..<Operations.starLimit {
                let note = try ops.createPost(title: "n\(index)", profile: .generic)
                ids.append(note.id)
                try ops.setStarred(.post(note.id), starred: true)
            }
            let sixth = try ops.createPost(title: "one too many", profile: .generic)

            #expect(throws: OperationError.starLimitReached(limit: Operations.starLimit)) {
                try ops.setStarred(.post(sixth.id), starred: true)
            }
            #expect(try db.read { try Queries.starred($0) }.map(\.target.id) == ids,
                    "the refusal leaves the five exactly as they were — nothing evicted")

            // And un-starring is the road the refusal names.
            try ops.setStarred(.post(ids[0]), starred: false)
            try ops.setStarred(.post(sixth.id), starred: true)
            #expect(try db.read { try Queries.starred($0) }.map(\.target.id)
                    == Array(ids.dropFirst()) + [sixth.id])
        }
    }

    @Test func aDeadTargetRendersNothingAndTheNextWriteHealsTheStoredList() throws {
        try withOperations { ops, db in
            let kept = try ops.createPost(title: "kept", profile: .generic)
            let doomedNote = try ops.createPost(title: "doomed note", profile: .generic)
            let doomedBook = try ops.createReading(name: "doomed book", kind: .curated)
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

    @Test func theCapCountsOnlyWhatSheCanSee() throws {
        // The reason the self-heal matters: a ghost star must never spend a
        // slot she cannot free, because the refusal's only road (un-star)
        // has no door for a row that renders nothing.
        try withOperations { ops, db in
            var ids: [String] = []
            for index in 0..<Operations.starLimit {
                let note = try ops.createPost(title: "n\(index)", profile: .generic)
                ids.append(note.id)
                try ops.setStarred(.post(note.id), starred: true)
            }
            try ops.deleteContainer(ids[2])

            let next = try ops.createPost(title: "one past the cap", profile: .generic)
            try ops.setStarred(.post(next.id), starred: true)
            // Symbolic over the cap (it was 5 at this pin's birth, 15 since
            // her 2026-09-18 #112(b) ruling): the live survivors in star
            // order, then the newcomer in the freed slot.
            var expected = ids
            expected.remove(at: 2)
            expected.append(next.id)
            #expect(try db.read { try Queries.starred($0) }.map(\.target.id)
                    == expected,
                    "the dead star freed its slot — the cap counts the live list")
        }
    }

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
