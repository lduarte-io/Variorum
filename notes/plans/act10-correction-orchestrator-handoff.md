# The Act 10 Correction Round — ORCHESTRATOR handoff (the two-document form; kept current at every batch close)

*Written 2026-09-01 ~06:50 by the founding orchestrator at 57 % of its context, per the skill's cutover rule
and R-cor-8. If you are the successor: everything below is VERIFY-NOT-TRUST — `git log`, the plan file's
records and the captures are the truth; this file is the map.*

## 1. The role, as amended

You are the architect/orchestrator of **the Act 10 correction round** (`/architect-phase`; the skill file
`.claude/skills/architect-phase/SKILL.md` binds; CLAUDE.md wins on conflict). The ONE record is
`notes/plans/act10-correction-round.md` — read it IN FULL first (§0 the cause; §1 her rulings R-cor-1…8;
§2 the constitution + the round's rules C-1…C-7; §3 the ledger; §4 the batches; §5 process; §6 environment;
§7 the morning bundle; §7b the closeout obligations; §8 the records and the batch BRIEFS A/B/C/F/D/E). Then
`notes/author-reports/2026-09-01-post-act10-ui-report.md` (her words), the memo
`notes/plans/act10-correction-memo-lenses-compare.md`, and `notes/handoffs/act10-correction-handoff.md`
(hers — you fill its PENDING slots at the close). **She is asleep and authorized the run (R-cor-8): choose,
record in §7, continue; never stop for a question.**

The cast: all Fable; ONE code agent at a time (a fresh `general-purpose` Agent per batch, briefed ONLY by
the plan file's named section — the spawn prompts used so far are short pointers: "read the plan in full,
your brief is section X, the rules, the trailer, push after each commit, synchronous waits, never
/Applications, your final message is a pointer to your record"). You write no code while a batch runs and
you do NOT drive the dev window while an implementer might (clicks collide).

## 2. State at cutover (verify against git before trusting)

- **Done:** the triage walk (captures `act10-correction-screens/triage/`); **batch B (the book)** built by
  its implementer (commits `be32fa7`…`1a6ceaf`) and WALKED by the orchestrator (`orchestrator-b/`): the
  hang is gone, rows 7/8/13/14/22/23/38-book/40/45/47 FIXED-walked; **row 53 (MAJOR — multi-expanded
  mis-landing) is being fixed by a fresh fix session** (spawned ~06:45). B's record is NOT closed until
  that fix is walked (six steps in row 53; the `vd.sh` recipe in B's brief).
- **Not started:** A (chrome) → C (note modes, R-cor-5/7) → F (recovery family) → D (Compare/Lenses
  mechanical) → E (library panel) → the ladder (`notes/REVIEW_PROMPT.md` verbatim, fresh reviewer per
  round, cap 3) → the orchestrator's full acceptance walk → the Release build + `/Applications` refresh at
  a zero-instance window behind the A1 backup → the tutorial re-seed of her real store (Help ▸ Restore
  Tutorial… on the refreshed install; if her store needs her unlock, the handoff's checklist carries the
  act) → the handoff filled → memory → stop.
- **Her app is CLOSED** (she quit it for the run); the dev-store Debug build runs from DerivedData with
  bundle `io.lduarte.Variorum.debug`; both books are seeded there (the field guide via Help ▸ Restore
  Tutorial…, Sherlock by default).

## 3. Machinery lessons (proven this run)

- **Clicks:** System Events' `click at` never reached the SwiftUI window; the compiled CoreGraphics
  poster `act10-correction-screens/tools/click` does (`vd.sh click x y` in window-relative POINTS; the
  helper activates the app first — an inactive app swallows the activating click). Keys/menus/bounds via
  System Events work. Zoom = Window ▸ Zoom (the green button is Full Screen). The dev app may restore TWO
  windows at launch — close one. Park the cursor on the title bar before a capture (a cursor at the
  screen's bottom edge reveals the Dock into the shot).
- **Captures are 2×**: window point = displayed pixel × (window width ÷ displayed width). Read PNGs with the
  Read tool sparingly — they are the context cost; walk by spot-check (3–4 captures at the riskiest rows)
  and let the implementer's record carry the full walk.
- **Implementer sessions cannot be resumed after they end** ("No transcript found") — re-spawn fresh from
  the repo; that is why every brief and record lives in the plan file.
- **The dev build livelocked once** (row 44, before the fix): if System Events reports zero windows and
  `ps` shows ~100 % CPU, `sample <pid> 3` then `kill -9` ONLY the DerivedData process and `open -n` it again.
- **Resiliency:** `notes/SessionResiliencyProtocol.md` — commit per piece, LIVE STATUS from the first
  commit, push after each, synchronous waits; a dead session's claims are verified by spot-check.

## 4. Open author items (already in the plan's §7; nothing new to add here)

R-cor-3's PROVISIONAL library-panel reading · row 26's panel order · Read's switch memory · the memo's
eight rulings · row 52 (underscore emphasis vocabulary) · any scalpel revert (none so far; her lean is none).

## 5. PASTE-READY KICKOFF PROMPT FOR THE SUCCESSOR ORCHESTRATOR

> You are the successor architect/orchestrator of Variorum's **Act 10 correction round**, taking over from
> the founding session at a clean seam. Invoke the `architect-phase` skill. Read IN FULL, in this order:
> `notes/plans/act10-correction-orchestrator-handoff.md` (this file — the state section tells you which
> batch is next; VERIFY it against `git log --oneline -30` and the plan's records before acting),
> `notes/plans/act10-correction-round.md` (the whole file), `notes/author-reports/2026-09-01-post-act10-ui-
> report.md`, `notes/plans/act10-correction-memo-lenses-compare.md`, `notes/handoffs/act10-correction-
> handoff.md`, `CLAUDE.md`, `notes/SessionResiliencyProtocol.md`. The author is asleep and authorized the
> run (R-cor-8): choose, record every choice in the plan's §7, never stop for a question. Continue the batch
> loop exactly as the plan's §4/§5 say — one fresh Fable implementer per batch, briefed by the plan's named
> section; walk each batch by spot-check before closing its record; then the ladder, your full acceptance
> walk, the Release build + `/Applications` refresh at a zero-instance window behind the A1 backup, the
> tutorial re-seed, the author handoff filled (her walk at the top), memory, the closeout obligations in
> §7b, push, stop. Keep THIS file current at every batch close and write your own cutover here if you
> approach your limit.

---

## Batch-close updates (append one line per close; newest last)

- ~06:50 — cutover document written; B walked; row 53 fix session running; A next.
