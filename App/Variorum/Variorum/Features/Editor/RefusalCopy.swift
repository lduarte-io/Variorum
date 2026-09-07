//
//  RefusalCopy.swift
//  Variorum
//
//  Human-readable copy for every planner refusal (Phase 9; Step 7 owns the
//  full sweep test). The switch is exhaustive by construction: a new
//  `Refusal` case fails this build until it gets copy — refusals are
//  visible, never silent, never beep-only (the ratified contract).
//

import Foundation

nonisolated enum RefusalCopy {
    static func message(for refusal: StructuralGesturePlanner.Refusal) -> String {
        switch refusal {
        case .sealed:
            "This note is sealed — unlock it to restructure."
        case .gapSlot:
            "This block hasn't fully synced yet — try again once it arrives."
        case .lockedVariant:
            "This take is locked — branch it or unlock it first."
        case .openTailTarget:
            "This text isn't a block yet — it becomes one moments after you pause typing."
        case .crossBlockSpan:
            "The selection crosses a block boundary. Divide the neighbors at the edges you want, then merge the middle pieces."
        case .wholeBlockSpan:
            "That selection already IS a whole block (see blk n/n below) — nothing to make. Select part of it to split one out."
        case .middleSpanNeedsMakeBlock:
            "Extract takes a span at the block's start or end. For a middle span, use Make Block from Selection."
        case .fannedMiddleSpan:
            "This block has other takes, and they carry no cut marks — divide at the cursor (⌘⇧D), or Divide choosing takes (⌥⌘⇧D) to place a cut in each take."
        case .notASeam:
            "To merge, put the caret at a block seam or select across the blocks to join."
        case .nothingToDo:
            // 13b 4A: under the ruled cut rule this class shrank to the
            // genuinely-empty cases — a one-word or empty block, an empty
            // or blank selection, a span that settled closed. The copy now
            // states the rule instead of implying boundaries are scarce.
            "No legal cut spot for that here — cuts land between words, at sentence ends, and at line breaks."
        case .invalidSelection:
            "The editor lost track of the selection — try again."
        }
    }
}
