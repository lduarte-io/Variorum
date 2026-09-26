# 18k — Runtime hygiene — AUTHOR HANDOFF (2026-09-25)

*Self-contained: a fresh session can answer your questions about 18k from this file plus the run record
(`notes/plans/phase-18k-runtime-hygiene.md`). If a question needs the orchestrator's session, the docs
are incomplete — fix the docs.*

## ✅ YOUR CHECKLIST (in order)

1. **Your backups (the one that matters).** Since 2026-09-04 your library's backups were shallower than
   they should be (details below). The fix is in the build installed at this closeout. **Open Settings ▸
   Data Safety and press Back Up Now once**, then check the "A second folder" row shows today's date
   (if you set one). The `variorum-backup-a1-…` files in that folder's `Variorum/Backups/` are
   early-September strays the app no longer sends or touches — keep or delete. Your planned clean-out
   (keep the newest dated `variorum-backup-2026-…` copy) is safe; press Back Up Now afterwards.
   Tonight's own safety copy is in `Backups/safety-copies/` (your R-18k-8) — keep it until you're happy
   with the new build.
2. **Ratify or overturn three PROVISIONALs** (each one line in `notes/QUESTIONS.md`):
   - **#146** — a phone that started SIGNED OUT seeds its own sample book, which would come back over
     your account's deletion at sign-in. Decided at your instruction: an UNTOUCHED local copy is retired
     at first sync when the account holds the book deleted; an EDITED one is never retired. Built at 18o.
   - **#147** — when the top of the page cuts a line below its letters (only descenders showing), the
     line you're reading is the NEXT one ("the baseline decides").
   - **#148** — the second folder's sentence when a run's own snapshot failed: *"This run made no
     snapshot to copy."*
3. **Next phase, at your word — you said likely 18l**, which now opens with your three evening reports
   and your harness ask (`notes/plans/post-13u-health-rounds.md`, KICKOFF 2, units U0 · U0b · U-VIS):
   the Index click that lands on the empty line, the clipped last line in the book view, the Write top
   padding that collapses when a newline is removed, and an opt-in visual regression harness. Your
   screenshots are committed in `notes/plans/18l-inputs/`. **18o** follows, with a fresh FABLE
   orchestrator (your R-18k-10).
4. **The install:** refreshed at this closeout — see "The install" below.

## What shipped (one line per unit)

| Unit | Result |
|---|---|
| C0 | Ledger housekeeping: 17t + 18o minted; rows re-owned; six review rows filed with owners |
| C1 | **The autosave registry leak FIXED** — 20 notes opened: coordinators 20 → 0, ⌘Q finalize 62 ms → 0.07 ms. On the Mac an entry leaves only through a LANDED leaving savepoint (no text-loss road; the over-release mutation pinned red) |
| C2 | The suspected inline-editor bug DISPROVED; the double realization bisected to an already-shipped fix (`f8610cb9`); the height write deferred anyway (warnings 84 → 4) |
| C3 | The review's warning theory DISMISSED AS HOLLOW by measurement — ALL SwiftUI "state during update" warnings are `PaneSurface`'s (18l's) |
| C4 | 12 DEBUG test-oracle types owner-keyed (two windows no longer cross-clear); production byte-identical |
| C5 | Canvas ⌘K Block History opens on the selected card · ⌘⇧M carries a take that arrived mid-typing · ⌥⌘Z/⇧⌥⌘Z can't double-fire past the confirm · backups single-flight · the phone's liveness race (already fixed) pinned |
| C6 | The five macOS-27 test deltas resolved — **one was a real 27 regression** (after a font/spacing change your place landed a line off), fixed in the jump primitive |
| C6b | Two more reading-position cases found by the walk and fixed (a top edge in a paragraph GAP; a jump landing ~a dozen paragraphs short after a re-font) — both pre-existing |
| C7 | **The backup listing sorted by NAME** — fixed (below) |
| C8 | A test-isolation leak 18k's own new tests introduced (a dropped test editor surviving in the runner's memory) — fixed test-only |
| Walks | Driven and captured on the dev-store build after you granted Ghostty Accessibility + Screen Recording (live, no restart) — C1/C2/C3/C5 PASS; C6's findings became C6b; W-3 became C7 |
| Ladder | **Fable, three rounds:** R1 0/0/0/3 NIT (one fixed — #148) · R2 0/0/0/0 · R3 (your R-18k-9/10: C8 + an audit of every orchestrator decision) 0/0/0/4 NIT, **the audit PASSED** |

## Your backups — what happened (C7)

The app picked "the newest backup" by FILE NAME. Safety copies sessions leave (`variorum-backup-a1-…`)
sort after the dated ones, so from 2026-09-04: the hourly check wrote a snapshot EVERY HOUR, and the
prune deleted real dated copies to keep the A1 ones. Verified in your real folder (names only): exactly
**11 dated copies, hourly, 2026-09-24 23:09 → 2026-09-25 09:09 UTC** — ~11 hours of history instead of
14 days; the pruned older copies cannot come back. **Nothing current is lost** (the library and sync were
never touched; the Sept 4/5/24 A1 snapshots survive). A second folder, if set, received the 2026-09-05
A1 snapshot every run since ~Sept 5 — its check said "ok". The fix admits only the app's own dated names
and hands the second folder the run's own file. From now on sessions write their safety copies into
`Backups/safety-copies/`, which the app never reads.

## The orchestrator seat (R-18k-10)

This run's orchestrator was **Opus 5.5**, not your usual Fable — noticed by you mid-run. Verified by
transcript: all three review rounds ran `claude-fable-5`; the implementers ran Opus as intended. Your
remedy ran: round 3 was Fable and audited every orchestrator adjudication — it PASSED. 18o gets a
fresh Fable orchestrator.

## Your rulings at this run (verbatim in the record's KICKOFF SITTING)

R-18k-1 17e split (18k C5 + 18o) · R-18k-2 rows 56/57 → 17t riding 18o · R-18k-3 refresh at your quit ·
R-18k-4 #136(b) leave for now · R-18k-5 #138(f) honour the tombstone at launch · R-18k-6 a book-edited
note's savepoint when you move to another note · R-18k-7 the TCC grants · R-18k-8 A1 copies into a
subfolder · R-18k-9 a cold review of C8 before the refresh · R-18k-10 the orchestrator seat's remedy.

## Test counts (the finals)

Core **1723/180 ALL PASSED** (+1 = the post-13y auto-entitlement act's pin, not 18k's) · iOS **BUILD
SUCCEEDED** · mobile **643/109 with exactly the 4 known issues** (+1 = C5's P26 pin) · full Mac
**3168/522** — the five macOS-27 deltas and C8's red GONE; the only reds three pointer-injection
suites that fail when someone is using the machine during the run (green 3/3 with it idle; not 18k's).

## The install

**DONE 2026-09-26 05:09 UTC.** Safety copy `Backups/safety-copies/18k-refresh-20260926T050909Z` (6
files, byte-verified) · Release from `11e7614f` · binary `9e15f8bf…` → **`79c7688b…`** · codesign OK ·
both keychain access groups present. **It's safe to open Variorum now.**

## Handed forward (every item owned)

**18l:** your three evening reports + the visual harness (U0 · U0b · U-VIS); `PaneSurface` is ALL of the
warning count (C3). **18o:** 17e's remainder, 17t, R-18k-5/6, #146, the Open strip's tenth-row trap, the
⌥⌘⇧M ceremony branch's stale read, the future-stamped backup. **12:** the ~85-pt inline restore
residual, the DEBUG oracles' parallel-suites axis + `EditorTypography`, the `SurfaceComposition` dump
reach, O-2's ring, a canvas grab glyph (W-1), the dropped-test-editor harness class (C8), T2/T3/warming.
**mobile:** the phone's autosave leak, the popped-screen liveness residue.

**MOBILE PARITY:** the phone owes its own autosave-registry release (the Mac's C1 shape — KnownIssues,
the mobile row). The ⌥⌘Z refusal sentence now lives in `StructuralUndoCopy`, which the phone forwards
byte-identically (nothing owed). Everything else is Mac-app/DEBUG — nothing else mobile-visible.
