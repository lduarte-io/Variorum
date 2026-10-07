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
        /// **Copied — and the copy did NOT follow the screen, said out
        /// loud** (the batch-7 fix wave, cold review MAJOR 1). It is the
        /// callout corner below: the copy carries the note's SAVED takes
        /// while the surface is showing a peeked or lensed one. Losing a
        /// `> ` is visible in the pasted text; carrying a paragraph she did
        /// not choose is not — so the one road that cannot be seen is the
        /// one that has to speak (P-2's letter, and this batch's own new
        /// promise is exactly what makes silence wrong here).
        case copiedSavedTakes
        case nothingToCopy
        case failed(String)

        var message: String {
            switch self {
            case .copied:
                return "Copied this note to the clipboard."
            case .copiedSavedTakes:
                return "Copied this note to the clipboard — it has callout "
                    + "blocks, so the copy carries the takes saved in the "
                    + "note rather than the one on screen."
            case .nothingToCopy:
                return "This note has no text to copy."
            case .failed(let detail):
                return "Copy failed: \(detail)"
            }
        }
    }

    /// What a projection came back as: the text, and the ONE thing about it
    /// the receipt has to be able to say — whether the callout fence sent
    /// the copy to the stored road while the surface was showing something
    /// else. Two values rather than a bare `String` because the caller must
    /// not have to re-derive a fact this walk already knows.
    struct Projection: Equatable {
        let text: String
        /// True only where `displayed` was offered AND the note carries
        /// callout frames — the recorded corner, and nothing else.
        let usedSavedTakesInstead: Bool
    }

    /// The note's copyable Markdown: the export projection, plus the open
    /// tail when the caller says the tail is content — joined through the
    /// ONE join brain. Empty pieces are dropped before the join, the same
    /// discipline `renderedText` applies, so an empty note yields `""`
    /// rather than a stray separator.
    /// `nonisolated` because it runs INSIDE the reader pool's closure, off
    /// the main thread (P2) — it is a pure projection read and touches no
    /// UIKit.
    ///
    /// ── **M23 ≡ R15 — COPY FOLLOWS WHAT IS ON THE SCREEN** ──────────────
    ///
    /// Her ruling, verbatim: *"copy should follow what's on the screen."*
    /// With a take PEEKED or a LENS active, the surface is showing something
    /// other than the store's chosen, and the copy carries what it shows.
    ///
    /// **The rule's shape is the ruled one — ASK THE SURFACE WHAT IT IS
    /// DISPLAYING, never a second selection-derivation** (§31's exact
    /// wording). `displayed` is that answer, handed in by the caller from
    /// `model.slots`, which IS the surface's display: the takes controller's
    /// `overlay(_:)` swaps a peeked slot's variant and text before the VM
    /// ever sees the projection, and a lens activation drives the same
    /// primitive. Nothing here re-decides which take anything shows.
    ///
    /// **EMPTY `displayed` takes the road that shipped, verbatim** — so a
    /// note with no peek and no lens copies byte-identically to before, and
    /// that is a fact the caller can guarantee cheaply (`takes.peeks.isEmpty`)
    /// rather than a claim this function has to prove.
    ///
    /// ⚠️ **ONE RECORDED CORNER, and it is a fence collision rather than a
    /// design choice: a note that carries CALLOUT FRAMES takes the stored
    /// road instead.** `exportPost` maps a callout block to a blockquote
    /// through `Queries.exportMapped`, which is `internal` to VariorumCore —
    /// so this app cannot ask for "this text, mapped for that frame", and
    /// re-implementing the mapper here would FORK A CORE BRAIN, which
    /// MobileSoul §3 forbids outright. The honest fallback is the shipped
    /// behaviour (chosen takes), never a document whose framed blocks
    /// silently lose their `> ` while its plain ones follow the screen.
    ///
    /// **AND IT SAYS SO** (the batch-7 fix wave, cold review MAJOR 1). The
    /// two roads' costs are not symmetrical: a missing `> ` is visible in
    /// the pasted text, while the wrong take's prose reads perfectly and
    /// marks nothing — so the fallback is reported rather than taken
    /// quietly. `Projection.usedSavedTakesInstead` is that report, and the
    /// caller's receipt speaks it.
    ///
    /// **The fix is one word** — `public` on `Queries.exportMapped`, zero
    /// behaviour change — and it is a `Sources/` edit this batch is fenced
    /// out of; it lands with the #94 hoists at the post-13u merge (the seat
    /// handoff's deferral list names it). When it does, this branch and the
    /// sentence both go.
    nonisolated static func markdown(
        _ db: Database, postID: String, openTail: String = "",
        displayed: [String: String] = [:]
    ) throws -> Projection {
        var pieces: [String] = []
        var usedSavedTakesInstead = false
        let stored: String
        if displayed.isEmpty {
            // The shipped road, verbatim — guaranteed by WHICH FUNCTION
            // RUNS, never by two projections happening to agree.
            stored = try Queries.exportPost(db, postID: postID)
        } else if try Queries.blockPresentations(db, containerID: postID).isEmpty {
            stored = try displayedProjection(db, postID: postID, displayed: displayed)
        } else {
            stored = try Queries.exportPost(db, postID: postID)
            usedSavedTakesInstead = true
        }
        if !stored.isEmpty { pieces.append(stored) }
        if !openTail.isEmpty { pieces.append(openTail) }
        return Projection(
            text: Queries.joinRenderedTexts(pieces),
            usedSavedTakesInstead: usedSavedTakesInstead)
    }

    /// `exportPost`'s projection with the SURFACE's displayed text in place
    /// of each slot's stored chosen — same walk, same join brain, same
    /// drop-the-empties discipline. The callout fence lives at the caller
    /// above, where the outcome it produces is decided in one place.
    private nonisolated static func displayedProjection(
        _ db: Database, postID: String, displayed: [String: String]
    ) throws -> String {
        let pieces = try Queries.renderPost(db, containerID: postID)
            .map { displayed[$0.blockID] ?? $0.text ?? "" }
            .filter { !$0.isEmpty }
        return Queries.joinRenderedTexts(pieces)
    }

    /// Writes a prepared projection and answers what happened. A note with
    /// nothing in it copies NOTHING and says so — silently clearing her
    /// clipboard would be the worse outcome of the two (P-2's honest
    /// refusal, applied to a door that cannot act).
    static func copy(
        _ projection: Projection, to destination: MobileClipboard.Destination = .general
    ) -> Outcome {
        guard !projection.text.isEmpty else { return .nothingToCopy }
        MobileClipboard.write(projection.text, to: destination)
        return projection.usedSavedTakesInstead ? .copiedSavedTakes : .copied
    }
}
