//
//  FirstRunDrillTests.swift
//  VariorumTests — **VX-509: THE STANDING FIRST-RUN DRILL** (VX-510 unit B1, D-B1). This suite IS the standing gate VX-509
//  asked for, and the release checklist cites it by name: EVERY first-run arm of the account section runs to its FIRST ROUND
//  with NO RELAUNCH, and each arm asserts what she would see — the act's sheet confirming its round (or saying what blocks
//  it, in the sync row's own words) and the sync row itself. A first-run arm that regresses to silence (VX-498 — a set-up
//  that lands with no round; VX-507 — a sheet that says "done" while nothing synced) fails HERE, headless, before any walk.
//
//  The world is unit A's `FirstRoundWorld`, extended (never forked): the bootstrap over the PLANTED road (no keychain; the
//  planted vault and sync keys), the app's real `AppServices`/`SyncSession` attached through `AppBootstrap.attach(services:)`
//  as `VariorumApp`'s `.task` composes them (and across a reopen: the teardown stops and releases them, the reopened ready arm
//  composes fresh ones), and an accepting fake server (no network). Also runs headless in the implementer's SwiftPM harness.
//
//  THE ARMS: the Standard set-up · the Standard join (same posture) · the Castle set-up under Always ask · the Castle set-up
//  under Touch ID (a planted press — a finger enrolled, no hardware) · the Castle join (same posture) · Move (same posture) ·
//  the re-keying join through the reopen (D-B0) — and the negative arms, each saying its blocker on the sheet AND the row:
//  offline · held (the restore hold) · not configured (the owner adoption refused — the run record's F-5) · the
//  account-binding gate (VX-314).
//
//  Words are P-VX510-1's (PROVISIONAL, standing at R-510-13).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-509 — THE STANDING FIRST-RUN DRILL: every first-run arm to its first round, no relaunch", .serialized)
@MainActor
struct FirstRunDrillTests {
    typealias Account = PlantedAccount

    /// The account's own pair (another device turned sync on first).
    static let accountWords = (try? RecoveryPhrase.generate()) ?? []

    // MARK: - The drill's two hands

    /// The sync row as the app composes it from this world: the services' status and the record fact the bootstrap's
    /// standing faces keep (what `VariorumApp` injects), with the Protection door where the main window has it.
    static func row(_ world: FirstRoundWorld, _ services: AppServices) -> SyncRowFace {
        SyncRowFace.face(
            allowsSync: services.sync.allowsSync, isConfigured: services.sync.isConfigured,
            signedIn: services.account.variorum != nil, isSyncing: services.sync.status.isSyncing,
            lastError: services.sync.status.lastError, lastErrorIsOffline: services.sync.status.lastErrorIsOffline,
            stalled: services.sync.status.pullStalled, canOpenProtection: true,
            libraryJoined: world.bootstrap.roadStanding?.syncsWithAnAccount)
    }

    /// Her press: the section re-read, `door`'s confirm opened through the one presenter, the secrets typed, the press; rule
    /// 7's moment (a join's) closed as she closes it.
    static func press(
        _ world: FirstRoundWorld, _ door: RoadAccountDoor = .turnOnSync, passphrase: String = "", again: String = "",
        words: [String] = [], gate: GateStyle? = nil, expecting plan: JoinPlan? = nil
    ) async throws -> RoadAccountConfirmModel {
        let account = try #require(world.bootstrap.roadAccount)
        await account.refresh()
        let open = try #require(account.faces?.face(door).openDoor, "\(door): \(String(describing: account.faces?.face(door)))")
        if let plan { #expect(open.spec.join == plan, "\(door): \(String(describing: open.spec.join))") }
        account.open(door)
        let confirm = try #require(account.confirm)
        if let gate { confirm.gate = gate }
        await confirm.submit(passphrase: passphrase, again: again, words: words.joined(separator: " "))
        #expect(confirm.refusal == nil, "\(door): \(String(describing: confirm.refusal))")
        if confirm.moment != nil { confirm.closeMoment() }
        return confirm
    }

    /// **THE GATE'S ASSERTION, every arm:** the sheet stayed for its first round, the round ran to its end, the sheet says
    /// `line`; the sync row (once the round settled) is `row`; Done closes the sheet. Returns the round's outcome.
    @discardableResult
    static func expectFirstRound(
        _ world: FirstRoundWorld, _ confirm: RoadAccountConfirmModel, line: String, row kind: SyncRowFace.Kind,
        rowLine: @autoclosure () -> String? = nil
    ) async throws -> FirstRoundOutcome? {
        let account = try #require(world.bootstrap.roadAccount)
        #expect(account.confirm === confirm, "the sheet stays for its first round")
        guard confirm.round != nil else {
            Issue.record("a first round runs after the act (VX-498) — the sheet said nothing about sync (VX-507)")
            return nil
        }
        let outcome = await confirm.awaitFirstRound()
        #expect(confirm.roundLine == line, "the sheet: \(String(describing: confirm.roundLine))")
        let services = try #require(world.services, "services are composed")
        await FirstRoundWorld.settle(seconds: 5) { !services.sync.status.isSyncing }
        let face = Self.row(world, services)
        #expect(face.kind == kind, "the row: \(face.kind) (\(String(describing: services.sync.status.lastError)))")
        // (Read once the round settled — the clean line carries the round's own stamp.)
        if let rowLine = rowLine() {
            #expect(SyncStatusRow.line(for: face.kind, lastSuccessAt: services.sync.status.lastSuccessAt) == rowLine)
            if kind == .idle, services.sync.status.lastSuccessAt != nil { #expect(rowLine.hasPrefix("Synced ")) }
        }
        confirm.done()
        #expect(account.confirm == nil, "Done closes the sheet")
        return outcome
    }

    /// The row's clean line after a round ("Synced ‹time›").
    static func syncedLine(_ services: AppServices) -> String {
        SyncStatusRow.line(for: .idle, lastSuccessAt: services.sync.status.lastSuccessAt)
    }

    // MARK: - The arms that land

    /// ARM 1 — **the Standard set-up** (no vault yet: rule 7's hand-up, a new passphrase twice and the library's words).
    @Test func arm1_theStandardSetUpRunsItsFirstRound() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            #expect(Self.row(world, services).kind == .notOnYet, "before the act: not on yet, never locked")
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words,
                expecting: .setsUpInLibrarysMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundSetUpLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.composedCount == 1, "no relaunch — the same services ran the round")
            #expect(world.vault.snapshot(Account.account)?.vault.mode == .standard)
            #expect(await world.server.pulls > 0, "the round reached the server")
        }
    }

    /// ARM 2 — **the Standard join** (the account syncs, Standard, on another device): one of the account's secrets, on the
    /// open session.
    @Test func arm2_theStandardJoinRunsItsFirstRound() async throws {
        try await FirstRoundWorld.run { world in
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(world, passphrase: Account.passphrase, expecting: .sameMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundJoinLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.composedCount == 1, "no relaunch, no reopen")
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account)
        }
    }

    /// ARM 3 — **the Castle set-up under Always ask**: the library enters Castle first (Use Castle through the bootstrap's
    /// crossing — its reopen composes fresh services), then turns sync on in Castle (the passphrase set at Use Castle, the
    /// library's words); the act holds the account's keys in session memory (Always ask's custody).
    @Test func arm3_theCastleSetUpUnderAlwaysAskRunsItsFirstRound() async throws {
        try await FirstRoundWorld.run { world in
            world.reopensComposeFreshServices()
            try await world.settlePreActRounds(try await world.composeServices())
            try await world.useCastle(gate: .alwaysAsk)
            let services = try #require(world.services, "the crossing's reopen composed fresh services")
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(
                world, passphrase: Crossing.passphrase, words: world.words, expecting: .setsUpInLibrarysMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundSetUpLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.vault.snapshot(Account.account)?.vault.mode == .castle, "the account was set up in Castle")
            #expect(world.services === services, "the set-up ran on the open session — no reopen")
        }
    }

    /// ARM 4 — **the Castle set-up under Touch ID** (a finger enrolled; the planted press — no hardware): Use Castle with
    /// Touch ID, then the set-up; the act files the keys the Castle way and holds them for the session (VX-487).
    @Test func arm4_theCastleSetUpUnderTouchIDRunsItsFirstRound() async throws {
        try await FirstRoundWorld.run(biometry: .ready) { world in
            world.reopensComposeFreshServices()
            try await world.settlePreActRounds(try await world.composeServices())
            try await world.useCastle(gate: .touchID)
            #expect(world.bootstrap.roadSession?.library.section.settings.gateStyle == .touchID)
            let services = try #require(world.services)
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(
                world, passphrase: Crossing.passphrase, words: world.words, expecting: .setsUpInLibrarysMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundSetUpLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .touchid)] != nil,
                    "the account's keys filed in the Touch ID item")
        }
    }

    /// ARM 5 — **the Castle join** (a Castle library joins an account that syncs in Castle — the same posture, on the open
    /// session): one of the account's secrets.
    @Test func arm5_theCastleJoinRunsItsFirstRound() async throws {
        try await FirstRoundWorld.run { world in
            world.reopensComposeFreshServices()
            try await world.settlePreActRounds(try await world.composeServices())
            try await world.useCastle(gate: .alwaysAsk)
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .castle)
            let services = try #require(world.services)
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(world, passphrase: Account.passphrase, expecting: .sameMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundJoinLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.services === services, "the same posture — no reopen")
        }
    }

    /// ARM 6 — **Move, the same posture**: a library that syncs with another account (bound there before this Mac's open)
    /// moves to the account signed in, which already syncs — rule 16's leave then rule 7's adoption, on the open session.
    @Test func arm6_moveRunsItsFirstRound() async throws {
        let other = SessionFact.signedIn(accountID: Account.other, email: "other@example.test")
        try await FirstRoundWorld.run(prepare: { _, vault, session, words in
            let read = try #require(await ProtectionPaneRead.read(session, signIn: other, exportSwitch: nil))
            let setUp = try #require(ProtectionPaneRead.accountFaces(read, session: session)?.turnOnSync.openDoor)
            let made = await ProtectionAccountRoad.press(
                session, request: RoadAccountRequest(
                    door: .turnOnSync, shown: setUp, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
                signIn: other, exportSwitch: nil)
            #expect(made == .made(receipt: ProtectionWords.turnOnSyncReceipt), "the library syncs with the other account")
            try vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .standard)
        }) { world in
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.other)
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(
                world, .moveToSignedInAccount, passphrase: Account.passphrase, expecting: .sameMode)
            try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundJoinLanded, row: .idle, rowLine: Self.syncedLine(services))
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account, "moved to the account signed in")
            #expect(world.composedCount == 1)
        }
    }

    /// ARM 7 — **the re-keying join through the reopen** (D-B0): a Standard library joins an account that syncs in Castle —
    /// the join enters Castle, re-keys, runs through the reopen; the sheet survives it and confirms the round the reopen's
    /// FRESH services run.
    @Test func arm7_theReKeyingJoinRunsItsFirstRoundThroughTheReopen() async throws {
        try await FirstRoundWorld.run { world in
            world.reopensComposeFreshServices()
            try await world.settlePreActRounds(try await world.composeServices())
            try world.vault.plant(
                accountID: Account.account, passphrase: Account.passphrase, words: Self.accountWords, mode: .castle)
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, gate: .alwaysAsk, expecting: .entersCastle)
            try await Self.expectFirstRound(world, confirm, line: ProtectionWords.firstRoundJoinLanded, row: .idle)
            #expect(world.composedCount == 2, "the reopen's fresh services ran it")
            #expect(world.bootstrap.roadSession?.library.record?.mode == .castle)
        }
    }

    // MARK: - The negative arms (each says its blocker on the sheet AND the row)

    /// NEGATIVE — **offline**: the act lands (the vault is the account's own road), the first round finds the network
    /// down; the sheet and the row both say waiting, never an error.
    @Test func negative_offlineSaysWaitingOnTheSheetAndTheRow() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            await world.server.goOffline()
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words)
            try await Self.expectFirstRound(
                world, confirm, line: "Sync hasn't run yet: Waiting to sync (offline).", row: .offline,
                rowLine: SyncStatusRow.offlineLabel)
            #expect(world.vault.snapshot(Account.account) != nil, "the act landed")
        }
    }

    /// NEGATIVE — **held** (the restore hold, wired before the start as `VariorumApp` wires it): no round runs before the
    /// one Resume press; the sheet says so, naming the banner; the row reads not-synced-yet beneath the hold's banner (the
    /// banner carries the hold's sentence — `RestoreHoldBar`).
    @Test func negative_heldSaysWaitingSinceTheRestore() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices(beforeStart: { $0.sync.roundsHeld = { true } })
            #expect(services.sync.status.roundsCompleted == 0, "held: nothing ran")
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words)
            let outcome = try await Self.expectFirstRound(
                world, confirm, line: ProtectionWords.firstRoundBlocked(ProtectionWords.firstRoundHeld), row: .idle,
                rowLine: "Not synced yet")
            #expect(outcome == .held)
            #expect(await world.server.pulls == 0, "still nothing ran")
        }
    }

    /// NEGATIVE — **not configured** (the owner adoption refused — the run record's F-5): the chain never composes; the sheet
    /// says sync is off, as the row does.
    @Test func negative_notConfiguredSaysSyncIsOff() async throws {
        try await FirstRoundWorld.run(owner: nil) { world in
            let services = try await world.composeServices()
            #expect(!services.sync.isConfigured, "the adoption refused: no chain")
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words)
            let outcome = try await Self.expectFirstRound(
                world, confirm, line: "Sync hasn't run yet: Sync is off.", row: .syncOff, rowLine: "Sync is off")
            #expect(outcome == .notConfigured)
        }
    }

    /// NEGATIVE — **the account-binding gate** (VX-314): the services' session is another account than the one the act bound
    /// the library to; the round refuses (outbox kept, cursor unmoved) and the sheet and the row both say paused.
    @Test func negative_theAccountGateSaysPaused() async throws {
        try await FirstRoundWorld.run { world in
            world.servicesSignIn = Account.other
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            let confirm = try await Self.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words)
            try await Self.expectFirstRound(
                world, confirm, line: "Sync hasn't run yet: \(SyncStatusRow.accountMismatchLabel).",
                row: .accountMismatch, rowLine: SyncStatusRow.accountMismatchLabel)
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account)
        }
    }
}
