//
//  BlockPastSection.swift
//  Variorum (Mac)
//
//  Phase 13j, batch 3 — **THE BLOCK'S PAST, INSIDE THE HISTORY FACE.**
//
//  Two rulings meet here, and they meet in the same place on purpose:
//
//  · **J3, as amended at sitting round 5.** Her words: *"I also think it
//    should be added to the bottom bar note block where you see the history,
//    since it is lineage."* So a block with a released original carries a
//    quiet lineage row in its History face, opening the same peek the
//    right-click item opens. The face is SUMMONED (behind the existing
//    History toggle), which is what makes this compose with her round-4
//    not-daily-chrome criterion instead of contradicting it.
//
//  · **The round-5 deleted-take ruling.** Her word was *"YES — the FULL
//    uniform story"*: deleted takes get quiet rows in the block's History
//    face with Put back, *"beside commits and the lineage row — one 'past'
//    surface per block"*. That sentence is this file's whole design.
//
//  ONE component, composed by BOTH history hosts — Write's inline
//  `CommitHistoryView` and the Takes bar's history sheet — because the
//  alternative is two renderings of one past that drift (R118's letter: Write
//  is never the privileged surface).
//
//  **NO COUNTDOWN**, deliberately: the 30-day Trash clock is J1's, batch 6.
//  Showing "N days left" before the clock exists is the copy-truth defect
//  class this phase is about. Archived takes are untouched here — they keep
//  their own listing on the take boards, and the archived/Trash distinction
//  (kept forever vs 30 days) is J10's chapter to teach.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **The words the block's past speaks**, in one home (the `TrayPath`
/// pattern). The lineage row's own sentence lives in `OriginPeekCopy`, where
/// the peek's heading reads it too.
nonisolated enum BlockPastCopy {
    static let deletedTakesHeader = "Deleted takes"
    static let putBackVerb = "Put back"
    static let seeOriginVerb = "See original"

    /// The receipt after a deleted take comes back. It names the fan,
    /// because that is where she will look for it.
    static let takeRestored = "Take put back — it's in this block's fan again."

    /// **The archived edition** (13j ladder A round 1, finding A3): the
    /// restore is an exact flip (#68(b), ruled), so a take that was ARCHIVED
    /// when it was deleted comes back archived — into the archived listing,
    /// not the fan — and the one receipt above was lying for that row. The
    /// door reads `restoreVariant`'s own returned status and says which.
    static let takeRestoredArchived =
        "Take put back — it was archived, so it's in this block's archived "
        + "takes, not the fan. Unarchive it there to bring it back."

    static func restored(_ status: VariantStatus) -> String {
        status == .archived ? takeRestoredArchived : takeRestored
    }

    /// The Put-back button's help, worded to the ROW's status (the row is a
    /// `Variant`, so it knows): "its place in the fan" was false for an
    /// archived take.
    static func putBackHelp(_ take: Variant) -> String {
        take.status == .archived
            ? "Puts this take back among the block's archived takes, exactly "
                + "as it was — it was archived when it was deleted"
            : "Puts this take back in the block's fan, exactly as it was — "
                + "its label, its place in the fan and its savepoints all "
                + "come back with it"
    }

    /// A deleted take's row label: its own label where it has one, else the
    /// take's first line (`TrayRowPreview`'s rule, which the tray's rows
    /// already speak).
    ///
    /// The empty case says **take**, not "block" — caught by the capture,
    /// where an empty deleted take rendered as "(empty block)" because
    /// `TrayRowPreview.line` was written for the tray's BLOCK rows and its
    /// fallback names that noun. A row in a fan that calls itself a block is
    /// the same small dishonesty this phase is about.
    static let emptyTake = "(empty take)"

    static func rowLabel(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return label }
        let line = TrayRowPreview.line(take.workingText)
        return line == TrayRowPreview.emptyBlock ? emptyTake : line
    }
}

@MainActor
@Observable
final class BlockPastModel {
    @ObservationIgnored private let session: AppSession
    let blockID: String

    private(set) var past = Queries.BlockPast()
    private(set) var statusMessage: String?

    init(session: AppSession, blockID: String) {
        self.session = session
        self.blockID = blockID
    }

    /// Held only while the face is on screen — the view's `.task` owns the
    /// lifetime, so the observation of `variant` (the one table autosave
    /// writes) never stands over a typing burst. See
    /// `AppDatabase.observeBlockPast` for the full reasoning.
    func start() async {
        do {
            for try await value in session.database.observeBlockPast(blockID, now: session.now) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// Internal so tests drive the face deterministically (the
    /// `TrayViewModel.adopt` seam).
    func adopt(_ value: Queries.BlockPast) {
        past = value
    }

    var isEmpty: Bool { past.isEmpty }

    /// Put a DELETED take back — `restoreVariant`, the recovery-door class
    /// (no undo entry: the door IS the recovery). Refusals diagnose through
    /// the tray's own copy, which already words the seal (P-2, the J8
    /// doctrine).
    func putBackTake(_ variantID: String) async {
        statusMessage = nil
        do {
            // A3: the receipt reads the op's own answer — an exact flip can
            // revive a take ARCHIVED (it was archived when it was deleted),
            // and that take lands in the archived listing, not the fan.
            let status = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            statusMessage = BlockPastCopy.restored(status)
        } catch let error as OperationError {
            statusMessage = TrayRefusalCopy.message(for: error)
        } catch {
            statusMessage = String(describing: error)
        }
    }
}

/// The quiet region under a block's savepoints: its lineage row, and the
/// takes it has deleted.
struct BlockPastSection: View {
    let model: BlockPastModel
    let tokens: VoiceTokens
    /// Raised when a lineage row is clicked — the host turns it into its own
    /// peek request (composition, never a feature-to-feature call).
    let onSeeOrigin: (Queries.UnplacedOrigin) -> Void

    /// The registry ids this section renders (13b 3D's `.surface` shape:
    /// acts whose door is an inline row on a panel). Declared ONCE here
    /// rather than in each host, the `MarkdownActs.contextMenuCapabilities`
    /// precedent — the declaration lives with the builder, so both history
    /// faces are covered by construction.
    static let surfaceCapabilities: [CapabilityID] = [.showOriginBlock, .restoreTake]

    var body: some View {
        // 13j ladder A round 1, finding A1 (BLOCKER — fixed by the reviewer,
        // cross-model flow): the starting `.task` used to sit INSIDE the
        // `if !model.isEmpty` conditional — and `past` begins empty, so the
        // task that populates it could never attach: the section was dead by
        // construction on every real host, green only through the `adopt`
        // test seam. The task now rides this always-present (zero-size when
        // empty) container, so mounting the section starts its observation.
        //
        // The GROUP form, deliberately — not host-side `start()` (the batch-3
        // implementer's constraint, agreed): `TakesBottomBar` holds its
        // `pastModel` in `@State` and never clears it on sheet dismissal, so
        // a host-driven start would leave the `variant` observation running
        // after the sheet closes. The view-side task cancels the moment the
        // section leaves the hierarchy, which is exactly the
        // held-only-while-on-screen property (P1) the file promises.
        VStack(alignment: .leading, spacing: 0) {
            if !model.isEmpty {
                content
            }
        }
        .task(id: model.blockID) { await model.start() }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let status = model.statusMessage {
                Text(tokens.chromeLabel(status))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
            }
            ForEach(model.past.origins) { origin in
                HStack(spacing: 8) {
                    Text(tokens.chromeLabel(
                        OriginPeekCopy.lineageRow(op: origin.originOp, at: origin.at)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        // Two lines, not one: the sentence's point is its
                        // TAIL ("the original is preserved"), and at a
                        // narrow pane width a one-line limit truncated
                        // exactly that (caught by the capture). The
                        // `lineLimit` itself stays — chrome text always
                        // carries one (P-8, the b6dae25 class).
                        .lineLimit(2)
                    Button(BlockPastCopy.seeOriginVerb) { onSeeOrigin(origin) }
                        .controlSize(.small)
                        .help("Look at the block this one came out of — it was kept "
                            + "whole and set aside, not deleted")
                    Spacer(minLength: 8)
                }
            }
            if !model.past.deletedTakes.isEmpty {
                Text(tokens.chromeLabel(BlockPastCopy.deletedTakesHeader))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                ForEach(model.past.deletedTakes, id: \.id) { take in
                    HStack(spacing: 8) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                        if let deletedAt = take.deletedAt {
                            Text(tokens.chromeLabel(
                                "deleted "
                                + deletedAt.formatted(date: .abbreviated, time: .shortened)))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 8)
                        Button(BlockPastCopy.putBackVerb) {
                            Task { await model.putBackTake(take.id) }
                        }
                        .controlSize(.small)
                        // A3: the help words to the row's status — "its
                        // place in the fan" was false for an archived take.
                        .help(BlockPastCopy.putBackHelp(take))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
