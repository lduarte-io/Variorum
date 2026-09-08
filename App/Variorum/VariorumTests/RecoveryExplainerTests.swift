//
//  RecoveryExplainerTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch G — **row 89: a section's meaning line
//  wraps to its full length, never truncates.** The orchestrator's row-74
//  probe (`orchestrator-e/r74-crop-side-by-side`) found the tray's "leaving
//  — on the 30-day clock" explainer cut mid-word at the inspector's default
//  width: "…and originals riding a family's countdown. put back keeps a row;
//  del…" — a sentence nobody could finish. `CalmSectionHeader`'s detail
//  carried `lineLimit(3)`; the family's explainers are three to six short
//  lines at a narrow pane. P-8's line-limit rule is for chrome LABELS; F's
//  row 63 ("a sentence's own point fell off the end") is the rule for prose.
//
//  The pin renders the SHIPPED header at the tray's narrowest width beside
//  a REFERENCE — the same words, the same font, no line limit at all — and
//  holds the shipped detail at least as tall as the reference: the whole
//  sentence, drawn. RED ON OLD: three lines against six.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The rendered height a probe reports (a class so the closure can write it).
private final class HeightBox: @unchecked Sendable {
    var height: CGFloat?
}

@MainActor
@Suite("The recovery family's explainers wrap whole (correction round, row 89)", .serialized)
struct RecoveryExplainerTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// The narrowest width a side panel's content gets: the column's
    /// minimum (280) less the tray's own padding.
    private static let narrow: CGFloat = 256

    /// **RETARGETED at 18d batch 2, claim intact.** The subject was the
    /// tray's leaving explainer, which her ruling U-9 SHRANK to one line
    /// (the filter names the populations now, so the sentence no longer
    /// lists them) — a short sentence cannot hold this pin, whose whole
    /// force is the `reference > oneLine * 3.5` guard below. The rule is the
    /// family's, not one string's, so the pin moves to the longest explainer
    /// the family still renders through `CalmSectionHeader`: Block History's
    /// came-from region, one door away from the tray and the room the tray's
    /// own kept-originals sentence points at.
    @Test func theTrayLeavingExplainerRendersWholeAtTheNarrowestPane() async throws {
        let detail = OriginPeekCopy.explainer
        let shipped = try Self.renderedHeight(width: Self.narrow) { report in
            CalmSectionHeader(
                tokens: .terminalLight, title: BlockHistoryPath.cameFromSection,
                detail: detail, onDetailHeight: report)
        }
        let reference = try Self.renderedHeight(width: Self.narrow) { report in
            Text(VoiceTokens.terminalLight.chromeLabel(detail))
                .font(VoiceTokens.terminalLight.small)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { report($0) }
        }
        let oneLine = try Self.renderedHeight(width: 4000) { report in
            Text(VoiceTokens.terminalLight.chromeLabel(detail))
                .font(VoiceTokens.terminalLight.small)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { report($0) }
        }
        #expect(reference > oneLine * 3.5,
                "the explainer needs more than three lines at \(Self.narrow) pt (reference \(reference), one line \(oneLine)) — else this pin would hold vacuously")
        #expect(shipped >= reference - 1,
                "the shipped meaning line is drawn whole: \(shipped) pt against the unlimited reference's \(reference)")
    }

    /// Mounts `content` alone in a real window of `width` and returns the
    /// height it reports through `report`.
    private static func renderedHeight<V: View>(
        width: CGFloat, @ViewBuilder _ content: @escaping (@escaping (CGFloat) -> Void) -> V
    ) throws -> CGFloat {
        let box = HeightBox()
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(
            rootView: content { box.height = $0 }
                .frame(width: width, alignment: .topLeading))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: 400)
        window.contentView = hosting
        window.orderFrontRegardless()
        for _ in 0..<40 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
            if box.height != nil { break }
        }
        return try #require(box.height, "the text reported its height at \(width)")
    }
}
