//
//  CommandRoutingTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1b — the CommandRouter/StatusCenter behaviors and the
//  named-cell pins (each verified red-on-old by behavioral revert; the
//  revert results are recorded in the Stage 1b closeout):
//
//  - the mode-switch drop class (P-4): a routed request with no detail
//    SPEAKS — the old `.variorumSwitchMode` broadcast vanished silently;
//  - N4: ⌥⌘Z reports through the mode-independent StatusCenter — the old
//    path reported into a nil Write editor;
//  - AD-14: ONE status presentation — VM outcome lines land in the
//    StatusCenter with the one auto-dismiss policy;
//  - N9/AD-17: the Takes landing focuses the first slot's article pane —
//    "just start typing" is literal;
//  - D3: the structural doors fire-and-DO from Takes (move-and-execute,
//    end-to-end into a real divide) and the lecture is DEAD;
//  - the add-block door (D3's third leg) mints natively and hands the
//    ring to the new block's pane.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A fresh in-memory session world with deterministic dependencies.
@MainActor
private func withSessionWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func poll(
    _ condition: @MainActor () -> Bool, turns: Int = 400
) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

// MARK: - Router mechanics

@MainActor
@Suite("CommandRouter (13b 1b, P-1/P-4)")
struct CommandRouterTests {
    @Test func aModeRequestWithNoDetailSpeaksInsteadOfVanishing() async throws {
        try await withSessionWorld { session, _ in
            // The old channel posted `.variorumSwitchMode` with no observer
            // mounted — consumed keystroke, silence. Routed: it SPEAKS.
            let applied = session.commandRouter.requestMode(.takes)
            #expect(!applied)
            #expect(session.status.current?.text
                    == "Open a post first — the modes live inside a post.")
        }
    }

    @Test func aRegisteredDetailReceivesRoutedModeRequests() async throws {
        try await withSessionWorld { session, _ in
            var modes: [PostMode] = []
            let token = session.commandRouter.registerDetail(
                postID: "p1", mode: .takes
            ) { modes.append($0) }
            #expect(session.commandRouter.activeMode == .takes)

            #expect(session.commandRouter.requestMode(.write))
            #expect(modes == [.write])

            // Targeted at the mounted post: applies; at another: drops
            // (a stale rail click — parity with the old targeted filter).
            #expect(session.commandRouter.requestMode(.lenses, postID: "p1"))
            #expect(!session.commandRouter.requestMode(.canvas, postID: "other"))
            #expect(modes == [.write, .lenses])

            // The detail reports its truth; the rail's mirror follows.
            session.commandRouter.noteMode(.write)
            #expect(session.commandRouter.activeMode == .write)

            session.commandRouter.unregisterDetail(token)
            #expect(session.commandRouter.activeMode == nil)
            #expect(!session.commandRouter.requestMode(.takes))
        }
    }

    @Test func aStaleUnregisterNeverTearsDownTheNextDetail() async throws {
        try await withSessionWorld { session, _ in
            let old = session.commandRouter.registerDetail(
                postID: "p1", mode: .takes) { _ in }
            _ = session.commandRouter.registerDetail(
                postID: "p2", mode: .write) { _ in }
            // SwiftUI can run the old detail's onDisappear AFTER the new
            // one's onAppear — the token guard keeps the new registration.
            session.commandRouter.unregisterDetail(old)
            #expect(session.commandRouter.activePostID == "p2")
            #expect(session.commandRouter.activeMode == .write)
        }
    }

    @Test func dispatchWalksHandlersTopDownAndSpeaksWhenNothingConsumes() async throws {
        try await withSessionWorld { session, _ in
            // Nothing mounted: the registry's honest note speaks.
            #expect(!session.commandRouter.dispatch(.takes(.branch)))
            #expect(session.status.current?.text
                    == "Takes grow on a block inside a post — open one first.")

            var hits: [String] = []
            let bottom = session.commandRouter.registerHandler { _ in
                hits.append("bottom")
                return true
            }
            let top = session.commandRouter.registerHandler { command in
                if case .commit = command { return false }  // fall through
                hits.append("top")
                return true
            }
            #expect(session.commandRouter.dispatch(.takes(.branch)))
            #expect(hits == ["top"], "the last-mounted handler wins")
            #expect(session.commandRouter.dispatch(.commit))
            #expect(hits == ["top", "bottom"], "an unconsumed command falls through")
            session.commandRouter.unregisterHandler(top)
            session.commandRouter.unregisterHandler(bottom)
        }
    }
}

// MARK: - N4 + AD-14

@MainActor
@Suite("StatusCenter (13b 1b, AD-14 + N4)")
struct StatusCenterTests {
    @Test func undoReportsThroughTheModeIndependentStatusSurface() async throws {
        try await withSessionWorld { session, _ in
            // N4's pin: no Write editor anywhere (the old path delivered
            // the outcome into `editorRouter.active` = nil — silence).
            #expect(session.editorRouter.active == nil)
            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.structuralUndo()
            await poll { session.status.current != nil }
            #expect(session.status.current?.text == "No structural change to undo.")
        }
    }

    @Test func statusItemsAutoDismissUnderTheOnePolicy() async throws {
        try await withSessionWorld { session, _ in
            session.status.dismissAfter = .milliseconds(40)
            session.status.speak("a transient outcome")
            #expect(session.status.current?.text == "a transient outcome")
            await poll { session.status.current == nil }
            #expect(session.status.current == nil, "the one auto-dismiss policy ran")
        }
    }

    @Test func viewModelOutcomeLinesLandInTheOneCenter() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "p")
            _ = try session.operations.newBlock(in: post.id, text: "hello world.")
            _ = db
            let model = TakesViewModel(session: session, postID: post.id)
            model.speak("the board says a thing")
            #expect(session.status.current?.text == "the board says a thing",
                    "AD-14: the VM's statusMessage forwards to the ONE presentation")
        }
    }
}

// MARK: - N9 / AD-17: the Takes landing

@MainActor
@Suite("Takes landing focus (13b 1b, N9/AD-17)")
struct TakesLandingTests {
    @Test func theTakesBoardLandingFocusesTheFirstArticlePane() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "landed")
            let minted = try session.operations.newBlock(in: post.id, text: "first block text.")
            _ = try session.operations.newBlock(in: post.id, text: "second block text.")
            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true  // the board's onAppear does this
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.authority.livePane == TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: minted.block.id, variantID: minted.variant.id),
                "the landing puts the ring on the first slot's article pane — typing goes somewhere")
        }
    }

    @Test func theWritePanelsEmbeddedModelNeverStealsTheLanding() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "panel")
            _ = try session.operations.newBlock(in: post.id, text: "block text.")
            let model = TakesViewModel(session: session, postID: post.id)
            // landingEnabled stays false (the WriteTakesPanel shape).
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.authority.livePane == nil)
        }
    }

    @Test func aCrossModeBloomLandingBloomsAndFocusesTheNamedBlock() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "bloom")
            _ = try session.operations.newBlock(in: post.id, text: "first.")
            let target = try session.operations.newBlock(in: post.id, text: "second target.")
            session.commandRouter.pendingTakesLanding = .bloom(blockID: target.block.id)
            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.expandedBlocks.contains(target.block.id),
                    "the Lenses ⌘⇧T landing blooms the block it left")
            #expect(model.authority.livePane?.blockID == target.block.id)
            #expect(session.commandRouter.pendingTakesLanding == nil, "one-shot")
        }
    }
}

// MARK: - D3: fire-and-DO from Takes (the lecture is dead)

@MainActor
@Suite("Fire-and-DO move-and-execute (13b 1b, D3)")
struct MoveAndExecuteTests {
    @Test func divideFromTakesParksTheIntentAndSwitchesToWrite() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "d3")
            let minted = try session.operations.newBlock(
                in: post.id, text: "First sentence here. Second sentence here.")
            var modes: [PostMode] = []
            _ = session.commandRouter.registerDetail(
                postID: post.id, mode: .takes
            ) { modes.append($0) }

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: minted.block.id, variantID: minted.variant.id))

            model.moveToWriteAndRun(.structural(.divide))
            await poll { session.commandRouter.pendingWriteIntent != nil }

            let intent = try #require(session.commandRouter.pendingWriteIntent)
            #expect(intent.blockID == minted.block.id)
            #expect(intent.followUp == .structural(.divide))
            #expect(modes == [.write], "the choreography switched modes, visibly")
            // The D3 lecture is DEAD — not reworded (its copy was also
            // factually wrong for Divide).
            #expect(model.statusMessage?.contains("works on selected text") != true)
        }
    }

    @Test func aParkedDivideIntentLandsAndDividesEndToEnd() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "landing")
            let minted = try session.operations.newBlock(
                in: post.id, text: "First sentence here. Second sentence here.")
            // The choreography's parked half: what Takes leaves behind.
            session.commandRouter.pendingWriteIntent = WriteIntent(
                blockID: minted.block.id,
                offsetInBlock: 21,  // inside "Second…" — snaps to the boundary
                followUp: .structural(.divide))

            // The arriving Write editor (the mode switch mounts one).
            let model = EditorViewModel(session: session, postID: post.id)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            model.attach(textView: textView, scrollView: scrollView)
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: post.id),
                 try Queries.containerHeader(db, containerID: post.id))
            }
            model.adoptHeader(header)
            model.applyProjection(slots)

            #expect(session.commandRouter.pendingWriteIntent == nil, "consumed at first render")
            await poll { model.pendingIntentTask == nil }
            await model.pendingIntentTask?.value
            await poll {
                ((try? db.read { try Queries.renderPost($0, containerID: post.id) })?.count ?? 0) == 2
            }
            let after = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(after.count == 2, "the carried divide LANDED — a real cut, not a lecture")
            #expect(after[0].text == "First sentence here.")
            #expect(after[1].text == "Second sentence here.")
        }
    }

    @Test func theAddBlockDoorMintsNativelyAndHandsTheRingOver() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "grow")
            _ = try session.operations.newBlock(in: post.id, text: "existing block.")
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })

            await model.addBlockAtEnd()
            let slots = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(slots.count == 2, "a new block minted at the end (D3's third leg)")
            #expect(slots[1].text == "", "born empty — a place to type")

            // The projection echo hands the ring to the new pane.
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.authority.livePane?.blockID == slots[1].blockID,
                    "typing continues instantly in the minted block")
        }
    }

    /// N5's pin, over the REAL board wiring: the menu's exact action body
    /// (`ShellActions.commitTake`) with a Takes board mounted commits the
    /// focused take. The old ⌘S called `editorRouter.active?` = nil here —
    /// keystroke consumed, nothing happened, nothing spoke.
    @Test func commandSCommitsTheFocusedTakeThroughTheMountedBoard() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "n5")
            let minted = try session.operations.newBlock(in: post.id, text: "commit me please.")

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let model = TakesViewModel(session: session, postID: post.id)
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await poll { session.commandRouter.handlerCount > 0 }
            #expect(session.commandRouter.handlerCount > 0, "the board registered its handler")
            await poll { !model.projection.slots.isEmpty }
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: minted.block.id, variantID: minted.variant.id))

            ShellActions(session: session, shell: ShellRouter()).commitTake()

            await poll {
                ((try? db.read { db in
                    try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        arguments: [minted.variant.id])
                }) ?? 0) > 0
            }
            let commits = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                    arguments: [minted.variant.id]) ?? 0
            }
            #expect(commits == 1, "⌘S ACTED where it was advertised (N5)")
        }
    }

    @Test func mergeFromTakesLandsAtTheSeamWithTheBlockAbove() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "merge-up")
            _ = try session.operations.newBlock(in: post.id, text: "the block above.")
            let second = try session.operations.newBlock(in: post.id, text: "the focused block.")
            _ = session.commandRouter.registerDetail(
                postID: post.id, mode: .takes) { _ in }
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: second.block.id, variantID: second.variant.id))

            model.moveToWriteAndRun(.structural(.merge))
            await poll { session.commandRouter.pendingWriteIntent != nil }
            let intent = try #require(session.commandRouter.pendingWriteIntent)
            #expect(intent.blockID == second.block.id)
            #expect(intent.offsetInBlock == 0,
                    "the memo's reading: merge joins UPWARD — the caret lands at the seam above")
        }
    }
}
