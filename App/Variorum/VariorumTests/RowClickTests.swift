//
//  RowClickTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-2: the Library's rows
//  held every body click for the double-click interval (the stacked
//  `onTapGesture(count: 2)` + plain-tap idiom batch C measured at 0.26–0.49 s
//  on the Blocks rows and replaced there; batch E rebuilt the panel behind
//  the same idiom on the Library's rows). The fix HOISTS the workbench
//  shell's one-tap brain into `rowClick` (`Core/Views/RowClick.swift`) and
//  puts it on the book row, the note row and the shell.
//
//  The pins: the timing rule, pure; and the REAL catalog mounted in the
//  canvas rig's window (the one that DELIVERS pointer events to a SwiftUI
//  hosting view under the runner), a real click on a NOTE row → the panel's
//  subject set within the row-25 budget (150 ms), then a second click inside
//  the system's interval → the note OPENS exactly once. RED ON OLD by batch
//  C's own numbers: the old rows delivered the single click only after the
//  0.5 s double-click window closed. The parity proof for the hoist is the
//  shell's own real-click pin (`BlocksWorkbenchFaceTests`), which rides the
//  rebuilt shell UNMODIFIED.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The row-click brain's timing (ladder R1-2)")
struct RowClickTimingTests {
    @Test func aSecondClickInsideTheIntervalIsTheDoubleAndOutsideItIsNot() {
        let clock = ContinuousClock()
        let t0 = clock.now
        let interval = Duration.seconds(0.5)
        // No previous click: a single, whatever the time.
        #expect(RowClickTiming.verdict(now: t0, lastClick: nil, interval: interval) == .single)
        // A second click 0.2 s later is the double…
        #expect(RowClickTiming.verdict(
            now: t0 + .seconds(0.2), lastClick: t0, interval: interval) == .double)
        // …exactly at the interval it is not (the window is open, not closed)…
        #expect(RowClickTiming.verdict(
            now: t0 + .seconds(0.5), lastClick: t0, interval: interval) == .single)
        // …and well after it a click is a single again.
        #expect(RowClickTiming.verdict(
            now: t0 + .seconds(0.9), lastClick: t0, interval: interval) == .single)
    }
}

@MainActor
@Suite("The Library rows act at once (ladder R1-2)", .serialized)
struct LibraryRowClickTests {
    /// Batch C's row-25 budget, reused: a body click stands the panel's
    /// subject up within this. The old rows delivered it only after the
    /// double-click interval (0.5 s on her Mac) had closed.
    static let budget: TimeInterval = 0.15

    @MainActor
    final class Opened {
        var selections: [SidebarSelection] = []
    }

    @Test func aBodyClickStandsThePanelUpWithinTheBudgetAndADoubleOpensOnce() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the row she clicks")
            _ = try session.operations.newBlock(in: post.id, text: "A note with one block.")
            let model = LibraryCatalogModel(session: session)
            let library = LibraryViewModel(session: session)
            await model.search()
            #expect(model.hits.contains { $0.id == post.id })
            let opened = Opened()
            #if DEBUG
            LibraryPanelOracle.reset()
            #endif
            let rig = BlocksWorkbenchFaceTests.Rig(
                LibraryCatalogView(
                    session: session, model: model, library: library,
                    tags: TagsViewModel(session: session),
                    onOpen: { opened.selections.append($0) })
                    .environment(ThemeStore(session: session)),
                width: 1000, height: 640)
            defer { rig.close() }

            // The note row's frame, reported in the catalog's own named space.
            #expect(await rig.poll(timeout: 6) {
                LibraryPanelOracle.noteRowFrames[post.id] != nil
                    && LibraryPanelOracle.rootFrame != nil
            }, "the note row and the catalog's root reported their frames")
            let row = try #require(LibraryPanelOracle.noteRowFrames[post.id])
            let root = try #require(LibraryPanelOracle.rootFrame)
            // The probe space is the catalog's HStack, inset from the hosting
            // view by its own symmetric padding — the offset is the difference.
            let dx = (rig.hosting.bounds.width - root.width) / 2
            let dy = (rig.hosting.bounds.height - root.height) / 2
            // Right of the title's words (the title's own tap opens; the
            // BODY selects — her click model), inside the row.
            let point = rig.windowPoint(CGPoint(x: row.midX + row.width * 0.3 + dx, y: row.midY + dy))
            #expect(model.infoHit == nil, "the premise: no subject before the click")

            rig.send(.leftMouseDown, at: point)
            rig.pump(0.005)
            let clock = ContinuousClock()
            let start = clock.now
            rig.send(.leftMouseUp, at: point)
            let acted = await rig.poll(timeout: 2) { model.infoHit != nil }
            let elapsed = clock.now - start
            print("[ladder R1-2] Library row click → the panel's subject in \(elapsed) (budget \(Self.budget) s; the old rows waited the \(NSEvent.doubleClickInterval) s double-click interval)")
            #expect(acted, "the body click acted at all")
            #expect(elapsed < .seconds(Self.budget),
                    "a body click stands the panel up at once — never after the double-click interval")
            #expect(model.infoHit?.id == post.id, "the panel's subject is the clicked note")
            #expect(opened.selections.isEmpty, "a single click never opens")

            // A DOUBLE click — a second click inside the system's interval —
            // opens the note exactly once.
            rig.send(.leftMouseDown, at: point, clickCount: 2)
            rig.pump(0.005)
            rig.send(.leftMouseUp, at: point, clickCount: 2)
            #expect(await rig.poll(timeout: 2) { !opened.selections.isEmpty }, "the double opens")
            #expect(opened.selections == [.post(post.id)], "…the clicked note, once")
        }
    }
}
