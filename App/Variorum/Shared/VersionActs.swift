//
//  VersionActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  **THE VERSIONS FAMILY'S ACTS — ONE DECISION LAYER** (the post-13l polish
//  round, ledger rows 16 and 23), on `RecoveryActs`' shape and for its reason:
//  the DECISION is shared (flush first; which receipt is true; which refusal a
//  door speaks), the VOICE and the STATE are each surface's own.
//
//  **FLUSH FIRST is the load-bearing one, and it is not optional.** The editor
//  debounces autosaves, so a version saved while a keystroke is still pending
//  would be a moment missing the words that summoned it — and the RESTORE's
//  save-of-now would be worse, because the restore then deletes the blocks
//  those bytes belonged to. Every door here goes through the flush, which is
//  why the doors do not each get to remember it (the `NoteDeletion` precedent,
//  and its EXISTING-ONLY entry: a note nothing has opened has nothing pending
//  and must not mint a coordinator for it — the 13l L-d growth class).
//
//  **…AND THE FLUSH'S OUTCOME IS CONSULTED** (VM-5 whole-round pass, MINOR 4).
//  The flush used to RUN and never be asked whether it landed: on a refused
//  flush (bytes pending on a take a remote lock froze — the coordinator keeps
//  them) the save minted a moment WITHOUT those bytes and said "Saved", and
//  the restore's save-of-now missed them before taking their blocks. Exactly
//  the failure the paragraph above names. Both acts now refuse, before
//  anything is written, in the sibling doors' standing words
//  (`OpsRefusalCopy.unsavedChanges` — `deleteNote`/`lockNote`'s contract).
//

import Foundation
import VariorumCore

@MainActor
enum VersionActs {
    /// The family's own refusal, for the case where NOTHING was attempted:
    /// the note's pending bytes could not be written, so a moment of it now
    /// would be missing them. (`RecoveryRefusal`'s shape — an operation never
    /// ran, so this is not an `OperationError`.)
    enum Refusal: Error, Equatable {
        case unsavedChanges
    }

    /// **⌘⇧S — save the whole note as it is.** Returns the receipt; refusals
    /// throw for the caller to word.
    @discardableResult
    static func save(session: AppSession, postID: String) async throws -> String {
        guard await session.flushExistingAutosave(forPost: postID) else {
            throw Refusal.unsavedChanges
        }
        _ = try await session.runner.run { ops in
            try ops.saveNoteVersion(postID)
        }
        return VersionsPath.saved
    }

    /// **RESTORE — the note becomes its past, keeping its identity.** The op
    /// saves the moment of NOW inside its own transaction; the flush is what
    /// makes that moment complete — so a flush that could not land refuses
    /// the restore before the op runs (nothing is saved, nothing is taken).
    @discardableResult
    static func restore(
        session: AppSession, postID: String, versionID: String
    ) async throws -> String {
        guard await session.flushExistingAutosave(forPost: postID) else {
            throw Refusal.unsavedChanges
        }
        _ = try await session.runner.run { ops in
            try ops.restoreNoteVersion(postID, from: versionID)
        }
        return VersionsPath.restored
    }

    /// **PROMOTE — the moment becomes a note of its own, forever.** No flush:
    /// a version is sealed and archived, so nothing is pending in it.
    @discardableResult
    static func promote(
        session: AppSession, postID: String, versionID: String
    ) async throws -> String {
        try await session.runner.run { ops in
            try ops.promoteNoteVersion(versionID, of: postID)
        }
        return VersionsPath.promoted
    }

    /// **DELETE one moment** — the ordinary move-to-Trash road (FOUND-ITEM 1,
    /// ratified: *"agree that deleting a single version from the listing
    /// should go into trash for 30 days"*). The instant-hard-delete
    /// alternative was weighed and declined by derivation: a moment is
    /// UNRECAPTURABLE, unlike the restore's outgoing blocks, which had just
    /// been saved.
    @discardableResult
    static func delete(session: AppSession, versionID: String) async throws -> String {
        try await session.runner.run { ops in
            try ops.deleteContainer(versionID)
        }
        return VersionsPath.deleted
    }

    /// **What a restore would take that no version holds** — read at ASK time,
    /// for `versionCount`'s reason below: a confirm is a pause, and the pause
    /// is about the note as it IS, not as a listing remembered it.
    ///
    /// The answer is a property of the NOTE (its outgoing blocks), not of the
    /// moment being restored, so one read serves whichever row she pressed.
    /// A read that cannot answer costs nothing rather than blocking the ask —
    /// the same `?? 0` the count below has always taken, and for the same
    /// reason: a confirm must still open.
    static func restoreCost(
        session: AppSession, postID: String
    ) async -> Queries.RestoreCost {
        (try? await session.database.read { db in
            try Queries.restoreCost(db, of: postID)
        }) ?? .none
    }

    /// **How many moments go with a note** — read at ASK time, so the confirm's
    /// one honest line is about the note as it is rather than as a listing
    /// remembered it (the R3-1 lesson; a confirm is a pause).
    static func versionCount(session: AppSession, postIDs: [String]) async -> Int {
        guard !postIDs.isEmpty else { return 0 }
        return (try? await session.database.read { db in
            try postIDs.reduce(0) { $0 + (try Queries.noteVersionIDs(db, of: $1).count) }
        }) ?? 0
    }

    /// The refusals, in the recovery family's own voice.
    ///
    /// **`seal:` is the platform's own note-seal door words, and it is
    /// REQUIRED** (VM-5 whole-round pass, MINOR 3's rider). This file is a
    /// shared home both apps compile, so the seal arm cannot name either
    /// app's door itself — it read *"This note is marked complete — unseal it
    /// to restore a version."*, the Mac's verb rendered on the phone, whose
    /// button says Unlock Note. It now composes the ONE sealed-note sentence
    /// (`SealedNoteCopy`, QUESTIONS #159 (a)) with the words each caller's
    /// own target supplies (`.mac` / `.phone`). No default, on purpose: a
    /// default would make one platform's words silently the other's — each
    /// door decides.
    static func words(_ error: Error, seal: SealedNoteCopy.Words) -> String {
        if let refusal = error as? Refusal {
            switch refusal {
            case .unsavedChanges: return OpsRefusalCopy.unsavedChanges
            }
        }
        guard let error = error as? OperationError else {
            return DeletionRefusal.fallback(error)
        }
        switch error {
        case .notVersionHistory:
            return "That isn't one of this note's saved versions any more."
        // Only `restoreNoteVersion` raises this in the family (a SEALED note
        // may be SAVED — reading is not authoring; the op's own doc), so the
        // act clause names the restore.
        case .lockedPost:
            return SealedNoteCopy.sentence(act: "restore a version", words: seal)
        case .postHasNoBlocks:
            return "There's nothing in this note to save a version of yet."
        case .containerNotFound:
            return "That version is already gone."
        default:
            return DeletionRefusal.words(error)
        }
    }
}
