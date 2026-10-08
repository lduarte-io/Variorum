//
//  BlockHistoryFace.swift
//  Variorum (Shared — Mac + iPhone)
//
//  **THE BLOCK'S WHOLE TIME, IN ONE VOCABULARY** — hoisted here at mobile
//  round 2, batch 6a, when the phone grew its own Block History face.
//
//  Everything below arrived verbatim from the Mac's
//  `Features/Tray/BlockHistoryPane.swift`, `Features/Tray/TrayPanel.swift`,
//  `Features/Tray/OriginPeek.swift` and `Features/Editor/SavepointHistory.swift`,
//  where it was named in `KnownIssuesAndTechDebt.md`'s forked-brains row as
//  deletion-copy still awaiting a hoist. **A hoist moves an ADDRESS, never a
//  behaviour** — every string, every rule and every signature is byte-identical
//  to what the Mac shipped, which is what lets the Mac's suite ride unmodified
//  as the proof (the 3C parity pattern, MobileSoul §3).
//
//  ── WHAT DELIBERATELY DID *NOT* COME ─────────────────────────────────────
//  Four strings and one rule stayed Mac-local, in an `extension` beside the
//  pane, because each of them names a MAC DOOR or a MAC CHORD and the phone
//  has neither: `doorLabel`/`doorPhrase` (the bottom bar's word and the
//  sentence pointing at it), `cameFromPathWithDoor`, `noSavepoints` (it names
//  ⌘S), `BlockHistoryCopy.deletedExplainer` (it names *This Note's Tray*, a
//  surface the phone does not have until batch 6b), and the current-block
//  jump's two strings (the Mac pane stands open beside a live editor; the
//  phone's sheet covers the page and stands the editor down, so its caret
//  cannot move while the face is up — no jump to offer).
//
//  Sharing a sentence that names one platform's door would be the
//  no-redirect breach (MobileSoul §4.4) wearing a shared home's clothes.
//

import Foundation
import VariorumCore

/// **The ONE place the block-history face's name and its regions are
/// spelled** (the `TrayPath` pattern, and for its reason: receipts, tutorial
/// lessons and menu labels on BOTH platforms promise this surface by name).
nonisolated enum BlockHistoryPath {
    /// The face's title, and the registry verb.
    static let name = "Block History"

    /// 13s-b U4 (her R-13s-31, *"I want that changed everywhere"*): the
    /// region's header says COMMITS on both platforms — it said
    /// "Savepoints". The constant's NAME keeps the old word: code names are
    /// not the product's.
    static let savepointsSection = "Commits"
    static let archivedSection = "Archived takes"
    static let deletedSection = "Deleted takes"
    static let cameFromSection = "Came from"

    /// What the whole face says about itself, once, at the top.
    static let explainer =
        "Everything this block has been: each take's saved moments, the takes "
        + "it set aside or deleted, and the block it came out of."

    /// **The came-from region's path phrase** — the destination
    /// `TrayPath.originalsPath` names, since her G5 ruling moved unclocked
    /// originals out of the tray and into lineage (*"the tray audits what is
    /// LEAVING; lineage holds what is KEPT"*). One constant, so the eight copy
    /// sites that quoted the tray's section follow for free.
    static var cameFromPath: String { "\(name) \u{2192} \(cameFromSection)" }

    /// A live take's heading: its own label where it has one, else its place
    /// in the fan. Never the raw id (13g R5-4's rule, one surface over).
    static func takeHeading(_ take: Variant, ordinal: Int, of total: Int) -> String {
        if let label = take.label, !label.isEmpty { return label }
        return total > 1 ? "take \(ordinal) of \(total)" : "this take"
    }

    static let focusedMark = "the take you're in"
    static let nothingHere =
        "This block has no past yet: one take, no saved moments, nothing set "
        + "aside, and nothing it came out of."

    /// The came-from row's one-button way back. Her fourth-sitting ask named
    /// the idea and rejected her own wording for it: *"add as block again to
    /// the note (that's too wordy, you can reword the button, but the idea is
    /// that if you just merged something then realized you actually wanted a
    /// parent block, you should just be able to pull that parent block back
    /// into existence easily)"*. Two words, the verb first, and the same
    /// grammar as the tray's own **Put back**.
    static let bringBackVerb = "Bring back"
    static let bringBackHelp =
        "Puts this original back into the note, beside the blocks it became — "
        + "it was kept whole and set aside, never deleted"
    static let openTrayVerb = "Open this note's tray"
}

/// **The words the block's past speaks about its TAKES**, in one home.
///
/// *(Kept verbatim through two moves: from `BlockPastSection.swift` into the
/// Mac's pane at the post-13l polish round, and from there to here at mobile
/// round 2 batch 6a. The sentences are semantic and every one of them is
/// still true on both platforms, so they move rather than being rewritten.)*
nonisolated enum BlockPastCopy {
    static let deletedTakesHeader = BlockHistoryPath.deletedSection
    static let putBackVerb = "Put back"
    static let seeOriginVerb = "See original"

    /// The receipt after a deleted take comes back. It names the fan,
    /// because that is where she will look for it.
    static let takeRestored = "Take put back — it's in this block's fan again."

    /// **The archived edition** (13j ladder A round 1, finding A3): the
    /// restore is an exact flip (#68(b), ruled), so a take that was ARCHIVED
    /// when it was deleted comes back archived — into the archived listing,
    /// not the fan — and the one receipt above was lying for that row. The
    /// door reads `restoreVariant`'s own returned status and says which.
    static let takeRestoredArchived =
        "Take put back — it was archived, so it's in this block's archived "
        + "takes, not the fan. Unarchive it there to bring it back."

    static func restored(_ status: VariantStatus) -> String {
        status == .archived ? takeRestoredArchived : takeRestored
    }

    /// The Put-back button's help, worded to the ROW's status (the row is a
    /// `Variant`, so it knows): "its place in the fan" was false for an
    /// archived take.
    static func putBackHelp(_ take: Variant) -> String {
        take.status == .archived
            ? "Puts this take back among the block's archived takes, exactly "
                + "as it was — it was archived when it was deleted"
            : "Puts this take back in the block's fan, exactly as it was — "
                + "its label, its place in the fan and its commits all "
                + "come back with it"
    }

    /// A deleted take's row label: its own label where it has one, else the
    /// take's first line (`TrayRowPreview`'s rule, which the tray's rows
    /// already speak).
    ///
    /// The empty case says **take**, not "block" — caught by the 13j capture,
    /// where an empty deleted take rendered as "(empty block)" because
    /// `TrayRowPreview.line` was written for the tray's BLOCK rows and its
    /// fallback names that noun. A row in a fan that calls itself a block is
    /// the same small dishonesty this family of surfaces exists to end.
    static let emptyTake = "(empty take)"

    static func rowLabel(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return label }
        let line = TrayRowPreview.line(take.workingText)
        return line == TrayRowPreview.emptyBlock ? emptyTake : line
    }
}

/// The face's own receipts — beside `BlockPastCopy`'s, which the deleted-take
/// region speaks.
nonisolated enum BlockHistoryCopy {
    static let restoredSavepoint =
        "Saved moment restored into this take — the moments themselves are "
        + "never overwritten, so nothing was lost."
    static let unarchivedTake = "Take unarchived — it's back in this block's fan."
    static let restoreVerb = "Restore"
    static let unarchiveVerb = "Unarchive"
    static let predatesSplitMark = "predates a split"
    static let predatesSplitTitle = "This saved moment predates a split of this block"
    static let predatesSplitDetail =
        "Restoring will resurrect the full pre-split text into this take's "
        + "buffer — the split-off half still exists next door."
    static let restoreAnyway = "Restore Anyway"

    static let archivedExplainer = "Set aside, out of the fan — kept, with no clock."

    // MARK: - Naming a saved moment (13u3 UNIT D — item 14, her R-13u3-1)

    /// The rename door's verb, WORDED TO THE ROW — the door says what it
    /// does, which is `BlockPastCopy.putBackHelp`'s rule one region up (a
    /// button whose label is true of some rows and false of others is the
    /// small dishonesty this family of surfaces exists to end).
    ///
    /// Shared rather than Mac-local because neither word names a platform's
    /// door or chord: it is the act, and the phone's Block History is the
    /// same listing with the same rows (`BlockHistoryFace`'s own rule for
    /// what may live here).
    static let nameSavepointVerb = "Name"
    static let renameSavepointVerb = "Rename"

    static func nameVerb(_ commit: CommitPoint) -> String {
        SavepointRowFace.name(commit) == nil ? nameSavepointVerb : renameSavepointVerb
    }

    static func nameHelp(_ commit: CommitPoint) -> String {
        SavepointRowFace.name(commit) == nil
            ? "Give this saved moment a name — what it was, so you can find it "
                + "again. The moment's text is never editable; only its name is"
            : "Change this saved moment's name, or clear it. The moment's text "
                + "is never editable; only its name is"
    }

    /// The receipts. The named one quotes the name back, because the whole
    /// point of a name is that she recognises it.
    static func savepointNamed(_ name: String) -> String {
        "Saved moment named \u{201C}\(name)\u{201D}."
    }

    static let savepointNameCleared = "Name cleared — the saved moment itself is untouched."

    static func renamed(_ name: String?) -> String {
        name.map(savepointNamed) ?? savepointNameCleared
    }

    /// **The deleted region's explainer, LEAD HALF — and the whole of the
    /// promise this face makes: NO PURGE DOOR HERE** (her evolved rule, the
    /// polish round's ledger row 21: Delete Now lives on TRASH SURFACES, never
    /// in the writing flow).
    ///
    /// The sentence naming where Delete Now *does* live is each platform's,
    /// because each platform's answer is a different door — and on the phone,
    /// until its note-level trash section lands (batch 6b), the honest answer
    /// is that there isn't one yet, which is why `purgeRoad` is optional and
    /// nil produces a complete sentence rather than a dangling clause.
    static func deletedRegionExplainer(purgeRoad: String?) -> String {
        let lead = "On the \(TrashWindow.days)-day clock. Put one back here"
        guard let purgeRoad else { return lead + "." }
        return lead + "; to end a take's remaining days early, \(purgeRoad)."
    }
}

/// **WHICH SAVEPOINT RUN A FACE OPENS WITH** — her ruling that every take is
/// sectioned with *"the focused take's expanded"*, as a pure rule so a pin
/// holds the decision without rendering anything.
///
/// The focused take where the request named one and it is still live, else
/// the first live take. Shared because a phone that opened a different take
/// than the Mac would be answering her ruling twice.
nonisolated enum BlockHistoryExpansion {
    static func initiallyExpanded(
        _ history: Queries.BlockHistory, focused: String?
    ) -> Set<String> {
        if let focused, history.takes.contains(where: { $0.id == focused }) {
            return [focused]
        }
        return Set(history.activeTakes.first.map { [$0.id] } ?? [])
    }
}

/// **A SAVEPOINT ROW'S QUIET LINE, AS A VALUE** — its name where she gave it
/// one, when it was saved, whether it was deliberate or quiet, and the
/// pre-split warning. Pure, so a pin holds what the row says without
/// rendering it (`TrayRowFace`'s shape and its reason).
///
/// **13u3 UNIT D — the NAME LEADS** (item 14, her ruling R-13u3-1). The
/// shipped order put the message third, after the stamp and the kind, which
/// was the right shape while nothing could write it: a message was a rarity
/// the line mentioned. Now the commit door offers one at every ⌘S, so the
/// name is what identifies the row — *"before the AI edit"* is why she is
/// looking at this savepoint and not the one above it — and a name she has
/// to read past a date to find is a name the row is hiding.
///
/// The two slots are additive beside `meta`, which now DERIVES from them
/// (`DeletedTakeFace`'s lead/clock split, same reason): a face with room can
/// draw the name in its own register and the details muted beneath it, while
/// a face with one line reads the joined form and gets the ordering for free.
/// **The occasion is never overwritten by the name** — a renamed quiet
/// savepoint still says *quiet* beside its name, because `renameCommitPoint`
/// writes `message` and leaves `kind` alone (her ruling's own note).
nonisolated enum SavepointRowFace {
    /// The name she gave this moment, or nil. Read through the ONE rule the
    /// operations layer stores it by, so a face can never show a name the
    /// store would have normalised away.
    static func name(_ commit: CommitPoint) -> String? {
        SavepointName.normalized(commit.message)
    }

    /// Everything the row says ABOUT the moment, in one place: when, whether
    /// it was deliberate or quiet, and the pre-split warning.
    static func details(_ commit: CommitPoint, predatesSplit: Bool) -> [String] {
        var pieces = [
            commit.createdAt.formatted(date: .abbreviated, time: .shortened),
            commit.kind == .auto ? "quiet" : "saved by hand",
        ]
        if predatesSplit { pieces.append(BlockHistoryCopy.predatesSplitMark) }
        return pieces
    }

    /// The whole quiet line — the NAME first where there is one.
    static func meta(_ commit: CommitPoint, predatesSplit: Bool) -> [String] {
        (name(commit).map { [$0] } ?? []) + details(commit, predatesSplit: predatesSplit)
    }
}

/// **A DELETED TAKE'S QUIET LINE, AS A VALUE** — when it went and how long it
/// has. The tray's `TrayTakeFace` names the take's BLOCK because the panel is
/// the note; here the face IS the block, so the row owes the clock instead.
nonisolated enum DeletedTakeFace {
    /// **The Act 10 correction round, row 63: the two-slot split** — the
    /// truncatable LEAD (a DATE-ONLY stamp; the `OriginPeekCopy.stamp`
    /// ruling) and the CLOCK in its own slot the layout may never compress.
    /// Additive beside `meta`, which now derives from the pair, so callers
    /// on either platform read byte-compatibly.
    static func lead(_ take: Variant) -> [String] {
        guard let deletedAt = take.deletedAt else { return [] }
        return ["deleted " + deletedAt.formatted(date: .abbreviated, time: .omitted)]
    }

    static func clockSlot(_ take: Variant, now: Date) -> String? {
        guard let deletedAt = take.deletedAt else { return nil }
        // The window's own arithmetic, over the ONE canonical stamp shape the
        // rest of the recovery family reads (`TrashWindow.daysLeft` parses
        // what the store holds; the record hands us the decoded date, so it
        // is re-encoded through the same formatter rather than a second
        // subtraction written here).
        return TrashWindow.daysLeft(
            DateFormatter.variorumISO8601.string(from: deletedAt), now: now)
            .map(RecoveryCopy.daysLeftLabel)
    }

    static func meta(_ take: Variant, now: Date) -> [String] {
        var pieces = lead(take)
        if let slot = clockSlot(take, now: now) { pieces.append(slot) }
        return pieces
    }
}

/// **A ROW'S ONE-LINE PREVIEW AND ITS STAMP**, shared since batch 6a because
/// the phone's Block History rows name takes and originals exactly as the
/// Mac's tray rows name blocks.
nonisolated enum TrayRowPreview {
    /// The FIRST LINE only — a multi-paragraph block's row must not grow to
    /// the block's height, and its first line is what identifies it (the
    /// `tocHandle` instinct, without borrowing its naming rules: a tray row
    /// is not a heading).
    /// The empty case's words, named so a caller in another scope can tell
    /// it apart and say its OWN noun (13j batch 3: the History face's take
    /// rows read "(empty block)" until the capture caught it).
    static let emptyBlock = "(empty block)"

    static func line(_ text: String?, limit: Int = 90) -> String {
        guard let text, !text.isEmpty else { return emptyBlock }
        let first = text.split(
            separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)[0]
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return emptyBlock }
        return trimmed.count > limit ? String(trimmed.prefix(limit)) + "\u{2026}" : trimmed
    }

    /// "deleted 12 Aug" — the stored canonical stamp, read through the ONE
    /// parser (`DateFormatter.variorumISO8601`), never re-parsed by hand.
    /// A stamp that doesn't parse renders nothing at all rather than raw
    /// ISO text.
    static func stampText(_ stamp: String, verb: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return nil }
        return "\(verb) \(date.formatted(date: .abbreviated, time: .shortened))"
    }

    /// **The DATE-ONLY stamp** (the Act 10 correction round, row 63 — the
    /// `OriginPeekCopy.stamp` ruling extended to the recovery rows it was
    /// learned beside: with the time of day in it, the row's own point — the
    /// clock — fell off the end "to make room for a minute nobody needs").
    /// Additive beside `stampText`, so every shipped caller on either
    /// platform reads byte-identically until its surface adopts this one.
    static func stampTextDateOnly(_ stamp: String, verb: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return nil }
        return "\(verb) \(date.formatted(date: .abbreviated, time: .omitted))"
    }
}

/// **THE LINEAGE VOCABULARY** — what a came-from row says about the original
/// standing behind a block. Hoisted at batch 6a with the region that speaks
/// it; the Mac's J3 peek is gone (absorbed into its pane) but these sentences
/// outlived it, and now both platforms read them.
nonisolated enum OriginPeekCopy {
    /// The palette's row and the registry's verb: the act with no target in
    /// hand, so it cannot name the act that released the original.
    static let genericVerb = "See the Original This Came From"

    /// The context row's words, which DO have a target — her ruled shape,
    /// "See original from divide…" / "…from merge…". An origin op the door
    /// has no word for falls back to the generic sentence rather than
    /// inventing one (`origin_op` is nullable and carries five values today).
    static func doorVerb(op: String?) -> String {
        guard let act = actWord(op) else { return "See the original this came from\u{2026}" }
        return "See original from \(act)\u{2026}"
    }

    /// The quiet lineage row — "From a divide on 12 Aug — the original is
    /// preserved".
    static func lineageRow(op: String?, at: String) -> String {
        let act = actWord(op).map { "a \($0)" } ?? "an earlier change"
        guard let when = stamp(at) else {
            return "From \(act) — the original is preserved"
        }
        return "From \(act) on \(when) — the original is preserved"
    }

    /// The peek's own heading, same fact in the same words.
    static func heading(op: String?, at: String) -> String {
        lineageRow(op: op, at: at)
    }

    static let putBackVerb = "Put back in note"
    static let openTrayVerb = "Open this note's tray"

    /// What the region says about itself, once, at the top: the original is
    /// not deleted and never was — the W preserves it whole and stands it to
    /// one side (OverallModel §7). Saying so is the whole point of the
    /// surface; her sitting question was "how do I even see the original one?"
    static let explainer =
        "This block was kept WHOLE and set aside — not deleted. It's waiting "
        + "here with its takes, and Put back returns it to the note beside "
        + "the blocks it became."

    /// The refusal for the door invoked where the block has no such original
    /// (the palette's context-blind row — fire-and-speak, P-2).
    static let noOriginHere =
        "This block wasn't divided or merged out of another one — there's no "
        + "original standing behind it."

    /// The original went somewhere while the face was open (it was put back
    /// from the tray in another pane, or a successor moved). One honest line
    /// rather than an empty region.
    static let originGone =
        "This original is no longer waiting here — it may already be back in "
        + "the note."

    private static func actWord(_ op: String?) -> String? {
        switch op {
        case "divide": return "divide"
        case "merge": return "merge"
        case "extract": return "extract"
        default: return nil
        }
    }

    /// The stored canonical stamp through the ONE parser, never re-parsed by
    /// hand; an unparseable stamp renders no date at all rather than raw ISO
    /// (`TrayRowPreview.stampText`'s rule).
    ///
    /// **DATE ONLY, deliberately** — and the capture is why: with the time of
    /// day in it, the lineage row read "From a merge on aug 18, 2026 at 6:30
    /// am — the original is p…", i.e. the sentence's own point fell off the
    /// end to make room for a minute nobody needs.
    static func stamp(_ raw: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: raw) else { return nil }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

/// What a history face renders for ONE grouped savepoint row (13j J11 — the
/// quiet-run collapse). The grouping itself is pure and lives in core
/// (`SavepointRuns`); this is the RENDER DECISION above it — collapsed line,
/// or line plus its savepoints — and the toggle both faces run.
///
/// Shared at batch 6a: it was already the rule two Mac faces shared, and the
/// phone's Block History is the third.
nonisolated enum SavepointHistoryFace {
    struct Rendered<Item> {
        /// The collapsed line's count, where this row is a run — nil for a
        /// lone savepoint, which renders as itself.
        var runCount: Int?
        /// Whether that line currently offers "hide" rather than "show".
        var expanded: Bool
        /// The savepoint rows to draw under it. A collapsed run draws none:
        /// that is what collapsing IS, and stating it here rather than in a
        /// view's `if` is what lets a test assert it.
        var items: [Item]
    }

    static func rendered<Item>(
        _ row: SavepointRuns.Row<Item>, expanded: Set<String>
    ) -> Rendered<Item> {
        guard let count = row.runCount else {
            return Rendered(runCount: nil, expanded: false, items: row.items)
        }
        let open = expanded.contains(row.id)
        return Rendered(runCount: count, expanded: open, items: open ? row.items : [])
    }

    /// The toggle both faces run — one rule for what a click on a run does.
    static func toggling(_ id: String, in expanded: Set<String>) -> Set<String> {
        var next = expanded
        if next.contains(id) { next.remove(id) } else { next.insert(id) }
        return next
    }
}
