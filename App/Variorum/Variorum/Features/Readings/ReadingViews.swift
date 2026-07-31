//
//  ReadingViews.swift
//  Variorum
//
//  The readings faces (Phase 10 Step 6): curated membership management and
//  the smart-spec editor surfacing the v1 vocabulary plainly. Functional,
//  unstyled; both sheets are presented by the SHELF since Phase 13's IA
//  rework (Shelf · Library · Pool · Blocks).
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
                    Text("Ordered by the reading's sort — manual reorder applies in Manual order.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ForEach(Array(members.enumerated()), id: \.element.postID) { i, entry in
                    HStack {
                        Text(entry.title?.isEmpty == false ? entry.title! : "Untitled")
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
                    Button(item.title?.isEmpty == false ? item.title! : "Untitled") {
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
                    .foregroundStyle(.red)
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

/// The v1 smart vocabulary, plainly: profile, entry-date range, ANY-of
/// tags with subtree semantics (AND across fields).
struct SmartSpecSheet: View {
    let session: AppSession
    let model: ReadingsViewModel
    let reading: Reading
    @State private var profile = ""
    @State private var dateFrom = ""
    @State private var dateTo = ""
    @State private var selectedTagPaths: Set<String> = []
    @State private var allTags: [Tag] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter for “\(reading.name)”").font(.headline)
            Text("Notes must match every field; empty fields don't constrain.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Form {
                TextField("Profile (journal, blog, book_chapter, generic)", text: $profile)
                TextField("Entry date from (yyyy-MM-dd)", text: $dateFrom)
                TextField("Entry date to (yyyy-MM-dd)", text: $dateTo)
            }
            if !allTags.isEmpty {
                Text("Tagged any of (subtree matches):").font(.caption)
                List(allTags, id: \.id) { tag in
                    Toggle(
                        tag.path,
                        isOn: Binding(
                            get: { selectedTagPaths.contains(tag.path) },
                            set: { on in
                                if on {
                                    selectedTagPaths.insert(tag.path)
                                } else {
                                    selectedTagPaths.remove(tag.path)
                                }
                            }))
                }
                .frame(minHeight: 120)
            }
            HStack {
                Button("Clear Filter") {
                    Task {
                        await model.setSmartSpec(reading.id, spec: nil)
                        dismiss()
                    }
                }
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    Task {
                        await model.setSmartSpec(reading.id, spec: builtSpec())
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 420)
        .task { await load() }
    }

    /// The UI's fields become exactly the v1 vocabulary — nothing else.
    private func builtSpec() -> Queries.SmartQuerySpec {
        Queries.SmartQuerySpec(
            tags: selectedTagPaths.isEmpty ? nil : selectedTagPaths.sorted(),
            profile: profile.isEmpty ? nil : profile,
            entryDateFrom: dateFrom.isEmpty ? nil : dateFrom,
            entryDateTo: dateTo.isEmpty ? nil : dateTo)
    }

    private func load() async {
        allTags = (try? await session.database.read { try Queries.allTags($0) }) ?? []
        // Seed the fields from the stored spec (round-trip honesty).
        if let json = reading.querySpec,
           let spec = try? JSONDecoder().decode(
               Queries.SmartQuerySpec.self, from: Data(json.utf8)) {
            profile = spec.profile ?? ""
            dateFrom = spec.entryDateFrom ?? ""
            dateTo = spec.entryDateTo ?? ""
            selectedTagPaths = Set(spec.tags ?? [])
        }
    }
}
