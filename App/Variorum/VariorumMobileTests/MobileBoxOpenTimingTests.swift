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
import QuartzCore
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// Counts the display refreshes the main run loop delivers from the moment it
/// is installed: a `CADisplayLink` on the run loop and in the mode a
/// frame-later mark rides (`NextFrameTick` in `MobileTiming.swift`: `.main`,
/// `.common`), called once per refresh until it is stopped.
@MainActor
private final class RefreshCounter: NSObject {
    private(set) var refreshes = 0
    private var link: CADisplayLink?

    func start() {
        let link = CADisplayLink(target: self, selector: #selector(refreshed))
        self.link = link
        link.add(to: .main, forMode: .common)
    }

    func stop() {
        link?.invalidate()
        link = nil
    }

    @objc private func refreshed() { refreshes += 1 }
}

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

    /// **Every frame-later mark already scheduled has fired** when this
    /// returns (the merge gate's one red, G.1 — the run record
    /// `notes/plans/vm-47-sizes-and-look.md` §6 ▸ "The gate's one red").
    ///
    /// A frame-later mark is `MobileTiming.afterNextFrame`'s one-shot display
    /// link, installed on the main run loop and called at the first refresh
    /// after it; nothing cancels it when the test that scheduled it ends. This
    /// waits for its OWN link, installed after every such mark, to be called at
    /// two refreshes. Why it cannot return early: a link installed earlier is
    /// due at a refresh no later than one installed after it, so every pending
    /// mark was due by the counter's first refresh; and the main run loop calls
    /// one refresh's links before it reaches the next refresh, so by the
    /// counter's second every one of them has been called — whatever their
    /// order within a refresh. The wait is counted in refreshes, never in time:
    /// the deadline only keeps a display link that never ticks from hanging
    /// the suite, and it says so.
    private func drainFrameLaterMarks(sourceLocation: SourceLocation = #_sourceLocation) async {
        let counter = RefreshCounter()
        counter.start()
        defer { counter.stop() }
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(10))
        while counter.refreshes < 2 {
            guard clock.now < deadline else {
                Issue.record(
                    "the display link reached no second refresh in 10 s — no frame-later mark is known to have fired",
                    sourceLocation: sourceLocation)
                return
            }
            try? await Task.sleep(for: .milliseconds(1))
        }
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

    /// **PIN (the merge gate's one red, G.1 — the run record
    /// `notes/plans/vm-47-sizes-and-look.md` §6): a paint mark an earlier test
    /// left pending cannot end this suite's Open.** An editor's first render
    /// schedules its note's paint for the next frame
    /// (`MobileEditorViewModel.applyProjection`'s `.initialRender` →
    /// `MobileTiming.noteRendered`), and nothing cancels the mark when its test
    /// ends. It is planted here the way the suite before this one leaves it —
    /// an editor rendered, then nothing that lets the main run loop turn — so it
    /// is pending when the Open begins its span; once it fires it ends that
    /// span as if the box's note had painted.
    ///
    /// RED BEFORE G.1's FIX (`freshSpans` let no frame pass): the planted mark
    /// fired inside the span — the span closed on the wrong paint, which
    /// recorded its one sample, and the note's own paint found nothing open:
    /// the gate's two issues, `anOpenThatFilesIsStillTimed`'s `:98` and `:101`.
    @Test func aPaintMarkAnEarlierRenderLeftCannotEndTheOpen() async throws {
        try await withEditorWorld { session, _ in
            recorder.setEnabled(true)
            // What earlier tests left fires here, so the one mark pending
            // below is the one this test plants.
            await drainFrameLaterMarks()
            let postID = try await makePost(session, blocks: ["A note an earlier test rendered."])
            let editor = makeEditor(session, postID: postID).model
            await editor.loadOnce()  // its first render: the note's paint waits for the next frame
            // Nothing below suspends before the press but the suite's own
            // `freshSpans`, so the planted mark can fire before the Open's span
            // begins only if `freshSpans` lets it.
            AppTiming.noteRequested()  // the planted mark's witness: its paint ends this span too
            freshSpans()
            let box = quietBox(session)
            box.text = "a thought to open"
            box.open()
            for _ in 0..<2_000 where box.pendingOpen == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            // A mark pending at the press has fired by now, whatever the load.
            await drainFrameLaterMarks()
            #expect(box.pendingOpen != nil, "the premise: the note was filed and handed off")
            #expect(!recorder.isOpen(.noteOpenToScreen), "the premise: the planted paint mark fired")
            #expect(recorder.isOpen(.boxOpenToNote), "a paint scheduled before the press does not end this Open")
            let painted = samples(.boxOpenToNote)
            AppTiming.notePainted()
            #expect(samples(.boxOpenToNote) == painted + 1, "the note's own paint records the Open")
            recorder.cancel(.noteOpenToScreen)
            recorder.cancel(.boxOpenToKeyboard)  // no keyboard rises in a test host
        }
    }
}
