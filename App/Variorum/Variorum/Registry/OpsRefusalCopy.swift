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
