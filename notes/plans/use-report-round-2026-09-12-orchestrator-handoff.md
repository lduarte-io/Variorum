# The 2026-09-12 use-report round — ORCHESTRATOR HANDOFF (written 2026-09-12 ~06:00 by the Fable orchestrator, at her ask: "write a handoff note for me so I don't have to wake you later… save whatever you durably need to know in a note so I can run / compact")

*This file is the orchestrator's transcript-proof state. It serves THREE readers: (1) the SAME session after a
context compaction (read it first, then LIVE STATUS in the plan); (2) a SUCCESSOR orchestrator if this session
dies (§0 is paste-ready); (3) the AUTHOR in the morning (§5 — what is hers). The ONE record of the round is
`notes/plans/use-report-round-2026-09-12.md`; this file never contradicts it — when the plan's LIVE STATUS is
newer than §2 below, the plan wins.*

## 0. PASTE-READY KICKOFF (a fresh session, or this one after compaction, starts here)

> `/architect-phase use-report round 2 (2026-09-12)` — you are the orchestrator of the 2026-09-12 use-report
> round (17p · 18g · 18h · 18i · 18j), running UNATTENDED overnight at her R-Q14. Work in
> `~/dev/variorum` on `main`. **READ, YOURSELF, IN THIS ORDER:** this handoff whole ·
> `notes/plans/use-report-round-2026-09-12.md` — §7 (her rulings R-Q1…R-Q15, SETTLED, never re-opened), §12
> (the REVIEW FOCI — every reviewer is told to treat them as mandatory), §8–§9, LIVE STATUS (where the round
> stands — newer than this file's §2), and the Records (R-0 the constitution; every batch's BRIEF · RECORD ·
> ADJUDICATION · ladder rounds) · `notes/plans/use-report-2026-09-12-briefs/R-2.md … R-7.md` (the drafted
> briefs for every remaining batch — append each to the plan's Records VERBATIM at the previous batch's close,
> re-grepping its pointers first) · `notes/author-reports/2026-09-12-use-report.md` · CLAUDE.md and the canon
> it loads · `notes/plans/use-report-round-2026-09-06.md` §8 (the process bound by reference) and its
> handoff · `notes/plans/phase-17-standing-fixes.md`'s rules · `notes/SessionResiliencyProtocol.md` ·
> `notes/KnownIssuesAndTechDebt.md` · `.claude/agents/*.md`.
> **VERIFY, NEVER TRUST, before acting:** `git log --oneline -10`, `git status -sb`, `git diff --stat`,
> `pgrep -fl 'Variorum.app/Contents/MacOS'` (her app is QUIT for the night — if an instance at
> `/Applications` appears, she is awake: NEVER quit/kill it), `pgrep -fl caffeinate` (a `caffeinate -dims`
> should be running; restart it detached if not), `ListAgents` (is an implementer or reviewer still running?
> a running agent gets a MESSAGE, never a twin — resume by `SendMessage` first; a fresh continuation only on
> "No transcript found"). Then continue from the plan's LIVE STATUS **Next**.
> **THE LOOP, per batch:** spawn ONE `opus-implementer` on the brief (by pointer: "your brief is `### R-n ·
> … — BRIEF` in the plan; write your RECORD under `### R-n · RECORD`") → on its report VERIFY against git
> (commits, `--stat` scopes, the record's claims, trailer-free messages) → write the ADJUDICATION (Jn — the
> judgment calls numbered J1… in this round; she reads them in the morning) → at the LETTER's end the ladder:
> a fresh cold reviewer running `notes/REVIEW_PROMPT.md` VERBATIM with `{PHASE}` = the letter, zero framing
> (Fable on 17p-a, 18g, 18j; Opus elsewhere); findings recorded repo-first; the cross-model flow for an
> Opus implementer under a Fable reviewer (the implementer responds agree/dispute, the REVIEWER decides and
> fixes, the implementer sanity-passes); same-model flow otherwise (you arbitrate against the spec, the
> implementer fixes); round 2 re-reviews with a FRESH reviewer; a new BLOCKER/MAJOR ⇒ round 3; cap 3 —
> residue to KnownIssues with an owner or a ledger row into a later batch. **Then the round-end Fable pass**
> over the Opus-reviewed letters' final diffs (her standing rule from last round), the closeout ritual
> (CLAUDE.md's, unabridged — §4 of this file lists the obligations), the author handoff, the install refresh
> at a zero-instance window behind the A1 backup (the exact recipe in §3).
> **ONE agent at a time. Never edit the plan while an implementer holds the tree (append briefs between
> batches). Repo-first records. Push every commit. No trailers. PROVISIONAL-and-continue; bundle for her.**

## 1. WHAT THE ROUND IS (one paragraph — the plan's §0 is the full one)

Her 2026-09-12 report: the Takes page "opening at the bottom" and "a mess" (ONE defect — the last round's
entry landing anchored to the top + the typewriter room), the empty block's placeholder under the caret,
the tray's missing Delete Now on block rows, the Callout Emoji alert's collapsed field, the comment badge and
callout emoji over the text in the book Outline, the confirmation toasts, created/edited times, the Library
sortable by time, an "edited on a day" search, colour palettes — and, added at the sitting, six two-tone and
five bold palette builds, dark mode pulled forward from 13u4. Five letters: **17p** defects (batches a, b;
the phone's row left for a mobile session) · **18h** time (batches 1, 2) · **18i** confirmations · **18g**
palettes · **18j** dark mode. Order 17p → 18h → 18i → 18g → 18j.

## 2. STATE AT THIS WRITING (2026-09-12 ~06:00 — the plan's LIVE STATUS supersedes this the moment it is newer)

- Tree: `main` at `33fa46d5` + uncommitted batch-a work (piece 5, the walk, in progress). `main` == `origin/main`
  at every orchestrator commit; the implementer pushes its own.
- **17p batch a IN FLIGHT** — `opus-implementer` spawned after `8df4f6c0`; pieces 1–4 landed (`664b7ad0` the
  scroll memory + reveal rule; `33fa46d5` the empty line + the door's alignment); piece 5 (the walk) running.
  Its RECORD is under `### R-1 · RECORD` in the plan. **After it reports:** verify against git; write the R-1
  ADJUDICATION (J1…); spawn the 17p-a Fable ladder round 1 (`fable-reviewer`, `{PHASE}` = "17p batch a", zero
  framing) — cross-model flow (the batch's implementer resumed for agree/dispute and the sanity pass; the
  reviewer decides and fixes); then append R-2 and spawn batch b.
- Baselines: core 1503/163 (this session); the FULL Mac suite 2462/424 over the byte-identical code tree
  `fd434824` (last round's final); iOS green; marker 8. Zero schema, zero `Sync/` expected.
- Her rulings: R-Q1…R-Q15 in the plan's §7 — all SETTLED. Notable: R-Q2 no placeholder anywhere (R103's face
  retired); R-Q5 receipts quiet by default, toast an option; R-Q11 + R-Q13 the three preset batches (4 pastels ·
  6 two-tone incl. grey & GREEN · 5 bold) all ship, custom = one hex + optional second; R-Q12 dark mode = 18j;
  R-Q14 overnight unattended; R-Q15 architecture in every review (§12's foci).
- Mobile: the phone's Write-page scroll LEFT the round (her word) — written on the `mobile` branch's
  `notes/plans/mobile-round-2-orchestrator-handoff.md` §12.2 + §12.2a (a paste-ready kickoff for her mobile
  session); PL-22 in `notes/MobileSoul.md` §6. Nothing here touches it.
- Briefs drafted and COMMITTED: `notes/plans/use-report-2026-09-12-briefs/R-2.md` (17p batch b) · `R-3.md`
  (18h batch 1 — carries a CORRECTION to the plan's §4.7/§4.8: the Library surface is `LibraryCatalogModel` over
  `Queries.searchCatalog`, not `observeLibrary`; apply that correction to §4.7/§4.8 when appending R-3) ·
  `R-4.md` (18h batch 2) · `R-5.md` (18i) · `R-6.md` (18g — the three preset batches, the two-seed brain with
  two intensity tables, custom's two fields) · `R-7.md` (18j). Append each VERBATIM as `### R-n · … — BRIEF`
  + `### R-n · RECORD` at the previous batch's close; re-grep every `file:line` first (the tree moves).
- The palette mockup — her approved reference for 18g, committed: `notes/plans/use-report-2026-09-12-mockups/palettes.html`
  (two pastel rows per voice, the six two-tone builds, the five bold builds; the dark strips are 18j's
  previews, not part of any light theme). Keep it; the closeout names it in the master plan's row 3d (already).
- Machinery running: `caffeinate -dims` (detached); the core baseline log at `scratchpad/use-report-2/core-baseline.log`
  (scratch — not durable; the number is recorded in LIVE STATUS).

## 3. THE INSTALL REFRESH RECIPE (the last act; only after the round-end pass and the closeout; zero instances)

`pgrep -fl 'Variorum.app/Contents/MacOS'` must be empty. **A1 backup FIRST:** copy the whole container store
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

## 5. FOR HER, SO FAR (the morning bundle grows in the plan's LIVE STATUS; this is the seed)

- Nothing needs her before the close. Her acts at the close (the author handoff will list them): launch the
  refreshed app; the walk of each row; the Appearance pane — pick a palette, try custom, cycle the appearance
  choice; QUESTIONS #102+ to ratify; the judgment calls J1… to review.
- Every preset's seeds are constants she can change later (R-Q13: "I'll change them later if I feel like it").
- The phone's Write-page scroll: the mobile session's, on its own branch (§2).

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
