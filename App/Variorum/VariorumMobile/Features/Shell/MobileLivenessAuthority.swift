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

    /// Every registered, still-alive editor — the background flush's own
    /// bookkeeping (MAJOR 1: one mechanism, never a parallel slot).
    var registered: [MobileEditorViewModel] {
        entries.compactMap(\.editor)
    }

    /// A screen's arrival: pushes only happen on the VISIBLE tab, so the
    /// newcomer takes liveness immediately (no refresh — it holds nothing
    /// yet; its arrival routine's `loadOnce` is the fresh read, and it
    /// runs AFTER this returns, i.e. after the flush below).
    func register(_ editor: MobileEditorViewModel, tab: MobileTab) async {
        entries.removeAll { $0.editor == nil || $0.editor === editor }
        entries.append(Entry(editor: editor, tab: tab))
        await takeLiveness(editor, refresh: false)
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
    func tabDidBecomeVisible(_ tab: MobileTab) async {
        entries.removeAll { $0.editor == nil }
        if let heir = entries.last(where: { $0.tab == tab })?.editor {
            await takeLiveness(heir, refresh: true)
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
    func takeLiveness(_ editor: MobileEditorViewModel, refresh: Bool) async {
        entries.removeAll { $0.editor == nil }
        for entry in entries where entry.editor !== editor {
            entry.editor?.standDown()
        }
        live = editor
        await editor.autosave.flushNow()
        if refresh {
            await editor.refreshTakesFromStore()
        }
        editor.noteLivenessGranted()
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
