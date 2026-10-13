//
//  ProtectionStatusRow.swift
//  Variorum (Mac)
//
//  pre-13u Act 10 wave 2a — **the unchosen-state indicator (memo §6):**
//  prominent, bottom-left family (the sidebar's status rows, beside
//  Sync), and TRUTHFUL — NEVER "encryption off": the store is
//  always encrypted (R13p-2); what is unchosen is the lock and the spare
//  keys. It renders only while the protection choice is genuinely
//  unmade (Auto + no secrets, facts readable) and leaves the moment a
//  shape is chosen; the door opens Settings, where the choice lives.
//  The detail line follows T2's tier truth: EXPOSED speaks the hardened
//  device-neutral headline; a covered-but-unchosen state (a verified
//  iCloud spare) keeps the calm sentence.
//

import SwiftUI

struct ProtectionStatusRow: View {
    @Bindable var controller: ProtectionController
    let tokens: VoiceTokens
    @Environment(\.openSettings) private var openSettings

    /// The genuinely-unchosen state: nothing picked, nothing set, and the
    /// facts READABLE (an unreadable sidecar must not be dressed as an
    /// unmade choice — the pane carries the unknown sentence instead).
    private var unchosen: Bool {
        controller.posture == .standard
            && !controller.hasPassphraseWrap
            && !controller.hasRecoveryWrap
            && !controller.legs.factsUnknown
    }

    var body: some View {
        if unchosen {
            let tier = controller.legs.tier
            let exposed = tier == .exposed
            Button {
                openSettings()
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Image(systemName: exposed ? "exclamationmark.shield" : "shield")
                        .font(tokens.small)
                        .foregroundStyle(exposed ? tokens.alarm : tokens.muted)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(tokens.chromeLabel(ProtectionCopy.postureName(.standard)))
                            .font(tokens.small)
                            .fontWeight(.semibold)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        // pre-13x 5a (design §8): the unchosen indicator reads
                        // "Standard" + the current-state line (copy §1); exposed
                        // keeps the hardened headline (copy §5); F3 (NIT-N8): a
                        // device waiting for the account's iCloud key reads copy
                        // §2d's waiting title — never the exposed headline.
                        Text(exposed
                             ? ProtectionCopy.exposedNudgeHeadline
                             : tier == .waiting
                                 ? ProtectionCopy.waitingTitle
                                 : ProtectionCopy.currentStateLine(.standard))
                            .font(tokens.small)
                            .foregroundStyle(exposed ? tokens.alarm : tokens.muted)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                // VX-218: on the column's content edge, with the sync row
                // below it (was 10 pt — the family read ragged at 10 vs 6).
                .padding(.horizontal, SidebarLayout.contentInset)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(ProtectionCopy.postureName(.standard))
            .help(ProtectionCopy.currentStateLine(.standard))
        }
    }
}
