//
//  EditorFind.swift
//  Variorum
//
//  IN-POST FIND & REPLACE (QoL round 2026-07-29, batch 3 — her **L6**:
//  *"i also realized that we need to ship some kind of text find and replace
//  … at least of the chosen text, because i noticed myself reaching for that
//  and not having it"*). Her ruling scoped v1 to the post you are in, acting
//  on the chosen (rendered) takes as ordinary edits; the takes-aware replace
//  and whole-library body search are recorded future scope (owner 13e).
//
//  ── WHY THIS FILE EXISTS AT ALL, i.e. why find & replace is not just
//     `usesFindBar = true` ────────────────────────────────────────────────
//
//  Two measured facts (the batch's step-1 measurements, on macOS 26.5.2):
//
//  **M1b — AppKit applies Replace All as ONE COALESCED STORAGE
//  TRANSACTION.** Three matches across three blocks produced exactly one
//  `didProcessEditing` with `editedRange = {4, 48}` and `changeInLength = 0`
//  — a single edited range spanning both block seams. Our pipeline routes a
//  storage edit by asking the index which BLOCK owns the edited range
//  (`fallbackVerdict`), so a multi-block range resolves to
//  `.refuse(.crossesBlockBoundary)` and lands in `desyncRecovery()`. The
//  first cut of that measurement wired the real model in and the process
//  died with *"Fatal error: editor surface desynced from the block index"*.
//  So "let the replacements ride the ordinary pipeline one at a time" is not
//  something AppKit will do for us — there are no per-range storage edits to
//  ride.
//
//  **M1 — the gate is BATCHED.** Replace All asks ONE question about ALL its
//  ranges (`shouldChangeTextInRanges:` with three ranges, zero single-range
//  calls). A single boolean cannot apply some and refuse others, which is
//  why the ruled shape for a partly-blocked Replace All is ALL-OR-NOTHING:
//  partial application is not merely undesirable here, it is unreachable.
//
//  So this file does the only honest thing: it answers the finder's own
//  client question with NO — nothing AppKit applies — and then re-drives the
//  author's intent through the editor's ORDINARY input path,
//  `insertText(_:replacementRange:)`, once per match, LAST MATCH FIRST so
//  the earlier offsets stay valid (the reason the SDK header gives for its
//  own reverse ordering). Each of those is indistinguishable from typing:
//  the delegate is consulted, the verdict routes, `BlockRangeIndex` updates,
//  autosave and churn record, NSTextView registers undo. Nothing is written
//  to the store by this file, and no operation is added to `Operations/` —
//  her L6 ruling's letter.
//
//  ── THE SAFETY CORE ──────────────────────────────────────────────────────
//
//  A match that spans an inter-block separator must NOT be replaced. On the
//  shipped editor a cross-block edit with a replacement does not refuse: it
//  routes to `planCrossBlockEdit`, which MERGES the blocks and then applies
//  the edit to the merged buffer (the ratified 2026-07-09 merge-then-edit).
//  That contract was made for a deliberate hand-made selection; nothing ever
//  ratified it for a machine-driven sweep, and a Replace All that silently
//  restructured her post would be the worst kind of surprise. So every range
//  is checked BEFORE anything is applied, and `isFindReplacing` guards the
//  application itself so a race cannot turn a replacement into a merge.
//

import AppKit
import Foundation
import VariorumCore

// MARK: - The gate's pure half

/// What a find-replace gesture may do, decided without touching anything.
/// Pure so the counting refusals are unit-testable without a text view.
nonisolated enum FindReplaceGate {
    /// Why a match cannot be replaced. Named for the reason SHE would give,
    /// not for the verdict case.
    enum Blocker: Equatable, Sendable {
        case crossesBlockBoundary
        case lockedTake
        case unsyncedBlock
        /// Cold review F-6: `.indexDesync` must not wear the cross-boundary
        /// copy (nor its ⌘⇧M advice — merging is the wrong way out of a
        /// desync; recovery re-renders from the store on its own).
        case editorResyncing
        /// Cold review F-6: the open-tail verdicts (`.openTail`/`.closeTail`)
        /// are about the paragraph still being written, not a block seam.
        case stillFormingParagraph
    }

    /// The counting refusal (the ruled ALL-OR-NOTHING outcome): nothing is
    /// applied, and the message says how many and why.
    static func refusal(total: Int, blockers: [Blocker]) -> String {
        let blocked = blockers.count
        let matches = total == 1 ? "match" : "matches"
        return "Nothing was replaced — \(blocked) of \(total) \(matches) can't be: "
            + causes(blockers) + "."
    }

    /// The single-match refusal — one match, one honest reason, and the way
    /// out named (⌘⇧M is the merge gesture the boundary case points at —
    /// and ONLY that case: F-6, a desync or a still-forming paragraph must
    /// never be advised into a merge).
    static func refusal(single blocker: Blocker) -> String {
        switch blocker {
        case .crossesBlockBoundary:
            "That match crosses a block boundary — replace inside one block, "
                + "or merge the blocks first (⌘⇧M)."
        case .lockedTake:
            "That match is in a locked take — branch it or unlock it to edit."
        case .unsyncedBlock:
            "That match is in a block that hasn't fully synced; it is read-only for now."
        case .editorResyncing:
            "That match is in text the editor is re-syncing — try again in a moment."
        case .stillFormingParagraph:
            "That match touches the paragraph still being written — it becomes "
                + "a block once typing pauses; try again then."
        }
    }

    static func replaced(_ count: Int) -> String {
        count == 1 ? "Replaced 1 match." : "Replaced \(count) matches."
    }

    // MARK: - 13e E9 — the takes-aware half's words

    /// The APPLY-AND-REPORT line (the `deleteInEveryTake` shape, which is
    /// the KnownIssues row's ruled aligned shape): what landed, in how many
    /// takes, and every take that was skipped WITH its reason — never
    /// silently. `moved` carries the substring valve's count, in the same
    /// one voice, so nothing is reported by a message another overwrites.
    static func replacedInEveryTake(
        replacements: Int, takes: Int, skipped: [String], moved: Int
    ) -> String {
        var message = "Replaced \(replacements) "
            + (replacements == 1 ? "match" : "matches")
            + " in \(takes) \(takes == 1 ? "take" : "takes")."
        if !skipped.isEmpty {
            message += " Skipped \(skipped.count): " + skipped.joined(separator: ", ") + "."
        }
        if moved > 0 {
            message += " \(moved) moved before \(moved == 1 ? "it" : "they") could be replaced."
        }
        return message
    }

    /// Nothing to do — every match moved, or the blocks carry no take that
    /// could take the replacement. A refusal in words, never a silent no-op.
    static func nothingReplacedInAnyTake(moved: Int, skipped: [String]) -> String {
        var message = "Nothing was replaced"
        if moved > 0 {
            message += " — \(moved) \(moved == 1 ? "match" : "matches") moved before "
                + "\(moved == 1 ? "it" : "they") could be"
        } else if !skipped.isEmpty {
            message += " — " + skipped.joined(separator: ", ")
        }
        return message + "."
    }

    /// The menu act fired with nothing for the finder to hand us — no
    /// search string, no bar to read one from, or nothing in the note that
    /// matches. Fire-and-speak: a door that could not act says so (P-2),
    /// and one sentence covers all three because the way out is the same.
    static let noFindToReplace =
        "Nothing to replace — open Find and Replace (⌥⌘F) and type what to find "
        + "and what to replace it with."

    /// **The apply-time completion, ONE voice (cold review F-1 + F-7):** when
    /// everything approved was applied it says so; when some approved matches
    /// could no longer be applied — the text MOVED in the deferred window
    /// (the substring valve), or the door refused where they now land (the
    /// belt) — the one final line carries the whole outcome, so nothing is
    /// reported by a message that another message then overwrites.
    static func completion(applied: Int, moved: Int, blocked: Int) -> String {
        let total = applied + moved + blocked
        guard moved > 0 || blocked > 0 else { return replaced(applied) }
        var causes: [String] = []
        if moved > 0 {
            causes.append("\(moved) moved before \(moved == 1 ? "it" : "they") could be")
        }
        if blocked > 0 {
            causes.append("\(blocked) can no longer be replaced where \(blocked == 1 ? "it" : "they") landed")
        }
        return "Replaced \(applied) of \(total) — " + causes.joined(separator: ", ") + "."
    }

    /// "2 cross a block boundary, 1 is in a locked take" — only the causes
    /// that actually occurred, in a stable order.
    private static func causes(_ blockers: [Blocker]) -> String {
        let boundary = blockers.count { $0 == .crossesBlockBoundary }
        let locked = blockers.count { $0 == .lockedTake }
        let unsynced = blockers.count { $0 == .unsyncedBlock }
        let resyncing = blockers.count { $0 == .editorResyncing }
        let forming = blockers.count { $0 == .stillFormingParagraph }
        var parts: [String] = []
        if boundary > 0 { parts.append("\(boundary) cross\(boundary == 1 ? "es" : "") a block boundary") }
        if locked > 0 { parts.append("\(locked) \(locked == 1 ? "is" : "are") in a locked take") }
        if unsynced > 0 { parts.append("\(unsynced) \(unsynced == 1 ? "is" : "are") in an unsynced block") }
        if resyncing > 0 { parts.append("\(resyncing) \(resyncing == 1 ? "is" : "are") in text still re-syncing") }
        if forming > 0 { parts.append("\(forming) touch\(forming == 1 ? "es" : "") the paragraph still being written") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - 13e E9 — the takes-aware replace, as a pure rule

/// One approved find-bar match, carried from the gate to whichever road
/// applies it: the surface path (ordinary typing, chosen text only) or the
/// takes path. `expected` is the SUBSTRING VALVE's captured text — a range
/// is applied only if it still holds what the finder matched (F-1's rule,
/// now shared by both roads rather than living inside one of them).
struct FindReplaceItem: Equatable, Sendable {
    let range: NSRange
    let replacement: String
    let expected: String?
}

/// **The takes-aware replace's brain (13e E9).** Pure, so the rule that
/// decides what happens inside a take she cannot see is unit-testable
/// without a text view, a board, or a store — and so it can be READ.
///
/// The rule, in one paragraph. A find-bar gesture approves matches in the
/// takes the note SHOWS. Carrying one into another take needs an answer to
/// "which occurrence?", and there are exactly two honest answers:
///
/// - **The gesture covered EVERY occurrence of that phrase in the visible
///   take** (what Replace All does): then "all of them" is literally what
///   she asked for, and every occurrence in the other take is replaced.
/// - **It covered only some** (a single Replace among several matches):
///   then the #10 discipline applies, exactly as `deleteInEveryTake` uses
///   it — a UNIQUE occurrence is replaced, and an ambiguous one is SKIPPED
///   AND REPORTED rather than guessed at.
///
/// Nothing here reads or writes markdown syntax specially: under 13g's F-1
/// the stored text IS the markdown, so a replacement is ordinary content
/// and the spans re-scan themselves afterwards (display == stored is
/// untouched — this rule never invents syntax and never strips it).
nonisolated enum TakesReplacePlan {
    /// One approved match, in the coordinates of the take it was found in.
    struct Match: Equatable, Sendable {
        let range: NSRange       // intra-take (UTF-16, the surface's unit)
        let needle: String
        let replacement: String
    }

    /// What one phrase asks of the OTHER takes.
    struct Group: Equatable, Sendable {
        let needle: String
        let replacement: String
        /// The visible gesture covered every occurrence of `needle` there.
        let coversEveryOccurrence: Bool
    }

    enum Outcome: Equatable, Sendable {
        case edited(text: String, charDelta: Int, replacements: Int)
        /// The phrase is not in this take at all.
        case noMatch
        /// It is there more than once and the gesture did not ask for all
        /// of them — which occurrence would be a guess.
        case ambiguous
    }

    /// Applies matches to the take they were found in — LAST MATCH FIRST,
    /// so every earlier offset stays valid (the surface path's own ordering
    /// rule, and the reason the SDK header gives for its reverse order).
    static func applyMatches(_ matches: [Match], to text: String) -> (text: String, charDelta: Int) {
        var result = text as NSString
        var delta = 0
        for match in matches.sorted(by: { $0.range.location > $1.range.location }) {
            guard match.range.upperBound <= result.length else { continue }
            delta += match.range.length + (match.replacement as NSString).length
            result = result.replacingCharacters(in: match.range, with: match.replacement) as NSString
        }
        return (result as String, delta)
    }

    /// The matches, grouped by the phrase they searched for. `coversEvery`
    /// is measured against the visible take's own text: three matches of
    /// "cat" where "cat" occurs three times is a Replace All.
    static func groups(from matches: [Match], visibleText: String) -> [Group] {
        var seen: [String] = []
        var byKey: [String: (needle: String, replacement: String, count: Int)] = [:]
        for match in matches {
            let key = match.needle + "\u{0}" + match.replacement
            if var existing = byKey[key] {
                existing.count += 1
                byKey[key] = existing
            } else {
                byKey[key] = (match.needle, match.replacement, 1)
                seen.append(key)
            }
        }
        return seen.compactMap { key in
            guard let entry = byKey[key] else { return nil }
            return Group(
                needle: entry.needle,
                replacement: entry.replacement,
                coversEveryOccurrence: entry.count >= occurrences(of: entry.needle, in: visibleText))
        }
    }

    /// Applies every group to another take's text, in order. Groups run
    /// SEQUENTIALLY against the evolving text — a replacement that creates
    /// or destroys another phrase's occurrence is seen by the next group,
    /// which is what a person doing it by hand would get.
    static func apply(_ groups: [Group], toOtherTake text: String) -> Outcome {
        var current = text as NSString
        var replacements = 0
        var delta = 0
        var ambiguous = false
        for group in groups {
            let needle = group.needle as NSString
            guard needle.length > 0 else { continue }
            let count = occurrences(of: group.needle, in: current as String)
            guard count > 0 else { continue }
            if !group.coversEveryOccurrence && count > 1 {
                ambiguous = true
                continue
            }
            let replaced = current.replacingOccurrences(
                of: group.needle, with: group.replacement,
                options: .literal, range: NSRange(location: 0, length: current.length))
            replacements += count
            delta += count * (needle.length + (group.replacement as NSString).length)
            current = replaced as NSString
        }
        if replacements > 0 {
            return .edited(text: current as String, charDelta: delta, replacements: replacements)
        }
        return ambiguous ? .ambiguous : .noMatch
    }

    /// Non-overlapping literal occurrences — the same counting AppKit's own
    /// Replace All performs, and the same `TakeSpanMatch.uniqueRange` uses
    /// to decide ambiguity (one occurrence or nothing).
    static func occurrences(of needle: String, in text: String) -> Int {
        guard !needle.isEmpty else { return 0 }
        let haystack = text as NSString
        let step = (needle as NSString).length
        var count = 0
        var from = 0
        while from < haystack.length {
            let found = haystack.range(
                of: needle, options: .literal,
                range: NSRange(location: from, length: haystack.length - from))
            guard found.location != NSNotFound else { break }
            count += 1
            from = found.location + step
        }
        return count
    }
}

// MARK: - 13o U2 — the FIND SEED (land-at-match, D6)

/// **What a search passage hands the editor it lands in** (13o U2 — her
/// land-at-match, the mockup's shared section: *"Clicking a passage opens the
/// note at that block with the match selected and the find bar armed, so ⌘G
/// keeps stepping"*). A ONE-SHOT seed beside the caret's
/// (`EditorViewModel.pendingFindSeed`), applied once at the arriving editor's
/// first render through this file's own doors — `performFind` — and nothing
/// inside the text view, the block index or the pane surface.
///
/// `needle` is the matched words AS THE INDEX MARKED THEM in the passage's
/// snippet — the text as written, so the find bar's literal search meets it
/// even though the index folds case and accents (R-13o-11). `steps` says the
/// match is in the text the note SHOWS (a rendered take): the editor selects
/// it. An unrendered take's hit only ARMS the bar — the words are not on the
/// page to select (PROVISIONAL P-13o-U2-4).
nonisolated struct EditorFindSeed: Equatable, Hashable, Sendable {
    let needle: String
    let steps: Bool
}

/// The seed's pure half (pinned): where the needle sits in the surface's
/// text, from the landed block's start onward.
nonisolated enum FindSeedLanding {
    /// The first occurrence of `needle` at or after `start` — the literal
    /// text first (the snippet's words ARE the source's), then folding case
    /// and diacritics (the index's own sameness, should the buffer differ in
    /// either); nil when the words are not there.
    static func range(of needle: String, in text: String, from start: Int) -> NSRange? {
        let haystack = text as NSString
        guard !needle.isEmpty, start >= 0, start <= haystack.length else { return nil }
        let rest = NSRange(location: start, length: haystack.length - start)
        for options: NSString.CompareOptions in [.literal, [.caseInsensitive, .diacriticInsensitive]] {
            let found = haystack.range(of: needle, options: options, range: rest)
            if found.location != NSNotFound { return found }
        }
        return nil
    }
}

// MARK: - The editor's find doors

@MainActor
extension EditorViewModel {
    /// Runs one find-family action on THIS editor. Returns whether this
    /// editor answered — the inline book/spread/pool editor declines (it owns
    /// no scroll view, so it has no find bar), and the router then speaks the
    /// capability's declared note instead of a per-site copy (P-2).
    @discardableResult
    func performFind(_ action: FindAction) -> Bool {
        guard let textView, scrollView != nil else { return false }
        // 13e E9: the takes scope is ARMED for exactly one finder call, not
        // held as a mode. AppKit's finder call is synchronous (M5), so the
        // flag is consumed by `gateFindReplace` within this call or not at
        // all — and "not at all" means the finder had nothing to replace
        // (no search string, no bar), which the door then SAYS rather than
        // failing silently (P-2). A one-shot flag also means the ordinary
        // ⌘F family can never acquire a hidden scope by accident.
        let armed = action == .replaceAllInEveryTake
        if armed {
            // Asked HERE as well as in the gate, deliberately: under a seal
            // the text view is not editable, so AppKit's finder may never
            // reach the client question at all — and a door that answered
            // "nothing to find" when the truth is "this note is sealed"
            // would be the lecture-shaped refusal P-2 retired.
            guard header?.locked != true else {
                refuseFeedback(SealedNoteCopy.sentence(act: "edit", words: .mac))
                return true
            }
            takesScopeArmed = true
        }
        let item = NSMenuItem()
        item.tag = action.finderAction.rawValue
        textView.performTextFinderAction(item)
        if armed && takesScopeArmed {
            takesScopeArmed = false
            refuseFeedback(FindReplaceGate.noFindToReplace)
        }
        return true
    }

    /// The finder's replace gate — called from `EditorTextView`'s client
    /// method, which has already told AppKit NO. Everything from here is ours.
    func gateFindReplace(ranges: [NSRange], strings: [String]) {
        guard let textView else { return }
        // 13e E9: consumed HERE, before any early return, so a refusal
        // clears the arming too — the door's own "nothing to replace" line
        // must not fire on top of a refusal that already spoke.
        let takesScope = takesScopeArmed
        takesScopeArmed = false
        guard header?.locked != true else {
            refuseFeedback(SealedNoteCopy.sentence(act: "edit", words: .mac))
            return
        }
        guard !ranges.isEmpty else {
            // 13e E9: the ordinary bar buttons stay silent here (she is
            // looking straight at the bar that found nothing), but a MENU
            // act that was deliberately chosen must not do nothing silently
            // — measured: AppKit calls its client with an empty range set
            // rather than skipping the call, so this is the road the
            // "nothing to replace" line actually travels, and
            // `performFind`'s still-armed check is the belt behind it.
            if takesScope { refuseFeedback(FindReplaceGate.noFindToReplace) }
            return
        }
        // A flight already in progress, or a structural op landing: the
        // surface is not ours to rewrite (the standing fence).
        guard !structuralInFlight else {
            refuseFeedback("Another structural change is still landing.")
            return
        }

        var blockers: [FindReplaceGate.Blocker] = []
        for range in ranges {
            switch index.verdict(
                replacing: range, replacementIsSingleNewline: false,
                segmentation: header?.effectiveSegmentation ?? .paragraph
            ) {
            case .block:
                continue
            case .tail:
                // 13e E9: the TAKES road has one blocker the surface road
                // does not. A match in the open tail sits in text that is
                // not a block yet, so it has no variant row to carry into
                // other takes — and the takes road writes through the
                // operations layer, which knows only variants. The tail
                // sentence already says the true thing ("it becomes a block
                // once typing pauses; try again then"), and the family's
                // all-or-nothing rule keeps the gesture whole.
                if takesScope { blockers.append(.stillFormingParagraph) }
                continue
            case .refuse(.lockedVariant):
                blockers.append(.lockedTake)
            case .refuse(.readOnlySlot):
                blockers.append(.unsyncedBlock)
            case .refuse(.crossesBlockBoundary):
                blockers.append(.crossesBlockBoundary)
            case .refuse(.indexDesync):
                // F-6: a desync is not a boundary — its copy must not
                // recommend a merge.
                blockers.append(.editorResyncing)
            case .openTail, .closeTail:
                // F-6: the tail verdicts are about the paragraph still
                // being written. (`.openTail` needs a zero-length newline
                // insertion, unreachable from a replace — kept for the
                // compiler's exhaustiveness, honest if it ever fires.)
                blockers.append(.stillFormingParagraph)
            }
        }
        guard blockers.isEmpty else {
            // ALL-OR-NOTHING (ruled, and structurally forced by M1's batched
            // gate): nothing is applied, and the refusal counts and names.
            refuseFeedback(
                ranges.count == 1
                    ? FindReplaceGate.refusal(single: blockers[0])
                    : FindReplaceGate.refusal(total: ranges.count, blockers: blockers))
            return
        }

        // We are INSIDE AppKit's finder call (measured synchronous, M5) —
        // rewriting storage here would be re-entrant. The same reason
        // `shouldChangeText` defers its cross-block compounds: refuse now,
        // reproduce the exact intent on the next turn.
        //
        // **The substring VALVE (cold review F-1, MAJOR):** capture what each
        // approved range MATCHES right now. The R-A race proves text can move
        // in the deferred window (any already-queued main-actor work runs
        // first), and a bounds check alone would let a drifted-but-in-block
        // range replace whatever sits at those offsets NOW — silent
        // wrong-text replacement. A range is applied only if it still holds
        // the text the finder matched; otherwise it is SKIPPED AND COUNTED.
        // The all-or-nothing gate above is untouched: it speaks for
        // everything it can see; the valve covers only what moves AFTER
        // approval.
        let snapshot = textView.string as NSString
        let plan = zip(ranges, paddedStrings(strings, to: ranges.count)).map {
            range, replacement in
            FindReplaceItem(
                range: range,
                replacement: replacement,
                expected: range.upperBound <= snapshot.length
                    ? snapshot.substring(with: range) : nil)
        }
        // 13e E9: the SCOPE fork, and the only one — everything above (the
        // seal, the flight fence, the per-range verdicts, the all-or-nothing
        // refusal, the valve's captured substrings) is shared, so the two
        // roads can never disagree about what a match is or when a gesture
        // must refuse. They differ in exactly one thing: where the approved
        // text lands.
        if takesScope {
            findReplaceTask = Task { @MainActor [weak self] in
                await self?.structural.replaceInEveryTake(plan)
            }
            return
        }
        findReplaceTask = Task { @MainActor [weak self] in
            self?.applyFindReplace(plan, in: textView)
        }
    }

    /// The finder hands a parallel `strings` array; a Replace All may send one
    /// string for every range. Neither shape is guessed at a call site.
    private func paddedStrings(_ strings: [String], to count: Int) -> [String] {
        if strings.count >= count { return Array(strings.prefix(count)) }
        return Array(repeating: strings.first ?? "", count: count)
    }

    /// Applies the replacements through the editor's ORDINARY input path —
    /// LAST MATCH FIRST, so every earlier offset is still valid — under ONE
    /// undo group, so a Replace All undoes as the single act she performed.
    ///
    /// **Two layers of protection against the deferred window (F-1):** the
    /// substring VALVE — a range is applied only if it still holds the exact
    /// text the finder matched at gate time (a drifted range is skipped and
    /// counted, never applied to whatever sits there now) — and, behind it,
    /// the `isFindReplacing` flag as the BELT for the one shape the valve
    /// cannot see: byte-identical text whose BLOCK membership moved (a
    /// structural change landing in the window), which `shouldChangeText`
    /// then refuses instead of merging.
    private func applyFindReplace(
        _ plan: [FindReplaceItem],
        in textView: EditorTextView
    ) {
        let manager = textView.undoManager
        manager?.beginUndoGrouping()
        var applied = 0
        var moved = 0    // the valve: the range no longer holds its match
        var blocked = 0  // the belt: the door refused where it now lands
        for item in plan.sorted(by: { $0.range.location > $1.range.location }) {
            let current = textView.string as NSString
            guard item.range.upperBound <= current.length,
                  let expected = item.expected,
                  current.substring(with: item.range) == expected else {
                moved += 1
                continue
            }
            // 13u1 UNIT 1 (item 7): the ONE input-path door, with the find
            // bar's own `withFindReplace` bracket as a PARAMETER rather than
            // an exemption — so the gate and the mutation can no longer be
            // separated here either, and "one input path" needs no footnote.
            guard OrdinaryInputEdit.apply(
                item.replacement, over: item.range, in: textView, underFindReplace: true)
            else {
                blocked += 1
                continue
            }
            applied += 1
        }
        manager?.endUndoGrouping()
        // ONE voice (F-7): the final line carries the whole outcome —
        // any mid-loop belt refusal is deliberately superseded by it.
        // J43, the split-by-outcome pair: a replace that replaced something
        // is a RECEIPT (its takes-aware twin at
        // `EditorSurfaceController.replaceInEveryTake` already is one); a run
        // that applied NOTHING reports a no-op and always shows (P-2).
        let line = FindReplaceGate.completion(
            applied: applied, moved: moved, blocked: blocked)
        applied > 0 ? showReceipt(line) : refuse(line)
        findReplaceTask = nil
    }
}

extension FindAction {
    /// The registry's vocabulary → AppKit's. The registry never imports
    /// AppKit (the `StructuralAct` layering); this is the feature-side map.
    var finderAction: NSTextFinder.Action {
        switch self {
        case .show: .showFindInterface
        case .showReplace: .showReplaceInterface
        case .next: .nextMatch
        case .previous: .previousMatch
        case .useSelection: .setSearchString
        // 13e E9: the SAME finder action as an ordinary Replace All — the
        // act is a scope, not a second search. What differs is that the
        // model is armed when the finder asks its client question.
        case .replaceAllInEveryTake: .replaceAll
        }
    }
}
