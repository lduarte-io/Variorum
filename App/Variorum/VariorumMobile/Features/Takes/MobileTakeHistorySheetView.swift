//
//  MobileTakeHistorySheetView.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C4a — the take-history sheet's PIXELS:
//  the comments sheet's ratified sheet-over-page pattern (LK4's geometry,
//  harness-drivable), applied to one take's append-only savepoints. Rows
//  are read-cheap (date · kind · pre-split flag · preview) with a
//  per-row Restore door; the PRE-SPLIT confirm rides the controller's
//  `pendingRestore` gate and presents as a system alert. Every
//  color/font resolves from `MobileEditorStyle.face` (P-8).
//

import UIKit
import VariorumCore

@MainActor
final class MobileTakeHistorySheetView: UIView, UIScrollViewDelegate {
    private weak var pageTextView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// The comments sheet's constant family (PROVISIONAL visual
    /// constants; the look rounds rule).
    static let sheetTop: CGFloat = 160
    /// The rows' fixed pitch (row height 64 + gap 10) — what makes the
    /// D2 lazy materialization arithmetic-exact: content size and row
    /// origins derive from the index, never from measuring every row.
    static let rowHeight: CGFloat = 64
    static let rowPitch: CGFloat = 74

    private let dimView = UIView()
    private let sheetView = UIView()
    private let headerLabel = UILabel()
    private let doneButton = UIButton(type: .custom)
    private let rowsScroll = UIScrollView()
    private let emptyLabel = UILabel()

    private var pageWasEditable = true
    /// The MATERIALIZED rows only (parity D2 — the routed C4 NIT: every
    /// savepoint used to materialize as a UIView on every render,
    /// unwindowed and without reuse, so a years-deep take paid its
    /// whole history per delivery ingest. Rows now materialize LAZILY —
    /// the near-viewport band only, the block-TOC's own discipline in
    /// this sheet's manual-frame terms), keyed by item index.
    private(set) var rowViewsByIndex: [Int: UIView] = [:]
    /// ARBITRARY dictionary order (D ladder NIT R1-4) — the pre-D2 array
    /// was top-to-bottom; consumers must not assume visual order here
    /// (today's are order-agnostic; index into `rowViewsByIndex` for
    /// position-aware reads).
    var rowViews: [UIView] { Array(rowViewsByIndex.values) }
    /// The scroll surface, exposed for the lazy pin (harness-drivable —
    /// the comments-sheet pattern's own discipline).
    var rowsScrollForTesting: UIScrollView { rowsScroll }
    /// The materialized band (equality gate — a scroll tick that stays
    /// inside the band rebuilds nothing).
    private var materializedBand: Range<Int> = 0..<0
    /// The pre-split confirm currently presented (one presentation per
    /// gate — render() re-runs freely and must not stack alerts).
    private var presentedRestoreID: String?

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.pageTextView = textView
        self.model = model
        super.init(frame: .zero)
        isHidden = true
        accessibilityIdentifier = "history.sheet"

        dimView.accessibilityIdentifier = "history.dim"
        addSubview(dimView)

        sheetView.layer.cornerRadius = 22
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.accessibilityIdentifier = "history.sheetPane"
        addSubview(sheetView)

        headerLabel.accessibilityIdentifier = "history.header"
        sheetView.addSubview(headerLabel)

        doneButton.accessibilityIdentifier = "history.done"
        doneButton.accessibilityLabel = "Done"
        doneButton.addAction(
            UIAction { [weak self] _ in self?.model?.takeHistory.close() },
            for: .touchUpInside)
        sheetView.addSubview(doneButton)

        rowsScroll.delegate = self // the lazy band follows her scrolling
        sheetView.addSubview(rowsScroll)

        emptyLabel.accessibilityIdentifier = "history.empty"
        emptyLabel.numberOfLines = 0
        rowsScroll.addSubview(emptyLabel)

        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    @objc private func dimTapped() {
        model?.takeHistory.close()
    }

    // MARK: - Render (the controller's onChanged hook)

    func render() {
        guard let model else { return }
        let history = model.takeHistory
        let wasHidden = isHidden
        let open = history.isOpen

        if open, superview == nil, let host = pageTextView?.superview {
            frame = host.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.addSubview(self)
        }
        isHidden = !open

        // The page editor stands down while the sheet is up (the
        // comments sheet's exact posture); restored at close.
        if let page = pageTextView {
            if open, wasHidden {
                pageWasEditable = page.isEditable
                page.isEditable = false
                _ = page.resignFirstResponder()
            } else if !open, !wasHidden {
                page.isEditable = pageWasEditable
            }
        }
        guard open else {
            for row in rowViewsByIndex.values { row.removeFromSuperview() }
            rowViewsByIndex = [:]
            materializedBand = 0..<0
            presentedRestoreID = nil
            return
        }

        layoutChrome()
        renderRows(history)
        presentPendingRestoreIfNeeded(history)
    }

    private func layoutChrome() {
        let face = MobileEditorStyle.face
        dimView.frame = bounds
        dimView.backgroundColor = face.ink.withAlphaComponent(0.25)
        sheetView.frame = CGRect(
            x: 0, y: Self.sheetTop,
            width: bounds.width, height: max(bounds.height - Self.sheetTop, 0))
        sheetView.backgroundColor = face.surface

        headerLabel.text = chromeCase("Take History")
        headerLabel.font = face.chrome.withSize(13)
        headerLabel.textColor = face.muted
        headerLabel.sizeToFit()
        headerLabel.frame.origin = CGPoint(x: 20, y: 14)

        doneButton.setTitle(chromeCase("Done"), for: .normal)
        doneButton.setTitleColor(face.accent, for: .normal)
        doneButton.titleLabel?.font = face.chrome.withSize(12.5)
        doneButton.sizeToFit()
        doneButton.frame = CGRect(
            x: sheetView.bounds.width - doneButton.bounds.width - 20, y: 10,
            width: doneButton.bounds.width, height: 24)

        rowsScroll.frame = CGRect(
            x: 16, y: 44,
            width: sheetView.bounds.width - 32,
            height: max(sheetView.bounds.height - 56, 0))
    }

    /// Content changed (open, verb, delivery ingest): size the scroll
    /// from the COUNT (fixed pitch — no row is measured) and rebuild
    /// the band from scratch. Cost ∝ the band, never the take's history
    /// (the D2 lazy shape).
    private func renderRows(_ history: MobileTakeHistoryController) {
        let face = MobileEditorStyle.face
        for row in rowViewsByIndex.values { row.removeFromSuperview() }
        rowViewsByIndex = [:]
        materializedBand = 0..<0

        let items = history.items
        emptyLabel.isHidden = !items.isEmpty
        if items.isEmpty {
            emptyLabel.text = chromeCase(
                "No savepoints yet — Commit Take in ⋯ keeps one.")
            emptyLabel.font = face.chrome.withSize(12)
            emptyLabel.textColor = face.muted
            let width = rowsScroll.bounds.width
            let size = emptyLabel.sizeThatFits(
                CGSize(width: width, height: .greatestFiniteMagnitude))
            emptyLabel.frame = CGRect(x: 0, y: 8, width: width, height: size.height)
            rowsScroll.contentSize = CGSize(width: width, height: size.height + 16)
            return
        }

        rowsScroll.contentSize = CGSize(
            width: rowsScroll.bounds.width,
            height: CGFloat(items.count) * Self.rowPitch)
        materializeBand(face: face)
    }

    /// The near-viewport band (one viewport of overscan each side),
    /// equality-gated: scrolling inside the band builds nothing;
    /// leaving it swaps the materialized set. Row origins derive from
    /// the index (fixed pitch), so any band lands pixel-identically to
    /// the old build-everything pass.
    private func materializeBand(face: MobileEditorStyle.Face? = nil) {
        guard let model, model.takeHistory.isOpen else { return }
        let items = model.takeHistory.items
        guard !items.isEmpty else { return }
        let viewport = max(rowsScroll.bounds.height, 0)
        let top = rowsScroll.contentOffset.y - viewport
        let bottom = rowsScroll.contentOffset.y + viewport * 2
        let first = max(0, Int(floor(top / Self.rowPitch)))
        let last = min(items.count, Int(ceil(bottom / Self.rowPitch)))
        let band = first..<max(first, last)
        guard band != materializedBand else { return }

        let face = face ?? MobileEditorStyle.face
        let width = rowsScroll.bounds.width
        for (index, row) in rowViewsByIndex where !band.contains(index) {
            row.removeFromSuperview()
            rowViewsByIndex[index] = nil
        }
        for index in band where rowViewsByIndex[index] == nil {
            let row = makeRow(item: items[index], face: face, width: width)
            row.frame.origin.y = CGFloat(index) * Self.rowPitch
            rowsScroll.addSubview(row)
            rowViewsByIndex[index] = row
        }
        materializedBand = band
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        materializeBand()
    }

    private func makeRow(
        item: MobileTakeHistoryController.HistoryItem,
        face: MobileEditorStyle.Face,
        width: CGFloat
    ) -> UIView {
        let row = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 64))
        row.accessibilityIdentifier = "history.row.\(item.commit.id)"
        row.layer.cornerRadius = 10
        row.layer.borderWidth = 1
        row.layer.borderColor = face.line.resolvedColor(with: traitCollection).cgColor
        row.backgroundColor = face.card

        let chrome = face.chrome.withSize(12)
        let meta = UILabel()
        var metaText = item.commit.createdAt.formatted(
            date: .abbreviated, time: .shortened)
        metaText += " · \(item.commit.kind == .auto ? "auto" : "manual")"
        if item.predatesSplit {
            metaText += " · \(Self.rowFlag)"
        }
        meta.text = chromeCase(metaText)
        meta.font = chrome
        meta.textColor = item.predatesSplit ? face.accent : face.muted
        meta.accessibilityIdentifier = "history.row.meta"
        row.addSubview(meta)
        meta.sizeToFit()
        meta.frame.origin = CGPoint(x: 12, y: 8)

        let restore = UIButton(type: .custom)
        restore.setTitle(chromeCase("Restore"), for: .normal)
        restore.setTitleColor(face.accent, for: .normal)
        restore.titleLabel?.font = chrome
        restore.accessibilityIdentifier = "history.row.restore"
        restore.accessibilityLabel = "Restore this savepoint"
        restore.addAction(
            UIAction { [weak self] _ in
                guard let model = self?.model else { return }
                Task { await model.takeHistory.restore(item) }
            }, for: .touchUpInside)
        restore.sizeToFit()
        restore.frame = CGRect(
            x: width - restore.bounds.width - 16, y: 4,
            width: restore.bounds.width, height: 26)
        row.addSubview(restore)

        let preview = UILabel()
        preview.text = item.commit.text.isEmpty
            ? chromeCase("(Empty savepoint)") : item.commit.text
        preview.font = face.chrome.withSize(12)
        preview.textColor = face.muted
        preview.numberOfLines = 1
        preview.accessibilityIdentifier = "history.row.preview"
        preview.frame = CGRect(x: 12, y: 32, width: width - 24, height: 22)
        row.addSubview(preview)

        return row
    }

    /// The pre-split confirm (AppSpec §9's warning): presented ONCE per
    /// gate — the controller's `pendingRestore` is the truth; the alert
    /// resolves it through the controller's own arms.
    private func presentPendingRestoreIfNeeded(_ history: MobileTakeHistoryController) {
        guard let pending = history.pendingRestore else {
            presentedRestoreID = nil
            return
        }
        guard presentedRestoreID != pending.commit.id,
              let root = window?.rootViewController
        else { return }
        presentedRestoreID = pending.commit.id
        let alert = UIAlertController(
            title: nil,
            message: MobileTakeHistoryController.predatesSplitWarning,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restore", style: .default) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.takeHistory.restore(pending, confirmed: true) }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.model?.takeHistory.cancelPendingRestore()
        })
        root.present(alert, animated: true)
    }

    private static var rowFlag: String {
        MobileTakeHistoryController.predatesSplitRowFlag
    }

    private func chromeCase(_ text: String) -> String {
        MobileEditorStyle.chromeCase(text)
    }
}
