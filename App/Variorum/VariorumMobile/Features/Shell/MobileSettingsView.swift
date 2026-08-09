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
    #if DEBUG
    /// FIX-B4 (Stage B ladder round 1, NIT 2 — fire-and-DO): the shell's
    /// door for "Open the pocket guide" — dismisses Settings and
    /// navigates to the book. nil ⇒ the door speaks its outcome in place
    /// (defensive; the shell always wires it).
    var onOpenTutorialBook: ((String) -> Void)? = nil
    #endif

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    /// The tag manager's presentation (parity C3 — Settings is tag
    /// management's home, the Mac R52 placement mirrored).
    @State private var tagsPresented = false
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

            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)

            // Tag management (parity C3 — her cross-fully ruling; R52's
            // Settings home mirrored: the manager is where you look at
            // tags).
            Text(tokens.chromeLabel("Tags"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            Button {
                tagsPresented = true
            } label: {
                Text(tokens.chromeLabel(MobileTagManagerSheet.doorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .accessibilityLabel("Manage Tags")

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
                Task { await openGuideDoor() }
            } label: {
                Text(tokens.chromeLabel("Open the pocket guide"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            Button {
                Task { await restoreGuideDoor() }
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
        .sheet(isPresented: $tagsPresented) {
            MobileTagManagerSheet(session: session, tokens: tokens)
        }
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
        .onDisappear {
            // FIX-B5 (Stage B ladder round 1, NIT 3): a sheet torn down
            // with the replace confirm up (swipe-dismiss) runs neither
            // alert button — the checked continuation would leak and the
            // suspended door would hold its in-flight latch for the
            // sheet's next presentation. Teardown resolves the confirm
            // as a DECLINE: the awaiting door resumes ("Left as it
            // was."), its `defer` releases the latch, and a
            // button-resolved continuation is already nil here (both
            // buttons nil it after resuming — never a double resume).
            confirmContinuation?.resume(returning: false)
            confirmContinuation = nil
        }
        #endif
    }

    #if DEBUG
    /// The OPEN door (FIX-B4, Stage B ladder round 1, NIT 2): one call
    /// into the tested `findOrSeed` seam — the discover → exists /
    /// residue-confirm → restore grammar lives THERE, encoded once (the
    /// walk suites drive it; the MAJOR-A same-`Existing` discipline is
    /// the seam's own) — and then the door DOES what its label says:
    /// the shell's closure dismisses Settings and navigates to the
    /// book (the 13b fire-and-DO doctrine; "Open" that only
    /// seeds-or-reports was the finding).
    private func openGuideDoor() async {
        guard !tutorialInFlight else { return }
        tutorialInFlight = true
        defer { tutorialInFlight = false }
        do {
            guard let bookID = try await MobileTutorialSeeder.findOrSeed(
                session: session, confirmReplace: confirmReplace)
            else {
                tutorialNote = "Left as it was."
                return
            }
            if let onOpenTutorialBook {
                onOpenTutorialBook(bookID)
            } else {
                tutorialNote = "The pocket guide is on your shelf."
            }
        } catch {
            tutorialNote = String(describing: error)
        }
    }

    /// The RESTORE door keeps its own grammar — a wholesale replace,
    /// always confirm-gated when anything tutorial-shaped exists (the
    /// Mac door grammar; deliberately NOT `findOrSeed`, which
    /// short-circuits at an existing book) — riding the same tested
    /// `discover`/`restore` seams, the SAME discovered `Existing` the
    /// confirm disclosed flowing into the replace (MAJOR-A, carried).
    private func restoreGuideDoor() async {
        guard !tutorialInFlight else { return }
        tutorialInFlight = true
        defer { tutorialInFlight = false }
        do {
            let existing = try await session.database.read {
                try MobileTutorialSeeder.discover($0)
            }
            if !existing.isEmpty {
                guard await confirmReplace() else {
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

    /// The continuation-shaped confirm both doors share — the alert
    /// resolves it (and FIX-B5's teardown cancel resolves it `false` if
    /// the sheet dies with the alert up).
    private func confirmReplace() async -> Bool {
        await withCheckedContinuation { continuation in
            confirmContinuation = continuation
            confirmPresented = true
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
