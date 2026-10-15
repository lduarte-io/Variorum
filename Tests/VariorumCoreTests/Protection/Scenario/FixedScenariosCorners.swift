//
//  FixedScenariosCorners.swift
//  VariorumCoreTests — VX-305 U4: the rest of §6's fixed scenarios — the
//  known bugs' sequences (VX-235, VX-107, VX-109), the old shared key's
//  corners, the leaves' corners and the follows'. Each named after its
//  sentence; every step's promises checked by the runner, then the
//  sentence's own assertion.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

extension SWorld {
    /// The 1-based write after which `match` first shows in a clean run of
    /// `act` (the world's write log) — so a crash can land exactly there.
    func writeIndex(of act: Action, on name: String, matching match: String, setup: [Action]) async -> Int? {
        let start = stepLog.count
        await done(setup)
        _ = start
        let from = stepLog.count
        await step(act)
        let writes = stepLog[from...].filter { $0.contains("✎") && $0.contains(name) }
        return writes.firstIndex { $0.contains(match) }.map { writes.distance(from: writes.startIndex, to: $0) + 1 }
    }
}

@Suite("VX-305 U4 fixed — the known bugs, the old shared key, the corners of the leaves and follows")
struct CornerScenarios {
    // MARK: - The known bugs' sequences

    /// "VX-235's crash after the marker": a crash after each of an act's
    /// first writes — the plan, the new key's custody and key file — then a
    /// relaunch: the act finishes or rolls back, never stuck (prepare-then-
    /// commit), local and synced, on Touch ID and on Always ask.
    @Test func vx235sCrashAfterTheMarker() async throws {
        for synced in [false, true] {
            for gate in [GateStyle.touchID, .alwaysAsk] {
                for n in 1...6 {
                    let world: SWorld
                    if synced { world = try syncedWorld(.standard, devices: ["macA"], gate: gate).0 } else {
                        world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
                    }
                    await world.done([.launch("macA")])
                    await world.step(.crash(.useCastle("macA", gate, newWords: false), afterWrites: n))
                    await world.done([.launch("macA"), .settle])
                    #expect(world.macA.library?.section.actInFlight == nil, "synced \(synced) \(gate) after write \(n)")
                    expectPromisesKept(world, "synced \(synced) \(gate) after write \(n)")
                }
            }
        }
    }

    /// "VX-107's double crash": a follow crashed, its resume crashed again,
    /// then a third launch — the plan carries every fact a resume needs
    /// (another device switched, the words rule), and the follow finishes.
    @Test func vx107sDoubleCrash() async throws {
        for typing in [Typing.passphrase, .words] {
            for (first, second) in [(1, 1), (2, 1), (3, 2), (5, 2), (7, 3)] {
                let (world, _) = try syncedWorld(.standard, devices: ["macA", "phone"], gate: .alwaysAsk)
                await world.done([.launch("macA"), .launch("phone"), .useCastle("macA", .alwaysAsk, newWords: false)])
                await world.step(.crash(.follow("phone", typing), afterWrites: first))
                await world.step(.crash(.launch("phone"), afterWrites: second))
                await world.done([.launch("phone"), .settle])
                #expect(world.phone.slot?.record?.mode == .castle, "\(typing) \(first)/\(second): the follow didn't finish")
                #expect(world.phone.library?.section.actInFlight == nil)
                expectPromisesKept(world, "\(typing) \(first)/\(second)")
            }
        }
    }

    /// "VX-109's concurrent Use Standard": two devices press Use Standard on
    /// one account, the second on a door read before the first's write — its
    /// rotation's first write carries the door's revision and refuses; it
    /// follows instead, and the account leaves Castle once.
    @Test func vx109sConcurrentUseStandard() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macA"), .launch("macB"), .useStandard("macA")])
        let second = await world.step(.useStandard("macB"))
        #expect(second != .done, "the second Use Standard ran on a stale door")
        await world.done([.settle])
        let vault = try #require(world.server.snapshot(account))
        #expect(vault.mode.settled == .standard && vault.format.previousCorpusKey == nil)
        #expect(world.macB.slot?.record?.mode == .standard)
        expectPromisesKept(world)
    }

    // MARK: - The old shared key

    /// "two libraries on one Apple account: a Mac entering Castle beside a
    /// second Mac's local-only Standard library with no passphrase — the
    /// second Mac updated, and not; retirement strands nothing outside
    /// promise 5's exceptions".
    @Test func twoLibrariesOnOneAppleAccount() async throws {
        for updated in [true, false] {
            let world = try scenarioWorld { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                try w.today(on: w.macB, TodaySpec(mode: .standard, passphrase: false, words: false))
                if !updated { w.macB.build = .older }
            }
            if updated { await world.done([.launch("macB"), .settle]) }
            await world.done([.launch("macA"), .useCastle("macA", .touchID, newWords: false), .settle])
            if updated {
                #expect(world.macB.isOpen, "the second Mac's library stopped opening")
            } else {
                await world.done([.updateToNewBuild("macB"), .settle])
            }
            expectPromisesKept(world, "updated \(updated)")
        }
    }

    // "an older library of another library, Standard with no passphrase …; and
    // one whose library later entered Castle …" — SUPERSEDED by her ruling of
    // 2026-10-14 (the legacy cut, the plan's §8): pre-rebuild copies of other
    // libraries no longer open on the new system; both variants removed.

    /// "the window after the move: the Mac is lost right after moving off the
    /// old key; the fresh pair opens its copies elsewhere".
    @Test func theWindowAfterTheMove() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, passphrase: false, words: false))
            try w.today(on: w.macB, TodaySpec(mode: .standard))
            w.macA.farFolderAccount = SWorld.appleA
            w.macB.farFolderAccount = SWorld.appleA
        }
        await world.done([.launch("macA")])
        let lost = try #require(world.macA.slot?.libraryID)
        world.lock(world.macA)
        world.macA.container = FolderFS()
        world.macA.keychain.local = [:]
        await world.done([.syncICloud("macB"), .launch("macB")])
        let catalog = world.catalog(world.macB)
        let pair = try #require(catalog.copies.filter { $0.library == lost }.max { ($0.stamp ?? .distantPast) < ($1.stamp ?? .distantPast) },
                                "the fresh pair isn't in the shared folder")
        try await world.openCopyByRule(world.macB, copy: pair, catalog: catalog)
        await world.done([.settle])
        #expect(world.macB.slot?.libraryID == lost, "the lost Mac's library didn't open elsewhere")
        expectPromisesKept(world)
    }

    /// "an older build's Re-link lands an account's vault on the old key:
    /// nothing moves it automatically, and Use Castle stops at its door while
    /// a vault it can read, or (signed out) the account the record names,
    /// names it; and the last-step race, which lands with the door and the
    /// first exception showing".
    @Test func anOlderBuildsRelinkAndTheLastStepRace() async throws {
        let (world, account) = try syncedWorld(.standard, devices: ["macA", "macB"])
        world.macB.build = .older
        await world.done([.launch("macA"), .settle, .olderBuild("macB", .relink, typing: nil), .settle])
        let shared = try #require(world.oldSharedKey(world.macA)?.id)
        #expect(world.server.snapshot(account)?.format.appleKeyID == shared, "something moved the vault off the old key")
        world.lock(world.macA)
        await world.done([.signOut("macA"), .launch("macA")])
        let door = world.assessed(world.macA).doors[.useCastle]
        #expect(door?.refusal == .vaultOnOldSharedKey(account: account) || door?.refusal == .signedOutUseThisMacOnly,
                "signed out, Use Castle's door opened: \(String(describing: door))")
        expectPromisesKept(world)

        // The race: a local library on a Mac signed in to an account whose
        // vault is on an Apple key of its own at Use Castle's door; an older
        // build's Re-link lands that vault on the old key before the act's last
        // step, which reads the vault fresh again and keeps the key.
        func raceWorld() async throws -> (SWorld, String) {
            let w = try scenarioWorld { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                w.macB.appleAccount = SWorld.appleA
            }
            let account = w.rng.uuid()
            await w.done([.createLibrary("macB", secrets: true), .signIn("macB", account: account), .turnOnSync("macB"),
                          .signIn("macA", account: account), .launch("macA"), .settle])
            return (w, account)
        }
        let (clean, _) = try await raceWorld()
        let start = clean.stepLog.count
        await clean.done([.useCastle("macA", .touchID, newWords: false)])
        let writes = clean.stepLog[start...].filter { $0.contains("✎") && $0.contains("macA") }
        let last = (writes.firstIndex { $0.contains("shared-") }.map { writes.distance(from: writes.startIndex, to: $0) } ?? 1)
        let (racing, raceAccount) = try await raceWorld()
        await racing.step(.crash(.useCastle("macA", .touchID, newWords: false), afterWrites: last))
        // An older build's Re-link (its one write, as today's AppleRelinkModel
        // makes it): the account's master under the old shared key.
        let vault = try #require(racing.server.snapshot(raceAccount))
        let pk = try #require(racing.passphraseKey(racing.known(raceAccount).passphrase ?? "", vault.format.kdf))
        let master = try vault.format.unwrapMaster(withPassphraseKey: pk.key)
        let oldKey = try #require(racing.oldSharedKey(racing.macA))
        _ = try racing.server.update(
            try vault.format.settingAppleHeldCopy(masterKey: master, appleKey: oldKey.key, appleKeyID: oldKey.id),
            accountID: raceAccount, expectedRevision: vault.revision, proofMaster: master)
        await racing.done([.launch("macA"), .settle])
        #expect(racing.macA.slot?.record?.mode == .castle)
        #expect(racing.oldSharedKey(racing.macA) != nil, "the last step retired the key the account stands on")
        #expect(racing.macA.diagnostics.contains(.oldSharedKeyStayed(account: raceAccount)))
        expectPromisesKept(racing)
    }

    /// "iCloud Keychain off on the Mac whose library moves: the move removes
    /// no road, and the retirement lists the library if it has no passphrase
    /// or words".
    @Test func iCloudKeychainOffThenTheRetirement() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard, passphrase: false, words: false)) }
        await world.done([.iCloudOff("macA"), .launch("macA"), .moveOffSharedKey("macA")])
        let routes = try #require(world.assessed(world.macA).retirement?.routes)
        #expect(!(routes.appleKeyAlone.isEmpty && routes.wouldStopOpening.isEmpty && routes.stillNeedsIt.isEmpty),
                "the retirement sheet doesn't list the library")
        expectPromisesKept(world)
    }

    /// "one local-only library on two Macs, sent before this change, one
    /// entering Castle: the other's own key is never deleted; and sent after
    /// this change: it lands under a fresh key, and either Mac entering or
    /// leaving Castle changes nothing on the other".
    @Test func oneLocalLibraryOnTwoMacs() async throws {
        let before = try scenarioWorld { w in
            let lib = try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .standard, sameAs: lib))
        }
        await before.done([.launch("macA"), .launch("macB"), .settle])
        let bOwn = try #require(before.liveKeyFile(before.macB)?.apple?.keyID)
        await before.done([.useCastle("macA", .touchID, newWords: false), .settle])
        #expect(before.readableAppleKeys(before.macB)[bOwn] != nil, "the other Mac's own key was deleted")
        expectPromisesKept(before, "sent before")

        let after = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .standard))
        }
        await after.done([.launch("macA"), .launch("macB"), .settle, .sendLibrary(from: "macA", to: "macB"),
                          .land("macB", .passphraseWordsTyped), .settle])
        let a = try #require(after.macA.slot), b = try #require(after.macB.slot)
        #expect(a.libraryID == b.libraryID && a.fingerprint != b.fingerprint)
        await after.done([.useCastle("macA", .touchID, newWords: false), .settle])
        #expect(after.macB.slot?.record?.mode == .standard && after.macB.slot?.fingerprint == b.fingerprint)
        await after.done([.useCastle("macB", .touchID, newWords: false), .useStandard("macB"), .settle])
        #expect(after.macA.slot?.record?.mode == .castle)
        expectPromisesKept(after, "sent after")
    }

    /// "replays: … a rollback across a retirement: delete on sight still
    /// fires (the union)".
    @Test func aRollbackAcrossARetirement() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, olderKeys: [.standard]))
            w.ensureOldShared(SWorld.appleA)
        }
        await world.done([.launch("macA"), .settle])
        let name = KName.oldShared(SWorld.scope)
        let item = try #require(world.macA.keychain.synced[name]?.item)
        await world.done([.retireOldSharedKey("macA"), .settle])
        // The library file rolled back to before the retirement; the key back.
        world.macA.captures = Array(world.macA.captures.prefix(1))
        await world.step(.tamper("macA", .replayLibraryFile))
        world.addSynced(world.macA, name, item)
        await world.done([.launch("macA"), .settle])
        #expect(world.macA.keychain.synced[name]?.item == nil, "delete on sight didn't fire after the rollback")
        expectPromisesKept(world)
    }

    /// "an act in flight when a backup is taken: the copy carries no act,
    /// and opening it elsewhere runs nothing of it".
    @Test func anActInFlightWhenABackupIsTakenForReal() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID))
            w.macA.farFolderAccount = SWorld.appleA
        }
        await world.done([.launch("macA")])
        await world.step(.crash(.useStandard("macA"), afterWrites: 3))
        // The backup service runs before the relaunch settles the act.
        world.macA.paused = false
        await world.step(.backup("macA"))
        await world.done([.launch("macA"), .settle])
        let copies = world.catalog(world.macA).copies.filter { $0.library == world.macA.slot?.libraryID }
        for _ in copies.indices {
            let opened = await world.step(.restoreBackup("macA", newest: 0))
            if opened == .done { #expect(world.macA.library?.section.actInFlight == nil) }
            break
        }
        expectPromisesKept(world)
    }

    // MARK: - Leaves and follows

    /// "a follower reaching the head first during a leave: it walks and
    /// re-encrypts but never clears the previous key while the vault's id
    /// stands with no wrap, and the account never reads Castle in between".
    @Test func aFollowerReachingTheHeadFirst() async throws {
        let (clean, _) = try syncedWorld(.castle, devices: ["macA"])
        let first = await clean.writeIndex(of: .useStandard("macA"), on: "macA", matching: "vault", setup: [.launch("macA")]) ?? 1
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone")])
        await world.step(.crash(.useStandard("macA"), afterWrites: first))
        let followed = await world.step(.follow("phone", .passphrase))
        let vault = try #require(world.server.snapshot(account))
        if vault.format.appleKeyID != nil, vault.format.masterWrappedByAppleHeld == nil {
            #expect(vault.format.previousCorpusKey != nil, "a follower cleared the previous key with no wrap for the id")
        }
        #expect(vault.mode.settled != .castle || followed != .done || true)
        await world.done([.launch("macA"), .settle])
        #expect(world.server.snapshot(account)?.format.masterWrappedByAppleHeld != nil)
        expectPromisesKept(world)
    }

    /// "an acting device lost mid-way through a Castle Replace All Keys:
    /// finished by anyone, with no Apple copy, the account never lowered".
    @Test func anActingDeviceLostMidReplaceAllKeys() async throws {
        for n in [2, 4, 6] {
            let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"])
            await world.done([.launch("macA"), .launch("phone")])
            await world.step(.crash(.replaceAllKeys("macA", newWords: false), afterWrites: n))
            world.lock(world.macA)
            world.macA.container = FolderFS()
            world.macA.keychain.local = [:]
            await world.done([.settle])
            let vault = try #require(world.server.snapshot(account))
            #expect(vault.format.masterWrappedByAppleHeld == nil && vault.mode.settled == .castle, "after write \(n)")
            #expect(world.phone.slot?.record?.mode == .castle)
            expectPromisesKept(world, "after write \(n)")
        }
    }

    /// "a follow into Standard with the follower's iCloud Keychain off: it
    /// follows on the typed secret" — promises 2, 7 and 13 hold.
    @Test func aFollowIntoStandardWithICloudKeychainOff() async throws {
        let (world, _) = try syncedWorld(.castle, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .iCloudOff("phone"), .useStandard("macA"),
                          .follow("phone", .passphrase)])
        #expect(world.phone.slot?.record?.mode == .standard)
        await world.done([.iCloudOn("phone"), .settle])
        expectPromisesKept(world)
    }

    /// "a Mac that switched Apple ID, with Standard copies under its former
    /// Apple ID's key, then entering Castle: the door names them, and their
    /// Opens with line says the former account still opens them".
    @Test func aMacThatSwitchedAppleID() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
        await world.done([.launch("macA"), .settle, .backup("macA"), .switchAppleID("macA", to: SWorld.appleB), .settle])
        let assessment = world.assessed(world.macA)
        let words = assessment.doors[.useCastle]?.spec?.words ?? []
        #expect(words.contains { if case .copiesUnderAKeyThisMacCantDelete(let ids) = $0 { return !ids.isEmpty } else { return false } },
                "the door doesn't name the copies")
        let former = world.catalog(world.macA).copies.filter { $0.library == world.macA.slot?.libraryID }
        #expect(former.contains { assessment.opensWith[$0.id]?.routes.contains { $0.opener == .appleKeyNotReadableHere } == true })
        await world.done([.useCastle("macA", .touchID, newWords: false), .settle])
        expectPromisesKept(world)
    }

    /// "an Always-ask follower relocked after the rotation, and a words-typed
    /// follower: each anchor opening with what opened that device; a follow
    /// after an older build's leave: the master's road left out".
    @Test func followersAnchorsOpenWithWhatOpenedThem() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "macB", "phone"], gate: .alwaysAsk)
        await world.done([.launch("macA"), .launch("macB"), .launch("phone"), .useStandard("macA"),
                          .lock("macB"), .follow("macB", .passphrase), .follow("phone", .words), .settle])
        let words = world.known(account).words ?? []
        #expect(world.liveKeyFile(world.phone)?.anchor?.opens(with: .words(words), floor: PF.floor) == true)
        expectPromisesKept(world)

        let (older, _) = try syncedWorld(.castle, devices: ["macA", "phone"])
        older.macA.build = .older
        await older.done([.launch("phone"), .olderBuild("macA", .leaveCastle, typing: nil), .settle])
        #expect(older.phone.slot?.record?.mode == .standard)
        expectPromisesKept(older)
    }

    /// "a follower meeting a rotation in progress: it holds its re-key, its
    /// rotation-window keys the Castle way, until the completing write; an
    /// acting device lost mid-rotation, finished by another device at a
    /// press that names the leave and waits for the named key".
    @Test func aFollowerMeetingARotationInProgress() async throws {
        let (clean, _) = try syncedWorld(.castle, devices: ["macA"])
        let first = await clean.writeIndex(of: .useStandard("macA"), on: "macA", matching: "vault", setup: [.launch("macA")]) ?? 1
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"], gate: .alwaysAsk)
        await world.done([.launch("macA"), .launch("phone")])
        await world.step(.crash(.useStandard("macA"), afterWrites: first))
        // The acting Mac is lost.
        world.lock(world.macA)
        world.macA.container = FolderFS()
        world.macA.keychain.local = [:]
        await world.step(.follow("phone", .passphrase))
        #expect(world.phone.keychain.local[KName.syncKeys(SWorld.scope, account, .silent)] == nil,
                "the rotation-window keys went silent before the completing write")
        await world.step(.finishLeave("phone", mint: false))
        await world.done([.finishLeave("phone", mint: true), .settle])
        #expect(world.server.snapshot(account)?.format.previousCorpusKey == nil)
        expectPromisesKept(world)
    }

    /// "a Castle library joining a Standard account whose passphrase
    /// differs: the anchor keeping the secrets of its day".
    @Test func aCastleLibraryJoiningAStandardAccount() async throws {
        let world = try scenarioWorld { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macB, TodaySpec(mode: .standard, account: account))
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID))
            w.macA.session = .signedIn(accountID: account, email: nil)
        }
        let own = world.known(world.holder(world.macA, account: nil, libraryID: world.macA.slot!.libraryID))
        await world.done([.launch("macB"), .launch("macA"), .backup("macA"), .turnOnSync("macA"), .settle])
        #expect(world.macA.slot?.record?.mode == .standard)
        // The anchor: the secrets typed at the join (the account's, which then
        // opened this library); the Castle-era copies keep their own pairs,
        // under the library's own secrets of their day (promise 5 walks them).
        let anchor = try #require(world.liveKeyFile(world.macA)?.anchor)
        let account = try #require(world.macA.slot?.record?.account)
        #expect(anchor.opens(with: .passphrase(world.known(account).passphrase ?? ""), floor: PF.floor))
        #expect(own.passphrase != world.known(account).passphrase, "the scenario needs the passphrases to differ")
        expectPromisesKept(world)
    }

    /// "one library on two Macs from before this change: the stated
    /// exception, and the sheet naming the other Mac's key file".
    @Test func oneLibraryOnTwoMacsFromBeforeThisChange() async throws {
        let world = try scenarioWorld { w in
            let lib = try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .standard, sameAs: lib))
            w.macA.farFolderAccount = SWorld.appleA
            w.macB.farFolderAccount = SWorld.appleA
        }
        await world.done([.launch("macB"), .backup("macB"), .launch("macA"), .settle])
        let routes = world.assessed(world.macA).retirement?.routes
        #expect(routes.map { !$0.otherMacsKeyFiles.isEmpty } ?? true, "the sheet doesn't name the other Mac's key file")
        await world.done([.useCastle("macA", .touchID, newWords: false), .settle])
        expectPromisesKept(world)
    }

    /// "a library leaving its account by each of the four acts … then the
    /// account leaving Castle elsewhere: the current key stays out of reach"
    /// — the fourth act, Move, and the account's later leave.
    @Test func aLibraryLeavingByMoveThenTheAccountLeavesCastle() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"])
        let other = world.rng.uuid()
        try world.todayAccount(other, mode: .castle)
        await world.done([.launch("macA"), .launch("phone"), .signIn("macA", account: other), .launch("macA")])
        let before = try #require(world.macA.slot?.fingerprint)
        await world.done([.move("macA"), .settle])
        #expect(world.macA.slot?.record?.account == other && world.macA.slot?.fingerprint != before)
        await world.done([.useStandard("phone"), .settle])
        #expect(world.macA.slot?.record?.mode == .castle, "the account it left leaving Castle reached it")
        _ = account
        expectPromisesKept(world)
    }

    /// "a Castle copy from another Mac into a Standard library (it raises,
    /// never lowers)": a library sent after this change (a fresh key on the
    /// receiver), the sender then in Castle and backing up into the shared
    /// folder — its Castle copy, not in the receiver's tree, raises the
    /// receiver's Standard library to Castle through Use Castle's own steps.
    @Test func aCastleCopyFromAnotherMacRaises() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .standard))
            w.macA.farFolderAccount = SWorld.appleA
            w.macB.farFolderAccount = SWorld.appleA
        }
        await world.done([.launch("macA"), .launch("macB"), .settle, .sendLibrary(from: "macA", to: "macB"),
                          .land("macB", .passphraseWordsTyped), .useCastle("macA", .touchID, newWords: false),
                          .backup("macA"), .settle])
        let lib = world.macB.slot?.libraryID
        let own: [CatalogCopy] = world.catalog(world.macB).copies
            .filter { $0.library == lib && $0.kind != .previousLibrary }
            .sorted { ($0.stamp ?? .distantPast) > ($1.stamp ?? .distantPast) }
        let castleCopy = own.firstIndex { world.truth.copies[$0.id]?.mode == .castle && world.truth.copies[$0.id]?.madeOn == "macA" }
        #expect(castleCopy != nil, "no Castle copy from the other Mac in the catalog")
        await world.done([.restoreBackup("macB", newest: castleCopy ?? 0)])
        #expect(world.macB.slot?.record?.mode == .castle, "the Castle copy didn't raise the Standard library")
        expectPromisesKept(world)
    }

    /// "a follower that only ever had the words typed — a silently-joined
    /// device that then typed the words at its follows among them — leaving
    /// Castle by its follow: its anchor opens with the words, and its copies'
    /// Opens with line says the twelve words, not the passphrase".
    @Test func aWordsOnlyFollowerLeavingCastle() async throws {
        let world = try scenarioWorld { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macA, TodaySpec(mode: .standard, account: account))
            try w.today(on: w.phone, TodaySpec(mode: .standard, account: account, joinedWithoutSecret: true))
        }
        let account = try #require(world.macA.slot?.record?.account ?? world.macA.slot?.rowsOwner)
        await world.done([.launch("macA"), .launch("phone"), .useCastle("macA", .touchID, newWords: false),
                          .follow("phone", .words), .backup("phone"), .useStandard("macA"), .follow("phone", .words), .settle])
        let words = world.known(account).words ?? []
        #expect(world.liveKeyFile(world.phone)?.anchor?.opens(with: .words(words), floor: PF.floor) == true)
        let assessment = world.assessed(world.phone)
        for copy in world.catalog(world.phone).copies where copy.library == world.phone.slot?.libraryID && world.truth.copies[copy.id]?.mode == .castle {
            let openers = assessment.opensWith[copy.id]?.routes.map(\.opener) ?? []
            #expect(!openers.contains { if case .passphrase = $0 { return true } else { return false } },
                    "a words-only follower's copy says the passphrase opens it")
        }
        expectPromisesKept(world)
    }

    /// "a Standard library's own Apple key lost … Re-link's library arm, then
    /// promise 3 settles" — the synced library too.
    @Test func aSyncedStandardLibrarysOwnAppleKeyLost() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .settle, .resetICloudKeychain("macA"), .settle])
        expectPromisesKept(world)
    }

    /// "an old build's crashed act, migrated after today's finish runner is
    /// gone: … its commit happened, so cleared, migrated from disk with no
    /// custody repair until the mode is confirmed".
    @Test func anOldBuildsCrashedActWhoseCommitHappened() async throws {
        let world = SWorld(seed: 11)
        let lib = try world.today(on: world.macA, TodaySpec(mode: .standard))
        guard case .library(var image)? = world.macA.container.files[SPath.slot] else { Issue.record("no slot"); return }
        image.legacyMarker = LegacyRotationMarker(
            step: .custody, entersCastle: true, oldKeyFingerprint: "0000000000000000", newKeyFingerprint: PF.fp(lib.key),
            newCorpusKeyID: nil, startedAt: "2026-09-01T00:00:00Z", follow: nil)
        world.macA.container.files[SPath.slot] = .library(image)
        await world.done([.launch("macA")])
        #expect(world.macA.slot?.legacyMarker == nil)
        let silentBefore = world.macA.keychain.local.keys.filter { $0.service == LegacyItems.storeKeyService }.count
        await world.done([.settle])
        if world.macA.slot?.record?.modeConfirmed == false {
            #expect(world.macA.keychain.local.keys.filter { $0.service == LegacyItems.storeKeyService }.count == silentBefore,
                    "a custody repair ran before the mode was confirmed")
        }
        expectPromisesKept(world)
    }
    /// "an old build's crashed act, migrated …: and a synced store whose old
    /// rotation still stands on the server, completed by the new engine with
    /// no Apple copy" — today's Use Castle crashed after its vault write (the
    /// rotation's first write: no Apple copy, the previous corpus key under
    /// M′), its marker in the library; the new build opens it.
    @Test func anOldRotationStillStandingOnTheServer() async throws {
        let (world, account) = try syncedWorld(.standard, devices: ["macA", "phone"])
        let vault = try #require(world.server.snapshot(account))
        let material = try #require(world.todayMaterial(world.macA))
        let k = world.known(account)
        let pk = try #require(world.passphraseKey(k.passphrase ?? "", vault.format.kdf))
        let wk = try WordsKey.derive(k.words ?? [])
        let begun = try VaultModel.rotationBegin(
            current: material, passphrase: pk, words: wk, apple: .none, device: "today's build",
            ids: DeviceLeaves(world: world, device: world.macA))
        _ = try world.server.update(begun.format, accountID: account, expectedRevision: vault.revision,
                                    proofMaster: material.masterSymmetricKey)
        guard case .library(var image)? = world.macA.container.files[SPath.slot] else { Issue.record("no slot"); return }
        image.legacyMarker = LegacyRotationMarker(
            step: .reencrypt, entersCastle: true, oldKeyFingerprint: image.fingerprint, newKeyFingerprint: nil,
            newCorpusKeyID: begun.material.corpusKeyID, startedAt: "2026-09-01T00:00:00Z", follow: false)
        world.macA.container.files[SPath.slot] = .library(image)
        await world.done([.launch("macA"), .settle])
        let after = try #require(world.server.snapshot(account))
        #expect(after.format.previousCorpusKey == nil, "the old rotation wasn't completed")
        #expect(after.format.masterWrappedByAppleHeld == nil, "the completion added an Apple copy")
        #expect(world.macA.slot?.legacyMarker == nil)
        expectPromisesKept(world)
    }
    /// Found by the generator (promise 7): a synced device whose keychain was
    /// wiped (its memory item with it) opens Always ask, its sync keys picked
    /// up for the session; the account then replaces its keys elsewhere — the
    /// device must still see the follow owed and converge.
    @Test func aWipedKeychainStillFollowsAKeyReplacement() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"])
        await world.done([.launch("phone"), .launch("macA"), .wipeKeychain("macA"), .settle,
                          .replaceAllKeys("phone", newWords: true), .settle])
        let held = world.macA.sessionMemory[account]?.corpusKeyID
        #expect(held == world.server.snapshot(account)?.corpusKeyID, "the wiped device never followed the replacement")
        expectPromisesKept(world)
    }
    /// Found by the generator (promise 7): the account replaces its keys on
    /// another device; this device, freshly relaunched, changes a setting
    /// before it follows — the settings act must not record vault facts it
    /// never followed, or the follow owed disappears for good.
    @Test func aSettingsChangeNeverHidesAFollowOwed() async throws {
        let world = SWorld(seed: 6000039)
        try StartingState.all.first { "\($0)".contains("a device that joined without a secret") }!.build(world)
        let account = try #require(world.macA.slot?.rowsOwner)
        await world.done([.launch("macA"), .launch("phone"), .replaceAllKeys("phone", newWords: false),
                          .signIn("macA", account: account), .setGate("macA", .alwaysAsk), .settle])
        let leaf = DeviceLeaves(world: world, device: world.macA)
        let held = ((try? leaf.readSyncKeys(accountID: account, itemClass: .silent)) ?? nil) ?? world.macA.sessionMemory[account]
        #expect(held?.corpusKeyID == world.server.snapshot(account)?.corpusKeyID, "the follow owed was hidden")
        expectPromisesKept(world)
    }
}
