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
        // 13b 1a (N3): the ONE per-post coordinator (shared with the Write
        // editor and the TOC on the same post). The quit door covers it at
        // the session scope — this surface no longer registers itself.
        self.autosave = session.autosave(forPost: postID)
        if let memory = TakesViewMemory.load(postID: postID, defaults: defaults) {
            columns = memory.columns
            alignmentLocked = memory.alignmentLocked
        } else {
            columns = [TakesColumn(kind: .main)]
            alignmentLocked = true
        }
        autosaveToken = autosave.observe(
            onError: { [weak self] error in
                self?.statusMessage = Self.message(for: error)
            },
            onSettled: { [weak self] in
                guard let self, !self.autosave.isDirty,
                      let deferred = self.deferredProjection else { return }
                self.deferredProjection = nil
                self.adopt(deferred)
            })
    }

    @ObservationIgnored private var autosaveToken: UUID?

    // MARK: - Observable state

    private(set) var projection = Queries.TakesProjection()
    private(set) var columns: [TakesColumn]
    var alignmentLocked: Bool {
        didSet { saveMemory() }
    }
    /// The ONE live pane (P3: the live editor migrates on click; everything
    /// else renders read-cheap) — the authority's, forwarded.
    var focusedPane: PaneKey? { authority.livePane }
    /// Fanned blocks currently bloomed — SESSION-ONLY by the plan's letter
    /// (fans stay open once expanded; close-all resets; nothing persists).
    private(set) var expandedBlocks: Set<String> = []
    /// The board's transient outcome line. PRESENTATION is the shell's
    /// StatusCenter (AD-14 — one placement, one auto-dismiss policy); the
    /// property remains the tested truth and forwards on set.
    private(set) var statusMessage: String? {
        didSet {
            if let statusMessage { session.status.speak(statusMessage) }
        }
    }

    // MARK: - Word counts (Stage 1 ladder MINOR-5 — P-8 binds P1 here)

    /// The post total over the projection's rendered slot texts — CACHED,
    /// recomputed per PROJECTION (settle cadence), never per bar render.
    /// The bar used to reduce `TextMetrics.wordCount` over EVERY slot each
    /// render, and it re-renders per keystroke (it reads the observed
    /// authority) — O(post length) per keystroke, the class the Write
    /// editor's ledger exists to prevent.
    private(set) var postWordCount = 0
    /// Per-slot counts from the LAST adoption — only slots whose text
    /// actually changed re-enumerate (the `EditorSurfaceLedger.adopt`
    /// discipline, mirrored). Counts are derived values, allowed in state;
    /// change detection diffs against the OLD projection still in hand at
    /// adoption time — no second copy of any slot's text is retained
    /// (round-2 NIT-R2-2).
    @ObservationIgnored private var slotCounts: [String: Int] = [:]
    /// Test seam: how many slots have been genuinely re-counted (the
    /// MINOR-5 pin asserts adoption is incremental, not recount-all).
    @ObservationIgnored private(set) var slotRecountCount = 0

    /// Called with the OUTGOING projection before `projection` is
    /// overwritten (the old slot texts are the last adoption's texts by
    /// construction — `adopt` is the only projection door).
    private func refreshWordCounts(old: Queries.TakesProjection, new: Queries.TakesProjection) {
        var oldTexts: [String: String] = [:]
        oldTexts.reserveCapacity(old.slots.count)
        for slot in old.slots {
            oldTexts[slot.blockID] = slot.text ?? ""
        }
        var counts: [String: Int] = [:]
        counts.reserveCapacity(new.slots.count)
        var total = 0
        for slot in new.slots {
            let text = slot.text ?? ""
            let count: Int
            if oldTexts[slot.blockID] == text,
               let cached = slotCounts[slot.blockID] {
                count = cached
            } else {
                count = TextMetrics.wordCount(text)
                slotRecountCount += 1
            }
            counts[slot.blockID] = count
            total += count
        }
        slotCounts = counts
        if postWordCount != total { postWordCount = total }
    }

    // MARK: - Follow-the-scroll (Phase 13 C2, R25)

    /// R25 — follow-the-scroll as a takes-viewing OPTION in all modes.
    /// Pushed by the View from the theme settings (models never read
    /// environments — the EditorView appearance pattern).
    var followTheScroll = false
    /// Near-viewport row bookkeeping: per-block REF COUNTS, because the
    /// multi-column compositions repeat a block's row — a disappear in one
    /// column must not blind the others. Observed (not ignored) so blooms
    /// re-render as rows come and go; when `followTheScroll` is off,
    /// `isBloomed` short-circuits before reading it, so Observation never
    /// tracks the churn (the calm default costs nothing).
    private var rowVisibility: [String: Int] = [:]

    /// The visible FANNED blocks (R25's set — derived from the counts
    /// against the current projection, so a fan born mid-visibility is
    /// picked up without a re-appear).
    var visibleFannedBlocks: Set<String> {
        Set(projection.slots
            .filter { $0.hasFan && (rowVisibility[$0.blockID] ?? 0) > 0 }
            .map(\.blockID))
    }

    func rowAppeared(_ blockID: String) {
        rowVisibility[blockID, default: 0] += 1
    }

    func rowDisappeared(_ blockID: String) {
        let next = (rowVisibility[blockID] ?? 0) - 1
        if next <= 0 {
            rowVisibility.removeValue(forKey: blockID)
        } else {
            rowVisibility[blockID] = next
        }
    }

    /// THE bloom rule (R25): explicitly expanded, OR — with follow-the-
    /// scroll on — any fanned row near the viewport.
    func isBloomed(_ slot: Queries.RenderedBlock) -> Bool {
        expandedBlocks.contains(slot.blockID)
            || (followTheScroll && slot.hasFan
                && (rowVisibility[slot.blockID] ?? 0) > 0)
    }

    /// Expand-all only where it MEANS something (R25's agreed half): the
    /// article that isn't slot-split (slot split IS a whole-post fan
    /// presentation already). Columns no longer figure in — they live in
    /// the LENSES tab now (Sitting 9, R86: the entanglement is dead).
    var offersExpandAll: Bool {
        projection.fanStyle != .slotSplit
    }

    /// R24's short/long rule for the margin grid: a SHORT fanned block gets
    /// the one-card-high horizontally-scrolling strip; longer blocks keep
    /// the vertical card column. The threshold is a character count (~200
    /// chars ≈ under three lines at the 68ch measure) — a BUILD-TIME CALL,
    /// recorded in the Stage C closeout + QUESTIONS #28.
    nonisolated static func usesHorizontalStrip(text: String?) -> Bool {
        (text ?? "").count < 200
    }

    /// The pane family's key type — the authority's (13b Stage 1a: the
    /// alias keeps every call site and pin naming unchanged).
    typealias PaneKey = PaneTextAuthority.PaneKey

    // MARK: - Internals

    @ObservationIgnored private var deferredProjection: Queries.TakesProjection?
    /// THE pane-text/liveness authority (13b Stage 1a, P-3): live pane +
    /// per-variant buffers + resolution live here as one tested value.
    /// OBSERVED as a stored property (batch 14 — the frozen-article root
    /// cause): `resolvedTake` feeds every read pane through the authority,
    /// so a keystroke in the live pane invalidates the rows that mirror it.
    /// Invalidation cost is bounded by the REALIZED rows (LazyVStack, P3);
    /// the live pane itself stays buffer-authoritative behind the `!isLive`
    /// adopt guard.
    private(set) var authority = PaneTextAuthority()

    /// The buffer overlay, forwarded (pins and cells read it).
    var liveBuffers: [String: String] { authority.buffers }

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
        refreshWordCounts(old: projection, new: new)
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
        authority.settle(isPending: { autosave.pending[$0] != nil })
        // Columns referencing lenses that died drop back to scratch with
        // the lens's last-known picks LOST deliberately (the lens was the
        // durable home; a deleted lens's thread is gone — its takes remain
        // in the fans).
        var changed = false
        for index in columns.indices {
            if case .lens(let lensID) = columns[index].kind,
               !new.lenses.contains(where: { $0.id == lensID }) {
                columns[index].kind = .scratch
                if columns[index].name == nil { columns[index].name = nextAutoName() }
                changed = true
            }
        }
        if changed { saveMemory() }
        // 13b 1b: programmatic landings (add-block focus, cross-mode
        // blooms, the N9 "just start typing" ring) resolve against the
        // fresh slots.
        consumeLandings(new)
    }

    func teardown() {
        if let autosaveToken {
            autosave.stopObserving(autosaveToken)
            self.autosaveToken = nil
        }
        Task { await autosave.flushNow() }
    }

    // MARK: - Resolution (visible ≠ chosen)

    /// What a column shows for a slot: the column's pick where one exists
    /// and is still a live ACTIVE take of the block, else the slot's
    /// ordinary chosen resolution (sparse overrides — the fall-through
    /// class everywhere). The fall-through + buffer overlay live in the
    /// AUTHORITY (13b P-3); this maps the column kind to its pick.
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
        return authority.resolvedText(
            pick: pick, slot: slot, fan: projection.fans[slot.blockID])
    }

    /// A take's displayed text anywhere it renders raw (fan cards, the
    /// stack style, the Write panel): the authority's overlay — a read
    /// pane mirroring a dirty variant never shows staler text than the
    /// buffer (the frozen-article class, closed for EVERY card path —
    /// the stack style's `take.workingText` bypass was the last live one).
    func liveText(_ take: Variant) -> String {
        authority.text(variantID: take.id, storeText: take.workingText)
    }

    /// One row's displayed texts across the columns (the sameness input).
    func rowTexts(slot: Queries.RenderedBlock) -> [String?] {
        columns.map { resolvedTake(column: $0, slot: slot)?.text }
    }

    // MARK: - Focus (the ONE live editor migrates)

    func focus(_ pane: PaneKey) {
        switch authority.focus(pane) {
        case .unchanged:
            return
        case .migrated(let leaving):
            // The leaving pane's text lands as the ring migrates (the
            // handoff contract in miniature — safety rides the buffers +
            // the `!isLive` adopt guard; the flush converges the store).
            if leaving != nil {
                Task { await autosave.flushNow() }
            }
        }
    }

    func blur() {
        authority.blur()
        Task { await autosave.flushNow() }
    }

    /// A live pane's keystroke: the buffer is authoritative while dirty;
    /// the edit lands in exactly THAT take's working_text (visible-not-
    /// chosen is real and editable — durable, synced).
    func paneEdited(variantID: String, newText: String) {
        let old = authority.text(
            variantID: variantID,
            storeText: currentStoreText(variantID: variantID) ?? "")
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        authority.bufferEdited(variantID: variantID, text: newText)
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

    /// Settled buffers converge back to the store's text (round 2 MAJOR:
    /// the seam existed unwired; the display could go permanently stale
    /// and clobber newer store text on resumed typing). The rule lives in
    /// the authority now; this forwards for the callers/pins that name it.
    func projectionCaughtUp(variantID: String) {
        authority.catchUp(variantID: variantID)
    }

    // MARK: - Columns (the Lenses tab's slots — Sitting 9, R80/R83)

    /// The next free "Lens n" auto-name among the current columns (R83:
    /// unnamed lenses are named too, so slots can be told apart and
    /// replaced deliberately).
    private func nextAutoName() -> String {
        let taken = Set(columns.compactMap(\.name))
        var n = 1
        while taken.contains("Lens \(n)") { n += 1 }
        return "Lens \(n)"
    }

    /// "+ Column → arrange existing takes" (R81's language): a fresh
    /// unnamed lens mirroring chosen; flip blocks to takes that already
    /// exist. Mints nothing.
    func addScratchColumn() {
        guard columns.count < 4 else { return }
        columns.append(TakesColumn(kind: .scratch, name: nextAutoName()))
        saveMemory()
    }

    /// "+ Column → write new takes" (R81/R82): a fresh take on EVERY
    /// renderable block (branched from what the post shows), opened as an
    /// unnamed column whose picks are exactly the minted takes.
    func addWriteColumn() async {
        guard columns.count < 4 else { return }
        statusMessage = nil
        do {
            let picks: [String: String] = try await session.runner.run { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            guard columns.count < 4 else { return }
            columns.append(TakesColumn(kind: .scratch, picks: picks, name: nextAutoName()))
            saveMemory()
        } catch {
            statusMessage = Self.message(for: error)
        }
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

    // MARK: - Column slot swapping (R83: any column replaceable in place)

    func replaceColumnWithChosen(_ columnID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        columns[i] = TakesColumn(id: columnID, kind: .main)
        saveMemory()
    }

    func replaceColumnWithLens(_ columnID: String, lensID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        columns[i] = TakesColumn(id: columnID, kind: .lens(lensID))
        saveMemory()
    }

    func replaceColumnWithNewScratch(_ columnID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        columns[i] = TakesColumn(id: columnID, kind: .scratch, name: nextAutoName())
        saveMemory()
    }

    func replaceColumnWithNewWrite(_ columnID: String) async {
        guard columns.contains(where: { $0.id == columnID }) else { return }
        statusMessage = nil
        do {
            let picks: [String: String] = try await session.runner.run { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
            columns[i] = TakesColumn(
                id: columnID, kind: .scratch, picks: picks, name: nextAutoName())
            saveMemory()
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    private func saveMemory() {
        TakesViewMemory(columns: columns, alignmentLocked: alignmentLocked)
            .save(postID: postID, defaults: defaults)
    }

    // MARK: - Discrete paging (session-only; model-owned)

    /// Per-key page offsets for the card rows (carousel, slot split, and —
    /// AD-2's fix — the margin rail): whole cards/columns, never halfway,
    /// an EXPLICIT ◀ ▶ door instead of an invisible horizontal scroll.
    /// Model-owned (13b 1a) so the AD-2 pin and the board soak can drive
    /// page coverage; session-only like expansion.
    private(set) var pageOffsets: [String: Int] = [:]

    /// The clamped current offset for a key (limit = last legal offset).
    func pageOffset(_ key: String, limit: Int) -> Int {
        min(max(pageOffsets[key] ?? 0, 0), max(limit, 0))
    }

    func stepPage(_ key: String, by delta: Int, limit: Int) {
        pageOffsets[key] = min(max(pageOffset(key, limit: limit) + delta, 0), max(limit, 0))
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
                if columns[i].name == nil { columns[i].name = nextAutoName() }
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

    /// "✓ Make this the post" — the R89 obvious door on every non-Chosen
    /// column. ADOPTING SWAPS, NEVER DESTROYS (R92): the outgoing chosen is
    /// auto-preserved as a lens ("chosen until <date>", suffixed on
    /// collision) in the same transaction; the toast names it so the way
    /// back is visible.
    func adoptColumn(_ columnID: String) async {
        guard let column = columns.first(where: { $0.id == columnID }) else { return }
        statusMessage = nil
        do {
            let preservation: Lens
            switch column.kind {
            case .main:
                statusMessage = "This column IS the post — nothing to adopt."
                return
            case .lens(let lensID):
                preservation = try await session.runner.run { ops in
                    try ops.adoptLensPreservingChosen(lensID)
                }
            case .scratch:
                let picks = column.picks
                preservation = try await session.runner.run { [postID] ops in
                    try ops.adoptPicksPreservingChosen(post: postID, picks: picks)
                }
            }
            statusMessage =
                "Adopted — the post now shows this column. The old chosen is kept as the lens “\(preservation.name)”."
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    /// ⧉ "Make this a post" per column: a lens column promotes; a SCRATCH
    /// column promotes DIRECTLY from its picks (R78 — the forced
    /// save-as-lens step is retired; `keepAsLens` optionally saves the way
    /// of looking too); the main column duplicates (the post exactly as it
    /// is). Fans ride by default, chosen-only offered at the gesture.
    func promoteColumn(_ columnID: String, carryFans: Bool = true, keepAsLens: Bool = false) async {
        guard let column = columns.first(where: { $0.id == columnID }) else { return }
        statusMessage = nil
        switch column.kind {
        case .main:
            await duplicateAsVersion()
        case .lens(let lensID):
            await run { ops in _ = try ops.promoteLens(lensID, carryFans: carryFans) }
        case .scratch:
            let picks = column.picks
            let lensName = column.name ?? "Lens"
            do {
                let promoted: Operations.PostCopyResult = try await session.runner.run { [postID] ops in
                    let result = try ops.promotePicks(
                        post: postID, picks: picks, carryFans: carryFans)
                    if keepAsLens {
                        let lens = try ops.createLens(post: postID, name: lensName)
                        for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                            _ = try ops.setLensChoice(
                                lens: lens.id, block: blockID, variant: variantID)
                        }
                    }
                    return result
                }
                statusMessage =
                    "Made a new post — “\(promoted.post.title ?? "untitled")” is now its own post, linked as a version."
            } catch {
                statusMessage = Self.message(for: error)
            }
        }
    }

    func duplicateAsVersion() async {
        await run { [postID] ops in _ = try ops.duplicateAsVersion(postID) }
    }

    /// "Write new takes on every block" from the TAKES tab (R82: the door
    /// lives in both tabs): mints the takes into each block's fan — no
    /// column, no lens — and says what happened.
    func writeNewTakesEverywhere() async {
        statusMessage = nil
        do {
            let picks: [String: String] = try await session.runner.run { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            statusMessage =
                "New takes written on \(picks.count) block\(picks.count == 1 ? "" : "s") — open any fan to see them, or open them side by side in Lenses."
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    /// "Save current choices as a lens…" (the Takes tab's elevate door —
    /// Sitting 9's "you should always … be able to elevate what you have to
    /// being a lens"): a lens whose EXPLICIT pick on every renderable slot
    /// is what the post currently shows.
    func saveCurrentChoicesAsLens(name: String) async {
        let shown: [(String, String)] = projection.slots.compactMap { slot in
            slot.variantID.map { (slot.blockID, $0) }
        }
        statusMessage = nil
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                let lens = try ops.createLens(post: postID, name: name)
                for (blockID, variantID) in shown {
                    _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            statusMessage = "Saved — “\(lens.name)” now remembers these choices."
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

    // MARK: - The fan-growth doors (Phase 13 C2 — v2's dashed footer)

    /// "＋ new take (branch)" — the default gesture: inherits the shown
    /// take's text (OverallModel §3's letter). Awaited through the runner
    /// (never fire-and-forget); a sealed post's refusal speaks. Returns the
    /// minted take so the calling surface can move the ring onto it
    /// (Sitting 9: "it just feels a little bit clunky" — you're typing in
    /// the new take instantly, chosen untouched).
    @discardableResult
    func branchTake(blockID: String, from variantID: String) async -> Variant? {
        statusMessage = nil
        do {
            return try await session.runner.run { ops in
                try ops.branchVariant(blockID, from: variantID)
            }
        } catch {
            statusMessage = Self.message(for: error)
            return nil
        }
    }

    /// "＋ blank take" — the genuinely-different-take gesture. Minting
    /// NEVER chooses (R90: "as you go through and fill items in, it can be
    /// selected"); the new card gets the ring so you're typing instantly.
    @discardableResult
    func newBlankTake(blockID: String) async -> Variant? {
        statusMessage = nil
        do {
            return try await session.runner.run { ops in
                try ops.newBlankVariant(blockID)
            }
        } catch {
            statusMessage = Self.message(for: error)
            return nil
        }
    }

    // MARK: - Take lifecycle (the retired FanPanel's doors, kept — R87:
    // one grammar everywhere, refusals speak)

    func archiveTake(_ variantID: String) async {
        await run { ops in try ops.archiveVariant(variantID) }
    }

    func unarchiveTake(_ variantID: String) async {
        await run { ops in try ops.unarchiveVariant(variantID) }
    }

    func setTakeLocked(_ variantID: String, locked: Bool) async {
        await run { ops in
            if locked {
                try ops.lockVariant(variantID)
            } else {
                try ops.unlockVariant(variantID)
            }
        }
    }

    func deleteTake(_ variantID: String) async {
        await run { ops in try ops.deleteVariant(variantID) }
    }

    // MARK: - Post-level doors (R63: the bottom bar's options ride along)

    /// Commit the FOCUSED take's buffer (⌘S in takes surfaces).
    func commitFocusedTake() async {
        guard let variantID = focusedPane?.variantID else {
            statusMessage = "Click into a take first — ⌘S commits the take you're in."
            return
        }
        await autosave.flushNow()
        await run { ops in _ = try ops.commit(variantID) }
        if statusMessage == nil { statusMessage = "Committed — an immutable savepoint of this take." }
    }

    func toggleSeal() async {
        let sealed = projection.sealed
        await run { [postID] ops in
            if sealed {
                try ops.unlockPost(postID)
            } else {
                try ops.lockPost(postID)
            }
        }
    }

    func updateEntryDate(_ day: String?) async {
        await run { [postID] ops in try ops.setEntryDate(postID, entryDate: day) }
    }

    /// R84's note condition: the daily-journal SHAPE (profile journal +
    /// entry date) is exactly what the Fragments bridge sweeps.
    var isJournalShaped: Bool {
        projection.profile == .journal && projection.entryDate != nil
    }

    /// The bar's speaking surface (9d fire-and-speak — a message, never a
    /// dead key).
    func speak(_ message: String) {
        statusMessage = message
    }

    // MARK: - Fire-and-DO (13b 1b, R115/R118 — the D3 lecture's replacement)

    /// The block a routed command acts on: the pane you're in; on a
    /// one-block post, THE block (no click should be needed).
    var commandTargetSlot: Queries.RenderedBlock? {
        if let pane = focusedPane {
            return projection.slots.first { $0.blockID == pane.blockID }
        }
        if projection.slots.count == 1 { return projection.slots.first }
        return nil
    }

    enum MoveAndExecuteAct: Equatable {
        case structural(StructuralAct)
        case deleteInEveryTake
    }

    /// The ONE mode-switch choreography's takes-side half: park a Write
    /// landing (block + carried caret/selection + the gesture) on the
    /// router, flush this surface's pending text (same per-post
    /// coordinator — the arriving editor serializes on it), and switch
    /// modes VISIBLY. The gesture then plans against the real landed
    /// selection, so any refusal is the operation's own, spoken — the
    /// lecture-and-redirect door is retired (its copy was also factually
    /// wrong for Divide).
    func moveToWriteAndRun(_ act: MoveAndExecuteAct) {
        guard let slot = commandTargetSlot else {
            speak("Click into a block first — then the gesture knows where to act.")
            return
        }
        var intent = WriteIntent(postID: postID, blockID: slot.blockID)
        // The caret/selection transfers when the focused pane shows the
        // CHOSEN take (Write shows chosen — same text, same offsets). A
        // non-chosen pane lands at the block's start; on a fanned block
        // divide opens the take ceremony, where cuts are adjusted per
        // take (the W memo's reading).
        let carried: NSRange? = {
            guard let sel = paneSelection,
                  sel.variantID == focusedPane?.variantID,
                  sel.variantID == slot.variantID else { return nil }
            return sel.range
        }()
        switch act {
        case .structural(.merge):
            // The merge memo: joining from Takes joins UPWARD — the caret
            // lands at the block's start, the seam with the block above.
            intent.offsetInBlock = 0
        case .structural(.divide):
            intent.offsetInBlock = carried?.location ?? 0
        case .structural(.extract), .structural(.makeBlock), .deleteInEveryTake:
            intent.offsetInBlock = carried?.location ?? 0
            intent.selectionLength = carried?.length ?? 0
        }
        switch act {
        case .structural(let gesture): intent.followUp = .structural(gesture)
        case .deleteInEveryTake: intent.followUp = .deleteInEveryTake
        }
        // Flush FIRST, then switch: the arriving editor's first render
        // reads the store, and the gesture must plan against the text the
        // author sees (the one per-post coordinator serializes the rest).
        // A REFUSED switch clears the parking (round-1 MAJOR, half a): a
        // stale intent surviving here would execute a structural gesture
        // unprompted at the next editor mount. `requestMode` speaks the
        // refusal itself (both failure branches).
        Task { [postID] in
            await autosave.flushNow()
            session.commandRouter.pendingWriteIntent = intent
            if !session.commandRouter.requestMode(.write, postID: postID) {
                session.commandRouter.pendingWriteIntent = nil
            }
        }
    }

    /// D3's third leg — the add-block door, NATIVE in Takes/Lenses: an
    /// empty block mints at the post's end and its pane takes the ring the
    /// moment its slot arrives ("just start typing", literally).
    func addBlockAtEnd() async {
        statusMessage = nil
        do {
            let result: Operations.NewBlockResult = try await session.runner.run { [postID] ops in
                try ops.newBlock(in: postID, text: "", at: .end)
            }
            pendingFocusVariantID = result.variant.id
            statusMessage = "New block added at the end — type away."
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    /// The routed comments door (⌘⇧' — the bars' block menu made
    /// keyboard-reachable): the bar presents the sheet for this target.
    struct CommentsRequest: Identifiable, Equatable {
        let blockID: String
        var id: String { blockID }
    }

    var commentsRequest: CommentsRequest?

    func requestComments() {
        guard let slot = commandTargetSlot else {
            speak("Click into a block first — comments live on the block you're in.")
            return
        }
        commentsRequest = CommentsRequest(blockID: slot.blockID)
    }

    // MARK: - Pane selection (the choreography's carried caret)

    /// The live pane's current selection, reported by the pane surface —
    /// what a fire-and-DO landing carries into Write.
    @ObservationIgnored private(set) var paneSelection: (variantID: String, range: NSRange)?

    func notePaneSelection(variantID: String, range: NSRange) {
        paneSelection = (variantID, range)
    }

    // MARK: - Landings (13b 1b — N9/AD-17 + the cross-mode bloom)

    /// True on the PRIMARY takes board only (never the Write panel's
    /// embedded model): landing focus + cross-mode landings apply there.
    @ObservationIgnored var landingEnabled = false
    @ObservationIgnored private var landingFocusDone = false
    /// A freshly-minted block's variant: its pane takes the ring when the
    /// slot arrives (the add-block door's second half).
    @ObservationIgnored private var pendingFocusVariantID: String?

    /// The landing column for programmatic focus: the takes board's main
    /// column, or the lens board's first column.
    private var landingColumnID: String {
        host == .takes ? Self.takesMainColumnID : (columns.first?.id ?? "main")
    }

    /// The Takes board's fixed main-column identity (shared with the view).
    nonisolated static let takesMainColumnID = "takes-main"

    private func consumeLandings(_ new: Queries.TakesProjection) {
        // A minted block's pane goes live the moment its slot arrives.
        if let want = pendingFocusVariantID,
           let slot = new.slots.first(where: { $0.variantID == want }) {
            pendingFocusVariantID = nil
            focus(PaneKey(columnID: landingColumnID, blockID: slot.blockID, variantID: want))
            return
        }
        guard landingEnabled else { return }
        // A cross-mode landing (Lenses' ⌘⇧T: blooms live in Takes — GO
        // there and bloom, visibly). Post-stamped (the round-1 MAJOR's
        // staleness discipline): a landing for ANOTHER post is left alone —
        // consuming it here would bloom a foreign block and eat THIS
        // board's landing focus below.
        if let landing = session.commandRouter.pendingTakesLanding,
           landing.postID == postID {
            session.commandRouter.pendingTakesLanding = nil
            switch landing {
            case .bloom(_, let blockID):
                expandedBlocks.insert(blockID)
                if let slot = new.slots.first(where: { $0.blockID == blockID }),
                   let variantID = slot.variantID {
                    focus(PaneKey(
                        columnID: landingColumnID, blockID: blockID, variantID: variantID))
                }
            }
            landingFocusDone = true
            return
        }
        // N9/AD-17 — "just start typing" at the Takes landing: with
        // nothing focused, the first block's article pane takes the ring.
        if !landingFocusDone, authority.livePane == nil,
           let first = new.slots.first, let variantID = first.variantID {
            landingFocusDone = true
            authority.focus(PaneKey(
                columnID: landingColumnID, blockID: first.blockID, variantID: variantID))
        }
    }

    // MARK: - Keyboard fan paging (13b 1b — AD-2's keyboard companion)

    /// Density inputs, pushed by the board (models never read @AppStorage).
    var beneathCount = 2
    var gridRows = 2
    var gridCols = 1

    /// R24's strip exception, one brain with the board's chunking.
    func railRowsPerColumn(slotText: String?) -> Int {
        (Self.usesHorizontalStrip(text: slotText) && gridRows == 1) ? 1 : gridRows
    }

    nonisolated static func railPageKey(_ blockID: String) -> String { "rail-\(blockID)" }

    /// The focused (else first-expanded) block's paging key + last legal
    /// offset in the CURRENT style — the board renders with the same
    /// answer, so the keyboard and the ◀ ▶ doors can never disagree.
    func pageTarget() -> (key: String, limit: Int)? {
        let blockID = focusedPane?.blockID
            ?? projection.slots.first { expandedBlocks.contains($0.blockID) }?.blockID
        guard let blockID, let fan = projection.fans[blockID], fan.count > 1 else { return nil }
        switch projection.fanStyle {
        case .carousel, .slotSplit:
            return (blockID, max(fan.count - beneathCount, 0))
        case .marginGrid:
            let text = projection.slots.first { $0.blockID == blockID }?.text
            let rows = railRowsPerColumn(slotText: text)
            let columns = (fan.count + rows - 1) / rows
            return (Self.railPageKey(blockID), max(columns - gridCols, 0))
        case .stack:
            return nil
        }
    }

    func pageFocusedFan(by delta: Int) {
        guard let (key, limit) = pageTarget(), limit > 0 else {
            speak("Open a block's takes first — ⌥⌘← and ⌥⌘→ page through its cards.")
            return
        }
        stepPage(key, by: delta, limit: limit)
    }

    func restoreCommit(_ commit: CommitPoint) async {
        await run { ops in try ops.restoreCommit(commit.variantId, commitID: commit.id) }
        if statusMessage == nil {
            statusMessage =
                "Restored — the savepoint is back in the take's buffer. Nothing was lost: commits are append-only."
        }
    }

    /// The R90 power variant (⇧⌥⌘T — "open new blank take as chosen"):
    /// mint AND choose in one gesture, both halves in one serialized run.
    func newBlankTakeAsChosen(blockID: String) async {
        statusMessage = nil
        do {
            let take = try await session.runner.run { ops -> Variant in
                let take = try ops.newBlankVariant(blockID)
                try ops.chooseVariant(blockID, variantID: take.id)
                return take
            }
            revealTake(blockID: blockID, variantID: take.id)
        } catch {
            statusMessage = Self.message(for: error)
        }
    }

    // MARK: - Reveal (Stage 2 tutorial-walk fix — the R112 class)

    /// A minted take must be SEEN. Before this, ⌘T (and the bar's ＋ take,
    /// the block menu, the growth doors) on a CLOSED fan minted a take
    /// that appeared NOWHERE — the article kept showing the chosen take
    /// and the only trace was the ⑂ counter ticking. The lesson's literal
    /// promise ("a second take appears beside it") is the contract (P-6):
    /// every mint door opens the block's fan and puts the ring on the new
    /// take, so typing continues there instantly.
    func revealTake(blockID: String, variantID: String, preferredColumnID: String? = nil) {
        expandedBlocks.insert(blockID)
        let columnID = preferredColumnID
            ?? focusedPane.flatMap { $0.blockID == blockID ? $0.columnID : nil }
            ?? landingColumnID
        focus(PaneKey(columnID: columnID, blockID: blockID, variantID: variantID))
    }

    /// Branch + reveal — the ONE body behind ⌘T, the bar's ＋ take, the
    /// block ▾ menu, the growth doors, and the card context menu.
    @discardableResult
    func branchTakeRevealed(
        blockID: String, from variantID: String, preferredColumnID: String? = nil
    ) async -> Variant? {
        guard let take = await branchTake(blockID: blockID, from: variantID) else { return nil }
        revealTake(blockID: blockID, variantID: take.id, preferredColumnID: preferredColumnID)
        return take
    }

    /// Blank + reveal — ⌥⌘T's one body (minting never chooses, R90; the
    /// blank card blooms and takes the ring).
    @discardableResult
    func newBlankTakeRevealed(
        blockID: String, preferredColumnID: String? = nil
    ) async -> Variant? {
        guard let take = await newBlankTake(blockID: blockID) else { return nil }
        revealTake(blockID: blockID, variantID: take.id, preferredColumnID: preferredColumnID)
        return take
    }

    // MARK: - The keyboard family's board half (R73)

    /// Which board hosts this model — ⌃⌘←/→ means "move the ring" in
    /// Takes and "move this column's pick" in Lenses.
    enum HostSurface { case takes, lenses }
    @ObservationIgnored var host: HostSurface = .takes

    /// The board asks its view to open the save-as-lens prompt (⌘⇧L —
    /// the view owns sheets, the model owns nothing UI).
    var lensPromptRequested = false

    /// ⌃⌘←/→ dispatch (R73): Takes moves the RING across the focused
    /// block's fan cards; Lenses steps the focused pane's column pick.
    func stepTakes(by delta: Int) async {
        guard let pane = focusedPane,
              let slot = projection.slots.first(where: { $0.blockID == pane.blockID })
        else {
            statusMessage = "Click into a take first — ⌃⌘← and ⌃⌘→ step through its siblings."
            return
        }
        switch host {
        case .lenses:
            if let column = columns.first(where: { $0.id == pane.columnID }),
               column.kind != .main {
                await stepPick(columnID: column.id, slot: slot, by: delta)
                return
            }
            fallthrough
        case .takes:
            guard let fan = projection.fans[slot.blockID], fan.count > 1,
                  let current = fan.firstIndex(where: { $0.id == pane.variantID })
            else {
                statusMessage = "This block has one take — ⌘T branches a second."
                return
            }
            let next = min(max(current + delta, 0), fan.count - 1)
            guard next != current else { return }
            if !expandedBlocks.contains(slot.blockID) { expandedBlocks.insert(slot.blockID) }
            focus(PaneKey(
                columnID: pane.columnID, blockID: slot.blockID, variantID: fan[next].id))
        }
    }

    /// ⌘⏎ — choose the take the ring is in (the ONE careful gesture, by
    /// keyboard).
    func chooseFocusedTake() async {
        guard let pane = focusedPane else {
            statusMessage = "Click into a take first — ⌘⏎ chooses the take you're in."
            return
        }
        await choose(blockID: pane.blockID, variantID: pane.variantID)
        if statusMessage == nil { statusMessage = "✓ chosen — the post shows this take everywhere." }
    }

    /// ⌘⇧T — toggle the focused (or first fanned) block's bloom.
    func toggleFocusedFan() {
        let blockID = focusedPane?.blockID
            ?? projection.slots.first(where: \.hasFan)?.blockID
            ?? projection.slots.first?.blockID
        guard let blockID else { return }
        toggleExpanded(blockID)
    }

    /// ⌘⇧A — archive the take the ring is in.
    func archiveFocusedTake() async {
        guard let pane = focusedPane else {
            statusMessage = "Click into a take first — ⌘⇧A archives the take you're in."
            return
        }
        await archiveTake(pane.variantID)
        if statusMessage == nil {
            statusMessage = "Take archived — it stays in the block's history (unarchive below)."
        }
    }

    /// The lens column's per-block ‹ › switcher (R83/R89 — the canvas
    /// grammar reused; here it moves THAT COLUMN's pick only, view-local
    /// for scratch, live-edited for named lenses; ends clamp).
    func stepPick(columnID: String, slot: Queries.RenderedBlock, by delta: Int) async {
        guard let column = columns.first(where: { $0.id == columnID }),
              column.kind != .main,
              let fan = projection.fans[slot.blockID], fan.count > 1,
              let current = resolvedTake(column: column, slot: slot)
        else { return }
        guard let index = fan.firstIndex(where: { $0.id == current.variantID }) else { return }
        let next = min(max(index + delta, 0), fan.count - 1)
        guard next != index else { return }
        await pick(columnID: columnID, blockID: slot.blockID, variantID: fan[next].id)
    }

    /// The switcher's "take k of n" caption for a column's block.
    func pickPosition(columnID: String, slot: Queries.RenderedBlock) -> (index: Int, count: Int)? {
        guard let column = columns.first(where: { $0.id == columnID }),
              let fan = projection.fans[slot.blockID], fan.count > 1,
              let current = resolvedTake(column: column, slot: slot),
              let index = fan.firstIndex(where: { $0.id == current.variantID })
        else { return nil }
        return (index + 1, fan.count)
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

    /// The ops-refusal vocabulary moved to the shared layer (13b 1b —
    /// Canvas/TOC/Tutorial no longer reach into this feature for copy);
    /// kept as a forward so every pin and call site reads unchanged.
    static func message(for error: Error) -> String {
        OpsRefusalCopy.message(for: error)
    }
}
