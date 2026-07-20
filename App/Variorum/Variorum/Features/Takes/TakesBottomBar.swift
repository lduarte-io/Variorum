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
    @Environment(\.openWindow) private var openWindow
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            // Batch 9 (R101): the round-2 status-line grammar — quiet
            // voiced words on the room, never a bezel row. Every door
            // stays (R63); only the register changes.
            HStack(spacing: 10) {
                Text(tokens.chromeLabel(contextLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Button(tokens.chromeLabel("commit ⌘S")) {
                    Task { await model.commitFocusedTake() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .disabled(model.projection.sealed)
                .help("An immutable savepoint of the take you're in")
                Button(tokens.chromeLabel("history")) { Task { await openHistory() } }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens))
                    .help("The focused take's savepoints — restore any of them")

                StatusDot(tokens: tokens)

                Button(tokens.chromeLabel(model.projection.sealed ? "unseal" : "seal")) {
                    Task { await model.toggleSeal() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens))
                .help("A sealed post is frozen — nothing under it changes until unsealed")
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

                StatusDot(tokens: tokens)

                // The structural gestures, present and SPEAKING (R63 +
                // the 9d posture): they need Write's text selection.
                ForEach(["Divide", "Extract", "Make Block", "Merge"], id: \.self) { name in
                    Button(tokens.chromeLabel(name)) {
                        model.speakStructuralGesturesLiveInWrite(gesture: name)
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .opacity(0.6)
                }

                Spacer()
                if let words = wordCountLabel {
                    Text(tokens.chromeLabel(words))
                        .font(tokens.small.weight(.semibold))
                        .foregroundStyle(tokens.accent)
                        .fixedSize()
                }
                Button("?") { openWindow(id: "variorum-helper") }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(HelperCheatSheet.summary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tokens.room)
        }
        .sheet(isPresented: $historyShown) {
            historySheet
        }
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
            parts.append("\(TextMetrics.wordCount(resolved.text))w take")
        }
        let total = model.projection.slots.reduce(0) { $0 + TextMetrics.wordCount($1.text ?? "") }
        parts.append("\(total.formatted())w post")
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
