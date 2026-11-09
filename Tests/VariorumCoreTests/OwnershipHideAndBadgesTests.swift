import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — HIDE-OWNED and the BADGE FACTS (the 13i-c plan §3; the sitting
/// record §6: "the HIDE-OWNED toggle is the release valve: per-gathering + a
/// global default, scope = gathering assemblies, tag listings, search; Library
/// EXEMPT … Global default = SHOW, badged"; "the badge family … toggleable as
/// a set; silence the common case").
@Suite("13i-c U2 — hide-owned (the fragment, the toggle, the default) · the badge facts")
struct OwnershipHideAndBadgesTests {
    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// A gathering on #t over two tagged notes, one of them held by an owned
    /// book.
    private func world(
        _ ops: Operations
    ) throws -> (gathering: Reading, owned: Reading, claimed: Container, free: Container, tag: VariorumCore.Tag) {
        let t = try ops.createTag(name: "t")
        let gathering = try ops.createReading(
            name: "g", kind: .gathering, querySpec: try rule(.tag(t.id)))
        let owned = try ops.createReading(name: "owned", kind: .book)
        try ops.setReadingOwned(owned.id, owned: true)
        let claimed = try ops.createPost(title: "claimed")
        let free = try ops.createPost(title: "free")
        try ops.addPostToReading(claimed.id, to: owned.id)
        for n in [claimed, free] { _ = try ops.applyTag(t.id, toPost: n.id) }
        return (gathering, owned, claimed, free, t)
    }

    private func shown(_ db: AppDatabase, _ readingID: String) throws -> Set<String> {
        Set(try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) })
    }

    @Test func theDefaultShowsOwnedNotesInAGatheringAndTheGlobalSwitchHidesThem() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            #expect(try shown(db, w.gathering.id) == [w.claimed.id, w.free.id])   // SHOW
            #expect(try db.read { try Queries.themeSettings($0) }.hideOwnedByDefault == false)

            try ops.setHideOwnedDefault(true)

            #expect(try shown(db, w.gathering.id) == [w.free.id])
            // The chip and the page-driven listing agree with the assembly.
            #expect(try db.read { try Queries.readingsContaining($0, postID: w.claimed.id) }
                .map(\.id) == [w.owned.id])
            #expect(try db.read {
                try Queries.smartBookMembership($0, postIDs: [w.claimed.id, w.free.id])
            } == [w.free.id: ["g"]])
            // Tag listings follow the global switch…
            #expect(try db.read { try Queries.taggedPostItems($0, tagID: w.tag.id) }
                .map(\.postID) == [w.free.id])
            // …and the LIBRARY is exempt (R32).
            #expect(Set(try db.read { try Queries.library($0) }.map(\.postID))
                .isSuperset(of: [w.claimed.id, w.free.id]))
        }
    }

    @Test func aGatheringsOwnToggleOutranksTheGlobalDefault() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try ops.setReadingHideOwned(w.gathering.id, true)
            #expect(try shown(db, w.gathering.id) == [w.free.id])
            try ops.setHideOwnedDefault(true)
            try ops.setReadingHideOwned(w.gathering.id, false)
            #expect(try shown(db, w.gathering.id) == [w.claimed.id, w.free.id])
            try ops.setReadingHideOwned(w.gathering.id, nil)          // follow the default
            #expect(try shown(db, w.gathering.id) == [w.free.id])
            // Released, the note shows again — it is free now.
            try ops.removePostFromReading(w.claimed.id, from: w.owned.id)
            #expect(try shown(db, w.gathering.id) == [w.claimed.id, w.free.id])
        }
    }

    @Test func theToggleIsAGatheringsAndIsNoOpGuarded() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            #expect(throws: OperationError.wrongReadingKind(id: w.owned.id, expected: .gathering)) {
                try ops.setReadingHideOwned(w.owned.id, true)
            }
            try db.clearOutbox()
            try ops.setReadingHideOwned(w.gathering.id, nil)   // already nil
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
            try ops.setReadingHideOwned(w.gathering.id, true)
            #expect(try db.outboxContains("reading", w.gathering.id))
        }
    }

    @Test func theTwoSettingsResolveAtReadAndRoundTrip() throws {
        try withOperations { ops, db in
            var settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.hideOwnedByDefault == false && settings.ownershipBadges == true)
            try ops.setOwnershipBadges(false)
            try ops.setHideOwnedDefault(true)
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.hideOwnedByDefault == true && settings.ownershipBadges == false)
            // An unrecognized value is her default, never a silent flip.
            try db.write {
                try $0.execute(sql: "UPDATE setting SET value = 'x' WHERE key IN "
                    + "('hide_owned_default', 'ownership_badges')")
            }
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.hideOwnedByDefault == false && settings.ownershipBadges == true)
            #expect(try db.read { try Queries.hideOwnedDefault($0) } == false)
        }
    }

    /// **VX-934 — the AI pair's own switch** (her ruling, #269: the badge
    /// family SPLIT — the book marks keep `ownership_badges`, the shared icon
    /// and the Private eye get one switch of their own, in Settings ▸ MCP). A
    /// synced setting of the enum class: ON by default at READ (no seed row),
    /// "1"/"0" stored, an unrecognized value reads her default, and the two
    /// switches never move each other. An Improvement — the pin states the
    /// new contract.
    @Test func theAIMarksSwitchResolvesAtReadRoundTripsAndStandsApartFromTheBadges() throws {
        try withOperations { ops, db in
            #expect(try db.fetchInt("SELECT COUNT(*) FROM setting WHERE key = 'ai_marks'") == 0,
                    "no seed row — the default is the read's")
            var settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.aiMarks == true && settings.ownershipBadges == true, "both ON by default")

            try db.clearOutbox()
            try ops.setAIMarks(false)
            #expect(try db.outboxContains("setting", "ai_marks"), "synced — it rides the outbox")
            #expect(try db.read { try String.fetchOne($0, sql: "SELECT value FROM setting WHERE key = 'ai_marks'") }
                    == "0", "a token, never prose (the PLAIN promise)")
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.aiMarks == false)
            #expect(settings.ownershipBadges == true, "the AI switch leaves the book marks alone")

            try ops.setOwnershipBadges(false)
            try ops.setAIMarks(true)
            settings = try db.read { try Queries.themeSettings($0) }
            #expect(settings.aiMarks == true && settings.ownershipBadges == false,
                    "the book marks' switch leaves the AI pair alone")

            // An unrecognized value is her default, never a silent OFF.
            try db.write { try $0.execute(sql: "UPDATE setting SET value = 'x' WHERE key = 'ai_marks'") }
            #expect(try db.read { try Queries.themeSettings($0) }.aiMarks == true)
        }
    }

    @Test func theBadgeFactsNameTheOwnerAndTheOtherBooksAndSaySilenceForFreeNotes() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let a = try ops.createReading(name: "a", kind: .book)
            let b = try ops.createReading(name: "b", kind: .book)
            let shared = try ops.createPost(title: "shared")
            try ops.addPostToReading(shared.id, to: a.id)
            try ops.addPostToReading(shared.id, to: b.id)

            let listing = try db.read {
                try Queries.ownershipFacts($0, postIDs: [w.claimed.id, w.free.id, shared.id])
            }
            #expect(listing[w.claimed.id]?.ownedBy == Queries.BookRef(id: w.owned.id, name: "owned"))
            #expect(listing[w.free.id] == nil)                          // silence
            #expect(listing[shared.id]?.ownedBy == nil)
            #expect(listing[shared.id]?.otherBooks.map(\.name) == ["a", "b"])

            let inBookA = try db.read {
                try Queries.ownershipFacts($0, postIDs: [shared.id], inBook: a.id)
            }
            #expect(inBookA[shared.id]?.otherBooks.map(\.name) == ["b"])
            #expect(inBookA[shared.id]?.otherBookCount == 1)
        }
    }

    @Test func theBadgeFactsAreOnePageDrivenStatement() throws {
        // P1 on the PLAN: the page's ids drive; each seeks the post index —
        // never a scan of `reading_post`.
        try withOperations { ops, db in
            _ = try world(ops)
            let plan = try db.read { db -> String in
                try Row.fetchAll(
                    db, sql: "EXPLAIN QUERY PLAN \(Queries.ownershipFactsSQL)",
                    arguments: ["[\"x\"]"]
                ).map { ($0["detail"] as String?) ?? "" }.joined(separator: "\n")
            }
            #expect(plan.contains("idx_reading_post_post"), "\(plan)")
            #expect(!plan.contains("SCAN rp"), "\(plan)")
        }
    }
}
