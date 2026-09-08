//
//  OutlineRoomTests.swift
//  VariorumTests
//
//  **THE OUTLINE'S ROOM** — the use-report round's 18d batch 3, her U-13:
//  *"the chapters feel too tightly clustered and the panel with the chapter
//  names should also be draggable to be a bit bigger"* · *"table of contents
//  in read mode for a note is horizontally limited and not changable, should
//  be adjustable."* (Ledger rows 22 · 26 · 33.)
//
//  Three claims, three kinds of evidence:
//
//  1. **The width brain's LEADING half is the trailing one's mirror** —
//     pure, and held against the shipped half rather than restated: for
//     every pointer x, leading(x) == trailing(total − x), R1-7's
//     past-the-edge floor included. The existing `SideColumnTests` ride
//     unmodified beside this (they own the trailing half).
//  2. **The navigator's rows have room** — a geometry oracle over the
//     MOUNTED book: what the chapter rows and the note rows actually drew,
//     and the air between one chapter's group and the next. RED on the
//     pre-fix shape (`VStack(spacing: 2)`, rows at their text height).
//  3. **Both columns remember their width across a remount** — the drawn
//     column, read back after a fresh hosting view over a fresh `@AppStorage`
//     read. RED on the pre-fix shape (a fixed `.frame(width: 190)` / the
//     fixed `NoteIndexColumn.width`, which no stored width can move).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The outline's room (18d batch 3, U-13)", .serialized)
struct OutlineRoomTests {

    // MARK: - 1. The width brain's leading half (pure)

    /// The mirror, stated as a relation and not as a second table of
    /// numbers: a leading column dragged to x keeps exactly the width a
    /// trailing column dragged to (total − x) keeps. If either half ever
    /// grows a rule the other lacks, this fails without anyone having to
    /// have thought of the case.
    @Test func theLeadingDragMirrorsTheTrailingOneAboutTheColumn() {
        let total: CGFloat = 1100
        for x in stride(from: CGFloat(-120), through: 1220, by: 20) {
            let leading = SideColumnLayout.draggedWidthFromLeading(
                pointerX: x, total: total, ideal: 420, minimum: 280)
            let trailing = SideColumnLayout.draggedWidth(
                pointerX: total - x, total: total, ideal: 420, minimum: 280)
            #expect(leading == trailing,
                    "x=\(x): leading \(leading) vs trailing \(trailing)")
        }
        // And with a host's own lowered ceiling (the navigator's), the two
        // halves still agree.
        for x in stride(from: CGFloat(-40), through: 900, by: 20) {
            let leading = SideColumnLayout.draggedWidthFromLeading(
                pointerX: x, total: 900, ideal: 190, minimum: 190, maximum: 360)
            let trailing = SideColumnLayout.draggedWidth(
                pointerX: 900 - x, total: 900, ideal: 190, minimum: 190, maximum: 360)
            #expect(leading == trailing, "x=\(x) at the navigator's clamps")
        }
    }

    /// R1-7's floor, on the LEADING side: a pointer dragged past the
    /// window's leading edge proposes ≤ 0, which the width rule reads as
    /// "nothing remembered" — so without the floor a column being dragged
    /// NARROW would snap WIDE at the edge. The mirror of the defect the
    /// trailing half was fixed for.
    @Test func aLeadingDragPastTheEdgeMeansTheMinimumNeverTheIdeal() {
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: -40, total: 1100, ideal: 420, minimum: 280) == 280)
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 0, total: 1100, ideal: 420, minimum: 280) == 280)
        // An ordinary drag asks for the room LEFT of the pointer.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 400, total: 1100, ideal: 420, minimum: 280) == 400)
        // Clamped by the ceiling the host set — the navigator's 360.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 900, total: 1400, ideal: 190, minimum: 190, maximum: 360) == 360)
        // And by the room the content keeps, whatever is dragged: a 600-pt
        // pane leaves the book's page its 320-pt floor, so the navigator
        // stops at 280 however far right the pointer goes.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 500, total: 600, ideal: 190, minimum: 190, maximum: 360) == 280)
    }

    /// A host may LOWER the ceiling; nothing else about the rule moves, and
    /// the shared default is what every caller written before 18d reads.
    @Test func aHostsOwnCeilingClampsTheRememberedWidth() {
        // The navigator's clamps: 190 … 360.
        #expect(SideColumnLayout.width(
            remembered: 900, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 360)
        #expect(SideColumnLayout.width(
            remembered: 300, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 300)
        #expect(SideColumnLayout.width(
            remembered: 40, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 190)
        // Unmeasured (the first pass, before any geometry read): inside the
        // host's floor and ceiling, so a stored 900 never draws at 900 for
        // a frame in a column whose ceiling is 360.
        #expect(SideColumnLayout.width(
            remembered: 900, ideal: 190, minimum: 190, total: 0, maximum: 360) == 360)
        // The default IS the shared ceiling (the note's panels, unchanged).
        #expect(SideColumnLayout.width(remembered: 900, ideal: 420, minimum: 280, total: 1100)
            == SideColumnLayout.width(remembered: 900, ideal: 420, minimum: 280,
                                      total: 1100, maximum: SideColumnLayout.maximum))
    }
}
