//
//  SpikeBench.swift
//  VariorumMobile — Stage 0 TK2-on-iOS spike (THROWAWAY; deleted at stage close)
//
//  The bench: a full-screen UIKit controller hosting (a) the interactive
//  text view — TK2-explicit, fanned block, pan-peek, edit-menu items,
//  storage-edit observer — for XCUITest-driven and hand-driven evidence,
//  and (b) a scenario container the in-process measurement scenarios mount
//  fresh cold views into. A status label (accessibilityIdentifier
//  "spike.status") publishes peek/menu/edit state for UI tests.
//
//  Canary posture (iOS asymmetry, confirmed by Apple-docs lookup 2026-08-03):
//  UIKit has NO analog of AppKit's willSwitchToNSLayoutManager notification.
//  The only public signal is `textLayoutManager` going nil (TK1 compatibility
//  mode). So the iOS canary is a CHECKPOINT canary: `canaryCheck(after:)`
//  after every exercised action, plus a CADisplayLink poll while idle.
//

#if DEBUG

import UIKit

// MARK: - Canary

/// Poll/checkpoint canary: records the first action after which
/// `textLayoutManager` reads nil. Weaker than the Mac's notification pair
/// by necessity — the memo records this asymmetry as a finding.
final class SpikeCanary {
    private(set) var fallbackDetectedAfter: String?
    var alive: Bool { fallbackDetectedAfter == nil }

    /// Returns true while TK2 is alive.
    @discardableResult
    func check(_ tv: UITextView, after action: String) -> Bool {
        if tv.textLayoutManager == nil {
            if fallbackDetectedAfter == nil {
                fallbackDetectedAfter = action
                SpikeRecorder.shared.record("CANARY|TK1-FALLBACK after: \(action)")
            }
            return false
        }
        return true
    }
}

// MARK: - Bench

final class SpikeBenchViewController: UIViewController, UITextViewDelegate,
    UIGestureRecognizerDelegate, NSTextStorageDelegate
{
    // Interactive surface
    private(set) var textView: UITextView!
    let canary = SpikeCanary()
    private var corpus = SpikeCorpus.makeInteractive()

    // The "fanned" block and its takes (peek is DISPLAY-ONLY; storage never written)
    let fannedBlockIndex = 2
    let takes = [
        "(take 0 — the stored text)",
        "Take 1 — a different opening for this paragraph, swapped in as a pure display overlay with zero storage writes.",
        "Take 2 — the third candidate; shorter, punchier.",
    ]
    private(set) var peekIndex = 0
    private var peekOverlay: UIView?
    private var storageFingerprintAtPeekStart: Int?

    // Gesture
    private(set) var pan: UIPanGestureRecognizer!
    private var panStartedInFannedBlock = false

    // Status for XCUITest
    private let statusLabel = UILabel()
    private(set) var lastEditMenuAction: String = "none"
    private(set) var editMenuDelegateCallCount = 0
    private(set) var storageEdits: [String] = []

    // Scenario container (in-process scenarios mount fresh views here)
    private(set) var scenarioContainer = UIView()

    // Keyboard observation
    private(set) var lastKeyboardFrame: CGRect = .null
    private(set) var keyboardEvents: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // --- TK2-explicit construction (iOS 16+ initializer) ---
        let tv = UITextView(usingTextLayoutManager: true)
        precondition(tv.textLayoutManager != nil, "TK2 opt-in must yield a textLayoutManager")
        textView = tv
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        tv.isEditable = true
        tv.autocorrectionType = .yes
        tv.spellCheckingType = .yes
        tv.accessibilityIdentifier = "spike.textView"
        tv.delegate = self
        tv.textStorage.delegate = self
        tv.attributedText = corpus.text

        // Accessory bar (item 6's home)
        tv.inputAccessoryView = Self.makeAccessoryBar()

        // The M5 pan (item 4): horizontal, scoped to the fanned block's rects
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.pan = pan
        tv.addGestureRecognizer(pan)

        // Status
        statusLabel.numberOfLines = 0
        statusLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        statusLabel.accessibilityIdentifier = "spike.status"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.backgroundColor = .secondarySystemBackground

        scenarioContainer.translatesAutoresizingMaskIntoConstraints = false
        scenarioContainer.isHidden = true

        view.addSubview(tv)
        view.addSubview(scenarioContainer)
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

            tv.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            tv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            scenarioContainer.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            scenarioContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scenarioContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scenarioContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let nc = NotificationCenter.default
        nc.addObserver(
            self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(
            self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        nc.addObserver(
            self, selector: #selector(keyboardChanged(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        refreshStatus()
    }

    static func makeAccessoryBar() -> UIView {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.items = [
            UIBarButtonItem(title: "B", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "I", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "•", style: .plain, target: nil, action: nil),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "✓", style: .plain, target: nil, action: nil),
        ]
        bar.accessibilityIdentifier = "spike.accessoryBar"
        return bar
    }

    // MARK: Status

    func refreshStatus() {
        let offset = textView.map { String(format: "%.0f", $0.contentOffset.y) } ?? "-"
        statusLabel.text =
            "peek=\(peekIndex) menu=\(lastEditMenuAction) menuCalls=\(editMenuDelegateCallCount) "
            + "offset=\(offset) edits=\(storageEdits.count) tk2=\(canary.alive ? 1 : 0) "
            + "kbd=\(keyboardEvents.last ?? "none")"
    }

    // MARK: Fragment rects for a block (container coords -> view coords)

    func fragmentRects(for blockIndex: Int, in tv: UITextView) -> [CGRect] {
        guard let tlm = tv.textLayoutManager, let cm = tlm.textContentManager,
            blockIndex < corpus.blockRanges.count
        else { return [] }
        let charRange = corpus.blockRanges[blockIndex]
        guard
            let start = cm.location(tlm.documentRange.location, offsetBy: charRange.location),
            let end = cm.location(
                tlm.documentRange.location, offsetBy: charRange.location + charRange.length)
        else { return [] }
        var rects: [CGRect] = []
        tlm.enumerateTextLayoutFragments(from: start, options: [.ensuresLayout]) { frag in
            if frag.rangeInElement.location.compare(end) != .orderedAscending { return false }
            rects.append(frag.layoutFragmentFrame)
            return true
        }
        let inset = tv.textContainerInset
        return rects.map { $0.offsetBy(dx: inset.left, dy: inset.top) }
    }

    // MARK: The M5 pan + peek (item 4)

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === pan else { return true }
        let location = pan.location(in: textView)
        let translation = pan.translation(in: textView)
        // Horizontal dominance — vertical drags stay the scroll view's.
        guard abs(translation.x) > abs(translation.y) * 1.5, abs(translation.x) > 4 else {
            return false
        }
        // Scoped to the fanned block's fragment rects.
        let rects = fragmentRects(for: fannedBlockIndex, in: textView)
        panStartedInFannedBlock = rects.contains { $0.insetBy(dx: -4, dy: -4).contains(location) }
        return panStartedInFannedBlock
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        // Never simultaneous with the scroll pan — once the horizontal pan
        // begins it owns the touch; vertical drags never reach here (the
        // shouldBegin dominance gate returns false first).
        false
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            storageFingerprintAtPeekStart = SpikeAttributeAudit.fingerprint(textView.textStorage)
        case .ended:
            let tx = gesture.translation(in: textView).x
            if abs(tx) > 30 {
                let delta = tx < 0 ? 1 : -1
                let next = (peekIndex + delta + takes.count) % takes.count
                setPeek(index: next)
            }
        default:
            break
        }
    }

    /// Display-swap the fanned block's text: an opaque overlay positioned on
    /// the block's fragment rects. ZERO storage writes — proven by
    /// fingerprint equality, recorded each flip.
    func setPeek(index: Int) {
        peekIndex = index
        peekOverlay?.removeFromSuperview()
        peekOverlay = nil
        if index != 0 {
            let rects = fragmentRects(for: fannedBlockIndex, in: textView)
            guard !rects.isEmpty else { return }
            let union = rects.dropFirst().reduce(rects[0]) { $0.union($1) }
            let overlay = UIView(frame: union)
            overlay.backgroundColor = textView.backgroundColor ?? .systemBackground
            let label = UILabel(frame: overlay.bounds.insetBy(dx: 2, dy: 0))
            label.numberOfLines = 0
            label.font = textView.font
            label.textColor = .systemIndigo
            label.text = takes[index]
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.addSubview(label)
            overlay.accessibilityIdentifier = "spike.peekOverlay"
            overlay.isUserInteractionEnabled = false
            textView.addSubview(overlay)  // scroll-content coordinates
            peekOverlay = overlay
        }
        if let before = storageFingerprintAtPeekStart {
            let after = SpikeAttributeAudit.fingerprint(textView.textStorage)
            SpikeRecorder.shared.record(
                "4.peek|index=\(index)|storageUntouched=\(before == after ? "YES" : "NO")")
        }
        canary.check(textView, after: "peek overlay flip")
        refreshStatus()
    }

    // MARK: Edit menu (item 5 — the M2 door's mechanism)

    func textView(
        _ textView: UITextView, editMenuForTextIn range: NSRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        editMenuDelegateCallCount += 1
        let blockID =
            range.location < textView.textStorage.length
            ? (textView.textStorage.attribute(
                SpikeCorpus.blockIDKey, at: range.location, effectiveRange: nil) as? NSNumber)
            : nil
        let takesAction = UIAction(title: "Block Takes") { [weak self] _ in
            self?.lastEditMenuAction = "takes(block \(blockID?.intValue ?? -1))"
            self?.refreshStatus()
        }
        let divideAction = UIAction(title: "Divide Here") { [weak self] _ in
            self?.lastEditMenuAction = "divide(block \(blockID?.intValue ?? -1))"
            self?.refreshStatus()
        }
        SpikeRecorder.shared.record(
            "5.editmenu|delegateCalled|range=\(range)|block=\(blockID?.intValue ?? -1)|suggested=\(suggestedActions.count)"
        )
        refreshStatus()
        return UIMenu(children: suggestedActions + [takesAction, divideAction])
    }

    // MARK: Storage-edit observation (item 3 — autocorrect evidence)

    nonisolated func textStorage(
        _ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange, changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        let text = textStorage.attributedSubstring(from: editedRange).string
        let runs = SpikeAttributeAudit.runs(in: textStorage, range: editedRange)
        let entry =
            "edit@\(editedRange.location)+\(editedRange.length)Δ\(delta)"
            + "|text=\(text.prefix(24).replacingOccurrences(of: "\n", with: "⏎"))"
            + "|runs=\(SpikeAttributeAudit.describe(runs))"
        MainActor.assumeIsolated {
            storageEdits.append(entry)
            SpikeRecorder.shared.record("3.storageEdit|\(entry)")
            refreshStatus()
        }
    }

    // MARK: Keyboard (item 6)

    @objc private func keyboardChanged(_ note: Notification) {
        let name = note.name.rawValue.replacingOccurrences(of: "UIKeyboard", with: "")
            .replacingOccurrences(of: "Notification", with: "")
        let frame =
            (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            ?? .null
        lastKeyboardFrame = frame
        let event = "\(name)@h=\(Int(frame.height))"
        keyboardEvents.append(event)
        SpikeRecorder.shared.record("6.keyboard|\(event)|frame=\(frame)")
        refreshStatus()
    }
}

#endif
