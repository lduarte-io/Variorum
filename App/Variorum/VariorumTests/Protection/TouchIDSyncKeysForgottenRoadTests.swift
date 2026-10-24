//
//  TouchIDSyncKeysForgottenRoadTests.swift
//  VariorumTests — VX-517 (the VX-510 run record's D-B8, on unit B2's trace T-B5-2 / T-B5-4), THROUGH THE ROAD'S DOORS as
//  the walk presses them: the TOUCH ID class of sync keys was never forgotten — the production leaf's listing
//  (`KeychainSyncKeysLeaf.syncKeyItems()`, no candidates wired) is blind to a Touch ID item with no silent sibling, and
//  every forget and drop read that listing — so a Castle + Touch ID library's item outlived its leave and Use Standard,
//  and the Standard library that followed read it first at every key door (a prompt each on the real leaf). The core's
//  pins are `TouchIDSyncKeysForgottenTests` (the executor over its world); these drive the same acts through the app's
//  roads over the planted leaves with `listsLikeProduction` ON (never the all-seeing planted listing — which is why no
//  test ever saw this) and its `touchIDReads` counter (every context-less Touch ID read — a prompt on the real leaf).
//  Also headless in the implementer's harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-517 (D-B8) — through the road's doors: the Touch ID sync-keys item forgotten, a Standard library never reads it")
@MainActor
struct TouchIDSyncKeysForgottenRoadTests {
    typealias Account = PlantedAccount
    typealias World = TouchIDUnlockSyncKeysTests.World

    static func touchIDItem(_ world: World) -> AccountKeys? {
        world.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .touchid)]
    }

    /// A synced Castle + Touch ID library (VX-487's world), its leaf listing as production lists.
    static func castleTouchIDSynced() async throws -> World {
        let world = try await TouchIDUnlockSyncKeysTests.castleTouchIDSynced()
        world.keys.listsLikeProduction = true
        #expect(Self.touchIDItem(world) != nil, "precondition: the account's keys in the Touch ID item")
        #expect(world.keys.items.count == 1, "precondition: Castle keeps no silent item — the Touch ID item is the only one")
        return world
    }

    /// THE WALK'S ROAD: Use Standard on a synced Castle + Touch ID library (both secrets typed), then Change passphrase on
    /// the now-Standard library. RED on the pre-fix tree: Use Standard left the Castle-era Touch ID item standing (the
    /// drop's blind listing), and the key door then read the Touch ID class first — twice: two prompts on a Standard library.
    @Test func vx517_useStandardThenChangePassphraseNeverTouchesTheTouchIDClass() async throws {
        let world = try await Self.castleTouchIDSynced()
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let read = try await Account.read(world.session, Account.signedIn)
        let exports = PlantedExportSwitch()
        let faces = try #require(ProtectionCrossings.readCrossings(world.session, exportSwitch: exports.road, read: read))
        let shown = try #require(faces.useStandard.openDoor, "\(faces.useStandard)")
        let typed = TypedSecrets(passphrase: Account.passphrase, words: world.words)
        world.session.executor.configuration.session = Account.signedIn
        #expect(ProtectionCrossings.preflight(
            world.session, door: .useStandard, shown: shown, typed: typed, exportSwitch: exports.road, read: read) == .ready)
        let reads = world.keys.touchIDReads
        let crossed = await ProtectionCrossings.cross(
            world.session, door: .useStandard, typed: typed, gate: .alwaysAsk, exportSwitch: exports.road)
        #expect(crossed.outcome == .made(.useStandard, exportTurnedOff: false), "\(crossed.outcome)")
        #expect(world.session.library.record?.mode == .standard)
        #expect(Self.touchIDItem(world) == nil, "the Castle-era Touch ID item goes with the posture")
        #expect(world.keys.items[SyncKeysItemFact(accountID: Account.account, itemClass: .silent)] != nil,
                "the keys filed silently (Standard's custody)")
        let doors = try #require(await ProtectionKeyDoorRoad.read(world.session, signIn: Account.signedIn, exportSwitch: nil))
        let change = try #require(doors.face(.changePassphrase).openDoor, "\(doors.face(.changePassphrase))")
        let pressed = await ProtectionKeyDoorRoad.press(
            world.session, request: RoadKeyDoorRequest(
                door: .changePassphrase, shown: change, current: Account.passphrase, new: "a standard era passphrase"),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(pressed == .made(ProtectionWords.changePassphraseReceipt), "\(pressed)")
        #expect(world.keys.touchIDReads == reads, "neither Use Standard nor the key door read the Touch ID class — no prompt")
    }

    /// RULE 16 — each LOCAL LEAVE of a synced Castle + Touch ID library forgets the account's Touch ID item (its only one).
    /// RED on the pre-fix tree: the leave's forget walked the blind listing and the item stayed.
    @Test(arguments: [RoadAccountDoor.stopSyncingHere, .deleteAccountHere, .thisMacOnly])
    func vx517_eachLeaveOfACastleTouchIDLibraryForgetsItsTouchIDItem(_ door: RoadAccountDoor) async throws {
        let world = try await Self.castleTouchIDSynced()
        // This Mac Only is the signed-out road; the other two are the signed-in ones.
        let signIn = door == .thisMacOnly ? SessionFact.signedOut : Account.signedIn
        let read = try await Account.read(world.session, signIn)
        let shown = try #require(ProtectionPaneRead.accountFaces(read)?.face(door).openDoor)
        let reads = world.keys.touchIDReads
        let outcome = await ProtectionAccountRoad.press(
            world.session, request: RoadAccountRequest(door: door, shown: shown, typed: .none), signIn: signIn,
            exportSwitch: nil)
        #expect(outcome == .made(receipt: door.receipt), "\(outcome)")
        #expect(world.session.library.record?.account == nil, "the record stops naming the account")
        #expect(Self.touchIDItem(world) == nil, "this Mac forgets the account's Touch ID item")
        #expect(world.keys.accountsHeld.isEmpty, "this Mac forgets every class of the account's sync keys")
        #expect(world.keys.touchIDReads == reads, "a leave reads no sync keys")
    }
}
