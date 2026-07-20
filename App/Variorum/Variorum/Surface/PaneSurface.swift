//
//  PaneSurface.swift
//  Variorum
//
//  Phase 13b, Stage 1a (P-3): the ONE pane surface — a TK2 text view with
//  read + live MODES, one measurement brain, and a RENDERED canary —
//  composed by every take pane (all four fan styles), the read tier's
//  view core, the takes article cell, the TOC's expanded rows, and the
//  Write takes panel. Replaces `TakePaneView`/`TakeTextView` and
//  `ReadPostTextView` (three private copies of the height brain and a
//  canary that wrote into a variable nothing rendered — N2).
//
//  The app deliberately keeps TWO surface kinds (the Stage 1a architect
//  precision): the FULL-DOCUMENT editor (`EditorTextView` + its identity
//  machinery) is the other kind and is NOT this component — both consult
//  the one authority (`PaneTextAuthority`) and the one per-post autosave.
//
//  Measurement discipline (the batch-12 clipped-take class, closed for
//  every composer): a pane measures through `PaneMeasurement` and
//  re-measures on the WIDTH-GATED layout hook — a zero-width install
//  cannot pin a pane at one line, whichever surface composes it.
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The ONE measurement brain

@MainActor
enum PaneMeasurement {
    /// Content height of a TK2 surface at its current width: full-document
    /// layout (pane-scale by construction — a pane is one take / one post's
    /// read view) + the container inset. Every pane height in the app comes
    /// from here; a divergent private copy is the batch-12 bug class.
    static func height(of view: NSTextView) -> CGFloat {
        guard let layoutManager = view.textLayoutManager else { return 0 }
        layoutManager.ensureLayout(for: layoutManager.documentRange)
        return layoutManager.usageBoundsForTextContainer.height
            + view.textContainerInset.height * 2
    }
}

// MARK: - The text view

final class PaneTextView: NSTextView {
    /// A click that created no selection — the click-to-focus gesture, with
    /// the clicked UTF-16 offset (the read tier seeds the editor's caret
    /// from it; take panes ignore the value).
    var onPlainClick: ((Int) -> Void)?
    /// Fires when layout gives the view a NEW width (batch 12 — the
    /// clipped-take fix's trigger; width-gated so height publishes can't
    /// loop through it).
    var onWidthChange: (() -> Void)?
    private var lastLaidOutWidth: CGFloat = -1
    /// Test seam (the N2 pin): the last canary message the surface
    /// PUBLISHED for rendering — proves the fire→render wiring without
    /// walking SwiftUI internals. Written only by the surface coordinator.
    private(set) var lastPublishedCanary: String?

    func notePublishedCanary(_ message: String) {
        lastPublishedCanary = message
    }

    override func layout() {
        super.layout()
        if bounds.width != lastLaidOutWidth {
            lastLaidOutWidth = bounds.width
            onWidthChange?()
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)  // the selection tracking loop runs first
        guard selectedRange().length == 0 else { return }
        let point = convert(event.locationInWindow, from: nil)
        onPlainClick?(characterIndexForInsertion(at: point))
    }

    /// The one factory: explicit TK2 opt-in (TEXTKIT2 §4.1), content-sized
    /// inside its container's scroll, the shared rendering brain (base font
    /// + the uniform presentation-only paragraph gap).
    static func makeSurface(inset: CGFloat, allowsUndo: Bool) -> PaneTextView {
        let view = PaneTextView(usingTextLayoutManager: true)
        precondition(view.textLayoutManager != nil, "TK2 opt-in failed at construction")
        view.isEditable = false
        view.isSelectable = true
        view.isRichText = false
        view.textContainerInset = NSSize(width: inset, height: inset)
        view.isVerticallyResizable = false
        view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.textContainer?.widthTracksTextView = true
        view.font = EditorDocument.baseFont
        view.defaultParagraphStyle = EditorDocument.baseParagraphStyle
        view.typingAttributes = EditorDocument.baseAttributes
        view.allowsUndo = allowsUndo
        return view
    }
}

/// The read tier's historical name — its view core IS the pane surface now
/// (P-3). Kept as an alias so the read tier and its pins name their surface
/// meaningfully.
typealias ReadPostTextView = PaneTextView

extension PaneTextView {
    /// The read tier's configuration (non-editable always; the container
    /// sizes it; selection + plain-click per the ratified read contract).
    static func makeReadSurface() -> PaneTextView {
        makeSurface(inset: 8, allowsUndo: false)
    }

    /// A take pane's configuration (live/read toggled by the composer).
    static func makeTakeSurface() -> PaneTextView {
        makeSurface(inset: 6, allowsUndo: true)
    }
}

// MARK: - The SwiftUI pane (read + live modes)

/// One pane: a take's cell, a TOC row's body, a tutorial sample — EVERY
/// pane everywhere is an editing surface, but only the ONE focused pane is
/// LIVE (P3: the live editor migrates); everything else is a read-cheap,
/// selectable TK2 surface. Edits land in exactly this pane's variant.
/// The canary is RENDERED (N2): a TK1 fallback shows a banner right here,
/// in whatever composition the pane sits.
struct PaneSurfaceView: View {
    let text: String
    let isLive: Bool
    /// nil = the pre-13 look (BlockTOC/tutorial call sites); set =
    /// voice-token styling — a TRANSPARENT surface (the wrapping card or
    /// article provides the paper), ink from the voice, the LIVE ring in
    /// tokens.ring (R22: among many editable surfaces, the ring is how you
    /// find the one live editor).
    var tokens: VoiceTokens? = nil
    /// Surface identity for tests/soaks: the pane's role in its
    /// composition ("article", "card", "mini", …) and the variant it
    /// mirrors — carried on the NSView identifier, rendered nowhere.
    var role: String = "pane"
    var variantID: String? = nil
    /// A plain click on a read pane — the container migrates the live
    /// editor here.
    var onFocusRequest: (() -> Void)?
    /// A live pane's edit: the full new text (the model computes cost and
    /// routes autosave).
    var onEdit: ((String) -> Void)?
    @State private var height: CGFloat = 24
    @State private var canaryMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let canaryMessage {
                // N2: the fallback SPEAKS wherever a pane renders — the
                // memo posture's visible in-app diagnostic, previously
                // swallowed by a variable nothing read.
                Text(canaryMessage)
                    .foregroundStyle(.white)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .textSelection(.enabled)
            }
            PaneSurfaceRepresentable(
                text: text, isLive: isLive, height: $height, canaryMessage: $canaryMessage,
                ink: tokens.map { NSColor($0.ink) },
                role: role, variantID: variantID,
                onFocusRequest: onFocusRequest, onEdit: onEdit)
                .frame(minHeight: height)
                .overlay(
                    RoundedRectangle(cornerRadius: tokens == nil ? 3 : 6)
                        .stroke(strokeColor, lineWidth: isLive ? 1.5 : 0.5))
        }
    }

    private var strokeColor: Color {
        if let tokens { return isLive ? tokens.ring : .clear }
        return isLive ? Color.accentColor : Color.gray.opacity(0.25)
    }
}

private struct PaneSurfaceRepresentable: NSViewRepresentable {
    let text: String
    let isLive: Bool
    @Binding var height: CGFloat
    @Binding var canaryMessage: String?
    /// Voice styling: non-nil ⇒ transparent background (the card/article
    /// behind provides the paper) + this ink.
    var ink: NSColor?
    var role: String
    var variantID: String?
    var onFocusRequest: (() -> Void)?
    var onEdit: ((String) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> PaneTextView {
        let view = PaneTextView.makeTakeSurface()
        view.delegate = context.coordinator
        context.coordinator.install(
            view: view,
            publishHeight: { height = max($0, 24) },
            publishCanary: { canaryMessage = $0 })
        context.coordinator.onEdit = onEdit
        view.onPlainClick = { [weak coordinator = context.coordinator] _ in
            coordinator?.onFocusRequest?()
        }
        context.coordinator.onFocusRequest = onFocusRequest
        applyStyle(to: view)
        applyIdentity(to: view)
        view.string = text
        view.isEditable = isLive
        context.coordinator.remeasure()
        return view
    }

    func updateNSView(_ view: PaneTextView, context: Context) {
        context.coordinator.onEdit = onEdit
        context.coordinator.onFocusRequest = onFocusRequest
        view.isEditable = isLive
        applyStyle(to: view)
        applyIdentity(to: view)
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
        // adopt any change. (The view-level half of PaneTextAuthority's
        // isLive contract.)
        if !isLive, view.string != text {
            view.string = text
            context.coordinator.remeasure()
        }
    }

    private func applyStyle(to view: PaneTextView) {
        if let ink {
            view.drawsBackground = false
            view.textColor = ink
            view.insertionPointColor = ink
        } else {
            view.drawsBackground = true
        }
    }

    private func applyIdentity(to view: PaneTextView) {
        view.identifier = NSUserInterfaceItemIdentifier(
            "pane:\(role)|\(variantID ?? "-")")
    }

    static func dismantleNSView(_ view: PaneTextView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var onEdit: ((String) -> Void)?
        var onFocusRequest: (() -> Void)?
        private weak var view: PaneTextView?
        private var publishHeight: ((CGFloat) -> Void)?
        private var publishCanary: ((String) -> Void)?
        private let canary = FallbackCanary()

        func install(
            view: PaneTextView,
            publishHeight: @escaping (CGFloat) -> Void,
            publishCanary: @escaping (String) -> Void
        ) {
            self.view = view
            self.publishHeight = publishHeight
            self.publishCanary = publishCanary
            // Batch 12 (her clipped-take report): the pane measures once at
            // install, BEFORE SwiftUI hands it real width — the width-gated
            // layout hook re-measures when real layout arrives.
            view.onWidthChange = { [weak self] in self?.remeasure() }
            // N2: the canary message is PUBLISHED into the rendered banner
            // (it used to land in a private var nothing read).
            canary.onFire = { [weak self] message in
                self?.view?.notePublishedCanary(message)
                self?.publishCanary?(message)
            }
            canary.arm(for: view)
        }

        func uninstall() {
            canary.disarm()
            publishHeight = nil
            publishCanary = nil
            view = nil
        }

        func textDidChange(_ notification: Notification) {
            guard let view else { return }
            onEdit?(view.string)
            remeasure()
        }

        func remeasure() {
            guard let view else { return }
            publishHeight?(max(PaneMeasurement.height(of: view), 24))
        }
    }
}
