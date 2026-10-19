//
//  RoadJoinFollowSurfaceTests.swift
//  VariorumTests — VX-308 U2 piece 5: THE JOIN'S AND THE FOLLOW'S MAC FACES build and lay out (hosted in a real window — a
//  face that crashes or cannot lay out fails here): the section with the join, Move and the follow (its notice beside its
//  door), the confirm in each new shape (one secret with the gate choice; the follow out typing nothing), and rule 7's
//  words moment (the typed words over `WordsLookPanel`; the notice alone). And THE ONE REOPENING SEAM through
//  `AppBootstrap` over the PLANTED road (no keychain, the planted vault — no network): a same-posture join on the open
//  session, then the account's other device enters Castle and the follow runs through the seam (the pool closed, the
//  reopen in Castle) with its Done spoken ONCE on the reopened window's status seam — and, stopped past its swap
//  (VX-107), the reopen's settle finishes it and says the same Done once, never twice. Mac only.
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-308 U2 — the join's and the follow's Mac faces (hosted) and the reopening seam (planted)", .serialized)
struct RoadJoinFollowSurfaceTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []

    /// The section hosts the join, Move (open and its not-yet arm) and the follow with its notice.
    @Test func theSectionHostsTheJoinMoveAndTheFollow() async {
        let follow = RoadAccountDoorOpen(
            door: .follow, ask: .oneSecret, newPassphrase: false,
            sentences: [ProtectionWords.followNotice(.intoCastle, device: "Studio Mac", day: "October 19")],
            spec: DoorSpec(requires: .oneSecret, rekeys: true, synced: true),
            gate: RoadGateChoice(touchIDAvailable: true, preselected: .touchID), follow: .intoCastle,
            notice: ProtectionWords.followNotice(.intoCastle, device: "Studio Mac", day: "October 19"))
        var move = PlantedJoin.join()
        move = RoadAccountDoorOpen(
            door: .moveToSignedInAccount, ask: .oneSecret, newPassphrase: false, sentences: move.sentences, spec: move.spec,
            label: ProtectionWords.moveDoor(PlantedAccount.email))
        let shapes: [RoadAccountFaces] = [
            PlantedAccountRoads.faces(turnOnSync: .open(PlantedJoin.join(.entersCastle))),
            RoadAccountFaces(
                situation: .inSync(email: PlantedAccount.email), turnOnSync: .hidden,
                stopSyncingHere: .refused(ProtectionWords.doorRefusedFollowOwed),
                deleteAccountHere: .open(PlantedAccountRoads.leave(.deleteAccountHere)), thisMacOnly: .hidden, move: .hidden,
                signOut: true, signIn: false, vaultUnreachable: false, follow: .open(follow)),
            RoadAccountFaces(
                situation: .otherAccount(signedInEmail: PlantedAccount.email, sameEmail: false), turnOnSync: .hidden,
                stopSyncingHere: .hidden, deleteAccountHere: .hidden, thisMacOnly: .hidden, move: .open(move),
                signOut: true, signIn: false, vaultUnreachable: false),
            RoadAccountFaces(
                situation: .otherAccount(signedInEmail: PlantedAccount.email, sameEmail: true), turnOnSync: .hidden,
                stopSyncingHere: .hidden, deleteAccountHere: .hidden, thisMacOnly: .hidden,
                move: .notYet(ProtectionWords.moveNotYet), signOut: true, signIn: false, vaultUnreachable: false),
        ]
        for faces in shapes {
            let planted = PlantedAccountRoads()
            planted.faces = faces
            let model = RoadAccountModel(roads: planted.roads)
            model.signOutRoad = {}
            await model.refresh()
            await SurfaceComposition.host(
                Form { RoadAccountSection(model: model) }.formStyle(.grouped), size: NSSize(width: 640, height: 600))
        }
    }

    /// Each new confirm shape hosts: one secret with the gate choice (Touch ID here, and Always ask alone); the follow out
    /// typing nothing; rule 7's moment with the typed words, and the notice alone.
    @Test func eachNewSheetShapeHosts() async throws {
        let gated = RoadAccountConfirmModel(
            door: PlantedJoin.join(.entersCastle, gate: RoadGateChoice(touchIDAvailable: true, preselected: .touchID)),
            act: { _ in .refused(ProtectionWords.passphraseDoesNotOpen) }) { _ in }
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: gated), size: NSSize(width: 480, height: 700))
        await gated.submit(passphrase: "p")
        #expect(gated.refusal == ProtectionWords.passphraseDoesNotOpen)
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: gated), size: NSSize(width: 480, height: 700))
        let alwaysAsk = RoadAccountConfirmModel(
            door: PlantedJoin.follow(.intoCastle, gate: RoadGateChoice(touchIDAvailable: false, preselected: .alwaysAsk)),
            act: { _ in .refused("x") }) { _ in }
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: alwaysAsk), size: NSSize(width: 480, height: 600))
        let out = RoadAccountConfirmModel(door: PlantedJoin.follow(.intoStandard), act: { _ in .refused("x") }) { _ in }
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: out), size: NSSize(width: 480, height: 500))
        let shown = RoadAccountConfirmModel(
            door: PlantedJoin.join(), act: { _ in .made(receipt: "joined", wordsReplaced: true) }) { _ in }
        await shown.submit(words: Self.words.joined(separator: " "))
        #expect(shown.moment != nil)
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: shown), size: NSSize(width: 480, height: 640))
        let notShown = RoadAccountConfirmModel(
            door: PlantedJoin.join(), act: { _ in .made(receipt: "joined", wordsReplaced: true) }) { _ in }
        await notShown.submit(passphrase: "p")
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: notShown), size: NSSize(width: 480, height: 400))
    }

    /// The moment's face is the one look idiom (by source): `WordsLookPanel` under rule 7's sentence, the notice alone with
    /// its OK, and the sheet never dismissed past the moment by a stray press.
    @Test func theMomentRidesTheOneLookIdiom() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Protection/RoadAccountSheet.swift"),
            encoding: .utf8)
        #expect(source.contains("WordsLookPanel(look: look, tokens: tokens)"))
        #expect(source.contains("ProtectionWords.joinWordsSentence") && source.contains("ProtectionWords.joinWordsNotShown"))
        #expect(source.contains(".interactiveDismissDisabled(model.busy || model.moment != nil)"))
        #expect(!source.contains("NSPasteboard") && !source.contains(".textSelection(.enabled)"), "no new clipboard road")
    }

    // MARK: - The reopening seam through AppBootstrap (planted)

    private func bootstrap(_ road: PlantedRoad, session: SessionFact) -> AppBootstrap {
        let url = road.slot.places.slot
        return AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "", reason: "today's road is not taken here")) },
            gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
            testPresence: StoreFilePresence.classify(at: url),
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: session, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
    }

    private func ready(_ bootstrap: AppBootstrap) async {
        await bootstrap.awaitOpen()
        if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
    }

    /// A library on the planted road joined (same posture, on the open session — the notice-only moment, closed), then
    /// the account's other device enters Castle under the account's pair. Returns the bootstrap ready on it.
    private func joinedThenEnteredElsewhere(_ road: PlantedRoad, _ vault: PlantedVaultLeaf) async throws -> AppBootstrap? {
        let accountWords = try RecoveryPhrase.generate()
        let keys = try vault.plant(
            accountID: PlantedAccount.account, passphrase: PlantedAccount.passphrase, words: accountWords, mode: .standard)
        let bootstrap = bootstrap(road, session: PlantedAccount.signedIn)
        await ready(bootstrap)
        guard case .ready = bootstrap.state else {
            Issue.record("the planted slot creates and opens: \(bootstrap.state)")
            return nil
        }
        let account = try #require(bootstrap.roadAccount)
        await account.refresh()
        #expect(account.faces?.turnOnSync.openDoor?.spec.join == .sameMode)
        account.open(.turnOnSync)
        let join = try #require(account.confirm)
        await join.submit(passphrase: PlantedAccount.passphrase)
        guard case .notShown? = join.moment else {
            Issue.record("the passphrase-typed join's moment: \(String(describing: join.moment))")
            return nil
        }
        join.closeMoment()
        #expect(account.confirm == nil && bootstrap.roadSession?.library.record?.account == PlantedAccount.account)
        try vault.enterCastleElsewhere(
            PlantedAccount.account, held: keys, passphrase: PlantedAccount.passphrase, words: accountWords)
        return bootstrap
    }

    /// THE FOLLOW THROUGH THE SEAM: the follow door opens; its press closes the pool, re-keys into Castle and reopens on
    /// the new road; the reopened window's status seam says the Done ONCE; Settings is asked back to Protection.
    @Test func theFollowRunsThroughTheReopeningSeam() async throws {
        try await withRoadDependencies {
            let (road, vault, _) = PlantedAccount.road()
            guard let bootstrap = try await joinedThenEnteredElsewhere(road, vault) else { return }
            let before = try #require(bootstrap.roadSession?.key)
            let account = try #require(bootstrap.roadAccount)
            await account.refresh()
            #expect(account.faces?.follow.openDoor?.follow == .intoCastle)
            account.open(.follow)
            let follow = try #require(account.confirm)
            follow.gate = .alwaysAsk
            await follow.submit(passphrase: PlantedAccount.passphrase)
            await ready(bootstrap)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the reopen lands ready: \(bootstrap.state)")
                return
            }
            #expect(account.confirm == nil && session.key != before && session.library.record?.mode == .castle)
            var spoken: [String] = []
            bootstrap.roadStanding?.speak = { spoken.append($0) }
            #expect(spoken == [ProtectionWords.followDone(.intoCastle)], "the Done, once, on the reopened window")
        }
    }

    /// VX-107 THROUGH THE SEAM: the follow stops past its swap (a step after it fails); the seam owes nothing of its own,
    /// the reopen's settle finishes the follow and says its Done — once, never twice.
    @Test func vx107_aFollowStoppedPastItsSwapIsSaidOnceByTheReopensSettle() async throws {
        try await withRoadDependencies {
            let (road, vault, _) = PlantedAccount.road()
            guard let bootstrap = try await joinedThenEnteredElsewhere(road, vault) else { return }
            let account = try #require(bootstrap.roadAccount)
            await account.refresh()
            account.open(.follow)
            let follow = try #require(account.confirm)
            follow.gate = .alwaysAsk
            road.custody.failingDeletes = 1  // `retireOldCustody` — after the swap
            await follow.submit(passphrase: PlantedAccount.passphrase)
            await ready(bootstrap)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the reopen lands ready: \(bootstrap.state)")
                return
            }
            #expect(session.report.settledFollow == .intoCastle && session.library.section.actInFlight == nil,
                    "the reopen's settle finished it")
            var spoken: [String] = []
            bootstrap.roadStanding?.speak = { spoken.append($0) }
            #expect(spoken == [ProtectionWords.followDone(.intoCastle)], "said once — by the settle, not the press")
        }
    }
}
