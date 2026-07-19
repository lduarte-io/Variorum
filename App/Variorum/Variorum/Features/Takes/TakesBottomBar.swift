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
            HStack(spacing: 12) {
                Text(tokens.chromeLabel(contextLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Button("Commit (⌘S)") { Task { await model.commitFocusedTake() } }
                    .disabled(model.projection.sealed)
                    .help("An immutable savepoint of the take you're in")
                Button("History") { Task { await openHistory() } }
                    .help("The focused take's savepoints — restore any of them")

                Divider().frame(height: 14)

                Button(model.projection.sealed ? "Unseal" : "Seal") {
                    Task { await model.toggleSeal() }
                }
                .controlSize(.small)
                Button(model.projection.entryDate.map { "Date: \($0)" } ?? "Set Date…") {
                    pickedDate = CommitBar.date(fromDay: model.projection.entryDate) ?? Date()
                    datePickerShown = true
                }
                .controlSize(.small)
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

                Divider().frame(height: 14)

                // The structural gestures, present and SPEAKING (R63 +
                // the 9d posture): they need Write's text selection.
                ForEach(["Divide", "Extract", "Make Block", "Merge"], id: \.self) { name in
                    Button(name) {
                        model.speakStructuralGesturesLiveInWrite(gesture: name)
                    }
                    .controlSize(.small)
                    .opacity(0.45)
                }

                Spacer()
                if let words = wordCountLabel {
                    Text(tokens.chromeLabel(words))
                        .font(tokens.small.weight(.semibold))
                        .foregroundStyle(tokens.accent)
                        .fixedSize()
                }
                Button("?") { openWindow(id: "variorum-helper") }
                    .controlSize(.small)
                    .help(HelperCheatSheet.summary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tokens.surface)
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
