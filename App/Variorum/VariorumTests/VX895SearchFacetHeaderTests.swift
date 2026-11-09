//
//  VX895SearchFacetHeaderTests.swift
//  VariorumTests (Mac)
//
//  **VX-895 (the VX-913 run, B1) — the answer sheet's group header follows
//  the picked facet.** Her Nov 7 walkthrough: the header over the results
//  ("Notes, with their passages" / "Blocks & scraps") did not track the facet
//  she picked — "clicking books resets it, depends on which one you just
//  clicked on… feels a bit random which one is up" — and the band read
//  "7 notes · 7 passages" while Blocks was picked.
//
//  THE TRACED MECHANISM (the B1 RECORD in `notes/plans/fixes/vx-913-freeze-
//  fixes.md`): the header draws `LibrarySearchModel.scope`, which was
//  `@ObservationIgnored`. A facet pick's read lands through
//  `LibrarySearchModel.land`, and the `@Observable` setters are
//  equality-gated, so when the matches are note BODIES (the everyday search)
//  All, Notes and Blocks list the same groups with the same counts — nothing
//  the sheet observes changes, its body never re-runs, and the header keeps
//  the words of the last facet that CHANGED the groups (Books lists none,
//  which is why a Books click "reset" it).
//
//  - **A — mounted, what the header DREW** (`LibrarySearchDrawnOracle`):
//    each pick is rendered BEFORE its read lands, as a click is. RED ON THE
//    PRE-FIX TREE at All → Blocks and at Blocks → Notes; Books → Blocks is
//    her "books resets it" tell (green on both).
//  - **B — the mechanism at the model seam:** the land that changes the
//    listed scope tells whoever read it. RED ON THE PRE-FIX TREE.
//  - **C — mounted, the band's counts guard:** the facets count differently
//    here, and the drawn line is the picked facet's own core numbers at every
//    pick (R-819-1). Expected GREEN ON BOTH TREES — the counts are observed;
//    the sighting's numbers were that facet's honest answer, so the counts
//    half of the ticket is recorded HOLLOW.
//
//  Red-on-old is a BEHAVIORAL revert of the fix line only (`@ObservationIgnored`
//  back on `LibrarySearchModel.scope`); the oracle stays.
//

import AppKit
import Dependencies
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-895 — the search sheet's group header follows the picked facet", .serialized)
struct VX895SearchFacetHeaderTests {
    /// The question every test asks — a whole word (the trailing space).
    private static let word = "lighthouse "

    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(13) }
                return value
            }
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval = 0.4) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    // MARK: - The worlds

    /// **The everyday search:** the word lives only in note BODIES — no
    /// title, no book name, no scrap — so All, Notes and Blocks list the same
    /// groups with the same counts (the bug's exact condition).
    private static func seedBodiesOnly(_ ops: Operations) throws {
        let harbor = try ops.createPost(title: "Harbor log")
        _ = try ops.newBlock(in: harbor.id, text: "the lighthouse kept its watch")
        _ = try ops.newBlock(in: harbor.id, text: "fog rolled over the lighthouse")
        let diary = try ops.createPost(title: "Keeper's diary")
        _ = try ops.newBlock(in: diary.id, text: "a lighthouse in winter")
        let other = try ops.createPost(title: "Shopping")
        _ = try ops.newBlock(in: other.id, text: "eggs and bread")
    }

    /// **The facets count differently here:** a note body, a book NAMED by
    /// the word and a scrap — All counts all three kinds, Notes the note,
    /// Blocks the note and the scrap, Books the book.
    private static func seedCountsDiffer(_ ops: Operations) throws {
        let harbor = try ops.createPost(title: "Harbor log")
        _ = try ops.newBlock(in: harbor.id, text: "the lighthouse kept its watch")
        _ = try ops.createReading(name: "Lighthouse Keepers", kind: .book)
        let heap = try ops.createPool(title: "Heap")
        _ = try ops.newBlock(in: heap.id, text: "a lighthouse scrap")
    }

    private func withLibrary<T>(
        seed: (Operations) throws -> Void,
        _ body: @MainActor (AppSession, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 895))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            try seed(session.operations)
            let suite = "vx-895-facet-header-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    /// The Library mounted in a window of its own, searching `word` under All.
    private func withMountedSearch(
        voice: ThemeVoice, seed: (Operations) throws -> Void,
        _ body: @MainActor (AppSession, LibraryCatalogModel, VoiceTokens, NSWindow, NSView) async throws -> Void
    ) async throws {
        #if DEBUG
        try await withLibrary(seed: seed) { session, model in
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            LibrarySearchDrawnOracle.reset()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1_100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1_100, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await Self.settle(window, hosting, 1.0)   // the mount's own read lands

            model.query = Self.word
            await model.search()
            await Self.settle(window, hosting, 0.8)
            #expect(model.isSearching && model.scope == .all, "premise: the answer sheet shows, under All")
            try await body(session, model, theme.tokens(for: .light), window, hosting)
        }
        #endif
    }

    /// **A facet click, as the screen meets it:** the pick (the picker's
    /// setter — `pickScope` then `search()`, the two steps its binding runs),
    /// the click's own render BEFORE the read lands, then the land's render.
    private func pick(
        _ scope: LibraryCatalogModel.Scope, _ model: LibraryCatalogModel,
        _ window: NSWindow, _ hosting: NSView
    ) async {
        model.pickScope(scope)
        await Self.settle(window, hosting)
        await model.search()
        await Self.settle(window, hosting)
    }

    private func header(_ scope: LibraryCatalogModel.Scope, _ tokens: VoiceTokens) -> String {
        tokens.chromeLabel(LibrarySearchCopy.groupsHeader(scope))
    }

    /// The band's counts line for `scope`, from the CORE's facet numbers
    /// (`Queries.searchCounts(…facet:…)` — R-819-1's one road), voiced.
    private func countsLine(
        _ scope: LibraryCatalogModel.Scope, _ session: AppSession, _ tokens: VoiceTokens
    ) async throws -> String {
        let question = try #require(LibrarySearchQuestion.read(Self.word))
        let wing = session.wing.currentID
        let counts = try await session.database.read { db in
            try Queries.searchCounts(db, query: question.query, facet: scope.facet, scope: SearchScope(wingID: wing))
        }
        let words = counts.map { LibrarySearchCopy.counts($0.kinds(.living)) } ?? LibrarySearchCopy.nothingFound
        return tokens.chromeLabel(LibrarySearchFace.countsLead(words, afterEcho: true))
    }

    #if DEBUG
    private func drawn(_ slot: LibrarySearchDrawnSlot, _ session: AppSession) -> String? {
        LibrarySearchDrawnOracle.drawn(slot, in: session)
    }
    #endif

    // MARK: - A — the drawn header follows every pick (RED ON OLD)

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theDrawnGroupsHeaderFollowsEveryFacetPick(voice: ThemeVoice) async throws {
        #if DEBUG
        try await withMountedSearch(voice: voice, seed: Self.seedBodiesOnly) { session, model, tokens, window, hosting in
            #expect(drawn(.groupsHeader, session) == header(.all, tokens), "\(voice): All's header is drawn")
            let allGroups = model.searchState.groups
            let allCounts = model.searchState.counts
            #expect(allGroups.count == 2, "premise: two notes answer (\(allGroups.count))")

            // All → Blocks: the same groups, the same counts — the bug's condition.
            await pick(.blocks, model, window, hosting)
            #expect(model.searchState.groups == allGroups && model.searchState.counts == allCounts,
                    "premise: under body-only matches Blocks lists exactly All's groups and counts")
            #expect(model.searchState.scope == .blocks, "premise: the MODEL holds the picked facet")
            #expect(drawn(.groupsHeader, session) == header(.blocks, tokens),
                    "\(voice): Blocks picked — the header names Blocks (drew \(drawn(.groupsHeader, session) ?? "nothing")) — RED ON OLD")
            let blocksLine = try await countsLine(.blocks, session, tokens)
            #expect(drawn(.countsLine, session) == blocksLine, "\(voice): the band says Blocks' own numbers")

            // Books lists no groups — the click that "reset" it.
            await pick(.books, model, window, hosting)
            #expect(model.searchState.groups.isEmpty, "premise: Books lists no groups")

            // Books → Blocks: the groups come back, so even the old sheet re-ran (her tell).
            await pick(.blocks, model, window, hosting)
            #expect(drawn(.groupsHeader, session) == header(.blocks, tokens),
                    "\(voice): after Books, Blocks' header — her 'books resets it' tell")

            // Blocks → Notes: the same groups again — the other direction.
            await pick(.posts, model, window, hosting)
            #expect(model.searchState.groups == allGroups, "premise: Notes lists exactly Blocks' groups")
            #expect(drawn(.groupsHeader, session) == header(.posts, tokens),
                    "\(voice): Notes picked — the header names the notes (drew \(drawn(.groupsHeader, session) ?? "nothing")) — RED ON OLD")
            let notesLine = try await countsLine(.posts, session, tokens)
            #expect(drawn(.countsLine, session) == notesLine, "\(voice): the band says Notes' own numbers")
        }
        #endif
    }

    // MARK: - B — the mechanism: the land tells the header's reader (RED ON OLD)

    @Test func aFacetPicksLandTellsWhoeverReadTheListedScope() async throws {
        try await withLibrary(seed: Self.seedBodiesOnly) { _, model in
            model.query = Self.word
            await model.search()
            #expect(model.searchState.scope == .all, "premise: listed under All")
            let groups = model.searchState.groups

            let told = LockIsolated(false)
            withObservationTracking {
                _ = LibrarySearchCopy.groupsHeader(model.searchState.scope)
            } onChange: {
                told.setValue(true)
            }
            model.pickScope(.blocks)
            await model.search()
            #expect(model.searchState.groups == groups, "premise: the land changed no group")
            #expect(model.searchState.scope == .blocks, "premise: the model holds the picked facet")
            #expect(told.value,
                    "the land that moved the listed scope from All to Blocks tells the header's reader — RED ON OLD")
        }
    }

    // MARK: - C — the band's counts follow every pick (expected green on both: the HOLLOW half)

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theDrawnCountsLineIsThePickedFacetsOwnNumbers(voice: ThemeVoice) async throws {
        #if DEBUG
        try await withMountedSearch(voice: voice, seed: Self.seedCountsDiffer) { session, model, tokens, window, hosting in
            var lines: [LibraryCatalogModel.Scope: String] = [:]
            for scope in [LibraryCatalogModel.Scope.all, .posts, .blocks, .books] {
                lines[scope] = try await countsLine(scope, session, tokens)
            }
            #expect(Set(lines.values).count == 4,
                    "premise: the four facets count differently here, so a stale line cannot pass (\(lines))")
            #expect(drawn(.countsLine, session) == lines[.all], "\(voice): All's numbers")
            for scope in [LibraryCatalogModel.Scope.posts, .blocks, .books, .all] {
                await pick(scope, model, window, hosting)
                #expect(drawn(.countsLine, session) == lines[scope],
                        "\(voice): \(scope) picked — the band says its own numbers (drew \(drawn(.countsLine, session) ?? "nothing"))")
            }
        }
        #endif
    }
}
