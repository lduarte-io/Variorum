# The Act 10 Correction Round — ORCHESTRATOR handoff (the two-document form; kept current at every batch close)

*Written 2026-09-01 ~06:50 by the founding orchestrator at 57 % of its context, per the skill's cutover rule
and R-cor-8. If you are the successor: everything below is VERIFY-NOT-TRUST — `git log`, the plan file's
records and the captures are the truth; this file is the map.*


## 0. READ THIS FIRST — why this round exists, and how the work must FEEL (written at her instruction; this section outranks convenience)

**Her original message (2026-09-01, ~04:00, after using the freshly-installed pre-13u build; the verbatim
text + the fifteen-image manifest is `notes/author-reports/2026-09-01-post-act10-ui-report.md` §1 — read it
whole, it is the round's source):** she opened the app after the pre-13u round's Act 10 UI work and found
it had gone *"from feeling pretty crisp, working well, no obvious bugs"* to *"the app feeling like a
vibecoded mess"* — her words: *"I'm honestly a bit sad and disappointed… I'm quite unhappy about it"*, and
she was prepared to **revert every UI change to a branch** rather than live with it (*"that's the level of
displeasure I have at seeing what's happened to this app"*). She blamed herself for overloading the prior
phase; the record's honest answer (§0 of the plan) is that the calls were the architect's. **The state of
despair is the context for every taste call you make:** this session exists to restore the app's quality
feeling — *"I just want my app to go back to feeling beautiful and well tested"* — while KEEPING the new
utility (her words: *"I think the ideas are mostly good"*, and later: *"i'd honestly RATHER not retire any
of the new changes"*).

**What happened during wave 2c (the cause, owned):** the pre-13u round's Act 10 wave 2c built FIVE
phase-sized surfaces in one implementer wave — Index (635 lines), Read (385), the Blocks workbench (811),
the book Index (574), plus rewrites of BookView/BlockTOCView/Compare/Lenses — across three chained
sessions, one of which died mid-run. The plan had the escape hatch ("item 18 defers WHOLE to 13u2 if 2c
cannot hold it") and the verdict came back "nothing defers". Verification was STRUCTURAL, not experiential:
"mount smokes", pins, a partial screenshot set (the record itself admits no Compare/Lenses capture exists),
and a review ladder whose every BLOCKER/MAJOR was in `Sync/` — **nobody clicked a chapter in the Sherlock
book on the running build**, and the install was refreshed to `/Applications` before she or anyone had used
the result. Two rulings also shipped half-delivered without the residue being flagged (W8-3's glass pane;
Index built read-only against "a new writing mode"). The round's rules C-1…C-7 exist so that cannot recur:
ONE surface per implementer session; **the acceptance gate is USE, never mount**; no install without a
walk; a ruling delivered whole or its residue is the record's first line.

**The bar (hers, verbatim, binding):** *"QUALITY is what this phase most needs to emphasize… the point is a
premium feeling app."* · *"I'm completely completely fine with this phase taking a long time, being a good
amount of work… I just want my app to go back to feeling beautiful and well tested."* · calm chrome
(*"word count shouldn't just be thrown in everywhere just because"*). **Take your time. Alignment is a
defect. A click that does nothing is a defect. A panel past the window's edge is a defect. A second of lag
is a defect.** Reduced bugginess is part of the taste bar — the round PULLED IN 13u2's item 17 at her word
(row 38: clicking in a read surface must land the editing surface at THAT location, never the top — built
once as `Shared/LandingTarget.swift`, the book half in batch B, the note half in batch C's `edit·read`).

**How the founding orchestrator personally validated results — DO THE SAME (this found real defects twice
after implementers honestly reported "done"):** every batch's record is only MARKED CLOSED after the
orchestrator's own hands-on walk of the running dev-store Debug build. Batch B's walk found **row 53** (the
multi-expanded landing missing — a MAJOR the implementer's own six reproduction steps had passed) and batch
A's walk found **row 58** (the masthead's second row colliding on a five-tag note). **An implementer's
"done" is a claim; the walk is the verification.** The method (§2c has the token discipline): drive the app
with `notes/plans/act10-correction-screens/tools/vd.sh` — clicks go through the compiled CoreGraphics
poster beside it (System Events' `click at` never reaches this SwiftUI window; `vd.sh click x y` takes
WINDOW-RELATIVE POINTS and activates the app first); captures are 2× PNGs (window point = displayed pixel ×
window-width ÷ displayed-width); read the implementer's CONTACT SHEET first (`tools/sheet.py <dir>` — one
image for a whole capture directory), then 2–4 full captures at the riskiest rows, then ONE live probe by
hand of the row most likely to be wrong; crop with `sips -c <h> <w> --cropOffset <y> <x>` when a detail
matters (a crop costs a few hundred tokens; a full capture ~2.5k); facts the AX tree can answer (window
count, a row's selection, "block 1/215") are read with `osascript`, not pixels. Aim clicks at a control's
FRAME — small glyphs miss (the founding session once removed a tag by hitting a card's × two points from
the `#`; it repaired the store through the product door and recorded the hit-target NIT as row 59).

## 0b. HER 26 ORIGINAL COMPLAINTS — where each stands at the founding session's wrap (the completion record; rows are the plan's ledger)

| # | Her complaint (short) | Rows | State at wrap |
|---|---|---|---|
| 1 | The library note peek — a preview, not facts; the panel's design | 1 · 33 · 34 | **OPEN → batch E** (R-cor-3's ruled shape: a simple READ preview, one Open door landing at the saved block, books show their outline, the boundary holds inactive) |
| 2 | The liquid-glass left edge | 2 | **FIXED + walked** (A: `ShellSplit` — the glass pane gone; W8-3 delivered whole) |
| 3 | Tabs under the modes; spacing compressed | 3 | **FIXED + walked** (A: her "tabs" were the OPEN STRIP's 21-pt rows — now one 30-pt pitch, the strip directly under the rail; compress only under a measured height) |
| 4 | Read: no centered title · no horizontal pages · contents cut off | 4 · 5 · 6 | **FIXED + walked** (A: the title centers in every mode; C: `continuous · pages` reuses the book's engine; the cut-off contents column retired for the `▸ 01` column) |
| 5 | Book: click used to navigate; now expand-first | 7 · 47 | **FIXED + walked** (B: a note-row click reveals and lands at the first block; ▸ is the separate expand) |
| 6 | Sherlock: chapters + notes named the same | 8 | **FIXED + walked** (B: the duplicate line collapses when names match; the field guide untouched) |
| 7 | Outline click: berserk scroll, landed at the end | 9 · 12 · 44 · 53 | **FIXED + walked twice** (B: the hang was a SwiftUI lazy-placement livelock — killed; row 53's second fix made landings exact with MULTIPLE 9k-word stories expanded — the orchestrator's six-step repro lands at the top every time) |
| 8 | Tags misaligned from the text | 10 | **FIXED + walked** (A, geometry pin) |
| 9 | "book" misaligned | 11 | **FIXED + walked** (A) |
| 10 | Outline scrolling completely broken | 12 | **FIXED** (row 7's mechanism) |
| 11 | The gutter crowded, low value | 13 | **FIXED + walked** (B: the invented facts string dropped; the takes fact kept; C-6) |
| 12 | Chapters don't even TRY to navigate | 14 | **FIXED + walked** (B: navigator chapter clicks survive expansion; the body headings became doors) |
| 13 | Tag icon AND "+ tag" — sloppy; her slide-out field | 15 · 55 · 58 · 59 | **FIXED + walked** (A + its fix session: the `#` is THE door, an inline field with the cursor; "+ tag" and the masthead fold retired — K12 superseded there; row 58's second-row collision fixed — the path chip leads, the cluster wraps). **Residual: row 59 (NIT, the `#` hit target) → the ladder's fix round** |
| 14 | Compare misaligned; "This note" shows nothing | 16 · 17 · 46 | **OPEN → batch D** (mechanical only: the anchor renders whole, one placement per act, the alignment; the DESIGN is the memo — see #17) |
| 15 | Blocks: draggable divider | 18 | **FIXED** (C: draggable, remembered) |
| 16 | Lenses title weirdly aligned | 19 | **FIXED + walked** (A's masthead fix, pinned across all modes) |
| 17 | "The use of lenses is still a bit unclear" | 20 · 41 | **RULED R-cor-6** — the design memo is WRITTEN (`notes/plans/act10-correction-memo-lenses-compare.md`; her eight rulings in its §7 await her); **the build is its own phase at her word — NOT this round's** |
| 18 | Read: horizontal option · outline not great · toggle loved | 5 · 21 | **FIXED** (C; the toggle byte-preserved) |
| 19 | Book Index looks good but can't click into it | 22 | **FIXED + walked** (B: edits in place through the one authority; the book's Read stays read-only) |
| 20 | The intermittent note-title click error | 23 | **FIXED** (B — it WAS row 47's mechanism: the reveal only worked for an already-realized card) |
| 21 | "this note" modes appear jarringly | 24 | **HALF-FIXED:** the rail fades (A); **the panel half → batch E** |
| 22 | Blocks laggy; "text above the details" | 25 · 26 | **FIXED** (C: the 0.5-s double-click hold became a 1.5-ms row click, measured; the panel is facts-first — **PROVISIONAL, her walk can flip the order**) |
| 23 | Block History opens wrong · savepoints vs lineage unclear · persists across modes | 27 · 28 · 29 | **FIXED + walked** (C: one right region, scoped to its mode; F: the pane's four sections as calm sections with one meaning line each — "Came from" is the lineage) |
| 24 | Index uneditable — "literally a new writing mode" | 30 · 42 | **FIXED + walked** (C, R-cor-5/7: ONE rail tab READ with `edit · read`, default `edit` — the editable index surface; seven modes, ⌘1–⌘7) |
| 25 | The Index dropdown awkwardly sized | 31 | **FIXED** (C: the tiny editing card RETIRED — the pane is the editor; the column's type stepped up) |
| 26 | "Were all these changes noted?" | 32 | **ANSWERED by the record** (every wave was recorded; the gap was USE, not records) — one of the two she dispositioned herself |
| — | Reading time ("how random is it?") | 37 | **Her own disposition:** `words ÷ 200`, a fixed convention; stays in Read at her word — the second she dispositioned herself |

Beyond the 26: rows 38/49 (the pulled-in 13u item 17 — read-click lands the editor at THAT block, both
halves FIXED), 39 (ONE current block follows across modes, FIXED + walked), 40/45 (the book's side card and
card previews, FIXED), 55–68 (the walks' and F's own finds — see the ledger; F's six all FIXED), 52/57 and
the §7 PROVISIONALs await HER.

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

- **Done (final, ~17:20):** batches B, A, C, F CLOSED and orchestrator-walked; the Lenses+Compare memo written; the canon deltas drafted (§7c of the plan); the ladder text ready (§7d). **Remaining — the successor's:** D → E → ladder + iOS build → full walk → Release install + re-seed → the author handoff → QUESTIONS #88 → memory. Earlier: the triage walk (captures `act10-correction-screens/triage/`); **batch B (the book)** built by
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
- **Her real store's at-open mode is `biometric`** (read 16:10 MDT from `defaults read io.lduarte.Variorum` → `variorum.protection.Variorum.mode = biometric`; the store itself at `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/variorum.sqlite` + shm/wal, ciphertext) — a DEMANDED mode: no session can open the refreshed install headlessly, so **the tutorial re-seed (§7b item 8) is HER one in-app act in the morning** (Help ▸ Restore Tutorial… on the refreshed `/Applications` build); the author handoff's checklist item 4 carries it. The A1 backup is unaffected (the app closed ⇒ the WAL quiescent; the whole store folder copied to `~/dev/variorum-store-backups/<name>-<UTC>/`, the pre-13u form).
- **Her app is CLOSED** (she quit it for the run); the dev-store Debug build runs from DerivedData with
  bundle `io.lduarte.Variorum.debug`; both books are seeded there (the field guide via Help ▸ Restore
  Tutorial…, Sherlock by default).


## 2b. PROOF THAT THE CURRENT PIECE FINISHED (for a successor checking in ~50 minutes after 07:30 on 2026-09-01)

**LIVE PIECE (the successor orchestrator, Fable 5.1, from 16:00 MDT 2026-09-01): BATCH D.** Markers: a
`LIVE STATUS — BATCH D` list under the BATCH D brief in the plan (commit subjects start `Correction round, batch
D`); the close marker `BATCH D RECORD — CLOSED`; after D comes E (`LIVE STATUS — BATCH E` / `BATCH E RECORD —
CLOSED`), then **G — residuals and width, ADDED at R-cor-10** (`LIVE STATUS — BATCH G` / `BATCH G RECORD — CLOSED`), then the ladder (`LADDER ROUND 1/2/3` sections), the full walk, the install (§7b items 8–9), the
author handoff. The machine's clock is the reference from here (the founding records' times ran ~1.5 h ahead of
it — F's "~17:20" close is the commit stamped 15:43 MDT).

**THE FOUNDING SESSION HAS WRAPPED (R-cor-9). Batches B, A, C and F are CLOSED — you start at BATCH D** (the plan's brief; then E; then the ladder §7d + the owed iOS build; the full acceptance walk; the install §7b items 8–9; the tutorial re-seed; the author handoff `notes/handoffs/act10-correction-handoff.md` filled — its PENDING slots are yours; QUESTIONS #88 minted from the plan's §7; memory; stop). Counts at the wrap: **Mac 2032 tests / 356 suites · core 1524/165 · spine 71/10 · zero `Sync/` · zero schema · marker 7.** The dev build runs from DerivedData; her real-store app is CLOSED and `/Applications` is UNTOUCHED — the refresh is yours, at a zero-instance window, behind the A1 backup. Historical: the piece before the wrap was BATCH F. Markers: `LIVE STATUS — BATCH F` under the BATCH F brief; the close marker `BATCH F RECORD — CLOSED`; after F comes D (mechanical), then E, then the ladder (§7d — plus the owed iOS build), the full walk, the install (§7b items 8–9), the handoff. Before this the piece was BATCH C. Markers: a `LIVE STATUS — BATCH C` list under the BATCH C brief in the plan (its commits' subjects start `Correction round, batch C`); the close marker `BATCH C RECORD — CLOSED`; the next batch after C is F. Before that (as of ~09:55) the piece was **the row-58 fix + the founding orchestrator's walk of it + batch A's CLOSE** — B is already closed (`b86b45c`). Read the markers below with 58/A in place of 53/B: the fix commit's subject starts `Correction round, batch A — row 58`; the subsection is `ROW 58 FIX` under the BATCH A RECORD; the close marker is `BATCH A RECORD — CLOSED`; the next batch after A is C. (The original 53/B wording is kept below as the worked example.) The original piece was **the row-53 fix + the founding orchestrator's walk of it + batch B's CLOSE**. Run these,
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
matters** — ~~`sips -c <h> <w> --cropOffset <y> <x>`~~ **CORRECTED 17:10 MDT by the successor: on this OS `sips --cropOffset` CENTERS the crop regardless of the offset (verified twice against a 220-px strip); crop with PIL instead — `python3 -c "from PIL import Image; im=Image.open('in.png'); im.crop((x0,y0,x1,y1)).save('crop.png')"` on the 2× PNG (PIL 12.3 is installed); exact every time.**

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

**SHE IS AWAKE from ~16:20 MDT 2026-09-01 (R-cor-10)** — taste calls go to her at batch seams as question batches; R-cor-3 RATIFIED (the simple read preview), row 26 RULED (facts first), row 52 RULED (underscore italics → G), batch G ADDED. Still hers: Read's per-note face memory · the memo's eight rulings (6 and 1 first) · any scalpel revert (none).

R-cor-3's PROVISIONAL library-panel reading · row 26's panel order · Read's switch memory · the memo's
eight rulings · row 52 (underscore emphasis vocabulary) · any scalpel revert (none so far; her lean is none).

## 5. PASTE-READY KICKOFF PROMPT FOR THE SUCCESSOR ORCHESTRATOR (FINAL FORM per R-cor-9 — a REGULAR handoff, not a shadow; she pastes this once batch F is closed and the founding session has stopped)

> You are the successor architect/orchestrator of Variorum's **Act 10 correction round**, taking over from
> the founding session at its ruled seam (R-cor-9: batches B, A, C and F are CLOSED; you run D → E → the
> ladder with the owed iOS build → the full acceptance walk → the install → the author handoff — the plan's
> §7b list, every item). Invoke the `architect-phase` skill. Read IN FULL, in this order:
> `notes/plans/act10-correction-orchestrator-handoff.md` (this file — **§0 and §0b FIRST and slowly: they
> carry her original message, the despair this round answers, the quality/premium bar in her words, the
> 26 complaints' completion table, and the personal-validation method that twice caught defects after an
> implementer's honest 'done' — taste and patience are this round's whole point**; the state section tells
> you which batch is next; VERIFY it against `git log --oneline -30` and the plan's records before acting),
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
- ~17:20 — **batch F CLOSED; the founding session WRAPPED (R-cor-9)** — Mac 2032/356, spine 71/10; the successor starts at D.
- ~16:0x — batch F's implementer DIED at the account's rate limit mid-USE-gate (pieces 1–4 committed: the seeded fixture, the walk's rows 63–68, the fixes, the pane's calm sections, the sweep; one uncommitted TrayPanel `.fixedSize()` rider left); the session continues at LOW PRIORITY until ~16:50; a fresh COMPLETION session is finishing F from its LIVE STATUS (adjudicate the diff → USE gate → suites → record). If checking in: the marker is still `BATCH F RECORD — CLOSED` absent/present.
- ~13:30 — **batch C CLOSED** (Mac 2028/356; the seven-mode rail + Read's edit·read + the current-block authority walked live); **batch F SPAWNED**; the orchestrator at ~68 % — cutover after F or D if above ~750k.
- ~10:40 — row 58 FIXED and walked; **batch A CLOSED** (Mac 2014/352); **batch C SPAWNED**; the orchestrator at ~64 % of context — cutover candidate after C closes.
- ~09:55 — batch A BUILT (Mac 2010/351) and walked by the orchestrator; RESIDUAL row 58 (the masthead's second row collides) → a fresh fix session running; A's record stays open until walked; C is next.
- ~07:50 — row 53 FIXED and walked (orchestrator-b53/ A–C); **batch B CLOSED**; Mac 2001/347; **batch A SPAWNED** (the chrome) — its record will appear under the BATCH A brief in the plan.
- ~07:30 — the fix session's first commit `7569af3` landed (row 53 converging landing); §2b proof checklist + §2c token discipline added at her question; she is starting a successor session to check in ~50 min.
- 16:05 MDT (machine clock) — **SUCCESSOR ORCHESTRATOR (Fable 5.1) ORIENTED**: state verified against git (`7f64b0f` HEAD, clean, pushed; no D/E/ladder records); the D/E briefs gained binding addenda (row 17's provenance: 13c 2E filtered the anchor by design, #47(c) default-on — the fix is a ruled narrowing); §7d's trailer moved to this session's; memory refreshed; **batch D SPAWNED**.
- ~16:40 MDT — **R-cor-10 recorded**: she is awake (live taste calls at seams); the cold review (§7d) confirmed; row 17 ratified; E's shape RATIFIED (simple read preview); **batch G (residuals and width — rows 59, 80–86 + the D-close walk's Snippets/Pool/Canvas finds) ADDED after E, before the ladder**; rows 26/52 ruled. D still running.
- 17:15 MDT — **batch D CLOSED** (walked: two full captures + the unrelated-first-peer live probe; rows 16/17/46 right in use; row 72 re-owned to G); **the Snippets/Pool/Canvas walk done in both voices** — rows 87 (the Pool's bare-date cards) and 88 (Canvas mid-bank + toolbar grammar) minted for HER call; Mac 2037/359; the row-46 deviation + 87/88 put to her at the seam; **E spawns after her answers**.
