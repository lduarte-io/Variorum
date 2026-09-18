//
//  ReadModeView.swift
//  Variorum
//
//  **READ — one tab, two faces** (the Act 10 correction round, her rulings
//  R-cor-5/7). Wave 2c shipped INDEX and READ as two tabs; she folded them
//  into ONE named Read — *"making it more similar to book, where it's a
//  selector within a place you're in. and the outline button could hide /
//  show the index, and the index could function as the outline"* — and
//  sharpened it: *"there is an editable index surface, then you click read
//  and it isn't anymore."* So this is the HOST of an in-place `edit · read`
//  switch, **opening on `edit` (RULED)** and remembering the face per note:
//
//  - **`edit`** — the editable index surface: the `▸ 01` column
//    (`NoteIndexColumn`, the Index tab's navigator she likes) beside a text
//    pane in which a clicked block goes LIVE in place (`ReadEditPane` — the
//    read-cheap→live upgrade through the ONE `PaneTextAuthority`; P-3).
//  - **`read`** — the calm page, NEVER editable: continuous (the wave-2c
//    paper — markdown rendered, boundaries gone) or PAGES (the book's paged
//    engine over this one note, `NotePagesView` — row 5, no second pager).
//    A click on a paragraph flips to `edit` at that block through the ONE
//    scrolled-open door (`LandingTarget`, batch B's brain — row 38).
//
//  The same `▸ 01` column stands beside either face behind the outline
//  toggle she loves (row 21); the old minimal outline and its mid-word
//  truncation (row 6) are gone with the tab. The current block is ONE fact
//  across the modes (row 39): the host ENTERS on `CommandRouter.focusedBlock`
//  and REPORTS its selection back through the same door.
//
//  P1: every face is a LazyVStack of per-block rows or the paged engine's
//  two leaves — cost ∝ viewport, never note size; zero TK2 geometry in any
//  scroll-sync (TEXTKIT2 §2's risk family deliberately avoided).
//

import SwiftUI
import VariorumCore

struct ReadModeView: View {
    /// The `.surface` acts this host renders (P-1's declared ⇔ rendered
    /// walk) — the column's ⋯ menu carries the TOC's archive/delete pair.
    static let surfaceCapabilities: [CapabilityID] = NoteIndexColumn.surfaceCapabilities

    /// The in-place switch. Raw values are the segment words and the
    /// per-note memory's stored form.
    enum Face: String, CaseIterable, Sendable {
        case edit
        case read
    }

    /// The `read` face's shape — continuous paper, or the book's leaves.
    /// Session/view state like the book's own `ReadForm` (13c: never
    /// persisted — QUESTIONS #43(b)/#45(e)); the face IS remembered.
    enum Form: String, CaseIterable, Sendable {
        case continuous
        case pages
    }

    /// Her ruling's letter: *"still default open to the index edit though."*
    /// Thereafter the face is remembered per note (the per-post mode
    /// memory's class — local, never synced; the architect's refinement,
    /// recorded PROVISIONAL for her walk).
    static func rememberedFace(postID: String, defaults: UserDefaults = .standard) -> Face {
        defaults.string(forKey: faceKey(postID)).flatMap(Face.init(rawValue:)) ?? .edit
    }

    static func remember(_ face: Face, postID: String, defaults: UserDefaults = .standard) {
        defaults.set(face.rawValue, forKey: faceKey(postID))
    }

    static func faceKey(_ postID: String) -> String { "readFace.\(postID)" }

    /// The contents column's remembered width (18d batch 3, her U-13). ONE
    /// posture for every note, like `readModeOutlineShown` beside it — how
    /// wide she wants a note's contents is how she reads, not a fact about
    /// one note. Local-only, never synced (the `CurrentBlockMemory` class).
    static let indexColumnWidthKey = "readModeIndexColumnWidth"

    /// The host's own coordinate space — the DEBUG geometry oracle reads
    /// block frames in it (a `.global` read inside a macOS `ScrollView`
    /// answers in the scroll view's own hosting space, not the window's —
    /// measured by the first cut of the pins, which clicked a column's
    /// width to the left of every block).
    nonisolated static let probeSpace = "variorum-read-host"

    let session: AppSession
    let postID: String
    /// "Jump to block in Write" — the detail switches to Write with the
    /// caret seeded (the standing hybrid primitive).
    var onJump: ((String) -> Void)?

    @State private var model: BlockTOCViewModel
    @State private var face: Face = .edit
    @State private var form: Form = .continuous
    /// The outline column — collapsible (her "I love that"), remembered
    /// across notes (a reading posture, not a per-note fact).
    @AppStorage("readModeOutlineShown") private var outlineShown = true
    /// The continuous page's type size step — a reading tool.
    @AppStorage("readModeTypeScale") private var typeScale = 1.0
    /// The CURRENT block on this surface (row 39's fact, mirrored here).
    @State private var selectedBlockID: String?
    /// One-shot scroll requests, one per consumer: the column and the
    /// mounted face each consume their own (two consumers of one nil-after-
    /// scroll request race each other — the wave-2c walk caught it).
    @State private var paneTarget: ReadLanding?
    @State private var pageTarget: ReadLanding?
    @State private var columnTarget: String?
    @State private var seeded = false
    /// 13u2b UNIT 3: what this surface knows about where the carried block
    /// sits — written at geometry cadence by the carried row and the face,
    /// read once at a mode switch. Unobserved on purpose (see the class).
    @State private var carryGeometry = ReadCarryGeometry()
    /// The registration behind that probe.
    @State private var placeProbeToken: UUID?
    /// A `read` click's landing, consumed by the `edit` face as it arrives.
    @State private var pendingLanding: LandingTarget?
    /// The registry's `readEditAttached` token while `edit` is on screen.
    @State private var editToken: UUID?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var page: ReadingPageTokens { scheme == .dark ? .dark : .light }

    init(
        session: AppSession, postID: String,
        onJump: ((String) -> Void)? = nil, model: BlockTOCViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.onJump = onJump
        _model = State(initialValue: model ?? BlockTOCViewModel(session: session, postID: postID))
    }

    private var rowsByID: [String: Queries.TOCRow] {
        Dictionary(uniqueKeysWithValues: model.rows.map { ($0.blockID, $0) })
    }

    var body: some View {
        VStack(spacing: 0) {
            faceBar
            // **18d batch 3 (her U-13): the contents column is the shared
            // LEADING side column** — *"table of contents in read mode for a
            // note is horizontally limited and not changable, should be
            // adjustable."* It was a fixed 340-pt slab beside a plain
            // `Divider`, so a long first line truncated mid-word and there
            // was nothing to do about it. Same three things, drawn by
            // `SideColumn`: our own line in every window state, `SeamGrip`'s
            // 14-pt grip and resize pointer on it, and the width she drags
            // remembered (240 … 640). `shown` is the outline toggle she
            // loves, unchanged, and the slide-in transition it animates now
            // comes from the column itself.
            SideColumn(
                tokens: tokens,
                shown: outlineShown,
                widthKey: Self.indexColumnWidthKey,
                subjectKey: postID,
                edge: .leading,
                ideal: NoteIndexColumn.width,
                minimum: NoteIndexColumn.minimumWidth
            ) {
                faceView
                    // 13u2b UNIT 3: the face IS the viewport the carried row's
                    // fraction is measured against — one rectangle, same space.
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .named(Self.probeSpace))
                    } action: { carryGeometry.noteViewport($0) }
            } panel: {
                NoteIndexColumn(
                    session: session, model: model, tokens: tokens,
                    selectedBlockID: selectedBlockID,
                    showsCount: face == .edit,
                    columnTarget: $columnTarget,
                    onSelect: { blockID in
                        // **A COLUMN CLICK IS NAVIGATION** (13u2 UNIT B, her
                        // item 19 — PROVISIONAL, QUESTIONS #110). Her two
                        // clauses only agree if the index highlight and the
                        // editing cursor can never name different blocks:
                        // clicking a row *"will also highlight the block on
                        // the right, which I do think is helpful"*, and *"the
                        // index highlight should follow where your editing
                        // cursor is"*. So a row click that names a DIFFERENT
                        // block than the live one releases the ring — the
                        // pane's text lands through the one coordinator, the
                        // clicked block wears the selection wash, and nothing
                        // is being edited until she clicks into it. Clicking
                        // the row of the block she is already in changes
                        // nothing.
                        if let live = model.liveBlockID, live != blockID { model.blur() }
                        select(blockID, scrollFace: true)
                    },
                    onJump: onJump)
                    .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                        #if DEBUG
                        ReadModeOracle.indexColumnFrames[postID] =
                            CGRect(origin: .zero, size: size)
                        #endif
                    }
            }
        }
        .background(tokens.room)
        .coordinateSpace(name: Self.probeSpace)
        // Ladder R1-9 (row 83's shape, the mode her ruling put beside Takes):
        // the rows are PRIMED by one bounded read before the observation
        // starts, and the sibling observations wait for it — Read arrives
        // painted instead of blank until the observations' first delivery.
        .task { await model.primeRows(); await model.start() }
        .task { await model.awaitPrimed(); await model.startTray() }
        .task { await model.awaitPrimed(); await model.startPools() }
        .onAppear {
            face = Self.rememberedFace(postID: postID)
            syncAttachment()
            // 13u2b UNIT 3: this surface can answer "where is the carried
            // block on your screen?" while it is mounted. The closure reads
            // the BOX, never this view's `@State` — an escaping closure holds
            // a snapshot of a struct's state, and a snapshot of where the page
            // was when Read mounted is exactly the wrong answer.
            if placeProbeToken == nil {
                let geometry = carryGeometry
                let id = postID
                placeProbeToken = session.commandRouter.registerBlockPlaceProbe {
                    geometry.place(postID: id)
                }
            }
            report()
        }
        .onDisappear {
            model.teardown()
            if let editToken {
                session.commandRouter.detachReadEdit(editToken)
                self.editToken = nil
            }
            if let placeProbeToken {
                session.commandRouter.unregisterBlockPlaceProbe(placeProbeToken)
                self.placeProbeToken = nil
            }
        }
        .onChange(of: model.rows) { _, rows in
            guard !seeded, !rows.isEmpty else { return }
            seeded = true
            // Arrive where she was (row 39: the ONE current block — Write's
            // caret, Takes' live pane, Blocks' focused row).
            let fact = session.commandRouter.focusedBlock
            let landing = (fact?.postID == postID ? fact?.blockID : nil)
                .flatMap { id in rows.contains { $0.blockID == id } ? id : nil }
            let target = landing ?? rows[0].blockID
            // 13u2b UNIT 3: **and at the HEIGHT she left it at**, when a mode
            // switch carried one for this very block. Nothing else takes it:
            // a column click, the `read` → `edit` click-through and a first
            // mount all keep this face's own standing anchor.
            let anchor = session.commandRouter
                .takeCarriedFraction(postID: postID, blockID: target)
                .map(ViewportCarry.anchor)
            select(target, scrollFace: true, report: false, anchor: anchor)
        }
        .onChange(of: face) { _, new in
            Self.remember(new, postID: postID)
            syncAttachment()
            if new == .read {
                // Nothing is live on the read-only face — the ring goes
                // (its pending text flushed through the ONE coordinator).
                model.blur()
            } else {
                landIfPending()
            }
            report()
        }
        .onChange(of: selectedBlockID) { _, _ in report() }
        // **THE INDEX HIGHLIGHT FOLLOWS THE EDITING CURSOR** (13u2 UNIT B —
        // her item 19, verbatim: *"the index highlight should follow where
        // your editing cursor is regardless of what your setting of showing it
        // on the editor is."*). It is the SECOND half of what she reported:
        // clicking a row on the left selects a block WITHOUT making it live,
        // so with a block already live the column highlighted one block while
        // her caret sat in another — *"the wrong index block on the left stays
        // highlighted"*, reproduced in the walk (capture 31).
        //
        // The ring is the authority; the selection follows it, never the other
        // way round, so every road that moves the ring — a click in the pane,
        // a landing, a programmatic `makeLive` — keeps the column honest with
        // one rule. The COLUMN scrolls to the row; the PANE deliberately does
        // not (clicking what you can see must not move it under you), and the
        // note's current-block fact is reported so the other modes land where
        // she was.
        .onChange(of: model.liveBlockID) { _, live in
            if let live, live != selectedBlockID {
                selectedBlockID = live
                columnTarget = live
                session.commandRouter.noteFocusedBlock(
                    live, variantID: rowsByID[live]?.variantID, postID: postID)
            }
            report()
        }
        .onChange(of: form) { _, _ in report() }
    }

    // MARK: - The face bar (the selector within the place you're in)

    private var faceBar: some View {
        HStack(spacing: 10) {
            Button(tokens.chromeLabel("outline")) {
                withAnimation(.easeInOut(duration: 0.18)) { outlineShown.toggle() }
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(outlineShown ? tokens.accent : tokens.muted)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                outlineShown ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                in: RoundedRectangle(cornerRadius: 6))
            .help("The note's index beside the page — fold it away and back")
            Divider().frame(height: 16)
            Picker("", selection: $face) {
                Text(tokens.chromeLabel("edit")).tag(Face.edit)
                Text(tokens.chromeLabel("read")).tag(Face.read)
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .fixedSize()
            .help("edit: the index beside the text — click a block to write in it. "
                + "read: the note as a page, nothing to edit")
            if face == .read {
                Picker("", selection: $form) {
                    Text(tokens.chromeLabel("continuous")).tag(Form.continuous)
                    Text(tokens.chromeLabel("pages")).tag(Form.pages)
                }
                .pickerStyle(.segmented)
                .controlSize(.small)
                .fixedSize()
                .help("Read the note as one continuous page, or as real pages "
                    + "with the text flowing across them")
                if form == .continuous {
                    Divider().frame(height: 16)
                    Button("Aa −") { typeScale = max(0.85, typeScale - 0.1) }
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .disabled(typeScale <= 0.86)
                        .help("Smaller type")
                    Button("Aa +") { typeScale = min(1.5, typeScale + 0.1) }
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .disabled(typeScale >= 1.49)
                        .help("Bigger type")
                }
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(tokens.card)
        .overlay(alignment: .bottom) { Divider().overlay(tokens.line) }
    }

    // MARK: - The faces

    @ViewBuilder
    private var faceView: some View {
        switch face {
        case .edit:
            ReadEditPane(
                model: model, tokens: tokens,
                indicator: ThemeStore.editingIndicator(of: themeStore),
                selectedBlockID: selectedBlockID,
                paneTarget: $paneTarget,
                carryGeometry: carryGeometry,
                onSelect: { blockID in select(blockID, scrollFace: false) })
        case .read:
            switch form {
            case .continuous:
                ReadPageColumn(
                    session: session, postID: postID, model: model,
                    page: page, tokens: tokens, typeScale: typeScale,
                    dark: scheme == .dark,
                    pageTarget: $pageTarget,
                    carriedBlockID: selectedBlockID,
                    carryGeometry: carryGeometry,
                    onOpenInEdit: { row in openInEdit(row) })
            case .pages:
                // Row 82: a page's paragraph is the same door as the
                // continuous page's — `edit` at that block.
                NotePagesView(session: session, postID: postID, onOpenInEdit: { blockID in
                    if let row = rowsByID[blockID] { openInEdit(row) }
                })
            }
        }
    }

    // MARK: - The current block (row 39) + the landing (row 38)

    private func select(
        _ blockID: String, scrollFace: Bool, report: Bool = true, anchor: UnitPoint? = nil
    ) {
        selectedBlockID = blockID
        // 13u2b UNIT 3: the carried row is the selected one; what was measured
        // for another row is not a fact about this one.
        carryGeometry.expect(blockID)
        if scrollFace {
            paneTarget = ReadLanding(blockID: blockID, anchor: anchor)
            pageTarget = ReadLanding(blockID: blockID, anchor: anchor)
            columnTarget = blockID
        }
        if report {
            session.commandRouter.noteFocusedBlock(
                blockID, variantID: rowsByID[blockID]?.variantID, postID: postID)
        }
    }

    /// The ruled click-through (R-cor-7): a click on a sentence in `read`
    /// flips to `edit` AT THAT BLOCK, live — the ONE scrolled-open door's
    /// value, consumed as the `edit` face arrives.
    private func openInEdit(_ row: Queries.TOCRow) {
        session.commandRouter.noteFocusedBlock(
            row.blockID, variantID: row.variantID, postID: postID)
        pendingLanding = LandingTarget(postID: postID, blockID: row.blockID)
        face = .edit
    }

    private func landIfPending() {
        guard let landing = pendingLanding, landing.postID == postID else { return }
        pendingLanding = nil
        guard let target = landing.blockID ?? model.rows.first?.blockID else { return }
        select(target, scrollFace: true, report: false)
        if let row = rowsByID[target], let variantID = row.variantID, !row.variantLocked {
            model.makeLive(target, variantID: variantID)
        }
    }

    /// The registry hears which face is on screen (`readEditAttached`).
    private func syncAttachment() {
        switch face {
        case .edit:
            if editToken == nil { editToken = session.commandRouter.attachReadEdit() }
        case .read:
            if let editToken {
                session.commandRouter.detachReadEdit(editToken)
                self.editToken = nil
            }
        }
    }

    private func report() {
        #if DEBUG
        ReadModeOracle.face = face
        ReadModeOracle.form = form
        ReadModeOracle.selectedBlockID = selectedBlockID
        ReadModeOracle.liveBlockID = model.liveBlockID
        #endif
    }
}

#if DEBUG
/// The correction round's Read oracle (the `MastheadGeometry` pattern): the
/// mounted host's face, form, selection and live block — so a pin asserts
/// what she sees, per face, not a state the code merely intends.
@MainActor
enum ReadModeOracle {
    static var face: ReadModeView.Face?
    static var form: ReadModeView.Form?
    static var selectedBlockID: String?
    static var liveBlockID: String?
    /// Each face's block frames in the host's own named space, so a pin
    /// can CLICK a block for real — the rig's synthesized events.
    static var pageBlockFrames: [String: CGRect] = [:]
    static var editBlockFrames: [String: CGRect] = [:]
    /// Ladder R1-5: how many leaves the pages face turned by its arrow keys.
    static var pageTurns = 0
    /// Ladder R1-9: when the `edit` face painted its FIRST row (the Blocks
    /// arrival measure's shape).
    static var firstEditRowPaintedAt: Date?
    /// 18d batch 3 (her U-13): what the CONTENTS COLUMN actually drew. "It
    /// is the width she left it at" is a claim about a rectangle, so the pin
    /// reads the rectangle, never `NoteIndexColumn.width`. Keyed by the
    /// NOTE's id: suites run in parallel, so a pin must read its own note's.
    static var indexColumnFrames: [String: CGRect] = [:]

    static func reset() {
        face = nil
        form = nil
        selectedBlockID = nil
        liveBlockID = nil
        pageBlockFrames = [:]
        editBlockFrames = [:]
        pageTurns = 0
        firstEditRowPaintedAt = nil
        indexColumnFrames = [:]
    }
}
#endif

/// **What Read knows about where the carried block sits** (13u2b UNIT 3) —
/// the geometry the mode-switch carry's CAPTURE half reads.
///
/// Two rectangles in the host's own named space: the face's own frame (the
/// viewport) and the CARRIED row's frame. Only the carried row reports, so
/// this is one write per scroll frame, not one per realized row.
///
/// Not observed, deliberately — it is written at geometry cadence and read
/// once, at a mode switch, by a closure. An observed property here would
/// re-render the note on every scroll frame, which is the 7 Hz loop row 53
/// already paid for once (`FlowRowHeights` carries the same note).
@MainActor
final class ReadCarryGeometry {
    private var viewport: CGRect = .zero
    private var carried: (blockID: String, frame: CGRect)?

    func noteViewport(_ frame: CGRect) { viewport = frame }

    func noteRow(_ blockID: String, _ frame: CGRect) { carried = (blockID, frame) }

    /// The selection moved: what was measured is about another row now. (The
    /// carry is also blockID-checked when it is consumed, so this is belt and
    /// braces — but a box that can hold a fact about a row nobody is on is a
    /// box the next reader has to reason about.)
    func expect(_ blockID: String?) {
        guard let blockID else {
            carried = nil
            return
        }
        if carried?.blockID != blockID { carried = nil }
    }

    /// The place, in the one sense `ViewportCarry` means — nil when nothing
    /// has been measured yet, or the row is off screen.
    func place(postID: String) -> ViewportCarry.Place? {
        guard let carried, viewport.height > 0 else { return nil }
        guard let fraction = ViewportCarry.fraction(
            blockTop: Double(carried.frame.minY - viewport.minY),
            blockHeight: Double(carried.frame.height),
            viewportHeight: Double(viewport.height))
        else { return nil }
        return ViewportCarry.Place(
            postID: postID, blockID: carried.blockID, fraction: fraction)
    }
}

/// **Where a face's landing means to put a block** (13u2b UNIT 3): the block,
/// and — when a mode switch carried one — the viewport fraction it had in the
/// mode she left. `nil` is each face's own standing anchor, which is what
/// every other road onto a landing keeps (a column click, the `read` → `edit`
/// click-through, a first mount).
struct ReadLanding: Equatable {
    let blockID: String
    var anchor: UnitPoint?
}

/// What a Read geometry probe reports — the slot a frame belongs to.
/// Always compiled (the modifier's signature names it); the oracle that
/// stores the frames is DEBUG-only.
enum ReadModeProbeSlot: Hashable {
    case pageBlock(String)
    case editBlock(String)
}

extension View {
    /// The Read oracle's DEBUG frame write (the masthead probe's shape): a
    /// no-op outside DEBUG.
    @ViewBuilder
    func readModeGeometryProbe(_ slot: ReadModeProbeSlot) -> some View {
        #if DEBUG
        self.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(ReadModeView.probeSpace))
        } action: { frame in
            switch slot {
            case .pageBlock(let id): ReadModeOracle.pageBlockFrames[id] = frame
            case .editBlock(let id):
                if ReadModeOracle.firstEditRowPaintedAt == nil {
                    ReadModeOracle.firstEditRowPaintedAt = Date()
                }
                ReadModeOracle.editBlockFrames[id] = frame
            }
        }
        #else
        self
        #endif
    }
}

// MARK: - The continuous page (the wave-2c paper, kept)

/// The calm page: the voice-independent `ReadingPageTokens` paper (the
/// book flow's own look, per R2), a LazyVStack of per-block rows, the
/// column's click landing the page on its block, a paragraph click opening
/// `edit` there. No count line but the header's (row 36: the old footer
/// said the same facts twice).
private struct ReadPageColumn: View {
    let session: AppSession
    let postID: String
    let model: BlockTOCViewModel
    let page: ReadingPageTokens
    let tokens: VoiceTokens
    let typeScale: Double
    let dark: Bool
    @Binding var pageTarget: ReadLanding?
    /// 13u2b UNIT 3: the block the mode-switch carry is about (the note's
    /// current one) — only that row measures itself.
    let carriedBlockID: String?
    let carryGeometry: ReadCarryGeometry
    let onOpenInEdit: (Queries.TOCRow) -> Void

    private var totalWords: Int {
        model.rows.reduce(0) { $0 + Queries.wordCount($1.text ?? "") }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14 * typeScale) {
                    ReadPageHeader(session: session, postID: postID, page: page,
                                   words: totalWords)
                    // Ladder R1-3: the ForEach identity (the placement id)
                    // is the landing anchor — no explicit `.id` on the row.
                    ForEach(Array(model.rows.enumerated()), id: \.element.placementID) { i, row in
                        ReadPageBlock(
                            page: page, typeScale: typeScale,
                            blockID: row.blockID,
                            text: row.text ?? "", ordinal: i + 1,
                            carried: row.blockID == carriedBlockID,
                            carryGeometry: carryGeometry,
                            onOpenInEdit: { onOpenInEdit(row) })
                    }
                    Text("· · ·")
                        .font(page.serif)
                        .foregroundStyle(page.pageMeta)
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 700)
                .padding(.horizontal, 60)
                .padding(.vertical, 46)
                .background(page.paper)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: .black.opacity(dark ? 0 : 0.10), radius: 12, y: 3)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
            }
            // 13u2 UNIT B (her item 19): the room behind the CREAM PAGE is the
            // voice's own, never a palette's — *"leave that white so that the
            // cream read page isn't on a colorful background."* The host still
            // paints `tokens.room` for the `edit` face, whose column and pane
            // cover it; this is the one face where the room shows.
            .background(ReadingPageTokens.room(voice: tokens.voice, dark: dark))
            .onChange(of: pageTarget) { _, target in
                guard let target else { return }
                // Ladder R1-3: unanimated, on the row's identity (the Outline
                // lesson — the pin measured the animated landing drifting).
                land(target, proxy)
                pageTarget = nil
            }
            .task {
                await Task.yield()
                guard let target = pageTarget else { return }
                land(target, proxy)
                pageTarget = nil
            }
        }
    }
}

extension ReadPageColumn {
    /// This page's own standing anchor: near the top, with a little air above.
    static let restingAnchor = UnitPoint(x: 0.5, y: 0.08)

    /// The landing: the block's row identity (its placement id), unanimated,
    /// anchored near the top of the page — or, when a mode switch carried a
    /// height for this block, at that fraction of the viewport instead
    /// (13u2b UNIT 3; `scrollTo`'s anchor IS the fraction, so nothing about
    /// the landing's mechanism changes).
    private func land(_ target: ReadLanding, _ proxy: ScrollViewProxy) {
        guard let placementID = model.rows
            .first(where: { $0.blockID == target.blockID })?.placementID
        else { return }
        proxy.scrollTo(placementID, anchor: target.anchor ?? Self.restingAnchor)
    }
}

/// The page's header: title + kicker on the paper. The kicker's reading
/// time is `words ÷ 200` rounded up — a fixed 200-wpm convention (adult
/// silent reading), not measured (R-cor-4(e); it stays here by her word).
private struct ReadPageHeader: View {
    let session: AppSession
    let postID: String
    let page: ReadingPageTokens
    let words: Int

    @State private var title = DisplayTitle.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(page.serifTitle)
                .foregroundStyle(page.ink)
            Text("\(words) words · about \(max(1, Int((Double(words) / 200).rounded(.up)))) minute\(words > 200 ? "s" : "")")
                .font(.system(size: 11.5))
                .foregroundStyle(page.pageMeta)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
        .task(id: postID) {
            let read = try? await session.database.read { [postID] db in
                try Queries.noteDisplayTitle(db, id: postID)
            }
            title = read ?? DisplayTitle.placeholder
        }
    }
}

/// One block's paragraphs on the paper: markdown via the one transform, a
/// quiet hover wash + gutter ordinal, one generous click target that flips
/// the face to `edit` at this block (the ruled behavior).
private struct ReadPageBlock: View {
    let page: ReadingPageTokens
    let typeScale: Double
    let blockID: String
    let text: String
    let ordinal: Int
    /// 13u2b UNIT 3: this is the note's current block, so its frame is what a
    /// mode switch asks about. Only this row pays for a geometry report.
    let carried: Bool
    let carryGeometry: ReadCarryGeometry
    let onOpenInEdit: () -> Void

    @State private var hovering = false

    /// Ladder R1-3: rendered SYNCHRONOUSLY (a pure transform, cost ∝ the
    /// realized rows) — deferred, every row stood one line tall for its
    /// first frame and grew after, the estimate drift that moved a far
    /// landing (see `ReadEditBlock`).
    private var paragraphs: [FlowParagraph] {
        FlowParagraph.paragraphs(of: text, codeTint: page.codeTint)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11 * typeScale) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(font(paragraph))
                    .foregroundStyle(page.ink)
                    .lineSpacing(6 * typeScale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ").font(page.serif)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            hovering ? AnyShapeStyle(page.pageMeta.opacity(0.10)) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 6))
        .overlay(alignment: .topLeading) {
            if hovering {
                Text(String(format: "%02d", ordinal))
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundStyle(page.pageMeta)
                    .offset(x: -36, y: 6)
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
        .onTapGesture { onOpenInEdit() }
        .readModeGeometryProbe(.pageBlock(blockID))
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(ReadModeView.probeSpace))
        } action: { frame in
            if carried { carryGeometry.noteRow(blockID, frame) }
        }
        .help("Click to edit this paragraph — the page turns to edit with this block live")
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
    }

    /// The page's type at the rail's scale — a look decision, view-local
    /// (the `maxDrawnIndentLevel` doctrine: look lives with the look).
    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(
                size: (15 * scale * typeScale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return .system(size: (16 * typeScale).rounded(), design: .serif)
        }
    }
}
