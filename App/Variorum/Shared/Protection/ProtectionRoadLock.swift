//
//  ProtectionRoadLock.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-308 U4 — VX-445: THE LOCK ON THE NEW ROAD (`notes/plans/vx-308-accounts-key-doors.md` §5d; the record's R-U4-1..3).
//  VX-306 left the new road without a lock (`canLock` false — "every library it opens is Standard"); VX-307's crossings
//  made Castle real there, so a Castle library under Always ask could not lock without quitting. The bootstrap's
//  `lock()` now closes a Castle library behind the open road's own lobby; this file holds the parts that are not the
//  bootstrap's seam:
//
//    - THE POLICY (`RoadRelockPolicy`) — Castle locks: at sleep and screen lock (always on in Castle — decision 18), by
//      Lock Now, and after time away by THIS MAC'S SEALED idle minutes (`DeviceSettings.idleLockMinutes`, default 10 —
//      the setting that could weaken protection lives in this Mac's facts, never UserDefaults: the design's §3.2/§3.15).
//      Standard never locks — its quiet roads would open it again at once (rule 8; R13p-14: no theater ships).
//    - WHAT THE LOCK LETS GO OF on the session it closes, beyond the references the bootstrap drops: the account's sync
//      keys held in SESSION memory (Always ask — the leaf's contract: "gone at a relock").
//    - THE LOBBY IT LANDS IN — the open road's own (`ProtectionOpenRoad.lobbyFacts`): the typed roads over every key file
//      this Mac holds, the Touch ID button and its one auto-ask where this Mac's item stands. The quiet roads are NOT tried
//      at a lock (a lock is never theater — today's lock lands in its lobby the same way).
//

import Foundation
import VariorumCore

/// The open library's relock policy on the new road — nil where nothing locks (Standard).
nonisolated struct RoadRelockPolicy: Equatable, Sendable {
    /// Lock after time away, in minutes — this Mac's sealed setting; nil = never.
    let idleMinutes: Int?

    /// Castle locks (Touch ID, Always ask, or no choice yet); Standard never does.
    static func of(_ library: UnlockedLibrary) -> RoadRelockPolicy? {
        guard library.record?.mode == .castle else { return nil }
        return RoadRelockPolicy(idleMinutes: library.section.settings.idleLockMinutes)
    }
}

/// THE IDLE CLOCK (decision 18: "the clock = time since Variorum was last used") — pure, so the cadence has pins. The
/// Mac stamps `lastUsedAt` from its own event stream (never the system's idle clock, which any app's activity resets —
/// "switching to another app doesn't lock it; time away does"); the phone reads the same rule on RETURN from the time it
/// left the screen. (Moved here byte-for-byte from today's `StoreProtection.swift` at VX-329 U1 — the road's lock reads it.)
nonisolated enum IdleLockClock {
    static func isDue(idleSeconds: TimeInterval, minutes: Int?) -> Bool {
        guard let minutes, minutes > 0 else { return false }
        return idleSeconds >= Double(minutes) * 60
    }

    static func isDue(now: Date, lastUsedAt: Date?, minutes: Int?) -> Bool {
        guard let lastUsedAt else { return false }
        return isDue(idleSeconds: now.timeIntervalSince(lastUsedAt), minutes: minutes)
    }
}

nonisolated enum ProtectionRoadLock {
    /// The account's sync keys held in session memory for the library the lock closes — dropped (the leaf's contract:
    /// "gone at a relock"). A library bound to no account holds none.
    static func dropSessionMemory(_ session: ProtectionRoadSession) {
        guard let account = session.library.record?.account else { return }
        session.system.leaves.syncKeys.holdInSession(nil, accountID: account)
    }

    /// The lobby a lock lands in: the open road's own, read now over `ctx` (a freshly composed road — a READ).
    static func lobby(_ ctx: RoadContext) -> RoadLobbyFacts {
        ProtectionOpenRoad.lobbyFacts(ctx)
    }
}
