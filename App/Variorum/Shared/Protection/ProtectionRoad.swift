//
//  ProtectionRoad.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE ONE SWITCH (`notes/plans/vx-306-castle-open-road.md` §2 U1b), FLIPPED at VX-329 U1
//  (`notes/plans/vx-329-release-switch.md` §6a — the release switch): the rebuilt protection core's OPEN ROAD — the
//  lobby on `LobbyRoads`, the executor's unlock, settle and repairs, every face over them — is the ONLY road, in
//  EVERY build: Debug and Release, the Mac and the phone, every store variant (the dev-store fence P-VX306-U1b-5
//  dissolved with the switch — no store opens any other way, because no other way exists any more). Today's deciding
//  and writing road was deleted in the same change (CastleRules rule 26: stores from before this design are neither
//  migrated nor handled).
//
//  The rule stays a pure function of the build's configuration so the switch's own pin keeps reading it: it answers
//  `true` for both arms. The core compiles in both configurations (rule 24).
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

    /// **THE ONE SWITCH** — on, in every build (VX-329).
    static let newRoadIsLive: Bool = live(debug: isDebugBuild)

    /// The switch's rule, pure: the new road in EVERY build — Debug and Release alike (VX-329 U1, superseding VX-306's
    /// Debug-only rule).
    static func live(debug: Bool) -> Bool { true }

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
