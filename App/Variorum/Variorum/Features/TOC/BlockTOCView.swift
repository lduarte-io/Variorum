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

    func makeLive(_ blockID: String, variantID: String) {
        let key = PaneTextAuthority.PaneKey(
            columnID: "toc", blockID: blockID, variantID: variantID)
        switch authority.focus(key) {
        case .unchanged:
            return
        case .migrated:
            // The leaving pane's text lands as the ring migrates; the
            // buffer overlay keeps the just-blurred row current meanwhile.
            Task { await autosave.flushNow() }
        }
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

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        statusMessage = nil
        do {
            try await session.runner.run(body)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }
}

struct BlockTOCView: View {
    /// **THE ROW MENU'S DECLARED ACTS** (the post-13l polish round, ledger row
    /// 14 / F1). Blocks mode's per-row menu is a listing's menu, not a
    /// context menu and not a bar — a `.surface` door in the 13b 3D sense:
    /// the target is the row you opened it on. It has offered *"Delete
    /// block"* since 13c with no declaration anywhere; the pass that gave it
    /// the ARCHIVE twin her F1 rule asks for declares the pair.
    ///
    /// (Its other rows — move to top/bottom, move to ordinal, move out to a
    /// pool — are placement moves, which the round's own scope note excludes
    /// as ordinary reversible editing rather than past-creating acts. They
    /// stay undeclared, and that is now a recorded gap rather than an
    /// invisible one.)
    static let surfaceCapabilities: [CapabilityID] = [.archiveBlock, .deleteBlock]

    let session: AppSession
    let postID: String
    /// Jump-to-block: the container switches to the Write editor with this
    /// block's caret seed (the hybrid primitive fires there — never
    /// in-place folding here).
    var onJump: ((String) -> Void)?
    @State private var model: BlockTOCViewModel
    @State private var renameTarget: Queries.TOCRow?
    @State private var renameText = ""
    /// 13b 4D (N39): the typed-position prompt's target + entry.
    @State private var moveTarget: Queries.TOCRow?
    @State private var moveOrdinalText = ""
    /// 13j (round 7): the tray panel this mode's section now opens.
    @State private var trayShown = false

    init(
        session: AppSession, postID: String,
        onJump: ((String) -> Void)? = nil, model: BlockTOCViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.onJump = onJump
        _model = State(initialValue: model ?? BlockTOCViewModel(session: session, postID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // (Round-1 MINOR-2: the never-dismissing red caption is gone —
            // outcomes render in the shell's one StatusToast.)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(model.rows.enumerated()), id: \.element.placementID) { i, row in
                        tocRow(row, ordinal: i + 1)
                    }
                    if !model.tray.isEmpty {
                        traySection
                    }
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $trayShown) {
            TrayPanel(session: session, postID: postID)
        }
        .task { await model.start() }
        .task { await model.startTray() }
        .task { await model.startPools() }
        .onDisappear { model.teardown() }
        .alert(
            "Name this block",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { row in
            TextField("Name (blank clears)", text: $renameText)
            Button("Save") {
                let name = renameText
                Task { await model.rename(blockID: row.blockID, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        // 13b 4D (N39): "what number block you want it to be out of the
        // total post" — a typed position, clamped; non-numbers speak.
        .alert(
            "Move to block # (of \(model.rows.count))",
            isPresented: Binding(
                get: { moveTarget != nil },
                set: { if !$0 { moveTarget = nil } }),
            presenting: moveTarget
        ) { row in
            TextField("Position (1–\(model.rows.count))", text: $moveOrdinalText)
            Button("Move") {
                let raw = moveOrdinalText.trimmingCharacters(in: .whitespaces)
                Task {
                    if let target = Int(raw) {
                        await model.move(blockID: row.blockID, toOrdinal: target)
                    } else {
                        model.speak("\u{201C}\(raw)\u{201D} isn't a position number — type 1 to \(model.rows.count).")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func tocRow(_ row: Queries.TOCRow, ordinal: Int) -> some View {
        let isExpanded = model.expanded.contains(row.blockID)
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Button(isExpanded ? "▾" : "▸") { model.toggleExpanded(row.blockID) }
                    .buttonStyle(.plain)
                Text("\(ordinal)/\(model.rows.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.tertiary)
                // The handle: name else read-time first sentence (the
                // core derivation — one brain). Batch 7: body-size — the
                // TOC is a reading surface, not fine print.
                Text(Queries.tocHandle(name: row.name, text: row.text))
                    .font(row.name != nil ? .body.weight(.semibold) : .body)
                    .lineLimit(1)
                if row.hasFan {
                    Text("⑂").font(.caption).foregroundStyle(.blue)
                }
                if row.variantLocked {
                    Text("locked").font(.caption2).foregroundStyle(.orange)
                }
                Spacer()
                HStack(spacing: 2) {
                    Button("↑") { Task { await model.move(blockID: row.blockID, up: true) } }
                        .disabled(ordinal == 1)
                    Button("↓") { Task { await model.move(blockID: row.blockID, up: false) } }
                        .disabled(ordinal == model.rows.count)
                }
                .controlSize(.mini)
                Menu("⋯") {
                    Button("Name…") {
                        renameText = row.name ?? ""
                        renameTarget = row
                    }
                    Button("Jump to block") { onJump?(row.blockID) }
                    Divider()
                    // 13b 4D (N39): long-distance moves without dragging —
                    // top / bottom / a typed position number.
                    Button("Move to top") {
                        Task { await model.moveToTop(row.blockID) }
                    }
                    .disabled(ordinal == 1)
                    Button("Move to bottom") {
                        Task { await model.moveToBottom(row.blockID) }
                    }
                    .disabled(ordinal == model.rows.count)
                    Button("Move to block #…") {
                        moveOrdinalText = "\(ordinal)"
                        moveTarget = row
                    }
                    Divider()
                    // 13b 4D (N32(a)): the honest title — it MOVES the
                    // block out of this post (I2), never a copy.
                    Menu("Move out to a pool (leaves this note)") {
                        ForEach(model.pools, id: \.id) { pool in
                            Button(pool.title ?? "Untitled pool") {
                                Task {
                                    await model.moveToPool(
                                        row.blockID, poolID: pool.id,
                                        poolTitle: pool.title)
                                }
                            }
                        }
                    }
                    Divider()
                    // Ledger row 14 (F1): archive rides beside delete, and
                    // before it — the same order the menu bar's Block menu,
                    // the block context menu and both bars' `block ▾` use.
                    Button(CapabilityRegistry.capability(.archiveBlock).verb) {
                        Task { await model.archiveBlock(row.blockID) }
                    }
                    Button("Delete block", role: .destructive) {
                        Task { await model.deleteBlock(row.blockID) }
                    }
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .controlSize(.mini)
            }
            if isExpanded {
                // The read-cheap tier; ONE block upgrades live on click
                // (P3's split, reused). Text resolves through the
                // authority — a blurred row never flashes stale (13b 1a).
                if let variantID = row.variantID {
                    PaneSurfaceView(
                        text: model.displayText(variantID: variantID, storeText: row.text),
                        isLive: model.liveBlockID == row.blockID && !row.variantLocked,
                        role: "toc", variantID: variantID,
                        onFocusRequest: { model.makeLive(row.blockID, variantID: variantID) },
                        onEdit: { newText in
                            model.paneEdited(
                                variantID: variantID,
                                oldText: row.text ?? "", newText: newText)
                        })
                        .padding(.leading, 20)
                } else {
                    Text("· · ·").foregroundStyle(.secondary).padding(.leading, 20)
                }
            }
        }
    }

    /// **13j (her round-7 ruling): ONE panel, one truth.** This section used
    /// to render its own small deleted-blocks list — a second listing over
    /// the same query, which batch 2 left alone deliberately (two views over
    /// one query is the pointer religion, not duplication) and flagged for
    /// her. She ruled: *"routed to the one panel"*. So the section is now a
    /// DOOR: it says how many blocks are waiting and opens This Note's Tray,
    /// where the countdown, the archived rows and the preserved originals all
    /// live. Nothing here can drift from that panel, because there is nothing
    /// here to drift.
    private var traySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                // Ledger row 9: the ONE panel, wherever the door is — the
                // router opens the detail's inspector, and this mode's own
                // sheet is the fallback for a host with no inspector.
                let request = TrayRequest(postID: postID)
                if !session.commandRouter.requestNoteTray(request) {
                    trayShown = true
                }
            } label: {
                Text("\(TrayPath.menuLabel) — \(model.tray.count) deleted")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.link)
            .padding(.top, 12)
            .help("Opens this note's tray: what it has deleted (with how long "
                + "you have to put it back), what it has archived, and any "
                + "originals a divide or merge preserved")
        }
    }
}
