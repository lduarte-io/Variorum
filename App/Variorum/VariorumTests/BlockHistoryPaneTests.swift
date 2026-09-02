//
//  BlockHistoryPaneTests.swift
//  VariorumTests
//
//  **THE POST-13L POLISH ROUND, BATCH 4** — ledger row 17 (G2), with row 10
//  (C2) folded in.
//
//  Her second-sitting ruling, verbatim: *"I know I just ruled that history
//  should go in the block menu, but I think I'm changing my mind and it should
//  be in the bottom chrome — my reasoning is that history is quite similar to
//  commit, it's the natural pair to commit."*
//
//  The door move's pins DRIVE THE REAL SURFACE (the 13l lesson, and batch 3's
//  technique with it): the mounted `PostDetailView`, the real `CommandRouter`
//  seam, the real acts. **AppKit's accessibility tree is EMPTY in this test
//  host** — measured at batch 3, not assumed — so an AX-based presence pin
//  would pass vacuously; the evidence is the AppKit class names in the mounted
//  subtree.
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
@Suite("The Block History pane (post-13l polish round, G2)", .serialized)
struct BlockHistoryPaneTests {
    /// **Rows 28 + 65 (the Act 10 correction round): the pane's regions read
    /// as SECTIONS, and the List that clipped them is gone.** The walk found
    /// "deleted takes" and "came from" drawn as struck-through slivers — the
    /// pane was still a `List`, whose fixed section-header measurement is the
    /// EXACT mechanism Act 10 item 1 traced and killed in the tray. The
    /// rebuild retires the List for a ScrollView of CalmSectionHeaders (one
    /// meaning line each — savepoints gains its missing one) over a REAL
    /// seeded history: a merge's two origins, an archived take, a deleted
    /// take, savepoints. **RED ON OLD:** the pre-fix body reflects `List<`.
    @Test func everyRegionReadsAsASectionAndTheListIsGone() async throws {
        try await withEditor(seedBlocks: ["First half.", "Second half."]) { h in
            let ops = h.session.operations
            let slots = try h.storeSlots()
            let merge = try ops.merge(slots[0].blockID, slots[1].blockID)
            let mergedID = merge.block.id
            try ops.commit(merge.variant.id)
            let branch = try ops.branchVariant(mergedID, from: merge.variant.id)
            try ops.archiveVariant(branch.id)
            let doomed = try ops.branchVariant(mergedID, from: merge.variant.id)
            try ops.deleteVariant(doomed.id)

            let now = h.session.now
            let history = try await h.session.database.read {
                try Queries.blockHistory($0, blockID: mergedID, now: now)
            }
            #expect(history.origins.count == 2, "the merge's BOTH originals")
            #expect(!history.archivedTakes.isEmpty)
            #expect(!history.deletedTakes.isEmpty)

            let model = BlockHistoryModel(
                session: h.session, postID: h.postID, blockID: mergedID)
            model.adopt(history)
            let pane = BlockHistoryPane(
                session: h.session,
                request: BlockHistoryRequest(postID: h.postID, blockID: mergedID),
                model: model)
            await SurfaceComposition.host(pane, size: NSSize(width: 420, height: 700))
            let shown = SurfaceComposition.text(of: pane.body)

            // The four section headers AND their meaning lines are in the tree.
            #expect(SurfaceComposition.carries(BlockHistoryPath.savepointsSection, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryPath.savepointsExplainer, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryPath.archivedSection, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryCopy.archivedExplainer, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryPath.deletedSection, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryCopy.deletedExplainer, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryPath.cameFromSection, in: shown))
            #expect(SurfaceComposition.carries(OriginPeekCopy.explainer, in: shown))

            // RED ON OLD: the pane was a `List` — the clipping mechanism.
            #expect(!shown.contains("List<"), "the pane must not be a List again")
            #expect(shown.contains("ScrollView"), "the calm scroll rebuild")
            #expect(!shown.contains("DisclosureGroup"),
                    "the take-run fold is a full-line Button now (row 64's rule)")
        }
    }

    // MARK: - The door, declared and rendered

    /// **ONE act, on BOTH bars, beside commit — and the `note ▾` menus lost
    /// their History item in the same commit** (R6-2's one-grammar rule,
    /// which matters most when a door moves).
    ///
    /// Her F2 report is what this closes: *"it's unclear that history is
    /// under Note, that makes it seem like the Note's history."* It was the
    /// BLOCK's all along, and the act is block-scoped now so the registry
    /// itself says so.
    @Test func theHistoryActIsDeclaredOnBothBarsBesideCommit() {
        let act = CapabilityRegistry.capability(.showBlockHistory)
        #expect(act.scope == .block, "her F2 defect, closed at the declaration")
        #expect(act.verb == BlockHistoryPath.name)
        #expect(act.doors == [.bottomBar, .palette])
        #expect(act.takesAccess == .native, "R118: not a Write privilege")
        #expect(!act.unavailableNote.isEmpty)
        // BOTH bars render it — and each one puts it beside commit, which is
        // the whole of her reasoning made visible.
        #expect(CommitBar.renderedCapabilities.contains(.showBlockHistory))
        #expect(TakesBottomBar.renderedCapabilities.contains(.showBlockHistory))
        let write = CommitBar.renderedCapabilities
        #expect(write.contains(.commitTake), "the pair it is the pair TO")
        #expect(ShellActions.paletteActs.contains(.showBlockHistory))
        #expect(!CapabilityRegistry.unhandledNote(
            for: .showBlockHistory, context: CapabilityContext()).isEmpty)
        // Grey where no note is open; alive wherever blocks are edited.
        #expect(!CapabilityRegistry.isEnabled(
            .showBlockHistory, in: CapabilityContext(mode: nil)))
        #expect(CapabilityRegistry.availability(
            .showBlockHistory, in: CapabilityContext(mode: .takes)) == .act)
    }

    /// **THE PANE CARRIES NO PURGE DOOR** — row 21's letter, stated where a
    /// future row could quietly acquire one. Her G5 ruling put Delete Now on
    /// the note's leaving section *"to keep the capability"* after takes left
    /// the global Trash; the rule she left in its place is that purge doors
    /// live in TRASH SURFACES, and a block's history is not one. It lists
    /// what a block HAS BEEN, which is the opposite of a deadline surface.
    @Test func theHistoryPaneOffersPutBackAndUnarchiveAndNoPurgeDoor() {
        #expect(BlockHistoryPane.surfaceCapabilities == [.restoreTake, .unarchiveTake])
        #expect(!BlockHistoryPane.surfaceCapabilities.contains(.deleteNow))
        #expect(!BlockHistoryPane.surfaceCapabilities.contains(.emptyTrash))
        // …and the deleted region SAYS where the capability does live, so the
        // absence is an answer rather than a hole.
        #expect(BlockHistoryCopy.deletedExplainer.contains(TrayPath.menuLabel))
        #expect(BlockHistoryCopy.deletedExplainer.contains("\(TrashWindow.days)"))
    }

    // MARK: - WALK-DRIVEN: the real mounted detail opens the real panel

    /// The detail registers a history seam with the router on appear, so the
    /// bars' door reaches ONE panel by composition — never a broadcast (P-4),
    /// and never the handler stack, whose LIFO order would hand the request
    /// to the editor's own sheet instead.
    @Test func theMountedDetailOpensTheHistoryPaneInItsRealSidePanel() async throws {
        try await mounted { session, post, blockID, variantID, window, hosting in
            #expect(session.commandRouter.activePostID == post, "the detail registered")
            // JUSTIFIED PIN EDIT (the correction round, row 74): the evidence this
            // replaces named the SYSTEM inspector's AppKit container
            // (`InspectorStyleContext`) — the very host row 74 retires, because
            // it drew its divider in a KEY window only. The column is ours now
            // (`SideColumn`), and its oracle — our divider's frame, reported
            // in every window state — is the honest "the pane stands" signal.
            PostDetailOracle.sideColumnDividerFrame = nil
            let atRest = TrayPanelMoveTests.classNames(hosting)
            #expect(PostDetailOracle.sideColumnDividerFrame == nil,
                    "the side panel is not on screen at rest")
            #expect(atRest.contains("EditorTextView"), "the page itself IS mounted")

            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(
                    postID: post, blockID: blockID, focusedVariantID: variantID)),
                    "the seam is registered — the request ACTED (P-2)")
            // JUSTIFIED PIN EDIT (the correction round, rows 28/65): the two
            // assertions this replaces named the LIST's own backing views
            // ("OutlineList", "ListTableHeaderView") — and the List's fixed
            // header measurement was exactly the mechanism that clipped the
            // region headers to slivers, so the rebuild retired it. The pane
            // is a ScrollView of calm sections now; its backing is
            // "HostingScrollView", and the four-regions evidence moved to
            // `everyRegionReadsAsASectionAndTheListIsGone` (a reflection pin
            // over a real seeded history, headers AND meaning lines).
            await Self.settle(window, hosting) {
                PostDetailOracle.sideColumnDividerFrame != nil
                    && TrayPanelMoveTests.classNames(hosting).contains("HostingScrollView")
            }
            let open = TrayPanelMoveTests.classNames(hosting)
            #expect(PostDetailOracle.sideColumnDividerFrame != nil,
                    "the side column really opened — her \"pane to the right\"")
            #expect(open.contains("HostingScrollView"),
                    "with the pane's calm scroll inside it (the List is retired)")
            #expect(!open.contains("ListTableHeaderView"),
                    "no List section headers — the clipping mechanism is gone")
            #expect(open.contains("EditorTextView"),
                    "beside the page, never instead of it (it is a panel, not a sheet)")
        }
    }

    /// A request for a post that is NOT mounted is refused rather than lost —
    /// and, unlike the tray's, it never parks: the doors that raise it (both
    /// bars, ⌘K) are rendered by surfaces already mounted and already holding
    /// their block, so there is no focus change to wait out. The caller's own
    /// sheet takes it.
    @Test func aHistoryRequestForAnUnmountedPostIsRefusedSoTheBarCanFallBack()
        async throws
    {
        try await mounted { session, post, blockID, _, _, _ in
            let router = session.commandRouter
            #expect(!router.requestBlockHistory(
                BlockHistoryRequest(postID: "some-other-note", blockID: blockID)),
                    "a stale target never opens a panel on the wrong note")
            #expect(router.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blockID)))
        }
    }

    // MARK: - Row 10 (C2) / the 13l walk's P-3: ALL of a merge's originals

    /// **THE P-3 FIX, DRIVEN THROUGH A REAL MERGE.** The 13l walk called the
    /// lineage peek *"the best surface in the walk"* and still filed this
    /// against it: `Queries.unplacedOrigins` returns an ARRAY — its own doc
    /// says *"a merge releases both sources, so A′ has two"* — and the peek
    /// took `.first`, so a door promising "the original" showed one of two.
    /// Her C2 ruling: **all** of them (*"it could be more than two originals
    /// even"* — the N-way merge chain makes that real).
    @Test func theCameFromRegionShowsEveryOriginOfAMerge() async throws {
        try await withNote(["Alpha one.", "Beta two.", "Gamma three."]) {
            session, postID, blocks in
            let ops = session.operations
            // An N-way chain: merge A+B, then merge the result with C — three
            // originals behind one block, which is exactly her *"more than
            // two"*.
            let first = try ops.merge(blocks[0], blocks[1])
            let second = try ops.merge(first.block.id, blocks[2])

            let history = try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: second.block.id, now: now)
            }
            #expect(Set(history.origins.map(\.origin.blockID))
                == Set([first.block.id, blocks[2]]),
                    "both of THIS merge's parents, not the first of them")
            #expect(history.origins.allSatisfy { $0.origin.originOp == "merge" })
            // Every row is recognisable on sight: the original's own text
            // rides the projection, which is what let the pane absorb a peek
            // whose whole panel existed to show it.
            #expect(history.origins.allSatisfy { $0.text?.isEmpty == false })

            // …and the FIRST merge's block still names ITS two, so the chain
            // is walkable one link at a time (her "more than two", the way the
            // model actually stores it).
            let deeper = try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: first.block.id, now: now)
            }
            #expect(Set(deeper.origins.map(\.origin.blockID)) == Set([blocks[0], blocks[1]]))
        }
    }

    // MARK: - Region 1: EVERY live take, the focused one open

    /// **The pane sections ALL of the block's takes** — which is the second
    /// thing the two absorbed faces could not do. Write's strip showed the
    /// CARET take's savepoints and the Takes sheet showed the FOCUSED take's;
    /// a block with three takes had three savepoint runs and no surface that
    /// showed more than one of them at a time.
    @Test func everyLiveTakesSavepointRunIsInThePane() async throws {
        try await withNote(["The sea took the boat."]) { session, postID, blocks in
            let ops = session.operations
            let chosen = try #require(
                try await session.database.read {
                    try Queries.renderPost($0, containerID: postID)
                }.first?.variantID)
            let second = try ops.branchVariant(blocks[0], from: chosen)
            try ops.autosave(second.id, text: "Another way of saying it.", charDelta: 0)
            _ = try ops.commit(chosen, kind: .manual)
            _ = try ops.commit(second.id, kind: .manual)
            let archived = try ops.branchVariant(blocks[0], from: chosen)
            try ops.archiveVariant(archived.id)

            let history = try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: blocks[0], now: now)
            }
            #expect(history.activeTakes.map(\.id) == [chosen, second.id],
                    "both live takes, in fan order")
            #expect(history.archivedTakes.map(\.id) == [archived.id],
                    "…and the archived one in its own region, never the fan")
            #expect(history.savepoints[chosen]?.count == 1)
            #expect(history.savepoints[second.id]?.count == 1,
                    "the second take's run is here too — the strip could show one")
            #expect(!history.isEmpty)

            // Her ruling on which one OPENS: the take she is in.
            #expect(BlockHistoryModel.initiallyExpanded(history, focused: second.id)
                == [second.id])
            // No focused take named (a ⌘K row carries none) ⇒ the first live
            // one, never an archived one and never nothing.
            #expect(BlockHistoryModel.initiallyExpanded(history, focused: nil)
                == [chosen])
            // A focused take that has since gone falls back the same way,
            // rather than opening a section that is not there.
            #expect(BlockHistoryModel.initiallyExpanded(history, focused: "gone")
                == [chosen])
        }
    }

    /// **A block with nothing behind it says so** — the pane renders a region
    /// only where there is something in it (P-2's shape, applied to reading).
    @Test func anOrdinaryBlockHasAnEmptyHistoryAndTheCopySaysWhat() async throws {
        try await withNote(["An ordinary block."]) { session, postID, blocks in
            let history = try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: blocks[0], now: now)
            }
            #expect(history.isEmpty)
            #expect(history.origins.isEmpty)
            #expect(history.deletedTakes.isEmpty)
            #expect(BlockHistoryPath.nothingHere.contains("no saved moments"))
        }
    }

    // MARK: - Restore: the flush that has to come first

    /// **A RESTORE FLUSHES THE POST'S PENDING BUFFER FIRST**, and the pin
    /// drives the exact race that makes it necessary.
    ///
    /// The mechanism, traced: the editor debounces autosaves, so at the
    /// moment a restore fires there may be typed text sitting in the
    /// coordinator with no write yet. Restore lands the saved moment into
    /// `working_text`; the pending flush then lands the typed text OVER it,
    /// and the restore she just asked for is silently undone. The absorbed
    /// strip's own `restore` flushed first for exactly this reason; the pane
    /// reaches the same per-post coordinator through the session's
    /// existing-only road, which never mints one for a note nothing opened.
    @Test func aRestoreFlushesThePendingBufferBeforeItLands() async throws {
        try await withNote(["the saved words"]) { session, postID, blocks in
            let ops = session.operations
            let chosen = try #require(
                try await session.database.read {
                    try Queries.renderPost($0, containerID: postID)
                }.first?.variantID)
            _ = try ops.commit(chosen, kind: .manual)

            // A long debounce stands in for "she is still typing": the text
            // is recorded and nothing has written it yet.
            let coordinator = session.autosave(
                forPost: postID, debounce: .seconds(30))
            coordinator.record(
                variantID: chosen, text: "words typed since", charDelta: 17)

            let history = BlockHistoryModel(
                session: session, postID: postID, blockID: blocks[0],
                focusedVariantID: chosen)
            history.adopt(try await session.database.read { [now = session.now] db in
                try Queries.blockHistory(db, blockID: blocks[0], now: now)
            })
            let commit = try #require(history.history.savepoints[chosen]?.first)
            await history.restore(commit, of: chosen)
            #expect(history.status?.isRefusal == false)

            // Whatever else happens, the pending flush must not be able to
            // land ON TOP of the restore — because it already landed BEFORE it.
            await coordinator.flushNow()
            let text = try await session.database.read { [chosen] db in
                try Variant.fetchOne(db, key: chosen)?.workingText
            }
            #expect(text == "the saved words",
                    "the restore stands: \(text ?? "nil")")
        }
    }

    // MARK: - The row faces, as values

    /// The two quiet lines the pane draws, held without rendering — the
    /// `TrayRowFace` shape and its reason (a preview must never share a line
    /// box with its metadata; the walk's P-1 is what that cost).
    @Test func theRowFacesSayWhenAndWhatAndNothingElse() {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        let manual = CommitPoint(
            id: "c1", variantId: "v1", text: "a saved moment", kind: .manual,
            message: "before the rewrite", createdAt: now)
        let meta = SavepointRowFace.meta(manual, predatesSplit: false)
        #expect(meta.contains("saved by hand"))
        #expect(meta.contains("before the rewrite"))
        #expect(!meta.contains(BlockHistoryCopy.predatesSplitMark))
        #expect(!meta.contains { $0.contains("a saved moment") },
                "the text owns its own line — never the metadata's")

        let quiet = CommitPoint(
            id: "c2", variantId: "v1", text: "", kind: .auto, createdAt: now)
        #expect(SavepointRowFace.meta(quiet, predatesSplit: true).contains("quiet"))
        #expect(SavepointRowFace.meta(quiet, predatesSplit: true)
            .contains(BlockHistoryCopy.predatesSplitMark))

        // A deleted take's line: when it went, and how long it has.
        let take = Variant(
            id: "v9", blockId: "b", workingText: "a take", fanPosition: "a",
            createdAt: now, updatedAt: now, deletedAt: now)
        let takeMeta = DeletedTakeFace.meta(take, now: now)
        #expect(takeMeta.count == 2)
        #expect(takeMeta.last == TrayPath.daysLeftLabel(TrashWindow.days))
        // A live take has nothing to say here at all.
        let live = Variant(
            id: "v8", blockId: "b", workingText: "a take", fanPosition: "a",
            createdAt: now, updatedAt: now)
        #expect(DeletedTakeFace.meta(live, now: now).isEmpty)
    }

    // MARK: - Row 28: the Aa condensation

    /// **FORMATTING ONLY BEHIND Aa** — her ruled scope, as a checkable value.
    ///
    /// Her kickoff addition asked for *"an Aa style button that when clicked
    /// expands into the full bar"*, and the sitting's question was WHAT
    /// condenses. Her answer was formatting only, and the bars are what would
    /// quietly drift from it: a future act dropped into the fold "because it
    /// fits there" is a bar she asked to stay legible getting shorter again.
    @Test func onlyFormattingCondensesBehindTheAaDoor() {
        #expect(FormattingDoor.label == "Aa")
        #expect(FormattingDoor.help(expanded: false)
            != FormattingDoor.help(expanded: true),
                "the chip says which way it goes")
        // What is behind the door is EXACTLY the formatting act table.
        #expect(FormattingDoor.condensed == Set(FormatBar.renderedCapabilities))
        #expect(FormattingDoor.condensed.contains(.formatBold))
        #expect(FormattingDoor.condensed.contains(.formatBulletList))

        // …and what her ruling says STAYS VISIBLE really does. `block ▾`,
        // Takes, commit, HISTORY, `note ▾`, comments — the bar as the block's
        // time controls, which is the reading row 17 depends on.
        for bar in [CommitBar.renderedCapabilities, TakesBottomBar.renderedCapabilities] {
            let visible = Set(bar).subtracting(FormattingDoor.condensed)
            #expect(visible.contains(.commitTake))
            #expect(visible.contains(.showBlockHistory), "the pair, at rest")
            #expect(visible.contains(.blockComments))
            #expect(visible.contains(.sealPost))
            #expect(visible.contains(.deleteBlock))
            #expect(visible.contains(.deleteNote))
            #expect(Set(bar).intersection(FormattingDoor.condensed)
                == FormattingDoor.condensed,
                    "the whole cluster is still this bar's to render")
        }
        // **The registry ids are UNCHANGED** — the R6-2/13g slide-out class:
        // rendering a door behind an expansion is still rendering it, so the
        // declared ⇔ rendered walk is untouched by the fold.
        #expect(Set(TakesBottomBar.renderedCapabilities)
            .union(CommitBar.renderedCapabilities)
            == CapabilityRegistry.doored(.bottomBar))
    }

    /// **WALK-DRIVEN: the real bar really is shorter at rest.**
    ///
    /// The value pin above holds what condenses; this holds that it condenses
    /// — the same `CommitBar` mounted twice, folded and open, and the count of
    /// real AppKit buttons in the subtree. (Class names are the honest probe
    /// here for batch 3's measured reason: the AX tree is empty in this test
    /// host, so a label-based pin would pass vacuously.)
    @Test func theRealBarDrawsFewerDoorsAtRestThanWithAaOpen() async throws {
        try await withEditor(seedBlocks: ["A block to stand in."]) { h in
            let folded = try Self.mountedBarControls(h.model, expanded: false)
            let open = try Self.mountedBarControls(h.model, expanded: true)
            #expect(folded > 0, "the bar is really mounted, not an empty tree")
            #expect(open > folded,
                    "Aa slides doors OUT: \(folded) at rest, \(open) open")
            // The cluster it hides is the formatting one, so the difference is
            // at least its size — a fold that hid one button would be theatre.
            #expect(open - folded >= FormatBar.renderedCapabilities.count - 2,
                    "the whole cluster moved, not a token of it")
        }
    }

    /// Mounts the REAL bar in a real window and counts the focusable controls
    /// in its subtree.
    private static func mountedBarControls(
        _ model: EditorViewModel, expanded: Bool
    ) throws -> Int {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 200),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(
            rootView: CommitBar(model: model, formattingExpanded: expanded)
                .environment(ThemeStore(session: model.session)))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 200)
        window.contentView = hosting
        window.orderFrontRegardless()
        for _ in 0..<20 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
        }
        return countControls(hosting)
    }

    /// How many focusable CONTROLS the mounted bar really has.
    ///
    /// `KeyViewProxy` is the AppKit view SwiftUI installs per focusable
    /// control, and it is the honest probe available here: the bar's doors
    /// are `VoicedButtonStyle` / `VoicedChip` — SwiftUI-drawn, so there is no
    /// `NSButton` to count (measured, not assumed: an `is NSButton` walk
    /// returned zero on a bar that is plainly full of doors), and the AX tree
    /// this host would otherwise answer from is empty (batch 3's measurement).
    private static func countControls(_ view: NSView) -> Int {
        let mine = String(describing: type(of: view)).contains("KeyViewProxy") ? 1 : 0
        return mine + view.subviews.reduce(0) { $0 + countControls($1) }
    }

    // MARK: - Row 33: the current-block jump

    /// **THE DECISION, AS A PURE RULE.** Her 2026-08-25 refinement ratified the
    /// request scoping and asked for the way out of it: *"if you've changed
    /// blocks there should be a small button or something to show current
    /// block's history, so you don't have to close it and reopen it."*
    ///
    /// So the rule is exactly "same note, different block", and everything
    /// else is no door at all (P-2): an unknown caret, a caret in another
    /// note, a caret in the block already on screen. The take she is standing
    /// in rides the request, so her *"the focused take's expanded"* ruling
    /// survives the jump.
    @Test func theJumpOffersItselfOnlyWhenTheCaretIsInAnotherBlockOfThisNote() {
        let here = FocusedBlock(postID: "N", blockID: "B1", variantID: "V1")
        let there = FocusedBlock(postID: "N", blockID: "B2", variantID: "V2")
        let elsewhere = FocusedBlock(postID: "OTHER", blockID: "B9", variantID: "V9")

        #expect(BlockHistoryModel.jumpTarget(nil, postID: "N", blockID: "B1") == nil,
                "no caret reported yet — nothing to offer")
        #expect(BlockHistoryModel.jumpTarget(here, postID: "N", blockID: "B1") == nil,
                "the caret is in the very block on screen — the door would do nothing")
        #expect(BlockHistoryModel.jumpTarget(elsewhere, postID: "N", blockID: "B1") == nil,
                "another note's caret is not \u{201C}the block you're in\u{201D} here")

        let jump = BlockHistoryModel.jumpTarget(there, postID: "N", blockID: "B1")
        #expect(jump == BlockHistoryRequest(
            postID: "N", blockID: "B2", focusedVariantID: "V2"),
                "the jump carries the take she is in, not just the block")
    }

    /// **The surfaces really report it, and only on a block change.** The
    /// fact is observable and read during `body`, so a report at keystroke
    /// rate would re-render the panel on every letter — which is why both
    /// writing surfaces report inside a changed-block guard and the router
    /// assigns only on a real change.
    @Test func theCaretFactIsRecordedForTheOpenNoteAndNobodyElse() async throws {
        try await withNote(["Alpha one.", "Beta two."]) { session, post, blocks in
            let router = session.commandRouter
            #expect(router.focusedBlock == nil, "nothing reported yet")

            // No detail mounted ⇒ the report is not for a note on screen.
            router.noteFocusedBlock(blocks[0], variantID: nil, postID: post)
            #expect(router.focusedBlock == nil)

            let token = router.registerDetail(postID: post, mode: .write, applyMode: { _ in })
            router.noteFocusedBlock(blocks[0], variantID: "V", postID: post)
            #expect(router.focusedBlock
                == FocusedBlock(postID: post, blockID: blocks[0], variantID: "V"))
            router.noteFocusedBlock(blocks[1], variantID: nil, postID: "another-note")
            #expect(router.focusedBlock?.blockID == blocks[0],
                    "a background pane's caret never speaks for the note on screen")
            router.unregisterDetail(token)
            #expect(router.focusedBlock == nil, "the note left; so did the fact")
        }
    }

    /// **THE WRITING SURFACE REALLY REPORTS IT** — the plumbing behind the
    /// door, driven through a REAL editor: move the caret into the next
    /// paragraph and the router's fact follows, take and all.
    @Test func movingTheCaretIntoAnotherBlockReportsItToTheRouter() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { h in
            let router = h.session.commandRouter
            let token = router.registerDetail(
                postID: h.postID, mode: .write, applyMode: { _ in })
            defer { router.unregisterDetail(token) }

            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.model.updateCaretContext()
            let first = try #require(router.focusedBlock)
            #expect(first.postID == h.postID)
            #expect(first.variantID != nil, "the take rides, so the jump can expand it")

            // "Alpha one.\nBeta two." — anything past the terminator is the
            // second paragraph.
            h.textView.setSelectedRange(NSRange(location: 13, length: 0))
            h.model.updateCaretContext()
            let second = try #require(router.focusedBlock)
            #expect(second.blockID != first.blockID,
                    "the fact followed the caret across the seam")
            #expect(second.blockID == h.model.caretBlockID)
        }
    }

    /// **WALK-DRIVEN: the real pane really draws the door, and only then.**
    ///
    /// The REAL `BlockHistoryPane` mounted in a real window twice — once with
    /// the caret in the block it is showing, once with the caret in the block
    /// next door — and the focusable controls counted in each subtree. The
    /// second is exactly one higher: the door her ruling asked for, drawn when
    /// and only when it can act.
    ///
    /// **Two mounts rather than one toggled in place, and the reason is
    /// MEASURED, not assumed** (the same discipline batch 3's empty-AX finding
    /// and batch 4's zero-`NSButton` finding come out of): in this headless
    /// host an in-place `@Observable` change does not rebuild the hosted tree
    /// within any settle window. I probed it with a change that has nothing to
    /// do with row 33 — adopting a history carrying a deleted take, which adds
    /// a Put back button — and the count stayed put at 1 through a full settle,
    /// exactly as the caret report did. It is the HOST, not the read: mounted
    /// fresh with the caret elsewhere, the pane draws the door every time. That
    /// is also why `theRealBarDrawsFewerDoorsAtRestThanWithAaOpen` mounts its
    /// bar twice instead of toggling the fold, one screen up in this file.
    @Test func theMountedPaneDrawsItsJumpDoorOnlyWhenTheCaretIsElsewhere() async throws {
        try await withNote(["Alpha one.", "Beta two."]) { session, post, blocks in
            let here = try await Self.mountedPaneControls(
                session: session, post: post, pane: blocks[0], caret: blocks[0])
            let elsewhere = try await Self.mountedPaneControls(
                session: session, post: post, pane: blocks[0], caret: blocks[1])
            #expect(here > 0, "the pane is really mounted, not an empty tree")
            #expect(elsewhere == here + 1,
                    """
                    the caret in the next block draws EXACTLY the jump door: \
                    \(here) with the caret here, \(elsewhere) with it there
                    """)
        }
    }

    /// Mounts the REAL pane with the router's caret fact set, and counts the
    /// focusable controls in its subtree (`mountedBarControls`' shape and its
    /// reason: the doors are SwiftUI-drawn, so `KeyViewProxy` is the honest
    /// probe and the AX tree this host would answer from is empty).
    private static func mountedPaneControls(
        session: AppSession, post: String, pane: String, caret: String
    ) async throws -> Int {
        let router = session.commandRouter
        let token = router.registerDetail(postID: post, mode: .write, applyMode: { _ in })
        defer { router.unregisterDetail(token) }
        router.noteFocusedBlock(caret, variantID: nil, postID: post)

        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 460, height: 620),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(
            rootView: BlockHistoryPane(
                session: session,
                request: BlockHistoryRequest(postID: post, blockID: pane),
                onJump: { _ in })
                .environment(ThemeStore(session: session)))
        hosting.frame = NSRect(x: 0, y: 0, width: 460, height: 620)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting) { countControls(hosting) > 0 }
        return countControls(hosting)
    }

    // MARK: - Row 14 (F1): archive beside delete, and one take-card grammar

    /// **ARCHIVE RIDES BESIDE DELETE AT EVERY BLOCK DOOR** — her F1 rule,
    /// checked against the registry's own door sets rather than by looking.
    ///
    /// The pass she asked for was a VERIFICATION (*"no, I see archive there
    /// too"*), and it found exactly one class of straggler: every door table
    /// that carried `.deleteBlock` carried `.archiveBlock` too, EXCEPT the
    /// bars' `block ▾` menus and Blocks mode's row menu — the two doors she
    /// actually reaches for while writing. So the two verbs that exist to be
    /// told apart appeared together in the menu bar and the context menu and
    /// separately where the work happens.
    @Test func everyDoorThatDeletesABlockOffersToArchiveItToo() {
        let deleteDoors = CapabilityRegistry.capability(.deleteBlock).doors
        let archiveDoors = CapabilityRegistry.capability(.archiveBlock).doors
        for door in deleteDoors where door != .palette {
            #expect(archiveDoors.contains(door),
                    "\(door) deletes a block and must offer to keep it: \(archiveDoors)")
        }
        // The one deliberate exception, stated so it is a decision and not a
        // gap: ⌘K carries delete and not archive because a palette row is
        // typed by name — someone who wants to archive types "Archive Block",
        // and the act is one line away in the same list.
        #expect(deleteDoors.contains(.palette))

        // The RENDERERS, each named: the menu bar's Block menu, the block
        // context menu, both bars' `block ▾`, and Blocks mode's rows.
        // (Re-anchored at pre-13u Act 10 wave 2c: `BlockTOCView` grew into
        // `BlocksWorkbenchView` + `IndexModeView` — W8-1's ruling; BOTH new
        // faces carry the pair, so the promise widened rather than moved.)
        #expect(EditorCommands.menuRendered.contains(.archiveBlock))
        #expect(EditorViewModel.contextMenuCapabilities.contains(.archiveBlock))
        #expect(CommitBar.renderedCapabilities.contains(.archiveBlock))
        #expect(TakesBottomBar.renderedCapabilities.contains(.archiveBlock))
        #expect(BlocksWorkbenchView.surfaceCapabilities.contains(.archiveBlock))
        #expect(IndexModeView.surfaceCapabilities.contains(.archiveBlock))
        // …and each of those renders the DELETE beside it.
        #expect(EditorCommands.menuRendered.contains(.deleteBlock))
        #expect(EditorViewModel.contextMenuCapabilities.contains(.deleteBlock))
        #expect(CommitBar.renderedCapabilities.contains(.deleteBlock))
        #expect(TakesBottomBar.renderedCapabilities.contains(.deleteBlock))
        #expect(BlocksWorkbenchView.surfaceCapabilities.contains(.deleteBlock))
        #expect(IndexModeView.surfaceCapabilities.contains(.deleteBlock))

        // THE SCRAP ROWS are block doors too — a scrap IS a block — and batch
        // 1 gave them the delete while naming these two listings as F1's to
        // enumerate. Both carry the pair now.
        for table in [
            BlocksAreaView.surfaceCapabilities, ScrapsPanel.surfaceCapabilities,
        ] {
            #expect(table.contains(.deleteScrap))
            #expect(table.contains(.archiveScrap))
        }
        #expect(CapabilityRegistry.capability(.archiveScrap).scope == .block)
        #expect(CapabilityRegistry.capability(.archiveScrap).doors == [.surface])
    }

    /// **ONE TAKE-CARD GRAMMAR** — her F1 rule's second half: *"Write's panel
    /// ⋯ carries Archive · Label · Lock · Delete — Takes mode's card grammar
    /// must match."*
    ///
    /// What the pass found, and why nothing caught it: Write's panel has
    /// rendered all four since Phase 7 and **declared none of them**, and
    /// Takes mode's cards carried Archive and Label only. With no
    /// declaration there was no door set for the walk to compare, so one
    /// surface offering half of a grammar was invisible by construction.
    /// Declaring `.lockTake` and `.deleteTake` is what makes this pin
    /// possible at all.
    @Test func theTakeCardsCarryTheSameFourActsOnBothSurfaces() {
        let grammar: Set<CapabilityID> = [.archiveTake, .labelTake, .lockTake, .deleteTake]
        #expect(grammar.isSubset(of: Set(WriteTakesPanel.surfaceCapabilities)),
                "Write's panel: \(WriteTakesPanel.surfaceCapabilities)")
        #expect(grammar.isSubset(of: Set(TakesCellView.contextMenuCapabilities)),
                "the board's cards: \(TakesCellView.contextMenuCapabilities)")
        // Both new acts are declared where they are rendered, and take-scoped.
        for id in [CapabilityID.lockTake, .deleteTake] {
            let act = CapabilityRegistry.capability(id)
            #expect(act.scope == .take)
            #expect(act.doors == [.contextMenu, .surface])
            #expect(act.takesAccess == .native, "R118: not a Write privilege")
            #expect(!act.unavailableNote.isEmpty)
        }
        // The lock row says WHICH WAY it points — a row reading "Lock" on a
        // locked take is the small dishonesty this family of surfaces exists
        // to end (Write's panel has always worded it this way).
        #expect(TakeCardMenuCopy.lockVerb(locked: false).contains("Lock"))
        #expect(TakeCardMenuCopy.lockVerb(locked: true).contains("Unlock"))
        #expect(TakeCardMenuCopy.deleteTake.contains("Delete"))
    }

    // MARK: - Harness

    private func withNote(
        _ texts: [String],
        _ body: @escaping (AppSession, String, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the block's time")
            var blocks: [String] = []
            for text in texts {
                blocks.append(try session.operations.newBlock(in: post.id, text: text).block.id)
            }
            try await body(session, post.id, blocks)
        }
    }

    /// Mounts the REAL `PostDetailView` in a real window (batch 3's harness,
    /// which is where the "drive the real surface" discipline for this view
    /// already lives).
    private func mounted(
        _ body: @escaping (
            AppSession, String, String, String?, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the pane")
            let minted = try session.operations.newBlock(
                in: post.id, text: "A block, so the page has one.")
            // The block is given a PAST, so more than one region renders and
            // "the four regions her ruling names" is a claim the class names
            // can actually carry (a `Section` with nothing in it builds no
            // header, which is the pane working, not a gap).
            _ = try session.operations.commit(minted.variant.id, kind: .manual)
            let spare = try session.operations.branchVariant(
                minted.block.id, from: minted.variant.id)
            try session.operations.deleteVariant(spare.id)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await Self.settle(window, hosting) {
                session.commandRouter.activePostID == post.id
            }
            try await body(
                session, post.id, minted.block.id, minted.variant.id, window, hosting)
        }
    }

    private nonisolated static func pump(_ seconds: TimeInterval = 0.03) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView,
        maxTurns: Int = 60, until predicate: () -> Bool
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }
}
