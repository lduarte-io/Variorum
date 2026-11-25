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

/// **The Write page's session memory: where each note was left** (VM-10, her
/// ruled shape (2) — the Mac's `EditorRouter.scrollPlaces` twin, the phone's
/// own version). Session-only: never persisted, never synced, gone at relaunch
/// (the Mac's letter — *"not across launches"*). Owned by the shell router,
/// the one session-lived composition object both tab stacks share, so a note
/// re-opened on either stack lands where it was last left. Keyed by note.
@MainActor
final class MobileWritePlaces {
    private var places: [String: MobileWritePlace] = [:]

    func place(for postID: String) -> MobileWritePlace? {
        places[postID]
    }

    func remember(_ place: MobileWritePlace, for postID: String) {
        places[postID] = place
    }
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
    /// **R-260-13 (the VM-260 run, batch 4b)** — the note's top as she picked
    /// it: the title gives way as she scrolls (the tracker reads the text
    /// view's own scroll); # opens the tags in place; the stack door's menu,
    /// and the row it chose (asked for once the menu has gone). The entry
    /// date's alert moved with its door into the Note sheet.
    @State private var titleTracker = MobileNoteTitleTracker()
    @State private var tagsOpen = false
    @State private var stackOpen = false
    @State private var stackChoice: MobileNoteStackChoice?
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
    /// The shell's theme authority (VM-51); nil in harness/preview use, where
    /// the editor face's own look governs.
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
    /// **VM-275 — the line that was showing when this note arrived**, so its
    /// leaving clears only what was raised while it showed (`MobileLine
    /// .leaveNote`). Written on appear; read by the leaving road.
    @State private var lineWhenShown: UUID?
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
        // VM-65: the timing layer's "a note screen requested" (a rebuild of the
        // same screen restarts the span — `AppTiming.noteRequested`).
        AppTiming.noteRequested()
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
        // (VM-51: this initializer no longer writes the editor's voice — the
        // library's look reaches `MobileEditorStyle` where it LANDS, through
        // the router's theme seam, its one app writer; QUESTIONS #195 MINOR 3.)
    }

    /// The SwiftUI chrome's tokens — this PHONE's voice and palette (VM-247;
    /// the library's until then, VM-51) through the router's one settings →
    /// tokens road; dark rides the
    /// system scheme (LK-2; R51's black rooms are the token layer's own).
    /// Harness use (no router) wears the editor face's own look, so the
    /// masthead and the page below it always agree.
    private var tokens: VoiceTokens {
        router?.tokens(dark: scheme == .dark)
            ?? .resolve(settings: MobileEditorStyle.settings, dark: scheme == .dark)
    }

    /// **The note's ground** (VM-247): the paper, or — when this phone chose it
    /// (her "the cream background color option … should stay as an option for
    /// the phone") — the cream, the voice's own room; one rule for the screen,
    /// its masthead and its edge strips (`MobileNoteGround.color`), the editor's
    /// own ground being the face's `paper`, the same choice in UIKit. Harness use
    /// (no router) wears the editor face's own ground, so the page and the editor
    /// agree.
    private var noteGround: Color {
        (router?.look.choice.ground ?? MobileEditorStyle.ground)
            .color(tokens: tokens, dark: scheme == .dark)
    }

    var body: some View {
        MobileWriteView(model: model)
            .ignoresSafeArea(.keyboard) // the container's keyboardLayoutGuide owns avoidance
            // VM-51 (R-47-1; the VM-47 run's piece 3.10, P-47-16): the page's
            // ground is the editor's own — the paper (`MobileEditorStyle.Face
            // .paper`, the Mac's editor and note masthead on `tokens.surface`),
            // or the cream this phone chose (VM-247).
            .background(noteGround.ignoresSafeArea())
            // VM-47 (the walk's W-A1, redone): the strips beyond the shell's
            // band — the note's ground at both edges, so with the keyboard up the
            // keyboard and its bar sit over her page, never the bare window.
            .mobileEdgeGrounds(top: noteGround, bottom: noteGround)
            // VM-272 (the batch-2 reconcile): no hidden gap under the masthead.
            // `safeAreaInset`'s default spacing put the system's 8 pt between
            // it and her text — air under air, uncounted by the 158 / 136
            // arithmetic and measured by the window (167 / 145). Its 4 below
            // is the note's top's one gap.
            .safeAreaInset(edge: .top, spacing: 0) { masthead }
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
                AppTiming.noteArrived() // VM-65: this open's reads are counted from here
                // R-260-13: the title reads the text view's own scroll (a read;
                // nothing of the editor changes).
                titleTracker.watch(model.textView)
                // VM-70: the arrival counts itself and, for a screen shown again
                // whose leaving gave its coordinator back, takes it again —
                // before the liveness grant flushes it.
                await model.takeAutosaveHold()
                if let router {
                    await router.editors.register(model, tab: tab)
                }
                // VM-10: the session's page memory, before the arrival reads it.
                model.placeMemory = router?.writePlaces
                await model.arrive(focus: beginEditing)
                await model.start()
            }
            // VM-275: what the line held as this note arrived — not the note's.
            .onAppear {
                lineWhenShown = session.status.current?.id
                titleTracker.watch(model.textView)
            }
            .onDisappear {
                let model = model
                let session = session
                // VM-61: a line still offering this note's structural Undo is
                // taken back — that door goes with the note.
                MobileLine.withdrawNoteLine(of: model.undoDoor, session: session)
                // VM-275 (her rule): a refusal raised in this note clears as
                // she leaves it — the same leaving road, no second observer.
                MobileLine.leaveNote(session: session, lineWhenShown: lineWhenShown)
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
                let leaving = AppTiming.noteLeaving() // VM-65: timed, its savepoint tries counted
                // VM-70: which arrival this leaving belongs to — a screen shown
                // again before the work below ends keeps its coordinator.
                let shown = model.arrivalCount
                Task {
                    await model.teardown()
                    await session.savepointOnLeaving(model.postID)
                    // VM-70: the leaving's LAST act — the flush and the
                    // savepoint have landed; the coordinator goes back.
                    model.releaseAutosaveHold(ifNotShownSince: shown)
                    AppTiming.noteLeft(leaving)
                }
            }
    }

    private var masthead: some View {
        // The documented `@Bindable` local (round 2 batch 4): `$door.…` is a
        // REAL observation dependency, which is exactly what the Mac's
        // computed-`Binding` purge dialogs lack (§15's trap (a)).
        @Bindable var door = model.undoDoor
        // **R-260-13 — THE NOTE'S TOP AS SHE PICKED IT** (the VM-260 run, batch
        // 4b; the drawing `notes/plans/vm-260/note-top-options.html` frame P).
        // The title on its own row, centred and wrapping; under it ONE row of
        // six icon doors with no separator; while the tags are open, their strip
        // under the row. Only the row (and the open strip, and a sealed note's
        // state line) stays as she scrolls: the title gives way with her text
        // (`MobileNoteTitleTracker` reads the text view's own scroll) and is
        // back at the top. The seal and the date moved into the Note sheet's
        // head (`MobileNoteActionsSheet`); the membership line and the five
        // chips left the top — the book door, #, and the stack door hold them.
        return VStack(spacing: 0) {
            if !titleTracker.gone {
                titleRow
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            doorRow
            if tagsOpen {
                MobileNoteTagStrip(model: noteTags, tokens: tokens) { tagsPresented = true }
                    .transition(.opacity)
            }
            if let canary = model.canaryMessage {
                Text(canary).phoneType(.meta, tokens).foregroundStyle(.red)  // CANARY: deliberately not the voice's alarm
            }
            if model.isSealed {
                // The state line pairs with its door (the 13b fire-and-DO
                // doctrine: a message naming an act offers the act) — every
                // sealed refusal on this screen says "unlock it", and the door
                // stands right here in the masthead. Both render voice-cased
                // (P26/P43 — PA1-1 resolved). R-260-13: the seal's OWN door
                // moved into the Note sheet's head; this line and its unlock
                // stay where they were — under the note's facts, in the part of
                // the top that stays — so a sealed note always says so.
                HStack(spacing: 10) {
                    Text(tokens.chromeLabel(Self.sealedStateLine))
                        .phoneType(.meta, tokens).foregroundStyle(tokens.phone.muted)
                    Button {
                        let model = model
                        Task { await model.unlockNote() }
                    } label: {
                        Text(tokens.chromeLabel(Self.unlockDoorTitle))
                    }
                    .buttonStyle(PhoneInlineActStyle(tokens: tokens))
                    .accessibilityLabel("Unlock Note")
                }
            }
            // **THE RECEIPT LEFT THE MASTHEAD** (VM-61 — her VM-44 ruling and
            // the note-write mockup's D4/D4b: "It never enters the masthead and
            // never moves the prose"). What this row drew — a refusal, a
            // receipt, a removal's Undo — speaks on the shell's ONE line
            // (`MobileMessageLine`); the structural Undo rides that line over
            // the same door (`MobileUndoDoor.beginUndo(from: .receipt)`), and
            // A12's warning still presents from this masthead's alert host.
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PhoneMetrics.gutter)
        .padding(.top, Self.mastheadTop)
        .padding(.bottom, Self.mastheadBottom)
        .background(noteGround)  // VM-51: her title shares the page's ground (P-47-17; VM-247's cream too)
        // The row's edge once her text runs under it (the drawing's `.edge`):
        // the palette's line, the bar's hairline.
        .overlay(alignment: .bottom) {
            if titleTracker.gone {
                Rectangle()
                    .fill(tokens.line)
                    .frame(height: MobileTabBarMetrics.hairline)
                    .accessibilityHidden(true)
            }
        }
        // The title's slide never draws over the system bar above the top.
        .clipped()
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
        // per sheet close. (R-260-13: the marker is the stack door's now —
        // its alarm tone and its spoken value — and its menu's lens row.)
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
    }

    /// **The title on its own row** (R-260-13 — her "the title to get more
    /// space on top … then the title could be more centered"): the whole width
    /// between the gutters and a little more room (`titleInset`), centred, and
    /// WRAPPING — never cut. It is still the rename door (parity C2 — "full app
    /// functionality"): the title IS the door; an alert confirms, so a stray tap
    /// costs nothing; the field edits the STORED title (the display title may
    /// be derived — DisplayTitle's brain). VM-148's rename-in-place is not this.
    private var titleRow: some View {
        Button {
            renameField = model.header?.title ?? ""
            renamePresented = true
        } label: {
            Text(model.displayTitle ?? "")
                .phoneType(.noteTitle, tokens)
                .foregroundStyle(tokens.ink)
                .multilineTextAlignment(.center)
                .phoneHitArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Rename Note")
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Self.titleInset)
        .padding(.top, Self.titleTop)
        // R1-1 (ladder round 1): the row's whole height, its own 8 above
        // included — exactly what the masthead gives the text view when the
        // title leaves — so the tracker decides the leave on the page's reach
        // AFTER the flip. A write to unobserved storage: no body is asked again.
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { titleTracker.titleHeight = $0 }
    }

    /// **The one row** (R-260-13): six icon doors, each the phone's 44 × 44
    /// icon button, touching (centres 44 apart — "I don't think there should be
    /// a verticle line between the options"), centred, in her order: copy ·
    /// find · book · # · the stack door · ⋯ (C-13-1: ⋯ last, the iOS
    /// convention).
    private var doorRow: some View {
        HStack(spacing: 0) {
            copyDoor
            findDoor
            bookDoor
            tagsDoor
            stackDoor
            noteActionsDoor
        }
        .frame(maxWidth: .infinity)
    }

    /// **The entry date's one fact** (VM-84): the day it shows, read in ONE
    /// place — the Note sheet's date door's words, its ink and the alert's seed
    /// (R-260-13 moved the door off the top) — so what the door OBSERVES is
    /// exactly what a pin can hold. It reads the model's OBSERVED `entryDate`,
    /// never `header` (deliberately unobserved), so a date change re-renders the
    /// door whether or not the title moved.
    static func dateChipDay(_ model: MobileEditorViewModel) -> String? {
        model.entryDate
    }

    /// **The book door** (R-260-13 — her "in no book should be replaced with a
    /// book icon that you can tap on to add it to a book, maybe greyed out when
    /// there's no book"): the membership line's act (parity C2 — which books
    /// hold this note; add it to one, take it out, diverge), behind the Mac's
    /// book glyph, grey (the corrected faint) while the note is in no book, in
    /// ink in one, in the accent in several. Its name is the line's; its value
    /// is what the line used to say.
    private var bookDoor: some View {
        Button {
            membershipPresented = true
        } label: {
            Image(systemName: MobileNoteTopDoors.bookSymbol)
                .foregroundStyle(MobileNoteTopDoors.bookInk(count: membership.books.count, tokens: tokens))
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
        .accessibilityLabel("Books holding this note")
        .accessibilityValue(MobileMembershipModel.labelText(bookNames: membership.books.map(\.name)))
        // VM-69: the door's own read — the books holding this note, never
        // every book (the sheet reads those on appear).
        .task(id: model.postID) { await membership.refreshChip() }
    }

    /// **#** (R-260-13 — "easy to click on tags to see them expand and then
    /// click on the tag icon so tags close again"): opens the note's tags IN
    /// PLACE, under the row, and the same # closes them; the accent while open
    /// (the Mac masthead's ＃'s own open state). Adding a tag stays one press
    /// away — the strip's add door opens the tags sheet. Its name is the tags
    /// chip's; its value the chip's words (the leaves, or that there are none).
    private var tagsDoor: some View {
        Button {
            if UIAccessibility.isReduceMotionEnabled {
                tagsOpen.toggle()
            } else {
                withAnimation(.easeOut(duration: MobileNoteTopDoors.flipSeconds)) { tagsOpen.toggle() }
            }
        } label: {
            Image(systemName: MobileNoteTopDoors.tagsSymbol)
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens, tone: tagsOpen ? .accent : .ink))
        .accessibilityLabel("Tags")
        .accessibilityValue(noteTags.chipLine ?? "no tags")
        .accessibilityAddTraits(tagsOpen ? .isSelected : [])
        // VM-69: the door's own read — this note's tags, never the vocabulary
        // (the sheet reads that on appear).
        .task(id: model.postID) { await noteTags.refreshChip() }
    }

    /// **The stack door** (R-260-13 — her "blcoks and lens and more info could
    /// probably go together"; C-13-3): one door, a three-row menu — blocks ·
    /// lens · more info — each opening what its chip opened. It keeps the lens
    /// chip's states: the accent while a lens drives the page, the ALARM while
    /// the active lens has a pick that fell back (PR14's marker, her 13j gate
    /// ruling (5) — "say loudly"), said in its value too.
    private var stackDoor: some View {
        Button {
            stackOpen = true
        } label: {
            Image(systemName: MobileNoteTopDoors.stackSymbol)
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens, tone: stackTone))
        .accessibilityLabel(MobileNoteTopDoors.stackName)
        .accessibilityValue(stackValue)
        // The more-info row's count — the chip's own read, kept at the open.
        .task(id: model.postID) { await references.refresh() }
        .popover(isPresented: $stackOpen, arrowEdge: .top) {
            MobileNoteStackMenu(
                tokens: tokens, lensWord: lenses.chipLabel,
                lensFellBack: lenses.activeLensHasFallback,
                referenceCount: references.references.count
            ) { choice in
                stackChoice = choice
                stackOpen = false
            }
            // The chosen sheet is asked for only once the menu has gone
            // (`MobileNoteActionsSheet`'s Settings row precedent), so two
            // presentations never overlap.
            .onDisappear { openStackChoice() }
        }
    }

    private var stackTone: PhoneActTone {
        if lenses.activeLensHasFallback { return .alarm }
        return lenses.activeLensID != nil ? .accent : .ink
    }

    private var stackValue: String {
        guard lenses.activeLensID != nil else { return "" }
        return lenses.activeLensHasFallback
            ? "\(lenses.chipLabel) — \(MobileNoteTopDoors.fellBackValue)"
            : lenses.chipLabel
    }

    private func openStackChoice() {
        guard let choice = stackChoice else { return }
        stackChoice = nil
        Task { @MainActor in
            switch choice {
            case .blocks: blocksPresented = true
            case .lens: lensesPresented = true
            case .moreInfo: referencesPresented = true
            }
        }
    }

    /// The lens row's spoken label while the active lens has a fallback — a
    /// glyph is not a sentence, and VoiceOver reads words.
    static let lensFallbackChipLabel = "Lenses — a pick fell back"

    /// **The note's top's room** (VM-272 → R-260-13): nothing above the title's
    /// row but its own 8 (`titleTop`), the title 8 further in than the gutter
    /// each side (`titleInset` — the drawing's 28), and 4 below the last row
    /// (`mastheadBottom`, VM-272's). At a one-line title the top is 8 + 44 + 44
    /// + 4 = 100 pt at rest and 44 + 4 scrolled (it was 136, always).
    /// PROVISIONAL with the set (P-260-4b-1).
    static let mastheadTop: CGFloat = 0
    static let mastheadBottom: CGFloat = PhoneMetrics.Space.s4
    static let titleTop: CGFloat = PhoneMetrics.Space.s8
    static let titleInset: CGFloat = PhoneMetrics.Space.s8

    /// Copy the whole note (round 2 batch 2 — M3 ≡ R6; her ask: *"a button
    /// added at the top that allows me to copy everything i've written in a
    /// particular note"*). It sits in the masthead's one row (R-260-13), first,
    /// because what it copies is the NOTE — the bar's ⋯ is where block-level
    /// acts live, and this is not one.
    /// Markdown, exactly what export writes; the model's `copyNote` owns
    /// the flush-first contract and the receipt (this view sends an action
    /// and nothing else). Works on a sealed note — copying is reading.
    private var copyDoor: some View {
        Button {
            let model = model
            Task { await model.copyNote() }
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
        .accessibilityLabel("Copy Note")
    }

    /// The note's ⋯ (round 2 batch 4): the note-scale acts sheet — M20's
    /// persistent undo/redo door and PR1's Delete Note…, and since R-260-13
    /// the seal and the date at its head. It ends the row, because everything
    /// it carries is the NOTE's (the bar's ⋯ is where BLOCK acts live).
    private var noteActionsDoor: some View {
        Button {
            noteActionsPresented = true
        } label: {
            Image(systemName: "ellipsis")
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
        .accessibilityLabel(MobileNoteActionsSheet.doorLabel)
    }

    /// Find in note (parity C4b item 3): the masthead's row is the phone's
    /// note-tool corner (note-level, and since R-260-13 it stays however far
    /// she has scrolled), and the magnifier presents the SYSTEM find navigator
    /// (find only; replace is structurally declined — the text view carries
    /// the reasoning). Works on a sealed note too: finding is reading, and
    /// reading stays free under the seal.
    private var findDoor: some View {
        Button {
            model.presentFind()
        } label: {
            Image(systemName: "magnifyingglass")
        }
        .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
        .accessibilityLabel("Find in Note")
    }
}
