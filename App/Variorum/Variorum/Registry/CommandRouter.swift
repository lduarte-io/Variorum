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

    /// The post detail registers itself on appear; `applyMode` is how a
    /// routed request reaches its `@State` (composition, not broadcast).
    func registerDetail(
        postID: String, mode: PostMode, applyMode: @escaping (PostMode) -> Void
    ) -> UUID {
        let token = UUID()
        detailToken = token
        activePostID = postID
        activeMode = mode
        self.applyMode = applyMode
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
        activePostID = nil
        activeMode = nil
        // A genuine teardown (no successor mounted yet): any parked
        // choreography intent's round is over (round-1 MAJOR, half b).
        pendingWriteIntent = nil
        pendingTakesLanding = nil
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
        "The open post changed — that request no longer applies."

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

    // MARK: - Context assembly

    func currentContext() -> CapabilityContext {
        CapabilityContext(
            mode: activeMode,
            writeEditorAttached: writeEditorAttached(),
            writeEditorOwnsScrollView: writeEditorOwnsScrollView(),
            takesBoardAttached: takesBoardAttached,
            undoAvailable: undoAvailable(),
            redoAvailable: redoAvailable())
    }

    func isEnabled(_ id: CapabilityID) -> Bool {
        CapabilityRegistry.isEnabled(id, in: currentContext())
    }
}
