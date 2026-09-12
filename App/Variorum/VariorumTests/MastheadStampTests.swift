//
//  MastheadStampTests.swift
//  VariorumTests
//
//  **18h batch 1 — the note's own time, in its masthead** (the 2026-09-12
//  use-report round, her ledger row 9; ruling R-Q7: *"at the trailing end of
//  the 'in no book' row, edited today 1:33 AM; a click flips it to created
//  …, a click again returns"*).
//
//  RED ON OLD — a PRODUCT row: `MastheadRowTwo.arrangement` took no
//  `stampWidth`, there was no `MastheadProbeSlot.stamp` or
//  `MastheadGeometry.stampFrame` to read a frame from, and no
//  `PostDetailOracle.stampShown` / `stampEditedAt` / `flipStamp`, so these
//  pins do not compile on the pre-change tree. Recorded in the batch record.
//
//  ── WHAT THEY DRIVE ──────────────────────────────────────────────────────
//  The mounted pins mount the REAL detail and read the DEBUG oracles the
//  masthead itself writes; the autosave pin moves the store through the REAL
//  operations runner and waits for the stamp's own HELD observation to
//  deliver — never hand-feeding the view a new value (the round's own
//  "green for the wrong reason" lesson). The flip pin calls the very closure
//  the Button calls.
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
@Suite("The masthead's time stamp (18h batch 1, row 9 — her R-Q7)", .serialized)
struct MastheadStampTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(until predicate: () -> Bool, maxTurns: Int = 80) async {
        for _ in 0..<maxTurns {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// **The pure rule, with three subviews.** The shipped two-subview
    /// expectations are in `MastheadLayoutTests` and are UNCHANGED — a
    /// zero-width stamp adds nothing, not even a gap — which is the parity
    /// proof for the layout's growth.
    @Test func theArrangementCountsTheStampsTailOrIgnoresItWhenThereIsNone() {
        // 680 held one line with chip 125 + cluster 286; a 130-pt stamp and
        // its gap still fit (125 + 16 + 286 + 16 + 130 = 573).
        #expect(MastheadRowTwo.arrangement(
            width: 680, chipWidth: 125, clusterMinimum: 286, gap: 16, stampWidth: 130) == .oneLine)
        // …and at 560 they do not, so the cluster drops below.
        #expect(MastheadRowTwo.arrangement(
            width: 560, chipWidth: 125, clusterMinimum: 286, gap: 16, stampWidth: 130) == .twoLines)
        // The same width with NO stamp still holds one line — the stamp is
        // what changed the answer, which is the honest claim.
        #expect(MastheadRowTwo.arrangement(
            width: 560, chipWidth: 125, clusterMinimum: 286, gap: 16) == .oneLine)
        // A zero stamp adds no gap (562 - 16 would have failed).
        #expect(MastheadRowTwo.arrangement(
            width: 427, chipWidth: 125, clusterMinimum: 286, gap: 16, stampWidth: 0) == .oneLine)
        #expect(MastheadRowTwo.arrangement(
            width: .infinity, chipWidth: 230, clusterMinimum: 326, gap: 16, stampWidth: 130)
            == .oneLine, "unmeasured: one line, stamp or no stamp")
    }

    /// **The stamp stands at row two's trailing end and covers nothing** —
    /// the chip, the cards and the ＃ door all clear of it, and it inside the
    /// masthead. RED ON OLD: `MastheadGeometry.stampFrame` did not exist;
    /// with the old two-subview layout handed three subviews, `plan` refused
    /// and row two laid nothing out at all.
    @Test func theStampSitsAtRowTwosTrailingEndAndCoversNothing() async throws {
        try await withMountedDetail(width: 1100, tags: ["walked", "tutorial"]) { _, postID in
            #if DEBUG
            await settle(until: {
                MastheadGeometry.stampFrames[postID] != nil && MastheadGeometry.pathChipFrame != nil
                    && MastheadGeometry.cardFrames.count == 2
                    && MastheadGeometry.doorFrame != nil
            })
            await settle(until: { false }, maxTurns: 6)
            // Keyed by the NOTE since the ladder's R1-14 — the pin names
            // whose masthead it is reading, rather than whichever mounted last.
            let stamp = try #require(MastheadGeometry.stampFrames[postID],
                                     "this note's stamp reported its frame")
            let chip = try #require(MastheadGeometry.pathChipFrame)
            let door = try #require(MastheadGeometry.doorFrame)
            let masthead = try #require(MastheadGeometry.contentMidX).magnitude * 2
            #expect(stamp.width > 0 && stamp.height > 0, "it is drawn: \(stamp)")
            #expect(stamp.maxX <= masthead + 0.5, "it stays inside the masthead: \(stamp) of \(masthead)")
            #expect(!stamp.intersects(chip), "it never covers the path chip: \(stamp) vs \(chip)")
            #expect(!stamp.intersects(door), "…nor the ＃ door: \(stamp) vs \(door)")
            for (id, card) in MastheadGeometry.cardFrames {
                #expect(!stamp.intersects(card), "…nor tag card \(id) \(card)")
                #expect(card.maxX <= stamp.minX + 0.5,
                        "the cards reflow INSIDE the stamp's edge (\(card) vs \(stamp))")
            }
            #expect(stamp.minX > chip.maxX, "it is at the TRAILING end, past the chip")
            // One line at this width: the chip and the stamp share a line.
            #expect(abs(stamp.midY - chip.midY) <= 4,
                    "on one line the stamp rides the chip's line: \(stamp) vs \(chip)")
            #endif
        }
    }

    /// **It follows an AUTOSAVE** — the whole point of an "edited" stamp is
    /// that it moves while she types, and the masthead's title learned in
    /// 17o row 19 that a one-shot read leaves the words standing while the
    /// store moves. The store is moved through the REAL runner; the pin
    /// waits for the stamp's own held observation to deliver.
    ///
    /// RED ON OLD: there was no stamp and no oracle. A one-shot
    /// implementation fails this pin, which is the regression it guards.
    @Test func anAutosaveMovesTheStampWithoutReopeningTheNote() async throws {
        try await withMountedDetail(width: 1100, tags: []) { session, postID in
            #if DEBUG
            await settle(until: { PostDetailOracle.stampEditedAt[postID] != nil })
            let before = try #require(
                PostDetailOracle.stampEditedAt[postID], "the held read delivered")
            let variantID = try await session.database.read { db in
                try Queries.renderPost(db, containerID: postID).first?.variantID
            }
            let variant = try #require(variantID, "the fixture's one block has a take")
            try await session.runner.run { ops in
                try ops.autosave(variant, text: "a block, so the mode can host. And more.", charDelta: 10)
            }
            await settle(until: {
                (PostDetailOracle.stampEditedAt[postID] ?? before) > before
            })
            let after = try #require(PostDetailOracle.stampEditedAt[postID])
            #expect(after > before,
                    "the held read delivered the new edit stamp (\(after) vs \(before))")
            #endif
        }
    }

    /// **A click flips it to *created …*, and again returns** — her ruling's
    /// own gesture, driven through the very closure the Button calls.
    @Test func aClickFlipsTheStampToCreatedAndBackAgain() async throws {
        try await withMountedDetail(width: 1100, tags: []) { _, postID in
            #if DEBUG
            await settle(until: { PostDetailOracle.stampShown[postID] != nil })
            let edited = try #require(PostDetailOracle.stampShown[postID])
            #expect(edited.hasPrefix("edited "), "it rests on the edit stamp: \(edited)")

            let flip = try #require(
                PostDetailOracle.flipStamp[postID], "the stamp's click reachable")
            flip()
            await settle(until: {
                PostDetailOracle.stampShown[postID]?.hasPrefix("created ") == true
            })
            let created = try #require(PostDetailOracle.stampShown[postID])
            #expect(created.hasPrefix("created "), "a click shows when it was created: \(created)")

            flip()
            await settle(until: {
                PostDetailOracle.stampShown[postID]?.hasPrefix("edited ") == true
            })
            #expect(PostDetailOracle.stampShown[postID]?.hasPrefix("edited ") == true,
                    "a click again returns")
            #endif
        }
    }

    /// Mounts the real detail with one note (a block, a book so the chip
    /// wears a real path, and `tags`), the oracles reset first — the
    /// `MastheadLayoutTests` rig, narrowed to this batch's needs.
    private func withMountedDetail(
        width: CGFloat, tags: [String],
        _ body: @MainActor (AppSession, String) async throws -> Void
    ) async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 90))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "The Boscombe Valley Mystery")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so the mode can host.")
            let book = try session.operations.createReading(name: "the field guide", kind: .curated)
            _ = try session.operations.addPostToReading(post.id, to: book.id)
            for name in tags {
                let tag = try session.operations.createTag(name: name)
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            defer { UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)") }
            try await withAdoptedTheme(session: session) { store in
                MastheadGeometry.resetRowTwo()
                PostDetailOracle.resetStamp(post.id)
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: width, height: 750),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                let hosting = NSHostingView(
                    rootView: PostDetailView(session: session, postID: post.id)
                        .environment(store))
                hosting.frame = NSRect(x: 0, y: 0, width: width, height: 750)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                for _ in 0..<12 {
                    hosting.layoutSubtreeIfNeeded()
                    window.layoutIfNeeded()
                    window.displayIfNeeded()
                    pump()
                    await Task.yield()
                }
                try await body(session, post.id)
            }
        }
    }
}
