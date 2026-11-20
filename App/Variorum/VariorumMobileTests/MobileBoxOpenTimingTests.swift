//
//  MobileBoxOpenTimingTests.swift
//  VariorumMobileTests
//
//  VM-64 ladder round 2, finding 8(a) (Part of VM-65) — AN OPEN THAT FILES
//  NOTHING TIMES NOTHING. The record is `notes/plans/fixes/vm-64-timing-and-
//  lags.md` §7 ▸ "Ladder round 2 — fix pass".
//
//  The capture box's Open begins "Open → note on screen" and "Open → keyboard
//  up in the note" at the press (`AppTiming.boxOpenPressed`); when the filing
//  hands back no note (an empty box, a refusal, a withdrawal), nothing opens —
//  and before this fix nothing cancelled the two spans, so the next note
//  painted by any road, or the next keyboard rising, inside the 30 s stale
//  limit ended them as a long, false Open in the row her handoff calls the
//  whole of her second lag.
//
//  These pins READ THE PROCESS'S ONE RECORDER (`AppTiming.recorder` — the
//  marks have no other), which is sound because this host runs its Swift
//  Testing suites one after another: the scheme's `parallelizable = "NO"` is
//  built into the xctestrun as `InProcessParallelizationEnabled = false` (the
//  ladder round 2 responses, O-1). The suite is `.serialized` as well.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-64 ladder round 2 — the box's Open times only an Open that files", .serialized)
struct MobileBoxOpenTimingTests {
    private typealias Recorder = TimingRecorder<AppTimingSeries, AppTimingCounter>
    private var recorder: Recorder { AppTiming.recorder }

    /// A box whose two clocks are OFF (the box suite's `quietBox`).
    private func quietBox(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in throw CancellationError() }
        model.autosaveSleep = { _ in throw CancellationError() }
        return model
    }

    /// The test host's launch enabled the recorder (`MobileTiming.start`); no
    /// span an earlier suite left open may stand in for this test's own.
    private func freshSpans() {
        recorder.setEnabled(true)
        recorder.cancel(.boxOpenToNote)
        recorder.cancel(.boxOpenToKeyboard)
    }

    private func samples(_ series: AppTimingSeries) -> Int {
        recorder.snapshot().stats(series)?.count ?? 0
    }

    /// **THE PIN.** Open on an empty box files nothing: once the box's task has
    /// run, neither Open span is open, and a note painted and a keyboard rising
    /// right after record no Open sample.
    ///
    /// RED ON OLD: both spans stayed open, and the paint and the keyboard each
    /// recorded one false sample.
    @Test func anOpenThatFilesNothingLeavesNoOpenSpan() async throws {
        try await withEditorWorld { session, _ in
            freshSpans()
            let box = quietBox(session)
            box.open()
            #expect(recorder.isOpen(.boxOpenToNote), "the premise: the press begins the span")
            for _ in 0..<500 where recorder.isOpen(.boxOpenToNote) || recorder.isOpen(.boxOpenToKeyboard) {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(2))
            }
            #expect(box.pendingOpen == nil, "an empty box files nothing and opens nothing")
            #expect(!recorder.isOpen(.boxOpenToNote), "no Open → note on screen is waiting")
            #expect(!recorder.isOpen(.boxOpenToKeyboard), "no Open → keyboard up is waiting")

            let painted = samples(.boxOpenToNote)
            let keyboard = samples(.boxOpenToKeyboard)
            AppTiming.notePainted()
            AppTiming.keyboardUp()
            #expect(samples(.boxOpenToNote) == painted, "a later paint records no Open")
            #expect(samples(.boxOpenToKeyboard) == keyboard, "a later keyboard records no Open")
        }
    }

    /// **GUARD (green on both trees): an Open that files still times.** A box
    /// with words files its note, hands it off, and its span waits for the
    /// note's paint, which records one sample.
    @Test func anOpenThatFilesIsStillTimed() async throws {
        try await withEditorWorld { session, _ in
            freshSpans()
            let box = quietBox(session)
            box.text = "a thought to open"
            box.open()
            for _ in 0..<2_000 where box.pendingOpen == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(box.pendingOpen != nil, "the premise: the note was filed and handed off")
            #expect(recorder.isOpen(.boxOpenToNote), "its Open waits for the note's paint")
            let painted = samples(.boxOpenToNote)
            AppTiming.notePainted()
            #expect(samples(.boxOpenToNote) == painted + 1, "the paint records the Open")
            recorder.cancel(.boxOpenToKeyboard)  // no keyboard rises in a test host
        }
    }
}
