//
//  DivideWCeremony.swift
//  Variorum
//
//  13d Batch 3 (A9 — "i desperately need divide in takes mode"): the W
//  ceremony's state machine, lifted out of `EditorSurfaceController` so it
//  can mount on ANY surface that knows which block and which take you are
//  in. Nothing about the ceremony was ever Write-shaped except the two
//  things now behind `DivideWCeremonyHost`: how a surface flushes its
//  pending text, and how it runs the divide. Everything else — the
//  checklist, the per-take cut proposals, the parking rules, the confirm
//  gate, the drift refresh — is store reads and pure state, and it moved
//  here VERBATIM (behavior parity is the batch contract: every pre-move
//  pin runs unmodified through `EditorSurfaceController`'s forwards).
//
//  ONE generalization, and it is what A9 needs (13d Batch 3): the SEED
//  take is a parameter now, not a derivation. Write derived it from its
//  own index — that index shows the CHOSEN take, so "the take you are
//  looking at" and "the chosen take" were the same sentence there. On a
//  takes board the caret may sit in a NON-chosen pane, so the surface
//  names its own seed and the propagation runs from that take's text.
//
//  Lifetime: the host owns this object strongly and is its only owner; the
//  back-reference is `unowned`.
//

import Foundation
import Observation
import VariorumCore

/// What the ceremony needs from whatever surface mounts it. Deliberately
/// seven members: the store, the surface's pending-text contract, the
/// one-flight door, the act, and the three voices (status, refusal,
/// error — refusal is its own member so the busy-door beep survived the
/// extraction; batch 3's judgment call 1). A host that can answer these
/// can mount the ceremony; nothing else about Write is required.
@MainActor
protocol DivideWCeremonyHost: AnyObject {
    var ceremonyDatabase: AppDatabase { get }
    /// Flush this surface's pending text. `false` = the flush REFUSED and
    /// kept its text pending (Phase 7 MAJOR 1) — the ceremony must not
    /// open or confirm against a store the surface disagrees with. The
    /// host speaks its own refusal.
    func flushPendingText() async -> Bool
    /// The host's one-flight door, read synchronously BEFORE any await
    /// (Phase 9 review round 3, MINOR): a gesture can be mid-flight while
    /// the sheet is up, because menu key equivalents stay live under a
    /// window-modal sheet.
    var structuralFlightInProgress: Bool { get }
    /// Runs the divide through the host's own structural door. Returns
    /// whether it LANDED — the sheet dismisses only then, so a refusal
    /// keeps the ceremony and its cuts for the author.
    ///
    /// `displayedVariantID` is the SEED take — the one the author was
    /// working in when the divide was invoked — and it anchors both
    /// successors' chosen/default (18c batch 1's additive `divideW` arm;
    /// QUESTIONS #91). Nil-or-not-in-`cuts` keeps A's rendered take, so an
    /// unchecked seed falls back to today's behaviour by construction.
    func runDivideW(
        blockID: String, cuts: [String: Int], displayedVariantID: String?
    ) async -> Bool
    /// The THIRD preset's road (U-5: "all takes go on both"), which is the
    /// shipped `Operations.divideDuplicating` — not a `divideW`
    /// arrangement, because "ride whole onto BOTH successors" is not
    /// something a per-take cut can say. Same contract: true = landed.
    func runDivideDuplicating(
        blockID: String, displayedVariantID: String, cut: Int
    ) async -> Bool
    func speakCeremonyStatus(_ message: String)
    /// A REFUSAL, in the host's own refusal voice — Write beeps because
    /// Write's structural refusals beep; a board speaks because its
    /// refusals speak. Separate from `speakCeremonyStatus` so the pre-move
    /// beep on the busy-door guard survives the extraction exactly.
    func speakCeremonyRefusal(_ message: String)
    func speakCeremonyError(_ error: Error)
}

@MainActor
@Observable
final class DivideWCeremony {
    @ObservationIgnored unowned let host: DivideWCeremonyHost

    init(host: DivideWCeremonyHost) {
        self.host = host
    }

    /// Non-nil = the sheet is up; the surface underneath is untouched for
    /// the ceremony's whole duration; cancel sets nil with no rows
    /// touched; confirm funnels back through the host's structural door.
    var state: State?

    /// **THE ARRANGEMENT ROW** (her ruling U-5, 2026-09-06, verbatim: *"the
    /// phone should offer three options … 1. all takes stay with the top
    /// block 2. all takes stay with the bottom block 3. all takes go on
    /// both. I think those options should feel easily available in the
    /// divide ceremony for ease and the custom selector should be something
    /// you really have to choose to do."* — the Mac's sheet gets the same
    /// row, mockup figure A).
    ///
    /// The order is fixed by ruling, and `keepOnTop` is SELECTED ON OPEN
    /// because it is her U-2 default — so confirming the sheet unchanged
    /// reproduces the instant divide byte-for-byte (pinned).
    ///
    /// Three of the four are ARRANGEMENTS of arguments to shipped
    /// operations, not new ones: top and bottom are `KeepOnTopDivide`'s two
    /// compositions over `divideW`'s parking rule (S4-22), and "copy to
    /// both" is `divideDuplicating` (13j J4's retired default, kept in core
    /// for exactly this). Only `perTake` is the hand-placement surface the
    /// sheet has always been.
    enum Arrangement: String, CaseIterable, Equatable, Sendable, Identifiable {
        case keepOnTop, keepOnBottom, copyToBoth, perTake
        var id: String { rawValue }

        /// The chip's word — the mockup's, shortened only where the row
        /// would not otherwise fit at the sheet's width.
        var title: String {
            switch self {
            case .keepOnTop: "Keep takes on the top block"
            case .keepOnBottom: "Keep takes on the bottom block"
            case .copyToBoth: "Copy takes to both"
            case .perTake: "Choose per take…"
            }
        }

        /// True where the takes are shown but not individually chosen — the
        /// checkbox appears only in "Choose per take" (mockup A's caption).
        var isPreset: Bool { self != .perTake }
    }

    struct State: Equatable, Identifiable {
        let blockID: String
        /// The SEED take — the one the author was looking at when the
        /// divide was invoked. Pre-marked, its cut pre-placed at the
        /// gesture's snapped position; every other take's proposal
        /// propagates from THIS take's text.
        let activeVariantID: String?
        var takes: [WTake]
        /// Which of U-5's four the sheet is showing. `keepOnTop` on open.
        var arrangement: Arrangement = .keepOnTop
        var id: String { blockID }

        /// The take the gesture was placed in — the one that actually
        /// splits under every preset.
        var seedTake: WTake? {
            takes.first { $0.id == activeVariantID }
        }

        /// The other live active takes, i.e. what an arrangement arranges.
        var otherTakes: [WTake] {
            takes.filter { $0.id != activeVariantID }
        }

        /// Takes a preset cannot place: an EMPTY take has no legal cut at
        /// all (0 and its end coincide), so it cannot park and stays on the
        /// original block in lineage — `KeepOnTopDivide.unparkable`'s own
        /// rule, read off the same fact.
        var unparkableTakes: [WTake] {
            otherTakes.filter { $0.variant.workingText.isEmpty }
        }

        /// Confirm gates on the WHOLE rule, with the reason spoken (13b 4A,
        /// the architect's precision): every marked take placed, AND each
        /// successor block born with at least one take — if every checked
        /// take parks at one end, the other block would be takeless (I10).
        /// nil = confirmable. The op's `divideSideWouldBeEmpty` is the belt
        /// behind this gate.
        ///
        /// **Under a PRESET the whole arrangement is placed for her**, so
        /// the only thing left to gate is the seed take's own ✂: unplaced,
        /// or parked at the end that would leave a successor takeless. Each
        /// preset's guard is the operation's own refusal (`divideW`'s
        /// `divideSideWouldBeEmpty`, `divideDuplicating`'s `invalidCut`)
        /// said before the fact rather than after it.
        var confirmBlocker: String? {
            guard arrangement == .perTake else { return presetBlocker }
            let marked = takes.filter(\.marked)
            if marked.isEmpty {
                return "Check at least one take to carry the cut through."
            }
            if marked.contains(where: { $0.cut == nil }) {
                return "Place the ✂ in every checked take — drag it, click a spot, or use ←/→ (⇥ moves between takes)."
            }
            if !marked.contains(where: { !$0.parkedAtEnd }) {
                return "Every checked take rides whole into the first block — the second block would be born without a take. Split at least one, or park one at its start."
            }
            if !marked.contains(where: { !$0.parkedAtStart }) {
                return "Every checked take rides whole into the second block — the first block would be born without a take. Split at least one, or park one at its end."
            }
            return nil
        }

        private var presetBlocker: String? {
            guard let seed = seedTake else {
                return "This block's takes changed — try the divide again."
            }
            guard seed.cut != nil else {
                return "Place the \u{2702} in the take you're dividing — drag it, "
                    + "click a spot, or use \u{2190}/\u{2192}."
            }
            switch arrangement {
            case .copyToBoth where seed.parkedAtEnd || seed.parkedAtStart:
                return "Copying the takes to both blocks needs a cut INSIDE this take — "
                    + "move the \u{2702} off the end."
            case .keepOnTop where seed.parkedAtEnd:
                return "The \u{2702} is at this take's very end and every other take stays "
                    + "on the top block — the bottom block would be born without a take. "
                    + "Move the \u{2702} into the text."
            case .keepOnBottom where seed.parkedAtStart:
                return "The \u{2702} is at this take's very start and every other take goes "
                    + "to the bottom block — the top block would be born without a take. "
                    + "Move the \u{2702} into the text."
            default:
                return nil
            }
        }

        var canConfirm: Bool { confirmBlocker == nil }

        var markedCuts: [String: Int] {
            Dictionary(uniqueKeysWithValues: takes.compactMap { take in
                guard take.marked, let cut = take.cut else { return nil }
                return (take.variant.id, cut)
            })
        }
    }

    struct WTake: Equatable, Identifiable {
        let variant: Variant
        var marked: Bool
        /// The cut carried through this take (UTF-16, any legal word-rule
        /// position of its text INCLUDING 0 and the end — parking, S4-22) —
        /// pre-seeded by string-context matching, freely adjusted; nil =
        /// unseeded (no unique match) until placed.
        var cut: Int?
        /// The legal cut positions in this take's text under the ruled
        /// WORD rule, ends included (the parking slots) — the click/drag/
        /// keyboard targets. Empty exactly when the take's text is empty
        /// (0 and the end coincide: nothing to place — uncheck it).
        let boundaries: [Int]
        /// The STRONG positions among them — sentence ends, newlines and the
        /// two text edges. Derived ONCE here (QoL round L1): the sheet used to
        /// re-derive this with a full sentence scan of the take's text once
        /// PER SLOT per body pass, and ~2 per candidate per drag sample, which
        /// is the beachball she reported.
        let strongBoundaries: Set<Int>
        /// The take's text as the alternating slot/token sequence the sheet
        /// draws. Also derived once here, for the same reason.
        let flow: [WCutPlacement.FlowItem]
        /// `nonisolated` for the same reason `init` is: the arrangement brain
        /// (`arranged`) runs off the main actor when the ceremony opens.
        nonisolated var id: String { variant.id }

        /// ONE derivation per take: the legal cuts, the strong subset and the
        /// draw/hit-test flow all come from the take's text here, at
        /// construction, and nothing downstream re-derives them.
        /// `nonisolated` so `open`'s derivation can run OFF the main actor —
        /// the whole point of doing it once per take is that the gesture never
        /// blocks the UI on scanning.
        nonisolated init(variant: Variant, marked: Bool, cut: Int?, text: String) {
            self.variant = variant
            self.marked = marked
            self.cut = cut
            let boundaries = DivideWCeremony.legalCutPositions(of: text)
            self.boundaries = boundaries
            let strong = Set(
                BoundarySnapping.boundaries(in: text, granularity: .sentence))
            self.strongBoundaries = strong.intersection(boundaries)
                .union([0, text.utf16.count].filter { boundaries.contains($0) })
            self.flow = WCutPlacement.flowItems(text: text, boundaries: boundaries)
        }

        /// Parking (S4-22 ruling 2): at the very end ⇒ the whole take
        /// rides into the FIRST block; at the very start ⇒ the SECOND.
        var parkedAtEnd: Bool {
            cut != nil && cut == variant.workingText.utf16.count
                && !variant.workingText.isEmpty
        }
        var parkedAtStart: Bool {
            cut == 0 && !variant.workingText.isEmpty
        }
    }

    // MARK: - Opening

    /// Builds the one-sheet ceremony state: the block's live ACTIVE fan as
    /// a checklist (the SEED take pre-marked with the gesture's snapped
    /// cut — nil when its text has no interior word edge; the ceremony
    /// still opens and parking covers it, 13b 4A), per-take cut proposals
    /// by string-context matching from the seed's text, per-take legal cut
    /// positions under the ruled WORD rule (ends included — the parking
    /// slots). The surface's pending text flushes first so every take's
    /// stored text — what the sheet shows and the op will cut — matches
    /// what the author sees. No rows are touched by opening.
    func open(blockID: String, seedVariantID: String?, seedCut: Int?) async {
        guard await host.flushPendingText() else { return }
        do {
            let fan = try await host.ceremonyDatabase.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            guard liveActive.count > 1,
                  let seedTake = liveActive.first(where: { $0.id == seedVariantID })
            else {
                // The fan changed under us (sync race): re-plan next invoke.
                host.speakCeremonyStatus("This block's takes changed — try the divide again.")
                return
            }
            // The per-take derivation — boundaries, the strong set, the flow,
            // and the propagated proposals — is real O(text) work per take, so
            // it runs OFF the main actor (QoL round L1). Opening the ceremony
            // on four long takes must never block the UI on scanning.
            // U-3/U-5: the sheet OPENS arranged — every take checked and the
            // non-seed ✂ parked at the END, because that is what her default
            // preset (keep on top) means. `CutPropagation`'s proposal is
            // therefore no longer the opening position on this road; it
            // survives where it still answers a real question — re-seeding a
            // take whose text drifted under an open sheet (`refresh`), and
            // Make Block's cross-take mapping.
            let takes = await Task.detached(priority: .userInitiated) {
                Self.arranged(
                    liveActive.map { variant in
                        WTake(
                            variant: variant,
                            marked: variant.id == seedTake.id,
                            cut: variant.id == seedTake.id ? seedCut : nil,
                            text: variant.workingText)
                    },
                    as: .keepOnTop, seedID: seedTake.id)
            }.value
            state = State(
                blockID: blockID, activeVariantID: seedTake.id, takes: takes,
                arrangement: .keepOnTop)
        } catch {
            host.speakCeremonyError(error)
        }
    }

    /// A take's placeable cut positions: the ruled WORD rule's full set —
    /// word edges, sentence ends, newlines, AND both ends (0 = start
    /// parking, the end = end parking; S4-22 ruling 2). Empty text answers
    /// [] — its two ends coincide, so there is nothing to place (the memo's
    /// "uncheck it" case, and the one genuinely-empty message left).
    nonisolated static func legalCutPositions(of text: String) -> [Int] {
        guard !text.isEmpty else { return [] }
        return BoundarySnapping.boundaries(in: text, granularity: .word)
    }

    // MARK: - The arrangement (U-5 / U-3)

    /// **Applies an arrangement to a fan — the ONE seeding brain.**
    ///
    /// The two parking presets go THROUGH `KeepOnTopDivide` rather than
    /// re-deriving its arithmetic, which is what makes "confirming the sheet
    /// unchanged reproduces the instant divide byte-for-byte" true by
    /// construction instead of by a pin's hope (the composition is the
    /// instant default's own; two homes of one rule is how a rule drifts —
    /// that file's own words).
    ///
    /// The SEED take is never re-placed: its ✂ is the gesture's, and hers
    /// once she moves it, so switching presets rearranges the OTHERS around
    /// it. `copyToBoth` gives the others no ✂ at all — they are not cut,
    /// they are duplicated — and `perTake` fills any unplaced ✂ with the
    /// take's END, which IS her U-3 default ("should automatically have the
    /// scissors at the end") and leaves a hand-placed cut alone.
    ///
    /// An EMPTY take can never be placed (`legalCutPositions` is empty), so
    /// the parking presets leave it unmarked — it stays on the original
    /// block in lineage, exactly as `KeepOnTopDivide.unparkable` reports it
    /// for the instant road.
    nonisolated static func arranged(
        _ takes: [WTake], as arrangement: Arrangement, seedID: String?
    ) -> [WTake] {
        switch arrangement {
        case .keepOnTop, .keepOnBottom:
            let seedCut = takes.first { $0.id == seedID }?.cut
            let fan = takes.map(\.variant)
            // The seed's own cut rides through `compose` untouched, so the
            // placeholder used when it is still unplaced never reaches a
            // take: only the OTHERS' parking is read off the composition.
            let composition = arrangement == .keepOnTop
                ? KeepOnTopDivide.compose(displayedID: seedID, cut: seedCut ?? 0, fan: fan)
                : KeepOnTopDivide.compose(keepBelow: seedID, cut: seedCut ?? 0, fan: fan)
            guard let composition else { return takes }
            return takes.map { take in
                var next = take
                if take.id == seedID {
                    next.marked = true
                } else if let cut = composition.cuts[take.id] {
                    next.marked = true
                    next.cut = cut
                } else {
                    next.marked = false
                    next.cut = nil
                }
                return next
            }
        case .copyToBoth:
            return takes.map { take in
                var next = take
                next.marked = true
                if take.id != seedID { next.cut = nil }
                return next
            }
        case .perTake:
            return takes.map { take in
                var next = take
                guard take.id != seedID else {
                    next.marked = true
                    return next
                }
                let end = take.variant.workingText.utf16.count
                guard end > 0 else { return next }
                next.marked = true
                if next.cut == nil { next.cut = end }
                return next
            }
        }
    }

    /// Switches the row. Nothing is written to the store — the sheet has
    /// touched no rows since 13b 4A and still doesn't.
    func setArrangement(_ arrangement: Arrangement) {
        guard var current = state, current.arrangement != arrangement else { return }
        current.arrangement = arrangement
        current.takes = Self.arranged(
            current.takes, as: arrangement, seedID: current.activeVariantID)
        state = current
    }

    /// **The one sentence under the row** — the mockup's, in counts, a pure
    /// function of the state so it is pinned rather than read off a
    /// screenshot (the `FannedDefaultsCopy` doctrine: a sentence may only
    /// claim what the operation will actually do).
    nonisolated static func arrangementSentence(
        _ arrangement: Arrangement, others: Int, unparkable: Int
    ) -> String {
        func takes(_ n: Int) -> String { n == 1 ? "1 other take" : "\(n) other takes" }
        let stranded = unparkable == 0
            ? ""
            : (unparkable == 1
                ? " 1 empty take can't be placed and stays with the original block."
                : " \(unparkable) empty takes can't be placed and stay with the original block.")
        switch arrangement {
        case .keepOnTop:
            return "The take you were in splits at the \u{2702}. \(takes(others)) stay whole "
                + "on the top block; the bottom block starts with one take.\(stranded) "
                + "Reversible — \u{2325}\u{2318}Z."
        case .keepOnBottom:
            return "The take you were in splits at the \u{2702}. \(takes(others)) stay whole "
                + "on the bottom block; the top block starts with one take.\(stranded) "
                + "Reversible — \u{2325}\u{2318}Z."
        case .copyToBoth:
            return "The take you were in splits at the \u{2702}. \(takes(others)) ride whole "
                + "onto BOTH blocks — the extra copies are quick to delete. "
                + "Reversible — \u{2325}\u{2318}Z."
        case .perTake:
            return "Each \u{2702} splits its take; \u{2702} at the very END keeps the whole "
                + "take on the top block, at the very START on the bottom. An unchecked "
                + "take is not cut and stays on the original block, in lineage. "
                + "\u{21E5} moves between takes."
        }
    }

    /// The per-row line under a take that a PRESET placed — what happens to
    /// THIS take, where she is looking (the 13f W10a doctrine).
    nonisolated static func presetRowNote(
        _ arrangement: Arrangement, isSeed: Bool, isEmpty: Bool
    ) -> String? {
        guard !isSeed else { return nil }
        switch arrangement {
        case .keepOnTop:
            return isEmpty
                ? "Empty — it can't be placed, so it stays whole on the original block."
                : "\u{2702} at the end — this whole take stays on the top block."
        case .keepOnBottom:
            return isEmpty
                ? "Empty — it can't be placed, so it stays whole on the original block."
                : "\u{2702} at the start — this whole take stays on the bottom block."
        case .copyToBoth:
            return "Not cut — this whole take rides onto BOTH blocks."
        case .perTake:
            return nil
        }
    }

    // MARK: - Placement

    func toggleTake(_ takeID: String) {
        guard var current = state,
              let i = current.takes.firstIndex(where: { $0.id == takeID }) else { return }
        current.takes[i].marked.toggle()
        state = current
    }

    /// **HER RULING (2026-07-29, selection: "Check it").** A click on a take's
    /// ROW: an UNCHECKED take is checked (and aimed at); a checked take is only
    /// aimed at. Before this, a click on an unchecked row did nothing at all —
    /// a silent dead click, the fire-and-DO class (P-2), and plausibly why the
    /// checkbox and the `›` marker read to her as one control.
    ///
    /// It lives here rather than in the row's `onTapGesture` so the rule is one
    /// sentence in one place and can be pinned without driving SwiftUI's
    /// gesture machinery. Returns the take to aim the arrow keys at.
    @discardableResult
    func rowTapped(_ takeID: String) -> String? {
        guard let take = state?.takes.first(where: { $0.id == takeID }) else { return nil }
        if !take.marked { toggleTake(takeID) }
        return takeID
    }

    func placeCut(takeID: String, cut: Int) {
        guard var current = state,
              let i = current.takes.firstIndex(where: { $0.id == takeID }),
              current.takes[i].boundaries.contains(cut) else { return }
        current.takes[i].cut = cut
        state = current
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancel() {
        state = nil
    }

    // MARK: - Confirm

    func confirm() async {
        guard let current = state, current.canConfirm else { return }
        // The one-flight door, checked synchronously BEFORE the drift
        // check's await (review round 3, MINOR): a gesture can be mid-
        // flight while the sheet is up (menu key equivalents stay live
        // under a window-modal sheet) — refuse visibly and KEEP the
        // ceremony and its cuts; the host's own door is the belt behind
        // this.
        guard !host.structuralFlightInProgress else {
            host.speakCeremonyRefusal("Another structural change is still landing.")
            return
        }
        let cuts = current.markedCuts
        let blockID = current.blockID
        let arrangement = current.arrangement
        let seedID = current.activeVariantID
        // The sheet may have sat open while a sync round landed edits to
        // the takes (review round 2, MINOR): cuts were placed against the
        // SNAPSHOT texts, and cutting the current store at those offsets
        // would land a well-formed but wrong-position cut, silently. Verify
        // every marked take against the CURRENT store first; on any drift,
        // refresh the ceremony (marks kept, cuts re-seeded) instead.
        do {
            let fan = try await host.ceremonyDatabase.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            let drifted = current.takes.filter(\.marked).contains { snapshot in
                guard let live = liveActive.first(where: { $0.id == snapshot.id })
                else { return true }  // a marked take vanished (deleted/archived remotely)
                return live.workingText != snapshot.variant.workingText
            }
            if drifted {
                refresh(from: current, liveActive: liveActive)
                return
            }
        } catch {
            host.speakCeremonyError(error)
            return
        }
        // Accepted residual (review round 3, NIT — same class as the
        // ceremony-open flush→fetch window): the drift check above is
        // check-then-act — a sync apply committing in the ms between that
        // read and the op below still lands a stale-offset cut. A true fix
        // needs op-level expected-text preconditions (a core change this
        // phase has no cause to make); the cut stays well-formed,
        // recoverable by undo, and the window is delivery-cadence narrow.
        // The confirm ROAD is the arrangement's own operation (U-5): the two
        // parking presets and the hand-placed sheet are all `divideW`
        // arrangements, while "copy takes to both" is `divideDuplicating` —
        // riding whole onto BOTH successors is not something a per-take cut
        // can express, which is exactly why 13j's retired default stayed in
        // core.
        //
        // The SEED rides as `displayedVariantID` on every `divideW` road, so
        // both successors show the take she was working in (18c batch 1's
        // arm; QUESTIONS #91's built answer, applied at the sheet's confirm
        // for the same reason it is applied at the instant door). An
        // unchecked seed is not in `cuts` and the op falls back to A's
        // rendered take by construction.
        let landed: Bool
        if arrangement == .copyToBoth {
            guard let seedID, let seedCut = current.seedTake?.cut else {
                host.speakCeremonyStatus(FannedDefaultsCopy.takesChangedDivide)
                return
            }
            landed = await host.runDivideDuplicating(
                blockID: blockID, displayedVariantID: seedID, cut: seedCut)
        } else {
            landed = await host.runDivideW(
                blockID: blockID, cuts: cuts, displayedVariantID: seedID)
        }
        // The sheet dismisses only when the cut LANDED — a refusal (busy
        // door, op error) keeps the ceremony and its cuts for the author.
        if landed {
            // 13f W10a (her sitting question, verbatim: *"it says … it stays
            // whole on the original one, but how do I even see the original
            // one?"*). The ceremony always said WHAT happens to an unchecked
            // take and never WHERE the block carrying it goes — so the answer
            // rides the completion, in the ratified `⌥⌘Z undoes it` grammar.
            // Spoken through the host's own status voice: Write shows it in
            // the toast, a board in its status line, no new mechanism.
            if let note = Self.releasedOriginalNote(
                uncheckedTakes: current.takes.count(where: { !$0.marked })) {
                host.speakCeremonyStatus(note)
            }
            state = nil
        }
    }

    // MARK: - Copy (13f W10a — pinned, never read off a screenshot)

    /// The sheet's checklist explainer. It lives here, beside the completion
    /// note, because the two sentences make ONE promise — what an unchecked
    /// take does, and where the block carrying it ends up — and her sitting
    /// question was exactly the half that was missing.
    nonisolated static var checklistExplainer: String {
        "**Check the takes that should be cut.** Each checked take carries "
            + "its own \u{2702}, and its two halves become the two new blocks' "
            + "takes. **An unchecked take is not cut and goes into neither new "
            + "block** — it stays whole on the original block, which the divide "
            + "keeps and releases to \(TrayPath.originalsPathWithDoor)."
    }

    /// The per-row caption under an unchecked take — the same answer where
    /// she was actually looking when she asked.
    nonisolated static var uncheckedRowNote: String {
        "Not cut — stays whole on the original block, which waits in "
            + "\(TrayPath.originalsPath)."
    }

    /// The completion's destination sentence — pure, so the copy is pinned
    /// rather than read off a screenshot. `nil` when every take was checked:
    /// the original is still released (the W always preserves A whole), but
    /// it carries nothing she wasn't shown, and a note on every divide would
    /// be noise where the ruling asked for an answer.
    nonisolated static func releasedOriginalNote(uncheckedTakes: Int) -> String? {
        guard uncheckedTakes > 0 else { return nil }
        let takes = uncheckedTakes == 1 ? "1 uncut take" : "\(uncheckedTakes) uncut takes"
        return "Divided — the original block kept \(takes) and waits in "
            + "\(TrayPath.originalsPathWithDoor). \u{2325}\u{2318}Z undoes the divide."
    }

    /// Rebuilds the ceremony over the CURRENT fan: marks survive by take
    /// identity, unchanged takes keep their placed cuts, changed takes get
    /// re-seeded cuts (the seed take's cut re-snapped into its new text;
    /// others re-proposed from it via string-context matching). The author
    /// reviews and confirms again — nothing is cut on a drifted snapshot.
    private func refresh(from current: State, liveActive: [Variant]) {
        guard liveActive.count > 1,
              let seedCurrent = liveActive.first(where: { $0.id == current.activeVariantID })
        else {
            // The fan itself dissolved (a single take remains, or the seed
            // take died): the ceremony no longer applies.
            state = nil
            host.speakCeremonyStatus("This block's takes changed — try the divide again.")
            return
        }
        let previous = Dictionary(uniqueKeysWithValues: current.takes.map { ($0.id, $0) })
        let previousSeed = previous[seedCurrent.id]
        let seedCut: Int? = {
            guard let cut = previousSeed?.cut else { return nil }
            if previousSeed?.variant.workingText == seedCurrent.workingText { return cut }
            return StructuralGesturePlanner.snapToInteriorBoundary(
                cut, in: seedCurrent.workingText)
        }()
        let takes = liveActive.map { variant -> WTake in
            let old = previous[variant.id]
            let cut: Int?
            if variant.id == seedCurrent.id {
                cut = seedCut
            } else if old?.variant.workingText == variant.workingText, let kept = old?.cut {
                cut = kept
            } else if let seedCut {
                cut = CutPropagation.propose(
                    activeCut: seedCut,
                    activeText: seedCurrent.workingText,
                    targetText: variant.workingText)
            } else {
                cut = nil
            }
            return WTake(
                variant: variant,
                marked: old?.marked ?? false,
                cut: cut,
                text: variant.workingText)
        }
        // The ARRANGEMENT survives a drift refresh — she chose it, and a
        // preset re-places every ✂ over the refreshed texts anyway (which is
        // the honest answer: a preset is a rule, not a set of positions).
        state = State(
            blockID: current.blockID, activeVariantID: seedCurrent.id,
            takes: Self.arranged(
                takes, as: current.arrangement, seedID: seedCurrent.id),
            arrangement: current.arrangement)
        host.speakCeremonyStatus("This block's takes changed while the sheet was open — the cuts were re-proposed; review before dividing.")
    }
}
