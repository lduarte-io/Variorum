//
//  SettingsLockCloseTests.swift
//  VariorumTests
//
//  VX-224 — her report: *"when you lock variorum and have the settings pane
//  open, a weird variorum settings stub window appears … even though you
//  can't read the text in it, it's not possible to make it bigger. i feel
//  like we can probably just close this window."*
//
//  THE MECHANISM: the `Settings {}` scene hosts `SettingsSceneContent`,
//  whose non-ready arm is the stub (`Text("Open the main window first.")`).
//  A lock flips `AppBootstrap.state` to `.locked`; the scene's content
//  re-renders into that arm and NOTHING closes the window, so the Settings
//  window stands on as the stub over a locked library.
//
//  The evidence of record (the architect's ruling, 2026-10-13): a REAL
//  `AppBootstrap` driven unlock → ready → lock, with the scene's real
//  content in a real window. The dev store's custody is never touched.
//  VX-329 U1 — THE RELEASE SWITCH: today's demanded-world road (a test
//  opener + a scripted Castle gate) went with today's road, so the world is
//  the protection road's, PLANTED (no keychain): a library created there,
//  crossed into Castle (Always ask) THROUGH the bootstrap, locked into the
//  road's lobby — `RoadLockRouteTests`' `LockWorld`.
//
//  The guard beside it: the reopen roads (the Protection pane's crossings,
//  Make this my library — the bootstrap's reopening seam) pass through
//  `.opening` WITH this window hosting their sheets, so a fix that closed on
//  "not ready" would close the window under its own ceremony. The window
//  must survive them — pinned over the crossing into Castle, its reopen's
//  opener held so the middle can be looked at.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
@testable import Variorum
import VariorumCore

@MainActor
@Suite("Settings — the window closes when the library locks (VX-224)", .serialized)
struct SettingsLockCloseTests {
    /// The reopen's opener, holdable: armed, the next open waits on the gate (the crossing's reopen caught in its
    /// `.opening` middle); never armed, it opens at once.
    final class OpenHold: @unchecked Sendable {
        private let lock = NSLock()
        private var armed = false
        let gate = DispatchSemaphore(value: 0)
        func arm() { lock.withLock { armed = true } }
        func waitIfArmed() {
            let wait = lock.withLock { () -> Bool in
                defer { armed = false }
                return armed
            }
            if wait { _ = gate.wait(timeout: .now() + 20) }
        }
    }

    /// A planted-road bootstrap whose opener the pin can hold — ready in Standard, its words kept. The caller holds `road`
    /// (`LockWorld.readyInStandard`'s rule).
    private func readyInStandard(
        _ road: PlantedRoad, hold: OpenHold
    ) async throws -> (bootstrap: AppBootstrap, words: [String]) {
        let (_, words) = try await road.created()
        let url = road.slot.places.slot
        let bootstrap = AppBootstrap(
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: .signedOut, open: { key in
                hold.waitIfArmed()
                return Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state else {
            throw LockWorld.LockWorldError.notReady("\(bootstrap.state)")
        }
        return (bootstrap, words)
    }

    /// The crossing into Castle (Always ask) through the bootstrap — the reopen road this window hosts.
    private func crossIntoCastle(_ bootstrap: AppBootstrap, words: [String]) async throws {
        let crossings = try #require(bootstrap.roadCrossings)
        await crossings.refresh()
        crossings.open(.useCastle)
        let confirm = try #require(crossings.confirm)
        confirm.gate = .alwaysAsk
        await confirm.submit(
            passphrase: LockWorld.passphrase, again: LockWorld.passphrase, words: words.joined(separator: " "))
    }

    /// The Settings scene's REAL content in a real window — the window the
    /// `Settings {}` scene gives it is titled and closable, never resizable.
    private func mountSettings(_ bootstrap: AppBootstrap) -> (NSWindow, NSView) {
        let window = NSWindow(
            contentRect: NSRect(x: 120, y: 120, width: 720, height: 520),
            styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: SettingsSceneContent(
            bootstrap: bootstrap, services: nil,
            appearance: nil, updates: nil, crashReports: nil, mcp: nil,
            libraryOpen: LibraryOpenPresenter(), handOff: LibraryHandOffPresenter()))
        hosting.frame = NSRect(x: 0, y: 0, width: 720, height: 520)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// Every text the hosting view draws (the stub's sentence is the tell).
    private func renderedTexts(_ view: NSView) -> [String] {
        var found: [String] = []
        if let label = view.accessibilityLabel(), !label.isEmpty { found.append(label) }
        if let value = view.accessibilityValue() as? String, !value.isEmpty { found.append(value) }
        for sub in view.subviews { found.append(contentsOf: renderedTexts(sub)) }
        return found
    }

    /// VX-240: the spinners the hosting view draws (a SwiftUI `ProgressView`
    /// is an `NSProgressIndicator` underneath — measured offscreen before the
    /// pin was written).
    private func spinners(in view: NSView) -> Int {
        (view is NSProgressIndicator ? 1 : 0) + view.subviews.map { spinners(in: $0) }.reduce(0, +)
    }

    // MARK: - Her report (RED ON OLD)

    /// Settings open over an unlocked library; Lock Library Now. The window
    /// must CLOSE — never stand on as the "Open the main window first." stub.
    @Test func lockingWithSettingsOpenClosesTheSettingsWindow() async throws {
        try await withRoadDependencies {
            // Every test here HOLDS its road for its whole life: the slot's folder is the road's (`TempSlot` removes it
            // at deinit) and the bootstrap keeps only the road's system and the slot's URL — an inline `PlantedRoad()`
            // is released at the call's end and takes the library's files with it (VX-329's Mac-suite fix leg).
            let road = PlantedRoad()
            defer { withExtendedLifetime(road) {} }
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            let (window, hosting) = mountSettings(bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            // Non-vacuity: the panes are up over the open library.
            #expect(window.isVisible, "Settings is on screen over the unlocked library")
            #expect(bootstrap.canLock, "Castle offers Lock Library Now")

            await bootstrap.lock()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("expected the road's lobby after Lock Library Now")
                return
            }
            await settle(window, hosting, until: { !window.isVisible })
            #expect(!window.isVisible,
                    """
                    locking closes the Settings window — it stood on over the locked \
                    library showing: \(renderedTexts(hosting).joined(separator: " · "))
                    """)
        }
    }

    // MARK: - The guard (green on old and new)

    /// The reopen roads run FROM this window (the Protection pane's crossings; Make this my library) and pass through
    /// `.opening` on their way back to `.ready`. The window hosts their sheets, so it must survive the road — a close
    /// keyed on "not ready" would shut it under its own ceremony.
    @Test func aReopenRoadThroughOpeningKeepsTheSettingsWindow() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            defer { withExtendedLifetime(road) {} }
            let (bootstrap, words) = try await readyInStandard(road, hold: OpenHold())
            let (window, hosting) = mountSettings(bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            #expect(window.isVisible)

            // The crossing into Castle: ready → opening → ready, the reopening seam's road.
            try await crossIntoCastle(bootstrap, words: words)
            await settle(window, hosting, until: { false }, maxTurns: 10)
            guard case .ready = bootstrap.state, bootstrap.roadSession?.library.record?.mode == .castle else {
                Issue.record("expected the crossing's reopen to land .ready in Castle: \(bootstrap.state)")
                return
            }
            #expect(window.isVisible,
                    "the window survives the reopen road's .opening (the crossing's own sheet lives on it)")
        }
    }

    /// The rule's table: which states mean the library CLOSED under Settings.
    /// `.opening` never does — it is the reopen roads' in-flight middle.
    @Test func theLibraryClosedRuleNamesTheSettledClosedStatesAndNeverOpening() async throws {
        try await withRoadDependencies {
            #expect(!SettingsSceneContent.libraryClosed(.opening))
            #expect(SettingsSceneContent.libraryClosed(.failed(
                AppDatabase.StoreOpenError(storePath: "", reason: "x"))))
            let road = PlantedRoad()
            defer { withExtendedLifetime(road) {} }
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            #expect(!SettingsSceneContent.libraryClosed(bootstrap.state), "ready is open")
            await bootstrap.lock()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("expected the road's lobby after the lock")
                return
            }
            #expect(SettingsSceneContent.libraryClosed(bootstrap.state))
            try await LockWorld.unlock(bootstrap)
            #expect(!SettingsSceneContent.libraryClosed(bootstrap.state), "ready is open again")
        }
    }

    // MARK: - VX-240: the mid-ceremony face (RED ON OLD)

    /// The reopen roads keep this window open through `.opening` — and the
    /// window used to show the stub's instruction, "Open the main window
    /// first.", a wrong one mid-ceremony. Her words now (QUESTIONS #217):
    /// "Opening your library…" with a spinner. Every settled closed state
    /// keeps the stub.
    @Test func theOpeningFaceSaysHerWordsAndEverySettledClosedStateKeepsTheStub() async throws {
        try await withRoadDependencies {
            #expect(SettingsSceneContent.nonReadyFace(.opening) == .opening)
            #expect(SettingsSceneContent.Copy.opening == "Opening your library\u{2026}")
            #expect(SettingsSceneContent.nonReadyFace(.failed(
                AppDatabase.StoreOpenError(storePath: "", reason: "x"))) == .stub)
            let road = PlantedRoad()
            defer { withExtendedLifetime(road) {} }
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            await bootstrap.lock()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("expected the road's lobby after the lock")
                return
            }
            #expect(SettingsSceneContent.nonReadyFace(bootstrap.state) == .stub)
        }
    }

    /// The real road, caught in its middle: Settings open over the unlocked
    /// library, the crossing into Castle with its reopen's opener held on a
    /// gate, so the window sits in `.opening` long enough to look at — it
    /// shows the spinner.
    @Test func aReopenRoadShowsTheOpeningSpinnerMidCeremony() async throws {
        try await withRoadDependencies {
            let hold = OpenHold()
            let road = PlantedRoad()
            defer { withExtendedLifetime(road) {} }
            let (bootstrap, words) = try await readyInStandard(road, hold: hold)
            let (window, hosting) = mountSettings(bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)

            hold.arm()
            let gate = hold.gate
            let road = Task { @MainActor in
                try await crossIntoCastle(bootstrap, words: words)
            }
            @MainActor func opening() -> Bool {
                if case .opening = bootstrap.state { return true }
                return false
            }
            await settle(window, hosting, until: { opening() && spinners(in: hosting) > 0 })
            let caughtOpening = opening()
            let shown = spinners(in: hosting)
            let texts = renderedTexts(hosting)
            gate.signal()
            try await road.value

            #expect(caughtOpening, "the road was caught in its .opening middle")
            #expect(shown > 0,
                    "mid-ceremony the window shows the opening spinner, never the stub — it showed: \(texts.joined(separator: " · "))")
            await settle(window, hosting, until: { false }, maxTurns: 10)
            guard case .ready = bootstrap.state else {
                Issue.record("expected the reopen to land .ready")
                return
            }
            #expect(window.isVisible, "the window survives the road")
        }
    }
}
