# Phase 13e — Takes & block management

**Status: OPEN — kicked off 2026-08-16 under `/architect-phase`
(the author's invocation; the opening sitting ran the same day
under a 30-minute author window — the sitting record below). The
paste-ready-era status line is superseded.**

## The binding principles (the P-1…P-9 constitution — copied VERBATIM at kickoff per the `/architect-phase` rule; the application notes in `.claude/skills/architect-phase/SKILL.md` bind alongside)

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

*(Original status paragraph, superseded above:)* Status was
PASTE-READY (authored at the 13g closeout, 2026-08-01,
per the front-loaded-planning rule). The author kicks it off at her
word. Sequencing was HER 13f round-5 ruling: 13f → 13g → **13e**,
then her choice (13h · 13i · 13j all pending at her word).
**13e's closeout authors the NEXT phase's plan** (whichever she
picks at that point — the standing ritual).

## THE OPENING REMINDER NOTE (her 13g round-7 instruction — REMINDERS, NEVER GATES)

Her words: *"you can make a note at the start of 13e to remind me
of those checks (not gate on them)."* The note, in full — walk it
with her at the opening sitting, none of it gates anything:

- **Two hand-checks** (13g's last unpinnable inches): press ⌘B
  while the keyboard is in a TAKE PANE (menu key-equivalent
  routing to a board's first responder); click a link in Read's
  SCROLL face (whether link dispatch beats the wake-the-post tap;
  benign either way, one line to move the gesture if not).
- **The #49–#52 walk** (`notes/QUESTIONS.md`): 32 build-time calls
  from 13g's batches, each with a stated default and one line to
  change.
- **The look/feel bundle:** inline code invisible in the terminal
  voice (a tint is the candidate fix); the CHECKED-box register
  (Write's `- [x]` line AND Read's ☑ line — dim? strike?);
  indented/nested list styling (the column-0 rule wants widening
  with her word); the visible formatting-TOOLBAR offer (menu-first
  shipped; the bar is hers); ⏎-continues-a-list (changes what
  typing does — her word first); `ReadTakesView` cards' raw
  undimmed markers (13g review NIT R1-6); the L3/L4 title-band
  look (keep, or one modifier each back); #52(g) — quick notes
  land in Quicknotes, not the Pool (the one-line alternative).
- **One click:** Help ▸ Restore Tutorial (covers 13f + 13g's
  lessons + the review's corrections), if not already pressed.

## Author additions (2026-08-01 evening, the lean-docs housekeeping session — direction-level, for the opening sitting)

Recorded the evening after 13g closed, her uncertainty preserved;
the sitting walks these BESIDE the reminder note above (same rule:
reminders and directions, nothing gates):

*(2026-08-02 addendum: the bar/nav bundle, BOTH callout riders, and
the code tint moved to PHASE 13K — ledger rows K11/K6/K9/K10,
`notes/plans/phase-13k-walk-build-round.md`, opened by her at the
session's tail. The E1 pickers, W26, and the kickoff sweep STAY
here.)*

- **Two 13g checks already VERIFIED by her, on the record:** ⌘B in
  a take pane — "bold in takes works well" — and the
  masthead-inspector crash "is gone now." (The Read-scroll link
  click remains open.)
- **The context/navigation bar should ALWAYS be the compact icon
  row** (her screenshot on file: ← · book icon · # · ›). Her
  words: "the collapsing and growing in that bar is a little
  annoying to me," and "i actually don't think that the spelled
  out *back arrow* is a need."
- **A FORWARD affordance beside back:** "after you just went back,
  i feel like you should be able to go forward." (⌘] shipped at
  13f; the bar itself offers no forward door — the greyed chevron
  is the natural candidate.)
- **"In xyz book" → a BOOK ICON:** click brings you to the book
  when there is exactly one; "command click on lets you see the
  list of books (or there's a dropdown if there's several books it
  could be in)."
- **Tags MAYBE move from the top bar to the context-bar area** —
  "i think it might look better there than in the top bar"; she is
  "sensitive to not wanting the header bar to be too crowded" and
  explicitly "a little conflicted on if tags belong there." A
  sitting call, deliberately NOT pre-decided.
- **E1 rider (callouts):** the right-click context menu carries
  the Format submenu but NO Callout submenu — Callout lives in the
  menu-bar Block menu (+ ⌥⌘C), and she went looking for it in the
  right-click and reasonably didn't find it (2026-08-01). E1's
  swatches/real-emoji-picker work should hang the right-click door
  too.
- **E1 rider 2 — callout frames in TAKE MODE (her instruction,
  2026-08-01, later the same evening): "callouts are supposed to
  be added to take mode as well."** Code fact at recording time:
  the frame RENDERS only in Write's overlay (`BlockDecor`); the
  Takes board's cards draw no frame, though canon says the frame
  is the BLOCK's and its takes share it (R16/R27) and the SETTING
  door already routes from Takes/Lenses/Compare (13c R2-2). The
  sitting pins the exact shape (frame around the whole fan? per
  card?) — the instruction itself is hers, on the record.
- **Code-tint ruling INCOMING (same message):** "code blocks
  should have their own tint - i'll rule on that" — the
  inline-code look/feel item above, hers to rule at the walk.
  (Recording note: v1's vocabulary has inline `` `code` `` SPANS
  only — fenced ``` blocks are not in F-3.)
- **Fenced ``` code blocks: WANTED, LATER — her word, 2026-08-02:**
  "oh i do want a fenced ``` code block later i think but it
  doesn't have to be in the immediate plans." Direction-level, NOT
  13e scope; the opening sitting slots where it lands (a
  vocabulary addition to F-3 — line-scoped fences would be the
  I4-clean shape — riding whatever formatting follow-up next
  opens). Recorded here so it is not lost; uncertainty ("i think")
  preserved.
- **Post-13k addition (2026-08-02, the closeout conversation) —
  DUPLICATE BOOK NAMES:** 13k K4's shown-once rule surfaced that
  nothing stops a curated book and a smart book from both being
  named "Ideas." Her words: *"i think that maybe being able to name
  books the exact same thing is not the best? it seems a bit
  confusing. i don't think it has to be a schema rule but maybe a UI
  rule that you can't purposefully do that? I'm open to suggestions
  there."* Fable's recorded recommendation for the sitting: a
  DOOR-level guard, never schema — the create/rename doors refuse
  (or warn on) a duplicate LIVE book name with honest wording. Schema
  uniqueness would demand a SyncSpec §7 repair rule and a forced
  rename for an offline name race; the door guard simply tolerates
  that race (K4's shown-once display already absorbs a raced
  collision gracefully). Exact shape — refuse vs warn, case
  sensitivity, whether archived/finished books count — is the
  sitting's.

## THE WALK RAN EARLY — the housekeeping session, 2026-08-02 (rulings on the record; the opening sitting walks only what is marked HELD or NOT YET WALKED)

She walked #49–#52 and the look/feel bundle in the housekeeping
session, the evening after 13g closed. Verdicts, her words quoted;
QUESTIONS.md's status lines carry the same record:

- **#49 RATIFIED in full** ("49 all looks good") — all nine
  formatting-act calls stand as shipped.
- **#50 RATIFIED in full** ("i think 50 also all seems fine for
  now"; on (a): "copy and pasting things still generally gives
  you the https").
- **#51 (a)(b)(d)(e) RATIFIED** ("51 seems fine to me"); **(c)
  HELD** on her question — what walking smart filters costs, and
  whether a journal entry shows "Journal" (YES — the daily book is
  curated, real membership rows) and a quicknote shows
  "Quicknotes" (NO today — smart membership is derived). **→ RULED
  at the 13k kickoff, same session: SHOW smart books on cards ("you
  still have to choose to deliberately create a smart book") —
  13k K4.**
- **#52(a) OVERTURNED — BUILD ITEM:** the literal-"Untitled"
  clause RETIRES; only a BLANK/nil title counts as no title, and a
  note literally named "Untitled" shows "Untitled" again. NO
  sweep: "i can delete them or rename them myself, there aren't
  that many of them." The ⌘N nil-mint half STANDS. **→ 13k K1.**
- **#52(c) HELD** on her question ("they still have a date they
  were created at, right?") — correct: a pool (the Snippets
  container) carries `created_at`, just never `entry_date`; the
  shipped call scoped the date-title rule to notes. **→ RULED at
  the 13k kickoff: nameless pools SHOW their created day ("i think
  that would be helpful") — 13k K2.**
- **#52(g) RATIFIED in her words:** "a quicknote should be in
  quicknotes, it goes to the pool if you delete that tag."
- **#52 (b)(d)(e)(f) — WALKED at the 13k kickoff:** (b) RATIFIED
  (`2026-08-01`, "easier to scan than august 1, 2026"); (d) FLIPPED
  — tag cards DEFAULT VISIBLE, folding a deliberate choice (13k
  K12); (e) FLIPPED — chips show LEAF ONLY (13k K3); (f) RATIFIED
  ("block menu rows fire and speak is good i think").
- **Checked-off text RULED:** "the checkbox shouldn't change the
  line visibly - just let it be checked off with no other changes"
  — the box flip (`- [x]` / ☑) is the whole signal; no dim, no
  strikethrough, both faces. Matches what shipped — now ruled
  rather than default.
- **The formatting toolbar RULED IN — the BOTTOM bar — BUILD
  ITEM:** "i think the formatting toolbar should be added to the
  bottom - if i decide it's too cluttered later i'll remove it
  then, i think other users would need it though."
- **Indented/nested lists RULED IN — Tab indents — BUILD ITEM:**
  "we should allow indented lists and it should happen when you
  click tab." The UNINDENT door is open — she knows ⌘[ is taken
  (per-pane back) and floated "maybe if you click in it's an
  option?"; ⇧Tab (the platform pair) proposed to her, pending her
  word.
- **⏎ list continuation RULED IN — BUILD ITEM:** "enter at the end
  of a list line should continue the list, and enter again should
  take you out of the list" — ⏎ on a texted list line mints the
  next lead; ⏎ on an EMPTY list item removes the lead and exits.
  (Supersedes the shipped no-continuation default the look/feel
  item flagged.)
- **Hand-checks:** "i'll do these other handchecks later in time"
  — the Read-scroll link click stays open, ungated.

**SUPERSEDED THE SAME SESSION — HER WORD CAME: every build item
above, plus the bar/nav bundle and both callout riders from the
author-additions section and the smart-membership / pool-date /
leaf-chip / tags-visible rulings, is now PHASE 13K**
(`notes/plans/phase-13k-walk-build-round.md`, opened by her at the
session's tail under `/architect-phase`, ledger rows K1–K12).
**W26, the kickoff-sweep rows, the E1 pickers, and the 13e ledger
proper STAY HERE — she kicks 13e off after 13k closes** ("let's get
these items done though and then i'll kick off 13e").

## Kickoff message (paste-ready for the orchestrator/coordinator the author invokes)

> You are running Variorum Phase 13e under the shape the author
> picks at kickoff (`/architect-phase` has run every phase since
> 13c; her recent cast: Fable orchestrator · a fresh Opus
> implementer per batch · ONE Fable cold review at phase end,
> standard ladder — confirm, never assume). Read IN FULL first:
> `CLAUDE.md` + the canon it loads (AppSpec §14's 13g delta is the
> latest state), this plan, `notes/handoffs/phase-13g-handoff.md`,
> the 13g plan's F-1…F-5 rulings (formatting semantics you must
> not regress), and the 13c plan's "Environment traps" (binding,
> as every phase) PLUS the two 13g standing rules: never address a
> Variorum instance by PROCESS NAME (bundle id
> `io.lduarte.Variorum.debug` or PID only), and Mac test runs use
> the cwd-independent `-project` invocation. Verify the baselines
> with your own runs. Copy the P-1…P-9 constitution into this file
> verbatim if running under `/architect-phase`. **OPEN WITH THE
> AUTHOR-ATTENDED SITTING, in this order:** (1) **the REMINDER
> NOTE above** — walk it with her, record verdicts as sitting
> rounds, gate on nothing; (2) **W26 — the true system-wide
> quick-note hotkey** (her 2026-08-01 slotting ruling: "so that
> i'm sure to land on it again"): the author-attended test — the
> researched one question is whether macOS prompts; the Carbon
> research lives in the 13f plan file; (3) the **KICKOFF SWEEP**
> (below); (4) scope confirmation from the ledger; (5) cast
> confirmation.

## Goal

The fan and the block list get their missing hands (roadmap ruling
K3, 2026-07-25).

## The ledger at authoring time

| # | Item | Source |
|---|------|--------|
| E1 | Colour swatches + a real emoji picker (callouts) | A13(b) |
| E2 | Block-level multi-select and multi-delete | A17 |
| E3 | ⌘-click merge selection in Takes | A18 |
| E4 | Reorder takes (`fan_position` — pin like every other ordering) | A19 |
| E5 | Move-a-take-into-a-block-below | A20 |
| E6 | Copy-all-takes / takes-to-blocks — **doubles as the REPAIR TOOL for the sub-takes diagnosis** (13c's A45 finding: "my takes should've been blocks"; A21 reframed as the migration for work already shaped wrong) | A21 |
| E7 | The 13c kickoff candidates SHE APPROVES (margin-hover comment grammar · canvas bank · synced card sizes) — offer at the sitting, build only her picks | 13c |
| E8 | The 13f round-11 candidates: the tag-surface ask + the in-post tags face (composes with 13g's R6-1 chips — the chips are the top bar's; this is the fuller ask) | 13f |
| E9 | The takes-aware find & replace half (the KnownIssues row: replace across a block's live takes — the Delete-in-Every-Take apply-and-report precedent is the aligned shape) | KnownIssues |
| E10 | The 11a copy-doors flush alignment (duplicateAsVersion/promoteLens faces flush the pending buffer first — the diverge doors' shape; KnownIssues row) | KnownIssues |
| E11 | Declare the book-icon ascent ("open this book at this note") in the capability registry — availability rule, doors, refusal wording, registry-walk coverage. The 13k handoff residual (the door has worked since Phase 13, never declared); her 2026-08-02 call: "the registry should be kept up to date, and keeping the registry up to date should be part of the plan." Pure P-1 hygiene, nothing user-visible | 13k handoff |
| E12 | **Canvas drag jitter/resist regression** (her kickoff-sitting finding, 2026-08-17, verbatim: "right now moving cards around on canvas is very weird and buggy compared to how it used to be. they jitter while moving and seemingly resist moving") — trace the mechanism in TODAY'S code (the hallucination guard binds), red-on-old pin, fix. **Her scoping rider (2026-08-17, same sitting): NOT a bisect hunt** — "it was a really long time ago when canvas cards last could be moved properly, like before the issue of them all stacking on top of each other at creation time was solved. so i wouldn't do too much code archeology because the change to them all being placed somewhere also happened a long time ago." The onset window is the creation-time-placement fix era (the 13b Stage 4 canvas rework's orbit); diagnose the live drag path directly, don't excavate history. Rides the canvas batch beside E7's bank | kickoff sitting |
| E13 | **Duplicate-book-name door guard — RULED at the kickoff sitting: REFUSE at the door.** Create/rename refuse a case-insensitive match against any LIVE book's name, honest wording ("A book named 'Ideas' already exists"); archived/deleted books don't count; NO schema — the offline race stays legal and 13k K4's shown-once display absorbs it | kickoff sitting |
| E14 | **W26 BUILD — RULED IN at the kickoff sitting (2026-08-17), chord ⌃⌥⌘N (fixed for now; a recorder UI is a later at-her-word add).** The true system-wide quick-note summon: the probe-proven shape (`RegisterEventHotKey` under the app's event loop) summons the 13f sticky while ANY app is frontmost. The batch's own verification act: the SANDBOXED in-app registration (the probe was unsandboxed — the one context gap). Registry-declared like every door (P-1); the chord joins the key table under the standing collision pin | kickoff sitting (W26) |
| E15 | **The Mac Takes board's projection-delivery policy routing** (its KnownIssues row, owner 13e, surfaced by the mobile S3 ladder 2026-08-03): `TakesViewModel` adopts clean-instant AND deferred deliveries outside the shared `EditorProjectionEngine` policy guarding both editor surfaces. Policy-route the board, or re-record its residual with evidence. Rides whichever batch touches the Takes board (E3/E4's orbit) | KnownIssues |

## THE KICKOFF SWEEP (owns four parked items; the hallucination guard binds hard)

1. **The windowless launch + quit-from-windowless hang**
   (KnownIssues row): 13g's sweep failed 32 cold reproductions
   across six arms and two trees — **CAPTURE, DO NOT SUMMON**: the
   next time the state occurs naturally, run `sample <pid> 5`
   FIRST, then the CGWindowList census (by PID — AX reads the
   current Space only), then `lsappinfo`, then time a `quit`, and
   only then click the Dock. The row carries the full ruled-out
   space and the three surviving candidates.
2. **The note-only window's clipped top** (KnownIssues row): 13g
   batch 6 reproduced it deterministically (a note IN A BOOK, so
   the context bar renders), instrumented it (layout converges;
   the pixels are the first pass's; any resize repairs it
   permanently), and **built three fixes that all measured wrong**
   — the row records them so nobody repeats them. The one
   structural difference from the main window is the pane row's
   re-proposing GeometryReader.
3. **The A47c tripwire** (KnownIssues row):
   `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
   fails on UNLOCKED sessions and passes locked — the pin's own
   message directs re-running the 13c A47c experiments; run them
   under BOTH lock states and disposition the pin from evidence.
4. **The shell-redo pin's sibling sweep is DONE** (13g batch 5
   resolved the row at its mechanism and swept all 32 status
   assertions) — listed so the sweep doesn't re-open it.

## Binding constraints

- The P-1…P-9 constitution (copy in verbatim at kickoff under
  `/architect-phase`); the registry grows to cover new doors.
- 13g's F-1…F-5 formatting semantics are CANON (AppSpec §14's 13g
  delta): display == stored on editing surfaces; the line-scoped
  tokenizer law; Read's rendered face; the DisplayTitle brain.
  E2/E5/E6 touch block/take structure — the markdown face must
  survive every structural op (spans re-scan; nothing stored).
- `fan_position` reordering (E4) is ordering like every other:
  fractional-index keys, jitter, no rebalance (SyncSpec §8).
- No schema without her explicit ruling (a §12 lockstep event,
  mirror-first, her go — E7's "synced card sizes" is the one
  candidate; STOP at the sitting if it firms).
- No `Sources/VariorumCore/Sync/` lines without the standing rider.
- Every PROVISIONAL to `notes/QUESTIONS.md` (append, never
  renumber — the #49–#55 walk is DONE except #54(d), per 13k's
  record; next free number at 13k's close: **#56**).

## Baselines at open (verify with your own runs)

Core **1034/114** · Mac **1191/208** (the ONE recorded
environment-gated tripwire red — covariate UNKNOWN since 13k
refuted the lock-state theory; its KnownIssues row; exactly that
one red is the known state) · mobile **14/4** · tutorial spine
**51/7** — the 13k finals, verified by that architect's own runs
2026-08-02, superseding the 13g figures this section carried at
authoring time. No schema since v1_12; mirror at lockstep marker 4.

## Verification

Per-batch: the standing loop (build → red-on-old pins by
behavioral revert with checksums → the tutorial spine green by
TYPE name → full suites, counts by the "Test run with N tests"
line; mobile when `Sources/`/`Shared/` is touched — iPhone 16e).
Review shape: the author sets it at kickoff. **13e's closeout
authors the next phase's plan** (her pick: 13h · 13i · 13j — or
an unslotted row at her word).

*(2026-08-02 addendum — PHASE 13K CLOSED: the #49–#55 walk is DONE
except #54(d) — Read's chip voice-independence, her flick. The
opening reminder note's remaining load is the 13k handoff checklist
(`notes/handoffs/phase-13k-handoff.md`), W26, and the four-row
kickoff sweep. Look/feel items RESOLVED by 13k: the inline-code
tint (the chip), ⏎-continues-a-list (built, with nesting),
the formatting toolbar (built, both bars), the checked-box register
(ruled no-change). The A47c tripwire row now starts
covariate-UNKNOWN — read its updated KnownIssues row before the
re-run.)*

*(2026-08-02 addendum 2, the post-13k conversation — SCOPE
FULLNESS, her observation: "it seems very full now." The ledger
runs E1–E11 plus the duplicate-book-name sitting item, and that is
deliberately MORE than one phase must carry: the kickoff's step (4)
scope confirmation is a REAL trim pass, not a formality. The
architect should bring her a keep/defer split with a proposed batch
order; the natural defer candidates if she wants it lighter are E8
(the fuller tags face) and E9 (the takes-aware find & replace half
— its KnownIssues row would be re-owned at the sitting, never left
blank), both severable without touching the phase's core (E1–E6 +
the sweep). Baselines and the QUESTIONS status line in this file
were refreshed to the 13k finals the same day.)*

*(→ HER RULING, the same conversation — NO TRIM: "honestly i don't
need to cut any items from 13e - we've had midphase handoffs before
when necessary." The full ledger E1–E11 runs; step (4) scope
confirmation returns to ordinary confirmation, and the pressure
valve for a long phase is the standing one — fresh implementer
sessions per batch and, if the orchestrator itself runs long, a
mid-phase orchestrator handoff on the 13b context-degradation rule
— never deferral. The defer-candidates sentence above is
superseded.)*

---

## THE KICKOFF SITTING (opened 2026-08-16, rounds landed 2026-08-17 — her verdicts verbatim-faithful; the phase is OPEN)

**Round 1 — CAST & SCOPE CONFIRMED, with her amendments (2026-08-17).**
Her words: *"confirm, you can have several Opus subagents and
implementers if you want, but only one fable orchestrating session
and only one fable cold review. my 'as many agents as you want' was
for when my session limit was running out, i didn't see these
questions so we're in the new week now. also, since this phase is so
big, maybe you can run a couple of fable cold reviews at points that
make sense, if needed"* — and, on the first question slot: *"Do NOT
spawn unlimited subagents."* Binding reading: **ONE Fable
orchestrating session (this one) · Opus implementers (several
allowed, at the orchestrator's judgment — never unlimited
subagents) · Fable cold review nominally ONE at phase end, with her
granted latitude for a couple at sensible mid-phase seams if
needed.** Scope: the full E1–E11 ledger + E12/E13 below + the
four-row kickoff sweep — the standing NO-TRIM ruling, reconfirmed.

**Round 2 — E7 RULED: margin-hover comments + canvas bank BUILD;
synced card sizes NOT picked** (stays recorded, unbuilt — so no
schema event is on this phase's horizon). Two riders from the same
answer:
- Her comment-side instruction/question: *"comments need to be on
  the left instead of the right - is that true in this phase?"* —
  architect's answer: it is NOW — folded INTO E7's margin-comment
  work as her instruction (comments render in the LEFT margin).
  **CONFIRMED by her the next round:** *"E7's margin comment work
  was my comments on the left point, so that osunds [sounds]
  good."* The left-side move and the hover grammar are one E7
  work item.
- Her live FINDING, verbatim: *"right now moving cards around on
  canvas is very weird and buggy compared to how it used to be.
  they jitter while moving and seemingly resist moving."* →
  **ledger row E12** (canvas drag jitter/resist regression), routed
  to the canvas batch beside E7's bank; the hallucination guard
  binds (self-traced mechanism; red-on-old pin; "compared to how it
  used to be" marks it bisectable).

**Round 3 — DUPLICATE BOOK NAMES RULED: REFUSE at the door** (her
pick of the recommended shape) → **ledger row E13**: create/rename
refuse a case-insensitive match against any LIVE book's name with
honest wording; archived/deleted books don't count; NO schema — the
offline race stays legal, K4's shown-once display absorbs it.

**Round 4 — W26: THE AUTHOR-ATTENDED TEST PASSED (2026-08-17).**
Probe v1 (a bare CLI pumping a plain RunLoop) registered clean but
never dispatched the event — the fix was a real `NSApplication`
accessory event loop (probe v2, unsandboxed, Glass-chime fire
signal). RESULT, measured on her machine: `InstallEventHandler: 0`
· `RegisterEventHotKey: 0` · **THREE FIRES logged (15:29:50/52/53
UTC) with another app frontmost — she heard the chime — and NO
permission prompt at registration or at fire, across all three
runs.** Her words: *"i heard the glass chime!"* The 13f research's
one open question (does macOS prompt?) is CLOSED: no, on macOS 26.x,
for a ⌘-inclusive chord, unsandboxed context. **Standing caveat:**
the shipping app is SANDBOXED — the in-app registration is the
build batch's own verification act (FB15168205's regression class
is ⌥-only/⌥⇧ chords; ⌃⌥⌘N sits outside it). Probe source:
the session scratchpad's `w26probe2.swift` (throwaway; the shape —
NSApplication accessory loop + `RegisterEventHotKey` — is what the
app-side build reuses).

**Round 5 — W26's BUILD RULED IN, same sitting:** her picks — build
it in 13e (→ **ledger row E14**), chord **⌃⌥⌘N** fixed for now (the
tested chord; "configurable from day one" offered and not taken —
a recorder UI is a later at-her-word add).

**THE SITTING IS CLOSED (2026-08-17).** All five kickoff steps ran:
the reminder-note walk (remainder open at leisure), W26 (test
passed + build ruled), the kickoff sweep confirmed as the
architect's autonomous work, scope confirmed (E1–E15, no trim),
cast confirmed with her amendments. The phase proceeds
autonomously from here: remaining preflight reading (13g handoff ·
F-1…F-5 · 13c environment traps · QUESTIONS.md), the Mac baseline
run at a zero-conflict window, then the batch plan + the first
Opus implementer brief — author touchpoints only at held items and
the end-of-phase checkpoint, per the standing away-run rules.

**The reminder-note remainder** (the 13k handoff checklist's
hand-checks · #54(d) Read's chip voice-independence · the code-chip
live judgment + radius · the Read-scroll link click) stays OPEN AT
LEISURE per her standing word ("i'll do these other handchecks
later in time") — re-surfaced at the sitting, nothing gates.

**Baselines re-verified at kickoff (architect's own runs):** core
**1216/128 GREEN** (run 2026-08-16 — supersedes this file's
authoring-time 1034/114: Phases 14a–14d landed between; 1216/128
matches the mobile-parity §5 seam record exactly). Mac suite run
pending at the next convenient window (her live instance + the
author-attended sitting made a flashing full-suite run the wrong
act mid-sitting); mirror is at lockstep marker **6** (14c), not
this file's authoring-time marker 4 — no schema change since
v1_12 locally, the delta is all server-side.
