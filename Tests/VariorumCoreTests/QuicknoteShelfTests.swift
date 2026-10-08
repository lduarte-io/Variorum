import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13g, batch 7 — her ruling R6-4, verbatim: *"i also like the idea of
/// quicknotes automatically adding a quicknote tag and there being a smart
/// 'quicknotes' book that's just based on tag, so if you remove the tag it
/// leaves the book."*
///
/// The point of this suite is how LITTLE had to be built: an ordinary post
/// tag and an ordinary smart book pointed at each other. The leaving half is
/// smart membership's own semantics, and it is pinned here precisely because
/// nothing was written to make it true.
@Suite("The quicknote tag & its smart book (13g batch 7 — R6-4)")
struct QuicknoteShelfTests {
    @Test func filingTagsTheNoteAndPutsThePinnedSmartBookOnTheShelf() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            let outcome = ops.fileAsQuicknote(note.id)

            guard case .filed(let tagID, let readingID) = outcome else {
                Issue.record("expected .filed, got \(outcome)")
                return
            }
            let (tags, book, pins) = try db.read { database in
                (try Queries.postTags(database, postID: note.id),
                 try Queries.reading(database, id: readingID),
                 try Queries.shelfPins(database))
            }
            #expect(tags.map(\.path) == [Operations.quicknoteTagPath])
            #expect(tags.first?.id == tagID)
            #expect(book?.name == Operations.defaultQuicknoteBookName)
            #expect(book?.kind == .gathering)
            #expect(pins.contains(readingID))
            // Designated the daily book's way — so the SECOND quick note
            // finds it rather than minting a rival.
            #expect(try db.read { try Queries.quicknotesBookID($0) } == readingID)
        }
    }

    /// **13s-b U1b (R-13s-36/38) — the FRESH-MINT default is lowercase,
    /// and an existing gathering of hers is never renamed.** RED ON OLD:
    /// the constant was "Quicknotes". The fresh-only half: a store whose
    /// designated gathering carries the old title case keeps it — filing
    /// finds the book by the DESIGNATION, never the name.
    @Test func theFreshQuicknotesMintIsLowercaseAndAnExistingGatheringKeepsItsName() throws {
        try withOperations { ops, db in
            #expect(Operations.defaultQuicknoteBookName == "quicknotes",
                    "the ruled default (R-13s-36)")
            let first = try ops.importPost(title: nil, text: "Jotted.").container
            guard case .filed(_, let readingID) = ops.fileAsQuicknote(first.id) else {
                Issue.record("expected .filed")
                return
            }
            // An earlier build's shape: she holds a title-case gathering.
            try ops.renameReading(readingID, name: "Quicknotes")
            let second = try ops.importPost(title: nil, text: "Jotted again.").container
            guard case .filed(_, let again) = ops.fileAsQuicknote(second.id) else {
                Issue.record("expected .filed")
                return
            }
            #expect(again == readingID, "the designation finds her book — nothing minted")
            let name = try db.read { try Queries.reading($0, id: readingID)?.name }
            #expect(name == "Quicknotes", "…and it is NEVER renamed (fresh mints only, R-13s-38)")
        }
    }

    /// DISCRIMINATING REVERT (verified): mint the book `kind: .book`
    /// instead of `.gathering` in `ensureQuicknotesBook` and this test fails on
    /// its FIRST assembly — a curated book collects nothing, because
    /// membership would have to be a row somebody wrote.
    @Test func theBookCOLLECTSTheTagAndRemovingTheTagLEAVESIt() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            guard case .filed(let tagID, let readingID) = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .filed")
                return
            }

            let collected = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(collected.map(\.postID) == [note.id])

            // Her sentence's second half — and nothing was built for it.
            try ops.removeTag(tagID, fromPost: note.id)
            let afterUntag = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(afterUntag.isEmpty)

            // …and it left by DERIVATION: no membership row was ever
            // written, live or tombstoned, so nothing had to be cleaned up.
            let membershipRows = try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?",
                    arguments: [readingID])
            }
            #expect(membershipRows == 0)

            // Re-tagging brings it back, for the same reason.
            _ = try ops.applyTag(tagID, toPost: note.id)
            let again = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(again.map(\.postID) == [note.id])
        }
    }

    @Test func theSecondQuickNoteReusesTheSameTagAndTheSameBook() throws {
        try withOperations { ops, db in
            let first = try ops.importPost(title: nil, text: "One.").container
            let second = try ops.importPost(title: nil, text: "Two.").container
            guard case .filed(let tagID, let readingID) = ops.fileAsQuicknote(first.id),
                  case .filed(let tagID2, let readingID2) = ops.fileAsQuicknote(second.id)
            else {
                Issue.record("expected two .filed outcomes")
                return
            }
            #expect(tagID == tagID2)
            #expect(readingID == readingID2)
            let (tagCount, bookCount) = try db.read { database in
                (try Int.fetchOne(
                    database, sql: "SELECT COUNT(*) FROM tag WHERE deleted_at IS NULL"),
                 try Int.fetchOne(
                    database, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL"))
            }
            #expect(tagCount == 1)
            #expect(bookCount == 1)
            // Both notes are in the book, collected by the predicate.
            let collected = try db.read {
                try Queries.assembleReading($0, readingID: readingID).map(\.postID)
            }
            #expect(Set(collected) == Set([first.id, second.id]))
        }
    }

    /// A LIVE designation is never replaced (a book she renamed stays hers),
    /// and a dead one is never handed back as if it were live.
    ///
    /// 13i-b U4 — HONEST TEST EDIT: this pin's first half used to assert the
    /// 13g re-mint ("a DANGLING designation mints afresh"), the behaviour §20
    /// retires; that half now lives, inverted, in
    /// `deletingQuicknotesIsHerWordAndTheNextQuickNoteStillLandsTagged`.
    ///
    /// DISCRIMINATING REVERT (verified at 13g): drop the liveness clause from
    /// `Queries.quicknotesBookID`'s designation read and the dead book's id
    /// comes back as if it were live.
    @Test func aLiveDesignationIsNeverReplacedAndADeadOneNeverReadsLive() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "One.").container
            guard case .filed(_, let book) = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .filed")
                return
            }
            // Now it is LIVE and she has made it her own — renaming it must
            // not cause a rival to be minted beside it.
            try ops.renameReading(book, name: "My jots")
            let second = try ops.importPost(title: nil, text: "Two.").container
            guard case .filed(_, let again) = ops.fileAsQuicknote(second.id) else {
                Issue.record("expected .filed")
                return
            }
            #expect(again == book)
            #expect(try db.read { try Queries.reading($0, id: book)?.name } == "My jots")

            try ops.deleteReading(book)
            #expect(try db.read { try Queries.quicknotesBookID($0) } == nil)
        }
    }

    /// **13i-b U4 — §20, ratified at §23: Quicknotes is ORDINARY.** "No special
    /// identity, no delete guard … deleting the gathering breaks nothing — quick
    /// notes still land, still tagged, still findable in the tag's own listing,
    /// and the gathering is re-makeable in one gesture." The 13g self-create
    /// read a DANGLING designation as "none" and minted a fresh Quicknotes at
    /// the next quick note — the daily Journal's comes-back trait (lesson 9),
    /// which §20 explicitly withholds ("Two special books is one more than the
    /// design needs"). Her deletion is her word now (PROVISIONAL P-13ib-U4-2).
    ///
    /// RED ON THE PRE-U4 TREE (watched): the second filing re-minted the
    /// gathering — one live reading, the note shown by it (so not in the
    /// Pool), and the restored original then sat BESIDE the re-mint while the
    /// designation pointed at the twin.
    @Test func deletingQuicknotesIsHerWordAndTheNextQuickNoteStillLandsTagged() throws {
        try withOperations { ops, db in
            let first = try ops.importPost(title: nil, text: "One.").container
            guard case .filed(let tagID, let book) = ops.fileAsQuicknote(first.id) else {
                Issue.record("expected .filed")
                return
            }
            try ops.deleteReading(book)

            let second = try ops.importPost(title: nil, text: "Two.").container
            let outcome = ops.fileAsQuicknote(second.id)
            if case .filed = outcome {
                Issue.record("the filing claimed a Quicknotes landing after she deleted it: \(outcome)")
            }
            if case .refused = outcome { Issue.record("expected the note filed, got \(outcome)") }
            #expect(outcome == .taggedOnly(tagID: tagID))
            // Nothing came back.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 0)
            // Still lands, still tagged…
            let tags = try db.read { try Queries.postTags($0, postID: second.id) }
            #expect(tags.map(\.id) == [tagID])
            // …still findable in the tag's own listing…
            let tagged = try db.read { try Queries.everythingTagged($0, tagID: tagID).postIDs }
            #expect(Set(tagged) == Set([first.id, second.id]))
            // …and shown by no gathering now, so the Pool lists it.
            let pool = try db.read { try Queries.poolPosts($0, limit: 50).map(\.postID) }
            #expect(pool.contains(second.id))

            // Restoring it is the ordinary Trash door — and the filing door
            // then finds THAT book again (no twin was ever minted).
            try ops.restoreReading(book)
            let third = try ops.importPost(title: nil, text: "Three.").container
            guard case .filed(_, let again) = ops.fileAsQuicknote(third.id) else {
                Issue.record("expected .filed once it is back")
                return
            }
            #expect(again == book)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
        }
    }

    /// It NEVER THROWS — the note is already minted and durable by the time
    /// this runs, so a failure here must report rather than take the capture
    /// with it (`shelveInDailyJournalBook`'s rule, and its reason).
    @Test func itNeverThrowsAndSaysWhatHappened() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "One.").container
            _ = ops.fileAsQuicknote(note.id)
            // Filing the same note twice reports rather than refusing.
            guard case .alreadyTagged = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .alreadyTagged on a re-file")
                return
            }
            // A note that is gone reports too — and in words, never an
            // error dump with a row id in it.
            guard case .refused(let reason) = ops.fileAsQuicknote("no-such-note") else {
                Issue.record("expected .refused for a missing note")
                return
            }
            #expect(reason == "the note is no longer there")
            // Nothing partial was left behind by the refusal.
            let applications = try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM post_tag WHERE deleted_at IS NULL")
            }
            #expect(applications == 1)
        }
    }
}
