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
//  rule is a pure function, pinned both ways. VX-329 U1 — THE RELEASE SWITCH: today's road and its rows are gone; the
//  pins now hold that they are gone, and the warning reads the open library's posture alone.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2c — VX-379's pane rows: today's rows gone with today's road, the rest in the rules' words")
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

    /// W-1: the posture box (`ProtectionStatusRow`, today's tier) rendered on today's road only — and left with it
    /// (VX-329 U1): composed nowhere, its file gone.
    @Test func thePostureBoxIsGone() throws {
        let root = try Self.code("Variorum/RootView.swift")
        #expect(!root.contains("ProtectionStatusRow("), "composed nowhere")
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        #expect(!FileManager.default.fileExists(atPath: app.appendingPathComponent("Variorum/ProtectionStatusRow.swift").path))
    }

    /// F-U3-1 and today's posture's backup lines: Data Safety's today's rows rendered only with no new-road faces — and
    /// left with today's road (VX-329 U1); the pane takes the road's faces.
    @Test func dataSafetysTodaysRowsAreGone() throws {
        let pane = try Self.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(!pane.contains("BackupsPostureLines"))
        #expect(!pane.contains("restoringByTheDoor"))
        #expect(!pane.contains("roadStanding == nil"), "no today's-road arm is left")
        #expect(!pane.contains("Finder operation"), "the old lead is gone")
        let settings = try Self.code("Variorum/Features/Settings/AppSettingsView.swift")
        #expect(settings.contains("handOffDoor: handOffDoor, roadDoors: roadDoors, roadStanding: roadStanding)"),
                "Settings hands Data Safety the road's faces")
    }

    /// F-6: the Castle warning reads the OPEN library's posture (VX-329 U1: the one road — today's posture, its other
    /// input, left with today's road).
    @Test func theCastleWarningReadsTheOpenLibrarysPosture() throws {
        #expect(DataSafetyPane.castleWarningShows(roadPosture: .castle))
        #expect(!DataSafetyPane.castleWarningShows(roadPosture: .standard))
        #expect(!DataSafetyPane.castleWarningShows(roadPosture: nil), "never a guessed warning")
        let pane = try Self.code("Variorum/Features/Settings/DataSafetyPane.swift")
        #expect(pane.contains("if Self.castleWarningShows(roadPosture: roadPosture) {"))
        #expect(pane.contains("private var roadPosture: ProtectionMode? { roadStanding?.posture }"))
        // The faces carry the open library's posture (the record's mode) from the session.
        let faces = try Self.code("Shared/Protection/ProtectionOpenFaces.swift")
        #expect(faces.contains("posture: session.library.record?.mode"))
    }

    /// The rows speak the rules' words (VX-329 U1: the restoring lead, the checklist and the posture floors — today's
    /// rows — left with today's road).
    @Test func theRowsSpeakTheRulesWords() {
        // Rule 11: "a plain copy on disk would undo the promise; it is your call".
        #expect(ProtectionCopy.plaintextExportUnderLockedDown.contains("a scheduled plain-text copy on disk would undo Castle's promise"))
        #expect(ProtectionCopy.plaintextExportUnderLockedDown.hasSuffix("It's your call."))
    }
}
