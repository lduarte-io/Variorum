//
//  StarredScrollTests.swift
//  VariorumTests
//
//  13u2 UNIT D — item 10, her words verbatim: *"I'm fine with where starred
//  items are on the mac but make sure in 13u that it says that starred items
//  should only show up to like 7 items and then it should start scrolling."*
//
//  PLACEMENT IS UNCHANGED — she said so. What changes is that the Starred
//  section is now a BOUNDED, scrolling section on the Open strip's shape,
//  through the one `SidebarLayout.scrollingSectionWindow`. (Act 10 item 9
//  named its own window "the starred precedent's ~7"; the precedent did not
//  exist — Starred rendered every row and pushed the column into its compact
//  pitch. This is that precedent made real, in both directions.)
//
//  The finding this item handed up (QUESTIONS #112(b)) is RULED: the cap
//  rose 5 → 15 at her 2026-09-18 word ("scroll should be allowed, maybe 15
//  items max"), so past seven stars this window really engages in the
//  shipped app. The copy sites were re-worded in the same change.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Item 10 — Starred is a bounded, scrolling section")
struct StarredScrollLayoutTests {
    /// **EDITED IN PLACE BY HER ASK — VX-285** (the VX-283 run, U1). This pin
    /// held ONE window constant for both scrolling sections; her VX-285 ask
    /// (*"Open tabs should extend the full height of the screen that they can
    /// … until the synced portion of the bottom row starts"*) splits it on
    /// purpose — the Open list grows into the free space while STARRED keeps
    /// its ~7 (her item-10 words above). The ruled-change class: the half of
    /// the claim that survives is Starred's, unchanged, and the new half is
    /// that the Open list no longer shares the window.
    @Test func theWindowIsOneConstantForBothScrollingSections() {
        // Starred keeps its ~7, its 7½-row tallest form, unchanged.
        #expect(SidebarLayout.scrollingSectionWindow == 7)
        #expect(SidebarLayout.scrollingSectionMaxHeight(rowHeight: 30) == 225)
        // The Open list no longer shares it: in a tall column it grows past
        // Starred's window, down to the footer.
        let open = SidebarLayout.openListMaxHeight(
            visibleHeight: 900, listTop: 300, bottomPadding: 12, rowHeight: 30)
        #expect(open > SidebarLayout.scrollingSectionMaxHeight(rowHeight: 30))
    }

    @Test func theFitTestCapsStarredAtItsWindow() {
        // RED ON OLD: `rowCount` added every starred row, so a long starred
        // list compressed the whole column — a section that scrolls must
        // not push the pitch of the rows beside it.
        #expect(SidebarLayout.rowCount(starred: 20, areas: 5, rail: 0, openNotes: 0) == 12)
        #expect(SidebarLayout.rowCount(starred: 3, areas: 5, rail: 0, openNotes: 0) == 8)
        #expect(SidebarLayout.scrollingSectionRowsCounted(rows: 3) == 3)
        #expect(SidebarLayout.scrollingSectionRowsCounted(rows: 20) == 7)
    }

    @Test func aLongStarredListNoLongerCompressesAColumnThatFitsTheRest() {
        // The same claim where it bites: a 900-pt column with five areas and
        // twenty starred rows. RED ON OLD (25 rows × 30 + chrome > 900 ⇒
        // compact); GREEN now (12 rows fit generously, the section scrolls).
        let rows = SidebarLayout.rowCount(starred: 20, areas: 5, rail: 0, openNotes: 0)
        #expect(SidebarLayout.rowHeight(columnHeight: 900, rows: rows, headedGroups: 2)
                == SidebarLayout.generousRowHeight)
    }
}

// MARK: - The mounted pin: what the section actually DREW

@MainActor
private struct StarredOracleHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore

    var body: some View {
        SidebarView(
            session: session, model: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session),
            workspace: workspace, stars: stars,
            selection: .constant(nil),
            noteBox: nil)
            .frame(width: 230)
            .environment(theme)
    }
}

@MainActor
@Suite("Item 10 — the Starred section's drawn height", .serialized)
struct StarredScrollMountTests {
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// Twelve starred notes in a tall column: the section draws at most its
    /// window (+ the half row that says there is more), never twelve rows.
    ///
    /// **Why the fixture writes the `setting` row directly** and not through
    /// `Operations.setStarred`: this pin is about the SECTION'S GEOMETRY when
    /// the list outgrows the window — not about the cap — so the fixture must
    /// stay independent of `starLimit`'s number (5 when this pin was born,
    /// 15 since her 2026-09-18 #112(b) ruling). It writes exactly the value
    /// the door would write (`StarTarget.key`s, JSON, in star order).
    @Test func twelveStarredRowsScrollInsideTheWindowInsteadOfGrowingTheColumn() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys below must not collide
            // with a parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try (1...12).map { try session.operations.createPost(title: "starred \($0)") }
            let keys = notes.map { StarTarget.post($0.id).key }
            let json = String(decoding: try JSONEncoder().encode(keys), as: UTF8.self)
            try await db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO setting (key, value) VALUES ('starred', ?)
                        ON CONFLICT(key) DO UPDATE SET value = excluded.value
                        """,
                    arguments: [json])
            }

            let workspace = WorkspaceModel()
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            let key = SidebarGeometry.bodyKey(for: workspace)
            SidebarGeometry.starredSectionHeights[key] = nil

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: StarredOracleHost(
                session: session, workspace: workspace, stars: stars, theme: theme))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                stars.items.count == 12
                    && (SidebarGeometry.starredSectionHeights[key] ?? 0) > 0
            })

            #expect(stars.items.count == 12, "the fixture's twelve stars are observed")
            let drawn = try #require(SidebarGeometry.starredSectionHeights[key])
            let window7 = SidebarLayout.scrollingSectionMaxHeight(
                rowHeight: SidebarLayout.generousRowHeight)
            // RED ON OLD: the section drew all twelve rows (≥ 360 pt).
            #expect(drawn <= window7 + 1,
                    "drew \(drawn); the window is \(window7)")
            #expect(drawn > SidebarLayout.generousRowHeight * 5,
                    "…and it is not collapsed either — it fills its window")
            window.orderOut(nil)
            SidebarGeometry.starredSectionHeights[key] = nil
        }
    }
}
