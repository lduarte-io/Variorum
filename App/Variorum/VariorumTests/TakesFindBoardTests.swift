//
//  TakesFindBoardTests.swift
//  VariorumTests
//
//  18l-c UNIT U7 — SEARCH IN TAKES on a REAL mounted board (the
//  `TakesArticleWatchTests` harness: a real window, a real hosting view, the
//  article's real `NSScrollView`). What these hold:
//
//  - **LEDGER ROW 7, TRACED** (her report: *"even though your cursor is
//    placed, tapping keys won't make you edit (i.e. the take that you are
//    navigated to isn't active…)"*): the entry ring can land on a take whose
//    row the lazy column has not built — the authority says LIVE, and AppKit
//    has no text view to hold the keyboard;
//  - **the design brief's decision 6, its answer**: a find step makes the
//    match's take LIVE with the match SELECTED and REVEALED through the one
//    landing authority — and the keyboard follows the Write bar's convention
//    (⌘G from the board: the take takes it; ⏎ in the field: the field keeps
//    it; Esc: it goes back to the take, her place kept) — so she can TYPE;
//  - R-18l-10: an off-scope match is COUNTED on its block, and stepping onto
//    it EXPANDS that block's fan and selects the match in its card;
//  - decision 7: a read pane wears its matches (the attributed-string paint);
//  - P1: a settle recounts only the takes whose text moved.
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
@Suite("18l-c U7 — search in Takes, on a mounted board", .serialized)
struct TakesFindBoardTests {

    // MARK: - Harness (`TakesArticleWatchTests`' pattern)

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func pane(_ variantID: String, role: String = "article", in view: NSView) -> PaneTextView? {
        panes(in: view).first { $0.identifier?.rawValue == "pane:\(role)|\(variantID)" }
    }

    /// Any pane showing this take, whatever its role (a fan card is "mini" or
    /// "card" by style).
    private func anyPane(_ variantID: String, in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasSuffix("|\(variantID)") == true }
    }

    private func articleScrollView(in root: NSView) -> NSScrollView? {
        guard let pane = panes(in: root)
            .first(where: { $0.identifier?.rawValue.hasPrefix("pane:article|") == true })
        else { return nil }
        var outermost: NSScrollView?
        var current: NSView? = pane.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { outermost = scroll }
            current = node.superview
        }
        return outermost
    }

    private func isOnScreen(_ pane: PaneTextView, _ article: NSScrollView) -> Bool {
        let frame = pane.convert(pane.bounds, to: article.contentView)
        let visible = article.contentView.bounds
        return frame.minY >= visible.minY - 2 && frame.maxY <= visible.maxY + 2
    }

    private struct Fixture: @unchecked Sendable {
        let postID: String
        let blocks: [(block: String, variant: String)]
        let defaults: UserDefaults
    }

    nonisolated private static func proseText(_ i: Int) -> String {
        "Paragraph \(i). Honest prose on the measured line, long enough to wrap "
            + "once at the article's measure so the rows have real height."
    }

    private func withSession(
        blocks: Int,
        text: @escaping @MainActor (Int) -> String = { TakesFindBoardTests.proseText($0) },
        prepare: @MainActor (AppSession, [(block: String, variant: String)]) throws -> Void = { _, _ in },
        _ body: @MainActor (
            _ session: AppSession, _ fixture: Fixture, _ db: AppDatabase,
            _ mount: @MainActor (TakesViewModel) async -> (NSWindow, NSHostingView<TakesBoardView>)
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let suiteName = "TakesFindBoard-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "find fixture")
            var made: [(block: String, variant: String)] = []
            for i in 1...blocks {
                let minted = try session.operations.newBlock(
                    in: post.id, text: text(i), registeringUndo: false)
                made.append((minted.block.id, minted.variant.id))
            }
            try prepare(session, made)
            let fixture = Fixture(postID: post.id, blocks: made, defaults: defaults)

            var windows: [NSWindow] = []
            defer {
                for window in windows {
                    window.orderOut(nil)
                    window.close()
                }
            }
            let mount: @MainActor (TakesViewModel) async -> (
                NSWindow, NSHostingView<TakesBoardView>
            ) = { model in
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(
                    rootView: TakesBoardView(session: session, postID: post.id, model: model))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                windows.append(window)
                await self.settle(window, hosting, until: {
                    self.panes(in: hosting).contains {
                        $0.identifier?.rawValue.hasPrefix("pane:article|") == true
                    }
                })
                await self.settle(window, hosting, until: { false }, maxTurns: 8)
                return (window, hosting)
            }
            try await body(session, fixture, db, mount)
        }
    }

    private func landingModel(
        session: AppSession, fixture: Fixture, db: AppDatabase
    ) async throws -> TakesViewModel {
        let model = TakesViewModel(
            session: session, postID: fixture.postID, defaults: fixture.defaults)
        model.landingEnabled = true
        model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
        return model
    }

    /// The entry fact, the way the app sets it (the reveal pins' road).
    private func enterOn(
        _ block: (block: String, variant: String), _ router: CommandRouter, _ postID: String
    ) -> UUID {
        router.forgetCurrentBlock(for: postID)
        let token = router.registerDetail(postID: postID, mode: .write) { _ in }
        router.noteFocusedBlock(block.block, variantID: block.variant, postID: postID, utf16Offset: 0)
        return token
    }

    private func range(of needle: String, in text: String, occurrence: Int = 0) -> NSRange {
        TakesFindPlan.ranges(of: needle, in: text)[occurrence]
    }

    // MARK: - LEDGER ROW 7 — the trace, and the find's answer

    /// **LEDGER ROW 7, TRACED — then answered.** Her sequence: in Takes on a
    /// block, scroll away, go to Write and come back. Her R-Q21 round trip
    /// restores the page she left (the ruled restore — U8's R-18l-13 is what
    /// changes the mode-switch half), and the entry ring still lands on her
    /// block. **The trace:** that block's row is not on the restored page, so
    /// the lazy column never built its pane — the authority says the take is
    /// LIVE, and there is NO text view to hold the keyboard: *"tapping keys
    /// won't make you edit"*, exactly. (Green on both sides: this half is the
    /// trace of shipped, ruled machinery — nothing here edits it.)
    ///
    /// **The answer (decision 6):** she finds a word in that block — ⏎ in the
    /// field — and the match's take goes LIVE with the match SELECTED and its
    /// row REVEALED; the field keeps the keyboard (⏎ would step again); Esc
    /// closes the bar and hands the keyboard to the take, her place kept; and
    /// a keystroke then EDITS the take. Red on the pre-U7 tree by
    /// construction (there was no find in Takes), and by behavioural revert.
    @Test func ledgerRowSevenTracedAndAFindStepMakesTheTakeTypeable() async throws {
        try await withSession(blocks: 60, text: {
            $0 == 40
                ? "Paragraph 40 names Kilimanjaro once, long enough to wrap at the measure."
                : TakesFindBoardTests.proseText($0)
        }) { session, fixture, db, mount in
            let router = session.commandRouter
            let target = fixture.blocks[39]
            let token = enterOn(target, router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }

            // Showing 1: the entry lands on block 40 and reveals it.
            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (window1, hosting1) = await mount(first)
            let article1 = try #require(articleScrollView(in: hosting1))
            let deadline1 = Date().addingTimeInterval(4)
            while !(pane(target.variant, in: hosting1).map { isOnScreen($0, article1) } ?? false),
                  Date() < deadline1 {
                await settle(window1, hosting1, until: { false }, maxTurns: 2)
            }
            let entered = try #require(pane(target.variant, in: hosting1),
                                       "non-vacuity: the entry built block 40's pane")
            #expect(entered.isEditable && window1.firstResponder === entered,
                    "non-vacuity: on arrival the ring's take holds the keyboard")

            // Her scroll away — to the top — then leaving the board.
            article1.contentView.scroll(to: .zero)
            article1.reflectScrolledClipView(article1.contentView)
            await settle(window1, hosting1, until: { false }, maxTurns: 12)
            // Leaving: the board unmounts (its handlers go with it).
            window1.contentView = nil
            first.teardown()
            window1.orderOut(nil)

            // Showing 2 — the round trip (nothing clicked between).
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            await settle(window, hosting, until: { false }, maxTurns: 16)
            let ring = try #require(model.focusedPane, "the entry ring landed")
            #expect(ring.blockID == target.block, "…on her block (the note's current block)")
            #expect(model.isPaneLive(ring), "the authority says its take is LIVE")
            #expect(pane(target.variant, in: hosting) == nil,
                    """
                    THE TRACE: the restored page (the top) does not hold block 40's row, \
                    so the lazy column built no pane for the live take
                    """)
            #expect(!(window.firstResponder is PaneTextView),
                    "…so no text view holds the keyboard: keys cannot edit (her row-7 report)")

            // The answer: find the word, ⏎ in the field.
            model.find.open()
            await settle(window, hosting, until: { model.find.fieldHoldsKeyboard }, maxTurns: 20)
            #expect(model.find.fieldHoldsKeyboard, "precondition: the bar's field took the keyboard")
            model.find.setQuery("kilimanjaro")
            #expect(model.find.countFace == "1 match")
            model.find.next()
            let article = try #require(articleScrollView(in: hosting))
            let deadline = Date().addingTimeInterval(4)
            while !(pane(target.variant, in: hosting).map { isOnScreen($0, article) } ?? false),
                  Date() < deadline {
                await settle(window, hosting, until: { false }, maxTurns: 2)
            }
            let landed = try #require(pane(target.variant, in: hosting),
                                      "the step's landing revealed block 40's row")
            let match = range(of: "kilimanjaro", in: landed.string)
            #expect(isOnScreen(landed, article), "the match's row is on screen")
            #expect(landed.isEditable, "its take is LIVE")
            #expect(landed.selectedRange() == match, "with the match SELECTED")
            #expect(window.firstResponder !== landed,
                    "stepped from the field, the field KEEPS the keyboard — ⏎ steps again")
            #expect(model.find.countFace == "1 of 1")

            // Esc: the bar closes, the keyboard goes to the take, her place kept.
            model.find.close()
            await settle(window, hosting, until: { window.firstResponder === landed }, maxTurns: 20)
            #expect(window.firstResponder === landed, "Esc hands the keyboard to the take")
            #expect(landed.selectedRange() == match, "her place kept")

            // …and tapping a key EDITS the take (the row-7 complaint, answered).
            landed.insertText("K2", replacementRange: landed.selectedRange())
            #expect(landed.string.contains("names K2 once"), "the keystroke replaced the match")
            #expect(model.liveBuffers[target.variant]?.contains("names K2 once") == true,
                    "…and reached the take's buffer (autosave's road)")
        }
    }

    // MARK: - ⌘G from the board: the take takes the keyboard

    /// ⌘G through the ROUTER (the menu's own road — `dispatch(.find(.next))`)
    /// with the keyboard in the board: each step reveals its row, makes the
    /// take live with the match selected, and hands it the keyboard; the next
    /// match in the SAME live take is reached by the pane's request (no
    /// liveness transition to ride); the take it left keeps its match PAINTED
    /// on the read tier; and a keystroke replaces the selected match.
    @Test func commandGFromTheBoardLandsEachMatchLiveSelectedAndTypeable() async throws {
        try await withSession(blocks: 60, text: {
            switch $0 {
            case 44: return "Paragraph 44 mentions Zanzibar in passing, long enough to wrap."
            case 45: return "Paragraph 45 sails to Zanzibar and home from Zanzibar again, wrapping."
            default: return TakesFindBoardTests.proseText($0)
            }
        }) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[0], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            let article = try #require(articleScrollView(in: hosting))

            model.find.open()
            await settle(window, hosting, until: { model.find.fieldHoldsKeyboard }, maxTurns: 20)
            model.find.setQuery("ZANZIBAR")  // case-insensitive, the Write bar's rule
            #expect(model.find.countFace == "3 matches")
            // The keyboard in the BOARD: her click back into the take she is in
            // (after the bar has appeared and its field took the keyboard).
            let start = try #require(pane(fixture.blocks[0].variant, in: hosting))
            window.makeFirstResponder(start)
            await settle(window, hosting, until: { !model.find.fieldHoldsKeyboard }, maxTurns: 20)
            #expect(!model.find.fieldHoldsKeyboard, "precondition: the keyboard is the board's")

            // ⌘G — block 44.
            #expect(router.dispatch(.find(.next)), "the board handles ⌘G")
            let b44 = fixture.blocks[43].variant
            await settle(window, hosting, until: {
                self.pane(b44, in: hosting).map { $0.isEditable && self.isOnScreen($0, article) } ?? false
            }, maxTurns: 60)
            let p44 = try #require(pane(b44, in: hosting), "block 44's row was revealed")
            #expect(p44.isEditable && isOnScreen(p44, article))
            #expect(p44.selectedRange() == range(of: "zanzibar", in: p44.string))
            #expect(window.firstResponder === p44, "⌘G from the board: the take takes the keyboard")
            #expect(model.find.countFace == "1 of 3")

            // ⌘G — block 45's first match; block 44 goes read and wears its paint.
            router.dispatch(.find(.next))
            let b45 = fixture.blocks[44].variant
            await settle(window, hosting, until: {
                self.pane(b45, in: hosting).map { $0.isEditable } ?? false
            }, maxTurns: 60)
            let p45 = try #require(pane(b45, in: hosting))
            #expect(p45.selectedRange() == range(of: "zanzibar", in: p45.string, occurrence: 0))
            #expect(window.firstResponder === p45)
            await settle(window, hosting, until: { p44.findPaint != nil }, maxTurns: 20)
            #expect(!p44.isEditable, "the ring left block 44")
            #expect(p44.findPaint?.matches == [range(of: "zanzibar", in: p44.string)],
                    "decision 7: a read pane wears its match — the attributed-string paint")
            #expect(p45.findPaint == nil, "…and the LIVE take wears none (the selection is its mark)")

            // ⌘G — the SECOND match in the same live take: the pane's request.
            router.dispatch(.find(.next))
            let second = range(of: "zanzibar", in: p45.string, occurrence: 1)
            await settle(window, hosting, until: { p45.selectedRange() == second }, maxTurns: 30)
            #expect(p45.selectedRange() == second, "the next match in the live take, selected")
            #expect(model.find.countFace == "3 of 3")

            // ⇧⌘G steps back; ⌘G past the end wraps and says so.
            router.dispatch(.find(.previous))
            let firstIn45 = range(of: "zanzibar", in: p45.string, occurrence: 0)
            await settle(window, hosting, until: { p45.selectedRange() == firstIn45 }, maxTurns: 30)
            #expect(p45.selectedRange() == firstIn45, "⇧⌘G steps back")
            router.dispatch(.find(.next))
            await settle(window, hosting, until: { p45.selectedRange() == second }, maxTurns: 30)
            router.dispatch(.find(.next))
            await settle(window, hosting, until: { model.find.current == 0 }, maxTurns: 30)
            #expect(model.find.countFace == "1 of 3 · wrapped", "past the end: the first, said")

            // Typing replaces the selected match.
            router.dispatch(.find(.next))
            await settle(window, hosting, until: { p45.selectedRange() == firstIn45 }, maxTurns: 40)
            p45.insertText("Mombasa", replacementRange: p45.selectedRange())
            #expect(p45.string.contains("sails to Mombasa and home"), "she can type at once")
        }
    }

    // MARK: - R-18l-10 — the off-scope count, then the fan on arrival

    /// With "only chosen takes" ON (the default — her ruling) a word that lives
    /// only in a take the article is not showing is NOT found. Turned OFF, the
    /// block wears the count, nothing expands yet; a step EXPANDS the block's
    /// fan and lands in the take's card with the match selected.
    @Test func anOffScopeMatchIsCountedThenStepOpensItsFanAndSelectsIt() async throws {
        var other: (block: String, variant: String)?
        try await withSession(blocks: 12, prepare: { session, made in
            let block = made[2]
            let take = try session.operations.branchVariant(block.block, from: block.variant)
            try session.operations.autosave(
                take.id, text: "Paragraph 3, the other take: a quetzal on the sill.", charDelta: 40)
            other = (block.block, take.id)
        }) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[0], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            let fanned = try #require(other)
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            TakesFindFaces.reset()

            model.find.open()
            await settle(window, hosting, until: { TakesFindFaces.bar != nil }, maxTurns: 20)
            #expect(model.find.chosenOnly, "her ruling: only chosen takes, ON by default")
            #expect(TakesFindFaces.bar?.chosenOnly == true)
            model.find.setQuery("quetzal")
            #expect(model.find.countFace == "No matches", "the chosen take does not hold it")
            #expect(model.find.offScopeCount(forBlock: fanned.block) == nil)

            model.find.toggleScope()
            await settle(window, hosting, until: {
                TakesFindFaces.markers[fanned.block] != nil
            }, maxTurns: 30)
            #expect(model.find.countFace == "1 match")
            #expect(model.find.offScopeCount(forBlock: fanned.block) == 1)
            #expect(TakesFindFaces.markers[fanned.block] == "1 in another take",
                    "the block SAYS a take it is not showing holds a match")
            #expect(!model.expandedBlocks.contains(fanned.block),
                    "nothing expands before she steps there")

            model.find.next()
            await settle(window, hosting, until: {
                self.anyPane(fanned.variant, in: hosting).contains { $0.isEditable }
            }, maxTurns: 60)
            #expect(model.expandedBlocks.contains(fanned.block), "the step opened the block's fan")
            let card = try #require(anyPane(fanned.variant, in: hosting).first { $0.isEditable },
                                    "the take's card is the live pane")
            #expect(card.selectedRange() == range(of: "quetzal", in: card.string),
                    "…with the match selected")
            #expect(model.focusedPane?.columnID == TakesViewModel.takesFanColumnID)

            // The scope's session slot: a new board of the session opens with it.
            #expect(session.editorRouter.takesFind.chosenOnly == false)
            model.find.toggleScope()
            #expect(session.editorRouter.takesFind.chosenOnly == true)
        }
    }

    // MARK: - P1 — a settle recounts only what moved

    @Test func aSettleRescansOnlyTheTakesWhoseTextMoved() async throws {
        try await withSession(blocks: 30) { session, fixture, db, _ in
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            model.find.open()
            model.find.setQuery("prose")
            let firstCount = model.find.takesRescanned
            #expect(firstCount == 30, "the first count scans every shown take once")
            #expect(model.find.countFace == "30 matches")

            try session.operations.autosave(
                fixture.blocks[7].variant, text: "Paragraph 8, rewritten prose and more prose.",
                charDelta: 20)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            model.find.projectionChanged()
            #expect(model.find.takesRescanned == firstCount + 1,
                    "a settle rescans the ONE take that moved, never the note")
            #expect(model.find.countFace == "31 matches")
        }
    }
}
