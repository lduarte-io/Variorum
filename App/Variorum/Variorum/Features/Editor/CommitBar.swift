//
//  CommitBar.swift
//  Variorum
//
//  The commit shortcut's visible face (Phase 7 Step 5): commit the caret
//  block's take, toggle its history. Functional, unstyled.
//

import SwiftUI
import VariorumCore

struct CommitBar: View {
    let model: EditorViewModel

    /// Wave 2c (Act 10 item 18, W8-5 — "note details render to the SIDE
    /// never below the opening paragraphs"): the bar's SECOND arrangement.
    /// `.horizontal` is the standing bottom bar; `.vertical` stacks the
    /// same clusters into a narrow side rail for the book Outline's
    /// focused inline note — ONE brain, every door, two arrangements
    /// (the drift a second bar would invite is exactly why this is an
    /// axis and not a sibling view). In the vertical form the Aa slide-out
    /// becomes a popover (the formatting cluster's ideal width is wider
    /// than any side rail — same doors, summoned).
    enum Axis { case horizontal, vertical }
    var axis: Axis = .horizontal

    init(
        model: EditorViewModel, formattingExpanded: Bool = false,
        axis: Axis = .horizontal
    ) {
        self.model = model
        self.axis = axis
        _formattingShown = State(initialValue: formattingExpanded)
    }

    @State private var datePickerShown = false
    @State private var pickedDate = Date()
    /// 13l Act 2 (item 3): the note-delete confirm's pending ask. View-local
    /// like the date picker's flag — the ACT is `NoteDeletion`'s, and the
    /// wording and the dialog's shape are the shared modifier's.
    @State private var pendingDelete: NoteDeleteConfirm?
    /// N15: the bar's measured width — the one-row/two-row switch.
    @State private var barWidth: CGFloat = 0

    /// **Act 10 item 6 (her ruling: "this bottom bar should be spread out
    /// again, unless the window is small and it needs to be collapsed").**
    /// The shipped threshold was 1080 — an ordinary editor pane collapsed,
    /// which is exactly her screenshot. The clusters' one-row content
    /// measures ~800 pt in the wider (Terminal, monospace) voice, so 840
    /// keeps one row wherever it genuinely fits and the collapse becomes
    /// the genuinely-small fallback her ruling wants. Pure, so the decision
    /// is pinned (`CommitBarLayoutTests`), not observed.
    nonisolated static let twoRowThreshold: CGFloat = 840

    nonisolated static func usesTwoRows(width: CGFloat) -> Bool {
        width > 0 && width < twoRowThreshold
    }
    /// Ledger row 28: is the formatting row slid out? Session UI state, per
    /// bar — a fold is not document semantics (`FormattingDoor`'s own note).
    /// Seeded at birth so a pin can mount the bar in EITHER state and read
    /// what is really drawn (the `TrayPanel(model:)` seam pattern, and its
    /// reason: a `@State` toggle is unreachable from outside the view).
    @State private var formattingShown: Bool
    @Environment(\.openWindow) private var openWindow
    // Phase 13 C1 (R11): the status line wears the voice; the word counts
    // are PROMINENT (the terminal mockup's liked idiom).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The registry ids this bar renders (13b 1b — walk-asserted with the
    /// Takes bar's against the bottomBar door set).
    static var renderedCapabilities: [CapabilityID] {
        [
            .commitTake, .sealPost, .blockComments, .divide, .extract, .makeBlock,
            .merge, .showTakes,
            .insertBlockBelow,  // 13b 4D (N28/S4-13): editor parity — Write's bar door
            .deleteBlock,  // 13c 1B (A8): the delete door beside the insert door
            .archiveBlock,  // the post-13l polish round (row 14 / F1): its twin
            // (`.showNoteTray` LEFT this bar at the post-13l polish round,
            // ledger row 9 — her C1 ruling moved the tray to the masthead's
            // icon and the side panel, and *"the note ▾ menu's item follows
            // the move"*. The act is declared with `.surface` doors only now.)
            // 13l Act 2 (item 3): the door she went looking for and could not
            // find, in the same menu.
            .deleteNote,
            // The post-13l polish round (ledger row 17): **History**, beside
            // commit. Her ruling — *"history is quite similar to commit, it's
            // the natural pair to commit"* — so the bar carries the block's
            // two time controls side by side: write a moment, see the moments.
            .showBlockHistory,
            // The post-13l polish round (ledger rows 16/23): the NOTE's two
            // time controls, in the `note ▾` menu — ⌘⇧S saves the whole note as
            // it is, and Versions… is the list of the moments it has. The
            // grain pairing with commit/history one line up IS the teaching
            // moment her G4 chapter names.
            .saveNoteVersion, .showNoteVersions,
        ]
        // 13k K7: the formatting toolbar's own eight, from ITS table (the
        // cluster is rendered here, so its doors are declared here).
        + FormatBar.renderedCapabilities
    }

    var body: some View {
        Group {
            if axis == .vertical {
                verticalBody
            } else {
                horizontalBody
            }
        }
        // Ledger row 17: the FALLBACK host. The pane's named home is the post
        // detail's inspector; this editor is also composed where there is no
        // detail (the scraps hosts, the book spread's inline form), and a door
        // that cannot act in its context should not have been rendered (P-2).
        .sheet(item: Binding(
            get: { model.blockHistoryRequest },
            set: { model.blockHistoryRequest = $0 })
        ) { request in
            BlockHistoryPane(
                session: model.session, request: request,
                onOpenTray: { blockID in
                    // No inspector here either, so the tray takes the same
                    // road this pane did — the bar's own sheet host.
                    model.blockHistoryRequest = nil
                    model.trayRequest = TrayRequest(
                        postID: model.postID, revealBlockID: blockID)
                },
                // Ledger row 33: the sheet host re-points the same way the
                // inspector does — a new request in the same slot.
                onJump: { request in model.blockHistoryRequest = request })
        }
        // Rows 16/23: the same fallback host for the Versions listing, and for
        // the same reason — this editor is composed where no inspector exists.
        .sheet(isPresented: Binding(
            get: { model.versionsRequested },
            set: { model.versionsRequested = $0 })
        ) {
            NoteVersionsPane(session: model.session, postID: model.postID)
        }
    }

    /// The SIDE RAIL (wave 2c): the same clusters, stacked — where you
    /// are, the block's doors, the note's, the counts. It reads top-down
    /// the way the flat row reads left-to-right.
    private var verticalBody: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(tokens.chromeLabel(caretLabel))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            blockMenu
            gestureButton("Takes", available: model.gestureAvailability.takes,
                          action: model.openCaretFan)
            Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .disabled(model.caretVariantID == nil || model.header?.locked == true)
                .help("An immutable savepoint of the take under the caret")
            Button(tokens.chromeLabel(BlockHistoryPath.doorLabel)) {
                model.requestBlockHistory()
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("Everything this block has been: each take's saved moments, "
                + "its archived and deleted takes, and the block it came out of")
            Divider().overlay(tokens.line).padding(.vertical, 1)
            noteMenu
            Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
                .buttonStyle(VoicedButtonStyle(tokens: tokens))
                .help("The caret block's comments — working remarks on a block, "
                    + "never per-take")
            VoicedChip(
                tokens: tokens, text: FormattingDoor.label, on: formattingShown
            ) {
                formattingShown.toggle()
            }
            .help(FormattingDoor.help(expanded: formattingShown))
            .popover(isPresented: $formattingShown, arrowEdge: .trailing) {
                // The same slide-out, summoned: the formatting cluster and
                // the newlines chip, at their own ideal width.
                formattingRow
            }
            Divider().overlay(tokens.line).padding(.vertical, 1)
            if let block = model.caretBlockWordCount {
                Text(tokens.chromeLabel("\(block)w block"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            if let selected = model.selectionWordCount {
                Text(tokens.chromeLabel("\(selected)w selected"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            if let total = model.postWordCount {
                WordTargetFace(
                    tokens: tokens, baseLabel: "\(total.formatted())w in note",
                    words: model.postWordCount,
                    target: model.header?.wordTarget,
                    onSet: { target in await model.setPostWordTarget(target) })
            }
            Button("?") { openWindow(id: "variorum-helper") }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(HelperCheatSheet.summary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.room, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tokens.line, lineWidth: 1))
    }

    private var horizontalBody: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            // Ledger row 28: the formatting row slides out ABOVE the flat row
            // — upward, away from the page's bottom edge — so the doors she
            // was reaching for do not move under her cursor when it opens.
            if formattingShown {
                formattingRow
                Divider().overlay(tokens.line)
            }
            // Batch 9 (R101): the round-2 status-line grammar — quiet
            // voiced words on the room; every door stays. 13b 3F (N15):
            // the bar is ADAPTIVE — one row where it fits (the detail
            // editor), two rows where it doesn't (the book-inline form,
            // whose default width wrapped every label mid-word — "com mit
            // ⌘S"; her call: "it needs 2 rows or something"). MEASURED
            // width, not ViewThatFits: every cluster is compressible
            // (lineLimit(1) truncation), so ViewThatFits judged the
            // one-row arrangement as "fitting" at any width and never
            // fell through — the flexible-children gotcha, seen live.
            // 13g batch 7 (her ruling R6-2, from round 5: *"i feel like the
            // bottom bar is looking a little bit overly crowded … something
            // where there could be groupings on the bottom of settings and
            // clicking on them brings all the options out in a slide - almost
            // like tab groups in a brwoser"*): the flat row keeps exactly
            // what she named — the block line, `block ▾`, the take door,
            // commit, `note ▾`, comments, newlines-make-blocks, the counts
            // and `?` — and the rest slide out of the two groups. The doors
            // are the SAME registry ids in the same numbers; only where they
            // are rendered moved (`renderedCapabilities` is unchanged, and
            // the registry walk proves it).
            Group {
                if Self.usesTwoRows(width: barWidth) {
                    // The width-responsive FALLBACK (Act 10 item 6 — her
                    // ruling: one row at ordinary widths; collapse only when
                    // the window is genuinely small). The counts ride the
                    // first row's right side — her screenshot's collapsed
                    // state left it empty while both rows packed left.
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 10) {
                            identityCluster
                            Spacer()
                            trailingCluster
                        }
                        HStack(spacing: 10) {
                            postCluster
                            Spacer()
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        identityCluster
                        StatusDot(tokens: tokens)
                        postCluster
                        Spacer()
                        trailingCluster
                    }
                }
            }
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { barWidth = $0 }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tokens.room)
        }
    }

    /// The flat row's block half: where you are, the block group, and the
    /// take door she said earns its place.
    @ViewBuilder private var identityCluster: some View {
        Text(tokens.chromeLabel(caretLabel))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
        blockMenu
        gestureButton("Takes", available: model.gestureAvailability.takes,
                      action: model.openCaretFan)
        Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .disabled(model.caretVariantID == nil || model.header?.locked == true)
            .help("An immutable savepoint of the take under the caret")
        // Ledger row 17 — THE PAIR. It is never disabled: unlike commit,
        // which needs a take to write into, a block always has a history to
        // read, and where the caret is nowhere the act SPEAKS the registry's
        // note rather than sitting grey (P-2, the standing fire-and-speak
        // posture for a door with no target).
        Button(tokens.chromeLabel(BlockHistoryPath.doorLabel)) {
            model.requestBlockHistory()
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .help("Everything this block has been: each take's saved moments, "
            + "its archived and deleted takes, and the block it came out of")
    }

    /// **block ▾** (R6-2): the structural gestures plus the two block-scoped
    /// mints, one slide-out. Fire-and-DO is unchanged — every row invokes the
    /// same call its button did, so a refusal still speaks (P-2). What is
    /// deliberately gone is the per-door DIMMING by the planner's verdict:
    /// a menu row cannot carry it, and the Takes bar's own block menu has
    /// shipped enabled-and-speaking since 13b (QUESTIONS #52).
    private var blockMenu: some View {
        VoicedMenu(tokens: tokens, label: "block") {
            Button("Divide") { model.divideAtCursor() }
            Button("Extract") { model.extractSelection() }
            Button("Make Block") { model.makeBlockFromSelection() }
            Button("Merge") { model.mergeBlocks() }
            Divider()
            Button("＋ New block below this one (⌘⇧⏎)") {
                Task { await model.insertBlockBelowCaret() }
            }
            // Ledger row 14 (F1): the kept road, beside the clocked one and
            // BEFORE it — the order the menu bar's Block menu and the block
            // context menu already use, so the three doors read alike.
            Button(CapabilityRegistry.capability(.archiveBlock).menuTitle()) {
                Task { await model.archiveCaretBlock() }
            }
            Button("− Delete this block") {
                Task { await model.deleteCaretBlock() }
            }
        }
        .help("Everything block-scoped: divide, extract, make block, merge, "
            + "the two block mints, and the two ways to set a block aside")
    }

    /// The flat row's note half: `note ▾`, comments, the newlines chip — and
    /// (13k K7) the formatting toolbar, which sits with them because it acts
    /// on the text of the note you are writing.
    @ViewBuilder private var postCluster: some View {
        noteMenu
        Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The caret block's comments — working remarks on a block, never per-take")
        StatusDot(tokens: tokens)
        // Ledger row 28 (her kickoff addition, scope ruled at the sitting):
        // the eight formatting doors and the newlines chip condense to ONE
        // Aa chip; everything else in this bar stays visible at rest.
        VoicedChip(
            tokens: tokens, text: FormattingDoor.label, on: formattingShown
        ) {
            formattingShown.toggle()
        }
        .help(FormattingDoor.help(expanded: formattingShown))
    }

    /// What Aa slides out: the formatting cluster, and the newlines chip
    /// beside it (13b 4D — N34/S4-14/S4-21: the one_block face's Write half,
    /// an in-view setting chip over the Phase-1 machinery; the header
    /// observation keeps `effectiveSegmentation` and this chip live).
    @ViewBuilder private var formattingRow: some View {
        HStack(spacing: 10) {
            FormatBar(tokens: tokens, status: model.session.status)
            StatusDot(tokens: tokens)
            newlinesChip
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(tokens.room)
    }

    /// **note ▾** (R6-2): history, the seal, the entry date. The date
    /// picker's popover is anchored on the MENU rather than on a row —
    /// a menu item cannot host one.
    private var noteMenu: some View {
        VoicedMenu(tokens: tokens, label: "note") {
            // (The "History" item LEFT this menu at the post-13l polish round,
            // ledger row 17 — and its being here is exactly what her F2 report
            // was about: *"it's unclear that history is under Note, that makes
            // it seem like the Note's history."* It was the BLOCK's, and it is
            // now a door in the bar that says so.)
            // The post-13l polish round (ledger rows 16/23): the note's own two
            // time controls, in the menu that IS the note. They sit first
            // because they are what the menu is most often opened for now.
            Button(CapabilityRegistry.capability(.saveNoteVersion).menuTitle()) {
                Task { await model.saveNoteVersion() }
            }
            Button(VersionsPath.menuLabel) { model.requestNoteVersions() }
            Divider()
            Button(model.header?.locked == true ? "Unseal" : "Seal") {
                model.toggleSeal()
            }
            Divider()
            Button(model.header?.entryDate.map { "Date: \($0)…" } ?? "Set date…") {
                pickedDate = Self.date(fromDay: model.header?.entryDate) ?? Date()
                datePickerShown = true
            }
            // 13l post-close, her #77 ruling (2026-08-24): the door renders in
            // NOTE contexts only — the scraps editor composes this same bar
            // with the POOL's id, and a door that can never act isn't rendered
            // (P-2; the walk observed the pre-fence version tombstone the
            // scraps area). The act-level kind fence in `NoteDeletion.run`
            // stays as the belt; this is the braces. The availability rule is
            // the header's own kind — nil (still loading) hides with it.
            if model.header?.kind == .post {
                Divider()
                // 13l Act 2 (item 3) — HER DOOR, in the menu she went looking
                // in. It is ordinary move-to-Trash and NOTHING else: Delete
                // Now never appears in a note context (her 13j round-3 rider),
                // so the only way past the 30 days from here is the Trash
                // itself.
                Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                    Task { pendingDelete = await NoteDeletion.ask(
                        session: model.session, postIDs: [model.postID]) }
                }
            }
        }
        .help("The note itself: its seal and its date (its tray is the tray "
            + "icon at the top of the note; a block's savepoints are the "
            + "history door beside commit)")
        .popover(isPresented: $datePickerShown, content: datePickerPopover)
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: model.session, postIDs: confirm.postIDs)
        }
    }

    /// The one_block chip (its truth is the observed header).
    @ViewBuilder private var newlinesChip: some View {
        let mints = model.header?.effectiveSegmentation != .oneBlock
        VoicedChip(
            tokens: tokens,
            text: mints ? SegmentationFaceCopy.chipOn : SegmentationFaceCopy.chipOff,
            on: mints
        ) {
            Task { await model.setNewlinesMintBlocks(!mints) }
        }
        .help(SegmentationFaceCopy.help)
    }

    @ViewBuilder private func datePickerPopover() -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Entry date").font(.headline)
                DatePicker(
                    "Entry date", selection: $pickedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                HStack {
                    Button("Clear Date") {
                        datePickerShown = false
                        Task { await model.updateEntryDate(nil) }
                    }
                    Spacer()
                    Button("Set") {
                        datePickerShown = false
                        let day = JournalDay.dayString(from: pickedDate)
                        Task { await model.updateEntryDate(day) }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(12)
    }

    /// 13b 1b (AD-14): the transient status line moved to the ONE shell
    /// toast (StatusCenter — R93's readability rides there).
    @ViewBuilder private var trailingCluster: some View {
        if let words = wordCountLabel {
            // R11: word-count PROMINENCE — the accent-colored,
            // always-there part of the editing surface. 13b 4F (N36):
            // the counts are now the per-post word-target face too —
            // progress rides the label, clicking opens the setter (zero
            // new bar width; the target's truth is the observed header).
            WordTargetFace(
                tokens: tokens, baseLabel: words,
                words: model.postWordCount,
                target: model.header?.wordTarget,
                onSet: { target in await model.setPostWordTarget(target) })
        }
        // Sitting 9 (R73/R91): hover = the cheat sheet; click =
        // the full helper with the dictionary.
        Button("?") { openWindow(id: "variorum-helper") }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(HelperCheatSheet.summary)
    }

    private func gestureButton(
        _ title: String, available: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(tokens.chromeLabel(title), action: action)
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .opacity(available ? 1 : 0.55)
    }

    private var caretLabel: String {
        if model.caretBlockID != nil {
            // "block 6/23" (9d): the user-facing number is the current
            // order, derived at read time; the stable ID stays the identity.
            // 13g R5-4: the raw ID and the "blk" abbreviation are gone — one
            // shared label so this bar and the Takes bar cannot drift.
            return BlockLineLabel.caret(ordinal: model.caretOrdinal, of: model.blockCount)
        }
        if model.hasOpenTail { return "open tail" }
        return "—"
    }

    private var wordCountLabel: String? {
        var parts: [String] = []
        if let block = model.caretBlockWordCount { parts.append("\(block)w block") }
        if let selected = model.selectionWordCount { parts.append("\(selected)w selected") }
        // R11: the post total, always ambient (incremental — never a
        // whole-document walk per keystroke).
        if let total = model.postWordCount {
            parts.append("\(total.formatted())w in note")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// "yyyy-MM-dd" → a local-calendar Date (the picker's seed). Pure and
    /// nonisolated: the View conformance makes CommitBar MainActor-isolated,
    /// and an isolated static traps when called off-main (the 9c
    /// SignInFlow lesson).
    nonisolated static func date(fromDay day: String?) -> Date? {
        guard let day, JournalDay.isValid(day) else { return nil }
        let parts = day.split(separator: "-").compactMap { Int($0) }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        components.hour = 12
        return Calendar.current.date(from: components)
    }
}
