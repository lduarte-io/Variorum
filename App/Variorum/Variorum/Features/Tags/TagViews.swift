//
//  TagViews.swift
//  Variorum
//
//  The tag faces (Phase 10 Step 5): the per-post assignment sheet.
//
//  The file's `TagListSection` — the Phase 10 SIDEBAR taxonomy section —
//  was left unreferenced by Phase 13's IA rework (Shelf · Library · Pool ·
//  Blocks) and deleted at the 13c K6 review (K5), the `ReadingsSection`
//  class exactly: dead code, with NO capability stranded — tag
//  create/rename/delete live in Settings (`AppSettingsView`, R52's home).
//

import SwiftUI
import VariorumCore

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

    /// 13b Stage 3, 3D (N24): the type-to-create field's buffer.
    @State private var typedTag = ""
    @FocusState private var typedFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags for “\(postTitle?.isEmpty == false ? postTitle! : DisplayTitle.placeholder)”")
                .font(.headline)
            // N24 — her words: "freely type tags in to a book, not just
            // select from already created tags." ⏎ applies; missing tags
            // (each “/” level) are created on the way; an existing path
            // just applies.
            TextField(
                "type a tag — ⏎ applies it (new tags are created; “/” nests: life/goals)",
                text: $typedTag)
                .textFieldStyle(.roundedBorder)
                .focused($typedFocused)
                .onSubmit {
                    let raw = typedTag
                    Task {
                        if await model.applyTypedPath(raw) != nil {
                            typedTag = ""
                        }
                        typedFocused = true
                    }
                }
            if model.allTags.isEmpty {
                Text("No tags yet — type one above, or manage the taxonomy in Settings (⌘,).")
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
        .frame(minWidth: 340)
        .task { await model.load() }
    }
}
