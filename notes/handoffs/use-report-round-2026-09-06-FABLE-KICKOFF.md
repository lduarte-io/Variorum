# THE FINISH — a paste-ready kickoff for a FRESH Fable session

*Written 2026-09-08 by an Opus session after the orchestrator's Fable budget ran out mid-ladder. Everything in the round is built, adjudicated, closed and pushed EXCEPT one bounded cold read and the mechanical finish behind it. This file exists so none of that costs a stale session's re-orientation: the two agents that hold this round's context (the orchestrator at ~600k tokens, the round-end reviewer at ~837k) should NOT be resumed — spawn fresh from here.*

## Why there is anything left

The round-end Fable pass (her ruling: *"add a bounded round-end Fable pass over the Opus-reviewed letters' final diffs only (17o c/d/e and 18d), so Fable sees the chrome fixes once after their Opus ladders. One extra Fable ladder."*) ran its **round 1** to completion: 1 MAJOR · 4 MINOR · 4 NIT, all nine agreed by the implementers, all nine fixed by the reviewer with pins, and the 18d batch-1 implementer's sanity pass returned **9 CLEAR · 0 RAISED** with a walk. **Round 2 was spawned and died at the Fable usage limit before writing a word** — its section in the plan is still an empty placeholder.

**It is not skipped, and the reason is evidence, not ceremony:** every one of this round's five letter-ladders found a NEW MAJOR inside round 1's own fixes — five for five — and the round-end pass's round 1 found a sixth. Round 1's fixes here touch the shell's render path and the editor's typography adoption, which is exactly Fable's mandate. (Recorded as **J46** in the plan's LIVE STATUS; hers to overrule — if she would rather spend the budget elsewhere, closing at round 1 is defensible on her own *"sees the chrome fixes once"* wording, and the read can run later over the named commit range from a 17 entry or 13u1's kickoff.)

---

## STEP 1 — round 2 of the round-end Fable pass (the only Fable work left)

Spawn ONE fresh `fable-reviewer`. Paste this verbatim:

> You are the FRESH cold reviewer for ROUND 2 of the ROUND-END FABLE PASS of the 2026-09-06 use-report round (Variorum, repo `<home>/dev/variorum`, branch `main`). Run `notes/REVIEW_PROMPT.md` verbatim. The author's ruling for this pass: "Keep the per-letter plan and add a bounded round-end Fable pass over the Opus-reviewed letters' final diffs only (17o c/d/e and 18d), so Fable sees the chrome fixes once after their Opus ladders. One extra Fable ladder."
>
> Round 2 is a REAL pass over round 1's fixes and what they touched, never a rubber-stamp. **The diff under review: `git diff 1f6ea613~1..6629f362`** — the round-1 Fable reviewer's ten fix commits (`git log --oneline 1f6ea613~1..6629f362` lists them): the closure-typed `caretLabel` in `RootView.noteBoxView` (the shell no longer re-renders per keystroke under a live book note); the typography stamp at `applyVoiceChrome` / `EditorDocument`; the oracle keying (`railGroupHeight` by the rail's post, the pane seam's subject, `reset()` scoped); `WorkbenchSeam` converted to `SeamGrip`; four doc lines; the note box's windowed "of M" total; `NoteBoxFactsModel.load`'s cancellation guard; and one justified test edit (`MarkdownFaceTests.theFaceFollowsAVoiceSwitch`). Read them AGAINST the letters' final diffs they sit in — 17o c/d/e `e6441686..941380a2` and 18d `ce6eb9cb..01849f3b`. (17o batch b's range `35c11948..4dd54c54` plus its own Fable ladder `1ed87482..f9f26eeb` is NOT in scope — already Fable-reviewed for three rounds.)
>
> Your ANCHOR is in `notes/plans/use-report-round-2026-09-06.md`: `### ROUND-END FABLE PASS — ROUND 1 FINDINGS (fable-reviewer)` (the nine findings, considered-and-cleared, the clean bill), the three `#### ROUND-END FABLE PASS round 1 — the implementers' responses (18d batch 1 / batch 4 / batch 3)` sections with their riders, `#### … dispositions + fixes (the reviewer)`, and `#### … the implementer's sanity pass`. Also: `### 17o — LETTER CLOSEOUT`, `### 18d — LETTER CLOSEOUT`, `### THE ROUND — CLOSEOUT`, J23–J46 in LIVE STATUS, QUESTIONS #97–#101.
>
> Your mandate is Fable's: the editor seam and its neighbours (the closure's capture and what `EditorRouter.editing` does and does not scope; the typography adoption — verify what the fix actually does against `EditorDocument`'s `baseFont`/`baseParagraphStyle`/`baseAttributes`; the surface-size stamp's provenance), custody and `Sources/VariorumCore/Sync/` (verify EMPTY), any DEFAULT's meaning moved, P1 (reproduce the premise of the 20 → 0 shell-render measurement), P39, P-3's one-authority doctrine, and the harness hygiene the keying claims. Verify red-on-old claims you can reach cheaply in a scratch worktree — **the boot volume is tight (~6 GiB free): remove the worktree AND its DerivedData when done**, and never revert in the shared tree. Read the canon the prompt names yourself; never delegate reading.
>
> Write your findings INCREMENTALLY under `### ROUND-END FABLE PASS — ROUND 2 FINDINGS (fable-reviewer, fresh)` at the plan's end (replace its placeholder line), severity-ranked in the prompt's format with mechanism, file:line and the red-on-old pin each would enter with (a pin green on both sides makes a finding hollow and you say so), then the clean bill; commit (path-scoped `git add`, `git pull --rebase`, push) BEFORE your final message. **If you find nothing above NIT, say so plainly — the pass closes there.** If you raise findings, do NOT fix them yet: the orchestrating session routes them to the batch implementers for agree/dispute and returns to you for the final call and your own fix pass. No subagents (one read-only Sonnet lookup at most); synchronous foreground waits only; never run the full suite at the start; **no `Co-Authored-By` / `Claude-Session` trailer lines on commits** (her 2026-09-04 rule); never rewrite history. Final message: a pointer plus the severity counts, nothing more.

**If round 2 raises findings** (the cross-model flow, exactly as the round ran it): the findings go to the batch implementer that owns each — they are **Opus** agents, so they cost no Fable — for AGREE/DISPUTE written into the plan; then back to the round-2 reviewer for the final call and its own fix pass with red-on-old pins; then ONE sanity pass by the owning implementer. Spawn `opus-implementer` fresh per batch and brief by pointer (`### R-10 · 18d batch 1 — BRIEF` and its RECORD for the box/shell; `### R-13` for the typography/memory; `### R-12` for the seams). Round 3 is owed only on a NEW BLOCKER or MAJOR; the cap is three.

---

## STEP 2 — the finish (no Fable needed; an Opus session or she can do it)

1. **Record round 2's outcome** in the plan's LIVE STATUS and amend the last paragraph of `### THE ROUND — CLOSEOUT` (it currently says one verification is open).
2. **A final FULL Mac run** from `App/Variorum/`: `xcodebuild test -scheme Variorum -destination 'platform=macOS' -only-testing:VariorumTests` — read the `Test run with N tests in M suites` line and the `skipped:` lines. The last full run was **2458/424 green** at 18d's close `01849f3b`; note that a reviewer cleared build intermediates on 2026-09-08, so the first build after that rebuilds from scratch (~10 min).
3. **The master plan** `notes/DetailedPlanForPhases.md` — four flips, all mechanical:
   - **Current phase** (the `**→ …**` block under `## Current phase`) → the 13u1 pointer. The outgoing block rolls VERBATIM into `notes/PhaseCloseoutArchive.md` under a new `## Superseded pointer — rolled 2026-09-XX at the use-report round's closeout`.
   - **The running order** (the `> …` block, ~line 61): `→ **the use-report round — 17o · 18c · 18d · 18e · 18f** (IN PROGRESS from 2026-09-07 …)` → `→ **the use-report round — 17o · 18c · 18d · 18f** ✔ (closed 2026-09-XX; 18e HELD at her word)`.
   - **The phase table**: row `3c` and row `use-report` → DONE with the date and "18e HELD"; the **Phase 18** row gains 18c/18f/18d DONE and 18e HELD **with her contemplation quoted verbatim** (it is in the plan's §5.5 and in the author handoff — quote it, do not paraphrase).
   - **The Closeout log**: the round's paragraph goes FIRST; the pre-13x paragraph rolls to `notes/PhaseCloseoutArchive.md`. A ready-to-use paragraph is in the scratchpad note named below, or write it from `### THE ROUND — CLOSEOUT`.
   - *(A drafted script for exactly these edits was staged at `…/scratchpad/round-close.py` with its texts in `round_close_texts.py`; the scratchpad may not survive, so the steps above are the authority.)*
4. **Delete the scaffolding**: `rm -r notes/plans/use-report-round-briefs/` (its briefs are all appended into the plan's Records) and mark `notes/plans/use-report-round-orchestrator-handoff.md` superseded.
5. **The install refresh — the round's last act, and only after the last walk**, at a **zero-instance window** (`pgrep -fl 'Variorum.app/Contents/MacOS'` must be silent; never quit an instance she opened):
   - **The A1 backup FIRST**: a WAL-safe copy of her real store into `~/dev/variorum-store-backups/use-report-refresh-<UTC stamp>/`, with `PRAGMA integrity_check` = ok. Her store: `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/`.
   - Build Release in a clean worktree (the pre-13x precedent used `~/dev/variorum-final`): `xcodebuild -scheme Variorum -configuration Release build`, copy the product to `/Applications`, then `codesign --verify --deep --strict`. Record the binary hashes in the author handoff.
   - **Disk**: only ~6 GiB is free. Reclaim first if needed — see the author handoff's item 7.
6. **Memory**: update `variorum-phase-9-run-state` to "round closed; next 13u1".

---

## The state to verify, never trust

- `main` == `origin/main`, tree clean, at the commit this file was written beside.
- Letters CLOSED: 18c `db02623a` · 18f `606ad6b9` · 17o `c4ef6104` · 18d `bc06d1e6`.
- The round-end Fable pass: round 1 findings `a9b96510`, fixes `1f6ea613..6629f362`, dispositions `60fb2c40`, sanity pass `e43e3937`, round 1 recorded complete `9aebb725`.
- Applied and pushed already: the plan's `### THE ROUND — CLOSEOUT`, AppSpec §14's round delta (+ pre-13x's roll to the archive), `MobileSoul` §6's **PL-21**, the KnownIssues table repair, and the author handoff.
- **The author handoff is `notes/handoffs/use-report-round-2026-09-06-handoff.md`** — her checklist, the walk list, the ratify list, the judgment calls, the disk note.
