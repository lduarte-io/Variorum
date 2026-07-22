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
        "Newlines now stay inside the block in this post — typing and pasting "
        + "won't make new blocks; Divide (⌘⇧D) or New Block Below (⌥⌘N) split "
        + "deliberately. Existing blocks are untouched."
    static let mintOnNote =
        "Newlines make blocks again in this post — each finished paragraph "
        + "becomes its own block as you type past it, and pasted paragraphs "
        + "arrive as blocks. Existing blocks are untouched."

    /// The chip's hover help (both bars).
    static let help =
        "ON (the standard): each finished paragraph becomes its own block as "
        + "you type past it; pasted paragraphs arrive as blocks. OFF (opt-in): "
        + "newlines stay INSIDE the block — typing and pasting never make "
        + "blocks in this post; Divide (⌘⇧D) or New Block Below (⌥⌘N) split "
        + "deliberately. Governs future entry only — existing blocks never "
        + "re-segment. Per post."
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
        "Word counts — click to set a word target for this post. "
        + "A target shows progress here; it is a measure, never a wall."
    static let fieldPrompt = "Word target (blank = none)"
    static let parseError = "Targets are plain numbers (e.g. 5000) — nothing was changed."
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
                return "This post is sealed — unseal it to change takes or choices."
            case .archivedVariant:
                return "That take is archived — unarchive it first."
            case .lockedVariant:
                return "That take is locked — unlock it or branch a new take."
            case .versionLinkNotFound:
                return "These two posts aren't marked as versions — nothing to unmark."
            default:
                return "Refused: \(error)"
            }
        }
        return String(describing: error)
    }
}
