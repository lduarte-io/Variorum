//
//  TakesEmptyStateTests.swift
//  VariorumTests
//
//  17o batch c, ledger row 15 — her punchlist 10, verbatim: *"you should
//  be able to make a first block there"* (image 3: an empty note in Takes,
//  slot-split style, offering only "Start writing (Write mode)").
//
//  THE TRACED MECHANISM: the empty state of both takes-shaped boards
//  rendered exactly ONE door — into Write — and the article's own
//  "＋ new block" door was gated on `!slots.isEmpty`, so it appeared only
//  once a block already existed. The capability was never missing
//  (`.addBlockAtEnd` is native to the take family, and it is on the bottom
//  bar and the menu bar); the DOOR on the surface she was looking at was.
//
//  RED ON THE PRE-FIX TREE: mounting either board on an empty note records
//  only `.write` — the new-block door never renders.
//
//  Why a DEBUG door oracle rather than a click: a SwiftUI button on a whole
//  board is not an `NSView` a pin can find, and the real-click rig cannot
//  mount a whole board (KnownIssues' rig row; the brief's own "pin
//  mechanisms, walk faces"). The oracle records what the empty state
//  actually rendered, on the real board, in the real mount — and the click
//  itself is walked.
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
@Suite("Takes/Lenses empty state (17o batch c, row 15)", .serialized)
struct TakesEmptyStateTests {
    private func pump(_ seconds: TimeInterval = 0.04) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withEmptyNote<T>(
        _ body: @MainActor (AppSession, AppDatabase, String) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // A note with NO blocks — exactly her image 3.
            let post = try session.operations.createPost(title: "a fresh note")
            return try await body(session, db, post.id)
        }
    }

    private func mount(_ root: some View, height: CGFloat = 800) -> NSWindow {
        let host = NSHostingController(rootView: root)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: height),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 900, height: height)
        for _ in 0..<6 {
            host.view.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    /// The Takes board, mounted on an empty note, renders BOTH doors.
    @Test func theTakesBoardOffersAFirstBlockOnAnEmptyNote() async throws {
        try await withEmptyNote { session, _, postID in
            TakesEmptyStateDoors.reset()
            let window = mount(TakesBoardView(session: session, postID: postID))
            defer { window.contentViewController = nil }
            #expect(TakesEmptyStateDoors.rendered.contains(.write),
                    "non-vacuity: the empty state mounted at all")
            #expect(TakesEmptyStateDoors.rendered.contains(.newBlock),
                    "the first block can be MADE here — her punchlist 10 (rendered: \(TakesEmptyStateDoors.rendered))")
        }
    }

    /// And so does Lenses — the same shared face, so the two boards can
    /// never answer her differently.
    @Test func theLensesBoardOffersAFirstBlockOnAnEmptyNote() async throws {
        try await withEmptyNote { session, _, postID in
            TakesEmptyStateDoors.reset()
            let window = mount(LensesBoardView(session: session, postID: postID))
            defer { window.contentViewController = nil }
            #expect(TakesEmptyStateDoors.rendered.contains(.write),
                    "non-vacuity: the empty state mounted at all")
            #expect(TakesEmptyStateDoors.rendered.contains(.newBlock),
                    "Lenses answers her the same way (rendered: \(TakesEmptyStateDoors.rendered))")
        }
    }

    /// Both boards render the SAME door list — one face, not two copies.
    @Test func bothBoardsRenderTheOneDoorList() {
        #expect(TakesEmptyState.doors == [.newBlock, .write],
                "the new-block door leads; Write is beside it")
    }

    /// The door's ACT, at the model: from a note with no blocks the mint
    /// lands a block whose pane takes the ring (P3's one live pane, through
    /// the existing `parkFocus` road — no new liveness mechanism), and the
    /// block is legal empty (I10: one live variant, empty text).
    @Test func theDoorMintsTheFirstBlockAndItsPaneTakesTheRing() async throws {
        try await withEmptyNote { session, db, postID in
            let model = TakesViewModel(session: session, postID: postID)
            defer { model.teardown() }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(model.projection.slots.isEmpty, "non-vacuity: the note starts blockless")

            await model.addBlockAtEnd()
            let after = try await db.read { try Queries.takesProjection($0, post: postID) }
            model.adopt(after)
            let slot = try #require(after.slots.first)
            #expect(after.slots.count == 1, "one block, minted at the end of a note that had none")
            let variantID = try #require(slot.variantID)

            // I10: the block is live and carries one live variant — empty.
            let variants = try await db.read { try Queries.blockFan($0, blockID: slot.blockID) }
            #expect(variants.count == 1)
            #expect(variants.first?.workingText == "",
                    "an empty first block is legal — 18c's Return rule makes it an ordinary block")

            // The ring: the mint parks focus, and adopting the projection
            // that carries the slot moves the ONE live pane onto it.
            #expect(model.isPaneLive(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: slot.blockID, variantID: variantID)),
                    "the minted pane takes the ring — \"just start typing\", literally")
        }
    }
}
