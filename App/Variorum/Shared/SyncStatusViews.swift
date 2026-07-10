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

    private var sync: SyncSession { services.sync }

    var body: some View {
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
                Text("Sync error")
                    .foregroundStyle(.red)
                    .help(error)
                Button("Retry") { sync.triggerSync() }
                Button("Account…") { showingAccount = true }
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
        .font(.caption)
        .padding(6)
        .sheet(isPresented: $showingAccount) {
            AccountView(services: services)
        }
    }

    private var lastSyncLabel: String {
        guard let last = sync.status.lastSuccessAt else { return "Not synced yet" }
        return "Synced \(last.formatted(date: .omitted, time: .shortened))"
    }
}
