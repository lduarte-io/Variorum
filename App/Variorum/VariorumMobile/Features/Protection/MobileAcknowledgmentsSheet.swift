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
            PhoneSheetHeader(
                tokens.path(["Acknowledgments"]), tokens: tokens, titleInk: tokens.phone.muted
            ) { dismiss() }
            .padding(.horizontal, PhoneMetrics.gutter)
            .padding(.top, PhoneMetrics.Space.s8)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(AcknowledgmentsCopy.intro)
                        .phoneType(.rowPreview, tokens)
                        .foregroundStyle(tokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(AcknowledgmentsCopy.all) { notice in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(notice.name)
                                .phoneType(.rowTitle, tokens)
                                .foregroundStyle(tokens.ink)
                            Text(notice.role)
                                .phoneType(.meta, tokens)
                                .foregroundStyle(tokens.phone.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(notice.text)
                                .phoneType(.meta, tokens)
                                .foregroundStyle(tokens.phone.muted)
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
