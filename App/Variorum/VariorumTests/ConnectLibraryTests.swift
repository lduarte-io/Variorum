//
//  ConnectLibraryTests.swift
//  VariorumTests
//
//  pre-13x batch 3a — THE ADOPT ROAD (the postures design decision 17, §3.6,
//  §5's setup/enroll rows, corner 29/31; §12's "Setup adopts" + "re-enrollment
//  re-initializes"): a library that last synced under ANOTHER account is
//  CONNECTED to the signed-in one — the typed passphrase unwraps THIS
//  account's master, every owner-carrying row is re-stamped, sync is
//  re-initialized, and the WHOLE library uploads into the new account's
//  partition; a sibling under the new account pulls every take; zero
//  conflict variants; the old account's mirror untouched. Over the REAL
//  `AppServices.connectLibrary` on an in-memory library, two per-account
//  emulated mirrors that CHECK owner stamps (the 09 push guard's twin —
//  nil-owner worlds elsewhere are unchecked), two emulated vaults.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

struct FixedKeys: SyncKeyProviding {
    let keys: SyncEncryptionKeys
    let identity: String
    func currentKeys() throws -> SyncEncryptionKeys { keys }
    func deviceIdentity() throws -> String { identity }
}

actor QuietLifecycle: AccountLifecycleProviding {
    func truncateAccountData(activeKeyID: String, keyProof: KeyProofMaterial) async throws -> [String: Int] { [:] }
    func purgeAccount() async throws -> AccountPurgeReport {
        AccountPurgeReport(dataRows: 0, vaultRows: 0, entitlementRows: 0, authUserRemoved: true)
    }
    func fetchEntitlements() async throws -> [AccountEntitlement] { [] }
}

@MainActor
@Suite("pre-13x 3a — the adopt road: delete → recreate → Connect uploads the whole library under the new owner", .serialized)
struct ConnectLibraryTests {
    /// One ACCOUNT on the emulated server: its own partition (an
    /// owner-checking mirror), its own vault, its own session.
    @MainActor
    final class Account {
        let userID: String
        let mirror: EmulatedMirror
        let vaultEmu: EmulatedVault
        let client: KeyVaultClient
        let auth: AuthSession

        init(userID: String) async {
            self.userID = userID
            let mirror = EmulatedMirror(ownerID: userID)
            self.mirror = mirror
            let emu = EmulatedVault(claimRotationSeq: { await mirror.claimSeq() })
            self.vaultEmu = emu
            let auth = AuthSession(
                configuration: AuthConfiguration(
                    projectURL: URL(string: "https://auth.3a.invalid")!, apiKey: "publishable-test-key"),
                store: .inMemory(initial: AuthTokens(
                    accessToken: "token-\(userID)", refreshToken: "refresh-\(userID)",
                    expiresAt: Date(timeIntervalSinceNow: 86_400),
                    userID: userID, email: "\(userID)@test.invalid")),
                http: { _ in throw URLError(.notConnectedToInternet) })
            self.auth = auth
            self.client = KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.3a.invalid")!, apiKey: "publishable-test-key",
                    deviceName: "test device"),
                sessionProvider: auth,
                load: emu.load)
            await mirror.attach(vault: client)
        }
    }

    nonisolated private static let userX = "user-x-00000000-0000-4000-8000-0000000000aa"
    nonisolated private static let userY = "user-y-00000000-0000-4000-8000-0000000000bb"

    private func ownerRows(_ db: AppDatabase) async throws -> [String: [String?]] {
        try await db.read { d in
            var out: [String: [String?]] = [:]
            for table in SyncSchema.tables where table.plainColumns.contains("owner_id") {
                out[table.name] = try Row.fetchAll(d, sql: "SELECT owner_id FROM \(table.name) ORDER BY \(table.primaryKey)")
                    .map { $0["owner_id"] as String? }
            }
            return out
        }
    }

    private func syncedRowCount(_ db: AppDatabase) async throws -> Int {
        try await db.read { d in
            var total = 0
            for table in SyncSchema.tables {
                total += try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM \(table.name)") ?? 0
            }
            return total
        }
    }

    private func conflictVariants(_ db: AppDatabase) async throws -> Int {
        try await db.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM variant WHERE label = 'conflict'") ?? 0 }
    }

    private func titles(_ db: AppDatabase) async throws -> [String: String?] {
        try await db.read { d in
            try Row.fetchAll(d, sql: "SELECT id, title FROM container").reduce(into: [:]) { acc, row in
                acc[row["id"] as String] = row["title"] as String?
            }
        }
    }

    /// DELETE → RECREATE → CONNECT. X authored three notes and pushed them
    /// under X (its mirror checks X's stamp). X's account is gone. A NEW
    /// account Y set its vault up on another device. This library, signed
    /// in as Y, reads FOREIGN; a direct push of X-stamped rows into Y's
    /// partition is REFUSED (the owner guard — the re-stamp is load-bearing);
    /// a wrong word connects nothing; the right word: every owner-carrying
    /// row under Y, versions 0, the cursor from 0, every row enqueued,
    /// custody holding Y's keys; the drain uploads 100% under Y with CAS
    /// clean; a sibling under Y pulls every take; ZERO conflict variants on
    /// both; X's mirror untouched. RED ON OLD: `connectLibrary` did not
    /// exist (inherent), and — the mechanism revert — a re-stamp that
    /// rewrites nothing leaves every row X's, so Y's mirror refuses the
    /// upload at the first batch.
    @Test func deleteRecreateConnectUploadsEveryRowUnderTheNewOwnerAndASiblingConverges() async throws {
        let x = await Account(userID: Self.userX)
        let y = await Account(userID: Self.userY)
        let library = try AppDatabase.inMemory()

        // ————— X's era: three notes, stamped X, pushed under X's keys —————
        let xMaterial = try await VaultEnrollment(client: x.client).setUp(passphrase: "x-sesame-passphrase")
        try withDependencies {
            $0.database = library
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
            $0.ownerIdentity = OwnerIdentity { Self.userX }
        } operation: {
            let ops = Operations()
            for index in 0..<3 {
                let post = try ops.createPost(title: "X's note \(index)", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Written under X — note \(index).", at: .end)
            }
            let tag = try ops.createTag(parent: nil, name: "x-era")
            _ = tag
        }
        let xEngine = SyncEngine(transport: x.mirror, keyProvider: FixedKeys(keys: xMaterial.syncKeys, identity: "x-device"))
        try await withDependencies { $0.database = library } operation: {
            var rounds = 0
            while try await xEngine.outboxCount() > 0, rounds < 20 { _ = try await xEngine.push(); rounds += 1 }
            #expect(try await xEngine.outboxCount() == 0, "X's era drained to X's mirror")
            _ = try await xEngine.pull()
        }
        let rowsPushedUnderX = await x.mirror.stored().count
        let syncedRows = try await syncedRowCount(library)
        #expect(rowsPushedUnderX == syncedRows, "every synced row reached X's partition: \(rowsPushedUnderX) of \(syncedRows)")
        let ownersBefore = try await ownerRows(library)
        #expect(ownersBefore.values.flatMap { $0 }.allSatisfy { $0 == Self.userX })
        let titlesUnderX = try await titles(library)

        // ————— X deleted; Y's vault set up on ANOTHER device —————
        let yElsewhere = try await VaultEnrollment(client: y.client).setUp(passphrase: "y-sesame-passphrase")
        #expect(yElsewhere.corpusKeyID != xMaterial.corpusKeyID)

        // ————— This library, signed in as Y —————
        let keyStore = DeviceKeyStore.inMemory()
        try await withDependencies {
            $0.database = library
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_900_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
            $0.ownerIdentity = OwnerIdentity { Self.userY }
        } operation: { @MainActor in
            let encryption = EncryptionSession(store: keyStore, client: y.client, signedIn: { true })
            let services = AppServices(
                session: AppSession(database: library), storeVariant: .dev,
                backupEnabled: false,
                auth: y.auth, encryption: encryption,
                makeSyncTransport: { _ in y.mirror },
                makeSyncKeyProvider: { DeviceKeySyncProvider(store: keyStore) },
                keyVault: y.client,
                makeAccountLifecycle: { _ in QuietLifecycle() },
                legacyCleanup: {})
            let landings = LockIsolated<[VaultLanding]>([])
            encryption.onVaultMaterialLanded = { landing in landings.withValue { $0.append(landing) } }

            #expect(await services.libraryOwnerIsForeign(), "X's stamps make the library FOREIGN to Y")
            #expect(try await library.read { try Queries.foreignOwnerExists($0, signedIn: Self.userY) })

            // The owner guard: X-stamped rows cannot enter Y's partition —
            // the re-stamp is what makes the upload possible.
            let stray = try await library.read { d in
                try SyncRow.fetch(d, table: SyncSchema.table(named: "container")!, rowID: titlesUnderX.keys.sorted()[0])
            }
            let yKeysForProbe = FixedKeys(keys: yElsewhere.syncKeys, identity: "probe")
            // 13y UNIT B: a direct RPC call mints its per-request proof
            // through the mirror's `mintProof` road (the gate runs before
            // the owner check, so the probe must pass it to REACH the
            // refusal under test; enrolling Y's own material here is what
            // Y's first engine round would do anyway).
            let probeProof = try await y.mirror.mintProof(
                rpc: "sync_push", material: try yKeysForProbe.currentKeys().keyProof,
                activeKeyID: yElsewhere.corpusKeyID)
            await #expect(throws: EmulatedMirror.OwnerRefusal.self, "Y's mirror refuses a row stamped X") {
                _ = try await y.mirror.push([try #require(stray)], activeKeyID: yElsewhere.corpusKeyID,
                                            keyProof: probeProof)
            }

            // A wrong word connects nothing.
            await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
                try await services.connectLibrary(passphrase: "not-y's-passphrase", recoveryWords: nil)
            }
            #expect(try await ownerRows(library) == ownersBefore, "nothing re-stamped")
            #expect(keyStore.load() == nil, "no custody")
            #expect(landings.value.isEmpty)
            await #expect(throws: PostureSwitchError.secretRequired) {
                try await services.connectLibrary(passphrase: nil, recoveryWords: nil)
            }

            // THE CONNECT.
            try await services.connectLibrary(passphrase: "y-sesame-passphrase", recoveryWords: nil)
            let ownersAfter = try await ownerRows(library)
            #expect(ownersAfter.values.flatMap { $0 }.allSatisfy { $0 == Self.userY },
                    "every owner-carrying row re-stamped to Y: \(ownersAfter)")
            #expect(!(try await library.read { try Queries.foreignOwnerExists($0, signedIn: Self.userY) }), "the library reads as Y's")
            #expect(!(await services.libraryOwnerIsForeign()))
            let versions = try await library.read { d in
                try SyncSchema.tables.reduce(0) { acc, table in
                    acc + (try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM \(table.name) WHERE sync_version != 0") ?? 0)
                }
            }
            #expect(versions == 0, "sync_version → 0 everywhere (resyncReinitialize)")
            #expect(try await library.read { d in try String.fetchOne(d, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'") } == nil,
                    "the cursor cleared — Y's partition is read from 0")
            #expect(try await library.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM sync_row_seq") } == 0)
            #expect(try await library.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM sync_outbox") } == syncedRows,
                    "every row enqueued")
            let held = try #require(keyStore.load())
            #expect(held.corpusKeyID == yElsewhere.corpusKeyID && held.masterKey == yElsewhere.masterKey, "custody holds Y's keys")
            #expect(landings.value.count == 1 && landings.value.first?.passphrase == "y-sesame-passphrase",
                    "the key file's landing fired once with the typed passphrase")
            #expect(encryption.state == .enrolled(hasRecoveryWrap: false))

            // THE UPLOAD: the whole library into Y's partition, CAS clean.
            let yEngine = SyncEngine(transport: y.mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
            var rounds = 0
            var accepted = 0, rejected = 0
            while try await yEngine.outboxCount() > 0, rounds < 20 {
                let report = try await yEngine.push()
                accepted += report.accepted; rejected += report.rejected
                rounds += 1
            }
            #expect(try await yEngine.outboxCount() == 0)
            #expect(accepted == syncedRows && rejected == 0, "100% accepted under Y with CAS clean: accepted \(accepted), rejected \(rejected)")
            // The pull from 0 re-reads Y's partition — this device's own
            // uploads, applied back VERBATIM (the engine's clean-row path;
            // the designed once-per-account re-download, the drills'
            // "applied 7656" shape) — with nothing merged, repaired or
            // minted.
            let pulled = try await yEngine.pull()
            #expect(pulled.applied == syncedRows && pulled.merged == 0 && pulled.repairs == 0 && !pulled.stalled,
                    "the pull from 0 re-applies its own rows verbatim: applied \(pulled.applied) merged \(pulled.merged) repairs \(pulled.repairs) stalled \(pulled.stalled) cursor \(pulled.newCursor)")
            #expect(try await titles(library) == titlesUnderX, "the re-download changed nothing")
            #expect(try await conflictVariants(library) == 0, "zero conflict variants")
            let stored = await y.mirror.stored()
            #expect(stored.count == syncedRows, "Y's partition holds every row: \(stored.count) of \(syncedRows)")
            for (key, entry) in stored where SyncSchema.table(named: entry.row.table)?.plainColumns.contains("owner_id") == true {
                #expect(entry.row.columns["owner_id"] == .text(Self.userY), "\(key) is stamped Y on the mirror")
            }
            #expect(await x.mirror.stored().count == rowsPushedUnderX, "X's partition untouched")
            services.stop()
        }

        // ————— A SIBLING under Y pulls every take —————
        let sibling = try AppDatabase.inMemory()
        let siblingEngine = SyncEngine(transport: y.mirror, keyProvider: FixedKeys(keys: yElsewhere.syncKeys, identity: "y-sibling"))
        try await withDependencies { $0.database = sibling } operation: {
            let report = try await siblingEngine.pull()
            #expect(report.applied + report.merged >= 3, "the sibling applied the notes: \(report.applied) applied, \(report.merged) merged")
        }
        #expect(try await titles(sibling) == titlesUnderX, "every note in the clear under Y — the same titles X wrote")
        #expect(try await conflictVariants(sibling) == 0)
        let siblingVariants = try await sibling.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0 }
        let libraryVariants = try await library.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0 }
        #expect(siblingVariants == libraryVariants && libraryVariants == 3, "every take arrived: \(siblingVariants) of \(libraryVariants)")
    }
}
