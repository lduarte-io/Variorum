//
//  WriteTakesPanel.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R87): the Phase 7 FanPanel is
//  RETIRED — this is Write's take machinery, scoped to ONE block, wearing
//  the SAME v2 card grammar as the Takes tab (one takes language in the
//  whole app): editable panes (the live editor migrates), the 3pt
//  "✓ chosen" bar, the growth doors (minting never chooses — R90; the
//  explicit blank-and-choose door beside them), the take lifecycle
//  (archive/lock/delete, refusals speaking), archived takes visible with
//  their way back, and the R84 note on journal-shaped posts.
//
//  **P39b (the pre-13u round, Act 2's sweep; fixed at 13u2 UNIT D) — THIS
//  FILE MOVED, and the move IS the fix.** It lived in `Features/Editor/` and
//  constructed a `TakesViewModel` at its `init` — a feature CONSTRUCTING a
//  sibling feature's view model, which is lifecycle ownership and exactly
//  what the cross-feature rule forbids after its 2026-08-30 refinement. The
//  sweep measured 57 candidate sites across the app and found two real
//  violations; this is the second.
//
//  The file belongs HERE by its own first paragraph: it is take machinery
//  wearing the Takes tab's card grammar, over the Takes tab's view model.
//  With it in the Takes feature, the construction is a feature building its
//  OWN model, and what the Editor does — presenting this view in a sheet —
//  is the thing the refined rule explicitly blesses: *"A view RENDERING a
//  sibling's view is legal composition, not a violation."*
//
//  **The literal remedy P39b sketched — "RootView constructs, features
//  receive" — was measured and rejected, and the measurement is the reason:**
//  `EditorView` is constructed at FIVE sites in FOUR features (the post
//  detail, Canvas, the book view, the book spread ×2) and at none of them by
//  `RootView`, so threading a `TakesViewModel` factory down to this sheet
//  would have touched four surfaces to relocate one `init` — and the model's
//  life is the SHEET's, which is what `@State`'s `init(initialValue:)` is
//  for. Moving the file removes the violation instead of moving it.
//
//  ZERO behaviour change: no line of this view's body was touched and every
//  pin that names it rides unmodified.
//

import GRDB
import SwiftUI
import VariorumCore

struct WriteTakesPanel: View {
    let session: AppSession
    let postID: String
    let blockID: String
    @State private var model: TakesViewModel
    @State private var archived: [Variant] = []
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
    }

    private let column = TakesColumn(id: "write-panel-main", kind: .main)

    /// The registry ids this panel renders INLINE (13b Stage 3, 3D — the
    /// `.surface` door; walk-asserted): the archived list's Unarchive.
    /// **…and, since the post-13l polish round (ledger row 14 / F1), the four
    /// acts every card's ⋯ menu has rendered since Phase 7.** They were
    /// undeclared the whole time, which is exactly why the drift F1 went
    /// looking for was invisible: this panel carried Archive · Label · Lock ·
    /// Delete and the Takes board's cards carried the first two, and no walk
    /// could see it.
    static let surfaceCapabilities: [CapabilityID] = [
        .unarchiveTake, .archiveTake, .labelTake, .lockTake, .deleteTake,
    ]

    init(session: AppSession, postID: String, blockID: String) {
        self.session = session
        self.postID = postID
        self.blockID = blockID
        _model = State(initialValue: TakesViewModel(session: session, postID: postID))
    }

    private var slot: Queries.RenderedBlock? {
        model.projection.slots.first { $0.blockID == blockID }
    }

    private var fan: [Variant] {
        model.projection.fans[blockID] ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Takes — block \(String(blockID.prefix(8)))")
                    .font(.headline)
                Spacer()
                Button("Open Takes mode") {
                    // 13b 1b: composed routing (P-4) — and the ring lands
                    // bloomed on this block over there. A refused switch
                    // clears the parking (the round-1 MAJOR's half-a
                    // pattern); `requestMode` speaks the refusal itself.
                    session.commandRouter.pendingTakesLanding =
                        .bloom(postID: postID, blockID: blockID)
                    if !session.commandRouter.requestMode(.takes, postID: postID) {
                        session.commandRouter.pendingTakesLanding = nil
                    }
                    dismiss()
                }
                .help("The full board — every block's takes at once (⌘2)")
                // 13s-b U2: step 6's second half ("then Open Takes mode").
                .tourAnchor(.panelOpenTakesMode, cornerRadius: 6)
                Button("Close") { dismiss() }
            }
            if model.isJournalShaped {
                // R84's journal-entry note, its S5 half only — the Fragments
                // clause left with the bridge (2026-09-04; PROVISIONAL
                // wording, QUESTIONS #89).
                Text("Sync conflicts can add takes here; nothing is lost — "
                    + "choose what the entry shows.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // The post-13l polish round, batch 5 (routed flag 2): a receipt is
            // not a refusal. This slot painted `tokens.accent` whatever it
            // said — and in the TERMINAL voice `accent` and `chosen` are the
            // same hex, so every board receipt AND every board refusal wore
            // the colour the "✓ chosen" mark wears. The class is the model's
            // now, decided where the message is produced.
            if let status = model.status {
                Text(status.text)
                    .font(.caption)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if model.projection.sealed {
                Text("Sealed note — takes are viewable; choosing and new takes are frozen.")
                    .font(.caption)
                    .foregroundStyle(tokens.muted)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if let slot {
                        ForEach(fan, id: \.id) { take in
                            card(take: take, slot: slot)
                        }
                        growthDoors(slot: slot)
                        if !archived.isEmpty {
                            Text("archived takes")
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .padding(.top, 6)
                            ForEach(archived, id: \.id) { take in
                                archivedCard(take: take)
                            }
                        }
                    } else {
                        Text("This block is no longer in the note.")
                            .foregroundStyle(tokens.muted)
                    }
                }
            }
        }
        .padding(12)
        .frame(minWidth: 560, minHeight: 360)
        .background(tokens.surface)
        .task {
            await model.start()
        }
        .task { await loadArchived() }
        .onChange(of: model.projection) { _, _ in
            Task { await loadArchived() }
        }
        .sheet(item: Binding(
            get: { model.takeLabelRequest },
            set: { model.takeLabelRequest = $0 })
        ) { request in
            TakeLabelSheet(currentLabel: request.currentLabel) { label in
                Task { await model.setTakeLabel(request.variantID, label: label) }
            }
        }
        .onDisappear { model.teardown() }
    }

    // MARK: - Cards (the one grammar)

    private func card(take: Variant, slot: Queries.RenderedBlock) -> some View {
        let isChosen = take.id == slot.variantID
        let key = TakesViewModel.PaneKey(
            columnID: column.id, blockID: blockID, variantID: take.id)
        return TakeCardFrame(isChosen: isChosen, tokens: tokens) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if let label = take.label {
                        Text(label).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    if isChosen {
                        Text("✓ chosen").font(tokens.small).foregroundStyle(tokens.chosen)
                    }
                    if take.locked {
                        Text("locked").font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    Spacer()
                    Button("✓") {
                        Task { await model.choose(blockID: blockID, variantID: take.id) }
                    }
                    .controlSize(.mini)
                    .disabled(isChosen)
                    .help("Choose this take — the note shows it (everywhere); ⌘⏎")
                    // 13u3 UNIT H: the four rows this panel has carried since
                    // Phase 7 are a COMPONENT now (`TakeCardMenu`), so the
                    // Takes board's live cards render the same list rather
                    // than a second copy of it — her F1 rule made structural.
                    // The chrome is this panel's own, unchanged to the byte;
                    // the one word that moved is the label row, which said
                    // "Label…" here and "Label take…" on the card context
                    // menu, i.e. the two "matching" menus did not agree on it.
                    TakeCardMenu(acts: TakeCardActs(
                        locked: take.locked,
                        archive: { Task { await model.archiveTake(take.id) } },
                        // 13b Stage 3 (3D — N6): the label door rides
                        // Write's panel too (one grammar everywhere).
                        label: { model.requestTakeLabel(variantID: take.id) },
                        toggleLock: {
                            Task { await model.setTakeLocked(take.id, locked: !take.locked) }
                        },
                        delete: { Task { await model.deleteTake(take.id) } }))
                }
                PaneSurfaceView(
                    text: model.liveText(take),
                    isLive: model.isPaneLive(key),
                    tokens: tokens,
                    indicator: indicator,
                    role: "panel", variantID: take.id,
                    onFocusRequest: { model.focus(key) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) })
            }
        }
    }

    private func archivedCard(take: Variant) -> some View {
        TakeCardFrame(isChosen: false, tokens: tokens) {
            HStack(spacing: 8) {
                Text(take.workingText.isEmpty
                     ? "(empty take)" : String(take.workingText.prefix(120)))
                    .font(tokens.small)
                    .lineLimit(2)
                    .foregroundStyle(tokens.muted)
                Spacer()
                Button("Unarchive") { Task { await model.unarchiveTake(take.id) } }
                    .controlSize(.mini)
                Button(TakeCardMenuCopy.deleteTake, role: .destructive) {
                    Task { await model.deleteTake(take.id) }
                }
                .controlSize(.mini)
            }
        }
    }

    /// The growth doors — minting never chooses (R90); the new card gets
    /// the ring instantly; the explicit as-chosen door sits beside them.
    private func growthDoors(slot: Queries.RenderedBlock) -> some View {
        HStack(spacing: 8) {
            Button("＋ new take (branch)") {
                guard let from = slot.variantID else { return }
                Task {
                    if let take = await model.branchTake(blockID: blockID, from: from) {
                        model.focus(.init(columnID: column.id, blockID: blockID, variantID: take.id))
                    }
                }
            }
            .disabled(slot.variantID == nil)
            .help("A new take that starts as a copy of what's shown (⌘T)")
            // 13s-b U2: step 5's door, once the panel is up.
            .tourAnchor(.panelNewTake, cornerRadius: 5)
            Text("·").foregroundStyle(tokens.faint)
            Button("＋ blank take") {
                Task {
                    if let take = await model.newBlankTake(blockID: blockID) {
                        model.focus(.init(columnID: column.id, blockID: blockID, variantID: take.id))
                    }
                }
            }
            .help("A genuinely different take, from scratch — NOT chosen until you ✓ it (⌥⌘T)")
            Text("·").foregroundStyle(tokens.faint)
            Button("＋ blank & choose") {
                // MINOR-D2: the panel names its OWN column — with no pane
                // focused the reveal used to fall to "takes-main", a
                // column this panel never renders, and the ring vanished.
                Task {
                    await model.newBlankTakeAsChosen(
                        blockID: blockID, preferredColumnID: column.id)
                }
            }
            .help("The power gesture: a blank take that becomes the note's text right now (⇧⌥⌘T)")
        }
        .buttonStyle(.plain)
        .font(tokens.small)
        .foregroundStyle(tokens.muted)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
        // states its own line policy, so its IDEAL width can never be a
        // wrapped one (the b6dae25 class's window-sizing hazard).
        // On the row, not each button: the three doors and their two ·
        // separators are ONE dashed line and wrap together or not at all.
        .lineLimit(1)
        .fixedSize()
    }

    private func loadArchived() async {
        archived = (try? await session.database.read { [blockID] db in
            try Variant
                .filter(Column("block_id") == blockID
                        && Column("deleted_at") == nil
                        && Column("status") == VariantStatus.archived.rawValue)
                .order(Column("fan_position"), Column("id"))
                .fetchAll(db)
        }) ?? []
    }
}
