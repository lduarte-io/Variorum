//
//  MobileCommentsSheetView.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M12) — the comments sheet's PIXELS: the
//  browser sheet's ratified sheet-over-page pattern (LK4's geometry —
//  dim + sheet in the SAME screen, harness-drivable), applied to the
//  block's comments. Rows are read-cheap; the draft field at the bottom
//  adds (or saves an edit); the DELETED section folds under the list
//  with per-row Restore (the never-skimpy rule). Every color/font
//  resolves from `MobileEditorStyle.face` (P-8).
//

import UIKit
import VariorumCore

@MainActor
final class MobileCommentsSheetView: UIView {
    private weak var pageTextView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// The sheet's top edge — the browser's constant family (PROVISIONAL
    /// visual constants; the look rounds rule).
    static let sheetTop: CGFloat = 160

    private let dimView = UIView()
    private let sheetView = UIView()
    private let headerLabel = UILabel()
    private let doneButton = UIButton(type: .custom)
    private let rowsScroll = UIScrollView()
    private let draftField = UITextView()
    private let draftPlaceholder = UILabel()
    private let submitButton = UIButton(type: .custom)
    private let cancelEditButton = UIButton(type: .custom)

    private var pageWasEditable = true
    private(set) var rowViews: [UIView] = []

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.pageTextView = textView
        self.model = model
        super.init(frame: .zero)
        isHidden = true
        accessibilityIdentifier = "comments.sheet"

        dimView.accessibilityIdentifier = "comments.dim"
        addSubview(dimView)

        sheetView.layer.cornerRadius = 22
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.accessibilityIdentifier = "comments.sheetPane"
        addSubview(sheetView)

        headerLabel.accessibilityIdentifier = "comments.header"
        sheetView.addSubview(headerLabel)

        doneButton.accessibilityIdentifier = "comments.done"
        doneButton.accessibilityLabel = "Done"
        doneButton.addAction(
            UIAction { [weak self] _ in self?.model?.comments.close() },
            for: .touchUpInside)
        sheetView.addSubview(doneButton)

        sheetView.addSubview(rowsScroll)

        draftField.accessibilityIdentifier = "comments.draft"
        draftField.layer.cornerRadius = 8
        draftField.layer.borderWidth = 1
        sheetView.addSubview(draftField)
        draftPlaceholder.accessibilityIdentifier = "comments.draft.placeholder"
        draftPlaceholder.isUserInteractionEnabled = false
        draftField.addSubview(draftPlaceholder)
        draftField.delegate = self

        submitButton.accessibilityIdentifier = "comments.submit"
        submitButton.accessibilityLabel = "Add comment"
        submitButton.addAction(
            UIAction { [weak self] _ in self?.submitDraft() },
            for: .touchUpInside)
        sheetView.addSubview(submitButton)

        cancelEditButton.accessibilityIdentifier = "comments.cancelEdit"
        cancelEditButton.addAction(
            UIAction { [weak self] _ in
                self?.draftField.text = ""
                self?.model?.comments.cancelEditing()
            }, for: .touchUpInside)
        sheetView.addSubview(cancelEditButton)

        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    @objc private func dimTapped() {
        model?.comments.close()
    }

    /// **17b P4 — THE FIELD EMPTIES ONLY WHEN THE STORE HAS TAKEN IT.**
    /// It used to clear here, before the write was even attempted, so a
    /// refusal — an ordinary one: the Comments row is offered on every
    /// block (fire-and-DO) and `addBlockComment` refuses under a sealed
    /// note — left her reading *"This note is locked…"* with the paragraph
    /// she had just typed gone and no undo. Her words live NOWHERE but
    /// this field until a row holds them, which is the quick note's own
    /// rule (#120(e)) and the pad's shipped shape.
    ///
    /// Keystrokes that land DURING the write are not part of what was
    /// submitted, so the field clears only while it still holds EXACTLY
    /// what was submitted — the capture family's recorded rule, in the
    /// original's own words (`QuickEntryBar`; the pad's `take()` is the
    /// same gate): *"clearing them wholesale would lose them for the sake
    /// of tidiness. She sees them still there, and a second ⏎ makes them a
    /// second note."* The consequence — text that landed can ride into
    /// that second post — is the family's chosen trade, not an oversight
    /// (ladder round 1's MINOR, dismissed against this rationale; changing
    /// the family's rule is the author's call, never one door's).
    private func submitDraft() {
        guard let model else { return }
        let text = draftField.text ?? ""
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task { [weak self] in
            guard await model.comments.submitDraft(text) else { return }
            guard let self, self.draftField.text == text else { return }
            self.draftField.text = ""
            self.draftPlaceholder.isHidden = false
        }
    }

    // MARK: - Render (the controller's onChanged hook)

    func render() {
        guard let model else { return }
        let comments = model.comments
        let wasHidden = isHidden
        let open = comments.isOpen

        if open, superview == nil, let host = pageTextView?.superview {
            frame = host.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.addSubview(self)
        }
        isHidden = !open

        // The page editor stands down under the sheet (the browser's
        // stand-down posture — one surface in charge); restored at close.
        if let page = pageTextView {
            if open, wasHidden {
                pageWasEditable = page.isEditable
                page.isEditable = false
                _ = page.resignFirstResponder()
            } else if !open, !wasHidden {
                page.isEditable = pageWasEditable
                draftField.text = ""
            }
        }
        guard open else {
            for row in rowViews { row.removeFromSuperview() }
            rowViews = []
            return
        }

        layoutChrome(comments)
        renderRows(comments)
    }

    private func layoutChrome(_ comments: MobileCommentsController) {
        let face = MobileEditorStyle.face
        dimView.frame = bounds
        dimView.backgroundColor = face.ink.withAlphaComponent(0.25)
        sheetView.frame = CGRect(
            x: 0, y: Self.sheetTop,
            width: bounds.width, height: max(bounds.height - Self.sheetTop, 0))
        sheetView.backgroundColor = face.surface

        let chrome = face.chrome.withSize(13)
        headerLabel.text = chromeCase("Comments")
        headerLabel.font = chrome
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

        let editing = comments.editingID != nil
        let draftY = sheetView.bounds.height - 56
        draftField.font = face.chrome.withSize(13)
        draftField.textColor = face.ink
        draftField.backgroundColor = face.card
        draftField.layer.borderColor = face.line.resolvedColor(
            with: traitCollection).cgColor
        draftField.frame = CGRect(
            x: 16, y: draftY, width: sheetView.bounds.width - 32 - 64, height: 40)
        draftPlaceholder.text = chromeCase(editing ? "Edit the comment…" : "Add a comment…")
        draftPlaceholder.font = face.chrome.withSize(13)
        draftPlaceholder.textColor = face.muted
        draftPlaceholder.sizeToFit()
        draftPlaceholder.frame.origin = CGPoint(x: 8, y: 10)
        draftPlaceholder.isHidden = !(draftField.text ?? "").isEmpty

        submitButton.setTitle(chromeCase(editing ? "Save" : "Add"), for: .normal)
        submitButton.setTitleColor(face.accent, for: .normal)
        submitButton.titleLabel?.font = chrome
        submitButton.frame = CGRect(
            x: draftField.frame.maxX + 8, y: draftY, width: 52, height: 40)

        cancelEditButton.setTitle(chromeCase("Cancel"), for: .normal)
        cancelEditButton.setTitleColor(face.muted, for: .normal)
        cancelEditButton.titleLabel?.font = face.chrome.withSize(11.5)
        cancelEditButton.isHidden = !editing
        cancelEditButton.frame = CGRect(
            x: draftField.frame.maxX + 8, y: draftY - 24, width: 52, height: 20)

        rowsScroll.frame = CGRect(
            x: 16, y: 44,
            width: sheetView.bounds.width - 32,
            height: max(draftY - 52, 0))
    }

    private func renderRows(_ comments: MobileCommentsController) {
        let face = MobileEditorStyle.face
        for row in rowViews { row.removeFromSuperview() }
        rowViews = []
        var y: CGFloat = 0
        let width = rowsScroll.bounds.width

        func addLabelRow(
            _ text: String, color: UIColor, size: CGFloat, identifier: String
        ) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = face.chrome.withSize(size)
            label.textColor = color
            label.numberOfLines = 0
            label.accessibilityIdentifier = identifier
            let fit = label.sizeThatFits(CGSize(width: width, height: .infinity))
            label.frame = CGRect(x: 0, y: y, width: width, height: fit.height)
            rowsScroll.addSubview(label)
            rowViews.append(label)
            y += fit.height + 2
            return label
        }

        func addButton(
            _ title: String, x: CGFloat, color: UIColor, identifier: String,
            action: @escaping () -> Void
        ) -> UIButton {
            let button = UIButton(type: .custom)
            button.setTitle(chromeCase(title), for: .normal)
            button.setTitleColor(color, for: .normal)
            button.titleLabel?.font = face.chrome.withSize(11.5)
            button.accessibilityIdentifier = identifier
            button.addAction(UIAction { _ in action() }, for: .touchUpInside)
            button.sizeToFit()
            button.frame = CGRect(
                x: x, y: y, width: max(button.bounds.width, 40), height: 20)
            rowsScroll.addSubview(button)
            rowViews.append(button)
            return button
        }

        if comments.comments.isEmpty {
            _ = addLabelRow(
                chromeCase("No comments on this block yet."),
                color: face.muted, size: 12, identifier: "comments.empty")
            y += 8
        }
        for comment in comments.comments {
            _ = addLabelRow(
                comment.text, color: face.ink, size: 13,
                identifier: "comments.row.\(comment.id)")
            _ = addLabelRow(
                comment.createdAt.formatted(date: .abbreviated, time: .shortened),
                color: face.muted, size: 10.5,
                identifier: "comments.date.\(comment.id)")
            let editButton = addButton(
                "Edit", x: 0, color: face.accent,
                identifier: "comments.edit.\(comment.id)"
            ) { [weak self] in
                guard let self, let model = self.model else { return }
                model.comments.beginEditing(comment.id)
                self.draftField.text = comment.text
                self.draftPlaceholder.isHidden = true
                self.render()
            }
            _ = addButton(
                "Delete", x: editButton.frame.maxX + 12, color: face.muted,
                identifier: "comments.delete.\(comment.id)"
            ) { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.comments.delete(comment.id) }
            }
            y += 26
        }

        if !comments.deleted.isEmpty {
            let fold = addButton(
                "\(comments.deletedShown ? "▾" : "▸") deleted (\(comments.deleted.count))",
                x: 0, color: face.muted, identifier: "comments.deletedFold"
            ) { [weak self] in
                guard let model = self?.model else { return }
                model.comments.deletedShown.toggle()
                model.comments.onChanged?()
            }
            _ = fold
            y += 26
            if comments.deletedShown {
                for comment in comments.deleted {
                    let label = addLabelRow(
                        comment.text, color: face.muted, size: 11.5,
                        identifier: "comments.deletedRow.\(comment.id)")
                    label.attributedText = NSAttributedString(
                        string: comment.text,
                        attributes: [
                            .font: face.chrome.withSize(11.5),
                            .foregroundColor: face.muted,
                            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        ])
                    _ = addButton(
                        "Restore", x: 0, color: face.accent,
                        identifier: "comments.restore.\(comment.id)"
                    ) { [weak self] in
                        guard let model = self?.model else { return }
                        Task { await model.comments.restore(comment.id) }
                    }
                    y += 26
                }
            }
        }
        rowsScroll.contentSize = CGSize(width: width, height: y + 12)
    }

    private func chromeCase(_ text: String) -> String {
        MobileEditorStyle.voice == .terminal ? text.lowercased() : text
    }
}

// MARK: - The draft field's delegate (placeholder visibility)

extension MobileCommentsSheetView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        draftPlaceholder.isHidden = !(textView.text ?? "").isEmpty
    }
}
