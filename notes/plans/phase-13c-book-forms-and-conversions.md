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
| C1 | The uniform-page book view (from the 4F brief) + her 7/23–24 direction | committed, not started |
| C2 | N38 smart→smart+curated conversion (from the 4F memo; her five rulings first) | committed, not started |
| C3 | N41 inline-comments airiness (R116-class conversation first) | committed, not started |
| C4 | Compare "show related blocks only" setting (resolves the 4C kin-less-peer PROVISIONAL) | committed, not started |

### Author intake, 2026-07-25 (the kickoff sitting's list — every item dispositioned)

Source: her exported note. **Nothing here is invented; each row is her
own item.** Phase assignments are K2/K3's; rows marked **13c-friction**
are this phase's opening batch.

| # | Item (hers) | Owner |
|---|-------------|-------|
| A1 | Fragments-landed journal entries appear in Pool, not the Journal book *(traced)* | **13c-friction** |
| A2 | The bridge "doesn't seem to refresh often enough" | **13c-friction** |
| A3 | Whitespace phantom — paragraphs of empty space with nothing in them; vanish on scroll, return when you're over them | **13c-friction** |
| A4 | Editor jumps when one block is taller than the screen; the empty space below isn't clickable as newlines | **13c-friction** |
| A5 | "the callouts don't have the spacing on their color right" | 13d |
| A6 | Book bottom inset — horizontal scrollbar on a vertical page; buggy progress bar | 13c (already ruled: remove both) |
| A7 | Backspace won't delete an empty block — "especially when there's an empty block right at the start of the post" | **13c-friction** |
| A8 | No ability to delete / archive empty blocks at all | **13c-friction** |
| A9 | "i desperately need divide in takes mode" | **13c-friction** |
| A10 | Redo — to undo an accidental structural undo *(traced: absent)* | **13c-friction** |
| A11 | Divide on an empty line should put the blank line NOWHERE — block above, block below | 13d |
| A12 | Warning before destructive actions like undoing a structural edit that created a take | 13d |
| A13 | Callouts (a) in Takes/Compare/Lenses + a shortcut *(traced)* · (b) real colour swatches + a proper emoji picker | (a) **13c-friction** · (b) 13e |
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
| A31 | See a book by its saved custom order OR by an attribute like time; the order savable like a lens | **13c** (book-shaped) |
| A32 | Infinite vertical scroll editor — jump to the right part in takes, then back | 13f |
| A33 | Formatting — bold, italics, different sized fonts, some markdown handling | 13g |
| A34 | **"a simple list maker and checkbox maker (like hyphens, [], bullets)"** — added live at the sitting | 13g |
| A35 | LLM folder bridge — save a post as .md in a folder, open one by path, edits sync back | 13h |
| A36 | Markdown folder import choosing whether folders become chapters/books ("to lure people from obsidian") | 13h |
| A37 | EPUB library — read-only books, highlights auto-appending to a "favorite quotes" note with quote marks, dash, author, title | unslotted row |
| A38 | "a variorum mobile app that's quite robust and easy to use" | 15 |
| A42 | **A thorough, beautiful, robust MOBILE app** — added live 2026-07-25, moving Phase 15's material up. Shapes floated and deliberately NOT chosen (hers to rule at the mobile design sitting): a Write-like base · drag-left/right on blocks for their complex menus · a small take button · **or** takes-in-stack-only with expand/shrink. Continues R58; puts CoreDescription pillar 8's "no variant/fan gestures there" in tension — an explicit vision-doc delta, hers to make | **re-slotted — her call pending** (was 15) |
| A43 | **All book views more editable** — *"chapters / posts with blocks within are genuinely helpful concepts."* Extends A39 beyond Outline; scope (Outline + Book, or all three incl. Read) is her call | **13c** |
| A44 | **Book mode offers TWO editing forms** — the takes STACK and normal WRITE, as the presentation choice for each full-post page in the flipping two-up spread. Instruction, not question | **13c** |
| A45 | **The "sub-takes" finding** — a use-level diagnosis, not a feature request; I7 stands. Raises A39's priority and reframes A21 as a repair tool (see the section above) | **finding — informs 13c** |
| A41 | **The long-block phantom gap** — added live 2026-07-25: an extreme gap below a single long block *"even if there was nothing to indicate that whitespace should be there (i.e. I copied in a long message with no whitespace at the end)"*. **Merged with A3 + A4 as ONE class** (see the section above); her no-trailing-whitespace test eliminates the content explanation and points the investigation at long-block HEIGHT. | **13c-friction** (one investigation with A3/A4) |
| A39 | **A book-level WRITE mode** — added live 2026-07-25, verbatim: *"i also feel like I need more of a proper 'write' mode for the whole book - like literally looks like write mode but has the chapter headings and the posts are collapsible. that would be nice."* **Book-shaped ⇒ 13c.** *Open at record time and asked at the sitting: whether this IS what Outline should become (today's continuous vertical scroll, renamed per her 7/23–24 direction) or a FIFTH surface beside it.* **Architectural notes recorded now:** "looks like write mode" means an EDITABLE book-level surface, so Stage 4 lessons 1–2 bind — it adopts `PaneTextAuthority`'s one-live-ring contract (never a second liveness mechanism) and joins `commitTake`'s availability with a `.commit` handler. "Collapsible" follows the block-TOC precedent: collapse is session/view state, **never in-place text folding inside a live TK2 editor** (TEXTKIT2 §3; AppSpec §12's standing rule). Virtualized per P3 like the reading flow (the 13 round-3 MAJOR's lesson). | **13c** |
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
  **`notes/plans/mobile-app-brief.md`** so they never depend on this
  session. **The pillar 8 delta is APPLIED with her explicit blessing**
  (full version, not hedged): takes ARE included on mobile; "smaller
  than the Mac" survives as the rule; the journal-restrictions-are-a-
  UI-profile half is untouched.
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

## Architect adjudications

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
