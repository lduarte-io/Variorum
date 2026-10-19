//
//  Phase13pCopySweepTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 4 — THE HONEST-COPY SWEEP, made structural.
//
//  Batch 2 shipped the Mac's disclosure sentences and pinned the ruled ones
//  byte-for-byte (the per-mode honesty grammar). What was missing is the
//  sweep's own guarantee: that EVERY gate has its sentences at all, that
//  they differ from each other, and that the ruled non-goal is stated
//  somewhere a reader choosing a posture will meet it. pre-13x 2a: the
//  presets and the escrow dial are gone (§13); the two POSTURES speak in
//  their place (copy §1).
//
//  Why that matters more here than in most panes: this is the one surface in
//  the app whose whole claim is that it says what is actually so. A future
//  gate added without its disclosure would not look broken — it would look
//  finished and say nothing, which is the failure R13p-16 refused in another
//  form (*"it makes users think privacy is in place that just isn't"*).
//  These pins fail the day such a gate appears.
//
//  Copy TASTE is 13s's; copy PRESENCE is a correctness property, and this is
//  where it is kept.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — the honest-copy sweep (every gate and posture speaks)")
struct Phase13pCopySweepTests {
    /// Every effective gate has a row label and a what-it-does-not-protect
    /// sentence — all non-empty and all distinct from one another. (The
    /// 13p loss math retired at pre-13x 5a — §13; the posture cards' floors
    /// are the loss story now, pinned below.)
    @Test func everyModeCarriesItsFullDisclosure() {
        var seenSentences: Set<String> = []
        var seenLabels: Set<String> = []
        for mode in StoreAtOpenMode.allCases {
            let label = ProtectionCopy.modeLabel(mode)
            #expect(!label.isEmpty)
            #expect(seenLabels.insert(label).inserted, "two modes share a row label")

            let sentence = ProtectionCopy.modeSentence(mode)
            #expect(sentence.count > 40, "a disclosure that short is not one")
            #expect(seenSentences.insert(sentence).inserted,
                    "two modes claim the same protection")
        }
    }

    /// Both POSTURES have a name, a tag and a one-line, and the cards say
    /// different things (a pair that reads the same is a choice a reader
    /// cannot make). Every card names who it STOPS and its FLOOR — the two
    /// honest boundaries the design says must survive re-voicing (§18 v).
    @Test func bothPosturesSayWhatTheyAre() {
        let postures: [Posture] = [.standard, .castle]
        #expect(Set(postures.map(ProtectionCopy.postureName)).count == 2)
        #expect(Set(postures.map(ProtectionCopy.postureOneLine)).count == 2)
        for posture in postures {
            let card = ProtectionCopy.postureCard(posture)
            #expect(card.contains { $0.label == "Who it stops" && $0.text.contains("the Variorum server — yes") })
            #expect(card.contains { $0.label == "The floor" })
        }
        #expect(ProtectionCopy.postureCard(.castle).contains { $0.text.contains("Nobody can help") },
                "Castle's floor is said as the sign the lock is real")
        #expect(ProtectionCopy.postureCard(.standard).contains { $0.text.contains("Keep the words") })
    }

    /// **THE NAMED NON-GOAL IS NAMED.** The plan declines exactly one threat
    /// (shape B's — an attacker at an open, unlocked app) and then declined
    /// the per-note curtain that would have implied it was covered. Both
    /// halves are in the sentence, and keystone 4 says it in every posture.
    @Test func theOpenAppIsReadableLineStatesTheDecline() {
        let line = ProtectionCopy.openAppIsReadable
        #expect(line.contains("open and unlocked"))
        #expect(line.contains("readable"))
        #expect(line.contains("no per-note lock"),
                "R13p-16's decline is stated, not merely absent")
        #expect(line.contains("Locking is how you end that"),
                "…and the honest answer is offered beside it")
        #expect(ProtectionCopy.keystoneOpenMeansReadable.contains("Locking is how you end that"))
    }

    /// **THE WALK'S CATCH.** The acceptance walk drove a passphrase-
    /// demanding lobby with no wraps and read *"its fingerprint item is
    /// gone"* — a cause that cannot exist in that mode, on the one screen
    /// whose whole job is telling a locked-out user the truth about their
    /// own library. The sentence is per-demand now, and this is the pin.
    @Test func theDeadEndNamesOnlyCausesThatCanExistInItsMode() {
        let underPassphrase = ProtectionCopy.deadEnd(.passphrase)
        #expect(!underPassphrase.contains(ProtectionCopy.biometryName),
                "a passphrase-demanding lobby never had a biometry item to lose")
        #expect(underPassphrase.contains("no passphrase or recovery phrase is on file"))

        let underBiometry = ProtectionCopy.deadEnd(.biometric)
        #expect(underBiometry.contains(ProtectionCopy.biometryName),
                "…and where one COULD exist, its absence is the first thing to say")

        for sentence in [underPassphrase, underBiometry] {
            #expect(sentence.contains(StoreKeyEnvelope.filename))
            #expect(sentence.contains("restore the whole library from a backup"))
        }
    }

    /// **Ladder R1-n2 — the unforeseen error speaks a sentence, never a
    /// case name.** RED ON OLD: the describing dump contains the error
    /// type's name.
    @Test func anUnforeseenErrorSpeaksASentenceNeverACaseName() {
        struct UtterlyUnforeseenError: Error {}
        let message = ProtectionCopy.message(for: UtterlyUnforeseenError())
        #expect(!message.contains("UtterlyUnforeseen"),
                "no case-name dumps on the refusal surface (R94)")
        #expect(message.contains(StoreKeyEnvelope.filename),
                "the one always-true recovery road is named")
    }

    @Test func thePlainTextEscapeWarnsUnderLockedDown() {
        // VX-307 U2c (VX-379's row — a justified edit: the warning speaks rule 11's words now, "a plain copy on disk
        // would undo the promise; it is your call"; the warning itself stands).
        #expect(ProtectionCopy.plaintextExportUnderLockedDown
            .contains("would undo Castle's promise"))
    }
}
