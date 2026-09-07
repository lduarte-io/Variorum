//
//  BlockTOCView.swift
//  Variorum
//
//  Phase 11, Step A6 — the collapsible block-TOC (AppSpec §14's 2026-07-07
//  delta; §12's view list): one row per block — the explicit name where
//  set, else the first sentence DERIVED AT READ TIME (never stored); a row
//  expands into the read-cheap tier and exactly ONE expanded block
//  upgrades to the live editor on click (P3's split, reused — the same
//  TakePane machinery). Collapse state is session-only; there is NO
//  in-place folding inside the live editor (TEXTKIT2 §3 — the TOC is a
//  pane). Block management lives here too (the 2026-07-09 affordances):
//  naming, reorder, delete + the tray's restore door, move to pool.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class BlockTOCViewModel {
    @ObservationIgnored let session: AppSession
    let postID: String
    /// Internal so tests can await deterministic flushes.
    @ObservationIgnored let autosave: AutosaveCoordinator

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
        // 13b 1a (N3): the ONE per-post coordinator; the quit door covers
        // it at the session scope.
        self.autosave = session.autosave(forPost: postID)
        autosaveToken = autosave.observe(
            onError: { [weak self] error in
                self?.statusMessage = OpsRefusalCopy.message(for: error)
            })
        // (Buffer convergence rides `adopt(rows:)` — the settle happens
        // WITH fresh rows in hand, so a landed buffer never reverts the
        // display to stale text for even one cycle.)
    }

    @ObservationIgnored private var autosaveToken: UUID?

    func teardown() {
        if let autosaveToken {
            autosave.stopObserving(autosaveToken)
            self.autosaveToken = nil
        }
        Task { await autosave.flushNow() }
    }

    private(set) var rows: [Queries.TOCRow] = []
    /// Wave 2c (item 16, direction C): the workbench's rows-with-FACTS —
    /// populated only where `startFacts()` runs (the Blocks mode); Index
    /// rides `rows` alone.
    private(set) var facts: [Queries.WorkbenchRow] = []
    /// The workbench's multi-select — the ONE selection brain (13e's
    /// `BlockSelection`), pruned on every projection adopt so an act can
    /// never address a ghost.
    var picked = BlockSelection()
    private(set) var tray: [Queries.TrayItem] = []
    /// 13j ladder A round 1, finding A6 (the flow's SECOND instance): this
    /// mode's tray observation was held UNBOUNDED — the same `trayBlocks`
    /// fetch the tray panel windows, with no window at all. Same window
    /// constant as the panel (one discipline, one number), truncation
    /// visible below the section (never a silent cut).
    private(set) var trayTruncated = false
    private(set) var pools: [Container] = []
    /// Expanded rows — SESSION-ONLY in v1 (the ratified reading; nothing
    /// persisted anywhere).
    private(set) var expanded: Set<String> = []
    /// THE pane-text/liveness authority (13b 1a, P-3): the TOC previously
    /// kept NO buffer map — the round-2 NIT-5 accepted residual (a blurred
    /// pane could flash pre-flush projection text). The shared authority
    /// retires it: rows resolve through the buffer overlay like every pane.
    private(set) var authority = PaneTextAuthority()
    /// The ONE live block (P3's split: expanded rows are read-cheap; one
    /// upgrades on click) — the authority's, forwarded.
    var liveBlockID: String? { authority.livePane?.blockID }
    /// The TOC's transient outcome line. PRESENTATION is the shell's
    /// StatusCenter (round-1 MINOR-2 — the AD-14 forward this VM alone
    /// lacked; Blocks is a full mode surface, and its own red caption
    /// never dismissed). The property remains the tested truth.
    private(set) var statusMessage: String? {
        didSet {
            if let statusMessage { session.status.speak(statusMessage) }
        }
    }

    func start() async {
        do {
            for try await value in session.database.observeBlockTOC(postID) {
                adopt(rows: value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    // MARK: - Row 83 (the Act 10 correction round, batch G): the rows FIRST

    /// **Blocks arrives painted.** Batch C measured the mode's first paint
    /// EMPTY for ~0.25–0.5 s on the 215-block story — the tool row up, the
    /// list blank — until the observations' FIRST delivery (a value
    /// observation's initial fetch is scheduled through the database's
    /// queues and delivered a turn later, and five sibling observations
    /// start at once and contend for the reader pool). So the workbench
    /// PRIMES the rows with ONE bounded read (the same query the
    /// observation runs — cost ∝ the note, P1) before its observation
    /// starts, and the sibling observations wait for that read (their
    /// first deliveries no longer sit on the critical path). The
    /// observation then keeps the rows live exactly as before.
    private(set) var primed = false
    private var primedWaiters: [CheckedContinuation<Void, Never>] = []

    func primeRows() async {
        if rows.isEmpty,
           let first = try? await session.database.read({ [postID] db in
               try Queries.blockTOC(db, post: postID)
           }) {
            adopt(rows: first)
        }
        primed = true
        let waiters = primedWaiters
        primedWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

    /// Suspends until `primeRows` has run (returns at once after it).
    func awaitPrimed() async {
        if primed { return }
        await withCheckedContinuation { primedWaiters.append($0) }
    }

    /// The workbench's facts observation (wave 2c — opt-in; only the
    /// Blocks mode pays for the joined row). Row 83: the facts are primed
    /// the same way — one bounded read before the observation — so the
    /// context panel and the per-row facts land with the rows' first
    /// paint rather than a delivery later.
    func startFacts() async {
        if facts.isEmpty,
           let first = try? await session.database.read({ [postID] db in
               try Queries.blockWorkbench(db, post: postID)
           }) {
            adopt(facts: first)
        }
        do {
            for try await value in session.database.observeBlockWorkbench(postID) {
                adopt(facts: value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    func adopt(facts: [Queries.WorkbenchRow]) {
        self.facts = facts
        picked.prune(to: Set(facts.map(\.blockID)))
        authority.settle(isPending: { autosave.pending[$0] != nil })
    }

    func startTray() async {
        do {
            for try await value in session.database.observeTray(
                postID, now: session.now, limit: TrayViewModel.window + 1
            ) {
                adopt(tray: value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    func startPools() async {
        do {
            for try await value in session.database.observePools() {
                pools = value
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// Test seam: adopt a projection deterministically. Settle-time
    /// convergence rides every adoption (the authority's rule): buffers
    /// with no pending autosave drop, so external edits reach the rows.
    func adopt(rows: [Queries.TOCRow]) {
        self.rows = rows
        authority.settle(isPending: { autosave.pending[$0] != nil })
    }
    func adopt(tray: [Queries.TrayItem]) {
        // A6: the probe-row window (the `TrayViewModel.adopt` shape) — the
        // observation fetches window + 1, so an exact-window listing never
        // false-positives the marker.
        trayTruncated = tray.count > TrayViewModel.window
        self.tray = trayTruncated
            ? Array(tray.prefix(TrayViewModel.window)) : tray
    }

    /// A row's displayed text: the authority's overlay over the store's
    /// row text (13b 1a — retires the NIT-5 stale-flash residual).
    func displayText(variantID: String?, storeText: String?) -> String {
        guard let variantID else { return storeText ?? "" }
        return authority.text(variantID: variantID, storeText: storeText ?? "")
    }

    // MARK: - Expansion (session-only) + the one live editor

    func toggleExpanded(_ blockID: String) {
        if expanded.contains(blockID) {
            expanded.remove(blockID)
            if liveBlockID == blockID { authority.blur() }
        } else {
            expanded.insert(blockID)
        }
    }

    /// The ring goes (the Read host flipping to its read-only face; a
    /// teardown): the leaving pane's text lands through the ONE coordinator.
    func blur() {
        guard authority.livePane != nil else { return }
        authority.blur()
        Task { await autosave.flushNow() }
    }

    func makeLive(_ blockID: String, variantID: String) {
        let key = PaneTextAuthority.PaneKey(
            columnID: "toc", blockID: blockID, variantID: variantID)
        // 17o batch b (U-20): the pane enters the note's current block where
        // she was — armed before the focus, and only for that block (a click
        // into another block brought its own place).
        armPaneCaretLanding(blockID: blockID, variantID: variantID)
        switch authority.focus(key) {
        case .unchanged:
            return
        case .migrated:
            // The leaving pane's text lands as the ring migrates; the
            // buffer overlay keeps the just-blurred row current meanwhile.
            Task { await autosave.flushNow() }
        }
    }

    /// The note's remembered caret place, for the ONE pane about to go live
    /// (17o batch b). `@ObservationIgnored`: read at the render the ring move
    /// already caused, never watched.
    @ObservationIgnored private var paneCaretLanding: (variantID: String, offset: Int)?

    private func armPaneCaretLanding(blockID: String, variantID: String) {
        guard let fact = session.commandRouter.currentBlock(for: postID),
              fact.blockID == blockID, let offset = fact.utf16Offset
        else {
            paneCaretLanding = nil
            return
        }
        paneCaretLanding = (variantID: variantID, offset: offset)
    }

    /// What a pane rendering `variantID` is handed on going live.
    func caretLanding(forVariant variantID: String) -> Int? {
        paneCaretLanding?.variantID == variantID ? paneCaretLanding?.offset : nil
    }

    /// 17o batch b (her ruling U-20): Read's `edit` face holds a real caret
    /// in its ONE live pane, so it reports where that caret is — the same
    /// door Write's editor and the Takes board's live pane report through.
    /// The live pane only (P-3's line: a read pane's selection is not a
    /// caret), and the host's own block report stays the block's.
    func notePaneCaret(blockID: String, variantID: String, offset: Int) {
        guard authority.livePane?.variantID == variantID else { return }
        session.commandRouter.noteFocusedBlock(
            blockID, variantID: variantID, postID: postID, utf16Offset: offset)
    }

    func paneEdited(variantID: String, oldText: String, newText: String) {
        let old = authority.text(variantID: variantID, storeText: oldText)
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        authority.bufferEdited(variantID: variantID, text: newText)
        autosave.record(variantID: variantID, text: newText, charDelta: cost)
    }

    // MARK: - Naming (setBlockName's face)

    func rename(blockID: String, to name: String) async {
        await run { ops in try ops.setBlockName(blockID, name: name) }
    }

    // MARK: - Block management (the 2026-07-09 affordances)

    /// Reorder by one step — exactly the Phase 2 fractional-index op.
    func move(blockID: String, up: Bool) async {
        guard let index = rows.firstIndex(where: { $0.blockID == blockID }) else { return }
        let target: Operations.InsertPosition
        if up {
            guard index > 0 else { return }
            target = .before(rows[index - 1].blockID)
        } else {
            guard index < rows.count - 1 else { return }
            target = .after(rows[index + 1].blockID)
        }
        await run { ops in try ops.reorder(blockID, to: target) }
    }

    /// 13b 4D (N39, her ask verbatim: "type in what number block you want
    /// it to be out of the total post, or move to top or move to bottom,
    /// so you don't only have to drag it"): a positional move — the block
    /// becomes #target of the post (1-based, clamped to the live count).
    /// ONE ordinary `reorder` op (⌥⌘Z undoes — the op registers its own
    /// inverse); position math over the OTHER rows' order, so "make me
    /// #k" reads exactly as a human counts.
    func move(blockID: String, toOrdinal target: Int) async {
        guard rows.contains(where: { $0.blockID == blockID }) else { return }
        let others = rows.filter { $0.blockID != blockID }
        let clamped = min(max(target, 1), rows.count)
        let insert: Operations.InsertPosition =
            clamped - 1 >= others.count ? .end : .before(others[clamped - 1].blockID)
        // Already there? Speak the no-op honestly instead of writing rows.
        if let current = rows.firstIndex(where: { $0.blockID == blockID }),
           current + 1 == clamped {
            statusMessage = "Already block \(clamped) of \(rows.count)."
            return
        }
        await run { ops in try ops.reorder(blockID, to: insert) }
        if statusMessage == nil {
            statusMessage = "Moved — now block \(clamped) of \(rows.count) (⌥⌘Z undoes)."
        }
    }

    func moveToTop(_ blockID: String) async {
        await move(blockID: blockID, toOrdinal: 1)
    }

    func moveToBottom(_ blockID: String) async {
        await move(blockID: blockID, toOrdinal: rows.count)
    }

    func deleteBlock(_ blockID: String) async {
        await run { ops in try ops.deleteBlock(blockID) }
    }

    /// The post-13l polish round (ledger row 14 / F1): the kept road, on the
    /// row that already offered the clocked one. Blocks mode is a listing of
    /// this note's blocks, and archive is exactly the verb a listing wants —
    /// set it aside without starting a countdown.
    func archiveBlock(_ blockID: String) async {
        await run { ops in try ops.archiveBlock(blockID) }
    }

    // (The tray's own Restore door used to live here. 13j round 7 routed this
    // mode's tray section to the ONE panel — "one surface, one truth" — so
    // the door lives in `TrayPanel` and this model no longer carries a second
    // copy of it. The tray LISTING stays: the section's door wears its count.)

    /// 13b 4D (N32(a), her confusion answered in the UI): move-to-pool is
    /// `moveBlock` — the block LEAVES the post (I2: one home per block; its
    /// takes go with it) and becomes a scrap there. The completion SPEAKS
    /// the consequence and the road back.
    func moveToPool(_ blockID: String, poolID: String, poolTitle: String? = nil) async {
        await run { ops in try ops.moveBlock(blockID, to: poolID, at: .end) }
        if statusMessage == nil {
            let name = (poolTitle?.isEmpty == false) ? "\u{201C}\(poolTitle!)\u{201D}" : "the pool"
            statusMessage = "Moved to \(name) — the block LEFT this note (a block lives in "
                + "one place; its takes went with it). Find it in Snippets; ⌥⌘Z brings it back."
        }
    }

    /// The view's speaking surface (fire-and-speak — a malformed position
    /// entry gets words, never silence).
    func speak(_ message: String) {
        statusMessage = message
    }

    // MARK: - The workbench's bulk acts (wave 2c, item 16 direction C —
    // 13e's block multi-select given its management face)

    /// The picked blocks in NOTE order (the store's projection order —
    /// the selection never invents one).
    var pickedInOrder: [String] {
        picked.inOrder(rows.map(\.blockID))
    }

    /// Move every picked block to the top (bottom), keeping their
    /// relative order — ONE compound entry, ordinary `reorder` ops.
    func movePicked(toTop: Bool) async {
        let chain = pickedInOrder
        guard !chain.isEmpty else { return }
        let others = rows.map(\.blockID).filter { !picked.contains($0) }
        guard !others.isEmpty else { return }  // the whole note is picked — nothing to move past
        statusMessage = nil
        do {
            let stack = session.undoStack
            try await session.runner.run { ops in
                try stack.withCompound(label: "Move Blocks", operations: ops) {
                    if toTop {
                        var previous: String?
                        for blockID in chain {
                            let target: Operations.InsertPosition =
                                previous.map { .after($0) } ?? .before(others[0])
                            try ops.reorder(blockID, to: target)
                            previous = blockID
                        }
                    } else {
                        for blockID in chain {
                            try ops.reorder(blockID, to: .end)
                        }
                    }
                }
            }
            statusMessage = "Moved \(chain.count) block\(chain.count == 1 ? "" : "s") "
                + "to the \(toTop ? "top" : "bottom") (\u{2325}\u{2318}Z undoes in one go)."
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// **Merge the picked run** — the third door of the 13e/13j act
    /// (Write's `mergeChain`, the Takes board's ⌘-click merge, now the
    /// workbench). The BRAINS are the shared ones (`BlockSelection`'s
    /// contiguity, `CarryAllMerge`'s composition, the one refusal copy);
    /// adjacency, fans and the displayed take are read FROM THE STORE —
    /// a projection is a selection aid, never an authorization.
    ///
    /// **18f batch 1 (her U-16):** the bulk bar's second door names the ROAD —
    /// bring every take (the carry-all chain) or only the shown ones (the
    /// plain chain). One chain body serves both (`MergeChainRun`), shared with
    /// Write and the Takes board.
    func mergePicked(bringEveryTake: Bool = true) async {
        let pickedSet = picked.picked
        guard pickedSet.count >= 2 else {
            speak("\u{2318}-click a second block first — merge joins the blocks you pick.")
            return
        }
        await autosave.flushNow()
        let slots: [Queries.RenderedBlock]
        do {
            slots = try await session.database.read { [postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
            return
        }
        let order = slots.map(\.blockID)
        guard pickedSet.isSubset(of: Set(order)) else {
            speak(BlockSelectionCopy.blockGoneForMerge)
            return
        }
        guard BlockSelection.isContiguousRun(pickedSet, in: order) else {
            speak("Merge joins neighbouring blocks — these aren't next to each other. "
                + "Pick blocks that sit side by side.")
            return
        }
        let chain = order.filter { pickedSet.contains($0) }
        let fans: [String: [Variant]]
        do {
            fans = try await session.database.read { db in
                var result: [String: [Variant]] = [:]
                for id in chain {
                    result[id] = try Queries.blockFan(db, blockID: id)
                        .filter { $0.deletedAt == nil && $0.status == .active }
                }
                return result
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
            return
        }
        let displayed = Dictionary(
            uniqueKeysWithValues: chain.map { id in
                (id, slots.first { $0.blockID == id }?.variantID)
            })
        // The A5 validation is the CARRY-ALL road's; the plain road depends
        // on no displayed-take resolution and cannot suffer that race.
        if bringEveryTake,
           !CarryAllMerge.chainComposes(order: chain, fans: fans, displayed: displayed) {
            speak(FannedDefaultsCopy.takesChangedMerge)
            return
        }
        statusMessage = nil
        do {
            let stack = session.undoStack
            let landing: MergeChainRun.Landing = try await session.runner.run { ops in
                try stack.withCompound(label: "Merge Blocks", operations: ops) {
                    try MergeChainRun.run(
                        ops, order: chain, fans: fans, displayed: displayed,
                        bringEveryTake: bringEveryTake)
                }
            }
            let carried = max(0, landing.takesOnMerged - 1)
            picked.clear()
            speak(FannedDefaultsCopy.mergedChain(blocks: chain.count, carried: carried))
        } catch {
            let op = error as? OperationError
            if case .blockNotFound = op {
                statusMessage = BlockSelectionCopy.blockGoneForMerge
            } else if case .blockNotPlaced = op {
                statusMessage = BlockSelectionCopy.blockGoneForMerge
            } else {
                statusMessage = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// Bulk archive — the standing per-block op, plain loop (the Snippets
    /// bulk grammar; archive is the no-clock verb).
    func archivePicked() async {
        let chain = pickedInOrder
        guard !chain.isEmpty else { return }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                for id in chain { try ops.archiveBlock(id) }
            }
            picked.clear()
            statusMessage = BlockSelectionCopy.archivedNote(home: .post)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// Bulk delete — 13e E2's compound shape: ONE entry, all-or-nothing,
    /// the ruled receipt naming both roads back.
    func deletePicked() async {
        let pickedSet = picked.picked
        guard !pickedSet.isEmpty else { return }
        let order = rows.map(\.blockID)
        let chain = pickedSet.subtracting(order).sorted()
            + order.filter { pickedSet.contains($0) }
        statusMessage = nil
        do {
            let stack = session.undoStack
            try await session.runner.run { ops in
                try stack.withCompound(label: "Delete Blocks", operations: ops) {
                    for blockID in chain { try ops.deleteBlock(blockID) }
                }
            }
            picked.clear()
            statusMessage = BlockSelectionCopy.deletedNote(chain.count)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// **The newline repair over the picked blocks** (18c batch 3 — her
    /// U-6). The 13e E2 compound shape, exactly as `deletePicked`: ONE
    /// entry, all-or-nothing, the receipt counted from the operations' own
    /// results. A picked block that is already one paragraph is a no-op leg
    /// — it writes nothing and is not counted.
    func splitPickedAtNewlines() async {
        let pickedSet = picked.picked
        guard !pickedSet.isEmpty else { return }
        await autosave.flushNow()
        let order = rows.map(\.blockID)
        let chain = pickedSet.subtracting(order).sorted()
            + order.filter { pickedSet.contains($0) }
        statusMessage = nil
        do {
            let stack = session.undoStack
            let results: [Operations.SplitAtNewlinesResult] = try await session.runner
                .run { ops in
                    try stack.withCompound(label: "Split at Newlines", operations: ops) {
                        try chain.map { try ops.splitBlockAtNewlines($0) }
                    }
                }
            picked.clear()
            statusMessage = SplitAtNewlinesCopy.receipt(
                results, whenNothingSplit: SplitAtNewlinesCopy.pickedAlreadyWhole)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// Bulk tag — one existing tag to every picked block, already-tagged
    /// rows skipping quietly (the standing batch semantics).
    func tagPicked(_ tagID: String) async {
        let chain = pickedInOrder
        guard !chain.isEmpty else { return }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                for id in chain {
                    do {
                        _ = try ops.applyTag(tagID, toBlock: id)
                    } catch OperationError.alreadyTagged {}
                }
            }
            statusMessage = "Tagged \(chain.count) block\(chain.count == 1 ? "" : "s")."
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// Bulk move-out to a snippet group — the honest per-block `moveBlock`
    /// (I2: the blocks LEAVE this note), spoken with the road back.
    func movePickedToPool(_ poolID: String, poolTitle: String?) async {
        let chain = pickedInOrder
        guard !chain.isEmpty else { return }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                for id in chain { try ops.moveBlock(id, to: poolID, at: .end) }
            }
            picked.clear()
            let name = (poolTitle?.isEmpty == false) ? "\u{201C}\(poolTitle!)\u{201D}" : "Snippets"
            statusMessage = "Moved \(chain.count) block\(chain.count == 1 ? "" : "s") to \(name) — "
                + "they LEFT this note (takes went along). \u{2325}\u{2318}Z brings them back."
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        statusMessage = nil
        do {
            try await session.runner.run(body)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }
}

// (The old `BlockTOCView` VIEW — one row per block, raw source text, the
// lower half of the window empty — retired at pre-13u Act 10 wave 2c, her
// W8-1 ruling: its TOC idea GREW UP into `IndexModeView` (sections, the
// reading pane) and its management half into `BlocksWorkbenchView` (facts,
// multi-select, the context panel). EVERY door it carried survives in the
// workbench: expand-to-edit, ↑↓, the whole ⋯ menu — name · jump · move to
// top/bottom/# · move out to snippets · archive · delete — and the tray
// door. The model above serves all three faces.)
