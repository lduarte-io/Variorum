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

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            // Batch 9 (R101): the round-2 status-line grammar — quiet
            // voiced words on the room; every door stays.
            HStack(spacing: 10) {
                Text(tokens.chromeLabel(caretLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
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

                StatusDot(tokens: tokens)

                // The post lifecycle faces (Phase 10 Step 8): the seal
                // toggle and Mac-side entry-date editing live with the open
                // post — the editor knows the header state.
                Button(tokens.chromeLabel(model.header?.locked == true ? "unseal" : "seal")) {
                    model.toggleSeal()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens))
                .help("A sealed post is frozen — nothing under it changes until unsealed")
                Button(tokens.chromeLabel("tags…")) { tagsShown = true }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens))
                    .help("The post's tags — apply or remove them right here")
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

                StatusDot(tokens: tokens)

                // The gesture button bar (9d — the fourth door): dimmed by
                // the planner's verdict but ALWAYS clickable — a refused
                // click speaks its refusal instead of going silent.
                gestureButton("Divide", available: model.gestureAvailability.divide,
                              action: model.divideAtCursor)
                gestureButton("Extract", available: model.gestureAvailability.extract,
                              action: model.extractSelection)
                gestureButton("Make Block", available: model.gestureAvailability.makeBlock,
                              action: model.makeBlockFromSelection)
                gestureButton("Merge", available: model.gestureAvailability.merge,
                              action: model.mergeBlocks)
                gestureButton("Takes", available: model.gestureAvailability.takes,
                              action: model.openCaretFan)

                Spacer()
                if let status = model.statusMessage {
                    // Sitting 9 (R93): refusals must be READABLE — two
                    // lines, wrapping, selectable; never "That span is t…".
                    Text(status)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(2)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 460, alignment: .trailing)
                        .help(status)
                }
                if let words = wordCountLabel {
                    // R11: word-count PROMINENCE — the accent-colored,
                    // always-there part of the editing surface.
                    Text(tokens.chromeLabel(words))
                        .font(tokens.small.weight(.semibold))
                        .foregroundStyle(tokens.accent)
                        .fixedSize()
                        .help("Word counts: the block you're in · your selection · the whole post")
                }
                // Sitting 9 (R73/R91): hover = the cheat sheet; click =
                // the full helper with the dictionary.
                Button("?") { openWindow(id: "variorum-helper") }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(HelperCheatSheet.summary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tokens.room)
            if model.commitList != nil {
                CommitHistoryView(model: model)
                    .frame(maxHeight: 180)
            }
        }
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
            parts.append("\(total.formatted())w in post")
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
