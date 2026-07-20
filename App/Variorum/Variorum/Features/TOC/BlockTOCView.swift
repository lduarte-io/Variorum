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
    private(set) var statusMessage: String?

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
            for try await value in session.database.observeTray(postID) {
                tray = value
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
    func adopt(tray: [Queries.TrayItem]) { self.tray = tray }

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

    func deleteBlock(_ blockID: String) async {
        await run { ops in try ops.deleteBlock(blockID) }
    }

    /// The tray's restore door (restoreBlock re-places at the end — the
    /// Phase 2 tray gesture).
    func restoreBlock(_ blockID: String) async {
        await run { ops in try ops.restoreBlock(blockID) }
    }

    func moveToPool(_ blockID: String, poolID: String) async {
        await run { ops in try ops.moveBlock(blockID, to: poolID, at: .end) }
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
    let session: AppSession
    let postID: String
    /// Jump-to-block: the container switches to the Write editor with this
    /// block's caret seed (the hybrid primitive fires there — never
    /// in-place folding here).
    var onJump: ((String) -> Void)?
    @State private var model: BlockTOCViewModel
    @State private var renameTarget: Queries.TOCRow?
    @State private var renameText = ""

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
            if let status = model.statusMessage {
                Text(status).font(.caption).foregroundStyle(.red).padding(.horizontal, 12)
            }
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
                    Menu("Move to pool") {
                        ForEach(model.pools, id: \.id) { pool in
                            Button(pool.title ?? "Untitled pool") {
                                Task { await model.moveToPool(row.blockID, poolID: pool.id) }
                            }
                        }
                    }
                    Divider()
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

    private var traySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Deleted blocks (the tray)")
                .font(.caption.weight(.semibold))
                .padding(.top, 12)
            ForEach(model.tray, id: \.blockID) { item in
                HStack(spacing: 6) {
                    Text((item.text?.isEmpty == false)
                         ? String(item.text!.prefix(80))
                         : "(empty block)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Button("Restore") {
                        Task { await model.restoreBlock(item.blockID) }
                    }
                    .controlSize(.mini)
                }
            }
        }
    }
}
