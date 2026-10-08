//
//  MobileBlockHistorySheetView.swift
//  VariorumMobile
//
//  **THE BLOCK HISTORY FACE'S PIXELS** (mobile round 2, batch 6a) — the
//  ratified sheet-over-page (LK4's geometry, the comments/takes sheets'
//  posture) carrying the four regions `MobileBlockHistoryController.rows()`
//  decides. Every colour and font resolves from `MobileEditorStyle.face`
//  (P-8); every word comes from `Shared/BlockHistoryFace.swift`.
//
//  ── WHY A UITableView, WHERE THE OLD SHEET HAND-ROLLED A BAND ────────────
//  The take-history sheet this replaces listed ONE take's savepoints at a
//  fixed pitch and materialized a near-viewport band by hand (parity D2's
//  fix for a face that used to build every row). This face lists FOUR
//  regions of differently-shaped rows, so a single pitch no longer exists —
//  and rather than grow the hand-rolled arithmetic to a per-kind height
//  table, the rows ride a `UITableView`, which is lazy BY CONSTRUCTION:
//  UIKit never builds a cell that is not near the viewport and recycles the
//  ones that leave. P3's read-cheap tier holds the same way it did, with
//  less machinery to be wrong. The lazy pin drives the real table.
//
//  ── NOTHING IN HERE IS A LIVE EDITOR ─────────────────────────────────────
//  Every take in this face is a label. A history face is a look at what a
//  block has been, never a place to write — and the page editor stands down
//  while the sheet is up (the comments sheet's exact posture), which is also
//  why this face needs no current-block jump: the caret cannot move.
//
//  ── NO PURGE DOOR ────────────────────────────────────────────────────────
//  The deleted region draws Put back and NOTHING else, by her evolved rule
//  (the post-13l polish round's ledger row 21): Delete Now lives on TRASH
//  SURFACES only. `MobileBlockHistorySheetView.surfaceCapabilities` names
//  what this surface renders, and `.deleteNow` is deliberately absent.
//

import UIKit
import VariorumCore

@MainActor
final class MobileBlockHistorySheetView: UIView {
    /// **What this surface renders inline**, named so the promise is a VALUE
    /// a pin can hold: **`deleteNow` is deliberately absent** — this is not a
    /// trash surface (her evolved purge-door rule).
    ///
    /// Plain strings, not `CapabilityID`: the capability REGISTRY is Mac-only
    /// (it has no mobile or `Shared/` half today), so this is the phone's own
    /// declaration rather than a registry entry, and a reader should not go
    /// looking for a walk that unions it.
    static let surfaceCapabilities: [String] = ["restoreTake", "unarchiveTake"]

    private weak var pageTextView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// The comments sheet's constant family (PROVISIONAL visual constants;
    /// the look rounds rule).
    static let sheetTop: CGFloat = 120

    private let dimView = UIView()
    private let sheetView = UIView()
    private let headerLabel = UILabel()
    private let statusLabel = UILabel()
    private let doneButton = UIButton(type: .custom)
    private let table = UITableView(frame: .zero, style: .plain)

    private var pageWasEditable = true
    private var rows: [MobileBlockHistoryController.Row] = []
    /// The pre-split confirm currently presented (one presentation per gate
    /// — `render()` re-runs freely and must not stack alerts).
    private var presentedRestoreID: String?

    /// The table, exposed for the lazy pin (harness-drivable — the comments
    /// sheet pattern's own discipline).
    var tableForTesting: UITableView { table }
    /// The rows currently rendered — the face's content as a value.
    var renderedRows: [MobileBlockHistoryController.Row] { rows }

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.pageTextView = textView
        self.model = model
        super.init(frame: .zero)
        isHidden = true
        accessibilityIdentifier = "blockHistory.sheet"

        dimView.accessibilityIdentifier = "blockHistory.dim"
        addSubview(dimView)

        sheetView.layer.cornerRadius = 22
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.accessibilityIdentifier = "blockHistory.sheetPane"
        addSubview(sheetView)

        headerLabel.accessibilityIdentifier = "blockHistory.header"
        sheetView.addSubview(headerLabel)

        statusLabel.accessibilityIdentifier = "blockHistory.status"
        statusLabel.numberOfLines = 2
        sheetView.addSubview(statusLabel)

        doneButton.accessibilityIdentifier = "blockHistory.done"
        doneButton.accessibilityLabel = "Done"
        doneButton.addAction(
            UIAction { [weak self] _ in self?.model?.blockHistory.close() },
            for: .touchUpInside)
        sheetView.addSubview(doneButton)

        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.accessibilityIdentifier = "blockHistory.rows"
        table.register(
            MobileBlockHistoryCell.self,
            forCellReuseIdentifier: MobileBlockHistoryCell.reuseID)
        sheetView.addSubview(table)

        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    @objc private func dimTapped() {
        model?.blockHistory.close()
    }

    // MARK: - Render (the controller's onChanged hook)

    func render() {
        guard let model else { return }
        let history = model.blockHistory
        let wasHidden = isHidden
        let open = history.isOpen

        if open, superview == nil, let host = pageTextView?.superview {
            frame = host.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.addSubview(self)
        }
        isHidden = !open

        // The page editor stands down while the sheet is up (the comments
        // sheet's exact posture); restored at close.
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
            rows = []
            table.reloadData()
            presentedRestoreID = nil
            return
        }

        layoutChrome(history)
        rows = history.rows()
        table.reloadData()
        presentPendingRestoreIfNeeded(history)
    }

    private func layoutChrome(_ history: MobileBlockHistoryController) {
        let face = MobileEditorStyle.face
        dimView.frame = bounds
        dimView.backgroundColor = face.ink.withAlphaComponent(0.25)
        sheetView.frame = CGRect(
            x: 0, y: Self.sheetTop,
            width: bounds.width, height: max(bounds.height - Self.sheetTop, 0))
        sheetView.backgroundColor = face.surface

        headerLabel.text = chromeCase(BlockHistoryPath.name)
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

        // A receipt is not a refusal — the SHARED classification decides the
        // colour, never the words (`RecoveryStatus`).
        var statusHeight: CGFloat = 0
        if let status = history.status {
            statusLabel.isHidden = false
            statusLabel.text = status.text
            statusLabel.font = face.chrome.withSize(12)
            statusLabel.textColor = status.isRefusal ? face.alarm : face.muted
            let width = sheetView.bounds.width - 40
            let size = statusLabel.sizeThatFits(
                CGSize(width: width, height: .greatestFiniteMagnitude))
            statusLabel.frame = CGRect(x: 20, y: 40, width: width, height: size.height)
            statusHeight = size.height + 8
        } else {
            statusLabel.isHidden = true
            statusLabel.text = nil
        }

        let top = 40 + statusHeight
        table.frame = CGRect(
            x: 8, y: top,
            width: sheetView.bounds.width - 16,
            height: max(sheetView.bounds.height - top - 8, 0))
    }

    /// The pre-split confirm (AppSpec §9's warning): presented ONCE per gate
    /// — the controller's `pendingRestore` is the truth; the alert resolves
    /// it through the controller's own arms.
    private func presentPendingRestoreIfNeeded(_ history: MobileBlockHistoryController) {
        guard let pending = history.pendingRestore else {
            presentedRestoreID = nil
            return
        }
        guard presentedRestoreID != pending.commit.id,
              let root = window?.rootViewController
        else { return }
        presentedRestoreID = pending.commit.id
        let alert = UIAlertController(
            title: BlockHistoryCopy.predatesSplitTitle,
            message: BlockHistoryCopy.predatesSplitDetail,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: BlockHistoryCopy.restoreAnyway, style: .destructive
        ) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.blockHistory.confirmPendingRestore() }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.model?.blockHistory.cancelPendingRestore()
        })
        root.present(alert, animated: true)
    }

    private func chromeCase(_ text: String) -> String {
        MobileEditorStyle.chromeCase(text)
    }
}

// MARK: - The rows

extension MobileBlockHistorySheetView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        // Section headers are MEASURED (M1): their explainers are prose and
        // a fixed pitch truncated the two longest of them. Everything else
        // keeps the pure `Row.height` pitch, which is what makes this table
        // cheap to lay out.
        if case .sectionHeader(let title, let explainer) = rows[indexPath.row] {
            return MobileBlockHistoryCell.sectionHeaderHeight(
                title: title, explainer: explainer,
                width: tableView.bounds.width, face: MobileEditorStyle.face)
        }
        return rows[indexPath.row].height
    }

    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MobileBlockHistoryCell.reuseID, for: indexPath)
            as! MobileBlockHistoryCell
        cell.configure(rows[indexPath.row], face: MobileEditorStyle.face) { [weak self] act in
            self?.perform(act)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let history = model?.blockHistory else { return }
        switch rows[indexPath.row] {
        case .takeHeader(let variantID, _, _, _, _):
            history.toggleTake(variantID)
        case .quietRun(let id, _, _):
            history.toggleRun(id)
        default:
            break
        }
    }

    private func perform(_ act: MobileBlockHistoryCell.Act) {
        guard let history = model?.blockHistory else { return }
        switch act {
        case .restore(let variantID, let commit):
            Task { await history.restore(commit, of: variantID) }
        case .unarchive(let variantID):
            Task { await history.unarchive(variantID) }
        case .putBack(let variantID):
            Task { await history.putBackTake(variantID) }
        case .bringBack(let blockID):
            Task { await history.bringBack(blockID) }
        }
    }
}

/// ONE cell shape for every row kind — a title, a quiet meta line and at most
/// one act button. Recycled by the table, so `configure` sets every field
/// each time (a half-configured recycled cell is the classic table defect).
@MainActor
final class MobileBlockHistoryCell: UITableViewCell {
    static let reuseID = "blockHistory.cell"

    enum Act {
        case restore(variantID: String, commit: CommitPoint)
        case unarchive(variantID: String)
        case putBack(variantID: String)
        case bringBack(blockID: String)
    }

    /// Internal, not private, for ONE reason: M1's defect — a silently
    /// truncated explainer — is invisible to a `rows()` pin and invisible
    /// to a subview census. The only way to hold "the sentence really fits"
    /// is to read the laid-out label, so the pin reads it.
    let titleLabel = UILabel()
    let metaLabel = UILabel()
    private let actButton = UIButton(type: .custom)
    private var act: Act?
    private var onAct: ((Act) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        titleLabel.numberOfLines = 2
        metaLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        actButton.addAction(
            UIAction { [weak self] _ in
                guard let self, let act = self.act else { return }
                self.onAct?(act)
            }, for: .touchUpInside)
        contentView.addSubview(actButton)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    func configure(
        _ row: MobileBlockHistoryController.Row,
        face: MobileEditorStyle.Face,
        onAct: @escaping (Act) -> Void
    ) {
        self.onAct = onAct
        act = nil
        actButton.isHidden = true
        actButton.accessibilityIdentifier = nil
        metaLabel.isHidden = false
        titleLabel.font = face.body
        titleLabel.textColor = face.ink
        metaLabel.font = face.chrome.withSize(11.5)
        metaLabel.textColor = face.muted
        // RESET BOTH LINE CAPS ON EVERY CONFIGURE (batch 6a's cold review,
        // M1 — and the recycled-cell rule this file's own header states):
        // `init` set them once, so a cell that had carried a one-line row
        // kept that cap when it came back as something taller.
        titleLabel.numberOfLines = 2
        metaLabel.numberOfLines = 2

        switch row {
        case .sectionHeader(let title, let explainer):
            accessibilityIdentifier = "blockHistory.section.\(title)"
            titleLabel.font = face.chrome.withSize(12.5)
            titleLabel.textColor = face.muted
            titleLabel.text = MobileEditorStyle.chromeCase(title)
            // UNBOUNDED, and the row is measured to fit it (see
            // `sectionHeaderHeight`). The two explainers this face leans on
            // hardest — the Savepoints one that says what the whole surface
            // is, and the Came-from one whose second half explains the
            // Bring back button rendered inches away — need three and four
            // lines at default text size, and both stopped mid-thought
            // under a two-line cap in a fixed 52pt row. The caps and the
            // row height were jointly wrong, so both move.
            metaLabel.numberOfLines = 0
            metaLabel.text = MobileEditorStyle.chromeCase(explainer)

        case .takeHeader(let variantID, let title, let focused, let savepoints, let expanded):
            accessibilityIdentifier = "blockHistory.take.\(variantID)"
            titleLabel.font = face.chrome.withSize(12.5)
            titleLabel.textColor = focused ? face.chosenMark : face.ink
            titleLabel.numberOfLines = 1
            let mark = focused ? " \u{00B7} \(BlockHistoryPath.focusedMark)" : ""
            titleLabel.text = MobileEditorStyle.chromeCase(
                "\(expanded ? "\u{25BE}" : "\u{25B8}") \(title)\(mark)")
            metaLabel.text = MobileEditorStyle.chromeCase("\(savepoints)")
            metaLabel.textAlignment = .right

        case .quietRun(_, let count, let expanded):
            accessibilityIdentifier = "blockHistory.run"
            titleLabel.font = face.chrome.withSize(11.5)
            titleLabel.textColor = face.muted
            titleLabel.numberOfLines = 1
            titleLabel.text = MobileEditorStyle.chromeCase(
                SavepointRuns.runLabel(count: count) + " \u{00B7} "
                + (expanded ? SavepointRuns.hideVerb : SavepointRuns.showVerb))
            metaLabel.isHidden = true

        case .savepoint(let variantID, let commit, let predatesSplit):
            accessibilityIdentifier = "blockHistory.savepoint.\(commit.id)"
            titleLabel.numberOfLines = 1
            titleLabel.text = commit.text.isEmpty
                ? MobileEditorStyle.chromeCase("(Empty commit)")
                : String(commit.text.prefix(120))
            titleLabel.textColor = commit.text.isEmpty ? face.muted : face.ink
            metaLabel.text = MobileEditorStyle.chromeCase(
                SavepointRowFace.meta(commit, predatesSplit: predatesSplit)
                    .joined(separator: " \u{00B7} "))
            metaLabel.textColor = predatesSplit ? face.accent : face.muted
            show(BlockHistoryCopy.restoreVerb,
                 label: "\(BlockHistoryCopy.restoreVerb) this commit",
                 identifier: "blockHistory.restore",
                 tint: face.accent, face: face,
                 act: .restore(variantID: variantID, commit: commit))

        case .quiet(let line):
            accessibilityIdentifier = "blockHistory.quiet"
            titleLabel.font = face.chrome.withSize(12)
            titleLabel.textColor = face.muted
            titleLabel.text = MobileEditorStyle.chromeCase(line)
            metaLabel.isHidden = true

        case .archivedTake(let take):
            accessibilityIdentifier = "blockHistory.archived.\(take.id)"
            titleLabel.numberOfLines = 1
            titleLabel.text = BlockPastCopy.rowLabel(take)
            titleLabel.textColor = take.workingText.isEmpty ? face.muted : face.ink
            metaLabel.text = MobileEditorStyle.chromeCase(RecoveryCopy.archivedForever)
            show(BlockHistoryCopy.unarchiveVerb,
                 label: "\(BlockHistoryCopy.unarchiveVerb) this take",
                 identifier: "blockHistory.unarchive",
                 tint: face.accent, face: face,
                 act: .unarchive(variantID: take.id))

        case .deletedTake(let take, let meta):
            accessibilityIdentifier = "blockHistory.deleted.\(take.id)"
            titleLabel.numberOfLines = 1
            titleLabel.text = BlockPastCopy.rowLabel(take)
            titleLabel.textColor = take.workingText.isEmpty ? face.muted : face.ink
            metaLabel.text = MobileEditorStyle.chromeCase(meta)
            show(BlockPastCopy.putBackVerb,
                 label: "\(BlockPastCopy.putBackVerb) this take",
                 identifier: "blockHistory.putBack",
                 tint: face.accent, face: face,
                 act: .putBack(variantID: take.id))

        case .origin(let blockID, let text, let lineage):
            accessibilityIdentifier = "blockHistory.origin.\(blockID)"
            titleLabel.numberOfLines = 2
            titleLabel.text = text
            metaLabel.text = MobileEditorStyle.chromeCase(lineage)
            show(BlockHistoryPath.bringBackVerb,
                 label: "\(BlockHistoryPath.bringBackVerb) this original",
                 identifier: "blockHistory.bringBack",
                 tint: face.accent, face: face,
                 act: .bringBack(blockID: blockID))
        }
        setNeedsLayout()
    }

    private func show(
        _ title: String, label: String, identifier: String,
        tint: UIColor, face: MobileEditorStyle.Face, act: Act
    ) {
        self.act = act
        actButton.isHidden = false
        actButton.setTitle(MobileEditorStyle.chromeCase(title), for: .normal)
        actButton.setTitleColor(tint, for: .normal)
        actButton.titleLabel?.font = face.chrome.withSize(12)
        actButton.accessibilityIdentifier = identifier
        actButton.accessibilityLabel = label
    }

    /// **What a `.sectionHeader` row actually needs at this width** (batch
    /// 6a's cold review, M1). Every other row kind carries text of a known
    /// shape and keeps its fixed pitch from `Row.height`; only the section
    /// headers carry prose, and their prose is the face's own explanation
    /// of itself. Measuring is `layoutSubviews`' arithmetic run ahead of
    /// time — same fonts, same `chromeCase` transform, same 12pt side
    /// insets and 4pt vertical padding, and no act button (a header never
    /// has one) — so the row can never be shorter than what the cell then
    /// draws into it.
    ///
    /// Floored at the old fixed 52pt so short headers keep the calm rhythm
    /// the face shipped with; only the long explainers grow.
    static func sectionHeaderHeight(
        title: String, explainer: String,
        width: CGFloat, face: MobileEditorStyle.Face
    ) -> CGFloat {
        let textWidth = max(width - 24, 40)
        let bounds = CGSize(width: textWidth, height: .greatestFiniteMagnitude)
        let titleHeight = (MobileEditorStyle.chromeCase(title) as NSString)
            .boundingRect(
                with: bounds, options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: face.chrome.withSize(12.5)], context: nil)
            .height
        let metaHeight = (MobileEditorStyle.chromeCase(explainer) as NSString)
            .boundingRect(
                with: bounds, options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: face.chrome.withSize(11.5)], context: nil)
            .height
        return max(ceil(titleHeight) + 2 + ceil(metaHeight) + 8,
                   MobileBlockHistoryController.Row.sectionHeaderFloor)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.bounds.width
        var actWidth: CGFloat = 0
        if !actButton.isHidden {
            actButton.sizeToFit()
            actWidth = actButton.bounds.width + 16
            actButton.frame = CGRect(
                x: width - actButton.bounds.width - 12,
                y: (contentView.bounds.height - 26) / 2,
                width: actButton.bounds.width, height: 26)
        }
        let textWidth = max(width - 24 - actWidth, 40)
        let titleSize = titleLabel.sizeThatFits(
            CGSize(width: textWidth, height: .greatestFiniteMagnitude))
        if metaLabel.isHidden {
            titleLabel.frame = CGRect(
                x: 12, y: (contentView.bounds.height - titleSize.height) / 2,
                width: textWidth, height: titleSize.height)
            return
        }
        let metaSize = metaLabel.sizeThatFits(
            CGSize(width: textWidth, height: .greatestFiniteMagnitude))
        let total = titleSize.height + 2 + metaSize.height
        let top = max((contentView.bounds.height - total) / 2, 4)
        titleLabel.frame = CGRect(
            x: 12, y: top, width: textWidth, height: titleSize.height)
        metaLabel.frame = CGRect(
            x: 12, y: top + titleSize.height + 2,
            width: textWidth, height: metaSize.height)
    }
}
