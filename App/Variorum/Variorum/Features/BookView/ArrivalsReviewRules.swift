//
//  ArrivalsReviewRules.swift
//  Variorum
//
//  VX-821 (the VX-808 run, Unit B3 — R-808-5) — THE REVIEW AREA'S RULES, pure
//  so pins read them (the `NoteRowSelection` lesson: a decision made inside a
//  gesture closure is a door nothing can reach):
//
//  · `ArrivalsSelection` — what is picked and which row the keyboard walks:
//    click / ⌘ toggle / ⇧ range through the Library's ONE brain
//    (`NoteRowSelection`), ⌘A, the walked row, ↑ ↓ walk, ⇧↑ ⇧↓ extend, and
//    the prune that keeps the pick to what is listed (the Trash's rule: the
//    rows a bulk act could not move stay picked, so the retry is one press)
//    while the walked row keeps its PLACE (judge one and the next slides
//    under the keyboard);
//  · `ArrivalsKey` — which key means which act (↑ ↓ ⏎ ⌫ esc; a chord with
//    ⌘ ⌥ or ⌃ is never ours);
//  · `ArrivalsBulk` — a bulk press's outcomes and its ONE message (A-808-11:
//    per-row acts, one message per press, choice rows named and kept, the
//    book's refusals end the run, a row's own refusal skips the row);
//  · `ArrivalsReviewExit` — which book navigation closes the review (a mode
//    change, a note focused, a reveal or landing asked for — the review never
//    stands over a landing she asked to see).
//

import Foundation
import VariorumCore

// MARK: - The pick and the walked row

nonisolated struct ArrivalsSelection: Equatable, Sendable {
    enum Direction: Equatable, Sendable { case up, down }

    /// The picked arrival rows (by arrival-row id — what the acts take).
    private(set) var picked: Set<String> = []
    /// The last row a click or ⇧-walk named — a ⇧-range's other end.
    private(set) var anchor: String?
    /// The row the keyboard stands on (drawn with the ring). ⏎ and ⌫ act on
    /// it when nothing is picked.
    private(set) var walked: String?
    /// The walked row's place in the listing, so a judged row's successor
    /// takes its place under the keyboard.
    private(set) var walkedIndex: Int?

    var count: Int { picked.count }
    var isEmpty: Bool { picked.isEmpty }
    func isPicked(_ id: String) -> Bool { picked.contains(id) }

    /// A click on a row's body — the macOS idiom through the Library's one
    /// brain: plain picks it alone, ⌘ toggles it, ⇧ takes the range. The
    /// keyboard follows the click.
    mutating func click(_ id: String, modifiers: NoteRowClickModifiers, order: [String]) {
        let next = NoteRowSelection.apply(
            NoteRowSelection.intent(for: modifiers), row: id,
            to: picked, anchor: anchor, order: order)
        picked = next.selection
        anchor = next.anchor
        setWalked(id, in: order)
    }

    /// The row's checkbox — ⌘-click's meaning: this row in or out, the rest
    /// untouched.
    mutating func toggle(_ id: String, order: [String]) {
        click(id, modifiers: .command_, order: order)
    }

    /// ⌘A — every LISTED row (A-808-11 F-6: the selection is a subset of the
    /// listing; the tail says how many more wait).
    mutating func selectAll(_ order: [String]) {
        guard !order.isEmpty else { return }
        picked = Set(order)
        if anchor == nil || !order.contains(anchor ?? "") { anchor = order.first }
        if walked == nil { setWalked(order[0], in: order) }
    }

    /// ↑ / ↓ — the keyboard walks; with ⇧ the pick grows from the anchor to
    /// where it lands (the ⇧-click range, by key).
    mutating func walk(_ direction: Direction, extend: Bool, order: [String]) {
        guard !order.isEmpty else { return }
        let current = walked.flatMap { order.firstIndex(of: $0) }
        let index: Int = switch (current, direction) {
        case (nil, .down): 0
        case (nil, .up): order.count - 1
        case (let i?, .down): min(i + 1, order.count - 1)
        case (let i?, .up): max(i - 1, 0)
        }
        let next = order[index]
        if extend {
            let from = anchor ?? walked ?? next
            let seeded = walked.map { picked.union([$0]) } ?? picked
            let applied = NoteRowSelection.apply(
                .extendRange, row: next, to: seeded, anchor: from, order: order)
            picked = applied.selection
            anchor = applied.anchor
        }
        setWalked(next, in: order)
    }

    /// **Keep the pick to what is listed** (the Trash's R2-2 standard): a row
    /// judged, by this window or another, leaves the pick with it; the rows a
    /// bulk act could not move stay picked. The walked row, if it left, is
    /// replaced by the row that took its place (else the last one); on a
    /// first listing it starts on the first row.
    mutating func prune(toVisible order: [String]) {
        let visible = Set(order)
        picked.formIntersection(visible)
        if let anchor, !visible.contains(anchor) { self.anchor = nil }
        guard !order.isEmpty else {
            walked = nil
            walkedIndex = nil
            return
        }
        if let walked, let index = order.firstIndex(of: walked) {
            walkedIndex = index
        } else {
            let index = min(walkedIndex ?? 0, order.count - 1)
            walked = order[index]
            walkedIndex = index
        }
    }

    mutating func clearPick() {
        picked = []
        anchor = nil
    }

    /// **What ⏎ and ⌫ act on** (A-808-11 F-8): the picked rows in listing
    /// order when anything is picked, else the walked row — else nothing.
    func targets(in order: [String]) -> [String] {
        if !picked.isEmpty { return order.filter { picked.contains($0) } }
        if let walked, order.contains(walked) { return [walked] }
        return []
    }

    private mutating func setWalked(_ id: String, in order: [String]) {
        walked = id
        walkedIndex = order.firstIndex(of: id)
    }
}

// MARK: - Which key means which act

nonisolated enum ArrivalsKey {
    enum Key: Equatable, Sendable { case up, down, returnKey, delete, escape }

    enum Act: Equatable, Sendable {
        case walk(ArrivalsSelection.Direction, extend: Bool)
        /// ⏎ — Add the targets (the pick, else the walked row).
        case add
        /// ⌫ — Dismiss the targets.
        case dismiss
        /// esc — Done: back to the book.
        case done
    }

    /// Her ruled keys (VX-821: "arrows walk, ⏎ adds, ⌫ dismisses"), plus
    /// ⇧-arrows extending and esc for Done. A chord carrying ⌘, ⌥ or ⌃ is
    /// never the review's — it passes on to the menus.
    static func act(
        for key: Key, shift: Bool, command: Bool = false, option: Bool = false, control: Bool = false
    ) -> Act? {
        guard !command, !option, !control else { return nil }
        switch key {
        case .up: return .walk(.up, extend: shift)
        case .down: return .walk(.down, extend: shift)
        case .returnKey: return shift ? nil : .add
        case .delete: return shift ? nil : .dismiss
        case .escape: return .done
        }
    }
}

// MARK: - A bulk press: its outcomes and its one message

nonisolated enum ArrivalsBulk {
    enum Act: Equatable, Sendable { case add, dismiss }

    /// One row of a press, as the press read it.
    struct Row: Equatable, Sendable, Identifiable {
        /// The arrival row's id.
        let id: String
        /// What the face calls it (the Library's one derivation, else its
        /// display title).
        let name: String
        let archived: Bool
        /// Its arms need her choice (`ArrivalArms` draws Copy In / Move In,
        /// no Add) — Add never runs it (A-808-11 F-4).
        let needsChoice: Bool
    }

    /// What one row's turn came to.
    enum Outcome: Equatable, Sendable {
        case landed
        /// Add did not run it: its arms need her choice (or the op said so).
        case waitsOnChoice
        /// Its OWN refusal skipped it, worded.
        case refused(String)
        /// The run ended at or before it — a book-level refusal (F-5).
        case stillWaiting
    }

    /// **A refusal that is the BOOK's** — every later row would hear the
    /// same, so the run ends there (F-5).
    static func endsTheRun(_ error: any Error) -> Bool {
        guard let error = error as? OperationError else { return false }
        switch error {
        case .readingAtCapacity, .lockedReading, .readingNotFound, .wrongReadingKind:
            return true
        default:
            return false
        }
    }

    /// **The ownership consult's refusal** — the row needs her choice (its
    /// facts were stale at the press): classed with the choice rows (F-4).
    static func needsChoice(_ error: any Error) -> Bool {
        guard let error = error as? OperationError else { return false }
        switch error {
        case .noteMemberedElsewhere, .noteOwnedElsewhere: return true
        default: return false
        }
    }

    /// **The press's ONE message** (F-3): a receipt when every row landed; a
    /// refusal carrying every fact otherwise — what landed, what waits on
    /// her choice (named), what could not be (the count and the first
    /// reason), what the book's refusal left waiting (and why) — and a
    /// refusal alone when nothing landed. A single row speaks exactly the
    /// single act's words.
    static func words(
        _ act: Act, outcomes: [(row: Row, outcome: Outcome)],
        bookRefusal: String?, chaptered: Bool
    ) -> (receipt: String?, refusal: String?) {
        let landed = outcomes.filter { $0.outcome == .landed }.map(\.row)
        let choice = outcomes.filter { $0.outcome == .waitsOnChoice }.map(\.row)
        var refusals: [String] = []
        for entry in outcomes {
            if case .refused(let words) = entry.outcome { refusals.append(words) }
        }
        let waiting = outcomes.filter { $0.outcome == .stillWaiting }.count

        var sentences: [String] = []
        if !landed.isEmpty {
            switch act {
            case .add:
                sentences.append(landed.count == 1
                    ? ArrivalsCopy.added(landed[0].name, chaptered: chaptered, archived: landed[0].archived)
                    : ArrivalsReviewCopy.addedMany(
                        landed.count, chaptered: chaptered,
                        archived: landed.filter(\.archived).count))
            case .dismiss:
                sentences.append(landed.count == 1
                    ? ArrivalsCopy.dismissed(landed[0].name)
                    : ArrivalsReviewCopy.dismissedMany(landed.count))
            }
        }
        if !choice.isEmpty {
            sentences.append(ArrivalsReviewCopy.waitOnChoice(choice.map(\.name)))
        }
        if let first = refusals.first {
            let alone = landed.isEmpty && choice.isEmpty && waiting == 0 && refusals.count == 1
            sentences.append(alone ? first : ArrivalsReviewCopy.couldNot(refusals.count, act: act, reason: first))
        }
        if waiting > 0, let bookRefusal {
            let alone = landed.isEmpty && choice.isEmpty && refusals.isEmpty
            sentences.append(alone ? bookRefusal : ArrivalsReviewCopy.stillWaiting(waiting, reason: bookRefusal))
        }
        let message = sentences.joined(separator: " ")
        guard !message.isEmpty else { return (nil, nil) }
        let clean = choice.isEmpty && refusals.isEmpty && waiting == 0
        return clean ? (message, nil) : (nil, message)
    }
}

// MARK: - Which navigation closes the review

/// The book facts a navigation moves. While the review is open, a CHANGE in
/// any of them means she asked the book to show her something — a mode, a
/// note, a reveal, a landing — and the review steps aside so she sees it
/// (it never stands over a landing). A reveal or landing CONSUMED (going to
/// nil) is the surface finishing its own work, never her ask.
@MainActor
struct ArrivalsReviewSignal: Equatable {
    var mode: BookStructureModel.ViewMode
    var focusedPostID: String?
    var indexSelectedPostID: String?
    var spreadFirstPostID: String?
    var reveal: String?
    var chapterReveal: String?
    var landingPostID: String?

    static func navigated(from old: ArrivalsReviewSignal, to new: ArrivalsReviewSignal) -> Bool {
        if old.mode != new.mode { return true }
        if old.focusedPostID != new.focusedPostID { return true }
        if old.indexSelectedPostID != new.indexSelectedPostID { return true }
        if old.spreadFirstPostID != new.spreadFirstPostID { return true }
        if let reveal = new.reveal, reveal != old.reveal { return true }
        if let chapter = new.chapterReveal, chapter != old.chapterReveal { return true }
        if let landing = new.landingPostID, landing != old.landingPostID { return true }
        return false
    }
}
