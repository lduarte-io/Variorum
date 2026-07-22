//
//  TakesBoardSoakTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a (P-7): the randomized BOARD SOAK — the ops-layer
//  soak pattern lifted to the view layer. Seeded action sequences run
//  over the REAL mounted TakesBoardView (type, focus-migrate, choose,
//  expand/collapse, branch, blank, blank-and-choose, adopt-as-lens,
//  style-switch, page-step, and a remount simulating a mode switch), and
//  the invariants are checked after EVERY action:
//
//  - ONE live ring: at most one editable pane exists (P3 / the authority's
//    structural invariant, verified on the rendered surface).
//  - EVERY read pane mirrors the authority's text for its variant — the
//    article cell follows the chosen take's buffer, fan cards follow
//    theirs; no pane ever renders staler than the live buffer (the
//    frozen-article class, soaked).
//  - Realized article/stack panes hold their text's measured height at
//    real width (the clipped-take class, soaked).
//  - An empty chosen take still renders its article pane (R103's kept
//    line).
//  - The AD-2 invariant: a bloomed block's rail/pager cards never exceed
//    the visible page capacity — every further take is behind an explicit
//    door, never silently clipped.
//
//  Non-vacuity is enforced per seed: the sequence opens with one of each
//  core action, and the counts are asserted at the end.
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
@Suite("The board soak (13b 1a, P-7)", .serialized)
struct TakesBoardSoakTests {
    // MARK: - Harness

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 3) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private struct PaneIdentity {
        let role: String
        let variantID: String
        let view: PaneTextView
    }

    private func identifiedPanes(in view: NSView) -> [PaneIdentity] {
        panes(in: view).compactMap { pane in
            guard let raw = pane.identifier?.rawValue, raw.hasPrefix("pane:") else { return nil }
            let parts = raw.dropFirst("pane:".count).split(
                separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2, parts[1] != "-" else { return nil }
            return PaneIdentity(role: String(parts[0]), variantID: String(parts[1]), view: pane)
        }
    }

    /// The store's CURRENT text for a variant, as the board itself sees it
    /// (the projection — both sides of the mirror check read one source).
    private func storeText(_ variantID: String, _ model: TakesViewModel) -> String? {
        for (_, fan) in model.projection.fans {
            if let take = fan.first(where: { $0.id == variantID }) {
                return take.workingText
            }
        }
        return model.projection.slots.first { $0.variantID == variantID }?.text
    }

    private func blockID(of variantID: String, _ model: TakesViewModel) -> String? {
        for (blockID, fan) in model.projection.fans
        where fan.contains(where: { $0.id == variantID }) {
            return blockID
        }
        return model.projection.slots.first { $0.variantID == variantID }?.blockID
    }

    // MARK: - The invariants (checked after EVERY action)

    private func checkInvariants(
        _ hosting: NSView, _ model: TakesViewModel, tag: String
    ) {
        let identified = identifiedPanes(in: hosting)

        // 1 — ONE live ring.
        let livePanes = panes(in: hosting).filter(\.isEditable)
        let liveCount = livePanes.count
        if liveCount > 1 {
            for pane in livePanes {
                print("LIVE-PANE [\(tag)]:", pane.identifier?.rawValue ?? "?",
                      pane.frame, "window:", pane.window != nil)
            }
        }
        #expect(liveCount <= 1, "[\(tag)] one live ring — found \(liveCount)")

        // 2 + 3 — read panes mirror the authority; realized free-height
        // panes hold their measured height.
        for pane in identified where !pane.view.isEditable {
            guard let store = storeText(pane.variantID, model) else { continue }
            let expected = model.authority.text(variantID: pane.variantID, storeText: store)
            #expect(pane.view.string == expected,
                    "[\(tag)] \(pane.role) pane mirrors the authority for \(pane.variantID.suffix(4))")
            if pane.role == "article" || pane.role == "card" {
                let measured = PaneMeasurement.height(of: pane.view)
                #expect(pane.view.bounds.height + 3 >= measured,
                        "[\(tag)] \(pane.role) height \(pane.view.bounds.height) holds measured \(measured)")
            }
        }

        // 4 — every REALIZED slot renders its article pane (R103: an empty
        // chosen take KEEPS the line). Scoped to realized rows — blooms
        // can push later rows past the viewport and the LazyVStack
        // derealizes them (P3's virtualization, not a bug); a row is
        // realized when ANY of its panes exist. A slot-split BLOOM
        // deliberately replaces the article cell with the in-flow split
        // (the style's whole point) — skipped.
        let realizedBlocks = Set(identified.compactMap { blockID(of: $0.variantID, model) })
        for slot in model.projection.slots where realizedBlocks.contains(slot.blockID) {
            guard let variantID = slot.variantID else { continue }
            if model.projection.fanStyle == .slotSplit, slot.hasFan, model.isBloomed(slot) {
                continue
            }
            #expect(identified.contains { $0.role == "article" && $0.variantID == variantID },
                    "[\(tag)] slot \(slot.blockID.suffix(4)) renders its article pane")
        }

        // 5 — the AD-2 class under the S4-24 HYBRID (13b 4D — JUSTIFIED
        // EDIT, her ruling): the strip carries EVERY take now (free scroll
        // + the ◀ ▶ pager + the counter, one brain), so the invariant
        // flips from "≤ the discrete page capacity" to "exactly the fan —
        // nothing missing (the unreachable-take class), nothing
        // duplicated". A realized bloom renders its whole strip.
        var miniPerBlock: [String: Int] = [:]
        for pane in identified where pane.role == "mini" {
            guard let block = blockID(of: pane.variantID, model) else { continue }
            miniPerBlock[block, default: 0] += 1
        }
        for (block, count) in miniPerBlock {
            let fanCount = model.projection.fans[block]?.count ?? 0
            #expect(count == fanCount,
                    "[\(tag)] block \(block.suffix(4)) strips \(count) cards for a fan of \(fanCount)")
        }
    }

    // MARK: - The soak

    @Test(arguments: [7, 21] as [UInt64])
    func randomizedBoardSoakHoldsEveryInvariant(seed: UInt64) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        // Pin the density/beneath settings the capacity invariant assumes.
        let defaults = UserDefaults.standard
        let saved = ["takesGridRows", "takesGridCols", "takesBeneathCount"].map {
            ($0, defaults.object(forKey: $0))
        }
        defaults.set(2, forKey: "takesGridRows")
        defaults.set(1, forKey: "takesGridCols")
        defaults.set(2, forKey: "takesBeneathCount")
        defer {
            for (key, value) in saved {
                if let value { defaults.set(value, forKey: key) }
                else { defaults.removeObject(forKey: key) }
            }
        }
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Long texts so the R24 strip rule never halves the capacity
            // the AD-2 invariant assumes.
            let base = String(repeating: "soaked prose that outgrows the strip rule. ", count: 6)
            let (postID, blocks): (String, [String]) = try {
                let post = try session.operations.createPost(title: "soak post")
                let m1 = try session.operations.newBlock(in: post.id, text: base + "One.")
                let m2 = try session.operations.newBlock(in: post.id, text: base + "Two.")
                let m3 = try session.operations.newBlock(in: post.id, text: base + "Three.")
                for source in [m1, m1, m2] {
                    let take = try session.operations.branchVariant(
                        source.block.id, from: source.variant.id)
                    try session.operations.autosave(
                        take.id, text: base + "take on \(source.block.id.suffix(4)).",
                        charDelta: 6)
                }
                return (post.id, [m1.block.id, m2.block.id, m3.block.id])
            }()

            var model = TakesViewModel(session: session, postID: postID)
            var observing = Task { await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            var hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 900)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where model.projection.slots.isEmpty {
                await settle(window, hosting, turns: 1)
            }
            #expect(!model.projection.slots.isEmpty, "the board mounted")

            var generator = SeededGenerator(seed: seed &+ 99)
            var counts: [String: Int] = [:]
            var step = 0

            @MainActor func randomVariant() -> (blockID: String, variantID: String)? {
                let blockID = blocks.randomElement(using: &generator)!
                if let fan = model.projection.fans[blockID], !fan.isEmpty,
                   let take = fan.randomElement(using: &generator) {
                    return (blockID, take.id)
                }
                guard let slot = model.projection.slots.first(where: { $0.blockID == blockID }),
                      let variantID = slot.variantID else { return nil }
                return (blockID, variantID)
            }

            @MainActor func perform(_ action: String) async {
                counts[action, default: 0] += 1
                switch action {
                case "focus":
                    guard let target = randomVariant() else { return }
                    model.focus(TakesViewModel.PaneKey(
                        columnID: TakesBoardView.fanColumnID,
                        blockID: target.blockID, variantID: target.variantID))
                case "type":
                    guard let pane = model.focusedPane else { return }
                    model.paneEdited(
                        variantID: pane.variantID,
                        newText: base + "typed at step \(step) seed \(seed).")
                case "choose":
                    guard let target = randomVariant() else { return }
                    await model.choose(blockID: target.blockID, variantID: target.variantID)
                case "expand":
                    model.toggleExpanded(blocks.randomElement(using: &generator)!)
                case "expandAll":
                    model.expandAllFans()
                case "closeAll":
                    model.closeAllFans()
                case "branch":
                    guard let target = randomVariant() else { return }
                    _ = await model.branchTake(
                        blockID: target.blockID, from: target.variantID)
                case "blank":
                    _ = await model.newBlankTake(
                        blockID: blocks.randomElement(using: &generator)!)
                case "blankChoose":
                    await model.newBlankTakeAsChosen(
                        blockID: blocks.randomElement(using: &generator)!)
                case "style":
                    let styles: [FanStyle] = [.stack, .carousel, .marginGrid, .slotSplit]
                    await model.setFanStyle(styles.randomElement(using: &generator)!)
                case "adopt":
                    await model.saveCurrentChoicesAsLens(name: "soak lens \(step)")
                    if let lens = model.projection.lenses.last {
                        await model.adoptLens(lens.id)
                    }
                case "page":
                    guard let block = blocks.randomElement(using: &generator) else { return }
                    model.stepPage(
                        "rail-\(block)", by: Bool.random(using: &generator) ? 1 : -1,
                        limit: 3)
                default:
                    Issue.record("unknown soak action \(action)")
                }
            }

            // Non-vacuity by construction: one of each core action first…
            let core = ["focus", "type", "choose", "expand", "branch", "style",
                        "blank", "blankChoose", "adopt", "page"]
            let pool = core + ["expandAll", "closeAll", "focus", "type", "type",
                               "choose", "expand", "page"]
            var script = core
            for _ in 0..<14 {
                script.append(pool.randomElement(using: &generator)!)
            }
            // …with ONE remount (the mode-switch simulation) at a random
            // midpoint: the leaving surface tears down (its flush lands
            // through the shared coordinator), a fresh model + board mount.
            let remountAt = Int.random(in: 8..<script.count, using: &generator)

            for (i, action) in script.enumerated() {
                step = i
                if i == remountAt {
                    // The mode-switch simulation: PostDetailView gives every
                    // mode an `.id(...)`, so a switch DESTROYS the surface +
                    // model and mounts fresh ones — a fresh hosting view
                    // reproduces that identity break (reusing the old one
                    // would silently keep the old @State model, which is a
                    // SwiftUI-identity artifact, not the app's shape).
                    counts["remount", default: 0] += 1
                    observing.cancel()
                    model.teardown()
                    model = TakesViewModel(session: session, postID: postID)
                    observing = Task { [model] in await model.start() }
                    hosting = NSHostingView(
                        rootView: TakesBoardView(session: session, postID: postID, model: model))
                    hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 900)
                    window.contentView = hosting
                    for _ in 0..<40 where model.projection.slots.isEmpty {
                        await settle(window, hosting, turns: 1)
                    }
                }
                await perform(action)
                await settle(window, hosting)
                checkInvariants(hosting, model, tag: "seed \(seed) step \(i) \(action)")
            }

            // Everything typed landed in the store by quiescence.
            await model.autosave.flushNow()
            for (action, minimum) in [("focus", 1), ("type", 1), ("choose", 1),
                                      ("expand", 1), ("branch", 1), ("style", 1),
                                      ("remount", 1)] {
                #expect((counts[action] ?? 0) >= minimum,
                        "non-vacuity: \(action) ran (seed \(seed))")
            }
        }
    }

    // MARK: - The COMPARE board soak (13b 4C — the cross-post authority)

    /// The compare-board variant (the Stage 4 brief's named addition):
    /// seeded actions across TWO posts' columns — focus, type, choose,
    /// bloom, per-post reorder, the follow/lineage toggles, and a remount —
    /// with the invariants checked after EVERY action:
    /// - at most ONE live pane across BOTH posts (the 4C authority
    ///   contract, verified on the rendered surface);
    /// - every read pane mirrors ITS OWN post's authority text (the
    ///   buffer overlay never leaks across posts, never goes stale);
    /// - a reorder in one column NEVER reorders the other post (S4-2d);
    /// - realized compare panes hold their measured height.
    @Test(arguments: [5, 17] as [UInt64])
    func randomizedCompareBoardSoakHoldsEveryInvariant(seed: UInt64) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let base = "compared prose that runs long enough to wrap and measure. "
            let (anchorID, twinID): (String, String) = try {
                let anchor = try session.operations.createPost(title: "soak anchor")
                let m1 = try session.operations.newBlock(in: anchor.id, text: base + "One.")
                _ = try session.operations.newBlock(in: anchor.id, text: base + "Two.")
                _ = try session.operations.newBlock(in: anchor.id, text: base + "Three.")
                let extra = try session.operations.branchVariant(m1.block.id, from: m1.variant.id)
                try session.operations.autosave(
                    extra.id, text: base + "another take on one.", charDelta: 6)
                let twin = try session.operations.duplicateAsVersion(anchor.id)
                return (anchor.id, twin.post.id)
            }()

            var model = CompareViewModel(session: session, anchorPostID: anchorID)
            model.peerSlots = [.init(postID: twinID)]
            var observing = Task { [model] in await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            var hosting = NSHostingView(
                rootView: CompareBoardView(session: session, postID: anchorID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 900)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where model.projection.anchor.slots.isEmpty
                || model.projection.peers[twinID] == nil {
                await settle(window, hosting, turns: 1)
            }
            #expect(!model.projection.anchor.slots.isEmpty, "the board mounted with both posts")

            @MainActor func storedOrders() async throws -> (anchor: [String], twin: [String]) {
                try await db.read { db in
                    (try Queries.renderPost(db, containerID: anchorID).map(\.blockID),
                     try Queries.renderPost(db, containerID: twinID).map(\.blockID))
                }
            }

            @MainActor func compareStoreText(_ variantID: String) -> String? {
                for face in [model.projection.anchor] + Array(model.projection.peers.values) {
                    for (_, fan) in face.fans {
                        if let take = fan.first(where: { $0.id == variantID }) {
                            return take.workingText
                        }
                    }
                    if let slot = face.slots.first(where: { $0.variantID == variantID }) {
                        return slot.text
                    }
                }
                return nil
            }

            @MainActor func checkCompareInvariants(tag: String) {
                let identified = identifiedPanes(in: hosting)
                // 1 — ONE live ring across BOTH posts.
                let liveCount = panes(in: hosting).filter(\.isEditable).count
                #expect(liveCount <= 1, "[\(tag)] one live ring across posts — found \(liveCount)")
                // 2 + 4 — read panes mirror the authority for their own
                // post's variant; realized compare panes hold measured height.
                for pane in identified where !pane.view.isEditable {
                    guard let store = compareStoreText(pane.variantID) else { continue }
                    let expected = model.authority.text(
                        variantID: pane.variantID, storeText: store)
                    #expect(pane.view.string == expected,
                            "[\(tag)] \(pane.role) pane mirrors its post's authority text")
                    if pane.role == "compare" {
                        let measured = PaneMeasurement.height(of: pane.view)
                        #expect(pane.view.bounds.height + 3 >= measured,
                                "[\(tag)] compare pane height holds measured \(measured)")
                    }
                }
            }

            var generator = SeededGenerator(seed: seed &+ 7)
            var counts: [String: Int] = [:]
            var step = 0

            @MainActor func paneKey(post: String, index: Int) -> PaneTextAuthority.PaneKey? {
                guard let face = model.face(for: post), !face.slots.isEmpty else { return nil }
                let slot = face.slots[min(index, face.slots.count - 1)]
                guard let variantID = slot.variantID else { return nil }
                return PaneTextAuthority.PaneKey(
                    columnID: "compare-\(post)", blockID: slot.blockID,
                    variantID: variantID, context: post)
            }

            @MainActor func perform(_ action: String) async throws {
                counts[action, default: 0] += 1
                switch action {
                case "focusAnchor":
                    if let key = paneKey(post: anchorID, index: Int.random(in: 0..<3, using: &generator)) {
                        model.focus(key)
                    }
                case "focusTwin":
                    if let key = paneKey(post: twinID, index: Int.random(in: 0..<3, using: &generator)) {
                        model.focus(key)
                    }
                case "type":
                    guard let pane = model.authority.livePane, !pane.context.isEmpty else { return }
                    model.paneEdited(
                        postID: pane.context, variantID: pane.variantID,
                        newText: base + "typed step \(step) seed \(seed).")
                case "choose":
                    // Choose the anchor's second take where the fan exists.
                    if let (blockID, fan) = model.projection.anchor.fans.first(where: { $1.count > 1 }),
                       let take = fan.randomElement(using: &generator) {
                        await model.choose(blockID: blockID, variantID: take.id)
                    }
                case "bloom":
                    if let slot = model.projection.anchor.slots.first(where: \.hasFan) {
                        model.toggleExpanded(slot.blockID)
                    }
                case "toggleFollow":
                    model.followAnchorOrder.toggle()
                case "toggleLineage":
                    model.lineageColorsOn.toggle()
                case "reorderAnchor", "reorderTwin":
                    let post = action == "reorderAnchor" ? anchorID : twinID
                    let other = action == "reorderAnchor" ? twinID : anchorID
                    let before = try await storedOrders()
                    let otherBefore = post == anchorID ? before.twin : before.anchor
                    guard let face = model.face(for: post), face.slots.count > 1 else { return }
                    let blockID = face.slots[0].blockID
                    await model.moveBlock(blockID, inPost: post, before: nil)
                    let after = try await storedOrders()
                    let otherAfter = post == anchorID ? after.twin : after.anchor
                    #expect(otherAfter == otherBefore,
                            "[seed \(seed) step \(step)] reorder in \(action) never touches \(other.suffix(4))")
                case "remount":
                    break  // handled in the script loop
                default:
                    Issue.record("unknown compare soak action \(action)")
                }
            }

            let core = ["focusAnchor", "type", "focusTwin", "type", "choose",
                        "bloom", "reorderAnchor", "reorderTwin", "toggleFollow",
                        "toggleLineage"]
            let pool = core + ["focusAnchor", "focusTwin", "type", "type"]
            var script = core
            for _ in 0..<10 {
                script.append(pool.randomElement(using: &generator)!)
            }
            let remountAt = Int.random(in: 8..<script.count, using: &generator)

            for (i, action) in script.enumerated() {
                step = i
                if i == remountAt {
                    counts["remount", default: 0] += 1
                    observing.cancel()
                    model.teardown()
                    model = CompareViewModel(session: session, anchorPostID: anchorID)
                    model.peerSlots = [.init(postID: twinID)]
                    observing = Task { [model] in await model.start() }
                    hosting = NSHostingView(
                        rootView: CompareBoardView(
                            session: session, postID: anchorID, model: model))
                    hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 900)
                    window.contentView = hosting
                    for _ in 0..<40 where model.projection.anchor.slots.isEmpty
                        || model.projection.peers[twinID] == nil {
                        await settle(window, hosting, turns: 1)
                    }
                }
                try await perform(action)
                await settle(window, hosting)
                checkCompareInvariants(tag: "seed \(seed) step \(i) \(action)")
            }

            // Quiescence: both posts' pipelines drain.
            await session.autosave(forPost: anchorID).flushNow()
            await session.autosave(forPost: twinID).flushNow()
            for (action, minimum) in [("focusAnchor", 1), ("focusTwin", 1), ("type", 1),
                                      ("reorderAnchor", 1), ("reorderTwin", 1),
                                      ("toggleFollow", 1), ("remount", 1)] {
                #expect((counts[action] ?? 0) >= minimum,
                        "non-vacuity: \(action) ran (seed \(seed))")
            }
        }
    }

    // MARK: - The CANVAS board soak (13b 4E — editable cards + culling)

    /// The canvas variant (the 4E batch's recorded addition, the compare
    /// soak's shape): seeded actions over the REAL mounted CanvasView —
    /// focus, type, ‹ › steps, card drags, an order-mode round, a fit-all
    /// round, and a remount — with the invariants checked after EVERY
    /// action:
    /// - at most ONE live pane (the authority's structural invariant on
    ///   the rendered surface; order mode and the overview hold it at 0);
    /// - every read pane mirrors the authority's text for its variant
    ///   (the buffer overlay never goes stale on a card);
    /// - realization stays BOUNDED (realizedCards < the 100-card corpus —
    ///   the 4E P1 clause, soaked under every action);
    /// - canvas_layout rows exist ONLY for dragged cards (arrangement
    ///   writes at drag end, nothing else writes positions);
    /// - an applied order round lands the clicked sequence as the stored
    ///   prefix.
    @Test(arguments: [11, 23] as [UInt64])
    func randomizedCanvasBoardSoakHoldsEveryInvariant(seed: UInt64) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let base = "canvas prose that runs long enough to wrap and scroll a card. "
            let postID: String = try {
                let post = try session.operations.createPost(title: "soak canvas")
                for i in 0..<100 {
                    let mint = try session.operations.newBlock(
                        in: post.id, text: base + "Card \(i).")
                    if i == 0 {
                        let extra = try session.operations.branchVariant(
                            mint.block.id, from: mint.variant.id)
                        try session.operations.autosave(
                            extra.id, text: base + "another take on card zero.", charDelta: 6)
                    }
                }
                return post.id
            }()
            UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(postID)")
            UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(postID)")
            defer {
                UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(postID)")
                UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(postID)")
            }

            var model = CanvasViewModel(session: session, containerID: postID)
            var observing = Task { [model] in await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            var hosting = NSHostingView(rootView: CanvasView(
                session: session, containerID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<60 where model.projection.cards.count < 100 {
                await settle(window, hosting, turns: 1)
            }
            #expect(model.projection.cards.count == 100, "the canvas mounted")

            var draggedBlocks: Set<String> = []

            @MainActor func canvasStoreText(_ variantID: String) -> String? {
                for (_, fan) in model.projection.fans {
                    if let take = fan.first(where: { $0.id == variantID }) {
                        return take.workingText
                    }
                }
                return model.projection.cards
                    .first { $0.block.variantID == variantID }?.block.text
            }

            @MainActor func checkCanvasInvariants(tag: String) async throws {
                // 1 — at most ONE live pane on the rendered surface.
                let liveCount = panes(in: hosting).filter(\.isEditable).count
                #expect(liveCount <= 1, "[\(tag)] one live ring — found \(liveCount)")
                // 2 — read panes mirror the authority for their variant.
                for pane in identifiedPanes(in: hosting)
                where pane.role == "canvas" && !pane.view.isEditable {
                    guard let store = canvasStoreText(pane.variantID) else { continue }
                    let expected = model.authority.text(
                        variantID: pane.variantID, storeText: store)
                    #expect(pane.view.string == expected,
                            "[\(tag)] canvas pane mirrors the authority")
                }
                // 3 — realization stays bounded (the 4E P1 clause).
                #expect(model.realizedCards.count < 100,
                        "[\(tag)] realized \(model.realizedCards.count) of 100 — bounded")
                // 4 — positions exist ONLY for dragged cards.
                let rows = try await db.read { db in
                    try Row.fetchAll(db, sql: """
                        SELECT block_id FROM canvas_layout WHERE deleted_at IS NULL
                        """).map { $0["block_id"] as String }
                }
                #expect(Set(rows) == draggedBlocks,
                        "[\(tag)] layout rows == the dragged set (nothing else writes positions)")
            }

            var generator = SeededGenerator(seed: seed &+ 3)
            var counts: [String: Int] = [:]
            var step = 0

            @MainActor func randomRealizedCard() -> Queries.PoolItem? {
                let cards = model.realizedCards
                guard !cards.isEmpty else { return nil }
                return cards[Int.random(in: 0..<cards.count, using: &generator)]
            }

            @MainActor func perform(_ action: String) async throws {
                counts[action, default: 0] += 1
                switch action {
                case "focus":
                    guard !model.orderMode, !model.overviewActive,
                          let item = randomRealizedCard(),
                          let resolved = model.resolvedCard(item: item) else { return }
                    model.focus(
                        blockID: item.block.blockID, variantID: resolved.variantID)
                case "type":
                    guard let pane = model.authority.livePane else { return }
                    model.paneEdited(
                        blockID: pane.blockID, variantID: pane.variantID,
                        newText: base + "typed step \(step) seed \(seed).")
                case "switch":
                    guard let (blockID, _) = model.projection.fans.first else { return }
                    model.switchTake(blockID: blockID, delta: step % 2 == 0 ? 1 : -1)
                case "drag":
                    guard !model.overviewActive, let item = randomRealizedCard() else { return }
                    let blockID = item.block.blockID
                    await model.dragEnded(
                        blockID: blockID,
                        translation: CGSize(
                            width: Double(Int.random(in: -80...200, using: &generator)),
                            height: Double(Int.random(in: -60...220, using: &generator))))
                    draggedBlocks.insert(blockID)
                case "orderRound":
                    guard !model.overviewActive else { return }
                    let before = try await db.read { db in
                        try Queries.renderPost(db, containerID: postID).map(\.blockID)
                    }
                    model.enterOrderMode()
                    guard model.orderMode else { return }
                    let picks = Array(before.shuffled(using: &generator).prefix(3))
                    for blockID in picks { model.toggleOrderClick(blockID: blockID) }
                    if step % 2 == 0 {
                        await model.applyOrder()
                        let after = try await db.read { db in
                            try Queries.renderPost(db, containerID: postID).map(\.blockID)
                        }
                        #expect(Array(after.prefix(picks.count)) == picks,
                                "[seed \(seed) step \(step)] the clicked sequence leads the post")
                    } else {
                        model.cancelOrderMode()
                        let after = try await db.read { db in
                            try Queries.renderPost(db, containerID: postID).map(\.blockID)
                        }
                        #expect(after == before,
                                "[seed \(seed) step \(step)] cancel is inert")
                    }
                case "fitAllRound":
                    _ = model.fitAll(viewport: CGSize(width: 900, height: 650))
                    if model.overviewActive {
                        if step % 2 == 0, let item = randomRealizedCard() {
                            _ = model.overviewClicked(blockID: item.block.blockID)
                        } else {
                            model.exitOverview()
                        }
                    }
                    #expect(model.authority.livePane == nil || !model.overviewActive,
                            "[seed \(seed) step \(step)] the overview is read-only (α)")
                case "remount":
                    break  // handled in the script loop
                default:
                    Issue.record("unknown canvas soak action \(action)")
                }
            }

            let core = ["focus", "type", "switch", "drag", "orderRound", "fitAllRound"]
            let pool = core + ["focus", "type", "drag"]
            var script = core
            for _ in 0..<8 {
                script.append(pool.randomElement(using: &generator)!)
            }
            let remountAt = Int.random(in: 6..<script.count, using: &generator)

            for (i, action) in script.enumerated() {
                step = i
                if i == remountAt {
                    counts["remount", default: 0] += 1
                    observing.cancel()
                    model.teardown()
                    model = CanvasViewModel(session: session, containerID: postID)
                    observing = Task { [model] in await model.start() }
                    hosting = NSHostingView(rootView: CanvasView(
                        session: session, containerID: postID, model: model))
                    hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 700)
                    window.contentView = hosting
                    for _ in 0..<60 where model.projection.cards.count < 100 {
                        await settle(window, hosting, turns: 1)
                    }
                }
                try await perform(action)
                await settle(window, hosting)
                try await checkCanvasInvariants(tag: "seed \(seed) step \(i) \(action)")
            }

            // Quiescence: the pipeline drains.
            await session.autosave(forPost: postID).flushNow()
            for (action, minimum) in [("focus", 1), ("type", 1), ("switch", 1),
                                      ("drag", 1), ("orderRound", 1),
                                      ("fitAllRound", 1), ("remount", 1)] {
                #expect((counts[action] ?? 0) >= minimum,
                        "non-vacuity: \(action) ran (seed \(seed))")
            }
        }
    }
}
