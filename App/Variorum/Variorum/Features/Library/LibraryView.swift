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

    var body: some View {
        List(selection: $selection) {
            ForEach(model.posts, id: \.postID) { item in
                Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                    .tag(item.postID)
            }
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
