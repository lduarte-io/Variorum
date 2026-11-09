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
    ///
    /// VX-909 (the VX-914 run, batch 4 — A JUSTIFIED EDIT; S-909 (1), RULED
    /// PROVISIONAL): the detail no longer restates the update fact, so its
    /// "older than your account's sync format" clause is gone by design — the
    /// WHY is said as "a newer format than this version reads", and the
    /// reassurance survives as its own sentence. The exact pair is pinned in
    /// `theUpdateFactIsSaidOnceTheTitleKeepsItTheBodyExplains` below.
    @Test func theWordsAreCalmAndTheDoorIsTheMenusOwn() {
        #expect(SyncRowFace.checkForUpdatesLabel == UpdateChannel.checkForUpdatesTitle)
        #expect(SyncRowFace.appOutOfDateDetail.contains("a newer format than this version reads"))
        #expect(SyncRowFace.appOutOfDateDetail.contains("Nothing is lost while sync is paused."))
        #expect(!SyncRowFace.appOutOfDateLabel.contains("error"))
    }

    /// **VX-909 — her find (Nov 8, a 1.2 build before its update): the title
    /// and the sentence under it said the update fact twice.** ONE line keeps
    /// the fact — the TITLE, because the account act's first-round sheet says
    /// the title alone — and the body earns its place with the why and the
    /// reassurance. One pair in `Shared/`, so the Mac's sidebar row and the
    /// phone's Settings ▸ Sync row say the same words (both arms render the
    /// body), and the sheet's composed sentence carries the fact on both
    /// platforms. RED ON OLD: the old pair said "update" in both lines.
    @Test func theUpdateFactIsSaidOnceTheTitleKeepsItTheBodyExplains() throws {
        #expect(SyncRowFace.appOutOfDateLabel == "Sync paused \u{2014} Variorum needs an update")
        #expect(SyncRowFace.appOutOfDateDetail
            == "Your account syncs in a newer format than this version reads. "
            + "Nothing is lost while sync is paused.")
        // One fact, one line: the title says the update, the body never does.
        #expect(SyncRowFace.appOutOfDateLabel.localizedCaseInsensitiveContains("update"))
        #expect(!SyncRowFace.appOutOfDateDetail.localizedCaseInsensitiveContains("update"),
                "the body explains — it does not tell the fact again")
        #expect(SyncStatusRow.line(for: .appOutOfDate, lastSuccessAt: nil) == SyncRowFace.appOutOfDateLabel,
                "the row's one presentation source")
        // The first-round sheet (Mac and phone) says the title alone, so the fact rides it.
        #expect(ProtectionWords.firstRoundBlocked(SyncStatusRow.line(for: .appOutOfDate, lastSuccessAt: nil))
            == "Sync hasn't run yet: Sync paused \u{2014} Variorum needs an update.")
        // Both arms of the row — the Mac's (nil style) and the phone's (styled) —
        // render the body under the title.
        let views = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Shared/SyncStatusViews.swift"),
            encoding: .utf8)
        let rendered = views.components(separatedBy: "if face.kind == .appOutOfDate {\n").dropFirst()
        #expect(rendered.count == 2, "both arms draw the out-of-date body")
        for arm in rendered {
            #expect(arm.prefix(120).contains("Text(SyncRowFace.appOutOfDateDetail)"))
        }
    }

    /// The Mac's injection: an inert channel (every Debug build) hands out
    /// no door, so the row renders none (P-2).
    @Test func anInertChannelHandsTheRowNoDoor() {
        #expect(UpdateChannel(live: false).syncRowDoor == nil)
    }
}
