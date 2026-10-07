//
//  MobileNoteActions.swift
//  VariorumMobile
//
//  **THE NOTE'S ⋯ — the masthead's note-scale acts** (round 2, batch 4).
//  Two rows arrive with it, and they are the two things the phone most
//  visibly lacked:
//
//  · **M20's persistent undo/redo door** (her R10) — the companion to the
//    receipt's Undo, for acts whose receipt has already passed. It carries
//    the stack's live `topLabel` / `topRedoLabel`, so the rows say what
//    they will do ("Undo Divide", "Redo Delete Blocks") instead of naming
//    a direction and hoping.
//  · **PR1's Delete Note…** — the phone had NO note-delete door anywhere
//    (the parity inventory's headline). Move to Trash, confirmed, with the
//    destination and the clock named.
//
//  **BATCH 6c ADDS THE NOTE'S TWO TIME CONTROLS** — `Save a Version` and
//  `Versions…` — and the pairing IS a teaching surface, not a pair of rows
//  (the archive/trash design record's finding 2). The Mac teaches the two
//  sizes of moment with two chords: ⌘S saves THIS TAKE's moment, ⌘⇧S saves
//  THIS NOTE's. The phone has no chord culture (PL-11's own words), so the
//  teaching needs another home — and it already had one, because the phone
//  keeps block acts in the **block ⋯** and note acts here. **As it stood
//  at 6c, kept because it was TRUE WHEN WRITTEN** (`MobileBlockMenu`'s own
//  convention for a superseded note):
//
//      block ⋯  →  Commit Take    +  Block History…
//      note  ⋯  →  Save a Version +  Versions…
//
//  **THE BLOCK ROW OF THAT DIAGRAM IS HISTORY, NOT CURRENT** (round 2,
//  batch 9 — her ⋯ letter: *"take history should move into the three ...
//  menu on each take rather than the main three dot menu"*). `Block
//  History…` left the block ⋯ and now lives on every live take card's
//  own ⋯ in the takes browser (`MobileTakesBrowserController.historyTitle`),
//  so the block grain's pair is broken on purpose — `MobileBlockMenu`'s
//  header carries the whole reasoning. What SURVIVES is exactly the row
//  below it: the NOTE ⋯ still holds its own *write a moment / see the
//  moments* pair, which is now the only place the phone teaches it, and
//  which is why this file's own shape did not change.
//
//  Two grains, and since batch 9 only ONE of them still holds its own
//  *write a moment / see the moments* pair here. **PROVISIONAL — the
//  design record's Q5:** it grows a
//  three-row sheet to five, and the alternative (a sixth masthead chip) was
//  refused because that row already wraps five and its crowding is flagged
//  for her.
//
//  **Why a SHEET and not a `Menu`** (the inventory recommended a `Menu`;
//  this is the recorded deviation, and it is the round's own trap-2 rule
//  paying rent): a SwiftUI `Menu`'s rows present into a separate context-
//  menu hierarchy that a pin cannot reach — measured, not assumed (the
//  probe: activating the Menu presents a `_UIContextMenuActionsOnlyView-
//  Controller` whose accessibility tree comes back EMPTY). Under §15's
//  trap (b) — *every door in this batch gets a pin that mounts the real
//  surface and drives the real control* — a Menu row is a door no pin can
//  drive, which is how the Mac's dead purge doors shipped. A sheet's rows
//  are ordinary Buttons: findable, activatable, and pinnable. It is also
//  the phone's own established grammar for summoned machinery (membership,
//  tags, references, blocks, lenses all present this way from this exact
//  masthead), and it leaves room for the tray and lineage doors the ledger
//  still owes this surface.
//
//  **The destructive dialogs here NEVER use the Mac's dead pattern** (§15's
//  trap (a)): both are `.alert(..., isPresented:)` over a real `@State` or
//  a `@Bindable` model property — the phone's shipped immune road.
//

import SwiftUI
import VariorumCore

struct MobileNoteActionsSheet: View {
    /// `@Bindable` so `$door.pendingWarning` is a REAL observation
    /// dependency — never a `Binding(get:set:)` computed over a property
    /// `body` does not read (the Mac's `RecoveryView` dead-door defect).
    @Bindable var door: MobileUndoDoor
    let model: MobileEditorViewModel
    let tokens: VoiceTokens
    /// The note went — the screen must navigate away from a tombstone.
    let onDeleted: () -> Void
    /// **Versions… (batch 6c)** — dismiss this sheet and push the note's
    /// Versions screen. nil in harness/preview use, where the row is still
    /// rendered and pinned: it is the DOOR that is optional, never the row,
    /// so a pin can prove the row exists and fires.
    var onOpenVersions: (() -> Void)?
    @State private var deletePresented = false
    @Environment(\.dismiss) private var dismiss

    static let sheetTitle = "Note"
    /// The masthead door's accessibility name (the pin's handle, and what
    /// VoiceOver says for a bare ⋯).
    static let doorLabel = "Note Actions"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(tokens.chromeLabel(Self.sheetTitle))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            // The note's two TIME controls first — the grain pairing the
            // phone teaches here instead of with chords (finding 2).
            saveVersionRow
            versionsRow
            Divider().overlay(tokens.line)
            undoRow
            redoRow
            Divider().overlay(tokens.line)
            deleteRow
            reportLine
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        // A12's destructive-undo warning — raised only when the undo would
        // set aside text edited since the operation (the insurance class).
        // Bound to THIS surface, so the masthead's twin host stays quiet
        // while the sheet is up.
        .alert(
            door.pendingWarning.map(
                { StructuralUndoCopy.discardingUndoQuestion($0.warning) }) ?? "",
            isPresented: $door.warningAtSheet
        ) {
            Button(tokens.chromeLabel("Undo"), role: .destructive) {
                let door = door
                Task { await door.confirmPendingUndo() }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) { door.cancelPendingUndo() }
        } message: {
            Text(door.pendingWarning.map(
                { MobileUndoDoor.discardingUndoDetail($0.warning) }) ?? "")
        }
        .alert(
            MobileEditorViewModel.deleteNoteConfirmTitle,
            isPresented: $deletePresented
        ) {
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task {
                    if await model.deleteNote() {
                        dismiss()
                        onDeleted()
                    }
                }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: {
            Text(MobileEditorViewModel.deleteNoteConfirmDetail)
        }
    }

    /// **A refusal raised HERE is spoken HERE** (§49's MINOR: *a refusal
    /// spoken behind the presenting sheet*).
    ///
    /// Every act on this sheet reports through `MobileEditorViewModel.report`,
    /// which renders in the WRITE surface's masthead — and this sheet covers
    /// the masthead. On the happy road that is invisible, because the sheet
    /// dismisses: `deleteNote()` returning `true` dismisses, an undo that
    /// lands dismisses nothing but is spoken after the alert closes. On a
    /// REFUSAL the sheet deliberately STAYS UP (a refused delete must not
    /// look like it went), so the sentence explaining why landed on a surface
    /// she could not see — the door's own D2 rule, *spoken where the door
    /// fired*, broken by a covering sheet.
    ///
    /// It reads the SAME one projection rather than keeping a copy: one
    /// message, rendered wherever the acting door is standing.
    @ViewBuilder
    private var reportLine: some View {
        if let message = model.statusMessage {
            Text(tokens.chromeLabel(message))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)
                .accessibilityLabel(message)
        }
    }

    /// **Save a Version** — ⌘⇧S's phone twin, and the whole note's moment.
    /// The sentence is the shared one (`VersionsPath`): the Mac and the
    /// phone must not describe one machinery two ways.
    ///
    /// The sheet STAYS UP: this is a save, not a departure, and its receipt
    /// (or refusal) is what `reportLine` below renders — a refusal spoken
    /// behind a covering sheet was §49's own MINOR.
    private var saveVersionRow: some View {
        actRow(
            title: VersionsPath.saveVerb,
            detail: Self.saveRowDetail,
            tint: tokens.accent
        ) {
            let model = model
            Task { await model.saveVersion() }
        }
    }

    /// **Versions…** — the moments of this note. Dismiss the sheet, then ask
    /// the shell to push.
    ///
    /// **The order is deliberate; the "proven road" claim this comment used
    /// to make was not** (the cold review's m4). It cited the shell's
    /// settings-sheet grammar — which is DEBUG-only, unpinned, and a
    /// different shape: there the shell flips its own `settingsPresented`
    /// flag and appends to the path in ONE scope, while here an
    /// environment `dismiss()` inside the sheet is followed by a callback up
    /// the tree. Nothing was measured, and no failure was ever traced. What
    /// the fix wave did instead of re-asserting it: DRIVE the composed road
    /// on a mounted `MobileShellView`
    /// (`MobileVersionsTests.theVersionsRowOpensTheRoomThroughTheWholeShell`),
    /// so the claim is a pin rather than a comment.
    private var versionsRow: some View {
        actRow(
            title: VersionsPath.menuLabel,
            detail: Self.versionsRowDetail,
            tint: tokens.accent
        ) {
            dismiss()
            onOpenVersions?()
        }
    }

    // MARK: - The two rows' own detail lines (phone-voiced, and listed)

    /// **These two lines are the phone's OWN, and that is a recorded gap
    /// rather than a licence** (the cold review's m2). `VersionsCopy` holds
    /// every SENTENCE about the machinery; what it has no home for is a
    /// menu row's one-line detail, which is a face fact — an iOS sheet row
    /// has a subtitle and a Mac menu item does not.
    ///
    /// The first draft's save-row line read *"saves this whole note as it is
    /// right now"* — one word off a clause inside `VersionsPath.empty`, i.e.
    /// the same sentence living twice, which is exactly what that shared
    /// file's header forbids. It is re-voiced here to say what the row
    /// LEAVES BEHIND rather than to restate the act, and the pin
    /// (`theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed`)
    /// enumerates all four phone-voiced Versions strings and holds them
    /// clear of the shared sentences.
    ///
    /// **`VersionsPath.saveDetail` is the durable answer** and it is on the
    /// next Shared-touching batch's list (`Shared/` is fenced this round).
    static let saveRowDetail = "keeps a moment of the note, to come back to"

    /// Composed from the shared VERBS rather than invented: this row's
    /// detail is a list of what is behind the door, and those three words
    /// are `VersionsPath`'s own.
    static var versionsRowDetail: String {
        "\(VersionsPath.openVerb.lowercased()), "
            + "\(VersionsPath.restoreVerb.lowercased()) or "
            + "\(VersionsPath.promoteVerb.lowercased()) a saved moment"
    }

    /// The stack's undo end. Rendered only when there IS one — P-2: a door
    /// that can never act in its context isn't rendered, and "Undo" with an
    /// empty stack is exactly that.
    @ViewBuilder
    private var undoRow: some View {
        if let label = door.undoLabel {
            actRow(
                title: StructuralUndoCopy.undoDoorTitle(label),
                detail: "puts the last structural change back",
                tint: tokens.accent
            ) {
                let door = door
                Task { await door.beginUndo(from: .sheet) }
            }
        }
    }

    @ViewBuilder
    private var redoRow: some View {
        if let label = door.redoLabel {
            actRow(
                title: StructuralUndoCopy.redoDoorTitle(label),
                detail: "re-applies what you just undid",
                tint: tokens.accent
            ) {
                let door = door
                Task { await door.redo() }
            }
        }
    }

    private var deleteRow: some View {
        actRow(
            title: MobileEditorViewModel.deleteNoteTitle,
            detail: RecoveryCopy.moveToTrashDetail(.note),
            tint: .red, role: .destructive
        ) {
            deletePresented = true
        }
    }

    /// One row shape for every act — a real `Button` (never a `Menu` row),
    /// labelled for VoiceOver and for the pins that drive it.
    /// The tint is a PARAMETER rather than a ternary inside the modifier
    /// (clearer, and it was written that way while chasing the note below),
    /// and the destructive row ALSO carries `role: .destructive` — the
    /// idiomatic iOS marking, which is what a `UIAlertController` uses for
    /// the same idea.
    ///
    /// **RECORDED OBSERVATION for the visual pass, measured not guessed:**
    /// in a `layer.render`-based capture of this sheet, SYSTEM semantic
    /// colours (`.red`, `.green`, `.orange`) render as the default label
    /// colour while a custom `Color` (`tokens.accent`) renders correctly —
    /// verified by changing the colour four ways, by a title probe proving
    /// the build was fresh, and by the fact that the very same `.red`
    /// renders red in `MobileTrashView`'s root-level rows and in the UIKit
    /// confirm's own destructive action in the same capture. Most likely a
    /// capture artifact of rendering a presentation container's layer, not
    /// a product defect — but it is a colour a DELETION door depends on
    /// (principle M-E), so it is flagged for a device look rather than
    /// assumed good.
    private func actRow(
        title: String, detail: String, tint: Color,
        role: ButtonRole? = nil, act: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: act) {
            VStack(alignment: .leading, spacing: 2) {
                Text(tokens.chromeLabel(title))
                    .font(tokens.body)
                    .foregroundStyle(tint)
                Text(tokens.chromeLabel(detail))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
