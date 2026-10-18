//
//  OpenListLayoutTests.swift
//  VariorumTests
//
//  VX-283 run, U1 — THE OPEN LIST'S LAYOUT: VX-285 (it grows into the
//  sidebar's free space and stops above the sync footer) and VX-286 (the
//  overlay scroll bar rides in the margin, never over ✕ or ★).
//
//  Her words (2026-10-13): *"I don't like that the open tabs cut off like
//  this - they should extend further down if there's the space for it
//  (though they should always stop before the syncing area begins."* · *"the
//  scroll bar on there goes over the x out button"* · *"the tab close x gets
//  hidden behind the scroll"*.
//
//  RED ON OLD, stated per pin (verified by behavioural revert in the stage
//  window — the U1 record names the revert and its counts):
//  · VX-285 — the old strip was capped at `rowHeight × 7.5` whatever the
//    window, so in a tall column with twenty notes open the list drew 225 pt
//    and stopped far above the footer; in a short one it drew the same 7½
//    rows, never the floor.
//  · VX-286 — both scrolling sections took the group's margin OUTSIDE their
//    scroll view, so the scroll view's trailing edge WAS the rows' trailing
//    edge (a gap of 0) and the overlay bar drew on the ✕ and the ★.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure height (VX-285)

@Suite("VX-285 — the Open list's height is the room down to the footer")
struct OpenListHeightTests {
    @Test func theListTakesTheRoomBetweenItsTopAndTheFooter() {
        // A 735-pt visible column, the list starting 213 pt down, 12 of air.
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 735, listTop: 213, bottomPadding: 12, rowHeight: 30) == 510)
        // Rounded DOWN, so the filled column is never a hair taller than it shows.
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 735.6, listTop: 213, bottomPadding: 12, rowHeight: 30) == 510)
    }

    @Test func aShortColumnFloorsTheListAndLetsTheOuterScrollCarryTheRest() {
        let floor = 30 * SidebarLayout.openListFloorRows
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 265, listTop: 183, bottomPadding: 12, rowHeight: 30) == floor)
        // The floor follows the drawn pitch (the compact column's 24-pt rows).
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 265, listTop: 183, bottomPadding: 12, rowHeight: 24)
                == 24 * SidebarLayout.openListFloorRows)
    }

    @Test func anUnmeasuredColumnClaimsOnlyTheFloor() {
        let floor = 30 * SidebarLayout.openListFloorRows
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 0, listTop: 0, bottomPadding: 12, rowHeight: 30) == floor)
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 900, listTop: 0, bottomPadding: 12, rowHeight: 30) == floor,
                "a list whose top has not been measured never claims the whole column")
    }

    @Test func theRowsHugWhileTheyFitAndScrollPastIt() {
        #expect(SidebarLayout.openListRowsFit(rows: 17, rowHeight: 30, maxHeight: 510))
        #expect(!SidebarLayout.openListRowsFit(rows: 18, rowHeight: 30, maxHeight: 510))
        #expect(SidebarLayout.openListRowsFit(rows: 0, rowHeight: 30, maxHeight: 105))
    }
}

// MARK: - The mounted pins: what the column actually DREW

@MainActor
private struct OpenListOracleHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    /// The stand-in for the sync footer — `RootView.statusRows`' slot.
    let footerHeight: CGFloat

    var body: some View {
        SidebarView(
            session: session, model: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session),
            workspace: workspace, stars: stars,
            selection: .constant(nil),
            noteBox: nil,
            bottom: AnyView(Color.clear.frame(height: footerHeight)))
            .frame(width: 230)
            .environment(theme)
    }
}

@MainActor
@Suite("VX-285 / VX-286 — the Open list and Starred as drawn", .serialized)
struct OpenListLayoutMountTests {
    private static let footerHeight: CGFloat = 64

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Mounts the column at `height` with `openNotes` open and `starred`
    /// stars, waits until the drawn geometry STOPS MOVING (the list's height
    /// is a function of two measurements, so it lands a pass or two after
    /// the first layout), and hands the drawn rectangles to `check`.
    private func withColumn(
        height: CGFloat, openNotes: Int, starred: Int = 0,
        check: @MainActor (_ open: SidebarGeometry.SectionDraw,
                           _ starred: SidebarGeometry.SectionDraw?,
                           _ column: CGRect) throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys must not collide with a
            // parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 285))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try (1...max(openNotes, starred)).map {
                try session.operations.createPost(title: "note \($0)")
            }
            if starred > 0 {
                // The fixture writes the starred setting the door would write,
                // independent of the star cap (`StarredScrollTests`' reason).
                let keys = notes.prefix(starred).map { StarTarget.post($0.id).key }
                let json = String(decoding: try JSONEncoder().encode(Array(keys)), as: UTF8.self)
                try await db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO setting (key, value) VALUES ('starred', ?)
                            ON CONFLICT(key) DO UPDATE SET value = excluded.value
                            """,
                        arguments: [json])
                }
            }

            let workspace = WorkspaceModel()
            for note in notes.prefix(openNotes) { workspace.visit(.post(note.id)) }
            #expect(workspace.openNotes.shown.count == openNotes)
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            let key = SidebarGeometry.bodyKey(for: workspace)
            SidebarGeometry.forgetSections(for: workspace)
            defer { SidebarGeometry.forgetSections(for: workspace) }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: OpenListOracleHost(
                session: session, workspace: workspace, stars: stars, theme: theme,
                footerHeight: Self.footerHeight))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            // Settle: drawn, starred observed, and STILL for several turns.
            var last: CGRect?
            var still = 0
            for _ in 0..<200 {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
                let draws = SidebarGeometry.sectionDraws[key]
                let open = draws?[.open]
                let ready = open?.scroll != nil && open?.firstRow != nil
                    && SidebarGeometry.columnScrollFrames[key] != nil
                    && (starred == 0 || (stars.items.count == starred
                        && draws?[.starred]?.scroll != nil
                        && draws?[.starred]?.firstRow != nil))
                guard ready else { continue }
                if open?.scroll == last { still += 1 } else { still = 0 }
                last = open?.scroll
                if still >= 5 { break }
            }

            let draws = try #require(SidebarGeometry.sectionDraws[key])
            let open = try #require(draws[.open])
            let column = try #require(SidebarGeometry.columnScrollFrames[key])
            try check(open, starred > 0 ? draws[.starred] : nil, column)
        }
    }

    /// **VX-285, the tall column.** Twenty notes open in an 800-pt column:
    /// the list runs DOWN to the sync footer — its bottom one content-padding
    /// above the column scroll's bottom, which is the footer's top — and
    /// stops there. RED ON OLD: 225 pt (7½ rows) and ~270 pt of empty column
    /// below it.
    @Test func inATallColumnTheListRunsDownToTheFooterAndStops() async throws {
        try await withColumn(height: 800, openNotes: 20) { open, _, column in
            let list = try #require(open.scroll)
            let row = try #require(open.firstRow)
            let window7 = SidebarLayout.scrollingSectionMaxHeight(rowHeight: row.height)
            print("[VX-285 tall] list \(list) · column \(column) · row \(row.height)")
            #expect(list.height > window7 + row.height,
                    "the list grew past the old 7½-row window: drew \(list.height), the old cap \(window7)")
            let floorOfFooter = column.maxY - SidebarLayout.contentBottomPadding
            #expect(list.maxY <= floorOfFooter + 0.5,
                    "it stops above the footer: bottom \(list.maxY), the footer's edge less the air \(floorOfFooter)")
            #expect(list.maxY >= floorOfFooter - 1.5,
                    "…and runs right down to it: bottom \(list.maxY) vs \(floorOfFooter)")
        }
    }

    /// **VX-285, the short column.** In a 330-pt column the room under the
    /// list is less than its floor, so the list takes the floor and the
    /// column's own last-resort scroll carries the rest (the list's bottom
    /// sits past the visible column). RED ON OLD: 7½ rows, not 3½.
    @Test func inAShortColumnTheListTakesItsFloorAndTheColumnScrolls() async throws {
        try await withColumn(height: 330, openNotes: 20) { open, _, column in
            let list = try #require(open.scroll)
            let row = try #require(open.firstRow)
            print("[VX-285 short] list \(list) · column \(column) · row \(row.height)")
            #expect(abs(list.height - row.height * SidebarLayout.openListFloorRows) <= 0.5,
                    "the floor — \(SidebarLayout.openListFloorRows) rows: drew \(list.height) at a \(row.height)-pt row")
            #expect(list.maxY > column.maxY,
                    "the list runs past the visible column, so the outer scroll carries it")
        }
    }

    /// **VX-286, both sections.** Each scrolling section's scroll view spans
    /// the column, so its trailing edge sits a whole group margin beyond its
    /// rows' trailing edge — the room the overlay bar rides in, beside the ✕
    /// and the ★ rather than over them. The rows themselves land exactly
    /// where they did (one group margin in from the column's edge). RED ON
    /// OLD: a trailing gap of 0 for both — the bar's edge was the rows' edge.
    @Test func bothScrollingSectionsKeepTheirBarInTheMargin() async throws {
        try await withColumn(height: 800, openNotes: 20, starred: 9) { open, starred, column in
            for (name, draw) in [("open", open), ("starred", starred)] {
                let draw = try #require(draw, "\(name) drew")
                let scroll = try #require(draw.scroll, "\(name)'s scroll view drew")
                let row = try #require(draw.firstRow, "\(name)'s first row drew")
                print("[VX-286 \(name)] scroll \(scroll) · row \(row) · column \(column)")
                #expect(scroll.maxX - row.maxX >= SidebarLayout.groupPadding - 0.5,
                        "\(name): the scroll bar's edge sits a margin past the rows' — \(scroll.maxX - row.maxX)")
                #expect(abs(row.minX - (column.minX + SidebarLayout.groupPadding)) <= 0.5,
                        "\(name): the rows still start one group margin in — \(row.minX - column.minX)")
                #expect(abs(column.maxX - row.maxX - SidebarLayout.groupPadding) <= 0.5,
                        "\(name): …and still end one group margin short of the column's edge")
            }
        }
    }
}
