//
//  MutationPins.swift
//  VariorumCoreTests — VX-305 U4: THE MUTATION PINS (the phase plan §6: "Each
//  fixed scenario that guards against a known bug runs once more with its
//  guard switched off (`ProtectionGuards`, DEBUG only) and must fail. That is
//  the red-on-old for new code."). Each pin runs its scenario twice on the
//  world: guarded, it keeps every promise and its own sentence; with the guard
//  off, it must fail — a promise broken or its sentence false. The failing
//  assertion each pin records is its `sentence`.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

#if DEBUG
/// Run `scenario` guarded and unguarded. It returns whether its own sentence
/// held; the world's violations count against it too.
func mutationPin(
    _ sentence: String, off: (inout ProtectionGuards) -> Void,
    sourceLocation: SourceLocation = #_sourceLocation,
    _ scenario: (ProtectionGuards) async throws -> (SWorld, Bool)
) async throws {
    let (guarded, holds) = try await scenario(.all)
    #expect(holds, "guarded: \(sentence) — false\n\(guarded.log)", sourceLocation: sourceLocation)
    expectPromisesKept(guarded, "guarded: \(sentence)", sourceLocation: sourceLocation)
    var guards = ProtectionGuards.all
    off(&guards)
    let (bare, bareHolds) = try await scenario(guards)
    let failed = !bareHolds || !bare.violations.isEmpty
    #expect(failed, "with the guard off, the scenario still passed: \(sentence)", sourceLocation: sourceLocation)
}

@Suite("VX-305 U4 — the mutation pins: each scenario fails with its guard off (DEBUG)")
struct ScenarioMutationPins {
    /// A planted plan, replayed from an earlier act: nothing named by this
    /// Mac's section resumes (VX-313).
    @Test func thePlantedPlan() async throws {
        try await mutationPin("a plan the record doesn't name changes nothing", off: { $0.planNamedBySection = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .alwaysAsk)) }
            await world.done([.launch("macA")])
            await world.step(.tamper("macA", .plantPlan))
            // A GENUINE plan of an earlier act (captured mid-act), written back:
            // it would turn the scheduled export on.
            let library = try #require(world.macA.library)
            let replay = ProtectionPlan(
                libraryID: library.record!.libraryID, deviceID: library.section.deviceID, sequence: 1, act: .deviceSettings,
                steps: [PlanStep(name: "settings")], createdAt: world.clock,
                parameters: ActParameters(settings: DeviceSettings(gateStyle: .alwaysAsk, scheduledExport: true)))
            world.macA.container.files[SPath.plan] = .plan(try replay.sealed(under: library.key))
            world.lock(world.macA)
            await world.step(.launch("macA"))
            return (world, world.macA.library?.section.settings.scheduledExport == false)
        }
    }

    /// The memory item replayed alone loses to the record (two homes).
    @Test func aReplayedMemoryItemChangesNothing() async throws {
        try await mutationPin("a memory item replayed alone changes nothing", off: { $0.twoHomes = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .alwaysAsk)) }
            await world.done([.launch("macA"), .setScheduledExport("macA", true), .setScheduledExport("macA", false)])
            // Replay the memory item from the export-on moment.
            let capture = world.macA.captures.last { capture in
                guard case .memory(let sealed)? = capture.memory?.value,
                      let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) else { return false }
                return memory.deviceSection.settings.scheduledExport
            }
            if let capture { world.macA.captures = [capture] }
            await world.step(.tamper("macA", .replayMemory))
            return (world, world.macA.library?.section.settings.scheduledExport == false)
        }
    }

    /// Two macOS logins on one Mac (VX-340): the second, with no memory item,
    /// never adopts the first login's section — its settings, its retired ids.
    @Test func theHardwareMarker() async throws {
        try await mutationPin("a Mac with no memory item finds only its own section", off: { $0.hardwareMarker = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
            await world.done([.launch("macA"), .setScheduledExport("macA", true)])
            let first = try #require(world.macA.library?.section.deviceID)
            // The same container opened by another login on the same hardware.
            world.macA.machine = MachineIdentity(hardware: world.macA.machine.hardware, login: world.rng.uuid().uppercased())
            world.macA.keychain.local = world.macA.keychain.local.filter { $0.key.service != ProtectionNames.memoryService }
            world.lock(world.macA)
            await world.done([.launch("macA")])
            return (world, world.macA.library?.section.deviceID != first)
        }
    }

    /// No repair ever makes a Touch ID item: a Touch ID choice with no item
    /// behind it records Always ask quietly (§3.10).
    @Test func noRepairMakesATouchIDItem() async throws {
        try await mutationPin("no repair makes a Touch ID item", off: { $0.noRepairMakesTouchID = false; $0.repairNeverMakesTouchIDItem = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
            await world.done([.launch("macA")])
            await world.step(.tamper("macA", .deleteTouchIDItem))
            let touchItems = world.macA.keychain.local.filter { $0.key.service == ProtectionNames.custodyService && $0.value.touchID }.count
            return (world, touchItems == 0 && world.macA.library?.section.settings.gateStyle == .alwaysAsk)
        }
    }

    /// No re-arm question without an existing item (§3.10).
    @Test func noRearmQuestionWithoutAnItem() async throws {
        try await mutationPin("no re-arm question without an item", off: { $0.noRearmWithoutItem = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
            await world.done([.launch("macA")])
            world.macA.keychain.local = world.macA.keychain.local.filter { !$0.value.touchID }
            return (world, !world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        }
    }

    /// The re-key at every crossing: a leave from an account in Standard
    /// re-keys, so nothing written after opens through the account (§3.8).
    @Test func theRekeyAtEveryCrossing() async throws {
        try await mutationPin("every leave re-keys", off: { $0.rekeyAtEveryCrossing = false }) { guards in
            let (world, _) = try syncedWorld(.standard, devices: ["macA"], guards: guards)
            await world.done([.launch("macA")])
            let before = try #require(world.macA.slot?.fingerprint)
            await world.done([.stopSyncingHere("macA", forgotPassphrase: false)])
            return (world, world.macA.slot?.fingerprint != before)
        }
    }

    /// The anchor carried by every re-key: after a leave, a change of
    /// passphrase and Replace-All-Keys-like re-keys keep the anchor, so copies
    /// from before the leave still open (promise 5).
    @Test func theAnchorCarriedByEveryRekey() async throws {
        try await mutationPin("the anchor rides every re-key", off: { $0.anchorCarriedByEveryRekey = false }) { guards in
            let (world, _) = try syncedWorld(.castle, devices: ["macA"], guards: guards)
            await world.done([.launch("macA"), .backup("macA"), .useStandard("macA"), .stopSyncingHere("macA", forgotPassphrase: false)])
            return (world, world.liveKeyFile(world.macA)?.anchor != nil)
        }
    }

    /// The family tree's two homes: a library file rolled back by Time Machine
    /// past a re-key — this library's later copies still read as its own.
    @Test func aTimeMachineRollbackPastARekey() async throws {
        try await mutationPin("its later copies still read as its own", off: { $0.familyTreeTwoHomes = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .timeMachineSnapshot("macA"), .useCastle("macA", .touchID, newWords: false),
                              .backup("macA"), .timeMachineRollback("macA"), .launch("macA")])
            let tree = world.macA.library?.familyTree
            let later = world.truth.copies.values.filter { $0.mode == .castle && $0.madeOn == "macA" }.map(\.fingerprint)
            return (world, !later.isEmpty && later.allSatisfy { tree?.contains($0) == true })
        }
    }

    /// The export-off step: entering Castle turns the scheduled export off
    /// here and on every device that follows.
    @Test func enteringCastleWithTheScheduledExportOn() async throws {
        try await mutationPin("the export turns off at Castle, and at the follow", off: { $0.exportOffAtCastle = false }) { guards in
            let (world, _) = try syncedWorld(.standard, devices: ["macA", "macB"], guards: guards)
            await world.done([.launch("macA"), .launch("macB"), .setScheduledExport("macA", true), .setScheduledExport("macB", true),
                              .useCastle("macA", .touchID, newWords: false), .settle])
            let off = [world.macA, world.macB].allSatisfy { $0.library?.section.settings.scheduledExport == false }
            return (world, off)
        }
    }

    /// Every own Apple key retired at entering Castle — the one Re-link's
    /// library arm minted beside a lost one included.
    @Test func reLinksLibraryArmThenUseCastle() async throws {
        try await mutationPin("both own keys retired", off: { $0.everyOwnKeyRetiredAtCastle = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .settle])
            let lost = try #require(world.liveKeyFile(world.macA)?.apple?.keyID)
            // The own key lost on this Mac (iCloud Keychain reset), Re-link's arm, then Castle.
            world.macA.keychain.synced[KName.apple(SWorld.scope, lost)] = nil
            await world.done([.relinkLibraryArm("macA"), .useCastle("macA", .touchID, newWords: false)])
            let retired = world.macA.library?.section.retiredAppleKeyIDs ?? []
            return (world, retired.contains(lost) && retired.count >= 2)
        }
    }

    /// The door-time vault check: an older build's Re-link lands an account's
    /// vault on the old shared key; Use Castle stops at its door while that
    /// vault names it.
    @Test func anOlderBuildsRelinkLandsTheVaultOnTheOldKey() async throws {
        try await mutationPin("Use Castle stops at its door", off: { $0.doorTimeVaultCheck = false }) { guards in
            let (world, account) = try syncedWorld(.standard, devices: ["macB"], guards: guards)
            try world.today(on: world.macA, TodaySpec(mode: .standard))
            world.macA.session = .signedIn(accountID: account, email: nil)
            world.macB.build = .older
            await world.done([.olderBuild("macB", .relink, typing: nil), .launch("macA")])
            let result = await world.step(.useCastle("macA", .touchID, newWords: false))
            return (world, result != .done && world.oldSharedKey(world.macA) != nil)
        }
    }

    /// The move keeps the old wrap (§3.5 point 2): the move only adds roads.
    @Test func theMoveRemovesNoRoad() async throws {
        try await mutationPin("the move keeps the old wrap", off: { $0.moveKeepsOldWrap = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA")])
            return (world, world.liveKeyFile(world.macA)?.sharedApple != nil)
        }
    }

    /// The fresh pair after the move: the newest pair carries every wrap.
    @Test func theFreshPairAfterTheMove() async throws {
        try await mutationPin("a fresh pair ends the migration's move", off: { $0.freshPairAfterMove = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA")])
            let pairs = world.truth.copies.values.filter { $0.madeOn == "macA" && !$0.byOlderBuild }
            return (world, !pairs.isEmpty)
        }
    }

    /// Gifts only for this Mac's copies (§3.5 point 2): another Mac's copies
    /// in a shared folder get no key file of this Mac's.
    @Test func giftsOnlyForThisMacsCopies() async throws {
        try await mutationPin("no gift for another Mac's copies", off: { $0.giftsOnlyForThisMacsCopies = false }) { guards in
            let world = try scenarioWorld(guards: guards) { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                try w.today(on: w.macB, TodaySpec(mode: .standard, passphrase: false, words: false))
                w.macA.farFolderAccount = SWorld.appleA
                w.macB.farFolderAccount = SWorld.appleA
            }
            await world.done([.launch("macB"), .backup("macB"), .launch("macA"), .moveOffSharedKey("macA")])
            let gifts = world.macA.container.files.keys.filter { $0.hasPrefix("Backups/") && $0.hasSuffix(SPath.liveKeyFile) }
            return (world, gifts.isEmpty)
        }
    }

    /// The cross-Mac prune (VX-302): retention never touches another Mac's
    /// copies in a shared iCloud Drive folder (promise 11).
    @Test func theCrossMacPrune() async throws {
        try await mutationPin("retention prunes only this Mac's copies", off: { $0.pruneOwnCopiesOnly = false }) { guards in
            let world = try scenarioWorld(guards: guards) { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                try w.today(on: w.macB, TodaySpec(mode: .standard))
                w.macA.farFolderAccount = SWorld.appleA
                w.macB.farFolderAccount = SWorld.appleA
            }
            await world.done([.launch("macB"), .backup("macB"), .launch("macA")])
            for _ in 0..<20 {
                world.advance(hours: 24)
                await world.done([.backup("macA")])
            }
            let macBsCopies = world.farFolders[SWorld.appleA]!.files.keys.filter { $0.hasSuffix(".sqlite") && !$0.contains("/\(world.macA.library!.section.mac8)/") }
            return (world, !macBsCopies.isEmpty)
        }
    }
    /// "the passphrase changed during Castle on another device, which then
    /// leaves Castle: a follower that never had the new passphrase typed
    /// follows typing it, and its anchor opens with it".
    @Test func aFollowersAnchorOpensWithTheSecretTypedAtItsFollow() async throws {
        try await mutationPin("the follower's anchor opens with the passphrase typed at its follow", off: { $0.followerAnchorTypedLock = false }) { guards in
            let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"], guards: guards)
            await world.done([.launch("phone"), .launch("macA"), .changePassphrase("macA"), .useStandard("macA"), .follow("phone", .passphrase)])
            let typed = world.known(account).passphrase ?? ""
            return (world, world.liveKeyFile(world.phone)?.anchor?.opens(with: .passphrase(typed), floor: PF.floor) == true)
        }
    }

    /// "Castle-kind custody through a leave's rotation on every device": a
    /// crash in the leave's window finds its sync keys the Castle way.
    @Test func castleKindCustodyThroughALeavesWindow() async throws {
        try await mutationPin("no silent sync keys in a leave's window", off: { $0.castleKindCustodyThroughLeave = false }) { guards in
            // The write after which the window's keys are filed, from a clean run.
            let (clean, _) = try syncedWorld(.castle, devices: ["macA"], gate: .alwaysAsk)
            await clean.done([.launch("macA")])
            let start = clean.stepLog.count
            await clean.done([.useStandard("macA")])
            let writes = clean.stepLog[start...].filter { $0.contains("✎") }
            let window = max(1, writes.firstIndex { $0.contains("reencrypt") } ?? 1)
            let (world, account) = try syncedWorld(.castle, devices: ["macA"], gate: .alwaysAsk, guards: guards)
            await world.done([.launch("macA")])
            await world.step(.crash(.useStandard("macA"), afterWrites: window))
            let silent = world.macA.keychain.local[KName.syncKeys(SWorld.scope, account, .silent)] != nil
            return (world, !silent)
        }
    }

    /// "a follower meeting a rotation in progress … never clears the previous
    /// key while the vault's id stands with no wrap" (the leave's id gating its
    /// completion).
    @Test func theLeavesIDGatesItsCompletion() async throws {
        try await mutationPin("the previous key stands while the id has no wrap", off: { $0.leaveIDGatesCompletion = false }) { guards in
            let (clean, _) = try syncedWorld(.castle, devices: ["macA"])
            await clean.done([.launch("macA")])
            let start = clean.stepLog.count
            await clean.done([.useStandard("macA")])
            let writes = clean.stepLog[start...].filter { $0.contains("✎") }
            let firstVault = (writes.firstIndex { $0.contains("vault") } ?? 0) + 1
            let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"], guards: guards)
            await world.done([.launch("macA"), .launch("phone")])
            await world.step(.crash(.useStandard("macA"), afterWrites: firstVault))
            // The named key never reaches the phone (macA never synced).
            await world.step(.follow("phone", .passphrase))
            let vault = try #require(world.server.snapshot(account))
            let leaving = vault.format.appleKeyID != nil && vault.format.masterWrappedByAppleHeld == nil
            return (world, !leaving || vault.format.previousCorpusKey != nil)
        }
    }

    /// "the old key's fold, then retirement — no stranded copy": the
    /// retirement runs the moves again, so another library's copy keeps a road
    /// of this Mac's own when the old shared key goes.
    @Test func theRetirementRerunsTheMoves() async throws {
        try await mutationPin("another library's copy keeps a road of this Mac's own", off: { $0.retirementRerunsMoves = false }) { guards in
            let world = try scenarioWorld(guards: guards) { w in
                try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, olderKeys: [.standard]))
                w.ensureOldShared(SWorld.appleA)
            }
            await world.done([.launch("macA")])
            try world.todayOtherLibrary(on: world.macA, mode: .standard, passphrase: false, words: false)
            await world.done([.retireOldSharedKey("macA"), .settle])
            let gifts = world.macA.container.files.keys.filter { $0.hasPrefix("Backups/") && $0.hasSuffix(SPath.liveKeyFile) }
            return (world, !gifts.isEmpty)
        }
    }

    /// "delete on sight, by recorded id only": a Mac in Castle never deletes
    /// another Mac's own Apple key it can see (that Mac's library is in
    /// Standard under a key of its own).
    @Test func deleteOnSightByRecordedIDOnly() async throws {
        try await mutationPin("another Mac's own Apple key survives", off: { $0.deleteOnSightByIDOnly = false }) { guards in
            let world = try scenarioWorld(guards: guards) { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                try w.today(on: w.macB, TodaySpec(mode: .standard))
            }
            await world.done([.launch("macB"), .settle, .useCastle("macA", .touchID, newWords: false), .settle, .launch("macA"),
                              .syncICloud("macA"), .syncICloud("macB")])
            let macBsKey = world.liveKeyFile(world.macB)?.apple?.keyID
            return (world, macBsKey.map { world.readableAppleKeys(world.macB)[$0] != nil } == true)
        }
    }

    /// "this library's own Castle-era copy restored after a leave: ours by
    /// the family tree, opening with the passphrase or words, taking the
    /// Standard mode, with no raise".
    @Test func ownCastleEraCopyRestoredAfterALeave() async throws {
        try await mutationPin("its own Castle-era copy opens as its own", off: { $0.ownLineByFamilyTree = false }) { guards in
            let world = try scenarioWorld(guards: guards) { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
            await world.done([.launch("macA"), .backup("macA"), .useStandard("macA")])
            let castleEra = world.truth.copies.filter { $0.value.mode == .castle && $0.key.hasPrefix("container:Backups/") }.keys.sorted().first
            let catalog = world.catalog(world.macA)
            let n = catalog.copies.filter { $0.library == world.macA.slot?.libraryID && $0.kind != .previousLibrary }
                .sorted { ($0.stamp ?? .distantPast) > ($1.stamp ?? .distantPast) }.firstIndex { $0.id == castleEra } ?? 0
            let result = await world.step(.restoreBackup("macA", newest: n))
            return (world, result == .done && world.macA.slot?.record?.mode == .standard)
        }
    }
}
#endif
