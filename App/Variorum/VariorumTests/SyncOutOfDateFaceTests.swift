//
//  SyncOutOfDateFaceTests.swift
//  VariorumTests
//
//  Phase 13r U3-A — R-13r-13 (her refinement at the U3 kickoff, verbatim:
//  *"if sync doesn't work because your version is out of date, a calm
//  message should say so as well."*). The engine's §12 lockstep refusal is
//  classified FACE-SIDE (`SyncRowFace.isAppBehindServerError`, the
//  `isKeysLockedError` pattern — zero `Sync/` lines): when the SERVER's
//  marker is ahead, the row is the calm out-of-date face, and its one door
//  is Check for Updates… — rendered ONLY where an updater can act (P-2).
//  The app-ahead direction keeps the generic face (no friend can reach it:
//  the §12 choreography deploys the mirror before any release ships).
//
//  The error strings are the ENGINE's own renderings (`String(describing:)`
//  of `SyncError` — exactly what `SyncScheduler` writes into `lastError`),
//  never re-typed sentences.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The out-of-date sync face (13r U3-A — R-13r-13)")
@MainActor
struct SyncOutOfDateFaceTests {
    private static func mismatch(client: Int, server: Int) -> String {
        String(describing: SyncError.schemaLockstepMismatch(client: client, server: server))
    }

    private static func face(_ error: String, updater: Bool) -> SyncRowFace {
        SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: error, lastErrorIsOffline: false, canCheckForUpdates: updater)
    }

    /// THE PIN: the server ahead → the calm face, and the update door.
    @Test func theServerAheadIsTheCalmFaceWithTheUpdateDoor() {
        let face = Self.face(Self.mismatch(client: 12, server: 13), updater: true)
        #expect(face.kind == .appOutOfDate)
        #expect(face.doors == [SyncRowFace.Door(label: "Check for Updates…", act: .checkForUpdates)])
    }

    /// P-2: no live updater (a Debug build, the phone) → the same calm face,
    /// and NO door — the sentence alone.
    @Test func withoutALiveUpdaterTheFaceSaysTheSentenceAndOffersNoDoor() {
        let face = Self.face(Self.mismatch(client: 12, server: 14), updater: false)
        #expect(face.kind == .appOutOfDate)
        #expect(face.doors.isEmpty)
    }

    /// The other direction keeps the generic face, doors and all.
    @Test func theAppAheadKeepsTheGenericFace() {
        let face = Self.face(Self.mismatch(client: 13, server: 12), updater: true)
        #expect(face.kind == .error)
        #expect(face.doors == [
            SyncRowFace.Door(label: "Retry", act: .syncNow),
            SyncRowFace.Door(label: "Account…", act: .openAccount(.account)),
        ])
    }

    /// The classifier is EXACT: the engine's rendering of the pair, whole —
    /// a prefix, a suffix, an equal pair or another refusal never reads as
    /// out of date.
    @Test func theClassifierMatchesExactlyTheEnginesRefusal() {
        let real = Self.mismatch(client: 12, server: 13)
        #expect(SyncRowFace.isAppBehindServerError(real))
        #expect(!SyncRowFace.isAppBehindServerError("Sync error: " + real))
        #expect(!SyncRowFace.isAppBehindServerError(real + " "))
        #expect(!SyncRowFace.isAppBehindServerError(Self.mismatch(client: 12, server: 12)))
        #expect(!SyncRowFace.isAppBehindServerError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!SyncRowFace.isAppBehindServerError("(app 1, server 2)"))
        // And the keys-locked classifier does not swallow it either way.
        #expect(!SyncRowFace.isKeysLockedError(real))
    }

    /// The words: calm and plain (her letter), and the door's label is the
    /// menu door's own (`Shared/` cannot see the Mac channel, so this holds
    /// the two equal).
    @Test func theWordsAreCalmAndTheDoorIsTheMenusOwn() {
        #expect(SyncRowFace.checkForUpdatesLabel == UpdateChannel.checkForUpdatesTitle)
        #expect(SyncRowFace.appOutOfDateDetail.contains("older than your account\u{2019}s sync format"))
        #expect(SyncRowFace.appOutOfDateDetail.contains("nothing is lost while sync is paused"))
        #expect(!SyncRowFace.appOutOfDateLabel.contains("error"))
    }

    /// The Mac's injection: an inert channel (every Debug build) hands out
    /// no door, so the row renders none (P-2).
    @Test func anInertChannelHandsTheRowNoDoor() {
        #expect(UpdateChannel(live: false).syncRowDoor == nil)
    }
}
