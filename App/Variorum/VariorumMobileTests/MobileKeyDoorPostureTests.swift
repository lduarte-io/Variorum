//
//  MobileKeyDoorPostureTests.swift
//  VariorumMobileTests
//
//  VM-8 unit 2 — THE KEY DOORS AND THE LEAVES ON THE PHONE'S POSTURE (the run record `notes/plans/vm-8-castle-catchup.md`,
//  UNIT 2 — LIVE STATUS piece 6): two core rules the brief says to VERIFY on the phone by pin, not re-trace — VX-530 (a
//  Castle + Touch ID key door reads the account's Touch ID sync-keys item AT MOST ONCE — never where a secret in hand
//  derives the keys; the core's `KeyDoorTouchIDReadsTests`) and VX-517 (every forget deletes each class of an account's
//  sync-keys item BY NAME, never by a listing — the production leaf's listing is blind to a Touch ID item with no silent
//  sibling; the Mac's `TouchIDSyncKeysForgottenRoadTests`). Her phone's posture through the PHONE'S OWN compiled bootstrap
//  over planted leaves (`MobilePlantedProtection.swift` — no keychain, no network), Face ID ready: a fresh library, signed
//  in to an account whose vault is in Castle, the JOIN with FACE ID chosen at the press (the custody item and the
//  account's Touch ID sync-keys item made), then the doors as the phone's screen presses them (`bootstrap.roadKeyDoors`,
//  `bootstrap.roadAccount`). The counting leaf's `touchIDReads` is every context-less Touch ID read — a Face ID sheet each
//  on the real leaf. GUARDS: green on this tree (the mechanisms are VX-530's and VX-517's, red-on-old in their own records).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("VM-8 unit 2 — VX-530 and VX-517 on the phone's posture (Castle + Face ID, the phone's own bootstrap)")
@MainActor
struct MobileKeyDoorPostureTests {
    nonisolated static let account = "acct-phone-u2"
    nonisolated static let signedIn = SessionFact.signedIn(accountID: account, email: "her@example.test")
    nonisolated static let passphrase = "correct horse battery staple"
    nonisolated static let renewed = "a castle passphrase made anew"
    nonisolated static let reset = "another castle passphrase anew"

    @MainActor
    final class World {
        let slot = TempSlot()
        let custody = PlantedCustodyLeaf()
        let memory = PlantedMemoryLeaf()
        let apple = InMemoryAppleKeysLeaf()
        let vault = PlantedVaultLeaf()
        let keys = PlantedSyncKeysLeaf()

        func harness() -> ProtectionRoadTestHarness {
            let system = ProtectionSystem(
                scope: "vm8-u2-phone", places: slot.places, deviceName: "Test iPhone", floor: .relaxedForTests,
                custody: custody, syncKeys: keys, apple: apple, vault: vault, memory: memory,
                biometry: FixedBiometryLeaf(.ready), ids: FastIDsLeaf())
            let url = slot.places.slot
            return ProtectionRoadTestHarness(system: system, session: MobileKeyDoorPostureTests.signedIn, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            })
        }

        var touchIDSyncKeys: AccountKeys? {
            keys.items[SyncKeysItemFact(accountID: MobileKeyDoorPostureTests.account, itemClass: .touchid)]
        }
    }

    /// Her phone's road to CASTLE + FACE ID: the creation (the phone's words card), then the JOIN ("Sync this library…" —
    /// `.entersCastle`, re-keying through the reopen) with FACE ID chosen at the press and the account's passphrase typed.
    static func castleFaceIDSynced(_ world: World) async throws -> AppBootstrap? {
        _ = try world.vault.plant(
            accountID: account, passphrase: passphrase, words: try RecoveryPhrase.generate(), mode: .castle)
        let bootstrap = AppBootstrap(testStoreURL: world.slot.places.slot, protectionRoad: world.harness())
        await bootstrap.awaitOpen()
        guard case .newLibraryWords(let card) = bootstrap.state else {
            Issue.record("a fresh slot creates a library and shows the phone's words card — \(bootstrap.state)")
            return nil
        }
        card.iveWrittenThemDown()
        await bootstrap.awaitOpen()
        guard case .ready = bootstrap.state, let section = bootstrap.roadAccount else {
            Issue.record("the library opens, its account section made — \(bootstrap.state)")
            return nil
        }
        await section.refresh()
        let join = try #require(section.faces?.turnOnSync.openDoor, "the join arm stands")
        #expect(join.spec.join == .entersCastle && join.gate?.touchIDAvailable == true)
        section.open(.turnOnSync)
        let confirm = try #require(section.confirm, "the join's confirm stands on the presenter")
        confirm.gate = .touchID
        await confirm.submit(passphrase: passphrase)
        await bootstrap.awaitOpen()
        #expect(confirm.refusal == nil, "the join landed — \(confirm.refusal ?? "")")
        guard case .ready = bootstrap.state else {
            Issue.record("the re-keying join reopened the library — \(bootstrap.state)")
            return nil
        }
        confirm.closeMoment()
        #expect(bootstrap.roadSession?.library.record?.mode == .castle, "Castle, under the account")
        #expect(world.touchIDSyncKeys != nil, "precondition: the account's keys in the Touch ID sync-keys item (Face ID)")
        #expect(world.custody.items.keys.contains { $0.itemClass == .touchid }, "precondition: the Face ID custody item")
        return bootstrap
    }

    /// **VX-530 on the phone:** Change passphrase on a synced Castle + Face ID library reads the account's Touch ID
    /// sync-keys item NEVER (the typed current passphrase opens the vault — the keys derive from it); Reset forgotten
    /// passphrase with Face ID reads it ONCE (the press confirms presence on the library's own item; the account's keys are
    /// read last and once). Session memory emptied first — the worst case (nothing loaded them).
    @Test func aCastleFaceIDKeyDoorReadsTheTouchIDSyncKeysItemAtMostOnce() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = World()
            guard let bootstrap = try await Self.castleFaceIDSynced(world) else { return }
            let doors = try #require(bootstrap.roadKeyDoors)

            world.keys.session = [:]
            await doors.refresh()
            let change = try #require(doors.faces?.changePassphrase.openDoor, "\(String(describing: doors.faces))")
            #expect(change.synced, "the account's lock changes with it (rule 7)")
            doors.open(.changePassphrase)
            let changing = try #require(doors.confirm, "Change's confirm on the presenter")
            let beforeChange = world.keys.touchIDReads
            await changing.submit(current: Self.passphrase, new: Self.renewed, again: Self.renewed)
            #expect(changing.refusal == nil, "Change landed — \(changing.refusal ?? "")")
            #expect(world.keys.touchIDReads - beforeChange == 0, "the secret in hand derives the keys — no Face ID sheet")

            world.keys.session = [:]
            await doors.refresh()
            let reset = try #require(doors.faces?.resetForgottenPassphrase.openDoor)
            #expect(reset.reset == .wordsOrTouchID(touchID: true), "Castle's forgot road offers Face ID where its item stands")
            doors.open(.resetForgottenPassphrase)
            let resetting = try #require(doors.confirm, "Reset's confirm on the presenter")
            #expect(resetting.offersTouchID)
            let beforeReset = world.keys.touchIDReads
            await resetting.submitWithTouchID(new: Self.reset, again: Self.reset)
            #expect(resetting.refusal == nil, "Reset by Face ID landed — \(resetting.refusal ?? "")")
            #expect(world.keys.touchIDReads - beforeReset == 1, "once per act — never twice")
            #expect(world.touchIDSyncKeys != nil, "the item read, never forgotten by a key door")
        }
    }

    /// **VX-517 on the phone:** *Stop syncing here* (rule 16's local leave) on a synced Castle + Face ID library forgets the
    /// account's Touch ID sync-keys item BY NAME — under a listing that is BLIND to it (production's: no silent sibling).
    @Test func aLeaveForgetsTheTouchIDClassByName() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = World()
            guard let bootstrap = try await Self.castleFaceIDSynced(world) else { return }
            world.keys.listsLikeProduction = true
            #expect(!(try world.keys.syncKeyItems()).contains { $0.itemClass == .touchid },
                    "precondition: the listing is blind to the Touch ID item, as production's is")
            let section = try #require(bootstrap.roadAccount)
            await section.refresh()
            _ = try #require(section.faces?.stopSyncingHere.openDoor, "\(String(describing: section.faces))")
            section.open(.stopSyncingHere)
            let leaving = try #require(section.confirm)
            await leaving.submit()
            #expect(leaving.refusal == nil, "the leave landed — \(leaving.refusal ?? "")")
            #expect(bootstrap.roadSession?.library.record?.account == nil, "the library names no account now")
            #expect(world.touchIDSyncKeys == nil, "the Touch ID class forgotten by name (VX-517)")
            #expect(world.keys.session[Self.account] == nil, "and session memory dropped")
        }
    }
}
