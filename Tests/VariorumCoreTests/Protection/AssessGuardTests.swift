//
//  AssessGuardTests.swift
//  VariorumCoreTests — VX-305 U2: the guards in `assess`, the open rule and
//  retention are LIVE — each one, switched off (DEBUG only, `ProtectionGuards`),
//  lets its bug through; switched on, it closes it. The red-on-old for new
//  code at the unit level; U4's mutation pins run the fixed scenarios the same
//  way. (Retention's own pin sits beside its suite.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U2 — ProtectionGuards: U2's guards are on, and a Release build has no off-switch")
struct AssessGuardsOnTests {
    @Test func everyU2GuardIsOnByDefault() {
        let guards = ProtectionGuards.all
        #expect(guards.pruneOwnCopiesOnlyOn && guards.noRepairMakesTouchIDOn && guards.noRearmWithoutItemOn)
        #expect(guards.doorTimeVaultCheckOn)
        #expect(guards.deleteOnSightByIDOnlyOn && guards.everyOwnKeyRetiredAtCastleOn && guards.leaveIDGatesCompletionOn)
        #expect(guards.castleKindCustodyThroughLeaveOn && guards.giftsOnlyForThisMacsCopiesOn)
        #expect(guards.standardRecordNoDestructiveRepairOn)
        #expect(guards.freshVaultBeforeAppleWriteOn && guards.rekeyAtEveryCrossingOn)
    }
}

#if DEBUG
@Suite("VX-305 U2 — each assess guard, switched off, lets its bug through (DEBUG mutation pins)")
struct AssessGuardMutationTests {
    /// NO REPAIR MAKES A TOUCH ID ITEM: a rolled-back choice of Touch ID with
    /// no item behind it would get one made — someone else's finger among them.
    @Test func noRepairMakesTouchID() throws {
        var world = try AWorld(.castle)
        world.custody = []
        #expect(try world.assessed().repairs.contains(.recordAlwaysAskQuietly))
        var off = ProtectionGuards()
        off.noRepairMakesTouchID = false
        #expect(try world.assessed(guards: off).repairs.contains(.makeTouchIDItem(fingerprint: PF.fp(world.key))),
                "red with the guard off: a repair makes a Touch ID item")
    }

    /// NO RE-ARM QUESTION WITHOUT AN EXISTING ITEM: a question that appears by
    /// itself after an item vanished could be answered yes to a choice undone.
    @Test func noRearmWithoutItem() throws {
        var world = try AWorld(.castle)
        world.custody = []
        #expect(!(try world.assessed().touchID.rearmQuestion))
        var off = ProtectionGuards()
        off.noRearmWithoutItem = false
        #expect(try world.assessed(guards: off).acts.contains(.touchIDRearmQuestion),
                "red with the guard off: the re-arm question with no item behind it")
    }

    /// THE DOOR-TIME VAULT CHECK: a vault still on the old shared key would
    /// lose its Apple copy's key to the retirement — its other devices their
    /// silent setup.
    @Test func doorTimeVaultCheck() throws {
        let y = PF.id(), shared = PF.id()
        var world = try AWorld(.standard)
        world.session = .signedIn(accountID: y, email: nil)
        world.vault = AWorld.vault(y, .standard(appleKeyID: shared))
        world.appleKeys.oldSharedID = shared
        #expect(try world.assessed().door(.useCastle).refusal == .vaultOnOldSharedKey(account: y))
        var off = ProtectionGuards()
        off.doorTimeVaultCheck = false
        #expect(try world.assessed(guards: off).door(.useCastle).isOpen,
                "red with the guard off: Use Castle opens over a vault on the old key")
    }

    /// DELETE ON SIGHT BY RECORDED ID ONLY: another Mac's own key for this
    /// library would be deleted for belonging to it.
    @Test func deleteOnSightByIDOnly() throws {
        var world = try AWorld(.castle)
        let retired = PF.id(), anotherMacs = PF.id()
        world.section = world.section.retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.t0)
        world.recordSection = world.section
        world.appleKeys.readable = [retired, anotherMacs]
        #expect(!(try world.assessed().repairs.contains(.deleteRetiredAppleKey(id: anotherMacs))))
        var off = ProtectionGuards()
        off.deleteOnSightByIDOnly = false
        #expect(try world.assessed(guards: off).repairs.contains(.deleteRetiredAppleKey(id: anotherMacs)),
                "red with the guard off: another Mac's own key deleted")
    }

    /// EVERY OWN APPLE KEY RETIRED AT ENTERING CASTLE: Re-link's second key, a
    /// predecessor's adopted one, would stay — and keep opening pre-Castle copies.
    @Test func everyOwnKeyRetiredAtCastle() throws {
        var world = try AWorld(.standard)
        let relinked = PF.id()
        world.section = world.section.recordingAppleKey(AppleKeyRecord(id: relinked, purpose: .library, origin: .minted))
        world.recordSection = world.section
        #expect(try world.assessed().door(.useCastle).spec?.retiresOwnAppleKeys.contains(relinked) == true)
        var off = ProtectionGuards()
        off.everyOwnKeyRetiredAtCastle = false
        #expect(try world.assessed(guards: off).door(.useCastle).spec?.retiresOwnAppleKeys == [world.own.id],
                "red with the guard off: only the live file's key retired")
    }

    /// THE LEAVE'S ID GATES ITS COMPLETION: a device that can't read the named
    /// key would close the window with no Apple copy — the account reading
    /// Castle in between.
    @Test func leaveIDGatesCompletion() throws {
        let world = try AssessVaultTests.synced(.castle, vault: .leavingCastle(appleKeyID: PF.id())).0
        #expect(try world.assessed().vault?.mayCompleteLeave == false)
        var off = ProtectionGuards()
        off.leaveIDGatesCompletion = false
        #expect(try world.assessed(guards: off).vault?.mayCompleteLeave == true,
                "red with the guard off: any device completes the leave")
    }

    /// CASTLE-KIND CUSTODY THROUGH A LEAVE's ROTATION: the new keys reach a
    /// Castle-era corpus key through the previous one until it leaves the vault.
    @Test func castleKindCustodyThroughLeave() throws {
        let world = try AssessVaultTests.synced(.castle, vault: .leavingCastle(appleKeyID: PF.id()), previous: "c0").0
        #expect(try world.assessed().vault?.syncKeysCustody == .castleWay)
        var off = ProtectionGuards()
        off.castleKindCustodyThroughLeave = false
        #expect(try world.assessed(guards: off).vault?.syncKeysCustody == .silent,
                "red with the guard off: a Castle-era key within the login password's reach")
    }

    /// GIFTS ONLY FOR THIS MAC'S COPIES: another Mac's library in a shared
    /// folder would get a key file of this Mac's own.
    @Test func giftsOnlyForThisMacsCopies() throws {
        var world = try AWorld(.standard)
        let theirs = PF.id(), key = StoreKey.mint()
        let file = try KeyFile.building(libraryID: theirs, key: key, epoch: 1, locks: NewKeyLocks(apple: AppleKeyMaterial.mint()))
        let folders = CF.macFolder(theirs, CF.macB)
        world.extraEntries = [
            CatalogEntry(place: .farFolder, folders: folders, name: CF.snapshotName(CF.stamp(1), key)),
            CatalogEntry(place: .farFolder, folders: folders, name: CF.pairName(CF.stamp(1), key), bytes: try file.encoded()),
        ]
        #expect(try world.assessed().movePlan.otherLibraries.isEmpty)
        var off = ProtectionGuards()
        off.giftsOnlyForThisMacsCopies = false
        #expect(try world.assessed(guards: off).movePlan.otherLibraries == [theirs],
                "red with the guard off: a gift for another Mac's copies")
    }

    /// NOTHING DESTRUCTIVE ON A STANDARD RECORD's WORD ALONE: a swapped-in
    /// Standard file would get a Touch ID item deleted.
    @Test func standardRecordNoDestructiveRepair() throws {
        var world = try AWorld(.standard)
        let castleItem = PF.fp(StoreKey.mint())
        world.custody.append(CustodyItemFact(fingerprint: castleItem, itemClass: .touchid))
        #expect(!(try world.assessed().repairs.contains(.deleteTouchIDItem(fingerprint: castleItem))))
        var off = ProtectionGuards()
        off.standardRecordNoDestructiveRepair = false
        #expect(try world.assessed(guards: off).repairs.contains(.deleteTouchIDItem(fingerprint: castleItem)),
                "red with the guard off: a delete on a Standard record's word")
    }

    /// DECISION 35: a synced library's Apple copy would land with the vault
    /// unread — on what might be a Castle account (the window's phone).
    @Test func freshVaultBeforeAppleWrite() throws {
        let x = PF.id()
        var world = try AWorld(.standard, account: x)
        world.liveFile = world.liveFile.droppingApple()
        world.session = .signedIn(accountID: x, email: nil)
        #expect(!(try world.assessed().repairs.contains(.landAppleWrap(appleKeyID: world.own.id))))
        var off = ProtectionGuards()
        off.freshVaultBeforeAppleWrite = false
        #expect(try world.assessed(guards: off).repairs.contains(.landAppleWrap(appleKeyID: world.own.id)),
                "red with the guard off: Apple-reachable with no fresh vault")
    }

    /// THE RE-KEY AT EVERY CROSSING: leaving an account in Standard would keep
    /// the key — the account you left keeping what you write after. (The
    /// landing's half left with rule 17 — VX-378 U1.)
    @Test func rekeyAtEveryCrossing() throws {
        let x = PF.id()
        var world = try AWorld(.standard, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(x, .standard(appleKeyID: PF.id()))
        #expect(try world.assessed().door(.thisMacOnly).spec?.rekeys == true)
        var off = ProtectionGuards()
        off.rekeyAtEveryCrossing = false
        #expect(try world.assessed(guards: off).door(.thisMacOnly).spec?.rekeys == false,
                "red with the guard off: a Standard leave keeps the key")
    }
}
#endif
