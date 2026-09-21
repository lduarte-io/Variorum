//
//  AppleRelinkDoorTests.swift
//  VariorumTests
//
//  RUN A batch A3 — 17m, THE RE-LINK YOUR APPLE ACCOUNT DOOR's state
//  transitions. The door is NEW capability, so these pins ARE its
//  specification: what it refuses and where, what exactly it writes, and the
//  arms in which nothing is written at all.
//
//  THE WORLD is the two harnesses the custody suites already keep, joined:
//  a `ProtectionController` over the SCRIPTED gate (`Phase13pControllerTests`'
//  pattern — no Keychain, no LocalAuthentication, no prompts anywhere) and a
//  REAL `EncryptionSession` over an emulated `key_vault` RPC (the
//  `EncryptionFlowTests` pattern — `VaultRPCEmulation` enforces the key
//  proof, the CAS and the whole-row replace, so a write that lands here
//  landed through the road the server actually keeps). The two are joined by
//  the PRODUCTION wire, copied from `wireOneSecretHooks` verbatim:
//  `controller.healAppleHeldCopy = { await session.relandAppleHeldCopy(under: $0) }`.
//
//  LIVE iCLOUD KEYCHAIN IS NOT EXERCISABLE BY AN AGENT — a real Apple-ID
//  switch and a real iCloud Keychain reset are acts on her account, not the
//  harness's. What these pins prove is everything on this side of that seam:
//  the orphaned vault row, the door's write, and the enroll road that then
//  succeeds with nothing typed.
//

import CryptoKit
import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// The `key_vault` row, emulated (the app suites' minimal twin — the same
/// double `EncryptionFlowTests`, `KeychainOffMainTests` and
/// `DataSafetyFacesTests` each keep, over the shared `VaultRPCEmulation`).
private final class RelinkVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        if let served = VaultRPCEmulation.serveUpdate(request, row: &row) {
            return response(served.status, served.body)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            row = request.httpBody
            return response(201)
        case "PATCH":
            return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
        default:
            return response(405)
        }
    }
}

/// A device's sync custody, boxed (the plain item alone — every world here is
/// Standard, where custody is the silent item).
private final class RelinkCustody: @unchecked Sendable {
    private let lock = NSLock()
    private var record: SyncCustodyRecord?

    init(_ record: SyncCustodyRecord? = nil) { self.record = record }

    func set(_ new: SyncCustodyRecord?) { lock.lock(); record = new; lock.unlock() }

    var leaves: E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { _ in true },
            savePlain: { [self] new in lock.lock(); record = new; lock.unlock(); return true },
            loadPlain: { [self] in lock.lock(); defer { lock.unlock() }; return record },
            gatedExists: { false },
            deletePlain: { [self] in lock.lock(); record = nil; lock.unlock(); return true },
            deleteGated: { true })
    }
}

@MainActor
@Suite("17m — the Re-link Your Apple Account door")
struct AppleRelinkDoorTests {
    private static let passphrase = "orchard-lantern-13"

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// One device, as this batch needs it: a Standard library (its key file
    /// carrying the Apple copy under whatever key its Keychain holds, the raw
    /// key in the silent item), a controller over the scripted gate, and —
    /// when `holdsKeys` — a real `EncryptionSession` whose custody holds this
    /// account's master.
    private struct Device {
        let controller: ProtectionController
        let session: EncryptionSession?
        let client: KeyVaultClient
        let appleKeys: InMemoryAppleKeyBacking
        let envelopeBox: ScriptedEnvelopeBox
        let custody: RelinkCustody
        let store: DeviceKeyStore?
        let key: StoreKey
        /// What `landEnrollment` was handed (the silent Standard enroll road
        /// — "nothing typed" made observable).
        let landed: LockIsolated<[DeviceKeyMaterial]>
    }

    private func client(over vault: RelinkVault, deviceName: String) -> KeyVaultClient {
        KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: deviceName),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: "user-relink")),
            load: vault.load)
    }

    /// A device on this account. `appleKey` is what ITS iCloud Keychain hands
    /// back (nil = hands back nothing at all); `bornUnder` is the key its own
    /// key file's Apple copy sits under (defaults to `appleKey`).
    private func device(
        over vault: RelinkVault, appleKey: AppleKey?, bornUnder: AppleKey? = nil,
        deviceName: String = "this Mac", storeID: String = "store-1",
        holdsKeys: Bool = true, settingUpTheAccountUnder setUpApple: AppleKey? = nil
    ) async throws -> Device {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope(storeID: storeID)
        if let fileKey = bornUnder ?? appleKey {
            try envelope.setAppleWrappedCopy(
                key: key, under: fileKey.symmetricKey, appleKeyID: fileKey.id)
        }
        let appleKeys = InMemoryAppleKeyBacking(key: appleKey)
        let backing = InMemoryStoreKeyGuardBacking(auto: key, gated: nil)
        let envelopeBox = ScriptedEnvelopeBox(envelope)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: envelopeBox, stamps: ScriptedStampsBox(), appleKey: appleKeys)
        let custody = RelinkCustody(SyncCustodyRecord(deviceID: deviceName, material: nil))
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { [kdf = fastKDF()] in kdf },
            storeID: { storeID },
            syncCustodyLeaves: { _ in custody.leaves },
            syncCustodySession: SyncCustodySession()))
        controller.adoptResident(nil)  // Standard: the silent item releases on demand

        let client = self.client(over: vault, deviceName: deviceName)
        var session: EncryptionSession?
        var store: DeviceKeyStore?
        if holdsKeys {
            let keyStore = DeviceKeyStore.inMemory()
            let made = EncryptionSession(store: keyStore, client: client, signedIn: { true })
            // The library's own posture + its iCloud key, as the production
            // wiring hands them over (`wireOneSecretHooks`).
            made.libraryPosture = { .standard }
            made.readAppleKey = { appleKeys.key }
            made.readOrMintAppleKey = { setUpApple ?? appleKeys.key }
            made.storeTie = StoreTie(
                libraryPosture: { .standard }, hasPassphrase: { false },
                hasRecoveryWords: { false }, verifyPassphrase: { _ in nil },
                setPassphrase: { _ in nil }, verifyRecoveryWords: { _ in nil },
                passphraseKDF: { [kdf = fastKDF()] in kdf })
            if setUpApple != nil {
                // THE ACCOUNT IS BORN HERE: the vault carries the Apple-held
                // copy under `setUpApple` — the key this device held on the
                // day sync was turned on.
                await made.setUp(passphrase: Self.passphrase)
                #expect(made.lastError == nil)
            }
            custody.set(SyncCustodyRecord(deviceID: deviceName, material: keyStore.load()))
            session = made
            store = keyStore
            // The production wire, verbatim from `wireOneSecretHooks`.
            controller.healAppleHeldCopy = { [made] apple in
                await made.relandAppleHeldCopy(under: apple)
            }
        }
        let landed = LockIsolated<[DeviceKeyMaterial]>([])
        controller.isSignedIn = { true }
        controller.foreignOwner = { _ in false }
        controller.landEnrollment = { material, _ in
            landed.withValue { $0.append(material) }
            return true
        }
        controller.readVaultPosture = { [client] in
            guard let fetched = try? await client.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID,
                passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true,
                corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt,
                updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-relink",
                hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
                format: fetched.format,
                recoveryWrapDigest: fetched.format.recoveryWrapDigest)
        }
        return Device(
            controller: controller, session: session, client: client, appleKeys: appleKeys,
            envelopeBox: envelopeBox, custody: custody, store: store, key: key, landed: landed)
    }

    /// The REAL tie `VaultTie.make` builds for an `.enrolled` account, over
    /// this world's client — the passphrase is checked by the true unwrap,
    /// never by a script.
    private func tie(for client: KeyVaultClient) -> VaultTie {
        VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { typed in
                let enrollment = VaultEnrollment(client: client)
                do {
                    _ = try await enrollment.enroll(passphrase: typed)
                    return .match
                } catch VaultEnrollmentError.wrongPassphrase {
                    return .mismatch("That isn't your account's encryption passphrase.")
                } catch {
                    return .couldNotCheck(EncryptionSession.message(for: error))
                }
            },
            verifyRecoveryWords: { _ in .match })
    }

    private func vaultRow(_ client: KeyVaultClient) async throws -> KeyVaultClient.FetchedVault {
        try #require(try await client.fetchVault())
    }

    // MARK: - (i) The orphaned copy, re-landed — and the nothing-typed enroll

    /// **PIN (i), the entry's own: the orphaned state → the door → a new
    /// device enrolls with nothing typed.**
    ///
    /// The world is MINOR-N1's exactly: sync was turned on while this Mac's
    /// iCloud Keychain held `A₁`, so the account's copy of the master is
    /// wrapped under `A₁`; then iCloud Keychain was RESET, this Mac minted
    /// `A′` for its OWN key file (F3's rule — a mint never heals the vault),
    /// and the account's copy was left orphaned under a key nobody reads.
    /// A new device on the same Apple account reads `A′`, finds the vault's
    /// copy under something else, and loses Standard's silent enroll.
    @Test func theOrphanedAppleHeldCopyIsReLandedAndANewDeviceThenEnrollsWithNothingTyped() async throws {
        let vault = RelinkVault()
        let a1 = AppleKey.mint()
        let aPrime = AppleKey.mint()
        // This Mac: it set the account up under A₁, and now reads A′.
        let mac = try await device(
            over: vault, appleKey: aPrime, deviceName: "this Mac",
            settingUpTheAccountUnder: a1)
        let master = try #require(mac.store?.load()).masterSymmetricKey
        let born = try await vaultRow(mac.client)
        #expect(born.format.appleKeyID == a1.id, "the account's copy is under A₁ — the day sync was turned on")
        #expect((try? born.format.unwrapMaster(withAppleKey: aPrime.symmetricKey)) == nil,
                "and A′ — all this Mac reads now — opens nothing of the account's")

        // A NEW device on the same Apple account, BEFORE the door.
        let fresh = try await device(
            over: vault, appleKey: aPrime, deviceName: "new Mac", storeID: "store-2",
            holdsKeys: false)
        await fresh.controller.reconcile()
        #expect(fresh.controller.enrollReading?.appleState == .differentAppleID,
                "the orphan, from the new device's side: the key it reads is not the account's")
        #expect(fresh.landed.value.isEmpty, "so nothing lands — Standard's nothing-typed enroll is gone")

        // THE DOOR.
        await mac.controller.reconcile()
        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        guard case .consent(let facts) = model.phase else {
            Issue.record("the door opened at \(model.phase) instead of its consent screen")
            return
        }
        #expect(facts.appleKeyID == aPrime.id, "the key this Mac's Apple account holds NOW")
        #expect(facts.recordedAppleKeyID == a1.id, "and the one on file, which it replaces")
        #expect(!facts.alreadyThisAccount)
        await model.confirm(passphrase: Self.passphrase)
        #expect(model.phase == .done, "\(model.phase) · \(model.lastError ?? "no error")")

        // ONE write, and what it wrote.
        let healed = try await vaultRow(mac.client)
        #expect(healed.revision == born.revision + 1, "ONE proof-authorized vault write")
        #expect(healed.format.appleKeyID == aPrime.id)
        #expect(try healed.format.unwrapMaster(withAppleKey: aPrime.symmetricKey) == master,
                "the account's copy now opens the master under the key this Apple account holds")
        #expect(healed.format.masterWrappedByRecovery != nil && healed.format.kdf == born.format.kdf,
                "the whole-row replace carried every other copy through untouched")

        // The new device, again — NOTHING TYPED.
        await fresh.controller.reconcile()
        let material = try #require(fresh.landed.value.first, "the silent Standard enroll ran")
        #expect(material.corpusKeyID == born.format.classKey(for: .corpus)?.keyID,
                "with the account's own keys")
        #expect(fresh.controller.enrollReading == nil, "no face is owed any more")
    }

    // MARK: - (ii) The consent sentence names THIS device's Apple account

    /// **PIN (ii), the entry's own.** The client stores no iCloud-account
    /// identity, so the sentence names the account the only way it honestly
    /// can — *the Apple account signed into this Mac*, with the key it hands
    /// back — and a device on a DIFFERENT Apple ID therefore names ITS
    /// account, never the one on file, which the second sentence names as
    /// what it replaces.
    @Test func aDifferentAppleAccountsDoorNamesTheKeyThisDeviceHoldsAndTheOneItReplaces() async throws {
        let vault = RelinkVault()
        let accounts = AppleKey.mint()   // the Apple account that set sync up
        let theirs = AppleKey.mint()     // this device's own Apple account
        let mac = try await device(
            over: vault, appleKey: theirs, deviceName: "other-ID Mac",
            settingUpTheAccountUnder: accounts)
        await mac.controller.reconcile()

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        let sentences = model.consentSentences
        #expect(sentences.count == 2)
        #expect(sentences[0] == ProtectionCopy.relinkConsent(appleKeyID: theirs.id))
        #expect(sentences[0].contains(ProtectionCopy.shortAppleKeyID(theirs.id)),
                "it names the key THIS device's Apple account holds")
        #expect(!sentences[0].contains(ProtectionCopy.shortAppleKeyID(accounts.id)),
                "never the account on file as the one that will hold it")
        #expect(sentences[1] == ProtectionCopy.relinkReplaces(recordedKeyID: accounts.id),
                "the second sentence names what stops working")
        #expect(model.phase != .done, "and nothing has been written by opening the door")
        #expect(try await vaultRow(mac.client).format.appleKeyID == accounts.id)
    }

    /// The same door where the key on file is ALREADY this Apple account's:
    /// it still acts (the write is the same key, re-landed) and says so
    /// rather than implying something changed.
    @Test func aDoorWhoseKeyIsAlreadyOnFileSaysSoAndStillActs() async throws {
        let vault = RelinkVault()
        let mine = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: mine, deviceName: "this Mac", settingUpTheAccountUnder: mine)
        await mac.controller.reconcile()
        let before = try await vaultRow(mac.client)

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        guard case .consent(let facts) = model.phase else {
            Issue.record("the door opened at \(model.phase)")
            return
        }
        #expect(facts.alreadyThisAccount)
        #expect(model.consentSentences.last == ProtectionCopy.relinkAlreadyThisAccount)
        await model.confirm(passphrase: Self.passphrase)
        #expect(model.phase == .done)
        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision + 1, "one write — the same key, re-landed")
        #expect(after.format.appleKeyID == mine.id)
    }

    // MARK: - (iii) The refusals, every one of them before or without a write

    /// **PIN (iii), the entry's own: `A` unreadable HERE ⇒ the waiting face's
    /// sentence, before any screen, with nothing written and nothing minted.**
    /// The last is the one that matters most: minting a key here would wrap
    /// the account's master under a key iCloud may never keep — MAJOR-3 (b)'s
    /// defect and decision 30's own prohibition.
    @Test func anUnreadableAppleKeyRefusesAtTheDoorBeforeAnyScreenAndWritesNothing() async throws {
        let vault = RelinkVault()
        let a1 = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: nil, bornUnder: a1, deviceName: "this Mac",
            settingUpTheAccountUnder: a1)
        let before = try await vaultRow(mac.client)

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        #expect(model.phase == .failed(ProtectionCopy.relinkAppleKeyUnreadable))
        #expect(ProtectionCopy.relinkAppleKeyUnreadable
                == ProtectionCopy.waitingTitle + " " + ProtectionCopy.waitingBody,
                "NIT-N8's waiting vocabulary, reused whole — never a sibling sentence")
        #expect(model.consentSentences.isEmpty, "refused BEFORE any screen")
        #expect(mac.appleKeys.key == nil, "and the door NEVER mints a key (decision 30 / MAJOR-3 b)")
        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision && after.format.appleKeyID == a1.id,
                "the vault's revision is exactly where it was")
    }

    /// The door's two other refusals, both before any screen: a follow owed
    /// (this device's keys are not the account's, so its proof would be
    /// refused anyway — §7's one sentence), and a CASTLE library, where no
    /// Apple-held copy is owed at all.
    @Test func aFollowOwedOrACastleLibraryRefusesAtTheDoorToo() async throws {
        let vault = RelinkVault()
        let mine = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: mine, deviceName: "this Mac", settingUpTheAccountUnder: mine)
        // A follow owed: the account's keys were rotated elsewhere, so this
        // device's custody names a corpus key the vault no longer carries.
        mac.custody.set(SyncCustodyRecord(deviceID: "this Mac", material: DeviceKeyMaterial(
            masterKey: Data(repeating: 9, count: 32),
            corpusKey: Data(repeating: 8, count: 32), corpusKeyID: "a-rotated-away-corpus",
            journalBridgeKey: Data(repeating: 7, count: 32), journalBridgeKeyID: "bridge")))
        await mac.controller.reconcile()
        #expect(mac.controller.followPending, "the world is the un-followed one")
        let before = try await vaultRow(mac.client)
        let owed = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await owed.start()
        #expect(owed.phase == .failed(ProtectionCopy.pickUpKeysFirst))
        #expect(owed.consentSentences.isEmpty)

        // Castle: the key file carries a passphrase wrap and no Apple copy.
        let castleKey = StoreKey.mint()
        var castleEnvelope = StoreKeyEnvelope(storeID: "store-castle")
        try castleEnvelope.setPassphraseWrap(key: castleKey, passphrase: "sesame", kdf: fastKDF())
        let backing = InMemoryStoreKeyGuardBacking(auto: nil, gated: castleKey)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(castleEnvelope), stamps: ScriptedStampsBox(),
            appleKey: InMemoryAppleKeyBacking(key: AppleKey.mint()))
        let castle = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            storeID: { "store-castle" }, syncCustodyLeaves: { _ in RelinkCustody().leaves },
            syncCustodySession: SyncCustodySession()))
        castle.adoptResident(castleKey)
        #expect(castle.posture == .castle)
        let inCastle = AppleRelinkModel(controller: castle, vaultTie: nil)
        await inCastle.start()
        #expect(inCastle.phase == .failed(
            PostureSwitchModel.message(for: PostureSwitchError.wrongPosture(.castle))))
        #expect(inCastle.consentSentences.isEmpty)

        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision, "neither refusal wrote a thing")
    }

    /// The KEY ACT: a wrong passphrase leaves the consent screen standing
    /// (she can type it again), speaks, and writes nothing.
    @Test func aWrongPassphraseSpeaksAndLeavesTheVaultExactlyAsItWas() async throws {
        let vault = RelinkVault()
        let a1 = AppleKey.mint()
        let aPrime = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: aPrime, deviceName: "this Mac", settingUpTheAccountUnder: a1)
        await mac.controller.reconcile()
        let before = try await vaultRow(mac.client)

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        await model.confirm(passphrase: "not-the-account's-word")
        #expect(model.lastError != nil, "it speaks")
        guard case .consent = model.phase else {
            Issue.record("a refused passphrase must leave the consent screen standing, not \(model.phase)")
            return
        }
        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision && after.format.appleKeyID == a1.id)

        // An empty field never even reaches the vault.
        await model.confirm(passphrase: "")
        #expect(model.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase))
        #expect(try await vaultRow(mac.client).revision == before.revision)
    }

    /// Consent was given for an ACCOUNT. A key that changes under the open
    /// sheet is not the key she agreed to, so the act refuses rather than
    /// writing the account's master under it.
    @Test func aKeyThatChangesUnderTheOpenSheetIsNotConsentedToAndNothingIsWritten() async throws {
        let vault = RelinkVault()
        let a1 = AppleKey.mint()
        let aPrime = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: aPrime, deviceName: "this Mac", settingUpTheAccountUnder: a1)
        await mac.controller.reconcile()
        let before = try await vaultRow(mac.client)

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        #expect(model.consentSentences.first == ProtectionCopy.relinkConsent(appleKeyID: aPrime.id))
        mac.appleKeys.key = AppleKey.mint()  // iCloud hands back another key
        await model.confirm(passphrase: Self.passphrase)
        #expect(model.phase == .failed(ProtectionCopy.relinkAppleKeyChanged))
        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision && after.format.appleKeyID == a1.id,
                "nothing written under a key the consent never named")
    }

    /// THE PROOF ROAD, proven by its refusal: the write is authorized by the
    /// master THIS device holds, so a device whose custody holds another
    /// master cannot land it — the server's own `VARIORUM_KEY_PROOF_REQUIRED`
    /// — and the door says nothing was changed, which is exactly true.
    @Test func aWriteTheServersProofRefusesLeavesTheVaultsRevisionWhereItWas() async throws {
        let vault = RelinkVault()
        let a1 = AppleKey.mint()
        let aPrime = AppleKey.mint()
        let mac = try await device(
            over: vault, appleKey: aPrime, deviceName: "this Mac", settingUpTheAccountUnder: a1)
        await mac.controller.reconcile()
        let before = try await vaultRow(mac.client)

        // A stranger's master in this device's own custody.
        let session = try #require(mac.session)
        let stranger = DeviceKeyMaterial(
            masterKey: Data(repeating: 3, count: 32),
            corpusKey: Data(repeating: 4, count: 32), corpusKeyID: "stranger-corpus",
            journalBridgeKey: Data(repeating: 5, count: 32), journalBridgeKeyID: "stranger-bridge")
        await session.adoptRekeyedMaterial(stranger)

        let model = AppleRelinkModel(controller: mac.controller, vaultTie: tie(for: mac.client))
        await model.start()
        await model.confirm(passphrase: Self.passphrase)
        #expect(model.phase == .failed(ProtectionCopy.relinkWriteRefused))
        let after = try await vaultRow(mac.client)
        #expect(after.revision == before.revision && after.format.appleKeyID == a1.id,
                "the server refused the proof; the account's copy is untouched")
    }
}
