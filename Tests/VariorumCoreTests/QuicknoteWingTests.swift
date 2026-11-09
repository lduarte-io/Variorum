import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-841 (the VX-915 run, batch 3 — her ask, 2026-11-04: *"in quicknote it
/// would be nice to optionally be able to select what wing your quicknote lands
/// in"*).** The landing half, at the operation that files a quick note
/// (`fileAsQuicknote`), ruled at the batch's fork (the record:
/// `notes/plans/fixes/vx-915-recents-sweep.md`, BATCH 3): a capture aimed at
/// wing W lands BOOKLESS in W; the `quicknote` tag ADOPTS-OR-MINTS by path in
/// W's vocabulary — R-13ia-1's one rule, the cross-wing move's own `adoptPath`;
/// W grows NO Quicknotes gathering (that furniture is Home's). Home's road is
/// unchanged.
///
/// And the LATENT the feature would have made reachable (pinned red-on-old):
/// the tag's lookup was WING-BLIND, so once another wing held a live
/// `quicknote` tag a Home capture whose wing held none resolved THAT one and
/// the cross-wing application refused — the Home filing failed forever.
@Suite("VX-841 — a quick note filed in another wing")
struct QuicknoteWingTests {
    /// The note's live tags with their wing, by path.
    private func tagsWorn(_ db: AppDatabase, _ postID: String) throws -> [(path: String, wing: String)] {
        try db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT t.path, t.wing_id FROM post_tag pt
                    JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                    WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                    ORDER BY t.path
                    """,
                arguments: [postID]
            ).map { (path: $0["path"], wing: $0["wing_id"]) }
        }
    }

    private func quicknoteTagCount(_ db: AppDatabase, wing: String) throws -> Int? {
        try db.fetchInt(
            "SELECT COUNT(*) FROM tag WHERE path = ? AND wing_id = ? AND deleted_at IS NULL",
            [Operations.quicknoteTagPath, wing])
    }

    /// THE CONTRACT: a capture filed in W wears W's OWN `quicknote` tag (minted
    /// there by path), is collected by nothing, so W's Pool lists it — and no
    /// gathering is minted anywhere, Home's included. RED ON OLD: the filing
    /// minted Home's tag and Home's gathering, then the cross-wing application
    /// refused (`.refused`).
    @Test func aCaptureInAnotherWingWearsThatWingsOwnTagAndGrowsNoGathering() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            let note = try ops.importPost(title: nil, text: "Jotted.", wingId: work.id).container
            let outcome = ops.fileAsQuicknote(note.id)

            guard case .taggedOnly(let tagID) = outcome else {
                Issue.record("expected .taggedOnly — tagged, no gathering shows it — got \(outcome)")
                return
            }
            let tag = try db.read { try Tag.fetchOne($0, key: tagID) }
            #expect(tag?.path == Operations.quicknoteTagPath)
            #expect(tag?.wingId == work.id, "born in W's vocabulary")
            #expect(try tagsWorn(db, note.id).map(\.wing) == [work.id])
            #expect(try quicknoteTagCount(db, wing: "") == 0, "Home's vocabulary is untouched")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 0,
                    "W grows no gathering — and Home's is not minted by a W capture")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM setting WHERE key = ?",
                [Operations.quicknoteBookDesignationKey]) == 0, "no designation written")
            let note2 = try db.read { try Container.fetchOne($0, key: note.id) }
            #expect(note2?.wingId == work.id, "it landed in W")
            let pool = try db.read { try Queries.poolPosts($0, limit: 50, wingID: work.id).map(\.postID) }
            #expect(pool.contains(note.id), "bookless: W's Pool lists it")
        }
    }

    /// The second capture in W ADOPTS the tag the first one minted — one
    /// `quicknote` per wing, never a twin.
    @Test func aSecondCaptureInThatWingAdoptsItsTag() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            let first = try ops.importPost(title: nil, text: "One.", wingId: work.id).container
            let second = try ops.importPost(title: nil, text: "Two.", wingId: work.id).container
            guard case .taggedOnly(let tagID) = ops.fileAsQuicknote(first.id),
                  case .taggedOnly(let again) = ops.fileAsQuicknote(second.id)
            else {
                Issue.record("expected two .taggedOnly filings")
                return
            }
            #expect(again == tagID)
            #expect(try quicknoteTagCount(db, wing: work.id) == 1)
        }
    }

    /// A wing that already wears the path (her own tag, or one a Move to Wing
    /// adopted-or-minted there) is ADOPTED — R-13ia-1's rule, by path.
    @Test func aWingAlreadyWearingThePathAdoptsIt() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            let hers = try ops.createTag(name: Operations.quicknoteTagPath, wingID: work.id)
            let note = try ops.importPost(title: nil, text: "Jotted.", wingId: work.id).container
            #expect(ops.fileAsQuicknote(note.id) == .taggedOnly(tagID: hers.id))
            #expect(try quicknoteTagCount(db, wing: work.id) == 1, "nothing minted beside it")
        }
    }

    /// The tag lands through the ONE application road, so a living book IN W
    /// whose rule hears W's quicknote tag hears the capture — exactly as one in
    /// Home would hear Home's. (A guard, green on both sides: the old wing-blind
    /// lookup happened to find W's tag here, the only live one.)
    @Test func aLivingBookInThatWingHearsTheCapture() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            let tag = try ops.createTag(name: Operations.quicknoteTagPath, wingID: work.id)
            let book = try ops.createReading(
                name: "jots", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                wingId: work.id)
            let note = try ops.importPost(title: nil, text: "Jotted.", wingId: work.id).container
            _ = ops.fileAsQuicknote(note.id)
            let members = try db.read { try Queries.assembleReading($0, readingID: book.id).map(\.postID) }
            #expect(members.contains(note.id), "the applying act seated it")
        }
    }

    /// HOME IS UNCHANGED: with another wing standing, a Home capture still
    /// files `.filed` — Home's tag, Home's designated gathering, which shows
    /// it — and W's vocabulary is untouched. (A guard: green on both sides.)
    @Test func aHomeCaptureIsUnchanged() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            guard case .filed(let tagID, let readingID) = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .filed")
                return
            }
            let (tag, book) = try db.read { db in
                (try Tag.fetchOne(db, key: tagID), try Queries.reading(db, id: readingID))
            }
            #expect(tag?.wingId == "")
            #expect(book?.wingId == "")
            #expect(book?.kind == .gathering)
            #expect(try db.read { try Queries.quicknotesBookID($0) } == readingID)
            #expect(try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
                == [note.id])
            #expect(try quicknoteTagCount(db, wing: work.id) == 0)

            // …and a W capture after it never joins Home's gathering.
            let away = try ops.importPost(title: nil, text: "Away.", wingId: work.id).container
            _ = ops.fileAsQuicknote(away.id)
            #expect(try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
                == [note.id])
        }
    }

    /// THE LATENT, pinned (a bug the feature would have made common): another
    /// wing holds a live `quicknote` tag and Home holds none — her first ever
    /// quick note went to W, or she deleted Home's. A Home capture must mint
    /// HOME's own tag and file into Home's gathering. RED ON OLD: the wing-blind
    /// lookup resolved W's tag, the gathering was minted on W's tag id, and the
    /// cross-wing application refused — `.refused`.
    @Test func aHomeCaptureNeverResolvesAnotherWingsTag() throws {
        try withOperations { ops, db in
            let work = try ops.createWing(name: "Work")
            _ = try ops.createTag(name: Operations.quicknoteTagPath, wingID: work.id)
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            let outcome = ops.fileAsQuicknote(note.id)
            guard case .filed(let tagID, let readingID) = outcome else {
                Issue.record("expected the Home capture filed, got \(outcome)")
                return
            }
            #expect(try db.read { try Tag.fetchOne($0, key: tagID)?.wingId } == "", "Home's own tag")
            #expect(try tagsWorn(db, note.id).map(\.wing) == [""])
            #expect(try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
                == [note.id], "the gathering's rule names Home's tag, so it shows the note")
            #expect(try quicknoteTagCount(db, wing: work.id) == 1, "W's tag untouched")
        }
    }
}
