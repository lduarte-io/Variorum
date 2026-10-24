//
//  NewRoadSyncKeyProvider.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-307 U1 — THE ENGINE'S KEY SEAM ON THE NEW ROAD (the plan §5a piece 4; P-VX306-K3's two-systems
//  coexistence ends here): on the new road the sync engine reads the account's keys from the protection
//  core's custody — `KeychainSyncKeysLeaf` (rule 15: the master, the current sync key and every earlier
//  one, held by the account's mode) — never today's `SyncCustodyRecord`. VX-329 U1: the ONE provider — today's
//  `DeviceKeySyncProvider` and the composition's road fork left with today's road.
//
//  The provider is attached to the road session at each ready (the `ProtectionBackupHook` shape). With no
//  session, no bound account, or no readable keys it throws — the engine refuses the round visibly, outbox
//  intact, cursor unmoved (SyncSpec §3's refusal grammar). It reads SESSION MEMORY first, then the SILENT
//  item; it NEVER reads the Touch ID item (a press per round is nobody's wish — under Always-ask Castle,
//  rounds run while an act or unlock has loaded session memory; P-VX307-U1-3). The device identity is the
//  record's own (rule 23), read from the attached session. VX-487: that design is BUILT now on both sides — a Castle act
//  with Touch ID holds the keys in session beside the item (`CommonSteps.holdSyncKeys`), and the Touch ID unlock loads
//  them in the same press (`ProtectionOpenRoad.loadSyncKeysForTheSession`); before it, Castle + Touch ID never synced.
//  VX-501 (VX-510 D-B4): and a TYPED Castle unlock loads them from the vault with the secret just typed
//  (`ProtectionOpenRoad.loadSyncKeysAfterTypedUnlock`); before it, Always-ask Castle never synced after a lock.
//
//  VX-329 U1 — THE RELEASE SWITCH: the road reaches every store now, so this provider is the engine's live key seam
//  (it was structural and dormant while the new road reached only the dev store, whose `SyncSession` never configures).
//

import CryptoKit
import Foundation
import VariorumCore

nonisolated final class NewRoadSyncKeyProvider: SyncKeyProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var session: ProtectionRoadSession?

    init() {}

    /// The road session of the current open (nil detaches — no library open on the road, or none yet).
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

    /// VX-314: the library's bound account — the ONE truth `currentKeys`
    /// already reads (the protection record's), exposed for the engine's
    /// account-binding gate. nil: no session attached, or the library is
    /// unbound (the gate is inert on nil by design).
    var boundAccount: String? {
        current?.library.record?.account
    }
}
