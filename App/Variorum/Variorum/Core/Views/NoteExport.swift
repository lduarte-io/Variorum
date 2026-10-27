//
//  NoteExport.swift
//  Variorum (Mac)
//
//  VX-125 (the VX-439 run, A-439-1 + C-125-1) — EXPORT NOTE…: the note as a
//  `.md` file in the Variorum simple format. Her ask, verbatim-faithful:
//  "I do want a per note export in markdown with variorum simple format —
//  that's a super obvious part of V1 and will make the 'variorum simple
//  format can be in markdown' lesson super clear and obvious."
//
//  The file IS Copy full text's text, byte for byte: the ONE serializer
//  (`Queries.variorumDocumentText` — the `{t:"…"} {#tag}` header and the
//  takes-carrying body), so what she exports is exactly what File ▸ Import…
//  reads back. Its doors — File ▸ Export Note… (⌥⌘S), ⌘K, both `note ▾`
//  menus (and, at VX-425, the sidebar's note rows) — run THIS act, so they
//  cannot drift. It lives in the shared home beside `CopyForAI` for the
//  reason that one moved there: several features consume it.
//
//  Reads only; writes no row (the export pin). Archived and sealed notes
//  export like any other — reading is never a seal's business.
//

import AppKit
import Foundation
import GRDB  // Database in the one-pass read
import VariorumCore

@MainActor
enum NoteExport {
    /// What the door is asked to write, read in ONE pass: the document text
    /// and the name the save panel offers.
    struct Contents: Equatable, Sendable {
        let text: String
        let defaultFileName: String
    }

    /// The note's export, read off-main: Copy full text's text exactly, and
    /// the file name the ONE display brain gives the note (its title, else
    /// its date — what the masthead and the bulk export already call it).
    nonisolated static func contents(
        _ db: GRDB.Database, postID: String
    ) throws -> Contents {
        Contents(
            text: try Queries.variorumDocumentText(db, postID: postID),
            defaultFileName: defaultFileName(
                displayTitle: try Queries.noteDisplayTitle(db, id: postID)))
    }

    /// `<display title>.md` through the bulk export's own sanitize rule; a
    /// name the rule empties (all separators, say) falls back to the
    /// placeholder the Library's per-post doors use.
    nonisolated static func defaultFileName(displayTitle: String?) -> String {
        let base = Queries.sanitizedFilename(displayTitle ?? "")
        return "\(base.isEmpty ? DisplayTitle.placeholder : base).md"
    }

    /// **The act.** Flush the note's pending typing (so the file says what
    /// she sees), read the document, ask where — the save panel is the
    /// author-visible moment, and a cancel is her answer, not a refusal —
    /// write, and say so.
    ///
    /// `destination` is the tests' seam: every door passes nothing and gets
    /// the save panel; a pin hands a file URL (or nil, a cancel).
    static func export(
        postID: String, session: AppSession,
        destination: ((String) -> URL?)? = nil
    ) async {
        _ = await session.flushExistingAutosave(forPost: postID)
        let contents: Contents
        do {
            contents = try await session.database.read { db in
                try Self.contents(db, postID: postID)
            }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return
        }
        guard !contents.text.isEmpty else {
            session.status.refuse(nothingToExport)
            return
        }
        let choose = destination ?? { name in
            ExportPanels.saveFile(defaultName: name, type: .markdownFile)
        }
        guard let url = choose(contents.defaultFileName) else { return }
        do {
            try Data(contents.text.utf8).write(to: url, options: .atomic)
            session.status.receipt(exported(fileName: url.lastPathComponent))
        } catch {
            session.status.refuse(couldNotWrite(
                fileName: url.lastPathComponent, reason: error.localizedDescription))
        }
    }

    // MARK: - What it says (sentence case — her standing rule)

    /// The receipt says what happened (the WA-2 register: short enough for
    /// either voice's bar).
    nonisolated static func exported(fileName: String) -> String {
        "Exported \u{201C}\(fileName)\u{201D}."
    }

    /// Copy full text's empty-note refusal, in this door's verb.
    nonisolated static let nothingToExport =
        "Nothing to export \u{2014} this note has no text yet."

    /// A failed write says WHY (the VX-439 ladder's n-2): the system's own
    /// sentence follows — a full disk, a permission refusal and a vanished
    /// folder must not read the same.
    nonisolated static func couldNotWrite(fileName: String, reason: String) -> String {
        let why = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let tail = why.isEmpty ? "" : " " + (".!?".contains(why.last!) ? why : why + ".")
        return "Couldn\u{2019}t write \u{201C}\(fileName)\u{201D} \u{2014} the note is unchanged; "
            + "try another folder." + tail
    }
}
