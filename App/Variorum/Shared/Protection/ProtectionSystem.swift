//
//  ProtectionSystem.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE COMPOSITION ROOT for the protection core on one slot (`notes/plans/vx-306-castle-open-
//  road.md` §2 U1a): the thirteen production leaves for a scope + slot + far folder, the
//  `ExecutorConfiguration` (the scope = the store variant's raw value; the library ID from the live key file,
//  else "" until unlock names it; the device name; the real `PassphraseKDF.floor`; the session), the executor,
//  and the facts gatherer.
//
//  `deviceName` defaults to `DeviceName.current`, which on the PHONE reads `UIDevice` under
//  `MainActor.assumeIsolated` — so the phone composes this on the main actor, or passes the name (U3).
//
//  VX-329 U3 — VX-423: the vault leaf rides the session the system is HANDED — production's is the process's one refresh
//  authority (`AppBootstrap.auth` → `RoadInputs.live` → `live(variant:session:)`), never a session of the system's own
//  (each composed system used to mint one over the scope's stored session, refreshing the rotating token beside the
//  services'). A system composed without it (a test world) rides no one's sign-in (`NobodySignedIn`).
//
//  The TYPES compile in both configurations (rule 24); their USE is U1b's Debug gate — nothing in
//  `AppBootstrap` calls this yet. Tests compose it over a throwaway scope and a temp slot, overriding the
//  leaves that must not reach iCloud.
//

import Foundation
import VariorumCore

nonisolated final class ProtectionSystem: @unchecked Sendable {
    let scope: String
    let places: ProtectionPlaces
    let deviceName: String
    let floor: PassphraseKDF.Floor
    let leaves: ExecutorLeaves
    let lister: CatalogLister
    /// The concrete leaves a face reads beside the protocols (the last Touch ID press, the copy pause, the
    /// typed diagnostics).
    let custody: any CustodyLeaf
    let backups: FileBackupsLeaf
    let diagnostics: AppDiagnosticsLeaf

    init(
        scope: String, places: ProtectionPlaces, deviceName: String = DeviceName.current,
        floor: PassphraseKDF.Floor = PassphraseKDF.floor,
        custody: (any CustodyLeaf)? = nil, syncKeys: (any SyncKeysLeaf)? = nil, apple: (any AppleKeysLeaf)? = nil,
        session: any UserSessionProviding = NobodySignedIn(), vault: (any VaultLeaf)? = nil,
        memory: (any MemoryStoreLeaf)? = nil, biometry: (any BiometryLeaf)? = nil, clock: (any ClockLeaf)? = nil,
        ids: (any IDsLeaf)? = nil
    ) {
        self.scope = scope
        self.places = places
        self.deviceName = deviceName
        self.floor = floor
        let biometry = biometry ?? LAEnvironmentBiometryLeaf()
        let memory = memory ?? KeychainMemoryLeaf(scope: scope)
        let custody = custody ?? KeychainCustodyLeaf(
            scope: scope, biometry: biometry, touchIDCandidates: Self.touchIDCandidates(places: places, memory: memory))
        let backups = FileBackupsLeaf(places: places)
        let diagnostics = AppDiagnosticsLeaf()
        self.custody = custody
        self.backups = backups
        self.diagnostics = diagnostics
        lister = CatalogLister(places: places)
        leaves = ExecutorLeaves(
            custody: custody, syncKeys: syncKeys ?? KeychainSyncKeysLeaf(scope: scope),
            apple: apple ?? ICloudAppleKeysLeaf(scope: scope),
            // VX-307 U1: the production wire leaf (the marker-14 shape) when
            // the project is configured; else the vault stays unreachable and
            // an act that needs it rolls back, exactly as before. Tests
            // inject their own. VX-423: served by the session handed in.
            vault: vault ?? WireVaultLeaf.live(deviceName: deviceName, session: session) ?? UnreachableVaultLeaf(),
            library: SQLCipherLibraryLeaf(places: places), keyFiles: FileKeyFileStoreLeaf(places: places),
            memory: memory, plans: FilePlanStoreLeaf(places: places),
            backups: backups, clock: clock ?? SystemClockLeaf(), ids: ids ?? SystemIDsLeaf(), biometry: biometry,
            diagnostics: diagnostics)
    }

    /// THE FINGERPRINTS THIS DEVICE KNOWS OF — whose Touch ID item the custody listing probes for by name
    /// (P-VX306-U1a-5): every catalogued key file's keys (the live one, the backups', Previous Libraries'),
    /// what each memory item names (its current key and its mirror's keys — read as stated, unverified: a
    /// key file holds no secret), the plan's two keys, and the staged key. Reads only.
    static func touchIDCandidates(places: ProtectionPlaces, memory: any MemoryStoreLeaf) -> @Sendable () -> Set<String> {
        let lister = CatalogLister(places: places)
        let library = SQLCipherLibraryLeaf(places: places)
        let plans = FilePlanStoreLeaf(places: places)
        nonisolated(unsafe) let memory = memory
        return {
            var known = Set(lister.catalog().keyFiles.flatMap(\.heldFingerprints))
            for libraryID in (try? memory.rememberedLibraryIDs()) ?? [] {
                guard let sealed = try? memory.readMemory(libraryID: libraryID),
                      let named = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload)
                else { continue }
                known.insert(named.currentFingerprint)
                known.formUnion(named.keyFileMirror?.heldFingerprints ?? [])
            }
            if let sealed = (try? plans.readPlan()) ?? nil,
               let plan = try? ProtectionCoding.decoder().decode(ProtectionPlan.self, from: sealed.payload) {
                known.formUnion([plan.fromFingerprint, plan.toFingerprint].compactMap { $0 })
            }
            if let staged = (try? library.stagedFingerprint()) ?? nil { known.insert(staged) }
            return known
        }
    }

    /// The store variant's protection system: its slot (`AppDatabase.defaultStoreURL`), and today's picked
    /// backup destination as the far folder (resolved security-scoped at each use). `session` — REQUIRED — is the
    /// process's one refresh authority the vault leaf rides (VX-423; the bootstrap's).
    static func live(variant: AppDatabase.StoreVariant, session: any UserSessionProviding) throws -> ProtectionSystem {
        let slot = try AppDatabase.defaultStoreURL(variant: variant)
        let places = ProtectionPlaces(slot: slot, farFolder: {
            BackupDestination.resolve().map { ProtectionFarFolder(picked: $0.picked, scoped: true) }
        })
        return ProtectionSystem(scope: variant.rawValue, places: places, session: session)
    }

    /// The executor's configuration now: the library ID the live key file names (else "" — unlock names it).
    func configuration(session: SessionFact) -> ExecutorConfiguration {
        let libraryID = ((try? leaves.keyFiles.readLiveKeyFile()) ?? nil)?.libraryID ?? ""
        return ExecutorConfiguration(
            scope: scope, libraryID: libraryID, deviceName: deviceName, floor: floor, session: session)
    }

    func executor(session: SessionFact, guards: ProtectionGuards = .all) -> ProtectionExecutor {
        ProtectionExecutor(leaves: leaves, configuration: configuration(session: session), guards: guards)
    }

    var gatherer: ProtectionFactsGatherer {
        ProtectionFactsGatherer(scope: scope, places: places, leaves: leaves, lister: lister)
    }

    /// What `assess` reads now (before unlock: `unlocked` nil). The last Touch ID press is the custody
    /// leaf's own unless the caller says otherwise.
    func facts(session: SessionFact, unlocked: UnlockedLibrary? = nil, touchIDPress: TouchIDPress? = nil) throws -> ProtectionFacts {
        let press = touchIDPress ?? (custody as? KeychainCustodyLeaf)?.lastPress
        return try gatherer.facts(session: session, unlocked: unlocked, touchIDPress: press)
    }
}
