//
//  MobileTrashView.swift
//  VariorumMobile
//
//  **THE TRASH ROOM — a utility you visit** (round 2, batch 4 — PR2;
//  **narrowed from the combined "Archived & Deleted" surface at batch 6c**).
//  Pushed as its own screen (a deliberately-opened surface, never a held
//  one: its stranded-originals arm walks lineage families).
//
//  **HER RULING, verbatim (QUESTIONS #84):** *"Two rooms — The Mac's own
//  asymmetry, translated literally. Archive becomes a room you browse; the
//  Trash becomes a utility you visit. Two doors, two destinations, nothing
//  shared."* Batch 4's combined screen — Trash section → `Divider` →
//  Archived section — was known-interim BY HER WORD, and this is its close.
//  The two promises it held apart in one scroll are now two rooms:
//  everything here is on the 30-day clock, and `MobileArchiveView` is the
//  kept-forever one. **Its door is the trash glyph on the LIBRARY's top
//  line** (`MobileRecoveryDoors`, `MobileTrashDoor` — the Mac's own trash
//  icon since VM-255, where it was a 🗑 on the path line), the analogue of
//  her Mac B1 ruling — the masthead trash icon that replaced a ⋯ menu. The
//  SHELF carried the same door too (a deleted BOOK rows here while books live
//  on the Shelf — the design record's finding 1) until VM-255, her words: "let's
//  just only show the trash icon within library."
//
//  **Both purge doors live here and nowhere else** (her round-3 rider), and
//  the split is where that could have been lost: `MobileArchiveModel` has no
//  purge road at all, so the rule is now structural in the Archive room
//  rather than merely absent from its view body.
//
//  ── THE TWO SHAPES THIS SURFACE CHOSE, AND WHY ───────────────────────────
//
//  **1. Every act is a VISIBLE BUTTON, never a swipe or a `Menu` row.** The
//  inventory sketched swipe actions with a long-press menu behind them.
//  Both are doors a pin cannot drive — measured: a SwiftUI `Menu`'s rows
//  present into a context-menu hierarchy whose accessibility tree comes
//  back EMPTY, and a swipe has no activation an in-process pin can send. §15's
//  trap (b) binds this batch absolutely — *every door gets a pin that mounts
//  the real surface and drives the real control* — and the reason is this
//  very surface's Mac twin, whose purge doors shipped DEAD under green
//  view-model pins. Visible buttons are also simply more discoverable in a
//  room she will visit rarely and urgently.
//
//  **2. The destructive dialog is `.alert(isPresented:presenting:)` over a
//  real `@Bindable` projection** — and BOTH halves are load-bearing. The
//  projection keeps the dialog PRESENTING (never a `Binding(get:set:)`
//  computed over an `@Observable` property — §15's trap (a)); `presenting:`
//  keeps it ACTING, by carrying the pending confirm INTO the action closure
//  instead of leaving it to be read back after the dismissal has cleared it.
//  Batch 4 shipped only the first half and this door confirmed nothing at
//  all: the rule it was obeying named a syntax, not the property that
//  mattered. `MobileTrashModel.purgeConfirmPresented` states the real one.
//
//  Rows are read-cheap `Text` (P3: no editor ever lives here), the listing
//  is windowed with a visible truncation marker (P1), and the filter/sort
//  restart the SQL rather than re-sorting in memory.
//

import SwiftUI
import VariorumCore

struct MobileTrashView: View {
    @Bindable var model: MobileTrashModel
    let tokens: VoiceTokens
    /// Open a note (an archived row's other road, and a Trash row's
    /// "from ‹note›" context when that note is still live).
    let onOpen: (String) -> Void

    /// The kind filter's doors, in the Mac picker's order — from the ONE
    /// decision (the post-13l polish round, ledger row 11): a filter may
    /// never offer a kind the listing no longer holds.
    static let filterKinds: [Queries.TrashItem.Kind?] =
        [nil] + TrashScope.filterKinds.map { Optional($0) }

    static let allFilterWord = "All"
    static let emptyTrashLine = "Nothing in the Trash."

    /// **The empty line, or nil while there is nothing true to say** (VM-33 —
    /// the Mac's `RecoveryViewModel.trashEmptyStateLine` rule). Before the
    /// listing's first value it is nil, never the false "Nothing in the
    /// Trash." — the face draws nothing in its place (calm, no spinner).
    static func emptyStateLine(_ model: MobileTrashModel) -> String? {
        guard model.trashListingLoaded, model.trash.isEmpty else { return nil }
        return emptyTrashLine
    }

    static func truncationMarker(shown: Int) -> String {
        "Showing the first \(shown) — narrow the filter to see more."
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                trashHeader
                filterRow
                if let line = Self.emptyStateLine(model) {
                    emptyLine(line)
                } else {
                    ForEach(model.trash, id: \.id) { item in
                        trashRow(item)
                    }
                }
                if model.trashTruncated {
                    emptyLine(Self.truncationMarker(shown: model.trash.count))
                }
            }
            .padding(.horizontal, 8)
        }
        // VM-51 (R-47-1, "prose should not be on the tint"): the Trash's rows
        // on the paper (its answers speak on the shell's one line, VM-61).
        .background(tokens.surface.ignoresSafeArea())
        // VM-47 (the walk's W-A1, redone): the strips beyond the shell's band —
        // the page's paper at both edges (the bar's room at its foot is the
        // shell's to paint while the bar stands there).
        .mobileEdgeGrounds(top: tokens.surface, bottom: tokens.surface)
        .navigationBarTitleDisplayMode(.inline)
        // The filter and the sort are applied IN SQL, so a change restarts
        // the observation rather than re-sorting a window of the wrong set.
        .task(id: model.restartToken) { await model.startTrash() }
        // Delete Now / Empty Trash — ONE confirm host, over a REAL
        // `@Bindable` projection (§15's trap (a)) AND with the act's value
        // riding into the action closure (`presenting:` — batch 4.5b's
        // BLOCKER fix). The second half is the one that matters: the
        // projection alone presented perfectly and then confirmed NOTHING,
        // because SwiftUI clears `isPresented` inside tap handling and the
        // action's `Task` read the cleared value back. See the rule at
        // `MobileTrashModel.purgeConfirmPresented`.
        .alert(
            model.pendingConfirm?.title ?? "",
            isPresented: $model.purgeConfirmPresented,
            presenting: model.pendingConfirm
        ) { confirm in
            Button(tokens.chromeLabel(confirm.confirmVerb), role: .destructive) {
                let model = model
                Task { await model.confirmPendingPurge(confirm) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {
                model.cancelPendingPurge()
            }
        } message: { confirm in
            Text(confirm.message)
        }
    }

    // MARK: - Chrome

    /// The Trash's header: its name, its promise, and Empty Trash — which
    /// renders ONLY when the Trash holds something (P-2).
    private var trashHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(tokens.path([RecoveryCopy.trashSection]))
                    .phoneType(.screenTitle, tokens)
                    .foregroundStyle(tokens.phone.muted)
                Spacer()
                sortDoor
                if !model.trash.isEmpty {
                    Button {
                        let model = model
                        Task { await model.requestEmptyTrash() }
                    } label: {
                        Text(tokens.chromeLabel(RecoveryCopy.emptyTrashVerb))
                    }
                    .buttonStyle(PhoneInlineActStyle(
                        tokens: tokens, tone: .alarm, role: .control, alignment: .leading))
                    .accessibilityLabel(RecoveryCopy.emptyTrashVerb)
                }
            }
            Text(tokens.chromeLabel(RecoveryCopy.windowNote))
                .phoneType(.meta, tokens)
                .foregroundStyle(tokens.phone.muted)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    /// newest ⇄ oldest, her round-3 second control.
    private var sortDoor: some View {
        Button {
            model.setOldestFirst(!model.oldestFirst)
        } label: {
            Text(tokens.chromeLabel(model.oldestFirst ? "oldest first" : "newest first"))
        }
        .buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .accent))
        .accessibilityLabel("Sort")
    }

    /// The kind filter — plain doors in a scrolling row (the Library filter
    /// row's grammar), never a `Menu`: a door a pin can drive.
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            // VM-50: filter chips (seven words do not share a segmented
            // choice at phone width; the sheet's chip is "filters … one row
            // that scrolls sideways") — P-47-11.
            HStack(spacing: PhoneMetrics.Space.s8) {
                ForEach(Array(Self.filterKinds.enumerated()), id: \.offset) { _, kind in
                    let word = kind.map(RecoveryCopy.kindLabel) ?? Self.allFilterWord
                    Button {
                        model.setKindFilter(kind)
                    } label: {
                        Text(tokens.chromeLabel(word))
                    }
                    .buttonStyle(PhoneChipStyle(tokens: tokens, selected: model.kindFilter == kind))
                    .accessibilityLabel(word)
                    .accessibilityAddTraits(model.kindFilter == kind ? .isSelected : [])
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 8)
    }

    /// The room's prose lines — the empty line and the truncation marker.
    /// **The plain sentence rides as the accessibility label** (the standing
    /// rule; the Terminal voice lowercases chrome, and a marker VoiceOver
    /// reads as *"showing the first 200 — narrow the filter to see more."*
    /// is chrome leaking into speech). Added at the 6c fix wave beside n9's
    /// marker pin.
    private func emptyLine(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .phoneType(.meta, tokens)
            .foregroundStyle(tokens.phone.muted)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .accessibilityLabel(text)
    }

    // VM-61: this room's receipts and refusals speak on the shell's one
    // line (`MobileMessageLine`), never in a slot of its own.

    // MARK: - Rows

    private func trashRow(_ item: Queries.TrashItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Self.rowTitle(item))
                .phoneType(.rowTitle, tokens)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
            Text(tokens.chromeLabel(rowMeta(item)))
                .phoneType(.meta, tokens)
                .foregroundStyle(tokens.phone.muted)
                .lineLimit(2)
            HStack(spacing: 18) {
                Button {
                    let model = model
                    Task { await model.putBack(item) }
                } label: {
                    Text(tokens.chromeLabel(RecoveryCopy.putBackVerb))
                }
                .buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .accent))
                .accessibilityLabel("\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(item))")
                // **Delete Now lives HERE and nowhere else** (her round-3
                // rider: never a full delete from inside a note). A
                // preserved original never wears one — it rides its family
                // (round 8b), so the door is not rendered (P-2).
                if item.kind != .preservedOriginal {
                    Button {
                        model.requestDeleteNow(item)
                    } label: {
                        Text(tokens.chromeLabel(RecoveryCopy.deleteNowVerb))
                    }
                    .buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .alarm))
                    .accessibilityLabel(
                        "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(item))")
                }
                // Open its note, where there still is one to open.
                if let noteID = item.noteID, !item.noteIsDeleted, item.kind != .note {
                    Button {
                        onOpen(noteID)
                    } label: {
                        Text(tokens.chromeLabel("Open note"))
                    }
                    .buttonStyle(PhoneInlineActStyle(tokens: tokens, tone: .accent))
                    .accessibilityLabel("Open note")
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }

    // MARK: - Row faces (pure, pinned)

    /// What a row shows as its name. Notes and books have one; blocks and
    /// takes show their text; nothing is ever blank.
    static func rowTitle(_ item: Queries.TrashItem) -> String {
        if let title = item.title, !title.isEmpty { return title }
        if let text = item.text, !text.isEmpty { return text }
        // VM-83 (W-073): an untitled GATHERING is named by its own kind word
        // (VX-611's rule — the row's kind word already was), never "(empty
        // book)". Round 1, N2: the ITEM overload, the shared file's rule
        // wherever the row is in hand — so an untitled saved version is
        // named as one too, as its meta line already says.
        return "(empty \(RecoveryCopy.rowKind(item)))"
    }

    /// The row's second line: what it is · where it came from · and the
    /// clock. A stranded original says WHY it is here instead of a bare
    /// countdown (her round-8b ruling).
    private func rowMeta(_ item: Queries.TrashItem) -> String {
        var parts: [String] = []
        if item.kind == .preservedOriginal {
            parts.append(RecoveryCopy.goesWithItsFamily)
        } else {
            // The ITEM overload, so a saved version says "saved version"
            // rather than "note" (LR2-4's rule; the Mac's display row has
            // worded it this way since the polish round's ledger row 23, and
            // this line is the phone's half of it, found while pinning the
            // accessibility labels the finding named).
            parts.append(RecoveryCopy.rowKind(item))
        }
        // A saved version's HOME is the note it is a moment of — and it is a
        // `.note`-kind row, so the plain `item.kind != .note` guard hid that
        // note's name from exactly the row that most needs it.
        if let noteTitle = item.noteTitle, item.isVersion {
            parts.append(VersionsPath.trashRowOf(noteTitle))
        } else if let noteTitle = item.noteTitle, item.kind != .note {
            parts.append(item.noteIsDeleted
                ? "from \(noteTitle) — also in the \(RecoveryCopy.trashSection)"
                : "from \(noteTitle)")
        }
        if let days = model.daysLeft(item) {
            parts.append(RecoveryCopy.daysLeftLabel(days))
        }
        return parts.joined(separator: "  ·  ")
    }
}
