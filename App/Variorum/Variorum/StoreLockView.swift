//
//  StoreLockView.swift
//  Variorum
//
//  Phase 13p, Batch 2 — the locked lobby's Mac face (R13p-5). Renders
//  INSTEAD of RootView: while this is on screen there is no session, no
//  services, no open store — the calm proof that nothing runs before
//  unlock. Placeholder voice, honest content (13s re-voices).
//
//  The biometric demand auto-asks ONCE on appear (that is what "asks
//  every time it opens" means), with the passphrase road rendered beside
//  it (R13p-5: the fallback is the passphrase, never the device
//  password); the forgot-road (recovery phrase) sits behind a disclosure.
//

import SwiftUI
import VariorumCore

struct StoreLockView: View {
    @Bindable var lobby: StoreLobby

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false
    @State private var autoAsked = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(.secondary)
            Text("Variorum is locked")
                .font(.title3.weight(.semibold))
            Text(ProtectionCopy.lobbyPrompt(lobby.demand))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if lobby.noRoadExists {
                deadEnd
            } else {
                roads
            }

            if let error = lobby.lastError {
                Text(error)
                    .font(.callout)
                    .alarmVoice()
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if lobby.busy {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Unlocking…").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .task {
            // The biometric demand asks as the lobby appears — once; the
            // button below re-asks. (The prompt is the mode's whole point.)
            guard lobby.demand == .biometric, lobby.biometryOffered, !autoAsked else { return }
            autoAsked = true
            await lobby.unlockWithBiometrics()
        }
    }

    @ViewBuilder
    private var roads: some View {
        if lobby.biometryOffered {
            Button {
                Task { await lobby.unlockWithBiometrics() }
            } label: {
                Label("Unlock with \(ProtectionCopy.biometryName)", systemImage: "touchid")
            }
            .disabled(lobby.busy)
        }
        if lobby.passphraseOffered {
            VStack(spacing: 8) {
                SecureField("Encryption passphrase", text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 320)
                    .onSubmit { submitPassphrase() }
                Button("Unlock") { submitPassphrase() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(lobby.busy || passphrase.isEmpty)
            }
        }
        if lobby.recoveryOffered {
            DisclosureGroup(isExpanded: $showsRecoveryRoad) {
                VStack(spacing: 8) {
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
                Text("Forgot your passphrase?")
                    .font(.caption)
            }
            .frame(maxWidth: 360)
        }
    }

    /// Practically unreachable (the mode transitions refuse to enter a
    /// demanded mode without a wrap) — but a dead end must SAY so, never
    /// render an empty room.
    private var deadEnd: some View {
        Text("No way to unlock this library exists on this device: its "
             + "fingerprint item is gone and no passphrase or recovery "
             + "phrase is on file beside the library. Restore the "
             + "\(StoreKeyEnvelope.filename) file from a backup folder, or "
             + "restore the whole library from a backup.")
            .font(.callout)
            .alarmVoice()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func submitPassphrase() {
        let typed = passphrase
        passphrase = ""
        Task { await lobby.unlock(passphrase: typed) }
    }
}
