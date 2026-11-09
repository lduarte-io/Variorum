//
//  QuickEntryBar.swift
//  Variorum
//
//  The R3 quick-entry bar, extracted (Sitting 9 batch 8 — her directive:
//  the Library page gets the type-immediately-creates-a-post bar exactly
//  as the round-2 mockup drew it): the hint line, the field, the blinking
//  block cursor (Terminal's idiom), ⏎ mints the typed text as a whole
//  segmented post AND OPENS it. One component, every host (Shelf,
//  Library) — the mockup's shape is the contract.
//
//  13l L-b: the box's RULE — when her typed text may be thrown away — moved
//  out of the view into `QuickEntryModel`, the phone's shape
//  (`MobileQuickNoteModel`) and for the phone's reason: a rule that exists
//  only inside a `Task` in a `View` body cannot be pinned, and this one was
//  wrong.
//

import SwiftUI
import VariorumCore

/// The quick-entry box's rule and its words.
///
/// **THE BOX ONLY CLEARS WHEN THE NOTE ACTUALLY EXISTS** (13l L-b). The
/// view used to write `entryText = ""` BEFORE the mint, so a refusal —
/// anything `importPost` can throw, the store cut off, a failure mid-round
/// — discarded the words she had just typed, **in the bar she uses daily**,
/// and left a raw `\(error)` dump where the reason should be. Her text
/// lives NOWHERE but this box until the mint returns. That is exactly the
/// phone's Q2 case, and it gets the phone's answer: reset ONLY on a
/// completed hand-off, and speak in words.
///
/// *(`QuickNotePad.take()` clears before filing too, deliberately: that pad
/// mints as you type, so the text is already a note by the time it files,
/// and its copy already speaks. Left alone — the two are different
/// machines.)*
@Observable
@MainActor
final class QuickEntryModel {
    var text = ""
    private(set) var lastError: String?

    /// **13u3 UNIT B — her item 4's capture half.** Has she taken the offered
    /// name? Off until she clicks, and off again after a note is filed: a
    /// suggestion is about the words in the box, and the box is now empty.
    /// Nothing is ever applied for her (*"a suggestion, never an action taken
    /// for her"*).
    var titleFromFirstWords = false

    /// The words the chip offers — the ONE brain the Library's cards lead
    /// with, asked of the buffer instead of a note. Nil when there is nothing
    /// to offer, and then no chip is drawn (a door that cannot act is not
    /// rendered).
    var suggestedTitle: String? { NoteCardFace.suggestedTitle(forTypedText: text) }

    @ObservationIgnored private let session: AppSession
    /// The endorsed defaulted-seam pattern (`tailIdleSleep`, the canary
    /// handlers, `teardown(afterDisarm:)` — mobile round 2 §20(b)):
    /// production never sets this, and a refusal is otherwise not reachable
    /// from a test without breaking the store underneath it.
    ///
    /// It carries the TITLE beside the text since 13u3 UNIT B, so a pin can
    /// read what the mint was actually asked for.
    @ObservationIgnored var mint: ((String, String?) async throws -> String)?

    init(session: AppSession) {
        self.session = session
    }

    /// **⏎ — file it** (the bar then opens it). Returns the note to open, or
    /// nil when nothing was minted — including a press made while a filing of
    /// EITHER road is already in the air (VX-928: it lands on that filing).
    @discardableResult
    func submit() async -> String? {
        await oneFilingInFlight { await self.fileTypedText() }
    }

    // MARK: - VX-928 — ONE FILING PER FLIGHT, BOTH ROADS

    /// A filing is in flight — on ⏎'s road or ⌘⏎'s (VX-911's guard, renamed
    /// from `filingWithoutOpening` and moved to where the two roads meet). The
    /// box clears only when the mint returns, so a second press inside the
    /// flight would read the SAME words and mint them again: two notes from one
    /// capture (VX-928 — her ⏎ had no guard; VX-911's guarded only its own
    /// road).
    private(set) var filing = false

    /// **THE ONE GUARD** both roads enter (`submit`, `fileWithoutOpening`): a
    /// press on either road while either road's filing is in the air lands on
    /// that filing — nothing is minted twice. A flight, never a latch: it lifts
    /// the moment the filing returns, refused or not.
    private func oneFilingInFlight(_ body: () async -> String?) async -> String? {
        guard !filing else { return nil }
        filing = true
        defer { filing = false }
        return await body()
    }

    /// The filing itself — the box's words made a note (both roads' body).
    ///
    /// **13u4 UNIT C1 — THE CAPTURE MICROSYNTAX PARSES HERE** (her ruling
    /// R-13u4-1), at the HAND-OFF and nowhere else: the box holds exactly
    /// what she typed until ⏎ files it, and only then do `{#tag}` and
    /// `{t:"title"}` stop being text. Filing NEVER blocks on a token — the
    /// note is minted first and the tags are applied to it after, so nothing
    /// a token can do costs her the capture.
    private func fileTypedText() async -> String? {
        let submitted = text
        let capture = CaptureMicrosyntax.parse(submitted)
        guard !capture.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Nothing to keep and nothing to file — and the stale error goes
            // with it. A capture of NOTHING BUT TOKENS lands here too: there
            // is no note for a tag to go on, so the door takes its standing
            // empty branch unchanged (PROVISIONAL, QUESTIONS #127(f)).
            text = ""
            lastError = nil
            titleFromFirstWords = false
            return nil
        }
        lastError = nil
        // The name is read from what is being FILED, not from what the box
        // holds now — the same discipline `submitted` already has. A
        // `{t:"…"}` token outranks the offered first words, and when she
        // HAS taken the offer the words are read from the CLEANED text, so
        // a token can never end up inside the stored name (#127(e)).
        let title = capture.title
            ?? (titleFromFirstWords
                ? NoteCardFace.suggestedTitle(forTypedText: capture.text)
                : nil)
        do {
            let postID = try await mintNow(capture.text, title: title)
            // The note exists; the tokens act on it now. A tag that does not
            // land speaks a refusal (18i: a door that did nothing says so)
            // and NOTHING is undone.
            for refusal in await CaptureMicrosyntax.applyTags(
                capture, toPost: postID, session: session,
                wording: TagsViewModel.message
            ) {
                session.status.refuse(refusal)
            }
            // **Only what was actually minted is cleared.** Keystrokes that
            // landed during the flight are not in that note — the mint read
            // `submitted` — so clearing them wholesale would lose them for
            // the sake of tidiness. She sees them still there, and a ⏎ after
            // the flight makes them a second note (VX-928: a ⏎ INSIDE it
            // lands on this filing).
            if text == submitted {
                text = ""
                titleFromFirstWords = false
            }
            return postID
        } catch {
            // A refusal keeps her text AND her decision about its name: both
            // are still in front of her, and a second ⏎ must do what the
            // first one was asked to.
            lastError = QuickEntryCopy.refusal(for: error)
            return nil
        }
    }

    // MARK: - VX-911 — FILE WITHOUT OPENING (the forks RULED, PROVISIONAL)

    /// **Is there something to file?** The submit road's own test — the
    /// capture with its tokens taken out, trimmed — so the button is grey
    /// exactly where ⏎ would file nothing (an empty box, a capture of nothing
    /// but tokens, #127(f)), and while a filing of either road is in flight
    /// (VX-928 — the one guard's flag).
    var canFile: Bool {
        !filing && !CaptureMicrosyntax.parse(text).text
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// **⌘⏎ and the band's button** (`.fileWithoutOpening`): the note is made
    /// through the SAME road as ⏎ (`submit` — the microsyntax at the hand-off,
    /// the title chip, the clear-only-what-minted rule, a refusal keeping her
    /// text), and then NOTHING opens: the box is already clear for the next
    /// note, and a quiet receipt says where this one landed — the duplicate's
    /// landing read (books only: an arrival is no membership, so a note
    /// waiting at a book's Arrivals is still in the Pool), carrying a one-press
    /// door to the note through `open` (the host's own road, never a
    /// broadcast). Returns the note, or nil when nothing was filed (an empty
    /// box says nothing, exactly as ⏎ does). The one guard covers the whole
    /// staying filing — the mint, the landing read and the receipt — as it
    /// always has; a press of either road inside it lands on it (VX-928).
    @discardableResult
    func fileWithoutOpening(open: @escaping @MainActor (String) -> Void) async -> String? {
        await oneFilingInFlight {
            guard let postID = await self.fileTypedText() else { return nil }
            // The one landing read — the pad's filing in another wing reads
            // the same (`CaptureLanding`, the VX-915 ladder's F-1).
            let books = try? await self.session.database.read { db in
                try CaptureLanding.books(db, postID: postID)
            }
            self.session.status.deliver(
                QuickEntryFileCopy.landed(books: books), kind: .receipt,
                action: StatusCenter.Item.Action(label: QuickEntryFileCopy.openNote) {
                    open(postID)
                })
            return postID
        }
    }

    private func mintNow(_ submitted: String, title: String?) async throws -> String {
        if let mint { return try await mint(submitted, title) }
        // 13i-d U5: the Bookcase's capture lands in the wing she stands in.
        let wing = session.wing.currentID
        return try await session.runner.run { ops in
            try ops.importPost(title: title, text: submitted, wingId: wing).container.id
        }
    }
}

/// The bar's own words, in one place so a pin can read the sentence rather
/// than a rendering of it (13l L-b).
enum QuickEntryCopy {
    /// **The box's one teaching line** (13u3 UNIT C — her R-13u-4). It used
    /// to live as a literal inside the view and to say only half the rule
    /// ("new note — just start typing · ⏎ opens it"); the other key now has
    /// to be said, and a sentence a pin can read is a sentence that stays
    /// true. "Opens" rather than "files" is R3's own grammar, kept: this
    /// door files the note AND navigates to it, which is what the bar has
    /// always done and what distinguishes it from the pad.
    static let placeholder = "new note — just start typing · ⏎ opens it · ⇧⏎ new paragraph"

    /// **VX-552 (the VX-439 run — her ask: the wing you're in always visible
    /// beside the New Note door, so a new note's landing place is never a
    /// surprise).** The quiet "in ‹wing›" word: where a new note will live.
    /// Shown with ONE wing too (C-552-1 — her "always"). Its one home is the
    /// window toolbar, beside New Note (`RootView`), where it is also the wing
    /// switcher's door (VX-644). **VX-738 (her R-736-7): it is OFF the
    /// quick-entry bars** — "shouldn't be there at all. they can see the
    /// swapper in the upper left corner." The words stay here, the bar's
    /// copy, because they were born here.
    static func wingLabel(_ wingName: String) -> String { "in \(wingName)" }
    /// Its hover — the whole fact.
    static func wingHelp(_ wingName: String) -> String {
        "A note made here lands in the \u{201C}\(wingName)\u{201D} wing \u{2014} \u{2318}L switches wings"
    }

    /// The refusal names the act, hands the reason to the app's ONE
    /// operations vocabulary — never the raw `\(error)` dump this printed
    /// until now — and ends with the half that is load-bearing: her text is
    /// still in the box, and this sentence is the only thing that tells her.
    static func refusal(for error: Error) -> String {
        let reason = error is OperationError
            ? OpsRefusalCopy.message(for: error)
            // Not an operations refusal — a store-level failure. Named
            // plainly rather than dumped, because there is nothing she can
            // act on in the description of one.
            : "The store couldn't take it just now."
        return "The note wasn't created. \(reason) "
            + "Your text is still here — try again in a moment."
    }
}

/// **VX-911 — File Without Opening's words, in one place** (the forks RULED,
/// PROVISIONAL — her wording bundle). `nonisolated` for `DuplicateCopy`'s
/// reason: the capability table is nonisolated and reads the verb here.
nonisolated enum QuickEntryFileCopy {
    /// The registry's verb (`.fileWithoutOpening`).
    static let verb = "File Without Opening"
    /// The button's word; the chord beside it is READ from the declaration
    /// (`buttonLabel`), never typed twice.
    static let buttonWord = "File"
    /// The button's face: its word and the act's declared key ("File ⌘⏎").
    static func buttonLabel(chord: String?) -> String {
        guard let chord, !chord.isEmpty else { return buttonWord }
        return "\(buttonWord) \(chord)"
    }
    /// Its hover — what it does, and what happens to the box.
    static let help = "File it without opening it \u{2014} the box clears for the next note"
    /// The receipt's one-press door to the note it filed (the duplicate's
    /// "Open ›", the AI receipts' idiom).
    static let openNote = "Open \u{203A}"

    /// **Where it landed** — the pad's "Filed in …" grammar, with the
    /// duplicate's book read: no book holds it → the Pool (bookless is the
    /// Pool's definition); a book a `{#tag}` seated it in → named; several →
    /// counted. Nil — the landing could not be read — says only that it filed.
    /// The place is `CaptureLanding`'s one rule (the pad names its landing
    /// through it too — the VX-915 ladder's F-1); these words are unchanged.
    static func landed(books: [String]?) -> String {
        guard let books else { return "Filed." }
        return "Filed in \(CaptureLanding.place(books: books, pool: "the Pool"))."
    }
}

struct QuickEntryBar: View {
    /// P-1: the band's one declared door — VX-911's File Without Opening,
    /// declared with the BUILDER so both hosts (the Bookcase's band and the
    /// Library's) are covered by construction (the `MarkdownActs` precedent).
    static let surfaceCapabilities: [CapabilityID] = [.fileWithoutOpening]

    let onOpen: (SidebarSelection) -> Void
    /// Batch 9 (R102): the shelf is the terminal home — it opens with the
    /// cursor already in the bar, so "start typing" is literal. Library
    /// leaves focus alone.
    ///
    /// **VX-332 (the VX-439 run — her ruling: "YES — focus on every return").**
    /// EVERY autofocus mount asks, and every ask takes the box's waiting,
    /// never-stealing road (`CaptureOpeningFocus` — VX-326's opening ask):
    /// it waits for the box to be in its window, then takes the caret only
    /// when nothing else in that window holds the keyboard and no sheet is up.
    /// So a window opening on the Bookcase AND every return to it (a sidebar
    /// click, ⌥⌘[, a note closed) put the caret here, and a field, a sheet or
    /// another pane's editor is never robbed (P-U6-2's option (b), R102's
    /// wording). VX-326's one-shot shell claim (`QuickEntryOpeningFocus`) is
    /// RETIRED with the ruling: it existed to keep later mounts OFF this road.
    var autofocus = false
    /// **VX-332 — the tour holds the window** (the W-U1a-1 lesson: a caret
    /// left in the quick entry turns the next keystroke into a note). While a
    /// tour runs, a mount does not ask at all; the tour's own arrival releases
    /// whatever held the keyboard, and nothing here takes it back.
    var standsDown = false
    // VX-738 (the VX-736 run, B2 — her R-736-7): the bar's "in ‹wing›" label
    // is GONE, and with it the `wingName` and `onWingLabel` inputs and the
    // bar's one `.surface` door (`.switchWing`, VX-644). The bar renders no
    // act of its own; the toolbar's label beside New Note stays the wing
    // switcher's door (`RootView.surfaceCapabilities`).

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var box: QuickEntryModel
    /// Plain state rather than `@FocusState` since 13u3 UNIT C: the caret
    /// lives in an AppKit box now, and the one honest report of where it is
    /// comes from that box's own first-responder changes (17y B2 (m) — it
    /// was its begin/end EDITING, which missed a caret that arrived without
    /// a keystroke: two cursors). The block-cursor idiom is the only reader.
    @State private var entryFocused = false
    /// A counted focus REQUEST, the capture box's own door: raised once when
    /// the shelf wants the caret here, and again whenever she clicks the
    /// box's padding rather than its text.
    @State private var focusRequest = 0
    /// The waiting, never-stealing ask (VX-326's road), raised at every
    /// autofocus mount since VX-332.
    @State private var openingFocusRequest = 0
    @State private var cursorOn = true

    /// **The box's bound** (13u3 UNIT C — the brief's "pick a sane max
    /// height and record it PROVISIONAL"; QUESTIONS #120(c)). Her ruling
    /// gives this box many paragraphs, and an unbounded one in a busy
    /// window would push the shelf's own content off the bottom as she
    /// types. 160 pt is about eight lines in either voice — past that it
    /// scrolls, and the note it becomes has no such limit.
    private static let maxBoxHeight: CGFloat = 160

    /// **Where the placeholder sits, relative to the box** (VX-179 U3 — the
    /// F-U3-1 ruling's Q-2). The placeholder shares the box's `ZStack`
    /// origin, so its offset IS the box's own first-line origin — read from
    /// the box, never re-typed here. Before this it was (0, 0): the hint sat
    /// 2 pt above the line her typing lands on.
    static var placeholderOrigin: CGPoint { CaptureTextView.firstLineOrigin }

    init(
        session: AppSession,
        onOpen: @escaping (SidebarSelection) -> Void,
        autofocus: Bool = false,
        standsDown: Bool = false
    ) {
        self.onOpen = onOpen
        self.autofocus = autofocus
        self.standsDown = standsDown
        _box = State(initialValue: QuickEntryModel(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        // Batch 14 (her call, with the round-1 mockup attached): the
        // DASHED-BOX cutout — "i like this box cutout separation more and
        // think it looks more like the terminal." The hint lives INSIDE
        // the box as the placeholder; typing replaces it.
        @Bindable var box = box
        return VStack(alignment: .leading, spacing: 4) {
            // VX-911 (F-911 seat (1), RULED PROVISIONAL): the box and, at its
            // trailing end on its first line, File Without Opening — inside the
            // dashed cutout, so the door sits beside what it files.
            HStack(alignment: .top, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    if box.text.isEmpty {
                        HStack(spacing: 6) {
                            Text(tokens.chromeLabel(QuickEntryCopy.placeholder))
                                .font(tokens.body)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                            if tokens.showsBlockCursor && !entryFocused {
                                Rectangle()
                                    .fill(tokens.accent)
                                    .frame(width: 8, height: 16)
                                    .opacity(cursorOn ? 1 : 0)
                                    .task {
                                        while !Task.isCancelled {
                                            try? await Task.sleep(for: .milliseconds(550))
                                            cursorOn.toggle()
                                        }
                                    }
                            }
                        }
                        // VX-179 U3 (F-U3-1 ruling Q-2): the hint sits ON the
                        // box's first line — the box's own named origin, never
                        // the ZStack's top (measured: 2 pt high, so the words
                        // dropped as she started typing).
                        .padding(.leading, Self.placeholderOrigin.x)
                        .padding(.top, Self.placeholderOrigin.y)
                        .allowsHitTesting(false)
                    }
                    // 13u3 UNIT C — THE ONE CAPTURE BOX (R-13u-4): ⏎ files it
                    // (and opens it, R3's grammar), ⇧⏎ makes a paragraph, and
                    // the floating quick-note pad answers the same two keys
                    // through this same component.
                    CaptureTextView(
                        text: $box.text,
                        style: CaptureTextStyle(tokens: tokens),
                        maxHeight: Self.maxBoxHeight,
                        focusRequest: focusRequest,
                        openingFocusRequest: openingFocusRequest,
                        onFocusChange: { entryFocused = $0 },
                        onFile: { submit() },
                        // VX-911: the box claims ⌘⏎ only because THIS host hands
                        // it the act (the pad hands none — its own File It keeps
                        // the key), and only while the box holds the keyboard.
                        onFileWithoutOpening: { fileWithoutOpening() })
                }
                fileButton
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
            .contentShape(Rectangle())
            .onTapGesture { focusRequest += 1 }
            // 13s-b U2: step 11 points at the dashed box itself ("the dashed
            // line at the bottom"). The tour lights it on the Bookcase only.
            .tourAnchor(.quickEntry)
            // 13u3 UNIT B — the OFFER (her item 4): the first words, one
            // click to take them as the note's title, ignorable forever.
            if let suggestion = box.suggestedTitle {
                TitleSuggestionChip(
                    tokens: tokens, suggestion: suggestion, adopted: box.titleFromFirstWords
                ) {
                    box.titleFromFirstWords.toggle()
                    // 13u3 ladder round 1, R1-6 (SPECULATIVE hardening — the
                    // acceptance walk's unreproduced first-⏎ miss): deciding
                    // about the name hands the caret straight back to the
                    // words, so ⏎ files whatever held keys during the click.
                    // A no-op when the box never lost them (takeFocus guards).
                    focusRequest += 1
                }
            }
            if let lastError = box.lastError {
                // lineLimit is LOAD-BEARING beside fixedSize — an unlimited
                // fixedSize text in non-scrolling chrome inflates the WINDOW
                // minimum during the near-zero-width min-size probe (the
                // wedged-window root cause; see SyncStatusRow).
                // 13u3 UNIT C: the ALARM register, not the accent. A refusal
                // painted in the voice's positive/accent colour read as a
                // receipt; A2 settled the vocabulary one unit earlier
                // ("refusals speak in its alarm") and the pad's line beside
                // this one wears the same.
                Text(lastError)
                    .font(tokens.small)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .alarmVoice()
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        // VX-121: the whole band — box, title chip, refusal line and their
        // air — is one a status toast never covers (the shell's host lifts the
        // toast above it: `StatusToastPlacement`). The bar marks itself, so
        // the Bookcase's foot and the Library's are kept clear alike.
        .statusToastKeepClear()
        .task {
            // VX-332: every mount asks — through the waiting road, which a
            // launch's swap and a navigation back both need (the ask reaches
            // the box before SwiftUI has put it in its window, the VX-282
            // record's O-U6-1), and which takes only a free keyboard. The
            // counted `focusRequest` (an explicit ask — the padding tap, the
            // title chip) is no longer a mount's road: it does not wait, and
            // it would take the keyboard from whatever held it.
            guard autofocus, !standsDown else { return }
            openingFocusRequest += 1
        }
    }

    private func submit() {
        Task {
            if let postID = await box.submit() { onOpen(.post(postID)) }
        }
    }

    // MARK: - VX-911 — File Without Opening (F-911 seat (1) + receipt (a), RULED PROVISIONAL)

    /// **The band's button** — the pad's File It idiom: always drawn, grey
    /// while the box holds nothing to file (P-2: honestly grey, never enabled
    /// into nothing), its word and the act's DECLARED key ("File ⌘⏎" — read
    /// from the registry, never typed twice), its hover the act. Never a
    /// key-view stop: it is clicked, and ⌘⏎ is its key — a Tab from the box
    /// never lands here, so the opening-caret law (VX-332) and the box's own
    /// keys stay whole (the coach card's `.focusable(false)` precedent).
    private var fileButton: some View {
        let act = CapabilityRegistry.capability(.fileWithoutOpening)
        return Button(tokens.chromeLabel(
            QuickEntryFileCopy.buttonLabel(chord: act.alternateShortcutLabel))
        ) {
            fileWithoutOpening()
            // The press hands the caret straight back to the box (the title
            // chip's road — an explicit ask, never the opening one), so the
            // next note is typed without reaching for the box again.
            focusRequest += 1
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        .disabled(!box.canFile)
        .focusEffectDisabled()
        .focusable(false)
        .help(QuickEntryFileCopy.help)
        .accessibilityLabel(act.verb)
        // On the box's first line (its own named origin, as the placeholder).
        .padding(.top, Self.placeholderOrigin.y)
        .lineLimit(1)
        .fixedSize()
    }

    /// File it and stay: the band clears for the next note (the model's own
    /// clear-only-what-minted rule) and the receipt's Open › reaches the note
    /// through THIS host's open road.
    private func fileWithoutOpening() {
        let open = onOpen
        Task {
            await box.fileWithoutOpening { postID in open(.post(postID)) }
        }
    }
}
