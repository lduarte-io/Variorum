//
//  TrayFilter.swift
//  Variorum (Mac)
//
//  The use-report round, 18d batch 2 — **THIS NOTE'S TRAY, REORGANIZED**
//  (ledger row 34; her ruling U-9, verbatim: *"you should be able to select
//  if you want to see leaving, if you want to see blocks or takes under
//  leaving, and separetly if you want to see archived (archived v. leaving
//  should be top level, with block or takes as a filter under each one"*;
//  mockup figure D).
//
//  ── WHAT THIS FILE IS ────────────────────────────────────────────────────
//  The panel's CHOOSING, as a pure rule. The tray's three leaving
//  populations and its archived population are unchanged in what they are
//  (the queries, the ops and every Put back / Delete Now road are untouched
//  by this batch) — what changed is how they are chosen and labelled:
//
//    · ONE top-level choice — **Leaving** · **Archived** — carrying its count;
//    · ONE filter row shared by both views — **all · blocks · takes** — whose
//      counts follow the view;
//    · the "▸ N deleted takes" fold RETIRES. The filter is the fold, and it
//      is a fold you cannot fail to find: her complaint was that "6 deleted
//      takes" was a disclosure hiding under the block cards.
//
//  It is a `nonisolated enum` over plain values so the whole matrix is
//  pinnable without a window — six cells (2 views × 3 kinds), their counts,
//  and the reveal's landing view. The face reads it; nothing re-derives it.
//
//  ── WHY THE COUNTS COME FROM THE ROWS ────────────────────────────────────
//  `count` is defined AS the rendered rows' total, not as a parallel sum, so
//  a chip can never advertise a number the list does not hold (the
//  fold-that-hides-its-own-size defect, one level up). The pin holds exactly
//  that identity across every cell.
//

import Foundation
import VariorumCore

/// The tray's TOP-LEVEL choice (U-9: *"archived v. leaving should be top
/// level"*). Two views over the SAME panel — never two panels, never two
/// observations: one snapshot, chosen from.
nonisolated enum TrayView: String, CaseIterable, Sendable, Identifiable {
    /// Everything of this note on the 30-day clock: blocks it deleted, takes
    /// deleted on their own, and originals riding a family's countdown.
    case leaving
    /// Kept, no clock — this note's archived blocks.
    case archived

    var id: String { rawValue }
}

/// The filter UNDER each view (U-9: *"with block or takes as a filter under
/// each one"*). One row shared by both views, exactly as figure D draws it —
/// so the control does not change shape when the view does.
nonisolated enum TrayKind: String, CaseIterable, Sendable, Identifiable {
    case all
    /// Blocks — and, in the leaving view, the ORIGINALS riding a family's
    /// countdown, which are blocks and show here with their stranded-clock
    /// line unchanged (figure D's caption, the architect's shape).
    case blocks
    case takes

    var id: String { rawValue }
}

/// The panel's populations, as ONE value the pure rule works over — the
/// adopted (windowed) listings of `TrayViewModel`, in the order the panel
/// has always rendered them.
nonisolated struct TrayContents: Equatable, Sendable {
    /// Blocks individually deleted from this note.
    var deleted: [Queries.TrayItem] = []
    /// Preserved originals whose whole descendant family is in the Trash, so
    /// they ride its clock (her round-8b ruling — they are BLOCKS).
    var stranded: [Queries.PreservedOriginal] = []
    /// Takes deleted on their own, each on its own 30-day clock.
    var takes: [Queries.TrayTake] = []
    /// Archived blocks — kept, no clock.
    var archived: [Queries.TrayItem] = []
}

/// What one cell of the matrix renders, in render order.
nonisolated struct TrayRows: Equatable, Sendable {
    var blocks: [Queries.TrayItem] = []
    var stranded: [Queries.PreservedOriginal] = []
    var takes: [Queries.TrayTake] = []

    var total: Int { blocks.count + stranded.count + takes.count }
    var isEmpty: Bool { total == 0 }
}

/// **THE MATRIX** — two views, three kinds, six answers.
nonisolated enum TrayFilter {
    /// The rows one cell renders.
    ///
    /// The archived view holds BLOCKS only: an archived take lives among its
    /// block's archived takes (`restoreVariant`'s own receipt says so), never
    /// in the note's tray. Its `takes` cell is therefore always empty — and
    /// it is still offered, because the filter row is ONE row shared by both
    /// views (figure D) and a control that changes shape under you is worse
    /// than a cell that honestly says it holds nothing.
    static func rows(_ contents: TrayContents, view: TrayView, kind: TrayKind) -> TrayRows {
        switch view {
        case .leaving:
            switch kind {
            case .all:
                return TrayRows(
                    blocks: contents.deleted, stranded: contents.stranded,
                    takes: contents.takes)
            case .blocks:
                return TrayRows(blocks: contents.deleted, stranded: contents.stranded)
            case .takes:
                return TrayRows(takes: contents.takes)
            }
        case .archived:
            switch kind {
            case .all, .blocks:
                return TrayRows(blocks: contents.archived)
            case .takes:
                return TrayRows()
            }
        }
    }

    /// A chip's count — DEFINED as the rows that chip renders, so the number
    /// and the list can never disagree.
    static func count(_ contents: TrayContents, view: TrayView, kind: TrayKind) -> Int {
        rows(contents, view: view, kind: kind).total
    }

    /// A view's own count, on the segmented choice: everything that view
    /// holds, whatever the filter says (the filter narrows the list, never
    /// the view's size — the same reason the old fold carried its count).
    static func count(_ contents: TrayContents, view: TrayView) -> Int {
        count(contents, view: view, kind: .all)
    }

    /// **Which view holds a revealed BLOCK** (the lineage door's landing).
    ///
    /// The reveal marks a row, and a mark under the other tab is a mark she
    /// cannot see — so the panel opens on the view that holds it. Takes are
    /// revealed by no door (a reveal names a block), so this asks the two
    /// block populations only; nil means neither holds it, which is exactly
    /// the case `revealMissing` / `revealKeptInLineage` already word.
    static func viewHolding(_ blockID: String, in contents: TrayContents) -> TrayView? {
        if contents.deleted.contains(where: { $0.blockID == blockID })
            || contents.stranded.contains(where: { $0.blockID == blockID }) {
            return .leaving
        }
        if contents.archived.contains(where: { $0.blockID == blockID }) {
            return .archived
        }
        return nil
    }
}

/// **The last view and filter, remembered PER SESSION** (the batch's own
/// line; the `AppSession.mergeJoinMemory` precedent, and for its reason: one
/// `AppSession` per launch, so parallel test worlds stay independent and a
/// fresh launch opens on the tray's own default).
///
/// Not persisted: a fold's state is session UI state everywhere else in the
/// app (the takes disclosure this replaces was `@State`), and a tray that
/// remembered "takes only" across launches could greet her with an empty
/// panel over a note whose blocks are the thing leaving.
nonisolated struct TrayViewMemory: Equatable, Sendable {
    /// LEAVING first, `all` — what is counting down is what she opened the
    /// tray for (the panel's shipped ordering, kept as the default).
    var view: TrayView = .leaving
    var kind: TrayKind = .all

    init(view: TrayView = .leaving, kind: TrayKind = .all) {
        self.view = view
        self.kind = kind
    }
}

/// **THE CONTROL'S WORDS** — the enums mapped onto `RecoveryCopy`'s strings.
///
/// The words themselves live in `RecoveryCopy` (the recovery family's ONE
/// copy home, shared by both apps); the enums are the Mac face's, so the
/// mapping lives here rather than dragging a Mac-only type into a file the
/// phone compiles. Pure, so the whole control is pinnable without a window.
nonisolated enum TrayFilterFace {
    /// The segmented choice's two words.
    static func tab(_ view: TrayView) -> String {
        switch view {
        case .leaving: return RecoveryCopy.trayLeavingTab
        case .archived: return RecoveryCopy.trayArchivedTab
        }
    }

    /// A chip's words: its name, and its count where it has one. `all` never
    /// carries a count — the segment above it does (figure D).
    static func chip(_ kind: TrayKind, count: Int) -> String {
        RecoveryCopy.trayFilterChip(name(kind), count: kind == .all ? nil : count)
    }

    static func name(_ kind: TrayKind) -> String {
        switch kind {
        case .all: return RecoveryCopy.trayFilterAll
        case .blocks: return RecoveryCopy.trayFilterBlocks
        case .takes: return RecoveryCopy.trayFilterTakes
        }
    }

    /// The one line under the filter, per view.
    static func explainer(_ view: TrayView, home: ContainerKind) -> String {
        switch view {
        case .leaving: return RecoveryCopy.trayLeavingExplainer(home)
        case .archived: return RecoveryCopy.trayArchivedExplainer(home)
        }
    }

    /// What an EMPTY cell says — in the view's noun AND the filter's, so
    /// "nothing is on the clock" is never read off a filter she set herself.
    static func nothing(view: TrayView, kind: TrayKind, home: ContainerKind) -> String {
        switch (view, kind) {
        case (.leaving, .all): return RecoveryCopy.trayNothingLeaving(home)
        case (.leaving, .blocks): return RecoveryCopy.trayNoBlocksLeaving(home)
        case (.leaving, .takes): return RecoveryCopy.trayNoTakesLeaving(home)
        case (.archived, .all): return RecoveryCopy.trayNothingArchived(home)
        case (.archived, .blocks): return RecoveryCopy.trayNoBlocksArchived(home)
        case (.archived, .takes): return RecoveryCopy.trayNoTakesArchived
        }
    }

    /// The kind label a card wears (figure D). A take names its block
    /// through `Queries.tocHandle`, the ONE block-naming rule.
    static let blockKind = RecoveryCopy.trayKindBlock
    static let originalKind = RecoveryCopy.trayKindOriginal

    static func takeKind(_ take: Queries.TrayTake) -> String {
        RecoveryCopy.trayKindTake(
            inBlock: Queries.tocHandle(name: take.blockName, text: take.blockText))
    }
}
