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

/// Runs `body` with the editor's debug assertions muted (the
/// `MobileFallbackCanary` N2 pattern). A pin that exercises an honest
/// RECOVERY road must not be stopped by the assertion that announces it;
/// the models' counters are the oracle instead.
///
/// The mute is TASK-SCOPED (round-2 ladder round 1, MINOR 4): this body
/// holds it across hundreds of `await`s, and Swift Testing runs suites in
/// parallel — a process-global handler would silently disable the editor's
/// Debug assertions inside whatever other `@MainActor` test was scheduled
/// during a suspension. A task-local binding reaches this body and the
/// tasks spawned inside it (which is exactly `desyncRecovery`'s heal) and
/// nothing else.
@MainActor
func withEditorAssertionsMuted<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ _, _, _ in }) {
        try await body()
    }
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

    /// **The round-2 ladder's MAJOR 1, pinned.** The first binding bounded
    /// the report's MAGNITUDE and its START — never its EXTENT. So a
    /// transaction that begins inside the approved range and runs PAST the
    /// region's end was still consumed, as long as it removed no more
    /// characters than the approval held.
    ///
    /// Her own stack names this shape:
    /// `_deleteBackwardAndNotify:reinsertText:overrideOriginalContext…` is
    /// a delete COMPOSED WITH A REINSERTION, and her transactions
    /// demonstrably crossed two separators. Here the gate approves
    /// `(16, 5)` → `""` (delete "Gamma", net −5) and one transaction
    /// replaces `(16, 11)` — "Gamma\ndelta", crossing the tail separator —
    /// with seven characters, reporting `editedRange (16, 7)`, `delta −4`.
    ///
    /// RED ON THE PRE-FIX TREE, and quietly: 4 ≤ 5 so the old guard
    /// passed, `applyBlockEdit(at: 2, lengthDelta: −4)` succeeded (5 − 4 =
    /// 1 ≥ 0, no trap), and afterwards `index.documentLength` and
    /// `storage.length` AGREE at 23 — so the totals check everything
    /// downstream leans on is satisfied, `restampProjection` stamps
    /// consistently with the corrupted index, and the Debug identity audit
    /// computes clean. Then `recordAutosave(entryIndex: 2, …)` reads
    /// `viewText((16, 1))` and writes her whole paragraph "Gamma" to the
    /// store as ONE CHARACTER — through the ledger, so echo detection
    /// never notices. **That is worse than the crash this batch fixed: a
    /// crash is loud and loses nothing committed; this loses her prose in
    /// silence.**
    ///
    /// GREEN AFTER: the net change (−4) is not the approved one (−5), the
    /// arming is declined, and `fallbackVerdict` recomputes `(16, 11)`
    /// against the pre-edit index — a span crossing block 2 into the tail,
    /// which no region contains — so the honest road runs and the store is
    /// untouched.
    @Test func aComposedTransactionWiderThanItsApprovalIsNotConsumed() async throws {
        try await withEditorWorld { session, db in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage
                let before = try await storedBlockTexts(db, postID: world.postID)
                #expect(before == ["Alpha", "Beta beta", "Gamma"])

                // The gate approves deleting exactly the third block.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 16, length: 5), replacement: ""))

                // …and one coalesced transaction replaces eleven characters
                // — across the tail separator — with seven.
                storage.beginEditing()
                storage.replaceCharacters(
                    in: NSRange(location: 16, length: 11), with: "Gamma??")
                storage.endEditing()

                #expect(model.desyncRecoveryCount == 1,
                        "the un-described transaction took the honest road")
                await settleEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length,
                        "the surface healed from the store")
                #expect(storage.string == "Alpha\nBeta beta\nGamma\ndelta",
                        "the store is truth: the un-routable transaction did not stand")
                await model.autosave.flushNow()
                #expect(try await storedBlockTexts(db, postID: world.postID) == before,
                        "her paragraph was not overwritten with one character")
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

// MARK: - M13: the paste's bulk intent is discarded with its arming

@MainActor
@Suite("Mobile edit routing — a discarded arming takes its paste intent (round 2, M13)")
struct MobileBulkArmingTests {
    /// **M13** — a state batch 1's own binding created, and it closes
    /// where it was opened. `bulkPending` is armed at the gate BESIDE the
    /// verdict, off the same call (`.tail` + `isPaste`). When the binding
    /// later declines that arming, the verdict goes and the flag stayed —
    /// so the next crystallization ran as `.bulk` instead of `.typing`.
    ///
    /// The difference is visible in the store: `.typing` mints only
    /// COMPLETED paragraphs (a tail with no newline mints nothing), while
    /// `.bulk` segments the whole tail and closes the region. So a
    /// half-typed sentence becomes a block early — a one-shot wrong
    /// segmentation kind, no data loss, and exactly the kind of quiet
    /// wrongness the binding exists to stop.
    ///
    /// RED ON THE PRE-FIX TREE: "delta!" mints as a fourth block.
    @Test func aRejectedArmingClearsThePastesBulkIntent() async throws {
        try await withEditorWorld { session, db in
            let world = try await editRoutingFixture(session)
            let model = world.model
            let storage = world.storage

            // A PASTE is approved into the open tail: the verdict AND the
            // bulk-entry intent arm together.
            #expect(model.shouldChangeText(
                in: NSRange(location: 22, length: 5), replacement: "one\ntwo", isPaste: true))

            // …but what lands is a different edit entirely (the gate-less
            // system road), so the arming is declined.
            systemPathEdit(storage, range: NSRange(location: 8, length: 1), replacement: "")
            #expect(model.index.entries.map(\.length) == [5, 8, 5],
                    "the landing routed by fallback to its own block")

            // One ordinary keystroke in the tail now runs the
            // crystallization the flag would have mis-kinded.
            typeAtEnd(model, storage, "!")
            await model.awaitMintSettle()

            #expect(model.index.entries.count == 3,
                    "typing mints nothing: the tail holds no completed paragraph")
            #expect(model.index.tailLength == 6, "the tail is still open, holding 'delta!'")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: world.postID)
                    == ["Alpha", "Bea beta", "Gamma"],
                    "the half-typed tail did not become a block")
        }
    }

    /// The other half, so the fix cannot be satisfied by never arming bulk
    /// at all: an arming that IS honored keeps its paste semantics.
    @Test func anHonoredPasteStillCrystallizesAsBulk() async throws {
        try await withEditorWorld { session, db in
            let world = try await editRoutingFixture(session)
            let model = world.model
            let storage = world.storage

            // The paste lands exactly as approved (gate, then the edit).
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: 22, length: 5), replacement: "one\ntwo",
                isPaste: true))
            await model.awaitMintSettle()

            #expect(model.index.tailLength == nil, "bulk entry closes the tail region")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: world.postID)
                    == ["Alpha", "Beta beta", "Gamma", "one", "two"],
                    "the pasted paragraphs segmented on entry (AppSpec §7)")
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

    /// **Round-2 ladder round 1, MINOR 3 — the ORDERING, which the pin
    /// above structurally cannot see.** It holds the surface strongly
    /// across `teardown()`'s await, so the disarm always lands whenever it
    /// runs. Production does not: `textView` is weak, `finish()` is a real
    /// DB round trip, and the only production caller is a NavigationStack
    /// pop, where SwiftUI releases the representable CONCURRENTLY — so a
    /// disarm sitting after the await silently did nothing whenever the
    /// view lost that race, which is exactly the accumulation M2e exists
    /// to close.
    ///
    /// The `afterDisarm` seam is what makes the ordering observable at all
    /// (the pre-fix ordering cannot be caught by racing it — a race that
    /// sometimes reproduces is not a pin). RED BY BEHAVIOURAL REVERT: move
    /// `textView?.disarmCanary()` back below `await finish()` and the
    /// observation reads `true`.
    @Test func theDisarmIsTeardownsFirstAct() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "canary ordering", profile: .blog)
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
            #expect(surface.textView.canaryIsArmed)

            var armedAtFirstAwait: Bool?
            await model.teardown(afterDisarm: {
                armedAtFirstAwait = surface.textView.canaryIsArmed
            })
            #expect(armedAtFirstAwait == false,
                    "the tick is gone before teardown ever suspends")
        }
    }

    /// The other end of the same class: a canary that never reaches a
    /// teardown at all — a failed load, a cancelled push, or the pop above
    /// losing its race — still stops its tick. `Timer.scheduledTimer` hands
    /// ownership to the run loop, so an un-invalidated tick outlives every
    /// reference to it and keeps waking the main thread every 30 s for the
    /// process's life.
    ///
    /// RED ON THE PRE-FIX TREE (no `deinit`): the timer is still valid
    /// after its canary is gone. The pin holds the `Timer` itself, because
    /// once the canary deallocates there is nothing else left to ask.
    @Test func aCanaryThatDiesWithoutADisarmStillStopsItsTick() throws {
        let surface = MobileWriteSurfaceView()
        var canary: MobileFallbackCanary? = MobileFallbackCanary()
        canary?.arm(for: surface.textView)
        let timer = try #require(canary?.idleTimer, "the tick is scheduled")
        #expect(timer.isValid)

        canary = nil
        #expect(!timer.isValid, "the tick dies with its canary")
    }
}
