import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// pre-13x batch 1b — THE KEY PROOF's client half (design §3.10, decision
/// 12) and the vault format's six additive columns (§3.10; the format
/// version STAYS 1): the token's shape, its hash, the wire round trip, a
/// pre-postures row decoding with the fields nil, the previous key + its
/// id + the rotation seq being NIL TOGETHER outside a rotation, the
/// Apple-held copy's presence/absence roads, and the previous key's two
/// columns (its id in its OWN column — the orchestrator's ruling).
@Suite("The key proof + the vault's postures fields (pre-13x 1b)")
struct KeyProofTests {
    private func sampleFormat() throws
        -> (format: KeyVaultFormat, master: SymmetricKey, corpus: SymmetricKey)
    {
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: SymmetricKey(size: .bits256),
            recoveryKey: nil,
            classKeys: [
                (keyClass: .corpus, keyID: "corpus-id-1", key: corpus),
                (keyClass: .journalBridge, keyID: "journal-id-1", key: SymmetricKey(size: .bits256)),
            ],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        return (format, master, corpus)
    }

    // MARK: The token

    @Test func theTokenIsThirtyTwoBytesDeterministicPerMasterAndDifferentAcrossMasters() {
        let m1 = SymmetricKey(size: .bits256)
        let m2 = SymmetricKey(size: .bits256)
        let t1 = KeyProof.token(master: m1)
        #expect(t1.count == 32)
        #expect(KeyProof.token(master: m1) == t1, "deterministic — computed on demand, never stored")
        #expect(KeyProof.token(master: m2) != t1, "a new master gives a new proof — the rotation road")
        // The wire form is the token, base64; the server hashes the RAW
        // token — so the client-side hash and the fake server's hash of
        // the wire form agree.
        let wire = KeyProof.wireToken(master: m1)
        #expect(Data(base64Encoded: wire) == t1)
        #expect(KeyProof.hash(ofWireToken: wire) == KeyProof.hash(master: m1))
        #expect(KeyProof.hash(master: m1).count == 64, "SHA-256 hex")
        #expect(KeyProof.hash(master: m1).allSatisfy { $0.isHexDigit && ($0.isNumber || $0.isLowercase) },
                "lowercase hex — Postgres's encode(…, 'hex') form, so the constant-time compare sees identical digits")
        #expect(KeyProof.hash(ofWireToken: "not!!base64") == nil, "a malformed token has no hash — the RPC's malformed arm")
        // A known vector: HMAC-SHA256 over the purpose string with a fixed
        // key is stable across builds — pinned so the SERVER's stored hash
        // (computed once at creation) can never drift from the client's.
        let fixed = SymmetricKey(data: Data(repeating: 0x42, count: 32))
        #expect(KeyProof.hash(master: fixed)
                == KeyProof.hash(ofToken: Data(HMAC<SHA256>.authenticationCode(
                    for: Data("variorum.key-proof.v1".utf8), using: fixed))))
    }

    // MARK: The format's fields

    @Test func aVaultIsCreatedWithItsProofHashAndNothingElseOfThePosturesFields() throws {
        let sample = try sampleFormat()
        #expect(sample.format.keyProofHash == KeyProof.hash(master: sample.master),
                "CREATE lands the hash — the server's insert trigger refuses one without")
        #expect(sample.format.masterWrappedByAppleHeld == nil && sample.format.appleKeyID == nil,
                "no Apple-held copy at create (batch 2 writes Standard's)")
        #expect(sample.format.previousCorpusKey == nil && sample.format.rotationStartedSeq == nil,
                "no rotation at create")
    }

    /// A pre-postures row (format 1, none of the five keys) DECODES with the
    /// fields nil — the author's existing vault until her first round.
    @Test func aPrePosturesFormatOneVaultDecodesWithTheFieldsNil() throws {
        let sample = try sampleFormat()
        // Strip the five keys from the encoded JSON — the row a 14b-era
        // client wrote.
        var json = try JSONSerialization.jsonObject(with: sample.format.encoded()) as! [String: Any]
        for key in ["masterWrappedByAppleHeld", "appleKeyID", "keyProofHash",
                    "previousCorpusKey", "rotationStartedSeq", "updatedByDevice"] {
            json.removeValue(forKey: key)
        }
        let decoded = try KeyVaultFormat(decoding: try JSONSerialization.data(withJSONObject: json))
        #expect(decoded.formatVersion == 1)
        #expect(decoded.keyProofHash == nil)
        #expect(decoded.masterWrappedByAppleHeld == nil && decoded.appleKeyID == nil)
        #expect(decoded.previousCorpusKey == nil && decoded.rotationStartedSeq == nil)
        #expect(decoded.updatedByDevice == nil, "the seventh column (2c) decodes nil on a pre-postures row")
        #expect(decoded.classKeys == sample.format.classKeys, "everything else is intact")
        // And the wire row's decode does the same over the 08 column set.
        let row = try KeyVaultWireRow(format: sample.format, userID: "u")
        var wire = try JSONSerialization.jsonObject(with: JSONEncoder().encode(row)) as! [String: Any]
        for key in ["master_wrapped_by_apple_held", "apple_key_id", "key_proof_hash",
                    "corpus_previous_key_id", "corpus_previous_wrapped_by_master",
                    "rotation_started_seq", "updated_by_device"] {
            wire.removeValue(forKey: key)
        }
        let decodedRow = try JSONDecoder().decode(
            KeyVaultWireRow.self, from: try JSONSerialization.data(withJSONObject: wire))
        #expect(decodedRow.keyProofHash == nil && decodedRow.rotationStartedSeq == nil)
        #expect(decodedRow.updatedByDevice == nil)
        #expect(try decodedRow.format().keyProofHash == nil)
    }

    /// The seven columns round-trip the wire row exactly (the seventh —
    /// `updated_by_device`, decision 34 / 2c — the writing device's NAME),
    /// and the previous key travels as its id in ITS OWN column beside its
    /// bare wrap — never packed into one value; one column without the
    /// other refuses.
    @Test func theWireRowCarriesTheSevenPosturesColumnsAndThePreviousKeysTwoColumns() throws {
        let sample = try sampleFormat()
        let apple = SymmetricKey(size: .bits256)
        let previous = SymmetricKey(size: .bits256)
        var format = try sample.format.settingAppleHeldCopy(
            masterKey: sample.master, appleKey: apple, appleKeyID: "apple-key-7")
        format = try format.carryingPreviousCorpusKey(
            previous, keyID: "corpus-id-0", masterKey: sample.master)
        format.rotationStartedSeq = 4_242
        format.updatedByDevice = "Lillian's MacBook Pro"

        let row = try KeyVaultWireRow(format: format, userID: "u")
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(row)) as! [String: Any]
        #expect(json["apple_key_id"] as? String == "apple-key-7")
        #expect(json["updated_by_device"] as? String == "Lillian's MacBook Pro",
                "the seventh column: a NAME, never an id")
        #expect(json["key_proof_hash"] as? String == KeyProof.hash(master: sample.master))
        #expect((json["master_wrapped_by_apple_held"] as? String).flatMap { Data(base64Encoded: $0) }
                == format.masterWrappedByAppleHeld)
        #expect(json["rotation_started_seq"] as? Int64 == 4_242)
        #expect(json["corpus_previous_key_id"] as? String == "corpus-id-0",
                "the previous key's ID in its OWN column")
        let previousWire = try #require(json["corpus_previous_wrapped_by_master"] as? String)
        #expect(!previousWire.contains(":"), "the wrap is bare base64 — never a packed <id>:<wrap>")
        #expect(Data(base64Encoded: previousWire) == format.previousCorpusKey?.wrappedByMaster)

        let back = try JSONDecoder().decode(KeyVaultWireRow.self, from: JSONEncoder().encode(row)).format()
        #expect(back == format, "the seven columns round-trip exactly")
        // The roads: the Apple copy opens with A; the previous key opens
        // with the (new) master and returns its id for the AAD.
        #expect(try back.unwrapMaster(withAppleKey: apple) == sample.master)
        let unwrapped = try back.unwrapPreviousCorpusKey(masterKey: sample.master)
        #expect(unwrapped.key == previous && unwrapped.keyID == "corpus-id-0")
        // One column without the other is a malformed row; a non-base64
        // wrap refuses typed, never crashes.
        var idOnly = row
        idOnly.corpusPreviousWrappedByMaster = nil
        #expect(throws: KeyVaultClientError.self, "an id without its wrap") { _ = try idOnly.format() }
        var wrapOnly = row
        wrapOnly.corpusPreviousKeyID = nil
        #expect(throws: KeyVaultClientError.self, "a wrap without its id") { _ = try wrapOnly.format() }
        var bad = row
        bad.corpusPreviousWrappedByMaster = "not!!base64"
        #expect(throws: KeyVaultClientError.self) { _ = try bad.format() }
    }

    /// The previous key, ITS ID and the rotation seq are NIL TOGETHER
    /// outside a rotation: completion clears all three (§3.10's "pin the
    /// absence of both, together" — three columns since the ruling); the
    /// Apple-held copy's ABSENCE is what Castle pins.
    @Test func thePreviousKeyAndTheSeqClearTogetherAndCastleCarriesNoAppleCopy() throws {
        let sample = try sampleFormat()
        var format = try sample.format.carryingPreviousCorpusKey(
            SymmetricKey(size: .bits256), keyID: "corpus-id-0", masterKey: sample.master)
        format.rotationStartedSeq = 9
        #expect(format.previousCorpusKey != nil && format.rotationStartedSeq != nil)
        let done = format.clearingPreviousCorpusKey()
        #expect(done.previousCorpusKey == nil && done.rotationStartedSeq == nil,
                "completion clears the key AND the seq together — never one without the other")
        let doneRow = try KeyVaultWireRow(format: done, userID: "u")
        #expect(doneRow.corpusPreviousKeyID == nil && doneRow.corpusPreviousWrappedByMaster == nil
                    && doneRow.rotationStartedSeq == nil,
                "on the wire: the id, the wrap and the seq all nil together")
        #expect(throws: KeyVaultError.noRotationInProgress) {
            _ = try done.unwrapPreviousCorpusKey(masterKey: sample.master)
        }
        let standard = try sample.format.settingAppleHeldCopy(
            masterKey: sample.master, appleKey: SymmetricKey(size: .bits256), appleKeyID: "a")
        let castle = standard.removingAppleHeldCopy()
        #expect(castle.masterWrappedByAppleHeld == nil && castle.appleKeyID == nil,
                "Castle: no copy under the Apple-held key — the absence pin")
        #expect(throws: KeyVaultError.appleHeldCopyAbsent) {
            _ = try castle.unwrapMaster(withAppleKey: SymmetricKey(size: .bits256))
        }
        // A wrong master never becomes the Apple copy's or the previous
        // key's content (the wrap-addition guard's discipline).
        #expect(throws: KeyVaultError.masterKeyMismatch) {
            _ = try sample.format.settingAppleHeldCopy(
                masterKey: SymmetricKey(size: .bits256),
                appleKey: SymmetricKey(size: .bits256), appleKeyID: "a")
        }
        #expect(throws: KeyVaultError.masterKeyMismatch) {
            _ = try sample.format.carryingPreviousCorpusKey(
                SymmetricKey(size: .bits256), keyID: "x", masterKey: SymmetricKey(size: .bits256))
        }
    }
}
