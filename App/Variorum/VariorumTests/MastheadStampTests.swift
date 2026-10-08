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
        try await withMountedDetail(width: 1100, tags: ["walked", "tutorial"]) { session, postID in
            #if DEBUG
            // Row 50: this pin's OWN masthead, named by its own session —
            // the per-note key rides UNDER the session's scope.
            let oracle = MastheadGeometry.reader(session.debugProbeScope)
            await settle(until: {
                oracle.stampFrames[postID] != nil && oracle.pathChipFrame != nil
                    && oracle.cardFrames.count == 2
                    && oracle.doorFrame != nil
            })
            await settle(until: { false }, maxTurns: 6)
            // Keyed by the NOTE since the ladder's R1-14 — the pin names
            // whose masthead it is reading, rather than whichever mounted last.
            let stamp = try #require(oracle.stampFrames[postID],
                                     "this note's stamp reported its frame")
            let chip = try #require(oracle.pathChipFrame)
            let door = try #require(oracle.doorFrame)
            let masthead = try #require(oracle.contentMidX).magnitude * 2
            #expect(stamp.width > 0 && stamp.height > 0, "it is drawn: \(stamp)")
            #expect(stamp.maxX <= masthead + 0.5, "it stays inside the masthead: \(stamp) of \(masthead)")
            #expect(!stamp.intersects(chip), "it never covers the path chip: \(stamp) vs \(chip)")
            #expect(!stamp.intersects(door), "…nor the ＃ door: \(stamp) vs \(door)")
            for (id, card) in oracle.cardFrames {
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

    /// **A click cycles her THREE faces — edited → created → the clock —
    /// and a click again brings the date back** (13u4 UNIT S2, her item 1:
    /// *"clicking on edited date goes to created, then collapses to a little
    /// clock icon"*), driven through the very closure the Button calls.
    ///
    /// This REPLACES 18h's two-state flip pin, which asserted that a second
    /// click returned to *edited*. That was 18h's own recorded call and her
    /// ruling supersedes it — a RULED behaviour change, so the pin is
    /// rewritten to the ruling rather than owed a red-on-old (13u4's CAST &
    /// DISCIPLINE).
    @Test func aClickCyclesTheStampThroughHerThreeFacesAndBackToTheDate() async throws {
        try await withMountedDetail(width: 1100, tags: []) { _, postID in
            #if DEBUG
            await settle(until: { PostDetailOracle.stampShown[postID] != nil })
            let edited = try #require(PostDetailOracle.stampShown[postID])
            #expect(edited.hasPrefix("edited "), "it rests on the edit stamp: \(edited)")
            #expect(PostDetailOracle.stampFace[postID] == StampFace.edited.rawValue)

            let flip = try #require(
                PostDetailOracle.flipStamp[postID], "the stamp's click reachable")
            flip()
            await settle(until: {
                PostDetailOracle.stampFace[postID] == StampFace.created.rawValue
            })
            let created = try #require(PostDetailOracle.stampShown[postID])
            #expect(created.hasPrefix("created "), "a click shows when it was created: \(created)")

            flip()
            await settle(until: {
                PostDetailOracle.stampFace[postID] == StampFace.clock.rawValue
            })
            #expect(PostDetailOracle.stampFace[postID] == StampFace.clock.rawValue,
                    "a second click COLLAPSES it — her clock icon")
            #expect(PostDetailOracle.stampShown[postID] == nil,
                    "…and the collapsed face says nothing on the row (the words are the hover's)")

            flip()
            await settle(until: {
                PostDetailOracle.stampShown[postID]?.hasPrefix("edited ") == true
            })
            #expect(PostDetailOracle.stampShown[postID]?.hasPrefix("edited ") == true,
                    "a click again brings the date back")
            #expect(PostDetailOracle.stampFace[postID] == StampFace.edited.rawValue)
            #endif
        }
    }

    /// **The choice is REMEMBERED, and a note she has never opened arrives
    /// wearing it** — her item 1's second sentence, which is the whole
    /// reason it is a preference and not a glance: *"remembers this on every
    /// note, so if you're normally in clock mode a new note would open with
    /// only a clock icon."*
    ///
    /// The memory is read through SwiftUI's own `@AppStorage` seam, so the
    /// pin hands the mount a scrubbed suite (`defaultAppStorage`) rather
    /// than writing the dev-store app's real domain — KnownIssues row 42's
    /// hazard, named at the key's own declaration.
    @Test func theRememberedFaceIsWhatANoteSheHasNeverOpenedArrivesIn() async throws {
        let db = try AppDatabase.inMemory()
        let suiteName = "13u4-s2-stampface-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 12))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let first = try session.operations.createPost(title: "the note she was in")
            _ = try session.operations.newBlock(in: first.id, text: "a block")
            let second = try session.operations.createPost(title: "a note she has never opened")
            _ = try session.operations.newBlock(in: second.id, text: "another block")

            #if DEBUG
            PostDetailOracle.resetStamp(first.id, in: session.debugProbeScope)
            PostDetailOracle.resetStamp(second.id, in: session.debugProbeScope)

            // In the first note, click twice: edited → created → clock.
            let firstWindow = mountStamp(session: session, postID: first.id, defaults: defaults)
            await settle(until: { PostDetailOracle.flipStamp[first.id] != nil })
            let flip = try #require(PostDetailOracle.flipStamp[first.id])
            flip()
            flip()
            await settle(until: {
                PostDetailOracle.stampFace[first.id] == StampFace.clock.rawValue
            })
            #expect(StampFace.remembered(defaults) == .clock,
                    "the click is what wrote the preference — never a settings pane")
            closeWindow(firstWindow)

            // A note she has never opened, in the same app: it opens with
            // only the clock icon.
            let secondWindow = mountStamp(session: session, postID: second.id, defaults: defaults)
            defer { closeWindow(secondWindow) }
            await settle(until: { PostDetailOracle.stampFace[second.id] != nil })
            #expect(PostDetailOracle.stampFace[second.id] == StampFace.clock.rawValue,
                    "her sentence, literally: a new note opens in clock mode")
            #expect(PostDetailOracle.stampShown[second.id] == nil,
                    "…with no date words on the row")
            #endif
        }
    }

    /// The cycle and the memory as PURE rules — no window, no store: her
    /// order, the subject each face is about, which face draws words, and
    /// the "a stored value that is not one of the three reads as edited"
    /// posture every local key in this app takes.
    @Test func theCycleAndItsMemoryAreOneRule() throws {
        #expect(StampFace.edited.next == .created)
        #expect(StampFace.created.next == .clock)
        #expect(StampFace.clock.next == .edited)
        #expect(StampFace.allCases.map(\.next.rawValue) == ["created", "clock", "edited"])

        #expect(StampFace.edited.subject == .edited)
        #expect(StampFace.created.subject == .created)
        #expect(StampFace.clock.subject == .edited,
                "the collapsed face is still the note's edit stamp — that is what the hover says")
        #expect(StampFace.edited.showsWords && StampFace.created.showsWords)
        #expect(!StampFace.clock.showsWords)

        let suiteName = "13u4-s2-stampface-pure-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        #expect(StampFace.remembered(defaults) == .edited, "the default is the shipped face")
        defaults.set("clock", forKey: StampFace.key)
        #expect(StampFace.remembered(defaults) == .clock)
        defaults.set("nonsense", forKey: StampFace.key)
        #expect(StampFace.remembered(defaults) == .edited, "a stored stranger reads as the default")
    }

    /// Mounts ONE masthead stamp in its own window, reading its remembered
    /// face from `defaults` (SwiftUI's own `@AppStorage` seam).
    private func mountStamp(
        session: AppSession, postID: String, defaults: UserDefaults
    ) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 420, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: MastheadStamp(session: session, postID: postID, tokens: .terminalLight)
                .defaultAppStorage(defaults)
                .frame(width: 420, height: 80, alignment: .leading))
        hosting.frame = NSRect(x: 0, y: 0, width: 420, height: 80)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    private func closeWindow(_ window: NSWindow) {
        window.contentView = nil
        window.orderOut(nil)
        window.close()
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
            let book = try session.operations.createReading(name: "the field guide", kind: .book)
            _ = try session.operations.addPostToReading(post.id, to: book.id)
            for name in tags {
                let tag = try session.operations.createTag(name: name)
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            defer { UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)") }
            // 13u4 UNIT S2: the stamp's remembered face is read through
            // `@AppStorage`, whose default store is the DEV-STORE app's own
            // `.standard` (KnownIssues row 42 — the test host IS
            // `io.lduarte.Variorum.debug`). A scrubbed suite per mount, so a
            // walk that left the app in clock mode cannot turn these pins
            // red and they cannot leave anything behind for a walk.
            let suiteName = "13u4-s2-masthead-\(UUID().uuidString)"
            let stampDefaults = UserDefaults(suiteName: suiteName) ?? .standard
            stampDefaults.removePersistentDomain(forName: suiteName)
            defer { stampDefaults.removePersistentDomain(forName: suiteName) }
            // 13s-b U1a (A JUSTIFIED EDIT): this pin was measured in the
            // world a voiceless store used to read — Terminal. A store with no
            // voice reads Study since her 2026-10-05 ruling, so the world is
            // named, not inherited.
            try session.operations.setThemeVoice(.terminal)
            try await withAdoptedTheme(session: session) { store in
                let oracle = MastheadGeometry.reader(session.debugProbeScope)
                oracle.resetRowTwo()
                PostDetailOracle.resetStamp(post.id, in: session.debugProbeScope)
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
                        .environment(store)
                        .defaultAppStorage(stampDefaults))
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

                // **The oracles are this note's while its masthead stands,
                // and nobody's after** (the ladder's R2-9) — asserted by
                // every mounted pin rather than by one of them, since the
                // teardown is the same for all three. RED ON OLD: the four
                // dictionaries kept the note's entries (a retained closure
                // among them) after the window went away, and a later pin
                // that forgot to reset could read them as its own.
                #if DEBUG
                window.contentView = nil
                await settle(until: { PostDetailOracle.flipStamp[post.id] == nil }, maxTurns: 20)
                #expect(PostDetailOracle.flipStamp[post.id] == nil,
                        "the closure is not retained past the masthead")
                #expect(PostDetailOracle.stampShown[post.id] == nil)
                #expect(PostDetailOracle.stampEditedAt[post.id] == nil)
                #expect(oracle.stampFrames[post.id] == nil)
                #endif
            }
        }
    }
}
