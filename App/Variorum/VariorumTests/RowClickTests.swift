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
//  The pins: the timing rule, pure; and the note row's click SHELL
//  (`CatalogNoteRowShell`) mounted alone in the canvas rig's window (the one
//  that DELIVERS pointer events to a SwiftUI hosting view under the runner),
//  wired to a real catalog model, a real click on its body → the panel's
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

    /// The note row's click SHELL mounted ALONE in the rig's panel (the whole
    /// catalog under the rig's event pump hangs, as the whole workbench did
    /// in batch C — the pin isolates the mechanism the row is about), wired
    /// to a REAL catalog model exactly as the row wires it.
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
            await model.search()
            #expect(model.hits.contains { $0.id == post.id })
            let opened = Opened()
            let tokens = VoiceTokens.fallback(for: .light)
            let rig = BlocksWorkbenchFaceTests.Rig(
                VStack(spacing: 0) {
                    CatalogNoteRowShell(
                        postID: post.id,
                        onClick: { modifiers in model.clickNoteRow(post.id, modifiers: modifiers) },
                        onDoubleClick: { opened.selections.append(.post(post.id)) }
                    ) {
                        Text("the row she clicks — a note row's body")
                            .font(tokens.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 60)
                    Spacer()
                }
                .padding(20))
            defer { rig.close() }
            await rig.poll(timeout: 2) { false }  // let it lay out
            // Right of the title's words — the BODY (her click model).
            let point = rig.windowPoint(CGPoint(x: 600, y: 50))
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
