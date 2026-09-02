# The Act 10 Correction Round — author handoff

*Drafted early 2026-09-01 ~06:05 with PENDING slots (the resiliency protocol's rule 7); FILLED at the closeout,
2026-09-02 ~06:10 MDT, by the successor orchestrator. The ONE record is `notes/plans/act10-correction-round.md`
(your rulings R-cor-1…18, the 100-row ledger, eight batch records, the two-round ladder, the full walk); this file
is what you read first in the morning. Everything in it is answerable from the repo alone.*

## Your checklist (in this order)

1. **Launch `/Applications/Variorum.app`** — refreshed at 09:46 UTC 2026-09-02 from the final tree (the last code
   commit `1e50e60`; the build ran at `ded5ac5`, records-only commits after it). The A1 backup came FIRST:
   `~/dev/variorum-store-backups/pre-act10cor-refresh-20260902T094613Z/` — the whole store folder (sqlite + shm +
   wal), copied with the app closed, the header verified ciphertext. The installed binary's sha256
   `600eeef9e5ed50c249c9411d26aef87030e10f4f7cb199904f00c078444189fe` matches the build product exactly;
   `io.lduarte.Variorum`, team `<apple-team-id>`, `keychain-access-groups` = ``. Your store's mode is biometric, so
   the app asks you at open exactly as before.
2. **Restore the field guide — YOUR one in-app act:** Help ▸ Restore Tutorial… (Replace). Four lesson texts
   changed this round — "getting around" (seven modes, ⌘1–⌘7), the "read" lesson (the `edit · read` teaching,
   renamed from "index · read"), "the workspace" (the masthead's `#` door instead of the retired fold), and the
   compare lesson's fourth paragraph (your note now reads whole against an unrelated note). Nothing else in your
   store is touched.
3. **Walk it in this order** (each line is a ledger row the round walked in use; nothing here is untested):
   - **the chrome:** the flat sidebar with one divider (no glass) · the rail's spacing · the Open strip directly
     under the modes · the title centered in every mode · the ONE tag door — click `#`, a field slides out with
     the cursor, ⏎ applies, ⎋ closes · a library row's alignment · resize the window narrow and open the tray:
     the title stays clear of its icons, the tag card sits on its own line under the path chip, the bottom bar
     folds to one row (`more ▾`), nothing truncates
   - **the book (open Sherlock):** Outline — expand "The Boscombe Valley Mystery", then click "the five orange
     pips" and then "a scandal in bohemia" in the navigator: each lands at its heading at once, no hang, no travel
     (the round's blocker) · click a collapsed story row far down: it reveals · the chapter headings in the body
     are doors · one row per story (the duplicate line is gone) · the gutter is calm · Index: click into a block
     and type · Read ▸ Scroll: click any navigator row — chapter or story — and the page lands at it, still in
     Read (your R-cor-17) · Read ▸ Pages: click a paragraph → Index at that block · the expanded note's side card
   - **Read (the merged tab, ⌘3):** opens on `edit` with the `▸ 01` column · click a block, type (it goes live in
     place) · switch to `read`, try `pages`, click a paragraph (it turns to edit at that block) · toggle the outline
   - **the one current block:** put the caret in a block in Write → ⌘2 Takes → ⌘3 Read → ⌘6 Blocks → ⌘1 Write —
     the same block every time
   - **Blocks:** a row click selects at once · drag the divider between the list and the panel (it remembers) ·
     the panel leads with the facts · `history` opens Block History inside the window and it leaves when you
     switch modes · ⌘K "block history" opens it too
   - **the recovery family:** This Note's Tray (the clocks and the verbs whole at any width; the explainers wrap)
     · Block History's sections — savepoints · archived takes · deleted takes · came from — each with one meaning
     line · Archived · the Trash (Empty Trash names snippet groups — cancel it) · ⌘⇧S saves a version and says so
   - **Compare (⌘5):** your note renders whole on first open, the offer cards under its card, `+ choose a note` at
     the right; pick an unrelated note — your note stays whole, the other column says "there is no relationship
     here" · the header cards share one bottom edge · **Lenses (⌘4):** the `＋ column` stub at the header's height;
     the cards over their panes. *(Both tabs still look much as they did beyond these mechanical fixes — the
     redesign is the memo's own phase, at your word.)*
   - **the Library panel:** click a note row's body — the panel slides in at once with the note's text, one facts
     line and a full-width **Open** that lands where your caret last was · click a book row's body — its outline;
     a note in it opens the book at that note · ⌘-Tab away: the boundary stays · a row's context menu ▸ Archive:
     the receipt sits above the bar, whole
   - **Canvas (⌘7)** on a long note: arrives at 1:1 with card 1 top-left under a calm strip; `fit all` opens the
     overview · **the Pool:** titleless cards show their first words · **Sherlock's `_italics_`** render as italics
   - **both voices:** Settings ▸ Appearance ▸ Study, then the same masthead, Read, tray and Compare
4. **Rule on the morning bundle** (QUESTIONS #88 — small; nothing in it blocks pre-13x).

## The morning bundle (what is still yours — everything else you ruled awake)

- **The Lenses + Compare memo's remaining rulings** (`notes/plans/act10-correction-memo-lenses-compare.md` §7):
  2 · 3's offer-in-the-slot half · 4's disabled-when-no-relationship half · 5 · 7 (the tab name — your copy pass) ·
  8 (when its build phase runs; its FuturePhases row exists). You ruled 1 (the door words) and 6 (two tabs) tonight.
- **Row 97:** a book opened from the shelf comes up in OUTLINE — it does not remember Read ▸ Scroll. That is the
  13c design (`defaultMode(for:)`), verified at the code, not a defect; keep it, or a small 13i-d/13u3 item makes
  books remember their tab.
- **The Read ▸ Scroll landing's follow-up:** the flow persists nothing — a story's height is remembered for the
  session, a never-measured story lands on an estimate within 3 % with one bounded correction. If you notice the
  page shift after a chapter click in your own use, the next step is persisting each story's measured height
  (the round's §7 line; 13u2 item 1's family or a 17 entry at your word).
- **Residuals recorded with owners (awareness only):** rows 92 (a Canvas silhouette click lands mid-board) · 94
  (Blocks' ~0.2–0.3 s arrival on the encrypted store) · 98 (the paged reader's paragraph over-count, self-corrected)
  · 100 (the flow's landing can end slightly off after a content creep) → 13u2 item 1's family; 93 (a nameless
  note's rename field shows the day as its prompt) → 13u2 item 13; 70 (⌘K cannot find a nameless note by its
  day) → 13o; 71 (an empty Compare slot has no close door) → the memo's phase; 62 · 96 (the real-click rig's
  whole-surface mounts) → 12; R1-15 · R1-18 (per-note defaults never reaped; a window-kind gate the registry
  cannot see) → 17e.
- **17 entries without an architect:** ruled tonight (R-cor-14) — one session allowed; an Opus cold review always;
  a Fable review for `Sync/`, custody or the editor seam. In the 17 file's header and CLAUDE.md.

## What shipped (the short version; the plan's records have every mechanism, pin and capture)

**Eight batches, one surface each, every one walked in use by the orchestrator before its record closed.**
**B the book:** the Outline hang killed (a SwiftUI lazy-placement livelock under an animated scroll), landings
exact with several 9k-word stories expanded (the segmented column with remembered sizes), note-row clicks reveal,
chapter headings are doors, the duplicate line collapses, the gutter calm, the book's Index editable in place, the
one scrolled-open door `LandingTarget` (13u item 17, pulled in). **A the chrome:** the liquid-glass sidebar retired
for a flat column with one divider (W8-3 delivered whole), one 30-pt pitch with the Open strip under the rail, the
title centered in every mode, ONE tag door (the `#` with an inline field; the K12 fold superseded), the library
rows on one baseline, the two-row masthead with the path chip leading. **C the note modes:** your R-cor-5/7 — the
seven-mode rail, Index retired into Read with `edit · read` (edit the default and editable, read never;
`continuous · pages` reusing the book's engine), ONE current block across modes, Block History scoped to its mode
in one right region, Blocks' draggable seam, the 0.5-s click hold gone, facts first. **F the recovery family:**
date-only stamps with an uncompressible clock slot, the pane's List retired for calm sections with one meaning line
each, Empty Trash naming snippet groups, the dead ⌘⇧S command group re-anchored, the kept-in-lineage sentence.
**D Compare/Lenses mechanical:** the anchor whole (the 13c filter narrowed to peers at your ratification), a
nameless note named by its day, one placement per act, one left edge, the stub at the header's height. **E the
Library panel:** the simple read preview you ratified — one facts line, a full-width Open landing at the saved
block, a book's outline, a column of our own whose boundary holds when the window is inactive, the calm-grammar
pick, the receipt laid out. **G residuals and width (added at your R-cor-10):** the `#`'s 24-pt target, the
narrow-window masthead and the folding bottom bar, your live find (the tag card over the path chip) fixed with a
width-aware second row, every note-side inspector moved to a column of our own, explainers wrapping whole, the
pages click landing in edit/Index, Blocks and Read arriving primed, `_italic_` in the vocabulary (core Domain,
display-only), the Pool card's first words, Canvas arriving 1:1 under a calm strip, the palette's history door,
the book landing after a Library ascent. **H Read ▸ Scroll's honest geometry:** the flow's stories at honest
heights (an estimate within 3 % of every Sherlock story), the chapter click exact from a fresh open, and — at your
R-cor-17 — every navigator row lands the read page.

**The ladder (your standard closeout cold review):** round 1 — 0 BLOCKER · 2 MAJOR · 9 MINOR · 7 NIT; the fix
session landed twelve with revert-verified pins, proved one hollow and undid it, found one speculative finding red
under load and fixed it, and found one deeper than said (→ batch H). Round 2 — 0 · 0 · 5 · 7, every round-1
disposition holding; all fixed. No round 3.

**Counts:** core 1525/165 · Mac 2106/378 · tutorial spine 72/10 — against the pre-13u finals (core 1524/165 ·
Mac 1985/343): +1/+0 · +121/+35. Zero `Sync/`, zero schema, marker 7. The iOS build passed (0 errors; 11
pre-existing warnings, none in the round's files).

**Your rulings this round (R-cor-1…18):** correct in place, retire nothing · this round before pre-13x · the
Library panel's shape · one walk at the end and the refresh · Index + Read one tab named Read with `edit · read` ·
Lenses + Compare need a design (the memo) · the overnight authorization · the founding orchestrator's wrap · you
awake: E ratified, batch G, rows 26/52 · the D-seam three · the 13u four-way re-split · 13i a–e with the Journal
identity, 13y trimmed, Phase 18 (18a sync considerations), the sizing guidance as guidance-to-raise · the
17-entry review rule · G's three kept as built · the #88 bundle ruled awake · the Read tab's navigator rows ·
sleep.

## Why it is shaped this way (the short version)

Your morning-after report (`notes/author-reports/2026-09-01-post-act10-ui-report.md`) and the cause, owned in the
plan's §0: five phase-sized surfaces built in one wave and verified by mount smokes, shipped to your install
before anyone used them. The round's rules C-1…C-7 were the fix for the cause — one surface per session; the
acceptance gate is USE; no install without a walk — and at your word they are now guidance for every phase
(`notes/PhaseSizingGuidance.md`, CLAUDE.md, the architect-phase skill).

## The install

Run 2026-09-02 09:46 UTC by the successor orchestrator's script (the cutover doc's appendix B), with your app closed
(your word) and the dev-store Debug build running from DerivedData: (1) the zero-instance check passed (no
non-DerivedData instance); (2) the A1 backup — the whole store folder copied to
`~/dev/variorum-store-backups/pre-act10cor-refresh-20260902T094613Z/` (sqlite 9.4 MB · shm · wal 3.0 MB — copied as
a set with no writer active; the header verified ciphertext); (3) `xcodebuild -scheme Variorum -configuration
Release -destination 'platform=macOS' build` at `ded5ac5` → `** BUILD SUCCEEDED **`; (4) the re-check passed and
*[removed for publication]*
`keychain-access-groups` = ``; sha256 of the installed binary and the build product identical
(`600eeef9e5ed50c249c9411d26aef87030e10f4f7cb199904f00c078444189fe`). The tutorial re-seed is yours (biometric).

## What moved, and where (the relocation sweep — your instruction; every file carries a dated pointer)

13u → FOUR phases (the 13u plan's banner; the master plan's `### 13u`); item 17 built here; rows 54/92/93/94/98
added to 13u2's families; the four protection items → pre-13x (its design's addendum); 17i runs AFTER pre-13x
(the 17 file; the sync-disagreements memo); 17k → 18a. 13i → a–e (the 13i brief's addendum) with the daily
Journal's identity as 13i-e (the memo's owner line; KnownIssues); 13y trimmed; the dedupe residuals → 18a
(KnownIssues; row 18). The Lenses + Compare build phase → FuturePhases. Row 70 → 13o's row. The mobile handoff
carries a pointer (item 17 built; the re-split). MobileSoul PL-19 is the parity row. Nothing owed in `Sync/`.

## Next

`pre-13x` — Postures & recovery (`notes/plans/pre-13x-postures-design.md`; its §16 has eight rulings for its
kickoff sitting; 17i runs after it, not inside). Then 13u1 (the seam only). The Lenses + Compare build phase — at
your word after the memo's remaining rulings.
