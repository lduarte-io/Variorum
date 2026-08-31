//
//  StoreLockView.swift
//  Variorum
//
//  Phase 13p, Batch 2 — the locked lobby's Mac face (R13p-5). Renders
//  INSTEAD of RootView: while this is on screen there is no session, no
//  services, no open store — the calm proof that nothing runs before
//  unlock.
//
//  ── pre-13u ACT 10 item 7 — THE REFRESH (her ask: "this page looks ugly
//  … maybe throw one of the tesselating background art photos on there
//  with a calm white box in the middle for it, aware that the prompt will
//  appear") ────────────────────────────────────────────────────────────────
//  · The backdrop is one of the brand's TESSELLATING endpaper pieces
//    (`girl-and-the-fan` — TASTE.md's named seamless tile, the fan being
//    the brand's own image), scaled to an endpaper grain and washed almost
//    to the paper, so the room reads as the library's endpaper rather than
//    as a poster. If the asset ever fails to load, the lobby composes calm
//    without it — nothing here may block an unlock.
//  · The content is a CALM CARD (the W8-2 grammar), placed in the UPPER
//    third — the system Touch ID dialog lands centered on the screen, so
//    the essentials sit above where it appears and are never occluded.
//  · LESS ON SCREEN at first unlock (progressive disclosure): under a
//    Biometric demand only the Touch ID road shows; the passphrase field
//    arrives on demand behind a quiet "use your encryption passphrase
//    instead" word, and the recovery road stays behind its disclosure.
//    Under a Passphrase demand the field is the road and shows directly.
//
//  The biometric demand auto-asks ONCE on appear (that is what "asks
//  every time it opens" means); every sentence is the standing
//  `ProtectionCopy` brain's — no copy changed in the restyle.
//

import SwiftUI
import VariorumCore

/// The endpaper's bundle anchor: `Bundle(for:)` finds the APP bundle even
/// when this view is hosted from a test runner (whose `Bundle.main` is the
/// runner, not the app).
private final class LobbyEndpaperLocator {}

struct StoreLockView: View {
    @Bindable var lobby: StoreLobby

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false
    /// Item 7's progressive disclosure: under a BIOMETRIC demand the
    /// passphrase road waits behind one quiet word. Any other demand shows
    /// the field directly (it is the road).
    @State private var passphraseRevealed = false
    @State private var autoAsked = false
    @Environment(\.colorScheme) private var scheme

    /// No session exists yet, so the lobby speaks the leading voice.
    private var tokens: VoiceTokens { .fallback(for: scheme) }

    /// The endpaper tile, loaded once per lobby (a 32 KB bundled SVG). At
    /// an endpaper grain: the art's natural 1024 pt would read as a poster.
    @State private var endpaper: NSImage?

    var body: some View {
        ZStack {
            tokens.room.ignoresSafeArea()
            if let endpaper {
                Image(nsImage: endpaper)
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                    .opacity(scheme == .dark ? 0.08 : 0.55)
                    .allowsHitTesting(false)
                // The wash: the pattern stays an undertone, never a poster.
                tokens.room.opacity(scheme == .dark ? 0.5 : 0.35)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                card
                // The card sits in the upper third: the system biometry
                // dialog lands mid-screen, and the essentials stay clear
                // of it (the 1:2 spacer split).
                Spacer(minLength: 24)
                Spacer(minLength: 24)
            }
        }
        .task { loadEndpaper() }
        .task {
            // The biometric demand asks as the lobby appears — once; the
            // button below re-asks. (The prompt is the mode's whole point.)
            guard lobby.demand == .biometric, lobby.biometryOffered, !autoAsked else { return }
            autoAsked = true
            await lobby.unlockWithBiometrics()
        }
    }

    private var card: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(tokens.muted)
            Text("Variorum is locked")
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(ProtectionCopy.lobbyPrompt(lobby.demand))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if lobby.noRoadExists {
                deadEnd
            } else {
                roads
            }

            if let error = lobby.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if lobby.busy {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Unlocking…")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
            }
        }
        .padding(28)
        .frame(maxWidth: 420)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0.5 : 0.10), radius: 22, y: 8)
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var roads: some View {
        if lobby.biometryOffered {
            Button {
                Task { await lobby.unlockWithBiometrics() }
            } label: {
                Label("Unlock with \(ProtectionCopy.biometryName)", systemImage: "touchid")
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            .disabled(lobby.busy)
        }
        if lobby.passphraseOffered {
            // Under a BIOMETRIC demand the field waits behind one quiet
            // word (item 7's less-on-screen); under a passphrase demand the
            // field IS the road and shows directly.
            if lobby.demand == .biometric && lobby.biometryOffered && !passphraseRevealed {
                Button("Use your encryption passphrase instead") {
                    passphraseRevealed = true
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            } else {
                VStack(spacing: 8) {
                    PeekableSecretField(
                        label: "Encryption passphrase", text: $passphrase,
                        onSubmit: { submitPassphrase() })
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)
                    Button("Unlock") { submitPassphrase() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                        .keyboardShortcut(.defaultAction)
                        .disabled(lobby.busy || passphrase.isEmpty)
                }
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
                        .frame(maxWidth: 340)
                    Button("Unlock with Recovery Phrase") {
                        let text = recoveryText
                        recoveryText = ""
                        Task { await lobby.unlock(recoveryText: text) }
                    }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                    .disabled(lobby.busy || recoveryText.trimmingCharacters(
                        in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 6)
            } label: {
                Text("Forgot your passphrase?")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: 340)
        }
    }

    /// Practically unreachable (the mode transitions refuse to enter a
    /// demanded mode without a wrap) — but a dead end must SAY so, never
    /// render an empty room. The sentence is the lobby's ONE brain
    /// (P11: an unreadable sidecar gets its true cause, never the
    /// absent-wraps one).
    private var deadEnd: some View {
        Text(lobby.deadEndMessage)
            .font(tokens.small)
            .alarmVoice()
            .multilineTextAlignment(.center)
            .lineLimit(8)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func submitPassphrase() {
        let typed = passphrase
        passphrase = ""
        Task { await lobby.unlock(passphrase: typed) }
    }

    private func loadEndpaper() {
        guard endpaper == nil,
              let url = Bundle(for: LobbyEndpaperLocator.self)
                  .url(forResource: "lobby-endpaper", withExtension: "svg"),
              let image = NSImage(contentsOf: url)
        else { return }
        // The endpaper grain: the art's own 1024 pt reads as a poster; a
        // ~340 pt tile reads as a pattern. RASTERIZED at 2× — SwiftUI's
        // tiling draws bitmap reps; an SVG rep tiles as nothing (measured).
        let tile = NSSize(width: 340, height: 340)
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 680, pixelsHigh: 680,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB,
            bytesPerRow: 0, bitsPerPixel: 0)
        else { return }
        rep.size = tile
        NSGraphicsContext.saveGraphicsState()
        if let context = NSGraphicsContext(bitmapImageRep: rep) {
            NSGraphicsContext.current = context
            image.draw(
                in: NSRect(origin: .zero, size: tile),
                from: .zero, operation: .sourceOver, fraction: 1)
            context.flushGraphics()
        }
        NSGraphicsContext.restoreGraphicsState()
        let raster = NSImage(size: tile)
        raster.addRepresentation(rep)
        endpaper = raster
    }
}
