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

    /// **The saved versions that go with them** (the post-13l polish round,
    /// ledger row 23 — V2, ratified: *"I agree it should auto delete versions
    /// and not ask for a confirmation dialog"*).
    ///
    /// Versions ARE the note's past, so they ride its deletion — the operation
    /// takes them, on the same stamp, whichever door fired. What the CONFIRM
    /// owes is **one honest line**, not a second question: a mid-delete dialog
    /// nobody can answer well is friction, and the keep road is restoring the
    /// version live before, or Put back within the window after.
    ///
    /// Read at ASK time through `NoteDeletion.ask` (a confirm is a pause and a
    /// listing is a projection — the R3-1 lesson); zero means the line is
    /// absent, so every empty-versions note reads exactly as it did.
    var versionCount: Int = 0

    /// Stable across a re-render of the same ask.
    var id: String { postIDs.joined(separator: "|") }

    var title: String { RecoveryCopy.deleteNotesConfirmTitle(postIDs.count) }
    var detail: String {
        let base = RecoveryCopy.deleteNotesConfirmDetail(postIDs.count)
        guard let rider = VersionsPath.versionsGoWithIt(versionCount) else { return base }
        return base + " " + rider
    }
}

// MARK: - The act

/// **DELETE A NOTE — one road, four doors.**
@MainActor
enum NoteDeletion {
    /// **WHAT THE ACT SAID, AND WHETHER ANYTHING HAPPENED** (the 18i ladder
    /// round 1's BLOCKER — J29). This door has FOUR outcomes and only one of
    /// them is a receipt: the other three report that nothing happened (the
    /// empty gesture, the scraps kind fence, and the race where every named
    /// note was already tombstoned), which is a REFUSAL's voice — the copy's
    /// own doc says so at `RecoveryCopy.notesAlreadyGone`, and P-2 says she
    /// must see it whatever her confirmations setting is. It matters most
    /// exactly here: none of this act's four doors mounts a bottom bar, so a
    /// refusal routed as a receipt is invisible under her own default.
    ///
    /// The shape is `SplitAtNewlinesCopy.acted`'s — ONE discriminator, one
    /// home, carried beside the words rather than re-derived by reading them.
    struct Report {
        let text: String
        /// True when NOTHING happened. `fire` routes on it; `run` drops it.
        let isRefusal: Bool
    }

    /// Flush, delete, announce. Returns **the words only** — and three of the
    /// four endings are REFUSALS, so a caller that routes this to the status
    /// centre must use `report(…)` and `say(_:refusing:)`, never `receipt(…)`
    /// (the round-1 BLOCKER was exactly that misreading, and this line said
    /// "returns the receipt" until the round-2 ladder caught it still
    /// standing). Operation failures still throw for the caller to word (the
    /// `TrashPutBack` / `TrashPurge` shape).
    ///
    /// **Kept byte-identical in name and return type** (the 3C parity
    /// pattern) when J29 gave the act its discriminator: every shipped pin
    /// over this function and `LibraryViewModel.delete`, which wants the
    /// words and nothing else, compile and pass unmodified.
    static func run(session: AppSession, postIDs: [String]) async throws -> String {
        try await report(session: session, postIDs: postIDs).text
    }

    /// The act itself — the same body this file has always had, now saying
    /// which of its four endings it reached.
    ///
    /// **Flush FIRST, like every structural door.** `deleteContainer`
    /// cascades to the note's blocks and their takes; a refused flush that
    /// left typed bytes pending while the tombstone landed would strand them
    /// outside both the surface and the rows they belong to.
    ///
    /// **Through the EXISTING-ONLY entry** (13l, the ladder's LR-MINOR-2): a
    /// post nothing has opened has nothing pending, so `autosave(forPost:)`'s
    /// minting arm bought this act nothing — and cost it a permanent registry
    /// entry plus a ⌘Q closure PER DELETED NOTE, for notes that were never
    /// open. That is the L-d growth class, reintroduced by exactly the doors
    /// most likely to name a never-opened note: a Library row, or fifty of
    /// them under ⌘-click multi-select. The paragraph this replaced said the
    /// rows "pay nothing for it", which was true of the flush and false of
    /// everything around it.
    ///
    /// **A note that is ALREADY gone is skipped, not fatal.** The double-press
    /// and the second-window race both produce it, and refusing the whole
    /// gesture because one of five rows had already been deleted elsewhere
    /// would be a refusal about nothing. Anything else the operations layer
    /// refuses propagates and is spoken.
    static func report(session: AppSession, postIDs: [String]) async throws -> Report {
        guard !postIDs.isEmpty else {
            return Report(text: RecoveryCopy.notesAlreadyGone(0), isRefusal: true)
        }
        // **THE KIND FENCE** (13l Act 7 — the 8d walk; the mechanism and the
        // 28 lost scraps are written at `RecoveryCopy.notADeletableNote`).
        // `deleteContainer` has no kind guard, and the scraps editor renders
        // this act's door with the POOL's id, so the one gesture tombstoned a
        // container the Trash cannot list and no door can restore. Read the
        // kinds BEFORE the flush: a pool must not even have its buffers
        // flushed on the way to a delete that must not happen.
        //
        // A missing or already-tombstoned container has no header and stays
        // IN the list on purpose — `deleteContainer` throws
        // `containerNotFound` for it below, which is the already-gone road
        // this act has always spoken.
        let notes = try await session.database.read { db in
            try postIDs.filter { id in
                try Queries.containerHeader(db, containerID: id)?.kind != .pool
            }
        }
        guard !notes.isEmpty else {
            return Report(text: RecoveryCopy.notADeletableNote, isRefusal: true)
        }
        let postIDs = notes
        for id in postIDs {
            await session.flushExistingAutosave(forPost: id)
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
        guard deleted > 0 else {
            return Report(
                text: RecoveryCopy.notesAlreadyGone(postIDs.count), isRefusal: true)
        }
        return Report(
            text: RecoveryCopy.movedToTrashReceipt(notes: deleted), isRefusal: false)
    }

    /// **THE ASK, with its version count read at ask time** (V2's one honest
    /// line). Every door raises its confirm through here, so none of them has
    /// to remember that a note's past goes with it.
    static func ask(session: AppSession, postIDs: [String]) async -> NoteDeleteConfirm {
        NoteDeleteConfirm(
            postIDs: postIDs,
            versionCount: await VersionActs.versionCount(
                session: session, postIDs: postIDs))
    }

    /// The doors' entry: run it, and SPEAK the outcome through the one
    /// status surface every window renders (AD-14 — mode- and
    /// surface-independent, which is exactly what a delete needs, since the
    /// surface that fired it may be the one that just went away).
    static func fire(session: AppSession, postIDs: [String]) {
        Task { @MainActor in
            do {
                // J29: the outcome's own class — three of the four endings
                // report that nothing happened, and a refusal always shows.
                let outcome = try await report(session: session, postIDs: postIDs)
                session.status.say(outcome.text, refusing: outcome.isRefusal)
            } catch {
                session.status.refuse(DeletionRefusal.words(error, act: .delete))
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
