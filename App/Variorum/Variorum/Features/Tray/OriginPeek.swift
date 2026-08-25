//
//  OriginPeek.swift
//  Variorum (Mac)
//
//  Phase 13j, batch 3 (J3) — **THE LINEAGE DOOR'S FINAL FORM.**
//
//  Her ruling (sitting round 4, verbatim): *"I think context menu only. maybe
//  also within the bottom bar? or is that what you mean by context item? I
//  honestly feel like this will rarely matter to people so it shouldn't be
//  part of the daily chrome, just accessible if needed."* — and round 5's
//  amendment: *"I also think it should be added to the bottom bar note block
//  where you see the history, since it is lineage."*
//
//  So the door lives in exactly three summoned places — the block's
//  right-click menu, ⌘K, and the History face — and NOWHERE ambient: no hover
//  glyph, no bottom-bar button. What it opens is this: a READ-ONLY PEEK of
//  the original, its takes visible, with exactly two actions —
//  **Put back in note** and **Open this note's tray**.
//
//  ── WHAT THIS REPLACES ───────────────────────────────────────────────────
//  13f W10b gave the door its first landing: a navigation to Library →
//  Archived & Deleted → Unplaced blocks. Her round-2 ruling REMOVED that room
//  ("what is that cursed table of lost hopes and dreams?"), so batch 2
//  repointed the door at the note's own tray as an honest BRIDGE and said in
//  its own comment that J3 owned the final form. This is that form; the tray
//  is now the peek's SECOND action rather than its destination, which is
//  exactly what the ruling asked for — you see the original itself, and the
//  tray is one click away if you want the whole list.
//
//  Read-cheap tier only (P3): the takes render as plain text. Nothing in a
//  peek is ever a live editor — this is a look at something standing to one
//  side, not a place to write.
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

/// **The ONE place the lineage door's words are spelled** (the `TrayPath`
/// pattern, and for its reason: the context row, the palette row, the History
/// face's row and the peek's own heading must all say the same thing about
/// the same fact, or they drift into four different stories).
nonisolated enum OriginPeekCopy {
    /// The palette's row and the registry's verb: the act with no target in
    /// hand, so it cannot name the act that released the original.
    static let genericVerb = "See the Original This Came From"

    /// The context row's words, which DO have a target — her ruled shape,
    /// "See original from divide…" / "…from merge…". An origin op the door
    /// has no word for falls back to the generic sentence rather than
    /// inventing one (`origin_op` is nullable and carries five values today).
    static func doorVerb(op: String?) -> String {
        guard let act = actWord(op) else { return "See the original this came from\u{2026}" }
        return "See original from \(act)\u{2026}"
    }

    /// The History face's quiet lineage row — "From a divide on 12 Aug — the
    /// original is preserved".
    static func lineageRow(op: String?, at: String) -> String {
        let act = actWord(op).map { "a \($0)" } ?? "an earlier change"
        guard let when = stamp(at) else {
            return "From \(act) — the original is preserved"
        }
        return "From \(act) on \(when) — the original is preserved"
    }

    /// The peek's own heading, same fact in the same words.
    static func heading(op: String?, at: String) -> String {
        lineageRow(op: op, at: at)
    }

    static let putBackVerb = "Put back in note"
    static let openTrayVerb = "Open this note's tray"

    /// What the peek says about itself, once, at the top: the original is not
    /// deleted and never was — the W preserves it whole and stands it to one
    /// side (OverallModel §7). Saying so is the whole point of the surface;
    /// her sitting question was "how do I even see the original one?"
    static let explainer =
        "This block was kept WHOLE and set aside — not deleted. It's waiting "
        + "here with its takes, and Put back returns it to the note beside "
        + "the blocks it became."

    /// The refusal for the door invoked where the block has no such original
    /// (the palette's context-blind row — fire-and-speak, P-2).
    static let noOriginHere =
        "This block wasn't divided or merged out of another one — there's no "
        + "original standing behind it."

    /// The original went somewhere while the peek was open (it was put back
    /// from the tray in another pane, or a successor moved). One honest line
    /// rather than an empty panel.
    static let originGone =
        "This original is no longer waiting here — it may already be back in "
        + "the note."

    private static func actWord(_ op: String?) -> String? {
        switch op {
        case "divide": return "divide"
        case "merge": return "merge"
        case "extract": return "extract"
        default: return nil
        }
    }

    /// The stored canonical stamp through the ONE parser, never re-parsed by
    /// hand; an unparseable stamp renders no date at all rather than raw ISO
    /// (`TrayRowPreview.stampText`'s rule).
    ///
    /// **DATE ONLY, deliberately** — and the capture is why: with the time of
    /// day in it, the lineage row read "From a merge on aug 18, 2026 at 6:30
    /// am — the original is p…", i.e. the sentence's own point fell off the
    /// end to make room for a minute nobody needs. A divide is a thing that
    /// happened on a DAY. The tray's rows keep their time (`TrayRowPreview
    /// .stampText`): "when did I delete this" is a same-day question.
    static func stamp(_ raw: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: raw) else { return nil }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

/// A surface's pending request to peek at a released original — the
/// `TrayRequest` shape, raised by a view model, presented by its view.
///
/// It carries the whole `UnplacedOrigin` rather than an id because the peek's
/// heading names WHAT released the block and WHEN, and the door already holds
/// both facts (they ride the same projection the door's enablement reads).
nonisolated struct OriginPeekRequest: Identifiable, Equatable, Sendable {
    let postID: String
    let origin: Queries.UnplacedOrigin
    var id: String { "\(postID)#\(origin.blockID)" }
}

@MainActor
@Observable
final class OriginPeekModel {
    @ObservationIgnored private let session: AppSession
    let postID: String
    let origin: Queries.UnplacedOrigin

    /// The original's own takes, read-cheap and read-only.
    private(set) var takes: [Variant] = []
    private(set) var loaded = false
    private(set) var statusMessage: String?
    /// True once Put back has landed it — the panel's two actions retire
    /// (there is nothing left to put back) and the receipt stands.
    private(set) var placed = false
    /// The tray, opened ON TOP of the peek (a sheet over a sheet, so closing
    /// it returns here rather than to nothing).
    var traySheetShown = false

    init(session: AppSession, postID: String, origin: Queries.UnplacedOrigin) {
        self.session = session
        self.postID = postID
        self.origin = origin
    }

    func start() async {
        do {
            let fan = try await session.database.read { [origin] db in
                try Queries.blockFan(db, blockID: origin.blockID)
            }
            takes = fan
            loaded = true
        } catch {
            statusMessage = String(describing: error)
            loaded = true
        }
    }

    /// **Put back in note** — the SAME composition the tray's originals
    /// section runs, through the one shared brain, so the two doors onto one
    /// act cannot drift on where the block lands or what the receipt says.
    func putBack() async {
        do {
            statusMessage = try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: origin.blockID)
            placed = true
        } catch let error as OperationError {
            statusMessage = TrayRefusalCopy.message(for: error)
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// **Open this note's tray** — the batch-2 bridge, kept and demoted to
    /// exactly what her ruling made it: the second action, with the
    /// original's row marked (`TrayRequest.revealBlockID` is that seam, and
    /// this is what keeps it earning its place).
    func openTray() {
        traySheetShown = true
    }
}

struct OriginPeekPanel: View {
    let session: AppSession
    @State private var model: OriginPeekModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, request: OriginPeekRequest, model: OriginPeekModel? = nil
    ) {
        self.session = session
        _model = State(initialValue: model
            ?? OriginPeekModel(
                session: session, postID: request.postID, origin: request.origin))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(
                    OriginPeekCopy.heading(op: model.origin.originOp, at: model.origin.at)))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                Spacer()
                Button("Close") { dismiss() }
            }
            Text(tokens.chromeLabel(OriginPeekCopy.explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let status = model.statusMessage {
                Text(status)
                    .font(tokens.small)
                    // Ledger row 6's second half, one file over: this slot
                    // already told a receipt from a refusal (`placed`), but
                    // the refusal's colour was a literal `.red` in a themed
                    // surface. Same token pair as the tray's now.
                    .foregroundStyle(model.placed ? tokens.muted : tokens.accent)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            if model.loaded && model.takes.isEmpty {
                Text(tokens.chromeLabel(OriginPeekCopy.originGone))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            List(model.takes, id: \.id) { take in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(tokens.chromeLabel(
                            take.label ?? (take.status == .archived ? "archived take" : "take")))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                        Spacer()
                    }
                    // Read-cheap by construction: a `Text`, never a pane (P3).
                    Text(take.workingText.isEmpty ? "(empty take)" : take.workingText)
                        .font(tokens.body)
                        .foregroundStyle(
                            take.workingText.isEmpty ? tokens.muted : tokens.ink)
                        .textSelection(.enabled)
                        .lineLimit(8)
                }
                .padding(.vertical, 2)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            HStack(spacing: 8) {
                Button(OriginPeekCopy.putBackVerb) {
                    Task { await model.putBack() }
                }
                .disabled(model.placed)
                .help("Returns this block to the note, beside the blocks it became")
                Button(OriginPeekCopy.openTrayVerb) { model.openTray() }
                    .help("The whole list: what this note has deleted, and every "
                        + "original it is holding")
                Spacer()
            }
        }
        .padding(12)
        .frame(minWidth: 460, minHeight: 320)
        .background(tokens.surface)
        .task { await model.start() }
        // The tray OVER the peek (her second action): closing it comes back
        // here rather than to nothing, which is what makes "open the tray"
        // an aside instead of a departure.
        .sheet(isPresented: $model.traySheetShown) {
            TrayPanel(
                session: session, postID: model.postID,
                revealBlockID: model.origin.blockID)
        }
    }
}
