//
//  MobileProtectionScreen.swift
//  VariorumMobile
//
//  VM-8 unit 1 — THE PHONE'S PROTECTION SCREEN, minimal unit-1 form (PROVISIONAL P-VM8-2; the run record
//  `notes/plans/vm-8-castle-catchup.md`, THE UNITS ▸ UNIT 1 piece 2). Settings ▸ Protection — the Mac's information
//  architecture, the phone's navigation (a room pushed on the shelf's stack, the settings-sheet grammar) — carrying ONLY
//  the Sync/account section this unit: the faces are the SHARED values `assess` reads (`RoadAccountFaces`, the brain
//  `RoadAccountModel`, the one presenter `ProtectionSheetPresenter` — all the bootstrap's, kept across every reopen),
//  rendered in the phone's voice. Nothing here decides; every door renders only where it can act (P-2):
//
//    - the situation in words; the follow's durable Done (VX-457) with its OK; the follow door only where `assess`
//      offers it; Turn on sync both arms (the set-up's "Turn on sync…", the JOIN's "Sync this library…" — P-VX510-3);
//      the three local leaves; Move; *Sign in…* (the app's Account sheet) and *Sign out…* (today's shipped confirm).
//    - F-U1-1, RULED (A): an arm whose confirm says HER rule-12 leave sentence (`RoadAccountDoorOpen.saysRuleTwelve` —
//      the Castle-leaving join, Move and the follow out of Castle) is NOT rendered here: its words name the Mac and their
//      phone wording is hers (F-PH-2). Unit 2 builds them.
//    - THE SHEETS, through the one presenter on its `.settings` host (the phone has one host — this screen): an account
//      door's confirm (exactly the door's fields, the Face ID gate choice into Castle, rule 7's words moment, and the
//      FIRST ROUND that stays to confirm — P-VX510-1's shape, its line the sync row's own sentence, Done always open and
//      never cancelling the round), the sign-out confirm, the Account sheet.
//    - F-U1-3: a RE-KEYING act (her phone's join — a Standard library into her Castle account) reopens the library, so
//      the `.ready` tree — this screen with it — goes down under the confirm. The confirm lives on in the presenter; the
//      shell adopts `ProtectionController.settingsRequest` (VX-206's road, which the reopen asks) and pushes this screen
//      again, which presents the standing sheet again.
//

import SwiftUI
import VariorumCore

// MARK: - The screen

struct MobileProtectionScreen: View {
    /// The open library's protection faces (nil while no library is open on the road — nothing renders).
    let standing: RoadStandingModel?
    let services: AppServices?
    let tokens: VoiceTokens

    /// VM-8 unit 2 — F-U2-E (PROVISIONAL P-VM8-8): the receipts the open library's faces spoke on the phone (the shell's
    /// holder; nil — a host with no shell — says none).
    @Environment(MobileProtectionReceipts.self) private var receipts: MobileProtectionReceipts?
    /// VM-8 unit 2: the set-passphrase sheet (the screen's own — never the one presenter's, the Mac pane's precedent).
    @State private var setSheet: SetPassphraseModel?
    /// VM-8 unit 2: New words' look, held here so the screen keeps its way back while it holds words (the Mac's "a host
    /// keeps its other doors back meanwhile — closing them would put the words away without the warning").
    @State private var wordsLook: WordsLookModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(tokens.path([ProtectionCopy.protectionPaneTitle]))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                // F-U2-E (P-VM8-8): what the protection acts said — one muted line, under the title.
                if let receipts, !receipts.lines.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(receipts.lines.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                if let standing {
                    // VM-8 unit 2 — the Mac pane's order: the passphrase (the set row or the key doors), the words, the check,
                    // the crossings, then the account.
                    MobilePassphraseSection(standing: standing, tokens: tokens, setSheet: $setSheet)
                    if standing.band != nil {
                        MobileWordsSection(standing: standing, tokens: tokens, look: $wordsLook)
                    }
                    if let keyDoors = standing.keyDoors {
                        MobileRoadSecretCheckDoor(model: keyDoors, tokens: tokens)
                    }
                    if let crossings = standing.crossings {
                        Divider().overlay(tokens.line)
                        MobileRoadCrossingsSection(model: crossings, tokens: tokens)
                    }
                }
                if let account = standing?.account {
                    Divider().overlay(tokens.line)
                    MobileRoadAccountSection(model: account, tokens: tokens)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        // New words' look holds the words on screen: no way back until her close (past the look's warning).
        .navigationBarBackButtonHidden(wordsLook?.holdsWords == true)
        // The section's faces re-read at each appearance (an act's reopen rebuilds this screen) — the pane's one read.
        .task { await standing?.refreshPane() }
        .onDisappear { receipts?.screenLeft() }
        .modifier(MobileProtectionSheetsHost(presenter: standing?.sheets, services: services, tokens: tokens))
        .background {
            // The set-passphrase sheet rides its own anchor (one `.sheet` per view — the presenter's host is the screen's).
            Color.clear.sheet(item: $setSheet) { model in
                MobileSetPassphraseSheet(model: model, tokens: tokens)
                    .presentationDetents([.large])
            }
        }
    }
}

// MARK: - The account section

struct MobileRoadAccountSection: View {
    @Bindable var model: RoadAccountModel
    let tokens: VoiceTokens

    var body: some View {
        if let faces = model.faces {
            VStack(alignment: .leading, spacing: 10) {
                Text(tokens.chromeLabel(ProtectionWords.accountSectionTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                situation(faces)
                // VX-457: the follow's Done — a durable notice until her OK.
                if let followed = model.followDone {
                    VStack(alignment: .leading, spacing: 6) {
                        line(ProtectionWords.followDoneNotice(followed), ink: tokens.ink)
                        door(ProtectionWords.followDoneOK) { model.followDoneOK() }
                    }
                }
                // VX-308 U2 (R-U2-1): the follow first — the account moved on another device; its notice beside its door.
                doorRow(.follow, faces.follow)
                ForEach(RoadAccountDoor.allCases.filter { $0 != .follow }) { door in
                    doorRow(door, faces.face(door))
                }
                if faces.signIn {
                    door(ProtectionWords.accountSignInDoor) { model.openSignIn() }
                }
                if model.offersSignOut {
                    door(ProtectionWords.accountSignOutDoor) { model.openSignOut() }
                }
            }
        }
    }

    @ViewBuilder
    private func situation(_ faces: RoadAccountFaces) -> some View {
        switch faces.situation {
        case .localOnly:
            line(ProtectionWords.accountLocalOnly, ink: tokens.ink)
        case .inSync(let email):
            line(ProtectionWords.accountInSync, ink: tokens.ink)
            if let email { caption(ProtectionWords.accountSignedInAs(email)) }
        case .signedOut:
            line(ProtectionWords.accountSignedOut, ink: tokens.ink)
            caption(ProtectionWords.accountSignedOutLine)
        case .otherAccount(let email, let sameEmail):
            line(ProtectionWords.accountOtherAccount, ink: tokens.ink)
            if let email { caption(ProtectionWords.accountSignedInAs(email)) }
            caption(ProtectionWords.accountOtherAccountLine)
            if sameEmail { caption(ProtectionWords.accountSameEmailDifferentAccount) }
        }
        if faces.vaultUnreachable { caption(ProtectionWords.doorRefusedNeedsVault) }
    }

    /// One door as `assess` says it — hidden renders nothing (P-2); refused / not yet says its sentence in its place; open
    /// renders its notice and its door. F-U1-1 (A): an open arm saying her rule-12 sentence renders NOTHING here.
    @ViewBuilder
    private func doorRow(_ door: RoadAccountDoor, _ face: RoadAccountDoorFace) -> some View {
        switch face {
        case .hidden:
            EmptyView()
        case .refused(let sentence), .notYet(let sentence):
            caption(sentence)
        case .open(let open) where open.saysRuleTwelve:
            EmptyView()
        case .open(let open):
            VStack(alignment: .leading, spacing: 6) {
                if let notice = open.notice { line(notice, ink: tokens.ink) }
                self.door(open.doorLabel) { model.open(door) }
            }
        }
    }

    private func door(_ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(tokens.chromeLabel(label))
                .font(tokens.body)
                .foregroundStyle(tokens.accent)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .disabled(model.presenter.sheet != nil)
    }

    private func line(_ text: String, ink: Color) -> some View {
        Text(text)
            .font(tokens.body)
            .foregroundStyle(ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - THE ONE PRESENTER's phone host

/// Presents the presenter's standing sheet on its `.settings` host — this screen, the phone's only one (VX-243: never two
/// presentations); the host's dismissal is the sheet's own way out (a running act keeps its sheet).
struct MobileProtectionSheetsHost: ViewModifier {
    let presenter: ProtectionSheetPresenter?
    let services: AppServices?
    let tokens: VoiceTokens

    func body(content: Content) -> some View {
        content.sheet(item: Binding(
            get: { presenter?.sheet(for: .settings) },
            set: { if $0 == nil { presenter?.hostDismissed(.settings) } })
        ) { sheet in
            switch sheet {
            case .account(let model):
                MobileRoadAccountConfirmSheet(model: model, tokens: tokens)
            case .signOut(let model):
                MobileRoadSignOutSheet(model: model, tokens: tokens)
            case .signIn:
                if let services {
                    // The app's one sign-in surface (R-5), in the phone's page style (the sync row's own injection).
                    AccountView(services: services, initialTab: .account)
                        .environment(\.sharedPageStyle, SharedPageStyle(tokens: tokens))
                } else {
                    MobileProtectionSheetNotHere(presenter: presenter, tokens: tokens, sentence: ProtectionWords.signInUnavailable)
                }
            // VM-8 unit 2: the crossings' confirm, the signed-out road's screen, a key door's confirm, the check.
            case .crossing(let model):
                MobileRoadCrossingConfirmSheet(model: model, tokens: tokens)
            case .signedOutCastle(let model):
                MobileRoadSignedOutCastleSheet(model: model, tokens: tokens)
            case .keyDoor(let model):
                MobileRoadKeyDoorConfirmSheet(model: model, tokens: tokens)
            case .checkSecrets(let model):
                MobileRoadSecretCheckSheet(model: model, tokens: tokens)
            }
        }
    }
}

/// A sheet this screen cannot host (never reached by a door here): the host's dismissal at once, or — the sign-in sheet
/// with no services, the Mac's NIT-1 face — its one true sentence with Close.
private struct MobileProtectionSheetNotHere: View {
    let presenter: ProtectionSheetPresenter?
    let tokens: VoiceTokens
    let sentence: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let sentence {
                Text(sentence)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                MobileRoadButton(title: ProtectionWords.signInUnavailableClose, tokens: tokens) {
                    presenter?.hostDismissed(.settings)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .presentationDetents([.medium])
        .background(tokens.room.ignoresSafeArea())
        .onAppear {
            guard sentence == nil else { return }
            ProtectionOpenRoad.log("road: the phone's Protection screen was asked for a sheet it has no door for — closed")
            presenter?.hostDismissed(.settings)
        }
    }
}

// MARK: - An account door's confirm (the phone's face of `RoadAccountConfirmModel`)

struct MobileRoadAccountConfirmSheet: View {
    @Bindable var model: RoadAccountConfirmModel
    let tokens: VoiceTokens

    @State private var passphrase = ""
    @State private var again = ""
    @State private var words = ""

    /// Her sentences these confirms say — the primary ink (rule 16's, rule 9's promise; rule 12's never renders here).
    private static let hers: Set<String> = [ProtectionWords.ruleSixteen, ProtectionWords.castlePromise]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(tokens.chromeLabel(model.title))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                if let moment = model.moment {
                    wordsMoment(moment)
                } else if let round = model.round {
                    // VX-510 D-A2 (VX-507): the act landed — the sheet confirms its first round, or says what blocks it.
                    firstRound(round)
                } else {
                    confirm
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(tokens.room.ignoresSafeArea())
        // VX-308 U2: the words moment closes only past her warning (or its OK) — a stray swipe never puts them away; a
        // running act keeps its sheet. In the round phase a swipe IS Done (the model's `cancel()` — the round goes on).
        .interactiveDismissDisabled(model.busy || model.moment != nil)
    }

    @ViewBuilder
    private var confirm: some View {
        ForEach(Array(model.door.sentences.enumerated()), id: \.offset) { _, sentence in
            Text(sentence)
                .font(tokens.body)
                .foregroundStyle(Self.hers.contains(sentence) ? tokens.ink : tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            if sentence == ProtectionWords.copiesUnderAKeyThisMacCantDelete {
                ForEach(model.door.undeletableCopies, id: \.self) { copy in
                    Text("\u{2022} \(copy)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
        }
        if let gate = model.door.gate {
            MobileGateChoice(gate: gate, selection: $model.gate, busy: model.busy, tokens: tokens)
        }
        fields
        if let refusal = model.refusal {
            Text(refusal)
                .font(tokens.small)
                .foregroundStyle(tokens.alarm)
                .fixedSize(horizontal: false, vertical: true)
        }
        if model.busy {
            HStack(spacing: 6) {
                TravellingDotsIndicator(ink: tokens.muted)
                Text(tokens.chromeLabel(ProtectionWords.accountWorking))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        HStack(spacing: 16) {
            MobileRoadButton(title: ProtectionWords.accountCancel, tokens: tokens) { model.cancel() }
                .disabled(model.busy)
            MobileRoadButton(title: model.button, tokens: tokens) { submit() }
                .disabled(!model.canSubmit(passphrase: passphrase, again: again, words: words))
        }
        .padding(.top, 4)
    }

    /// Exactly the fields the door's ask names (turning sync on: both; a leave and the follow out: none; a join, Move and
    /// the follow: ONE secret — rule 14 — either field).
    @ViewBuilder
    private var fields: some View {
        let ask = model.door.ask
        if ask == .oneSecret {
            let follows = model.door.door == .follow
            styled(PeekableSecretField(
                label: follows ? ProtectionWords.followPassphraseField : ProtectionWords.joinPassphraseField,
                text: $passphrase))
            // VX-463: the twelve words conceal like the passphrase, with the same reveal eye.
            styled(PeekableSecretField(
                label: follows ? ProtectionWords.followWordsField : ProtectionWords.joinWordsField, text: $words,
                onSubmit: submit))
        }
        if ask.asksPassphrase {
            if model.asksNewPassphrase {
                Text(ProtectionWords.turnOnSyncNewPassphraseLead)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                styled(PeekableSecretField(label: ProtectionWords.crossingNewPassphraseField, text: $passphrase))
                // VM-8 unit 2 — F-U2-C (VX-211): the quiet strength hint beneath a passphrase being SET.
                MobilePassphraseHintLine(passphrase: passphrase, tokens: tokens)
                styled(PeekableSecretField(label: ProtectionWords.crossingNewPassphraseAgain, text: $again))
            } else {
                styled(PeekableSecretField(label: ProtectionWords.crossingPassphraseField, text: $passphrase))
            }
        }
        if ask.asksWords {
            // VX-463: the twelve words conceal like the passphrase, with the same reveal eye.
            styled(PeekableSecretField(label: ProtectionWords.crossingWordsField, text: $words, onSubmit: submit))
        }
    }

    /// The lobby's field idiom (`MobileRoadLockView`): a quiet card around the shared concealing field.
    private func styled(_ field: PeekableSecretField) -> some View {
        field.mobileSecretFieldChrome(tokens)
    }

    /// RULE 7's WORDS MOMENT (VX-308 U2, R-U2-5): the words she typed, shown once over the one look under her sentence;
    /// the passphrase typed — the notice that they were replaced, nothing shown (P-VX378-U2-3 (a)).
    @ViewBuilder
    private func wordsMoment(_ moment: RoadJoinWordsMoment) -> some View {
        switch moment {
        case .shown(let look):
            Text(ProtectionWords.joinWordsSentence)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            MobileWordsLookPanel(look: look, tokens: tokens)
        case .notShown:
            // VX-309 U2: her draft — the library adopts the account's words, the account named by its email.
            Text(ProtectionWords.joinWordsNotShown(model.door.accountEmail))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            MobileRoadButton(title: ProtectionWords.joinWordsMomentOK, tokens: tokens) { model.closeMoment() }
        }
    }

    /// VX-510 D-A2 — THE FIRST ROUND (VX-507): while it runs, the progress and why closing is fine; when it comes back, the
    /// success line or what blocks it in the sync row's own words (an error face's cause note beneath, as the row shows
    /// it). Done — the one door, open throughout — closes the sheet and never cancels the round (P-VX510-1).
    @ViewBuilder
    private func firstRound(_ round: FirstRoundPhase) -> some View {
        switch round {
        case .running:
            HStack(spacing: 8) {
                TravellingDotsIndicator(ink: tokens.muted)
                Text(ProtectionWords.firstRoundProgress)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            closeNote
        case .done:
            if let line = model.roundLine {
                Text(line)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                // VX-510 ladder round 2, F-R2-2: a settle past the bound freezes the progress words as the outcome — the
                // close note stays with them, so the face still says the road forward.
                if line == ProtectionWords.firstRoundProgress { closeNote }
            }
            if let cause = model.roundErrorCause {
                ErrorCauseNote(error: cause)
                    .font(tokens.small)
            }
        }
        // VX-529 unit 2 (R-529-5): the pair catch-up landed by the twelve words — the window and the Reset chain.
        ForEach(Array(model.landedLines.enumerated()), id: \.offset) { _, line in
            Text(line)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        MobileRoadButton(title: ProtectionWords.firstRoundDone, tokens: tokens) { model.done() }
            .padding(.top, 4)
    }

    private var closeNote: some View {
        Text(ProtectionWords.firstRoundCloseNote)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func submit() {
        let typedPassphrase = passphrase
        let typedAgain = again
        let typedWords = words
        Task { await model.submit(passphrase: typedPassphrase, again: typedAgain, words: typedWords) }
    }
}

// MARK: - The words, once (the phone's face of `WordsLookModel` — the join's moment)

/// The look's shown words: "write these down now", the two numbered columns (never selectable, privacy-sensitive — the
/// snapshot cover redacts them), and the close behind her warning. NO Copy door: the phone has no words clipboard road
/// (the bootstrap's `copyWords` is the Mac's alone — P-2).
struct MobileWordsLookPanel: View {
    @Bindable var look: WordsLookModel
    let tokens: VoiceTokens

    @State private var passphrase = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch look.phase {
            case .closed:
                EmptyView()
            case .asking:
                // VM-8 unit 2 — New words through the look (rule 6: new words ask the passphrase where one exists; F-U2-3:
                // a synced library hears first that new words replace the account's — her *Show my twelve words* the yes).
                // The join's moment never asks (its look is the typed words).
                asking
            case .minting:
                HStack(spacing: 8) {
                    TravellingDotsIndicator(ink: tokens.muted)
                    Text(ProtectionWords.wordsLookMinting)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            case .shown, .warning:
                Text(ProtectionWords.wordsLookLead)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if look.saysRuleSix {
                    Text(ProtectionWords.wordsLookRuleSix)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                columns
                if look.phase == .warning {
                    Text(ProtectionWords.wordsLookWarning)
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                    HStack(spacing: 16) {
                        MobileRoadButton(title: ProtectionWords.wordsLookGoBack, tokens: tokens) { look.goBack() }
                        MobileRoadButton(title: ProtectionWords.wordsLookClose, tokens: tokens) { look.close() }
                    }
                } else {
                    MobileRoadButton(title: ProtectionWords.wordsLookWrittenDown, tokens: tokens) { look.writtenDown() }
                }
            }
            if let message = look.message, look.phase != .closed {
                Text(message)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var asking: some View {
        VStack(alignment: .leading, spacing: 10) {
            if look.saysAccountWords {
                Text(ProtectionWords.wordsLookReplacesAccountWords)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(ProtectionWords.wordsLookAsk)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            PeekableSecretField(label: ProtectionWords.wordsLookPassphraseField, text: $passphrase, onSubmit: submit)
                .mobileSecretFieldChrome(tokens)
            HStack(spacing: 16) {
                MobileRoadButton(title: ProtectionWords.wordsLookCancel, tokens: tokens) {
                    passphrase = ""
                    look.cancel()
                }
                MobileRoadButton(title: ProtectionWords.wordsLookShow, tokens: tokens) { submit() }
                    .disabled(passphrase.isEmpty)
            }
        }
    }

    private func submit() {
        let typed = passphrase
        passphrase = ""
        Task { await look.submit(passphrase: typed) }
    }

    private var columns: some View {
        HStack(alignment: .top, spacing: 28) {
            ForEach(Array(look.columns.enumerated()), id: \.offset) { _, column in
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
    }
}

// MARK: - Sign out (today's shipped confirm)

struct MobileRoadSignOutSheet: View {
    @Bindable var model: RoadSignOutModel
    let tokens: VoiceTokens

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(tokens.chromeLabel(ProtectionWords.accountSignOutTitle))
                .font(tokens.title)
                .foregroundStyle(tokens.ink)
            Text(ProtectionWords.accountSignOutBody)
                .font(tokens.body)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                MobileRoadButton(title: ProtectionWords.accountCancel, tokens: tokens) { model.cancel() }
                    .disabled(model.busy)
                if model.busy { TravellingDotsIndicator(ink: tokens.muted) }
                MobileRoadButton(title: ProtectionWords.accountSignOutButton, tokens: tokens) {
                    Task { await model.confirm() }
                }
                .disabled(model.busy)
            }
        }
        .padding(22)
        // The voice's room fills the whole sheet (the walk's C05: a natural-height card left the system's grey above and
        // below it at the medium detent).
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .presentationDetents([.medium])
        .background(tokens.room.ignoresSafeArea())
        .interactiveDismissDisabled(model.busy)
    }
}
