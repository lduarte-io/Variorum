//
//  MobileMembershipTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C2 — the masthead's note-identity pair:
//  the MEMBERSHIP CHIP (see/add/remove/diverge — her "move something
//  between books" finding, R31/R35's truth) and RENAME NOTE. Every act
//  is state-transition-tested through the view models against a real
//  in-memory store; every act routes through existing core operations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile membership chip (parity C2)")
struct MobileMembershipTests {
    /// The pure brains: the chip's three-case label (the Mac's own),
    /// curated-before-smart ordering, and the P-2 door rule (remove
    /// renders only where a membership ROW exists to remove).
    @Test func theChipBrainsSpeakTheMacGrammar() throws {
        #expect(MobileMembershipModel.labelText(bookNames: []) == "in no book")
        #expect(MobileMembershipModel.labelText(bookNames: ["Orbit"]) == "in Orbit")
        #expect(MobileMembershipModel.labelText(bookNames: ["A", "B"]) == "in 2 books")

        func reading(_ id: String, _ name: String, kind: ReadingKind) -> Reading {
            Reading(
                id: id, ownerId: nil, name: name, kind: kind, profile: nil,
                sortField: .manual, sortDir: .asc, groupingTagId: nil,
                querySpec: nil, maxPosts: nil, wordTarget: nil, locked: false,
                createdAt: Date(), updatedAt: Date(), deletedAt: nil, syncVersion: 0)
        }
        let smart = reading("s", "Alpha", kind: .gathering)
        let curated = reading("c", "Zeta", kind: .book)
        #expect(MobileMembershipModel.ordered([smart, curated]).map(\.id) == ["c", "s"],
                "curated before smart, whatever the names say")
        #expect(MobileMembershipModel.rowCarriesRemove(curated))
        #expect(!MobileMembershipModel.rowCarriesRemove(smart),
                "derived membership has no row to remove — no door (P-2)")
    }

    /// Add and remove are exact membership rows; the smart add goes BY
    /// TAGGING (R98's apply-and-report) and the smart book then appears
    /// in the chip's own list (derived membership IS membership).
    @Test func addRemoveAndCollectAreExactRows() async throws {
        try await withEditorWorld { session, db in
            let (postID, curatedID, smartID) = try await session.runner.run {
                ops -> (String, String, String) in
                let post = try ops.createPost(title: "Harbor")
                let curated = try ops.createReading(name: "Essays", kind: .book)
                _ = try ops.createTag(name: "sea")
                let smart = try ops.createReading(
                    name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#)
                return (post.id, curated.id, smart.id)
            }
            let model = MobileMembershipModel(session: session, postID: postID)
            await model.refresh()
            #expect(model.books.isEmpty)
            #expect(model.addableBooks.map(\.id) == [curatedID])
            #expect(model.addableSmartBooks.map(\.id) == [smartID])

            let curated = try #require(model.addableBooks.first)
            await model.add(to: curated)
            #expect(model.books.map(\.id) == [curatedID])
            #expect(model.status == "Added to “Essays”.")
            let live = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [curatedID, postID])
            }
            #expect(live == 1, "one live membership row")

            let smart = try #require(model.addableSmartBooks.first)
            await model.collect(into: smart)
            #expect(model.status?.contains("#sea") == true,
                    "the door says adding IS tagging")
            #expect(try await db.read { db in
                try Queries.postTags(db, postID: postID).map(\.path)
            } == ["sea"])
            #expect(model.books.map(\.id) == [curatedID, smartID],
                    "the smart collection joins the list, after curated")

            await model.remove(from: curated)
            #expect(model.books.map(\.id) == [smartID])
            #expect(model.status == "Removed from “Essays” — the note itself is untouched.")
            let tombstoned = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NOT NULL",
                    arguments: [curatedID, postID])
            }
            #expect(tombstoned == 1, "remove is a tombstone, never a row delete (S2)")
        }
    }

    /// W23's compound through the SHARED flush-first entry: the copy
    /// lands at the original's EXACT slot, the original leaves THIS book
    /// only — and the copy carries the bytes still pending in the
    /// autosave coordinator (the R1-4 class, pinned). The phone's status
    /// promises no undo (no structural undo exists here) and names no
    /// platform.
    @Test func divergeSwapsAtTheExactSlotAndCarriesPendingBytes() async throws {
        try await withEditorWorld { session, db in
            let (postID, otherID, bookID, variantID) = try await session.runner.run {
                ops -> (String, String, String, String) in
                let post = try ops.createPost(title: "Tides")
                let block = try ops.newBlock(in: post.id, text: "First words.", at: .end)
                let other = try ops.createPost(title: "Anchor")
                let book = try ops.createReading(name: "Logbook", kind: .book)
                _ = try ops.addPostToReading(other.id, to: book.id)
                _ = try ops.addPostToReading(post.id, to: book.id)
                return (post.id, other.id, book.id, block.variant.id)
            }
            let originalRow = try #require(await db.read { db in
                try ReadingPost.fetchOne(
                    db,
                    sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [bookID, postID])
            })

            // The R1-4 moment: typed bytes still pending in the ONE
            // per-post coordinator when the diverge door is pressed.
            session.autosave(forPost: postID).record(
                variantID: variantID, text: "First words, just typed.", charDelta: 12)

            let model = MobileMembershipModel(session: session, postID: postID)
            await model.refresh()
            let book = try #require(model.books.first)
            await model.diverge(for: book)

            #expect(model.books.isEmpty, "the original left THIS book")
            let copyID = try #require(model.divergedCopyID)
            let copyRow = try #require(await db.read { db in
                try ReadingPost.fetchOne(
                    db,
                    sql: "SELECT * FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [bookID, copyID])
            })
            #expect(copyRow.position == originalRow.position,
                    "the copy inherits the original's exact slot")
            #expect(try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT v.working_text FROM container_block cb
                        JOIN block b ON b.id = cb.block_id
                        JOIN variant v ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                        """,
                    arguments: [copyID])
            } == ["First words, just typed."],
                    "the copy carries the PENDING bytes — flush-first (R1-4)")
            #expect(try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM container WHERE id = ? AND deleted_at IS NULL",
                    arguments: [postID])
            } == 1, "the original lives on")
            let otherStill = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [otherID])
            }
            #expect(otherStill == 1, "the book's other note is untouched")

            let status = try #require(model.status)
            #expect(status.contains("holds the copy now"))
            #expect(!status.contains("Mac"), "no platform name")
            #expect(!status.contains("⌥"), "no undo promise — the phone has no structural undo")
        }
    }

    /// A smart row's diverge refuses honestly and names the tag road —
    /// without naming a door the phone lacks, and without minting
    /// anything.
    @Test func aSmartRowsDivergeRefusesNamingTheTagRoad() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Gulls")
                let tag = try ops.createTag(name: "sea")
                _ = try ops.applyTag(tag.id, toPost: post.id)
                _ = try ops.createReading(
                    name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#)
                return post.id
            }
            let model = MobileMembershipModel(session: session, postID: postID)
            await model.refresh()
            let smart = try #require(model.books.first)
            let postsBefore = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container")
            }

            await model.diverge(for: smart)

            let status = try #require(model.status)
            #expect(status.contains("collects by its tags"))
            #expect(!status.contains("Mac"))
            #expect(!status.contains("Duplicate as Version"),
                    "no door the phone lacks is named")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container")
            } == postsBefore, "a refusal mints nothing")
            #expect(model.divergedCopyID == nil)
        }
    }
}

@MainActor
@Suite("Mobile note metadata — rename (parity C2)")
struct MobileNoteRenameTests {
    /// Rename writes the STORED title (trimmed) and the masthead follows
    /// deterministically; a blank clears to NIL — the ⌘N no-placeholder
    /// semantics (13g R6-3 / the K1 doctrine).
    @Test func renameWritesTrimsAndBlankClears() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "Old name")
            }.id
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(model.displayTitle == "Old name")

            await model.renameNote("  Harbor Light ")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT title FROM container WHERE id = ?", arguments: [postID])
            } == "Harbor Light", "the stored title lands trimmed")
            #expect(model.displayTitle == "Harbor Light")
            #expect(model.statusMessage == nil)

            await model.renameNote("   ")
            let stored = try await db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT title FROM container WHERE id = ?", arguments: [postID])
                    .map(CopiedRow.init)
            }
            #expect(stored?["title"] == nil as String?,
                    "a blank clears the stored title to NIL — no placeholder")
            #expect(model.displayTitle != "Harbor Light",
                    "the masthead falls to the derived display brain")
        }
    }

    /// The seal is content-level (AppSpec §9's letter: a sealed post
    /// "may still be … retitled") — rename works on a locked note.
    @Test func renameWorksUnderTheSeal() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Sealed")
                try ops.lockPost(post.id)
                return post.id
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(model.isSealed)

            await model.renameNote("Sealed, renamed")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT title FROM container WHERE id = ?", arguments: [postID])
            } == "Sealed, renamed")
            #expect(model.statusMessage == nil, "no refusal — the seal is content-level")
            #expect(model.isSealed, "renaming never unseals")
        }
    }
}

@MainActor
@Suite("Mobile note metadata — entry date (parity C2, her sitting item 4)")
struct MobileNoteEntryDateTests {
    /// Set AND clear through the core's `setEntryDate`; the masthead
    /// follows (an untitled note displays its day — the DisplayTitle
    /// chain), and clearing un-dates the note exactly.
    @Test func setAndClearTheEntryDate() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: nil)
            }.id
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()

            await model.setEntryDate("2026-08-09")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT entry_date FROM container WHERE id = ?",
                    arguments: [postID])
            } == "2026-08-09")
            #expect(model.displayTitle == "2026-08-09",
                    "an untitled note's masthead shows its day")
            #expect(model.statusMessage == nil)

            await model.setEntryDate("  ")
            let stored = try await db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT entry_date FROM container WHERE id = ?",
                    arguments: [postID]).map(CopiedRow.init)
            }
            #expect(stored?["entry_date"] == nil as String?,
                    "blank clears — un-dating a note is legitimate")
            #expect(model.statusMessage == nil)
        }
    }

    /// **VM-84 — the date chip follows the date when the title does not move.**
    /// The chip read `header?.entryDate`, and `header` is `@ObservationIgnored`
    /// (editor internals, never observed), so the masthead re-rendered on a
    /// date change ONLY when the title changed in the same pass — an untitled
    /// note's displayed title IS its date. On a TITLED note nothing the chip
    /// observed changed, so it kept the old day.
    ///
    /// The pin holds exactly what the chip observes (`dateChipDay`, its one
    /// read) under `withObservationTracking` — SwiftUI's own mechanism for
    /// re-rendering a body — through both roads: the model's own door, and
    /// the op from elsewhere (the day shift) followed by the header door's
    /// store re-read. **Red on old:** neither change wakes the chip.
    ///
    /// This pin holds the SEAM; `noPhoneFaceReadsTheEditorsUnobservedHeaderDate`
    /// below holds the FACE — that the chip's body reads nothing else
    /// (VM-78 ladder round 4, G1).
    @Test func theDateChipFollowsTheDateWhenTheTitleDoesNot() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Kept title")
                try ops.setEntryDate(post.id, entryDate: "2026-08-09")
                return post.id
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(MobileWriteScreen.dateChipDay(model) == "2026-08-09")
            #expect(model.displayTitle == "Kept title")

            // Road 1: the chip's own door (Set in the date alert).
            let wokeByDoor = LockIsolated(false)
            withObservationTracking {
                _ = MobileWriteScreen.dateChipDay(model)
            } onChange: {
                wokeByDoor.setValue(true)
            }
            await model.setEntryDate("2026-08-10")
            #expect(wokeByDoor.value, "a date change must wake the chip")
            #expect(MobileWriteScreen.dateChipDay(model) == "2026-08-10")
            #expect(model.displayTitle == "Kept title", "the title never moved")

            // Road 2: the op from elsewhere (the day shift), then the header
            // door's store re-read — the road a sync delivery also takes.
            let wokeByShift = LockIsolated(false)
            withObservationTracking {
                _ = MobileWriteScreen.dateChipDay(model)
            } onChange: {
                wokeByShift.setValue(true)
            }
            _ = try await session.runner.run { ops in
                try ops.shiftEntryDate(postID, byDays: 1)
            }
            await model.confirmNoteStillLive()
            #expect(wokeByShift.value, "a shifted date must wake the chip")
            #expect(MobileWriteScreen.dateChipDay(model) == "2026-08-11")

            // P3's half (green on both sides): a header refresh that changes
            // nothing the chip shows wakes nothing — the chip does not
            // re-render the masthead on every header delivery.
            let wokeByNothing = LockIsolated(false)
            withObservationTracking {
                _ = MobileWriteScreen.dateChipDay(model)
            } onChange: {
                wokeByNothing.setValue(true)
            }
            await model.confirmNoteStillLive()
            #expect(!wokeByNothing.value, "an unchanged header wakes nothing")
        }
    }

    /// **The date chip's FACE — a source guard** (VM-78 ladder round 4,
    /// R4-F1, G1). The pin above holds the seam (`dateChipDay`); nothing
    /// there sees whether the chip's body reads it. The next wave-1 merge
    /// conflicts on the chip's label lines, and the other side of that hunk
    /// is the face from before VM-84 — `model.header?.entryDate`, where
    /// `header` is `@ObservationIgnored`. This walk of the phone's product
    /// sources forbids that read everywhere outside the model itself: a
    /// MEMBER ACCESS `.header?.entryDate` / `.header!.entryDate` /
    /// `.header.entryDate`, on comment-stripped lines.
    ///
    /// Deliberately narrow: a local named `header` is not matched
    /// (`MobileStars`' `header.entryDate` reads a fetched row), and the
    /// other `.header?.` reads are not forbidden (the rename door's
    /// tap-time seed, `renameField = model.header?.title`, is legitimate).
    /// Red on `e48ef2f30` (three lines), on `2d66e9a30` (one), and on main
    /// and VM-47's tip (three each); green on the fix.
    @Test func noPhoneFaceReadsTheEditorsUnobservedHeaderDate() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
        let root = appRoot.appendingPathComponent("VariorumMobile", isDirectory: true)
        #expect(FileManager.default.fileExists(atPath: root.path), "the sweep root is missing")
        let walk = try #require(FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil))
        // The model's own file is the one place `header` may be read: it is
        // where `adoptHeader` mirrors the day into the observed `entryDate`.
        let modelFile = "/Features/Write/MobileEditorViewModel.swift"
        let unobservedRead = /\.header[?!]?\.entryDate\b/
        var walked = 0
        var offenders: [String] = []
        for case let url as URL in walk where url.pathExtension == "swift" {
            guard !url.path.hasSuffix(modelFile) else { continue }
            walked += 1
            let source = try String(contentsOf: url, encoding: .utf8)
            for (number, line) in MobileNoRawErrorPinTests.strippingComments(source).enumerated()
            where line.contains(unobservedRead) {
                offenders.append(
                    "\(url.lastPathComponent):\(number + 1) \(line.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(walked > 60, "the walk must reach the phone's sources (walked \(walked))")
        #expect(offenders.isEmpty, """
            A phone face reads the editor's UNOBSERVED `header` for the entry date. \
            Read `MobileWriteScreen.dateChipDay(model)` (the model's observed \
            `entryDate`) instead — `header` is `@ObservationIgnored`, so a face that \
            reads it waits for the title to change (VM-84):
            \(offenders.joined(separator: "\n"))
            """)
    }

    /// C2 ladder R1-2 (red-on-old): an untitled, UNDATED note's masthead
    /// falls back to its created DAY through the SAME DisplayTitle chain
    /// the Library row reads — two surfaces must never disagree on one
    /// note's name. (Pre-fix the header dropped `createdAt`, so the
    /// masthead read the placeholder while the row read the day.)
    @Test func anUntitledUndatedNoteMastheadShowsItsCreatedDay() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: nil)
            }.id
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            let storedStamp = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT created_at FROM container WHERE id = ?",
                    arguments: [postID])
            }
            #expect(model.displayTitle == DisplayTitle.note(
                title: nil, entryDate: nil, createdAt: storedStamp),
                    "the masthead and the listing rows share one chain")
            #expect(model.displayTitle != DisplayTitle.placeholder,
                    "a created day exists, so the placeholder must not show")
        }
    }

    /// C2 ladder R1-1: the blank-clear copy names the REAL fallback (the
    /// date), never the retired "its own words" promise no display shape
    /// ever kept.
    @Test func theBlankClearMessageNamesTheRealFallback() {
        #expect(MobileEditorViewModel.blankTitleClearsMessage.contains("its date"))
        #expect(!MobileEditorViewModel.blankTitleClearsMessage.contains("own words"))
    }

    /// A malformed day REFUSES AND KEEPS (the op's `invalidEntryDate`
    /// belt, spoken in phone words — no platform name; the ExtentInput
    /// parallel: a typo must never silently clear a stored date).
    @Test func aMalformedDayRefusesAndKeeps() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: nil)
                try ops.setEntryDate(post.id, entryDate: "2026-08-01")
                return post.id
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()

            await model.setEntryDate("next tuesday")
            #expect(model.statusMessage == MobileEditorViewModel.entryDateRefusal)
            #expect(MobileEditorViewModel.entryDateRefusal.contains("Mac") == false)
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT entry_date FROM container WHERE id = ?",
                    arguments: [postID])
            } == "2026-08-01", "the stored date survives the typo")
        }
    }

    /// Dating rides the retitle class — container METADATA the seal does
    /// not freeze (the op's standing behavior on both platforms,
    /// recorded and pinned rather than left to inference).
    @Test func entryDateWorksUnderTheSeal() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Sealed")
                try ops.lockPost(post.id)
                return post.id
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(model.isSealed)

            await model.setEntryDate("2026-08-09")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT entry_date FROM container WHERE id = ?",
                    arguments: [postID])
            } == "2026-08-09")
            #expect(model.statusMessage == nil, "no refusal — metadata, the retitle class")
            #expect(model.isSealed, "dating never unseals")
        }
    }
}
