//
//  MobileProtectionDoors.swift
//  VariorumMobile
//
//  VM-8 unit 2 — THE PROTECTION SCREEN'S REMAINING FACES (the run record `notes/plans/vm-8-castle-catchup.md`, THE UNIT 2
//  BRIEF; every finding and PROVISIONAL named here is in its UNIT 2 — LIVE STATUS). The faces are the SHARED values
//  `assess` reads — `RoadCrossingFaces` / `RoadCrossingsModel`, `RoadKeyDoorFaces` / `RoadKeyDoorsModel`,
//  `SetPassphraseModel`, `WordsLookModel`, `ProtectionSecretCheck`'s `RoadSecretCheckModel` — all the bootstrap's and kept
//  across every reopen, rendered in the phone's voice. Nothing here decides; a door renders only where it can act (P-2):
//
//    - THE PASSPHRASE: *Set a passphrase…* while none exists (the shared setter — the 12-character floor its only refusal,
//      VX-211's quiet hint under the field); Change passphrase… and Reset forgotten passphrase… as `assess` says them
//      (Standard's plain confirm; Castle's words, or *Reset with Face ID* where this iPhone has its item), each saying
//      VX-263's one line; a door the follow locks renders nothing here (the pair gate's and the generic one's alike).
//    - THE OWED FOLLOW, SAID ONCE (`MobileFollowOwed` — F-U2-D, PROVISIONAL P-VM8-9 (a-unified), ladder round 1's
//      MINOR-1): the follow-owed refusal is said once on the whole screen, in the account section's follow place — beside
//      the follow door's notice, or alone there where the follow out of Castle is held (P-VM8-10); the pair's sentence is
//      the follow door's notice, once. The Mac's VX-542 repetition is not copied.
//    - THE TWELVE WORDS: New words through the one look (it mints and shows once; asks the passphrase where one exists; a
//      synced library hears first that new words replace the account's) — no Copy door (the phone has no words clipboard).
//    - THE CHECK: *Check my passphrase or twelve words…* — one typed secret, read only; it writes nothing (VX-513).
//    - THE CROSSINGS, ENTERING ONLY: the posture line; Use Castle… (both secrets typed; a new passphrase twice where none;
//      the gate choice at the press — Face ID or Always ask), and its signed-out road (This iPhone only, then Use Castle's
//      own confirm); Replace All Keys… (synced — the library's key only); in Castle the standing gate-style row. USE
//      STANDARD NEVER RENDERS (its confirm says her rule-12 sentence — F-PH-2, hers; F-U2-G). Rule 11's export-off notice
//      renders nothing: the phone has no scheduled export, so it can never stand (F-U2-A).
//    - THE RECEIPTS' HOME (F-U2-E, PROVISIONAL P-VM8-8): `MobileProtectionReceipts` — what `RoadStandingModel.speak` says
//      on the phone, shown muted under the screen's title: the newest few said (up to three, one line each), never a
//      single line.
//

import SwiftUI
import VariorumCore

// MARK: - The phone's chrome for these faces

/// The lines, captions and doors every protection section on the phone speaks in (unit 1's account section's idiom).
enum MobileProtectionChrome {
    static func heading(_ text: String, _ tokens: VoiceTokens) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
    }

    static func line(_ text: String, _ tokens: VoiceTokens) -> some View {
        Text(text)
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func caption(_ text: String, _ tokens: VoiceTokens) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func alarm(_ text: String, _ tokens: VoiceTokens) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.alarm)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// A door in the section (the accent, its plain label for VoiceOver).
    static func door(_ label: String, _ tokens: VoiceTokens, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(tokens.chromeLabel(label))
                .font(tokens.body)
                .foregroundStyle(tokens.accent)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    /// A sheet's title.
    static func title(_ text: String, _ tokens: VoiceTokens) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.title)
            .foregroundStyle(tokens.ink)
    }

    /// An act running: the dots and the act's own word.
    static func working(_ text: String, _ tokens: VoiceTokens) -> some View {
        HStack(spacing: 6) {
            TravellingDotsIndicator(ink: tokens.muted)
            Text(tokens.chromeLabel(text))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
        }
    }
}

extension View {
    /// The lobby's field idiom (`MobileRoadLockView`): a quiet card around the shared concealing field.
    func mobileSecretFieldChrome(_ tokens: VoiceTokens) -> some View {
        textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tokens.card)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1)))
    }

    /// A protection sheet's room: the voice's room fills the whole sheet (unit 1's C05 — never the system's grey).
    func mobileProtectionSheetRoom(_ tokens: VoiceTokens) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(tokens.room.ignoresSafeArea())
    }
}

/// **VX-211 — the ONE calm line beneath a NEW passphrase field, as she types** (the Mac's `PassphraseHintLine`, the phone's
/// face of the same shared rule — `NewPassphraseRule.hint`): advice, never a block, never a meter; nothing for a long,
/// varied phrase or an empty field. Every phone field that SETS a passphrase renders it (F-U2-C).
struct MobilePassphraseHintLine: View {
    let passphrase: String
    let tokens: VoiceTokens

    var body: some View {
        if let hint = NewPassphraseRule.hint(passphrase) {
            Text(hint)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(hint)
        }
    }
}

/// Into Castle (Use Castle, a join that enters it, the follow into it): Face ID or Always ask — the crossings' own choice,
/// the phone's biometry named by the shared words (`ProtectionCopy.biometryName`); the selected one in ink with its mark.
struct MobileGateChoice: View {
    let gate: RoadGateChoice
    @Binding var selection: GateStyle
    let busy: Bool
    let tokens: VoiceTokens

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MobileProtectionChrome.heading(ProtectionWords.gateHeading, tokens)
            if gate.touchIDAvailable {
                row(.touchID, ProtectionWords.gateTouchID)
                row(.alwaysAsk, ProtectionWords.gateAlwaysAsk)
            } else {
                Text(ProtectionWords.gateAlwaysAsk)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                MobileProtectionChrome.caption(ProtectionWords.touchIDNotSetUpOnThisMac, tokens)
            }
            MobileProtectionChrome.caption(
                selection == .touchID && gate.touchIDAvailable
                    ? ProtectionWords.gateTouchIDLine : ProtectionWords.gateAlwaysAskLine, tokens)
        }
    }

    private func row(_ style: GateStyle, _ label: String) -> some View {
        let selected = selection == style
        return Button {
            selection = style
        } label: {
            HStack(spacing: 8) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? tokens.accent : tokens.muted)
                Text(label)
                    .font(tokens.body)
                    .foregroundStyle(selected ? tokens.ink : tokens.muted)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .disabled(busy)
    }
}

// MARK: - THE RECEIPTS' HOME (F-U2-E — PROVISIONAL P-VM8-8)

/// **What `RoadStandingModel.speak` says on the phone.** The phone has no status seam (no toast, no `StatusCenter`); its
/// idiom is a landed act's own words in the muted slot of the surface where the door fired — and every protection door the
/// phone can press fires on the Protection screen. So the shell composition hands the open library's faces this holder as
/// their receipt door (rebuilt with each open: a re-keying act's receipt owed to the reopen is spoken into the shell that
/// re-pushes the screen); the screen shows what was said muted under its title — the newest `kept` (three), one line
/// each, oldest first; receipts owed by an OPEN (rule 1's restore receipt, the key-file offer's — P-VX329-PH-1's two
/// sentences) wait here until the screen next shows; leaving the screen clears what it showed. `receipt_style` has no
/// phone consumer yet (PL-22's owed face call) — the lines always show.
@MainActor
@Observable
final class MobileProtectionReceipts {
    /// What was said since the screen last showed it, oldest first (the newest few).
    private(set) var lines: [String] = []

    static let kept = 3

    func say(_ text: String) {
        lines.append(text)
        if lines.count > Self.kept { lines.removeFirst(lines.count - Self.kept) }
    }

    /// The screen went away: what it showed is said.
    func screenLeft() {
        lines = []
    }
}

// MARK: - The owed follow, said once (VM-8 ladder round 1, MINOR-1 — PROVISIONAL P-VM8-9 (a-unified))

/// **The owed follow's refusal, said ONCE on the screen.** While the account changed on another device, `assess` locks
/// every key door, the crossings (its gate runs before the posture's own check) and the leaves that write the account
/// (`.followOwed`), and the shared faces give each the same sentence in its place — VX-542's repetition, four times on one
/// phone screen. The phone says it once, in ONE place: the account section's follow place — beside the follow door's
/// notice where that door renders, alone there where it does not (P-VM8-10: the follow out of Castle is held for her phone
/// wording, and the dead end keeps its one truth-teller). Every section renders nothing for a door the follow locks; a door
/// refused for any other reason keeps its row. The sentence is the shared faces' own (`doorRefusedFollowOwed` — no new
/// words); the pair gate's per-door sentence (`followFirstToCatchUp` — the pair's notice + the road) collapses into it, the
/// pair's notice standing beside its door. Pure readings of the shared faces — nothing here decides.
enum MobileFollowOwed {
    /// The one saying.
    static let saying = ProtectionWords.doorRefusedFollowOwed

    /// The key doors are locked by the follow: the pair gate (each door's sentence names the pair — the shared fact), or
    /// any door saying the follow-owed refusal.
    static func locks(_ faces: RoadKeyDoorFaces?) -> Bool {
        guard let faces else { return false }
        return faces.pairGate || RoadKeyDoor.allCases.contains { faces.face($0) == .refused(saying) }
    }

    /// A crossing the phone renders is locked by the follow.
    static func locks(_ faces: RoadCrossingFaces?) -> Bool {
        guard let faces else { return false }
        return MobileRoadCrossingsSection.phoneDoors.contains { faces.face($0) == .refused(saying) }
    }

    /// An account door is locked by the follow (the leaves that write the account — `assess`'s `.followOwed`).
    static func locks(_ faces: RoadAccountFaces?) -> Bool {
        guard let faces else { return false }
        return RoadAccountDoor.allCases.contains { faces.face($0) == .refused(saying) }
    }
}

// MARK: - The passphrase (Set a passphrase…, Change, Reset — VX-306 U2, VX-308 U3)

struct MobilePassphraseSection: View {
    let standing: RoadStandingModel
    let tokens: VoiceTokens
    /// The screen's set-passphrase sheet (the Mac pane's own sheet — never the one presenter's).
    @Binding var setSheet: SetPassphraseModel?

    /// One row of the section, as `assess` said the doors (identical refusals said once).
    enum Row: Hashable {
        case open(RoadKeyDoor)
        case refused(String)
    }

    /// The passphrase doors' rows — the pure reading the section renders. A door the follow locks contributes NO row (the
    /// pair gate's doors and the follow-owed refusal alike — the screen says it once, in the follow's place: P-VM8-9
    /// (a-unified)); any other refusal keeps its row, identical ones once.
    static func rows(_ faces: RoadKeyDoorFaces) -> [Row] {
        if faces.pairGate { return [] }
        var rows: [Row] = []
        for door in [RoadKeyDoor.changePassphrase, .resetForgottenPassphrase] {
            switch faces.face(door) {
            case .hidden: continue
            case .open: rows.append(.open(door))
            case .refused(MobileFollowOwed.saying): continue
            case .refused(let sentence): if !rows.contains(.refused(sentence)) { rows.append(.refused(sentence)) }
            }
        }
        return rows
    }

    var body: some View {
        let keyDoors = standing.keyDoors
        let rows = keyDoors?.faces.map(Self.rows) ?? []
        if standing.offersSetPassphrase || !rows.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                MobileProtectionChrome.heading(ProtectionWords.passphraseSectionTitle, tokens)
                if standing.offersSetPassphrase {
                    MobileProtectionChrome.door(ProtectionWords.reminderSetDoor, tokens) {
                        setSheet = standing.makeSetPassphraseSheet {
                            setSheet = nil
                            // W-U2-1 (the walk's D08): the screen's doors read again — a passphrase set lets Change and
                            // Reset stand where the set row retires (the pane's one read; nothing else re-reads them).
                            Task { await standing.refreshPane() }
                        }
                    }
                    .disabled(keyDoors?.presenter.sheet != nil)
                }
                ForEach(rows, id: \.self) { row in
                    switch row {
                    case .open(let door):
                        MobileProtectionChrome.door(door.doorLabel, tokens) { keyDoors?.open(door) }
                            .disabled(keyDoors?.presenter.sheet != nil)
                    case .refused(let sentence):
                        MobileProtectionChrome.caption(sentence, tokens)
                    }
                }
            }
        }
    }
}

/// The set-passphrase sheet (VX-306 U2; §7c (7)'s words): the title, the lead, a new passphrase typed twice with VX-211's
/// hint beneath it, one button — and a way out. It refuses at once where a passphrase already exists.
struct MobileSetPassphraseSheet: View {
    @Bindable var model: SetPassphraseModel
    let tokens: VoiceTokens

    @State private var passphrase = ""
    @State private var again = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MobileProtectionChrome.title(ProtectionWords.setPassphraseTitle, tokens)
                MobileProtectionChrome.caption(ProtectionWords.setPassphraseLead, tokens)
                if !model.alreadySet {
                    PeekableSecretField(label: ProtectionWords.setPassphraseField, text: $passphrase)
                        .mobileSecretFieldChrome(tokens)
                    MobilePassphraseHintLine(passphrase: passphrase, tokens: tokens)
                    PeekableSecretField(label: ProtectionWords.setPassphraseAgain, text: $again, onSubmit: submit)
                        .mobileSecretFieldChrome(tokens)
                }
                if let refusal = model.refusal { MobileProtectionChrome.alarm(refusal, tokens) }
                if model.busy { TravellingDotsIndicator(ink: tokens.muted) }
                HStack(spacing: 16) {
                    MobileRoadButton(title: ProtectionWords.setPassphraseCancel, tokens: tokens) { model.cancel() }
                        .disabled(model.busy)
                    MobileRoadButton(title: ProtectionWords.setPassphraseButton, tokens: tokens) { submit() }
                        .disabled(!model.canSubmit(passphrase: passphrase, again: again))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
        }
        .mobileProtectionSheetRoom(tokens)
        .interactiveDismissDisabled(model.busy)
    }

    private func submit() {
        let typed = passphrase
        let twice = again
        Task { await model.submit(passphrase: typed, again: twice) }
    }
}

/// A passphrase door's confirm (VX-308 U3): its sentences (VX-263's one line first, in ink; synced, the account's
/// passphrase changing with it; the forgot road's lead), exactly the fields the door names (Change: the current
/// passphrase; both: a new one typed twice with VX-211's hint; Castle's forgot road: the twelve words, or *Reset with Face
/// ID* where this iPhone has its item), the refusal, the door's one button.
struct MobileRoadKeyDoorConfirmSheet: View {
    @Bindable var model: RoadKeyDoorConfirmModel
    let tokens: VoiceTokens

    @State private var current = ""
    @State private var new = ""
    @State private var again = ""
    @State private var words = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MobileProtectionChrome.title(model.title, tokens)
                ForEach(Array(model.door.sentences.enumerated()), id: \.offset) { index, sentence in
                    Text(sentence)
                        .font(tokens.body)
                        .foregroundStyle(index == 0 ? tokens.ink : tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if model.asksCurrent {
                    PeekableSecretField(label: ProtectionWords.changePassphraseCurrentField, text: $current)
                        .mobileSecretFieldChrome(tokens)
                }
                if model.asksWords {
                    // VX-463: the twelve words conceal like the passphrase, with the same reveal eye.
                    PeekableSecretField(label: ProtectionWords.resetPassphraseWordsField, text: $words)
                        .mobileSecretFieldChrome(tokens)
                }
                PeekableSecretField(label: ProtectionWords.keyDoorNewPassphraseField, text: $new)
                    .mobileSecretFieldChrome(tokens)
                MobilePassphraseHintLine(passphrase: new, tokens: tokens)
                PeekableSecretField(label: ProtectionWords.keyDoorNewPassphraseAgain, text: $again, onSubmit: submit)
                    .mobileSecretFieldChrome(tokens)
                if let refusal = model.refusal { MobileProtectionChrome.alarm(refusal, tokens) }
                if model.busy { MobileProtectionChrome.working(ProtectionWords.keyDoorWorking, tokens) }
                if model.offersTouchID {
                    MobileRoadButton(title: ProtectionWords.resetPassphraseWithTouchID, systemImage: "faceid", tokens: tokens) {
                        submitWithFaceID()
                    }
                    .disabled(!model.canSubmitWithTouchID(new: new, again: again))
                }
                HStack(spacing: 16) {
                    MobileRoadButton(title: ProtectionWords.keyDoorCancel, tokens: tokens) { model.cancel() }
                        .disabled(model.busy)
                    MobileRoadButton(
                        title: model.door.door == .changePassphrase
                            ? ProtectionWords.changePassphraseButton : ProtectionWords.resetPassphraseButton,
                        tokens: tokens
                    ) { submit() }
                    .disabled(!model.canSubmit(current: current, new: new, again: again, words: words))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
        }
        .mobileProtectionSheetRoom(tokens)
        .interactiveDismissDisabled(model.busy)
    }

    private func submit() {
        let typed = (current, new, again, words)
        Task { await model.submit(current: typed.0, new: typed.1, again: typed.2, words: typed.3) }
    }

    private func submitWithFaceID() {
        let typed = (new, again)
        Task { await model.submitWithTouchID(new: typed.0, again: typed.1) }
    }
}

// MARK: - The twelve words (New words through the look — VX-307 U2b, VX-308 U3)

struct MobileWordsSection: View {
    let standing: RoadStandingModel
    let tokens: VoiceTokens
    /// The look the door opened (the screen holds it: while it holds words the screen keeps its way back).
    @Binding var look: WordsLookModel?

    var body: some View {
        let faces = standing.keyDoors?.faces
        VStack(alignment: .leading, spacing: 10) {
            MobileProtectionChrome.heading(ProtectionWords.wordsSectionTitle, tokens)
            MobileProtectionChrome.caption(ProtectionWords.wordsSectionLine, tokens)
            if let look, look.phase != .closed {
                MobileWordsLookPanel(look: look, tokens: tokens)
            } else if faces?.pairGate == true || faces?.newWords == .refused(MobileFollowOwed.saying) {
                // P-VM8-9 (a-unified): New words locked by the follow — the screen says it once, in the follow's place.
                EmptyView()
            } else if case .refused(let sentence)? = faces?.newWords {
                MobileProtectionChrome.caption(sentence, tokens)
            } else if faces?.newWords != .hidden {
                MobileProtectionChrome.door(ProtectionWords.wordsSectionDoor, tokens) {
                    // A fresh look per press (it reads, at its making, whether words were recorded before).
                    let fresh = standing.makeWordsLook()
                    look = fresh
                    Task { await fresh.open() }
                }
                .disabled(standing.keyDoors?.presenter.sheet != nil)
                // VX-263's one line — the key door says it (rule 6: "the doors say so in one sentence").
                MobileProtectionChrome.caption(ProtectionWords.keyDoorsLine, tokens)
                if let message = look?.message { MobileProtectionChrome.alarm(message, tokens) }
            }
        }
    }
}

// MARK: - The check (VX-513 — it writes nothing)

struct MobileRoadSecretCheckDoor: View {
    @Bindable var model: RoadKeyDoorsModel
    let tokens: VoiceTokens

    var body: some View {
        if model.offersCheck {
            MobileProtectionChrome.door(ProtectionWords.checkSecretsDoor, tokens) { model.openCheck() }
                .disabled(model.presenter.sheet != nil)
        }
    }
}

/// The check's sheet: the title, one lead line, ONE concealed field (VX-463), what the check said (the first line in the
/// alarm ink when something did not open), *Close* and *Check*. Typing again clears what was said (unit C's W-10).
struct MobileRoadSecretCheckSheet: View {
    @Bindable var model: RoadSecretCheckModel
    let tokens: VoiceTokens

    @State private var typed = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MobileProtectionChrome.title(ProtectionWords.checkSecretsTitle, tokens)
                MobileProtectionChrome.caption(ProtectionWords.checkSecretsLead, tokens)
                PeekableSecretField(label: ProtectionWords.checkSecretsField, text: $typed, onSubmit: submit)
                    .mobileSecretFieldChrome(tokens)
                    .onChange(of: typed) { model.edited() }
                if let outcome = model.outcome {
                    ForEach(Array(outcome.lines.enumerated()), id: \.offset) { index, line in
                        if index == 0 && outcome.warns {
                            Text(line)
                                .font(tokens.body)
                                .foregroundStyle(tokens.alarm)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(line)
                                .font(tokens.body)
                                .foregroundStyle(index == 0 ? tokens.ink : tokens.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                if model.busy { MobileProtectionChrome.working(ProtectionWords.checkSecretsWorking, tokens) }
                HStack(spacing: 16) {
                    MobileRoadButton(title: ProtectionWords.checkSecretsClose, tokens: tokens) { model.close() }
                    MobileRoadButton(title: ProtectionWords.checkSecretsButton, tokens: tokens) { submit() }
                        .disabled(!model.canSubmit(typed))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
        }
        .mobileProtectionSheetRoom(tokens)
    }

    private func submit() {
        let text = typed
        Task { await model.submit(text) }
    }
}

// MARK: - The crossings, entering only (VX-307 U2a)

struct MobileRoadCrossingsSection: View {
    @Bindable var model: RoadCrossingsModel
    let tokens: VoiceTokens

    @State private var gatePassphrase = ""

    /// F-U2-G: the phone's crossings — Use Castle and Replace All Keys. USE STANDARD NEVER (its confirm says her rule-12
    /// sentence; its phone wording is hers — F-PH-2), in any state: open, it is not rendered; refused, a refusal for a door
    /// the phone never offers is no road.
    static let phoneDoors: [RoadCrossingDoor] = [.useCastle, .replaceAllKeys]

    /// One row of the section, as `assess` said the doors (identical refusals said once — P-VM8-9's rule).
    enum Row: Hashable {
        case open(RoadCrossingDoor)
        case signedOutRoad(RoadCrossingDoor)
        case refused(String)
    }

    /// The pure reading the section renders. A door the follow locks contributes no row (the screen says it once, in the
    /// follow's place — P-VM8-9 (a-unified)).
    static func rows(_ faces: RoadCrossingFaces) -> [Row] {
        var rows: [Row] = []
        for door in phoneDoors {
            switch faces.face(door) {
            case .hidden: continue
            // The belt beside the list: any door whose confirm says rule 12's sentence renders nothing here.
            case .open(let open) where open.saysRuleTwelve: continue
            case .open: rows.append(.open(door))
            case .signedOutRoad: rows.append(.signedOutRoad(door))
            case .refused(MobileFollowOwed.saying): continue
            case .refused(let sentence): if !rows.contains(.refused(sentence)) { rows.append(.refused(sentence)) }
            }
        }
        return rows
    }

    var body: some View {
        if let faces = model.faces {
            VStack(alignment: .leading, spacing: 10) {
                Text(ProtectionWords.postureLine(faces.mode))
                    .font(tokens.body.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                ForEach(Self.rows(faces), id: \.self) { row in
                    switch row {
                    case .open(let door):
                        MobileProtectionChrome.door(door.doorLabel, tokens) { model.open(door) }
                            .disabled(model.presenter.sheet != nil)
                    case .signedOutRoad(let door):
                        // VX-308 U1 (VX-264): Use Castle while signed out — the signed-out screen first.
                        MobileProtectionChrome.door(door.doorLabel, tokens) { model.openSignedOutRoad() }
                            .disabled(model.presenter.sheet != nil)
                    case .refused(let sentence):
                        MobileProtectionChrome.caption(sentence, tokens)
                    }
                }
                // (Rule 11's export-off notice: the phone has no scheduled export, so it never stands — F-U2-A.)
            }
            if let row = faces.gateRow {
                Divider().overlay(tokens.line)
                gateSection(row)
            }
        }
    }

    /// The standing gate-style row (Castle): Face ID on only with the passphrase; Always ask deletes the item.
    private func gateSection(_ row: RoadGateRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            MobileProtectionChrome.heading(ProtectionWords.gateHeading, tokens)
            MobileProtectionChrome.line(
                row.current == .touchID ? ProtectionWords.gateRowTouchID : ProtectionWords.gateRowAlwaysAsk, tokens)
            if row.current == .touchID {
                MobileProtectionChrome.door(ProtectionWords.gateRowUseAlwaysAsk, tokens) {
                    Task { await model.useAlwaysAsk() }
                }
                .disabled(model.gateBusy)
            } else if row.touchIDAvailable {
                if model.gateAsksPassphrase {
                    PeekableSecretField(
                        label: ProtectionWords.crossingPassphraseField, text: $gatePassphrase, onSubmit: useFaceID)
                        .mobileSecretFieldChrome(tokens)
                    HStack(spacing: 16) {
                        MobileRoadButton(title: ProtectionWords.crossingCancel, tokens: tokens) {
                            gatePassphrase = ""
                            model.cancelTouchID()
                        }
                        .disabled(model.gateBusy)
                        if model.gateBusy { TravellingDotsIndicator(ink: tokens.muted) }
                        MobileRoadButton(title: ProtectionWords.gateRowTouchIDButton, tokens: tokens) { useFaceID() }
                            .disabled(gatePassphrase.isEmpty || model.gateBusy)
                    }
                } else {
                    MobileProtectionChrome.door(ProtectionWords.gateRowUseTouchID, tokens) { model.beginTouchID() }
                }
            } else {
                MobileProtectionChrome.caption(ProtectionWords.touchIDNotSetUpOnThisMac, tokens)
            }
            if let refusal = model.gateRefusal { MobileProtectionChrome.alarm(refusal, tokens) }
            // (The idle dial and Lock Library Now sit here on the Mac — not this unit's: F-U2-F.)
        }
    }

    private func useFaceID() {
        let typed = gatePassphrase
        gatePassphrase = ""
        Task { await model.useTouchID(passphrase: typed) }
    }
}

/// A crossing's confirm (Use Castle, Replace All Keys): the door's title, its sentences as `assess` gave them (rule 9's
/// promise is hers — in ink; rule 25's copies named beneath their line), Use Castle's gate choice, exactly the fields the
/// door asks (both typed — the passphrase, a NEW one typed twice with VX-211's hint when the library has none, and the
/// twelve words), the refusal, one button. While the act runs the library closes and reopens under it.
struct MobileRoadCrossingConfirmSheet: View {
    @Bindable var model: RoadCrossingConfirmModel
    let tokens: VoiceTokens

    @State private var passphrase = ""
    @State private var again = ""
    @State private var words = ""

    private static let hers: Set<String> = [ProtectionWords.castlePromise]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MobileProtectionChrome.title(model.title, tokens)
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
                if let refusal = model.refusal { MobileProtectionChrome.alarm(refusal, tokens) }
                if model.busy { MobileProtectionChrome.working(ProtectionWords.crossingWorking, tokens) }
                HStack(spacing: 16) {
                    MobileRoadButton(title: ProtectionWords.crossingCancel, tokens: tokens) { model.cancel() }
                        .disabled(model.busy)
                    MobileRoadButton(title: model.title, tokens: tokens) { submit() }
                        .disabled(!model.canSubmit(passphrase: passphrase, again: again, words: words))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
        }
        .mobileProtectionSheetRoom(tokens)
        .interactiveDismissDisabled(model.busy)
    }

    /// Exactly the fields the door's ask names.
    @ViewBuilder
    private var fields: some View {
        let ask = model.door.ask
        if ask.asksPassphrase || ask == .oneSecret {
            if model.asksNewPassphrase {
                MobileProtectionChrome.caption(ProtectionWords.crossingNewPassphraseLead, tokens)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseField, text: $passphrase)
                    .mobileSecretFieldChrome(tokens)
                MobilePassphraseHintLine(passphrase: passphrase, tokens: tokens)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseAgain, text: $again)
                    .mobileSecretFieldChrome(tokens)
            } else {
                PeekableSecretField(label: ProtectionWords.crossingPassphraseField, text: $passphrase)
                    .mobileSecretFieldChrome(tokens)
            }
        }
        if ask.asksWords || ask == .oneSecret {
            // VX-463: the twelve words conceal like the passphrase, with the same reveal eye.
            PeekableSecretField(label: ProtectionWords.crossingWordsField, text: $words, onSubmit: submit)
                .mobileSecretFieldChrome(tokens)
        }
    }

    private func submit() {
        let typedPassphrase = passphrase
        let typedAgain = again
        let typedWords = words
        Task { await model.submit(passphrase: typedPassphrase, again: typedAgain, words: typedWords) }
    }
}

/// Use Castle while signed out (VX-308 U1, VX-264 — drafted to the current rules): the screen's sentences; *Continue* runs
/// This iPhone only (rule 16 — no key or secret changes), then Use Castle's own confirm takes the floor; *Cancel* writes
/// nothing.
struct MobileRoadSignedOutCastleSheet: View {
    @Bindable var model: RoadSignedOutCastleModel
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                MobileProtectionChrome.title(model.title, tokens)
                ForEach(Array(model.sentences.enumerated()), id: \.offset) { _, sentence in
                    Text(sentence)
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let refusal = model.refusal { MobileProtectionChrome.alarm(refusal, tokens) }
                if model.busy { TravellingDotsIndicator(ink: tokens.muted) }
                HStack(spacing: 16) {
                    MobileRoadButton(title: ProtectionWords.accountCancel, tokens: tokens) { model.cancel() }
                        .disabled(model.busy)
                    MobileRoadButton(title: ProtectionWords.accountContinue, tokens: tokens) {
                        Task { await model.proceed() }
                    }
                    .disabled(model.busy)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
        }
        .mobileProtectionSheetRoom(tokens)
        .interactiveDismissDisabled(model.busy)
    }
}
