//
//  SidebarView.swift
//  Variorum
//
//  The shell's sidebar (Phase 10 Step 5 — grown per step): Journal (the
//  dated home — the author's binding 9c-sitting expectation), the flat
//  Library, and the Tags taxonomy. Selection routes through the parent's
//  SidebarSelection — cross-feature interaction lives in composition,
//  never feature-to-feature. Functional, unstyled.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

/// What the sidebar can select; the detail pane switches on it.
enum SidebarSelection: Hashable {
    case post(String)
    case tag(String)
    case reading(String)
    case timeline
    /// A pool container, opened in the detail editor (a pool renders and
    /// edits like a post — one container table, one traversal).
    case pool(String)
    /// The archived + deleted recovery surfaces.
    case recovery
    /// The modes tutorial (Phase 11, A10 — the author's spike-round-6
    /// instruction): a seeded, deletable demo walkthrough.
    case tutorial
}

struct SidebarView: View {
    let session: AppSession
    let model: LibraryViewModel
    let tags: TagsViewModel
    let readings: ReadingsViewModel
    let pool: PoolViewModel
    @Binding var selection: SidebarSelection?
    @State private var renameTarget: RenameTarget?
    @State private var renameTitle = ""
    @State private var tagSheetTarget: TagSheetTarget?
    /// Phase 11b (B1): the last export gesture's report or error — the
    /// export model itself is per-gesture (one-shot projections).
    @State private var exportStatus: String?
    /// Phase 11b (B2): the drop-in import model, created on first drop
    /// (its async provider loads need a live owner; observable status).
    @State private var importer: ImportModel?

    private struct RenameTarget: Identifiable {
        let id: String
    }

    struct TagSheetTarget: Identifiable {
        let id: String
        let title: String?
    }

    var body: some View {
        List(selection: $selection) {
            Section("Views") {
                Label("Timeline", systemImage: "calendar.day.timeline.left")
                    .tag(SidebarSelection.timeline)
                Label("Archived & Deleted", systemImage: "archivebox")
                    .tag(SidebarSelection.recovery)
                Label("Modes Tutorial", systemImage: "graduationcap")
                    .tag(SidebarSelection.tutorial)
            }
            Section("Journal") {
                ForEach(model.journal, id: \.postID) { item in
                    HStack(spacing: 6) {
                        Text(item.entryDate ?? "undated")
                        if let title = item.title, !title.isEmpty {
                            Text(title)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .tag(SidebarSelection.post(item.postID))
                    .contextMenu { postMenu(item) }
                }
                Button("Today's Entry") {
                    Task {
                        if let id = await model.openJournalEntry() {
                            selection = .post(id)
                        }
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
            Section("Library") {
                ForEach(model.posts, id: \.postID) { item in
                    Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                        .tag(SidebarSelection.post(item.postID))
                        .contextMenu { postMenu(item) }
                }
            }
            ReadingsSection(session: session, model: readings)
            TagListSection(model: tags)
            PoolSection(session: session, model: pool) { poolID in
                selection = .pool(poolID)
            }
        }
        // The library import door (Phase 11b, B2): drop `.md`/plain text
        // anywhere on the sidebar → new post(s). The pool's rows carry
        // their own, deeper drop target (deepest target wins), so a drop
        // ON the pool lands as scraps instead.
        .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
            let model = importer ?? ImportModel(session: session)
            importer = model
            return model.handleDrop(providers, into: .library)
        }
        .alert(
            "Rename Post",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { target in
            TextField("Title", text: $renameTitle)
            Button("Rename") {
                let title = renameTitle
                Task { await model.rename(postID: target.id, title: title) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $tagSheetTarget) { target in
            TagAssignmentSheet(session: session, postID: target.id, postTitle: target.title)
        }
        .toolbar {
            ToolbarItem {
                Button("New Post", systemImage: "square.and.pencil") {
                    Task {
                        if let id = await model.createPost() {
                            selection = .post(id)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? tags.lastError ?? importer?.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            } else if let status = exportStatus ?? importer?.lastReport {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    // MARK: - Export doors (Phase 11b, B1 — one-way projections)

    /// Post export: save panel first (the author-visible moment), then the
    /// projection reads and writes. All shapes live in Queries — no join or
    /// section is decided here.
    private func exportPost(_ item: Queries.TimelineItem, includeVariants: Bool) {
        let name = defaultFileName(item)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).md", type: .markdownFile) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let markdown = await exporter.markdown(
                forPost: item.postID, includeVariants: includeVariants) {
                exporter.writeMarkdown(markdown, to: url)
            }
            exportStatus = exporter.lastError ?? exporter.lastReport
        }
    }

    private func exportPostPDF(_ item: Queries.TimelineItem) {
        let name = defaultFileName(item)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).pdf", type: .pdf) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let data = await exporter.pdfData(forPost: item.postID) {
                exporter.writePDF(data, to: url)
            }
            exportStatus = exporter.lastError ?? exporter.lastReport
        }
    }

    private func defaultFileName(_ item: Queries.TimelineItem) -> String {
        let title = Queries.sanitizedFilename(item.title ?? "")
        if !title.isEmpty { return title }
        if let day = item.entryDate, !day.isEmpty { return day }
        return "Untitled"
    }

    /// The shared per-post context menu (journal and library rows alike —
    /// one object type, two lenses).
    @ViewBuilder
    private func postMenu(_ item: Queries.TimelineItem) -> some View {
        Button("Rename…") {
            renameTitle = item.title ?? ""
            renameTarget = RenameTarget(id: item.postID)
        }
        Button("Tags…") {
            tagSheetTarget = TagSheetTarget(id: item.postID, title: item.title)
        }
        Divider()
        // version_of DOOR 1 (Phase 11, A2 — brief item 2): pick the pair in
        // the library; the submenu is the "select two posts" gesture's
        // shape here (one shared context menu; the same operation door 2
        // emits — pinned).
        Menu("Mark as Versions with") {
            ForEach(model.posts.filter { $0.postID != item.postID }, id: \.postID) { other in
                Button(other.title?.isEmpty == false ? other.title! : "Untitled") {
                    Task { await model.markAsVersions(item.postID, other.postID) }
                }
            }
        }
        Button("Duplicate as Version") {
            Task { await model.duplicateAsVersion(postID: item.postID) }
        }
        Divider()
        // Export doors (Phase 11b, B1 — the ratified shapes; one-way
        // projections, the save panel is the author-visible moment).
        Menu("Export") {
            Button("Markdown…") { exportPost(item, includeVariants: false) }
            Button("Markdown with Takes…") { exportPost(item, includeVariants: true) }
            Button("PDF…") { exportPostPDF(item) }
        }
        Divider()
        // The lifecycle faces (Step 8): archive is kept-out-of-view; delete
        // is a tombstone — both recoverable in Archived & Deleted.
        Button("Archive") {
            Task {
                await model.archive(postID: item.postID)
                if selection == .post(item.postID) { selection = nil }
            }
        }
        Button("Delete", role: .destructive) {
            Task {
                await model.delete(postID: item.postID)
                if selection == .post(item.postID) { selection = nil }
            }
        }
    }
}
