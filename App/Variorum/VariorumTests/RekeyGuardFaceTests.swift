//
//  RekeyGuardFaceTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2a — T1's guard at the FACE: the count-and-dates
//  warning renders her ruled emphasis ("a concrete number stops a
//  click-through where an abstract warning doesn't") essentially
//  verbatim, and the couldn't-compare arm stays honest without blocking
//  the door. The probe + rule mechanics are pinned in core
//  (`RekeyRecencyProbeTests`).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor  // EncryptionView's statics are MainActor-isolated (a view type)
@Suite("The re-key door's recency warning (T1)")
struct RekeyGuardFaceTests {
    /// Her example's exact shape: "12 notes this copy doesn't have, newer
    /// versions of 9 others, latest Aug 28" → the shipped sentence.
    @Test func theWarningCarriesCountsAndTheDate() {
        let report = RekeyRecencyReport(
            notesOnlyOnServer: 12, notesNewerOnServer: 9,
            latestServerChange: "2026-08-28T14:00:00Z")
        let warning = EncryptionView.recencyWarning(report)
        #expect(warning.contains("12 notes this copy doesn't have"))
        #expect(warning.contains("newer versions of 9 others"))
        #expect(warning.contains("Aug 28, 2026"))
        #expect(warning.contains(
            "Re-keying replaces the server's copy with this one — those would be lost."))
        #expect(warning.contains(
            "If you can remember your passphrase, that road keeps them."))
    }

    @Test func theWarningReadsNaturallyInEveryArm() {
        let onlyNew = EncryptionView.recencyWarning(
            RekeyRecencyReport(notesOnlyOnServer: 1))
        #expect(onlyNew.contains("1 note this copy doesn't have"))
        #expect(!onlyNew.contains("others"))

        let onlyNewer = EncryptionView.recencyWarning(
            RekeyRecencyReport(notesNewerOnServer: 3))
        #expect(onlyNewer.contains("newer versions of 3 of your notes"))

        // No date known → no dangling clause.
        #expect(!onlyNew.contains("latest from"))
    }

    /// The failure arm: honest, and never a refusal — the sentence says
    /// what proceeding means instead of standing in the way.
    @Test func theUncomparableArmStaysOpenAndHonest() {
        #expect(EncryptionView.recencyUncomparable.contains("couldn't be compared"))
        #expect(EncryptionView.recencyUncomparable.contains("THIS copy the truth"))
    }

    @Test func theDisplayDateSurvivesOddStamps() {
        #expect(EncryptionView.displayDate("2026-08-28T14:00:00Z") == "Aug 28, 2026")
        #expect(EncryptionView.displayDate(nil) == nil)
        #expect(EncryptionView.displayDate("junk") == nil)
        #expect(EncryptionView.displayDate("2026-13-99Tgarbage") == "2026-13-99")
    }
}
