//
//  MobileLivenessAuthority.swift
//  VariorumMobile
//
//  Mobile S3 ladder, round-1 BLOCKER + MAJOR 1 (one mechanism, per the
//  adjudication): **the phone's liveness authority** — the
//  `PaneTextAuthority` analog for the shell's editors, a testable sibling
//  brain per flag 3's directive (shell wiring carries no policy of its
//  own).
//
//  P-3's phone reading, made mechanical:
//
//  · **Exactly ONE live editor anywhere.** Both tab stacks stay alive by
//    design (opacity-switched — each keeps its navigation state), so two
//    `MobileWriteScreen`s can exist at once, and nothing about visibility
//    ever fires `onDisappear`. Liveness is therefore an EXPLICIT act
//    through this authority: the hidden stack's editor STANDS DOWN
//    (read-tier: focus resigned, editability off, its gate refusing), and
//    only `takeLiveness` grants the pen back.
//
//  · **Taking liveness lands the store truth first.** Editors of one post
//    share the session's ONE per-post `AutosaveCoordinator` (the N3
//    boundary, hoisted cross-platform with this fix), so a stood-down
//    sibling's typed-but-unflushed text lives in the taker's own
//    coordinator — `takeLiveness` flushes it and (on re-entry) re-reads
//    fresh BEFORE granting the pen. Without this, the round-1 BLOCKER's
//    loss: type in A → switch tabs inside the debounce → type in B over a
//    stale photograph → B's flush permanently clobbers A's typing.
//
//  · **The background flush covers EVERY registered editor** (MAJOR 1,
//    folded in): the registration set below IS the flush target list —
//    never a parallel single slot, which covered only the most recently
//    registered editor and nothing at all after a pop.
//
//  · **The voice flip reaches every registered editor** (MINOR 2): a
//    stood-down surface restyles too, so no mixed-voice storage survives
//    a Settings flip.
//
//  · **THE LAST REQUESTED HANDOFF WINS, NEVER THE LAST COMPLETED ONE**
//    (the architectural review's MAJOR 2). Every grant below suspends —
//    on a flush, and on a fresh read — while the shell's `tab` state is
//    assigned SYNCHRONOUSLY at the tap. So two taps spawned two
//    independent tasks whose bodies interleaved across four suspension
//    points of database work, each acting on the tab it captured at
//    spawn, with nothing capturing an order. Whichever finished LAST
//    installed the liveness that stood — and the two wrong end states
//    were exactly the two this authority exists to forbid: the visible
//    editor stood down (she taps into her note and cannot type), or a
//    HIDDEN editor holding the pen. A monotonic `handoff` token closes
//    it: a request mints the newest token, and any grant that resumes to
//    find a newer one abandons itself instead of installing state the
//    user has already asked to replace. Checked at entry AND after every
//    suspension, because both windows are real.
//

import Foundation

@MainActor
final class MobileLivenessAuthority {
    private struct Entry {
        weak var editor: MobileEditorViewModel?
        let tab: MobileTab
    }

    /// Registration order preserved (the last registered editor on a tab
    /// is its top-most — the liveness heir on tab re-entry).
    private var entries: [Entry] = []
    /// The one live editor (weak — the screen owns its model).
    private(set) weak var live: MobileEditorViewModel?

    /// The monotonic handoff token (MAJOR 2). Bumped by every request for
    /// a grant — a tab tap, a registration — so an in-flight grant can ask
    /// after each suspension whether it is still the one being asked for.
    private var handoffGeneration = 0

    /// Mints the newest token. **Called SYNCHRONOUSLY at the gesture**, in
    /// the same turn as the `tab` assignment it belongs to, so the order of
    /// REQUESTS is fixed before any task runs; the token is then carried
    /// into the async grant.
    @discardableResult
    func beginHandoff() -> Int {
        handoffGeneration += 1
        return handoffGeneration
    }

    /// True while `token` is still the newest request. A grant that finds
    /// this false has been superseded and must install nothing.
    private func isCurrent(_ token: Int) -> Bool { token == handoffGeneration }

    /// Every registered, still-alive editor — the background flush's own
    /// bookkeeping (MAJOR 1: one mechanism, never a parallel slot).
    var registered: [MobileEditorViewModel] {
        entries.compactMap(\.editor)
    }

    /// The notes those editors have open, DEDUPED (round 2 batch 4 — PR7).
    /// Two tab stacks can hold the same note, and a leaving must savepoint
    /// it once: `closeAutoCommit` is idempotent by its own dedupe rule, but
    /// asking twice would still be two transactions for one leaving.
    var registeredPostIDs: [String] {
        var seen = Set<String>()
        return registered.compactMap { seen.insert($0.postID).inserted ? $0.postID : nil }
    }

    /// A screen's arrival: pushes only happen on the VISIBLE tab, so the
    /// newcomer takes liveness immediately (no refresh — it holds nothing
    /// yet; its arrival routine's `loadOnce` is the fresh read, and it
    /// runs AFTER this returns, i.e. after the flush below).
    func register(_ editor: MobileEditorViewModel, tab: MobileTab) async {
        entries.removeAll { $0.editor == nil || $0.editor === editor }
        entries.append(Entry(editor: editor, tab: tab))
        // A push IS a request for the pen, so it mints its own token — a
        // tab switch requested while this grant is mid-flush supersedes it,
        // and this grant supersedes an older switch still in flight.
        await takeLiveness(editor, refresh: false, handoff: beginHandoff())
    }

    /// A screen's teardown (pop). The revealed screen is a book list or a
    /// tab root — no heir is crowned here; the next registration or tab
    /// switch grants liveness explicitly.
    func deregister(_ editor: MobileEditorViewModel) {
        entries.removeAll { $0.editor == nil || $0.editor === editor }
        if live === editor { live = nil }
    }

    /// The shell's tab switch: the entering tab's top editor takes
    /// liveness WITH a refresh (its surface may be a stale photograph of
    /// work done on the other tab); a tab with no editor leaves zero live
    /// editors (at most one is the law, not exactly one).
    ///
    /// `handoff` is the token minted at the tap (`beginHandoff`). Passing
    /// nil mints one here, which is right for a caller with nothing to race
    /// — a sequential test, or a single switch — and wrong for the shell,
    /// whose taps must be ordered before their tasks start.
    func tabDidBecomeVisible(_ tab: MobileTab, handoff: Int? = nil) async {
        let token = handoff ?? beginHandoff()
        // AT ENTRY, before anything is touched: a task that resumes after a
        // newer switch has already landed must not stand anyone down.
        guard isCurrent(token) else { return }
        entries.removeAll { $0.editor == nil }
        if let heir = entries.last(where: { $0.tab == tab })?.editor {
            await takeLiveness(heir, refresh: true, handoff: token)
        } else {
            for entry in entries { entry.editor?.standDown() }
            live = nil
        }
    }

    /// THE explicit act (P-3's letter). In order: every other editor
    /// stands down; the taker's (possibly shared) pending buffer lands in
    /// the store — a stood-down sibling's typing included, because same-
    /// post editors share the ONE per-post coordinator; on re-entry the
    /// taker re-reads fresh through its one projection door; then the pen.
    func takeLiveness(
        _ editor: MobileEditorViewModel, refresh: Bool, handoff: Int? = nil
    ) async {
        let token = handoff ?? beginHandoff()
        guard isCurrent(token) else { return }
        entries.removeAll { $0.editor == nil }
        for entry in entries where entry.editor !== editor {
            entry.editor?.standDown()
        }
        // **NO PEN OVER A TOMBSTONE** (4.5c-phone item 2). Both stacks stay
        // alive, so a note deleted from the LIBRARY tab leaves the other
        // stack's editor standing on a tombstone — and popping the deleting
        // stack (the fix §49 filed) reaches nothing, because the stale
        // surface is not in it. Liveness is where it CAN be reached: this is
        // the one act that hands a surface the pen.
        //
        // **THE CHEAP ARM RE-CONFIRMS; IT NEVER REFUSES ON ITS OWN**
        // (round-1 MAJOR 1). `noteIsGone` is what the last header DELIVERY
        // said, and this class's own justification for the authoritative
        // read below is that a delivery's latency is real — an argument that
        // is SYMMETRIC. Refusing on the stale value short-circuited the very
        // read that would have corrected it, so a note Put back from the
        // Trash (a Library-tab act, i.e. one tab tap away from her stale
        // shelf surface) could be refused, and could not heal inside that
        // visit: `adoptHeader`'s restore branch needs `isLive`, which the
        // refusal has just made false.
        //
        // So the arm survives for what it was kept for — a note the store
        // AGREES is gone skips the flush and the takes-refresh entirely —
        // and pays one indexed header read to earn the right to refuse.
        if editor.noteIsGone {
            let confirmedLive = await editor.confirmNoteStillLive()
            guard isCurrent(token) else { return }
            guard confirmedLive else {
                refuseOverTombstone(editor)
                return
            }
        }
        live = editor
        // The flush is what makes the window WIDE — it is real database
        // work, and the review's traced race lives inside it.
        await editor.autosave.flushNow()
        guard isCurrent(token) else { return }
        // **THE AUTHORITATIVE ANSWER, AND IT COMES BEFORE THE REFRESH**
        // (round-1 MAJOR 2). Asked after the suspensions because a delivery
        // has latency a tab tap can land inside; asked BEFORE
        // `refreshTakesFromStore` because that read hands a tombstoned note's
        // EMPTY projection to the one projection door, which renders it —
        // her words leave the screen before anything has established there is
        // nothing left to show. The token is re-checked after it for the same
        // reason every other suspension here is (MAJOR 2's discipline: a
        // request that has been superseded installs nothing, whatever it
        // learned).
        let stillLive = await editor.confirmNoteStillLive()
        guard isCurrent(token) else { return }
        guard stillLive else {
            refuseOverTombstone(editor)
            return
        }
        if refresh {
            await editor.refreshTakesFromStore()
            guard isCurrent(token) else { return }
            // **THE BELT TAKES THE SAME MEDICINE AS THE ENTRY ARM** (round-2
            // MINOR R2-2). The refresh is the one suspension standing between
            // the store's answer and the grant, so a delivery landing inside
            // it must still be able to stop the pen. Its first shape refused
            // on the delivery alone, argued as *"a reading taken here cannot
            // be stale"* — but LANDED after is not TAKEN after, and the gap
            // between them is this file's own load-bearing premise
            // (`confirmNoteStillLive`: a delivery's latency is real, and the
            // argument is symmetric). A nil observed BEFORE the read above can
            // land after it, and the belt then stood a LIVE note down and told
            // her it had been deleted.
            //
            // So the belt earns its refusal the same way the arm above does:
            // one indexed header read, paid only when the reading says gone.
            // **Every refusal on this road is now store-confirmed** — no
            // surface is stood down on a delivery that was already in the air.
            if editor.noteIsGone {
                let confirmedLive = await editor.confirmNoteStillLive()
                guard isCurrent(token) else { return }
                guard confirmedLive else {
                    refuseOverTombstone(editor)
                    return
                }
            }
        }
        // **AND THE REFUSAL IS WITHDRAWN WHERE IT STOPS BEING TRUE**
        // (round-2 MINOR R2-1). `statusMessage` is sticky by design — it is
        // cleared only by an explicit `report(nil)`, and none of the three
        // sites that do so is on this road — so the sentence this authority
        // speaks at a refusal outlived the note it was about: refuse → Put
        // back from the Trash → tap back, and the arm above heals everything
        // (the pen, her words, her keystrokes) while the masthead still reads
        // *"This note was deleted…"*. A grant is the exact moment that claim
        // stops being true, so it is where it is taken back.
        //
        // **NARROW ON PURPOSE — it clears this ONE sentence, never a receipt.**
        // Her commonest deletion road leaves *"Moved to the Trash…"* standing
        // on the editor's own status line, and a grant that cleared whatever
        // it found would eat it. Matching on the sentence also means the ONE
        // rule covers the gate's producer as well as this file's: both speak
        // `deletedNoteRefusal`, and a note that is live again wears neither.
        if editor.statusMessage == MobileEditorViewModel.deletedNoteRefusal {
            editor.report(nil)
        }
        // The pen is granted ONLY by a handoff still being asked for. The
        // superseding grant is what sets `live` and hands the pen on; an
        // abandoned one leaves the store work it already did (a flush is
        // never wasted) and installs nothing.
        editor.noteLivenessGranted()
    }

    /// Nobody holds the pen, **and the surface that asked is told why**
    /// (round-1 MAJOR 2). *At most* one live editor is the law (never exactly
    /// one), so a tab whose top surface stands on a tombstone is a legal end
    /// state — but a legal end state is not a self-explaining one: the
    /// refusal drops the keyboard, and `shouldChangeText`'s sentence is
    /// reachable only for an EDITABLE text view, so the surface she is
    /// looking at would say nothing at all. The sentence goes through the
    /// status road the write view already renders.
    ///
    /// It stands EVERYONE down, the asker included — `takeLiveness`'s own
    /// loop deliberately skips the taker, so this is what reaches it.
    private func refuseOverTombstone(_ editor: MobileEditorViewModel) {
        standDownEveryone()
        editor.report(MobileEditorViewModel.deletedNoteRefusal)
    }

    /// Nobody holds the pen — a legal end state, not an error.
    private func standDownEveryone() {
        for entry in entries { entry.editor?.standDown() }
        live = nil
    }

    /// The app-level background transition's targets (MAJOR 1): EVERY
    /// registered editor's pending text lands — `finish()` is the S1
    /// teardown backstop (mints the open tail, attaches trailing runs,
    /// flushes), the right shape for a possible suspension.
    func flushAll() async {
        for editor in registered {
            await editor.finish()
        }
    }

    /// LK2's flip reaches every registered surface (MINOR 2): a
    /// stood-down editor restyles too — O(open note) each, at most one
    /// editor per tab, spent only at a deliberate Settings flip.
    func applyVoiceChangeEverywhere() {
        for editor in registered {
            editor.applyVoiceChange()
        }
    }
}
