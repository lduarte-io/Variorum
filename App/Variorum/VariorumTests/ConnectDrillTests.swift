//
//  ConnectDrillTests.swift
//  VariorumTests
//
//  pre-13x batch 3a — THE ADOPT DRILL (the batch gate's third drill; the
//  postures design decision 17, §12's "Setup adopts"): delete → recreate →
//  Connect over the WHOLE SAMPLE LIBRARY (the Sherlock corpus seeded into a
//  scratch KEYED store, thousands of rows pushed under the OLD account's keys
//  into its owner-checking partition) — signed in as the NEW account, the
//  REAL `AppServices.connectLibrary` re-stamps every owner-carrying row,
//  re-initializes sync, and the drain uploads 100% into the new partition
//  with CAS clean and ZERO conflict variants; a sibling under the new account
//  pulls every take; the old partition is untouched. The pin
//  (`ConnectLibraryTests`) proves the mechanism on three notes; this drill
//  runs it at corpus scale and records the wall times.
//
//  OPT-IN — DISABLED unless VARIORUM_CONNECT_DRILL=1 (it seeds the whole
//  corpus; run deliberately):
//      TEST_RUNNER_VARIORUM_CONNECT_DRILL=1 xcodebuild test … \
//          -only-testing:VariorumTests/ConnectDrillTests
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

nonisolated enum ConnectDrill {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_CONNECT_DRILL"] == "1"
    }
}

@MainActor
@Suite(
    "pre-13x 3a — THE ADOPT DRILL: delete → recreate → Connect over the sample library (opt-in; DISABLED unless VARIORUM_CONNECT_DRILL=1)",
    .serialized,
    .enabled(
        if: ConnectDrill.requested,
        "seeds the whole sample library into a scratch keyed store — run deliberately with TEST_RUNNER_VARIORUM_CONNECT_DRILL=1"))
struct ConnectDrillTests {
    nonisolated private static let userX = "user-x-drill-0000-4000-8000-0000000000aa"
    nonisolated private static let userY = "user-y-drill-0000-4000-8000-0000000000bb"

    private func ownerStamps(_ db: AppDatabase) async throws -> Set<String?> {
        try await db.read { d in
            var out = Set<String?>()
            for table in SyncSchema.tables where table.plainColumns.contains("owner_id") {
                for row in try Row.fetchAll(d, sql: "SELECT DISTINCT owner_id FROM \(table.name)") {
                    out.insert(row["owner_id"] as String?)
                }
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

    private func liveVariants(_ db: AppDatabase) async throws -> Int {
        try await db.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0 }
    }

    private func conflictVariants(_ db: AppDatabase) async throws -> Int {
        try await db.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM variant WHERE label = 'conflict'") ?? 0 }
    }

    @Test func theWholeSampleLibraryUploadsUnderTheNewOwnerAndASiblingPullsEveryTake() async throws {
        let x = await ConnectLibraryTests.Account(userID: Self.userX)
        let y = await ConnectLibraryTests.Account(userID: Self.userY)
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-3a-connect-drill-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let library = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: .mint()))
        let clock = ContinuousClock()
        func note(_ line: String) { print("drill 3a CONNECT: \(line)") }

        // ————— X's era: the vault, the sample library seeded under X, pushed under X's keys —————
        let xMaterial = try await VaultEnrollment(client: x.client).setUp(passphrase: "x-sesame-passphrase")
        let seedTime = try await clock.measure {
            try await withDependencies {
                $0.database = library
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
                $0.ownerIdentity = OwnerIdentity { Self.userX }
            } operation: { @MainActor in
                let appSession = AppSession(database: library)
                let stories = try SampleLibrarySeeder.loadStories()
                let result = try await SampleLibrarySeeder.seed(
                    session: appSession, stories: stories, existing: SampleLibrarySeeder.Existing())
                #expect(result.minted > 0, "the sample library seeded: \(result)")
            }
        }
        let variantCount = try await liveVariants(library)
        let syncedRows = try await syncedRowCount(library)
        let sample = try await library.read { db in
            try Row.fetchOne(db, sql: "SELECT id, working_text FROM variant WHERE length(working_text) > 200 ORDER BY id LIMIT 1")
                .map { (id: $0["id"] as String, text: $0["working_text"] as String) }
        }
        let xEngine = SyncEngine(transport: x.mirror, keyProvider: FixedKeys(keys: xMaterial.syncKeys, identity: "x-device"))
        let xPushTime = try await clock.measure {
            try await withDependencies {
                $0.database = library
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
            } operation: {
                var rounds = 0
                while try await xEngine.outboxCount() > 0, rounds < 400 { _ = try await xEngine.push(); rounds += 1 }
                #expect(try await xEngine.outboxCount() == 0, "X's era drained to X's partition")
                _ = try await xEngine.pull()
            }
        }
        let rowsUnderX = await x.mirror.stored().count
        #expect(rowsUnderX == syncedRows, "every synced row reached X's partition: \(rowsUnderX) of \(syncedRows)")
        #expect(try await ownerStamps(library) == [Self.userX], "every owner-carrying row stamped X")
        note("seeded the sample library in \(seedTime) — \(variantCount) live takes, \(syncedRows) synced rows; pushed \(rowsUnderX) rows under X in \(xPushTime)")

        // ————— X deleted; Y's vault set up on ANOTHER device —————
        let yElsewhere = try await VaultEnrollment(client: y.client).setUp(passphrase: "y-sesame-passphrase")
        #expect(yElsewhere.corpusKeyID != xMaterial.corpusKeyID)

        // ————— This library, signed in as Y: CONNECT through the real services, then the drain —————
        let keyStore = DeviceKeyStore.inMemory()
        var connectWall: Duration = .zero
        var drainWall: Duration = .zero
        var accepted = 0, rejected = 0
        try await withDependencies {
            $0.database = library
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
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
            #expect(await services.libraryOwnerIsForeign(), "X's stamps make the library FOREIGN to Y")
            await #expect(throws: VaultEnrollmentError.wrongPassphrase, "a wrong word connects nothing") {
                try await services.connectLibrary(passphrase: "not-y's-passphrase", recoveryWords: nil)
            }
            #expect(try await ownerStamps(library) == [Self.userX] && keyStore.load() == nil, "nothing re-stamped, no custody")

            connectWall = try await clock.measure {
                try await services.connectLibrary(passphrase: "y-sesame-passphrase", recoveryWords: nil)
            }
            #expect(try await ownerStamps(library) == [Self.userY], "every owner-carrying row re-stamped to Y")
            #expect(!(await services.libraryOwnerIsForeign()))
            #expect(try await library.read { d in try Int.fetchOne(d, sql: "SELECT COUNT(*) FROM sync_outbox") } == syncedRows, "every row enqueued")
            #expect(try await library.read { d in try String.fetchOne(d, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'") } == nil, "the cursor cleared")
            let held = try #require(keyStore.load())
            #expect(held.corpusKeyID == yElsewhere.corpusKeyID && held.masterKey == yElsewhere.masterKey, "custody holds Y's keys")

            let yEngine = SyncEngine(transport: y.mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
            drainWall = try await clock.measure {
                var rounds = 0
                while try await yEngine.outboxCount() > 0, rounds < 400 {
                    let report = try await yEngine.push()
                    accepted += report.accepted; rejected += report.rejected
                    rounds += 1
                }
            }
            #expect(try await yEngine.outboxCount() == 0, "the drain emptied the outbox")
            #expect(accepted == syncedRows && rejected == 0, "100% accepted under Y with CAS clean: accepted \(accepted), rejected \(rejected)")
            let pulled = try await yEngine.pull()
            #expect(pulled.applied == syncedRows && pulled.merged == 0 && pulled.repairs == 0 && !pulled.stalled,
                    "the pull from 0 re-applies its own rows verbatim: applied \(pulled.applied) merged \(pulled.merged) repairs \(pulled.repairs)")
            #expect(try await conflictVariants(library) == 0, "zero conflict variants on the connected library")
            let stillHere = try await liveVariants(library)
            #expect(stillHere == variantCount, "every take still here: \(stillHere) of \(variantCount)")
        }
        let rowsUnderY = await y.mirror.stored().count
        #expect(rowsUnderY == syncedRows, "Y's partition holds the whole library: \(rowsUnderY) of \(syncedRows)")
        #expect(await x.mirror.stored().count == rowsUnderX, "X's partition untouched")

        // ————— A SIBLING under Y pulls every take —————
        let sibling = try AppDatabase.inMemory()
        let siblingEngine = SyncEngine(transport: y.mirror, keyProvider: FixedKeys(keys: yElsewhere.syncKeys, identity: "y-sibling"))
        var siblingApplied = 0, siblingMerged = 0
        let siblingWall = try await clock.measure {
            try await withDependencies {
                $0.database = sibling
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
            } operation: {
                let report = try await siblingEngine.pull()
                siblingApplied = report.applied; siblingMerged = report.merged
            }
        }
        #expect(siblingApplied + siblingMerged == syncedRows, "the sibling under Y applies every row: applied \(siblingApplied), merged \(siblingMerged)")
        let siblingVariants = try await liveVariants(sibling)
        #expect(siblingVariants == variantCount, "every take arrived on the sibling: \(siblingVariants) of \(variantCount)")
        #expect(try await conflictVariants(sibling) == 0, "zero conflict variants on the sibling")
        if let sample {
            let text = try await sibling.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [sample.id])
            }
            #expect(text == sample.text, "a sampled take reads back byte-for-byte on the sibling under Y's keys")
        }
        note("CONNECT in \(connectWall) (re-stamped to Y, sync re-initialized, \(syncedRows) rows enqueued); drained \(accepted) rows under Y (rejected \(rejected)) in \(drainWall); the pull from 0 re-applied its own rows; the sibling pulled applied \(siblingApplied), merged \(siblingMerged) in \(siblingWall) — \(siblingVariants) of \(variantCount) takes; conflicts 0/0; X's partition untouched at \(rowsUnderX)")
    }
}
