//
//  CaptureRouter.swift
//  VariorumMobile
//
//  Parent-composition routing for the active capture editor — the mobile
//  twin of the Mac's EditorRouter. Exists so the app-level background
//  transition can flush the editor's pending autosave BEFORE the sync
//  round runs (review round 2: `onDisappear` does not fire when the whole
//  app backgrounds, so up to one debounce of typed text sat unpersisted
//  when the scene suspended — a background kill would lose it silently;
//  the Mac analog, quit, deliberately flushes per Phase 7).
//

import Observation

@MainActor
@Observable
final class CaptureRouter {
    weak var activeEditor: EntryEditorViewModel?
}

/// The background transition, extracted for tests: the active editor's
/// pending text lands in the STORE first, then one sync round pushes it —
/// ordering matters, or the round would carry the pre-flush text and the
/// fresh write would wait for the next foreground.
@MainActor
func performBackgroundFlush(editor: EntryEditorViewModel?, sync: SyncSession?) async {
    await editor?.finish()
    await sync?.flush()
}
