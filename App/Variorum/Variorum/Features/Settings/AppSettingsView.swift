//
//  AppSettingsView.swift
//  Variorum
//
//  Phase 13, B2 — the Settings window: APPEARANCE (the B1 global settings
//  — voice R1, seams R42, editing indicator R14/R22, inline comments R7,
//  follow-the-scroll R25, fan style) and TAGS (R52 — tag management's real
//  home: "if it's not in the sidebar it still needs to be somewhere":
//  create, adjust hierarchy, rename, delete; ⌘K-reachable; in-context
//  editing everywhere stands beside it). Promote-tag(s)-to-book (R30/R37)
//  lives here too — the manager is where you look at tags.
//
//  **13u4 UNIT S1 — THE SHAPE CHANGED (her items 4 and 6).** Her words:
//  *"the settings menu could probably be broken up a little more - an
//  overall one, then maybe tabs on text editing shortcuts, window /
//  reshaping shortcuts, etc."* and *"simple text search within the settings
//  menu - it's too hard to find how to make a callout."*
//
//  What was here: ONE `TabView` of five tabs, whose first tab was a single
//  `Form` holding FIVE sections and fifteen controls. That is why the 18j
//  appearance control sat below the fold at the shipped 560×460 size
//  (KnownIssues row 59, her own owner assignment) — a pane that long has a
//  fold wherever you put the window.
//
//  What is here now: a LEADING PANE LIST beside a detail column, with the
//  search field at the list's head. The pane list is chosen over more tabs
//  for three reasons, all of them hers: nine panes cannot fit a tab bar;
//  the search needs a home and this is where macOS puts one; and the
//  reference artifact's grammar (`notes/plans/pre-13u-mockups/
//  blocks-and-snippets.html`, her *"actual guide"*) is solid geometric
//  lines and calm cards, which is a list and a hairline. **Row 59 dies by
//  construction**: General stays SHORT (six catalog rows, the two short
//  dials at its top — the caps are pinned), so the appearance choice is
//  on screen the moment Settings opens.
//
//  The panes, the catalog and the search brain are `SettingsShape.swift`;
//  this file composes them.
//

import GRDB  // AsyncValueObservation iteration (the ThemeStore pattern)
import SwiftUI
import VariorumCore

struct AppSettingsView: View {
    let session: AppSession
    /// 13l Act 4: the Data Safety pane reads the backup scheduler and the
    /// sync session. Optional for the same reason `RootView`'s is — the
    /// Settings scene can open before the main window's composition has run,
    /// and the pane says so honestly rather than rendering dashes.
    let services: AppServices?
    /// 13p Batch 2: the protection brain (the bootstrap's — dials, modes,
    /// escrow, the passphrase doors). Optional like `services`.
    let protection: ProtectionController?
    /// 18j (her R-Q12): the app's ONE appearance owner (`NSApp.appearance`
    /// at the root — `AppearanceChoice.swift`). Optional like `services`
    /// and `protection`: a host that composes this pane without the app
    /// delegate (a preview, a pin) gets the row's door hidden rather than a
    /// second owner minted beside the real one.
    let appearance: AppearanceController?
    /// 13r U3-A: the app's ONE update channel — General's "Check for updates
    /// automatically" maps onto Sparkle's own setting through it. Rendered
    /// only where the channel is LIVE (P-2: never in a Debug build).
    let updates: UpdateChannel?
    /// 13r U3-B: the app's ONE crash-reporting owner — Settings ▸
    /// Diagnostics reads and calls it. Optional like `protection`: a host
    /// without the app delegate (a preview, a pin) gets no Diagnostics pane
    /// rather than a second owner minted beside the real one (P-2).
    let crashReports: CrashReporting?
    /// 13n-b U1: the app's ONE MCP door owner (the app delegate's). nil
    /// hosts render no MCP pane (P-2).
    let mcp: MCPDoor?
    @State private var theme: ThemeStore
    @State private var tags: TagsViewModel
    /// The pane on screen. Her "overall one" opens.
    @State private var pane: SettingsPane = .general
    /// Item 4's field. Session-lived and nothing else — no storage, nothing
    /// synced, gone when the window closes.
    @State private var query = ""
    @Environment(\.colorScheme) private var scheme

    /// 13x U2 row 6: the Restore surface's per-row door (Settings' own
    /// adoption presenter behind it). nil hosts render no Open… rows.
    let restoreDoor: ((URL) -> Void)?
    /// 13x F1 (R1-MAJOR): Data Safety's hand-off twin (Settings' own
    /// presenter behind it). nil hosts render no door.
    let handOffDoor: (() -> Void)?

    init(
        session: AppSession, services: AppServices? = nil,
        protection: ProtectionController? = nil,
        appearance: AppearanceController? = nil,
        updates: UpdateChannel? = nil,
        crashReports: CrashReporting? = nil,
        mcp: MCPDoor? = nil,
        restoreDoor: ((URL) -> Void)? = nil,
        handOffDoor: (() -> Void)? = nil
    ) {
        self.session = session
        self.services = services
        self.protection = protection
        self.appearance = appearance
        self.updates = updates
        self.crashReports = crashReports
        self.mcp = mcp
        self.restoreDoor = restoreDoor
        self.handOffDoor = handOffDoor
        _theme = State(initialValue: ThemeStore(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
    }

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    /// **Which catalog rows each pane actually renders** — the registry
    /// walk's own shape (`CommitBar.renderedCapabilities`, P-1: declared ⇔
    /// rendered), one layer down. Without it the catalog could name a
    /// control no pane shows, and the search would send her to a pane that
    /// does not hold the thing it promised: the same drift her item 7
    /// reports one menu over, arriving through the search instead.
    ///
    /// The panes composed from other files (`Tags`, `Protection`, `Data
    /// Safety`, `Diagnostics`, `Acknowledgments`) carry ONE catalog row each
    /// — the pane itself (Diagnostics': its one toggle), so it can be found by
    /// name — and that row is what these entries say.
    static let rowIDsRendered: [SettingsPane: [String]] = [
        .general: ["voice", "palette", "appearance", "receipts", "keepOpenNotes", "updates"],
        .editor: ["seams", "indicator", "inlineComments", "paragraphGap",
                  "arrivalFlash", "ownershipBadges", "hideOwnedDefault",
                  "hoverHandles", "spellcheck", "longBlocks"],
        .takes: ["fanStyle", "followScroll"],
        .writing: ["segmentation", "cadence", "pruning"],
        .shortcuts: [],
        .tags: ["tagManager"],
        // 13n-c U4: Waiting renders while an ask waits (the catalog row says so).
        .mcp: ["mcpServer", "mcpWaiting", "mcpOpenBook"],
        .protection: ["protection"],
        .dataSafety: ["backups"],
        .diagnostics: ["crashReports"],
        .acknowledgments: ["acknowledgments"],
    ]

    /// The panes this window can show. Protection is dropped where no
    /// controller exists (a preview, a pin) rather than rendered empty —
    /// P-2's letter, which the old `TabView` already applied to that tab.
    private var panes: [SettingsPane] {
        SettingsPane.allCases.filter {
            ($0 != .protection || protection != nil)
                && ($0 != .diagnostics || crashReports != nil)
                && ($0 != .mcp || mcp != nil)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            // The reference artifact's "solid geometric lines" — one
            // hairline, never a floating pane (W8-3's retirement).
            Rectangle()
                .fill(tokens.line)
                .frame(width: 1)
            detail
        }
        .frame(width: 720, height: 520)
        .background(tokens.room)
        // Every voiced modifier inside Settings (`alarmVoice()` and its
        // siblings) reads the store from the environment and otherwise
        // falls back — so the panes have been painting in the FALLBACK
        // voice since they were written. One line, and Protection's and
        // Data Safety's refusals finally wear the voice she chose.
        .environment(theme)
        .tint(tokens.accent)
        .task { await theme.start() }
        .task { await tags.start() }
        // 13n-c U4 — ⌥⌘, (MCP Settings…): the pane OPENS at MCP — on a fresh
        // window (appear) and on a window already up (the request changing).
        .onAppear { adoptMCPRequest() }
        .onChange(of: mcp?.settingsRequest) { _, _ in adoptMCPRequest() }
    }

    /// ⌥⌘,'s request, adopted once each (the door's counter and this
    /// window's "seen" mark — `MCPDoor.settingsRequest`).
    private func adoptMCPRequest() {
        guard let mcp, Self.adopts(request: mcp.settingsRequest, adopted: mcp.settingsRequestAdopted)
        else { return }
        mcp.settingsRequestAdopted = mcp.settingsRequest
        query = ""
        pane = .mcp
    }

    /// Pure: a request is adopted exactly once.
    nonisolated static func adopts(request: Int, adopted: Int) -> Bool {
        request > adopted
    }

    // MARK: - The leading column (the search, then the panes)

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchField
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(panes) { candidate in
                        paneRow(candidate)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
        }
        .frame(width: 196)
        .background(tokens.surface)
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
            TextField(text: $query) {
                Text(tokens.chromeLabel("search settings"))
            }
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .lineLimit(1)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                }
                .buttonStyle(.plain)
                .help("Clear the search")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(tokens.line, lineWidth: 1))
        .padding(10)
    }

    private func paneRow(_ candidate: SettingsPane) -> some View {
        let selected = candidate == pane && query.isEmpty
        return Button {
            query = ""
            pane = candidate
        } label: {
            HStack(spacing: 7) {
                Image(systemName: candidate.symbol)
                    .font(tokens.small)
                    .frame(width: 16)
                    .foregroundStyle(selected ? tokens.accent : tokens.muted)
                Text(tokens.chromeLabel(candidate.title))
                    .font(tokens.small)
                    .fontWeight(selected ? .semibold : .regular)
                    .foregroundStyle(selected ? tokens.ink : tokens.muted)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear),
                in: RoundedRectangle(cornerRadius: 7))
            .contentShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }

    // MARK: - The detail column

    @ViewBuilder private var detail: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Rectangle().fill(tokens.line).frame(height: 1)
            if query.isEmpty {
                paneBody
            } else {
                SettingsResultsPane(
                    tokens: tokens, query: query,
                    onOpen: { finding in
                        query = ""
                        pane = finding.pane
                    })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(query.isEmpty ? pane.title : "search"))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(query.isEmpty
                 ? pane.blurb
                 : "Settings, keyboard shortcuts and the app's own words — all three.")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    @ViewBuilder private var paneBody: some View {
        switch pane {
        case .general:
            GeneralPane(theme: theme, session: session, appearance: appearance, updates: updates)
        case .editor:
            EditorSettingsPane(theme: theme)
        case .takes:
            TakesSettingsPane(theme: theme)
        case .writing:
            WritingSettingsPane(session: session)
        case .shortcuts:
            ShortcutsSettingsPane(tokens: tokens)
        case .tags:
            TagManagerPane(session: session, tags: tags)
        case .protection:
            if let protection {
                // 13p Batch 2: the at-open modes, presets, escrow, and the
                // passphrase/recovery doors (R13p-5/6/7/9).
                ProtectionPane(controller: protection, services: services)
            }
        case .dataSafety:
            // 13l Act 4 (ledger row 12): backups, their freshness, and what
            // restoring one does — including to things that were deleted.
            // 13x U2: + the Restore from Backup rows (QB's second door).
            DataSafetyPane(
                services: services, protection: protection, restoreDoor: restoreDoor,
                handOffDoor: handOffDoor)
        case .diagnostics:
            // 13r U3-B (R-13r-5; the architect's Option A): the crash-report
            // opt-in at the head, the received reports verbatim under it.
            if let crashReports {
                DiagnosticsPane(crashReports: crashReports)
            }
        case .mcp:
            // 13n-b U1: the MCP door's pane — the app's ONE door owner, handed
            // down like `crashReports` (P-1: its acts render from the registry).
            if let mcp {
                MCPPane(door: mcp)
            }
        case .acknowledgments:
            // 13p Batch 1 (R13p-11's attribution obligation): the Zetetic
            // copyright line, the SQLCipher license text, and the
            // dependency notices — user-accessible, functional over polish.
            AcknowledgmentsPane()
        }
    }
}

// MARK: - The search results (her item 4)

/// The detail column while the field has words in it. A result names its
/// PANE, so the answer teaches where the thing lives as well as what it is
/// — and a shortcut or a dictionary word answers without going anywhere,
/// which is the whole point of *"it's too hard to find how to make a
/// callout"*: the answer to that is a chord, not a setting.
private struct SettingsResultsPane: View {
    let tokens: VoiceTokens
    let query: String
    let onOpen: (SettingsFinding) -> Void

    private var findings: [SettingsFinding] {
        SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                if findings.isEmpty {
                    Text("Nothing here matches “\(query)”. Try a word from the thing itself — "
                         + "“callout”, “dark”, “seam”, “commit”.")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        // P-8, per site and deliberate: this is PROSE, and a
                        // sentence whose own point falls off the end is row
                        // 63's defect (`CalmSectionHeader`'s own note says
                        // the same). `nil` is the decision, not the default.
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                } else {
                    ForEach(findings) { finding in
                        Button { onOpen(finding) } label: {
                            CalmCard(tokens: tokens) {
                                row(finding)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func row(_ finding: SettingsFinding) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(finding.lead)
                    .font(finding.kind == .shortcut
                          ? .system(.body, design: .monospaced)
                          : tokens.body)
                    .foregroundStyle(tokens.ink)
                    // P-8: a row's NAME, so a cap — but a generous one,
                    // because a helper row's `keys` can be a phrase
                    // ("⏎ / ⇧⏎ in a capture box").
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Text(tokens.chromeLabel(badge(finding)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Text(finding.detail)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                // P-8, deliberate: the ANSWER. Truncating it would be the
                // feature failing at the moment it works — "how do I make a
                // callout" is the sentence, not its first line.
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// What kind of answer this is, in the app's own words.
    private func badge(_ finding: SettingsFinding) -> String {
        switch finding.kind {
        case .setting: finding.pane.title
        case .shortcut: "shortcut"
        case .word: "the word"
        }
    }
}

// MARK: - General (her "overall one")

/// The three appearance dials and how the app talks back — everything here
/// is about the WHOLE app rather than one surface. Deliberately the SHORT
/// pane: **KnownIssues row 59** (the 18j appearance control below the fold)
/// is a fold that existed because fifteen controls shared one pane, and the
/// cure is that this one stays short — six catalog rows, pinned, with
/// the two short dials at the top.
private struct GeneralPane: View {
    let theme: ThemeStore
    let session: AppSession
    let appearance: AppearanceController?
    let updates: UpdateChannel?
    /// VX-139: the Open strip across launches. LOCAL (this Mac's
    /// UserDefaults, the writeHoverHandles class) — the strip is one
    /// window's chrome on one machine; the ids never sync.
    @AppStorage(OpenNotesMemory.settingKey) private var keepOpenNotes = true

    var body: some View {
        Form {
            Section("Voice") {
                Picker(SettingsCatalog.title("voice"), selection: Binding(
                    get: { theme.settings.voice },
                    set: { theme.setVoice($0) })) {
                    Text("Terminal").tag(ThemeVoice.terminal)
                    Text("Study").tag(ThemeVoice.study)
                }
                .pickerStyle(.segmented)
                Text("Two voices, one structure: Terminal is mono and airy with its own idioms; Study is the warm paper-and-serif look. Everything works identically in both, and the colour palette below works under either one.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 18j (her R-Q12): the light/dark choice, the third of the three
            // appearance dials.
            //
            // **13u4 UNIT S1 — KnownIssues row 59 (hers: *"you can add the
            // fold issue to 13u4"*).** Splitting the pane was NOT enough and
            // the walk is what said so: the palette row is five swatch rows
            // and two paragraphs tall, so with it still between the voice
            // and this, "Light & dark" was STILL under the fold at the
            // shipped window size — a shorter pane with the same order has
            // the same fold. So the order changes: the two SHORT dials sit
            // at the top where they are on screen the moment Settings
            // opens, and the palette — by far the tallest control in the
            // app's settings — follows them.
            //
            // 18g's recorded worry (a section added above pushes the
            // palette's custom-hex refusal further out of sight) is
            // answered rather than ignored: what sits above the palette now
            // is two pickers and two short paragraphs, where before it was
            // the whole of the old Appearance tab.
            if let appearance {
                AppearanceChoiceRow(appearance: appearance)
            }
            // 18g (her R-Q6/R-Q11/R-Q13): the palette layers UNDER the
            // voice, and reads that way — it is the third thing on the
            // pane, below both dials it modifies. Its own file: a feature
            // that arrives as fifty lines inside a pane is how a pane
            // becomes a god file.
            Section {
                PaletteSettingsRow(session: session, theme: theme)
            }
            // 18i (her R-Q5): its OWN section, because it is neither a look
            // of the writing surface nor a habit of the document — it is how
            // the app talks back, everywhere. Synced like the Writing pane's
            // settings, so the same act confirms the same way on every
            // device (the fan_style class).
            Section("Confirmations") {
                Picker(SettingsCatalog.title("receipts"), selection: Binding(
                    get: { theme.settings.receiptStyle },
                    set: { theme.setReceiptStyle($0) })) {
                    ForEach(ReceiptStyle.allCases, id: \.self) { style in
                        Text(ReceiptStyleCopy.label(style)).tag(style)
                    }
                }
                Text(ReceiptStyleCopy.help)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                // The sentence the setting must never leave out: a refusal
                // is not a confirmation, and “Off” never silences one.
                Text(ReceiptStyleCopy.alwaysShownNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // VX-139 (her ask, pulled into VX-143 at her word): the Open
            // strip across launches. Beside Confirmations rather than on a
            // writing pane — it is how the app OPENS, not how a note behaves.
            Section("Open notes") {
                Toggle(SettingsCatalog.title("keepOpenNotes"), isOn: $keepOpenNotes)
                Text("The sidebar's Open section returns as you left it the next time Variorum opens — the notes that still exist, in the same order. Off, each launch starts with an empty list. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 13r U3-A — THE CALM-ASKS CADENCE's rule 4: the update ask is
            // always answerable here, without the popup. The checkbox IS
            // Sparkle's own setting; touching it answers the question, so the
            // ask retires for good. Only where a live channel can act (P-2).
            if let updates, updates.isLive {
                Section(UpdateSettingsCopy.section) {
                    Toggle(SettingsCatalog.title("updates"), isOn: Binding(
                        get: { updates.automaticallyChecks },
                        set: { updates.setAutomaticallyChecks($0) }))
                    Text(updates.permissionAnswered
                         ? UpdateSettingsCopy.help
                         : UpdateSettingsCopy.help + " " + UpdateSettingsCopy.unansweredNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Editor (her "text editing" pane)

/// How the writing surface looks and behaves. Everything here is LOCAL to
/// this Mac except the three that were always synced (seams, the editing
/// indicator, inline comments), which say so in their own help.
private struct EditorSettingsPane: View {
    let theme: ThemeStore
    /// 13b 4D (S4-19, her ruling): hover-revealed drag handles in Write —
    /// default ON; OFF = the fully clean surface. LOCAL (this Mac's
    /// UserDefaults, the takes-density class — deliberately not the synced
    /// setting table this batch; recorded).
    @AppStorage("writeHoverHandles") private var writeHoverHandles = true
    /// 13c 1E (memo Q3, option E — PROVISIONAL, QUESTIONS #39): the
    /// phantom fix's KILL SWITCH. Default ON so she can feel it before
    /// ruling on the posture; LOCAL like the hover-handle setting (this is
    /// one Mac's editor behaviour, not document semantics).
    @AppStorage(LongBlockLayout.settingKey) private var longBlockLayout = true
    /// 13d batch 4 (A23): the paragraph-gap choice. LOCAL like its two
    /// neighbours above — one Mac's editor look, not document semantics,
    /// and stored nowhere in the schema (no export byte moves).
    @AppStorage(ParagraphGap.settingKey) private var paragraphGap = ParagraphGap.standard
    /// 13d batch 4 (A24): spellcheck level, coarse by TEXTKIT2 §3's warning.
    @AppStorage(SpellcheckLevel.settingKey) private var spellcheck = SpellcheckLevel.off

    var body: some View {
        Form {
            Section("The page") {
                Toggle(SettingsCatalog.title("seams"), isOn: Binding(
                    get: { theme.settings.seamsVisible },
                    set: { theme.setSeamsVisible($0) }))
                Picker(SettingsCatalog.title("indicator"), selection: Binding(
                    get: { theme.settings.editingIndicator },
                    set: { theme.setEditingIndicator($0) })) {
                    Text("Off — the cursor is enough").tag(EditingIndicatorStyle.off)
                    Text("Outline ring").tag(EditingIndicatorStyle.outline)
                    Text("Background").tag(EditingIndicatorStyle.background)
                }
                Toggle(SettingsCatalog.title("inlineComments"), isOn: Binding(
                    get: { theme.settings.inlineComments },
                    set: { theme.setInlineComments($0) }))
                // 13d batch 4 (A23): the paragraph gap. Pure presentation
                // over the 2026-07-12 ruling's presentation half — uniform
                // and per-PARAGRAPH, never per-seam (§12: boundaries stay
                // invisible at rest).
                Picker(SettingsCatalog.title("paragraphGap"), selection: $paragraphGap) {
                    Text("Standard").tag(ParagraphGap.standard)
                    Text("A blank line's worth").tag(ParagraphGap.paragraphTall)
                }
                Text("Air after every paragraph — inside a block and between blocks alike, so block boundaries stay invisible at rest. Purely how it looks: nothing is stored, and exports are byte-identical either way. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 18l-c U8 (her R-18l-7): the mode switch's arrival flash. Synced,
            // like the three above it — the same switch on every device.
            Section("Switching modes") {
                Toggle(SettingsCatalog.title("arrivalFlash"), isOn: Binding(
                    get: { theme.settings.arrivalFlash },
                    set: { theme.setArrivalFlash($0) }))
                Text(ArrivalFlashCopy.help)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 13i-c U4 (the sitting record §6): the badge family's one switch
            // and the hide-owned global default — synced, like the flash.
            Section(OwnershipSettingsCopy.section) {
                Toggle(SettingsCatalog.title("ownershipBadges"), isOn: Binding(
                    get: { theme.settings.ownershipBadges },
                    set: { theme.setOwnershipBadges($0) }))
                Text(OwnershipSettingsCopy.badgesHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                Toggle(SettingsCatalog.title("hideOwnedDefault"), isOn: Binding(
                    get: { theme.settings.hideOwnedByDefault },
                    set: { theme.setHideOwnedDefault($0) }))
                Text(OwnershipSettingsCopy.hideOwnedHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section("While you write") {
                Toggle(SettingsCatalog.title("hoverHandles"), isOn: $writeHoverHandles)
                Text("ON: pointing at a block in Write reveals its ⠿ drag handle in the left margin. OFF: the fully clean writing surface. With block seams shown (⌘⇧B), every handle shows regardless. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                // 13d batch 4 (A24): coarse by design — TEXTKIT2 §3 records
                // continuous checking + the completion popover crashing
                // NSTextView, so three levels and no finer.
                Picker(SettingsCatalog.title("spellcheck"), selection: $spellcheck) {
                    Text("Off").tag(SpellcheckLevel.off)
                    Text("Check while typing").tag(SpellcheckLevel.checkWhileTyping)
                    Text("Check and correct").tag(SpellcheckLevel.checkAndCorrect)
                }
                Text("Off (the default): no underlines; Edit ▸ Spelling and Grammar still checks on demand. Check while typing: red underlines as you go. Check and correct: macOS also fixes what it is confident about. Applies to every writing surface — Write, takes, comparisons. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(8)
                    .fixedSize(horizontal: false, vertical: true)
                Toggle(SettingsCatalog.title("longBlocks"), isOn: $longBlockLayout)
                Text("ON: when you scroll near a very long block, Variorum asks the text system to measure that one block properly — which removes the empty space it was guessing at underneath. It happens once per block, only for blocks over about a long-paragraph's length and under a measured size cap, and never while you are actually scrolling. OFF: the text system's own estimate stands, and long blocks can show phantom space that vanishes when you scroll onto them. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(10)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Takes

/// Two controls, and that is on purpose. A takes-shaped question ("where do
/// I change how takes open?") gets a pane with the word on it rather than a
/// row buried in a fifteen-control Editor pane — which is the whole
/// complaint item 6 is about. (PROVISIONAL, QUESTIONS #131: folding these
/// two back under Editor is one `case` away.)
private struct TakesSettingsPane: View {
    let theme: ThemeStore

    var body: some View {
        Form {
            Section("The fan") {
                Picker(SettingsCatalog.title("fanStyle"), selection: Binding(
                    get: { theme.settings.fanStyle },
                    set: { theme.setFanStyle($0) })) {
                    Text("Stack").tag(FanStyle.stack)
                    Text("Carousel").tag(FanStyle.carousel)
                    Text("Margin grid").tag(FanStyle.marginGrid)
                    Text("Slot split").tag(FanStyle.slotSplit)
                }
                Toggle(SettingsCatalog.title("followScroll"), isOn: Binding(
                    get: { theme.settings.followTheScroll },
                    set: { theme.setFollowTheScroll($0) }))
                Text("Takes open with ⌘⇧T on the block you are in, and ⎋ closes them all. Both settings are synced, so a fan opens the same way on every device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Writing (the document's own habits — the synced three)

private struct WritingSettingsPane: View {
    let session: AppSession
    /// 13d batch 4 (A16): the DOCUMENT-GLOBAL segmentation default — synced,
    /// because it changes what entry DOES to the store rather than how one
    /// Mac looks.
    @State private var defaultSegmentation: Segmentation = .paragraph
    @State private var segmentationNote: String?
    /// 13j J11: the ONE cadence setting — synced document semantics, exactly
    /// like the segmentation default beside it.
    @State private var savepointCadence: SavepointCadence = .everySession
    @State private var cadenceNote: String?
    /// 13j batch 6b (round 9): history pruning — synced like the cadence.
    @State private var historyPruning: HistoryPruning = .standard
    @State private var pruningNote: String?

    var body: some View {
        Form {
            // 13d batch 4 (A16 — N34's deferred GLOBAL half): document
            // semantics, so it is SYNCED, and it says so. Per-post settings
            // still win where they are set.
            Section("Typing") {
                Picker(SettingsCatalog.title("segmentation"), selection: Binding(
                    get: { defaultSegmentation },
                    set: { setDefaultSegmentation($0) })) {
                    Text(SegmentationFaceCopy.globalParagraph).tag(Segmentation.paragraph)
                    Text(SegmentationFaceCopy.globalOneBlock).tag(Segmentation.oneBlock)
                }
                Text(SegmentationFaceCopy.globalHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(8)
                    .fixedSize(horizontal: false, vertical: true)
                if let segmentationNote {
                    Text(segmentationNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Section("Commits") {
                // 13j J11 (her round-1 ruling): the ONE cadence setting.
                // SYNCED like segmentation above it, and for the same reason
                // — it is a habit of the document, not a look of this Mac.
                Picker(SettingsCatalog.title("cadence"), selection: Binding(
                    get: { savepointCadence },
                    set: { setSavepointCadence($0) })) {
                    ForEach(SavepointCadence.allCases, id: \.self) { cadence in
                        Text(SavepointCadenceCopy.label(cadence)).tag(cadence)
                    }
                }
                Text(SavepointCadenceCopy.help)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(8)
                    .fixedSize(horizontal: false, vertical: true)
                // The sentence the setting must never leave out: the
                // INSURANCE occasions are not a cadence and stay on in
                // every mode.
                Text(SavepointCadenceCopy.insuranceNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                if let cadenceNote {
                    Text(cadenceNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // 13j batch 6b (her round-9 ruling): history PRUNING —
                // one row beside the cadence it exists because of. Synced
                // like it, and "Never means never on every device".
                Picker(SettingsCatalog.title("pruning"), selection: Binding(
                    get: { historyPruning },
                    set: { setHistoryPruning($0) })) {
                    ForEach(HistoryPruning.allCases, id: \.self) { pruning in
                        Text(HistoryPruningCopy.label(pruning)).tag(pruning)
                    }
                }
                Text(HistoryPruningCopy.help)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(8)
                    .fixedSize(horizontal: false, vertical: true)
                if let pruningNote {
                    Text(pruningNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        // A tiny bounded observation over the `setting` table (the
        // ThemeStore pattern) — so a change made on another device shows
        // here, and the picker never drifts from the store.
        .task {
            do {
                for try await value in session.database.observe({ db in
                    try Queries.defaultSegmentation(db)
                }) {
                    defaultSegmentation = value
                }
            } catch {}
        }
        // 13j J11: the same bounded observation for the cadence, so a change
        // made on another device shows here and the picker never drifts.
        .task {
            do {
                for try await value in session.database.observe({ db in
                    try Queries.savepointCadence(db)
                }) {
                    savepointCadence = value
                }
            } catch {}
        }
        // 13j batch 6b: and for the pruning setting, the same shape.
        .task {
            do {
                for try await value in session.database.observe({ db in
                    try Queries.historyPruning(db)
                }) {
                    historyPruning = value
                }
            } catch {}
        }
    }

    /// The write goes through the runner like every other setting write
    /// (the ThemeStore setters' shape); the observation above carries the
    /// new value back, so the picker never holds an optimistic guess.
    private func setDefaultSegmentation(_ segmentation: Segmentation) {
        guard segmentation != defaultSegmentation else { return }
        segmentationNote = segmentation == .oneBlock
            ? SegmentationFaceCopy.globalMintOffNote
            : SegmentationFaceCopy.globalMintOnNote
        Task {
            do {
                try await session.runner.run { try $0.setDefaultSegmentation(segmentation) }
            } catch {
                // Readable words, never the raw enum dump (the R1-3 class —
                // 13d cold review, F-9).
                segmentationNote = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// 13j J11 — the same shape as its neighbour: the write goes through the
    /// runner, and the observation above carries the new value back, so the
    /// picker never holds an optimistic guess.
    private func setSavepointCadence(_ cadence: SavepointCadence) {
        guard cadence != savepointCadence else { return }
        cadenceNote = nil
        Task {
            do {
                try await session.runner.run { try $0.setSavepointCadence(cadence) }
            } catch {
                cadenceNote = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// 13j batch 6b — the pruning setter, its neighbours' exact shape.
    private func setHistoryPruning(_ pruning: HistoryPruning) {
        guard pruning != historyPruning else { return }
        pruningNote = nil
        Task {
            do {
                try await session.runner.run { try $0.setHistoryPruning(pruning) }
            } catch {
                pruningNote = OpsRefusalCopy.message(for: error)
            }
        }
    }
}

// MARK: - Shortcuts (her "text editing shortcuts, window / reshaping shortcuts")

/// The keyboard map, in Settings — **the same grouped list the ⌘/ helper
/// shows**, read from `HelperView.groups` rather than copied, because two
/// copies of a list is two lists (and that one is already held to the
/// registry by `everyDeclaredShortcutIsFindableInTheHelper`).
///
/// Her item 5's other half lands here: *"how are things unindented? that's
/// further proof that I need a better formatting shortcut menu."* The
/// Formatting group names every door, keyed and keyless alike.
private struct ShortcutsSettingsPane: View {
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Every shortcut here is also a menu item — the menus are the map. "
                     + "The search field finds any of these by what it does.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(HelperView.groups) { group in
                    VStack(alignment: .leading, spacing: 5) {
                        CalmSectionHeader(tokens: tokens, title: group.title)
                        CalmCard(tokens: tokens) {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(group.items, id: \.keys) { item in
                                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                                        Text(item.keys)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundStyle(tokens.ink)
                                            .frame(width: 126, alignment: .leading)
                                            // P-8: the chord column. Three
                                            // lines is the widest row the
                                            // helper actually has ("⏎ / ⇧⏎
                                            // in a capture box").
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(item.does)
                                            .font(tokens.small)
                                            .foregroundStyle(tokens.muted)
                                            // P-8, deliberate: prose that
                                            // must finish — this is the
                                            // ⌘/ helper's own wording and
                                            // several rows run four lines.
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                }
                Text("⌘/ opens the same list in its own window, beside the dictionary of the "
                     + "app's own words.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - The tag manager (R52)

private struct TagManagerPane: View {
    let session: AppSession
    let tags: TagsViewModel
    @State private var newTagParent: String?
    @State private var newTagSheet = false
    @State private var renameTarget: Tag?
    @State private var nameField = ""
    @State private var promoteTags: Set<String> = []
    @State private var promoteSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List {
                ForEach(tags.tags, id: \.id) { tag in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { promoteTags.contains(tag.path) },
                            set: { on in
                                if on { promoteTags.insert(tag.path) } else { promoteTags.remove(tag.path) }
                            }))
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                        Text(String(repeating: "    ", count: tags.depth(of: tag)) + tag.name)
                        Text(tag.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .contextMenu {
                        Button("New Child Tag…") {
                            newTagParent = tag.id
                            nameField = ""
                            newTagSheet = true
                        }
                        Button("Rename…") {
                            nameField = tag.name
                            renameTarget = tag
                        }
                        Divider()
                        Button("Delete (with subtree)", role: .destructive) {
                            Task { await tags.deleteTag(tag.id) }
                        }
                    }
                }
                if tags.tags.isEmpty {
                    Text("No tags yet.").foregroundStyle(.secondary)
                }
            }
            HStack {
                Button("New Tag…") {
                    newTagParent = nil
                    nameField = ""
                    newTagSheet = true
                }
                Spacer()
                // R30/R37: promote one or SEVERAL tags to a saved GATHERING —
                // AND-joined or OR-joined; the tags stay on the posts. 13i-d
                // U6 (a): the door names what it mints (it was "Promote to
                // Book…", minting a gathering — "smart" retired, §1/§14).
                Button("Make a Gathering…") { promoteSheet = true }
                    .disabled(promoteTags.isEmpty)
            }
            if let error = tags.lastError {
                Text(error).font(.caption).alarmVoice()
            }
        }
        .padding(12)
        .alert(newTagParent == nil ? "New Tag" : "New Child Tag", isPresented: $newTagSheet) {
            TextField("Name", text: $nameField)
            Button("Create") {
                let name = nameField
                let parent = newTagParent
                Task { await tags.createTag(parentID: parent, name: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Rename Tag",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { tag in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task { await tags.renameTag(tag.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $promoteSheet) {
            PromoteTagsSheet(session: session, tagPaths: promoteTags.sorted())
        }
    }
}

/// R30's face: tags → a saved GATHERING on the Bookcase. AND-joined
/// (`tagsAll`) or OR-joined (`tags`); the promotion LEAVES the tags on the
/// posts (R37 — trivially: nothing here touches applications).
struct PromoteTagsSheet: View {
    let session: AppSession
    let tagPaths: [String]
    @State private var name = ""
    @State private var joinAll = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Make a Gathering").font(.headline)
            Text("Makes a gathering on the Bookcase that shows every note with these tags \u{2014} it holds none of them. The tags stay on the notes.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(tagPaths.map { "#\($0)" }.joined(separator: "  "))
                .font(.callout)
            TextField("Gathering name", text: $name)
            if tagPaths.count > 1 {
                Picker("Notes must carry", selection: $joinAll) {
                    Text("any of these tags (OR)").tag(false)
                    Text("all of these tags (AND)").tag(true)
                }
                .pickerStyle(.radioGroup)
            }
            if let error {
                Text(error).font(.caption).alarmVoice()
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Make Gathering") { promote() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
    }

    /// The spec construction is the whole promotion (pinned in
    /// `ShelfAndPaletteTests`): OR → `tags`, AND → `tagsAll` (R30's letter,
    /// the A2 vocabulary).
    static func spec(paths: [String], joinAll: Bool) -> Queries.SmartQuerySpec {
        joinAll
            ? Queries.SmartQuerySpec(tagsAll: paths)
            : Queries.SmartQuerySpec(tags: paths)
    }

    private func promote() {
        let bookName = name.trimmingCharacters(in: .whitespaces)
        let paths = tagPaths
        let all = joinAll
        Task {
            do {
                _ = try await session.runner.run { ops in
                    // 13e E13 — this is a book-CREATING door with a free-text
                    // name, so it carries the same guard the shelf's does
                    // (her round-3 ruling). Inside the runner closure with
                    // the mint, for that guard's own reason.
                    try ops.assertBookNameIsFree(bookName)
                    return try ops.createReading(
                        name: bookName, kind: .gathering,
                        querySpec: try Self.spec(paths: paths, joinAll: all).encodedJSON())
                }
                dismiss()
            } catch {
                // …and speaks the ops layer's refusal in the app's words
                // rather than dumping the raw enum (the R93 class; this door
                // was the last book-naming one still doing it).
                self.error = OpsRefusalCopy.message(for: error)
            }
        }
    }
}

// MARK: - Acknowledgments (13p Batch 1 — R13p-11's attribution obligation)

/// The dependency notices, verbatim from their checkouts — Zetetic's
/// copyright line and SQLCipher license lead, per the ruling. Functional
/// and honest is the bar here; 13s owns any voice pass over the intro line.
private struct AcknowledgmentsPane: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(AcknowledgmentsCopy.intro)
                    .font(.callout)
                ForEach(AcknowledgmentsCopy.all) { notice in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(notice.name)
                            .font(.headline)
                        Text(notice.role)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text(notice.text)
                            .font(.system(size: 11, design: .monospaced))
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary.opacity(0.04)))
                }
            }
            .padding(16)
        }
    }
}
