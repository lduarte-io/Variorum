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
            .showNoteTray,  // 13j J2: the note ▾ menu's tray door
        ]
        // 13k K7: the formatting toolbar's own eight, from ITS table (the
        // cluster is rendered here, so its doors are declared here).
        + FormatBar.renderedCapabilities
    }

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
                if barWidth > 0, barWidth < 1080 {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 10) {
                            identityCluster
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
            if model.commitList != nil {
                CommitHistoryView(model: model)
                    .frame(maxHeight: 180)
            }
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
            Button("− Delete this block") {
                Task { await model.deleteCaretBlock() }
            }
        }
        .help("Everything block-scoped: divide, extract, make block, merge, and the two block mints")
    }

    /// The flat row's note half: `note ▾`, comments, the newlines chip — and
    /// (13k K7) the formatting toolbar, which sits with them because it acts
    /// on the text of the note you are writing.
    @ViewBuilder private var postCluster: some View {
        noteMenu
        Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The caret block's comments — working remarks on a block, never per-take")
        // 13b 4D (N34 — S4-14/S4-21): the one_block face's Write half — an
        // in-view setting chip over the Phase-1 machinery; the header
        // observation keeps `effectiveSegmentation` (and this chip) live.
        newlinesChip
        StatusDot(tokens: tokens)
        FormatBar(tokens: tokens, status: model.session.status)
    }

    /// **note ▾** (R6-2): history, the seal, the entry date. The date
    /// picker's popover is anchored on the MENU rather than on a row —
    /// a menu item cannot host one.
    private var noteMenu: some View {
        VoicedMenu(tokens: tokens, label: "note") {
            Button(model.commitList == nil ? "History" : "Hide history") {
                model.toggleCommitHistory()
            }
            .disabled(model.caretVariantID == nil && model.commitList == nil)
            Button(model.header?.locked == true ? "Unseal" : "Seal") {
                model.toggleSeal()
            }
            Divider()
            // 13j J2: the tray's NAMED door. The context bar's ⌫ badge is
            // the glance; this is the one that is always there, and it is
            // where someone who has never seen the badge will look.
            Button("\(TrayPath.menuLabel)\u{2026}") { model.requestNoteTray() }
            Divider()
            Button(model.header?.entryDate.map { "Date: \($0)…" } ?? "Set date…") {
                pickedDate = Self.date(fromDay: model.header?.entryDate) ?? Date()
                datePickerShown = true
            }
        }
        .help("The note itself: its savepoints, its seal, its tray, its date")
        .popover(isPresented: $datePickerShown, content: datePickerPopover)
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
