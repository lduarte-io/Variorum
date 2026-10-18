//
//  ProtectionRoad.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE ONE SWITCH (`notes/plans/vx-306-castle-open-road.md` §2 U1b, her kickoff ruling: "dormant
//  in release is what I meant"). The rebuilt protection core's OPEN ROAD — the lobby on `LobbyRoads`, the
//  creation card, the executor's unlock, settle and repairs — runs only where this reads `true`: a DEBUG build
//  on the MAC. Everywhere else (every Release build; the phone this unit) today's road runs byte-for-byte as it
//  did, because every new-road line sits behind this one value or in a file only the new road reaches.
//
//  The value is decided at COMPILE TIME (`isDebugBuild` is the `#if DEBUG` arm and nothing else), so no
//  defaults key, environment variable or launch argument can turn the new road on in a Release build — the
//  Release product's scope is the REAL store, which this phase never opens. The core compiles in both
//  configurations (rule 24); only the WIRING is gated here.
//
//  THE PHONE (PROVISIONAL P-VX306-U1b-1): the rule reads `debug && mac` — the phone's lobby face is U3's, so
//  this unit the phone keeps today's route in every configuration. U3 widens the rule to the phone's Debug
//  build when its face lands.
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

    /// Whether this build is the Mac app.
    static let isMac: Bool = {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }()

    /// **THE ONE SWITCH** — read at the head of `AppBootstrap.routeAndOpen` (through the bootstrap's `newRoad`).
    static let newRoadIsLive: Bool = live(debug: isDebugBuild, mac: isMac)

    /// The switch's rule, pure: the new road only in a Debug build on the Mac (P-VX306-U1b-1).
    static func live(debug: Bool, mac: Bool) -> Bool { debug && mac }
}
