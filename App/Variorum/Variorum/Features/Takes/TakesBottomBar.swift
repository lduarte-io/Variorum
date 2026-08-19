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
    @State private var datePickerShown = false
    @State private var pickedDate = Date()
    @State private var historyShown = false
    @State private var history: [CommitPoint] = []
    /// 13j batch 3: the block's PAST beside its savepoints — the lineage row
    /// (J3, her round-5 amendment) and its deleted takes (the round-5 ruling),
    /// through the one component Write's history face also composes.
    @State private var pastModel: BlockPastModel?
    /// 13j J11: which quiet savepoint runs this sheet has open. View-local,
    /// like Write's — a fold is not document semantics.
    @State private var expandedRuns: Set<String> = []
    /// N15's class: the bar's measured width — the one/two-row switch.
    @State private var barWidth: CGFloat = 0
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
            .showNoteTray,  // 13j J2: the note ▾ menu's tray door
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
        .sheet(isPresented: $historyShown) {
            historySheet
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
        // 13j J3: the released original's peek, hosted beside the tray — one
        // view, presented wherever a door raises it.
        .sheet(item: Binding(
            get: { model.originPeek },
            set: { model.originPeek = $0 })
        ) { request in
            OriginPeekPanel(session: model.session, request: request)
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
        // 13b 4D (N34 — S4-14/S4-21): the one_block face — an in-view
        // setting chip (the wash-chip class, recorded not declared) over
        // the Phase-1 machinery; the honest consequence speaks on toggle.
        // Refresh rides the bar at projection cadence (a segmentation
        // change alone never moves the takes projection — the setter
        // refreshes itself; an external change catches up next projection).
        VoicedChip(
            tokens: tokens,
            text: model.newlinesMintBlocks
                ? SegmentationFaceCopy.chipOn : SegmentationFaceCopy.chipOff,
            on: model.newlinesMintBlocks
        ) {
            let mint = model.newlinesMintBlocks
            Task { await model.setNewlinesMintBlocks(!mint) }
        }
        .task(id: model.projection) { await model.refreshSegmentation() }
        .help(SegmentationFaceCopy.help)
        // 13k K7: the formatting toolbar, in the same slot Write's bar gives
        // it — one grammar across the two bars (R6-2's whole point).
        StatusDot(tokens: tokens)
        FormatBar(tokens: tokens, status: model.session.status)
    }

    /// **note ▾** (R6-2): history, the seal, the entry date — Write's bar's
    /// group, with the take's own history in the history slot.
    private var noteMenu: some View {
        VoicedMenu(tokens: tokens, label: "note") {
            Button("History") { Task { await openHistory() } }
            Button(model.projection.sealed ? "Unseal" : "Seal") {
                Task { await model.toggleSeal() }
            }
            Divider()
            // 13j J2: the tray's NAMED door — Write's bar's item, here, so
            // the two bars keep one grammar (R6-2's whole point).
            Button("\(TrayPath.menuLabel)\u{2026}") { model.requestNoteTray() }
            Divider()
            Button(model.projection.entryDate.map { "Date: \($0)…" } ?? "Set date…") {
                pickedDate = CommitBar.date(fromDay: model.projection.entryDate) ?? Date()
                datePickerShown = true
            }
        }
        .help("The note itself: this take's savepoints, its seal, its tray, its date")
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

    private func openHistory() async {
        guard let pane = model.focusedPane else {
            model.speak("Click into a take first — History shows that take's savepoints.")
            return
        }
        let variantID = pane.variantID
        history = (try? await model.session.database.read { db in
            try Queries.commitHistory(db, variantID: variantID).reversed()
        }) ?? []
        // 13j batch 3: the block's past rides the same summoned face — one
        // "past" surface per block (her round-5 words).
        pastModel = BlockPastModel(session: model.session, blockID: pane.blockID)
        historyShown = true
    }

    /// True while the block has nothing in its past — the A1 container is
    /// mounted and zero-size, so the sheet's spacing must not pay for it.
    private var pastIsEmpty: Bool { pastModel?.isEmpty ?? true }

    /// **R2-N2's absorption, as a value** (13j batch 6): what the past
    /// section's top padding must be so the sheet's own `spacing: 8` is not
    /// paid twice for a zero-size view. Pure and static so a pin can hold the
    /// decision without measuring SwiftUI: the stack puts a gap BEFORE this
    /// child and another AFTER it, and an empty child means the reader sees
    /// 16 pt of nothing under the title. Cancelling exactly one gap restores
    /// the single space the sheet was designed with.
    static func pastSectionTopPadding(pastEmpty: Bool) -> CGFloat {
        pastEmpty ? -8 : 0
    }

    private var historySheet: some View {
        // 13j batch 6 — LADDER A's R2-N2, absorbed. The past section's
        // container is deliberately ALWAYS mounted (it carries the starting
        // `.task`; a `Group` that renders nothing runs no task, which is the
        // A1 BLOCKER this fixed), so on the common case — a block with no
        // past — a zero-size view still takes a stack gap and the sheet
        // showed a doubled 16 pt space under its title. The gap is the
        // STACK's to decide, so the stack decides it: the section keeps its
        // life, the spacing stops paying for a view with no height. (Write's
        // host is spacing-0 and was never affected.)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Savepoints — this take").font(.headline)
                Spacer()
                Button("Close") { historyShown = false }
            }
            if let pastModel {
                BlockPastSection(model: pastModel, tokens: tokens) { origin in
                    historyShown = false
                    model.revealOriginBlock(origin)
                }
                .padding(.top, Self.pastSectionTopPadding(pastEmpty: pastIsEmpty))
            }
            if history.isEmpty {
                Text("No savepoints yet — ⌘S commits one.")
                    .foregroundStyle(tokens.muted)
            }
            // 13j J11 — the same quiet-run collapse Write's face renders,
            // through the same pure grouping and the same collapsed row.
            // This face lists OLDEST-first (`openHistory` reverses the
            // query's newest-first order) and the rule does not care: a run
            // is contiguous read either way.
            List {
                ForEach(SavepointRuns.rows(
                    history, isQuiet: { $0.kind == .auto }, id: { $0.id })
                ) { row in
                    let rendered = SavepointHistoryFace.rendered(row, expanded: expandedRuns)
                    if let count = rendered.runCount {
                        QuietRunRow(count: count, expanded: rendered.expanded, tokens: tokens) {
                            expandedRuns = SavepointHistoryFace.toggling(row.id, in: expandedRuns)
                        }
                    }
                    ForEach(rendered.items, id: \.id) { commitRow($0) }
                }
            }
        }
        .padding(12)
        .frame(minWidth: 520, minHeight: 280)
    }

    @ViewBuilder
    private func commitRow(_ commit: CommitPoint) -> some View {
        HStack(spacing: 8) {
            Text(commit.createdAt.formatted(date: .abbreviated, time: .standard))
                .font(.caption)
            Text(commit.kind == .auto ? "auto" : "manual")
                .font(.caption2)
                .foregroundStyle(commit.kind == .auto ? .secondary : .primary)
            Spacer()
            Text(String(commit.text.prefix(60)))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Button("Restore") {
                Task { await model.restoreCommit(commit) }
            }
            .controlSize(.small)
            .disabled(model.projection.sealed)
        }
    }
}
