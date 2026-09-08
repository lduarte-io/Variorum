//
//  BlockTagViews.swift
//  Variorum
//
//  Phase 11, Step A8 — the block-tagging faces DEFERRED FROM Phase 10 (the
//  in-phase decision: block tags primarily serve the pool, AppSpec §7):
//  the per-block assignment sheet (TagAssignmentSheet's block twin — every
//  toggle exactly one applyTag/removeTag(toBlock:)) and the pool's tag
//  filter (everythingTagged block semantics, subtree included).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class BlockTagAssignmentViewModel {
    @ObservationIgnored let session: AppSession
    let blockID: String

    init(session: AppSession, blockID: String) {
        self.session = session
        self.blockID = blockID
    }

    private(set) var allTags: [Tag] = []
    private(set) var appliedIDs: Set<String> = []
    private(set) var lastError: String?

    func load() async {
        do {
            let (tags, applied) = try await session.database.read { [blockID] db in
                (try Queries.allTags(db), try Queries.blockTags(db, blockID: blockID))
            }
            allTags = tags
            appliedIDs = Set(applied.map(\.id))
        } catch {
            lastError = String(describing: error)
        }
    }

    func isApplied(_ tagID: String) -> Bool {
        appliedIDs.contains(tagID)
    }

    /// One toggle = exactly one apply/remove op (tombstone, never removal).
    func toggle(_ tagID: String) async {
        lastError = nil
        do {
            if isApplied(tagID) {
                try await session.runner.run { [blockID] ops in
                    try ops.removeTag(tagID, fromBlock: blockID)
                }
            } else {
                try await session.runner.run { [blockID] ops in
                    _ = try ops.applyTag(tagID, toBlock: blockID)
                }
            }
            await load()
        } catch {
            lastError = String(describing: error)
        }
    }
}

struct BlockTagAssignmentSheet: View {
    let session: AppSession
    let blockID: String
    let preview: String?
    @State private var model: BlockTagAssignmentViewModel
    @Environment(\.dismiss) private var dismiss

    init(session: AppSession, blockID: String, preview: String?) {
        self.session = session
        self.blockID = blockID
        self.preview = preview
        _model = State(initialValue: BlockTagAssignmentViewModel(session: session, blockID: blockID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags for block “\(preview?.isEmpty == false ? String(preview!.prefix(48)) : "(empty)")”")
                .font(.headline)
            if model.allTags.isEmpty {
                // 17o batch e (row 39's rider): the sidebar has had no Tags
                // section since R52 moved tag management into Settings — a
                // door that names a room that is not there is worse than no
                // sentence at all. Worded as the Blocks workbench's twin.
                Text("No tags yet — make one in Settings \u{25B8} Tags.")
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
