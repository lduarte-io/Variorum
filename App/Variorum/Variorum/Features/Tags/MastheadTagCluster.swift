//
//  MastheadTagCluster.swift
//  Variorum (Mac)
//
//  pre-13u Act 10, item 5 — **THE TAGS' NEW HOME.** Her ruling, verbatim:
//  *"I also want the tags moved from where they are in the top bar to being
//  under the scraps / outside reference / tray button - they look cluttered
//  up there in the navigation bar and I think they'd look nicer on the far
//  right, across from what books an item is in."*
//
//  So the note's tag cards sit in the MASTHEAD's right edge, directly under
//  the tray/scraps/references icon cluster, across from the membership chip
//  — one coherent right edge (designed together with item 10's panel work,
//  per the act's own instruction). This SUPERSEDES 13k K12's placement (the
//  cards on the context bar) in part; everything else about the cards is
//  the standing machinery, unmoved:
//
//    · the cards themselves are `NoteTagChips` (13g R6-1's grammar);
//    · the fold is `TagChipsFold` — the same sticky preference, so ⌘⇧I and
//      the ＃ door here move every window's cluster at once (K12's letter);
//    · applying types through `TagAssignmentViewModel.applyTypedPath` (the
//      one type-to-create door), removing through the standing op;
//    · loading is the one-shot discipline (`PaneHost`'s reason: a held
//      observation on `post_tag` would re-read at write rate).
//
//  **The add door reads "＋ tag" here** — her delegated call ("maybe
//  instead of just a + it should have like + tag or something so it's
//  clear"), judged in place: the masthead's right edge has the room, and a
//  labeled door beats a bare glyph where nothing crowds it (the generous-
//  buttons doctrine). The Library rows keep their bare ＋ — a dense listing
//  is exactly the "chrome clutter" her hedge worried about.
//

import SwiftUI
import VariorumCore

struct MastheadTagCluster: View {
    /// The `.surface` acts this cluster renders (P-1's declared ⇔ rendered
    /// walk) — both moved here WITH the cards from the context bar.
    static let surfaceCapabilities: [CapabilityID] = [.tagNote, .toggleTagChips]

    let session: AppSession
    let postID: String
    let tokens: VoiceTokens

    @State private var tags: [Tag] = []
    @State private var allTags: [Tag] = []
    /// K12 — the same sticky fold every bar read; one preference, every
    /// window (and ⌘⇧I) moves this cluster too.
    @AppStorage(TagChipsFold.settingKey) private var folded = TagChipsFold.defaultFolded

    var body: some View {
        HStack(spacing: 5) {
            if !folded {
                NoteTagChips(
                    tokens: tokens, tags: tags, allTags: allTags,
                    onApply: { apply($0) },
                    onRemove: { remove($0) },
                    addLabel: "\u{FF0B} tag")
            }
            foldDoor
        }
        .task(id: postID) { await load() }
    }

    /// The ＃ door — K12's deliberate, sticky fold, at the cards' new
    /// address. Folded it carries the count (the shipped grammar, through
    /// the same pure rule the bar used).
    private var foldDoor: some View {
        Button {
            TagChipsFold.toggle()
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "number")
                if let count = ContextBarDoors.tagsDoorCount(
                    folded: folded, tagCount: tags.count) {
                    Text(tokens.chromeLabel("\(count)"))
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
            }
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .padding(.vertical, 2)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(WorkspaceNaming.tagsFoldHelp(folded: folded))
    }

    // MARK: - The one-shot loads and the standing doors (PaneHost's
    // discipline, moved with the cards)

    private func load() async {
        let read = try? await session.database.read { [postID] db in
            (applied: try Queries.postTags(db, postID: postID),
             all: try Queries.allTags(db))
        }
        tags = read?.applied ?? []
        allTags = read?.all ?? []
    }

    /// Applying a typed path goes through the SHIPPED type-to-create door
    /// (`TagAssignmentViewModel.applyTypedPath`, 13b 3D's N24) — this face
    /// adds no tag semantics of its own.
    private func apply(_ path: String) {
        let model = TagAssignmentViewModel(session: session, postID: postID)
        Task {
            if await model.applyTypedPath(path) == nil, let error = model.lastError {
                session.status.speak(error)
            }
            await load()
        }
    }

    private func remove(_ tag: Tag) {
        Task {
            do {
                try await session.runner.run { ops in
                    try ops.removeTag(tag.id, fromPost: postID)
                }
            } catch {
                session.status.speak(TagsViewModel.message(error))
            }
            await load()
        }
    }
}
