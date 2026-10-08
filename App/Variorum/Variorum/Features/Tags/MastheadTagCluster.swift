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
//  ── 13i-d U3 — THE CARDS ARE A HELD READ (KnownIssues row 112) ──────────
//  The cluster used to read the note's tags ONCE per note, so a tag taken
//  off by ANOTHER door on the same screen (13i-c's membership-chip
//  "remove #tag", 13i-d U2's Book Panel gathering line) kept its card until
//  the note was reopened (U2's walk capture `u2/14`). The read lives in
//  `MastheadTagsModel` now (below).
//

import GRDB
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

    /// 13i-d U3 (KnownIssues row 112): the cluster's two reads live in ONE
    /// small model, the row-104 shape (`NoteMembershipModel`).
    @State private var store = MastheadTagsModel()
    private var tags: [Tag] { store.tags(for: postID) }
    private var allTags: [Tag] { store.allTags }

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
            // The door ends the last line WITH a card — never orphaned on a
            // line of its own (the first walk on the fixed row: five cards
            // filled the line exactly and the ＃ stood alone below them).
            door
                .keepsWithPrevious()
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
                                // 17o batch d, ledger row 40 (her U-15): the
                                // note now carries a tag, so the template does
                                // not sit open beside it — the ＃ is right
                                // there for the next one. (This retires "the
                                // field stays out after an apply, so several
                                // tags go on in one breath": it is exactly the
                                // sitting-open she asked to stop, and one key
                                // reopens it.)
                                fieldOpen = false
                            },
                            onFocusLost: {
                                // Her rule, verbatim in shape: *"if there's a
                                // tag already applied this new tag template
                                // shouldn't just sit here by default, it should
                                // collapse after you click out of it."* A note
                                // with NO tags keeps the field on the first
                                // click — there is nothing yet for the template
                                // to be sitting redundantly beside, and her
                                // words are about the already-tagged case.
                                if !tags.isEmpty { fieldOpen = false }
                            },
                            onDismiss: { fieldOpen = false })
                            .offset(x: -Self.fieldGap)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .mastheadGeometryProbe(.field, in: geometryProbeSpace)
                    }
                }
        }
        .animation(.easeInOut(duration: 0.18), value: fieldOpen)
        .task(id: postID) { await store.track(session: session, postID: postID) }
    }

    /// Row 59 (the Act 10 correction round, batch G — the orchestrator's walk
    /// of batch A): the ＃'s HIT TARGET is the row's height, never the
    /// glyph's. The ~10 pt symbol was its own target, so a click a few
    /// points off landed on the neighbouring card's × (a tag removed by
    /// accident) or in the editor. The glyph keeps its place inside a
    /// square target of this side (C-7's "generous targets"; the geometry
    /// pin reads the door's frame).
    static let doorTarget: CGFloat = 24

    /// THE door: the ＃ glyph. Open → the field slides out with the cursor
    /// in it; open again → it slides away.
    private var door: some View {
        Button {
            fieldOpen.toggle()
        } label: {
            Image(systemName: "number")
                .font(tokens.small)
                .foregroundStyle(fieldOpen ? tokens.accent : tokens.faint)
                .frame(width: Self.doorTarget, height: Self.doorTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(WorkspaceNaming.tagFieldHelp(open: fieldOpen))
        // 13s-b U2: the leg's second stop ("The ＃ on the masthead adds a
        // tag").
        .tourAnchor(.mastheadTagDoor, cornerRadius: 6, outset: 0)
        .mastheadGeometryProbe(.door, in: geometryProbeSpace)
    }

    // MARK: - The standing doors (PaneHost's discipline, moved with the cards)

    /// Applying a typed path goes through the SHIPPED type-to-create door
    /// (`TagAssignmentViewModel.applyTypedPath`, 13b 3D's N24) — this face
    /// adds no tag semantics of its own.
    private func apply(_ path: String) {
        let model = TagAssignmentViewModel(session: session, postID: postID)
        Task {
            if await model.applyTypedPath(path) == nil, let error = model.lastError {
                session.status.refuse(error)
            }
            await store.refresh(session: session, postID: postID)
        }
    }

    private func remove(_ tag: Tag) {
        Task {
            do {
                try await session.runner.run { ops in
                    try ops.removeTag(tag.id, fromPost: postID)
                }
            } catch {
                session.status.refuse(TagsViewModel.message(error))
            }
            await store.refresh(session: session, postID: postID)
        }
    }
}

/// **The note's tag cards' read** (13i-d U3 — KnownIssues row 112, U2's
/// F-U2-2): the cards a note wears and the live taxonomy the inline field
/// suggests from. Extracted from the cluster so its cadence is pinned
/// without a window — the row-104 shape (`NoteMembershipModel`).
///
/// `track` is the cluster's HELD read for the note's visit; `refresh` is a
/// one-shot re-read after the cluster's OWN door acts (belt and braces — the
/// observation delivers the same change a beat later). A `subject` guard
/// keeps a previous note's cards from answering for the next one.
@MainActor
@Observable
final class MastheadTagsModel {
    private(set) var subject: String?
    private var applied: [Tag] = []
    private(set) var allTags: [Tag] = []

    /// The cards for `postID` — empty when the read in hand is another note's.
    func tags(for postID: String) -> [Tag] {
        subject == postID ? applied : []
    }

    /// What one read returns: the note's cards and the live taxonomy.
    nonisolated struct Snapshot: Equatable, Sendable {
        var applied: [Tag]
        var all: [Tag]
    }

    /// The ONE fetch — `post_tag` and `tag` only, never `container` or
    /// `variant` (pinned by region: autosave must never wake it).
    ///
    /// 13i-d U5: `wingID` — the NOTE's wing (its vocabulary — a tag of
    /// another wing does not exist in this library). Read ONCE per visit,
    /// OUTSIDE the held observation (`noteWing`), so the region stays
    /// `post_tag` + `tag` alone; nil = every wing (the pins' shape).
    nonisolated static func fetch(
        _ db: Database, postID: String, wingID: String? = nil
    ) throws -> Snapshot {
        Snapshot(
            applied: try Queries.postTags(db, postID: postID),
            all: try Queries.allTags(db, wingID: wingID))
    }

    /// The note's wing as surfaces read it — one point read per visit (13i-d
    /// U5), never inside the held region.
    nonisolated static func noteWing(_ db: Database, postID: String) throws -> String {
        try Queries.effectiveWing(db, ofPost: postID) ?? ""
    }

    /// The visit's read — HELD for as long as the note is shown (the
    /// cluster's `.task(id: postID)` cancels it on leaving). A tag taken off
    /// or put on by ANY door — the chip's "remove #tag", the Book Panel's
    /// gathering line, another window — reaches the cards without a reopen.
    /// Cost, named beside KnownIssues row 13's class and OUTSIDE it: the
    /// region is `post_tag` + `tag` alone, so a keystroke's autosave never
    /// wakes it;
    /// a tagging act anywhere re-runs two indexed reads (the note's
    /// applications and the author-scale taxonomy).
    func track(session: AppSession, postID: String) async {
        let wing = try? await session.database.read { db in
            try Self.noteWing(db, postID: postID)
        }
        do {
            for try await snapshot in session.database.observe({ db in
                try Self.fetch(db, postID: postID, wingID: wing)
            }) {
                adopt(snapshot, postID: postID)
            }
        } catch {
            // Cancellation (the note left) or a store refusal: the cards in
            // hand stay; the next visit's read starts fresh.
        }
    }

    func refresh(session: AppSession, postID: String) async {
        guard let read = try? await session.database.read({ db in
            try Self.fetch(db, postID: postID, wingID: try Self.noteWing(db, postID: postID))
        }) else { return }
        // Ladder A round 1, MINOR 1 (U3's extension): a refresh in flight
        // for the OLD note may land after the NEW note's read adopted — a
        // one-shot whose postID is no longer the subject in hand is dropped.
        // A nil subject adopts (the first read of a fresh visit; the held
        // track's own delivery corrects it either way).
        guard subject == nil || subject == postID else { return }
        adopt(read, postID: postID)
    }

    /// Internal so the ladder's pin drives it deterministically (the
    /// `BookArchivedModel.adopt` precedent).
    func adopt(_ snapshot: Snapshot, postID: String) {
        // Ladder A round 1, MINOR 1: a SUPERSEDED observation's late
        // delivery — its task cancelled by `.task(id:)` for the next note —
        // never stomps the subject in hand. The `NoteMembershipModel` guard
        // (the `NoteBoxFactsModel` lesson), on every loop of this class.
        guard !Task.isCancelled else { return }
        applied = snapshot.applied
        allTags = snapshot.all
        subject = postID
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
    /// Row 40: the field resigned the keyboard — the CLUSTER decides what
    /// that means, because only it knows whether the note carries a tag.
    let onFocusLost: () -> Void
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
            // Row 40: clicking out reports. A suggestion row is a plain
            // `Button`, which does not take the keyboard on macOS, so this
            // cannot fire under a click on the list below.
            .onChange(of: focused) { _, nowFocused in
                if !nowFocused { onFocusLost() }
            }
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
                    // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                    // states its own line policy, so its IDEAL width can never be a
                    // wrapped one (the b6dae25 class's window-sizing hazard).
                    // The suggestion rows carry their own `lineLimit(1)` inside; the
                    // PANEL states it too, so the class is mechanical rather than a
                    // fact four lines down the file.
                    .lineLimit(1)
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
