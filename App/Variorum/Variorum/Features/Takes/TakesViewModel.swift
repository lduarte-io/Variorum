//
//  TakesViewModel.swift
//  Variorum
//
//  Phase 11, Step A3 — the takes/lens board's conductor for ONE post. The
//  spike record is binding: columns are selection profiles (main / scratch
//  / named lens); a lens is NEVER rendering truth — ✓ (`chooseVariant`) and
//  ADOPT are the only lens→chosen doors; visible-not-chosen takes are real
//  and editable (edits land in that take's working_text, durable, synced);
//  the ONE live editor migrates between panes on click (P3 unchanged);
//  scratch arrangements persist via VIEW MEMORY (local, automatic); named
//  lenses are synced and LIVE-edited; fan expansion is session-only.
//
//  No business rules live here: every gesture is an Operations call; the
//  projections come from Queries.takesProjection.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class TakesViewModel {
    @ObservationIgnored let session: AppSession
    let postID: String
    @ObservationIgnored private let defaults: UserDefaults
    /// Internal so the handoff tests can await deterministic flushes.
    @ObservationIgnored let autosave: AutosaveCoordinator

    init(session: AppSession, postID: String, defaults: UserDefaults = .standard) {
        self.session = session
        self.postID = postID
        self.defaults = defaults
        self.autosave = AutosaveCoordinator(runner: session.runner)
        if let memory = TakesViewMemory.load(postID: postID, defaults: defaults) {
            columns = memory.columns
            alignmentLocked = memory.alignmentLocked
        } else {
            columns = [TakesColumn(kind: .main)]
            alignmentLocked = true
        }
        autosave.onError = { [weak self] error in
            self?.statusMessage = Self.message(for: error)
        }
        autosave.onSettled = { [weak self] in
            guard let self, !self.autosave.isDirty, let deferred = self.deferredProjection else { return }
            self.deferredProjection = nil
            self.adopt(deferred)
        }
        // The quit door awaits this surface's debounced buffers too
        // (review round 1, MINOR 2 — the Phase 10 quit-door class).
        quitToken = session.quitFinalize.register { [weak autosave = self.autosave] in
            await autosave?.flushNow()
        }
    }

    @ObservationIgnored private var quitToken: UUID?

    // MARK: - Observable state

    private(set) var projection = Queries.TakesProjection()
    private(set) var columns: [TakesColumn]
    var alignmentLocked: Bool {
        didSet { saveMemory() }
    }
    /// The ONE live pane (P3: the live editor migrates on click; everything
    /// else renders read-cheap).
    private(set) var focusedPane: PaneKey?
    /// Fanned blocks currently bloomed — SESSION-ONLY by the plan's letter
    /// (fans stay open once expanded; close-all resets; nothing persists).
    private(set) var expandedBlocks: Set<String> = []
    private(set) var statusMessage: String?

    struct PaneKey: Equatable, Hashable {
        var columnID: String
        var blockID: String
        /// The specific take the pane shows (a bloomed fan shows several
        /// panes per block).
        var variantID: String
    }

    // MARK: - Internals

    @ObservationIgnored private var deferredProjection: Queries.TakesProjection?
    /// Per-variant buffer while a pane is live and unsettled — the
    /// buffer-authoritative rule in miniature (the editor's discipline).
    @ObservationIgnored private(set) var liveBuffers: [String: String] = [:]

    // MARK: - Lifecycle

    func start() async {
        do {
            for try await value in session.database.observeTakes(postID) {
                if autosave.isDirty {
                    deferredProjection = value  // adopt at settle
                } else {
                    adopt(value)
                }
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Takes observation failed: \(error)"
        }
    }

    /// Internal so tests drive projections deterministically (the test host
    /// never fires `.task`).
    func adopt(_ new: Queries.TakesProjection) {
        projection = new
        // THE CONVERGENCE HALF of the buffer-authoritative discipline
        // (review round 2, MAJOR): adoption only runs clean or at settle
        // (the observation loop defers while dirty), so any buffer with NO
        // pending autosave record has fully landed — the projection is the
        // truth and the buffer must clear, or external edits (a phone edit
        // via sync, an engine repair, a sibling surface) would never reach
        // the display and resumed typing would clobber them with no
        // conflict variant. Entries still pending stay authoritative (the
        // dirty half). Accepted residual, recorded: a stale pre-flush
        // emission racing settle can flicker one observation cycle before
        // the post-commit emission converges it.
        for variantID in liveBuffers.keys where autosave.pending[variantID] == nil {
            projectionCaughtUp(variantID: variantID)
        }
        // Columns referencing lenses that died drop back to scratch with
        // the lens's last-known picks LOST deliberately (the lens was the
        // durable home; a deleted lens's thread is gone — its takes remain
        // in the fans).
        var changed = false
        for index in columns.indices {
            if case .lens(let lensID) = columns[index].kind,
               !new.lenses.contains(where: { $0.id == lensID }) {
                columns[index].kind = .scratch
                changed = true
            }
        }
        if changed { saveMemory() }
    }

    func teardown() {
        if let quitToken {
            session.quitFinalize.unregister(quitToken)
            self.quitToken = nil
        }
        Task { await autosave.flushNow() }
    }

    // MARK: - Resolution (visible ≠ chosen)

    /// What a column shows for a slot: the column's pick where one exists
    /// and is still a live ACTIVE take of the block, else the slot's
    /// ordinary chosen resolution (sparse overrides — the fall-through
    /// class everywhere).
    func resolvedTake(column: TakesColumn, slot: Queries.RenderedBlock) -> (variantID: String, text: String)? {
        let pick: String?
        switch column.kind {
        case .main:
            pick = nil
        case .scratch:
            pick = column.picks[slot.blockID]
        case .lens(let lensID):
            pick = projection.lensSelections[lensID]?[slot.blockID]
        }
        if let pick,
           let take = projection.fans[slot.blockID]?.first(where: { $0.id == pick }) {
            return (take.id, liveBuffers[take.id] ?? take.workingText)
        }
        guard let variantID = slot.variantID else { return nil }  // gap
        return (variantID, liveBuffers[variantID] ?? (slot.text ?? ""))
    }

    /// One row's displayed texts across the columns (the sameness input).
    func rowTexts(slot: Queries.RenderedBlock) -> [String?] {
        columns.map { resolvedTake(column: $0, slot: slot)?.text }
    }

    // MARK: - Focus (the ONE live editor migrates)

    func focus(_ pane: PaneKey) {
        guard focusedPane != pane else { return }
        // The leaving pane's text lands before the arriving pane goes live
        // (the handoff contract in miniature — flush, then migrate).
        let leaving = focusedPane
        focusedPane = pane
        if leaving != nil {
            Task { await autosave.flushNow() }
        }
    }

    func blur() {
        focusedPane = nil
        Task { await autosave.flushNow() }
    }

    /// A live pane's keystroke: the buffer is authoritative while dirty;
    /// the edit lands in exactly THAT take's working_text (visible-not-
    /// chosen is real and editable — durable, synced).
    func paneEdited(variantID: String, newText: String) {
        let old = liveBuffers[variantID]
            ?? currentStoreText(variantID: variantID)
            ?? ""
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        liveBuffers[variantID] = newText
        autosave.record(variantID: variantID, text: newText, charDelta: cost)
    }

    private func currentStoreText(variantID: String) -> String? {
        for (_, fan) in projection.fans {
            if let take = fan.first(where: { $0.id == variantID }) {
                return take.workingText
            }
        }
        return projection.slots.first { $0.variantID == variantID }?.text
    }

    /// Settled buffers converge back to the store's text — called by
    /// `adopt` for every entry with no pending autosave record (round 2
    /// MAJOR: the seam existed unwired; the display could go permanently
    /// stale and clobber newer store text on resumed typing).
    func projectionCaughtUp(variantID: String) {
        liveBuffers.removeValue(forKey: variantID)
    }

    // MARK: - Columns

    func addScratchColumn() {
        guard columns.count < 4 else { return }
        // The transparent lens is the default for new threads (the LAZY
        // ruling): a fresh column starts as an empty overlay; takes mint
        // only on divergence.
        columns.append(TakesColumn(kind: .scratch))
        saveMemory()
    }

    func addLensColumn(_ lensID: String) {
        guard columns.count < 4 else { return }
        columns.append(TakesColumn(kind: .lens(lensID)))
        saveMemory()
    }

    func removeColumn(_ columnID: String) {
        guard columns.count > 1 else { return }
        columns.removeAll { $0.id == columnID }
        saveMemory()
    }

    private func saveMemory() {
        TakesViewMemory(columns: columns, alignmentLocked: alignmentLocked)
            .save(postID: postID, defaults: defaults)
    }

    // MARK: - Expansion (session-only)

    func toggleExpanded(_ blockID: String) {
        if expandedBlocks.contains(blockID) {
            expandedBlocks.remove(blockID)
        } else {
            expandedBlocks.insert(blockID)
        }
    }

    /// Expand-all-fans (AppSpec §12): every FANNED block blooms, in the set
    /// style; fans stay open once expanded; close-all resets.
    func expandAllFans() {
        expandedBlocks = Set(projection.slots.filter(\.hasFan).map(\.blockID))
    }

    func closeAllFans() {
        expandedBlocks = []
    }

    // MARK: - Gestures (every one an Operations call)

    /// ✓ — the explicit chooseVariant (I3's setter; the ONE per-slot door
    /// from visible to chosen).
    func choose(blockID: String, variantID: String) async {
        await run { ops in
            try ops.chooseVariant(blockID, variantID: variantID)
        }
    }

    /// A scratch/lens column adopts a different take for one slot (a VIEW
    /// change — never touches chosen).
    func pick(columnID: String, blockID: String, variantID: String) async {
        guard let index = columns.firstIndex(where: { $0.id == columnID }) else { return }
        switch columns[index].kind {
        case .main:
            statusMessage = "The main column shows the post's chosen takes — use ✓ to change them."
        case .scratch:
            columns[index].picks[blockID] = variantID
            saveMemory()
        case .lens(let lensID):
            // Named lenses are LIVE-edited (no explicit re-save).
            await run { ops in
                _ = try ops.setLensChoice(lens: lensID, block: blockID, variant: variantID)
            }
        }
    }

    /// DIVERGE HERE: edit-as-this-thread — mints a take branched from what
    /// the pane shows; the column adopts it (visible, not chosen). One
    /// operations body for the store half; the column's own state updates
    /// after it lands.
    func divergeHere(columnID: String, blockID: String, fromVariantID: String) async {
        guard let index = columns.firstIndex(where: { $0.id == columnID }) else { return }
        let kind = columns[index].kind
        statusMessage = nil
        do {
            let take: Variant = try await session.runner.run { ops in
                let take = try ops.branchVariant(blockID, from: fromVariantID)
                if case .lens(let lensID) = kind {
                    // Named lenses are LIVE-edited: the thread's pick
                    // moves in the same breath.
                    _ = try ops.setLensChoice(lens: lensID, block: blockID, variant: take.id)
                }
                return take
            }
            guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
            switch kind {
            case .main:
                // Diverging the main column starts a scratch thread —
                // chosen never moves without ✓.
                columns[i].kind = .scratch
                columns[i].picks[blockID] = take.id
                saveMemory()
            case .scratch:
                columns[i].picks[blockID] = take.id
                saveMemory()
            case .lens:
                break  // the store carries it; the projection follows
            }
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    /// 💾 — a scratch column becomes a durable NAMED lens (deliberate; no
    /// auto-minted lenses).
    @discardableResult
    func saveScratchAsLens(columnID: String, name: String) async -> Lens? {
        guard let index = columns.firstIndex(where: { $0.id == columnID }),
              case .scratch = columns[index].kind
        else { return nil }
        let picks = columns[index].picks
        statusMessage = nil
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                let lens = try ops.createLens(post: postID, name: name)
                for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                    _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            if let i = columns.firstIndex(where: { $0.id == columnID }) {
                columns[i].kind = .lens(lens.id)
                columns[i].picks = [:]
                saveMemory()
            }
            return lens
        } catch {
            statusMessage = Self.message(for: error)
            return nil
        }
    }

    /// ADOPT LENS: every pick → chosen, one compound (the other lens→chosen
    /// door).
    func adoptLens(_ lensID: String) async {
        await run { ops in
            try ops.adoptLens(lensID)
        }
    }

    /// ⧉ per column: a lens column promotes (chosen := its picks; fans ride
    /// by default, chosen-only offered); the main column duplicates (the
    /// post exactly as it is). Scratch columns save-as-lens first (💾) —
    /// the shipped shape, recorded in the closeout.
    func promoteColumn(_ columnID: String, carryFans: Bool = true) async {
        guard let column = columns.first(where: { $0.id == columnID }) else { return }
        switch column.kind {
        case .main:
            await duplicateAsVersion()
        case .lens(let lensID):
            await run { ops in _ = try ops.promoteLens(lensID, carryFans: carryFans) }
        case .scratch:
            statusMessage = "Save this column as a lens first (💾) — promoting materializes a lens."
        }
    }

    func duplicateAsVersion() async {
        await run { [postID] ops in _ = try ops.duplicateAsVersion(postID) }
    }

    /// BRANCH-ALL-FANS: the eager thread (explicit command; new columns
    /// default to the transparent scratch instead).
    func branchAllFans(lensName: String) async {
        statusMessage = nil
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                try ops.branchAllFans(post: postID, lensName: lensName)
            }
            addLensColumn(lens.id)
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    func deleteLens(_ lensID: String) async {
        await run { ops in try ops.deleteLens(lensID) }
    }

    func renameLens(_ lensID: String, to name: String) async {
        await run { ops in try ops.renameLens(lensID, newName: name) }
    }

    func duplicateLens(_ lensID: String) async {
        await run { ops in _ = try ops.duplicateLens(lensID) }
    }

    func setFanStyle(_ style: FanStyle) async {
        await run { ops in try ops.setFanStyle(style) }
    }

    // MARK: - Plumbing

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        statusMessage = nil
        do {
            try await session.runner.run(body)
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    static func message(for error: Error) -> String {
        if let error = error as? OperationError {
            switch error {
            case .lockedPost:
                return "This post is sealed — unseal it to change takes or choices."
            case .archivedVariant:
                return "That take is archived — unarchive it first."
            case .lockedVariant:
                return "That take is locked — unlock it or branch a new take."
            default:
                return "Refused: \(error)"
            }
        }
        return String(describing: error)
    }
}
