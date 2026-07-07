//
//  SyncStatusViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the one-row functional sync status surface (SyncSpec
//  §10's "sync status indicator" scope, nothing more) and the paste-in
//  credentials form (PROVISIONAL mechanism, ratify at checkpoint). Views
//  render state and send actions only; functional and unstyled (Phase 13
//  owns beauty).
//

import SwiftUI
import VariorumCore

/// One row: configured → last sync / pending / error; unconfigured → the
/// setup door.
struct SyncStatusRow: View {
    let sync: SyncSession
    @State private var showingSetup = false

    var body: some View {
        HStack(spacing: 6) {
            if !sync.allowsSync {
                // The A4 fence: a dev-store session never syncs — no setup
                // door either (the one mirror belongs to the real store).
                Text("Sync off (dev store)")
                    .foregroundStyle(.secondary)
            } else if !sync.isConfigured {
                Text("Sync is off")
                    .foregroundStyle(.secondary)
                Button("Set up…") { showingSetup = true }
            } else if sync.status.isSyncing {
                ProgressView().controlSize(.small)
                Text("Syncing…")
            } else if let error = sync.status.lastError {
                Text("Sync error")
                    .foregroundStyle(.red)
                    .help(error)
                Button("Retry") { sync.triggerSync() }
            } else {
                Text(lastSyncLabel)
                    .foregroundStyle(.secondary)
                if sync.status.pendingPushCount > 0 {
                    Text("· \(sync.status.pendingPushCount) pending")
                        .foregroundStyle(.secondary)
                }
                Button("Sync now") { sync.triggerSync() }
            }
        }
        .font(.caption)
        .padding(6)
        .sheet(isPresented: $showingSetup) {
            SyncSetupView(sync: sync)
        }
    }

    private var lastSyncLabel: String {
        guard let last = sync.status.lastSuccessAt else { return "Not synced yet" }
        return "Synced \(last.formatted(date: .omitted, time: .shortened))"
    }
}

/// The paste-in credentials form: URL + API key (+ optional bearer token —
/// blank reuses the API key, the single-user default). Stored in the
/// Keychain; re-paste after a key rotation.
struct SyncSetupView: View {
    let sync: SyncSession
    @Environment(\.dismiss) private var dismiss
    @State private var urlText = ""
    @State private var apiKey = ""
    @State private var authToken = ""
    @State private var problem: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Supabase sync setup").font(.headline)
            Text("Paste the project URL and API key. Nothing is bundled with the app; re-paste after rotating keys.")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Project URL (https://…supabase.co)", text: $urlText)
                .textContentType(.URL)
                .autocorrectionDisabled()
            SecureField("API key", text: $apiKey)
            SecureField("Bearer token (blank = API key)", text: $authToken)
            if let problem {
                Text(problem).font(.caption).foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save & sync") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(urlText.isEmpty || apiKey.isEmpty)
            }
        }
        .padding(20)
        .frame(minWidth: 420)
        .onAppear {
            if let existing = sync.credentials {
                urlText = existing.projectURL.absoluteString
                apiKey = existing.apiKey
                authToken = existing.authToken == existing.apiKey ? "" : existing.authToken
            }
        }
    }

    private func save() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), url.scheme?.hasPrefix("http") == true else {
            problem = "That URL doesn't look right."
            return
        }
        let token = authToken.isEmpty ? apiKey : authToken
        let credentials = SyncCredentials(projectURL: url, apiKey: apiKey, authToken: token)
        let sync = sync
        Task {
            // Async: configure drains a mid-round predecessor first (A3 at
            // the session layer).
            await sync.configure(with: credentials, persist: true)
            sync.triggerSync()
        }
        dismiss()
    }
}
