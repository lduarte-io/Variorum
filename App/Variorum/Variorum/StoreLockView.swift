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
//  · The backdrop is `GlyphRainBackdrop` — falling monochrome columns of
//    letters and numbers, the voice's ink over the voice's room, washed
//    back behind the card (17u, 2026-09-25: her ask replaced the item-7
//    tessellating endpaper tile, which she did not like; the asset left
//    the bundle and a pin keeps it out). Pure decoration — nothing here
//    may block an unlock.
//  · The content is a CALM CARD (the W8-2 grammar), placed in the UPPER
//    third — the system Touch ID dialog lands centered on the screen, so
//    the essentials sit above where it appears and are never occluded.
//  · LESS ON SCREEN at first unlock (progressive disclosure): under a
//    Biometric demand only the Touch ID road shows; the passphrase field
//    arrives on demand behind a quiet "use your encryption passphrase
//    instead" word, and the recovery road stays behind its disclosure.
//    Under a Passphrase demand the field is the road and shows directly.
//
//  The biometric demand auto-asks ONCE per lock occasion (that is what
//  "asks every time it opens" means); every sentence is the standing
//  `ProtectionCopy` brain's — no copy changed in the restyle.
//
//  VX-140 (the VX-143 run — her report: the Touch ID sheet over her terminal,
//  "it just keeps appearing"): the automatic ask fires only while Variorum is
//  the ACTIVE app. A lobby that mounts in the background (a relock while she
//  works elsewhere) waits, and asks once when she comes back; the "asked"
//  fact lives on the lobby (`StoreLobby.autoAskSpent`), so a cancel is never
//  followed by another unasked sheet — the button is her road after that.
//

import AppKit
import SwiftUI
import VariorumCore

struct StoreLockView: View {
    @Bindable var lobby: StoreLobby
    /// 13x U2 row 6 — §3.8's second door on the WAITING face ("open an
    /// existing library"): non-nil only where the composition offers it
    /// (the waiting state; never the Castle lobby — P-2).
    var openDoor: (() -> Void)? = nil
    /// VX-140: whether Variorum is the active app RIGHT NOW — the automatic
    /// ask's one input beyond the lobby. Injected so a pin can stand in for
    /// either side; production asks AppKit.
    var appIsActive: () -> Bool = { NSApp.isActive }

    @State private var passphrase = ""
    @State private var recoveryText = ""
    @State private var showsRecoveryRoad = false
    /// Item 7's progressive disclosure: under a BIOMETRIC demand the
    /// passphrase road waits behind one quiet word. Any other demand shows
    /// the field directly (it is the road).
    @State private var passphraseRevealed = false
    @Environment(\.colorScheme) private var scheme

    /// No session exists yet, so the lobby speaks the leading voice.
    private var tokens: VoiceTokens { .fallback(for: scheme) }

    var body: some View {
        ZStack {
            tokens.room.ignoresSafeArea()
            GlyphRainBackdrop(tokens: tokens, scheme: scheme)
                .ignoresSafeArea()
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
        .task {
            // The biometric demand asks as the lobby appears — once per lock
            // occasion, and only in front of her (VX-140): a lobby that
            // mounted in the background asks on her return instead (below).
            // The button re-asks. (The prompt is the mode's whole point.)
            await lobby.autoAskIfDue(appIsActive: appIsActive())
        }
        .onReceive(NotificationCenter.default.publisher(
            for: NSApplication.didBecomeActiveNotification)) { _ in
            // She came back to Variorum: a lobby still holding its one
            // automatic ask spends it now. Spent already (asked, cancelled, or
            // she pressed the button) ⇒ nothing — no re-ask she did not make.
            Task { await lobby.autoAskIfDue(appIsActive: true) }
        }
    }

    private var card: some View {
        VStack(spacing: 14) {
            Image(systemName: lobby.isWaitingForICloudKeychain ? "icloud" : "lock.fill")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(tokens.muted)
            if lobby.isWaitingForICloudKeychain {
                // pre-13x 2a (§3.8) — STANDARD'S WAITING STATE, copy §2d
                // verbatim: the title, the body, and (where iCloud Keychain
                // holds another Apple ID's key) the third sentence.
                Text(ProtectionCopy.waitingTitle)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(lobby.differentAppleID
                     ? ProtectionCopy.waitingDifferentAppleID
                     : ProtectionCopy.waitingBody)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                if !lobby.differentAppleID {
                    HStack(spacing: 6) {
                        TravellingDotsIndicator(ink: tokens.muted)
                        Text("Checking iCloud Keychain…")
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                }
            } else {
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
            }

            if lobby.noRoadExists {
                if !lobby.isWaitingForICloudKeychain { deadEnd }
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
            // pre-13x 4a (copy §3): the offline note, small, after a submit
            // whose vault read failed — never before one.
            if lobby.showsOfflineNote {
                Text(ProtectionCopy.lobbyOfflineNote)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // pre-13x 4a: the phase line (*Unlocking… / Checking your
            // account…*) from ~200 ms into a submit.
            if lobby.busy, lobby.showsProgress {
                HStack(spacing: 6) {
                    // pre-13x 5b (ledger 32): the ceremonies' original indicator.
                    TravellingDotsIndicator(ink: tokens.muted)
                    Text(ProtectionCopy.lobbyPhaseLine(lobby.phase))
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
            // field IS the road and shows directly. The WAITING state's
            // door is copy §2d's "Enter Passphrase…" (P-2: it acts — the
            // same envelope road).
            if lobby.isWaitingForICloudKeychain && !passphraseRevealed {
                Button(ProtectionCopy.waitingPassphraseDoor) {
                    passphraseRevealed = true
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens))
            } else if lobby.demand == .biometric && lobby.biometryOffered && !passphraseRevealed {
                Button(ProtectionCopy.lobbyPassphraseInsteadDoor) {
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
        if let openDoor, lobby.isWaitingForICloudKeychain {
            // 13x U2 row 6: the waiting state's own copy of the door —
            // the same one flow the File menu drives.
            Button(ProtectionCopy.libraryMissingOpenDoor) { openDoor() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .disabled(lobby.busy)
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
                Text(lobby.isWaitingForICloudKeychain
                     ? ProtectionCopy.waitingWordsDoor : ProtectionCopy.lobbyWordsDoor)
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
}

// MARK: - VX-306 U1b — THE NEW ROAD'S LOBBY (Debug, the one switch)

/// The new road's lobby face, rendering `ProtectionLobbyModel` (`notes/plans/vx-306-castle-open-road.md` §2 U1b):
/// the same room and calm card as today's lobby above, on the core's roads. The quiet roads were tried at once
/// before this shows (rule 8), so the typed field shows at once — the passphrase field when the library's key
/// files carry one, the words behind one quiet door beside it (or the words field directly when there is no
/// passphrase); VX-310's Touch ID button and its one line (design §3.10); rule 27's sentence when no road
/// exists at all (its doors are U2's face). It re-reads the roads when Variorum becomes active again (VX-310's
/// second bug — never a relaunch to bring a road back).
struct RoadLockView: View {
    @Bindable var lobby: ProtectionLobbyModel
    /// VX-306 U2 — rule 27's face's *Restore from Backup…*: the app's own Backups folder beside the library, revealed
    /// (the missing face's road); nil: none to show, the door does not render (P-2).
    var backupsFolder: URL? = nil
    /// VX-306 U2 — rule 27's face's *Open Library…* (13x's open door, the missing face's); nil: not rendered.
    var openDoor: (() -> Void)? = nil
    /// VX-140: whether Variorum is the active app RIGHT NOW — the automatic ask's one input beyond the lobby.
    var appIsActive: () -> Bool = { NSApp.isActive }

    /// The app's own Backups folder beside the library — the missing face's rule (`LibraryMissingLobby
    /// .backupsFolderURL`), named by the catalogue's one name for it (the ladder's round-1 NIT 1): nil when there is none.
    static func backupsFolder(besideStore storeURL: URL) -> URL? {
        let folder = storeURL.deletingLastPathComponent()
            .appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
        return FileManager.default.fileExists(atPath: folder.path) ? folder : nil
    }

    @State private var passphrase = ""
    @State private var wordsText = ""
    @State private var showsWords = false
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
            Text(ProtectionWords.lobbyTitle)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if let nothing = face.noKeyFileAnywhere {
                // RULE 27 before unlock — §7c (3), the account sentence only when the account road is named, and
                // the missing face's three doors beneath (VX-306 U2).
                sentence(ProtectionWords.noKeyFileAnywhere)
                if nothing.accountRoad { sentence(ProtectionWords.noKeyFileAnywhereAccountRoad) }
                noKeyFileDoors
            } else {
                sentence(face.keychainUnreadable ? ProtectionWords.keychainUnreadable : face.lead)
                roads
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
                    Text(ProtectionWords.opening)
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
        if let backupsFolder {
            Button(ProtectionWords.noKeyFileRestoreDoor) {
                NSWorkspace.shared.activateFileViewerSelecting([backupsFolder])
            }
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
            DisclosureGroup(isExpanded: $showsWords) {
                wordsField.padding(.top, 6)
            } label: {
                Text(ProtectionWords.wordsDoor)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: 340)
        }
    }

    private var wordsField: some View {
        VStack(spacing: 8) {
            TextField(ProtectionWords.wordsPlaceholder, text: $wordsText, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
                .autocorrectionDisabled()
                .privacySensitive()
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
