//
//  TakesArticleRenderTests.swift
//  VariorumTests
//
//  Batch 14 (Sitting 9): her two reopened article-cell reports, mounted
//  against the REAL TakesBoardView — (1) "when something is chosen, it
//  still doesn't appear as chosen in the space above" and (2) "lines
//  multiple paragraph breaks below the start of a take still aren't
//  appearing when the take isn't expanded". The article cell must render
//  the CHOSEN take's full multi-paragraph text at full height, closed fan
//  and all, including after an edit-in-card → choose flow.
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
private func withTakesWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ postID: String, _ blockID: String,
                        _ chosenTakeID: String, _ chosenText: String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "takes world")
        let minted = try session.operations.newBlock(
            in: post.id, text: "let's see what this post will be like")
        // Her flow: branch a second take, give it the multi-paragraph
        // text, choose it.
        let branch = try session.operations.branchVariant(
            minted.block.id, from: minted.variant.id)
        let chosenText = "let's see what this post will be like ;)\n\n\n\n\nI like it!"
        try session.operations.autosave(
            branch.id, text: chosenText, charDelta: chosenText.count)
        try session.operations.chooseVariant(minted.block.id, variantID: branch.id)
        return try await body(
            session, db, post.id, minted.block.id, branch.id, chosenText)
    }
}

@MainActor
@Suite("Takes article rendering (batch 14 pins)", .serialized)
struct TakesArticleRenderTests {
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

    private func takeViews(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let take = view as? PaneTextView { found.append(take) }
        for sub in view.subviews { found.append(contentsOf: takeViews(in: sub)) }
        return found
    }

    @Test func closedFanArticleCellShowsTheChosenTakeWholly() async throws {
        try await withTakesWorld { session, _, postID, _, _, chosenText in
            let model = TakesViewModel(session: session, postID: postID)
            let observing = Task { await model.start() }
            defer {
                model.teardown()
                observing.cancel()
            }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !takeViews(in: hosting).isEmpty })
            await settle(window, hosting, until: { false }, maxTurns: 10)

            let panes = takeViews(in: hosting)
            #expect(!panes.isEmpty, "the article rendered")
            // The CLOSED fan renders exactly the article cell — it must
            // hold the CHOSEN take's text ("appear as chosen in the space
            // above")…
            let article = panes.first
            #expect(article?.string == chosenText,
                    "article cell shows \(article?.string ?? "nil")")
            // …at a height that holds every paragraph ("the text that's
            // underneath several newlines never even shows").
            #expect((article?.bounds.height ?? 0) > 100,
                    "article cell height \(article?.bounds.height ?? 0)")
        }
    }

    @Test func focusedChosenCardNeverFreezesTheArticleCell() async throws {
        // HER LIVE FLOW (image #9: TWO live rings): bloom the fan, click
        // into the CHOSEN take's card, type. Pre-fix, the card's pane key
        // EQUALED the article cell's (same column id + block + variant) —
        // both went live, and a live pane never adopts text, so the
        // article froze stale ("doesn't appear as chosen in the space
        // above"). The fan cards live in their own pane namespace now.
        try await withTakesWorld { session, _, postID, blockID, chosenID, chosenText in
            let model = TakesViewModel(session: session, postID: postID)
            let observing = Task { await model.start() }
            defer {
                model.teardown()
                observing.cancel()
            }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !takeViews(in: hosting).isEmpty })

            // Bloom the fan and focus the chosen card the way the UI does.
            model.toggleExpanded(blockID)
            await settle(window, hosting, until: { takeViews(in: hosting).count >= 2 })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesBoardView.fanColumnID, blockID: blockID, variantID: chosenID))
            await settle(window, hosting, until: { false }, maxTurns: 4)

            // Type into the focused card (the model path a keystroke takes).
            let typed = chosenText + " and more typing!"
            model.paneEdited(variantID: chosenID, newText: typed)
            await settle(
                window, hosting,
                until: { takeViews(in: hosting).first?.string == typed })

            // The ARTICLE CELL (first pane in hierarchy order — the read
            // mirror above the fan) must follow the live buffer at once.
            // Pre-fix it froze: the shared pane key made it "live" (never
            // adopts), and @ObservationIgnored buffers never invalidated
            // it. (The live CARD itself shows the user's real keystrokes
            // AppKit-side; a programmatic model edit deliberately never
            // clobbers a live pane — the buffer-authoritative guard.)
            #expect(takeViews(in: hosting).first?.string == typed,
                    "article shows \(takeViews(in: hosting).first?.string ?? "nil")")
        }
    }

    @Test func stackStyleReadCardsFollowTheLiveBufferNotStaleStoreText() async throws {
        // 13b Stage 1a (the batch-14 pattern EXTENDED to the stack style):
        // `CollapsibleTakeCard` fed panes raw `take.workingText`, bypassing
        // the live buffers — the ONE card path left outside the authority.
        // Mechanism: edit the chosen take from the ARTICLE cell (live);
        // its stack-bloom CARD is a read pane mirroring the same variant —
        // while the autosave debounce holds, the store (and the manually-
        // driven projection here) is stale, so the pre-fix card shows the
        // OLD text. Post-fix every card resolves through the authority.
        // (No observation task runs — the projection stays deliberately
        // stale, so a late flush can't green the old code.)
        try await withTakesWorld { session, db, postID, blockID, chosenID, chosenText in
            let model = TakesViewModel(session: session, postID: postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            defer { model.teardown() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #expect(model.projection.fanStyle == .stack, "the stack style is the default")
            await settle(window, hosting, until: { !takeViews(in: hosting).isEmpty })

            // Bloom the fan; focus the ARTICLE cell (main column) for the
            // chosen take — its fan CARD is then a read pane.
            model.toggleExpanded(blockID)
            await settle(window, hosting, until: { takeViews(in: hosting).count >= 2 })
            model.focus(TakesViewModel.PaneKey(
                columnID: "takes-main", blockID: blockID, variantID: chosenID))
            await settle(window, hosting, until: { false }, maxTurns: 3)

            let typed = chosenText + " — typed into the article"
            model.paneEdited(variantID: chosenID, newText: typed)
            let cardID = NSUserInterfaceItemIdentifier("pane:card|\(chosenID)")
            // SHORT settle, deliberately inside the 500 ms autosave
            // debounce: the card must follow the BUFFER at once — waiting
            // for the store's round trip would let the pre-fix code
            // converge late and hollow the pin.
            await settle(
                window, hosting,
                until: {
                    takeViews(in: hosting).contains {
                        $0.identifier == cardID && $0.string == typed
                    }
                }, maxTurns: 5)

            let card = takeViews(in: hosting).first { $0.identifier == cardID }
            #expect(card != nil, "the chosen take's stack card rendered")
            #expect(card?.string == typed,
                    "the stack card follows the live buffer (shows: \(card?.string ?? "nil"))")
        }
    }

    @Test func editInCardThenChooseUpdatesTheArticleCell() async throws {
        try await withTakesWorld { session, _, postID, blockID, chosenID, _ in
            let model = TakesViewModel(session: session, postID: postID)
            let observing = Task { await model.start() }
            defer {
                model.teardown()
                observing.cancel()
            }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !takeViews(in: hosting).isEmpty })

            // Her live flow: type MORE into the chosen take's pane (the
            // live-buffer path), then keep working — the article cell
            // above must follow the buffer, not a stale projection.
            let edited = "a fully new paragraph.\n\n\n\nand the far tail!"
            model.paneEdited(variantID: chosenID, newText: edited)
            await settle(
                window, hosting,
                until: { takeViews(in: hosting).contains { $0.string == edited } })

            let panes = takeViews(in: hosting)
            #expect(panes.contains { $0.string == edited },
                    "the article cell follows the chosen take's live buffer")
            let article = panes.first { $0.string == edited }
            #expect((article?.bounds.height ?? 0) > 100,
                    "followed text at full height — measured \(article?.bounds.height ?? 0)")
        }
    }
}
