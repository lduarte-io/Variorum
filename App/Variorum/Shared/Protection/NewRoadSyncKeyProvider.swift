//
//  NewRoadSyncKeyProvider.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-307 U1 — THE ENGINE'S KEY SEAM ON THE NEW ROAD (the plan §5a piece 4; P-VX306-K3's two-systems
//  coexistence ends here): on the new road the sync engine reads the account's keys from the protection
//  core's custody — `KeychainSyncKeysLeaf` (rule 15: the master, the current sync key and every earlier
//  one, held by the account's mode) — never today's `SyncCustodyRecord`. Today's road keeps
//  `DeviceKeySyncProvider`, byte-unchanged (the composition site switches on `AppBootstrap.newRoad`).
//
//  The provider is attached to the road session at each ready (the `ProtectionBackupHook` shape). With no
//  session, no bound account, or no readable keys it throws — the engine refuses the round visibly, outbox
//  intact, cursor unmoved (SyncSpec §3's refusal grammar). It reads SESSION MEMORY first, then the SILENT
//  item; it NEVER reads the Touch ID item (a press per round is nobody's wish — under Always-ask Castle,
//  rounds run while an act or unlock has loaded session memory; P-VX307-U1-3). The device identity is the
//  record's own (rule 23), read from the attached session.
//
//  Honest limit this phase: the new road reaches only the dev store, whose `SyncSession` never configures
//  (`allowsSync` is the real store's alone) — so this provider is structural, proven by its suite, and
//  dormant live until VX-329.
//

import CryptoKit
import Foundation
import VariorumCore

nonisolated final class NewRoadSyncKeyProvider: SyncKeyProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var session: ProtectionRoadSession?

    init() {}

    /// The road session of the current open (nil detaches — today's road, or none yet).
    func attach(_ session: ProtectionRoadSession?) {
        lock.withLock { self.session = session }
    }

    private var current: ProtectionRoadSession? { lock.withLock { session } }

    func currentKeys() throws -> SyncEncryptionKeys {
        guard let session = current, session.writes,
              let account = session.library.record?.account
        else { throw SyncKeyProviderError.notEnrolled }
        let leaf = session.system.leaves.syncKeys
        guard let keys = leaf.sessionSyncKeys(accountID: account)
            ?? (try? leaf.readSyncKeys(accountID: account, itemClass: .silent)) ?? nil
        else { throw SyncKeyProviderError.notEnrolled }
        return SyncEncryptionKeys(
            corpusKey: SymmetricKey(data: keys.rowKey),
            corpusKeyID: keys.rowKeyID,
            keyProof: KeyProofMaterial(master: keys.masterKey),
            rotation: nil,
            earlierKeys: keys.earlierRowKeys.mapValues { SymmetricKey(data: $0) })
    }

    func deviceIdentity() throws -> String {
        guard let session = current, session.writes else { throw SyncKeyProviderError.notEnrolled }
        return session.library.section.deviceID
    }
}
