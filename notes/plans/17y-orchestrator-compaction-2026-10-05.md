# 17y — the orchestrator's COMPACTION DOCUMENT (2026-10-05 ~03:40, at 512k context; her call: compaction instead of a handoff — SAME session continues)

> **Who reads this:** the 17y Fable orchestrator itself, post-compaction. Read this file FIRST
> and IN FULL, then the files its NEXT ACTS name. Everything binding is repo-first already;
> this file carries the pointers plus the TRANSCRIPT-ONLY facts (live agent handles, in-flight
> state, machinery lessons). Verify, never trust: spot-check every state claim against git.

## 1. ROLE AND STANDING FRAME

You are the Fable orchestrator for **17y, THE 13i FAMILY FIX PASS** (`/architect-phase`; a
standing-fixes ENTRY, not a master-plan phase). The binding item list: the 17y row in
`notes/plans/phase-17-standing-fixes.md` (items a–q) **PLUS items (r) and (s)** minted at her
live sitting (`notes/plans/17y-sitting-rulings-2026-10-05.md` — READ THAT FILE WHOLE, it is
the night's rulings record R-17y-1…9 + addenda and binds over everything older where they
touch). The kickoff message + execution order sit at the 17 file's tail; the **17y RUN RECORD
— LIVE STATUS** section there is the per-batch state. HER STANDING FRAME, verbatim: "quality
is always paramount, dates are always provisional." HER PROCESS RULE: every cold review is a
FRESH reviewer subagent; the orchestrator NEVER hand-reviews (memory:
orchestrator-never-hand-reviews).

## 2. THE TREE (load-bearing)

- Work ONLY in the worktree **`~/dev/variorum-17y`**, branch `main`, push `origin main` after
  every commit, **pathspec-limited commits always** (an implementer may hold uncommitted work
  in this same worktree — `git add -A` is forbidden to you).
- **NEVER touch `~/dev/variorum`**: the strings-workbook session (`variorum-65`, reachable at
  `uds:/tmp/cc-socks/83468.sock`) holds it on `tools/strings-workbook`. Its real-store mint is
  DONE (hold released ~02:0x). I warned it that `git checkout main` there will refuse while
  this worktree holds main; if it needs exclusive main before our close, it messages us.
- DerivedData: `App/Variorum/DerivedData/17y*` in the worktree (swept at close). Commits carry
  NO attribution trailers (her standing rule). The worktree is REMOVED at the pass's close.

## 3. STATE AT COMPACTION (verify against `git log --oneline ba76a936..origin/main`)

- **B0 ✓ CLOSED** (`ba76a936`): 19e + 19g, reviews waived, pins green, 19 ledger rows flipped.
- **B-SEED ✓ CLOSED** (implementer commits `b9ee80d5..6f4ed4fd`; ladder `bd324f15` — ONE
  round, fable-reviewer, **0/0/0/2 NIT both record-only**, dispositions written in the RUN
  RECORD). The mechanism + fix: the field guide is born with a fresh store
  (`TutorialSeeder.seedAtBirth` via `LaunchFurniture.swift`). Her glance items: QUESTIONS
  #183(a)–(e), none gating.
- **B2 — RUNNING** (spawned ~03:00): items (a)(b)(e)(m)(n)(p), brief = "17y B2 BRIEF" in the
  17 file; the implementer appends "17y B2 RECORD" after it. **Its agent handle:
  `a4a6e7cde780cfe71`** (SendMessage for the cross-model findings exchange if the ladder needs
  one; its hand-back report may arrive during/right after compaction — if a report seems
  missing, check ReadNotifications + `git log` + ListAgents before assuming anything).
  At its close: VERIFY (commits/fences/record), then spawn the cold review — `opus-reviewer`
  unless the implementer flagged the editor seam (item (n) might) ⇒ then `fable-reviewer`.
  Findings → implementer verbatim (SendMessage to the handle) → reviewer makes the final call
  and implements its confirmed fixes itself (the cross-model flow) where Fable reviews; same-
  model flow (Opus/Opus): you arbitrate against the spec.
- **B3 — NOT SPAWNED.** Brief: **`notes/plans/17y-b3-brief.md`** (standalone file, committed —
  items (c)(d)(g)(o)(h)(i)(f)(l)(r)(s), her rulings folded; spawn a fresh `opus-implementer`
  briefed from THAT file + the rulings file; it appends its record to the 17 file as "17y B3
  RECORD"). Gate 1 is PRE-ANSWERED (R-17y-1…4) — no sitting gates B3; it closes on your
  verification + its ladder.
- **B-DEDUPE — NOT STARTED** (after B3, before B1; YOU implement the `Sync/` halves — the
  standing rider; a FRESH `fable-reviewer` cold-reviews your diff, zero framing). Scope as
  ruled + trimmed: the FIELD GUIDE dedupe-facts entry (Mac-side wiring; no phone collision —
  the phone's guide is "the pocket guide"; its own facts entry is a recorded MOBILE PARITY
  row, never built here) · the SEEDED-GATHERING keeper (classics · starred notes · Quicknotes;
  judge rules by tag PATH, re-point the keeper's rule to the live tag, explicit outbox rows)
  · the QUICKNOTE fold (note grain: reserved title + content hash) · **JEKYLL LEAVES THE
  DEFAULT SEED (R-17y-8)** — launch seeds a subset excluding it; existing stores never
  retrofitted; Help ▸ Restore keeps minting; ONE lesson sentence per her intake (re-seed
  consequence recorded); the Jekyll FOLD is DROPPED (no fresh copies exist to fold — the
  scripted-history-allowance design note in the rulings file is the why-not record).
  **IMPORTANT: your SyncSpec/postmortem/classifier reading predates compaction — RE-READ
  before writing a line:** SyncSpec §7 whole + `notes/sync-postmortem-fragments.md` +
  `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift` + the Welcome keeper in `Repairs.swift`
  + `SampleLibrarySeeder.swift`'s facts/Book grammar. Write the short design memo
  (`notes/plans/17y-bdedupe-design-memo.md`) BEFORE building; convergence suites mandatory;
  zero schema (marker stays 12); SyncSpec §7 gains the keeper paragraph as the canon delta at
  close.
- **B1 — LAST.** Brief: **`notes/plans/17y-b1-brief.md`** (standalone). (j) trace-first,
  TK2 §2–3 read required (re-read — pre-compaction reading is gone); (k) keyset pagination,
  never a raised cap; **FABLE review mandatory**; the close is USE-SHAPED: her live scroll
  walk + her feel + her word. The entry closes ONLY there.

## 4. THE CLOSE (after B1, at her word)

Dispositions per item in the 17y row cell · the row cell gains (r)(s) and the B-SEED/B2/…
close notes (fold from the rulings file) · KnownIssues: the B-DEDUPE row closes with its slice
· QUESTIONS PROVISIONALs numbered · MOBILE PARITY line (the pocket-guide facts row + anything
batches flagged) · the `/Applications` refresh at a ZERO-INSTANCE window (A1 safety copy →
Release build → copy → codesign verify) · **0.9.2 (R-17y-6): draft the release notes →
PRESENT to her → her APPROVAL → only then the release run** (the R-13r-15 road; runbook in
`~/dev/stargazing.tech`'s notes/variorum-releases.md; no repo commits mid-release-run; zone
cache purges are HERS) · the DerivedData sweep · the worktree removed after its last push ·
memory updated · hard stop. Her remaining hands-on: the B1 scroll walk + drag spot-check, the
0.9.2 notes approval, the entry-close word, her Monday new-Mac install (post-0.9.2 or carried
DMG = guide-complete + duplicate-free).

## 5. MACHINERY LESSONS (this run's own)

- macOS screenshot filenames carry a NARROW NO-BREAK SPACE before AM/PM — copy by glob.
- Captures land under `notes/plans/17y-screens/` (git add -f where ignored; `b-seed/` is
  gitignored, the two loose defect captures are committed).
- The 17 file is SHARED with the running implementer (it appends records): your edits there
  only at seams, pathspec-limited; mid-flight rulings go to the rulings file instead.
- Monitor pattern: the harness re-invokes you on agent completion — never poll, never read the
  task output files. Peer messages: reply to the exact `from=` address.
- Her question-tool appetite is high and fast — bring real decisions as single tight batches,
  recommended option first; record her answers verbatim-faithful SAME TURN, repo-first.

## 6. MEMORY

`variorum-phase-9-run-state` (auto-memory, git-synced) is current to ~03:30; update it at
every significant state change. The new standing memory: `orchestrator-never-hand-reviews`.
