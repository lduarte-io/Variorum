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
            _ name: String, kind: ReadingKind = .book, profile: String? = nil,
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
        // 13i-a (ladder R1 M-2): THE daily Journal wears 'daily' — the
        // trait keeps its entries unit.
        let daily = book("Journal", profile: "daily", posts: 1)
        #expect(MobileShelfFaces.meta(for: daily, tagPaths: [], isDaily: true)
            == "1 entry · daily", "the 'daily' marker HAS the journal trait")
        #expect(MobileShelfFaces.meta(for: journal, tagPaths: ["dreams"], isDaily: true)
            == "1 entry · #dreams · daily", "tags outrank the daily marker")

        let smart = book(
            "reading notes", kind: .gathering, spec: #"{"tags":["books"]}"#)
        // 13i-a: rules hold tag IDs, so the paths arrive RESOLVED
        // (`Queries.ruleTagPaths` at the load) — the face consumes the map.
        #expect(MobileShelfFaces.tagPaths(
                    for: smart, curatedTags: [:], ruleTags: [smart.reading.id: ["books"]])
                == ["books"],
                "a gathering's tags are its rule's, resolved")
        #expect(MobileShelfFaces.meta(for: smart, tagPaths: ["books"], isDaily: false)
            == "smart · #books", "derived membership is never a count")
    }

    /// LK5's rider: ✓ finished is a STATE riding the NAME (the Mac
    /// grammar), never a meta stat.
    @Test func finishedIsAStateOnTheNameNeverAMetaStat() throws {
        let finished = Queries.ShelfBook(
            reading: Reading(
                id: "p", ownerId: nil, name: "Poems", kind: .book, profile: nil,
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
                    id: id, ownerId: nil, name: name, kind: .book, profile: profile,
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
                    name: "Journal", kind: .book, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(journal.id)
                let pinned = try ops.createReading(name: "Essays", kind: .book)
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
                    name: "Journal", kind: .book, profile: "journal",
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
    /// author's 13d #37(iii) ruling); and every reportable outcome names
    /// a PHONE road (parity C2 — inventory #8/#9/#10's sanctioned pin
    /// flips: the book-details surface holds finish/reopen and the daily
    /// designation, so no note redirects to the Mac).
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
            #expect(MobileTodayDoor.shelvingNote(.bookFinished)?.contains("book details") == true,
                    "the reopen note names the phone's own door")
            #expect(MobileTodayDoor.shelvingNote(.bookAtCapacity)?.contains("full") == true)
            #expect(MobileTodayDoor.shelvingNote(.bookAtCapacity)?.contains("daily journal") == true,
                    "the full-book note names the designation road")
            #expect(MobileTodayDoor.shelvingNote(.wrongKind)?.contains("smart") == true)
            #expect(MobileTodayDoor.shelvingNote(.refused("nope"))?.contains("nope") == true)
            // Parity C2 (inventory #8/#9/#10): no shelving note redirects.
            for note in [
                MobileTodayDoor.shelvingNote(.bookFinished),
                MobileTodayDoor.shelvingNote(.bookAtCapacity),
                MobileTodayDoor.shelvingNote(.wrongKind),
                MobileTodayDoor.shelvingNote(.refused("nope")),
            ] {
                #expect(note?.contains("Mac") == false, "no platform name in a refusal")
            }
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
                    name: "Journal", kind: .book, profile: "journal")
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

    // MARK: - + New Note (P33 — the shelf's twin of the Library door)

    /// P33's flip (parity A3): the shelf mints through the ONE shared
    /// door — a NAMELESS bookless note (the Mac ⌘N semantics the Library
    /// pin already carries), reading the same door word, so the twins
    /// cannot fork in path or register.
    @Test func theShelfNewNoteDoorIsTheLibrarysTwin() async throws {
        try await withEditorWorld { session, db in
            let model = MobileShelfViewModel(session: session)
            let postID = try #require(await model.newNote())
            let stored = try await db.read { db in
                try Row.fetchOne(
                    db, sql: """
                        SELECT title,
                               (SELECT COUNT(*) FROM reading_post
                                WHERE post_id = container.id
                                  AND deleted_at IS NULL) AS memberships
                        FROM container WHERE id = ?
                        """,
                    arguments: [postID]).map(CopiedRow.init)
            }
            #expect((stored?["title"] as String?) == nil, "no stored placeholder title")
            #expect((stored?["memberships"] as Int?) == 0, "a BOOKLESS mint (the Pool's filter)")
            #expect(MobileNewNoteDoor.doorTitle == "+ New Note")
            #expect(VoiceTokens.terminalLight.chromeLabel(MobileNewNoteDoor.doorTitle)
                    == "+ new note", "the door renders voice-cased on both tabs")
        }
    }

    // MARK: - The book list (chapters honored)

    /// The book list groups by the assembly's OWN section transitions
    /// (never a re-sort), names rows through the ONE display brain, and
    /// shows tag-section leaves.
    @Test func theBookListGroupsByTheAssemblysOwnSections() async throws {
        try await withEditorWorld { session, _ in
            let readingID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "The Book", kind: .book)
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
            // S3 ladder (MINOR 2): the flip reaches editors through the
            // liveness authority's registration set, never a single slot.
            await router.editors.register(model, tab: .shelf)

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
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)
            await model.loadOnce()

            // Typed, debounce not yet fired (the harness clock never
            // fires it) — exactly the state at a home-button press.
            typeEdit(
                model, storage,
                range: NSRange(location: ("Quick entry" as NSString).length, length: 0),
                replacement: ", typed right before backgrounding")
            #expect(model.autosave.isDirty)

            // The app-level background handler's exact routine (S3
            // ladder MAJOR 1: the flush targets are the authority's own
            // registration set; the two-editor arms ride
            // `MobileLivenessTests`).
            await performBackgroundFlush(editors: editors, sync: nil)

            #expect(try await storedText(db, variantID: minted.variant.id)
                    == "Quick entry, typed right before backgrounding",
                    "the pending burst survives a background kill because it reached the store")
            #expect(!model.autosave.isDirty)
        }
    }

    @Test func theBuiltProductIsIPhoneOnlyAndPortraitOnly() {
        // THE PLATFORM RULING (the gate sitting, verbatim: "we CANNOT
        // declare ipad capability or it doesn't let your app be portrait
        // only"; batch A1 item 2). The pin reads the BUILT product's
        // Info.plist — the hosted suite's Bundle.main IS the app — so any
        // future pbxproj drift (a template re-add of "1,2", a landscape
        // orientation returning) fails here, not on her phone.
        let bundle = Bundle.main
        let families = bundle.object(forInfoDictionaryKey: "UIDeviceFamily")
            as? [Int]
        #expect(families == [1],
                "iPhone-only: TARGETED_DEVICE_FAMILY must be 1 — declaring iPad forbids portrait-only")
        let orientations = bundle.object(
            forInfoDictionaryKey: "UISupportedInterfaceOrientations") as? [String]
        #expect(orientations == ["UIInterfaceOrientationPortrait"],
                "portrait-locked: no landscape orientation may be declared")
        #expect(bundle.object(
            forInfoDictionaryKey: "UISupportedInterfaceOrientations~ipad") == nil,
                "no iPad-specific declaration of any kind")
    }
}
