# Phase 13c — book forms, conversions & carried work

**Status:** CREATED at the 13b closeout (2026-07-22, per the author's
13b end-of-life directive — recorded in
`notes/plans/phase-13b-make-it-work.md`, "The 13b end-of-life
directive"). **ACTIVE from 2026-07-25** — the author opened the phase
herself with an author-attended kickoff sitting (its record is the
"Kickoff sitting" section below).
**Shape:** runs under the `/architect-phase` skill
(`.claude/skills/architect-phase/SKILL.md`) — the 13b-proven
architect/orchestrator machinery; the skill file governs process; this
file is the phase's ONE running record.
**Cast: ALL-OPUS — author ruling 2026-07-25, superseding the all-Fable
pre-confirmation.** Her reason, in her words: "previous I was going to
run this phase with Fable but now that Opus 5 has come out, I want to
give it a go with this phase." Orchestrator · fresh implementer per
batch · fresh cold reviewer per ladder round, all Opus. The shape ruling
came at the same sitting: she invoked `/run-phase`, was offered the
choice, and **ruled `/architect-phase`** — this plan was written for it
and the phase is genuinely multi-batch with sittings.
*(Superseded, kept for the thread: "all-Fable, author-confirmed IN
ADVANCE 2026-07-22 … she intends to kick 13c off when her Fable credits
reset." The credits question is moot — Opus 5 shipped instead.)*
**The paste-ready kickoff message is the third section below**
("Kickoff message"); the two sections before it exist because this file
changed hands between models and opens with two review obligations.

## PROVENANCE — read this before trusting any line (author's instruction, 2026-07-22)

**This file was drafted by FABLE and finished by OPUS, and the seam is
deliberately visible in git.** The Fable Stage 4 execution orchestrator
wrote the draft in its scratchpad and then hit the author's Fable token
limit mid-gate; an Opus session finished 13b's closeout and this plan.
Two commits make the handoff auditable:

1. **`224938b` — "FABLE-AUTHORED SCRATCH PLAN"**: the draft committed
   UNEDITED (constitution placeholder and empty baselines included).
2. **the next commit — the Opus edits**: `git diff 224938b <this file>`
   shows EXACTLY what changed hands.

**Your instruction as the 13c orchestrator (hers, verbatim-faithful):**
review the plan file overall AND the Opus changes specifically — "so it
can use its own judgement or ask me questions if anything seems to be
different." The largest deliberate divergence is named for you: **the
visual/design/UI review left this phase's scope entirely** (see
"What deliberately did NOT come here"). Everything else in the Opus diff
is the constitution splice, the real baselines, and the notes below.

## First acts at phase start (before any batch)

1. **Re-review the 13b gate fixes AND THE TWO DEFECTS THEY CORRECTED —
   76 lines, three commits (`e5b8221`, `16e5fcb`, `2e60d0d`), plus the
   round-3 post-cap hardening (`120c418`).** The author asked for this
   explicitly (2026-07-22): "look over the defects and the fixes." These
   were REAL bugs found when the stage-close gate ran tests that a
   locked login session had only ever compiled — not cosmetic. The two
   defects, so you know what you're re-checking:
   - **The mid-view-update `@State` height drop** (`16e5fcb`, hardened
     in `120c418`): `PaneSurface`'s `remeasure()` could publish a height
     through a SwiftUI `Binding` *during* an update pass, which SwiftUI
     silently drops — leaving a compare pane framed one line tall under
     two lines of text with nothing left to re-publish. `PaneSurface` is
     **the ONE text surface every pane composes** (P-3), so this reaches
     the editor, takes, lenses, compare, canvas, and the read tier
     alike. The fix routes every publish through one `PanePublisher`
     door with a bounded convergence heal; the first cut patched two
     instances, and `120c418` made it structural (that history is the
     round-3 record). **Confirm the class is truly closed** — a publish
     added later must inherit the discipline, not need its own repair.
   - **The multi-peer Compare flush** (`e5b8221`): `CompareComposition`
     force-flushed one peer's unrelated blocks into a sparse segment —
     the gap parade N29 exists to kill, at segment scale. The failing
     test was the correct pin. Two placement behaviors it left are
     recorded below (the kin-less-peer question) and are a live design
     item this phase — read them together with the fix.
   A ladder round-3 cold review already ran over these at 13b's close
   (verdict + traces in the 13b plan file's round-3 sections); this is a
   SECOND look with fresh eyes on code that landed under model
   exhaustion, not a repeat for its own sake.
2. **Review the applied canon deltas.** 13b's closeout wrote real
   semantic changes into the canonical docs — the merge-pairing
   extension (AppSpec §9 + OverallModel §7), the cut rule + parking
   semantics (same sections), and `restoreReading`'s deliberate
   reversal of the readings-have-no-restore-door boundary (AppSpec §9).
   These are not bookkeeping: a round-1 reviewer already caught the
   delta checklist incomplete once. Read them against the S4 rulings
   they encode before building on them.
3. **Verify the baselines below with your own runs** (the skill's
   verify-don't-trust rule).

## Kickoff sitting — 2026-07-25 (author-attended; THIS RAN, and it binds)

**The phase opened here.** The author invoked the phase herself, brought
a fresh intake list from real daily use (an exported Variorum note,
`~/Downloads/Things I want to do before Brazil.md` — her own app's
export, takes and all), and ruled on shape, cast, ordering, and the
roadmap beyond this phase. Her framing, verbatim-faithful: *"Overall,
I'm LOVING IT and couldn't be more thrilled with our work together and
how the app is coming along… I want you to consider the list of
suggestions at the end of this exported note and work with me to figure
out how to order them and arrange them in more phases — 13d, e, f,
etc."*

**Her rulings (K1–K5):**

- **K1 — Cast and shape: ALL-OPUS under `/architect-phase`.** Recorded
  in the header above; supersedes the all-Fable pre-confirmation.
  Re-confirmed by her mid-turn: "yeah, i meant /architect-phase should
  be run for 13c."
- **K2 — A FRICTION BATCH OPENS THIS PHASE, before the book work.**
  Offered three orderings (friction batch inside 13c · full flip ·
  13c untouched); she chose the first. 13c keeps its committed scope and
  its name's "carried work" half now carries real weight: the traced
  defects and the cheapest refusals land FIRST, then the book forms.
  Rationale on the record: this material is what hurts her *daily*,
  and the book work is the nicer-reading build — a whole phase of
  waiting for backspace to delete an empty block was the wrong trade.
  The remainder of the friction list becomes **13d**.
- **K3 — The roadmap beyond 13c** (new master-plan rows, added the same
  day): **13d** the rest of the refusal/ergonomics floor · **13e** takes
  & block management · **13f** workspace (windows, tabs, stars,
  quicknote, the post→note sweep) · **13g** formatting **+ lists and
  checkboxes** · **13h** the LLM folder bridge + markdown folder import.
  Unslotted: the EPUB library. Mobile stays Phase 15.
- **K4 — Big-rock ranking (what she wants soonest):** **Workspace** and
  **Formatting** — and at the same breath she ADDED a new item in her own
  words: *"i also want a simple list maker and checkbox maker (like
  hyphens, [], bullets)"* (ledger A34). The LLM folder bridge and the
  EPUB library are wanted but rank BEHIND these; neither was chosen as
  urgent.
- **K5 — `post` → `note` is UI STRINGS ONLY.** Every user-facing label,
  menu item, shortcut name, refusal copy and helper text says "note";
  `container.kind='post'` stays (never user-facing) and the canon docs
  keep "post" as the model term, so the ratified vocabulary (visible /
  chosen / lens / version) stays unmuddied. Owned by 13f as one sweep.

**Four claims VERIFIED IN CODE at the sitting** (not taken on report —
these are facts the friction batch builds on):

1. **Fragments-landed journal entries land bookless.**
   `BridgeEngine.swift:254` calls `createOrOpenJournalEntry` and stops;
   the Mac's ⌘J door (`BookStructureModel.swift:240-242`) calls it *and
   then* `addPostToReading` into the designated daily book. The bridge
   path never got the second half, so a landed day is a journal post in
   no book — and "posts in no book" is exactly what Pool shows. Her
   report was exact.
2. **Redo does not exist.** No `redo` / `redoStack` / `canRedo` anywhere
   in core or the app; structural undo is one-directional by omission,
   not by design ruling.
3. **Callout is Write-only BY DECLARATION** — the registry says
   `availability: writeEditor`, `doors: [.menuBar]`. Both halves of her
   ask (every mode + a shortcut) are edits to that one declaration plus
   the P-2 fire-and-DO wiring 13b built for exactly this class.
4. **Sync has been signed out since 2026-07-20** — the 13b handoff's
   item 2, still undone. Read-only count of her real store at the
   sitting: **1,868 outbox rows**, oldest `2026-07-20T05:06:34Z`, newest
   `2026-07-25T06:53:34Z` (up from 1,216 at 13b's close). Nothing lost —
   the engine refuses rounds and holds by design — but her mirror and
   phone are five days stale. Surfaced to her at the top of the sitting;
   **hers to discharge, never the phase's** (author-only: her accounts).

### The friction batch (K2) — scope as ruled

Opens the phase. Ledger rows **A1, A2, A3, A4, A7, A8, A9, A10, A13(a)**
— the four verified items plus the refusals that cost her most:

- the bridge's missing daily-book membership (A1) and its refresh
  cadence (A2);
- the two editor-layout defects she lives with — the whitespace phantom
  (A3) and the jumping tall block (A4). *First suspect, recorded so the
  batch doesn't rediscover it: 13b Stage 3 root-caused a sibling class —
  overlays computed before TK2's first layout pass with no post-layout
  trigger. Trace before fixing; the hallucination guard applies.*
- backspace won't delete an empty block (A7) and there is no
  delete/archive door for one at all (A8);
- no divide in Takes (A9) — a registry availability rule, the P-1/P-2
  class 13b built the machinery for;
- redo for structural undo (A10) — a real absence, and the pair to A12's
  destructive-undo warning (which stays 13d: the warning is cheap once
  redo makes the mistake recoverable);
- callout mode PARITY + a shortcut (A13(a)) — the declaration edit above.
  *The pickers half (swatches, emoji) is A13(b) and stays 13e.*

Everything else on the intake list is dispositioned in the ledger below.

### First acts — DISCHARGED 2026-07-25 (the two opening obligations + baselines)

**Obligation 1 — the 13b gate fixes and the two defects they corrected.**
Re-read `e5b8221` / `16e5fcb` / `2e60d0d` and the round-3 hardening
`120c418` in full, against the current `PaneSurface.swift` and
`CompareModels.swift`. **Verdict: both fixes are sound, both mechanisms
are real, and I traced them myself rather than accepting the commit
prose.** The `PanePublisher` shape genuinely answers the plan's question
— publishes write synchronously (so the common path can't starve under a
busy main queue) *and* re-make on a later main-queue turn where a write
always lands; deferred turns coalesce; the height re-publish is a real
bounded convergence loop against what the pane actually renders, so a
composer deliberately constraining a frame can't spin the queue forever.
A publish added **to `PanePublisher`** inherits both halves for free.

> **FINDING F1 (hardening candidate, not a defect — recorded, not
> built):** the plan asked me to confirm "a publish added later must
> inherit the discipline, not need its own repair." That holds for
> publishes routed through `PanePublisher` — but the routing itself is a
> **comment**, not a constraint (`PaneSurface.swift:511-512`, "Nothing in
> this coordinator writes SwiftUI state except through it"). `install`
> takes the write closures as parameters, so a future third piece of pane
> state (a measured width, a scroll offset, a selection echo) can accept a
> third closure and be written directly from `updateNSView` or a delegate
> callback, and nothing fails. **That is the P-1 shape one layer down —
> green by audit rather than by construction.** Two cheap closings, either
> one small: a source-walk pin in the registry-walk spirit (assert the
> `Coordinator` body contains no state write outside `publisher?.`), or a
> type-level fix (`install` takes one `PanePublisher.Writes` value that
> only `PanePublisher` can consume). **Author's call whether it enters
> scope; nothing built on it.**

The Compare fix (`e5b8221`) is correct and its expectation matches the 4C
record's letter — peers register against the anchor independently, so a
kin-less peer's pending run must NOT be force-flushed by another peer's
kin row. Its two left-behind placement behaviours are exactly what **C4**
(the related-blocks-only setting) exists to resolve; read together as the
plan directs, C4 makes the kin-less-peer PROVISIONAL largely moot rather
than needing a separate placement ruling.

**Obligation 2 — the applied canon deltas.** Read AppSpec §7
(`container.word_target`), §9 (the cut rule + parking; `mergeCeremony`;
`restoreReading`; `setPostWordTarget`), §14's Stage 4 delta, and
OverallModel §7 (merge pairing; the word-edge cut rule) against the S4
rulings they encode. **Verdict: faithful and complete** — the parking
semantics, the I10-at-birth gates (`divideSideWouldBeEmpty`,
`mergedBlockWouldHaveNoTake`), the no-cartesian rule's survival, the 1:1
pairing PROVISIONAL, `restoreReading`'s explicitly-flagged reversal of
the standing no-restore-door boundary, and `setPostWordTarget`'s
refuses-under-seal PROVISIONAL are all stated where a fresh session
finds them.

> **FINDING F2 (one-line canon inconsistency — flagged, NOT
> autonomously edited):** OverallModel §7 still opens its size sentence
> "Block size: **floor is the sentence**, default is the paragraph,
> ceiling-less upward" — and then, in the same sentence, carries S4-22's
> "a cut may fall between any two words … snapping to word edges with a
> gentle settle." After S4-22 the effective floor is a **word**, and
> CoreDescription pillar 1 already says "The floor is a sentence (**or a
> single word**)". So OverallModel §7 is now internally in tension and
> behind both pillar 1 and her own ruling. Proposed wording, hers to
> bless: *"floor is the sentence (or a single word)"* — matching pillar
> 1 exactly. Left unedited because canon changes beyond recording her
> explicit decisions are author-only.

**Baselines — verified by my own runs, not trusted from the file.**
Core `swift test`: **817 tests / 96 suites passed** (28.7 s), matching
the recorded baseline exactly, P1 benchmarks flat. Mac
`xcodebuild test`: **652 tests / 123 suites passed** (58.2 s), matching
exactly. Mobile untouched at 11/4. Login session confirmed UNLOCKED
(lock flag 0), so the Stage 4 locked-session regime does not bind this
phase's opening.

**F1 and F2 — both RULED by the author the same sitting.** F1: *fold the
hardening into the friction batch* (her pick — this is the surface every
pane composes, and it's where the gate found a real bug two days
earlier). F2: *make OverallModel §7 match* — applied this turn, "floor
is the sentence **(or a single word)**", matching CoreDescription pillar
1 and her own S4-22 ruling; a contradiction removed, no new meaning.

**Her sync sign-in landed (2026-07-25, same sitting):** outbox
**1,868 → 0**, cursor at `server_seq 6662`. The 13b handoff's item 2 is
discharged; her mirror and phone are current.

### A40 refined by the author, and what it actually is (the friction batch's first real design finding)

Asked which of two readings her callout report meant, she gave a third
and better answer — **verbatim:**

> *"I see the card, sometimes it isn't aligned well with the blocks, like
> the color spreads underneath it, sometimes it just looks misaligned. i
> think we haven't figured out how to color blocks with their weird
> spacing well. this also relates to how the gaps that happen when you
> have a comment inline has to eb fixed - representing it in the editor
> as a block or something? idk?"*

**Her diagnosis is right, and it names a class rather than a bug.** The
callout frame is an OVERLAY over a TK2 flow whose vertical space is
already contested by three ruled things: stored trailing newlines are
block CONTENT (the 2026-07-12 ruling, option (a)), the presentation gap
is **per-PARAGRAPH and uniform** (same ruling — deliberately not
per-seam, so boundaries stay invisible at rest, AppSpec §12), and inline
comments widen that same uniform gap by a strip height because **an
overlay cannot reserve vertical space in TK2** (S4-30(a); QUESTIONS
#27(a)). So "where does this block visually end" has no single settled
answer, and every decoration that must draw a box around a block is
guessing — which is exactly what "the color spreads underneath it"
looks like.

**Precedent that says this is tractable:** Phase 10 fixed the sibling
class exactly once, at one pure mapping — *fragment frames are
container-relative, overlays are view-relative*, which had every tint
stripe sitting 8 px high. 13b Stage 3 then root-caused the timing half
(overlays computed before TK2's first layout pass with no post-layout
trigger). This is the third visit to the same neighbourhood, which under
**P-5 is the definition of an under-architected feature.**

**Ruling (mine, as architect — recorded, and hers to overturn):** the
batch **traces before it fixes**, and the two halves split by what they
actually are:

- **If the frame is MIS-MAPPED** — the geometry says one thing and the
  overlay draws another, the Phase 10 shape — that is a bug: fix it at
  the one mapping, with a red-on-old pin, in the friction batch.
- **If the frame is drawing exactly what it was told, and what it was
  told is ambiguous** — i.e. the block's visual extent genuinely has no
  defined answer once gaps and trailing newlines are in play — that is
  **NOT a patch**, per P-5. It becomes a **design memo** and merges with
  **C3/N41**, which the plan already flagged as an R116 conversation
  rather than a fix.

**C3 is therefore RESCOPED** (from "N41 inline-comments airiness") to:
**one design memo on block extent and decoration geometry in the
editor** — what vertical space a block owns, who may draw in the gap,
and whether an inline comment stops being an overlay and becomes
something the flow reserves space for honestly (her own floated idea:
*"representing it in the editor as a block or something?"*, whose cost
is stated up front — the editor's text must never diverge from the
block's text, since `BlockRangeIndex`'s UTF-16 tiling invariant is what
the app's whole identity machinery rides on, AppSpec §15 risk 1). Edges
enumerated on paper, her rulings on the product-flavored ones, then
build. **A5, A40, C3/N41 are one item now, not three.**

### A3 + A4 + A41 are ONE class — her long-block detail unifies them

Third live report the same sitting, **verbatim:**

> *"it seems there are some overall issues with white space / spacing.
> the extreme gap at the bottom of a single block came when one block was
> really long - even if there was nothing to indicate that whitespace
> should be there (i.e. I copied in a long message with no whitespace at
> the end)."*

**This is the diagnostic that collapses the search.** "No whitespace at
the end" **rules out stored trailing newlines** as the cause — so the
2026-07-12 content-spacing ruling is NOT implicated, and A40's
gap-geometry question is a *different* problem from this one. What's
left is a **height problem on long blocks**, and it explains all three
reports as one class:

- **A3** (phantom empty paragraphs that *"disappear on scroll then
  reappear when you're more on top of it"*) — the signature of a height
  that is estimated, replaced by real geometry when the region lays out,
  and reverted when it doesn't.
- **A4** (the editor *"jumping around"* when a block is taller than the
  screen, with unclickable space below) — the same estimate revising
  under her.
- **A41** (this report) — the extreme gap under one long block, with the
  content explanation eliminated by her own test.

**HYPOTHESIS, traced from code this sitting — explicitly NOT yet
reproduced, and the batch must confirm or refute it BEFORE fixing
anything (hallucination guard: build the pin first as the confirm; red
confirms, green means record-only):**

`PanePublisher`'s convergence heal is **one-directional**
(`PaneSurface.swift:177`):

```swift
if rendered + Self.convergenceSlack < height, healTurnsLeft > 0 {
```

It re-publishes only while the pane renders **SHORTER** than its
measured height — the dropped-write case the gate found. There is **no
convergence check for the opposite direction**: if `measure()` returns a
height LARGER than the text actually needs — which is precisely what
TK2's estimated geometry does before a long region is fully laid out
(TEXTKIT2 §2: *"total document height is estimated, and the estimate
shifts as you scroll and lay out more"*; AppSpec §15 risk 2 is the
standing register entry) — the pane is framed **too tall**, nothing ever
re-measures it downward, and what she sees is empty space under her text
that she cannot click into because there is no text there. Scrolling
forces layout that corrects the measurement; scrolling away restores the
estimate. **That is her exact description, in both directions.**

Corroborating precedent, so the batch weighs the hypothesis honestly:
the Phase 6 spike measured the estimate **under**-reporting at rest
(6.8% low) and *converging* with content never regressing — but it
measured ONE full-document `NSTextView`, not a `PaneSurface` whose
measured height is published into SwiftUI `@State` and used to frame the
pane. The publish path is younger than the spike and is where the Stage
4 gate found a real defect two days ago.

**Batch instruction:** treat A3/A4/A41 as one investigation with one
traced mechanism, not three fixes. If the hypothesis is refuted, say so
plainly and keep tracing — a wrong hypothesis recorded and killed is a
good outcome; a fix built on an unconfirmed one is the forbidden class.

### A39 RULED — Outline becomes the book's writing surface

Her pick: *that IS what Outline should become.* So the book's three
modes stay three — **Outline** (write the book: Write's typography and
margins, chapter headings inline, each post collapsible) · **Book**
(the two-up spread, page = a whole scrollable post) · **Read** (the flow
+ true pagination pair). No fourth mode. The architectural notes on
A39's ledger row bind: it adopts `PaneTextAuthority`'s one-live-ring
contract, joins `commitTake`, collapse is view state and never in-place
TK2 folding, and it virtualizes per P3.

## Kickoff message (for the fresh /architect-phase 13c orchestrator — read this first)

> You are the Phase 13c architect/orchestrator for Variorum under the
> `/architect-phase` skill — read the skill file IN FULL first (it
> carries the constitution, the machinery, and the environment
> invariants), then THIS plan file IN FULL, then the three committed-
> scope inputs: `notes/plans/phase-13c-uniform-page-view-brief.md`,
> `notes/plans/phase-13c-memo-smart-to-curated.md`, and the N41 row in
> the ledger below. Then `notes/handoffs/phase-13b-handoff.md` (state
> at the boundary; anything still-held there that the author has since
> discharged is recorded in its checklist). Confirm the repo state with
> `git log --oneline -10` and `git status`. **Read "PROVENANCE" and
> "First acts at phase start" below before anything else — this file
> changed hands between models mid-flight, the seam is auditable by
> `git diff`, and two review obligations open the phase.** Verify the
> baselines below with your own runs before building on them. Note what
> deliberately did NOT come into this phase (its own section). The
> phase OPENS with an
> author-attended kickoff sitting — the agenda is the "Kickoff sitting
> agenda" section; bring the question batches (≤4 per call), record
> her rulings verbatim-faithful in this file the same turn, then run
> batches through the standing machinery: fresh Fable implementer per
> batch, repo-first records, one review ladder per stage over the
> combined diff, PROVISIONAL-and-continue for non-gating ambiguity,
> the standing author-only hard stops untouched.

## Committed scope (the author's EOL directive — "ruled and wanted, deferred in time only, not optional")

1. **The uniform-page traditional book view** — built from
   `notes/plans/phase-13c-uniform-page-view-brief.md` (4F's detailed
   brief per her S4-16 condition: two-tier estimated/measured
   pagination outside the editor stack, estimated-page scrub domain,
   lazy spread-only realization per P1, edge cases decided on paper).
   The brief's FIVE open questions are the kickoff sitting's; its
   settled facts are cited, not re-derived. (S4-9(3); ledger N31's
   re-owned half.)

   > **Author direction captured 2026-07-23/24 (pre-13c-kickoff, via
   > screenshots + a correction round + a resolution round — recorded here
   > so it BINDS at kickoff, not lost in chat):** In real use she found the shipped book
   > surfaces weren't the book she pictured. This direction GROWS the plan;
   > it does NOT simplify it (her words: "the twist is not supposed to
   > simplify the plan… both views are supposed to exist").
   >
   > **The book segmented picker becomes `Outline · Book · Read`** (from
   > `Book · Pages · Read`), and **Read** itself becomes a two-mode view:
   >
   > - **Outline** = today's continuous vertical-scroll book view (today's
   >   `.book`). **Remove the ENTIRE bottom inset** (`BookView.swift:512-552`)
   >   — both the `Slider` JUMP control ("it makes no sense to have a
   >   horizontal scrollbar on a vertical page") AND the `ProgressView`
   >   "post N of M · %" above it. She RULED (2026-07-24): remove the
   >   progress bar too — "it seems a bit buggy… remove it fully for now,
   >   I'll add it later if I feel inclined." (So if it is ever re-added,
   >   investigate the bugginess she saw FIRST — an observed defect, parked
   >   by removal, not chased now.) Outline ends as a clean vertical-scroll
   >   read + the navigator, no bottom chrome.
   > - **Book** = NEW: a two-up SPREAD where **each page is a whole POST,
   >   vertically scrollable and fully contained** (the post does NOT flow
   >   across pages), two posts side by side — "basically like [today's]
   >   Pages but with two posts side by side… new compared to what we have"
   >   (confirmed 2026-07-24), "more like a lens column, for comparison."
   >   View B (page = post, two-up); effectively today's `.pages` paged
   >   view made TWO-UP + book-styled. **KEEP its bottom bar.** Flip
   >   navigation (ruled 2026-07-24): the DEFAULT advances TWO posts at
   >   once (turn the leaf), PLUS a single-step control (her sketch: "a
   >   half arrow button or something") that nudges the spread by ONE post
   >   — so she can re-pair when turn-the-leaf splits two posts she wants
   >   side by side. Arrows also navigate.
   > - **Read** = today's reading flow, now the Apple-Books/Kindle PAIR of
   >   modes: **(a) vertical infinite scroll** (today's `ReadingFlowView`)
   >   and **(b) TRUE BOOK PAGINATION** — a **TWO-PAGE SPREAD** (ruled
   >   2026-07-24), horizontal pages each a SET amount of text (text flows
   >   across identical fixed pages). Mode (b) IS View A and IS the
   >   uniform-page brief's hard two-tier estimator (§3) — it does NOT
   >   evaporate; it lives here. **KEEP the bottom bar on the paginated
   >   sub-mode**; arrows also navigate.
   >
   > **Net — BOTH must exist:** an Apple-Books "set text per page" true-
   > pagination view (Read → paginated, View A) AND an Apple-Books two-up
   > "each page is a scrollable post" spread (Book, View B). The brief's
   > uniform-page pagination work stands UNCHANGED and lives inside Read;
   > the Book spread is additional. Correction of record: my first read —
   > that page=post "evaporates" the estimator — was WRONG; she wants both.
   >
   > **Naming flag for her:** "Outline" also names the retired post-level
   > tab folded into Compare — different surface, no hard collision.
   >
   > **The small opens are now RESOLVED (2026-07-24):** Outline progress
   > bar → removed fully (above); Read-paginated → two-page spread (above);
   > Book flip → two-by-default + a one-post nudge control (above). Nothing
   > on the book-view STRUCTURE is left open pre-kickoff; the brief's
   > pagination-mechanism questions (surface, page-break policy) remain the
   > architect's build-time calls.
   >
   > **Not built pre-kickoff:** her live real-store instance is running
   > (the no-Release-build-under-live-instance rule) and this is 13c's
   > owned scope. Queued for the 13c book-view batch.

2. **Smart → smart+curated book conversion (N38)** — built from
   `notes/plans/phase-13c-memo-smart-to-curated.md` (4F's design memo
   per her S4-16-class condition: three conversion shapes with A —
   materialize-and-convert + the fresh-smart-book offer —
   recommended; zero schema change for A confirmed). The memo's FIVE
   plain-language rulings are HERS at the kickoff; build to her
   answers. (S4-28.4.)
3. **N41 — the inline-comments airiness** — 13c is the named owner
   (her EOL directive discharged the "13b closeout names its owner"
   duty). The mechanism constraint is on the record (S4-30(a): an
   overlay cannot reserve vertical space in TK2; the uniform gap is
   the honest mechanism) — if it still bothers her in use, this is an
   R116 design-memo conversation at the sitting, not a patch.
4. **Compare — a "show related blocks only" setting** *(author request
   2026-07-22, at the 13b closeout — verbatim: "we should have a
   setting to only show related blocks - that would make the pane feel
   more usable")*. A per-view toggle (session/view-local, the
   follow-order/lineage-colour toggle class from 4C — no schema) that
   collapses each column to only the blocks with lineage kinship to the
   anchor, hiding the unrelated stretches. **This RESOLVES the 4C
   kin-less-peer PROVISIONAL directly** (13b plan, Batch 4C judgment
   call 0 — a peer with no kinship renders its whole post below every
   aligned row): with the setting on, an unrelated peer simply shows
   nothing, and a partly-related one shows only its kin rows. Her call
   at the kickoff: whether "off" keeps today's shipped placement (the
   PROVISIONAL as-is) or the placement itself changes — the setting may
   make the placement question moot. Design detail (the empty-column
   affordance, whether "related" means direct `derived_from`/`version_of`
   or the transitive lineage the alignment already computes) is the
   kickoff's; it composes with the honesty line (N29) — an all-unrelated
   pair with the setting on says "there is no relationship here" over
   two empty columns.

## What deliberately did NOT come here (author's decision, 2026-07-22 — the largest Opus divergence from the Fable draft)

**The visual / design / UI review round is NOT 13c's.** The Fable draft
assumed 13b's closing propose-only sweep would feed this phase's kickoff
agenda. The author removed that: the sweep and the accumulated
screenshot/usability verification became a **standalone, re-runnable
item on the master plan's phase table** (unslotted, like the Apple Notes
import), because — her reasoning — 13c "already has a defined scope and
several big issues," the review is "something that can be run multiple
times," and separating it "saves the 13c orchestrator context from going
through a bunch of screenshots and items before it begins the more
defined items."

Consequences for you, stated plainly:

- **Do NOT import the visual backlog.** The per-batch visual-loop items
  live in 13b's batch records (4A–4F); a future design-review round
  starts by reading those lists. They are not 13c ledger rows.
- **Several 13b Stage 4 surfaces shipped with machine verification but
  NO visual pass** — the reworked take ceremony sheet, the merge
  ceremony sheet, the rebuilt Compare board, the reworked Canvas, and
  the paged book view + progress bar. The suite, soaks, and pins cover
  their behavior; nobody has LOOKED at them. The author accepted being
  first eyes.
- **ONE targeted exception you must honor:** the uniform-page book view
  (committed scope 1) composes directly with the **paged view and
  progress bar 4F shipped**, which are among those visually unverified
  surfaces. Look at them when you build on them — that is not the same
  as adopting the sweep.

## Kickoff sitting agenda (bring as question batches; record rulings verbatim)

- The N38 memo's five rulings; the uniform-page brief's five open
  questions.
- Any 13b handoff checklist items she has not yet discharged, incl.
  held ratifications (its "worth a look" list is advisory, never a
  requirement; the deferred-in-place judgment-call walk stays deferred
  and is never re-asked unprompted).
- Open organic-use findings from her 13b-era reports (standing triage:
  happy-path breaker / owned row / new row).
- **Kickoff candidates (propose-only, recorded during Stage 4 — each
  enters scope ONLY on her approval; none is owed):** the canvas BANK
  as a future face atop culling (the 4E fork she preserved); synced
  canvas card-size columns (`w`/`h` — a §12 lockstep event); the full
  margin-hover comment grammar (4D built the minimal caret-block
  "+ //"); the N34 GLOBAL one_block face (one small core setter away —
  the 4D-recorded blocker); the word-target face's discoverability (the
  4F quiet door); consolidating the two sibling refusal-copy homes onto
  `OpsRefusalCopy` (the round-1 fix pass's recorded candidate).

## Binding principles

**The P-1…P-9 constitution is copied VERBATIM below (the skill's
requirement; the author's directive: copy, don't summarize; byte-exact
from 13b's plan file).**

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**The skill's "Applying the constitution" precisions bind here as
written there** (P-1's routed-vocabulary scope + `.surface`; P-3's two
surface kinds — the full-document editor is never absorbed; layer
placement + parity-by-forwards; the overlay/sink delivery law).

## Stage 4 lessons (established by 13b Stage 4 — binding here explicitly, per the EOL directive)

1. **One-ring-across-contexts lives ON `PaneTextAuthority`**
   (`PaneKey.context`, the 4C extension): any new editable surface —
   the uniform-page view included, if it ever wakes to edit — adopts
   the authority; never a second liveness mechanism (4C/4E are the
   worked examples).
2. **A new editable surface joins `commitTake`'s availability AND
   registers a `.commit` handler** (`takeFamilyPlusEditableBoards` —
   the N5 class closes per surface; 4D/4E precedent).
3. **ONE snap brain:** `BoundarySnapping`'s ruled word rule + gentle
   settle is THE cut rule at every gesture door (plain divide, the
   ceremony, extract, `CutPropagation` seeds). Never a second snap
   table.
4. **ONE join brain:** `MergeJoin` resolves every merge join (op,
   ceremony, previews) — no surface re-derives a join byte.
5. **Ceremony-sheet disciplines** (the W + merge sheets): one-flight
   guard before any await; drift-refresh against the CURRENT fans at
   confirm; cancel-inert; honest confirm blockers; I10-at-birth gates
   (`divideSideWouldBeEmpty` / `mergedBlockWouldHaveNoTake`).
6. **The realization-bound discipline for free-2D / long surfaces:**
   the realized set is a PURE function of (positions, sizes,
   visibleRect, margin); silhouettes under overview zoom keep the
   bound; DEBUG materialization counters are the hosted pin form (4E;
   the ReadingFlow precedent). The uniform-page view's brief already
   binds its pagination to this discipline.
7. **Ops returning take mappings carry correspondence arrays**
   (`FanHalf.sourceVariantIDs`, `mergeCeremony`'s `sources` — the 4A/4B
   precedent).
8. **Model-driven navigation re-affirmed** (the Phase 6 ruling, applied
   at 4F): progress, scrub, and page domains ride the POST LIST /
   stored estimates — never live TK2 geometry.
9. **The locked-session regime** (a Stage 4 environment discovery): the
   Mac test runner hangs pre-connection under a locked login session —
   verified against control suites. Under lock: core `swift test` +
   `build-for-testing` compile gates run per batch; Mac suite
   executions, app-side behavioral-revert reds, visual loops, and
   install refreshes consolidate at the first unlocked window with
   EXACT procedures recorded per batch (the 4A–4F records' form).
10. **In-view affordances vs declared acts:** view-mode toggles,
    progress faces, sheet controls, and recovery doors are surface-
    local (recorded, not declared); routed acts and doors-with-
    shortcuts are declared (the standing 4A–4F reading).
11. **The §12 deploy-gate pattern** (also in the skill): mirror deploys
    only on her explicit go-ahead; install refreshes that would outrun
    the deployed marker are HELD; lesson edits stale the seeded field
    guide — re-seed behind the A1 rail at close.

## The running ledger

| # | Item | Status |
|---|------|--------|
| C1 | The uniform-page book view (from the 4F brief) + her 7/23–24 direction | **the READ half SHIPPED (Batch 2C)** — Read is the pair she asked for: SCROLL (the flow) and PAGES, a two-page spread of identical fixed leaves with the text flowing across them. The brief's two-tier design built as designed (estimated globally from `Queries.blockExtents` — lengths, in SQL, no prose; measured locally by CoreText), with ONE architectural rule added that the brief did not have: **a page is addressed by (post, page-in-post), never by a page number**, so a measurement replacing an estimate moves the LABEL and never the page under her. Slicing is LAZY on a measurement, not on caution — CoreText typesets per paragraph, so ordinary prose paginates whole in 3.5 ms at 26k words while the same text as ONE block costs 1.67 s (the A3/A41 shape). Read is NOT editable (A43), which is why there is no NSTextView on the surface at all — and therefore no TK2 estimated geometry to inherit (the 1C cross-check). The brief's five opens are PROVISIONAL — QUESTIONS #45; (b) deliberately goes against the brief's own lean and says why. *(The BOOK-spread half of her 7/23–24 direction shipped at 2B; Outline's at 2A.)* |
| C2 | N38 smart→smart+curated conversion (from the 4F memo; her five rulings first) | **SHIPPED (Batch 2D) as the memo's SHAPE A — materialize-and-convert — PROVISIONAL in full.** Her five rulings were owed and she was asleep, so each is built at its most spec-defensible reading with the alternative recorded: QUESTIONS #46. The book's current results become real `reading_post` rows in the order she was looking at, `kind` flips and `sort_field` freezes to manual so nothing moves; the filter and grouping tag ride the row (the tag-derived sections SURVIVE and hand over to real chapters the moment she makes one — no new rule); the fresh collector is offered, carrying the filter/order/sectioning but never the extents or the finish state. **ZERO schema, confirmed in code**, which is why A was the right shape to build in her absence — the other two are not one-line reversals. Two doors: the shelf's deliberate menu item and the navigator's "+ new chapter", which now RENDERS on a smart book and acts (convert, then the chapter prompt — P-2's choreography). **The memo expected three refusals to become offers; only ONE was a real dead end** — adding a post already had a better answer (R98's tag-and-report) and order is now controllable everywhere (A31), so the drop gesture is untouched. Undoable and redoable on exact rows |
| C3 | N41 inline-comments airiness (R116-class conversation first) | **TRANSFORMED, not skipped** *(row corrected at the K6 review, K8 — it read "committed, not started" long after the phase's own record superseded that)*: 1A merged A5/A40/N41 into ONE block-extent design memo (`phase-13c-memo-block-extent.md`, written per P-5); 1C measured its option E; 1E BUILT E (PROVISIONAL, QUESTIONS #39). **What remains is HERS:** the memo's Parts 1 and 3 rulings + Q3's posture — QUESTIONS #29/#39 on the ratify walk. The airiness conversation itself lives in the memo's Part 1, not in a batch |
| C4 | Compare "show related blocks only" setting (resolves the 4C kin-less-peer PROVISIONAL) | **SHIPPED 2E** (commit `e8f13ee` — a third session-local toggle of the follow-order/lineage-colour class, no schema; `CompareComposition.relatedOnly` is a PURE pre-pass over `segments`' own inputs, so `segments` is byte-unchanged and every 4C honesty pin stands. "Related" = the SAME block-level transitive lineage the rails and the alignment already use (`Queries.blockKinship`) — ONE kinship brain, because a narrower rule would hide railed blocks and a wider one would show unrailed ones. Every survivor is kin ⇒ the composition holds nothing but aligned rows. **The 4C kin-less-peer PROVISIONAL is MOOTED, not re-ruled** — with the filter on the unrelated peer contributes nothing, and the filter-OFF placement is byte-unchanged. N29 COMPOSES: the all-unrelated board says "there is no relationship here" over the empty columns with the way out named; the mixed case gets a per-column note that also catches the version-linked-but-lineage-less peer. The live ring follows 4C's NIT-1 precedent — hiding it blurs, flushes that post's own coordinator, and SPEAKS; never a refusal of the toggle. Default OFF. QUESTIONS #47) |

### Author intake, 2026-07-25 (the kickoff sitting's list — every item dispositioned)

Source: her exported note. **Nothing here is invented; each row is her
own item.** Phase assignments are K2/K3's; rows marked **13c-friction**
are this phase's opening batch.

| # | Item (hers) | Owner |
|---|-------------|-------|
| A1 | Fragments-landed journal entries appear in Pool, not the Journal book *(traced)* | **13c-friction — SHIPPED (Batch 1D).** The landing half now shelves the day's entry in the designated daily book, mirroring ⌘J; never blocks the landing (finished/full/smart/dangling books land-and-speak); never re-shelves what she removed — which is also what makes it REPAIR her two existing orphans on their next landing. No-designated-book posture PROVISIONAL, QUESTIONS #37. Third class instance found and recorded, not fixed: the mobile capture door mints bookless the same way |
| A2 | The bridge "doesn't seem to refresh often enough" | **13c-friction — ANSWERED + one structural fix (Batch 1D).** The sign-out starvation is CONFIRMED as the dominant cause (signed out ⇒ zero sync rounds ⇒ zero `onRoundCompleted` ⇒ the bridge ran once per launch for five days) — but the hole is structural, not historical (an expired session or a failed owner adoption reach it too), so a lifecycle event now reaches the bridge when sync can't deliver a round, and a stale bridge no longer LOOKS fresh in the status row. The 60 s throttle is untouched; a periodic poll is deliberately NOT taken — QUESTIONS #38 |
| A3 | Whitespace phantom — paragraphs of empty space with nothing in them; vanish on scroll, return when you're over them | **13c-friction — ADDRESSED (Batch 1E, PROVISIONAL).** 1A traced it to TK2's own height estimate (not our bug, no public API to correct it) and 1C measured the only remedy; 1E built it — the block the viewport reaches is laid out once, and the phantom under it goes. Behind a cap, a once-per-block bound, a floor, and a KILL SWITCH; memo Q3 is still hers, now on felt evidence — QUESTIONS #39 |
| A4 | Editor jumps when one block is taller than the screen; the empty space below isn't clickable as newlines | **13c-friction — JUMPING FIXED (Batch 1A: two real defects, revert-verified); the un-clickable half was A46, which 1C proved is not a bug (the space is the editor's and the caret does move — there is just no text there); the space itself goes with 1E** |
| A5 | "the callouts don't have the spacing on their color right" | 13d |
| A6 | Book bottom inset — horizontal scrollbar on a vertical page; buggy progress bar | **13c — SHIPPED (Batch 2A).** Outline's ENTIRE `safeAreaInset` is gone, both controls, exactly as ruled; the per-row scroll-visibility reporting that fed the bar went with it rather than costing work for a face that isn't drawn. Red-on-old: restoring the inset puts an `NSSlider` and an `NSProgressIndicator` back in the hierarchy and the pin fails. The model's scrub/progress brains STAY (pure, pinned) — Book and Read both keep a bottom bar and 2B/2C own them. If the bar ever returns, her observed bugginess is investigated FIRST |
| A7 | Backspace won't delete an empty block — "especially when there's an empty block right at the start of the post" | **13c-friction — SHIPPED (Batch 1B)** |
| A8 | No ability to delete / archive empty blocks at all | **13c-friction — DELETE SHIPPED (Batch 1B); ARCHIVE deliberately not built, QUESTIONS #33(c)** |
| A9 | "i desperately need divide in takes mode" | **DEFERRED to 13d — recorded, not silent (13c Stage 1 ladder, R2-2).** K2 put it in the friction batch and no batch brief ever covered it; the fix pass sized it honestly and it is NOT the registry-declaration shape the sitting assumed. Divide from Takes works today via fire-and-DO (the bottom-bar door carries her to Write with the caret placed and runs it there); acting NATIVELY needs a structural planning path for Takes plus the W ceremony mountable outside `EditorSurfaceController` — materially larger than a declaration plus wiring, and out of scope for a ladder fix pass. Owner **13d**; QUESTIONS #41 |
| A10 | Redo — to undo an accidental structural undo *(traced: absent)* | **13c-friction — SHIPPED (Batch 1B)** |
| A11 | Divide on an empty line should put the blank line NOWHERE — block above, block below | 13d |
| A12 | Warning before destructive actions like undoing a structural edit that created a take | 13d |
| A13 | Callouts (a) in Takes/Compare/Lenses + a shortcut *(traced)* · (b) real colour swatches + a proper emoji picker | (a) **13c-friction — SHIPPED (Stage 1 ladder, R2-2).** The frame is the BLOCK's and its takes share it (R16/R27), so `.callout` gained `takesAccess: .native` and the take family + Compare, every menu item routes through `CommandRouter` instead of reaching into Write's editor, and **⌥⌘C toggles**. One shared pure transform (`CalloutEditRule`) for all four doors. Canvas deliberately out (not in her ask) · (b) 13e |
| A14 | ⌘⇧Enter for new block | 13d |
| A15 | Shift-Enter keeps text in the same block — in Takes AND Write | 13d |
| A16 | The newline-makes-a-block setting available in Takes too (N34's global `one_block` face) | 13d |
| A17 | Delete several blocks at once — block-level highlight instead of text highlight across blocks | 13e |
| A18 | ⌘-click in Takes to select blocks to merge; merge several when they have no takes | 13e |
| A19 | Reorder takes | 13e |
| A20 | Shortcut: move a take into a new block beneath the current block | 13e |
| A21 | Copy all takes to the clipboard, or turn all takes into their own blocks | 13e |
| A22 | Scroll into ~a page of empty space so typing stays high on the page (typewriter room) | 13d |
| A23 | Setting: gap between blocks a paragraph tall, vs. today's height | 13d |
| A24 | Different levels of spellchecking | 13d |
| A25 | Two posts next to each other in the same window — "DEFINITELY need" | 13f |
| A26 | Several Variorum windows, or one window split in half | 13f |
| A27 | Tabs of recently-open notes under "this post", ⌘⇧1… to jump | 13f |
| A28 | Star up to 5 notes (or books) so they're always on the left | 13f |
| A29 | Quick-note format — a floating sticky note, no takes unless opened as its own post | 13f |
| A30 | "post" → "note" everywhere — **UI strings only (K5)** | 13f |
| A31 | See a book by its saved custom order OR by an attribute like time; the order savable like a lens | **13c — SHIPPED (Batch 2D), and the halves were not what they looked like.** The ATTRIBUTE half already existed and had **no reachable door**: `reading.sort_field` + `setReadingSort` have shipped since Phase 2, and their only face was the Phase 10 sidebar's `ReadingsSection`, left unreferenced by Phase 13's IA rework — dead code, deleted here, its list living on as `BookOrderChoices` in the book's own navigator. The **"saved like lenses"** half is the lens grammar exactly: `Queries.ReadingOrder` is a read-time override that writes NOTHING (export, the bridge, and every other reader still see the book's own order), and "Save as This Book's Order" is the adopt door. Pinned: `assembleReading(order: X)` is byte-identical to saving X then reading — the preview cannot lie. **The one thing NOT built, deliberately: several NAMED saved orders per book** — that needs stored order profiles, i.e. a §12 lockstep event, which is never a batch's call. Recorded for her in QUESTIONS #46 |
| A32 | Infinite vertical scroll editor — jump to the right part in takes, then back | 13f |
| A33 | Formatting — bold, italics, different sized fonts, some markdown handling | 13g |
| A34 | **"a simple list maker and checkbox maker (like hyphens, [], bullets)"** — added live at the sitting | 13g |
| A35 | LLM folder bridge — save a post as .md in a folder, open one by path, edits sync back | 13h |
| A36 | Markdown folder import choosing whether folders become chapters/books ("to lure people from obsidian") | 13h |
| A37 | EPUB library — read-only books, highlights auto-appending to a "favorite quotes" note with quote marks, dash, author, title | unslotted row |
| A38 | "a variorum mobile app that's quite robust and easy to use" | 15 |
| A42 | **A thorough, beautiful, robust MOBILE app** — added live 2026-07-25, moving Phase 15's material up. Shapes floated and deliberately NOT chosen (hers to rule at the mobile design sitting): a Write-like base · drag-left/right on blocks for their complex menus · a small take button · **or** takes-in-stack-only with expand/shrink. Continues R58; puts CoreDescription pillar 8's "no variant/fan gestures there" in tension — an explicit vision-doc delta, hers to make | **RULED 2026-07-25 — mobile gets its OWN PLAN, decided separately** (she declined all three in-sequence slots; Phase 15's row superseded, an unslotted first-class project row in its place, `notes/plans/mobile-app-plan.md`). The pillar 8 delta is applied — the option text she chose is quoted in the "Further author direction" section. *(Row corrected at the ladder's round 3 beside R3-2: it still read "her call pending" a day after she made the call — the R2-2 class, and the same section this finding was about.)* |
| A43 | **All book views more editable** — *"chapters / posts with blocks within are genuinely helpful concepts."* Extends A39 beyond Outline; scope (Outline + Book, or all three incl. Read) is her call | **13c — SHIPPED as she ruled it: OUTLINE (Batch 2A) + BOOK (Batch 2B); READ stays a reading surface.** Outline's half was already half-true before 2A (the focused post has mounted the full editor inline since Phase 10) and 2A made the surface around it look and behave like a place to write. 2B made Book's pages editable in either form (A44) with ONE live editor across the spread |
| A44 | **Book mode offers TWO editing forms** — the takes STACK and normal WRITE, as the presentation choice for each full-post page in the flipping two-up spread. Instruction, not question | **13c — SHIPPED (Batch 2B).** The two-up spread built with it: page = a whole scrollable post, ◀ ▶ turning the leaf (two at once) beside the ◁ ▷ one-post nudge, bottom bar kept, no slider. The ACTIVE page mounts `TakesBoardView` or the inline Write editor; its sibling stays read-cheap and the ring migrates on click — one live editor in the app, still (the two-boards-two-authorities finding is in the batch record). One spread-level form control, PROVISIONAL — QUESTIONS #44 |
| A45 | **The "sub-takes" finding** — a use-level diagnosis, not a feature request; I7 stands. Raises A39's priority and reframes A21 as a repair tool (see the section above) | **finding — informs 13c** |
| A41 | **The long-block phantom gap** — added live 2026-07-25: an extreme gap below a single long block *"even if there was nothing to indicate that whitespace should be there (i.e. I copied in a long message with no whitespace at the end)"*. **Merged with A3 + A4 as ONE class** (see the section above); her no-trailing-whitespace test eliminates the content explanation and points the investigation at long-block HEIGHT. Her diagnostic was right end to end: 1A measured the mechanism (a 3,000-word block guessing 4,964 pt against 4,597 pt real), 1C measured the remedy, **1E built it (PROVISIONAL, QUESTIONS #39)** — measured in a real window at 7,837 → 7,300 pt, with the document giving back the same 537 pt. | **13c-friction — ADDRESSED (Batch 1E)** |
| A47 | **The take-card gap — added live 2026-07-27 (sitting record below), verbatim:** *"that large open space at the end of a take, without further newlines to click into bug? it still seems present… now the large open gap isn't going away when i click into other blocks, which is good because it's less annoying, but the fact that it exists is still annoying."* Screenshot on record: the TAKES view (stack style), post "Things I want to do before Brazil", a take card with ~60 visible words and a large (~550 pt) un-clickable empty region below the caret INSIDE the card; status bar `blk 28/31 · 52204DF` and **`805w take · 1,727w post`** — a counter-vs-visible-text discrepancy the investigation must explain. This is a PANE surface, explicitly OUTSIDE 1E's detail-editor scope, and it challenges 1C's "panes never carry an estimate" clean-bill claim. Her directive: Fable finds and fixes it FIRST, before Stage 2. **OUTCOME (Batch 1F, 2026-07-27): FIXED at the traced persistence mechanism — the pane frame was a past exact measurement with NO correction path (every remeasure trigger change-gated; the heal one-directional), now closed by the BOTH-SIDES convergence law on `PaneSurface` (same-width layout passes re-check frame-vs-measurement and republish on divergence), red-on-old by behavioral revert (546.0 pt frame held over 293.0 pt of text on the pre-fix code). 1C's clean bill HOLDS (measurement proven exact everywhere; hypothesis 3 refuted); hypothesis 1 refuted by the read-only store (zero trailing newlines; text unchanged since Jul 24); the 805w-vs-60 discrepancy resolved (the screenshot showed the one ~800-word take's TAIL above the void). The BIRTH event is recorded UNIDENTIFIED (launch-adjacent, recurring; candidate table + kills in the batch record) — the fix makes any birth self-heal within one layout pass. Full record: "Batch 1F" under Batch records.** **A47b (2026-07-27, ~15:25): the void SURVIVED the 1F build — Batch 1G traced TWO more real gaps, both fixed + revert-red-pinned (`f285c84`): production delivers ZERO layout passes to an idle card (the check had no trigger — R3-4 one layer up, now fired by scroll-end/click/liveness-transition occasions), and the heal's equal-value state write was a SwiftUI NO-OP when the frame diverged with the state already right (now the frame lever pulls the AppKit frame directly). The 264 chars that left her take the same day were identified to the byte (her last two prose paragraphs + separators, deleted BY HER under the deceptive rendering — laid-out-but-undrawn text; no automatic remover exists, pinned by `TakePaneDurabilityTests`) and RESTORED byte-exact via `restoreCommit` under her authorization, the 3,997 state insured by a manual commit first. `/Applications` refreshed per her "when this issue is fixed". Full record: "Batch 1G" under the A47b section.** | **13c — Batch 1F + 1G DONE (Fable)** |
| A46 | **The DEAD CLICK** — her Q4 answer, verbatim: *"clicking does nothing at all - it couldn't move your cursor into the phantom space and the down arrow couldn't move you down either. nothing was actually there."* Queued as batch 1C. | **13c-friction — INVESTIGATED (Batch 1C): NOT A BUG.** Measured through the real event route: the phantom IS the editor's surface, the click reaches it, and the caret moves — to the document END. It cannot enter the phantom because no text is there, which is her sentence exactly. Down-arrow already agreed correct. **Nothing fixed; characterization pins landed** (`PhantomSpaceTests`) and the weight moves to memo Q3 (option E, now measured). One genuinely un-routed **6 pt** strip at the bottom of every scroll view found and recorded — **AppKit's, reproduced on a vanilla `NSTextView`** — pinned at size so this class can't grow unnoticed |
| A39 | **A book-level WRITE mode** — added live 2026-07-25, verbatim: *"i also feel like I need more of a proper 'write' mode for the whole book - like literally looks like write mode but has the chapter headings and the posts are collapsible. that would be nice."* **Book-shaped ⇒ 13c.** *Open at record time and asked at the sitting: whether this IS what Outline should become (today's continuous vertical scroll, renamed per her 7/23–24 direction) or a FIFTH surface beside it.* **Architectural notes recorded now:** "looks like write mode" means an EDITABLE book-level surface, so Stage 4 lessons 1–2 bind — it adopts `PaneTextAuthority`'s one-live-ring contract (never a second liveness mechanism) and joins `commitTake`'s availability with a `.commit` handler. "Collapsible" follows the block-TOC precedent: collapse is session/view state, **never in-place text folding inside a live TK2 editor** (TEXTKIT2 §3; AppSpec §12's standing rule). Virtualized per P3 like the reading flow (the 13 round-3 MAJOR's lesson). | **13c — SHIPPED (Batch 2A).** Outline is the book's writing surface: Write's OWN prose measure (measured off the realized text surface, not restated — the pre-2A 760pt column was 64pt wider than Write's), chapter headings in the book's voice with real air, the post heading's chrome receded, and posts reading OPEN by default (the model tracks the COLLAPSED set — PROVISIONAL, QUESTIONS #43). The pre-bound architecture held WITHOUT a second mechanism, and that is the batch's main finding: Outline's editable surface IS the full-document editor, so it inherits the one-live-ring contract from `BookViewModel`'s single focus authority (13b 3E's fold) and `commitTake`'s availability from the registry's attached-editor arm — both now NAMED by pins rather than inherited silently. P3 pinned by a DEBUG materialization counter, load-bearing for the first time now that every realized row is a text surface |
| A40 | **Callout coloration** — added live 2026-07-25, verbatim: *"the coloration wasn't working super well on the callout posts and i didn't like that i couldn't see it in write."* Supersedes/absorbs A5's spacing half. **Two readings, NOT guessed between — asked at the sitting:** (i) the frame renders in Write but the colour/spacing looks wrong, or (ii) the frame does not render in Write AT ALL — which would contradict the standing claim that callouts "show up consistently on the editor, the read tier, and the book views" and would be a genuine rendering defect on the surface callouts are *set from*. Trace before fixing (hallucination guard). | **13c-friction** (joins A13(a)'s parity work — same surface, same batch) |

**Not this repo** (acknowledged, deliberately unscoped here): storage
migration, planetlillian.com / stargazing.tech (its own agent — see the
`stargazing-tech` memory), Fragments polish, the YouTube project.

**One technical input recorded NOW so 13g's design sitting doesn't
rediscover it (A33/A34):** `notes/TEXTKIT2_NOTES.md` §3 records that
**`NSTextList` has been broken since macOS 14**, and §1 records Tahoe's
`includesTextListMarkers` split between TK1 and TK2 expectations — so
native TK2 lists are a known-rough area. Markdown-as-content (a typed
`- ` or `[ ]` renders as a bullet/checkbox, the text stays the truth)
sidesteps `NSTextList` entirely, costs zero schema, and keeps export
free — which is a real argument for that fork over attributed runs when
she rules the formatting shape. **Not decided; recorded as an input.**

## Baselines at open (VERIFY with your own runs — the skill's rule)

- **Core `swift test`: 817 tests / 96 suites** green.
- **Mac `xcodebuild test`: 645 tests / 122 suites** green — the count
  the 13b gate verified by execution. NOTE the arithmetic lesson worth
  carrying: the batch records' hand-estimated 648 was wrong by 3 because
  **a parameterized `@Test(arguments:)` reports as ONE test regardless
  of case count** (13b Stage 4 added two 2-seed soaks that were each
  counted as two), plus a retired/migrated pin. Estimate counts that
  way or don't estimate them.
- **Mobile: 11 / 4**, builds clean.
- **The v1_12 lockstep state and the `/Applications` + field-guide seed
  state are recorded in the 13b handoff's checklist** — read it there
  rather than trusting a number copied here.

## Environment traps (the invariant core — the skill's environment section binds; this phase's specifics)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the DerivedData test host matches mid-run since
4G; `/Applications` = hers/real-store); real-store instances by STORE,
not path — NEVER quit/kill one; no Release builds or `/Applications`
refreshes while one lives; Mac suites DO run beside her live app since
4G (the Debug host is `io.lduarte.Variorum.debug`; its container holds
the seeded design corpus); `xcodebuild build-for-testing` compiles
without the runner; Mac tests from `App/Variorum/`, SUITE-level
`-only-testing` only, confirm the "Test run with N tests" line; zsh
`pipestatus` (lowercase); NEVER add a custom build configuration (SPM
builds packages release under any config not named "Debug" — strips
the DEBUG oracles); test windows flash beside a live session — prefer
zero-instance windows for timing-sensitive measurement; the Mac runner
needs an UNLOCKED login session (lock-flag check:
`swift -e 'import CoreGraphics; print((CGSessionCopyCurrentDictionary()
as? [String: Any])?["CGSSessionScreenIsLocked"] ?? 0)'`); backups
WAL-safe with UTC names, ALWAYS before touching the real store (the A1
rail); the real store lives in the SANDBOX CONTAINER
`~/Library/Containers/io.lduarte.Variorum/Data/Library/Application
Support/Variorum/`; drives need unlocked + author-free + own
`caffeinate -d`; osascript System Events menu clicks work
(accessibility granted); fresh hosting views for remounts; a bare
NSWindow auto-assigns first responder on order-front; async-poll
(never sync RunLoop pumping) drains settle hops; screenshots in
gitignored dirs; never `git checkout` over uncommitted work; never
push.

### The "sub-takes" finding — 2026-07-25, and why it is NOT a feature request (A45)

Her words, verbatim, because the reasoning is the valuable part:

> *"I found myself wanting sub takes (which is never going to happen and
> shouldn't happen), which was a sign to me my current takes should've
> been blocks and my block should've been a post (if that makes sense - i
> haven't found using the upper edge of the design that much. i think the
> book views all being editable will help with that)."*

**This is a use-level diagnosis, and it VALIDATES the model rather than
straining it.** I7 (no nesting — a block's variants are whole-span
alternatives, no sub-fans) stays exactly as written; she is not asking
to relax it and explicitly says it *"shouldn't happen."* What she
identified is subtler and more useful: **wanting a sub-take is the
symptom of working one level too low.** The hierarchy that answers it
already exists and is fully built — book → post → block → take — and
her instinct is that a wanted sub-take means the thing she called a take
is really a block, and the thing she called a block is really a post.

**Why she ended up there is a UI fact, not a model fact.** The book
level has never been a *writing* surface — Outline is a scroll, Book is
a spread, Read is a read — so the only place it has ever been natural to
compose is inside ONE post, which forces everything downward into big
blocks with many takes. **She derived A39's value independently and from
the other direction**, which is strong corroboration that A39 is the
right build: making the book editable is what makes the upper edge of
the design reachable in practice.

**Two consequences recorded now:**

1. **A39 gains weight inside 13c.** It is no longer only "a nicer book
   view" — it is the surface that makes the model's existing upper
   levels usable. Prioritize accordingly within the phase.
2. **A21 is the ESCAPE HATCH for the exact mistake she diagnosed** —
   *"turn all takes into their own blocks"* is literally the migration
   from "these should have been blocks" to blocks. It was filed to 13e
   as a convenience shortcut; her finding reframes it as a **repair
   tool** for work already shaped the wrong way. Candidate for promotion
   into 13c beside A39 — **her call, offered, not taken.**

**Standing guard for every future session:** the correct answer to any
future "can I nest takes" is NO (I7), and the correct *response* is to
ask whether the block should be a post. Never invent nesting.

### Further author direction — 2026-07-25 (recorded verbatim-faithful; the questions it raised are hers)

- **Mobile moves up, and gets a real design** (A42): *"i really do need a
  thorough implementation of the app that is beautiful and easy to use…
  it's going to have to be a real and robust option."* Her floated
  shapes, preserved as floated and NOT chosen: a **Write-like base**;
  **dragging left and right on blocks for their complex menus**; a
  **small take button to click**; **or** takes only in **stack mode**
  with a button to expand and shrink it. She is explicitly undecided
  ("either way"), so the shape is the mobile phase's own design sitting
  — do not pre-commit it. **This continues R58** (sitting 8: *"i think i
  will include takes on mobile"*), which was a lean; this is firmer, and
  it puts **CoreDescription pillar 8's "no variant/fan gestures there"
  in tension** — a vision-doc delta that is hers to make explicitly, not
  something a phase absorbs quietly.
- **The book form needs to be more editable** (A43): *"chapters / posts
  with blocks within are genuinely helpful concepts."* Extends A39
  beyond Outline. **Scope question raised for her:** whether "editable"
  means Outline + Book (with Read staying a reading surface, which is
  what Read is *for*) or all three.
- **Book mode offers TWO editing forms** (A44): *"stack view + the normal
  write view should be the editing forms offered in the 'page that
  you're flipping with full sized posts on each page' view."* A direct
  refinement of the committed **Book** mode (two-up spread, page = a
  whole scrollable post): each page is editable, and the page's
  presentation is a choice between the **takes STACK** and **normal
  Write**. Recorded as instruction, not question. Architecture is
  pre-bound as with A39: `PaneTextAuthority`'s one-live-ring contract
  across pages, `commitTake` availability, P3 virtualization — never a
  second liveness mechanism.
- **A42 RULED (2026-07-25): mobile gets its OWN PLAN, decided
  separately** — she declined all three in-sequence slots offered
  (after 13c · after 13e · after formatting) and chose to decouple it
  from the phase sequence entirely. Phase 15's row is **superseded**;
  mobile becomes an unslotted first-class project row beside the Apple
  Notes import and the Design & UI review, starting at her word. Its
  standing inputs — her four floated interaction shapes preserved
  UNCHOSEN, what binds, the open questions, the inherited iOS
  trailing-newline defect — are collected in
  **`notes/plans/mobile-app-plan.md`** so they never depend on this
  session. **The pillar 8 delta is APPLIED with her explicit blessing**
  (full version, not hedged): takes ARE included on mobile; "smaller
  than the Mac" survives as the rule; the journal-restrictions-are-a-
  UI-profile half is untouched.

  > **THE RULING, IN THE WORDS SHE WAS SHOWN AND CHOSE** *(added
  > 2026-07-26 at the Stage 1 ladder, round 3 — finding R3-2, and it is
  > my error being corrected: this is the phase's ONE change to a
  > canonical VISION document, and it was the one ruling recorded
  > without her words. Every other ruling in this file carries a
  > verbatim quote; this one carried my paraphrase of its effect, while
  > the two quotes that ARE on the record — R58's "i think i will
  > include takes on mobile" and this intake's "quite robust and easy
  > to use" — are both WEAKER than the wording that was applied. Her
  > standing instruction is "don't add more certainty than I have", and
  > it binds hardest here. She did explicitly choose this, but from a
  > presented option, so the honest record is the OPTION TEXT, quoted —
  > not a restatement of what it did.)*
  >
  > She was asked whether to record takes as included on mobile, and
  > selected the option labelled:
  >
  > **"Yes — record takes as included on mobile (Recommended)"**
  >
  > whose description, as shown to her, read:
  >
  > *"Rewrite pillar 8 to say mobile is a smaller surface but DOES
  > carry take viewing and the gestures the mobile design settles on,
  > superseding the no-fan-gestures line. Keeps the 'journal
  > restrictions are a UI profile, never a separate data model' half
  > intact — that part is still true and load-bearing."*
  >
  > **CoreDescription pillar 8's current wording is what she blessed and
  > is deliberately NOT re-worded by this correction** — the gap was the
  > record, not the text. What "the gestures the mobile design settles
  > on" turn out to be is the mobile design sitting's, exactly as the
  > option says and as `notes/plans/mobile-app-plan.md` records.
- **A43 RULED (2026-07-25): Outline + Book are editable; Read stays a
  reading surface.** Her pick, and the reasoning she was given and
  accepted: Read's value as a distinct mode IS that it is a place to
  just read — and true pagination plus live editing is the hardest
  combination in the stack to keep stable (TEXTKIT2 §2). So Outline
  becomes the book's writing surface (A39), Book's full-post pages
  become editable with the stack/Write presentation choice (A44), and
  Read keeps the flow + true-pagination pair as a reading experience.
  R8/R23's "everything visible in an editing surface is editable" is
  honored precisely — Read is not an editing surface.
- **Answered for her on the record:** *"i'm also not sure where in the
  plan 'make all takes under a block into their own block' is"* — it is
  **ledger row A21**, from her own intake list ("Copy all takes to the
  clipboard, **or turn all takes into their own blocks**"), currently
  owned by **13e**. See A45 above for why it may deserve to move.

### AUTONOMY GRANT — 2026-07-25 (her directive; this governs the rest of the phase)

Her words: *"once you've found the source of the issue, please fix it
and continue with the rest of the 13c phase all the way through."*

**What this authorizes:** run every batch, the review ladder, and the
closeout without returning for a sitting between them. Fix the vertical-
space root cause once Batch 1A has *identified* it (the confirm-first
discipline is unchanged — the grant is to fix what is found, never to
skip finding it).

**What it does NOT authorize — the standing author-only hard stops are
untouched by it** (CLAUDE.md): inventing product behavior; violating or
relaxing any invariant (I1–I10, P1–P3, S1–S5); adding a dependency;
contradicting the canonical docs beyond recording deltas she has
explicitly ruled; anything needing her accounts, credentials, or GUI
steps; **any mirror/schema deploy** (SyncSpec §12 — hers explicitly, the
R53 precedent); deleting or overwriting anything she created; pushing.

**The operating rule for everything ambiguous in between:
PROVISIONAL-and-continue** — the R55/architect-phase shape: write 2–3
options into the record, implement the most spec-defensible one, mark it
**PROVISIONAL**, log it to `notes/QUESTIONS.md`, and **bundle it into
the closeout's ratify list** rather than stalling the run on a question
she is not present to answer. This explicitly covers the product-flavored
calls this phase already knows it owes her:

- **N38's five rulings** (`phase-13c-memo-smart-to-curated.md`) — the
  memo recommends shape A; build to A as PROVISIONAL, record what each
  alternative would have changed, and put all five on the ratify list.
- **The uniform-page brief's five open questions** — same treatment.
- **The C3 block-extent memo's product edges** — the memo is still
  WRITTEN as P-5 requires (edges enumerated on paper, not discovered by
  her), and its happy path built to the most spec-defensible reading;
  its genuinely taste-flavored calls are ratify-list items, not guesses
  presented as decisions.

**Held for her regardless of the grant** (bundled into the handoff
checklist, never improvised around): any `/Applications` refresh that
would outrun a deployed lockstep marker, the A21-promotion offer, and
anything the ladder cannot resolve against the canonical docs.

### The overnight run — 2026-07-25 → 26 (her authorization + the regime)

Her words: *"i'm stepping away for the night, so go ahead and run any
tests and screenshot verification things that are needed while i'm
asleep."* Combined with the autonomy grant above, this is a full
overnight run: batches, suites, screenshot walkthroughs, the ladder.

**The one environment act taken on her machine, stated plainly so she
finds it in the morning:** `caffeinate -d` is running (11 h cap, pid
recorded at start). **Why it is necessary and not incidental:** Stage 4's
recorded environment lesson is that **the Mac test runner hangs
pre-connection under a locked login session** — and 13b's gate failed for
exactly this reason (six batches of app-side tests written but never
executed because her machine auto-locked overnight; when they finally
ran, three failed and two were real defects). Without holding the
session, "run tests while I'm asleep" is not actually possible. **Side
effect she should know about: her display stays awake.** It expires on
its own; `kill <pid>` or `pkill caffeinate` ends it early. Nothing else
about her machine is touched.

**What CANNOT happen overnight, regardless** (author-only, unchanged):
any mirror/schema deploy; any `/Applications` refresh that would outrun
the deployed lockstep marker; quitting or killing her live app instance;
pushing. Her real store is read-only to this run except behind the A1
backup rail.

**What gets bundled for her instead of guessed:** the C3 memo's five
questions (Q4 now answered by her; Q3 revised), N38's five rulings, the
uniform-page brief's five opens, the A21-promotion offer, and the
jump-landing taste call. All go to the closeout ratify list.

### THE PHASE RUNS AS TWO STAGES — architect decision, 2026-07-26 (mid-run)

Adopted once the friction work proved to be a coherent body of its own.

- **Stage 1 — FRICTION: batches 1A · 1B · 1C · 1D(+addendum) · 1E.**
  Her daily pain: the geometry mis-mappings, block deletion and redo, the
  dead-click verdict, the bridge, and the phantom fix. **Its ladder runs
  when 1E lands**, then its fixes, then **`/Applications` is refreshed**.
- **Stage 2 — BOOKS: batches 2A · 2B · 2C · 2D · 2E**, its own ladder,
  its own refresh.

**Why two stages rather than one ladder at the end** — three reasons, and
the third is the one that decided it:

1. It is what "one ladder per stage over the combined diff" means when a
   phase has two genuinely different bodies of work. Stage 1 is
   editor/bridge defect work; Stage 2 is new book surfaces.
2. A single ladder over both would review ~10 batches of diff at once,
   which is how findings get missed.
3. **She wakes up to REVIEWED, working fixes rather than to a promise.**
   The friction items are what she reported as hurting daily; getting
   them through review and into her actual daily-drive build overnight is
   worth more than holding them behind book work that may not finish.

**The refresh is legitimate and its preconditions are checked, not
assumed:** CLAUDE.md's standing rule is that any session changing the Mac
app ends by refreshing `/Applications`; **no schema change has landed
this phase**, so no install can outrun the deployed lockstep marker (4)
and the §12 hold does not bind; and a refresh requires zero instances at
build and copy — **verified zero at this decision** (`pgrep` clean,
2026-07-26). If an instance is live when the moment comes, the refresh is
**HELD**, not forced — she may have opened the app.

> **THE REFRESH IS HELD UNTIL THE LADDER CLOSES — recorded at round 2
> (R2-5), because it was only inferable before.** `/Applications` is still
> 13b's build (mtime Jul 22) and Stage 1's stated deliverable was that she
> wakes to reviewed, working fixes in her daily-drive build. That has not
> slipped; it was always to follow the **CLOSED** ladder, and the ladder
> did not close: round 2 found the comment-destroying carve (R2-1), so a
> refresh at that moment would have shipped exactly the defect the
> two-stage split exists to catch. **That is the plan working, not
> failing.** The rule, now written rather than inferred: **the refresh
> happens after round 3, and is skipped only if round 3 leaves something
> open.** The zero-instance precondition is re-checked at that moment, not
> carried forward from this one.

## Batch briefs

### Batch 1A — the vertical-space investigation (the friction batch's first half)

**Why these together:** every item here is about how much VERTICAL SPACE
a block owns in a TK2 flow and who is allowed to draw in it. Splitting
them would hand two sessions half a picture each.

**Scope:** A3 + A4 + A41 (one investigation — the long-block phantom
gap, the jumping tall block, the vanishing-on-scroll empty paragraphs) ·
A40 (the callout frame misaligning, "the color spreads underneath it") ·
F1 (the `PaneSurface` publish-door hardening — she ruled it in).

**Read these sections of this file, in this order, before touching
code:** "A3 + A4 + A41 are ONE class", "A40 refined by the author", the
"First acts — DISCHARGED" section's F1 finding, "Binding principles"
(P-1…P-9, verbatim), "Stage 4 lessons", "Environment traps". Then
`notes/TEXTKIT2_NOTES.md` §2 and §3 IN FULL — this batch lives in the
subsystem that file exists to warn about — and AppSpec §15 risk 2.

**The order of work is fixed, and it is not "fix the bugs":**

1. **CONFIRM OR REFUTE the recorded hypothesis first, with a pin.** The
   hypothesis (one-directional convergence in `PanePublisher`, so an
   over-large measured height is never corrected downward) is traced
   from code but **NOT reproduced**. Build the pin as the confirm: red
   confirms and you proceed; green means the hypothesis is DEAD, you say
   so plainly in the batch record, and you keep tracing. A wrong
   hypothesis killed cheaply is a good outcome. A fix built on an
   unconfirmed one is the forbidden class.
2. **Then split what you found by what it actually is.** A mis-mapping
   or a missing convergence direction is a BUG: fix it at the one place,
   red-on-old pin verified by behavioral revert. An ambiguity — the
   block's visual extent genuinely having no defined answer once stored
   trailing newlines, the uniform per-paragraph gap, and the comment
   strip all want the same space — is **NOT a patch under P-5**. Stop,
   and write it up for the C3 memo instead of guessing a number.
3. **F1's hardening rides whatever you touch in `PaneSurface`:** make
   the one-publish-door guarantee ENFORCED rather than commented — a
   walk-style pin asserting the coordinator writes no SwiftUI state
   outside `publisher?.`, or the type-level shape where `install` takes
   a single value only `PanePublisher` can consume. Either is fine;
   state which you chose and why.

**Hard constraints:** P-8's overlays-never-rendering-attributes stands
(TEXTKIT2 §3's fragile class). P-3 — you may extend `PaneSurface`, never
add a second measurement brain or a second liveness mechanism. The
full-document editor is NOT absorbed into the pane surface (the
constitution's application note). Do not change the 2026-07-12 spacing
ruling's semantics: stored trailing newlines are content, the
presentation gap is per-PARAGRAPH and uniform, and `renderedText` /
export / the bridge join must stay byte-identical — pin that they do.

**Deliverables:** the fixes that are genuinely bugs, each with a
revert-verified red-on-old pin; a batch record in this file's "Batch
records" section (the 13b form — commits, counts before → after, traced
mechanisms, numbered judgment calls, red-on-old evidence, deviations
with reasons); and, if step 2 finds ambiguity, the **C3 memo draft**
(`notes/plans/phase-13c-memo-block-extent.md`) — behavior whole, edges
enumerated, refusal wordings where relevant, and a plain-language
tradeoff list for the author, per P-5's form. Counts at batch open:
core **817/96**, Mac **652/123**, mobile 11/4 — all verified green by
the architect this sitting.

### Batch 2A — OUTLINE becomes the book's writing surface (A39, A6, the rename)

**Read first:** committed scope item 1 and its indented **"Author
direction captured 2026-07-23/24"** block (her binding book direction),
the **A39 ledger row** (its architecture is pre-bound — do not re-derive
it), the **A45 sub-takes finding** (it is *why* this batch matters more
than it looks), and the **A43 ruling**.

**Three things, in this order:**

1. **The segmented picker becomes `Outline · Book · Read`** (from
   `Book · Pages · Read`). Naming flag already raised with her:
   "Outline" also named the retired post-level tab folded into Compare —
   different surface, no hard collision.
2. **Remove the ENTIRE bottom inset from Outline** (`BookView.swift`
   ~512–552): both the `Slider` jump control — *"it makes no sense to
   have a horizontal scrollbar on a vertical page"* — **and** the
   `ProgressView` above it. She RULED the progress bar out too: *"it
   seems a bit buggy… remove it fully for now, I'll add it later if I
   feel inclined."* **If it is ever re-added, the bugginess she saw gets
   investigated FIRST** — an observed defect parked by removal, not
   chased now. Outline ends as a clean vertical-scroll read + the
   navigator, no bottom chrome.
3. **Outline becomes the book's WRITING surface** — the batch's real
   work. Her words: *"a proper 'write' mode for the whole book - like
   literally looks like write mode but has the chapter headings and the
   posts are collapsible."*

**Why this matters more than a view change — read A45.** She wanted
sub-takes, refused the idea herself, and diagnosed the cause: *"my
current takes should've been blocks and my block should've been a post…
i haven't found using the upper edge of the design that much."* The
reason she works one level too low is that **the book level has never
been a writing surface**, so the only natural place to compose has been
inside one post. This batch is the fix for that. Build it as the place
she writes a book, not as a decorated list.

**What binds — do NOT relitigate any of it:**

- **`PaneTextAuthority`'s one-live-ring contract** (Stage 4 lesson 1):
  this surface ADOPTS the authority. **Never a second liveness
  mechanism.** Exactly one live pane across the whole app, still.
- **It joins `commitTake`'s availability AND registers a `.commit`
  handler** (Stage 4 lesson 2 — `takeFamilyPlusEditableBoards`). A new
  editable surface that skips this ships the N5 class again.
- **Collapse is SESSION/VIEW state** — the block-TOC precedent — and
  **never in-place text folding inside a live TK2 editor** (TEXTKIT2 §3;
  AppSpec §12's standing rule). This is not negotiable; it is the one
  thing that subsystem is worst at.
- **Virtualized per P3.** The Phase 13 round-3 MAJOR was exactly this
  surface's sibling shipping as a plain `VStack` with cost ∝ book size.
  `LazyVStack` + a DEBUG materialization counter as the pin.
- **Chapters are `reading_section` rows** (AppSpec §7/§9). Render them
  inline as headings; a dangling `section_id` reads as **unsectioned**;
  unfiled posts **TRAIL** the chapters (ratified, QUESTIONS #26(b)).
- **P-1:** every act this surface offers is DECLARED in the registry.

**PROVISIONAL territory (use the autonomy grant, do not stall):** how
chapter headings render in Write's typography; whether collapse state
persists per book within a session; what a collapsed post shows (title?
first sentence — the `tocHandle` read-time rule already exists). Record
2–3 options, pick the most spec-defensible, log it.

### Batch 2B — BOOK: the two-up spread, editable (A43, A44)

**Read first:** committed scope item 1's author-direction block, and the
**A43/A44 rulings**.

**What it is, in her words:** *"basically like [today's] Pages but with
two posts side by side… new compared to what we have"*, and *"more like
a lens column, for comparison."* **Each page is a WHOLE POST, vertically
scrollable and fully contained — a post does NOT flow across pages.**
That is what distinguishes Book from Read: Book paginates by *post*,
Read paginates by *text*.

**Flip navigation (ruled):** the default advances **TWO posts at once**
(turn the leaf), **plus a single-step control** — her sketch, *"a half
arrow button or something"* — that nudges the spread by ONE post, so she
can re-pair when turn-the-leaf splits two posts she wanted side by side.
Arrows navigate too. **KEEP the bottom bar** here (unlike Outline, where
it is removed). **No horizontal scrollbar** — that was her complaint
about the current surface.

**Editable, with TWO forms (A44):** each page offers the **takes STACK**
and **normal WRITE** as its presentation. Same bindings as 2A, restated
because they are absolute: `PaneTextAuthority`'s one-live-ring contract
across pages (**one live editor in the whole app, still**), `commitTake`
availability + a `.commit` handler, P3 virtualization — realize the
spread, not the book.

**PROVISIONAL territory:** whether the stack/write choice is per-page,
per-book, or global; where its control lives. Options, pick, log.

### Batch 2C — READ: true pagination (C1, the uniform-page brief)

**Read `notes/plans/phase-13c-uniform-page-view-brief.md` IN FULL** —
4F authored it as the condition of deferring this work, its settled
facts are cited rather than re-derived, and **its five open questions are
PROVISIONAL under the autonomy grant** (she is asleep; record options,
pick the most spec-defensible, log to QUESTIONS).

**What it is:** Read becomes the Apple-Books/Kindle **pair** of modes —
**(a) vertical infinite scroll** (today's `ReadingFlowView`, already
virtualized as of Phase 13's round-3 fix) and **(b) TRUE BOOK
PAGINATION**: a **TWO-PAGE SPREAD** of horizontal pages each holding a
SET amount of text, with text flowing across identical fixed pages. Mode
(b) IS the brief's hard two-tier estimated/measured pagination. **KEEP
the bottom bar on the paginated sub-mode**; arrows navigate.

**Read is NOT editable** (her A43 ruling) — it is the reading surface,
and that is what makes it a distinct mode rather than a third editor.
R8/R23 is honored exactly: Read is not an editing surface.

**What binds:** the brief's two-tier pagination lives **outside the
editor stack**; the scrub domain is **estimated pages**; realization is
**spread-only and lazy** (P1 — the Stage 4 realization-bound discipline:
the realized set is a pure function of the inputs, DEBUG counters are the
pin form). **Model-driven navigation** (the Phase 6 ruling, Stage 4
lesson 8): page domains ride the post list and stored estimates, **never
live TK2 geometry**.

**Cross-check with 1C's finding before you trust any height:** TK2's
estimated geometry over-reports (measured 4,964 vs 4,597 pt on one
block). A paginator that trusts estimated heights will paginate wrong and
then re-paginate under her. Say explicitly in your record how your
estimator behaves when a block's layout state flips from estimated to
laid-out.

### Batch 2D — the smart→curated conversion (C2/N38) + book order as a lens (A31)

**Read `notes/plans/phase-13c-memo-smart-to-curated.md` IN FULL.** 4F
authored it as the condition of deferring this work; it presents three
conversion shapes and recommends **A (materialize-and-convert + the
fresh-smart-book offer)**, with zero schema change confirmed for A.

**Her five rulings are OWED but she is asleep.** Under the autonomy
grant: **build to A**, mark the whole thing **PROVISIONAL**, and for each
of the five record *what the alternative would have changed* so her
ratify walk is a real choice and not a rubber stamp. Log to QUESTIONS.

**A31 rides with it** — her intake item: *"I need the ability to see a
book either by its saved custom order or by an attribute like time to
freely change the order of it - should be more like lenses where the
order can be saved."* It is book-shaped and conversion-adjacent (both are
about a book's membership and ordering being something she can shape).
**Note what already exists before building anything:** `reading.sort_field`
already carries `manual | entry_date | created_at | last_touched |
last_major_revision` with `sort_dir` — so "see it by an attribute" may be
mostly a face over shipped machinery. Her "**saved** like lenses" half is
the part that may need design; treat it as PROVISIONAL and say plainly
which half was already there.

### Batch 2E — Compare: "show related blocks only" (C4)

**Her request, verbatim (2026-07-22):** *"we should have a setting to
only show related blocks - that would make the pane feel more usable."*

A per-view toggle (session/view-local — the follow-order/lineage-colour
toggle class from 13b's 4C; **no schema**) that collapses each column to
only the blocks with lineage kinship to the anchor, hiding the unrelated
stretches.

**This RESOLVES the 4C kin-less-peer PROVISIONAL** rather than needing a
separate placement ruling (13b plan, Batch 4C judgment call 0: a peer
with no kinship renders its whole post below every aligned row). With the
setting ON, an unrelated peer simply shows nothing and a partly-related
one shows only its kin rows. **Her call at ratify:** whether "off" keeps
today's shipped placement — the setting may make the placement question
moot, which is the outcome to aim for.

**Compose with N29's honesty line, do not break it:** an all-unrelated
pair with the setting on must **say** "there is no relationship here"
over two empty columns, never present emptiness as if it were content.
That honesty is the whole reason 4C's gap parade was killed.

**PROVISIONAL:** whether "related" means direct `derived_from`/
`version_of` or the transitive lineage the alignment already computes.
Options, pick, log — and note that the alignment machinery already has an
answer it uses, which is the cheapest defensible one.

### Batch 1E — BUILD option E (the phantom fix), PROVISIONAL

**Authorized by the architect decision in the 1C adjudication.** Batch 1C
measured E and it is alive; this builds it. **Read 1C's record and the
memo's Part 2 + Q3 appendix first — the measurements are yours to build
against, not to re-derive.**

**What it is:** when the viewport is looking at a block whose layout TK2
has only *estimated*, ensure layout for **that one block's own text
range**, once. Its over-guess collapses, the phantom below it goes, and
TK2 keeps the layout (measured: survives scrolling away and back).

**What it is NOT, and this is the whole risk:** document-scale layout.
P1 binds cost to what is on screen and what is being edited — E is
inside that only while it stays **one block, once**. The cost is not the
danger; **the trigger is**. Build accordingly:

1. **A hard block-size cap.** Above it, skip and record — never a hitch
   the author would feel. Pick it from 1C's measured table (20 ms at
   25,000 words is already past a frame budget) and state your reasoning.
2. **At most ONCE per block per session — pinned.** TK2 does not discard
   the layout, so a second pass is pure waste and a symptom of a trigger
   bug. The pin is the guard against the failure mode that would make
   this a P1 problem.
3. **A kill switch** — she must be able to turn it off having felt it.
4. **The refresh nudge:** 1C measured that the scroll extent corrects on
   the NEXT display pass, not synchronously (9,063 → 8,708 pt one pass
   later). Handle it, and do not introduce a layout loop doing so.

**Mark the whole thing PROVISIONAL** and log it. **Q3 remains hers** —
this build is so she can rule having felt it rather than from a table.

**Do not** touch the memo's Parts 1 and 3 (her rulings pending), and do
not chase A46 — 1C closed it.

### Batch 1D — the bridge (A1, A2), queued behind 1C

**A1 — Fragments-landed journal entries arrive BOOKLESS. Traced by the
architect, so build from the trace:** `BridgeEngine.swift:254` calls
`ops.createOrOpenJournalEntry(entryDate: day)` **and stops**. The Mac's
own daily door (`BookStructureModel.swift:240-242`) calls the same thing
**and then** `addPostToReading(entry.container.id, to: readingID)` into
the designated daily journal book. The bridge path never got that second
half — so a Fragments-landed day is a journal post in no book, and
"posts in no book" is exactly what the Pool surface shows. Her report
(*"fragments journal did sync and appear, but not in the journal book,
just appeared in the pool"*) is precisely this.

**Make the two paths agree**, and handle the same error cases the Mac
door already handles (`alreadyInReading`, `lockedReading`,
`readingAtCapacity`) — read that door and mirror its semantics rather
than inventing new ones.

**The one genuine design question, and its guard rail:** what if **no
daily journal book is designated yet**? The Mac door *creates and pins*
one. A headless bridge minting and pinning a book on her shelf without
her is a bigger act. **The landing must NEVER be blocked by this** —
"nothing typed in either app can be permanently lost" is ratified
doctrine and outranks tidiness, so the entry lands regardless. Options:
(i) land, and skip membership silently; (ii) land, skip membership, and
surface it in the bridge status row; (iii) land and create the book as
the Mac door would. **Implement the most spec-defensible, mark it
PROVISIONAL, log it.** My lean, for what it is worth: (ii) — the entry
is never lost, and she learns why it is not on her shelf.

**A2 — the bridge "doesn't seem to refresh often enough."** Trace before
tuning. Known and relevant: bridge rounds **ride sync rounds**
(`SyncSession.onRoundCompleted` — after sync, never interleaved, pinned
at 9b), and cadence triggers are throttled to a **60 s minimum round
interval**. That throttle was ratified (QUESTIONS #15) but explicitly as
*"an engineering default of the `settleDebounce` class — adjust freely"*,
so tuning it is not a re-litigation. **But check the likelier cause
first:** if bridge rounds ride sync rounds, then bridge freshness is
bounded by SYNC cadence, and she was signed out of sync entirely from
2026-07-20 to 2026-07-25 — which would have starved the bridge of rounds
for five days and may be the whole of what she felt. Report what you
find; adjust the default only if the trace justifies it.

**Scope guard:** `Sources/VariorumCore/Bridge/` is bridge code, NOT
`Sources/VariorumCore/Sync/` — the standing sync-engine-surgery rider
does not apply here. **If a fix would require touching `Sync/` itself,
stop and report to me** rather than proceeding.

**Never regress:** unchanged text must never push (pinned to the
server's write counter); the duplicate-day pause; the fail-closed
canonical-user gate. These are 9b's hard-won guarantees.

### Batch 1C — the DEAD CLICK (A46), queued behind 1B

**Her answer to the memo's Q4, 2026-07-25, verbatim:**

> *"clicking does nothing at all - it couldn't move your cursor into the
> phantom space and the down arrow couldn't move you down either.
> nothing was actually there."*

**This is a FOURTH bug and it was explicitly offered as one.** Batch 1A
asked the question with the two outcomes named: caret-lands-at-end
(benign, the phantom behaving as phantom space does) versus click-does-
nothing (a separate defect worth finding). She reports the second.

**Why it is a defect, mechanically:** clicking below the last line of an
`NSTextView` places the caret at the nearest text position — the end of
the document. Hers does not move at all. So the phantom region is not
merely empty, it is **not being handled by the text view**: either the
click lands on something that is not the editor (a container, an inset,
an overlay eating the hit), or the editor's clickable area stops short of
the area it is displaying. The DOWN-ARROW half is correct behaviour and
should NOT be "fixed" — there is genuinely no text below, so the caret
has nowhere to go. **It is the dead click alone that is wrong.**

**Scope:** trace it, and fix it if it is independently fixable. It may
have a cause entirely separate from the over-estimate — in which case it
is fixable **without** touching the estimate, which would be the best
outcome available. Check the hit-testing path and the editor's frame
versus its enclosing scroll view's document area, and check whether any
overlay (the decoration hosts batch 1A just touched, the block tint, the
comment strips) is intercepting.

**Consequence recorded for the memo:** this **upgrades Q3**. Option A
("do nothing, it's cosmetic") was recommended on the premise the phantom
is harmless; that premise is now false. The memo's recommendation is
revised to *measure E first, A as fallback*.

**SECOND SCOPE ITEM — MEASURE option E (do not build it).** The memo now
recommends *E measured first*, and I promised her in writing that E would
not be built on arithmetic. So this batch **measures and reports, and
stops there**: instrument `ensureLayout` over a SINGLE long block's own
text range (the block on screen or just below), at several block sizes,
and report (a) the wall-clock cost per block size, (b) whether it
actually collapses the phantom for that block, and (c) whether the effect
survives scrolling away and back or has to be re-done. Compare against
the Phase 6 spike's measured document-scale rate (105 ms / 50k words) so
the numbers sit on the same axis. **If the numbers are bad, say so** —
"E is dead, A stands" is a completely acceptable and useful outcome, and
is why this is a measurement and not a build. Record the result in the
memo under Q3 so she rules on evidence.

**Related but distinct — do NOT conflate:** her **A22** ("scroll down
into at least a page of empty space so I can keep the text I'm typing
high up on the page") is *wanted* space, not phantom space. If A22 is
built later, its space must not feel dead the way this does — clicking in
deliberate trailing room should place the caret at the document end.
Recorded so the two are designed together rather than fighting.

### Batch 1B — block deletion & redo (A7, A8, A10)

**Why together:** all three are the structural/undo family, and redo is
the safety net that makes an accidental block deletion cheap.

**Scope, in her words:**

- **A7** — *"I cant use backspace to delete empty blocks with no takes
  right now which is too annoying - especially when there's an empty
  block right at the start of the post."*
- **A8** — *"I don't seem to have the ability to delete / archive empty
  blocks?"* (`deleteBlock` exists in Operations and has since Phase 2;
  what's missing is a door and, for A7, the editor gesture.)
- **A10** — *"i desperately need a 'redo' command to be able to undo my
  structural undos for when that was an accident."* **Verified by the
  architect: no `redo` / `redoStack` / `canRedo` exists anywhere in core
  or the app.** Structural undo is one-directional by omission.

**What binds:**

- **Redo is STRUCTURAL redo only.** ⌘Z stays NSTextView's ordinary text
  undo and the two stacks never interleave (AppSpec §9's structural-undo
  paragraph, ratified). Session-scoped and in-memory like the undo stack
  — no persistence across sessions; that line is deliberate.
- **Redo emits ordinary operations**, exactly as undo does, so sync never
  learns redo exists (same reasoning as undo's design).
- **The redo stack clears on any new structural act** — the standard
  discipline; state it and pin it.
- **A7 is a cross-block destructive edit at a seam**, which the editor
  has REFUSED since Phase 7 by ratified design. Deleting an EMPTY block
  is the case where that refusal buys nothing — there is no text to lose.
  Keep the general refusal; carve the empty case honestly, and make sure
  the carve cannot widen (a block with text, or with takes, still
  refuses). Under P-2 the door must act or speak — never silently no-op.
  The post's FIRST block being empty is her named case: pin it.
- **I10 stands absolutely:** a live block has at least one live variant,
  and deleting a block's last block is `deleteBlock`, never a variant op.
  If the post would be left with no blocks, that is a real refusal —
  decide it against the spec and say which rule you applied.
- **P-1:** any new act is DECLARED in the registry (verb, scope,
  availability, doors, refusal copy) — never a per-view if-statement.

**Deliverables:** the fixes with revert-verified red-on-old pins; a batch
record; PROVISIONALs for anything the spec leaves genuinely open, per the
autonomy grant. Counts at open: core **817/96**, Mac **668/125**.

## Stage 1 review ladder

### Round 1 — findings + dispositions (2026-07-26, fresh cold reviewer, `REVIEW_PROMPT.md` verbatim, zero framing)

**0 BLOCKER · 2 MAJOR · 6 MINOR · 4 NIT.** The reviewer verified both
suites by its own runs (core 848/98, Mac 719/129 — matching exactly) and
confirmed zero `Sources/VariorumCore/Sync/` lines touched. **Every
finding carries a traced mechanism; I agree with all of them.**

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R1-1 | **MAJOR** | **A7's carve fires on blocks that DO have text to lose.** The guard uses `activeVariantCount`, which excludes archived takes — but archived takes carry prose. Reachable in three ordinary gestures: branch a take, `archiveVariant` the one with prose (legal — the other is still active), blank the survivor (R90's power gesture). The block now renders empty with `activeVariantCount == 1`, so a seam backspace runs `deleteBlock` and cascades the archived prose out, while the status line says *"Empty block deleted."* | **AGREED — FIX.** The carve was granted *only* on "there is no text to lose", and that premise fails here. Recoverable via ⌥⌘Z and the tray, so not data loss — but the narrowness contract is what the carve was authorized on, and none of the nine cannot-widen pins covers archived takes. Fourth guard: count live variants regardless of `status`. |
| R1-2 | **MAJOR** | **Three shipped semantic changes are absent from canon:** (a) structural REDO — AppSpec §9 and OverallModel §3 still describe a one-directional stack; (b) `Operations.shelveInDailyJournalBook` is a new *public* operation and §9 opens "Every mutation is one of these"; (c) A7's carve is a named exception to the ratified cross-block refusal and §14 does not record it. | **AGREED — FIX, and part of this is MY miss as architect.** I wrote the §14 delta for the kickoff *rulings* and the two canon corrections, and did not extend it as Stage 1 shipped. The reviewer is also right about *when*: **at the Stage 1 fix pass, not the closeout** — Stage 2 and 13d build on these, and a fresh session reading canon would not know redo exists. This is exactly the class the phase's own opening obligation 2 warned about. |
| R1-3 | MINOR | **Raw `String(describing: error)` reaches two new user-facing surfaces** — her bridge status row can read *"…: wrongReadingKind(id: "8F3C-…", expected: VariorumCore.ReadingKind.curated)"*. The same batch retired this exact pattern in `ShellActions` one file over. | **AGREED — FIX.** Give `DailyBookShelving` a `.wrongKind` case (the enum already models the other named refusals). Pin: the note contains no `(id:`. |
| R1-4 | MINOR | **⌘J and the new shared helper disagree on rule 2** — the rule the batch record called "the good one". The helper treats any membership row, live or tombstoned, as decided; `openToday` catches only `alreadyInReading`, which fires on *live* rows, so a tombstoned membership is invisible and it re-inserts. She removes today's entry from the Journal book, presses ⌘J → it is silently back on the shelf, while the bridge and phone correctly leave it alone. | **AGREED — FIX.** The brief said "make the two paths agree"; the deliberate non-conversion was justified by the *create-and-pin* difference, which is orthogonal to rule 2. `openToday` keeps create-and-pin and delegates the ensure half. |
| R1-5 | MINOR | **The cap's stated safety margin is not real** — `ensureLayout` runs in the system TextKit binary, identical in Debug and Release, and no app code runs in that path (no layout-manager/content-storage delegates exist). So "margin on top of margin" buys nothing — and **QUESTIONS #39 repeats it to her verbatim.** | **AGREED — FIX, and this one matters disproportionately** because it is the honesty of what she is being asked to *rule from*. The number still stands on the 8.3 ms budget; only the claimed extra headroom is illusory. Strike the clause from all three carriers, or take one Release measurement and record the real figure. |
| R1-6 | MINOR | **The F1 walk misses two write forms** — `self.height = x` and `$height.wrappedValue = x` are counted in neither bucket, so a write could escape the door while the equality assertion passes. | **AGREED — FIX.** Precisely the "green by audit" gap F1 was raised about, one level deeper: the guard against un-routed writes had an un-guarded route. |
| R1-7 | MINOR | **Redo *correctness* is pinned for 9 of 21 sites**, and `archiveVariant`/`deleteVariant` — which have their own re-apply bodies carrying the I10 `ensureNotLastActive`, locked-variant, chosen-variant and `reassignDefaultIfNeeded` guards — are exercised by no redo test at all. | **AGREED — FIX the sharp end.** Two round-trip pins (delete-the-default with three takes; archive-then-undo-then-redo) close it cheaply. The rest reuse pinned bodies. |
| R1-8 | NIT | **`QUESTIONS.md` structural damage** — the new 13c section was inserted beneath the "Phase 13, Stage C" heading, orphaning it and re-parenting #27/#28; entries are also out of numeric order. | **AGREED — MY error, fix.** That file is the ratify-walk surface she reads top to bottom. |
| R1-9 | NIT | **"All 23 registration sites" is not locatable** — 21 + the compound's own + a synthetic test site = 22 at most. | **AGREED — correct the number.** The claim is load-bearing for the totality argument, so it must match what a reviewer can count. |
| R1-10 | NIT | **A compound that throws mid-body destroys the redo future** even though its partial work rolls back. | **AGREED — record it.** Defensible under "any new structural act clears the future"; worth one line of comment either way. |
| R1-11 | NIT | **`try?` swallows a bridge read failure into "nothing to shelve"** with no note, so a transient failure looks like a day with no entry — the one silent path in an otherwise speaking flow. | **AGREED — FIX.** |

**Clean bill worth carrying forward** (things it checked specifically and
found solid): 1E writes nothing to the store (S1–S5 untouched); its
trigger bound is real and `decide` is pure and total; **the 1E scoping
rationale holds at every pane host** — all three callers of the one
measurement brain go through `PaneMeasurement.height`, which lays out
first, so no pane can carry an estimate and 1C's "not reproduced
elsewhere" is a *mechanism*, not an absence of evidence; the 1A geometry
sweep is complete across all eight remaining `layoutFragmentFrame` uses;
judgment call 4's assertion change is legitimate; redo is sync-invisible
and registers nothing; `reapplyStructural` is I2- and seal-safe; A7's
carve is correctly narrow *at the range level*; 1D's A2 discriminator is
right and 9b's guarantees are untouched; **the "any membership row means
decided" rule survives all the restore doors** (it walked
`restoreContainer`, `restoreReading`, re-designate, re-mint, and the
SyncSpec §7 repairs); and the 1C refutation is honest.

### Round 1 — the FIX PASS (2026-07-26, fresh implementer session; all eleven dispositions implemented)

**Counts: core 848/98 → 851/98 · Mac 719/129 → 722/129 · mobile 14/4
(unchanged).** All three suites re-run in full and green after the last
fix. **Zero `Sources/VariorumCore/Sync/` lines touched.** Four commits,
one per family, plus this record.

**How to read the evidence column.** Where a finding is a bug, the pin was
run against BOTH trees and the observed RED is quoted. Where a finding is
documentation, a claim correction, or new coverage of behaviour that
already worked, that is said plainly rather than left ambiguous — a pin
that is green on both sides proves nothing, and the record says which is
which.

| # | What changed | Traced mechanism | Red-on-old |
|---|---|---|---|
| **R1-1** | `Queries.RenderedBlock` gains **`liveVariantCount`** (live variants regardless of `status`) + `hasArchivedTakes`; `planEmptyBlockDeletion` gains the **fourth guard**, `liveVariantCount == 1`. The init parameter is **required, never defaulted** to the active count (the `register(redo:)` precedent — a projection builder that has not thought about archived takes must say so); four test construction sites updated, and `slot(…)` gains an explicit `archived:` knob. | Archive is out-of-the-fan, **not gone**: `archiveVariant` only flips `status`, and the `deleteBlock` trigger cascade tombstones every live variant regardless of status. So the three-gesture path the reviewer traced (branch · archive the one with prose · blank the survivor) leaves `activeVariantCount == 1` over a block that renders empty and still holds prose — and the carve's ONLY authorization is "there is no text to lose". | **YES, built first as the confirm per the disposition.** `anARCHIVEDTakeCarryingProseKeepsTheRefusal` ran against the **pre-fix tree** and failed at exactly the plan-time guard line (`BlockDeletionAndRedoTests.swift:183`) while every other assertion in it passed — the block *does* render empty, the fan *does* read 1, the pure index *does* name it. GREEN after. Core adds `liveVariantCountSeesArchivedTakesTheFanDoesNot` over the query itself (characterization — the field did not exist pre-fix). |
| **R1-2** | AppSpec §9's structural-undo paragraph gains its **REDO half**; a §9 entry for **`shelveInDailyJournalBook`**; a §14 **shipped-semantics delta** naming A7's carve as the exception to the ratified cross-block refusal (with the still-open texted-seam case pointed at #34 so nobody reads it as shipped); OverallModel §3's bullet follows. | Documentation. §9 opens "Every mutation is one of these", and a fresh session reading canon could not have learned that redo exists, that a new public operation exists, or that the cross-block refusal now has one named exception. | **None owed — documentation only.** Written strictly as *what shipped*; nothing extends a ruling. The one thing deliberately NOT written: the texted-seam merge question, which is product and hers (#34). |
| **R1-3** | `DailyBookShelving` gains **`.wrongKind`**; the residual bucket stops dumping — a private `residualReason` maps the races that can still reach it (`readingNotFound`, `containerNotFound`, `wrongContainerKind`) to short human phrases, with a generic phrase for anything else. Both surfaces word the new case. | `String(describing:)` on an `OperationError` renders its associated values — row ids and fully-qualified enum case paths — and both callers put that string in front of her. Mapping only the smart-book case would have closed the example, not the class; the residual mapping makes it structural. | **YES.** Reverted to the pre-fix shape (`.refused(String(describing: error))`, no `.wrongKind`): the pin observed **verbatim the reviewer's example** — *"…is not in the daily journal book (find it in the Pool): wrongReadingKind(id: "0000…", expected: VariorumCore.ReadingKind.curated)."* Restored and verified byte-identical by checksum. |
| **R1-4** | `JournalBooks.openToday` keeps **create-and-pin** (the act only her button press may take, #37) and **delegates the ensure half** to `shelveInDailyJournalBook`; its notes are rewritten over the outcome cases, gaining the smart-book one. | `addPostToReading` throws `alreadyInReading` only for a **live** membership row (`liveMembership`), while the live-unique index is `WHERE deleted_at IS NULL` — so a tombstoned membership is invisible to it and it INSERTS a second row beside the tombstone. Three doors, two different rules. | **YES.** With the pre-fix `addPostToReading` + `alreadyInReading` path restored, `openTodayNeverReShelvesAnEntryTheAuthorRemoved` fails exactly as traced: `books` comes back holding "Journal", and `reading_post` holds **2** rows where 1 is required. Restored byte-identical by checksum. |
| **R1-5** | The Debug-vs-Release clause **struck from all three carriers** (the `maxBlockUTF16Length` doc comment, `theCapStaysUnderHalfAFrameAtTheWorstMeasuredRate`, QUESTIONS #39) **plus a fourth** found while fixing — this plan's own batch-1E cap paragraph, annotated in place. Each replaced with the reviewer's traced reason. | The claim cannot be made true, which is why striking is the only honest option: `ensureLayout` executes in the system TextKit binary — the same code in both configurations — and no app code runs in that path (this target installs no layout-manager or content-storage delegate). A Release measurement would have confirmed the absence of a difference, not restored the claimed headroom. | **None owed — a false CLAIM, not a defect.** The cap constant is unchanged and its derivation pin still holds it to the half-frame budget (~4× of room), which is the only claim the evidence supports. This one mattered because #39 repeats it to her verbatim as part of what she is asked to rule from. |
| **R1-6** | `PaneSurfaceSource.assignmentCount` now counts **all four** binding-write forms (`name =`, `self.name =`, `$name.wrappedValue =`, `_name.wrappedValue =`), split into `wholeWordAssignments` + `literalAssignments` + one `isAssignment` rule; the four forms are mutually exclusive by construction, so nothing double-counts. **No production code changed.** | The old rule required the character before the name to be neither an identifier char nor `.` nor `$` — which is precisely what excluded `self.`, `$…wrappedValue` and `_…wrappedValue`. Both sides of the walk's equality assertion used the same blind rule, so a write in any of those forms was invisible to it and the walk reported clean. | **YES, demonstrated end to end.** With the old counting rule and two escaping writes injected into `updateNSView` (`self.height = 999`, `$canaryMessage.wrappedValue = "x"`), `everyPaneStateWriteLeavesThroughThePublishDoor` **PASSED** — the hole, made visible. With the fixed rule and the same injections it caught them (`assignments → 2` vs `insideInstall → 1`). The new `theWalkCountsEveryFormOfWritingToABinding` is red on the old rule (`1` where 4 is required). `PaneSurface.swift` verified byte-identical afterwards; `git diff` on it is empty. |
| **R1-7** | Two round-trip pins in `RedoStackTests`: **delete the block's DEFAULT out of a three-take fan** (so the re-apply must re-run `reassignDefaultIfNeeded`, not merely re-stamp `deleted_at` — a default left pointing at a tombstone is the dangling-default state SyncSpec §7 has a repair for), and **archive → undo → redo** exact-row with I10 still refusing the last active afterwards. Plus a `snapshotExcludingDeletedAt` helper for the re-tombstone case. | `performDeleteVariant` / `performArchiveVariant` are the only two re-apply bodies of their own; every other re-apply reuses a body an undo pin already exercises. Their guards (`ensureNotLastActive`, locked, chosen, default reassignment) therefore ran only on the forward path. | **Coverage of behaviour that already worked — so the honest question is whether the pins are LOAD-BEARING, and they were checked.** Neutering both re-applies (`redo: { _ in }`) reds them with the traced shapes: `deletedAt != nil` fails, the default pointer fails, the row snapshots fail. Restored byte-identical by checksum. |
| **R1-8** | `QUESTIONS.md` restructured: **#27/#28 back under "Phase 13, Stage C"**, a `---` before the 13c heading, and the 13c entries in numeric order **29 → 39** (they ran 34, 35, 29, 36, 30, 31, 33, 37, 38, 39, 32). | Documentation. My own error at the kickoff — the 13c section was inserted beneath the Stage C heading, orphaning it and re-parenting two entries under a phase they have nothing to do with. | **None owed.** Verified by content, not by trust: every entry accounted for (#27/#28 under Stage C, #29–#39 under 13c) and the word count differs only by the R1-5 edit to #39. |
| **R1-9** | The claim corrected in both carriers: **21** `undoStack?.register(…)` sites + the compound's own registration inside `withCompound` = **22 in production**. | Documentation. The claim is load-bearing for the totality argument, so it must match what a reviewer can count — and "23" matched nothing. | **None owed.** `grep -c '\.register('` over `Sources/` + `App/` excluding tests = 21; the compound's own call is the 22nd. |
| **R1-10** | One recorded paragraph in `withCompound`'s doc comment. | Each collected leg's own `register` clears `redoEntries` as it lands; the catch path runs the collected inverses but does not restore the cleared future. So a compound that throws mid-body rolls its work back and still ends the redo future. | **None owed — behaviour recorded, not changed.** Defensible under "any new structural act clears the future" (she DID invoke one), and a redo stack surviving a half-applied-then-rolled-back gesture is the subtler surprise. Reachable only through a refusal landing mid-gesture. |
| **R1-11** | The `try?` split into a `do`/`catch`: no entry for the day still returns nil (nothing to shelve), a **read failure** returns a speaking note pointing at the next round. | `try? await database.read { … }` produced `String??` and the guard flattened both nils, so a store-read failure and "there is no entry that day" were the same answer — the one silent path in a flow whose entire discipline is to speak. | **YES, two ways, by experiment rather than by revert alone.** With the lookup forced to throw: the `try?` shape reports **0 notes** (the swallow, reproduced), the fix reports **1**. **No permanent pin, deliberately:** inducing a real store-read failure in the harness would need a production seam whose only consumer is the test, and the landing that precedes this call would fail first under any schema-level sabotage. Stated rather than left blank. |

**Two things worth carrying into round 2.**

1. **R1-1's fix changed a core read-layer type**, so a reviewer should
   satisfy itself that `liveVariantCount` is populated everywhere a
   projection is built — the two production sites are `renderPost`'s SQL
   and `LensQueries.renderPost`'s pass-through, and the required init
   parameter is what makes a third site impossible to add silently.
2. **R1-6 hardened a TEST**, and the thing it guards is the F1 door. The
   demonstration above is the load-bearing part of that finding: with the
   old rule the walk passed while two writes escaped, which is exactly the
   failure F1 was raised to prevent one layer up.

**Nothing was disputed.** Every disposition was implemented as written;
the two places I went slightly beyond the letter are recorded above and
both close the finding's CLASS rather than its example (R1-3's residual
mapping; R1-5's fourth carrier in this file).

### Round 1 fix pass — ACCEPTED (2026-07-26)

**All eleven dispositions implemented, zero disputes, counts core
848→851/98 · Mac 719→722/129 · mobile 14/4, all three re-run in full.**
Verified by me: the new core read-layer member exists
(`PostRender.swift:45`) and the package builds clean — a SourceKit
diagnostic claiming otherwise was stale index state, the second such
false alarm this phase and checked rather than assumed both times.

**Three things it did better than the disposition asked:**

1. **R1-1's new `liveVariantCount` is a REQUIRED init parameter, never
   defaulted** — the `register(redo:)` precedent applied to the read
   layer, so a third projection builder cannot silently report a block
   textless. The fix closes the *class*, not the instance.
2. **R1-6's proof is a demonstration, not an assertion.** It injected two
   escaping writes, showed the OLD walk **passed** with the hole open,
   then showed the fixed walk catching them — and `PaneSurface.swift` is
   byte-identical afterward (empty diff). That is how you prove a guard
   guards.
3. **R1-11 states plainly that it carries no permanent pin, and why**
   (inducing a real store-read failure needs a production seam whose only
   consumer would be the test) — verified twice by forcing the throw
   instead. **Stated rather than left blank** is the standard this phase
   has held throughout.

**Two deliberate steps beyond the letter, both ACCEPTED** because each
closes the finding's *class* rather than its example — the
class-completeness discipline, correctly applied: R1-3 mapped the whole
residual bucket rather than only the smart-book case the reviewer
quoted, and R1-5 struck the false margin from **a fourth carrier the
reviewer had not found** (this plan's own 1E paragraph).

**R1-5's resolution is the honest one.** The clause could not be made
true — a Release measurement would confirm the *absence* of a difference,
not restore headroom — so striking it was the only option that ends
accurate rather than merely softened. The cap constant is unchanged; only
the false justification is gone, including from `QUESTIONS.md` #39, which
is the one place this touched what she rules from.

**R1-2 left one thing out deliberately and pointed at it:** the
texted-seam merge case is hers (#34), so canon records the empty-block
carve as shipped and explicitly does *not* describe the broader behaviour
as existing.

### Round 2 — findings + dispositions (2026-07-26, FRESH cold reviewer, verbatim prompt)

**2 NEW MAJOR · 5 MINOR · 3 NIT → the ladder goes to ROUND 3** (the
standing rule: a new BLOCKER/MAJOR at round 2 earns its fixes a third
pass). Counts re-verified by its own runs: core 851/98, Mac 722/129.
**All findings agreed.**

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R2-1 | **MAJOR** | **A7's carve still destroys authored text — block COMMENTS** (and `presentation`/`name` one notch weaker). Traced whole: `addBlockComment` has no empty-block guard, and an empty block carrying a note is ordinary (*"I'll rewrite this — see the note"*); `planEmptyBlockDeletion`'s four guards cannot see one because `RenderedBlock` carries no comment signal; `deleteBlock` fires v1_8's cascade trigger; and because `deletedBlockComments` is keyed by `blockID` and the block is now only in the tray, **AppSpec §7's ratified "deleted comments are visible and resurrectable — never skimpy" does not hold for this path.** | **AGREED — FIX. This is R1-1's class, one guard short, and the same sentence convicts it:** the carve was granted only on *"there is no text to lose"*, and a comment is authored text. Fifth guard on R1-1's footing — and **`hasArchivedTakes` (NIT R2-7, currently dead code) is the natural shape to wire it through.** Whether a *named* or *callout* empty block should also refuse is author-flavored → ratify list. |
| R2-2 | **MAJOR** | **A9 and A13(a) were ruled into the friction batch by K2 and never built, never deferred — while I declared Stage 1 COMPLETE.** `.callout` is still `doors: [.menuBar]`, `shortcutLabel: nil`, `availability: writeEditor` (neither half of A13(a) shipped); `.divide` is still `takesAccess: .moveAndExecute`, so Takes yanks her to Write rather than acting natively (A9 — her *"i desperately need divide in takes mode"*). Their ledger rows still read a bare `13c-friction` while every other friction row carries a shipped annotation. | **AGREED — MY PROCESS FAILURE, and the reviewer is right that it matters:** "Stage 1 COMPLETE" + a ladder + a planned refresh reads as *the friction batch is delivered*. I wrote both rows into K2's scope and then never put them in a batch brief. **FIX: build them** — they are her explicit asks and the sitting already traced A13(a) as a registry-declaration edit plus P-2 wiring. **Bounded honestly:** if either proves larger than that, record the deferral with 13d named as owner and annotate the ledger rows — what is forbidden is the silent gap, not the deferral. |
| R2-3 | MINOR | **The master plan still tells a fresh session sync is signed out with 1,868 rows queued** — the plan file records the opposite from the same sitting (drained to 0, `server_seq 6662`). CLAUDE.md points cold sessions at the master plan for state. | **AGREED — MY error, fix.** |
| R2-4 | MINOR | **`QUESTIONS.md` #33 and #35 are the same five 1B calls, duplicated** — on the very file R1-8 restructured. Answering one leaves an identical entry marked OPEN on a list she walks top to bottom. | **AGREED — MY error** (I added #35 without noticing 1B had filed #33). Merge on #35's fuller wording. |
| R2-5 | MINOR | **`/Applications` is still 13b's build (mtime Jul 22)** — Stage 1's stated deliverable and the deciding reason for the two-stage split, with no HOLD recorded. | **AGREED as a RECORDING failure, not a sequencing one.** The refresh was always to follow the *closed* ladder, and the ladder did not close — round 2 found the comment-destroying carve, so refreshing now would have shipped R2-1 into her daily-drive build. **That is the two-stage plan working, not failing.** But no hold was written down, so a reader could only infer it: recorded now — **the refresh happens after round 3, and is skipped only if round 3 leaves something open.** |
| R2-6 | MINOR | **`TakesViewModel.deleteFocusedBlock` flushes but drops the post-flush dirty guard `runStructural` applies for the same act** — so one capability's two native doors carry different safety contracts. Concrete trigger marked SPECULATIVE; the divergence is real. | **AGREED — FIX.** One `guard !autosave.isDirty` with the same spoken refusal. P-1's own reasoning: one declared act, one contract, however many doors. |
| R2-7 | MINOR | **The KnownIssues iOS row's owner is no longer a phase**, against that file's own "no entry without naming the phase that resolves it" rule — the mobile project is deliberately unslotted. | **AGREED — FIX in the file's header:** state that unslotted first-class project rows count as owners. The rule's purpose is that nothing sits unowned; her ruling created a new kind of owner, so the rule gets extended rather than bent. |
| R2-8 | NIT | **`hasArchivedTakes` is dead code** — added with R1-1 and consumed nowhere. | **AGREED — wire it via R2-1** (its doc comment describes exactly R2-1's role). One fix, two findings. |
| R2-9 | NIT | **The F1 walk still overstates by one class** — compound assignment (`height += x`) and a binding forwarded to a child are both invisible to it, while the pin's prose claims "all four write forms count, and nothing else does". *The same shape R1-6 closed one level down.* | **AGREED — FIX** by counting `<op>=` and softening the prose to what is actually true. |
| R2-10 | NIT | **`shelveInDailyJournalBook` is a read-then-write composite under a §9 header that says "each is a single transaction"** — the live-row race is caught, the tombstoned-row race is not (sub-ms, headless, honestly unpinnable). | **AGREED — one sentence in the §9 entry** naming it a read-then-act with handled races, so no future reader infers atomicity from the section header. |

**Clean bill worth carrying:** redo's totality verified independently (21
production sites + the compound's own = 22, matching R1-9's correction);
**redo cannot clear its own future** (every re-apply path walked, none
registers); re-applies are idempotent and therefore safely retryable;
redo is sync-shaped through the outbox triggers; **A7's carve is narrow
at the range level by construction** (only inter-entry separators, tail
unreachable); **1E's trigger bound is structural, not hopeful** (the scan
breaks before any enumerate call, `handled` is written before
`ensureLayout` so a throwing AppKit path cannot leave a block eligible);
the A40 sweep is complete and the badge exception is correct; **the A4
anchor fix is symmetric by construction rather than by two cancelling
errors**; 1D does not regress 9b (pinned across a landing round *and* a
following quiescent round); `liveVariantCount` is populated at both
construction sites and a silent third is impossible; canon matches what
shipped, including correctly declining to describe the texted-seam merge
as shipped.

**Scope note the reviewer raised first, and it is correct:** Stage 2 —
the phase's entire *committed* scope (C1, C2/N38, C3/N41, C4, A31) — has
briefs and no implementation. Stage 1 is friction work only. Nothing in
the records claims otherwise, but a reader skimming "Stage 1 COMPLETE"
could infer the phase is near done. It is not.

### Round 2 — the FIX PASS (2026-07-26, fresh implementer session; all ten dispositions implemented)

**Counts: core 851/98 → 852/98 · Mac 722/129 → 731/129 · mobile 14/4
(unchanged, re-run on the iPhone 17 Pro simulator).** All three suites
re-run IN FULL and green after the last fix. **Zero
`Sources/VariorumCore/Sync/` lines touched.** No schema change.

**How to read the evidence column** (the round-1 convention kept): where a
finding is a bug, the pin was run against BOTH trees and the observed RED
is quoted. Where a finding is documentation or a claim correction, that is
said plainly — a pin green on both sides proves nothing, and the record
says which is which.

| # | What changed | Traced mechanism | Red-on-old |
|---|---|---|---|
| **R2-1 + R2-8** | `Queries.RenderedBlock` gains **`commentCount`** (live `block_comment` rows, one indexed correlated subquery beside the two variant counts) — **required init parameter**, the R1-1 precedent — plus `hasComments` and **`carriesUnshownText`**, which is where R2-8's dead `hasArchivedTakes` is now consumed. The carve's third guard becomes `guard !slots[i].carriesUnshownText`, replacing `liveVariantCount == 1`: **ONE name for "prose the slot does not show", not two parallel guards** — a third kind extends the property, never the guard line. `slot(…)` gains a `comments:` knob; four construction sites updated. | Archive is out-of-the-fan; a COMMENT is out of the fan *and out of the slot's text entirely*. `addBlockComment` has no empty-block rule, and a note on an empty block is an ordinary thing to write. `deleteBlock` fires v1_8's cascade over `block_comment`, so the carve — authorized ONLY on *"there is no text to lose"* — was destroying authored text; and because `deletedBlockComments` is keyed by `blockID`, a tombstoned block leaves AppSpec §7's ratified *"deleted comments are visible and resurrectable — never skimpy"* with **no surface at all**. That second half is what makes this worse than R1-1's case, not merely its twin. | **YES, and the destruction is visible in the red.** With the guard reverted to `liveVariantCount == 1` (the pre-fix line), `aBLOCKCOMMENTKeepsTheRefusal` fails at the plan-time guard and `backspaceLeavesACommentedEmptyBlockAlone` fails **5 ways** — `texts → ["hello"]` (the block gone), `entries.count → 1`, an undo entry landed, and, decisively, **`notes.count → 0`: the comment cascaded away**. GREEN after. The archived-take pin and the eleven cannot-widen pins stayed green under the revert, as narrowness pins should. Core adds `commentCountSeesWorkingNotesTheSlotNeverRenders` (characterization — the field did not exist pre-fix). |
| **R2-1's author-flavored half** | **PROVISIONAL, QUESTIONS #40 — the shipped reading: a NAMED or CALLOUT empty block STILL CARVES**, pinned as such (`aNAMEDOrCALLOUTEmptyBlockStillCarves_PROVISIONAL`). | The line is not "is it authored" but "does deleting the block make it unrecoverable or unreachable". `block.name` and `block.presentation` are columns ON the block row: the tombstone keeps them, ⌥⌘Z and `restoreBlock` bring them back with the block, and the tray lists the block BY its name. Comments and archived takes are separate cascaded rows, and comments additionally lose their recovery surface. The reductio that settles it: **block TAGS cascade too** — a guard on "anything attached to a block" would narrow the carve out of existence and undo the A7 fix she asked for. | **None owed — a reading, not a defect.** Recorded with what flipping costs (two more projection signals + one guard line) so her answer is one line. |
| **R2-2 — A13(a): BUILT** | `.callout` gains `takesAccess: .native`, `shortcutLabel: "⌥⌘C"` with its key wiring, and a new named availability rule `takeFamilyPlusCompare` (the take family + Compare — exactly the surfaces she named). `RoutedCommand.callout(CalloutEdit)` joins the vocabulary; **every** menu item routes (colours, Emoji…, Remove, and a new "Toggle Callout" carrying ⌥⌘C) instead of reaching into `session.editorRouter.active`. Four handlers consume it — Write, Takes, Lenses, Compare — over **one pure shared transform, `CalloutEditRule`** (the `MergeJoin`/`BoundarySnapping` shape, Stage 4 lessons 3–4), applied inside `updateBlockPresentation`'s own transaction. The emoji prompt now gathers the glyph and lets the router deliver it, so it no longer needs a Write editor to exist. | The frame is the BLOCK's and its takes share it (R16/R27) — so any surface that knows which block you are in can set it. Write was privileged only by where the door was first hung, which is the exact R118 class 13b's registry exists to kill; the declaration said `availability: writeEditor`, so in Takes/Lenses/Compare the menu was **grey** and the shortcut did not exist. | **YES, by behavioral revert.** With `availability: writeEditor` + `shortcutLabel: nil` restored: `theCalloutDoorReachesEverySurfaceSheNamed` red 3× (takes/lenses/compare all `.unavailable`), `takesIsNeverBehindWrite` red 2× (the R118 parity assertion itself), `theCalloutDoorHasItsShortcut` red (`shortcutLabel → nil`). Restored byte-identical by checksum. `theCalloutDoorFramesTheFocusedBlockNativelyInTakes` and the transform pin are **STRUCTURAL** red — `TakesViewModel.applyCallout` and `CalloutEditRule` do not exist on the old tree, so they cannot compile against it (the 1B A8/A10 precedent, labelled as such). |
| **R2-2 — A9: DEFERRED to 13d, recorded, with the reason** | Ledger row A9 annotated; QUESTIONS #41 filed for her. **Nothing built.** | **The ledger row was wrong about the shape, and that is the finding under the finding.** K2's scope line called A9 "a registry availability rule, the P-1/P-2 class 13b built the machinery for". Traced: `.divide` is `takesAccess: .moveAndExecute`, the door **is** rendered on the Takes bottom bar, and invoking it flushes, parks a `WriteIntent` with her carried caret, switches mode visibly, and runs the real divide — i.e. it works, and it is P-2-compliant fire-and-DO, which IS the machinery 13b built. Her ask is that it act **without leaving Takes**, and that is a different build: `StructuralGesturePlanner` plans over the full-document editor's `BlockRangeIndex`, and a divide on a FANNED block — the ordinary case in Takes — opens the W ceremony, whose state machine belongs to `EditorSurfaceController` and whose sheet takes an `EditorViewModel`. Native means giving Takes a planning path AND making the ceremony mountable outside Write. A half-measure (native when unfanned, yank when fanned) is worse than either: two behaviors for one gesture is the confusion class Stage 4 named. | **None owed — nothing was fixed.** Stated explicitly rather than left blank, per the brief's bound: *"a recorded deferral is fine; a silent gap is not."* |
| **R2-3** | The master plan's pointer section corrected: the sync sign-out is **DISCHARGED** (1,868 → 0, cursor `server_seq 6662`), with the old state kept as a superseded clause for the thread. | Documentation. CLAUDE.md points cold sessions at the master plan for state, and it still said the opposite of what the same sitting recorded four paragraphs later in the plan file. | **None owed.** Verified by content: the paragraph now matches the plan file's own record of that sitting. |
| **R2-4** | `QUESTIONS.md` #33 and #35 merged. **#33 keeps the number** (it is what the ledger row A8, the 1B batch record and the 1B adjudication all cite) and takes **#35's fuller wording**; #35 becomes a one-line `MERGED INTO #33` pointer so nothing above or below renumbers on a list she walks top to bottom. | Documentation, my own duplication. Two identical entries meant answering one would leave the other marked OPEN. | **None owed.** Verified by content: five calls, one entry, every clause of both originals present in the survivor. |
| **R2-5** | The plan's two-stage section gains the HOLD in as many words: **the refresh happens after round 3, and is skipped only if round 3 leaves something open**; the zero-instance precondition is re-checked at that moment, not carried forward. | Documentation. The sequencing was always right — the refresh follows the CLOSED ladder, and refreshing at round 2 would have shipped R2-1's comment-destroying carve into her daily-drive build — but a reader could only infer that, which is the same failure class as an unrecorded deferral. | **None owed.** |
| **R2-6** | `TakesViewModel.deleteFocusedBlock` gains `guard !autosave.isDirty` after its flush, speaking **the same sentence** Write's `runStructural` speaks. | A flush can REFUSE and keep its text pending (the coordinator's documented posture, Phase 7 MAJOR 1 — a seal or lock landing remotely mid-typing is the real-world shape). `runStructural` has always checked that before running an op against a store the surface disagrees with; the Takes door flushed and proceeded regardless. One declared act, two native doors, two different safety contracts — which is P-1's own reasoning against itself. | **YES — and the finding's SPECULATIVE label was too cautious.** The pin induces the refusal honestly (a pending record for a variant that does not exist, so `ops.autosave` throws and the entry goes back into `pending`). With the guard removed: `slots.count → 1` — **the block is deleted while typed text is still unwritten** — plus the wrong survivor and no message. Restored byte-identical by checksum. |
| **R2-9** | `isAssignment` now counts arithmetic COMPOUND assignment (`+=`, `-=`, `*=`, `/=`, `%=`) beside plain `=`; `<`/`>` and the bitwise ops are excluded **with the reason written down** (`<=`/`>=` are comparisons; no shift is meaningful on what a pane publishes). The pin's prose stops overclaiming, and `assignmentCount`'s doc comment now **states what the walk cannot see** — a binding FORWARDED to a child view is not a write here, and the walk claims only that every write *made by this file* leaves through the door. No production code changed. | `height += 8` mutates a binding exactly as `height = …` does, and the old rule (`first == "="`) counted it in **neither** side of the equality assertion — so such a write could escape the publish door while the walk reported clean. Literally the shape R1-6 closed one level down, one level up. | **YES, demonstrated end to end — the R1-6 method.** With the old counting rule AND `height += 1` injected into `updateNSView` (outside the install door), `everyPaneStateWriteLeavesThroughThePublishDoor` **PASSED** — the hole, made visible — while `theWalkCountsEveryFormOfWritingToABinding` went red (`4` where 7 is required; `"height += 1" → 0`). Restoring only the counting rule, with the same injection still in place, the walk **caught it**: `assignments → 2` vs `insideInstall → 1`. `PaneSurface.swift` restored and verified byte-identical (`git diff` empty). |
| **R2-10** | One sentence in AppSpec §9's `shelveInDailyJournalBook` entry naming it a **read-then-act composite, not a single transaction**, with which race is caught (`alreadyInReading` on live rows) and which is not (a `removePostFromReading` committing in the sub-ms window between the read and the insert). | Documentation. §9 opens "each is a single transaction", so a future reader would have inherited an atomicity guarantee this operation does not make. | **None owed.** The unpinnable half is stated as unpinnable — the `confirmDivideWCeremony` residual's class — rather than left implied. |

**Two canon edits rode the fixes, both strictly recording what shipped:**
AppSpec §14's Stage 1 shipped-semantics delta gains **(4)** the callout
door's reach (a DOOR-reach change, not a model change — said so in the
text, since §12 describes callouts without saying who sets them), and
item (3)'s carve description gains the comment guard and the
named/callout PROVISIONAL. `KnownIssuesAndTechDebt.md`'s header states
that an unslotted first-class project row counts as an owner (R2-7) —
**the rule extended, not bent**: her 2026-07-25 mobile ruling created a
kind of owner the original wording had no word for, and the rule's
purpose (nothing sits unowned) is satisfied exactly.

**Nothing was disputed.** The one place this went beyond the letter is
R2-1's shape: the disposition asked for a fifth guard and named
`hasArchivedTakes` as the vehicle; what landed is ONE property
(`carriesUnshownText`) that both guards now live behind, so a third kind
of unshown prose extends a documented predicate instead of appending a
sixth guard line. That closes the class rather than the instance — the
same reasoning the round-1 pass was accepted for.

**Two things worth carrying into round 3.**

1. **R2-1 changed a core read-layer type again.** `commentCount` is a
   required init parameter for the same reason `liveVariantCount` is, and
   the two production construction sites are unchanged (`renderPost`'s SQL,
   `LensQueries.renderPost`'s pass-through). A reviewer should satisfy
   itself that the new correlated subquery is P1-shaped: it is per-slot
   and indexed (`idx_block_comment_block`), so cost stays ∝ the container,
   and the core P1 benchmarks re-ran flat (`renderPost` and autosave
   unchanged).
2. **A9 is the one piece of ruled scope this stage does NOT deliver.** It
   is recorded, owned by 13d, and filed to her as QUESTIONS #41 — but a
   reviewer should judge for itself whether the sizing argument above is
   honest, since the alternative reading ("it was always a declaration
   edit") is what the ledger row asserted for a day.

### Round 2 fix pass — ACCEPTED (2026-07-26); round 3 running

**Counts core 851→852/98 · Mac 722→731/129 · mobile 14/4**, all re-run
in full. Verified by me: the new members exist (`PostRender.swift:52,
82`) and the package builds clean — a **third** stale-index SourceKit
alarm this phase, checked rather than assumed every time.

**R2-1 closed the class rather than the instance, in the right shape.**
Rather than a sixth guard line, it added one named predicate —
**`carriesUnshownText = hasArchivedTakes || hasComments`** — which is
also where R2-8's dead code found its consumer. A future third kind of
unshown prose extends a documented property instead of appending to a
guard list nobody will remember to read. **The red-on-old shows the
destruction directly**: with the guard reverted, the pin fails five ways
and `notes.count → 0` — the comment cascading away, visible in the
failure rather than argued about.

**PROVISIONAL #40 (a *named* or *callout* empty block still carves) —
ACCEPTED, and its reasoning is better than the disposition I wrote.** The
line it draws is not *"is it authored"* but **"does deleting make it
unrecoverable"** — `name` and `presentation` are columns on the block
row, revived by undo and `restoreBlock`, and the tray lists the block
*by its name*, so nothing goes dark. The reductio that settles it: **block
tags cascade too**, so a guard on "anything attached to a block" would
narrow the carve out of existence and undo the very A7 fix she asked
for. Flipping costs two projection signals plus one guard line, and the
entry says so.

**A13(a) BUILT** — `takesAccess: .native`, ⌥⌘C, a `takeFamilyPlusCompare`
rule covering exactly the surfaces she named, routed through the command
vocabulary with four handlers over **one pure shared transform**. Canvas
deliberately out (not in her ask; honestly grey per P-2, and recorded for
the Design & UI review row).

> **A9 DEFERRED to 13d — and the deferral corrected MY ledger row, which
> is the finding under the finding.** The row asserted "no divide in
> Takes". **False:** the bottom-bar door flushes, parks a `WriteIntent`
> carrying her caret, switches mode *visibly*, and runs the real divide —
> that IS 13b's fire-and-DO machinery working as designed. Her actual ask
> is that it act **without leaving Takes**, which needs a structural
> planning path for Takes *plus* the W ceremony mountable outside
> `EditorSurfaceController` (a fanned block — the ordinary case in Takes —
> opens the ceremony, whose sheet takes an `EditorViewModel`). **A
> half-measure would ship two behaviours for one gesture — the exact
> confusion class Stage 4 exists to kill.** I accept the sizing; the
> round-3 reviewer is explicitly asked to judge it, since the opposite
> reading stood in the ledger for a day. **QUESTIONS #41** lets her lift
> it to the top of 13d if she wants.

**R2-6's SPECULATIVE label was too cautious, and the fix pass said so** —
without the guard the block is deleted while typed text is still
unwritten. A reviewer under-claiming its own finding is the safe
direction to err, and correcting it on the record is right.

**R2-9 was demonstrated the R1-6 way again:** with the old rule and an
injected `height += 1`, the door walk **passed** while a write escaped;
the fixed rule caught it. That is now twice this guard has been proven by
showing the hole open first.

### Round 3 — findings + dispositions (2026-07-26, FRESH reviewer; the ladder's CAP round)

**1 MAJOR · 4 MINOR · 2 NIT.** Counts re-verified by its own runs (core
852/98, Mac 731/129, mobile 14/4). **All agreed.**

**Ladder status:** three rounds have run, which is the hard cap. Per the
standing rule, **round 3's fixes land POST-CAP and no round 4 review is
spawned** — the Phase 9 / 11a / 13 precedent.

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R3-1 | **MAJOR** | **A7's carve evaluates three of its four guards against a projection the editor DELIBERATELY holds stale.** `EditorProjectionEngine.decide` returns `.deferUntilClean` whenever `busy` (`autosave.isDirty` ‖ mint ‖ structural in flight), and autosave's debounce is 500 ms re-armed per keystroke — so **for a whole typing burst `slots` is frozen**, and `planEmptyBlockDeletion` reads `activeVariantCount`/`carriesUnshownText` from that frozen array. `runEmptyBlockDeletion` re-verifies **only the text**. Sequence: post is `["", "hello"]`, she is typing in "hello", a comment lands on the empty block (sync from another device, or her own comments sheet while the buffer is dirty), the observation defers — she backspaces at the seam, all four guards pass on stale data, the CAS passes because the text really *is* empty, and the comment cascades away. | **AGREED — FIX, post-cap.** This is R1-1/R2-1's class a third time, at a level neither previous round reached: not a missing guard but **a guard reading a stale source**. **The tell is damning and the reviewer found it: every carve pin calls `harness.reload()` between the ops write and the plan — the tests hand-refresh the projection that production does not.** The pins were green because they rehearsed a state production never reaches. **Fix at the level that ends the class: an ops-level precondition on `deleteBlock` so the authorization is re-checked INSIDE the same transaction as the tombstone** — which also subsumes R3-3. Guard lists have now failed three times; a transactional precondition cannot be read stale. |
| R3-2 | MINOR | **The one canonical-VISION change in this phase is the one author ruling recorded without her words.** Every other ruling carries a verbatim quote; pillar 8's supersession is asserted as "with her explicit blessing" with no quoted sentence — and the two quotes that ARE on record are *weaker* than the applied wording (R58 is a lean; her intake says only "quite robust and easy to use"). | **AGREED — MY error, fix.** She *did* explicitly choose it, but from a presented option — so the honest record is **the option text she was shown and selected**, quoted, not my paraphrase of its effect. Her standing instruction is "don't add more certainty than I have", and that binds hardest on the vision document. |
| R3-3 | MINOR | **The carve's CAS is stated as "inside the transaction"; it is check-then-act across TWO** (`editTakesAtomically` opens one write, `deleteBlock` another; `OperationsRunner` serializes bodies, it is not a transaction, and sync applies through `applyingRemote` outside it). The window is sub-ms and unpinnable; **the finding is the CLAIM**, which appears in canon and in the doc comment. | **AGREED — and R3-1's fix closes it for real** rather than annotating it. Where R2-10 correctly annotated an unfixable read-then-act, this one is fixable, so it gets fixed. Correct the canon sentence to match what ships. |
| R3-4 | MINOR | **1E's scroll trigger is UNPINNED — delete `EditorView.swift:639` and all three suites stay green.** Every editor test stubs the debounce sleeper to throw, and the three trigger tests call `considerLongBlockLayout()` directly; nothing drives the anchor controller's bounds change. **So the entire default-ON feature could be inert in the shipped app and nothing would say so** — and `/Applications` is still 13b's build, so no human has exercised it either. | **AGREED — FIX.** This is the most consequential MINOR of the night: it means the phantom fix she will be asked to rule on (#39) has no proof it ever fires in the real app. One pin driving the bounds change, red on the deleted line. |
| R3-5 | MINOR | **The memo she rules Q3 from is stale in exactly R1-5's way, and it is the carrier nobody swept.** It still says E "survives scrolling… not a treadmill" and that *when* to do it "is a design question" — 1E measured the opposite (a width reflow returns a laid-out block to a **worse** guess) and **built** the trigger policy. `grep -i "width\|reflow\|resiz"` over the memo returns nothing. | **AGREED — FIX.** #39 carries the correction; #29 points her at the memo, which does not. She must not rule from a document that contradicts the code. Annotate in place (the R1-5 precedent) and flip its "measured, deliberately NOT built" framing. |
| R3-6 | NIT | The F1 walk still cannot see a write through a **mutating method** on a binding (`height.toggle()`, `$list.wrappedValue.append(…)`). Not reachable with today's two bindings. | **AGREED** — add the form or document the limit. Third layer of the same onion; each has been genuinely narrower. |
| R3-7 | NIT | **Three CLAUDE.md drifts against docs this phase changed:** the model-policy table stops at 14/15 (13c's all-Opus cast lives only in the plan + master plan, though CLAUDE.md is where that policy is declared to live, and 13d–13h have no rows); its copy of the KnownIssues rule still says "phase" after R2-7 extended it; and it still treats Phase 15 as live while the master plan marks it superseded. | **AGREED — FIX.** CLAUDE.md is what a cold session reads first, which is exactly why these matter more than their size. |

**Clean bill worth carrying:** counts verified independently; **zero
`Sync/` AND zero `Persistence/` lines**, last migration is 13b's v1_12 so
no §12 obligation; no `try!`/`as!`/`fatalError`/TODO introduced anywhere
in the diff; redo's totality re-counted independently (21 + the
compound's own = 22); **every re-apply body walked — none registers, all
write through `database.write` so the outbox triggers fire**; exact-row
discipline holds (`moveBlock`/`reorder` capture the *landed* position
rather than re-deriving a jittered key); the two new counts are required
init parameters with exactly two production construction sites and both
subqueries hang off the LIVE block row, so a gap slot reads 0 and
SyncSpec §5 tolerance is preserved; `shelveInDailyJournalBook` genuinely
never throws and `.wrongKind` really is what `addPostToReading` raises;
9b's guarantees intact; **1A's geometry is correct against the typography
actually in use** (only `paragraphSpacing` is set, never
`paragraphSpacingBefore`, so keeping the frame's top is right); 1E writes
nothing to the store and cannot manufacture its own trigger; A13(a)'s
four declared⇔rendered door tables still balance.

### Round 3 — the FIX PASS (2026-07-26, fresh implementer session; POST-CAP, all seven dispositions implemented)

**Counts: core 852/98 → 858/98 · Mac 731/129 → 733/129 · mobile 14/4
(unchanged, re-run on the iPhone 17 Pro simulator).** All three suites
re-run IN FULL and green after the last fix. **Zero
`Sources/VariorumCore/Sync/` lines touched.** No schema change. Three
commits (`faf4c7e`, `7818bc3`, `407e0dd`) plus this record.

**Read this as the last word, because it is.** Three rounds have run —
the hard cap — so nothing reviews these fixes. The evidence column is
therefore written for someone who has only it: where a finding is a bug,
the revert was executed against the SHIPPED tree and the observed RED is
quoted; where it is documentation or a stated limit, that is said plainly
rather than left ambiguous.

| # | What changed | Traced mechanism | Red-on-old |
|---|---|---|---|
| **R3-1 + R3-3** | **The carve's authorization left the projection.** `Operations.deleteBlock` gains `requiring: BlockDeletionPrecondition` — `.none` (the ordinary door, the default, every existing call site unchanged) or **`.emptyWithNothingUnshown(variantID:)`**, re-checked **inside the same `database.write` as the tombstone**: the named take must be the block's ONE live variant (so no fan AND no archived take), active, unlocked, under an unsealed post, with an empty buffer, and the block must carry zero live comments. `runEmptyBlockDeletion` drops its `editTakesAtomically` CAS-write entirely, so the gesture is now genuinely ONE transaction. The plan-time guards STAY, re-described as what they are: fast enablement, not authorization. New `OperationError.blockCarriesUnshownText`, worded in the editor's own switch AND in `OpsRefusalCopy` (the R1-3 class closed for any future door). | Three rounds found three ways the carve's only authorization — *"there is no text to lose"* — could be false while the gesture still fired. R1-1 and R2-1 each added a condition to `planEmptyBlockDeletion`; **both read `model.slots`, which `EditorProjectionPolicy.decide` deliberately freezes** (`.deferUntilClean` whenever `autosave.isDirty ‖ mintInFlight ‖ structuralInFlight`, and the debounce re-arms per keystroke — so the array is frozen for a whole typing burst). A comment landing in that window is invisible to every guard; the run path re-verified only the TEXT, which really was empty. **A guard list read from a frozen array is exactly as stale as the array** — so the answer was not a sixth guard but a different LEVEL. That subsumes R3-3: the "compare-and-set inside the transaction" claim was check-then-act across two, and now it is one. | **YES, both layers, by behavioural revert, run both ways.** **App:** with the pre-fix two-transaction shape restored, `aCommentArrivingWhileSheIsTypingStillStopsTheCarve` fails **4 ways** — `after.count → 1` (the block gone), the wrong survivor, **`notes.count → 0` (the comment cascaded away)**, and an undo entry landed; the other 27 pins in that suite stayed GREEN under the revert, which is precisely the finding. **Core:** with `enforce` neutered, **9 issues across 4 pins** including the redo one. Both files restored and verified against pre-revert checksums. |
| **R3-1's redo half** (judgment call, recorded) | The precondition **rides the structural-redo re-apply too**, not just the forward call. | A redo lands a tombstone exactly as the first delete did — and the window is real, because writing a comment is not a structural act and therefore never cleared the redo future. Deleting the empty block, undoing, writing a note on the restored block, then redoing would otherwise reproduce R2-1's destruction through a different door. A refused redo keeps its entry for retry — the existing, pinned "resolvable refusal" posture, not a new one. | **YES** — `aRedoneEmptyBlockDeletionReChecksThePreconditionToo` is among the four core pins red under the neuter (3 issues: no throw, the block tombstoned, `redoDepth → 0`). |
| **R3-4** | **1E's scroll trigger gets the pin it never had.** A hosted test installs production's own `ScrollAnchorController` on the real clip-bounds notification and scrolls toward a long block. | The feature's only scroll wire is one line in `boundsChanged`; every 1E pin drives the pass by hand and every editor test stubs the debounce sleeper to throw, so deleting that line left all three suites green while the whole default-ON feature was inert — with `/Applications` still on the previous build, so no human had exercised it either. That matters disproportionately: **#39 asks her to rule on this feature having FELT it.** | **YES.** With the production line deleted: `passesRun` stuck at the attach settle's **1**, `layoutsRun → 0`, `handled` empty. `EditorView.swift` restored to a verified checksum. **Two things it took to make the pin honest, both written into the test:** (a) the trigger has TWO inputs — `overlayLayoutDidSettle`'s hop is generation-gated (storage · attach · WIDTH, never a scroll), so it fires once after attach; **a first version of this pin stayed GREEN with the wire deleted, satisfied by that settle**, and the shipped pin puts the long block far below the look-ahead so only a scroll can reach it. (b) TWO drains, not interchangeable: the bounds notification wants a run-loop turn (`OperationQueue.main`), the debounce is a main-actor `Task` that a synchronous `RunLoop.run(until:)` **never** services — measured: pumping alone leaves `passesRun` at 0 forever. The plan's "async-poll, never sync RunLoop pumping" trap, from the other side. |
| **R3-2** | The pillar 8 ruling is recorded **in the words she was shown and selected** — the option's label and its full description, quoted in the plan file beside the delta. **CoreDescription pillar 8 itself is deliberately untouched.** The stale `A42` ledger row is corrected with it. | My error, and the one that most deserved catching: this is the phase's ONE change to a canonical VISION document, and it was the only author ruling in this file recorded without her words — while the two quotes that ARE on record (R58's lean; "quite robust and easy to use") are both weaker than the wording applied. Her standing instruction is *"don't add more certainty than I have."* She DID choose it — but from a presented option, so the honest record is the option text, not a restatement of its effect. | **None owed — a record correction.** The one judgment inside it: pillar 8's text was left exactly as she blessed it, because the gap was the record and re-wording it would be a second, unasked change to the vision doc. |
| **R3-5** | The C3 memo annotated in place at every carrier — header, the `(c)` bullet, the caveat, the recommendation, the Q3 table row, and the appendix — with the "measured, deliberately NOT built" framing flipped throughout. `QUESTIONS.md` #29 now says the memo carries the correction. | It is the document she rules Q3 from, and it contradicted the code in two specific ways: it said E "survives scrolling… not a treadmill" (true of scroll travel ONLY — a width reflow returns a laid-out 3,000-word block to an 11,492 pt guess, *worse* than it started), and it said the trigger "is a design question" when 1E had decided and built it. `grep -i "width\|reflow\|resiz"` over the memo returned nothing. #39 carried the correction; #29 pointed her here, and here did not. | **None owed — staleness in a document, the R1-5 class.** Annotated rather than rewritten, so the sequence of what was known when stays legible. |
| **R3-6** | The F1 walk's mutating-method blind spot (`height.negate()`, `$text.wrappedValue.append(…)`) **documented, and the limit PINNED** (`assignmentCount(of: "height", in: "height.negate()") == 0`) so it is visible rather than discovered. The pin's prose stops claiming more than the rule checks. | The walk is lexical, and that is the reason the form is documented rather than counted: `height.round()` and `height.rounded()` are indistinguishable without a type checker, so counting every `name.foo(` would flag reads as writes and make the walk's equality assertion meaningless. Not reachable with today's two bindings (a `CGFloat` and a `String?`, both only ever assigned). The honest closing **if a pane ever publishes a collection or a flag set** is named in the doc comment as type-level, not another substring rule. | **None owed — a stated limit, not a defect.** The disposition allowed "add the form or document the limit"; this documents it and pins the limit so the next reader inherits the fact rather than the assumption. Third layer of the same onion, and each has been genuinely narrower. |
| **R3-7** | Three CLAUDE.md corrections: **13c's all-Opus cast + the `/architect-phase` shape ruling** written where the model policy is declared to live (with her verbatim reason), **13d–13h** named as cast-at-kickoff, the **KnownIssues owner rule** widened to match R2-7's extension, and **"Phase 15 onward" corrected — Phase 15 no longer exists** (her 2026-07-25 ruling made the iPhone app an unslotted project row). | Documentation, and it matters more than its size: CLAUDE.md is what a cold session reads FIRST, and every one of these was a statement it would have inherited as current. | **None owed.** Each edit records a decision already made and recorded elsewhere (K1, K3, R2-7, the A42 ruling); none extends one. |

**Nothing was disputed.** Two places went past the letter, both closing the
finding's class rather than its example — the round-1/round-2 precedent:
R3-1's refusal copy landed in `OpsRefusalCopy` as well as the editor's own
switch (so a future door onto `deleteBlock(requiring:)` cannot inherit a raw
enum dump), and R3-2's fix corrected the adjacent stale `A42` ledger row,
which is the R2-2 class sitting in the very section the finding was about.

**What a fourth reviewer would be asked to look at, recorded because there
will not be one:**

1. **`BlockDeletionPrecondition` defaults to `.none`.** That keeps ~20 call
   sites unchanged and is honest for the general door, but it is NOT the
   `register(redo:)` shape (required, never defaulted) that R1-1 and R2-1
   were praised for. The judgment: requiring it everywhere would make every
   caller declare an authorization most of them genuinely do not have,
   which is noise rather than a guard. The class R3-1 named — an
   authorization read from a snapshot — is closed by the parameter
   EXISTING and by its doc comment saying what a caller must do; a new
   caller that wants "delete only if still empty" now has one obvious way
   to get it right.
2. **The redo path re-checking the precondition is a deliberate asymmetry**
   with every other structural re-apply, which is unconditional. Argued
   above; a reviewer might reasonably prefer redo to be a pure re-apply and
   the window accepted (it is undoable and tray-recoverable either way).
3. **The R3-4 pin's own fragility.** It asserts `layoutsRun == 1` after
   scrolling toward the long block in ≤ 4 steps, which depends on the
   corpus's geometry (100 short blocks, long at index 60, 500 pt viewport).
   It is bounded and it broke loudly rather than silently while being
   written, but a machine with very different metrics is where it would
   flake first. `passesRun > baseline` is the assertion that carries the
   finding; the other two are the "and it did the work" half.

### Stage 1 — INDEPENDENT FABLE VERIFICATION (2026-07-27, author-requested)

The author returned after the Opus overnight run and asked a fresh
**Fable** `/architect-phase` session to verify the Stage 1 work — the
fixes, the records, and the roadmap — before deciding what runs next.
This session now holds the 13c orchestrator role; her cast intent for
Stage 2 is an open question bundled below, not assumed. What was
verified, by the skill's verify-don't-trust rule:

- **Counts, by my own runs:** core `swift test` **858/98 green** (P1
  benchmarks flat); Mac `xcodebuild test` **733/129 green**. Mobile
  **14/4 taken from the record** (run twice there on the simulator; not
  re-run here — stated rather than implied).
- **The R3-1 fix is genuinely at the level the record claims:**
  `BlockDeletionPrecondition` is enforced inside `performDeleteBlock`'s
  own `database.write` (`Operations+Deletion.swift`), fresh SQL counts
  mirroring `liveVariantCount`/`commentCount`, and the redo carries the
  SAME precondition. Spot-checked live: `register(redo:)` required;
  `shelveInDailyJournalBook` + `.wrongKind`; `LongBlockLayout` + both
  new suites; `takeFamilyPlusCompare` + ⌥⌘C in the registry.
- **The install is functionally Stage 1**, not just recently stamped:
  the `/Applications` binary contains the kill-switch string and
  `blockCarriesUnshownText`; mtime 07:31, one minute before the final
  commit. Zero instances at check. The A1 backup exists, WAL-safe, in
  the sandbox container (`…/Variorum/Backups/variorum-backup-2026-07-25-133011.sqlite`,
  2.99 MB, 07:30 local — the handoff's bare `Backups/` path is that
  container directory, not the repo).
- **F-V1 — a dateline offset, recorded so nobody reconciles it again:**
  the batch/ladder records are datelined 2026-07-26, but every Stage 1
  commit sits on **2026-07-25 local** (1D at 03:49 → SHIPPED at 07:32).
  The *sequence* is internally consistent — R2-5's "install is still
  13b's build" was true at 06:05, and the refresh at 07:31 followed
  round 3's fixes exactly as the recorded hold required. Only the
  written datelines are off by one day.
- **F-V2 — one handoff-checklist imprecision:** item 3 says "opening ⌘J
  on that date shelves them immediately" for the two orphaned past days,
  but ⌘J opens *today's* entry. The doors that verifiably reach a past
  day are the phone capture list's day tap (`open(on:)` — the addendum's
  door) and any Fragments landing that writes the day. Not a code
  defect; the fix and repair rules themselves check out.

**Verdict: the Stage 1 records are faithful.** Every claim I spot-checked
against code, commits, or the machine held, including the ones that
would have been easiest to fudge (the install's contents, the
transactional level of the carve fix, the red-on-old convention's
honesty about which pins are characterization). The handoff matches the
repo record. My assessments of the open judgment calls and the roadmap
went to the author directly (they are hers, not records).

## Sitting — 2026-07-27 (author-attended; Stage 2 cast, GO, and a live finding)

**K6 — the Stage 2 cast, her words verbatim:** *"we'll go with Fable
orchestrator, Opus 5 implementer for now, with one Fable cold-reviewer
at the end of the phase. Go ahead and run Stage 2."* Operating reading
(the orchestrator's, recorded so it is inspectable): Stage 2's batches
(2A–2E) go to fresh **Opus** implementer sessions; the phase's review is
**ONE Fable cold review at the end**, over the combined diff of Batch 1F
+ Stage 2 (Stage 1's own three-round ladder already closed). If that
review surfaces BLOCKER/MAJOR findings, the fixes land and the
orchestrator verifies them; further review rounds only at her word —
"one" is read as one, not as the standing up-to-three ladder. The
`/Applications` refresh follows the closed review, zero-instance-checked
at that moment (the R2-5 rule).

**A47 — a LIVE finding, ruled to run FIRST (her words in the ledger row
above):** the take-card gap. Her directive on staffing, verbatim: *"do
as deep of a dive as you need to verify and fix this issue because it
realy is quite bothersome… I would use fable to find and fix that bug as
well as a first task, maybe spawning a unique subagent for it."* So the
order is **1F (Fable) → 2A…2E (Opus) → the one Fable cold review →
refresh.** Note for the record: her app was LIVE at the screenshot
("Synced 10:13 AM"), so the no-Release-build / no-refresh / never-quit
instance rules bind every session until the end-of-phase window.

**MID-PHASE REFRESH — 2026-07-27, author-opened window (recorded the
turn it happened).** After the 1F report reached her ("the gap on your
screen remains until the end-of-phase refresh — your app is live"), she
closed the app and said, verbatim: *"i've closed my app so it should be
ready."* Read as opening the window for the 1F fix, and executed as a
**pinned build**: `/Applications/Variorum.app` was refreshed from a
Release build of **commit `e5c3a80`** (Stage 1 + Batch 1F, exactly the
adjudicated set) built in a throwaway git worktree — NOT from the
working tree, where the 2A Opus implementer was mid-flight; nothing
unadjudicated shipped. Preconditions honored: fresh WAL-safe backup
first (`variorum-backup-2026-07-27-171216.sqlite`, `integrity_check`
ok — the A1 rail), zero instances verified at build AND immediately
before the copy, signature verified after
*[removed for publication]*
concern (marker 4). The K6 end-of-phase refresh still happens after the
Fable cold review closes — it is what carries Stage 2. Worktree note
for future refreshes of this shape: the app project's local-package
reference requires the checkout directory to be NAMED `variorum`
(a `…/wt1f/variorum` worktree builds; any other leaf name fails SPM
resolution).

### Batch 1F — the take-card gap (A47) — FABLE implementer, runs before Stage 2

**Read first, in this order:** this sitting record and ledger row A47;
the constitution (P-1…P-9, esp. P-3, P-7, P-8) and "Stage 4 lessons";
"Environment traps"; `notes/TEXTKIT2_NOTES.md` §2 and §3 IN FULL; batch
record **1A** (the PanePublisher refutation — four grounds — and traced
mechanism 3), **1C** (the pane clean-bill: "`PaneMeasurement` lays out
first, so a pane never sees an estimate", plus `PhantomSpaceTests`),
**1E** (the trigger table — WHY panes and the inline editor are out of
its scope) and the round-1 clean bill's pane-host sentence. Then
`PaneSurface.swift` / `PanePublisher` and the Takes stack's pane
composition, with fresh eyes.

**What is known, stated precisely:**

- The surface is a **Takes stack card** — a `PaneSurface` pane wearing
  the live ring — NOT the Write editor. 1E's fix is scoped
  `scrollView != nil` (detail editor only) and **deliberately does not
  reach panes**, on 1C's finding that every pane measures through
  `PaneMeasurement.height`, which calls `ensureLayout(documentRange)`
  first. **Her report is evidence that story is incomplete somewhere.**
  Finding WHERE is the batch's job; it may be a different mechanism
  entirely rather than a hole in that claim.
- The gap is **stable** now — it no longer vanishes when she clicks
  into other blocks (her words; 1A's anchor/geometry fixes are the
  likely reason it stopped MOVING). What remains is a static
  over-allocation of vertical space inside one card.
- The status bar read **`805w take · 1,727w post`** while the card
  showed ~60 words. Explain this reading: same take or a different
  take? If the caret take really holds 805 words, where do they render?
  If it holds ~60, why was the card framed for something far taller?

**Hypotheses to confirm or refute, IN ORDER, pin-first (the
hallucination guard: a killed hypothesis recorded is a good outcome; a
fix built on an unconfirmed one is the forbidden class):**

1. **Stored trailing newlines — CONTENT, not a bug.** Read her REAL
   store **READ-ONLY** (the container path is in "Environment traps";
   post "Things I want to do before Brazil", block ordinal 28/31, id
   prefix `52204DF`): does the caret take's `working_text` end in a
   newline run? If YES, this is the 2026-07-12 content-spacing ruling
   plus possibly the iOS-accrual KnownIssues class — **report, never
   trim** (trimming stored content is product-flavored and hers).
   Evidence against, weighed honestly: she says the space has no
   "further newlines to click into", and stored newlines are clickable
   lines.
2. **A stale pane height across take/text switching** — the card framed
   for a longer sibling take (the 805-word reading?) while displaying a
   short one; check every path that swaps a pane's text under an
   equality-gated height sink (the overlay/sink delivery law — state
   delivered at wire time; the starved-host class).
3. **TK2 estimated fragments inside the LIVE pane path** — does the
   live mode size through `PaneMeasurement` the way read panes do, or
   does the live editor's own geometry take over when the ring lands?
4. **`PanePublisher`'s one-directional heal on UPDATE paths** — 1A
   refuted it for the mount path (`runTurn` re-measures
   unconditionally); verify the same holds for text-change, live↔read
   flips, and width changes, rather than inheriting the refutation.

**Hard constraints:** trace before fixing; every bug-class fix lands
with a red-on-old pin verified by BEHAVIORAL REVERT, restored to a
checksum; narrowness pins where a carve/guard changes; P-3 — extend
`PaneSurface`/the one authority, never a second measurement brain or
liveness mechanism; P-8 overlays-never-rendering-attributes; **zero
`Sources/VariorumCore/Sync/` lines; no schema change; her real store is
READ-ONLY to this batch** (if a fix would need a store write, stop and
report); **her app is LIVE** — never quit/kill it, no Release builds,
no `/Applications` refresh (the refresh is end-of-phase regardless);
Mac tests from `App/Variorum/` with suite-level `-only-testing`,
confirm the "Test run with N tests" line; the full Mac suite + core
suite green at the end, `TutorialWalkTests` included (P-6). If the
mechanism turns out product-flavored (stored content, a taste call),
**report with options instead of fixing** — the author decides.

**Deliverables:** the traced mechanism (or the honest report that it is
content/product-flavored); the fix with pins if it is a bug; a batch
record in this file (the 13b form — commits, counts before → after,
traced mechanism, judgment calls, red-on-old evidence, deviations,
ladder foci for the end-of-phase review); the A47 ledger row updated;
commits per convention. Counts at batch open: core **858/98** · Mac
**733/129** · mobile 14/4 — the first two verified by the orchestrator's
own runs this sitting.

## The K6 cold review — round 1 findings + dispositions (2026-07-27, fresh Fable reviewer, `REVIEW_PROMPT.md` verbatim, zero framing)

**2 MAJOR · 3 MINOR · 3 NIT.** The reviewer verified both suites by its
own runs (core 881/100, Mac 780/135 — matching), confirmed zero
`Sync/`/`Persistence/`/`Models/` lines, re-derived the batches'
architectural claims cold (1F's termination argument walked across all
six pane composers; 2A's "already true" inheritance traced to its
sources; 2C's `blockExtents` mirroring compared line-level), and ran
the 2D-assigned dead-door sweep. **Every finding carries a traced
mechanism; I agree with all of them.** Dispositions:

| # | Sev | Finding (compressed — the reviewer's full traces are in the review report, quoted in the fix records) | Disposition |
|---|-----|---|---|
| K1 | **MAJOR** | **The reader's page address is a post INDEX, not an identity** (`PageIndex.Position.postIndex: Int`; `adopt()` clamps, never re-anchors) — a membership/order change moves the page under her, falsifying 2C's own (post, page-in-post) architecture claim; reachable via 2D's order menu, 1D's mid-session shelving, or any sync round. The same class sits in Book's `spreadLeftIndex`, which can also strand `focusedPostID` off-spread with the arrows withdrawn. | **AGREED — FIX.** Anchor by postID: capture the shown post's ID before adopt, re-derive the index from the new list, clamp only when the post left the book; same for the spread; call the spread's focus-release from `adopt`. Red-on-old pins BOTH ways (insertion and reorder under a held position) — they must fail on current code. |
| K2 | **MAJOR** | **The conversion freezes the STORED order while every carrier promises "the order you're looking at"** — 2D's own A31 view override is active on the same surfaces and neither door passes it; the one case where looking-at ≠ stored is the case the batch itself created, untested. | **AGREED — FIX.** `convertSmartReadingToCurated` gains `order:` forwarded to `assembleReading`; the navigator door passes `model.viewOrder`; the shelf passes nil. Red-on-old pin: convert under an active override, minted order equals the override's assembly. |
| K3 | MINOR | `PageComposer.compose` hand-copies `joinRenderedTexts`' conditional beside a real call to it — ranges from one string applied to the other; byte-equal today, structural drift risk (worst case `NSRangeException`), and the record claimed the opposite. | **AGREED — FIX architecturally:** make `composed` the body (ONE walk), so the existing body-equality pin becomes the real drift guard. No red-on-old possible (equal today) — traced mechanism + this justification is the architectural-finding standard. |
| K4 | MINOR | The 2B progress/visibility brain (`noteVisible` family) has zero production callers, against its own comment's rule ("deleted rather than kept warm on speculation") — 2C shipped, did not adopt it, did not delete it. | **AGREED — FIX by deletion** (brain + its pins), per the comment's own rule. Cleanliness with written justification; no pin owed. |
| K5 | MINOR | `TagListSection` is a second Phase-13-IA-orphaned dead view (the `ReadingsSection` class; the 2D-assigned sweep's find). No capability stranded — R52's Settings home holds tag management. | **AGREED — FIX by deletion.** |
| K6f | NIT | Paginated Read's openers/titles re-adopt only on membership-ID changes — renames/retitles/remote edits render stale mid-read; self-corrects on remount; read-only, no data hazard. | **RECORD-ONLY** — a staleness class, named; a per-delivery refresh would buy little for real cost. |
| K7 | NIT | `attachToken` overwritten unguarded on `onAppear` — SPECULATIVE; no double-fire traceable in this app's compositions. | **RECORD-ONLY** per the hallucination guard: no traced mechanism, no fix. The one-line `guard attachToken == nil` is named here for the day the class ever fires. |
| K8 | NIT | Ledger row C3 still reads "committed, not started" — stale against the phase's own record (1A rescoped it to the block-extent memo; 1C measured; 1E built option E). | **AGREED — MY record error; fixed in this commit** (the row now carries C3's transformation and what remains hers: the memo's Parts 1/3 + Q3, QUESTIONS #29/#39). |

**Confirmed-fix set: K1, K2, K3, K4, K5** — authorized to the SAME
reviewer session per the cross-model flow's letter (the reviewer
implements the fixes for its confirmed findings itself; here
reviewer = Fable and the Stage 2 implementers were Opus). Per K6's
"one" ruling there is NO second cold round: the architect verifies the
fix diff and re-runs both suites, and anything still open goes to the
author. The implementer sanity pass over the reviewer's diff is the
architect's (the batch records + adjudications above are that
context).

### The K6 review — FIX PASS (2026-07-27, the reviewer session itself, per the authorization above; all five dispositions implemented)

**Commits:** `5bfa26c` (K2 core — the model-changes-first convention) ·
`88214e2` (K1) · `c2e9333` (K2 faces) · `600d8f5` (K3) · `a042e3a`
(K4+K5) · this record's. **Zero `Sources/VariorumCore/Sync/` lines, zero
schema** (`git diff --stat` over the range: `Operations+ReadingConversion`
is the only core source touched). **Final counts, my own full runs:**
core **`✔ Test run with 882 tests in 100 suites`** (+1: the K2 core pin) ·
Mac **`✔ Test run with 782 tests in 134 suites`** (+3 pins −1 deleted
test; −1 suite = the deleted `BookProgressBrainTests`) · mobile
**BUILD SUCCEEDED** (`generic/platform=iOS Simulator`; no mobile code in
the diff — see deviations for the destination note). **P-6:** the seven
tutorial suites re-run explicitly by TYPE name after everything landed —
`✔ Test run with 49 tests in 7 suites` — beside their run inside the full
suite. Her app was live at one instance check and untouched (no Release
build, no `/Applications` refresh; the K6 refresh remains the
orchestrator's, after verification).

| # | What changed | Traced mechanism (why this shape) | Red-on-old evidence |
|---|---|---|---|
| **K1** | `PagedReadModel.adopt` captures the shown post's ID before the entries list changes and re-derives `position.postIndex` from the new list (clamp only when the post left the book). `BookViewModel.adopt` anchors `spreadLeftIndex` the same way — the FOCUSED post while it is on the spread (keeping its side: a right-page anchor lands `newIndex − 1`), else the left page — and now releases focus when its post leaves the book, via the new `releaseFocusIfItLeftTheBook()`. | Both position holders were post INDEXES merely clamped on adopt; an insertion (sync; 1D's bridge shelving) or an A31 order flip shifted every later index and the address named a DIFFERENT post — the page under her changed, falsifying 2C's own address rule; the spread could additionally strand `focusedPostID` off-book with arrows withdrawn. **One deliberate adjustment to the disposition's letter, flagged for the architect:** the disposition said "call the spread's focus-release from adopt", but `releaseFocusIfItLeftTheSpread()` there would have been mode-blind — `BookViewModel` serves OUTLINE, where the focused post is rarely on the spread's two indices, and the observation delivers at autosave-settle cadence, so the literal call would have unmounted the Outline editor mid-typing on every delivery. The release is therefore BOOK-scoped; with identity anchoring, a spread-focused post can only leave the spread by leaving the book (or the window), so the book test IS the spread test — and the stale-focus arm of the pin proves the disposition's intent is met. | **Revert-red, BOTH pins, checksum-restored (`shasum -c` OK both files).** Paged revert (re-anchor block removed): `theAddressSurvivesMembershipAndOrderChangesByIdentity` RED — the pane named post `…0001` where her post is `…000C` (`✘ Test run with 6 tests`). Spread revert (pre-fix clamp-only adopt restored): `theSpreadSurvivesMembershipAndOrderChangesByIdentity` RED on **all four arms** — both pages swapped, the focused post off-spread, stale focus never released (`✘ Test run with 7 tests`). Pin note: the paged pin drives the reader's position via `seed(fromFocus:)`, not `showPost` — `showPost` deliberately no-ops when the post is already a spread leaf, and post 1 is page one's right leaf on a short book. |
| **K2** | Core (`5bfa26c`): `convertSmartReadingToCurated` gains `order: Queries.ReadingOrder? = nil`, forwarded to the ONE `assembleReading` call; nil = stored order, every existing caller byte-identical. Faces (`c2e9333`): `BookStructureModel.convertToCurated` gains and forwards `order:`; `BookView`'s offer-sheet closure passes `model.viewOrder`; the shelf door passes nothing (no override exists there). **Plus one composition line:** on a successful conversion the view CLEARS `model.viewOrder` — the "Save as This Book's Order" door's own recorded rule (frozen IS the book's order now; the menu must stop claiming a separate way of looking; content is identical at that instant, so nothing on screen moves). | A31's override and the conversion shipped in the same batch on the same surface; neither door passed the override, so the conversion froze the STORED order while the sheet promised "the order you're looking at them" — false exactly when an override was active, surfacing only later as a silent reorder. | **Revert-red twice, checksum-restored.** Core revert (forwarding → `order: nil` inside the op): `conversionUnderAViewOrderOverrideFreezesTheOrderSheIsLookingAt` RED on both halves (rows stored-ASC vs seen-DESC; the post-conversion read likewise). Face revert (the structure model's forwarding dropped): `theNavigatorConversionFreezesTheOrderSheIsBrowsing` RED (stored-ASC vs browsed-DESC). **The one line left unpinned, stated rather than papered over:** `BookView`'s sheet-closure argument `order: model.viewOrder` — driving a presented sheet's confirm through hosted UI is the cost; the structure-model pin sits one call below it. |
| **K3** | `PageComposer.compose` builds ONE string: the separate `joinRenderedTexts` call is gone and `let body = composed` — the range walk's own output IS the body. Doc comments updated to carry the real guard relationship. | Two strings from two code paths (the walk's hand-copied join conditional beside the real join), ranges computed on one and attributes applied to the other; byte-equal today (compared line-level against `PostRender.swift` at review), so the degradation is structural — future drift lands callout indents on wrong characters or an out-of-bounds `addAttribute` (NSRangeException). With one string, the EXISTING pin `theComposedBodyIsTheRatifiedProjection` (body == `renderedText`) stops being a tautology and becomes the drift guard on the conditional. | **No red-on-old owed or claimed** (the two strings are byte-equal today — an architectural finding under the hallucination guard's standard: mechanism traced, justification written). Pagination suites `✔ Test run with 16 tests in 3 suites`; the pin now carries load it could not carry before. |
| **K4** | The 13b 4F progress/visibility brain deleted from `BookViewModel` (`noteVisible` / `visiblePosts` / `progressPosition` / `readingProgress`) with its one-test suite `BookProgressBrainTests`; a note at each site records where it went and that her A6 "investigate the bugginess first" instruction binds any re-add. | Zero production callers after 2A removed the face, 2B read `spreadLeftIndex` exactly, and 2C built its own page domain — against the brain's own recorded rule ("deleted rather than kept warm on speculation"), which 2C neither honored nor amended. | **Cleanliness deletion — no pin owed.** Grep-verified zero remaining references (Canvas's unrelated `noteVisibleRect` untouched). One compile stumble caught by the build gate and fixed in the same commit: the deletion first left the dead suite's `@MainActor` + doc comment stranded above the spread suite (duplicate-attribute compile error) — the gate did its job. Book suites `✔ Test run with 23 tests in 4 suites`. |
| **K5** | `TagListSection` deleted from `Features/Tags/TagViews.swift`; the file header now records the retirement (the `ReadingsSection` class exactly). `TagAssignmentSheet` — still referenced twice — untouched. | The second Phase-13-IA-orphaned sidebar view, found by the 2D-assigned dead-door sweep; dead code with NO capability stranded (tag create/rename/delete live in Settings — `AppSettingsView`, R52's home). | **Cleanliness deletion — no pin owed.** Grep before and after: zero references remain beyond the documentary header line; `TagCreateTarget` died with its only user. |

**Deviations / notes for the architect's verification pass:**

- **K1's book-scoped release** (the one place the fix deliberately
  refines the disposition's letter — argued and pinned above; if the
  architect reads the spread-scoped letter as binding, the change is
  four lines, but it will break Outline typing and
  `focusImpliesExpansionAndCollapseReleasesFocus` documents why).
- **K2's override clear on success** rides the fix as the saved-order
  door's own precedent applied to the same fact ("this IS the book's
  order now"); one line to drop if the architect reads it as scope
  creep.
- **The 2E `-only-testing` trap fired once at ME:** a single-TEST filter
  (`…/PagedReadViewTests/theAddressSurvives…`) matched nothing and
  reported `✔ Test run with 0 tests` — caught by the run-line rule,
  re-run at suite level. The trap note earns its binding status.
- **Mobile destination note:** bare `xcodebuild build -scheme
  VariorumMobile` now fails on a provisioning complaint about the
  physical Mac as run destination (environment drift, not code — no
  mobile source is in this diff); `-destination 'generic/platform=iOS
  Simulator'` builds clean and is the honest form for future records.
- **NOT touched, per the dispositions:** K6f and K7 (record-only; K7
  untraced — the hallucination guard holds), K8 (the architect's own
  correction, already landed in `9eec274`).

## POST-CLOSEOUT — A47 CONTINUED (A47b): the void SURVIVES the fixed build, and her birth story arrives (2026-07-27, ~15:25)

**Her report, verbatim:** *"ok, so the issue is that it still appears. I
think I actually know the cause of it - I think I made a number of
newlines, then the newline removal on the edges of the post around the
edges actually deleted the existing new lines, but then they appear…
I think that the issue spawned in write when I wanted to be able to
scroll down further on the page, but i couldn't, so then I made a bunch
of new lines so I could have teh text in the middle of the page rather
than the bottom. it must've been removed somehow but now there are no
new lines there (tried to highlight what does exist so it's clear) but
that issue is still there."* Screenshot on record: same take card
(blk 28/31 · 52B204DF, Takes stack), taken **15:25 — twenty-one minutes
AFTER the fixed build was installed at a zero-instance window**, so she
was ON the 1F build; a full-width selection highlight covers the UPPER
~250 pt of the void (selectable characters existed there at 15:25); the
remaining ~600 pt below it un-selectable.

**The store, read at ~15:30 (read-only), and it is not what the morning
read showed:** the take is now **3,997 chars · 45 newlines · ZERO
trailing whitespace · `updated_at 21:26:19Z` (15:26 local — one minute
AFTER her screenshot)**. This morning's 1F read (and the sole
commit_point, `kind=auto`, stamped **10:12:45** — launch+2s, the idle
sweep insuring a dirty buffer) was **4,261 chars · 50 newlines ·
trailing "…everywhere. "**. So **264 characters including 5 newlines
LEFT this take today**, after the morning read, around the moment of
her screenshot — and the pre-shrink text is preserved whole in the
10:12 auto-commit (nothing is lost; the insurance held).

**Two live questions, handed to Batch 1G (FABLE, spawned this turn):**

1. **Why did the 1F heal not fire on the fixed build?** Top suspect,
   stated for the record: `reconvergeIfDiverged` rides
   `PaneTextView.layout()` — if AppKit never runs another layout pass
   on an idle, already-laid-out card, the divergence check has no
   trigger and a stale frame keeps forever. The 1F pin drove the pass
   in its harness; R3-4's lesson (a feature inert in production while
   every pin drives it by hand) may have recurred one layer up.
2. **What removed 264 chars from this take, and was it authorized?**
   If she deleted her highlighted selection herself, fine — but if an
   automatic edge-trim removed stored content from INSIDE a take
   (I4: newlines are content; the 2026-07-12 ruling made typed gaps
   durable), that is the forbidden class, insurance notwithstanding.
   Her own hypothesis — an edge-of-post newline removal — names the
   open-tail whitespace-drop rule as a candidate; block 28 is NOT the
   last block, so the geometry of where she typed matters.

**Her motive is A22 verbatim** (typewriter room — she built it by hand
out of newlines because the app refuses to scroll past the end); the
13d plan's A22 row already binds the two: deliberate room must be REAL.

**A47b follow-up rulings (author, 2026-07-27, ~15:45 — verbatim):**
*"I deleted the highlighted 5 lines of newlines - I don't think that is
actually 264 characters though, so maybe something else was deleted? or
maybe the visual glitch means that I deleted it even if it didn't
visually seem like I was deleting it? there's a way bigger gap than the
newlines that existed. and yeah, I think we should build A22 properly
in 13d. You can refresh the install when this issue is fixed. I would
restore the missing 264 characters I think."* So: **(1)** the 5-line
deletion was HERS and deliberate — Q2 narrows to the other ~259
characters: identify them EXACTLY (the 10:12 commit vs the current
working_text is a computable diff) and whether her selection could have
covered more than it visually showed (her own hypothesis — ties Q2 to
Q1's rendering state). **(2) The restore is authorized, BOUNDED by her
intent** (her "I think" is a hedge on content she hasn't seen): if the
259 are real prose, restore them through ordinary operations behind the
A1 rail — current state committed first as insurance, her deliberate
5-newline deletion preserved; if they are whitespace-only, restoring
junk she deliberately cleaned would contradict her intent — report
instead, one line for her to confirm. Ambiguity ⇒ stop and report.
**(3) The install refresh is authorized "when this issue is fixed"**
(the post-close hold lifts on the 1G fix landing verified). **(4) A22
is CONFIRMED for 13d** ("we should build A22 properly in 13d") — the
13d plan's row carries it.

**A47b, her design question (2026-07-27, verbatim):** *"should we just
stop trimming the whitespace at the end of blocks? that seems to be the
source of this issue on some level (though obviously the fact that the
newlines no longer exist but are rendered as a large block is the
bigger issue). still, I'm kind of curious what our approach is there
and if we should fix it."* Answered directly (the architect's reply is
the record of the approach): block ENDS are never trimmed (I4 +
the 2026-07-12 durability ruling — her 5 deleted blank lines had been
stored faithfully); the trim lives at exactly two edges — the OPEN
TAIL (whitespace-only tail content never mints) and the leading/
trailing blank lines of BULK-ENTERED material. The recommendation
given: keep the edge rules (the iOS accrual defect is the proof of the
pollution class they prevent), build A22 as the real answer to her
need, and fix the FELT bug regardless — typed tail whitespace must
never look durable and then silently vanish at a later teardown (the
surface-vs-store disagreement class). **Her ruling is deliberately NOT
taken now** — it is the 13d design sitting's (the A22/A11/A15 cluster),
with 1G's Q2 verdict as an input (whether the edge-trim even caused
her 259).

### Batch 1G — A47b answered: two more real gaps in the heal, the 264 characters identified and RESTORED (2026-07-27, post-closeout)

**Commits:** `f285c84` (the fix + its three pins + the durability
characterization pin) · the record commit carrying this section, the
A47 ledger update, and the 13d A22/A11 notes. **Counts:** core
**`✔ Test run with 882 tests in 100 suites`** (untouched — zero
`Sources/VariorumCore/` lines, coherent by construction) · Mac
**`✔ Test run with 786 tests in 135 suites`** (was 782/134: +3 pins in
`TakePaneMeasureTests`, +1 new suite `TakePaneDurabilityTests`) ·
tutorial suites re-run explicitly by type:
**`✔ Test run with 49 tests in 7 suites`** (P-6). Zero
`Sources/VariorumCore/Sync/` lines; no schema. **Diff scope:** 3 files —
`Surface/PaneSurface.swift` (the occasion wires + the frame lever +
observation counters), `VariorumTests/TakePaneMeasureTests.swift`
(three 1G pins + the 1F pin's falsified comment corrected),
`VariorumTests/TakePaneDurabilityTests.swift` (new, characterization).
**Her store:** read-only throughout the investigation (`mode=ro` /
`immutable=1`); the ONE authorized write (the restore below) ran behind
two fresh WAL-safe backups at verified zero-instance windows. Her app
was never running during any write or build.

#### Q1 — WHY THE 1F HEAL DID NOT FIRE: the top suspect confirmed in refined form, plus a second gap the suspect was hiding

**The census (the experiment the brief demanded, run in the REAL
mounted `TakesBoardView` and a standalone host, with new
pass-counters on `PaneTextView`):** an idle, already-laid-out card
receives **ZERO layout passes** from clicks, selections, scroll-wheel
events, ring migrations, blur, or two seconds of idle run loop — the
counters stay frozen through every phase. `layout()` runs only on
frame-size changes and explicit `needsLayout`, and nothing in her
15:04–15:25 usage (clicking, highlighting, scrolling — her words)
produces either. So the 1F divergence check, riding `layout()` alone,
**never ran in the shipped app for exactly the situations she was in**
— R3-4's class one layer up, precisely as the brief suspected: the 1F
pin drives `needsLayout = true` by hand at its line 164 (its comment
even claimed clicks/ring-moves/scrolls deliver such passes — falsified
by the census, corrected on the pin).

**The refinement that matters:** the suspect's LITERAL form ("no pass
ever arrives") is only half true — the 1F stand-in construction
self-heals on the fixed build (a storage edit's `endEditing` queues
its own layout pass; both E1 experiments watched it heal in the real
board). What does NOT self-deliver a pass is a divergence born
without leaving layout dirt — and the hunt for how that could happen
exposed **GAP 2, which the starvation was hiding: the heal's remedy
can be a NO-OP.** The check's only corrective action was a height
publish — a SwiftUI state write. When the frame diverges while the
state ALREADY holds the measured value (a frame application dropped
by SwiftUI mid-update — the exact hazard class `PanePublisher` was
built around, MINOR-D), the equal-value write invalidates nothing:
**the check fires forever and heals nothing.** Demonstrated by pin
and revert: with the lever removed, a 250 pt frame-vs-measurement
divergence survived the check running repeatedly (the REVERT-1 red).
This shape also composes into a coherent birth story for her card —
a tall→short correction during the launch storm (the 1F candidate
table's transient) whose short re-frame was dropped, every later
re-publish an equal-value no-op — though the birth itself remains
honestly UNIDENTIFIED (unchanged from 1F; no construction I drove
reproduced it, and I do not claim it).

**What shipped (both gaps closed, one component — P-3):**

1. **Production occasions.** `PaneTextView` fires the divergence check
   on three USER-EVENT wires: `NSScrollView.didEndLiveScrollNotification`
   of the enclosing scroll view (registered at `viewDidMoveToWindow`;
   the census verified the real board's panes DO sit in an
   NSScrollView — SwiftUI's `HostingScrollView`), a click on the pane
   (`mouseDown`), and a LIVENESS TRANSITION (her "clicking into other
   blocks", verbatim — the one event a stale card reliably receives).
   Transition-gated and event-driven: cost is one warm pane-scale
   measurement per user event (the cost class 1F already accepted per
   layout pass), zero at rest.
2. **The frame lever.** `PanePublisher`'s convergence chase goes
   both-sided (`abs(rendered − height) > slack`, replacing the
   short-only chase) and gains `applyFrame`: a chase turn that still
   renders divergent pulls the AppKit frame DIRECTLY to the measured
   height — on a deferred main-queue turn, never inside a SwiftUI
   update. SwiftUI's next layout re-imposes the same value, so the two
   authorities agree instead of fighting.

**The termination argument, extended explicitly (the 1F foci's ask):**
occasions are discrete user events a height publish can never cause;
the check publishes only on divergence; a corrective publish/lever
re-frames the view to the measurement, and the next layout pass's own
divergence branch measures equal and stays silent; the lever fires
only inside the budgeted chase (`healTurnBudget`, unchanged at 3) and
moves the frame toward the value the state holds — no oscillation is
possible because only one side ever moves. The composer-capped
compositions (the rail's ScrollView-wrapped cards) are unaffected for
1F's recorded reason — their pane bounds equal their measurement
inside the cap.

**What heals her on-screen card:** any scroll-gesture end, any click
on it, or any ring move — the events her session is made of.
**The stated falsifier:** a void that survives scrolling and clicking
ON THIS BUILD would mean a third mechanism (the one candidate left
standing: `usageBoundsForTextContainer` itself mis-measuring under
`ensureLayout` on her live instance — 1C proved it exact in every
driven state, so I did not modify the measurement brain on an
unproven theory). That report, if it comes, points the next session
at `PaneMeasurement` with a precise target.

#### Q2 — WHAT REMOVED THE 264 CHARACTERS: identified to the byte, and the automatic-removal theory is dead

**The store archaeology (the WAL held every write of her session —
main db last checkpointed 11:12; replayed commit-by-commit by pairing
the db with progressively truncated WAL copies, all on scratch copies,
her store untouched):**

| Local time | working_text | Δ | What |
|---|---|---|---|
| (since Jul 24) | 4,261 · 50 nl | — | her text, stable through the 15:02 backup |
| 15:24:50.661 | 4,262 · trail 1 | **+1** | one Return typed at the end |
| 15:24:51.482 | 4,261 · trail 0 | **−1** | …and removed, 821 ms later |
| 15:25 | — | — | her screenshot: highlight over the void's upper ~250 pt |
| 15:26:12.160 | 3,999 · trail 2 | **−262** | **her highlight deletion** — "\nin addition…everywhere. " |
| 15:26:14.562 | 3,997 · trail 0 | −2 | her second delete: the last two blank lines |
| 15:26:16.453 | 4,006 · trail 9 | **+9** | nine Returns typed at the end |
| 15:26:19.180 | 3,997 · trail 0 | **−9** | …removed, 2.73 s later — **byte-identical** to the 15:26:14 state |

**The 264 characters, exactly:** the take's LAST TWO PROSE PARAGRAPHS
plus their ordinary separators — `\n\n\n` + *"in addition to the tabs
of open notes at the left, maybe you should be able to star like up
to 5 of them so they just always are there on the left. maybe be able
to star books? or just individual notes?"* + `\n\n` + *"need to change
the wording from post to note everywhere. "* (trailing space
included). They are her OWN intake notes — the A29 stars idea and the
K5 post→note sweep. The current text was a verified strict
byte-prefix of the 10:12:45 commit; the removal was exactly the
trailing 264 bytes.

**Verdict on her hypothesis (a) — CONFIRMED:** her selection covered
more than it visually showed. The morning capture's "~60 visible
words" WERE these paragraphs rendering normally; at 15:25 the same
rows photographed as blank while remaining selectable (the store
proves characters existed at those positions — she selected and
deleted them one minute later believing them newlines; there were
never 5 standalone blank lines to delete — the 5 newlines were the
paragraphs' own separators). The deletion was HERS and the rendering
state deceived her — laid-out-but-undrawn text, the A47 state's
second face.

**Verdict on hypothesis (b) — NO automatic path exists, and the
ground is now pinned:** the app-wide sweep found no whitespace trim
anywhere in the pane/autosave path (every `trimmingCharacters` call
is names/labels/queries; the only content-level whitespace rules are
`SegmentationRules`' ratified bulk-entry edge-run drop and the
open-tail whitespace-only-never-mints guard — `idleMintTail` and
`finalizeWork` both `guard !tail.allSatisfy(\.isWhitespace)` — which
never touch an existing block). The E2 experiment typed nine real
Returns into the live take card in the real mounted board: they
survive autosave (stored byte-exact), ring migration, projection
adoption, and teardown — now the permanent characterization pin
`TakePaneDurabilityTests` (labelled as such; it documents correct
behavior and guards the forbidden class). The −1/−9 removals were
therefore her own editing — and the −9's byte-identical revert 2.73 s
after typing is the exact signature of ⌘Z over a coalesced Return
burst (or a held ⌫); with the tail rendering invisibly, typing that
produced no visible change and being backed out is the coherent
reading. **No I4/durability violation occurred in the takes path;
nothing is dismissed without the pin that would catch it.**

**The one AUTHORIZED "removal" her original narrative fits:** typed
newlines at the very END OF THE POST (past the last block, in Write)
are open-tail entry — whitespace-only tails never mint and evaporate
at teardown, by the ratified Phase 7 rules, WITHOUT ever reaching the
store (consistent with her text being byte-stable July 24 → 15:24
while she remembers building room "out of newlines" that "must've
been removed somehow"). That surface-vs-store disagreement — room
that looks durable and silently vanishes — is exactly the A22 input;
recorded in the 13d plan's A22/A11 rows, built there, not here.

#### The RESTORE — executed per her authorization (2026-07-27, ~16:33)

The 259 non-newline characters are REAL PROSE → restore authorized.
Executed through ORDINARY operations via a scratch VariorumCore
executable (never ad-hoc row edits), behind the A1 rail: fresh
WAL-safe backups `variorum-backup-2026-07-27-223147.sqlite` (pre) and
`…-223415.sqlite` (post-restore, pre-refresh), both `integrity_check`
ok; zero instances verified immediately before the write; preconditions
re-checked INSIDE the tool (len 3,997 / commit 4,261 / strict-prefix —
abort on any drift). **(1)** `commit(kind: .manual)` — the current
3,997 state preserved as insurance ("A47b insurance (2026-07-27)…"),
so today's state stays one restore away forever; **(2)**
`restoreCommit` back to the 10:12:45 auto-commit — the §9 door whose
semantics ARE this act, byte-exact by construction. Verified read-only
after: working_text 4,261 chars / 50 newlines ending "…everywhere. ";
2 commits on the variant; ONE ordinary outbox row (the restore rides
ordinary sync to the mirror on her next signed-in round).
**A judgment call flagged for her, not hidden:** her follow-up asked
for "the missing 264 characters" restored while the coordinator's
instruction said "her deliberate 5-blank-line deletion still applied"
— the two are INCOMPATIBLE with the actual bytes (the 5 newlines ARE
the restored paragraphs' own separators; subtracting them would fuse
"takes" into "in addition…"). Her explicit sentence was honored: the
264 restored VERBATIM (= the known-good 10:12 state she wrote). If
she still wants the gap above "in addition" one blank line tighter,
it is a one-second ordinary edit in the app.

#### The `/Applications` REFRESH — executed under her authorization ("when this issue is fixed")

Release built from `f285c84` (fix landed, suites green, both reverts
red-verified); zero instances at build start AND immediately before
the copy; installed via `ditto`; signature verified
*[removed for publication]*
build against the restored store.

#### Red-on-old evidence — by behavioral revert, checksum-restored (`shasum -c` OK after each)

| Revert applied | RED observed |
|---|---|
| **REVERT 1 — the frame lever removed** (the chase restored to 1F's short-only form, no `applyFrame`) | `aFrameTheStateCannotMoveIsHealedByTheFrameLever` FAILED — the 250 pt frame-vs-measurement divergence survived the check firing (the equal-value no-op, demonstrated); occasion pins stayed green (wires intact — clean attribution) |
| **REVERT 2 — the occasion wires removed** (scroll-end observer, click hook, liveness transition, install wiring; lever kept) | `productionOccasionsRunTheDivergenceCheck` FAILED both arms (`convergenceChecksRun` frozen at 2 through the posted scroll-end and the driven click) and `aLivenessTransitionRunsTheDivergenceCheck` FAILED (`occasionsFired` frozen at 0 through the in-place liveness flip); pin A stayed green (lever intact) |

**Pin honesty, recorded because it cost two iterations:** the first
two occasion-pin constructions asserted a HEAL and stayed GREEN with
the wires deleted — incidental harness machinery (SwiftUI observing a
directly-set child frame; TK2's deferred storage-edit invalidation)
delivered layout passes that healed via the 1F branch + the lever.
Exactly R3-4's recorded first-version trap. The shipped pins take
R3-4's final MECHANICAL form — wire-fired and check-ran counters
(`occasionsFired` / `convergenceChecksRun`, the funnel
`fireConvergenceOccasion()`), asserted synchronously — and the pins'
comments say why. The durability pin is CHARACTERIZATION and says so
in its header (correct behavior documented; no red-on-old owed).

#### Numbered judgment calls

1. **The restore-verbatim call** (flagged above — her sentence over
   the instruction's letter, because the letter was incompatible with
   the actual bytes; ambiguity resolved toward the only coherent
   reading rather than stopping, since her "I would restore the
   missing 264 characters" is itself unambiguous).
2. **The −9 attributed to her own editing** on the strength of: no
   automatic path in code (swept), none under experiment (E2, now
   pinned), the byte-identical-revert signature, and the timeline
   (2.73 s). Honestly bounded: I cannot distinguish ⌘Z from held-⌫
   from here, and her testimony ("it must've been removed somehow")
   most plausibly refers to the open-tail episode, which never touched
   this block's store.
3. **The measurement brain untouched.** The converged-but-mismeasured
   theory (usage bounds wrong under ensureLayout on her live instance)
   would defeat the check silently — but 1C measured it exact in every
   driven state and no experiment here contradicted that; modifying
   the ONE brain on an unproven theory fails the hallucination guard.
   Recorded with its falsifier instead.
4. **The scratch hunt suite (`A47bHuntTests`) deleted after use**, per
   the 1F precedent; its census numbers and refutations are recorded
   here; E2 graduated into the permanent durability pin instead of
   dying with the suite.
5. **No QUESTIONS entry:** nothing new product-flavored — the restore
   and refresh ran under her explicit same-day authorizations; the
   whitespace-approach ruling is already deliberately parked for 13d
   (the section above); the one flagged judgment call (1) is hers to
   reverse cheaply if she disagrees.

#### Deviations

- **The A47b brief's Q1 experiment order was honored** (starvation
  first, by experiment, in the real composition); its top suspect was
  CONFIRMED in refined form rather than whole — the refinement (GAP 2)
  is the more load-bearing finding, and the record says which is
  which.
- **One permission-classifier denial** (a compound heredoc+build
  command for the restore tool) — re-done through ordinary file
  writes + a plain build; no workaround of intent.
- **No lookup subagent used** — every question was answerable by the
  repo, the store, or measurement.
- The full-suite run line, quoted: core
  `✔ Test run with 882 tests in 100 suites` · Mac
  `✔ Test run with 786 tests in 135 suites` · tutorial
  `✔ Test run with 49 tests in 7 suites`.

#### Ladder foci suggested for this batch (1G)

Whether the occasion set is complete for panes that never sit in a
scroll view and never host clicks (the TOC's expanded rows compose
the same surface — do they idle the same way?); whether the frame
lever can fight a composer that DELIBERATELY frames a pane away from
its measurement (the capped-rail argument says no — a reviewer should
try to break it); whether `didEndLiveScrollNotification` actually
posts from SwiftUI's `HostingScrollView` on real trackpad gestures
(the pin drives the notification wire itself — a live-app observation
would close this; recorded as the one production assumption the
harness cannot prove); and whether the durability pin should also
cover the WRITE editor's mid-post block-end newlines (the takes path
is pinned; Write's autosave path was code-swept but not
experiment-pinned).

### Batch 1G — ACCEPTED (2026-07-27); A47 IS CLOSED, and the security flag is resolved on the record

**Verified before accepting, with extra care because the batch wrote to
her REAL STORE:** the take is back at **4,261 bytes exactly** (the
10:12:45 commit's text, byte-count-confirmed read-only), the
**insurance manual commit of the 3,997 pre-restore state** sits in the
block's history with a message naming the event (so the restore itself
is one restore away from reversal), the fresh WAL-safe backup exists
(`…-223415`), `/Applications` is refreshed (16:35) and signed, both
commits present, tree clean, and **core 882/100 · Mac 786/135 green by
my own runs**.

**The subagent harness attached a SECURITY FLAG** (a store write + an
install refresh authorized only by an orchestrator-relayed message —
the flag is correct behavior for a harness that cannot see the author's
session). **Resolved by the architect, who can:** both acts trace to
the author's DIRECT words in this session, quoted in the A47b rulings
paragraph above — *"I would restore the missing 264 characters I
think"* and *"You can refresh the install when this issue is fixed"* —
and the batch executed them behind the exact insurance structure the
relay demanded (backup + commit-current-first + zero-instance windows).
The flag, this review of it, and the trace to her words are recorded so
no future reader mistakes the relay for improvisation.

**The verdicts, adjudicated:**

1. **Q1 — CONFIRMED in a sharper form than briefed, both gaps fixed.**
   Production delivers ZERO layout passes to an idle laid-out card
   (the census proved it — the 1F check never ran in the shipped app;
   R3-4's class one layer up, exactly as suspected), AND the heal's
   only remedy could be a SwiftUI equal-value no-op when the height
   `@State` already matched (a dropped frame application — the check
   would fire forever and heal nothing). The fix gives the check three
   real user-event occasions (scroll-end · clicks · liveness
   transitions — her "clicking into other blocks", verbatim) and a
   frame lever that cannot no-op. Both revert-red. **The honest
   falsifier is stated**: a void surviving a scroll-end/click on this
   build points at `PaneMeasurement` itself.
2. **Q2 — AUTHORIZED, and the deception explained.** The WAL replay
   reconstructed her session sub-second: the 264 characters were her
   last TWO PROSE PARAGRAPHS (the stars idea; the post→note note) plus
   their separators — laid-out-but-UNDRAWN rows that photographed
   blank and selected full-width, so she deleted real prose believing
   it blank lines. Her hypothesis (a), confirmed. **No automatic
   remover exists** — code-swept and experiment-pinned
   (`TakePaneDurabilityTests`); the forbidden class does not fire; her
   earlier vanished-newlines episode fits the ratified open-tail rule
   (recorded into 13d's A22/A11 rows as input).
3. **The restore's judgment call — ACCEPTED:** "restore the missing
   264" was honored verbatim via `restoreCommit` because the
   "preserve her 5-newline deletion" instruction was incompatible with
   the bytes — the 5 newlines ARE the restored paragraphs' separators;
   there never were standalone blank lines. One-second edit if she
   wants the spacing tighter.

**Open observation for her next real session (the one assumption the
harness cannot prove):** that `didEndLiveScroll` posts from SwiftUI's
scroll view under real trackpad gestures — one minute of live use
closes it. If the void survives a real scroll-end or click, that is
the `PaneMeasurement` falsifier and must be reported.

## A47c — THE DRAW GAP, and the author invokes the friction doctrine (2026-07-27, ~17:15)

**Her report, verbatim:** *"ok, so that bug is gone! yay! however,
there's now a different weird thing happening when i click between that
long block and another block. sometimes when i click on the other
block, the long block will temporarily appear blank, before the text
appearance is restored… on one occassion, only the final sentence
stayed visible and the rest of it didn't reappear. there are weird
thing happening where sometimes the whole block comes back and
someitmes only a line or two reappears… in the worst case, the text
stays visibly gone even after clicking in (except for two lines at the
bottom that are not visibly gone). Does the severity of these issues
with the long blocks and the recurrence of the issues seem to indicate
that we need some kind of overhaul with what we're doing? and the
underlying architecture of the block? it's fine if not, I just don't
want to whack a mole these bugs into a bad spaghetti code situation."*
Four screenshots on record (17:15–17:17): the long take card rendering
with its text partially or wholly undrawn — sometimes healing on
click-in, sometimes only the tail lines drawing.

**The architect's reading, recorded before the trace so it can be
tested:** this is the **laid-out-but-UNDRAWN state 1G identified as the
deletion deception — the still-unfixed ROOT.** 1G fixed the FRAME
lifecycle (the gap is gone, her confirmation on record) but its new
heal occasions now exercise the draw path on every click, so the
pre-existing draw gap fires visibly and often. The class is TEXTKIT2
§2/§3's letter (content cropped until a relayout; viewport-order
drawing against a wrong viewport notion) — a CONTENT-SIZED TK2 view
holding arbitrarily long text inside a SwiftUI scroll has no honest
viewport of its own.

**THE P-5 INVOCATION — hers, and it is ruled correct:** three bugs in
one layer in one day (the phantom estimate · the stale frame · the
draw gap) is the friction doctrine's definition of an under-architected
feature. **The response is a DESIGN MEMO, not another patch**
(`notes/plans/phase-13d-memo-long-content-panes.md` — assigned to the
A47c Fable session): the pane surface × LONG content × TK2, behavior
whole, options enumerated with costs (a capped card with in-card
scroll — the S4-31b fixed-strip precedent; an honest viewport wired to
the outer scroll; a CoreText-drawn read tier for long takes — the 2C
paginator precedent; thresholds and where they live), refusal/degrade
wordings, and her rulings BEFORE the build. **The boundary is stated
with the evidence:** the block MODEL is untouched by this — in every
one of these defects the STORE was right (the one content loss went
through her own keystroke on a deceptive surface and was one restore
away) — the overhaul is of ONE rendering layer, not the architecture.

**The A47c session's mandate:** trace the draw gap's mechanism
precisely; if completing 1G's fix needs a small honest mechanism (e.g.
a missing display invalidation after the frame lever), land THAT as
stabilization with a pin — completing an accepted fix is not
whack-a-mole; anything beyond it goes in the memo, unbuilt, for her
rulings. Her A45 connection recorded: the model's upper levels are the
long-take pressure valve, but the layer must handle long takes
gracefully regardless — she must never be forced to restructure to
dodge a renderer.

### A47c session — the draw gap TRACED to one mechanism and stabilized; the memo written (2026-07-27, FABLE)

**Commits:** `3eb8fe3` (the stabilization + both pins) · the record
commit carrying this section and the memo
(`notes/plans/phase-13d-memo-long-content-panes.md`). **Counts:** core
**`✔ Test run with 882 tests in 100 suites`** (untouched — zero
`Sources/` lines, coherent by construction) · Mac
**`✔ Test run with 788 tests in 135 suites`** (was 786/135: +2 A47c
pins in `TakePaneMeasureTests`) · tutorial suites re-run explicitly by
TYPE: **`✔ Test run with 49 tests in 7 suites`** (P-6) · mobile 14/4
untouched (the diff is Mac-target-only). Zero
`Sources/VariorumCore/Sync/` lines; no schema. **Diff scope:** 2
files — `Surface/PaneSurface.swift` (the change-gated style + the
check's render half + the restore counter),
`VariorumTests/TakePaneMeasureTests.swift` (pins A and B).
**Her instance:** never running during the session (`pgrep` empty at
open and at every build window); her real store never opened — this
trace needed no store read. **No Release build; the `/Applications`
refresh is HELD for her word**, per the brief.

#### THE HEADLINE: one mechanism, fully traced — the unguarded full-range `textColor` write strands TK2's rendering surfaces on a tail-scrolled pane, and nothing ever rebuilt them

The trace ran in the REAL mounted `TakesBoardView` (the 1G census
method) with two new instruments: **pixel truth** (compositing the
window's CURRENT layer contents via `CALayer.render(in:)` — a destroyed
rendering surface shows as blank; nothing is force-redrawn) and a
**fragment-surface census** (TK2 draws a pane through per-fragment
child surfaces — `_NSTextContentView` under
`_NSTextRenderingSurfacesGroupView` — created ONLY for the viewport
region; their frames say exactly which regions are drawn). The chain,
each link measured:

1. **The kill.** On a tail-scrolled ~800-word pane (676×2,753 pt,
   frame exact per 1F/1G), a full-range storage attribute write
   destroys the rendering surfaces above the pane's tail — 14 → 6,
   keeping only the last ~274 pt — while `viewportBounds` stays
   CORRECT and the measurement stays exact. The state is
   laid-out-but-undrawn: selectable, measurable, blank — **her worst
   case verbatim ("except for two lines at the bottom"), and the state
   behind 1G's deletion deception.**
2. **The permanence.** Nothing rebuilds the surfaces: `needsDisplay`
   is powerless (the surfaces are the unit of drawing, not the backing
   store), 12+ natural runloop turns deliver nothing, clicking back in
   delivers nothing. A real scroll heals (TK2's own viewport layout) —
   her observed "scrolling up made it disappear."
3. **The production trigger, bisected at the tail:** `applyStyle` ran
   `view.textColor = ink` on EVERY `updateNSView` — measurement,
   `isEditable`, first-responder moves, and selection all proved
   innocent; the textColor write kills (surfaces 14 → 6 on the driven
   call). Every click, ring move, and projection delivery was a fresh
   full-range write on every tokened pane.
4. **The heal, measured:** ONE
   `textViewportLayoutController.layoutViewport()` call rebuilds the
   surfaces for the actual viewport completely (6 → 14, full ink).
5. **Why no earlier session saw it:** the minimal standalone
   composition (1F/1C's replica method) does NOT reproduce the strand
   — driven storage rewrites, invalidations, and textColor writes all
   self-heal there; the strand is real-board-composition-dependent.
   The 1G census method (real board) plus pixel truth was the
   combination that caught it.

**The architect's pre-trace reading, tested:** confirmed in substance —
this IS the laid-out-but-undrawn root behind 1G's deception, it
predates 1F/1G, and the 1G occasions did make it fire visibly (every
occasion's SwiftUI re-render ran the killing write). One correction to
the reading's letter: the viewport NOTION was never stale and the 1G
frame lever needed no display invalidation — the gap was the render
tier itself, below both.

#### What shipped (both halves at the ONE component — completing the accepted 1F/1G mechanism, nothing architectural)

1. **The change-gate** (`PaneTextView.appliedInk`): `applyStyle`
   writes ink/`drawsBackground` ONLY on change — same ink ⇒ zero
   writes of any kind. The everyday trigger is dead; a REAL voice/ink
   switch still writes, as it should.
2. **The check's RENDER half:**
   `reconvergeIfDiverged(restoreRender:)` — the 1G occasions (click ·
   scroll-end · liveness transition) now also schedule ONE coalesced
   deferred `layoutViewport()`, rebuilding any stranded render tier.
   Deferred because inside `updateNSView` the liveness occasion fires
   BEFORE the killing write (a synchronous restore would lose the
   race); occasion-GATED for termination — occasions are discrete user
   events a viewport layout can never cause, while layout passes stay
   geometry-only because a viewport layout CAN queue a layout pass.
   Counter seam `renderRestoresRun` (the R3-4 mechanical form). Cost:
   one viewport-bounded warm pass per occasion burst, zero at rest
   (P1).

**End-to-end on the fixed build:** her exact gesture (tail-scrolled
long card → click the other block → click back) shows NO strand at any
step; a deliberately re-created strand (direct `invalidateLayout`)
heals at the next occasion; quiescence verified (checks 6 → 6,
same-width passes 2 → 2 over 12 idle turns — no ping-pong).

#### Red-on-old evidence — by behavioral revert, checksum-restored (`shasum -c` OK after each)

| Revert applied | RED observed |
|---|---|
| **REVERT 1 — the render half removed** (the `scheduleRenderRestore()` call dropped from the check; counters kept so the pin compiles) | `aStrandedRenderTierIsRebuiltByAConvergenceOccasion` FAILED both arms: `renderRestoresRun` stayed 0 through the fired occasion AND the healed-ink assertion read 0 inked bands — the strand constructed, geometry exact, occasion fired, nothing healed (clean attribution: the strand and non-vacuity arms stayed green) |
| **REVERT 2 — the change-gate removed** (applyStyle restored to the pre-A47c unguarded writes) | `anUnchangedInkUpdateNeverRewritesTheStorage` FAILED: 3 liveness-flip updates = **3 full-range storage edits** counted via `NSTextStorage.didProcessEditing`, with `occasionsFired` proving the updates genuinely reached `updateNSView` |

**Pin honesty, recorded because it cost an iteration (R3-4 again):**
pin B's FIRST version drove a sibling-state tick and stayed GREEN under
revert 2 — SwiftUI's fine-grained invalidation never delivered the
update to the pane, so the pin was hollow. Rebuilt around liveness
flips with `occasionsFired` as the proof-of-update arm, red verified
against the live revert before the fix was restored. Pin A carries a
deliberate OS-drift sensitivity, stated in its doc comment: its STRAND
assertion fails if a macOS update ever fixes the TK2 cull — TEXTKIT2
§5's re-verify posture as a tripwire, so the mechanism is retired
deliberately, never silently.

#### The memo (P-5) — written, nothing from it built

`notes/plans/phase-13d-memo-long-content-panes.md`: the trace's facts
as foundation; the layer's contract whole; the edges enumerated (all
ten pane compositions, caret-in-cap, selection-across-cap, the
full-range-invalidation class, extreme-take measurement cost, R25's
cadence, §5 drift); four options costed — (a) the S4-31b capped card
generalized · (b) a live-wired TK2 viewport (priced out by TEXTKIT2
§2) · (c) a CoreText read tier (the deep escape hatch; costs selection
parity and presses P-3) · (d) the stabilized status quo (landed).
**Recommendation: (d) now, (a) pre-approved as 13d's build if her use
asks for it** — with the threshold and the article-cell question as her
rulings (the memo's §6 decision list). The A45 note is carried in the
memo's own words: the cap, if ruled, is a presentation bound, never a
nudge to restructure.

#### Numbered judgment calls

1. **Both stabilization halves landed, not one.** The gate alone
   leaves every OTHER full-range invalidation (voice switch, string
   adoption) able to strand permanently; the restore alone leaves the
   every-update kill flashing on every click. Together they are
   trigger-death plus self-repair — both are completions of the
   accepted 1F/1G mechanism at the one component, and the mandate's
   example ("a viewport nudge TK2 needs") names the second literally.
2. **The restore is occasion-gated, not layout-pass-gated** — the
   termination argument mirrors 1G's own (user events cannot be caused
   by the mechanism they trigger); a layout-pass-fired restore could
   ping-pong at runloop rate.
3. **The idle-voice-switch residual recorded, not fixed:** a font
   re-attribution while a scrolled card is idle can still strand until
   the next user event. One line (a restore after the font-swap
   branch) if her use ever surfaces it — memo ruling 5.
4. **The scratch hunt suite (`A47cHuntTests`, 13 experiments) deleted
   after use** per the 1F/1G precedent; every census number and
   refutation is recorded here and in the memo; the durable checks
   graduated into the two pins.
5. **No QUESTIONS entry:** the stabilization changes no visible
   behavior except removing the defect; every product-flavored edge is
   deliberately in the memo's §6 decision list for her walk.

#### Deviations

- **The 2E false-green trap fired and was caught in this session:**
  `-only-testing:VariorumTests/TutorialWalkTests` reported
  `** TEST SUCCEEDED **` over **ZERO tests** — `TutorialWalkTests` is a
  FILE of seven `@Suite` types, not a type. The seven type names were
  run explicitly (`✔ Test run with 49 tests in 7 suites`). The traps
  section's rule now has a second concrete instance.
- **No lookup subagent used** — every question was answerable by
  measurement in the real composition, and was measured.
- The full-suite lines, quoted: core
  `✔ Test run with 882 tests in 100 suites` · Mac
  `✔ Test run with 788 tests in 135 suites` · tutorial (explicit types)
  `✔ Test run with 49 tests in 7 suites`.

#### Ladder foci suggested for this session's diff

Whether the render restore should also ride the two remaining
full-range invalidation sites (the font-swap branch and the read-pane
string adoption) rather than waiting for the next user event — the
recorded residual; whether pin A's deliberate OS-drift sensitivity is
the right posture or should soften to a skip-with-record; whether the
change-gate's `NSColor` equality holds across every token path (pin B
pins terminal-light; study/dark inks ride the same conversion but are
not separately pinned); and 1G's still-unresolved focus — whether the
TOC's expanded rows idle the same way (they compose the same surface
but sit in a different scroll composition).

### A47c — ACCEPTED (2026-07-27 evening); the refresh is HELD for her word

**Verified by my own runs: core 882/100 · Mac 788/135 green**; tree
clean, both commits present; the stabilization diff read — the
change-gate (`appliedInk`, same ink ⇒ zero writes) and the render half
(occasion-scheduled, coalesced, one `layoutViewport()`) are both at the
ONE component, both completions of the accepted 1F/1G mechanism,
nothing architectural. **The trace's letter-level correction of my
pre-trace reading is accepted as the better fact:** the viewport notion
was never stale and the frame lever needed no display invalidation —
the killer was the unguarded full-range `textColor` write on every
`updateNSView`, destroying TK2's per-fragment rendering surfaces above
a tail-scrolled pane's viewport (her "two lines at the bottom",
mechanism-exact). Pin B's first hollow version caught and rebuilt on
the record (the R3-4 discipline, self-applied). The 2E false-green trap
fired once more and was caught by the run-line rule — the trap section
earns its keep.

**The memo** (`notes/plans/phase-13d-memo-long-content-panes.md`) is
written per P-5 with the trace as its foundation — four options costed,
recommendation (d) stabilized-status-quo now with (a) the capped card
pre-approvable for 13d; **its §6 rulings are HERS** and join the walk
list. **The `/Applications` refresh RAN at her word** ("go ahead and
install it", 2026-07-27 evening): fresh WAL-safe backup
(`variorum-backup-2026-07-28-012524.sqlite`, `integrity_check` ok),
Release built from HEAD (`7004301`), zero instances at build AND copy,
installed 19:27 local, signature verified. Her daily-drive build now
carries the full A47 family: the phantom fix, the frame law + its
production triggers, and the render heal.

## THE RATIFY WALK — 2026-07-27 evening (author-attended; rulings land here as they come)

Preface from her, before the walk: *"it seems to be working correctly
for now! so I think that it's fine for now"* — the A47c stabilized
build, felt working in real use.

**Batch 1 (the behavior-changers):**
- **#34 — RULED (ii):** backspace at a texted seam MERGES when neither
  block has takes; refuses-and-speaks when either does. Builds in 13d
  (its gate is now open); §14 delta when it ships.
- **#40 — RATIFIED AS SHIPPED:** a named/callout empty block still
  deletes; undo/tray restore it whole.
- **#41 — RULED, her words:** *"it should be done in 13d but wherever
  in 13d is fine"* — carry-to-Write stands until then; no promotion to
  13d's top.
- **#39 — RATIFIED AS SHIPPED, on felt evidence:** the phantom fix
  stays default-ON with its cap/floor and kill switch.

## STAGE 2 CLOSEOUT — 2026-07-27 (the phase's committed scope is DELIVERED; the author's walk remains)

**Final counts, verified by the architect's own runs: core 882/100 ·
Mac 782/134 · mobile 14/4** (from 858/98 · 733/129 · 14/4 at Stage 2
open; from 817/96 · 652/123 · 11/4 at phase open). Zero
`Sources/VariorumCore/Sync/` lines across the whole phase; **zero
schema change** — the mirror stays at lockstep marker 4 and no §12
event occurred.

**What Stage 2 delivered** (batch records above; the K6 review section
holds the findings + fix pass): **1F** the take-card gap's both-sides
convergence law (her live A47 report; birth honestly unidentified, a
recorded unknown) · **2A** Outline as the book's writing surface + the
`Outline · Book · Read` picker + A6's inset removal · **2B** the
editable two-up Book spread with A44's two forms + the
`takesBoardAttached` registry truth · **2C** Read's true two-page
pagination on the (post, page-in-post) identity address +
`Queries.blockExtents` · **2D** the N38 smart→curated conversion
(shape A, PROVISIONAL) + A31's order faces (the dead-door
resurrection) · **2E** Compare's related-blocks-only toggle (the 4C
kin-less-peer PROVISIONAL mooted). The K6 review (ONE Fable round per
her ruling) found 2 MAJOR / 3 MINOR / 3 NIT — all agreed, K1–K5 fixed
by the reviewer and verified by the architect, K6f/K7 record-only.

**THE END-OF-PHASE REFRESH EXECUTED (2026-07-27, 15:04 local):**
`/Applications/Variorum.app` rebuilt Release from HEAD (all work
adjudicated + reviewed), installed at a verified zero-instance window,
*[removed for publication]*
fresh WAL-safe A1 backup (`variorum-backup-2026-07-27-210243.sqlite`,
`integrity_check` ok). No schema change ⇒ no marker concern.

**Open with the author (the handoff's checklist carries these):** the
ratify walk **QUESTIONS #29–#47**; the **field-guide re-seed** (2C
revised the books lesson — one "Restore Tutorial" run from ⌘K, her
confirm required); the 1F birth + K6f/K7 residuals (recorded); and the
next-phase choice (13d per the letter order, or 13f/13g per her K4
ranking — cast at kickoff either way).

## Architect adjudications

### The K6 fix pass — ACCEPTED (2026-07-27); THE REVIEW IS CLOSED

**Verified by my own runs after the last fix: core 882/100 · Mac
782/134, both green.** All six commits present, tree clean, zero
`Sync/` lines, no schema; the K1 core diff read myself — the anchor is
captured from the OLD entries before adoption and the index re-derived
in the new list, with the clamp surviving only as the left-the-book
fallback, exactly the ruled shape; both MAJOR pins revert-red per the
fix record.

**The two flagged deviations, adjudicated:**

1. **K1's BOOK-scoped release (vs the disposition's literal
   spread-scoped call) — ACCEPTED.** The literal form would have
   unmounted the Outline editor mid-typing on every observation
   delivery, because the model serves Outline too; and with identity
   anchoring, the focused post can only leave the SPREAD by leaving the
   BOOK — so the book test IS the spread test, and the pin's
   stale-focus arm proves the intent. A refinement that honors the
   finding's purpose over its letter, correctly flagged rather than
   silently taken.
2. **K2's override-clear on successful conversion — ACCEPTED, not
   scope creep:** at the instant of conversion the frozen order IS the
   stored order (content identical), and keeping a redundant override
   layered over it would diverge confusingly later; it follows the
   "Save as This Book's Order" door's own recorded rule.

**K6f and K7 stand RECORD-ONLY; K8 landed with the round-1 commit.**
Per the K6 "one review" ruling, the review is CLOSED — anything further
is the author's. The end-of-phase `/Applications` refresh executes
next (zero instances verified at this decision; re-checked at the
copy), followed by the closeout.

### Batch 2E — ACCEPTED (2026-07-27); STAGE 2 IS BUILT — the end-of-phase Fable cold review runs next

**Verified before accepting:** Mac **780/135 green by my own run**; core
untouched coherent by construction (zero `Sources/` lines in the
range); tree clean, both commits present; QUESTIONS #47 exists
appended. Zero `Sync/` lines; zero schema.

**Adjudicated:**

1. **The pure pre-pass shape — ACCEPTED, and it is the right one:**
   `segments` byte-unchanged with all eight 4C honesty pins standing is
   exactly how a filter should compose with a hard-won composition —
   nothing re-derived, nothing re-proven.
2. **Mooting the kin-less-peer PROVISIONAL instead of re-ruling the OFF
   placement — ACCEPTED:** she asked for a setting, not a placement
   change; spending a ruling she never made would have been invention.
   4C's alternatives stay live in #47's yes/no.
3. **The live-ring release-not-refuse call — ACCEPTED** on the P-2
   ground (refusing a view toggle because you happen to be typing is
   lecture-and-redirect), with REVERT C proving the flush load-bearing.
4. **#47(c) — default OFF — flagged as the likeliest to flip:** her
   "would make the pane feel more usable" reads plausibly as
   default-ON. One line either way; hers.

**Environment trap ELEVATED from 2E's deviations (binding on every
later session, incl. the review and fix passes):** a filename-shaped
`-only-testing:` argument that matches no TYPE reports
`** TEST SUCCEEDED **` over ZERO tests — swift-testing suites are
addressed by type name, and one file can hold several. **The
`✔ Test run with N tests` line is the only proof a suite ran**; never
accept a SUCCEEDED without it. (The traps section's "confirm the Test
run with N tests line" rule now has its concrete failure mode.)

**Stage 2 counts at build-complete: core 881/100 · Mac 780/135 ·
mobile 14/4.** The K6 review — ONE Fable cold review over the combined
1F + 2A–2E diff (`0ef4d59..` this point), `REVIEW_PROMPT.md` verbatim,
zero framing — runs next; its findings land here repo-first before any
fix session sees them; the refresh and closeout follow it.

### Batch 2D — ACCEPTED (2026-07-27); the dead-door finding matters beyond this batch

**Verified before accepting:** core **881/100** and Mac **772/135**,
both green by my own runs; tree clean, three commits with the core op
in its own commit; QUESTIONS #46 exists appended; the deleted
`ReadingsSection` is genuinely unreferenced (grep: only documentary
comments remain); `convertSmartReadingToCurated` lives in its own core
file. Zero `Sync/` lines; zero schema — the batch confirmed shape A's
zero-schema claim in code rather than trusting the memo, which is the
right posture.

**Adjudicated:**

1. **Shape A as PROVISIONAL — ACCEPTED** per the autonomy grant's
   explicit instruction; the five rulings + A31's two calls are #46,
   each with its alternative stated.
2. **The A31 finding — the shipped app had NO reachable door to change
   a book's order at all** (the machinery shipped Phase 2; its only
   face died unreferenced at Phase 13's IA rework). Fixed by
   relocation into the navigator, dead view deleted. **The CLASS is
   worth the end-of-phase reviewer's attention:** shipped-machinery /
   dead-door is exactly the 9d and capability-matrix family — ladder
   focus 5's "whether a third surface still dead-ends" is adopted, and
   the reviewer should sweep for other Phase-13-IA-orphaned faces.
3. **The named-saved-orders half correctly NOT built** — stored order
   profiles are a §12 lockstep event; the stop-and-report bound held
   (no stop was needed because the sentence she wrote is covered
   without schema; the fuller shape is recorded for her).
4. **The navigator first-character clip — ACCEPTED with approval for
   the pin discipline:** the first pin (on the control's frame) passed
   on pre-fix code and was DISCARDED for a rendered-pixels pin that
   goes red honestly. That is the hallucination guard applied to one's
   own evidence.

### Batch 2C — ACCEPTED (2026-07-27); the addressing insight is the batch's spine, and the field guide re-seed joins the closeout obligations

**Verified before accepting:** core **861/99** and Mac **760/134**, both
green by my own runs; tree clean, four commits with the core query in
its own commit (`211a942` — the model-change convention honored);
QUESTIONS #45 exists appended; **`Queries.blockExtents` read myself** —
the SQL genuinely mirrors `renderPost`'s fallback (chosen requires
live + active + on-this-block, else the live default; `(position, id)`
sort; the Phase 5 injection discipline; bounded-window chunking), and
its doc comment says why `renderedLength`'s looser COALESCE was NOT
reused. Zero `Sync/` lines; no schema.

**Adjudicated:**

1. **The (post, page-in-post) address rule — ACCEPTED, and it is the
   batch's best reasoning:** with a page-number address the two tiers
   cannot coexist (an estimate correction reflows the page under her);
   with the pair address a measurement moves the LABEL, never the
   content. Judgment call 1 (every post starts a new page — against the
   brief's lean) follows from it and is honestly filed as #45(b), the
   first push-back candidate.
2. **The lazy-slicing correction — ACCEPTED with approval:** the first
   build paginated whole posts on arrival; the batch's own cost test
   caught the 1.67 s single-giant-block shape (her A3/A41 terrain) and
   the fix bounds slicing by pages actually walked. The ~30 ms deep-turn
   residual inside a 25k-word single block is recorded, not hidden.
3. **#45(c) — the scrubber staying on Read while 2B removed it on
   Book — ACCEPTED as flagged:** the two surfaces now show her BOTH
   answers to the #44(c) family question, which is the both-ways-testing
   method she herself has asked for on open items. Her one ruling can
   unify them.
4. **The red-on-old table correction (`f0cdb38`) — noted with
   approval:** executing the reverts corrected two RED numbers written
   from reasoning; the correction is its own commit rather than a quiet
   amendment.

**CLOSEOUT OBLIGATION RECORDED (do not lose):** 2C edited the field
guide's books lesson (stale since 2A's rename, repaired + a new walk
act). Per the standing rule, **lesson content edits stale the REAL
store's seeded field guide — the phase closeout must re-seed it via the
product door behind the A1 rail.**

### Batch 2B — ACCEPTED (2026-07-27); #44(c) is a genuine push-back candidate on her walk

**Verified before accepting:** Mac **745/131 green by my own run**; core
untouched coherent by construction (zero `Sources/` lines in the stat);
tree clean, both commits present; QUESTIONS #44 exists appended;
**the `TutorialWalkTests` edit read in full** — legitimate adaptation of
the paged vocabulary to the spread (equivalent-or-stronger assertions,
including a new blank-leaf honesty check), not a weakened step; the
registry diff read — `takeFamily` now reads
`writeEditorAttached || takesBoardAttached`, the proxy retired for the
truth it stood for, the `writeEditorAttached` shape reused.

**The judgment calls, adjudicated:**

1. **One active editable page at a time (#44(b)) — ACCEPTED as
   PROVISIONAL.** Two mounted boards would mean two `PaneTextAuthority`
   values and two LIFO-racing routed handlers — the trace is concrete,
   and the shipped shape (sibling read-cheap, ring migrates on click) is
   the app-wide P3 pattern applied consistently. The
   both-pages-live alternative is honestly named as a bigger build.
2. **The `takesBoardAttached` registry condition — ACCEPTED**, and it is
   the batch's best work: `mode == .takes` was a proxy that silently
   broke the moment a board mounted outside a post detail, and the fix
   reports the actual attachment (RED-verified). The named consequence
   (structural gestures read `.unavailable` in the takes form rather
   than `.actElsewhere(.write)` — the #41 family) rides the end-of-phase
   review's foci.
3. **The removed jump slider (#44(c)) — ACCEPTED as flagged, and I lean
   HER WAY on the walk:** her Outline rationale ("a horizontal scrollbar
   on a vertical page") does not apply to a horizontal pager, and
   S4-9(2)'s Kindle-style ask arguably wants a scrubber here. The batch
   was right to flag rather than bury; restoring it is one control if
   she rules so.
4. **The density-pill clipping in half-width containers** — pre-existing
   chrome, correctly routed to the Design & UI review row rather than
   fixed mid-batch.

**Environment note carried:** the Mac runner ran normally under a
locked-reading login session (probed with a control suite first) —
contradicts Stage 4 lesson 9's prediction; recorded in the batch record
so the lesson gains its exception rather than silently drifting.

### Batch 2A — ACCEPTED (2026-07-27); the R106 flip is the ratify walk's first stop

**Verified before accepting:** Mac **741/130 green by my own run**; core
unchanged coherent by construction (`git show --stat`: zero `Sources/`
lines); working tree clean, both commits present; **zero stale
`ViewMode` references** (the both-cases rename did its job — grep
confirms no `.book`/`.pages` enum use survives); the 2A touches to
`PaneSurface.swift` and `EditorTextView.swift` read in full — both are
the `inlineSurfaceInset` named-constant extraction only, and **1F's
convergence logic is untouched**.

**The judgment calls, adjudicated:**

1. **Posts-open-by-default (the R106 reversal for this surface) —
   ACCEPTED as PROVISIONAL, and it is the right call on her own words.**
   R106 ruled a *navigation* surface; A39 makes Outline a *writing*
   surface, and "literally looks like write mode… posts are collapsible"
   cannot mean content hidden by default — you cannot write in what you
   cannot see. The card survives as the collapsed form and collapse-all
   is one click. **QUESTIONS #43(a) is the first stop on her next
   ratify walk**, flagged as a reversal rather than smuggled.
2. **The "already true" architectural finding — ACCEPTED, with the
   review asked to re-derive it.** The batch argues Outline's editable
   surface IS the one full-document editor under `BookViewModel`'s
   single focus authority (13b 3E's fold), so adding a parallel
   authority would itself have violated P-3 — and it pinned both halves
   (the one-ring inheritance; `commitTake` via `writeEditorAttached`)
   instead of writing ceremony code. That reasoning is sound and the
   restraint is correct; because it is a *claim about existing
   machinery*, the end-of-phase Fable reviewer is explicitly asked to
   re-derive it cold rather than inherit it (it is in the batch's
   ladder foci).
3. **The A6 removal taking the per-row visibility reporting with it —
   ACCEPTED** (work per realized row for a face that is not drawn); the
   scrub/progress brains stay pure and pinned for 2B/2C, and her
   "investigate the bugginess first if ever re-added" is carried in
   code.

**Worth naming:** the DEBUG materialization counter becoming
load-bearing (452 → bounded realizations on a 150-post book) is exactly
the Phase 13 round-3 lesson applied *before* a reviewer had to find it.

### Batch 1F — ACCEPTED (2026-07-27); the persistence fix stands, the birth rides the end-of-phase review

**Verified before accepting:** the diff read in full (one hook + one
coordinator method on the ONE surface component — P-3 held; every write
still leaves through the publish door, so the F1 walk's ground is
untouched); Mac **734/129 green by my own run**; core untouched is
coherent by construction (`git show --stat`: zero `Sources/` lines).

**The two judgment calls, adjudicated:**

1. **Fixing the persistence without the birth — ACCEPTED.** The
   persistence mechanism is fully traced (the change-gated trigger
   enumeration + the heal's short-side-only chase + her live "isn't
   going away" as the observable), the fix neutralizes every birth
   candidate equally, and the hunt was honest (two harness drives, a
   quantified candidate table, the ~470 pt transient named as the
   suspect that would not reproduce). Continuing to hunt while she
   lives with a recurring launch-adjacent void was the wrong trade.
   **The birth stays OPEN as a named ladder focus** — the end-of-phase
   Fable reviewer is explicitly asked to try to drive it (the
   first-render-width suspect) and to try to break the termination
   argument.
2. **The stand-in pin — ACCEPTED as labelled.** It reproduces the stale
   STATE (frame tall, text short, no trigger left), not the birth, and
   says so in its own doc comment — the 1E characterization-honesty
   discipline applied to a defect whose trigger is unknown. The RED it
   observed (546.0 held over 293.0 across settle passes) is the class,
   demonstrated.

**Worth naming as the batch's best work:** the harness-gap finding —
`TakesBoardSoakTests`' height invariant was one-directional AND
live-pane-blind, so this entire defect class passed every soak *by
construction*. The widened both-sides invariant is the structural fix
for the class's invisibility, which outlives this instance (P-7's
letter: the soak could not find this bug before she did, and now it
can).

**Also noted:** the passive-only interrogation of her live instance
(screencapture + `mode=ro`/`immutable=1` queries, AX injection
declined) is exactly the instance discipline the environment traps
demand, applied under pressure. Her on-screen card heals at its first
layout pass once the end-of-phase refresh lands the fixed build.

### Batch 1E — ACCEPTED, and it made me reverse my own bound (2026-07-26)

**The build landed with a trigger policy better than the brief asked
for.** Cap 64,000 UTF-16 units (≈11,600 words in ONE block), derived from
1C's table on the axis the code can check for free —
`BlockRangeIndex.Entry.length`, because *counting words would read text
on every scroll, which is the exact P1 mistake* — budgeted at half a
60 Hz frame in DEBUG, predicted worst case 7.5 ms, roughly 4× of room
against my "20 ms is past a frame budget." **The derivation is itself
pinned so the constant cannot outrun its evidence** — that is better than
a well-chosen number; it is a number that stays honest.

**A FLOOR beyond the brief (2,000 units), and it was the right call to
make unprompted:** an ordinary post now performs **zero** layout calls,
ever. Reverting it makes a post of 27-character blocks lay blocks out one
per pass. I had not specified it; the batch exercised judgment in the
correct direction.

Also measured and worth keeping: **my nudge guess was wrong.** A *display*
pass does nothing (9,063 pt before and after); the lever is **layout**
(9,063 → 8,533). It cannot loop — only the height changes, so no width
reflow fires, and re-entry finds the block `handled`.

> **ARCHITECT REVERSAL — the width-reflow fork, TAKEN, with a gate.**
> The batch found that *"TK2 does not discard the layout"* — a premise
> **I** put in its brief from 1C's finding — **holds for scroll travel
> but NOT for a width reflow**: a laid-out 3,000-word block returns to an
> **11,492 pt guess** at a narrower column, *worse than it started*.
> Honouring "once per session" literally therefore means the phantom
> **returns after her first sidebar toggle or window resize and is never
> corrected again.**
>
> **I reversed my own bound, and the reasoning matters more than the
> outcome:** "at most once per block per session" was written before
> anyone knew a width reflow discards layout, and its purpose was never
> the word *session* — it was to prevent the same work being redone
> wastefully, which is the failure mode that would make this a P1
> violation. Re-laying out a block whose layout TK2 has genuinely thrown
> away is not waste; it is the same bounded work for a new state. **New
> information changed the reasoning; the principle is intact.** The cost
> of NOT taking it is worse: we would ship a fix that silently stops
> working, and she would report the same bug twice — which P-5 exists to
> prevent.
>
> **The hard requirement attached:** re-eligibility once per **settled**
> width, never per width *sample* — a divider drag produces a continuous
> stream of widths, and per-sample re-eligibility would run layout
> repeatedly mid-drag, the precise P1 problem the trigger policy exists
> to prevent. **The drag case is pinned specifically**, because it is the
> thing actually worth worrying about.
>
> **The batch was right to stop at my bound rather than widen it on its
> own, and right to record it as a fork.** That is the shape this process
> wants.

**Verification honesty noted approvingly:** end-to-end pins are declared
**characterization** in the file header rather than dressed as red-on-old
(correct — this is a new capability), while every *guard* is genuinely
red-on-old by behavioral revert, run both ways and restored to a verified
checksum. And **two counterfactuals did not fire on the first attempt and
the record says so** (R6's fabricated scroll view was not the real
counterfactual; R7 needed *both* reach bounds removed because at that
distance they cover for each other). A batch that reports its own
counterfactuals being wrong is one whose green results mean something.

### The 1E width fix pass — ACCEPTED; STAGE 1 IS COMPLETE (2026-07-26)

`handled` becomes `[blockID: containerWidth]`; a block is eligible again
only at a width it has not been handled at. **Why it does not widen the
trigger**, in the order that matters: TK2's own `laidOut` check gates
every candidate, so a width change that *didn't* discard layout costs
nothing — **re-eligibility only permits work; TK2's state decides whether
any is needed**. One pass per **settled** width, reusing the existing
scroll-settle debounce rather than adding a second timer — **pinned: 14
width samples ⇒ 1 layout; with the gate bypassed, 16 passes.** And the
nudge cannot manufacture eligibility, because it changes only height
while re-eligibility is signalled on width alone — *the one event that
grants re-eligibility is exactly the one the fix cannot cause.*

**Two reports that are the reason to trust the rest:**

1. **A pin's red stopped reproducing, and it said so instead of keeping
   it.** Under the width contract, TK2's own `layoutAvailable` state
   covers that ground, so removing the `handled` write no longer failed
   the test whose name claimed it. The claim moved to where `handled` **is**
   provably load-bearing (an over-cap block must vanish from the scan's
   answer entirely, not merely stop being re-recorded), and **the test
   file's header says this in as many words.** A pin whose named guard no
   longer earns it is worse than no pin, because it reads as proof.
2. **The drag pin flaked, and the cause was real** — a width reflow also
   fires the overlay layout-settle hop by design, a second legitimate
   trigger whose async hop can land after the first pass under load. It
   now asserts the exact thing it can (`layoutsRun == 1`) plus a decisive
   bound (`passesRun ≤ 4` against the bypassed 16). **"Over-tight would
   have meant a flaky pin, which is worse than a slightly looser true
   one"** — correct, and the reasoning is recorded rather than the number
   quietly relaxed.

**All eight reverts were re-run against the SHIPPED tree** rather than
relying on pre-ruling evidence — the guard code had moved under them, so
the old evidence would not have counted. Each restored to a verified
checksum.

**Stage 1 counts: core 848/98 · Mac 719/129 · mobile 14/4** (from
817/96 · 652/123 · 11/4 at phase open).

### Batch 1D — ACCEPTED, with one architect-directed addendum (2026-07-26)

**A1's diagnosis was confirmed IN HER REAL STORE, read-only, which turns
my trace into a fact:** her 2026-07-11 entry was created **17 seconds
after** the `bridge_day.last_remote_stamp` of the Fragments row it landed
from, and carries **no `reading_post` row at all** — not live, not
tombstoned. 2026-07-16 is identical. Her designation was healthy the
whole time (`Journal`, curated, pinned, unlocked), so the only missing
piece really was the second half of the ⌘J door.

**The fix's three rules are well-shaped and I want rule 2 on the record
as the good one:** *any membership row, live OR tombstoned, means the
pair is already decided.* That is what stops the bridge from re-shelving
a post she deliberately removed from the book — the obvious objection to
shelving on every write — and it is simultaneously what makes the fix a
**repair** for her two existing orphans, which have no row of any kind.
One rule, both jobs, no special case.

**A2 — the answer was the sign-out, AND the hole is structural.** The
batch confirmed the dominant cause (signed out ⇒ `connectSyncIfAllowed`
never runs ⇒ no scheduler ⇒ `onRoundCompleted` never fires ⇒ **the bridge
ran exactly once per launch for five days**, with her Fragments session
valid throughout — and her `bridge_day` rows stop at 2026-07-21,
consistent). **It did not stop at "it was the sign-out."** The same
starvation returns on any expired Variorum session and on a failed owner
adoption, and the 9b plan documents a cadence the code does not deliver
in that state. Fixed at the lifecycle trigger, throttle untouched —
correct, since the latency she felt was five days, not sixty seconds.
The stale "Bridged 11:04 PM" label (a five-day-old round looking fresh —
9b's MINOR-4 class) now carries the date.

**PROVISIONAL #37 ACCEPTED** (no designated book ⇒ land, skip, say why):
its reasoning is the one I would have made — the Mac door creates and
pins a book *because she pressed a button*, and a headless overnight
round minting one is a materially larger act.

**#38 CORRECTLY LEFT TO HER** (a periodic poll): nothing pulls Fragments
while she sits in Variorum without typing or switching apps, and a timer
would fix that — but every bridge round hash-sweeps every live journal
day, so putting that on a clock is a **posture change stacked on the P1
relaxation she ratified at 9b**. Not ours to make.

> **ARCHITECT-DIRECTED ADDENDUM — the mobile door.** The batch flagged
> that `EntryListViewModel.swift:94` has the **identical missing half**:
> a phone-minted entry also arrives bookless. I sent it back to be fixed
> in the same session rather than deferred. **Reasoning:** it is the same
> class, adjacent and now known, and the skill's class-completeness rule
> says a recurring class gets swept, not audited later — leaving a known
> instance is the "green by audit" pattern P-1 exists to kill. I also
> judge the stated mitigations weaker than they look: A1's rule 3 fires
> on a landing that *writes* a day, but a phone-minted entry she never
> touches in Fragments produces no landing at all — only a
> Variorum→Fragments push — so it stays bookless until she happens to
> open ⌘J on that exact day. The addendum closes the mobile suite gap the
> batch honestly flagged (it had not run it).

**Ladder foci adopted:** the duplicate-day landing (shelving follows
`canonicalJournalEntry` while push is paused), and whether "any
membership row means decided" has a `restoreContainer`/`restoreReading`
interaction worth stating.

**The addendum ACCEPTED, and it did better than directed.** It agreed
the push-back was right and put the correction on the record in the
terms it was wrong in — *"nothing repaired it; it stayed bookless until
she happened to open ⌘J on that exact date."* Then, rather than adding a
second call site, it **hoisted the rules into
`Operations.shelveInDailyJournalBook(_:)`** beside `createOrOpenJournalEntry`,
where it **never throws** and returns what happened for each surface to
word. That is the better shape and worth naming: it makes "never block
the mint or the landing" **structural rather than a convention each
caller has to remember** — the same reasoning as P-1's, applied one layer
down. The bridge's private copy is gone.

**The class sweep is complete and bounded** (every `createOrOpenJournalEntry`
call site in the tree, verdicted): ⌘J/Today's Entry — already shelved,
**deliberately NOT converted** because it also *creates and pins* the
book, which is the act only her button press may take (#37's line held
exactly); the bridge landing — new; phone capture — new; the daily
branch of `BookStructureModel.newEntry` — unchanged. **Mobile 11/4 →
14/4, RUN** on simulator, closing the gap it had honestly flagged.

**One judgment call routed, not built:** the phone's note rides
`lastError`, the capture list's only message surface, so "your entry
isn't in a book yet" renders in the same red caption as a real failure.
It is precedent rather than invention (that surface already carries
human-worded non-crash notes), but a note-vs-error distinction on mobile
is **new UI in a fix pass** — correctly recorded for the Design & UI
review row instead of invented at 3 a.m. **Counts after: core 848/98 ·
Mac 700/127 · mobile 14/4.**

### Batch 1C — ACCEPTED, and it unlocks a build decision (2026-07-26)

**A46 does not exist, and the batch was right not to fix something.**
Traced empirically with **real mouse events into a mounted window**, not
by reading code: the phantom space below the last line **is** the
editor's own text view, the click **reaches** it, and the caret **does
move — to the document end**. It cannot land *inside* the phantom because
there is no text there. That is her own sentence confirmed by
measurement (*"nothing was actually there"*), and it is correct text-view
behaviour over space that is not text — the same verdict the brief
already granted the down-arrow half.

Five candidate mechanisms were traced and refuted (overlay eating the
hit; clip parked past a shrunk document — overshoot measured 0.0; a huge
last block; a mid-document gap — none > 12 pt on screen; gutters/insets).
**Recorded so nobody re-walks them.**

**I want the restraint on the record, because it is the harder call:**
there *was* something dead to fix — a constant 6.0 pt strip at the
scroll view's bottom — and the batch proved it is **AppKit's own**
(reproduced with a vanilla `NSTextView` in a vanilla `NSScrollView`, no
Variorum code) and left it alone, pinned at ≤ 8 pt so the class speaks if
it ever grows. Fixing that and declaring A46 addressed would have closed
her item with a fix that could not have caused her report. **The
hallucination guard exists for exactly this, and it held.**

**Consequence, stated plainly and unwelcome: removing the phantom is now
the ONLY remedy for what she experienced.** There is no cheaper
independent fix hiding behind it.

**Option E measured — and it is ALIVE, better than my arithmetic:**

| block | cost | phantom removed | per 1k words |
|---|---|---|---|
| 1,000 w | 1.27 ms | 180 pt | 1.27 ms |
| 3,000 w | 2.90 ms | 537 pt | 0.97 ms |
| 12,000 w | 11.52 ms | 2,169 pt | 0.96 ms |
| 25,000 w | 20.06 ms | 4,549 pt | 0.80 ms |

Per-word cost is **flat-to-improving in block size** — the shape P1
demands — against Phase 6's whole-document rate of 2.1 ms/1k. I estimated
~6 ms for 3,000 words; measured **2.90**. And the open worry resolved
favourably: **TK2 does not discard the layout**, so E is once per block
per session, not a treadmill.

> **ARCHITECT DECISION — build E, PROVISIONAL, with a cap (batch 1E).**
> Reasoning, since this is the closest call of the phase so far. Her
> directive was *"once you've found the source of the issue, please fix
> it"*; the source is found and the only remedy is measured and cheap at
> real block sizes. **Is E a P1 relaxation (author-only) or within P1?**
> I judge it **within P1's letter** — P1 binds cost to *"what's on screen
> and what's being edited"*, and laying out the block the viewport is
> looking at is exactly that; it is document-scale layout that P1 bans,
> and E is explicitly not that. **The honest risk is not the cost, it is
> the TRIGGER** — a once-per-block 3 ms becomes a real problem if
> something makes it run repeatedly. So the build carries: a hard block-
> size cap (skip and record above it), a pin that it runs **at most once
> per block per session**, and a kill switch. **Q3 stays on her ratify
> list regardless** — she can turn it off having felt it, which is a
> better position to rule from than a table of numbers.

**Judgment calls accepted:** the characterization pins carry **no
red-on-old and the batch said so explicitly** rather than leaving it
blank — correct, since nothing was fixed; and E's measurement ships as a
suite test rather than a `Spikes/` binary, which I am happy with (it
re-measures on every run, so the numbers cannot silently rot).

**Ladder focus adopted from its suggestion:** whether "not reproduced in
the surface she named" equals "does not exist" — specifically whether a
`PaneSurface` pane in Takes/Lenses/Compare, a read-tier post, or a canvas
card could present phantom space whose click does not reach a text view.
Added to the ladder's foci.

### Batch 1B — ACCEPTED after verification, plus a product finding for her (2026-07-26)

**Verified before accepting** (prompted by a stale-index diagnostic that
appeared to contradict the report — worth doing precisely because it
looked like a contradiction): the tree compiles clean; `register` takes
`redo:` as a **required, non-defaulted** parameter; the flagged call
sites do pass it; and there are **zero `redo: nil` holes** anywhere in
core or the app. The totality claim holds. Core **836/97 confirmed by my
own run.**

**Design note worth keeping:** making `redo` *required but optional-typed*
is the right shape — a future registration site must explicitly decide
and pass `nil` rather than silently omitting a re-apply. That is P-1's
"green by construction" reasoning applied to the undo layer.

**The batch's own corrected assumption is the most valuable thing in it.**
It wrote a pin asserting that a bare seam-backspace between two *texted*
blocks still merges, on the strength of the ratified "a cross-seam delete
just works." **The pin failed, and the pin was wrong — not the code.**
That 2026-07-09 ruling covers a *selection spanning text*; a bare
separator intersects neither neighbour, so both cross-block plans have
always returned nil and the keystroke has always refused. Good
self-correction: the implementer believed the doc, tested it, and
reported that the doc's scope was narrower than it read.

> **FINDING F3 — a product call for her, NOT taken (author-only).**
> The corrected assumption exposes a live gap: **backspace at a seam
> between two blocks that both have text does nothing today.** In every
> ordinary editor that keystroke joins the two paragraphs. This invokes
> her own stated principle *verbatim* (2026-07-09, AppSpec §14): *"there
> is no other writing editor where you can select a bunch of text, hit
> delete, and it doesn't delete… if your text looks like basic text with
> no variants, it should behave like basic text."* A7's carve deliberately
> covers only the EMPTY-block case, which is right for this batch — but
> the texted case is the same principle one step further, and merge
> already exists as the operation it would call. **Options for her:**
> (i) leave it — merge stays an explicit named gesture, and a silent
> structural merge from a keystroke is a big implicit act; (ii) backspace
> at a seam merges when **neither** block has takes (basic text behaves
> like basic text) and refuses-and-speaks when either does; (iii) as (ii)
> but always, with the fan consequence spoken. **Not built. Logged as
> QUESTIONS #34.**

**The five bundled PROVISIONALs (QUESTIONS #33) — all adjudicated
DEFENSIBLE against the spec, and all still hers to ratify:** (a) the
delete door is not restricted to empty blocks — `deleteBlock` has always
been general, and inventing a restriction would be inventing product
behavior; (b) deleting a post's last block is allowed — no invariant
makes block count load-bearing (I10 governs a block's *variants*, not a
post's blocks), the blockless post is the modelled fresh-post state, and
the editor already handles it; (c) **the archive half deliberately NOT
built** — `block.archived_at` has sat in schema v1 since Phase 1 with no
operation, query, or face, so building it means deciding what an archived
block *means*, which is hers. **This is the correct call and the right
kind of restraint**; (d) the both-empty tie-break resolves to the block
before the seam — arbitrary but recorded and pinned; (e) redo is ⇧⌥⌘Z,
never sharing ⌘⇧Z with text redo — consistent with structural undo's
⌥⌘Z and with the never-interleave rule.

**Recorded, not actioned:** redo's insurance asymmetry — a source block
edited between undo and redo is re-released with its edit intact but
uncommitted. This is **the same asymmetry undo already has**, not a new
one, and the batch recorded it deliberately rather than inventing a
sixth auto-commit occasion (which would be product behavior). Correct
restraint; flagged for the ladder.

### Batch 1A — ACCEPTED, with one option added to the memo (2026-07-25)

**The hypothesis died, and the record says so plainly.** My recorded
mechanism — `PanePublisher`'s one-directional heal leaving an over-large
height uncorrected — was **REFUTED on four independent grounds**, and one
of them is that it was false on its own terms: `runTurn()` re-measures
and writes **unconditionally** (`PaneSurface.swift:172`); the directional
check gates only whether another turn is *scheduled*. I read that path
too quickly when I traced it. The confirm-first instruction caught it
before it became a fix, which is the entire reason that instruction
exists — **the batch spent its first effort killing the architect's
hypothesis, and that was the correct outcome, not a detour.**

**Verified myself before accepting** (verify-don't-trust):

- **Judgment call 4 — the pin edit — ACCEPTED.** The concerning shape
  would have been an assertion deleted to make a fix pass. It is not
  that: the old assertion compared the decoration span to the *fragment*
  bounds while its own prose said "the text's view-space bottom", so it
  was **encoding the defect**; it survives in corrected form
  (`first.frame.minY`), and the replacement set is strictly stronger —
  the trailing-gap rule, the last-paragraph identity, the unlaid-fragment
  degradation ("never worse than pre-fix"), the frame clamp, R17's white
  gap now genuinely enforced, and — the best of them —
  `swallowedGapsLeaveNoWhiteAtAll`, which pins **her exact reported
  mechanism** so it cannot return unnoticed.
- **Scope confirmed:** zero `Sources/VariorumCore/` lines changed, so
  core's 817/96 standing untouched is coherent. Mac 652/123 → **668/125**.

**Findings I am escalating rather than burying:**

1. **R17's white-gap rule has been DEAD CODE since it shipped.** A
   ratified design rule that never took effect, because it was always
   handed a gap of 0 and always returned 0 pad. This is a canon-vs-
   shipped discrepancy, not a bug in the ordinary sense, and it is now
   pinned by a test that fails without it.
2. **Two compensating errors hid a real defect through an entire phase.**
   `JumpPrimitive` and the anchor path carried the *identical*
   container-point/view-point confusion, so the Phase 7 smoke pin passed
   **for the wrong reason**. Both are corrected and that pin now passes
   untouched. Worth remembering as a class: a green pin proves agreement,
   not correctness.
3. **A3/A41 is a TextKit 2 platform limitation, not our bug** —
   measured with Apple's own `NSTextLayoutFragment.state`: 4,964 pt while
   estimated vs 4,597 pt once laid out. **This is AppSpec §15 risk 2
   biting in daily use for the first time**, exactly where TEXTKIT2 §2
   said it would.

**My one substantive disagreement with the batch — recorded as an
addition, not an override.** The memo folded "lay out just the one long
block" into option B ("lay out the document in the background") and
recommended against the pair. Those costs are not the same: B is work
∝ document size and breaches P1; laying out **one block's own text
range** is work ∝ one block, which is what P1 actually permits, and the
Phase 6 spike's measured rate puts a 3,000-word block around 6 ms.
**Added to the memo as option E**, with its honest caveats stated (it
fixes the block you are near, not phantom contributed further down; a
gigantic single block is the "virtualize inside a post" escape-hatch case
and wants a measured ceiling; and it is **not to be built on arithmetic
— it gets measured, and dropped if the number disagrees**). The
recommendation now reads *A now, with E measured as the real candidate.*

**Deferred to her, not decided:** the memo's five questions (Q3's posture
and Q4's clickability reading chief among them), and the jump-landing
taste call — fixing the conversion means jumps land flush at the viewport
top instead of 24 pt below it; flush is the documented contract and the
24 pt was an accident, so it was not preserved, but whether a jump wants
top air is taste and goes to the Design & UI review row.

**Recorded, not actioned:** a pre-existing `Sendable` warning at
`PaneSurface.swift:117` (13b code, untouched by this batch).

## Batch records

*(appended per batch, the 13b form: commits, counts before → after,
traced mechanisms, numbered judgment calls/PROVISIONALs, red-on-old
evidence, deviations with reasons, ladder foci)*

### Batch 1A — the vertical-space investigation (A3 + A4 + A41 · A40 · F1)

**Commits:** `01e2602` (the three geometry mis-mappings + pins) ·
`b77686e` (F1, the enforced publish door) · this record.
**Counts:** Mac **652/123 → 668/125** · core **817/96 → 817/96**
(unchanged — see judgment call 5) · mobile 11/4 untouched.
**Diff scope:** 8 files, all under `App/Variorum/`. **Zero lines of
`Sources/VariorumCore/` changed** (`git diff --name-only … -- Sources/`
returns nothing).

#### THE HEADLINE: the recorded hypothesis is DEAD as to mechanism, and its symptom prediction was right

The batch was told to confirm or refute the recorded hypothesis with a
pin BEFORE fixing anything. Doing that first is what made the rest of the
batch cheap, and it is worth stating both halves plainly.

**REFUTED — `PanePublisher`'s one-directional convergence heal is NOT the
site,** on four independent grounds:

1. **Wrong surface.** She reports this in the Write editor, which is
   `EditorSurface` — a TK2 text view inside an `NSScrollView` with
   `isVerticallyResizable = true`. It sizes ITSELF from TK2 geometry.
   `PanePublisher` is not in that path at all.
2. **No over-report to correct.** A mounted pane's measured height equals
   its true text extent EXACTLY (measured: 1134 vs 1134; and on the read
   tier, `measured − (lastFragmentMaxY + 2·inset) = 0.0`). Every pane
   measures through `PaneMeasurement`, which calls
   `ensureLayout(documentRange)` first — pane-scale by construction, so a
   pane never sees an estimate.
3. **The measurement is not sticky downward.** `usageBoundsForTextContainer`
   shrinks correctly (1134 → 29 → 1134 across a shrink/regrow).
4. **The claim is false on its own terms.** `runTurn()` re-measures and
   writes UNCONDITIONALLY (`PaneSurface.swift:172`); the directional check
   at :177 gates only whether to schedule ANOTHER turn. An over-large
   measurement is in fact the case that keeps the heal running (rendered
   stays below measured), so it gets MORE correction attempts, not fewer.

**CONFIRMED — the symptom it predicted is real, reproduced, and
quantified**, with the true mechanism traced elsewhere (Part 2 below).
A wrong hypothesis, killed cheaply, that still pointed at the right
class: recorded as the good outcome it is.

#### What each report actually was

| Her report | Verdict | Where it went |
|---|---|---|
| **A40** callout colour "spreads underneath it" | **BUG — mis-mapping**, 2 hosts | Fixed, revert-verified |
| **A4** editor jumps on a block taller than the screen | **TWO BUGS** — fragment granularity + a container/view conversion | Fixed, revert-verified |
| **A3 + A41** phantom empty space that vanishes on scroll | **NOT OUR BUG.** TK2's documented height estimate; no public API to correct it; the only cure is P1-banned | **C3 memo** — `notes/plans/phase-13c-memo-block-extent.md` |
| **F1** publish door green by audit, not construction | Hardening (her ruling) | Enforced by a name-independent walk |

#### Traced mechanism 1 — A40, the decoration frame (FIXED)

TK2 folds a paragraph's **trailing gap** into `layoutFragmentFrame`.
Measured, Terminal voice: a one-line paragraph is **17 pt of text inside
a 24 pt frame**; with inline comments on, 17 pt inside **46 pt**. Both
decoration hosts built a block's frame from fragment frames, so:

- every block frame claimed a gap belonging to NEITHER neighbour;
- consecutive frames **abutted — measured gap 0.0** at every boundary;
- the callout wash ran 7 pt under the text and touched the next block
  (her words);
- **R17's BINDING white-gap rule was unreachable** — `verticalPad` always
  received gap 0, so it could only ever return 0 pad, while the frame it
  was padding was already a whole gap too tall. The rule has been dead
  code since it shipped;
- `seamYs` put the dotted seam on the next block's first line rather than
  centred in the white (off by gap/2 — 3.5 pt Terminal, 14.5 pt with
  inline comments).

Fixed at ONE new pure mapping, `BlockDecor.textBottom` / `textRect`,
consulted by both hosts (`EditorViewModel.refreshDecorations` and
`ReadPostViewModel.refreshDecor` — a class sweep: same defect, two hosts,
both fixed, no third host exists — `BlockTint.viewRect`'s only two callers
are exactly these). An unlaid fragment reports no line fragments and
degrades to its frame: the pre-fix value, never worse.

**Recorded for the reviewer:** `everyDecorFrameRegistersWithItsBlocksText`
has asserted the FRAGMENT bottom since Phase 13 C1 while its own prose
said *"the text's view-space bottom"* — **the pin was holding the defect
in place.** Its ground truth is now the last LINE's typographic bottom,
and it gained real-gap + seam-inside-the-white assertions. Changing a
test to match a fix is normally the forbidden move; it is defensible here
precisely because the test's stated contract and its assertion disagreed,
and the fix makes the assertion match the prose.

#### Traced mechanism 2 — A4, the scroll anchor (TWO BUGS, FIXED)

The anchor is `topVisibleOffset()` (read on scroll) →
`restoreTopVisibleOffset()` (replayed on every width reflow: sidebar
toggle, split divider, window resize, live-resize end). It is the Phase 6
memo's standing obligation — *never px-anchor across reflow, restore by
text location*.

**(1) Fragment granularity.** A block is always its own paragraph
(R26/R33); a paragraph is ONE layout fragment. So a block taller than the
viewport collapsed every reading position inside it to the block's start.
Reproduced: scrolled to y=2500 inside a **6,127 pt** block (360 line
fragments), the anchor answered **813** — the block's first character —
and the restore landed at **y=225**. A **2,251 pt leap backwards**, every
time she resizes anything. Both halves now resolve to the LINE through
one pure helper, `FragmentLines`.

**(2) Coordinate space.** `textLayoutFragment(for:)` takes a
TEXT-CONTAINER point — measured against ground truth, not assumed
(`refreshDecorations` already converted; this site did not). Passing a
VIEW point made the anchor name the block BELOW the one at the viewport
top at every stop: **entry 8 for 7, entry 20 for 19.** Same container↔view
class as the Phase 10 mis-registration, one site over.

**Why nothing had ever caught (2):** `JumpPrimitive` carried the
IDENTICAL error in the same direction — it steered a VIEW-space scroll
offset by a CONTAINER-space fragment minY. **The two errors cancelled on
the round trip**, and the Phase 7 smoke pin
(`tenThousandWordPostStaysSnappyAndAnchored`) passed for the wrong
reason. Both are converted now, so read-then-restore is exact by
construction rather than by two errors agreeing — and **that Phase 7 pin
passes UNTOUCHED**, which is the strongest available evidence that the
new pair is right.

#### Traced mechanism 3 — A3 + A41, the phantom gap (NOT A PATCH → C3 memo)

Her diagnostic held: a paste of a three-paragraph message stores a
trailing newline on the first two blocks and **none on the last**, so
"no whitespace at the end" is literally true and stored content is
eliminated.

What it is: TK2 **guesses** the height of paragraphs it has not laid out,
and a Variorum block is one paragraph — so one very long block is one
very large guess. Measured on 60 blocks with one 3,000-word block:

| | long block | document total |
|---|---|---|
| at the top (`state == .estimatedUsageBounds`) | **4,964 pt** | 11,245 pt |
| after scrolling onto it (`state == .layoutAvailable`) | **4,597 pt** | 10,885 pt |

**367 pt of text that does not exist** (~21 blank lines), vanishing on
scroll. Apple's own documented `NSTextLayoutFragment.state` names the
transition. Controls: the same post with NO giant block wanders only
84 pt and **upward** (the benign converging direction the Phase 6 spike
measured); a giant block sitting ALONE at the top wanders **0 pt** (it is
laid out immediately, never guessed).

**Why it is not a patch:** an external-facts lookup confirmed there is
**no public API to supply or correct estimated fragment heights** (Apple
docs + the STTextView maintainer), and Apple DTS states that fluctuating
estimated heights are expected and by design. The only cure —
full-document layout — is banned by P1 and measured at 105 ms @ 50k words
/ 408 ms @ 200k in the Phase 6 spike. Per the brief's step 2 this is
**not a number to guess into the code**: it is the C3 memo, which puts
four postures to her with recommendations.

#### F1 — the publish door, ENFORCED

Chose the **walk**, not the type-level shape, and the reason matters:
`install` taking one `PanePublisher.Writes` value channels only the two
publishes that exist today and would not stop a fourth closure being
added beside them — so it does not close the hole F1 names. The walk is
**name-independent by construction**: it reads the surface's own
`@Binding` declarations out of the source and requires every write to
each to sit lexically inside the `install(…)` call, so a binding added
tomorrow is covered with no edit to the test. A second pin keeps SwiftUI
state out of the coordinator entirely. **No production code changed.**

#### Red-on-old evidence — every bug-class fix, by behavioral revert

| # | Revert applied | Pin(s) | Observed RED |
|---|---|---|---|
| 1 | `BlockDecor.textRect` returns `layoutFragmentFrame` | `everyDecorFrameRegistersWithItsBlocksText` | frame bottom **7.0 pt** past the text; every gap **0.0** vs 7.0; every seam outside the white — **9 issues** |
| 2 | `topVisibleOffset` returns `fragmentStart` | `theAnchorResolvesInsideABlockTallerThanTheViewport`, `aWidthReflowKeepsTheReadingPositionInsideATallBlock` | anchor **813** (needs > 5813); round trip **2251.0 pt** (needs ≤ 17) |
| 3 | `topVisibleOffset` passes the VIEW point | `theAnchorNamesTheBlockAtTheViewportTopNotTheOneBelow` **+ the untouched Phase 7 smoke pin** | entry **8** for 7 and **20** for 19; smoke pin `60964 ≠ 60887`, `60999 ≠ 60964` — the cancellation made visible |
| 4 | a state write added to `updateNSView` | `everyPaneStateWriteLeavesThroughThePublishDoor` | 2 writes, **1** inside the door |
| 5 | a NEW `@Binding var probeWidth` written from `updateNSView` | same | caught **by name, with no edit to the test** — the name-independence claim proven |

All reverts restored; `PaneSurface.swift` restored to HEAD and verified
byte-clean before committing. Full Mac suite re-run green after restore.

#### Numbered judgment calls / PROVISIONALs

1. **Jumps now land flush at the viewport top**, not one container inset
   (24 pt) below it — a consequence of fixing `JumpPrimitive`'s
   conversion. Flush IS the documented contract ("lands the target at the
   viewport top") and the 24 pt was an accident of the missing
   conversion, so I did not preserve it. **Whether a jump should keep top
   air is a taste question** — flagged for the standalone Design & UI
   review, not decided here.
2. **Fixed `JumpPrimitive` as well as `topVisibleOffset`** rather than
   leaving the two errors cancelling. Both are now independently correct
   against measured ground truth, the round trip is exact by
   construction, and the Phase 7 pin passes untouched — which the
   cancelling pair also did, for the wrong reason. Recorded as a decision
   because it changes visible jump behaviour (see 1).
3. **The A40 fix makes R17's white-gap rule bite for the first time**, and
   with a 7 pt uniform gap it yields a **0.5 pt** callout pad in Terminal
   (1.0 in Study, the full 5.0 with inline comments on). That is the rule
   working exactly as written. Whether a callout should get more room at
   rest is **hers** — memo Q1, with the connection to A23's gap setting
   (13d) named.
4. **`everyDecorFrameRegistersWithItsBlocksText`'s assertion was
   changed** — justified above (its prose already stated the correct
   contract; the assertion encoded the defect). Called out explicitly so
   a reviewer checks it rather than assuming.
5. **The "pin that renderedText / export / the bridge join stay
   byte-identical" constraint is satisfied structurally, not by a new
   pin:** the entire diff is view geometry under `App/Variorum/`, and
   **zero lines of `Sources/VariorumCore/` changed**, so the ONE join
   brain (`Queries.joinRenderedTexts`) and its existing pins are
   untouched — core stays 817/96 green. Adding a fresh pin over code the
   batch never touched would assert nothing. Recorded as a deliberate
   reading of the constraint, flagged for the reviewer.
6. **A40's class sweep is complete and bounded:** `BlockTint.viewRect`
   has exactly two callers (editor + read tier), both fixed. `refreshBadges`
   deliberately still reads `layoutFragmentFrame` — badges anchor to a
   block's TOP (unaffected by the trailing gap) and use the frame only for
   a generous viewport-intersection test.

#### Deviations

- **None from the ordered method.** Hypothesis pinned first, refuted,
  recorded, tracing continued; bugs split from the non-bug; the non-bug
  became the memo instead of a guessed constant.
- **One scope addition:** A4 turned out to be TWO defects, and the second
  (coordinate space) could only be fixed by also correcting
  `JumpPrimitive` — otherwise a correct anchor and an incorrect restore
  disagree. Judgment calls 1–2 record it.
- **One lookup subagent** used (Sonnet, external facts only: TK2 estimate
  API surface + `NSTextLineFragment` signatures). Its decisive finding —
  no public API exists to correct estimates — is what turned A3/A41 from
  "fix" to "memo".

#### Pre-existing, untouched, recorded for the reviewer

- `PaneSurface.swift:117` emits a Swift 6 Sendable warning
  (`passing non-Sendable parameter 'work' to function expecting a
  '@Sendable' closure`) on the `PanePublisher` scheduler default. 13b
  code, not touched by this batch, warning only.
- `[SwiftUI] Modifying state during view update` still logs from mounted
  pane tests. That is the exact condition `PanePublisher` exists to
  survive (sync write + bounded heal), not a regression — noted because a
  reviewer reading test output will see it.

#### Ladder foci suggested for this batch

The container↔view and fragment-vs-text-extent conversions (are there
other sites?); the changed decor-registration assertion; whether jumps
landing flush is acceptable; and whether the C3 memo's Part 2 posture
recommendation is honest about P1.

### Batch 1B — block deletion & redo (A7 · A8 · A10)

**Commits:** `5a4844e` (structural redo, the core half) · `7df0795`
(A7's carve, A8's door, redo's faces) · this record.
**Counts:** core **817/96 → 836/97** · Mac **668/125 → 691/126** ·
mobile 11/4 (builds clean; `AppSession` is shared by both targets and the
new redo wiring is inside the existing `#if os(macOS)` block).
**Diff scope:** 9 core files + 1 new core suite; 15 app files + 1 new app
suite. No schema change, no `Sources/VariorumCore/Sync/` change.

#### A10 — structural redo: the design fork, and why this side of it

The absence was real (the architect verified it; I re-verified before
building). The interesting part is that there are exactly two ways to
build redo here, and they are not close:

**Re-run the forward operation.** `redo` = call `divide(A, cut)` again.
Cheap to write — and wrong. Divide mints a block with a FRESH UUID, so
the entry's own inverse, which captured the OLD id at do-time, is
instantly stranded; the second undo would tombstone a block that no
longer exists and leave the new one placed. Dead end, and the codebase
already says so in its own words: the inverses are documented as
"exact-row inverses … never fresh rows — which is why do → undo
round-trips to row equality."

**Mirror the inverse.** Every registration now carries BOTH halves —
the `inverse` and a `redo` re-apply built from the SAME do-time
pre-images — so an entry MOVES between two stacks and ping-pongs
forever without re-deriving anything. `do → undo → redo` returns the
store to the post-do rows with every ID intact; that is pinned as row
snapshots, not asserted in prose.

**Totality was a deliberate choice, not an accident of effort.** A
partial redo is a P-2 smell (a door that works sometimes), so all 21
`undoStack?.register(…)` sites — plus the compound's own registration
inside `withCompound`, 22 in production — supply a re-apply and
`register` takes `redo:`
**required, never defaulted** — a future site must decide rather than
silently ship a hole. The work turned out bounded because most mirrors
already existed: `restorePlacementLocation` is its own mirror given the
other image, `revertChosenPointers` likewise, `restoreContainer` is
exactly `revertMintedContainer` reversed, and `revertDeleteBlock` is
exactly the un-tombstone `reapplyStructural` needs. Only TWO new bodies
were written (`reapplyStructural`, `reapplyMintedContainer`), plus a
`perform…` split on the deletion trio so the redo half can re-run the
row work without registering.

Two capture changes rode along, both load-bearing: move/reorder now keep
the **landed** position string (a fresh `containerPosition` derivation
would mint a new jittered key on every ping-pong and drift), and the
three adopt doors keep both pointer images through one small
`AdoptedPointer` value.

#### What binds, and where each is pinned (`RedoStackTests`, 19 tests)

| Rule | Pin |
|---|---|
| Redo is STRUCTURAL only; ⌘Z stays text undo, the stacks never interleave (AppSpec §9) | separate doors, separate keys (⇧⌥⌘Z vs ⌘⇧Z) — `theRedoCapabilityIsDeclared…` |
| Session-scoped, in-memory, never persisted | `UndoStack` state only; `removeAllClearsBothStacks` |
| Redo emits ORDINARY operations — sync never learns it exists | `redoEmitsOutboxRowsLikeAnyOperation` |
| Any new structural act clears the redo future | `anyNewStructuralActClearsTheRedoFuture` |
| Neither undo nor redo registers anything of its own | `neitherUndoNorRedoRegistersAnythingOfItsOwn` (the stack arithmetic) |
| A refused redo stays on the redo stack for retry | `aRefusedRedoStaysOnTheRedoStackForRetry` (seal → unseal → succeeds) |
| An obsolete redo pops quietly instead of wedging | `anObsoleteRedoPopsQuietlyInsteadOfWedgingTheStack` |
| A compound redoes as ONE entry, every leg re-applied | `aCompoundRedoesAsOneEntryAndReAppliesEveryLeg` |
| Exact-row round trip, IDs included | divide · merge · divide-W · take-edit · deleteBlock · reorder · moveBlock · post-mint · adopt |

#### The one behavioral finding inside redo — verified, not assumed

The first row-snapshot pins failed, and the failure was worth chasing
rather than relaxing. A diagnostic (written, run, deleted) showed the
ONLY differing column anywhere is `deleted_at` on rows that die AGAIN:
a re-release or a re-tombstone writes a fresh stamp. That is
pre-existing undo behaviour, not new — undo has always re-stamped on
each run — and it is benign, because nothing keys off a released
placement's stamp (the revive is by row id; `restoreBlock` and
`restoreContainer` key off the BLOCK's and CONTAINER's stamps, which a
released placement never carried).

What IS load-bearing is the stamp's internal CONSISTENCY, so that is
what the pins assert instead of byte-equality: after every redo→undo
cycle the block's tombstone and its cascade victims still share ONE
value (checked every round of the ping-pong), and
`aRedoneThenUndoneBlockIsStillTrayRecoverable` walks it end to end
through `Queries.trayBlocks` + `restoreBlock`. A re-apply that flipped
children with a fresh stamp instead of the block's own would fail that
on the FIRST cycle.

#### A7 — traced mechanism, and the carve

**Traced:** with blocks `["", "hello"]` the surface is `"\nhello"`;
entry 0 occupies `(0,0)` and entry 1 `(1,5)`, with the separator at 0
owned by NEITHER (the tiling doctrine). A backspace at the start of
"hello" — or a forward-delete inside the empty block — proposes the
range `(0,1)`, which is contained in no entry, so
`BlockRangeIndex.verdict` returns `.crossesBlockBoundary` and
`shouldChangeText` refuses. Exactly her report, and exactly her named
"empty block right at the start of the post" case: with nothing above
it, that seam is the ONLY gesture that can reach it.

**The carve** is one pure function (`BlockRangeIndex.emptyBlockDeletion`)
plus three caller-side guards, and its narrowness is the deliverable:
a **deletion** (never a replacement) of **exactly one inter-entry
separator** whose neighbour is an **empty** block, which is **unfanned**,
**editable**, and whose stored buffer is re-verified **empty by
compare-and-set inside the transaction** (`editTakesAtomically` with an
unchanged text is a pure verification — it registers nothing, the
`runCrossBlockEdit` precedent), so a sync apply landing text between the
keystroke and the write refuses the whole gesture. Exactly ONE undo
entry lands: "Delete Block".

**Nine pins say it cannot widen:** two blocks with text · a
multi-character range · a caret-only range · a one-character range
inside a block · the tail separator (that is `closeTail`'s) · a
single-block post · an empty post · a FANNED empty block · a LOCKED
empty block. Plus `theCarveAndTheTwoCrossBlockPlansAreMUTUALLYEXCLUSIVE`,
which is why running the carve FIRST is safe: both cross-block plans
collect targets by intersection (`length > 0`), and a lone separator
intersects nothing.

#### The assumption this batch corrected (record it — a test caught it)

I wrote a pin asserting that a bare seam-backspace between two TEXTED
blocks still merges, on the strength of the ratified "a cross-seam
delete just works" (2026-07-09). **It failed, and the pin was wrong, not
the code.** That ruling covers a SELECTION that spans text; a bare
separator range intersects neither neighbour, so `planCrossBlockEdit`
and `planVisibleTakeEdit` have BOTH always returned nil for it and the
keystroke has always refused. Consequence, now pinned as behaviour: the
range shape A7 carves is the one shape that previously did NOTHING, so
the carve changes behaviour for the empty-block case and nothing else,
and joining two texted blocks remains the explicit merge gesture. The
pin was rewritten to assert the refusal
(`backspaceBetweenTwoBLOCKSWITHTEXTStillREFUSES`).

#### A8 — the door

`deleteBlock` has been an operation since Phase 2 and had exactly ONE
face app-wide: the block-TOC row menu. It is now a DECLARED capability
(P-1) — verb, block scope, doors `[.menuBar, .bottomBar, .palette]`,
`takesAccess: .native`, the `takeFamily` availability rule reused by
name — routed through `CommandRouter` and handled natively in Write,
Takes and Lenses (R118: Write is never privileged). Caret/ring lands on
the neighbour that takes the departed block's place. Both halves flush
before deleting, so a pending buffer never lands in a tombstoned
variant. Sealed posts refuse through the op, spoken (P-2).

#### Numbered judgment calls / PROVISIONALs (all on the ratify list, QUESTIONS #33)

1. **The delete door is not restricted to empty blocks** — the operation
   isn't, the TOC door never was, and a restriction nobody ruled is
   invented product behaviour. One availability line either way. #33(a).
2. **Deleting the post's LAST block is allowed**, leaving a blockless
   post. The rule applied: no invariant makes a post's block count
   load-bearing (I10 governs variants under a live block), and the
   blockless post is explicitly modelled — `BlockRangeIndex`'s own
   doc comment names it the fresh-post state. Pinned end to end,
   including that typing rebuilds. #33(b).
3. **The "archive" half of A8 is NOT built.** `block.archived_at` exists
   in schema v1 with NO operation, NO query and NO face anywhere;
   building one means deciding what an archived block MEANS (render?
   surface? restore door?), which is product design. Deliberately left
   for her. #33(c).
4. **Both-empty neighbours resolve to the block BEFORE the separator** —
   deterministic, not derived from which key was pressed. Preferring the
   block AFTER would delete the block the caret sits in and never
   converge under repeated presses. #33(d).
5. **Redo is ⇧⌥⌘Z**, deliberately not sharing ⌘⇧Z with NSTextView's text
   redo — the two stacks never interleave, so their doors never share a
   key. #33(e).
6. **Redo's divergence bucket mirrors undo's:** a resolvable refusal
   throws and keeps the entry (retry after unsealing); an obsolete
   re-apply — the transition is already true — pops quietly rather than
   wedging every entry beneath it. The `quietWhenGone` parameter on the
   three `perform…` splits is that rule, made explicit.
7. **A compound is redoable only when EVERY leg is** (`redo: nil` on any
   leg ⇒ the compound carries none). A half-re-applied compound is not a
   state the model should be able to reach.

#### Red-on-old evidence

| # | Item | Revert applied | Observed RED |
|---|---|---|---|
| 1 | A7, the consumer | the carve unwired from `shouldChangeText` (`if false, let empty = …`) | **8 issues** across `backspaceAtTheStartOfThePostDeletesTheEmptyFirstBlock` (6) and `forwardDeleteFromInsideAnEmptyBlockDeletesItToo` (2): the store keeps `["", "hello"]`, the surface keeps `"\nhello"`, the index keeps 2 entries, the undo stack stays empty — **her reported behaviour, reproduced exactly** |
| 2 | A7, the pure carve | `emptyBlockDeletion` returns nil (`guard false, …`) | **12 issues** — the four index pins, the fan pin's index half, the mutual-exclusion pin, and both end-to-end pins |
| 3 | A8 | — | STRUCTURAL: the capability did not exist; the P-1 registry walk (`everyCapabilityIsDeclaredExactlyOnce…`, the four door tables) and the suite do not compile against the old tree |
| 4 | A10 | — | STRUCTURAL: `UndoStack.redo` / `redoDepth` / `topRedoLabel` did not exist; `RedoStackTests` cannot compile against the old tree |

Both reverts were restored and verified byte-clean (`grep -c "guard false"` = 0
in both files) before committing; the full Mac suite re-ran green after
restore.

#### Deviations / scope notes

- **One scope addition, one line:** `ShellActions.structuralUndo`'s
  failure copy moved from raw `\(error)` to `OpsRefusalCopy.message(for:)`
  — writing the redo twin beside it made the asymmetry obvious, and the
  1A record's own candidate ("consolidating the two sibling refusal-copy
  homes onto `OpsRefusalCopy`") points the same way. No behaviour change
  beyond readable refusals.
- **`JumpAndUndoTests`' serialization test** gained an explicit
  `redo: nil` — it registers a synthetic entry with no re-apply, which
  is exactly the case the required parameter makes visible.
- **`CapabilityRegistryTests`' sampled contexts** gained the
  `redoAvailable` axis (and the parity contexts gained the flag), so the
  walk still proves every act can act somewhere.
- **No lookup subagent used** — nothing external was needed.
- **P-6:** `TutorialWalkTests` ran green in the full-suite run.

#### Ladder foci suggested for this batch

Whether the carve can be reached by any range shape the nine
cannot-widen pins miss (particularly under an open tail or a gap slot);
whether `reapplyStructural`'s ordering (releases → un-tombstones →
texts) has an I2 or seal interaction the pins don't reach; whether
redo's insurance asymmetry is right (a diverged buffer is auto-committed
before a text re-apply, but merge/divide-W carry no `restoringTexts`, so
a source block edited between undo and redo is re-released with its edit
intact in lineage but no commit — the same asymmetry undo already has,
recorded deliberately); and whether the totality claim actually holds
across every registration site *(count corrected at the ladder's round-1
fix pass, R1-9: **21** `undoStack?.register(…)` sites + the compound's
own = **22** in production; "23" was not locatable)*.

### Batch 1C — the DEAD CLICK (A46) + the option-E MEASUREMENT

**Commits:** `ab16680` (the `PhantomSpaceTests` characterization
pins + the memo's Q3/Q4 update + this record).
**Counts:** core **836/97 → 836/97** (unchanged — zero core lines
touched) · Mac **691/126 → 696/127** (one new suite, five tests: four
plain + one 4-case parameterized, which reports as ONE — the counting
lesson the baselines section records) · mobile 11/4 untouched.
**Diff scope:** ONE new test file (`App/Variorum/VariorumTests/
PhantomSpaceTests.swift`) + two notes files. **ZERO production lines
changed, in either target.**

#### THE HEADLINE: A46 is NOT a bug, and the evidence is her own sentence

The batch was sent to find a fourth bug. **It found that there isn't
one**, and the finding is worth more than a fix would have been, because
it moves the whole weight of her complaint onto the thing that IS real.

Her words: *"clicking does nothing at all - it couldn't move your cursor
into the phantom space and the down arrow couldn't move you down either.
nothing was actually there."*

**Measured, through the real event route** (an `NSEvent.mouseEvent` sent
into a mounted window, hit-tested by `window.contentView.hitTest` and
delivered to whatever that returns — never a simulation of the intended
path):

- the phantom region below the last drawn line **is the editor's own
  `EditorTextView`** (hit test returns it);
- clicking there **moves the caret to the DOCUMENT END** — offset
  34,164 of 34,164 on the 60-block corpus with one 3,000-word block;
- it cannot put the caret *inside* the phantom because there is no text
  there — **which is her sentence, word for word.**

So both halves of her report describe correct text-view behaviour over
space that is not text. The architect's brief already conceded the
down-arrow half; the measurement extends the same verdict to the click.
**Under the hallucination guard this is the recorded-and-dismissed
outcome, not a fix**: there is no traced mechanism connecting a dead
click to her symptom, and inventing one would be the forbidden class.

**Consequence, recorded because it changes what to build:** removing the
phantom (memo Q3, option E) is now the *only* remedy for what she
experienced — there is no cheaper independent fix hiding behind it. And
**A22** ("scroll into a page of empty space so I can type high on the
page") must make that space REAL — room the caret can enter — or it will
feel exactly as dead as this does. The brief predicted this pairing; the
measurement confirms why.

#### What WAS found dead — and why it is recorded, not fixed

A constant **6.0 pt** strip at the very bottom of the editor's scroll
view routes clicks to the scroll view's background instead of the text
view (`NSClipView` stops covering the document view there). Measured
identical at every window height tried — 200 / 400 / 500 / 700 / 900 pt
clip, text view always exactly 6 pt shorter.

**It is AppKit's, not ours:** a vanilla `NSTextView(usingTextLayoutManager:
true)` in a vanilla `NSScrollView`, configured the way Apple documents,
shows the identical 6 pt with no Variorum code in the picture
(`theBottomStripIsAppKitsNotOurs`). Not caused by `contentInsets` either
(zeroing them and turning off `automaticallyAdjustsContentInsets` changed
nothing).

Not fixed, deliberately: 6 pt is a sliver above the commit bar, working
around AppKit's clip-view hit testing to reclaim it would be a hack, and
it is provably not her report. **Pinned at size instead**
(`theDeadStripAtTheBottomOfTheScrollViewStaysASliver`, ≤ 8 pt) so that if
this class ever grows into the readable band she described, a test says
so before she does — P-7's letter.

#### Hypotheses killed on the way (recorded so nobody re-walks them)

Each was traced, tested, and refuted — all cheaply, none turned into
code:

1. **An overlay eating the hit.** No: every decoration view returns `nil`
   from `hitTest` by construction (`DecorRectView`, `SeamLineView`, and
   `CommentCardView` when it has no door — the round-3 rule); the two
   that do take clicks (comment cards WITH a door, drag handles) are
   small and margin-anchored.
2. **The document shrinking under a deep scroll**, leaving the clip
   parked past the end. Tested by parking at the bottom of the
   estimate-inflated height and then forcing the long block's layout:
   **overshoot 0.0** — AppKit re-clamps.
3. **A huge LAST block leaving dead space at the document end.** Tested:
   `gapBelowText` = 24.0 pt, exactly the container inset. Scrolling to
   the bottom lays the block out, so the error is gone by the time you
   are there.
4. **A gap in the MIDDLE, between a long block's last line and the next
   block's first** (her "the extreme gap at the bottom of a single
   block"). Walked the whole post in 300 pt steps looking for one: **no
   on-screen gap > 12 pt exists.** TK2 keeps fragment positions
   consistent — when the block lays out, everything below moves with it
   (which is the JUMP 1A fixed, not a gap).
5. **The gutters and insets.** With a 1,400 pt-wide window (360 pt
   gutters — R9's bounded column), clicks in the left gutter, the right
   gutter and the top inset all land the caret on the correct LINE.

#### The option-E MEASUREMENT (measured, deliberately NOT built)

The brief was explicit — measure and stop — and the architect had
promised her in writing that E would not be built on arithmetic. Method:
real windows, 60-block posts with one long block in the middle,
`ensureLayout` over **that block's own text range only**, timed with
`ContinuousClock`. Debug build (Release is faster), macOS 26.4.1 /
Xcode 26.3.

| Long block | (a) cost | (b) phantom removed | per 1k words | (c) survives travel |
|---|---|---|---|---|
| 1,000 w | 1.27 ms | 180 pt | 1.27 ms | yes |
| 3,000 w | 2.90 ms | 537 pt | 0.97 ms | yes |
| 12,000 w | 11.52 ms | 2,169 pt | 0.96 ms | yes |
| 25,000 w | 20.06 ms | 4,549 pt | 0.80 ms | yes |

**My honest read: E is alive, and the numbers are better than the
architect's arithmetic guessed.**

- **(a) Cost** is ~1 ms per 1,000 words and the rate is **flat-to-
  improving** as the block grows — the shape P1 actually demands (∝ the
  block, never the post). Against the Phase 6 spike's whole-document rate
  of **105 ms / 50,000 words = 2.1 ms per 1k**, one block is ~2× cheaper
  per word *and* structurally bounded. Even 25,000 words in one block —
  far past anything she has written — is a one-time 20 ms.
- **(b)** It removes exactly the over-estimate, every size.
- **(c) The open risk came out favourably:** TK2 does NOT discard the
  layout. After scrolling to the far end of the post and back the
  fragment is still `layoutAvailable` at all four sizes, so E is once per
  block per session, not a treadmill.

**Caveat found while measuring, stated rather than buried:** the *scroll
extent* does not shrink synchronously with the layout call — the document
height corrects on the next display pass (9,063 pt unchanged at the
instant; 8,708 pt one pass later). A built E must nudge the refresh, not
merely ask for layout. **Also still undecided if she says yes:** the
TRIGGER policy (which long block, on what event) — a design question, and
the place where a one-time 3 ms could turn into something that runs too
often.

Recorded in the memo under Q3 in her language, with the recommendation
moved from "A now, E as candidate" to **E**, A as fallback.

#### Numbered judgment calls / PROVISIONALs

1. **No fix was shipped for A46** — the finding is dismissed as
   not-a-bug and recorded, per the hallucination guard's own rule that a
   finding whose mechanism does not trace to the symptom is recorded, not
   fixed. The alternative (fix the 6 pt AppKit strip and call A46
   addressed) would have been a fix that could not possibly have caused
   her report — worse than nothing, because it would close the item.
2. **The 6 pt strip is pinned but not fixed** (above). If she wants it
   reclaimed, the honest shape is a bottom `contentInset` or a document-
   view minimum height that matches the clip — one line, but it is
   working around AppKit and it changes nothing she can see.
3. **The pins are CHARACTERIZATION pins, not red-on-old pins**, and are
   labelled as such in the file's header. There is no pre-fix code for
   them to be red against; their job is to hold the measured truth so a
   future session does not re-litigate A46 from scratch, and to fail if
   the dead-strip class ever grows.
4. **The E measurement ships as a TEST rather than a throwaway spike**
   (~1.8 s of suite time). Reason: the memo's numbers are the evidence
   she rules on, and a re-runnable measurement is worth more than a
   number in a document — the same reasoning as the Phase 9 latency pins,
   which also print. If the architect prefers it as a `Spikes/` binary,
   it moves with no loss.

#### Red-on-old evidence

**None owed — nothing was fixed.** Stated explicitly rather than left
blank: the batch's deliverable is a refutation plus a measurement, and
neither class carries a red-on-old pin. The reproduction evidence is in
the numbers above, each printed by a test that runs on every suite run.

#### Deviations

- **No production code changed at all** — the largest possible deviation
  from a batch brief that expected a fix, and the correct one: the fix
  had no bug to attach to.
- **No lookup subagent used.** Nothing external was needed; 1A's lookup
  had already established that no public API exists to correct TK2's
  estimates, and this batch's questions were all answerable by
  measurement.
- **P-6:** `TutorialWalkTests` green in the full-suite run.

#### Ladder foci suggested for this batch (1C)

Whether the A46 refutation is complete — i.e. whether any surface OTHER
than the Write editor (a `PaneSurface` pane in Takes / Lenses / Compare,
a read-tier post in the book view, a canvas card) can present phantom
space whose click does NOT reach a text view; the 1C probes covered the
Write editor's scroll-view path and the inline (book) editor's frame, and
found the pane path measures honestly because `PaneMeasurement` lays out
first — but a reviewer should decide whether "not reproduced in the
surface she named" is the same as "does not exist". Also: whether the
characterization pins assert the right invariants (particularly the ≤ 8 pt
bound, which is a judgement about how big is too big), and whether
shipping the E measurement as a suite test rather than a spike is the
right home.

### Batch 1E — the PHANTOM FIX (memo option E, PROVISIONAL)

**Commits:** `<this record's commit>` (the build, its suite, QUESTIONS #39
and this record — one commit; no schema change, no core change).
**Counts:** core **848/98 → 848/98** (unchanged — **zero
`Sources/VariorumCore/` lines touched**, so the baseline is coherent by
construction) · Mac **700/127 → 719/129** (two new suites, 19 tests: 10
pure + 9 hosted) · mobile **14/4 → 14/4** (RUN on the iPhone 17 Pro
simulator, not inferred — the batch touches `EditorViewModel`, which is
Mac-only, and the run confirms it).
**Diff scope:** 2 new files (`Features/Editor/LongBlockLayout.swift`,
`VariorumTests/LongBlockLayoutTests.swift`) + 4 edited, **36 added lines
total across the four** — the whole concern lives in its own file, and
`EditorViewModel` grew by one stored property and two call sites (P-9).

#### What shipped

When the viewport is looking at — or is one screenful short of — a block
whose layout TK2 has only ESTIMATED, the editor asks for layout of that
one block's own text range, once. Its over-guess collapses and the
document gives back the phantom in the same turn.

Measured in a real window this batch, on 1C's own corpus: the 3,000-word
block's **7,837 pt guess → 7,300 pt real**, and the document
**9,063 → 8,533 pt** — the same 530 pt, and the memo's independently
measured 537 pt for that block size. That number appears in the record
twice from two directions, which is the corroboration worth having.

#### What the architect named as this batch's best work (recorded at the fix pass, in his words' substance)

Kept in the record because they are the practices, not the outcome:

1. **Pinning the CAP'S DERIVATION** rather than only choosing a good
   number — *"a number that stays honest."* `theCapStaysUnderHalfAFrameAtTheWorstMeasuredRate`
   fails if the constant is ever raised past the evidence it came from.
2. **The FLOOR added beyond the brief.** An ordinary post performing
   *zero* layout calls is the correct default and was not specified;
   revert R3 shows what its absence looks like (a post of 27-character
   blocks starts laying blocks out one per pass).
3. **Saying which pins are CHARACTERIZATION rather than red-on-old, in
   the file's own header — and reporting that R6 and R7 did not fire on
   the first attempt and why.** *"A batch that reports its own
   counterfactuals being wrong is one I can trust the rest of."* The fix
   pass added a third instance of the same discipline: R1's red stopped
   reproducing under the new contract, and the header says so instead of
   keeping a pin that proves nothing.

#### The trigger policy, and why each part of it

The brief's constraint was that the cost is not the danger, the TRIGGER
is. What that turned into:

| Guard | Value | Why this value |
|---|---|---|
| **Cap** | 64,000 UTF-16 units per block | Below |
| **Once per block** | **per CONTAINER WIDTH**, `handled` | The brief's rule as ruled at the fix pass (below): once per *session* was written before anyone knew a width reflow discards TK2's layout. One pass per **SETTLED** width, never per width sample |
| **Floor** | 2,000 UTF-16 units (~350 words) | An ordinary post performs **zero** layout calls, ever — the calm default costs nothing (`refreshDecorations`' doctrine). This is the guard that keeps the trigger quiet in the common case |
| **Reach** | viewport + **1 viewport** of look-ahead, and ≤ 64 fragment lookups per pass | Non-zero look-ahead is what makes E do anything (a block strictly *inside* the viewport has already been laid out by TK2 itself); bounding it is what stops "the viewport is looking at it" quietly meaning "the whole post" |
| **Per pass** | exactly ONE block | A pass can never cost more than the cap, whatever the post looks like |
| **When** | after scrolling SETTLES (150 ms debounce), never during it | A 7 ms hop inside a live scroll is a dropped frame; the same hop when the viewport stops is invisible |
| **Where** | the DETAIL editor only (`scrollView != nil`) | The inline/book editor is sized to CONTENT, so it has no viewport smaller than its document — "the block the viewport is looking at" would mean every block, which is the document-scale work P1 forbids. The pane surfaces measure honestly already (1C: `PaneMeasurement` lays out first) |
| **Kill switch** | Settings → Appearance → Editor, default ON, LOCAL | She rules on Q3 having felt it. Local (the `writeHoverHandles` class) rather than the synced `setting` table: this is one Mac's editor behaviour, not document semantics |

**THE CAP'S REASONING, stated as the brief asked.** 1C's table is in
words; the quantity this code can check for FREE is the block's UTF-16
length (already in `BlockRangeIndex.Entry` — counting words would mean
reading each candidate's text on every scroll, which is the P1 mistake
the feature exists to avoid). The measurement corpus's words are
`"longword\(i % 97)"` joined by single spaces = **10.897 units/word**, so:

| words | UTF-16 units | measured | ms per 1k units |
|---|---|---|---|
| 1,000 | 10,897 | 1.27 ms | **0.117** |
| 3,000 | 32,691 | 2.90 ms | 0.089 |
| 12,000 | 130,764 | 11.52 ms | 0.088 |
| 25,000 | 272,425 | 20.06 ms | 0.074 |

Worst observed rate **0.117 ms per 1,000 units**. Budget: **half a 60 Hz
frame (8.3 ms)** — half a frame so the same runloop turn has room for
everything else. *(Corrected at the ladder's round-1 fix pass, R1-5: this
paragraph originally added "in a DEBUG build … margin on top of margin".
That margin is not real — `ensureLayout` runs in the system TextKit
binary, identical in both configurations, and no app code runs in that
path. The Debug measurement is simply THE measurement; the cap stands on
the half-frame budget alone.)* 8.3 ÷ 0.117 ≈ 71,000; rounded
down to **64,000**, predicted worst case **7.5 ms** (~5.7 ms at the
measured mid-range rate). The architect's "20 ms at 25,000 words is
already past a frame budget" is honoured with ~4× of room. In her prose
(~5.5 units/word) the cap is ~**11,600 words in a SINGLE block** —
generous where it matters, hard where it would hurt. The derivation
itself is pinned (`theCapStaysUnderHalfAFrameAtTheWorstMeasuredRate`), so
the constant cannot be raised past its own evidence silently.

#### The refresh nudge — measured, not assumed, and the first guess was wrong

1C recorded the caveat (the scroll extent corrects on the *next* display
pass, not synchronously) but not the mechanism. My first cut took
"display pass" literally and set `needsDisplay`. **Measured: that does
nothing** — 9,063 pt before, 9,063 pt after `window.display()` plus
runloop turns, and on this layer-backed view `needsDisplay` does not even
read back true. The lever is **LAYOUT**: an `NSTextView` with
`isVerticallyResizable` re-frames itself from
`usageBoundsForTextContainer` in its layout pass (9,063 → 8,533 pt). So
the pass sets `needsLayout` and settles it in the same turn with
`layoutSubtreeIfNeeded()` — measured **0.21 ms cold / 0.05 ms warm**,
inside the cap's budget, and it closes the space *with* the layout rather
than a beat later.

**Why it cannot loop** (the brief's explicit worry): only the HEIGHT
changes, and `EditorTextView.setFrameSize` signals `onWidthReflow` on
WIDTH changes alone, so no overlay generation is bumped. The resulting
clip-bounds change *can* re-enter the trigger — but the block is in
`handled` by then, so a second layout for it is impossible; each pass
consumes one block from a set that only shrinks, so the chain terminates
by construction rather than by timing. `aScrollSweepTouchesEachLongBlock…`
pins the whole thing over a real 100-block sweep: three long blocks, at
most three layout calls, no short block ever touched, and a **second full
read-through costs nothing at all**.

#### THE FINDING, and the architect's ruling on it (fix pass, same session)

The brief's reasoning for the once-per-block rule was *"TK2 does not
discard the layout, so a second pass is pure waste"* (1C measured that
across scroll travel, correctly). **A WIDTH REFLOW is not the same, and I
measured it:** a laid-out 3,000-word block goes straight back to
`estimatedUsageBounds` when the column narrows — **7,300 pt real →
11,492 pt guessed**, a *worse* over-estimate than it started with.

I built to the brief's literal bound and reported the fork rather than
widening it myself. **The architect ruled: TAKE IT** — and the reasoning
is worth more than the outcome, so it is recorded here as given: *"the
rule's purpose was never the literal word 'session' — it was to prevent
the same work being redone wastefully… Re-laying out a block whose layout
TK2 has genuinely thrown away is not that: it is the same bounded work
for a new state. New information changed the reasoning; the principle is
intact."* Plus the cost of NOT taking it: the phantom returns on her
first sidebar toggle and is then never corrected — **a fix that silently
stops working, and a second report of the same bug** (P-5: she should not
discover an edge we already knew about).

**What changed, and what did not.** Eligibility is now keyed on the
CONTAINER WIDTH (`handled: [String: CGFloat]`) rather than a flag; a
block is eligible again only at a width it has not been handled at. The
cap, the floor, one-block-per-pass, the reach bounds, detail-editor-only
and the kill switch are untouched.

**Why the width axis does not widen the trigger** — three things, in
order of how much work they do:

1. **The `laidOut` check gates every candidate.** A width change that did
   NOT discard the layout costs *nothing at all* — re-eligibility only
   PERMITS the work; TK2's own state decides whether any is needed.
2. **One pass per SETTLED width, never per sample** — the architect's
   hard requirement, and the thing actually worth worrying about, since a
   divider drag emits a continuous stream of widths. The existing
   **scroll-settle debounce is reused, not duplicated**: every width
   sample cancels and re-arms it, so one pass runs after the drag stops.
   Pinned by `aWidthDragProducesOnePassAtTheSettledWidthNotOnePerSample`
   — 14 samples ⇒ **1 layout**; with the settle gate bypassed, **16
   passes** (revert R8).
3. **The nudge cannot manufacture eligibility.** It changes only the
   HEIGHT, and `EditorTextView.setFrameSize` signals `onWidthReflow` on
   WIDTH changes alone — so the one event that grants re-eligibility is
   exactly the one the fix cannot cause. Termination is unchanged: at a
   given width the map only grows.

**A second, smaller honesty item that came out of re-running the
reverts.** Under the old contract, removing the `handled` write made
`theSameBlockIsNeverLaidOutTwice` fail. **Under the width contract it no
longer does** — TK2's own `layoutAvailable` state covers that ground at
every width. Rather than keep a pin whose named guard no longer earns it,
the claim moved to where `handled` *is* provably load-bearing: an
over-cap block must stop appearing in the scan's answer at all, not
merely stop being re-recorded (`aBlockOverTheCapIsSkippedAndRecorded`'s
second-pass assertion; revert R1′ is red). The test file's own header
says this in as many words.

**One flake caught and corrected honestly, not tuned away.** The drag
pin's first form asserted `passesRun == 1`; it passed alone and failed in
the full-suite run at 2. The cause is real and is now in the pin's
comment: a width reflow *also* fires the overlay layout-settle hop by
design — a second legitimate trigger whose async hop can land after the
first pass under load and coalesce into one more. So the pin asserts the
exact thing it can (`layoutsRun == 1` — the cost, and a second pass
cannot add one because the block is handled at that width) and a
decisive bound on the rest (`passesRun <= 4` against R8's measured 16).
The over-tight version would have been a flaky pin, which is worse than
a slightly looser true one.

#### Red-on-old evidence — every GUARD, by behavioral revert, run both ways

**Stated plainly first, because the batch ships a NEW CAPABILITY:** the
end-to-end pins (`aPassCollapsesThePhantomOfALongBlock`, the sweep, the
planner's decision tests) are **CHARACTERIZATION** — there is no pre-batch
code for them to be red against; the type does not exist there. What IS
red-on-old in the real sense is every GUARD, and each revert below was
executed against the shipped tree and observed:

| # | Revert applied | Pin(s) | Observed RED |
|---|---|---|---|
| R8 | **the SETTLE GATE bypassed** (the trigger runs the pass directly) | `aWidthDragProducesOnePassAtTheSettledWidth…` | **16 passes** for 14 width samples where 1 is the contract — the drag failure the ruling worried about, made visible |
| R1′ | the over-cap `handled` write removed | `aBlockOverTheCapIsSkippedAndRecorded` | the second pass re-considers the 76,269-unit block forever — `plan.isEmpty → false` |
| R2 | the cap comparison disabled | `aBlockOverTheCapIsPassedOverAndRecorded` + `aBlockOverTheCapIsSkippedAndRecorded` | **8 issues**; a **76,269-unit** block laid out instead of skipped; `skippedOverCap → []` |
| R3 | the floor comparison → `>= 0` | `anOrdinaryPostNeverLaysOutAnything` (+ 3 more) | an ordinary post of **27-character** blocks starts laying blocks out one per pass — `layoutsRun → 5`, `handled` 5 short blocks: the trigger-runaway class, made visible |
| R4 | the kill-switch read → `true` | `theKillSwitchStopsItCompletely` | **5 issues**; the pass runs and the trigger arms with the switch off |
| R5 | the nudge removed | `thePassAsksForTheRefreshItNeeds` + `aPassCollapsesThePhantom…` | the block gives back **537.0 pt** and the document gives back **0** — the caveat reproduced exactly |
| R6 | the detail-editor scoping guard removed (scan falls back to the whole surface, as `viewportBounds(of:)` does inline) | `theInlineEditorIsOutOfScope` | the content-sized inline surface lays out the long block — `layoutsRun → 1` where 0 is required |
| R7 | **both** reach bounds removed (look-ahead + lookup cap) | `aLongBlockFarBelowTheLookAheadIsLeftAlone` | the pass reaches **entry 150 of 200** and lays it out |

**All eight were re-run against the SHIPPED tree after the width fix
pass** (the guard code moved under them, so evidence gathered before the
ruling would not have counted). Every revert was restored and the file
verified **byte-identical to a pre-revert checksum** (`shasum` against a
pristine copy) before the next one; the suites re-ran fully green
afterwards, and the two new suites were re-run twice in isolation plus
once inside the full Mac suite to check the drag pin for flake in both
directions.

**Recorded honestly about R6 and R7, because the first attempts did not
fire.** R6's first form fabricated an `NSScrollView` around the inline
view and stayed GREEN — the fabrication did not model the real
alternative. The faithful counterfactual is the one the codebase itself
uses for that surface (`viewportBounds(of:)`'s `textView.bounds`
fallback), and *that* is red; the test was also corrected to frame the
inline surface at CONTENT scale, which is what its wrapper actually does.
R7 likewise: reverting the look-ahead **alone** stayed green, and so did
reverting the lookup bound alone — at that distance the two bounds cover
for each other, and only removing both is red. Both facts are written
into the pins' own doc comments rather than left as a tidier-sounding
claim.

#### Numbered judgment calls / PROVISIONALs

1. **The whole feature is PROVISIONAL (QUESTIONS #39), default ON.** The
   brief's instruction, and the reason is the point: she rules on memo Q3
   having FELT it, not from a table. The kill switch returns the old
   behaviour exactly, with no relaunch (pinned).
2. **The cap is in UTF-16 units, not words** — the length is already in
   the index, so the check is free; measuring words would read every
   candidate's text on every scroll, which is the P1 mistake the feature
   exists to avoid. The word-based reading of 1C's table is converted at
   the constant, with the conversion shown.
3. **A FLOOR was added that the brief did not ask for.** It is the guard
   that keeps the trigger quiet in the ordinary case (R3 shows what
   happens without it: a post of 27-character blocks starts laying blocks
   out). Recorded as an addition, not smuggled in.
4. **"Skip and record" records in CODE, not to her.** `skippedOverCap` is
   an inspectable, pinned list; there is no user-facing message. A "this
   block was not optimised" line is developer noise about a cosmetic
   nicety, and the kill switch is her real control.
5. **Scoped to the detail editor**, with the inline surface deliberately
   out (see the table). The pane surfaces are out too, for 1C's reason —
   they lay out before measuring, so they never carry an estimate.
6. **The debounce is 150 ms** — an engineering default of the
   `settleDebounce` class, injectable, chosen so nothing happens during a
   live scroll. Not derived from anything; adjust freely.
7. **Eligibility is keyed on the container WIDTH** (the architect's
   ruling at the fix pass), settle-gated so a drag costs one pass. The
   width is derived from the view (`bounds.width − 2 × inset`) rather
   than read off the text container, so it tracks the dynamic gutter
   exactly, and it is ROUNDED so sub-pixel jitter is not a new width.
8. **The test harness disables the debounce by default**
   (`EditorTestSupport`, one line beside the identical `tailIdleSleep`
   line) so every existing suite's geometry is byte-unchanged — notably
   `PhantomSpaceTests`, whose whole job is to characterize the
   UN-corrected estimate. 1E's own pins drive `runLongBlockLayoutPass()`
   explicitly. Production default is unchanged (ON).

#### Deviations

- **None from the brief's four requirements** — cap, once-per-block pin,
  kill switch, refresh nudge, all built and all pinned; the cap's
  reasoning is stated as asked; the whole thing is marked PROVISIONAL and
  logged; A46 was not chased and memo Parts 1 and 3 were not touched.
- **One correction to the brief's premise**, reported not absorbed —
  then RULED by the architect and built in the same session (the FINDING
  above). The record deliberately keeps both halves: stopping at the
  bound, and the reasoning that moved it.
- **One addition beyond the brief**: the size floor (judgment call 3).
- **No lookup subagent used** — every open question this batch had
  (which lever moves the scroll extent; whether a reflow re-estimates;
  whether two long blocks fit one look-ahead) was answerable by
  measurement, and was measured.
- **Zero `Sources/VariorumCore/` lines**, zero schema, zero
  `Sources/VariorumCore/Sync/`. The stop-and-report condition never
  triggered.
- **P-6:** `TutorialWalkTests` green in the full Mac suite run.
- **P-1:** nothing new is a routed ACT — this is a rendering behaviour
  with a Settings toggle, the `writeHoverHandles` class, which the
  standing 4A–4F reading files as surface-local (recorded, not declared).

#### Ladder foci suggested for this batch

Whether the width key is the right granularity now that it is ruled in
(a reviewer should satisfy itself that the settle gate really is the only
thing standing between a divider drag and repeated layout, and that the
overlay settle hop cannot slip a pass through mid-drag on a slower
machine — the drag pin bounds it at 4 for 14 samples, which is decisive
but not 1); whether `layoutSubtreeIfNeeded()` inside the settle hop can reach any
path where a synchronous AppKit layout is unwelcome (it is never called
from inside a draw or a SwiftUI update — the debounce guarantees a fresh
main-queue turn — but a reviewer should check the `overlayLayoutDidSettle`
chain for itself); whether the look-ahead of ONE viewport is the right
reach, given that an estimated long block is tall enough that a second
one essentially never shares a look-ahead window (measured while writing
the tests, and the reason the two-blocks-in-one-window test was replaced
by the scroll sweep); whether the floor at 2,000 units leaves a visible
phantom class uncovered; and whether the detail-editor scoping is
complete — the pane surfaces are excluded on 1C's finding that
`PaneMeasurement` lays out first, which a reviewer should confirm still
holds for every pane host rather than take from the record.

### Batch 1D — the bridge (A1 · A2)

**Commits:** `88bfd9a` (A1, the daily-book membership + its suite) ·
`2dd3e2f` (A2, the lifecycle cadence + the stale-label honesty + pins) ·
this record.
**Counts:** core **836/97 → 848/98** · Mac **696/127 → 700/127** ·
mobile 11/4 (builds clean; the shared `AppServices` change is an
optional init parameter with a default plus a method mobile does not
call, and mobile's bridge is disabled by construction).
**Diff scope:** 1 core file + 1 new core suite; 3 app files + 2 app
suites. No schema change. **Zero `Sources/VariorumCore/Sync/` lines
touched** — the scope guard held with nothing to report.

#### A1 — traced in her own store before a line was written

The architect's trace was correct and I built from it rather than
re-deriving it. What I added is the **evidence from her real store**,
read-only, which turns the trace into a fact:

| day | post created | `bridge_day.last_remote_stamp` | in the Journal book? |
|---|---|---|---|
| 2026-07-11 | `02:12:20.581Z` | `02:12:03.437Z` (**17 s EARLIER**) | **no row at all** |
| 2026-07-16 | 2026-07-14 | 2026-07-17 | **no row at all** |
| 2026-07-18 / 20 / 21 | — | — | in book |

A post created seventeen seconds *after* the Fragments row it landed is
the bridge-mint signature, and it carries **no `reading_post` row at
all** — not live, not tombstoned. Her designation is healthy (`Journal`,
curated, pinned, unlocked), so the missing half is exactly the one the
architect named: `BridgeEngine.land` called `createOrOpenJournalEntry`
and stopped, while `JournalBooks.openToday` calls it *and then*
`addPostToReading`.

**The fix, and its three deliberate rules.** A landing that WROTE to a
day (`created` / `updated` / `conflictVariant` / `rescuedVariant` —
echoes, replays and consumed-with-a-note rows wrote nothing and shelve
nothing) shelves that day's canonical entry in the designated daily
book, mirroring the Mac door's error handling rather than inventing
semantics.

1. **The landing is NEVER blocked by shelving.** It runs after the body
   is in the store and after the cursor advances, and it returns a NOTE
   instead of throwing — a finished book, a full book, a smart book, a
   dangling designation and any unexpected error all land-and-speak.
   "Nothing typed in either app can be permanently lost" outranks
   tidiness, and the note surface already exists (`LandingReport.notes`
   → `Status.issueNotes` → the status row's "needs attention").
2. **Never re-shelve what she took off the shelf.** A `reading_post`
   row for the pair — **live OR tombstoned** — means the pair is already
   decided, so the bridge leaves it alone. This is what answers the
   otherwise-fair objection to shelving on every write: a headless round
   can never undo a deliberate `removePostFromReading`.
3. **…and rule 2 is also what makes it a REPAIR.** Her two orphans have
   no membership row of any kind, so the next landing that writes to
   those days shelves them — as it will for any entry minted by a door
   that doesn't shelve.

#### A1's judgment calls / PROVISIONAL

1. **Shelve on every WRITING landing, not only at mint (judgment call).**
   `openToday` *ensures* membership on every invocation, so parity is the
   ensure, not the create. The mint-only alternative would never repair
   her existing orphans and would never catch an entry minted elsewhere.
   The objection this raises — re-adding an entry she removed — is
   answered structurally by rule 2 above, and pinned.
2. **No designated daily book ⇒ land, skip, and SAY SO (PROVISIONAL,
   QUESTIONS #37).** The architect's lean, and I agree with it after
   building the alternatives in my head: the Mac door *creates and pins*
   a "Journal" book on first use **because she pressed a button**; a
   headless bridge minting and pinning a book on her shelf while she
   sleeps is a materially larger act, and it would be the first time the
   bridge created anything but journal entries. A silent skip (option i)
   leaves her exactly where she was — an entry in the Pool with no
   explanation, which is the confusion she reported. Pinned that the
   round mints **no reading at all** in this state.
3. **A CLASS INSTANCE FOUND AND DELIBERATELY NOT FIXED — for the
   architect, not built:** the mobile capture door
   (`EntryListViewModel.open(on:)`,
   `App/Variorum/VariorumMobile/Features/Capture/EntryListViewModel.swift:94`)
   calls `createOrOpenJournalEntry` and stops, exactly as the bridge did.
   So an entry minted **on her phone** arrives on the Mac bookless and
   shows in the Pool — the same symptom from a different door. It is out
   of this batch's stated scope and touches a target whose suite I did
   not run, and the daily-book designation is a synced setting so the
   phone could do it. **Two mitigations already in place:** A1's rule 3
   repairs such an entry the moment Fragments writes to that day, and
   ⌘J on the Mac repairs it the moment she opens the day. Recorded as
   the sweep's third instance; ownership is the architect's call.

#### A1's red-on-old evidence (behavioral revert, run both ways)

| # | Revert applied | Observed RED |
|---|---|---|
| 1 | the call site unwired (`if false, outcome.wroteToTheDay`) | **9 of 12 pins red, 14 issues** — `rows.count → 0` where 1 is required; every "…LandsAndSaysWhy" note assertion `nil`; the repair and rescue pins find no membership |
| 2 | the pure helper no-ops (`if true { return nil }`) | the same 9 pins red with the same shapes — the helper is the site, not the consumer |

Both reverts restored and verified byte-clean before committing
(`grep -c` = 0 for both markers); the suite re-ran green after restore.
The three pins that stay GREEN under both reverts are the narrowness
pins and are labelled as such in the file's own comment
(`theBridgeNeverReShelvesAnEntryTheAuthorRemoved`,
`anEchoLandingShelvesNothing`, `shelvingNeverCausesAPush`) — they hold
the carve's edges, the 1B cannot-widen precedent.

#### A2 — the trace, and it is BOTH answers at once

The architect's instruction was to trace before tuning, and said plainly
that "it was the sign-out, change nothing" would be a complete answer.
**The trace confirms the sign-out as the dominant cause AND shows the
hole is structural rather than historical, so I fixed the hole and left
the throttle alone.**

**What the wiring actually is.** The bridge's ONLY cadence trigger is
`sync.onRoundCompleted` (`AppServices:111-113`), which fires when a sync
round FINISHES. Sync rounds come from exactly three places, and **there
is no periodic timer anywhere in the app**: `connectSyncIfAllowed` at
sign-in/launch, `didBecomeActiveNotification`, and the outbox settle
observation. Signed out of the Variorum project, `connectSyncIfAllowed`
never runs, `sync.scheduler` stays nil, `triggerSync()` returns
immediately, `roundsCompleted` never increments — **so `onRoundCompleted`
never fires and the bridge ran exactly once per launch**, via the
`bridge.trigger(manual: true)` in `connectBridgeIfAllowed`. That is
2026-07-20 → 07-25, five days, with her Fragments session perfectly
valid the whole time. Her `bridge_day` rows stop at
`2026-07-21T23:17:45` in the real store, consistent with it.

**Why it is not a one-off.** The same starvation returns whenever the
Variorum session is absent — an expired session, a sign-out — **and on a
failed owner adoption**, because `connectSyncIfAllowed` returns before
composing when `runOwnerAdoption()` fails. And the 9b plan's Step 5
names the bridge's cadence as *"launch / became-active /
post-write-settle"*, which is not what the code does in that state: a
spec-vs-code divergence, which CLAUDE.md says to align to the spec.

**The fix (`AppServices.triggerLifecycleRound`)**: one sync round, plus
one bridge round *only when sync cannot deliver one*. It is a CADENCE
trigger, never manual, so the 60 s throttle still guards the
O(journal-days) hash sweep (QUESTIONS #15's ratified relaxation).
With sync configured the behaviour is byte-identical to before, and
that is its own pin (`theLifecycleCadenceStillNeverInterleavesWhenSyncIsOn`
parks a sync round mid-flight and requires zero bridge rounds beside it).

**The second half — a stale bridge must not LOOK fresh.** The row's
label was time-only, so for five days it read "Bridged 11:04 PM" and
looked like it had just run. That is the same *silently-frozen-bridge*
class the 9b round-1 MINOR 4 fixed for per-day rejections, and it is the
observability half of her actual sentence: past today the label now
carries the date.

#### A2's judgment calls / what was deliberately NOT done

1. **The 60 s throttle is UNCHANGED.** The trace does not justify it —
   the latency she felt was five days, not a minute — and its own
   ratification's "adjust freely" wording is not a reason to adjust
   without cause.
2. **No periodic poll was added, deliberately.** Even signed in, nothing
   pulls Fragments while she sits in Variorum without typing or
   switching apps; a timer would fix that and is the obvious next idea.
   It is not mine to take: every bridge round hash-sweeps every live
   journal day, so putting that on a clock forever is a cadence/P1
   posture change on top of QUESTIONS #15's ratified relaxation.
   **Recorded for her/the architect, not built.**
3. **The `bridgeMinimumRoundInterval` init parameter is a test seam**
   (default `.seconds(60)`, production unchanged), following the file's
   own `makeSyncTransport`/`makeBridgeTransport` precedent — without it
   the cadence pin would have to wait a real minute.
4. **Mobile's became-active hook was left alone.** It still calls
   `sync.triggerSync()`; mobile's bridge is disabled by construction
   (`bridgeEnabled: false`), so routing it through the new method would
   be a no-op. Recorded rather than changed.
5. **The sync row's label was left alone** although it has the same
   time-only form: the sync row already speaks loudly when it is off
   ("Signed out" + a Sign in… button), which is what the bridge row
   lacked. Flagged as a sibling candidate, not taken.

#### A2's red-on-old evidence (behavioral revert, run both ways)

| # | Revert applied | Pin | Observed RED |
|---|---|---|---|
| 1 | `triggerLifecycleRound` body → `sync.triggerSync()` alone | `theLifecycleCadenceReachesTheBridgeWhenSyncIsOff` | bridge calls never rise above the launch round — **her five days, reproduced in 2.7 s** |
| 2 | the app hook back to `services?.sync.triggerSync()` | `theBecomeActiveHookRoutesThroughTheLifecycleCadence` | 2 issues — the rule exists but nothing calls it |
| 3 | the label back to time-only | `theLastBridgedLabelShowsTheDateOnceItIsNotToday` | `"Bridged 9:30 AM"` for a **five-day-old** round |

`theLifecycleCadenceStillNeverInterleavesWhenSyncIsOn` stayed GREEN
under all three, as an ordering pin should. All three reverts restored
and verified by grep; both suites re-ran green, then the full Mac suite.

#### 9b's guarantees — checked, not assumed

Read in the 9b record first, then verified against the diff: unchanged
text still never pushes (`shelvingNeverCausesAPush` asserts the fake
server's `acceptedWriteCount` is untouched across a landing round AND a
following quiescent round); the duplicate-day pause, the fail-closed
canonical-user gate, and `applyBridgeLanding`'s insure-overwrite-commit
transaction are untouched by both changes — the shelving is a
`reading_post` insert that happens after the landing and cannot reach
the push classifier, since membership is not rendered text. The full
core suite (all bridge suites included) is green.

#### Deviations

- **None from the brief's method.** A1 was built from the architect's
  trace as instructed, with her store consulted read-only as
  corroboration; A2 was traced before anything was tuned, and the one
  thing the brief named as adjustable (the throttle) was left alone
  because the trace didn't justify it.
- **One scope addition, argued above:** A2's stale-label honesty fix.
  It is the observability half of the same report and it is what would
  have let her see the starvation herself.
- **One finding recorded rather than fixed:** the mobile capture door's
  identical missing half (A1 judgment call 3).
- **No lookup subagent used** — nothing external was needed.
- **P-6:** `TutorialWalkTests` green in the full Mac suite run.

#### Ladder foci suggested for this batch

Whether shelving on every writing landing can reach a state the three
narrowness pins miss (particularly a duplicate-day landing, where the
canonical entry is chosen by the notebook rule while the push half is
paused — the shelving follows `canonicalJournalEntry`, so it shelves the
*canonical* entry of a duplicated day); whether "any membership row,
live or tombstoned, means decided" has a `restoreContainer` /
`restoreReading` / sync-repair interaction worth stating (a cascade-
tombstoned membership that never revived reads as "removed"); whether
the note wording carries enough for her to act on without the plan file;
and whether `triggerLifecycleRound`'s "only when sync is unconfigured"
condition is the right discriminator versus, say, "when no sync round
has completed recently" (the chosen form is the one that cannot double-
trigger, which is why it is the one pinned).

#### ADDENDUM (architect-directed, same session) — the capture door joins the sweep

**The ruling:** fix the mobile capture door now, in this session, reusing
the helper — "the same class, adjacent, and now known", and the skill's
class-completeness rule sweeps a recurring class rather than leaving a
known instance to an audit. **Accepted, and the push-back on my two
"mitigations" was right — recorded because I had it wrong:** A1's rule 3
only fires on a landing that WRITES a day, and a phone-minted day she
never touches in Fragments produces a Variorum→Fragments **push and no
landing at all**. So nothing repaired it; it stayed bookless until she
happened to open ⌘J on that exact day. My report described the
mitigations as stronger than they are.

**ONE implementation, not two.** The rules moved into
**`Operations.shelveInDailyJournalBook(_:) -> DailyBookShelving`**
(`Operations+Container.swift`, directly beside `createOrOpenJournalEntry`
so the two halves are read together). It **never throws** — it returns
what happened, and each surface words it — which is what makes "never
block the mint or the landing" structural rather than a convention each
caller has to remember. The bridge's private copy is gone; it now
consults the shared helper and keeps only its own wording.

| Door | Shelves? | How it speaks |
|---|---|---|
| ⌘J / Today's Entry (`JournalBooks.openToday`) | yes, always did | its own inline version — **deliberately not converted**: it also CREATES and pins the book on first use, which is an act only a button press she pressed may take (QUESTIONS #37) |
| Fragments bridge landing (`BridgeEngine`) | **new (A1)** | the round's note surface → the status row's "needs attention" |
| Phone capture (`EntryListViewModel.open(on:)`) | **new (this addendum)** | `lastError`, worded to point at the Mac — the precedent is the capture surface's existing human notes ("This post is locked — unlock it on the Mac to edit") |
| `BookStructureModel.newEntry` daily branch | yes, always did | its own notes (unchanged) |

**The class sweep is now complete and bounded:** those four are every
door in the tree that mints or opens the day's entry
(`createOrOpenJournalEntry` has exactly these call sites plus tests).

**Judgment call — the phone's note rides `lastError`.** It is the only
message surface the capture list has, and it already carries human-worded
non-crash notes, so this is precedent rather than invention; the cost is
that a "your entry isn't in a book yet" line renders in the same red
caption as a real failure. A note-vs-error distinction on mobile would be
new UI, and this is a fix pass. Recorded for the Design & UI review row.

**Red-on-old evidence (behavioral revert, run both ways):** with the
door minting and stopping again, all three new mobile pins go red with
the traced shapes — `aPhoneCapturedEntryJoinsTheDailyJournalBook`
(`members → []`), `theCaptureMintIsNeverBlockedByShelving`
(`lastError → nil`), and `theCaptureDoorNeverReShelvesAnEntryTheAuthorRemoved`
(the removal setup throws `postNotInReading`, because nothing was ever
shelved to remove — recorded honestly rather than filed as the narrowness
pin I first labelled it). Restored and re-run green.

**Counts after the addendum:** core **848/98** · Mac **700/127** (both
re-run green after the hoist) · **mobile 11/4 → 14/4 — RUN, not
inferred**, on the iPhone 17 Pro simulator (26.2). That was the gap the
ruling named, and closing it also revealed nothing else: the whole mobile
suite is green.

**Nothing structural was needed** — no new dependency, no shared-code
move beyond hoisting the rules into the operations layer where both
callers already live, and zero `Sources/VariorumCore/Sync/` lines. The
stop-and-report condition never triggered.

### Batch 1F — the take-card gap (A47)

**Commits:** one commit — the fix, its pin, the widened soak invariant,
the A47 ledger update, and this record (no schema change, zero
`Sources/VariorumCore/` lines, zero `Sources/VariorumCore/Sync/` lines).
**Counts:** core **858/98 → 858/98** (unchanged — coherent by
construction, nothing under `Sources/` touched) · Mac **733/129 →
734/129** (one new pin) · mobile untouched.
**Diff scope:** 3 files — `App/Variorum/Variorum/Surface/PaneSurface.swift`
(the fix: ~30 lines, one hook + one coordinator method),
`VariorumTests/TakePaneMeasureTests.swift` (the pin),
`VariorumTests/TakesBoardSoakTests.swift` (the widened invariant).
**Her live instance:** untouched throughout — interrogated passively only
(a `screencapture -l` of her window, read-only `mode=ro` store and
`immutable=1` backup queries, `ps`). No Release build, no
`/Applications` refresh, no quit, no AX injection (declined
`AXManualAccessibility` — it mutates app state).

#### THE HEADLINE: the PERSISTENCE mechanism is traced and fixed; the birth event is honestly unidentified

Her card's frame was a **past, exact measurement that nothing could ever
correct**. The pane's height `@State` is written only from
`PaneMeasurement.height` — proven exact at every driven state — but every
remeasure TRIGGER was gated on a **change** (the width-gated layout hook;
`updateNSView`'s string-adopt and font-switch; `textDidChange`), and
`PanePublisher`'s heal re-schedules **only while the frame renders SHORT
of its measurement**. So a frame left TALLER than its text had no
correction path at all: no event short of a width change, a text change,
or a font switch would ever shrink it. That is her sentence — *"the large
open gap isn't going away when i click into other blocks"* — as
mechanism. What I could **not** pin is the birth: the one moment that
measured ~450 pt tall against the state the card now renders. It is
recorded below as unidentified, with every candidate quantified and the
kill for each; the fix is deliberately at the traced persistence
mechanism, where it also makes **any** birth self-heal within one layout
pass.

#### The defect, observed live (not only from her screenshot)

Her app was running (launched **10:12:43** today; PID 15640, a
real-store Release build out of DerivedData — never touched). A passive
window capture during this batch shows the A47 state still on screen:
the Takes stack article card for block 28/31 (`52B204DF…`, her ledger's
"52204DF" dropped the B), live ring on, showing the take's **last three
paragraphs** and then a **~450 ± 25 pt** empty region inside the card,
ending at the card's bottom border (void measured from the capture with
the scale calibrated against the card's known 676 pt width). The ledger's
"~60 visible words" are the tail of the SAME take — which resolves the
805w-vs-60 discrepancy the brief demanded: the status bar counts the
whole ~800-word take; the screenshot's words are the visible slice above
the void. Her post even contains her own diagnostic of the class, in a
block below the card: *"fix this damn whitespace bug that's happening
(scrolling up made it disappear, then typing at the end made it
reappear)"*. And decisively: **the void was on screen within ~60 seconds
of a fresh launch** — the `@State` is fresh per launch, so the birth is
launch-adjacent and RECURRING, not an ancient stale ghost.

#### The four hypotheses, in the brief's order

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| 1 | Stored trailing newlines (content, not a bug) | **REFUTED** | Read-only store: the take is 4,261 chars, **0 trailing newlines**, 50 internal (24 blank-line-separated paragraphs), ends `"…everywhere. "`. Unchanged since **July 24** in every rotating backup including today's 10:12 one — so no content explains the void and no store write was ever needed |
| 2 | A stale pane height across take/text switching | **The SWITCHING half refuted; the STALE-HEIGHT half is the defect's shape** | The block has exactly ONE live take (no switch exists); article `ForEach` identity is `placementID` (stable); the mode host `switch`es boards away (fresh `@State` per tab return). But the frame IS a stale past measurement — held terminal by the trigger gap, not by switching |
| 3 | TK2 estimated fragments inside the LIVE pane path | **REFUTED** | Live panes measure through the ONE brain (`PaneMeasurement`), and it is EXACT — delta 0.0 against a fragment-walk ground truth, zero estimated fragments after `ensureLayout` at pane scale — across mount, width reflows both directions, live typing, scroll away/back, and ring migration, in a standalone replica AND the real mounted `TakesBoardView` (VOID +0.0 at every step of both hunt drives, launch shape included). 1C's clean bill holds |
| 4 | `PanePublisher`'s one-directional heal on UPDATE paths | **REFUTED as the site; its one-directional TRIGGER SET confirmed as the persistence mechanism** | `runTurn` re-measures fresh unconditionally (1A ground 4 re-verified); text-change, live↔read flips and width changes all re-publish correctly in the real composition. But the heal chases only a SHORT frame, and no trigger fires without a width/string/font CHANGE — an over-tall frame is terminal. This is what "isn't going away" is |

#### The birth: unidentified, with the candidate table (her REAL text, read-only, measured at the pane's real 676 pt width, Study voice, comments off — the settings her store holds)

True height H(study g8, 676) = **2,304 pt**; the observed stale frame ≈
2,750–2,780. Candidates and their kills:

| Candidate | Δ vs true | Kill |
|---|---|---|
| Inline-comments gap swap (8→30, all 50 paragraph ends) | **+1,100** | Too big for the observed void; and no pane path re-attributes storage without remeasuring (the font-gated branch remeasures; adopt remeasures; a comments toggle without a font change re-attributes NOTHING on a pane — stale-but-consistent, no void) |
| Mono (launch-default typography) at 676 | **−310** | Wrong direction; the study-arrival font swap heals (driven in the launch-shape hunt: 1994 → 2502 exact) |
| Mono + comments at 676 | +790 | Off by ~2×, and same no-path argument |
| Window narrowing | n/a | The article pane is width-clamped ~676 for ANY window ≥ ~730 (verified in the harness: a 900-wide window still lays the pane at 676); her window is 1728 |
| A transient **~470 pt-wide** layout of the pane | **+462 — the arithmetic match** | No static Takes composition produces it at her window size; rapid width flips, the launch shape (mono-first + late Study + narrow-then-wide window) and scroll-driven realization were all driven in the REAL board and all converge (VOID +0.0). A first-render/restore transient width remains the honest suspect; it did not reproduce under anything I could drive |

Under the hallucination guard this stays a recorded unknown: **no fix
was built on any unconfirmed birth**. The shipped fix is at the traced
persistence mechanism and neutralizes every candidate equally.

#### What shipped — the BOTH-SIDES convergence law

`PaneTextView.layout()` gains a same-width branch: passes that did NOT
change the width run `reconvergeIfDiverged()` — one warm measurement of
already-laid-out pane-scale text; **publish only when the frame and the
measurement disagree beyond the existing `convergenceSlack`**. Loop-free
by construction: a corrective publish reframes the view to the
measurement, the next pass measures equal and stays silent; a width pass
keeps its existing unconditional remeasure, so no pass measures twice.
Composer-capped compositions (the rail's tall cards) never fire it —
their cap is a ScrollView AROUND the pane, so the pane's own bounds
still equal its measurement inside. P-3: the ONE surface component
extended, every composer inherits, no second measurement brain; all
writes still leave through the ONE publish door (the F1 walk is
untouched and green). Cost: one warm `ensureLayout`-over-laid-text +
`usageBounds` read per realized pane per same-width layout pass —
pane-scale (P1), the same cost class the width hook already pays per
width change. Her on-screen card heals at its first layout pass under
the fixed build (the end-of-phase refresh's moment, not this batch's).

#### Red-on-old evidence — by behavioral revert

| Revert applied | Pin | Observed RED |
|---|---|---|
| The same-width divergence branch removed from `layout()` (the pre-fix trigger set restored) | `aStaleTallPaneFrameReconvergesOnTheNextLayoutPass` | frame **546.0** held over **293.0** of text — a **253 pt** terminal void surviving `needsLayout` + settle passes, exactly the class (scaled to the pin's 12 paragraphs) |

Restored from the pre-revert copy and verified **byte-identical by
`shasum -c`**; the suite re-run green after restore. The pin's stale
state is constructed by a paragraph-spacing swap behind the coordinator's
back — **a labelled STAND-IN for the unidentified birth** (it reproduces
the stale STATE — frame measured tall, text rendering short, no trigger
left — not the birth event; the pin's doc comment says so in as many
words). The widened soak invariant (below) is a characterization-class
extension, not red-on-old: no soak action can produce the stale state,
which is itself informative — the birth is outside the soak's action
vocabulary.

#### The harness gap this class exposed (recorded for the reviewer)

`TakesBoardSoakTests`' height invariant was `bounds.height + 3 >=
measured` over READ panes only — **one-directional and blind to the live
pane**, so her defect (an over-tall frame on the ring-wearing card)
passed every soak by construction. It now asserts
`abs(bounds.height − measured) <= 3` for every article/card pane, live
included; the authority-mirror check stays read-pane-only (the live pane
is buffer-authoritative by design).

#### Numbered judgment calls / PROVISIONALs

1. **A class fix without the birth.** The persistence mechanism is fully
   traced (trigger enumeration + the one-directional heal + her live
   evidence); the birth is not. Fixing the persistence makes any birth
   self-heal within a pass. The alternative — keep hunting the birth
   before fixing anything — leaves her with a recurring launch-adjacent
   defect while the hunt continues against a transient that did not
   reproduce under two harness drives and a candidate table. Recorded
   as the deliberate call.
2. **The pin's stand-in construction** (judged above, labelled in the
   pin itself).
3. **Passive-only interrogation of her live instance** — screenshots and
   read-only queries; AX tree injection declined.
4. **The scratch hunt suite (`A47HuntTests`) was deleted after use**, as
   its own header promised; its negative results (every driven sequence
   converges, VOID +0.0 — including the launch shape: mono-first
   typography, late Study arrival, narrow-then-wide window, rapid
   unsettled width flips, scroll-driven realization) are recorded here,
   and the real-composition invariant now lives permanently in the
   widened soak instead.
5. **No QUESTIONS entry**: nothing product-flavored surfaced — the take's
   text is content exactly as stored (zero trailing newlines), and the
   fix changes no visible behavior except removing the defect.
6. **`805w take` vs a plain whitespace count of 817** on the same text:
   `TextMetrics.wordCount`'s rules vs `split()` — not load-bearing (the
   bar names the same take either way); noted so nobody chases it.

#### Deviations

- **None from the ordered method**: hypotheses pinned/refuted in order,
  store read first and read-only, trace before fix, red-on-old by
  behavioral revert with checksum restore.
- **No lookup subagent used** — every question was answerable by
  measurement or the repo, and was measured.
- **P-6:** `TutorialWalkTests` green in the full Mac suite run.

#### Ladder foci suggested for this batch (1F)

Whether the same-width divergence check can thrash in any composition
not considered (the termination argument: publish-on-divergence-only +
deterministic measurement for fixed (text, attrs, width) — a reviewer
should try to break it, e.g. under live window resize storms or a
composition that constrains the pane's own bounds rather than wrapping
it); whether measuring inside `layout()` on every same-width pass is
acceptable cost at the margin-grid's realized-pane counts (the width
hook precedent measures in `layout()` already); whether the stand-in pin
is acceptable evidence for this fix class or the reviewer can drive the
real birth (the launch-transient-width suspect: first-render width
before the restored frame applies — undriven here); and whether the
3 pt slack is the right both-sides tolerance.

### Batch 2A — OUTLINE becomes the book's writing surface (A39 · A6 · the rename)

**Commit:** one — `681851e` (the build, its pins, the ledger rows and this
record follow in the record commit). **No schema change; zero
`Sources/VariorumCore/` lines, therefore zero `Sources/VariorumCore/Sync/`
lines** — which is also why the core count is unchanged by construction
rather than by luck.
**Counts:** core **858/98 → 858/98** · Mac **734/129 → 741/130** (one new
suite, seven new tests) · mobile **builds clean** (`xcodebuild build
-scheme VariorumMobile`), 14/4 untouched.
**Diff scope:** 8 files — `BookStructureModel.swift` (the mode rename),
`BookView.swift` (the picker, the inset removal, the writing surface, the
row extraction), `BookViewModel.swift` (expanded → COLLAPSED set),
`EditorTypography.swift` (+`inlineSurfaceInset`), `EditorTextView.swift`
and `PaneSurface.swift` (that literal's two other homes),
`BookViewTests.swift` / `BookStructureTests.swift` (the pins).
**Her instance:** `pgrep` at batch open showed her Release build live
(PID 15640, DerivedData path) — never touched, never quit; no Release
build, no `/Applications` refresh from this batch. It had exited by the
suite run. *(The orchestrator's pinned mid-phase refresh landed in
parallel at `e5c3a80` and deliberately excludes this batch — correct: 2A
is unadjudicated until the end-of-phase review.)*

#### THE HEADLINE: the pre-bound architecture held, and the work that was left was the LOOK

A39's ledger row pre-bound four things (adopt the one-live-ring contract ·
join `commitTake` + register a `.commit` handler · collapse is view state ·
virtualize per P3). Reading the code first, **three of the four were
already true and one had never been named**, and that changes what this
batch is: not "wire a new editable surface" but "make an already-editable
surface look and behave like the place a book gets written."

- **The one-live-ring contract:** Outline's live surface is
  `EditorView(inline: true)` — the FULL-DOCUMENT editor, which the
  constitution's own application note says is never absorbed into the pane
  surface. Its liveness authority is `BookViewModel.focusedPostID`, a
  single optional, which 13b 3E installed as this surface's one focus
  authority when it folded `BookFocusState` away. There was no second
  mechanism to avoid adding, and adding a `PaneTextAuthority` beside it
  would have BEEN the second mechanism.
- **`commitTake` + a `.commit` handler:** both already reached, through the
  registry's `writeEditorAttached` arm (`takeFamily`'s first line) and
  `EditorView.handleRouted`'s `case .commit`. Unnamed, though — the
  attached-editor context existed only as an unlabelled row in the
  registry walk's context list. It is now named by two pins (below), so a
  future narrowing of `takeFamily` fails on Outline's behalf.
- **Collapse as view state, never TK2 folding:** already true; preserved
  exactly, and the inversion did not go near the editor.
- **Virtualization:** the `LazyVStack` was there, but the counter pin was
  NOT, and the default flip is what makes it matter (below).

Stated plainly because it is the kind of claim a reviewer should distrust:
**nothing here earned Stage 4 lesson 2 by writing new code; it earned it by
proving the surface already satisfies it.**

#### What shipped

**1 — the picker: `Outline · Book · Read`.** `ViewMode` renamed
`.book → .outline` and `.pages → .spread`; `defaultMode` follows (a working
book opens into Outline, a finished one still into Read — R2 untouched).
Both cases moved out of the collision deliberately (judgment call 1).

**2 — Outline's bottom inset, gone entirely (A6).** The `Slider` and the
`ProgressView` both, as she ruled. The `.onScrollVisibilityChange`
reporting that fed the bar went with it — it cost work per realized row for
a face that is no longer drawn (P1 hygiene). The model's `noteVisible` /
`progressPosition` / `readingProgress` brains STAY: pure, pinned, and both
2B (Book keeps its bottom bar) and 2C (Read's paginated sub-mode keeps
one) will want them. A comment in the model says so, so they don't read as
dead code. **Her instruction is carried in the code comment**: if the bar
ever returns, the bugginess she saw is investigated FIRST.

**3 — Outline as the writing surface.**
- **Write's own measure.** The column was 760pt, which put 744pt of prose
  on screen — **64pt wider than Write's 680**. It is now
  `EditorTypography.maxColumnWidth + 2 × inlineSurfaceInset`, so the text
  lands on exactly Write's measure. `inlineSurfaceInset` is a NEW named
  constant in the typography home, replacing a literal `8` that lived in
  three places (`makeInlineEditor`, `makeReadSurface`, and the arithmetic
  a composer has to do) — the drift this batch would otherwise have added
  a fourth copy to. Left-anchoring is untouched (batch 12's ruling).
- **Chapter headings read as headings** — the title face, accented, 28pt of
  air above, the drag handle quietened to `small`/`faint`. Same for the
  smart-book tag-path headers and the "unfiled" group, so the three
  sectioning stories look like one thing.
- **The post heading recedes**: title at `heading`, and both doors (▾ and
  "open ↗") demoted from `.primary` to `.quiet`. A loud button on every
  post is catalog chrome; this is a page.
- **Posts read OPEN by default** — the model now tracks the **COLLAPSED**
  set (judgment call 2 and PROVISIONAL 1).
- **`OutlinePostRow` extracted** from four inline builders, so the row has
  an `init` the materialization counter can ride (the `ReadingFlowView`
  precedent) — P-9's split rides along, and `BookView` shed ~100 lines of
  row rendering.

#### Traced: why the COLLAPSED set rather than seeding the expanded one

Inverting the set is not cosmetic. With an EXPANDED set, "open by default"
needs a rule about who seeds arrivals — and arrivals are ordinary here: the
"+ new post in this book" door mints one, a tag pulls one into a smart
book, sync lands one. Every such rule has a silent-miss class (the seeding
site that nobody updated), which is the shape of the bug this app keeps
finding. Tracking the collapsed side makes the default hold with **no
seeding site at all**: a post nobody collapsed is open because it is not in
the set. Pinned directly (`aPostThatArrivesAfterCollapseAllIsOpen`): after a
collapse-all, a post added to the book arrives OPEN while the deliberate
collapse survives on the others.

#### Red-on-old evidence — stated plainly as red-on-old vs characterization

**This is a FEATURE batch: no bug was fixed, so no pin is owed under the
hallucination guard.** Three pins are nonetheless RED on the pre-2A code
and were verified by behavioral revert, each restored byte-identical by
`shasum -c`; three are characterization and say so.

| Pin | Class | Revert applied | Observed RED |
|---|---|---|---|
| `outlineProseSitsOnWritesOwnMeasure` | **red-on-old** | column back to `760` | prose measured **744.0 pt** vs Write's 680 — off by 64 at every realized surface |
| `outlineVirtualizesItsRowsWithPostsOpenByDefault` | **red-on-old** | `LazyVStack` → `VStack` | **452 row materializations** on a 150-post book's first layout (bound is 75) |
| `outlineCarriesNoBottomChrome` | **red-on-old** | the `safeAreaInset` restored | 1 `NSSlider` + 1 `NSProgressIndicator` back in the hierarchy |
| `aPostThatArrivesAfterCollapseAllIsOpen` | **red-on-old by construction** (the old default was collapsed; the assertion is the flipped semantics) | — | not separately driven |
| `aMountedOutlineConsumesTheCommitCommand` | **characterization** | — | passes on the pre-2A code too — Outline already mounted the editor. It names Stage 4 lesson 2's behavioral half so a future change has to break a test to break it |
| `outlineJoinsCommitTakeAndTheTakeFamilysAvailability` | **characterization** | — | same: the availability arm already held; this names it |
| `theBookOpensIntoOutlineAndTheModesAreOutlineBookRead` | **rename** | — | does not compile on the old code (that is the rename's point) |

#### The visual loop (P-7)

A throwaway capture suite rendered Outline into a real 1280×900 window and
was **deleted after use** (the 1F precedent), its findings here: both
states read right — open, the book is chapter headings and prose in a
bounded column with quiet per-post chrome; collapsed, batch 12's card view
returns exactly. Two observations recorded, neither acted on:
**(i)** a stored blank line inside a post renders as real vertical space in
Outline (the 2026-07-12 spacing ruling, visible and correct — worth knowing
before 2C paginates the same text); **(ii)** on SHORT posts the collapsed
card is nearly as tall as the open post, so collapsing buys little there —
a taste item, routed to the **Design & UI review** row, not fixed.
*(Sandbox note for future visual loops: the test host cannot write to the
scratchpad — `NSTemporaryDirectory()` lands in
`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/`, and the file is
copied out from there.)*

#### Numbered judgment calls / PROVISIONALs

1. **The `ViewMode` cases renamed OUT of the collision** (`.book →
   .outline`, `.pages → .spread`) rather than shifting `.book` onto the new
   meaning. Alternatives: (a) shift `.book` to name the spread and add
   `.outline` — matches the picker exactly, but every stale `.book` in a
   rebased branch, a revert, or a future session's reading of an older
   batch record compiles **silently against the wrong surface**; (b) change
   labels only and keep `.book`/`.pages` — the code then says the opposite
   of the UI for the whole of 2B. Chosen: rename both, so a stale reference
   is a compile error. Cost: the enum says `.spread` where the picker says
   "Book" — carried in a doc comment on the case.
2. **Outline opens with posts OPEN — PROVISIONAL, QUESTIONS #43(a). This
   reverses R106 for this surface**, and it is the one thing in the batch
   that contradicts a recorded ruling of hers, so it is flagged rather than
   buried: batch 12's *"you shouldn't see the content within a post on the
   book screen unless you click something"* was ruled when this was a book
   *screen*. Grounds for flipping it here: her own A39 word is
   *"collapsible"*; *"literally looks like write mode"* is not a page of
   cards; and the batch brief says outright *"build it as the place she
   writes a book, not as a decorated list."* Her card design is untouched
   and one "collapse all" away — which is the cheapness that made
   PROVISIONAL-and-continue the right posture rather than stalling.
3. **Collapse state stays session/view-scoped, not persisted** — QUESTIONS
   #43(b). Persisting it per book is a `lens`-flavored design question
   ("is a folded book a saved way of looking?") and inventing it would be
   product behavior.
4. **A collapsed post keeps batch 12's CARD unchanged** — QUESTIONS #43(c).
   The one-line folded heading (or the `tocHandle` first-sentence rule)
   was considered and not taken: it discards a design she reacted well to.
5. **`chromeLabel` left ON the chapter heading**, so terminal voice still
   lowercases her chapter names. It reads oddly for authored text in a
   prose column, but the terminal idiom is R1's and app-wide, and changing
   it is an unforced taste call. Recorded, not taken — a Design & UI review
   item if it bothers her.
6. **The progress/scrub BRAINS kept** though Outline no longer calls them
   (the alternative — delete them — would delete work 2B and 2C need, and
   she ruled out the FACE, not the arithmetic).
7. **`BookView.init(initiallyExpanded:)` kept** as an explicit un-collapse
   seed. It is now a no-op for posts nobody collapsed; it still says
   exactly what it does, and every existing caller compiles and passes
   unmodified.

#### Deviations

- **None from the brief's three items or their order.** Item 3's binding
  list was verified item by item against the code before building, which
  is what turned the batch from wiring into looks (the headline).
- **No lookup subagent used** — nothing external was in question.
- **P-6:** `TutorialWalkTests` green inside the full Mac run (741/130).
- **P-1:** nothing new is declared, and nothing new needed declaring — the
  acts this surface offers are either already-routed (they reach it through
  the attached editor) or surface-local under Stage 4 lesson 10 (the mode
  picker, the collapse chevrons, expand/collapse-all, the chapter doors).
  The registry walk is green unchanged.

#### Ladder foci suggested for this batch (2A)

**(1) The R106 reversal is the thing to argue with** — judgment call 2 is a
deliberate contradiction of a recorded author ruling, made under the
autonomy grant. A reviewer should test whether the grounds hold or whether
this should have been held for her. **(2) The `.spread` naming**: does a
third vocabulary (picker "Book" / enum `.spread` / her prose "two-up
spread") cost more than the collision it avoids — and check that no
reference to the old `.book`/`.pages` meaning survives anywhere in prose
records that a future session would read as code. **(3) The measure claim**:
`outlineProseSitsOnWritesOwnMeasure` asserts within 2 pt off the REALIZED
read surfaces — check it would still bite if the live inline editor (not
the read tier) diverged, since the pin walks `ReadPostTextView` only.
**(4) The materialization bound (75 of 150)** — is it tight enough to catch
a partial regression, given 452 was the unvirtualized number? **(5) The
kept brains**: `noteVisible` now has no caller in the app; confirm that is
recorded rather than rotting, and that 2B/2C actually pick it up.
**(6) Arrivals**: `collapseAll` snapshots `entries`, so a post arriving
afterwards is open — pinned as intended behavior, but a reviewer should
decide whether "collapse all" ought to mean "and stay collapsed."

### Batch 2B — BOOK: the two-up spread, editable (A43 · A44)

**Commit:** one — `89219a3` (the build, its pins, the suite reorganization;
the ledger rows, QUESTIONS #44 and this record follow in the record commit).
**No schema change; zero `Sources/VariorumCore/` lines, therefore zero
`Sources/VariorumCore/Sync/` lines** — which is why the core count is
unchanged by construction rather than by luck.
**Counts:** core **858/98 → 858/98** · Mac **741/130 → 745/131** (one new
suite; +6 tests in it, −2 retired from the old paged suite) · mobile
**builds clean** (`xcodebuild build -scheme VariorumMobile`), 14/4 untouched.
**Diff scope:** 10 files + one rename — `PagedBookView.swift` →
`SpreadBookView.swift` (rewritten), `BookViewModel.swift` (the spread
brain), `BookView.swift` (the `.spread` branch + the navigator's spread
doors), `Capability.swift` / `CapabilityRegistry.swift` /
`CommandRouter.swift` / `TakesBoardView.swift` (the availability half),
`BookViewTests.swift` / `CapabilityRegistryTests.swift` /
`TutorialWalkTests.swift`.
**Her instance:** `pgrep` clean at batch open and throughout — no Release
build, no `/Applications` refresh, nothing quit. The login session read
LOCKED (`CGSSessionScreenIsLocked` = 1) and the Mac runner nonetheless ran
normally, hosted-window suites included — recorded because Stage 4 lesson 9
predicts a pre-connection hang under lock and it did **not** materialize
here (probed with a control suite first rather than assumed either way).

#### THE HEADLINE: "one live editor" stopped being a slogan here, and that decided the architecture

A44 asks for two editing forms on a two-up spread, which reads as "make both
pages editable." Built naively that is: each page mounts its own form. Traced
before building, that shape breaks two things at once, and neither is
cosmetic:

- **Two `PaneTextAuthority` owners.** The one-live-ring invariant is
  structural *inside* one authority (`livePane` is a single optional — 4C
  extended it across post CONTEXTS precisely so one authority could span
  several posts). Two mounted `TakesBoardView`s own two `TakesViewModel`s and
  therefore two authorities, and nothing in the app would prevent two live
  rings. That is the batch-14 two-rings defect class, re-opened by
  composition.
- **Two routed-command handlers.** `CommandRouter.dispatch` walks handlers
  **LIFO — last mounted wins**. With two boards up, ⌘S and every take act
  would reach whichever board SwiftUI happened to mount last, not the one
  under her hands. The N5/D3 class, delivered by geometry.

So the spread does what every other surface in the app does and reuses the
**existing** authority: `BookViewModel.focusedPostID`, the book surface's
single focus authority since 13b 3E folded `BookFocusState` away — the same
one Outline uses. ONE page is active; it mounts the chosen form; its sibling
renders `ReadPostView` and upgrades on click, which is how the ring migrates
between the pages. **Each page is editable; only one is editable at a time**,
and that is P3's letter rather than a compromise with it. It is also what
makes two whole posts affordable at once.

Stated plainly because it is the claim a reviewer should attack: **no new
liveness mechanism was added, and the alternative was rejected on a traced
mechanism, not on taste.** Both halves are pinned — the ring migration
behaviorally, and the two-boards shape by the revert that produces two live
editors.

#### What shipped

**1 — the two-up spread.** `HStack { left · spine · right }`; each page is a
whole post inside its own `ScrollView`, capped at `BookView.proseColumn`
(Write's measure) and never flowing into its neighbour. Book paginates by
**post**; Read paginates by **text** — the distinction is now in the file
header where 2C will read it.

**2 — the flip family, as ruled.** `◀ ▶` **turn the leaf** (two posts at
once — the DEFAULT), `◁ ▷` **nudge by one** (her *"half arrow button or
something"*), arrows too. ONE enablement rule behind all four:
`BookViewModel.canMove(by:leftIndex:count:)` — *a move that reveals no post
you cannot already see is refused*. That is what makes the last leaf honest:
from pages 4–5 of 5 there is no live "next" that re-shows page 5.

**3 — the blank leaf.** An odd book (or a nudge onto the last post) shows one
page and a quiet "end of the book", never a post wrapped round from the other
end. A one-post book turns nowhere, both directions.

**4 — the bottom bar KEPT, the slider GONE.** Flip controls, a text page line
("pages 3–4 of 40 — <left> · <right>") read straight off `spreadLeftIndex`,
and the form picker. Deliberately TEXT and not a `ProgressView`: she ruled
the book's progress bar out for now, and a spread whose position is exactly
known does not need one to say where it is. The slider's removal is the
brief's instruction and sits against her own S4-9(2) ask — flagged to her as
QUESTIONS #44(c) rather than quietly executed; nothing was lost, since the
navigator's post list performs the same model-driven jump.

**5 — the two editing forms (A44).** The active page mounts either
`TakesBoardView` (the takes stack, which brings its own scrolling and its own
bottom bar, so it is never wrapped in the page's `ScrollView`) or the inline
full-document `EditorView`. One spread-level control in the bar, PROVISIONAL
(#44(a)).

**6 — the availability half of Stage 4 lesson 2, which the spread exposed as
a genuine gap.** The Write form inherits `commitTake` through the
attached-editor arm — 2A's proof, unchanged. The TAKES form did **not**:
`takeFamily` reads `ctx.mode == .takes`, and `activeMode` is nil in a book
(no `PostDetailView` is mounted), so the whole take family — ⌘S included —
would have greyed out over a mounted, fully working board whose handler was
registered. Traced, not assumed, and verified RED. **`mode == .takes` was
only ever a PROXY for "a takes board is mounted"**, and the proxy stopped
being true the moment a board could mount outside a post detail. The fix
reports the truth the registry actually needs: `CapabilityContext.
takesBoardAttached`, wired exactly like `writeEditorAttached`, set by the
board itself in the `onAppear`/`onDisappear` it already had. Token-SET rather
than a flag, for the reason `registerDetail` uses tokens: an arriving board's
`onAppear` can precede the departing one's `onDisappear`.

**7 — renamed out of the collision** (2A's discipline, same reason):
`pagedIndex` → `spreadLeftIndex`, `currentPage` → `leftPage`/`rightPage`,
`openPage`/`flipPage`/`seedPageFromFocus` → `openSpread`/`turnLeaf`/
`nudgeSpread`/`showPost`/`seedSpreadFromFocus`, `PagedBookView` →
`SpreadBookView`. Every one of those names changed MEANING (from "the page"
to "the left page of the spread"), so a stale reference is now a compile
error rather than a silent mismeaning — which is exactly what it did: the
first build after the model change failed on the two stale call sites and on
nothing else.

#### Traced: why focus is released on a turn but KEPT on a nudge

The old rule was "flipping away from a live page releases focus", which was
unambiguous when a page was the only page. On a spread it has to be stated
against the SPREAD: focus is released when the focused post is no longer one
of the two visible pages. The consequence is the right one and worth naming —
**a nudge that carries your live page along keeps your caret** (that is the
whole point of the nudge: re-pair without losing your place), while a turn
that leaves it behind releases it and the editor's teardown flushes pending
text through the per-post coordinator, exactly as before. Pinned both ways.

#### Red-on-old evidence — stated plainly as red-on-old vs characterization

**This is a FEATURE batch: no bug was fixed, so no pin is owed under the
hallucination guard.** Four of the six pins are nonetheless RED on an
alternative implementation and were verified by **behavioral revert**, each
restored byte-identical by `shasum -c` (three source files checksummed before
the first revert and re-verified after every restore); the rest are
characterization and say so.

| Pin | Class | Revert applied | Observed RED |
|---|---|---|---|
| `theSpreadRealizesTwoPagesNotTheBook` | **red-on-old** | the two-page `HStack` → `ForEach(model.entries)` | **60 read surfaces** on a 60-post book (bound is 2); the page-materialization counter and the content assertions fail with it |
| `theRingMigratesBetweenPagesAndOnlyOnePageIsEverLive` | **red-on-old** | `isActive` → `true` (the naive "both pages editable" architecture) | **2 live editors**, 0 read surfaces — the exact P3 violation the architecture exists to prevent |
| `theSpreadKeepsItsBarWithFormsAndNoSlider` | **red-on-old** | 4F's `Slider` restored into the bar | **1 `NSSlider`** back in the hierarchy |
| `bothSpreadFormsJoinTheTakeFamilysAvailability` | **red-on-old** | `\|\| ctx.takesBoardAttached` removed from `takeFamily` | `commitTake` → **`.unavailable`** in the takes-form context, and five more family acts with it |
| `aMountedSpreadConsumesTheCommitCommandInEitherForm` | **red-on-old** (same revert) | as above | `CapabilityRegistry.isEnabled(.commitTake, …)` **false** over a board that was attached and consuming ⌘S — the N5 shape exactly: the act works, the door is grey |
| `theSpreadBrainPairsTurnsNudgesAndClamps` | **characterization** | — | new behavior; it states the pairing/turn/nudge/refusal rules so a future change has to break a test to break them |

#### The visual loop (P-7)

A throwaway capture suite rendered the spread into a real 1500×900 window and
was **deleted after use** (the 1F/2A precedent). It read right: two titled
pages either side of a spine, the flip family greying correctly at the covers,
the page line centred, the form picker at the trailing end; the takes form
mounts the real board — style/wash/expand-all header, the live ring, the fan
badge, "+ new block", its own bottom bar — with the facing page still calm
prose; the last leaf shows one page and "end of the book". Three observations
recorded, none acted on:
**(i)** with the takes form up, the board's own bottom bar sits directly above
the spread's flip bar — legible, but two bars deep; a **Design & UI review**
item, not a defect.
**(ii)** `TakesBottomBar`'s "newlines make blocks: on" capsule **clips its
label** at half-window width — pre-existing chrome (the `b6dae25` lineLimit
class's cousin), newly reachable because 2B is the first surface to put the
board in a half-width container. Deliberately NOT fixed here: it is the Takes
tab's chrome, touching its layout risks every takes surface, and the honest
owner is the **Design & UI review** row. Named as a ladder focus so the
reviewer sees it was seen.
**(iii)** a page whose post carries a fan measures slightly narrower than one
that doesn't (the read tier's badge gutter) — pre-existing `ReadPostView`
behavior, visible for the first time because two pages now sit side by side
for comparison.
*(Sandbox note, unchanged from 2A: the test host cannot write to the
scratchpad — `NSTemporaryDirectory()` lands in
`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/`, and the files are
copied out from there.)*

#### Numbered judgment calls / PROVISIONALs

1. **ONE spread-level Write | Takes control, in the bottom bar —
   PROVISIONAL, QUESTIONS #44(a).** Her sentence is *"the editing forms
   offered in the … view"*, so the view offers them. Alternatives recorded
   with what each would change: **per page** (a control in each page header —
   costs a second control and begs "what does Takes mean on the page that
   isn't active"); **per post**, reusing `PostDetailView.rememberedMode` — the
   most attractive alternative, since a post would then present the same way
   everywhere, but a click in the book would quietly rewrite how that post
   opens in its own editor, which she did not ask for; **global** `@AppStorage`
   across books. Not persisted, matching the collapse-state call (#43(b)).
2. **Only the ACTIVE page mounts an editing form.** The headline's finding.
   The alternative (both pages live) needs one authority shared across two
   boards plus routing that knows which board a command means — a real build,
   named for her at #44(b) rather than assumed unwanted.
3. **The jump slider removed — the brief's instruction, flagged because it
   sits against her own S4-9(2) ask.** #44(c) carries both sentences and the
   ~15-line road back; `scrubIndex` is kept and still pinned.
4. **Arrows are CONDITIONAL key equivalents** — withdrawn entirely while a
   page holds the live editor. A permanent `◀`/`▶` equivalent is checked
   before the responder chain and would steal arrow keys from her typing;
   `.onKeyPress` was the other candidate and needs `.focusable()` on the
   container, which risks the live editor's first-responder handoff for no
   gain. ⌥←/⌥→ nudge on the same condition (⌃⌘← and ⌥⌘← are both already
   taken by the take/fan pagers). #44(d).
5. **`showPost` never re-shuffles a spread that already shows the post** —
   jumping to what you are reading must not move the pairing you are looking
   at. Otherwise the requested post takes the LEFT page.
6. **A blank leaf, never a wrapped page**, and the enablement rule that goes
   with it ("a move that reveals nothing is refused"). The alternative —
   clamping the left index so the last spread is always full — was rejected:
   it makes the last turn land on a pairing she did not ask for.
7. **The page line is TEXT, not a `ProgressView`.** She ruled the book's
   progress bar out ("it seems a bit buggy… remove it fully for now") and a
   spread knows its position exactly.
8. **`takesBoardAttached` added to the registry context rather than the
   spread registering itself as a post DETAIL.** The detail route was
   genuinely attractive — it would have given `.actElsewhere(.write)`
   fire-and-DO for structural gestures in the takes form for free — but
   `registerDetail` also claims `activePostID`/`activeMode`, which the sidebar
   rail reads as "the mounted post detail", and `requestMode` would then hand
   the spread modes it cannot host. Reporting the one fact the registry needs
   was the smaller and truer change. **Consequence, recorded rather than
   hidden:** in the takes form, structural gestures (divide/extract/merge)
   read `.unavailable` rather than `.actElsewhere(.write)`, because the
   spread has no mode-switch choreography to offer — the honest road is the
   form picker or "open ↗". Same family as QUESTIONS #41 (A9's deferral).
9. **The progress/visibility brain (`noteVisible`) is still uncalled**, and
   2A's record asked whether 2B would adopt it. It should not: the spread's
   position is exact, so reporting per-row visibility would be work for an
   answer already known. Recorded in the model so 2C decides deliberately —
   if Read's flow sub-mode does not adopt it, it has no caller and should be
   deleted there.

#### Deviations

- **None from the brief.** Every ruled item built as written (page = whole
  post, turn-the-leaf default + one-post nudge, arrows, bottom bar kept, no
  horizontal scrollbar, both forms, one live ring, P3 realization,
  model-driven navigation).
- **No lookup subagent used** — nothing external was in question.
- **P-6:** `TutorialWalkTests` green inside the full Mac run (745/131); its
  paged walk was updated to the spread vocabulary (same promises: the domain
  reaches the last page, the last cover clamps, the navigator jumps), and it
  gained one assertion — the last leaf's blank half.
- **P-1:** nothing new is declared, and nothing new needed declaring. The
  spread's own affordances (flip controls, the form picker) are surface-local
  under Stage 4 lesson 10; the acts its pages offer are already-routed and
  reach them through the mounted form. What DID change is a declared act's
  availability *rule*, which is the registry's own data — the walk is green
  unchanged, and its sampled context space gained the new axis.

#### Ladder foci suggested for this batch (2B)

**(1) The one-active-page architecture is the thing to argue with** —
judgment call 2 and the headline. A reviewer should test whether "both pages
editable at once" is really blocked by the two mechanisms named (authority
ownership; handler LIFO) or whether a cheaper shape exists, and whether the
shipped behavior satisfies A44's letter. **(2) `takesBoardAttached`** — is
adding a context axis right, or should the spread have registered as a detail
(judgment call 8)? Check especially the consequence: structural gestures are
`.unavailable` in the takes form, where in a post detail they would be
`.actElsewhere(.write)`. **(3) The attachment's lifecycle** — the token SET
is meant to survive SwiftUI's mount-before-unmount ordering; try to make
`takesBoardAttached` stick true after every board is gone, or false while one
is up. **(4) The conditional arrow shortcuts** (judgment call 4) — verify a
key equivalent really is withdrawn the instant a page goes live, and that
nothing else in `BookView` (the navigator) wanted arrows. **(5) The slider
removal** (#44(c)) — is the navigator genuinely an equal jump door for a
40-post book? **(6) The takes board inside a HALF-WIDTH container**: the
visual loop found `TakesBottomBar`'s density pill clipping there, and the
board's internal 680 pt article measure plus its margin rail were designed
for a full window — worth a look at what else compresses badly. **(7) The
retired paged suite**: check that nothing the old
`thePagedViewRealizesExactlyOnePageAndFlipsContent` guarded went unguarded —
its successors are the two hosted spread pins.

### Batch 2C — READ: true pagination (C1, the uniform-page brief)

**Commits:** two builds — `211a942` (the CORE half: `Queries.blockExtents` +
its three pins) and `e955708` (the app half: the domain, the paginator, the
surface, its fifteen pins, the tutorial's prose + walk act); the ledger row,
QUESTIONS #45 and this record follow in the record commit.
**No schema change** — the extent index is DERIVED (the brief §5's option
(a)), so AppSpec §4's stored-`length_estimate` door stays closed and unbuilt.
**Zero `Sources/VariorumCore/Sync/` lines.**
**Counts:** core **858/98 → 861/99** (+3 tests, +1 suite) · Mac **745/131 →
760/134** (+15 tests, +3 suites) · mobile **builds clean**
(`xcodebuild build -scheme VariorumMobile`), 14/4 untouched.
**Diff scope:** 5 new files — `Sources/VariorumCore/Queries/PageExtents.swift`,
`Features/BookView/PageDomain.swift` / `PagePaginator.swift` /
`PagedReadModel.swift` / `PagedReadView.swift` — plus
`BookStructureModel.swift` (the `ReadForm` pair), `BookView.swift` (the Read
branch, the sub-toggle, the navigator's paginated jumps, the structure
injection), `TutorialSeeder.swift` + `TutorialWalkTests.swift` (P-6), and two
new test files.
**Her instance:** `pgrep -fl 'Variorum.app/Contents/MacOS'` clean at batch
open and re-checked before every suite run — no Release build, no
`/Applications` refresh, nothing quit. The login session was UNLOCKED
throughout (2B's recorded exception to Stage 4 lesson 9 was not needed).

#### THE HEADLINE: the brief's two tiers are safe to mix only if a page is not a number — and that is the one thing the brief did not say

The brief §3 gives the architecture (estimated globally, measured locally)
and §9 asks for a pin that "estimate→exact convergence never regresses a
visited page". Building it surfaced *why* that property is hard, and the
answer changed the design:

**If the reader's position is a page NUMBER, the two tiers cannot coexist.**
A global page number is a prefix sum over every post before her. Correct one
post's estimate anywhere earlier and her number now points at different text
— the page reflows under her eyes, which is precisely the failure the brief
warns about ("page seams would visibly lie").

So the reader's position is an **ADDRESS — (post, page-within-post)** — and
the global number is a *label* computed from the domain for display. A
measurement moves the label; the address is untouched, so the page under her
is the same page. That is the Phase 6 spike's accepted height story
("estimates revise, content never regresses") expressed in a page domain, and
it is pinned directly (`aCorrectionMovesTheLabelAndNeverThePage`).

Two consequences follow from the address rule rather than from taste, and
both are recorded as calls rather than smuggled:

1. **Every post starts a new page** (judgment call 1 / #45(b)) — which is
   what makes an address stable at all. The brief leaned the other way.
2. **The post the reader is IN is always the post that has been sliced**, so
   it is measured (or floored past her page) and can never be re-estimated
   out from under her. The pin says so in the same test.

#### The measurement that decided the architecture (and refuted my own first build)

The batch's first build paginated a post fully on arrival and adopted the
exact count. The suite's cost test said 22 pages in **109 ms** and getting
worse per page — so I measured properly, in a throwaway harness, both shapes:

| one post | pages | paginate ALL | one frame deep in it |
|---|---|---|---|
| 2,438 chars, real paragraphs | 3 | 0.1 ms | 0.02 ms |
| 39,038 chars, real paragraphs | 46 | 0.9 ms | 0.02 ms |
| 156,158 chars (26k words), real paragraphs | 183 | **3.5 ms** | 0.02 ms |
| 37,760 chars as ONE unbroken paragraph | 22 | **105 ms** | 7.7 ms |
| 151,040 chars as ONE unbroken paragraph | 92 | **1,668 ms** | 31 ms |

**CoreText typesets per PARAGRAPH.** Ordinary Variorum prose is many
paragraphs — every block is its own (R26/R33) and the join puts `"\n\n"`
between them — so whole-post pagination is milliseconds even at book scale.
The pathological case is ONE enormous block, which is exactly the shape her
A3/A41 report came from (a long message pasted in one piece): every frame
inside a giant paragraph re-typesets that paragraph from its start, and the
cost goes quadratic.

So slicing is **LAZY** — a post is cut only as far as the reader has walked,
plus the one page of lookahead a turn needs — and a post's page count becomes
EXACT only when slicing reaches its end. Until then the domain carries the
estimate plus a **floor** (pages slicing has already found), which is what
keeps the "never regresses" contract under laziness. Both the flat shape and
the climbing one are asserted structurally (not as timing thresholds) and
printed on every run: `paginationCostIsParagraphShapedAndPrintsItsNumbers`.

*Recorded because it is a real limit, not a solved problem:* a 25k-word
single-block post still costs ~30 ms per deep page turn inside that block.
Bounded by the block, paid only for pages she actually turns to, and
un-improvable without leaving CoreText.

#### The 1C cross-check, answered explicitly (the batch brief asked for this)

1C measured TK2's estimated geometry OVER-reporting by 367 pt on one
3,000-word block (4,964 pt guessed vs 4,597 laid out), and the brief asked
what my estimator does when a block's layout state flips from estimated to
laid-out. **The honest answer is that it cannot flip, because this surface
never enters that path:**

- the estimated tier's inputs are **character counts out of SQLite**
  (`Queries.blockExtents`, lengths computed in SQL — no prose crosses the
  boundary and no layout engine is consulted);
- the exact tier is **CoreText**, which lays out synchronously and completely
  for the range it is handed; `CTFrameGetVisibleStringRange` is a measured
  fact, not a guess;
- **there is no NSTextView on a paginated page at all** — a page is a drawn
  `CTFrame` — so there is no `NSTextLayoutFragment.state` to be wrong, no
  canary to arm, and no phantom space to inherit. Pinned:
  `readCarriesNoTextViewAtAll`.

What DOES flip here is this domain's own estimate → measurement, and the
address rule above is what bounds its blast radius to the page label.

#### What shipped

**1 — Read is a PAIR.** `BookStructureModel.ReadForm { flow, pages }`, with a
`scroll | pages` control under the mode picker (it is in the navigator, not a
bottom bar, because the SCROLL face has no bottom chrome at all — A6's
argument). `.flow` stays the default so R2's "a finished book opens into the
reading flow" means what it has always meant.

**2 — the estimated tier.** `Queries.blockExtents` (core, own commit) returns
one row per live block — container, block, characters, internal newlines —
with the take resolution MIRRORING `renderPost` exactly, so the estimator and
a rendered page can never disagree about *which* takes are on the page. Its
agreement with `renderedText` is pinned arithmetically. `PageEstimator` models
**paragraphs**, not characters: a block is its own paragraph, its newlines are
content (I4), and each paragraph ends ragged — which is why a post of twenty
short blocks is much taller than one block of the same characters (pinned at
line level and at page level).

**3 — the page domain.** `PageIndex`: one entry per post, `estimated` /
`measured` / `floor`, prefix-summed into page numbers, with `advance`,
`next`, `position(atPageNumber:)` and `clamped` as its whole vocabulary.
Calibration is a running correction learned from measured posts — **and only
from posts of two pages or more**, because a short post's count is dominated
by the one-page floor and reports a ratio that says nothing (a book of
one-paragraph journal entries would otherwise drag the constant to nonsense).
Bounded to [0.5, 2.0] so one pathological post cannot wreck the domain.

**4 — the exact tier.** `PageComposer` builds a post for the page: the body is
the ratified projection and nothing else (`renderPost` slots, blank takes and
gaps skipped, `joinRenderedTexts` — the ONE join brain), so **stored spacing
reaches the page exactly as it reaches export**, which the reading flow's
paragraph-splitting deliberately does not do (2A's visual loop flagged that
this batch would meet it). `PagePaginator` slices with the 11b PDF exporter's
proven CoreText loop.

**5 — the surface.** A two-page spread of fixed logical leaves (470×660,
46 pt margins) with paper, shadow, a folio, the post's title on its first
page and a chapter opener where a chapter begins. A window resize SCALES the
paper (the scale is applied to the drawing CTM, so text stays vector-crisp);
it never repaginates. The bottom bar keeps ◀ ▶ (a leaf is two pages), the
brief §4's SCRUBBER over the estimated domain, and a page line that wears a
**"~"** while any post is still a guess (R112's honesty rule applied to a
number — it drops the tilde when the whole book has been read).

**6 — arrows are UNCONDITIONAL here**, and that is a direct dividend of her
A43 ruling: 2B had to withdraw ← → while a page held the live editor
(QUESTIONS #44(d)); Read has no editor to steal keys from.

**7 — the navigator jumps PAGES without leaving Read.** A post row (and a
chapter row) in paginated Read lands that post's first page rather than
throwing her into Outline's editor — the 4F no-context-jump rule (R43)
applied to a surface that did not exist when it was written.

**8 — the field guide's books lesson, repaired.** Its "three views" paragraph
still described the PRE-2A vocabulary (BOOK = the scroll, PAGES = one post
per page, a progress bar A6 removed) — stale for two batches, and P-6 says the
lesson is the spec. It now teaches OUTLINE · BOOK · READ with both Read faces,
and the walk gained an act that drives `PagedReadModel` over the guide itself.
The walk's assertions are **equivalent-or-stronger** (the 2B precedent): one
stale `"progress bar"` claim became five vocabulary claims plus the new act.
*(The seeded book in her store stays stale until the A1-railed re-seed — the
13b handoff's standing item.)*

#### Traced: why the composer records block ranges even though pagination does not need them

A callout's indent must land on exactly the characters the callout block
contributes, and the body is built by a join with a conditional (the
2026-07-12 rule). Re-deriving those ranges from the finished string would
mean re-implementing the join's condition a second time — the exact drift
class `joinRenderedTexts` exists to prevent. So the composer walks the slots
ONCE, emitting the string and the ranges together, and a pin asserts the
emitted body equals `Queries.renderedText` byte for byte. One walk, one
answer, no second join brain.

#### Red-on-old evidence — stated plainly as red-on-old vs characterization

**This is a FEATURE batch: no bug was fixed, so no pin is owed under the
hallucination guard.** Three pins are nonetheless RED on an alternative
implementation and were verified by behavioral revert (each file restored
byte-identical, `shasum -c`); the rest are characterization and say so. One
row records a defect the pins found in MY OWN first build.

| Pin | Class | Revert applied | Observed RED |
|---|---|---|---|
| `thePaginatedReadRealizesTheSpreadNotTheBook` | **red-on-old** | the two-leaf `ForEach(pages.leaves)` → `ForEach(model.entries)` (the naive "draw the book" shape) | **60 `PageFrameNSView`s** on a 60-post book (bound is 2), and the materialization counter fails with it |
| `readCarriesNoTextViewAtAll` | **red-on-old** | the leaf's `PageFrameView` → `ReadPostView` (the "reuse the read tier" alternative the brief's Q3 offered) | **2 `ReadPostTextView`s** and an `NSTextView` count of **2** where the assertion is 0 — the A43 ruling broken by composition (and `PageFrameNSView` falls to 0, so the realization pin fails with it) |
| `openingABookSlicesTheSpreadNotThePost` | **red-on-old** | `realize` calling `paginator.pageCount()` (my own first build) | the first post sliced to **11 pages** on open where the bound is 3, and all three of the test's claims fail — the 1.67 s shape, caught by a pin rather than by her |
| `aCorrectionMovesTheLabelAndNeverThePage` | **characterization** | — | new behavior; it states the address rule so a future change to page addressing has to break a test to break it |
| `theEstimatorCountsParagraphsNotOnlyCharacters` · `aBlockLongerThanAPageContributesSeveralPages` · `onlyRealPostsCalibrateAndAMeasurementIsFinal` · `theDomainWalksAcrossPostsAndDiesAtTheCovers` | **characterization** | — | the estimator and domain rules, pinned as arithmetic |
| `thePagesCoverThePostExactlyOnceInOrder` | **characterization** | — | the exact tier's correctness statement: page k starts where page k−1 ended, no gap, no overlap, the last page ends at the post's end |
| `theComposedBodyIsTheRatifiedProjection` · `aCalloutIsIndentedWithoutAnyCharacterChanging` | **characterization** | — | the page shows `renderedText` and only that; the callout treatment changes no character |
| `theBarKeepsItsScrubberAndSpeaksApproximately` · `theLeafTurnsTwoPagesAndTheCoversAreDead` | **characterization** | — | the bar's controls and the domain walk through the real surface |
| `paginationCostIsParagraphShapedAndPrintsItsNumbers` | **measurement** | — | asserts the SHAPE (flat vs climbing per-page cost), never a timing threshold; prints both tables on every run (the 1C precedent) |
| core: `extentsResolveTheSameTakeARenderedPageWould` · `aTombstonedBlockReadsAsZeroRatherThanVanishing` · `severalPostsComeBackGroupedAndOrdered` | **characterization** | — | the extent index agrees with `renderPost`/`renderedText` about what a post contains |

**All three reverts were EXECUTED, not reasoned about** (each file
checksummed before, reverted, run, restored, `shasum -c` verified), and the
execution corrected this table: two of the three RED numbers I first wrote
here were estimates rather than measurements — `readCarriesNoTextViewAtAll`
reads **2**, not 6, and `openingABookSlicesTheSpreadNotThePost` reads **11**,
not 40. Recorded rather than quietly amended, because a red-on-old table
whose numbers were guessed is exactly the hollow-pin class the hallucination
guard exists to catch.

**Two pins caught real defects in this batch's own code before any suite ran
them in anger** — the eager-pagination row above, and the estimator's
paragraph model, whose first test run showed two page-level assertions
failing because the ceil hid the difference at 20 lines/page. The second was
a TEST scale error, not a model error, and is recorded as such: the claim now
sits at line level, where the model actually lives, and again at a page scale
where she would see it.

#### The visual loop (P-7)

A throwaway capture suite rendered the whole book view (navigator included,
light and dark) into a real 1500×950 window and was **deleted after use**
(the 1F/2A/2B precedent). It read right: two leaves of paper with a spine of
room between them, the chapter opener letterspaced above the post title, the
body in the reading serif, folios centred in the bottom margin, the last leaf
of the book blank with "end of the book", and ▶ correctly dead there. **The
seam works** — page 1 ends mid-sentence ("…the way it always does") and page 2
opens with its continuation ("here, without ceremony…"), which is the whole
promise of the view, visible.

Two things the loop changed: the bar's slider was **bounded to 460 pt** with a
spacer before the page line (it had stretched to fill and jammed the label
against the trailing edge), and the mode-seeding order in the capture itself
exposed that `BookView` owns its `BookStructureModel` — which is why the
**structure injection** shipped (the same seam `model:` already had).

Three observations recorded, none acted on:
**(i)** a post's LAST page leaves white space below it — that is judgment
call 1 made visible, and it is exactly what #45(b) asks her about;
**(ii)** in light, paper (#FFFDF6) and room are close enough that the page
edge is carried by its shadow alone — a **Design & UI review** item;
**(iii)** the callout's indent reads clearly as a set-in passage; the missing
colour is noted for her in #45's closing paragraph rather than invented.
*(Sandbox note, unchanged from 2A/2B: the test host cannot write to the
scratchpad — `NSTemporaryDirectory()` lands in
`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/`, copied out from
there.)*

#### Numbered judgment calls / PROVISIONALs

1. **Every post starts a new page; text flows across pages WITHIN a post —
   PROVISIONAL, QUESTIONS #45(b), and it deliberately contradicts the brief's
   own lean.** The headline has the argument: with posts flowing, a
   correction to any earlier estimate reflows every page after it, including
   the one she is reading, and the only honest alternative is measuring the
   whole chapter before showing page one (the P1-banned shape). Anchoring at
   posts makes an address stable by construction. **What the alternative
   would change:** the page count drops (short entries stop occupying whole
   pages), the white space at a post's end disappears, and either the reader
   accepts pages reflowing under her or the view accepts a full-book
   measurement pass at open. Not a flag — a different build.
2. **PAGES is a second FACE of Read, not a fourth tab (brief Q1) — and it is
   named "Pages".** Alternatives recorded in #45(a) with what each changes: a
   fourth top-level segment (four modes in the rail; and it would say the pair
   is two unrelated views), or the sub-toggle in the paginated bottom bar
   (which the SCROLL face does not have, so the door would vanish where it is
   needed). The NAME is hers; the brief floated "Print", "Book pages",
   "Spread".
3. **The page is drawn by CoreText, not by a read-tier TK2 view (brief Q3).**
   The brief leaned TK2-read-tier and said to decline only if page-slicing
   fights it. It does fight it, in a way worth naming: a page must show
   EXACTLY the range pagination assigned it, and asking a second layout
   engine to re-wrap that range is two chances to disagree about where a line
   breaks — the disagreement's shape is text visibly clipped or doubled at a
   seam. With CoreText, **the break and the drawing are the same
   computation.** It also keeps TK2's estimated geometry out of the surface
   entirely (the 1C cross-check) and costs a frame per page instead of an
   NSTextView. **What it costs:** selection and copy on the page. Read's other
   face has never offered them either (its `Text` rows are not selectable), so
   the pair is consistent; the roads to the text are the editing surfaces and
   export.
4. **A callout renders as an INDENTED passage, not a coloured frame** — a
   deviation from the brief §7's lean, recorded in #45's closing paragraph.
   A coloured frame is an overlay treatment and this surface has no overlay
   layer by design (see 3). The indent is a paragraph-style transform that
   changes no character, which is the same *class* of transform as export's
   blockquote mapping (that one adds `"> "`, this one adds nothing) — and
   neither touches `renderedText`. Splitting across a page boundary is free
   with an indent, where a frame would have needed the brief's "keep callouts
   whole" special case.
5. **The scrubber stays (brief §4), against 2B's removal on Book** — flagged
   as #45(c) rather than harmonised by guess, because the two briefs said
   opposite things and her Outline complaint applies to neither surface. One
   rule for both is one line of hers.
6. **No one-page NUDGE control** (Book has ◁ ▷ by her ruling). A nudge exists
   there to re-pair two POSTS that a leaf-turn split; a text spread has no
   pairing to fix — the pages are a continuous window over one post's prose.
   Recorded rather than skipped silently; the scrubber can land any page if
   she wants odd/even control.
7. **The page bears the POST's title on its first page, and a chapter opener
   where a chapter begins.** Not in the brief. Reason: every post starting a
   page makes a book of untitled leaves hard to place, and a printed book
   labels its sections. Cost: the estimator must know the chrome's height or
   every short post is estimated wrong — so `PageComposer.headingLines` is the
   single source both sides read, which is stated in its doc comment.
8. **Calibration learns only from posts of ≥ 2 pages.** A one-page post's
   count is the floor, not a measurement; letting it teach would drag the
   constant toward nonsense on exactly her corpus shape (many short journal
   entries). Bounded to [0.5, 2.0] besides.
9. **A `PagePaginator` cache of 4 posts, evicted by recency.** The domain
   keeps every MEASUREMENT (they live in `PageIndex`, not the cache), so
   eviction costs a re-slice and never a re-guess — which is why reading a
   12-post book and coming back leaves the total exact.
10. **`BookView` gained a `structure:` injection**, mirroring `model:`. Needed
    because the structure model seeds its own view mode from the first
    observed reading row, so a hosted test (and the visual loop) cannot drive
    the mode from outside without it. Defaulted, so every existing call site
    compiles unchanged.
11. **The extent index is DERIVED, not stored (brief §5's option (a)).** AppSpec
    §4's escape hatch says "stored per-block length estimates"; this is that
    number, read. Building the column would owe a §12 lockstep event and a
    maintenance path for a need nothing has demonstrated — the measurement says
    reading lengths is free. Recorded so the door stays visibly closed rather
    than forgotten.

#### Deviations

- **From the brief: two, both named above and both in QUESTIONS #45** —
  judgment call 1 (post page-breaks, against §7's lean, on a P1/stability
  argument) and judgment call 4 (callouts indented rather than framed, a
  consequence of Q3's answer). Everything else built as the brief specifies:
  two tiers, the estimated scrub domain, spread-only lazy realization, the
  bottom bar kept, `renderedText` semantics, no badges, no comments, the
  fixed-page/scale-not-repaginate posture, the empty-book leaf.
- **From the batch brief: none.** Read is not editable; the domain rides the
  post list and stored lengths; the 1C cross-check is answered explicitly in
  its own section.
- **No lookup subagent used** — every open question was answerable by
  measurement on this machine, and the two that mattered were (the CoreText
  cost shapes).
- **P-6:** `TutorialWalkTests` green inside the full Mac run (760/134), with
  the books lesson's stale prose repaired and a new walk act over the
  paginated domain; assertions equivalent-or-stronger.
- **P-1:** nothing new is declared, and nothing new needed declaring. The
  surface's affordances — the `scroll | pages` toggle, the flip controls, the
  scrubber — are surface-local under Stage 4 lesson 10, and Read routes no
  acts at all (it is not an editing surface). The registry walk is green
  unchanged.

#### Ladder foci suggested for this batch (2C)

**(1) Judgment call 1 is the thing to argue with** — a reviewer should test
whether posts-flow really costs what the headline claims, or whether a
bounded incremental scheme (measure forward from a chapter anchor, cache the
frontier) gets both. **(2) The address rule** — try to find a path where a
re-estimate DOES move the page under the reader: a book whose membership
changes while she reads (`adopt` re-entering), a post edited under her, a
scrub landing inside a post whose measurement then comes in shorter.
**(3) The lazy-slicing bound** — `slice(through:)` plus the caller's one-page
lookahead is a two-place contract; check it cannot be walked into slicing a
whole post (especially `realize`'s 3-turn loop and `pageCount()`, which is
deliberately off the reading path but is still public). **(4) The paginator
cache** — 4 posts, evicted by recency, and the pins read `realizedPostCount`;
check that eviction while a leaf is on screen cannot leave a leaf drawing a
stale or nil frame. **(5) The composer's ranges vs the join** — the callout
indent lands on ranges the composer computes with a duplicated copy of
`joinRenderedTexts`' conditional; the body-equality pin covers the STRING,
but a reviewer should decide whether the range walk should be folded into
core beside the join instead. **(6) `PageFrameNSView.draw`** — a scaled CTM
plus a folio drawn outside the frame's path; check the folio cannot collide
with body text at small scales, and that `isOpaque = false` plus the SwiftUI
paper underneath is really the right split. **(7) The unconditional arrow
shortcuts** — verify nothing else in `BookView` (the navigator's rows) wanted
← →, and that switching from Read to Book hands the keys back to 2B's
conditional pair cleanly. **(8) The tutorial prose repair** — it corrects
2A/2B's staleness, so check the whole paragraph against what those batches
actually shipped, not only against 2C.

### Batch 2D — the smart→curated conversion (C2 · N38) + book order as a lens (A31)

**Commits:** two — `2569784` (core: the operation, its two undo halves, the
read-time order override; the model-change convention honored — core in its
own commit) and `f9cf009` (the faces, the pins, one pre-existing defect
fixed). The ledger rows, QUESTIONS #46, and this record follow in the record
commit.
**Counts:** core **861/99 → 881/100** (+20, one new suite) · Mac **760/134 →
772/135** (+12, one new suite) · mobile **14/4 untouched, `xcodebuild build
-scheme VariorumMobile` clean**. `TutorialBookShapeTests` + `TutorialDoorTests`
green (P-6). **No schema change; zero `Sources/VariorumCore/Sync/` lines.**
**Her instance:** `pgrep -fl 'Variorum.app/Contents/MacOS'` clean at batch
open and at every suite run — no Release build, no `/Applications` refresh
from this batch.

#### THE HEADLINE: the memo's shape A needed no schema, and only ONE of its three dead ends was still dead

Two findings decided what this batch is.

**1 — Shape A really is free of schema, and I checked rather than trusted
it.** A smart book's membership is derived; a chapter assignment lives on
`reading_post.section_id`; so chaptering a smart book is impossible *because
there is no row to hold the pointer*. Materializing the current results and
flipping `kind` (already a CHECK-legal value) turns the book into an ordinary
curated book, at which point chapters, hand order, the capacity gate, finish
and `restoreReading` all work because they already worked. Nothing new had to
be taught to any consumer. That is what made A the right shape to build in
her absence: shapes B and C are not one-line reversals, and A is.

**2 — the memo named THREE refusals that should become offers, and by the
time this batch ran, two of them had better answers already.**

- *Direct add* — R98 (`collectPostIntoSmartReading`, Sitting 9 batch 10)
  already accepts a post onto a smart book **by applying the filter's tags**
  and reporting what it did. That is a better answer than converting the
  whole book, so the drag-onto-a-smart-book gesture is deliberately
  untouched. Converting there would have been a regression.
- *Reorder* — a smart book's order is `sort_field`, and A31's own face now
  makes it choosable on every book. No dead end left.
- *Chapters* — genuinely dead, for the structural reason above. So exactly
  one door became an offer, and it is the one the memo's §3 leaned on.

Stated because a reviewer reading the memo would expect three and find one.

#### What shipped — the operation

`convertSmartReadingToCurated(_:keepCollecting:collectingName:)`, ONE
transaction:

- refuses a non-smart book (`wrongReadingKind(expected: .smart)`) and a
  FINISHED one (`lockedReading` — converting is a structural act on a book
  declared done; un-finish first, the bucket every sibling reading op uses);
- materializes `Queries.assembleReading`'s CURRENT answer — the book's own
  assembly, never a second ordering brain — into `reading_post` rows at
  `.end`, so the fractional positions come from the one position helper;
- flips `kind` to curated and `sort_field` to **manual**, so nothing moves on
  screen at the moment of conversion;
- leaves `query_spec` and `grouping_tag_id` on the row. The spec is
  provenance (and is what makes the collector offer still possible later);
  the grouping tag is not decoration — **curated assembly already honors a
  grouping tag whenever the book has no live chapters**, so her tag-derived
  sections survive the conversion intact and hand over to real chapters at
  the moment she creates one (`chaptersActive`'s shipped precedence). Pinned
  both ways. No new rule was needed for the memo's "what happens to derived
  sections" question — the shipped precedence already answers it;
- optionally mints the fresh collector: same filter, same sectioning tag,
  same order the book had — and deliberately **not** `max_posts`,
  `word_target`, or `locked` (a collector born capped or finished cannot
  collect, which is the one thing it exists to do);
- **skips posts that already carry a live membership row.** No ordinary door
  can produce one on a smart reading, but undo can: its inverse tombstones
  only what IT minted, so a hand-added row survives — and a second conversion
  would otherwise throw on `uq_reading_post_live`. Cheap, and it makes
  convert → undo → hand-add → convert a legal sequence (pinned).

**Undo AND redo, exact-row on do-time ids** (the 1B contract). The inverse
tombstones precisely the minted memberships, buries the collector, and
restores `kind` + the stored sort pair; the re-apply un-tombstones the same
rows with `restoreReading`'s live-parent guard (a member post that died
stays out) and re-applies the flip. `redo:` is passed, not defaulted.

#### What shipped — A31, and which half already existed

**The attribute half already existed and had no reachable door.**
`reading.sort_field` (manual / entry_date / created_at / last_touched /
last_major_revision, each direction) and `setReadingSort` have shipped since
Phase 2. Their ONLY face was `ReadingsSection` — the Phase 10 SIDEBAR
section — which Phase 13's Shelf · Library · Pool · Blocks rework left
unreferenced. It has been dead code ever since, which means **the shipped app
has had no way at all to change a book's order**. That is most of why A31
reads as a missing feature. The dead view is deleted; its choice list lives on
verbatim as `BookOrderChoices` (pinned verbatim), and its door is now the
book navigator's `order ·` menu.

**The "saved like lenses" half is the lens grammar, literally.**
`Queries.ReadingOrder` + `assembleReading(order:)` / `observeReading(order:)`:
picking an order is a way of LOOKING — view-local on `BookViewModel.viewOrder`,
writes nothing, and export / the Fragments projection / another device all
still see the book's own order. "Save as This Book's Order" is the adopt door.
This is not an analogy stretched to fit: the 11a ratification is that *a lens
is never rendering truth*, and a browsing order that silently changed what
export writes would violate it.

Three details worth naming:

- **The override is applied at the one point the stored pair would have been
  read**, so `assembleReading(order: X)` is byte-identical to
  `setReadingSort(X)` then `assembleReading()` — pinned across five orders,
  because "browsing shows what saving would show" is the whole promise of a
  preview, and two code paths agreeing by inspection is how that promise
  quietly stops being true.
- **It belongs in the QUERY, not in a post-fetch re-sort**, because the window
  is applied by the query: sorting delivered rows would sort the first N of
  the OLD order. Pinned with a 5-post book windowed to 2.
- **Chapters keep governing** under an override, exactly as they do under a
  stored stamp sort — one rule, not two. Pinned.

`BookView` drives it with `.task(id: model.viewOrder)`, so changing the way
she looks restarts the observation rather than re-sorting what arrived.

#### The pre-existing defect this batch's visual loop found (fixed, red-on-old)

**Every row in the book navigator was losing its first character**, on every
book, since 2A. Traced rather than guessed:

1. Captured the navigator — "entry 0" read "ntry 0", the smart-book notice
   started mid-word, the order menu read "rder ·".
2. Captured again with **this batch's own control removed**: identical. So it
   is pre-existing, not mine (`00-without-order-control.png`).
3. Measured it with temporary borders on the padded content box vs the
   `.frame(width: 190)` box (`04-borders.png`): the content's ideal width is
   **~209 pt**. `.frame(width:)` does not clip — it **centers** an over-wide
   child — so the whole column drew ~9.5 pt left of the window edge.
4. The floor is the segmented mode picker's own minimum, which grew when 2A
   renamed the modes `Outline · Book · Read`. `.frame(maxWidth: .infinity)`
   was tried first and did **nothing** (an HStack still reports its child's
   ideal width upward); `.controlSize(.small)` brings the row under the
   column without touching the column's intended width, and the content box
   then sits inside the frame box exactly (`05-controlsize.png`).

This is the b6dae25 chrome-sizing class, which P-8 carries as standing law.
Fixed rather than routed to the Design & UI review row (2B's density-pill
precedent) because that precedent covered a *taste* question about a control's
look, and a column that clips its own text is not taste — and because this
batch adds a row to that column.

**The pin is on the rendered PIXELS**, deliberately: the clipped elements are
SwiftUI `Text` with no `NSView` to interrogate, and a first attempt asserting
on the `NSSegmentedControl`'s frame **passed on the pre-fix code** — the
picker's own origin was positive; it was the text that went negative. That
false pin was discarded rather than kept. `leftmostInkX` scans the navigator's
band for the first pixel materially darker than its chrome.

| Pin | Class | Revert applied | Observed RED |
|---|---|---|---|
| `theNavigatorsChromeStaysInsideItsColumn` | **red-on-old** | `.controlSize(.small)` removed | ink at **0.0 pt** (assertion: ≥ 6) — the column's text drawn flush at the window edge |
| everything else in both suites | **structural** | — | neither `convertSmartReadingToCurated` nor `Queries.ReadingOrder` existed before this batch; the suites do not compile against the pre-2D tree |

The revert was executed, observed RED, restored, and the file verified
byte-identical by `shasum -c`.

#### The visual loop (P-7)

A throwaway capture suite rendered the smart-book navigator and the offer
sheet into real windows and was **deleted after use** (the 1F/2A/2B/2C
precedent); its captures are in the gitignored
`notes/plans/phase-13c-2d-screens/`. Findings: the navigator defect above
(the loop's whole justification — it had shipped through 2A's own visual
pass), and the offer sheet reading correctly — the "why", the concrete
promise ("Its current 4 posts stay, in the order you're looking at them"),
the collector toggle with the default name as placeholder, and buttons that
say what they do ("Convert & Add Chapter" when the chapter door opened it).
The sheet is system-chromed, matching its siblings (`BookSettingsSheet`,
`BookExtentSheet`, `SmartSpecSheet`).

#### Numbered judgment calls / PROVISIONALs (all on the ratify list, QUESTIONS #46)

1. **Shape A over B/C** — the memo's recommendation, built whole. The
   alternative that matters is B (the hybrid), and its knot is recorded in her
   entry in her terms: a post pinned by chaptering whose tag is then removed
   has no non-surprising answer.
2. **The collector offer is CHECKED by default.** Her sentence asks for it;
   defaulting off would make the common case a thing to remember.
3. **The collector carries the filter, sectioning tag and order, but not the
   extents or the finish state.** Traced: a cap or a finish on a fresh
   collector contradicts collecting.
4. **"+ new chapter" renders on a smart book and opens the offer** (the
   memo's Q3 lean, the R115 grammar). The alternative — leave it absent and
   keep conversion to the shelf menu only — is one `if`.
5. **The displayed order is frozen to manual** (Q4's lean), and the **cap is
   honored** at materialization, so a converted book is never born over its
   own capacity.
6. **No curated → smart door** (Q5's lean). Undo/redo cover the accident; a
   fresh collector is the honest road back.
7. **Conversion registers a structural undo entry**, unlike
   `addPostToReading`'s class which deliberately registers nothing. It mints
   N rows, changes what a book IS, and may mint a second book — and there is
   no reverse door. The alternative is "no undo entry (the recovery door is
   the recovery)", which would leave no recovery door at all here.
8. **A31's saved half is view-local + one save door.** Several NAMED saved
   orders per book — the fuller lens reading — needs stored order profiles,
   i.e. a SyncSpec §12 lockstep event. **Deliberately NOT taken**, per the
   batch's own instruction; recorded for her.
9. **`wrongReadingKind`'s message is now direction-aware.** It stated the
   curated direction only, which read as nonsense on the conversion door's
   refusal. Latent before this batch (only `collectPostIntoSmartReading`
   could produce the smart direction, and only in a race).

#### Deviations

- **`ReadingsSection` deleted.** Unreferenced since Phase 13's IA rework;
  removing it is what makes the A31 finding legible rather than a claim. Its
  two sheets (`ManageReadingPostsSheet`, `SmartSpecSheet`) are still presented
  by the shelf and are untouched.
- **One pre-existing defect fixed** rather than routed (justified above).
- **The member count in the offer is a one-shot derived read**
  (`SmartConversionCount.collected`), not the shelf's `postCount`, which
  counts membership rows and is therefore **0 for every smart book** — the
  sheet would have promised "0 posts stay" every time it was shown. Pinned.
  It runs the book's own assembly so the promised number IS the number of rows
  minted, by construction; the `bookWordCounts` cost tier (a deliberate press,
  never a held observation).

#### Ladder foci suggested for this batch (2D)

1. **Re-derive the "grouping tag survives conversion" claim cold.** It is the
   batch's cheapest-looking decision and the one carrying the most inherited
   behavior: it relies on curated assembly honoring `grouping_tag_id` while a
   book has no live chapters, and on chapters winning afterwards. Both are
   pre-2D rules; if either reading is wrong, converted books lose their
   sections silently.
2. **Try to break the undo/redo pair against a moving world.** The inverse
   refuses under a re-finished book and skips dead rows; the re-apply skips a
   membership whose post died and any pair that already has a live row. Look
   for a sequence that leaves a conversion half-undone, or that trips
   `uq_reading_post_live`.
3. **Check that the view-local order really cannot leak into truth** —
   export, `renderedText`, the Fragments projection, `bulkExportManifest`,
   and the paged-read/spread surfaces all read `model.entries`, which now
   reflects an override. The claim is that nothing PERSISTED changes; verify
   there is no path where a browsing order is written or exported.
4. **The `.controlSize(.small)` fix is a geometry change on a shipped
   surface.** Confirm the picker still reads correctly at the voices' other
   font settings, and that no other navigator row is near the 166 pt content
   budget.
5. **The offer's two doors and the R98 non-door.** Confirm that leaving the
   drag-onto-a-smart-book gesture alone is right, and that no third surface
   still dead-ends on a smart book.

### Batch 2E — Compare: "show related blocks only" (C4) — the 4C kin-less-peer PROVISIONAL MOOTED, not re-ruled; core untouched at 881/100, Mac 772/135 → **780/135**

**Her request, verbatim (2026-07-22):** *"we should have a setting to only
show related blocks - that would make the pane feel more usable."*

**What shipped (one commit + this record's):**

- **`e8f13ee`** — `CompareComposition.relatedOnly` (the pure filter) ·
  `CompareViewModel.relatedOnly` + `Display` (the one per-pass
  computation) + `releaseLivePaneIfFilteredAway` · the third header chip,
  the whole-board honesty state, the per-column note · the tutorial
  lesson's fifth paragraph and its walk assertion · 8 new pins.

**Zero core lines, zero schema, zero `Sources/VariorumCore/Sync/` lines**
(`git diff --stat -- Sources/VariorumCore/Sync/` empty; core suite
unchanged at 881/100 by execution, which is the honest proof there was
no core allowance and none was used). Mobile: **BUILD SUCCEEDED**.

#### THE SHAPE: a pre-pass, so `segments` is byte-unchanged

The filter is **not** a parameter on `CompareComposition.segments` and
deliberately so. `relatedOnly(anchorBlocks:peerBlocks:kinships:)` is a
PURE pre-pass over *exactly the inputs `segments` already takes*, and the
view model composes the two. Consequences that paid for themselves:

- **Every 4C honesty pin stands untouched** — the eight
  `CompareCompositionTests` pins that encode N29's rule, the flush
  asymmetry (MINOR-B), and the kin-less-peer placement (MINOR-C) run
  byte-identical against byte-identical code. A phase that changes the
  honesty brain to add a filter would have had to re-prove all of it.
- **The composition needs no filter knowledge.** Because every survivor
  is kin by construction, `segments` then emits *nothing but aligned
  rows* — the free stretches ARE the unrelated material, which is the
  clean statement of what the filter does.

#### "Related" — the PROVISIONAL the brief named, and the argument that decided it

**Chosen: BLOCK-LEVEL TRANSITIVE LINEAGE — the SAME notion the rails and
the alignment already use** (`Queries.blockKinship`: the
ancestors/descendants CTE, nearest kin wins, depth-bounded at 32). The
brief flagged this as "the alignment machinery's existing answer is the
cheapest defensible one"; it is also the *only* self-consistent one, and
that argument is stronger than cheapness:

- `railKin` reads `projection.kinship`. `CompareComposition` reads the
  same map. **A filter on a NARROWER rule (direct `derived_from` /
  `version_of` edges only) would hide blocks that are visibly wearing a
  rail**, and a wider one would show blocks with no rail — the surface
  would contradict itself inside one glance. ONE kinship brain, or the
  rails and the filter have to be narrowed together, which is a bigger
  and unrequested change.
- Recorded alternative, live for her: direct-only, with the rails
  narrowed to match. QUESTIONS #47(a).

**The post-level `version_of` link is NOT block relatedness** (#47(b)):
it says *these posts are versions*, never WHICH blocks correspond. So a
version-linked, lineage-less peer filters to nothing — and because its
header already says "versions", an unannotated empty column there would
be exactly the emptiness-as-content failure N29 forbids. Hence the
per-column note (below).

#### The 4C kin-less-peer PROVISIONAL: MOOTED, and the OFF side deliberately untouched

13b's judgment call 0 (ladder round 3, MINOR-C) left a peer with NO
kinship trailing every aligned row, so against a long fully-kin anchor
that column reads blank for that many rows. **With the filter ON the
unrelated peer contributes nothing at all, so the question of where its
run lands does not arise** — pinned on the exact configuration that
PROVISIONAL's own pin uses
(`relatedOnlyDropsTheKinLessPeerEntirelyAndMootsThePlacement` vs
`aPeerWithNoKinshipAtAllTrailsEveryAlignedRow`, same inputs, both green).

**The filter-OFF placement is byte-for-byte unchanged.** The brief's aim
was "the outcome where the setting makes the placement question moot",
and she asked for a *setting*, not a different placement; changing both
at once would have spent a ruling she never made. 4C's options (b) and
(c) stay one arm away each and are recorded in #47 as still-live if the
OFF behavior bothers her in use. The site doc at
`CompareComposition.segments` now carries this resolution beside the
original PROVISIONAL rather than replacing it.

#### N29's honesty line — COMPOSED at two scales, never broken

| Situation | What the board does |
|---|---|
| Filter ON, **nothing** related anywhere | The rows area is replaced by `nothingRelatedState`: **"there is no relationship here"** (her words, the existing vocabulary) + *"…is on, and lineage connects nothing across these posts — so there is nothing to show. Turn it off to read them side by side."* The way out is named. |
| Filter ON, **mixed** (one column related, another not) | The unrelated column's header adds **"related blocks only — nothing from this post"** with the help text naming the escape. This is also what catches the version-linked-but-lineage-less peer. |
| Filter ON, everything related (a version twin) | Nothing changes — every block is kin. The filter costs the related comparison nothing, pinned. |

The per-column note is **suppressed** when the whole board is empty (the
board-level line says it once, properly) — three surfaces speaking the
same fact at once is its own dishonesty.

#### The live-ring call (the binding concern the brief named)

**Decision: the toggle acts and the ring is RELEASED — never a refusal.**
Turning the filter on can hide the block the live pane sits in. The
governing precedent is **4C's own NIT-1** (a closed column hosting the
live pane): the ring must never stay on a pane nothing renders. So
`releaseLivePaneIfFilteredAway` blurs, flushes **that pane's own post's**
coordinator (the cross-context handback's rule), and **SPEAKS**.

- **Why not refuse the toggle while a pane is live** ("close the block
  you're writing in first"): that is lecture-and-redirect by another name
  (P-2, R115), and it would refuse most often exactly when she is deepest
  in a comparison. A view toggle that stops working because you happen to
  be typing is the friction this phase exists to remove.
- **Why it speaks:** a caret disappearing without a word is the
  silent-door class 13b retired.
- **Why the flush is load-bearing and not politeness:** REVERT C below
  shows the store still holding `"Nothing to do with it."` while the
  typed text sat in a buffer no surface rendered. Without the release the
  text is not lost forever (the session-scoped coordinator still flushes
  eventually) but it is invisible and unreachable meanwhile — and the
  filter is precisely a gesture she'd make mid-comparison.
- **Scoped to the TOGGLE, deliberately.** A projection change can also
  hide the live pane's block (a block deleted in another window). That is
  the **pre-existing 4C class, unguarded today**, and calling the release
  per observation delivery would both cost a filter pass per delivery and
  invent a new way for the ring to drop mid-typing. Recorded, not
  widened — a ladder focus below.

#### Numbered judgment calls / PROVISIONALs (all on the #47 ratify list)

1. **"Related" = transitive block lineage, the alignment's own notion**
   (PROVISIONAL — #47(a)). The self-consistency argument above is the
   deciding one; the direct-only alternative is recorded with its true
   cost (the rails must narrow with it).
2. **A `version_of` link does not relate BLOCKS** (PROVISIONAL —
   #47(b)); the alternative makes the filter inert in the case it exists
   for.
3. **Default OFF** (PROVISIONAL — #47(c)). A filter that HIDES material
   is reached for, not arrived in: on-by-default buys nothing against a
   version twin (all kin) and lands on an explanation against an
   unrelated post. One line to flip.
4. **The hidden live ring releases, speaks, and lands its text; the
   toggle never refuses** (PROVISIONAL — #47(d)), on the 4C NIT-1
   precedent + P-2.
5. **The filter-OFF placement is untouched** — 4C judgment call 0 is
   MOOTED by the setting, not re-ruled. Recorded above; both 4C
   alternatives stay live in #47.
6. **Orthogonal to `followAnchorOrder` by construction** — this decides
   WHICH blocks show, that decides HOW they arrange. Filter on + follow
   off = each column's related blocks in its own order. Pinned
   (`relatedOnlyAndFollowOrderStayOrthogonal`). The alternative
   (related-only forces follow-order on) couples two independent toggles
   and would surprise.
7. **A kinship entry naming an anchor block this compare does not show**
   (a gap slot; a map read a beat before the projection) **drops** rather
   than surviving as a cell with no partner. Cheap, and it keeps the
   invariant below true.
8. **Recorded, NOT declared** (P-1's precision + Stage 4 lesson 10): the
   chip is a view-mode affordance with no shortcut and no menu item —
   exactly the class of its two siblings, which are also undeclared. Give
   it a shortcut later and it must be declared then.
9. **ONE `Display` computation per pass** (P-9): `rows` and the
   per-column notes read the same filtered inputs, so the board cannot
   disagree with itself about what is on screen. `rows` survives as the
   direct accessor the pins use.
10. **The tutorial gained a paragraph, not a lesson** — the "Compare is
    honest about relationships" lesson would have become actively
    misleading with a filter it never mentioned. The walk act
    `compareHonestyHoldsOnTheLessonsOwnContent` was EXTENDED rather than
    duplicated (count-neutral), so the new prose promise has an assertion
    behind it (P-6). **Field-guide re-seed:** this is a further staling of
    the already-stale seed — it joins the closeout obligation 2C/2D
    recorded, adding nothing new to it.

#### Red-on-old / guard-revert evidence

**Every pin in this batch is a CONTRACT pin over a NEW capability — the
4C record's "(c) new-contract pins" class, explicitly NOT red-on-old:**
there is no pre-2E filter to run against, and nothing here fixes a bug.
Their non-hollowness is proven instead by **four surgical guard reverts,
each executed, each restored and verified byte-identical by `shasum -c`**
(`pre-revert.sha`, both files OK after every restore; the suites re-run
green after the last).

| Revert applied | Pins that went RED | Observed |
|---|---|---|
| **A** — `relatedOnly` returns its inputs unchanged (the filter keeps everything) | `relatedOnlyKeepsTheKinAndComposesOnlyAlignedRows` · `relatedOnlyLeavesTheAnchorEmptyExactlyWhenEveryPeerIs` · `relatedOnlyDropsTheKinLessPeerEntirelyAndMootsThePlacement` · `relatedOnlyIgnoresKinshipPointingOutsideThisCompare` · `relatedOnlyAndFollowOrderStayOrthogonal` · `relatedOnlyHidesTheUnrelatedColumnAndTheBoardSaysSo` · `turningOnRelatedOnlyReleasesARingItHidesAndLandsTheText` · **`compareHonestyHoldsOnTheLessonsOwnContent`** (the tutorial act) | **8 pins, 22 issues.** The tutorial act's red is the informative one: the lesson's own unrelated pair filtered to 6 anchor + 4 peer blocks instead of nothing — i.e. the prose promise fails when the filter doesn't filter. `relatedOnlyLeavesARingItDoesNotHideAlone` correctly stayed GREEN (nothing is hidden, so nothing should release). |
| **B** — the `anchorSet.contains(anchor)` guard dropped | `relatedOnlyIgnoresKinshipPointingOutsideThisCompare` **alone** | Exactly one pin, one issue: `[["A'", "ghost"]]` survived where `[["A'"]]` is right. The narrowness guard discriminates and nothing else depends on it. |
| **C** — the `releaseLivePaneIfFilteredAway()` call removed from `relatedOnly`'s `didSet` | `turningOnRelatedOnlyReleasesARingItHidesAndLandsTheText` (3 arms) | The ring stayed on the hidden pane, nothing spoke, and — the arm worth reading — the store still held **`"Nothing to do with it."`** instead of `"typed just before the filter hid it"`: the typed text sat in a buffer no surface rendered. This is the mechanism the guard exists for, demonstrated rather than asserted. |
| **D** — the release fires unconditionally (`guard !stillVisible` dropped) | `relatedOnlyLeavesARingItDoesNotHideAlone` (3 arms) | The ring dropped and the message spoke on a block the filter KEPT, on both the peer and the anchor arms — i.e. without the visibility check the toggle would blur every time, in the common case. |

#### Test deltas

| Suite | Before | After |
|---|---|---|
| `CompareCompositionTests` | 8 | **13** (+5) |
| `CompareViewModelTests` | 7 | **10** (+3) |
| `TutorialLookingActsTests` | 6 | **6** (the honesty act extended — count-neutral, P-6) |
| **Mac total** | 772 / 135 | **780 / 135** (executed) |
| **Core total** | 881 / 100 | **881 / 100** (executed; zero core lines) |
| **Mobile** | 14 / 4 | builds clean (BUILD SUCCEEDED) |

#### Deviations

- **None from the brief.** The three things it named — the honesty line
  composed not broken, the 4C PROVISIONAL resolved by mooting, the
  "related" definition picked from options and logged — are each built
  and recorded above.
- **Environment note worth carrying (a false green caught, then
  corrected):** `-only-testing:VariorumTests/TutorialWalkTests` matched
  NOTHING and reported `** TEST SUCCEEDED **` — swift-testing suites are
  addressed by their **type name**, and that file holds seven suites
  (`TutorialLookingActsTests` is the one that carries the compare acts).
  The "Executed 0 tests" XCTest lines are always present (there are no
  XCTest cases), so **the `✔ Test run with N tests` line is the only
  proof a suite ran** — exactly why the environment section demands it.
  Recorded because a filename-shaped `-only-testing` argument is an easy
  and silent way to skip the pin you think you just ran.
- **Her app was NOT live** during this batch (`pgrep` clean at open); no
  Release build, no `/Applications` refresh, no store touched.

#### Ladder foci suggested for this batch (for the end-of-phase Fable review)

1. **The kinship-map asymmetry inside `compositionInputs`:** the filtered
   block lists ride with the UNFILTERED `kinships` map into `segments`.
   That is safe by `relatedOnly`'s invariant (every survivor's kin is a
   surviving anchor, and `segments` only consults the map for blocks it
   is handed) — worth a cold walk of `PostAlignment.rows` to confirm no
   path reads the map by iteration rather than by lookup.
2. **`railKin` under the filter:** it reads the full `projection.kinship`
   and `railedAnchors` over all mounted peers, unfiltered. Every visible
   block is kin under the filter, so it agrees today — confirm there is
   no configuration where a filtered-in block gets no rail or vice versa.
3. **The release's scope:** a projection change can hide the live pane's
   block without the toggle (the pre-existing 4C class, recorded above as
   deliberately not widened). Confirm the window's width and whether the
   4C accepted-transient reasoning still covers it now that a second way
   to hide a pane exists.
4. **`Display` vs `rows` double-computation:** the view reads `display`
   once per pass; `rows` recomputes independently for the pins. Confirm
   no view path still calls `model.rows` (grep says none) — a caller
   using both would double the composition per pass.
5. **The per-column note's suppression condition**
   (`isFiltered && !rows.isEmpty && slot.postID != nil && !peerHasBlocks[i]`)
   — four conjuncts is where an off-by-one lives. Worth constructing the
   three-column mixed case by hand.
6. **The default-OFF call** (#47(c)) is the one most likely to come back
   from her the other way — her sentence ("would make the pane feel more
   usable") can be read as wanting it on. The flip is one line if she
   says so.
