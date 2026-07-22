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
            session.commandRouter.pendingTakesLanding =
                .bloom(postID: post.id, blockID: target.block.id)
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
                postID: post.id,
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
            #expect(after.first?.text == "First sentence here.")
            #expect(after.dropFirst().first?.text == "Second sentence here.")
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

    /// 13b 4D (N28/S4-13): the insert-below door mints RIGHT UNDER the
    /// focused block (never at the end) and hands the ring to the mint's
    /// pane — the addBlockAtEnd ring-handover precedent at `.after(...)`.
    @Test func theInsertBelowDoorMintsUnderTheFocusedBlockAndHandsTheRingOver() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "grow downward")
            let first = try session.operations.newBlock(in: post.id, text: "first block.")
            _ = try session.operations.newBlock(in: post.id, text: "last block.")
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })

            // No focus on a MULTI-block post: fire-and-speak, no guess.
            await model.insertBlockBelowFocused()
            #expect((try await db.read {
                try Queries.renderPost($0, containerID: post.id)
            }).count == 2, "no target — nothing minted")

            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.block.id, variantID: first.variant.id))
            await model.insertBlockBelowFocused()
            let slots = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(slots.count == 3)
            #expect(slots[1].text == "", "born empty, BETWEEN the two blocks")
            #expect(slots[0].blockID == first.block.id)

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

// MARK: - Stage 1 ladder, round-1 fix pins (each verified red by behavioral
// revert; the revert results are recorded in the round-1 dispositions
// section of notes/plans/phase-13b-make-it-work.md)

@MainActor
@Suite("Stale WriteIntent (13b Stage 1 ladder, round-1 MAJOR)")
struct StaleWriteIntentTests {
    /// Half (a), end to end — the finding's own pin: park an intent, make
    /// `requestMode` fail (postID mismatch — another post mounted during
    /// the flush await), mount the post's editor later, and assert NO
    /// gesture ran. Pre-fix: the mismatch branch returned false silently,
    /// the intent survived, and the later editor divided the block by
    /// itself at the stale offset.
    @Test func aRefusedModeSwitchClearsTheParkedIntentAndNothingEverRuns() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "stale-a")
            let minted = try session.operations.newBlock(
                in: post.id, text: "First sentence here. Second sentence here.")
            // The user clicked ANOTHER post while the choreography's flush
            // awaited: the mounted detail is not the intent's post.
            _ = session.commandRouter.registerDetail(
                postID: "another-post", mode: .takes) { _ in }

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: minted.block.id, variantID: minted.variant.id))
            model.notePaneSelection(
                variantID: minted.variant.id, range: NSRange(location: 21, length: 0))

            model.moveToWriteAndRun(.structural(.divide))
            // The refused switch SPEAKS (the mismatch branch was a silent
            // door inside the anti-silent-door machinery) …
            await poll {
                session.status.current?.text == CommandRouter.staleModeRequestNote
            }
            #expect(session.status.current?.text == CommandRouter.staleModeRequestNote)
            // … and the parking is CLEARED — nothing lies in wait.
            #expect(session.commandRouter.pendingWriteIntent == nil,
                    "a refused mode switch leaves no parked intent")

            // "Minutes later": the user opens the post in Write. Pre-fix,
            // this render consumed the stale intent and divided unprompted.
            let editor = EditorViewModel(session: session, postID: post.id)
            editor.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: editor)
            delegate.wire(to: textView)
            editor.attach(textView: textView, scrollView: scrollView)
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: post.id),
                 try Queries.containerHeader(db, containerID: post.id))
            }
            editor.adoptHeader(header)
            editor.applyProjection(slots)
            await editor.pendingIntentTask?.value

            #expect(editor.pendingIntentTask == nil, "no follow-up gesture was spawned")
            let after = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(after.count == 1,
                    "the store is untouched — no structural gesture ran unprompted")
        }
    }

    /// Half (b) — the consumption gate: every full-document editor runs
    /// `applyFocusSeeds` (detail Write, book-inline, pool), so an intent
    /// is post-stamped and an editor takes ONLY its own post's intent. A
    /// mismatched intent is left parked (a book-inline editor rendering
    /// mid-choreography must not destroy the detail editor's landing).
    @Test func aStaleIntentForAnotherPostIsNeverConsumedByAMountedEditor() async throws {
        try await withSessionWorld { session, db in
            let postP = try session.operations.createPost(title: "intent-owner")
            let mintedP = try session.operations.newBlock(
                in: postP.id, text: "First sentence here. Second sentence here.")
            let postQ = try session.operations.createPost(title: "innocent-bystander")
            _ = try session.operations.newBlock(in: postQ.id, text: "Q's only block.")

            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: postP.id, blockID: mintedP.block.id,
                offsetInBlock: 21, followUp: .structural(.divide))

            // An editor for a DIFFERENT post mounts (book-inline/pool
            // shape — no detail registration involved).
            let editor = EditorViewModel(session: session, postID: postQ.id)
            editor.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: editor)
            delegate.wire(to: textView)
            editor.attach(textView: textView, scrollView: scrollView)
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: postQ.id),
                 try Queries.containerHeader(db, containerID: postQ.id))
            }
            editor.adoptHeader(header)
            editor.applyProjection(slots)
            await editor.pendingIntentTask?.value

            #expect(session.commandRouter.pendingWriteIntent != nil,
                    "the mismatched intent stays parked for its own post's editor")
            #expect(editor.pendingIntentTask == nil,
                    "the wrong post's editor never spawned the follow-up")
            let qAfter = try await db.read { try Queries.renderPost($0, containerID: postQ.id) }
            #expect(qAfter.count == 1, "Q's store is untouched")
        }
    }

    /// Half (b), freshness — one-round validity as detail-lifecycle
    /// clearing: a parked intent dies when the detail changes post
    /// (register-ordering-proof) or unmounts entirely.
    @Test func theDetailLifecycleClearsStaleParkedIntents() async throws {
        try await withSessionWorld { session, _ in
            // Register-with-a-different-post clears (P→Q switch — Q's
            // onAppear may run BEFORE P's onDisappear, so the clearing
            // must ride registration, not only teardown).
            _ = session.commandRouter.registerDetail(
                postID: "p", mode: .takes) { _ in }
            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: "p", blockID: nil, followUp: .structural(.divide))
            session.commandRouter.pendingTakesLanding = .bloom(postID: "p", blockID: "b")
            _ = session.commandRouter.registerDetail(
                postID: "q", mode: .takes) { _ in }
            #expect(session.commandRouter.pendingWriteIntent == nil,
                    "a different post's registration clears the stale intent")
            #expect(session.commandRouter.pendingTakesLanding == nil,
                    "…and the stale landing")

            // A genuine unregister (detail gone, no successor) clears too.
            let token = session.commandRouter.registerDetail(
                postID: "r", mode: .takes) { _ in }
            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: "r", blockID: nil, followUp: .structural(.merge))
            session.commandRouter.pendingTakesLanding = .bloom(postID: "r", blockID: "b2")
            session.commandRouter.unregisterDetail(token)
            #expect(session.commandRouter.pendingWriteIntent == nil,
                    "a genuine detail teardown ends the intent's round")
            #expect(session.commandRouter.pendingTakesLanding == nil)

            // The happy path is untouched: same-post registration keeps a
            // parked intent (the arriving editor consumes it).
            _ = session.commandRouter.registerDetail(
                postID: "s", mode: .takes) { _ in }
            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: "s", blockID: nil, followUp: .structural(.divide))
            _ = session.commandRouter.registerDetail(
                postID: "s", mode: .write) { _ in }
            #expect(session.commandRouter.pendingWriteIntent != nil,
                    "same-post registration leaves the in-flight intent alone")
        }
    }

    /// Half (a)'s parenthetical: the postID-mismatch branch SPEAKS.
    @Test func aStaleTargetedModeRequestSpeaks() async throws {
        try await withSessionWorld { session, _ in
            _ = session.commandRouter.registerDetail(
                postID: "p1", mode: .takes) { _ in }
            #expect(!session.commandRouter.requestMode(.write, postID: "other"))
            #expect(session.status.current?.text == CommandRouter.staleModeRequestNote,
                    "the mismatch branch is no longer a silent door")
        }
    }

    /// The landing twin (the MAJOR's staleness discipline extended to
    /// `TakesLanding`): a stale landing for ANOTHER post is not consumed —
    /// pre-fix it bloomed a foreign block ID and, worse, set
    /// `landingFocusDone`, eating the consuming board's own N9
    /// "just start typing" focus.
    @Test func aStaleLandingForAnotherPostNeverEatsTheBoardsLandingFocus() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "landing-guard")
            let minted = try session.operations.newBlock(in: post.id, text: "the first block.")
            session.commandRouter.pendingTakesLanding =
                .bloom(postID: "another-post", blockID: "foreign-block")

            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })

            #expect(session.commandRouter.pendingTakesLanding != nil,
                    "the mismatched landing stays parked")
            #expect(!model.expandedBlocks.contains("foreign-block"),
                    "no foreign block bloomed")
            #expect(model.authority.livePane?.blockID == minted.block.id,
                    "the board's own N9 landing focus still happened")
        }
    }

    /// Round-2 MINOR-R2 — the SAME-POST aborted round: the request
    /// SUCCEEDS, but a competing mode switch (⌘2–⌘7) flips the detail off
    /// Write in the tens-of-ms before the arriving editor's first render.
    /// Same post ⇒ register/unregister clearing never fires (detail
    /// identity, not round); the round boundary is the detail's MODE
    /// report — `noteMode` clears a parcel whose landing mode the round
    /// left. Pre-fix, the orphaned intent divided unprompted at the NEXT
    /// Write mount, minutes later.
    @Test func aCompetingModeSwitchAbortsTheRoundAndClearsTheParkedIntent() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "aborted-round")
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
            model.notePaneSelection(
                variantID: minted.variant.id, range: NSRange(location: 21, length: 0))

            model.moveToWriteAndRun(.structural(.divide))
            await poll { session.commandRouter.pendingWriteIntent != nil }
            #expect(modes == [.write], "the request succeeded — the round began")

            // The detail's own onChange reports the LANDING mode first —
            // the parcel survives (the ordering-safety half).
            session.commandRouter.noteMode(.write)
            #expect(session.commandRouter.pendingWriteIntent != nil,
                    "reporting the landing mode keeps the in-flight intent")

            // The competing switch: the editor unmounts before any
            // .initialRender; the detail reports the new truth.
            #expect(session.commandRouter.requestMode(.lenses))
            session.commandRouter.noteMode(.lenses)
            #expect(session.commandRouter.pendingWriteIntent == nil,
                    "the round is over — the parcel cleared on the mode report")

            // "Minutes later": Write mounts again on the SAME post.
            let editor = EditorViewModel(session: session, postID: post.id)
            editor.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: editor)
            delegate.wire(to: textView)
            editor.attach(textView: textView, scrollView: scrollView)
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: post.id),
                 try Queries.containerHeader(db, containerID: post.id))
            }
            editor.adoptHeader(header)
            editor.applyProjection(slots)
            await editor.pendingIntentTask?.value

            #expect(editor.pendingIntentTask == nil, "no follow-up gesture spawned")
            let after = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(after.count == 1, "no structural gesture ran unprompted")
        }
    }

    /// The landing twin's round boundary (benign consequence pre-fix —
    /// stale bloom/focus — but the same window).
    @Test func aCompetingModeSwitchClearsTheParkedLandingToo() async throws {
        try await withSessionWorld { session, _ in
            _ = session.commandRouter.registerDetail(
                postID: "p", mode: .lenses) { _ in }
            session.commandRouter.pendingTakesLanding = .bloom(postID: "p", blockID: "b")
            session.commandRouter.noteMode(.takes)
            #expect(session.commandRouter.pendingTakesLanding != nil,
                    "the landing mode's report keeps the parcel")
            session.commandRouter.noteMode(.canvas)
            #expect(session.commandRouter.pendingTakesLanding == nil,
                    "any other mode report ends the landing's round")
        }
    }
}

@MainActor
@Suite("Seal door in handler-less modes (13b Stage 1 ladder, round-1 MINOR-1)")
struct SealDoorTests {
    /// Compare/Blocks register no command handler (Outline retired into
    /// Compare, 13b 4C; Canvas falls
    /// through), so the seal dispatch is unhandled and the shell fallback
    /// SEALS. Pre-fix the unhandled dispatch spoke "open a post first" —
    /// with a post open — a factually wrong refusal immediately replaced
    /// by "Sealed.". The dispatch is quiet now; only the outcome speaks.
    @Test func sealFromAHandlerLessModeActsWithoutAWrongRefusalFlash() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "seal-me")
            _ = try session.operations.newBlock(in: post.id, text: "a block.")
            _ = session.commandRouter.registerDetail(
                postID: post.id, mode: .compare) { _ in }

            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.toggleSeal()
            // The pre-fix wrong note landed SYNCHRONOUSLY inside the
            // dispatch, before the fallback's Task ran.
            #expect(session.status.current == nil,
                    "no wrong refusal flash — the quiet dispatch left speech to the outcome")

            await poll {
                (try? db.read { db in
                    try Queries.containerHeader(db, containerID: post.id)?.locked
                }) == true
            }
            let sealed = try await db.read { db in
                try Queries.containerHeader(db, containerID: post.id)?.locked
            }
            #expect(sealed == true, "the fallback ACTED — the post sealed")
            #expect(session.status.current?.text.contains("Sealed") == true,
                    "the one honest outcome spoke")
        }
    }

    /// Where the fallback genuinely can't act (no post open anywhere),
    /// the honest note still speaks — the quiet dispatch didn't create a
    /// new silent door. (Parity guard, not a red pin: the old code also
    /// spoke here, via the dispatch.)
    @Test func sealWithNoPostOpenStillSpeaksTheHonestNote() async throws {
        try await withSessionWorld { session, _ in
            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.toggleSeal()
            #expect(session.status.current?.text
                    == "Sealing acts on an open post — open one first.")
        }
    }
}

@MainActor
@Suite("Block TOC status forward (13b Stage 1 ladder, round-1 MINOR-2)")
struct BlockTOCStatusTests {
    /// Blocks is a full mode surface; its VM was the ONE surface VM not
    /// forwarding `statusMessage` to the StatusCenter — refusals rendered
    /// in a private never-dismissing red caption instead of AD-14's one
    /// presentation.
    @Test func tocRefusalsLandInTheOneStatusCenter() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "toc-status")
            let minted = try session.operations.newBlock(in: post.id, text: "a block.")
            try session.operations.lockPost(post.id)  // sealed — deletes refuse
            _ = db

            let model = BlockTOCViewModel(session: session, postID: post.id)
            await model.deleteBlock(minted.block.id)

            let expected = OpsRefusalCopy.message(for: OperationError.lockedPost(id: post.id))
            #expect(model.statusMessage == expected, "the property stays the tested truth")
            #expect(session.status.current?.text == expected,
                    "the TOC's outcome reached the ONE presentation (AD-14)")
        }
    }
}

@MainActor
@Suite("Takes word-count cache (13b Stage 1 ladder, round-1 MINOR-5)")
struct TakesWordCountTests {
    /// The bar re-renders per keystroke (it reads the observed authority)
    /// and used to reduce `TextMetrics.wordCount` over EVERY slot's full
    /// text each render — O(post length) per keystroke. The total is now
    /// the model's cache: recomputed per PROJECTION, and only for slots
    /// whose text actually changed (the Write ledger's discipline).
    @Test func slotWordCountsRecomputeOnlyWhereTextChanged() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "counts")
            _ = try session.operations.newBlock(in: post.id, text: "one two three.")
            let second = try session.operations.newBlock(in: post.id, text: "four five.")
            _ = try session.operations.newBlock(in: post.id, text: "six.")

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.postWordCount == 6, "3 + 2 + 1 words over the rendered slots")
            #expect(model.slotRecountCount == 3, "first adoption counts every slot once")

            // An unchanged projection re-adopts with ZERO recounts (the
            // pre-fix shape re-enumerated everything, every time).
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.slotRecountCount == 3, "unchanged texts reuse their cached counts")
            #expect(model.postWordCount == 6)

            // One slot's text changes ⇒ exactly one recount.
            try session.operations.autosave(
                second.variant.id, text: "four five six seven.", charDelta: 10)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.slotRecountCount == 4, "only the changed slot re-enumerated")
            #expect(model.postWordCount == 8, "3 + 4 + 1")
        }
    }
}
