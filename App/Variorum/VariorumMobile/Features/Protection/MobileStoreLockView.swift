//
//  MobileStoreLockView.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — THE PHONE'S LOCKED LOBBY (the mobile-only-user
//  expansion's item (c); PL-15). The twin of the Mac's `StoreLockView`
//  over the SAME brain (`StoreLobby`, Shared): while this is on screen
//  there is no session, no services, no open store, and no capture
//  surface — the phone's proof that nothing runs before unlock.
//
//  Face ID auto-asks ONCE on appear (that is what "asks every time it
//  opens" means), with the passphrase road rendered beside it — R13p-5's
//  fallback is the PASSPHRASE, never the device passcode — and the
//  forgot-road (the twelve words) behind a disclosure.
//
//  It renders in the voice the phone is set to, read from the DEVICE
//  preference (`MobileVoicePreference`) rather than the store: the store
//  is exactly what is not open yet. Placeholder voice, honest content —
//  13s re-voices.
//

import SwiftUI
import VariorumCore

struct MobileStoreLockView: View {
    @Bindable var lobby: StoreLobby
    let tokens: VoiceTokens

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false
    @State private var autoAsked = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: lobby.isWaitingForICloudKeychain ? "icloud" : "lock.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(tokens.muted)
                if lobby.isWaitingForICloudKeychain {
                    // pre-13x 2a (§3.8) — STANDARD'S WAITING STATE, copy §2d
                    // verbatim (the phone's nouns ride the interpolation).
                    Text(tokens.chromeLabel(ProtectionCopy.waitingTitle))
                        .font(tokens.title)
                        .foregroundStyle(tokens.ink)
                        .multilineTextAlignment(.center)
                    Text(lobby.differentAppleID
                         ? ProtectionCopy.waitingDifferentAppleID
                         : ProtectionCopy.waitingBody)
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(tokens.chromeLabel("Variorum is locked"))
                        .font(tokens.title)
                        .foregroundStyle(tokens.ink)
                    Text(ProtectionCopy.lobbyPrompt(lobby.demand))
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if lobby.noRoadExists {
                    if !lobby.isWaitingForICloudKeychain { deadEnd }
                } else {
                    roads
                }

                if let error = lobby.lastError {
                    Text(error)
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if lobby.busy {
                    HStack(spacing: 6) {
                        ProgressView()
                        Text(tokens.chromeLabel("Unlocking…"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room.ignoresSafeArea())
        .task {
            // The biometric demand asks as the lobby appears — once; the
            // button below re-asks.
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
                Label(
                    tokens.chromeLabel("Unlock with \(ProtectionCopy.biometryName)"),
                    systemImage: "faceid")
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tokens.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(tokens.line, lineWidth: 1)))
            }
            .buttonStyle(.plain)
            .disabled(lobby.busy)
            .accessibilityLabel("Unlock with \(ProtectionCopy.biometryName)")
        }
        if lobby.passphraseOffered {
            VStack(spacing: 10) {
                PeekableSecretField(
                    label: "Encryption passphrase", text: $passphrase,
                    onSubmit: { submitPassphrase() })
                    .submitLabel(.go)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tokens.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(tokens.line, lineWidth: 1)))
                Button(tokens.chromeLabel("Unlock")) { submitPassphrase() }
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    .disabled(lobby.busy || passphrase.isEmpty)
                    .accessibilityLabel("Unlock")
            }
        }
        if lobby.recoveryOffered {
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    showsRecoveryRoad.toggle()
                } label: {
                    Text(tokens.chromeLabel(lobby.isWaitingForICloudKeychain
                                            ? ProtectionCopy.waitingWordsDoor
                                            : "Forgot your passphrase?"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                if showsRecoveryRoad {
                    TextField(
                        "The 12 recovery words, separated by spaces",
                        text: $recoveryText, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .privacySensitive()
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tokens.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tokens.line, lineWidth: 1)))
                    Button(tokens.chromeLabel("Unlock with Recovery Phrase")) {
                        let text = recoveryText
                        recoveryText = ""
                        Task { await lobby.unlock(recoveryText: text) }
                    }
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    .disabled(lobby.busy || recoveryText.trimmingCharacters(
                        in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Unlock with Recovery Phrase")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Practically unreachable (the mode transitions refuse to enter a
    /// demanded mode without a wrap) — but a dead end must SAY so, never
    /// render an empty room. The Mac's twin says the same thing; the
    /// sentence is the lobby's ONE brain (P11: an unreadable sidecar gets
    /// its true cause, never the absent-wraps one).
    private var deadEnd: some View {
        Text(lobby.deadEndMessage)
            .font(tokens.small)
            .foregroundStyle(tokens.alarm)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func submitPassphrase() {
        let typed = passphrase
        passphrase = ""
        Task { await lobby.unlock(passphrase: typed) }
    }
}
