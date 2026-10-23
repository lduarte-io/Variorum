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

    /// THE DOOR-ACT PIN: where a Protection pane door was injected (the Mac's main window), the locked row's ONE door is
    /// `Protection…` and its act is the pane request — never `.openAccount`. (Its door label is PROVISIONAL, hers.)
    @Test func theLockedRowsOneDoorIsTheProtectionPane() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: Self.locked, lastErrorIsOffline: false, canOpenProtection: true)
        #expect(face.kind == .keysLocked)
        #expect(face.doors == [SyncRowFace.Door(label: "Protection…", act: .openProtection)])
        #expect(SyncRowFace.openProtectionLabel == ProtectionCopy.protectionPaneTitle + "…",
                "the pane's own name, in the row's Account… idiom")
    }

    /// P-2: with no Protection pane to land in (the phone — its Protection screen is VM-8's — and every composition that
    /// injects no door), the locked row says its sentence alone, exactly as the out-of-date face without an updater.
    @Test func withNoProtectionPaneTheLockedRowSaysTheSentenceAlone() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: Self.locked, lastErrorIsOffline: false, canOpenProtection: false)
        #expect(face.kind == .keysLocked)
        #expect(face.doors.isEmpty)
    }

    /// The injected door's act IS the Protection pane ask: one fresh request on the bootstrap's one controller, which the
    /// Settings window adopts (`AppSettingsView.adopts` — `request > adopted`; on appear for a fresh window, on change for
    /// one already up). The crossings' own ask is unchanged — the same counter, through the same neutral entry.
    @Test func theProtectionDoorAsksForTheProtectionPane() {
        let protection = ProtectionController()
        let door = ProtectionPaneDoor.settings(protection)
        let before = protection.settingsRequest
        door.request()
        #expect(protection.settingsRequest == before + 1, "one fresh ask per press")
        #expect(protection.settingsRequest > protection.settingsRequestAdopted, "the Settings window adopts it")
        protection.settingsRequestAdopted = protection.settingsRequest
        door.request()
        #expect(protection.settingsRequest > protection.settingsRequestAdopted, "every press is a fresh ask")
        let crossingBefore = protection.settingsRequest
        protection.requestProtectionPaneForRoadCrossing()
        #expect(protection.settingsRequest == crossingBefore + 1, "the crossing's ask, unchanged")
    }

    /// Only the LOCKED state wears the Protection door; the replaced-keys and account-mismatch rows keep their own
    /// `Account…` (not this fix's), and no other face mints it — across every state the face family reaches.
    @Test func onlyTheLockedFaceMintsTheProtectionDoor() {
        let errors: [String?] = [
            nil, "Sync error: something else", Self.locked,
            String(describing: SyncError.encryptionKeysReplaced),
            String(describing: SyncError.keyProofRefused),
            String(describing: SyncError.accountMismatch(bound: "a", signedIn: "b")),
            String(describing: SyncError.schemaLockstepMismatch(client: 12, server: 13)),
        ]
        for isSyncing in [false, true] {
            for error in errors {
                for offline in [false, true] {
                    let face = SyncRowFace.face(
                        allowsSync: true, isConfigured: true, signedIn: true, isSyncing: isSyncing,
                        lastError: error, lastErrorIsOffline: offline, canOpenProtection: true)
                    if face.doors.contains(where: { $0.act == .openProtection }) {
                        #expect(face.kind == .keysLocked, "\(face.kind) minted the Protection door")
                    }
                }
            }
        }
        let replaced = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: String(describing: SyncError.encryptionKeysReplaced), lastErrorIsOffline: false,
            canOpenProtection: true)
        #expect(replaced.kind == .keysReplaced)
        #expect(replaced.doors == [SyncRowFace.Door(label: "Account…", act: .openAccount(.account))])
        let mismatch = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
            lastError: String(describing: SyncError.accountMismatch(bound: "a", signedIn: "b")),
            lastErrorIsOffline: false, canOpenProtection: true)
        #expect(mismatch.kind == .accountMismatch)
        #expect(mismatch.doors == [SyncRowFace.Door(label: "Account…", act: .openAccount(.account))])
    }
}
