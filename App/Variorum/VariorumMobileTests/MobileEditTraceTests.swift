//
//  MobileEditTraceTests.swift
//  VariorumMobileTests
//
//  E1's instrument, DRIVEN — because a settling experiment nobody drove is
//  the round's own most expensive lesson (§63: a pin built exactly as both
//  the reviewer and the architect specified would have passed on the
//  pre-fix code — "the round's sixth green-over-nothing, caught by driving
//  it instead of trusting it").
//
//  If these pins did not exist, a session on her phone that produced NO
//  flag would be uninterpretable: it could mean iOS is 1:1, or it could
//  mean the instrument cannot see the thing. These make the negative
//  result MEAN something by proving the positive case first, against the
//  crash trace's own two worked examples.
//
//  What is pinned:
//   · INERTNESS — disarmed, the recorder observes nothing at all (the
//     shipping state, and the P1 claim's oracle).
//   · DETECTION — the two crash shapes, reproduced as the coalesced
//     storage transaction `coordinateEditing:` really delivers, each
//     raising the signals the readout reports. Crash 1 raises the
//     SPECIFIED overrun flag; crash 2 does NOT — which is exactly why the
//     instrument records three predicates and not one.
//   · PAIRING — several gate consults before one storage report is
//     recorded as such (`maxConsultsBeforeAReport`), since "gate calls >
//     reports" is M1's confirmation on its own.
//   · GATE-LESS — a system-path edit (autocorrect / dictation / marked
//     text) is counted and NOT scored as a mismatch, so her readout does
//     not report ordinary autocorrect as a finding.
//   · BOUNDED MEMORY — the ring caps at `ringCapacity` while the counters
//     stay true past the wrap (MobileSoul §2).
//
//  ZERO BEHAVIOUR CHANGE is pinned too: the identical transaction is run
//  armed and disarmed, and the editor's own observable outcomes
//  (`desyncRecoveryCount`, the healed document length, the stored texts)
//  must match exactly.
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile edit trace — E1's instrument, driven (round 2)", .serialized)
struct MobileEditTraceTests {
    /// Runs `body` against a recorder OF THIS TEST'S OWN, armed.
    ///
    /// The app's recorder is deliberately process-global (the readout lives
    /// in Settings, an ocean away from the view model), and Swift Testing
    /// runs suites in PARALLEL — so a test that armed the global store and
    /// then suspended at an `await` would collect every OTHER `@MainActor`
    /// editor suite's keystrokes into its own counts, and an absolute
    /// assertion like "exactly one suspect signature" would break on
    /// scheduling rather than on the code. The `@TaskLocal` binding is the
    /// same answer `EditorAssertionSeam` records for the same hazard
    /// (round-2 ladder round 1, MINOR 4): scoped to this task and the tasks
    /// it spawns, invisible to everything running beside it, and it never
    /// touches the app's persisted arming.
    private func withTraceArmed<T>(_ body: () async throws -> T) async rethrows -> T {
        try await MobileEditTrace.$testRecorder.withValue(
            MobileEditTrace.Recorder(armed: true)
        ) {
            try await body()
        }
    }

    /// The same isolation, DISARMED — the shipping state, observed without
    /// the global store's arming being touched at all.
    private func withTraceDisarmed<T>(_ body: () async throws -> T) async rethrows -> T {
        try await MobileEditTrace.$testRecorder.withValue(
            MobileEditTrace.Recorder(armed: false)
        ) {
            try await body()
        }
    }

    /// The coalesced transaction her `deleteBackward` produced: one
    /// `beginEditing` / `replaceCharacters` / `endEditing` block whose net
    /// deletion is wider than the region the gate last approved. Driven
    /// directly, so the pin does not depend on any iOS version's keyboard
    /// decomposition (`MobileEditRoutingCrashTests`' reasoning, reused).
    private func coalescedDelete(_ storage: NSTextStorage, _ range: NSRange) {
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: "")
        storage.endEditing()
    }

    // MARK: - Inertness (the shipping state)

    @Test func disarmedTheRecorderObservesNothing() async throws {
        try await withTraceDisarmed {
            try await withEditorWorld { session, _ in
                let world = try await editRoutingFixture(session)
                typeEdit(
                    world.model, world.storage,
                    range: NSRange(location: 8, length: 0), replacement: "!")
                #expect(world.model.index.entries.map(\.length) == [5, 10, 5])
            }

            #expect(MobileEditTrace.events.isEmpty,
                    "disarmed, nothing is recorded — the ring stays empty")
            #expect(MobileEditTrace.summary == MobileEditTrace.Summary(),
                    "disarmed, no counter moves")
        }
    }

    // MARK: - Detection (the two crashes, as the readout would show them)

    /// **Crash 1's shape (15:52:43, `applyBlockEdit`).** The last gate
    /// consult describes `(16, 5)` — inside the third block — and the
    /// transaction then deletes fifteen characters from offset 12. The
    /// old span (12, 15) ends at 27; the consult's upper bound is 21.
    ///
    /// This is the row the ladder's specified predicate was written for,
    /// and the instrument must raise it.
    @Test func theBlockCrashShapeRaisesTheSpecifiedOverrunFlag() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await editRoutingFixture(session)
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 16, length: 5), replacement: ""))
                    coalescedDelete(world.storage, NSRange(location: 12, length: 15))
                    await settleEditor(until: {
                        world.model.index.documentLength == world.storage.length
                    })
                }
            }

            let s = MobileEditTrace.summary
            #expect(s.overruns == 1, "the SPECIFIED signature fired")
            #expect(s.mismatches == 1)
            #expect(s.armingsRejected == 1, "the binding refused the stale arming")
            #expect(s.desyncRecoveries >= 1, "and the honest road was taken")

            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(report.flags.contains(.overrun))
            #expect(report.flags.contains(.startsBefore))
            #expect(report.flags.contains(.netMismatch))
            #expect(report.location == 12)
            #expect(report.value == -15)

            // The readout's own words, so a line she reads back names the
            // finding rather than a raw flag byte.
            let line = MobileEditTrace.line(for: report)
            #expect(line.contains("OVERRUN"))
            #expect(MobileEditTrace.headline().contains("SUSPECT SIGNATURE   1"))
            #expect(MobileEditTrace.headline().contains("of which overrun  1 of 1 testable"))
        }
    }

    /// **Crash 2's shape (13:59:27, `applyTailEdit`) — and the reason the
    /// instrument records THREE predicates.** The last consult is the tail
    /// `(22, 5)`, whose upper bound is 27; the transaction's old span
    /// (12, 15) also ends at 27. **The specified overrun predicate is
    /// SILENT on one of the two crashes we actually have** — the other two
    /// signals are what catch it.
    ///
    /// If this pin ever goes green on `overruns == 1`, the predicate's
    /// arithmetic changed and this comment is the record of why it was
    /// written this way.
    @Test func theTailCrashShapeIsMissedByTheSpecifiedFlagAndCaughtByTheOthers() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await editRoutingFixture(session)
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 22, length: 5), replacement: ""))
                    coalescedDelete(world.storage, NSRange(location: 12, length: 15))
                    await settleEditor(until: {
                        world.model.index.documentLength == world.storage.length
                    })
                }
            }

            let s = MobileEditTrace.summary
            #expect(s.overruns == 0,
                    "the old span ends EXACTLY at the consult's upper bound")
            #expect(s.mismatches == 1, "…and the other two predicates catch it")
            #expect(s.armingsRejected == 1)

            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(!report.flags.contains(.overrun))
            #expect(report.flags.contains(.startsBefore))
            #expect(report.flags.contains(.netMismatch))
        }
    }

    // MARK: - Why the specified predicate needed a carve-out

    /// **The evidence for the one design decision this instrument makes.**
    ///
    /// The round's record specified the flag as *"any report whose OLD span
    /// extends past the last consult's `range.upperBound`"*. Written
    /// literally that fires on EVERY ordinary keystroke on iOS, because the
    /// old span is reconstructed from `length - delta` and iOS reports a
    /// range WIDER than the characters that moved while leaving `delta`
    /// exact. A readout that flags every keystroke answers nothing.
    ///
    /// This pin measures the widening on the real storage road instead of
    /// citing it, computes what the literal predicate would have done, and
    /// shows the carve-out (evaluate only on pure removals) suppressing it.
    /// If iOS ever stops widening, `theReportIsWiderThanTheCharactersThat
    /// Moved` goes red here and the carve-out can be reconsidered on
    /// evidence — which is the point of pinning it rather than arguing it.
    @Test func theSpecifiedPredicateWouldFireOnEveryOrdinaryKeystroke() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                let world = try await editRoutingFixture(session)
                // One ordinary keystroke, policed road, inside block 1.
                #expect(typeEdit(
                    world.model, world.storage,
                    range: NSRange(location: 8, length: 0), replacement: "!"))
                #expect(world.model.index.entries.map(\.length) == [5, 10, 5])
            }

            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(report.value == 1, "delta is exact — widening never touches it")
            #expect(report.location == 8, "…nor the location")
            #expect(report.length > 1,
                    "the reported range IS wider than the one character that moved")

            // What the literal predicate would have computed, by hand:
            let literalOldSpanUpperBound = report.location + (report.length - report.value)
            let consultUpperBound = 8 // the consult was (8, 0)
            #expect(literalOldSpanUpperBound > consultUpperBound,
                    "the predicate as specified fires on this ordinary keystroke")

            // …and what the shipped instrument actually reports.
            #expect(!report.flags.contains(.overrun))
            #expect(report.flags.contains(.overrunNotTestable))
            #expect(MobileEditTrace.summary.overrunTestable == 0)
            #expect(MobileEditTrace.summary.mismatches == 0,
                    "an ordinary keystroke is not a finding")
        }
    }

    // MARK: - Pairing (the headline test: gate calls > reports)

    @Test func severalGateConsultsBeforeOneReportAreRecordedAsSuch() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await editRoutingFixture(session)
                    // Three consults, then ONE coordinated transaction —
                    // M1's shape, driven at the storage contract.
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 0, length: 1), replacement: "A"))
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 1, length: 1), replacement: "B"))
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 2, length: 0), replacement: "C"))
                    world.storage.beginEditing()
                    world.storage.replaceCharacters(
                        in: NSRange(location: 2, length: 0), with: "C")
                    world.storage.endEditing()
                    await Task.yield()
                }
            }

            let s = MobileEditTrace.summary
            #expect(s.consults >= 3)
            #expect(s.maxConsultsBeforeAReport >= 3,
                    "M1's fingerprint on its own: more gate calls than edits")
            let consults = MobileEditTrace.events.filter { $0.kind == .consult }
            #expect(consults.contains { $0.flags.contains(.armed) },
                    "an armed consult is marked as such")
        }
    }

    // MARK: - Gate-less (autocorrect / dictation / marked text)

    @Test func aGateLessEditIsCountedButNeverScoredAsAMismatch() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await editRoutingFixture(session)
                    // The system-path shape: storage moves with no consult.
                    // A DELETION deliberately — its report is exact, so this
                    // pin measures the gate-less accounting and nothing else
                    // (a gate-less INSERTION's report is widened by iOS — M12;
                    // since VM-24 it routes from the changed characters, and
                    // the widened/rescued pins below measure that road).
                    systemPathEdit(
                        world.storage, range: NSRange(location: 8, length: 1),
                        replacement: "")
                    await Task.yield()
                    #expect(world.model.desyncRecoveryCount == 0)
                }
            }

            let s = MobileEditTrace.summary
            #expect(s.gatelessReports == 1)
            #expect(s.mismatches == 0,
                    "a report with no consult has nothing to disagree with, so ordinary autocorrect never reads as a finding")
            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(report.flags.contains(.gateless))
            #expect(report.flags.isDisjoint(with: MobileEditTrace.Flags.mismatch))
        }
    }

    // MARK: - Zero behaviour change

    @Test func armingTheTraceChangesNothingTheEditorDoes() async throws {
        func run() async throws -> (recoveries: Int, length: Int, entries: [Int]) {
            var out = (recoveries: 0, length: 0, entries: [Int]())
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await editRoutingFixture(session)
                    #expect(world.model.shouldChangeText(
                        in: NSRange(location: 16, length: 5), replacement: ""))
                    coalescedDelete(world.storage, NSRange(location: 12, length: 15))
                    await settleEditor(until: {
                        world.model.index.documentLength == world.storage.length
                    })
                    out = (
                        world.model.desyncRecoveryCount,
                        world.model.index.documentLength,
                        world.model.index.entries.map(\.length))
                }
            }
            return out
        }

        let disarmed = try await withTraceDisarmed { try await run() }
        let armed = try await withTraceArmed { try await run() }

        #expect(armed.recoveries == disarmed.recoveries)
        #expect(armed.length == disarmed.length)
        #expect(armed.entries == disarmed.entries)
    }

    // MARK: - VM-24: widened · rescued · no capture (the "after" session's count)

    /// A two-block note on the bare storage seam, loaded — the place where a
    /// font-only insert at block 0's end is widened through the separator
    /// (the iOS fixing finding, TEXTKIT2 §3: the new run carries no paragraph
    /// style, so fixing writes the paragraph's over it through the
    /// terminator).
    private func twoBlockNote(
        _ session: AppSession
    ) async throws -> (model: MobileEditorViewModel, storage: NSTextStorage) {
        let postID = try await makePost(session, blocks: ["Alpha beta.", "Gamma delta."])
        let (model, storage) = makeEditor(session, postID: postID)
        await model.loadOnce()
        return (model, storage)
    }

    /// **VM-24, D-24-4 — the road the fix exists for, counted and drawn.** A
    /// gate-less insert at block 0's end: its report runs past the one
    /// character that changed (WIDENED), and alone it would have refused while
    /// the changed characters route it (RESCUED — one snap-back that did not
    /// happen). Both are counted, marked on the event and drawn in the
    /// readout; the first callback kept the characters, so no capture is
    /// missing.
    @Test func aWidenedUnarmedReportIsMarkedAndItsRescueCounted() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                try await withEditorAssertionsMuted {
                    let world = try await twoBlockNote(session)
                    systemPathEdit(
                        world.storage, range: NSRange(location: 11, length: 0), replacement: "X")
                    #expect(world.model.desyncRecoveryCount == 0, "routed from the changed characters")
                    #expect(world.model.index.entries.map(\.length) == [12, 12])
                }
            }

            let s = MobileEditTrace.summary
            #expect(s.reports == 1)
            #expect(s.widenedReports == 1, "the report ran past the one character that changed")
            #expect(s.rescuedReports == 1,
                    "alone it would have refused, and the changed characters routed it")
            #expect(s.reportsWithoutCapture == 0, "the first callback kept the changed characters")
            #expect(s.desyncRecoveries == 0)

            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(report.flags.contains(.gateless))
            #expect(report.flags.contains(.widened))
            #expect(report.flags.contains(.rescued))
            #expect(!report.flags.contains(.noCapture))
            #expect(report.flags.isDisjoint(with: MobileEditTrace.Flags.mismatch),
                    "a rescue is not a suspect signature")
            #expect(report.changedLocation == 11)
            #expect(report.changedLength == 1)
            #expect(report.length > report.changedLength, "measured, not inferred")

            let line = MobileEditTrace.line(for: report)
            #expect(line.contains("widened — changed at 11 len 1"))
            #expect(line.contains("rescued"))
            let headline = MobileEditTrace.headline()
            #expect(headline.contains("  widened           1"))
            #expect(headline.contains("  rescued           1"))
            #expect(headline.contains("  no capture        0"))
        }
    }

    /// A BOUND report is widened just the same — and never rescued: its
    /// arming routed it, and no second verdict is asked for it.
    @Test func aBoundWidenedReportIsWidenedButNeverRescued() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                let world = try await twoBlockNote(session)
                #expect(typeEdit(
                    world.model, world.storage,
                    range: NSRange(location: 11, length: 0), replacement: "X"))
                #expect(world.model.desyncRecoveryCount == 0)
            }

            let s = MobileEditTrace.summary
            #expect(s.widenedReports == 1)
            #expect(s.rescuedReports == 0, "an armed edit is routed by its arming")
            #expect(s.gatelessReports == 0)
        }
    }

    /// **The disarmed trace does no extra work, and the armed one asks the
    /// second verdict only where it can mean something** (D-24-4): disarmed,
    /// never; armed, only for an UNBOUND report that was WIDENED — not for a
    /// bound one, an exact one, or one with no changed characters.
    @Test func theRescueVerdictIsAskedOnlyArmedAndOnlyForAnUnboundWidenedReport() async throws {
        var asked = 0
        let reported = NSRange(location: 11, length: 2)
        let oneCharacter = NSRange(location: 11, length: 1)
        func report(bound: Bool, changed: NSRange?) {
            MobileEditTrace.report(
                editedRange: reported, delta: 1, hadArming: bound, bound: bound,
                changedCharacters: changed,
                rescued: {
                    asked += 1
                    return true
                })
        }

        await withTraceDisarmed {
            report(bound: false, changed: oneCharacter)
            #expect(MobileEditTrace.summary == MobileEditTrace.Summary(), "disarmed: nothing recorded")
        }
        #expect(asked == 0, "disarmed: nothing computed")

        await withTraceArmed {
            report(bound: true, changed: oneCharacter)    // widened, but bound
            report(bound: false, changed: reported)       // unbound, not widened
            report(bound: false, changed: nil)            // unbound, nothing kept
            #expect(asked == 0, "the second verdict is never asked where it cannot mean a rescue")
            report(bound: false, changed: oneCharacter)   // unbound and widened
            #expect(asked == 1)

            let s = MobileEditTrace.summary
            #expect(s.reports == 4)
            #expect(s.widenedReports == 2)
            #expect(s.rescuedReports == 1)
            #expect(s.reportsWithoutCapture == 1)
        }
    }

    /// **No capture, counted** — a storage edit whose report arrived with no
    /// changed characters kept (here: the observer's second callback with no
    /// first one, driven by hand around an exact deletion). It routes from the
    /// report as before, and the readout says so.
    @Test func aReportWithNoKeptValueIsCountedAndMarked() async throws {
        try await withTraceArmed {
            try await withEditorWorld { session, _ in
                let world = try await twoBlockNote(session)
                let observer = try #require(world.storage.delegate as? MobileStorageObserver)
                world.storage.delegate = nil
                world.storage.replaceCharacters(in: NSRange(location: 8, length: 1), with: "")
                world.storage.delegate = observer
                observer.textStorage(
                    world.storage, didProcessEditing: .editedCharacters,
                    range: NSRange(location: 8, length: 0), changeInLength: -1)
                #expect(world.model.desyncRecoveryCount == 0, "an exact report routes as before")
                #expect(world.model.index.entries.map(\.length) == [10, 12])
            }

            let s = MobileEditTrace.summary
            #expect(s.reportsWithoutCapture == 1)
            #expect(s.widenedReports == 0, "with nothing kept, widening is not measured")
            let report = try #require(
                MobileEditTrace.events.last(where: { $0.kind == .report }))
            #expect(report.flags.contains(.noCapture))
            #expect(report.changedLocation == -1)
            #expect(MobileEditTrace.line(for: report).contains("no capture"))
            #expect(MobileEditTrace.headline().contains("  no capture        1"))
        }
    }

    /// Zero behaviour change on the rescued road too: the widened gate-less
    /// insert, run armed and disarmed, lands identically.
    @Test func armingTheTraceChangesNothingOnTheRescuedRoad() async throws {
        func run() async throws -> (recoveries: Int, entries: [Int], stored: [String]) {
            var out = (recoveries: 0, entries: [Int](), stored: [String]())
            try await withEditorWorld { session, db in
                try await withEditorAssertionsMuted {
                    let postID = try await makePost(session, blocks: ["Alpha beta.", "Gamma delta."])
                    let (model, storage) = makeEditor(session, postID: postID)
                    await model.loadOnce()
                    systemPathEdit(storage, range: NSRange(location: 11, length: 0), replacement: "X")
                    await model.autosave.flushNow()
                    out = (
                        model.desyncRecoveryCount,
                        model.index.entries.map(\.length),
                        try await storedBlockTexts(db, postID: postID))
                }
            }
            return out
        }

        let disarmed = try await withTraceDisarmed { try await run() }
        let armed = try await withTraceArmed { try await run() }

        #expect(armed.recoveries == disarmed.recoveries)
        #expect(armed.entries == disarmed.entries)
        #expect(armed.stored == disarmed.stored)
        #expect(armed.stored == ["Alpha beta.X", "Gamma delta."], "and both routed it")
    }

    // MARK: - Bounded memory (MobileSoul §2)

    @Test func theRingIsBoundedWhileTheCountersStayTrue() async throws {
        try await withTraceArmed {
            let overshoot = MobileEditTrace.ringCapacity + 47
            for i in 0..<overshoot {
                MobileEditTrace.gate(
                    range: NSRange(location: i, length: 0), replacementLength: 1)
            }
            #expect(MobileEditTrace.events.count == MobileEditTrace.ringCapacity,
                    "the ring never grows past its capacity")
            #expect(MobileEditTrace.summary.consults == overshoot,
                    "…while the counters survive the wrap")
            #expect(MobileEditTrace.summary.eventsDropped == 47)
            // Oldest-first order survives the wrap, so the readout's
            // newest-first list is really newest-first.
            let seqs = MobileEditTrace.events.map(\.seq)
            #expect(seqs == Array(seqs.sorted()))
            #expect(seqs.last == overshoot)
        }
    }
}
