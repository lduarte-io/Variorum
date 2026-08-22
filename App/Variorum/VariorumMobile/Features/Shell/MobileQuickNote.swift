//
//  MobileQuickNote.swift
//  VariorumMobile
//
//  Mobile Round 2, batch 3b — THE HOME-SCREEN QUICK NOTE (ledger M5, her
//  ruling R5: *"in the 'quick note' box on the home screen, if the user
//  just closes the app, their note should still be saved! it should have
//  generous instant saving so that even if they forget to hit enter or
//  press the button to edit it fully, it's still saved and it should show
//  a little icon when saved."*)
//
//  The Mac's `QuickEntryBar` is the surface she praised and this is its
//  phone edition — with ONE inversion that is the whole point of her
//  ruling: **the Mac bar keeps nothing until ⏎; this box mints first and
//  edits after.** The architect's rulings A5-1…A5-8 (`notes/plans/
//  mobile-round-2.md` §11) are the build spec; the mechanism survey they
//  rule over is `mobile-round-2-quicknote-survey.md`.
//
//  · **A5-2 — ONE BLOCK, minted through `Operations.importPost`.** Same
//    cost as `newBlock` and strictly better: newline-free typing yields
//    exactly one block, while a pre-mint PASTE of several paragraphs
//    segments correctly for free (AppSpec's bulk-entry rule, honoured
//    rather than special-cased). After the mint the box owns the LAST
//    minted block's variant and autosaves it like any note.
//  · **A5-3 — the mint clock.** The first NON-WHITESPACE character arms a
//    ~1 s clock; FOUR occasions mint early (⏎ · the open door · the app
//    backgrounding · navigating away). The early-mint occasions are the
//    load-bearing half — they are what make her sentence true instead of
//    true-after-a-second.
//  · **A5-6 — a fixed row under the path line**, outside the ScrollView,
//    and **NO AUTOFOCUS** (a keyboard on every launch is hostile; the
//    phone's home screen is also a place she reads).
//  · **A5-7 — three states** (typing → saving → saved) present from the
//    first non-whitespace character, spoken for VoiceOver, and NEVER
//    mentioning sync: this indicator can honestly claim only "on this
//    iPhone" (offline is the phone's normal; the sync row owns that
//    state).
//
//  **P3 is not engaged here**, exactly as the Mac pad's own header
//  reasons: a SwiftUI `TextField` mounts no TK2 surface, carries no
//  `BlockRangeIndex`, and is not a `MobileEditorViewModel`, so it never
//  takes the pen from the one live editor. The Library tab already ships
//  a `TextField` on an identically-composed "no live editor here"
//  surface.
//

import SwiftUI
import VariorumCore

// MARK: - The box's words (one home, so the pins read what renders)

@MainActor
enum MobileQuickNoteCopy {
    /// The Mac bar's hint, phone-worded (its `⏎ opens it` grammar is
    /// A5-1's, and it is the reason no newline can be typed here).
    static let hint = "new note — just start typing · ⏎ opens it"
    /// The visible door A5-1 requires beside ⏎ ("press a button to go into
    /// the particular note for it" — her sentence names both).
    static let openDoor = "open ↵"
    static let openDoorSpoken = "Open this note in the editor"
    /// The undo entry's words (`importPost`'s own `undoLabel` parameter —
    /// its doc comment names this very feature).
    static let undoLabel = "Quick Note"

    /// The indicator's face. `nil` before the first non-whitespace
    /// character — the row does not render at all until there is something
    /// to be honest about (A5-7's "present from the first non-whitespace
    /// character").
    static func indicator(_ state: MobileQuickNoteModel.SaveState) -> String? {
        switch state {
        case .idle: return nil
        case .typing: return "typing…"
        case .saving: return "saving…"
        case .saved: return "✓ saved"
        }
    }

    /// The spoken form (MobileSoul §5.6 — a custom indicator with a
    /// glyph has no spoken form without one). **The "saved" state names
    /// the honest scope and NEVER sync** (A5-7): a committed row is on
    /// this phone, and whether it has reached the mirror is the sync
    /// row's fact, not this box's.
    static func spokenIndicator(_ state: MobileQuickNoteModel.SaveState) -> String? {
        switch state {
        case .idle: return nil
        case .typing: return "Typing. Not saved yet."
        case .saving: return "Saving."
        case .saved: return "Saved on this iPhone."
        }
    }

    static func refusal(_ error: Error) -> String {
        "Quick note refused: \(error)"
    }
}

// MARK: - The brain

/// The box's model. It holds the TEXT (never the view's `@State`) for two
/// load-bearing reasons: a navigation away must be able to file what is in
/// the box *after* the view has gone, and the app-lifecycle seam must be
/// able to reach it from `scenePhase`.
@MainActor
@Observable
final class MobileQuickNoteModel {

    /// A5-7's three states, plus the honest empty one.
    ///
    /// - `idle` — nothing worth saving has been typed; the indicator does
    ///   not render.
    /// - `typing` — typed text that is not in the store and has no write
    ///   under way. Two occasions: the pre-mint quiet window, and a
    ///   refusal that left the coordinator dirty (the survey's honesty
    ///   trap — a settle-driven icon must stay un-saved on a refusal
    ///   rather than settle optimistically).
    /// - `saving` — a write is in flight or scheduled (the mint running, or
    ///   an autosave inside its debounce).
    /// - `saved` — everything in the box is committed to SQLite. Durable
    ///   through an app kill (WAL), and queued for sync in the same
    ///   transaction (the outbox trigger — SyncSpec §3), which is why the
    ///   indicator never needs a second sync claim.
    enum SaveState: Equatable {
        case idle
        case typing
        case saving
        case saved
    }

    // MARK: Observable state

    /// The box's text. Every mutation route — the field's binding, the
    /// clear at a hand-off, a test — runs through `didSet`, so there is no
    /// "the view forgot to tell the model" failure mode.
    var text: String = "" {
        didSet {
            guard !suppressChange else { return }
            guard text != oldValue else { return }
            handleTextChange(from: oldValue)
        }
    }

    private(set) var saveState: SaveState = .idle
    private(set) var lastError: String?
    /// The minted note, once it exists (nil in the sub-mint window).
    private(set) var postID: String?
    /// Set when a hand-off wants the shell to open the note — the ⏎ road
    /// and the open door both land here, so navigation stays the view's
    /// job and the model stays testable without a closure.
    private(set) var pendingOpen: String?
    /// Bumped every time the box actually FILES a note and lets go. The
    /// face drops the keyboard on it — found by driving the real surface:
    /// a tab switch files the box, but the field is still first responder
    /// on a shelf that is now behind the Library, so the keyboard stayed
    /// up over a box nobody can see. A `saveState == .idle` reading would
    /// not do: deleting back to an empty box is also idle, and dropping
    /// the keyboard while she is still typing is worse than the bug.
    private(set) var handOffCount = 0

    // MARK: Wiring (never observed — none of it renders)

    @ObservationIgnored private(set) var session: AppSession?
    @ObservationIgnored private(set) var variantID: String?
    /// The text of the blocks the box does NOT own — everything the mint
    /// segmented ahead of the last block. Empty in the ordinary
    /// (newline-free) capture, which is why the ordinary case is exact.
    @ObservationIgnored private(set) var frozenPrefix = ""
    /// The tail as last handed to the autosave coordinator (the charDelta
    /// baseline).
    @ObservationIgnored private var lastRecordedTail = ""
    @ObservationIgnored private var autosave: AutosaveCoordinator?
    @ObservationIgnored private var settleToken: UUID?
    @ObservationIgnored private var clockTask: Task<Void, Never>?
    @ObservationIgnored private var mintTask: Task<String?, Never>?
    @ObservationIgnored private var suppressChange = false

    // MARK: Injected clocks (production defaults; tests drive them)

    /// A5-3's number. Deliberately NOT the editor's 2 s idle clock: that
    /// one governs text which is ALREADY durable, and hers is *"generous
    /// instant saving"*.
    @ObservationIgnored var mintDelay: Duration = .milliseconds(1000)
    @ObservationIgnored var sleep: @Sendable (Duration) async throws -> Void = {
        try await Task.sleep(for: $0)
    }
    /// Passed to the post's coordinator when the box mints it (the session
    /// cache means the first caller's clock wins — exactly what a
    /// deterministic harness needs).
    @ObservationIgnored var autosaveDebounce: Duration = .milliseconds(500)
    @ObservationIgnored var autosaveSleep: (@Sendable (Duration) async throws -> Void)?

    init(session: AppSession? = nil) {
        self.session = session
    }

    /// Idempotent, and deliberately so: the shell binds the store's session
    /// once the bootstrap is ready, and a re-created view must never swap
    /// the session out from under a note the box already owns.
    func bind(session: AppSession) {
        if self.session == nil { self.session = session }
    }

    // MARK: - Predicates (pure — the door's grey reads them)

    /// Is there anything to mint? Mirrors `importPost`'s own `emptyImport`
    /// refusal, so the box can never fire into it.
    nonisolated static func mints(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var mints: Bool { MobileQuickNoteModel.mints(text) }

    /// Churn cost for one text change: characters removed + characters
    /// inserted, equal weight (AppSpec §10). A plain field reports no
    /// ranges, so the cost is recovered from the common prefix/suffix —
    /// which is exact for a keystroke and honest for an autocorrect
    /// replacement (where a length diff alone would report zero).
    ///
    /// **Deliberately local, not hoisted (M-C weighed):** the Mac has no
    /// mint-as-you-type surface, so there is no second implementation for
    /// this to fork from. If the Mac's bar ever adopts this shape (the
    /// survey §8 records the question), this is the function that moves to
    /// `Shared/`.
    nonisolated static func charDelta(from old: String, to new: String) -> Int {
        let before = Array(old)
        let after = Array(new)
        var prefix = 0
        while prefix < before.count, prefix < after.count, before[prefix] == after[prefix] {
            prefix += 1
        }
        var suffix = 0
        while suffix < before.count - prefix, suffix < after.count - prefix,
              before[before.count - 1 - suffix] == after[after.count - 1 - suffix] {
            suffix += 1
        }
        return (before.count - prefix - suffix) + (after.count - prefix - suffix)
    }

    /// Was this change a single typed RETURN? A5-1 makes ⏎ open the note,
    /// which means a newline can never be typed into the box — but A5-2's
    /// whole benefit is that a pre-mint PASTE of several paragraphs
    /// segments correctly, so newlines that ARRIVE IN BULK must survive.
    /// One inserted character which is a newline is the return key; a
    /// multi-character insertion is a paste and keeps every newline it
    /// carries.
    nonisolated static func isTypedReturn(from old: String, to new: String) -> Bool {
        guard new.count == old.count + 1 else { return false }
        let before = Array(old)
        let after = Array(new)
        var prefix = 0
        while prefix < before.count, before[prefix] == after[prefix] { prefix += 1 }
        return after[prefix] == "\n"
    }

    // MARK: - The text pipeline

    private func handleTextChange(from oldValue: String) {
        // ⏎ — strip the newline and hand off (A5-1). The strip happens
        // before anything else, so the newline never reaches the store,
        // never reaches the coordinator, and never reaches the mint.
        if MobileQuickNoteModel.isTypedReturn(from: oldValue, to: text) {
            write(oldValue)
            open()
            return
        }

        if variantID != nil {
            applyOwnedChange()
            return
        }

        // NOT YET MINTED. The first non-whitespace character arms the
        // clock; whitespace alone never mints (importPost refuses it).
        if mints {
            armMintClock()
            if saveState == .idle { saveState = .typing }
        } else {
            cancelMintClock()
            saveState = .idle
            lastError = nil
        }
    }

    /// One owned-block change: the box owns the last minted block's
    /// variant, and everything after the frozen prefix is that block's
    /// text.
    private func applyOwnedChange() {
        guard text.hasPrefix(frozenPrefix) else {
            // THE CLAMP, and it is only reachable after a multi-paragraph
            // PASTE was minted (the ordinary capture's prefix is empty):
            // she has deleted back through the whole owned tail and into
            // paragraphs that are already REAL BLOCKS of a real note.
            // Removing those is a structural operation, which a capture
            // box has no business performing — so the box holds at the
            // boundary, and the editor one tap away is where a note's
            // structure changes. Nothing is lost in either direction.
            //
            // **The record below is load-bearing, not tidiness.** She
            // reached the boundary by emptying the owned tail, so the
            // store has to hear that the tail is now empty — a clamp that
            // only restored the text would leave the box showing one thing
            // and the note holding another, which is the silent divergence
            // this whole anchor exists to prevent. (Caught by its own pin.)
            write(frozenPrefix)
            recordTail()
            return
        }
        recordTail()
    }

    /// A programmatic write that must not re-enter the pipeline.
    private func write(_ value: String) {
        suppressChange = true
        text = value
        suppressChange = false
    }

    /// Hands the owned tail to the post's autosave coordinator — the
    /// ordinary road every note's text takes (A5-3: "autosaves like any
    /// note").
    private func recordTail() {
        guard let variantID, let autosave else { return }
        let tail = String(text.dropFirst(frozenPrefix.count))
        let delta = MobileQuickNoteModel.charDelta(from: lastRecordedTail, to: tail)
        lastRecordedTail = tail
        autosave.record(variantID: variantID, text: tail, charDelta: delta)
        saveState = .saving
    }

    // MARK: - The mint clock (A5-3)

    private func armMintClock() {
        guard clockTask == nil, postID == nil else { return }
        clockTask = Task { [weak self, mintDelay, sleep] in
            guard (try? await sleep(mintDelay)) != nil else { return }
            guard !Task.isCancelled else { return }
            await self?.mintNow()
        }
    }

    private func cancelMintClock() {
        clockTask?.cancel()
        clockTask = nil
    }

    // MARK: - The mint

    /// Mints the note if it does not exist yet, joining an in-flight mint
    /// rather than starting a second one. Returns the note's id.
    ///
    /// **This is the load-bearing half of her requirement.** The clock
    /// fires it a second in; the four early occasions fire it the instant
    /// she leaves, so *"if the user just closes the app, their note should
    /// still be saved"* is true rather than true-after-a-second.
    @discardableResult
    func mintNow() async -> String? {
        if let postID { return postID }
        if let mintTask { return await mintTask.value }
        guard let session, mints else { return nil }
        cancelMintClock()
        let snapshot = text
        let undoLabel = MobileQuickNoteCopy.undoLabel
        saveState = .saving
        let task = Task<String?, Never> { [weak self] in
            do {
                let result = try await session.runner.run { ops in
                    // A5-2: `importPost`, not `newBlock` — the paste that
                    // arrived before the mint segments correctly for free.
                    try ops.importPost(title: nil, text: snapshot, undoLabel: undoLabel)
                }
                return await self?.adopt(result, mintedFrom: snapshot, session: session)
            } catch {
                self?.lastError = MobileQuickNoteCopy.refusal(error)
                self?.saveState = .typing
                return nil
            }
        }
        mintTask = task
        let minted = await task.value
        mintTask = nil
        return minted
    }

    /// Takes ownership of the minted note: which variant the box now
    /// edits, what sits frozen ahead of it, and the settle wiring the
    /// indicator reads.
    private func adopt(
        _ result: Operations.ImportResult, mintedFrom snapshot: String, session: AppSession
    ) async -> String? {
        let containerID = result.container.id
        let blocks = (try? await session.database.read { db in
            try Queries.renderPost(db, containerID: containerID)
        }) ?? []
        guard let owned = blocks.last, let ownedVariant = owned.variantID else {
            // Unreachable through `importPost` (it mints at least one block
            // or throws), but a box that cannot name its variant must not
            // pretend to be saving into one.
            lastError = MobileQuickNoteCopy.refusal(OperationError.emptyImport)
            saveState = .typing
            return nil
        }

        postID = containerID
        variantID = ownedVariant
        frozenPrefix = MobileQuickNoteModel.frozenPrefix(
            of: snapshot, ownedText: owned.text ?? "", blockCount: blocks.count)
        lastRecordedTail = String(snapshot.dropFirst(frozenPrefix.count))

        let coordinator = session.autosave(
            forPost: containerID, debounce: autosaveDebounce,
            sleep: autosaveSleep ?? { try await Task.sleep(for: $0) })
        autosave = coordinator
        settleToken = coordinator.observe(
            onError: { [weak self] error in
                self?.lastError = MobileQuickNoteCopy.refusal(error)
            },
            onSettled: { [weak self] in self?.settled() })

        saveState = .saved
        // Keystrokes that landed while the mint was in flight: the store
        // holds the snapshot, the box holds more, so hand the difference
        // to the coordinator immediately.
        if text != snapshot { applyOwnedChange() }
        return containerID
    }

    /// What the box does NOT own, computed from the mint's own result.
    ///
    /// One block (the ordinary capture, and every newline-free one) ⇒
    /// nothing is frozen and the box owns the whole text exactly. Several
    /// blocks (a pre-mint paste) ⇒ the owned block's stored text is a
    /// contiguous piece of what was minted, so its LAST occurrence marks
    /// where the box's editable tail begins. Segmentation trims each
    /// piece's edges, so the anchor is searched rather than arithmetic'd
    /// off the end.
    nonisolated static func frozenPrefix(
        of minted: String, ownedText: String, blockCount: Int
    ) -> String {
        guard blockCount > 1, !ownedText.isEmpty else { return "" }
        guard let anchor = minted.range(of: ownedText, options: .backwards) else { return "" }
        return String(minted[..<anchor.lowerBound])
    }

    private func settled() {
        guard let autosave else { return }
        // The survey's honesty trap: a refused entry goes BACK into
        // `pending` and keeps `isDirty` true, so the indicator must read
        // the same source rather than a "we called flush" flag.
        saveState = autosave.isDirty ? .typing : .saved
        if !autosave.isDirty { lastError = nil }
    }

    // MARK: - The hand-offs

    /// ⏎ and the open door (A5-1): file the note, then ask the shell to
    /// open it. The box clears, so one capture opens one note.
    func open() {
        Task { [weak self] in
            guard let self else { return }
            if let id = await self.file() { self.pendingOpen = id }
        }
    }

    /// The shell takes the request exactly once.
    func takePendingOpen() -> String? {
        defer { pendingOpen = nil }
        return pendingOpen
    }

    /// A5-8 — LEAVING MINTS AND CLEARS (the Mac pad's closing-files-it
    /// grammar). A tab switch, a push onto a book or a note, and the app
    /// backgrounding all land here; combined with the mint clock this
    /// closes the un-minted loss window at EVERY exit, which is the whole
    /// point of her ruling.
    func fileOnLeaving() async {
        _ = await file()
    }

    /// The ONE body every hand-off shares. Order is A5-4's and it is
    /// binding: **mint first, then flush** — the flush covers text the
    /// mint already wrote, the mint covers the sub-mint window; reversed,
    /// the last word is lost.
    @discardableResult
    private func file() async -> String? {
        guard postID != nil || mints else {
            reset()
            return nil
        }
        cancelMintClock()
        let minted = await mintNow()
        guard let session else { return minted }
        // A5-4 option (c): the existing shared drain, no new registry and
        // NOT `MobileLivenessAuthority` (registering there would stand the
        // real editor down from the shelf — the wrong category).
        await session.flushEveryOpenPost()
        if let minted {
            // A5-5: the shared savepoint op at the hand-off — one line,
            // exactly what the Mac pad does at its filing. A captured
            // thought whose note no pane ever opened would otherwise carry
            // no history at all. (The phone's GENERAL on-leaving funnel
            // stays PL-11(e)/M6's; this is the box's own call.)
            await session.savepointOnLeaving(minted)
        }
        reset()
        if minted != nil { handOffCount += 1 }
        return minted
    }

    /// Back to an empty box, owning nothing.
    private func reset() {
        cancelMintClock()
        if let settleToken { autosave?.stopObserving(settleToken) }
        settleToken = nil
        autosave = nil
        variantID = nil
        postID = nil
        frozenPrefix = ""
        lastRecordedTail = ""
        lastError = nil
        saveState = .idle
        write("")
    }
}

// MARK: - The face

/// A5-6: a FIXED row directly under the shelf's path line, outside the
/// ScrollView — it never scrolls away, and it never displaces the Today
/// button or the starred section (her constraint: the shelf's feel must
/// not change around it). **No autofocus**, a deliberate divergence from
/// the Mac shelf's R102 behaviour: raising a keyboard on every phone
/// launch is hostile.
struct MobileQuickNoteBox: View {
    @Bindable var model: MobileQuickNoteModel
    let tokens: VoiceTokens
    /// Where a hand-off lands — the shelf's own open-for-writing road.
    let onOpen: (String) -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            field
            if let indicator = MobileQuickNoteCopy.indicator(model.saveState) {
                statusRow(indicator)
            }
            if let error = model.lastError {
                // `lineLimit` beside a growing chrome text is standing law
                // (P-8, the b6dae25 class).
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .onChange(of: model.handOffCount) { _, _ in
            // The box has let go; the keyboard should let go with it.
            focused = false
        }
        .onChange(of: model.pendingOpen) { _, _ in
            if let postID = model.takePendingOpen() { onOpen(postID) }
        }
    }

    private var field: some View {
        ZStack(alignment: .topLeading) {
            if model.text.isEmpty {
                HStack(spacing: 6) {
                    Text(tokens.chromeLabel(MobileQuickNoteCopy.hint))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                    if tokens.showsBlockCursor && !focused {
                        BlinkingCursorBlock(color: tokens.accent)
                    }
                }
                .allowsHitTesting(false)
            }
            TextField("", text: $model.text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .focused($focused)
                .lineLimit(1...5)
                .submitLabel(.return)
                .accessibilityLabel("Quick note")
                .accessibilityHint("Type a note here. It saves itself. Return opens it in the editor.")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }

    private func statusRow(_ indicator: String) -> some View {
        HStack(spacing: 12) {
            Text(tokens.chromeLabel(indicator))
                .font(tokens.small)
                .foregroundStyle(model.saveState == .saved ? tokens.accent : tokens.faint)
                .accessibilityLabel(
                    MobileQuickNoteCopy.spokenIndicator(model.saveState) ?? "")
            Spacer()
            // P-2, fire-and-DO: the door is rendered only where it can act
            // (there is text to open), and it performs the whole hand-off.
            Button {
                model.open()
            } label: {
                Text(tokens.chromeLabel(MobileQuickNoteCopy.openDoor))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(MobileQuickNoteCopy.openDoorSpoken)
        }
        .padding(.horizontal, 2)
    }
}
