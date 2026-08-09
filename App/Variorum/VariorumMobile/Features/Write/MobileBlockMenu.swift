//
//  MobileBlockMenu.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 — the ⋯ BLOCK MENU: Takes… · Comments… ·
//  Callout ▸ · Name Block… · Divide Block · Merge with Previous · Delete
//  Block, on the caret's block, through TWO doors that cannot drift (the
//  CalloutMenu one-vocabulary precedent): the keyboard bar's ⋯ and the
//  extended edit menu both render `menuElements` — ONE builder decides
//  the words and the order.
//
//  Every row performs a STANDING act or delivers the ops' real refusal
//  (P-2): Takes/Comments open their sheets; Callout rides the mirrored
//  `MobileCallout` transform through `updateBlockPresentation`; Name is
//  `setBlockName`; Divide/Merge/Delete are `MobileStructuralController`'s
//  doors (M10; Delete joined at the S4 ladder — MAJOR 1's latch +
//  flush-guard contract) — the deleted-blocks TRAY stays
//  Mac-side in v1 (the refusal-free recovery road, named in the note).
//  "Archive Block" is a recorded DELIBERATE ABSENCE: no such operation
//  exists (blocks archive nowhere — only containers and takes do), the
//  Mac offers no such door, and rendering one would invent product
//  behavior.
//
//  PROMPTS (Name…, Emoji…, the delete confirm) ride injectable seams —
//  production installs UIAlertController plumbing at attach; tests
//  inject answers. The emoji prompt's semantics are the Mac
//  `CalloutMenu.promptEmoji`'s exactly: cancel = nil (nothing happens);
//  EMPTY is a real answer ("no glyph").
//

import Foundation
import UIKit
import VariorumCore

@MainActor
final class MobileBlockMenuController {
    private let session: AppSession
    weak var model: MobileEditorViewModel?

    /// The prompt seams (production: UIAlertController; tests inject).
    /// completion(nil) = cancelled.
    var promptForText:
        (@MainActor (_ title: String, _ message: String, _ current: String?,
                     _ completion: @escaping @MainActor (String?) -> Void) -> Void)?
    /// The destructive confirm seam. completion(true) = proceed.
    var confirmDestructive:
        (@MainActor (_ title: String, _ message: String, _ actionTitle: String,
                     _ completion: @escaping @MainActor (Bool) -> Void) -> Void)?

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - The row vocabulary (one builder, two doors)

    static let takesTitle = "Takes…"
    static let commentsTitle = "Comments…"
    static let calloutTitle = "Callout"
    static let nameTitle = "Name Block…"
    static let divideTitle = "Divide Block"
    static let mergeTitle = "Merge with Previous"
    static let deleteTitle = "Delete Block"
    /// The Mac CalloutMenu's row words, mirrored (one vocabulary).
    static let calloutToggleTitle = "Toggle Callout"
    static let calloutEmojiTitle = "Emoji…"
    static let calloutRemoveTitle = "Remove Callout"

    /// The flat titles both doors must agree on (the drift pin's oracle).
    static var rowTitles: [String] {
        [takesTitle, commentsTitle, calloutTitle, nameTitle,
         divideTitle, mergeTitle, deleteTitle]
    }

    /// The callout submenu's titles in order (separators excluded) —
    /// `CalloutMenu.rowTitles`' mirror.
    static var calloutRowTitles: [String] {
        [calloutToggleTitle]
            + MobileCallout.names.map(\.capitalized)
            + [calloutEmojiTitle, calloutRemoveTitle]
    }

    /// The menu's elements for one block — consumed by the bar's ⋯
    /// (whole) and the edit menu's Block submenu (minus Takes…, which
    /// already rides flat there — S2's own item, byte-untouched).
    /// Displayed titles are VOICE-CASED (P26/P43, parity A3 — the flip
    /// of P26/P43's recorded system-register posture): `rowTitles` stays
    /// the canonical vocabulary, `chromeCase` is the render register.
    func menuElements(blockID: String, includeTakes: Bool) -> [UIMenuElement] {
        let cased = MobileEditorStyle.chromeCase
        var elements: [UIMenuElement] = []
        if includeTakes {
            elements.append(UIAction(title: cased(Self.takesTitle)) { [weak self] _ in
                self?.model?.openTakesBrowser(blockID: blockID)
            })
        }
        elements.append(UIAction(title: cased(Self.commentsTitle)) { [weak self] _ in
            self?.model?.openComments(blockID: blockID)
        })
        elements.append(calloutSubmenu(blockID: blockID))
        elements.append(UIAction(title: cased(Self.nameTitle)) { [weak self] _ in
            self?.promptRename(blockID: blockID)
        })
        elements.append(UIAction(title: cased(Self.divideTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.divideAtCaret() }
        })
        elements.append(UIAction(title: cased(Self.mergeTitle)) { [weak self] _ in
            guard let model = self?.model else { return }
            Task { await model.structural.mergeWithPrevious() }
        })
        elements.append(UIAction(
            title: cased(Self.deleteTitle), attributes: .destructive
        ) { [weak self] _ in
            self?.confirmDelete(blockID: blockID)
        })
        return elements
    }

    private func calloutSubmenu(blockID: String) -> UIMenu {
        let cased = MobileEditorStyle.chromeCase
        var rows: [UIMenuElement] = [
            UIAction(title: cased(Self.calloutToggleTitle)) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .toggle) }
            },
        ]
        rows += MobileCallout.names.map { name in
            UIAction(title: cased(name.capitalized)) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .color(name)) }
            }
        }
        rows += [
            UIAction(title: cased(Self.calloutEmojiTitle)) { [weak self] _ in
                self?.promptEmoji(blockID: blockID)
            },
            UIAction(title: cased(Self.calloutRemoveTitle)) { [weak self] _ in
                Task { await self?.applyCallout(blockID: blockID, edit: .color(nil)) }
            },
        ]
        return UIMenu(title: cased(Self.calloutTitle), children: rows)
    }

    // MARK: - Callout (M12 — the one mirrored transform through the op)

    func applyCallout(blockID: String, edit: MobileCallout.Edit) async {
        guard let model else { return }
        do {
            try await session.runner.run { ops in
                try ops.updateBlockPresentation(blockID) { existing in
                    MobileCallout.apply(edit, to: existing)
                }
            }
            model.report(nil)
            await model.refreshTakesFromStore()
        } catch {
            model.report(Self.refusalMessage(error, act: "change the callout"))
        }
    }

    private func promptEmoji(blockID: String) {
        guard let promptForText else { return }
        promptForText(
            "Callout Emoji",
            "A leading glyph for this callout (leave empty for none).",
            nil
        ) { [weak self] glyph in
            guard let glyph else { return } // cancelled
            Task { await self?.applyCallout(blockID: blockID, edit: .emoji(glyph)) }
        }
    }

    // MARK: - Name (the block's handle — `setBlockName`)

    func promptRename(blockID: String) {
        guard promptForText != nil, let postID = model?.postID else { return }
        Task { [weak self] in
            guard let self else { return }
            // The seed reads through the standing query vocabulary (S4
            // ladder NIT 1 — the read-side home is `Queries`, never raw
            // SQL in a feature controller): `blockTOC` is the standing
            // name-carrying read, cost ∝ the post (P1).
            let current: String? = (try? await self.session.database.read { db in
                try Queries.blockTOC(db, post: postID)
                    .first { $0.blockID == blockID }?.name
            }) ?? nil
            guard let promptForText = self.promptForText else { return }
            promptForText(
                "Name Block",
                "A handle for this block (leave empty to clear).",
                current
            ) { [weak self] name in
                guard let name else { return } // cancelled
                Task { await self?.rename(blockID: blockID, name: name) }
            }
        }
    }

    func rename(blockID: String, name: String?) async {
        guard let model else { return }
        do {
            try await session.runner.run { ops in
                try ops.setBlockName(blockID, name: name)
            }
            model.report(nil)
        } catch {
            model.report(Self.refusalMessage(error, act: "name the block"))
        }
    }

    // MARK: - Delete block (the tray stays Mac-side; confirm, since the
    // phone has no structural undo — v1's recorded posture)

    private func confirmDelete(blockID: String) {
        guard let confirmDestructive else {
            Task { await delete(blockID: blockID) }
            return
        }
        confirmDestructive(
            "Delete Block",
            "The block waits in this note's deleted-blocks tray on the Mac.",
            "Delete"
        ) { [weak self] proceed in
            guard proceed else { return }
            Task { await self?.delete(blockID: blockID) }
        }
    }

    /// The act itself rides the STRUCTURAL controller's contract (S4
    /// ladder MAJOR 1): `deleteBlock` is a structural op, so it takes the
    /// one-flight latch + the flush-guard its siblings carry — a refused
    /// flush refuses the delete, which is what makes the tray-copy
    /// promise true. This door keeps only the confirm seam.
    func delete(blockID: String) async {
        await model?.structural.deleteBlock(blockID: blockID)
    }

    // MARK: - Refusal copy

    /// The everyday cases in phone words (the S2 posture); the rest is
    /// the operations layer's own message.
    static func refusalMessage(_ error: Error, act: String) -> String {
        guard let error = error as? OperationError else {
            return String(describing: error)
        }
        switch error {
        case .lockedPost:
            return "This note is locked — unlock it to \(act)."
        default:
            return String(describing: error)
        }
    }
}
