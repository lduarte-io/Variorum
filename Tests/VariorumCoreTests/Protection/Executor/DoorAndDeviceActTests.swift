//
//  DoorAndDeviceActTests.swift
//  VariorumCoreTests — VX-305 U3: the key doors (re-wrap the current key
//  only; a fresh descriptor for a new passphrase), this Mac's settings and the
//  Touch ID re-arm, creating a library. (The anchor sentences, confirming the
//  mode, Re-link, the old shared key and the migration left with VX-378 U1.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A library that left Castle (its history carrying the Castle key).
func leftCastle(synced: Bool = false) async throws -> (EX, UnlockedLibrary, ProtectionExecutor) {
    let fixture = try EX(.castle, synced: synced)
    let executor = fixture.executor()
    var library = try fixture.unlocked(executor)
    _ = try await executor.useStandard(&library, typed: fixture.typed)
    fixture.key = library.key
    fixture.world.writes = []
    return (fixture, library, executor)
}

@Suite("VX-305 U3 — the key doors re-wrap the current key only (rule 6)")
struct ExecutorKeyDoorTests {
    /// Rule 6: the key stays, the history stays, and the NEW passphrase opens
    /// the Castle key from before the leave through it (rule 4) — the Done
    /// says nothing more (the anchor sentences left with VX-378 U1).
    @Test func changePassphraseReWrapsTheCurrentKeyAndTheNewOneOpensTheHistory() async throws {
        var (fixture, library, executor) = try await leftCastle()
        let before = try #require(fixture.world.liveFormat3)
        let outcome = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "another one")
        let after = try #require(fixture.world.liveFormat3)
        #expect(after.fingerprint == before.fingerprint && after.history == before.history)
        #expect(after.passphrase?.kdf != before.passphrase?.kdf)
        let opened = try after.open(passphrase: .passphrase("another one"), floor: PF.floor)
        #expect(opened == library.key)
        #expect(try after.historyKeys(currentKey: opened).count == 1)
        #expect(outcome.done.isEmpty)
        _ = executor
        expectSettled(fixture, library)
    }

    @Test func theResetRoadReLocksTheCurrentKey() async throws {
        var (fixture, library, executor) = try await leftCastle()
        let before = try #require(fixture.world.liveFormat3)
        let outcome = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: "fresh")
        let after = try #require(fixture.world.liveFormat3)
        #expect(after.fingerprint == before.fingerprint && after.history == before.history)
        #expect(try after.open(passphrase: .passphrase("fresh"), floor: PF.floor) == library.key)
        #expect(outcome.done.isEmpty)
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
