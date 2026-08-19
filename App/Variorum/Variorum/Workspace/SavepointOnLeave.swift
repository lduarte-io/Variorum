//
//  SavepointOnLeave.swift
//  Variorum (Mac)
//
//  Phase 13j, J11 — **WHERE "CLOSE/LEAVE" ACTUALLY HOOKS.**
//
//  Her sitting-round-1 ruling: *"every editing session that changed a note
//  leaves one quiet savepoint per edited take at close/leave"*, after her
//  report that *"I haven't been seeing auto commits in the history… unless
//  you've been remembering to commit version history is kind of weak right
//  now."*
//
//  ── THE MAPPING, STATED ONCE ─────────────────────────────────────────────
//  A note is LEFT when it stops being shown by a window — and that is the
//  only definition used anywhere:
//
//  1. **navigating a pane away, closing the split, Open-Beside displacing a
//     pane** — `WorkspaceModel.reportingDepartures`, which wraps every
//     mutation of the shown set. `select` is the door every navigation
//     funnels through (its own contract, 13f batch 4), so this needs no
//     per-door instrumentation;
//  2. **a window closing** — `leaveEverythingShown`, from the two windows'
//     `onDisappear` (the full shell's panes; the note-only window's one
//     note);
//  3. **⌘Q** — `AppSession.autosave(forPost:)`'s existing quit registration,
//     which has covered every open post since 13b 1a;
//  4. **a quick note filing itself** — `QuickNotePad.take()`, the one body
//     its three triggers share.
//
//  All four call ONE entry, `AppSession.savepointOnLeaving`, and every rule
//  lives below it in `Operations.closeAutoCommit`. **No second lifecycle
//  mechanism** was added: liveness stays `PaneTextAuthority`'s inside a
//  surface and the per-post autosave registry's across surfaces; this reads
//  what the workspace already knows.
//
//  ── WHAT IS DELIBERATELY *NOT* A LEAVING ────────────────────────────────
//  · **Closing an Open-strip row** (the ✕). Its own contract says it "closes
//    a ROW and nothing else" — the pane keeps showing the note, so she has
//    not left it. The next real leaving covers it.
//  · **Moving focus between two panes.** Both notes are still on screen;
//    `reportingDepartures` compares SETS for exactly this reason.
//  · **Switching modes inside a note** (Write ▸ Takes ▸ Canvas…). The note is
//    still the open one; only its surface changed.
//
//  ── ONE ACCEPTED CONSEQUENCE, RECORDED ──────────────────────────────────
//  The shown set is PER WINDOW. With the same note open in two windows (a
//  note-only window beside the shell), leaving it in one savepoints it while
//  the other still shows it. The cost is bounded and benign — a savepoint of
//  text that genuinely changed, which is the feature — and the alternative
//  is a cross-window read on every navigation to save a quiet row that the
//  run collapse then folds away anyway.
//

import Foundation

enum SavepointOnLeave {
    /// Wire a window's workspace to the session. Idempotent, and safe to run
    /// from every window: each workspace is its own, and the closure holds
    /// only the session.
    static func wire(workspace: WorkspaceModel, session: AppSession) {
        workspace.onNotesLeft = { [weak session] ids in
            guard let session else { return }
            for id in ids {
                Task { @MainActor in await session.savepointOnLeaving(id) }
            }
        }
    }

    /// A window is going away: leave a savepoint for everything its panes
    /// were showing. Deliberately NOT routed through `onNotesLeft` — the
    /// workspace is not mutating (the whole thing is being torn down), and a
    /// teardown that depended on a mutation firing is the class of bug this
    /// phase's ladder found once already.
    static func windowClosing(workspace: WorkspaceModel, session: AppSession) {
        leaving(workspace.shownNoteIDs, session: session)
    }

    /// The note-only window's one note, and the shared spawn shape.
    static func leaving(_ noteIDs: [String], session: AppSession) {
        for id in noteIDs {
            // Detached from any view's lifetime on purpose: the view raising
            // this is already unmounting, and a `.task`-owned job would be
            // cancelled before the write landed (the `QuickNoteView`
            // onDisappear precedent).
            Task { @MainActor in await session.savepointOnLeaving(id) }
        }
    }
}
