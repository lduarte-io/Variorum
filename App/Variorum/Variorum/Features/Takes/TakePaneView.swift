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
    /// Stage C2 (the v2-canon restyle): nil = the pre-13 look (the
    /// BlockTOC/tutorial call sites compile unchanged); set = voice-token
    /// styling — a TRANSPARENT surface (the wrapping card or article
    /// provides the paper), ink from the voice, and the LIVE ring in
    /// tokens.ring (R22's rule: among many editable surfaces, the ring is
    /// how you find the one live editor).
    var tokens: VoiceTokens? = nil
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
            ink: tokens.map { NSColor($0.ink) },
            onFocusRequest: onFocusRequest, onEdit: onEdit)
            .frame(minHeight: height)
            .overlay(
                RoundedRectangle(cornerRadius: tokens == nil ? 3 : 6)
                    .stroke(strokeColor, lineWidth: isLive ? 1.5 : 0.5))
    }

    private var strokeColor: Color {
        if let tokens { return isLive ? tokens.ring : .clear }
        return isLive ? Color.accentColor : Color.gray.opacity(0.25)
    }
}

private struct TakePaneSurface: NSViewRepresentable {
    let text: String
    let isLive: Bool
    @Binding var height: CGFloat
    /// Voice styling (Stage C2): non-nil ⇒ transparent background (the
    /// card/article behind provides the paper) + this ink.
    var ink: NSColor?
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
        applyStyle(to: view)
        view.string = text
        view.isEditable = isLive
        context.coordinator.remeasure()
        return view
    }

    func updateNSView(_ view: TakeTextView, context: Context) {
        context.coordinator.onEdit = onEdit
        context.coordinator.onFocusRequest = onFocusRequest
        view.isEditable = isLive
        applyStyle(to: view)
        // A voice switch changes the ONE global typography (C1's
        // EditorTypography); live-adopt it so open panes re-font without
        // reconstruction (an ordinary storage write, never §3 attributes).
        if view.font != EditorDocument.baseFont {
            view.font = EditorDocument.baseFont
            view.defaultParagraphStyle = EditorDocument.baseParagraphStyle
            view.typingAttributes = EditorDocument.baseAttributes
            if let storage = view.textStorage, storage.length > 0 {
                storage.beginEditing()
                storage.addAttributes(
                    EditorDocument.baseAttributes,
                    range: NSRange(location: 0, length: storage.length))
                storage.endEditing()
            }
            context.coordinator.remeasure()
        }
        // The buffer is authoritative while live: a projection may lag the
        // keystroke; never clobber the surface under the caret. Read panes
        // adopt any change.
        if !isLive, view.string != text {
            view.string = text
            context.coordinator.remeasure()
        }
    }

    private func applyStyle(to view: TakeTextView) {
        if let ink {
            view.drawsBackground = false
            view.textColor = ink
            view.insertionPointColor = ink
        } else {
            view.drawsBackground = true
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
            // Batch 12 (her clipped-take report): the pane measures once at
            // install, BEFORE SwiftUI hands it real width — a zero-width
            // container lays out almost nothing and reports ~one line, and
            // no later event re-measures a READ pane (the live pane
            // re-measures per keystroke, which is why only reads clipped).
            // The geometry hook re-measures whenever layout delivers a new
            // width, so the first real layout corrects the height.
            view.onWidthChange = { [weak self] in self?.remeasure() }
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
    /// Fires when layout gives the view a NEW width (batch 12 — the
    /// clipped-take fix's trigger; width-gated so height publishes can't
    /// loop through it).
    var onWidthChange: (() -> Void)?
    private var lastLaidOutWidth: CGFloat = -1

    override func layout() {
        super.layout()
        if bounds.width != lastLaidOutWidth {
            lastLaidOutWidth = bounds.width
            onWidthChange?()
        }
    }

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
