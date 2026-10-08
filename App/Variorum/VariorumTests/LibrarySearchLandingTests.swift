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

    // MARK: - VX-86 — the whole matched phrase arms the bar (the 13o follow-up run, VX-83)

    /// Her report: *"also only the first word of what you searched is filled
    /// in"* — "sherlock holmes" landed armed as "Sherlock". FTS5 marks each
    /// term as its own run; the seed took the first run alone (§M3). Red on
    /// the pre-fix tree: the needle was "Sherlock".
    @Test func aTwoWordQueryArmsTheBarWithBothWordsAsWritten() {
        let marked = SearchComposer.snippetSegments("It was \u{2}Sherlock\u{3} \u{2}Holmes\u{3} who knocked")
        #expect(SearchLanding.findSeed(kind: .take, rendered: true, snippet: marked)
                == EditorFindSeed(needle: "Sherlock Holmes", steps: true),
                "the first CONTIGUOUS matched span (D-3) — both words, as written")
        let scattered = SearchComposer.snippetSegments("\u{2}Sherlock\u{3} said that \u{2}Holmes\u{3} was")
        #expect(SearchLanding.findSeed(kind: .take, rendered: true, snippet: scattered)
                == EditorFindSeed(needle: "Sherlock", steps: true),
                "control: scattered terms keep the first run (the bar holds no disjunction)")
    }

    @Test func theSearchStatesOwnPassageLandsTheWholePhrase() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let note = try session.operations.createPost(title: "Baker Street")
            _ = try session.operations.newBlock(in: note.id, text: "It was Sherlock Holmes who knocked first.")
            let suite = "vx86-landing-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            model.query = "sherlock holmes"
            await model.search()
            let line = try #require(model.searchState.groups.first?.lines.first)
            #expect(SearchLanding.findSeed(kind: line.kind, rendered: line.isRenderedTake, snippet: line.snippet)
                    == EditorFindSeed(needle: "Sherlock Holmes", steps: true),
                    "the search state's own passage hands the bar the whole phrase")
        }
    }

    // MARK: - VX-85 — the landed match never rests under the bar (the 13o follow-up run, VX-83)

    /// Where the landed line sits, against the SHOWN find bar: its top and
    /// bottom in the clip, the bar's bottom edge (the bar overlays the clip's
    /// top — measured on 27.0, said by `clip.contentInsets`), and the clip's
    /// unobscured bottom.
    private func placeUnderTheBar(
        of offset: Int, _ textView: NSTextView, _ scrollView: NSScrollView
    ) throws -> (top: Double, bottom: Double, barBottom: Double, viewBottom: Double, scrolled: Double) {
        let clip = scrollView.contentView
        let span = try #require(JumpPrimitive.lineSpan(ofOffset: offset, in: textView))
        let bar = try #require(scrollView.findBarView)
        let barInClip = clip.convert(bar.bounds, from: bar)
        return (span.top, span.bottom, Double(barInClip.maxY),
                Double(clip.bounds.maxY - clip.contentInsets.bottom), Double(clip.bounds.minY))
    }

    /// The band's two edges in Write (the comfort band's own numbers: the
    /// container's top air, `ComfortBand.bottomLines` of the base line).
    private func band(_ textView: NSTextView) -> (topAir: Double, bottomRoom: Double) {
        (Double(textView.textContainerOrigin.y),
         Double(ComfortBand.bottomLines * TypewriterRoom.lineHeight(of: EditorDocument.baseFont)))
    }

    /// Her report: *"when you click onto a result, it looks like it wasn't
    /// working but it's because the search bar hides the result, which is at
    /// the top of the page."* The find seed's reveal landed the match's line
    /// FLUSH at the clip's top — the very strip the just-shown bar covers
    /// (§M2). Red on the pre-fix tree: the line's top sat ~32 pt above the
    /// bar's bottom edge.
    @Test func aFarMatchRestsInTheComfortBandBelowTheShownBar() async throws {
        var blocks = (0..<60).map { "paragraph \($0) carries plain words for the measure" }
        blocks[45] = "the harbor at dawn"
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: blocks, landingAt: 45, find: EditorFindSeed(needle: "harbor", steps: true)
            ) { _, textView, scrollView, offset in
                let text = textView.string as NSString
                let match = text.range(of: "harbor", options: .literal,
                                       range: NSRange(location: offset, length: text.length - offset))
                #expect(textView.selectedRange() == match, "the landing selected the match")
                #expect(scrollView.isFindBarVisible)
                let place = try placeUnderTheBar(of: match.location, textView, scrollView)
                let edges = band(textView)
                #expect(place.top >= place.barBottom + edges.topAir - 1,
                        "the line rests in the band's top air BELOW the bar, never under it: \(place)")
                #expect(place.bottom <= place.viewBottom - edges.bottomRoom + 1,
                        "…with the band's room below: \(place)")
            }
        }
    }

    /// The same defect with no scroll at all: a match in a note's FIRST line
    /// (a one-block journal entry — the ordinary case) sits at the page's top,
    /// under the 32-pt bar, and the reveal's visibility guard called it on
    /// screen. Red on the pre-fix tree.
    @Test func aMatchInTheNotesFirstLineIsNotHiddenUnderTheBar() async throws {
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: ["Sherlock Holmes knocked at the door", "a second block", "a third block"],
                landingAt: 0, find: EditorFindSeed(needle: "Holmes", steps: true)
            ) { _, textView, scrollView, _ in
                let match = (textView.string as NSString).range(of: "Holmes")
                #expect(textView.selectedRange() == match)
                let place = try placeUnderTheBar(of: match.location, textView, scrollView)
                #expect(place.top >= place.barBottom + band(textView).topAir - 1,
                        "the first line clears the bar, with the band's air: \(place)")
            }
        }
    }

    /// Control (green on both trees): a match already resting mid-band does
    /// not move the page — the band never lurches a line she can see.
    @Test func aMatchAlreadyRestingMidPageLeavesThePageAlone() async throws {
        let blocks = (0..<12).map { $0 == 4 ? "the harbor at dawn" : "plain block \($0)" }
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: blocks, landingAt: 4, find: EditorFindSeed(needle: "harbor", steps: true)
            ) { _, textView, scrollView, _ in
                let place = try placeUnderTheBar(of: textView.selectedRange().location, textView, scrollView)
                #expect(abs(place.scrolled) < 0.5, "the page did not move: \(place)")
                #expect(place.top >= place.barBottom + band(textView).topAir - 1)
            }
        }
    }

    /// The non-stepping arm (an unrendered take's hit — the words are not on
    /// the page) selects nothing, but the caret seed still revealed the landed
    /// block FLUSH at the top — under the bar this arm shows too. Red on the
    /// pre-fix tree.
    @Test func anUnrenderedSeedsBlockRestsBelowTheShownBar() async throws {
        let blocks = (0..<60).map { "paragraph \($0) carries plain words for the measure" }
        try await withFindPasteboard {
            try await withLandedEditor(
                blocks: blocks, landingAt: 45, find: EditorFindSeed(needle: "hidden", steps: false)
            ) { _, textView, scrollView, offset in
                #expect(textView.selectedRange() == NSRange(location: offset, length: 0),
                        "nothing selected — the caret rests at the landed block")
                let place = try placeUnderTheBar(of: offset, textView, scrollView)
                #expect(place.top >= place.barBottom + band(textView).topAir - 1,
                        "the landed block's first line clears the bar: \(place)")
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
