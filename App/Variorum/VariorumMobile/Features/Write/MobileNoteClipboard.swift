//
//  MobileNoteClipboard.swift
//  VariorumMobile
//
//  Round 2, batch 2 — M3 ≡ R6. Her ask, verbatim: *"I also need a button
//  added at the top that allows me to copy everything i've written in a
//  particular note."*
//
//  WHAT IT COPIES — the note as Markdown: the chosen takes joined, callout
//  blocks mapped to blockquotes, the note's TITLE not included (a title is
//  the note's handle, not something she wrote inside it). That is not a
//  shape invented here: it IS the app's `.md` export projection,
//  `Queries.exportPost` (core), which the Mac's export doors already write
//  to disk. **No second joining rule exists in this file** — the one join
//  brain (`Queries.joinRenderedTexts`, the 2026-07-12 conditional join) is
//  what stitches the pieces, exactly as `renderedText` does, so a copy and
//  an export of the same note are byte-identical
//  (pinned). Nothing here writes a row: this is a projection read plus a
//  pasteboard write, which is why a SEALED note copies exactly like an open
//  one — the seal freezes authoring, and reading stays free under it.
//
//  THE OPEN TAIL is the one piece the store cannot supply. A paragraph she
//  is still typing at the end of the note has not crystallized into a block
//  yet, so it exists only on the surface — and "everything i've written"
//  plainly includes it. It rides as one more piece through the SAME join
//  brain, which is exactly the bytes it will export as the moment it mints,
//  and the caller decides whether the tail is content at all by asking the
//  app's own `mintableTail` rule (a whitespace-only tail is not writing).
//  Deliberately NOT done: minting the tail to make the store complete — a
//  copy is a read, and a read may not perform a structural act on the
//  paragraph she is mid-sentence in.
//
//  THE PASTEBOARD half is the phone's twin of the Mac's `TakeClipboard`
//  (Features/Takes/TakeClipboard.swift): the same injectable `Destination`
//  shape, so a pin drives the real door end to end without touching her
//  clipboard. `MobileClipboard` is deliberately the ONE place this app puts
//  prose on the pasteboard — the parity inventory's R11 (copy all takes)
//  composes it rather than opening a second writer.
//

import Foundation
import GRDB // Database in the projection read
import UIKit
import VariorumCore

/// The phone's ONE pasteboard writer — the `TakeClipboard.Destination`
/// shape, UIKit edition.
@MainActor
enum MobileClipboard {
    /// Where a copy lands. `.general` is the system clipboard; a NAMED
    /// destination is a pasteboard of the caller's own, which is how a pin
    /// drives the real door without writing to hers (and without tripping
    /// iOS's paste prompt, which only guards reads of the general board).
    struct Destination {
        let pasteboard: UIPasteboard

        static let general = Destination(pasteboard: .general)

        /// A private board for tests and probes; the caller owns removing
        /// it (`UIPasteboard.remove(withName:)`).
        static func named(_ name: String) -> Destination {
            Destination(pasteboard: UIPasteboard(
                name: UIPasteboard.Name(name), create: true) ?? .general)
        }
    }

    /// The write itself — plain text, the one place prose leaves the app
    /// for the clipboard.
    static func write(_ text: String, to destination: Destination = .general) {
        destination.pasteboard.string = text
    }
}

/// Copying a whole note: the projection, the outcome, and the words.
@MainActor
enum MobileNoteClipboard {
    /// What a copy answers — a sentence the caller speaks, so no future
    /// second door can word the same outcome differently.
    enum Outcome: Equatable {
        case copied
        case nothingToCopy
        case failed(String)

        var message: String {
            switch self {
            case .copied:
                return "Copied this note to the clipboard."
            case .nothingToCopy:
                return "This note has no text to copy."
            case .failed(let detail):
                return "Copy failed: \(detail)"
            }
        }
    }

    /// The note's copyable Markdown: the export projection, plus the open
    /// tail when the caller says the tail is content — joined through the
    /// ONE join brain. Empty pieces are dropped before the join, the same
    /// discipline `renderedText` applies, so an empty note yields `""`
    /// rather than a stray separator.
    /// `nonisolated` because it runs INSIDE the reader pool's closure, off
    /// the main thread (P2) — it is a pure projection read and touches no
    /// UIKit.
    nonisolated static func markdown(
        _ db: Database, postID: String, openTail: String = ""
    ) throws -> String {
        var pieces: [String] = []
        let stored = try Queries.exportPost(db, postID: postID)
        if !stored.isEmpty { pieces.append(stored) }
        if !openTail.isEmpty { pieces.append(openTail) }
        return Queries.joinRenderedTexts(pieces)
    }

    /// Writes a prepared projection and answers what happened. A note with
    /// nothing in it copies NOTHING and says so — silently clearing her
    /// clipboard would be the worse outcome of the two (P-2's honest
    /// refusal, applied to a door that cannot act).
    static func copy(
        _ markdown: String, to destination: MobileClipboard.Destination = .general
    ) -> Outcome {
        guard !markdown.isEmpty else { return .nothingToCopy }
        MobileClipboard.write(markdown, to: destination)
        return .copied
    }
}
