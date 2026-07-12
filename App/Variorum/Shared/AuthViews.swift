//
//  AuthViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 5 — the sign-in surface replacing Phase 8's paste-in
//  (SyncSetupView, deleted). Functional and unstyled (Phase 13 owns
//  beauty). Two sections, two sessions:
//   - the VARIORUM sign-in: route A's one-button delegated flow ("her
//    Fragments account IS her Variorum account" — the browser sheet runs
//    Fragments' consent page; Variorum mints the session);
//   - the FRAGMENTS JOURNAL connection: the bridge's direct
//     Fragments-project session (QUESTIONS #16, ratified (c)) — her
//     Fragments email+password once; only the session persists.
//

import SwiftUI
import VariorumCore

struct AccountView: View {
    let services: AppServices
    @Environment(\.dismiss) private var dismiss
    @State private var fragmentsEmail = ""
    @State private var fragmentsPassword = ""
    @FocusState private var bridgeFocus: BridgeField?

    private enum BridgeField { case email, password }

    private var canConnectBridge: Bool {
        ProjectConfig.fragmentsConfigured && !services.account.busy
            && !fragmentsEmail.isEmpty && !fragmentsPassword.isEmpty
    }

    /// One door for the button AND the fields' Return key (the sitting,
    /// 2026-07-11: Return in these fields was a silent no-op — the form
    /// only worked via the Connect button).
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
                Text("Project keys are not filled in yet (ProjectConfig.swift) — sign-in is dormant until the Phase 9c cutover.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: The Variorum session (the identity)
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
                Button("Sign in with Fragments…") {
                    Task { await services.signInWithFragments() }
                }
                .disabled(!ProjectConfig.variorumConfigured || services.account.busy)
                Text("One account: your Fragments sign-in becomes your Variorum session.")
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
                TextField("Fragments email", text: $fragmentsEmail)
                    .autocorrectionDisabled()
                    .focused($bridgeFocus, equals: .email)
                    .onSubmit { bridgeFocus = .password }
                SecureField("Fragments password", text: $fragmentsPassword)
                    .focused($bridgeFocus, equals: .password)
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
        .frame(minWidth: 440)
    }
}
