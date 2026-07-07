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
            "This post is sealed — unlock it to restructure."
        case .gapSlot:
            "This block hasn't fully synced yet — try again once it arrives."
        case .lockedVariant:
            "This take is locked — branch it or unlock it first."
        case .openTailTarget:
            "This text isn't a block yet — it becomes one moments after you pause typing."
        case .crossBlockSpan:
            "The selection crosses a block boundary. Divide the neighbors at the edges you want, then merge the middle pieces."
        case .wholeBlockSpan:
            "That span is the whole block — it already is a block."
        case .middleSpanNeedsMakeBlock:
            "Extract takes a span at the block's start or end. For a middle span, use Make Block from Selection."
        case .fannedMiddleSpan:
            "This block has other takes, and they carry no cut marks — use Divide Block at Cursor to open the take ceremony instead."
        case .tooManyBlocksForMerge:
            "Merge joins exactly two blocks — select two neighbors, no more."
        case .notASeam:
            "To merge, put the caret at a block seam or select exactly two adjacent blocks."
        case .nothingToDo:
            "No legal boundary for that here."
        case .invalidSelection:
            "The editor lost track of the selection — try again."
        }
    }
}
