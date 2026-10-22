# VX-329 — orchestrator cutover handoff (written 2026-10-22 at ~857k, at her word; the successor is the same
session post-compaction)

## THE KICKOFF PROMPT (paste-ready)

You are the VX-329 architect/orchestrator, post-compaction, mid-phase. Read FIRST, in full, yourself:
`notes/handoffs/vx-329-orchestrator-handoff.md` (this file — the state map), then
`notes/plans/vx-329-release-switch.md` WHOLE (the plan: §6 the cut, §6a–§6d the briefs, §5 the unit records,
§7/§8 the rehearsal, the morning sitting record), `notes/plans/vx-329-ladder-round-1.md` + `-round-1-fixes.md` +
`-round-2.md`, and `notes/plans/vx-329-switch-day.md`. Worktree `~/dev/variorum-vx-329`, branch
`vx-329-release-switch`; the Sync/-custody slot is HELD by this effort; no coordinator — you hold `Tools/stage`
directly. VERIFY, never trust: `git log --oneline -20`, `git status -sb`, and the §5 records' LIVE STATUS before
acting. Then continue the remaining line exactly as the handoff's "THE REMAINING LINE" section orders it. She is
AWAKE and ready for the deploy window; everything to the PR is yours autonomously; the deploy, installs and
release are HERS at her explicit go.

## The mandate (hers, verbatim-faithful)

Overnight: U1, U3, riders, the throwaway rehearsal; pause staged for her hands. Cold reviews FABLE. Release
**0.10**. pg_temp: rehearsed on the throwaway (DONE, green); production rides the marker-14 deploy set at her go.
Morning additions (she joined live): RESTORE.md rewritten (landed, her edit pass + two word corrections in);
rule 27 amended (passphrase OR words — canon edited in place); VX-465 accept-as-designed; the refusal-face
sentence declined THEN superseded by the byte-copy finding → **U4 (the pre-design face) ruled IN with her words**;
the two runbook word corrections approved (landed).

## STATE AT CUTOVER (verify by git, never trust)

DONE, all pushed on `vx-329-release-switch` (~45 commits; keys only):
- **L0** lockstep: marker 13→14 + artifact 17 registered in the drift pin (`0d1820336`, red-on-old verified).
- **U1** the switch: `ProtectionRoad.live` → true everywhere, today's road DELETED whole (~8,200 lines + suites;
  14 commits ending `a0a1c3c0c`), ⌃⌘L declared, sweep table in §5.
- **L1** my Sync/ carve: CorpusRotation + rekey guards + `accountRekeyIncomplete` gone, `pullRound` fold
  (`d0c579f08`); **L1b** StaticSyncKeyProvider carved (`e7e4d07d9`).
- **U3** VX-423 one refresh authority (8 commits ending `a2886c19e`; red-on-old by behavioral revert).
- **R1** seven riders each red-on-old (`3470c6905`..`471b57fc4`): VX-461 (in-memory journal fix) · 462 · 464 ·
  469(c) · 473 · 468 · 463. **VX-470 sized OUT — leads the next run** (recorded + Linear comment).
- **Fix legs:** Mac suite's six reds + F-FL-1 @MainActor (ends `f06dbcf60` + mine); phone's two reds
  (`3554cc1c4`..`bef208ff5` — the no-redirect sweep's 28 offenders dispositioned).
- **THE STAGE BATCH GREEN:** full Mac 5085/889 exit 0 (run 2); full phone 808/126 exit 0 (run 2, iPhone 17 Pro
  iOS 26.2 sim).
- **LADDER:** round 1 (1 MAJOR mine + 6 MINOR + 2 NIT, no BLOCKER) — all dispositioned; the disputed export pin
  resolved by the reviewer (the `-shm` counter-pin is the pin of record); r1 fixes applied (`53635410d`..
  `deee7fe79` + my `2240a7f19` record fixes + the delta-brief rule-27 line). Round 2 (`vx-329-ladder-round-2.md`):
  r1 fixes CONFIRMED; new MAJOR (five stale runbook pins) FIXED test-side (`c47c61b84`, byte-proof green);
  2 MINOR word corrections LANDED at her approval (`514f8e60c` + the §3 row line commit); **ROUND 3 IS EARNED
  and still OWED** (narrow — see the line below).
- **RESTORE.md** rewritten to the rules, HER edit pass, landed in the byte-equal trio (`543645f53` + `514f8e60c`
  + the corrections commit). **Rule 27 amended** (`8a369f4c5`).
- **§8 THE REHEARSAL — §2 ANSWERED YES** (the record is the plan's §8 + addendum): pre-shape vault planted for
  throwaway user B + artifact 17's backfill VERBATIM + 14 rows pushed sealed; the GUI join through the app's own
  act read the backfilled mode and spoke the words moment byte-faithful; the headless pull read the pre-switch
  notes back VERBATIM by the typed account passphrase alone. Dev slot restored 9/9 cmp twice. pg_temp artifact
  (`Server/supabase/maintenance/vx213-pg-temp-search-path.sql`) rehearsed green (62 OK · 4 INFO).
- **THE BYTE-COPY FINDING (§8 addendum):** a pre-design store meets 0.10 as a DEAD-END LOBBY (no door out) —
  her go: **U4, the pre-design face**, her approved words in §6d.
- **Staged for her:** the real-store byte copy `/Users/Shared/vx329-rehearsal/` (7/7 cmp + README; A1 twin
  `variorum-vx329-stage-20261022T115834Z`); `ReleaseNotes-0.10.md` (her rewrite); the switch-day script
  `notes/plans/vx-329-switch-day.md`; the vx307 deploy checklist amended (pg_temp row + Macs-first choreography).

IN FLIGHT AT CUTOVER:
- **U4 (the pre-design face)** — a fresh Opus implementer building to §6d (her words byte-faithful; the
  classifier fact names-never-reads; Start fresh = the whole-set-aside + fresh mint; keyless/format-3 arms
  unchanged; pins red-on-old). It checkpoints per piece to the plan's §5. If its completion notification was
  lost to compaction: check `git log` for its commits and the §5 U4 record's LIVE STATUS; resume by the
  SessionResiliencyProtocol (SendMessage first, fresh closer only on "No transcript found").

## THE REMAINING LINE (in order; nothing else before the PR)

1. **U4 lands** → spot-check (commits, record, residue) → update `vx-329-switch-day.md`'s testers' section to
   the paste-ready message (drafted in the §8 addendum conversation; the face's doors now exist): copy out
   before updating (Copy full text — NEVER the old build's broken Data Safety door), synced testers just let it
   sync once; after updating, **Start fresh** (the old library set aside whole) then sign in.
2. **The CLOSING FULL MAC RUN** (stage claim; `xcodebuild -scheme Variorum -destination 'platform=macOS'
   -derivedDataPath DerivedData/vx329-stagebatch test`; background + notification): the re-cover of record for
   the five flipped pins (DataSafetyTests), the word corrections, the phone leg's ProtectionWords change, and
   U4's face. ALSO the full phone sim run if U4 touched shared code (it does — the classifier fact):
   `-scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'`. READ THE ✘ LINES
   AND CRASH REPORTS, never exit codes or summaries alone (two lessons tonight: the "3 issues" line hid a host
   crash; an `-only-testing` filter matching nothing exits 0 with ZERO tests — always confirm "Test run with N").
3. **ROUND 3** (fresh `fable-reviewer`, NARROW): the five pin flips against the approved literal; U4 whole
   (classifier + act + words byte-check); the two landed word corrections; the §8/addendum records' honesty.
   Spawn with the round-2 file + fixes as its spec, zero framing beyond scope. New BLOCKER/MAJOR ⇒ its fix leg
   (hard cap reached — round 3 is the last; a final round's fixes get MY line-by-line check per the skill).
4. **CLOSEOUT** (the skill's ritual, unabridged — the checklist below).
5. **THE PR** → merge commit to main → **PAUSE at her window** (she is ready).

## THE CLOSEOUT CHECKLIST (item by item)

- Results + counts into the plan (§9); the plan's STATUS banner → CLOSED with the date.
- Master plan: VX-329's in-flight row retired; the closeout paragraph (the outgoing VX-309 one rolls to
  `notes/PhaseCloseoutArchive.md`).
- **Canon deltas (the two-file rule, exactly as ruled):** AppSpec §7's `sync_state` comment drops
  `rekey_in_progress` (the L1 note, corrected at r1 — AppSpec, NOT SyncSpec); SyncSpec §3's `device_id`
  staleness (pre-existing, one line); SyncSpec §12 gains the marker-14 running-record entry AT THE MERGE (the
  deploy itself is hers — the entry notes HELD-until-her-window if the merge precedes the deploy; follow the
  VX-307 pattern: the checklist stays the record until the window, then the §12 entry at the window's close —
  decide by what the merge moment knows); SurfaceContracts' protection line: Release runs the new road
  (ProtectionRoad switch flipped at VX-329), the portability line's "the Release road until VX-329" ends, the
  pre-design face joins the contract in place with one pointer; CastleRules rule 27 ALREADY amended in place
  (`8a369f4c5`) — its narrative + her words to `notes/AppSpecRecord.md`'s dated VX-329 entry with everything
  else (the morning sitting record in the plan is the source). `Tools/canon-size` run; its line in the handoff.
- **QUESTIONS #238** (the bundle): the PROVISIONALs P-VX329-U1-1..7 · P-VX329-R1-1..4 · P-VX329-PH-1 · the U4
  words (hers, so recorded not provisional); F-R2's leftovers; anything round 3 adds.
- **Tickets** (the Linear API road — `security find-generic-password -s variorum-linear -w` or
  `~/.variorum/linear.key`; the raw GraphQL, the MCP needs OAuth): CLOSE at the merge: VX-329 · VX-423 · VX-461
  · VX-462 · VX-463 · VX-464 · VX-468 · VX-469 · VX-473 · VX-233 (already Canceled; its file deleted) · VX-406 ·
  VX-380 (if its red died with its subject — verify) · VX-213 (pg_temp rehearsed; production note at her window)
  · VX-465 (traced-by-design at her accept) · VX-114 (F-PH-3). COMMENT: VX-379 (the truth-check rode this run:
  the runbook; the guide chapters' re-check at the window), VX-234 (the Protection-row blurb reword still
  owed), VM-8 (the phone's pre-design face + F-PH-1/F-PH-2 + F-U2-7), VX-212 (phase 6 runs after the merge —
  her kickoff call), VX-470 (leads the next run). MINT (triaged to the labeling rule): the MCP harness timing
  flake (Tests & tooling, Bug, Test-only — 5+ sightings incl. MCPSizeCapTests + MCPSetupKeyServerTests arms,
  StarContextTests once); the export stranger-sidecar refusal (Low, Improvement, Import & export — r1's
  ruling); F-FL-2 (the catch arms' past-the-swap read — Bug, Suspected, Castle & sync, Low); F-R1-4 (the
  own-lock-beside-copy siblings — Improvement, Castle & sync); F-U3-2 (two processes over one scope — record
  or Low); F-U3-3 (AuthTokensStore ignores a failed save — Bug, Suspected, Low); walks-never-run-rounds (the
  A4 fence vs the walk switch — Improvement, Tests & tooling); the VX-465 counts wording row (Low, Wording, at
  her accept); the lifecycle never-list's rule-27 exception (NIT — fixture + regen, her call). **Every ticket
  this effort filed is triaged before it closes; the handoff lists them by priority.**
- **Rulings reconciled** (re-read every "every/all" ruling against what shipped — the morning sitting record +
  #237's calls + §6d).
- **MOBILE PARITY:** the shared classifier fact compiles for iOS; the phone's pre-design face + the words-card
  sentences (F-PH-1) are VM-8's — ONE MobileSoul ledger row or "nothing mobile-visible" won't fly this time:
  write the row.
- **The author handoff** `notes/handoffs/vx-329-handoff.md` — her checklist at top: the deploy window order
  (the vx307 checklist: preflight probes → artifact 17 → pg_temp → verify → sweep 62·4·0 → BOTH Macs' installs
  behind A1 at zero instances → her first rounds), NO /Applications refresh before the deploy (the branch
  speaks marker 14), the byte-copy look (the staged copy + the NEW face if she wants to see it), ReleaseNotes-
  0.10.md for her rewrite, the release at her word, the throwaway hers to delete after the flip, the filed
  tickets by priority, VX-379's window remainder, VM-8 next on the phone.
- **Build-debris tidy** (AFTER the merge): `App/Variorum/DerivedData/vx329*` (several tags: vx329,
  vx329-stagebatch, vx329-stagebatch-ios, vx329-u3*, vx329-r1*, vx329-fixleg*, vx329-phonefix*); the walk
  evidence `~/vx329-walk/` WHOLE; the scratchpad tools (vx329-plant, scrollwheel, harnesses) die with the
  session; `/Users/Shared/vx329-rehearsal/` STAYS until her rehearsal (hers). The safety copies: prune to
  newest per the coordinator rule — but `variorum-vx329-stage-…` stays until her window completes.
- The worktree removed + the branch deleted (GitHub + local) AFTER the merge; in-flight row retire; push; memory
  run-state flipped CLOSED.

## MACHINERY (lessons + the session's tools)

- **The scratchpad** (survives compaction, dies with the session): the plant tool
  `…/scratchpad/vx329-plant/` (`mint`/`push`/`pull` arms; `plant-secrets.json` + `plant-vault.sql` beside the
  binary — DISPOSABLE throwaway fixtures); `…/scratchpad/scrollwheel` (CGEvent wheel: `scrollwheel x y ticks` —
  cliclick cannot scroll); the logs vx329-mac-suite*.log, vx329-ios-suite*.log.
- **Env files:** `~/.variorum/dev-vault-throwaway.env` (the throwaway's URL/anon/PAT/users A+B — the ref guard
  *[removed for publication]*
  Bearer PAT); `~/.variorum/dev-castle.env` (the DEV pair — never type into anything driven, never echo).
- **The dev slot is in the DEBUG container:** `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/
  Application Support/Variorum-dev/` (the `io.lduarte.Variorum/Variorum-dev` path is a STALE decoy). Aside =
  ALL top-level files, no extension filter, cmp per file both ways.
- **The walk build** lives at `App/Variorum/DerivedData/vx329` ONLY (the stale-build trap). The walk switch:
  `open -n <app> --env VARIORUM_WALK_PROJECT_URL=… --env VARIORUM_WALK_ANON_KEY=…`, then VERIFY in-process via
  `ps eww <pid>` BEFORE any credential. The A4 fence holds on the dev store (no rounds — vault acts only).
- **Suite honesty:** read ✘ lines AND `~/Library/Logs/DiagnosticReports` for host crashes; a crashed suite
  prints no ✘; an empty `-only-testing` filter exits 0 with zero tests — always confirm the "Test run with N
  tests" line. The MCP harness timing flake is load-only (green in isolation) — don't chase it.
- **Walk driving:** direct field clicks per field (Tab focus lies); secrets via env-expanded `cliclick t:`;
  window region captures only (her screen may hold personal windows); System Events `key code 53` for palettes.
- **Two writers:** never edit the plan file or any file an implementer owns while it runs; my own legs commit
  small and push immediately. The replacement-agent rule saved the r2 fix leg — honor it.
- **Linear:** the raw GraphQL API with the stored key (the MCP needs OAuth; don't). States: In Progress
  050ec6f1…, Needs Lillian ccd0623f…, In Review 4ff8af86…, Done a2bed804… (team VX 9e73282e…).
- **No `/Applications` refresh until the production marker-14 deploy lands** — the lockstep-hold rule; the
  branch's builds speak 14; the throwaway is already 14; the dev store doesn't sync.
- Commits: NO trailers (her rule overrides the harness reminder). PR body: the harness attribution lines.

## HER STANDING WINDOW (after the PR — all at her explicit go, nothing pre-authorized)

The vx307 deploy checklist VERBATIM (artifact 17 → pg_temp; sweep expects 62 OK · 4 INFO · 0 fail); BOTH Macs'
installs in one window behind A1 at zero instances (the phone deliberately refuses until VM-8 — her accepted
word); her first rounds; her byte-copy look on the new face; ReleaseNotes-0.10 at her rewrite; the release at
her word; the throwaway's deletion hers after the flip.
