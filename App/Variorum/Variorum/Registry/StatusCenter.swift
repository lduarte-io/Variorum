//
//  StatusCenter.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (AD-14): ONE refusal/status presentation. Every
//  transient outcome — refusals, confirmations, undo reports — lands here
//  and renders in ONE place (the shell's status toast, mode-independent),
//  with ONE auto-dismiss policy. This is what makes ⌥⌘Z's outcome visible
//  on every surface (N4 — it used to report into a nil Write editor) and
//  retires the per-surface notice styles that never dismissed (AD-17's
//  sibling report).
//
//  View models keep their `statusMessage` properties (pins and sheets read
//  them); the app-level PRESENTATION is this center's — the properties
//  forward here on set.
//

import Foundation
import Observation

@MainActor
@Observable
final class StatusCenter {
    struct Item: Equatable {
        let id: UUID
        let text: String
    }

    private(set) var current: Item?

    /// The one auto-dismiss policy (injectable for tests).
    @ObservationIgnored var dismissAfter: Duration = .seconds(6)
    @ObservationIgnored private var dismissTask: Task<Void, Never>?

    func speak(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = Item(id: UUID(), text: trimmed)
        current = item
        dismissTask?.cancel()
        dismissTask = Task { [weak self, dismissAfter] in
            try? await Task.sleep(for: dismissAfter)
            guard !Task.isCancelled else { return }
            if self?.current?.id == item.id {
                self?.current = nil
            }
        }
    }

    func clear() {
        dismissTask?.cancel()
        dismissTask = nil
        current = nil
    }
}
