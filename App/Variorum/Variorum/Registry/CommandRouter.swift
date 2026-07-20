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
        return token
    }

    func unregisterDetail(_ token: UUID) {
        guard token == detailToken else { return }  // a stale teardown after the next mount
        detailToken = nil
        applyMode = nil
        activePostID = nil
        activeMode = nil
    }

    /// The detail reports its mode truth (its own `@State` changed).
    func noteMode(_ mode: PostMode) {
        guard detailToken != nil else { return }
        activeMode = mode
    }

    /// Routes a mode switch to the mounted detail. `postID` targets a
    /// specific post (the sidebar rail); nil addresses whichever detail is
    /// visible (⌘1–⌘7). No detail ⇒ the request SPEAKS instead of
    /// vanishing (the Stage 0 silent-drop class).
    @discardableResult
    func requestMode(_ mode: PostMode, postID: String? = nil) -> Bool {
        if let postID, let active = activePostID, postID != active {
            return false  // stale targeted request — a different post mounted meanwhile
        }
        guard let applyMode else {
            speak?(CapabilityRegistry.capability(.switchMode).unavailableNote)
            return false
        }
        applyMode(mode)
        return true
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
    /// consumed ⇒ the registry's honest note speaks. Returns consumption.
    @discardableResult
    func dispatch(_ command: RoutedCommand) -> Bool {
        for entry in handlers.reversed() where entry.handler(command) {
            return true
        }
        speak?(CapabilityRegistry.unhandledNote(for: command, context: currentContext()))
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
    /// Whether the structural undo stack has an entry (wired to the undo
    /// menu state).
    @ObservationIgnored var undoAvailable: () -> Bool = { false }

    // MARK: - Context assembly

    func currentContext() -> CapabilityContext {
        CapabilityContext(
            mode: activeMode,
            writeEditorAttached: writeEditorAttached(),
            undoAvailable: undoAvailable())
    }

    func isEnabled(_ id: CapabilityID) -> Bool {
        CapabilityRegistry.isEnabled(id, in: currentContext())
    }
}
