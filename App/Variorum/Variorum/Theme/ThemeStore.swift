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
    ///
    /// **The one global text-surface typography is adopted HERE, where a
    /// settings value LANDS** (18d ladder round 1, MINOR-2). It used to be
    /// adopted by `RootView`'s `.onChange(of: theme.settings)` — a VIEW
    /// noticing a change — which is one turn later and, worse, conditional
    /// on the loaded value DIFFERING from the compile-time default: a store
    /// whose settings happen to equal the default never fires it at all, and
    /// a Study store fires it only after a SwiftUI update cycle. Anything
    /// that stamps or compares the typography (`SurfaceSizeMemory`, whose
    /// records carry the type they were measured in) was reading a guess in
    /// that gap. The store is the theme's authority; the adoption belongs to
    /// it. `RootView` still owns the markdown palette, which also depends on
    /// the color SCHEME and so is genuinely a view's question.
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.themeSettings(db)
            }) {
                settings = value
                EditorTypography.adopt(value)
                // 18i (her R-Q5): the receipt style is adopted HERE too,
                // for the same reason and by the same rule — a settings
                // value is adopted where it LANDS, never guessed by a view
                // and never re-read per surface (F-6: "the setting is read
                // by the centre once from the landed store"). The centre's
                // compile-time value is already her default, so the gap
                // before the first emission behaves as the store says.
                session.status.receiptStyle = value.receiptStyle
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The resolved tokens for the current scheme (R51: dark = fully black
    /// in both voices).
    ///
    /// **18g:** the palette and its custom seeds ride here and nowhere else
    /// — one resolver, consulted at the one store, so no surface ever reads
    /// the palette setting itself (F-0's "every setting is read ONCE at its
    /// store and pushed down"). A surface that already asked this store for
    /// tokens gains the palette by construction.
    func tokens(dark: Bool) -> VoiceTokens {
        VoiceTokens.resolve(
            voice: settings.voice,
            palette: settings.palette,
            tint: PaletteTint(room: settings.customRoom, accent: settings.customAccent),
            dark: dark)
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

    /// 18i (her R-Q5): the confirmations setting. A setter and nothing more
    /// — the adoption is `start`'s, above, so the centre and the pane can
    /// never disagree about what landed.
    func setReceiptStyle(_ style: ReceiptStyle) {
        run { try $0.setReceiptStyle(style) }
    }

    /// 18g (her R-Q6): the colour palette. A setter and nothing more, like
    /// `setVoice` beside it — it cannot refuse, so it needs no words. The
    /// CUSTOM SEEDS deliberately do NOT have one here: `setThemeTints` can
    /// refuse a value that is not a colour, and a setter whose refusal this
    /// store would swallow into `lastError` (which nothing renders) is a
    /// trap. Its door is the Appearance pane's own, beside the three other
    /// refusable settings on that pane, which show the operations layer's
    /// real words inline.
    func setThemePalette(_ palette: ThemePalette) {
        run { try $0.setThemePalette(palette) }
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

    /// **17o batch c (her U-7 · U-19 (5)):** the editing-indicator style a
    /// surface pushes into its panes, resolved for a host whose store may
    /// be absent (previews, a detached hosting root, the pins) — the
    /// shipped RING, so a surface the appearance push has not reached
    /// looks exactly as it always did.
    ///
    /// ONE copy, deliberately: the fallback is a decision, and a decision
    /// copied into ten hosts is the drift class row 6 exists because of.
    static func editingIndicator(of store: ThemeStore?) -> EditingIndicatorStyle {
        store?.settings.editingIndicator ?? .outline
    }
}
