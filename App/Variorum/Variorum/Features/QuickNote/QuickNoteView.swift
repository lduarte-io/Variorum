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
//  ── WHEN IT MINTS (her round-14.2 ruling) ───────────────────────────────
//  **⏎ IS A NEWLINE** — the pad is free-typing and multi-line. The note
//  mints on **CLOSE**, on **⌘⏎** (filing it explicitly), and at **QUIT**
//  (the architect's ruling (c): the capture-scale analog of the open tail's
//  teardown backstop — loss is bounded by one summon, and this is what
//  bounds it). ONE SUMMON = ONE NOTE, and an empty sticky mints nothing.
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

    init(session: AppSession) { self.session = session }

    /// Is there anything to file? The button's grey reads this, so it can
    /// never fire into `emptyImport`.
    var mints: Bool { QuickNoteMint.mints(text) }

    /// ⌘⏎ — file it explicitly. The pad clears, so the `close` that follows
    /// finds nothing and ONE SUMMON STILL MINTS ONE NOTE (her round-14.2).
    @discardableResult
    func fileExplicitly() async -> String? { await take() }

    /// CLOSING FILES IT (her round-14.2). Idempotent by the same clearing.
    @discardableResult
    func close() async -> String? { await take() }

    /// QUIT (the architect's ruling (c)): a non-empty pad at app quit files
    /// itself — the capture-scale analog of the open tail's teardown
    /// backstop, and what bounds the loss to one summon.
    @discardableResult
    func finalizeAtQuit() async -> String? { await take() }

    /// The one body all three share: take the text, clear the pad, file it.
    /// Clearing FIRST is what makes the three triggers compose — close
    /// follows ⌘⏎, and quit can follow either, and none of them can mint a
    /// second note from the same summon.
    ///
    /// **13j J11:** filing IS the pad's leaving — the note it mints is not
    /// open in any pane, so no other road would ever reach it, and a captured
    /// thought with no savepoint is exactly the thin history she reported.
    /// One line, on the one shared body, so all three triggers inherit it.
    private func take() async -> String? {
        let text = self.text
        // The name is read from what is being FILED, before the pad clears.
        let title = titleFromFirstWords
            ? NoteCardFace.suggestedTitle(forTypedText: text)
            : nil
        self.text = ""
        titleFromFirstWords = false
        guard let postID = await QuickNoteMint.file(text, title: title, session: session)
        else { return nil }
        await session.savepointOnLeaving(postID)
        return postID
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
    /// The quit-finalize registration (the architect's ruling (c)).
    @State private var quitToken: UUID?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

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
            // A plain multi-line field: ⏎ types a newline (her ruling), so
            // this deliberately carries NO `.onSubmit`.
            TextEditor(text: $pad.text)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .scrollContentBackground(.hidden)
                .background(tokens.surface)
                .overlay(alignment: .topLeading) {
                    if pad.text.isEmpty {
                        Text(tokens.chromeLabel(QuickNoteCopy.placeholder))
                            .font(tokens.body)
                            .foregroundStyle(tokens.faint)
                            .padding(.top, 8)
                            .padding(.leading, 5)
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
                }
            }
            HStack {
                // `lineLimit` beside a hint in non-scrolling chrome — P-8's
                // b6dae25 class.
                Text(tokens.chromeLabel(QuickNoteCopy.hint))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
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
            // THE QUIT PATH: a non-empty pad at app quit files itself.
            let pad = self.pad
            quitToken = session.quitFinalize.register { @MainActor in
                await pad.finalizeAtQuit()
            }
        }
        .onDisappear {
            windows.unregister(windowID)
            if let quitToken { session.quitFinalize.unregister(quitToken) }
            // CLOSING FILES IT (her ruling). The window is already going, so
            // this rides the pad rather than this view's lifetime.
            let pad = self.pad
            Task { @MainActor in await pad.close() }
        }
    }

    private func fileAndClose() {
        // ⌘⏎ files explicitly. `onDisappear` runs next, finds an empty pad,
        // and mints nothing — one summon, one note.
        let pad = self.pad
        Task { @MainActor in
            await pad.fileExplicitly()
            dismiss()
        }
    }
}

// MARK: - The mint (the standing quick-entry grammar)

/// WHAT A SUMMON BECOMES. Pure decision + one standing call, kept out of
/// the view so the rule is pinnable: a view's closure is a promise no test
/// can keep (the `MembershipChip.ascend` lesson, W20).
@MainActor
enum QuickNoteMint {
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
    static func file(_ text: String, title: String? = nil, session: AppSession) async -> String? {
        guard mints(text) else { return nil }
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
            case .refused(let reason):
                session.status.refuse(QuickNoteCopy.refusedFilingLine(reason))
            }
            return result.container.id
        } catch {
            session.status.refuse(
                "\(QuickNoteCopy.refusedPrefix) \(OpsRefusalCopy.message(for: error))")
            return nil
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
    static let placeholder = "jot it down — it lands in Quicknotes"
    /// ⏎ is a NEWLINE here (her ruling), so the hint says the two things
    /// that are not obvious: how to file, and where it goes.
    static let hint = "⏎ new line · ⌘⏎ files it · closing files it too"
    static let fileVerb = "File It"
    /// The undo entry's words — "Undo Quick Note", never "Undo Import".
    static let undoLabel = "Quick Note"
    /// 13g batch 7 (R6-4): the quick note now wears the `quicknote` tag and
    /// the smart **Quicknotes** book collects it — so the line names the
    /// shelf it can be found on, and NOT the Pool: the Pool lists what no
    /// book holds, and a collected note is held (Stage B's MAJOR 3 — derived
    /// membership counts). One untag puts it back there.
    static let filedNote = "Filed in Quicknotes — tagged #quicknote."
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
        "Kept as a note in the Pool — the Quicknotes filing didn't take: \(reason)."
    }
    static let refusedPrefix = "The quick note wasn't filed:"
}
