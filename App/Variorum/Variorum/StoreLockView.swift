//
//  StoreLockView.swift
//  Variorum
//
//  THE LOBBY'S MAC FACE (`RoadLockView`, the protection road's — VX-306 U1b): renders INSTEAD of RootView, so while it
//  is on screen there is no session, no services, no open store — the calm proof that nothing runs before unlock. The
//  room is the 13p lobby's (pre-13u Act 10 item 7: `GlyphRainBackdrop` behind a calm card in the upper third, so the
//  system Touch ID dialog never occludes the essentials); VX-140's rule stands: the automatic Touch ID ask fires only
//  while Variorum is the active app. VX-329 U1: today's 13p lobby (`StoreLockView` over `StoreLobby`) was deleted with
//  today's road; the file keeps its name (the pins read it by path).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - VX-306 U1b — THE ROAD'S LOBBY

/// The road's lobby face, rendering `ProtectionLobbyModel` (`notes/plans/vx-306-castle-open-road.md` §2 U1b):
/// the room and calm card of the 13p lobby (deleted with today's road at VX-329), on the core's roads. The quiet roads were tried at once
/// before this shows (rule 8), so the typed field shows at once — the passphrase field when the library's key
/// files carry one, the words behind one quiet door beside it (or the words field directly when there is no
/// passphrase); VX-310's Touch ID button and its one line (design §3.10); rule 27's sentence when no road
/// exists at all (its doors are U2's face). It re-reads the roads when Variorum becomes active again (VX-310's
/// second bug — never a relaunch to bring a road back). VX-329 U4: over a store from before this design (rule 26 — an
/// older Variorum's key file beside it by name, none of this design's) it shows HER pre-design face instead — her lead,
/// her body, *Start fresh…* (her confirm first) and *Open Library…* — and no road at all.
struct RoadLockView: View {
    @Bindable var lobby: ProtectionLobbyModel
    /// VX-306 U2 — rule 27's face's *Open Library…* (13x's open door, the missing face's); nil: not rendered. VX-329 U4:
    /// her pre-design face's second door, the same standing door.
    var openDoor: (() -> Void)? = nil
    /// VX-309 U1b — rule 27's face's *Restore from Backup…* as the doors over this Mac's catalogued copies (rule 17: "The
    /// app's Restore from Backup is this door"), shown where a home of copies stands (`copiesHome`); nil: not rendered.
    /// (VX-329 U1: today's Finder-revealing restore left with today's road.)
    var restoreDoor: (() -> Void)? = nil
    var copiesHome = false
    /// VX-140: whether Variorum is the active app RIGHT NOW — the automatic ask's one input beyond the lobby.
    var appIsActive: () -> Bool = { NSApp.isActive }

    /// VX-309 U1b — a home of this Mac's copies beside the library (`Backups/` or `Previous Libraries/`).
    static func copiesHome(besideStore storeURL: URL) -> Bool {
        let container = storeURL.deletingLastPathComponent()
        return [CatalogNames.backupsFolderName, CatalogNames.previousLibrariesFolderName].contains {
            FileManager.default.fileExists(atPath: container.appendingPathComponent($0, isDirectory: true).path)
        }
    }

    @State private var passphrase = ""
    @State private var wordsText = ""
    @State private var showsWords = false
    /// VX-329 U4 — *Start fresh…* asks her confirm first (her line, the plan's §6d).
    @State private var confirmsStartFresh = false
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens { .fallback(for: scheme) }
    private var face: ProtectionLobbyFace { lobby.face }

    var body: some View {
        ZStack {
            tokens.room.ignoresSafeArea()
            GlyphRainBackdrop(tokens: tokens, scheme: scheme)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                card
                Spacer(minLength: 24)
                Spacer(minLength: 24)
            }
        }
        .task { await lobby.autoAskIfDue(appIsActive: appIsActive()) }
        .onReceive(NotificationCenter.default.publisher(
            for: NSApplication.didBecomeActiveNotification)) { _ in
            Task {
                await lobby.refresh()
                await lobby.autoAskIfDue(appIsActive: true)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(tokens.muted)
            if face.preDesignStore {
                // VX-329 U4 — RULE 26 before unlock: a store from before this design (its key files' names alone say so).
                // HER face, her words only (the plan's §6d): the lead, the body, her two doors — no road, no lobby title.
                Text(ProtectionWords.preDesignLead)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                sentence(ProtectionWords.preDesignBody)
                preDesignDoors
            } else {
                Text(ProtectionWords.lobbyTitle)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                standingLobby
            }
            if face.liveKeyFileUnreadable {
                Text(ProtectionWords.liveKeyFileUnreadable)
                    .font(tokens.small)
                    .alarmVoice()
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let message = lobby.message {
                Text(message)
                    .font(tokens.small)
                    .alarmVoice()
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if lobby.busy {
                HStack(spacing: 6) {
                    TravellingDotsIndicator(ink: tokens.muted)
                    // Under her pre-design face nothing is opening (Start fresh… is running): the dots alone, no words
                    // beyond hers.
                    if !face.preDesignStore {
                        Text(ProtectionWords.opening)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(28)
        .frame(maxWidth: 420)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0.5 : 0.10), radius: 22, y: 8)
        .padding(.horizontal, 32)
        // VX-329 U4 — *Start fresh…*'s confirm: her line (the plan's §6d); the act runs only on its yes.
        .alert(ProtectionWords.preDesignStartFreshConfirm, isPresented: $confirmsStartFresh) {
            Button(ProtectionWords.preDesignStartFreshButton) {
                Task { await lobby.startFresh() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    /// The lobby as it stands for every slot but a pre-design one: rule 27's refusal and its doors when no road exists
    /// at all, else the roads.
    @ViewBuilder
    private var standingLobby: some View {
        if let nothing = face.noKeyFileAnywhere {
            // RULE 27 before unlock — §7c (3), the account sentence only when the account road is named, and
            // the missing face's three doors beneath (VX-306 U2).
            sentence(ProtectionWords.noKeyFileAnywhere)
            if nothing.accountRoad { sentence(ProtectionWords.noKeyFileAnywhereAccountRoad) }
            noKeyFileDoors
        } else {
            sentence(face.keychainUnreadable ? ProtectionWords.keychainUnreadable : face.lead)
            // VX-529 unit 2 — E6 (R-529-6: the why and the road): the account's passphrase hasn't been typed here yet; the
            // field below takes it (the lobby's vault road).
            if let line = face.accountPassphraseLine { sentence(line) }
            roads
        }
    }

    /// VX-329 U4 — her pre-design face's two doors (the plan's §6d), each rendered only where it can act (P-2):
    /// *Start fresh…* asks her confirm first; *Open Library…* is the standing door.
    @ViewBuilder
    private var preDesignDoors: some View {
        if lobby.offersStartFresh {
            Button(ProtectionWords.preDesignStartFreshDoor) { confirmsStartFresh = true }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .disabled(lobby.busy)
        }
        if let openDoor {
            Button(ProtectionWords.preDesignOpenDoor) { openDoor() }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .disabled(lobby.busy)
        }
    }

    private func sentence(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .multilineTextAlignment(.center)
            .lineLimit(6)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Rule 27's doors — the missing face's three, §7c (3)'s words; each renders only where it can act (P-2).
    @ViewBuilder
    private var noKeyFileDoors: some View {
        if let restoreDoor, copiesHome {
            Button(ProtectionWords.noKeyFileRestoreDoor) { restoreDoor() }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .disabled(lobby.busy)
        }
        if let openDoor {
            Button(ProtectionWords.noKeyFileOpenDoor) { openDoor() }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
                .disabled(lobby.busy)
        }
        if lobby.offersStartNew {
            VStack(spacing: 4) {
                Button(ProtectionWords.noKeyFileStartDoor) {
                    Task { await lobby.startNewLibrary() }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .disabled(lobby.busy)
                Text(ProtectionCopy.libraryMissingStartSubline)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
            }
        }
    }

    @ViewBuilder
    private var roads: some View {
        if face.touchIDButton {
            Button {
                Task { await lobby.pressTouchID() }
            } label: {
                Label(ProtectionWords.touchIDButton, systemImage: "touchid")
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            .disabled(lobby.busy)
        }
        if let line = face.touchIDLineWords {
            Text(line)
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        if face.passphraseField {
            VStack(spacing: 8) {
                PeekableSecretField(
                    label: ProtectionWords.passphraseLabel, text: $passphrase,
                    onSubmit: { submitPassphrase() })
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
                Button(ProtectionWords.openButton) { submitPassphrase() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: face.touchIDButton ? .ordinary : .primary))
                    .keyboardShortcut(.defaultAction)
                    .disabled(lobby.busy || passphrase.isEmpty)
            }
        }
        switch face.wordsRoad {
        case .none:
            EmptyView()
        case .field:
            wordsField
        case .disclosure:
            // VX-510 D-B9 (VX-527, her hand: "the words don't open it"): a macOS DisclosureGroup's label is not a control —
            // only its chevron presses — so the label is a Button toggling the same road, as the phone's whole-label door
            // is. The words fill the row and their hit shape reaches over the system row's own spacing (the gap after the
            // chevron, the row's top and bottom), so the chevron and the words are one press target; the chevron, the
            // spacing and the unfolding stay the system's own (pixel-identical, measured offscreen — the run record).
            DisclosureGroup(isExpanded: $showsWords) {
                wordsField.padding(.top, 6)
            } label: {
                Button {
                    withAnimation { showsWords.toggle() }
                } label: {
                    Text(ProtectionWords.wordsDoor)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Self.wordsDoorRowSpacing)
                        .contentShape(Rectangle())
                        .padding(-Self.wordsDoorRowSpacing)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: 340)
        }
    }

    /// VX-510 D-B9 — the system disclosure row's spacing around its label (chevron → label, and the row's top and bottom
    /// margins), measured offscreen on macOS 27: the words door's hit shape reaches this far past the label so the gap
    /// between the chevron and the words presses too. Layout-neutral (the padding is taken back), so nothing moves.
    private static let wordsDoorRowSpacing: CGFloat = 4

    private var wordsField: some View {
        VStack(spacing: 8) {
            // VX-463 (her ruling: "conceal with a reveal eye"): the passphrase's one shared concealing field.
            PeekableSecretField(label: ProtectionWords.wordsPlaceholder, text: $wordsText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 340)
            Button(ProtectionWords.wordsButton) {
                let text = wordsText
                wordsText = ""
                Task { await lobby.unlock(wordsText: text) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens))
            .disabled(lobby.busy || wordsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func submitPassphrase() {
        let typed = passphrase
        passphrase = ""
        Task { await lobby.unlock(passphrase: typed) }
    }
}
