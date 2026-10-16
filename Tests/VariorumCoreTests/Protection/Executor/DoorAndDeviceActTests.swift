//
//  DoorAndDeviceActTests.swift
//  VariorumCoreTests — VX-305 U3: the key doors (re-wrap the current key
//  only; a fresh descriptor for a new passphrase; the anchor sentence in the
//  Done), this Mac's settings and the Touch ID re-arm, confirming the mode,
//  creating a library, Re-link's two arms, the old shared key's move and
//  retirement (by recorded id; the last-step race), and the migration.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A library that left Castle (an anchor in its key file).
func leftCastle(synced: Bool = false) async throws -> (EX, UnlockedLibrary, ProtectionExecutor) {
    let fixture = try EX(.castle, synced: synced)
    let executor = fixture.executor()
    var library = try fixture.unlocked(executor)
    _ = try await executor.useStandard(&library, typed: fixture.typed)
    fixture.key = library.key
    fixture.world.writes = []
    return (fixture, library, executor)
}

@Suite("VX-305 U3 — the key doors re-wrap the current key only, and say the anchor's sentence")
struct ExecutorKeyDoorTests {
    @Test func changePassphraseReWrapsTheCurrentKeyAndTheAnchorKeepsItsDay() async throws {
        var (fixture, library, executor) = try await leftCastle()
        let before = try #require(fixture.world.liveFormat3)
        let outcome = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "another one")
        let after = try #require(fixture.world.liveFormat3)
        #expect(after.fingerprint == before.fingerprint && after.anchor == before.anchor && after.history == before.history)
        #expect(after.passphrase?.kdf != before.passphrase?.kdf)
        #expect(try after.open(passphrase: .passphrase("another one"), floor: PF.floor) == library.key)
        guard case .anchor(let sentence)? = outcome.done.first else { Issue.record("no anchor sentence"); return }
        #expect(sentence.door == .changePassphrase && sentence.replacedSecretOpensIt == true)
        // The anchor still opens with the leave day's passphrase.
        #expect(after.anchor?.opens(with: .passphrase(fixture.passphrase), floor: PF.floor) == true)
        _ = executor
        expectSettled(fixture, library)
    }

    @Test func theResetRoadNeverPointsAtTheForgottenPassphrase() async throws {
        var (fixture, library, executor) = try await leftCastle()
        let outcome = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: "fresh")
        guard case .anchor(let sentence)? = outcome.done.first else { Issue.record("no anchor sentence"); return }
        #expect(sentence.door == .resetForgottenPassphrase)
        #expect(!sentence.stillOpensWith.contains { if case .passphrase = $0 { return true } else { return false } })
        _ = (fixture, executor)
    }

    @Test func castlesResetTakesTouchIDOrTheWordsNeverAPlainConfirm() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: "x")
        }
        _ = try await executor.resetPassphrase(&library, authorization: .words(fixture.words), new: "set by the words")
        #expect(try fixture.world.liveFormat3?.open(passphrase: .passphrase("set by the words"), floor: PF.floor) == library.key)
    }

    @Test func newWordsSyncedReplaceTheVaultsRecoveryWrapAndTheKeyFilesCopy() async throws {
        let fixture = try EX(.castle, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: fresh)
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        let live = try #require(fixture.world.liveFormat3)
        #expect(live.masterWordsCopy == vault.format.masterWrappedByRecovery)
        #expect(try live.open(words: fresh) == library.key)
        #expect(try live.open(wordsThroughMaster: fresh) == library.key)
        #expect(VaultModel.master(of: vault.format, passphrase: nil, words: try WordsKey.derive(fixture.words)) == nil)
        expectSettled(fixture, library)
    }

    @Test func aWrongCurrentPassphraseIsRefused() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.changePassphrase(&library, current: "not it", new: "x")
        }
    }
}

@Suite("VX-305 U3 — this Mac's settings, the re-arm, confirm mode, create library")
struct ExecutorDeviceActTests {
    @Test func touchIDComesOnlyFromSettingsWithThePassphraseAndAlwaysAskDeletesTheItem() async throws {
        let fixture = try EX(.castle, gate: .alwaysAsk)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        var settings = library.section.settings
        settings.gateStyle = .touchID
        await #expect(throws: ExecutorRefusal.secretMissing) { _ = try await executor.changeSettings(&library, to: settings) }
        _ = try await executor.changeSettings(&library, to: settings, passphrase: fixture.passphrase)
        #expect(fixture.custody(.touchid, fixture.key) && library.section.settings.gateStyle == .touchID)
        settings.gateStyle = .alwaysAsk
        _ = try await executor.changeSettings(&library, to: settings)
        #expect(!fixture.custody(.touchid, fixture.key))
        // Both homes carry the setting (the replay class VX-313 names).
        #expect(fixture.memoryValue()?.deviceSection.settings.gateStyle == .alwaysAsk)
        expectSettled(fixture, library)
    }

    @Test func theReArmIsAskedOnlyWhenTheItemExists() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.answerTouchIDRearm(&library, yes: true)
        #expect(fixture.custody(.touchid, fixture.key) && library.section.settings.gateStyle == .touchID)
        _ = try await executor.answerTouchIDRearm(&library, yes: false)
        #expect(!fixture.custody(.touchid, fixture.key) && library.section.settings.gateStyle == .alwaysAsk)
        await #expect(throws: ExecutorRefusal.nothingToDo) { _ = try await executor.answerTouchIDRearm(&library, yes: true) }
    }

    @Test func aNewLibraryIsBornStandardWithThisMacsOwnAppleKey() throws {
        let world = ExecutorWorld()
        let executor = ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", machine: PF.macA, deviceName: "Mac A", floor: PF.floor))
        let library = try executor.createLibrary()
        let record = try #require(world.live?.record)
        #expect(record.mode == .standard && record.account == nil)
        let own = try #require(world.liveFormat3?.apple?.keyID)
        #expect(library.section.appleKeys.map(\.id) == [own] && world.icloud.keys[own] != nil)
        #expect(world.custody.keys.map(\.itemClass) == [.silent])
        #expect(library.section.settings.gateStyle == nil)
    }
}

@Suite("VX-305 U3 — Re-link, the move off the old shared key, its retirement")
struct SharedKeyActTests {
    @Test func reLinkMintsAFreshAccountKeyNeverTheOldSharedOne() async throws {
        let fixture = try EX(.standard, synced: true)
        fixture.world.icloud.oldShared = fixture.accountApple
        fixture.world.icloud.keys[fixture.accountApple!.id] = nil  // the account's key no device reads
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.relinkAccount(&library, passphrase: fixture.passphrase)
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        let fresh = try #require(library.section.appleKeys.last { $0.purpose == .account })
        #expect(vault.mode == .standard(appleKeyID: fresh.id) && fresh.id != fixture.accountApple!.id)
        #expect(library.key == fixture.key)  // re-keys nothing
    }

    @Test func theLibraryArmMintsAFreshOwnKeyAndThenUseCastleRetiresBoth() async throws {
        let fixture = try EX(.standard)
        let lost = fixture.ownApple!.id
        fixture.world.icloud.keys[lost] = nil  // iCloud Keychain reset
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.relinkLibraryArm(&library)
        let fresh = try #require(fixture.world.liveFormat3?.apple?.keyID)
        #expect(fresh != lost && fixture.world.icloud.keys[fresh] != nil)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        #expect(library.section.retiredAppleKeyIDs.isSuperset(of: [lost, fresh]))
        #expect(fixture.world.icloud.keys[fresh] == nil)
    }

    @Test func useCastleRetiresTheOldSharedKeyLastByItsRecordedID() async throws {
        let fixture = try EX(.standard)
        let shared = AppleKeyMaterial.mint()
        fixture.world.icloud.oldShared = shared
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.writeFacts(&library, section: { var s = library.section.bumped(); s.oldSharedKey = OldSharedKeyRecord(id: shared.id); return s }())
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        #expect(fixture.world.icloud.oldShared == nil)
        #expect(library.section.oldSharedKey?.retiredAt != nil)
        // The last step: after the backup and the own key's retirement.
        let log = fixture.world.writeLog()
        let retired = try #require(log.firstIndex(of: "shared- \(shared.id.prefix(8))"))
        #expect(log.lastIndex { $0.hasPrefix("backup") }! < retired && log.lastIndex { $0.hasPrefix("apple-") }! < retired)
    }

    @Test func aNewOldNameItemAnOlderBuildMintedLaterIsLeftAlone() async throws {
        let fixture = try EX(.castle)
        let recorded = AppleKeyMaterial.mint(), newer = AppleKeyMaterial.mint()
        fixture.world.icloud.oldShared = newer
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.writeFacts(&library, section: { var s = library.section.bumped(); s.oldSharedKey = OldSharedKeyRecord(id: recorded.id); return s }())
        _ = try await executor.retireOldSharedKey(&library)
        #expect(fixture.world.icloud.oldShared?.id == newer.id)
    }

    @Test func theLastStepRaceKeepsTheKeyWhenAVaultItReadsNamesIt() async throws {
        let fixture = try EX(.castle, synced: true)
        let shared = AppleKeyMaterial.mint()
        fixture.world.icloud.oldShared = shared
        // An older build's Re-link landed the account's vault on the old key.
        var account = fixture.world.server.accounts[fixture.account!]!
        account.format = try account.format.settingAppleHeldCopy(
            masterKey: fixture.material!.masterSymmetricKey, appleKey: shared.key, appleKeyID: shared.id)
        fixture.world.server.accounts[fixture.account!] = account
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let outcome = try await executor.retireOldSharedKey(&library)
        #expect(outcome.notices == [.oldSharedKeyStayed(account: fixture.account!)])
        #expect(fixture.world.icloud.oldShared?.id == shared.id && library.section.oldSharedKey?.retiredAt == nil)
    }
}
