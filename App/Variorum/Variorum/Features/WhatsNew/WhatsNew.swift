//
//  WhatsNew.swift
//  Variorum (MAC ONLY)
//
//  Phase 13r U3-A — THE IN-APP WHAT'S NEW (the U3 section: "shown once
//  when the version changes, + a Help ▸ What's New door; voice-conformant
//  chrome per P-8"), built to the architect's recorded reading (the plan's
//  LIVE STATUS, "U3-A — OPEN"): under her no-popup-at-first-open principle
//  (R-13r-11 — "opening Variorum is calm"), **a FRESH install records the
//  current version SILENTLY and shows nothing; the sheet appears only on a
//  version CHANGE from a recorded one** — once, and never again for that
//  version.
//
//  THE LEDGER is a LOCAL preference of this app on this Mac (never a synced
//  `setting` — a version is a fact about this installation, not the
//  document): the last version What's New was settled for. The decision is
//  taken ONCE per process at launch, so the moment the sheet records the
//  new version cannot turn a later window's question into a different
//  answer. The version is the MARKETING version (`CFBundleShortVersionString`
//  — 0.9.0 → 0.9.1), never the build number, which moves on every commit
//  (R-13r-6) and would greet every developer build.
//
//  Existing installs reach their first stamped build with NO record, so they
//  read as fresh and stay quiet — the calm direction (her daily drive's first
//  U3 refresh included). From then on each version change shows once.
//
//  VX-329 R1 (VX-468): `WhatsNewLedger` moved byte-for-byte to
//  `WhatsNewLedger.swift` beside this file (Foundation only, so a headless
//  harness compiles it); the sheet stays here.
//

import Foundation
import SwiftUI

/// The sheet: the current version's notes, in the voice (P-8 — the tokens
/// from the window's `ThemeStore`, `VoicedButtonStyle` for the door, every
/// fixed-size chrome text line-limited).
struct WhatsNewSheet: View {
    let version: String
    /// The Markdown source, or nil for a build without notes.
    let notes: String?
    let onClose: () -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(WhatsNewCopy.title(version: version))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let notes {
                        ForEach(Array(ReleaseNotes.blocks(from: notes).enumerated()), id: \.offset) { _, block in
                            row(block)
                        }
                    } else {
                        Text(WhatsNewCopy.noNotes(version: version))
                            .font(tokens.body)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
            HStack {
                Spacer()
                Button(WhatsNewCopy.closeDoor, action: onClose)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .padding(24)
        .frame(width: 520)
        .frame(minHeight: 260, maxHeight: 560)
        .background(tokens.surface)
    }

    @ViewBuilder
    private func row(_ block: ReleaseNotes.Block) -> some View {
        switch block {
        case .heading(let text):
            Text(Self.inline(text))
                .font(tokens.body.weight(.semibold))
                .foregroundStyle(tokens.ink)
                .padding(.top, 4)
                .fixedSize(horizontal: false, vertical: true)
        case .bullet(let text):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\u{2022}").foregroundStyle(tokens.muted)
                Text(Self.inline(text))
                    .foregroundStyle(tokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(tokens.body)
        case .paragraph(let text):
            Text(Self.inline(text))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Inline Markdown (bold, italic, code, links); plain text if it fails.
    static func inline(_ text: String) -> AttributedString {
        (try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(text)
    }
}
