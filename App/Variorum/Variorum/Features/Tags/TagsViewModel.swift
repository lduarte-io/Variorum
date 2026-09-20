//
//  TagsViewModel.swift
//  Variorum
//
//  Tag management (Phase 10 Step 5 — brief item 3): the hierarchical
//  taxonomy's CRUD faces over the Phase 2 operations. Chrome only — the
//  operations layer enforces name validity, path uniqueness, and the
//  subtree rewrite (`renameTag`); refusals surface as messages, never
//  silence (the 9d fire-and-speak posture).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class TagsViewModel {
    @ObservationIgnored private let session: AppSession

    private(set) var tags: [Tag] = []
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// Runs for the view's lifetime. The taxonomy is author-scale metadata
    /// (cost ∝ tag count — the unbounded pool/tray precedent).
    func start() async {
        do {
            for try await value in session.database.observeTags() {
                tags = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Internal so tests drive the listing deterministically.
    func adopt(_ new: [Tag]) {
        tags = new
    }

    /// Indent depth for the tree presentation (path components below root).
    func depth(of tag: Tag) -> Int {
        tag.path.reduce(0) { $0 + ($1 == "/" ? 1 : 0) }
    }

    func createTag(parentID: String?, name: String) async {
        await run { ops in _ = try ops.createTag(parent: parentID, name: name) }
    }

    func renameTag(_ id: String, to newName: String) async {
        await run { ops in try ops.renameTag(id, newName: newName) }
    }

    /// Deletes the tag AND its subtree (the op's contract); the per-tag
    /// trigger tombstones applications.
    func deleteTag(_ id: String) async {
        await run { ops in try ops.deleteTag(id) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch {
            lastError = Self.message(error)
        }
    }

    /// Refusal copy (review focus: refusals surface — duplicate path,
    /// invalid name).
    static func message(_ error: Error) -> String {
        guard let op = error as? OperationError else {
            return "Operation failed: \(error)"
        }
        switch op {
        case .invalidTagName:
            return "Tag names can't be empty or contain “/”."
        case .duplicateTagPath(let path):
            return "A tag named “\(path)” already exists."
        case .tagNotFound:
            return "That tag no longer exists."
        default:
            return "The operation was refused: \(op)"
        }
    }
}

/// The per-post tag editor (apply/remove — brief item 3's application
/// half): every toggle is exactly one Phase 2 operation.
@MainActor
@Observable
final class TagAssignmentViewModel {
    @ObservationIgnored private let session: AppSession
    let postID: String

    private(set) var allTags: [Tag] = []
    private(set) var appliedTagIDs: Set<String> = []
    private(set) var lastError: String?

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    /// One-shot load (the sheet is short-lived; a live observation would be
    /// ceremony for a modal).
    func load() async {
        do {
            let (tags, applied) = try await session.database.read { [postID] db in
                (try Queries.allTags(db), try Queries.postTags(db, postID: postID))
            }
            allTags = tags
            appliedTagIDs = Set(applied.map(\.id))
        } catch {
            lastError = String(describing: error)
        }
    }

    func isApplied(_ tagID: String) -> Bool {
        appliedTagIDs.contains(tagID)
    }

    /// 13b Stage 3, 3D (N24 — her words: "I want to be able to freely type
    /// tags in to a book, not just have to select from already created
    /// tags"): TYPE-TO-CREATE. A typed path ("life/goals/2024") walks the
    /// live taxonomy for its deepest existing prefix, creates the missing
    /// remainder through the EXISTING taxonomy ops (`createTag` per
    /// segment — the subtree path stays the op layer's), and applies the
    /// LEAF to the post — all in ONE serialized runner turn, so a racing
    /// duplicate refuses through the op's own guard. Already-applied
    /// leaves no-op politely. Returns the leaf's path on success (the
    /// field clears on it).
    ///
    /// **THE RULE ITSELF NOW LIVES IN `Shared/TypedTagPath.swift`** (13u4
    /// UNIT C1 — the KnownIssues forked-brains row's touch rule: *"any Mac
    /// phase touching one of these brains hoists it THEN"*, and the fix is
    /// always a HOIST, never a patch). It was mirrored onto the phone at
    /// the parity round's C3 and was therefore living twice; both platforms
    /// consume the one brain now. What stays HERE is exactly what belongs
    /// to this face: the sheet's re-sync and the Mac's own refusal copy.
    @discardableResult
    func applyTypedPath(_ raw: String) async -> String? {
        switch await TypedTagPath.apply(raw, toPost: postID, session: session) {
        case .nothingTyped:
            lastError = TypedTagPath.emptyMessage
            return nil
        case .refused(let error):
            lastError = TagsViewModel.message(error)
            return nil
        case .applied(let leafPath):
            await load()  // re-sync the sheet's rows (the new tag + check)
            lastError = nil
            return leafPath
        }
    }

    /// Apply or remove — exactly the Phase 2 op, then re-sync local state.
    func toggle(_ tagID: String) async {
        do {
            let post = postID
            if isApplied(tagID) {
                try await session.runner.run { ops in
                    try ops.removeTag(tagID, fromPost: post)
                }
                appliedTagIDs.remove(tagID)
            } else {
                try await session.runner.run { ops in
                    _ = try ops.applyTag(tagID, toPost: post)
                }
                appliedTagIDs.insert(tagID)
            }
            lastError = nil
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }
}
