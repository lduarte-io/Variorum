//
//  StatusCenter.swift
//  Variorum (shared: Mac + Mobile)
//
//  **VM-61 (2026-11-19) — ONE SEAM, TWO FACES.** This file moved here from
//  the Mac's `Registry/` so the phone speaks through the same
//  `session.status`: the kinds are decided at the door on both platforms
//  (refusal · offer · receipt), and a brain hoisted to `Shared/` speaks
//  without a platform `#if`. What differs is WHERE a message shows — the
//  placement, one pure rule (`slot(kind:leavesPage:placement:receiptStyle:)`):
//  the Mac's is her receipt style (toast · quiet · off, below, unchanged);
//  the phone's is her VM-44 ruling — *"no line for ordinary acts; a short
//  line with Undo when something leaves the page, and for refusals"* — so a
//  receipt draws on the phone only when its door says it took something off
//  the page (`removal(_:undo:owner:)`), and `receipt_style` is not read there
//  (PROVISIONAL P-55-1). The Mac's toast, quiet line and standing offer are
//  byte-identical: no Mac caller sets the placement, says `removal` or
//  `withdraw`s (pinned, `VM61MacStatusSeamPinTests`). The phone's face is
//  `MobileMessageLine` (the one line, hosted once by the phone's shell).
//
//  Phase 13b, Stage 1b (AD-14): ONE refusal/status presentation. Every
//  transient outcome — refusals, confirmations, undo reports — lands here
//  and renders in ONE place (the shell's status toast, mode-independent),
//  with ONE auto-dismiss policy. This is what makes ⌥⌘Z's outcome visible
//  on every surface (N4 — it used to report into a nil Write editor) and
//  retires the per-surface notice styles that never dismissed (AD-17's
//  sibling report).
//
//  View models keep their `statusMessage` properties (pins and sheets read
//  them); the app-level PRESENTATION is this center's — the properties
//  forward here on set.
//
//  ── 18i (her ruling R-Q5): THE MESSAGES GAIN A KIND ──────────────────────
//  From her 2026-09-12 report: *"there's these little text confirmation
//  popups that are always appearing… i either need them off, more subtle in
//  the bottom bar in more muted text, or a setting if i can turn it on or
//  off… i don't always need it less noticable because for some operations
//  it's the right confirmation text to show."* The answer is NOT a per-site
//  `if setting` — it is one distinction made HERE, where every message
//  already passes:
//
//    · **refusal** — nothing happened, and this says why. ALWAYS the toast,
//      under every setting: a door that could not act must deliver the
//      operations layer's real refusal (P-2, fire-and-DO). A DIRECTION (the
//      undo hint at the junction, "finish the ceremony, then run this
//      again") rides this class for the same reason — she must see it.
//    · **offer** — it carries a button; it is a question, and a question
//      she cannot see is not asked. ALWAYS the toast.
//    · **receipt** — an act LANDED and this says what ("Blocks joined —
//      ⌥⌘Z undoes it."). THESE are what her setting governs.
//
//  **THE DOORS SAY THEIR CLASS (13u2 UNIT E — KnownIssues row 56, step 1).**
//  18i shipped `speak`, which INFERRED the kind from whether an action rode
//  along; the class was then invisible at ~100 call sites and the 18i ladder
//  found FOUR mis-classified families by hand against a green suite. The
//  inference is retired: `refuse(_:)` (nothing happened), `offer(_:action:)`
//  (it carries a button), `direct(_:)` (a direction, always shown, nothing
//  refused) and `receipt(_:)` (it landed — the only class her setting
//  governs). `deliver(_:kind:)` stays the general door for a producer that
//  already knows its class (`TakesViewModel`'s `RecoveryStatus`, and the four
//  models whose `statusMessage` didSet forwards here); `say(_:refusing:)`
//  stays the door for an act whose own outcome decides.
//

import Foundation
import Observation
import OSLog
import VariorumCore

@MainActor
@Observable
final class StatusCenter {
    /// **What kind of thing was said** (18i — R-Q5). The class is decided
    /// WHERE THE MESSAGE IS PRODUCED, never guessed here from its text:
    /// a view (or a centre) re-deriving "was this a refusal" from words is
    /// exactly the projection the split exists to prevent — the same rule
    /// `RecoveryStatus` states for the recovery surfaces' local slots.
    enum Kind: Equatable, Sendable {
        /// Nothing happened, and this says why — or a direction she must
        /// see. Always the toast.
        case refusal
        /// It carries a button. Always the toast.
        case offer
        /// Something happened, and this says what. Her setting governs it.
        case receipt
    }

    struct Item: Equatable {
        let id: UUID
        let text: String
        /// 13f batch 5 (W23 + her round-10 item 4): a note may carry ONE
        /// door. Her words: *"it seems a bit annoying to get the FYI but not
        /// have a button that nicely duplicates it as version and deletes the
        /// original for you all in one go"* — so a status item can be an
        /// offer, not only an announcement. Optional by default, so every
        /// existing `speak` call and every pin over them is unchanged.
        var action: Action?
        /// 18i: defaulted, so every shipped `Item` construction and every
        /// pin reads unchanged.
        var kind: Kind = .refusal
        /// 13r U3-A (R-13r-12): an offer may carry a SECOND door — the
        /// backup-folder ask's Set Up… / Not Now pair. Defaulted, so every
        /// shipped construction and pin reads unchanged; only an offer sets it.
        var secondary: Action? = nil
        /// **VX-676 — a STANDING offer's own small ✕** (her sitting's ruling
        /// (2): "the line carries its own small dismiss"): drawn by the quiet
        /// line beside the item's door, and it ENDS the offer — distinct from
        /// the toast's ✕, which only sends a standing offer to the line.
        /// Defaulted, so every other item reads unchanged.
        var dismiss: Action? = nil
        /// **VM-61 — a receipt whose act took something OFF THE PAGE** (a
        /// delete, a merge, an archive). Decided at the door
        /// (`removal(_:undo:owner:)`), never inferred from the words or from
        /// an action riding along. The phone's placement draws a receipt only
        /// when this is set; the Mac's ignores it. Defaulted, so every other
        /// item reads unchanged.
        var leavesPage: Bool = false
        /// **VM-61 — who spoke it**, so a speaker going away can take back a
        /// line whose door was its own (`withdraw(owner:)` — the phone's note
        /// screen, whose structural Undo dies with it). Defaulted nil.
        var owner: ObjectIdentifier? = nil

        struct Action: Equatable {
            let label: String
            let perform: @MainActor () -> Void

            static func == (lhs: Action, rhs: Action) -> Bool { lhs.label == rhs.label }
        }
    }

    /// The TOAST slot — the shell's card at the bottom. Refusals and offers
    /// always land here; receipts land here only under `.toast`.
    private(set) var current: Item?

    /// **THE QUIET SLOT** (18i — her *"more subtle in the bottom bar in more
    /// muted text"*): a receipt under `.quiet`. One view renders it —
    /// `QuietReceiptLine`, composed by the bottom bars — and it rides the
    /// SAME 6 s clock the toast does, so "quiet" is a different placement
    /// and register, never a different lifetime.
    private(set) var quietLine: Item?

    /// **VX-676 — THE STANDING OFFER** (her sitting 2026-10-28, ruling (2),
    /// settled at her afternoon pass: *"killing an active ask taking two
    /// presses is not the worst issue ever … why do you not want to see what
    /// the AI brought you"*). An offer that OUTLIVES its toast: it first shows
    /// at the toast's full prominence (it IS `current` then), and once the toast
    /// has gone — its fade, its ✕, or a newer toast — it HOLDS the quiet line at
    /// the bottom bar's trailing end until its owner ends it (taken, replaced
    /// by a newer one, its client gone) or her ✕ on the line does. No snooze
    /// fork: the standing line IS the snoozed state.
    ///
    /// One at a time; never cleared by `clear()` (a toast's ✕ must send it to
    /// the line, not kill it) — only `stand(_:)`'s replacement and
    /// `endStanding(_:)` move it. A quiet RECEIPT that lands while it stands
    /// takes the line for its own six seconds, then the offer is back
    /// (PROVISIONAL P-676-3 — her receipt style keeps its meaning).
    private(set) var standing: Item?

    /// **What the quiet line shows** (the one view, `QuietReceiptLine`): a
    /// receipt under `.quiet` while one speaks; else the standing offer — unless
    /// the toast is showing that very offer (one message, one place).
    var lineItem: Item? {
        if let quietLine { return quietLine }
        guard let standing, current?.id != standing.id else { return nil }
        return standing
    }

    /// **The last thing said, wherever it landed.** A pin that asserts THE
    /// WORDS reads this and stays kind-agnostic; the pins that assert WHICH
    /// SLOT (`StatusCenterTests`) read `current`/`quietLine` directly. At
    /// most one of the two is ever non-nil — a new message clears the other
    /// slot — so this is a choice, never a merge.
    ///
    /// **THE TRAP, named for the next author** (the 18i ladder round 1, N2):
    /// this is *what is on screen*, NOT *what was said*. Under `.off` a
    /// receipt is produced, reaches the centre, and is dropped — and `spoken`
    /// reads nil. So a pin that asserts SILENCE by reading `spoken` means
    /// "nothing is showing", which under `.off` is true of every receipt in
    /// the app; if such a pin is ever run under that style it is hollow. Read
    /// `lastDroppedReceipt` to tell "dropped" from "never produced".
    /// VX-676: a standing offer the line shows is on screen too.
    var spoken: Item? { current ?? lineItem }

    /// **What a RECEIPT does** — adopted by `ThemeStore` from the LANDED
    /// settings (the 18d ladder's lesson: a settings value is adopted where
    /// it lands, never guessed by a view). The compile-time value is HER
    /// DEFAULT, the same one `Queries.ThemeSettings` resolves for an
    /// unseeded store, so the milliseconds before the first observation
    /// delivers behave exactly as the store says they will.
    ///
    /// `@ObservationIgnored` deliberately: it is read at SPEAK time and
    /// nothing renders from it, so changing it must not invalidate a view.
    @ObservationIgnored var receiptStyle: ReceiptStyle = .quiet

    /// **VM-61 — where a message shows: the platform's face.**
    enum Placement: Equatable, Sendable {
        /// The Mac: refusals and offers toast; a receipt goes where her
        /// `receipt_style` says.
        case receiptStyle
        /// The phone's ONE line (her VM-44 ruling): refusals and offers
        /// always; a receipt only when it took something off the page;
        /// `receipt_style` is not read (PROVISIONAL P-55-1). Everything that
        /// draws lands in `current` — the phone has one line, no quiet slot.
        case phoneLine
    }

    /// The platform's placement, read at SPEAK time like `receiptStyle`
    /// (nothing renders from it). Composition, not a brain: no caller sets
    /// it; each platform's build answers it once, here.
    #if os(macOS)
    @ObservationIgnored var placement: Placement = .receiptStyle
    #else
    @ObservationIgnored var placement: Placement = .phoneLine
    #endif

    /// The one auto-dismiss policy (injectable for tests).
    @ObservationIgnored var dismissAfter: Duration = .seconds(6)
    @ObservationIgnored private var dismissTask: Task<Void, Never>?

#if DEBUG
    /// What `.off` swallowed, for a walk and for the pin that proves a
    /// dropped receipt REACHED the centre (rather than never having been
    /// produced at all). DEBUG-only; nothing production reads it.
    private(set) var lastDroppedReceipt: String?
#endif

    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "status")

    /// **REFUSE — nothing happened, and this says why.** Always the toast,
    /// under every setting.
    ///
    /// *(13u2 UNIT E — KnownIssues row 56, step 1. This door was `speak`,
    /// which INFERRED its class from whether an action rode along, so ~100
    /// call sites said nothing about what kind of message they were making.
    /// The inference is gone: `refuse` takes no action and `offer` requires
    /// one, so the class is readable at every site with no doc. Zero
    /// behaviour — both still deliver exactly what `speak` delivered.)*
    func refuse(_ text: String) {
        deliver(text, kind: .refusal)
    }

    /// **OFFER — it carries a button; it is a question.** Always the toast,
    /// because a question she cannot see is not asked.
    func offer(_ text: String, action: Item.Action) {
        deliver(text, kind: .offer, action: action)
    }

    /// **OFFER with two doors** (13r U3-A — the backup-folder ask: Set Up… /
    /// Not Now). The primary door is the act; the secondary is the decline.
    /// Either one dismisses the toast as it acts (`StatusToast`).
    func offer(_ text: String, action: Item.Action, secondary: Item.Action) {
        deliver(text, kind: .offer, action: action, secondary: secondary)
    }

    /// **DIRECT — a direction she must see, though nothing was refused.**
    /// Delivered as a refusal because the CLASS is "always shown", which is
    /// what the setting governs; the name exists so a reader is not told
    /// something failed when nothing did (row 56's own distinction — the doc
    /// on `Kind.refusal` already carried it, and a name carries it better).
    func direct(_ text: String) {
        deliver(text, kind: .refusal)
    }

    /// **The receipt door** (18i): an act landed and this says what. Where
    /// it shows is `receiptStyle`'s answer.
    func receipt(_ text: String) {
        deliver(text, kind: .receipt)
    }

    /// **The door for an act whose OWN OUTCOME decides the class** (the 18i
    /// ladder round 1, J29): a door that computes its line from what it did
    /// — the note delete's four outcomes, the import's skips, the export's
    /// count — knows whether anything landed, and that answer IS the class.
    /// The mapping lives here for **every door that speaks to the CENTRE
    /// directly**, so those three cannot spell it three ways (F-0).
    ///
    /// **What this does NOT cover, and why** (the ladder round 2, N1 — the
    /// shipped sentence said "here and only here" and overclaimed): three
    /// sites spell the same `landed ? … : …` as a ternary because they write
    /// a VIEW MODEL's own status property rather than the centre —
    /// `EditorSurfaceController`'s `runStructural` seam
    /// (`outcome.noteIsRefusal ? refuse : showReceipt`),
    /// `TakesStructureController`'s split door (`setReceipt`/`setRefusal`, the
    /// board's `RecoveryStatus`, which `WriteTakesPanel` RENDERS), and
    /// `BlockTOCViewModel`'s (`showReceipt`/`refuse`). Routing any of them
    /// through this door would bypass a property ~22 shipped pins read and,
    /// on the board, a slot a view draws — the parity this letter has kept
    /// everywhere else. Giving each model its own `say` would spell the
    /// mapping three MORE times, not once.
    ///
    /// `refusing` is the doors' own vocabulary — `RecoveryStatus.isRefusal`
    /// and `StructuralOutcome.noteIsRefusal` are the two spellings already in
    /// the codebase, and this is the third consumer of the same word.
    func say(_ text: String, refusing: Bool) {
        deliver(text, kind: refusing ? .refusal : .receipt)
    }

    /// The general door, for a producer that already knows its class — the
    /// view models whose own status line is classed where the message is
    /// produced (`RecoveryStatus`, and the `statusMessage` forwarders).
    func deliver(
        _ text: String, kind: Kind, action: Item.Action? = nil, secondary: Item.Action? = nil
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        place(Item(id: UUID(), text: trimmed, action: action, kind: kind, secondary: secondary))
    }

    /// **VM-61 — REMOVAL: an act landed AND took something off the page** (a
    /// delete, a merge, an archive — her VM-44 ruling's own list). A receipt
    /// in kind (her receipt style governs it on the Mac, exactly as
    /// `receipt(_:)`); the phone draws it — and only it, of all receipts —
    /// with its `undo` door, which is only ever a road that already exists
    /// (structural undo, Put back, unarchive; scope call 7).
    ///
    /// A removal may carry its Undo ALONE, with no words: the phone's merge
    /// and cross-block join shipped a wordless Undo (no words were ever
    /// ruled for them — PROVISIONAL P-55-5), so the empty-text guard yields
    /// to an Undo here, and only here. `owner` names the speaker whose
    /// going-away withdraws the line (`withdraw(owner:)`).
    func removal(_ text: String, undo: Item.Action? = nil, owner: ObjectIdentifier? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || undo != nil else { return }
        place(Item(
            id: UUID(), text: trimmed, action: undo, kind: .receipt,
            leavesPage: true, owner: owner))
    }

    /// **VM-61 — take back what `owner` said, if it is still showing.** The
    /// phone's note screen calls it as it goes away: its structural Undo is
    /// that screen's door, and a line offering it over another screen would
    /// press a door with no note behind it. Anything else said since stands.
    func withdraw(owner: ObjectIdentifier) {
        if current?.owner == owner { current = nil }
        if quietLine?.owner == owner { quietLine = nil }
    }

    /// The one placement step every door's item takes (VM-61 split it out of
    /// `deliver` so `removal` shares it; the Mac's order — route, replace,
    /// re-arm the clock — is unchanged).
    private func place(_ item: Item) {
        let trimmed = item.text
        guard let slot = Self.slot(
            kind: item.kind, leavesPage: item.leavesPage,
            placement: placement, receiptStyle: receiptStyle)
        else {
            // `.off` (and, on the phone, an ordinary act's receipt): she
            // asked for nothing, so nothing shows — and a dropped receipt
            // leaves whatever is already on screen alone (a refusal she is
            // still reading is not swept away by an act that says nothing).
#if DEBUG
            lastDroppedReceipt = trimmed
#endif
            switch placement {
            case .receiptStyle:
                Self.log.debug("receipt dropped (style=off): \(trimmed, privacy: .public)")
            case .phoneLine:
                // Private: a dropped receipt carries her words (note and book
                // titles) — VM-55 ladder round 1, finding 5.
                Self.log.debug("receipt dropped (phone line, ordinary act): \(trimmed, privacy: .private)")
            }
            return
        }
        // ONE message at a time, wherever it sits: a new one clears the
        // other slot, so the centre can never show a stale receipt under a
        // fresh refusal.
        switch slot {
        case .toast:
            current = item
            quietLine = nil
        case .quiet:
            quietLine = item
            current = nil
        }
        dismissTask?.cancel()
        dismissTask = Task { [weak self, dismissAfter] in
            try? await Task.sleep(for: dismissAfter)
            guard !Task.isCancelled, let self else { return }
            if self.current?.id == item.id { self.current = nil }
            if self.quietLine?.id == item.id { self.quietLine = nil }
        }
    }

    /// **VX-676 — present a STANDING offer**: at the toast's full prominence
    /// now (an offer, so under every receipt style — the toast's own clock), and
    /// standing on the quiet line from the moment the toast is gone, until
    /// `endStanding`. A newer one REPLACES it (her ruling's "replaced by a newer
    /// ask"). `action` is its door; `dismiss` its line's ✕.
    /// `id` is the item's — a caller whose doors must name their own offer
    /// (so an older offer's door never acts on a newer one) mints it first.
    @discardableResult
    func stand(_ text: String, id: UUID = UUID(), action: Item.Action, dismiss: Item.Action) -> UUID? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let item = Item(id: id, text: trimmed, action: action, kind: .offer, dismiss: dismiss)
        // VM-55 ladder round 1, finding 2: the phone's one line has no quiet
        // slot and no ✕ (P-55-3), so a standing offer is an ORDINARY offer
        // there until a phone face for standing offers exists — it draws with
        // its door and fades on the seam's clock, and nothing is kept standing
        // behind a line no surface draws. The Mac's road below is untouched.
        if placement == .phoneLine {
            place(item)
            return item.id
        }
        standing = item
        current = item
        quietLine = nil
        dismissTask?.cancel()
        dismissTask = Task { [weak self, dismissAfter] in
            try? await Task.sleep(for: dismissAfter)
            guard !Task.isCancelled, let self else { return }
            // The toast goes; the offer stays standing — the line holds it now.
            if self.current?.id == item.id { self.current = nil }
        }
        return item.id
    }

    /// **VX-676 — the standing offer ends** (taken, its line's ✕, its client
    /// gone, the library closing): gone from the line and, if it is still the
    /// toast, from the toast too. Only the offer named ends — a newer one that
    /// replaced it is never ended by the older one's road.
    func endStanding(_ id: UUID) {
        // VM-55 ladder round 1, finding 2: on the phone nothing stands (see
        // `stand`), so ending the offer takes it off the line if it still
        // shows — BEFORE the Mac's guard, which would return early here.
        if placement == .phoneLine {
            if current?.id == id { current = nil }
            return
        }
        guard standing?.id == id else { return }
        standing = nil
        if current?.id == id { current = nil }
    }

    /// Where an item lands. `toast` is the prominent slot (`current`) — the
    /// Mac's toast card, and the phone's ONE line; `quiet` is the Mac's
    /// muted line at the bottom bar's trailing end (the phone has none).
    enum Slot: Equatable, Sendable { case toast, quiet }

    /// **The ONE routing rule, pure** (VM-61 made it a static over its
    /// inputs so both platforms' answers are pinned as a table). Refusals and
    /// offers are not the setting's to govern; on the Mac a receipt goes
    /// where she said; on the phone a receipt draws only when it took
    /// something off the page — her VM-44 ruling — and the receipt style is
    /// never consulted there (PROVISIONAL P-55-1). `nil` = nothing shows.
    static func slot(
        kind: Kind, leavesPage: Bool, placement: Placement, receiptStyle: ReceiptStyle
    ) -> Slot? {
        switch kind {
        case .refusal, .offer:
            return .toast
        case .receipt:
            switch placement {
            case .receiptStyle:
                switch receiptStyle {
                case .toast: return .toast
                case .quiet: return .quiet
                case .off: return nil
                }
            case .phoneLine:
                return leavesPage ? .toast : nil
            }
        }
    }

    func clear() {
        dismissTask?.cancel()
        dismissTask = nil
        current = nil
        quietLine = nil
#if DEBUG
        // N1 (the 18i ladder round 1): the drop record is part of what
        // `clear()` clears. Without this a pin asserting "nothing was
        // dropped" after an earlier drop in the same session passes wrongly.
        lastDroppedReceipt = nil
#endif
    }
}

// MARK: - The forwarder (18i ladder round 1, J30)

/// **ONE HOME FOR THE `statusMessage` FORWARD'S RULE.**
///
/// Four view models (`EditorViewModel`, `BlockTOCViewModel`,
/// `CanvasViewModel`, `CompareBoardModel`) keep a `statusMessage` property
/// that pins and sheets read and that FORWARDS to the centre on set (AD-14).
/// 18i gave that forward a kind, and the rule it needs is stateful — *name
/// the class the next write carries, deliver it, RESET* — so that the ~100
/// bare `statusMessage = …` assignments in those files, every one of them a
/// refusal or an error, keep behaving exactly as they did without a single
/// edit.
///
/// The reset is an INVARIANT: a missed one makes the next refusal speak as a
/// receipt, which under `off` is silence — the same failure the round's
/// BLOCKER was, arriving by drift instead of by classification. It shipped as
/// four hand-written copies (three byte-identical, the fourth already
/// diverged), which is exactly F-0's *"two copies of one rule anywhere are
/// the drift class"*. It lives here now, once, beside the centre it speaks
/// to: a fifth forwarder gets the rule rather than a fifth copy of it.
@MainActor
struct StatusForwarder {
    private let status: StatusCenter

    /// The class the NEXT delivery carries. A door that is about to write a
    /// receipt raises it; everything else leaves it alone, so the default —
    /// and the value after every delivery — is the always-shown class.
    var outgoing: StatusCenter.Kind = .refusal

    init(_ status: StatusCenter) { self.status = status }

    /// Called from the property's `didSet`. Nil clears the model's own line
    /// and says nothing (the centre has its own clock) — **and resets the
    /// class anyway** (the ladder round 2, J41): the reset is an INVARIANT,
    /// and holding it by "no caller writes nil after raising the class" left
    /// exactly one road open (`EditorViewModel.setStatusMessage(_:kind:)`
    /// takes an optional). No caller takes that road today and there is no
    /// red to fix — this closes it rather than documenting it.
    mutating func deliver(_ text: String?) {
        guard let text else {
            outgoing = .refusal
            return
        }
        status.deliver(text, kind: outgoing)
        outgoing = .refusal
    }
}
