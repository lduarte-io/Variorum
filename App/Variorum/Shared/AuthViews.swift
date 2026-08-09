//
//  AuthViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 5 — the sign-in surface replacing Phase 8's paste-in
//  (SyncSetupView, deleted). Functional and unstyled (Phase 13 owns
//  beauty). Two sections, two sessions:
//   - the VARIORUM sign-in: the SUITE account, direct email+password
//     against the Variorum project (Phase 14a, round 0h — the delegated
//     browser flow is retired);
//   - the FRAGMENTS JOURNAL connection: the bridge's direct
//     Fragments-project session (QUESTIONS #16, shape (c) — the active
//     road until the Fragments batch swaps it to the suite-delegated
//     flow).
//
//  Phase 14b CROSSOVER ROUND (CF-14, her ruling): the Account sheet gains
//  TABS — Account · Encryption ("account will one day show payment") —
//  both form factors through this one shared seam. The sync row's
//  separate "Encryption…" door retires into the Encryption tab; the
//  LOCKED state's "Unlock…" door opens that tab DIRECTLY (one act — the
//  refusal's own affordance, never buried). The sheet's dismissal is the
//  CF-1 grammar applied whole: one borderless "Close" in the header row,
//  no defaultAction, never beside an act.
//

import SwiftUI
import VariorumCore

/// CF-14: the Account sheet's tabs. Top-level and nonisolated so the sync
/// row's pure face model can name a door's target tab as plain data.
nonisolated enum AccountTab: String, CaseIterable, Identifiable, Sendable {
    case account = "Account"
    case encryption = "Encryption"
    var id: String { rawValue }
}

struct AccountView: View {
    let services: AppServices
    @Environment(\.dismiss) private var dismiss
    /// D1: the phone's styling seam (nil on the Mac ALWAYS — the
    /// environment accessor compiles to nil there; every styled arm
    /// below is phone-only by construction).
    @Environment(\.sharedPageStyle) private var pageStyle
    @State private var tab: AccountTab
    @State private var variorumEmail = ""
    @State private var variorumPassword = ""
    /// Phase 14c batch 3 (L8): the sign-up face's state — the signed-out
    /// section flips between the sign-in and create-account forms.
    @State private var creatingAccount = false
    @State private var signUpEmail = ""
    @State private var signUpPassword = ""
    @State private var signUpConfirm = ""
    @State private var fragmentsEmail = ""
    @State private var fragmentsPassword = ""
    /// Phase 14c: the deletion door's friction state (her Round-5 ruling).
    @State private var showingDeleteAccount = false
    @State private var deleteConfirmationEntry = ""
    @State private var deletePassphrase = ""
    @FocusState private var focus: Field?

    // MARK: Phase 14c — the deletion door's copy (THE DESIGN 4)

    /// HER PINNED COPY RULE (Round 5, the CF-6 class — her question was
    /// "this won't delete the user's work locally, right?"): the door
    /// MUST say the local copy survives. Byte-pinned.
    static let deleteAccountExplanation =
        "Deleting your account immediately and permanently removes the synced copy of "
        + "your writing, your encryption vault, and the account itself from the server. "
        + "The writing on this device stays on this device and keeps working — and "
        + "anything on your other devices stays there too. Only the account and its "
        + "synced copy are deleted."

    /// The static cancel-first advisory (subscription state warned FIRST —
    /// the ruling's letter; the entitlement read strengthens it when it
    /// succeeds, and batch 3's checkout owns the real cancellation flow).
    static let deleteSubscriptionAdvisory =
        "If you have an active subscription, cancel it first — deleting the account "
        + "does not cancel a purchase on its own."

    /// The typed confirmation naming the consequence (her ruling's first
    /// friction layer; the button stays dead until this exact phrase is
    /// typed).
    static let deleteConfirmationPhrase = "delete my account"

    // MARK: Phase 14c batch 3 — the sign-up face's copy (THE DESIGN 6)

    /// The create-account footnote: the v1 principle spoken at the door —
    /// the app is whole without an account; an account is sign-in for the
    /// tier, never a requirement.
    static let signUpFootnote =
        "One account for the suite — hosted sync runs under it. Variorum works fully "
        + "without an account; everything you write stays on this device either way."

    init(services: AppServices, initialTab: AccountTab = .account) {
        self.services = services
        _tab = State(initialValue: initialTab)
    }

    private enum Field {
        case variorumEmail, variorumPassword
        case signUpEmail, signUpPassword, signUpConfirm
        case bridgeEmail, bridgePassword
    }

    private var canSignInVariorum: Bool {
        ProjectConfig.variorumConfigured && !services.account.busy
            && !variorumEmail.isEmpty && !variorumPassword.isEmpty
    }

    /// The create act's gate: both password entries must agree — the typo
    /// class is real here (a mistyped password locks a stranger out until
    /// a reset email, and the pre-SMTP mailer is tightly capped).
    private var canSignUp: Bool {
        ProjectConfig.variorumConfigured && !services.account.busy
            && !signUpEmail.isEmpty && !signUpPassword.isEmpty
            && signUpPassword == signUpConfirm
    }

    private var canConnectBridge: Bool {
        ProjectConfig.fragmentsConfigured && !services.account.busy
            && !fragmentsEmail.isEmpty && !fragmentsPassword.isEmpty
    }

    /// One door for the button AND the fields' Return key (the 9c sitting,
    /// 2026-07-11: Return in these fields was a silent no-op — the form
    /// only worked via its button).
    private func signInVariorum() {
        guard canSignInVariorum else { return }
        let email = variorumEmail
        let password = variorumPassword
        variorumPassword = ""
        Task { await services.signInWithVariorum(email: email, password: password) }
    }

    private func connectBridge() {
        guard canConnectBridge else { return }
        let email = fragmentsEmail
        let password = fragmentsPassword
        fragmentsPassword = ""
        Task { await services.connectFragmentsJournal(email: email, password: password) }
    }

    /// One door for the button AND the fields' Return key (the sign-in
    /// form's own rule, applied to the create face).
    private func signUp() {
        guard canSignUp else { return }
        let email = signUpEmail
        let password = signUpPassword
        signUpPassword = ""
        signUpConfirm = ""
        Task { await services.signUpWithVariorum(email: email, password: password) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: pageStyle != nil ? 16 : 14) {
                header

                switch tab {
                case .account:
                    accountSection
                case .encryption:
                    EncryptionView(services: services)
                }
            }
            .padding(20)
        }
        // D1 styled arm only (nil renders an empty background — no Mac
        // change): the voice's room behind the sheet, the accent as the
        // control tint (toggles, progress).
        .background {
            if let style = pageStyle {
                style.tokens.room.ignoresSafeArea()
            }
        }
        .tint(pageStyle?.tokens.accent)
        // Mac-only floor (review round 1, R1-2): an iPhone sheet proposes
        // ~393 pt — a forced width clips the form on the phone door. macOS
        // keeps a minimum sized for the wider Encryption tab (its 460, the
        // pre-tabs EncryptionView floor).
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 340)
        #endif
    }

    /// The sheet's header row. nil arm: the pre-D1 construction exactly
    /// (segmented picker + borderless Close). Styled arm: the phone sheet
    /// grammar — the tabs as voiced text doors (the LK7 tab-bar shape:
    /// ink when selected, faint otherwise) with the CF-14 tab mechanism
    /// untouched, and the CF-1 Close as a chrome-cased plain accent door.
    @ViewBuilder
    private var header: some View {
        if let style = pageStyle {
            HStack(alignment: .firstTextBaseline, spacing: 18) {
                ForEach(AccountTab.allCases) { target in
                    Button {
                        tab = target
                    } label: {
                        Text(style.chrome(target.rawValue))
                            .font(style.tokens.heading)
                            .foregroundStyle(
                                tab == target ? style.tokens.ink : style.tokens.faint)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(target.rawValue)
                    .accessibilityAddTraits(tab == target ? [.isSelected] : [])
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text(style.chrome("Close"))
                        .font(style.tokens.small)
                        .foregroundStyle(style.tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.bottom, 2)
        } else {
            HStack {
                // CF-14: the two tabs, rendered as the plain segmented
                // control (functional, unstyled — the Mac's arm).
                Picker("Section", selection: $tab) {
                    ForEach(AccountTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                Spacer()
                // CF-1's grammar, carried to the whole sheet: dismissal
                // is a borderless Close — no defaultAction, never a
                // prominent "Done" beside an act.
                Button("Close") { dismiss() }
                    .buttonStyle(.borderless)
            }
        }
    }

    @ViewBuilder
    private var accountSection: some View {
        if !ProjectConfig.variorumConfigured {
            Text("Project keys are not filled in yet (ProjectConfig.swift) — sign-in is dormant.")
                .pageCaption(pageStyle)
        }

        // MARK: The Variorum session (the suite identity)
        if let signedIn = services.account.variorum {
            HStack(alignment: pageStyle != nil ? .firstTextBaseline : .center) {
                Text("Signed in\(signedIn.email.map { " as \($0)" } ?? "")")
                    .pageProse(pageStyle)
                Spacer()
                PageDoor("Sign out", form: .inlineAct, style: pageStyle) {
                    Task { await services.signOutVariorum() }
                }
            }
            Text("Sync runs under this account; everything you write is owned by it.")
                .pageCaption(pageStyle)

            // Phase 14c batch 3 (L7): the tier's real home — CF-14's own
            // words made good ("account will one day show payment").
            HostedSyncSection(services: services)

            if showingDeleteAccount {
                deleteAccountSection
            } else {
                PageDoor("Delete Account…", form: .destructive, style: pageStyle) {
                    showingDeleteAccount = true
                    Task { await services.refreshSubscriptionNote() }
                }
                .disabled(services.account.busy)
            }
        } else if creatingAccount {
            signUpSection
        } else {
            Text("Sign in with your account email and password:")
                .pageProse(pageStyle)
            emailField("Email", text: $variorumEmail)
                .focused($focus, equals: .variorumEmail)
                .onSubmit { focus = .variorumPassword }
                .pageFieldChrome(pageStyle)
            SecureField("Password", text: $variorumPassword)
                .textContentType(.password)  // AutoFill (R1-5)
                .focused($focus, equals: .variorumPassword)
                .onSubmit { signInVariorum() }
                .pageFieldChrome(pageStyle)
            PageDoor("Sign In", style: pageStyle) { signInVariorum() }
                .disabled(!canSignInVariorum)
            PageDoor("Create an account…", form: .borderless, style: pageStyle) {
                creatingAccount = true
                services.account.lastError = nil
                services.account.lastNotice = nil
            }
            Text("One account for the suite — sync and everything you write run under it.")
                .pageCaption(pageStyle)
        }

        PageDivider(pageStyle)

        // MARK: The Fragments journal connection (the bridge's session)
        if let fragments = services.account.fragments {
            HStack(alignment: pageStyle != nil ? .firstTextBaseline : .center) {
                Text("Fragments journal connected\(fragments.email.map { " (\($0))" } ?? "")")
                    .pageProse(pageStyle)
                Spacer()
                PageDoor("Disconnect", form: .inlineAct, style: pageStyle) {
                    Task { await services.disconnectFragmentsJournal() }
                }
            }
        } else {
            Text("Connect the Fragments journal (two-way bridge):")
                .pageProse(pageStyle)
            emailField("Fragments email", text: $fragmentsEmail)
                .focused($focus, equals: .bridgeEmail)
                .onSubmit { focus = .bridgePassword }
                .pageFieldChrome(pageStyle)
            SecureField("Fragments password", text: $fragmentsPassword)
                .textContentType(.password)  // AutoFill (R1-5)
                .focused($focus, equals: .bridgePassword)
                .onSubmit { connectBridge() }
                .pageFieldChrome(pageStyle)
            PageDoor("Connect", style: pageStyle) { connectBridge() }
                .disabled(!canConnectBridge)
            Text("Signs in directly to the Fragments project; only the session is kept, never the password.")
                .pageCaption(pageStyle)
        }

        if services.account.busy {
            ProgressView().controlSize(.small)
        }
        if let error = services.account.lastError {
            Text(error).pageCaptionError(pageStyle)
        }
        // Phase 14c (L8): the informational line — a notice is a normal
        // outcome (the confirmation email went out), never red.
        if let notice = services.account.lastNotice {
            Text(notice)
                .pageCaption(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Phase 14c batch 3 — the sign-up face (THE DESIGN 6)

    /// The create-account form: the same seam as sign-in, the CF-1
    /// grammar (one act button; the way back is borderless). The confirm
    /// field guards the mistyped-password class. While the signups
    /// toggle is OFF the server refuses every create — the surface
    /// speaks that refusal as a closed door
    /// (`ErrorPresentation.signUpClosedMessage`), never a generic error.
    @ViewBuilder
    private var signUpSection: some View {
        Text("Create an account with an email and password:")
            .pageProse(pageStyle)
        emailField("Email", text: $signUpEmail)
            .focused($focus, equals: .signUpEmail)
            .onSubmit { focus = .signUpPassword }
            .pageFieldChrome(pageStyle)
        SecureField("Password", text: $signUpPassword)
            .textContentType(.newPassword)
            .focused($focus, equals: .signUpPassword)
            .onSubmit { focus = .signUpConfirm }
            .pageFieldChrome(pageStyle)
        SecureField("Confirm password", text: $signUpConfirm)
            .textContentType(.newPassword)
            .focused($focus, equals: .signUpConfirm)
            .onSubmit { signUp() }
            .pageFieldChrome(pageStyle)
        if !signUpConfirm.isEmpty && signUpPassword != signUpConfirm {
            Text("The two password entries don't match yet.")
                .pageCaptionWarning(pageStyle)
        }
        PageDoor("Create Account", style: pageStyle) { signUp() }
            .disabled(!canSignUp)
        PageDoor("Back to sign in", form: .borderless, style: pageStyle) {
            creatingAccount = false
            services.account.lastError = nil
            services.account.lastNotice = nil
        }
        Text(Self.signUpFootnote)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Phase 14c — the deletion door (THE DESIGN 4, her Round-5 ruling)

    /// Immediate hard purge behind real friction: the honest consequence
    /// copy (the local copy SURVIVES — her pinned rule), the subscription
    /// warning first, the TYPED confirmation naming the consequence, and
    /// the encryption passphrase as authorization (verified by a real
    /// vault unwrap in the brain; a vault-less account needs none — the
    /// PROVISIONAL arm, so the field's caption says when it applies).
    @ViewBuilder
    private var deleteAccountSection: some View {
        PageHeading("Delete this account", style: pageStyle)
        Text(Self.deleteAccountExplanation)
            .pageCaptionWarning(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        Text(Self.deleteSubscriptionAdvisory)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if let note = services.account.subscriptionNote {
            Text(note)
                .pageCaptionWarning(pageStyle)
                .fixedSize(horizontal: false, vertical: true)
        }
        TextField("Type “\(Self.deleteConfirmationPhrase)” to continue", text: $deleteConfirmationEntry)
            .autocorrectionDisabled()
            .pageFieldChrome(pageStyle)
        SecureField("Encryption passphrase (if encryption is set up)", text: $deletePassphrase)
            .pageFieldChrome(pageStyle)
        HStack {
            PageDoor("Delete Account Permanently", form: .destructive, style: pageStyle) {
                let passphrase = deletePassphrase
                deletePassphrase = ""
                deleteConfirmationEntry = ""
                showingDeleteAccount = false
                Task {
                    await services.deleteAccount(
                        passphrase: passphrase.isEmpty ? nil : passphrase)
                }
            }
            .disabled(services.account.busy
                      || deleteConfirmationEntry.lowercased()
                          .trimmingCharacters(in: .whitespaces) != Self.deleteConfirmationPhrase)
            PageDoor("Cancel", form: .inlineAct, style: pageStyle) {
                showingDeleteAccount = false
                deleteConfirmationEntry = ""
                deletePassphrase = ""
            }
        }
    }

    /// An email entry field: autocorrect and (on the phone) auto-capitals
    /// off — a capitalized first letter breaks the address silently.
    /// `.textContentType(.username)` (review round 1, R1-5) marks the
    /// login form's account field so AutoFill offers saved credentials —
    /// the platform type resolves per OS (UITextContentType /
    /// NSTextContentType), so no gate is needed.
    private func emailField(_ label: String, text: Binding<String>) -> some View {
        let field = TextField(label, text: text)
            .autocorrectionDisabled()
            .textContentType(.username)
        #if os(iOS)
        return field
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        #else
        return field
        #endif
    }
}
