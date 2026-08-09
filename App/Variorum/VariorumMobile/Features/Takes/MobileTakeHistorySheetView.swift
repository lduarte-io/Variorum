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
final class MobileTakeHistorySheetView: UIView {
    private weak var pageTextView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// The comments sheet's constant family (PROVISIONAL visual
    /// constants; the look rounds rule).
    static let sheetTop: CGFloat = 160

    private let dimView = UIView()
    private let sheetView = UIView()
    private let headerLabel = UILabel()
    private let doneButton = UIButton(type: .custom)
    private let rowsScroll = UIScrollView()
    private let emptyLabel = UILabel()

    private var pageWasEditable = true
    private(set) var rowViews: [UIView] = []
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
            for row in rowViews { row.removeFromSuperview() }
            rowViews = []
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

    private func renderRows(_ history: MobileTakeHistoryController) {
        let face = MobileEditorStyle.face
        for row in rowViews { row.removeFromSuperview() }
        rowViews = []

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

        var y: CGFloat = 0
        let width = rowsScroll.bounds.width
        for item in items {
            let row = makeRow(item: item, face: face, width: width)
            row.frame.origin.y = y
            rowsScroll.addSubview(row)
            rowViews.append(row)
            y += row.bounds.height + 10
        }
        rowsScroll.contentSize = CGSize(width: width, height: y)
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
