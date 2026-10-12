# 13n-c — the Opus UX-reviewer walk (ledger row 13, leg 2)

**Walker:** Opus 5.5 (`claude-opus-5-5`), a fresh session, 2026-10-11 evening. Worktree `~/dev/variorum-vx-165`, branch
`vx-165-13n-c`, from tip `2e35aebb`. The author's named refresh condition: "specifically had an opus UX reviewer walk it
to flag problematic flows, hard to find buttons, weird spacing or looks, etc."

**Mandate:** walk the real app on screen (the dev-store Debug build only) and flag what reads wrong to fresh eyes. I change
no code. Dispositions are the orchestrator's: I flag, I do not fix. The inputs are the phase plan's rulings, the U1–U6
walk subsections, the HELD-WALKS RECORD's taste list T-1…T-17, and the drawn states in `vx-156-grant-ux-mockups.html`.

**Captures:** `notes/plans/13n-c-screens/walk-ux/` (gitignored, `.gitignore:66`).

## LIVE STATUS

| # | Leg | Status |
|---|---|---|
| 0 | Preflight: the plan's rulings, units, walk records and taste list; WalkKit; the scale-fixture road | DONE (this commit) |
| 1 | Build the tip's Debug app; stage claim; A1 prestage copy + scale seed | DONE — `** BUILD SUCCEEDED **` into `App/Variorum/DerivedData/vx165-ux` (an APFS clone of `vx165-u6`, incremental); stage `ux-walk` claimed (90 min); no instance before launch; `stage.sh notes=30,long=1,books=20,shelves=3` → **the restore source `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261012T012517Z`** (sizes 8,671,232 · 32,768 · 803,432 — the U6 record's); the wing part (`wing=1`) is deferred to a relaunch so the ONE-WING state could be walked first |
| 2 | Zero-client gating (no share face renders) | WALKED — the four approved clients revoked from their rows (claude-code, u3/u2/u1-walk); the Bookcase icon left "o ladrão de raios", the book row menu carries no Share door (`09-crop.png`), the Edit menu no Share item; claude-code re-approved through Approve… (the sheet walked — `10-approve-sheet-win.png`, `13-…`, `14-…`) |
| 3 | The grant sheet on the scaled seed | NOT-STARTED |
| 4 | Settings ▸ MCP (Shared with AI · Waiting · Activity · the boundary line · the setup menu) | NOT-STARTED |
| 5 | The share doors (Library row · bulk bar · Bookcase book menu · Book Settings · ⌥⌘A) | NOT-STARTED |
| 6 | Icons (the shared icon · pending mark · in-note indicator · popovers) | NOT-STARTED |
| 7 | ⌘L, the masthead cycle, the ▾ menu, the one-wing note, ⌥⌘, | NOT-STARTED |
| 8 | Receipts (share/change/revoke · wing-move lines · Open › · ⌥⌘O) | NOT-STARTED |
| 9 | The guide's "AI & the MCP door" chapter, all seven lessons | NOT-STARTED |
| 10 | T-15: the "ask was let go" line pressed from Settings | NOT-STARTED |
| 11 | Terminal voice + dark | NOT-STARTED |
| 12 | Restore: dev store, voice, appearance, stage released, no instance | NOT-STARTED |

## FINDINGS (ranked by how much they would bother a real user)

(Interim, written repo-first as the walk runs; the final ranking replaces this list at the end.)

- **[interim, CONFIRMED twice — wing ask and note ask] An answered ask's sheet RE-PRESENTS ITSELF when the same client asks the same thing again** (second proof: `67-crop.png` — the Fixture 0006 note ask, answered Once from the in-note mark, popped up unpressed on the BOOKCASE when re-raised) — captures
  `25-crop.png` (her press on the masthead's wing mark), `28b-clean-before-crop.png` (nothing open), `28c-clean-after-ask-crop.png`
  (the sheet up with no press). See the ranked list for the trace.
- **[interim] The one-wing note is never shown** — `01-cmdL-onewing-win.png`, `02-palette-switchwing-onewing.png`, `03-view-menu-crop.png`.
- **[interim] A client row's Revoke denies the client and drops every grant in one press, no confirm** — `05-mcp-pane-top-study.png`.
- **[interim] Shared with AI lists one book five times; "3 shared places" counts grants** — `06-mcp-pane-u1.png`, `06-mcp-pane-u2.png`.
- **[interim] The grant sheet's confirm does not look like a button** — `10-approve-sheet-win.png`, `13-sheet-sherlock17-picked.png`.
- **[interim] The in-note popover hangs off the window; the app behind tints it** — `35-crop2.png`.

## CLEAN-WALK LIST

(Filled as the walk runs.)

## NOT WALKABLE

(Filled as the walk runs.)

## RESTORE EVIDENCE

(Filled at the end.)
