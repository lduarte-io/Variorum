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
//  `AppBootstrap` on the Phase13pLobbyTests demanded-world road (a test
//  opener + a scripted Castle gate, Always ask) driven unlock → ready →
//  lock, with the scene's real content in a real window. The dev store's
//  custody is never touched.
//
//  The guard beside it: the reopen roads (`adoptLibrary` — Settings' own
//  Restore from Backup door; `rekeyLibrary` — the Protection pane's posture
//  switches) pass through `.opening` WITH this window hosting their sheets,
//  so a fix that closed on "not ready" would close the window under its own
//  ceremony. The window must survive them.
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
    private struct World {
        let bootstrap: AppBootstrap
        let key: StoreKey
        let directory: URL
    }

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    /// The Phase13pLobbyTests demanded world: a passphrase-wrapped key file
    /// (no Apple copy) derives Castle; Always ask is the dial.
    private func demandedWorld() throws -> World {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx224-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let storeURL = dir.appendingPathComponent("store.sqlite")
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(
            key: key, passphrase: "sesame",
            kdf: PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32))
        let gate = StoreLaunchGate.scripted(
            dials: ProtectionDials(alwaysAsk: true),
            backing: InMemoryStoreKeyGuardBacking(), envelope: envelope)
        let bootstrap = AppBootstrap(
            testOpener: {
                Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                    .mapError { AppDatabase.StoreOpenError(
                        storePath: storeURL.path, reason: String(describing: $0)) }
            },
            gate: gate)
        return World(bootstrap: bootstrap, key: key, directory: dir)
    }

    /// Unlocks the world's lobby into `.ready`.
    private func unlock(_ world: World) async throws {
        await world.bootstrap.awaitOpen()
        guard case .locked(let lobby) = world.bootstrap.state else {
            Issue.record("expected the demanded world to start .locked")
            return
        }
        await lobby.unlock(passphrase: "sesame")
        await world.bootstrap.awaitOpen()
        guard case .ready = world.bootstrap.state else {
            Issue.record("expected .ready after unlock")
            return
        }
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
        try await withDeps {
            let world = try demandedWorld()
            defer { try? FileManager.default.removeItem(at: world.directory) }
            try await unlock(world)
            let (window, hosting) = mountSettings(world.bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            // Non-vacuity: the panes are up over the open library.
            #expect(window.isVisible, "Settings is on screen over the unlocked library")
            #expect(world.bootstrap.canLock, "a demanded posture offers Lock Library Now")

            await world.bootstrap.lock()
            guard case .locked = world.bootstrap.state else {
                Issue.record("expected .locked after Lock Library Now")
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

    /// The reopen roads run FROM this window (Restore from Backup's
    /// `adoptLibrary`; the posture switches' `rekeyLibrary`) and pass through
    /// `.opening` on their way back to `.ready`. The window hosts their
    /// sheets, so it must survive the road — a close keyed on "not ready"
    /// would shut it under its own ceremony.
    @Test func aReopenRoadThroughOpeningKeepsTheSettingsWindow() async throws {
        try await withDeps {
            let world = try demandedWorld()
            defer { try? FileManager.default.removeItem(at: world.directory) }
            try await unlock(world)
            let (window, hosting) = mountSettings(world.bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            #expect(window.isVisible)

            // An adoption whose work moves nothing, reopening under the same
            // key: ready → opening → ready, exactly the Restore door's road.
            try await world.bootstrap.adoptLibrary(reopeningWith: world.key, work: {})
            await settle(window, hosting, until: { false }, maxTurns: 10)
            guard case .ready = world.bootstrap.state else {
                Issue.record("expected the reopen to land .ready")
                return
            }
            #expect(window.isVisible,
                    "the window survives the reopen road's .opening (the Restore door's own sheet lives on it)")
        }
    }

    /// The rule's table: which states mean the library CLOSED under Settings.
    /// `.opening` never does — it is the reopen roads' in-flight middle.
    @Test func theLibraryClosedRuleNamesTheSettledClosedStatesAndNeverOpening() async throws {
        try await withDeps {
            #expect(!SettingsSceneContent.libraryClosed(.opening))
            #expect(SettingsSceneContent.libraryClosed(.failed(
                AppDatabase.StoreOpenError(storePath: "", reason: "x"), recovery: nil)))
            let world = try demandedWorld()
            defer { try? FileManager.default.removeItem(at: world.directory) }
            await world.bootstrap.awaitOpen()
            guard case .locked = world.bootstrap.state else {
                Issue.record("expected the demanded world to start .locked")
                return
            }
            #expect(SettingsSceneContent.libraryClosed(world.bootstrap.state))
            try await unlock(world)
            #expect(!SettingsSceneContent.libraryClosed(world.bootstrap.state), "ready is open")
        }
    }

    // MARK: - VX-240: the mid-ceremony face (RED ON OLD)

    /// The reopen roads keep this window open through `.opening` — and the
    /// window used to show the stub's instruction, "Open the main window
    /// first.", a wrong one mid-ceremony. Her words now (QUESTIONS #217):
    /// "Opening your library…" with a spinner. Every settled closed state
    /// keeps the stub.
    @Test func theOpeningFaceSaysHerWordsAndEverySettledClosedStateKeepsTheStub() async throws {
        try await withDeps {
            #expect(SettingsSceneContent.nonReadyFace(.opening) == .opening)
            #expect(SettingsSceneContent.Copy.opening == "Opening your library\u{2026}")
            #expect(SettingsSceneContent.nonReadyFace(.failed(
                AppDatabase.StoreOpenError(storePath: "", reason: "x"), recovery: nil)) == .stub)
            let world = try demandedWorld()
            defer { try? FileManager.default.removeItem(at: world.directory) }
            await world.bootstrap.awaitOpen()
            guard case .locked = world.bootstrap.state else {
                Issue.record("expected the demanded world to start .locked")
                return
            }
            #expect(SettingsSceneContent.nonReadyFace(world.bootstrap.state) == .stub)
        }
    }

    /// The real road, caught in its middle: Settings open over the unlocked
    /// library, an adoption whose work is held on a gate, so the window sits
    /// in `.opening` long enough to look at — it shows the spinner.
    @Test func aReopenRoadShowsTheOpeningSpinnerMidCeremony() async throws {
        try await withDeps {
            let world = try demandedWorld()
            defer { try? FileManager.default.removeItem(at: world.directory) }
            try await unlock(world)
            let (window, hosting) = mountSettings(world.bootstrap)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)

            let gate = DispatchSemaphore(value: 0)
            let key = world.key
            let bootstrap = world.bootstrap
            let road = Task { @MainActor in
                try await bootstrap.adoptLibrary(reopeningWith: key, work: {
                    _ = gate.wait(timeout: .now() + 20)
                })
            }
            func opening() -> Bool {
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
