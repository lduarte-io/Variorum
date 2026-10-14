//
//  MCPSetupMenu.swift
//  Variorum (MAC ONLY)
//
//  **CONNECT A CLIENT — the setup menu** (13n-c U5 — VX-274; her R-13nb-5
//  "Copy setup command" grew a per-client menu: Claude Code · Codex · Any MCP
//  client). Moved out of `MCPPane.swift` and rebuilt at VX-281 U1:
//
//  - **VX-205, her words:** *"the block that has the code command to be
//    copied should be in one of those nice little code blocks you see in UI's
//    everywhere, with the super clear copy icon in the upper right. I feel
//    like there's a very standard look for copying commands, we should follow
//    that."* The setup is a CODE BLOCK — the docs-site idiom: a rounded block
//    on the voice's code tint, a header strip with the client choice on the
//    left and THE copy icon in the upper right, then the text in mono (its
//    setup key shown masked, VX-168).
//  - **The registry shape — the act's NEW FACE, never a second door.**
//    `.mcpCopySetupCommand` stays ONE act on ONE surface: the icon IS its
//    door, the verb ("Copy setup command", her R-13nb-5 words) rendered as
//    the icon's help and accessibility name (P-1's declared ⇔ rendered). The
//    copy itself is untouched: `MCPDoor.copySetupCommand(for:)` mints the
//    fresh key, writes the clipboard, speaks the chosen client's receipt
//    under the block. A visible button beside the icon would be two doors to
//    one act on one surface — the very thing her "standard look" leaves out.
//  - **R-VX184-6 — the setup first, the explainers one line each:** the
//    block leads; under it the chosen client's one line (its sentence behind
//    an (i)), the receipt once a copy lands, the key's line; then the door's
//    own line with the program's path.
//  - **VX-232:** the choice is the DOOR's (`MCPDoor.setupClient`), so the
//    menu always shows the client its receipt names — even after the pane
//    went away and came back. The host binds `client` to the door; choosing
//    another client clears a receipt there (`chooseSetupClient`).
//
//  Its own view so the locked-session harness can draw it alone.
//

import SwiftUI
import VariorumCore

struct MCPSetupMenu: View {
    let door: MCPDoor
    @Binding var client: MCPSetupClient
    let tokens: VoiceTokens

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            MCPSetupCodeBlock(text: door.setupText(for: client), client: $client, tokens: tokens) {
                // VX-168: the copy mints its key first (a store write).
                let copying = client
                await door.copySetupCommand(for: copying)
                return door.note == MCPDoor.Note(text: copying.copiedReceipt, place: .connect)
            }
            ExplainerLine(line: client.summary, detail: client.sentence)
            if let note = door.note, note.place == .connect {
                Text(note.text)
                    .font(.caption.weight(.semibold))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // VX-168 (K2): the shown text masks the key; each copy mints one.
            ExplainerLine(line: MCPPaneCopy.keySummary, detail: MCPPaneCopy.keyLine)
            ExplainerLine(line: MCPPaneCopy.stdioSummary, detail: MCPPaneCopy.stdioLine)
                .padding(.top, 6)
            // Shown WHOLE and selectable (R-13nb-5) — a Debug build's
            // DerivedData path runs several lines at this width.
            Text(verbatim: MCPDoor.shimPath)
                .font(.system(size: 11, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// **The setup as a code block** (VX-205): the client choice in its header
/// strip (left), THE copy icon in its upper right, the setup text under a
/// hairline in mono. After a copy LANDS the icon reads ✓ for a moment (the
/// standard look's own receipt); the door's caption beneath carries the next
/// step.
struct MCPSetupCodeBlock: View {
    /// The text the block shows (the key masked — VX-168).
    let text: String
    @Binding var client: MCPSetupClient
    let tokens: VoiceTokens
    /// THE copy act (`.mcpCopySetupCommand`) — true once the copy landed.
    let copy: () async -> Bool
    @State private var copied = false

    /// How long the ✓ stands after a copy lands.
    static let copiedFlash: Duration = .seconds(1.6)

    /// The icon, at rest and just after a copy (SF Symbols — the standard
    /// glyphs for copy and done).
    static let copySymbol = "doc.on.doc"
    static let copiedSymbol = "checkmark"

    private static var verb: String { CapabilityRegistry.capability(.mcpCopySetupCommand).verb }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Picker(MCPPaneCopy.connectSection, selection: $client) {
                    ForEach(MCPSetupClient.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .controlSize(.small)
                // P-8 (VX-245's form): a segmented control's labels are one line.
                .lineLimit(1)
                .fixedSize()
                Spacer(minLength: 8)
                Button {
                    Task { if await copy() { flash() } }
                } label: {
                    Image(systemName: copied ? Self.copiedSymbol : Self.copySymbol)
                        .font(.system(size: 13))
                        .frame(width: 18, height: 16)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: copied ? .primary : .secondary))
                .help(Self.verb)
                .accessibilityLabel(Self.verb)
            }
            .padding(.leading, 8)
            .padding(.trailing, 4)
            .padding(.vertical, 6)
            Rectangle()
                .fill(tokens.line)
                .frame(height: 1)
            // Shown WHOLE and selectable (R-13nb-5; VX-168: the key masked) —
            // the JSON stanza is ten lines before a long path wraps.
            Text(verbatim: text)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(tokens.ink)
                .textSelection(.enabled)
                .lineLimit(16)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
        }
        .background(tokens.codeTint, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    private func flash() {
        copied = true
        Task {
            try? await Task.sleep(for: Self.copiedFlash)
            copied = false
        }
    }
}
