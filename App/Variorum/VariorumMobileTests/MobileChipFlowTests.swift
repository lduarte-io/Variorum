//
//  MobileChipFlowTests.swift
//  VariorumMobileTests
//
//  Parity D2 — the masthead chip flow's row-breaking brain (the routed
//  crowding item's pinnable half; the Layout conformance is its thin
//  face, evidenced by the screenshot walk — the A1-masthead
//  not-headless-testable class).
//

import CoreGraphics
import Testing
@testable import VariorumMobile

@Suite("Mobile chip flow — the masthead crowding answer (parity D2)")
struct MobileChipFlowTests {
    /// The one row-breaking rule: greedy fill · break exactly when the
    /// next chip plus its leading spacing would cross the line · an
    /// over-wide chip gets its own line, never dropped · calm at rest
    /// (chips that fit stay one line).
    /// D ladder R1-1: an over-wide chip (user text — a long lens name)
    /// clamps to the available width so truncation re-engages; a finite
    /// clamp never touches narrower chips, and an unspecified (infinite)
    /// width clamps nothing.
    @Test func anOverWideChipClampsToTheAvailableWidth() {
        #expect(MobileChipFlow.clampedWidths([500, 80], available: 393)
            == [393, 80])
        #expect(MobileChipFlow.clampedWidths([500, 80], available: .infinity)
            == [500, 80])
        // The clamped chip occupies its own full row in the brain.
        #expect(MobileChipFlow.rows(
            widths: MobileChipFlow.clampedWidths([500, 80], available: 393),
            available: 393, spacing: 6) == [[0], [1]])
    }

    @Test func theRowBreakingArithmeticIsExact() {
        // Calm at rest: five bare-word chips fit one line.
        #expect(MobileChipFlow.rows(
            widths: [50, 30, 65, 45, 30], available: 353, spacing: 12)
            == [[0, 1, 2, 3, 4]])

        // The break lands exactly where the spacing arithmetic says:
        // 100 + 12 + 100 = 212 fits 212; +12+100 = 324 would cross 300.
        #expect(MobileChipFlow.rows(
            widths: [100, 100, 100], available: 212, spacing: 12)
            == [[0, 1], [2]])
        // One point tighter and the second chip already wraps.
        #expect(MobileChipFlow.rows(
            widths: [100, 100, 100], available: 211, spacing: 12)
            == [[0], [1], [2]])

        // A grown chip ("lens: the other reading") wraps ONLY itself —
        // the chips before it hold their line (60+12+80+12+70 = 234
        // fits; +12+200 crosses).
        #expect(MobileChipFlow.rows(
            widths: [60, 80, 70, 200], available: 260, spacing: 12)
            == [[0, 1, 2], [3]])

        // An over-wide chip gets a line of its own — never dropped,
        // never clipped out of the flow's bookkeeping.
        #expect(MobileChipFlow.rows(
            widths: [400, 50], available: 353, spacing: 12)
            == [[0], [1]])

        // Empty input: no rows (the bare masthead renders nothing).
        #expect(MobileChipFlow.rows(widths: [], available: 353, spacing: 12)
            == [[Int]]())
    }
}
