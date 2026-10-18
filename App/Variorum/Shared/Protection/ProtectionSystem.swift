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
        memory: (any MemoryStoreLeaf)? = nil, biometry: (any BiometryLeaf)? = nil, clock: (any ClockLeaf)? = nil,
        ids: (any IDsLeaf)? = nil
    ) {
        self.scope = scope
        self.places = places
        self.deviceName = deviceName
        self.floor = floor
        let biometry = biometry ?? LAEnvironmentBiometryLeaf()
        let custody = custody ?? KeychainCustodyLeaf(scope: scope, biometry: biometry)
        let backups = FileBackupsLeaf(places: places)
        let diagnostics = AppDiagnosticsLeaf()
        self.custody = custody
        self.backups = backups
        self.diagnostics = diagnostics
        lister = CatalogLister(places: places)
        leaves = ExecutorLeaves(
            custody: custody, syncKeys: syncKeys ?? KeychainSyncKeysLeaf(scope: scope),
            apple: apple ?? ICloudAppleKeysLeaf(scope: scope), vault: UnreachableVaultLeaf(),
            library: SQLCipherLibraryLeaf(places: places), keyFiles: FileKeyFileStoreLeaf(places: places),
            memory: memory ?? KeychainMemoryLeaf(scope: scope), plans: FilePlanStoreLeaf(places: places),
            backups: backups, clock: clock ?? SystemClockLeaf(), ids: ids ?? SystemIDsLeaf(), biometry: biometry,
            diagnostics: diagnostics)
    }

    /// The store variant's protection system: its slot (`AppDatabase.defaultStoreURL`), and today's picked
    /// backup destination as the far folder (resolved security-scoped at each use).
    static func live(variant: AppDatabase.StoreVariant) throws -> ProtectionSystem {
        let slot = try AppDatabase.defaultStoreURL(variant: variant)
        let places = ProtectionPlaces(slot: slot, farFolder: {
            BackupDestination.resolve().map { ProtectionFarFolder(picked: $0.picked, scoped: true) }
        })
        return ProtectionSystem(scope: variant.rawValue, places: places)
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
