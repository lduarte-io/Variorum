//
//  EncryptionViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14b, batch 3 (L9) — the E2EE settings surface, ONE shared view for
//  both form factors (PL-6; the AccountView precedent — functional and
//  unstyled).
//
//  Phase 14b COPY/FLOW ROUND (CF-1…CF-13 + the CF-12 biometric ruling; the
//  governing principle is CF-10, her words: many users' first real
//  end-to-end encryption — the flow must make sense FOR THEM):
//  SETUP is a real stepped flow — 1 choose passphrase · 2 the warning with
//  the MANDATORY understanding checkbox (her exact sentence) · 3 create ·
//  4 the recovery phrase, MANDATORY (CF-5: generate → write down → confirm;
//  setup cannot complete without it — and because step 4 IS the
//  `enrolled(hasRecoveryWrap: false)` state, a relaunch mid-setup resumes
//  exactly there). ENROLLMENT (passphrase, or the recovery phrase as the
//  disaster road — the reveal LOOKS like a button, CF-3). REGENERATE gates
//  behind the passphrase (CF-2). CHANGE PASSPHRASE (current passphrase OR
//  recovery phrase — Round 7). The FORGET door (CF-11 — confirmed,
//  destructive). The BIOMETRIC unlock policy (CF-12's ruling — biometric
//  or the passphrase, never the device passcode; per-platform naming).
//
//  The warning wording + the disclosure copy ride the plan file's GATE
//  RATIFY + copy/flow record (L13) — change them there and here together.
//
//  Phase 14b CROSSOVER ROUND: this view is now the Account sheet's
//  ENCRYPTION TAB content (CF-14 — her ruling: the Encryption surface
//  folds UNDER the Account button; AccountView owns the sheet chrome —
//  scroll, padding, the CF-1 borderless Close — and this view renders the
//  states). CF-16: the honest REPLACED state — a device that slept
//  through a re-key explains itself and offers the ordinary unlock roads
//  instead of failing generically.
//

import SwiftUI
import VariorumCore

struct EncryptionView: View {
    let services: AppServices
    /// D1: the phone's styling seam (nil on the Mac ALWAYS — the
    /// environment accessor compiles to nil there, so every styled arm
    /// in this file is phone-only by construction).
    @Environment(\.sharedPageStyle) private var pageStyle

    /// pre-13x 3a: the sync-setup ceremony's brain (copy §2a), made when the
    /// account has no vault and the user opens the door; nil = the door.
    @State private var setup: SyncEnrollmentModel?

    @State private var enrollPassphrase = ""
    @State private var usePhraseInstead = false
    @State private var phraseEntry = ""

    /// The freshly-generated words, shown ONCE; nothing lands until the
    /// re-entry confirms (Round 5 item 3's order). NOT cleared on a failed
    /// land — the words she wrote down must stay the words on screen.
    @State private var generatedWords: [String]?
    @State private var confirmEntry = ""
    @State private var confirmMismatch = false
    /// True while the generate flow is REPLACING an existing wrap (the
    /// mandatory-phrase arm never is; kept for the confirm section's line).
    @State private var replacingWrap = false
    /// pre-13x 3b: the open re-wrap door (copy §4's change passphrase /
    /// regenerate twelve words) — ONE brain, rendered inline; nil = the doors.
    @State private var keyDoor: KeyDoorModel?

    /// 13l Act 5 (row 18): the sanity check's own model — the vault client
    /// straight from the composition root, never through
    /// `EncryptionSession`, whose flows all adopt custody. Read-only by
    /// construction.
    @State private var secretCheck: SecretCheckModel

    /// pre-13x 3b: the Account sheet's dismissal — Replace All Keys opens on
    /// the CONTROLLER (held across the re-key's reopen, 2b's precedent), so
    /// this sheet closes first and the main window presents the ceremony.
    @Environment(\.dismiss) private var dismiss

    private var encryption: EncryptionSession { services.encryption }

    /// Explicit because of `secretCheck` (13l row 18), which has no default:
    /// it needs the composition root's vault client. Every other piece of
    /// state here keeps its default, and the one call site is unchanged.
    init(services: AppServices) {
        self.services = services
        _secretCheck = State(initialValue: SecretCheckModel(client: services.keyVault))
    }

    // MARK: - The copy (GATE RATIFY / her walk — the record carries these)

    /// CF-13: the whole phrase is the secret.
    static let wholePhraseIsTheSecret =
        "All 12 words together, in order, are the secret — no single word is a password. "
        + "Anyone with the whole phrase can unlock your synced writing; anyone with less "
        + "has nothing."

    /// Item 8: the disclosure list's USER-FACING copy (staged for her walk;
    /// the technical column list is the plan file's GATE RATIFY block).
    static let disclosureCopy =
        "Everything you write is sealed on your devices before it syncs: your text and "
        + "takes, titles, book and chapter names, tags, comments, commit messages, and "
        + "reference names and links. The server can never read any of it.\n\n"
        + "What the server still sees is the shape, not the words: that an entry exists on "
        + "a day, how items are ordered and connected, their sizes, when you sync, and "
        + "settings switches. Sealed words plus visible shape is what lets sync work "
        + "without trusting the server."

    /// CF-16's replaced state's headline — pre-13x 5b (ledger 66): copy §4's
    /// precised sentence for the UN-FOLLOWED device, through the one copy
    /// constant (the device word by platform); 14b's *"…Enter your
    /// passphrase to re-enroll."* retired with the re-enroll framing (the
    /// door beneath is the follow).
    static let keysReplacedExplanation = ProtectionCopy.keysReplacedHeadline

    /// Ladder R1-1: the persisted-marker banner's prompt — a re-key
    /// started on this device and never completed (a crash or a mid-run
    /// failure), so sync is paused on the engine's own refusal and the
    /// rerun road is spoken HERE, with the door right beside it
    /// (fire-and-DO). The brain's rerun heals every window state,
    /// whichever section renders below.
    static let rekeyIncompletePrompt =
        "Key replacement didn't finish on this device — sync is paused until it completes. "
        + "Run Replace Encryption Keys again; nothing is lost, and your writing is untouched."

    /// Ladder R2-1: the same owed-re-key signal over the SIGNED-OUT arm,
    /// where the completing door could only fail (the brain needs a
    /// session) with a rerun prescription that mis-directs — the
    /// prescription becomes sign-in-first and the door waits below.
    static let rekeyIncompleteSignedOutPrompt =
        "Key replacement didn't finish on this device — sync is paused until it completes. "
        + "Sign in first, then run Replace Encryption Keys from this tab; nothing is lost."

    /// VX-110 (the ticket's item 2 — VX-99 round 3's NIT): the banner names
    /// the PENDING MARKER's act — the panes' one rule. A marker that enters
    /// Castle (the switch, or a follow into Castle) speaks
    /// `ceremonyResumeTitle`, on either arm (its resume needs no session on
    /// the local road, so "sign in first" would mis-direct); a key
    /// replacement keeps the two sentences above; an unknown act (no read
    /// wired, an undecodable marker) keeps them too.
    static func rekeyIncompletePrompt(for act: CeremonyAct?, signedIn: Bool) -> String {
        if let act, act.entersCastle { return ProtectionCopy.ceremonyResumeTitle(act) }
        return signedIn ? rekeyIncompletePrompt : rekeyIncompleteSignedOutPrompt
    }

    /// The banner's door, by the same act (the panes' label rule).
    static func rekeyIncompleteDoorLabel(for act: CeremonyAct?) -> String {
        act?.entersCastle == true ? ProtectionCopy.finishEnteringCastleDoor : ProtectionCopy.finishReplacingKeysDoor
    }

    /// ISO-8601 stamp → a human date ("Aug 28, 2026"); nil in, nil out.
    static func displayDate(_ stamp: String?) -> String? {
        guard let stamp, stamp.count >= 10 else { return nil }
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.dateFormat = "yyyy-MM-dd"
        guard let day = dayFormatter.date(from: String(stamp.prefix(10))) else {
            return String(stamp.prefix(10))
        }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return display.string(from: day)
    }

    /// CF-12: per-platform biometric naming — never the WebAuthn credential
    /// word (her terminology ruling; the TerminologyPinTests walk enforces
    /// it over every shipped source, comments included).
    static var biometricName: String {
        #if os(macOS)
        "Touch ID"
        #else
        "Face ID or Touch ID"
        #endif
    }


    var body: some View {
        // CF-14: no chrome of its own — the tabbed Account sheet carries
        // the scroll, the padding, and the CF-1 borderless Close; this view
        // is the Encryption tab's content.
        VStack(alignment: .leading, spacing: 14) {
            // Ladder R1-1: the unfinished-re-key banner rides ABOVE the
            // state switch — every arm below (enrolled, mandatory-phrase,
            // keysReplaced, …) is a state a mid-re-key crash can land in,
            // and the completing door must be one act away in all of them.
            if encryption.rekeyIncomplete {
                if case .signedOut = encryption.state {
                    // Ladder R2-1: over the signed-out arm the door's run
                    // could only fail — the signal stays, the prescription
                    // is sign-in-first, the door returns with the session.
                    // VX-110: by the marker's act.
                    Text(Self.rekeyIncompletePrompt(for: encryption.rekeyIncompleteAct, signedIn: false))
                        .pageCaptionWarning(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    rekeyIncompleteBanner
                }
                PageDivider(pageStyle)
            }
            if encryption.libraryOwnerIsForeign?() == true {
                // pre-13x 3a (§3.6 / copy §3): the rows' owner is another
                // account — the sentence with its doors, over every arm.
                foreignOwnerSection
            } else {
            switch encryption.state {
            case .unknown:
                TravellingDotsIndicator(pageStyle: pageStyle)
                Text("Checking this account's encryption state…")
                    .pageSecondary(pageStyle)
            case .signedOut:
                // pre-13x 5a: copy §4's signed-out line (the Sign In… door is
                // the Account tab's, one tab over).
                Text(ProtectionCopy.signedOutLine)
                    .pageSecondary(pageStyle)
            case .newerFormat:
                Text("This account's encryption was set up by a newer version of Variorum. Update the app to unlock sync.")
                    .pageWarning(pageStyle)
            case .noVault:
                setupSection
            case .notEnrolled(let hasRecoveryWrap):
                enrollmentSection(hasRecoveryWrap: hasRecoveryWrap)
            case .keysReplaced(let hasRecoveryWrap):
                keysReplacedSection(hasRecoveryWrap: hasRecoveryWrap)
            case .enrolled(let hasRecoveryWrap):
                if hasRecoveryWrap {
                    enrolledSection
                } else {
                    // Step 4 of 4 — mandatory (CF-5): the flow's own last
                    // step, and the resume point after any interruption.
                    mandatoryPhraseSection
                }
            }
            }

            if encryption.busy {
                // pre-13x 5b (ledger 32): the ceremonies' original indicator.
                TravellingDotsIndicator(pageStyle: pageStyle)
            }
            if let error = encryption.lastError {
                Text(error).pageCaptionError(pageStyle)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(6)
            }
        }
        .task { await encryption.refresh() }
    }

    // MARK: - pre-13x 3a: the rows' owner is another account (copy §3)

    /// Copy §3's sentence with *Connect…* (the adopt road — decision 17) and
    /// Sign Out; Delete Account… stays the Account tab's one door.
    @ViewBuilder
    private var foreignOwnerSection: some View {
        Text(ProtectionCopy.keysDontMatchThisLibrary)
            .pageWarning(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        HStack {
            if let connectDoor = encryption.connectDoor {
                PageDoor(ProtectionCopy.connectDoor, style: pageStyle) { connectDoor() }
                    .disabled(encryption.busy)
            }
            PageDoor("Sign Out", form: .inlineAct, style: pageStyle) {
                Task { await services.signOutVariorum() }
            }
        }
    }

    // MARK: - Setup (the first device of an account) — copy §2a (pre-13x 3a)

    /// Copy §4's signed-in-no-sync line with *Turn On Sync…*; the ceremony
    /// renders inline once opened (both platforms — the ONE brain).
    @ViewBuilder
    private var setupSection: some View {
        if let setup {
            SyncEnrollmentView(model: setup, pageStyle: pageStyle) { self.setup = nil }
        } else {
            Text(ProtectionCopy.syncNotSetUpLine)
                .pageProse(pageStyle)
            if encryption.storeTie != nil {
                PageDoor(ProtectionCopy.turnOnSyncDoor, style: pageStyle) {
                    setup = SyncEnrollmentModel.make(services: services)
                }
                .disabled(encryption.busy)
            } else {
                Text("Sync setup isn't available in this build.")
                    .pageCaption(pageStyle)
            }
        }
    }

    // MARK: - Step 4 of 4 — the MANDATORY recovery phrase (CF-4/5/13)

    private var mandatoryPhraseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PageHeading("Step 4 of 4 — Your recovery phrase (required)", style: pageStyle)
            Text("If you ever forget the passphrase, these 12 words are the only other way into your synced writing. Setup isn't finished until you've written them down and confirmed them — closing now just leaves this step waiting.")
                .pageCaptionWarning(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
            if let words = generatedWords {
                phraseConfirmSection(words: words, cancellable: false)
            }
        }
        .onAppear {
            // Generation is automatic — the step IS the phrase; there is no
            // optional-looking offer to decline (CF-5).
            if generatedWords == nil {
                replacingWrap = false
                generatedWords = encryption.generatePhrase()
            }
        }
    }

    // MARK: - The 12-words entry field (one shape, three arms)

    /// The phrase entry field shared by the confirm, enrollment, and
    /// change-passphrase arms: autocorrect off, and on the phone
    /// auto-capitals off too — BIP-39 words are lowercase; validation
    /// folds case, but a capitalized first word READS as a wrong entry
    /// (the AuthViews emailField precedent). privacySensitive: typed
    /// words are the same secret as the displayed phrase, so the mobile
    /// shell's snapshot cover redacts them alike.
    private func phraseEntryField(_ label: String, text: Binding<String>) -> some View {
        let field = TextField(label, text: text, axis: .vertical)
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

    // MARK: - The phrase display + confirm-by-re-entry (Round 5 item 3; CF-4)

    @ViewBuilder
    private func phraseConfirmSection(words: [String], cancellable: Bool) -> some View {
        Text(Self.wholePhraseIsTheSecret)
            .pageCaptionWarning(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        Text(words.enumerated().map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "   "))
            .font(.body.monospaced())
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            // The one place the 12 words render. privacySensitive is inert
            // until a shell applies a .privacy redaction — the mobile
            // shell does, for the app-switcher snapshot (SnapshotPrivacy);
            // the Mac applies none and is byte-identical in behavior.
            // D1: the phrase card wraps OUTSIDE this Text — the mark and
            // the mono rendering stay exactly where they were.
            .privacySensitive()
            .pagePhraseCard(pageStyle)
        Text("1. Write the 12 words down — on paper, or in a password manager.")
            .pageCaption(pageStyle)
        Text("2. Type them back, in order, to confirm:")
            .pageCaption(pageStyle)
        phraseEntryField("The 12 words, separated by spaces", text: $confirmEntry)
        if confirmMismatch {
            Text("That doesn't match the phrase above — check what you wrote down.")
                .pageCaptionError(pageStyle)
        }
        if replacingWrap {
            Text("The phrase you have now keeps working until this confirm lands — then it stops, everywhere.")
                .pageCaption(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
        }
        HStack {
            PageDoor("Confirm — I Wrote It Down", style: pageStyle) {
                let entered = EncryptionSession.words(from: confirmEntry)
                    .map { $0.lowercased() }
                guard entered == words else {
                    confirmMismatch = true
                    return
                }
                confirmMismatch = false
                let replace = replacingWrap
                Task {
                    await encryption.landRecoveryWrap(
                        confirmedWords: words, allowReplace: replace)
                    if encryption.lastError == nil {
                        generatedWords = nil
                        confirmEntry = ""
                        replacingWrap = false
                    }
                }
            }
            .disabled(encryption.busy || confirmEntry.isEmpty)
            if cancellable {
                PageDoor("Cancel", form: .inlineAct, style: pageStyle) {
                    generatedWords = nil
                    confirmEntry = ""
                    confirmMismatch = false
                    replacingWrap = false
                }
            }
        }
    }

    // MARK: - Enrollment (new device) + the shared unlock roads (CF-3)

    /// pre-13x 3a — ENROLL's faces (copy §2d) by the controller's facts: the
    /// Standard waiting face (the silent road lands at the next ready; the
    /// roads beside it); Castle's title + roads; (c) the re-key sentence
    /// under the title; (d) the consent with Join / Cancel. Without facts
    /// (no controller wired) the 14b generic face stands.
    @ViewBuilder
    private func enrollmentSection(hasRecoveryWrap: Bool) -> some View {
        if let facts = encryption.enrollFacts?() {
            if facts.castleBornJoinsStandard {
                joinStandardSection(facts: facts, hasRecoveryWrap: hasRecoveryWrap)
            } else if facts.accountPosture == .standard {
                Text(ProtectionCopy.waitingTitle)
                    .pageProse(pageStyle)
                Text(ProtectionCopy.waitingBody)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                if facts.appleState == .differentAppleID {
                    Text(ProtectionCopy.waitingDifferentAppleID)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                unlockRoads(offerPhraseRoad: hasRecoveryWrap, joining: true)
            } else {
                Text(ProtectionCopy.joinCastleTitle)
                    .pageProse(pageStyle)
                if facts.standardBornJoinsCastle {
                    Text(ProtectionCopy.joinCastleRekeysSentence)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                unlockRoads(offerPhraseRoad: hasRecoveryWrap, joining: true)
            }
        } else {
            Text("Unlock sync on this device")
                .pageProse(pageStyle)
            Text("Enter your encryption passphrase to unwrap this account's keys.")
                .pageCaption(pageStyle)
            unlockRoads(offerPhraseRoad: hasRecoveryWrap)
        }
    }

    /// (d): the consent sentence (PROVISIONAL words — ledger 46) with Join /
    /// Cancel; A opens the vault's copy when it is the one, else the roads
    /// (typed) run the same join. After Cancel: one line and a re-offer door.
    @ViewBuilder
    private func joinStandardSection(facts: EnrollFacts, hasRecoveryWrap: Bool) -> some View {
        if encryption.declinedStandardJoin {
            Text(ProtectionCopy.joinLaterLine)
                .pageCaption(pageStyle)
            PageDoor(ProtectionCopy.joinReofferDoor, form: .inlineAct, style: pageStyle) {
                encryption.declinedStandardJoin = false
            }
        } else {
            Text(ProtectionCopy.joinStandardConsent)
                .pageWarning(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
            if facts.appleState == .matched {
                HStack {
                    PageDoor(ProtectionCopy.joinDoor, style: pageStyle) {
                        Task { await encryption.joinStandard() }
                    }
                    .disabled(encryption.busy)
                    PageDoor(ProtectionCopy.joinCancelDoor, form: .inlineAct, style: pageStyle) {
                        encryption.declineStandardJoin()
                    }
                }
            } else {
                if facts.appleState == .differentAppleID {
                    Text(ProtectionCopy.waitingDifferentAppleID)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                unlockRoads(offerPhraseRoad: hasRecoveryWrap, joining: true, joinsStandard: true)
                PageDoor(ProtectionCopy.joinCancelDoor, form: .inlineAct, style: pageStyle) {
                    encryption.declineStandardJoin()
                }
            }
        }
    }

    /// CF-12: custody exists here but this launch hasn't unlocked — the
    /// biometric door first, the passphrase (and phrase) roads beside it.

    /// CF-16: the honest replaced state — custody exists, but the account
    /// was re-keyed after this device enrolled. The headline is the ruled
    /// copy; the roads are the ORDINARY unlock roads (passphrase, plus the
    /// phrase reveal when the new vault carries a wrap) — the enroll save
    /// overwrites the stale custody wholesale (the step-0 proven class).
    @ViewBuilder
    private func keysReplacedSection(hasRecoveryWrap: Bool) -> some View {
        Text(Self.keysReplacedExplanation)
            .pageWarning(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if let followDoor = encryption.followDoor {
            // pre-13x 2c (§7): the un-followed state — every key door says
            // *pick up your new keys first*, and the one door is the FOLLOW
            // (M′ from the vault, custody replaced, the library re-keyed,
            // custody behind the gate), never the bare 14c re-enroll.
            Text(ProtectionCopy.pickUpKeysFirst)
                .pageCaption(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
            // Row 10 (ledger 54): the label says what the door will DO.
            PageDoor(
                ProtectionCopy.followEnterDoorLabel(
                    asksNothing: encryption.followDoorAsksNothing?() ?? false),
                style: pageStyle
            ) { followDoor() }
                .disabled(encryption.busy)
        } else {
            Text("The keys this device holds were replaced after it enrolled — sync stays paused until you re-enroll; nothing is lost while paused.")
                .pageCaption(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
            unlockRoads(offerPhraseRoad: hasRecoveryWrap)
        }
    }

    /// `joining` (pre-13x 3a): copy §2d's doors — *Join* and *Use my twelve
    /// words instead.*; `joinsStandard` routes the typed secret through the
    /// (d) join (custody, then the follow into Standard).
    @ViewBuilder
    private func unlockRoads(offerPhraseRoad: Bool, joining: Bool = false, joinsStandard: Bool = false) -> some View {
        if !usePhraseInstead {
            PeekableSecretField(
                label: "Encryption passphrase", text: $enrollPassphrase,
                onSubmit: { enrollNow(joinsStandard: joinsStandard) })
                .pageFieldChrome(pageStyle)
            PageDoor(joining ? ProtectionCopy.joinDoor : "Unlock", style: pageStyle) { enrollNow(joinsStandard: joinsStandard) }
                .disabled(encryption.busy || enrollPassphrase.isEmpty)
            if offerPhraseRoad {
                // CF-3: the reveal is a real, visibly-bordered button —
                // never something that reads as static hint text (the
                // styled .bordered arm keeps a visible border too).
                PageDoor(joining ? ProtectionCopy.joinWordsDoor : "Use my recovery phrase instead", form: .bordered,
                         style: pageStyle) { usePhraseInstead = true }
            }
        } else {
            phraseEntryField("The 12 recovery words, separated by spaces", text: $phraseEntry)
            PageDoor(joining ? ProtectionCopy.joinDoor : "Unlock with Recovery Phrase", style: pageStyle) {
                let entry = phraseEntry
                phraseEntry = ""
                if joinsStandard {
                    Task { await encryption.joinStandard(typedWords: EncryptionSession.words(from: entry)) }
                } else {
                    Task { await encryption.enroll(recoveryWordsText: entry) }
                }
            }
            .disabled(encryption.busy || phraseEntry.isEmpty)
            PageDoor("Back to passphrase entry", form: .bordered, style: pageStyle) {
                usePhraseInstead = false
            }
        }
    }

    private func enrollNow(joinsStandard: Bool = false) {
        guard !enrollPassphrase.isEmpty, !encryption.busy else { return }
        let passphrase = enrollPassphrase
        enrollPassphrase = ""
        if joinsStandard {
            Task { await encryption.joinStandard(typedPassphrase: passphrase) }
        } else {
            Task { await encryption.enroll(passphrase: passphrase) }
        }
    }

    // MARK: - Enrolled (custody + the doors)

    @ViewBuilder
    private var enrolledSection: some View {
        // pre-13x 3b: copy §4's enrolled line + keystone 3.
        Text(ProtectionCopy.enrolledLine)
            .pageProse(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        Text(ProtectionCopy.keystoneAccountPassword)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        // Her sharpest question's answer, standing where the fact it
        // explains is stated (memo §2's keystone).
        Text(ProtectionCopy.keystoneUnlockedDevice)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if let seconds = encryption.lastKDFSeconds {
            // L12: the on-device KDF number, readable straight off the flow.
            Text(String(format: "Passphrase key derivation took %.2f s on this device.", seconds))
                .pageCaption(pageStyle)
        }

        PageDivider(pageStyle)

        // pre-13x 3b (copy §4): the two RE-WRAP doors over ONE brain
        // (`KeyDoorModel`), rendered inline; P-2 — only when the facts are
        // wired. The 14b regenerate gate and change-passphrase sections
        // retired into it; the 13p reset door merged into its forgot road.
        if let keyDoor {
            KeyDoorView(model: keyDoor, pageStyle: pageStyle) { self.keyDoor = nil }
        } else if encryption.keyDoorFacts != nil {
            HStack {
                PageDoor("Change Passphrase…", form: .inlineAct, style: pageStyle) {
                    keyDoor = KeyDoorModel.make(kind: .changePassphrase, services: services)
                }
                .disabled(encryption.busy)
                PageDoor(ProtectionCopy.regenerateWordsDoor, form: .inlineAct, style: pageStyle) {
                    keyDoor = KeyDoorModel.make(kind: .regenerateWords, services: services)
                }
                .disabled(encryption.busy)
            }
        }

        PageDivider(pageStyle)

        // 13l Act 5 (ledger row 18) — the SANITY CHECK, her 2026-08-19 ask.
        // It sits here, on the enrolled surface, because this is the state
        // where neither secret is ever exercised: the device unwrapped once
        // and the Keychain has carried it ever since (the R-6 cadence). In
        // every other state a real unlock door is already on screen and
        // verifies by being used. It writes nothing — see `SecretCheck.swift`.
        SecretCheckSection(
            framing: .sanityCheck, offersRecoveryPhrase: true, model: secretCheck)

        PageDivider(pageStyle)

        // pre-13x 3b (copy §4): REPLACE ALL KEYS — the ceremony on the
        // controller (P-2: rendered only when the root wired the door);
        // while a re-key is owed the banner at the top carries the door.
        if !encryption.rekeyIncomplete, encryption.replaceKeysDoor != nil {
            PageDoor(ProtectionCopy.replaceKeysOpenDoor, form: .inlineAct, style: pageStyle) {
                openReplaceKeys(passphrase: nil, words: nil)
            }
            .disabled(encryption.busy)

            PageDivider(pageStyle)
        }

        disclosureSection
    }

    /// The server-visibility disclosure. nil arm: the pre-D1 construction
    /// exactly; styled arm: the same DisclosureGroup with a voice-cased
    /// label and the voice's small type (content identical — the ruled
    /// disclosure copy renders as written).
    @ViewBuilder
    private var disclosureSection: some View {
        if let style = pageStyle {
            DisclosureGroup {
                Text(Self.disclosureCopy)
                    .pageCaption(pageStyle)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            } label: {
                Text(style.chrome("What the server can and can't see"))
                    .font(style.tokens.small)
                    .foregroundStyle(style.tokens.accent)
                    .accessibilityLabel("What the server can and can't see")
            }
        } else {
            DisclosureGroup("What the server can and can't see") {
                Text(Self.disclosureCopy)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
            .font(.caption)
        }
    }

    // MARK: - The unfinished-re-key banner (ladder R1-1)

    /// The persisted marker's surface voice: the prompt plus the
    /// completing door RIGHT HERE — reachable from every state arm, so
    /// the rerun is one act away whichever window the crash left.
    @ViewBuilder
    private var rekeyIncompleteBanner: some View {
        // VX-110 (item 2): the words and the door name the marker's act.
        Text(Self.rekeyIncompletePrompt(for: encryption.rekeyIncompleteAct, signedIn: true))
            .pageCaptionWarning(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if encryption.replaceKeysDoor != nil {
            // pre-13x 3b: the same door — the root opens the marker's RESUME
            // when one is pending (the ceremony's resume road).
            PageDoor(Self.rekeyIncompleteDoorLabel(for: encryption.rekeyIncompleteAct),
                     form: .inlineAct, style: pageStyle) {
                openReplaceKeys(passphrase: nil, words: nil)
            }
            .disabled(encryption.busy)
        }
    }

    /// pre-13x 3b: the Account sheet closes, then the ceremony opens on the
    /// controller — the main window's bar presents it (both platforms).
    private func openReplaceKeys(passphrase: String?, words: [String]?) {
        guard let door = encryption.replaceKeysDoor else { return }
        dismiss()
        door(passphrase, words)
    }
}
