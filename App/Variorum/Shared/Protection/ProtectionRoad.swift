//
//  ProtectionRoad.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE ONE SWITCH (`notes/plans/vx-306-castle-open-road.md` §2 U1b, her kickoff ruling: "dormant
//  in release is what I meant"). The rebuilt protection core's OPEN ROAD — the lobby on `LobbyRoads`, the
//  creation card, the executor's unlock, settle and repairs — runs only where this reads `true`: a DEBUG build
//  (the Mac's, and since VX-306 U3 the phone's). Every Release build runs today's road byte-for-byte as it did,
//  because every new-road line sits behind this one value or in a file only the new road reaches.
//
//  The value is decided at COMPILE TIME (`isDebugBuild` is the `#if DEBUG` arm and nothing else), so no
//  defaults key, environment variable or launch argument can turn the new road on in a Release build — the
//  Release product's scope is the REAL store, which this phase never opens. The core compiles in both
//  configurations (rule 24); only the WIRING is gated here.
//
//  THE PHONE: U1b's rule read `debug && mac` (PROVISIONAL P-VX306-U1b-1 — the phone's lobby face was U3's). VX-306 U3
//  SUPERSEDES it, as the plan's U3 addendum rules: the phone's faces land (the lobby, the creation card, the interlude,
//  rule 27's), so the rule reads `debug` alone — the phone's Debug build opens its fenced dev store on the new road.
//
//  Tests: `AppBootstrap(testOpener:…)` defaults the road OFF (the existing route suites run today's road
//  unchanged); a new-road route test turns it on explicitly over a temp slot.
//

import Foundation

nonisolated enum ProtectionRoad {
    /// Whether this is a DEBUG build — the `#if DEBUG` arm, the switch's only configuration input.
    static let isDebugBuild: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Whether this build is the Mac app (read by the faces; no longer an input to the switch — VX-306 U3).
    static let isMac: Bool = {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }()

    /// **THE ONE SWITCH** — read at the head of `AppBootstrap.routeAndOpen` (through the bootstrap's `newRoad`).
    static let newRoadIsLive: Bool = live(debug: isDebugBuild)

    /// The switch's rule, pure: the new road only in a Debug build — the Mac's and the phone's (VX-306 U3, superseding
    /// P-VX306-U1b-1's `debug && mac`).
    static func live(debug: Bool) -> Bool { debug }

    /// Whether a store opens on the new road: the switch AND the dev-store fence (P-VX306-U1b-5 — a Debug build pointed
    /// at the real store's variant keeps today's road). ONE rule, read by the bootstrap's road and by the readme's Start
    /// Here passages (VX-306 ladder round 2, m2: they seed only where the road they describe is the store's road).
    static func opensOnTheNewRoad(devStore: Bool) -> Bool { newRoadIsLive && devStore }

    /// VX-307 U2b (VX-412 — `notes/CastleRules.md` rules 2 and 3 as amended at her sitting on VX-306's bundle): whether
    /// a library just created shows its words card BEFORE the first screen. On the Mac it never does — "the words are
    /// never shown before the first screen: the first open is the Bookcase and the quick entry with nothing in front of
    /// them"; the creation's words are dropped unseen (nothing stores the words — rule 2) and the card above the quick
    /// entry offers fresh ones when she asks. The PHONE keeps its creation card this phase (PROVISIONAL P-VX307-U2b-0:
    /// the phone's calm first open is a VM ticket — the mobile-parity line).
    static func wordsCardAtCreation(mac: Bool) -> Bool { !mac }

    /// The rule read for this build (the bootstrap's `.roadCreated` arm).
    static let showsWordsAtCreation: Bool = wordsCardAtCreation(mac: isMac)
}
