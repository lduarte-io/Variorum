# Phase 13b — Orchestrator/Architect Handoff (session cutover, 2026-07-20)

**Why this exists:** the founding orchestrator session (Sitting 9 batches
15–18 → Stage 2 close) reached ~492k tokens — the project's own recorded
~500k degradation line — and cut over at the clean Stage 2/Stage 3
boundary, per the doctrine it wrote. Everything binding lives in the repo
by construction; this document is the ROLE handoff, not the state (the
state is in the plan file and the commits).

## The kickoff prompt (author: paste this into a fresh session)

> You are the Phase 13b architect/orchestrator for Variorum, taking over
> at the Stage 2/Stage 3 boundary per
> `notes/plans/phase-13b-orchestrator-handoff.md` — read it first, in
> full. Then read `notes/plans/phase-13b-make-it-work.md` IN FULL (the
> phase plan: constitution, verdicts, ledger, stage closeouts, ladder
> records) and the tail of `notes/plans/phase-13-ui-design.md` (Sitting
> 9 batches 15–18, rulings R111–R121). Confirm the repo state with
> `git log --oneline -10` and `git status`. Then: author the Stage 3
> execution brief just-in-time from the ledger + stage closeouts (the
> standing pattern — the Stage 2 closeout's "what Stage 3 inherits" list
> is your seed), record it, and run Stage 3 through the same machinery
> (fresh Fable implementer sessions, repo-first findings, the ladder,
> class-completeness sweeps where a class recurs). Then assemble the ONE
> end checkpoint (R121). You hold the R117 architect mandate; R119/R120
> govern your posture; the standing author-only hard stops are
> untouched.

## The role (what the author granted, batches 16–18)

- **R117 architect mandate:** Fable holds architectural ownership;
  principles P-1..P-9 in the plan are binding; product-flavored calls in
  scope are DELEGATED (R120 for memos) with everything recorded for her
  end-checkpoint walk. Hard stops unchanged (invariants, schema meaning,
  dependencies, credentials, deleting her content, origin pushes).
- **All-Fable cast** (implementers, reviewers, fix passes). Fresh
  session per stage; fresh fix session when a prior one nears ~500k
  (agents' token spend appears in their completion notifications — check
  it before resuming a session).
- **R121 continuous execution:** no author gates until Stage 3 completes;
  ladders + hard stops unchanged; then the ONE end checkpoint.

## State at cutover (verify, don't trust)

- **Stages 0–2 CLOSED** — audits + synthesis; the interaction-layer
  consolidation (registry, fire-and-DO, PaneTextAuthority, one pane
  surface, one autosave); the tutorial ("the field guide", 6 chapters ·
  21 lessons) with hardened Restore/Open doors. Both ladders closed at
  round 2 with all dispositions holding.
- **Counts: Mac 542/106 · core 747/90 (byte-untouched all phase) ·
  mobile 11/4 untouched.** `/Applications/Variorum.app` refreshed from
  the final Stage 2 build (2026-07-20 15:32, post-sweep).
- **The real store:** the field guide is seeded (verified: her 15
  containers + 2 readings byte-untouched; zero journal-shaped rows — the
  Fragments bridge can never see tutorial content; backup
  `variorum-backup-2026-07-20-175038.sqlite` on disk). She is signed out
  on the real store (sync inactive, bridge active) — recorded as NOT an
  issue unless it comes up. She may run the app freely; it is safe.
- **The dev store** holds walk residue — one Restore away from pristine,
  deliberately left as a live exercise of the door.

## Stage 3 — what the brief must cover (seed list; the closeouts refine it)

- **First item: the UNLOCKED-SESSION drive** — the click/selection-gated
  coverage the locked-screen walks couldn't reach (list in the Stage 2
  closeout): ceremony sheet on-screen, drags, precise selections, save
  panels, N12's verify-unlocked, plus re-verifying the raw-ops walk-test
  NITs through real doors.
- **The ledger's open rows** (the plan's running ledger is authoritative):
  N10 (the EditorViewModel gesture-band + projection-executors ONE-SEAM
  move + the TakesViewModel P-9 decomposition), N1/N6 → T5 takes
  lifecycle completeness (unarchive faces, take-label op+face,
  lens-rename face), D1 → T6 book view (collapse/focus unification),
  D2/N8/AD-7/AD-8 → T7 geometry/spacing (margin-grid shift, comment
  clipping, wash slabs, crowdedness), N11 (palette row-stepping), N13
  (chapters → export; a CORE seam — the §12 lockstep rules and the
  schema-commit convention apply if it needs schema, which it should
  not; it needs `assembleReading`/export surgery, so treat as core-touch
  with a cold review), the T4 memo builds' Stage-3 halves, the cosmetic
  copy notes (the tutorial-open confirm copy; exportCaretBlock's tail
  phrasing), and looks-polish LAST (R111). L1 (mockup gap-list) stays
  LOW.
- Themed batches per the loop: build → soak + pins → screenshot-verify →
  point-by-point ledger update → commit → `/Applications` refresh.

## The end checkpoint (R121 — assemble after Stage 3)

Bundle: every recorded judgment call/PROVISIONAL from all stages (the
stage closeouts + dispositions enumerate them); the two memos (her
reading list); the TUTORIAL WALK in the real store; a fresh screenshot
tour; the standing asks A1 (`//` glyph), A2 (QUESTIONS #23–#27 + rest of
#28), A3 (typographic PDF). Her reactions become new sitting entries;
any fix round is the phase tail. Then Phase 12 waits on real use.

## The machinery (binding lessons, learned the hard way this phase)

1. **Repo-first, always:** ladder findings are mirrored VERBATIM into
   the plan file BEFORE (or as) they go to any fix session — a session
   death must never cost state. Same for every binding decision, same
   turn it happens.
2. **The ladder protocol:** cold reviewer runs the REVIEW_PROMPT pattern
   (see the Stage 1/2 reviewer prompts in this phase's history — pass
   verbatim, zero framing); findings → trace + agree/dispute + red-on-old
   pins revert-verified; disputes to the architect, spec wins;
   dispositions recorded cold-readable; fresh reviewer per round; round
   2 re-reviews; new HIGH at round 2 ⇒ round 3; cap at 3.
3. **Class-completeness sweeps:** when a fixed class recurs on an
   adjacent door/field (it happened twice), the fix pass owes an
   enumeration table (call sites × hosts, FIXED-or-PROVABLY-SAFE) — end
   patterns by enumeration, not by rounds.
4. **Verify agents' claims by spot-check** (the hallucination guard
   applies to sessions too): commits exist, closeouts written, one or
   two load-bearing greps. The reviewers re-run suites; you needn't.
5. **Environment traps** (full lists in the Stage 1a/1b briefs, verbatim
   binding): zsh `pipestatus` not `PIPESTATUS`; never pipe xcodebuild
   without checking it; tests from `App/Variorum/`, SUITE-level
   `-only-testing` only; a live app instance fails the Mac test runner —
   NEVER touch a `/Applications` instance (quit only path-verified
   DerivedData leftovers); drives run their own `caffeinate -d`;
   screenshots stay untracked (gitignored dirs exist); fresh hosting
   views for remounts; real-store writes only behind the rail (A1 backup
   → zero instances → fence verified).
6. **Memory:** update `variorum-phase-9-run-state` at every significant
   state change; MEMORY.md index line stays current.
7. **Commits:** per batch/stage, the standing trailer (Co-Authored-By +
   Claude-Session, per CLAUDE.md's Bash guidance in the session).
8. **Choreography caution:** any new landing kind must declare its
   landing mode in `noteMode` or it is cleared on arrival (round-scoped
   by design).

## Open author-side items (do not lose)

- A1 `//` glyph ratification · A2 QUESTIONS #23–#27 + rest of #28 · A3
  typographic-PDF disposition · the R24 paged-strip wording change + the
  merge-joins-upward call (both flagged for her walk) · the N9
  landing-focus behavior change (first article pane live at board open)
  · the unexplained clean exit of her real-store app (2026-07-20 ~03:25,
  one data point, no crash record — becomes a defect only if it recurs)
  · the two blank utility windows at launch (unlocked-drive look owed).
