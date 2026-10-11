//
//  WriteTakesPanelChooseTests.swift
//  VariorumTests
//
//  VX-135 (the VX-143 run) — her report: *"command enter in a take from
//  write's take menu doesn't work to select the take as the chosen one."*
//
//  THE MECHANISM (traced in the run record): Write's take menu is
//  `WriteTakesPanel`, a sheet over the Write editor. ⌘⏎ is the menu bar's
//  Choose Take, which routes `.takes(.choose)` through `CommandRouter`'s LIFO
//  handler stack. The panel registered no handler, so the top one was Write's
//  own (`EditorView.handleRouted`), whose `.choose` arm OPENS the caret
//  block's take panel — already open — and consumes the command. The take
//  whose pane is live in the panel was never chosen.
//
//  The pin drives the real panel with Write's handler standing beneath it
//  (registered first, exactly as `EditorView` is in the app — its stand-in
//  here consumes `.choose` the way the real arm does), puts the ring in the
//  second take by the real click road, and dispatches ⌘⏎'s routed command
//  through the session's own router. RED ON OLD: Write's handler consumes it
//  and nothing is chosen.
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
@Suite("Write's take panel — ⌘⏎ chooses the take you're in (VX-135)", .serialized)
struct WriteTakesPanelChooseTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panelPanes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView,
           pane.identifier?.rawValue.hasPrefix("pane:panel|") == true {
            found.append(pane)
        }
        for sub in view.subviews { found.append(contentsOf: panelPanes(in: sub)) }
        return found
    }

    private func chosenVariant(_ db: AppDatabase, blockID: String) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(
                db,
                sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
        }
    }

    @Test func commandReturnInThePanelChoosesTheTakeTheRingIsIn() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 135))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (postID, blockID, takeIDs): (String, String, [String]) = try {
                let post = try session.operations.createPost(title: "the ⌘⏎ post")
                let minted = try session.operations.newBlock(in: post.id, text: "the chosen take")
                let branch = try session.operations.branchVariant(
                    minted.block.id, from: minted.variant.id)
                try session.operations.autosave(
                    branch.id, text: "the take she means", charDelta: 6)
                return (post.id, minted.block.id, [minted.variant.id, branch.id])
            }()
            #expect(try await chosenVariant(db, blockID: blockID) == takeIDs[0],
                    "the fixture starts with the FIRST take chosen")

            // Write's handler, standing beneath the sheet exactly as
            // `EditorView` registers it: its `.choose` arm consumes the
            // command (in the app it re-opens the caret block's panel).
            let writeSaw = LockIsolated(0)
            let writeToken = session.commandRouter.registerHandler { command in
                guard case .takes(.choose) = command else { return false }
                writeSaw.withValue { $0 += 1 }
                return true
            }
            defer { session.commandRouter.unregisterHandler(writeToken) }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 800, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: WriteTakesPanel(session: session, postID: postID, blockID: blockID))
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { panelPanes(in: hosting).count >= 2 })

            // The ring goes into the SECOND take by the real click road.
            let target = try #require(panelPanes(in: hosting).first {
                $0.identifier?.rawValue == "pane:panel|\(takeIDs[1])"
            })
            target.onPlainClick?(0)
            await settle(window, hosting, until: { target.isEditable })
            #expect(target.isEditable, "the clicked take is the live one — the ring is in it")

            // ⌘⏎ — the menu item's exact act (`EditorCommands`: the routed
            // `.takes(.choose)` through the session's router).
            ShellActionsProbe.dispatch(.takes(.choose), router: session.commandRouter)
            var chosen: String?
            for _ in 0..<40 {
                chosen = try await chosenVariant(db, blockID: blockID)
                if chosen == takeIDs[1] { break }
                await settle(window, hosting, until: { false }, maxTurns: 1)
            }
            #expect(chosen == takeIDs[1],
                    "⌘⏎ in the panel chose the take the ring is in (chosen: \(chosen ?? "nil"))")
            #expect(writeSaw.value == 0,
                    "the panel answered ⌘⏎ itself — Write's caret door underneath never saw it")

            // Lifecycle: with the panel gone, Write's handler is the top of
            // the stack again (the panel took its registration with it).
            window.contentView = NSView()
            await settle(window, hosting, until: { false }, maxTurns: 4)
            ShellActionsProbe.dispatch(.takes(.choose), router: session.commandRouter)
            #expect(writeSaw.value == 1,
                    "after the panel closes, ⌘⏎ is Write's again (saw \(writeSaw.value))")
        }
    }
}

/// The menu item's act, minus the shell (`ShellActions.dispatch` is exactly
/// `router.dispatch(command)`); named so the pin reads as the door it drives.
@MainActor
private enum ShellActionsProbe {
    static func dispatch(_ command: RoutedCommand, router: CommandRouter) {
        router.dispatch(command)
    }
}
