//
//  ProtectionScanTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): no secret appears in any value
//  written to disk (the encodings scanned), and no raw hardware identifier
//  either — the hardware marker is a salted hash, recomputed on the same
//  hardware and login (design §3.2, VX-340).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U1 — the scans: no secret and no hardware identifier in any stored value")
struct ProtectionScanTests {
    @Test func noSecretAppearsInAnyValueWrittenToDisk() throws {
        let world = try KeyWorld()
        let library = world.library
        let device = PF.id()
        let c0 = StoreKey.mint(), c1 = StoreKey.mint(), s2 = StoreKey.mint(), s3 = StoreKey.mint()
        let apple = AppleKeyMaterial.mint()
        let anchorKey = SymmetricKey(size: .bits256)

        // A synced Castle library, a re-key, a leave (anchor first, its key
        // known to the test), a re-key in Standard under this Mac's Apple key.
        let castle0 = try world.castleFile(c0)
        let castle1 = try castle0.rekeyed(.withinMode, from: c0, to: c1, locks: world.castleLocks(), at: PF.day(1)).keyFile
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castle1, outgoingKey: c1,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: castle1, includeMasterRoad: true),
            madeAt: PF.day(2), madeBy: device, anchorKey: anchorKey)
        let standard2 = try castle1.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c1, to: s2,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple),
            at: PF.day(2)).keyFile
        let standard3 = try standard2.rekeyed(
            .withinMode, from: s2, to: s3,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple),
            at: PF.day(3)).keyFile

        // The record, this Mac's facts in both homes, a plan.
        var record = ProtectionRecord.minting(
            libraryID: library, mode: .castle, account: PF.id(),
            currentFingerprint: PF.fp(c0), madeBy: device, at: PF.t0)
        record = record.recordingRekey(to: PF.fp(c1), kind: .castle, by: device, at: PF.day(1))
            .recordingRekey(to: PF.fp(s2), kind: .standard, by: device, at: PF.day(2))
            .recordingRekey(to: PF.fp(s3), kind: .standard, by: device, at: PF.day(3))
        let section = DeviceSection(
            deviceID: device, hardwareMarker: record.marker(for: PF.macA),
            settings: DeviceSettings(gateStyle: .touchID))
            .recordingAppleKey(AppleKeyRecord(id: apple.id, purpose: .library, origin: .minted))
            .beginningAct(.replaceAllKeys, from: PF.fp(s3), to: nil, at: PF.day(4)).section
        record = try record.storing(section, sealedUnder: s3)
        let memory = DeviceMemory(
            libraryID: library, scope: "Variorum", currentFingerprint: PF.fp(s3), keyEpoch: record.keyEpoch,
            lastConfirmed: ConfirmedFacts(mode: .standard, account: record.account),
            vaultFacts: VaultFacts(kdf: world.p.kdf, corpusKeyID: PF.id(), recoveryWrapDigest: "d"),
            keyFileMirror: standard3, familyTree: record.familyTree, deviceSection: section)
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
            ("anchor key", PF.bytes(anchorKey)),
            ("passphrase key", PF.bytes(world.p.key)), ("words key", PF.bytes(world.w.key)),
            ("passphrase", Data(world.passphrase.utf8)),
            ("the words", Data(world.words.joined(separator: " ").utf8)),
            ("the words, joined", Data(world.words.joined().utf8)),
            ("hardware identity", Data(PF.macA.hardware.utf8)),
            ("hardware identity, lowercased", Data(PF.macA.hardware.lowercased().utf8)),
            ("login identity", Data(PF.macA.login.utf8)),
            ("login identity, lowercased", Data(PF.macA.login.lowercased().utf8)),
            // Each part of the marker is SALTED (her 2026-10-14/15 split): no
            // unsalted hash of either identifier is stored anywhere.
            ("hardware identity, unsalted hash", Data(SHA256.hash(data: Data(PF.macA.hardware.utf8)))),
            ("login identity, unsalted hash", Data(SHA256.hash(data: Data(PF.macA.login.utf8)))),
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
        // The marker's two parts live in this Mac's facts (the record's
        // section and the memory's second home) and nowhere else.
        for (name, data) in stored where name != "record" && name != "memory" {
            for part in [section.hardwareMarker.hardware, section.hardwareMarker.login] {
                #expect(!SecretScan.carries(data, text: part), "\(name) carries a marker part")
            }
        }
        // The marker's salt lives in the record and nowhere else.
        for (name, data) in stored where name != "record" {
            #expect(!SecretScan.carries(data, record.markerSalt), "\(name) carries the marker salt")
        }
        // The scan itself bites: a planted raw key IS found.
        #expect(SecretScan.carries(try ProtectionCoding.canonical(["k": c0.data]), c0.data))
        #expect(SecretScan.carries(Data(c0.hexEncoded.utf8), c0.data))
    }
}
