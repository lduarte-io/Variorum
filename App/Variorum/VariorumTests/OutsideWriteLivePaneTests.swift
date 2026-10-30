//
//  OutsideWriteLivePaneTests.swift
//  VariorumTests
//
//  VX-664 (the VX-677 run, batch 1 — the record `notes/plans/fixes/
//  vx-677-editor-panes-ai-door.md`): the SURFACE truth of the ring-end, on the
//  two roads the walk will film. A live pane is buffer-authoritative — it
//  never adopts projection text (P-3, untouched) — so before this fix a live
//  pane whose own take was written from outside kept the OLD words on screen,
//  and her next keystroke handed them up and wrote them back. Now the board
//  hears the write at its delivery seam (`PaneTextAuthority.settle(isPending:
//  liveIncoming:)`, confirmed on a fresh read), ENDS the ring, and the pane —
//  read again — adopts the stored words through its ordinary read arm. The
//  `RestoreLandingTests` W-1 idiom (VX-440), on the AI's road and the sync
//  road.
//
//  RED ON OLD (`rev664`): both — the live pane still reads the pre-write words.
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
@Suite("VX-664 — a live pane shows an outside write to its own take, read", .serialized)
struct OutsideWriteLivePaneTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated { RunLoop.main.run(until: Date().addingTimeInterval(seconds)) }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 6,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    private static func pane(_ role: String, _ variantID: String, in hosting: NSView) -> PaneTextView? {
        views(PaneTextView.self, in: hosting).first {
            $0.identifier?.rawValue == "pane:\(role)|\(variantID)"
        }
    }

    /// The outside words, as constants: the predicates then capture alike (a
    /// closure-type mismatch at this toolchain otherwise — the class
    /// `RestoreLandingTests.pause` documents).
    private static let aiWords = "An AI rewrote this paragraph while her ring was in it."
    private static let remoteWords = "The phone's version of this paragraph, pulled in."

    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
    }

    private static func prose(_ i: Int) -> String {
        "Paragraph \(i): honest prose on the measured line, long enough to wrap once at "
            + "the column's measure so the page has real height to scroll through."
    }

    /// `RestoreLandingTests.withWorld`'s shape: random ids (the DEBUG oracles'
    /// keys never collide across tests), the Terminal voice, a real ThemeStore.
    private func withWorld(
        count: Int = 6, _ body: @MainActor (World, ThemeStore) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let typography = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = typography
            EditorTypography.isAdopted = adopted
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 664))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note an outside write reaches")
            var blocks: [String] = []
            for i in 1...count {
                blocks.append(try session.operations.newBlock(in: post.id, text: Self.prose(i)).block.id)
            }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            defer { session.commandRouter.forgetCurrentBlock(for: postID) }
            try session.operations.setThemeVoice(.terminal)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            try await body(World(session: session, postID: postID, blocks: blocks), theme)
        }
    }

    private func newWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    private func mountBoard<V: View>(_ board: V, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(rootView: board.environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    private func chosen(_ w: World, _ blockID: String) async throws -> String {
        try #require(try await w.session.database.read {
            try Queries.renderPost($0, containerID: w.postID)
        }.first { $0.blockID == blockID }?.variantID)
    }

    private func model(_ w: World, host: TakesViewModel.HostSurface) async throws -> TakesViewModel {
        let suite = "OutsideWriteLivePaneTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let model = TakesViewModel(session: w.session, postID: w.postID, defaults: defaults)
        model.host = host
        let postID = w.postID
        model.adopt(try await w.session.database.read { try Queries.takesProjection($0, post: postID) })
        return model
    }

    private func storeText(_ w: World, _ variantID: String) async throws -> String? {
        try await w.session.database.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    /// **RED ON OLD — an AI's `edit_take` on the take her ring is in, beside
    /// TAKES: the article pane shows the AI's words, and is read.** On the old
    /// tree it still read her pre-edit words, editable — her next key would
    /// have written them back over the AI's edit (the door's flush-first rule
    /// had already landed her typing; nothing ended the ring).
    ///
    /// **Its two fixture predicates are PLAIN closures bound to locals** (the
    /// VX-677 ladder round 1, F-L1 — VX-692): they sat inside
    /// `#expect(await settle { … })`, the exact shape that merged its Lenses
    /// sibling's first predicate with its decisive one (D-1). Here it compiled
    /// honestly only by numbering — the first fixture predicate and the
    /// decisive `shows` held ADJACENT discriminators (#2 / #3), one closure
    /// away from sharing a body. The bodies are byte-unchanged.
    @Test func aLiveTakesArticleShowsAnAIsEditToItsOwnTake() async throws {
        try await withWorld { w, theme in
            let target = w.blocks[2]
            let take = try await chosen(w, target)
            let model = try await model(w, host: .takes)
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                TakesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let showsTheTake = await Self.settle(window, hosting) {
                Self.pane("article", take, in: hosting)?.string == Self.prose(3)
            }
            #expect(showsTheTake, "fixture: the article shows the take")
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: target, variantID: take))
            let isLive = await Self.settle(window, hosting) {
                Self.pane("article", take, in: hosting)?.isEditable == true
            }
            #expect(isLive, "fixture: the pane is LIVE")

            let words = Self.aiWords
            try w.session.operations.editTakeUnderInsurance(
                take, text: words, expectedText: Self.prose(3), client: "claude-code",
                undoLabel: "claude-code's edit")
            let shows = await Self.settle(window, hosting, timeout: 4) {
                Self.pane("article", take, in: hosting)?.string == Self.aiWords
            }
            #expect(shows, "RED ON OLD: the live pane still reads \(Self.pane("article", take, in: hosting)?.string ?? "nil")")
            #expect(Self.pane("article", take, in: hosting)?.isEditable == false,
                    "the ring over the old words ended")
            #expect(try await storeText(w, take) == words, "the AI's edit stands")
        }
    }

    /// **RED ON OLD — a SYNC PULL writes the take of her live Lenses cell: the
    /// cell shows the remote words, read.** Consumed UI-side from the store's
    /// own delivery; the pull's row write is staged in apply mode (SyncSpec
    /// §3) — no `Sync/` source is touched or called.
    ///
    /// **Every closure here is a PLAIN closure bound to a local before any
    /// macro reads it** (the dispositions record, D-1 — VX-692): the earlier
    /// form wrapped the two fixture predicates in `#expect(await settle { … })`,
    /// and this toolchain gave the first of them and the decisive predicate
    /// below ONE closure discriminator, emitting one body for both — the
    /// decisive `settle` ran "the cell still reads the old words" and passed
    /// at its first look on both trees (proven in the compiled binary). Keep
    /// closure-bearing expressions out of `#expect`/`#require` in this test.
    @Test func aLiveLensesCellShowsASyncPullToItsOwnTake() async throws {
        try await withWorld { w, theme in
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            let model = try await model(w, host: .lenses)
            let mainColumn = model.columns.first { $0.kind == .main }
            let column = try #require(mainColumn)
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                LensesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let showsTheTake = await Self.settle(window, hosting) {
                Self.pane("cell", take, in: hosting)?.string == Self.prose(2)
            }
            #expect(showsTheTake, "fixture: the Chosen column shows the take")
            model.focus(TakesViewModel.PaneKey(columnID: column.id, blockID: target, variantID: take))
            let isLive = await Self.settle(window, hosting) {
                Self.pane("cell", take, in: hosting)?.isEditable == true
            }
            #expect(isLive, "fixture: the cell is LIVE")

            let remote = Self.remoteWords
            try await w.session.database.write { db in
                try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
                try db.execute(
                    sql: "UPDATE variant SET working_text = ? WHERE id = ?", arguments: [remote, take])
                try db.execute(sql: "DELETE FROM _sync_applying")
            }
            let stored = try await storeText(w, take)
            #expect(stored == remote, "fixture: the pull's write stands in the store")
            // **The decisive line, awaited as ONE condition:** the ring over the
            // take ENDS — the cell READ, showing the pulled words. The ring-end
            // follows a fresh confirming read (`OutsideWriteConfirmation`), then
            // the read pane adopts the stored words through its read arm; on
            // the old tree nothing ends the ring and the live cell keeps the
            // old words (a live pane never adopts — P-3), so this waits out
            // its timeout.
            let ended = await Self.settle(window, hosting, timeout: 4) {
                guard let cell = Self.pane("cell", take, in: hosting) else { return false }
                return cell.string == Self.remoteWords && !cell.isEditable
            }
            let cellNow = Self.pane("cell", take, in: hosting)
            #expect(ended, "RED ON OLD: the live cell's ring never ended over the pulled words — it reads \(cellNow?.string ?? "nil"), editable: \(cellNow?.isEditable == true)")
        }
    }
}
