//
//  PeekableSecretField.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13u Act 10 wave 2a (item 3) — **the ONE eye/peek secret field.**
//  Her spec: the toggle lands on the passphrase set screen AND its
//  SecureField siblings (`SecretCheck`, the lobby's passphrase field) —
//  one shared control, not three ad-hoc ones. Every passphrase entry in
//  the app routes through this view; chrome stays the caller's (a
//  `.textFieldStyle` or `.pageFieldChrome` chained on the control reaches
//  the inner field / wraps the pair, so each surface keeps its own look).
//
//  The peek reveals ONLY while toggled — the field returns to secure on
//  its own when the text is cleared, so a submitted secret never lingers
//  readable. `privacySensitive` rides the whole pair (the mobile shell's
//  snapshot cover redacts a revealed secret exactly like a phrase card).
//

import SwiftUI

struct PeekableSecretField: View {
    let label: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil

    @State private var revealed = false

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if revealed {
                    plainField
                } else {
                    SecureField(label, text: $text)
                }
            }
            .onSubmit { onSubmit?() }
            Button {
                revealed.toggle()
            } label: {
                Image(systemName: revealed ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(revealed ? "Hide the secret" : "Show the secret")
            .help(revealed ? "Hide what you typed" : "Show what you typed")
        }
        .privacySensitive()
        .onChange(of: text) { _, newValue in
            // A cleared field (submit paths empty the binding) drops the
            // reveal — the next secret starts hidden.
            if newValue.isEmpty { revealed = false }
        }
    }

    private var plainField: some View {
        let field = TextField(label, text: $text)
            .autocorrectionDisabled()
        #if os(iOS)
        return field.textInputAutocapitalization(.never)
        #else
        return field
        #endif
    }
}
