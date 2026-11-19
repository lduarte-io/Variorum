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
                    .foregroundStyle(tokens.phone.muted)
                Text(tokens.chromeLabel(ProtectionCopy.libraryMissingTitle))
                    .phoneType(.screenTitle, tokens)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.center)
                Text(ProtectionCopy.libraryMissingBody)
                    .phoneType(.rowPreview, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 6) {
                    Button {
                        Task { await lobby.startNewLibrary() }
                    } label: {
                        Text(tokens.chromeLabel(ProtectionCopy.libraryMissingStartDoor))
                    }
                    // VM-50: THE calm button (was its own build).
                    .buttonStyle(PhoneCalmButtonStyle(tokens: tokens))
                    .disabled(lobby.busy || lobby.storeURL == nil)
                    .accessibilityLabel(ProtectionCopy.libraryMissingStartDoor)
                    Text(ProtectionCopy.libraryMissingStartSubline)
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                        .multilineTextAlignment(.center)
                }

                if let error = lobby.lastError {
                    Text(error)
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.alarm)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if lobby.busy {
                    HStack(spacing: 6) {
                        TravellingDotsIndicator(ink: tokens.phone.muted)
                        Text(tokens.chromeLabel("Starting…"))
                            .phoneType(.meta, tokens)
                            .foregroundStyle(tokens.phone.muted)
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
