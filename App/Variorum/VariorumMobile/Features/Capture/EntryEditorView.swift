//
//  EntryEditorView.swift
//  VariorumMobile
//
//  Phase 8, Step 3 — the capture editor: one live TextEditor for the
//  focused block; every other block renders read-cheap and focuses on tap
//  (P3 at phone scale). No fan chrome, no structural gestures — pillar 8's
//  narrow surface is the design, not a compromise. Functional and unstyled.
//

import SwiftUI
import VariorumCore

struct EntryEditorView: View {
    @State private var model: EntryEditorViewModel

    init(session: AppSession, postID: String) {
        _model = State(initialValue: EntryEditorViewModel(session: session, postID: postID))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if model.isSealed {
                    Text("This post is locked — reading only.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                if let error = model.lastError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                if model.isJournal {
                    entryDateRow
                }
                blocks
            }
            .padding()
        }
        .navigationTitle(model.entryDate ?? "Post")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.loadOnce() }
        .task { await model.start() }
        .onDisappear {
            let model = model
            Task { await model.finish() }
        }
    }

    /// The user-set calendar day (author 2026-07-07): default today-local,
    /// any day allowed, past or future; `created_at` never moves.
    private var entryDateRow: some View {
        DatePicker(
            "Entry day",
            selection: Binding(
                get: { model.entryDate.flatMap(Self.date(fromDay:)) ?? Date() },
                set: { model.setEntryDate(Self.day(from: $0)) }),
            displayedComponents: .date)
        .font(.caption)
        .disabled(false) // library metadata stays editable under the seal
    }

    @ViewBuilder
    private var blocks: some View {
        if model.slots.isEmpty {
            // The empty entry: the first keystroke mints THE block.
            if model.isSealed {
                Text("Empty.").foregroundStyle(.secondary)
            } else {
                editor
            }
        } else {
            ForEach(model.slots, id: \.placementID) { slot in
                if slot.isGap {
                    // A referenced-but-not-yet-arrived row (SyncSpec §5):
                    // render a gap, never crash.
                    Text("…").foregroundStyle(.tertiary)
                } else if slot.variantID == model.focusedVariantID {
                    editor
                } else {
                    Text(slot.text ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture { model.focus(slot) }
                }
            }
        }
    }

    private var editor: some View {
        TextEditor(text: Binding(
            get: { model.draftText },
            set: { model.setDraft($0) }))
            .frame(minHeight: 160)
            .disabled(model.isSealed)
    }

    // MARK: - Day ↔ Date conversion for the picker (local calendar)

    static func date(fromDay day: String) -> Date? {
        let parts = day.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        components.hour = 12
        return Calendar.current.date(from: components)
    }

    static func day(from date: Date) -> String {
        JournalDay.dayString(from: date, calendar: .current)
    }
}
