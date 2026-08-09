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
    private let fallbackVoice: ThemeVoice
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String,
        router: MobileShellRouter? = nil, beginEditing: Bool = false,
        tab: MobileTab = .shelf,
        onOpenNote: ((String) -> Void)? = nil
    ) {
        _model = State(initialValue: MobileEditorViewModel(session: session, postID: postID))
        _membership = State(initialValue: MobileMembershipModel(session: session, postID: postID))
        _noteTags = State(initialValue: MobileNoteTagsModel(session: session, postID: postID))
        _references = State(initialValue: MobileReferencesModel(session: session, postID: postID))
        _blockList = State(initialValue: MobileBlockListModel(session: session, postID: postID))
        self.router = router
        self.beginEditing = beginEditing
        self.tab = tab
        self.onOpenNote = onOpenNote
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
                router?.editors.deregister(model)
                Task { await model.teardown() }
            }
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                findDoor
                sealDoor
            }
            HStack(spacing: 12) {
                membershipChip
                dateChip
            }
            // The identity area's second line (parity C3): the note's
            // tags and its sources — two more chips would crowd the
            // books · date line, so they breathe on their own (recorded
            // PROVISIONAL; her look round may re-arrange).
            HStack(spacing: 12) {
                tagsChip
                moreInfoChip
                blocksChip
            }
            if let canary = model.canaryMessage {
                Text(canary).font(tokens.small).foregroundStyle(.red)
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
            if let status = model.statusMessage {
                Text(status).font(tokens.small).foregroundStyle(tokens.muted)
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
        .sheet(isPresented: $blocksPresented) {
            MobileBlockListSheet(model: blockList, tokens: tokens) { blockID in
                blocksPresented = false
                model.jumpToBlock(blockID)
            }
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
