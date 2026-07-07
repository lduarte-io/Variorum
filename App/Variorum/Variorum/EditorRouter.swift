//
//  EditorRouter.swift
//  Variorum (Mac)
//
//  Parent-composition routing for the focused editor: commands address the
//  active editor through this, never feature-to-feature. Mac-only (the TK2
//  editor is the Mac's surface); split out of AppSession when the session
//  became shared with the mobile target (Phase 8).
//

import Observation

@MainActor
@Observable
final class EditorRouter {
    weak var active: EditorViewModel?
    /// Top visible text location per post (UTF-16 offset) — content-anchored
    /// reopen restore (accepted memo: never px-anchor).
    @ObservationIgnored var scrollAnchors: [String: Int] = [:]
}
