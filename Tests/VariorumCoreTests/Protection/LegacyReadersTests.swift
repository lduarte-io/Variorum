//
//  LegacyReadersTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): the readers that outlive the
//  release switch — formats 1 and 2, today's mode rule, today's item names
//  and values, and the old marker's read and clearing check (design §3.13,
//  §3.15).
//

import CryptoKit
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// TODAY'S `Posture.derive`, transcribed verbatim from
/// App/Variorum/Shared/StoreProtection.swift:85-119 (the app target can't be
/// imported here) — the oracle the legacy reader must agree with everywhere.
/// HAND-FORWARD (phase 2, which owns the app wiring): an app-target test that
/// runs the core reader against the REAL `Posture.derive` over the same
/// exhaustive input space, so a later edit to either is caught at once.
private enum TodaysDerive {
    enum Reading: Equatable { case determined(ProtectionMode), indeterminate(shape: ProtectionMode) }

    static func derive(
        legacyMode: LegacyAtOpenMode?, vaultHasAppleHeldCopy: Bool?, keyFile: StoreKeyEnvelope?,
        rawKeyCustody: LegacyRawKeyCustody = .unknown, enrolled: Bool
    ) -> Reading {
        if let vaultHasAppleHeldCopy { return .determined(vaultHasAppleHeldCopy ? .standard : .castle) }
        if enrolled {
            return .indeterminate(shape: shapeReading(keyFile: keyFile, rawKeyCustody: rawKeyCustody))
        }
        if let legacyMode { return .determined(legacyMode.isDemanded ? .castle : .standard) }
        return .determined(localReading(keyFile: keyFile, rawKeyCustody: rawKeyCustody))
    }

    private static func localReading(keyFile: StoreKeyEnvelope?, rawKeyCustody: LegacyRawKeyCustody) -> ProtectionMode {
        guard let keyFile else { return .standard }
        if keyFile.apple != nil { return .standard }
        guard keyFile.passphrase != nil else { return .standard }
        switch rawKeyCustody {
        case .silent: return .standard        // corner 45: Standard-waiting, never a lock
        case .gatedOrNone, .unknown: return .castle
        }
    }

    private static func shapeReading(keyFile: StoreKeyEnvelope?, rawKeyCustody: LegacyRawKeyCustody) -> ProtectionMode {
        switch rawKeyCustody {
        case .silent: return .standard
        case .gatedOrNone: return .castle
        case .unknown: return localReading(keyFile: keyFile, rawKeyCustody: .unknown)
        }
    }
}

@Suite("VX-305 U1 — the legacy mode reader agrees with today's Posture.derive")
struct LegacyModeReaderTests {
    /// Every key-file shape today's builds write: none, a wraps-less stub, a
    /// passphrase-only, an Apple-only, and both.
    private static func keyFiles() throws -> [StoreKeyEnvelope?] {
        let key = StoreKey.mint()
        var passphraseOnly = StoreKeyEnvelope()
        try passphraseOnly.setPassphraseWrap(key: key, passphrase: "p", kdf: PF.fastKDF())
        var appleOnly = StoreKeyEnvelope()
        try appleOnly.setAppleWrappedCopy(key: key, under: SymmetricKey(size: .bits256), appleKeyID: PF.id())
        var both = passphraseOnly
        try both.setAppleWrappedCopy(key: key, under: SymmetricKey(size: .bits256), appleKeyID: PF.id())
        return [nil, StoreKeyEnvelope(), passphraseOnly, appleOnly, both]
    }

    private func mapped(_ reading: LegacyModeReading) -> TodaysDerive.Reading {
        switch reading {
        case .determined(let mode): return .determined(mode)
        case .indeterminate(let shape): return .indeterminate(shape: shape)
        }
    }

    /// The whole input space — every starting state today's builds can leave,
    /// corner 45's included — agrees with today's rule.
    @Test func itAgreesWithTodaysDeriveOnTheWholeInputSpace() throws {
        var count = 0
        for keyFile in try Self.keyFiles() {
            for legacy in [nil] + LegacyAtOpenMode.allCases.map(Optional.some) {
                for vault in [nil, true, false] as [Bool?] {
                    for custody in LegacyRawKeyCustody.allCases {
                        for enrolled in [true, false] {
                            let verdict = LegacyModeReader.read(LegacyModeInputs(
                                legacyMode: legacy, vaultHasAppleHeldCopy: vault,
                                keyFile: keyFile.map(LegacyKeyFileFacts.init), rawKeyCustody: custody,
                                enrolled: enrolled))
                            let today = TodaysDerive.derive(
                                legacyMode: legacy, vaultHasAppleHeldCopy: vault, keyFile: keyFile,
                                rawKeyCustody: custody, enrolled: enrolled)
                            #expect(mapped(verdict.reading) == today)
                            count += 1
                        }
                    }
                }
            }
        }
        #expect(count == 5 * 4 * 3 * 3 * 2)
    }

    /// The design's named starting states (the phase plan §6), read as today
    /// reads them, with §3.13 step 2's recording.
    @Test func theStartingStatesReadAsTheDesignSays() throws {
        let castleShaped = LegacyKeyFileFacts(hasAppleWrap: false, hasPassphraseWrap: true)
        func read(_ inputs: LegacyModeInputs) -> LegacyModeVerdict { LegacyModeReader.read(inputs) }
        // Exposed: no secrets, no Apple copy landed — Standard, never Castle.
        let exposed = read(LegacyModeInputs(
            keyFile: LegacyKeyFileFacts(hasAppleWrap: false, hasPassphraseWrap: false),
            rawKeyCustody: .silent, enrolled: false))
        #expect(exposed.reading == .determined(.standard))
        #expect(exposed.migrationRecord == (.standard, true))
        // Standard-waiting — corner 45's ambiguous case (and VX-202's victims,
        // whose custody move left the silent item beside a Castle-shaped file):
        // today Standard; the migration records Castle, NOT confirmed.
        let waiting = read(LegacyModeInputs(keyFile: castleShaped, rawKeyCustody: .silent, enrolled: false))
        #expect(waiting.reading == .determined(.standard))
        #expect(waiting.isCorner45Ambiguous)
        #expect(waiting.migrationRecord == (.castle, false))
        // Castle with no Touch ID (Always ask): Castle, confirmed.
        let alwaysAsk = read(LegacyModeInputs(keyFile: castleShaped, rawKeyCustody: .gatedOrNone, enrolled: false))
        #expect(alwaysAsk.reading == .determined(.castle))
        #expect(alwaysAsk.migrationRecord == (.castle, true))
        // VX-209's victim: a Standard-era pair opened over a Castle library —
        // the live key file carries the Apple copy, so today reads Standard.
        let vx209 = read(LegacyModeInputs(
            keyFile: LegacyKeyFileFacts(hasAppleWrap: true, hasPassphraseWrap: true),
            rawKeyCustody: .gatedOrNone, enrolled: false))
        #expect(vx209.reading == .determined(.standard))
        // Signed out with keys / a deleted account: enrolled, no vault word —
        // the custody shape, NOT confirmed.
        let signedOut = read(LegacyModeInputs(keyFile: castleShaped, rawKeyCustody: .gatedOrNone, enrolled: true))
        #expect(signedOut.reading == .indeterminate(shape: .castle))
        #expect(signedOut.migrationRecord == (.castle, false))
        #expect(!signedOut.isCorner45Ambiguous)
        // A synced library with the vault in reach: the vault's word, confirmed.
        let synced = read(LegacyModeInputs(
            vaultHasAppleHeldCopy: false, keyFile: castleShaped, rawKeyCustody: .silent, enrolled: true))
        #expect(synced.reading == .determined(.castle))
        #expect(synced.migrationRecord == (.castle, true))
        // The 13p-era stored mode, still read through.
        #expect(read(LegacyModeInputs(legacyMode: .biometric, keyFile: nil, enrolled: false)).reading == .determined(.castle))
        // A fresh library: Standard.
        #expect(read(LegacyModeInputs(keyFile: nil, enrolled: false)).source == .freshLibrary)
    }
}

@Suite("VX-305 U1 — key files of formats 1 and 2 read as the design says")
struct LegacyKeyFileTests {
    @Test func aFormat1FileReadsAsPassphraseAndWordsOnly() throws {
        let key = StoreKey.mint()
        let words = try PF.words()
        var envelope = StoreKeyEnvelope(formatVersion: 1)
        try envelope.setPassphraseWrap(key: key, passphrase: "format one", kdf: PF.fastKDF())
        try envelope.setRecoveryWrap(key: key, words: words)
        envelope.formatVersion = 1  // written by a 13p build
        let data = try JSONEncoder().encode(envelope)
        guard case .legacy(let file) = try KeyFileDocument.decode(data) else {
            Issue.record("not read as a legacy file"); return
        }
        #expect(file.formatVersion == 1)
        #expect(file.roads == [.passphrase, .words])
        #expect(file.vaultFacts == nil)
        #expect(file.sharedAppleKeyID == nil)
        #expect(file.attributedKind == .castle)
        #expect(try file.open(passphrase: "format one", floor: PF.floor) == key)
        #expect(try file.open(words: words) == key)
        #expect(throws: StoreKeyEnvelopeError.noMasterWrappedCopy) { _ = try file.open(master: SymmetricKey(size: .bits256)) }
        #expect(try KeyFileDocument.decode(data).heldFingerprints == [PF.fp(key)])
    }

    /// Format 2's Apple wrap is the OLD SHARED key's — read as that, opened
    /// only by that id.
    @Test func aFormat2FileReadsItsAppleWrapAsTheOldSharedKeys() throws {
        let key = StoreKey.mint()
        let shared = AppleKeyMaterial.mint()
        let master = SymmetricKey(size: .bits256)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "two", kdf: PF.fastKDF())
        try envelope.setMasterWrappedCopy(key: key, under: master)
        try envelope.setAppleWrappedCopy(key: key, under: shared.key, appleKeyID: shared.id)
        try envelope.recordVaultReconciliation(kdf: PF.fastKDF(), corpusKeyID: "corpus", recoveryWrapDigest: "digest")
        guard case .legacy(let file) = try KeyFileDocument.decode(try JSONEncoder().encode(envelope)) else {
            Issue.record("not read as a legacy file"); return
        }
        #expect(file.formatVersion == 2)
        #expect(file.roads == [.passphrase, .master, .sharedApple])
        #expect(file.sharedAppleKeyID == shared.id)
        #expect(file.attributedKind == .standard)
        #expect(file.vaultFacts?.corpusKeyID == "corpus")
        #expect(try file.open(sharedApple: shared) == key)
        #expect(try file.open(master: master) == key)
        #expect(throws: KeyFileError.appleKeyMismatch(expected: shared.id, offered: "other")) {
            _ = try file.open(sharedApple: AppleKeyMaterial(id: "other", key: shared.key))
        }
    }

    @Test func formatsAreToldApartAndANewerOneRefuses() throws {
        let key = StoreKey.mint()
        let v3 = KeyFile(libraryID: PF.id(), key: key, epoch: 1)
        guard case .format3(let reread) = try KeyFileDocument.decode(try v3.encoded()) else {
            Issue.record("format 3 not recognized"); return
        }
        #expect(reread == v3)
        #expect(throws: KeyFileError.newerFormat(4)) {
            _ = try KeyFileDocument.decode(Data(#"{"formatVersion":4}"#.utf8))
        }
        #expect(throws: StoreKeyEnvelopeError.self) { _ = try KeyFileDocument.decode(Data("not json".utf8)) }
    }
}

@Suite("VX-305 U1 — today's item names and values, read-only")
struct LegacyItemsTests {
    /// The per-library-ID names agree with today's code where the core can
    /// see it.
    @Test func todaysNamesAreTodays() {
        let library = PF.id()
        #expect(LegacyItems.storeKeyService == StoreKeyCustody.deviceKeychainService)
        #expect(LegacyItems.boundAccount(scope: "Variorum", libraryID: library)
            == StoreKeyKeychain.boundAccount(scope: "Variorum", storeID: library))
        #expect(LegacyItems.legacyBoundAccount(scope: "Variorum") == StoreKeyKeychain.legacyBoundAccount(scope: "Variorum"))
        #expect(LegacyItems.gatedAccount(scope: "Variorum-dev", libraryID: library) == "Variorum-dev-\(library)-biometric")
        #expect(LegacyItems.syncBoundAccount(scope: "Variorum", libraryID: library) == "Variorum-\(library)-sync")
        #expect(LegacyItems.escrowAccount(libraryID: library) == library)
        #expect(ProtectionNames.oldSharedAppleKeyAccount(scope: "Variorum") == "Variorum-apple-key")
    }

    /// The values decode as today's code writes them: the raw key, the sync
    /// custody record (and the 14b bare blob), the old shared key's `{id, key}`.
    @Test func todaysValuesDecode() throws {
        let key = StoreKey.mint()
        #expect(LegacyItems.storeKey(fromItemData: key.data) == key)
        #expect(LegacyItems.storeKey(fromItemData: Data([1, 2])) == nil)
        let material = DeviceKeyMaterial(
            masterKey: Data(repeating: 1, count: 32), corpusKey: Data(repeating: 2, count: 32), corpusKeyID: "c",
            journalBridgeKey: Data(repeating: 3, count: 32), journalBridgeKeyID: "j")
        let device = PF.id()
        // `SyncCustodyRecord`'s encoding: {deviceID, material}.
        struct Record: Encodable { var deviceID: String; var material: DeviceKeyMaterial? }
        let record = try JSONEncoder().encode(Record(deviceID: device, material: material))
        #expect(LegacyItems.syncCustody(fromItemData: record)
            == LegacyItems.SyncCustodyValue(deviceID: device, material: material))
        let identityOnly = try JSONEncoder().encode(Record(deviceID: device, material: nil))
        #expect(LegacyItems.syncCustody(fromItemData: identityOnly)?.deviceID == device)
        let bare = try JSONEncoder().encode(material)
        #expect(LegacyItems.syncCustody(fromItemData: bare) == LegacyItems.SyncCustodyValue(deviceID: nil, material: material))
        // `AppleKey`'s encoding: {id, key}.
        struct Apple: Encodable { var id: String; var key: Data }
        let id = PF.id()
        let bytes = Data(repeating: 7, count: 32)
        let apple = LegacyItems.appleKey(fromItemData: try JSONEncoder().encode(Apple(id: id, key: bytes)))
        #expect(apple?.id == id)
        #expect(apple.map { PF.bytes($0.key) } == bytes)
    }
}

@Suite("VX-305 U1 — the old marker: read forever, cleared on the disk's evidence")
struct LegacyMarkerTests {
    private func database() throws -> DatabaseQueue {
        let queue = try DatabaseQueue()
        try queue.write { db in
            try db.execute(sql: "CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
        }
        return queue
    }

    /// The restated reader reads exactly what today's `RotationMarker.write`
    /// writes — every step, every field — and a 14c-era value as `.vaultWrite`.
    @Test func itReadsWhatTodaysMarkerWrites() throws {
        let queue = try database()
        #expect(try queue.read { try LegacyRotationMarker.read($0) } == nil)
        for step in RotationMarker.Step.allCases {
            let marker = RotationMarker(
                step: step, entersCastle: step.rawValue.count % 2 == 0, oldKeyFingerprint: "aaaaaaaaaaaaaaaa",
                newKeyFingerprint: "bbbbbbbbbbbbbbbb", newCorpusKeyID: "corpus", startedAt: "2026-10-14T01:02:03Z",
                follow: step == .custody ? true : nil)
            try queue.write { try RotationMarker.write(marker, $0) }
            let read = try #require(try queue.read { try LegacyRotationMarker.read($0) })
            #expect(read.step.rawValue == step.rawValue)
            #expect(read.entersCastle == marker.entersCastle)
            #expect(read.oldKeyFingerprint == marker.oldKeyFingerprint)
            #expect(read.newKeyFingerprint == marker.newKeyFingerprint)
            #expect(read.newCorpusKeyID == marker.newCorpusKeyID)
            #expect(read.startedAt == marker.startedAt)
            #expect(read.follow == marker.follow)
        }
        #expect(LegacyRotationMarker.Step.allCases.map(\.rawValue) == RotationMarker.Step.allCases.map(\.rawValue))
        try queue.write {
            try $0.execute(sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
                           arguments: [LegacyRotationMarker.syncStateKey, "2026-08-04 12:00:00"])
        }
        let stamp = try #require(try queue.read { try LegacyRotationMarker.read($0) })
        #expect(stamp.step == .vaultWrite)
        #expect(stamp.startedAt == "2026-08-04 12:00:00")
    }

    /// The clearing check (§3.13 step 1): the library still opens under its
    /// old key and the new key never landed → never happened; otherwise its
    /// commit happened. Either way the marker clears.
    @Test func theClearingCheckReadsTheDisk() {
        let old = "aaaaaaaaaaaaaaaa", new = "bbbbbbbbbbbbbbbb"
        let marker = LegacyRotationMarker(
            step: .rekeyLibrary, entersCastle: true, oldKeyFingerprint: old, newKeyFingerprint: new, startedAt: "s")
        // The old key opens it and no new key file landed (VX-235's stuck marker).
        #expect(marker.resolve(.init(opensUnder: old, newKeyFileLanded: false)) == .neverHappened)
        // The new key file landed before the swap — its prepare is on disk.
        #expect(marker.resolve(.init(opensUnder: old, newKeyFileLanded: true)) == .commitHappened)
        // The swap happened: the library opens under the new key.
        #expect(marker.resolve(.init(opensUnder: new, newKeyFileLanded: true)) == .commitHappened)
        #expect(marker.resolve(.init(opensUnder: new, newKeyFileLanded: false)) == .commitHappened)
        // A marker at `.custody` / `.snapshot` (past the swap).
        var later = marker
        later.step = .snapshot
        #expect(later.resolve(.init(opensUnder: new, newKeyFileLanded: true)) == .commitHappened)
        // PROVISIONAL: a fingerprint-less marker (`vaultWrite` / `reencrypt`)
        // never minted a library key — never happened, library-wise.
        let early = LegacyRotationMarker(step: .reencrypt, entersCastle: true, startedAt: "s")
        #expect(early.resolve(.init(opensUnder: old, newKeyFileLanded: false)) == .neverHappened)
        #expect(LegacyRotationMarker.Resolution.neverHappened.clearsTheMarker)
        #expect(LegacyRotationMarker.Resolution.commitHappened.clearsTheMarker)
    }
}
