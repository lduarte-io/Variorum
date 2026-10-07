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

    /// **Where each note's Write page was left, for the session** (VM-10, her
    /// ruled arrival shape (2)). Here for the same reason `quickNote` is: it
    /// must outlive any one screen, and this is the session-lived object both
    /// tab stacks share. The type and every rule live in the Write feature.
    @ObservationIgnored let writePlaces = MobileWritePlaces()

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
/// **Both halves matter, and 4.5a's Q4 is that the shipped grant had
/// neither.** The grant was taken ASYNCHRONOUSLY — one hop after the phase
/// change, inside the `Task` — which is the anti-pattern Apple's own
/// documentation names (*"don't call this at the very end of
/// `applicationDidEnterBackground` and expect your app to continue
/// running"*); and it used the SINGLE-ARGUMENT form, with **no expiration
/// handler**, which makes an overrun fatal (`0x2182bad2`) rather than
/// recoverable — on a routine whose last leg is a network round.
///
/// So `begin` now takes the handler UIKit will call shortly before time
/// runs out, and `BackgroundAssertion` below is what holds the token.
@MainActor
struct BackgroundTaskGrant {
    /// `(name, expirationHandler) -> token`. The handler is delivered on
    /// the main thread by UIKit's contract.
    var begin: (String, @escaping @MainActor () -> Void) -> UIBackgroundTaskIdentifier
    var end: (UIBackgroundTaskIdentifier) -> Void

    static let application = BackgroundTaskGrant(
        begin: { name, expiration in
            UIApplication.shared.beginBackgroundTask(
                withName: name, expirationHandler: expiration)
        },
        end: { UIApplication.shared.endBackgroundTask($0) })

    /// For worlds with no application to ask (tests, previews): nothing is
    /// granted and nothing can expire, so the flush runs to completion on
    /// its own — which is exactly what an unhosted call should do.
    static let none = BackgroundTaskGrant(begin: { _, _ in .invalid }, end: { _ in })
}

/// **One background assertion, held for the whole flush and ended exactly
/// once** (4.5a, Q4). An unbalanced grant is a watchdog kill, so `end()` is
/// idempotent and both roads out — the work finishing and the expiration
/// handler firing — go through it.
@MainActor
final class BackgroundAssertion {
    private let grant: BackgroundTaskGrant
    private var token: UIBackgroundTaskIdentifier = .invalid
    private var ended = false

    /// What to stop when iOS says time is up. **Assigned AFTER the work
    /// exists**, which is safe by construction rather than by luck: the
    /// handler is installed at `begin` time (before the `Task` it must
    /// cancel can exist), it is delivered on the main thread, and this
    /// initializer's caller does not yield before setting it — so the
    /// handler cannot run against an empty slot.
    ///
    /// **BOTH construction roads set it** (4.5a fix round, MAJOR 4): the
    /// phase-change handler below, and `performBackgroundFlush`'s own
    /// self-minting road. Leaving it nil does not merely lose a nicety — it
    /// means the token goes back while the work runs on, which is the
    /// `0xdead10cc` shape this type exists to prevent. If a third
    /// construction site ever appears, it owes teeth too.
    var onExpire: (@MainActor () -> Void)?

    init(grant: BackgroundTaskGrant, name: String) {
        self.grant = grant
        token = grant.begin(name) { [weak self] in self?.expire() }
    }

    private func expire() {
        onExpire?()
        end()
    }

    /// Hands the time back, exactly once. **The token is cleared with it**
    /// (4.5a fix round, MAJOR 4): it used to survive, so the `isGranted`
    /// property read `true` after the assertion had been returned — and the
    /// network leg's guard was reading exactly that. That property is gone
    /// with the guard (see the flush's last leg), and the token no longer
    /// outlives what it stands for.
    func end() {
        guard !ended else { return }
        ended = true
        guard token != .invalid else { return }
        grant.end(token)
        token = .invalid
    }
}

/// The background transition, extracted for tests (the Phase 8 shape,
/// re-pointed at the liveness authority — S3 ladder MAJOR 1): EVERY
/// registered editor's pending text lands in the STORE first, then one
/// sync round pushes it — ordering matters, or the round would carry the
/// pre-flush text and the fresh write would wait for the next foreground.
/// `finish()` per editor is the S1 teardown backstop (mints the open
/// tail, attaches trailing runs, flushes).
///
/// **Round 2 (M5, A5-3/A5-4/A5-8): the quick-note box goes FIRST**, and
/// inside it the ruled order is MINT, then flush. The mint covers the
/// sub-mint window (text she typed less than a second ago, which lives only
/// in the box); the flush covers everything the mint already wrote. This is
/// the leg that makes her requirement — *"if the user just closes the app,
/// their note should still be saved!"* — true at the moment the app leaves
/// the screen.
///
/// *(4.5a, Q5 — a correction to what this comment used to claim. It said
/// **"reversed, the last word is lost"**, and that does not hold:
/// `mintNow` reads the BOX's current text, so a flush-then-mint order lands
/// the same bytes today. A5-4's order stays — it is the one that survives
/// the mint ever becoming more than a single read — but the REASON is
/// robustness, not a live loss, and a comment stating a mechanism that
/// isn't there is how the next reader is made wrong.)*
/// **The assertion is normally taken by the CALLER** (4.5a, Q4 — the
/// phase-change handler takes it synchronously and passes it in as
/// `holding:`). A direct caller that has none gets one minted here, which
/// is what keeps every existing call site — and every test that drives this
/// routine straight — honest rather than ungranted.
///
/// **AND THE SELF-MINTING ROAD HAS THE SAME TEETH** (4.5a fix round,
/// MAJOR 4). It used to mint an assertion and never set `onExpire`, so on
/// that road iOS saying *"time is up"* handed the token back and **the
/// flush carried on running under a returned assertion** — writing SQLite
/// and then opening a network round, which is the exact inverse of Apple's
/// `0xdead10cc` guidance. A type whose doc advertises the guarantee on
/// *"every existing call site"* while one of its two construction sites
/// drops it is the class the twin-check exists for. The teeth need a task
/// to cancel, so this road makes one and cancels it — the same shape
/// `mobileScenePhaseChanged` builds around its own.
@MainActor
func performBackgroundFlush(
    editors: MobileLivenessAuthority,
    sync: SyncSession?,
    quickNote: MobileQuickNoteModel? = nil,
    savepoint: (@MainActor (String) async -> Void)? = nil,
    grant: BackgroundTaskGrant = .application,
    holding assertion: BackgroundAssertion? = nil
) async {
    guard assertion != nil else {
        let mine = BackgroundAssertion(
            grant: grant, name: "Variorum flush before suspension")
        let work = Task { @MainActor in
            await performBackgroundFlush(
                editors: editors, sync: sync, quickNote: quickNote,
                savepoint: savepoint, grant: grant, holding: mine)
        }
        mine.onExpire = { work.cancel() }
        // The caller's own cancellation reaches the child too — an
        // unstructured task does not inherit it, and a flush that outlives
        // the thing that asked for it is its own bug.
        await withTaskCancellationHandler { await work.value } onCancel: { work.cancel() }
        mine.end()
        return
    }
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
    //
    // **The cancellation checks are the expiration handler's teeth**
    // (Q4). When iOS says time is up it cancels this task; the two legs
    // above have already landed her text in SQLite, and the two below are
    // the ones worth abandoning rather than being killed inside.
    if let savepoint, !Task.isCancelled {
        for postID in editors.registeredPostIDs {
            if Task.isCancelled { break }
            await savepoint(postID)
        }
    }
    // The NETWORK leg — the long one, and the only one that can overrun a
    // grant. If iOS has said time is up, the expiration handler has already
    // cancelled this work and the outbox simply waits for the next
    // foreground, which is what the scene handler's own comment has always
    // promised.
    //
    // *(4.5a fix round — the architect's ruling on 4.5a's own report: the
    // `isGranted` half of this guard is GONE. On device an ungranted
    // assertion already fires the expiration handler, which cancels, so the
    // gate's only DISTINCT effect was in worlds with no application to ask
    // — tests and previews. A semantic nobody can observe in the product is
    // one the next reader will take for intentional product behaviour.
    // Cancellation is the mechanism; keep one, not two.)*
    guard !Task.isCancelled else { return }
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
///
/// **13p Batch 4 — the RE-LOCK leg** (the mobile-only-user expansion's
/// item (g)). `relock` is the phone's re-lock coordinator when one
/// exists; it is consulted at BOTH edges and the ORDER is load-bearing:
///
/// · leaving ⇒ the flush runs to completion FIRST (quick note minted,
///   editors flushed, savepoints landed, one sync round) and only then
///   does the library lock. A lock that beat the flush would close the
///   pool under her last keystrokes.
/// · returning ⇒ the coordinator is asked BEFORE `triggerSync()`, because
///   a return that locks must not first wake a round against a pool it is
///   about to close. It says whether it locked, and the trigger is
///   skipped when it did.
///
/// A nil coordinator (every pre-13p call site, and every test that does
/// not care) behaves exactly as before.
@MainActor
@discardableResult
func mobileScenePhaseChanged(
    _ phase: ScenePhase,
    editors: MobileLivenessAuthority,
    sync: SyncSession?,
    quickNote: MobileQuickNoteModel? = nil,
    savepoint: (@MainActor (String) async -> Void)? = nil,
    grant: BackgroundTaskGrant = .application,
    relock: MobileRelockCoordinator? = nil
) -> Task<Void, Never>? {
    switch phase {
    case .active:
        guard let relock else {
            sync?.triggerSync()
            return nil
        }
        return Task { @MainActor in
            let locked = await relock.didReturnToTheScreen()
            guard !locked else { return }
            sync?.triggerSync()
        }
    case .background:
        // **THE GRANT IS TAKEN HERE, SYNCHRONOUSLY, INSIDE THE PHASE-CHANGE
        // HANDLER** (4.5a, Q4). It used to be taken one hop later, inside
        // the `Task` — the anti-pattern Apple's documentation names by
        // hand. An assertion that arrives after iOS has begun suspending is
        // an assertion that may never be granted, and an ungranted
        // assertion means this flush writes SQLite with no protection
        // against suspension: `0xdead10cc`, *"held a database lock during
        // suspension"*.
        //
        // Before this round there was no grant at all and iOS simply
        // suspended us; the grant is what makes the flush safe, so taking
        // it late created a termination class rather than closing one.
        let assertion = BackgroundAssertion(
            grant: grant, name: "Variorum flush before suspension")
        let work = Task {
            defer { assertion.end() }
            await performBackgroundFlush(
                editors: editors, sync: sync, quickNote: quickNote,
                savepoint: savepoint, holding: assertion)
            // 13p Batch 4 (item g): the lock lands LAST, inside the same
            // grant — everything above has already put her text in the
            // store, so closing the pool now loses nothing. Deliberately
            // NOT gated on `Task.isCancelled`: if iOS is taking the app
            // away, dropping the key is the one leg that should still run.
            await relock?.didLeaveTheScreen()
        }
        // The expiration handler's job: STOP, then hand the time back. No
        // handler at all is what makes an overrun fatal (`0x2182bad2`)
        // instead of recoverable. Assigned after the `Task` exists and
        // before this function yields, so the handler can never fire
        // against an empty slot.
        assertion.onExpire = { work.cancel() }
        return work
    default:
        return nil
    }
}
