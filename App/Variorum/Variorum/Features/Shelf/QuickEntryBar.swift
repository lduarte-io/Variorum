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
    @discardableResult
    func submit() async -> String? {
        let submitted = text
        guard !submitted.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Nothing to keep and nothing to file — and the stale error goes
            // with it.
            text = ""
            lastError = nil
            titleFromFirstWords = false
            return nil
        }
        lastError = nil
        // The name is read from what is being FILED, not from what the box
        // holds now — the same discipline `submitted` already has.
        let title = titleFromFirstWords
            ? NoteCardFace.suggestedTitle(forTypedText: submitted)
            : nil
        do {
            let postID = try await mintNow(submitted, title: title)
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
        return try await session.runner.run { ops in
            try ops.importPost(title: title, text: submitted).container.id
        }
    }
}

/// The bar's own words, in one place so a pin can read the sentence rather
/// than a rendering of it (13l L-b).
enum QuickEntryCopy {
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
    var autofocus = false

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var box: QuickEntryModel
    @FocusState private var entryFocused: Bool
    @State private var cursorOn = true

    init(
        session: AppSession,
        onOpen: @escaping (SidebarSelection) -> Void,
        autofocus: Bool = false
    ) {
        self.onOpen = onOpen
        self.autofocus = autofocus
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
            ZStack(alignment: .topLeading) {
                if box.text.isEmpty {
                    HStack(spacing: 6) {
                        Text(tokens.chromeLabel("new note — just start typing · ⏎ opens it"))
                            .font(tokens.body)
                            .foregroundStyle(tokens.faint)
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
                    .allowsHitTesting(false)
                }
                TextField("", text: $box.text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .focused($entryFocused)
                    .lineLimit(1...4)
                    .onSubmit { submit() }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
            .contentShape(Rectangle())
            .onTapGesture { entryFocused = true }
            // 13u3 UNIT B — the OFFER (her item 4): the first words, one
            // click to take them as the note's title, ignorable forever.
            if let suggestion = box.suggestedTitle {
                TitleSuggestionChip(
                    tokens: tokens, suggestion: suggestion, adopted: box.titleFromFirstWords
                ) {
                    box.titleFromFirstWords.toggle()
                }
            }
            if let lastError = box.lastError {
                // lineLimit is LOAD-BEARING beside fixedSize — an unlimited
                // fixedSize text in non-scrolling chrome inflates the WINDOW
                // minimum during the near-zero-width min-size probe (the
                // wedged-window root cause; see SyncStatusRow).
                Text(lastError)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        .task {
            if autofocus { entryFocused = true }
        }
    }

    private func submit() {
        Task {
            if let postID = await box.submit() { onOpen(.post(postID)) }
        }
    }
}
