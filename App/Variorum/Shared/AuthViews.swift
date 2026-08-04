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

import SwiftUI
import VariorumCore

struct AccountView: View {
    let services: AppServices
    @Environment(\.dismiss) private var dismiss
    @State private var variorumEmail = ""
    @State private var variorumPassword = ""
    @State private var fragmentsEmail = ""
    @State private var fragmentsPassword = ""
    @FocusState private var focus: Field?

    private enum Field { case variorumEmail, variorumPassword, bridgeEmail, bridgePassword }

    private var canSignInVariorum: Bool {
        ProjectConfig.variorumConfigured && !services.account.busy
            && !variorumEmail.isEmpty && !variorumPassword.isEmpty
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account").font(.headline)

            if !ProjectConfig.variorumConfigured {
                Text("Project keys are not filled in yet (ProjectConfig.swift) — sign-in is dormant.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: The Variorum session (the suite identity)
            if let signedIn = services.account.variorum {
                HStack {
                    Text("Signed in\(signedIn.email.map { " as \($0)" } ?? "")")
                    Spacer()
                    Button("Sign out") {
                        Task { await services.signOutVariorum() }
                    }
                }
                Text("Sync runs under this account; everything you write is owned by it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Sign in with your account email and password:")
                emailField("Email", text: $variorumEmail)
                    .focused($focus, equals: .variorumEmail)
                    .onSubmit { focus = .variorumPassword }
                SecureField("Password", text: $variorumPassword)
                    .textContentType(.password)  // AutoFill (R1-5)
                    .focused($focus, equals: .variorumPassword)
                    .onSubmit { signInVariorum() }
                Button("Sign In") { signInVariorum() }
                    .disabled(!canSignInVariorum)
                Text("One account for the suite — sync and everything you write run under it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // MARK: The Fragments journal connection (the bridge's session)
            if let fragments = services.account.fragments {
                HStack {
                    Text("Fragments journal connected\(fragments.email.map { " (\($0))" } ?? "")")
                    Spacer()
                    Button("Disconnect") {
                        Task { await services.disconnectFragmentsJournal() }
                    }
                }
            } else {
                Text("Connect the Fragments journal (two-way bridge):")
                emailField("Fragments email", text: $fragmentsEmail)
                    .focused($focus, equals: .bridgeEmail)
                    .onSubmit { focus = .bridgePassword }
                SecureField("Fragments password", text: $fragmentsPassword)
                    .textContentType(.password)  // AutoFill (R1-5)
                    .focused($focus, equals: .bridgePassword)
                    .onSubmit { connectBridge() }
                Button("Connect") { connectBridge() }
                    .disabled(!canConnectBridge)
                Text("Signs in directly to the Fragments project; only the session is kept, never the password.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if services.account.busy {
                ProgressView().controlSize(.small)
            }
            if let error = services.account.lastError {
                Text(error).font(.caption).foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        // Mac-only floor (review round 1, R1-2): an iPhone sheet proposes
        // ~393 pt — a forced 440 clips the form on the phase's own phone
        // door. macOS keeps the 9c-era minimum.
        #if os(macOS)
        .frame(minWidth: 440)
        #endif
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
