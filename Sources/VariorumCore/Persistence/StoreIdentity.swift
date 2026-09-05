import Foundation

// pre-13x batch 1a — THE STORE'S IDENTITY WITHOUT THE KEY (the postures
// design §1.13 / §3.7 / §14.3). A library's id is its key file's `storeID`
// (stable across re-keys — every key file of one library carries it); the
// device's per-store custody items are NAMED by it, so it must be readable
// before any key is in hand. `resolve` reads it from the current key file
// beside the store; `establish` is the MINT road's step: it writes the key
// file (store id + the minted key's fingerprint, no wraps) BEFORE the
// Keychain add, so the item's name exists on disk before the item does.
//
// A key file that BELONGS to the key (a fingerprint-less stub, or the same
// fingerprint) keeps its id; a foreign wraps-bearing file — another key's
// — is SET ASIDE (`.stale-<stamp>.json`, the controller's own set-aside
// shape; never deleted: its wraps are somebody's recovery legs) and a fresh
// id is minted. "Start a New Library" (§3.7) therefore always lands under a
// NEW store id: the old library's items stay where they are, unreachable
// by name, never deleted.

public enum StoreIdentity {
    public enum Reading: Equatable, Sendable {
        /// The current key file names the library.
        case known(String)
        /// No key file beside the store (a fresh library, or a pre-1a
        /// store that never landed a wrap).
        case none
        /// A key file exists but cannot be decoded — a REFUSAL to write
        /// anything beside it (P1/P11), never absence.
        case unreadable
    }

    /// The store id beside `storeURL`, found without the key.
    public static func resolve(besideStore storeURL: URL) -> Reading {
        do {
            guard let envelope = try StoreKeyEnvelope.loadCurrent(besideStore: storeURL)
            else { return .none }
            return .known(envelope.storeID)
        } catch {
            return .unreadable
        }
    }

    /// The mint road (and the legacy-item re-scope): ensure a key file
    /// beside the store carries `key`'s fingerprint, and return its store
    /// id. Reuses the id of a file that belongs to the key; sets a foreign
    /// file aside and mints a new id. Throws on an unreadable file (never
    /// overwrite what cannot be read).
    @discardableResult
    public static func establish(besideStore storeURL: URL, key: StoreKey) throws -> String {
        let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
        var envelope: StoreKeyEnvelope
        if let current = try StoreKeyEnvelope.loadCurrent(besideStore: storeURL) {
            if current.belongs(to: key) {
                envelope = current
            } else {
                setAside(besideStore: storeURL)
                envelope = StoreKeyEnvelope()
            }
        } else {
            envelope = StoreKeyEnvelope()
        }
        if envelope.keyFingerprint != fingerprint {
            envelope.keyFingerprint = fingerprint
            envelope.formatVersion = StoreKeyEnvelope.currentFormatVersion
        }
        let target = envelope.preferredURL(besideStore: storeURL)
        // Write only when the file on disk would change (a re-mint over a
        // stub, or the first write); an identical file is left untouched.
        if (try? StoreKeyEnvelope.load(at: target)) != envelope {
            try FileManager.default.createDirectory(
                at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            try envelope.write(at: target)
        }
        return envelope.storeID
    }

    /// Move the current key file aside (never delete). The same shape the
    /// app layer's launch gate uses, so a set-aside file looks the same
    /// whoever moved it.
    public static func setAside(besideStore storeURL: URL) {
        guard let url = StoreKeyEnvelope.locate(besideStore: storeURL) else { return }
        let aside = url.deletingPathExtension()
            .appendingPathExtension("stale-\(Int(Date().timeIntervalSince1970)).json")
        try? FileManager.default.moveItem(at: url, to: aside)
    }
}
