//
//  TailCrystallizer.swift
//  Variorum / VariorumMobile (Shared/EditorBrain)
//
//  **18m U2 — TYPE-TIME CRYSTALLIZATION'S CONDUCTOR, ONCE FOR BOTH
//  PLATFORMS.** AppSpec §7: brand-new text at the end of a post is an OPEN
//  TAIL, and it crystallizes into blocks paragraph by paragraph as she types
//  past them — and, after a short quiet gap, whole (the idle mint; author
//  decision 2026-07-06). The PLANS were already one brain
//  (`CrystallizationPlanner`, `CrystallizationReconciler`, `BlockRangeIndex`);
//  the CONDUCTOR that runs them — the idle clock, the mint flight, the
//  leading-run attachment, the reconcile-and-apply — lived twice, line for
//  line, in `EditorViewModel` and `MobileEditorViewModel` (the post-13u
//  health review §3; the 18m U2 band map). It lives here now.
//
//  **The shape (the 18m U2 ruling, (B)).** This object OWNS the band's own
//  state — the tail's text, the mint flight and its task, the idle clock —
//  and each view model owns ONE of it (a downward reference only). Everything
//  else the band touches is the view model's, reached through a
//  `TailCrystallizerHost` that the view model passes ITSELF as, PER CALL:
//  nothing here stores a model. The two Tasks capture the host exactly as the
//  pre-move Tasks captured `self` — strongly for the mint (review round 1,
//  MINOR 5: the reconciliation must run even if the view goes away), weakly
//  for the idle clock.
//
//  **Why a reference type and not a value struct passed `inout`** (the
//  record's constraint, adopted by the ruling): the band's storage writes
//  re-enter the view model SYNCHRONOUSLY — `NSTextStorage.processEditing`
//  reports every character edit to `storageDidEdit`, and on the Mac AppKit's
//  selection-change delegate runs `updateCaretContext`, which reads the
//  tiling — so an `inout` hold on view-model state spanning such a write is a
//  dynamic exclusivity violation. The VALUE seam holds the pure layer (the
//  planner, the reconciler, the index); this object holds the choreography.
//
//  **The DECLARED platform deltas** stay declared, never averaged: the Mac's
//  structural-flight hold (`TailCrystallizerHost.holdsTailForStructuralFlight`)
//  and its caret-context republish (`didApplyMint`), each platform's
//  marked-text accessor and error voice, each platform's settle road. Two
//  deltas deliberately live OUTSIDE this band and call into it through the
//  view model's forwards: the Mac's ⇧⏎ tail arm (`runSoftNewlineInTail` —
//  13d batch 4, A15 option B; the phone has no soft newline) and the phone's
//  `restampProjection` (iOS strips custom attributes on every insertion path,
//  so its consume road re-stamps; the Mac's clamps — two implementations of
//  TEXTKIT2 §3's one rule).
//
//  Charter (EditorDocumentCore's): NOTHING here may depend on a platform UI
//  framework — no AppKit/UIKit; Foundation, VariorumCore and UI-free
//  `Shared/` types only (the 18m U2 ladder's wording: this file also leans
//  on `AutosaveCoordinator`, `OperationsRunner` and `EditorSurfaceStorage`,
//  each itself platform-free).
//

import Foundation
import VariorumCore

// MARK: - The host (the view model's side of the band — per member, who needs it)

/// **What the crystallizer needs from the surface it serves — and nothing
/// else** (the 18m U2 ruling's condition 1: every member names the band
/// function that needs it, so a reviewer can see there is no general-purpose
/// door here). The view models conform in their own files, where these doors
/// can reach their `private` state; their `private(set)` surfaces are
/// unchanged. The platform DIFFERENCES are the ACCESSOR and DECLARED members;
/// the rest is state the band genuinely shares with the gate and the
/// projection roads, exposed as narrow intention-revealing doors instead of
/// widened setters.
@MainActor
protocol TailCrystallizerHost: AnyObject {
    // MARK: The tiling — the view model OWNS it; these are the band's doors

    /// The live tiling. Read by `isMintable` (is a tail region open),
    /// `attachLeadingTailRunIfNeeded` (the last entry and its range),
    /// `crystallizeIfNeeded` (is the tail still open after the attachment)
    /// and `finishMint` (the tail region before the apply; the entries and
    /// their ranges after it).
    var index: BlockRangeIndex { get }
    /// `attachLeadingTailRunIfNeeded` only: the tail's leading newline run
    /// becomes the last entry's trailing content
    /// (`BlockRangeIndex.transferTailPrefixToLastEntry`).
    func transferTailPrefixToLastEntry(_ units: Int)
    /// `finishMint` only: the minted blocks join the tiling
    /// (`BlockRangeIndex.crystallize`).
    func crystallizeIndex(
        minted: [(blockID: String, variantID: String, length: Int)],
        remainingTailLength: Int?)
    /// `attachLeadingTailRunIfNeeded` only: what the surface is known to hold
    /// for the last entry's variant (the ledger — read, never the surface, so
    /// the attachment works with the view already gone at teardown).
    func surfaceKnownText(variantID: String) -> String?
    /// `attachLeadingTailRunIfNeeded` and `finishMint`: the ledger learns
    /// what the surface now holds for a variant.
    func recordSurfaceText(variantID: String, text: String)

    // MARK: Routing and settle state — the view model keeps it

    /// `crystallizeIfNeeded`: a paste landed in the tail, so the next plan
    /// segments as BULK entry (armed beside the gate's verdict — NIT 4).
    var pendingBulkEntry: Bool { get }
    /// `crystallizeIfNeeded`: the bulk intent is consumed (or has nothing
    /// left to apply to).
    func clearBulkPending()
    /// `finishMint`: a verdict armed before the mint describes a tail that
    /// may no longer exist — disarm it (the sharpest stale case).
    /// `attachLeadingTailRunIfNeeded`: the attachment moves the tiling by an
    /// equal-length transfer the binding's length oracle cannot see (VM-5
    /// stability pass, MINOR 3). Clears the ARMING only — never the paste's
    /// bulk intent, which both callers may still be carrying on purpose.
    func disarmPendingEdit()
    /// `finishMint`: the reconciler asked for a re-render from the store, or
    /// the tail region vanished under the flight.
    func requestFullRender()
    /// `finishMint`: our mint's writes settled — the store-write freshness
    /// generation moves (MAJOR 3's fence, read by the settle road).
    func noteOwnWritesSettled()

    // MARK: The store

    /// `attachLeadingTailRunIfNeeded` and `finishMint` (the corrections and
    /// their flush): the ONE per-post autosave coordinator.
    var autosave: AutosaveCoordinator { get }
    /// `crystallizeIfNeeded` (the mint) and `finishMint` (the quiet
    /// compensating deletions): the serial operations runner.
    var mintRunner: OperationsRunner { get }
    /// `crystallizeIfNeeded`: the post the tail's blocks are minted into.
    var postID: String { get }
    /// `idleMintTail` and `crystallizeIfNeeded`: the note's effective
    /// segmentation (the chip; `.paragraph` before a header has arrived).
    var segmentationMode: Segmentation { get }

    // MARK: ACCESSORS — the platform differences the band injects

    /// `attachLeadingTailRunIfNeeded` and `finishMint`: the surface's storage
    /// for the identity stamps (Mac `textView?.textStorage`; phone the
    /// attached `storage`).
    var surfaceStorage: NSMutableAttributedString? { get }
    /// `idleMintTail`: an input-method composition is open (Mac
    /// `hasMarkedText()`; phone `markedTextRange != nil`).
    var surfaceHasMarkedText: Bool { get }
    /// `crystallizeIfNeeded` and `finishMint`: the platform's error voice
    /// (Mac `showOperationError`; phone the status line's description).
    func reportOperationError(_ error: Error)
    /// `finishMint`: the tail region rewritten to the reconciled text,
    /// through the view model's one programmatic write door (caret kept at
    /// the end when it was there).
    func replaceTailRegion(_ region: NSRange, with normalized: String)
    /// `finishMint`: undo entries recorded against the old tail would replay
    /// at stale offsets — drop them.
    func clearTextUndo()
    /// `finishMint`: the DEBUG identity oracle, after the hand-made stamps.
    func auditIdentityProjection()

    // MARK: DECLARED platform arms (never averaged — each with its reason)

    /// `idleMintTail` and `attachLeadingTailRunIfNeeded`: hold the tail for a
    /// structural flight. **Mac: `structuralInFlight`** — its flight rewrites
    /// the surface ITSELF after the op (`applyStructuralResult`), bypassing
    /// the projection policy, so a mint born mid-flight could materialize the
    /// minted block beside the unconsumed tail and crystallize a duplicate
    /// index entry (Phase 9 review round 1, MAJOR; pinned
    /// `anIdleMintIsNeverBornMidStructuralFlight`). **Phone: `false`** — its
    /// structural doors settle through `ingest` → the projection policy,
    /// whose busy arm defers while a mint is in flight, so that hazard cannot
    /// arise there (18m U2's probe P-a: 14 interleavings, every one
    /// convergent).
    var holdsTailForStructuralFlight: Bool { get }
    /// `finishMint`, after the audit: **Mac `updateCaretContext()`** — it
    /// keeps an OBSERVED caret context (block, ordinal, word counts, gesture
    /// availability) that must republish when the caret's text leaves the
    /// tail for a block. **Phone: nothing** — it keeps no view-model caret
    /// projection, and a fresh mint carries no chrome.
    func didApplyMint()
    /// `crystallizeIfNeeded` (a failed mint) and `finishMint` (every exit):
    /// each platform's OWN settle road — the deferred projection re-read
    /// fresh (kept per-platform at 18m U2: the two re-read different
    /// projections and the phone's lacks 17b P36 — F-2).
    func applyPendingIfClean()
}

// MARK: - The crystallizer

@MainActor
final class TailCrystallizer {
    /// The open tail's text as the surface holds it (was each view model's
    /// `tailText`, which is now a read forward of this).
    private(set) var text = ""
    /// One mint batch is in flight at a time.
    private(set) var mintInFlight = false
    private(set) var mintTask: Task<Void, Never>?
    private var idleTask: Task<Void, Never>?

    // Idle-mint (author decision 2026-07-06, review round — QUESTIONS item
    // 2 answered): a short quiet gap crystallizes the open tail, including
    // the trailing partial paragraph, bounding crash loss to seconds like
    // every other edit; teardown stays the backstop. Granularity is
    // paragraph in EVERY mode (author ruling on QUESTIONS item 3).
    var idleDebounce: Duration = .seconds(2)
    /// Injectable for deterministic tests (default: the real clock).
    var idleSleep: @Sendable (Duration) async throws -> Void =
        { try await Task.sleep(for: $0) }

    init() {}

    // MARK: The tail text's two outside writers

    /// The view models' non-band sites that set the tail: a render adopting
    /// the tail it preserved, `.openTail`/`.closeTail`, the tail re-read after
    /// a tail edit.
    func setText(_ text: String) {
        self.text = text
    }

    /// Holds (cancels) the idle-mint clock — `.closeTail`, the teardown
    /// backstops, and the Mac's structural flight (re-armed at flight end).
    func cancelIdleClock() {
        idleTask?.cancel()
    }

    // MARK: The band

    /// Whether the open tail holds anything the ratified rules would mint —
    /// the SAME guard the idle mint and the teardown backstops apply (a
    /// whitespace-only tail never mints). Read by the Mac's A15 B2 fork so the
    /// two can never disagree about what "mintable" means.
    func isMintable(host: some TailCrystallizerHost) -> Bool {
        host.index.tailLength != nil && !text.allSatisfy(\.isWhitespace)
    }

    /// Re-arms the idle-mint clock after tail activity (author decision
    /// 2026-07-06: the open tail crystallizes after a short quiet gap, so
    /// crash loss is bounded to seconds; teardown remains the backstop).
    func armIdleMint(host: some TailCrystallizerHost) {
        idleTask?.cancel()
        guard isMintable(host: host) else { return }
        idleTask = Task { [weak self, weak host, idleSleep, idleDebounce] in
            guard (try? await idleSleep(idleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            guard let host else { return }
            self?.idleMintTail(host: host)
        }
    }

    /// The idle-mint itself — tests fire it deterministically through the
    /// view models' forwards. Typing granularity is paragraph in EVERY mode
    /// (author ruling): the whole tail mints, trailing partial paragraph
    /// included, tail closes — with the `.idle` kind preserving a trailing
    /// typed newline run (k−1).
    func idleMintTail(host: some TailCrystallizerHost) {
        guard isMintable(host: host) else { return }
        // A structural gesture is mid-flight — the DECLARED arm (see
        // `TailCrystallizerHost.holdsTailForStructuralFlight`; the Mac's
        // Phase 9 review round 1, MAJOR): skip this tick and re-arm; the
        // flight's defer re-arms too.
        if host.holdsTailForStructuralFlight {
            armIdleMint(host: host)
            return
        }
        // Marked text is an in-progress input-method composition, not yet
        // the author's text (review round 2): minting under it would rewrite
        // the region mid-composition. Skip this tick and re-arm the clock (on
        // iOS multi-stage input is COMMON, so this guard earns its keep).
        if host.surfaceHasMarkedText {
            armIdleMint(host: host)
            return
        }
        let mode = host.segmentationMode
        // The .idle kind (round 1, MAJOR 2): the durability mint must never
        // collapse a pending typed gap — the trailing run survives.
        crystallizeIfNeeded(
            forcedKind: CrystallizationPlanner.kindForDurabilityMint(mode: mode), host: host)
    }

    /// The leading-run attachment (author ruling 2026-07-12; Phase 10
    /// review round 1, MAJOR 2's fix): a tail that STARTS with newlines
    /// sits after a preceding block — under the ruling those newlines are
    /// that block's trailing CONTENT (the k−1 rule; the tail separator is
    /// the +1). The surface BYTES never change: the block's range grows
    /// over the run, the separator conceptually slides to the run's end,
    /// and the store follows through an ordinary autosave (read from the
    /// Step-1 surface-text map, so this works even when the view is
    /// already gone at teardown). Fires when the .idle mint leaves its
    /// kept-open run behind AND when Enters land in a reopened tail — a
    /// typed gap is durable content the moment it exists, successor or
    /// not (the "like any normal editor" behavior the author named).
    private func attachLeadingTailRunIfNeeded(host: some TailCrystallizerHost) {
        guard !host.holdsTailForStructuralFlight, !mintInFlight,
              host.index.tailLength != nil else { return }
        guard let last = host.index.entries.indices.last,
              host.index.entries[last].editable,
              let variantID = host.index.entries[last].variantID,
              let knownText = host.surfaceKnownText(variantID: variantID)
        else { return }
        let run = text.prefix(while: { $0 == "\n" }).count
        guard run > 0 else { return }
        let oldRange = host.index.range(ofEntryAt: last)
        host.transferTailPrefixToLastEntry(run)
        // The tiling MOVED — disarm, as every index-changing door does (VM-5
        // stability pass, MINOR 3). This move is EQUAL-LENGTH (the entry
        // grows by exactly what the tail loses), so `ArmedEdit.describes`'
        // length oracle cannot see it — the reason `displaySlot` gives for
        // disarming structurally. Reachable with a LIVE arming only from the
        // idle tick (the consume road consumed it already; `finishMint`
        // disarms before its re-run): a stale `.tail` arming over the run
        // would otherwise bind a gate-less edit there and charge the TAIL
        // for characters the last entry now owns (pinned:
        // `theLeadingRunAttachmentDisarmsAStaleArming`). The paste's bulk
        // intent is NOT dropped with it — `disarmPendingEdit` clears the
        // arming only, and the plan just below may be reading that intent.
        host.disarmPendingEdit()
        // Ownership moves; bytes don't: the block-ID attribute grows over
        // the old separator position + run−1 tail newlines.
        EditorSurfaceStorage.setBlockID(
            host.index.entries[last].blockID,
            over: NSRange(location: oldRange.upperBound, length: run),
            in: host.surfaceStorage)
        text = String(text.dropFirst(run))
        let newText = knownText + String(repeating: "\n", count: run)
        host.recordSurfaceText(variantID: variantID, text: newText)
        host.autosave.record(variantID: variantID, text: newText, charDelta: run)
    }

    /// The tail-edit crystallization (and, with `forcedKind`, the idle
    /// mint's). A plan mints through the runner; `finishMint` reconciles.
    func crystallizeIfNeeded(
        forcedKind: CrystallizationPlanner.Kind? = nil, host: some TailCrystallizerHost
    ) {
        // While a mint is in flight, keep `bulkPending` ARMED (review round
        // 1, MAJOR 3): finishMint re-runs this and the paste-during-mint
        // still gets bulk semantics.
        guard !mintInFlight else { return }
        attachLeadingTailRunIfNeeded(host: host)
        guard host.index.tailLength != nil else {
            host.clearBulkPending()
            return
        }
        let mode = host.segmentationMode
        let kind: CrystallizationPlanner.Kind = forcedKind
            ?? CrystallizationPlanner.kindForTailEdit(
                mode: mode, bulkPending: host.pendingBulkEntry)
        guard let plan = CrystallizationPlanner.plan(kind, tail: text) else {
            if forcedKind == nil { host.clearBulkPending() } // consumed: nothing to mint
            return
        }
        // Any plan covers the whole current tail — the flag is consumed.
        host.clearBulkPending()
        mintInFlight = true
        let post = host.postID
        let runner = host.mintRunner
        // The host, strongly (review round 1, MINOR 5): the reconciliation
        // must run even if the view goes away mid-flight — the task completes
        // in milliseconds and the view model is freed after.
        mintTask = Task { [host] in
            do {
                let minted = try await runner.run { ops in
                    try TailCrystallizer.mintBlocks(plan, in: post, ops: ops)
                }
                self.finishMint(minted, kind: kind, host: host)
            } catch {
                self.mintInFlight = false
                host.reportOperationError(error)
                host.applyPendingIfClean()
            }
        }
    }

    /// **The ONE mint body** (18m U2 — it was written out three times: the
    /// Mac's tail edit, the Mac's teardown/quit finalize, the phone's tail
    /// edit). Runs INSIDE the operations runner.
    nonisolated static func mintBlocks(
        _ plan: CrystallizationPlanner.Plan, in post: String, ops: Operations
    ) throws -> [CrystallizationReconciler.MintedBlock] {
        try plan.mints.map { text -> CrystallizationReconciler.MintedBlock in
            // **R-13u-3's ONE named exception** (13u1 UNIT 2):
            // type-time crystallization is not a gesture she
            // made — a paragraph becomes a block because she
            // typed past it (AppSpec §7's "silently becomes a
            // block as you type") — so it registers NO undo
            // entry. Registering here would put one on her stack
            // per paragraph AND clear the redo future on every
            // one, which is the opposite of what ⌥⌘Z is for.
            let result = try ops.newBlock(
                in: post, text: text, at: .end, registeringUndo: false)
            return .init(
                blockID: result.block.id,
                variantID: result.variant.id,
                text: text)
        }
    }

    /// The mint's reconciliation and apply — also the Mac's teardown
    /// finalize's, after its own inline durability mint.
    func finishMint(
        _ minted: [CrystallizationReconciler.MintedBlock],
        kind: CrystallizationPlanner.Kind,
        host: some TailCrystallizerHost
    ) {
        mintInFlight = false
        host.noteOwnWritesSettled() // our mint's writes settled (MAJOR 3's fence)
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted, currentTail: text, kind: kind)

        // Store follow-ups (review round 1, MINOR 6):
        // - Corrections go through the autosave coordinator, so `isDirty`
        //   covers the window until they land (no clobber-then-heal gap)
        //   and a refusal rides the coordinator's keep-pending posture.
        // - Compensating deletions are internal bookkeeping, not an author
        //   gesture: they run through an undo-stack-FREE Operations so
        //   ⌥⌘Z never offers an inverse for something she never did.
        for correction in outcome.corrections {
            host.recordSurfaceText(variantID: correction.variantID, text: correction.text)
            host.autosave.record(
                variantID: correction.variantID,
                text: correction.text,
                charDelta: correction.text.utf16.count)
        }
        if !outcome.corrections.isEmpty {
            Task { [host] in await host.autosave.flushNow() }
        }
        if !outcome.deletions.isEmpty {
            let deletions = outcome.deletions
            let runner = host.mintRunner
            Task { [host] in
                do {
                    try await runner.run { _ in
                        let quiet = Operations() // no undo stack, same store
                        for blockID in deletions {
                            try quiet.deleteBlock(blockID)
                        }
                    }
                } catch {
                    host.reportOperationError(error)
                }
            }
        }
        if outcome.needsFullRerender {
            host.requestFullRender()
        }
        guard !outcome.applied.isEmpty else {
            host.applyPendingIfClean()
            return
        }

        // View + index application for the applied prefix.
        guard let region = host.index.tailRange else {
            host.requestFullRender()
            host.applyPendingIfClean()
            return
        }
        var normalized = outcome.applied.map(\.text).joined(separator: EditorDocument.separator)
        if let newTail = outcome.newTail {
            normalized += EditorDocument.separator + newTail
        }
        if normalized != text {
            host.replaceTailRegion(region, with: normalized)
            host.clearTextUndo()
        }
        for block in outcome.applied {
            host.recordSurfaceText(variantID: block.variantID, text: block.text)
        }
        // A verdict armed before the mint describes a tail that may no
        // longer exist (every index-replacing door disarms) — the sharpest
        // stale case, since a `.tail` arming survives into a closed tail.
        //
        // `bulkPending` deliberately does NOT go with it here (the one
        // exception to NIT 4's rule, beside the consume road's conditional
        // clear): a paste that arrived DURING the mint parked its intent
        // here on purpose, and the crystallization re-run below consumes it.
        host.disarmPendingEdit()
        host.crystallizeIndex(
            minted: outcome.applied.map { ($0.blockID, $0.variantID, $0.text.utf16.count) },
            remainingTailLength: outcome.newTail?.utf16.count)
        text = outcome.newTail ?? ""
        let index = host.index
        let firstNew = index.entries.count - outcome.applied.count
        // ONE tiling walk for the whole mint (13u1 UNIT 1 — the O(N²) class,
        // this member found by its own sweep rule): the accessor walks from
        // zero, so stamping M freshly-minted paragraphs over a note of N
        // blocks cost O(M·N) — and a bulk paste or an import makes M large.
        let ranges = index.entryRanges()
        for (offset, block) in outcome.applied.enumerated() {
            let range = ranges[firstNew + offset]
            if range.length > 0 {
                EditorSurfaceStorage.setBlockID(block.blockID, over: range, in: host.surfaceStorage)
            }
        }
        // 13l L-a: crystallization mints entries and stamps their attributes
        // by hand — the audit runs here on both platforms for that reason.
        host.auditIdentityProjection()
        host.didApplyMint()
        // New paragraphs may have completed during the flight — and a
        // paste-during-mint's still-armed bulk flag is honored here.
        crystallizeIfNeeded(host: host)
        // Whatever tail remains restarts the idle-mint clock.
        armIdleMint(host: host)
        host.applyPendingIfClean()
    }

    /// Awaits an in-flight crystallization mint's reconciliation (the Mac's
    /// pre-rewrite fence; both platforms' teardown backstop and tests).
    func awaitMintSettle() async {
        while mintInFlight {
            if let mint = mintTask { await mint.value } else { await Task.yield() }
        }
    }
}
