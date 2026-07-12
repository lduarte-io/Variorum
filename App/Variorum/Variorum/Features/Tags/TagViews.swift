//
//  TagViews.swift
//  Variorum
//
//  The tag faces (Phase 10 Step 5): the sidebar's taxonomy section
//  (create/rename/delete — `renameTag`'s subtree rewrite gets its first
//  face) and the per-post assignment sheet. Functional, unstyled.
//

import SwiftUI
import VariorumCore

/// The sidebar's Tags section: the live taxonomy as an indented tree;
/// selecting a tag opens the folder view for its subtree.
struct TagListSection: View {
    let model: TagsViewModel
    /// (parentID, parentPath) for the create sheet; nil parent = root tag.
    @State private var createUnder: TagCreateTarget?
    @State private var renameTarget: Tag?
    @State private var nameField = ""

    struct TagCreateTarget: Identifiable {
        let parentID: String?
        let parentPath: String?
        var id: String { parentID ?? "(root)" }
    }

    var body: some View {
        Section("Tags") {
            ForEach(model.tags, id: \.id) { tag in
                HStack(spacing: 4) {
                    Text(tag.name)
                        .padding(.leading, CGFloat(model.depth(of: tag)) * 12)
                }
                .tag(SidebarSelection.tag(tag.id))
                .contextMenu {
                    Button("New Tag Inside “\(tag.name)”") {
                        nameField = ""
                        createUnder = TagCreateTarget(parentID: tag.id, parentPath: tag.path)
                    }
                    Button("Rename…") {
                        nameField = tag.name
                        renameTarget = tag
                    }
                    Button("Delete Tag (and subtree)", role: .destructive) {
                        Task { await model.deleteTag(tag.id) }
                    }
                }
            }
            Button("New Tag…") {
                nameField = ""
                createUnder = TagCreateTarget(parentID: nil, parentPath: nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .alert(
            "New Tag",
            isPresented: Binding(
                get: { createUnder != nil },
                set: { if !$0 { createUnder = nil } }),
            presenting: createUnder
        ) { target in
            TextField("Name", text: $nameField)
            Button("Create") {
                let name = nameField
                Task { await model.createTag(parentID: target.parentID, name: name) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { target in
            Text(target.parentPath.map { "Inside “\($0)”." } ?? "A root tag.")
        }
        .alert(
            "Rename Tag",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { tag in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task { await model.renameTag(tag.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { tag in
            Text("Renames “\(tag.path)” and every tag beneath it.")
        }
    }
}

/// The per-post tag editor: toggle rows, each toggle exactly one
/// apply/remove operation.
struct TagAssignmentSheet: View {
    let session: AppSession
    let postID: String
    let postTitle: String?
    @State private var model: TagAssignmentViewModel
    @Environment(\.dismiss) private var dismiss

    init(session: AppSession, postID: String, postTitle: String?) {
        self.session = session
        self.postID = postID
        self.postTitle = postTitle
        _model = State(initialValue: TagAssignmentViewModel(session: session, postID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags for “\(postTitle?.isEmpty == false ? postTitle! : "Untitled")”")
                .font(.headline)
            if model.allTags.isEmpty {
                Text("No tags yet — create one in the sidebar's Tags section.")
                    .foregroundStyle(.secondary)
            }
            List(model.allTags, id: \.id) { tag in
                Toggle(
                    isOn: Binding(
                        get: { model.isApplied(tag.id) },
                        set: { _ in Task { await model.toggle(tag.id) } })
                ) {
                    Text(tag.path)
                }
            }
            .frame(minHeight: 200)
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
        .frame(minWidth: 340)
        .task { await model.load() }
    }
}
