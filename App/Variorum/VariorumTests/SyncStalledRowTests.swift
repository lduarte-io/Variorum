//
//  SyncStalledRowTests.swift
//  VariorumTests
//
//  RUN B B2 row 12 (17d P31) — the FACE half of the stall's production
//  reader: a permanently stalled pull cursor used to render "Synced <time>"
//  forever (the idle row), a green light under a one-way inbound jam. The
//  scheduler half (`Status.pullStalled` / `Status.pushDeferredCount`, read
//  from the rounds' own reports — the `BridgeScheduler.status.stalled`
//  precedent) is pinned in core (`SyncSchedulerTests`); these pins hold the
//  row's presentation to the same honesty.
//

import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The stalled-pull row (RUN B B2 row 12 — 17d P31)")
struct SyncStalledRowTests {
    /// A CLEAN round with a held pull cursor presents as the dedicated
    /// `.stalled` state — warning-toned, honest — with LITERALLY the idle
    /// row's doors ("Sync now" retries, which is also how a transient
    /// straggler's heal is felt; no new chrome vocabulary — P-8).
    @Test func aStalledCleanRoundStopsPresentingAsSyncedFine() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: nil, lastErrorIsOffline: false,
            stalled: true)
        #expect(face.kind == .stalled,
                "a held cursor is not 'Synced <time>' — the row says so")
        let idle = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: nil, lastErrorIsOffline: false)
        #expect(idle.kind == .idle, "unstalled stays the idle row byte-unchanged")
        #expect(face.doors == idle.doors,
                "the stalled row offers exactly the idle row's doors")
        #expect(SyncStatusRow.stalledLabel
                == "Sync incomplete — some changes haven't arrived yet")
    }

    /// The stall decorates ONLY the clean branch: a syncing row is
    /// mid-answer, and an error face already says something is wrong —
    /// their presentations are byte-unchanged with the flag up.
    @Test func theStallNeverOutranksSyncingOrAnErrorFace() {
        let syncing = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: true, lastError: nil, lastErrorIsOffline: false,
            stalled: true)
        #expect(syncing.kind == .syncing)

        let offline = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: "offline", lastErrorIsOffline: true,
            stalled: true)
        #expect(offline.kind == .offline)

        let error = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: "boom", lastErrorIsOffline: false,
            stalled: true)
        #expect(error.kind == .error)
    }
}
