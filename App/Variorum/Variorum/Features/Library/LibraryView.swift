//
//  LibraryView.swift
//  Variorum
//
//  Minimal post list + create (Phase 7 Step 1). Functional, unstyled.
//

import SwiftUI
import VariorumCore

struct LibraryView: View {
    let model: LibraryViewModel
    @Binding var selection: String?
    @State private var renameTarget: RenameTarget?
    @State private var renameTitle = ""

    private struct RenameTarget: Identifiable {
        let id: String
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(model.posts, id: \.postID) { item in
                Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                    .tag(item.postID)
                    .contextMenu {
                        Button("Rename…") {
                            renameTitle = item.title ?? ""
                            renameTarget = RenameTarget(id: item.postID)
                        }
                    }
            }
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
        .toolbar {
            ToolbarItem {
                Button("New Post", systemImage: "square.and.pencil") {
                    Task {
                        if let id = await model.createPost() {
                            selection = id
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }
}
