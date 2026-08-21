//
//  MobileEditRoutingTests.swift
//  VariorumMobileTests
//
//  Mobile round 2, batch 1 — the delete-at-the-end crash's PINS, the half
//  that does NOT kill the test process on the pre-fix tree. The two exact
//  crash reproductions (and the closed-tail sibling) live in
//  `MobileEditRoutingCrashTests.swift`, because on pre-fix code they die
//  inside `BlockRangeIndex`'s preconditions and a dying process takes the
//  whole suite's report down with it.
//
//  THE MECHANISM these pin (traced in `notes/plans/mobile-round-2-crash-
//  trace.md`, proven from her two 2026-08-20 iPhone logs by symbolication
//  AND disassembly of the shipped binary): `shouldChangeText` computes a
//  verdict against the PRE-edit index and parks it; `storageDidEdit` takes
//  the IDENTITY from that parked answer and the MAGNITUDE from the
//  storage's own report, and nothing checked the two described the same
//  edit. The headline pin below is the clean oracle for the fix — it needs
//  no crash at all, which is the point: the crash was one symptom of
//  wrong bookkeeping, and the wrong bookkeeping is what got fixed.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The shared fixture (the crash trace's §5 document)

/// Three blocks + a freshly-typed open tail:
/// `"Alpha\nBeta beta\nGamma\ndelta"` — entries 5 / 9 / 5, tail 5,
/// documentLength 27, tailRange (22, 5). The trace's worked numeric
/// example runs on exactly this shape.
@MainActor
func editRoutingFixture(
    _ session: AppSession
) async throws -> (model: MobileEditorViewModel, storage: NSTextStorage, postID: String) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: "edit routing", profile: .blog)
    }
    for text in ["Alpha", "Beta beta", "Gamma"] {
        _ = try await session.runner.run { ops in
            try ops.newBlock(in: post.id, text: text, at: .end)
        }
    }
    let (model, storage) = makeEditor(session, postID: post.id)
    await model.loadOnce()
    typeAtEnd(model, storage, "\n")      // opens the tail
    typeAtEnd(model, storage, "delta")   // fills it
    return (model, storage, post.id)
}

/// A gate-LESS storage edit — the shape iOS's system paths really use
/// (autocorrect's `replace(_:withText:)`, dictation revision, a
/// marked-text commit). No `shouldChangeText` call precedes it, which is
/// exactly why a stale arming gets consumed by it.
@MainActor
func systemPathEdit(_ storage: NSTextStorage, range: NSRange, replacement: String) {
    storage.replaceCharacters(
        in: range,
        with: NSAttributedString(
            string: replacement, attributes: [.font: MobileEditorStyle.baseFont]))
}

/// Runs `body` with the editor's debug assertions muted, restoring the
/// handler afterwards (the `MobileFallbackCanary` N2 pattern). A pin that
/// exercises an honest RECOVERY road must not be stopped by the assertion
/// that announces it; the models' counters are the oracle instead.
@MainActor
func withEditorAssertionsMuted<T>(_ body: () async throws -> T) async rethrows -> T {
    let original = EditorAssertionSeam.handler
    EditorAssertionSeam.handler = { _ in }
    defer { EditorAssertionSeam.handler = original }
    return try await body()
}

/// Spins the main actor until `condition` holds or the budget runs out
/// (the house pattern — `desyncRecovery` heals through an async read).
@MainActor
func settleEditor(until condition: () -> Bool, spins: Int = 400) async {
    for _ in 0..<spins {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

// MARK: - The binding (P1 — the headline)

@MainActor
@Suite("Mobile edit routing — the verdict is bound to its edit (round 2, M1)")
struct MobileEditRoutingBindingTests {
    @Test func theFixtureIsTheTracesDocument() async throws {
        try await withEditorWorld { session, _ in
            let world = try await editRoutingFixture(session)
            #expect(world.storage.string == "Alpha\nBeta beta\nGamma\ndelta")
            #expect(world.model.index.entries.map(\.length) == [5, 9, 5])
            #expect(world.model.index.tailLength == 5)
            #expect(world.model.index.documentLength == 27)
            #expect(world.model.index.tailRange == NSRange(location: 22, length: 5))
            #expect(world.model.index.documentLength == world.storage.length)
            #expect(world.model.desyncRecoveryCount == 0)
            #expect(world.model.identityAuditFailures == 0)
        }
    }

    /// **P1 — the pin the whole fix is for.** A verdict armed for an edit
    /// that never lands must not be applied to the edit that lands next.
    ///
    /// The arming-without-landing shape is real and in the code today:
    /// `MobileMarkdownActs.handleReturnKey`'s `.continueList` arm calls
    /// `gateAllows` and then early-returns when the newline did not land,
    /// leaving the slot armed; `inputReplace` and `performTabKey` arm and
    /// then hand off to UIKit. The edit that follows is a gate-LESS system
    /// path (autocorrect / dictation / a marked-text commit), which is the
    /// one road that reads the parked slot without first overwriting it.
    ///
    /// RED ON THE PRE-FIX TREE, with no process death: the stale
    /// `.block(0)` is consumed, so `entries[0]` SHRINKS to 4 while
    /// `entries[1]` — the block the characters actually left — stays 9.
    /// The index still tiles the storage by total LENGTH, so nothing
    /// traps; the identity projection is simply wrong, and the audit sees
    /// it. That quiet version of the bug is why the fix is the BINDING and
    /// not just a fallible mutator.
    ///
    /// The landing is a DELETION deliberately: iOS's attribute fixing
    /// widens an insertion's `didProcessEditing` report (measured here —
    /// a one-character insert mid-paragraph reported `{8, 9}`), while a
    /// deletion's report is exact. A widened gate-less report can already
    /// overflow its entry and take the honest recovery road, which is
    /// correct but is a different story from this one; the deletion keeps
    /// the pin on the binding alone.
    @Test func aStaleVerdictIsNotAppliedToTheNextEdit() async throws {
        try await withEditorWorld { session, _ in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage

                // Arm a verdict for an edit that never reaches storage.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 0, length: 1), replacement: "X"))

                // …then land an unrelated one-character deletion inside
                // block 1, through a path that consults no gate.
                systemPathEdit(storage, range: NSRange(location: 8, length: 1), replacement: "")

                #expect(storage.string == "Alpha\nBea beta\nGamma\ndelta")
                #expect(model.index.entries[1].length == 8,
                        "the edit's own block shrank")
                #expect(model.index.entries[0].length == 5,
                        "the stale verdict's block is untouched")
                #expect(model.index.entries[2].length == 5)
                #expect(model.index.tailLength == 5)
                #expect(model.index.documentLength == storage.length,
                        "the index still tiles the storage exactly")
                #expect(model.identityAuditFailures == 0,
                        "identity did not silently drift onto the wrong block")
                #expect(model.desyncRecoveryCount == 0,
                        "a rejected arming is not a refusal — the report routes by fallback")
            }
        }
    }

    /// The other half of the binding: an arming that DOES describe the
    /// edit that lands is still honored. Without this the pin above could
    /// be satisfied by throwing every arming away, which would retire the
    /// gate's exact churn cost and the open/close-tail gestures with it.
    @Test func anArmingThatStillDescribesItsEditIsHonored() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "honored", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha beta.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // A policed insertion: gate, then the storage edit it approved.
            typeEdit(model, storage, range: NSRange(location: 5, length: 0), replacement: "!")
            #expect(storage.string == "Alpha! beta.")
            #expect(model.index.entries[0].length == 12)
            #expect(model.index.documentLength == storage.length)
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.identityAuditFailures == 0)
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id) == "Alpha! beta.")
        }
    }

    /// The open/close-tail gestures are armings too — the fixture above
    /// already proves `.openTail` survives the binding (it builds its tail
    /// through the gate), and this pins `.closeTail`'s round trip.
    @Test func theTailGesturesSurviveTheBinding() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "tail gestures", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            typeAtEnd(model, storage, "\n")
            #expect(model.index.tailLength == 0, "the tail opened")
            #expect(model.index.documentLength == storage.length)

            // Backspace over the tail's own separator closes it again.
            let separator = try #require(model.index.tailSeparatorOffset)
            typeEdit(
                model, storage,
                range: NSRange(location: separator, length: 1), replacement: "")
            #expect(model.index.tailLength == nil, "the tail closed")
            #expect(model.index.documentLength == storage.length)
            #expect(storage.string == "Alpha")
            #expect(model.desyncRecoveryCount == 0)
        }
    }
}

// MARK: - M2e: the canary's idle tick is disarmed at teardown

@MainActor
@Suite("Mobile TK2 canary — the idle tick is torn down (round 2, M2e)")
struct MobileCanaryTeardownTests {
    /// RED ON THE PRE-FIX TREE: `disarmCanary()` had only test callers, so
    /// a 30-second repeating main-run-loop `Timer` accumulated per note
    /// ever opened, for the process's life.
    @Test func teardownDisarmsTheIdleTick() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "canary teardown", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha", at: .end)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            model.attach(textView: surface.textView)
            #expect(surface.textView.canaryIsArmed, "attach arms the idle tick")

            await model.teardown()
            // Otherwise: one orphaned repeating main-run-loop timer per
            // note ever opened, for the process's life.
            #expect(!surface.textView.canaryIsArmed, "the screen's teardown disarms it")
        }
    }
}
