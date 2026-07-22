# Phase 13b — Stage 4 EXECUTION orchestrator handoff (cutover after the kickoff sitting + batch 4G, 2026-07-22)

**Why this exists:** the Stage 4 kickoff sitting (author-attended,
2026-07-21/22) ran long and interactive — the sitting session reached
~490k tokens with the brief authored but implementation barely begun;
the author directed the cutover ("finish 4G all the way through, but
then I want you to stop and pause"). Same form as
`phase-13b-stage4-handoff.md`, the document that session was kicked off
from. Everything binding lives in the repo by construction; this is the
ROLE handoff — the state is in the plan file and the commits.

## The kickoff prompt (author: paste this into a fresh session)

> You are the Phase 13b Stage 4 EXECUTION orchestrator/architect for
> Variorum, taking over after the author-attended kickoff sitting per
> `notes/plans/phase-13b-stage4-orchestrator-handoff.md` — read it
> first, in full. Then read `notes/plans/phase-13b-make-it-work.md` IN
> FULL — the constitution, the running ledger, the "Stage 4 kickoff
> sitting" record (rulings S4-1…S4-33 — BINDING), **the "Stage 4
> execution brief" at the file's end (your governing document)**, and
> the "Batch 4G record". Then read BOTH memos WITH their RULED addenda
> (`phase-13b-memo-w-ceremony.md`, `phase-13b-memo-merge.md` — the
> rulings sections make them build-ready; build to them exactly).
> Confirm the repo state with `git log --oneline -10` and `git status`.
> Run the remaining batches **4A → 4B → 4C → 4D → 4E → 4F** per the
> brief through the standing machinery — a FRESH Fable implementer
> session per batch, repo-first records, then ONE ladder over the
> combined diff, then the closing PROPOSE-ONLY sweep (everything it
> surfaces comes to me). You hold the R117 architect mandate; the
> S4 rulings and the ruled memos govern the designs — do not re-open
> them; the standing author-only hard stops are untouched. I am in
> ORGANIC USE of the app: my reports are live findings — record
> verbatim, route to the owning batch, answer point-by-point, same
> turn. My scheduled touchpoints: the 4F mirror-deploy go-ahead
> (v1_12) and the closing sweep; ask me nothing else that the record
> already answers.

## The role (as amended through the kickoff sitting)

- **R117 architect mandate** unchanged; P-1…P-9 bind. **The S4 rulings
  (S4-1…S4-33) and the two RULED memo addenda are settled design** —
  the execution orchestrator builds them, never re-litigates them;
  genuinely NEW ambiguities get PROVISIONAL-and-continue (R119/R121)
  or, where product-flavored and gating, a live question to the author
  (she is present in daily life, not at a sitting).
- **All-Fable cast**; fresh implementer session per batch; fix sessions
  fresh when a prior nears ~500k. **Agents die at her API limits** —
  implementers mark unverified claims PENDING; the orchestrator
  verifies a dead session's claims before committing its record (the
  3C annotation is the worked example). **The orchestrator itself must
  stay lean** (this cutover's lesson): delegate reading-heavy work to
  implementers, keep records tight, and hand off before ~500k.
- **The judgment-call walk is DEFERRED-IN-PLACE** (S4-32): every
  recorded call stands addressable; nothing is ratified-by-silence;
  her organic use is the active review channel. Do not re-ask them.
- **The closing sweep is PROPOSE-ONLY** (her standing words: "it's all
  a taste question").
- **The 4F deploy gate:** migration v1_12's mirror deploy executes
  ONLY on her explicit go-ahead at that batch (the R53 precedent;
  mirror → Mac only — the phone stays uninstalled).

## State at cutover (verify, don't trust)

- **Counts:** Mac **562/112** · core **762/92** · mobile **11/4**
  (pre-4G; the 4G record updates the Mac arithmetic if pins were
  added — read it).
- **Commits:** the kickoff sitting is `0830d7e` → `be61d8b` (parts 1–9
  + the brief); 4G's commits follow — `git log` is the truth.
- **`/Applications` carries the full ladder-fix build** (refreshed at
  the sitting, 2026-07-21 23:16 MDT); the REAL store carries the
  FRESH field guide (re-seeded via the product door behind the A1
  rail — backup `variorum-backup-2026-07-22-051433.sqlite`); her
  15+2-era content untouched, verified.
- **Her app may be RUNNING at any time** — she is in organic daily
  use. Live-instance rules bind (by STORE, not path; tight pgrep);
  **4G's whole purpose is that Mac suites now run beside her live
  app** — but Release builds / `/Applications` refreshes still need
  zero-instance windows.
- **BATCH 4G:** ⟦FINALIZED AT CUTOVER — see the "Batch 4G record" in
  the plan file for the design, the proof-run status (which of the
  two runs executed, which is PENDING), and the orchestrator's
  verification note. Any PENDING run is the NEXT session's first
  obligation before it relies on the unlock.⟧

## What the kickoff sitting settled (pointers — the plan file's record is the truth)

- **Environment acts discharged** (backup · refresh · re-seed; she
  pressed Replace herself).
- **S4-1…S4-33** — the full rulings record (compare/outline/canvas/
  books direction, the Takes trap, drag handles, default-view
  reversal, one_block face, scrap tagging, N20 closed, the flagged
  items, QUESTIONS #23–#28 all ANSWERED with statuses updated in
  `notes/QUESTIONS.md`).
- **Both memo addenda RULED** (all nine tradeoffs; rulings appended to
  the memos). The merge pairing extension is HER CANON RULING —
  AppSpec §9 + OverallModel §7 gain the delta at stage close, not
  before.
- **Ledger rows N28–N41** added/updated this sitting; N20/N26/N16/N17
  arcs closed or routed. **Apple Notes import** joined the master
  plan's phase table (unslotted, quarantine instinct — do not plan
  over it).
- **Deferrals executed:** the uniform-page book view and N38
  (smart→smart+curated) → Stage 5, each with its detailed
  brief/design memo OWED AS A 4F DELIVERABLE (her condition);
  N41 (inline-comments airiness) deferred beyond Stage 4, closeout
  names its owner.

## The machinery (binding lessons — the founding eight + Stage 3's + this sitting's)

1. **Repo-first, always** — findings/decisions land in the plan file
   the same turn, BEFORE any fix session sees them.
2. **The ladder protocol** — REVIEW_PROMPT.md verbatim, zero framing;
   fresh reviewer per round; trace + red-on-old revert-verified pins;
   spec wins; cap 3 rounds; the hallucination guard's pin-first
   conditional order for speculative findings.
3. **Class-completeness sweeps** when a fixed class recurs adjacent —
   enumerate trigger INPUTS, not just consumers.
4. **Verify agents' claims by spot-check**; verify a DEAD session's
   claims before committing its record.
5. **Environment traps (verbatim-binding):** instance checks use
   `pgrep -fl 'Variorum.app/Contents/MacOS'` (bare `pgrep -f Variorum`
   self-matches); treat real-store instances BY STORE not path; NEVER
   quit/kill one; `xcodebuild build-for-testing` compiles app+tests
   without the runner; Mac tests from `App/Variorum/`, SUITE-level
   `-only-testing` only, confirm the "Test run with N tests" line; zsh
   `pipestatus` (lowercase); no Release builds while a real-store
   instance lives; drives need unlocked + author-free + own
   `caffeinate -d`; backup filenames are UTC; a bare NSWindow
   auto-assigns first responder on order-front; fresh hosting views
   for remounts; async-poll (never sync RunLoop pumping) drains settle
   hops; screenshots stay in gitignored dirs.
6. **This sitting's additions:** the real store lives in the SANDBOX
   CONTAINER — `~/Library/Containers/io.lduarte.Variorum/Data/Library/
   Application Support/Variorum/` (NOT ~/Library/Application Support);
   osascript System Events menu clicks WORK from this host
   (accessibility granted) — `open -a` + menu AXPress is a sanctioned
   light-touch drive path; the author answers question-tool batches
   fast and well — use it for her rulings, keep each batch ≤4.
7. **Memory:** update `variorum-phase-9-run-state` at every
   significant state change.
8. **Commits:** per batch/stage with the standing trailer
   (`Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`).
9. **The author is a live finding source** — verbatim-faithful,
   point-by-point, same turn, routed to owning batches; every item
   answered (her standing escalation rule).

## Open author-side items (do not lose)

- The **4F v1_12 mirror-deploy go-ahead** (hers, at that batch).
- The **closing propose-only sweep** (hers to consider, item by item).
- The **deferred-in-place judgment-call walk** (hers whenever wanted;
  never re-asked unprompted).
- Her **organic-use findings** — the active channel all stage.
- Standing residuals: the Fragments consent-page LAN serving until
  stargazing.tech ships; Phase 12 after 13b + the real-use window;
  the phone reinstall stays Phase 15's; Apple Notes import unslotted
  on the roadmap.
