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
/// six members: the store, the surface's pending-text contract, the
/// one-flight door, the act, and the two voices. A host that can answer
/// these can mount the ceremony; nothing else about Write is required.
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
    func runDivideW(blockID: String, cuts: [String: Int]) async -> Bool
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

    struct State: Equatable, Identifiable {
        let blockID: String
        /// The SEED take — the one the author was looking at when the
        /// divide was invoked. Pre-marked, its cut pre-placed at the
        /// gesture's snapped position; every other take's proposal
        /// propagates from THIS take's text.
        let activeVariantID: String?
        var takes: [WTake]
        var id: String { blockID }

        /// Confirm gates on the WHOLE rule, with the reason spoken (13b 4A,
        /// the architect's precision): every marked take placed, AND each
        /// successor block born with at least one take — if every checked
        /// take parks at one end, the other block would be takeless (I10).
        /// nil = confirmable. The op's `divideSideWouldBeEmpty` is the belt
        /// behind this gate.
        var confirmBlocker: String? {
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
        var id: String { variant.id }

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
            let takes = liveActive.map { variant in
                WTake(
                    variant: variant,
                    marked: variant.id == seedTake.id,
                    cut: variant.id == seedTake.id
                        ? seedCut
                        : seedCut.flatMap {
                            CutPropagation.propose(
                                activeCut: $0,
                                activeText: seedTake.workingText,
                                targetText: variant.workingText)
                        },
                    boundaries: Self.legalCutPositions(of: variant.workingText))
            }
            state = State(
                blockID: blockID, activeVariantID: seedTake.id, takes: takes)
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

    // MARK: - Placement

    func toggleTake(_ takeID: String) {
        guard var current = state,
              let i = current.takes.firstIndex(where: { $0.id == takeID }) else { return }
        current.takes[i].marked.toggle()
        state = current
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
        let landed = await host.runDivideW(blockID: blockID, cuts: cuts)
        // The sheet dismisses only when the cut LANDED — a refusal (busy
        // door, op error) keeps the ceremony and its cuts for the author.
        if landed {
            state = nil
        }
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
                boundaries: Self.legalCutPositions(of: variant.workingText))
        }
        state = State(
            blockID: current.blockID, activeVariantID: seedCurrent.id, takes: takes)
        host.speakCeremonyStatus("This block's takes changed while the sheet was open — the cuts were re-proposed; review before dividing.")
    }
}
