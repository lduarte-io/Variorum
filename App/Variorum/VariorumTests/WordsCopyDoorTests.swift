//
//  WordsCopyDoorTests.swift
//  VariorumTests
//
//  18o U5 — 17t item 2 (KnownIssues row 55): **COPY ALL ON EVERY MAC SCREEN
//  THAT SHOWS THE TWELVE WORDS, ONE RULE.** Before this unit the door existed
//  in ONE place (the Castle / Replace All Keys ceremony) while the Mac showed
//  the words on four more: sync setup (`SyncEnrollmentView` — copy §2a's own
//  Screen 3, whose "Copied" caption was a branch nothing could reach),
//  Regenerate Twelve Words (`KeyDoorView`), the set sheet
//  (`PassphraseSetSheet`) and the nudge's phrase-only sheet.
//
//  **How these read the surface** — the two sanctioned roads, combined:
//  `SurfaceComposition` (the view's own composition; an UNTAKEN branch is
//  absent) and `ComposedSliders`' rule (find a node by its OWN TYPE, then
//  drive exactly what a click drives — never an OS-internal field name). The
//  `WordsCopyDoor` found in a face's composition IS the value that face
//  renders, so calling its `copy` is the click, and the face's flag moving is
//  proof the composed door is wired to THAT face's receipt. Every drive uses a
//  PRIVATE named pasteboard and a short interval — her clipboard is never a
//  test's.
//
//  The limit, inherited from `SurfaceComposition` and stated: a composition
//  proves the door is COMPOSED, not VISIBLE; the hosted window beside each pin
//  proves the face builds and lays out; the walk is the visible half.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum ComposedWordsCopyDoors {
    /// Every `WordsCopyDoor` node in `view`'s composition, in walk order —
    /// found by its own type (the `ComposedSliders` walk: SwiftUI's own
    /// values and storage classes are descended, an app model is not).
    static func find<V: View>(in view: V) -> [WordsCopyDoor] {
        var found: [WordsCopyDoor] = []
        var visited = Set<ObjectIdentifier>()
        walk(view, depth: 0, visited: &visited, into: &found)
        return found
    }

    private static func walk(
        _ value: Any, depth: Int,
        visited: inout Set<ObjectIdentifier>, into found: inout [WordsCopyDoor]
    ) {
        guard depth < 400 else { return }
        if let door = value as? WordsCopyDoor {
            found.append(door)
            return
        }
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .class {
            guard String(reflecting: type(of: value)).hasPrefix("SwiftUI.") else { return }
            let id = ObjectIdentifier(value as AnyObject)
            guard visited.insert(id).inserted else { return }
        }
        for child in mirror.children {
            walk(child.value, depth: depth + 1, visited: &visited, into: &found)
        }
    }

    /// A private pasteboard, never the general one.
    static func privateBoard() -> NSPasteboard {
        NSPasteboard(name: NSPasteboard.Name("io.lduarte.variorum.tests.words.\(UUID().uuidString)"))
    }

    /// The click: drive the composed door against a private board; the
    /// board must hold the words as ONE line; the clear then runs.
    static func click(_ door: WordsCopyDoor, expecting words: [String]) async {
        let board = privateBoard()
        defer { board.releaseGlobally() }
        let clearing = door.copy(to: board, clearAfter: .milliseconds(20))
        #expect(board.string(forType: .string) == words.joined(separator: " "),
                "the door put the twelve words on the clipboard as one line")
        await clearing.value
        #expect(board.string(forType: .string) == nil, "…and cleared them after its interval")
    }
}

@MainActor
@Suite("18o U5 — Copy All on every Mac words screen, one rule (17t item 2)", .serialized)
struct WordsCopyDoorTests {
    private static let passphrase = "orchard-lantern-13"

    // MARK: - THE ONE RULE (guards — the hoisted closure's two arms)

    /// Decision 23: the words ride ONE line and the clipboard clears after
    /// the interval when nothing else wrote. Guard (the hoist is the
    /// scaffolding; green on both trees).
    @Test func theWordsRideOneLineAndClearAfterTheirInterval() async {
        #expect(WordsClipboard.clearAfter == .seconds(60), "decision 23's number, which the sub-line says")
        let board = ComposedWordsCopyDoors.privateBoard()
        defer { board.releaseGlobally() }
        let words = (1...12).map { "word\($0)" }
        let clearing = WordsClipboard.copy(words, to: board, clearAfter: .milliseconds(20))
        #expect(board.string(forType: .string) == words.joined(separator: " "))
        await clearing.value
        #expect(board.string(forType: .string) == nil, "cleared — nothing else wrote in between")
    }

    /// The clear never erases what she (or anything) copied since — the
    /// `changeCount` guard. Guard.
    @Test func anythingCopiedSinceIsNeverCleared() async {
        let board = ComposedWordsCopyDoors.privateBoard()
        defer { board.releaseGlobally() }
        let clearing = WordsClipboard.copy(["alpha", "beta"], to: board, clearAfter: .milliseconds(20))
        board.clearContents()
        board.setString("her own later copy", forType: .string)
        await clearing.value
        #expect(board.string(forType: .string) == "her own later copy")
    }

    // MARK: - (2) Sync setup — copy §2a Screen 3 (SHARED face; the Mac arm)

    /// RED ON OLD: `SyncEnrollmentView`'s words screen composed no Copy All,
    /// so `SyncEnrollmentModel.markWordsCopied()` had no caller and the
    /// screen's "Copied" caption was a branch that could never show.
    @Test func syncSetupsWordsScreenCarriesCopyAllAndItsCaptionShows() async throws {
        let model = SyncEnrollmentModel(
            encryption: EncryptionSession(store: .inMemory(), client: nil, signedIn: { false }),
            tie: StoreTie(
                libraryPosture: { .standard }, hasPassphrase: { false }, hasRecoveryWords: { false },
                verifyPassphrase: { _ in nil }, setPassphrase: { _ in nil },
                verifyRecoveryWords: { _ in nil }, passphraseKDF: { nil }),
            foreignOwner: { false }, adopt: {})
        await model.start()
        model.continueFromExplain()
        await model.submitPassphrase(Self.passphrase, confirmation: Self.passphrase)
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("sync setup shows fresh words: \(model.phase)"); return
        }
        let view = SyncEnrollmentView(model: model, pageStyle: nil, onClose: {})
        await SurfaceComposition.host(view, size: NSSize(width: 520, height: 520))
        #expect(!SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)),
                "no caption before a copy")
        let door = try #require(ComposedWordsCopyDoors.find(in: view.body).first,
                                "the sync-setup words screen composes Copy All (copy §2a Screen 3)")
        #expect(door.words == words, "the door copies the words on screen")
        await ComposedWordsCopyDoors.click(door, expecting: words)
        #expect(model.copiedWords, "the composed door reports to THIS model — markWordsCopied() is reachable")
        #expect(SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)),
                "the caption branch renders after a copy")
    }

    // MARK: - (3) Regenerate Twelve Words — copy §4 ("Then 2a's Screens 3/3b")

    /// RED ON OLD: `KeyDoorView`'s words screen had neither the door nor the
    /// caption; `KeyDoorModel.markWordsCopied()` had no caller.
    @Test func regenerateWordsScreenCarriesCopyAllAndItsCaptionShows() async throws {
        let facts = KeyDoorFacts(
            posture: { .standard }, gate: { .auto }, biometryAvailable: { false },
            keyFileVaultKDF: { nil }, confirmPresence: { _ in true },
            verifyLocalPassphrase: { _ in nil }, verifyLocalWords: { _ in nil },
            setLocalPassphrase: { _ in nil })
        let model = KeyDoorModel(
            kind: .regenerateWords,
            encryption: EncryptionSession(store: .inMemory(), client: nil, signedIn: { false }),
            facts: facts)
        await model.start()
        #expect(model.phase == .authorize, "\(model.phase)")
        model.forgot()
        #expect(model.phase == .forgotStandard, "\(model.phase)")
        await model.authorizeRegenerateByDevice()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("regenerate shows fresh words: \(model.phase)"); return
        }
        let view = KeyDoorView(model: model, pageStyle: nil, onClose: {})
        await SurfaceComposition.host(view, size: NSSize(width: 520, height: 520))
        #expect(!SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)))
        let door = try #require(ComposedWordsCopyDoors.find(in: view.body).first,
                                "the regenerate words screen composes Copy All (2a's Screen 3)")
        #expect(door.words == words)
        await ComposedWordsCopyDoors.click(door, expecting: words)
        #expect(model.copiedWords, "the composed door reports to THIS model")
        #expect(SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)),
                "copy §2a's sub-line renders after a copy")
    }

    // MARK: - (4) The set sheet's phrase screen (Mac)

    private func controller() -> ProtectionController {
        let backing = InMemoryStoreKeyGuardBacking(
            auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(nil), stamps: ScriptedStampsBox())
        return ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
    }

    /// RED ON OLD: the set sheet showed the fresh twelve words with no Copy All.
    @Test func theSetSheetsPhraseScreenCarriesCopyAllAndItsCaptionShows() async throws {
        let words = try RecoveryPhrase.generate()
        let model = PassphraseSetModel(controller: controller(), vaultTie: nil, startingAt: .showPhrase(words))
        let view = PassphraseSetSheet(model: model, onDone: {})
        await SurfaceComposition.host(view, size: NSSize(width: 440, height: 420))
        #expect(!SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)))
        let door = try #require(ComposedWordsCopyDoors.find(in: view.body).first,
                                "the set sheet's phrase screen composes Copy All")
        #expect(door.words == words)
        await ComposedWordsCopyDoors.click(door, expecting: words)
        #expect(model.copiedWords, "the composed door reports to THIS model")
        #expect(SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: view.body)))
    }

    // MARK: - (5) The nudge's phrase-only sheet (Mac; no model — the presenter's flag)

    /// RED ON OLD: the phrase-only sheet showed the twelve words with no
    /// Copy All. The receipt is its presenter's, handed in, so the caption is
    /// a function of `copied` and the door must call `onCopied`.
    @Test func theNudgesPhraseOnlySheetCarriesCopyAllAndItsCaptionFollowsItsFlag() async throws {
        let words = try RecoveryPhrase.generate()
        let reported = LockIsolated(false)
        let fresh = PhraseOnlySheet(words: words, copied: false,
                                    onCopied: { reported.setValue(true) }, onDone: {})
        await SurfaceComposition.host(fresh, size: NSSize(width: 440, height: 360))
        #expect(!SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: fresh.body)))
        let door = try #require(ComposedWordsCopyDoors.find(in: fresh.body).first,
                                "the phrase-only sheet composes Copy All")
        #expect(door.words == words)
        await ComposedWordsCopyDoors.click(door, expecting: words)
        #expect(reported.value, "the composed door reports to the presenter's receipt")
        let copied = PhraseOnlySheet(words: words, copied: true, onCopied: {}, onDone: {})
        await SurfaceComposition.host(copied, size: NSSize(width: 440, height: 360))
        #expect(SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: copied.body)),
                "the caption renders once the presenter's flag is set")
    }
}
