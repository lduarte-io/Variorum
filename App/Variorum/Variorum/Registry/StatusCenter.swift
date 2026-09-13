//
//  StatusCenter.swift
//  Variorum (Mac)
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
//  `speak` keeps its exact signature and INFERS the kind (an action ⇒ an
//  offer, else a refusal), so every shipped call site and every pin over
//  them is byte-unchanged; `receipt(_:)` is the new door the after-the-fact
//  confirmations adopt; `deliver(_:kind:)` is the general door the view
//  models that forward a CLASSED status line use (`TakesViewModel`'s
//  `RecoveryStatus`, and the four models whose `statusMessage` didSet
//  forwards here).
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
    var spoken: Item? { current ?? quietLine }

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

    /// The shipped door, signature unchanged: an action makes it an OFFER,
    /// otherwise it is a REFUSAL. Both always toast, so every call site and
    /// pin that existed before 18i behaves byte-identically.
    func speak(_ text: String, action: Item.Action? = nil) {
        deliver(text, kind: action == nil ? .refusal : .offer, action: action)
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
    /// The mapping lives here and only here, so the three doors that carry
    /// such a fact cannot spell it three ways (F-0's drift class).
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
    func deliver(_ text: String, kind: Kind, action: Item.Action? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = Item(id: UUID(), text: trimmed, action: action, kind: kind)
        guard let slot = slot(for: kind) else {
            // `.off`: she asked for nothing, so nothing shows — and a
            // dropped receipt leaves whatever is already on screen alone
            // (a refusal she is still reading is not swept away by an act
            // that says nothing).
#if DEBUG
            lastDroppedReceipt = trimmed
#endif
            Self.log.debug("receipt dropped (style=off): \(trimmed, privacy: .public)")
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

    private enum Slot { case toast, quiet }

    /// The ONE routing rule. Refusals and offers are not the setting's to
    /// govern; a receipt goes where she said.
    private func slot(for kind: Kind) -> Slot? {
        switch kind {
        case .refusal, .offer:
            return .toast
        case .receipt:
            switch receiptStyle {
            case .toast: return .toast
            case .quiet: return .quiet
            case .off: return nil
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
