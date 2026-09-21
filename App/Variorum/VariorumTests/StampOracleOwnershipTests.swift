//
//  StampOracleOwnershipTests.swift
//  VariorumTests
//
//  **13u4 UNIT S2 — `KnownIssuesAndTechDebt` row 51's two DEBUG-oracle
//  edges, swept together.** Both are the same defect in two files: a
//  registration keyed by its SUBJECT with no record of WHO registered it,
//  so a departing view tears down a registration that belongs to a view
//  still on screen.
//
//    · **`PostDetailOracle.resetStamp` with the same note in TWO WINDOWS**
//      (17q's R-8, the 18h ladder's R1-14 half left with its reason):
//      `stampShown` / `stampEditedAt` / `flipStamp` are keyed by note, and
//      the masthead clears its note's row on `onDisappear` and on a
//      `.task(id:)` swap. With the SAME note open twice, closing either
//      window empties the other masthead's entries.
//    · **`CatalogStampOracle.forget` on `onDisappear`** (the 18h ladder's
//      R3-10 hygiene): SwiftUI does not promise a departing view's
//      `onDisappear` runs BEFORE its successor's `onAppear`, so a recycled
//      card — same note, same slot — can have its fresh words forgotten by
//      the instance it replaced.
//
//  Both are DEBUG-only and neither is a shipped consequence: the failure
//  mode is a pin reading an empty oracle while the words are on screen —
//  "a green pin that proved nothing" in the other direction, a RED pin that
//  proved nothing. They are swept because row 51 asks for it and because
//  the fix is one idea: **the registrant names itself, and a teardown
//  clears only what it still owns.**
//
//  RED-ON-OLD, measured rather than reasoned (the numbers are in the UNIT
//  S2 RECORD): the two-window pin below COMPILES on the pre-fix tree and
//  was run there first — red, with the second window's entries gone. The
//  card pin does not compile there (`forget` took no owner), which is the
//  `MastheadStampTests` "product row" shape: the API it drives did not
//  exist.
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
@Suite("The stamp oracles' ownership (13u4 UNIT S2 — row 51)", .serialized)
struct StampOracleOwnershipTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(until predicate: () -> Bool, maxTurns: Int = 60) async {
        for _ in 0..<maxTurns {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func mount<V: View>(_ content: V) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 420, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: content.frame(width: 420, height: 80, alignment: .leading))
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

    private func close(_ window: NSWindow) {
        window.contentView = nil
        window.orderOut(nil)
        window.close()
    }

    /// **THE TWO-WINDOW EDGE, in a real pair of windows.** The same note's
    /// masthead stamp stands in two windows; the first goes away; the
    /// second is still on screen and its DEBUG entries must still be
    /// there — because a pin that reads them is asking about a masthead
    /// that exists.
    ///
    /// **RED ON OLD** (measured on the pre-fix tree): closing the first
    /// window ran `resetStamp(postID)`, which cleared the note's row
    /// wholesale — `flipStamp` and `stampShown` both nil with the second
    /// masthead drawn.
    @Test func closingOneOfTwoWindowsOnOneNoteLeavesTheOthersStampRegistered() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 51))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "two windows, one note")
            _ = try session.operations.newBlock(in: post.id, text: "a block")
            #if DEBUG
            PostDetailOracle.resetStamp(post.id, in: session.debugProbeScope)

            let first = mount(
                MastheadStamp(session: session, postID: post.id, tokens: .terminalLight))
            await settle(until: { PostDetailOracle.flipStamp[post.id] != nil })
            #expect(PostDetailOracle.flipStamp[post.id] != nil, "the first masthead registered")

            let second = mount(
                MastheadStamp(session: session, postID: post.id, tokens: .terminalLight))
            defer { close(second) }
            await settle(until: { PostDetailOracle.stampShown[post.id] != nil })

            close(first)
            await settle(until: { false }, maxTurns: 10)

            #expect(PostDetailOracle.flipStamp[post.id] != nil,
                    "the second window's stamp is still on screen, so its door is still wired")
            #expect(PostDetailOracle.stampShown[post.id] != nil,
                    "…and its words are still reported")
            #endif
        }
    }

    /// **THE RECYCLED-CARD EDGE, at its mechanism.** SwiftUI's teardown
    /// order is not something a test can force — which is exactly why the
    /// claim is made about the ORACLE rather than about a mount: a
    /// successor that has already recorded its words must not lose them to
    /// its predecessor's late `onDisappear`.
    ///
    /// **RED ON OLD by non-compilation** (the `MastheadStampTests` product
    /// -row shape): `forget` took no owner, so a late forget cleared the
    /// slot whatever had happened since.
    @Test func aLateForgetFromTheDepartingCardDoesNotEmptyItsSuccessorsSlot() {
        #if DEBUG
        let key = "note-\(UUID().uuidString)"
        let departing = UUID()
        let successor = UUID()
        CatalogStampOracle.reset(key)
        defer { CatalogStampOracle.reset(key) }

        CatalogStampOracle.record(key, slot: "card.small", words: "edited Sep 9", owner: departing)
        // The successor appears BEFORE the predecessor disappears — the
        // order SwiftUI does not promise against.
        CatalogStampOracle.record(key, slot: "card.small", words: "created Sep 1", owner: successor)
        CatalogStampOracle.forget(key, slot: "card.small", owner: departing)

        #expect(CatalogStampOracle.shown[key]?["card.small"] == "created Sep 1",
                "the successor's words survive its predecessor's late teardown")

        // …and the successor's OWN teardown still empties the slot, so the
        // hygiene the fix protects is not the hygiene it breaks.
        CatalogStampOracle.forget(key, slot: "card.small", owner: successor)
        #expect(CatalogStampOracle.shown[key]?["card.small"] == nil,
                "the owner's own teardown still forgets")
        #endif
    }

    /// The masthead's half of the same claim, at ITS mechanism: a release
    /// from a masthead that no longer owns the note's row is a no-op, while
    /// the owner's release clears it — and a PIN's own pre-mount reset
    /// clears unconditionally, because a pin owns nothing and must be able
    /// to start from empty.
    @Test func aReleaseFromANonOwnerIsANoOpAndAPinsResetIsNot() {
        #if DEBUG
        let key = "note-\(UUID().uuidString)"
        let first = UUID()
        let second = UUID()
        PostDetailOracle.resetStamp(key, in: "unscoped")

        PostDetailOracle.recordStamp(key, words: "edited today 1:33 PM", owner: first)
        PostDetailOracle.recordStamp(key, words: "edited today 1:34 PM", owner: second)
        PostDetailOracle.releaseStamp(key, owner: first, in: "unscoped")
        #expect(PostDetailOracle.stampShown[key] == "edited today 1:34 PM",
                "the owner is the last registrant; the other's release does nothing")

        PostDetailOracle.releaseStamp(key, owner: second, in: "unscoped")
        #expect(PostDetailOracle.stampShown[key] == nil, "the owner's release clears")

        PostDetailOracle.recordStamp(key, words: "edited today 1:35 PM", owner: first)
        PostDetailOracle.resetStamp(key, in: "unscoped")
        #expect(PostDetailOracle.stampShown[key] == nil,
                "a pin's reset owns nothing and clears anyway")
        #endif
    }
}
