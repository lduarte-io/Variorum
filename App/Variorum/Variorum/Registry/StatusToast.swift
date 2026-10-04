//
//  StatusToast.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (AD-14): the ONE status presentation — a quiet
//  voiced toast at the shell's bottom, mode- and surface-independent.
//  Refusals are READABLE (R93: wrapping, selectable, never truncated to
//  nothing) and the line limit is LOAD-BEARING (the b6dae25 chrome class:
//  an unlimited fixedSize text never sits in non-scrolling window chrome).
//

import SwiftUI

struct StatusToast: View {
    let item: StatusCenter.Item
    let tokens: VoiceTokens
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(item.text)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(4)  // LOAD-BEARING (b6dae25 class)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            // 13f batch 5 (W23 / her round-10 item 4): a note that names a
            // door can BE the door. The button dismisses as it acts — an
            // offer that stays on screen after it is taken reads as a
            // question that was never answered.
            // 13r U3-A (R-13r-12): an offer's second door — the decline
            // (Not Now), quieter than the act and before it, the platform's
            // order for a cancel beside a default. It dismisses as it acts.
            if let secondary = item.secondary {
                Button(secondary.label) {
                    onDismiss()
                    secondary.perform()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .lineLimit(1)
                .fixedSize()
            }
            if let action = item.action {
                Button(action.label) {
                    onDismiss()
                    action.perform()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                // states its own line policy, so its IDEAL width can never be a
                // wrapped one (the b6dae25 class's window-sizing hazard).
                // The toast's own message above is deliberately UNLIMITED (its
                // `fixedSize(h:false,v:true)` wraps a sentence); the ACTION is a
                // verb and takes one line.
                .lineLimit(1)
                .fixedSize()
            }
            Button("✕", action: onDismiss)
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .help("Dismiss")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 8, y: 2)
        .frame(maxWidth: 560)
    }
}
