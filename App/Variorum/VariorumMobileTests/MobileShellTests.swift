//
//  MobileShellTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 3, batch 1 — the app shape's suite: the shelf's LK5
//  faces + Mac-mirrored order, the Today door (the Phase 8 A1-class
//  daily-book pins RE-POINTED here — the capture surface retired with
//  its test file; these pins are its load-bearing survivors), the book
//  list's chapter grouping, the shell router's voice flip, and the
//  background flush re-pointed at the S1 editor.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile shell — shelf, Today, router (S3 batch 1)")
struct MobileShellTests {
    // MARK: - The shelf's faces (LK5) + order

    /// LK5's letter, pinned: note count + tags LEAD the meta line; the
    /// daily marker ranks BEHIND them; journal books count "entries", the
    /// rest "notes"; smart books say "smart" with their own query tags;
    /// tags display LEAF-ONLY (the 13k K3 doctrine).
    @Test func lk5FacesLeadWithCountAndTags() throws {
        func book(
            _ name: String, kind: ReadingKind = .curated, profile: String? = nil,
            locked: Bool = false, spec: String? = nil, posts: Int = 0
        ) -> Queries.ShelfBook {
            Queries.ShelfBook(
                reading: Reading(
                    id: name, ownerId: nil, name: name, kind: kind, profile: profile,
                    sortField: .manual, sortDir: .asc, groupingTagId: nil,
                    querySpec: spec, maxPosts: nil, wordTarget: nil, locked: locked,
                    createdAt: Date(), updatedAt: Date(), deletedAt: nil,
                    syncVersion: 0),
                postCount: posts, sectionCount: 0)
        }

        let essays = book("Essays", posts: 2)
        #expect(MobileShelfFaces.meta(
            for: essays, tagPaths: ["life/goals"], isDaily: false)
            == "2 notes · #goals", "count leads, tags follow, leaf-only")

        let journal = book("Journal", profile: "journal", posts: 1)
        #expect(MobileShelfFaces.meta(for: journal, tagPaths: [], isDaily: true)
            == "1 entry · daily", "journal counts entries; daily ranks behind")
        #expect(MobileShelfFaces.meta(for: journal, tagPaths: ["dreams"], isDaily: true)
            == "1 entry · #dreams · daily", "tags outrank the daily marker")

        let smart = book(
            "reading notes", kind: .smart, spec: #"{"tags":["books"]}"#)
        #expect(MobileShelfFaces.tagPaths(for: smart, curatedTags: [:]) == ["books"],
                "a smart book's tags are its own spec")
        #expect(MobileShelfFaces.meta(for: smart, tagPaths: ["books"], isDaily: false)
            == "smart · #books", "derived membership is never a count")
    }

    /// LK5's rider: ✓ finished is a STATE riding the NAME (the Mac
    /// grammar), never a meta stat.
    @Test func finishedIsAStateOnTheNameNeverAMetaStat() throws {
        let finished = Queries.ShelfBook(
            reading: Reading(
                id: "p", ownerId: nil, name: "Poems", kind: .curated, profile: nil,
                sortField: .manual, sortDir: .asc, groupingTagId: nil, querySpec: nil,
                maxPosts: nil, wordTarget: nil, locked: true,
                createdAt: Date(), updatedAt: Date(), deletedAt: nil, syncVersion: 0),
            postCount: 3, sectionCount: 0)
        #expect(MobileShelfFaces.name(for: finished) == "Poems ✓")
        let meta = MobileShelfFaces.meta(for: finished, tagPaths: [], isDaily: false)
        #expect(meta == "3 notes")
        #expect(!meta.contains("finished"), "the state lives on the name")
    }

    /// The Mac `ShelfViewModel.ordered` semantics, mirrored: pins first
    /// in pin order, then journal-profile books by name, then the rest by
    /// name.
    @Test func shelfOrderPutsPinsFirstThenJournalsThenName() throws {
        func book(_ id: String, _ name: String, profile: String? = nil) -> Queries.ShelfBook {
            Queries.ShelfBook(
                reading: Reading(
                    id: id, ownerId: nil, name: name, kind: .curated, profile: profile,
                    sortField: .manual, sortDir: .asc, groupingTagId: nil,
                    querySpec: nil, maxPosts: nil, wordTarget: nil, locked: false,
                    createdAt: Date(), updatedAt: Date(), deletedAt: nil,
                    syncVersion: 0),
                postCount: 0, sectionCount: 0)
        }
        let books = [
            book("z", "Zebra"), book("j", "Journal", profile: "journal"),
            book("a", "Aster"), book("d", "Dreams", profile: "journal"),
            book("p", "Pinned late"),
        ]
        let ordered = MobileShelfFaces.ordered(books: books, pins: ["p", "z"])
        #expect(ordered.map(\.reading.id) == ["p", "z", "d", "j", "a"],
                "pin order · journals by name · the rest by name")
    }

    /// The held observation delivers books + pins + the daily mark, and
    /// the row faces compose from a real store (tags one-shot).
    @Test func theShelfObservationDeliversBooksPinsAndTheDailyMark() async throws {
        try await withEditorWorld { session, _ in
            let (bookID, pinnedID) = try await session.runner.run { ops -> (String, String) in
                let journal = try ops.createReading(
                    name: "Journal", kind: .curated, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(journal.id)
                let pinned = try ops.createReading(name: "Essays", kind: .curated)
                try ops.setShelfPinned(pinned.id, pinned: true)
                return (journal.id, pinned.id)
            }
            let model = MobileShelfViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.books.count < 2 || model.dailyBookID == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.books.count == 2)
            #expect(model.pins == [pinnedID])
            #expect(model.dailyBookID == bookID)
            #expect(model.orderedBooks.map(\.reading.id) == [pinnedID, bookID],
                    "the pinned book leads; the journal follows")
            #expect(model.rowMeta(for: model.orderedBooks[1]) == "0 entries · daily")
        }
    }

    // MARK: - The Today door (the Phase 8 A1-class pins, re-pointed)

    /// THE PIN (Phase 13c batch 1D's class sweep, third instance —
    /// re-pointed from the retired capture door): a phone-minted day's
    /// entry belongs in the daily journal book too, and re-opening the
    /// day mints no second membership (the notebook rule's door is
    /// idempotent on both halves).
    @Test func theTodayDoorJoinsTheDailyJournalBook() async throws {
        try await withEditorWorld { session, db in
            let book = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Journal", kind: .curated, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(book.id)
                return book.id
            }
            let model = MobileShelfViewModel(session: session)

            let postID = try #require(await model.openToday(day: "2026-08-03"))

            let members = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT post_id FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [book])
            }
            #expect(members == [postID], "the minted entry must be shelved")
            #expect(model.lastReport == nil, "a clean shelving says nothing")

            let again = await model.openToday(day: "2026-08-03")
            #expect(again == postID, "the notebook rule: one entry per day")
            #expect(try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?",
                    arguments: [book])
            } == 1)
        }
    }

    /// The mint is NEVER blocked by shelving; with no daily book
    /// designated the shared door CREATES AND PINS the Journal book (the
    /// author's 13d #37(iii) ruling); and every reportable outcome has
    /// phone wording pointing at the Mac. (Re-pointed from the retired
    /// capture door, wording byte-carried.)
    @Test func theTodayMintIsNeverBlockedAndCreatesThePinnedJournal() async throws {
        try await withEditorWorld { session, db in
            let model = MobileShelfViewModel(session: session)

            let postID = try #require(await model.openToday(day: "2026-08-03"))
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM container WHERE id = ?", arguments: [postID])
            } == postID, "the entry always opens")
            #expect(model.lastReport == nil, "nothing to explain — it is on the shelf")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL")
            } == 1, "the Journal book was created by the shared ensure")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL
                    """, arguments: [postID])
            } == 1, "…and the day's entry is in it")

            #expect(MobileTodayDoor.shelvingNote(.shelved(readingID: "r")) == nil)
            #expect(MobileTodayDoor.shelvingNote(.alreadyDecided) == nil)
            #expect(MobileTodayDoor.shelvingNote(.bookFinished)?.contains("finished") == true)
            #expect(MobileTodayDoor.shelvingNote(.bookAtCapacity)?.contains("full") == true)
            #expect(MobileTodayDoor.shelvingNote(.wrongKind)?.contains("smart") == true)
            #expect(MobileTodayDoor.shelvingNote(.refused("nope"))?.contains("nope") == true)
        }
    }

    /// A membership the author REMOVED stays removed — the Today door
    /// must never re-shelve it. (Re-pointed from the retired capture
    /// door.)
    @Test func theTodayDoorNeverReShelvesAnEntryTheAuthorRemoved() async throws {
        try await withEditorWorld { session, db in
            let model = MobileShelfViewModel(session: session)
            let book = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Journal", kind: .curated, profile: "journal")
                try ops.setDailyJournalBook(book.id)
                return book.id
            }
            let postID = try #require(await model.openToday(day: "2026-08-03"))
            try await session.runner.run { ops in
                try ops.removePostFromReading(postID, from: book)
            }

            _ = await model.openToday(day: "2026-08-03")

            let rows = try await db.read { db in
                try Row.fetchAll(
                    db,
                    sql: "SELECT deleted_at FROM reading_post WHERE reading_id = ?",
                    arguments: [book])
                    .map { $0["deleted_at"] as String? }
            }
            #expect(rows.count == 1, "no second membership row")
            #expect(rows.first ?? nil != nil, "her removal stands")
        }
    }

    // MARK: - The book list (chapters honored)

    /// The book list groups by the assembly's OWN section transitions
    /// (never a re-sort), names rows through the ONE display brain, and
    /// shows tag-section leaves.
    @Test func theBookListGroupsByTheAssemblysOwnSections() async throws {
        try await withEditorWorld { session, _ in
            let readingID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "The Book", kind: .curated)
                let one = try ops.createSection(in: book.id, name: "Openings")
                let two = try ops.createSection(in: book.id, name: "Middles")
                for (index, section) in [(1, one.id), (2, one.id), (3, two.id)] {
                    let post = try ops.createPost(title: "ch\(index)")
                    _ = try ops.addPostToReading(post.id, to: book.id)
                    try ops.assignPostToSection(post.id, in: book.id, section: section)
                }
                let unfiled = try ops.createPost(title: nil, profile: .journal, entryDate: "2026-08-01")
                _ = try ops.addPostToReading(unfiled.id, to: book.id)
                return book.id
            }
            let model = MobileBookViewModel(session: session, readingID: readingID)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.entries.count < 4 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.reading?.name == "The Book")
            #expect(!model.truncated)
            let groups = model.groupedRows
            #expect(groups.map(\.section) == ["Openings", "Middles", nil],
                    "chapters in book order; unfiled rows carry no header")
            #expect(groups.map { $0.entries.count } == [2, 1, 1])
            let unfiledRow = try #require(groups.last?.entries.first)
            #expect(MobileBookViewModel.rowTitle(unfiledRow) == "2026-08-01",
                    "nameless notes show their date (the ONE display brain)")
            #expect(MobileBookViewModel.sectionLabel("life/goals") == "goals",
                    "tag-grouping sections show their leaf")
        }
    }

    // MARK: - The router (voice + background flush)

    /// The Settings flip is the shell router's ONE voice authority: it
    /// reaches the stored preference, `MobileEditorStyle`, and the OPEN
    /// surface (`applyVoiceChange`). The flip window is await-free
    /// (MainActor-atomic — the S1 round-2 posture).
    @Test func theVoiceFlipReachesPreferenceStyleAndTheOpenSurface() async throws {
        try await withEditorWorld { session, _ in
            let suite = "MobileShellTests-voice-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer {
                defaults.removePersistentDomain(forName: suite)
                MobileEditorStyle.voice = .terminal
            }

            let post = try await session.runner.run { ops in
                try ops.createPost(title: "voiced", profile: .journal, entryDate: "2026-08-03")
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Voiced text.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            let router = MobileShellRouter(defaults: defaults)
            #expect(router.voice == .terminal, "the preference's default leads")
            router.activeEditor = model

            // The flip window: synchronous end to end.
            router.setVoice(.study)
            #expect(router.voice == .study)
            #expect(MobileVoicePreference.current(defaults) == .study)
            #expect(MobileEditorStyle.voice == .study)
            let studyFont = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(studyFont == MobileEditorStyle.studyFace.body,
                    "the open surface follows the flip")
            router.setVoice(.terminal)
            let terminalFont = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(terminalFont == MobileEditorStyle.terminalFace.body)
        }
    }

    /// THE PIN, re-pointed from the retired capture router (`onDisappear`
    /// never fires on whole-app backgrounding): the background transition
    /// lands the S1 editor's pending text in the STORE before the sync
    /// round runs.
    @Test func theBackgroundTransitionLandsPendingTextInTheStore() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "mid-typing", profile: .journal, entryDate: "2026-08-03")
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Quick entry", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Typed, debounce not yet fired (the harness clock never
            // fires it) — exactly the state at a home-button press.
            typeEdit(
                model, storage,
                range: NSRange(location: ("Quick entry" as NSString).length, length: 0),
                replacement: ", typed right before backgrounding")
            #expect(model.autosave.isDirty)

            // The app-level background handler's exact routine.
            await performBackgroundFlush(editor: model, sync: nil)

            #expect(try await storedText(db, variantID: minted.variant.id)
                    == "Quick entry, typed right before backgrounding",
                    "the pending burst survives a background kill because it reached the store")
            #expect(!model.autosave.isDirty)
        }
    }
}
