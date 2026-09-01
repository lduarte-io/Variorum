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
//  — one coherent right edge. The cards are `NoteTagChips` (13g R6-1's
//  grammar); applying types through `TagAssignmentViewModel.applyTypedPath`
//  (the one type-to-create door), removing through the standing op; loading
//  is the one-shot discipline (a held observation on `post_tag` would
//  re-read at write rate).
//
//  ── THE ACT 10 CORRECTION ROUND, BATCH A (row 15) — ONE DOOR ────────────
//  Act 10 shipped TWO doors for one act side by side: a "＋ tag" that opened
//  a popover field, and the ＃ glyph that FOLDED the cards (13k K12's sticky
//  fold, moved here with them). Her words: *"showing a tag icon and a + tag
//  at the same time … that's just sloppy"*; her shape: *"clicking on the tag
//  button … could slide out a neat 'tag creator' field where your cursor is
//  already active."* So:
//
//    · the ＃ is THE door — click it and the tag field slides out INLINE
//      beside the cards with the cursor in it (⏎ applies, "/" nests,
//      suggestions from the live taxonomy, ⎋ or a second ＃ puts it away);
//    · "＋ tag" retired;
//    · **the masthead FOLD retired — K12's fold is SUPERSEDED here.** It
//      served the crowded context bar ("tag cards should fold into the bar
//      if you deliberately choose that"); the masthead's right edge is not
//      crowded, the cards are the note's quiet fact, and a door that hides
//      what the other door adds is the confusion C-6's one-door rule exists
//      to kill. The chips stay visible.
//    · ⌘⇧I (the fold's key) is RE-POINTED at the field: `.tagNote` carries
//      the chord and its menu/palette doors; `.toggleTagChips` is gone.
//
//  The field is `TagInlineField` — the popover's brain (`TagChipAdder`'s
//  pure `suggestions`) in an inline body.
//

import SwiftUI
import VariorumCore

struct MastheadTagCluster: View {
    /// The `.surface` act this cluster renders (P-1's declared ⇔ rendered
    /// walk): ONE — tagging the note. (`.toggleTagChips` retired with the
    /// fold, the correction round's row 15.)
    static let surfaceCapabilities: [CapabilityID] = [.tagNote]
    /// The cards render WITHOUT their own ＋ here — the ＃ is the cluster's
    /// one door (row 15). A static, so the one-door claim is a fact a pin
    /// reads rather than a modifier it would have to find.
    static let chipsShowAddDoor = false

    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    /// Whether the inline field is out. A BINDING, owned by the detail, so
    /// ⌘⇧I (routed to the detail through the command router) and the ＃
    /// open the same field.
    @Binding var fieldOpen: Bool
    /// Row 58's DEBUG geometry oracle: the named coordinate space the
    /// cards' and the field's frames are reported in (the masthead passes
    /// its own; nil — a standalone host — probes nothing).
    var geometryProbeSpace: String? = nil

    @State private var tags: [Tag] = []
    @State private var allTags: [Tag] = []

    /// The gap between the open field's right edge and what it slid out
    /// beside (the ＃'s line).
    static let fieldGap: CGFloat = 6
    /// Row 58: what every line of the flow keeps FREE at its left — the
    /// field's width plus its gap — so the field slides out beside
    /// whichever line holds the ＃ without reaching what sits left of the
    /// cluster (the path chip). Reserved always, open or closed: opening
    /// the field must never move a card or the chip.
    static let fieldReserve: CGFloat = TagInlineField.width + fieldGap

    var body: some View {
        // ── ROW 58 — THE CLUSTER IS A RIGHT-ALIGNED WRAPPING ROW ────────────
        // The cards, then the ＃, fill from the right edge and wrap onto
        // further lines when the width the masthead hands this cluster
        // says so (the masthead's row 2 gives it what remains right of the
        // path chip and a minimum gap — one layout, `PostDetailView`).
        // Nothing clips, nothing hides, no door moves. Before this the
        // cards were one non-wrapping HStack trailing on their own layer
        // and the centered path chip was laid out unaware of them — her
        // walk found the chip drawn UNDER the first cards on a five-tag
        // note and gone under the open field.
        TrailingFlow(itemSpacing: 4, lineSpacing: 4, leadingReserve: Self.fieldReserve) {
            ForEach(tags, id: \.id) { tag in
                TagChipCard(tokens: tokens, tag: tag, onRemove: { remove($0) })
                    .mastheadGeometryProbe(.card(tag.id), in: geometryProbeSpace)
            }
            door
            // THE FIELD IS AN OVERLAY, deliberately outside the flow's
            // items: it slides out of the ＃ to the LEFT of the ＃'s line,
            // into the room every line reserves for it, and no card, the
            // chip nor the title moves while a tag goes on (row 55's
            // lesson, kept: the walk's capture 11 was a laid-out field
            // squeezing the title to "thr…"). The anchor is the zero-width
            // item the flow parks at the last line's leading edge.
            Color.clear
                .frame(width: 0)
                .trailingFlowAnchor()
                .overlay(alignment: .trailing) {
                    if fieldOpen {
                        TagInlineField(
                            tokens: tokens, allTags: allTags, applied: Set(tags.map(\.path)),
                            onApply: { path in
                                apply(path)
                                // The field stays out after an apply, so several
                                // tags go on in one breath; ⎋ or ＃ closes it.
                            },
                            onDismiss: { fieldOpen = false })
                            .offset(x: -Self.fieldGap)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .mastheadGeometryProbe(.field, in: geometryProbeSpace)
                    }
                }
        }
        .animation(.easeInOut(duration: 0.18), value: fieldOpen)
        .task(id: postID) { await load() }
    }

    /// THE door: the ＃ glyph. Open → the field slides out with the cursor
    /// in it; open again → it slides away.
    private var door: some View {
        Button {
            fieldOpen.toggle()
        } label: {
            Image(systemName: "number")
                .font(tokens.small)
                .foregroundStyle(fieldOpen ? tokens.accent : tokens.faint)
                .padding(.vertical, 2)
                .padding(.horizontal, 3)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(WorkspaceNaming.tagFieldHelp(open: fieldOpen))
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

/// **The inline tag field** (row 15 — her "tag creator" field, cursor
/// already active). The popover's brain in an inline body: one squarish
/// field (W8-2's search-field grammar), focused on appear; ⏎ applies what
/// was typed (creating the path if it is new — the standing door), ⎋
/// dismisses, and the live taxonomy's matches hang under it as a small
/// list a click applies.
struct TagInlineField: View {
    let tokens: VoiceTokens
    let allTags: [Tag]
    let applied: Set<String>
    let onApply: (String) -> Void
    let onDismiss: () -> Void

    @State private var typed = ""
    @FocusState private var focused: Bool

    /// The field's width — room for a nested path, never a search bar.
    static let width: CGFloat = 190

    private var suggestions: [Tag] {
        TagChipAdder.suggestions(allTags, typed: typed, applied: applied, limit: 6)
    }

    var body: some View {
        TextField("", text: $typed, prompt: Text(tokens.chromeLabel("tag — ⏎ applies · / nests")))
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .focused($focused)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .frame(width: Self.width)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(focused ? tokens.accent.opacity(0.45) : tokens.line, lineWidth: 1))
            .onSubmit { apply(typed) }
            .onExitCommand { onDismiss() }
            // The matches hang UNDER the field, over whatever sits below the
            // masthead (the masthead's z-order lifts them above the page).
            .overlay(alignment: .topLeading) {
                if focused, !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.id) { tag in
                            Button {
                                apply(tag.path)
                            } label: {
                                Text(tokens.chromeLabel(tag.path))
                                    .font(tokens.small)
                                    .foregroundStyle(
                                        TagChipColor.color(forPath: tag.path, dark: false))
                                    .lineLimit(1)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .frame(width: Self.width, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(tokens.line, lineWidth: 1))
                    .offset(y: 26)
                    .fixedSize()
                }
            }
            .task { focused = true }
            .help("Tag this note — type a path (\u{201C}/\u{201D} nests: life/goals), \u{23CE} applies, \u{238B} closes")
    }

    private func apply(_ path: String) {
        let trimmed = path.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        typed = ""
        onApply(trimmed)
    }
}
