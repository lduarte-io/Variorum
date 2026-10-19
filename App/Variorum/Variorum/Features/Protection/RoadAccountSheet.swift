//
//  RoadAccountSheet.swift
//  Variorum
//
//  VX-308 U1 piece 6 — THE ACCOUNT SECTION'S MAC FACES on the new road (`notes/plans/vx-308-accounts-key-doors.md` §5a and
//  its U1 ARBITRATION; rules 7, 14, 16):
//
//    - `RoadAccountSection` (Settings ▸ Protection, beneath the crossings): the situation in words, each door `assess`
//      opens (a refused one says why in its place; one with no act here renders nothing — P-2; one road per situation),
//      VX-308 U2's follow first (its notice beside its door — R-U2-1) and the join and Move as their own doors (Move's
//      no-vault arm its not-yet line), *Sign in…* where no one is signed in, *Sign out…* where someone is.
//    - The sheets, all presented through THE ONE PRESENTER (`ProtectionSheetsHost` — VX-239 + VX-243): an account door's
//      confirm (turning sync on asks exactly its fields; a leave asks nothing and says rule 16; VX-308 U2 — a join, Move and
//      the follow ask ONE secret, into Castle with the gate choice, rule 25's copies named; after a join whose words were
//      replaced, rule 7's WORDS MOMENT — the typed words over `WordsLookPanel`, or the notice alone), today's sign-out
//      confirm, the signed-out screen for Use Castle (drafted to the current rules), the crossings' confirm (VX-307 U2a's
//      sheet, unchanged), and the app's Account sheet for *Sign in…* (R-5).
//

import SwiftUI
import VariorumCore

// MARK: - The section

/// Settings ▸ Protection on the new road: the account's situation and its doors.
struct RoadAccountSection: View {
    @Bindable var model: RoadAccountModel

    var body: some View {
        if let faces = model.faces {
            Section(ProtectionWords.accountSectionTitle) {
                situation(faces)
                // VX-308 U2 (R-U2-1): the follow first — the account moved on another device; its notice beside its door.
                doorRow(.follow, faces.follow)
                ForEach(RoadAccountDoor.allCases.filter { $0 != .follow }) { door in
                    doorRow(door, faces.face(door))
                }
                if faces.signIn {
                    HStack {
                        Button(ProtectionWords.accountSignInDoor) { model.openSignIn() }
                            .disabled(model.presenter.sheet != nil)
                        Spacer()
                    }
                }
                if model.offersSignOut {
                    HStack {
                        Button(ProtectionWords.accountSignOutDoor) { model.openSignOut() }
                            .disabled(model.presenter.sheet != nil)
                        Spacer()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func situation(_ faces: RoadAccountFaces) -> some View {
        switch faces.situation {
        case .localOnly:
            Text(ProtectionWords.accountLocalOnly)
                .font(.callout.weight(.semibold))
        case .inSync(let email):
            Text(ProtectionWords.accountInSync)
                .font(.callout.weight(.semibold))
            if let email { caption(ProtectionWords.accountSignedInAs(email)) }
        case .signedOut:
            Text(ProtectionWords.accountSignedOut)
                .font(.callout.weight(.semibold))
            caption(ProtectionWords.accountSignedOutLine)
        case .otherAccount(let email, let sameEmail):
            Text(ProtectionWords.accountOtherAccount)
                .font(.callout.weight(.semibold))
            if let email { caption(ProtectionWords.accountSignedInAs(email)) }
            caption(ProtectionWords.accountOtherAccountLine)
            if sameEmail { caption(ProtectionWords.accountSameEmailDifferentAccount) }
        }
        if faces.vaultUnreachable { caption(ProtectionWords.doorRefusedNeedsVault) }
    }

    @ViewBuilder
    private func doorRow(_ door: RoadAccountDoor, _ face: RoadAccountDoorFace) -> some View {
        switch face {
        case .hidden:
            EmptyView()
        case .refused(let sentence), .notYet(let sentence):
            caption(sentence)
        case .open(let open):
            if let notice = open.notice {
                Text(notice)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(open.doorLabel) { model.open(door) }
                    .disabled(model.presenter.sheet != nil)
                Spacer()
            }
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - An account door's confirm

struct RoadAccountConfirmSheet: View {
    @Bindable var model: RoadAccountConfirmModel

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var passphrase = ""
    @State private var again = ""
    @State private var words = ""

    /// Her sentences these confirms say — the primary ink (rule 16's, rule 12's leave sentence, rule 9's promise).
    private static let hers: Set<String> = [
        ProtectionWords.ruleSixteen, ProtectionWords.leaveSentence, ProtectionWords.castlePromise,
    ]

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.title3.weight(.semibold))
            if let moment = model.moment {
                wordsMoment(moment)
            } else {
                confirm
            }
        }
        .padding(22)
        .frame(width: 460, alignment: .leading)
        // VX-308 U2: the words moment closes only past her warning (or its OK) — a stray dismissal never puts them away.
        .interactiveDismissDisabled(model.busy || model.moment != nil)
    }

    @ViewBuilder
    private var confirm: some View {
        ForEach(Array(model.door.sentences.enumerated()), id: \.offset) { _, sentence in
            Text(sentence)
                .font(.callout)
                // Her sentences — the primary ink, as rule 12's are on Use Standard.
                .foregroundStyle(Self.hers.contains(sentence) ? .primary : .secondary)
                .fixedSize(horizontal: false, vertical: true)
            if sentence == ProtectionWords.copiesUnderAKeyThisMacCantDelete {
                ForEach(model.door.undeletableCopies, id: \.self) { copy in
                    Text("\u{2022} \(copy)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        if let gate = model.door.gate { gateChoice(gate) }
        fields
        if let refusal = model.refusal {
            Text(refusal)
                .font(.callout)
                .alarmVoice()
                .fixedSize(horizontal: false, vertical: true)
        }
        HStack {
            Button(ProtectionWords.accountCancel) { model.cancel() }
                .keyboardShortcut(.cancelAction)
                .disabled(model.busy)
            Spacer()
            if model.busy {
                TravellingDotsIndicator(ink: .secondary)
                Text(ProtectionWords.accountWorking).font(.caption).foregroundStyle(.secondary)
            }
            Button(model.button) { submit() }
                .keyboardShortcut(.defaultAction)
                .disabled(!model.canSubmit(passphrase: passphrase, again: again, words: words))
        }
    }

    /// RULE 7's WORDS MOMENT (VX-308 U2, R-U2-5): the words she typed, shown once over the one look idiom under her
    /// sentence; the passphrase typed — the notice that they were replaced, nothing shown (P-VX378-U2-3 (a)).
    @ViewBuilder
    private func wordsMoment(_ moment: RoadJoinWordsMoment) -> some View {
        switch moment {
        case .shown(let look):
            Text(ProtectionWords.joinWordsSentence)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            WordsLookPanel(look: look, tokens: tokens)
        case .notShown:
            Text(ProtectionWords.joinWordsNotShown)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Button(ProtectionWords.joinWordsMomentOK) { model.closeMoment() }
            }
        }
    }

    /// Into Castle (a join that enters it, the follow into it): Touch ID or Always ask — the crossings' own choice.
    private func gateChoice(_ gate: RoadGateChoice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ProtectionWords.gateHeading)
                .font(.callout.weight(.semibold))
            if gate.touchIDAvailable {
                Picker(ProtectionWords.gateHeading, selection: $model.gate) {
                    Text(ProtectionWords.gateTouchID).tag(GateStyle.touchID)
                    Text(ProtectionWords.gateAlwaysAsk).tag(GateStyle.alwaysAsk)
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
                .disabled(model.busy)
            } else {
                Text(ProtectionWords.gateAlwaysAsk)
                    .font(.callout)
                Text(ProtectionWords.touchIDNotSetUpOnThisMac)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(model.gate == .touchID && gate.touchIDAvailable
                 ? ProtectionWords.gateTouchIDLine : ProtectionWords.gateAlwaysAskLine)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Exactly the fields the door's ask names (turning sync on: both; a leave and the follow out: none; a join, Move and
    /// the follow: ONE secret — rule 14 — either field).
    @ViewBuilder
    private var fields: some View {
        let ask = model.door.ask
        if ask == .oneSecret {
            let follows = model.door.door == .follow
            PeekableSecretField(
                label: follows ? ProtectionWords.followPassphraseField : ProtectionWords.joinPassphraseField,
                text: $passphrase)
                .textFieldStyle(.roundedBorder)
            TextField(follows ? ProtectionWords.followWordsField : ProtectionWords.joinWordsField, text: $words,
                      axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .autocorrectionDisabled()
                .privacySensitive()
                .textFieldStyle(.roundedBorder)
                .onSubmit(submit)
        }
        if ask.asksPassphrase {
            if model.asksNewPassphrase {
                Text(ProtectionWords.turnOnSyncNewPassphraseLead)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseField, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseAgain, text: $again)
                    .textFieldStyle(.roundedBorder)
            } else {
                PeekableSecretField(label: ProtectionWords.crossingPassphraseField, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
            }
        }
        if ask.asksWords {
            TextField(ProtectionWords.crossingWordsField, text: $words, axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .autocorrectionDisabled()
                .privacySensitive()
                .textFieldStyle(.roundedBorder)
                .onSubmit(submit)
        }
    }

    private func submit() {
        let typedPassphrase = passphrase
        let typedAgain = again
        let typedWords = words
        Task { await model.submit(passphrase: typedPassphrase, again: typedAgain, words: typedWords) }
    }
}

// MARK: - Sign out (today's shipped confirm)

struct RoadSignOutSheet: View {
    @Bindable var model: RoadSignOutModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ProtectionWords.accountSignOutTitle)
                .font(.title3.weight(.semibold))
            Text(ProtectionWords.accountSignOutBody)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(ProtectionWords.accountCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy { TravellingDotsIndicator(ink: .secondary) }
                Button(ProtectionWords.accountSignOutButton) { Task { await model.confirm() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy)
            }
        }
        .padding(22)
        .frame(width: 440, alignment: .leading)
        .interactiveDismissDisabled(model.busy)
    }
}

// MARK: - Use Castle while signed out (the signed-out screen)

struct RoadSignedOutCastleSheet: View {
    @Bindable var model: RoadSignedOutCastleModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.title3.weight(.semibold))
            ForEach(Array(model.sentences.enumerated()), id: \.offset) { _, sentence in
                Text(sentence)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.accountCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy { TravellingDotsIndicator(ink: .secondary) }
                Button(ProtectionWords.accountContinue) { Task { await model.proceed() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy)
            }
        }
        .padding(22)
        .frame(width: 460, alignment: .leading)
        .interactiveDismissDisabled(model.busy)
    }
}

// MARK: - THE ONE PRESENTER's host (Settings ▸ Protection)

/// Presents the presenter's standing sheet on `host` — only there (VX-243); the host's dismissal is the sheet's Cancel.
struct ProtectionSheetsHost: ViewModifier {
    let presenter: ProtectionSheetPresenter?
    let services: AppServices?
    var host: ProtectionSheetHost = .settings

    func body(content: Content) -> some View {
        content.sheet(item: Binding(
            get: { presenter?.sheet(for: host) },
            set: { if $0 == nil { presenter?.hostDismissed(host) } })
        ) { sheet in
            switch sheet {
            case .crossing(let model):
                RoadCrossingSheet(model: model)
            case .signedOutCastle(let model):
                RoadSignedOutCastleSheet(model: model)
            case .account(let model):
                RoadAccountConfirmSheet(model: model)
            case .signOut(let model):
                RoadSignOutSheet(model: model)
            case .signIn:
                if let services {
                    AccountView(services: services, initialTab: .account)
                } else {
                    Text(ProtectionWords.doorRefusedNeedsVault)
                        .padding(22)
                }
            }
        }
    }
}

extension View {
    /// The new road's protection sheets, presented through the one presenter (nil on today's road — nothing presents).
    func protectionSheets(_ presenter: ProtectionSheetPresenter?, services: AppServices?) -> some View {
        modifier(ProtectionSheetsHost(presenter: presenter, services: services))
    }
}
