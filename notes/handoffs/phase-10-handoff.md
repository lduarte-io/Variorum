# Phase 10 handoff — Readings & first views (closed 2026-07-12)

*Self-contained checkpoint document (the standing rule: if a question about
this phase can only be answered by the original session, the docs have
failed — everything an author walk needs is here or linked).*

## Your checklist (in order)

1. **Relaunch `/Applications/Variorum.app`.** A fresh Release build was
   installed at closeout (if your running copy blocked the copy step, the
   handoff note at the bottom says where the built product waits). What you
   will see immediately: the sectioned sidebar (Views / Journal / Library /
   Readings / Tags / Pool), your journal entries as DATED rows with a
   "Today's Entry" button, paragraph spacing in the editor (the ruling's
   presentation half), and "Show Blocks" stripes that finally sit ON their
   text.
2. **Walk QUESTIONS #17 (the phase's three PROVISIONALs, bundled)** —
   ratify or redirect:
   (a) clicking a fan badge on an unfocused post FOCUSES it first, then
   opens the takes panel; (b) timeline/folder rows open-in-editor only (no
   previews until 13); (c) the pool lives in the sidebar. Companion
   build-time calls recorded with it: ⌥-drag carries a scrap's whole fan;
   "Open Pool" edits the pool in the ordinary editor (that's how scraps are
   typed until 11's fuller pool); the Journal section + Today's Entry as the
   dated home's minimal shape.
3. **The app-sections design conversation you asked for at the 9c sitting.**
   The Journal section satisfies "journal entries have an obvious dated
   home" minimally (dated rows, newest first, create-or-open Today). The
   fuller question — what the app's final sections ARE — is deliberately
   left for this walk. Bring opinions; nothing is locked.
4. **Try the spacing ruling in anger** (it's your ruling — QUESTIONS #12,
   2026-07-12): paste multi-paragraph text with blank lines (they persist,
   byte-for-byte); type paragraph–Enter–Enter–pause–paragraph (the gap
   persists — even across the pause, even across quit); export/bridge
   projections carry the spacing. Two consequences you acknowledged: the
   Fragments side shows spaced days spaced; the iOS trailing-blank-lines bug
   (Phase 15) must later distinguish accidental newlines from stored spacing.
5. **Note the re-owned KnownIssues row:** "offline reads as SyncError" was
   assigned to Phase 10 at the 9c sitting — the day AFTER this phase's plan
   was authored — so it never entered scope; it moved to Phase 11 (Step A0,
   first thing). Pull it earlier if the label annoys you before then.
6. **Phase 11 kickoff, when you're ready:** it BEGINS with the
   author-attended HTML mockup spike you asked for (fan-out appearances +
   the side-by-side view — you choose before anything is built), and it
   carries the two ask-you-live items (#10 W-ceremony, #11 fanned
   cross-block edits) as hard gates. Plan:
   `notes/plans/phase-11-remaining-views.md`.

## What shipped (why it's shaped this way)

- **The read tier** (`Features/ReadTier/`): unfocused posts render as
  non-editable TK2 text — the Step 0 measurement chose this over SwiftUI
  Text because only it DELIVERS your ratified per-post cross-block
  selection AND fan badges (memo + numbers in the plan's closeout;
  0.35 ms/view median). Exactly ONE live editor ever exists; clicking a
  read post migrates it there, caret landing where you clicked.
- **The continuous book view**: a reading's posts in one scroll, virtualized
  (off-viewport posts never instantiate — counted, not hoped); section
  headers where the grouping tag changes; a visible marker if a reading
  exceeds the 300-post window (never a silent cut).
- **The shell**: Journal (your dated home), Library, Readings (create/
  rename/delete, curated + smart with the filter editor, membership
  add/remove/reorder), Tags (taxonomy management + per-post assignment),
  Timeline (strict-stamp lenses + All posts), Pool (drag a scrap into any
  editor — the drop is exactly the `poolDragCopy` operation; ⌥ carries the
  fan), Archived & Deleted (recovery surfaces — unarchive/restore).
- **Lifecycle faces**: Seal/Unseal and the entry-date picker live in the
  editor's bottom bar; Archive/Delete on every post row's context menu.
  Sealing runs the full "insure what you freeze" contract (flush, mint the
  open tail, then lock).
- **Your spacing ruling, both halves**: mechanism (a) exactly as demoed —
  k newlines between pieces store k−1 trailing newlines on the preceding
  block; typing completes a paragraph when the NEXT one begins, so typed
  gaps persist identically to pasted ones; export joins conditionally (the
  merge-join precedent) and the Fragments bridge projects the same join
  (one join brain — the pushed body always equals the export). Presentation
  half: a uniform per-PARAGRAPH gap, stored nowhere — per-paragraph rather
  than per-seam because §12 keeps block boundaries invisible at rest (a
  seam-only gap would reveal them). Recorded as AppSpec §14's 2026-07-12
  delta.
- **The tint fix, traced first**: every stripe sat exactly 8 px above its
  text (TK2 frames are container-relative; the overlays live in the view —
  the inset was never applied). Fixed at one pure mapping; badges had the
  same latent offset in both tiers, fixed with it. Your stable-color rules
  untouched.

## Counts and verification

**Final: core 562/62 · Mac 311/55 · mobile 11/4** (from 549/62 · 254/45 ·
11/4). Step 10 ran the multi-post benchmarks (book-view realization flat,
16 ms at 20 and 200 posts), the sync convergence spot suite at multi-post
scale (two clients, held observations delivering throughout, spaced content
on the wire — byte-identical stores), and the TEXTKIT2 §5 ritual (canary
silent everywhere incl. every read-tier instance; macOS 26.4.1 unchanged
since the Phase 6 spike, so no re-run owed).

## Review ladder, in brief (full dispositions in the plan's closeout)

- **Round 1 (2 MAJOR / 4 MINOR / 4 NIT — all agreed, all fixed, bug-class
  fixes red-verified by revert):** the seal button could strand an open
  tail (now runs the full teardown contract first); the idle/teardown mint
  collapsed typed blank-line gaps in the normal writing rhythm — fixed with
  the `.idle` mint kind + the leading-run attachment, so a typed gap is
  durable the moment it exists; held observations bounded (folder/recovery);
  a read-tier remake could render blank (fixed); inline editor overlays no
  longer go stale on scroll; the questioned per-keystroke layout cost was
  MEASURED (0.043 ms warm — a non-issue, now pinned).
- **Round 2 (1 MINOR / 5 NIT — zero new HIGH; the ladder closed):** the
  quit door could strand the last-typed gap's store write inside a 500 ms
  debounce (fixed inside the awaited quit task; pinned red-on-current);
  truncation markers gained exact-window probes and folder/recovery parity;
  two honest doc fixes; two record-only corners (a gap typed after a LOCKED
  last block collapses at idle — the only lock-respecting outcome; a
  ms-window seal-vs-cleanup race that self-surfaces and loses nothing).

## Where everything is

- Phase plan + full closeout (memo, per-step records, the ruling, both
  rounds' dispositions, residuals): `notes/plans/phase-10-readings-and-first-views.md`
- Your ruling's canonical record: AppSpec §14, 2026-07-12 delta;
  QUESTIONS #12 (answered) and #17 (to ratify).
- KnownIssues: echo/tint/paste rows resolved; offline-label row → 11;
  bounded-windows row → 12; the iOS row's stored-spacing note → 15.
- Phase 11 plan: `notes/plans/phase-11-remaining-views.md` (starts with
  your mockup spike; carries #10/#11 as ask-you-live gates).

## Install note

**Your Variorum.app was RUNNING at closeout (PID 40430), so the bundle was
deliberately NOT swapped under your live session** (replacing a running
app's bundle can destabilize it — and nothing force-quits your app, ever).
The fresh Release build succeeded and waits at:
`~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/Build/Products/Release/Variorum.app`
Checklist step 1 therefore is: **quit Variorum, then run**
`cp -R ~/Library/Developer/Xcode/DerivedData/Variorum-*/Build/Products/Release/Variorum.app /Applications/`
**and relaunch** (or ask any session to do the copy once your app is
closed).
