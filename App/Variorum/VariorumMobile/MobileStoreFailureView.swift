//
//  MobileStoreFailureView.swift
//  VariorumMobile
//
//  The recovery surface for a failed store open — the iOS twin of the Mac's
//  StoreFailureView (no Finder/quit affordances here). Functional and
//  unstyled (Phase 13 owns beauty).
//

import SwiftUI
import VariorumCore

/// The first frame, while the store opens off the main thread (13l L-c).
///
/// **Deliberately silent.** The work behind it measured 54 ms at its worst
/// and "almost imperceptible" on her device, so a spinner would announce a
/// wait she does not have; and the calm ground is what the app opens onto
/// anyway. What this view exists for is the honest STRUCTURE: there is now
/// a moment with no session, and it renders as itself rather than as an
/// empty shell that looks broken.
struct MobileStoreOpeningView: View {
    var body: some View {
        Color(.systemBackground).ignoresSafeArea()
    }
}

struct MobileStoreFailureView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("The Variorum database could not be opened.")
                    .font(.headline)
                if !error.storePath.isEmpty {
                    Text("Store: \(error.storePath)")
                        .font(.caption)
                        .textSelection(.enabled)
                }
                Text(error.reason)
                    .font(.callout)
                    .textSelection(.enabled)
                if let recovery {
                    recoverySection(recovery)
                }
                Button("Retry") { retry() }
            }
            .padding(24)
        }
    }

    /// The sidecar-present unlock road (13p ladder R1-M3) — the phone twin
    /// of the Mac's section, over the same `StoreLobby` brain.
    @ViewBuilder
    private func recoverySection(_ lobby: StoreLobby) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The key file beside your library can still unlock it.")
                .font(.callout.weight(.semibold))
            if lobby.passphraseOffered {
                PeekableSecretField(
                    label: "Encryption passphrase", text: $passphrase,
                    onSubmit: { submitPassphrase(lobby) })
                    .submitLabel(.go)
                    .textFieldStyle(.roundedBorder)
                Button("Unlock") { submitPassphrase(lobby) }
                    .disabled(lobby.busy || passphrase.isEmpty)
            }
            if lobby.recoveryOffered {
                Button(lobby.passphraseOffered
                    ? "Forgot your passphrase?" : "Unlock with your recovery phrase") {
                    showsRecoveryRoad.toggle()
                }
                .font(.caption)
                if showsRecoveryRoad {
                    TextField(
                        "The 12 recovery words, separated by spaces",
                        text: $recoveryText, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .privacySensitive()
                        .textFieldStyle(.roundedBorder)
                    Button("Unlock with Recovery Phrase") {
                        let text = recoveryText
                        recoveryText = ""
                        Task { await lobby.unlock(recoveryText: text) }
                    }
                    .disabled(lobby.busy || recoveryText.trimmingCharacters(
                        in: .whitespacesAndNewlines).isEmpty)
                }
            }
            if let unlockError = lobby.lastError {
                Text(unlockError)
                    .font(.callout)
                    // Literal on purpose: this surface renders BEFORE the
                    // store (and its voice) can be read — the same reason
                    // the whole view is unstyled plain SwiftUI.
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if lobby.busy {
                HStack(spacing: 6) {
                    ProgressView()
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
