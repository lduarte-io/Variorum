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
    /// N15's class: the bar's measured width — the one/two-row switch.
    @State private var barWidth: CGFloat = 0
    /// Batch 12 (her "we need a block menu"): the tags sheet the status
    /// line opens. (The comments sheet is model-driven since 13b 1b — the
    /// routed ⌘⇧' door and the menu item share `commentsRequest`.)
    @State private var tagsShown = false
    @Environment(\.openWindow) private var openWindow
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The registry ids this bar renders (walk-asserted with CommitBar's
    /// against the bottomBar door set).
    static let renderedCapabilities: [CapabilityID] = [
        .newTake, .blankTake, .blankTakeAsChosen, .addBlockAtEnd, .blockComments,
        .commitTake, .sealPost, .divide, .extract, .makeBlock, .merge,
        .labelTake,  // 13b Stage 3, 3D (N6): the block menu's label door
        .insertBlockBelow,  // 13b 4D (N28/S4-13): the block menu's insert door
    ]

    /// The structural doors the bar renders (registry-walk-asserted: the
    /// bottomBar-doored structural set, in gesture order).
    static let structuralBar: [(title: String, act: StructuralAct, help: String)] = [
        ("Divide", .divide,
         "Cut the block you're in at your cursor — in Write, carried there for you; "
         + "a block with several takes opens the take ceremony"),
        ("Extract", .extract,
         "Pull your selected span out into its own block — in Write, carried there for you"),
        ("Make Block", .makeBlock,
         "Your selected span becomes its own block — in Write, carried there for you"),
        ("Merge", .merge,
         "Join the block you're in with the one above it — in Write, carried there for you"),
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
            Button("＋ New take — branch of what's shown (⌘T)") {
                guard let slot = targetSlot else { return speakNoTarget() }
                let from = model.focusedPane?.variantID ?? slot.variantID
                guard let from else {
                    return model.speak("This block has no renderable take to branch from.")
                }
                Task { await model.branchTakeRevealed(blockID: slot.blockID, from: from) }
            }
            Button("＋ Blank take (⌥⌘T)") {
                guard let slot = targetSlot else { return speakNoTarget() }
                Task { await model.newBlankTakeRevealed(blockID: slot.blockID) }
            }
            Button("＋ Blank take, opened as chosen (⇧⌥⌘T)") {
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
            Button("＋ New block below this one (⌥⌘N)") {
                // 13b 4D (N28/S4-13): insert-below, native — an empty block
                // mints right under the block you're in and its pane takes
                // the ring. The Takes trap's second half closes here.
                Task { await model.insertBlockBelowFocused() }
            }
            Button("＋ New block at the end of the post") {
                // D3's third leg (13b 1b): native — the minted block's
                // pane takes the ring; typing continues instantly.
                Task { await model.addBlockAtEnd() }
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
            Group {
                if barWidth > 0, barWidth < 1080 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 10) {
                            takeCluster
                            StatusDot(tokens: tokens)
                            postCluster
                            Spacer()
                        }
                        HStack(spacing: 10) {
                            gestureCluster
                            Spacer()
                            trailingCluster
                        }
                    }
                } else {
                    HStack(spacing: 10) {
                        takeCluster
                        StatusDot(tokens: tokens)
                        postCluster
                        StatusDot(tokens: tokens)
                        gestureCluster
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
        .sheet(isPresented: $tagsShown) {
            TagAssignmentSheet(session: model.session, postID: model.postID, postTitle: nil)
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
        Button(tokens.chromeLabel("history")) { Task { await openHistory() } }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The focused take's savepoints — restore any of them")
    }

    /// The post-level doors (seal, tags, entry date).
    @ViewBuilder private var postCluster: some View {
        Button(tokens.chromeLabel(model.projection.sealed ? "unseal" : "seal")) {
            Task { await model.toggleSeal() }
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .help("A sealed post is frozen — nothing under it changes until unsealed")
        Button(tokens.chromeLabel("tags…")) { tagsShown = true }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The post's tags — apply or remove them right here")
        Button(tokens.chromeLabel(
            model.projection.entryDate.map { "date: \($0)" } ?? "set date…")) {
            pickedDate = CommitBar.date(fromDay: model.projection.entryDate) ?? Date()
            datePickerShown = true
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
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

    /// The structural gestures, present and ACTING (13b 1b — R115/R118:
    /// fire-and-DO replaces the retired lecture): each door performs the
    /// one mode-switch choreography — Write, caret landed in your block,
    /// gesture run; on a fanned block Divide opens the take ceremony.
    @ViewBuilder private var gestureCluster: some View {
        ForEach(Self.structuralBar, id: \.title) { door in
            Button(tokens.chromeLabel(door.title)) {
                model.moveToWriteAndRun(.structural(door.act))
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(door.help)
        }
    }

    @ViewBuilder private var trailingCluster: some View {
        if let words = wordCountLabel {
            Text(tokens.chromeLabel(words))
                .font(tokens.small.weight(.semibold))
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
        }
        Button("?") { openWindow(id: "variorum-helper") }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(HelperCheatSheet.summary)
    }

    private var contextLabel: String {
        guard let pane = model.focusedPane,
              let index = model.projection.slots.firstIndex(where: { $0.blockID == pane.blockID })
        else { return "click into a take" }
        return "blk \(index + 1)/\(model.projection.slots.count) · \(String(pane.blockID.prefix(8)))"
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
        parts.append("\(model.postWordCount.formatted())w post")
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private func openHistory() async {
        guard let variantID = model.focusedPane?.variantID else {
            model.speak("Click into a take first — History shows that take's savepoints.")
            return
        }
        history = (try? await model.session.database.read { db in
            try Queries.commitHistory(db, variantID: variantID).reversed()
        }) ?? []
        historyShown = true
    }

    private var historySheet: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Savepoints — this take").font(.headline)
                Spacer()
                Button("Close") { historyShown = false }
            }
            if history.isEmpty {
                Text("No savepoints yet — ⌘S commits one.")
                    .foregroundStyle(tokens.muted)
            }
            List(history, id: \.id) { commit in
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
        .padding(12)
        .frame(minWidth: 520, minHeight: 280)
    }
}
