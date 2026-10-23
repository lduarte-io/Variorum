//
//  SyncLockedRowTests.swift
//  VariorumTests
//
//  VX-486 (her live finding at the 0.10 window — "it says sync locked, enter passphrase, but there's no easy button or
//  way to do so that's obvious"): the locked-sync row's line spoke the deleted road's vocabulary ("enter your encryption
//  passphrase") and its one door opened the Account sheet (sign in/out), which has nowhere to take a passphrase
//  (P-VX329-U1-4's provisional seam). The row now names its state in the road's words, and its door lands in
//  Settings ▸ Protection through the one programmatic open-at-pane road (`ProtectionController.settingsRequest`), where
//  the road's doors live — rendered only where that pane exists (P-2: the phone, and every composition that injects no
//  door, says the sentence alone).
//
//  The error strings are the ENGINE's own renderings (`String(describing:)` of `SyncError` — exactly what
//  `SyncScheduler` writes into `lastError`), never re-typed sentences.
//

import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The locked-sync row (VX-486)")
struct SyncLockedRowTests {
    private static let locked = String(describing: SyncError.encryptionKeysUnavailable)

    /// THE PRESENTED-STATE PIN (red on old: "Sync locked — enter your encryption passphrase"). The line names its state
    /// in the road's own words — never the deleted Encryption tab's ask for a passphrase the row cannot take.
    /// PROVISIONAL words, hers (the run record's OPEN ITEMS).
    @Test func theLockedLineSpeaksTheRoadsWordsNeverThePassphrase() {
        #expect(SyncStatusRow.lockedLabel == "Sync locked — this Mac hasn't unlocked your account's sync keys")
        #expect(!SyncStatusRow.lockedLabel.contains("passphrase"), "the row cannot take one")
        #expect(!SyncStatusRow.lockedLabel.contains("encryption"), "the old road's word")
        #expect(SyncStatusRow.lockedLabel.hasPrefix("Sync locked"), "the state's name stays")
    }

    /// THE DOOR'S OTHER HALF (red on old: the one door was `Account…` → the Account sheet). Whatever composition renders
    /// the locked row, it never offers the Account sheet as the locked state's fix.
    @Test func theLockedRowNeverOffersTheAccountSheet() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: Self.locked, lastErrorIsOffline: false)
        #expect(face.kind == .keysLocked)
        #expect(!face.doors.contains { $0.act == .openAccount(.account) },
                "the Account sheet has nowhere to take what the locked state needs")
        #expect(!face.doors.contains { $0.label == "Account…" })
    }
}
