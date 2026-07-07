//
//  EditorView.swift
//  Variorum
//
//  The editor feature's SwiftUI face (Phase 7): TK2 surface + functional,
//  unstyled chrome (canary banner, seal banner, commit bar, fan panel).
//  Calm default: no fan machinery is visible on unfanned blocks — the badge
//  appears only where a fan exists (AppSpec §12), as an overlay, never a
//  rendering attribute (memo obligation: decorations stay off the live view).
//

import AppKit
import SwiftUI
import VariorumCore

struct EditorView: View {
    let session: AppSession
    let postID: String
    @State private var model: EditorViewModel

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: EditorViewModel(session: session, postID: postID))
    }

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            if let canary = model.canaryMessage {
                Text(canary)
                    .foregroundStyle(.white)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .textSelection(.enabled)
            }
            if model.header?.locked == true {
                Text("Sealed post — read-only")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)
            }
            EditorSurface(model: model)
            CommitBar(model: model)
        }
        .task { await model.start() }
        .onDisappear { model.teardown() }
        .sheet(item: $model.fanPanel) { panel in
            FanPanel(model: model, state: panel)
        }
        .sheet(item: $model.divideWCeremony) { state in
            // The W ceremony (Phase 9, contract item 3): one sheet; any
            // dismissal other than Confirm is a cancel — no rows touched.
            DivideWSheet(model: model, presented: state)
        }
        .alert(
            "This commit predates a split of this block",
            isPresented: Binding(
                get: { model.pendingRestore != nil },
                set: { if !$0 { model.pendingRestore = nil } }),
            presenting: model.pendingRestore
        ) { item in
            Button("Restore Anyway", role: .destructive) {
                model.restore(item, confirmed: true)
            }
            Button("Cancel", role: .cancel) { model.pendingRestore = nil }
        } message: { _ in
            Text("Restoring will resurrect the full pre-split text into this "
                + "block's buffer — the split-off half still exists next door.")
        }
    }
}

// MARK: - The TK2 surface

private struct EditorSurface: NSViewRepresentable {
    let model: EditorViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let (scrollView, textView) = EditorTextView.makeEditor()
        context.coordinator.surfaceDelegate.wire(to: textView)
        model.attach(textView: textView, scrollView: scrollView)
        context.coordinator.install(scrollView: scrollView, textView: textView)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // All updates flow through the model (projection-driven).
    }

    static func dismantleNSView(_ nsView: NSScrollView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject {
        let model: EditorViewModel
        let surfaceDelegate: EditorSurfaceDelegate
        private var badges: BadgeOverlayController?
        private var anchor: ScrollAnchorController?

        init(model: EditorViewModel) {
            self.model = model
            self.surfaceDelegate = EditorSurfaceDelegate(model: model)
        }

        func install(scrollView: NSScrollView, textView: EditorTextView) {
            badges = BadgeOverlayController(model: model, textView: textView)
            anchor = ScrollAnchorController(model: model, scrollView: scrollView)
        }

        func uninstall() {
            badges?.uninstall()
            anchor?.uninstall()
        }
    }
}

/// The delegate glue between AppKit's edit pipeline and the view model —
/// its own (internal) class so tests can drive the REAL NSTextView path
/// (shouldChange → storage edit → didProcessEditing) without SwiftUI.
@MainActor
final class EditorSurfaceDelegate: NSObject {
    let model: EditorViewModel

    init(model: EditorViewModel) {
        self.model = model
    }

    /// Wires both delegates the pipeline needs.
    func wire(to textView: EditorTextView) {
        textView.delegate = self
        textView.textStorage?.delegate = self
    }
}

extension EditorSurfaceDelegate: NSTextViewDelegate {
    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        model.shouldChangeText(in: affectedCharRange, replacement: replacementString)
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges affectedRanges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool {
        // Multi-range edits (find-and-replace-all, multi-caret) are out of
        // editor v1's scope: each range would need its own verdict and the
        // index shifts would interleave — refuse rather than guess.
        guard affectedRanges.count == 1 else {
            model.showStatus("Multi-range edits aren't supported yet.")
            return false
        }
        return model.shouldChangeText(
            in: affectedRanges[0].rangeValue,
            replacement: replacementStrings?.first)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        model.updateCaretContext()
    }
}

extension EditorSurfaceDelegate: NSTextStorageDelegate {
    nonisolated func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        MainActor.assumeIsolated {
            model.storageDidEdit(editedRange, changeInLength: delta)
        }
    }
}

// MARK: - Fan badges (overlay views, not text attributes)

/// Reconciles small AppKit badge buttons over the fanned blocks currently in
/// view. Buttons live in the text view's coordinate space, so no cross-
/// framework geometry mapping is needed. Functional, unstyled.
@MainActor
final class BadgeOverlayController {
    private let model: EditorViewModel
    private weak var textView: EditorTextView?
    private var buttons: [String: NSButton] = [:]

    init(model: EditorViewModel, textView: EditorTextView) {
        self.model = model
        self.textView = textView
        model.badgeSink = { [weak self] badges in self?.render(badges) }
    }

    func uninstall() {
        model.badgeSink = nil
        for button in buttons.values { button.removeFromSuperview() }
        buttons.removeAll()
    }

    private func render(_ badges: [EditorViewModel.BlockBadge]) {
        guard let textView else { return }
        var seen = Set<String>()
        for badge in badges {
            seen.insert(badge.blockID)
            let button = buttons[badge.blockID] ?? makeButton(blockID: badge.blockID)
            button.title = "⑂\(badge.variantCount)"
            button.sizeToFit()
            // Corner badge: top-right of the block's first fragment.
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
        model.openFan(blockID: blockID)
    }
}

// MARK: - Content-anchored scroll restore (the memo's resize obligation)

/// The spike measured the real position-loss hazard: NSScrollView keeps the
/// PIXEL offset across a width reflow while the geometry under it changes
/// (−79 paragraphs on a 900→600 resize). Restore by TEXT location via the
/// hybrid primitive: capture the top visible location while scrolling is
/// stable, restore it when the width changes (one-shot after live resize).
@MainActor
final class ScrollAnchorController {
    private let model: EditorViewModel
    private weak var scrollView: NSScrollView?
    private var tokens: [NSObjectProtocol] = []
    private var stableAnchor: Int?
    private var lastWidth: CGFloat = 0
    private var inLiveResize = false

    init(model: EditorViewModel, scrollView: NSScrollView) {
        self.model = model
        self.scrollView = scrollView
        lastWidth = scrollView.contentView.bounds.width
        let clip = scrollView.contentView
        clip.postsBoundsChangedNotifications = true
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification, object: clip, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.boundsChanged() }
        })
        // Only a Sendable window identity crosses into the isolated region
        // (Notification itself is not Sendable — Swift 6 mode).
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSWindow.willStartLiveResizeNotification, object: nil, queue: .main
        ) { [weak self] note in
            let windowID = (note.object as? NSWindow).map(ObjectIdentifier.init)
            MainActor.assumeIsolated { self?.liveResizeStarted(windowID: windowID) }
        })
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSWindow.didEndLiveResizeNotification, object: nil, queue: .main
        ) { [weak self] note in
            let windowID = (note.object as? NSWindow).map(ObjectIdentifier.init)
            MainActor.assumeIsolated { self?.liveResizeEnded(windowID: windowID) }
        })
    }

    func uninstall() {
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        tokens.removeAll()
    }

    private var window: NSWindow? { scrollView?.window }

    private func boundsChanged() {
        guard !inLiveResize, let scrollView else { return }
        let width = scrollView.contentView.bounds.width
        if width != lastWidth {
            // A width reflow outside live resize (split-view divider, etc.):
            // the pixel offset now points at different text — restore.
            lastWidth = width
            if let anchor = stableAnchor {
                model.restoreTopVisibleOffset(anchor)
            }
        } else {
            // Ordinary scrolling: keep the anchor current.
            stableAnchor = model.topVisibleOffset() ?? stableAnchor
        }
        model.refreshBadges()
    }

    private func liveResizeStarted(windowID: ObjectIdentifier?) {
        guard let window, windowID == ObjectIdentifier(window) else { return }
        stableAnchor = model.topVisibleOffset() ?? stableAnchor
        inLiveResize = true
    }

    private func liveResizeEnded(windowID: ObjectIdentifier?) {
        guard let window, windowID == ObjectIdentifier(window) else { return }
        inLiveResize = false
        lastWidth = scrollView?.contentView.bounds.width ?? lastWidth
        if let anchor = stableAnchor {
            model.restoreTopVisibleOffset(anchor)
        }
    }
}
