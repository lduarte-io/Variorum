//
//  MobileRelock.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — THE PHONE'S RE-LOCK DIAL (the mobile-only-user
//  expansion's item (g), her words: *"re-lock on background as the
//  phone's re-lock dial + the manual Lock Now act in demanded modes (the
//  hand-someone-your-phone case — a REAL boundary here, key material
//  dropped)"*).
//
//  THE PLATFORM MAPPING, stated once so nobody re-derives it. The dials
//  are SHARED (`ProtectionDials`); what each one MEANS is a per-platform
//  reading, and the phone's is:
//
//  · `relockOnSleepAndScreenLock` ⇒ **lock when Variorum leaves the
//    screen.** On the Mac that dial is sleep + screen lock; on the phone,
//    backgrounding IS the leaving (MobileSoul §5.1: the app dies without
//    warning, and `.background` is already this app's ⌘Q — the flush, the
//    savepoint and the sync round all hang off it). Locking there is a
//    REAL boundary, not theater: the pool closes and the key is dropped,
//    so handing someone the phone hands them a lobby.
//  · `relockAfterIdleMinutes` ⇒ **lock after time away.** The Mac polls
//    idle time because it stays running; a suspended phone cannot poll at
//    all, so the phone reads the same dial on RETURN — a short trip out
//    of the app costs nothing, a long one re-asks. Same dial, same
//    intent, honest mechanism.
//
//  Both re-check the dials AT FIRE TIME (the Mac monitors' own discipline)
//  and both end at `AppBootstrap.lock()`, which refuses under Auto by
//  itself — so no road here can produce the theater R13p-14 forbids.
//
//  ORDER IS LOAD-BEARING: on leaving, the flush runs FIRST (quick note
//  minted, editors flushed, savepoints landed, one sync round) and the
//  lock only after — a lock that beat the flush would close the pool
//  under her last keystrokes.
//

import Foundation
import VariorumCore

// MARK: - The policy (pure — the dials' phone reading)

nonisolated enum MobileRelockPolicy {
    /// The "lock after time away" rows, in minutes (0 = never). The Mac's
    /// idle picker offers the same shape; the phone's wording differs
    /// because the mechanism does.
    static let awayChoices = [0, 5, 15, 60]

    static func awayLabel(_ minutes: Int) -> String {
        switch minutes {
        case 0: return "Never"
        case 1: return "After a minute"
        case 60: return "After an hour"
        default: return "After \(minutes) minutes"
        }
    }

    /// Does leaving the screen lock the library right now?
    static func locksOnLeaving(_ dials: ProtectionDials) -> Bool {
        dials.mode.isDemanded && dials.relockOnSleepAndScreenLock
    }

    /// Does coming back after `awayFor` seconds lock it? (Nil/0 minutes =
    /// never; a demanded mode is required, exactly as on the Mac.)
    static func locksOnReturn(_ dials: ProtectionDials, awayFor seconds: TimeInterval) -> Bool {
        guard dials.mode.isDemanded else { return false }
        guard let minutes = dials.relockAfterIdleMinutes, minutes > 0 else { return false }
        return seconds >= Double(minutes) * 60
    }
}

// MARK: - The lock teardown (the phone's onWillLock — ladder R1-M2)

/// The phone's pre-lock teardown, mirroring the Mac's closure
/// (VariorumApp.swift's `bootstrap.onWillLock`): a lock FLUSHES every
/// registered editor and lands each open note's leaving savepoint BEFORE
/// the pool closes, then stops and RELEASES the mobile services — so no
/// pending keystroke races `StoreLockedError` into loss, no scheduler
/// fires into a locked window, and no stale services object survives past
/// the next `.ready`'s `guard services == nil`.
///
/// A FACTORY rather than an inline closure so the scripted world wires
/// exactly what production wires (`MobilePhoneLobbyTests` pins the
/// pending-edit-survives-a-lock round trip on this same function).
///
/// The quick-note box is DELIBERATELY not minted here: its worded refusal
/// — the text STAYS in the box and the sentence names the lock and the
/// road — is Batch 4's ruled behavior for the re-lock seam (her item (i)
/// ratification), and a silent mint here would replace that ruling.
@MainActor
func mobileWillLock(
    session: AppSession,
    editors: MobileLivenessAuthority,
    stopServices: @escaping @MainActor () -> Void
) -> @MainActor () async -> Void {
    {
        // ORDER IS LOAD-BEARING (the Mac's ruled teardown order): the
        // flush lands her text in the store, the savepoints insure it,
        // and only then do the services stop — all before the state flips
        // and the pool closes.
        await editors.flushAll()
        for postID in editors.registeredPostIDs {
            await session.savepointOnLeaving(postID)
        }
        stopServices()
    }
}

// MARK: - The coordinator (the scene seam's one holder)

/// Holds the leaving stamp and asks the policy at each phase change. It
/// is a tiny object on purpose: everything it decides is pure and lives
/// above, and everything it DOES is `lock`, which is the bootstrap's.
@MainActor
final class MobileRelockCoordinator {
    private let dials: @MainActor () -> ProtectionDials
    private let lock: @MainActor () async -> Void
    private let now: @MainActor () -> Date
    /// When the app last left the screen — nil before the first leaving,
    /// and cleared by a lock (a locked library has nothing left to
    /// re-lock, and a stale stamp must not lock the NEXT session).
    private(set) var leftAt: Date?

    init(
        dials: @escaping @MainActor () -> ProtectionDials,
        lock: @escaping @MainActor () async -> Void,
        now: @escaping @MainActor () -> Date = { Date() }
    ) {
        self.dials = dials
        self.lock = lock
        self.now = now
    }

    /// Called AFTER the background flush has finished (the ordering rule
    /// in this file's header). Locks when the dial says so.
    func didLeaveTheScreen() async {
        leftAt = now()
        guard MobileRelockPolicy.locksOnLeaving(dials()) else { return }
        leftAt = nil
        await lock()
    }

    /// Called on the way back in, BEFORE any sync trigger: a return that
    /// locks must not first wake a round against a pool it is about to
    /// close. Returns true when it locked, so the caller can skip that
    /// trigger.
    @discardableResult
    func didReturnToTheScreen() async -> Bool {
        guard let leftAt else { return false }
        let away = now().timeIntervalSince(leftAt)
        self.leftAt = nil
        guard MobileRelockPolicy.locksOnReturn(dials(), awayFor: away) else { return false }
        await lock()
        return true
    }
}
