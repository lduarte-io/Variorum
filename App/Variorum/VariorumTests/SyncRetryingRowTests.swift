//
//  SyncRetryingRowTests.swift
//  VariorumTests — VX-505 (VX-500 U2, P-500-3): the one-writer belt's refusal used to reach the row as the GENERIC
//  error face, so for the seconds until its follow-up round healed it the row showed the engine's internal sentence
//  ("another sync round committed while this one was downloading (cursor … → …); …"). The scheduler now carries the
//  TYPED fact (`Status.lastErrorIsRetrying`, set via `PullStage.isOneWriterRefusal` — U1a's seam, pinned in core by
//  `ResumableCatchUpTests.theBeltsRefusalIsFlaggedRetryingUntilItsFollowUpHeals`), and the face classifies it AFTER
//  offline and BEFORE every other error class as `Kind.retrying`, rendered like `.syncing` (the small spinner, CF-15's
//  doors) with her line — sentence-cased from her draft "another change landed mid-sync — retrying." — and the engine's
//  sentence in the hover as every paused state's. P-500-7 is built as (a): on a REFUSED follow-up (two rounds racing
//  one store — not a production shape) the flag is false by the scheduler's design and the row keeps `.error`.
//

import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-505 — the belt's retrying face (P-500-3)")
struct SyncRetryingRowTests {
    /// The engine's own rendering of the belt's cursor refusal, as the scheduler writes it to `lastError`
    /// (`String(describing:)`). The face never matches this text — the fact is typed — so the pin hands it in only as
    /// what the hover carries.
    static let beltSentence =
        "another sync round committed while this one was downloading (cursor 2000 \u{2192} 4000); "
        + "the next round starts from the new cursor"

    static func face(
        error: String? = beltSentence, retrying: Bool = true, offline: Bool = false, isSyncing: Bool = false
    ) -> SyncRowFace {
        SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: isSyncing,
            lastError: error, lastErrorIsOffline: offline, lastErrorIsRetrying: retrying,
            canCheckForUpdates: true, canOpenProtection: true)
    }

    /// THE PRESENTED-STATE PIN (red on old: the belt's refusal classified as the generic `.error`, the internal
    /// sentence on the row): the typed flag presents as `.retrying` with her line and CF-15's doors — "Sync now"
    /// present and disabled, "Account…" in place — exactly the `.syncing` rendering.
    @Test func theBeltsRefusalPresentsAsRetryingWithTheSyncingDoors() {
        let face = Self.face()
        #expect(face.kind == .retrying)
        #expect(face.doors == [
            SyncRowFace.Door(label: "Sync now", act: .syncNow, enabled: false),
            SyncRowFace.Door(label: "Account\u{2026}", act: .openAccount(.account)),
        ])
        let line = SyncStatusRow.line(for: .retrying, lastSuccessAt: nil)
        #expect(line == SyncStatusRow.retryingLabel)
        #expect(line == "Another change landed mid-sync \u{2014} retrying",
                "sentence-cased from her draft; the row's period-less idiom (PROVISIONAL P-500-3)")
    }

    /// AFTER offline: a dead wire outranks the mid-answer face (the flag up with the offline class keeps `.offline`).
    /// And a running round keeps `.syncing` (isSyncing is read before any error class, unchanged).
    @Test func offlineAndSyncingOutrankRetrying() {
        #expect(Self.face(offline: true).kind == .offline)
        #expect(Self.face(isSyncing: true).kind == .syncing)
    }

    /// BEFORE every other error class: the typed fact outranks the text classifiers — even an error text that would
    /// classify as keys-locked, replaced, mismatch, out-of-date or not-entitled reads `.retrying` while the flag is up
    /// (the flag is set only for the belt's refusal, so these pairs are synthetic; the pin holds the ORDER).
    @Test func theTypedFlagOutranksEveryTextClassifier() {
        for text in [
            String(describing: SyncError.encryptionKeysUnavailable),
            String(describing: SyncError.encryptionKeysReplaced),
            String(describing: SyncError.keyProofRefused),
            String(describing: SyncError.accountMismatch(bound: "a", signedIn: "b")),
            String(describing: SyncError.schemaLockstepMismatch(client: 12, server: 13)),
        ] {
            #expect(Self.face(error: text).kind == .retrying, Comment(rawValue: text))
        }
    }

    /// AN ORDINARY ERROR KEEPS `.error` (pin): the flag down, the generic face and its doors are byte-unchanged —
    /// which is also P-500-7 (a): the refused follow-up corner (the flag false by the scheduler's design) still shows
    /// the error face until the next trigger, deliberately unbuilt further.
    @Test func anOrdinaryErrorKeepsTheErrorFace() {
        let face = Self.face(error: "HTTP 500 \u{2014} the server refused", retrying: false)
        #expect(face.kind == .error)
        #expect(face.doors == [
            SyncRowFace.Door(label: "Retry", act: .syncNow),
            SyncRowFace.Door(label: "Account\u{2026}", act: .openAccount(.account)),
        ])
        let belt = Self.face(retrying: false)
        #expect(belt.kind == .error, "P-500-7 (a): the refused follow-up's double-refusal corner keeps the error face")
    }

    /// The first-round sheet speaks the same classification (one presentation source): a retrying outcome reads
    /// "Sync hasn't run yet: ‹her line›." — never the engine's internal sentence, never a reworded second spelling.
    @Test func theFirstRoundSheetSaysTheRetryingLine() {
        var status = SyncScheduler.Status()
        status.lastError = Self.beltSentence
        status.lastErrorIsRetrying = true
        status.roundsCompleted = 1
        let line = RoadAccountConfirmModel.firstRoundLine(.ran(status), joins: false)
        #expect(line == "Sync hasn't run yet: Another change landed mid-sync \u{2014} retrying.")
        #expect(RoadAccountConfirmModel.rowFace(status).kind == .retrying)
    }
}
