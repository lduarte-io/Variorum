//
//  MobileSettingsProtectionDoorTests.swift
//  VariorumMobileTests
//
//  VM-27 (her report, VM-47 batch 5 — her word: "file the double protections as a bug not a taste call"): the phone's
//  Settings sheet said "Protection…" TWICE, stacked, whenever the sync row stood in a DOORED paused state.
//
//  THE MECHANISM (traced, `MobileSettingsView` before the fix): ONE closure, `protectionDoor` (the shell's road, the
//  app's services, AND an account section on the open library — P-2), fed TWO renderers on the same sheet:
//    1. the sync row — `.environment(\.protectionPaneDoor, protectionDoor.map { … })` made `canOpenProtection` true, so
//       `SyncRowFace.face` minted its `Protection…` door for the keys refusal (`.keysLocked`, and `.notOnYet` over a
//       library that has not joined — VX-510 D-A3), drawn under the row's line;
//    2. the standing row directly below it — `if let protectionDoor { Button … SyncRowFace.openProtectionLabel }`.
//  Both gated on the same value, so whenever (1) rendered, (2) rendered too: the same word twice, one above the other.
//
//  WHICH DOOR STAYS — the standing row (the ticket's lean, and the lock mockup's build note: "One Protection row,
//  always: the sync row's door and the standing button must never both render"): on the phone it is on this same
//  sheet in EVERY state the sync row's door could render (the same gate), and in every other state too, so it is the
//  one that never leaves. The sync row in Settings is handed NO Protection door, so a doored paused state says its
//  sentence alone — the shared face's own P-2 arm (`canOpenProtection: false`), which the Mac's pins already hold
//  (`SyncLockedRowTests.withNoProtectionPaneTheLockedRowSaysTheSentenceAlone`). The Mac's sidebar row keeps its door
//  (a different window's composition — untouched).
//
//  THE PIN — mounted for real: the PHONE'S OWN bootstrap over a planted road (a fresh library, its account section
//  made), real `AppServices` over its session whose sync chain refuses for keys (a locked provider, a transport that is
//  never reached — a keys refusal makes no network contact), one round run so the row stands in the doored state; then
//  the sheet, both the locked face (the record fact unknown — nil) and the not-yet face (`librarySyncsWithAnAccount`
//  false). Exactly ONE element says "Protection…", and pressing it opens the screen.
//  RED ON OLD: two elements say it (the sync row's door and the standing row) — run in a detached snapshot with
//  `MobileSettingsView.swift` from the pre-fix tree (the run record §4, row 5.1).
//

import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-27 — Settings says Protection… once, in every doored sync state", .serialized)
struct MobileSettingsProtectionDoorTests {
    /// A transport no keys-refused round ever reaches (the engine asks the key provider first).
    private actor UnreachedTransport: SyncTransport {
        func fetchChallenges(_ count: Int) async throws -> [String] { [] }
        func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
        func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
            batch.map { _ in .rejected(current: nil) }
        }
        func pull(
            since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?
        ) async throws -> [SyncPulledRow] { [] }
        func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
    }

    private static let keysLocked = String(describing: SyncError.encryptionKeysUnavailable)

    /// `joined`: the open library's record fact as the phone's root injects it — nil (not known: the locked face) and
    /// false (not joined: the not-yet face). Both are the doored paused states her report names.
    @Test(arguments: [nil, false] as [Bool?])
    func aDooredSyncRowLeavesExactlyOneProtectionDoor(joined: Bool?) async throws {
        await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = MobileTypedUnlockSyncKeysTests.World()
            let bootstrap = AppBootstrap(testStoreURL: world.slot.places.slot, protectionRoad: world.harness())
            await bootstrap.awaitOpen()
            guard case .newLibraryWords(let card) = bootstrap.state else {
                Issue.record("a fresh slot creates a library — \(bootstrap.state)")
                return
            }
            card.iveWrittenThemDown()
            await bootstrap.awaitOpen()
            guard case .ready(let session) = bootstrap.state else {
                Issue.record("the library opens — \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadStanding?.account != nil, "precondition: the account section stands (the gate's third fact)")

            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://vm27.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            let services = AppServices(
                session: session, storeVariant: .real, backupEnabled: false, auth: auth,
                makeSyncKeyProvider: { UnenrolledKeyProvider() }, networkPath: nil, legacyCleanup: {})
            defer { services.stop() }
            await services.sync.configure(transport: UnreachedTransport(), keyProvider: UnenrolledKeyProvider())
            services.sync.triggerSync()
            for _ in 0..<400 where services.sync.status.lastError == nil {
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(services.sync.status.lastError == Self.keysLocked,
                    "precondition: the round refused for keys — the doored paused state")

            let opened = LockIsolated(0)
            let settings = MobileSettingsView(
                session: session, router: MobileShellRouter(), services: services,
                bootstrap: bootstrap, onOpenProtection: { opened.withValue { $0 += 1 } })
                .environment(\.librarySyncsWithAnAccount, joined)
            await withHostedSurface(settings) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                let line = joined == false ? SyncStatusRow.notOnYetLabel : SyncStatusRow.lockedLabel
                #expect(labels.contains(line), "the row stands in its doored paused state — labels were \(labels)")
                let doors = labels.filter { $0 == SyncRowFace.openProtectionLabel }
                #expect(doors.count == 1,
                        "ONE Protection… door on the sheet, never the sync row's beside the standing row — labels were \(labels)")
                #expect(surface.activate(SyncRowFace.openProtectionLabel), "the one door is a real control")
                #expect(opened.value == 1, "and it opens the Protection screen")
            }
        }
    }
}
