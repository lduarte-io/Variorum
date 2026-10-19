//
//  FirstLookWordsTests.swift
//  VariorumCoreTests — VX-307 U2b (VX-412; PROVISIONAL P-VX307-U2b-1): RULE 2's FIRST LOOK on a library with no
//  passphrase. The amended rules 2 and 3 show the twelve words only when the user asks — from the card above the quick
//  entry, which offers them while no passphrase exists yet, or at the tour's last card, beside the passphrase ask — and
//  nothing stores the words, so the look MINTS the words she records through rule 6's act (`regenerateWords`), the key
//  unchanged. The act as built asked the passphrase always (`verifiedPassphrase` → `.passphraseDoesNotOpen` on a key
//  file with no passphrase lock), so the look could not run on the very library the card is for. These pin the arm:
//  nil is asked nothing ONLY in Standard, unsynced, with no passphrase lock; a library with a passphrase is still asked
//  it; Castle and a synced library refuse nil.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-307 U2b — rule 2's first look: new words on a library with no passphrase (rule 6's act)")
struct FirstLookWordsTests {
    /// A library just created on this Mac (rule 2: twelve words, no passphrase — rule 3 asks later).
    private func created() throws -> (ExecutorWorld, ProtectionExecutor, CreatedLibrary) {
        let world = ExecutorWorld()
        let executor = ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(scope: EX.scope, libraryID: "", deviceName: "Mac A", floor: PF.floor))
        return (world, executor, try executor.createLibrary())
    }

    /// The look on a fresh Standard library: fresh words open the live key file, the creation's no longer do, the
    /// KEY is unchanged (rule 6), every other lock and this Mac's items stay, the mirror follows, nothing stores them.
    @Test func aStandardLibraryWithNoPassphraseMintsFreshWordsWithTheKeyUnchanged() async throws {
        let (world, executor, created) = try created()
        var library = created.library
        let before = try #require(world.liveFormat3)
        let custodyBefore = world.custody
        let appleBefore = world.icloud.keys
        let fresh = try PF.words()
        let outcome = try await executor.regenerateWords(&library, passphrase: nil, newWords: fresh)
        #expect(outcome.done.isEmpty)
        let after = try #require(world.liveFormat3)
        #expect(after.fingerprint == before.fingerprint, "rule 6: the key does not change")
        #expect(library.key == created.library.key)
        #expect(try after.open(words: fresh) == library.key, "the words she records open the library")
        #expect((try? after.open(words: created.words)) == nil, "the creation's words (never shown) no longer open it")
        #expect(after.passphrase == nil, "no passphrase is made by the look")
        #expect(after.apple == before.apple && after.history == before.history, "every other lock stays")
        #expect(world.custody == custodyBefore && Set(world.icloud.keys.keys) == Set(appleBefore.keys), "this Mac's items stay")
        #expect(library.memory?.keyFileMirror == after, "rule 1: this Mac's sealed copy follows the live key file")
        // Nothing stores the words: not the key file, not what this Mac remembers.
        let text = fresh.joined(separator: " ")
        var stored: [Data] = [try ProtectionCoding.canonical(after)]
        stored += world.memories.values.map(\.payload)
        #expect(!stored.contains { SecretScan.carries($0, text: text) }, "the words are stored")
        #expect(library.section.actInFlight == nil && world.plan == nil, "the act ended")
    }

    /// A library WITH a passphrase is asked it, exactly as before: nil refuses and writes nothing.
    @Test func aLibraryWithAPassphraseIsStillAskedIt() async throws {
        let (world, executor, created) = try created()
        var library = created.library
        _ = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: "chosen")
        let before = try #require(world.liveFormat3)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        #expect(world.liveFormat3 == before, "nothing written")
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.regenerateWords(&library, passphrase: "not it", newWords: try PF.words())
        }
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: "chosen", newWords: fresh)
        #expect(try world.liveFormat3?.open(words: fresh) == library.key)
    }

    /// Castle is always asked (rule 9's posture: no road around the passphrase).
    @Test func castleRefusesALookWithNoPassphrase() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = fixture.world.liveFormat3
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        #expect(fixture.world.liveFormat3 == before)
    }

    /// A synced library is always asked (the vault's lock is re-made under the account's master).
    @Test func aSyncedLibraryRefusesALookWithNoPassphrase() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = fixture.world.liveFormat3
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        #expect(fixture.world.liveFormat3 == before)
    }
}
