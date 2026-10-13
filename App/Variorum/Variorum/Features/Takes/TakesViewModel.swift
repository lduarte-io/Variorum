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
//  13b Stage 3 (N10 — the P-9 decomposition): the board's session-only
//  view-geometry state lives in `TakesBoardLayout` and the cross-surface
//  choreography (move-and-execute parking, landings) in
//  `TakesChoreographer`; this class remains the takes CONDUCTOR
//  (projection lifecycle, authority mapping, columns, the ops-call
//  gestures, the keyboard family) and forwards both components' surfaces
//  so every call site and pin reads unchanged.
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
        // 17q piece 6 (her R-Q21): the board asks ONCE, at construction, which
        // block was current when it was last shown — the value is a fact about
        // the PREVIOUS showing and this mount overwrites the session's copy
        // within milliseconds (`consumeLandings` sets the entry ring before it
        // sets the landing), so a live read would compare the landing against
        // itself. `landingEnabled` is not known yet here; the WRITE side is
        // gated on it, so the Write panel's embedded model never puts anything
        // in this store and its snapshot is whatever the real board left —
        // which it never consults, because it holds no article landing.
        self.board = TakesBoardLayout(
            postID: postID, defaults: defaults,
            lastCurrentRow: session.editorRouter.takesArticleCurrentRows[postID])
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
                self?.setRefusal(Self.message(for: error))
            },
            // 13e E15: settle no longer ADOPTS the held photograph — it
            // settles through the ONE fresh-read path, exactly as both
            // editor surfaces do (the value was fetched BEFORE the flush
            // that just landed, so adopting it regressed the board to
            // pre-flush bytes).
            onSettled: { [weak self] in
                self?.storeWriteGeneration &+= 1
                self?.applyPendingIfClean()
            })
    }

    @ObservationIgnored private var autosaveToken: UUID?

    /// **18k C1 — the ONE release for the ONE acquisition in `init`.** The
    /// instance's death is the only point that runs exactly once per
    /// acquisition: SwiftUI builds this model eagerly in its view's `init`
    /// (`State(initialValue:)` evaluates its argument on EVERY re-init and
    /// keeps only the first), so discarded twins acquire too and never see
    /// `onDisappear`, while a kept one can see `teardown()` more than once.
    /// Nothing records through this instance after it dies, and it dies only
    /// after its flush has landed — `teardown()`'s flush Task holds `self` until then — so the
    /// release is flush-then-release by construction. What the session does
    /// with the last release is `AppSession.releaseAutosave(forPost:)`'s.
    isolated deinit {
        session.releaseAutosave(forPost: postID)
    }
    /// The store-write freshness generation (the `EditorViewModel` fence,
    /// mirrored — mobile S3 ladder MAJOR 3): bumped whenever OUR writes
    /// settle, so a fresh read that STRADDLED a settle is re-signaled
    /// instead of adopted.
    @ObservationIgnored private var storeWriteGeneration = 0
    /// Whether a projection has ever been adopted — the policy's `loaded`
    /// input (a first value has no display to protect).
    @ObservationIgnored private(set) var loaded = false

    // MARK: - Observable state

    private(set) var projection = Queries.TakesProjection()
    private(set) var columns: [TakesColumn]
    var alignmentLocked: Bool {
        didSet { saveMemory() }
    }
    /// The ONE live pane (P3: the live editor migrates on click; everything
    /// else renders read-cheap) — the authority's, forwarded.
    var focusedPane: PaneKey? { authority.livePane }
    /// The board's session-only view-geometry state (13b Stage 3, N10 —
    /// the P-9 decomposition's seam 1): expansion, paging, follow-the-
    /// scroll visibility, density. Every pre-move property/method name is
    /// forwarded below, so views and pins read unchanged.
    ///
    /// QoL batch 2: constructed in `init` now, because L3's slot heights
    /// are LOCAL VIEW MEMORY and need the post identity + the injected
    /// defaults a property initializer cannot see.
    @ObservationIgnored let board: TakesBoardLayout
    /// The cross-surface choreography (seam 2): move-and-execute parking,
    /// the carried pane selection, landing consumption. Lazy so the
    /// composition can reference `self`.
    @ObservationIgnored private(set) lazy var choreography = TakesChoreographer(model: self)
    /// The board's STRUCTURAL DOORS (seam 3 — 13e ladder round A, A-2: the
    /// P-9 split the constitution names, on the editor side's
    /// `EditorSurfaceController` pattern). Every act that mints, joins,
    /// moves or removes rows from this surface lives there; this class keeps
    /// each pre-move name as a forwarder, so views and pins read unchanged.
    /// It holds NO state of its own — the latch, the status line and the
    /// projection stay here — so nothing about observation or invalidation
    /// changes with the move. Lazy so the composition can reference `self`.
    @ObservationIgnored private(set) lazy var structure = TakesStructureController(model: self)
    /// Fanned blocks currently bloomed — the board's (forwarded).
    var expandedBlocks: Set<String> { board.expandedBlocks }
    /// The board's transient outcome line, **CLASSED** (the post-13l polish
    /// round, batch 5 — the architect's routed flag 2: ledger row 6's defect,
    /// one surface over).
    ///
    /// Row 6 split the tray's single red slot because *"Put back where it
    /// was."* — the whole point of that surface — read as an error.
    /// `WriteTakesPanel`'s slot has the same shape: ONE line, painted
    /// `tokens.accent` whatever it says, so a board receipt wears the colour a
    /// refusal wears. Batch 4 deliberately did NOT sweep it into `alarm`,
    /// because painting the whole slot alarm would make every receipt read as
    /// an error — the defect, not the fix.
    ///
    /// So the class is decided **where the message is produced**, never
    /// guessed by a view from its text, which is what makes the drift
    /// impossible rather than merely unlikely.
    ///
    /// PRESENTATION is still the shell's StatusCenter (AD-14 — one placement,
    /// one auto-dismiss policy).
    private var statusSlot: TrayViewModel.Status? {
        didSet {
            // 18i (her R-Q5): the class this board already decides at the
            // door RIDES to the shell. `RecoveryStatus`'s receipt/refusal
            // split IS the centre's — one rule, two renderers (the panel's
            // colour and the shell's placement), never a second predicate.
            if let status {
                session.status.deliver(
                    status.text, kind: status.isRefusal ? .refusal : .receipt)
            }
        }
    }

    /// **THE BOARD'S STATUS LINE — READ-ONLY TO EVERYTHING, THIS TYPE
    /// INCLUDED** (13u2 UNIT E — KnownIssues row 56, step 2).
    ///
    /// It was `private(set)`, which in Swift means "private to the type AND
    /// its same-file extensions" — and this file is 2,600 lines, so 66 call
    /// sites wrote the slot directly and the three doors below were a
    /// convention rather than a fence. That is precisely why the 18i ladder's
    /// J38 found EIGHT of them mis-classified against a green suite: a class
    /// decided at a bare assignment is invisible to any pin that reads the
    /// words.
    ///
    /// A computed forward makes the bypass UNEXPRESSIBLE — `status = …` no
    /// longer compiles anywhere, including here — so every message on this
    /// board passes through a door whose NAME is its class. Readers are
    /// unchanged: `@Observable` tracks the stored slot the getter reads, so
    /// every view and every pin observes exactly what it observed before.
    var status: TrayViewModel.Status? { statusSlot }

    /// The forwarder, so every shipped pin and every reader rides unmodified
    /// (the 3C parity pattern — a hoist moves an address, not behaviour).
    var statusMessage: String? { status?.text }

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

    // MARK: - Follow-the-scroll (Phase 13 C2, R25) — the board's, forwarded

    /// R25 — pushed by the View from the theme settings.
    var followTheScroll: Bool {
        get { board.followTheScroll }
        set { board.followTheScroll = newValue }
    }

    /// The visible FANNED blocks (R25's set — derived from the board's
    /// counts against the current projection, so a fan born mid-visibility
    /// is picked up without a re-appear).
    var visibleFannedBlocks: Set<String> {
        Set(projection.slots
            .filter { $0.hasFan && board.isRowVisible($0.blockID) }
            .map(\.blockID))
    }

    func rowAppeared(_ blockID: String) {
        board.rowAppeared(blockID)
    }

    func rowDisappeared(_ blockID: String) {
        board.rowDisappeared(blockID)
    }

    /// THE bloom rule (R25) — the board's, read THROUGH the `show ▾` filter
    /// (VX-170): with no filter it is the board's rule byte-for-byte; under one,
    /// a collapsed row never blooms and a filtered row blooms its expand set.
    func isBloomed(_ slot: Queries.RenderedBlock) -> Bool {
        lensFilter.isBloomed(slot)
    }

    /// **VX-170 — the board's `show ▾` filter** (lens-aware Takes), its own
    /// component (P-9, the `find` shape). Lazy so the composition can reference
    /// `self`.
    @ObservationIgnored private(set) lazy var lensFilter = TakesLensFilterController(model: self)

    /// How a row draws under the filter (`.ordinary` with none) — forwarded.
    func rowShape(_ slot: Queries.RenderedBlock) -> TakesRowShape {
        lensFilter.rowShape(slot)
    }

    /// The takes a bloom draws: the filter's expand set on a filtered row, the
    /// whole active fan everywhere else — forwarded, so every bloom style and
    /// both pagers ask ONE question.
    func bloomTakes(_ slot: Queries.RenderedBlock) -> [Variant] {
        lensFilter.bloomTakes(slot)
    }

    /// Expand-all only where it MEANS something (R25's agreed half): the
    /// article that isn't slot-split (slot split IS a whole-post fan
    /// presentation already). Columns no longer figure in — they live in
    /// the LENSES tab now (Sitting 9, R86: the entanglement is dead).
    var offersExpandAll: Bool {
        projection.fanStyle != .slotSplit
    }

    /// R24's short/long rule for the margin grid — the board layout's
    /// rule; the static forward keeps every `TakesViewModel.` call site
    /// and pin unchanged.
    nonisolated static func usesHorizontalStrip(text: String?) -> Bool {
        TakesBoardLayout.usesHorizontalStrip(text: text)
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

    /// ONE structural act lands at a time on this surface (13d Batch 3 —
    /// Write's `structuralInFlight` shape, its board twin). Taken
    /// synchronously at the door BEFORE any await; released in a `defer`.
    ///
    /// It does two jobs, and the second is a correctness job, not tidiness:
    /// a second divide refuses visibly (including ⌘⇧D under the open
    /// ceremony sheet, since key equivalents stay live under a
    /// window-modal sheet — the Phase 9 round-3 MINOR), AND the panes
    /// FREEZE for the flight. Without the freeze, a keystroke landing
    /// between the flush and the op records the block's PRE-divide text
    /// into autosave, whose debounce then writes that whole text back over
    /// the half `ops.divide` just truncated — the second half would live in
    /// the source block AND the new one. That is the forbidden
    /// text-duplication class `runStructural` names, and Write closes it
    /// with `textView.isEditable = false`; this is the same close.
    /// Settable internally, deliberately: in production only
    /// `divideFocused` and `runDivideW` write it (both immediately around
    /// their awaits), but the freeze is a rule about what a pane may do
    /// DURING a flight, and a pin that cannot stage a flight cannot check
    /// it — the `adopt`/`divideWorld` precedent (internal so tests drive
    /// the state deterministically rather than racing it).
    var structuralInFlight = false

    /// The take ceremony, mounted on THIS board (13d Batch 3, A9): a
    /// fanned block's divide opens the same sheet Write opens, in place.
    @ObservationIgnored private(set) lazy var ceremony = DivideWCeremony(host: self)

    /// The sheet's `.sheet(item:)` binding — the ceremony's own state,
    /// forwarded so the boards bind to the model like every other sheet.
    var divideWCeremony: DivideWCeremony.State? {
        get { ceremony.state }
        set { ceremony.state = newValue }
    }

    /// Pane liveness with BOTH of this surface's suppression reasons
    /// folded in (13d Batch 3): a sealed post has no live pane (viewing
    /// isn't authoring), and a pane whose post is mid-structural-flight is
    /// frozen the same way. The authority still answers "which pane is
    /// live" — this composes the reasons before asking it, exactly as
    /// `sealed:` already did, so no second liveness mechanism exists (P-3).
    func isPaneLive(_ key: PaneKey) -> Bool {
        let frozen = projection.sealed || structuralInFlight
        return authority.isLive(key, sealed: frozen)
    }

    // MARK: - Lifecycle

    func start() async {
        do {
            for try await value in session.database.observeTakes(postID) {
                // 13e E15: a delivery is a SIGNAL, never adoption authority
                // (the shared policy — the same words `observeSlots` uses).
                deliver(value)
            }
        } catch is CancellationError {
        } catch {
            setRefusal("Takes observation failed: \(error)")
        }
    }

    // MARK: - Projection deliveries (13e E15 — the board joins the ONE policy)

    /// **A DELIVERY may never rewrite the board** (the KnownIssues row *"The
    /// Mac Takes board adopts projection deliveries directly"*, owner 13e;
    /// the class the mobile S3 ladder closed at `EditorProjectionPolicy` for
    /// both EDITOR surfaces while this board kept its own two-line rule).
    ///
    /// The mechanism, traced on this surface: an observation value fetched
    /// BEFORE a flush can be CONSUMED after it settles — at that clean
    /// instant the old rule adopted it, `authority.settle` then cleared the
    /// (no-longer-pending) buffer, and every pane mirroring that variant fell
    /// back to the projection's PRE-FLUSH text. A keystroke in that window
    /// computes its delta against the stale text (`paneEdited` →
    /// `currentStoreText`) and autosaves it over the newer store text. The
    /// old settle path had the same hole from the other side: it adopted the
    /// photograph it had been holding since before the flush.
    ///
    /// Internal so pins drive it deterministically (the `adopt` precedent —
    /// the test host never runs the observation).
    func deliver(_ new: Queries.TakesProjection) {
        applyProjection(new, fromDelivery: true)
    }

    /// Executes the ONE policy's decision for this surface. The board has no
    /// text surface to differentially rewrite, so the three render arms
    /// collapse into adoption — what matters is the precedence the policy
    /// pins: not-loaded ▸ busy ▸ echo ▸ delivery-refetch.
    ///
    /// `busy` is exactly the board's standing defer condition (a dirty
    /// buffer). A structural flight is deliberately NOT folded in: the board
    /// has no flight-exit settle hook the way `EditorSurfaceController` does,
    /// and its native divide relies on the ordinary adoption to show the
    /// successors (recorded, #57).
    func applyProjection(_ new: Queries.TakesProjection, fromDelivery: Bool = false) {
        switch EditorProjectionPolicy.decide(
            loaded: loaded,
            busy: autosave.isDirty,
            forceFull: false,
            delivery: fromDelivery,
            matchesSurface: displayMatches(new),
            // The board never renders a partial rewrite; the differential
            // arm has no meaning here and is never taken.
            sameSequence: false
        ) {
        case .deferUntilClean:
            deferredProjection = new
        case .refetchFresh:
            // Hold the marker and settle by the ONE fresh-read path; the
            // fresh value comes back as a NON-delivery and adopts.
            deferredProjection = new
            applyPendingIfClean()
        case .initialRender, .adoptEcho, .differential, .fullRender, .forcedFullRender:
            adopt(new)
        }
    }

    /// True when the delivery says exactly what the board already SHOWS — the
    /// echo check, in this surface's own terms.
    ///
    /// With NO live buffer the board's display IS the projection, so a
    /// byte-identical delivery is an echo and adopting it changes nothing.
    /// With a buffer in hand the display is deliberately NOT the projection,
    /// and nothing cheap here can tell a stale photograph from a genuinely
    /// newer one — so nothing matches and the fresh-read path decides. The
    /// cost is bounded and deliberate: at most one extra read per delivery
    /// inside the settle window (exactly what the editor surfaces pay at the
    /// same moment), and zero the rest of the time. A LAX check here would
    /// freeze the display; a strict one only ever costs a read.
    func displayMatches(_ new: Queries.TakesProjection) -> Bool {
        authority.buffers.isEmpty && new == projection
    }

    /// Settles a held delivery by RE-READING the store (the editor surfaces'
    /// `applyPendingIfClean`, mirrored): the held value predates the write
    /// that settled, so the fresh projection — which includes that write — is
    /// what adopts. A settle landing DURING the read re-signals through the
    /// generation fence.
    func applyPendingIfClean() {
        guard !autosave.isDirty, deferredProjection != nil else { return }
        deferredProjection = nil
        let generation = storeWriteGeneration
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] db in
                try Queries.takesProjection(db, post: postID)
            }) else { return }
            guard !autosave.isDirty else {
                deferredProjection = fresh
                return
            }
            guard generation == storeWriteGeneration else {
                deferredProjection = fresh
                applyPendingIfClean()
                return
            }
            applyProjection(fresh)
        }
    }

    /// Internal so tests drive projections deterministically (the test host
    /// never fires `.task`).
    func adopt(_ new: Queries.TakesProjection) {
        loaded = true
        // **13u2 UNIT E — THE ONE STRUCTURAL ARM** (KnownIssues row 51's
        // recommended design, built inside the `TakesArticleScroll` split).
        // A pending article landing ends when the content it was judged
        // against changes — whatever changed it: her gesture, a SYNC arrival,
        // a structural undo in another window, an engine repair. The dozen
        // enumerated gesture arms stay (they end a landing AT the gesture,
        // which is when her hand moved, and their pins assert exactly that);
        // this makes a road nobody enumerated impossible rather than
        // improbable. It runs FIRST, before `consumeLandings` below can make
        // a new landing against this projection.
        board.noteProjectionArrived(new)
        refreshWordCounts(old: projection, new: new)
        // VX-222: the take the article showed under the ring, read while the
        // OUTGOING projection is still in hand (`endRingIfItsTakeChanged`) —
        // since VX-227 (F5) on the Lenses host's columns too; and the take a
        // parked follow's cell showed (rider 1's adoption arm).
        let ringTakeBefore = takeUnderRing(in: projection)
        let parkedTakeBefore = parkedFollow.flatMap {
            stableCellTake(columnID: $0.columnID, blockID: $0.blockID, in: projection)
        }
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
        // VX-222: a ring whose article cell changed take under it ends here —
        // BEFORE the landings below may ring the fresh projection. VX-227
        // (F5): the same for a ring in any Lenses column; and a parked follow
        // whose cell re-resolved elsewhere is dropped.
        endRingIfItsTakeChanged(from: ringTakeBefore)
        dropParkedFollowIfMovedElsewhere(from: parkedTakeBefore)
        // VX-170: the `show ▾` filter re-reads the fresh projection BEFORE the
        // landings below resolve against it (a landing onto a pane the filter
        // hides opens its block — the filter must already know the shapes).
        lensFilter.projectionAdopted()
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
        // 13e E3: a ⌘-click selection only ever names blocks the post holds —
        // a merge's own successors, a delete or a sync arrival drop out (the
        // `expandAll` shape: the conductor hands over the fresh set, the
        // layout component never reads the projection).
        board.pruneMergeSelection(to: Set(new.slots.map(\.blockID)))
        // 13b 1b: programmatic landings (add-block focus, cross-mode
        // blooms, the N9 "just start typing" ring) resolve against the
        // fresh slots.
        consumeLandings(new)
        // 13b 3F: a revealed mint that lagged its projection pages its fan
        // now (re-parking while the take is still in flight). NIT-2: a
        // re-park inherits the DECREMENTED budget — a fresh reveal gets a
        // fresh one — and drops at zero (the take is not coming).
        if let pending = pendingRevealPage {
            pendingRevealPage = nil
            pageToReveal(blockID: pending.blockID, variantID: pending.variantID)
            if pendingRevealPage != nil {
                pendingRevealPage = pending.retriesLeft > 1
                    ? (pending.blockID, pending.variantID, pending.retriesLeft - 1)
                    : nil
            }
        }
    }

    func teardown() {
        // The article's memory is closed first (the 17q ladder's round 2,
        // R2-2): the rows' departures that follow — or precede, the order is
        // not SwiftUI's promise — must not write a place she never saw.
        articleTornDown = true
        // 18l-b U2: a landing the one authority is watching ends SILENTLY
        // with the board (nothing landed; no story to file).
        board.endArticleLandingWatch()
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
        authority.resolvedText(
            pick: columnPick(column, blockID: slot.blockID, in: projection),
            slot: slot, fan: projection.fans[slot.blockID])
    }

    /// The column kind's pick for a block, read against `projection` (a
    /// named lens's picks live in the store; a scratch column's in view
    /// memory; the Chosen column has none).
    private func columnPick(
        _ column: TakesColumn, blockID: String, in projection: Queries.TakesProjection
    ) -> String? {
        switch column.kind {
        case .main: return nil
        case .scratch: return column.picks[blockID]
        case .lens(let lensID): return projection.lensSelections[lensID]?[blockID]
        }
    }

    /// **VX-227 — the take a STABLE-IDENTITY cell renders** for `blockID` in
    /// `columnID` under `projection`, or nil where that column renders no
    /// stable cell (or the column/block is gone). Two cell kinds are stable —
    /// ONE pane per block whose key moves with its resolution: the Takes
    /// board's ARTICLE (`takes-main`, the block's chosen take — 13b 3F) and
    /// EVERY Lenses column (its pick, else the chosen — the authority's
    /// fall-through, the same rule `resolvedTake` asks). Fan cards and the
    /// Write panel's cards are one pane per TAKE (identity by take id), so a
    /// ring moved onto one never re-points a pane she is typing in.
    ///
    /// Why it matters (the run record's BATCH 4 RECORD, mechanism 3): a LIVE
    /// pane never receives projection text (`PaneSurface.swift:1514-1524`),
    /// so a stable cell re-pointed while live — or turned live in the same
    /// render that re-points it — keeps the OUTGOING take's words under the
    /// INCOMING take's key, and the next keystroke writes them there.
    private func stableCellTake(
        columnID: String, blockID: String, in projection: Queries.TakesProjection
    ) -> String? {
        guard let slot = projection.slots.first(where: { $0.blockID == blockID }) else { return nil }
        switch host {
        case .takes:
            return columnID == Self.takesMainColumnID ? slot.variantID : nil
        case .lenses:
            guard let column = columns.first(where: { $0.id == columnID }) else { return nil }
            return authority.resolvedText(
                pick: columnPick(column, blockID: blockID, in: projection),
                slot: slot, fan: projection.fans[blockID])?.variantID
        }
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
        // VX-227 (rider 1): any focus that is not the parked key's own
        // render-report ends a parked follow (`paneRendered` clears its park
        // before it comes through here).
        parkedFollow = nil
        // VX-170: the ring never lands on a pane the `show ▾` filter hides —
        // that pane's block opens first (a click only ever reaches a shown
        // pane, so this is the landings', reveals' and find's door).
        lensFilter.reveal(pane)
        // 17o batch b (U-20): armed BEFORE the report, because the report
        // itself is what makes this block current — read after it, the
        // memory would answer about the pane we are about to open rather
        // than the place she is coming from.
        armPaneCaretLanding(for: pane)
        // Ledger row 33 — the boards' half of "the block you're in", reported
        // at the ONE authority door (P-3), so Takes and Lenses both feed the
        // Block History pane's jump without a second liveness mechanism.
        session.commandRouter.noteFocusedBlock(
            pane.blockID, variantID: pane.variantID, postID: postID)
        switch authority.focus(pane) {
        case .unchanged:
            return
        case .migrated(let leaving):
            // Her hand: a click that moves the live editor ends a pending
            // article landing (17p batch a, J1).
            board.clearArticleLanding()
            // 17q piece 6 (her R-Q21): …and it makes THIS the block she is
            // in, so leaving right afterwards is not "she moved blocks while
            // away".
            rememberArticleCurrentBlock(pane.blockID)
            // The leaving pane's text lands as the ring migrates (the
            // handoff contract in miniature — safety rides the buffers +
            // the `!isLive` adopt guard; the flush converges the store).
            if leaving != nil {
                Task { await autosave.flushNow() }
            }
        }
    }

    func blur() {
        parkedFollow = nil  // VX-227 (rider 1): a blur ends a parked follow too
        authority.blur()
        Task { await autosave.flushNow() }
    }

    // MARK: - VX-227 — THE PARKED FOLLOW (her R-VX214-1; the architect's F2)

    /// The pane the ring follows onto once its cell has RENDERED it — set by
    /// the doors that re-point a stable cell under the ring (a step, a pick, a
    /// mint into a column, a blank-and-choose, a transient slot change), nil
    /// otherwise. Never observed: the cells REPORT to it (`paneRendered`); no
    /// view reads it to decide anything (P-3 — the authority stays the one
    /// answer to "is this pane live").
    ///
    /// The ONE-RING CONTRACT, extended rather than duplicated: while a follow
    /// is parked the ring is NIL — never two live panes, never one stranded on
    /// a key no cell renders (rider 2). The gap lasts one render for a view-
    /// memory pick and one store round for a named lens's; a keystroke in it
    /// meets a read pane, never a wrong take. Anything else that moves the
    /// ring (a focus, a blur) or re-resolves the parked cell elsewhere (an
    /// adoption) drops the park (rider 1).
    @ObservationIgnored private(set) var parkedFollow: PaneKey?

    /// End the ring by the flushed blur (no keystroke dies with it), then
    /// park `key` — the follow lands when the cell reports rendering it.
    private func followOnceRendered(_ key: PaneKey) {
        blur()
        parkedFollow = key
    }

    /// **A cell reports the key it has RENDERED** (`TakesCellView`'s
    /// render-report, after the render that drew it — the `onFocusRequest`
    /// shape: the view reports a fact, the model's one focus door decides).
    /// Only the parked key is acted on: the pane now shows that take's own
    /// text READ-ONLY (a read pane adopts the projection), so turning it live
    /// is a read→live flip of a pane that already holds its own words — the
    /// re-bind that can never keep another take's words.
    func paneRendered(_ key: PaneKey) {
        guard let parked = parkedFollow, parked == key else { return }
        parkedFollow = nil
        focus(key)
    }

    /// Rider 1's adoption arm: a parked follow survives an adoption that
    /// leaves its cell alone (an echo, another block's edit, the flush's own
    /// settle) or that BRINGS the parked take (a named lens's pick arriving);
    /// one that re-resolves the parked cell to any OTHER take, or removes the
    /// column or block, ends it — the world moved on without her.
    private func dropParkedFollowIfMovedElsewhere(from before: String?) {
        guard let parked = parkedFollow else { return }
        let after = stableCellTake(
            columnID: parked.columnID, blockID: parked.blockID, in: projection)
        if after == nil || (after != before && after != parked.variantID) {
            parkedFollow = nil
        }
    }

    // MARK: - VX-222 — the article's ring never outlives the take it rang

    /// The take the ring's STABLE cell shows for its block in `projection` —
    /// the ARTICLE's (the Takes board's column that renders each block's
    /// CHOSEN take) or, since VX-227 (F5), a Lenses column's; nil when the
    /// ring is in a per-take card or its block/column is gone
    /// (`stableCellTake` is the one rule).
    private func takeUnderRing(in projection: Queries.TakesProjection) -> String? {
        guard let live = authority.livePane else { return nil }
        return stableCellTake(columnID: live.columnID, blockID: live.blockID, in: projection)
    }

    /// **VX-222 — a ring whose article cell changed take under it ENDS** (the
    /// architect's ruling, 2026-10-13; the trace is the run record's VX-222
    /// RECORD in `notes/plans/fixes/vx-214-settings-launch-polish.md`).
    ///
    /// The article cell is ONE stable-identity pane per block that renders the
    /// block's chosen take (13b 3F) and keys its liveness by that take's id.
    /// When the store moves the chosen pointer — her card's "choose", ⌘⏎, an
    /// agent's `choose_take`, sync, undo — the cell re-resolves under a ring
    /// keyed to the OLD take: it goes read-only and shows the new take, while
    /// the ring names a pane nothing renders (the R112 class). Choosing the
    /// old take back then turned that same pane LIVE in place, and a live
    /// pane never adopts projection text (it is buffer-authoritative), so the
    /// page kept the other take's words under the ✓ — and a keystroke there
    /// would have written them into the wrong take. A ring ⌃⌘→ stepped onto
    /// the next take's id came back to life the same way when that take was
    /// chosen.
    ///
    /// So when the article's take for the ring's block CHANGES across an
    /// adoption, the ring ends through `blur()` — whose flush is load-bearing:
    /// no keystroke may die with the ring. The test is the column's MODEL
    /// resolution, never the viewport: a ring whose row scrolled away keeps
    /// its place, and an adoption that leaves the article's take alone never
    /// touches it. Fan cards render the whole fan, so a ring in a card (her
    /// click into a take, the ⌘⏎ road) is never in question here.
    ///
    /// **VX-227 (the architect's F5 ruling): the same rule on the LENSES
    /// host's columns** — a lens pick moved by sync, an agent's
    /// `setLensChoice`/`adopt_lens`, another window or undo, and a choice
    /// under a Chosen-column ring, re-resolve that column's stable cell exactly
    /// as VX-222's choose did, so the ring ends. The STEP is not in conflict:
    /// it parks its follow first (the ring is nil at its own adoption), and a
    /// parked follow is judged by `dropParkedFollowIfMovedElsewhere` instead.
    private func endRingIfItsTakeChanged(from before: String?) {
        guard let before, let after = takeUnderRing(in: projection), after != before
        else { return }
        blur()
    }

    // MARK: - 13f W7 — the takes room's landing

    /// The variant whose pane should take the caret at the END of its text,
    /// and the monotonic token that says "asked again". Only the board's
    /// typewriter-room click writes these; a pane compares the token it is
    /// handed against the one it last acted on.
    private(set) var caretToEndVariantID: String?
    private(set) var caretToEndCounter = 0

    /// Focus a pane AND ask it for its caret at the text end — the room's
    /// whole gesture. It rides `focus` (the ONE authority door, migration
    /// flush and all); the caret half is a message to the pane that focus
    /// already reached, never a second way to be live (P-3).
    func focusWithCaretAtEnd(_ pane: PaneKey) {
        caretToEndVariantID = pane.variantID
        caretToEndCounter += 1
        focus(pane)
        // The room asked for the END explicitly (13f W7's A22) — the note's
        // remembered place does not get a say here. Armed as the END rather
        // than cleared (the ladder's R1-3 rider): a pane BORN live under the
        // room's request only ADOPTS the caret-to-end token at its first
        // render (`makeNSView` — the token applies on updates), so with the
        // transition's START rule a cleared arm would have landed it at 0;
        // `.end` lands the text's end in the transition, and an already-
        // mounted pane's token application lands the same place.
        paneCaretLanding = (variantID: pane.variantID, landing: .end)
    }

    /// **18l-c U7 — a FIND step's focus** (the design brief's decision 6: the
    /// current match's take goes LIVE with the match SELECTED). The room's
    /// shape one landing over: it rides `focus` (the ONE authority door —
    /// migration flush, the current-block report and all) and then names
    /// where the caret lands, AFTER `focus` armed the entry rule, so the step's
    /// own place wins. The body of the find lives in `TakesFindController`;
    /// this is the one line it needs from the landing state this file owns.
    func focus(_ pane: PaneKey, landingAt landing: PaneCaretLanding) {
        focus(pane)
        paneCaretLanding = (variantID: pane.variantID, landing: landing)
    }

    /// **18l-c U7 — search in Takes** (`TakesFindController`): the board's
    /// find, its own component (P-9 — the `structure` / `choreography`
    /// shape). Lazy so the composition can reference `self`.
    @ObservationIgnored private(set) lazy var find = TakesFindController(model: self)

    // MARK: - Where a pane's caret lands when it takes the ring (17o batch b)

    /// The note's remembered caret place, for the ONE pane about to go live.
    /// `@ObservationIgnored` on purpose: it is read at the render the ring
    /// move already caused, never watched — a caret place is data, not a
    /// signal (the argument in full is on `CommandRouter.focusedBlock`).
    @ObservationIgnored private var paneCaretLanding: (variantID: String, landing: PaneCaretLanding)?

    /// Arms the landing when — and only when — the pane taking the ring is
    /// the note's CURRENT block: the remembered place, else its START (R1-3
    /// — an accidental END there becomes "where she was"). Any other block
    /// is left alone (`.leave`, the shipped END): a click brought its own
    /// place, and a post-structural ring landing (the survivor, the merged
    /// block, the divide successors, the moved take — `parkFocus` → `focus`)
    /// keeps the "continue at the end of what you just made" it shipped with
    /// (the sanity pass's RAISE-2; QUESTIONS #97 names the edge).
    private func armPaneCaretLanding(for pane: PaneKey) {
        // Round 2 (R2-4): the entry rule is `PaneCaretLanding.entering` —
        // one pure copy shared with `BlockTOCViewModel`.
        paneCaretLanding = PaneCaretLanding.entering(
            session.commandRouter.currentBlock(for: postID), block: pane.blockID
        ).map { (variantID: pane.variantID, landing: $0) }
    }

    /// What a pane rendering `variantID` is handed. `.leave` for every pane
    /// the landing did not name, so nothing else on the board ever moves.
    func caretLanding(forVariant variantID: String) -> PaneCaretLanding {
        paneCaretLanding.map { $0.variantID == variantID ? $0.landing : .leave } ?? .leave
    }

    // MARK: - The article's landing (17o batch b, row 8) — the board layout's,
    // forwarded

    /// The `placementID` the article column is asked to scroll to, or nil.
    var articleLanding: String? { board.articleLanding }

    /// The article scrolled: the request is spent.
    func clearArticleLanding() { board.clearArticleLanding() }

    // MARK: - The article's scroll memory and its reveal rule (17p batch a,
    // row 1 — her ruling R-Q1)

    /// The article's realized rows report their place; the board answers
    /// whether a landing needs a scroll at all.
    func noteArticleRowFrame(_ placementID: String, _ frame: CGRect) {
        guard board.noteArticleRowFrame(placementID, frame) else { return }
        // The 17q ladder's R1-1 (the re-walk): the scroll hook runs before
        // the rows' frame reports for the same step, so the memory it wrote
        // is one step stale — a row that moved re-derives it.
        if case .remember(let place) = board.articleRowFramesMoved() {
            rememberArticlePlace(place)
        }
    }

    /// A row left the realized set — **the DEPARTURE half of W-2's rule**
    /// (the 17q ladder's round 2, R2-2). `articlePlaceNow` takes the lowest
    /// fitting frame, so a de-realized row's last frame masks every arrival
    /// while it is held and is then forgotten without a report: the memory
    /// stayed one fling stale on her 262-block note (a fling from the entry
    /// frame to the top, ⌘1, ⌘2 → back at the entry frame; captures `35` →
    /// `36`). The re-derivation is DEFERRED and COALESCED to the end of the
    /// current turn rather than written per departure: a board's unmount
    /// runs every row's `onDisappear` in one transaction, and a write per
    /// departure re-derived the memory from a shrinking set of rows so the
    /// last row to leave decided what she comes back to (measured on the
    /// naive shape: block 15 at 2 → block 24 at 506). By the end of that turn
    /// a teardown has left no rows to derive from and `teardown()` has
    /// closed the door; a scroll's departures and arrivals have all landed
    /// and the ONE re-derivation reads the rows as they are.
    func forgetArticleRowFrame(_ placementID: String) {
        board.forgetArticleRowFrame(placementID)
        guard !articleDepartureScheduled else { return }
        articleDepartureScheduled = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.articleDepartureScheduled = false
            guard !self.articleTornDown else { return }
            if case .remember(let place) = self.board.articleRowFramesMoved() {
                self.rememberArticlePlace(place)
            }
        }
    }

    /// One deferred re-derivation per turn, however many rows left in it.
    @ObservationIgnored private var articleDepartureScheduled = false
    /// Set by `teardown()`: the board is leaving, and nothing it sees on the
    /// way out is a place she was at.
    @ObservationIgnored private var articleTornDown = false

    /// The article reported its geometry: run the board's restore rule against
    /// the SESSION's memory and hand back the ONE thing the view can do about
    /// it. The memory write happens here, where the session is.
    func consumeArticleGeometry(
        _ geometry: TakesBoardLayout.ArticleGeometry, positionedByUser: Bool
    ) -> TakesBoardLayout.ArticleRestoreStep {
        let step = board.consumeArticleGeometry(
            geometry, remembered: rememberedArticlePlace,
            positionedByUser: positionedByUser,
            // The slot order, LAZILY and only once the projection has landed
            // (nil = not yet known, so a restore keeps aiming until it is):
            // a remembered row the note no longer holds settles at once
            // (R1-4).
            order: loaded ? projection.slots.map(\.placementID) : nil)
        if case .remember(let place) = step { rememberArticlePlace(place) }
        return step
    }

    /// The landing's next step, judged against the article's slots in their
    /// `ForEach` order (so an unrealized row can be aimed at by direction).
    /// The order is handed over LAZILY (the board's autoclosure): called from
    /// every realized row's frame report at scroll rate, and the O(N) map
    /// must not run when nothing is pending (R1-3, P1).
    func articleLandingStep() -> TakesBoardLayout.ArticleLandingStep {
        board.articleLandingStep(order: projection.slots.map(\.placementID))
    }

    /// 18l-b U2 — the view's REPORT roads (a row frame, the article's
    /// geometry): the step until the one landing authority is watching the
    /// landing, a report to it afterwards (`TakesArticleScroll
    /// .articleLandingReport`). Lazily ordered for the same P1 reason.
    func articleLandingReport() -> TakesBoardLayout.ArticleLandingStep {
        board.articleLandingReport(order: projection.slots.map(\.placementID))
    }

    /// 18l-b U2 — the watch's corrections; the view spends the step once each.
    var articleLandingCorrections: Int { board.articleLandingCorrections }

    /// How many aims the current landing issued (the pins' non-vacuity).
    var articleLandingAims: Int { board.articleLandingAims }


    /// **Where she left this note's article** — held at the SESSION, because
    /// this model dies with the mount and the memory must not
    /// (`EditorRouter.takesArticlePlaces`, beside Write's `scrollAnchors`).
    ///
    /// Gated on `landingEnabled`, which is true on THE takes board and false
    /// on the Write panel's embedded model: two surfaces sharing one note's
    /// remembered position would have them fighting over it.
    var rememberedArticlePlace: TakesBoardLayout.ArticlePlace? {
        guard landingEnabled else { return nil }
        return session.editorRouter.takesArticlePlaces[postID]
    }

    func rememberArticlePlace(_ place: TakesBoardLayout.ArticlePlace) {
        guard landingEnabled else { return }
        // Equality-gated: the rows re-derive the place at scroll rate now
        // (`noteArticleRowFrame`), and the session's dictionary should not
        // churn for a place that did not move.
        guard session.editorRouter.takesArticlePlaces[postID] != place else { return }
        session.editorRouter.takesArticlePlaces[postID] = place
    }

    /// **Which block is current on this board right now** — remembered for
    /// the session beside the place (17q piece 6, her ruling R-Q21: *"the
    /// same block"* means the note's current block did not CHANGE while she
    /// was away). The NEXT mount snapshots it at construction and asks
    /// whether its entry landing names a different block.
    ///
    /// Written at the TWO doors where this board's live pane becomes or
    /// changes — the entry ring (`landAuthorityFocus`) and a click that
    /// migrates it (`focus`'s `.migrated` arm) — never from the geometry
    /// hook: a click that moves the ring without scrolling the page must
    /// still count, or leaving right after it would read as "she moved
    /// blocks while away" when she moved them while here.
    ///
    /// Gated on `landingEnabled` exactly as the place is, so the Write
    /// panel's embedded model never writes into the board's memory.
    private func rememberArticleCurrentBlock(_ blockID: String) {
        guard landingEnabled else { return }
        guard let row = projection.slots.first(where: { $0.blockID == blockID })?.placementID
        else { return }
        session.editorRouter.takesArticleCurrentRows[postID] = row
    }

    /// What a pane rendering `variantID` is handed. Zero for every pane the
    /// room did not name, so nothing else in the board ever sees a change.
    func caretToEndToken(forVariant variantID: String) -> Int {
        caretToEndVariantID == variantID ? caretToEndCounter : 0
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
        // Her hand: an edit ends a pending article landing (17p batch a, J1).
        board.clearArticleLanding()
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
        clearStatus()
        do {
            // 17b P7 — `branchAllFans` mints each block's take from the
            // SHOWN take's `working_text` row, so the whole-post write
            // doors carry the same hazard as ⌘T and take the same road.
            let picks: [String: String] = try await session.runCopying(from: postID) { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            guard columns.count < 4 else { return }
            columns.append(TakesColumn(kind: .scratch, picks: picks, name: nextAutoName()))
            saveMemory()
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    func addLensColumn(_ lensID: String) {
        guard columns.count < 4 else { return }
        columns.append(TakesColumn(kind: .lens(lensID)))
        saveMemory()
    }

    /// What `showLens` did (13n-b U4 — pinned).
    enum LensShowing: Equatable {
        case alreadyShown, added, replacedLast
    }

    /// **Show THIS saved lens on the board** (13n-b U4 — `show_in_app`'s
    /// lens target and a receipt's "Open ›"; AF-11 F-3): its column if one
    /// already shows it; else a new column (her "+ Column → lens" door);
    /// else, with the board's four columns full, the LAST column swapped for
    /// it (her R83 replace-in-place door — PROVISIONAL P-13nb-U4-11). Her
    /// doors' own column ops, so the memory saves as hers do.
    @discardableResult
    func showLens(_ lensID: String) -> LensShowing {
        if columns.contains(where: { $0.kind == .lens(lensID) }) { return .alreadyShown }
        if columns.count < 4 {
            addLensColumn(lensID)
            return .added
        }
        guard let last = columns.last else { return .alreadyShown }
        replaceColumnWithLens(last.id, lensID: lensID)
        return .replacedLast
    }

    /// The router's parked lens landing, consumed if it is THIS note's
    /// (post-stamped — a landing for another note is left alone).
    func consumePendingLensLanding() {
        guard let landing = session.commandRouter.pendingLensLanding, landing.postID == postID else { return }
        session.commandRouter.pendingLensLanding = nil
        showLens(landing.lensID)
    }

    /// 13n-b U4: a takes landing parked while THIS board was already
    /// mounted (an agent's show at a block, a receipt's "Open ›") is
    /// consumed now against the current projection, rather than waiting for
    /// the next store write to deliver one.
    func consumePendingTakesLanding() {
        guard loaded, session.commandRouter.pendingTakesLanding?.postID == postID else { return }
        consumeLandings(projection)
    }

    func removeColumn(_ columnID: String) {
        guard columns.count > 1 else { return }
        columns.removeAll { $0.id == columnID }
        saveMemory()
    }

    // MARK: - Column slot swapping (R83: any column replaceable in place)

    func replaceColumnWithChosen(_ columnID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        rePointColumn(columnID) { columns[i] = TakesColumn(id: columnID, kind: .main) }
        saveMemory()
    }

    func replaceColumnWithLens(_ columnID: String, lensID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        rePointColumn(columnID) { columns[i] = TakesColumn(id: columnID, kind: .lens(lensID)) }
        saveMemory()
    }

    func replaceColumnWithNewScratch(_ columnID: String) {
        guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
        let name = nextAutoName()
        rePointColumn(columnID) { columns[i] = TakesColumn(id: columnID, kind: .scratch, name: name) }
        saveMemory()
    }

    /// **VX-227 — a column RE-POINTED BY MODEL STATE under the ring** (the
    /// sweep's slot-swap rows: no adoption carries these, so neither the
    /// step's follow nor `adopt`'s end-rule sees them). Measured on the
    /// current projection before and after `mutate`: when the ring's block now
    /// shows another take in that column, the ring ENDS (flushed — the
    /// pre-ruled end-rule for every road that is not a step; a swap that
    /// lands the column ON a stranded ring's take is the revival itself, so it
    /// ends too). `followBack` is for a re-point that is only TRANSIENT — a
    /// scratch saved as a lens shows the chosen take until the lens's own
    /// choices arrive — so the ring PARKS on its own key and re-binds when the
    /// cell shows that take again.
    private func rePointColumn(_ columnID: String, followBack: Bool = false, _ mutate: () -> Void) {
        let ring = authority.livePane.flatMap { $0.columnID == columnID ? $0 : nil }
        let before = ring.flatMap {
            stableCellTake(columnID: columnID, blockID: $0.blockID, in: projection)
        }
        mutate()
        // Rider 1: a follow parked in this column whose take the swap no
        // longer shows is over — the world moved on before the cell drew it.
        if let parked = parkedFollow, parked.columnID == columnID,
           stableCellTake(columnID: columnID, blockID: parked.blockID, in: projection)
               != parked.variantID {
            parkedFollow = nil
        }
        guard let ring else { return }
        let after = stableCellTake(columnID: columnID, blockID: ring.blockID, in: projection)
        guard after != before else { return }
        if followBack, before == ring.variantID {
            followOnceRendered(ring)
        } else {
            blur()
        }
    }

    func replaceColumnWithNewWrite(_ columnID: String) async {
        guard columns.contains(where: { $0.id == columnID }) else { return }
        clearStatus()
        do {
            // 17b P7 — `branchAllFans` mints each block's take from the
            // SHOWN take's `working_text` row, so the whole-post write
            // doors carry the same hazard as ⌘T and take the same road.
            let picks: [String: String] = try await session.runCopying(from: postID) { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            guard let i = columns.firstIndex(where: { $0.id == columnID }) else { return }
            let name = nextAutoName()
            rePointColumn(columnID) {
                columns[i] = TakesColumn(id: columnID, kind: .scratch, picks: picks, name: name)
            }
            saveMemory()
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    private func saveMemory() {
        TakesViewMemory(columns: columns, alignmentLocked: alignmentLocked)
            .save(postID: postID, defaults: defaults)
    }

    // MARK: - Discrete paging (session-only) — the board's, forwarded

    var pageOffsets: [String: Int] { board.pageOffsets }

    /// The clamped current offset for a key (limit = last legal offset).
    func pageOffset(_ key: String, limit: Int) -> Int {
        board.pageOffset(key, limit: limit)
    }

    func stepPage(_ key: String, by delta: Int, limit: Int) {
        board.stepPage(key, by: delta, limit: limit)
    }

    /// 13b 4D (S4-24(1) — the scroll+pager hybrid's write-back): a settled
    /// scroll addresses the SAME clamped offset the ◀ ▶ door writes — one
    /// paging brain, so the counter, the keyboard pager, and the scroll
    /// position can never disagree.
    func setPage(_ key: String, to offset: Int, limit: Int) {
        board.setPage(key, to: offset, limit: limit)
    }

    // MARK: - Expansion (session-only) — the board's, forwarded

    /// Every board gesture is HER HAND and ends a pending article landing
    /// (the 17p batch-a ladder, R1-2 — measured: a bloom on a row above the
    /// landed one grew the content, pushed the landed row below the fold, and
    /// the kept-alive request re-aimed the page 65 → 97 after her own click).
    /// The expansion doors and the Operations plumbing (`run` /
    /// `runCopying`) clear it here, beside the migrate and edit arms.
    func toggleExpanded(_ blockID: String) {
        board.clearArticleLanding()
        board.toggleExpanded(blockID)
    }

    /// Expand-all-fans (AppSpec §12): every FANNED block blooms, in the set
    /// style; fans stay open once expanded; close-all resets. The conductor
    /// supplies the projection's fanned set (the board never reads the
    /// projection).
    func expandAllFans() {
        board.clearArticleLanding()
        board.expandAll(
            fannedBlockIDs: Set(projection.slots.filter(\.hasFan).map(\.blockID)))
    }

    func closeAllFans() {
        board.clearArticleLanding()
        board.closeAllFans()
    }

    // MARK: - Gestures (every one an Operations call)

    /// ✓ — the explicit chooseVariant (I3's setter; the ONE per-slot door
    /// from visible to chosen).
    func choose(blockID: String, variantID: String) async {
        await run { ops in
            try ops.chooseVariant(blockID, variantID: variantID)
        }
    }

    /// Block drag-reorder — the structure controller's (13e round A, A-2).
    func reorderBlock(_ blockID: String, before targetBlockID: String?) async {
        await structure.reorderBlock(blockID, before: targetBlockID)
    }

    /// The Chosen column's own refusal (J38) — ONE copy, said by `pick` and by
    /// ⌃⌘←/→ on that column (VX-227's F3: it has no pick to step).
    nonisolated static let chosenColumnHasNoPickNote =
        "The main column shows the note's chosen takes — use ✓ to change them."

    /// A scratch/lens column adopts a different take for one slot (a VIEW
    /// change — never touches chosen).
    ///
    /// **VX-227 — every door that moves the pick under the ring FOLLOWS** (her
    /// R-VX214-1; the architect's F2/F4 rulings — ONE body, so ⌃⌘←/→, the
    /// column's ‹ › switcher and "Show take ▸" are one road): when the ring is
    /// in THIS column's pane for THIS block and the pick changes what the
    /// cell renders, the ring ends by the flushed `blur()` and PARKS on the
    /// newly picked take's key; it re-binds when the cell has RENDERED that
    /// key (`paneRendered`) — never in the same render that re-points the
    /// cell, which would keep the outgoing take's words live (see
    /// `stableCellTake`). A pick on a block or column the ring is not in
    /// leaves the ring alone.
    func pick(columnID: String, blockID: String, variantID: String) async {
        guard let index = columns.firstIndex(where: { $0.id == columnID }) else { return }
        let ringBefore = authority.livePane
        let follow: PaneKey? = ringBefore.flatMap { ring in
            guard ring.columnID == columnID, ring.blockID == blockID,
                  stableCellTake(columnID: columnID, blockID: blockID, in: projection) != variantID
            else { return nil }
            return PaneKey(
                columnID: columnID, blockID: blockID, variantID: variantID, context: ring.context)
        }
        switch columns[index].kind {
        case .main:
            // J38: nothing is picked here, so this is a REFUSAL — and since
            // 18i lets this class ride to the shell, the class now decides
            // whether she sees it at all (P-2).
            setRefusal(Self.chosenColumnHasNoPickNote)
        case .scratch:
            if let follow { followOnceRendered(follow) }  // BEFORE the cell re-points
            columns[index].picks[blockID] = variantID
            saveMemory()
        case .lens(let lensID):
            if let follow { followOnceRendered(follow) }  // BEFORE the store write
            // Named lenses are LIVE-edited (no explicit re-save).
            await run { ops in
                _ = try ops.setLensChoice(lens: lensID, block: blockID, variant: variantID)
            }
            // A refused pick moved nothing: the cell still renders the take
            // she was in, so the ring goes back there (a read→live flip of a
            // pane that already shows its own take — never a re-point).
            if let follow, status?.isRefusal == true, parkedFollow == follow,
               let ringBefore {
                focus(ringBefore)
            }
        }
    }

    /// DIVERGE HERE: edit-as-this-thread — mints a take branched from what
    /// the pane shows; the mint becomes VISIBLE where you are (never
    /// chosen). HOST-GATED (Stage 2 ladder round 2, R2-A sweep): on the
    /// Lenses host the column adopts the mint as its pick; on the TAKES
    /// host the cells carry board-local column IDs ("takes-main"/
    /// "takes-fan") that never live in `columns` — the old body's index
    /// guard silently NO-OPPED the cell menu's door there (the R112
    /// class, sweep-found) — so it routes through the takes reveal (fan
    /// opens, ring on the mint).
    @discardableResult
    func divergeHere(columnID: String, blockID: String, fromVariantID: String) async -> Variant? {
        switch host {
        case .takes:
            return await branchTakeRevealed(
                blockID: blockID, from: fromVariantID, preferredColumnID: columnID)
        case .lenses:
            return await branchIntoColumn(
                columnID: columnID, blockID: blockID, fromVariantID: fromVariantID)
        }
    }

    /// The Lenses-side branch core (the old `divergeHere` body): the mint
    /// lands as the COLUMN's pick — named lenses live-edit in the same
    /// serialized breath — and the ring follows onto the pane that now
    /// renders it (R2-A: never stranded on the replaced key).
    private func branchIntoColumn(
        columnID: String, blockID: String, fromVariantID: String
    ) async -> Variant? {
        guard let index = columns.firstIndex(where: { $0.id == columnID }) else { return nil }
        let kind = columns[index].kind
        clearStatus()
        do {
            // 17b P7 — the Lenses-side branch mints a copy too (see
            // `branchTake`): flush the pane's keystrokes before the row is
            // read.
            let take: Variant = try await session.runCopying(from: postID) { ops in
                let take = try ops.branchVariant(blockID, from: fromVariantID)
                if case .lens(let lensID) = kind {
                    // Named lenses are LIVE-edited: the thread's pick
                    // moves in the same breath.
                    _ = try ops.setLensChoice(lens: lensID, block: blockID, variant: take.id)
                }
                return take
            }
            adoptMintIntoColumn(
                columnID: columnID, kind: kind, blockID: blockID, variantID: take.id)
            return take
        } catch {
            setRefusal(Self.message(for: error))
            return nil
        }
    }

    /// The Lenses-side blank core (⌥⌘T's column half — R2-A: ONE brain
    /// with the branch core; the old keyboard door minted via
    /// `newBlankTake` then `pick`, which on the Chosen column REFUSED the
    /// pick after minting — an invisible take plus a lecture, the R112
    /// class. Both mint gestures now agree: a mint into the Chosen column
    /// starts a scratch thread, chosen never moves without ✓).
    private func blankIntoColumn(columnID: String, blockID: String) async -> Variant? {
        guard let index = columns.firstIndex(where: { $0.id == columnID }) else { return nil }
        let kind = columns[index].kind
        clearStatus()
        do {
            let take: Variant = try await session.runner.run { ops in
                let take = try ops.newBlankVariant(blockID)
                if case .lens(let lensID) = kind {
                    _ = try ops.setLensChoice(lens: lensID, block: blockID, variant: take.id)
                }
                return take
            }
            adoptMintIntoColumn(
                columnID: columnID, kind: kind, blockID: blockID, variantID: take.id)
            return take
        } catch {
            setRefusal(Self.message(for: error))
            return nil
        }
    }

    /// The column's adoption of a fresh mint + the ring-follow (shared by
    /// the branch and blank cores).
    ///
    /// **VX-227 (the architect's F6 ruling):** the ring-follow goes through
    /// the PARKED FOLLOW, parked BEFORE the column re-points. It used to
    /// `focus` the mint's key in the same turn the pick moved — a live
    /// re-point of the column's stable cell, which keeps the SOURCE take's
    /// words under the fresh take's key (invisible for a branch, whose text
    /// is a copy; a blank mint's first keystroke wrote the source's words
    /// into it). A fresh mint is never what the cell already renders, so the
    /// park is unconditional; the ring re-binds once the cell shows the mint.
    private func adoptMintIntoColumn(
        columnID: String, kind: TakesColumnKind, blockID: String, variantID: String
    ) {
        followOnceRendered(PaneKey(columnID: columnID, blockID: blockID, variantID: variantID))
        if let i = columns.firstIndex(where: { $0.id == columnID }) {
            switch kind {
            case .main:
                // Diverging the main column starts a scratch thread —
                // chosen never moves without ✓.
                columns[i].kind = .scratch
                if columns[i].name == nil { columns[i].name = nextAutoName() }
                columns[i].picks[blockID] = variantID
                saveMemory()
            case .scratch:
                columns[i].picks[blockID] = variantID
                saveMemory()
            case .lens:
                break  // the store carries it; the projection follows
            }
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
        clearStatus()
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                let lens = try ops.createLens(post: postID, name: name)
                for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                    _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            if let i = columns.firstIndex(where: { $0.id == columnID }) {
                // VX-227: until the lens's choices arrive by adoption the
                // column reads the chosen takes — a transient re-point under
                // a ring in it, so the ring parks on its own key and comes
                // back when the cell shows that take again.
                rePointColumn(columnID, followBack: true) {
                    columns[i].kind = .lens(lens.id)
                    columns[i].picks = [:]
                }
                saveMemory()
            }
            return lens
        } catch {
            setRefusal(Self.message(for: error))
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
        clearStatus()
        do {
            let preservation: Lens
            switch column.kind {
            case .main:
                setRefusal("This column IS the note — nothing to adopt.")  // J38
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
            setReceipt(
                "Adopted — the note now shows this column. The old chosen is kept as the lens “\(preservation.name)”."
            )
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    /// ⧉ "Make this a post" per column: a lens column promotes; a SCRATCH
    /// column promotes DIRECTLY from its picks (R78 — the forced
    /// save-as-lens step is retired; `keepAsLens` optionally saves the way
    /// of looking too); the main column duplicates (the post exactly as it
    /// is). Fans ride by default, chosen-only offered at the gesture.
    func promoteColumn(_ columnID: String, carryFans: Bool = true, keepAsLens: Bool = false) async {
        guard let column = columns.first(where: { $0.id == columnID }) else { return }
        clearStatus()
        switch column.kind {
        case .main:
            await duplicateAsVersion()
        case .lens(let lensID):
            // 13e E10: `promoteLens` copies the post the lens belongs to —
            // the same class as the duplicate door, so the same entry.
            await runCopying { ops in _ = try ops.promoteLens(lensID, carryFans: carryFans) }
        case .scratch:
            let picks = column.picks
            let lensName = column.name ?? "Lens"
            do {
                // 13e E10: `promotePicks` is a post copy too — the row named
                // two doors; the family is what the sweep found.
                let promoted: Operations.PostCopyResult = try await session.runCopying(
                    from: postID
                ) { [postID] ops in
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
                setReceipt(
                    "Made a new note — “\(promoted.post.title ?? "untitled")” is now its own note, linked as a version."
                )
            } catch {
                setRefusal(Self.message(for: error))
            }
        }
    }

    /// 13e E10: the copy family's flush-first entry, like every other copy
    /// door — this board's panes are live editors, so the buffer under the
    /// ring is exactly the text a duplicate would otherwise miss.
    func duplicateAsVersion() async {
        await runCopying { [postID] ops in _ = try ops.duplicateAsVersion(postID) }
    }

    /// "Write new takes on every block" from the TAKES tab (R82: the door
    /// lives in both tabs): mints the takes into each block's fan — no
    /// column, no lens — and says what happened.
    func writeNewTakesEverywhere() async {
        clearStatus()
        do {
            // 17b P7 — `branchAllFans` mints each block's take from the
            // SHOWN take's `working_text` row, so the whole-post write
            // doors carry the same hazard as ⌘T and take the same road.
            let picks: [String: String] = try await session.runCopying(from: postID) { [postID] ops in
                try ops.branchAllFans(post: postID)
            }
            // J38's milder sibling, the J37 class: `branchAllFans` returns
            // `[:]` without throwing on a post with no renderable slots, so
            // this line is producible with NOTHING written — and a report of
            // a no-op is a refusal, whatever its shape. ONE predicate; the
            // words are untouched (a sentence for the zero case would be new
            // copy, which is hers).
            let wrote = !picks.isEmpty
            let note =
                "New takes written on \(picks.count) block\(picks.count == 1 ? "" : "s") — open any fan to see them, or open them side by side in Lenses."
            wrote ? setReceipt(note) : setRefusal(note)
        } catch {
            setRefusal(Self.message(for: error))
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
        clearStatus()
        do {
            let lens: Lens = try await session.runner.run { [postID] ops in
                let lens = try ops.createLens(post: postID, name: name)
                for (blockID, variantID) in shown {
                    _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            setReceipt("Saved — “\(lens.name)” now remembers these choices.")
        } catch {
            setRefusal(Self.message(for: error))
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
        clearStatus()
        do {
            // **17b P7 — FLUSH FIRST.** `branchVariant` copies the source's
            // `working_text` ROW inside its transaction, and a live pane
            // holds keystrokes in the autosave debounce for up to 500 ms —
            // so a ⌘T pressed mid-sentence used to mint a copy of the text
            // as it stood before it, and the ring then moved onto that
            // card. OverallModel §3 says branching inherits the CURRENT
            // buffer, and Write's twin (`EditorViewModel.mintCaretTake`)
            // has always awaited `flushNow()` first; this is the same
            // gesture meaning the same thing on the boards.
            return try await session.runCopying(from: postID) { ops in
                try ops.branchVariant(blockID, from: variantID)
            }
        } catch {
            setRefusal(Self.message(for: error))
            return nil
        }
    }

    /// "＋ blank take" — the genuinely-different-take gesture. Minting
    /// NEVER chooses (R90: "as you go through and fill items in, it can be
    /// selected"); the new card gets the ring so you're typing instantly.
    @discardableResult
    func newBlankTake(blockID: String) async -> Variant? {
        clearStatus()
        do {
            return try await session.runner.run { ops in
                try ops.newBlankVariant(blockID)
            }
        } catch {
            setRefusal(Self.message(for: error))
            return nil
        }
    }

    // MARK: - Fan ORDER (13e E4 — her A19: "Reorder takes")

    /// Move a take one place earlier or later in its block's fan — the
    /// structure controller's (13e round A, A-2).
    func moveTake(_ variantID: String, in blockID: String, by delta: Int) async {
        await structure.moveTake(variantID, in: blockID, by: delta)
    }

    // MARK: - Take ↔ block structure (13e batch 3 — her A20/A21, AR-1)

    /// Her A20 on the boards — the structure controller's (13e round A, A-2).
    func moveTakeIntoBlockBelow(blockID: String? = nil, variantID: String? = nil) async {
        await structure.moveTakeIntoBlockBelow(blockID: blockID, variantID: variantID)
    }

    /// Her A21's second half (the A45 repair) — the controller's.
    func turnTakesIntoBlocks(blockID: String? = nil) async {
        await structure.turnTakesIntoBlocks(blockID: blockID)
    }

    // MARK: - Copy all takes (13e E6 — her A21's clipboard half)

    /// *"keyboard shortcut for copying all takes together to clipboard"* —
    /// the target block's whole fan as text, in the app's own ratified export
    /// shape (`TakeClipboard`, the one brain both editors' doors use).
    ///
    /// FLUSHES FIRST so the clipboard carries what she SEES: the projection
    /// reads the store, and a dirty buffer means the store is a keystroke
    /// behind the card. A refused flush stops the act (13c R2-6's
    /// one-act-one-contract rule) rather than copying stale prose silently.
    /// `blockID` names the target explicitly where a caller knows it (a
    /// right-click does not move the keyboard — 13k K6's lesson); nil uses the
    /// standing routed target.
    func copyAllTakes(
        blockID: String? = nil, to destination: TakeClipboard.Destination = .general
    ) async {
        guard let targetID = blockID ?? commandTargetSlot?.blockID else {
            refuse("Click into a block first — this copies that block's takes.")
            return
        }
        guard await flushPendingText() else { return }
        // J43's batch call: the SAME `Outcome` Write's door speaks, through
        // the same predicate — a copy that landed is a receipt on both
        // surfaces, so one sentence cannot carry two classes.
        let outcome = await TakeClipboard.copyBlock(
            targetID, session: session, to: destination)
        outcome.isRefusal ? refuse(outcome.message) : setReceipt(outcome.message)
    }

    // MARK: - The merge selection (13e E3 — her A18)

    /// The ⌘-clicked blocks — the board layout's, forwarded (session-only
    /// view state, like expansion).
    var mergeSelection: Set<String> { board.mergeSelection }

    /// Her hand (the 17p batch-a ladder, R3-1): a pick summons the selection
    /// banner ABOVE the article, which shrinks the article's VIEWPORT by the
    /// banner's height — so a landed row at the foot reads as clipped and a
    /// kept-alive landing revealed it again after her click (measured: 65 →
    /// 93, the banner's 28 pt; the same pick with no landing moves nothing).
    /// The ⌘-click deliberately never migrates the ring (picking blocks is
    /// not writing in one), so the arm sits at the two PICK doors — never at
    /// `clearMergeSelection`, which the structure controller shares after a
    /// merge, a split or a delete, and whose banner LEAVING can clip nothing.
    func toggleMergeSelection(_ blockID: String) {
        board.clearArticleLanding()
        board.toggleMergeSelection(blockID)
    }

    /// ⌘⇧-click (13e E2): extend the run from the anchor, in the POST's
    /// order. The order comes from the projection because this is the
    /// SELECTION, not an act — naming what she is pointing at is exactly
    /// what a projection is for; every act below still re-reads the store.
    func extendMergeSelection(to blockID: String) {
        board.clearArticleLanding()   // her hand (R3-1, as above)
        board.extendMergeSelection(to: blockID, in: projection.slots.map(\.blockID))
    }

    func clearMergeSelection() {
        board.clearMergeSelection()
    }

    func isSelectedForMerge(_ blockID: String) -> Bool {
        board.isSelectedForMerge(blockID)
    }

    /// The selection in the POST's order (the projection's slot order) — what
    /// the banner counts and what the merge walks.
    var selectedBlocksInOrder: [String] {
        projection.slots.map(\.blockID).filter { board.mergeSelection.contains($0) }
    }

    /// Her A18's merge over the ⌘-click selection — the structure
    /// controller's (13e round A, A-2).
    func mergeSelectedBlocks(bringEveryTake: Bool = true) async {
        await structure.mergeSelectedBlocks(bringEveryTake: bringEveryTake)
    }

    /// Her A17's multi-delete over the same selection — the controller's.
    func deleteSelectedBlocks() async {
        await structure.deleteSelectedBlocks()
    }

    // MARK: - Take lifecycle (the retired FanPanel's doors, kept — R87:
    // one grammar everywhere, refusals speak)

    /// 13b Stage 3 (3D — N1/R118): every archive door speaks the road
    /// BACK, and the road it names lives right here in Takes (the
    /// archived listing under the block's takes). Host-gated copy: the
    /// Lenses board renders no archived list, so it points at the Takes
    /// board instead of promising a door it doesn't have.
    func archiveTake(_ variantID: String) async {
        await run { ops in try ops.archiveVariant(variantID) }
        if status == nil {
            switch host {
            case .takes:
                setReceipt("Take archived — never gone: "
                    + "\u{201C}archived \u{B7} n\u{201D} under this block's takes brings it back.")
            case .lenses:
                setReceipt("Take archived — never gone: the archived list "
                    + "under this block's takes on the Takes board (\u{2318}2) brings it back.")
            }
        }
    }

    func unarchiveTake(_ variantID: String) async {
        await run { ops in try ops.unarchiveVariant(variantID) }
        if status == nil {
            setReceipt("Take unarchived — back in the block's fan.")
        }
    }

    // MARK: - 13j J5 — the lens's dangling pick, said out loud

    /// The pick a lens column MADE for this slot and can no longer show
    /// (`Queries.danglingLensPicks`), or nil where the column is showing what
    /// it picked. Only LENS columns — because 13j's J5 ruling, as recorded,
    /// is scoped to a SAVED lens's pick; NOT because a scratch pick cannot
    /// dangle. It can: a scratch column's picks (`column.picks`) are
    /// PERSISTED per note in the local view memory (`TakesViewMemory`,
    /// written by `saveMemory()` on every pick), nothing prunes them when the
    /// picked take is archived or deleted, and `resolvedTake` then falls
    /// through to the slot's chosen take with nothing said — across
    /// relaunches. That gap is NAMED for her, not built: QUESTIONS #160
    /// (18o U1, 17e P32 — this line used to claim scratch picks are never
    /// stored).
    func danglingPick(columnID: String, slot: Queries.RenderedBlock) -> Queries.DanglingPick? {
        guard let column = columns.first(where: { $0.id == columnID }),
              case .lens(let lensID) = column.kind
        else { return nil }
        return projection.lensDangles[lensID]?[slot.blockID]
    }

    /// **The one-click Restore** her ruling asked for, routed to the right
    /// door by the pick's actual state: an ARCHIVED take comes back through
    /// `unarchiveVariant` — the road that has shipped since 13b Stage 3 and
    /// is what the archived listing's own Unarchive button calls — and a
    /// DELETED one through 13j's `restoreVariant`. A pick with no row, or one
    /// pointing at another block's take, has nothing this surface can
    /// honestly restore, and its notice renders without the button.
    func restoreDanglingPick(_ pick: Queries.DanglingPick) async {
        switch pick.state {
        case .archived:
            await run { ops in try ops.unarchiveVariant(pick.variantID) }
            if status == nil {
                setReceipt(LensFallbackCopy.restoredArchived)
            }
        case .deleted:
            // 13j ladder A round 1, finding A3: the restore is an exact flip
            // (#68(b), ruled), so a take ARCHIVED when it was deleted comes
            // back archived — the pick then STILL dangles (as `.archived`,
            // Restore now offering unarchive) and "showing its pick again"
            // would be false. The receipt reads the op's own answer.
            clearStatus()
            do {
                let restored = try await session.runner.run { ops in
                    try ops.restoreVariant(pick.variantID)
                }
                setReceipt(restored == .archived
                    ? LensFallbackCopy.restoredDeletedButArchived
                    : LensFallbackCopy.restoredDeleted)
            } catch {
                setRefusal(Self.message(for: error))
            }
        case .gone, .foreign:
            setRefusal(LensFallbackCopy.nothingToRestore)  // J38: nothing restored
        }
    }

    // MARK: - The archived listing (13b Stage 3, 3D — N1: the road back
    // lives in Takes). The fans query stays ACTIVE-ONLY by design; the
    // archived listing is its own read, refreshed by the board view at
    // projection cadence (the WriteTakesPanel precedent) — cost ∝ the
    // post's blocks (one indexed query), P1-shaped.

    /// Archived-take counts per block — the "archived · n" door's truth.
    private(set) var archivedCounts: [String: Int] = [:]
    /// The archived takes themselves, fan-ordered, for every counted block
    /// (author-scale small: archived rows per post).
    private(set) var archivedTakes: [String: [Variant]] = [:]
    /// Blocks whose archived listing is open (session-only, like blooms).
    private(set) var revealedArchived: Set<String> = []

    func toggleArchivedRevealed(_ blockID: String) {
        if revealedArchived.contains(blockID) {
            revealedArchived.remove(blockID)
        } else {
            revealedArchived.insert(blockID)
        }
    }

    /// One read for counts + rows over the post's live blocks. The view
    /// calls this on appearance and at projection cadence; tests call it
    /// directly (the observation never fires under the test host).
    func refreshArchived() async {
        let blockIDs = projection.slots.map(\.blockID)
        guard !blockIDs.isEmpty else {
            if !archivedCounts.isEmpty { archivedCounts = [:] }
            if !archivedTakes.isEmpty { archivedTakes = [:] }
            return
        }
        let rows: [Variant] = (try? await session.database.read { db in
            try Variant
                .filter(
                    blockIDs.contains(Column("block_id"))
                        && Column("deleted_at") == nil
                        && Column("status") == VariantStatus.archived.rawValue)
                .order(Column("fan_position"), Column("id"))
                .fetchAll(db)
        }) ?? []
        let grouped = Dictionary(grouping: rows, by: \.blockId)
        archivedTakes = grouped
        archivedCounts = grouped.mapValues(\.count)
    }

    // MARK: - Take labels (13b Stage 3, 3D — N6: the 3B op's faces)

    /// The label prompt's payload (model-driven sheet — the
    /// `commentsRequest` pattern; the bar hosts the sheet on both boards).
    struct TakeLabelRequest: Identifiable, Equatable {
        let variantID: String
        let currentLabel: String?
        var id: String { variantID }
    }

    var takeLabelRequest: TakeLabelRequest?

    /// Opens the label prompt for a take (card menu / bar block-menu).
    func requestTakeLabel(variantID: String) {
        takeLabelRequest = TakeLabelRequest(
            variantID: variantID, currentLabel: currentLabel(of: variantID))
    }

    private func currentLabel(of variantID: String) -> String? {
        for (_, fan) in projection.fans {
            if let take = fan.first(where: { $0.id == variantID }) {
                return take.label
            }
        }
        for (_, archived) in archivedTakes {
            if let take = archived.first(where: { $0.id == variantID }) {
                return take.label
            }
        }
        return nil
    }

    /// The op call (empty clears — the core trims and NULLs).
    func setTakeLabel(_ variantID: String, label: String?) async {
        await run { ops in try ops.setTakeLabel(variantID, label: label) }
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

    /// **THE COMMIT DOOR'S PENDING NAME** (13u3 UNIT D — item 14). The bar
    /// presents it at the commit door; Takes and Lenses share this model, so
    /// one slot serves both surfaces exactly as one bar does.
    var savepointAsk: SavepointNameAsk?

    /// ⌘S and the bar's commit button — the DOOR. It summons the optional
    /// name; ⏎ on the empty field files what ⌘S has always filed. Where no
    /// take is focused the door refuses HERE, before a field opens over a
    /// gesture that cannot land (P-2).
    func askSavepointName() {
        guard let variantID = focusedPane?.variantID else {
            setRefusal("Click into a take first — ⌘S commits the take you're in.")  // J38
            return
        }
        // 13u3 ladder round 1, R1-3 (the implementer's widen, confirmed):
        // `focusedPane` is the RAW `authority.livePane` — a click under a
        // seal still sets it (`focus` has no seal test; `isPaneLive` is where
        // the seal lives) — so without this the field opened over a commit
        // the filer refuses. Same sentence as the post-⏎ road's.
        guard !projection.sealed else {
            setRefusal(OpsRefusalCopy.message(for: OperationError.lockedPost(id: postID)))
            return
        }
        savepointAsk = .naming(variantID: variantID)
    }

    func fileSavepoint(named name: String?) async {
        savepointAsk = nil
        await commitFocusedTake(named: name)
    }

    /// Commit the FOCUSED take's buffer (⌘S in takes surfaces), optionally
    /// named. Everything but the name is byte-unchanged, which is why the
    /// shipped pins on this road ride unmodified.
    func commitFocusedTake(named name: String? = nil) async {
        guard let variantID = focusedPane?.variantID else {
            setRefusal("Click into a take first — ⌘S commits the take you're in.")  // J38
            return
        }
        await autosave.flushNow()
        await run { ops in _ = try ops.commit(variantID, message: name) }
        if status == nil {
            setReceipt(name.map(SavepointNameCopy.filed) ?? SavepointNameCopy.unnamedReceipt)
        }
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

    // MARK: - The one_block face (13b 4D — N34, S4-14/S4-21)

    /// Whether newlines mint blocks in this post (the EFFECTIVE
    /// segmentation ≠ one_block) — the bar chip's truth. Refreshed by the
    /// bar at projection cadence and by the setter (a segmentation change
    /// alone doesn't move the takes projection, so the observation can't
    /// carry it; an external change catches up at the next projection —
    /// recorded).
    private(set) var newlinesMintBlocks = true
    /// 13b 4F (N36): the per-post word target, for the bar's face — same
    /// refresh cadence as the segmentation chip (the bar re-reads at
    /// projection cadence and the setter refreshes itself; an external
    /// change catches up at the next projection — recorded).
    private(set) var postWordTarget: Int?

    func refreshSegmentation() async {
        // ONE header read now carries BOTH bar facts (4F: + the target).
        let header = (try? await session.database.read { [postID] db in
            try Queries.containerHeader(db, containerID: postID)
        }) ?? nil
        if let header {
            newlinesMintBlocks = header.effectiveSegmentation != .oneBlock
            postWordTarget = header.wordTarget
        }
    }

    /// The one_block face — a door over the Phase-1 machinery
    /// (`setSegmentationDefault`, Phase 2; NO semantics change: `one_block`
    /// is entry-wide — typing and paste — by the model's standing meaning,
    /// S4-21 ratified). ON ⇒ per-post nil (inherit the global default);
    /// OFF ⇒ `.oneBlock`. Allowed under seal (the container-row metadata
    /// class; entry itself refuses under seal anyway).
    func setNewlinesMintBlocks(_ mint: Bool) async {
        await run { [postID] ops in
            try ops.setSegmentationDefault(postID, segmentation: mint ? nil : .oneBlock)
        }
        await refreshSegmentation()
        if status == nil {
            // 13d batch 4 (A16): the refresh has just re-read the EFFECTIVE
            // mode, so the note describes what the post now does rather than
            // what was asked for — turning ON under a global one_block
            // clears the override and still doesn't mint.
            setReceipt(SegmentationFaceCopy.note(
                asked: mint, effectivelyMints: newlinesMintBlocks))
        }
    }

    /// 13b 4F (N36 — S4-28.1): the per-post word target's Takes/Lenses
    /// half (R118 parity with Write's). Refusals — the sealed post's
    /// PROVISIONAL refuse among them — speak through the standing door.
    func setPostWordTarget(_ target: Int?) async {
        await run { [postID] ops in
            try ops.setPostWordTarget(postID, wordTarget: target)
        }
        await refreshSegmentation()
        if status == nil {
            setReceipt(target.map(WordTargetFaceCopy.setNote)
                ?? WordTargetFaceCopy.clearNote)
        }
    }

    /// R84's note condition: the daily-journal SHAPE (profile journal +
    /// entry date) — the day's entry, where sync conflicts land as takes.
    var isJournalShaped: Bool {
        projection.profile == .journal && projection.entryDate != nil
    }

    /// The bar's speaking surface (9d fire-and-speak — a message, never a
    /// dead key).
    ///
    /// **It classes as a REFUSAL** (the post-13l polish round, batch 5 —
    /// routed flag 2), and that is what it has always been: fire-and-speak
    /// exists for the door that *cannot act in its context* and must say why
    /// rather than sit grey (P-2). Every one of its callers is such a
    /// sentence — *"Click into a block first…"*, *"This block has no
    /// renderable take to divide."*, the registry's own unavailable notes.
    /// A door that DID something reports through `setReceipt`.
    func refuse(_ message: String) {
        setRefusal(message)
    }

    /// **A RECEIPT — an act LANDED and this says what.** The seam primitive
    /// the structure controller speaks through (13e round A, A-2).
    ///
    /// *(13u2 UNIT E — row 56: it was `setReceipt(_ message: String?)`, a name
    /// that said nothing about its class while being one of the two doors
    /// step 2 makes load-bearing. Shipping "these are the only writers" with
    /// one of them not naming its class would have recorded the defect rather
    /// than fixed it. Its `nil` case — clear the line before an act — is
    /// `clearStatus()` below, because "set a receipt to nothing" was never
    /// what that call meant.)*
    func setReceipt(_ message: String) {
        statusSlot = .receipt(message)
    }

    /// …and its REFUSAL twin (routed flag 2). A door that ran an operation and
    /// was told no says so in a refusal's voice — which is the whole point of
    /// deciding the class where the message is produced.
    func setRefusal(_ message: String) {
        statusSlot = .refusal(message)
    }

    /// **Clear the line before an act** — exactly as the pre-move bodies did,
    /// and said out loud rather than spelled `clearStatus()`.
    func clearStatus() {
        statusSlot = nil
    }

    /// 13f W10b — the lineage door's act, identical to Write's, and given its
    /// THIRD and final landing with it at the post-13l polish round (ledger
    /// row 17): the block's History pane, whose came-from region shows ALL of
    /// a merge's originals rather than the first.
    /// `EditorViewModel.revealCaretBlockOrigin` carries the whole history.
    ///
    /// The blockID is named EXPLICITLY by the card that raised it — a
    /// right-click never moves the keyboard, so a routed target could name
    /// another card's block (13k K6's lesson, same fix).
    func revealOriginBlock(ofBlock blockID: String) {
        requestBlockHistory(blockID: blockID)
    }

    /// The ⌘K row's body on the boards: the focused block's original, or the
    /// honest note where it has none (fire-and-speak — Write's twin).
    func revealFocusedBlockOrigin() {
        guard let slot = commandTargetSlot,
              projection.unplacedOrigins[slot.blockID]?.isEmpty == false
        else {
            refuse(OriginPeekCopy.noOriginHere)
            return
        }
        revealOriginBlock(ofBlock: slot.blockID)
    }

    /// **The Block History pane's pending target** (ledger row 17) — the
    /// router first, this bar's sheet as the fallback. Write's twin carries
    /// the reasoning; the only difference here is which block is "the one
    /// you're in".
    var blockHistoryRequest: BlockHistoryRequest?

    func requestBlockHistory(blockID: String? = nil) {
        guard let slot = blockID.flatMap({ id in
            projection.slots.first { $0.blockID == id }
        }) ?? commandTargetSlot else {
            refuse(CapabilityRegistry.capability(.showBlockHistory).unavailableNote)
            return
        }
        let request = BlockHistoryRequest(
            postID: postID, blockID: slot.blockID,
            focusedVariantID: focusedPane?.blockID == slot.blockID
                ? focusedPane?.variantID : slot.variantID)
        if session.commandRouter.requestBlockHistory(request) { return }
        blockHistoryRequest = request
    }

    /// 13j J2: the tray sheet's pending target (`TakesBottomBar` presents
    /// it, where the comments sheet lives).
    var trayRequest: TrayRequest?

    /// A door onto this note's tray — the router first (its home is the post
    /// detail's side panel since her C1 ruling), this bar's sheet as the
    /// fallback for hosts with no inspector. `EditorViewModel`'s twin carries
    /// the full reasoning.
    func requestNoteTray() {
        let request = TrayRequest(postID: postID)
        if session.commandRouter.requestNoteTray(request) { return }
        trayRequest = request
    }

    /// **The Versions pane** (ledger rows 16/23) — the router first, this bar's
    /// sheet as the fallback. Write's twin carries the reasoning.
    var versionsRequested = false

    func requestNoteVersions() {
        if session.commandRouter.requestNoteVersions(postID: postID) { return }
        versionsRequested = true
    }

    /// **⌘⇧S — save the whole note as it is** (Write's twin, same composition).
    func saveNoteVersion() async {
        do {
            setReceipt(try await VersionActs.save(session: session, postID: postID))
        } catch {
            setRefusal(VersionActs.words(error, seal: .mac))
        }
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

    /// The choreographer's act vocabulary (13b Stage 3, N10); the alias
    /// keeps every `TakesViewModel.MoveAndExecuteAct` reference unchanged.
    typealias MoveAndExecuteAct = TakesChoreographer.MoveAndExecuteAct

    /// The ONE mode-switch choreography's takes-side half — the
    /// choreographer's (13b Stage 3, N10); forwarded so every routed door
    /// and pin reads unchanged.
    func moveToWriteAndRun(_ act: MoveAndExecuteAct) {
        choreography.moveToWriteAndRun(act)
    }

    // MARK: - The structural doors (13d Batch 3, A9)
    //
    // 13e round A (A-2): the bodies live in `TakesStructureController` now;
    // these forwards keep every call site and pin naming the model.

    /// THE structural door for both boards: divide acts NATIVELY here;
    /// extract, make-block and merge keep the carry choreography.
    func runStructuralDoor(_ act: StructuralAct) {
        structure.runStructuralDoor(act)
    }

    /// A9's native divide, in place. 13j J4: the default cuts (plain on an
    /// unfanned block, the DUPLICATING shape on a fanned one) and
    /// `ceremony: true` is ⌥⌘⇧D's road onto the same sheet as before.
    func divideFocused(ceremony: Bool = false) async {
        await structure.divideFocused(ceremony: ceremony)
    }

    /// The single-entry planner world over the take the caret is in —
    /// forwarded so the PARITY PIN keeps driving it through the model
    /// (`theTakesWorldAndWritesWorldPlanAlike`).
    func divideWorld(
        slot: Queries.RenderedBlock, take: Variant, arity: Int
    ) -> StructuralGesturePlanner.World {
        structure.divideWorld(slot: slot, take: take, arity: arity)
    }

    /// D3's third leg — the add-block door, NATIVE in Takes/Lenses (the
    /// structure controller's, 13e round A, A-2).
    func addBlockAtEnd() async {
        await structure.addBlockAtEnd()
    }

    /// N28's insert-below door — the controller's.
    func insertBlockBelowFocused() async {
        await structure.insertBlockBelowFocused()
    }

    /// A8's delete-block door where takes live — the controller's.
    func deleteFocusedBlock() async {
        await structure.deleteFocusedBlock()
    }

    /// 13j (her round-7 ruling): the archive door beside it, same controller.
    func archiveFocusedBlock() async {
        await structure.archiveFocusedBlock()
    }

    /// 18c batch 3 (her U-6) — the board's three doors onto the newline
    /// repair, forwarded (the machinery is the controller's).
    func splitEveryNewlineIntoBlocks() async {
        await structure.splitEveryNewlineIntoBlocks()
    }

    func splitFocusedBlockAtNewlines() async {
        await structure.splitFocusedBlockAtNewlines()
    }

    func splitSelectedBlocksAtNewlines() async {
        await structure.splitSelectedBlocksAtNewlines()
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
            refuse("Click into a block first — comments live on the block you're in.")
            return
        }
        commentsRequest = CommentsRequest(blockID: slot.blockID)
    }

    /// **13k K9 — the frame a block's takes region wears**, or nil where the
    /// block is plain.
    ///
    /// Her instruction was *"callouts are supposed to be added to take mode
    /// as well"*: the door has routed from the boards since 13c R2-2, but
    /// the FRAME drew only in Write's `BlockDecor` overlay, so setting one
    /// here changed nothing you could see. The ruled shape is ONE frame
    /// around the block's whole takes region — one block, one frame, takes
    /// inside it (R16/R27's letter: the frame is the BLOCK's and its takes
    /// share it, which is exactly why it is never per-card).
    ///
    /// The `kind` check is the same fail-open rule the editor's overlay
    /// applies: a future non-callout presentation kind draws nothing here
    /// rather than being drawn as a callout.
    func calloutFrame(_ blockID: String) -> BlockPresentation? {
        guard let presentation = projection.presentations[blockID],
              presentation.kind == BlockPresentation.calloutKind
        else { return nil }
        return presentation
    }

    /// 13c Stage 1 ladder, R2-2 (her A13(a) — *"callouts in Takes/Compare/
    /// Lenses"*): the callout door where takes live, NATIVE. A frame is the
    /// BLOCK's and takes share it (R16/R27), so the surface that knows
    /// which block you are in can set it — Write was privileged only by
    /// where the door was first hung (R118). Same target rule as every
    /// other block-scoped act here, and the ONE shared transform. Sealed
    /// posts refuse through the op, spoken.
    ///
    /// `blockID` names the target EXPLICITLY where the caller knows it —
    /// 13k K6's card right-click does, and it has to: a right-click does not
    /// move the keyboard, so `commandTargetSlot` would still name whichever
    /// card was last focused and the frame would land on the wrong block.
    /// nil keeps the routed door's long-standing behaviour byte-for-byte.
    func applyCallout(_ edit: CalloutEdit, blockID: String? = nil) async {
        guard let target = blockID ?? commandTargetSlot?.blockID else {
            refuse("Click into a block first — the frame goes on the block you're in.")
            return
        }
        clearStatus()
        // Her hand (the 17p batch-a ladder, R2-1): a frame pads the row it
        // lands on — above a landed row, the kept-alive landing re-aimed
        // (measured 65 → 75 after her menu pick); a bare-runner road with no
        // focus migration, so the arm is here.
        board.clearArticleLanding()
        do {
            try await session.runner.run { ops in
                try ops.updateBlockPresentation(target) {
                    CalloutEditRule.apply(edit, to: $0)
                }
            }
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    // MARK: - Pane selection + landings — the choreographer's, forwarded
    // (13b Stage 3, N10)

    /// The live pane's current selection, reported by the pane surface —
    /// what a fire-and-DO landing carries into Write.
    var paneSelection: (variantID: String, range: NSRange)? {
        choreography.paneSelection
    }

    func notePaneSelection(variantID: String, range: NSRange) {
        choreography.notePaneSelection(variantID: variantID, range: range)
        // 17o batch b (her ruling U-20): the LIVE pane's caret is the note's
        // current-block offset — so switching back to Write lands where she
        // was in the take, not at its first character. The live pane only:
        // a read pane's selection is not a caret (P-3's line), and reporting
        // one would hand a landing a place she never stood.
        guard let pane = focusedPane, pane.variantID == variantID else { return }
        session.commandRouter.noteFocusedBlock(
            pane.blockID, variantID: variantID, postID: postID,
            utf16Offset: range.location)
    }

    /// True on the PRIMARY takes board only (never the Write panel's
    /// embedded model): landing focus + cross-mode landings apply there.
    var landingEnabled: Bool {
        get { choreography.landingEnabled }
        set { choreography.landingEnabled = newValue }
    }

    /// The Takes board's fixed main-column identity (shared with the view).
    nonisolated static let takesMainColumnID = "takes-main"

    /// The Takes board's fan-card namespace (shared with the view — the
    /// bloom's cards key on it). R2-A sweep: an UN-chosen mint renders as
    /// a fan card, never in the article (which renders chosen only), so
    /// reveals map article-keyed focus onto this namespace.
    nonisolated static let takesFanColumnID = "takes-fan"

    /// The landing column for programmatic focus — the choreographer's.
    private var landingColumnID: String { choreography.landingColumnID }

    private func consumeLandings(_ new: Queries.TakesProjection) {
        choreography.consumeLandings(new)
    }

    /// The N9 landing's direct-authority focus door (the choreographer's
    /// one write into the authority): the landing ring claims the pane
    /// WITHOUT the migration flush task — at a landing there is no leaving
    /// pane with pending text, exactly the pre-move `authority.focus`
    /// call. Internal for the choreographer; everything else focuses
    /// through `focus(_:)`.
    func landAuthorityFocus(_ pane: PaneKey) {
        parkedFollow = nil  // VX-227 (rider 1): a landing is a focus too
        // VX-170: the entry ring lands where she was — and if the `show ▾`
        // filter folded that block to a line, the block opens (`focus`'s rule).
        lensFilter.reveal(pane)
        // 17o batch b (U-20): the N9 landing enters the note's current block
        // — and enters it WHERE SHE WAS. (This door deliberately does not
        // report the fact; it is landing ON the fact.)
        armPaneCaretLanding(for: pane)
        // The N9 FALL-THROUGH (no fact — a note opened fresh in Takes) is
        // still the note's ENTRY, never a structural act: it lands at the
        // START like Write's own no-memory arrival (R1-3's fall-through road
        // — the pane reports, so its END would become the memory).
        if paneCaretLanding == nil {
            paneCaretLanding = (variantID: pane.variantID, landing: .start)
        }
        authority.focus(pane)
        // 17q piece 6 (her R-Q21): the entry ring IS this board's current
        // block from now on — the next mount's snapshot. (It is written AFTER
        // the layout took its own snapshot in `init`, which is what keeps the
        // two showings apart.)
        rememberArticleCurrentBlock(pane.blockID)
    }

    // MARK: - Keyboard fan paging (13b 1b — AD-2's keyboard companion;
    // density + chunking are the board layout's, forwarded)

    /// Density inputs, pushed by the board view (models never read
    /// @AppStorage) — stored on the board layout.
    var beneathCount: Int {
        get { board.beneathCount }
        set { board.beneathCount = newValue }
    }
    var gridRows: Int {
        get { board.gridRows }
        set { board.gridRows = newValue }
    }
    var gridCols: Int {
        get { board.gridCols }
        set { board.gridCols = newValue }
    }
    /// VX-136: her column CHOICE (nil = the ruled default).
    var gridColsChoice: Int? {
        get { board.gridColsChoice }
        set { board.gridColsChoice = newValue }
    }

    /// VX-136: the columns one block's rail shows (her choice, else the
    /// ruled default for its fan) — the board's brain, forwarded.
    func gridCols(takeCount: Int, slotText: String?) -> Int {
        board.gridCols(takeCount: takeCount, slotText: slotText)
    }

    /// R24's strip exception, one brain with the board's chunking.
    func railRowsPerColumn(slotText: String?) -> Int {
        board.railRowsPerColumn(slotText: slotText)
    }

    /// VX-136: the grid's ROW slots for one block's fan — the tallest card in
    /// each row across all its columns (see `TakesBoardLayout.railRowHeights`).
    func railRowHeights(takes: [Variant], rowsPerColumn: Int) -> [CGFloat] {
        TakesBoardLayout.railRowHeights(
            cardTextHeights: takes.map { board.measuredTextHeight($0.id) },
            rowsPerColumn: rowsPerColumn)
    }

    // MARK: - Card heights (QoL batch 2, L3 · L4) — the board's, forwarded

    /// The RULED measurement seam's sink: a take pane's measured text
    /// height, delivered on a deferred turn (never inside a SwiftUI
    /// update). Equality-gated on the board, so a converged card is silent.
    func notePaneMeasuredHeight(variantID: String, height: CGFloat) {
        board.noteMeasuredTextHeight(variantID, height)
    }

    /// The seam's observation counter — board invalidations caused by
    /// measured-height deliveries (the settle + carousel-parity pins).
    var measuredHeightWrites: Int { board.measuredHeightWrites }

    /// L4: a margin-grid card's height — its content, capped at 330.
    func marginCardHeight(variantID: String) -> CGFloat {
        TakesBoardLayout.marginCardHeight(
            measuredText: board.measuredTextHeight(variantID))
    }

    /// L4: the rail's reserved vertical room — actual heights bounded by
    /// the cap, maxed over ALL columns so ◀ ▶ never move the article.
    func reservedRailHeight(takes: [Variant], rowsPerColumn: Int) -> CGFloat {
        TakesBoardLayout.reservedRailHeight(
            cardTextHeights: takes.map { board.measuredTextHeight($0.id) },
            rowsPerColumn: rowsPerColumn)
    }

    /// L3: the height this block's slot-split cards render at — `nil` =
    /// full length (the ruled default).
    func slotHeight(_ blockID: String) -> CGFloat? {
        board.slotHeight(blockID, naturalHeight: naturalSlotHeight(blockID))
    }

    /// The tallest card this block's fan would render at full length —
    /// the drag's ceiling, and the "past it ⇒ full length" snap.
    func naturalSlotHeight(_ blockID: String) -> CGFloat? {
        // VX-170: the takes the bloom DRAWS (a filtered row's expand set).
        let takes = projection.slots.first { $0.blockID == blockID }
            .map(bloomTakes) ?? projection.fans[blockID] ?? []
        return board.naturalSlotHeight(variantIDs: takes.map(\.id))
    }

    /// Her hand (the 17p batch-a ladder's final word, after the sanity pass's
    /// raise): the slot-height drag and its double-click write a row's HEIGHT
    /// through no Operations call and no focus migration — R1-2's measured
    /// mechanism — so both gesture doors end a pending article landing.
    /// `slotDragChanged` / `slotDragEnded` always follow `beginSlotDrag`.
    func beginSlotDrag(_ blockID: String) {
        board.clearArticleLanding()
        board.beginSlotDrag(blockID, naturalHeight: naturalSlotHeight(blockID))
    }

    func slotDragChanged(_ blockID: String, translation: CGFloat) {
        board.slotDragChanged(blockID, translation: translation)
    }

    func slotDragEnded(_ blockID: String, translation: CGFloat) {
        board.slotDragEnded(
            blockID, translation: translation, naturalHeight: naturalSlotHeight(blockID))
    }

    func resetSlotHeight(_ blockID: String) {
        board.clearArticleLanding()
        board.resetSlotHeight(blockID)
    }

    nonisolated static func railPageKey(_ blockID: String) -> String {
        TakesBoardLayout.railPageKey(blockID)
    }

    /// The focused (else first-expanded) block's paging key + last legal
    /// offset in the CURRENT style — the board renders with the same
    /// answer, so the keyboard and the ◀ ▶ doors can never disagree.
    func pageTarget() -> (key: String, limit: Int)? {
        let blockID = focusedPane?.blockID
            ?? projection.slots.first { expandedBlocks.contains($0.blockID) }?.blockID
        // VX-170: the takes the bloom DRAWS — a filtered row pages its expand
        // set, exactly as the board renders it (one paging brain).
        guard let blockID,
              let slot = projection.slots.first(where: { $0.blockID == blockID }),
              case let fan = bloomTakes(slot), fan.count > 1
        else { return nil }
        switch projection.fanStyle {
        case .carousel, .slotSplit:
            return (blockID, max(fan.count - beneathCount, 0))
        case .marginGrid:
            let text = projection.slots.first { $0.blockID == blockID }?.text
            let rows = railRowsPerColumn(slotText: text)
            let columns = (fan.count + rows - 1) / rows
            let shown = gridCols(takeCount: fan.count, slotText: text)
            return (Self.railPageKey(blockID), max(columns - shown, 0))
        case .stack:
            return nil
        }
    }

    func pageFocusedFan(by delta: Int) {
        guard let (key, limit) = pageTarget(), limit > 0 else {
            refuse("Open a block's takes first — ⌥⌘← and ⌥⌘→ page through its cards.")
            return
        }
        stepPage(key, by: delta, limit: limit)
    }

    func restoreCommit(_ commit: CommitPoint) async {
        await run { ops in try ops.restoreCommit(commit.variantId, commitID: commit.id) }
        if status == nil {
            setReceipt(
                "Restored — the commit's text is back in the take's buffer. Nothing was lost: commits are append-only."
            )
        }
    }

    /// The R90 power variant (⇧⌥⌘T — "open new blank take as chosen"):
    /// mint AND choose in one gesture, both halves in one serialized run.
    func newBlankTakeAsChosen(blockID: String, preferredColumnID: String? = nil) async {
        clearStatus()
        do {
            let take = try await session.runner.run { ops -> Variant in
                let take = try ops.newBlankVariant(blockID)
                try ops.chooseVariant(blockID, variantID: take.id)
                return take
            }
            revealChosenTake(
                blockID: blockID, variantID: take.id, preferredColumnID: preferredColumnID)
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    /// Stage 2 ladder, MINOR-D2: the as-chosen mint's reveal is gated on
    /// the HOST — the ring may only land on a pane some surface renders.
    /// On the Takes board (and Write's panel, which passes its own column
    /// as `preferredColumnID`) the ordinary reveal is right: the article
    /// pane renders the new chosen and an opened fan renders every take.
    /// On the LENSES board a lens/scratch column keeps showing its own
    /// pick, so the unconditional reveal parked the ring on a pane NO
    /// column hosts and the live ring silently vanished — there the ring
    /// goes to the column that renders CHOSEN (`.main`), and when no such
    /// column is open the ring stays where it is (a rendered pane) rather
    /// than moving onto nothing.
    private func revealChosenTake(blockID: String, variantID: String, preferredColumnID: String?) {
        switch host {
        case .takes:
            revealTake(
                blockID: blockID, variantID: variantID, preferredColumnID: preferredColumnID)
        case .lenses:
            guard let main = columns.first(where: { $0.kind == .main }) else {
                // NIT-R2-C: without a chosen-showing column the act
                // succeeds with nothing visible — a silent success is
                // against fire-and-speak, so say where it went.
                refuse("Chosen \u{2014} the note now shows the new blank take; "
                    + "add a \u{201C}Chosen (the note)\u{201D} column to see it here.")
                return
            }
            // VX-227 (the F5/F6 addendum): the Chosen column's stable cell
            // shows the mint only once the choice arrives by adoption — the
            // ring PARKS on it and re-binds when the cell shows the blank take.
            followOnceRendered(PaneKey(columnID: main.id, blockID: blockID, variantID: variantID))
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
        board.bloom(blockID)
        // 13b 3F (sweep table (a)'s recorded residual): on a LONG open fan
        // the revealed card could sit on a later ◀ ▶ page — page to it.
        pageToReveal(blockID: blockID, variantID: variantID)
        let columnID = preferredColumnID
            ?? focusedPane.flatMap { $0.blockID == blockID ? $0.columnID : nil }
            ?? landingColumnID
        let key = PaneKey(columnID: columnID, blockID: blockID, variantID: variantID)
        // VX-227: a mint is never what a STABLE cell already shows — on the
        // article (⇧⌥⌘T: the chosen mint arrives there by adoption) the ring
        // parks and re-binds once the article shows it; fan and panel cards
        // are one pane per take, so the ring lands on a fresh card at once.
        // Unconditional on a stable cell, deliberately: if the adoption raced
        // ahead of this continuation, a direct focus could still meet a cell
        // not yet re-rendered (the live re-point); the park is fail-safe in
        // both orders (at worst the ring stays nil — never another take's
        // words under the caret).
        if stableCellTake(columnID: columnID, blockID: blockID, in: projection) != nil {
            followOnceRendered(key)
        } else {
            focus(key)
        }
    }

    // MARK: - Auto-page to the reveal (13b 3F)

    /// A revealed take not yet in the projection (the mint's observation
    /// lags the op): resolved at the next `adopt`. The retry budget (NIT-2,
    /// Stage 3 ladder round 1) retires the zombie: a reveal for a take
    /// that never arrives — a refused mint, a raced delete — used to
    /// re-park on every adopt forever. The real mint sequence resolves on
    /// the first adopt; a budget of 2 also covers a stale emission ordered
    /// before the mint; past it the park drops (the fan stays open and the
    /// ring focused — only the auto-page is forgone).
    @ObservationIgnored private var pendingRevealPage: (blockID: String, variantID: String, retriesLeft: Int)?

    /// Pages the set style's pager so `variantID`'s card is on the visible
    /// page — the fan was open and the counter ticked, but a mint at the
    /// end of a long fan landed BEHIND the ◀ x–y of n ▶ door. One paging
    /// brain with the board (`pageOffset`/`stepPage` read the same state).
    func pageToReveal(blockID: String, variantID: String) {
        guard let fan = projection.fans[blockID],
              let index = fan.firstIndex(where: { $0.id == variantID }) else {
            pendingRevealPage = (blockID, variantID, 2)
            return
        }
        switch projection.fanStyle {
        case .carousel, .slotSplit:
            let limit = max(fan.count - beneathCount, 0)
            let current = pageOffset(blockID, limit: limit)
            if index < current || index >= current + beneathCount {
                board.setPage(blockID, to: min(index, limit), limit: limit)
            }
        case .marginGrid:
            let text = projection.slots.first { $0.blockID == blockID }?.text
            let rows = max(railRowsPerColumn(slotText: text), 1)
            let column = index / rows
            let columns = (fan.count + rows - 1) / rows
            let shown = gridCols(takeCount: fan.count, slotText: text)
            let limit = max(columns - shown, 0)
            let key = Self.railPageKey(blockID)
            let current = pageOffset(key, limit: limit)
            if column < current || column >= current + shown {
                board.setPage(key, to: min(column, limit), limit: limit)
            }
        case .stack:
            break  // the stack renders every card; nothing pages
        }
    }

    /// Column resolution for an UN-chosen mint on the TAKES host (R2-A
    /// sweep): the article renders CHOSEN only, so an article-keyed (or
    /// landing-keyed) reveal would strand the ring's authority on a pane
    /// no style renders — the mint blooms as a FAN card, and the reveal
    /// keys the fan namespace the bloom actually renders.
    private func takesUnchosenRevealColumnID(
        preferredColumnID: String?, blockID: String
    ) -> String {
        let columnID = preferredColumnID
            ?? focusedPane.flatMap { $0.blockID == blockID ? $0.columnID : nil }
            ?? landingColumnID
        return columnID == Self.takesMainColumnID ? Self.takesFanColumnID : columnID
    }

    /// Column resolution on the LENSES host (R2-A): a mint is visible
    /// only as a column's pick — the door needs a real column (the cell
    /// menus pass theirs; the bar falls back to the focused pane's).
    private func lensesMintColumnID(
        preferredColumnID: String?, blockID: String
    ) -> String? {
        if let preferredColumnID, columns.contains(where: { $0.id == preferredColumnID }) {
            return preferredColumnID
        }
        if let pane = focusedPane, pane.blockID == blockID,
           columns.contains(where: { $0.id == pane.columnID }) {
            return pane.columnID
        }
        return nil
    }

    nonisolated static let lensesMintNeedsColumnNote =
        "Click into a column's pane first — on this board a new take lands as that column's pick."

    /// Branch + reveal — the ONE body behind ⌘T, the bar's ＋ take, the
    /// block ▾ menu, the growth doors, and the card context menu. R2-A
    /// (Stage 2 ladder round 2): HOST-GATED like `revealChosenTake` — on
    /// the Takes board the mint blooms as a fan card and the ring lands
    /// on it; on the Lenses board an un-chosen mint is visible ONLY as a
    /// column's pick, so the door routes through the board's own
    /// pick-into-column semantics (the branch core `divergeHere` shares)
    /// and the ring follows onto the pane that now renders it.
    @discardableResult
    func branchTakeRevealed(
        blockID: String, from variantID: String, preferredColumnID: String? = nil
    ) async -> Variant? {
        switch host {
        case .takes:
            guard let take = await branchTake(blockID: blockID, from: variantID)
            else { return nil }
            revealTake(
                blockID: blockID, variantID: take.id,
                preferredColumnID: takesUnchosenRevealColumnID(
                    preferredColumnID: preferredColumnID, blockID: blockID))
            return take
        case .lenses:
            guard let columnID = lensesMintColumnID(
                preferredColumnID: preferredColumnID, blockID: blockID) else {
                refuse(Self.lensesMintNeedsColumnNote)
                return nil
            }
            return await branchIntoColumn(
                columnID: columnID, blockID: blockID, fromVariantID: variantID)
        }
    }

    /// Blank + reveal — ⌥⌘T's one body (minting never chooses, R90; the
    /// blank card blooms and takes the ring). Host-gated like the branch
    /// twin (R2-A).
    @discardableResult
    func newBlankTakeRevealed(
        blockID: String, preferredColumnID: String? = nil
    ) async -> Variant? {
        switch host {
        case .takes:
            guard let take = await newBlankTake(blockID: blockID) else { return nil }
            revealTake(
                blockID: blockID, variantID: take.id,
                preferredColumnID: takesUnchosenRevealColumnID(
                    preferredColumnID: preferredColumnID, blockID: blockID))
            return take
        case .lenses:
            guard let columnID = lensesMintColumnID(
                preferredColumnID: preferredColumnID, blockID: blockID) else {
                refuse(Self.lensesMintNeedsColumnNote)
                return nil
            }
            return await blankIntoColumn(columnID: columnID, blockID: blockID)
        }
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
            setRefusal("Click into a take first — ⌃⌘← and ⌃⌘→ step through its siblings.")  // J38
            return
        }
        switch host {
        case .lenses:
            // VX-227: on the Lenses board a step moves the COLUMN's pick and
            // the live editor follows it (`pick`'s one body). It never falls
            // through to the Takes arm any more: that arm keyed the ring to
            // `<column>|<block>|<next>` — on the Chosen column a key no cell
            // renders (the board has no fan cards), which ⌘⏎ could then revive
            // over the old chosen's words.
            guard let column = columns.first(where: { $0.id == pane.columnID }) else {
                setRefusal("Click into a take first — ⌃⌘← and ⌃⌘→ step through its siblings.")  // J38
                return
            }
            // F3: the Chosen column has no pick to step — its own refusal,
            // the ring left where she is (P-2).
            guard column.kind != .main else {
                setRefusal(Self.chosenColumnHasNoPickNote)
                return
            }
            await stepPick(columnID: column.id, slot: slot, by: delta)
        case .takes:
            guard let fan = projection.fans[slot.blockID], fan.count > 1,
                  let current = fan.firstIndex(where: { $0.id == pane.variantID })
            else {
                setRefusal("This block has one take — ⌘T branches a second.")  // J38
                return
            }
            let next = min(max(current + delta, 0), fan.count - 1)
            guard next != current else { return }
            if !board.expandedBlocks.contains(slot.blockID) { board.bloom(slot.blockID) }
            // **VX-227 — the step FOLLOWS, visibly (her R-VX214-1).** A step
            // moves the ring only (no op; chosen never moves — the run record's
            // step-vs-choose verdict), so the ring lands on the pane that
            // RENDERS the stepped-to take. The article renders the chosen take
            // only, so from the article that pane is the take's FAN CARD — the
            // R2-A reveal mapping (`takesUnchosenRevealColumnID`'s rule) —
            // paged into view; it used to key `takes-main|<next>`, a pane no
            // style renders (the ring vanished). Cards are one pane per take,
            // so this re-bind never re-points the pane she was typing in; the
            // ring's migration flushes it (`focus`).
            let columnID = pane.columnID == Self.takesMainColumnID
                ? Self.takesFanColumnID : pane.columnID
            if columnID == Self.takesFanColumnID {
                pageToReveal(blockID: slot.blockID, variantID: fan[next].id)
            }
            focus(PaneKey(
                columnID: columnID, blockID: slot.blockID, variantID: fan[next].id))
        }
    }

    /// ⌘⏎ — choose the take the ring is in (the ONE careful gesture, by
    /// keyboard).
    func chooseFocusedTake() async {
        guard let pane = focusedPane else {
            setRefusal("Click into a take first — ⌘⏎ chooses the take you're in.")  // J38
            return
        }
        await choose(blockID: pane.blockID, variantID: pane.variantID)
        if status == nil {
            setReceipt("✓ chosen — the note shows this take everywhere.")
        }
    }

    /// ⌘⇧T — toggle the focused (or first fanned) block's bloom.
    func toggleFocusedFan() {
        let blockID = focusedPane?.blockID
            ?? projection.slots.first(where: \.hasFan)?.blockID
            ?? projection.slots.first?.blockID
        guard let blockID else { return }
        toggleExpanded(blockID)
    }

    /// ⌘⇧A — archive the take the ring is in. The road-back speech is
    /// `archiveTake`'s (one copy on every door — 3D/N1).
    func archiveFocusedTake() async {
        guard let pane = focusedPane else {
            setRefusal("Click into a take first — ⌘⇧A archives the take you're in.")  // J38
            return
        }
        await archiveTake(pane.variantID)
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

    /// The ops-call plumbing: clear the line, run, speak a refusal.
    /// Internal (13e round A, A-2) so the structure controller's doors run
    /// through the SAME body rather than growing a second copy of it.
    func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        clearStatus()
        board.clearArticleLanding()   // her hand (R1-2)
        do {
            try await session.runner.run(body)
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    /// `run`'s COPY sibling (13e E10): identical plumbing, through the copy
    /// family's one flush-first entry (`AppSession.runCopying`). Separate
    /// from `run` deliberately — flushing before every ops call would make
    /// every board door pay for a hazard only the copy doors carry, and
    /// would hide which doors mint copies.
    func runCopying(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        clearStatus()
        board.clearArticleLanding()   // her hand (R1-2)
        do {
            try await session.runCopying(from: postID, body)
        } catch {
            setRefusal(Self.message(for: error))
        }
    }

    /// The ops-refusal vocabulary moved to the shared layer (13b 1b —
    /// Canvas/TOC/Tutorial no longer reach into this feature for copy);
    /// kept as a forward so every pin and call site reads unchanged.
    static func message(for error: Error) -> String {
        OpsRefusalCopy.message(for: error)
    }
}

// MARK: - DivideWCeremonyHost (13d Batch 3, A9)

/// The take ceremony mounts on a board exactly as it mounts in Write —
/// same state machine, same disciplines (one flight before any await,
/// drift-refresh at confirm, cancel-inert, I10-at-birth). What differs is
/// only what this protocol names: how the surface flushes, and how the
/// divide runs.
extension TakesViewModel: DivideWCeremonyHost {
    var ceremonyDatabase: AppDatabase { session.database }

    /// The board's pending-text contract — identical to `deleteFocusedBlock`'s
    /// (13c R2-6: one declared act, one contract, however many doors).
    func flushPendingText() async -> Bool {
        await autosave.flushNow()
        guard !autosave.isDirty else {
            refuse("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        return true
    }

    var structuralFlightInProgress: Bool { structuralInFlight }

    /// *(The rule this used to hold — "the take a fresh successor RENDERS" —
    /// moved to `Operations.FanHalf.renderedTakeID` at 13u3 UNIT G, the 18f
    /// ladder's R3-8, so the board's INSTANT road reads it too. Behaviour
    /// byte-identical; the reasoning lives beside the rule now.)*

    /// The confirm's act — its OWN flight, exactly as `runStructural` is
    /// Write's (the ceremony's pre-await guard reads the latch and this
    /// takes it afterwards, so there is no self-refusal). The ring goes to
    /// the SECOND successor's rendered take — the board's instant road's own
    /// rule, and Write's for every divide shape since the 18f ladder (R1-13;
    /// R2-4 for which take).
    func runDivideW(
        blockID: String, cuts: [String: Int], displayedVariantID: String?
    ) async -> Bool {
        structuralInFlight = true
        defer { structuralInFlight = false }
        clearStatus()
        do {
            let result: Operations.DivideWResult = try await session.runner.run { ops in
                try ops.divideW(
                    blockID, cuts: cuts, displayedVariantID: displayedVariantID)
            }
            if let landing = result.second.renderedTakeID {
                choreography.parkFocus(onVariant: landing)
            }
            // The receipt counts from the OP's OWN result — and from the
            // part of it that names the shape (18f ladder R3-1, ledger row
            // 43). `first.variants.count - 1` is the INSTANT road's
            // arithmetic: it assumes exactly one seed-half sits in `first`,
            // which `KeepOnTopDivide.compose` guarantees there and this road
            // does not. The sheet may park the seed at its very START
            // (keep-on-top with the ✂ at 0 — legal; `presetBlocker` blocks
            // only `parkedAtEnd`), and under "Choose per take…" any take may
            // be cut by hand. `FanHalf.sourceVariantIDs` is index-aligned
            // with `variants`, so the two claims are readable exactly: a
            // take RODE WHOLE onto the first block iff its source id is in
            // `first` and not in `second`, and "the take you were in split
            // across both blocks" is true iff the seed is in both. When it
            // is not, the line falls back to R1-9's deliberate zero form,
            // which claims nothing — better a receipt that says less than
            // one that describes a shape it cannot say (J8).
            let rodeOntoFirst = Set(result.first.sourceVariantIDs)
                .subtracting(result.second.sourceVariantIDs)
            let seedSplit = displayedVariantID.map {
                result.first.sourceVariantIDs.contains($0)
                    && result.second.sourceVariantIDs.contains($0)
            } ?? false
            setReceipt(FannedDefaultsCopy.divided(
                kept: seedSplit ? rodeOntoFirst.count : 0))
            return true
        } catch {
            setRefusal(Self.message(for: error))
            return false
        }
    }

    /// U-5's third preset on the board — the same flight, the same ring
    /// rule, the shipped `divideDuplicating`.
    func runDivideDuplicating(
        blockID: String, displayedVariantID: String, cut: Int
    ) async -> Bool {
        structuralInFlight = true
        defer { structuralInFlight = false }
        clearStatus()
        do {
            let result: Operations.DivideDuplicatingResult
                = try await session.runner.run { ops in
                try ops.divideDuplicating(
                    blockID, displayedVariantID: displayedVariantID, cut: cut)
            }
            if let landing = result.second.renderedTakeID {
                choreography.parkFocus(onVariant: landing)
            }
            setReceipt(FannedDefaultsCopy.divided(kept: 0))
            return true
        } catch {
            setRefusal(Self.message(for: error))
            return false
        }
    }

    func speakCeremonyStatus(_ message: String) {
        refuse(message)
    }

    /// 18i: the ceremony's one RECEIPT (the released original's note) — the
    /// board's own receipt door, so it wears the muted colour in the panel
    /// and follows her setting in the shell.
    func speakCeremonyReceipt(_ message: String) {
        setReceipt(message)
    }

    func speakCeremonyRefusal(_ message: String) {
        refuse(message)
    }

    func speakCeremonyError(_ error: Error) {
        setRefusal(Self.message(for: error))
    }
}
