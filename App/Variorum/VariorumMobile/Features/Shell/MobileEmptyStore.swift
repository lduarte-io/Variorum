//
//  MobileEmptyStore.swift
//  VariorumMobile
//
//  Pre-13u round, Act 0 — WHAT A FRESH INSTALL SAYS BEFORE HER FIRST WRITE.
//
//  **The rider that rides R-pre13u-1.** Her ruling's own recorded cost was
//  *"'empty app' on first open — which may read as broken without a little
//  empty-state copy"*, so the copy ships WITH the change rather than after
//  it: seeding on first write means a fresh install genuinely holds
//  nothing, and a screen holding nothing has to say what to do with it.
//
//  Two roads, because a fresh install has exactly two kinds of owner: a
//  new writer (start one) and a returning one on a new phone (sign in, and
//  everything arrives). Naming the second is what stops the emptiest,
//  most alarming case — *"my writing is gone"* — from being the reading.
//
//  ── COPY DOCTRINE ─────────────────────────────────────────────────────
//  Structure over prose, no explainer paragraphs: a state line, then the
//  door that changes it. FUNCTIONAL and **PROVISIONAL** — her voice pass
//  (13s) rewords all of it, exactly as the tutorial and starter-journal
//  copy waits for the same pass. Door names are DERIVED from the doors
//  themselves rather than retyped, so a renamed door cannot leave a
//  sentence pointing at a button that no longer says that.
//

import Foundation

enum MobileEmptyStoreCopy {

    /// The shelf, with no books. (Unchanged wording, moved here so both
    /// empty surfaces read from one home.)
    static let noBooks = "No books yet — Today's Entry starts your journal."

    /// The Library listing, with no notes and no search running.
    static let noNotes = "No notes yet."

    /// …and the door that ends it. Derived from the door's own title.
    static var noNotesDoor: String { "\(MobileNewNoteDoor.doorTitle) starts one." }

    /// The returning-owner road, named on both empty surfaces. The phone's
    /// sign-in lives in Settings under Sync (`SyncStatusRow`), which is
    /// what this points at — the whole reason the seed waits for a write
    /// is that taking this road first has to leave nothing behind.
    static let signIn = "Have an account? Settings ▸ Sync signs you in."
}
