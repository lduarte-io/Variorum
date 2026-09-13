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
                    == "Open a note first — the modes live inside a note.")
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
                    == "Takes grow on a block inside a note — open one first.")

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

    // MARK: - 18i (her R-Q5): the three kinds and the one routing rule

    /// **A REFUSAL SHOWS UNDER EVERY SETTING.** The setting governs receipts
    /// and nothing else: a door that could not act must still deliver the
    /// operations layer's real refusal (P-2, fire-and-DO), so `off` must
    /// never be able to silence one.
    @Test func aRefusalToastsUnderEveryReceiptStyle() async throws {
        try await withSessionWorld { session, _ in
            for style in ReceiptStyle.allCases {
                session.status.clear()
                session.status.receiptStyle = style
                session.status.speak("Click into a block first.")
                #expect(session.status.current?.text == "Click into a block first.",
                        "a refusal toasts under \(style.rawValue)")
                #expect(session.status.quietLine == nil,
                        "…and never lands quietly instead")
            }
        }
    }

    /// **AN OFFER SHOWS UNDER EVERY SETTING** — it carries a button, and a
    /// question she cannot see is not asked. The kind is INFERRED from the
    /// action, so every shipped `speak(_:action:)` call is unchanged.
    @Test func anOfferAlwaysToastsAndIsInferredFromItsAction() async throws {
        try await withSessionWorld { session, _ in
            for style in ReceiptStyle.allCases {
                session.status.clear()
                session.status.receiptStyle = style
                session.status.speak(
                    "This note is in two books.",
                    action: StatusCenter.Item.Action(label: "Diverge", perform: {}))
                #expect(session.status.current?.kind == .offer,
                        "an action makes it an offer under \(style.rawValue)")
                #expect(session.status.current?.text == "This note is in two books.")
                #expect(session.status.quietLine == nil)
            }
        }
    }

    /// **THE RECEIPT GOES WHERE SHE SAID.** RED ON OLD by the routing's own
    /// revert: before 18i every receipt was a `speak`, i.e. a toast — so the
    /// `.quiet` arm is exactly the fix.
    @Test func aReceiptLandsWhereTheSettingSays() async throws {
        try await withSessionWorld { session, _ in
            session.status.receiptStyle = .toast
            session.status.receipt("Blocks joined — \u{2325}\u{2318}Z undoes it.")
            #expect(session.status.current?.text == "Blocks joined — \u{2325}\u{2318}Z undoes it.")
            #expect(session.status.current?.kind == .receipt)
            #expect(session.status.quietLine == nil)

            session.status.clear()
            session.status.receiptStyle = .quiet
            session.status.receipt("Blocks joined — \u{2325}\u{2318}Z undoes it.")
            #expect(session.status.current == nil, "HER DEFAULT: no toast")
            #expect(session.status.quietLine?.text
                    == "Blocks joined — \u{2325}\u{2318}Z undoes it.",
                    "…the bottom bar's muted line carries the words")

            session.status.clear()
            session.status.receiptStyle = .off
            session.status.receipt("Blocks joined — \u{2325}\u{2318}Z undoes it.")
            #expect(session.status.current == nil && session.status.quietLine == nil,
                    "off means off")
            #expect(session.status.lastDroppedReceipt
                    == "Blocks joined — \u{2325}\u{2318}Z undoes it.",
                    "…and the receipt REACHED the centre — it was dropped, not unspoken")
        }
    }

    /// The centre says ONE thing at a time, wherever it sits: a refusal
    /// arriving over a quiet receipt clears the quiet line (and back), so
    /// nothing stale ever reads as current. `spoken` is the kind-agnostic
    /// read — the word pins use it, the slot pins above do not.
    @Test func oneMessageAtATimeAcrossBothSlots() async throws {
        try await withSessionWorld { session, _ in
            session.status.receiptStyle = .quiet
            session.status.receipt("Block divided.")
            #expect(session.status.spoken?.text == "Block divided.")
            session.status.speak("This note is sealed — unlock it first.")
            #expect(session.status.quietLine == nil, "the quiet line stood down")
            #expect(session.status.spoken?.text == "This note is sealed — unlock it first.")
            session.status.receipt("Blocks merged.")
            #expect(session.status.current == nil, "…and the toast stood down in turn")
            #expect(session.status.spoken?.text == "Blocks merged.")
            session.status.clear()
            #expect(session.status.spoken == nil, "clear() empties both slots")
        }
    }

    /// The quiet line rides the SAME clock the toast does — "quiet" is a
    /// placement and a register, never a different lifetime.
    @Test func theQuietLineAutoDismissesUnderTheOnePolicy() async throws {
        try await withSessionWorld { session, _ in
            session.status.receiptStyle = .quiet
            session.status.dismissAfter = .milliseconds(40)
            session.status.receipt("Moved — now block 3 of 8.")
            #expect(session.status.quietLine != nil)
            await poll { session.status.quietLine == nil }
            #expect(session.status.quietLine == nil, "the one auto-dismiss policy ran")
        }
    }

    /// **THE DEFAULT IS HERS, AND IT IS ADOPTED WHERE IT LANDS.** The
    /// centre's compile-time value already is her default; the theme store
    /// pushes the stored one in from the settings observation (the 18d
    /// lesson) — no surface reads the setting for itself (F-6).
    @Test func theThemeStoreAdoptsTheReceiptStyleFromTheLandedSettings() async throws {
        try await withSessionWorld { session, _ in
            #expect(session.status.receiptStyle == .quiet,
                    "the compile-time value is her default")
            try session.operations.setReceiptStyle(.toast)
            try await withAdoptedTheme(session: session) { store in
                await poll { store.settings.receiptStyle == .toast }
                #expect(session.status.receiptStyle == .toast,
                        "adopted where the settings LAND, never guessed by a view")
            }
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

    // MARK: - 17o batch b, ledger row 8 — the landing also SCROLLS

    /// Her words: *"open takes mode in write from the takes menu is also not
    /// automatically navigating you to where the take is"*. The bloom landing
    /// (the fan panel's "Open Takes mode") ringed the pane and left the
    /// article column where it was. Model-level, because the real-click rig
    /// cannot mount the whole board (KnownIssues' rig row) — the face is
    /// walked. The requested id is the article `ForEach`'s own identity, the
    /// placement id.
    @Test func theBloomLandingAlsoAsksTheArticleToScrollToThatSlot() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "scroll to it")
            for i in 1...12 {
                _ = try session.operations.newBlock(in: post.id, text: "block \(i) of the note.")
            }
            let target = try session.operations.newBlock(in: post.id, text: "the far target block.")
            session.commandRouter.pendingTakesLanding =
                .bloom(postID: post.id, blockID: target.block.id)
            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true
            let projection = try await db.read { try Queries.takesProjection($0, post: post.id) }
            model.adopt(projection)
            let slot = try #require(projection.slots.first { $0.blockID == target.block.id })
            #expect(model.articleLanding == slot.placementID,
                    "the article is asked to scroll to the landed slot, not left at the top")
            // One-shot: the article spends it, and a scroll afterwards stands.
            model.clearArticleLanding()
            #expect(model.articleLanding == nil)
        }
    }

    /// The same rule at the ordinary ⌘2 landing: the board ENTERS on the
    /// note's current block (the Act 10 row-39 fact), so the page shows it.
    @Test func theNineLandingOnTheCurrentBlockAsksTheArticleToScrollThere() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "enter on it")
            for i in 1...8 {
                _ = try session.operations.newBlock(in: post.id, text: "block \(i).")
            }
            let target = try session.operations.newBlock(in: post.id, text: "where she was.")
            let router = session.commandRouter
            router.forgetCurrentBlock(for: post.id)
            defer { router.forgetCurrentBlock(for: post.id) }
            let token = router.registerDetail(postID: post.id, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                target.block.id, variantID: target.variant.id, postID: post.id, utf16Offset: 4)
            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true
            let projection = try await db.read { try Queries.takesProjection($0, post: post.id) }
            model.adopt(projection)
            let slot = try #require(projection.slots.first { $0.blockID == target.block.id })
            #expect(model.authority.livePane?.blockID == target.block.id)
            #expect(model.articleLanding == slot.placementID)
            // …and the pane it rings enters at the remembered caret place.
            #expect(model.caretLanding(forVariant: target.variant.id) == .offset(4))
        }
    }

    /// The fall-through (no fact, or a fact this note does not hold) rings the
    /// FIRST slot — which is already at the top. Asking for a scroll there
    /// would fight a restored position for nothing, so nothing is asked.
    @Test func theFallThroughLandingAsksForNoScrollAtAll() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "no fact")
            _ = try session.operations.newBlock(in: post.id, text: "first.")
            _ = try session.operations.newBlock(in: post.id, text: "second.")
            session.commandRouter.forgetCurrentBlock(for: post.id)
            let model = TakesViewModel(session: session, postID: post.id)
            model.landingEnabled = true
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.authority.livePane != nil, "the ring still lands")
            #expect(model.articleLanding == nil)
            // The sanity pass's RAISE-2, the fall-through's caret: the note's
            // ENTRY with nothing remembered is the START (R1-3's road — this
            // pane reports), never `.leave`.
            let live = try #require(model.authority.livePane)
            #expect(model.caretLanding(forVariant: live.variantID) == .start)
        }
    }
}

// MARK: - D3: fire-and-DO from Takes (the lecture is dead)

@MainActor
@Suite("Fire-and-DO move-and-execute (13b 1b, D3)")
struct MoveAndExecuteTests {
    @Test func extractFromTakesParksTheIntentAndSwitchesToWrite() async throws {
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

            // 13d Batch 3: this pin exercises the CHOREOGRAPHY, and it
            // uses EXTRACT because divide stopped carrying — it acts
            // natively on the board now (A9). The machinery is unchanged;
            // only the sample act moved off a retired flow.
            model.moveToWriteAndRun(.structural(.extract))
            await poll { session.commandRouter.pendingWriteIntent != nil }

            let intent = try #require(session.commandRouter.pendingWriteIntent)
            #expect(intent.blockID == minted.block.id)
            #expect(intent.followUp == .structural(.extract))
            #expect(modes == [.write], "the choreography switched modes, visibly")
            // The D3 lecture is DEAD — not reworded (its copy was also
            // factually wrong for Divide).
            #expect(model.statusMessage?.contains("works on selected text") != true)
        }
    }

    @Test func aParkedExtractIntentLandsAndExtractsEndToEnd() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "landing")
            let minted = try session.operations.newBlock(
                in: post.id, text: "First sentence here. Second sentence here.")
            // The choreography's parked half: what Takes leaves behind.
            // 13d Batch 3: this pin exercises the CHOREOGRAPHY, and it
            // uses EXTRACT because divide stopped carrying — it acts
            // natively on the board now (A9). The machinery is unchanged;
            // only the sample act moved off a retired flow.
            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: post.id,
                blockID: minted.block.id,
                offsetInBlock: 21,  // "Second sentence here." — a suffix span
                selectionLength: 21,
                followUp: .structural(.extract))

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
            #expect(after.count == 2, "the carried extract LANDED — a real cut, not a lecture")
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

    /// 13c Stage 1 ladder, R2-6: **one declared act, one contract, however
    /// many doors.** `deleteBlock` is native in Write and in Takes; Write's
    /// door runs through `runStructural`, which flushes AND THEN checks
    /// `isDirty`, because a flush can REFUSE and keep its text pending
    /// (Phase 7 MAJOR 1) — running a structural op against a store the
    /// surface disagrees with is exactly what that check exists to stop.
    /// The Takes door flushed and then went ahead regardless.
    ///
    /// The refusal is induced the honest way: a pending record for a
    /// variant that does not exist. `ops.autosave` throws, the coordinator
    /// puts the entry BACK into `pending` (its documented posture), and
    /// `isDirty` stays true — which is precisely the real-world shape
    /// (a seal or lock landing remotely mid-typing).
    @Test func theTakesDeleteDoorRefusesWhenTheFlushCouldNotBeWritten() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "unflushable")
            let first = try session.operations.newBlock(in: post.id, text: "first block.")
            _ = try session.operations.newBlock(in: post.id, text: "second block.")
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.block.id, variantID: first.variant.id))

            model.autosave.record(
                variantID: "no-such-variant", text: "typed but unwritable", charDelta: 1)
            await model.deleteFocusedBlock()

            let slots = try await db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(slots.count == 2, "the block SURVIVES a refused flush")
            #expect(slots[0].blockID == first.block.id)
            #expect(model.statusMessage?.hasPrefix("Unsaved changes couldn't be written") == true,
                    "…and it says why — the same sentence Write's door speaks")
        }
    }

    /// 13c Stage 1 ladder, R2-2 — her A13(a): *"callouts in Takes/Compare/
    /// Lenses"*. The frame lands on the FOCUSED block, right there, with no
    /// mode switch anywhere in the flow. Red on the old code by
    /// construction twice over: `TakesViewModel` had no callout door at all,
    /// and the registry declared the act `writeEditor`-only so the menu was
    /// grey here.
    @Test func theCalloutDoorFramesTheFocusedBlockNativelyInTakes() async throws {
        try await withSessionWorld { session, db in
            let post = try session.operations.createPost(title: "framed")
            let first = try session.operations.newBlock(in: post.id, text: "first block.")
            _ = try session.operations.newBlock(in: post.id, text: "second block.")
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })

            // No focus on a MULTI-block post: fire-and-speak, no guess.
            await model.applyCallout(.toggle)
            var frames = try await db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(frames.isEmpty, "no target — nothing framed")
            #expect(model.statusMessage?.isEmpty == false, "…and it says so (P-2)")

            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: first.block.id, variantID: first.variant.id))
            await model.applyCallout(.color("sand"))
            frames = try await db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(frames[first.block.id]?.color == "sand",
                    "the frame is the BLOCK's — Takes sets it without leaving Takes")

            // The emoji door keeps the colour, and the toggle takes it away.
            await model.applyCallout(.emoji("💡"))
            frames = try await db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(frames[first.block.id]?.color == "sand")
            #expect(frames[first.block.id]?.emoji == "💡")
            await model.applyCallout(.toggle)
            frames = try await db.read { try Queries.blockPresentations($0, containerID: post.id) }
            #expect(frames.isEmpty)
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

            // 13d Batch 3: this pin exercises the CHOREOGRAPHY, and it
            // uses EXTRACT because divide stopped carrying — it acts
            // natively on the board now (A9). The machinery is unchanged;
            // only the sample act moved off a retired flow.
            model.moveToWriteAndRun(.structural(.extract))
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

            // 13d Batch 3: this pin exercises the CHOREOGRAPHY, and it
            // uses EXTRACT because divide stopped carrying — it acts
            // natively on the board now (A9). The machinery is unchanged;
            // only the sample act moved off a retired flow.
            session.commandRouter.pendingWriteIntent = WriteIntent(
                postID: postP.id, blockID: mintedP.block.id,
                offsetInBlock: 21, selectionLength: 21,
                followUp: .structural(.extract))

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
                postID: "p", blockID: nil, followUp: .structural(.extract))
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
                postID: "s", blockID: nil, followUp: .structural(.extract))
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

            // 13d Batch 3: this pin exercises the CHOREOGRAPHY, and it
            // uses EXTRACT because divide stopped carrying — it acts
            // natively on the board now (A9). The machinery is unchanged;
            // only the sample act moved off a retired flow.
            model.moveToWriteAndRun(.structural(.extract))
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

            // 13g batch 5: poll the LAST signal in the chain. `lockPost`
            // lands inside `session.runner.run` — an actor hop — and the
            // status is spoken only after the door's main-actor continuation
            // resumes, so a poll on the STORE can exit before the report
            // exists (the traced shell-redo flake, same shape).
            await poll { session.status.current?.text.contains("Sealed") == true }
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
                    == "Sealing acts on an open note — open one first.")
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

// MARK: - The Act 10 correction round, batch G — row 86(d)

/// **The ⌘K "Block History" row from a mode with no surface handler.** Her
/// walk (F's (d), verified by G on the running build): Blocks, row 03
/// selected, ⌘K "block history" ⏎ → the toast "Put the caret in a block and
/// its History shows…" and no pane. The palette act dispatched to the
/// mounted SURFACE's command handler, which Read's faces and Blocks never
/// register — so it fell through to the registry's note while the block
/// was plainly focused (row 39's memory holds it). RED ON OLD: nothing
/// opened and the refusal spoke.
@MainActor
@Suite("The palette's Block History row where no surface handles it (correction round, row 86(d))")
struct BlockHistoryPaletteDoorTests {
    @Test func thePaletteRowOpensTheFocusedBlocksHistoryWhereNoSurfaceHandlesIt() async throws {
        try await withSessionWorld { session, _ in
            let post = try session.operations.createPost(title: "in blocks mode")
            let minted = try session.operations.newBlock(
                in: post.id, text: "the block she selected in Blocks.")
            var opened: [BlockHistoryRequest] = []
            let token = session.commandRouter.registerDetail(
                postID: post.id, mode: .blocks, applyMode: { _ in },
                showBlockHistory: { opened.append($0) })
            defer { session.commandRouter.unregisterDetail(token) }
            // Blocks reports its selected row as the current block (row 39)
            // and registers NO command handler — the walk's exact state.
            session.commandRouter.noteFocusedBlock(
                minted.block.id, variantID: minted.variant.id, postID: post.id)
            #expect(session.commandRouter.handlerCount == 0, "no surface handler is mounted")

            let actions = ShellActions(session: session, shell: ShellRouter())
            let row = try #require(
                actions.paletteEntries().first { $0.title == BlockHistoryPath.name },
                "the palette carries the Block History row")
            row.action()
            #expect(opened == [BlockHistoryRequest(
                postID: post.id, blockID: minted.block.id,
                focusedVariantID: minted.variant.id)],
                "the row opened the FOCUSED block's history through the detail's inspector")
            #expect(session.status.current == nil, "no refusal spoke — the pane opened")

            // With no block in hand at all, the honest note still speaks.
            session.commandRouter.noteFocusedBlock(nil, variantID: nil, postID: post.id)
            row.action()
            #expect(opened.count == 1, "nothing to open without a focused block")
            #expect(session.status.current?.text
                == CapabilityRegistry.capability(.showBlockHistory).unavailableNote)
        }
    }
}
