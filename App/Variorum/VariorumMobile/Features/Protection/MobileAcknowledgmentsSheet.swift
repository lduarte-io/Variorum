//
//  MobileAcknowledgmentsSheet.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — R13p-11's ATTRIBUTION OBLIGATION on the phone.
//  The iPhone app ships the same SQLCipher Community Edition the Mac
//  does, so it owes the same user-accessible notice: the Zetetic
//  copyright line, the license text verbatim, and the dependency
//  notices. The WORDS are `AcknowledgmentsCopy` (Shared) — Batch 1 put
//  them there naming this face as the reason ("shared — Batch 4's phone
//  face renders the same words"), so the two surfaces cannot drift.
//
//  Functional over polish, exactly like the Mac's pane; the voice tokens
//  make it belong to the phone.
//

import SwiftUI

struct MobileAcknowledgmentsSheet: View {
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tokens.path(["Acknowledgments"]))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text(tokens.chromeLabel("Done"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(AcknowledgmentsCopy.intro)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(AcknowledgmentsCopy.all) { notice in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(notice.name)
                                .font(tokens.heading)
                                .foregroundStyle(tokens.ink)
                            Text(notice.role)
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(notice.text)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(tokens.muted)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(tokens.card)
                                .overlay(RoundedRectangle(cornerRadius: 6)
                                    .stroke(tokens.line, lineWidth: 1)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(tokens.room.ignoresSafeArea())
    }
}
