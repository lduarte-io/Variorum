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
    static let mintOnNote =
        "Newlines make blocks again in this note — each finished paragraph "
        + "becomes its own block as you type past it, and pasted paragraphs "
        + "arrive as blocks. Existing blocks are untouched."

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
        "ON (the standard): each finished paragraph becomes its own block as "
        + "you type past it; pasted paragraphs arrive as blocks. OFF (opt-in): "
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
        + "standard): a finished paragraph becomes its own block as you type "
        + "past it, and pasted paragraphs arrive as blocks. OFF: newlines "
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
    /// The word-count label's hover help (both bars) — it names the quiet
    /// door: clicking the counts opens the target setter.
    static let help =
        "Word counts — click to set a word target for this note. "
        + "A target shows progress here; it is a measure, never a wall."
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

nonisolated enum OpsRefusalCopy {
    static func message(for error: Error) -> String {
        if let error = error as? OperationError {
            switch error {
            case .lockedPost:
                return "This note is sealed — unseal it to change takes or choices."
            case .archivedVariant:
                return "That take is archived — unarchive it first."
            case .lockedVariant:
                return "That take is locked — unlock it or branch a new take."
            case .versionLinkNotFound:
                return "These two notes aren't marked as versions — nothing to unmark."
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
                    + "and the take ceremony will open, so each take gets its own cut."
            // 13f batch 6 (W4): the star cap, refusing honestly rather than
            // evicting her oldest star. The refusal NAMES the road, which
            // is the whole reason the cap is a refusal and not a silent
            // drop (P-2 — a door that fires and says what to do instead).
            case .starLimitReached(let limit):
                return "You can star \(limit) things at a time — un-star one in the "
                    + "\(StarCopy.sectionHeader) list at the top of the sidebar, and "
                    + "this can take its place."
            case .blockCarriesUnshownText:
                return "That block isn't empty after all — it carries a take or "
                    + "a note that isn't shown here. Nothing was deleted."
            default:
                return "Refused: \(error)"
            }
        }
        return String(describing: error)
    }
}
