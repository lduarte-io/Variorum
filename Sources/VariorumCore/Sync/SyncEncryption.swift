import CryptoKit
import Foundation

/// Phase 14b — the E2EE payload seam's key side (rulings R-6/R-8, THE
/// DESIGN's "Sync gating"). The engine takes a `SyncKeyProviding` and asks
/// it once per round half; everything the engine pushes or applies flows
/// through `SyncPayloadCrypto` built from the answer.
///
/// **Post-14b there is NO plaintext mode**: E2EE is mandatory from birth
/// (release-strategy §4). Keys absent or locked is not an error state to
/// work around — the round REFUSES visibly (outbox intact, cursor unmoved,
/// `SyncError.encryptionKeysUnavailable` naming the fix), exactly the
/// SyncSpec §12 lockstep-refusal grammar. Stalling is free; guessing —
/// pushing plaintext, or applying unverified bytes — is the one forbidden
/// move.

/// The key material one sync round seals/opens with. v1 carries the CORPUS
/// class key only (R-8): every synced table's encrypted columns are corpus
/// class; the journal-bridge key is the bridge's (batch 3) and never
/// enters the row-sync engine.
public struct SyncEncryptionKeys: Sendable {
    /// The corpus-class key (unwrapped, from the device Keychain at batch
    /// 3; a fixed test key in the harness).
    public let corpusKey: SymmetricKey
    /// The corpus key's vault key id — bound into every ciphertext's AAD
    /// (`PayloadCipher.Binding`), so a value can never be silently
    /// re-attributed to a different key.
    public let corpusKeyID: String
    /// pre-13x (decision 12): THE KEY PROOF — since 13y UNIT B the
    /// MATERIAL (`KeyProofMaterial`: kp1's wire form for the enroll road +
    /// kp2, the per-request MAC key, both derived from M), computed on
    /// demand by the holder of the master key. The round's
    /// `SyncChallengeSigner` turns it into one single-use proof per RPC
    /// call. REQUIRED here (no default — every composition site decides):
    /// a round without it is refused by the server with
    /// `SyncError.keyProofRefused`.
    public let keyProof: KeyProofMaterial
    /// pre-13x (decisions 6 / 31): while a rotation is finishing, the
    /// PREVIOUS corpus key (+ its id) and the server's rotation seq — the
    /// seam opens a pulled row whose `server_seq` is BELOW the seq under
    /// the previous key, every other row under the current one. nil
    /// outside a rotation; one optional so "both or neither" holds by
    /// construction. Batch 2's driver fills it from the vault.
    public let rotation: RotationInProgress?
    /// VX-307 U1 (CastleRules rule 15): the account's EARLIER row keys, by
    /// id — rows written before a key change stay under their day's key and
    /// open by the key their own id names. Empty everywhere but the new
    /// road's provider, so today's call sites are byte-unchanged.
    public let earlierKeys: [String: SymmetricKey]

    public init(
        corpusKey: SymmetricKey, corpusKeyID: String, keyProof: KeyProofMaterial,
        rotation: RotationInProgress? = nil, earlierKeys: [String: SymmetricKey] = [:]
    ) {
        self.corpusKey = corpusKey
        self.corpusKeyID = corpusKeyID
        self.keyProof = keyProof
        self.rotation = rotation
        self.earlierKeys = earlierKeys
    }
}

/// A rotation in progress, as the seam needs it (the design's §3.10 seq
/// rule): the previous corpus key with its OWN id (the AAD of a
/// pre-rotation row was bound to it) and the `rotation_started_seq` the
/// vault carries.
public struct RotationInProgress: Sendable {
    public let previousCorpusKey: SymmetricKey
    public let previousCorpusKeyID: String
    public let startedSeq: Int64

    public init(previousCorpusKey: SymmetricKey, previousCorpusKeyID: String, startedSeq: Int64) {
        self.previousCorpusKey = previousCorpusKey
        self.previousCorpusKeyID = previousCorpusKeyID
        self.startedSeq = startedSeq
    }
}

/// The engine's key seam. Batch 3 wires the Keychain-backed provider
/// (enrollment-only cadence, R-6 — the keys persist per device after the
/// one-time passphrase unwrap); tests bind a fixed provider so the whole
/// convergence suite runs over ciphertext.
public protocol SyncKeyProviding: Sendable {
    /// The round's key material. Throw ANYTHING to signal absent/locked —
    /// the engine maps every throw to `SyncError.encryptionKeysUnavailable`
    /// and refuses the round before any network contact.
    func currentKeys() throws -> SyncEncryptionKeys

    /// pre-13x batch 1a (the postures design §1.13 / §3.3): THIS DEVICE'S
    /// IDENTITY for this library's sync — the `device_id` the pull's
    /// `for_device` carries (the server's `device_cursor`, the purge
    /// horizon's substrate). It RIDES THE SYNC-KEY CUSTODY ITEM, never the
    /// store file: a copy of the library on another machine has no custody
    /// for its store id and therefore no identity — it is writing, never a
    /// device — and gets a fresh one when it enrolls. `sync_state.device_id`
    /// is gone. Throw to signal no custody (the engine refuses the round
    /// exactly as for absent keys).
    func deviceIdentity() throws -> String
}

/// The post-14b default: a device with no enrollment wired refuses every
/// round. This is the DESIGNED behavior, not a stub — the app target keeps
/// compiling through the defaulted engine parameter, and its rounds refuse
/// visibly until the enrollment flow installs a real provider.
public struct UnenrolledKeyProvider: SyncKeyProviding {
    public init() {}
    public func currentKeys() throws -> SyncEncryptionKeys {
        throw SyncKeyProviderError.notEnrolled
    }
    public func deviceIdentity() throws -> String {
        throw SyncKeyProviderError.notEnrolled
    }
}

/// A fixed key world with a FIXED identity — the in-process worlds that
/// hold keys in memory (the `vault-bootstrap` runner, the re-key brain's
/// `resyncReinitialize`-only engine, the tests' fixed providers) compose
/// over it. Public so the app's test target can build one too.
public struct StaticSyncKeyProvider: SyncKeyProviding {
    public let keys: SyncEncryptionKeys
    public let deviceID: String
    public init(keys: SyncEncryptionKeys, deviceID: String) {
        self.keys = keys
        self.deviceID = deviceID
    }
    public func currentKeys() throws -> SyncEncryptionKeys { keys }
    public func deviceIdentity() throws -> String { deviceID }
}

public enum SyncKeyProviderError: Error, Equatable, Sendable {
    /// No key material is available on this device (never enrolled, or the
    /// Keychain item is inaccessible/locked).
    case notEnrolled
}

/// THE SEAM (Phase 14b, THE DESIGN's "What encrypts, where"): rows leave
/// the store as plaintext (local SQLite IS plaintext — FileVault guards the
/// device; the E2EE boundary is the network/server), are SEALED here on
/// the way to the transport, and are OPENED here the moment they arrive —
/// the pull window AND the push-reject's `current` row alike — so the
/// engine inland (`Merge.swift`, `Repairs.swift`, CAS bookkeeping, FK
/// checks) operates on plaintext and stays byte-untouched.
///
/// Which columns seal is the registry's truth (`SyncTable.encryptedColumns`
/// — the completeness walk forces every column to take a side). NULL passes
/// (presence/absence is disclosed structure); a non-text value in an
/// encrypted-classified column is impossible through Operations and
/// refuses loudly rather than inventing an encoding.
struct SyncPayloadCrypto: Sendable {
    let keys: SyncEncryptionKeys

    /// Plaintext local row → wire payload: every encrypted-classified text
    /// value sealed under the corpus key, AAD-bound to
    /// `table:rowID:column:keyID`.
    func encryptForWire(_ row: SyncRow) throws -> SyncRow {
        guard let table = SyncSchema.table(named: row.table) else {
            throw SyncError.unknownTable(row.table)
        }
        guard !table.encryptedColumns.isEmpty else { return row }
        var sealed = row
        for column in table.encryptedColumns {
            guard let value = row.columns[column] else { continue }
            switch value {
            case .null:
                continue
            case .text(let plaintext):
                do {
                    sealed.columns[column] = .text(try PayloadCipher.seal(
                        plaintext, key: keys.corpusKey,
                        binding: binding(row, column: column)))
                } catch {
                    throw SyncError.payloadCryptoFailure(
                        table: row.table, rowID: row.rowID, column: column,
                        detail: String(describing: error))
                }
            case .integer, .real:
                // SQLite's flexible typing could smuggle a number into a
                // TEXT column; no Operation writes one, and an encrypted-
                // classified value has no non-text form — refuse, never
                // invent an encoding (the blobInPayload doctrine).
                throw SyncError.payloadCryptoFailure(
                    table: row.table, rowID: row.rowID, column: column,
                    detail: "non-text value in an encrypted-classified column")
            }
        }
        return sealed
    }

    /// Wire payload → plaintext row, BEFORE any inland logic sees it.
    /// The policy (post-14b, no plaintext mode): a non-`e1:` value arriving
    /// in an encrypted-classified column refuses the whole round with a
    /// typed error naming table/row — wipe-and-repush (R-2) guarantees this
    /// never fires in practice, so firing signals a real fault: fail
    /// visible, never pass through silently. Wrong-key/tamper/foreign-
    /// version failures refuse the same way (nothing unauthenticated is
    /// ever applied).
    func decryptFromWire(_ row: SyncRow) throws -> SyncRow {
        do {
            return try decryptFromWire(row, key: keys.corpusKey, keyID: keys.corpusKeyID)
        } catch let primary as SyncError {
            // VX-307 U1 (rule 15): a reject's `current` row may be an
            // earlier-key write (its last edit predates a key change) — the
            // same deterministic fallback as the pull path; dead while
            // `earlierKeys` is empty.
            guard case .payloadCryptoFailure = primary, !keys.earlierKeys.isEmpty else { throw primary }
            for id in keys.earlierKeys.keys.sorted() {
                guard let key = keys.earlierKeys[id] else { continue }
                if let opened = try? decryptFromWire(row, key: key, keyID: id) { return opened }
            }
            throw primary
        }
    }

    /// THE SEQ RULE (pre-13x decision 31): a row whose `server_seq` is
    /// BELOW the rotation seq is under the PREVIOUS corpus key (and its
    /// AAD names that key's id); every other row is under the current one.
    /// Outside a rotation there is one key. Every arriving row — the pull
    /// window and the push-reject's `current` alike — carries its seq, so
    /// both roads open by this rule.
    func keyMaterial(forServerSeq seq: Int64) -> (key: SymmetricKey, keyID: String) {
        if let rotation = keys.rotation, seq < rotation.startedSeq {
            return (rotation.previousCorpusKey, rotation.previousCorpusKeyID)
        }
        return (keys.corpusKey, keys.corpusKeyID)
    }

    private func decryptFromWire(_ row: SyncRow, key: SymmetricKey, keyID: String) throws -> SyncRow {
        guard let table = SyncSchema.table(named: row.table) else {
            throw SyncError.unknownTable(row.table)
        }
        guard !table.encryptedColumns.isEmpty else { return row }
        var opened = row
        for column in table.encryptedColumns {
            guard let value = row.columns[column] else { continue }
            switch value {
            case .null:
                continue
            case .text(let encoded):
                do {
                    opened.columns[column] = .text(try PayloadCipher.open(
                        encoded, key: key,
                        binding: binding(row, column: column, keyID: keyID)))
                } catch PayloadCipherError.notEncrypted {
                    throw SyncError.unencryptedValueInEncryptedColumn(
                        table: row.table, rowID: row.rowID, column: column)
                } catch {
                    throw SyncError.payloadCryptoFailure(
                        table: row.table, rowID: row.rowID, column: column,
                        detail: String(describing: error))
                }
            case .integer, .real:
                // A number where ciphertext must stand is the same policy
                // class as bare plaintext: an unencrypted value.
                throw SyncError.unencryptedValueInEncryptedColumn(
                    table: row.table, rowID: row.rowID, column: column)
            }
        }
        return opened
    }

    func decryptFromWire(_ pulled: SyncPulledRow) throws -> SyncPulledRow {
        let material = keyMaterial(forServerSeq: pulled.serverSeq)
        do {
            return SyncPulledRow(
                row: try decryptFromWire(pulled.row, key: material.key, keyID: material.keyID),
                serverSeq: pulled.serverSeq)
        } catch let primary as SyncError {
            // VX-307 U1 (rule 15): a row from before a key change is under
            // an earlier key — the AAD binds the key id, so exactly one
            // (key, id) pair opens it; the tries are deterministic (sorted
            // ids) and this arm is dead while `earlierKeys` is empty
            // (today's road, byte-unchanged).
            guard case .payloadCryptoFailure = primary, !keys.earlierKeys.isEmpty else { throw primary }
            for id in keys.earlierKeys.keys.sorted() {
                guard let key = keys.earlierKeys[id] else { continue }
                if let opened = try? decryptFromWire(pulled.row, key: key, keyID: id) {
                    return SyncPulledRow(row: opened, serverSeq: pulled.serverSeq)
                }
            }
            throw primary
        }
    }

    private func binding(_ row: SyncRow, column: String) -> PayloadCipher.Binding {
        binding(row, column: column, keyID: keys.corpusKeyID)
    }

    private func binding(_ row: SyncRow, column: String, keyID: String) -> PayloadCipher.Binding {
        PayloadCipher.Binding(
            table: row.table, rowID: row.rowID, column: column, keyID: keyID)
    }
}
