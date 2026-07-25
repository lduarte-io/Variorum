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
| A1 | Fragments-landed journal entries appear in Pool, not the Journal book *(traced)* | **13c-friction — SHIPPED (Batch 1D).** The landing half now shelves the day's entry in the designated daily book, mirroring ⌘J; never blocks the landing (finished/full/smart/dangling books land-and-speak); never re-shelves what she removed — which is also what makes it REPAIR her two existing orphans on their next landing. No-designated-book posture PROVISIONAL, QUESTIONS #37. Third class instance found and recorded, not fixed: the mobile capture door mints bookless the same way |
| A2 | The bridge "doesn't seem to refresh often enough" | **13c-friction — ANSWERED + one structural fix (Batch 1D).** The sign-out starvation is CONFIRMED as the dominant cause (signed out ⇒ zero sync rounds ⇒ zero `onRoundCompleted` ⇒ the bridge ran once per launch for five days) — but the hole is structural, not historical (an expired session or a failed owner adoption reach it too), so a lifecycle event now reaches the bridge when sync can't deliver a round, and a stale bridge no longer LOOKS fresh in the status row. The 60 s throttle is untouched; a periodic poll is deliberately NOT taken — QUESTIONS #38 |
| A3 | Whitespace phantom — paragraphs of empty space with nothing in them; vanish on scroll, return when you're over them | **13c-friction — ADDRESSED (Batch 1E, PROVISIONAL).** 1A traced it to TK2's own height estimate (not our bug, no public API to correct it) and 1C measured the only remedy; 1E built it — the block the viewport reaches is laid out once, and the phantom under it goes. Behind a cap, a once-per-block bound, a floor, and a KILL SWITCH; memo Q3 is still hers, now on felt evidence — QUESTIONS #39 |
| A4 | Editor jumps when one block is taller than the screen; the empty space below isn't clickable as newlines | **13c-friction — JUMPING FIXED (Batch 1A: two real defects, revert-verified); the un-clickable half was A46, which 1C proved is not a bug (the space is the editor's and the caret does move — there is just no text there); the space itself goes with 1E** |
| A5 | "the callouts don't have the spacing on their color right" | 13d |
| A6 | Book bottom inset — horizontal scrollbar on a vertical page; buggy progress bar | 13c (already ruled: remove both) |
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
| A41 | **The long-block phantom gap** — added live 2026-07-25: an extreme gap below a single long block *"even if there was nothing to indicate that whitespace should be there (i.e. I copied in a long message with no whitespace at the end)"*. **Merged with A3 + A4 as ONE class** (see the section above); her no-trailing-whitespace test eliminates the content explanation and points the investigation at long-block HEIGHT. Her diagnostic was right end to end: 1A measured the mechanism (a 3,000-word block guessing 4,964 pt against 4,597 pt real), 1C measured the remedy, **1E built it (PROVISIONAL, QUESTIONS #39)** — measured in a real window at 7,837 → 7,300 pt, with the document giving back the same 537 pt. | **13c-friction — ADDRESSED (Batch 1E)** |
| A46 | **The DEAD CLICK** — her Q4 answer, verbatim: *"clicking does nothing at all - it couldn't move your cursor into the phantom space and the down arrow couldn't move you down either. nothing was actually there."* Queued as batch 1C. | **13c-friction — INVESTIGATED (Batch 1C): NOT A BUG.** Measured through the real event route: the phantom IS the editor's surface, the click reaches it, and the caret moves — to the document END. It cannot enter the phantom because no text is there, which is her sentence exactly. Down-arrow already agreed correct. **Nothing fixed; characterization pins landed** (`PhantomSpaceTests`) and the weight moves to memo Q3 (option E, now measured). One genuinely un-routed **6 pt** strip at the bottom of every scroll view found and recorded — **AppKit's, reproduced on a vanilla `NSTextView`** — pinned at size so this class can't grow unnoticed |
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
  **`notes/plans/mobile-app-plan.md`** so they never depend on this
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

## Architect adjudications

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
