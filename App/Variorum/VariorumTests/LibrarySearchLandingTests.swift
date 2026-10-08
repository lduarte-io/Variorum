//
//  LibrarySearchLandingTests.swift
//  VariorumTests
//
//  **13o U2 — LAND-AT-MATCH** (D6; the mockup's shared section, her ruled
//  behavior: *"Clicking a passage opens the note at that block with the
//  match selected and the find bar armed, so ⌘G keeps stepping"*). Pinned at
//  the FEATURE-API level, the brief's letter:
//
//  - the seed a passage hands over is its first matched run AS WRITTEN (an
//    accent-folded query still lands on the accented words), stepping only
//    in the take the note shows;
//  - the shell's park carries the seed WITH its block — expired by the next
//    navigation, spent with the landing (never a second park);
//  - the arriving Write editor, seeded exactly as `PostDetailView.jump`
//    seeds it, SELECTS the match at the landed block and shows the bar, and
//    `performFind(.next)` — the ⌘G door's own road — steps to the next
//    occurrence; an unrendered take's seed arms the bar and selects nothing.
//
//  New road, new pins: on the pre-change tree they do not compile
//  (`EditorFindSeed`, `pendingFindSeed`, `landingFind` did not exist; a block
//  hit landed its caret at the block's start and the bar stayed shut).
//
//  FIND-PASTEBOARD DISCIPLINE (the L6 ruling): the machine-global find
//  pasteboard is saved and put back by every pin that touches it.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — land-at-match (the find seed)", .serialized)
struct LibrarySearchLandingTests {
    // MARK: - The seed (pure)

    @Test func aPassageSeedsItsFirstMatchedRunAsWritten() {
        let marked = SearchComposer.snippetSegments("…a \u{2}Café\u{3} by the \u{2}harbor\u{3}…")
        #expect(SearchLanding.findSeed(kind: .take, rendered: true, snippet: marked)
                == EditorFindSeed(needle: "Café", steps: true),
                "the text as written — the bar's literal search meets it")
        #expect(SearchLanding.findSeed(kind: .take, rendered: false, snippet: marked)
                == EditorFindSeed(needle: "Café", steps: false),
                "an unrendered take arms the bar without selecting (P-13o-U2-4)")
        #expect(SearchLanding.findSeed(kind: .blockName, rendered: false, snippet: marked) == nil,
                "a name's words are not in the prose to find")
        #expect(SearchLanding.findSeed(
            kind: .take, rendered: true, snippet: SearchComposer.snippetSegments("no marks")) == nil)
    }

    @Test func theNeedleIsFoundFromTheLandedBlockOnward() {
        let text = "the harbor at dawn\nlights on the Harbor wall\na third harbor"
        let second = (text as NSString).range(of: "lights").location
        #expect(FindSeedLanding.range(of: "harbor", in: text, from: 0) == NSRange(location: 4, length: 6))
        #expect(FindSeedLanding.range(of: "Harbor", in: text, from: second)
                == (text as NSString).range(of: "Harbor"), "literal first")
        #expect(FindSeedLanding.range(of: "HARBOR", in: text, from: second)
                == (text as NSString).range(of: "Harbor"), "then folded — the index's own sameness")
        #expect(FindSeedLanding.range(of: "cafe", in: "un café", from: 0) == NSRange(location: 3, length: 4))
        #expect(FindSeedLanding.range(of: "absent", in: text, from: 0) == nil)
        #expect(FindSeedLanding.range(of: "harbor", in: text, from: 999) == nil)
    }

    @Test func theSearchStatesOwnPassageCarriesTheAccentedWords() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let note = try session.operations.createPost(title: "Paris")
            _ = try session.operations.newBlock(in: note.id, text: "we met at the Café Bleu")
            let suite = "13o-u2-landing-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            model.query = "cafe "
            await model.search()
            let line = try #require(model.searchState.groups.first?.lines.first)
            #expect(SearchLanding.findSeed(kind: line.kind, rendered: line.isRenderedTake, snippet: line.snippet)
                    == EditorFindSeed(needle: "Café", steps: true),
                    "typed without its accent, it lands on the words as she wrote them (R-13o-11)")
        }
    }

    // MARK: - The shell carries it with the landing

    @Test func theSeedRidesThePark() {
        let router = ShellRouter()
        let seed = EditorFindSeed(needle: "harbor", steps: true)
        router.adopt(.post("X"), landing: "b2", find: seed)
        #expect(router.landing(for: "X") == "b2" && router.landingFind(for: "X") == seed)
        #expect(router.landingFind(for: "Y") == nil, "…and no other container's")
        router.spendLanding(for: "X")
        #expect(router.landingFind(for: "X") == nil, "spent with its landing")

        router.adopt(.post("X"), landing: "b2", find: seed)
        router.adopt(.library)
        #expect(router.landingFind(for: "X") == nil, "expired by the next navigation")
        router.adopt(.post("X"), landing: "b4")
        #expect(router.landingFind(for: "X") == nil, "a landing that names no words carries none")
    }

    // MARK: - The arriving editor (feature API)

    private func pump(_ turns: Int = 6) {
        for _ in 0..<turns { RunLoop.main.run(until: Date().addingTimeInterval(0.03)) }
    }

    /// An editor mounted in a window and seeded EXACTLY as `PostDetailView
    /// .jump` seeds it — the landed block's surface offset as the caret seed,
    /// the passage's words as the find seed — before its first render.
    private func withLandedEditor(
        blocks: [String], landingAt index: Int, find: EditorFindSeed,
        _ body: @MainActor (EditorViewModel, EditorTextView, NSScrollView, Int) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                start.addingTimeInterval(Double(tick.withValue { v -> Int in defer { v += 1 }; return v }))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "T")
            for text in blocks {
                _ = try session.operations.newBlock(in: post.id, text: text, registeringUndo: false)
            }
            let model = EditorViewModel(session: session, postID: post.id)
            model.tailIdleSleep = { _ in throw CancellationError() }
            model.longBlockLayout.sleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let surfaceDelegate = EditorSurfaceDelegate(model: model)
            surfaceDelegate.wire(to: textView)
            let frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            scrollView.frame = frame
            let window = NSWindow(contentRect: frame, styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSView(frame: frame)
            window.contentView?.addSubview(scrollView)
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil) }
            model.attach(textView: textView, scrollView: scrollView)

            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: post.id),
                 try Queries.containerHeader(db, containerID: post.id))
            }
            let offset = BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: index).location
            model.pendingCaretSeed = offset
            model.pendingFindSeed = find
            model.adoptHeader(header)
            model.applyProjection(slots)
            pump()
            try await body(model, textView, scrollView, offset)
            _ = surfaceDelegate
        }
    }

    private func withFindPasteboard(_ body: () async throws -> Void) async rethrows {
        let board = NSPasteboard(name: .find)
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        try await body()
    }

    @Test func theMatchIsSelectedAtItsBlockAndCommandGStepsOnward() async throws {
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: ["the harbor at dawn", "lights on the harbor wall", "a third harbor"],
                landingAt: 1, find: EditorFindSeed(needle: "harbor", steps: true)
            ) { model, textView, scrollView, offset in
                let text = textView.string as NSString
                let inBlock = text.range(
                    of: "harbor", options: .literal,
                    range: NSRange(location: offset, length: text.length - offset))
                #expect(textView.selectedRange() == inBlock,
                        "the match is SELECTED in the landed block — not the first block's")
                #expect(scrollView.isFindBarVisible, "the find bar is armed")
                #expect(NSPasteboard(name: .find).string(forType: .string) == "harbor",
                        "⌘E's own road made it the search string")

                // ⌘G — the registry's find-next door runs exactly this.
                #expect(model.performFind(.next))
                pump()
                let third = text.range(
                    of: "harbor", options: .literal,
                    range: NSRange(location: inBlock.upperBound, length: text.length - inBlock.upperBound))
                #expect(textView.selectedRange() == third, "⌘G steps onward to the next occurrence")
            }
        }
    }

    @Test func anUnrenderedTakesSeedArmsTheBarAndSelectsNothing() async throws {
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: ["first block", "the shown words", "last"],
                landingAt: 1, find: EditorFindSeed(needle: "hidden", steps: false)
            ) { _, textView, scrollView, offset in
                #expect(textView.selectedRange() == NSRange(location: offset, length: 0),
                        "the caret stays at the landed block — nothing on the page to select")
                #expect(scrollView.isFindBarVisible)
                #expect(NSPasteboard(name: .find).string(forType: .string) == "hidden",
                        "the bar holds the words, ready for the take that has them")
            }
        }
    }
}
