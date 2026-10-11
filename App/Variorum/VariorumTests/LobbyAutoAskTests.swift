//
//  LobbyAutoAskTests.swift
//  VariorumTests
//
//  VX-140 (the VX-143 run) — her report: Touch ID asks relentlessly, and her
//  live example was the system sheet *"Variorum is trying to Unlock your
//  Variorum library"* standing over her TERMINAL while Variorum was not
//  frontmost: *"see this is an example. it just keeps appearing."*
//
//  THE MECHANISM (traced in the run record; the tripwire was NOT hit — this
//  is prompt triggering, not key custody): every lock occasion mints a fresh
//  lobby, and the relock monitors fire in the BACKGROUND (sleep, screen lock,
//  and the idle clock, which counts only Variorum's own events — time in her
//  terminal is time away). Each relock mounted `StoreLockView`, whose `.task`
//  asked at once whether the app was frontmost or not; answering in the
//  background unlocked and re-armed the idle clock without her touching the
//  app, so the next idle period asked again. The once-only guard was a
//  per-VIEW `@State`, so a re-mount or a second main window asked again too.
//
//  The prompt itself cannot be driven here (`StoreKeyGuard`'s rule: tests
//  never evaluate biometrics) — so these pins count calls into the lobby's
//  GATED ROAD, which is exactly the act that raises the system sheet in
//  production (`StoreKeyGuardKeychain.unlockGated`).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The lock lobby asks once, and only where she is (VX-140)", .serialized)
struct LobbyAutoAskTests {
    /// A biometric lobby whose gated road COUNTS its asks and answers like a
    /// cancelled sheet (nil — "failed / cancelled", `StoreKeyGuard.unlockGated`).
    private func countingLobby(_ asks: LockIsolated<Int>) -> StoreLobby {
        StoreLobby(
            demand: .biometric, biometryOffered: true,
            passphraseOffered: true, recoveryOffered: false,
            gatedRoad: {
                asks.withValue { $0 += 1 }
                return nil
            },
            envelopeRoad: { _ in .failure(.init(message: "not it")) },
            complete: { _ in })
    }

    private func host<V: View>(_ view: V) -> (NSWindow, NSHostingView<V>) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 520, height: 480),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: 520, height: 480)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 12) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    /// **RED ON OLD — her screenshot, as a pin.** A lobby that mounts while
    /// Variorum is NOT the active app (a background relock — she is in her
    /// terminal) must not raise the system sheet. The XCTest host is never
    /// the active app (measured; `WindowRegistry`'s header records it), which
    /// is exactly the background case.
    @Test func aLobbyMountedInTheBackgroundDoesNotAsk() async throws {
        try #require(!NSApp.isActive,
                     "the test host must be inactive for this to be the background case")
        let asks = LockIsolated(0)
        let lobby = countingLobby(asks)
        let (window, hosting) = host(StoreLockView(lobby: lobby))
        defer {
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting)
        #expect(asks.value == 0,
                "the lobby asked for Touch ID while Variorum was not frontmost (asks: \(asks.value))")
    }

    /// **The lobby's rule, whole** (red by behavioural revert — see the run
    /// record): a background lobby holds its ask; her return asks ONCE; a
    /// cancel spends it, so the next activation asks nothing; her BUTTON is
    /// the deliberate road and always asks.
    @Test func theAutomaticAskIsOncePerOccasionAndOnlyInFrontOfHer() async {
        let asks = LockIsolated(0)
        let lobby = countingLobby(asks)
        await lobby.autoAskIfDue(appIsActive: false)
        #expect(asks.value == 0, "a lobby in the background never asks")
        #expect(!lobby.autoAskSpent, "…and keeps its one automatic ask for her return")
        await lobby.autoAskIfDue(appIsActive: true)
        #expect(asks.value == 1, "her return asks — once")
        await lobby.autoAskIfDue(appIsActive: true)
        #expect(asks.value == 1,
                "a cancelled sheet is never followed by another unasked one (asks: \(asks.value))")
        await lobby.unlockWithBiometrics()
        #expect(asks.value == 2, "her button is the deliberate road — it always asks")
    }

    /// **A deliberate first ask spends the automatic one too**: she pressed
    /// the button before any automatic ask fired — her return must not
    /// stack a second sheet on top of the one she already answered.
    @Test func herButtonSpendsTheAutomaticAsk() async {
        let asks = LockIsolated(0)
        let lobby = countingLobby(asks)
        await lobby.unlockWithBiometrics()
        await lobby.autoAskIfDue(appIsActive: true)
        #expect(asks.value == 1, "one ask, hers (asks: \(asks.value))")
    }

    /// **Mounted: the background lobby asks when she comes back, once.** The
    /// face listens for the app's activation; a second activation after the
    /// cancel asks nothing.
    @Test func aBackgroundLobbyAsksOnHerReturnOnce() async {
        let asks = LockIsolated(0)
        let lobby = countingLobby(asks)
        let (window, hosting) = host(StoreLockView(lobby: lobby, appIsActive: { false }))
        defer {
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting)
        #expect(asks.value == 0, "mounted in the background: no sheet")
        NotificationCenter.default.post(
            name: NSApplication.didBecomeActiveNotification, object: NSApp)
        await settle(window, hosting)
        #expect(asks.value == 1, "her return asked once (asks: \(asks.value))")
        NotificationCenter.default.post(
            name: NSApplication.didBecomeActiveNotification, object: NSApp)
        await settle(window, hosting)
        #expect(asks.value == 1,
                "coming back again after the cancel asks nothing (asks: \(asks.value))")
    }

    /// **Two faces, one occasion.** Every main window renders the one lobby;
    /// a second face (another window, or a remount of the first) must not
    /// raise a second sheet — the old `@State` guard was per FACE.
    @Test func twoFacesOverOneLobbyAskOnce() async {
        let asks = LockIsolated(0)
        let lobby = countingLobby(asks)
        let (first, firstHost) = host(StoreLockView(lobby: lobby, appIsActive: { true }))
        defer {
            first.orderOut(nil)
            first.close()
        }
        await settle(first, firstHost)
        let (second, secondHost) = host(StoreLockView(lobby: lobby, appIsActive: { true }))
        defer {
            second.orderOut(nil)
            second.close()
        }
        await settle(second, secondHost)
        #expect(asks.value == 1, "one lock occasion, one sheet (asks: \(asks.value))")
    }
}
