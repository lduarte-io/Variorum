//
//  CutPinsTests.swift
//  VariorumCoreTests — VX-378 U1: THE CUT'S BEHAVIOUR PINS. Each was written
//  BEFORE its cut and seen red on the pre-cut tree (the record in the plan's
//  §8 U1 RECORD names the red run), then green after. A pure deletion needs no
//  pin; these are the deletions that change what an act does.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U1 — the cut's behaviour pins (red on the pre-cut tree)")
struct CutPinsTests {
    /// RULE 4 (`notes/CastleRules.md`): "every key change carries that list
    /// forward — no exceptions". Leaving Castle (Use Standard) mints a new
    /// Standard key whose key file's history holds the outgoing Castle key —
    /// so the current passphrase or words open the Castle-era copies (rule
    /// 12). The anchor and the leave's empty history were the exception.
    @Test func leavingCastleCarriesTheHistory() async throws {
        let fixture = try EX(.castle)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        let k1 = library.key
        #expect(k1 != k0 && fixture.liveRecord?.mode == .standard)
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0,
                "the leave's new key file must carry the outgoing Castle key in its history (rule 4)")
    }

    /// RULE 4 again, on a follower: a device following its account out of
    /// Castle carries its outgoing Castle key into the new Standard key's
    /// history (rule 12: "a new Standard key carrying every earlier key").
    @Test func aFollowOutOfCastleCarriesTheHistory() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let k0 = phone.key
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        _ = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
        let k1 = library.key
        #expect(k1 != k0 && phone.liveRecord?.mode == .standard)
        #expect(try phone.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0,
                "the follow's new key file must carry the outgoing Castle key in its history (rule 4)")
    }

    /// RULE 12 (the stuck leave cut): the leave's account write never leaves
    /// the vault in the id-with-no-wrap window that only a device reading the
    /// named key could close. Crashed right after its first vault write, a
    /// synced Use Standard leaves the vault reading Standard already.
    @Test func aCrashedLeaveNeverLeavesTheVaultWaitingForANamedKey() async throws {
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        let firstVaultWrite = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        let fixture = try EX(.castle, synced: true)
        fixture.world.crashAfterWrites = firstVaultWrite + 1
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: SimulatedCrash.self) { _ = try await executor.useStandard(&library, typed: fixture.typed) }
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        #expect(vault.mode == .standard,
                "a leave's vault write left the account short of Standard — the stuck leave's window (rule 12)")
    }
}

@Suite("VX-378 U1 — rule 21: no repair by guessing (red on the pre-cut tree)")
struct CutPinsRule21Tests {
    /// RULE 1 + RULE 21: the sealed mirror is the redundant copy, restored
    /// ONLY into an empty live place. A live key file that lost a lock is not
    /// rewritten from the mirror by a repair (the old `mirrorHoldsMore` arm).
    @Test func aLiveKeyFileThatLostALockIsNotRewrittenFromTheMirror() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.keyFileMirror = world.liveFile
        world.memory = memory
        world.liveFile.words = nil
        #expect(!(try world.assessed().repairs.contains(.restoreKeyFileFromMirror)),
                "a present live key file was owed a rewrite from the mirror")
    }

    /// RULE 21: another key's file in the live place is never overwritten —
    /// neither from the mirror nor from a catalogued copy.
    @Test func anotherKeysFileInTheLivePlaceIsNotOverwrittenByARepair() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.keyFileMirror = world.liveFile
        world.memory = memory
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: StoreKey.mint(), epoch: 9, locks: NewKeyLocks(passphrase: world.world.p, words: world.world.w))
        let restores = try world.assessed().repairs.filter { "\($0)".hasPrefix("restoreKeyFile") }
        #expect(restores.isEmpty, "a repair would overwrite the stray: \(restores)")
    }

    /// RULE 21, at the executor: the mirror's restore never writes over a file
    /// in the live place.
    @Test func theMirrorsRestoreNeverWritesOverAFileInTheLivePlace() async throws {
        let fixture = try EX(.standard)
        var present = try #require(fixture.world.liveFormat3)
        present.words = nil
        fixture.world.liveKeyFile = present
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.runRepairs([.restoreKeyFileFromMirror], on: &library)
        #expect(fixture.world.liveFormat3 == present, "the restore wrote over the file in the live place")
    }

    /// RULE 21 ("it never repairs by guessing"): with the live key file AND
    /// its mirror gone, no repair puts a catalogued copy's key file in the
    /// live place (rule 27's honest outcome is U2's refusal).
    @Test func noRepairRestoresTheLiveKeyFileFromACopy() throws {
        var world = try AWorld(.castle)
        world.memoryAbsent = true
        let frozen = world.liveFile
        let folders = CF.macFolder(world.world.library, CF.macA)
        world.extraEntries = [
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(2), world.key)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(2), world.key), bytes: try frozen.encoded()),
        ]
        var facts = try world.facts()
        facts.catalog = Catalog.build(Array(try world.entries().dropFirst()))
        let restores = assess(facts).repairs.filter { "\($0)".hasPrefix("restoreKeyFile") }
        #expect(restores.isEmpty, "a repair would restore the live key file from a copy: \(restores)")
    }

    /// RULE 21: a library file older than what this Mac remembers is not
    /// re-encrypted under the memory's key by the open ("memory wins" — the
    /// older-library-file re-key). U2 refuses instead.
    @Test func aLibraryFileReplayedAloneIsNotReKeyedToTheMemorysKey() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.launch("macA"), .useCastle("macA", .alwaysAsk, newWords: false)])
        let castleKey = try #require(world.macA.slot?.fingerprint)
        await world.step(.tamper("macA", .replayLibraryFile))
        #expect(world.macA.slot?.fingerprint != castleKey, "the replayed file was re-keyed to the memory's key")
    }

}

@Suite("VX-378 U1 — rules 21 and 23: four remembered things, a plain device ID (red on the pre-cut tree)")
struct CutPinsRule23Tests {
    /// RULE 21 ("this Mac remembers four things about its library — its ID,
    /// its current key, its device ID and the sealed copy of its key file")
    /// and RULE 23 ("no hardware fingerprinting"): no stored value carries a
    /// hardware marker, its salt, a family tree, or a second home of this
    /// Mac's section.
    @Test func noStoredValueCarriesAMarkerATreeOrASecondHome() throws {
        let fixture = try EX(.standard)
        let record = try #require(fixture.liveRecord)
        let recordText = String(decoding: try ProtectionCoding.canonical(record), as: UTF8.self)
        #expect(!recordText.contains("markerSalt"), "the record carries a hardware marker's salt")
        #expect(!recordText.contains("familyTree"), "the record carries a family tree")
        for sealed in record.deviceSections {
            #expect(!String(decoding: sealed.payload, as: UTF8.self).contains("hardwareMarker"),
                    "a device section carries a hardware marker")
        }
        let memory = try #require(fixture.world.memories[fixture.libraryID])
        let memoryText = String(decoding: memory.payload, as: UTF8.self)
        for field in ["familyTree", "deviceSection", "hardwareMarker", "lastConfirmed"] {
            #expect(!memoryText.contains(field), "what this Mac remembers carries \(field)")
        }
    }

    /// RULE 23: the device ID is the plain random one this Mac remembers — a
    /// memory item carried onto new hardware keeps it (no marker decides a
    /// new identity, no takeover).
    @Test func aMemoryItemCarriedToNewHardwareKeepsItsDeviceID() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
        await world.done([.launch("macA")])
        let id = try #require(world.macA.library?.section.deviceID)
        await world.done([.replaceMac("macA", carriesMemory: true), .launch("macA")])
        #expect(world.macA.library?.section.deviceID == id, "the device ID was recomputed from the hardware")
    }
}

@Suite("VX-378 U1 — rule 16: leaving an account changes no keys (red on the pre-cut tree)")
struct CutPinsRule16Tests {
    /// RULE 16: "Leaving an account changes none of your library's keys or
    /// secrets — it stops syncing." Every leave, in both modes: the account
    /// unbound, the key and the key file's secret locks as they were.
    @Test func everyLeaveKeepsTheLibrarysKeyAndItsSecrets() async throws {
        for mode in ProtectionMode.allCases {
            for act in [ProtectionAct.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
                let fixture = try EX(mode, synced: true)
                let k0 = fixture.key
                let before = try #require(fixture.world.liveFormat3)
                let executor = fixture.executor()
                var library = try fixture.unlocked(executor)
                _ = try await executor.leaveAccount(act, &library)
                #expect(fixture.liveRecord?.account == nil, "\(mode) \(act): still bound")
                #expect(library.key == k0 && fixture.world.live?.fingerprint == PF.fp(k0), "\(mode) \(act): the key changed")
                let after = try #require(fixture.world.liveFormat3)
                #expect(after.passphrase == before.passphrase && after.words == before.words,
                        "\(mode) \(act): a secret's lock changed")
            }
        }
    }

    /// RULE 16 + RULE 7: Move is leaving one account (no key change) and
    /// joining another in the same mode (a re-lock, never a new key).
    @Test func movingToAnAccountInTheSameModeKeepsTheKey() async throws {
        let x = try EX(.standard, synced: true)
        let y = try EX(.standard, synced: true, world: ExecutorWorld(icloud: x.world.icloud, server: x.world.server))
        let k0 = x.key
        let executor = x.executor(session: y.session)
        var library = try x.unlocked(executor)
        _ = try await executor.move(&library, typed: TypedSecrets(passphrase: y.passphrase, words: y.words))
        #expect(x.liveRecord?.account == y.account)
        #expect(library.key == k0, "the move changed the library's key")
    }
}

@Suite("VX-378 U1 — rule 4: a quiet road opens only a key it holds directly (red on the pre-cut tree)")
struct CutPinsRule4QuietRoadTests {
    /// RULE 4: "Only typed secrets reach through the list; a quiet road opens
    /// only a key it directly holds." After a leave, this Mac's silent item and
    /// its Apple key hold the NEW key only: the Castle copy's sentence names no
    /// quiet road (the old route graph walked them through the history).
    @Test func aCastleCopyAfterALeaveNamesNoQuietRoad() throws {
        let world = try KeyWorld()
        let castleKey = StoreKey.mint(), standardKey = StoreKey.mint(), apple = AppleKeyMaterial.mint()
        let castleFile = try world.castleFile(castleKey)
        let standardFile = try castleFile.rekeyed(
            from: castleKey, to: standardKey, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: apple), at: CF.stamp(2))
        let folders = CF.macFolder(world.library, CF.macA)
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try standardFile.encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), castleKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), castleKey),
                         bytes: try castleFile.encoded()),
        ])
        let finder = RouteFinder(RouteFacts(
            catalog: catalog, custody: [CustodyItemFact(fingerprint: PF.fp(standardKey), itemClass: .silent)],
            readableAppleKeyIDs: [apple.id]))
        let copy = try #require(catalog.copies.first { $0.fingerprint == PF.fp(castleKey) })
        let sentence = "\(finder.opensWith(copy: copy))"
        #expect(!sentence.contains("thisMac") && !sentence.contains("appleAccount"),
                "a quiet road reached through the history: \(sentence)")
    }
}

@Suite("VX-378 U1 — rule 2: no library without a secret (red on the pre-cut tree)")
struct CutPinsRule2Tests {
    /// RULE 2: "There is no such thing as a library with no secret." A key
    /// file with no words lock is never a library whose words a door may take
    /// as new: words it can't verify are refused, never adopted (the
    /// secretless arm — "no words: the typed ones become the words").
    @Test func wordsTheKeyFileCannotVerifyAreNeverTakenAsTheLibrarysWords() async throws {
        let fixture = try EX(.standard)
        var live = try #require(fixture.world.liveFormat3)
        live.words = nil
        fixture.world.liveKeyFile = live
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.wordsDoNotOpen) {
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        }
        #expect(fixture.liveRecord?.mode == .standard)
    }
}
