//
//  VX206ProtectionLandingTests.swift
//  VariorumTests
//
//  VX-206 — entering Castle from Settings ▸ Protection ENDS on Protection,
//  its sheet up (RUN VX-201, unit U4; the brief and the record:
//  notes/plans/fixes/vx-201-castle-prelaunch-fixes.md §F, the run's VX-206
//  MACHINERY RULING, and "U4 RECORD (VX-204 + VX-206)").
//
//  THE DEFECT (her nit, 2026-10-12): Use Castle runs from Settings ▸
//  Protection, and the ceremony re-keys the library. `AppBootstrap.rekeyLibrary`
//  flips the bootstrap to `.opening`, so the Settings scene's content — which
//  renders `AppSettingsView` only while `.ready` — is torn down, and the reopen
//  builds a FRESH one whose `@State pane` starts at General. The ceremony
//  itself survives (it is held on the controller, `activeSwitch`), but its
//  host is the Protection pane (`ceremonyHost == .pane`, decided when it
//  opened), and no Protection pane is mounted any more: the During screen and
//  then the Done sat invisible until she clicked Protection by hand.
//
//  THE FIX: the Protection twin of the MCP door's open-at-pane request
//  (`MCPDoor.settingsRequest` → `AppSettingsView.adoptMCPRequest`): a counter
//  on the controller (which outlives the re-key) that the reopen and the
//  road's return bump for a pane-hosted ceremony only, and ONE adopter in
//  `AppSettingsView` (on appear, on change) that lands Protection — whose pane
//  then presents the ceremony's sheet, as it always has.
//
//  THE PINS (each red on the pre-fix code by the behavioral revert the record
//  names; the bound says so):
//   (a) a ceremony opened from Protection, run through the PRODUCTION re-key
//       reopen, ends with the request pending; a fresh Settings window lands
//       Protection (the pane mounts) with the ceremony's Done the sheet it
//       presents;
//   (b) BOUND — a ceremony the main window hosts asks Settings for nothing:
//       General's default stands;
//   (c) the request outlives the teardown: made at the reopen while no
//       Settings view exists, on the SAME controller across the re-key, and a
//       window already up when a request arrives lands Protection too.
//
//  Scripted Keychain backings throughout — no Keychain, no prompts. The
//  hosted legs build the real `AppSettingsView` in a real window and read
//  the Protection pane's own mount count (`ProtectionPane.onAppear` →
//  `protectionPaneAppeared()`), so the adopter is exercised, not re-derived.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-206 — a ceremony opened from Settings ▸ Protection ends on Protection", .serialized)
struct VX206ProtectionLandingTests {
    private let passphrase = "orchard-lantern-206"

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A real keyed store at `storeURL` with one note, its pool closed.
    private func seedStore(at storeURL: URL, key: StoreKey) async throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let store = try AppDatabase.onDisk(url: storeURL, key: key)
        try await store.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["vx206-note", "written before Castle", "2026-10-13T00:00:00Z", "2026-10-13T00:00:00Z"])
        }
        store.asRebindable().binding.lock()
    }

    /// The production open road under whichever key opens the file now (the
    /// VX-202 pins' opener — the unlocked key reaches production's opener as
    /// custody).
    private func opener(
        storeURL: URL, candidate: LockIsolated<StoreKey>, fallback: StoreKey
    ) -> @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError> {
        {
            let key = StoreEncryptionMigration.opens(storeURL, key: candidate.value) ? candidate.value : fallback
            return Result {
                try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
            }.mapError { error in
                error as? AppDatabase.StoreOpenError
                    ?? AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: error))
            }
        }
    }

    // MARK: - The world: a local-only Standard library, the ceremony wired as the app wires it

    @MainActor
    final class World {
        let dir: URL
        let bootstrap: AppBootstrap
        var runner: PostureSwitchRunner!
        /// What the re-key leaf saw around the PRODUCTION reopen.
        var controllerBeforeReopen: ProtectionController?
        var controllerAfterReopen: ProtectionController?
        var requestBeforeReopen: Int?
        var requestAtReopen: Int?
        var adoptedAtReopen: Int?
        var panesMountedAtReopen: Int?
        /// Set by a pin that stands a Protection pane on screen when the
        /// ceremony opens: the `.opening` teardown takes it down (the leaf
        /// says so on the controller, as the pane's own `onDisappear` would).
        var paneTornDownAtReopen = false
        var protection: ProtectionController { bootstrap.protection }

        init(dir: URL, bootstrap: AppBootstrap) {
            self.dir = dir
            self.bootstrap = bootstrap
        }

        func tearDown() {
            try? FileManager.default.removeItem(at: dir)
        }

        var session: AppSession? {
            if case .ready(let session) = bootstrap.state { return session }
            return nil
        }
    }

    /// Her library before Use Castle: Standard, local-only — the key file
    /// carries a passphrase copy and the Apple copy, the raw key sits in the
    /// silent item, A is readable, Touch ID exists. The runner rides the
    /// PRODUCTION re-key road (`bootstrap.rekeyLibrary` → `beginOpening` →
    /// `.ready`) and the PRODUCTION custody move, and it is the controller's
    /// `switchRunner`, so the ceremony opens through `openSwitch` exactly as
    /// the pane's Use Castle… door opens it.
    private func makeWorld() async throws -> World {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx206-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let oldKey = StoreKey.mint()
        try await seedStore(at: storeURL, key: oldKey)
        let apple = AppleKey.mint()
        let storeID = "vx206-\(UUID().uuidString.prefix(8).lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: passphrase, kdf: fastKDF())
        try envelope.setAppleWrappedCopy(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let backing = InMemoryStoreKeyGuardBacking(auto: oldKey, biometryAvailable: true, biometricSucceeds: true)
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        let pending = ScriptedSwitchPendingBox()
        let dials = ScriptedDialsBox(ProtectionDials())
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: backing) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in },
            syncCustodyPresent: { _, _ in false },
            switchPending: { _, id in pending.isPending(id) },
            setSwitchPending: { value, _, id in pending.set(value, for: id) })
        let currentKey = LockIsolated(oldKey)
        let syncLeaves = RecordingSyncLeaves()
        let bootstrap = AppBootstrap(
            testOpener: opener(storeURL: storeURL, candidate: currentKey, fallback: oldKey),
            gate: gate, testPresence: .encryptedOrUnknown, testStoreURL: storeURL,
            syncCustodyLeaves: { _ in syncLeaves.leaves }, syncCustodySession: SyncCustodySession())
        await bootstrap.awaitOpen()
        guard case .ready(let session) = bootstrap.state else {
            Issue.record("the Standard library opens silently: \(bootstrap.state)")
            throw CancellationError()
        }
        let world = World(dir: dir, bootstrap: bootstrap)
        let protection = bootstrap.protection
        let keyStore = DeviceKeyStore.inMemory()
        let suiteName = "io.lduarte.variorum.tests.vx206.\(UUID().uuidString)"
        world.runner = PostureSwitchRunner(leaves: PostureSwitchRunner.Leaves(
            scope: AppDatabase.StoreVariant.dev.rawValue,
            storeURL: storeURL,
            database: session.database,
            gate: gate,
            keyStore: keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore),
            vault: nil,
            transport: nil,
            signedIn: { false },
            appleKeys: AppleKeyLeaves.inMemory(backing: appleBacking),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { protection.biometryAvailable },
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { [weak world] old, new, work in
                currentKey.setValue(new)
                world?.controllerBeforeReopen = bootstrap.protection
                world?.requestBeforeReopen = bootstrap.protection.settingsRequest
                // The `.opening` teardown takes the Protection pane down with
                // the rest of the `.ready` tree (its `onDisappear`).
                if world?.paneTornDownAtReopen == true { bootstrap.protection.protectionPaneDisappeared() }
                try await bootstrap.rekeyLibrary(from: old, to: new, work: work)
                world?.controllerAfterReopen = bootstrap.protection
                world?.requestAtReopen = bootstrap.protection.settingsRequest
                world?.adoptedAtReopen = bootstrap.protection.settingsRequestAdopted
                world?.panesMountedAtReopen = bootstrap.protection.mountedProtectionPanes
            },
            pauseSync: {},
            resumeSync: {},
            takeSnapshot: { .notKept },
            preSwitchSnapshots: { _ in [] },
            deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { await protection.reconcile() },
            now: { Date() },
            log: { _ in },
            endSwitch: { bootstrap.endSwitch() }))
        protection.switchRunner = world.runner
        return world
    }

    /// The ceremony's whole road on this library, through the model the
    /// controller opened: the door, Screen 1, the fresh twelve words, the
    /// floor, the act.
    private func runToDone(_ model: PostureSwitchModel) async throws {
        await model.start()
        guard model.phase == .explain else {
            Issue.record("Screen 1 first: \(model.phase)")
            throw CancellationError()
        }
        model.continueFromExplain()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("the twelve words are shown: \(model.phase)")
            throw CancellationError()
        }
        model.acknowledgeWordsWritten()
        model.confirmWords(words.joined(separator: " "))
        #expect(model.phase == .floor(needsPassphrase: true), "\(model.phase)")
        await model.enterCastle(passphrase: passphrase, acknowledged: true)
        guard case .done = model.phase else {
            Issue.record("the ceremony finishes: \(model.phase) \(model.lastError ?? "")")
            throw CancellationError()
        }
    }

    // MARK: - The Settings window, hosted for real

    /// The real `AppSettingsView` in a real window — what the Settings scene
    /// builds at a `.ready` (the protection brain handed down as the app
    /// hands it). `pump` lays it out until a condition holds.
    @MainActor
    final class HostedSettings {
        let window: NSWindow
        let hosting: NSHostingView<AppSettingsView>

        init(session: AppSession, protection: ProtectionController) {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            hosting = NSHostingView(rootView: AppSettingsView(session: session, protection: protection))
            hosting.frame = NSRect(x: 0, y: 0, width: 720, height: 520)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
        }

        @discardableResult
        func pump(tries: Int = 50, until condition: () -> Bool = { false }) async -> Bool {
            for _ in 0..<tries {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                if condition() { return true }
                try? await Task.sleep(for: .milliseconds(20))
            }
            return condition()
        }

        func close() {
            window.orderOut(nil)
            window.close()
        }
    }

    // MARK: - (a) the Settings-origin ceremony ends on Protection, its Done up

    /// **THE NAMED PIN.** The pane is on screen when she presses Use Castle…
    /// (`protectionPaneAppeared`), so the ceremony is the PANE's. The road
    /// runs through the production re-key, whose teardown takes the pane
    /// down. At the Done the request is pending, nothing has adopted it, and
    /// the first Settings window the ready builds lands PROTECTION — the pane
    /// mounts, and the sheet it presents is this ceremony at its Done.
    /// RED ON OLD (the record's revert R-none — the controller asks for
    /// nothing): no request, and the fresh window stays on General (no pane
    /// mounted) — exactly her report. Revert R-done (the road's return asks
    /// nothing): the request does not move at the Done. Revert R-adopter (the
    /// window adopts nothing): the pane never mounts.
    @Test func aCeremonyOpenedFromProtectionEndsWithItsDoneUpOnProtection() async throws {
        try await withDeps {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let protection = world.protection
            #expect(protection.posture == .standard, "her library starts Standard")

            // Settings ▸ Protection is up: the pane mounted, and the window
            // has adopted every earlier request (its "seen" mark).
            protection.protectionPaneAppeared()
            protection.settingsRequestAdopted = protection.settingsRequest
            let before = protection.settingsRequest
            protection.openSwitch(.enter, vaultTie: nil)
            let model = try #require(protection.activeSwitch)
            #expect(protection.ceremony(for: .pane) === model, "opened from the pane: the pane hosts it")
            world.paneTornDownAtReopen = true

            try await runToDone(model)

            let atReopen = try #require(world.requestAtReopen)
            #expect(protection.settingsRequest > atReopen,
                    "the road's return asks Settings for Protection (the Done is up where she acted)")
            #expect(protection.settingsRequest > before)
            #expect(AppSettingsView.adopts(
                request: protection.settingsRequest, adopted: protection.settingsRequestAdopted),
                    "nothing has adopted it yet — the window that showed General is gone")
            #expect(protection.mountedProtectionPanes == 0, "the teardown took the pane down")
            #expect(protection.ceremony(for: .pane) === model && protection.ceremony(for: .root) == nil,
                    "the Done is still the pane's to present — and only the pane's")

            // The Settings window the ready builds: Protection, its pane up,
            // the request adopted once.
            let session = try #require(world.session)
            let settings = HostedSettings(session: session, protection: protection)
            let landed = await settings.pump { protection.mountedProtectionPanes == 1 }
            #expect(landed, "a fresh Settings window lands on Protection — never General")
            #expect(protection.settingsRequestAdopted == protection.settingsRequest, "adopted exactly once")
            if case .done = model.phase {} else {
                Issue.record("the sheet the pane presents is the Done: \(model.phase)")
            }
            #expect(protection.ceremony(for: .pane) === model, "the pane on screen presents the Done")

            protection.closeSwitch()
            await settings.pump(tries: 5)
            settings.close()
        }
    }

    // MARK: - (b) BOUND — a ceremony the main window hosts asks nothing

    /// The same road with NO Protection pane on screen when the ceremony
    /// opens (the Account sheet's door, the notice bar's resume): the main
    /// window hosts it, and Settings is asked for nothing — General's default
    /// and wherever she left Settings stand. BOUND on the pre-fix code
    /// (nothing ever asked); red under the record's revert R-host (the host
    /// check dropped: the root's ceremony would yank Settings to Protection).
    @Test func aCeremonyTheMainWindowHostsLeavesSettingsWhereItWas() async throws {
        try await withDeps {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let protection = world.protection
            #expect(protection.mountedProtectionPanes == 0)
            protection.openSwitch(.enter, vaultTie: nil)
            let model = try #require(protection.activeSwitch)
            #expect(protection.ceremony(for: .root) === model, "no pane on screen: the root hosts it")

            try await runToDone(model)

            #expect(world.requestAtReopen == 0, "the reopen asked for nothing")
            #expect(protection.settingsRequest == 0, "the road's return asked for nothing")
            #expect(!AppSettingsView.adopts(
                request: protection.settingsRequest, adopted: protection.settingsRequestAdopted))

            let session = try #require(world.session)
            let settings = HostedSettings(session: session, protection: protection)
            await settings.pump(tries: 25)
            #expect(protection.mountedProtectionPanes == 0, "Settings opens where it always does: General")

            protection.closeSwitch()
            settings.close()
        }
    }

    // MARK: - (c) the request outlives the teardown, and reaches a window already up

    /// The reopen ASKS (the During screen comes back where it was) at a
    /// moment no Settings view exists — the pane torn down, nothing to adopt —
    /// on the SAME controller the ceremony opened on (the bootstrap's own,
    /// which the re-key never replaces); the ask waits there for the next
    /// window. And a window ALREADY up when a request arrives (the road's
    /// return over a window that came back meanwhile) lands Protection by its
    /// change road. RED ON OLD (revert R-none): nothing is asked at the reopen.
    /// Revert R-reopen (the bootstrap's ask removed): the reopen asks nothing.
    /// Revert R-adopter: the window already up never moves.
    @Test func theRequestOutlivesTheReKeysTeardownAndReachesAWindowAlreadyUp() async throws {
        try await withDeps {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let protection = world.protection
            protection.protectionPaneAppeared()
            protection.settingsRequestAdopted = protection.settingsRequest
            protection.openSwitch(.enter, vaultTie: nil)
            let model = try #require(protection.activeSwitch)
            world.paneTornDownAtReopen = true

            try await runToDone(model)

            // At the reopen: asked, with no pane mounted and nothing adopted.
            let beforeReopen = try #require(world.requestBeforeReopen)
            let atReopen = try #require(world.requestAtReopen)
            #expect(atReopen > beforeReopen, "the re-key's reopen asks Settings for Protection")
            #expect(world.panesMountedAtReopen == 0, "asked while no Protection pane is on screen")
            #expect(world.adoptedAtReopen.map { $0 < atReopen } == true, "and nothing adopted it there")
            // The holder is the bootstrap's controller, unchanged across the re-key.
            #expect(world.controllerBeforeReopen === protection && world.controllerAfterReopen === protection,
                    "the request lives on the controller the re-key never replaces")

            // A window already up — everything so far seen (the window that
            // came back at the reopen adopted it) — sits on General…
            protection.settingsRequestAdopted = protection.settingsRequest
            let session = try #require(world.session)
            let settings = HostedSettings(session: session, protection: protection)
            await settings.pump(tries: 25)
            #expect(protection.mountedProtectionPanes == 0, "nothing pending: General")
            // …until the ceremony asks (the one door both asks use).
            protection.requestProtectionPaneForCeremony()
            let landed = await settings.pump { protection.mountedProtectionPanes == 1 }
            #expect(landed, "a window already up lands Protection when the request arrives")
            #expect(protection.settingsRequestAdopted == protection.settingsRequest)

            protection.closeSwitch()
            await settings.pump(tries: 5)
            settings.close()
        }
    }
}
