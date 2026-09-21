//
//  QuickNoteParkTests.swift
//  VariorumTests
//
//  **17b row 65 (RUN A batch A1) — the quick-note pad's close/quit-while-
//  refused road.** KnownIssues row 65; the orchestrator's ruling (Option 1
//  + the 1b rider, both PROVISIONAL — QUESTIONS #137) is recorded in
//  `notes/plans/run-a-custody-text-loss.md`.
//
//  THE MECHANISM, traced: `QuickNotePad` is `@State` inside `QuickNoteView`
//  and `pad.text` is the ONLY place a capture exists until a note holds it
//  (the scene is a singleton `Window`, so a close tears the view and its
//  state down). 13u3 UNIT C made a refusal KEEP the text — right on the
//  ⏎/⌘⏎ road, where the pad stays open — but two roads have no pad left
//  afterwards:
//
//   · CLOSE: `.onDisappear` spawns `Task { pad.close() }`; the refusal
//     preserves `text` on an object whose LAST STRONG REFERENCE is that
//     task, which then returns. The words are unreachable from anywhere in
//     the app — and the sentence the status seam spoke, *"Your text is
//     still here — try again in a moment"*, was false on that road.
//   · QUIT: `QuitFinalizeRegistry.finalizeAll()` discards the
//     `@discardableResult` outcome outright and
//     `applicationShouldTerminate` replied `true` unconditionally, so a
//     refusal at quit was not even observable.
//
//  The ruling's four pins are below, in its order — with pin (iii) split
//  in two: the park's own one-shot, and the quit door's decision as the
//  delegate actually consults it.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withParkWorld<T>(
    _ body: @MainActor (AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

/// A pad whose store REFUSES — the endorsed defaulted-seam pattern
/// (`QuickNotePad.mint`'s own words): production never sets it, and a
/// refusal is otherwise unreachable without breaking the store.
@MainActor
private func refusingPad(_ session: AppSession) -> QuickNotePad {
    let pad = QuickNotePad(session: session)
    pad.mint = { _, _ in
        .refused(QuickNoteCopy.refusal(for: OperationError.lockedPost(id: "c1")))
    }
    return pad
}

@Suite("17b row 65 — a refused capture survives the pad", .serialized)
@MainActor
struct QuickNoteParkTests {
    private static let capture = "This capture is the row-65 road: typed, unfiled, one window away from gone."

    /// **PIN (i) — RED ON OLD.** Refused, then CLOSED: the words used to
    /// die with the view's `@State`. A fresh summon now brings them back
    /// and says why the box is not empty.
    ///
    /// DISCRIMINATING REVERT (verified): delete the `session.quickNotePark.park(...)`
    /// call from `QuickNotePad.take()`'s `.refused` arm — the fresh pad
    /// comes up empty and this fails at its first expectation.
    @Test func aRefusedCaptureComesBackAtTheNextSummon() async throws {
        try await withParkWorld { session in
            let pad = refusingPad(session)
            pad.text = Self.capture
            pad.titleFromFirstWords = true

            // ⏎ refuses — the pad keeps it (13u3 UNIT C, unchanged) …
            guard case .refused = await pad.fileExplicitly() else {
                Issue.record("the premise: the store refused")
                return
            }
            #expect(pad.text == Self.capture)

            // … and then she closes the pad. This is the road row 65 names:
            // `close()` tries again, is refused again, and the view goes.
            guard case .refused = await pad.close() else {
                Issue.record("the close road's retry is refused too")
                return
            }

            // The fresh pad a later summon builds — a different object,
            // exactly as the singleton window produces.
            let next = QuickNotePad(session: session)
            #expect(next.text.isEmpty, "it starts empty, like every summon")
            next.restoreParkedCapture()

            #expect(next.text == Self.capture, "her words came back")
            #expect(next.titleFromFirstWords, "…and the decision she had made about the name")
            #expect(next.restoredNote == QuickNoteCopy.restoredCapture,
                    "the pad says why the box is not empty (binding 3)")

            // Binding 2: the park let go in the same breath — no ghost, no
            // double restore.
            #expect(session.quickNotePark.held == nil)
            let third = QuickNotePad(session: session)
            third.restoreParkedCapture()
            #expect(third.text.isEmpty, "the pad is the only home again")
            #expect(third.restoredNote == nil)
        }
    }

    /// **PIN (ii)** — `.filed` and `.nothingToFile` clear the park
    /// (binding 2), so a capture that lands can never come back as a ghost.
    @Test func filingOrEmptyingClearsThePark() async throws {
        try await withParkWorld { session in
            let pad = refusingPad(session)
            pad.text = Self.capture
            _ = await pad.fileExplicitly()
            #expect(session.quickNotePark.held != nil, "the premise: something is parked")

            // The store comes back and the retry lands.
            pad.mint = nil
            #expect(await pad.fileExplicitly().postID != nil)
            #expect(session.quickNotePark.held == nil, "filed — the park holds nothing")

            // And the other road out: a pad with nothing in it.
            let other = refusingPad(session)
            other.text = "held again"
            _ = await other.fileExplicitly()
            #expect(session.quickNotePark.held != nil)
            other.text = "   "
            #expect(await other.fileExplicitly() == .nothingToFile)
            #expect(session.quickNotePark.held == nil,
                    "nothing to file — and nothing left behind either")
        }
    }

    /// **PIN (iii) — RED ON OLD.** The 1b rider: a refused capture standing
    /// at quit declines the termination ONCE; the second consecutive ⌘Q
    /// always proceeds. (Red on old because `applicationShouldTerminate`
    /// replied `true` unconditionally, and because nothing parked at all.)
    @Test func aRefusedCaptureAtQuitDeclinesOnceAndThenProceeds() async throws {
        try await withParkWorld { session in
            let pad = refusingPad(session)
            pad.text = Self.capture
            // The quit road's own call — what `quitFinalize` runs.
            guard case .refused = await pad.finalizeAtQuit() else {
                Issue.record("the premise: the quit-time file was refused")
                return
            }
            #expect(session.quickNotePark.held != nil, "the words are parked, not gone")

            #expect(session.quickNotePark.declineQuitOnce(),
                    "the first ⌘Q is declined — macOS's unsaved-work grammar")
            #expect(!session.quickNotePark.declineQuitOnce(),
                    "the second consecutive ⌘Q always proceeds — she is never trapped")
            #expect(!session.quickNotePark.declineQuitOnce())

            // A refusal RESOLVED and later arising again re-arms its own
            // single decline (binding 4's last clause).
            session.quickNotePark.clear()
            let again = refusingPad(session)
            again.text = "a second thought, refused in its turn"
            _ = await again.finalizeAtQuit()
            #expect(session.quickNotePark.declineQuitOnce(),
                    "a fresh refusal gets its own one-shot")
            #expect(!session.quickNotePark.declineQuitOnce())
        }
    }

    /// **PIN (iii), the DELEGATE's half** — the same one-shot as the quit
    /// door actually consults it, plus binding 4's "speaks where the pad
    /// cannot": with no pad on screen the status seam carries the close
    /// road's sentence, because a quit that quietly refuses to quit is its
    /// own defect. (`applicationShouldTerminate` itself is not driven: it
    /// would mean calling `reply(toApplicationShouldTerminate:)` on the
    /// real `NSApp` inside the test host.)
    @Test func theQuitDoorsOwnDecisionDeclinesOnceAndSpeaks() async throws {
        try await withParkWorld { session in
            let delegate = VariorumAppDelegate()
            delegate.session = session
            #expect(!delegate.declineQuitIfACaptureStands(),
                    "nothing parked — ⌘Q is never touched")

            let pad = refusingPad(session)
            pad.text = Self.capture
            _ = await pad.finalizeAtQuit()
            session.quickNotePark.isPadShowing = false   // the pad had been closed

            #expect(delegate.declineQuitIfACaptureStands(), "declined once")
            #expect(session.status.current?.text == QuickNoteCopy.parkedOnClose,
                    "…and it says so, since no pad is up to say it")
            #expect(session.status.current?.kind == .refusal)

            #expect(!delegate.declineQuitIfACaptureStands(),
                    "the second consecutive ⌘Q proceeds")

            // With the pad ON SCREEN it is already speaking its own refusal
            // line, so the seam stays quiet — one event, said once.
            session.quickNotePark.clear()
            session.status.clear()
            let open = refusingPad(session)
            open.text = "still here, pad and all"
            _ = await open.finalizeAtQuit()
            session.quickNotePark.isPadShowing = true
            #expect(delegate.declineQuitIfACaptureStands())
            #expect(session.status.current == nil, "the pad carries it — never twice")
        }
    }

    /// **PIN (iv) — THE GUARD.** The park holds REFUSED captures only
    /// (binding 1). Her deliberate-abandon grammar is untouched: a close
    /// with nothing refused FILES, exactly as her round-14.2 ruling says,
    /// and leaves nothing behind to restore — so the park can never widen
    /// into a general draft-keeper.
    @Test func aCloseWithNothingRefusedKeepsNothing() async throws {
        try await withParkWorld { session in
            let pad = QuickNotePad(session: session)   // a HEALTHY store
            pad.text = "an ordinary capture, closed rather than filed"

            #expect(await pad.close().postID != nil, "closing files it (her round-14.2)")
            #expect(session.quickNotePark.held == nil,
                    "nothing was refused, so nothing is parked")

            let next = QuickNotePad(session: session)
            next.restoreParkedCapture()
            #expect(next.text.isEmpty, "the next summon is a fresh pad — the ruled grammar")
            #expect(next.restoredNote == nil)

            // And the emptier road: an abandoned EMPTY pad keeps nothing
            // either, and speaks nothing.
            let empty = QuickNotePad(session: session)
            #expect(await empty.close() == .nothingToFile)
            #expect(session.quickNotePark.held == nil)
        }
    }
}
