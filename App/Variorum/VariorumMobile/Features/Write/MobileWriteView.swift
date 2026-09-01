//
//  MobileWriteView.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 1: the SwiftUI face of the continuous Write
//  surface — a representable over `MobileWriteSurfaceView` (the
//  keyboard-avoiding container) wiring the UITextViewDelegate gate into
//  the view model. Functional and unstyled (the look track owns beauty).
//
//  The Phase 8 capture views are UNTOUCHED — they keep working until S3
//  replaces them; batch 1 reaches this surface through a DEBUG-gated door
//  beside the spike's (the Stage 0 precedent), so her feel round can open
//  it without the app shape existing yet.
//

import SwiftUI
import VariorumCore

struct MobileWriteView: UIViewRepresentable {
    let model: MobileEditorViewModel

    func makeUIView(context: Context) -> MobileWriteSurfaceView {
        let surface = MobileWriteSurfaceView()
        // The gate delegate is the VM's own since batch 2 (`attach` installs
        // it) — the SwiftUI face carries no police of its own, so every host
        // of the surface polices identically.
        model.attach(textView: surface.textView)
        return surface
    }

    func updateUIView(_ uiView: MobileWriteSurfaceView, context: Context) {}
}

/// The Write screen: the surface under a voiced masthead (batch 3 — the
/// look canon lands: the voice room, the title in the voice's title type,
/// status rows in the chrome register). Since S3 batch 1 this is THE
/// app's editor (the shell pushes it for every note; the S1 DEBUG door
/// retired): the shell router registers the active editor for the
/// app-level background flush, `beginEditing` raises the keyboard on
/// arrival (the Today door's straight-into-typing invitation), and the
/// masthead's voice-switch door RETIRED to Settings (P11's placement —
/// recorded; the shell router is the one voice authority, so an open
/// surface follows a Settings flip via `applyVoiceChange`).
struct MobileWriteScreen: View {
    /// The seal door's words (parity A3, P26/P43 — PA1-1 resolved: the
    /// A1 door's system-register strings join the ONE voice register;
    /// rendered through `tokens.chromeLabel`, pinned. Accessibility
    /// labels stay plain — VoiceOver reads words, not chrome styling).
    static let sealedStateLine = "This note is locked — reading only."
    static let unlockDoorTitle = "Unlock Note"
    static let lockDoorTitle = "Lock Note"

    @State private var model: MobileEditorViewModel
    /// The membership chip's model (parity C2 — the masthead wears the
    /// chip; the sheet carries the acts).
    @State private var membership: MobileMembershipModel
    @State private var membershipPresented = false
    /// Rename note (parity C2): the title IS the door; the alert's field.
    @State private var renamePresented = false
    @State private var renameField = ""
    /// Entry date (parity C2, her sitting item 4): the date chip's alert.
    @State private var datePresented = false
    @State private var dateField = ""
    /// The note's tags (parity C3 — "tag posts", leaf-chip grammar): the
    /// chip's model and its sheet.
    @State private var noteTags: MobileNoteTagsModel
    @State private var tagsPresented = false
    /// The note's references (parity C3 — the "More info" list): the
    /// chip's model and its sheet.
    @State private var references: MobileReferencesModel
    @State private var referencesPresented = false
    /// The in-note block list (parity C4b item 5 — her ruling 11): the
    /// chip's model and its sheet; a tap jumps the editor there.
    @State private var blockList: MobileBlockListModel
    @State private var blocksPresented = false
    /// **The per-note TRAY** (round 2 batch 6b — §69.3's ruled shape): this
    /// note's archived and leaving blocks, reached through the SAME sheet as
    /// the block list, because all three are one subject in three states
    /// (the design record's Q8 candidate — see `MobileBlockList.swift`).
    @State private var tray: MobileNoteTrayModel
    /// Lenses (parity C5 — her top-bar sketch, the ruled saved-peek
    /// shape): the chip's model and its sheet; the active lens is
    /// session-local (evaporates with this screen — M9's lifetime).
    @State private var lenses: MobileLensesModel
    @State private var lensesPresented = false
    /// The session, held for the leaving road (PR7 — `savepointOnLeaving`
    /// is `AppSession`'s, and `onDisappear` is one of the phone's two
    /// leavings). Everything else here reaches the store through the models
    /// built from it at init.
    private let session: AppSession
    /// The shell's voice authority; nil in harness/preview use, where the
    /// stored preference read at init governs.
    private let router: MobileShellRouter?
    private let beginEditing: Bool
    /// The OWNING tab stack (S3 ladder BLOCKER): liveness registration
    /// carries the stack's identity, passed by the shell's per-stack
    /// destination builder — never read from the visible-tab state.
    private let tab: MobileTab
    /// Push another note on the owning stack (the diverged copy's landing
    /// — R67); nil in harness/preview use.
    private let onOpenNote: ((String) -> Void)?
    /// **The note went (round 2 batch 4 — PR1).** A surface standing on a
    /// tombstoned note is the one thing the delete door must never leave
    /// behind, so the shell pops this screen off its OWNING stack. nil in
    /// harness/preview use (the pins call the model door directly and
    /// assert the callback fired).
    private let onDeleted: (() -> Void)?
    /// **Note ▸ Versions (batch 6c)** — the shell pushes the note's moments
    /// onto the OWNING stack; nil in harness/preview use.
    private let onOpenVersions: (() -> Void)?
    /// The ⋯ sheet (M20's persistent undo/redo door + PR1's Delete Note… +
    /// batch 6c's two time controls).
    @State private var noteActionsPresented = false
    private let fallbackVoice: ThemeVoice
    @Environment(\.colorScheme) private var scheme

    /// `editor` is a TEST SEAM and nothing else: production passes nothing
    /// and this screen mints its own model, exactly as it always has. The
    /// pins hand in the model they already drove, so the surface under test
    /// is the app's own screen showing the app's own state — which is the
    /// whole of §15's trap (b): *mount the real surface and drive the real
    /// control.* Without it a pin would host a SECOND model over the same
    /// post and assert against a receipt nothing had written.
    init(
        session: AppSession, postID: String,
        router: MobileShellRouter? = nil, beginEditing: Bool = false,
        tab: MobileTab = .shelf,
        onOpenNote: ((String) -> Void)? = nil,
        onDeleted: (() -> Void)? = nil,
        onOpenVersions: (() -> Void)? = nil,
        editor injected: MobileEditorViewModel? = nil
    ) {
        let editor = injected ?? MobileEditorViewModel(session: session, postID: postID)
        _model = State(initialValue: editor)
        _membership = State(initialValue: MobileMembershipModel(session: session, postID: postID))
        _noteTags = State(initialValue: MobileNoteTagsModel(session: session, postID: postID))
        _references = State(initialValue: MobileReferencesModel(session: session, postID: postID))
        _blockList = State(initialValue: MobileBlockListModel(session: session, postID: postID))
        _tray = State(initialValue: MobileNoteTrayModel(session: session, postID: postID))
        _lenses = State(initialValue: MobileLensesModel(
            session: session, postID: postID, editor: editor))
        self.session = session
        self.router = router
        self.beginEditing = beginEditing
        self.tab = tab
        self.onOpenNote = onOpenNote
        self.onDeleted = onDeleted
        self.onOpenVersions = onOpenVersions
        // The live phone voice governs from the first materialization —
        // set BEFORE the surface exists (makeUIView runs later). With a
        // router the value is already authoritative (idempotent).
        let stored = router?.voice ?? MobileVoicePreference.current()
        MobileEditorStyle.voice = stored
        fallbackVoice = stored
    }

    /// The SwiftUI chrome's tokens — dark rides the system scheme (R51's
    /// black rooms come from the token layer's own dark values). Reading
    /// `router.voice` keeps the masthead live under a Settings flip.
    private var tokens: VoiceTokens {
        .resolve(voice: router?.voice ?? fallbackVoice, dark: scheme == .dark)
    }

    var body: some View {
        MobileWriteView(model: model)
            .ignoresSafeArea(.keyboard) // the container's keyboardLayoutGuide owns avoidance
            .background(tokens.room.ignoresSafeArea())
            .safeAreaInset(edge: .top) { masthead }
            .task {
                // Wiring COMPLETES before the infinite observation loops
                // (S3 ladder, MAJOR 2 — `start()` never returns while the
                // editor lives, so nothing may be sequenced after it):
                // liveness registration first (the authority flushes any
                // same-post sibling's pending text), then the arrival
                // routine (authoritative first load + the Today door's
                // focus raise — a sealed note's gate still refuses and
                // speaks; raising focus never bypasses the police), then
                // the loops, last, forever.
                if let router {
                    await router.editors.register(model, tab: tab)
                }
                await model.arrive(focus: beginEditing)
                await model.start()
            }
            .onDisappear {
                let model = model
                let session = session
                router?.editors.deregister(model)
                // **PR7 — the OTHER leaving road** (round 2 batch 4). The
                // note is popped or replaced: land what is pending, then
                // leave one quiet savepoint per take that changed, through
                // the ONE shared entry (`AppSession.savepointOnLeaving`,
                // 13j J11). It runs AFTER `teardown` because teardown is
                // the S1 backstop that mints the open tail and attaches
                // trailing runs — a savepoint taken before it would miss
                // the paragraph she was still typing.
                //
                // `savepointOnLeaving` never throws (a leaving is not a
                // moment to refuse at) and its own flush is a no-op on the
                // coordinator teardown just drained.
                Task {
                    await model.teardown()
                    await session.savepointOnLeaving(model.postID)
                }
            }
    }

    private var masthead: some View {
        // The documented `@Bindable` local (round 2 batch 4): `$door.…` is a
        // REAL observation dependency, which is exactly what the Mac's
        // computed-`Binding` purge dialogs lack (§15's trap (a)).
        @Bindable var door = model.undoDoor
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                // Rename note (parity C2 — "full app functionality"): the
                // title IS the door; an alert confirms, so a stray tap
                // costs nothing. The field edits the STORED title (the
                // display title may be derived — DisplayTitle's brain).
                Button {
                    renameField = model.header?.title ?? ""
                    renamePresented = true
                } label: {
                    Text(model.displayTitle ?? "")
                        .font(tokens.title)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rename Note")
                Spacer(minLength: 12)
                // The note-tool corner (M3 ≡ R6 joins it): copy · find ·
                // seal, spaced so three small glyphs stay three separate
                // taps.
                HStack(spacing: 14) {
                    copyDoor
                    findDoor
                    sealDoor
                    noteActionsDoor
                }
            }
            // The note's primary home reads alone (full width for
            // "in N books"); the FIVE identity chips — date · tags ·
            // more info · blocks · lens — ride ONE wrapping flow (D2,
            // the routed PC4b-4/PC5-5 crowding answer: OVERFLOW — the
            // chips wrap when their content grows, so nothing clips and
            // no door hides; calm at rest, five bare words fit one
            // line. PROVISIONAL for her sitting).
            membershipChip
            MobileChipFlow(hSpacing: 12, vSpacing: 4) {
                dateChip
                tagsChip
                moreInfoChip
                blocksChip
                lensChip
            }
            if let canary = model.canaryMessage {
                Text(canary).font(tokens.small).foregroundStyle(.red)  // CANARY: deliberately not the voice's alarm
            }
            if model.isSealed {
                // The state line pairs with its door (the 13b fire-and-DO
                // doctrine: a message naming an act offers the act) —
                // every sealed refusal on this screen says "unlock it",
                // and the door stands right here in the masthead. Both
                // render voice-cased (P26/P43 — PA1-1 resolved).
                HStack(spacing: 10) {
                    Text(tokens.chromeLabel(Self.sealedStateLine))
                        .font(tokens.small).foregroundStyle(tokens.muted)
                    Button {
                        let model = model
                        Task { await model.unlockNote() }
                    } label: {
                        Text(tokens.chromeLabel(Self.unlockDoorTitle))
                    }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Unlock Note")
                }
            }
            // **THE RECEIPT, and since round 2 batch 4 its ACTION** (M20 ≡
            // her R10): *"the phone ALREADY shows a receipt after a
            // structural act … and an Undo action on that receipt is the
            // standard iOS shape."*
            //
            // The row renders for EITHER half. Several structural acts —
            // divide, merge, Make Block, the cross-block edit — deliberately
            // say nothing (the text rearranging on screen is the report),
            // and they now carry a BARE Undo: the way back with no new
            // chatter, which is both the calmer surface and the reason every
            // shipped "this act says nothing" pin stays true.
            //
            // The button's WORDS come from the live stack, so it can never
            // name an entry that has since moved, and it renders only while
            // the stack really holds that end (P-2).
            if model.statusMessage != nil || model.statusAction != nil {
                HStack(spacing: 10) {
                    if let status = model.statusMessage {
                        Text(status).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    receiptAction
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // The A3 spacing floor: the canon's masthead frame (`.notetitle
        // padding:10px 20px 2px` + the prose's 8 below it) — h20 where
        // the system default (~16) sat, real top air under the safe
        // area, bottom 8.
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(tokens.room)
        .alert("Rename Note", isPresented: $renamePresented) {
            TextField("Title", text: $renameField)
            Button("Rename") {
                let title = renameField
                let model = model
                Task { await model.renameNote(title) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(MobileEditorViewModel.blankTitleClearsMessage)
        }
        .sheet(isPresented: $membershipPresented) {
            MobileMembershipSheet(
                model: membership, tokens: tokens, onOpenNote: onOpenNote)
        }
        .sheet(isPresented: $tagsPresented) {
            MobileNoteTagsSheet(model: noteTags, tokens: tokens)
        }
        .sheet(isPresented: $referencesPresented) {
            MobileReferencesSheet(model: references, tokens: tokens)
        }
        // **THE HOST HEALS THE LENS CHIP'S ⚠** (the 6b cold review's MINOR
        // 2). The masthead's fallback marker reads `MobileLensesModel.rows`,
        // and `rows` is written by `refresh()` alone — whose only external
        // caller is the lens sheet's own `.task`. This batch then shipped
        // two doors that change a pick's LIVE-ness without touching a lens:
        // the tray's Put back on a deleted take, and its Delete Now. So a
        // pick could stop dangling while the chip kept announcing a fallback
        // that no longer existed — to VoiceOver as well as to the eye —
        // until she happened to reopen the sheet.
        //
        // The refresh rides the sheet's DISMISSAL, and both halves of that
        // are deliberate:
        //   · **the HOST does it, not the tray.** A refresh fired from
        //     `putBackTake` would be a feature-to-feature call; this screen
        //     composes both features and is the only place allowed to know
        //     they meet (CLAUDE.md's composition rule).
        //   · **at dismissal, not at mount.** The chip is BEHIND the sheet
        //     while it is up (the presented tree is the whole screen), so
        //     the stale marker becomes visible at exactly this moment — and
        //     a `.task` on this screen would not fire at all: presenting and
        //     dismissing a sheet never re-runs the presenter's task, and at
        //     mount no lens is active yet (`activeLensID` starts nil), so a
        //     mount-time read could not change the marker either way.
        // One bounded post-scoped read (`refresh()`'s own cost note), once
        // per sheet close.
        .sheet(isPresented: $blocksPresented, onDismiss: {
            let lenses = lenses
            Task { await lenses.refresh() }
        }) {
            // PR20's act is injected HERE, not called from inside the sheet:
            // this screen composes the block list and the structural
            // controller, and it is the only place allowed to know they meet
            // (CLAUDE.md's composition rule — a call from the list into
            // `model.structural` would be feature-to-feature). The road
            // itself is the one that already exists: `deleteWholeBlockRun`
            // carries the ONE compound undo entry, the flight latch, the
            // flush-first contract, the caret landing and the receipt.
            MobileBlockListSheet(
                model: blockList, tokens: tokens, tray: tray,
                onDeleteBlocks: { blockIDs in
                    // The road ANSWERS (the fix wave, MINOR 3): the sheet
                    // puts picking mode away on a landing and keeps her
                    // picks on a refusal, and that difference is the act's
                    // to report, never a re-read's to infer.
                    await model.structural.deleteWholeBlockRun(blockIDs)
                }
            ) { blockID in
                blocksPresented = false
                model.jumpToBlock(blockID)
            }
        }
        .sheet(isPresented: $lensesPresented) {
            MobileLensSheet(model: lenses, tokens: tokens)
        }
        .sheet(isPresented: $noteActionsPresented) {
            MobileNoteActionsSheet(
                door: model.undoDoor, model: model, tokens: tokens,
                onDeleted: { onDeleted?() },
                onOpenVersions: { onOpenVersions?() })
                .presentationDetents([.medium, .large])
        }
        // A12's destructive-undo warning for the RECEIPT's button (the ⋯
        // sheet hosts its own twin; each binds to the surface that asked,
        // so exactly one presents). The binding is `@Bindable`-projected —
        // never the Mac's computed-Binding road (§15's trap (a)).
        .alert(
            model.undoDoor.pendingWarning.map(
                { StructuralUndoCopy.discardingUndoQuestion($0.warning) }) ?? "",
            isPresented: $door.warningAtReceipt
        ) {
            Button("Undo", role: .destructive) {
                let door = model.undoDoor
                Task { await door.confirmPendingUndo() }
            }
            Button("Cancel", role: .cancel) { model.undoDoor.cancelPendingUndo() }
        } message: {
            Text(model.undoDoor.pendingWarning.map(
                { MobileUndoDoor.discardingUndoDetail($0.warning) }) ?? "")
        }
        .alert("Entry Date", isPresented: $datePresented) {
            TextField("2026-08-09", text: $dateField)
                .keyboardType(.numbersAndPunctuation)
            Button("Set") {
                let day = dateField
                let model = model
                Task { await model.setEntryDate(day) }
            }
            Button("Clear Date") {
                let model = model
                Task { await model.setEntryDate(nil) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A date makes this a day's entry — journals sort by it. Plain days only (2026-08-09); Clear leaves the note undated.")
        }
    }

    /// The entry-date chip (parity C2, her sitting item 4 — set AND
    /// clear). Placement: beside the books chip on the masthead's
    /// identity line — the date is note identity exactly as membership
    /// is, and the alert-confirmed chip is the rename door's own grammar.
    private var dateChip: some View {
        Button {
            dateField = model.header?.entryDate ?? ""
            datePresented = true
        } label: {
            Text(model.header?.entryDate ?? tokens.chromeLabel("no date"))
                .font(tokens.small)
                .foregroundStyle(model.header?.entryDate != nil ? tokens.muted : tokens.faint)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Entry Date")
    }

    /// The tags chip (parity C3 — "tag posts", the LK5 expansion's "full
    /// app functionality"): the note's tags as LEAF-only chips (13k K3's
    /// grammar; the full paths live in the sheet, where hierarchy is
    /// surfaced). Tap → the tags sheet (apply by typing or suggestion,
    /// remove with ✕).
    private var tagsChip: some View {
        Button {
            tagsPresented = true
        } label: {
            Text(tokens.chromeLabel(noteTags.chipLine ?? "tags"))
                .font(tokens.small)
                .foregroundStyle(noteTags.chipLine != nil ? tokens.muted : tokens.faint)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tags")
        .task(id: model.postID) { await noteTags.refresh() }
    }

    /// The "more info" chip (parity C3 — her own name for the surface):
    /// the note's kept links and files, one tap away; the count rides
    /// the word when any exist.
    private var moreInfoChip: some View {
        Button {
            referencesPresented = true
        } label: {
            Text(tokens.chromeLabel(
                MobileReferencesModel.chipLabel(count: references.references.count)))
                .font(tokens.small)
                .foregroundStyle(references.references.isEmpty ? tokens.faint : tokens.muted)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More Info")
        .task(id: model.postID) { await references.refresh() }
    }

    /// The membership chip (parity C2): which books hold this note — the
    /// voice's path grammar for the single-book case (the Mac label's own
    /// rule), accent ink when the note appears in several.
    private var membershipChip: some View {
        Button {
            membershipPresented = true
        } label: {
            Text(tokens.chromeLabel(chipLabel))
                .font(tokens.small)
                .foregroundStyle(membership.books.count > 1 ? tokens.accent : tokens.muted)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Books holding this note")
        .task(id: model.postID) { await membership.refresh() }
    }

    private var chipLabel: String {
        let names = membership.books.map(\.name)
        if names.count == 1, !tokens.pathPrefix.isEmpty {
            return tokens.path([names[0]])
        }
        return MobileMembershipModel.labelText(bookNames: names)
    }

    /// The blocks chip (parity C4b item 5 — her ruling 11): the in-note
    /// block list's door, on the masthead's second identity line beside
    /// tags and more info. Deliberately the bare voiced WORD — no count
    /// (the chip refreshes at sheet cadence, not keystroke cadence; a
    /// stale census on the masthead would be worse than none, and the
    /// list itself is the census — recorded judgment).
    private var blocksChip: some View {
        Button {
            blocksPresented = true
        } label: {
            Text(tokens.chromeLabel(MobileBlockListModel.chipWord))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Blocks")
    }

    /// The lens chip (parity C5 — her sketch: "choose between lenses on
    /// the top bar"): the bare voiced word at rest; the ACTIVE lens's
    /// name in words while one drives the display (the whole-surface
    /// viewing state, named honestly — accent ink says the display is a
    /// way of looking, not the note). Fourth chip on the second line —
    /// joins PC4b-4's recorded crowding look item.
    private var lensChip: some View {
        Button {
            lensesPresented = true
        } label: {
            // **PR14's marker** (her 13j gate ruling (5) — *"say loudly"*):
            // while the ACTIVE lens has a pick that fell back to the note's
            // own take, the chip says so on the page the lens is driving,
            // in the alarm token, rather than leaving the fact inside a
            // sheet she would have to think to open. The sheet's own loud
            // region names WHICH block and offers the way back.
            Text(tokens.chromeLabel(
                lenses.chipLabel + (lenses.activeLensHasFallback ? " \u{26A0}" : "")))
                .font(tokens.small)
                .foregroundStyle(
                    lenses.activeLensHasFallback
                        ? tokens.alarm
                        : (lenses.activeLensID != nil ? tokens.accent : tokens.faint))
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(lenses.activeLensHasFallback ? Self.lensFallbackChipLabel : "Lenses")
    }

    /// The chip's spoken label while the active lens has a fallback — a
    /// glyph is not a sentence, and VoiceOver reads words.
    static let lensFallbackChipLabel = "Lenses — a pick fell back"

    /// Copy the whole note (round 2 batch 2 — M3 ≡ R6; her ask: *"a button
    /// added at the top that allows me to copy everything i've written in a
    /// particular note"*). It sits in the masthead's note-tool corner
    /// beside find and seal, because what it copies is the NOTE — the
    /// bar's ⋯ is where block-level acts live, and this is not one.
    /// Markdown, exactly what export writes; the model's `copyNote` owns
    /// the flush-first contract and the receipt (this view sends an action
    /// and nothing else). Works on a sealed note — copying is reading.
    private var copyDoor: some View {
        Button {
            let model = model
            Task { await model.copyNote() }
        } label: {
            Image(systemName: "doc.on.doc")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy Note")
    }

    /// **The receipt's action** (M20). It offers the direction the last
    /// act left available: Undo after a structural act, Redo right after an
    /// undo (the ping-pong her R10 asked for). Rendered only when the stack
    /// really holds that end — a receipt can outlive its entry, and a
    /// button that would pop somebody else's act is worse than no button.
    @ViewBuilder
    private var receiptAction: some View {
        switch model.statusAction {
        case .undo:
            if let label = model.undoDoor.undoLabel {
                Button {
                    let door = model.undoDoor
                    Task { await door.beginUndo(from: .receipt) }
                } label: {
                    Text(tokens.chromeLabel("Undo"))
                }
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .buttonStyle(.plain)
                .accessibilityLabel(StructuralUndoCopy.undoDoorTitle(label))
            }
        case .redo:
            if let label = model.undoDoor.redoLabel {
                Button {
                    let door = model.undoDoor
                    Task { await door.redo() }
                } label: {
                    Text(tokens.chromeLabel("Redo"))
                }
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .buttonStyle(.plain)
                .accessibilityLabel(StructuralUndoCopy.redoDoorTitle(label))
            }
        case nil:
            EmptyView()
        }
    }

    /// The note's ⋯ (round 2 batch 4): the note-scale acts sheet — M20's
    /// persistent undo/redo door and PR1's Delete Note…. It sits in the
    /// note-tool corner beside copy · find · seal, because everything it
    /// carries is the NOTE's (the bar's ⋯ is where BLOCK acts live).
    private var noteActionsDoor: some View {
        Button {
            noteActionsPresented = true
        } label: {
            Image(systemName: "ellipsis")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MobileNoteActionsSheet.doorLabel)
    }

    /// Find in note (parity C4b item 3): the masthead's trailing corner
    /// is the phone's note-tool corner (the seal glyph's own placement
    /// justification — note-level, always visible however far she has
    /// scrolled), and the magnifier presents the SYSTEM find navigator
    /// (find only; replace is structurally declined — the text view
    /// carries the reasoning). Works on a sealed note too: finding is
    /// reading, and reading stays free under the seal.
    private var findDoor: some View {
        Button {
            model.presentFind()
        } label: {
            Image(systemName: "magnifyingglass")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Find in Note")
    }

    /// The note seal's door (parity round Stage A batch A1, item 4 — her
    /// ruling: "you should be able to unlock a note and lock it on
    /// mobile"). Placement: the masthead is the phone's note-identity
    /// surface and its only note-level acts home — block acts live in the
    /// bar's ⋯, but the seal is the NOTE's own state, already displayed
    /// here, so its door lives beside it. The glyph mirrors the state;
    /// lock and unlock are both one reversible tap (the seal is a guard,
    /// never a snapshot — I6).
    private var sealDoor: some View {
        Button {
            let model = model
            Task {
                if model.isSealed {
                    await model.unlockNote()
                } else {
                    await model.lockNote()
                }
            }
        } label: {
            Image(systemName: model.isSealed ? "lock.fill" : "lock.open")
                .font(tokens.small)
                .foregroundStyle(model.isSealed ? tokens.accent : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(model.isSealed ? Self.unlockDoorTitle : Self.lockDoorTitle)
    }
}
