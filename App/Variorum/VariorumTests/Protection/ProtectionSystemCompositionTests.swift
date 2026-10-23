//
//  ProtectionSystemCompositionTests.swift
//  VariorumTests — VX-306 U1a: THE COMPOSITION, ONCE END TO END (`notes/plans/vx-306-castle-open-road.md`
//  §2 U1a piece 5): on a temp slot and a THROWAWAY keychain scope, the real custody, memory and sync-keys
//  leaves and every file leaf — only the Apple keys stay in memory (the real iCloud leaf is the opt-in
//  suite's) — `createLibrary(passphrase:)` → the twelve words → a relaunch → the lobby's facts → `unlock`
//  through the silent item → `assess` → `.open`, with rule 21's four remembered things written; and the
//  words, typed on the key file beside the library, open it too.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1a — the protection system, composed end to end (throwaway scope, temp slot)", .serialized)
struct ProtectionSystemCompositionTests {
    static func system(_ slot: TempSlot, _ scope: ThrowawayScope, apple: InMemoryAppleKeysLeaf) -> ProtectionSystem {
        ProtectionSystem(
            scope: scope.scope, places: slot.places, deviceName: "Test Mac", floor: .relaxedForTests,
            syncKeys: KeychainSyncKeysLeaf(scope: scope.scope), apple: apple,  // VX-487 F-M1-1: handed, never defaulted
            biometry: FixedBiometryLeaf(.none), ids: FastIDsLeaf())
    }

    @Test func aLibraryIsCreatedWithItsWordsAndOpensThroughTheLobbyWithTheFourThingsRemembered() async throws {
        let slot = TempSlot()
        let scope = ThrowawayScope()
        defer { scope.purge() }
        let apple = InMemoryAppleKeysLeaf()

        // Stage 1 — the creation (rule 2: twelve words at birth, shown once; rule 3: no passphrase yet).
        let first = Self.system(slot, scope, apple: apple)
        #expect(assess(try first.facts(session: .signedOut)).launch == .startFresh)
        let created = try first.executor(session: .signedOut).createLibrary(passphrase: nil)
        #expect(created.words.count == 12)
        let libraryID = try #require(created.library.record?.libraryID)
        let key = created.library.key
        let fingerprint = KeyFingerprint.of(key)

        // What landed: the library under its key, the key file beside it with its words lock, the silent
        // item STAMPED with this library, the Apple key (in memory here) stamped too, the memory item.
        #expect(ProtectionLibraryFiles.opens(slot.places.slot, key: key))
        let liveFile = try #require(try first.leaves.keyFiles.readLiveKeyFile())
        #expect(liveFile.libraryID == libraryID && liveFile.opensWithTheWords && liveFile.passphrase == nil)
        #expect(try liveFile.open(words: created.words) == key, "the words open the key file beside the library")
        let custody = KeychainCustodyLeaf(scope: scope.scope)
        let items = try custody.custodyItems()
        #expect(items == [CustodyItemFact(fingerprint: fingerprint, itemClass: .silent)])
        #expect(items.first?.libraryID == libraryID)
        #expect(try apple.appleKeyIDs(ofLibrary: libraryID).count == 1)
        #expect(try KeychainMemoryLeaf(scope: scope.scope).rememberedLibraryIDs() == [libraryID])

        // A relaunch: a fresh system, the library ID from the live key file, the lobby's facts.
        let second = Self.system(slot, scope, apple: apple)
        #expect(second.configuration(session: .signedOut).libraryID == libraryID)
        let lobbyFacts = try second.facts(session: .signedOut)
        let lobby = assess(lobbyFacts)
        #expect(lobby.launch == .lobby)
        #expect(lobby.lobby.silentItems.map(\.fingerprint) == [fingerprint])
        #expect(!lobby.lobby.asksASecretAtOnce)
        #expect(lobby.lobby.noKeyFileAnywhere == nil)
        #expect(lobbyFacts.custodyOpensLibrary == [fingerprint])

        // The quiet road: the silent item's key, verified by the unlock itself.
        let executor = second.executor(session: .signedOut)
        let quiet = try #require(try second.leaves.custody.readCustody(fingerprint: fingerprint, itemClass: .silent))
        var library = try executor.unlock(with: quiet)
        #expect(library.notice == nil)
        _ = try await executor.settle(&library)
        var assessment = assess(try second.facts(session: .signedOut, unlocked: library))
        #expect(assessment.launch == .open)
        _ = try executor.runRepairs(assessment.repairs, on: &library)
        assessment = assess(try second.facts(session: .signedOut, unlocked: library))
        #expect(assessment.faults.isEmpty, "\(assessment.faults)")

        // RULE 21's four things, as this Mac remembers them.
        let sealed = try #require(try second.leaves.memory.readMemory(libraryID: libraryID))
        let remembered = try #require(DeviceMemory.opening(sealed, libraryID: libraryID) { $0 == fingerprint ? key : nil })
        #expect(remembered.libraryID == libraryID)
        #expect(remembered.currentFingerprint == fingerprint)
        #expect(remembered.deviceID == library.section.deviceID)
        #expect(remembered.keyFileMirror == liveFile)

        // The words, typed on the key file beside the library, open it too.
        let typed = try liveFile.open(.words(created.words))
        #expect(try executor.unlock(with: typed).record?.libraryID == libraryID)
    }
}
