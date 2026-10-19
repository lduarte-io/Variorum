//
//  RoadInterludeCard.swift
//  Variorum
//
//  VX-306 U2 — THE OPEN'S INTERLUDE, the Mac's face (rule 21; `notes/plans/vx-306-castle-open-road.md` §7c (2) and
//  (4), built exactly as drafted — PROVISIONAL, hers at the bundle). In the lobby's room, between the unlock and the
//  library's open (PROVISIONAL P-VX306-U2-1 — the words card's idiom): ONE quiet sentence per card — rule 21's
//  NOTICE (her sentence, the model's: `LibraryNotice.sentence(date:)`) with one *OK*; then the KEY-FILE OFFER (her
//  sentence, the model's: `KeyFileOffer.sentence(date:)`) with *Not now* · *Use it*. Nothing is written before
//  *Use it*. When the last card is answered the library opens. No session exists yet, so the face speaks the leading
//  voice's fallback tokens, as the lobby does. VX-307 U2a: then VX-310's RE-ARM question (the design's §3.10 sentence)
//  with *Always ask instead* · *Set it up again* — or *OK* when the answer could not be written (nothing decided).
//

import SwiftUI
import VariorumCore

struct RoadInterludeCard: View {
    @Bindable var model: RoadInterludeModel
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens { .fallback(for: scheme) }

    var body: some View {
        ZStack {
            tokens.room.ignoresSafeArea()
            GlyphRainBackdrop(tokens: tokens, scheme: scheme)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                card
                Spacer(minLength: 24)
                Spacer(minLength: 24)
            }
        }
    }

    private var card: some View {
        VStack(spacing: 16) {
            Image(systemName: glyph)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(tokens.muted)
            if let sentence = model.sentence {
                Text(sentence)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            buttons
            if let message = model.message {
                Text(message)
                    .font(tokens.small)
                    .alarmVoice()
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if model.busy {
                TravellingDotsIndicator(ink: tokens.muted)
            }
        }
        .padding(28)
        .frame(maxWidth: 440)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0.5 : 0.10), radius: 22, y: 8)
        .padding(.horizontal, 32)
    }

    private var glyph: String {
        if case .offer? = model.current { return "key" }
        if case .rearm? = model.current { return "touchid" }
        return "info.circle"
    }

    @ViewBuilder
    private var buttons: some View {
        switch model.current {
        case .notice?:
            Button(ProtectionWords.noticeOK) { model.ok() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
        case .offer?:
            HStack(spacing: 12) {
                Button(ProtectionWords.offerNotNow) { model.notNow() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens))
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Button(ProtectionWords.offerUseIt) { Task { await model.useIt() } }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .disabled(model.busy)
            }
        case .rearm?:
            // VX-307 U2a — VX-310's re-arm: a no records Always ask; a yes makes a new item at this press.
            if model.rearmFailed {
                Button(ProtectionWords.noticeOK) { model.ok() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
            } else {
                HStack(spacing: 12) {
                    Button(ProtectionWords.rearmNo) { Task { await model.rearm(yes: false) } }
                        .buttonStyle(CalmButtonStyle(tokens: tokens))
                        .disabled(model.busy)
                    Button(ProtectionWords.rearmYes) { Task { await model.rearm(yes: true) } }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                        .disabled(model.busy)
                }
            }
        case nil:
            EmptyView()
        }
    }
}
