//
//  TakesStepFollowTests.swift
//  VariorumTests
//
//  VX-227 (the VX-214 run) — HER RULING R-VX214-1 (2026-10-13): *"if you
//  step the pick under a pane you're editing in takes, the live editor
//  should follow the step — it should be visible to you what you've done and
//  it makes editing with the keyboard more ergonomic."*
//
//  THE MECHANISM (the run record's BATCH 4 RECORD in
//  `notes/plans/fixes/vx-214-settings-launch-polish.md`): ⌃⌘←/→ moved the
//  PICK (Lenses) or the RING (Takes) but never the live editor onto a pane
//  that renders the stepped-to take. On the Lenses board the column's
//  stable-identity cell re-resolved under a ring still keyed to the OLD take
//  (the cell went read-only; the ring named a pane nothing renders), and
//  stepping BACK turned that same pane live in place — and a live pane never
//  adopts projection text, so it kept the other take's words while every
//  keystroke landed in the take it was keyed to (VX-222's step 4, reached by
//  stepping). On the Takes board a step from the ARTICLE keyed the ring to
//  `takes-main|<next>`, a key the article never renders (it shows the chosen
//  take only): the ring vanished.
//
//  THE RULE these pins hold: after a step the ONE live pane is the pane that
//  renders the stepped-to take, it shows that take's own text, and no pane
//  she can type into ever holds another take's words — the keystroke drives
//  the real edit door wherever a pane is open.
//
//  RED ON OLD: all three.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private let takeAText = "The first take of the paragraph, as the note first said it."
private let takeBText = "A second take with quite different words, for stepping."

@MainActor
private func freshDefaults(_ name: String) -> UserDefaults {
    let suite = "TakesStepFollowTests-\(name)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

/// One note: a block with two takes — A (chosen) and B (branched from it,
/// then rewritten so the two can never be mistaken for each other) — and a
/// plain second block.
@MainActor
private struct StepWorld {
    let postID: String
    let blockID: String
    let takeA: String
    let takeB: String
    let otherBlockID: String
    let otherVariantID: String

    static func make(_ session: AppSession) throws -> StepWorld {
        let post = try session.operations.createPost(title: "the stepping post")
        let minted = try session.operations.newBlock(in: post.id, text: takeAText)
        let b = try session.operations.branchVariant(minted.block.id, from: minted.variant.id)
        try session.operations.autosave(b.id, text: takeBText, charDelta: 30)
        let other = try session.operations.newBlock(in: post.id, text: "A second block, never fanned.")
        return StepWorld(
            postID: post.id, blockID: minted.block.id,
            takeA: minted.variant.id, takeB: b.id,
            otherBlockID: other.block.id, otherVariantID: other.variant.id)
    }
}

@MainActor
private func withStepWorld<T>(
    _ name: String,
    _ body: @MainActor (AppSession, AppDatabase, StepWorld, UserDefaults) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 227))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let defaults = freshDefaults(name)
        let world = try StepWorld.make(session)
        return try await body(session, db, world, defaults)
    }
}

private func storeText(_ db: AppDatabase, _ variantID: String) async throws -> String {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT working_text FROM variant WHERE id = ?",
            arguments: [variantID]) ?? "MISSING"
    }
}

@MainActor
@Suite("Takes stepping — the live editor follows the step (VX-227)", .serialized)
struct TakesStepFollowTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
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
            pump()
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

    private func editable(_ hosting: NSView) -> [PaneTextView] {
        panes(in: hosting).filter(\.isEditable)
    }

    /// The variant a pane renders — the last field of its identifier
    /// (`pane:<role>|<variantID>`).
    private func variant(of pane: PaneTextView) -> String {
        String(pane.identifier?.rawValue.split(separator: "|").last ?? "")
    }

    private func role(of pane: PaneTextView) -> String {
        let raw = pane.identifier?.rawValue ?? ""
        return String(raw.split(separator: "|").first ?? "")
    }

    private func window() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// Her keystroke, through the real edit door, at the end of the pane.
    private func type(_ text: String, into pane: PaneTextView, in window: NSWindow) {
        window.makeFirstResponder(pane)
        pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
        pane.insertText(text, replacementRange: pane.selectedRange())
    }

    /// No pane she can type into holds another take's words.
    private func expectEveryEditablePaneShowsItsOwnTake(
        _ hosting: NSView, _ db: AppDatabase, _ moment: String
    ) async throws {
        for pane in editable(hosting) {
            let store = try await storeText(db, variant(of: pane))
            #expect(pane.string == store,
                    "\(moment): the editable pane \(pane.identifier?.rawValue ?? "?") shows its own take's text (shows: \(pane.string))")
        }
    }

    // MARK: - Lenses: the step under a live ring (RED ON OLD)

    /// The pick-moving doors under a live ring (F4 — ONE body): the keys
    /// (⌃⌘←/→ → `stepTakes`), the column's ‹ › switcher (`stepPick`) and the
    /// cell menu's "Show take ▸" (`pick`).
    private enum Door { case keys, switcher, showTake }

    /// ONE scratch column (it mirrors the chosen take until a step moves its
    /// pick) — every cell's pane identifier is unique on the board.
    private func scratchBoard(
        _ session: AppSession, _ world: StepWorld, _ defaults: UserDefaults
    ) throws -> (TakesViewModel, String) {
        let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
        model.host = .lenses
        model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
        return (model, try #require(model.columns.first).id)
    }

    /// ONE named-lens column (no choice yet — it shows the chosen take).
    private func lensBoard(
        _ session: AppSession, _ world: StepWorld, _ defaults: UserDefaults
    ) throws -> (TakesViewModel, String) {
        let lens = try session.operations.createLens(post: world.postID, name: "a reading")
        let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
        model.host = .lenses
        model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
        return (model, try #require(model.columns.first).id)
    }

    @Test func aScratchColumnStepFollowsAndSteppingBackNeverRevivesAStalePane() async throws {
        try await withStepWorld("scratch") { session, db, world, defaults in
            let (model, columnID) = try scratchBoard(session, world, defaults)
            try await stepFollowFlow(
                session: session, db: db, world: world, model: model, columnID: columnID, door: .keys)
        }
    }

    @Test func aNamedLensColumnStepFollowsAndSteppingBackNeverRevivesAStalePane() async throws {
        try await withStepWorld("lens") { session, db, world, defaults in
            let (model, columnID) = try lensBoard(session, world, defaults)
            try await stepFollowFlow(
                session: session, db: db, world: world, model: model, columnID: columnID, door: .keys)
        }
    }

    /// F4: the column's ‹ › switcher reaches the same body as the keys.
    @Test func theColumnSwitcherFollowsUnderTheRingToo() async throws {
        try await withStepWorld("switcher") { session, db, world, defaults in
            let (model, columnID) = try scratchBoard(session, world, defaults)
            try await stepFollowFlow(
                session: session, db: db, world: world, model: model, columnID: columnID, door: .switcher)
        }
    }

    /// F4: "Show take ▸" on the pane she is in moves the same pick.
    @Test func showTakeUnderTheRingFollowsToo() async throws {
        try await withStepWorld("showtake") { session, db, world, defaults in
            let (model, columnID) = try lensBoard(session, world, defaults)
            try await stepFollowFlow(
                session: session, db: db, world: world, model: model, columnID: columnID, door: .showTake)
        }
    }

    private func mountLenses(
        _ session: AppSession, _ world: StepWorld, _ model: TakesViewModel
    ) -> (NSWindow, NSView) {
        let window = window()
        let hosting = NSHostingView(
            rootView: LensesBoardView(session: session, postID: world.postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// Her flow on the real Lenses board: click into the column's pane on
    /// take A, type, step (the live editor follows onto B, VISIBLY, with B's
    /// own words), step back (onto A — with A's own words), type again.
    private func stepFollowFlow(
        session: AppSession, db: AppDatabase, world: StepWorld,
        model: TakesViewModel, columnID: String, door: Door
    ) async throws {
        let observing = Task { await model.start() }
        let (window, hosting) = mountLenses(session, world, model)
        defer {
            model.teardown()
            observing.cancel()
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting, until: {
            panes(in: hosting).contains { variant(of: $0) == world.takeA }
        })

        @MainActor func step(_ delta: Int) async throws {
            switch door {
            case .keys:
                await model.stepTakes(by: delta)
            case .switcher:
                let slot = try #require(model.projection.slots.first { $0.blockID == world.blockID })
                await model.stepPick(columnID: columnID, slot: slot, by: delta)
            case .showTake:
                await model.pick(
                    columnID: columnID, blockID: world.blockID,
                    variantID: delta > 0 ? world.takeB : world.takeA)
            }
        }

        // Her click into the column's pane (the ring on take A).
        let ringA = TakesViewModel.PaneKey(
            columnID: columnID, blockID: world.blockID, variantID: world.takeA)
        model.focus(ringA)
        await settle(window, hosting, until: { editable(hosting).count == 1 })
        let first = try #require(editable(hosting).first, "non-vacuity: the pane she clicked is live")
        #expect(variant(of: first) == world.takeA)
        type("!", into: first, in: window)

        // The step moves the column's pick to B. One live ring at every
        // instant (rider 2): sampled on every settle turn, never two.
        var mostLive = 0
        try await step(1)
        await settle(window, hosting, until: {
            mostLive = max(mostLive, editable(hosting).count)
            return editable(hosting).first.map { variant(of: $0) } == world.takeB
        })
        await settle(window, hosting, until: { false }, maxTurns: 4)
        #expect(model.focusedPane == TakesViewModel.PaneKey(
            columnID: columnID, blockID: world.blockID, variantID: world.takeB),
            "the live editor follows the step onto the newly picked take")
        let followed = editable(hosting)
        #expect(followed.count == 1, "exactly one live pane after the step (found \(followed.count))")
        #expect(followed.first.map { variant(of: $0) } == world.takeB,
                "the live pane is the one that renders B")
        try await expectEveryEditablePaneShowsItsOwnTake(hosting, db, "after the step")

        // Back onto A: the defect's moment (the stale pane revived).
        try await step(-1)
        await settle(window, hosting, until: {
            mostLive = max(mostLive, editable(hosting).count)
            return editable(hosting).first.map { variant(of: $0) } == world.takeA
        })
        await settle(window, hosting, until: { false }, maxTurns: 4)
        #expect(model.focusedPane == ringA, "stepping back follows back onto A")
        #expect(mostLive <= 1, "never two live panes, even mid-follow (saw \(mostLive))")
        try await expectEveryEditablePaneShowsItsOwnTake(hosting, db, "after stepping back")

        // The worst consequence, through the real edit door: wherever a pane
        // is open for typing, the keystroke lands in the take it shows.
        if let live = editable(hosting).first {
            type("?", into: live, in: window)
        }
        await model.autosave.flushNow()
        let aNow = try await storeText(db, world.takeA)
        #expect(!aNow.contains("quite different words"),
                "no keystroke may write B's words into A (A: \(aNow))")
        #expect(aNow.hasPrefix(takeAText + "!"),
                "the keystroke typed before the step is in A — none died with the ring (A: \(aNow))")
        #expect(try await storeText(db, world.takeB) == takeBText, "B keeps its own words")
    }

    // MARK: - Takes: a step from the ARTICLE (RED ON OLD)

    /// The article renders the CHOSEN take only, so the pane that renders the
    /// stepped-to take is its FAN CARD (the R2-A reveal mapping): ⌃⌘→ from
    /// the article blooms the block and the live editor lands on that card,
    /// showing that take's own words.
    @Test func aStepFromTheArticleFollowsOntoTheRenderedFanCard() async throws {
        try await withStepWorld("article") { session, db, world, defaults in
            let board = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            let observing = Task { await board.start() }
            let window = window()
            defer {
                board.teardown()
                observing.cancel()
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: world.postID, model: board))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                panes(in: hosting).contains { role(of: $0) == "pane:article" && variant(of: $0) == world.takeA }
            })

            // Her click into the article (the ring on the chosen take, A).
            board.focus(.init(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.takeA))
            await settle(window, hosting, until: { editable(hosting).count == 1 })
            #expect(editable(hosting).first.map(role(of:)) == "pane:article",
                    "non-vacuity: the article is live before the step")

            await board.stepTakes(by: 1)
            await settle(window, hosting, until: {
                editable(hosting).first.map { variant(of: $0) } == world.takeB
            })
            await settle(window, hosting, until: { false }, maxTurns: 4)
            #expect(board.focusedPane == TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: world.blockID, variantID: world.takeB),
                "the ring follows onto the fan card that renders the stepped-to take")
            let live = editable(hosting)
            #expect(live.count == 1, "exactly one live pane after the step (found \(live.count))")
            if let card = live.first {
                #expect(variant(of: card) == world.takeB)
                #expect(["pane:mini", "pane:card"].contains(role(of: card)),
                        "the live pane is B's fan card, a pane the board renders (role: \(role(of: card)))")
            }
            try await expectEveryEditablePaneShowsItsOwnTake(hosting, db, "after ⌃⌘→ from the article")
            let article = panes(in: hosting).first { role(of: $0) == "pane:article" }
            #expect(article?.string == takeAText, "the article still shows the chosen take")
        }
    }

    // MARK: - F6: a mint's ring re-bind (the SPECULATIVE CONFIRM — the
    // blank-take hypothesis; red on old iff it holds)

    /// ⌥⌘T on the pane she is in: the blank take lands as the column's pick
    /// and the ring follows onto it (R2-A). The live pane must show the
    /// BLANK take's own (empty) text — the hypothesis is that the stable cell
    /// re-keyed while live keeps the source take's words.
    @Test func aBlankMintIntoAScratchColumnGoesLiveWithItsOwnText() async throws {
        try await withStepWorld("blank-scratch") { session, db, world, defaults in
            let (model, columnID) = try scratchBoard(session, world, defaults)
            try await mintFollowFlow(
                session: session, db: db, world: world, model: model, ringColumnID: columnID
            ) {
                await model.newBlankTakeRevealed(blockID: world.blockID, preferredColumnID: columnID)?.id
            }
        }
    }

    @Test func aBlankMintIntoANamedLensColumnGoesLiveWithItsOwnText() async throws {
        try await withStepWorld("blank-lens") { session, db, world, defaults in
            let (model, columnID) = try lensBoard(session, world, defaults)
            try await mintFollowFlow(
                session: session, db: db, world: world, model: model, ringColumnID: columnID
            ) {
                await model.newBlankTakeRevealed(blockID: world.blockID, preferredColumnID: columnID)?.id
            }
        }
    }

    /// ⇧⌥⌘T on the Lenses board's Chosen column (`revealChosenTake`'s Lenses
    /// arm — the sibling re-ring, the addendum to the F1–F6 ruling).
    @Test func aBlankChosenMintOnTheChosenColumnGoesLiveWithItsOwnText() async throws {
        try await withStepWorld("blank-chosen") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.host = .lenses
            let columnID = try #require(model.columns.first { $0.kind == .main }).id
            try await mintFollowFlow(
                session: session, db: db, world: world, model: model, ringColumnID: columnID
            ) {
                await model.newBlankTakeAsChosen(blockID: world.blockID)
                return try? await db.read { [blockID = world.blockID] db in
                    try String.fetchOne(
                        db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                        arguments: [blockID])
                }
            }
        }
    }

    private func mintFollowFlow(
        session: AppSession, db: AppDatabase, world: StepWorld,
        model: TakesViewModel, ringColumnID: String,
        mint: @MainActor () async -> String?
    ) async throws {
        let observing = Task { await model.start() }
        let (window, hosting) = mountLenses(session, world, model)
        defer {
            model.teardown()
            observing.cancel()
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting, until: {
            panes(in: hosting).contains { variant(of: $0) == world.takeA }
        })
        model.focus(.init(columnID: ringColumnID, blockID: world.blockID, variantID: world.takeA))
        await settle(window, hosting, until: { editable(hosting).count == 1 })
        #expect(editable(hosting).first.map { variant(of: $0) } == world.takeA,
                "non-vacuity: she is in A's pane")

        let mintedID = await mint()
        let blank = try #require(mintedID, "the blank take was minted")
        #expect(try await storeText(db, blank) == "", "fixture: the mint is blank")
        await settle(window, hosting, until: {
            editable(hosting).first.map { variant(of: $0) } == blank
        })
        await settle(window, hosting, until: { false }, maxTurns: 4)
        #expect(editable(hosting).count == 1, "the ring follows onto the mint")
        #expect(editable(hosting).first.map { variant(of: $0) } == blank)
        try await expectEveryEditablePaneShowsItsOwnTake(hosting, db, "after the blank mint")

        if let live = editable(hosting).first {
            type("x", into: live, in: window)
        }
        await model.autosave.flushNow()
        let blankNow = try await storeText(db, blank)
        #expect(blankNow == "x",
                "her first keystroke in the blank take is all it holds (blank: \(blankNow))")
        #expect(try await storeText(db, world.takeA) == takeAText, "A keeps its own words")
    }
}

// MARK: - The rules at the model (no mounted cell)

@MainActor
@Suite("Takes stepping — the follow's rules at the model (VX-227)", .serialized)
struct TakesStepFollowModelTests {
    private func fresh(_ db: AppDatabase, _ postID: String) async throws -> Queries.TakesProjection {
        try await db.read { try Queries.takesProjection($0, post: postID) }
    }

    /// THE ONE-RING CONTRACT, AS DATA: the live pane (if any) is a pane its
    /// column RENDERS — the column resolves the ring's block to the ring's
    /// take. A ring on a key its column does not resolve is the stranded
    /// ring every revival in this class grows from.
    private func ringIsRendered(_ model: TakesViewModel) -> Bool {
        guard let ring = model.focusedPane else { return true }
        guard let column = model.columns.first(where: { $0.id == ring.columnID }),
              let slot = model.projection.slots.first(where: { $0.blockID == ring.blockID })
        else { return false }
        return model.resolvedTake(column: column, slot: slot)?.variantID == ring.variantID
    }

    private func lensesModel(
        _ session: AppSession, _ db: AppDatabase, _ world: StepWorld, _ defaults: UserDefaults
    ) async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
        model.host = .lenses
        model.adopt(try await fresh(db, world.postID))
        return model
    }

    /// The model twin of the mounted step pins (RED ON OLD): after a step on
    /// a scratch column and on a named lens, the ring is never stranded.
    @Test func aStepNeverLeavesTheRingOnAPaneItsColumnNoLongerRenders() async throws {
        try await withStepWorld("twin") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
            let scratchID = try #require(model.columns.first).id
            model.focus(.init(columnID: scratchID, blockID: world.blockID, variantID: world.takeA))
            await model.stepTakes(by: 1)
            #expect(ringIsRendered(model), "scratch: the step never strands the ring (ring: \(String(describing: model.focusedPane)))")

            let lens = try session.operations.createLens(post: world.postID, name: "twin")
            model.replaceColumnWithLens(scratchID, lensID: lens.id)
            model.adopt(try await fresh(db, world.postID))
            model.focus(.init(columnID: scratchID, blockID: world.blockID, variantID: world.takeA))
            await model.stepTakes(by: 1)
            model.adopt(try await fresh(db, world.postID))
            #expect(ringIsRendered(model), "named lens: the step never strands the ring (ring: \(String(describing: model.focusedPane)))")
        }
    }

    /// F3 (RED ON OLD): the Chosen column has no pick to step — ⌃⌘→ there
    /// speaks the column's own refusal and the ring stays where she is.
    @Test func steppingOnTheChosenColumnRefusesAndKeepsTheRing() async throws {
        try await withStepWorld("chosen-step") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            let main = try #require(model.columns.first { $0.kind == .main })
            let ring = TakesViewModel.PaneKey(
                columnID: main.id, blockID: world.blockID, variantID: world.takeA)
            model.focus(ring)
            await model.stepTakes(by: 1)
            #expect(model.focusedPane == ring, "the ring stays on the pane she is in")
            #expect(model.statusMessage == "The main column shows the note's chosen takes — use ✓ to change them.",
                    "the refusal is the column's own words (said: \(model.statusMessage ?? "nothing"))")
            #expect(model.status?.isRefusal == true)
            #expect(ringIsRendered(model))
        }
    }

    /// F5 (RED ON OLD): a lens pick moved by ANY road but the step — sync, an
    /// agent's `setLensChoice`, another window, undo — re-resolves the cell
    /// under the ring; the ring ENDS (VX-222's rule, on the Lenses host),
    /// so it can never come back to life over the other take's words.
    @Test func aLensPickMovedElsewhereEndsTheRing() async throws {
        try await withStepWorld("external") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            let lens = try session.operations.createLens(post: world.postID, name: "elsewhere")
            model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
            model.adopt(try await fresh(db, world.postID))
            let columnID = try #require(model.columns.first).id
            let ring = TakesViewModel.PaneKey(
                columnID: columnID, blockID: world.blockID, variantID: world.takeA)
            model.focus(ring)

            // The store moves the pick (the adoption is the one door every road
            // reaches the board through).
            _ = try session.operations.setLensChoice(lens: lens.id, block: world.blockID, variant: world.takeB)
            model.adopt(try await fresh(db, world.postID))
            #expect(model.focusedPane == nil, "the cell changed take under the ring — the ring ends")

            // …and moving it back never revives a live pane over B's words.
            _ = try session.operations.setLensChoice(lens: lens.id, block: world.blockID, variant: world.takeA)
            model.adopt(try await fresh(db, world.postID))
            #expect(!model.isPaneLive(ring))
        }
    }

    /// F5 (RED ON OLD): choosing under a Chosen-column ring (✓, ⌘⏎, the
    /// agent's `choose_take`) — the Chosen column re-resolves under it.
    @Test func aChoiceUnderAChosenColumnRingEndsTheRing() async throws {
        try await withStepWorld("choose") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            let main = try #require(model.columns.first { $0.kind == .main })
            let ring = TakesViewModel.PaneKey(
                columnID: main.id, blockID: world.blockID, variantID: world.takeA)
            model.focus(ring)
            await model.choose(blockID: world.blockID, variantID: world.takeB)
            model.adopt(try await fresh(db, world.postID))
            #expect(model.focusedPane == nil, "the Chosen column now shows B — the ring keyed to A ends")
            await model.choose(blockID: world.blockID, variantID: world.takeA)
            model.adopt(try await fresh(db, world.postID))
            #expect(!model.isPaneLive(ring), "choosing A back never revives the pane over B's words")
        }
    }

    // MARK: - Guards (green on both sides)

    /// A pick on a block the ring is NOT in leaves the ring alone (F4's
    /// "off-ring picks leave the ring alone").
    @Test func aPickElsewhereLeavesTheRingAlone() async throws {
        try await withStepWorld("offring") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
            let columnID = try #require(model.columns.first).id
            let ring = TakesViewModel.PaneKey(
                columnID: columnID, blockID: world.otherBlockID, variantID: world.otherVariantID)
            model.focus(ring)
            await model.pick(columnID: columnID, blockID: world.blockID, variantID: world.takeB)
            #expect(model.focusedPane == ring)
            #expect(model.isPaneLive(ring))
        }
    }

    /// An adoption that leaves the ring's column resolution alone (another
    /// block's edit, an identical re-read) keeps the ring — the model, never
    /// the viewport (VX-222's rider 1, on the Lenses host).
    @Test func anAdoptionThatLeavesTheRingsTakeAloneKeepsTheRing() async throws {
        try await withStepWorld("keep") { session, db, world, defaults in
            let model = try await lensesModel(session, db, world, defaults)
            let lens = try session.operations.createLens(post: world.postID, name: "kept")
            model.replaceColumnWithLens(try #require(model.columns.first).id, lensID: lens.id)
            model.adopt(try await fresh(db, world.postID))
            let ring = TakesViewModel.PaneKey(
                columnID: try #require(model.columns.first).id,
                blockID: world.blockID, variantID: world.takeA)
            model.focus(ring)
            try await session.runner.run { [world] ops in
                try ops.autosave(world.otherVariantID, text: "Another block, edited elsewhere.", charDelta: 8)
            }
            model.adopt(try await fresh(db, world.postID))
            model.adopt(try await fresh(db, world.postID))
            #expect(model.focusedPane == ring)
            #expect(model.isPaneLive(ring))
        }
    }
}
