//
//  BlockRangeIndex.swift
//  Variorum
//
//  Live block identity over the editor surface (Phase 7 Step 3 — AppSpec §15
//  risk 1, this phase's hard core). Pure value type, UTF-16 offsets (the
//  Phase 3 unit decision). Every edit reports its exact changed range; the
//  index shifts/grows the owning block and never lets an edit leak across a
//  block boundary. Identity is validated against the DB, never inferred from
//  the text — if this bookkeeping ever fails, the store stays safe (the
//  editor re-renders from the projection).
//
//  Document shape invariant (tiling): block entries in order, exactly one
//  1-char separator between consecutive entries, then — iff the tail region
//  is open — one separator (when entries exist) followed by the tail to the
//  document end. When there are no entries the tail IS the document and is
//  always open (fresh-post state). Separators are owned by no block
//  (EditorDocument doctrine).
//

import Foundation
import VariorumCore

nonisolated struct BlockRangeIndex: Equatable, Sendable {
    struct Entry: Equatable, Sendable {
        let blockID: String
        /// The variant this slot's edits autosave into (the rendered
        /// variant); nil = a gap slot (missing block/variant — read-only).
        let variantID: String?
        /// UTF-16 length of the block's text in the surface.
        var length: Int
        /// False for gap slots and locked variants: edits refuse.
        let editable: Bool
    }

    private(set) var entries: [Entry]
    /// UTF-16 length of the open tail; nil = no tail region.
    private(set) var tailLength: Int?

    // MARK: - Construction

    init(entries: [Entry], tailLength: Int?) {
        self.entries = entries
        // No entries ⇒ the tail is the document (always open).
        self.tailLength = entries.isEmpty ? (tailLength ?? 0) : tailLength
    }

    init(slots: [Queries.RenderedBlock], tail: String?) {
        self.init(
            entries: slots.map { slot in
                Entry(
                    blockID: slot.blockID,
                    variantID: slot.variantID,
                    length: (slot.text ?? "").utf16.count,
                    editable: !slot.isGap && !slot.variantLocked)
            },
            tailLength: tail.map { $0.utf16.count })
    }

    // MARK: - Geometry

    /// Total UTF-16 length of the document this index describes.
    var documentLength: Int {
        var length = entries.reduce(0) { $0 + $1.length }
        if entries.count > 1 { length += entries.count - 1 }
        if let tailLength {
            if !entries.isEmpty { length += 1 }
            length += tailLength
        }
        return length
    }

    /// The range of entry `i` in the document.
    func range(ofEntryAt i: Int) -> NSRange {
        var location = 0
        for (j, entry) in entries.enumerated() {
            if j == i { return NSRange(location: location, length: entry.length) }
            location += entry.length + 1
        }
        preconditionFailure("entry index out of range")
    }

    /// **EVERY entry's range, from ONE accumulating pass.**
    ///
    /// 13u1 UNIT 1 — the sweep-to-completion of the O(N²) class
    /// `KnownIssuesAndTechDebt.md` opened on `planVisibleTakeEdit` and the
    /// 2026-08-30 tech-debt sweep widened (P16 · P17 · P22). The accessor
    /// above walks the entries from ZERO on every call, so it is O(i); a
    /// caller that asks it once per entry inside a loop therefore pays
    /// Σi ≈ N²/2 — **cost proportional to the DOCUMENT, which is P1's one
    /// prohibition**, and the fixed twin
    /// (`CrossBlockEditPlanner.plan`) measured 23.8 s for a single plan at
    /// 20,000 entries before it accumulated instead.
    ///
    /// **The arithmetic is the accessor's own:** entry `i` starts at
    /// `Σ_{j<i}(length_j + 1)` BY DEFINITION — the tiling invariant in this
    /// file's header — which is exactly what `range(ofEntryAt:)` computes
    /// one call at a time. Accumulating it once answers identically;
    /// `EditorSeamCostTests.theEntryRangesWalkAgreesWithTheIndexsOwnAccessor`
    /// pins that against the accessor itself on an irregular tiling with
    /// empty entries at both edges and in the middle, which is where an
    /// off-by-one would hide.
    ///
    /// **ONE brain, not N hand-rolled walks** — every loop caller on both
    /// platforms consumes this (the hoist discipline: a rule that lives
    /// twice drifts). The accessor stays for the single-lookup callers,
    /// where O(i) once is the honest cost of the question.
    func entryRanges() -> [NSRange] {
        var ranges: [NSRange] = []
        ranges.reserveCapacity(entries.count)
        var location = 0
        for entry in entries {
            ranges.append(NSRange(location: location, length: entry.length))
            location += entry.length + 1
        }
        return ranges
    }

    /// The open tail's range (nil when no tail region exists).
    var tailRange: NSRange? {
        guard let tailLength else { return nil }
        guard !entries.isEmpty else { return NSRange(location: 0, length: tailLength) }
        let lastEnd = range(ofEntryAt: entries.count - 1).upperBound
        return NSRange(location: lastEnd + 1, length: tailLength)
    }

    /// The separator character position before the tail (only meaningful
    /// when a tail region exists below non-empty entries).
    var tailSeparatorOffset: Int? {
        guard tailLength != nil, !entries.isEmpty else { return nil }
        return range(ofEntryAt: entries.count - 1).upperBound
    }

    // MARK: - Edit routing (the policy layer, consulted BEFORE any change)

    enum Verdict: Equatable, Sendable {
        /// The edit is fully owned by one block: apply, autosave its variant.
        case block(index: Int)
        /// The edit is fully inside the open tail (fresh, not-yet-block text).
        case tail
        /// Enter at the exact document end opens the tail (paragraph-
        /// crystallization posts; PROVISIONAL — see phase plan closeout).
        case openTail
        /// Deleting the separator of an EMPTY tail closes the tail region —
        /// no block text is touched, only the render artifact goes.
        case closeTail
        case refuse(Refusal)
    }

    enum Refusal: Equatable, Sendable {
        /// Cross-block destructive edits refuse in editor v1 (author-
        /// confirmed interpretation 3a; structural gestures arrive Phase 9).
        case crossesBlockBoundary
        /// Gap slot (missing block/variant): nothing to autosave into.
        case readOnlySlot
        /// The rendered variant is locked: branch or unlock to edit.
        case lockedVariant
        /// The proposed range lies outside the document this index
        /// describes — the index has desynced from the storage. Never a
        /// crash (review round 1, MINOR 7): the view model's recovery
        /// re-renders from the store, which is truth.
        case indexDesync
    }

    /// Routes a proposed replacement. `replacementIsSingleNewline` and
    /// `segmentation` decide the open-tail gesture; everything else is
    /// containment against the tiling invariant.
    func verdict(
        replacing range: NSRange,
        replacementIsSingleNewline: Bool,
        segmentation: Segmentation
    ) -> Verdict {
        // A range outside the tiling means the index no longer describes
        // the storage. The posture is recover-not-crash: refuse the edit
        // and let the caller re-render from the store (`desyncRecovery`).
        guard range.location >= 0, range.upperBound <= documentLength else {
            return .refuse(.indexDesync)
        }

        // The open-tail gesture: a typed newline at the exact document end
        // while no tail region exists. One-block posts never open a tail
        // (their Enter is content of the single block — crystallization
        // never applies to them).
        if tailLength == nil, !entries.isEmpty,
           range.length == 0, range.location == documentLength,
           replacementIsSingleNewline, segmentation != .oneBlock {
            return .openTail
        }

        // Closing an empty tail: deleting exactly its separator.
        if let separator = tailSeparatorOffset, tailLength == 0,
           range == NSRange(location: separator, length: 1) {
            return .closeTail
        }

        // Containment: the edit must sit fully inside one region.
        if let tail = tailRange,
           range.location >= tail.location, range.upperBound <= tail.upperBound {
            return .tail
        }
        var location = 0
        for (i, entry) in entries.enumerated() {
            let entryRange = NSRange(location: location, length: entry.length)
            if range.location >= entryRange.location, range.upperBound <= entryRange.upperBound {
                if !entry.editable {
                    return .refuse(entry.variantID == nil ? .readOnlySlot : .lockedVariant)
                }
                return .block(index: i)
            }
            location += entry.length + 1
        }
        return .refuse(.crossesBlockBoundary)
    }

    // MARK: - A7 (13c batch 1B): the empty-block carve

    /// Phase 13c, batch 1B — her A7, verbatim: *"I cant use backspace to
    /// delete empty blocks with no takes right now which is too annoying -
    /// especially when there's an empty block right at the start of the
    /// post."*
    ///
    /// A backspace at the start of a block, or a forward-delete at the end
    /// of one, proposes deleting exactly the ONE separator character
    /// between them — a range owned by NEITHER block, so `verdict` answers
    /// `.crossesBlockBoundary` and the keystroke refuses. That refusal is
    /// ratified and stays: a cross-block destructive edit must not
    /// half-apply. But where one side of that seam is an EMPTY block the
    /// refusal buys nothing — **there is no text to lose** — and the right
    /// answer is to delete that block.
    ///
    /// This is the whole carve, and it is deliberately narrow so it cannot
    /// widen: a **deletion** (never a replacement — typing over a seam is a
    /// different gesture) of **exactly one inter-entry separator** where a
    /// neighbouring entry has **zero length**. Everything else — a block
    /// with any text, a multi-character range, a range that starts or ends
    /// inside a block, the tail separator — falls through untouched to the
    /// existing merge-then-edit / visible-take / refusal paths. The
    /// no-fan and editability guards live with the caller, which is where
    /// the fan arity is known (`EditorSurfaceController`).
    ///
    /// Returns the entry index to delete, or nil. **When BOTH neighbours
    /// are empty the one BEFORE the separator wins** — backspace is the
    /// dominant gesture and its meaning is "remove what is behind me";
    /// preferring the block after would delete the very block the caret
    /// sits in and never converge under repeated presses.
    func emptyBlockDeletion(replacing range: NSRange, isDeletion: Bool) -> Int? {
        emptyBlockCarve(replacing: range, isDeletion: isDeletion)?.carved
    }

    /// The same carve, naming the entry ACROSS the separator too — the one
    /// that survives (VX-290). Where the caret lands is where the deleted
    /// line break was, and only the separator's two sides say where that is:
    /// `survivor < carved` means the carved block sat AFTER the separator (the
    /// caret goes to the survivor's END), `survivor > carved` that it sat
    /// BEFORE it (the survivor's START). One walk, and the both-empty rule
    /// above stays here, in one place.
    func emptyBlockCarve(
        replacing range: NSRange, isDeletion: Bool
    ) -> (carved: Int, survivor: Int)? {
        guard let (before, after) = interEntrySeparatorPair(deleting: range, isDeletion: isDeletion)
        else { return nil }
        if entries[before].length == 0 { return (before, after) }
        if entries[after].length == 0 { return (after, before) }
        return nil
    }

    /// The ONE geometric question both seam carves ask: *which pair of
    /// entries does this proposed edit's separator sit between?*
    ///
    /// Answers only for a **deletion** (never a replacement — typing over a
    /// seam is a different gesture) of **exactly one INTER-ENTRY separator**.
    /// The tail's separator is deliberately outside the loop: it is the
    /// `closeTail` verdict's business, and neither carve may steal it.
    ///
    /// Extracted at 13d batch 2 so the empty-block carve (A7) and the
    /// texted-seam merge (#34) read the same geometry rather than two
    /// hand-walked copies of it — the ONE-brain discipline the snap and join
    /// rules already follow. `emptyBlockDeletion`'s behaviour is unchanged by
    /// the extraction (same guards, same walk, same both-empty tie-break).
    func interEntrySeparatorPair(
        deleting range: NSRange, isDeletion: Bool
    ) -> (before: Int, after: Int)? {
        guard isDeletion, range.length == 1, entries.count >= 2 else { return nil }
        var location = 0
        for k in 0..<(entries.count - 1) {
            location += entries[k].length
            if location == range.location { return (k, k + 1) }
            location += 1  // the separator itself
        }
        return nil
    }

    // MARK: - J9 (13j batch 1): the WHOLE-BLOCK selection

    /// Phase 13j, batch 1 — her J9, from the screenshot report: *"what kind
    /// of writing app won't let you delete a paragraph? there's not even a
    /// take on it right now."*
    ///
    /// **The traced mechanism** (recorded in the batch-1 record, pinned by
    /// `WholeBlockDeleteTests`' two trace tests): selecting a paragraph the
    /// way a triple-click or a drag-to-the-next-paragraph does includes the
    /// newline the eye sees at its end — and that newline is a SEPARATOR,
    /// owned by no entry. So containment fails (`.crossesBlockBoundary`),
    /// and BOTH cross-block planners then decline on the same two guards:
    /// `touched.count >= 2` (the span intersects exactly one entry's
    /// characters) and contiguity (`upperBound <= last-entry.upperBound` —
    /// the separator sits one past it). The open tail was a suspect in the
    /// post-close reading and the trace ruled it out: a tail-free note
    /// declines identically.
    ///
    /// This is the geometry half of the answer: *does this span cover a
    /// contiguous run of WHOLE entries, and nothing else but the separators
    /// that glue that run to its neighbours?* At most one separator may hang
    /// off each end — the one before the run's first entry, the one after
    /// its last (which may be the tail's, so the tail's own TEXT is never
    /// inside the answer). A span covering any entry only PARTIALLY answers
    /// nil: partial selections keep their existing behaviour by her ruling.
    ///
    /// `starts` and `ends` are both strictly increasing (each entry consumes
    /// its length plus one separator), so the two lookups below have at most
    /// one solution each and the run they bracket is unambiguous.
    ///
    /// **Ranges of exactly one character are deliberately excluded.** A
    /// one-character deletion is a SEAM KEYSTROKE, and the two seam carves
    /// own that geometry whole — A7's empty-block delete with its
    /// no-fan/nothing-unshown authorization, and #34's texted-seam merge with
    /// its fan refusal. Answering it here would route around guards the
    /// author ruled, which is the one thing this function must not do.
    func wholeBlockRun(covering range: NSRange) -> ClosedRange<Int>? {
        guard !entries.isEmpty, range.length > 1,
              range.location >= 0, range.upperBound <= documentLength
        else { return nil }
        var starts: [Int] = []
        var ends: [Int] = []
        var location = 0
        for entry in entries {
            starts.append(location)
            ends.append(location + entry.length)
            location += entry.length + 1
        }
        // The run's first entry starts AT the span's start, or one past it
        // (the span opened on the separator that precedes the entry).
        let first = entries.indices.first { starts[$0] == range.location }
            ?? entries.indices.first { $0 > 0 && starts[$0] == range.location + 1 }
        // …and its last entry ends AT the span's end, or one short of it
        // (the span closed on the separator that follows). The `starts <
        // upperBound` fence (13j ladder A, finding A8): a ZERO-LENGTH entry
        // sitting exactly AT the span's end has `ends == upperBound` without
        // being covered — the half-open span stops at its position — and the
        // primary lookup used to grab it, bracketing one more empty block
        // than the selection covers. Trailing edge only: at the LEADING edge
        // a zero-length entry at `range.location` IS inside the half-open
        // span, so `first` needs no mirror. For any non-empty entry the
        // fence is vacuous (`starts = ends − length < upperBound`).
        let last = entries.indices.first {
            ends[$0] == range.upperBound && starts[$0] < range.upperBound
        } ?? entries.indices.first { ends[$0] == range.upperBound - 1 }
        guard let first, let last, first <= last else { return nil }
        return first...last
    }

    /// **The whole-block delete PLAN — the RULE half beside the geometry
    /// half above.** Hoisted here at mobile round 2, batch 1b (R18 ≡ M11)
    /// so the phone INHERITS it instead of copying it: it lived Mac-app-local
    /// in `EditorSurfaceController.planWholeBlockDeletion` from 13j J9 until
    /// a second platform needed the same answer, and MobileSoul §3's rule
    /// (brains in core/`Shared/`, platforms own only faces) makes the copy
    /// a parity defect at birth — the KnownIssues "six mobile brains are
    /// byte-copies" row is the standing scar this avoids. Both platforms'
    /// consumers are now one-line delegates.
    ///
    /// **DELETE, NEVER TYPE-OVER.** A replacement spanning whole blocks is a
    /// DIFFERENT gesture and keeps the merge-then-edit / visible-take roads
    /// it has always taken; the typed characters must never be dropped on
    /// the floor by a delete compound.
    ///
    /// Purely geometric on purpose, with ONE fence — the gap (below). It
    /// carries no other content guard at all: that is the 13c R3-1 lesson
    /// applied rather than re-learned: a plan-time guard reading a
    /// projection is an ENABLEMENT hint, never an authorization, because
    /// the projection is deliberately frozen for the length of a typing
    /// burst. The authorization is `deleteBlock`'s own — the STANDING
    /// unrestricted door (QUESTIONS #33(a): the block goes, whatever it
    /// holds) — and a sealed note refuses at the first leg through the
    /// operation itself, with nothing deleted. A LOCKED take inside the
    /// run is deliberately NOT fenced for exactly that reason (#33(a) is
    /// the ruling; the ⋯ menu's single-block delete has always taken a
    /// locked take's block).
    ///
    /// **THE GAP FENCE (mobile round 2, batch 1b ladder, MINOR 3(a)).** A
    /// gap slot is a block whose variant has NOT ARRIVED (`variantID ==
    /// nil`): the surface renders the block, the editor's own gate refuses
    /// typing into it, and both platforms say so in words *("This block
    /// hasn't fully synced…" / "A block in this selection hasn't arrived
    /// yet")*. Tombstoning one is not the same class of act as deleting a
    /// block she can read: under tombstone-wins (SyncSpec §6) the peer's
    /// paragraph goes with it **when the variant finally lands** — text
    /// she has never seen, deleted behind a promise the app made aloud one
    /// keystroke earlier. So a run containing a gap declines here, and
    /// each platform's face speaks its own read-only refusal. This is the
    /// ONE fence, not the start of a fence family: it is not a guess about
    /// content (the store's answer could differ) — it is the surface
    /// declining to act on a slot it has already declared unwritable.
    func wholeBlockDeletion(covering range: NSRange, replacement: String) -> [String]? {
        guard replacement.isEmpty, let run = wholeBlockRun(covering: range),
              !runAwaitsSync(run)
        else { return nil }
        return run.map { entries[$0].blockID }
    }

    /// **Why a whole-block span declined: because a block in it has not
    /// arrived.** The FACE's question, so a refusal can name the real
    /// reason instead of the residual one (the phone's gate would
    /// otherwise speak its cross-block line at a span that is a perfectly
    /// good run; the Mac's `CrossBlockRefusal` already diagnoses
    /// `.unsyncedBlock` for itself). One rule, two readers — the decline
    /// above and the copy choice here read the same private predicate.
    func wholeBlockRunAwaitsSync(covering range: NSRange) -> Bool {
        guard let run = wholeBlockRun(covering: range) else { return false }
        return runAwaitsSync(run)
    }

    private func runAwaitsSync(_ run: ClosedRange<Int>) -> Bool {
        run.contains { entries[$0].variantID == nil }
    }

    /// Where the caret goes when a whole SET of blocks leaves: the START of
    /// the nearest SURVIVING block below the run, else the END of the
    /// nearest surviving block above it — the single-block rule, applied to
    /// a set.
    ///
    /// **"Nearest surviving", not "just past the edges" (round 2 batch 1b
    /// ladder, MINOR 4).** For the phone's gesture the removed set is a
    /// CONTIGUOUS run, and for a contiguous run the two readings agree —
    /// everything past the last removed index survives by definition. The
    /// Mac's ⌘-click pick is not contiguous, and there the edge reading was
    /// wrong: removing `[b0, b2]` out of `b0 b1 b2` named `b0` — a block
    /// being deleted — while `b1` sat there surviving. Harmless at both
    /// callers (a lookup of a departed block finds nothing and the caret
    /// stands still), but this is the SHARED brain's stated rule now, so it
    /// states the true one and answers `b1`.
    ///
    /// Hoisted with its sibling above (round 2, batch 1b) from
    /// `EditorSurfaceController`, where it was private. Answers by BLOCK ID
    /// rather than by surface offset on purpose: the surface re-renders from
    /// the store between the plan and the landing, so an offset computed here
    /// would be stale by the time anyone could use it, while the ID of a
    /// SURVIVING block is still true afterwards.
    ///
    /// On a run that takes every block there is no survivor — naming the
    /// departed block is the honest answer and a harmless no-op at both
    /// callers (the Mac's `applyStructuralResult`, the phone's
    /// `rangeOfBlock` lookup, which simply finds nothing).
    ///
    /// **Cost (same ladder, MINOR 5): ONE pass over the entries, then one
    /// lookup per ID.** It used to `firstIndex` per ID — O(N·M), and a
    /// select-all makes M = N, which measured ~0.9 s of MAIN-ACTOR work at
    /// the 20,000 entries this feature's own perf pin adopts as its
    /// ceiling. The position map is built once; the survivor scans walk the
    /// entries at most once each.
    func caretLandingAfterRemoving(_ blockIDs: [String]) -> (blockID: String, offset: Int) {
        var positions: [String: Int] = [:]
        positions.reserveCapacity(entries.count)
        for (i, entry) in entries.enumerated() where positions[entry.blockID] == nil {
            positions[entry.blockID] = i  // first occurrence wins (`firstIndex`'s rule)
        }
        let removed = Set(blockIDs.compactMap { positions[$0] })
        guard let first = removed.min() else { return (blockIDs.first ?? "", 0) }
        if let below = (first..<entries.count).first(where: { !removed.contains($0) }) {
            return (entries[below].blockID, 0)
        }
        if let above = (0..<first).reversed().first(where: { !removed.contains($0) }) {
            return (entries[above].blockID, entries[above].length)
        }
        return (entries[first].blockID, 0)
    }

    // MARK: - #34 (13d batch 2): the texted seam

    /// Phase 13d, batch 2 — her QUESTIONS #34 ruling, option (ii): backspace
    /// at a seam between two **TEXTED** blocks MERGES when neither block has
    /// takes, and refuses-and-speaks when either does. Her own principle is
    /// what carried it: *"there is no other writing editor where you can
    /// select a bunch of text, hit delete, and it doesn't delete… if your
    /// text looks like basic text with no variants, it should behave like
    /// basic text."*
    ///
    /// This is the geometry half only: the pair of entries a single-separator
    /// deletion would join, when **both** carry text. An empty neighbour is
    /// A7's carve, never this — the two are mutually exclusive by
    /// construction (one requires a zero-length neighbour, the other requires
    /// neither), which is why `shouldChangeText` can run them in sequence.
    /// The fan rule (instant-vs-ceremony) is deliberately NOT here: it is the
    /// merge gesture's own threshold, read from the store at run time where
    /// it cannot be a stale projection (`EditorSurfaceController.runSeamMerge`).
    func textedSeamPair(deleting range: NSRange, isDeletion: Bool) -> (Int, Int)? {
        guard let (before, after) = interEntrySeparatorPair(deleting: range, isDeletion: isDeletion),
              entries[before].length > 0, entries[after].length > 0
        else { return nil }
        return (before, after)
    }

    // MARK: - Mutations (applied AFTER the change, per the verdict)

    // THE MUTATORS REFUSE; THEY DO NOT TRAP (mobile round 2, batch 1 — the
    // crash her two 2026-08-20 iPhone logs recorded, traced in
    // `notes/plans/mobile-round-2-crash-trace.md`). These four used to be
    // `precondition`-guarded, and `precondition` survives `-O`, so the
    // shipped app DIED where the surrounding design already had a name and
    // a road for the state: `Refusal.indexDesync`'s own doc comment above
    // says "Never a crash … the view model's recovery re-renders from the
    // store, which is truth", and `StructuralGesturePlanner`'s header states
    // the law outright — *the pure layer never asserts; impossible states
    // answer with a refusal and the caller recovers.* The mutators were the
    // only part of this brain that had never been brought to that standard.
    //
    // WHAT DID NOT CHANGE — and this is the point (round-2 principle M-A):
    // the impossible state is still REFUSED. This struct still cannot hold
    // a negative length, cannot open a tail that is already open, cannot
    // close a non-empty one, and a caller that ignores the answer mutates
    // NOTHING. Only the DELIVERY changed: a value instead of a process
    // death. Both view models route a `false` to `desyncRecovery()`.
    //
    // Overflow is folded into the same guard (the disassembly of her
    // crashed binary showed a live `b.vs` overflow trap beside the sign
    // test): an addition that cannot be represented is exactly as much
    // "this delta does not describe me" as a negative result, and answering
    // it with `false` costs one branch.
    //
    // NONE OF THESE CARRIES `@discardableResult`, DELIBERATELY
    // (round-2 ladder round 1, MINOR 2). The whole point of the change is
    // that a caller MUST react to a refusal; the attribute tells the
    // compiler not to warn when one doesn't, which is precisely how the
    // pre-fix `precondition`s shipped. Every call site guards the Bool
    // today, and a future one that forgets should be told.
    //
    // SIX, NOT FOUR, SINCE THE VM-5 STABILITY PASS (MINOR 4). The band's
    // two crystallization mutators — `transferTailPrefixToLastEntry` and
    // `crystallize`, below — kept their `precondition`s through the round-2
    // conversion, so this header promised a law two of its own members
    // broke, and both were one new caller away from the shipped crash
    // class. They refuse now on exactly the states their preconditions
    // named (plus the overflow and negative-length folds the four above
    // carry). Their only callers are the shared `TailCrystallizer`'s
    // attachment and `finishMint`, through each view model's host doors,
    // and a `false` there stops the band and takes the SAME road as the
    // four: the platform's `desyncRecovery()`
    // (`TailCrystallizerHost.recoverFromRefusedIndexMutation`). No red-on-old
    // pin exists for either and none is claimed: both callers guard every
    // precondition today (traced in the VM-5 record), so this is the
    // doctrine made true, not a fixed observed crash.

    mutating func applyBlockEdit(at index: Int, lengthDelta: Int) -> Bool {
        guard entries.indices.contains(index) else { return false }
        let (length, overflow) = entries[index].length.addingReportingOverflow(lengthDelta)
        guard !overflow, length >= 0 else { return false }
        entries[index].length = length
        return true
    }

    mutating func applyTailEdit(lengthDelta: Int) -> Bool {
        guard let tail = tailLength else { return false }
        let (length, overflow) = tail.addingReportingOverflow(lengthDelta)
        guard !overflow, length >= 0 else { return false }
        tailLength = length
        return true
    }

    /// The typed newline that opened the tail IS the separator before it.
    mutating func openTail() -> Bool {
        guard tailLength == nil, !entries.isEmpty else { return false }
        tailLength = 0
        return true
    }

    mutating func closeTail() -> Bool {
        guard tailLength == 0, !entries.isEmpty else { return false }
        tailLength = nil
        return true
    }

    /// The leading-run attachment's bookkeeping (Phase 10, the 2026-07-12
    /// spacing ruling): the tail's first `units` characters become the
    /// last entry's trailing content — the entry grows, the tail shrinks,
    /// the document's bytes and total length are unchanged (the separator
    /// conceptually slides to the transferred run's end).
    ///
    /// REFUSES (mutating nothing) unless the run is at least one unit, an
    /// entry exists to attach to, and the open tail contains the run — the
    /// three states its `precondition`s used to trap on (VM-5, MINOR 4).
    mutating func transferTailPrefixToLastEntry(_ units: Int) -> Bool {
        guard units > 0, !entries.isEmpty, let tail = tailLength, tail >= units
        else { return false }
        let last = entries.count - 1
        let (length, overflow) = entries[last].length.addingReportingOverflow(units)
        guard !overflow else { return false }
        entries[last].length = length
        tailLength = tail - units
        return true
    }

    /// Crystallization bookkeeping (the view edit is the caller's job): the
    /// tail's completed paragraphs became real blocks; the remainder stays
    /// open. `remainingTailLength` nil ⇒ the tail region closed entirely
    /// (bulk segmentation consumes it) — and entries can never be left
    /// empty by it, because at least one mint is required.
    ///
    /// REFUSES (mutating nothing) when no tail is open or nothing was minted
    /// — the two states its `precondition`s used to trap on (VM-5, MINOR 4)
    /// — and on a negative length, which this struct never holds.
    mutating func crystallize(
        minted: [(blockID: String, variantID: String, length: Int)],
        remainingTailLength: Int?
    ) -> Bool {
        guard tailLength != nil, !minted.isEmpty,
              minted.allSatisfy({ $0.length >= 0 }),
              (remainingTailLength ?? 0) >= 0
        else { return false }
        for mint in minted {
            entries.append(Entry(
                blockID: mint.blockID, variantID: mint.variantID,
                length: mint.length, editable: true))
        }
        tailLength = remainingTailLength
        return true
    }
}
