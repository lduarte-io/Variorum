//
//  MobileShellRouter.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shell's shared routing state, replacing
//  Phase 8's `CaptureRouter` (retired with the capture surface). Two
//  concerns, both routing:
//
//  · **The active editor** (the CaptureRouter parallel, re-pointed at the
//    S1 Write surface): the app-level background transition flushes the
//    open editor's pending autosave BEFORE the sync round runs
//    (`onDisappear` never fires on whole-app backgrounding — the Phase 8
//    review-round-2 finding, carried; the pin re-pointed at
//    `MobileEditorViewModel` rides `MobileShellTests`).
//
//  · **The live voice** (LK2's preference, applied app-wide): the shell is
//    the ONE voice authority — Settings flips it here, and the flip
//    reaches the stored preference, `MobileEditorStyle`, every observing
//    chrome surface (shelf, library, tab bar, masthead), and any OPEN
//    editor surface (`applyVoiceChange`). The S1 masthead switch door
//    RETIRED with this batch (P11's placement lands: Settings is the
//    home; two doors for one preference was clutter — recorded).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileShellRouter {
    /// The open Write surface, when one exists (weak — the screen owns it).
    weak var activeEditor: MobileEditorViewModel?

    /// The live phone voice — the shell's one authority (LK2).
    private(set) var voice: ThemeVoice

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = MobileVoicePreference.current(defaults)
        voice = stored
        MobileEditorStyle.voice = stored
    }

    /// The ONE voice flip: preference + style + every open surface.
    func setVoice(_ next: ThemeVoice) {
        guard next != voice else { return }
        voice = next
        MobileVoicePreference.set(next, defaults)
        MobileEditorStyle.voice = next
        activeEditor?.applyVoiceChange()
    }
}

/// The background transition, extracted for tests (the Phase 8 shape,
/// re-pointed at the new editor): the active editor's pending text lands
/// in the STORE first, then one sync round pushes it — ordering matters,
/// or the round would carry the pre-flush text and the fresh write would
/// wait for the next foreground. `finish()` is the S1 teardown backstop
/// (mints the open tail, attaches trailing runs, flushes).
@MainActor
func performBackgroundFlush(editor: MobileEditorViewModel?, sync: SyncSession?) async {
    await editor?.finish()
    await sync?.flush()
}
