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

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 12) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
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
}
