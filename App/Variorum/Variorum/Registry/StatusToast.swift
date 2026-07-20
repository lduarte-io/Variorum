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
