//
//  StoreFailureView.swift
//  Variorum
//
//  The recovery surface for a failed store open (KnownIssues
//  "AppDatabase.liveValue failure UX"). Functional and unstyled (Phase 13
//  owns beauty): what failed, where the file lives, and three ways out.
//

import AppKit
import SwiftUI
import VariorumCore

/// The first frame, while the store opens off the main thread (13l L-c).
///
/// **Deliberately silent.** The work behind it measured 54 ms at its worst,
/// and the app opens onto a calm ground regardless; a spinner would announce
/// a wait she does not have. What this view exists for is the honest
/// STRUCTURE — there is now a moment with no session, and it renders as
/// itself rather than as an empty window that looks broken.
struct StoreOpeningView: View {
    var body: some View {
        Color(nsColor: .textBackgroundColor).ignoresSafeArea()
    }
}

struct StoreFailureView: View {
    let error: AppDatabase.StoreOpenError
    /// Phase 13p (ladder R1-M3): non-nil when the failure is the
    /// encrypted-store-with-empty-custody refusal and a wraps-bearing
    /// `variorum-keys.json` sits beside the store — the surface then
    /// offers unlock by passphrase / recovery phrase through the SAME
    /// lobby machinery (the envelope road; never a new crypto road).
    var recovery: StoreLobby? = nil
    let retry: () -> Void

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Variorum database could not be opened.")
                .font(.headline)
            if !error.storePath.isEmpty {
                Text("Store: \(error.storePath)")
                    .textSelection(.enabled)
            }
            Text(error.reason)
                .textSelection(.enabled)
                .font(.callout)
            if let recovery {
                recoverySection(recovery)
            }
            HStack {
                Button("Retry") { retry() }
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting(
                        [URL(fileURLWithPath: error.storePath)])
                }
                .disabled(error.storePath.isEmpty)
                Button("Quit") { NSApp.terminate(nil) }
            }
        }
        .padding(24)
        .frame(minWidth: 480)
    }

    /// The sidecar-present unlock road (13p ladder R1-M3): the key file
    /// beside the library carries wrapped copies of its key, so the
    /// passphrase (or the twelve words) can hand it back even though this
    /// Mac's Keychain no longer holds it. Same-machine recovery; a
    /// successful unlock also re-lands the silent Keychain item, so the
    /// next launch opens normally.
    @ViewBuilder
    private func recoverySection(_ lobby: StoreLobby) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The key file beside your library can still unlock it.")
                .font(.callout.weight(.semibold))
            if lobby.passphraseOffered {
                HStack {
                    SecureField("Encryption passphrase", text: $passphrase)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 280)
                        .onSubmit { submitPassphrase(lobby) }
                    Button("Unlock") { submitPassphrase(lobby) }
                        .disabled(lobby.busy || passphrase.isEmpty)
                }
            }
            if lobby.recoveryOffered {
                DisclosureGroup(isExpanded: $showsRecoveryRoad) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(
                            "The 12 recovery words, separated by spaces",
                            text: $recoveryText, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .autocorrectionDisabled()
                            .privacySensitive()
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 360)
                        Button("Unlock with Recovery Phrase") {
                            let text = recoveryText
                            recoveryText = ""
                            Task { await lobby.unlock(recoveryText: text) }
                        }
                        .disabled(lobby.busy || recoveryText.trimmingCharacters(
                            in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.top, 6)
                } label: {
                    Text(lobby.passphraseOffered
                        ? "Forgot your passphrase?" : "Unlock with your recovery phrase")
                        .font(.caption)
                }
                .frame(maxWidth: 360)
            }
            if let unlockError = lobby.lastError {
                Text(unlockError)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if lobby.busy {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Unlocking…").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func submitPassphrase(_ lobby: StoreLobby) {
        let typed = passphrase
        passphrase = ""
        Task { await lobby.unlock(passphrase: typed) }
    }
}
