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
        if activePostID != postID { focusedBlock = currentBlocks.current(for: postID) }
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
        activePostID = nil
        activeMode = nil
        // A genuine teardown (no successor mounted yet): any parked
        // choreography intent's round is over (round-1 MAJOR, half b).
        pendingWriteIntent = nil
        pendingTakesLanding = nil
        pendingTrayRequest = nil
        focusedBlock = nil
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
    private(set) var focusedBlock: FocusedBlock?

    /// A mounted writing surface reports where its caret is. Ignored for any
    /// note other than the one on screen — a background pane's caret is not
    /// "the block you're in" for the panel beside the foreground one.
    func noteFocusedBlock(_ blockID: String?, variantID: String?, postID: String) {
        guard activePostID == postID else { return }
        guard let blockID else {
            focusedBlock = nil
            return
        }
        let fact = FocusedBlock(postID: postID, blockID: blockID, variantID: variantID)
        guard focusedBlock != fact else { return }  // assign only on a real change
        focusedBlock = fact
        // Row 39: the fact is remembered for its note — every reporter
        // (Write's caret, the boards' ring, Read's selection, Blocks' row)
        // feeds the one memory through this door, nothing else.
        currentBlocks.remember(fact)
    }

    // MARK: - The current block, remembered per note (the correction round, row 39)

    /// The per-note memory behind `focusedBlock` — `CurrentBlockMemory`'s
    /// header has the whole argument. Session-scoped, persisted per note.
    @ObservationIgnored private var currentBlocks = CurrentBlockMemory()

    /// Where she last was in a note — mounted or not. The Library's Open
    /// door (batch E) lands here; a mode entering a mounted note reads the
    /// live `focusedBlock`, which this seeded.
    func currentBlock(for postID: String) -> FocusedBlock? {
        if let fact = focusedBlock, fact.postID == postID { return fact }
        return currentBlocks.current(for: postID)
    }

    /// A pin's reset (or a deleted note): the memory for one note goes.
    func forgetCurrentBlock(for postID: String) {
        currentBlocks.forget(postID: postID)
        if focusedBlock?.postID == postID { focusedBlock = nil }
    }

    /// The detail reports its mode truth (its own `@State` changed).
    func noteMode(_ mode: PostMode) {
        guard detailToken != nil else { return }
        activeMode = mode
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
            speak?(Self.staleModeRequestNote)
            return false
        }
        guard let applyMode else {
            speak?(CapabilityRegistry.capability(.switchMode).unavailableNote)
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
            speak?(CapabilityRegistry.unhandledNote(for: command, context: currentContext()))
        }
        return false
    }

    // MARK: - Choreography intents (one-shot, consumed by the arriving surface)

    /// A fire-and-DO landing in Write — parked here across the mode
    /// switch, consumed by the arriving editor's first render.
    var pendingWriteIntent: WriteIntent?
    /// A fire-and-DO landing in Takes (bloom this block on arrival).
    var pendingTakesLanding: TakesLanding?

    // MARK: - Composition wiring (set once by the session)

    /// Speech lands in the StatusCenter (AD-14's one presentation).
    @ObservationIgnored var speak: ((String) -> Void)?
    /// Whether a full-document Write editor is attached (wired to the
    /// EditorRouter; reads its observable `active`, so menu enablement
    /// tracks it).
    @ObservationIgnored var writeEditorAttached: () -> Bool = { false }
    /// Whether that editor owns its own scroll view — the post detail's
    /// full-document editor, never the book/spread/pool inline one (QoL batch
    /// 3, L6; see `CapabilityContext.writeEditorOwnsScrollView`).
    @ObservationIgnored var writeEditorOwnsScrollView: () -> Bool = { false }
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

    // MARK: - Context assembly

    func currentContext() -> CapabilityContext {
        CapabilityContext(
            mode: activeMode,
            writeEditorAttached: writeEditorAttached(),
            writeEditorOwnsScrollView: writeEditorOwnsScrollView(),
            takesBoardAttached: takesBoardAttached,
            readEditAttached: readEditAttached,
            undoAvailable: undoAvailable(),
            redoAvailable: redoAvailable(),
            openNoteCount: openNoteCount(),
            canNavigateBack: canNavigateBack(),
            canNavigateForward: canNavigateForward(),
            paneCount: paneCount(),
            canOpenBeside: canOpenBeside(),
            canStarCurrent: canStarCurrent())
    }

    func isEnabled(_ id: CapabilityID) -> Bool {
        CapabilityRegistry.isEnabled(id, in: currentContext())
    }
}
