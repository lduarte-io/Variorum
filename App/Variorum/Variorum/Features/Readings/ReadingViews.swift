//
//  ReadingViews.swift
//  Variorum
//
//  The readings faces (Phase 10 Step 6): curated membership management.
//  Functional, unstyled; presented by the SHELF since Phase 13's IA rework
//  (Shelf · Library · Pool · Blocks).
//
//  13i-b U3: this file's second sheet — `SmartSpecSheet`, the v1 smart-spec
//  editor — RETIRED with its draft reader (`Queries.legacyDraft`). It
//  collected a rule in the v1 vocabulary (profile, dates, any-of tags), so a
//  v2 rule it could not spell (a star, a not, a nested group) would have
//  been silently dropped on save. Its successor edits the grammar itself:
//  `RuleEditor.swift`.
//
//  13c 2D: the file's `ReadingsSection` — the Phase 10 SIDEBAR section this
//  file was named for — was DELETED here. It had been unreferenced since
//  that IA rework, and its "Sort" submenu was the app's only door onto
//  `setReadingSort`, so the shipped app has had no reachable way to change
//  a book's order at all. That list now lives in `BookOrderChoices` and its
//  door in the book's own navigator (A31).
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

extension Reading: @retroactive Identifiable {}

/// Curated membership: add/remove/reorder — the fractional positions ride
/// the existing op; up/down emits one `reorderReadingPost` each.
struct ManageReadingPostsSheet: View {
    let session: AppSession
    let model: ReadingsViewModel
    let reading: Reading
    @State private var members: [Queries.ReadingEntry] = []
    @State private var candidates: [Queries.TimelineItem] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes in “\(reading.name)”").font(.headline)
            List {
                if reading.sortField != .manual {
                    // Round 1, NIT: reorder writes `position`, which a
                    // stamp-sorted assembly doesn't display — hide the
                    // silent no-op instead of offering it.
                    Text("Ordered by the book's sort — manual reorder applies in Manual order.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ForEach(Array(members.enumerated()), id: \.element.postID) { i, entry in
                    HStack {
                        Text(entry.displayTitle)
                        Spacer()
                        if reading.sortField == .manual {
                            Button("↑") { move(entry.postID, up: true) }
                                .disabled(i == 0)
                            Button("↓") { move(entry.postID, up: false) }
                                .disabled(i == members.count - 1)
                        }
                        Button("Remove") {
                            Task {
                                await model.removePost(entry.postID, from: reading.id)
                                await refresh()
                            }
                        }
                    }
                }
                if members.isEmpty {
                    Text("No notes yet.").foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 180)
            Menu("Add Note…") {
                ForEach(candidates.filter { item in
                    !members.contains { $0.postID == item.postID }
                }, id: \.postID) { item in
                    Button(item.displayTitle) {
                        Task {
                            await model.addPost(item.postID, to: reading.id)
                            await refresh()
                        }
                    }
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .alarmVoice()
                    .textSelection(.enabled)
            }
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 420)
        .task { await refresh() }
    }

    private func move(_ postID: String, up: Bool) {
        Task {
            await model.movePost(postID, in: reading.id, up: up)
            await refresh()
        }
    }

    private func refresh() async {
        members = (try? await session.database.read { [id = reading.id] db in
            try Queries.assembleReading(db, readingID: id)
        }) ?? []
        candidates = (try? await session.database.read { db in
            try Queries.library(db, sort: .lastTouched, direction: .desc, limit: 200)
        }) ?? []
    }
}
