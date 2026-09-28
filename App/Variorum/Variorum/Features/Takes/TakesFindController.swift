//
//  TakesFindController.swift
//  Variorum
//
//  18l-c UNIT U7 — SEARCH IN TAKES, find-only v1: the board's FIND, its own
//  component (P-9 — the `TakesStructureController` / `TakesChoreographer`
//  shape: the conductor owns one, lazily, and forwards nothing it does not
//  need). Her ruling R-18l-6 is the mandate; R-18l-9 (find-only — replace
//  stays Write's) and R-18l-10 (the off-scope indicator + expand on arrival)
//  are its frame; the design record is `notes/plans/phase-18l-c-navigation-
//  feel.md`'s U7 DESIGN BRIEF (ten decisions — this file is 3, 4, 5, 6, 8).
//
//  **What it owns:** the bar's state (presented, the query, the scope, the
//  field's hold on the keyboard), the matches (`TakesFindPlan`, over what the
//  board SHOWS — the authority's overlay included), the current match, and
//  the ONE road a step takes onto the board:
//
//  1. an off-scope match (a take the article is not showing) EXPANDS its
//     block's fan and pages it into view — nothing expands before she
//     navigates there, and an expanded fan stays open as she steps on
//     (decision 4, PROVISIONAL);
//  2. the match's pane takes the ring through the model's one focus door
//     (`TakesViewModel.focus(_:landingAt:)`) with the match SELECTED
//     (decision 6 — the answer to her ledger-row-7 report);
//  3. the page reveals the match's row through the one landing authority
//     (`landArticle(kind: .find)`, policy `.takesArticle` — decision 5; no
//     scroll mechanics of its own anywhere).
//
//  **Where the keyboard is** follows the Write bar's own convention (decision
//  1): ⏎ / ⇧⏎ in the find field step and leave the keyboard in the field, so
//  ⏎ keeps stepping (the landed take is live all the same — ring and
//  selection); ⌘G / ⇧⌘G from the board step and the landed take takes the
//  keyboard, so she can type at once; Esc closes the bar and hands the
//  keyboard back to the live take, her place kept.
//
//  **Cost (P1/P3):** a whole-note recount is a deliberate find act's —
//  opening, typing a query, flipping the scope, a step, and a settle while
//  the bar is open — and each rescans ONLY the takes whose text moved (the
//  per-take cache, the word-count cache's discipline). Nothing runs per
//  keystroke in a pane. The panes render from dictionary reads.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import VariorumCore

/// The session's one slot (`EditorRouter.takesFind` — decision 3).
struct TakesFindMemory: Equatable {
    var query = ""
    /// Her ruling R-18l-6: *"search only in chosen takes"* defaults ON.
    var chosenOnly = true
}

@MainActor
@Observable
final class TakesFindController {
    unowned let model: TakesViewModel

    init(model: TakesViewModel) {
        self.model = model
        let memory = model.session.editorRouter.takesFind
        query = memory.query
        chosenOnly = memory.chosenOnly
    }

    // MARK: - State (observed: the bar and the panes render from it)

    private(set) var isPresented = false
    private(set) var query: String
    /// Decision 3 — ON is each block's shown take only.
    private(set) var chosenOnly: Bool
    private(set) var matches: [TakesFindPlan.Match] = []
    private(set) var current: Int?
    private(set) var wrapped = false
    /// The find field holds the keyboard (reported by the bar).
    private(set) var fieldHoldsKeyboard = false
    /// Increments each time a door asks the bar to focus its field (⌘F).
    private(set) var fieldFocusRequests = 0
    private(set) var matchesByVariant: [String: [NSRange]] = [:]
    /// R-18l-10's marker counts — per block, matches on takes it is not
    /// showing (only with the toggle OFF).
    private(set) var offScopeCounts: [String: Int] = [:]
    /// The last step's (or Esc's) request, addressed to one take's panes.
    private(set) var request: (variantID: String, request: PaneFindFace.Request)?

    @ObservationIgnored private var requestToken = 0
    /// The per-take cache: a take's ranges for `cacheQuery`, kept with the
    /// text they were counted over, so a recount rescans only what moved.
    @ObservationIgnored private var cache: [String: (text: String, ranges: [NSRange])] = [:]
    @ObservationIgnored private var cacheQuery = ""
    /// Observation seam (the `slotRecountCount` precedent): takes actually
    /// RESCANNED — a pin asserts a settle does not rescan the whole note.
    @ObservationIgnored private(set) var takesRescanned = 0

    var scope: TakesFindPlan.Scope { chosenOnly ? .shownTakesOnly : .everyLiveTake }

    var currentMatch: TakesFindPlan.Match? {
        guard let current, matches.indices.contains(current) else { return nil }
        return matches[current]
    }

    /// The bar's count face (decisions 1 and 8).
    var countFace: String {
        TakesFindPlan.countFace(
            total: matches.count, current: current, wrapped: wrapped, query: query)
    }

    // MARK: - The doors

    /// ⌘F — the bar opens (or, already open, takes the keyboard again).
    /// Opening changes the article's VIEWPORT height (the bar sits above it),
    /// which is her hand ending a pending landing — the ⌘-pick banner's
    /// class (17q R3-1), armed at the door.
    func open() {
        if !isPresented {
            model.board.clearArticleLanding()
            isPresented = true
        }
        fieldFocusRequests += 1
        recount(keepingCurrent: true)
    }

    /// Esc / ✕ — the bar closes; the keyboard goes back to the live take with
    /// her place kept (decision 1). Its matches' paint goes with it.
    func close() {
        guard isPresented else { return }
        model.board.clearArticleLanding()  // the viewport grows back — her hand
        isPresented = false
        fieldHoldsKeyboard = false
        if let pane = model.focusedPane, model.isPaneLive(pane) {
            issueRequest(variantID: pane.variantID, select: nil, claimsKeyboard: true)
        }
    }

    func setQuery(_ text: String) {
        guard text != query else { return }
        query = text
        model.session.editorRouter.takesFind.query = text
        // A new search starts fresh — the count reads "M matches" until a
        // step (incremental navigation is OFF, the Write bar's ruled v1).
        current = nil
        wrapped = false
        recount()
    }

    /// Decision 3's toggle. The current match re-anchors to the first match
    /// at or after it in the new scope.
    func toggleScope() {
        chosenOnly.toggle()
        model.session.editorRouter.takesFind.chosenOnly = chosenOnly
        recount(keepingCurrent: true)
    }

    func fieldFocusChanged(_ focused: Bool) {
        if fieldHoldsKeyboard != focused { fieldHoldsKeyboard = focused }
    }

    /// ⏎ / ⌘G.
    func next() { step(forward: true) }

    /// ⇧⏎ / ⇧⌘G.
    func previous() { step(forward: false) }

    /// The board adopted a new projection (a settle, a sync arrival, an op):
    /// recount while the bar is open; the current match re-anchors.
    func projectionChanged() {
        guard isPresented, !query.isEmpty else { return }
        recount(keepingCurrent: true)
    }

    // MARK: - What the board renders from

    /// The find face one take's panes wear. Nil when there is nothing to say
    /// (the bar closed and no request outstanding for this take), so a pane
    /// off the find is byte-unchanged.
    func face(forVariant variantID: String, tokens: VoiceTokens) -> PaneFindFace? {
        let pending = request?.variantID == variantID ? request?.request : nil
        guard isPresented || pending != nil else { return nil }
        var face = PaneFindFace()
        if isPresented {
            face.matches = matchesByVariant[variantID] ?? []
            if let match = currentMatch, match.variantID == variantID {
                face.current = match.range
            }
            face.fieldHoldsKeyboard = fieldHoldsKeyboard
        }
        face.matchTint = Self.matchTint(tokens)
        face.currentTint = Self.currentTint(tokens)
        face.request = pending
        return face
    }

    /// R-18l-10's marker for a block — with the toggle OFF and the bar open.
    func offScopeCount(forBlock blockID: String) -> Int? {
        guard isPresented, !chosenOnly, let count = offScopeCounts[blockID], count > 0
        else { return nil }
        return count
    }

    /// The caret a FAN card takes on going live for a step — a fan card's
    /// pane otherwise lands where AppKit leaves it (its hosts pass no
    /// landing; `.leave` keeps every other road byte-unchanged).
    func fanCaretLanding(forVariant variantID: String) -> PaneCaretLanding {
        if case .select = model.caretLanding(forVariant: variantID) {
            return model.caretLanding(forVariant: variantID)
        }
        return .leave
    }

    /// The paint's two tints — the voice's accent, lighter for a match and
    /// stronger for the current one (decision 7's "stronger emphasis";
    /// VoiceTokens only — the colour is the palette's, PROVISIONAL taste).
    static func matchTint(_ tokens: VoiceTokens) -> NSColor {
        NSColor(tokens.accent).withAlphaComponent(0.22)
    }

    static func currentTint(_ tokens: VoiceTokens) -> NSColor {
        NSColor(tokens.accent).withAlphaComponent(0.5)
    }

    // MARK: - The step

    private func step(forward: Bool) {
        // Nothing to find: the door gives her the field rather than doing
        // nothing (P-2 — a door that cannot act says so, here by acting).
        guard !query.isEmpty else {
            open()
            return
        }
        recount(keepingCurrent: true)
        let origin: TakesFindPlan.Order?
        let strictly: Bool
        if let caret = liveCaret(forward: forward) {
            origin = caret
            strictly = !forward
        } else if let match = currentMatch {
            origin = match.order
            strictly = true
        } else {
            origin = nil
            strictly = true
        }
        guard let step = TakesFindPlan.step(
            from: origin, in: matches, forward: forward, strictly: strictly)
        else {
            current = nil
            wrapped = false
            return
        }
        current = step.index
        wrapped = step.wrapped
        land(matches[step.index])
    }

    /// Where the LIVE take's selection sits, as a reading position — the
    /// finder's own origin: a next resumes from the selection's END (so a
    /// selected match is stepped past, and a caret's own spot is included), a
    /// previous from its START. Nil when no pane is live, or the live pane's
    /// selection has not been reported (a fan card reports none) — the
    /// current match is the origin then.
    private func liveCaret(forward: Bool) -> TakesFindPlan.Order? {
        guard let pane = model.focusedPane, model.isPaneLive(pane),
              let selection = model.paneSelection, selection.variantID == pane.variantID,
              let slotIndex = model.projection.slots.firstIndex(where: { $0.blockID == pane.blockID })
        else { return nil }
        let slot = model.projection.slots[slotIndex]
        let shownID = model.resolvedTake(column: Self.mainColumn, slot: slot)?.variantID
        let takeIndex: Int
        if pane.variantID == shownID {
            takeIndex = 0
        } else {
            let others = (model.projection.fans[slot.blockID] ?? []).filter { $0.id != shownID }
            guard let index = others.firstIndex(where: { $0.id == pane.variantID }) else { return nil }
            takeIndex = index + 1
        }
        return TakesFindPlan.Order(
            slot: slotIndex, take: takeIndex,
            location: forward ? selection.range.upperBound : selection.range.location)
    }

    /// The ONE road a step takes onto the board (the header's three moves).
    private func land(_ match: TakesFindPlan.Match) {
        guard let slot = model.projection.slots.first(where: { $0.blockID == match.blockID })
        else { return }
        if !match.onShownTake {
            model.board.bloom(match.blockID)
            model.pageToReveal(blockID: match.blockID, variantID: match.variantID)
        }
        // A slot-split bloom REPLACES the article cell with the fan's cards,
        // so its shown take lives in the fan namespace there (`articleRow`'s
        // own branch).
        let splitBloomed = model.isBloomed(slot)
            && model.projection.fanStyle == .slotSplit && slot.hasFan
        let columnID = match.onShownTake && !splitBloomed
            ? TakesViewModel.takesMainColumnID : TakesViewModel.takesFanColumnID
        model.focus(
            TakesViewModel.PaneKey(
                columnID: columnID, blockID: match.blockID, variantID: match.variantID),
            landingAt: .select(match.range))
        issueRequest(
            variantID: match.variantID, select: match.range,
            claimsKeyboard: !fieldHoldsKeyboard)
        model.board.landArticle(on: match.placementID, kind: .find)
    }

    private func issueRequest(variantID: String, select: NSRange?, claimsKeyboard: Bool) {
        requestToken += 1
        request = (variantID, .init(token: requestToken, select: select, claimsKeyboard: claimsKeyboard))
    }

    // MARK: - The recount

    static let mainColumn = TakesColumn(id: TakesViewModel.takesMainColumnID, kind: .main)

    /// The note as the board SHOWS it — every slot's shown take and its fan's
    /// other live active takes, texts through the authority's overlay.
    private func boardSlots() -> [TakesFindPlan.Slot] {
        model.projection.slots.map { slot in
            let shown = model.resolvedTake(column: Self.mainColumn, slot: slot)
            let fan = model.projection.fans[slot.blockID] ?? []
            return TakesFindPlan.Slot(
                blockID: slot.blockID, placementID: slot.placementID,
                shown: shown.map { TakesFindPlan.Take(variantID: $0.variantID, text: $0.text) },
                others: fan.filter { $0.id != shown?.variantID }.map {
                    TakesFindPlan.Take(variantID: $0.id, text: model.liveText($0))
                })
        }
    }

    private func recount(keepingCurrent: Bool = false) {
        let old = keepingCurrent ? currentMatch : nil
        // An empty query finds nothing and scans nothing (decision 2: "empty
        // query = no matches, no residue").
        guard !query.isEmpty else {
            cache = [:]
            cacheQuery = ""
            if !matches.isEmpty { matches = [] }
            if current != nil { current = nil }
            if !matchesByVariant.isEmpty { matchesByVariant = [:] }
            if !offScopeCounts.isEmpty { offScopeCounts = [:] }
            return
        }
        if query != cacheQuery {
            cache = [:]
            cacheQuery = query
        }
        var kept: [String: (text: String, ranges: [NSRange])] = [:]
        let found = TakesFindPlan.matches(in: boardSlots(), scope: scope) { take in
            if let hit = cache[take.variantID], hit.text == take.text {
                kept[take.variantID] = hit
                return hit.ranges
            }
            takesRescanned += 1
            let ranges = TakesFindPlan.ranges(of: query, in: take.text)
            kept[take.variantID] = (take.text, ranges)
            return ranges
        }
        cache = kept
        if found != matches { matches = found }
        let anchored = keepingCurrent ? TakesFindPlan.reanchor(old, in: found) : nil
        if anchored != current { current = anchored }
        var byVariant: [String: [NSRange]] = [:]
        for match in found { byVariant[match.variantID, default: []].append(match.range) }
        if byVariant != matchesByVariant { matchesByVariant = byVariant }
        let counts = scope == .everyLiveTake ? TakesFindPlan.offScopeCounts(found) : [:]
        if counts != offScopeCounts { offScopeCounts = counts }
    }
}
