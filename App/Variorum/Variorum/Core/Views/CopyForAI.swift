//
//  CopyForAI.swift
//  Variorum (Mac)
//
//  13n-a — COPY FOR AI (R-13n-11, the push gesture): the note in the
//  Variorum document format, onto the clipboard, for any chat anywhere. It
//  is the EXPORT side of the format, consumed by three features — Write's
//  `note ▾` menu (`CommitBar`), Takes' (`TakesBottomBar`) and ⌘K
//  (`ShellActions`) — so it lives in the SHARED home (ladder round 1, F8:
//  moved here from the import feature at its minting touch, byte for byte;
//  its two sentences moved with it).
//

import AppKit
import Foundation
import VariorumCore

/// The note in the Variorum document format, onto the clipboard
/// (`Queries.variorumDocumentText` — the ONE serializer the round-trip pins
/// hold). Flushes the note's pending typing first, so what is copied is what
/// she sees. Reads only; writes no row.
@MainActor
enum CopyForAI {
    /// `pasteboard` is the tests' seam (a private named board) — every door
    /// passes nothing and writes the general one.
    static func copy(
        postID: String, session: AppSession, pasteboard: NSPasteboard = .general
    ) async {
        _ = await session.flushExistingAutosave(forPost: postID)
        do {
            let text = try await session.database.read { db in
                try Queries.variorumDocumentText(db, postID: postID)
            }
            guard !text.isEmpty else {
                session.status.refuse(copyForAIEmpty)
                return
            }
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
            session.status.receipt(copiedForAI)
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    // MARK: - What it says (sentence case — her standing rule)

    static let copiedForAI =
        "Copied for AI \u{2014} the note with its takes and tags, ready to paste into any chat."
    static let copyForAIEmpty =
        "Nothing to copy \u{2014} this note has no text yet."
}
