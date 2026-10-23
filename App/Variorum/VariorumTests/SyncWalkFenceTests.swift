//
//  SyncWalkFenceTests.swift
//  VariorumTests
//
//  VX-483 — THE A4 FENCE'S WALK LIFT (DEBUG walk machinery; her call at the 0.10 window: the VX-487 fix must be provable
//  LIVE, the rehearsal's round landing against the throwaway, in the app, before her Mac gets the rebuilt app). A dev-store
//  session never configures sync (`SyncSession.allowsSync`, derived in `AppServices` from the store variant — the one
//  production mirror pairs with the real store only). The lift: a DEBUG launch whose walk switch resolved to a project
//  that is NOT the production mirror (`ProjectConfig`'s own walk project — the one `projectOverrideForThisLaunch` read,
//  never a second environment parse) lets the DEV store's sessions configure sync against that project; a walk project
//  carrying the production mirror's ref is REFUSED, fail-loud (the fence stands; one log line says why, host only).
//  Release: the derivation byte-unchanged — the fence absolute.
//
//  Testability: the launch's decision is read once per process from its environment, so the pins inject the walk project
//  into the pure decision and the pure derivation; the production composition is pinned in THIS process's world (no walk
//  switch) and by source (the DEBUG/Release arms).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-483 — the A4 fence's walk lift (DEBUG walk machinery)")
struct SyncWalkFenceTests {
    /// `App/Variorum/` (this file lives in `App/Variorum/VariorumTests/`; resolved through symlinks so the headless
    /// harness reads the worktree's files).
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent()
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
    }

    private func services(_ variant: AppDatabase.StoreVariant) throws -> AppServices {
        let db = try AppDatabase.inMemory()
        return withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: {
            AppServices(
                session: AppSession(database: db), storeVariant: variant,
                backupEnabled: false,
                auth: AuthSession(
                    configuration: AuthConfiguration(
                        projectURL: URL(string: "https://vx483-pin.invalid")!, apiKey: "pin-publishable"),
                    store: .inMemory(),
                    http: { _ in throw URLError(.notConnectedToInternet) }),
                makeSyncTransport: { _ in preconditionFailure("this pin composes no sync chain") },
                makeSyncKeyProvider: { preconditionFailure("this pin composes no sync chain") },
                legacyCleanup: {})
        }
    }

    /// ARM 1 — THE FENCE HOLDS WITH NO WALK SWITCH, through the production composition (this test process launches with
    /// no walk switch): a dev-store session never configures sync; the real store's always may. A guard by design (green
    /// on both sides — the lift must never move it).
    @Test func withNoWalkSwitchTheDevStoreNeverSyncs() throws {
        try #require(ProcessInfo.processInfo.environment[ProtectionWalkSwitch.projectURLKey] == nil,
                     "this pin's world is a launch with no walk switch")
        #expect(try services(.dev).sync.allowsSync == false, "the A4 fence: a dev-store session never syncs")
        #expect(try services(.real).sync.allowsSync == true)
    }

    /// THE DERIVATION SITE, by source (red on old: one undivided line). `AppServices.init`'s DEBUG arm derives the fence
    /// from the launch's ONE decision (`ProjectConfig.walkSyncFenceLift`); its Release arm is the line as it always was —
    /// the store variant alone, no walk machinery reachable.
    @Test func theDerivationReadsTheLaunchsLiftOnlyInDebug() throws {
        let services = try Self.source("Shared/AppServices.swift")
        let assignment = try #require(services.range(of: "sync = SyncSession("))
        let debug = try #require(services.range(of: "#if DEBUG", options: .backwards, range: services.startIndex..<assignment.lowerBound))
        let release = try #require(services.range(of: "#else", range: debug.upperBound..<services.endIndex))
        let end = try #require(services.range(of: "#endif", range: release.upperBound..<services.endIndex))
        let debugArm = services[debug.upperBound..<release.lowerBound]
        let releaseArm = services[release.upperBound..<end.lowerBound]
        #expect(debugArm.contains("ProjectConfig.walkSyncFenceLift"), "the launch's one decision — never a second parse")
        #expect(releaseArm.contains("sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)"),
                "Release: the fence absolute, the line byte-unchanged")
        #expect(!releaseArm.contains("walk") && !releaseArm.contains("ProtectionWalkSwitch"))
        #expect(!services.contains("ProcessInfo"), "AppServices reads no environment of its own")
    }

    /// A SECOND-ORDER FENCE KEPT (red on old: the guard read `sync.allowsSync`): the retired-credential sweep reaches the
    /// machine's LOGIN keychain — the installed build's items — so it runs for the REAL store only, by the store variant
    /// itself; a lifted dev-store session must never reach it (the bridge retirement's round-2 N1 class).
    @Test func theRetiredCredentialSweepGuardsOnTheRealStoreNeverTheLift() throws {
        let services = try Self.source("Shared/AppServices.swift")
        let sweep = try #require(services.range(of: "private func runRetiredCredentialSweep() {"))
        let body = services[sweep.upperBound...].prefix(240)
        #expect(body.contains("guard storeVariant == .real else { return }"))
        #expect(!body.contains("sync.allowsSync"), "the lift moves allowsSync; the sweep's fence must not move with it")
    }
}
