//
//  MobileShellRouter.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shell's shared routing state, replacing
//  Phase 8's `CaptureRouter` (retired with the capture surface). Two
//  concerns, both routing:
//
//  · **The editors** (S3 ladder, round-1 BLOCKER + MAJOR 1 — the fix
//    replaced the single weak `activeEditor` slot): `MobileLivenessAuthority`
//    is the ONE bookkeeping for every open Write surface — exactly one
//    live editor anywhere, hidden-stack editors stood down, the app-level
//    background flush covering EVERY registered editor (never just the
//    most recently registered one; `onDisappear` never fires on whole-app
//    backgrounding — the Phase 8 review-round-2 finding, carried).
//
//  · **The live voice** (LK2's preference, applied app-wide): the shell is
//    the ONE voice authority — Settings flips it here, and the flip
//    reaches the stored preference, `MobileEditorStyle`, every observing
//    chrome surface (shelf, library, tab bar, masthead), and EVERY
//    registered editor surface through the liveness authority (MINOR 2 —
//    a stood-down editor restyles too, so no mixed-voice storage survives
//    a flip). The S1 masthead switch door RETIRED with this batch (P11's
//    placement lands: Settings is the home; two doors for one preference
//    was clutter — recorded).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileShellRouter {
    /// The one editors bookkeeping (BLOCKER/MAJOR 1's testable brain):
    /// registration set, liveness grants, background-flush targets.
    @ObservationIgnored let editors = MobileLivenessAuthority()

    /// The live phone voice — the shell's one authority (LK2).
    private(set) var voice: ThemeVoice

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = MobileVoicePreference.current(defaults)
        voice = stored
        MobileEditorStyle.voice = stored
    }

    /// The ONE voice flip: preference + style + every registered surface.
    func setVoice(_ next: ThemeVoice) {
        guard next != voice else { return }
        voice = next
        MobileVoicePreference.set(next, defaults)
        MobileEditorStyle.voice = next
        editors.applyVoiceChangeEverywhere()
    }
}

/// The background transition, extracted for tests (the Phase 8 shape,
/// re-pointed at the liveness authority — S3 ladder MAJOR 1): EVERY
/// registered editor's pending text lands in the STORE first, then one
/// sync round pushes it — ordering matters, or the round would carry the
/// pre-flush text and the fresh write would wait for the next foreground.
/// `finish()` per editor is the S1 teardown backstop (mints the open
/// tail, attaches trailing runs, flushes).
@MainActor
func performBackgroundFlush(editors: MobileLivenessAuthority, sync: SyncSession?) async {
    await editors.flushAll()
    await sync?.flush()
}
