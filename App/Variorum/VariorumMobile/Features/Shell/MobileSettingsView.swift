//
//  MobileSettingsView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the voice switch's real home (scope item 6:
//  P11's placement lands; the S1 masthead door RETIRED — recorded). A
//  minimal voiced sheet off the shelf: the two voices (LK2 — the
//  phone-local preference, never synced), the sync status row (the Phase
//  8 shell that carries over), and the DEBUG spike door (the Stage 0
//  KEPT deviation's manual entry).
//

import SwiftUI
import VariorumCore

struct MobileSettingsView: View {
    let router: MobileShellRouter
    let services: AppServices?

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    #if DEBUG
    @State private var spikePresented = false
    #endif

    private var tokens: VoiceTokens {
        .resolve(voice: router.voice, dark: scheme == .dark)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tokens.path(["Settings"]))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text(tokens.chromeLabel("Done"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Text(tokens.chromeLabel("Voice"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            voiceRow(.terminal, "Terminal")
            voiceRow(.study, "Study")

            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)

            Text(tokens.chromeLabel("Sync"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
            if let services {
                SyncStatusRow(services: services)
                    .padding(.horizontal, 14)
            } else {
                Text(tokens.chromeLabel("Starting…"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.horizontal, 20)
            }

            #if DEBUG
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)
            Button("TK2 Spike") { spikePresented = true }
                .font(tokens.small)
                .padding(.horizontal, 20)
            #endif

            Spacer()
        }
        .background(tokens.room.ignoresSafeArea())
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        #endif
    }

    /// One voice's row: the terminal `›` marker carries the selection
    /// (the R1 idiom); study renders the plain selected ink.
    private func voiceRow(_ voice: ThemeVoice, _ label: String) -> some View {
        let selected = router.voice == voice
        return Button {
            router.setVoice(voice)
        } label: {
            HStack(spacing: 4) {
                if !tokens.selectionMarker.isEmpty {
                    Text(tokens.selectionMarker)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .opacity(selected ? 1 : 0)
                }
                Text(tokens.chromeLabel(label))
                    .font(tokens.body)
                    .foregroundStyle(selected ? tokens.ink : tokens.muted)
                if selected, tokens.selectionMarker.isEmpty {
                    Text("✓")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
