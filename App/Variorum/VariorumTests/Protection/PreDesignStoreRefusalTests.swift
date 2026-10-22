//
//  PreDesignStoreRefusalTests.swift
//  VariorumTests — VX-329 U1 piece 5: THE HONEST REFUSAL (the plan's §6 OPEN DESIGN NOTE). With today's readers deleted
//  ("nothing is kept read-only"), a store from BEFORE this design — her real store included: an encrypted library with
//  an older Variorum's key file beside it (`variorum-keys-<fp16>.json`) and no format-3 key file, record, memory item or
//  custody item of this design — is a store the road cannot open (CastleRules rule 26). These pins hold WHAT THE BUILT
//  SHAPE SAYS, never a crash and never a guess, over PLANTED leaves (no keychain):
//    · the LIVE SLOT routes to the lobby with rule 27's refusal (§7c (3), `ProtectionWords.noKeyFileAnywhere` — "No key
//      file opens this library…") and its three doors, and offers no typed road that could not open it; the older key
//      file and the store are only read; no key file is minted on a guess;
//    · a PICKED copy of that shape (File ▸ Open Library…) is named as a library with a key file and refused as "This file
//      couldn't be read as a library." — never the no-key-file sentence; one with no key file at all keeps the honest
//      keyless refusal.
//  What the shape does NOT do (recorded for the orchestrator, never invented here): neither face names the older format
//  or the road out (export from the old build, sync, start fresh) — the road's facts do not see an older Variorum's file
//  names (rule 26), so naming them would need a new fact and new words: hers.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-329 U1 — piece 5: a store from before this design meets the honest refusal (planted, no keychain)")
@MainActor
struct PreDesignStoreRefusalTests {
    /// An older Variorum's key file's top-level shape (the classifier and the road read its NAME only).
    private func olderKeyFileBytes(_ key: StoreKey) -> Data {
        let recovery = Data((0..<40).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        return Data("""
            {"formatVersion":2,"storeID":"\(UUID().uuidString.lowercased())",\
            "keyFingerprint":"\(KeyFingerprint.of(key))","recovery":"\(recovery)"}
            """.utf8)
    }

    /// A pre-design library in `folder`: a keyed store with no protection record, the older key file beside it.
    private func plantPreDesignLibrary(at store: URL) throws -> (olderKeyFile: URL, olderBytes: Data) {
        let key = StoreKey.mint()
        try FileManager.default.createDirectory(at: store.deletingLastPathComponent(), withIntermediateDirectories: true)
        let database = try AppDatabase.onDisk(url: store, key: key)
        _ = database.asRebindable().binding.lock()
        let older = store.deletingLastPathComponent()
            .appendingPathComponent("variorum-keys-\(KeyFingerprint.of(key)).json", isDirectory: false)
        let bytes = olderKeyFileBytes(key)
        try bytes.write(to: older)
        return (older, bytes)
    }

    @Test func theLiveSlotSaysRuleTwentySevensRefusalAndTouchesNothing() async throws {
        let road = PlantedRoad()
        let planted = try plantPreDesignLibrary(at: road.slot.places.slot)
        let storeBefore = try Data(contentsOf: road.slot.places.slot)

        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("a store from before this design meets the lobby, never a crash or a guess")
            return
        }
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false), "rule 27's refusal: \(face)")
        #expect(!face.passphraseField && face.wordsRoad == .none && !face.touchIDButton,
                "no typed or Touch ID road is offered that could not open it")
        #expect(ProtectionWords.noKeyFileAnywhere.hasPrefix("No key file opens this library."),
                "the sentence the face says (§7c (3)) — never a claim that no key file exists")
        #expect(try Data(contentsOf: planted.olderKeyFile) == planted.olderBytes, "the older key file is only read")
        #expect(try Data(contentsOf: road.slot.places.slot) == storeBefore, "the store is only read")
        #expect(!FileManager.default.fileExists(atPath: road.slot.places.liveKeyFile.path), "nothing minted on a guess")
    }

    @Test func aPickedPreDesignCopyIsNamedNeverCalledKeyless() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx329-u1-predesign-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let withKeyFile = root.appendingPathComponent("from-the-old-build", isDirectory: true)
        _ = try plantPreDesignLibrary(at: withKeyFile.appendingPathComponent("variorum.sqlite"))
        #expect(PickedCopy.classify(withKeyFile) == .refused(ProtectionWords.pickedCopyUnreadable, detail: nil),
                "named as a library with a key file this build can't read")
        #expect(PickedCopy.classify(withKeyFile.appendingPathComponent("variorum.sqlite"))
            == .refused(ProtectionWords.pickedCopyUnreadable, detail: nil), "the store itself, picked")

        let bare = root.appendingPathComponent("no-key-file", isDirectory: true)
        let planted = try plantPreDesignLibrary(at: bare.appendingPathComponent("variorum.sqlite"))
        try FileManager.default.removeItem(at: planted.olderKeyFile)
        #expect(PickedCopy.classify(bare) == .refused(LibraryOpenCopy.bareStoreRefusal, detail: nil),
                "with no key file at all, the keyless refusal is the honest one")
    }
}
