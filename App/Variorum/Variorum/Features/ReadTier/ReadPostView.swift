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
    @State private var model: ReadPostViewModel

    init(
        session: AppSession,
        postID: String,
        onFocusRequest: ((Int) -> Void)? = nil,
        onBadgeTap: ((String) -> Void)? = nil
    ) {
        self.session = session
        self.postID = postID
        self.onFocusRequest = onFocusRequest
        self.onBadgeTap = onBadgeTap
        _model = State(initialValue: ReadPostViewModel(session: session, postID: postID))
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
            ReadPostSurface(model: model, onFocusRequest: onFocusRequest, onBadgeTap: onBadgeTap)
                .frame(height: model.contentHeight)
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
    let onFocusRequest: ((Int) -> Void)?
    let onBadgeTap: ((String) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> ReadPostTextView {
        let textView = ReadPostTextView.makeReadSurface()
        model.attach(textView: textView)
        context.coordinator.install(textView: textView)
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onBadgeTap = onBadgeTap
        textView.onPlainClick = { [weak coordinator = context.coordinator] offset in
            coordinator?.onFocusRequest?(offset)
        }
        return textView
    }

    func updateNSView(_ nsView: ReadPostTextView, context: Context) {
        // Projection-driven; only the callbacks refresh here.
        context.coordinator.onFocusRequest = onFocusRequest
        context.coordinator.onBadgeTap = onBadgeTap
    }

    /// Deliberate recycling (the Step 0 memo's obligation — leaked text
    /// views are the classic NSViewRepresentable rot): the canary disarms,
    /// the sinks clear, the overlay drops its buttons.
    static func dismantleNSView(_ nsView: ReadPostTextView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator {
        let model: ReadPostViewModel
        var onFocusRequest: ((Int) -> Void)?
        var onBadgeTap: ((String) -> Void)?
        private var badges: ReadBadgeOverlay?
        private var frameToken: NSObjectProtocol?
        private var observation: Task<Void, Never>?

        init(model: ReadPostViewModel) {
            self.model = model
        }

        func install(textView: ReadPostTextView) {
            // The live projection, for exactly the surface's lifetime.
            observation = Task { [model] in await model.start() }
            let overlay = ReadBadgeOverlay(textView: textView) { [weak self] blockID in
                self?.onBadgeTap?(blockID)
            }
            badges = overlay
            model.badgeSink = { [weak overlay] badges in overlay?.render(badges) }
            // Width reflows change wrapping, so height must re-measure.
            textView.postsFrameChangedNotifications = true
            frameToken = NotificationCenter.default.addObserver(
                forName: NSView.frameDidChangeNotification, object: textView, queue: .main
            ) { [weak model] _ in
                MainActor.assumeIsolated { model?.viewWidthChanged() }
            }
        }

        func uninstall() {
            observation?.cancel()
            observation = nil
            if let frameToken { NotificationCenter.default.removeObserver(frameToken) }
            frameToken = nil
            badges?.uninstall()
            badges = nil
            model.detach()
        }
    }
}

// MARK: - The text view

final class ReadPostTextView: NSTextView {
    /// A click that created no selection — the click-to-focus gesture
    /// (drag-selections stay selections; the ratified read-tier contract
    /// keeps both).
    var onPlainClick: ((Int) -> Void)?

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)  // the selection tracking loop runs first
        guard selectedRange().length == 0 else { return }
        let point = convert(event.locationInWindow, from: nil)
        onPlainClick?(characterIndexForInsertion(at: point))
    }

    /// The spike-proven read surface: explicit TK2 opt-in, non-editable,
    /// selectable, sized by the container (no enclosing scroll view of its
    /// own — it lives inside the multi-post scroll).
    static func makeReadSurface() -> ReadPostTextView {
        let textView = ReadPostTextView(usingTextLayoutManager: true)
        precondition(textView.textLayoutManager != nil, "TK2 opt-in failed at construction")
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isVerticallyResizable = false
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.font = EditorDocument.baseFont
        return textView
    }
}

// MARK: - Fan badges (overlay views, not text attributes)

/// The read tier's badge overlay — same doctrine as the editor's
/// BadgeOverlayController (buttons in the text view's coordinate space; the
/// Phase 6 memo keeps decorations off the text storage).
@MainActor
final class ReadBadgeOverlay {
    private weak var textView: NSTextView?
    private let onTap: (String) -> Void
    private var buttons: [String: NSButton] = [:]

    init(textView: NSTextView, onTap: @escaping (String) -> Void) {
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
            button.frame = NSRect(
                x: textView.bounds.width - size.width - 12,
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
