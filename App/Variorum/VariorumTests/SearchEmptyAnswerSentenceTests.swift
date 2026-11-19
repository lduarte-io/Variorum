//
//  SearchEmptyAnswerSentenceTests.swift
//  VariorumTests
//
//  **R-980-5 — her ruling of P-980-1 (the VX-980 run, batch 1;
//  `notes/plans/fixes/vx-980-her-rulings.md`, `vx-980-search-fixes.md`)**: a
//  Library search field holding ONLY punctuation or symbols, and no tag, SAYS
//  WHY its answer is empty instead of "Nothing matches" — her pick, "Say why",
//  with the provisional line "Search looks for words and numbers, so
//  punctuation on its own can't be found." The field still counts as a typed
//  search: the Library does not go to rest and the band keeps its honest
//  "nothing found".
//
//  The decision is core's ONE reading of the text half
//  (`SearchComposer.holdsNothingSearchable`); the sentence's one home is
//  `SearchAnswerCopy.emptyAnswer`, read by the Library's answer sheet and the
//  book's band (⌘K speaks no empty sentence, so nothing was added there).
//  These pins read what the sheet DREW (`LibrarySearchDrawnOracle`'s
//  `.emptyAnswer` slot, DEBUG), in both voices: the punctuation-only field
//  draws her line; a wordful search that finds nothing still draws "Nothing
//  matches."; `— #flora` is NOT this state — it is `#flora`, the Library's own
//  narrowed listing, so the sheet is not drawn at all.
//
//  BUILD pins for a ruled new face (not a bug row): before the ruling the
//  sheet drew "Nothing matches." for every empty answer.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("R-980-5 — a field of only punctuation says why its answer is empty", .serialized)
struct SearchEmptyAnswerSentenceTests {
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

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval = 0.6) async {
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

    // MARK: - The decision (pure)

    /// Her line, as ruled (provisional wording, listed in the run record).
    @Test func theLineIsHers() {
        #expect(SearchAnswerCopy.nothingSearchable
                == "Search looks for words and numbers, so punctuation on its own can't be found.")
    }

    /// The ONE decision both sheets read: her line exactly for a typed field
    /// of only punctuation or symbols with no tag (an armed day or book state
    /// beside it changes nothing); every other empty answer keeps the sheet's
    /// own silence.
    @Test func theDecisionIsTheCorePredicates() throws {
        let silence = LibraryCopy.nothingMatches
        for text in ["—", "+", "#", "…", "\"—\"", "— +", "$ ©"] {
            let question = try #require(LibrarySearchQuestion.read(text))
            #expect(SearchAnswerCopy.emptyAnswer(for: question.query, otherwise: silence)
                    == SearchAnswerCopy.nothingSearchable, "\(text)")
            let dated = try #require(LibrarySearchQuestion.read(
                text, range: SearchDayRange(field: .edited, start: "a", end: "b")))
            #expect(SearchAnswerCopy.emptyAnswer(for: dated.query, otherwise: silence)
                    == SearchAnswerCopy.nothingSearchable, "\(text) beside an armed day")
        }
        for text in ["zzyzx ", "red", "red +", "— #flora", "+ #flora", "#flora"] {
            let question = try #require(LibrarySearchQuestion.read(text))
            #expect(SearchAnswerCopy.emptyAnswer(for: question.query, otherwise: silence) == silence, "\(text)")
        }
        #expect(SearchAnswerCopy.emptyAnswer(for: SearchQuery(text: .not(.word("red"))), otherwise: silence) == silence,
                "a negation-only tree refuses in its own words")
        #expect(SearchAnswerCopy.emptyAnswer(for: nil, otherwise: BookSearchCopy.nothingRow) == BookSearchCopy.nothingRow)
    }

    // MARK: - What the Library's sheet DRAWS

    #if DEBUG
    private func drawn(_ slot: LibrarySearchDrawnSlot, _ session: AppSession) -> String? {
        LibrarySearchDrawnOracle.drawn(slot, in: session)
    }
    #endif

    private func ask(
        _ text: String, _ model: LibraryCatalogModel, _ window: NSWindow, _ hosting: NSView
    ) async {
        model.query = text
        await model.search()
        await Self.settle(window, hosting)
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theSheetSaysWhyForAFieldOfOnlyPunctuationAndNothingMatchesOtherwise(voice: ThemeVoice) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 985))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let harbor = try ops.createPost(title: "Harbor log")
            _ = try ops.newBlock(in: harbor.id, text: "the lighthouse kept its watch")
            let flora = try ops.createTag(name: "flora")
            _ = try ops.applyTag(flora.id, toPost: harbor.id)
            try ops.setThemeVoice(voice)
            let suite = "r-980-5-empty-answer-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
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
            let tokens = theme.tokens(for: .light)
            let reason = tokens.chromeLabel(SearchAnswerCopy.nothingSearchable)

            // A field of only punctuation or symbols: a typed search (the
            // sheet shows, the band says its honest "nothing found"), and
            // the sheet's empty row says WHY.
            for text in ["—", "+", "#", "— +"] {
                await ask(text, model, window, hosting)
                #expect(model.isSearching, "\(voice) \(text): still a typed search — the answer sheet shows")
                #expect(drawn(.emptyAnswer, session) == reason, "\(voice) \(text): the sheet draws her line")
                let echo = !(LibrarySearchQuestion.read(text)?.words.isEmpty ?? true)
                #expect(drawn(.countsLine, session)
                        == tokens.chromeLabel(LibrarySearchFace.countsLead(LibrarySearchCopy.nothingFound, afterEcho: echo)),
                        "\(voice) \(text): the band keeps its honest zero")
            }

            // A wordful search that finds nothing keeps "Nothing matches."
            await ask("zzyzx ", model, window, hosting)
            #expect(model.isSearching)
            #expect(drawn(.emptyAnswer, session) == tokens.chromeLabel(LibraryCopy.nothingMatches),
                    "\(voice): a real search that finds nothing keeps \"Nothing matches.\"")

            // `— #flora` is NOT this state: it IS `#flora` — the Library's
            // own listing, narrowed to the tagged note; no sheet is drawn.
            await ask("— #flora", model, window, hosting)
            #expect(!model.isSearching, "\(voice): — #flora takes the tag road")
            #expect(model.noteHits.map(\.id) == [harbor.id], "\(voice): the tagged note is listed")
            #expect(drawn(.emptyAnswer, session) == nil, "\(voice): no answer sheet, so no empty sentence")
        }
        #endif
    }
}
