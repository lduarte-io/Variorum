//
//  SyncEnrollmentView.swift  (pre-13x 5a — renamed from the 3a name, ledger 55: a
//  NAME collision with the retired Phase 8 paste-in form, never a revival)
//  Variorum (shared: Mac + Mobile — SYNC SETUP's face over `SyncEnrollmentModel`,
//  rendered inline by the Encryption tab's `.noVault` arm on both platforms)
//
//  pre-13x batch 3a — copy §2a's screens, verbatim through `ProtectionCopy`:
//  the pre-Screen-1 move confirm · Screen 1 (what sync needs + the posture
//  addendum) · Screen 2 (the passphrase: typed when the library has one, set
//  otherwise) · Screen 3 / 3b (the words through the shared `WordsCeremony`)
//  · During · Screen 4 (done, the posture's sentence). The chrome is the
//  page family every shared face uses (`PageDoor`, `PeekableSecretField`,
//  the page style seam), so the Mac and the phone render one ceremony.
//

import SwiftUI
import VariorumCore

struct SyncEnrollmentView: View {
    @Bindable var model: SyncEnrollmentModel
    let pageStyle: SharedPageStyle?
    var onClose: () -> Void

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch model.phase {
            case .checking:
                ProgressView().controlSize(.small)
            case .confirmMove:
                Text(ProtectionCopy.setupMoveSentence)
                    .pageWarning(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    PageDoor(ProtectionCopy.setupMoveDoor, style: pageStyle) { model.confirmMove() }
                    PageDoor("Cancel", form: .inlineAct, style: pageStyle) { onClose() }
                }
            case .explain:
                PageHeading(ProtectionCopy.setupNeedsTitle, style: pageStyle)
                Text(ProtectionCopy.setupNeedsBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(ProtectionCopy.setupNeedsBullets, id: \.self) { line in
                    Text("• " + line)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text((model.facts?.libraryPosture ?? .standard) == .standard
                     ? ProtectionCopy.setupStandardAddendum : ProtectionCopy.setupCastleAddendum)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    PageDoor(ProtectionCopy.setupContinue, style: pageStyle) { model.continueFromExplain() }
                    PageDoor("Cancel", form: .inlineAct, style: pageStyle) { onClose() }
                }
            case .passphrase(let existing):
                PageHeading(ProtectionCopy.setupPassphraseTitle, style: pageStyle)
                if existing {
                    Text(ProtectionCopy.passphraseAlreadyOnAccount)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                    PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                        .pageFieldChrome(pageStyle)
                } else {
                    PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                        .pageFieldChrome(pageStyle)
                    PeekableSecretField(label: ProtectionCopy.passphraseConfirmLabel, text: $confirmation)
                        .pageFieldChrome(pageStyle)
                    Text(ProtectionCopy.passphraseSubline)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                PageDoor(ProtectionCopy.setupContinue, style: pageStyle) {
                    let typed = passphrase
                    let confirm = confirmation
                    Task { await model.submitPassphrase(typed, confirmation: existing ? nil : confirm) }
                }
                .disabled(model.busy || passphrase.isEmpty)
            case .wordsExisting:
                PageHeading(ProtectionCopy.wordsExistTitle, style: pageStyle)
                Text(ProtectionCopy.wordsExistBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    PageDoor(ProtectionCopy.wordsTypeMineDoor, style: pageStyle) { model.chooseTypeWords() }
                    PageDoor(ProtectionCopy.wordsGenerateNewDoor, form: .inlineAct, style: pageStyle) { model.chooseGenerateNewWords() }
                }
            case .wordsType:
                PageHeading(ProtectionCopy.wordsExistTitle, style: pageStyle)
                wordsField
                PageDoor(ProtectionCopy.wordsConfirmDoor, style: pageStyle) {
                    let typed = typedWords
                    Task { await model.submitExistingWords(typed) }
                }
                .disabled(model.busy || typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            case .wordsShow(let words):
                PageHeading(ProtectionCopy.wordsWriteDownTitle, style: pageStyle)
                Text(ProtectionCopy.wordsWriteDownBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                Text(words.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "   "))
                    .font(.body.monospaced())
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .privacySensitive()
                    .pagePhraseCard(pageStyle)
                if model.copiedWords {
                    Text(ProtectionCopy.wordsCopied).pageCaption(pageStyle)
                }
                PageDoor(ProtectionCopy.wordsWrittenDoor, style: pageStyle) { model.acknowledgeWordsWritten() }
            case .wordsConfirm:
                PageHeading(ProtectionCopy.wordsConfirmTitle, style: pageStyle)
                Text(ProtectionCopy.wordsConfirmBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                wordsField
                PageDoor(ProtectionCopy.wordsConfirmDoor, style: pageStyle) { model.confirmWords(typedWords) }
                    .disabled(model.busy || typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            case .creating:
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Turning on sync…").pageCaption(pageStyle)
                }
            case .done(let posture):
                Text(posture == .standard ? ProtectionCopy.setupDoneStandard : ProtectionCopy.setupDoneCastle)
                    .pageProse(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                PageDoor(ProtectionCopy.setupDoneDoor, style: pageStyle) { model.close(); onClose() }
            case .failed(let sentence):
                Text(sentence)
                    .pageCaptionError(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                PageDoor("Close", form: .inlineAct, style: pageStyle) { model.close(); onClose() }
            case .closed:
                EmptyView()
            }
            if let error = model.lastError {
                Text(error)
                    .pageCaptionError(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task { await model.start() }
    }

    private var wordsField: some View {
        let field = TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
            .privacySensitive()
        #if os(iOS)
        return field
            .textInputAutocapitalization(.never)
            .pageFieldChrome(pageStyle)
        #else
        return field
        #endif
    }
}
