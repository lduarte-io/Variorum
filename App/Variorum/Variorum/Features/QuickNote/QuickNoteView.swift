//
//  QuickNoteView.swift
//  Variorum (Mac)
//
//  Phase 13f, W5 — THE QUICK NOTE (her sitting ruling, round 3: *a FLOATING
//  MINI-WINDOW; global shortcut / menu-bar door; typing mints an ordinary
//  bookless note (the Pool lists it); the sticky face shows NO takes
//  machinery; the note persists when the window closes*).
//
//  ── IT IS A CAPTURE SURFACE, NOT AN EDITOR (the gate's ruling (a)) ───────
//  There is no TK2 surface here, no block identity, no live ring — a plain
//  SwiftUI text field, and the text becomes a note through the standing
//  quick-entry grammar when she is done. Two things fall out of that, and
//  they are the reason the shape was chosen over a mini editor:
//
//  1. **P-3 holds trivially rather than carefully.** The sticky mounts no
//     text surface, so there is nothing for it to be live *with*: no
//     authority, no routed-command handler, no `EditorRouter.active`. The
//     one-live-ring invariant is not extended here; it is simply not
//     engaged.
//  2. **"No takes machinery" holds by construction**, not by stripping a
//     face down and keeping it stripped.
//
//  The cost, stated where it lives: a summon she abandons keeps nothing,
//  and re-summoning gives a fresh pad rather than the last note. That is
//  what a sticky IS — the minted note opens in the full editor the moment
//  she wants more of it.
//
//  ── WHEN IT MINTS (her round-14.2 ruling, AMENDED BY R-13u-4) ───────────
//  **⏎ FILES IT · ⇧⏎ ADDS A PARAGRAPH** — 13u3 UNIT C, her 13u1 sitting
//  ruling R-13u-4, which settled the capture model for BOTH platforms: *"the
//  capture surface holds MANY paragraphs; ⏎ FILES the note, ⇧⏎ adds a
//  paragraph; the hand-off segments through `importPost`'s bulk rule."*
//  **This supersedes round-14.2's "⏎ IS A NEWLINE" for this pad** — the pad
//  still holds many paragraphs (that half is untouched and is exactly what
//  her ruling keeps), but the key that makes one is now ⇧⏎, and the shelf's
//  quick-entry bar answers the same two keys through the same box
//  (`CaptureTextView`). The note still mints on **CLOSE**, on **⌘⏎** and at
//  **QUIT** (the architect's ruling (c): the capture-scale analog of the
//  open tail's teardown backstop — loss is bounded by one summon, and this
//  is what bounds it). ONE SUMMON = ONE NOTE, and an empty sticky mints
//  nothing.
//
//  ── AND A REFUSAL NEVER TAKES HER WORDS (13u3 UNIT C) ───────────────────
//  The pad used to clear BEFORE the mint, so anything `importPost` could
//  throw took the capture with it — 13l's L-b defect, which was fixed in
//  the quick-entry bar and left standing here on a justification that had
//  stopped being true. The text now leaves the pad only when a note exists
//  to hold it, the refusal is spoken IN the pad (the window she is looking
//  at), and the pad stays open so the next ⏎ can try again.
//
//  ── AND IT STAYS QUIET (her round-14.3) ─────────────────────────────────
//  The note lands in the smart Quicknotes book (13g batch 7, R6-4 — tagged
//  "quicknote"; one untag returns it to the Pool); one status line names
//  where it went; the main window never navigates. A sticky that yanks her
//  out of what she was doing is the opposite of a quick note.
//

import SwiftUI
import VariorumCore

/// THE PAD ITSELF — the text and its three mint triggers, OUT of the view.
///
/// This is not ceremony: the triggers are `close`, `⌘⏎` and `quit`, and two
/// of the three are SwiftUI/AppKit lifecycle hooks that no test can drive.
/// Left inside the view they would be exactly the promise this file's own
/// header warns about (the `MembershipChip.ascend` lesson, W20) — and the
/// first revert proved it: deleting the close path left every pin green.
/// Here each trigger is a named call the pins drive directly, and the view
/// holds nothing but the hooks that call them.
@MainActor
@Observable
final class QuickNotePad {
    @ObservationIgnored let session: AppSession
    var text = ""

    /// **13u3 UNIT B — her item 4's capture half**, the same offer the
    /// quick-entry bar makes: has she taken the suggested name? Off until she
    /// clicks it; a pad she ignores files untitled exactly as it always did.
    var titleFromFirstWords = false

    /// The words the chip offers — one brain with the Library's cards.
    var suggestedTitle: String? { NoteCardFace.suggestedTitle(forTypedText: text) }

    /// **13u3 UNIT C — the refusal, where she can see it.** The quick-entry
    /// bar's shape (13l L-b): her text lives NOWHERE but this pad until a
    /// note exists, so the sentence that says it is still here has to be on
    /// the pad itself and not in a status line one window away.
    private(set) var lastError: String?

    /// **17b row 65 — why this box is not empty** (binding 3). Set when a
    /// summon takes a capture back out of the park; cleared the moment she
    /// files again, because by then it is answering a question nobody is
    /// asking. Its own line rather than `lastError`'s: nothing is being
    /// refused here, so it must not wear the alarm register.
    private(set) var restoredNote: String?

    /// The endorsed defaulted-seam pattern, adopted from `QuickEntryModel`
    /// for its stated reason (mobile round 2 §20(b)): production never sets
    /// this, and a REFUSAL is otherwise not reachable from a test without
    /// breaking the store underneath it. It carries the title beside the
    /// text so a pin can read what the mint was actually asked for.
    @ObservationIgnored
    var mint: ((String, String?) async -> QuickNoteMint.Outcome)?

    init(session: AppSession) { self.session = session }

    /// **17b row 65 — THE SUMMON TAKES IT BACK** (bindings 2 and 3). The
    /// park lets go in the same breath, so this pad is the only home again
    /// and abandoning it from here is her ordinary abandon; a re-refusal
    /// re-parks. Idempotent: a second call finds an empty park.
    func restoreParkedCapture() {
        guard let held = session.quickNotePark.restore() else { return }
        text = held.text
        titleFromFirstWords = held.titleFromFirstWords
        restoredNote = QuickNoteCopy.restoredCapture
    }

    /// Is there anything to file? The button's grey reads this, so it can
    /// never fire into `emptyImport`.
    var mints: Bool { QuickNoteMint.mints(text) }

    /// ⏎ and ⌘⏎ — file it explicitly. The pad clears on success, so the
    /// `close` that follows finds nothing and ONE SUMMON STILL MINTS ONE
    /// NOTE (her round-14.2).
    @discardableResult
    func fileExplicitly() async -> QuickNoteMint.Outcome { await take() }

    /// CLOSING FILES IT (her round-14.2). Idempotent by the same clearing.
    @discardableResult
    func close() async -> QuickNoteMint.Outcome { await take() }

    /// QUIT (the architect's ruling (c)): a non-empty pad at app quit files
    /// itself — the capture-scale analog of the open tail's teardown
    /// backstop, and what bounds the loss to one summon.
    @discardableResult
    func finalizeAtQuit() async -> QuickNoteMint.Outcome { await take() }

    /// The one body all three share: take the text, file it, and clear the
    /// pad ONLY when a note exists to hold it.
    ///
    /// **Clearing on SUCCESS is what makes the three triggers compose** —
    /// close follows ⏎/⌘⏎, and quit can follow either, and none of them can
    /// mint a second note from the same summon. It used to clear FIRST, for
    /// the same composition, and that cost her the capture on any refusal
    /// (13u3 UNIT C's traced defect; 13l L-b one file over). A refusal now
    /// leaves the words in the pad, so the next trigger tries again — and
    /// since nothing was minted, one summon is still one note either way.
    ///
    /// **Keystrokes that land DURING the mint are not in that note** (the
    /// bar's own rule, adopted here so the two capture doors behave the
    /// same): the mint read `submitted`, so only `submitted` is cleared.
    ///
    /// **13j J11:** filing IS the pad's leaving — the note it mints is not
    /// open in any pane, so no other road would ever reach it, and a captured
    /// thought with no savepoint is exactly the thin history she reported.
    /// One line, on the one shared body, so all three triggers inherit it.
    private func take() async -> QuickNoteMint.Outcome {
        let submitted = text
        // **13u4 UNIT C1 — THE CAPTURE MICROSYNTAX PARSES HERE** (her ruling
        // R-13u4-1), at the HAND-OFF and nowhere else, through the same
        // shared rule the shelf's box uses. A capture of NOTHING BUT TOKENS
        // has nothing to file and takes the pad's standing empty branch
        // unchanged (PROVISIONAL, QUESTIONS #127(f)).
        let capture = CaptureMicrosyntax.parse(submitted)
        guard QuickNoteMint.mints(capture.text) else {
            text = ""
            titleFromFirstWords = false
            lastError = nil
            restoredNote = nil
            // 17b row 65 (binding 2): nothing to file — the park holds
            // nothing either, so an emptied pad never leaves a ghost.
            session.quickNotePark.clear()
            return .nothingToFile
        }
        // The name is read from what is being FILED, not from what the pad
        // holds now — the same discipline `submitted` already has. A
        // `{t:"…"}` token outranks the offered first words, and the offer
        // itself reads the CLEANED text so a token can never land inside the
        // stored name (#127(e)).
        let title = capture.title
            ?? (titleFromFirstWords
                ? NoteCardFace.suggestedTitle(forTypedText: capture.text)
                : nil)
        lastError = nil
        restoredNote = nil
        let outcome = await mintNow(capture.text, title: title)
        switch outcome {
        case .filed(let postID):
            // The note exists; the tokens act on it now, and a tag that does
            // not land speaks a refusal without undoing anything — filing
            // never blocks on a token.
            for refusal in await CaptureMicrosyntax.applyTags(
                capture, toPost: postID, session: session,
                wording: TagsViewModel.message
            ) {
                session.status.refuse(refusal)
            }
            if text == submitted {
                text = ""
                titleFromFirstWords = false
            }
            // 17b row 65 (binding 2): filed — the park holds nothing.
            session.quickNotePark.clear()
            await session.savepointOnLeaving(postID)
        case .refused(let message):
            lastError = message
            // **17b row 65 — THE PARK** (binding 1: refused captures ONLY).
            // On the ⏎/⌘⏎ road this is belt-and-braces: the pad stays open
            // and IS the home. On `close()` and `finalizeAtQuit()` it is the
            // whole fix — the words are about to become unreachable, because
            // this object's last strong reference is the task that called us.
            // Parked from `submitted`, never from `text`: keystrokes that
            // landed during the mint are not part of what was refused (the
            // discipline `submitted` already carries).
            session.quickNotePark.park(
                text: submitted, titleFromFirstWords: titleFromFirstWords,
                message: message)
        case .nothingToFile:
            break
        }
        return outcome
    }

    private func mintNow(_ submitted: String, title: String?) async -> QuickNoteMint.Outcome {
        if let mint { return await mint(submitted, title) }
        return await QuickNoteMint.file(submitted, title: title, session: session)
    }
}

struct QuickNoteView: View {
    let session: AppSession
    let windows: WindowRegistry

    /// Its own router — registered so the mount gate and the menu's gates
    /// answer for this window while it is key (see `onAppear`).
    @State private var router = ShellRouter()
    @State private var windowID = UUID()
    @State private var theme: ThemeStore
    @State private var pad: QuickNotePad
    /// The capture box's counted focus ask: 1 when the pad opens (the caret
    /// lands in the words), bumped when the title chip hands it back (13u3
    /// ladder round 1, R1-6).
    @State private var focusRequest = 1
    /// The quit-finalize registration (the architect's ruling (c)).
    @State private var quitToken: UUID?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    /// The pad draws the box's surface itself, so the inset around the box is
    /// the HOST's (WALK FIND 2).
    static let boxPadding = CGSize(width: 6, height: 4)
    /// **Where the placeholder sits** (VX-179 U3, the F-U3-1 ruling's Q-2):
    /// the pad's padding plus the box's OWN first-line origin — the one
    /// number `CaptureTextView` owns. (6, 6), exactly where it has always
    /// drawn: the pad is the parity proof that the box's static is the number
    /// the hand-derived 6 already was.
    static var placeholderOrigin: CGPoint {
        CGPoint(
            x: boxPadding.width + CaptureTextView.firstLineOrigin.x,
            y: boxPadding.height + CaptureTextView.firstLineOrigin.y)
    }

    init(session: AppSession, windows: WindowRegistry) {
        self.session = session
        self.windows = windows
        _theme = State(initialValue: ThemeStore(session: session))
        _pad = State(initialValue: QuickNotePad(session: session))
    }

    var body: some View {
        let tokens = theme.tokens(for: scheme)
        VStack(alignment: .leading, spacing: 8) {
            Text(tokens.chromeLabel(QuickNoteCopy.header))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
            // 13u3 UNIT C — THE ONE CAPTURE BOX (R-13u-4): ⏎ files it, ⇧⏎
            // makes a paragraph, and the shelf's quick-entry bar answers the
            // same two keys through this same component.
            CaptureTextView(
                text: $pad.text,
                style: CaptureTextStyle(tokens: tokens),
                maxHeight: nil,  // the pad IS a window: it takes the space
                focusRequest: focusRequest,  // 1 at open; the chip bumps it
                onFile: { fileAndClose() })
                // WALK FIND 2: the pad draws the box's surface itself, so the
                // inset is the HOST's — and it has to be the same one the
                // placeholder wears, or the words move sideways when she
                // starts typing (the same class the container padding caused
                // one file over).
                .padding(.horizontal, Self.boxPadding.width)
                .padding(.vertical, Self.boxPadding.height)
                .background(tokens.surface)
                .overlay(alignment: .topLeading) {
                    if pad.text.isEmpty {
                        // VX-179 U3 (F-U3-1 Q-2): derived from the box's own
                        // first-line origin + the pad's padding — the same
                        // (6, 6) it always drew at, now said once.
                        Text(tokens.chromeLabel(QuickNoteCopy.placeholder))
                            .font(tokens.body)
                            .foregroundStyle(tokens.faint)
                            .padding(.leading, Self.placeholderOrigin.x)
                            .padding(.trailing, Self.boxPadding.width)
                            .padding(.top, Self.placeholderOrigin.y)
                            .allowsHitTesting(false)
                    }
                }
            // 13u3 UNIT B — the OFFER (her item 4): the first words, one
            // click to take them as this note's title, ignorable forever.
            if let suggestion = pad.suggestedTitle {
                TitleSuggestionChip(
                    tokens: tokens, suggestion: suggestion, adopted: pad.titleFromFirstWords
                ) {
                    pad.titleFromFirstWords.toggle()
                    // 13u3 ladder round 1, R1-6 (SPECULATIVE hardening — the
                    // acceptance walk's unreproduced first-⏎ miss): deciding
                    // about the name hands the caret straight back to the
                    // words. A no-op when the box never lost them.
                    focusRequest += 1
                }
            }
            // 17b row 65 (binding 3): why this box is not empty. Its own
            // register — nothing is being refused here — and `lineLimit`
            // beside `fixedSize` for the b6dae25 class (P-8), like its
            // neighbour below.
            if let restoredNote = pad.restoredNote {
                Text(tokens.chromeLabel(restoredNote))
                    .font(tokens.small)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(tokens.accent)
            }
            if let lastError = pad.lastError {
                // `lineLimit` is LOAD-BEARING beside `fixedSize` — an
                // unlimited fixedSize text in non-scrolling chrome inflates
                // the WINDOW minimum during the near-zero-width min-size
                // probe (the b6dae25 wedged-window class, P-8).
                Text(lastError)
                    .font(tokens.small)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .alarmVoice()
            }
            HStack {
                // `lineLimit` beside a hint in non-scrolling chrome — P-8's
                // b6dae25 class. TWO lines since 13u3 UNIT C's walk: at the
                // pad's own 340 pt the one-line hint truncated mid-rule
                // ("⏎ files it · ⇧⏎ new paragraph · c…"), so the third
                // clause — closing files it too — could not be read at the
                // width the pad actually opens at.
                Text(tokens.chromeLabel(QuickNoteCopy.hint))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Button(QuickNoteCopy.fileVerb) { fileAndClose() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(!pad.mints)
            }
        }
        .padding(14)
        .frame(minWidth: 300, minHeight: 220)
        .background(tokens.room)
        .environment(theme)
        .background {
            WindowKeyReporter(
                onWindow: { windows.attach($0, to: windowID) },
                onKey: { windows.noteKey(windowID) })
        }
        .task { await theme.start() }
        .onAppear {
            // Registered like every other window (the gate's ruling): while
            // the sticky is key the app has ZERO live surfaces, so ⌘S and
            // the whole editing family go honestly grey through the gates
            // that already exist — and no act can reach a window she is not
            // looking at (the 5b menu-gates defect, refused re-entry).
            windows.register(windowID, router: router, kind: .quickNote)
            let status = session.status
            router.refuse = { status.refuse($0) }
            // **17b row 65 — THE SUMMON TAKES BACK A REFUSED CAPTURE**
            // (bindings 2/3). Before the quit registration, so the pad that
            // registers is the one holding her words.
            pad.restoreParkedCapture()
            session.quickNotePark.isPadShowing = true
            // THE QUIT PATH: a non-empty pad at app quit files itself.
            let pad = self.pad
            quitToken = session.quitFinalize.register { @MainActor in
                await pad.finalizeAtQuit()
            }
        }
        .onDisappear {
            windows.unregister(windowID)
            if let quitToken { session.quitFinalize.unregister(quitToken) }
            session.quickNotePark.isPadShowing = false
            // CLOSING FILES IT (her ruling). The window is already going, so
            // this rides the pad rather than this view's lifetime.
            let pad = self.pad
            let status = session.status
            Task { @MainActor in
                // There is no pad left to draw a refusal on, so this is the
                // one path that hands it to the status seam (13u3 UNIT C).
                //
                // **17b row 65:** and the sentence it hands over is the
                // PARKED one — `refusal(for:)`'s *"Your text is still here"*
                // was false the moment this window went, and the words are
                // now somewhere it can honestly name.
                if case .refused = await pad.close() {
                    status.refuse(QuickNoteCopy.parkedOnClose)
                }
            }
        }
    }

    private func fileAndClose() {
        // ⏎ and ⌘⏎ file explicitly, and the window goes with the thought —
        // one act, three doors (the key, the chord, the button).
        //
        // **A REFUSAL KEEPS THE WINDOW OPEN** (13u3 UNIT C): dismissing on a
        // refusal would close a pad that is still holding her words, and
        // `onDisappear`'s retry would then be the last thing standing
        // between the capture and nothing. `onDisappear` runs after a
        // SUCCESSFUL file, finds an empty pad, and mints nothing — one
        // summon, one note.
        let pad = self.pad
        Task { @MainActor in
            if case .filed = await pad.fileExplicitly() { dismiss() }
        }
    }
}

// MARK: - The mint (the standing quick-entry grammar)

/// WHAT A SUMMON BECOMES. Pure decision + one standing call, kept out of
/// the view so the rule is pinnable: a view's closure is a promise no test
/// can keep (the `MembershipChip.ascend` lesson, W20).
@MainActor
enum QuickNoteMint {
    /// What a filing did — **returned rather than only spoken** (13u3 UNIT
    /// C). The caller knows where she is looking: the pad shows a refusal on
    /// its own face and stays open; `close`/quit, which have no pad left to
    /// draw on, hand it to the status seam's refusal door instead. Speaking
    /// it in both places would be one event said twice.
    enum Outcome: Equatable {
        case filed(String)
        case refused(String)
        /// An empty (or whitespace-only) pad. Files nothing, says nothing —
        /// the button is grey for exactly this case.
        case nothingToFile

        var postID: String? {
            if case .filed(let id) = self { return id }
            return nil
        }
    }

    /// Whether this pad has anything to file. The same rule `importPost`
    /// enforces (`emptyImport` on whitespace-only text), stated here so the
    /// button can be honestly grey rather than firing into a refusal.
    nonisolated static func mints(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// File the pad as an ordinary BOOKLESS note and say where it went.
    ///
    /// It rides `importPost` exactly as the R3 quick-entry bar does, so
    /// every property her ruling names comes from the standing grammar
    /// rather than from a second rule here: untitled; the typed text
    /// SEGMENTS as content under the document-global setting (the
    /// 2026-07-12 spacing ruling and the `one_block` face ride free); and
    /// it joins no CURATED book — since 13g batch 7 (R6-4) the filing tags
    /// it and the smart Quicknotes book collects it (one untag returns it
    /// to the Pool, R29's letter).
    ///
    /// The undo entry says **"Quick Note"** — the label parameter this item
    /// added to `importPost`, so the menu says what she did.
    ///
    /// **`title` is her own adoption** (13u3 UNIT B): nil unless she clicked
    /// the offered name, which keeps "untitled" the pad's default exactly as
    /// this doc says it is.
    @discardableResult
    static func file(
        _ text: String, title: String? = nil, session: AppSession
    ) async -> Outcome {
        guard mints(text) else { return .nothingToFile }
        do {
            // 13g batch 7 (her R6-4): the mint and the FILING ride ONE runner
            // turn, so nothing can interleave between the note existing and
            // the note being a quick note. They are two calls rather than one
            // transaction — `fileAsQuicknote` says why on its own face — and
            // the filing NEVER THROWS, so the capture is never at risk from
            // the shelf's bookkeeping.
            let (result, filing) = try await session.runner.run { ops in
                let result = try ops.importPost(
                    title: title, text: text, undoLabel: QuickNoteCopy.undoLabel)
                return (result, ops.fileAsQuicknote(result.container.id))
            }
            // Her round-14.3: STAY QUIET. One line naming where it went —
            // the main window never navigates. It names the BOOK when the
            // filing worked, because that is now where she will look for
            // it; a REFUSAL speaks its own line (13g cold review R1-3):
            // the note is minted and safe, wears no tag, and the Pool
            // lists it — so the toast must not claim the Quicknotes
            // landing that exactly did not happen.
            switch filing {
            case .filed, .alreadyTagged:
                session.status.receipt(QuickNoteCopy.filedNote)  // 18i: it landed
            case .taggedOnly:
                // 13i-b U4: tagged, and no Quicknotes gathering shows it (she
                // deleted it) — so the line names where it IS.
                session.status.receipt(QuickNoteCopy.filedTaggedOnly)
            case .refused(let reason):
                session.status.refuse(QuickNoteCopy.refusedFilingLine(reason))
            }
            return .filed(result.container.id)
        } catch {
            // **RETURNED, not spoken** (13u3 UNIT C): the note does NOT
            // exist, her words are still in the pad, and the sentence that
            // says so belongs on the pad's own face. The two lifecycle
            // triggers that have no pad left (close, quit) hand it to the
            // status seam themselves.
            return .refused(QuickNoteCopy.refusal(for: error))
        }
    }
}

// MARK: - The menu-bar door (her round-14.1)

/// The `MenuBarExtra`'s contents — the summon-from-anywhere door. It is a
/// menu rather than a window-style extra deliberately: clicking it opens
/// the ONE pad the other two doors open, so all three are the same act.
struct QuickNoteMenuBarContent: View {
    /// The REGISTRY acts this extra renders (P-1's walk) — so its contents
    /// are declared ⇔ rendered exactly like every other door surface's.
    static let menuBarExtraCapabilities: [CapabilityID] = [.quickNote]

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(QuickNoteCopy.summonVerb) {
            // 13e E14: through the ONE summon line, which activates first —
            // this door is pressed with ANOTHER app frontmost by definition,
            // and the floating pad used to open behind it.
            QuickNoteSummon.summon { openWindow(id: $0) }
        }
        .keyboardShortcut("n", modifiers: [.command, .shift])
    }
}

// MARK: - Vocabulary

nonisolated enum QuickNoteCopy {
    /// The registry's ONE verb — the menu-bar extra, ⌘⇧N and the File-menu
    /// item all wear it.
    static let verb = "Quick Note"
    /// The menu-bar row's own words (the extra's title is the app's glyph,
    /// so its one row says what pressing it does).
    static let summonVerb = "New Quick Note"
    static let header = "quick note"
    // 13s-b U1b (R-13s-36/38): the lines NAME the default gathering, so
    // they read its one constant — the fresh default is lowercase now, and
    // copy must never mix casings with the board it describes.
    static let placeholder = "jot it down — it lands in \(Operations.defaultQuicknoteBookName)"
    /// **R-13u-4's two keys, in her own order** (13u3 UNIT C — this line
    /// used to read "⏎ new line · ⌘⏎ files it · closing files it too", which
    /// is the model her ruling replaced). The paragraph key comes second
    /// because filing is what ⏎ now does and that is the surprise for
    /// anyone who knew the old pad.
    static let hint = "⏎ files it · ⇧⏎ new paragraph · closing files it too"
    static let fileVerb = "File It"
    /// The undo entry's words — "Undo Quick Note", never "Undo Import".
    static let undoLabel = "Quick Note"
    /// 13g batch 7 (R6-4): the quick note now wears the `quicknote` tag and
    /// the smart **Quicknotes** book collects it — so the line names the
    /// shelf it can be found on, and NOT the Pool: the Pool lists what no
    /// book holds, and a collected note is held (Stage B's MAJOR 3 — derived
    /// membership counts). One untag puts it back there.
    static let filedNote = "Filed in \(Operations.defaultQuicknoteBookName) — tagged #quicknote."
    /// 13i-b U4 (§20 — Quicknotes is ordinary; P-13ib-U4-2): the line for a
    /// filing that tagged the note while NO Quicknotes gathering shows it —
    /// she deleted it, and her deletion stands. `filedNote` would claim a
    /// landing that did not happen; this says what did: the tag, and where an
    /// untagged-by-any-gathering note is found (the Pool, bookless by
    /// definition).
    static let filedTaggedOnly = "Filed in the Pool — tagged #quicknote."
    /// 13g cold review R1-3: the FILING-refusal line. `filedNote` claims the
    /// Quicknotes landing, which is exactly what a `.refused` outcome says
    /// did NOT happen — the note is minted and durable, carries no tag, and
    /// the Pool lists it (bookless is the Pool's definition). This line
    /// stays true at the moment it is spoken and carries the reason.
    ///
    /// DISCRIMINATING REVERT (verified): return the pre-fix composition
    /// (`"\(filedNote) (\(reason))"`) and
    /// `aFilingRefusalNeverClaimsTheQuicknotesLanding` fails on its first
    /// two expectations.
    static func refusedFilingLine(_ reason: String) -> String {
        "Kept as a note in the Pool — the \(Operations.defaultQuicknoteBookName) filing didn't take: \(reason)."
    }
    static let refusedPrefix = "The quick note wasn't filed:"

    /// **The MINT's refusal — the one whose load-bearing half is the last
    /// sentence** (13u3 UNIT C; the quick-entry bar's `QuickEntryCopy`
    /// wording, deliberately, because it is the same event on the app's
    /// other capture door and two sentences for one thing is the drift
    /// class). Nothing was created, so this line's job is to say where her
    /// words are: still here.
    static func refusal(for error: Error) -> String {
        let reason = error is OperationError
            ? OpsRefusalCopy.message(for: error)
            : "The store couldn't take it just now."
        return "\(refusedPrefix) \(reason) "
            + "Your text is still here — try again in a moment."
    }

    /// **17b row 65, binding 3 — THE CLOSE/QUIT ROAD'S OWN SENTENCE, and it
    /// is now TRUE.** Those two roads spoke `refusal(for:)` above, whose
    /// load-bearing half is *"Your text is still here"* — a promise about a
    /// pad that has just been torn down, said into a status line one window
    /// away. The words really are kept now (the park), so the sentence says
    /// where they are instead of where they aren't.
    ///
    /// **It deliberately carries no REASON**, unlike its pad twin: she is
    /// not looking at the pad on this road, and the reason is actionable
    /// only where the retry is — the next summon brings the words back and
    /// the next ⏎ speaks the reason on the pad if it still applies. Stated
    /// rather than slipped in; PROVISIONAL wording (13s owns her voice),
    /// and the trade rides QUESTIONS #137.
    static let parkedOnClose =
        "The quick note wasn't filed. Your words are kept — the next quick note opens with them."

    /// **The restored pad's own line** (17b row 65, binding 3): why this box
    /// is not empty. PROVISIONAL wording (13s).
    static let restoredCapture = "the capture that couldn't be filed — ⏎ tries again"
}
