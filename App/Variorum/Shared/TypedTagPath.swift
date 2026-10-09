//
//  TypedTagPath.swift
//  Variorum — SHARED (both platforms)
//
//  **THE TYPED-PATH TAG BRAIN, HOISTED** (13u4 UNIT C1; the
//  `KnownIssuesAndTechDebt.md` forked-brains row's own rule: *"any Mac phase
//  touching one of these brains hoists it THEN"* — and the fix is always a
//  HOIST, never a patch).
//
//  It began as `TagAssignmentViewModel.applyTypedPath` (13b Stage 3, 3D —
//  her N24: *"I want to be able to freely type tags in to a book, not just
//  have to select from already created tags"*) and was MIRRORED onto the
//  phone at the parity round's C3, where it was then split into pure halves
//  (`MobileTagsModel.typedSegments` / `typedPathPlan` / `createMissing`) so
//  the phone's two typing surfaces could share one rule. That left the RULE
//  living twice across the platforms — the drift class the forked-brains row
//  exists to close. This file is the one home; the Mac view model and both
//  phone doors consume it, and `MobileTagsModel` keeps every pre-move name
//  as a forwarder so not one test on either platform had to move (the 3C
//  parity pattern — a zero-test-edit run is the proof the hoist moved an
//  address and not a behaviour).
//
//  **The rule, unchanged in every part:** a typed path ("life/goals/2026")
//  walks the LIVE taxonomy for its deepest existing prefix, creates the
//  missing remainder through the standing ops (`createTag` per segment — the
//  materialized subtree path stays the operations layer's), and applies the
//  LEAF to the post. Slash noise collapses forgivingly ("/a//b/" is a/b);
//  an already-applied leaf is a polite no-op, never an error; the creates
//  and the apply run in ONE serialized runner turn, so a racing duplicate
//  refuses through the op's own guard and the ops layer stays the only
//  integrity authority.
//

import Foundation
import VariorumCore

nonisolated enum TypedTagPath {
    /// Slash noise collapses forgivingly ("/a//b/" is a/b) — pure.
    ///
    /// No per-segment validity guard: `split(separator: "/")` can never
    /// yield a segment containing "/" and the filter drops the empties, so
    /// the only refusal this road has is "nothing was typed" (the Stage 3
    /// ladder's NIT-1 deleted the dead guard and its unreachable copy).
    ///
    /// 13n-a: the rule lives in core (`VariorumCore.TagPath.segments`) — the
    /// document format's `{#tag/path}` tokens are typed paths too, and the
    /// core import door reads them by this same rule. This forwards.
    static func segments(_ raw: String) -> [String] {
        TagPath.segments(raw)
    }

    /// The empty-type hint — ONE sentence for every typing surface in both
    /// apps (it must name no platform: the phone says it too).
    static let emptyMessage = "Type a tag name — “/” makes a hierarchy (life/goals)."

    /// A typed path resolved against the live taxonomy: the deepest existing
    /// live prefix anchors creation; the missing remainder creates on the
    /// way.
    struct Plan: Equatable, Sendable {
        /// The deepest existing prefix's id — the create anchor (nil ⇒
        /// creation starts at the root).
        var parentID: String?
        /// The segments still to create, in order.
        var missing: [String]
        /// Non-nil when the WHOLE path already exists (nothing to create).
        var existingLeafID: String?
        /// The full path the walk lands on.
        var leafPath: String
    }

    /// The resolution half — pure over a taxonomy read (nil on empty
    /// segments; the caller speaks `emptyMessage`).
    static func plan(segments: [String], live: [Tag]) -> Plan? {
        guard !segments.isEmpty else { return nil }
        var parentID: String?
        var missing: [String] = []
        var existingLeafID: String?
        var path = ""
        for (i, segment) in segments.enumerated() {
            path = path.isEmpty ? segment : "\(path)/\(segment)"
            if missing.isEmpty, let existing = live.first(where: { $0.path == path }) {
                parentID = existing.id
                if i == segments.count - 1 { existingLeafID = existing.id }
            } else {
                missing.append(segment)
            }
        }
        return Plan(
            parentID: parentID, missing: missing,
            existingLeafID: existingLeafID, leafPath: path)
    }

    /// The create half, run INSIDE one serialized runner turn: creates the
    /// plan's missing segments through the standing ops and returns the
    /// LEAF's id.
    ///
    /// 13i-d U5: `wingID` — the wing a ROOT segment is born in (the note's —
    /// R-13ia-1); a child is born in its parent's (the op's own rule). ''
    /// (Home) for every caller that names none — the phone's, today.
    static func createMissing(
        _ plan: Plan, ops: Operations, wingID: String = ""
    ) throws -> String? {
        var parent = plan.parentID
        for segment in plan.missing {
            parent = try ops.createTag(
                parent: parent, name: segment, wingID: parent == nil ? wingID : nil).id
        }
        return plan.existingLeafID ?? parent
    }
}

// MARK: - The whole walk (the act both platforms' doors run)

@MainActor
extension TypedTagPath {
    /// What a typed path did. The ERROR rides out rather than a sentence,
    /// because refusal copy is the one part of this brain that is
    /// deliberately platform-local (the Mac's `TagsViewModel.message`, the
    /// phone's `MobileTagsModel.refusal` — MobileSoul §4.4: a shared home
    /// must not hold words that name a platform's own doors).
    enum Outcome {
        case applied(String)
        /// Nothing typed — or nothing but slashes. The caller speaks
        /// `emptyMessage`.
        case nothingTyped
        case refused(Error)
    }

    /// Resolve, create and apply — the composition every typed-path door
    /// runs, in one place so the two platforms cannot drift in the ORDER of
    /// it any more than in its parts.
    ///
    /// The read is a plain taxonomy read; the creates + the apply are ONE
    /// serialized runner turn. An `alreadyTagged` leaf is swallowed here, at
    /// the one site that knows typing a tag twice is a no-op and not a
    /// failure.
    static func apply(
        _ raw: String, toPost postID: String, session: AppSession
    ) async -> Outcome {
        let typed = segments(raw)
        guard !typed.isEmpty else { return .nothingTyped }
        do {
            // 13i-d U5: the NOTE's wing's vocabulary — a typed path resolves
            // (and mints) there, never in another library (R-13ia-1).
            let (live, wing) = try await session.database.read { db in
                let wing = try Queries.effectiveWing(db, ofPost: postID) ?? ""
                return (try Queries.allTags(db, wingID: wing), wing)
            }
            guard let plan = plan(segments: typed, live: live) else { return .nothingTyped }
            try await session.runner.run { [plan, postID] ops in
                guard let leafID = try createMissing(plan, ops: ops, wingID: wing)
                else { return }
                do {
                    _ = try ops.applyTag(leafID, toPost: postID)
                } catch OperationError.alreadyTagged {
                    // Already wearing it — typing it again is a no-op,
                    // never an error.
                }
            }
            return .applied(plan.leafPath)
        } catch {
            return .refused(error)
        }
    }
}
