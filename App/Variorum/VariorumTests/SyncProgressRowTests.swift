//
//  SyncProgressRowTests.swift
//  VariorumTests — VX-496 (VX-500 U2, P-500-1): the sync row's PROGRESS LINE. The engine reports a long catch-up's
//  numbers (`SyncProgress`, U1a's seam — published only once a round needed a second window or resumed a stage);
//  the row's words are the app's, said in ONE place (`SyncStatusRow.line(for:lastSuccessAt:progress:)` — the VX-510
//  D-A2 presentation source) with the count part spelled once for every surface (`SyncStatusRow.progressCount`,
//  which the first-round sheet says beneath its own sentence — P-500-2). Her example leads:
//  "Syncing — 40,000 of 108,000". Words PROVISIONAL, hers (P-500-1; the `done > total` render P-500-8).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-496 — the sync row's progress line (P-500-1)")
struct SyncProgressRowTests {
    /// Her example, byte for byte under her locale's grouping: a downloading progress with the server's total.
    /// (`formatted()` writes the user's locale grouping — the expectation is built by the same formatter, plus one
    /// literal pin of the whole line under the en-US grouping shape when the runner's locale writes it that way.)
    @Test func aDownloadingProgressWithATotalSaysNofM() {
        let line = SyncStatusRow.line(
            for: .syncing, lastSuccessAt: nil,
            progress: SyncProgress(phase: .downloading, done: 40_000, total: 108_000))
        #expect(line == "Syncing \u{2014} \(40_000.formatted()) of \(108_000.formatted())")
        if 40_000.formatted() == "40,000" {
            #expect(line == "Syncing — 40,000 of 108,000", "her example, byte for byte")
        }
    }

    /// No count surface (a wrapper without it, a refusal, the RPC not yet deployed): rows so far, honestly unbounded.
    @Test func aDownloadingProgressWithoutATotalSaysSoFar() {
        let line = SyncStatusRow.line(
            for: .syncing, lastSuccessAt: nil,
            progress: SyncProgress(phase: .downloading, done: 40_000, total: nil))
        #expect(line == "Syncing \u{2014} \(40_000.formatted()) so far")
    }

    /// The save phase: its total is the staged batch's count (always known from the engine).
    @Test func aSavingProgressSaysSavingNofM() {
        let line = SyncStatusRow.line(
            for: .syncing, lastSuccessAt: nil,
            progress: SyncProgress(phase: .saving, done: 12_000, total: 108_000))
        #expect(line == "Syncing \u{2014} saving \(12_000.formatted()) of \(108_000.formatted())")
    }

    /// NO progress — every ordinary round — keeps "Syncing…" BYTE-UNCHANGED (the standing pins' line; the engine never
    /// arms a progress on a one-window round).
    @Test func noProgressKeepsSyncingByteUnchanged() {
        #expect(SyncStatusRow.line(for: .syncing, lastSuccessAt: nil) == "Syncing\u{2026}")
        #expect(SyncStatusRow.line(for: .syncing, lastSuccessAt: nil, progress: nil) == "Syncing\u{2026}")
    }

    /// **P-500-8 (PROVISIONAL)** — `done > total` (the feed grew during a long download; `SyncProgress.total` names the
    /// bound): the shown denominator RISES to `done`, so the line never claims a total smaller than what is already
    /// done. (The recorded alternative: show "40,200 of 40,000" honestly.) The save's stall direction — `done` ending
    /// below its total — reads as-is.
    @Test func doneAboveTheTotalRaisesTheShownDenominator() {
        let grown = SyncStatusRow.progressCount(SyncProgress(phase: .downloading, done: 108_200, total: 108_000))
        #expect(grown == "\(108_200.formatted()) of \(108_200.formatted())")
        let stalled = SyncStatusRow.progressCount(SyncProgress(phase: .saving, done: 2_000, total: 108_000))
        #expect(stalled == "saving \(2_000.formatted()) of \(108_000.formatted())")
    }

    /// The one spelling: the row's line IS "Syncing — " + `progressCount` for every progress shape (the count part is
    /// what the first-round sheet says beneath its sentence — P-500-2; never a second spelling).
    @Test func theLineIsTheOneCountSpellingAfterItsDash() {
        for progress in [
            SyncProgress(phase: .downloading, done: 1, total: 2),
            SyncProgress(phase: .downloading, done: 3, total: nil),
            SyncProgress(phase: .saving, done: 4, total: 5),
            SyncProgress(phase: .saving, done: 6, total: nil),
        ] {
            #expect(SyncStatusRow.line(for: .syncing, lastSuccessAt: nil, progress: progress)
                == "Syncing \u{2014} " + SyncStatusRow.progressCount(progress))
        }
        #expect(SyncStatusRow.progressCount(SyncProgress(phase: .saving, done: 6, total: nil))
            == "saving \(6.formatted()) so far", "a nil-total save falls back to the so-far shape, never a minted denominator")
    }

    /// CF-15 (pin): the `.syncing` face keeps its doors with a progress standing — "Sync now" present and disabled,
    /// "Account…" in place. The face is progress-blind by construction (the numbers ride the line, never the doors).
    @Test func theSyncingFaceKeepsItsDoorsWithAProgressStanding() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: true,
            lastError: nil, lastErrorIsOffline: false)
        #expect(face.kind == .syncing)
        #expect(face.doors == [
            SyncRowFace.Door(label: "Sync now", act: .syncNow, enabled: false),
            SyncRowFace.Door(label: "Account\u{2026}", act: .openAccount(.account)),
        ])
    }

    /// The parameter is `.syncing`'s alone: every other kind's line is byte-identical with a progress passed (the
    /// standing pins' lines cannot drift under the new parameter).
    @Test func everyOtherKindsLineIgnoresAProgress() {
        let progress = SyncProgress(phase: .downloading, done: 7, total: 9)
        let kinds: [SyncRowFace.Kind] = [
            .devStore, .signedOut, .syncOff, .offline, .keysLocked, .notOnYet, .keysReplaced,
            .accountMismatch, .notEntitled, .stalled, .appOutOfDate, .error, .idle,
        ]
        for kind in kinds {
            #expect(SyncStatusRow.line(for: kind, lastSuccessAt: nil, progress: progress)
                == SyncStatusRow.line(for: kind, lastSuccessAt: nil), "\(kind)")
        }
    }
}

@MainActor
@Suite("VX-496 — the first-round sheet's count beneath its sentence (P-500-2)")
struct FirstRoundSheetCountTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []

    static func syncing(_ progress: SyncProgress?) -> SyncScheduler.Status {
        var status = SyncScheduler.Status()
        status.isSyncing = true
        status.roundsCompleted = 1
        status.progress = progress
        return status
    }

    /// The count stands exactly under the STILL-SYNCING outcome carrying a progress (F-R1-1's frozen face): the sheet's
    /// sentence keeps `firstRoundProgress` BYTE-UNCHANGED (the F-R2-2 close-note equality holds) and the count beneath
    /// it is the row's own spelling — one source, never a second one.
    @Test func aStillSyncingOutcomeWithAProgressGainsTheCountBeneathTheSentence() {
        let progress = SyncProgress(phase: .downloading, done: 40_000, total: 108_000)
        let outcome = FirstRoundOutcome.ran(Self.syncing(progress))
        #expect(RoadAccountConfirmModel.firstRoundLine(outcome, joins: false) == ProtectionWords.firstRoundProgress,
                "the sentence is byte-unchanged — the count is a line beneath, never a reworded sentence")
        #expect(RoadAccountConfirmModel.firstRoundCount(outcome) == SyncStatusRow.progressCount(progress))
        #expect(RoadAccountConfirmModel.firstRoundCount(outcome)
            == "\(40_000.formatted()) of \(108_000.formatted())")
    }

    /// No count anywhere else: a progress-less still-syncing outcome (the sentence alone, exactly as shipped), a clean
    /// round, a blocked round (even were a stale progress left on its status), held and not configured.
    @Test func everyOtherOutcomeSaysNoCount() {
        #expect(RoadAccountConfirmModel.firstRoundCount(.ran(Self.syncing(nil))) == nil)
        var clean = SyncScheduler.Status()
        clean.lastSuccessAt = Date(timeIntervalSince1970: 1_782_864_000)
        #expect(RoadAccountConfirmModel.firstRoundCount(.ran(clean)) == nil)
        var blocked = SyncScheduler.Status()
        blocked.lastError = String(describing: SyncError.encryptionKeysUnavailable)
        blocked.progress = SyncProgress(phase: .downloading, done: 7, total: 9)
        #expect(RoadAccountConfirmModel.firstRoundCount(.ran(blocked)) == nil,
                "a blocked face never wears a count — the sentence names what blocks")
        #expect(RoadAccountConfirmModel.firstRoundCount(.held) == nil)
        #expect(RoadAccountConfirmModel.firstRoundCount(.notConfigured) == nil)
    }

    /// Through the confirm model (the road the sheet reads): a landed act whose round froze still syncing with a
    /// progress shows the sentence (`roundLine`) and the count (`roundCountLine`); a clean round shows the success line
    /// and no count.
    @Test func theConfirmModelCarriesTheCountBesideItsLine() async throws {
        let progress = SyncProgress(phase: .saving, done: 12_000, total: 108_000)
        let frozen = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .made(receipt: nil) },
            firstRound: { .ran(Self.syncing(progress)) }, finished: { _ in })
        await frozen.submit(
            passphrase: "a new passphrase", again: "a new passphrase", words: Self.words.joined(separator: " "))
        _ = await frozen.awaitFirstRound()
        #expect(frozen.roundLine == ProtectionWords.firstRoundProgress)
        #expect(frozen.roundCountLine == "saving \(12_000.formatted()) of \(108_000.formatted())")

        var clean = SyncScheduler.Status()
        clean.lastSuccessAt = Date(timeIntervalSince1970: 1_782_864_000)
        let landed = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .made(receipt: nil) },
            firstRound: { .ran(clean) }, finished: { _ in })
        await landed.submit(
            passphrase: "a new passphrase", again: "a new passphrase", words: Self.words.joined(separator: " "))
        _ = await landed.awaitFirstRound()
        #expect(landed.roundCountLine == nil)
    }
}
