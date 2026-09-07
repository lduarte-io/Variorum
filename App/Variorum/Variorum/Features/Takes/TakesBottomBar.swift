//
//  TakesBottomBar.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R63): "the options at the bottom
//  of the write editor should absolutely still be there in the take
//  editor." The bar rides the Takes and Lenses boards: block/word context
//  for the take you're in, Commit (⌘S) + History for THAT take, the
//  post-level Seal / Set Date doors, and the structural gestures present
//  and SPEAKING (they operate on Write's text selection, so here they say
//  exactly where to go — the 9d fire-and-speak posture, never dead keys).
//

import SwiftUI
import VariorumCore

struct TakesBottomBar: View {
    let model: TakesViewModel

    init(model: TakesViewModel, formattingExpanded: Bool = false) {
        self.model = model
        _formattingShown = State(initialValue: formattingExpanded)
    }

    @State private var datePickerShown = false
    @State private var pickedDate = Date()
    /// N15's class: the bar's measured width — the one/two-row switch.
    @State private var barWidth: CGFloat = 0
    /// Ledger row 28: is the formatting row slid out? Write's bar's twin —
    /// session UI state, per bar (`FormattingDoor`'s own note), seeded at
    /// birth for the same pin seam.
    @State private var formattingShown: Bool
    /// 13l Act 2 (item 3): the note-delete confirm's pending ask — Write's
    /// bar's twin, so the two bars keep one grammar (R6-2's whole point).
    @State private var pendingDelete: NoteDeleteConfirm?
    @Environment(\.openWindow) private var openWindow
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The registry ids this bar renders (walk-asserted with CommitBar's
    /// against the bottomBar door set).
    static var renderedCapabilities: [CapabilityID] {
        [
            .newTake, .blankTake, .blankTakeAsChosen, .addBlockAtEnd, .blockComments,
            .commitTake, .sealPost, .divide, .extract, .makeBlock, .merge,
            .labelTake,  // 13b Stage 3, 3D (N6): the block menu's label door
            .insertBlockBelow,  // 13b 4D (N28/S4-13): the block menu's insert door
            .deleteBlock,  // 13c 1B (A8): the block menu's delete door
            .archiveBlock,  // the post-13l polish round (row 14 / F1): its twin
            // (`.showNoteTray` LEFT this bar at the post-13l polish round,
            // ledger row 9 — her C1 ruling; both bars lose it together, which
            // is R6-2's one-grammar point applied to a REMOVAL.)
            .deleteNote,  // 13l Act 2 (item 3): Write's bar's door, here too
            // The post-13l polish round (ledger row 17): **History**, beside
            // commit, on BOTH bars in the same commit — R6-2's one-grammar
            // rule, which matters most when a door moves.
            .showBlockHistory,
            // The post-13l polish round (ledger rows 16/23): the NOTE's two
            // time controls, in `note ▾` — Write's bar's pair, here too
            // (R118's letter: no surface is privileged).
            .saveNoteVersion, .showNoteVersions,
            // 18c batch 3 (her U-6): Write's bar's two rows, here too.
            .splitEveryNewlineIntoBlocks, .splitBlockAtNewlines,
        ]
        // 13k K7: the formatting toolbar rides BOTH bars — the acts are
        // `takesAccess: .native`, so Write must not be the only surface with
        // visible formatting doors (R118).
        + FormatBar.renderedCapabilities
    }

    /// The structural doors the bar renders (registry-walk-asserted: the
    /// bottomBar-doored structural set, in gesture order).
    static let structuralBar: [(title: String, act: StructuralAct, help: String)] = [
        // 13j J4/J4b: both helps say what the flipped defaults actually do —
        // copy naming a behaviour the app no longer has is the J8 class.
        ("Divide", .divide,
         "Cut the block you're in at your cursor, right here — on a block with "
         + "several takes the take you're looking at is cut and the rest are "
         + "copied whole onto both halves (⌥⌘⇧D to place each cut by hand)"),
        ("Extract", .extract,
         "Pull your selected span out into its own block — in Write, carried there for you"),
        ("Make Block", .makeBlock,
         "Your selected span becomes its own block — in Write, carried there for you"),
        ("Merge", .merge,
         "Join the block you're in with the one above it, bringing every take "
         + "along — in Write, carried there for you (⌥⌘⇧M to pair takes by hand)"),
    ]

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The block the menu acts on: the pane you're in; on a one-block post,
    /// THE block (her screenshots' case — no click should be needed).
    /// (13b 1b: the rule moved to the model — the routed commands share it.)
    private var targetSlot: Queries.RenderedBlock? {
        model.commandTargetSlot
    }

    /// The BLOCK MENU (batch 12 — her ask, verbatim: "I feel like we need
    /// a block menu. the same issue has appeared where i can see the takes
    /// but i can't make a new take."): every block-scoped act, one door,
    /// always visible in the status line. Fire-and-speak when no block is
    /// in reach.
    private var blockMenu: some View {
        VoicedMenu(tokens: tokens, label: "block") {
            Button(CapabilityRegistry.capability(.newTake)
                .menuTitle("＋ New take — branch of what's shown")) {
                guard let slot = targetSlot else { return speakNoTarget() }
                let from = model.focusedPane?.variantID ?? slot.variantID
                guard let from else {
                    return model.speak("This block has no renderable take to branch from.")
                }
                Task { await model.branchTakeRevealed(blockID: slot.blockID, from: from) }
            }
            Button(CapabilityRegistry.capability(.blankTake)
                .menuTitle("＋ Blank take")) {
                guard let slot = targetSlot else { return speakNoTarget() }
                Task { await model.newBlankTakeRevealed(blockID: slot.blockID) }
            }
            Button(CapabilityRegistry.capability(.blankTakeAsChosen)
                .menuTitle("＋ Blank take, opened as chosen")) {
                guard let slot = targetSlot else { return speakNoTarget() }
                Task { await model.newBlankTakeAsChosen(blockID: slot.blockID) }
            }
            Button("Label take…") {
                // 13b Stage 3 (3D — N6): the 3B op's bar door; acts on the
                // take you're in (the shown take on a one-block post).
                guard let slot = targetSlot else { return speakNoTarget() }
                guard let variantID = model.focusedPane?.variantID ?? slot.variantID else {
                    return model.speak("This block has no renderable take to label.")
                }
                model.requestTakeLabel(variantID: variantID)
            }
            Divider()
            Button("＋ New block below this one (⌘⇧⏎)") {
                // 13b 4D (N28/S4-13): insert-below, native — an empty block
                // mints right under the block you're in and its pane takes
                // the ring. The Takes trap's second half closes here.
                Task { await model.insertBlockBelowFocused() }
            }
            // 18c batch 3 (her U-6): Write's bar's row, here too — R6-2's one
            // grammar and R118's letter, in the same commit.
            Button(SplitAtNewlinesCopy.blockDoor) {
                Task { await model.splitFocusedBlockAtNewlines() }
            }
            // Ledger row 14 (F1): Write's bar's row, here too — and it
            // finishes the sentence her 13c A8 report started, quoted right
            // below: *"I don't seem to have the ability to delete / archive
            // empty blocks?"* 13c answered the delete half in both bars and
            // archive did not exist yet; this is the other half.
            Button(CapabilityRegistry.capability(.archiveBlock).menuTitle()) {
                Task { await model.archiveFocusedBlock() }
            }
            Button("− Delete this block") {
                // 13c 1B (A8): her "I don't seem to have the ability to
                // delete / archive empty blocks?" — the door where takes
                // live, native (R118 parity with Write's bar).
                Task { await model.deleteFocusedBlock() }
            }
            Button("＋ New block at the end of the note") {
                // D3's third leg (13b 1b): native — the minted block's
                // pane takes the ring; typing continues instantly.
                Task { await model.addBlockAtEnd() }
            }
            Divider()
            // 13g batch 7 (R6-2): the four structural doors moved OFF the
            // flat row and INTO this group — her "block menu for divide,
            // extract, make block, and merge". Same `runStructuralDoor`
            // call, so fire-and-DO's whole choreography is unchanged.
            ForEach(Self.structuralBar, id: \.title) { door in
                Button(door.title) { model.runStructuralDoor(door.act) }
            }
            Divider()
            Button("Comments… (⌘⇧')") {
                model.requestComments()
            }
            Divider()
            Button("Open in Write") {
                model.session.commandRouter.requestMode(.write, postID: model.postID)
            }
        }
        .help("Everything block-scoped: new takes, new blocks, comments — acts on the block you're in")
    }

    private func speakNoTarget() {
        model.speak("Click into a block first — the block menu acts on the block you're in.")
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            // Ledger row 28, Write's bar's twin: the formatting row slides out
            // above the flat row, so nothing she was reaching for moves.
            if formattingShown {
                formattingRow
                Divider().overlay(tokens.line)
            }
            // Batch 9 (R101): the round-2 status-line grammar — quiet
            // voiced words on the room, never a bezel row. Every door
            // stays (R63); only the register changes. 13b 3F (N15's
            // class): the bar is ADAPTIVE by MEASURED width — one row
            // where it fits, two where it doesn't (never mid-word wraps,
            // never a page-wide truncation parade).
            // 13g batch 7 (R6-2): the same two slide-out groups Write's bar
            // grew — `block ▾` and `note ▾` — so the two bars read as one
            // grammar. Every declared door is still rendered here
            // (`renderedCapabilities` unchanged; the registry walk proves
            // it); only the placement moved.
            Group {
                if barWidth > 0, barWidth < 1080 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 10) {
                            takeCluster
                            Spacer()
                        }
                        HStack(spacing: 10) {
                            postCluster
                            Spacer()
                            trailingCluster
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        takeCluster
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
        .task(id: model.projection) { await model.refreshSegmentation() }
        // Ledger row 17: the FALLBACK host, Write's bar's twin — the pane's
        // named home is the post detail's inspector, and this bar also rides
        // surfaces that have none.
        .sheet(item: Binding(
            get: { model.blockHistoryRequest },
            set: { model.blockHistoryRequest = $0 })
        ) { request in
            BlockHistoryPane(
                session: model.session, request: request,
                onOpenTray: { blockID in
                    model.blockHistoryRequest = nil
                    model.trayRequest = TrayRequest(
                        postID: model.postID, revealBlockID: blockID)
                },
                // Ledger row 33: the sheet host re-points the same way the
                // inspector does — a new request in the same slot.
                onJump: { request in model.blockHistoryRequest = request })
        }
        .sheet(item: Binding(
            get: { model.commentsRequest },
            set: { model.commentsRequest = $0 })
        ) { target in
            CommentsPanel(session: model.session, blockID: target.blockID)
        }
        // 13j J2: this note's tray, hosted where the comments sheet is —
        // one view, presented wherever a door raises it.
        .sheet(item: Binding(
            get: { model.trayRequest },
            set: { model.trayRequest = $0 })
        ) { request in
            TrayPanel(
                session: model.session, postID: request.postID,
                revealBlockID: request.revealBlockID)
        }
        .sheet(item: Binding(
            get: { model.takeLabelRequest },
            set: { model.takeLabelRequest = $0 })
        ) { request in
            // 13b Stage 3 (3D — N6): ONE sheet host for both boards (the
            // bar rides Takes and Lenses; the cell menus and the block
            // menu all set the same model request).
            TakeLabelSheet(currentLabel: request.currentLabel) { label in
                Task { await model.setTakeLabel(request.variantID, label: label) }
            }
        }
        // Rows 16/23: the Versions listing's fallback host, Write's bar's twin.
        .sheet(isPresented: Binding(
            get: { model.versionsRequested },
            set: { model.versionsRequested = $0 })
        ) {
            NoteVersionsPane(session: model.session, postID: model.postID)
        }
    }

    /// Take context + take acts (the block menu, + take, commit, history).
    @ViewBuilder private var takeCluster: some View {
        Text(tokens.chromeLabel(contextLabel))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
        blockMenu
        Button(tokens.chromeLabel("+ take")) {
            // The one-click twin of the menu's first item (her
            // batch-10 report: "i don't see an option in the
            // bottom bar where i can add a new take").
            guard let slot = targetSlot else { return speakNoTarget() }
            let from = model.focusedPane?.variantID ?? slot.variantID
            guard let from else {
                return model.speak("This block has no renderable take to branch from.")
            }
            Task { await model.branchTakeRevealed(blockID: slot.blockID, from: from) }
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
        .help("A new take on the block you're in, branched from what's shown (⌘T)")
        Button(tokens.chromeLabel("commit ⌘S")) {
            Task { await model.commitFocusedTake() }
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
        .disabled(model.projection.sealed)
        .help("An immutable savepoint of the take you're in")
        // Ledger row 17 — the pair, Write's bar's twin. Never disabled: a
        // sealed note's history is still readable (the seal freezes writing,
        // not looking), and with no block in reach the act SPEAKS (P-2).
        Button(tokens.chromeLabel(BlockHistoryPath.doorLabel)) {
            model.requestBlockHistory()
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .help("Everything this block has been: each take's saved moments, "
            + "its archived and deleted takes, and the block it came out of")
    }

    /// The flat row's note half: `note ▾`, comments, and the newlines chip
    /// (13g batch 7, R6-2 — Write's bar's grammar, here).
    @ViewBuilder private var postCluster: some View {
        noteMenu
        // 13b 4D (N35 + S4-33, her rider verbatim: "the comments button
        // should be there in takes the way it is in write, on the bottom
        // bar") — parity of PROMINENCE, not just existence: the same
        // direct door Write's bar carries (the block ▾ menu's item stays;
        // the routed ⌘⇧' and this button share `requestComments`).
        Button(tokens.chromeLabel("comments")) { model.requestComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The block's comments — working remarks on a block, never per-take (⌘⇧')")
        StatusDot(tokens: tokens)
        // Ledger row 28: Write's bar's Aa chip, here too — one grammar
        // across the two bars (R6-2's whole point, and the reason the door
        // and its row live in `FormattingDoor` rather than twice).
        VoicedChip(
            tokens: tokens, text: FormattingDoor.label, on: formattingShown
        ) {
            formattingShown.toggle()
        }
        .help(FormattingDoor.help(expanded: formattingShown))
    }

    /// What Aa slides out — Write's row, with this board's own newlines chip.
    ///
    /// 13b 4D (N34 — S4-14/S4-21): the one_block face — an in-view setting
    /// chip (the wash-chip class, recorded not declared) over the Phase-1
    /// machinery; the honest consequence speaks on toggle. Refresh rides the
    /// bar at projection cadence (a segmentation change alone never moves the
    /// takes projection — the setter refreshes itself; an external change
    /// catches up next projection). **The refreshing `.task` rides the BAR,
    /// not the row**, deliberately: the row is behind a fold now, and a chip
    /// that only learned the truth once she opened the fold would be a stale
    /// setting wearing a confident face.
    @ViewBuilder private var formattingRow: some View {
        HStack(spacing: 10) {
            FormatBar(tokens: tokens, status: model.session.status)
            StatusDot(tokens: tokens)
            VoicedChip(
                tokens: tokens,
                text: model.newlinesMintBlocks
                    ? SegmentationFaceCopy.chipOn : SegmentationFaceCopy.chipOff,
                on: model.newlinesMintBlocks
            ) {
                let mint = model.newlinesMintBlocks
                Task { await model.setNewlinesMintBlocks(!mint) }
            }
            .help(SegmentationFaceCopy.help)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(tokens.room)
    }

    /// **note ▾** (R6-2): history, the seal, the entry date — Write's bar's
    /// group, with the take's own history in the history slot.
    private var noteMenu: some View {
        VoicedMenu(tokens: tokens, label: "note") {
            // (The "History" item LEFT this menu at the post-13l polish round,
            // ledger row 17 — Write's bar lost it in the same commit. Her F2
            // report is the reason: a block's history reached through a menu
            // called `note ▾` reads as the NOTE's.)
            // The post-13l polish round (ledger rows 16/23) — Write's bar's
            // pair, in the same order, in the same commit (R6-2).
            Button(CapabilityRegistry.capability(.saveNoteVersion).menuTitle()) {
                Task { await model.saveNoteVersion() }
            }
            Button(VersionsPath.menuLabel) { model.requestNoteVersions() }
            Divider()
            // 18c batch 3 (her U-6): Write's bar's row, in Takes too.
            Button(SplitAtNewlinesCopy.noteDoor) {
                Task { await model.splitEveryNewlineIntoBlocks() }
            }
            Divider()
            Button(model.projection.sealed ? "Unseal" : "Seal") {
                Task { await model.toggleSeal() }
            }
            Divider()
            Button(model.projection.entryDate.map { "Date: \($0)…" } ?? "Set date…") {
                pickedDate = CommitBar.date(fromDay: model.projection.entryDate) ?? Date()
                datePickerShown = true
            }
            Divider()
            // 13l Act 2 (item 3): Write's bar's door, in Takes too — R118's
            // letter (no surface is privileged) and R6-2's one grammar.
            Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                Task { pendingDelete = await NoteDeletion.ask(
                    session: model.session, postIDs: [model.postID]) }
            }
        }
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: model.session, postIDs: confirm.postIDs)
        }
        .help("The note itself: its seal and its date (a block's savepoints "
            + "are the history door beside commit; its tray is the tray icon "
            + "at the top of the note)")
        .popover(isPresented: $datePickerShown) {
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
    }

    @ViewBuilder private var trailingCluster: some View {
        if let words = wordCountLabel {
            // 13b 4F (N36): the counts are the per-post word-target face
            // here too — R118 parity of prominence with Write's bar; the
            // target refreshes with the segmentation chip's cadence.
            WordTargetFace(
                tokens: tokens, baseLabel: words,
                words: model.postWordCount,
                target: model.postWordTarget,
                onSet: { target in await model.setPostWordTarget(target) })
        }
        Button("?") { openWindow(id: "variorum-helper") }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(HelperCheatSheet.summary)
    }

    private var contextLabel: String {
        guard let pane = model.focusedPane,
              let index = model.projection.slots.firstIndex(where: { $0.blockID == pane.blockID })
        else { return "click into a take" }
        // 13g R5-4: her ruling — no raw ID, no "blk". ONE shared label with
        // Write's bar (`BlockLineLabel`), so the two cannot drift.
        return BlockLineLabel.caret(ordinal: index + 1, of: model.projection.slots.count)
    }

    private var wordCountLabel: String? {
        var parts: [String] = []
        if let pane = model.focusedPane,
           let slot = model.projection.slots.first(where: { $0.blockID == pane.blockID }),
           let column = model.columns.first,
           let resolved = model.resolvedTake(column: column, slot: slot) {
            // O(the focused take) per render — the P1 edit unit.
            parts.append("\(TextMetrics.wordCount(resolved.text))w take")
        }
        // Round-1 MINOR-5: the post total is the model's CACHE (recomputed
        // per projection, incremental) — the bar re-renders per keystroke
        // (it reads the observed authority) and must never re-enumerate
        // every slot's full text each time.
        parts.append("\(model.postWordCount.formatted())w note")
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
