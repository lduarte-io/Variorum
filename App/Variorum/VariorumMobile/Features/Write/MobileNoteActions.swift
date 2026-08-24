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
