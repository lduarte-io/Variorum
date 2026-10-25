//
//  MobileTypedUnlockSyncKeysTests.swift
//  VariorumMobileTests
//
//  VM-8 unit 1, piece 3 — VX-501 ON THE PHONE'S POSTURE (the run record `notes/plans/vm-8-castle-catchup.md`; VX-510's
//  D-B4 is the mechanism — shared `ProtectionOpenRoad.loadSyncKeysAfterTypedUnlock`, pinned on the Mac by
//  `TypedUnlockSyncKeysTests`; no phone pin covered it). Her phone's whole road through the PHONE'S OWN compiled
//  bootstrap over planted leaves (no keychain, no network — `MobilePlantedProtection.swift`), the phone's biometry
//  (Face ID ready):
//    1. a fresh library on the road — the phone's once-shown words card (the creation) — then signed in to an account
//       whose vault is in CASTLE (another device turned sync on first);
//    2. Settings ▸ Protection's JOIN ("Sync this library…" — `.entersCastle`, a RE-KEYING act through the reopen),
//       Always ask chosen, the account's passphrase typed: the library lands in Castle under the account, rule 7's
//       moment said (the passphrase typed — the words not shown);
//    3. a LOCK (Castle under Always ask: no item on the phone at all) — the lobby; the engine's seam holds no keys;
//    4. THE TYPED UNLOCK at the lobby — the account's sync keys load into session memory and the engine's seam reads
//       them: the round runs. RED by behavioral revert (the load's one call in `openTyped`): nothing loaded, the seam
//       refuses — "Sync locked" after every typed unlock (VX-501's red, on the phone).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("VM-8 unit 1 — VX-501 on the phone's posture: the join into Castle, then a typed unlock loads the sync keys")
@MainActor
struct MobileTypedUnlockSyncKeysTests {
    nonisolated static let account = "acct-phone"
    nonisolated static let signedIn = SessionFact.signedIn(accountID: account, email: "her@example.test")
    nonisolated static let passphrase = "correct horse battery staple"

    /// The planted road: a temp slot with the real file leaves, planted custody/memory/Apple/vault/sync keys, the phone's
    /// biometry (Face ID ready), signed in to the account.
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
                scope: "vm8-u1-phone", places: slot.places, deviceName: "Test iPhone", floor: .relaxedForTests,
                custody: custody, syncKeys: keys, apple: apple, vault: vault, memory: memory,
                biometry: FixedBiometryLeaf(.ready), ids: FastIDsLeaf())
            let url = slot.places.slot
            return ProtectionRoadTestHarness(system: system, session: MobileTypedUnlockSyncKeysTests.signedIn, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            })
        }
    }

    /// What the engine's seam would read for a round (nil: it refuses — "Sync locked").
    static func engineKeyID(_ bootstrap: AppBootstrap) -> String? {
        (try? bootstrap.newRoadSyncKeys.currentKeys())?.corpusKeyID
    }

    @Test func herPhonesJoinIntoCastleThenATypedUnlockLoadsTheSyncKeys() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = World()
            let accountsWords = try RecoveryPhrase.generate()
            let accountKeys = try world.vault.plant(
                accountID: Self.account, passphrase: Self.passphrase, words: accountsWords, mode: .castle)
            let bootstrap = AppBootstrap(testStoreURL: world.slot.places.slot, protectionRoad: world.harness())
            await bootstrap.awaitOpen()

            // 1 — the creation: the phone's once-shown words card, then the open.
            guard case .newLibraryWords(let card) = bootstrap.state else {
                Issue.record("a fresh slot creates a library and shows the phone's words card — \(bootstrap.state)")
                return
            }
            card.iveWrittenThemDown()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let section = bootstrap.roadAccount else {
                Issue.record("the library opens, its account section made — \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadSession?.library.record?.mode == .standard, "a fresh library is Standard")

            // 2 — the JOIN into Castle (Settings ▸ Protection's "Sync this library…").
            await section.refresh()
            let join = try #require(section.faces?.turnOnSync.openDoor, "the join arm stands — \(String(describing: section.faces))")
            #expect(join.doorLabel == ProtectionWords.joinSyncDoor && join.spec.join == .entersCastle && join.rekeys)
            #expect(join.gate?.touchIDAvailable == true, "Face ID is a gate choice on the phone")
            #expect(!join.saysRuleTwelve, "her arm carries no rule-12 sentence")
            section.open(.turnOnSync)
            let confirm = try #require(section.confirm, "the join's confirm stands on the presenter")
            confirm.gate = .alwaysAsk
            await confirm.submit(passphrase: Self.passphrase)
            await bootstrap.awaitOpen()
            #expect(confirm.refusal == nil, "the join landed — \(confirm.refusal ?? "")")
            guard case .ready = bootstrap.state else {
                Issue.record("the re-keying join reopened the library — \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadSession?.library.record?.mode == .castle, "the library followed the account into Castle")
            #expect(bootstrap.roadSession?.library.record?.account == Self.account, "the library names the account")
            if case .notShown? = confirm.moment {} else {
                Issue.record("rule 7's moment: the passphrase typed — the words not shown")
            }
            confirm.closeMoment()
            #expect(bootstrap.protection.settingsRequest > 0, "the reopen asked for Protection back (F-U1-3's road)")
            #expect(world.keys.items.isEmpty, "Always ask: no sync-keys item on the phone at all")

            // 3 — the LOCK: the lobby; nothing holds the keys.
            await bootstrap.lock()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("Castle locks into the road's lobby — \(bootstrap.state)")
                return
            }
            #expect(world.keys.sessionSyncKeys(accountID: Self.account) == nil, "the lock dropped session memory")
            #expect(lobby.face.passphraseField, "the typed road stands")

            // 4 — THE TYPED UNLOCK loads the account's sync keys; the engine's seam reads them.
            await lobby.unlock(passphrase: Self.passphrase)
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the typed passphrase opens the library — \(bootstrap.state) \(lobby.message ?? "")")
                return
            }
            #expect(world.keys.sessionSyncKeys(accountID: Self.account) == accountKeys,
                    "the typed unlock loaded the account's keys into session memory (VX-501)")
            #expect(Self.engineKeyID(bootstrap) == accountKeys.rowKeyID, "the engine's seam reads them — the round runs")
            #expect(world.keys.items.isEmpty, "nothing written to the keychain — session memory only")
        }
    }
}
