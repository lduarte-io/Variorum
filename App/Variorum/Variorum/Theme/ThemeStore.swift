//
//  ThemeStore.swift
//  Variorum
//
//  Phase 13, B1 — the live theme: observes the synced appearance settings
//  (Queries.themeSettings — a bounded fetch over the tiny setting table)
//  and resolves VoiceTokens per color scheme. Setters go through the
//  operations runner like every write. Views take the store from the
//  environment and never hold literal colors.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class ThemeStore {
    @ObservationIgnored private let session: AppSession
    private(set) var settings = Queries.ThemeSettings()
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// Runs for the app's lifetime; the setting table is tiny, so the held
    /// observation is bounded by construction.
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.themeSettings(db)
            }) {
                settings = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The resolved tokens for the current scheme (R51: dark = fully black
    /// in both voices).
    func tokens(dark: Bool) -> VoiceTokens {
        VoiceTokens.resolve(voice: settings.voice, dark: dark)
    }

    // MARK: - Setters (through the runner, like every write)

    func setVoice(_ voice: ThemeVoice) {
        run { try $0.setThemeVoice(voice) }
    }

    func setSeamsVisible(_ visible: Bool) {
        run { try $0.setSeamsVisible(visible) }
    }

    func setEditingIndicator(_ style: EditingIndicatorStyle) {
        run { try $0.setEditingIndicator(style) }
    }

    func setInlineComments(_ inline: Bool) {
        run { try $0.setInlineComments(inline) }
    }

    func setFollowTheScroll(_ follows: Bool) {
        run { try $0.setFollowTheScroll(follows) }
    }

    func setFanStyle(_ style: FanStyle) {
        run { try $0.setFanStyle(style) }
    }

    /// Round 3 NIT: setters CHAIN instead of racing — parallel unstructured
    /// tasks could enter the runner out of click order and settle on the
    /// older value (the trap-2 class at the settings surface). Each write
    /// awaits its predecessor, so the last click always wins.
    @ObservationIgnored private var pendingWrite: Task<Void, Never>?

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) {
        pendingWrite = Task { [previous = pendingWrite] in
            await previous?.value
            do {
                try await session.runner.run(body)
                lastError = nil
            } catch {
                lastError = String(describing: error)
            }
        }
    }
}

/// Convenience: the resolved tokens for a SwiftUI context.
extension ThemeStore {
    func tokens(for scheme: ColorScheme) -> VoiceTokens {
        tokens(dark: scheme == .dark)
    }
}
