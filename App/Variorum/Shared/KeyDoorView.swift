//
//  KeyDoorView.swift
//  Variorum (shared: Mac + Mobile — the two re-wrap doors' ONE inline face)
//
//  pre-13x batch 3b — copy §4's *Change passphrase* and *Regenerate twelve
//  words*, rendered inline in the Encryption tab's enrolled section on both
//  platforms over the shared `KeyDoorModel` (the sync-setup face's precedent —
//  a re-wrap never re-keys the library, so no reopen tears the sheet down).
//  Functional and unstyled; 13s re-voices.
//

import SwiftUI
import VariorumCore

struct KeyDoorView: View {
    @Bindable var model: KeyDoorModel
    let pageStyle: SharedPageStyle?
    var onClose: () -> Void

    @State private var current = ""
    @State private var newPassphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch model.phase {
            case .checking:
                Text("Checking…").pageCaption(pageStyle)
            case .authorize:
                if model.kind == .changePassphrase {
                    PageHeading(ProtectionCopy.changePassphraseTitle, style: pageStyle)
                    Text(ProtectionCopy.changePassphraseLead)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                    PeekableSecretField(label: ProtectionCopy.currentPassphraseLabel, text: $current)
                        .pageFieldChrome(pageStyle)
                    PeekableSecretField(label: ProtectionCopy.newPassphraseLabel, text: $newPassphrase)
                        .pageFieldChrome(pageStyle)
                    PeekableSecretField(label: ProtectionCopy.confirmNewPassphraseLabel, text: $confirmation)
                        .pageFieldChrome(pageStyle)
                    forgotLinks
                    replaceKeysCheckbox(ProtectionCopy.alsoReplaceKeysAfterPassphrase)
                    HStack {
                        PageDoor(ProtectionCopy.changePassphraseDoor, style: pageStyle) {
                            Task { await model.changePassphrase(current: current, new: newPassphrase, confirmation: confirmation) }
                        }
                        .disabled(model.busy || current.isEmpty || newPassphrase.isEmpty)
                        cancel
                    }
                } else {
                    PageHeading(ProtectionCopy.regenerateWordsTitle, style: pageStyle)
                    Text(ProtectionCopy.regenerateWordsBody)
                        .pageCaptionWarning(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                    PeekableSecretField(label: ProtectionCopy.currentPassphraseLabel, text: $current)
                        .pageFieldChrome(pageStyle)
                    forgotLinks
                    replaceKeysCheckbox(ProtectionCopy.alsoReplaceKeysAfterWords)
                    HStack {
                        PageDoor(ProtectionCopy.enterCastleContinue, style: pageStyle) {
                            Task { await model.authorizeRegenerate(current: current) }
                        }
                        .disabled(model.busy || current.isEmpty)
                        cancel
                    }
                }
            case .forgotStandard:
                Text(ProtectionCopy.forgotStandardBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                if model.kind == .changePassphrase {
                    newFields
                    HStack {
                        PageDoor(ProtectionCopy.forgotStandardDoor, style: pageStyle) {
                            Task { await model.resetPassphrase(new: newPassphrase, confirmation: confirmation) }
                        }
                        .disabled(model.busy || newPassphrase.isEmpty)
                        cancel
                    }
                } else {
                    HStack {
                        PageDoor(ProtectionCopy.enterCastleContinue, style: pageStyle) {
                            Task { await model.authorizeRegenerateByDevice() }
                        }
                        .disabled(model.busy)
                        cancel
                    }
                }
            case .forgotBiometric:
                Text(ProtectionCopy.forgotCastleBiometricBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                if model.kind == .changePassphrase {
                    newFields
                    HStack {
                        PageDoor("Confirm with \(ProtectionCopy.biometryName)", style: pageStyle) {
                            Task { await model.resetPassphraseWithBiometrics(new: newPassphrase, confirmation: confirmation) }
                        }
                        .disabled(model.busy || newPassphrase.isEmpty)
                        cancel
                    }
                } else {
                    HStack {
                        PageDoor("Confirm with \(ProtectionCopy.biometryName)", style: pageStyle) {
                            Task { await model.authorizeRegenerateByDevice() }
                        }
                        .disabled(model.busy)
                        cancel
                    }
                }
            case .forgotWords:
                Text(ProtectionCopy.forgotUseWordsDoor)
                    .pageCaption(pageStyle)
                wordsField
                if model.kind == .changePassphrase {
                    newFields
                    HStack {
                        PageDoor(ProtectionCopy.changePassphraseDoor, style: pageStyle) {
                            Task { await model.resetPassphraseWithWords(typedWords, new: newPassphrase, confirmation: confirmation) }
                        }
                        .disabled(model.busy || typedWords.isEmpty || newPassphrase.isEmpty)
                        cancel
                    }
                } else {
                    HStack {
                        PageDoor(ProtectionCopy.enterCastleContinue, style: pageStyle) {
                            Task { await model.authorizeRegenerateWithWords(typedWords) }
                        }
                        .disabled(model.busy || typedWords.isEmpty)
                        cancel
                    }
                }
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
                HStack {
                    PageDoor(ProtectionCopy.wordsWrittenDoor, style: pageStyle) { model.acknowledgeWordsWritten() }
                    cancel
                }
            case .wordsConfirm:
                PageHeading(ProtectionCopy.wordsConfirmTitle, style: pageStyle)
                Text(ProtectionCopy.wordsConfirmBody).pageCaption(pageStyle)
                wordsField
                HStack {
                    PageDoor(ProtectionCopy.wordsConfirmDoor, style: pageStyle) { model.confirmWords(typedWords) }
                        .disabled(model.busy || typedWords.isEmpty)
                    cancel
                }
            case .done:
                Text(model.kind == .changePassphrase
                     ? ProtectionCopy.changePassphraseDone : ProtectionCopy.regenerateWordsDone)
                    .pageProse(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                PageDoor("Close", form: .inlineAct, style: pageStyle) { onClose() }
            case .failed(let sentence):
                Text(sentence)
                    .pageCaptionError(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                PageDoor("Close", form: .inlineAct, style: pageStyle) { onClose() }
            case .closed:
                EmptyView()
            }
            if model.busy {
                TravellingDotsIndicator(pageStyle: pageStyle)
            }
            if let error = model.lastError {
                Text(error)
                    .pageCaptionError(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task { await model.start() }
        .onChange(of: model.phase) { _, phase in
            if phase == .closed { onClose() }
        }
    }

    /// Copy §4's forgot link — Standard's plain road, Castle's Touch ID /
    /// Face ID road; under Always ask no link: the words are offered instead.
    @ViewBuilder
    private var forgotLinks: some View {
        if model.enrolled || model.kind == .changePassphrase {
            if model.offersForgotLink {
                PageDoor(ProtectionCopy.forgotCurrentPassphraseLink, form: .bordered, style: pageStyle) {
                    model.forgot()
                }
            } else {
                PageDoor(ProtectionCopy.forgotUseWordsDoor, form: .bordered, style: pageStyle) {
                    model.forgot()
                }
            }
        }
    }

    @ViewBuilder
    private func replaceKeysCheckbox(_ label: String) -> some View {
        if model.offersReplaceKeys {
            Toggle(isOn: $model.alsoReplaceKeys) {
                Text(label)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
            }
            #if os(macOS)
            .toggleStyle(.checkbox)
            #endif
        }
    }

    @ViewBuilder
    private var newFields: some View {
        PeekableSecretField(label: ProtectionCopy.newPassphraseLabel, text: $newPassphrase)
            .pageFieldChrome(pageStyle)
        PeekableSecretField(label: ProtectionCopy.confirmNewPassphraseLabel, text: $confirmation)
            .pageFieldChrome(pageStyle)
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

    private var cancel: some View {
        PageDoor("Cancel", form: .inlineAct, style: pageStyle) { onClose() }
    }
}
