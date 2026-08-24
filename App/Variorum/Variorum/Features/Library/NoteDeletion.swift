//
//  NoteDeletion.swift
//  Variorum (Mac)
//
//  **THE NOTE-DELETION DOOR SET** (13l Act 2, ledger item 3 — her report at
//  13j's close, *"how do i even delete a note? I'm within a note I want to
//  delete right now and I don't see how to delete it"*, and the ruling it
//  became: *"include delete note in the note menu with confirmation, … add a
//  confirmation for the library door of deletion, and … allow for command
//  clicking to select multiple items and deleting all of them"*).
//
//  ── WHAT LIVES HERE, AND WHY IT IS ONE FILE ──────────────────────────────
//  Four doors reach this act — the `note ▾` menu in BOTH bottom bars, the
//  Library's note rows, the Pool's note rows, and the Library's ⌘-click
//  multi-select — and every one of them owes the same four things: FLUSH
//  first, delete, say where it went, and get every pane and window off the
//  note it just tombstoned. A door that forgets the last of those leaves a
//  surface standing on a tombstone, which is the one thing this act must
//  never leave behind (the phone's own delete door says exactly that, and it
//  is why `MobileEditorViewModel.deleteNote` returns a Bool).
//
//  ── NO UNDO ENTRY, AND THAT IS A RULING, NOT AN OMISSION ─────────────────
//  `deleteContainer` registers nothing on the structural stack and never has.
//  13j's doctrine is the reason: **the Trash is the recovery door, not
//  structural undo** — the receipt says so in words, and Put back is the
//  gesture. The KnownIssues row born of mobile round 2 states the boundary
//  exactly: whether `deleteContainer` should be undoable at all is a PRODUCT
//  call and it is the author's, with 13j's doctrine as the precedent. So the
//  multi-delete deliberately does NOT reach for `UndoStack.withCompound` the
//  way 13e's multi-BLOCK delete does: a compound over legs that register
//  nothing collects nothing, and building the entry that would make it
//  collect something is inventing the ruling.
//
//  ── THE SEAL DOES NOT REFUSE THIS ────────────────────────────────────────
//  By design, and it is written down in AppSpec §9: the seal is
//  content-level, and a sealed note "may still be … deleted (recoverable via
//  restoreContainer)". No seal guard is written here, exactly as none is
//  written in the phone's door.
//

import AppKit
import Foundation
import SwiftUI
import VariorumCore

// MARK: - The confirm's value

/// What the dialog is asking about. **A VALUE the dialog PRESENTS**, never a
/// flag it reads back — 13l Act 2's item 2 is the whole argument for that
/// shape, and its rule is stated at `View.purgeConfirmDialog`: *a binding
/// setter must never clear state that an action's continuation will read
/// back.* SwiftUI writes `isPresented = false` synchronously inside the
/// button's own click handling, so an action closure that re-reads the
/// pending value finds nothing. Every confirm in this app rides
/// `presenting:` for that reason; this one is no exception.
struct NoteDeleteConfirm: Identifiable, Equatable {
    /// The notes the gesture named, in the order the surface listed them.
    let postIDs: [String]

    /// Stable across a re-render of the same ask.
    var id: String { postIDs.joined(separator: "|") }

    var title: String { RecoveryCopy.deleteNotesConfirmTitle(postIDs.count) }
    var detail: String { RecoveryCopy.deleteNotesConfirmDetail(postIDs.count) }
}

// MARK: - The act

/// **DELETE A NOTE — one road, four doors.**
@MainActor
enum NoteDeletion {
    /// Flush, delete, announce. Returns the receipt; refusals throw for the
    /// caller to word (the `TrashPutBack` / `TrashPurge` shape).
    ///
    /// **Flush FIRST, like every structural door.** `deleteContainer`
    /// cascades to the note's blocks and their takes; a refused flush that
    /// left typed bytes pending while the tombstone landed would strand them
    /// outside both the surface and the rows they belong to. `flushNow()` on a
    /// post nothing has opened is a no-op with nothing pending, so the library
    /// and pool rows — which routinely name notes that are not open at all —
    /// pay nothing for it (`AppSession.runCopying`'s own note).
    ///
    /// **A note that is ALREADY gone is skipped, not fatal.** The double-press
    /// and the second-window race both produce it, and refusing the whole
    /// gesture because one of five rows had already been deleted elsewhere
    /// would be a refusal about nothing. Anything else the operations layer
    /// refuses propagates and is spoken.
    static func run(session: AppSession, postIDs: [String]) async throws -> String {
        guard !postIDs.isEmpty else { return RecoveryCopy.notesAlreadyGone(0) }
        for id in postIDs {
            await session.autosave(forPost: id).flushNow()
        }
        let deleted = try await session.runner.run { ops -> Int in
            var landed = 0
            for id in postIDs {
                do {
                    try ops.deleteContainer(id)
                    landed += 1
                } catch OperationError.containerNotFound {
                    continue  // already gone — the double-press race
                }
            }
            return landed
        }
        // **THE SIGNAL, and it is a signal** (P-4): it says what happened, and
        // each window decides what that means for the panes it owns. Posted
        // after the writes land, so a listener that re-reads sees the truth.
        NotificationCenter.default.post(
            name: .variorumNotesDeleted, object: nil,
            userInfo: ["postIDs": postIDs])
        guard deleted > 0 else { return RecoveryCopy.notesAlreadyGone(postIDs.count) }
        return RecoveryCopy.movedToTrashReceipt(notes: deleted)
    }

    /// The doors' entry: run it, and SPEAK the outcome through the one
    /// status surface every window renders (AD-14 — mode- and
    /// surface-independent, which is exactly what a delete needs, since the
    /// surface that fired it may be the one that just went away).
    static func fire(session: AppSession, postIDs: [String]) {
        Task { @MainActor in
            do {
                session.status.speak(try await run(session: session, postIDs: postIDs))
            } catch {
                session.status.speak(DeletionRefusal.words(error, act: .delete))
            }
        }
    }
}

extension Notification.Name {
    /// **Notes have been tombstoned.** Every full window listens (not only
    /// the navigation target — this is not a claim, it is a fact each window
    /// must act on for its own panes), and the note-only window that shows
    /// one of them closes.
    static let variorumNotesDeleted = Notification.Name("variorumNotesDeleted")
}

// MARK: - The confirm's host

/// **THE NOTE-DELETE CONFIRM'S HOST — ONE PLACE, FOUR DOORS** (her ruling's
/// *"one wording, both doors"*, which four renderers make four).
///
/// It is a modifier rather than a `confirmationDialog` typed out at each door
/// for the reason the purge host is one: the WORDING and the SHAPE are the
/// thing that must not drift, and a pin can drive the shipping wiring here
/// while a surface's own `@State` is unreachable from outside.
///
/// It rides `presenting:` — see `NoteDeleteConfirm`'s doc for why that is the
/// only shape allowed in this codebase.
extension View {
    func deleteNoteConfirmDialog(
        _ pending: Binding<NoteDeleteConfirm?>,
        onConfirm: @escaping (NoteDeleteConfirm) -> Void
    ) -> some View {
        confirmationDialog(
            pending.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { pending.wrappedValue != nil },
                set: { presented in if !presented { pending.wrappedValue = nil } }),
            titleVisibility: .visible,
            presenting: pending.wrappedValue
        ) { confirm in
            Button("Delete", role: .destructive) {
                pending.wrappedValue = nil
                onConfirm(confirm)
            }
            Button("Cancel", role: .cancel) { pending.wrappedValue = nil }
        } message: { confirm in
            Text(confirm.detail)
        }
    }
}
