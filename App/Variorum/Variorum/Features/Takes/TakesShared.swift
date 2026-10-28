//
//  TakesShared.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R86): the Takes/Lenses tab split
//  pulled the cell grammar both boards share into one home — a cell is the
//  column's resolved take, read-cheap until clicked, the ONE live editor
//  migrating on click (P3), with the explicit ✓ and the diverge/diff doors
//  on the context menu. The boards differ in COMPOSITION (article + fans vs
//  column slots), never in cell semantics.
//

import SwiftUI
import VariorumCore

/// A diff sheet's payload (shared by both boards).
struct TakesDiffPresentation: Identifiable {
    let leftTitle: String
    let rightTitle: String
    let left: String
    let right: String
    let id = UUID()
}

/// **The empty note's face on the takes-shaped boards** (17o batch c,
/// ledger row 15 — her punchlist 10: *"you should be able to make a first
/// block there"*, image 3).
///
/// Both boards showed exactly one door out of an empty note — "Start
/// writing (Write mode)" — and the article's own `＋ new block` door was
/// gated on `!slots.isEmpty`, i.e. it appeared only once a block already
/// existed. So the ONE surface where a first block is wanted was the one
/// place it could not be made. The capability itself was never missing
/// (`.addBlockAtEnd` is native to the take family and is on the bottom bar
/// and the menu); the DOOR here was.
///
/// The face is shared rather than copied because both boards owe her the
/// same answer, and two copies of an empty state is how they drift.
enum TakesEmptyState {
    enum Door: Hashable {
        case newBlock
        case write
    }

    /// What both boards render, in this order. A board that renders
    /// something else is the drift this enum exists to prevent.
    static let doors: [Door] = [.newBlock, .write]

    /// J8's copy-truth: the old line ("blocks are born by typing") stopped
    /// being the whole truth the moment a door here mints one.
    static let line = "Nothing here yet — make the first block here, or start writing."
    static let newBlockVerb = "＋ new block"
    static let newBlockHelp =
        "The note's first block, right here — it takes the ring, so you can type into it"
    static let writeVerb = "Start writing (Write mode)"
}

#if DEBUG
/// The row-15 door oracle: which doors the empty state actually RENDERED.
/// A pin resets it, mounts a board on an empty note, and reads it — the
/// only way to assert a SwiftUI door's presence on a whole board, whose
/// buttons are not `NSView`s (KnownIssues' rig row; the `LensesGeometry`
/// DEBUG pattern).
@MainActor
enum TakesEmptyStateDoors {
    static var rendered: Set<TakesEmptyState.Door> = []

    static func record(_ door: TakesEmptyState.Door) { rendered.insert(door) }

    static func reset() { rendered = [] }
}
#endif

/// The empty note's card — the line and its doors, one face for Takes and
/// Lenses. The board supplies the acts and its own framing.
struct TakesEmptyStateView: View {
    let tokens: VoiceTokens
    let onNewBlock: () -> Void
    let onWrite: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(tokens.chromeLabel(TakesEmptyState.line))
                .font(tokens.body)
                .foregroundStyle(tokens.muted)
            ForEach(TakesEmptyState.doors, id: \.self) { door in
                switch door {
                case .newBlock:
                    // The same dashed grammar the article's end-of-note door
                    // wears, so the act reads as the one she already knows.
                    Button(TakesEmptyState.newBlockVerb, action: onNewBlock)
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    tokens.faint,
                                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                        // P-8: a chrome `fixedSize` text always carries a
                        // `lineLimit` (the b6dae25 class).
                        .lineLimit(1)
                        .fixedSize()
                        .help(TakesEmptyState.newBlockHelp)
                        .recordEmptyStateDoor(.newBlock)
                case .write:
                    Button(tokens.chromeLabel(TakesEmptyState.writeVerb), action: onWrite)
                        .buttonStyle(
                            VoicedButtonStyle(tokens: tokens, role: .primary, font: tokens.mono))
                        .recordEmptyStateDoor(.write)
                }
            }
        }
    }
}

extension View {
    /// The DEBUG oracle write (a no-op outside DEBUG).
    @ViewBuilder
    func recordEmptyStateDoor(_ door: TakesEmptyState.Door) -> some View {
        #if DEBUG
        self.onAppear { TakesEmptyStateDoors.record(door) }
        #else
        self
        #endif
    }
}

#if DEBUG
/// **R-Q2's oracle: what CHROME WORDS a take cell draws OVER its pane.**
///
/// Her ruling (17p batch a, row 2) is that there are none — a take pane shows
/// the take's own text and nothing else, so an empty block reads as the empty
/// line Write already renders. A pin cannot see that any other way: a SwiftUI
/// `Text` is drawn rather than mounted as an `NSView` (KnownIssues' rig row),
/// and a hosted board builds NO accessibility tree in the test host (measured
/// at this batch: exactly one element, the hosting view, with no children).
///
/// So the cell DECLARES what it draws, on every render, and the pin reads the
/// declaration. The list is empty today and the call site is the place a
/// future overlay would have to pass through.
@MainActor
enum TakesCellChrome {
    /// variantID → the chrome words drawn over that cell's pane.
    static var overlayWords: [String: [String]] = [:]

    static func record(_ variantID: String, _ words: [String]) {
        overlayWords[variantID] = words
    }

    static func reset() { overlayWords = [:] }
}
#endif

extension View {
    /// The DEBUG oracle write (a no-op outside DEBUG).
    @ViewBuilder
    func recordCellChrome(_ variantID: String, _ words: [String]) -> some View {
        #if DEBUG
        self.onAppear { TakesCellChrome.record(variantID, words) }
        #else
        self
        #endif
    }
}

/// One cell: the column's resolved take for a slot. Rendering + gestures
/// only — every rule lives in the model.
struct TakesCellView: View {
    let model: TakesViewModel
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): the editing indicator, pushed beside the
    /// tokens — the cell decides nothing, it carries the appearance down to
    /// the ONE component that does.
    let indicator: EditingIndicatorStyle
    let slot: Queries.RenderedBlock
    let column: TakesColumn
    let tinted: Bool
    /// Surface identity for tests/soaks ("article" on the takes board's
    /// main cell; the default elsewhere).
    var role: String = "cell"
    /// 13f W7: forwarded to the pane, defaulted OFF so every host but the
    /// takes board's article column reads exactly as before.
    var caretToEndToken: Int = 0
    /// 13e E3 (her A18): the ⌘-click claim, set ONLY by the takes board's
    /// article cell — nil on the Lenses board and anywhere else, so no other
    /// composition's ⌘-click behaviour moves. The `Bool` is 13e E2's: ⇧ was
    /// held too, i.e. extend the run rather than toggle this one.
    var onCommandClick: ((Bool) -> Bool)?
    /// 18l-c U7: the find's face for the take this cell shows — set ONLY by
    /// the Takes board's article cell (nil on the Lenses board and anywhere
    /// else, so no other composition's pane moves).
    var findFace: PaneFindFace?
    let onDiff: (TakesDiffPresentation) -> Void

    var body: some View {
        if let resolved = model.resolvedTake(column: column, slot: slot) {
            let key = TakesViewModel.PaneKey(
                columnID: column.id, blockID: slot.blockID, variantID: resolved.variantID)
            PaneSurfaceView(
                text: resolved.text,
                isLive: model.isPaneLive(key),
                tokens: tokens,
                indicator: indicator,
                role: role, variantID: resolved.variantID,
                onFocusRequest: { model.focus(key) },
                // The sanity pass's RAISE-1: the click's place, reported AFTER
                // the ring moved — the click's own selection change arrived
                // while the ring was elsewhere and was rightly dropped.
                onClickPlace: { offset in
                    model.notePaneSelection(
                        variantID: resolved.variantID,
                        range: NSRange(location: offset, length: 0))
                },
                onEdit: { model.paneEdited(variantID: resolved.variantID, newText: $0) },
                onCommandClick: onCommandClick,
                onSelectionChange: { range in
                    // The choreography's carried caret (13b 1b): what a
                    // fire-and-DO landing brings into Write.
                    model.notePaneSelection(variantID: resolved.variantID, range: range)
                },
                // 17o batch b (U-20): a pane taking the ring enters the note's
                // current block WHERE SHE WAS.
                caretOnGoingLive: model.caretLanding(forVariant: resolved.variantID),
                menuItems: { menuSpecs(resolved: resolved) },
                caretToEndToken: caretToEndToken,
                findFace: findFace)
                .background(tinted ? tokens.accent.opacity(0.12) : Color.clear)
                // **NOTHING is drawn over a take's pane** (17p batch a, row 2
                // — her ruling R-Q2, "no placeholder anywhere"): an empty
                // block in Takes is an empty LINE, exactly as Write renders
                // it. The `[]` is the whole face, declared so a pin can read
                // it, and this is the place any future overlay would have to
                // pass through.
                //
                // **This SUPERSEDES the FACE of Phase 13 batch 9's R103**, and
                // only the face. R103's substance stands and is pinned
                // elsewhere (`PaneTextAuthorityTests`, `TakesBoardSoakTests`):
                // a take deleted down to nothing KEEPS the block's own line —
                // the row, the pane and the ⑂+ badge are all still there. What
                // retires is the words that described it. They were written
                // for a take she had emptied on purpose; 18c's Return and
                // 17o's ＋ new block door made empty blocks EVERYDAY, so the
                // note greeted a block she had just made — and under the
                // editing indicator OFF, where a live pane draws no ring
                // (17o batch c, U-7), her caret sat in the middle of the
                // words. Her report: *"the invitation to write a block is
                // weird… I want it to return to what it used to look like."*
                .recordCellChrome(resolved.variantID, [])
                // **VX-227 — the cell's RENDER-REPORT** (the parked follow, the
                // architect's F2 ruling): this cell is ONE pane per block whose
                // key moves with what it shows, and a live pane never takes
                // projection text — so a follow onto a re-pointed cell may only
                // turn it live AFTER it has drawn its new take read-only. The
                // task runs once the render that drew this key is done (on
                // appear, and whenever the key changes); the model acts only
                // when it has a follow parked on exactly this key. A fact
                // reported, never a decision made here (P-3).
                .task(id: key) { model.paneRendered(key) }
        } else {
            Text("· · ·")  // a gap slot renders a gap, never crashes
                .foregroundStyle(tokens.muted)
        }
    }

    /// The take card's context menu (13b 1b, AD-4): right-clicking a pane
    /// used to show ONLY the stock text menu — the SwiftUI `.contextMenu`
    /// never fired inside the NSTextView. The Variorum vocabulary now
    /// renders through the pane surface's real menu path, above the
    /// standard edit items. Registry-declared: see
    /// `TakesCellView.contextMenuCapabilities`.
    private func menuSpecs(
        resolved: (variantID: String, text: String)
    ) -> [PaneTextView.MenuItemSpec] {
        // The take's own lock state, read off the projection the menu is
        // built from — the row must say which way it points (F1's letter,
        // and Write's panel's own wording).
        let lockedNow = model.projection.fans[slot.blockID]?
            .first { $0.id == resolved.variantID }?.locked ?? false
        var specs: [PaneTextView.MenuItemSpec] = [
            // R2-A: the cell KNOWS its column — on the Lenses host the
            // mint lands as THIS column's pick (the ring follows).
            .init(title: TakeCardMenuCopy.newTake) {
                Task {
                    await model.branchTakeRevealed(
                        blockID: slot.blockID, from: resolved.variantID,
                        preferredColumnID: column.id)
                }
            },
            .init(title: TakeCardMenuCopy.blankTake) {
                Task {
                    await model.newBlankTakeRevealed(
                        blockID: slot.blockID, preferredColumnID: column.id)
                }
            },
            .init(
                title: "✓ Choose this take (the note shows it)",
                enabled: slot.variantID != resolved.variantID
            ) {
                Task { await model.choose(blockID: slot.blockID, variantID: resolved.variantID) }
            },
            .init(title: "Diverge here (new take, this thread)") {
                Task {
                    await model.divergeHere(
                        columnID: column.id, blockID: slot.blockID,
                        fromVariantID: resolved.variantID)
                }
            },
            .init(title: TakeCardMenuCopy.archiveTake) {
                Task { await model.archiveTake(resolved.variantID) }
            },
            // 13b Stage 3 (3D — N6): the 3B `setTakeLabel` op's card door;
            // the bar hosts the sheet on both boards.
            .init(title: TakeCardMenuCopy.labelTake) {
                model.requestTakeLabel(variantID: resolved.variantID)
            },
            // **Ledger row 14 (F1): the grammar made uniform.** Write's takes
            // panel has carried Archive · Label · Lock · Delete on every
            // card's ⋯ since Phase 7; these cards carried the first two. Her
            // rule for this pass is that the card menus MATCH — so the other
            // two land here, on the same explicitly-named target the rows
            // above use (a right-click never moves the keyboard — 13k K6).
            .init(title: TakeCardMenuCopy.lockVerb(locked: lockedNow)) {
                Task {
                    await model.setTakeLocked(
                        resolved.variantID, locked: !lockedNow)
                }
            },
            .init(title: TakeCardMenuCopy.deleteTake) {
                // Takes do NOT confirm (13j's confirmation-consistency
                // principle, second clause): ⌥⌘Z is right there and the
                // block's History lists what went.
                Task { await model.deleteTake(resolved.variantID) }
            },
            // 13e E6 (her A21's clipboard half): the whole fan as text. The
            // target is named EXPLICITLY — a right-click never moves the
            // keyboard, so the routed target could name another card's block
            // (13k K6's lesson, same fix).
            .init(title: TakeCardMenuCopy.copyAllTakes) {
                Task { await model.copyAllTakes(blockID: slot.blockID) }
            },
            // 13e batch 3 (her A20/A21's second half — AR-1): the take↔block
            // pair, on the card that IS the take. Both name their target
            // explicitly, for the same right-click reason.
            .init(title: TakeCardMenuCopy.takeToBlockBelow) {
                Task {
                    await model.moveTakeIntoBlockBelow(
                        blockID: slot.blockID, variantID: resolved.variantID)
                }
            },
            .init(title: TakeCardMenuCopy.takesToBlocks) {
                Task { await model.turnTakesIntoBlocks(blockID: slot.blockID) }
            },
        ]
        // 13e E3 (her A18): the merge door for a ⌘-click selection, rendered
        // only where it can act — on the Takes board, with two or more blocks
        // picked (the `.diffAgainstChosen` per-target shape, P-2). The count
        // is in the row's words so the menu says what it will join.
        if model.host == .takes {
            let picked = model.selectedBlocksInOrder
            if picked.count >= 2 {
                specs.append(.init(
                    title: "\(CapabilityRegistry.capability(.mergeSelectedBlocks).verb) "
                        + "(\(picked.count))"
                ) {
                    Task { await model.mergeSelectedBlocks() }
                })
            }
            // 13e E2 (her A17): the delete door over the SAME selection.
            // Rendered from ONE pick, not two — one picked block is a
            // perfectly good thing to delete, where a merge needs a partner.
            if !picked.isEmpty {
                specs.append(.init(
                    title: BlockSelectionCopy.deleteVerb(picked: picked.count)
                ) {
                    Task { await model.deleteSelectedBlocks() }
                })
            }
        }
        if slot.variantID != resolved.variantID, let chosenText = slot.text {
            specs.append(.init(title: "Diff against chosen") {
                onDiff(TakesDiffPresentation(
                    leftTitle: "chosen", rightTitle: "this take",
                    left: chosenText, right: resolved.text))
            })
        }
        // 13f W10b: the road back to the RELEASED original — rendered only on
        // a block that has one (P-2), which is why it sits behind the same
        // kind of per-target condition as "Diff against chosen" above. This
        // is the answer to her sitting question where she asked it: looking
        // at a divide's successor takes.
        if let origin = model.projection.unplacedOrigins[slot.blockID]?.first {
            specs.append(.init(
                // 13j J3: her ruled wording — the row names the act that
                // released the original ("See original from divide…"). The
                // row still renders from the FIRST origin because that is
                // what names the act; where it LANDS (the post-13l polish
                // round, ledger row 17) shows every one of them.
                title: OriginPeekCopy.doorVerb(op: origin.originOp)
            ) {
                model.revealOriginBlock(ofBlock: slot.blockID)
            })
        }
        if let fan = model.projection.fans[slot.blockID], fan.count > 1 {
            specs.append(.init(
                title: "Show take",
                children: fan.map { take in
                    .init(title: TakesShared.takeLabel(take, chosen: slot.variantID)) {
                        Task {
                            await model.pick(
                                columnID: column.id, blockID: slot.blockID, variantID: take.id)
                        }
                    }
                }))
        }
        // 13k K6: the CALLOUT submenu — the same rows the menu bar and
        // Write's right-click offer, from the one vocabulary
        // (`CalloutMenu.rows`). The frame is the BLOCK's and takes share it
        // (R16/R27), so a card's right-click is a legitimate place to set
        // it; the act is the board's own `applyCallout`, i.e. the same
        // routed transform 13c R2-2 gave every other door.
        specs.append(.init(
            title: CalloutMenu.title,
            children: CalloutMenu.rows.compactMap { row in
                guard !row.isSeparator else { return nil }  // specs carry no dividers
                if row.promptsForEmoji {
                    return .init(title: row.title) {
                        guard let glyph = CalloutMenu.promptEmoji() else { return }
                        Task {
                            await model.applyCallout(.emoji(glyph), blockID: slot.blockID)
                        }
                    }
                }
                guard let edit = row.edit else { return nil }
                return .init(
                    title: row.title,
                    action: { Task { await model.applyCallout(edit, blockID: slot.blockID) } },
                    // 13e E1: the swatch, from the one vocabulary's own row —
                    // the card's right-click shows the same chip the menu bar
                    // and Write's right-click show.
                    image: row.swatch.map { CalloutMenu.swatchImage(for: $0) })
            }))
        return specs
    }

    /// The registry ids this menu renders (walk-asserted against the
    /// contextMenu door set's take-scope half).
    static let contextMenuCapabilities: [CapabilityID] = [
        .newTake, .blankTake, .chooseTake, .divergeHere, .archiveTake, .diffAgainstChosen,
        .labelTake,
        // Ledger row 14 (F1): the take-card grammar's other two.
        .lockTake, .deleteTake,
        .showOriginBlock,  // 13f W10b — rendered only where an origin exists
        .callout,  // 13k K6 — the frame door where the takes are
        // 13e E3 (A18) — rendered only on the Takes board with a selection
        .mergeSelectedBlocks,
        // 13e E2 (A17) — the delete door over the same selection
        .deleteSelectedBlocks,
        // 13e E6 (A21) — the clipboard half's card door
        .copyAllTakes,
        // 13e batch 3 (A20/A21) — the take↔block pair's card doors
        .takeToBlockBelow, .takesToBlocks,
    ]
}

/// **The take card's chorded row WORDS — ladder round A (A-4).** One home,
/// for the `BlockSelectionCopy` reason and one more: every chord here comes
/// from the capability that DECLARES it (`Capability.menuTitle`), never a
/// hand-typed suffix. The mechanism the finding names is concrete — AR-1(e)
/// leaves ⌥⌘⏎ / ⇧⌥⌘⏎ hers to re-pick, and while the suffixes were typed by
/// hand a re-pick had to visit the registry, this menu, and the shortcut
/// helper, with nothing making the three agree. `TakeCardMenuTitleTests` is
/// the drift guard over exactly that.
///
/// The words themselves are unchanged — the rows that speak in the card's
/// own sentence keep it and pass it through the formatter; the rows that
/// speak the registry's verb read it from there as they already did.
nonisolated enum TakeCardMenuCopy {
    static var newTake: String {
        CapabilityRegistry.capability(.newTake)
            .menuTitle("＋ New take — branch of this one")
    }

    static var blankTake: String {
        CapabilityRegistry.capability(.blankTake).menuTitle("＋ Blank take")
    }

    /// VX-594 — the card ⌄ menu's branch row, in her ruled words (R-601-4:
    /// *"New branched take"*), the chord from the declaration — the
    /// `archiveTake` row's shape: the row acts on this card's take, the chord
    /// on the take the caret is in (this one, once she is in it).
    static var newBranchedTake: String {
        CapabilityRegistry.capability(.newTake).menuTitle("New branched take")
    }

    static var archiveTake: String {
        CapabilityRegistry.capability(.archiveTake).menuTitle("Archive this take")
    }

    static var copyAllTakes: String {
        CapabilityRegistry.capability(.copyAllTakes).menuTitle()
    }

    static var takeToBlockBelow: String {
        CapabilityRegistry.capability(.takeToBlockBelow).menuTitle()
    }

    static var takesToBlocks: String {
        CapabilityRegistry.capability(.takesToBlocks).menuTitle()
    }

    /// **The lock's two faces, in one place** (the post-13l polish round,
    /// ledger row 14 / F1). The verb is the registry's; which WAY it points
    /// is the take's, exactly as Write's panel has always worded it — a row
    /// that said "Lock" on a locked take would be the small dishonesty this
    /// family of surfaces exists to end.
    static func lockVerb(locked: Bool) -> String {
        locked ? "Unlock this take" : "Lock this take"
    }

    /// The delete row's words — the registry's verb, in the card's voice.
    static var deleteTake: String {
        CapabilityRegistry.capability(.deleteTake).menuTitle("Delete this take")
    }

    /// The label row's words — ONE spelling now (13u3 UNIT H). Write's panel
    /// hand-typed `"Label…"` while the card context menu hand-typed
    /// `"Label take…"`, so the two card menus the F1 ruling called one
    /// grammar did not even agree on this row's name. The context menu's
    /// spelling is the one kept, because it says what it acts on.
    static var labelTake: String {
        CapabilityRegistry.capability(.labelTake).menuTitle("Label take\u{2026}")
    }

    /// The glyph the tutorial's prose names the card's act menu by. It lives
    /// here so the words and the door cannot drift: the lesson interpolates
    /// this constant and `TakeCardDoorTests` reads both.
    ///
    /// VX-223 (PROVISIONAL P-VX223-a, her "it should keep just the dropdown
    /// probably"): the card wore TWO marks — "⋯" beside the borderless style's
    /// own disclosure chevron. It keeps just the dropdown now: `TakeCardMenu`
    /// draws THAT chevron (`chevron.down`, the indicator's own size — the
    /// `RestingRowControls` precedent), and the prose names it by its text
    /// twin "⌄". (A first build drew "▾" at the mini metric; the walk read it
    /// as a dot — the batch record.) A guide seeded before this keeps the "⋯"
    /// it was seeded with.
    static let menuGlyph = "\u{2304}"

    /// The chevron's spoken name (an image label says nothing by itself).
    static let menuAccessibilityLabel = "This take's acts"

    /// Every chorded row on the card, paired with the capability that
    /// declares its key — what the drift guard walks.
    static var chorded: [(id: CapabilityID, title: String)] {
        [(.newTake, newTake), (.newTake, newBranchedTake),
         (.blankTake, blankTake), (.archiveTake, archiveTake),
         (.copyAllTakes, copyAllTakes), (.takeToBlockBelow, takeToBlockBelow),
         (.takesToBlocks, takesToBlocks)]
    }
}

// MARK: - The take card's ⋯ menu (13u3 UNIT H — the E hand-up)

/// **THE CARD'S FOUR ACTS, AS ONE COMPONENT.**
///
/// Her F1 ruling (the post-13l polish round, ledger row 14) is that the take
/// card menus MATCH — *"Write's panel ⋯ carries Archive · Label · Lock ·
/// Delete — Takes mode's card grammar must match."* That pass gave the four
/// acts to the Takes board's ARTICLE cell (its right-click), and the board's
/// take CARDS were left with a choose band and two reorder arrows: a spare
/// take seen on the board could not be deleted, archived, labelled or locked
/// where it was seen. The tutorial meanwhile teaches a reader to delete a
/// spare take *from the card's ⋯ menu*.
///
/// So the menu is a component rather than a second copy of Write's four
/// buttons. Both surfaces build from ONE `rows` list, which is also what the
/// DEBUG oracle reports — so "what this menu renders" has exactly one answer,
/// and a fifth act cannot reach one surface and miss the other.
struct TakeCardActs {
    /// The take's own lock state, so the row can say which way it points
    /// (Write's panel has always worded it that way — a row reading "Lock"
    /// on a locked take is the small dishonesty `lockVerb` exists to end).
    let locked: Bool
    /// VX-594 (R-601-4): a new take branched from THIS card's take — the
    /// card's own target, chosen or not (`branchVariant` takes any parent).
    let branch: () -> Void
    let archive: () -> Void
    let label: () -> Void
    let toggleLock: () -> Void
    let delete: () -> Void
}

extension TakesViewModel {
    /// **The card's acts, wired ONCE for both hosts** (VX-594 — the menu's
    /// fifth row is what made the two hand-built copies worth one home: the
    /// board's cards and Write's take panel built the same four closures
    /// beside each other). Every target is the card's own take, NAMED — a
    /// press on a card never moves the keyboard (13k K6), and the act belongs
    /// to the card she pointed at, not the take the caret is in. `columnID`
    /// is the host's card namespace, so the branch's reveal puts the ring on
    /// a card that host renders (the board's fan cards; the panel's own).
    /// Every refusal — a sealed note, a locked take, the take the note shows,
    /// the block's last take — comes from the operations layer through the
    /// model's doors and speaks (P-2).
    func cardActs(for take: Variant, columnID: String) -> TakeCardActs {
        TakeCardActs(
            locked: take.locked,
            branch: { [self] in
                Task {
                    await branchTakeRevealed(
                        blockID: take.blockId, from: take.id, preferredColumnID: columnID)
                }
            },
            archive: { [self] in Task { await archiveTake(take.id) } },
            label: { [self] in requestTakeLabel(variantID: take.id) },
            toggleLock: { [self] in
                Task { await setTakeLocked(take.id, locked: !take.locked) }
            },
            delete: { [self] in Task { await deleteTake(take.id) } })
    }
}

struct TakeCardMenu: View {
    let acts: TakeCardActs

    /// One row: the capability that declares it, its words, and its act.
    struct Row: Identifiable {
        let id: CapabilityID
        let title: String
        let destructive: Bool
        let act: () -> Void
    }

    /// **THE list** — rendered by the menu, reported by the oracle, asserted
    /// by the per-surface pin. Never two lists.
    static func rows(_ acts: TakeCardActs) -> [Row] {
        [
            // VX-594 (R-601-4): branch from the take the card IS — the one
            // road to a branch of a not-chosen take without clicking into it
            // first. Leads the list: it is the one act that ADDS a take.
            .init(id: .newTake, title: TakeCardMenuCopy.newBranchedTake,
                  destructive: false, act: acts.branch),
            .init(id: .archiveTake, title: TakeCardMenuCopy.archiveTake,
                  destructive: false, act: acts.archive),
            .init(id: .labelTake, title: TakeCardMenuCopy.labelTake,
                  destructive: false, act: acts.label),
            .init(id: .lockTake, title: TakeCardMenuCopy.lockVerb(locked: acts.locked),
                  destructive: false, act: acts.toggleLock),
            // Takes do NOT confirm (13j's confirmation-consistency principle,
            // second clause): ⌥⌘Z is right there and the block's History
            // lists what went, with Put back beside it.
            .init(id: .deleteTake, title: TakeCardMenuCopy.deleteTake,
                  destructive: true, act: acts.delete),
        ]
    }

    /// The capability ids this menu declares — what the per-surface registry
    /// pin compares against each host's `surfaceCapabilities`.
    static let capabilities: [CapabilityID] = [
        .newTake,  // VX-594 (R-601-4): "New branched take"
        .archiveTake, .labelTake, .lockTake, .deleteTake,
    ]

    var body: some View {
        let rows = Self.rows(acts)
        // The chrome is Write's panel's — this component was extracted
        // from it, and the board inherits the grammar rather than a second
        // one being invented for it.
        //
        // VX-155 (her 2026-10-11 report) found the class this menu now
        // shares with every row ⋯: a control size on the Menu is inherited
        // by the popped `NSMenu`, so all four rows rendered in mini type. The
        // fix lives in ONE place since VX-223 — `ChromePullDown` pins its
        // own control size and carries the mini metric on the label.
        //
        // VX-223 (PROVISIONAL P-VX223-a, her lean: "it should keep just the
        // dropdown probably"): the card wore TWO marks — the "⋯" label AND
        // the borderless style's own chevron. It keeps just the dropdown: the
        // chevron, drawn as the indicator draws it (`ChromePullDownMetric.
        // indicatorFont`), the system indicator hidden so it is not doubled;
        // 4 pt either side keeps a clickable target. (A first build drew "▾"
        // at the mini metric — the walk read it as a dot.)
        ChromePullDown(showsIndicator: false) {
            ForEach(rows) { row in
                Button(row.title, role: row.destructive ? .destructive : nil, action: row.act)
            }
        } label: {
            // A Text-embedded symbol: a bare `Image` label is drawn by the
            // pop-up at its own 13-pt size and ignores the font (measured
            // 21×14 vs 15×9 — the walk saw a large light chevron).
            Text(Image(systemName: "chevron.down"))
                .font(ChromePullDownMetric.indicatorFont)
                .padding(.horizontal, 4)
                .accessibilityLabel(TakeCardMenuCopy.menuAccessibilityLabel)
        }
        .recordTakeCardDoors(rows.map(\.id))
    }
}

#if DEBUG
/// **The rendered-door oracle** (13u3 UNIT H; the `TakesEmptyStateDoors`
/// pattern, scoped per row 50's rule because a Takes board is exactly the
/// kind of surface two suites mount at once).
///
/// Why an oracle rather than a click: a SwiftUI `Menu` on a whole board is
/// not an `NSView` a pin can find, and a hosted board builds no accessibility
/// tree in the test host (measured at 17p batch a). The menu reports the list
/// it actually built, on the real board, in the real mount — and the press
/// itself is walked.
@MainActor
enum TakeCardDoors {
    private static var byScope: [String: Set<CapabilityID>] = [:]

    static func record(_ ids: [CapabilityID], in scope: String) {
        byScope[scope, default: []].formUnion(ids)
    }

    struct Reader {
        let scope: String

        var rendered: Set<CapabilityID> { TakeCardDoors.byScope[scope] ?? [] }

        func reset() { TakeCardDoors.byScope[scope] = [] }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}

/// A modifier rather than a bare `onAppear`, because it must READ the
/// environment for its scope (`TakeCardGeometryProbe`'s own reason).
private struct TakeCardDoorsProbe: ViewModifier {
    let ids: [CapabilityID]
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onAppear { TakeCardDoors.record(ids, in: scope) }
    }
}
#endif

extension View {
    /// The DEBUG oracle write (a no-op outside DEBUG).
    @ViewBuilder
    func recordTakeCardDoors(_ ids: [CapabilityID]) -> some View {
        #if DEBUG
        self.modifier(TakeCardDoorsProbe(ids: ids))
        #else
        self
        #endif
    }
}

enum TakesShared {
    static func takeLabel(_ take: Variant, chosen: String?) -> String {
        var label = take.label ?? String(take.workingText.prefix(40))
        if label.isEmpty { label = "(empty take)" }
        if take.id == chosen { label = "✓ " + label }
        return label
    }
}

/// The 9d stable-color family: same block, same color, forever — the
/// same-ORIGIN signal (sameness's other channel).
struct LineageStripe: View {
    let blockID: String

    var body: some View {
        let hue = Double(BlockTint.stableHash(blockID) % 360) / 360.0
        Color(hue: hue, saturation: 0.5, brightness: 0.85)
            .frame(width: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

/// Batch 14 — the takes article's LEFT-MARGIN comment note (her placement
/// suggestion; the round-2 margin-comment idiom, takes-side): the block's
/// first comment, glyph-prefixed, click for the full panel. Fetched per
/// visible row (LazyVStack — cost ∝ viewport).
struct CommentMarginNote: View {
    let session: AppSession
    let blockID: String
    let tokens: VoiceTokens
    /// 13b 3F (N8/AD-8): under ~90pt of real gutter the full card cannot
    /// fit — the note degrades to the // chip (count included) instead of
    /// laying out in space the sidebar owns. Same philosophy as Write's
    /// `gutterFitsCards` degrade.
    var compact = false
    @State private var comments: [BlockComment] = []
    @State private var panelShown = false

    var body: some View {
        if let first = comments.first {
            Button {
                panelShown = true
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    if compact {
                        Text(tokens.chromeLabel(
                            comments.count > 1
                                ? "\(tokens.commentPrefix)\(comments.count)"
                                : tokens.commentPrefix))
                            .font(tokens.small)
                            .foregroundStyle(tokens.commentInk)
                            .lineLimit(1)
                    } else {
                        Text(tokens.commentPrefix + first.text)
                            .font(tokens.small)
                            .foregroundStyle(tokens.commentInk)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                        if comments.count > 1 {
                            Text(tokens.chromeLabel("+\(comments.count - 1) more"))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                        }
                    }
                }
                .padding(.leading, compact ? 0 : 8)
                .overlay(alignment: .leading) {
                    if !compact {
                        Rectangle()
                            .fill(tokens.commentInk.opacity(0.5))
                            .frame(width: 2)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("This block's comments — click to read, add, or edit them")
            .popover(isPresented: $panelShown) {
                CommentsPanel(session: session, blockID: blockID)
            }
            .onChange(of: panelShown) { _, shown in
                if !shown { Task { await refresh() } }
            }
            .task(id: blockID) { await refresh() }
        } else {
            Color.clear
                .frame(width: 1, height: 1)
                .task(id: blockID) { await refresh() }
        }
    }

    private func refresh() async {
        comments = (try? await session.database.read { [blockID] db in
            try Queries.blockComments(db, blockID: blockID)
        }) ?? []
    }
}

/// The take-label prompt (13b Stage 3, 3D — N6's face): set, change, or
/// clear a label on one take. Empty commits clear (the core op NULLs).
struct TakeLabelSheet: View {
    let currentLabel: String?
    let onSet: (String?) -> Void
    @State private var label = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(currentLabel == nil ? "Label this take" : "Change the take's label")
                .font(.headline)
            TextField("e.g. bolder opening", text: $label)
                .frame(width: 260)
                .onSubmit(submit)
            Text("A label names a take on its card and in exports — identity only, never printed in the prose.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 260, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if currentLabel != nil {
                    Button("Clear Label") {
                        onSet(nil)
                        dismiss()
                    }
                }
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Set") { submit() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .onAppear { label = currentLabel ?? "" }
    }

    private func submit() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        onSet(trimmed.isEmpty ? nil : trimmed)
        dismiss()
    }
}

/// Naming sheet for lenses (save-as-lens, save-current-choices, rename).
struct LensNameSheet: View {
    var title: String = "Name this lens"
    /// Prefill (the rename door starts from the current name).
    var initialName: String = ""
    let onName: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            TextField("e.g. bolder thread", text: $name)
                .frame(width: 260)
                .onSubmit(submit)
                .onAppear { if name.isEmpty { name = initialName } }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onName(trimmed)
        dismiss()
    }
}
