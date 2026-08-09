//
//  MobileSettingsView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the voice switch's real home (scope item 6:
//  P11's placement lands; the S1 masthead door RETIRED — recorded). A
//  minimal voiced sheet off the shelf: the two voices (LK2 — the
//  phone-local preference, never synced), the sync status row (the Phase
//  8 shell that carries over), and the DEBUG spike door (the Stage 0
//  KEPT deviation's manual entry).
//
//  Parity round Stage B, batch B1: the DEBUG tutorial doors (open /
//  restore the pocket guide). DEBUG-only BY DESIGN — Debug builds
//  resolve the DEV store (the A4 fence), so the guide can never reach
//  her real corpus from here; the product door's placement is hers
//  (PROVISIONAL PB1-1). The doors are thin wiring onto the tested
//  seeder seams (`MobileTutorialSeeder.findOrSeed`/`restore`) — the
//  walk suites drive those seams headlessly.
//

import SwiftUI
import VariorumCore

struct MobileSettingsView: View {
    let session: AppSession
    let router: MobileShellRouter
    let services: AppServices?

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    #if DEBUG
    @State private var spikePresented = false
    /// The tutorial doors' state: one door in flight at a time (the
    /// Mac's NIT-6 latch, sheet-local), the spoken outcome, and the
    /// replace confirm's continuation (the alert resolves it).
    @State private var tutorialInFlight = false
    @State private var tutorialNote: String?
    @State private var confirmPresented = false
    @State private var confirmContinuation: CheckedContinuation<Bool, Never>?
    /// The performance fixture door's state (parity B2 — the B1 door
    /// family's latch/outcome shape, its own latch).
    @State private var perfInFlight = false
    @State private var perfNote: String?
    #endif

    private var tokens: VoiceTokens {
        .resolve(voice: router.voice, dark: scheme == .dark)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tokens.path(["Settings"]))
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

            Text(tokens.chromeLabel("Voice"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            voiceRow(.terminal, "Terminal")
            voiceRow(.study, "Study")

            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)

            Text(tokens.chromeLabel("Sync"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
            if let services {
                SyncStatusRow(services: services)
                    .padding(.horizontal, 14)
            } else {
                Text(tokens.chromeLabel("Starting…"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.horizontal, 20)
            }

            #if DEBUG
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)
            Text(tokens.chromeLabel("Tutorial (dev store)"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            Button {
                Task { await tutorialDoor(replace: false) }
            } label: {
                Text(tokens.chromeLabel("Open the pocket guide"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            Button {
                Task { await tutorialDoor(replace: true) }
            } label: {
                Text(tokens.chromeLabel("Restore the pocket guide…"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            if let tutorialNote {
                Text(tokens.chromeLabel(tutorialNote))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
            }
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)
            Text(tokens.chromeLabel("Performance (dev store)"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            Button {
                Task { await perfDoor() }
            } label: {
                Text(tokens.chromeLabel("Seed the 100k fixture"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            if let perfNote {
                Text(tokens.chromeLabel(perfNote))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
            }
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)
            Button("TK2 Spike") { spikePresented = true }
                .font(tokens.small)
                .padding(.horizontal, 20)
            #endif

            Spacer()
        }
        .background(tokens.room.ignoresSafeArea())
        #if DEBUG
        .fullScreenCover(isPresented: $spikePresented) { SpikeScreen() }
        .alert(MobileTutorialSeeder.replaceQuestion, isPresented: $confirmPresented) {
            Button("Replace", role: .destructive) {
                confirmContinuation?.resume(returning: true)
                confirmContinuation = nil
            }
            Button("Cancel", role: .cancel) {
                confirmContinuation?.resume(returning: false)
                confirmContinuation = nil
            }
        } message: {
            Text(MobileTutorialSeeder.replaceDetail)
        }
        #endif
    }

    #if DEBUG
    /// The two doors share one body: `replace: false` is find-or-seed
    /// (an existing book just reports — never a second guide); `replace:
    /// true` is the wholesale restore, always confirm-gated when
    /// anything tutorial-shaped exists (the Mac door grammar). The SAME
    /// discovered `Existing` the confirm disclosed flows into the
    /// replace (the MAJOR-A discipline, carried).
    private func tutorialDoor(replace: Bool) async {
        guard !tutorialInFlight else { return }
        tutorialInFlight = true
        defer { tutorialInFlight = false }
        do {
            let existing = try await session.database.read {
                try MobileTutorialSeeder.discover($0)
            }
            if !replace, !existing.readingIDs.isEmpty {
                tutorialNote = "The pocket guide is already on your shelf."
                return
            }
            if !existing.isEmpty {
                let confirmed = await withCheckedContinuation { continuation in
                    confirmContinuation = continuation
                    confirmPresented = true
                }
                guard confirmed else {
                    tutorialNote = "Left as it was."
                    return
                }
            }
            _ = try await MobileTutorialSeeder.restore(
                session: session, existing: existing)
            tutorialNote = "The pocket guide is on your shelf."
        } catch {
            tutorialNote = String(describing: error)
        }
    }

    /// The performance fixture's door (parity B2): find-or-seed only —
    /// an existing proving ground just reports, and nothing here is ever
    /// destructive, so no confirm is owed. Seeding a few thousand rows
    /// through Operations takes a moment on the dev store; the latch
    /// keeps the door single-entry and the note speaks the outcome.
    private func perfDoor() async {
        guard !perfInFlight else { return }
        perfInFlight = true
        perfNote = "Seeding…"
        defer { perfInFlight = false }
        do {
            let outcome = try await MobilePerfFixtureSeeder.findOrSeed(session: session)
            if let seeded = outcome.seeded {
                perfNote = "Seeded: \u{201C}\(MobilePerfFixtureSeeder.megaPostTitle)\u{201D} "
                    + "(\(seeded.megaWordCount) words, \(seeded.megaBlockCount) blocks) "
                    + "+ \(seeded.corpusNoteCount) corpus notes in six books."
            } else {
                perfNote = "The proving ground is already seeded."
            }
        } catch {
            perfNote = String(describing: error)
        }
    }
    #endif

    /// One voice's row: the terminal `›` marker carries the selection
    /// (the R1 idiom); study renders the plain selected ink.
    private func voiceRow(_ voice: ThemeVoice, _ label: String) -> some View {
        let selected = router.voice == voice
        return Button {
            router.setVoice(voice)
        } label: {
            HStack(spacing: 4) {
                if !tokens.selectionMarker.isEmpty {
                    Text(tokens.selectionMarker)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .opacity(selected ? 1 : 0)
                }
                Text(tokens.chromeLabel(label))
                    .font(tokens.body)
                    .foregroundStyle(selected ? tokens.ink : tokens.muted)
                if selected, tokens.selectionMarker.isEmpty {
                    Text("✓")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
