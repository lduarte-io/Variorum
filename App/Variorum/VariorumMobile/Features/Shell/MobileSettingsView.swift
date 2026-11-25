//
//  MobileSettingsView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the voice switch's real home (scope item 6:
//  P11's placement lands; the S1 masthead door RETIRED — recorded). A
//  minimal voiced sheet off the shelf: the two voices (VM-51 made them the
//  LIBRARY's synced voice, R-47-2; since VM-247 — the VM-260 run, batch 3 —
//  the whole of Look is THIS PHONE's own: voice, colour palette, background),
//  the sync status row (the Phase
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
//  VM-53 + VM-27 (the VM-47 run, batch 5): ONE scrolling, grouped list on the
//  phone's shared controls (the body's doc says how), opened from the roots' ⋯
//  menu and a note's ⋯ sheet; this phone's light · dark · follow-the-system
//  choice (LK-2 — a local preference) beside the library's voice; and ONE
//  Protection door (VM-27 — the sync row is handed none of its own here).
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
    /// pushes the screen (the settings-sheet grammar, the pocket guide's precedent). nil ⇒ the Protection row does not
    /// render (P-2). Since VM-27 it is the sheet's ONE Protection door — the sync row is never handed one here.
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
    /// VM-65: the timing readout's sheet (always recording on the phone — no
    /// arming; the door only reads).
    @State private var timingPresented = false
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

    /// This phone's voice and palette (VM-247) in this device's appearance.
    private var tokens: VoiceTokens {
        router.tokens(dark: scheme == .dark)
    }

    /// VM-8 unit 1: the Protection screen's door where it can act — the shell gave the road, the app's services exist (the
    /// sync row says *Starting…* until they do — ladder round 1's NIT-2: the screen's *Sign in…* has no Account sheet to
    /// present before them), AND a library is open on the protection road with its account section (P-2: no screen that
    /// can act, no door).
    private var protectionDoor: (() -> Void)? {
        guard let onOpenProtection, services != nil, bootstrap?.roadStanding?.account != nil else { return nil }
        return onOpenProtection
    }

    // MARK: - The list's words (VM-53)
    //
    // Every word below is either on screen today (the voice rows' Terminal /
    // Study and their section's "Voice"; Tags; Diagnostics; the doors' own
    // words), the Mac's own for the same row (the appearance choice — the Mac's
    // Settings ▸ General: "Appearance", "Follow system", "Light", "Dark",
    // `AppearanceChoiceRow`), or — where a row had none — the wording list's
    // draft (`notes/plans/vm-44/design/wording-list-2.md`, lock-and-protection
    // S1: the group names "Library", "Look", "Help"), listed for her wording
    // pass in the run record §5.

    static let libraryGroupTitle = "Library"
    static let lookGroupTitle = "Look"
    static let tagsGroupTitle = "Tags"
    static let helpGroupTitle = "Help"
    static let diagnosticsGroupTitle = "Diagnostics"
    static let voiceLabel = "Voice"
    static let appearanceLabel = "Appearance"
    /// VM-247: the Mac's own label for the same row (`PaletteCopy.title`, Settings
    /// ▸ General — a phone pin holds it to the Mac's source).
    static let paletteLabel = "Colour palette"
    /// VM-247: her own word ("the cream background color option") — DRAFT for
    /// her wording pass, with its two words below.
    static let groundLabel = "Background"
    /// VM-254: the text-size row's label — DRAFT (her wording pass).
    static let textSizeLabel = "Text size"

    /// The voice choice's two words — the two rows' own, kept (R-47-2).
    static func voiceWord(_ voice: ThemeVoice) -> String {
        switch voice {
        case .terminal: "Terminal"
        case .study: "Study"
        }
    }

    /// The appearance choice's three words — the Mac's own
    /// (`AppearanceChoiceRow`; a phone pin holds them equal).
    static func appearanceWord(_ choice: AppearanceChoice) -> String {
        switch choice {
        case .system: "Follow system"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// **VM-247 — the palettes' words: the Mac's own** (`PaletteCopy.label`, the
    /// Mac's Settings ▸ General swatch strip; a phone pin holds every one to the
    /// Mac's source, as the appearance words are held).
    static func paletteWord(_ palette: ThemePalette) -> String {
        switch palette {
        case .default: "Classic"
        case .lavender: "Lavender"
        case .mint: "Mint"
        case .pink: "Pink"
        case .blue: "Blue"
        case .goldAndBlack: "Gold & black"
        case .sageAndTerracotta: "Sage & terracotta"
        case .slateAndAmber: "Slate & amber"
        case .plumAndCream: "Plum & cream"
        case .inkAndCoral: "Ink & coral"
        case .greyAndGreen: "Grey & green"
        case .cobaltAndTangerine: "Cobalt & tangerine"
        case .peachAndIndigo: "Peach & indigo"
        case .butterAndCobalt: "Butter & cobalt"
        case .roseAndMoss: "Rose & moss"
        case .tealAndRust: "Teal & rust"
        case .seaglass: "Sea glass"
        case .custom: "Custom"
        }
    }

    /// **VM-247 — the palette menu's sections**: the Mac's groups in the Mac's
    /// order (`PaletteCopy.Group`), but for two calls (PROVISIONAL P-260-3c): the
    /// Mac's two one-swatch rows ("Default" — the sea-glass — and "Classic") are
    /// one untitled first section, where a "Classic" heading over a lone
    /// "Classic" would say its word twice; and "Your own" is not offered (her own
    /// hex needs the seed fields the phone does not have). The heading words are
    /// the Mac's (pinned to its source).
    static let paletteSections: [(title: String?, palettes: [ThemePalette])] = [
        (nil, [.seaglass, .default]),
        ("Pastels", [.lavender, .mint, .pink, .blue]),
        ("Two-tone", [.goldAndBlack, .sageAndTerracotta, .slateAndAmber,
                      .plumAndCream, .inkAndCoral, .greyAndGreen]),
        ("Bold", [.cobaltAndTangerine, .peachAndIndigo, .butterAndCobalt,
                  .roseAndMoss, .tealAndRust]),
    ]

    /// VM-247 — the note's background's two words. DRAFT (her wording pass):
    /// "Cream" is her own word for road (b).
    static func groundWord(_ ground: MobileNoteGround) -> String {
        switch ground {
        case .paper: "Paper"
        case .cream: "Cream"
        }
    }

    /// VM-254 — the five steps' words. DRAFT (her wording pass); short enough
    /// that five share the row at 402 pt in Terminal at the default size.
    static func textSizeWord(_ size: MobileTextSize) -> String {
        switch size {
        case .smaller: "Smaller"
        case .small: "Small"
        case .standard: "Default"
        case .large: "Large"
        case .larger: "Larger"
        }
    }

    // MARK: - The list (VM-53)

    /// **ONE scrolling, grouped list** (VM-53 — the ticket: "Settings is a
    /// fixed stack that cannot scroll, nearly every row is a 14 pt tall word").
    /// The sheet header stays put; under it everything scrolls, so the list
    /// grows with the text size and nothing clips. Groups under their section
    /// names on the room, rows on the paper with hairlines from the gutter (the
    /// lock mockup's settings rows, sheet §C/§E); every door is a whole-row
    /// target at least the menu row's 44 (`PhoneMenuRow`, the gutter inside
    /// it), every choice the system's segmented control (`PhoneSegmentedChoice`).
    /// Today's rows only, grouped: rows whose features do not exist on the phone
    /// yet (the palette, Lock now, the writing and document settings, crash
    /// reports, the tour) are other tickets'.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PhoneSheetHeader(
                tokens.path(["Settings"]), tokens: tokens, titleInk: tokens.phone.muted
            ) { dismiss() }
            .padding(.horizontal, PhoneMetrics.gutter)
            .padding(.top, PhoneMetrics.Space.s8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    libraryGroup
                    lookGroup
                    // Tag management (parity C3 — her cross-fully ruling; R52's
                    // Settings home mirrored: the manager is where you look at
                    // tags).
                    MobileSettingsGroup(Self.tagsGroupTitle, tokens: tokens) {
                        PhoneMenuRow(
                            tokens.chromeLabel(MobileTagManagerSheet.doorTitle),
                            tokens: tokens, inset: PhoneMetrics.gutter
                        ) { tagsPresented = true }
                        .accessibilityLabel(MobileTagManagerSheet.doorTitle)
                    }
                    // R13p-11's attribution obligation reaches the phone too — it
                    // ships the same SQLCipher, so it owes the same notice. Same
                    // words as the Mac's pane (`AcknowledgmentsCopy`, Shared).
                    MobileSettingsGroup(Self.helpGroupTitle, tokens: tokens) {
                        PhoneMenuRow(
                            tokens.chromeLabel("Acknowledgments"),
                            tokens: tokens, inset: PhoneMetrics.gutter
                        ) { acknowledgmentsPresented = true }
                        .accessibilityLabel("Acknowledgments")
                    }
                    diagnosticsGroup
                    #if DEBUG
                    debugGroups
                    #endif
                }
                .padding(.bottom, PhoneMetrics.Space.s48)
            }
            // (The Restore “Encryption Explained” row — pre-13x F2 —
            // REMOVED at 13s-b U1b, R-13s-37: "encryption explained not
            // present and not restorable". An existing store's copy is her
            // data and stays.)
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
        .sheet(isPresented: $timingPresented) {
            MobileTimingView(tokens: tokens)
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

    /// **The library's group** — the sync row, then the ONE Protection door.
    private var libraryGroup: some View {
        MobileSettingsGroup(Self.libraryGroupTitle, tokens: tokens) {
            if let services {
                // D1: the ONE injection site of the shared pages' phone
                // style — the row restyles to the live voice, and the
                // Account sheet it presents inherits the style through
                // the environment (sheets inherit their presenter's
                // environment — the SnapshotPrivacy precedent). The Mac
                // never sets this key (its accessor compiles to nil).
                // The gutter aligns the row with the section names (the
                // styled row carries no horizontal padding of its own —
                // the old 14+6 composition is the nil arm's).
                SyncStatusRow(services: services)
                    .environment(\.sharedPageStyle, SharedPageStyle(tokens: tokens))
                    // VM-27 (her report — "file the double protections as a bug"): the row gets NO Protection door
                    // here. Its keys-locked and not-yet faces used to draw their own *Protection…* door directly above
                    // the standing row below — one gate (`protectionDoor`) fed both, so the sheet said the word twice.
                    // The standing row is the one door: it is on this sheet whenever the row's door could be, and in
                    // every other state too. A doored paused state says its sentence alone (the face's P-2 arm).
                    .environment(\.protectionPaneDoor, nil)
                    .frame(
                        maxWidth: .infinity, minHeight: PhoneMetrics.RowHeight.accessory,
                        alignment: .leading)
                    .padding(.horizontal, PhoneMetrics.gutter)
                    .padding(.vertical, PhoneMetrics.Space.s4)
            } else {
                Text(tokens.chromeLabel("Starting…"))
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .frame(
                        maxWidth: .infinity, minHeight: PhoneMetrics.RowHeight.menu,
                        alignment: .leading)
                    .padding(.horizontal, PhoneMetrics.gutter)
            }
            // VM-8 unit 1 (PROVISIONAL P-VM8-2): Settings ▸ Protection — the phone's screen over the shared protection
            // brains (unit 1: the Sync/account section). The row's name is the sync row's own door name (P-VX486-1).
            // Since VM-27 the sheet's ONE Protection door.
            if let protectionDoor {
                PhoneMenuRow(
                    tokens.chromeLabel(SyncRowFace.openProtectionLabel),
                    tokens: tokens, inset: PhoneMetrics.gutter
                ) { protectionDoor() }
                .accessibilityLabel(SyncRowFace.openProtectionLabel)
            }
        }
    }

    /// **The look — all of it THIS PHONE's own** (VM-247; her words: "I don't like
    /// that the theme syncs between mac and phone either it's annoying" · "the
    /// voice should also be per device"): the voice, the colour palette, the
    /// note's background (her "cream background color option"), light · dark ·
    /// follow the system (VM-53) and her words' size (VM-254) — each kept in this
    /// device's defaults
    /// (`MobileLookController`, `MobileAppearanceController`), never the synced
    /// `setting` table; a look chosen on the Mac moves nothing here.
    private var lookGroup: some View {
        MobileSettingsGroup(Self.lookGroupTitle, tokens: tokens) {
            choiceRow(Self.voiceLabel) {
                PhoneSegmentedChoice(
                    [ThemeVoice.terminal, .study], selection: router.voice, tokens: tokens,
                    word: Self.voiceWord, select: { router.setVoice($0) })
            }
            choiceRow(Self.paletteLabel) { paletteMenu }
            choiceRow(Self.groundLabel) {
                PhoneSegmentedChoice(
                    MobileNoteGround.allCases, selection: router.look.choice.ground, tokens: tokens,
                    word: Self.groundWord, select: { router.look.setGround($0) })
            }
            choiceRow(Self.appearanceLabel) {
                PhoneSegmentedChoice(
                    AppearanceChoice.allCases, selection: router.appearance.choice, tokens: tokens,
                    word: Self.appearanceWord, select: { router.appearance.set($0) })
            }
            // VM-254 (her R-260-2): her words' size on this phone — the five
            // steps scale her words only; the chrome around them holds.
            choiceRow(Self.textSizeLabel) {
                PhoneSegmentedChoice(
                    MobileTextSize.allCases, selection: router.look.choice.textSize, tokens: tokens,
                    word: Self.textSizeWord, select: { router.look.setTextSize($0) })
            }
        }
    }

    /// **The colour palette** (VM-247) — sixteen choices, more than a segmented
    /// control holds, so the choice is the SYSTEM's menu (the Library's sort door's
    /// idiom: a checkmark on the chosen, nothing private built — PROVISIONAL
    /// P-260-3c): its door is the row under the label, the chosen palette's name
    /// in ink with the pop-up glyph, a whole-width target at least 44 tall. The
    /// screen recolours as she picks — the swatches the Mac draws are the room
    /// itself here.
    private var paletteMenu: some View {
        let chosen = router.look.choice.palette
        return Menu {
            ForEach(Self.paletteSections.indices, id: \.self) { index in
                let section = Self.paletteSections[index]
                Section {
                    ForEach(section.palettes, id: \.self) { palette in
                        Button {
                            router.look.setPalette(palette)
                        } label: {
                            if palette == chosen {
                                Label(Self.paletteWord(palette), systemImage: "checkmark")
                            } else {
                                Text(Self.paletteWord(palette))
                            }
                        }
                    }
                } header: {
                    if let title = section.title { Text(title) }
                }
            }
        } label: {
            HStack(spacing: PhoneMetrics.Space.s8) {
                Text(tokens.chromeLabel(Self.paletteWord(chosen)))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: PhoneMetrics.touchMinimum, alignment: .leading)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(Self.paletteLabel)
        .accessibilityValue(Self.paletteWord(chosen))
    }

    /// A labelled choice: the label on its own line, the system control under
    /// it across the row (three words do not share a line with a label at 402
    /// pt in Terminal).
    private func choiceRow<Choice: View>(
        _ label: String, @ViewBuilder choice: () -> Choice
    ) -> some View {
        VStack(alignment: .leading, spacing: PhoneMetrics.Space.s8) {
            Text(tokens.chromeLabel(label))
                .phoneType(.control, tokens)
                .foregroundStyle(tokens.ink)
                .accessibilityLabel(label)
            choice()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PhoneMetrics.gutter)
        .padding(.vertical, PhoneMetrics.Space.s12)
    }

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
    //
    // VM-53: the on/off is the system switch (it was a text button whose
    // words flipped to "Recording edit trace — tap to stop"); its words are
    // the row's own. Whether it ships in Release is W-214's, not this list's.
    private var diagnosticsGroup: some View {
        MobileSettingsGroup(Self.diagnosticsGroupTitle, tokens: tokens) {
            Toggle(isOn: $traceArmed) {
                Text(tokens.chromeLabel("Record edit trace"))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.ink)
            }
            .tint(tokens.accent)
            .frame(minHeight: PhoneMetrics.RowHeight.menu)
            .padding(.horizontal, PhoneMetrics.gutter)
            .accessibilityLabel("Record edit trace")
            .onChange(of: traceArmed) { _, armed in
                // The appear's seed reads the recorder; only a change she made
                // writes it back.
                if armed != MobileEditTrace.isArmed { MobileEditTrace.setArmed(armed) }
            }
            PhoneMenuRow(
                tokens.chromeLabel("Edit trace…"), tokens: tokens, inset: PhoneMetrics.gutter
            ) { tracePresented = true }
            .accessibilityLabel("Open the edit trace")
            // VM-65 (PROVISIONAL P-65-1): the timing readout — her moments'
            // numbers, before and after every speed fix. Release-live, like the
            // edit trace beside it. (VM-47's re-land: the group's menu row, the
            // edit trace's own door shape.)
            PhoneMenuRow(
                tokens.chromeLabel(MobileTimingCopy.door), tokens: tokens, inset: PhoneMetrics.gutter
            ) { timingPresented = true }
            .accessibilityLabel("Open the timing readout")
        }
    }

    #if DEBUG
    /// The dev store's own doors (DEBUG-only by design — the A4 fence), grouped
    /// as they were sectioned.
    @ViewBuilder
    private var debugGroups: some View {
        MobileSettingsGroup("Tutorial (dev store)", tokens: tokens) {
            PhoneMenuRow(
                tokens.chromeLabel("Open the pocket guide"), tokens: tokens, inset: PhoneMetrics.gutter
            ) { Task { await openGuideDoor() } }
            PhoneMenuRow(
                tokens.chromeLabel("Restore the pocket guide…"), tokens: tokens,
                inset: PhoneMetrics.gutter
            ) { Task { await restoreGuideDoor() } }
            if let tutorialNote { noteLine(tutorialNote) }
        }
        MobileSettingsGroup("Performance (dev store)", tokens: tokens) {
            PhoneMenuRow(
                tokens.chromeLabel("Seed the 100k fixture"), tokens: tokens, inset: PhoneMetrics.gutter
            ) { Task { await perfDoor() } }
            if let perfNote { noteLine(perfNote) }
        }
        // D2 look sweep: the spike door joins the one register.
        // (The pre-13x batch 0 keychain probe row lived here — deleted
        // at batch 2a with the real Apple-key item, row 12.)
        MobileSettingsGroup(nil, tokens: tokens) {
            PhoneMenuRow(
                tokens.chromeLabel("TK2 Spike"), tokens: tokens, inset: PhoneMetrics.gutter
            ) { spikePresented = true }
        }
    }

    /// A door's spoken outcome, as a row of the group it belongs to.
    private func noteLine(_ note: String) -> some View {
        Text(tokens.chromeLabel(note))
            .phoneType(.meta, tokens)
            .foregroundStyle(tokens.phone.muted)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, PhoneMetrics.gutter)
            .padding(.vertical, PhoneMetrics.Space.s8)
    }
    #endif

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
            tutorialNote = OpsRefusalCopy.sentence(for: error, roads: .phone)
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
            tutorialNote = OpsRefusalCopy.sentence(for: error, roads: .phone)
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
            perfNote = OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
    }
    #endif

    // (VM-53: the two voice rows — `voiceRow(_:_:)`, the R1 `›` marker or a
    // ✓ carrying the selection — became ONE choice in the Look group, the
    // system's segmented control; their words stay.)
}

/// **One group of the Settings list** (VM-53): its section name on the room
/// (`PhoneSectionHeader` — 24 above, 8 below, at the gutter; none for an
/// unnamed group, which keeps the same air), then its rows full width on the
/// paper with a hairline between rows from the gutter (the lock mockup's
/// settings rows; sheet §C/§E). A row the caller does not render (a door that
/// cannot act — P-2) leaves no hairline behind. Phone-local composition, not a
/// control: the rows inside it are the shared controls.
struct MobileSettingsGroup<Rows: View>: View {
    let title: String?
    let tokens: VoiceTokens
    let rows: Rows

    init(_ title: String?, tokens: VoiceTokens, @ViewBuilder rows: () -> Rows) {
        self.title = title
        self.tokens = tokens
        self.rows = rows()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                PhoneSectionHeader(tokens.chromeLabel(title), tokens: tokens)
                    .padding(.horizontal, PhoneMetrics.gutter)
                    .accessibilityLabel(title)
            } else {
                Color.clear.frame(height: PhoneControlMetrics.sectionAbove)
            }
            VStack(alignment: .leading, spacing: 0) {
                Group(subviews: rows) { subviews in
                    ForEach(subviews) { row in
                        if row.id != subviews.first?.id {
                            Divider()
                                .overlay(tokens.line)
                                .padding(.leading, PhoneMetrics.gutter)
                        }
                        row
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.surface)
        }
    }
}


// (The `restoreEncryptionBookDoor` road — pre-13x F2 — left with its row at
// 13s-b U1b, R-13s-37: the book is not restorable.)
