//
//  TakeChoiceBadgeTests.swift
//  VariorumTests
//
//  VX-729 (Run VX-736, B3) — A FANNED BLOCK KEEPS ITS CORNER BADGE WHEN A
//  TAKE IS CHOSEN. Her report (seen while recording the launch hero, the
//  "You, I hope :)" title block of a short note): a block with two takes wears
//  its ⑂2 in Write; after choosing a take in Write's take panel and closing
//  it, the badge stops rendering though the block is still fanned. The
//  contract: "A corner badge appears only on fanned blocks" (SurfaceContracts
//  §The note) — the block IS fanned, so the badge stays.
//
//  The traced mechanism (the run record's B3 RECORD, piece 1; macOS 27.0.1):
//  the choose is a store write, and Write hears it by its observation — a
//  delivery, re-read fresh, then the DIFFERENTIAL rewrite
//  (`EditorSurfaceController.applyDifferential`). The rewrite replaces the
//  block's range and reads the badges at once; the replaced paragraph is
//  UNLAID at that instant (TK2 state `.none`, frame `.zero`), so VX-230's rule
//  rightly skips it and the overlay removes the button. The re-read is owed to
//  the N14 settle hop, whose only trigger is the text view's OWN display pass
//  (`viewWillDraw`) — and TextKit 2 never runs that pass for a storage edit
//  that keeps the text view's frame (TEXTKIT2_NOTES §3, the 27.0.1 entry). A
//  take flip in a short note keeps the frame: no pass, no hop, no badge.
//
//  Every pin below stages the FRAME-CONSTANT world on purpose and `#require`s
//  it (a frame that moved would run the pass and heal the old tree too — the
//  pin would be hollow). The bug pins are RED on the pre-fix tree on their
//  final expectation (the badge never comes back); the guard and the full-
//  render characterization are recorded on both trees (the record says which
//  sweep row each answers).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// The ⑂ buttons the surface draws — her FACE, not the model's list.
@MainActor
private func fanButtons(in textView: NSTextView) -> [NSButton] {
    textView.subviews.compactMap { $0 as? NSButton }.filter { $0.title.hasPrefix("⑂") }
}

/// One entry's FIRST fragment as the surface holds it NOW, in view
/// coordinates — read with `options: []`, so the read lays nothing out.
@MainActor
private func entryFragment(
    _ i: Int, model: EditorViewModel, textView: NSTextView
) -> (frame: CGRect, laidOut: Bool)? {
    guard let layoutManager = textView.textLayoutManager,
          let contentManager = layoutManager.textContentManager
    else { return nil }
    let range = model.index.range(ofEntryAt: i)
    guard let location = contentManager.location(
        contentManager.documentRange.location, offsetBy: range.location)
    else { return nil }
    let origin = textView.textContainerOrigin
    var found: (frame: CGRect, laidOut: Bool)?
    layoutManager.enumerateTextLayoutFragments(from: location, options: []) { fragment in
        found = (fragment.layoutFragmentFrame.offsetBy(dx: origin.x, dy: origin.y),
                 fragment.state == .layoutAvailable)
        return false
    }
    return found
}

@MainActor
@Suite("A chosen take keeps its fan's badge (VX-729)", .serialized)
struct TakeChoiceBadgeTests {
    /// The short note of her sighting: three one-line blocks, block 1 the
    /// title. Every take text below is ONE line at the harness width, so a
    /// flip never moves the text view's frame (the page floors it).
    static let note = ["You, I hope :)", "A second short block of prose.", "A third."]

    /// FanBadgePlacementTests' proven wait: async polling drains the settle
    /// hop's main-queue turns (TEXTKIT2_NOTES §3's harness fact — a nested run
    /// loop runs no main-queue hop; an `await` does), and the display call
    /// gives every pass its chance. Bounded: ~400 turns.
    private func pumpUntil(_ window: NSWindow, _ condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// Write's surface in a real window with the APP's coordinator installed
    /// (the badge overlay, the decor overlay, the scroll-anchor controller —
    /// exactly what `EditorSurface.makeNSView` installs), ordered in without
    /// becoming key.
    private func mountWrite(
        _ h: EditorHarness
    ) throws -> (window: NSWindow, coordinator: EditorSurface.Coordinator) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 600),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView
        let coordinator = EditorSurface.Coordinator(model: h.model)
        coordinator.install(scrollView: scrollView, textView: h.textView)
        window.orderFrontRegardless()
        window.layoutIfNeeded()
        window.display()
        return (window, coordinator)
    }

    /// Entry `i` wears its badge at its own first line, laid out, and the
    /// face draws a button with `title` at that line.
    private func badgedHome(_ h: EditorHarness, entry i: Int, blockID: String, title: String) -> Bool {
        guard let truth = entryFragment(i, model: h.model, textView: h.textView), truth.laidOut,
              let badge = h.model.badges.first(where: { $0.blockID == blockID }),
              abs(badge.frame.minY - truth.frame.minY) < 1
        else { return false }
        return fanButtons(in: h.textView).contains {
            $0.title == title && abs($0.frame.minY - truth.frame.minY) < 1
        }
    }

    /// Fans entry `i` with one more take per text (each branched from the
    /// shown take, then given its own words) and returns the take ids.
    private func fan(_ h: EditorHarness, entry i: Int, takes texts: [String]) throws -> [String] {
        let slot = try h.storeSlots()[i]
        let source = try #require(slot.variantID)
        var ids: [String] = []
        for text in texts {
            let take = try h.session.operations.branchVariant(slot.blockID, from: source)
            try h.session.operations.autosave(take.id, text: text, charDelta: text.count)
            ids.append(take.id)
        }
        try h.reload()
        return ids
    }

    /// Write hears the store the way its observation does: a DELIVERY
    /// (`observeSlots` → `applyProjection(fromDelivery: true)`), which the
    /// policy turns into a fresh re-read and then the render arm.
    private func deliver(_ h: EditorHarness) throws {
        h.model.applyProjection(try h.storeSlots(), fromDelivery: true)
    }

    /// The flip's shared shape: badge home first, then `act`, then the
    /// rewrite landing (`landed`), the frame `#require`d unchanged and the
    /// block `#require`d still fanned — and then the badge must come back.
    private func expectBadgeSurvives(
        _ h: EditorHarness, entry i: Int, before: String = "⑂2", title: String, where_: String,
        act: () async throws -> Void, landed: @MainActor () -> Bool
    ) async throws {
        let (window, coordinator) = try mountWrite(h)
        defer {
            coordinator.uninstall()
            window.orderOut(nil)
            window.close()
        }
        let blockID = try h.storeSlots()[i].blockID
        await pumpUntil(window) { badgedHome(h, entry: i, blockID: blockID, title: before) }
        try #require(badgedHome(h, entry: i, blockID: blockID, title: before),
                     "premise: the fanned block wears its \(before) at its own line before the act")
        let frameBefore = h.textView.frame

        try await act()
        try deliver(h)
        await pumpUntil(window, landed)
        try #require(landed(), "premise: the rewrite landed on Write's surface")
        try #require(h.textView.frame == frameBefore,
                     "premise: the FRAME-CONSTANT world — the text view's frame did not move (\(frameBefore) → \(h.textView.frame))")
        try #require(h.model.slots.first(where: { $0.blockID == blockID })?.hasFan == true,
                     "premise: the block is still fanned after the act")

        await pumpUntil(window) { badgedHome(h, entry: i, blockID: blockID, title: title) }
        #expect(badgedHome(h, entry: i, blockID: blockID, title: title),
                "\(where_): the fanned block lost its \(title) — model badges \(h.model.badges.map { "\($0.blockID.prefix(8))@\($0.frame.minY)" }), buttons \(fanButtons(in: h.textView).map { "\($0.title)@\($0.frame.minY)" })")
    }

    /// **Her report, through the panel's own road.** A two-take title block;
    /// the take is chosen with the panel's ✓ (`WriteTakesPanel` builds a
    /// `TakesViewModel` scoped to the block and calls `choose`); Write hears
    /// the store. RED on the pre-fix tree: the differential's synchronous read
    /// meets the replaced paragraph unlaid, and no display pass ever re-runs
    /// it — the ⑂2 never comes back.
    @Test func aTakeChosenInWritesPanelKeepsItsBadge() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            let other = "Me, I think :]"
            let takeIDs = try fan(h, entry: 0, takes: [other])
            let blockID = try h.storeSlots()[0].blockID
            let suite = "vx729-panel-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let panel = TakesViewModel(session: h.session, postID: h.postID, defaults: defaults)
            panel.writePanelBlockID = blockID
            defer { panel.teardown() }
            try await expectBadgeSurvives(
                h, entry: 0, title: "⑂2", where_: "the panel's ✓",
                act: { await panel.choose(blockID: blockID, variantID: takeIDs[0]) },
                landed: { h.textView.string.hasPrefix(other) })
            #expect(panel.status == nil, "the panel's choose landed without a refusal")
        }
    }

    /// **Sweep sibling — archiving the CHOSEN take** (the panel's ⋯ Archive,
    /// the board's, the wire's `archive_take`): the read-time rule renders the
    /// block's default in its place — different words, the same road. Three
    /// takes become two; the ⑂2 stays. RED on the pre-fix tree.
    @Test func archivingTheChosenTakeKeepsTheFansBadge() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            _ = try fan(h, entry: 0, takes: ["Bravo, I hope :)", "Charlie, I hope"])
            let chosen = try #require(try h.storeSlots()[0].variantID)
            try await expectBadgeSurvives(
                h, entry: 0, before: "⑂3", title: "⑂2", where_: "archiving the chosen take",
                act: { try h.session.operations.archiveVariant(chosen) },
                landed: { !h.textView.string.hasPrefix(Self.note[0]) })
        }
    }

    /// **Sweep sibling — an edit that lands from OUTSIDE on a fanned block's
    /// shown take** (an MCP `edit_take`, a sync apply of the take's words, a
    /// savepoint restored from Block History): the shown words change under
    /// Write by the same differential road. RED on the pre-fix tree.
    @Test func anOutsideEditToAFannedBlocksShownTakeKeepsItsBadge() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            _ = try fan(h, entry: 0, takes: ["Me, I think :]"])
            let shown = try #require(try h.storeSlots()[0].variantID)
            let edited = "Yes, I hope :)"
            try await expectBadgeSurvives(
                h, entry: 0, title: "⑂2", where_: "an outside edit of the shown take",
                act: { try h.session.operations.autosave(shown, text: edited, charDelta: 3) },
                landed: { h.textView.string.hasPrefix(edited) })
        }
    }

    /// **The GUARD — a new take that changes no shown words** (＋ new take,
    /// a conflict take landing, Bring back as a take): the projection's echo
    /// check passes, nothing is rewritten, the fragment stays laid out, and the
    /// badge recounts to ⑂3 at once. GREEN on both trees by design (the sweep
    /// table's SAFE row, its mechanism measured).
    @Test func aNewTakeRecountsTheBadgeWithoutARewrite() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            _ = try fan(h, entry: 0, takes: ["Me, I think :]"])
            let slot = try h.storeSlots()[0]
            let shown = try #require(slot.variantID)
            try await expectBadgeSurvives(
                h, entry: 0, title: "⑂3", where_: "a new take on the fan",
                act: { _ = try h.session.operations.branchVariant(slot.blockID, from: shown) },
                landed: { h.model.slots.first(where: { $0.blockID == slot.blockID })?.activeVariantCount == 3 })
        }
    }

    /// **The FULL-RENDER characterization — a block moved from outside** (a
    /// reorder by sync, the wire or another window): the block SEQUENCE
    /// changes, so the policy takes the full render, which replaces the whole
    /// storage and reads the badges after its anchor jump. Recorded on both
    /// trees (the sweep table's full-render row): RED on the pre-fix tree
    /// would put the row in the fixed class; GREEN on both says the jump's own
    /// layout already placed the badge there.
    @Test func aBlockMovedFromOutsideKeepsTheFansBadge() async throws {
        try await withEditor(seedBlocks: Self.note) { h in
            _ = try fan(h, entry: 0, takes: ["Me, I think :]"])
            let slots = try h.storeSlots()
            let moved = slots[2].blockID
            try await expectBadgeSurvives(
                h, entry: 0, title: "⑂2", where_: "a block moved from outside",
                act: {
                    try h.session.operations.reorder(moved, to: .after(slots[0].blockID))
                },
                landed: { h.model.index.entries.map(\.blockID) == [slots[0].blockID, moved, slots[1].blockID] })
        }
    }
}
