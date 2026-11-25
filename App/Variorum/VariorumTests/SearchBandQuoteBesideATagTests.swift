//
//  SearchBandQuoteBesideATagTests.swift
//  VariorumTests
//
//  **VX-1069 — her ruling of P-980-B1-1, option (b) (the Nov 24 sitting;
//  QUESTIONS #276 addendum 2): words that fold to nothing drop out of the
//  band's QUOTE when a tag is there.** `— #tag` read "“—” — 2 notes · #tag"
//  while `#tag` alone quotes nothing — the ANSWER was already the tag's
//  (VX-954's `SearchComposer.asksWords`); only the quote was left over.
//
//  The mechanism (traced in `notes/plans/fixes/vx-1082-nov-24-fixes.md`,
//  BATCH S): the quote is `SearchFieldWords.words(of:)` — every token that is
//  not a tag — read by the Library's question and the book's band alike, so a
//  dash beside a tag was quoted as the question's words and led the counts
//  with "— ".
//
//  RED on the pre-fix tree: the model pins (the quote for every folded shape
//  beside a tag; a real word keeping only itself) and the MOUNTED band's
//  counts line (what the band DREW — `LibrarySearchDrawnOracle`'s
//  `.countsLine`, DEBUG), both voices. GUARDS, green on both sides: a field
//  with no tag quotes what she typed — R-980-5's says-why field keeps its
//  quote byte for byte.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1069 — words that fold to nothing drop out of the band's quote beside a tag", .serialized)
struct SearchBandQuoteBesideATagTests {
    /// VX-888's six shapes (the VX-980 run's batch 1) — every one IS `#flora`.
    static let foldedBesideATag = ["— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora"]

    // MARK: - The quote (pure)

    /// Every folded shape beside a tag quotes NOTHING — the Library's question
    /// and the book's band read the one rule — so the counts lead bare, as
    /// `#flora`'s do. RED on the pre-fix tree (each quoted its punctuation).
    @Test func aFoldedWordBesideATagLeavesNoQuote() throws {
        let alone = try #require(LibrarySearchQuestion.read("#flora"))
        #expect(alone.words.isEmpty, "the tag alone quotes nothing (the premise)")
        for text in Self.foldedBesideATag {
            let question = try #require(LibrarySearchQuestion.read(text))
            #expect(question.words.isEmpty, "\(text): the Library's band quotes nothing, read \"\(question.words)\"")
            #expect(LibrarySearchFace.countsLead("2 notes", afterEcho: !question.words.isEmpty) == "2 notes",
                    "\(text): the counts lead bare, as #flora's do")
            let book = try #require(BookSearchModel.read(text, visibility: .living))
            #expect(book.words.isEmpty, "\(text): the book's band reads the same rule, read \"\(book.words)\"")
        }
    }

    /// Beside a tag, a real word keeps ONLY itself in the quote — the folded
    /// words beside it drop out (the ruling's letter: words that fold to
    /// nothing, when a tag is there). A quoted phrase that holds real words
    /// rides whole. RED on the pre-fix tree.
    @Test func besideATagARealWordKeepsOnlyItself() throws {
        let cases: [(text: String, quote: String)] = [
            ("red — #flora", "red"),
            ("— red #flora", "red"),
            ("red + #flora", "red"),
            ("# red #flora", "red"),
            ("\"a + b\" — #flora", "\"a + b\""),
            ("red — blue #a #b", "red blue"),
        ]
        for (text, quote) in cases {
            #expect(LibrarySearchQuestion.read(text)?.words == quote, "\(text) → \"\(quote)\"")
            #expect(BookSearchModel.read(text, visibility: .living)?.words == quote, "\(text) on the book's band")
        }
    }

    /// GUARD (green on both trees): with NO tag the quote is what she typed —
    /// the ruling reaches the quote only beside a tag. R-980-5's field of
    /// only punctuation keeps its quote ("“—” — nothing found") byte for byte.
    @Test func withNoTagTheQuoteIsWhatSheTyped() {
        for text in ["—", "+", "#", "— +", "\"—\"", "red —", "red", "\"a + b\""] {
            #expect(LibrarySearchQuestion.read(text)?.words == text, "\(text)")
            #expect(BookSearchModel.read(text, visibility: .living)?.words == text, "\(text) on the book's band")
        }
    }

    // MARK: - What the band DRAWS

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

    /// The MOUNTED Library's band, both voices: every folded shape beside
    /// `#flora` draws exactly the counts line `#flora` draws — no dash before
    /// the counts, because nothing is quoted. RED on the pre-fix tree (the
    /// band drew "— 1 note" — the dash of the quote's separator). The
    /// tagless `—` keeps R-980-5's face: quoted, "— nothing found".
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theBandDrawsTheTagAlonesCountsLine(voice: ThemeVoice) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1069))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let harbor = try ops.createPost(title: "Harbor log")
            _ = try ops.newBlock(in: harbor.id, text: "the lighthouse kept its watch")
            let flora = try ops.createTag(name: "flora")
            _ = try ops.applyTag(flora.id, toPost: harbor.id)
            try ops.setThemeVoice(voice)
            let suite = "vx-1069-band-quote-\(UUID().uuidString)"
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
            await Self.settle(window, hosting, 1.0)
            @MainActor func ask(_ text: String) async {
                model.query = text
                await model.search()
                await Self.settle(window, hosting)
            }

            await ask("#flora")
            let alone = try #require(LibrarySearchDrawnOracle.drawn(.countsLine, in: session),
                                     "\(voice): #flora's band draws its counts")
            #expect(!alone.hasPrefix("\u{2014}"), "\(voice): the tag alone's counts lead bare (the premise): \(alone)")
            for text in Self.foldedBesideATag {
                await ask(text)
                #expect(LibrarySearchDrawnOracle.drawn(.countsLine, in: session) == alone,
                        "\(voice) \(text): the band draws #flora's counts line, not \(LibrarySearchDrawnOracle.drawn(.countsLine, in: session) ?? "nil")")
            }

            // GUARD: R-980-5's tagless field keeps its quote and its dash.
            await ask("—")
            let tokens = theme.tokens(for: .light)
            #expect(LibrarySearchDrawnOracle.drawn(.countsLine, in: session)
                    == tokens.chromeLabel(LibrarySearchFace.countsLead(LibrarySearchCopy.nothingFound, afterEcho: true)),
                    "\(voice): the tagless — still reads “—” — nothing found")
        }
        #endif
    }
}
