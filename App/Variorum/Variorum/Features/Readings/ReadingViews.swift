//
//  ReadingViews.swift
//  Variorum
//
//  The readings faces (Phase 10 Step 6): the sidebar section (CRUD +
//  sort pickers), curated membership management, and the smart-spec
//  editor surfacing the v1 vocabulary plainly. Functional, unstyled.
//

import SwiftUI
import VariorumCore

/// The sidebar's Readings section; selecting a reading opens the book view.
struct ReadingsSection: View {
    let session: AppSession
    let model: ReadingsViewModel
    @State private var createPresented = false
    @State private var renameTarget: Reading?
    @State private var nameField = ""
    @State private var manageTarget: Reading?
    @State private var smartTarget: Reading?

    var body: some View {
        Section("Readings") {
            ForEach(model.readings, id: \.id) { reading in
                HStack(spacing: 4) {
                    Image(systemName: reading.kind == .smart ? "sparkles" : "book")
                        .foregroundStyle(.secondary)
                    Text(reading.name)
                }
                .tag(SidebarSelection.reading(reading.id))
                .contextMenu { readingMenu(reading) }
            }
            Button("New Reading…") {
                nameField = ""
                createPresented = true
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .alert("New Reading", isPresented: $createPresented) {
            TextField("Name", text: $nameField)
            Button("Create Curated") {
                let name = nameField
                Task { await model.create(name: name.isEmpty ? "Untitled" : name, kind: .curated) }
            }
            Button("Create Smart") {
                let name = nameField
                Task { await model.create(name: name.isEmpty ? "Untitled" : name, kind: .smart) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Curated readings hold a hand-picked, ordered post list; smart readings match a filter.")
        }
        .alert(
            "Rename Reading",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { reading in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task { await model.rename(reading.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $manageTarget) { reading in
            ManageReadingPostsSheet(session: session, model: model, reading: reading)
        }
        .sheet(item: $smartTarget) { reading in
            SmartSpecSheet(session: session, model: model, reading: reading)
        }
    }

    @ViewBuilder
    private func readingMenu(_ reading: Reading) -> some View {
        Button("Rename…") {
            nameField = reading.name
            renameTarget = reading
        }
        if reading.kind == .curated {
            Button("Manage Posts…") { manageTarget = reading }
        } else {
            Button("Edit Filter…") { smartTarget = reading }
        }
        Menu("Sort") {
            ForEach(sortChoices, id: \.label) { choice in
                Button {
                    Task {
                        await model.setSort(
                            reading.id, field: choice.field, direction: choice.direction)
                    }
                } label: {
                    if reading.sortField == choice.field && reading.sortDir == choice.direction {
                        Label(choice.label, systemImage: "checkmark")
                    } else {
                        Text(choice.label)
                    }
                }
            }
        }
        Divider()
        Button("Delete Reading", role: .destructive) {
            Task { await model.delete(reading.id) }
        }
    }

    private var sortChoices: [(label: String, field: SortField, direction: SortDirection)] {
        [
            ("Manual order", .manual, .asc),
            ("Entry date ↑", .entryDate, .asc),
            ("Entry date ↓", .entryDate, .desc),
            ("Created ↑", .createdAt, .asc),
            ("Created ↓", .createdAt, .desc),
            ("Last touched ↓", .lastTouched, .desc),
            ("Major revision ↓", .lastMajorRevision, .desc),
        ]
    }
}

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
            Text("Posts in “\(reading.name)”").font(.headline)
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
                    Text("No posts yet.").foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 180)
            Menu("Add Post…") {
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
            Text("Posts must match every field; empty fields don't constrain.")
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
