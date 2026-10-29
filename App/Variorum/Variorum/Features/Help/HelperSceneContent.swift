//
//  HelperSceneContent.swift
//  Variorum
//
//  The ⌘/ helper WINDOW's content — what `VariorumApp`'s
//  `Window("Shortcuts & Dictionary")` hosts. Moved out of the scene closure
//  (`SettingsSceneContent`'s precedent, VX-224) so a pin mounts exactly what
//  the window shows.
//
//  **F-FW-2 (the VX-677 run, the fixes unit — `notes/plans/fixes/vx-677-
//  editor-panes-ai-door.md`, FIXES RECORD, F-3): the window's ROOT carries the
//  open library's voice, as every window root does.** The scene closure built
//  `HelperView()` with no `ThemeStore` in its environment, so the helper read
//  `VoiceTokens.fallback` — Terminal — whatever voice she had chosen: the
//  final walk filmed the tab in Terminal's mono and lowercase headings while
//  the app was in Study (S-572-1/2), defeating VX-572's "the description column
//  in the voice's face" in Study. The in-host face pin stayed green because it
//  hands the tab its tokens itself. THIS COMMIT IS THE SEAM ONLY (behaviour
//  unchanged — the content is still the bare `HelperView()`), so the pin that
//  mounts it (`HelperWindowThemeTests`) is red here, on the pre-fix tree.
//

import SwiftUI
import VariorumCore

struct HelperSceneContent: View {
    let state: AppBootstrap.State

    var body: some View {
        HelperView()
    }
}

#if DEBUG
/// **F-FW-2's pin door** (DEBUG only; decides nothing): which theme each
/// mounted helper ROOT gave its window, keyed by the session it serves, and
/// the tokens each `HelperView` body last DREW in, keyed by the theme that
/// reached it — so a pin can ask "under THIS library, what did the window
/// draw?" (in-process SwiftUI builds no accessibility tree to read the face
/// from — `SurfaceComposition`'s recorded limit). A helper no theme reached
/// records its fallback tokens apart.
@MainActor
enum HelperViewOracle {
    private static var roots: [ObjectIdentifier: ThemeStore] = [:]
    private static var drawn: [ObjectIdentifier: VoiceTokens] = [:]
    /// What the last helper with NO theme drew in (the fallback face).
    private(set) static var lastUnthemed: VoiceTokens?

    static func root(_ theme: ThemeStore, for session: AppSession) {
        roots[ObjectIdentifier(session)] = theme
    }

    static func release(_ session: AppSession) {
        if let theme = roots.removeValue(forKey: ObjectIdentifier(session)) {
            drawn[ObjectIdentifier(theme)] = nil
        }
    }

    static func drew(_ tokens: VoiceTokens, theme: ThemeStore?) {
        if let theme {
            drawn[ObjectIdentifier(theme)] = tokens
        } else {
            lastUnthemed = tokens
        }
    }

    /// The tokens the helper under `session`'s window root last drew in —
    /// nil when that root's theme never reached a helper body.
    static func drawnTokens(forSession session: AppSession) -> VoiceTokens? {
        guard let theme = roots[ObjectIdentifier(session)] else { return nil }
        return drawn[ObjectIdentifier(theme)]
    }

    /// Whether a helper root stands for `session` (the pin's premise).
    static func hasRoot(forSession session: AppSession) -> Bool {
        roots[ObjectIdentifier(session)] != nil
    }

    /// A pin starts from no record of an unthemed helper.
    static func forgetUnthemed() { lastUnthemed = nil }
}
#endif
