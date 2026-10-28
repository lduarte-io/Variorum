//
//  TakesExpansionMemoryTests.swift
//  VariorumTests
//
//  VX-601 batch B — **VX-428** (her ruling R-601-2: the Takes board's open
//  fans survive a brief mode switch — the session's per-note memory, the
//  VX-170 road, R-VX170-5) and **VX-577** (expand all / close all in SLOT
//  SPLIT — her word: *"where is expand all takes when you're in slot split??
//  you still need it lowkey"*).
//
//  THE TRACED MECHANISM (VX-428, the batch B record): `PostDetailView` mounts
//  `TakesBoardView` only while the mode is Takes and gives it `.id("takes-…")`,
//  so a mode switch destroys the board and its per-mount `@State`
//  `TakesViewModel` — and with it `TakesBoardLayout.expandedBlocks`, the
//  open-fan set. On the pre-fix tree a fresh board therefore always opens
//  every fan CLOSED. The fix keeps the set per note on the session
//  (`EditorRouter.takesExpandedBlocks`), seeds a fresh board at construction
//  (before its first geometry report) and writes every change back.
//
//  Her requirement rides the member, verbatim: *"any relevant performance or
//  rendering calculations need to be made and we need to make sure this
//  doesn't degrade the app in other ways (like getting to the right
//  location)"* — so the mounted pins below prove the restore and the entry
//  landing still reach the right block with a seeded set in place, and the
//  cost suite measures the seeded remount (its numbers print as
//  `VX428-MEASURE` lines into the run's log and land in the batch B record).
//
//  Every mounted suite waits on `HostLaunchSettle` first (batch A's rig
//  diagnosis: never pump the run loop into the test host's own launch), then
//  pins the Terminal metrics the article's landing constants assume.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The shared world

/// One note of `count` blocks; block `i` (0-based) carries a second, distinct
/// take when `fanned(i)` — the chosen take first, the spare second.
@MainActor
private struct ExpansionWorld {
    let session: AppSession
    let db: AppDatabase
    let postID: String
    let blocks: [(block: String, chosen: String, spare: String?)]
    let defaults: UserDefaults

    var blockIDs: [String] { blocks.map(\.block) }
    var fannedBlockIDs: Set<String> { Set(blocks.filter { $0.spare != nil }.map(\.block)) }

    func projection() async throws -> Queries.TakesProjection {
        try await db.read { [postID] in try Queries.takesProjection($0, post: postID) }
    }

    /// A model wired the way `TakesBoardView.init` wires the app's: built,
    /// then told it is THE takes board — which is the moment VX-428 seeds it —
    /// and only THEN handed its first projection.
    func boardModel() async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        model.landingEnabled = true
        model.adopt(try await projection())
        return model
    }

    /// The model Write's take panel builds (never told it is the board).
    func panelModel() async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        model.writePanelBlockID = blocks.first?.block
        model.adopt(try await projection())
        return model
    }

    var remembered: Set<String>? { session.editorRouter.takesExpandedBlocks[postID] }
}

nonisolated private func expansionProse(_ i: Int) -> String {
    "Paragraph \(i). Honest prose on the measured line, long enough to wrap "
        + "once at the article's measure so the rows have real height."
}

@MainActor
private func withExpansionWorld(
    blocks count: Int,
    style: FanStyle = .stack,
    fanned: @escaping (Int) -> Bool = { _ in true },
    _ body: @MainActor (ExpansionWorld) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    let suiteName = "TakesExpansionMemory-\(UUID().uuidString)"
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 428))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(.terminal)
        try session.operations.setFanStyle(style)
        let post = try session.operations.createPost(title: "expansion memory fixture")
        var made: [(block: String, chosen: String, spare: String?)] = []
        for i in 0..<count {
            let minted = try session.operations.newBlock(in: post.id, text: expansionProse(i + 1))
            var spare: String?
            if fanned(i) {
                let take = try session.operations.branchVariant(
                    minted.block.id, from: minted.variant.id)
                try session.operations.autosave(
                    take.id, text: "The other take of paragraph \(i + 1), its own words.",
                    charDelta: 40)
                spare = take.id
            }
            made.append((minted.block.id, minted.variant.id, spare))
        }
        try await body(ExpansionWorld(
            session: session, db: db, postID: post.id, blocks: made, defaults: defaults))
    }
}

// MARK: - The memory's own state transitions (no mount)

@MainActor
@Suite("VX-428 — the board's open fans, remembered per note for the session", .serialized)
struct TakesExpansionMemoryTests {

    /// **RED ON OLD (the memory never written).** Every change THE takes
    /// board's layout makes is in the session at once — her badge, expand
    /// all, a close of one, close all (which forgets the note: no empty set is
    /// stored) — and another note keeps its own.
    @Test func theBoardsOpenFansAreWrittenToTheSessionAsTheyChange() async throws {
        try await withExpansionWorld(blocks: 4, fanned: { $0 != 3 }) { world in
            let model = try await world.boardModel()
            let b = world.blockIDs
            #expect(world.remembered == nil, "non-vacuity: a fresh session remembers nothing")

            model.toggleExpanded(b[0])
            #expect(world.remembered == [b[0]], "her badge — remembered at once")
            model.expandAllFans()
            #expect(world.remembered == world.fannedBlockIDs,
                    "expand all — every FANNED block (\(String(describing: world.remembered)))")
            model.toggleExpanded(b[1])
            #expect(world.remembered == world.fannedBlockIDs.subtracting([b[1]]),
                    "one fan closed — the rest still remembered")
            model.board.bloom(b[3])  // a reveal's bloom (the unfanned block's first-take door)
            #expect(world.remembered?.contains(b[3]) == true, "a reveal's bloom is a change too")

            // Another note's fans are its own (the dictionary is per note).
            world.session.editorRouter.takesExpandedBlocks["another-note"] = ["x"]
            model.closeAllFans()
            #expect(world.remembered == nil,
                    "close all (⎋) forgets this note — never an empty set stored")
            #expect(world.session.editorRouter.takesExpandedBlocks["another-note"] == ["x"],
                    "…and leaves every other note's memory alone")
        }
    }

    /// **RED ON OLD — the construction-time fact.** A FRESH board (a mode round
    /// trip: a new model) holds the remembered set the moment it is told it
    /// is THE takes board — BEFORE its first projection, so the first render
    /// draws the fans open and the first geometry report is judged with them
    /// (the 17q R1-1 lesson, `TakesBoardView.init`).
    @Test func aFreshBoardIsSeededBeforeItsFirstProjection() async throws {
        try await withExpansionWorld(blocks: 4) { world in
            let first = try await world.boardModel()
            first.toggleExpanded(world.blockIDs[1])
            first.toggleExpanded(world.blockIDs[2])
            first.teardown()

            let second = TakesViewModel(
                session: world.session, postID: world.postID, defaults: world.defaults)
            #expect(second.expandedBlocks.isEmpty,
                    "non-vacuity: before it is THE board, a model holds nothing")
            second.landingEnabled = true  // `TakesBoardView.init`'s construction-time line
            #expect(!second.loaded, "non-vacuity: no projection has arrived yet")
            #expect(second.expandedBlocks == [world.blockIDs[1], world.blockIDs[2]],
                    "the fans she left open are in place before the first projection")
            second.adopt(try await world.projection())
            #expect(second.expandedBlocks == [world.blockIDs[1], world.blockIDs[2]],
                    "…and the first projection keeps every block the note still holds")
            #expect(second.isBloomed(try #require(second.projection.slots.first {
                $0.blockID == world.blockIDs[1]
            })), "the remembered block BLOOMS — the board draws it open")
            second.teardown()
        }
    }

    /// **RED ON OLD.** A remembered block the note no longer holds (deleted on
    /// the way, merged away, gone by sync) is pruned by the FIRST projection —
    /// layout and memory alike; inside one showing a block that leaves keeps
    /// its open state exactly as before (a ⌥⌘Z that puts it back brings it
    /// back open).
    @Test func theFirstProjectionPrunesBlocksTheNoteNoLongerHolds() async throws {
        try await withExpansionWorld(blocks: 3) { world in
            let b = world.blockIDs
            world.session.editorRouter.takesExpandedBlocks[world.postID] = [b[0], "a-block-long-gone"]
            let model = try await world.boardModel()
            #expect(model.expandedBlocks == [b[0]], "the gone block is pruned from the layout")
            #expect(world.remembered == [b[0]], "…and from the memory")

            // Inside the showing: a block leaving is NOT pruned (only the first
            // projection prunes) — today's in-mount behavior, unchanged.
            model.toggleExpanded(b[1])
            let without = Queries.TakesProjection(
                slots: model.projection.slots.filter { $0.blockID != b[1] },
                fans: model.projection.fans, fanStyle: model.projection.fanStyle)
            model.adopt(without)
            #expect(model.expandedBlocks.contains(b[1]),
                    "a later projection never prunes — the in-mount open state stands")
            model.teardown()
        }
    }

    /// **GUARD (green on both trees): the fence.** Write's take panel and the
    /// Lenses board are never THE takes board — they never read the note's
    /// memory and never write it, whatever they open.
    @Test func onlyTheTakesBoardReadsOrWritesTheMemory() async throws {
        try await withExpansionWorld(blocks: 3) { world in
            let b = world.blockIDs
            world.session.editorRouter.takesExpandedBlocks[world.postID] = [b[2]]

            let panel = try await world.panelModel()
            #expect(panel.expandedBlocks.isEmpty, "Write's panel is never seeded")
            panel.toggleExpanded(b[0])
            panel.expandAllFans()
            #expect(world.remembered == [b[2]], "…and never writes the note's memory")
            panel.teardown()

            let lenses = TakesViewModel(
                session: world.session, postID: world.postID, defaults: world.defaults)
            lenses.host = .lenses
            lenses.adopt(try await world.projection())
            lenses.toggleExpanded(b[1])
            #expect(lenses.expandedBlocks == [b[1]])
            #expect(world.remembered == [b[2]], "the Lenses board neither")
            lenses.teardown()
        }
    }

    /// **GUARD: the `show ▾` filter's fresh page is a change like any other**
    /// — applying a filter starts from the plain page (R-VX170: every open fan
    /// closes), so the memory forgets the note's fans with it.
    @Test func applyingAShowFilterForgetsTheFansItCloses() async throws {
        try await withExpansionWorld(blocks: 3) { world in
            let lens = try world.session.operations.createLens(
                post: world.postID, name: "a lens")
            let model = try await world.boardModel()
            model.host = .takes
            model.expandAllFans()
            #expect(world.remembered == world.fannedBlockIDs, "non-vacuity: fans remembered")
            model.lensFilter.set(.inLens(lens.id))
            #expect(model.expandedBlocks.isEmpty, "the filter starts from the plain page")
            #expect(world.remembered == nil, "…and the memory follows it")
            model.teardown()
        }
    }
}

// MARK: - The mounted board (her "getting to the right location")

@MainActor
@Suite("VX-428 — a seeded board still lands where it should (mounted)", .serialized)
struct TakesExpansionRemountTests {

    private func pump(_ seconds: TimeInterval = 0.02) {
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

    fileprivate static func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    fileprivate static func panes(_ role: String, in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:\(role)|") == true }
    }

    /// The ARTICLE's scroll view: the outermost `NSScrollView` above any pane
    /// (the article column's own; the slot-split strips nest inside it).
    private func articleScrollView(in root: NSView) -> NSScrollView? {
        guard let pane = Self.panes(in: root).first else { return nil }
        var outermost: NSScrollView?
        var current: NSView? = pane.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { outermost = scroll }
            current = node.superview
        }
        return outermost
    }

    private func offset(_ scroll: NSScrollView) -> CGFloat {
        scroll.contentView.bounds.origin.y
    }

    private func scroll(_ scroll: NSScrollView, to y: CGFloat) {
        scroll.contentView.scroll(to: NSPoint(x: 0, y: y))
        scroll.reflectScrolledClipView(scroll.contentView)
    }

    /// The ARTICLE take nearest the viewport's top edge (still crossing it or
    /// below it) — "where she left it" is a ROW on this surface, never a raw
    /// offset (`TakesArticleScrollTests.topOfPage`'s rule).
    private func topOfPage(_ hosting: NSView, _ article: NSScrollView) -> String? {
        let visible = article.contentView.bounds
        var best: (String, CGFloat)?
        for pane in Self.panes("article", in: hosting) {
            let rect = pane.convert(pane.bounds, to: article.contentView)
            guard rect.maxY > visible.minY else { continue }
            let into = rect.minY - visible.minY
            if best == nil || into < best!.1 {
                best = (pane.identifier?.rawValue
                    .replacingOccurrences(of: "pane:article|", with: "") ?? "", into)
            }
        }
        return best?.0
    }

    private func mount(
        _ model: TakesViewModel, _ world: ExpansionWorld, height: CGFloat = 700
    ) async -> (NSWindow, NSHostingView<TakesBoardView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1100, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: TakesBoardView(session: world.session, postID: world.postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: { !Self.panes(in: hosting).isEmpty })
        await settle(window, hosting, until: { false }, maxTurns: 8)
        return (window, hosting)
    }

    private func close(_ window: NSWindow, _ model: TakesViewModel) {
        model.teardown()
        window.orderOut(nil)
        window.close()
    }

    /// **RED ON OLD in its first half; her requirement's proof in its second.**
    /// The mode round trip: she opens fans (above the page AND on it), scrolls
    /// deep, leaves; a FRESH board comes back with the same fans open — drawn
    /// as cards — AND on the block she was reading (±1, the row is the memory;
    /// `TakesArticleScrollTests.aBoardLeftScrolledComesBackWhereSheLeftIt`'s
    /// own tolerance), with the restore actually aiming.
    @Test func aModeRoundTripComesBackWithItsFansOpenAndOnTheSameBlock() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 40) { world in
            let router = world.session.commandRouter
            router.forgetCurrentBlock(for: world.postID)
            defer { router.forgetCurrentBlock(for: world.postID) }

            let first = try await world.boardModel()
            let open: Set<String> = [world.blockIDs[2], world.blockIDs[9], world.blockIDs[14]]
            for id in open { first.toggleExpanded(id) }
            let (windowA, hostingA) = await mount(first, world)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            first.clearArticleLanding()
            scroll(articleA, to: 900)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(abs(offset(articleA) - 900) < 2, "non-vacuity: the scroll landed (\(offset(articleA)))")
            let before = try #require(topOfPage(hostingA, articleA), "a take at the top of the page")
            #expect(world.remembered == open, "the session holds the fans she opened")
            close(windowA, first)
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await world.boardModel()
            #expect(second.expandedBlocks == open,
                    "the fresh board is born with her fans open (\(second.expandedBlocks.count) of \(open.count))")
            let (windowB, hostingB) = await mount(second, world)
            defer { close(windowB, second) }
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 14)

            #expect(second.board.articleRestoreAims > 0,
                    "the restore RAN (\(second.board.articleRestoreAims) aims)")
            let after = try #require(topOfPage(hostingB, articleB), "a take at the top after the remount")
            let index = { (variantID: String) -> Int? in
                world.blocks.firstIndex { $0.chosen == variantID }
            }
            let wasAt = try #require(index(before)), isAt = try #require(index(after))
            #expect(abs(isAt - wasAt) <= 1,
                    """
                    with three fans open (two above the page) the board comes back \
                    on the block she was reading — block \(isAt + 1), left on \
                    block \(wasAt + 1) of \(world.blocks.count)
                    """)
            // The open fans that are realized draw their cards (stack style).
            let realizedOpen = open.filter { id in
                guard let block = world.blocks.first(where: { $0.block == id }) else { return false }
                return !Self.panes("article", in: hostingB).filter {
                    $0.identifier?.rawValue == "pane:article|\(block.chosen)"
                }.isEmpty
            }
            for id in realizedOpen {
                let spare = try #require(world.blocks.first { $0.block == id }?.spare)
                #expect(Self.panes("card", in: hostingB).contains {
                    $0.identifier?.rawValue == "pane:card|\(spare)"
                }, "an open fan on screen draws its cards")
            }
        }
    }

    /// **PROOF (green on both trees — the old tree has no fans to seed):** an
    /// entry landing on a FAR block still reveals it with remembered fans
    /// open ABOVE it — the rows the landing must scroll past are taller than
    /// their estimates, and the margin rail is engaged from the first frame.
    /// Every style.
    @Test(arguments: [FanStyle.stack, .marginGrid, .slotSplit, .carousel])
    func anEntryLandingStillReachesAFarBlockWithFansOpenAboveIt(style: FanStyle) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 24, style: style) { world in
            let router = world.session.commandRouter
            router.forgetCurrentBlock(for: world.postID)
            defer { router.forgetCurrentBlock(for: world.postID) }
            let token = router.registerDetail(postID: world.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            let far = try #require(world.blocks.last)
            router.noteFocusedBlock(
                far.block, variantID: far.chosen, postID: world.postID, utf16Offset: 0)
            // Eight fans open above the far block; the far block itself closed.
            world.session.editorRouter.takesExpandedBlocks[world.postID] =
                Set(world.blockIDs.prefix(8))

            let model = try await world.boardModel()
            #expect(model.expandedBlocks.count == 8, "non-vacuity: the board was seeded")
            let (window, hosting) = await mount(model, world)
            defer { close(window, model) }
            await settle(window, hosting, until: { false }, maxTurns: 16)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            #expect(model.articleLandingAims > 0, "non-vacuity: the landing aimed the page")
            #expect(model.authority.livePane?.blockID == far.block,
                    "the ring entered on the block she came from")
            let pane = try #require(Self.panes("article", in: hosting).first {
                $0.identifier?.rawValue == "pane:article|\(far.chosen)"
            }, "the far block's row is realized")
            let visible = article.contentView.bounds
            let row = pane.convert(pane.bounds, to: article.contentView)
            #expect(row.minY >= visible.minY - 2 && row.maxY <= visible.maxY + 2,
                    "\(style): the far block is ON SCREEN (row \(row), visible \(visible))")
        }
    }

    /// **RED ON OLD (and red with only the entry mapping reverted): SLOT
    /// SPLIT's entry ring lands on a pane the board RENDERS.** A board born
    /// with the entry block's fan open has no article cell for it in slot
    /// split (the bloom replaces it with the fan's cards) — the ring lands on
    /// the card that renders the same take, live, exactly one ring on screen.
    @Test func slotSplitsEntryRingLandsOnTheCardThatRendersItsTake() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 6, style: .slotSplit) { world in
            let router = world.session.commandRouter
            router.forgetCurrentBlock(for: world.postID)
            defer { router.forgetCurrentBlock(for: world.postID) }
            let token = router.registerDetail(postID: world.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            let entry = world.blocks[2]
            router.noteFocusedBlock(
                entry.block, variantID: entry.chosen, postID: world.postID, utf16Offset: 0)
            world.session.editorRouter.takesExpandedBlocks[world.postID] = [entry.block]

            let model = try await world.boardModel()
            let slot = try #require(model.projection.slots.first { $0.blockID == entry.block })
            #expect(model.slotSplitReplacesArticleCell(slot),
                    "non-vacuity: the entry block is born split-bloomed")
            #expect(model.authority.livePane == TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: entry.block, variantID: entry.chosen),
                    "the entry ring keys the CARD that renders the take — never the replaced article cell")
            let (window, hosting) = await mount(model, world)
            defer { close(window, model) }
            await settle(window, hosting, until: {
                Self.panes(in: hosting).contains(where: \.isEditable)
            })
            let live = Self.panes(in: hosting).filter(\.isEditable)
            #expect(live.count == 1, "exactly one live ring on screen (\(live.count))")
            #expect(live.first?.identifier?.rawValue == "pane:mini|\(entry.chosen)",
                    "…and it is the entry take's split card (\(live.first?.identifier?.rawValue ?? "none"))")
        }
    }
}

// MARK: - VX-577 — expand all in slot split

@MainActor
@Suite("VX-577 — expand all / close all in slot split", .serialized)
struct TakesSlotSplitExpandAllTests {

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 10) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func roles(_ hosting: NSView, _ role: String) -> Set<String> {
        Set(TakesExpansionRemountTests.panes(role, in: hosting).compactMap {
            $0.identifier?.rawValue.replacingOccurrences(of: "pane:\(role)|", with: "")
        })
    }

    private func mount(
        _ model: TakesViewModel, _ world: ExpansionWorld
    ) async -> (NSWindow, NSHostingView<TakesBoardView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 1000),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: TakesBoardView(session: world.session, postID: world.postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 1000)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, turns: 14)
        return (window, hosting)
    }

    /// **GUARD (green on both trees — the act always worked; the gate hid
    /// it): what the door DOES in slot split, on the rendered board.** Every
    /// fanned block opens into its split — its cards in the article cell's
    /// place, one card per take, no article pane — while an unfanned block
    /// keeps its line; each split pages on its own; close all (and ⎋'s same
    /// body) brings the plain page back. The memory keeps expand all's result
    /// (VX-428's interplay).
    @Test func expandAllOpensEverySplitAndCloseAllBringsThePlainPageBack() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 4, style: .slotSplit, fanned: { $0 != 1 }) { world in
            let model = try await world.boardModel()
            let (window, hosting) = await mount(model, world)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            #expect(roles(hosting, "mini").isEmpty, "non-vacuity: the page starts plain")
            #expect(roles(hosting, "article").count == 4, "every block's line is drawn")

            model.expandAllFans()
            await settle(window, hosting)
            for block in world.blocks {
                if let spare = block.spare {
                    #expect(roles(hosting, "mini").isSuperset(of: [block.chosen, spare]),
                            "a fanned block opens into its split — every take a card")
                    #expect(!roles(hosting, "article").contains(block.chosen),
                            "…in the article cell's place")
                } else {
                    #expect(roles(hosting, "article").contains(block.chosen),
                            "an unfanned block keeps its line")
                }
            }
            #expect(world.remembered == world.fannedBlockIDs,
                    "the session keeps expand all's result (VX-428)")

            // Each split pages on its own (the pager's key is the block).
            let a = world.blocks[0].block, c = world.blocks[2].block
            model.stepPage(a, by: 1, limit: 1)
            #expect(model.pageOffset(a, limit: 1) == 1)
            #expect(model.pageOffset(c, limit: 1) == 0, "another split's page is untouched")

            model.closeAllFans()
            await settle(window, hosting)
            #expect(roles(hosting, "mini").isEmpty, "close all — every split folds back")
            #expect(roles(hosting, "article").count == 4, "…and the plain page is back")
            #expect(world.remembered == nil, "…and the session forgets the note's fans")
        }
    }

    /// **RED ON OLD — the ring.** In slot split expand all REPLACES the
    /// article cell she is typing in with its fan's cards; the ring may not
    /// stand on a pane no surface renders (R112), so it ends by the FLUSHED
    /// blur — what she typed is in the store, and no pane is left live
    /// (PROVISIONAL P-B-1). In every other style the article cell stays and so
    /// does the ring.
    @Test(arguments: [FanStyle.slotSplit, .stack])
    func expandAllNeverLeavesTheRingOnAPaneNoSurfaceRenders(style: FanStyle) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 3, style: style) { world in
            let model = try await world.boardModel()
            let (window, hosting) = await mount(model, world)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            let target = world.blocks[1]
            let key = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: target.block, variantID: target.chosen)
            model.focus(key)
            let typed = expansionProse(2) + " And a sentence she was typing."
            model.paneEdited(variantID: target.chosen, newText: typed)
            await settle(window, hosting)
            #expect(model.focusedPane == key, "non-vacuity: the ring is in the article cell")

            model.expandAllFans()
            await settle(window, hosting)
            switch style {
            case .slotSplit:
                #expect(model.focusedPane == nil,
                        "the article cell is gone — the ring ended rather than stand on nothing")
                await model.autosave.flushNow()
                let stored = try await world.db.read {
                    try Variant.fetchOne($0, key: target.chosen)?.workingText
                }
                #expect(stored == typed, "…and what she typed landed (the blur is flushed)")
                #expect(TakesExpansionRemountTests.panes(in: hosting).filter(\.isEditable).isEmpty,
                        "no pane is left live")
            default:
                #expect(model.focusedPane == key, "\(style) keeps the article cell — and the ring")
            }
        }
    }
}

// MARK: - The measurement (her "performance or rendering calculations")

@MainActor
@Suite("VX-428 — what a seeded remount costs (measured; P3-bounded)", .serialized)
struct TakesExpansionCostTests {

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private struct Mount {
        var seedMicros: Double
        var firstPaneMillis: Double
        var settledMillis: Double
        var article: Int
        var cards: Int
        var turns: Int
    }

    private func millis(_ duration: Duration) -> Double {
        Double(duration.components.seconds) * 1000
            + Double(duration.components.attoseconds) / 1e15
    }

    /// One remount with `seeded` remembered open: the construction (the seed
    /// is timed on its own), the first realized pane, and the settle — until
    /// the realized pane set holds still for three turns (the first paint and
    /// the restore's re-renders are over).
    private func measure(_ world: ExpansionWorld, seeded: Set<String>) async throws -> Mount {
        world.session.editorRouter.takesExpandedBlocks[world.postID] = seeded.isEmpty ? nil : seeded
        world.session.editorRouter.takesArticlePlaces.removeValue(forKey: world.postID)
        world.session.editorRouter.takesArticleCurrentRows.removeValue(forKey: world.postID)
        let clock = ContinuousClock()
        let model = TakesViewModel(session: world.session, postID: world.postID, defaults: world.defaults)
        let seedStart = clock.now
        model.landingEnabled = true
        let seed = clock.now - seedStart
        model.adopt(try await world.projection())
        #expect(model.expandedBlocks == seeded, "non-vacuity: the board was seeded")

        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            model.teardown()
            window.orderOut(nil)
            window.close()
        }
        let start = clock.now
        let hosting = NSHostingView(
            rootView: TakesBoardView(session: world.session, postID: world.postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        var firstPane: Duration?
        var lastIDs: Set<String> = []
        var still = 0
        var turns = 0
        while turns < 80 {
            turns += 1
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.01)
            await Task.yield()
            let ids = Set(TakesExpansionRemountTests.panes(in: hosting).compactMap {
                $0.identifier?.rawValue
            })
            if firstPane == nil, !ids.isEmpty { firstPane = clock.now - start }
            if !ids.isEmpty, ids == lastIDs { still += 1 } else { still = 0 }
            lastIDs = ids
            if still >= 3 { break }
        }
        let settled = clock.now - start
        let all = TakesExpansionRemountTests.panes(in: hosting)
        let article = all.filter { $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
        return Mount(
            seedMicros: millis(seed) * 1000,
            firstPaneMillis: firstPane.map(millis) ?? -1,
            settledMillis: millis(settled),
            article: article.count, cards: all.count - article.count, turns: turns)
    }

    /// **The numbers, and the bound that makes them safe.** A 60-block note,
    /// every block fanned (two takes), remounted with 0, 5 and 25 fans
    /// remembered open at the TOP (the worst case: all on the first screen),
    /// and with 25 open at the BOTTOM (off the first screen). P3 is the
    /// bound: a seeded fan costs only when its row is realized — 25 fans
    /// remembered below the fold realize exactly what 0 do — and the top-25
    /// remount realizes no more panes than the viewport holds rows for (the
    /// lazy column builds what is on screen, never the note). The timings
    /// print as `VX428-MEASURE` lines (the batch B record takes them).
    @Test(arguments: [FanStyle.stack, .marginGrid, .slotSplit])
    func aSeededRemountCostsOnlyWhatIsOnScreen(style: FanStyle) async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withExpansionWorld(blocks: 60, style: style) { world in
            let ids = world.blockIDs
            let none = try await measure(world, seeded: [])
            let five = try await measure(world, seeded: Set(ids.prefix(5)))
            let top = try await measure(world, seeded: Set(ids.prefix(25)))
            let bottom = try await measure(world, seeded: Set(ids.suffix(25)))
            for (label, m) in [("0", none), ("5-top", five), ("25-top", top), ("25-below", bottom)] {
                print(String(
                    format: "VX428-MEASURE style=%@ open=%@ seed=%.1fµs firstPane=%.1fms settled=%.1fms panes(article=%d cards=%d) turns=%d",
                    "\(style)", label, m.seedMicros, m.firstPaneMillis, m.settledMillis,
                    m.article, m.cards, m.turns))
            }
            #expect(none.firstPaneMillis >= 0 && top.firstPaneMillis >= 0, "every remount painted")
            #expect(bottom.cards == none.cards && abs(bottom.article - none.article) <= 1,
                    """
                    \(style): 25 fans remembered BELOW the fold realize what 0 do \
                    (article \(bottom.article) vs \(none.article), cards \(bottom.cards) vs \(none.cards)) \
                    — a seeded fan costs nothing until its row is on screen (P3)
                    """)
            // The top-25 remount draws the first screen's rows open: each
            // realized fanned row costs its two cards (one per take), so the
            // realized panes stay a viewport's worth — never the 25 × 3 a
            // note-wide build would make, nor anything ∝ the 60 blocks.
            #expect(top.article + top.cards <= (none.article + 2) * 3,
                    """
                    \(style): the top-25 remount realizes a viewport's worth \
                    (\(top.article) article + \(top.cards) cards, vs \(none.article) rows at rest)
                    """)
            #expect(top.cards > 0, "non-vacuity: the seeded fans really drew their cards")
        }
    }
}
