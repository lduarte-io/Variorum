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
    /// 13p Batch 4: the launch/protection brain — Protection's own screen
    /// and the acknowledgments the encryption obliges (R13p-11). Optional
    /// like `services`: the sheet says nothing about what it does not have.
    var bootstrap: AppBootstrap? = nil
    /// VM-8 unit 1 (PROVISIONAL P-VM8-2): the shell's door to the phone's Protection screen — dismisses Settings and
    /// pushes the screen (the settings-sheet grammar, the pocket guide's precedent). nil ⇒ neither the row nor the sync
    /// row's *Protection…* door renders (P-2).
    var onOpenProtection: (() -> Void)? = nil
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
    /// 13p Batch 4: the acknowledgments, a nested sheet off this one (the tag-manager precedent).
    @State private var acknowledgmentsPresented = false
    /// E1's door state (temporary — mobile round 2's settling experiment;
    /// the walk script is at the section itself, below). Seeded from the
    /// recorder on appear (not in the initializer — a `View`'s stored
    /// property initializer is nonisolated), so the row shows the persisted
    /// arming after a relaunch.
    @State private var traceArmed = false
    @State private var tracePresented = false
    // (The Encryption Explained restore row's state — pre-13x F2 — left
    // with the row at 13s-b U1b, R-13s-37.)
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

    /// VM-8 unit 1: the Protection screen's door where it can act — the shell gave the road, the app's services exist (the
    /// sync row says *Starting…* until they do — ladder round 1's NIT-2: the screen's *Sign in…* has no Account sheet to
    /// present before them), AND a library is open on the protection road with its account section (P-2: no screen that
    /// can act, no door).
    private var protectionDoor: (() -> Void)? {
        guard let onOpenProtection, services != nil, bootstrap?.roadStanding?.account != nil else { return nil }
        return onOpenProtection
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
                // D1: the ONE injection site of the shared pages' phone
                // style — the row restyles to the live voice, and the
                // Account sheet it presents inherits the style through
                // the environment (sheets inherit their presenter's
                // environment — the SnapshotPrivacy precedent). The Mac
                // never sets this key (its accessor compiles to nil).
                // Horizontal 20 aligns the row with the section headers
                // (the styled row carries no horizontal padding of its
                // own — the old 14+6 composition is the nil arm's).
                SyncStatusRow(services: services)
                    .environment(\.sharedPageStyle, SharedPageStyle(tokens: tokens))
                    // VM-8 unit 1 (VX-486's door, the phone's home): the keys-locked and not-on-yet rows' *Protection…*
                    // door opens the phone's Protection screen — only where that screen can act (P-2).
                    .environment(\.protectionPaneDoor, protectionDoor.map { open in ProtectionPaneDoor { open() } })
                    .padding(.horizontal, 20)
            } else {
                Text(tokens.chromeLabel("Starting…"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.horizontal, 20)
            }

            // VM-8 unit 1 (PROVISIONAL P-VM8-2): Settings ▸ Protection — the phone's screen over the shared protection
            // brains (unit 1: the Sync/account section). The row's name is the sync row's own door name (P-VX486-1).
            if let protectionDoor {
                Button {
                    protectionDoor()
                } label: {
                    Text(tokens.chromeLabel(SyncRowFace.openProtectionLabel))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .accessibilityLabel(SyncRowFace.openProtectionLabel)
            }

            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)

            // (13p Batch 4's PROTECTION door — the phone's posture screen over today's protection brain — was today's
            // road and left with it at VX-329 U1; VM-8 unit 1's Protection row stands above, in the Sync section.)
            // R13p-11's attribution obligation reaches the phone too — it
            // ships the same SQLCipher, so it owes the same notice. Same
            // words as the Mac's pane (`AcknowledgmentsCopy`, Shared).
            Button {
                acknowledgmentsPresented = true
            } label: {
                Text(tokens.chromeLabel("Acknowledgments"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .accessibilityLabel("Acknowledgments")

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

            // ── E1, THE SETTLING EXPERIMENT (temporary; mobile round 2) ──
            //
            // ⚠️ THE WALK SCRIPT LIVES HERE, because the arming point is
            // where someone will look for it.
            //
            // WHAT IT ANSWERS. Her delete-at-the-end crash is fixed, but the
            // trace could not prove WHERE the stale verdict came from. The
            // leading suspect is that iOS asks the editor's gate about one
            // small edit and then performs a WIDER one in the same
            // transaction. This records both halves so the answer stops
            // being a guess. **It must run on HER device (iOS 26.6)** — the
            // newest simulator here is 26.2, and a non-reproduction on an
            // older runtime is a runtime gap, not an answer.
            //
            // HOW SHE RUNS IT.
            //  1. Turn "Record edit trace" ON here. Tap Done.
            //  2. Open any note with several paragraphs. Type a couple of
            //     words first, so the last paragraph is freshly typed.
            //  3. Do these five things, in order, with ordinary typing in
            //     between:
            //       a. select from the MIDDLE of a paragraph all the way to
            //          the very end of the note, and press ⌫;
            //       b. select two whole paragraphs in the middle, press ⌫;
            //       c. the same as (a), but end the selection ONE CHARACTER
            //          short of the end;
            //       d. type a word wrong on purpose and accept the
            //          autocorrect suggestion;
            //       e. dictate a sentence with the microphone key.
            //  4. Come back here → "Edit trace…". Read the first six lines.
            //  5. Tap Copy and paste the whole thing into a message.
            //
            // WHAT THE NUMBERS MEAN.
            //  · **"SUSPECT SIGNATURE" above 0 → confirmed.** The event
            //    list underneath names the exact edit, and its ⚠ words say
            //    which way it disagreed.
            //  · **"most gate calls before one edit" above 1 → confirmed**
            //    on its own: iOS asked more than once for a single edit.
            //  · "gate-less" above 0 is EXPECTED and is not a finding —
            //    that is autocorrect and dictation, which never ask.
            //  · "of which overrun N of M testable" is the sub-signal the
            //    round's record named by hand; M is smaller than the edit
            //    count on purpose (iOS reports a wider range than it
            //    changed for anything that INSERTS, so that sub-test is
            //    only run on pure deletions).
            //  · Everything at 0 after all five gestures → evidence AGAINST
            //    the suspect on this iOS version, but not proof: it only
            //    covers the gestures that were actually performed.
            //
            // Turning it back OFF makes it completely inert; leaving it on
            // costs a few numbers per keystroke and nothing else.
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 14)
            Text(tokens.chromeLabel("Diagnostics"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            Button {
                traceArmed.toggle()
                MobileEditTrace.setArmed(traceArmed)
            } label: {
                Text(tokens.chromeLabel(
                    traceArmed ? "Recording edit trace — tap to stop"
                               : "Record edit trace"))
                    .font(tokens.small)
                    .foregroundStyle(traceArmed ? tokens.accent : tokens.muted)
                    .lineLimit(2)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .accessibilityLabel("Record edit trace")
            .accessibilityValue(traceArmed ? "on" : "off")
            Button {
                tracePresented = true
            } label: {
                Text(tokens.chromeLabel("Edit trace…"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .accessibilityLabel("Open the edit trace")

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
            // D2 look sweep: the spike door joins the one register
            // (it rendered system-blue written case — the only chrome
            // on this sheet outside the voice).
            Button {
                spikePresented = true
            } label: {
                Text(tokens.chromeLabel("TK2 Spike"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            // (The pre-13x batch 0 keychain probe row lived here — deleted
            // at batch 2a with the real Apple-key item, row 12.)
            #endif

            // (The Restore “Encryption Explained” row — pre-13x F2 —
            // REMOVED at 13s-b U1b, R-13s-37: "encryption explained not
            // present and not restorable". An existing store's copy is her
            // data and stays.)

            Spacer()
        }
        .background(tokens.room.ignoresSafeArea())
        .sheet(isPresented: $tagsPresented) {
            MobileTagManagerSheet(session: session, tokens: tokens)
        }
        .sheet(isPresented: $acknowledgmentsPresented) {
            MobileAcknowledgmentsSheet(tokens: tokens)
        }
        .sheet(isPresented: $tracePresented) {
            MobileEditTraceView(tokens: tokens)
        }
        .onAppear { traceArmed = MobileEditTrace.isArmed }
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


// (The `restoreEncryptionBookDoor` road — pre-13x F2 — left with its row at
// 13s-b U1b, R-13s-37: the book is not restorable.)
