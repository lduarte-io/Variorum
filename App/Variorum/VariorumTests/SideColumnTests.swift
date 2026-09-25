//
//  SideColumnTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch G — **row 74: the note's side column
//  holds its boundary when the window is inactive.** The orchestrator's
//  window-id probe (`orchestrator-e/r74-tray-active/inactive`) confirmed at
//  the note's side what batch E found at the Library's: the `.inspector`
//  host draws its divider in a KEY window only — active, one faint line at
//  the boundary; inactive, none. The tray, Block History, Versions,
//  references and scraps all hung off that one host, and the scraps area's
//  tray off another.
//
//  The pins: the width rule, pure; and the REAL detail mounted with
//  `controlActiveState = .inactive`, the tray opened through the router's
//  seam — OUR divider reports its frame (1 pt wide, the column's height,
//  at the panel's edge), the composition carries no SwiftUI inspector, and
//  the view tree carries no `InspectorStyleContext`. RED ON OLD: under the
//  `.inspector` host no divider of ours exists (the settle times out, the
//  frame stays nil) and the composition names the inspector modifier.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The side column of our own (correction round, row 74)", .serialized)
struct SideColumnTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 80
    ) async -> Bool {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return true }
        }
        return predicate()
    }

    /// Ladder R1-7: a drag past the window's trailing edge means the
    /// MINIMUM, never the ideal — the old gesture wrote a proposal ≤ 0,
    /// which the rule read as "nothing remembered" and snapped to 420.
    @Test func aDragPastTheTrailingEdgeMeansTheMinimumNeverTheIdeal() {
        // The pointer 40 pt past the edge (a proposal of −40), and exactly at it (0).
        #expect(SideColumnLayout.draggedWidth(pointerX: 1140, total: 1100, ideal: 420, minimum: 280) == 280)
        #expect(SideColumnLayout.draggedWidth(pointerX: 1100, total: 1100, ideal: 420, minimum: 280) == 280)
        // An ordinary drag asks for the room right of the pointer, clamped as before.
        #expect(SideColumnLayout.draggedWidth(pointerX: 700, total: 1100, ideal: 420, minimum: 280) == 400)
        #expect(SideColumnLayout.draggedWidth(pointerX: 100, total: 1100, ideal: 420, minimum: 280) == 640)
        // "Nothing remembered" (0 from the store) is still the ideal — a drag never writes it.
        #expect(SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: 1100) == 420)
    }

    @Test func theWidthRuleIsTheRememberedWidthClampedToTheRoom() {
        // Nothing remembered: the ideal, clamped to the room the content keeps.
        #expect(SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: 1100) == 420)
        #expect(SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: 0) == 420,
                "unmeasured: what was asked for")
        // A dragged width is kept, inside the minimum and the maximum.
        #expect(SideColumnLayout.width(remembered: 500, ideal: 420, minimum: 280, total: 1100) == 500)
        #expect(SideColumnLayout.width(remembered: 100, ideal: 420, minimum: 280, total: 1100) == 280)
        #expect(SideColumnLayout.width(remembered: 900, ideal: 420, minimum: 280, total: 1100) == 640)
        // A narrow host: the content keeps its floor; the panel never goes
        // under its own minimum (the host's floor yields first).
        #expect(SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: 700) == 380)
        #expect(SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: 500) == 280)
    }

    @Test func theTrayColumnHoldsItsBoundaryInAnInactiveWindow() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 74))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note with a tray")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so the mode can host.")
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            UserDefaults.standard.removeObject(forKey: PostDetailView.sideColumnWidthKey)

            let width: CGFloat = 1100
            let height: CGFloat = 750
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let root = PostDetailView(session: session, postID: post.id)
            #if DEBUG
            PostDetailOracle.forgetSideColumnDivider()
            #endif
            let hosting = NSHostingView(
                rootView: root
                    .environment(ThemeStore(session: session))
                    .environment(\.controlActiveState, .inactive))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #expect(await settle(window, hosting, until: {
                session.commandRouter.activePostID == post.id
            }), "the detail registered")

            #expect(session.commandRouter.requestNoteTray(TrayRequest(postID: post.id)),
                    "the tray opened through the router's seam")
            #if DEBUG
            #expect(await settle(window, hosting, until: {
                PostDetailOracle.sideColumnDividerFrame != nil
            }), "OUR divider reported its frame with the window INACTIVE")
            _ = await settle(window, hosting, until: { false }, maxTurns: 6)
            let divider = try #require(PostDetailOracle.sideColumnDividerFrame)
            let panel = SideColumnLayout.width(remembered: 0, ideal: 420, minimum: 280, total: width)
            #expect(abs(divider.width - 1) <= 0.5, "the boundary is a 1-pt line of ours: \(divider)")
            #expect(divider.height >= height - 2, "…running the column's height: \(divider)")
            #expect(abs(divider.minX - (width - panel - 1)) <= 1,
                    "…at the panel's edge (panel \(panel) wide): \(divider)")
            #endif
            let classes = TrayPanelMoveTests.classNames(hosting)
            #expect(!classes.contains { $0.contains("InspectorStyleContext") },
                    "no system inspector stands in the tree")
            let composition = SurfaceComposition.text(of: root.body)
            let inspectorLines = composition.split(separator: "\n")
                .filter { $0.contains("SwiftUI.Inspector") || $0.contains("InspectorModifier") }
            #expect(inspectorLines.isEmpty,
                    "the side column is ours, never a system inspector: \(inspectorLines.prefix(3))")
        }
    }
}
