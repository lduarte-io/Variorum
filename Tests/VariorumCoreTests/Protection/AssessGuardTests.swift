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
        #expect(guards.deleteOnSightByIDOnlyOn && guards.everyOwnKeyRetiredAtCastleOn)
        #expect(guards.standardRecordNoDestructiveRepairOn)
        #expect(guards.freshVaultBeforeAppleWriteOn)
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

    /// DELETE ON SIGHT BY RECORDED ID ONLY: another Mac's own key for this
    /// library would be deleted for belonging to it.
    @Test func deleteOnSightByIDOnly() throws {
        var world = try AWorld(.castle)
        let retired = PF.id(), anotherMacs = PF.id()
        world.section = world.section.retiringAppleKey(id: retired, at: PF.t0)
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
        world.section = world.section.recordingAppleKey(AppleKeyRecord(id: relinked))
        #expect(try world.assessed().door(.useCastle).spec?.retiresOwnAppleKeys.contains(relinked) == true)
        var off = ProtectionGuards()
        off.everyOwnKeyRetiredAtCastle = false
        #expect(try world.assessed(guards: off).door(.useCastle).spec?.retiresOwnAppleKeys == [world.own.id],
                "red with the guard off: only the live file's key retired")
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

}
#endif
