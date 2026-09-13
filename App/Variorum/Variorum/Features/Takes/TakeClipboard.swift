//
//  TakeClipboard.swift
//  Variorum
//
//  Phase 13e, batch 3 (E6 — her A21, verbatim: *"keyboard shortcut for
//  copying all takes together to clipboard, or turning all takes into their
//  own blocks"*). This is the CLIPBOARD half, and it is deliberately ONE
//  brain rather than a per-surface copy: Write's caret block and a board's
//  focused card reach the same read, write the same bytes, and speak the
//  same sentence.
//
//  The FORMAT is not invented here. It is the app's own ratified export
//  shape (`Queries.blockTakes` — the shown take, then the labeled
//  "Alternates for this block" section), which is literally the format her
//  2026-07-25 intake note arrived in. Nothing is written to the store: this
//  is a projection read plus a pasteboard write, so a sealed note copies
//  exactly like an open one.
//

import AppKit
import VariorumCore

/// **`@MainActor` — ladder round A (A-5), a CLEANLINESS annotation, not a bug
/// fix.** The reviewer flagged the pasteboard write as running off the main
/// actor after `copyBlock`'s awaited read and labelled the finding itself
/// SPECULATIVE; no concrete failure was traceable — `NSPasteboard` is not
/// documented main-thread-only, both production doors (`TakesViewModel`,
/// `EditorViewModel`) and every pin already call in from the MainActor, and
/// nothing here touches a view. So the bug claim is dismissed under the
/// hallucination guard (no pin is owed, and one would have passed on both
/// sides), while the annotation is applied on its own merits: it states the
/// actor these callers already run on, so the hop off and back cannot be
/// introduced later by accident.
@MainActor
enum TakeClipboard {
    /// Where a copy lands. `.general` is the system clipboard; a NAMED
    /// destination is a pasteboard of the caller's own — which is how a pin
    /// drives the real door end to end without touching her clipboard. It
    /// exists as a Variorum type so the view models can carry a default
    /// without importing AppKit (the conductor knows no window server types).
    struct Destination {
        let pasteboard: NSPasteboard

        static let general = Destination(pasteboard: .general)

        static func named(_ name: String) -> Destination {
            Destination(pasteboard: NSPasteboard(name: NSPasteboard.Name(name)))
        }
    }

    /// What a copy answers — a message the caller speaks, so the two doors
    /// cannot word the same outcome differently.
    enum Outcome: Equatable {
        case copied(takes: Int)
        case nothingToCopy
        case failed(String)

        /// **WHETHER NOTHING HAPPENED** (the 18i ladder round 3, J43): a
        /// copy that landed is a RECEIPT — her confirmations setting governs
        /// it — while "no text to copy" and a failure are REFUSALS and always
        /// show (P-2). ONE predicate beside the message, so the two doors
        /// that speak this outcome cannot give the same sentence two classes.
        var isRefusal: Bool {
            if case .copied = self { return false }
            return true
        }

        var message: String {
            switch self {
            case .copied(let takes):
                return takes == 1
                    ? "Copied this block's take to the clipboard."
                    : "Copied \(takes) takes to the clipboard — the shown one first, "
                        + "then its alternates."
            case .nothingToCopy:
                return "This block has no text to copy."
            case .failed(let detail):
                return "Copy failed: \(detail)"
            }
        }
    }

    /// Reads the block's takes projection and writes it to `destination`.
    static func copyBlock(
        _ blockID: String, session: AppSession,
        to destination: Destination = .general
    ) async -> Outcome {
        let projection: (markdown: String, takeCount: Int)
        do {
            projection = try await session.database.read { db in
                try Queries.blockTakes(db, blockID: blockID)
            }
        } catch {
            return .failed(OpsRefusalCopy.message(for: error))
        }
        guard !projection.markdown.isEmpty else { return .nothingToCopy }
        write(projection.markdown, to: destination)
        return .copied(takes: projection.takeCount)
    }

    /// The pasteboard write itself — cleared then set as plain text, the one
    /// place the app puts prose on the clipboard.
    static func write(_ text: String, to destination: Destination = .general) {
        destination.pasteboard.clearContents()
        destination.pasteboard.setString(text, forType: .string)
    }
}
