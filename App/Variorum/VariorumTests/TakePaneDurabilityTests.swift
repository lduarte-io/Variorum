//
//  TakePaneDurabilityTests.swift
//  VariorumTests
//
//  13c Batch 1G (A47b) — CHARACTERIZATION, stated as such: this pin
//  documents CORRECT existing behavior and guards the forbidden class
//  (I4: newlines are content; the 2026-07-12 ruling made typed gaps
//  durable). It was born from the store archaeology of 2026-07-27: her
//  take's typed trailing newlines vanished from working_text twice in one
//  session (+1 → −1 in 821 ms; +9 → −9 in 2.73 s, byte-exact reverts),
//  and the question was whether ANY automatic path in the takes surface
//  can remove typed trailing whitespace from a take's stored text. The
//  code sweep found none (no trim exists outside SegmentationRules'
//  bulk-entry/open-tail rules, which never touch an existing block), and
//  this pin holds that ground permanently: typed trailing newlines in a
//  LIVE take card survive autosave, ring migration, projection adoption,
//  and teardown — in the REAL mounted TakesBoardView over a real store.
//
//  (The removals in her session are therefore attributed to her own
//  editing — one ⌘Z over a coalesced Return burst restores byte-exact
//  prior text, matching the WAL signature — with the A47 rendering state
//  explaining why it did not feel like deletion. The full evidence chain
//  is the Batch 1G record in the 13c plan file.)
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
@Suite("Take pane durability (13c 1G)", .serialized)
struct TakePaneDurabilityTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, turns: Int = 4) async {
        for _ in 0..<turns {
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    @Test func typedTrailingNewlinesInALiveTakeSurviveEveryOrdinaryPath() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .init(Date.init)
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "durability post")
            let m1 = try session.operations.newBlock(in: post.id, text: "first block")
            let m2 = try session.operations.newBlock(
                in: post.id, text: "middle take that ends with prose. ability to reorder takes")
            _ = try session.operations.newBlock(in: post.id, text: "third block")
            let variant2 = m2.variant.id

            let model = TakesViewModel(session: session, postID: post.id)
            let observing = Task { await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where model.projection.slots.isEmpty {
                hosting.layoutSubtreeIfNeeded()
                await settle(window, turns: 1)
            }
            await settle(window, turns: 3)

            func storeText() async throws -> String {
                try await db.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT working_text FROM variant WHERE id = ?",
                        arguments: [variant2]) ?? "MISSING"
                }
            }
            let before = try await storeText()

            // The live ring onto the middle take, through the real door.
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: m2.block.id, variantID: variant2))
            await settle(window, turns: 6)
            guard let live = panes(in: hosting).first(where: {
                $0.isEditable && $0.identifier?.rawValue.contains(variant2) == true
            }) else {
                Issue.record("no live pane for the middle take")
                return
            }
            window.makeFirstResponder(live)
            live.setSelectedRange(NSRange(location: (live.string as NSString).length, length: 0))
            // Nine real Returns through the key-binding door (her count).
            for _ in 0..<9 { live.insertNewline(nil) }
            await model.autosave.flushNow()
            let typed = try await storeText()
            let expected = before + String(repeating: "\n", count: 9)
            #expect(typed == expected,
                    "autosave stores the typed trailing newlines byte-exact (len \(typed.count))")

            // Ring migration away (the flush door) + projection adoption.
            if let slot1 = model.projection.slots.first(where: { $0.blockID == m1.block.id }),
               let variant1 = slot1.variantID {
                model.focus(TakesViewModel.PaneKey(
                    columnID: TakesViewModel.takesMainColumnID,
                    blockID: m1.block.id, variantID: variant1))
            }
            await settle(window, turns: 6)
            await model.autosave.flushNow()
            let afterMigration = try await storeText()
            #expect(afterMigration == expected, "ring migration preserves the newlines")

            // The read pane now mirrors the projection — the newlines SHOW.
            if let read = panes(in: hosting).first(where: {
                !$0.isEditable && $0.identifier?.rawValue == "pane:article|\(variant2)"
            }) {
                #expect(read.string.hasSuffix(String(repeating: "\n", count: 9)),
                        "the read pane renders the stored trailing newlines")
            }

            // Teardown (the mode-switch / quit door).
            model.teardown()
            await settle(window, turns: 4)
            await model.autosave.flushNow()
            let afterTeardown = try await storeText()
            #expect(afterTeardown == expected,
                    "teardown preserves the newlines — no automatic path trims a take's stored text")
        }
    }
}
