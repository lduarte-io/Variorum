//
//  BlockDecor.swift
//  Variorum
//
//  Phase 13, C1 — the writing surface's decoration layer, ALL of it
//  overlay views over the live TK2 editor (the ground rule: decorations
//  never ride rendering attributes — TEXTKIT2 §3; the Phase 7 badge
//  pattern, the A0 spike's measured ~0.04 ms budget):
//
//  - dotted SEAMS between blocks on the global toggle (R6/R42 — THE
//    boundary mechanism; the 9d pastel tint look is RETIRED, this layer
//    replaces `BlockTintOverlayController`);
//  - the EDITING INDICATOR (R14/R22 — a setting: off / outline ring /
//    background wash; off default, cursor-only is legitimate);
//  - CALLOUT frames (R16/R27) with the WHITE-GAP rule (R17: colored
//    blocks keep base-background breathing room — the 9d tint's diagnosed
//    defect, never repeated);
//  - COMMENT surfaces (R7: margin cards the default, inline tinted strips
//    as the setting; a narrow gutter degrades to a count badge — every
//    face opens the comments panel);
//  - block DRAG HANDLES + the Notion INSERTION BAR (R19) — drop lands as
//    ONE `reorder` operation.
//
//  Geometry is pure and tested (`BlockDecor`); the controller only owns
//  view pools. Everything renders from `BlockDecor.State`, which the view
//  model emits on every overlay refresh (scroll, layout, projection,
//  caret move, appearance change).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The appearance context (theme → editor)

/// What the editor surface needs to know from the theme environment —
/// pushed by the View (models never read SwiftUI environments).
nonisolated struct EditorAppearance: Equatable, Sendable {
    var voice: ThemeVoice = .terminal
    var dark = false
    var seamsVisible = false
    var indicator: EditingIndicatorStyle = .off
    var inlineComments = false
    /// 13b 4D (S4-19, her ruling): drag handles reveal on HOVER in Write —
    /// a setting, default ON; OFF = the fully clean surface. The seams-on
    /// STATIC display is unchanged (seams = the working-with-blocks state);
    /// this governs the AT-REST hover only. Local (UserDefaults
    /// `writeHoverHandles`, the density-settings class), pushed by the
    /// View like every appearance input.
    var hoverHandles = true
    /// **The palette and its custom seeds ride the appearance value** (18g
    /// ladder, R1-1): the decoration layer draws the selected-block wash
    /// with its accent border and the `.background` editing indicator from
    /// `tokens` below, and the view model's `didSet { if oldValue !=
    /// appearance … }` is the ONLY thing that re-renders the decor on a
    /// theme change — so a palette click must MOVE this value, which means
    /// the palette is stored here, not re-read. Defaults keep every
    /// `EditorAppearance()` site (the models' placeholders, the pins)
    /// byte-identical to before.
    var palette: ThemePalette = .default
    var tint: PaletteTint = .none
    /// 18l-c U8 (a): her arrival-flash switch (R-18l-7 — default ON), riding
    /// the settings → appearance road like every other synced look.
    var arrivalFlash = true

    init() {}

    init(_ settings: Queries.ThemeSettings, dark: Bool) {
        self.voice = settings.voice
        self.dark = dark
        self.seamsVisible = settings.seamsVisible
        self.indicator = settings.editingIndicator
        self.inlineComments = settings.inlineComments
        self.palette = settings.palette
        self.tint = PaletteTint(settings)
        self.arrivalFlash = settings.arrivalFlash
    }

    /// The four-parameter resolver — the palette-aware road (R1-1); a
    /// default palette is the voice's static set byte-identically.
    @MainActor var tokens: VoiceTokens {
        .resolve(voice: voice, palette: palette, tint: tint, dark: dark)
    }
}

// MARK: - Pure geometry

nonisolated enum BlockDecor {
    /// One visible block's resolved geometry, view coordinates.
    struct Frame: Equatable {
        let entryIndex: Int
        let blockID: String
        let frame: CGRect
    }

    /// Everything one decoration pass renders from.
    struct State: Equatable {
        var frames: [Frame] = []
        var fannedBlockIDs: Set<String> = []
        var appearance = EditorAppearance()
        var caretBlockID: String?
        /// 13e E2 (her A17: *"highlighting all of the blocks perhaps? block
        /// highlight instead of text highlight across blocks?"*) — the
        /// picked blocks. Drawn as a wash PLUS an accent border, so it is
        /// legible beside the editing indicator's background style (which is
        /// a wash alone, and only ever on the caret block).
        var selectedBlockIDs: Set<String> = []
        var presentations: [String: BlockPresentation] = [:]
        var comments: [String: [CommentBrief]] = [:]
        /// The prose column's edges + the surface's width (view coords).
        var textLeft: CGFloat = 0
        var textRight: CGFloat = 0
        var viewWidth: CGFloat = 0
        /// The total entry count (drop boundaries may exceed the visible
        /// window's last index).
        var entryCount = 0
    }

    struct CommentBrief: Equatable {
        let id: String
        let text: String
    }

    /// The bottom of a fragment's TEXT, given the fragment's own frame and
    /// its last line's typographic bottom (fragment-local).
    ///
    /// **The 13c 1A mis-mapping (A40), traced and measured:** TK2 folds a
    /// paragraph's TRAILING GAP into `layoutFragmentFrame`. With the uniform
    /// per-paragraph gap (the 2026-07-12 ruling's presentation half) a
    /// one-line paragraph is 17 pt of text inside a **24 pt** frame in the
    /// terminal voice — **46 pt** with inline comments on. A block frame
    /// taken from the fragment frame therefore claims a gap that belongs to
    /// NEITHER neighbour, consecutive block frames ABUT (measured gap 0.0),
    /// and every decoration drawn from them inherits the claim: the callout
    /// wash spreads under the text and touches the next block (her words —
    /// "the color spreads underneath it"), R17's white-gap rule receives
    /// gap 0 and can only ever return 0 pad, and `seamYs` lands the dotted
    /// seam on the next block's first line instead of centred in the white.
    ///
    /// A fragment with no line fragments (not yet laid out) degrades to its
    /// frame — the pre-fix value, never worse.
    static func textBottom(
        fragmentMinY: CGFloat, fragmentMaxY: CGFloat, lastLineMaxY: CGFloat?
    ) -> CGFloat {
        guard let lastLineMaxY else { return fragmentMaxY }
        return min(fragmentMaxY, fragmentMinY + lastLineMaxY)
    }

    /// A fragment's TEXT rect in CONTAINER coordinates — its frame with the
    /// trailing paragraph gap removed (`textBottom`). THE one extraction
    /// both decoration hosts use; a private copy per host is the class this
    /// fixes.
    static func textRect(of fragment: NSTextLayoutFragment) -> CGRect {
        let frame = fragment.layoutFragmentFrame
        let bottom = textBottom(
            fragmentMinY: frame.minY, fragmentMaxY: frame.maxY,
            lastLineMaxY: fragment.textLineFragments.last?.typographicBounds.maxY)
        return CGRect(
            x: frame.minX, y: frame.minY,
            width: frame.width, height: max(0, bottom - frame.minY))
    }

    /// Seam Y positions — the midpoint of each gap between CONSECUTIVE
    /// visible blocks (a pruned neighbor draws no seam; §12's rest state
    /// is no seams at all).
    static func seamYs(_ frames: [Frame]) -> [CGFloat] {
        zip(frames, frames.dropFirst()).compactMap { a, b in
            guard b.entryIndex == a.entryIndex + 1, b.frame.minY >= a.frame.maxY - 1
            else { return nil }
            return ((a.frame.maxY + b.frame.minY) / 2).rounded()
        }
    }

    /// The white-gap rule (R17, BINDING): a callout card may pad beyond
    /// its text vertically only as far as leaves `minWhiteGap` of base
    /// background toward each neighbor. A nil gap (no adjacent block —
    /// document edge or pruned) allows the ideal pad.
    static func verticalPad(
        gap: CGFloat?, ideal: CGFloat = 5, minWhiteGap: CGFloat = 6
    ) -> CGFloat {
        guard let gap else { return ideal }
        return max(0, min(ideal, (gap - minWhiteGap) / 2))
    }

    // MARK: - THE GUTTER'S NUMBERS (13u3 UNIT A1 — her R-13u-9 / item 20)
    //
    // Everything below draws in the WHITESPACE the page already owns, to the
    // LEFT of the prose (R5-3's margin) or behind it. Nothing here may reach
    // the prose column: the one law says the text's measure and left edge
    // are the surface width's alone, and R9 says the margins are sacred, so
    // a decoration with no room YIELDS rather than borrowing a point of
    // either. (17p batch b's answer — reserve a lane, move the text — is
    // what she reversed; `calloutGutterPad`, `calloutGlyphPad`,
    // `calloutLeadingPad` and `commentClearance` retired with it.)

    /// The view's own edge margin — every decoration's clamp, named.
    static let edgeMargin: CGFloat = 2

    /// The room a leading glyph gets. FIXED rather than measured: a box that
    /// changed shape with the glyph would move the gutter's arithmetic per
    /// block. One emoji at 13 pt measures ~17, and since R-13u3-4 a glyph is
    /// exactly ONE grapheme (`leadingGlyph`), so the box always holds it.
    static let calloutGlyphBox = CGSize(width: 18, height: 17)

    /// The comment badge's own size (the shipped 32 × 16) — its WIDTH is a
    /// maximum now, because a badge may never stand on prose (below).
    static let commentBadgeSize = CGSize(width: 32, height: 16)

    /// Below this a count badge cannot be read at all, so nothing is drawn —
    /// the block keeps every other door to its comments (the block menu,
    /// ⌘⇧', the panel) and the page keeps its measure. Chosen ON THE WALK:
    /// "#1" at 10 pt semibold inside `CommentCardView`'s badge insets needs
    /// ~19 pt, and a badge that shows only "#" is not a count.
    static let commentBadgeMinWidth: CGFloat = 19

    /// The air between two stacked decorations in the gutter — the glyph and
    /// the comment face beneath it (R-13u3-3's stack).
    static let decorAir: CGFloat = 4

    /// The badge's air to the TEXT — the shipped `textLeft − 36` for a
    /// 32-wide badge, stated as the number it always was.
    static let commentBadgeAir: CGFloat = 4

    /// The glyph's air to the TEXT. The same 4 as the badge's, deliberately:
    /// the two stack in one lane and a shared air is what makes them read as
    /// one column rather than two.
    static let calloutGlyphAir: CGFloat = 4

    /// The minimum air between two stacked margin CARDS, so two commented
    /// blocks' cards never abut (her *"the comments still also aren't spaced
    /// well"*; memo §2 B's rhythm).
    static let cardRhythmAir: CGFloat = 6

    /// Below this a clamped card is not a card — the block shows its badge
    /// instead. One 11-pt line inside `CommentCardView`'s own insets is
    /// ~19 pt, so this is the smallest card that still says a WORD rather
    /// than a count; the walk chose it against two adjacent commented
    /// blocks (PROVISIONAL, a taste number).
    static let cardMinHeight: CGFloat = 19

    /// **THE LEADING GLYPH — ONE GRAPHEME** (her ruling R-13u3-4, the memo
    /// §3 edge 2). Whatever is stored (a multi-glyph answer typed before the
    /// guard, or one arriving from another device), what the gutter draws is
    /// the FIRST grapheme, so the fixed box above always holds it and row
    /// 50's clip residual cannot recur. nil = this block wears no glyph.
    static func leadingGlyph(_ presentation: BlockPresentation?) -> String? {
        guard let presentation,
              presentation.kind == BlockPresentation.calloutKind,
              let emoji = presentation.emoji,
              let first = emoji.first
        else { return nil }
        return String(first)
    }

    /// Does this presentation put a glyph in the gutter?
    static func hasLeadingGlyph(_ presentation: BlockPresentation?) -> Bool {
        leadingGlyph(presentation) != nil
    }

    /// **The gutter room a decoration of `air` clearance can occupy** — from
    /// the view's edge margin to `air` short of the prose. Zero or less means
    /// the page has no gutter here and the decoration yields.
    static func gutterRoom(textLeft: CGFloat, air: CGFloat) -> CGFloat {
        max(0, textLeft - air - edgeMargin)
    }

    /// **The callout's WASH — it HUGS THE PROSE COLUMN** (memo §2 C). It is a
    /// background, so it never moves text and it stays the callout's identity
    /// (R16/R17) — but it no longer extends into the gutter on either side,
    /// because the gutter is the decorations' now and a tint under the glyph
    /// would read as the old frame-with-an-emoji-in-it. Vertical air is
    /// untouched: R17's white-gap rule, capped against BOTH neighbours.
    static func calloutRect(
        block: CGRect, gapAbove: CGFloat?, gapBelow: CGFloat?,
        textLeft: CGFloat, textRight: CGFloat
    ) -> CGRect {
        let top = verticalPad(gap: gapAbove)
        let bottom = verticalPad(gap: gapBelow)
        return CGRect(
            x: textLeft, y: block.minY - top,
            width: max(0, textRight - textLeft), height: block.height + top + bottom)
    }

    /// **The leading glyph's rect — IN THE GUTTER, at the block's first
    /// line** (memo §2 C). nil where the gutter cannot hold it without
    /// touching the prose: at a narrow window the glyph yields before the
    /// text does (memo §3 edge 1).
    static func calloutGlyphRect(textLeft: CGFloat, blockTop: CGFloat) -> CGRect? {
        guard gutterRoom(textLeft: textLeft, air: calloutGlyphAir)
            >= calloutGlyphBox.width
        else { return nil }
        return CGRect(
            x: textLeft - calloutGlyphAir - calloutGlyphBox.width, y: blockTop,
            width: calloutGlyphBox.width, height: calloutGlyphBox.height)
    }

    /// **THE STACK (her ruling R-13u3-3, verbatim: *"stack them at any
    /// width, I think it would look better."*)** — where a block's COMMENT
    /// face sits: directly UNDER the callout glyph where the block wears one
    /// in the gutter, at the block's first line otherwise. One uniform
    /// arrangement at every width, never side-by-side jockeying — which is
    /// why `commentClearance`'s horizontal arithmetic is retired.
    static func commentFaceTop(blockTop: CGFloat, glyph: CGRect?) -> CGFloat {
        guard let glyph else { return blockTop }
        return glyph.maxY + decorAir
    }

    /// **The comment count BADGE — and it never stands on prose.** Its width
    /// is the shipped 32 wherever the gutter holds it (byte-identical), and
    /// yields to the room where it does not; below `commentBadgeMinWidth`
    /// there is no badge at all. *(Row 50's first residual — Write at
    /// `minGutter` 28 — dissolves here: the badge is 22 pt wide there and
    /// clear of the words, where it used to clamp at 2 and sit on them.)*
    static func commentBadgeRect(textLeft: CGFloat, top: CGFloat) -> CGRect? {
        let room = gutterRoom(textLeft: textLeft, air: commentBadgeAir)
        guard room >= commentBadgeMinWidth else { return nil }
        let width = min(commentBadgeSize.width, room)
        return CGRect(
            x: textLeft - commentBadgeAir - width, y: top,
            width: width, height: commentBadgeSize.height)
    }

    /// The air the editing indicator takes on each side of the prose — the
    /// round-2 mockup's outline-offset, unchanged since 13 C1 and named here
    /// so the one place it can now YIELD says what it is yielding.
    static let indicatorOverhang: CGFloat = 8

    /// The editing indicator's rect (outline ring or background wash):
    /// the block's lines with the round-2 mockup's air (outline-offset).
    ///
    /// **13u4 UNIT S3 — KnownIssues row 63: the ring RESPECTS the gutter's
    /// faces.** The 8 pt overhang was designed when the gutter held nothing;
    /// since 13u3 UNIT A1 it holds the callout glyph and the comment badge,
    /// both of which end 4 pt short of the prose — so on a block wearing one
    /// the ring's leading edge (`textLeft − 8`) stood 4 pt INSIDE the face
    /// and drew straight through it. `gutterTrailingX` is the trailing edge
    /// of whatever that block's gutter actually draws (`gutterTrailingX(…)`,
    /// which asks the one comment-face decision rather than guessing), and
    /// the ring stops there.
    ///
    /// **THE GUTTER LAW, at this line:** the ring can only ever GIVE room
    /// back. `textLeft` and `textRight` are arguments, never outputs; the
    /// trailing edge is untouched; and the leading edge is clamped at
    /// `textLeft` so no arithmetic here can ever put the ring on her words.
    /// A margin CARD ends at `textLeft − 28` and therefore moves the ring by
    /// nothing at all — which is the common commented block, and it looks
    /// exactly as it shipped.
    ///
    /// nil (the default) is the no-gutter answer and is BYTE-IDENTICAL to
    /// what shipped, which is what lets every existing pin ride unmodified.
    static func indicatorRect(
        block: CGRect, textLeft: CGFloat, textRight: CGFloat,
        gutterTrailingX: CGFloat? = nil
    ) -> CGRect {
        let ideal = max(edgeMargin, textLeft - indicatorOverhang)
        let left = min(textLeft, max(ideal, gutterTrailingX ?? ideal))
        return CGRect(
            x: left, y: block.minY - 3,
            width: (textRight + indicatorOverhang) - left, height: block.height + 6)
    }

    /// **The trailing edge of everything this block's gutter DRAWS** (row 63)
    /// — nil where it draws nothing. The glyph and the comment face are the
    /// two inhabitants; the comment half is ASKED of `commentGutterFaces`,
    /// the same decision the renderer draws from, because a second copy of
    /// "card or badge?" is exactly the drift `indicatorRect`'s own shared-
    /// geometry note warns about one screen up.
    static func gutterTrailingX(
        blockID: String, blockTop: CGFloat, in state: State,
        commentFaces: [String: CommentFace]
    ) -> CGFloat? {
        var trailing: CGFloat?
        if hasLeadingGlyph(state.presentations[blockID]),
           let glyph = calloutGlyphRect(textLeft: state.textLeft, blockTop: blockTop) {
            trailing = glyph.maxX
        }
        if let rect = commentFaces[blockID]?.rect {
            trailing = max(trailing ?? rect.maxX, rect.maxX)
        }
        return trailing
    }

    /// **What a commented block's gutter draws, and where.** ONE decision,
    /// asked twice: by `renderComments`, which draws it, and by the editing
    /// indicator and the block highlight, which must not cross it (row 63).
    enum CommentFace: Equatable {
        /// The margin card (R7's ruling, on the LEFT by R5-3).
        case card(CGRect)
        /// The narrow-gutter count badge — still a door.
        case badge(CGRect)
        /// No gutter at all: the decoration YIELDS and the text keeps every
        /// point of its measure (13u3 UNIT A1, the one law's other side).
        /// Named `yields` rather than `none` deliberately — a `none` case on
        /// a type that also travels as an Optional is the ambiguity Swift
        /// warns about, and the app's own word for this state is "yields".
        case yields

        var rect: CGRect? {
            switch self {
            case .card(let rect), .badge(let rect): rect
            case .yields: nil
            }
        }
    }

    /// The whole pass's gutter decision, keyed by block. **Empty when
    /// comments render INLINE** (R7's setting — the tinted strip lives
    /// inside the prose column, so the gutter holds nothing and the ring
    /// keeps its shipped overhang).
    ///
    /// The arithmetic is `renderComments`' own, moved rather than copied:
    /// each face's TOP is the STACK's answer (R-13u3-3) and each card's room
    /// reaches to the NEXT face's top, so two commented blocks' cards never
    /// abut (the rhythm, memo §2 B).
    static func commentGutterFaces(_ state: State) -> [String: CommentFace] {
        guard !state.appearance.inlineComments else { return [:] }
        let items = state.frames.filter { !(state.comments[$0.blockID] ?? []).isEmpty }
        guard !items.isEmpty else { return [:] }
        let fitsCards = gutterFitsCards(width: state.textLeft)
        let tops: [CGFloat] = items.map { item in
            commentFaceTop(
                blockTop: item.frame.minY,
                glyph: hasLeadingGlyph(state.presentations[item.blockID])
                    ? calloutGlyphRect(textLeft: state.textLeft, blockTop: item.frame.minY)
                    : nil)
        }
        var faces: [String: CommentFace] = [:]
        for (index, item) in items.enumerated() {
            let top = tops[index]
            let roomBelow = index + 1 < tops.count ? tops[index + 1] - top : nil
            if fitsCards, let rect = leftCardRect(
                textLeft: state.textLeft, top: top,
                blockHeight: item.frame.height, roomBelow: roomBelow) {
                faces[item.blockID] = .card(rect)
            } else if let rect = commentBadgeRect(textLeft: state.textLeft, top: top) {
                faces[item.blockID] = .badge(rect)
            } else {
                faces[item.blockID] = .yields
            }
        }
        return faces
    }

    /// The drop boundary nearest a drag Y: `index` = the entry the dragged
    /// block would land BEFORE (`entryCount` = the end); `barY` = where
    /// the insertion bar renders. Boundaries come from the VISIBLE frames
    /// (drag targets are on-screen by construction).
    static func dropBoundary(
        at y: CGFloat, frames: [Frame], entryCount: Int
    ) -> (index: Int, barY: CGFloat)? {
        guard let first = frames.first, let last = frames.last else { return nil }
        if y < first.frame.midY {
            return (first.entryIndex, first.frame.minY - 2)
        }
        for (a, b) in zip(frames, frames.dropFirst()) where y < b.frame.midY {
            return (b.entryIndex, ((a.frame.maxY + b.frame.minY) / 2).rounded())
        }
        let end = min(last.entryIndex + 1, entryCount)
        return (end, last.frame.maxY + 2)
    }

    /// Whether a comment gutter is wide enough for margin comment CARDS;
    /// below this the margin presentation degrades to the count badge.
    ///
    /// 13g batch 6 (R5-3): the gutter handed in is the LEFT one now — her
    /// ruling, verbatim: *"i also think comments should appear on the left
    /// since there's so much machinery going on on the right already."* The
    /// threshold is unchanged; only which margin is measured moved, which is
    /// why this takes a plain width rather than deriving one side's.
    static func gutterFitsCards(width: CGFloat) -> Bool {
        width >= 150
    }

    /// Where a left-margin comment card sits, given the text's left edge.
    /// The drag handles own the lane at `textLeft - 22` (see
    /// `renderHandles`), so a card stops short of it rather than under it.
    ///
    /// **13u3 UNIT A1 — the RHYTHM (memo §2 B; her *"the comments still also
    /// aren't spaced well"*).** Two new inputs, and nothing else moved: `top`
    /// is the STACK's answer (the block's first line, or under its callout
    /// glyph — R-13u3-3), and `roomBelow` is how far this card may reach
    /// before the NEXT commented block's face begins, so two cards can never
    /// abut. A card with too little room to be one answers nil and its block
    /// shows the badge instead. With no glyph and no neighbour the rect is
    /// BYTE-IDENTICAL to what shipped (the parity claim, pinned).
    ///
    /// **VX-179 U2 — THE CARD GROWS TO THE BLOCK (her ruling R-VX179-2,
    /// verbatim at the kickoff: the card may grow to the block's own height
    /// plus a small pad, still bounded by the rhythm; a one-line block keeps
    /// a small card; scroll-inside covers overflow; the 96 pt cap retires).**
    /// Her words behind it: *"sometimes a block is several paragraphs but the
    /// comment is always just one line."* The ideal is now the block's own
    /// height plus `cardHeightPad` — the shipped pad, kept, so every card
    /// under the old cap (a block of 72 pt or less) is byte-identical — and
    /// the two bounds that were already here stand exactly as they were:
    /// `roomBelow` minus the rhythm's air (two cards never abut) and the
    /// `cardMinHeight` floor. Width, x, the handle lane: untouched.
    static func leftCardRect(
        textLeft: CGFloat, top: CGFloat, blockHeight: CGFloat,
        roomBelow: CGFloat? = nil
    ) -> CGRect? {
        let width = min(210, max(0, textLeft - leftCardLane))
        guard width > 0 else { return nil }
        let ideal = blockHeight + cardHeightPad
        let height = min(ideal, roomBelow.map { max(0, $0 - cardRhythmAir) } ?? ideal)
        guard height >= cardMinHeight else { return nil }
        return CGRect(
            x: max(0, textLeft - leftCardLane - width), y: top,
            width: width, height: height)
    }

    /// The clearance a left card leaves for the drag-handle lane.
    static let leftCardLane: CGFloat = 28

    /// How far past its block's text a margin card reaches — the shipped
    /// `+ 24`, named at VX-179 U2 when the 96 pt cap beside it retired. A
    /// one-line block's card is therefore ~41 pt: room for two or three
    /// short entries before the card scrolls (R-VX179-2's "a one-line block
    /// keeps a small card").
    static let cardHeightPad: CGFloat = 24

    // 13l (her 8c rider, verbatim: *"I need the comment + on the left
    // removed … it's too crowded and I don't like the look of seeing it
    // there"*): 13e E7's hover add-a-comment chip is GONE, and its geometry
    // with it. The margin-hover comment CARD and BADGE are untouched — they
    // are what a block with comments shows, and the same door — and so is
    // every other way in (the block menu, ⌘⇧', the comments panel). Only
    // the invitation on an UNCOMMENTED block is retired.
}

// MARK: - The callout palette (token NAMES → colors; R1 forbids stored values)

nonisolated enum CalloutPalette {
    static let names = ["blue", "green", "sand", "violet", "rose"]
    static let defaultName = "blue"

    /// Soft washes with real breathing room (R17's spirit); dark keeps the
    /// fully-black room readable (R51).
    static func color(_ name: String?, dark: Bool) -> NSColor {
        let resolved = name ?? defaultName
        let hex: UInt32
        switch (resolved, dark) {
        case ("green", false): hex = 0xEAF3E7
        case ("green", true): hex = 0x17251A
        case ("sand", false): hex = 0xF7F1DE
        case ("sand", true): hex = 0x262012
        case ("violet", false): hex = 0xEFEAF6
        case ("violet", true): hex = 0x1F1A2A
        case ("rose", false): hex = 0xF8ECEC
        case ("rose", true): hex = 0x2A1A1C
        case (_, false): hex = 0xE8F1F8  // blue + unknown names (fail-open)
        case (_, true): hex = 0x14202B
        }
        return NSColor(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

// MARK: - The ONE callout transform (13c Stage 1 ladder, R2-2 — A13(a))

/// What each `CalloutEdit` does to a block's STORED frame. Pure, so the
/// four surfaces that now carry the callout door (Write, Takes, Lenses,
/// Compare) share one rule instead of each re-deriving read-modify-write
/// semantics — the shape `MergeJoin`/`BoundarySnapping` set for their
/// gestures (Stage 4 lessons 3–4), applied to presentation.
///
/// Every caller passes this straight to `Operations.updateBlockPresentation`,
/// whose transform runs INSIDE the write transaction — so "keep the colour,
/// change the emoji" reads the stored frame, never a projection cache.
nonisolated enum CalloutEditRule {
    static func apply(_ edit: CalloutEdit, to existing: BlockPresentation?) -> BlockPresentation? {
        switch edit {
        case .color(let name):
            // nil REMOVES the frame; a name keeps whatever emoji is there.
            return name.map { BlockPresentation(color: $0, emoji: existing?.emoji) }
        case .emoji(let raw):
            let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
            return BlockPresentation(
                color: existing?.color ?? CalloutPalette.defaultName,
                emoji: (trimmed?.isEmpty == false) ? trimmed : nil)
        case .toggle:
            // A frame is one thing you either have or don't — which is what
            // makes ⌥⌘C a legitimate single act.
            return existing == nil
                ? BlockPresentation(color: CalloutPalette.defaultName, emoji: nil)
                : nil
        }
    }
}

// MARK: - The overlay controller

/// Owns the decoration view pools over one TK2 surface — the LIVE editor
/// (comment doors + drag handles wired) or the READ tier (view-only:
/// callouts, seams, comment cards — nil doors hide the handles and mute
/// the clicks). Renders whatever `BlockDecor.State` its owner feeds it;
/// every view is either click-through (seams, washes, callouts, the bar)
/// or an explicit door.
@MainActor
final class BlockDecorOverlayController {
    private weak var textView: NSTextView?
    /// The comments door (nil = read-only faces).
    private let onOpenComments: ((String) -> Void)?
    /// The drop door: (fromEntry, toBoundary). nil = no handles at all.
    private let onMoveBlock: ((Int, Int) -> Void)?

    private var seamViews: [SeamLineView] = []
    private var calloutViews: [DecorRectView] = []
    private var emojiLabels: [NSTextField] = []
    private var indicatorView: DecorRectView?
    /// 13e E2: one view per PICKED, visible block (pooled like the seams).
    private var selectionViews: [DecorRectView] = []
    private var commentCards: [CommentCardView] = []
    private var handleViews: [DragHandleView] = []
    private var insertionBar: DecorRectView?
    private var state = BlockDecor.State()

    /// The live editor's controller: full doors.
    convenience init(model: EditorViewModel, textView: EditorTextView) {
        self.init(
            textView: textView,
            onOpenComments: { [weak model] blockID in model?.openComments(blockID: blockID) },
            onMoveBlock: { [weak model] from, to in
                Task { await model?.moveBlock(fromEntry: from, toBoundary: to) }
            })
        model.decorSink = { [weak self] state in self?.render(state) }
        // 18l-c U8 (a): the mode switch's arrival flash draws in THIS layer —
        // a decoration below the text like every other (never a rendering
        // attribute, TEXTKIT2 §3).
        model.arrivalFlashSink = { [weak self] rect, tokens in self?.flashArrival(rect, tokens: tokens) }
        // 13e E7: the pointer's presence reaches the model, so the calm
        // page grows geometry exactly while she is pointing at it (and the
        // hover faces — the handle AND the comment invitation — can exist
        // there at all).
        onPointerInside = { [weak model] inside in model?.pointerInEditor = inside }
        // Stage 2 walk fix (the starved-host class): wiring delivers the
        // current state — decorations computed before this host existed
        // must not stay invisible until the next real change.
        model.pushDecorationsToSink()
    }

    init(
        textView: NSTextView,
        onOpenComments: ((String) -> Void)?,
        onMoveBlock: ((Int, Int) -> Void)?
    ) {
        self.textView = textView
        self.onOpenComments = onOpenComments
        self.onMoveBlock = onMoveBlock
        // 13b 4D (S4-19): hover tracking exists only where a DOOR does —
        // the read tier (nil doors) never tracks or reveals. 13e E7 had
        // widened this to "a drop door OR a comments door" for the margin's
        // add-a-comment invitation; 13l retired that invitation (her 8c
        // rider), so the condition narrows back to the door that still uses
        // hover — the drag handle's reveal. Behaviourally identical in
        // production, which E7's own note recorded: every production
        // controller has both doors or neither.
        if onMoveBlock != nil {
            let tracker = HandleHoverTracker()
            tracker.onHover = { [weak self, weak textView] windowPoint in
                guard let self else { return }
                guard let windowPoint, let textView else {
                    return self.noteHover(atY: nil)
                }
                self.noteHover(atY: textView.convert(windowPoint, from: nil).y)
            }
            let area = NSTrackingArea(
                rect: .zero,
                options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
                owner: tracker, userInfo: nil)
            textView.addTrackingArea(area)
            hoverTracker = tracker
            hoverArea = area
        }
    }

    func uninstall() {
        // 13e E7: the surface is going away with the pointer possibly still
        // over it (a mode switch, a closing pane). Tell the model the
        // pointer is gone, or its decoration walk stays awake for a surface
        // nobody is pointing at.
        onPointerInside?(false)
        onPointerInside = nil
        hoveredBlockID = nil
        if let hoverArea { textView?.removeTrackingArea(hoverArea) }
        hoverArea = nil
        hoverTracker = nil
        for view in seamViews { view.removeFromSuperview() }
        for view in calloutViews { view.removeFromSuperview() }
        for label in emojiLabels { label.removeFromSuperview() }
        for card in commentCards { card.removeFromSuperview() }
        for handle in handleViews { handle.removeFromSuperview() }
        for view in selectionViews { view.removeFromSuperview() }
        indicatorView?.removeFromSuperview()
        insertionBar?.removeFromSuperview()
        flashView?.removeFromSuperview()
        flashView = nil
        seamViews = []
        calloutViews = []
        emojiLabels = []
        commentCards = []
        handleViews = []
        selectionViews = []
        indicatorView = nil
        insertionBar = nil
    }

    // MARK: Render

    func render(_ state: BlockDecor.State) {
        self.state = state
        guard let textView else { return }
        // **13u3 UNIT A1 — THE ONE LAW.** There is no door here any more.
        // 17p batch b's decoration lane stood at exactly this line: a render
        // asked its surface to MOVE THE PROSE to make room, which needed a
        // second pass (the W-1 finding) and moved her text (item 20's
        // reversal). The prose column is now a pure function of the
        // surface's own width (`ProseGutter`), so a decoration has nothing
        // to reserve, nothing to release, and no second pass to ask for —
        // it draws in the room the page already owns.
        let tokens = state.appearance.tokens
        // 13u4 UNIT S3 (row 63): the gutter's comment decision, made ONCE for
        // the pass. The comments render LAST (below), but the indicator and
        // the block highlight must know what the gutter will hold before they
        // draw — so the decision is taken here and handed to all three,
        // rather than the ring re-deriving "card or badge?" and drifting.
        let commentFaces = BlockDecor.commentGutterFaces(state)
        renderCallouts(state, tokens: tokens, in: textView)
        renderSelection(state, tokens: tokens, in: textView, commentFaces: commentFaces)
        renderIndicator(state, tokens: tokens, in: textView, commentFaces: commentFaces)
        renderSeams(state, tokens: tokens, in: textView)
        renderComments(state, tokens: tokens, in: textView, faces: commentFaces)
        renderHandles(state, in: textView)
    }

    private func renderSeams(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        let ys = state.appearance.seamsVisible ? BlockDecor.seamYs(state.frames) : []
        pool(&seamViews, count: ys.count, in: textView, below: true) { SeamLineView() }
        for (view, y) in zip(seamViews, ys) {
            view.frame = CGRect(
                x: state.textLeft, y: y - 1,
                width: max(0, state.textRight - state.textLeft), height: 2)
            view.lineColor = NSColor(tokens.seam)
        }
    }

    private func renderCallouts(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView
    ) {
        var rects: [(frame: BlockDecor.Frame, presentation: BlockPresentation)] = []
        for frame in state.frames {
            if let presentation = state.presentations[frame.blockID],
               presentation.kind == BlockPresentation.calloutKind {
                rects.append((frame, presentation))
            }
        }
        pool(&calloutViews, count: rects.count, in: textView, below: true) { DecorRectView() }
        // 13u3 UNIT A1: a glyph is drawn only where the GUTTER holds it —
        // at a narrow window the glyph yields before the text does (memo §3
        // edge 1), so the pool counts the ones that will actually fit.
        let glyphed = rects.filter {
            BlockDecor.hasLeadingGlyph($0.presentation)
                && BlockDecor.calloutGlyphRect(
                    textLeft: state.textLeft, blockTop: $0.frame.frame.minY) != nil
        }
        pool(&emojiLabels, count: glyphed.count, in: textView, below: false) {
            let label = NSTextField(labelWithString: "")
            label.font = .systemFont(ofSize: 13)
            // ONE grapheme by rule (R-13u3-4), so the fixed box always holds
            // it; clipping stays as the last resort for a wide glyph.
            label.lineBreakMode = .byClipping
            return label
        }
        var emojiIndex = 0
        for (view, item) in zip(calloutViews, rects) {
            let index = item.frame.entryIndex
            let above = state.frames.first { $0.entryIndex == index - 1 }
            let below = state.frames.first { $0.entryIndex == index + 1 }
            view.frame = BlockDecor.calloutRect(
                block: item.frame.frame,
                gapAbove: above.map { item.frame.frame.minY - $0.frame.maxY },
                gapBelow: below.map { $0.frame.minY - item.frame.frame.maxY },
                textLeft: state.textLeft, textRight: state.textRight)
            view.configure(
                fill: CalloutPalette.color(item.presentation.color, dark: state.appearance.dark),
                border: nil, cornerRadius: 8)
            // 13u3 UNIT A1 (her R-13u-9 / memo §2 C): the glyph is the
            // FRAME's accent, not the text's — it moves fully into the
            // gutter beside the block's first line. It used to sit inside
            // the wash's own leading pad, which is what made the wash grow
            // into the margin in the first place.
            if let glyph = BlockDecor.leadingGlyph(item.presentation),
               let rect = BlockDecor.calloutGlyphRect(
                   textLeft: state.textLeft, blockTop: item.frame.frame.minY),
               emojiIndex < emojiLabels.count {
                let label = emojiLabels[emojiIndex]
                emojiIndex += 1
                label.stringValue = glyph
                label.frame = rect
            }
        }
    }

    /// **13e E2 (her A17): the BLOCK HIGHLIGHT.** One wash-and-border band
    /// per picked, visible block — the same full-width geometry the editing
    /// indicator uses (`indicatorRect`), because "the block, edge to edge"
    /// is the same shape in both cases and a second rect rule would drift
    /// from it. Drawn BELOW the text like every other decoration (an
    /// overlay, never a rendering attribute — TEXTKIT2 §3), and pooled, so a
    /// selection of forty blocks costs only the visible ones (P1).
    ///
    /// Row 63 rides here too, for that same reason: the highlight takes the
    /// gutter's trailing edge exactly as the ring does, so a picked callout
    /// block's band and a caret block's ring stop at the same x.
    private func renderSelection(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView,
        commentFaces: [String: BlockDecor.CommentFace]
    ) {
        let frames = state.selectedBlockIDs.isEmpty
            ? []
            : state.frames.filter { state.selectedBlockIDs.contains($0.blockID) }
        pool(&selectionViews, count: frames.count, in: textView, below: true) { DecorRectView() }
        for (view, frame) in zip(selectionViews, frames) {
            view.frame = BlockDecor.indicatorRect(
                block: frame.frame, textLeft: state.textLeft, textRight: state.textRight,
                gutterTrailingX: BlockDecor.gutterTrailingX(
                    blockID: frame.blockID, blockTop: frame.frame.minY,
                    in: state, commentFaces: commentFaces))
            view.configure(
                fill: NSColor(tokens.wash), border: NSColor(tokens.accent), cornerRadius: 6)
        }
    }

    private func renderIndicator(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView,
        commentFaces: [String: BlockDecor.CommentFace]
    ) {
        let caretFrame = state.caretBlockID.flatMap { id in
            state.frames.first { $0.blockID == id }
        }
        guard state.appearance.indicator != .off, let caretFrame else {
            indicatorView?.removeFromSuperview()
            indicatorView = nil
            return
        }
        let view = indicatorView ?? {
            let view = DecorRectView()
            indicatorView = view
            return view
        }()
        if view.superview == nil {
            textView.addSubview(view, positioned: .below, relativeTo: nil)
        }
        view.frame = BlockDecor.indicatorRect(
            block: caretFrame.frame,
            textLeft: state.textLeft, textRight: state.textRight,
            // Row 63: the ring stops at whatever this block's gutter draws.
            gutterTrailingX: BlockDecor.gutterTrailingX(
                blockID: caretFrame.blockID, blockTop: caretFrame.frame.minY,
                in: state, commentFaces: commentFaces))
        switch state.appearance.indicator {
        case .outline:
            view.configure(fill: nil, border: NSColor(tokens.ring), cornerRadius: 4)
        case .background:
            view.configure(fill: NSColor(tokens.wash), border: nil, cornerRadius: 6)
        case .off:
            break
        }
    }

    /// **13u4 UNIT S3 (row 63): the gutter decision ARRIVES, it is not made
    /// here.** `faces` is `BlockDecor.commentGutterFaces(state)` — the STACK
    /// (R-13u3-3), the card/badge/nothing choice and the rhythm's room, all
    /// of it — computed once per pass in `render` so the editing indicator
    /// and the block highlight can respect exactly what this draws. The
    /// arithmetic MOVED; not one number of it changed. The inline strip
    /// (R7's setting) stays here because it lives inside the PROSE column,
    /// where no gutter face and no ring can meet it.
    private func renderComments(
        _ state: BlockDecor.State, tokens: VoiceTokens, in textView: NSTextView,
        faces: [String: BlockDecor.CommentFace]
    ) {
        var items: [(frame: BlockDecor.Frame, briefs: [BlockDecor.CommentBrief])] = []
        for frame in state.frames {
            if let briefs = state.comments[frame.blockID], !briefs.isEmpty {
                items.append((frame, briefs))
            }
        }
        let inline = state.appearance.inlineComments
        // VX-179 U2: the pool pairs cards with blocks by IDENTITY, not
        // position — a margin card now holds an inner scroll position, and a
        // block that stays on screen keeps it while the page scrolls
        // (`CommentCardLayout.reconcile`'s note).
        reconcileCommentCards(for: items.map(\.frame.blockID), in: textView)
        for (card, item) in zip(commentCards, items) {
            let text = item.briefs.map(\.text).joined(separator: "  ·  ")
            let blockID = item.frame.blockID
            card.identity = blockID
            card.onClick = onOpenComments.map { open in { open(blockID) } }
            if inline {
                // The inline strip (R7's setting): the tinted line in the
                // widened uniform gap under the block.
                card.present(
                    text: tokens.commentPrefix + text,
                    tint: NSColor(tokens.commentTint), ink: NSColor(tokens.commentInk),
                    style: .strip)
                card.frame = CGRect(
                    x: state.textLeft, y: item.frame.frame.maxY + 3,
                    width: max(40, state.textRight - state.textLeft),
                    height: EditorTypography.inlineCommentSpacing - 4)
                card.isHidden = false
            } else if case .card(let rect) = faces[blockID] ?? .yields {
                // The margin card (R7's ruling — the round-2 mockup's
                // mcmt), on the LEFT by her R5-3 ruling, at the STACK's top
                // and with the rhythm's room (13u3 UNIT A1) — and since
                // VX-179 U2 (R-VX179-1) each comment its own ENTRY, in the
                // briefs' (= the panel's) order, scrolling inside the card
                // when they outgrow it. The tooltip keeps the shipped joined
                // string whole.
                card.presentCard(CommentCardView.CardContent(
                    entries: item.briefs.map(\.text),
                    prefix: tokens.commentPrefix,
                    ink: NSColor(tokens.commentInk),
                    rule: NSColor(tokens.commentTint),
                    separator: NSColor(tokens.line),
                    fill: .clear,
                    toolTip: tokens.commentPrefix + text))
                card.frame = rect
                card.isHidden = false
            } else if case .badge(let rect) = faces[blockID] ?? .yields {
                // Narrow gutter: the count badge — still a door, and now on
                // the same side as the cards it stands in for.
                card.present(
                    text: "#\(item.briefs.count)",
                    tint: NSColor(tokens.commentTint), ink: NSColor(tokens.commentInk),
                    style: .badge)
                card.frame = rect
                card.isHidden = false
            } else {
                // **NO GUTTER, NO FACE** (13u3 UNIT A1, the one law's other
                // side). At a window narrow enough that even a clamped badge
                // would stand on her words, the decoration yields: the text
                // keeps every point of its measure, and the comment keeps
                // every other door it has (the block menu, ⌘⇧', the panel,
                // and the inline-strip setting — R-13u3-5).
                card.isHidden = true
                card.frame = .zero
            }
        }
    }

    /// The comment cards' pool, keyed by the block each card shows (VX-179
    /// U2): reuse the card already showing a block, hand the free ones to the
    /// rest in pool order, make new ones only when the pool runs out, and
    /// remove what no visible commented block needs — the generic `pool`'s
    /// grow/shrink, with identity in place of position.
    private func reconcileCommentCards(for blockIDs: [String], in textView: NSTextView) {
        let plan = CommentCardLayout.reconcile(
            current: commentCards.map(\.identity), wanted: blockIDs)
        let existing = commentCards
        commentCards = plan.reuse.map { index in
            if let index { return existing[index] }
            let card = CommentCardView()
            textView.addSubview(card)
            return card
        }
        for index in plan.discard { existing[index].removeFromSuperview() }
    }

    // MARK: The margin add-a-comment door — RETIRED (13l, her 8c rider)
    //
    // Her words, verbatim: *"I need the comment + on the left removed …
    // it's too crowded and I don't like the look of seeing it there … the
    // comments + to the left is currently annoying me though so removing it
    // can be a super minor 13l item."*
    //
    // The door's whole history was one long argument about WHERE it could
    // sit: 13b 4D shipped a quiet "+ //" in the RIGHT gutter at the caret
    // block; her R5-3 ruling retired that (*"stop showing the comment + to
    // the right completely, it conflicts with the take icon"*); 13e E7
    // rebuilt it on the LEFT, hover-only, uncommented blocks only. This
    // ruling ends the argument: the invitation is gone from both margins.
    //
    // **What is NOT removed, deliberately** — every other way to leave a
    // comment, and every way to READ one: the margin card and its narrow-
    // gutter badge (what a block WITH comments shows, and itself the door),
    // the inline strip grammar, the block menu's item, ⌘⇧', and the
    // comments panel. Removal only; the fuller comments-area rework is
    // 13u's item 3.

    private func renderHandles(_ state: BlockDecor.State, in textView: NSTextView) {
        // Handles exist only where a drop door does (the read tier renders
        // none). Two reveal regimes (13b 4D, S4-19 — her ruling):
        // - seams ON: every visible block's handle, statically — the
        //   recorded build-time call stands unchanged (boundaries-shown IS
        //   the working-with-blocks state; faint ink as before);
        // - seams OFF + the hover setting ON (default): the HOVERED
        //   block's handle reveals, in the stronger muted ink (the S4-1
        //   faint-invisibility finding); setting OFF = the fully clean
        //   surface. A drag in flight keeps its handle alive regardless —
        //   removing the view mid-drag would sever the event stream.
        let frames: [BlockDecor.Frame]
        if onMoveBlock == nil {
            frames = []
        } else if state.appearance.seamsVisible {
            frames = state.frames
        } else if let dragging = dragEntryIndex {
            frames = state.frames.filter { $0.entryIndex == dragging }
        } else if state.appearance.hoverHandles, let hoveredBlockID {
            frames = state.frames.filter { $0.blockID == hoveredBlockID }
        } else {
            frames = []
        }
        pool(&handleViews, count: frames.count, in: textView, below: false) {
            DragHandleView()
        }
        let tokens = state.appearance.tokens
        for (handle, frame) in zip(handleViews, frames) {
            handle.frame = CGRect(
                x: max(0, state.textLeft - 22), y: frame.frame.minY + 1,
                width: 18, height: 18)
            handle.inkColor = NSColor(
                state.appearance.seamsVisible ? tokens.faint : tokens.muted)
            let entryIndex = frame.entryIndex
            handle.onDragBegan = { [weak self] in self?.dragBegan(entryIndex: entryIndex) }
            handle.onDragMoved = { [weak self] point in self?.dragMoved(to: point) }
            handle.onDragEnded = { [weak self] point in self?.dragEnded(at: point) }
        }
    }

    // MARK: Hover reveal (13b 4D, S4-19)

    private var hoverTracker: HandleHoverTracker?
    private var hoverArea: NSTrackingArea?
    private(set) var hoveredBlockID: String?
    /// 13e E7: "the pointer is (not) in this surface", reported to whoever
    /// owns the decoration walk. The live editor's convenience init wires
    /// it to the model; a bare controller (tests, the read tier) leaves it
    /// nil and behaves exactly as before.
    var onPointerInside: ((Bool) -> Void)?

    /// The hover input, in text-view coordinates (internal so tests drive
    /// it without synthetic mouse events; nil = the pointer left).
    /// Re-renders the hover faces ONLY when the hovered block changes —
    /// mouse-moved cadence never re-renders per event (cost: one frames
    /// scan).
    ///
    /// 13e E7: the pointer's PRESENCE is reported separately from the
    /// hovered block, because the two answer different questions. The block
    /// resolves against `state.frames`, which the model only computes when
    /// something is decorated — so on a calm page (seams off, indicator off,
    /// no callouts, no comments, nothing picked) there are no frames to
    /// resolve against and no hover face could ever appear. `onPointerInside`
    /// tells the model the pointer is here, which is itself a reason to have
    /// geometry; the walk stays viewport-proportional and stops again the
    /// moment the pointer leaves.
    func noteHover(atY y: CGFloat?) {
        guard onMoveBlock != nil else { return }
        onPointerInside?(y != nil)
        let id = y.flatMap { y in
            state.frames.first {
                $0.frame.minY - 4 <= y && y <= $0.frame.maxY + 4
            }?.blockID
        }
        guard id != hoveredBlockID else { return }
        hoveredBlockID = id
        // Mid-drag, defer — renderHandles keeps the dragged handle; the
        // next render after drag end settles the reveal.
        guard dragEntryIndex == nil, let textView else { return }
        renderHandles(state, in: textView)
    }

    // MARK: The mode switch's arrival flash (18l-c U8 (a))

    /// The one flash on screen (a new arrival replaces it).
    private var flashView: DecorRectView?

    /// **Flash the caret's line** — the block highlight's own face (the wash
    /// fill, the accent border — `renderSelection`'s vocabulary), below the
    /// text like every decoration here, held for `ArrivalFlash.holdSeconds`
    /// and then faded by opacity alone over `fadeSeconds` (Reduce Motion: shown
    /// unanimated for the same total, then removed). Click-through, like every
    /// `DecorRectView`.
    func flashArrival(_ rect: CGRect, tokens: VoiceTokens) {
        guard let textView else { return }
        flashView?.removeFromSuperview()
        let view = DecorRectView()
        flashView = view
        textView.addSubview(view, positioned: .below, relativeTo: nil)
        view.frame = rect
        view.configure(fill: NSColor(tokens.wash), border: NSColor(tokens.accent), cornerRadius: 6)
        view.alphaValue = 1
        let plan = ArrivalFlash.plan(
            reduceMotion: NSWorkspace.shared.accessibilityDisplayShouldReduceMotion)
        #if DEBUG
        let key = "write|\(ObjectIdentifier(self))"
        let startedAt = Date()
        ArrivalFlashOracle.note(key, part: .fill, opacity: 1, startedAt: startedAt)
        ArrivalFlashOracle.note(key, part: .stroke, opacity: 1, startedAt: startedAt)
        #endif
        guard plan.animated else {
            DispatchQueue.main.asyncAfter(deadline: .now() + plan.total) { [weak self, weak view] in
                MainActor.assumeIsolated { self?.endFlash(view) }
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + plan.hold) { [weak self, weak view] in
            MainActor.assumeIsolated {
                guard let view, view.superview != nil else { return }
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = plan.fade
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    view.animator().alphaValue = 0
                } completionHandler: { [weak self, weak view] in
                    MainActor.assumeIsolated { self?.endFlash(view) }
                }
            }
        }
    }

    /// The flash is over: its view goes (only if it is still the one shown).
    private func endFlash(_ view: DecorRectView?) {
        guard let view else { return }
        view.removeFromSuperview()
        if flashView === view { flashView = nil }
    }

    #if DEBUG
    /// The flash view on screen now, for the pins.
    var arrivalFlashView: NSView? { flashView }
    #endif

    /// Grows/shrinks a view pool in place.
    private func pool<V: NSView>(
        _ views: inout [V], count: Int, in textView: NSTextView,
        below: Bool, make: () -> V
    ) {
        while views.count < count {
            let view = make()
            if below {
                textView.addSubview(view, positioned: .below, relativeTo: nil)
            } else {
                textView.addSubview(view)
            }
            views.append(view)
        }
        while views.count > count {
            views.removeLast().removeFromSuperview()
        }
    }

    // MARK: Drag (R19 — the insertion bar)

    private var dragEntryIndex: Int?

    private func dragBegan(entryIndex: Int) {
        dragEntryIndex = entryIndex
    }

    private func dragMoved(to point: CGPoint) {
        guard dragEntryIndex != nil, let textView,
              let boundary = BlockDecor.dropBoundary(
                at: point.y, frames: state.frames, entryCount: state.entryCount)
        else { return }
        let bar = insertionBar ?? {
            let bar = DecorRectView()
            insertionBar = bar
            return bar
        }()
        if bar.superview == nil { textView.addSubview(bar) }
        bar.configure(
            fill: NSColor(state.appearance.tokens.ring), border: nil, cornerRadius: 1)
        bar.frame = CGRect(
            x: state.textLeft, y: boundary.barY - 1.25,
            width: max(0, state.textRight - state.textLeft), height: 2.5)
    }

    private func dragEnded(at point: CGPoint) {
        insertionBar?.removeFromSuperview()
        insertionBar = nil
        guard let from = dragEntryIndex else { return }
        dragEntryIndex = nil
        guard let boundary = BlockDecor.dropBoundary(
            at: point.y, frames: state.frames, entryCount: state.entryCount)
        else { return }
        onMoveBlock?(from, boundary.index)
    }
}

// MARK: - Overlay views

/// A click-through rectangle: fill and/or border, rounded.
final class DecorRectView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    func configure(fill: NSColor?, border: NSColor?, cornerRadius: CGFloat) {
        layer?.backgroundColor = (fill ?? .clear).cgColor
        layer?.borderColor = border?.cgColor
        layer?.borderWidth = border == nil ? 0 : 1.5
        layer?.cornerRadius = cornerRadius
    }
}

/// A click-through dotted seam line (R6 — dotted, never a color band).
final class SeamLineView: NSView {
    var lineColor: NSColor = .separatorColor {
        didSet { needsDisplay = true }
    }

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.line(to: CGPoint(x: bounds.width, y: bounds.midY))
        path.lineWidth = 1.5
        path.setLineDash([1.5, 4], count: 2, phase: 0)
        lineColor.setStroke()
        path.stroke()
    }
}

// The comment face (`CommentCardView`) lives in `CommentCard.swift` since
// VX-179 U2 — the margin card re-formed for stacked entries with an inner
// scroll (R-VX179-1), its pure arrangement beside it.

/// The hover tracker (13b 4D, S4-19): an NSTrackingArea owner reporting
/// window-space pointer moves into the overlay controller. A plain
/// responder — never in the view hierarchy, never intercepts clicks (the
/// tracking area delivers moved/exited to its OWNER regardless of hit
/// testing, so the text surface's events are untouched).
final class HandleHoverTracker: NSResponder {
    var onHover: ((NSPoint?) -> Void)?

    override func mouseMoved(with event: NSEvent) {
        onHover?(event.locationInWindow)
    }

    override func mouseEntered(with event: NSEvent) {
        onHover?(event.locationInWindow)
    }

    override func mouseExited(with event: NSEvent) {
        onHover?(nil)
    }
}

/// The block drag handle (R19): "⠿" in the left gutter; dragging reports
/// superview-space points so the controller can place the insertion bar
/// and land the drop.
final class DragHandleView: NSView {
    var inkColor: NSColor = .tertiaryLabelColor {
        didSet { needsDisplay = true }
    }
    var onDragBegan: (() -> Void)?
    var onDragMoved: ((CGPoint) -> Void)?
    var onDragEnded: ((CGPoint) -> Void)?

    override func draw(_ dirtyRect: NSRect) {
        let glyph = "⠿" as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12), .foregroundColor: inkColor,
        ]
        let size = glyph.size(withAttributes: attributes)
        glyph.draw(
            at: CGPoint(x: (bounds.width - size.width) / 2,
                        y: (bounds.height - size.height) / 2),
            withAttributes: attributes)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .openHand)
    }

    override func mouseDown(with event: NSEvent) {
        onDragBegan?()
    }

    override func mouseDragged(with event: NSEvent) {
        guard let superview else { return }
        onDragMoved?(superview.convert(event.locationInWindow, from: nil))
    }

    override func mouseUp(with event: NSEvent) {
        guard let superview else { return }
        onDragEnded?(superview.convert(event.locationInWindow, from: nil))
    }
}
