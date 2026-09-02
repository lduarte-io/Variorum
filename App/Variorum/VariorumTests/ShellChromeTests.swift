//
//  ShellChromeTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — THE CHROME's pins: the flat shell
//  (row 2), the sidebar column's one row pitch and its height-threshold
//  compression (row 3), and the Open strip's rows back under the rail at
//  that pitch (row 3's "tabs").
//
//  Red-on-old, stated per pin:
//  · the flat shell — the pre-round `RootView` was a `NavigationSplitView`,
//    which AppKit backs with an `NSSplitView`; the flat `ShellSplit` is an
//    `HStack` with none. The mount walk below finds ZERO at rest on the
//    new tree and one on the old.
//  · the pitch — the pre-round Open strip drew ~21 pt rows (4 pt padding, a
//    19 pt floor, 1 pt spacing) at EVERY height; the oracle below reads the
//    row the column actually drew and asserts the generous 30.
//  · the threshold function did not exist (the bottom bar's precedent:
//    `CommitBar.usesTwoRows`) — pinned at its threshold both ways, and the
//    unmeasured case never compresses.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The sidebar's row pitch (correction round, row 3)")
struct SidebarLayoutTests {
    /// Twenty rows is the column at its fullest ordinary shape: one starred
    /// note, five areas, the SEVEN-mode rail (R-cor-5/7 — batch C; the
    /// fixture said "eight" until ladder R1-12) and seven strip rows in
    /// its window — with all three headed groups present.
    private let fullColumnRows = SidebarLayout.rowCount(
        starred: 1, areas: 5, rail: 7, openNotes: 12)

    @Test func ordinaryHeightsKeepTheGenerousPitch() {
        #expect(fullColumnRows == 20, "the strip counts only its window's rows")
        #expect(!SidebarLayout.compressesRows(columnHeight: 1000, rows: fullColumnRows))
        #expect(SidebarLayout.rowHeight(columnHeight: 1000, rows: fullColumnRows)
                == SidebarLayout.generousRowHeight)
        #expect(SidebarLayout.generousRowHeight == 30, "the mockup's `.sb-row` pitch")
    }

    @Test func aColumnTooShortForTheGenerousLayoutCompresses() {
        // 20 rows × 30 + the fixed chrome = 774 pt of generous layout.
        let needed = 20 * SidebarLayout.generousRowHeight + SidebarLayout.fixedChromeHeight
        #expect(SidebarLayout.compressesRows(columnHeight: needed - 1, rows: fullColumnRows))
        #expect(!SidebarLayout.compressesRows(columnHeight: needed, rows: fullColumnRows),
                "exactly fitting is fitting")
        #expect(SidebarLayout.rowHeight(columnHeight: 600, rows: fullColumnRows)
                == SidebarLayout.compactRowHeight)
    }

    /// Ladder R1-12: the chrome counts the headed groups actually present —
    /// a column with no starred group and no rail (one header, one
    /// separator) has ~82 pt more room for its rows than the full column.
    @Test func theChromeCountsOnlyTheHeadedGroupsPresent() {
        #expect(SidebarLayout.chromeHeight(headedGroups: 3) == SidebarLayout.fixedChromeHeight)
        #expect(SidebarLayout.chromeHeight(headedGroups: 1) == SidebarLayout.fixedChromeHeight - 2 * 41)
        // Twelve rows (five areas + seven strip rows) with ONE headed group
        // (the strip): the three-group chrome would compress at this height;
        // the honest count fits.
        let rows = SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 12)
        let height = 12 * SidebarLayout.generousRowHeight + SidebarLayout.chromeHeight(headedGroups: 1)
        #expect(SidebarLayout.compressesRows(columnHeight: height, rows: rows, headedGroups: 3),
                "counted as three groups it would compress")
        #expect(!SidebarLayout.compressesRows(columnHeight: height, rows: rows, headedGroups: 1),
                "counted as the one group present it fits")
    }

    @Test func fewRowsNeverCompressInAShortWindow() {
        // Five areas alone in a 400 pt column: plenty of room — a fixed
        // pixel threshold would have squeezed them for nothing.
        #expect(!SidebarLayout.compressesRows(columnHeight: 400, rows: 5))
    }

    @Test func anUnmeasuredColumnNeverCompresses() {
        // Height 0 = the first pass before geometry lands (the bar's third
        // pin): generous, so the column does not flash compact while mounting.
        #expect(!SidebarLayout.compressesRows(columnHeight: 0, rows: 40))
    }

    @Test func theOpenStripWindowIsHerSevenAndAHalf() {
        #expect(SidebarLayout.openStripWindow == 7)
        #expect(SidebarLayout.openStripMaxHeight(rowHeight: 30) == 225)
        #expect(SidebarLayout.openStripRowsCounted(openNotes: 3) == 3)
        #expect(SidebarLayout.openStripRowsCounted(openNotes: 20) == 7)
    }
}

@MainActor
private func countSplitViews(in view: NSView) -> Int {
    var count = view is NSSplitView ? 1 : 0
    for sub in view.subviews { count += countSplitViews(in: sub) }
    return count
}

@MainActor
@Suite("The flat shell (correction round, row 2) and the strip's pitch (row 3)")
struct ShellChromeTests {
    /// **Row 2 — the shell mounts FLAT.** The pre-round root was a
    /// `NavigationSplitView` (AppKit: an `NSSplitView` under the hosting
    /// view, drawing Tahoe's floating glass sidebar); the flat `ShellSplit`
    /// is an `HStack`. At rest — no inspector presented — the window's view
    /// tree holds no split view at all. RED ON OLD: one.
    ///
    /// **Row 3 — the Open strip's rows carry the column's generous pitch.**
    /// A note is visited so the strip shows it; the oracle reads the row the
    /// column DREW. RED ON OLD: ~21 pt (the strip's own compressed row).
    @Test func theShellMountsFlatAndTheStripRowsAreGenerous() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a tab")
            let router = ShellRouter()
            #if DEBUG
            SidebarGeometry.openRowHeight = nil
            #endif

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<200 where router.workspace.history().current == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(countSplitViews(in: hosting) == 0,
                    "no NSSplitView backs the shell at rest — the flat HStack, not the system split view and its glass pane")

            // The strip: visit a note, let the column lay its row out.
            router.workspace.visit(.post(post.id))
            #if DEBUG
            for _ in 0..<200 where SidebarGeometry.openRowHeight == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            let drawn = try #require(SidebarGeometry.openRowHeight,
                                     "the strip drew its row for the visited note")
            #expect(drawn == SidebarLayout.generousRowHeight,
                    "an Open-strip row at an ordinary height is the generous 30 pt row (the pre-round strip drew ~21)")
            #endif
        }
    }

    @Test func theSidebarWidthIsClampedToAUsableColumn() {
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(10) == 180)
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(210) == 210)
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(5000) == 360)
    }

    /// The toggle is a declared act on both of its doors (P-1): the View
    /// menu on the platform's own ⌃⌘S, and the toolbar.
    @Test func theSidebarToggleIsDeclaredOnItsTwoDoors() {
        let cap = CapabilityRegistry.capability(.toggleSidebar)
        #expect(cap.doors.contains(.menuBar))
        #expect(cap.doors.contains(.surface))
        #expect(cap.shortcutLabel == "\u{2303}\u{2318}S")
        #expect(RootView.surfaceCapabilities == [.toggleSidebar])
        #expect(EditorCommands.menuRendered.contains(.toggleSidebar))
        let router = ShellRouter()
        #expect(router.sidebarShown, "a window opens with its sidebar")
        router.sidebarShown.toggle()
        #expect(!router.sidebarShown)
    }
}
