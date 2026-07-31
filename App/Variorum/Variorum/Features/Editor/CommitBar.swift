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
    @State private var datePickerShown = false
    @State private var pickedDate = Date()
    /// N15: the bar's measured width — the one-row/two-row switch.
    @State private var barWidth: CGFloat = 0
    /// Batch 12 — the tags door ("so unclear how you're supposed to add
    /// tags"): the post's tag sheet, right in the status line.
    @State private var tagsShown = false
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
    static let renderedCapabilities: [CapabilityID] = [
        .commitTake, .sealPost, .blockComments, .divide, .extract, .makeBlock,
        .merge, .showTakes,
        .insertBlockBelow,  // 13b 4D (N28/S4-13): editor parity — Write's bar door
        .deleteBlock,  // 13c 1B (A8): the delete door beside the insert door
    ]

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
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
            Group {
                if barWidth > 0, barWidth < 1080 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 10) {
                            identityCluster
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
                        identityCluster
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
            if model.commitList != nil {
                CommitHistoryView(model: model)
                    .frame(maxHeight: 180)
            }
        }
    }

    /// Caret identity + the take acts (commit, history).
    @ViewBuilder private var identityCluster: some View {
        Text(tokens.chromeLabel(caretLabel))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
        Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .disabled(model.caretVariantID == nil || model.header?.locked == true)
            .help("An immutable savepoint of the take under the caret")
        Button(tokens.chromeLabel(model.commitList == nil ? "history" : "hide history")) {
            model.toggleCommitHistory()
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .disabled(model.caretVariantID == nil && model.commitList == nil)
        .help("The caret take's savepoints — restore any of them")
    }

    /// The post lifecycle faces (Phase 10 Step 8): the seal toggle, tags,
    /// comments, and Mac-side entry-date editing live with the open post.
    @ViewBuilder private var postCluster: some View {
        Button(tokens.chromeLabel(model.header?.locked == true ? "unseal" : "seal")) {
            model.toggleSeal()
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .help("A sealed note is frozen — nothing under it changes until unsealed")
        Button(tokens.chromeLabel("tags…")) { tagsShown = true }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The note's tags — apply or remove them right here")
            .sheet(isPresented: $tagsShown) {
                TagAssignmentSheet(
                    session: model.session, postID: model.postID,
                    postTitle: model.header?.title)
            }
        Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The caret block's comments — working notes on a block, never per-take")
        Button(tokens.chromeLabel(
            model.header?.entryDate.map { "date: \($0)" } ?? "set date…")) {
            pickedDate = Self.date(fromDay: model.header?.entryDate) ?? Date()
            datePickerShown = true
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .popover(isPresented: $datePickerShown, content: datePickerPopover)
        // 13b 4D (N34 — S4-14/S4-21): the one_block face's Write half — an
        // in-view setting chip over the Phase-1 machinery; the header
        // observation keeps `effectiveSegmentation` (and this chip) live.
        newlinesChip
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

    /// The gesture button bar (9d — the fourth door): dimmed by the
    /// planner's verdict but ALWAYS clickable — a refused click speaks
    /// its refusal instead of going silent.
    @ViewBuilder private var gestureCluster: some View {
        gestureButton("Divide", available: model.gestureAvailability.divide,
                      action: model.divideAtCursor)
        gestureButton("Extract", available: model.gestureAvailability.extract,
                      action: model.extractSelection)
        gestureButton("Make Block", available: model.gestureAvailability.makeBlock,
                      action: model.makeBlockFromSelection)
        gestureButton("Merge", available: model.gestureAvailability.merge,
                      action: model.mergeBlocks)
        // 13b 4D (N28/S4-13): insert-below — an empty block right under the
        // caret block, the caret landing in it (parity with the Takes bar's
        // block-menu door). Fire-and-speak: no caret block ⇒ the refusal
        // speaks; a sealed post refuses through the op.
        Button(tokens.chromeLabel("＋ below")) {
            Task { await model.insertBlockBelowCaret() }
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        .help("New Block Below (⌘⇧⏎) — an empty block right under the one you're in; type straight into it")
        // 13c 1B (A8): the delete door, beside the insert door it mirrors.
        Button(tokens.chromeLabel("− block")) {
            Task { await model.deleteCaretBlock() }
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        .help("Delete Block — removes the block you're in; ⌥⌘Z undoes it, ⇧⌥⌘Z redoes it, and it waits in this note's deleted-blocks tray")
        gestureButton("Takes", available: model.gestureAvailability.takes,
                      action: model.openCaretFan)
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
            let ordinal = model.caretOrdinal.map { "\($0)/\(model.blockCount)" } ?? "—"
            return "blk \(ordinal) · \(shortID(model.caretBlockID))"
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

    private func shortID(_ id: String?) -> String {
        String((id ?? "").prefix(8))
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

/// The caret variant's append-only history, newest first, with restore —
/// and the documented pre-split warning (AppSpec §9) marked per row.
struct CommitHistoryView: View {
    let model: EditorViewModel

    var body: some View {
        List(model.commitList ?? []) { item in
            HStack(spacing: 8) {
                Text(item.commit.createdAt.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                Text(item.commit.kind == .auto ? "auto" : "manual")
                    .font(.caption2)
                    .foregroundStyle(item.commit.kind == .auto ? .secondary : .primary)
                if let message = item.commit.message {
                    Text(message).font(.caption).lineLimit(1)
                }
                if item.predatesSplit {
                    Text("predates a split")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                Spacer()
                Text(String(item.commit.text.prefix(60)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Button("Restore") { model.restore(item) }
                    .controlSize(.small)
                    .disabled(model.header?.locked == true)
            }
        }
    }
}
