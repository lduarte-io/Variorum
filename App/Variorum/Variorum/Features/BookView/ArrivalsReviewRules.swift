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

import CoreGraphics
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

// MARK: - One row's shape (W-2 / W-3 — the leg-2 walk)

/// **Which of a waiting row's two shapes it takes** — pure, over the row's
/// width and the arms' own ideal width (NEVER the text's: a title or a why
/// line can't change a row's shape — the controls-row law's stable widths).
/// The walk's W-2: at a narrow pane the arms (fixed-size — a door's word is
/// never truncated) took the row's whole width, crushed the title to
/// "Not…", clipped Copy In and pushed Dismiss past the window's edge.
nonisolated enum ArrivalRowFit {
    /// Checkbox → text.
    static let spacing: CGFloat = 14
    /// Text → arms, inline.
    static let armsGap: CGFloat = 12
    /// Text → arms, stacked.
    static let stackGap: CGFloat = 8
    /// The checkbox's drop to the name's line.
    static let boxDrop: CGFloat = 2
    /// The least the text column keeps beside the arms — below it, the arms
    /// go under the text.
    static let textFloor: CGFloat = 220

    /// INLINE needs the box, the text's floor and the arms whole, side by side.
    static func stacked(rowWidth: CGFloat, boxWidth: CGFloat, armsWidth: CGFloat) -> Bool {
        boxWidth + spacing + textFloor + armsGap + armsWidth > rowWidth
    }

    /// The text column's width: the row less the box (and, inline, the arms).
    static func textWidth(
        rowWidth: CGFloat, boxWidth: CGFloat, armsWidth: CGFloat, stacked: Bool
    ) -> CGFloat {
        let beside = rowWidth - boxWidth - spacing
        return max(0, stacked ? beside : beside - armsGap - armsWidth)
    }

    /// Stacked arms sit at the text's left edge while that indent holds them
    /// whole; else they start at the row's edge.
    static func stackedArmsIndented(rowWidth: CGFloat, boxWidth: CGFloat, armsWidth: CGFloat) -> Bool {
        boxWidth + spacing + armsWidth <= rowWidth
    }

    /// The row's ideal width, inline (a parent asking with no width).
    static func inlineWidth(boxWidth: CGFloat, textWidth: CGFloat, armsWidth: CGFloat) -> CGFloat {
        boxWidth + spacing + max(textWidth, textFloor) + armsGap + armsWidth
    }
}

// MARK: - One row's why · since line (F-2 — the ladder's round 1)

/// **Which part of a waiting row's WHY · SINCE line gives way when the line
/// runs short.** Pure, over the line's width and each part's own ideal
/// width. Her ruling is that every row says WHY it waits and since when. The
/// why is the main fact, so it gets the width first: it stays whole while the
/// line can hold it. The SINCE gives way first, in steps: the whole form while
/// it fits beside the why, then the SHORT form (`ArrivalsReviewCopy.sinceShort`,
/// "since …"), then nothing. When it shows nothing, its whole fact is on the
/// why's hover (`ArrivalsReviewCopy.whyHelp`). Beside a why, a stamp is never
/// cut mid-word ("waiting si…" says nothing). The why truncates only when its
/// own words are wider than the line, and by then the since is already gone.
/// The B3+B4 walk's nit (the ladder's F-2): at a ~370-pt pane the why read
/// "Ta…" beside a whole timestamp, because the old line fixed the since's size
/// and let the why truncate. The line stays ONE line at every width: the rule
/// chooses a stamp form, never a shape.
nonisolated enum ArrivalMetaFit {
    /// The space on each side of the dot (the old line's `HStack` spacing).
    static let gap: CGFloat = 6

    /// Which form of the since the line draws.
    enum SinceForm: Equatable, Sendable { case whole, short, dropped }

    /// The line's plan: each part's width (0 = not drawn) and the since's
    /// form (nil when the row has no readable stamp).
    struct Plan: Equatable, Sendable {
        var why: CGFloat
        var dot: CGFloat
        var since: CGFloat
        var form: SinceForm?

        /// Where the since starts: after the why, the gap, the dot and the
        /// gap when it sits beside a why; at the line's start when it is alone.
        var sinceOffset: CGFloat { why > 0 && since > 0 ? why + 2 * ArrivalMetaFit.gap + dot : 0 }
        /// Where the dot starts (drawn only between a why and a since).
        var dotOffset: CGFloat { why + ArrivalMetaFit.gap }
        /// The width the line draws. It is never wider than it was offered.
        var width: CGFloat { since > 0 ? sinceOffset + since : why }
    }

    /// - `width`: what the line is offered (nil: every part at its ideal).
    /// - `why`: the why's ideal width; nil when the row has no why.
    /// - `dot`: the separator's ideal width.
    /// - `since`: the ideal widths of the since's two forms; nil when the row
    ///   has no readable stamp.
    static func plan(
        width: CGFloat?, why: CGFloat?, dot: CGFloat, since: (whole: CGFloat, short: CGFloat)?
    ) -> Plan {
        let room = max(0, width ?? .infinity)
        guard let since else {
            return Plan(why: min(why ?? 0, room), dot: 0, since: 0, form: nil)
        }
        guard let why else {
            // The since alone has nothing to give way to: the whole form while
            // it fits, else the short form (which truncates only past that).
            if since.whole <= room { return Plan(why: 0, dot: 0, since: since.whole, form: .whole) }
            return Plan(why: 0, dot: 0, since: min(since.short, room), form: .short)
        }
        let beside = room - why - 2 * gap - dot
        if since.whole <= beside { return Plan(why: why, dot: dot, since: since.whole, form: .whole) }
        if since.short <= beside { return Plan(why: why, dot: dot, since: since.short, form: .short) }
        return Plan(why: min(why, room), dot: 0, since: 0, form: .dropped)
    }
}

// MARK: - The header's and the bar's shape (W-4 — the rewalk)

/// **Whether the review's header or bar takes one line or two** — pure, the
/// row's rule one level up (the Library controls-row law: wrap only by stable
/// widths). One line while the leading group keeps its FLOOR beside the
/// trailing door(s) whole; else two — the leading group on the first line,
/// the door(s) on the second. The rewalk's W-4: at a ~370-pt pane the header's
/// "Dismiss all" and the bar's "Done" were cut at the window's edge.
nonisolated enum ReviewChromeFit {
    /// Between the groups on one line.
    static let gap: CGFloat = 12
    /// Between the two lines.
    static let lineGap: CGFloat = 8
    /// The header's title keeps this much beside its doors (it truncates
    /// past it, whole on the line above them below it).
    static let titleFloor: CGFloat = 140

    /// Two lines when the leading floor, a gap and the trailing group's own
    /// width do not fit in `width`. Never reads the leading group's words
    /// beyond its floor, so a title or a count never flips the shape.
    static func stacked(width: CGFloat, leadingFloor: CGFloat, trailingWidth: CGFloat) -> Bool {
        leadingFloor + gap + trailingWidth > width
    }

    /// On one line, the leading group's width: its own ideal while there is
    /// room, yielding down to its floor so a flexible middle (the receipt)
    /// gets its ideal first — never below the floor, never past `available`.
    static func inlineLeadingWidth(
        available: CGFloat, leadingIdeal: CGFloat, leadingFloor: CGFloat, flexibleIdeal: CGFloat?
    ) -> CGFloat {
        guard let flexibleIdeal else { return max(0, min(leadingIdeal, available)) }
        let yielded = max(leadingFloor, available - gap - flexibleIdeal)
        return max(0, min(leadingIdeal, yielded, available))
    }
}

// MARK: - Which navigation closes the review

/// The book facts a navigation moves. While the review is open, a MOVE in
/// any of them means she asked the book to show her something — a mode, a
/// note, a reveal, a landing — and the review steps aside so she sees it
/// (it never stands over a landing). A reveal or landing CONSUMED (going to
/// nil) is the surface finishing its own work, never her ask.
///
/// **W-1 (the leg-2 walk) — the review's OWN acts are never navigation.**
/// Its seats change the book's CONTENT, and content arriving moves two of
/// these facts from NOTHING: an empty book's first seat fills the spread's
/// first page (`BookViewModel.spreadEntries`), and the Index's cold seed
/// selects its first note (`BookIndexView.landOrSeed`). So the spread's page
/// and the Index's selection count only when they move from one note to
/// ANOTHER; a focus counts when it lands on a note, never when the book
/// releases one it no longer shows (its own housekeeping — every release she
/// asks for rides a mode, a reveal or a page that does count).
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
        if let focused = new.focusedPostID, focused != old.focusedPostID { return true }
        if moved(old.indexSelectedPostID, new.indexSelectedPostID) { return true }
        if moved(old.spreadFirstPostID, new.spreadFirstPostID) { return true }
        if let reveal = new.reveal, reveal != old.reveal { return true }
        if let chapter = new.chapterReveal, chapter != old.chapterReveal { return true }
        if let landing = new.landingPostID, landing != old.landingPostID { return true }
        return false
    }

    /// From one note to ANOTHER — never seeded from nothing, never emptied.
    private static func moved(_ old: String?, _ new: String?) -> Bool {
        guard let old, let new else { return false }
        return old != new
    }
}
