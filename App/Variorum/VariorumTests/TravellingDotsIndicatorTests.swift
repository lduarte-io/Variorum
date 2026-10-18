//
//  TravellingDotsIndicatorTests.swift
//  VariorumTests
//
//  pre-13x batch 5b, item 1 (ledger 32) — the ORIGINAL animated indicator:
//  its brain (the dots travel there and back; Reduce Motion rests them),
//  the view hosted ALONE in a window (the real-click rig's mechanism-only
//  rule — never a whole surface), and the grep-shaped pin that NO
//  protection-surface file on either platform names `ProgressView` (the
//  system spinner) any more — the rest of the app keeps its spinners.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("pre-13x 5b — the travelling-dots indicator (ledger 32)")
struct TravellingDotsIndicatorTests {
    /// The brain: in motion the lead dot goes out (phase 0 → ½ maps to
    /// 0 → 1) and comes BACK (phase ½ → 1 maps 1 → 0) — there and back, the
    /// trailing dots behind it; under Reduce Motion the dots REST evenly
    /// spaced whatever the phase.
    @Test func theDotsTravelThereAndBackAndRestUnderReduceMotion() {
        let count = TravellingDotsIndicator.dotCount
        let lead = { (phase: Double) in
            TravellingDotsIndicator.dotPositions(phase: phase, reduceMotion: false, count: count)[0]
        }
        #expect(abs(lead(0) - 0) < 1e-9, "at the start of the trip the lead dot is at the line's start")
        #expect(abs(lead(0.25) - 0.5) < 1e-9, "a quarter in — halfway out")
        #expect(abs(lead(0.5) - 1) < 1e-9, "half the trip — the far end")
        #expect(abs(lead(0.75) - 0.5) < 1e-9, "three quarters — halfway BACK")
        #expect(lead(0.4) > lead(0.3) && lead(0.7) < lead(0.6), "outward, then homeward — movement, not a loop")
        // The trail: on the outward leg the dots behind sit behind.
        let outward = TravellingDotsIndicator.dotPositions(phase: 0.3, reduceMotion: false, count: count)
        #expect(outward[0] > outward[1] && outward[1] > outward[2], "a trail — the followers behind the lead: \(outward)")
        // Every position stays on the line, at every phase.
        for step in 0..<64 {
            let positions = TravellingDotsIndicator.dotPositions(phase: Double(step) / 64, reduceMotion: false, count: count)
            #expect(positions.count == count && positions.allSatisfy { (0...1).contains($0) }, "phase \(step)/64: \(positions)")
        }
        // Reduce Motion: evenly spaced, phase-independent.
        let rest = TravellingDotsIndicator.dotPositions(phase: 0, reduceMotion: true, count: 3)
        #expect(rest == [0.25, 0.5, 0.75])
        for phase in [0.1, 0.5, 0.9] {
            #expect(TravellingDotsIndicator.dotPositions(phase: phase, reduceMotion: true, count: 3) == rest, "resting dots never move")
        }
        #expect(TravellingDotsIndicator.dotPositions(phase: 0.5, reduceMotion: false, count: 0).isEmpty)
    }

    /// The view builds and lays out ALONE in a real window (never a whole
    /// surface under the rig), and its composition carries the spoken label.
    @Test func theIndicatorHostsAloneAndSpeaksWorking() async {
        let indicator = TravellingDotsIndicator(ink: .secondary)
        await SurfaceComposition.host(indicator, size: NSSize(width: 120, height: 40))
        let shown = SurfaceComposition.text(of: indicator.body)
        #expect(SurfaceComposition.carries(TravellingDotsIndicator.accessibilityLabel, in: shown),
                "the indicator is spoken as Working…")
        #expect(TravellingDotsIndicator.accessibilityLabel == "Working…")
        let paged = TravellingDotsIndicator(pageStyle: nil)
        await SurfaceComposition.host(paged, size: NSSize(width: 120, height: 40))
    }

    /// THE GREP PIN: the protection surfaces on BOTH platforms name no
    /// `ProgressView` — the system spinner is gone from every ceremony,
    /// lobby and key door; the list is the design's sites plus the same
    /// family's siblings found by the 5b walk. Composed so this file's own
    /// text never trips the walk.
    @Test func noProtectionSurfaceNamesTheSystemSpinner() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let spinner = "Progress" + "View("
        let surfaces = [
            "Shared/EncryptionViews.swift", "Shared/KeyDoorView.swift",
            "Shared/SyncEnrollmentView.swift", "Shared/SecretCheck.swift",
            "Variorum/StoreLockView.swift", "Variorum/LibraryMissingView.swift",
            "Variorum/Features/Settings/ProtectionPane.swift",
            // VX-306 U2: the new road's interlude card and set-passphrase sheet.
            "Variorum/Features/Protection/RoadInterludeCard.swift",
            "Variorum/Features/Protection/SetPassphraseSheet.swift",
            // VX-306 U3: the two doors' sheet; the phone's new-road faces.
            "Variorum/Features/Protection/CopyDoorsSheet.swift",
            "Variorum/Features/Protection/LookInsideSheet.swift",
            "VariorumMobile/Features/Protection/MobileRoadFaces.swift",
            "VariorumMobile/Features/Protection/MobilePostureSheets.swift",
            "VariorumMobile/Features/Protection/MobileProtectionCeremonies.swift",
            "VariorumMobile/Features/Protection/MobileStoreLockView.swift",
            "VariorumMobile/Features/Protection/MobileLibraryMissingView.swift",
            "VariorumMobile/Features/Protection/MobileProtectionSheet.swift",
        ]
        var offenders: [String] = []
        for relative in surfaces {
            let url = appRoot.appendingPathComponent(relative)
            #expect(FileManager.default.fileExists(atPath: url.path), "surface missing: \(relative)")
            let text = try String(contentsOf: url, encoding: .utf8)
            if text.contains(spinner) { offenders.append(relative) }
            #expect(text.contains("TravellingDotsIndicator") || relative.hasSuffix("MobileProtectionSheet.swift"),
                    "\(relative) should render the indicator where it once spun")
        }
        #expect(offenders.isEmpty, "the system spinner survives on a protection surface: \(offenders)")
    }
}
