//
//  LibraryWordsCard.swift
//  Variorum
//
//  VX-306 U1b — THE ONCE-SHOWN WORDS CARD, the Mac's face (rule 2; `notes/plans/vx-306-castle-open-road.md` §7c (1),
//  built exactly as drafted — PROVISIONAL, hers at the bundle). Shown at a library's creation, before anything
//  else opens: the title, the lead, the twelve words numbered in two columns, the foot, and ONE button,
//  "I've written them down", which forgets the words and opens the library (P-VX306-K7 — no Copy door, no
//  "later": the words are never stored, and the clipboard never holds them; the words are not selectable).
//  The room and the card are the lobby's (`StoreLockView`): no session exists yet, so it speaks the leading
//  voice's fallback tokens.
//

import SwiftUI
import VariorumCore

struct LibraryWordsCard: View {
    let model: LibraryWordsCardModel
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
            Image(systemName: "key")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(tokens.muted)
            Text(ProtectionWords.wordsCardTitle)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(ProtectionWords.wordsCardLead)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.center)
                .lineLimit(8)
                .fixedSize(horizontal: false, vertical: true)
            words
            Text(ProtectionWords.wordsCardFoot)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Button(ProtectionWords.wordsCardButton) { model.iveWrittenThemDown() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(model.words.isEmpty)
        }
        .padding(28)
        .frame(maxWidth: 460)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0.5 : 0.10), radius: 22, y: 8)
        .padding(.horizontal, 32)
    }

    /// The twelve words, numbered, in two columns — never selectable (no copy road), privacy-sensitive.
    private var words: some View {
        HStack(alignment: .top, spacing: 36) {
            ForEach(Array(model.columns.enumerated()), id: \.offset) { _, column in
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(column, id: \.number) { entry in
                        HStack(spacing: 8) {
                            Text("\(entry.number)")
                                .font(tokens.mono)
                                .foregroundStyle(tokens.faint)
                                .frame(minWidth: 20, alignment: .trailing)
                            Text(entry.word)
                                .font(tokens.mono)
                                .foregroundStyle(tokens.ink)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .textSelection(.disabled)
        .privacySensitive()
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(tokens.room.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }
}
