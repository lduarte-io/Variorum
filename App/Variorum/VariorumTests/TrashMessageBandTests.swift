//
//  TrashMessageBandTests.swift
//  VariorumTests
//
//  VX-636 (the VX-828 run, batch D — the rider): the Trash's message line
//  drew OVER the bottom visible Trash row (seen at VX-601's A2 walk, after
//  Delete for Good: "The note is gone from the app now — the app's own
//  cleanup removes the bytes." written across the last row's text).
//
//  The mechanism, traced: `RecoveryView` hung its refusal/receipt slot on the
//  `List` as `.overlay(alignment: .bottom)` — an overlay draws on top of the
//  list's own frame and gives the list no room, so the row at the bottom of
//  the viewport sat underneath it. The fix lays the line out in its own band
//  BELOW the list (the Pool's foot idiom: a hairline, then the line, present
//  only while something speaks).
//
//  The geometry is pinned through the SHIPPING view over a test-owned model
//  (`RecoveryView`'s internal `model:` seam, ruled at the batch D fork) and
//  the DEBUG frame oracle (`TrashFootProbe`, the `BaselineProbe` idiom): the
//  band's frame must lie wholly below the list's, and the list must give up
//  the band's height. RED ON OLD by the behavioral revert named in the run
//  record (R-D4: `body` back to `list.overlay(alignment: .bottom) {
//  messageFoot }` — the band drawn over the list, exactly the old placement).
//
//  WRITTEN and compiled by batch D; run at the orchestrator's stage window.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-636 — the Trash's message band never draws over its rows", .serialized)
struct TrashMessageBandTests {

    private func pump(_ seconds: TimeInterval = 0.2) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Pumps until `done`, or the bound passes — waiting for an EVENT.
    private func settle(until done: () -> Bool, seconds: TimeInterval = 10) async {
        let deadline = Date().addingTimeInterval(seconds)
        while !done(), Date() < deadline {
            pump(0.05)
            for _ in 0..<10 { await Task.yield() }
        }
    }

    // MARK: - The decision

    /// The slot's order (ArchivedView's): this surface's refusal, then its
    /// receipt, else the seam's quiet line; else no band at all.
    @Test func theBandSaysTheRefusalThenTheReceiptThenTheSeamElseNothing() {
        #expect(TrashMessageFoot.line(error: "no", receipt: "yes", quietSpeaks: true) == .refusal("no"))
        #expect(TrashMessageFoot.line(error: nil, receipt: "yes", quietSpeaks: true) == .receipt("yes"))
        #expect(TrashMessageFoot.line(error: nil, receipt: nil, quietSpeaks: true) == .quiet)
        #expect(TrashMessageFoot.line(error: nil, receipt: nil, quietSpeaks: false) == nil,
                "nothing speaks: no band, no reserved blank line")
    }

    // MARK: - The geometry

    /// A Trash long enough to fill the window; a real Put back speaks its
    /// receipt. Idle, there is no band; speaking, the band's frame lies wholly
    /// BELOW the list's frame, and the list gave up the band's height — so no
    /// row can sit under the line.
    @Test func theReceiptSpeaksInItsOwnBandNeverOverTheRows() async throws {
        try await withEditor { editor in
            _ = try await editor.session.runner.run { (ops: Operations) -> [String] in
                try (0..<30).map { index in
                    let note = try ops.createPost(title: "a deleted note \(index)")
                    try ops.deleteContainer(note.id)
                    return note.id
                }
            }
            let library = LibraryViewModel(session: editor.session)
            let model = RecoveryViewModel(session: editor.session)
            TrashFootProbe.reset()
            defer { TrashFootProbe.reset() }
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 640, height: 360),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(rootView: RecoveryView(
                session: editor.session, library: library, openPost: { _ in }, model: model))
            window.orderFrontRegardless()
            await settle(until: { model.trash.count == 30 })
            pump(0.3)
            #expect(model.trash.count == 30, "premise: the listing answered")
            #expect(model.receipt == nil && model.lastError == nil)
            #expect(TrashFootProbe.frames["foot"] == nil, "nothing speaks: no band at all")
            let idle = try #require(TrashFootProbe.frames["list"])

            let row = try #require(model.trash.first)
            await model.putBack(row)
            let receipt = try #require(model.receipt, "premise: the Put back spoke a receipt")
            #expect(!receipt.isEmpty)
            await settle(until: { TrashFootProbe.frames["foot"] != nil })
            pump(0.3)

            let foot = try #require(TrashFootProbe.frames["foot"], "the band is drawn while it speaks")
            let list = try #require(TrashFootProbe.frames["list"])
            #expect(foot.minY >= list.maxY - 0.5,
                    "the line lies wholly below the list (foot \(foot), list \(list)) — never over a row")
            #expect(list.height < idle.height - 0.5,
                    "the list gave the band its room (idle \(idle.height), speaking \(list.height))")
            #expect(foot.height > 0)
        }
    }
}
