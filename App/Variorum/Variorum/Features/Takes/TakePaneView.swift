//
//  TakePaneView.swift
//  Variorum
//
//  Phase 11, Step A3 — one take's pane: the cell every composition is
//  built from. EVERY pane everywhere is an editing surface (the spike
//  record's letter) — but only the ONE focused pane is LIVE (P3: the live
//  editor migrates on click); everything else is a read-cheap, selectable
//  TK2 surface (the read-tier doctrine at take scale, same rendering
//  brain). Edits land in exactly this pane's variant (visible-not-chosen
//  is real and editable).
//

import AppKit
import SwiftUI
import VariorumCore

struct TakePaneView: View {
    let text: String
    let isLive: Bool
    /// A plain click on a read pane — the container migrates the live
    /// editor here.
    var onFocusRequest: (() -> Void)?
    /// A live pane's edit: the full new text (the model computes cost and
    /// routes autosave).
    var onEdit: ((String) -> Void)?
    @State private var height: CGFloat = 24

    var body: some View {
        TakePaneSurface(
            text: text, isLive: isLive, height: $height,
            onFocusRequest: onFocusRequest, onEdit: onEdit)
            .frame(minHeight: height)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(isLive ? Color.accentColor : Color.gray.opacity(0.25),
                            lineWidth: isLive ? 1.5 : 0.5))
    }
}

private struct TakePaneSurface: NSViewRepresentable {
    let text: String
    let isLive: Bool
    @Binding var height: CGFloat
    var onFocusRequest: (() -> Void)?
    var onEdit: ((String) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> TakeTextView {
        let view = TakeTextView.makeTakeSurface()
        view.delegate = context.coordinator
        context.coordinator.install(view: view) { height = max($0, 24) }
        context.coordinator.onEdit = onEdit
        view.onPlainClick = { [weak coordinator = context.coordinator] in
            coordinator?.onFocusRequest?()
        }
        context.coordinator.onFocusRequest = onFocusRequest
        view.string = text
        view.isEditable = isLive
        context.coordinator.remeasure()
        return view
    }

    func updateNSView(_ view: TakeTextView, context: Context) {
        context.coordinator.onEdit = onEdit
        context.coordinator.onFocusRequest = onFocusRequest
        view.isEditable = isLive
        // The buffer is authoritative while live: a projection may lag the
        // keystroke; never clobber the surface under the caret. Read panes
        // adopt any change.
        if !isLive, view.string != text {
            view.string = text
            context.coordinator.remeasure()
        }
    }

    static func dismantleNSView(_ view: TakeTextView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var onEdit: ((String) -> Void)?
        var onFocusRequest: (() -> Void)?
        private weak var view: TakeTextView?
        private var publishHeight: ((CGFloat) -> Void)?
        private let canary = FallbackCanary()
        private var canaryMessage: String?

        func install(view: TakeTextView, publishHeight: @escaping (CGFloat) -> Void) {
            self.view = view
            self.publishHeight = publishHeight
            canary.onFire = { [weak self] message in self?.canaryMessage = message }
            canary.arm(for: view)
        }

        func uninstall() {
            canary.disarm()
            publishHeight = nil
            view = nil
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            onEdit?(view.string)
            remeasure()
        }

        func remeasure() {
            guard let view, let layoutManager = view.textLayoutManager else { return }
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            let height = layoutManager.usageBoundsForTextContainer.height
                + view.textContainerInset.height * 2
            publishHeight?(max(height, 24))
        }
    }
}

final class TakeTextView: NSTextView {
    var onPlainClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard selectedRange().length == 0 else { return }
        onPlainClick?()
    }

    /// Explicit TK2 opt-in; content-sized inside the board's scroll; the
    /// same rendering brain as every surface (base font + the uniform
    /// presentation-only paragraph gap).
    static func makeTakeSurface() -> TakeTextView {
        let view = TakeTextView(usingTextLayoutManager: true)
        precondition(view.textLayoutManager != nil, "TK2 opt-in failed at construction")
        view.isEditable = false
        view.isSelectable = true
        view.isRichText = false
        view.textContainerInset = NSSize(width: 6, height: 6)
        view.isVerticallyResizable = false
        view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.textContainer?.widthTracksTextView = true
        view.font = EditorDocument.baseFont
        view.defaultParagraphStyle = EditorDocument.baseParagraphStyle
        view.typingAttributes = EditorDocument.baseAttributes
        view.allowsUndo = true
        return view
    }
}
