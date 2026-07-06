//
//  EditorView.swift
//  Variorum
//
//  Placeholder (Phase 7 Step 1); the TK2 editor lands in Step 2.
//

import SwiftUI
import VariorumCore

struct EditorView: View {
    let session: AppSession
    let postID: String

    var body: some View {
        Text("Editor (Step 2) — post \(postID)")
            .foregroundStyle(.secondary)
    }
}
