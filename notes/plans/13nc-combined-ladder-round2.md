# 13n-c combined ladder — round 2 (cold review, fable-reviewer, 2026-10-11)

**Reviewer model: Fable 5 (`claude-fable-5`), xhigh — a FRESH reviewer (not round 1's).** Prompt:
`notes/REVIEW_PROMPT.md` verbatim (PHASE = 13n-c) plus a mechanics-only note naming the round-2 range and
round 1's record as the re-review anchor. The reviewer stayed read-only; the orchestrator landed this record
from its report.

- **Scope:** `0d2f6ef3..513c9e04` — round 1's fix leg (the F1 pin + fix + disposition) and the author-ruled
  edits landed since (the advice's while-connected sentence; the two sitting copy edits).
- **Status: ROUND 2 COMPLETE — 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT. No new BLOCKER/MAJOR, so no round 3
  is earned. THE COMBINED LADDER IS CLOSED AT ROUND 2.**

## Round 1's record re-reviewed (each item against the diff)

- **F1 (the dead-wing replay) — FIXED, VERIFIED END TO END.** The shipped fix is exactly the disposition's
  final call (the obsolete half only; the scoping as a documented precondition). The reviewer re-traced the
  mechanism from the helpers themselves and REPRODUCED the red-on-old by its own hands: a detached scratch
  worktree at the pin commit `6fac6d5f` ran the pin → **5 issues**, the other 10 tests green; on the tip the
  suite is **11/1 green**. `wingIsLive('')` = true, so Home-involved replays are never wrongly obsoleted.
- **F2 (the U6-8 cell) — CLOSED** (flipped with its pointer).
- **F3 (the advice's register) — CLOSED BY RULING** (P-13nc-U4-1, her sitting: the split stays).

## The author-ruled edits verified

- **The while-connected sentence** (`MCPSession.swift:58-60`): every clause matched against the mechanics the
  reviewer read itself (`MCPServerHost.ended` revokes the NAME's connection grants only at the last live
  session's close; `stop()` hangs every session up; `start()` sweeps synchronously before listening; nothing
  re-mints on reconnect). The pin executes all five clauses against the real host — **8/1 green** by the
  reviewer's own run; the 2,000-bound pin green beside it; provider-neutral; the ruled register honored.
- **P-13nc-U2-2 reversed in-pane** and **P-13nc-SB-2 reworded**: both single-sourced, every render site reads
  the one constant, the pins assert through the consuming layer. Reproduced under a held-and-released stage
  claim: **58 tests / 3 suites TEST SUCCEEDED**.

## Findings and dispositions

| # | Sev | Where | Finding (short) | Disposition |
|---|---|---|---|---|
| R2-M1 | MINOR | the plan's running PROVISIONALs list | The sitting's rulings were recorded in the sitting block but never back-propagated: ~7 entries still read as open questions or quote copy the app no longer says, and the list is the merge-time #211 source. | **ACCEPT — FIXED in this commit (the orchestrator):** every ruled entry now carries a "↳ RULED at the 2026-10-11 sitting" line pointing at the sitting block; the ledger header carries the discharge line. Record class, no pin. |
| R2-N1 | NIT | `Operations+MCPWingMove.swift:187/:231` | A residual, deliberate corner: the note's CURRENT wing dying can resolve INTO a HOME stood-in wing (client moved S→Home; her door moved Home→X; X dies by sync), and the undo proceeds where P-13nc-U6-3's moved-on letter says obsolete — while the dangling-reads-as-Home doctrine (P-13id-U5-2) says the note genuinely stands in Home. Bounded: only a bare note can land (anything gained since refuses `wingMoveChangedSince` through `wingScope('')`); no cross-wing row mintable; sync-only; mirror on redo. | **ACCEPT AS RECORDED, NOT FIXED** — the right outcome is undefined between two letters (product territory). Landed as the second corner row in P-13nc-U6-3's annotation — then RULED QUIET-OBSOLETE at the sitting minutes later (the plan's fourth-round block): now a confirmed finding with a fix owed, implemented by this round's reviewer per the cross-model flow (red-on-old pin first), implementer sanity pass after. |
| R2-N2 | NIT | `CapabilityRegistry.swift:2191` | `mcpRevokeGrant`'s unavailable note says "Shared places are revoked in Settings ▸ MCP." while the pane section is now titled "Shared with AI" (her in-pane reversal) — the noun no longer matches the title a user will look for. | **ACCEPT — rides the post-ladder copy/lesson job** as a PROVISIONAL realignment (app voice allows "AI"; e.g. "Sharing with AI is revoked in Settings ▸ MCP."), final words hers at the copy pass. |

## Clean bill (the reviewer's, summarized — its full list is in the report)

- The F1 fix core-only, guard order correct both directions, no existing behavior regressed (the prior 10
  tests green on BOTH sides of the fix).
- Finals reproduced exactly: core **2,634/301** · `VariorumMCPTests` **93/14** (no VX-132 stall this run) ·
  workbook **40/6**; the Mac batch 58/3 under a held-and-released claim.
- Range hygiene: the whole diff read line by line — ten files, zero `Sync/` / `Server/` / schema / migration /
  custody / editor-seam / `Persistence/` lines; zero trailers; canon untouched; commits past the range tip are
  notes-only; P1 holds (two point lookups on the author-scale wing table); no "Review foci" section exists
  (verified by grep) — round 1's F1–F3 dispositions served as the mandatory anchor, all addressed.
- Process: read-only throughout; the one stage claim released; the scratch worktree removed.

## The ladder's close

Round 1 (`33bd8772..0d2f6ef3`): 0B/0M/1m/2n, F-1…F-25 ALL CONCUR. The fix leg: F1 fixed per the implementer's
refinement, sanity-passed SOUND. Round 2 (`0d2f6ef3..513c9e04`): 0B/0M/1m/2n, no new BLOCKER/MAJOR. **The owed
Fable span and Stage C/U6 are discharged; the ladder closes clean at round 2.** Next per the takeover schedule:
the ruled how-to-use-it guide lesson (+ the two PROVISIONAL copy items above), then the Opus UX-reviewer walk.
