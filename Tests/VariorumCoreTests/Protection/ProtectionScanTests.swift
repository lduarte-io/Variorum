//
//  ProtectionScanTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): no secret appears in any value
//  written to disk (the encodings scanned). (The hardware marker's scans left
//  with the marker — VX-378 U1, rule 23: no hardware identifier is read.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U1 — the scans: no secret in any stored value")
struct ProtectionScanTests {
    @Test func noSecretAppearsInAnyValueWrittenToDisk() throws {
        let world = try KeyWorld()
        let library = world.library
        let device = PF.id()
        let c0 = StoreKey.mint(), c1 = StoreKey.mint(), s2 = StoreKey.mint(), s3 = StoreKey.mint()
        let apple = AppleKeyMaterial.mint()

        // A synced Castle library, a re-key, a leave (the history carrying the
        // Castle keys), a re-key in Standard under this Mac's Apple key.
        let castle0 = try world.castleFile(c0)
        let castle1 = try castle0.rekeyed(from: c0, to: c1, kind: .castle, locks: world.castleLocks(), at: PF.day(1))
        let standard2 = try castle1.rekeyed(
            from: c1, to: s2, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple),
            at: PF.day(2))
        let standard3 = try standard2.rekeyed(
            from: s2, to: s3, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple),
            at: PF.day(3))

        // The record, this Mac's section, what this Mac remembers, a plan.
        var record = ProtectionRecord.minting(
            libraryID: library, mode: .castle, account: PF.id(), currentFingerprint: PF.fp(c0), at: PF.t0)
        record = record.recordingRekey(to: PF.fp(c1), kind: .castle, at: PF.day(1))
            .recordingRekey(to: PF.fp(s2), kind: .standard, at: PF.day(2))
            .recordingRekey(to: PF.fp(s3), kind: .standard, at: PF.day(3))
        let section = DeviceSection(deviceID: device, settings: DeviceSettings(gateStyle: .touchID))
            .recordingAppleKey(AppleKeyRecord(id: apple.id, purpose: .library, origin: .minted))
            .beginningAct(.replaceAllKeys, from: PF.fp(s3), to: nil, at: PF.day(4)).section
        record = try record.storing(section, sealedUnder: s3)
        let memory = DeviceMemory(
            libraryID: library, currentFingerprint: PF.fp(s3), deviceID: device, keyFileMirror: standard3,
            vaultFacts: VaultFacts(kdf: world.p.kdf, corpusKeyID: PF.id(), recoveryWrapDigest: "d"))
        let plan = ProtectionPlan(
            libraryID: library, deviceID: device, sequence: section.lastActSequence, act: .replaceAllKeys,
            fromFingerprint: PF.fp(s3), steps: [PlanStep(name: "prepare")], createdAt: PF.day(4))

        let stored: [(String, Data)] = [
            ("key file 0", try castle0.encoded()),
            ("key file 1", try castle1.encoded()),
            ("key file 2", try standard2.encoded()),
            ("key file 3", try standard3.encoded()),
            ("record", try ProtectionCoding.canonical(record)),
            ("memory", try ProtectionCoding.canonical(try memory.sealed(under: s3))),
            ("plan", try ProtectionCoding.canonical(try plan.sealed(under: s3))),
        ]
        var secrets: [(String, Data)] = [
            ("c0", c0.data), ("c1", c1.data), ("s2", s2.data), ("s3", s3.data),
            ("master", PF.bytes(world.master)), ("apple key", PF.bytes(apple.key)),
            ("passphrase key", PF.bytes(world.p.key)), ("words key", PF.bytes(world.w.key)),
            ("passphrase", Data(world.passphrase.utf8)),
            ("the words", Data(world.words.joined(separator: " ").utf8)),
            ("the words, joined", Data(world.words.joined().utf8)),
        ]
        for key in [s3] {
            for purpose in [SealPurpose.memory, .plan, .deviceSection] {
                secrets.append(("sealing key \(purpose.rawValue)",
                                PF.bytes(ProtectionSeal.sealingKey(libraryKey: key, libraryID: library, purpose: purpose))))
            }
        }
        for (name, data) in stored {
            for (secretName, secret) in secrets {
                #expect(!SecretScan.carries(data, secret), "\(name) carries \(secretName)")
            }
        }
        // The scan itself bites: a planted raw key IS found.
        #expect(SecretScan.carries(try ProtectionCoding.canonical(["k": c0.data]), c0.data))
        #expect(SecretScan.carries(Data(c0.hexEncoded.utf8), c0.data))
    }
}
