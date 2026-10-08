//
//  ReadPostView.swift
//  Variorum
//
//  The read-cheap tier's face (Phase 10 Step 2): a non-editable TK2 text
//  view sized to content, living inside the container's scroll (never its
//  own). Per the ratified read-tier contract: select + copy per post
//  (cross-block, one view spans the post); a PLAIN click (no drag, no
//  selection) requests focus — the container upgrades exactly this post to
//  the live editor; a drag-selection stays read-tier selection, so
//  "read-only never means inert" and click-to-focus coexist. Fan badges on
//  fanned blocks only, as overlay views (never rendering attributes).
//

import AppKit
import SwiftUI
import VariorumCore

struct ReadPostView: View {
    let session: AppSession
    let postID: String
    /// A plain click at a UTF-16 offset of the rendered document — the
    /// container upgrades this post to the live editor and seeds the caret.
    var onFocusRequest: ((Int) -> Void)?
    /// A badge tap: interpretation 1 (PROVISIONAL) — the container focuses
    /// the post FIRST, then opens the fan panel for this block.
    var onBadgeTap: ((String) -> Void)?
    /// VX-82: fired once when this surface first shows its note at a real
    /// height (`ReadPostViewModel.onShowing` — the inline editor's VX-75
    /// announce, mirrored). A host that keeps something on screen until the
    /// read tier is back (the book Outline's outgoing editor on the
    /// live→read swap) releases it here. nil everywhere else.
    var onShowing: (() -> Void)?
    /// **13u3 UNIT A1 — WHERE THIS PAGE'S PROSE SITS, and how much of the
    /// host's whitespace the surface may absorb** (`Surface/ProseGutter`).
    /// The host knows both, so the host says: the book Outline hands over
    /// its centring leftover AND its pane padding (Write's own rule at the
    /// pane's width), the spread book's page and the workspace's read pane
    /// hand over their 20 pt padding. `.contained` — the shipped 8 pt each
    /// side, no bleed — is the default, so a host this unit did not convert
    /// renders exactly as it always did.
    var gutter: ProseGutter = .contained
    @State private var model: ReadPostViewModel
    // Phase 13 C1: the voice reaches the read tier (optional environment,
    // terminal fallback in test hosts).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession,
        postID: String,
        gutter: ProseGutter = .contained,
        onFocusRequest: ((Int) -> Void)? = nil,
        onBadgeTap: ((String) -> Void)? = nil,
        onShowing: (() -> Void)? = nil
    ) {
        self.session = session
        self.postID = postID
        self.gutter = gutter
        self.onFocusRequest = onFocusRequest
        self.onBadgeTap = onBadgeTap
        self.onShowing = onShowing
        _model = State(initialValue: ReadPostViewModel(session: session, postID: postID))
    }

    private var themeSettings: Queries.ThemeSettings {
        themeStore?.settings ?? Queries.ThemeSettings()
    }

    /// 13d batch 4 (A23/A24): this Mac's editor-behaviour settings ride
    /// the chrome, so a change re-applies through the one chrome gate.
    @AppStorage(ParagraphGap.settingKey) private var paragraphGap = ParagraphGap.standard
    @AppStorage(SpellcheckLevel.settingKey) private var spellcheck = SpellcheckLevel.off

    private var chrome: EditorSurfaceChrome {
        EditorSurfaceChrome(
            tokens: themeSettings, dark: scheme == .dark,
            paragraphGap: paragraphGap, spellcheck: spellcheck)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let canary = model.canaryMessage {
                Text(canary)
                    .foregroundStyle(.white)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .textSelection(.enabled)
            }
            ReadPostSurface(
                model: model, chrome: chrome, gutter: gutter,
                onFocusRequest: onFocusRequest, onBadgeTap: onBadgeTap,
                onShowing: onShowing)
                .frame(height: model.contentHeight)
                // **THE BLEED** (13u3 UNIT A1): the surface's FRAME reaches
                // into the host's whitespace on each side while THIS view's
                // reported geometry stays exactly what it was — so every
                // remembered surface length (`SurfaceSizeMemory`), every
                // `BookHeightManifest` row and every `StableSurface`
                // reservation is untouched, and the prose inside lands back
                // on the same point it always did.
                .padding(.horizontal, -gutter.bleed)
        }
        .onAppear { model.appearance = EditorAppearance(themeSettings, dark: scheme == .dark) }
        .onChange(of: themeSettings) { _, new in
            model.appearance = EditorAppearance(new, dark: scheme == .dark)
        }
        .onChange(of: scheme) { _, new in
            model.appearance = EditorAppearance(themeSettings, dark: new == .dark)
        }
        // The observation is started by the surface's coordinator (its
        // lifetime IS the surface's — makeNSView starts it, dismantle
        // cancels it), not by `.task`: the projection feeds the text view,
        // so they must live and die together.
    }
}

// MARK: - The non-editable TK2 surface

private struct ReadPostSurface: NSViewRepresentable {
    let model: ReadPostViewModel
    let chrome: EditorSurfaceChrome
    let gutter: ProseGutter
    let onFocusRequest: ((Int) -> Void)?
    let onBadgeTap: ((String) -> Void)?
    /// VX-82 (see `ReadPostView.onShowing`).
    let onShowing: (() -> Void)?

    func makeCoordinator() -> ReadPostSurfaceCoordinator {
        ReadPostSurfaceCoordinator(model: model)
    }

    func makeNSView(context: Context) -> ReadPostTextView {
        let textView = ReadPostTextView.makeReadSurface()
        textView.proseGutter = gutter
        context.coordinator.applyChrome(chrome, to: textView)
        model.attach(textView: textView)
        context.coordinator.install(textView: textView)
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onBadgeTap = onBadgeTap
        model.onShowing = onShowing
        textView.onPlainClick = { [weak coordinator = context.coordinator] offset in
            coordinator?.onFocusRequest?(offset)
        }
        return textView
    }

    func updateNSView(_ nsView: ReadPostTextView, context: Context) {
        // Projection-driven; the callbacks and the VOICE refresh here.
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onBadgeTap = onBadgeTap
        model.onShowing = onShowing
        nsView.proseGutter = gutter
        context.coordinator.applyChrome(chrome, to: nsView)
    }

    /// Deliberate recycling (the Step 0 memo's obligation — leaked text
    /// views are the classic NSViewRepresentable rot): the canary disarms,
    /// the sinks clear, the overlay drops its buttons.
    static func dismantleNSView(_ nsView: ReadPostTextView, coordinator: ReadPostSurfaceCoordinator) {
        coordinator.uninstall()
    }
}

/// The read surface's coordinator — file-scope + internal (Stage 2 ladder,
/// MAJOR-C) so the dismantle→remake pin drives the REAL install/uninstall
/// path, not a replica.
@MainActor
final class ReadPostSurfaceCoordinator {
    let model: ReadPostViewModel
    var onFocusRequest: ((Int) -> Void)?
    var onBadgeTap: ((String) -> Void)?
    private var badges: ReadBadgeOverlay?
    private var decor: BlockDecorOverlayController?
    private var observation: Task<Void, Never>?
    private var decorObservation: Task<Void, Never>?
    private var appliedChrome: EditorSurfaceChrome?

    init(model: ReadPostViewModel) {
        self.model = model
    }

    func applyChrome(_ chrome: EditorSurfaceChrome, to textView: ReadPostTextView) {
        guard appliedChrome != chrome else { return }
        let previous = appliedChrome
        appliedChrome = chrome
        textView.applyVoiceChrome(chrome, previous: previous)
        model.remeasure()
    }

    func install(textView: ReadPostTextView) {
        // The live projections, for exactly the surface's lifetime.
        observation = Task { [model] in await model.start() }
        decorObservation = Task { [model] in await model.startDecorContext() }
        let overlay = ReadBadgeOverlay(textView: textView) { [weak self] blockID in
            self?.onBadgeTap?(blockID)
        }
        badges = overlay
        model.badgeSink = { [weak overlay] badges in overlay?.render(badges) }
        // Phase 13 C1: the shared decoration controller, read-only
        // doors (no handles; comment cards are quiet).
        let decorController = BlockDecorOverlayController(
            textView: textView, onOpenComments: nil, onMoveBlock: nil)
        decor = decorController
        model.decorSink = { [weak decorController] state in
            decorController?.render(state)
        }
        // Width reflows change wrapping, so height must re-measure —
        // the SHARED width-gated layout hook (13b 1a: the batch-12
        // brain, one copy for every pane surface; replaces this
        // surface's private frame-notification trigger). 13u3 UNIT A1: the
        // gate is the prose CONTAINER's width now, so a window resize at a
        // capped column costs no layout here.
        textView.onWidthChange = { [weak model] in
            model?.viewWidthChanged()
        }
        // …and when only the GUTTER moved, every decoration's rect is stale
        // (they are all computed from `textLeft`) while the wrapping is not.
        // Badges and decorations are re-read; nothing is re-measured.
        textView.onGutterChange = { [weak model] in
            model?.proseColumnDidChange()
        }
        // Wiring DELIVERS (MAJOR-C — the read tier's twin of the editor's
        // `pushDecorationsToSink` walk fix): state computed before this
        // host existed must not stay invisible until the next real change.
        model.pushOverlaysToSinks()
    }

    func uninstall() {
        observation?.cancel()
        observation = nil
        decorObservation?.cancel()
        decorObservation = nil
        badges?.uninstall()
        badges = nil
        decor?.uninstall()
        decor = nil
        model.decorSink = nil
        model.detach()
    }
}

// The text view: `ReadPostTextView` IS the shared pane surface now
// (13b 1a, P-3 — the typealias + `makeReadSurface` factory live in
// Surface/PaneSurface.swift; plain-click offsets, the width-gated
// remeasure hook, and the TK2 opt-in are the one component's).

// MARK: - Fan badges (overlay views, not text attributes)

/// The read tier's badge overlay — same doctrine as the editor's
/// BadgeOverlayController (buttons in the text view's coordinate space; the
/// Phase 6 memo keeps decorations off the text storage).
@MainActor
final class ReadBadgeOverlay {
    private weak var textView: ReadPostTextView?
    private let onTap: (String) -> Void
    private var buttons: [String: NSButton] = [:]

    init(textView: ReadPostTextView, onTap: @escaping (String) -> Void) {
        self.textView = textView
        self.onTap = onTap
    }

    func uninstall() {
        for button in buttons.values { button.removeFromSuperview() }
        buttons.removeAll()
    }

    func render(_ badges: [ReadPostViewModel.ReadBadge]) {
        guard let textView else { return }
        var seen = Set<String>()
        for badge in badges {
            seen.insert(badge.blockID)
            let button = buttons[badge.blockID] ?? makeButton(blockID: badge.blockID)
            button.title = "⑂\(badge.variantCount)"
            button.sizeToFit()
            let size = button.frame.size
            // The prose column's edge is the surface's ONE derivation
            // (`proseRight` — 17p batch b ladder round 1, R1-3; the editor's
            // twin says why the inset arithmetic is the symmetric mean, not
            // the edge, once the decoration lane makes the insets asymmetric).
            let columnRight = textView.proseRight
            button.frame = NSRect(
                x: min(textView.bounds.width - size.width - 8, columnRight + 6),
                y: badge.frame.minY,
                width: size.width, height: size.height)
            if button.superview == nil { textView.addSubview(button) }
        }
        for (blockID, button) in buttons where !seen.contains(blockID) {
            button.removeFromSuperview()
            buttons.removeValue(forKey: blockID)
        }
    }

    private func makeButton(blockID: String) -> NSButton {
        let button = NSButton(title: "⑂", target: nil, action: nil)
        button.bezelStyle = .badge
        button.controlSize = .small
        button.target = self
        button.action = #selector(badgeClicked(_:))
        button.identifier = NSUserInterfaceItemIdentifier(blockID)
        buttons[blockID] = button
        return button
    }

    @objc private func badgeClicked(_ sender: NSButton) {
        guard let blockID = sender.identifier?.rawValue else { return }
        onTap(blockID)
    }
}
