# The 2026-09-12 use-report round — ORCHESTRATOR HANDOFF (first written 2026-09-12 ~06:00 by the Fable orchestrator for a compaction; REWRITTEN 2026-09-13 at the CUTOVER to a SUCCESSOR SESSION at her word — "you're at 600k and given that 18i, 18g, and 18j still remain it would be best to do that in a new session")

*This file is the orchestrator's transcript-proof state. It serves THREE readers: (1) the SAME session after a
context compaction (read it first, then LIVE STATUS in the plan); (2) a SUCCESSOR orchestrator if this session
dies (§0 is paste-ready); (3) the AUTHOR in the morning (§5 — what is hers). The ONE record of the round is
`notes/plans/use-report-round-2026-09-12.md`; this file never contradicts it — when the plan's LIVE STATUS is
newer than §2 below, the plan wins.*

## 0. PASTE-READY KICKOFF FOR THE SUCCESSOR ORCHESTRATOR (written 2026-09-13 by the first orchestrator at ~600k context, at her word: "it would be best to do that in a new session")

> `/architect-phase use-report round 2 (2026-09-12) — the SECOND SESSION` — you are the successor orchestrator of the 2026-09-12 use-report round. **17p and 18h are CLOSED**; you run **17q → 18i → 18g → 18j → the round-end Fable pass → the closeout → the author handoff → the install refresh**. Work in `~/dev/variorum` on `main`. **READ, YOURSELF, IN THIS ORDER:** this handoff whole (§1 what the round is; §2 the state as of the cutover; §3 the install-refresh recipe; §4 the close's obligations; §5 her items; §6 machinery lessons — the first session's, all still true, plus the second list) · `notes/plans/use-report-round-2026-09-12.md` — §7 (her rulings R-Q1…R-Q20, SETTLED — R-Q16…R-Q20 from her 2026-09-13 morning sitting), §12 (the REVIEW FOCI — every reviewer is told to treat them as mandatory), §8–§9, LIVE STATUS (the newest state — it wins over §2 here), the Records — R-0 the constitution; R-1…R-4 with their adjudications and ladders (read the 17p LETTER CLOSEOUT and the 18h LETTER CLOSEOUT for the round's standard of evidence and its lessons: pins whose second pass is hand-fed are green for the wrong reason; a measurement must execute the arm it measures; name suite TYPES; the app never runs ANALYZE) · the briefs already appended for you: `### R-5 · 18i — BRIEF` (with its pointer note), and the staged `R-6` / `R-7` texts in `notes/plans/use-report-2026-09-12-briefs/` (append each VERBATIM at the previous batch's close, re-grepping its pointers — 18i moves `ThemeSettings`, `Operations+Appearance`, `ThemeStore` and the Appearance pane before 18g; 18g rewrites the resolver before 18j) · `notes/author-reports/2026-09-12-use-report.md` · CLAUDE.md and the canon it loads · `notes/plans/phase-17-standing-fixes.md`'s rules · `notes/SessionResiliencyProtocol.md` · `notes/KnownIssuesAndTechDebt.md` · `.claude/agents/*.md`.
> **VERIFY, NEVER TRUST, before acting:** `git log --oneline -10`, `git status -sb`, `git diff --stat`, `pgrep -fl 'Variorum.app/Contents/MacOS'` (**she is AWAKE now** — a real-store instance at `/Applications` is hers: NEVER quit/kill it; walks run on the dev-store Debug build regardless; the install refresh at the close needs a zero-instance window she grants), `pgrep -fl caffeinate`, `ListAgents`.
> **FIRST ACT — 17q (small, before 18i):** her two morning builds — R-Q20 (J3: when the entry landing names a block, the landing wins and the remembered place is not restored; one condition on `TakesBoardLayout`'s restore/landing step + a pin) and R-Q17 (#103: the Library's Notes card shows the stated day AND the sort's stamp where there is room, the click-flip where small) — one `opus-implementer`, one cold review (`fable-reviewer`: the Takes half is the landing family), the dev-store walk, a register row in `phase-17-standing-fixes.md`, dispositions at its close.
> **THE LOOP, per batch:** spawn ONE `opus-implementer` on the brief by pointer → on its report VERIFY against git → write the ADJUDICATION (the next J number — J14 onward) → the ladder per letter: `fable-reviewer` on 18g and 18j (a default's meaning; every surface), `opus-reviewer` on 18i (chrome; re-spawn as Fable if the diff reaches the seam or a default's meaning); the cross-model flow under a Fable reviewer, the same-model flow under Opus (you arbitrate against the spec, the implementer fixes); round 2 fresh; a new BLOCKER/MAJOR ⇒ round 3; cap 3. **Then the round-end Fable pass** over the Opus-reviewed letters (18h — already Opus-reviewed, its fixes included — and 18i), the closeout (§4), the author handoff `notes/handoffs/use-report-round-2026-09-12-handoff.md` with HER CHECKLIST at the top, the install refresh (§3) at a window she grants.
> **ONE agent at a time. Never edit the plan while an implementer holds the tree. Repo-first records. Push every commit. No trailers. Name suite TYPES. PROVISIONAL-and-continue; bundle for her — she is present today, so a genuine product fork may be ASKED with the question tool (≤4 per call, recommended first) instead of parked.**

## 1. WHAT THE ROUND IS (one paragraph — the plan's §0 is the full one)

Her 2026-09-12 report: the Takes page "opening at the bottom" and "a mess" (ONE defect — the last round's
entry landing anchored to the top + the typewriter room), the empty block's placeholder under the caret,
the tray's missing Delete Now on block rows, the Callout Emoji alert's collapsed field, the comment badge and
callout emoji over the text in the book Outline, the confirmation toasts, created/edited times, the Library
sortable by time, an "edited on a day" search, colour palettes — and, added at the sitting, six two-tone and
five bold palette builds, dark mode pulled forward from 13u4. Five letters: **17p** defects (batches a, b;
the phone's row left for a mobile session) · **18h** time (batches 1, 2) · **18i** confirmations · **18g**
palettes · **18j** dark mode. Order 17p → 18h → 18i → 18g → 18j.

## 2. STATE AT THE CUTOVER (2026-09-13, the first session's close at ~610k context — the plan's LIVE STATUS supersedes this the moment it is newer)

- **Tree:** `main` at `7236a1e7 (18h's close) plus this handoff commit` == `origin/main`, clean. Marker **8** (v1_17 added `idx_commit_created` — an index, not a lockstep event).
- **17p — CLOSED as a letter** (`34799a1b`): rows 1–6 FIXED with pins, row 7 RETIRED to mobile; batch a's Fable ladder capped at three rounds, batch b's closed at two; the LETTER CLOSEOUT is in the plan and copied into `notes/plans/phase-17-standing-fixes.md` (the register row CLOSED); canon deltas applied (AppSpec §12's takes line; R103's dated sentence; KnownIssues' R1-7 amendment + two 13u2 rows).
- **18h — CLOSED as a letter** (`7236a1e7`): rows 9–11 FIXED; the Opus ladder's round 1 (1 BLOCKER · 3 MAJOR · 7 MINOR · 5 NIT — all fixed; the BLOCKER was the day search's correlated savepoint arm, P1, my J11 having accepted a measurement that never ran the arm) and round 2 (round 2: 1 MAJOR — a regression by R1-11's fix, fixed — · 5 MINOR · 6 NIT; round 3, the cap: 3 MINOR · 7 NIT recorded to 17q / #103 / the close; open defects none); the LETTER CLOSEOUT in the plan; AppSpec §7's `commit_point` DDL gained the index and §12's Library line the stamps, the sort and the day filter. Baselines at the cutover: core 1545/167 · Mac (the letter's closing set) 217/37 (batch 2's set) · 206/34 (batch 1's set) · iOS green.
- **Her morning sitting (2026-09-13) — R-Q16…R-Q20 in §7:** #102 ratified (the lane everywhere) · #103 RULED (the card shows both where there is room, the click-flip where small — a BUILD, 17q) · #104 ratified (notes only) · J5 the 64 pt lane kept for now (her stack-under-the-drag-dots idea recorded for the lane's next touch) · J3 RULED — the block she came from wins (a BUILD, 17q).
- **NOT STARTED:** 17q (the two morning builds — first), 18i (R-5 appended in the plan), 18g (R-6 in the briefs folder — append), 18j (R-7 — append), the round-end Fable pass over 18h + 18i, the closeout, the author handoff, the install refresh.
- **Briefs:** `### R-5 · 18i — BRIEF` is IN the plan with its pointer note; R-6 and R-7 are in `notes/plans/use-report-2026-09-12-briefs/` — append each verbatim at the previous batch's close and re-grep (18i moves `ThemeSettings` / `Operations+Appearance` / `ThemeStore` / the Appearance pane; 18g rewrites the resolver). The palette mockup she approved: `notes/plans/use-report-2026-09-12-mockups/palettes.html`.
- **Machinery:** `caffeinate -dims` was left running by the first session (check `pgrep -fl caffeinate`); she is AWAKE and may run her real app — never touch it; the install refresh needs a zero-instance window she grants.
- **Agents from the first session:** all finished; none to resume. The successor spawns fresh.

## 3. THE INSTALL REFRESH RECIPE (the last act; only after the round-end pass and the closeout; zero instances)

`pgrep -fl 'Variorum.app/Contents/MacOS'` must be empty — she is awake and may be using her real app, so the window is HERS to grant (ask; never quit it). **A1 backup FIRST:** copy the whole container store
folder (the encrypted `variorum.sqlite` + shm/wal, the key files, `Backups/`) to
`~/dev/variorum-store-backups/use-report-2-refresh-<UTC stamp>/` with the app closed; `cmp` the sqlite and wal
byte-identical; verify the header is NOT `SQLite format 3` (ciphertext) — NO headless `integrity_check`
(SQLCipher; the key is in her Keychain custody; the app's own backups run it). Then build Release in a CLEAN
worktree (`git worktree add ~/dev/variorum-final <final hash>`; `xcodebuild -scheme Variorum -configuration
Release build` with its own DerivedData), copy the product to `/Applications/Variorum.app`,
*[removed for publication]*
keychain access groups unchanged (`codesign -d --entitlements -`), record the binary hashes before/after,
remove the worktree and its DerivedData. The precedent with every command: the last round's LIVE STATUS
(`notes/plans/use-report-round-2026-09-06.md`, the finish's entry) and its handoff item 1.

## 4. OBLIGATIONS AT CLOSE (the plan's §10 + CLAUDE.md's ritual — nothing here is optional)

Every ledger row dispositioned · every ladder complete or capped with residue owned · the round-end Fable pass
(both rounds if round 1 fixes anything MAJOR) · the FULL Mac suite over the final tree + core + the iOS build
· the canon deltas exactly as ruled (AppSpec §7's `setting` seeds — `receipt_style`, `theme_palette`,
`theme_tint`/`theme_accent_tint`; §12 — the palettes, the appearance choice, the stamps and sort, the takes
line's R103 face supersession; §14's delta paragraph, the outgoing one rolled to the archive) · QUESTIONS'
ratify list (#102+) · KnownIssues rows for anything deferred, owned · 17p's dispositions copied into the
standing-fixes file and its register row closed · the master plan: the pointer back to 13u1, row 3d ✔, the
Phase 18 row, the closeout-log paragraph (the previous one rolled to `PhaseCloseoutArchive.md`) · the MOBILE
PARITY LINE PL-22 confirmed (palettes/appearance by construction? the phone must compile) · the author
handoff `notes/handoffs/use-report-round-2026-09-12-handoff.md` with HER CHECKLIST AT THE TOP · the install
refresh (§3) · the briefs folder deleted at the finish (its content lives in the plan's Records) · memory
updated · push.

## 5. FOR HER (the morning bundle so far; the author handoff at the close carries the final list)

- **Ratified/ruled today:** #102, #103 (→ 17q), #104, J3 (→ 17q), J5 (keep 64 for now; the stacking idea recorded).
- **Still hers at the close:** the walk of every row on the refreshed build; the Appearance pane after 18g/18j (pick a palette, try custom, cycle the appearance choice); QUESTIONS from 18i/18g/18j; the judgment calls J14+.
- **Recorded, not asked:** the KnownIssues rows (the kept-alive landing's enumerated her-hand set + option (b) for 13u2; the reflow discriminator; the lane's two residuals; the app never runs `ANALYZE` — owner 12); the two hoist candidates named in R-3/R-4's records.

## 6. MACHINERY LESSONS THIS SESSION (so a successor does not relearn them)

- One commit's message over-claimed edits whose script had stopped at a stale anchor (`88211346`); the next
  commit said so and landed them. Rule: `assert old in s` BEFORE the commit command runs, and never chain a
  commit onto a script that can fail silently.
- The mockup is a LOCAL HTML file, never an Artifact (her standing rule); `open <path>` puts it in front of
  her; say the path in the reply.
- Her app was RUNNING during the sitting (a real-store instance at `/Applications`); it is QUIT now. Walks
  are on `io.lduarte.Variorum.debug` regardless.
- The scratchpad is not durable (the resiliency protocol's addendum 11) — the briefs moved into
  `notes/plans/use-report-2026-09-12-briefs/` for that reason; anything else worth keeping goes in the repo.

### The second list (2026-09-13 — the first session's items above stand)

- **A pin whose second pass is hand-fed is green for the wrong reason** (17p a's three-block pin; 17p b's nine lane pins): drive the second pass through the surface's own report, or the walk finds it.
- **A measurement must execute the arm it measures** (18h's J11): a fixture where every row satisfies the cheap arm never reaches the expensive one; contrast the empty case.
- **`-only-testing` takes suite TYPE names**; a file name matches nothing and `xcodebuild` runs the rest silently — read the `Test run with N tests in M suites` line every time.
- **zsh does not word-split an unquoted `$var`** — put `-only-testing` arguments in an array.
- **Two heredocs on one shell line** fed a python script to `git commit -F -` (`5f9a3a89`): never chain a commit onto a script on the same line; the message is a separate, checked step.
- **A same-model ladder with two batches**: route findings to each batch's implementer, arbitrate once, fix in batch order (the shared file's latest hand first), then round 2 fresh.
- **Her presence changes the rule:** parked PROVISIONALs become question-tool batches (≤4, recommended first); record her words verbatim the same turn.

