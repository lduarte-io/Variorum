//
//  HoldBannerAccountTests.swift
//  VariorumTests — VX-329 R1: VX-473 (VX-309 F-U2-2, seen live at its walk's row 3). The restore-hold banner's account
//  clause — *"Sync is waiting — Resume to catch up with your account. …"* — was decided by whether THIS MAC was signed in
//  (the composition root passed `services.account.variorum != nil || services.sync.isConfigured`), so Make this my library
//  while signed in (the new library names no account — the copy carries no sync identity) spoke the catch-up clause over a
//  library that does not sync, where Resume only clears the hold. The fact is the OPEN library's record: its standing faces
//  read it (`RoadStandingModel.syncsWithAnAccount`), and re-read it when an account act lands on the open session and when
//  the pane appears. Planted leaves (`PlantedRoad` + `PlantedAccount` — no keychain, no network); also runs headless in the
//  implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-473 — the hold banner's account clause reads the open library's record (planted, no network)", .serialized)
@MainActor
struct HoldBannerAccountFactTests {
    /// A library naming no account on a SIGNED-IN Mac (what Make this my library lands there): the banner names no
    /// account. Turning sync on binds it on the open session (no reopen) — the landing's re-read says so; a leave unbinds
    /// it — the pane's appearance re-reads it too.
    @Test func anUnboundLibraryOnASignedInMacNamesNoAccountUntilItSyncs() async throws {
        let (road, _, _) = PlantedAccount.road()
        road.session = PlantedAccount.signedIn
        let (session, words) = try await road.created()
        #expect(session.library.record?.account == nil, "a new library names no account")
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(session, ledger: PassphraseReminderLedger(defaults: store.defaults))
        #expect(standing.syncsWithAnAccount == false, "this Mac is signed in; the LIBRARY names no account")
        let banner = LibraryOpenCopy.holdBanner(asOfDay: "October 20, 2026", hasAccount: standing.syncsWithAnAccount ?? true)
        #expect(banner == LibraryOpenCopy.holdBanner(asOfDay: "October 20, 2026", hasAccount: false))
        #expect(!banner.contains("account"), "no account named over a library that doesn't sync")

        // Turning sync on — the pane's press on the OPEN session (set-up: a new passphrase, the library's words).
        let read = try await PlantedAccount.read(session, PlantedAccount.signedIn)
        let open = try #require(ProtectionPaneRead.accountFaces(read)?.face(.turnOnSync).openDoor)
        let outcome = await ProtectionAccountRoad.press(
            session,
            request: RoadAccountRequest(
                door: .turnOnSync, shown: open, typed: TypedSecrets(words: words, newPassphrase: PlantedAccount.passphrase)),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        #expect(outcome == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        standing.rereadAccountBinding()
        #expect(standing.syncsWithAnAccount == true, "the record names the account now — the catch-up clause is true")

        // Stop syncing here (rule 16) — the pane's appearance re-reads the record.
        let leaveRead = try await PlantedAccount.read(session, PlantedAccount.signedIn)
        let leave = try #require(ProtectionPaneRead.accountFaces(leaveRead)?.face(.stopSyncingHere).openDoor)
        let left = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(door: .stopSyncingHere, shown: leave, typed: .none),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        #expect(left == .made(receipt: ProtectionWords.stopSyncingReceipt))
        await standing.refreshPane()
        #expect(standing.syncsWithAnAccount == false)
    }

    /// Hand-made faces (no session behind them) know nothing: nil — the root keeps the shipped wording then.
    @Test func handMadeFacesKnowNothing() {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel(
            faces: .none, reminder: PassphraseReminderModel(
                libraryID: "lib", moment: nil, ledger: PassphraseReminderLedger(defaults: store.defaults),
                facts: { (passphraseSet: true, dismissals: 0) }, recordDismissal: { true }),
            setPassphrase: { _ in .set }, passphraseExists: { true }, receiptsOwed: { [] })
        #expect(standing.syncsWithAnAccount == nil)
        standing.rereadAccountBinding()
        #expect(standing.syncsWithAnAccount == nil)
    }
}

/// THE COMPOSITION, read from the product's sources: the root hands the banner the OPEN LIBRARY's account fact — never the
/// Mac's sign-in — and the bootstrap's account landing re-reads it. Red on the pre-fix root (it passed the sign-in read).
@Suite("VX-473 — the hold banner's composition (source)")
struct HoldBannerAccountCompositionTests {
    /// `App/Variorum/` — through the symlink a headless harness reads this file by, when there is one.
    static let appRoot = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // Protection
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum

    /// A source's CODE — every line with its `//` comment cut off (only code counts).
    static func code(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    @Test func theRootFeedsTheBannerTheOpenLibrarysAccountNeverTheMacsSignIn() throws {
        let root = try Self.code("Variorum/VariorumApp.swift")
        let start = try #require(root.range(of: "RestoreHoldBar("), "the root hosts the banner")
        let end = try #require(root.range(of: "ProtectionRoadBar(", range: start.upperBound..<root.endIndex))
        let call = String(root[start.lowerBound..<end.lowerBound])
        #expect(call.contains("hasAccount:") && call.contains("roadStanding") && call.contains("syncsWithAnAccount"),
                "the banner's account clause reads the open library's standing faces: \(call)")
        #expect(!call.contains("account.variorum") && !call.contains("isConfigured") && !call.contains("services"),
                "never whether this Mac is signed in: \(call)")
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        let landed = try #require(bootstrap.range(of: "landed: {"))
        let after = String(bootstrap[landed.upperBound...].prefix(400))
        #expect(after.contains("rereadAccountBinding()"), "an account act's landing re-reads the record")
    }
}
