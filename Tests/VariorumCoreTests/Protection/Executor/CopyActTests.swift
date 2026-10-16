//
//  CopyActTests.swift
//  VariorumCoreTests — VX-305 U3: the copy acts (design §3.7) — Send Library,
//  the plaintext export, the offer's delete. (Opening a copy into this
//  library's own line and the landing left with rule 17 — VX-378 U1.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — Send Library, the plaintext export, the offer's delete")
struct SmallCopyActTests {
    @Test func sendLibraryWritesThePairWithNoSharingNote() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let outcome = try await executor.sendLibrary(&library, to: "hand-off")
        #expect(outcome.done.isEmpty && outcome.notices.isEmpty)
        let sent = try #require(fixture.world.sent["hand-off"])
        #expect(sent.fingerprint == PF.fp(fixture.key) && sent.keyFile == fixture.world.liveFormat3)
        expectSettled(fixture, library)
    }

    @Test func aPlaintextExportInCastleTakesThePassphrase() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.plaintextExport(&library, typed: .none, to: "out")
        }
        _ = try await executor.plaintextExport(&library, typed: TypedSecrets(passphrase: fixture.passphrase), to: "out")
        #expect(fixture.world.exports == ["out"])
    }

    @Test func theOfferDeletesOnlyThisMacsCopiesOfAnotherLibraryAndTheLastCopysAppleKey() async throws {
        let fixture = try EX(.castle)
        let other = "cccc3333-0000-4000-8000-000000000003"
        let otherKey = AppleKeyMaterial.mint()
        fixture.world.icloud.keys[otherKey.id] = otherKey
        let otherLibraryKey = StoreKey.mint()
        let own = try KeyFile(libraryID: other, key: otherLibraryKey, epoch: 1).settingApple(otherKey, for: otherLibraryKey)
        fixture.world.ownKeyFiles[other] = own
        let mine = CatalogCopy(
            id: "c:mine", place: .container, folders: [], name: "a", kind: .backup, stamp: PF.t0, nameFingerprint8: nil,
            servingKeyFiles: [], fingerprint: nil, candidateFingerprints: [], library: other, mac: .thisMacsContainer)
        var anotherMacs = mine
        anotherMacs.id = "f:theirs"
        anotherMacs.mac = .mac8("ffffffff")
        var thisLibrarys = mine
        thisLibrarys.id = "c:ours"
        thisLibrarys.library = fixture.libraryID
        for copy in [mine, anotherMacs, thisLibrarys] { fixture.world.copies[copy.id] = fixture.world.live }
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.offerDelete(
            &library, copies: [mine, anotherMacs, thisLibrarys], catalog: Catalog(copies: [mine, anotherMacs, thisLibrarys]))
        #expect(fixture.world.copies["c:mine"] == nil)
        #expect(fixture.world.copies["f:theirs"] != nil && fixture.world.copies["c:ours"] != nil)
        #expect(fixture.world.icloud.keys[otherKey.id] == nil)
    }
}
