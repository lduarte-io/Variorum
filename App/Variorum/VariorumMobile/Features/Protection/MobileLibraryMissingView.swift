//
//  MobileLibraryMissingView.swift
//  VariorumMobile
//
//  pre-13x batch 1a — THE PHONE'S ABSENT-STORE FACE (the postures design
//  §3.7; copy §3 "Library file missing", verbatim), over the SAME brain as
//  the Mac's (`LibraryMissingLobby`, Shared). The lock stays; nothing
//  opens. Per P-2 the one door that can act here renders: Start a New
//  Library. (Restore from a Backup… has no phone road — the phone's store
//  is re-derivable from the mirror, and 13l's backups are the Mac's; Open
//  an Existing Library… is 13x's, unbuilt.)
//

import SwiftUI
import VariorumCore

struct MobileLibraryMissingView: View {
    @Bindable var lobby: LibraryMissingLobby
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(tokens.muted)
                Text(tokens.chromeLabel(ProtectionCopy.libraryMissingTitle))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.center)
                Text(ProtectionCopy.libraryMissingBody)
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 6) {
                    Button {
                        Task { await lobby.startNewLibrary() }
                    } label: {
                        Text(tokens.chromeLabel(ProtectionCopy.libraryMissingStartDoor))
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
                    .disabled(lobby.busy || lobby.storeURL == nil)
                    .accessibilityLabel(ProtectionCopy.libraryMissingStartDoor)
                    Text(ProtectionCopy.libraryMissingStartSubline)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .multilineTextAlignment(.center)
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
                        TravellingDotsIndicator(ink: tokens.muted)
                        Text(tokens.chromeLabel("Starting…"))
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
    }
}
