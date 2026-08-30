//
//  Phase13pCopySweepTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 4 — THE HONEST-COPY SWEEP, made structural.
//
//  Batch 2 shipped the Mac's disclosure sentences and pinned the ruled ones
//  byte-for-byte (knot 8's pair, the per-mode honesty grammar). What was
//  missing is the sweep's own guarantee: that EVERY mode and EVERY preset
//  has its sentences at all, that they differ from each other, and that the
//  ruled non-goal is stated somewhere a reader choosing a mode will meet it.
//
//  Why that matters more here than in most panes: this is the one surface in
//  the app whose whole claim is that it says what is actually so. A future
//  mode added without its disclosure would not look broken — it would look
//  finished and say nothing, which is the failure R13p-16 refused in another
//  form (*"it makes users think privacy is in place that just isn't"*).
//  These pins fail the day such a mode appears.
//
//  Copy TASTE is 13s's; copy PRESENCE is a correctness property, and this is
//  where it is kept.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — the honest-copy sweep (every mode and preset speaks)")
struct Phase13pCopySweepTests {
    /// Every at-open mode has a row label, a what-it-does-not-protect
    /// sentence, and loss math under BOTH escrow states — all non-empty and
    /// all distinct from one another.
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

            for escrow in [true, false] {
                let math = ProtectionCopy.lossMath(mode, escrowOn: escrow)
                #expect(math.count > 40)
                #expect(!ProtectionCopy.lossLegs(mode, escrowOn: escrow).isEmpty,
                        "every mode has at least one way back in")
            }
        }
    }

    /// Both presets have a title and a blurb, and the blurbs say different
    /// things (a preset pair that reads the same is a choice a reader cannot
    /// make).
    @Test func bothPresetsSayWhatTheyDo() {
        let titles = ProtectionPreset.allCases.map(ProtectionCopy.presetTitle)
        let blurbs = ProtectionPreset.allCases.map(ProtectionCopy.presetBlurb)
        #expect(Set(titles).count == titles.count)
        #expect(Set(blurbs).count == blurbs.count)
        for blurb in blurbs { #expect(blurb.count > 20) }
    }

    /// The escrow dial states its consequence BOTH ways — never only the
    /// reassuring one (knot 8's ruled pair is the content; this pin is that
    /// both arms exist and disagree).
    @Test func theEscrowDialSpeaksBothWays() {
        #expect(ProtectionCopy.escrowOn != ProtectionCopy.escrowOff)
        #expect(ProtectionCopy.escrowOn.contains("iCloud"))
        #expect(ProtectionCopy.escrowOff.contains("unrecoverable"))
        // And the two honesty riders the dial owes: what it needs to ride,
        // and what it costs under a demanded gate.
        #expect(ProtectionCopy.escrowNeedsICloudKeychain.contains("nothing for it to ride"))
        #expect(ProtectionCopy.escrowUnderDemandedMode.contains("without passing the lock"))
    }

    /// **THE NAMED NON-GOAL IS NAMED.** The plan declines exactly one threat
    /// (shape B's — an attacker at an open, unlocked app) and then declined
    /// the per-note curtain that would have implied it was covered. Both
    /// halves are in the sentence, and the sentence is rendered where a mode
    /// is chosen.
    @Test func theOpenAppIsReadableLineStatesTheDecline() {
        let line = ProtectionCopy.openAppIsReadable
        #expect(line.contains("open and unlocked"))
        #expect(line.contains("readable"))
        #expect(line.contains("no per-note lock"),
                "R13p-16's decline is stated, not merely absent")
        #expect(line.contains("Locking is how you end that"),
                "…and the honest answer is offered beside it")
    }

    /// **THE WALK'S CATCH.** The acceptance walk drove a passphrase-
    /// demanding lobby with no wraps and read *"its fingerprint item is
    /// gone"* — a cause that cannot exist in that mode, on the one screen
    /// whose whole job is telling a locked-out user the truth about their
    /// own library. The sentence is per-demand now, and this is the pin.
    ///
    /// **Red-on-old** (behavioural revert, executed): with the single
    /// unconditional sentence restored, the passphrase arm names the
    /// biometry item and this fails.
    @Test func theDeadEndNamesOnlyCausesThatCanExistInItsMode() {
        let underPassphrase = ProtectionCopy.deadEnd(.passphrase)
        #expect(!underPassphrase.contains(ProtectionCopy.biometryName),
                "a passphrase-demanding lobby never had a biometry item to lose")
        #expect(underPassphrase.contains("no passphrase or recovery phrase is on file"))

        let underBiometry = ProtectionCopy.deadEnd(.biometric)
        #expect(underBiometry.contains(ProtectionCopy.biometryName),
                "…and where one COULD exist, its absence is the first thing to say")

        // Both roads end at the same two recoveries, named by real file.
        for sentence in [underPassphrase, underBiometry] {
            #expect(sentence.contains(StoreKeyEnvelope.filename))
            #expect(sentence.contains("restore the whole library from a backup"))
        }
    }

    /// The plain-text escape's warning exists and names the trade (R13p-8's
    /// rider: a scheduled export re-opens the door the encryption closed).
    @Test func thePlainTextEscapeWarnsUnderLockedDown() {
        #expect(ProtectionCopy.plaintextExportUnderLockedDown
            .contains("re-opens the door"))
    }
}
