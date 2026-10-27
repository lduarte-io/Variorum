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

    /// Returns the note to open, or nil when nothing was minted.
    ///
    /// **13u4 UNIT C1 — THE CAPTURE MICROSYNTAX PARSES HERE** (her ruling
    /// R-13u4-1), at the HAND-OFF and nowhere else: the box holds exactly
    /// what she typed until ⏎ files it, and only then do `{#tag}` and
    /// `{t:"title"}` stop being text. Filing NEVER blocks on a token — the
    /// note is minted first and the tags are applied to it after, so nothing
    /// a token can do costs her the capture.
    @discardableResult
    func submit() async -> String? {
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
            // the sake of tidiness. She sees them still there, and a second
            // ⏎ makes them a second note.
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
    /// surprise).** The quiet line at the box's trailing edge: where what she
    /// types here will live. Shown with ONE wing too (C-552-1 — her "always").
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

struct QuickEntryBar: View {
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
    /// VX-552 (the VX-439 run): the wing a note filed here lands in — the
    /// host's own `WingsModel.currentName` (the app's one wing, which follows
    /// the focused note), never a second observation. nil draws no label (a
    /// host with no wings model — a test, a preview).
    var wingName: String?

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
        standsDown: Bool = false,
        wingName: String? = nil
    ) {
        self.onOpen = onOpen
        self.autofocus = autofocus
        self.standsDown = standsDown
        self.wingName = wingName
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
                    onFile: { submit() })
            }
            // VX-552: the wing she is filing into, beside the box she files
            // in — on the box's first line, at its trailing edge, outside the
            // text (so her typing never runs under it), visible while she types.
            if let wingName {
                Text(tokens.chromeLabel(QuickEntryCopy.wingLabel(wingName)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 180, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Self.placeholderOrigin.y)
                    .help(QuickEntryCopy.wingHelp(wingName))
            }
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
}
