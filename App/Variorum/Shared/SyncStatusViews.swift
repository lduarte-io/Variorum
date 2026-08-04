//
//  SyncStatusViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the one-row functional sync status surface (SyncSpec
//  §10's "sync status indicator" scope, nothing more). Phase 9c, Step 5:
//  the paste-in form (SyncSetupView) is DELETED — the row's door is the
//  sign-in surface (AccountView), and an unconfigured row means signed
//  out, not credential-less. Views render state and send actions only;
//  functional and unstyled (Phase 13 owns beauty).
//

import SwiftUI
import VariorumCore

/// One row: signed-in + configured → last sync / pending / error;
/// signed out → the sign-in door.
struct SyncStatusRow: View {
    let services: AppServices
    @State private var showingAccount = false
    @State private var showingEncryption = false

    private var sync: SyncSession { services.sync }

    /// Phase 14b (L9): the engine's keys-refusal, classified — the row
    /// names the fix and offers the door to it.
    private var keysLocked: Bool {
        guard let error = sync.status.lastError else { return false }
        return EncryptionSession.isKeysLockedError(error)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 6) {
            if !sync.allowsSync {
                // The A4 fence: a dev-store session never syncs — no
                // sign-in door either (the one mirror belongs to the real
                // store; signing in belongs to real-store sessions).
                Text("Sync off (dev store)")
                    .foregroundStyle(.secondary)
            } else if !sync.isConfigured {
                Text(services.account.variorum == nil ? "Signed out" : "Sync is off")
                    .foregroundStyle(.secondary)
                Button("Sign in…") { showingAccount = true }
            } else if sync.status.isSyncing {
                ProgressView().controlSize(.small)
                Text("Syncing…")
            } else if let error = sync.status.lastError {
                // Phase 11, Step A0 (KnownIssues row, re-owned from 10 with
                // author approval 2026-07-12): offline is a designed-for
                // state (A3 — outbox kept, next trigger retries), so it
                // presents as waiting/pending, never as "Sync error". Real
                // refusals keep the error face.
                if sync.status.lastErrorIsOffline {
                    Text(Self.offlineLabel)
                        .foregroundStyle(.secondary)
                        .help(error)
                    if sync.status.pendingPushCount > 0 {
                        Text("· \(sync.status.pendingPushCount) pending")
                            .foregroundStyle(.secondary)
                    }
                    Button("Sync now") { sync.triggerSync() }
                } else if keysLocked {
                    // Phase 14b (L9): the locked-state line — the engine's
                    // keys-refusal presents as a paused state naming its
                    // fix, never a generic "Sync error" (nothing is lost
                    // while paused; the outbox keeps everything).
                    Text(Self.lockedLabel)
                        .foregroundStyle(.orange)
                        .help(error)
                    Button("Unlock…") { showingEncryption = true }
                    // The keys check precedes any transport contact, so a
                    // dead/stale session sits BEHIND the locked face and no
                    // auth error ever surfaces — the Account door must stay
                    // reachable here (pre-Stage-A, 2026-08-04: her phone's
                    // exact state).
                    Button("Account…") { showingAccount = true }
                } else {
                    Text("Sync error")
                        .foregroundStyle(.red)
                    Button("Retry") { sync.triggerSync() }
                    Button("Account…") { showingAccount = true }
                }
            } else {
                Text(lastSyncLabel)
                    .foregroundStyle(.secondary)
                if sync.status.pendingPushCount > 0 {
                    Text("· \(sync.status.pendingPushCount) pending")
                        .foregroundStyle(.secondary)
                }
                Button("Sync now") { sync.triggerSync() }
                Button("Account…") { showingAccount = true }
            }
        }
        // Phase 14b: the E2EE settings door (the Settings/sync sheet family
        // — Round 6 item 2: the recovery phrase is generated HERE). Shown
        // whenever a signed-in real-store session exists; the sheet itself
        // projects the exact state (setup / enroll / enrolled doors).
        if sync.allowsSync, services.account.variorum != nil, !keysLocked {
            Button("Encryption…") { showingEncryption = true }
        }
        // Sitting 9 (R94): the cause inline, classified — an auth-shaped
        // failure names its fix and the Account door is right there. The
        // keys-locked state carries its own line above instead (the cause
        // IS the line).
        if let error = sync.status.lastError, !sync.status.lastErrorIsOffline,
           !sync.status.isSyncing, !keysLocked {
            ErrorCauseNote(error: error)
        }
        }
        .font(.caption)
        .padding(6)
        .sheet(isPresented: $showingAccount) {
            AccountView(services: services)
        }
        .sheet(isPresented: $showingEncryption) {
            EncryptionView(services: services)
        }
    }

    /// The locked-state line's one string (Phase 14b, L9 — the SyncSpec
    /// §12-grammar presentation of `SyncError.encryptionKeysUnavailable`),
    /// exposed for the presented-state pin like `offlineLabel`.
    static let lockedLabel = "Sync locked — enter your encryption passphrase"

    private var lastSyncLabel: String {
        guard let last = sync.status.lastSuccessAt else { return "Not synced yet" }
        return "Synced \(last.formatted(date: .omitted, time: .shortened))"
    }

    /// The offline presentation's one string (Step A0's row letter),
    /// exposed for the presented-state pin.
    static let offlineLabel = "Waiting to sync (offline)"
}
