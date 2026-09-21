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

/// The block-tag sheet's own words (17o batch e, row 39's rider — named so
/// a pin can hold them: the empty state pointed at *"the sidebar's Tags
/// section"*, a room gone since R52 moved tag management into Settings).
nonisolated enum BlockTagCopy {
    static let noTagsYet = "No tags yet \u{2014} make one in Settings \u{25B8} Tags."

    /// **The subject's word, per surface** (13u4 UNIT S3 — KnownIssues row
    /// 45's second half). The sheet is shared by three renderers and its
    /// title said *"block"* on all of them, including the two that speak
    /// SNIPPETS (the K5 vocabulary ruling: the scraps area's UI word is
    /// "snippet"). It is a per-call noun now — one parameter, which is the
    /// bar the brief set for changing it at all.
    ///
    /// The CANVAS keeps the default deliberately: it is opened on a note OR
    /// on the scraps area (`containerID` is either kind) and holds no fact
    /// that says which, so a word chosen there would be right half the time.
    /// PROVISIONAL, QUESTIONS #133.
    static let blockNoun = "block"
    static let snippetNoun = "snippet"

    static func title(noun: String, preview: String?) -> String {
        let subject = preview?.isEmpty == false
            ? String(preview!.prefix(48))
            : "(empty)"
        return "tags for this \(noun) \u{2014} \u{201C}\(subject)\u{201D}"
    }
}

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

/// **The block-tag sheet, in the app's own voice** (13u4 UNIT S3 —
/// KnownIssues row 45). It rendered in system chrome (`.headline`, a `List`
/// of `Toggle`s, no `VoiceTokens` anywhere), so it looked identical in both
/// voices while everything around it changed — and three surfaces render it,
/// which is what made one unvoiced sheet visible three times.
///
/// **Nothing about what it DOES moved:** one row still equals exactly one
/// `applyTag`/`removeTag`, the model is byte-untouched, and the empty
/// state's sentence is the one 17o batch e wrote. What changed is the type,
/// the inks, and the row grammar — the reference artifact's `.a-row`
/// (a calm hover/selected wash on a rounded row, never a hairline list) and
/// its `.btn.primary` for the one door out.
///
/// The ✓ is this app's own marker for *chosen* (the take cards' "✓ chosen"),
/// which is why the toggle became a row: a system checkbox is the one
/// control in here that could not wear the voice. The accessibility value
/// says on/off out loud so nothing is lost with the checkbox.
struct BlockTagAssignmentSheet: View {
    let session: AppSession
    let blockID: String
    let preview: String?
    /// The subject's word — see `BlockTagCopy.blockNoun`.
    var noun: String = BlockTagCopy.blockNoun
    @State private var model: BlockTagAssignmentViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, blockID: String, preview: String?,
        noun: String = BlockTagCopy.blockNoun
    ) {
        self.session = session
        self.blockID = blockID
        self.preview = preview
        self.noun = noun
        _model = State(initialValue: BlockTagAssignmentViewModel(session: session, blockID: blockID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // NOT `chromeLabel`: this line quotes HER text, and a voice's
            // chrome-case would lowercase words she typed. The label's own
            // half is authored lowercase, so the two voices read the same
            // here either way — which is what made the wrapper look free.
            Text(BlockTagCopy.title(noun: noun, preview: preview))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
            if model.allTags.isEmpty {
                // 17o batch e (row 39's rider): the sidebar has had no Tags
                // section since R52 moved tag management into Settings — a
                // door that names a room that is not there is worse than no
                // sentence at all. Worded as the Blocks workbench's twin.
                Text(tokens.chromeLabel(BlockTagCopy.noTagsYet))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(model.allTags, id: \.id) { tag in
                        tagRow(tag)
                    }
                }
                .padding(4)
            }
            .frame(minHeight: 200)
            .background(tokens.surface, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("done")) { dismiss() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 340)
        .background(tokens.room)
        .task { await model.load() }
    }

    /// The reference artifact's `.a-row`: a calm rounded row with the wash
    /// under the applied one, never a list hairline.
    private func tagRow(_ tag: Tag) -> some View {
        Button {
            Task { await model.toggle(tag.id) }
        } label: {
            HStack(spacing: 8) {
                Text(model.isApplied(tag.id) ? "\u{2713}" : " ")
                    .font(tokens.small)
                    .foregroundStyle(tokens.chosen)
                    .frame(width: 12, alignment: .leading)
                Text(tag.path)
                    .font(tokens.body)
                    .foregroundStyle(model.isApplied(tag.id) ? tokens.ink : tokens.muted)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                model.isApplied(tag.id) ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                in: RoundedRectangle(cornerRadius: 7))
            .contentShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tag.path)
        .accessibilityValue(model.isApplied(tag.id) ? "on" : "off")
    }
}
