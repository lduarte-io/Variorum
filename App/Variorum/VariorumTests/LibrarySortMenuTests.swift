//
//  LibrarySortMenuTests.swift
//  VariorumTests
//
//  **18h batch 1 — the Library's `sort ▾`** (the 2026-09-12 use-report
//  round, her ledger row 10; ruling R-Q8's first half). Her words: *"i need
//  to be able to sort the library by time… the time alone is a minimum."*
//
//  RED ON OLD — a PRODUCT row, so these pins do not COMPILE on the
//  pre-change tree: `LibraryCatalogModel` had no `sort`/`direction` at all
//  (its listing was `Queries.searchCatalog`'s one hardwired
//  edited-newest-first order), took no `defaults:`, and there was no
//  `LibrarySortFace` to say the menu's words. The recorded compile errors
//  are in the batch record.
//
//  ── WHAT THESE PINS DRIVE (never hand-feed — the round's own lesson) ─────
//  Each order pin sets the sort through the model's OWN door (`setSort`,
//  which is what the menu's button calls) and then runs the model's OWN
//  `search()`, reading the hits the model landed. Nothing reconstructs a
//  query or an order by hand; the memory pins build a SECOND model over the
//  same injected defaults, which is the only honest way to ask whether
//  something was remembered.
//
//  Every model here gets its own scrubbed `UserDefaults(suiteName:)` —
//  suites and hand walks share the dev-store app's `.standard` (KnownIssues
//  R1-7), and a sort remembered by a walk must never reach a pin.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The Library's sort door and its memory (18h batch 1, row 10)", .serialized)
struct LibrarySortMenuTests {
    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "18h-1-sort-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// The same three notes as the core pin's fixture, so the orders are the
    /// same four distinct answers: created ↓ = C B A · edited ↓ = B A C ·
    /// entry date ↓ = A C B · title ↑ = C A B.
    private func fixture(_ session: AppSession) throws -> (a: String, b: String, c: String) {
        let a = try session.operations.createPost(title: "apple", entryDate: "2026-03-01")
        let b = try session.operations.createPost(title: "Banana", entryDate: "2026-01-15")
        let c = try session.operations.createPost(entryDate: "2026-02-20")
        let blockA = try session.operations.newBlock(in: a.id, text: "A")
        let blockB = try session.operations.newBlock(in: b.id, text: "B")
        let blockC = try session.operations.newBlock(in: c.id, text: "C")
        try session.operations.autosave(blockC.variant.id, text: "C typed", charDelta: 6)
        try session.operations.autosave(blockA.variant.id, text: "A typed", charDelta: 6)
        try session.operations.autosave(blockB.variant.id, text: "B typed", charDelta: 6)
        return (a.id, b.id, c.id)
    }

    /// A world whose clock TICKS — the two stamps must be able to differ.
    private func withTickingLibrary<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    @Test func theDoorOpensOnEditedNewestFirstAndEveryPickReordersTheListing() async throws {
        try await withTickingLibrary { session, _ in
            let f = try fixture(session)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("picks"))
            #expect(model.sort == .lastTouched, "the shipped order is the door's resting state")
            #expect(model.direction == .desc)
            await model.search()
            #expect(model.listedNoteIDs == [f.b, f.a, f.c], "edited, newest first")

            model.setSort(.createdAt)
            await model.search()
            #expect(model.listedNoteIDs == [f.c, f.b, f.a], "created, newest first")

            model.setSort(.entryDate)
            await model.search()
            #expect(model.listedNoteIDs == [f.a, f.c, f.b], "the day she stated")

            model.setSort(.title)
            await model.search()
            #expect(model.listedNoteIDs == [f.c, f.a, f.b], "A–Z on the displayed name")

            model.setDirection(.desc)
            await model.search()
            #expect(model.listedNoteIDs == [f.b, f.a, f.c], "Z–A")
        }
    }

    /// **Picking a sort takes its NATURAL direction** (the batch's call,
    /// recorded): newest-first for a stamp, A–Z for a name — what every
    /// list-sorting control in the OS does. An explicit direction pick then
    /// stands until the next sort pick.
    @Test func aSortPickTakesItsNaturalDirectionAndAnExplicitPickStands() async throws {
        try await withTickingLibrary { session, _ in
            _ = try fixture(session)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("natural"))
            model.setDirection(.asc)
            #expect(model.direction == .asc, "she asked for oldest first")
            model.setSort(.title)
            #expect(model.direction == .asc, "…and A–Z is title's natural direction anyway")
            model.setSort(.lastTouched)
            #expect(model.direction == .desc, "a stamp's natural direction is newest first")
            model.setDirection(.asc)
            model.setSort(.createdAt)
            #expect(model.direction == .desc)
        }
    }

    /// **Remembered, locally** (the `readModeOutlineShown` class — a posture,
    /// never a synced `setting`): a second model over the SAME defaults opens
    /// where she left it, and a model over a different store opens on the
    /// default — which is what proves the memory is the injected store's and
    /// not a global.
    @Test func theSortIsRememberedInTheInjectedDefaultsAndNowhereElse() async throws {
        try await withTickingLibrary { session, _ in
            _ = try fixture(session)
            let mine = try scrubbed("memory")
            let first = LibraryCatalogModel(session: session, defaults: mine)
            first.setSort(.title)
            first.setDirection(.desc)

            let second = LibraryCatalogModel(session: session, defaults: mine)
            #expect(second.sort == .title, "the door reopens where she left it")
            #expect(second.direction == .desc)

            let elsewhere = LibraryCatalogModel(session: session, defaults: try scrubbed("other"))
            #expect(elsewhere.sort == .lastTouched, "another store, the shipped default")
            #expect(elsewhere.direction == .desc)
        }
    }

    /// A stored value the app does not recognise (a hand-edited plist, an
    /// older build's key) reads as the default rather than crashing or
    /// leaving the list in a shape no menu row matches.
    @Test func anUnknownRememberedValueFallsBackToTheShippedOrder() async throws {
        try await withTickingLibrary { session, _ in
            let defaults = try scrubbed("garbage")
            defaults.set("by_vibes", forKey: LibraryCatalogModel.sortKey)
            defaults.set("sideways", forKey: LibraryCatalogModel.directionKey)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            #expect(model.sort == .lastTouched)
            #expect(model.direction == .desc)
        }
    }

    /// The menu's words are a pure rule, not literals in a body (P-8/F-0),
    /// and the direction reads in the sort's own language.
    @Test func theDoorsWordsAreTheFacesNotTheViews() {
        #expect(LibrarySortFace.offered == [.lastTouched, .createdAt, .entryDate, .title],
                "her four, in her order (edited · created · date · title)")
        #expect(LibrarySortFace.label(.lastTouched) == "edited")
        #expect(LibrarySortFace.label(.createdAt) == "created")
        #expect(LibrarySortFace.label(.entryDate) == "date")
        #expect(LibrarySortFace.label(.title) == "title")
        #expect(LibrarySortFace.directionLabel(.lastTouched, .desc) == "newest first")
        #expect(LibrarySortFace.directionLabel(.lastTouched, .asc) == "oldest first")
        #expect(LibrarySortFace.directionLabel(.title, .asc) == "A–Z")
        #expect(LibrarySortFace.directionLabel(.title, .desc) == "Z–A")
        // The door's own label says what the list is doing, so she never has
        // to open the menu to find out.
        #expect(LibrarySortFace.doorLabel(.lastTouched, .desc) == "edited · newest first")
        #expect(LibrarySortFace.doorLabel(.title, .asc) == "title · A–Z")
    }

    /// **Which stamp a ROW shows is the sort's own** (the brief's rule):
    /// edited under edited and title, created under created, the stated day
    /// under date. One rule, so the two row renderers cannot disagree.
    @Test func theRowsStampFollowsTheSort() {
        #expect(LibrarySortFace.stampSubject(.lastTouched) == .edited)
        #expect(LibrarySortFace.stampSubject(.title) == .edited,
                "a name order says nothing about time, so the useful stamp is the edit")
        #expect(LibrarySortFace.stampSubject(.createdAt) == .created)
        #expect(LibrarySortFace.stampSubject(.entryDate) == .dated)
        #expect(LibrarySortFace.stampSubject(.lastMajorRevision) == .edited,
                "the vocabulary's unoffered case still answers, never crashes")
    }

    /// The header carries ONE sort door, and it is the voiced menu (never a
    /// system picker beside the two that are there).
    @Test func theHeaderCarriesOneVoicedSortDoor() async throws {
        try await withTickingLibrary { session, _ in
            _ = try fixture(session)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("door"))
            let composition = SurfaceComposition.text(
                of: LibrarySortMenu(
                    tokens: VoiceTokens.terminalLight, sort: model.sort,
                    direction: model.direction, onPick: { _ in }, onDirection: { _ in }).body)
            #expect(composition.contains("VoicedMenu"),
                    "the chrome vocabulary's own control (P-8), not a system picker")
            #expect(composition.contains("edited · newest first"),
                    "the door says what the list is doing")

            // …and it is really IN the header, not merely constructible: the
            // catalog's own body composes it.
            let catalog = LibraryCatalogView(
                session: session, model: model, library: LibraryViewModel(session: session),
                tags: TagsViewModel(session: session), onOpen: { _ in })
            // A reflection read sees the view TYPE in the header's tree; WHERE
            // it stands is the rule below, and what it looks like is the
            // walk's capture.
            #expect(SurfaceComposition.text(of: catalog.body).contains("LibrarySortMenu"),
                    "the catalog's header composes the sort door")

            // Where it stands is a RULE, not an `if` a pin cannot reach
            // (P-1's doctrine: gating is data). The Timeline mode is an
            // order already, so a sort door there could not act (P-2).
            #expect(model.showsSortDoor, "List mode offers the door")
            model.mode = .notes
            #expect(model.showsSortDoor, "so does her Apple-Notes-shaped list")
            model.mode = .timeline
            #expect(!model.showsSortDoor, "the Timeline keeps its own order")
        }
    }
}
