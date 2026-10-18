//
//  VX385PoolQuietReceiptTests.swift
//  VariorumTests
//
//  **VX-385 + VX-355 (the VX-348 run, U4) — the Pool gets a quiet-receipt
//  home.** VX-385 (VX-383's walk, W4): in the Pool, a row's Duplicate
//  with/without Tags delivered its receipt to the status centre as a RECEIPT,
//  and under her default `receipt_style` quiet it had no face — the Pool
//  hosted no `QuietReceiptLine`. VX-355 (VX-336's U6 live round): with the
//  Pool open, an AI's receipt and her ⌥⌘Z / ⇧⌥⌘Z "Undid / Redid" lines never
//  appeared. ONE fix answers both, and VX-355's open question (a page-foot
//  home or a toast) with it: the Pool hosts the line (PROVISIONAL
//  P-VX385-1).
//
//  Read through the Pool's own COMPOSITION (the `SurfaceComposition` road —
//  `ProtectionSurfaceRenderTests`' header: `dump` walks the real `body`, an
//  untaken branch is absent, the AX tree is empty here). Each case drives the
//  REAL road that speaks — the row menu's act (`NoteDuplicate.perform`, what
//  `RootView` hands the Pool through the Library's model), the shell's
//  ⌥⌘Z / ⇧⌥⌘Z doors (`ShellActions`), the status seam an AI write speaks on —
//  and asks the Pool, open the whole time, whether it composes the line.
//
//  RED ON OLD, every case (pre-fix APIs only): the receipt reached the quiet
//  slot and the Pool composed no `QuietReceiptLine`. The foot's slot rule is
//  new API and lives in `VX385PoolReceiptFootRuleTests.swift` (fixed-only).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-385 + VX-355 — the Pool hosts the quiet receipt line", .serialized)
struct VX385PoolQuietReceiptTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(13) }
                return value
            }
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(timeout: TimeInterval = 4, until predicate: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline, !predicate() {
            Self.pumpRunLoop(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The Pool, open, over one bookless note — and its duplicate door wired
    /// the way `RootView` wires it (the Library's act, `NoteDuplicate`).
    private func withOpenPool(
        _ body: @MainActor (AppSession, PoolPostsView, String) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 385))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            #expect(session.status.receiptStyle == .quiet, "the premise: her default, quiet")
            let note = try session.operations.createPost(title: "Harbor Log")
            _ = try session.operations.newBlock(in: note.id, text: "lanterns along the quay")
            let model = PoolPostsModel(session: session)
            await model.adopt(try await db.read {
                try Queries.notePoolListing($0, window: PoolPostsModel.window)
            })
            let pool = PoolPostsView(
                session: session, model: model,
                onDuplicateAsVersion: { id, tags in
                    await NoteDuplicate.perform(postID: id, tags: tags, session: session)
                },
                onArchive: { _ in },
                readings: ReadingsViewModel(session: session),
                tags: TagsViewModel(session: session),
                onOpen: { _ in })
            await SurfaceComposition.host(pool, size: NSSize(width: 900, height: 600))
            #expect(!Self.hostsTheLine(pool), "the premise: nothing speaks, so the foot is not composed")
            try await body(session, pool, note.id)
        }
    }

    /// Does the Pool's composition carry the one quiet line?
    private static func hostsTheLine(_ pool: PoolPostsView) -> Bool {
        SurfaceComposition.text(of: pool.body).contains("QuietReceiptLine")
    }

    /// **VX-385's case.** A row's Duplicate with Tags and without: the act's
    /// receipt lands in the QUIET slot and the open Pool composes the line
    /// that says it.
    @Test(arguments: [Operations.DuplicateTags.applied, .none])
    func aRowDuplicateSpeaksAtThePoolsFoot(tags: Operations.DuplicateTags) async throws {
        try await withOpenPool { session, pool, noteID in
            await pool.onDuplicateAsVersion(noteID, tags)
            let line = try #require(session.status.quietLine, "the act spoke a RECEIPT, in the quiet slot")
            #expect(line.text.hasPrefix(tags == .applied ? "Duplicated with tags" : "Duplicated without tags"),
                    "\(line.text)")
            #expect(Self.hostsTheLine(pool), "the open Pool composes the line that says it")
        }
    }

    /// **VX-355's case, her ⌥⌘Z / ⇧⌥⌘Z.** The duplicate undone and redone
    /// through the shell's own doors: "Undid: …" and "Redid: …" speak at the
    /// open Pool's foot.
    @Test func herUndoAndRedoSpeakAtThePoolsFoot() async throws {
        try await withOpenPool { session, pool, noteID in
            await pool.onDuplicateAsVersion(noteID, .applied)
            let actions = ShellActions(session: session, shell: ShellRouter())
            session.status.clear()

            actions.structuralUndo(confirm: { _ in true })
            await settle { session.status.quietLine?.text.hasPrefix("Undid") == true }
            #expect(session.status.quietLine?.text.hasPrefix("Undid") == true,
                    "the undo spoke a receipt: \(session.status.spoken?.text ?? "nothing")")
            #expect(Self.hostsTheLine(pool), "…at the open Pool's foot")

            session.status.clear()
            #expect(!Self.hostsTheLine(pool), "silence again: the foot goes with the words")
            actions.structuralRedo()
            await settle { session.status.quietLine?.text.hasPrefix("Redid") == true }
            #expect(session.status.quietLine?.text.hasPrefix("Redid") == true,
                    "the redo spoke a receipt: \(session.status.spoken?.text ?? "nothing")")
            #expect(Self.hostsTheLine(pool), "…at the open Pool's foot")
        }
    }

    /// **VX-355's case, an AI's write.** The door's receipt is a RECEIPT that
    /// carries its one-press "Open ›" (AppSpec §12, R-13nb-27), spoken on the
    /// one status seam: the open Pool composes the line, its door with it.
    @Test func anAIsReceiptSpeaksAtThePoolsFoot() async throws {
        try await withOpenPool { session, pool, _ in
            session.status.deliver(
                "claude-code duplicated \u{201C}Harbor Log\u{201D} \u{2014} \u{2325}\u{2318}Z undoes it.",
                kind: .receipt, action: .init(label: "Open \u{203A}", perform: {}))
            #expect(session.status.quietLine?.action?.label == "Open \u{203A}", "the premise: quiet, with its door")
            #expect(Self.hostsTheLine(pool), "the open Pool composes the line and its door")
        }
    }
}
