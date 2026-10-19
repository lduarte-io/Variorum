//
//  VX379PaneRowsTests.swift
//  VariorumTests — VX-307 U2c, VX-379's pane rows (`notes/plans/vx-307-castle-crossings.md` §5e piece 3; the U2a-4
//  ruling: today's rows retire behind the switch on the new road, and are reworded where they render — TODAY's road):
//    - the sidebar's POSTURE BOX reads today's tier, so it renders on today's road only (the VX-306 walk's W-1: on the
//      new road its exposed line said "only this Mac can open your work" — false under rule 8);
//    - Settings ▸ Data Safety's today's rows — what opens a backup by today's posture, and the "Restoring a copy" lead —
//      render on today's road only; the lead says rule 17's road (Restore from Backup; the current library steps aside
//      whole into Previous Libraries) in place of "a Finder operation, not a button" (false since 13x's door — F-U3-1);
//    - the CASTLE WARNING says rule 11's words and, on the new road, reads the OPEN library's posture (U2a's F-6 — today's
//      controller reads today's road, so a new-road Castle went unwarned);
//    - the Protection pane's checklist and floors speak the rules' words (twelve words; your Apple account; no shouting).
//  Source pins where the rule IS the composition (the established idiom — `ProtectionPaneRoadRowTests`); the warning's
//  rule is a pure function, pinned both ways.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2c — VX-379's pane rows: today's rows on today's road, in the rules' words")
@MainActor
struct VX379PaneRowsTests {
    static func code(_ relative: String) throws -> String {
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: app.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    /// W-1: the posture box (`ProtectionStatusRow`, today's tier) is composed only with no new-road faces.
    @Test func thePostureBoxRendersOnTodaysRoadOnly() throws {
        let root = try Self.code("Variorum/RootView.swift")
        let gate = try #require(root.range(of: "if let protection, protectionFaces == nil {"), "the posture box's gate")
        let row = try #require(root.range(of: "ProtectionStatusRow(controller: protection, tokens: tokens)"))
        #expect(gate.upperBound <= row.lowerBound && root[gate.upperBound..<row.lowerBound]
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "the row sits directly under the gate")
        #expect(root.components(separatedBy: "ProtectionStatusRow(").count == 2, "composed once")
    }

    /// F-U3-1 and today's posture's backup lines: Data Safety's today's rows render only with no new-road faces.
    @Test func dataSafetysTodaysRowsRenderOnTodaysRoadOnly() throws {
        let pane = try Self.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(pane.contains("if let protection, roadStanding == nil {\n                BackupsPostureLines(posture: protection.posture)"))
        #expect(pane.contains("if roadStanding == nil {\n                Text(DataSafetyCopy.restoringByTheDoor)"))
        #expect(!pane.contains("Finder operation"), "the old lead is gone")
        let settings = try Self.code("Variorum/Features/Settings/AppSettingsView.swift")
        #expect(settings.contains("handOffDoor: handOffDoor, roadDoors: roadDoors, roadStanding: roadStanding)"),
                "Settings hands Data Safety the new road's faces")
    }

    /// F-6: the Castle warning reads the OPEN library's posture on the new road, today's posture on today's road.
    @Test func theCastleWarningReadsTheOpenLibrarysPosture() throws {
        #expect(DataSafetyPane.castleWarningShows(todaysPosture: nil, roadPosture: .castle))
        #expect(DataSafetyPane.castleWarningShows(todaysPosture: .standard, roadPosture: .castle),
                "a new-road Castle library is warned whatever today's controller reads")
        #expect(!DataSafetyPane.castleWarningShows(todaysPosture: .castle, roadPosture: .standard),
                "the new road's posture decides there")
        #expect(DataSafetyPane.castleWarningShows(todaysPosture: .castle, roadPosture: nil), "today's road, as ever")
        #expect(!DataSafetyPane.castleWarningShows(todaysPosture: .standard, roadPosture: nil))
        #expect(!DataSafetyPane.castleWarningShows(todaysPosture: nil, roadPosture: nil), "never a guessed warning")
        let pane = try Self.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(pane.contains("if Self.castleWarningShows(todaysPosture: protection?.posture, roadPosture: roadPosture) {"))
        #expect(pane.contains("private var roadPosture: ProtectionMode? { roadStanding?.posture }"))
        // The faces carry the open library's posture (the record's mode) from the session.
        let faces = try Self.code("Shared/Protection/ProtectionOpenFaces.swift")
        #expect(faces.contains("posture: session.library.record?.mode)"))
    }

    /// The rows speak the rules' words, and stay true of today's road where they render.
    @Test func theRowsSpeakTheRulesWords() {
        // Rule 11: "a plain copy on disk would undo the promise; it is your call".
        #expect(ProtectionCopy.plaintextExportUnderLockedDown.contains("a scheduled plain-text copy on disk would undo Castle's promise"))
        #expect(ProtectionCopy.plaintextExportUnderLockedDown.hasSuffix("It's your call."))
        // Rule 17: the app's Restore from Backup is the door; the current library steps aside whole.
        let lead = DataSafetyCopy.restoringByTheDoor
        #expect(lead.contains("Restore from Backup") && lead.contains("steps aside whole into Previous Libraries"))
        #expect(lead.contains("File \u{25B8} Open Library\u{2026}") && lead.contains(StoreBackup.runbookFilename))
        #expect(!lead.contains("not a button"))
        // The checklist: twelve words; your Apple account; the passphrase opens THIS library (a copy opens with the one
        // it was made under).
        for gate in [StoreAtOpenMode.auto, .biometric] {
            let rows = ProtectionCopy.checklistRows(
                ProtectionLegs(hasPassphraseWrap: true, hasRecoveryWrap: true, appleKeyVerified: true, storeCustodyGated: false),
                mode: gate)
            let names = rows.map(\.name)
            #expect(names.contains("Twelve words") && names.contains("Your Apple account"), "\(names)")
            #expect(!names.contains("Recovery phrase") && !names.contains("iCloud key"))
            #expect(!rows.contains { $0.note.contains("iCloud key") || $0.note.contains("any copy") })
        }
        // Her no-shouty-caps rule: the floors say "and".
        for posture in [Posture.standard, .castle] {
            let floor = ProtectionCopy.postureCard(posture).first { $0.label == "The floor" }?.text ?? ""
            #expect(!floor.isEmpty && !floor.contains(" AND "), "\(posture): \(floor)")
        }
    }
}
