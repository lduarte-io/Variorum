//
//  NewWordsResumeTests.swift
//  VariorumCoreTests — VX-308 ladder round 1, MAJOR-1 (`notes/plans/vx-308-ladder-round-1.md`; F-U3-2's option (a),
//  scoped to the new-words act). RULE 20: "a crash at any point leaves either the old state or the new one. The next open
//  finishes the act or rolls it back from what is on disk, and says which." A new-words act (`regenerateWords`) stopped
//  mid-plan could NEITHER: its resume holds no words (a plan never holds a secret, and the words were never shown — they
//  die with the process), and the registry's program never mints a key file, so the resume threw out of the settle
//  (`secretsRequired` at the vault or key-file step, `noLiveKeyFile` on a file-less library) and the act stayed in flight
//  FOREVER: every later act refused `actInFlight` — VX-447's banner door (rule 27's recovery road) included — and, synced,
//  the account's words had already moved to values nobody saw. Now a RESUMED new-words act that cannot finish ROLLS BACK
//  before writing anything: the act cleared, the plan gone, the library as it stood (a landed vault write stands, as any
//  landed CAS write does — the next new words re-wrap it again), and the door works at once.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-308 ladder round 1 — MAJOR-1: a new-words act stopped mid-plan rolls back at the next open, never wedging its door")
struct NewWordsResumeTests {
    /// `fixture`'s library with rule 27's state planted (`FileLessWordsTests`' own): no key file in the live place, nothing
    /// this Mac remembers — opened with the key in hand (the silent item's road).
    private func fileLess(_ fixture: EX) throws -> (ProtectionExecutor, UnlockedLibrary) {
        fixture.world.liveKeyFile = nil
        fixture.world.memories = [:]
        let executor = fixture.executor()
        let library = try fixture.unlocked(executor)
        #expect(library.keyFile == nil && library.memory == nil, "the state as planted")
        fixture.world.writes = []
        return (executor, library)
    }

    /// The banner door's own act: Standard unsynced asks nothing; synced asks the account's passphrase.
    private func mint(_ fixture: EX, _ executor: ProtectionExecutor, _ library: inout UnlockedLibrary, _ words: [String])
        async throws {
        _ = try await executor.regenerateWords(
            &library, passphrase: fixture.account == nil ? nil : fixture.passphrase, newWords: words)
    }

    /// The account's vault opens with `words` (the twelve-words wrap of its master).
    private func vaultOpens(_ fixture: EX, words: [String]) throws -> Bool {
        let account = try #require(fixture.account)
        let vault = try #require(fixture.world.server.snapshot(account))
        return VaultModel.master(of: vault.vault, passphrase: nil, words: try WordsKey.derive(words)) != nil
    }

    /// A settled world (`expectSettled`'s first four — the key file may be absent here: that is the state).
    private func expectNothingHalfDone(_ fixture: EX, _ library: UnlockedLibrary, _ context: String,
                                       sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(library.section.actInFlight == nil, "\(context) an act is still in flight", sourceLocation: sourceLocation)
        #expect(fixture.world.plan == nil, "\(context) a plan is left on disk", sourceLocation: sourceLocation)
        #expect(fixture.world.staged == nil, "\(context) a staged file is left", sourceLocation: sourceLocation)
        #expect(!fixture.world.paused, "\(context) copies are still paused", sourceLocation: sourceLocation)
    }

    /// THE FINDING'S OWN SEQUENCE (both postures): a SYNCED file-less library's banner door re-wraps the ACCOUNT's words
    /// (the act's one vault write LANDS), then the process dies before the fresh key file is written. The next quiet open
    /// (no typed secrets — the silent item's road, rule 27's state) ROLLS THE ACT BACK: nothing in flight, no plan, still
    /// no key file (the old state on disk); the landed vault write stands (the account moved — honestly said here); and
    /// the door MINTS AGAIN at once, the account's words and the fresh file changing together (rule 7). RED ON OLD: the
    /// settle threw `noLiveKeyFile`, the act stayed in flight, and the second mint refused `actInFlight`.
    @Test(arguments: [ProtectionMode.standard, .castle])
    func aSyncedMintStoppedBetweenItsVaultWriteAndItsFileRollsBackAndTheDoorMintsAgain(_ mode: ProtectionMode)
        async throws {
        // The clean run's write log names the crash point: right after the plan records the vault step done.
        let clean = try EX(mode, synced: true)
        var (cleanExecutor, cleanLibrary) = try fileLess(clean)
        try await mint(clean, cleanExecutor, &cleanLibrary, try PF.words())
        let vaultWrite = try #require(clean.world.writes.firstIndex { if case .vaultUpdate = $0 { true } else { false } })
        #expect(clean.world.writes[vaultWrite + 1] == .plan && clean.world.writes[vaultWrite + 2] == .keyFile(f8(clean.key)))

        let fixture = try EX(mode, synced: true)
        var (executor, library) = try fileLess(fixture)
        let key = library.key
        let unseen = try PF.words()
        fixture.world.crashAfterWrites = vaultWrite + 2
        await #expect(throws: SimulatedCrash.self) { try await mint(fixture, executor, &library, unseen) }
        #expect(fixture.world.plan != nil && fixture.world.liveFormat3 == nil, "stopped between the vault write and the file")
        #expect(try vaultOpens(fixture, words: unseen), "the act's one vault write landed — words nobody was shown")

        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.regenerateWords), "rule 20: rolled back, and said which")
        expectNothingHalfDone(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == nil && settled.keyFile == nil, "the old state on disk: still no key file")
        #expect(settled.key == key, "no key changed")
        #expect(try vaultOpens(fixture, words: unseen) && !vaultOpens(fixture, words: fixture.words),
                "the landed vault write stands, as any landed CAS write does")

        var again = settled
        let fresh = try PF.words()
        try await mint(fixture, relaunched, &again, fresh)
        let minted = try #require(fixture.world.liveFormat3, "the door mints at once — the recovery road is not wedged")
        #expect(try minted.open(words: fresh) == key)
        #expect(try vaultOpens(fixture, words: fresh) && !vaultOpens(fixture, words: unseen),
                "rule 7: the account's words and the library's change together again")
        #expect(again.section.actInFlight == nil && fixture.world.plan == nil)
    }

    /// THE UNSYNCED TWIN (Standard — the smaller window, no network): the door's act begun, the process dead before the
    /// fresh key file. The next quiet open rolls back; the door then mints. RED ON OLD: `noLiveKeyFile` out of the settle.
    @Test func anUnsyncedMintStoppedBeforeItsFileRollsBackAndTheDoorMintsAgain() async throws {
        let fixture = try EX(.standard)
        var (executor, library) = try fileLess(fixture)
        let key = library.key
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) { try await mint(fixture, executor, &library, try PF.words()) }
        #expect(fixture.world.writes == [.record(f8(key)), .memory(f8(key)), .plan], "stopped right after its begin")

        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.regenerateWords))
        expectNothingHalfDone(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == nil, "the old state on disk")

        var again = settled
        let fresh = try PF.words()
        try await mint(fixture, relaunched, &again, fresh)
        #expect(try #require(fixture.world.liveFormat3).open(words: fresh) == key, "the door mints at once")
    }

    /// The EVERYDAY new-words act (a library with its key file and a passphrase — F-U3-2's "above all" case), stopped
    /// right after its begin: the next quiet open rolls back (the live key file untouched — the old words still open it),
    /// and New Words works again. RED ON OLD: `secretsRequired` out of the settle, the act in flight for good.
    @Test func anEverydayNewWordsActStoppedMidPlanRollsBackToo() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = try #require(fixture.world.liveFormat3)
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: try PF.words())
        }
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.regenerateWords))
        expectSettled(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == before, "the live key file as it stood")
        #expect(try before.open(words: fixture.words) == settled.key, "the words she has still open it")

        var again = settled
        let fresh = try PF.words()
        _ = try await relaunched.regenerateWords(&again, passphrase: fixture.passphrase, newWords: fresh)
        #expect(try #require(fixture.world.liveFormat3).open(words: fresh) == again.key)
    }

    /// A resume that HOLDS words (typed at a lobby) but finds NO live key file of the key — the file-less mint stopped before
    /// its file, a resume never minting — rolls back too, before any write (synced: the vault untouched by the resume), and
    /// the door mints again. (Red with the no-live-file arm dropped — the pre-fix behaviour on this road: `noLiveKeyFile`
    /// out of the settle.)
    @Test(arguments: [false, true])
    func aStoppedMintResumedHoldingWordsButNoKeyFileRollsBackToo(_ synced: Bool) async throws {
        let fixture = try EX(.standard, synced: synced)
        var (executor, library) = try fileLess(fixture)
        let key = library.key
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) { try await mint(fixture, executor, &library, try PF.words()) }
        let vaultBefore = synced ? fixture.world.server.snapshot(try #require(fixture.account))?.revision : nil
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(
            TypedSecrets(passphrase: fixture.passphrase, words: fixture.words))
        #expect(outcome == .rolledBack(.regenerateWords))
        expectNothingHalfDone(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == nil)
        if synced {
            #expect(fixture.world.server.snapshot(try #require(fixture.account))?.revision == vaultBefore,
                    "the resume wrote nothing to the vault")
        }
        var again = settled
        let fresh = try PF.words()
        try await mint(fixture, relaunched, &again, fresh)
        #expect(try #require(fixture.world.liveFormat3).open(words: fresh) == key)
    }

    /// A resume HOLDING the act's words (typed at the lobby — the scenario world's model of her) still FINISHES, exactly
    /// as before: the rollback is only for a resume that cannot finish. (Green on both trees — the arm's guard.)
    @Test func aResumeHoldingTheWordsStillFinishes() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let fresh = try PF.words()
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: fresh)
        }
        let (outcome, settled, _) = try await fixture.relaunchAndSettle(
            TypedSecrets(passphrase: fixture.passphrase, words: fresh))
        guard case .resumed = outcome else {
            Issue.record("the resume holding its words should finish — \(outcome)")
            return
        }
        expectSettled(fixture, settled, "after the settle:")
        #expect(try #require(fixture.world.liveFormat3).open(words: fresh) == settled.key)
    }

    /// WHEREVER IT STOPS (a crash after EVERY write of the door's clean run — Standard unsynced, and synced in both
    /// postures): the next quiet open settles without throwing, leaves nothing half-done, and the door's act then LANDS —
    /// a key file opened by the words it shows. RED ON OLD at every stop between the begin and the key file (and, synced,
    /// right after the vault write).
    @Test(arguments: [(ProtectionMode.standard, false), (.standard, true), (.castle, true)])
    func aStoppedMintNeverWedgesItsDoorWhereverItStopped(_ shape: (ProtectionMode, Bool)) async throws {
        let (mode, synced) = shape
        let clean = try EX(mode, synced: synced)
        var (cleanExecutor, cleanLibrary) = try fileLess(clean)
        try await mint(clean, cleanExecutor, &cleanLibrary, try PF.words())
        let count = clean.world.writes.count
        #expect(count > 5)
        for crashAt in 1...count {
            let context = "\(mode)\(synced ? " synced" : ""), crash after write \(crashAt) (\(clean.world.writes[crashAt - 1])):"
            let fixture = try EX(mode, synced: synced)
            var (executor, library) = try fileLess(fixture)
            fixture.world.crashAfterWrites = crashAt
            do {
                try await mint(fixture, executor, &library, try PF.words())
                Issue.record("\(context) no crash")
            } catch is SimulatedCrash {}
            let settled: UnlockedLibrary, relaunched: ProtectionExecutor
            do {
                (_, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
            } catch {
                Issue.record("\(context) the settle threw \(error) — the act stays in flight and its door is wedged. LOG: \(fixture.world.logLines.suffix(8))")
                continue
            }
            expectNothingHalfDone(fixture, settled, context)
            var again = settled
            let fresh = try PF.words()
            do {
                try await mint(fixture, relaunched, &again, fresh)
            } catch {
                Issue.record("\(context) the door refused \(error)")
                continue
            }
            let file = fixture.world.liveFormat3
            #expect((try? file?.open(words: fresh)) == again.key, "\(context) the door's key file opens with its words")
        }
    }
}
