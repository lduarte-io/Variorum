//
//  AssessFixtures.swift
//  VariorumCoreTests — VX-305 U2: one library on this Mac, unlocked (or
//  not), as `assess` reads it — every fact a plain value the test sets.
//

import CryptoKit
import Foundation

@testable import VariorumCore

struct AWorld {
    static let scope = "Variorum-test"
    static let now = CF.stamp(10)
    static let liveKeyFileID = Catalog.id(place: .container, folders: [], name: ProtectionNames.keyFilename)

    let world: KeyWorld
    var key: StoreKey
    var mode: ProtectionMode
    var account: String?
    var session: SessionFact = .signedOut
    var vault: VaultReading?
    var liveFile: KeyFile
    var extraEntries: [CatalogEntry] = []
    var custody: [CustodyItemFact]
    var syncKeys: [SyncKeysItemFact] = []
    var appleKeys: AppleKeyFacts
    var biometry = BiometryFacts.ready
    var press: TouchIDPress?
    var section: DeviceSection
    var memory: DeviceMemory?
    var memoryAbsent = false
    var recordSection: DeviceSection?
    var tree: FamilyTree
    var unlocked = true
    var libraryAccountEmail: String?
    let own = AppleKeyMaterial.mint()

    /// A library in `mode`: Castle — passphrase and words, a Touch ID item,
    /// Touch ID chosen; Standard — passphrase, words and this Mac's own Apple
    /// key (readable), a silent item.
    init(_ mode: ProtectionMode, account: String? = nil, history: [StoreKey] = []) throws {
        world = try KeyWorld()
        self.mode = mode
        self.account = account
        let current = StoreKey.mint()
        key = current
        var locks = NewKeyLocks(passphrase: world.p, words: world.w)
        if mode == .standard { locks.apple = own }
        var file = try KeyFile.building(libraryID: world.library, key: current, epoch: history.count + 1, locks: locks)
        file.history = try history.enumerated().map { index, old in
            HistoryEntry(fingerprint: PF.fp(old), epoch: index + 1, retiredAt: PF.t0,
                         wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: old.data), using: SymmetricKey(data: current.data)))
        }
        liveFile = file
        custody = [CustodyItemFact(fingerprint: PF.fp(current), itemClass: mode == .castle ? .touchid : .silent)]
        appleKeys = AppleKeyFacts(readable: mode == .standard ? [own.id] : [])
        section = DeviceSection(
            deviceID: CF.macA, hardwareMarker: .stub("marker"), settings: DeviceSettings(gateStyle: mode == .castle ? .touchID : nil),
            appleKeys: mode == .standard ? [AppleKeyRecord(id: own.id, purpose: .library, origin: .minted)] : [])
        tree = FamilyTree(entries: ([current] + history).map { FamilyTree.Entry(fingerprint: PF.fp($0), kind: mode) })
        recordSection = section
    }

    var record: ProtectionRecord {
        var record = ProtectionRecord.minting(
            libraryID: world.library, mode: mode, account: account,
            currentFingerprint: PF.fp(key), madeBy: CF.macA, at: PF.t0)
        record.familyTree = tree
        return record
    }

    /// What this Mac remembers, agreeing with the record (unless set).
    var agreeingMemory: DeviceMemory {
        DeviceMemory(
            libraryID: world.library, scope: Self.scope, currentFingerprint: PF.fp(key), keyEpoch: record.keyEpoch,
            lastConfirmed: ConfirmedFacts(mode: mode, account: account),
            familyTree: tree, deviceSection: section)
    }

    func entries() throws -> [CatalogEntry] {
        [CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try liveFile.encoded())] + extraEntries
    }

    func facts() throws -> ProtectionFacts {
        let unlockedFacts = unlocked ? UnlockedFacts(
            record: record, familyTree: tree, thisMac: section,
            identity: .continuing(deviceID: section.deviceID), memory: memoryAbsent ? nil : (memory ?? agreeingMemory),
            currentFingerprint: PF.fp(key), liveKeyFileID: Self.liveKeyFileID, recordSection: recordSection) : nil
        return ProtectionFacts(
            scope: Self.scope, unlocked: unlockedFacts, slotFingerprintHint: PF.fp(key),
            rememberedModeHint: unlocked ? nil : mode, libraryAccountEmail: libraryAccountEmail,
            custody: custody, syncKeys: syncKeys, appleKeys: appleKeys, biometry: biometry,
            touchIDPress: press, session: session, vault: vault, catalog: Catalog.build(try entries()), now: Self.now)
    }

    func assessed(guards: ProtectionGuards = .all) throws -> Assessment { assess(try facts(), guards: guards) }

    /// The account's vault as read this session.
    static func vault(_ account: String, _ mode: VaultMode, previous: String? = nil, corpus: String = "c1",
                      device: String? = "Lillian's Air", day: Date? = CF.stamp(9)) -> VaultReading {
        switch mode {
        case .standard(let id):
            return VaultReading(accountID: account, hasAppleWrap: true, appleKeyID: id, previousCorpusKeyID: previous,
                                corpusKeyID: corpus, updatedByDevice: device, updatedAt: day)
        case .leavingCastle(let id):
            return VaultReading(accountID: account, hasAppleWrap: false, appleKeyID: id, previousCorpusKeyID: previous,
                                corpusKeyID: corpus, updatedByDevice: device, updatedAt: day)
        case .castle:
            return VaultReading(accountID: account, hasAppleWrap: false, previousCorpusKeyID: previous,
                                corpusKeyID: corpus, updatedByDevice: device, updatedAt: day)
        }
    }
}

extension Assessment {
    func door(_ door: Door) -> DoorState { doors[door] ?? .refused(.nothingToDo) }
}
