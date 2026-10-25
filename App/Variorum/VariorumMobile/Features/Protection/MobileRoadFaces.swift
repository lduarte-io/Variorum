//
//  MobileRoadFaces.swift
//  VariorumMobile
//
//  VX-306 U3 — THE PHONE OPENS ON THE NEW ROAD (`notes/plans/vx-306-castle-open-road.md` §2 U3 + its addendum; the
//  switch on in the phone's Debug build, P-VX306-U1b-1 superseded). The phone's minimum, over the SAME shared brains
//  the Mac's faces render (`ProtectionLobbyModel`, `LibraryWordsCardModel`, `RoadInterludeModel`, `RoadStandingFaces`),
//  in the SAME words (`ProtectionWords` — the biometry and the device named as the phone's own, P-VX306-U3-8) and the
//  phone's own layout and voice (the DEVICE voice preference — the store is exactly what is not open yet):
//    - THE LOBBY (`MobileRoadLockView`): the typed field at once (the quiet roads were tried before it showed — rule 8),
//      the passphrase field when the library's key files carry one with the words behind one quiet door, or the words
//      field directly; the biometry button and its one line (VX-310's rule, the face's); the refusal line; RULE 27's
//      sentence before unlock (the account sentence when the account road is named) with *Start a New Library* (the
//      phone keeps no backups and has no Open Library door — the Mac's other two doors are not the phone's).
//    - THE ONCE-SHOWN WORDS CARD (`MobileLibraryWordsCard`, rule 2; §7c (1)): the title, the lead, the twelve words
//      numbered in two columns (never selectable, privacy-sensitive — the snapshot cover redacts them), the foot, ONE
//      button.
//    - THE INTERLUDE (`MobileRoadInterludeCard`, rule 21): her notice once with *OK*, then the key-file offer with *Not
//      now* · *Use it*.
//    - RULE 27 AFTER A QUIET OPEN (`MobileNoKeyFileSheet`): her U2-7 sentence (VX-414 — *Variorum opened your library,
//      but found no key file for it anywhere. …*) as a sheet over the open library, once per open, no doors (nothing
//      rebuilds a key file from the key). The lobby's moment keeps §7c (3)'s refusal.
//  Rule 3's reminder and the receipts have no phone face this unit (the record's hand-forward).
//

import SwiftUI
import VariorumCore

// MARK: - The lobby

struct MobileRoadLockView: View {
    @Bindable var lobby: ProtectionLobbyModel
    let tokens: VoiceTokens

    @Environment(\.scenePhase) private var scenePhase
    @State private var passphrase = ""
    @State private var wordsText = ""
    @State private var showsWords = false
    /// VM-8 unit 1 — *Start fresh…* asks her confirm first (her line, the vx-329 plan's §6d; the Mac's `RoadLockView`).
    @State private var confirmsStartFresh = false

    private var face: ProtectionLobbyFace { lobby.face }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(tokens.muted)
                if face.preDesignStore {
                    // VM-8 unit 1 (F-U4-2) — RULE 26 before unlock: a store from before this design (its key files' names
                    // alone say so). HER face, her words only — the lead heading the card (no lobby title — P-VX329-U4-1),
                    // her body, *Start fresh…* with her confirm first. NO *Open Library…* on the phone: it has no picker road
                    // (the standing lobby's precedent — PROVISIONAL P-VM8-1).
                    preDesignFace
                } else {
                    standingLobby
                }
                if face.liveKeyFileUnreadable { alarm(ProtectionWords.liveKeyFileUnreadable) }
                if let message = lobby.message { alarm(message) }
                if lobby.busy {
                    HStack(spacing: 6) {
                        TravellingDotsIndicator(ink: tokens.muted)
                        // Under her pre-design face nothing is opening (Start fresh… is running): the dots alone, no words
                        // beyond hers (the Mac's own rule).
                        if !face.preDesignStore {
                            Text(tokens.chromeLabel(ProtectionWords.opening))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room.ignoresSafeArea())
        // VM-8 unit 1 — *Start fresh…*'s confirm: her line (the vx-329 plan's §6d); the act runs only on its yes.
        .alert(ProtectionWords.preDesignStartFreshConfirm, isPresented: $confirmsStartFresh) {
            Button(ProtectionWords.preDesignStartFreshButton) {
                Task { await lobby.startFresh() }
            }
            Button(ProtectionWords.accountCancel, role: .cancel) {}
        }
        .task { await lobby.autoAskIfDue(appIsActive: scenePhase == .active) }
        .onChange(of: scenePhase) { _, phase in
            // VX-310's second bug, the phone's twin: the roads are re-read when she comes back to the app.
            guard phase == .active else { return }
            Task {
                await lobby.refresh()
                await lobby.autoAskIfDue(appIsActive: true)
            }
        }
    }

    /// VM-8 unit 1 — her pre-design face (the Mac's `RoadLockView` branch, the phone's room): her lead, her body, and
    /// *Start fresh…* only where it can act (P-2 — `offersStartFresh`: the fact AND a wired act).
    @ViewBuilder
    private var preDesignFace: some View {
        Text(ProtectionWords.preDesignLead)
            .font(tokens.title)
            .foregroundStyle(tokens.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        sentence(ProtectionWords.preDesignBody)
        if lobby.offersStartFresh {
            MobileRoadButton(title: ProtectionWords.preDesignStartFreshDoor, tokens: tokens) { confirmsStartFresh = true }
                .disabled(lobby.busy)
        }
    }

    /// The lobby as it stands for every slot but a pre-design one (unchanged from VX-306 U3).
    @ViewBuilder
    private var standingLobby: some View {
                Text(tokens.chromeLabel(ProtectionWords.lobbyTitle))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.center)
                if let nothing = face.noKeyFileAnywhere {
                    sentence(ProtectionWords.noKeyFileAnywhere)
                    if nothing.accountRoad { sentence(ProtectionWords.noKeyFileAnywhereAccountRoad) }
                    if lobby.offersStartNew {
                        VStack(spacing: 6) {
                            MobileRoadButton(title: ProtectionWords.noKeyFileStartDoor, tokens: tokens) {
                                Task { await lobby.startNewLibrary() }
                            }
                            .disabled(lobby.busy)
                            Text(ProtectionCopy.libraryMissingStartSubline)
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    sentence(face.keychainUnreadable ? ProtectionWords.keychainUnreadable : face.lead)
                    // VX-529 unit 2 — E6 (R-529-6: the why and the road): the shared lobby face's line beneath the lead
                    // (the Mac's `RoadLockView` says it; the phone rendered the field without its why until VM-8).
                    if let line = face.accountPassphraseLine { sentence(line) }
                    roads
                }
    }

    @ViewBuilder
    private var roads: some View {
        if face.touchIDButton {
            MobileRoadButton(title: ProtectionWords.touchIDButton, systemImage: "faceid", tokens: tokens) {
                Task { await lobby.pressTouchID() }
            }
            .disabled(lobby.busy)
        }
        if let line = face.touchIDLineWords {
            Text(line)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        if face.passphraseField {
            VStack(spacing: 10) {
                PeekableSecretField(label: ProtectionWords.passphraseLabel, text: $passphrase, onSubmit: { submitPassphrase() })
                    .submitLabel(.go)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                    .background(field)
                MobileRoadButton(title: ProtectionWords.openButton, tokens: tokens) { submitPassphrase() }
                    .disabled(lobby.busy || passphrase.isEmpty)
            }
        }
        switch face.wordsRoad {
        case .none:
            EmptyView()
        case .field:
            wordsField
        case .disclosure:
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    showsWords.toggle()
                } label: {
                    Text(tokens.chromeLabel(ProtectionWords.wordsDoor))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                if showsWords { wordsField }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var wordsField: some View {
        VStack(spacing: 10) {
            // VX-463 (her ruling: "conceal with a reveal eye"): the passphrase's one shared concealing field.
            PeekableSecretField(label: ProtectionWords.wordsPlaceholder, text: $wordsText)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                .background(field)
            MobileRoadButton(title: ProtectionWords.wordsButton, tokens: tokens) {
                let text = wordsText
                wordsText = ""
                Task { await lobby.unlock(wordsText: text) }
            }
            .disabled(lobby.busy || wordsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var field: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tokens.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    private func sentence(_ text: String) -> some View {
        Text(text)
            .font(tokens.body)
            .foregroundStyle(tokens.muted)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func alarm(_ text: String) -> some View {
        Text(text)
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

// MARK: - The once-shown words card (rule 2)

struct MobileLibraryWordsCard: View {
    let model: LibraryWordsCardModel
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "key")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(tokens.muted)
                Text(tokens.chromeLabel(ProtectionWords.wordsCardTitle))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Text(ProtectionWords.wordsCardLead)
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 28) {
                    ForEach(Array(model.columns.enumerated()), id: \.offset) { _, column in
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(column, id: \.number) { entry in
                                HStack(spacing: 8) {
                                    Text("\(entry.number)")
                                        .font(tokens.mono)
                                        .foregroundStyle(tokens.muted)
                                        .frame(minWidth: 20, alignment: .trailing)
                                    Text(entry.word)
                                        .font(tokens.mono)
                                        .foregroundStyle(tokens.ink)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
                .textSelection(.disabled)
                .privacySensitive()
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 10).fill(tokens.card))
                Text(ProtectionWords.wordsCardFoot)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                MobileRoadButton(title: ProtectionWords.wordsCardButton, tokens: tokens) { model.iveWrittenThemDown() }
                    .disabled(model.words.isEmpty)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room.ignoresSafeArea())
    }
}

// MARK: - The interlude (rule 21)

struct MobileRoadInterludeCard: View {
    @Bindable var model: RoadInterludeModel
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: isOffer ? "key" : "info.circle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(tokens.muted)
                if let sentence = model.sentence {
                    Text(sentence)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                switch model.current {
                case .notice?:
                    MobileRoadButton(title: ProtectionWords.noticeOK, tokens: tokens) { model.ok() }
                case .offer?:
                    HStack(spacing: 16) {
                        MobileRoadButton(title: ProtectionWords.offerNotNow, tokens: tokens) { model.notNow() }
                            .disabled(model.busy)
                        MobileRoadButton(title: ProtectionWords.offerUseIt, tokens: tokens) { Task { await model.useIt() } }
                            .disabled(model.busy)
                    }
                case .rearm?:
                    // VX-307 U2a — the shared re-arm card (the Mac's twin; reachable only once the phone enters Castle).
                    if model.rearmFailed {
                        MobileRoadButton(title: ProtectionWords.noticeOK, tokens: tokens) { model.ok() }
                    } else {
                        HStack(spacing: 16) {
                            MobileRoadButton(title: ProtectionWords.rearmNo, tokens: tokens) {
                                Task { await model.rearm(yes: false) }
                            }
                            .disabled(model.busy)
                            MobileRoadButton(title: ProtectionWords.rearmYes, tokens: tokens) {
                                Task { await model.rearm(yes: true) }
                            }
                            .disabled(model.busy)
                        }
                    }
                case nil:
                    EmptyView()
                }
                if let message = model.message {
                    Text(message)
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if model.busy { TravellingDotsIndicator(ink: tokens.muted) }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 48)
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room.ignoresSafeArea())
    }

    private var isOffer: Bool {
        if case .offer? = model.current { return true }
        return false
    }
}

// MARK: - Rule 27 after a quiet open (a sheet, once per open)

struct MobileNoKeyFileSheet: View {
    let accountRoad: Bool
    let tokens: VoiceTokens
    let close: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(tokens.muted)
            Text(ProtectionWords.noKeyFileAfterAQuietOpen)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            if accountRoad {
                Text(ProtectionWords.noKeyFileAnywhereAccountRoad)
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            MobileRoadButton(title: ProtectionWords.noticeOK, tokens: tokens) { close() }
        }
        .padding(28)
        .presentationDetents([.medium])
        .background(tokens.room.ignoresSafeArea())
    }
}

/// The phone's calm button for these faces (the lobby's own idiom: the accent on a quiet card).
struct MobileRoadButton: View {
    let title: String
    var systemImage: String?
    let tokens: VoiceTokens
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(tokens.chromeLabel(title), systemImage: systemImage)
                } else {
                    Text(tokens.chromeLabel(title))
                }
            }
            .font(tokens.body)
            .foregroundStyle(tokens.accent)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tokens.surface)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
