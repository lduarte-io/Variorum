//
//  CommandRouter.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (P-1/P-4): the ONE routing brain between the app's
//  command doors (menu bar, palette, bars) and whichever post surface is
//  mounted. Replaces the three Stage 0 routing regimes:
//
//  - editor-router calls that silently no-op'd into nil outside Write
//    (the ⌘S class),
//  - `.variorumTakesCommand` broadcasts with no listener mounted
//    (keystroke consumed, nothing anywhere), and
//  - `.variorumSwitchMode` with ONE conditional observer (mode switches
//    silently dropped when no PostDetailView was mounted).
//
//  Surfaces REGISTER handlers (composition — a session-scoped object, the
//  EditorRouter precedent); dispatch walks the handler stack; an unhandled
//  command SPEAKS the registry's honest note through the StatusCenter.
//  Broadcasts carry nothing here — no decision rides a notification (P-4).
//

import Foundation
import Observation

@MainActor
@Observable
final class CommandRouter {
    // MARK: - Mode truth (the mounted post detail)

    /// The mounted post detail's post + mode — observable truth the sidebar
    /// rail reads directly (the broadcast-derived shadow is retired).
    private(set) var activePostID: String?
    private(set) var activeMode: PostMode?

    @ObservationIgnored private var detailToken: UUID?
    @ObservationIgnored private var applyMode: ((PostMode) -> Void)?
    /// How a tray request reaches the mounted detail's INSPECTOR (the
    /// post-13l polish round, ledger row 9 — her C1 move). See
    /// `requestNoteTray` for why this is its own seam and not a handler.
    @ObservationIgnored private var showTray: ((TrayRequest) -> Void)?

    /// The post detail registers itself on appear; `applyMode` is how a
    /// routed request reaches its `@State` (composition, not broadcast).
    /// `showTray` is the same seam for the inspector's tray panel — defaulted
    /// nil so a host that has no inspector (and every pin) registers exactly
    /// as before.
    func registerDetail(
        postID: String, mode: PostMode, applyMode: @escaping (PostMode) -> Void,
        openTagField: (() -> Void)? = nil,
        showTray: ((TrayRequest) -> Void)? = nil,
        showBlockHistory: ((BlockHistoryRequest) -> Void)? = nil,
        showVersions: (() -> Void)? = nil
    ) -> UUID {
        let token = UUID()
        detailToken = token
        // A DIFFERENT note arriving makes the remembered caret a fact about
        // somewhere else (ledger row 33): the live fact becomes THAT note's
        // remembered current block (the Act 10 correction round, row 39 —
        // one current block per note, kept across mounts), or nothing. The
        // same note re-registering keeps it — a remount is not a caret move.
        if activePostID != postID {
            // 17o batch b: the outgoing note's caret place is written now (the
            // session dict has been taking every report; the persisted copy is
            // written at block changes and here).
            if let leaving = activePostID { currentBlocks.persist(postID: leaving) }
            // 18l U0c — HER R-18l-1: *"First open of a note each session shows
            // the start; re-opening a note you already visited this session
            // restores where you were."* — which SUPERSEDES, for the note-open
            // act, 17o's "every door into Write lands at the remembered caret
            // and reveals it". So the run's FIRST open of a note seeds NO fact:
            // every mode arrives exactly as a note with nothing remembered
            // does (Write's caret and page at the start, Takes' first slot,
            // Read's first row), and the memory follows whatever she does next
            // — a mode switch included (measured on the walk: keeping the old
            // caret as the live fact put the blank END back on screen at the
            // first ⌘1 — `18l-screens/u0c/walk/letter/t-11`). A RE-open restores what
            // THIS run knows (`sessionFact`), never an earlier run's place. The
            // memory itself is untouched (persisted, and read by the doors that
            // name a place on purpose). The OPENING is recorded beside the fact
            // (`openingLanding`) so a re-open's arrival lands the page she left
            // rather than revealing a caret she had scrolled away from. Every
            // door into a note (the Library, the shelf, the Open strip, ⌘K,
            // ← →, ⌘⇧n, a split pane taking focus) reaches this registration,
            // so the rule is door-agnostic by construction; a door that names a
            // block carries its own landing and never read this fact.
            let reopening = !notesOpenedThisRun.insert(postID).inserted
            let restored = reopening ? currentBlocks.sessionFact(for: postID) : nil
            opening = NoteOpening(postID: postID, isReopen: reopening, mode: mode, seeded: restored)
            focusedOffset = restored?.utf16Offset
            // R1-9: the observed half carries NO offset — the caret-rate half
            // above is the only home, so the two lifetimes cannot be confused.
            // (Order is load-bearing: the offset is read off `restored` first.)
            var identity = restored
            identity?.utf16Offset = nil
            focusedBlockIdentity = identity
            // 13u2b UNIT 3: a place on ANOTHER note's screen means nothing here.
            carriedPlace = nil
        }
        activePostID = postID
        activeMode = mode
        self.applyMode = applyMode
        self.openTagField = openTagField
        self.showTray = showTray
        self.showBlockHistory = showBlockHistory
        self.showVersions = showVersions
        // The arriving detail consumes a tray request parked for IT — the
        // `pendingWriteIntent` choreography, one act over (see
        // `requestNoteTray`). Stamped, so a park for another post never
        // opens a panel on this one.
        if let parked = pendingTrayRequest, parked.postID == postID {
            pendingTrayRequest = nil
            showTray?(parked)
        } else if pendingTrayRequest?.postID != postID {
            pendingTrayRequest = nil
        }
        // Staleness (round-1 MAJOR, half b): a parked choreography intent
        // for ANOTHER post has missed its round — the detail it targeted is
        // gone. Clear it here (register-ordering-proof: on a P→Q switch
        // SwiftUI may run Q's onAppear before P's onDisappear, so the
        // token-guarded unregister below can be a no-op).
        if let pending = pendingWriteIntent, pending.postID != postID {
            pendingWriteIntent = nil
        }
        if let landing = pendingTakesLanding, landing.postID != postID {
            pendingTakesLanding = nil
        }
        if let landing = pendingLensLanding, landing.postID != postID {
            pendingLensLanding = nil
        }
        if let landing = pendingCompareLanding, landing.postID != postID {
            pendingCompareLanding = nil
        }
        return token
    }

    func unregisterDetail(_ token: UUID) {
        guard token == detailToken else { return }  // a stale teardown after the next mount
        detailToken = nil
        applyMode = nil
        openTagField = nil
        showTray = nil
        showBlockHistory = nil
        showVersions = nil
        // 17o batch b: the leaving note's caret place is written before the
        // fact goes (the session dict keeps it either way; this is what a
        // relaunch reads).
        if let leaving = activePostID { currentBlocks.persist(postID: leaving) }
        activePostID = nil
        activeMode = nil
        // A genuine teardown (no successor mounted yet): any parked
        // choreography intent's round is over (round-1 MAJOR, half b).
        pendingWriteIntent = nil
        pendingTakesLanding = nil
        pendingLensLanding = nil
        pendingCompareLanding = nil
        pendingTrayRequest = nil
        focusedBlockIdentity = nil
        focusedOffset = nil
        // 13u2b UNIT 3: the detail is gone, so any place captured for a mode
        // switch inside it has no arrival left to consume it.
        carriedPlace = nil
        // 18l U0c: …and its opening is over.
        opening = nil
    }

    // MARK: - The note's OPENING (18l U0c — her R-18l-1)

    /// **The notes this app run has opened** — in memory, never persisted,
    /// never synced: "each session" in her ruling is one run of the app. A
    /// note in here re-opens where she was THIS run; a note not yet in here is
    /// the session's first open and arrives at its start.
    @ObservationIgnored private var notesOpenedThisRun: Set<String> = []

    /// How the mounted detail's note ARRIVED — kept for exactly the opening:
    /// the surface the detail opened in (its remembered mode). A mode switch
    /// ends it (`noteMode` — a mode round trip is the standing machinery's,
    /// never an opening's), and so does the detail leaving.
    struct NoteOpening: Equatable {
        let postID: String
        /// The run had opened this note before (a re-open) — vs its first open.
        let isReopen: Bool
        /// The mode the detail registered in: the opening's own surface.
        let mode: PostMode
        /// The fact the opening restored — nil on the run's first open, THIS
        /// run's place on a re-open. The arrival that lands on exactly this is
        /// the OPENING's landing; a report since (a click, a door that names
        /// its block by reporting it) is a place someone chose, and it lands by
        /// the standing rules.
        let seeded: FocusedBlock?
    }

    @ObservationIgnored private(set) var opening: NoteOpening?

    /// **Is this arrival the note-OPENING's own landing?** Asked by each
    /// mode's arrival with the fact it is about to land on (Write's bare
    /// arrival, Takes' N9 entry arm, Read's seed). Non-nil ⇒ her R-18l-1
    /// decides the VIEWPORT: the page THIS RUN left for the note (Write's
    /// session place, Takes' article place, Read's this-run current block —
    /// Read keeps no page of its own), else the note's START — never a reveal
    /// of a caret she has since scrolled away from. The caret, the ring and the
    /// selection still land on the fact. Nil ⇒ not an opening (a mode switch,
    /// another note, or a fact someone placed since the note arrived) — the
    /// standing machinery.
    func openingLanding(postID: String, fact: FocusedBlock?) -> NoteOpening? {
        guard let opening, opening.postID == postID, opening.seeded == fact else { return nil }
        return opening
    }

    // MARK: - Where the caret is (the post-13l polish round, ledger row 33)

    /// **The block the mounted writing surface is standing in.** A FACT, not a
    /// request: nothing here decides anything, and the one reader — the Block
    /// History pane's jump door — compares it against the block it is showing
    /// (`BlockHistoryModel.jumpTarget`).
    ///
    /// Observable, because the door has to APPEAR when she clicks into another
    /// block; cheap, because the surfaces report only when the block CHANGES,
    /// so a caret walking inside one paragraph writes nothing at all.
    ///
    /// **The caret's OFFSET inside the block rides beside the identity, never
    /// in it** (17o batch b, her ruling U-20). It has to be fresh at caret
    /// rate — she types, then switches to Write and expects to be where she
    /// was — and it must wake nobody at caret rate, because the one view that
    /// registers a `body` dependency here (the Block History pane's jump
    /// door) would then re-render on every keystroke, which is precisely the
    /// cost the paragraph above exists to refuse. So the offset is stored
    /// `@ObservationIgnored` and this READ merges the two: one truth, one
    /// value, and the cadence of the signal unmoved.
    var focusedBlock: FocusedBlock? {
        guard var fact = focusedBlockIdentity else { return nil }
        fact.utf16Offset = focusedOffset
        return fact
    }

    /// The observed half — assigned only when the BLOCK (or its take) changes.
    private var focusedBlockIdentity: FocusedBlock?
    /// The caret-rate half — read at a landing, watched by nobody.
    @ObservationIgnored private var focusedOffset: Int?

    /// A mounted writing surface reports where its caret is. Ignored for any
    /// note other than the one on screen — a background pane's caret is not
    /// "the block you're in" for the panel beside the foreground one.
    ///
    /// `utf16Offset` is nil for a surface that holds no caret (Blocks' row,
    /// the outline's card) — nil is UNKNOWN, not zero, and the memory's own
    /// rule keeps a known offset for the same block rather than erasing it.
    func noteFocusedBlock(
        _ blockID: String?, variantID: String?, postID: String, utf16Offset: Int? = nil
    ) {
        guard activePostID == postID else { return }
        guard let blockID else {
            focusedBlockIdentity = nil
            focusedOffset = nil
            return
        }
        let fact = FocusedBlock(
            postID: postID, blockID: blockID, variantID: variantID, utf16Offset: utf16Offset)
        // Row 39: the fact is remembered for its note — every reporter
        // (Write's caret, the boards' ring, Read's selection, Blocks' row)
        // feeds the one memory through this door, nothing else. The memory
        // takes EVERY report, offset included; the observed identity below
        // takes only the ones that move the block.
        currentBlocks.remember(fact)
        focusedOffset = currentBlocks.current(for: postID)?.utf16Offset
        guard focusedBlockIdentity?.blockID != blockID
            || focusedBlockIdentity?.variantID != variantID
            || focusedBlockIdentity?.postID != postID
        else { return }  // assign only on a real change
        var identity = fact
        identity.utf16Offset = nil  // R1-9: the observed half never carries the offset
        focusedBlockIdentity = identity
    }

    // MARK: - The current block, remembered per note (the correction round, row 39)

    /// The per-note memory behind `focusedBlock` — `CurrentBlockMemory`'s
    /// header has the whole argument. Session-scoped, persisted per note.
    @ObservationIgnored private var currentBlocks = CurrentBlockMemory()

    /// Where she last was in a note — mounted or not: the live fact, else the
    /// memory (this run's, else the persisted one). The doors that name a place
    /// on purpose read it (the book's edit-here door, the panes' entry caret);
    /// a mode entering a mounted note reads the live `focusedBlock`, which this
    /// seeded. (Since 18l U0c the NOTE-OPEN door no longer lands here — the
    /// run's first open seeds nothing, a re-open this run's place:
    /// `registerDetail`.) Both carry the caret's offset (17o batch b): the live
    /// fact merges it on read, the memory persists it.
    func currentBlock(for postID: String) -> FocusedBlock? {
        if let fact = focusedBlock, fact.postID == postID { return fact }
        return currentBlocks.current(for: postID)
    }

    /// **The leaving door the app itself walks through** (17o batch b's
    /// ladder, R1-4): the persisted copy is written at a block/take change
    /// and when the note leaves the screen — `registerDetail` on a note
    /// change, `unregisterDetail` on the detail's disappear — and NEITHER
    /// runs at app termination (`onDisappear` never fires when the process
    /// exits), so after ⌘Q the persisted offset was the block's ENTRY
    /// offset, never where she left. The quit door
    /// (`applicationShouldTerminate`, both branches) and the lock door
    /// (`macWillLock`) call this before they reply. Idempotent; a hard kill
    /// remains the only road that can lose the walk inside one block.
    func persistCurrentBlocks() {
        if let active = activePostID { currentBlocks.persist(postID: active) }
    }

    /// A pin's reset (or a deleted note): the memory for one note goes.
    ///
    /// **Every per-note memory, not only this one** (18d ladder round 1,
    /// NIT-3): the book Outline's and the reading flow's remembered surface
    /// sizes are persisted per note too, and they live on per-book view
    /// models this router cannot reach — so the door drops their PERSISTED
    /// records here, which is the part that would otherwise outlive the note
    /// (`SurfaceSizeMemory.forgetPersisted` says why the session halves need
    /// no reaching). **One door, every memory** — adding the next per-note
    /// memory beside them is a line here, not a new eviction road.
    ///
    /// **Who walks it** (round 2's MINOR-3 corrected round 1's claim): the
    /// Mac's Delete Now on a note (`RecoveryViewModel.confirmPendingPurge` →
    /// `forgetLocalMemories`), which is the purge, not the delete — a deleted
    /// note is in the Trash and Put back must find her caret where she left
    /// it. Every other caller is a pin's reset. What this door does NOT
    /// reach — Empty Trash's targets, and a note never purged at all — is the
    /// accepted leak the KnownIssues row names at its own arithmetic.
    func forgetCurrentBlock(for postID: String) {
        currentBlocks.forget(postID: postID)
        SurfaceSizeMemory.forgetPersisted(postID)
        if focusedBlockIdentity?.postID == postID {
            focusedBlockIdentity = nil
            focusedOffset = nil
        }
    }

    // MARK: - The mode switch's viewport carry (13u2b UNIT 3)

    /// **Where the carried block sits on the mounted surface's screen**, asked
    /// at the moment a mode switch is made and handed to the surface that
    /// arrives — so the same block keeps the same viewport fraction across the
    /// switch (the architectural trace's §6; the rule itself is the pure
    /// `ViewportCarry`).
    ///
    /// A registry rather than one closure, and LIFO like `handlers`, for the
    /// same reason: mount order is SwiftUI's, and an arriving surface's
    /// `onAppear` can precede the departing one's `onDisappear`. The answer is
    /// filtered by `activePostID`, so a surface showing ANOTHER NOTE can never
    /// answer for the one this switch is about. **What the filter does NOT
    /// discriminate (13u2b ladder round 1, NIT 1 — recorded, accepted):** the
    /// SAME note open in two windows registers two probes, and the LIFO pick
    /// can then carry the other window's geometry — a cosmetic misplacement
    /// in the recorded two-windows keying family. The eventual fix is keying
    /// the probe by the detail's registration token; not built here because
    /// it needs a window discriminator plumbed through both registration
    /// sites and the capture path — not the one-line class.
    @ObservationIgnored
    private var placeProbes: [(token: UUID, probe: () -> ViewportCarry.Place?)] = []

    func registerBlockPlaceProbe(_ probe: @escaping () -> ViewportCarry.Place?) -> UUID {
        let token = UUID()
        placeProbes.append((token, probe))
        return token
    }

    func unregisterBlockPlaceProbe(_ token: UUID) {
        placeProbes.removeAll { $0.token == token }
    }

    /// The one slot the carry lives in: in-memory, session-scoped, one-shot.
    ///
    /// Deliberately NOT persisted — a per-note `UserDefaults` key is the
    /// hazard class `KnownIssuesAndTechDebt`'s per-note-defaults row already
    /// owns (a fact that outlives its note), and where the page happened to
    /// stand during one mode switch is worth far less than that leak. A fresh
    /// session therefore starts with no carried fractions, which is right:
    /// nothing was on screen to carry.
    @ObservationIgnored private var carriedPlace: ViewportCarry.Place?

    /// **The mode is about to change — ask the mounted surface where the
    /// carried block sits.** Called by the mode-switch road BEFORE the mode
    /// changes (the outgoing surface is still mounted and still knows its own
    /// geometry); never by a landing, a click-through or a remount, because
    /// those name their own block and keep their standing reveals.
    ///
    /// Every switch re-decides, **nil included**: a switch away from a surface
    /// that does not participate (Takes — her own 17q ruling outranks this
    /// rule — Lenses, Compare, Canvas, Blocks) CLEARS the slot rather than
    /// leaving a stale place for some later arrival to consume.
    func carryPlaceAcrossModeSwitch() {
        guard let postID = activePostID else {
            carriedPlace = nil
            return
        }
        carriedPlace = placeProbes.reversed().lazy
            .compactMap { $0.probe() }
            .first { $0.postID == postID }
    }

    /// The arriving surface takes the carry — ONCE, and only for the block it
    /// is actually landing on. A different block (the current block moved
    /// between the switch and the arrival, or the block is gone) gets nil and
    /// the surface's own standing reveal, which is the honest answer.
    ///
    /// **ONE-SHOT MEANS ONE ASK (13u2b ladder round 1, MINOR 1 — red-on-old
    /// in `CommandRouterTests`):** the ask SPENDS the slot, matched or not.
    /// The first cut cleared only on a match, so a mismatched take left the
    /// place loaded — and `jump(to:)` sets the mode outside the switch's
    /// re-decide, so a later jump-road arrival naming the carried block
    /// consumed a minutes-old fraction where those roads are promised their
    /// standing landings. The switch's one arrival gets one chance.
    func takeCarriedFraction(postID: String, blockID: String) -> Double? {
        guard let place = carriedPlace, place.postID == postID else { return nil }
        carriedPlace = nil
        guard place.blockID == blockID else { return nil }
        return place.fraction
    }

    /// **The arriving surface takes the WHOLE place — block-agnostic,
    /// consume-once** (13u2b ladder round 1, MAJOR 2 — red-on-old in
    /// `ModeSwitchCarryTests`). Read's seed lands ON the carried block, so it
    /// cannot key its ask by a block it has not yet chosen: the switch-time
    /// capture (the outgoing editor's own `caretBlockID`) is the NEWER fact
    /// than the router's observed identity — the orchestrator's walk caught
    /// the first Read mount landing on the note-open's block because the
    /// seed keyed itself off a fact that had gone stale while the capture
    /// was fresh. The one ask spends the slot, exactly as
    /// `takeCarriedFraction`'s rule above; the caller still refuses a place
    /// naming a block it cannot show and falls back to its standing road.
    func takeCarriedPlace(postID: String) -> ViewportCarry.Place? {
        guard let place = carriedPlace, place.postID == postID else { return nil }
        carriedPlace = nil
        return place
    }

    /// **A click-through road that names its OWN block drops the carry as it
    /// changes the mode** (13u2b ladder round 1, MINOR 1's second door — the
    /// same one-shot rule where the re-decide cannot run). The `jump(to:)`
    /// family sets the mode directly, by design; without this, Write → Canvas
    /// parks a place nothing consumes and the canvas card's jump back to the
    /// same block would land it at the parked fraction instead of the jump's
    /// own landing.
    func dropCarriedPlace() {
        carriedPlace = nil
    }

    /// The detail reports its mode truth (its own `@State` changed).
    func noteMode(_ mode: PostMode) {
        guard detailToken != nil else { return }
        activeMode = mode
        // 18l U0c: a switch to another mode ends the note's opening — the
        // arriving surface is a mode round trip's (the registration's own
        // mode reported back by the detail's first `onChange` keeps it).
        if let current = opening, current.mode != mode { opening = nil }
        // Round-2 MINOR-R2 (the aborted-round window): a parked parcel is
        // valid for exactly the ROUND that parked it, and the round is
        // over the moment the detail reports any mode other than the
        // parcel's landing mode — a competing switch (⌘2–⌘6) in the
        // tens-of-ms before the arriving surface consumes leaves the
        // parcel orphaned on a SAME-post detail, which register/unregister
        // clearing (detail identity, not round) can never see. Ordering is
        // safe: the park precedes `applyMode(.write)`, whose own onChange
        // reports the LANDING mode first and keeps the parcel.
        if pendingWriteIntent != nil, mode != .write {
            pendingWriteIntent = nil
        }
        if pendingTakesLanding != nil, mode != .takes {
            pendingTakesLanding = nil
        }
        if pendingLensLanding != nil, mode != .lenses {
            pendingLensLanding = nil
        }
        if pendingCompareLanding != nil, mode != .compare {
            pendingCompareLanding = nil
        }
    }

    /// What a stale targeted mode request says (round-1 MAJOR, half a: the
    /// mismatch branch was a silent door inside the anti-silent-door
    /// machinery). Shared with the pins.
    static let staleModeRequestNote =
        "The open note changed — that request no longer applies."

    /// Routes a mode switch to the mounted detail. `postID` targets a
    /// specific post (the sidebar rail); nil addresses whichever detail is
    /// visible (⌘1–⌘6). No detail, or a stale targeted request ⇒ the
    /// request SPEAKS instead of vanishing (the Stage 0 silent-drop class).
    @discardableResult
    func requestMode(_ mode: PostMode, postID: String? = nil) -> Bool {
        if let postID, let active = activePostID, postID != active {
            // Stale targeted request — a different post mounted meanwhile.
            refuse?(Self.staleModeRequestNote)
            return false
        }
        guard let applyMode else {
            refuse?(CapabilityRegistry.capability(.switchMode).unavailableNote)
            return false
        }
        applyMode(mode)
        return true
    }

    // MARK: - The note tray's one panel (the post-13l polish round, C1)

    /// **A tray request parked across a pane focus change**, the
    /// `pendingWriteIntent` choreography exactly: one-shot, STAMPED with its
    /// post, consumed by the arriving detail's registration.
    ///
    /// Why parking is needed at all: the ⌫ badge lives on the pane's context
    /// bar, ABOVE the detail, and an UNFOCUSED pane renders read-cheap — no
    /// `PostDetailView`, no inspector, nothing registered. So the badge
    /// focuses its pane first and the request waits the one runloop the mount
    /// takes.
    var pendingTrayRequest: TrayRequest?

    /// **Routes a tray request to the mounted detail's inspector.**
    ///
    /// It is its OWN seam rather than a `RoutedCommand` through the handler
    /// stack, and the reason is ordering: `EditorView` registers a handler
    /// INSIDE the post detail and therefore later, so a LIFO dispatch would
    /// reach the editor's own sheet first and the panel would open in the
    /// wrong place — a coin-flip on mount order deciding where a door leads.
    /// The detail owns the inspector; the detail is what registers this.
    ///
    /// **It never parks by itself**, deliberately: a caller that has its own
    /// fallback (the bars' sheet hosts) must be told "no" rather than have a
    /// request quietly wait and then open a second panel later. The ONE
    /// caller that wants parking is the badge, which has just focused its
    /// pane and knows a detail is arriving — it sets `pendingTrayRequest`
    /// itself, which is why that property is visible.
    ///
    /// Returns whether the panel was opened.
    @discardableResult
    func requestNoteTray(_ request: TrayRequest) -> Bool {
        guard let showTray, activePostID == request.postID else { return false }
        showTray(request)
        return true
    }

    // MARK: - The block's history pane (the post-13l polish round, row 17)

    /// How a Block History request reaches the mounted detail's INSPECTOR.
    /// Its own seam beside `showTray`, for the identical ordering reason —
    /// `EditorView` registers a handler INSIDE the detail and therefore
    /// later, so a LIFO dispatch would reach the editor's own sheet first and
    /// the same door would land in two different places depending on mount
    /// order.
    @ObservationIgnored private var showBlockHistory: ((BlockHistoryRequest) -> Void)?

    /// **Routes a history request to the mounted detail's inspector.**
    ///
    /// It never parks, deliberately, and for a sharper reason than the tray's:
    /// the doors that raise it (both bottom bars, ⌘K) are rendered by surfaces
    /// that are ALREADY mounted and already know their block — there is no
    /// focus change to wait out. A caller with its own sheet fallback must be
    /// told "no" so it can use it; a caller with none gets the registry's
    /// honest note through the dispatch road.
    ///
    /// Returns whether the panel was opened.
    @discardableResult
    func requestBlockHistory(_ request: BlockHistoryRequest) -> Bool {
        guard let showBlockHistory, activePostID == request.postID else { return false }
        showBlockHistory(request)
        return true
    }

    /// **The FOCUSED block's history, for a door with no surface handler**
    /// (the Act 10 correction round, batch G — row 86(d)). The ⌘K "Block
    /// History" row is dispatched to the mounted SURFACE's command handler;
    /// Write, Takes and Lenses register one, but Read's faces and Blocks
    /// register none — so from those modes the row fell through to the
    /// registry's "put the caret in a block" note while a block was plainly
    /// selected (the walk's capture: Blocks, row 03 focused, the sentence).
    /// What those modes DO report is `focusedBlock` (row 39's one memory);
    /// this asks the mounted detail's inspector for exactly that block's
    /// history. Returns whether the pane opened (no block in hand ⇒ false,
    /// and the caller speaks the honest note).
    @discardableResult
    func requestBlockHistoryForFocusedBlock() -> Bool {
        guard let fact = focusedBlock, fact.postID == activePostID else { return false }
        return requestBlockHistory(BlockHistoryRequest(
            postID: fact.postID, blockID: fact.blockID, focusedVariantID: fact.variantID))
    }

    // MARK: - The masthead's tag field (the Act 10 correction round, row 15)

    /// How ⌘⇧I and the ⌘K row reach the mounted detail's masthead — the ONE
    /// inline tag field its ＃ opens. Its own seam beside the tray's, for
    /// the same reason: the detail owns the masthead, so the detail registers
    /// it; nothing else can open a field that lives in its state.
    @ObservationIgnored private var openTagField: (() -> Void)?

    /// **Opens the mounted detail's tag field.** It never parks: a tag field
    /// with no note under it has nothing to tag, and the caller speaks the
    /// registry's honest note instead. Returns whether a field opened.
    @discardableResult
    func requestTagField() -> Bool {
        guard let openTagField, activePostID != nil else { return false }
        openTagField()
        return true
    }

    // MARK: - The note's Versions pane (the post-13l polish round, rows 16/23)

    /// How a Versions request reaches the mounted detail's INSPECTOR. Its own
    /// seam beside the other two, for the identical ordering reason — the
    /// detail owns the inspector, so the detail is what registers this.
    @ObservationIgnored private var showVersions: (() -> Void)?

    /// **Routes a Versions request to the mounted detail's inspector.**
    ///
    /// It carries no payload: the listing is the NOTE's, and the detail
    /// already knows which note it is. It never parks, for
    /// `requestBlockHistory`'s reason — the doors that raise it are rendered
    /// by surfaces that are already mounted, so there is no focus change to
    /// wait out, and a caller with its own sheet fallback must be told "no".
    ///
    /// Returns whether the panel was opened.
    @discardableResult
    func requestNoteVersions(postID: String) -> Bool {
        guard let showVersions, activePostID == postID else { return false }
        showVersions()
        return true
    }

    // MARK: - Takes-board attachment (13c 2B)

    /// A mounted takes board reports itself here so the registry's take
    /// family can read the ATTACHMENT rather than the post-detail mode that
    /// used to imply it. The book spread's takes page mounts a board with no
    /// detail around it; `activeMode` is nil there, and without this the
    /// whole take family (⌘S included) would grey out over a board that
    /// works perfectly (Stage 4 lesson 2's availability half).
    ///
    /// A SET of tokens rather than a flag: mount/unmount order is SwiftUI's,
    /// and an arriving board's `onAppear` can precede the departing one's
    /// `onDisappear` — a boolean would be cleared by the teardown of a board
    /// that no longer exists (the `registerDetail` token discipline, same
    /// hazard, same shape of fix).
    @ObservationIgnored private var takesBoardTokens: Set<UUID> = []

    /// Observable so menu enablement re-evaluates when a board mounts.
    private(set) var takesBoardAttached = false

    func attachTakesBoard() -> UUID {
        let token = UUID()
        takesBoardTokens.insert(token)
        takesBoardAttached = true
        return token
    }

    func detachTakesBoard(_ token: UUID) {
        takesBoardTokens.remove(token)
        takesBoardAttached = !takesBoardTokens.isEmpty
    }

    // MARK: - Read's editable face (the Act 10 correction round, R-cor-7)

    /// READ's `edit` face reports itself here while it is on screen — the
    /// takes board's shape exactly, for the same reason: the mode says
    /// "Read", and only the host knows whether the editable index surface or
    /// the read-only page is showing. A SET of tokens (mount order is
    /// SwiftUI's; a flag would be cleared by a departing face's teardown).
    @ObservationIgnored private var readEditTokens: Set<UUID> = []

    /// Observable so menu enablement re-evaluates when the face flips.
    private(set) var readEditAttached = false

    func attachReadEdit() -> UUID {
        let token = UUID()
        readEditTokens.insert(token)
        readEditAttached = true
        return token
    }

    func detachReadEdit(_ token: UUID) {
        readEditTokens.remove(token)
        readEditAttached = !readEditTokens.isEmpty
    }

    // MARK: - Write's take panel (VX-154, the VX-282 run)

    /// Write's take panel reports itself here while it is up — the takes
    /// board's shape exactly, for its reason: availability must track the
    /// surface that actually answers, and while the panel is the LIFO top the
    /// verbs that act where she writes cannot act from it
    /// (`CapabilityContext.writeTakesPanelAttached`). A SET of tokens (mount
    /// order is SwiftUI's; a flag would be cleared by a departing teardown).
    @ObservationIgnored private var writeTakesPanelTokens: Set<UUID> = []

    /// Observable so menu enablement re-evaluates when the panel comes and goes.
    private(set) var writeTakesPanelAttached = false

    func attachWriteTakesPanel() -> UUID {
        let token = UUID()
        writeTakesPanelTokens.insert(token)
        writeTakesPanelAttached = true
        return token
    }

    func detachWriteTakesPanel(_ token: UUID) {
        writeTakesPanelTokens.remove(token)
        writeTakesPanelAttached = !writeTakesPanelTokens.isEmpty
    }

    // MARK: - Surface command handlers (LIFO — last mounted wins)

    @ObservationIgnored private var handlers: [(token: UUID, handler: (RoutedCommand) -> Bool)] = []

    var handlerCount: Int { handlers.count }

    func registerHandler(_ handler: @escaping (RoutedCommand) -> Bool) -> UUID {
        let token = UUID()
        handlers.append((token, handler))
        return token
    }

    func unregisterHandler(_ token: UUID) {
        handlers.removeAll { $0.token == token }
    }

    /// Routes a command to the top-most handler that consumes it. Nothing
    /// consumed ⇒ the registry's honest note speaks — UNLESS the caller has
    /// its own fallback act (`speakingWhenUnhandled: false` — the round-1
    /// MINOR-1 class: `toggleSeal`'s shell fallback SEALS in handler-less
    /// modes, so a "no post open" refusal flashing first was factually
    /// wrong and immediately contradicted). Returns consumption.
    @discardableResult
    func dispatch(_ command: RoutedCommand, speakingWhenUnhandled: Bool = true) -> Bool {
        for entry in handlers.reversed() where entry.handler(command) {
            return true
        }
        if speakingWhenUnhandled {
            refuse?(CapabilityRegistry.unhandledNote(for: command, context: currentContext()))
        }
        return false
    }

    // MARK: - Choreography intents (one-shot, consumed by the arriving surface)

    /// A fire-and-DO landing in Write — parked here across the mode
    /// switch, consumed by the arriving editor's first render.
    var pendingWriteIntent: WriteIntent?
    /// A fire-and-DO landing in Takes (bloom this block on arrival).
    var pendingTakesLanding: TakesLanding?
    /// 13n-b U4: a landing on the Lenses board (show this saved lens) —
    /// observed, so a board already mounted consumes it too.
    var pendingLensLanding: LensLanding?
    /// VX-298 (VX-336 U6a): a landing on the Compare board (these notes beside
    /// the anchor) — observed, like the lens landing.
    var pendingCompareLanding: CompareLanding?

    // MARK: - Composition wiring (set once by the session)

    /// Speech lands in the StatusCenter (AD-14's one presentation).
    @ObservationIgnored var refuse: ((String) -> Void)?
    /// Whether a full-document Write editor is attached (wired to the
    /// EditorRouter; reads its observable `active`, so menu enablement
    /// tracks it).
    @ObservationIgnored var writeEditorAttached: () -> Bool = { false }
    /// Whether that editor owns its own scroll view — the post detail's
    /// full-document editor, never the book/spread/pool inline one (QoL batch
    /// 3, L6; see `CapabilityContext.writeEditorOwnsScrollView`).
    @ObservationIgnored var writeEditorOwnsScrollView: () -> Bool = { false }
    /// 13n-b U4 (AF-11 F-2): whether the MCP door holds a last AI change
    /// with somewhere to show (wired by `MCPDoor.attach`).
    @ObservationIgnored var aiLastChangeAvailable: () -> Bool = { false }
    /// Whether the structural undo stack has an entry (wired to the undo
    /// menu state).
    @ObservationIgnored var undoAvailable: () -> Bool = { false }
    /// Whether the structural REDO stack has an entry (13c 1B — A10).
    @ObservationIgnored var redoAvailable: () -> Bool = { false }
    /// The workspace facts behind the navigation core (13f batch 3): how
    /// many notes the window has open, and whether its active pane can walk
    /// back / forward. Wired by the SHELL to its own `WorkspaceModel` —
    /// the workspace is per-window state and this router is the app's, so
    /// the closure is what keeps the two straight (and is where batch 4's
    /// focused-window refinement lands, without a type here changing).
    @ObservationIgnored var openNoteCount: () -> Int = { 0 }
    @ObservationIgnored var canNavigateBack: () -> Bool = { false }
    @ObservationIgnored var canNavigateForward: () -> Bool = { false }
    /// 13f batch 4 — the split's two facts, wired the same way. These read
    /// the FOCUSED pane's world (the navigation pair does too, since
    /// `WorkspaceModel.history()` now defaults to the focused pane) — the
    /// gate's focused-pane refinement, landed where batch 3 cut for it.
    @ObservationIgnored var paneCount: () -> Int = { 1 }
    @ObservationIgnored var canOpenBeside: () -> Bool = { false }
    /// 13f batch 6 (W4): is the focused pane showing a thing a star can
    /// point at? Wired the same way, to the KEY window's workspace.
    @ObservationIgnored var canStarCurrent: () -> Bool = { false }
    /// 18o U1 (17e (12)): the KEY window's kind — the sidebar toggle's gate
    /// as a registry fact. Wired the same way, through the window registry.
    @ObservationIgnored var windowKind: () -> WindowRegistry.Kind? = { nil }
    /// 13n-c Stage B R1 B6: the library's wing count (⌘L's gate) — wired by
    /// the session to its `WingState`.
    @ObservationIgnored var wingCount: () -> Int = { 1 }

    // MARK: - Context assembly

    func currentContext() -> CapabilityContext {
        CapabilityContext(
            mode: activeMode,
            writeEditorAttached: writeEditorAttached(),
            writeEditorOwnsScrollView: writeEditorOwnsScrollView(),
            takesBoardAttached: takesBoardAttached,
            readEditAttached: readEditAttached,
            writeTakesPanelAttached: writeTakesPanelAttached,
            aiLastChangeAvailable: aiLastChangeAvailable(),
            undoAvailable: undoAvailable(),
            redoAvailable: redoAvailable(),
            openNoteCount: openNoteCount(),
            canNavigateBack: canNavigateBack(),
            canNavigateForward: canNavigateForward(),
            paneCount: paneCount(),
            canOpenBeside: canOpenBeside(),
            canStarCurrent: canStarCurrent(),
            windowKind: windowKind(),
            wingCount: wingCount())
    }

    func isEnabled(_ id: CapabilityID) -> Bool {
        CapabilityRegistry.isEnabled(id, in: currentContext())
    }
}
