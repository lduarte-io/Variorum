//
//  TakesLensFilterController.swift
//  Variorum
//
//  **VX-170 — LENS-AWARE TAKES** (the VX-168 run's Unit 4). Her ask, from the
//  2026-10-11 editorial session: *"on the Takes page, expand just the takes
//  that belong to certain named lens columns … Takes has the better views for
//  reading them."* The ratified shape is `notes/plans/vx-170-lens-aware-
//  takes.md` (her rulings R-VX170-1…5, P-VX170-1); the rule itself is the
//  core's pure `LensTakeFilter` (the four forms, the expand set). This file is
//  the BOARD's half — its own component on the conductor (P-9, the
//  `TakesFindController` / `TakesStructureController` shape):
//
//  - **the filter** (R-VX170-5) — read from and written to the session's
//    per-note slot (`EditorRouter.takesShowFilters`), so it survives mode
//    flips and note switches and is gone on relaunch; only THE takes board
//    (`applies`) ever reads or writes it;
//  - **the evaluation** — the rule over the board's projection, computed at
//    adoption and at a filter change, never per render (P1: ∝ the note);
//  - **the row shapes** (R-VX170-2/3) — collapsed one-liners for the blocks
//    the filter does not name, the expand set for the ones it does, and the
//    block's own corner badge as its whole-fan door (the usual control);
//  - **the ring's two rules** (the R112 class — "the ring may only land on a
//    pane some surface renders"): a focus or landing onto a pane the filter
//    hides OPENS its block; her own filter change that hides the live pane
//    blurs it (flushed), because the view she asked for is exactly what shows;
//  - **the popover's rows and the words** (R-VX170-4) — the masthead-popover
//    idiom, the four forms with inline lens pickers.
//
//  Nothing here writes the store. A filter never changes what any take IS.
//

import Foundation
import Observation
import VariorumCore

/// How one article row draws under the `show ▾` filter.
enum TakesRowShape: Equatable {
    /// Today's row under today's bloom rule — no filter, or a block she opened
    /// whole through its corner badge (`expandedBlocks`).
    case ordinary
    /// R-VX170-2: a block the filter does not name — one line (its first line
    /// and the fan count), the note's map kept whole.
    case collapsed
    /// R-VX170-3: a block the filter names — its row, its bloom the EXPAND SET
    /// (the named takes plus the chosen one, in fan order). It blooms only when
    /// the set holds more than the shown take: a lone shown take IS the cell.
    case filtered([String])
}

@MainActor
@Observable
final class TakesLensFilterController {
    unowned let model: TakesViewModel

    init(model: TakesViewModel) {
        self.model = model
        stored = model.session.editorRouter.takesShowFilters[model.postID]
    }

    // MARK: - State

    /// The note's filter as the session remembers it (nil = all takes).
    private var stored: LensTakeFilter?
    /// The filter over the CURRENT projection — refreshed at adoption and at a
    /// filter change. nil while no filter applies.
    private(set) var evaluation: LensTakeFilter.Evaluation?
    /// The popover is open — a menu's life: never remembered.
    var menuOpen = false

    /// Only THE takes board filters (`landingEnabled` is set by `TakesBoardView`
    /// alone): the Write panel's embedded model and the Lenses board never read
    /// or write the slot, and never change a row.
    var applies: Bool { model.landingEnabled && model.host == .takes }

    /// The active filter, nil = all takes.
    var filter: LensTakeFilter? { applies ? stored : nil }

    /// The door renders only on a note that HAS a saved lens (PROVISIONAL
    /// P-VX168-U4-1): with none, every form could only match nothing.
    var offered: Bool { applies && (stored != nil || !model.projection.lenses.isEmpty) }

    // MARK: - The doors

    /// Applies a filter (nil = all takes) — her act from the popover.
    ///
    /// Applying a filter starts from the PLAIN page (every fan she had opened
    /// closes): a fan opened before would show that block whole whatever the
    /// filter says, and the view she asked for is exactly the filter's. A live
    /// pane the new view hides is blurred (its text flushed first by `blur`).
    func set(_ new: LensTakeFilter?) {
        guard applies, new != stored else { return }
        stored = new
        if let new {
            model.session.editorRouter.takesShowFilters[model.postID] = new
        } else {
            model.session.editorRouter.takesShowFilters.removeValue(forKey: model.postID)
        }
        // Her hand reshapes the page: a pending landing ends here (the
        // expansion doors' rule, 17p batch a's R1-2).
        model.board.clearArticleLanding()
        if new != nil { model.board.closeAllFans() }
        evaluation = new.map { model.projection.evaluate($0) }
        if let pane = model.focusedPane, !paneIsShown(pane) {
            model.blur()
        }
    }

    func toggleMenu() { menuOpen.toggle() }

    func closeMenu() {
        if menuOpen { menuOpen = false }
    }

    /// The conductor's adoption hook — runs right after `projection` moves and
    /// BEFORE the landings resolve against it. A filter naming a lens the note
    /// no longer holds resets to all takes (the dead-lens column precedent:
    /// the lens was the filter's subject). A store change that would hide the
    /// LIVE pane opens its block instead — content never vanishes from under
    /// the ring because something else moved.
    func projectionAdopted() {
        guard applies, let filter = stored else {
            evaluation = nil
            return
        }
        let live = Set(model.projection.lenses.map(\.id))
        guard filter.lensIDs.allSatisfy(live.contains) else {
            stored = nil
            evaluation = nil
            model.session.editorRouter.takesShowFilters.removeValue(forKey: model.postID)
            return
        }
        evaluation = model.projection.evaluate(filter)
        if let pane = model.focusedPane { reveal(pane) }
    }

    /// **The ring never lands on a hidden pane.** Every road that hands a pane
    /// the ring — a click (already shown), the entry landing, a reveal after a
    /// mint, a find step, a parked focus — passes through here first: a pane
    /// the filter hides opens its block whole (the one `bloom` door).
    func reveal(_ pane: TakesViewModel.PaneKey) {
        guard filter != nil, !paneIsShown(pane) else { return }
        model.board.bloom(pane.blockID)
    }

    // MARK: - The row shapes

    func rowShape(_ slot: Queries.RenderedBlock) -> TakesRowShape {
        guard filter != nil, let evaluation else { return .ordinary }
        if model.board.expandedBlocks.contains(slot.blockID) { return .ordinary }
        guard let set = evaluation.expanded[slot.blockID] else { return .collapsed }
        return .filtered(set)
    }

    /// The bloom rule under the filter: a collapsed row never blooms (follow-
    /// the-scroll included — the filter's map is not a place fans open by
    /// themselves); a filtered row blooms its expand set when there is more
    /// than the shown take to show; an opened row follows today's rule.
    func isBloomed(_ slot: Queries.RenderedBlock) -> Bool {
        switch rowShape(slot) {
        case .ordinary: model.board.isBloomed(slot)
        case .collapsed: false
        case .filtered(let set): set.count > 1
        }
    }

    /// The takes a bloom draws: the expand set on a filtered row, the whole
    /// active fan otherwise.
    func bloomTakes(_ slot: Queries.RenderedBlock) -> [Variant] {
        let fan = model.projection.fans[slot.blockID] ?? []
        guard case .filtered(let set) = rowShape(slot) else { return fan }
        return fan.filter { set.contains($0.id) }
    }

    /// Whether the board RENDERS this pane under the current shapes.
    func paneIsShown(_ pane: TakesViewModel.PaneKey) -> Bool {
        guard filter != nil,
              let slot = model.projection.slots.first(where: { $0.blockID == pane.blockID })
        else { return true }
        switch rowShape(slot) {
        case .ordinary:
            return true
        case .collapsed:
            return false
        case .filtered(let set):
            let bloomed = set.count > 1
            if pane.columnID == TakesViewModel.takesFanColumnID {
                return bloomed && set.contains(pane.variantID)
            }
            // The article cell — present unless a slot-split bloom replaced it
            // with the fan's cards (`articleRow`'s own branch).
            return !(bloomed && model.projection.fanStyle == .slotSplit && slot.hasFan)
        }
    }

    // MARK: - The faces (the masthead door, the chip, the zero line)

    /// The lens names the board can say, by id.
    private var lensNames: [String: String] {
        Dictionary(model.projection.lenses.map { ($0.id, $0.name) }, uniquingKeysWith: { a, _ in a })
    }

    /// The door's expression after "show: " (R-VX170-4).
    var label: [TakesShowCopy.Segment] {
        TakesShowCopy.label(filter, names: lensNames)
    }

    /// The quiet chip — "N of M blocks" — while a filter is active.
    var chip: String? {
        guard filter != nil, let evaluation else { return nil }
        return TakesShowCopy.chip(matches: evaluation.matchCount, blocks: evaluation.blockCount)
    }

    /// R-VX170-2's honest zero: one muted line in place when nothing matches.
    var zeroLine: [TakesShowCopy.Segment]? {
        guard let filter, let evaluation, evaluation.matchCount == 0,
              evaluation.blockCount > 0
        else { return nil }
        return TakesShowCopy.zeroLine(filter, names: lensNames)
    }

    /// The corner badge's words under the filter (nil = today's words).
    func badgeHelp(_ slot: Queries.RenderedBlock) -> String? {
        guard filter != nil, let evaluation else { return nil }
        return TakesShowCopy.badgeHelp(
            shape: rowShape(slot), matches: evaluation.matches(slot.blockID),
            fanCount: slot.activeVariantCount)
    }

    // MARK: - The popover's rows

    /// The popover's rows: "all takes", then the four forms with their
    /// operands (the active filter's where it names them).
    var menuRows: [TakesShowMenuRow] {
        TakesShowMenuRow.rows(active: filter, lenses: model.projection.lenses.map(\.id))
    }

    /// The lenses a row's picker offers at `index` — every lens of the note
    /// but the row's OTHER operand (a two-lens form never names one lens twice).
    func pickerLenses(_ row: TakesShowMenuRow, at index: Int) -> [(id: String, name: String)] {
        let other = row.operands.count == 2 ? row.operands[1 - index] : nil
        return model.projection.lenses
            .filter { $0.id != other }
            .map { ($0.id, $0.name) }
    }

    func name(ofLens id: String) -> String { lensNames[id] ?? "" }

    /// A row's words pressed: its filter applies and the popover closes (the
    /// order popover's pick).
    func choose(_ row: TakesShowMenuRow) {
        guard row.enabled else { return }
        set(row.filter)
        menuOpen = false
    }

    /// An operand picked in a row: that form applies with the new lens, and the
    /// popover stays open (the expression may want its other operand too).
    func pick(_ lensID: String, at index: Int, in row: TakesShowMenuRow) {
        guard let filter = row.picking(lensID, at: index) else { return }
        set(filter)
    }
}

// MARK: - The popover's rows (pure)

struct TakesShowMenuRow: Identifiable, Equatable {
    /// nil = "all takes".
    let form: LensTakeFilter.Form?
    /// The lenses the row shows in its pickers (a form's operand count, or
    /// fewer when the note cannot fill it — then the row is inert).
    let operands: [String]
    let selected: Bool
    let enabled: Bool

    var id: String { form.map { "\($0)" } ?? "all" }

    /// The filter this row applies (nil = all takes, or an inert row's nothing).
    var filter: LensTakeFilter? {
        guard let form else { return nil }
        return LensTakeFilter(form: form, lenses: operands)
    }

    /// The row's filter with `lensID` at `index`.
    func picking(_ lensID: String, at index: Int) -> LensTakeFilter? {
        guard let form, operands.indices.contains(index) else { return nil }
        var lenses = operands
        lenses[index] = lensID
        return LensTakeFilter(form: form, lenses: lenses)
    }

    /// The rows for a note with `lenses` (in the note's stable order) under the
    /// `active` filter. A form's operands carry the active filter's lenses
    /// where they fit (first → first, second → second), else the note's first
    /// lenses — so switching forms keeps the lenses she was looking through. A
    /// two-lens form on a one-lens note is inert (P-2: it could only match
    /// nothing).
    static func rows(active: LensTakeFilter?, lenses: [String]) -> [TakesShowMenuRow] {
        let live = Set(lenses)
        let activeLenses = (active?.lensIDs ?? []).filter(live.contains)
        let first = activeLenses.first ?? lenses.first
        var result = [TakesShowMenuRow(
            form: nil, operands: [], selected: active == nil, enabled: true)]
        for form in LensTakeFilter.Form.allCases {
            var operands: [String] = []
            if let first {
                operands.append(first)
                if form.lensCount == 2 {
                    let carried = activeLenses.count == 2 ? activeLenses[1] : nil
                    if let second = (carried.flatMap { $0 != first ? $0 : nil })
                        ?? lenses.first(where: { $0 != first }) {
                        operands.append(second)
                    }
                }
            }
            result.append(TakesShowMenuRow(
                form: form,
                operands: operands,
                selected: active?.form == form,
                enabled: operands.count == form.lensCount))
        }
        return result
    }
}

// MARK: - The words (pure; PROVISIONAL — her copy pass, P-VX168-U4-6)

enum TakesShowCopy {
    /// A run of words: app chrome (voiced — `chromeLabel` may fold its case) or
    /// a lens's NAME (hers, drawn verbatim — the chip-prose rule of
    /// `VoicedChip.content`).
    enum Segment: Equatable {
        case words(String)
        case name(String)
    }

    /// The door reads "show: " + this + " ▾" (R-VX170-4: resting "all takes";
    /// active, the expression in words — her example *"show: claude's cut
    /// disagrees with chosen"*).
    static func label(_ filter: LensTakeFilter?, names: [String: String]) -> [Segment] {
        guard let filter else { return [.words("all takes")] }
        func n(_ id: String) -> Segment { .name(names[id] ?? "") }
        switch filter {
        case .inLens(let x):
            return [.words("in "), n(x)]
        case .inLensNotIn(let a, let b):
            return [.words("in "), n(a), .words(", not in "), n(b)]
        case .disagree(let x, let y):
            return [n(x), .words(" disagrees with "), n(y)]
        case .disagreeWithChosen(let x):
            return [n(x), .words(" disagrees with chosen")]
        }
    }

    /// The popover's row for a form: its words with `nil` where a picker
    /// stands (the last form's fixed operand is "the chosen takes").
    static func rowWords(_ form: LensTakeFilter.Form) -> [String?] {
        switch form {
        case .inLens: ["in ", nil]
        case .inLensNotIn: ["in ", nil, ", not in ", nil]
        case .disagree: [nil, " disagrees with ", nil]
        case .disagreeWithChosen: [nil, " disagrees with the chosen takes"]
        }
    }

    static let allTakes = "all takes"

    /// The quiet chip — "N of M blocks" (R-VX170-2's honest counts).
    static func chip(matches: Int, blocks: Int) -> String {
        "\(matches) of \(blocks) block\(blocks == 1 ? "" : "s")"
    }

    static let chipHelp =
        "Takes is showing only the blocks this filter names — show ▾ › all takes shows every block again"

    /// R-VX170-2: a zero-match filter says so in place, in one muted line —
    /// the disagree forms in the shape's own words (*"no blocks match — X and
    /// Y agree everywhere"*).
    static func zeroLine(_ filter: LensTakeFilter, names: [String: String]) -> [Segment] {
        func q(_ id: String) -> Segment { .name("\u{201C}\(names[id] ?? "")\u{201D}") }
        switch filter {
        case .inLens(let x):
            return [.words("No blocks match — "), q(x), .words(" picks no take in this note.")]
        case .inLensNotIn(let a, let b):
            return [.words("No blocks match — wherever "), q(a), .words(" picks a take, "), q(b),
                    .words(" picks one too.")]
        case .disagree(let x, let y):
            return [.words("No blocks match — "), q(x), .words(" and "), q(y),
                    .words(" agree everywhere.")]
        case .disagreeWithChosen(let x):
            return [.words("No blocks match — "), q(x),
                    .words(" agrees with the chosen takes everywhere.")]
        }
    }

    /// The corner badge's help under a filter — the block's whole-fan door
    /// (her "the rest of the fan stays behind its usual control").
    static func badgeHelp(shape: TakesRowShape, matches: Bool, fanCount: Int) -> String {
        let all = fanCount > 1 ? "all \(fanCount) takes" : "its takes"
        switch shape {
        case .collapsed:
            return "Open this block whole — its text and \(all) (the filter doesn't name it)"
        case .filtered:
            return "Show \(all) — the filter shows the ones it names, beside the chosen one"
        case .ordinary:
            return matches
                ? "Back to the takes the filter names"
                : "Fold this block back to its one line"
        }
    }

    /// A collapsed row's excerpt: the shown take's FIRST LINE that says
    /// anything (R-VX170-2's "first-line excerpt"), nil when the block is empty
    /// or whitespace alone.
    static func firstLine(_ text: String) -> String? {
        for line in text.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { return trimmed }
        }
        return nil
    }

    static let emptyBlock = "(empty block)"
}
