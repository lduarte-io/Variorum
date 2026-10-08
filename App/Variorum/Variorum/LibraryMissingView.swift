//
//  LibraryMissingView.swift
//  Variorum
//
//  pre-13x batch 1a — THE ABSENT-STORE FACE (the postures design §3.7;
//  copy §3 "Library file missing", rendered verbatim). A demanded at-open
//  mode over a store that is not where it was: the lock STAYS, nothing
//  opens, nothing is persisted. Three doors in the copy; per P-2 only the
//  ones that can act render here — Start a New Library (built), Restore
//  from a Backup… (reveals the app's own Backups folder, when one exists;
//  the 13l restore is a manual road), and NOT Open an Existing Library…
//  (13x's door, unbuilt).
//

import AppKit
import SwiftUI
import VariorumCore

struct LibraryMissingView: View {
    @Bindable var lobby: LibraryMissingLobby
    /// 13x U2 row 6 — copy §3's third door lands ("Open an Existing
    /// Library…", shipped unrendered since 1a): nil hosts (pins, a
    /// preview) simply don't render it (P-2).
    var openDoor: (() -> Void)? = nil
    @Environment(\.colorScheme) private var scheme

    /// No session exists yet, so the face speaks the leading voice.
    private var tokens: VoiceTokens { .fallback(for: scheme) }

    var body: some View {
        ZStack {
            tokens.room.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                card
                Spacer(minLength: 24)
                Spacer(minLength: 24)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(tokens.muted)
            Text(ProtectionCopy.libraryMissingTitle)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
            Text(ProtectionCopy.libraryMissingBody)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if let folder = lobby.backupsFolderURL {
                Button(ProtectionCopy.libraryMissingRestoreDoor) {
                    NSWorkspace.shared.activateFileViewerSelecting([folder])
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .disabled(lobby.busy)
            }
            if let openDoor {
                Button(ProtectionCopy.libraryMissingOpenDoor) { openDoor() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                    .disabled(lobby.busy)
            }
            VStack(spacing: 4) {
                Button(ProtectionCopy.libraryMissingStartDoor) {
                    Task { await lobby.startNewLibrary() }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .disabled(lobby.busy || lobby.storeURL == nil)
                Text(ProtectionCopy.libraryMissingStartSubline)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
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
                    TravellingDotsIndicator(ink: tokens.muted)
                    Text("Starting…")
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
}
