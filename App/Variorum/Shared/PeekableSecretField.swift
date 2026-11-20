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
    #if os(iOS)
    /// VM-47 (the walk's W-A10): inside the phone's field (`phoneField`) the
    /// placeholder is the phone layer's corrected faint, never iOS's own grey;
    /// outside one it is nil and each field is built exactly as before. The
    /// Mac never reads it — its two fields are the same constructors as ever.
    @Environment(\.phoneFieldPrompt) private var promptInk
    #endif

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if revealed {
                    plainField
                } else {
                    secureField
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

    @ViewBuilder
    private var secureField: some View {
        #if os(iOS)
        if let promptInk {
            SecureField(label, text: $text, prompt: Text(label).foregroundStyle(promptInk))
        } else {
            SecureField(label, text: $text)
        }
        #else
        SecureField(label, text: $text)
        #endif
    }

    private var plainField: some View {
        #if os(iOS)
        return phonePlainField
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        #else
        return TextField(label, text: $text)
            .autocorrectionDisabled()
        #endif
    }

    #if os(iOS)
    @ViewBuilder
    private var phonePlainField: some View {
        if let promptInk {
            TextField(label, text: $text, prompt: Text(label).foregroundStyle(promptInk))
        } else {
            TextField(label, text: $text)
        }
    }
    #endif
}
