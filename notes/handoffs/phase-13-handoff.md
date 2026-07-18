# Phase 13 — Author Handoff (2026-07-18)

Phase 13 (UI design passes) is CLOSED as a build: Stages A–C shipped, the
review ladder ran all three rounds and closed at the cap, the schema
lockstep is deployed (mirror at marker 3), and `/Applications/Variorum.app`
is the phase's Release build, syncing against your real store. **What
remains is deliberately yours: the R48 taste checkpoint.** Per your R59
directive, this document is written so that checkpoint runs in a FRESH
session anchored on this file alone — if a question about the phase can't
be answered from here plus the files this points at, that is a
documentation defect to report, never a reason to wake an old session.

The binding design record is `notes/plans/phase-13-ui-design.md`: your
eight sittings verbatim, rulings R1–R59, the execution plan, all three
stage closeouts, and every review round's findings + dispositions.

---

## Your checklist (in order)

1. **☐ Launch `/Applications/Variorum.app`.** Already refreshed from the
   post-ladder Release build — no action needed beyond launching. It opens
   your REAL store and syncs (the mirror is at lockstep marker 3; the
   pre-13 refuse-to-sync window R53 accepted is over). Your real store is
   nearly empty, so also:
2. **☐ Open the design corpus for the real look at volume.** The seeded
   corpus lives in the DEV store (A4-fenced, never syncs): open the Xcode
   project and press Run (Debug ⇒ `Variorum-dev/`). Re-seed anytime:
   `cd Spikes/DesignCorpusSeeder && swift run DesignCorpusSeeder --replace`.
   What's in it: the daily journal (~96 dated entries inside a curated
   "Journal 2026" book), the **Dream Journal** (word target 10,000 — the
   shelf's progress line), **Orbit** (18 posts, 4 real chapters, fans,
   comments, callouts), the finished **Letters, 2025** (28 posts, locked),
   the **attention** series (URL references), **star-notes** (a smart book
   promoted from a tag, locked), one ~10k-word draft (scroll feel), 25
   bookless quick posts (the Pool), 30 scraps (Blocks — fans, block tags,
   canvas positions), and recovery material (an archived post, a deleted
   post, a deleted block, a deleted comment).
3. **☐ The guided UI/UX walk** (next section) — both voices, light and
   dark, over the corpus and your real store.
4. **☐ The deferred Phase 11b real-file walk folds into this session**
   (its items 1–3 were deferred to post-13; item 1 is moot — the app is
   refreshed — and item 3 is superseded — the phone is removed, Phase 15's
   orbit): right-click a post → Export ▸ Markdown… (the save panel must
   appear and the file must land); File ▸ Export Library… (one `.md` per
   post, `Archived/`, `Readings/`, `Pools/`); drag a real `.md` from
   Finder onto the sidebar (one undo unwinds the drop); add a real PDF in
   the reference panel, flip pages, drag a selection into the draft, then
   **quit, relaunch, reopen the same reference** — it must reopen to your
   page (the cross-launch bookmark proof no test can run).
5. **☐ The ratify walk** — QUESTIONS #23–#28 (full text in
   `notes/QUESTIONS.md`; summarized with options below) **plus the
   typographic-PDF disposition** (below — a KnownIssues row that now
   explicitly awaits your call at this checkpoint).
6. **☐ Record your reactions as new sitting entries** in
   `notes/plans/phase-13-ui-design.md` (mechanics at the bottom of this
   file) — **the fix round follows them; its cast is your call at that
   point.** The phase's closeout is done; the fix round is the checkpoint's
   own follow-through, exactly as R48 planned.
7. **☐ Then: real daily use.** Phase 12 (hardening) kicks off only after a
   window of it — you invoke it; its plan is intact under its deferral
   banner (`notes/plans/phase-12-hardening.md`), and its kickoff
   re-baselines on this phase's counts. The week-one dump-compare ritual
   begins when real use does.
8. **☐ The phone, whenever you want it** (no deadline, Phase 15's orbit):
   reinstall as Release, sign in — it lands on current schema; nothing
   waits on it.

---

## The guided walk (surface by surface — what to look at, what to try, what's a setting)

**First, the two global levers.** Everything below should be walked TWICE:
- **Voice — Settings (⌘,) → Appearance → "Design voice": Terminal / Study.**
  Terminal is the leading voice (your R1 ruling): SF Mono, airy, the `›`
  selection marker, `~/` path grammar, lowercased chrome, the blinking
  cursor. Study is the Phase 11 mockups' look: sepia room, white paper,
  Iowan Old Style serif. Same structure, same gestures, both voices —
  idioms included, not a palette swap (R1's "special little ways").
- **Dark — the macOS system appearance** (System Settings → Appearance, or
  Control Center). There is no in-app dark toggle; the app follows the
  system, and dark is a FULLY BLACK room in both voices (your R51
  re-ruling). Judge light first (you design light-first), then flip.

**Settings (⌘,) — where the global settings live.** Two tabs:
- **Appearance:** Design voice · "Show block seams (dotted lines between
  blocks)" (R42 — the global seam toggle; ⌘⇧B flips the same setting from
  the editor) · "Mark the block being edited" (R14/R22: Off — the cursor is
  enough / Outline ring / Background; OFF is the default) · "Show comments
  inline (tinted, under the block)" (R7's offered setting) · "Takes follow
  the scroll" (R25) · "Takes open as" (the four fan-out styles: Stack /
  Carousel / Margin grid / Slot split — the 11a setting, restyled this
  phase). These are synced document settings, not per-window state.
- **Tags — the tag manager's real home (your R52 ruling):** create tags,
  add children (hierarchy indented — R45: hierarchy stays SURFACED, its
  chance to earn its keep), rename, delete-with-subtree, and **Promote to
  Book…** — pick one or several tags, AND or OR joined (R30), and a smart
  book lands on your shelf; the tags stay on the posts (R37). In-context
  tag editing everywhere else still stands (R45/R46).

**The sidebar — final: Shelf · Library · Pool · Blocks (R44).** No Tags
tab (R39/R45), no Canvas item (R40), no Journal section (R38 — it lives on
the shelf), no Timeline (a Library view mode). Recovery and the tutorial
moved off the sidebar — reach them via ⌘K or the Library's toolbar menu
(#26d).

**The Shelf.** The terminal list (your R4 pick: B's list style) with a
TAGS column; the `~/shelf · N books · M finished` ls-line; ordering =
pinned books → journal books → the rest by name (R38's pinning as a
general mechanism — the daily Journal arrives pinned). Try: **the bottom
quick-entry bar** (R3 — the blinking cursor idiom; type and press Enter:
the text becomes a whole segmented post, untitled by design, #26e — it
lands in the Pool until you shelve it); **drag a post onto a book row**
(the membership drag, idempotent); a book row's menu — pin, **Finish**
(`reading.locked`'s face at last), **Length & Extent** (`max_posts` +
`word_target`: the Dream Journal shows "…% of 10,000w"; garbage input
refuses and keeps the stored value, #round-2 fix), **Use as Daily
Journal** on journal-profile books (the re-designation door — a finished
daily book never wedges ⌘J), and the new-book alert's **Create Journal
Book** (start a fresh journal notebook — §14 item 10 realized). The hint
bar names ⌘K · ⌘J · ⌘N.

**Library — everything (R32).** Catalog search across books, posts, AND
blocks; a scope picker; **List / Timeline** modes (timeline folded in per
sitting 2); the **addable tags column** (R46 — per-row "+tag", and
multi-select for batch tagging); the post context menu carries Export ▸
and "Mark as Versions with" (restored by the round-2 review after the
sidebar→Library move dropped them). A block hit opens its home post with
the caret AT that block (the caret-precise landing, Stage C).

**Pool — bookless posts (R29/R44).** "When you make a random post, that's
where it goes." Every row offers Add-to-Book and tags — the drainage
purpose built in. Note the #26(h) consequence to form a view on: SMART-book
membership counts (tagging a post into a promoted book pulls it out of the
Pool; untagging returns it — derived membership FLAPS by design).

**Blocks — the scraps area (renamed per R20/R29).** Sidebar rows per pool;
opens in the ordinary detail surface with its canvas face intact. Drag a
scrap into a draft (⌥-drag carries its whole fan); block tags and the
tag filter live here.

**⌘K / ⌘N / ⌘J (R15/R41).** The palette takes commands and catalog hits —
"every buried capability typeable"; Enter executes/opens (block hits land
caret-precise). ⌘N = New Post (your R41 call); ⌘J = Today's Entry — the
untouchable one-entry-per-day door: it creates-or-opens today's entry AND
ensures the designated daily book exists, pinned; on a finished/full daily
book the entry still opens and a note speaks (round-2 MAJOR 2's fix).

**A book with chapters (open Orbit in the corpus).** The **navigator**
(R43's letter): a leading rail with chapters (slash-label idiom in
Terminal voice), a top-level outline, and settings; **clicking a post
opens it in the current editor — no context jump**; there is deliberately
NO separate chapter view. Chapters: "+ new chapter", rename, Move Up/Down
AND drag with the accent insertion bar (R19), file posts via "Chapter ▸",
delete a chapter (posts survive — they just unsection), and **"restore
deleted chapter"** (the never-skimpy recovery door; assignments reattach
for free). Unfiled posts trail the chapters (#26b). The book's settings
leg = rename / finish / extents. **Journal books:** "+ new entry" on the
daily book is ⌘J's rule; on any OTHER journal-like notebook it mints a
normal dated post — several a day is legal there (sitting 8 / R57: normal
notebooks; only the daily journal wears the journal shape the bridge keys
on).

**The reading flow (R2/R56 — direction C).** In a book: the Book/Read
mode switch; a FINISHED book (Letters, 2025) opens straight into Read.
A continuous page column on the C page tokens — paper, serif, typographic
chapter breaks — voice-independent by design (a view mode, not a theme).
Click a post to wake it in the book view for editing. (Round 3's MAJOR
made this genuinely virtualized — opening Journal 2026's ~96 entries costs
the viewport, not the book.)

**The editor (Write mode).** Look for: the measure (max ~680pt, centered,
real gutters — R9's sacred margins; TextEdit named as the anti-pattern);
the voice typography (SF Mono 14 / Iowan 16); the **status line's
word-count prominence** (R11: "blk 2/5 · 12w · 1,204w post"). Try:
- **⌘⇧B "Toggle Block Seams"** — dotted seams at mid-gap (R6: seams are
  THE boundary mechanism; the 9d pastel tint look is retired). With seams
  ON, the **⠿ drag handles** appear (#27b — handles ride the seams-visible
  working state); drag a block — the Notion-style insertion bar (R19)
  shows the landing; drops target visible frames (long moves go through
  the Blocks TOC mode).
- **The editing indicator** — flip the setting through off / outline /
  background and decide which you live in (your R14 "sometimes people
  don't even want to see what block they're editing").
- **Callouts (R16/R27):** Block ▸ Callout ▸ — five colors (theme-token
  names, resolved per voice) + Emoji… + Remove. Watch the WHITE-GAP rule
  (R17 — base background always breathes between colored blocks; the
  9d-tint defect you diagnosed, fixed by rule); the emoji sits in the left
  gutter, not inside your prose (#27d). A callout exports as a blockquote
  (presentation only — renderedText and the bridge never map).
- **Comments (R7 + §14 items 6/9):** Block ▸ Comments… (⌘⇧') or click a
  margin card. Margin placement is the default ruling; cards carry the
  `#` prefix idiom in Terminal voice; a narrow window degrades cards to a
  "#N" badge (#27c). Flip **"Show comments inline"** — tinted strips under
  the commented blocks; the mechanism is a uniformly widened paragraph gap
  (#27a — the whole surface airs out, not just commented blocks; §12's
  boundaries-invisible-at-rest preserved). The panel's **Deleted section**
  lists tombstoned comments with per-row Restore (never skimpy). Comments
  are per-BLOCK, never per-take, and they duplicate onto split/merge
  successors (your travel instinct, built).
- The **membership chip** beside the mode picker (R35): "in N books" →
  the book list + the divergence door (duplicate-as-version presented as
  THE way to separate this book's copy — R31's membership-is-not-ownership
  made visible where it matters).

**Takes mode — every presentation (R12: the v2 canon).** Set each of the
four styles in Settings and open a fanned post (Orbit has fans):
- The grammar everywhere: tinted take cards, the **3pt bar + "✓ chosen"**
  on the chosen take, and the **ring on exactly the pane being edited**
  (R22's marginalia rule — among many editable surfaces the ring finds the
  ONE live editor; click into any take and watch it migrate — R8/R23:
  everything visible is editable, P3 mechanically intact).
- **"Mark changing block"** (toggle in the board, default ON): the grey
  wash on the block whose takes are open (R13); toggle it off — cards
  stay, wash goes (#28a — the old "Seamless" folded into it).
- **The short-block strip (R24 — your design):** in Margin grid, a short
  fanned block's cards render as a ONE-CARD-HIGH horizontally-scrolling
  strip; the post grows vertically to fit it. Longer blocks keep the
  vertical grid. The cut is a 200-character threshold (#28b — a build-time
  call for your walk; a long take on a short block clips at card height in
  strip form).
- **Follow-the-scroll (R25 — your "excellent idea!!"):** flip the setting
  and scroll — near-viewport fanned blocks bloom by themselves, in every
  mode where blooming exists (#28c/d: while it's on, the ⑂ toggle can't
  close a mode-bloom — scrolling away or turning it off closes).
- **Expand All / Close All** only appear single-column, non-slot-split
  (R25's agreed half — columns and slot split ARE whole-post fan
  presentations).
- The dashed **"＋ new take (branch)" / "＋ blank take"** doors close every
  bloom (v2's footer; refusals speak under a seal).
- The margin grid reserves a fixed rail so the article column never
  wobbles as takes open (#28f — R9's calm).

**Canvas — a view ON a post now (R40).** Open any post → mode "Canvas"
(the sidebar door is gone). Arrange cards spatially (positions persist —
`canvas_layout`); fanned cards show **"⑂ see takes (n)"** → the minimal
**‹ take k of n · label ›** switcher, one take at a time, one switcher
open at a time — deliberately the pattern mobile might inherit (R40/R58).
**Note for your walk (#28e): ‹ › writes CHOSEN** (`chooseVariant`, ends
clamped) — what you arrange is what the post IS; the recorded alternative
is a view-local display pick that never touches chosen.

**Compare / Outline / Blocks modes** are the 11a surfaces restyled onto
the voice tokens — worth one pass each to confirm nothing reads as
pre-13 leftovers.

---

## The ratify walk (QUESTIONS #23–#28 — options considered · what shipped; authoritative text in `notes/QUESTIONS.md`)

All six stayed OPEN by design (R55: PROVISIONAL-and-continue; zero
stop-and-asks arose). Each is one guard line or one condition to flip if
you rule otherwise.

**#23 — Comments (A1/A2), four calls:** (a) comment writes REFUSE under a
sealed post (the everything-under letter; alternative: allow — a note
about the text isn't the text — one line to flip; reading stays free);
(b) travel copies PRESERVE the source's `created_at` (a note's date is
part of the note; alternative: now-stamps); (c) comment text is metadata
CAS under sync, deliberately NOT S5 (conflict-as-variant stays scoped to
prose; an edit race converges to either text); (d) DELETED comments never
travel (recovery stays with the original block).

**#24 — Callouts/presentation, five calls:** (a) REFUSES under seal
(closer to authoring than a lens); (b) structural successors INHERIT the
frame; (c) merge keeps the frame only when BOTH sources agree, else plain
(alternative recorded: first-source-wins); (d) `color` stores a
theme-token NAME, never a literal (R1's two-voices rule); **(e) the
poolDragCopy name asymmetry — a genuine open call:** poolDragCopy carries
presentation and comments but has NEVER carried `block.name` (pre-13
behavior the new travel made visible) — options: leave (a scrap's name is
pool-local shorthand) or copy it too (one line). Behavior unchanged
pending you.

**#25 — Sections & extents, five calls:** (a) chapters are CURATED-only
(smart books refuse; their sectioning stays tag-grouping); (b) a locked
reading freezes chapter STRUCTURE, rename stays free; (c) `word_target`
never refuses an add (progress display; both extent setters refuse under
a locked reading); (d) `setReadingMaxPosts` added — lowering below
membership is legal, further adds refuse; (e) `deleteSection` +
**`restoreSection`** (one tombstone flip; assignments reattach free;
refuses live/locked/died-with-reading — and readings themselves still
have no restore door, a standing pre-13 boundary flagged in case you want
one).

**#26 — The structure stage's bundle:** (a) the daily book's designation
(created/pinned/designated on first ⌘J; Outcome doctrine — the entry
always opens, notes speak, "Use as Daily Journal" re-designates); **(a′)
corrected at round 2 and RATIFIED by your sitting 8/R57** — non-daily
journal books mint `.generic` + `entry_date` + one-block (normal
notebooks; only the daily journal wears the journal shape); (b) unfiled
posts trail chapters; (c) Blocks scrap rows stay in the sidebar (the
drag-into-draft reason); (d) Recovery/Tutorial live behind ⌘K + the
Library toolbar; (e) quick-entry posts are untitled; (f) the shelf's tags
column derives (smart books: query tags; curated: members' top paths);
(g) book word counts are one-shot loads, never held observations (P1 —
they can lag a keystroke); (h) **derived membership IS membership** on
Pool + chip (promote-to-book actually drains — with the FLAP consequence
for your eyes: tag in/out moves posts; an empty-spec smart book collects
everything; malformed collects nothing).

**#27 — The writing surface (C1), eight calls:** (a) inline comments =
the uniformly widened paragraph gap (an overlay can't reserve TK2
vertical space; per-block paragraph attributes are §3's fragile class;
uniform keeps boundaries uninferable — consequence: inline-ON airs out
the whole surface); (b) drag handles ride seams-visible (alternative:
hover-revealed); (c) narrow gutter → "#N" badge; (d) callout emoji in the
left gutter, never in the prose run; (e) ⌘⇧B is a menu BUTTON, not a
checked toggle (the menu can't observe the synced setting; Settings shows
the checked state); (f) a spaced callout's export loses byte-exactness
through the blockquote mapping (deliberate; renderedText/bridge stay
byte-exact, pinned); (g) handle drops target visible frames only; (h) the
status line omits a per-caret "commits N" (a DB hit per caret step —
deferred until wanted).

**#28 — Takes + canvas (C2/C3), six calls:** (a) the Seamless toggle
folded into "Mark changing block" (unchecking removes the wash only —
cards stay; alternative: a separate hide-cards read-plainly mode);
(b) the 200-char strip threshold + the strip's clip-at-card-height cost;
(c) follow-the-scroll outranks the per-block ⑂ close (no third state
invented); (d) follow's reach = wherever blooming exists (unlocked
columns keep their no-bloom pre-13 shape); (e) **the canvas switcher
writes CHOSEN** (the explicit-gesture reading of R40; alternative: a
view-local display pick — needs per-canvas state + a differs-from-chosen
marker); (f) the margin grid's fixed reserved rail.

**The typographic-PDF disposition (KnownIssues, round-3 flag):** no Phase
13 stage built or scoped it — export still renders through the 11b
system-font CTFramesetter path. The row now explicitly awaits YOUR call
at this checkpoint: **build it in the fix round, or re-own it to a named
phase.** (It is the last 13-owned row; everything else in KnownIssues is
owned by 12/14/15.)

---

## What shipped and why it's shaped that way (per stage, traced to rulings)

**Stage A — substrate.** The ONE SyncSpec §12 lockstep event, four
additive own-commit migrations: `block_comment` (v1_8 — your §14 items
6/9: own table, multiple per block, tombstoned, deleted-visible +
resurrectable, exact-stamp cascade so `restoreBlock` revives notes);
`block.presentation` (v1_9 — R16/R27 callouts at block identity level,
takes share the frame); `reading_section` + `reading_post.section_id`
(v1_10 — R28/R50: reading_post = which book, section_id = which chapter;
dangling reads unsectioned so deleting a chapter never rewrites
memberships); `reading.word_target` (v1_11 — item 10's words-based
extent, display-only by design). A2 built the travel rules (comments
duplicate onto successors — extract/divide/W/merge/copies — your
"duplicate where needed" instinct; presentation inherits, merge-agree-
else-plain) and `SmartQuerySpec.tagsAll` (R30's AND-joining). A0 ran the
deferred-12 pull-forwards: the three measurements (headline: the entire
decoration language as OVERLAYS costs ~0.04 ms at p95 — nothing you'll
judge visually is perf-constrained; the overlays-never-rendering-
attributes ground rule is what buys it), the design corpus, and the
restore drill (executed; runbook in the plan's Stage A closeout; the
KnownIssues row closed).

**Stage B — structure.** The voice layer as its own module (VoiceTokens
with IDIOM SLOTS — R1's "special little ways" are first-class: `›`,
slashes, `~/`, the cursor; ReadingPageTokens = direction C's
voice-independent page; fully-black dark pinned in both voices — R51;
every font macOS-shipped — R49, zero dependencies). The final IA (R44)
with the Journal folded into the shelf as pinned notebooks (R38), the
shelf's finish/extent faces (`max_posts` visible for the first time since
v1), the quick-entry bar (R3), ⌘K/⌘N/⌘J (R15/R41), Settings as the tag
manager's home (R52), Library-as-everything (R32) with the R46 batch-tag
column, the Pool drainage surface (R29), books with real chapters + the
terminal navigator (R43) + the membership chip and divergence door (R35),
journal books by ordinary membership with the one-per-day rule scoped
exactly where the journal SHAPE lives (R50 + R57), and the reading flow
(R2) that finished books open into.

**Stage C — editor surfaces.** The C1 writing surface (typography +
gutter math per voice; seams/indicator/word counts/handles per
R6/R42/R22/R11/R19; callouts with the white-gap cap R17; comments margin
+ inline per R7; everything as OVERLAY views — the TEXTKIT2 §3 ground
rule, never rendering attributes on the live editor). The C2 takes
presentations (the v2-canon restyle R12; the R24 strip; R25
follow-the-scroll with refcounted row visibility so multi-column repeats
can't blind each other; expand-all gated; fan-growth doors). The C3
canvas-as-post-view (R40) with the minimal chosen-writing takes switcher
(R58's mobile-inheritable seed).

**Why some things are NOT here:** N-post side-by-side, the
reference-panel-beside-multi-post-views composition, and chat-format
references (§14 items 1/2/5) were never pulled into the ratified plan's
stages — they remain open direction-level asks with no owner change;
mobile takes (R58) is Phase 15's; the typographic PDF is the explicit
checkpoint call above. Nothing else from the sittings was dropped: open
questions 1–21 all closed in the sittings, and the build's own
ambiguities are exactly #23–#28.

---

## Counts, the ladder, the deploy trail, the sessions

**Final gates (all green): core `swift test` 731 in 88 suites · Mac app
421 in 78 · mobile 11 in 4** — deferred Phase 12's re-baseline inputs.
A0's numbers re-checked at every stage gate (decoration cost at p95
−0.00 ms; overlay reposition 0.02 ms; read-tier within noise); canary
silent; no macOS point update since 26.4.1, so the TEXTKIT2 §5 matrix
stands on the build the spike re-exercised.

**The review ladder (three rounds, closed at the cap; every finding
AGREED, every bug-class fix red-on-old pinned; full dispositions in the
plan file's three round sections):**
- **Round 1 (Stage A): 3 MINOR / 2 NIT** — race tests actually entering
  the new orphan-repair extensions; `restoreSection` born from the
  unrecoverable-chapter finding; the poolDragCopy name-asymmetry record
  corrected (#24e); the spike's fallback guard hardened; canary wording
  made precise.
- **Round 2 (Stage B): 1 BLOCKER / 4 MAJOR / 6 MINOR / 2 NIT** — the
  BLOCKER: dream-journal entries minted the journal SHAPE (`profile=
  'journal'`+`entry_date`) that ⌘J's lookup and the Fragments bridge
  sweep key on — a dream entry WAS the day's journal; fixed to
  `.generic`+dated+one-block and ratified mid-fix by your sitting 8
  (R57). The MAJORs: a finished daily book wedged ⌘J (now the Outcome
  doctrine — entries always open, notes speak); smart-book membership
  invisible to Pool/chip (now drains — #26h); shelf word counts wrong by
  SQL construction (now the editor's own counting rule — one brain); two
  ratified capabilities dropped in the Library move (export doors +
  version_of door 1, restored).
- **Round 3 (Stage C + the round-2 fixes): 1 MAJOR / 5 MINOR / 3 NIT**,
  fixes landed post-cap per the ladder's rule — the MAJOR: the reading
  flow was NOT virtualized (plain VStack, cost ∝ book size, P3's banned
  shape, contradicting its own closeout claim; now LazyVStack, pinned by
  a materialization counter, red-verified at 300-on-revert). Also: the
  locked-book "+ new entry" stray-mint door (the new
  `assertReadingAcceptsPosts` core gate — refuse BEFORE minting); quiet
  comment cards now genuinely click-through; the closeout ritual's doc
  batch widened (the §7/§9/tagsAll drift this handoff's part-1 commit
  closed); a stale-read guard on tag chips; the typographic-PDF row's
  disposition made an explicit author call; capped-book word counts now
  count exactly the assembly's capped set.

**The deploy trail (R53):** sitting 7 authorized and UN-GATED the schema
deploy ("just do the schema deploy" — you'd removed the phone app, so no
un-updated client existed and the lockstep was mirror → Mac only) →
`06_phase13_lockstep.sql` executed VERBATIM on the production mirror via
the stored-PAT arrangement (the 9c precedent) mid-Stage-A → verified the
same sitting: `sync_schema_version()` = 3, both new tables present with
zero rows and RLS enabled, all three new columns live, RPCs in place →
the accepted window (the pre-13 Mac install visibly refusing to sync)
closed at the Stage B gate when `/Applications` was refreshed. State
now: mirror marker 3, your Mac client matched, outbox/cursor semantics
untouched throughout.

**The sessions, in two sentences:** the build ran as three implementer
sessions (Stage A+B; Stage C1; Stage C2/C3) with author-directed context
cutovers at clean seams, each seam carried by a self-contained section of
the plan file so the next session inherited every decision and trap
without re-derivation. The coordinator held one continuous thread across
all of it, and this closeout session wrote only documentation — the
recorded gates stand, nothing was re-run.

---

## How your review session should record things (R48/R59 mechanics)

1. **Anchor a fresh session on this file** (plus, as needed, the plan
   file's sittings and QUESTIONS #23–#28 — never an old session's
   memory).
2. **Your reactions and tweak requests are recorded as NEW SITTING
   ENTRIES** in `notes/plans/phase-13-ui-design.md` — the standing
   format: your message VERBATIM (your standing instruction), then
   numbered rulings (R60+), uncertainty preserved where you have it.
3. **Ratifications land in QUESTIONS** (#23–#28 statuses + where
   recorded) and, where they change canonical behavior, as AppSpec §14
   deltas — same as every checkpoint before this one.
4. **The fix round follows your list** — its cast is your call at that
   point (a `/run-phase`-style cast or a direct author-attended session;
   nothing is pre-committed). The typographic-PDF call (build vs re-own)
   slots into the same decision.
5. **Phase 12 waits for real use, and you invoke it** — nothing
   auto-advances.

## Where everything is recorded

- The sittings (your words verbatim) + rulings R1–R59 + the execution
  plan + all stage closeouts + all three review rounds' dispositions:
  `notes/plans/phase-13-ui-design.md`.
- The open ratify items: `notes/QUESTIONS.md` #23–#28.
- The canonical-doc ratification batch (this closeout's commit
  `0c42dd9`): CoreDescription pillars 1/3 · OverallModel §2 · AppSpec
  §7/§8/§9/§12/§14 · SyncSpec §12's event record.
- Master plan row/pointer + the Phase 13 closeout paragraph:
  `notes/DetailedPlanForPhases.md`.
- KnownIssues: restore-drill row closed; typographic-PDF row = your
  checkpoint call; no other 13-owned rows.
- The design corpus seeder: `Spikes/DesignCorpusSeeder` (dev store only).
- The measurement spike + baselines: `Spikes/Phase13DecorationSpike` +
  the plan's Stage A/C closeouts.
- The mirror artifacts: `Server/supabase/06_phase13_lockstep.sql`
  (deployed, marker 3).
