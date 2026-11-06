//
//  HistoryRequests.swift
//  Variorum (Mac)
//
//  The block's History & Lineage surface's REQUESTS and the facts its doors
//  read — moved here whole from the retired Block History panel's file
//  (`Features/Tray/BlockHistoryPane.swift`, VX-827 U3b): a hoist moves an
//  address, never a behaviour. `BlockHistoryRequest` grew `opening` (U3b).
//

import Foundation

/// **A CONFIRMED RESTORE'S LANDING** (VX-431, the VX-440 run — the plan's
/// Batch 2 design, item 4; her words on the ticket: restoring a long commit,
/// *"it's unclear which part came back (briefly highlight at least where it
/// starts)"*).
///
/// Posted on `CommandRouter.pendingRestoreLanding` by the pane once a restore
/// LANDED (the row's Restore or the read-in-full sheet's), and consumed by the
/// writing surface standing beside the pane — the detail's Write editor, or
/// the Takes board — which lands at the block's start and washes it with the
/// arrival flash's face (an OVERLAY, never a rendering attribute — P-8). A
/// SIGNAL, never a decision (P-4): each surface decides for itself whether it
/// shows the restored words, and a surface that does not (another take
/// rendered there, another mode, a host with no landing road) simply lets it
/// go. Consumed only on CHANGE by a surface already mounted — never at an
/// arrival — so a parcel nobody took is inert, and the router clears it with
/// its detail like the landings beside it.
nonisolated struct RestoreLanding: Equatable, Sendable, Identifiable {
    /// Each restore is its own landing — restoring the same words twice lands
    /// twice (an observed change is what a mounted surface hears).
    let id: UUID
    let postID: String
    let blockID: String
    /// The take that was restored — a surface lands only where it shows it.
    let variantID: String
    /// The words the take holds now — a surface lands once it SHOWS them
    /// (before that its layout is the old words', and the projection that
    /// brings them would end a landing made against the old ones).
    let text: String

    /// **How long a surface may wait for the restored words to arrive** — the
    /// store's own delivery, milliseconds in practice; past this the landing
    /// is dropped rather than haul the page somewhere seconds later.
    static let patience: TimeInterval = 2

    init(id: UUID = UUID(), postID: String, blockID: String, variantID: String, text: String) {
        self.id = id
        self.postID = postID
        self.blockID = blockID
        self.variantID = variantID
        self.text = text
    }
}

/// A surface's pending request to open the pane — the `TrayRequest` shape,
/// and for its reason: the doors that raise it live on view models and bars
/// while the panel lives in the post detail's inspector.
///
/// It carries the FOCUSED take because her ruling is that all the block's
/// takes are sectioned with *"the focused take's expanded"* — a pane that
/// forgot which take she was in would have to guess, and guessing is what
/// the request exists to prevent.
nonisolated struct BlockHistoryRequest: Identifiable, Hashable, Sendable {
    let postID: String
    let blockID: String
    var focusedVariantID: String?
    /// **Which face the surface opens on** (VX-827 U3b): the Commits face (every
    /// history door), or the Lineage face — "lineage ›", block ▾'s Lineage, and
    /// the ORIGIN door, which names the original to select (G2's ruling).
    var opening: HistoryOpening = .commits
    var id: String { "\(postID)#\(blockID)#\(focusedVariantID ?? "")#\(opening.key)" }
}

/// Where the block's History & Lineage surface opens (VX-827 U3b).
nonisolated enum HistoryOpening: Hashable, Sendable {
    case commits
    /// The Lineage face, with the member to select (nil = its own opening
    /// rule, `LineageFamily.opening`).
    case lineage(select: String?)

    var key: String {
        switch self {
        case .commits: return "commits"
        case .lineage(let select): return "lineage:\(select ?? "")"
        }
    }
}

/// **WHERE THE WRITING SURFACE'S CARET IS** (ledger row 33) — a FACT the
/// mounted surface reports, never a request.
///
/// It is the `BlockHistoryRequest`'s shape without being one, deliberately:
/// the two are different kinds of thing (one is "open this", the other is
/// "this is where I am"), and a fact that could be mistaken for a request
/// would invite a surface to open a panel by reporting a caret move.
///
/// Reported only when the block CHANGES, which is what keeps it cheap: a
/// caret walking within one paragraph writes nothing, so nothing observing it
/// re-renders at keystroke rate. **`utf16Offset` is the exception, and it is
/// deliberately not a signal** (the 2026-09-06 use-report round, 17o batch b —
/// her ruling U-20): the caret's place INSIDE the block is data a landing
/// READS at the moment it lands, never something a view watches, so the
/// router keeps it beside the observed identity rather than in it
/// (`CommandRouter.focusedBlock` has the whole argument).
nonisolated struct FocusedBlock: Hashable, Sendable {
    let postID: String
    let blockID: String
    var variantID: String?
    /// **Where the caret was inside the block, UTF-16** — nil means UNKNOWN
    /// (a surface that holds no caret: Blocks' row, the outline's card, an
    /// old two-field memory), which every landing spells "the block's start".
    /// Zero is a real place, not unknown. This is THE road a caret's offset
    /// travels on (`LandingTarget` carries none since 18l-b U4 — QUESTIONS
    /// #153; its field of this name was set by no production site).
    var utf16Offset: Int?
}
