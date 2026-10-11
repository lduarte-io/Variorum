//
//  WingState.swift
//  Variorum (shared: Mac + Mobile)
//
//  13i-d U5 — THE CURRENT WING (the sitting record §9: a wing is "basically a
//  whole separate library"; her sketch, 2026-08-25: "what library you're in
//  … with a drop down selector"). ONE app-wide current wing on the session —
//  every window shows the same library (PROVISIONAL P-13id-U5-3) — remembered
//  LOCALLY per device (a view preference, never a synced setting: which room
//  she is standing in is this Mac's fact, not the store's).
//
//  Home is VIRTUAL ('' — R-13ia-2). A remembered wing that has since died
//  (deleted here, or on another device) reads as Home at the next check.
//
//  The memory is ATTACHED by the bootstrap only: a session built anywhere
//  else (every pin, every preview) holds the wing in memory and never reads
//  or writes the test host's defaults — the test host IS the Debug app's
//  domain (the row-36/42 class).
//
//  The phone compiles this and never switches (its wing face is the mobile
//  catch-up's) — so it stands in Home, which is exactly what it showed.
//

import Foundation
import Observation

@MainActor
@Observable
final class WingState {
    /// The wing every surface reads ('' = Home).
    private(set) var currentID: String = ""
    /// 13n-c Stage B R1 B6 — how many wings this library has, Home included
    /// (1 until a wings model has read the store). ⌘L's gate (P-2: with ONE
    /// wing there is nothing to switch to), written only on a change by the
    /// wings model's adopt — a session-level fact, so the app-wide menu reads
    /// it whichever window is key.
    private(set) var wingCount = 1

    /// The device's memory, when the bootstrap attached one.
    @ObservationIgnored private var memory: UserDefaults?
    static let memoryKey = "wing.current"

    init(currentID: String = "") {
        self.currentID = currentID
    }

    /// What a SHARED read passes as its wing: the current wing on the Mac;
    /// nil (every wing) on the phone, whose surfaces stay unscoped until the
    /// mobile catch-up gives it a wing face — so each platform's doors take
    /// exactly what its surfaces show ("a door may not take what it does not
    /// show", the Trash's own G6 letter).
    var readScope: String? {
        #if os(macOS)
        currentID
        #else
        nil
        #endif
    }

    /// Switch the whole app to `wingID` (Home is ''). Remembered.
    func switchTo(_ wingID: String) {
        guard wingID != currentID else { return }
        currentID = wingID
        memory?.set(wingID, forKey: Self.memoryKey)
    }

    /// The bootstrap's call: adopt the device's remembered wing at once (so
    /// the first frame already stands in it), from now on writing every
    /// switch through. The bootstrap then `revalidate`s off the main actor's
    /// read — a remembered wing that died meanwhile returns to Home.
    func attachMemory(_ defaults: UserDefaults) {
        memory = defaults
        currentID = defaults.string(forKey: Self.memoryKey) ?? ""
    }

    /// The live wing count, from a fresh read of the store (Home + the live
    /// additional wings) — written only when it changed.
    func noteWingCount(_ count: Int) {
        let count = max(count, 1)
        if count != wingCount { wingCount = count }
    }

    /// Re-check after a wing act (a delete here or a sync round): a wing that
    /// is no longer live returns the app to Home.
    func revalidate(isLive: (String) -> Bool) {
        if !isLive(currentID) { switchTo("") }
    }
}
