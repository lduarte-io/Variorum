//
//  OpsRefusalCopy.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (AD-14 + the Stage 0 cross-feature finding): the
//  operations layer's refusals in the app's words, ONE home. This used to
//  live as `TakesViewModel.message(for:)` and three other features (Canvas,
//  Block TOC, Tutorial) reached into the Takes feature for it — refusal
//  copy is shared vocabulary, so it lives in the shared layer. Copy is
//  sourced from the ops layer's REAL errors, never invented per surface.
//

import Foundation
import VariorumCore

/// 13b 4D (N34 — S4-14/S4-21): the one_block face's shared vocabulary —
/// ONE home for the copy both bars speak (Write's CommitBar and the
/// Takes/Lenses bar face the same per-post setting). The setting is a FACE
/// over the Phase-1 segmentation machinery (`setSegmentationDefault`,
/// Phase 2); `one_block` is ENTRY-WIDE by the model's standing meaning —
/// typing AND paste (S4-21 ratified it; no semantics change here, ever).
nonisolated enum SegmentationFaceCopy {
    /// The chip's label halves (legible words, R93 — never a coined term).
    static let chipOn = "newlines make blocks: on"
    static let chipOff = "newlines make blocks: off"

    /// The honest consequence, spoken on toggle (the architect precision:
    /// segmentation governs FUTURE entry — existing blocks never
    /// re-segment).
    static let mintOffNote =
        "Newlines now stay inside the block in this note — typing and pasting "
        + "won't make new blocks; Divide (⌘⇧D) or New Block Below (⌘⇧⏎) split "
        + "deliberately. Existing blocks are untouched."
    // 18c ladder round 1, R1-8: "in Write" — the key's act is the Write
    // editor's; a take pane's ⏎ is content, and this note is spoken from the
    // Takes board's chip too.
    static let mintOnNote =
        "Newlines make blocks again in this note — in Write, Return makes a "
        + "block wherever the cursor is, and pasted paragraphs arrive as "
        + "blocks. Existing blocks are untouched."

    /// 13d batch 4 (A16): the note a post speaks when it is turned back ON
    /// and the DOCUMENT-GLOBAL default is itself `one_block`. Turning the
    /// chip on writes per-post NIL — "inherit" (4D's recorded mapping, kept
    /// deliberately so a global one_block choice stays honored) — so under
    /// a global OFF the post keeps behaving as OFF, and `mintOnNote` would
    /// be a lie. The door still acts (it really does clear the override);
    /// it just says what that means (P-2). Only reachable BECAUSE this
    /// batch made the global settable, which is why this batch owns it.
    static let mintOnInheritsOffNote =
        "This note now follows your global setting — and that is currently "
        + "\"newlines don't make blocks\", so newlines still stay inside the "
        + "block here. Change it in Settings ▸ Appearance ▸ Writing."

    /// The ONE place either bar picks a note: what was ASKED for versus
    /// what the post now EFFECTIVELY does. Both callers re-read the header
    /// before asking, so this can never speak past a stale projection.
    static func note(asked mint: Bool, effectivelyMints: Bool) -> String {
        guard mint else { return mintOffNote }
        return effectivelyMints ? mintOnNote : mintOnInheritsOffNote
    }

    /// The chip's hover help (both bars).
    static let help =
        "ON (the standard): in Write, Return makes a block wherever the cursor "
        + "is — a new block below at a paragraph's end, a divide inside its "
        + "text — and pasted paragraphs arrive as blocks; ⇧⏎ stays a newline "
        + "inside the block, and a take pane's ⏎ is always content. OFF (opt-in): "
        + "newlines stay INSIDE the block — typing and pasting never make "
        + "blocks in this note; Divide (⌘⇧D) or New Block Below (⌘⇧⏎) split "
        + "deliberately. Governs future entry only — existing blocks never "
        + "re-segment. Per note — ON means "
        + "\"follow the global setting\" (Settings ▸ Appearance ▸ Writing)."

    // MARK: - The GLOBAL face (13d batch 4 — A16 / N34's deferred half)

    /// The Settings picker's label and its two offered modes. Sentence
    /// segmentation is deliberately NOT offered: type-time crystallization
    /// is paragraph-granular in EVERY mode (the ratified 2026-07-06 rule),
    /// so a sentence choice here would name a behaviour the editor does not
    /// have. `bulkSegments(.sentence)` stays reachable where it always was.
    static let globalTitle = "Newlines make blocks"
    static let globalParagraph = "On — each paragraph becomes its own block"
    static let globalOneBlock = "Off — newlines stay inside the block"

    static let globalHelp =
        "The default for every note that has no setting of its own. ON (the "
        + "standard): in Write, Return makes a block wherever the cursor is, "
        + "and pasted paragraphs arrive as blocks. OFF: newlines "
        + "stay inside the block everywhere — Divide (⌘⇧D) or New Block "
        + "Below (⌘⇧⏎) split deliberately. Governs future entry only; "
        + "existing blocks never re-segment, and a note with its own setting "
        + "keeps it. Synced to all your devices."

    static let globalMintOnNote =
        "Newlines make blocks by default again. Existing blocks are "
        + "untouched, and notes with their own setting keep it."
    static let globalMintOffNote =
        "Newlines now stay inside the block by default — typing and pasting "
        + "won't make new blocks. Existing blocks are untouched, and notes "
        + "with their own setting keep it."
}

/// 13b 4F (N36 — S4-28.1): the per-post word-target face's shared
/// vocabulary — ONE home for the copy both bars speak (the face rides the
/// word-count label in Write's CommitBar and the Takes/Lenses bar alike;
/// R118 parity of prominence). A target is display/progress ONLY — the
/// ratified `word_target` semantics, mirrored per post: never a wall,
/// never an entry-time refusal.
nonisolated enum WordTargetFaceCopy {
    /// The word-count label's hover help (both bars) — the WHOLE fact
    /// first, then both gestures.
    ///
    /// **13u4 UNIT S2 (her item 1):** the click now CONDENSES the counts, so
    /// the target setter it displaced is named as the right-click — and the
    /// whole fact leads, because in the collapsed faces this sentence is
    /// where the counts she is not looking at have gone. (It used to read
    /// *"Word counts — click to set a word target for this note…"*, which
    /// after her ruling would have been a face teaching the wrong gesture.)
    static func help(whole: String?) -> String {
        (whole.map { "\($0) \u{2014} " } ?? "Word counts \u{2014} ")
            + "click condenses them; right-click sets a word target for this note, "
            + "which shows progress here and is a measure, never a wall."
    }

    /// What the collapsed face is called where there are no words to read
    /// it by (VoiceOver, and any face that draws only the glyph).
    static let iconLabel = "Word counts"

    /// The context menu's target rows — the door her keep asks for, offered
    /// in every face: *"I like that it offers to set a word count target, so
    /// I want to keep that functionality."*
    static let setTargetItem = "Set a word target\u{2026}"
    static let changeTargetItem = "Change the word target\u{2026}"
    static let clearTargetItem = "Clear the word target"

    /// …and the four faces themselves, so the cycle is legible rather than
    /// folklore. The unit's noun is the BAR's (a block in Write, a take on
    /// the boards) — the same word the counts themselves use.
    static func faceItem(_ face: CountsFace, unitNoun: String) -> String {
        switch face {
        case .full: "Full counts"
        case .note: "Only the note"
        case .block: "Only this \(unitNoun)"
        case .icon: "Just an icon"
        }
    }
    static let fieldPrompt = "Word target (blank = none)"
    static let parseError = "Targets are plain positive numbers (e.g. 5000) — nothing was changed."
    static func setNote(_ target: Int) -> String {
        "Word target set — \(target.formatted())w. Progress shows beside the "
        + "word counts; a target is a measure, never a wall."
    }
    static let clearNote = "Word target cleared."
    /// The label's progress segment ("26% of 5,000w target").
    static func progressSegment(words: Int, target: Int) -> String {
        let percent = Int((Double(words) / Double(target) * 100).rounded())
        return "\(percent)% of \(target.formatted())w target"
    }
}

/// 13e batch 3 — what the take↔block doors SAY when they act (her A20/A21,
/// under architect ruling AR-1). ONE home, for the `BookNameCopy` reason
/// (that enum now lives in `Shared/BookNameCopy.swift` — hoisted, not
/// copied, when the phone's book doors needed the same sentence):
/// both editor kinds render these doors (R118 — Write is never privileged),
/// and a receipt written twice is a promise no test can keep.
///
/// Every line names where the ORIGINAL went, because AR-1's whole shape is
/// that nothing is lost: the take is archived on its own block, reachable in
/// the archived listing with its commits. A door that removes a take from a
/// fan without saying it is recoverable is the lecture-less-silence class
/// P-2 retired.
nonisolated enum TakeStructureCopy {
    static let movedNote =
        "That take is now the block below — the original is archived on its "
        + "block (\u{201c}archived \u{B7} n\u{201d} under its takes brings it back); "
        + "\u{2325}\u{2318}Z undoes it."

    /// The conversion's receipt, counts and all — including the blank takes
    /// it passed over (AR-1(d): they are skipped, and the door says so
    /// rather than leaving her to notice a missing block).
    static func convertedNote(blocks: Int, skippedBlanks: Int) -> String {
        var line = blocks == 1
            ? "1 take is now its own block below"
            : "\(blocks) takes are now their own blocks below"
        line += " — this block still shows the take it showed, and the originals "
            + "are archived on it."
        if skippedBlanks > 0 {
            line += skippedBlanks == 1
                ? " 1 blank take was left alone (there was nothing to make a block from)."
                : " \(skippedBlanks) blank takes were left alone "
                    + "(there was nothing to make blocks from)."
        }
        return line + " \u{2325}\u{2318}Z undoes it."
    }
}

/// 13e batch 4 — what the BLOCK SELECTION says (her A17, verbatim: *"delete
/// several blocks at the same time from a post - highlighting all of the
/// blocks perhaps? block highlight instead of text highlight across
/// blocks?"*). ONE home, for the `TakeStructureCopy` reason: the two post
/// surfaces that host a selection — Write's editor and the Takes board —
/// render the same banner and the same receipt, and words written twice are
/// a promise no test can keep.
nonisolated enum BlockSelectionCopy {
    /// The banner's line. It teaches the second gesture where the first one
    /// just worked, which is the only moment the hint is welcome.
    static func bannerLabel(picked: Int) -> String {
        picked == 1
            ? "1 block picked — \u{2318}-click another, or \u{2318}\u{21e7}-click to "
                + "pick a whole run"
            : "\(picked) blocks picked"
    }

    static func deleteVerb(picked: Int) -> String {
        picked <= 1 ? "Delete Block" : "Delete \(picked) Blocks"
    }

    /// **13j J8(a), GRADUATED (batch 2).** Batch 1 trimmed this line to the
    /// interim truth because the tray it named had no door; batch 2 built
    /// the door, so the whole truth fits again — and the two halves are
    /// different promises, deliberately: ⌥⌘Z is the immediate one-gesture
    /// reversal that dies with the session, the tray is the one that does
    /// not. A receipt that named only the first taught her that a delete is
    /// permanent after a restart, which is exactly what her morning report
    /// found.
    static let deleteHelp =
        "Delete every picked block — \u{2325}\u{2318}Z brings them all back at "
        + "once, and afterwards they wait in \(TrayPath.menuLabel)"

    /// The receipt. It names the ONE undo, because the whole point of the
    /// compound is that a multi-delete is one mistake to reverse, not N.
    ///
    /// **13j J8(a) — GRADUATED (batch 2).**
    ///
    /// The history, because it is the point. This line used to promise the
    /// block "waits in this note's deleted-blocks tray", and her first
    /// morning back found that the tray HAD NO FACE anywhere: the ops
    /// existed (`restoreBlock`, `last_container_id`) with no door, so past
    /// the session's ⌥⌘Z window a deleted block was unreachable by any
    /// click. Batch 1 withdrew the promise and said only what was true.
    /// **Batch 2 built the door, so the promise comes back — naming it.**
    ///
    /// It names BOTH roads because they are different promises: ⌥⌘Z is the
    /// immediate reversal that dies with the session; the tray is the one
    /// that survives a restart. Saying only the first is what made a delete
    /// feel permanent.
    /// **AND THE SCRAPS AREA GETS ITS OWN ROAD** (the post-13l polish round,
    /// ledger row 4 — her A4 ruling on the 13l walk's P-8: *"I'd fix whatever
    /// this is"*).
    ///
    /// The scraps editor composes this same bar over a `kind='pool'`
    /// container, so deleting a scrap printed *"…then in **This Note's Tray**
    /// — the ⌫ door in **the note's bar**"* on a surface that is not a note
    /// and carries no ⌫ badge. The road it named was findable only if you
    /// already knew that the note ▾ menu's tray item works on a pool too.
    ///
    /// The honest road for a scrap is the one the walk actually saw work: it
    /// rows in the **Trash**, labelled *"from scraps"*, with an **Open
    /// scraps** door beside it. So a pool home names that, and ⌥⌘Z — the
    /// immediate reversal — survives either way, because it is the same
    /// gesture wherever the block lived.
    ///
    /// `.post` is the default so every shipped caller and pin rides
    /// unmodified: a note's receipt is byte-identical to what it has always
    /// said.
    static func deletedNote(_ count: Int, home: ContainerKind = .post) -> String {
        let road: String
        switch home {
        case .post:
            road = "then in \(TrayPath.menuLabel) \u{2014} \(TrayPath.doorPhrase)."
        case .pool:
            road = "then in the \(RecoveryCopy.trashSection)."
        }
        return count == 1
            ? "Block deleted — \u{2325}\u{2318}Z puts it back, \(road)"
            : "\(count) blocks deleted — \u{2325}\u{2318}Z puts them all back in one go, "
                + road
    }

    /// **The ARCHIVE receipt** (13j, her round-7 ruling — the third verb).
    /// It says the thing that makes archive different from delete IN THE
    /// SAME BREATH as the act: no clock.
    ///
    /// **The road it names moved with the door** (the post-13l polish round,
    /// batch 1's deferred item + ledger row 9): it said *"(the note menu)"*,
    /// and her C1 ruling took the tray out of that menu. The reasoning behind
    /// the old wording is unchanged and is exactly why it must follow — the
    /// receipt may never point at the tray BADGE, which counts DELETED blocks
    /// only (her ratified #67(a)) and stays hidden for a note that has only
    /// archived something. The icon is always there; the badge is not.
    ///
    /// And it takes the home's KIND for `deletedNote`'s reason, one act over:
    /// the scraps editor archives blocks through the same menu, and an
    /// archived scrap's road really IS the tray (it has no clock and never
    /// reaches the Trash) — it is the tray's NOUN that was wrong there.
    static var archivedNote: String { archivedNote(home: .post) }

    static func archivedNote(home: ContainerKind) -> String {
        "Block archived — it's kept, with no countdown, in "
        + "\(TrayPath.menuLabel(for: home)) \u{2014} "
        + "\(TrayPath.doorPhrase(for: home)). \u{2325}\u{2318}Z undoes this."
    }

    /// **The stranding sentence** (her round-8b ruling (d)): when a delete
    /// takes the LAST live descendant of a preserved original, the original
    /// stops being permanent and starts counting down with the family — and
    /// the receipt says so, because her named failure mode was believing an
    /// ancestor waiting in the tray was a guaranteed backup.
    static func strandedOriginalNote(_ count: Int) -> String {
        count == 1
            ? " The original preserved from this block's divide rides the Trash with it."
            : " \(count) preserved originals ride the Trash with these blocks."
    }

    /// Nothing picked. Reachable from the routed/registry note only; the
    /// banner and the context row do not render without a selection (P-2).
    static let nothingPicked =
        "\u{2318}-click the blocks you want to remove first — they highlight as "
        + "you pick them."

    /// **`blockNotFound`, in words.** It has existed since Phase 2 and
    /// dumped the raw enum, because until now every door onto it addressed
    /// the ONE block the caret was in and a surface could not offer a block
    /// the store had lost. A multi-block selection can: it is held across
    /// time while the store moves under it (another pane, the other half of
    /// a split, a sync arrival). The compound's atomic rollback means she
    /// meets it with NOTHING deleted — which is the fact the words must
    /// carry, or a rolled-back gesture reads as a half-done one.
    ///
    /// It lives here, in ONE place, because Write's editor keeps its own
    /// refusal switch (`EditorViewModel.operationMessage`) beside
    /// `OpsRefusalCopy` and both of this act's hosts must say the same
    /// sentence — a shared constant is what makes that true by
    /// construction rather than by proofreading.
    /// Hedge asymmetry (ladder round 2, R2-1): this line's thrower story is
    /// DELETED-only — a pick that merely MOVED is live at its new address
    /// and the delete door deletes it there (#60(c)), so "or moved
    /// elsewhere" could never be this sentence's truth. Merge's line keeps
    /// the wider hedge: its pre-check reads absence from THIS note's order,
    /// which moves do produce.
    static let blockGone = blockGoneLine(
        nothingWas: "deleted", hedge: "it may have been deleted since you picked it")

    /// **The same race, one door over (ladder round A, A-3).** The Takes
    /// board's merge read the vanished pick as a GAP — "these aren't next to
    /// each other" — because contiguity was the first thing asked, and a
    /// block the order no longer holds fails that test for a reason the
    /// sentence then misreports. The block is gone; saying "not adjacent"
    /// sends her hunting for a neighbour that is standing right there.
    ///
    /// Its own line rather than `blockGone` because the verb has to be true:
    /// this door merges, and nothing was merged.
    static let blockGoneForMerge = blockGoneLine(
        nothingWas: "merged", hedge: "it may have been deleted or moved elsewhere")

    /// The one sentence both refusals wear, so the pair cannot drift apart
    /// in everything except the verb and the hedge that distinguish them
    /// (the hedge asymmetry is `blockGone`'s doc comment — R2-1).
    private static func blockGoneLine(nothingWas: String, hedge: String) -> String {
        "One of the blocks you picked is already gone — \(hedge). "
        + "Nothing was \(nothingWas); pick again and retry."
    }
}

nonisolated enum OpsRefusalCopy {
    static func message(for error: Error) -> String {
        if let error = error as? OperationError {
            switch error {
            case .lockedPost:
                return "This note is sealed — unseal it to change takes or choices."
            case .archivedVariant:
                return "That take is archived — unarchive it first."
            // 13j batch 3 (the round-5 deleted-take ruling): the recovery
            // door's double-click / raced-restore path — the
            // `readingNotDeleted` sentence, one row-kind down. It is a
            // SUCCESS story told as a refusal, so it says so.
            case .variantNotDeleted:
                return "That take is already back — it's in the block's fan."
            // 13j batch 6b (J1): the purge op's three refusals, worded —
            // never the raw dump (the J8 bar, in the phase whose bar is
            // copy truth). The first is the honest impossible-door case:
            // only things in the Trash can be deleted for good.
            case .purgeTargetNotDeleted:
                return "Only things in the Trash can be deleted for good — "
                    + "delete it first, and it waits there \(TrashWindow.days) days."
            case .deliberateSavepointNeverPruned:
                return "That's a deliberate ⌘S savepoint — those are never pruned, "
                    + "in any mode."
            case .unsupportedPurgeTarget:
                return "That isn't something the Trash can delete for good."
            case .lockedVariant:
                return "That take is locked — unlock it or branch a new take."
            // 13u3 UNIT H (the enum-dump straggler this unit's own door
            // walked straight into). `deleteVariant` checks the CHOSEN
            // pointer before the last-active guard, so the commonest press
            // on a take card's Delete — the take the note is showing, and on
            // a one-take block the ONLY take — raises this; it fell to
            // `default:` and printed `Refused: variantIsChosen(id: "…")`,
            // a raw enum with a UUID in it, on a door Write's panel has
            // offered since Phase 7. The words answer BOTH readers, because
            // one error serves both states: "choose another first" is the
            // road on a fan, and on a block with nothing else to show the
            // thing she means to delete is the block.
            case .variantIsChosen:
                return "The note shows this take \u{2014} choose another take first, and then "
                    + "this one can go. (If it's the block's only take, it's the block "
                    + "you want to delete.)"
            // 13u3 ladder round 1, R1-4 — the enum-dump class's two
            // stragglers, first reachable from a face at UNIT D's rename
            // door (race-only: the take dying or the moment purged under the
            // open ask). Worded generically, because `variantNotFound` is
            // every op's honest answer to a take that is gone.
            case .variantNotFound:
                return "That take isn't there any more \u{2014} it may have just been "
                    + "deleted. The block's History lists deleted takes, with Put back."
            case .commitNotFound:
                return "That saved moment isn't there any more."
            case .versionLinkNotFound:
                return "These two notes aren't marked as versions — nothing to unmark."
            // 17o batch d (ledger row 27, J8): the mark door's own refusal
            // fell to `default:` and printed the raw enum WITH BOTH POST
            // UUIDs in it — on a click she can make by pressing the row
            // twice. Its inverse above has spoken since Sitting 9; this is
            // the missing half of that pair.
            case .postsAlreadyVersionLinked:
                return "These two notes are already marked as versions of each other."
            // Same batch, same class. Since row 17 the VERSION-LINK door no
            // longer raises this at all (a blockless note gains its anchor
            // block — her U-19 (1)); what survives are the COPY roads —
            // Compare's "make outline note" and duplicate-as-version — where
            // there is genuinely nothing to copy. `VersionActs.words` has its
            // own sentence for the note-moments family, whose "save a version
            // of" phrasing belongs only there.
            case .postHasNoBlocks:
                return "There's nothing in that note yet — write a line in it first."
            // 13b Stage 4 ladder round 1, MINOR-2: the two Stage 4 doors
            // that spoke raw enum dumps get app words. `readingNotDeleted`
            // is the recovery door's double-click/raced-restore path;
            // `readingNotFound` is its absent-row sibling AND the shared
            // `liveReading` guard's refusal (missing OR tombstoned) from
            // every reading op, so the copy serves both meanings.
            case .readingNotDeleted:
                return "That book is already restored — it's back on the shelf."
            case .readingNotFound:
                return "That book can't be found — it may have been deleted, "
                    + "or removed on another device."
            // The belt behind the extent faces (same finding): the ops
            // layer refuses non-positive targets/caps typed nowhere the
            // ONE `ExtentInput.parse` rule now guards.
            case .invalidExtent:
                return "A word target or note cap must be a positive number — "
                    + "nothing was changed."
            // 18g (her R-Q13's custom hex): the belt behind the palette
            // field. The refusal shows back what she typed and says the
            // shape, because "invalid" without an example is the R1-3
            // class — and it names that nothing moved, since a half-written
            // pair is exactly what the one-transaction setter prevents.
            case .invalidTint(let value):
                return "\u{201C}\(value)\u{201D} isn't a colour — a colour is six hex "
                    + "digits, like B9A7E6 or #8A7A3A. Nothing was changed."
            // 13c Stage 1 ladder, R3-1: the empty-block carve's
            // authorization, re-checked inside the tombstone's own
            // transaction. Worded here as well as in the editor's own
            // switch so any future door onto `deleteBlock(requiring:)`
            // inherits real words rather than the raw dump (the R1-3
            // class).
            // 13d Batch 3 (A9): reachable the moment divide has a door
            // on a board — the fan is read from the store and the op
            // re-checks it inside its own transaction, so a take arriving
            // in that window refuses HERE. It dumped the raw enum before.
            case .fannedBlock:
                return "This block has more than one take now — divide it again "
                    + "and the take you're in splits while the others stay on the "
                    + "first block (⌥⌘⇧D arranges them differently)."
            // 13f batch 6 (W4): the star cap, refusing honestly rather than
            // evicting her oldest star. The refusal NAMES the road, which
            // is the whole reason the cap is a refusal and not a silent
            // drop (P-2 — a door that fires and says what to do instead).
            case .starLimitReached(let limit):
                return "You can star \(limit) things at a time — un-star one in the "
                    + "\(StarCopy.sectionHeader) list at the top of the sidebar, and "
                    + "this can take its place."
            // 13e E13: her round-3 ruling's words, from the one home above.
            case .duplicateBookName(let existing):
                return BookNameCopy.refusal(existing: existing)
            case .blockCarriesUnshownText:
                return "That block isn't empty after all — it carries a take or "
                    + "a comment that isn't shown here. Nothing was deleted."
            // 13e batch 3 (E5/E6b — her A20/A21): the take↔block doors'
            // three refusals, in words. `lastActiveVariant` has existed
            // since Phase 2 and dumped the raw enum; E5 makes it a door she
            // will actually meet (a one-take block has nothing to move out),
            // so it gets its words here beside the two new cases.
            case .lastActiveVariant:
                return "This block has only one take — a take moves out when "
                    + "there's another one left behind. Divide the block instead (⌘⇧D)."
            case .emptyTakeCannotBecomeABlock:
                return "That take is empty — there's no text to become a block."
            case .noConvertibleTakes:
                return "This block has no other takes with text in them — "
                    + "nothing to turn into blocks."
            // 13e batch 4 (E2 — her A17): `blockNotFound` has existed since
            // Phase 2 and dumped the raw enum, because until now every door
            // onto it addressed the ONE block the caret was in and the
            // surface could not offer a block the store had lost. A
            // multi-block selection can: it is held across time while the
            // store moves under it (a sync arrival, another pane, the other
            // half of a split), and the compound's atomic rollback means she
            // meets this refusal with NOTHING deleted — which is the fact the
            // words have to carry, or a rolled-back gesture reads as a
            // half-done one.
            case .blockNotFound:
                return BlockSelectionCopy.blockGone
            // Ladder round 2 (R2-2): `blockNotFound`'s mid-flight sibling —
            // the block is live but its placement left this note between a
            // door's read and its write. First made reachable by the
            // multi-pick doors; spoke the raw enum until now.
            case .blockNotPlaced:
                return "That block is no longer in this note — it may have "
                    + "moved while you worked. Nothing was changed here."
            // 13j batch 6 (the enum-dump straggler, routed here from LADDER
            // A's round-1 sanity pass, which found it falling to `default:`
            // as "Refused: \(error)" — loud and typed, but a raw dump as a
            // sentence).
            //
            // **Reachability, VERIFIED rather than assumed** (the reviewer's
            // own gap-slot trace, re-walked in this batch): every structural
            // op resolves its text through `renderedVariant`, which throws
            // this when a slot renders NOTHING — a GAP SLOT (`variantID ==
            // nil` at render) is the shipped case, and the merge, divide,
            // extract, pool-copy and version doors all pass through it. Its
            // sibling on that same road, `blockNotFound`, already speaks
            // (13e E2), so this is the last one; the OTHER errors those
            // doors raise are worded above. It is unreachable for a healthy
            // live block (I10 plus the default-variant reassignment
            // guarantee one), which is exactly why the words describe the
            // state it really means — text that has not arrived here yet —
            // rather than blaming her for a block she can see.
            // **13u1 UNIT 2 (item 8's U-3, the Mac half of the gap
            // fence's missing face).** The mobile round created this
            // Mac-side gap and the handback row names it: a span covering
            // an interior block that has NOT ARRIVED renders that block
            // with zero length, so the old planner ran straight past it and
            // the merge chain refused across it — and `operationMessage`
            // had no case, so she met the RAW `blocksNotAdjacent(first:
            // second:)` enum dump. The compound's run now fences the gap
            // before any op runs (it is an index RANGE, not the intersected
            // set), so this is the belt behind that brace: the ordinary
            // race, a block landing or leaving between a plan and its
            // write. The phone has said this sentence since M22; the Mac
            // says it now, and the two are the same reading.
            case .blocksNotAdjacent:
                return "Something sits between these blocks — a block that hasn't "
                    + "arrived yet, or one that landed since you selected. "
                    + "Nothing was changed."
            case .noRenderableVariant:
                return "That block has no text here yet — it may still be "
                    + "arriving from another device. Nothing was changed; "
                    + "try again in a moment."
            default:
                return "Refused: \(error)"
            }
        }
        return String(describing: error)
    }
}

// MARK: - "Make every newline a block" (18c batch 3 — her U-6)

/// Every sentence the newline repair speaks. ONE home, beside its
/// neighbours, because FIVE doors say it — Write's two bar menus, the Takes
/// bar's two, and the two bulk bars — and a receipt worded five ways is how
/// copy drifts (`FannedDefaultsCopy`'s own reason).
///
/// **The J8 copy-truth doctrine binds every line here:** the counts come
/// from the operation's OWN results (the 13e receipt rule), the takes clause
/// appears only when takes actually rode, and a note where nothing split
/// gets a real refusal rather than a lecture (P-2).
nonisolated enum SplitAtNewlinesCopy {
    /// The verb, in her words — the note ▾ row.
    static let noteDoor = "Make every newline a block"
    /// The block ▾ row.
    static let blockDoor = "Split this block at its newlines"
    /// The bulk bars' compact label.
    static let bulkDoor = "split at newlines"

    static let noteHelp =
        "Every paragraph in this note becomes its own block — the takes on a "
        + "multi-paragraph block stay with its TOP paragraph. Lists stay whole. "
        + "\u{2325}\u{2318}Z undoes the whole thing."
    static let blockHelp =
        "This block's paragraphs become their own blocks — its takes stay with "
        + "the top one. \u{2325}\u{2318}Z undoes."

    /// **THE RECEIPT.** `made` and `from` are the operation's own numbers:
    /// how many blocks came out, and how many blocks went in — counting ONLY
    /// the blocks that actually had a newline to split at, because a block
    /// that was already one paragraph was not acted on.
    static func split(made: Int, from: Int, takesKept: Int, takesLeftBehind: Int = 0) -> String {
        var sentence = "\(made) blocks from \(from == 1 ? "1 block" : "\(from) blocks")"
        if takesKept > 0 {
            sentence += " — every take stayed with its top paragraph"
        }
        if takesLeftBehind > 0 {
            sentence += takesLeftBehind == 1
                ? "; 1 empty take stayed with the original block"
                : "; \(takesLeftBehind) empty takes stayed with the original block"
        }
        return sentence + ". \u{2325}\u{2318}Z undoes."
    }

    /// **The ONE arithmetic every door speaks through** — handed the
    /// operation's own results and nothing else, so no surface can count a
    /// receipt its own way (13e's rule, and the reason the five doors share
    /// this file). Blocks that were already one paragraph are not counted:
    /// they were not acted on.
    static func receipt(
        _ results: [Operations.SplitAtNewlinesResult], whenNothingSplit: String
    ) -> String {
        // N3 (the 18i ladder round 1): ONE spelling of "did anything
        // split" — this used to compute its own `filter { !$0.isNoOp }`
        // six lines from the predicate that answers the same question.
        guard acted(results) else { return whenNothingSplit }
        // N3 (round 2): named for what they ARE, not for the method that
        // renders them — the round-1 collapse called this `split` and had to
        // reach the static `split(made:from:…)` as `self.split(…)`.
        let splitters = results.filter { !$0.isNoOp }
        return split(
            made: splitters.reduce(0) { $0 + $1.blocksMade },
            from: splitters.count,
            takesKept: splitters.reduce(0) { $0 + $1.takesKeptOnTop },
            takesLeftBehind: splitters.reduce(0) { $0 + $1.takesLeftBehind })
    }

    /// The honest no-op — a REFUSAL that says what is already true, never a
    /// lecture that redirects to nothing (P-2).
    /// **18i (her R-Q5): which CLASS the line above carries.** A split that
    /// split something is a RECEIPT — her confirmations setting governs it.
    /// "Already one paragraph" is a REFUSAL: nothing happened, and P-2 says
    /// she must see that whatever the setting says. ONE predicate, consulted
    /// by every door that speaks this copy, so no site re-derives it.
    static func acted(_ results: [Operations.SplitAtNewlinesResult]) -> Bool {
        results.contains { !$0.isNoOp }
    }

    static let noteAlreadyWhole = "Every block is already one paragraph."
    static let blockAlreadyWhole = "This block is already one paragraph."
    static let pickedAlreadyWhole = "Every picked block is already one paragraph."
}

// MARK: - The cross-block compound (13u1 UNIT 2 — her item 5)

/// **What the cross-block compound SAYS when it lands.** Her legibility
/// mandate is the whole reason this file gained an entry: *"receipts name
/// where every block went"*, and her worked example is the shape —
/// *"2 blocks to the Trash; A and C merged — originals in the new block's
/// History."*
///
/// **Why a gesture that used to be silent speaks now, and why that is not
/// the noise she declined.** The merge-then-edit road said nothing, on
/// purpose — a message on every join would have been chatter, and the
/// tutorial's "the two exits" lesson made a virtue of it. Two things
/// changed. First, this gesture now moves blocks to the TRASH, which is a
/// place she has to be told about (the J8(a) lesson: a delete whose receipt
/// names no road reads as permanent). Second, 18i made a RECEIPT quiet by
/// default (her R-Q5: toast · quiet · off, quiet the default) — so this line
/// is a muted line at the bottom bar's trailing end, not a toast in front of
/// her prose. The receipt she declined and the receipt she mandated are not
/// the same object.
///
/// ONE home, beside its neighbours, because the compound has two hosts (the
/// note editor and the scraps editor, which is why `home` is a parameter)
/// and because the DELETION clause must be the same sentence the bulk bar
/// speaks — one grammar, never two (her item 5: *"composes with the Blocks
/// workbench's bulk grammar"*).
nonisolated enum CrossBlockEditCopy {
    /// The receipt, built from what the compound ACTUALLY did — never from
    /// what the plan hoped (the 13e receipt rule: counts come from the
    /// operation's own results).
    ///
    /// **SHORT, AND IN THAT ORDER, BECAUSE THE WALK MEASURED IT.** The first
    /// build composed `BlockSelectionCopy.deletedNote` whole and appended the
    /// join clause — one grammar with the bulk bar, and on the dev build's
    /// 1728 pt window it TRUNCATED at *"…the tray icon at the top of the
    /// note…"*, which is exactly where the join clause began. A receipt whose
    /// second destination falls off the end does not keep her mandate
    /// (*receipts name where every block went*), and the quiet line truncates
    /// by design — one line, tail, the whole sentence one hover away
    /// (`QuietReceiptLine`'s own contract). So this says both destinations by
    /// their NOUNS, first, and spends what is left on the road out.
    ///
    /// The nouns are the shared constants, not new words: the tray the bulk
    /// bar names (`TrayPath.menuLabel`, home-aware — the scraps editor
    /// composes this bar too) and the lineage region Block History names
    /// (`BlockHistoryPath.cameFromSection`). One grammar is kept where it
    /// matters — the same PLACES, called the same things, with the same ⌥⌘Z.
    static func receipt(
        _ outcome: CrossBlockCompound.Outcome, home: ContainerKind = .post
    ) -> String {
        var clauses: [String] = []
        if outcome.deletedCount > 0 {
            let noun = outcome.deletedCount == 1 ? "1 block" : "\(outcome.deletedCount) blocks"
            clauses.append("\(noun) to \(TrayPath.menuLabel(for: home))")
        }
        if outcome.merged {
            // Her condition on the join ruling: *the previous blocks must be
            // EASY TO SEE in lineage.* The region's own name is the road.
            clauses.append(
                "the ends joined \u{2014} originals under \(BlockHistoryPath.cameFromSection)")
        } else if outcome.joinSuppressedByFan {
            // #11a's standing rule, said out loud instead of left to be
            // noticed: the halves join only where no fan hangs on the seam.
            clauses.append("the ends kept their own blocks \u{2014} one has takes")
        }
        // Nothing left the note and nothing joined: two ordinary buffer
        // edits. It still speaks, because a STRUCTURAL act landed from an
        // ordinary keystroke and ⌘Z — the text stack — cannot take it back
        // (the rewrite clears it by design). Naming the door that can is
        // load-bearing, not chatter (A7's carve set this shape).
        if clauses.isEmpty { clauses.append("edited across blocks") }
        return clauses.joined(separator: "; ") + ". \u{2325}\u{2318}Z undoes it."
    }
}
