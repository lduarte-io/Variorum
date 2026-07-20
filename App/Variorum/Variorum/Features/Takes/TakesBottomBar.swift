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
    /// Batch 12 (her "we need a block menu"): the comments/tags sheets the
    /// status line opens.
    @State private var commentsTarget: BlockSheetTarget?
    @State private var tagsShown = false
    @Environment(\.openWindow) private var openWindow
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    struct BlockSheetTarget: Identifiable {
        let id: String
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The block the menu acts on: the pane you're in; on a one-block post,
    /// THE block (her screenshots' case — no click should be needed).
    private var targetSlot: Queries.RenderedBlock? {
        if let pane = model.focusedPane {
            return model.projection.slots.first { $0.blockID == pane.blockID }
        }
        if model.projection.slots.count == 1 { return model.projection.slots.first }
        return nil
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
                Task { await model.branchTake(blockID: slot.blockID, from: from) }
            }
            Button("＋ Blank take (⌥⌘T)") {
                guard let slot = targetSlot else { return speakNoTarget() }
                Task { await model.newBlankTake(blockID: slot.blockID) }
            }
            Button("＋ Blank take, opened as chosen (⇧⌥⌘T)") {
                guard let slot = targetSlot else { return speakNoTarget() }
                Task { await model.newBlankTakeAsChosen(blockID: slot.blockID) }
            }
            Divider()
            Button("Comments…") {
                guard let slot = targetSlot else { return speakNoTarget() }
                commentsTarget = BlockSheetTarget(id: slot.blockID)
            }
            Divider()
            Button("Open in Write") {
                NotificationCenter.default.post(
                    name: .variorumSwitchMode, object: nil,
                    userInfo: ["mode": "Write", "postID": model.postID])
            }
        }
        .help("Everything block-scoped: new takes, comments — acts on the block you're in")
    }

    private func speakNoTarget() {
        model.speak("Click into a block first — the block menu acts on the block you're in.")
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
                    Task { await model.branchTake(blockID: slot.blockID, from: from) }
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

                StatusDot(tokens: tokens)

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
        .sheet(item: $commentsTarget) { target in
            CommentsPanel(session: model.session, blockID: target.id)
        }
        .sheet(isPresented: $tagsShown) {
            TagAssignmentSheet(session: model.session, postID: model.postID, postTitle: nil)
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
