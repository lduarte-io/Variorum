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
import SwiftUI
import UIKit
import VariorumCore

@MainActor
@Observable
final class MobileShellRouter {
    /// The one editors bookkeeping (BLOCKER/MAJOR 1's testable brain):
    /// registration set, liveness grants, background-flush targets.
    @ObservationIgnored let editors = MobileLivenessAuthority()

    /// The home screen's quick-note box (round 2, M5). It lives HERE and
    /// not in the shelf view's `@State` for one reason that is the whole
    /// feature: the app-lifecycle seam has to reach it. `scenePhase` →
    /// `.background` must be able to mint what is in the box before iOS
    /// suspends the app, and a `@State` on a view the shell may re-create
    /// is not a thing the scene handler can hold. The shell binds the
    /// store's session once the bootstrap is ready.
    @ObservationIgnored let quickNote = MobileQuickNoteModel()

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

/// **The iOS suspension grant (round 2, A5-4).** The survey found that
/// NOTHING in this app had ever called `beginBackgroundTask`: the
/// `.background` flush was a bare `Task` racing suspension with no grant
/// at all. That is a real robustness gap for the EDITOR as much as for
/// the quick note, so the grant lands on the one routine both use.
///
/// Injectable because a pin must be able to prove the grant is taken AND
/// ended — an unbalanced grant is a watchdog kill, which is a worse bug
/// than the one it fixes.
@MainActor
struct BackgroundTaskGrant {
    var begin: (String) -> UIBackgroundTaskIdentifier
    var end: (UIBackgroundTaskIdentifier) -> Void

    static let application = BackgroundTaskGrant(
        begin: { UIApplication.shared.beginBackgroundTask(withName: $0) },
        end: { UIApplication.shared.endBackgroundTask($0) })

    /// For worlds with no application to ask (tests, previews).
    static let none = BackgroundTaskGrant(begin: { _ in .invalid }, end: { _ in })
}

/// The background transition, extracted for tests (the Phase 8 shape,
/// re-pointed at the liveness authority — S3 ladder MAJOR 1): EVERY
/// registered editor's pending text lands in the STORE first, then one
/// sync round pushes it — ordering matters, or the round would carry the
/// pre-flush text and the fresh write would wait for the next foreground.
/// `finish()` per editor is the S1 teardown backstop (mints the open
/// tail, attaches trailing runs, flushes).
///
/// **Round 2 (M5, A5-3/A5-4/A5-8): the quick-note box goes FIRST, and its
/// order inside is binding — MINT, then flush.** The mint covers the
/// sub-mint window (text she typed less than a second ago, which lives
/// only in the box); the flush covers everything the mint already wrote.
/// Reversed, the last word is lost. This is the leg that makes her
/// requirement — *"if the user just closes the app, their note should
/// still be saved!"* — true at the moment the app leaves the screen.
@MainActor
func performBackgroundFlush(
    editors: MobileLivenessAuthority,
    sync: SyncSession?,
    quickNote: MobileQuickNoteModel? = nil,
    savepoint: (@MainActor (String) async -> Void)? = nil,
    grant: BackgroundTaskGrant = .application
) async {
    let token = grant.begin("Variorum flush before suspension")
    defer { grant.end(token) }
    await quickNote?.fileOnLeaving()
    await editors.flushAll()
    // **THE SAVEPOINT LEG (round 2 batch 4 — PR7).** *"unless you've been
    // remembering to commit version history is kind of weak right now"* —
    // her 13j words. 13j's answer was `AppSession.savepointOnLeaving`, the
    // sixth quiet auto-commit occasion; it sits deliberately OUTSIDE the
    // `#if os(macOS)` fence so a second platform owes a hook, never a
    // rule. The phone had zero call sites until now.
    //
    // **On iOS, backgrounding IS ⌘Q** (MobileSoul §5.1: the app dies
    // without warning), so this is the leaving that matters most — and it
    // is the one the Mac's own hook could never cover.
    //
    // ORDER: after `flushAll` and BEFORE the sync round. `closeAutoCommit`
    // reads `working_text` rows, so the flush must have landed them; and
    // the savepoint's own rows must exist before the round pushes, or they
    // wait for the next foreground. (`savepointOnLeaving` flushes again
    // internally — a no-op on a coordinator this call just drained — so
    // the two are not a duplicated flush, they are a guaranteed one.)
    if let savepoint {
        for postID in editors.registeredPostIDs {
            await savepoint(postID)
        }
    }
    await sync?.flush()
}

/// The scene's phase handler, extracted from `VariorumMobileApp` so the
/// routing itself is pinnable rather than only the routine it calls (the
/// round's own lesson: a pin over a configured property proves nothing
/// about what runs). Returns the work it started so a test can await it;
/// the app ignores the value.
///
/// `.inactive` stays deliberately unhandled — it is the app-switcher and
/// Control Center peek, and a real leaving passes through `.background`,
/// which is where the grant and the flush live.
@MainActor
@discardableResult
func mobileScenePhaseChanged(
    _ phase: ScenePhase,
    editors: MobileLivenessAuthority,
    sync: SyncSession?,
    quickNote: MobileQuickNoteModel? = nil,
    savepoint: (@MainActor (String) async -> Void)? = nil,
    grant: BackgroundTaskGrant = .application
) -> Task<Void, Never>? {
    switch phase {
    case .active:
        sync?.triggerSync()
        return nil
    case .background:
        return Task {
            await performBackgroundFlush(
                editors: editors, sync: sync, quickNote: quickNote,
                savepoint: savepoint, grant: grant)
        }
    default:
        return nil
    }
}
