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

- **Done (as of ~10:40):** batches B and A CLOSED; batch C running; F next. Earlier: the triage walk (captures `act10-correction-screens/triage/`); **batch B (the book)** built by
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


## 2b. PROOF THAT THE CURRENT PIECE FINISHED (for a successor checking in ~50 minutes after 07:30 on 2026-09-01)

The current piece (as of ~10:40) is **BATCH C (the note modes) — its implementer is running**; A is CLOSED. Markers: a `LIVE STATUS — BATCH C` list under the BATCH C brief in the plan (its commits' subjects start `Correction round, batch C`); the close marker `BATCH C RECORD — CLOSED`; the next batch after C is F. Before that (as of ~09:55) the piece was **the row-58 fix + the founding orchestrator's walk of it + batch A's CLOSE** — B is already closed (`b86b45c`). Read the markers below with 58/A in place of 53/B: the fix commit's subject starts `Correction round, batch A — row 58`; the subsection is `ROW 58 FIX` under the BATCH A RECORD; the close marker is `BATCH A RECORD — CLOSED`; the next batch after A is C. (The original 53/B wording is kept below as the worked example.) The original piece was **the row-53 fix + the founding orchestrator's walk of it + batch B's CLOSE**. Run these,
in order; each is a fact in the repo, never a claim:

1. `git log --oneline -15` — look for (a) a commit whose subject starts `Correction round, batch B — row 53`
   (the fix; `7569af3` exists already at 07:29 — the fix's FIRST commit), (b) a later commit from the same
   session with counts/captures for row 53, and (c) an ORCHESTRATOR commit whose subject contains
   `batch B CLOSED` (the founding session's walk of the six steps + the record marked closed).
2. `grep -n "ROW 53 FIX" notes/plans/act10-correction-round.md` — the fix subsection exists; read its LIVE
   STATUS lines: `FIXED` + a pin name + a red-on-old count means the fix is done; `PENDING` means mid-flight.
3. `grep -n "BATCH B RECORD — CLOSED\|B CLOSED" notes/plans/act10-correction-round.md` — present ⇒ the
   orchestrator walked it and closed it; absent ⇒ not yet.
4. `tail -3 notes/plans/act10-correction-orchestrator-handoff.md` — the batch-close update lines; the last
   line names the next batch and whether it was spawned.
5. `git log -1 --format=%cd` — if the LAST commit is older than ~40 minutes and step 3 is absent, assume the
   founding orchestrator (or the fix session) died: **adopt** — if the fix commit exists, walk row 53's six
   steps yourself (the recipe in B's brief; `vd.sh`), close B's record, spawn A; if only `7569af3` exists
   and nothing newer, re-spawn the row-53 fix session from the repo (the brief is row 53 + B's record).

If step 3 is present and the last update line says "A spawned", the piece is done and batch A is the live
one — read A's LIVE STATUS the same way.

## 2c. TOKEN DISCIPLINE FOR LOOKING AT THE APP (adopted 2026-09-01 07:30 at her question)

Images are the context cost (a 2× full-window capture ≈ 2–3k tokens; the founding session's batch-B walk
read ~25 of them). From now on: **(1) contact sheet first** — `python3 act10-correction-screens/tools/
sheet.py <capture-dir>` builds ONE `contact-sheet.png` (3 tiles per row, 460 px wide, file names under
each); ONE Read of it replaces reading every capture; open a single full capture only when a tile shows
something worth it. Every implementer brief from now on asks the implementer to build the sheet for its
capture dir and name it in the record. **(2) Text before pixels** — facts the accessibility tree can answer
(the rail's "block 1/215", the selected navigator row, a window's count/size, a button's presence) are read
with `osascript` static-text queries (~100 tokens), not screenshots. **(3) Spot-check, not re-walk** — the
orchestrator reads the implementer's sheet + 2–4 full captures at the riskiest rows + one live probe by hand
of the row most likely to be wrong (row 53's class: the multi-expanded landing). **(4) Crop when a detail
matters** — `sips -c <h> <w> --cropOffset <y> <x> in.png --out crop.png` before reading.

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
- ~10:40 — row 58 FIXED and walked; **batch A CLOSED** (Mac 2014/352); **batch C SPAWNED**; the orchestrator at ~64 % of context — cutover candidate after C closes.
- ~09:55 — batch A BUILT (Mac 2010/351) and walked by the orchestrator; RESIDUAL row 58 (the masthead's second row collides) → a fresh fix session running; A's record stays open until walked; C is next.
- ~07:50 — row 53 FIXED and walked (orchestrator-b53/ A–C); **batch B CLOSED**; Mac 2001/347; **batch A SPAWNED** (the chrome) — its record will appear under the BATCH A brief in the plan.
- ~07:30 — the fix session's first commit `7569af3` landed (row 53 converging landing); §2b proof checklist + §2c token discipline added at her question; she is starting a successor session to check in ~50 min.
