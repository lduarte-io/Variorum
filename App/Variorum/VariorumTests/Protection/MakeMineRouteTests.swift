//
//  MakeMineRouteTests.swift
//  VariorumTests — VX-306 U3 piece 2: MAKE THIS MY LIBRARY end to end through `AppBootstrap` (the one switch turned on
//  by a test harness) on a temp slot and a THROWAWAY keychain scope (the real custody and memory leaves; an in-memory
//  Apple leaf). The swap's precondition held by the bootstrap's own seam — the `.ready` tree down and the app's pool
//  CLOSED through the binding before the act — then the restore hold beside the new library, the reopen THROUGH THE
//  NEW ROAD with the new key, and §7c (9)'s receipt owed once to the reopened session's status seam; and a typo that
//  never tears the window down. Mac only (the keychain); the same act over planted leaves is `MakeMineRoadTests`'.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U3 — Make this my library through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct MakeMineRouteTests {
    @Test func makeThisMyLibraryClosesThePoolSwapsHoldsAndReopensOnTheNewRoadWithTheReceipt() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (created, words) = try await world.created()
            let oldID = try #require(created.library.record?.libraryID)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            // Rule 5's pair, by the backup hook's own road.
            #expect(ProtectionBackupHook.takePair(session) == .written)
            let roads = try #require(bootstrap.copyDoorsRoads(), "the doors exist on the new road at ready")
            let listing = await roads.listing()
            let row = try #require(listing.thisLibrary.first)
            #expect(roads.passphraseSet() == false)
            #expect(await roads.opensQuietly(row.copy), "this Mac's silent item holds the backup's key")
            let pair = TypedSecrets(words: words)
            let outcome = await bootstrap.makeThisMyLibrary(row, copySecrets: pair, currentPair: pair)
            #expect(outcome == .made)
            guard case .ready = bootstrap.state, let reopened = bootstrap.roadSession else {
                Issue.record("the reopen lands ready on the new road: \(bootstrap.state)")
                return
            }
            #expect(reopened !== session, "a fresh open's session")
            let newID = try #require(reopened.library.record?.libraryID)
            #expect(newID != oldID && reopened.key != created.key)
            #expect(reopened.library.record?.mode == .standard)
            #expect(LibraryRestoreHold.isHeld(besideStore: world.slotURL), "the restore hold stands beside the new library")
            let aside = CopyDoorsPlant.asideFolders(world.slot.places)
            #expect(aside.count == 1)
            if let folder = aside.first {
                #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: created.key))
                #expect(FileManager.default.fileExists(atPath: folder.appendingPathComponent(ProtectionNames.keyFilename).path))
            }
            // Today's store id beside the new library is a fresh one, under the new key.
            guard case .known = StoreIdentity.resolve(besideStore: world.slotURL) else {
                Issue.record("a store id beside the new library")
                return
            }
            #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.slotURL)?.keyFingerprint == reopened.library.fingerprint)
            // §7c (9), owed once to the reopened session's status seam.
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            #expect(spoken.filter { $0 == ProtectionWords.makeMineReceipt }.count == 1, "\(spoken)")
            standing.speakOwedReceipts()
            #expect(spoken.filter { $0 == ProtectionWords.makeMineReceipt }.count == 1, "said once")
        }
    }

    /// A wrong word is refused BEFORE anything closes: the library stays open on the same session, nothing held.
    @Test func aWrongWordNeverTearsTheWindowDown() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (_, words) = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            #expect(ProtectionBackupHook.takePair(session) == .written)
            let roads = try #require(bootstrap.copyDoorsRoads())
            let listing = await roads.listing()
            let row = try #require(listing.thisLibrary.first)
            let wrong = TypedSecrets(words: try RecoveryPhrase.generate())
            let outcome = await bootstrap.makeThisMyLibrary(row, copySecrets: TypedSecrets(words: words), currentPair: wrong)
            #expect(outcome == .refused(.wordsDoNotOpen))
            guard case .ready = bootstrap.state else {
                Issue.record("still ready: \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadSession === session, "never torn down")
            #expect(!LibraryRestoreHold.isHeld(besideStore: world.slotURL))
            #expect(CopyDoorsPlant.asideFolders(world.slot.places).isEmpty)
        }
    }
}
