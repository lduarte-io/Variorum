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

**Baseline correction on the record (2026-08-17):** the standing
full-suite baselines at 13e's open are the 14d-close figures —
**core 1216/128 · Mac 1246/220 tripwire-only · mobile 314/60 ·
spine 51/7** (14d shipped zero core-logic/`Sync/`/schema changes,
so the §5-seam merged-tree figures stand; core independently
re-verified green by the architect's own run 2026-08-16). The
"Baselines at open" section's 13k-era figures are superseded.
Mirror at lockstep marker **6**; local schema unchanged since
v1_12.

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

---

## Environment traps (13e's binding copy — the 13c core + the 13g standing rules + this phase's specifics; every batch brief carries THIS section)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the DerivedData test host matches mid-run;
`/Applications` = hers/real-store); real-store instances by STORE,
not path — **NEVER quit/kill one, and NEVER address a Variorum
instance by PROCESS NAME: bundle id (`io.lduarte.Variorum.debug`)
or PID only** (the 13g batch-1 incident's standing rule); no
Release builds or `/Applications` refreshes while a real-store
instance lives (one was LIVE at kickoff, PID 54789 — re-check,
never assume); Mac suites DO run beside her live app (the Debug
host's container holds the seeded design corpus); **Mac test runs
use the cwd-independent `-project` invocation** (the second 13g
standing rule): `xcodebuild test -project
<home>/dev/variorum/App/Variorum/Variorum.xcodeproj
-scheme Variorum -destination 'platform=macOS'`, SUITE-level
`-only-testing` only, confirm the "Test run with N tests" line;
`xcodebuild build-for-testing` compiles without the runner; zsh
`pipestatus` (lowercase); NEVER add a custom build configuration
(SPM builds packages release under any config not named "Debug" —
strips the DEBUG oracles); test windows flash beside a live
session — prefer zero-instance windows for timing-sensitive
measurement; the Mac runner needs an UNLOCKED login session
(lock-flag check: `swift -e 'import CoreGraphics;
print((CGSessionCopyCurrentDictionary() as? [String: Any])?["CGSSessionScreenIsLocked"] ?? 0)'`);
backups WAL-safe with UTC names, ALWAYS before touching the real
store (the A1 rail); the real store lives in the SANDBOX CONTAINER
`~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/`;
drives need unlocked + author-free + own `caffeinate -d`;
osascript System Events menu clicks work (accessibility granted);
fresh hosting views for remounts; a bare NSWindow auto-assigns
first responder on order-front; async-poll (never sync RunLoop
pumping) drains settle hops; screenshots in gitignored dirs; never
`git checkout` over uncommitted work; **implementer sessions never
push** (the orchestrator pushes at bout ends per the 2026-08-03
author rule). 13e specifics: `PoolDragTests` reads the physical ⌥
key — a real keypress during a suite run can flake it (13k
record); the ONE allowed standing red is
`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
(environment-gated tripwire, covariate UNKNOWN — its KnownIssues
row; the kickoff sweep owns the A47c re-run); the W26 probe
binaries live in the session scratchpad, throwaway.

## THE BATCH PLAN (architect's order, 2026-08-17 — adjustable on evidence; one FRESH Opus implementer per batch, strictly sequential)

| Batch | Scope | Status |
|---|---|---|
| 1 | **The door set:** E1 (swatches + real emoji picker) · E13 (duplicate-book-name refusal) · E11 (ascent registry declaration) | **DONE 2026-08-17** — record below (core 1223/130 · Mac 1266/224 tripwire-only · mobile 314/60 · spine 51/7; Mac baseline corrected to 1251/220) |
| 2 | **The fan's hands:** E4 (reorder takes + the fan-copy remap fix that lands WITH it — its KnownIssues row's FIX-2 template) · E15 (Takes-board policy routing) · E3 (⌘-click merge selection) | **DONE 2026-08-17** — record below (core 1235/132 · Mac 1285/227 tripwire-only · mobile 314/60 · spine 51/7; both KnownIssues rows RESOLVED) |
| 3 | **Take↔block structure:** E5 (move-a-take-into-a-block-below) · E6 (copy-all-takes / takes-to-blocks — the A45 repair tool) | **DONE 2026-08-17** — record below (core 1254/135 · Mac 1298/229 tripwire-only · mobile 314/60 · spine 51/7; the fork RULED as AR-1 — mint-copy, source take ARCHIVED) |
| 4 | **Block management:** E2 (block multi-select + multi-delete) | **DONE 2026-08-17** — record below (core 1254/135 · Mac 1330/234 tripwire-only · spine 51/7; mobile not run — `Sources/`/`Shared/` untouched) |
| 5 | **Canvas:** E7-bank (canvas bank) · E12 (drag jitter/resist — live-path trace, no archeology per her rider) | pending |
| 6 | **Comments & tags:** E7-comments (margin-hover grammar, comments on the LEFT) · E8 (the fuller tags face) | pending |
| 7 | **Text tools:** E9 (takes-aware find & replace) · E10 (copy-door flush alignment) | pending |
| 8 | **W26 (E14):** the system-wide ⌃⌥⌘N summon — the batch's own verification act is the SANDBOXED in-app registration | pending |

The kickoff sweep runs BESIDE the batches, orchestrator-owned: the
A47c experiments under BOTH lock states (locked runs when she is
away); the windowless launch stays CAPTURE-ON-OCCURRENCE (the
row's `sample <pid> 5`-first protocol); the note-window clip joins
whichever batch next touches window lifecycle (batch 8's orbit)
with its three already-failed fixes read first.

## Batch 1 brief — the door set (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads); this
plan file TOP TO BOTTOM (the P-1…P-9 constitution, the sitting
rounds — E13's ruling is Round 3 — and the Environment traps above
are all binding); the `architect-phase` skill's "Applying the
constitution" notes (`.claude/skills/architect-phase/SKILL.md`).
You do your own reading in your own context — never delegate it.

**Scope: E1 + E13 + E11 ONLY.** No other ledger row, however
adjacent it looks.

- **E1 — callout colour swatches + a real emoji picker.** Today's
  callout editor takes color and emoji through minimal controls;
  her A13(b) ask upgrades both. Constraints: a callout color is a
  THEME-TOKEN NAME, never a literal (AppSpec §7 `presentation`,
  R1) — swatches present the token palette rendered per
  voice/appearance and store the NAME; the emoji field gains a real
  picker (the native character palette
  `NSApp.orderFrontCharacterPalette` is the zero-dependency road —
  if you find yourself designing anything bigger, that is an
  in-batch design fork: PROPOSE to the architect before building
  that half). The upgraded controls appear at EVERY standing
  callout door — the Block menu / ⌥⌘C sheet, Write's right-click,
  a take card's right-click (13k K6 + #53(g)) — one control
  component, not per-door copies. Frame semantics byte-untouched
  (one frame per block; takes share it; take-mode draws around the
  fan).
- **E13 — duplicate-book-name refusal (her Round 3 ruling).** The
  create-book and rename-book DOORS refuse a case-insensitive
  match against any LIVE book's name (archived/deleted don't
  count) with honest wording ("A book named 'Ideas' already
  exists"). Door-level by her explicit word — NO schema, NO
  operation-level invariant, NO SyncSpec §7 repair (the offline
  race stays legal; 13k K4's shown-once display absorbs it). Shape:
  a small core read (the `assertReadingAcceptsPosts` precedent —
  store-truthful inside the door's serialized path, never a stale
  projection read), consulted by every door that names a book
  (create, rename, and the smart-book creation door if it names
  freely). Red-on-old pin: the door accepts the duplicate on the
  pre-fix tree, refuses after — behavioral revert with checksums.
- **E11 — declare the book-icon ascent (P-1 hygiene).** The
  "open this book at this note" act (the context bar's book icon +
  the membership chip's book rows — one ACT, its doors enumerated)
  enters the capability registry: availability rule (a note open;
  the icon renders greyed-with-tooltip on a bookless note per the
  ratified #55(b)/(g) shape — declaring must not change shipped
  behavior), refusal wording, registry-walk coverage. Nothing
  user-visible changes; the walk test growing to cover the doors
  IS the deliverable.

### BATCH 1 RECORD — the door set (2026-08-17, a fresh Opus implementer; COMPLETE)

**Shipped, per ledger row.**

- **E1 — callout colour swatches + a real emoji picker.** Both upgrades
  land in the ONE vocabulary (`CalloutMenu`), so all three standing
  doors get them without a per-door copy — which is what K6's
  consolidation was for.
  - **Swatches:** `CalloutMenu.Row` gained `swatch: String?` (the
    palette TOKEN NAME, set on exactly the five colour rows) and
    `CalloutMenu.swatchImage(for:dark:size:)` draws a 14pt rounded chip
    filled by `CalloutPalette.color(name, dark:)` — the SAME resolution
    the block's frame uses, so nothing new is stored (AppSpec §7 / R1:
    the stored value is the name) and a palette change reaches menus and
    blocks together. `isTemplate = false` + `accessibilityDescription =
    name`. Appearance comes from ONE reading
    (`CalloutMenu.isDarkAppearance()`, the app's effective appearance),
    because two of the three renderers are `NSMenu`s with no SwiftUI
    environment. Rendered by: the shared AppKit builder
    (`CalloutMenu.menuItem` → Write's right-click), the pane menu spec
    (`PaneTextView.MenuItemSpec` gained `image`; `TakesShared` passes
    the row's chip → a take card's right-click), and the SwiftUI menu bar
    (`EditorCommands` — a `Label` with `Image(nsImage:)
    .renderingMode(.original)`). Row WORDS untouched, so the K6 drift pin
    still compares identical titles across the three doors (#56(j)).
  - **Emoji picker:** the prompt's accessory is now
    `[ field ] [ Emoji & Symbols… ]` (`CalloutMenu.emojiAccessory`,
    returned as a value so a pin can inspect and fire it), whose button
    focuses the field and calls `NSApp.orderFrontCharacterPalette(field)`
    — the zero-dependency road the brief named, with NO design fork
    taken. It is an ACCESSORY button, not a third alert button, because
    an alert button ends the modal session and would dismiss the prompt
    the glyph must land in. Typing/pasting still works; the K6 contract
    (empty string = "no glyph", nil = cancel) is byte-unchanged.
- **E13 — duplicate-book-name refusal (her Round 3 ruling).** New pure
  Domain rule `BookNaming` (ends-trimmed + case-folded key; internal
  spacing and diacritics deliberately NOT folded — #56(e)) and one core
  read `Operations.assertBookNameIsFree(_:excluding:)` throwing the new
  `OperationError.duplicateBookName(name:)` (payload = the EXISTING
  book's stored casing, so the refusal names back the book she already
  has). Live = `deleted_at IS NULL`: a FINISHED book counts, a deleted
  one does not (#56(a)/(b)). `createReading`/`renameReading` are
  BYTE-UNCHANGED — the guard is door-level by her explicit word, so the
  seeders, `shelveInDailyJournalBook`'s never-throwing create-and-pin
  and the sync apply path cannot refuse for a name reason (#56(h)),
  pinned by `createAndRenameStillAcceptDuplicateNamesThemselves`. FIVE
  Mac doors consult it INSIDE their own runner closure (bodies are
  synchronous, so no other door's write interleaves; only the
  cross-device race her ruling tolerates survives): the shelf's New Book
  (all three buttons) + Rename (`ReadingsViewModel`), the navigator's
  Rename (`BookStructureModel`), Settings ▸ Promote to Book
  (`PromoteTagsSheet` — which also stopped dumping raw enums, the R93
  class), and BOTH conversion doors' TYPED fresh-collector name (the
  derived default is deliberately unguarded — #56(f)). Ruled wording in
  ONE home (`BookNameCopy.refusal(existing:)`), read by both
  `ReadingsViewModel.message` and `OpsRefusalCopy.message`. NO schema,
  no operation-level invariant, no §7 repair.
- **E11 — the book ascent, declared (P-1 hygiene).** New
  `CapabilityID.openBookAtNote`: verb "Open Book at This Note", scope
  `.book`, doors `[.surface]`, no chord, `unavailableNote` =
  `WorkspaceNaming.ascentUnavailableNote` (the written refusal #55(i)
  said it lacked), availability gated on the new
  `CapabilityContext.canAscendToBook` (the `canStarCurrent` family).
  Both renderers of the one act now declare it —
  `ContextBar.surfaceCapabilities` and
  `MembershipChip.surfaceCapabilities` — and `ContextBar.bookEnabled`
  READS the registry instead of re-deriving `!books.isEmpty`, so the
  declaration is load-bearing rather than decorative while staying
  byte-identical to the shipped face (#55(b)/(g): grey with a tooltip on
  a bookless note). Registry-walk additions: a sampled context carrying
  `canAscendToBook`, and the R118 exemption beside `.openPeerPost` with
  its reasoning stated (a navigation act, and literally reachable from
  Takes — both doors render above the mode row).

**Mechanisms traced (the hallucination guard).** E13 is a new rule, not
a bug fix, and its mechanism is the one her observation named: nothing
anywhere consulted book names, so `createReading`/`renameReading`
accepted "Ideas" twice and 13k K4's card row showed the name once —
verified by the pre-fix reverts below, where the second book really is
minted. E1's mechanism: the three renderers built menu items with a
title and no image and the emoji prompt built a bare `NSTextField`, so
there was no chip and no picker to press — again verified by revert. E11
changed no behaviour by design, so it carries no bug mechanism; its
proof is the flipped `ContextBar.surfaceCapabilities` expectation.

**Pins + red-on-old evidence (behavioral revert, checksums recorded).**
New core file `Tests/VariorumCoreTests/BookNameGuardTests.swift` (7
tests, 2 suites) and new Mac file
`App/Variorum/VariorumTests/DoorSetTests.swift` (15 tests, 4 suites).

*Group A revert — the four E13 door asserts deleted (the pre-13e door
shape). Files reverted:* `ReadingsViewModel.swift`
`4cae903b…1b596` → `05e1cc7f…a7ee`; `BookStructureModel.swift`
`b133e84d…88ce` → `1aa1588c…38a8`; `ShelfViewModel.swift`
`7c6a575e…f433` → `35b28ec5…fa11`. Result: **all four pins RED, each for
its own door** — `theShelfsNewBookDoorRefusesANameAlreadyTaken` (5
issues; the store ends holding two "Ideas"),
`theShelfsRenameDoorRefusesAnotherBooksNameButNeverItsOwn` (2),
`theNavigatorsRenameDoorCarriesTheSameGuard` (2),
`theConversionsTypedCollectorNameIsGuardedAndTheDerivedOneIsNot` (5 —
the report line shows the fresh `"ideas"` collector really was minted).
Restored: both checksums back to `4cae903b…`, `b133e84d…`, `7c6a575e…`.

*Group B revert — four E1 lines (the swatch assignment in
`CalloutMenu.menuItem`; the palette lookup in `swatchImage`; the picker
button's place in the accessory stack; `menuItem.image = spec.image` in
`PaneTextView.makeMenuItem`). Files:* `CalloutMenu.swift`
`df406f95…d865` → `a4608884…dbd9`; `PaneSurface.swift`
`757d8d07…1835` → `7a06bda1…0c96`. Result: **exactly the four
corresponding pins RED** —
`theSharedMenuBuilderDrawsASwatchOnEveryColourRow` (Blue's `image` is
nil), `theSwatchPaintsThePalettesOwnColourPerAppearance` (12 issues,
including both distinctness checks),
`aPaneMenuSpecCarriesItsSwatchThroughToTheItem`,
`theAccessoryOffersTheSystemPickerBesideTheField` — while
`onlyTheColourRowsCarryASwatchToken`,
`pressingItOpensThePickerAtTheField` and `anEmptyAnswerIsStillARealAnswer`
stayed GREEN (they do not depend on those lines — clean attribution).
Restored: `df406f95…d865`, `757d8d07…1835`.

*E11's proof is the JUSTIFIED EDIT* to `BookAscentTests
.theFoldIsOneDeclaredActWithOneKey`, whose exact-list expectation on
`ContextBar.surfaceCapabilities` encoded the pre-E11 (undeclared)
state and now names the fourth element; the pre-13e registry has no
`.openBookAtNote` at all, so the flip IS the red-on-old. Called out in
the test's own comment per the 13b 4D convention. The E11 behaviour pins
(`theBarsBookDoorIsGatedByTheRegistry`) pass on BOTH sides deliberately —
"declaring must not change shipped behaviour" is the deliverable's claim,
and a red there would have been the bug.

*A note on the colour pin's shape (worth keeping):* the first version
compared the drawn pixel against a fixed sRGB triple and failed by up to
0.054 per channel — the drawing context is the device's, so a fixed-space
comparison crosses a profile hop. It now compares the swatch against a
flat reference chip drawn through the SAME `NSImage` path (plus two
distinctness checks), which is exact and cannot be satisfied by a
tolerance wide enough to accept a wrong colour.

**Counts (own runs, quoted from the "Test run with N tests" lines).**
- Core: **`✔ Test run with 1223 tests in 130 suites passed`** (baseline
  1216/128 → +7/+2, exactly the new core file).
- Mac: **`✘ Test run with 1266 tests in 224 suites failed … with 1
  issue`** — the ONE issue is
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergence
  Occasion`, the recorded environment-gated tripwire, allowed by
  IDENTITY.
- **BASELINE CORRECTION (verified, worth the phase's while):** the
  carried-forward Mac baseline of **1246/220 is 5 tests low**. This
  batch ran the Mac suite in a throwaway git worktree at the pristine
  kickoff commit `6346853` (own DerivedData, removed afterwards) and got
  **`✘ Test run with 1251 tests in 220 suites failed … with 1 issue`** —
  the same single tripwire red. So the true pre-batch baseline is
  **1251/220 tripwire-only**, and this batch's +15/+4 lands exactly on
  1266/224. (The kickoff section had recorded the Mac run as *pending*;
  this closes it.) **A47c datum, free:** the tripwire fired on a pristine
  HEAD in an UNLOCKED session (`CGSSessionScreenIsLocked = 0`) — evidence
  for the sweep's covariate question, and proof the red is nothing this
  batch touched.
- Mobile: **`✔ Test run with 314 tests in 60 suites passed`** (iPhone
  16e / iOS 26.2 — run because E13's rule lands in `Sources/`; baseline
  matched exactly).
- Tutorial spine, by TYPE name (all seven): **`✔ Test run with 51 tests
  in 7 suites passed`**.

**PROVISIONALs / build-time calls:** fifteen, bundled as **QUESTIONS
#56** (a)–(o) — the finished-book and deleted-book halves of "live", the
second-unnamed-book refusal, casing-only renames, the fold's deliberate
narrowness, the typed-vs-derived collector name, all-or-nothing
conversion refusal, doors-not-operations, the unguarded phone doors, the
swatch's words/appearance/Remove-row calls, the system emoji picker, and
E11's scope/keylessness/parity exemption. Two of them are HAND-CHECKS no
test can drive: whether a glyph clicked in the system palette lands in
the modal prompt's field (#56(m)), and whether SwiftUI draws the menu
bar's chips in colour (#56(n)) — the two `NSMenu` doors' chips are pinned.

**Nothing stopped, nothing schema-shaped.** No design fork appeared: the
emoji picker stayed on the brief's named road
(`orderFrontCharacterPalette`), and no ledger row outside E1/E13/E11 was
touched. `Sources/VariorumCore/Sync/` untouched; no migration; no mirror
implication; no `/Applications` refresh (her real-store instance, PID
54789, was live the whole batch and was never addressed).

**MOBILE PARITY (for the closeout ledger):** the phone owes the
**duplicate-book-name refusal at its own two doors** —
`MobileCreateBook` and `MobileBookDetails`' rename — one
`assertBookNameIsFree` line each, since the rule already lives in core
(#56(i)). Also open, if she wants it: the phone's callout controls
(`MobileCallout`/`MobileBlockMenu`) have neither swatches nor a picker.
E11 is Mac-registry-only and owes the phone nothing.

---

**The loop (binding):** red-on-old pins by behavioral revert with
checksums; PROVISIONAL-and-continue for non-gating ambiguity
(append to `notes/QUESTIONS.md` — next free number **#56**);
STOP-and-report for anything gating or schema-shaped; the tutorial
spine green by TYPE name; full suites at batch end with counts
quoted from your own "Test run with N tests" lines — baselines to
match-or-beat: **core 1216/128 · Mac 1246/220** (the ONE allowed
red is the recorded tripwire, by identity) **· mobile 314/60 —
mobile runs because E13's core read touches `Sources/`** (iPhone
16e destination). Run builds/tests SYNCHRONOUSLY in your session —
never end your turn to "wait" on a background run (a session that
ends waiting dies as completed). Append the batch record to this
file (what shipped, mechanisms traced, pins with checksums, counts,
PROVISIONALs) BEFORE final claims only with PENDING marks; commit
per convention with the standing trailer; NEVER push; NEVER
`/Applications`; her real-store instance is never touched (the
Environment traps above bind verbatim).

**ARCHITECT ACCEPTANCE (2026-08-17):** Batch 1 ACCEPTED on spot-checks —
`b20bcc2` verified (tree clean; `swift build` clean, so the post-commit
SourceKit "Cannot find BookNaming" diagnostics were stale indexing;
`BookNameGuardTests` re-run green 7/2 by the architect's own run; the
createReading/renameReading byte-unchanged claim corroborated by the
+53/−0 `Operations+Reading.swift` diff; the plan record + QUESTIONS #56
confirmed in the commit). **The Mac baseline stands CORRECTED: the true
pre-batch figure was 1251/220 tripwire-only** (the implementer's
throwaway-worktree run at `6346853` — this CLOSES the kickoff's pending
Mac-baseline verification; the carried-forward 1246/220 was 5 low), so
batch 1's 1266/224 is exactly +15/+4. **Free A47c datum recorded for
the sweep:** the tripwire fired on the PRISTINE kickoff tree in an
UNLOCKED session (`CGSSessionScreenIsLocked = 0`, 2026-08-17) — with
13k's locked-session fire, the tripwire has now fired in BOTH states;
the A47c re-run starts from "fires regardless of lock state" as the
working hypothesis.

**HELD FOR THE NEXT SITTING (running bundle — grows per batch, walks at
the checkpoint):**
- #56(m) — the one hand-check no test can drive: a glyph clicked in the
  system Emoji & Symbols palette actually lands in the modal prompt's
  field.
- #56(n) — whether SwiftUI tints the menu-bar door's colour chips (the
  two NSMenu doors' chips are pinned; the third is the eyeball).
- The mobile parity flags from batch 1 (for the closeout's parity
  line): the phone owes the duplicate-name guard at `MobileCreateBook`
  + `MobileBookDetails` rename (one line each — the rule is in core),
  and, AT HER WORD, swatches/picker for `MobileCallout`/`MobileBlockMenu`.

## Batch 2 brief — the fan's hands (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads — AppSpec §9's
operations material and SyncSpec §8's ordering rules bind this batch);
this plan file TOP TO BOTTOM (constitution, sitting rounds, Environment
traps, batch 1's record, this brief); the "Applying the constitution"
notes in `.claude/skills/architect-phase/SKILL.md`; the KnownIssues rows
named below VERBATIM (`notes/KnownIssuesAndTechDebt.md`); **and the 13c
intake ledger's row A18** (`notes/plans/phase-13c-book-forms-and-conversions.md`)
— E3 builds HER ask, so her verbatim words are the spec; if the ledger's
words underdetermine the gesture's shape, that is an in-batch design
fork: PROPOSE to the architect before building that half. Do your own
reading; at most ONE read-only lookup subagent, external facts only.

**Scope: E4 + E15 + E3 ONLY.**

- **E4 — reorder takes (A19).** The Takes board gains take reordering;
  `fan_position` moves through `FractionalIndex.between` with jitter —
  ordering like every other (SyncSpec §8: no rebalance exists; sort key
  stays `(position, id)`; pin the jittered-key write like every other
  ordering op). Trace the existing block `reorder` op and MIRROR its
  shape (touch/churn/undo semantics — reorder is on the structural-undo
  list; a fan reorder entry should register inverse AND redo from
  do-time pre-images like every 13c-era registration; if any semantic
  is genuinely undefined for the fan case, PROVISIONAL-and-continue).
  Registry-declare the act with its doors.
  - **The fan-copy remap fix lands WITH E4** (its KnownIssues row —
    read it): `poolDragCopy` (`Operations+Pool.swift`) and `copyPost`
    (`Operations+Versions.swift`) remap `parent_variant_id` in ONE pass
    assuming parent-precedes-child in fan order; reorder-takes
    falsifies the premise. Fix with the row's named FIX-2 template
    (pre-assigned IDs + second pass); the row names the fixture:
    `aParentThatFollowsItsChildInFanOrderStillRemaps` — red-on-old
    against a reordered fan, behavioral revert with checksums. Note the
    row's resolution in your record (the closeout clears it).
- **E15 — the Takes board's projection-delivery policy routing** (its
  KnownIssues row — read it). `TakesViewModel` adopts clean-instant AND
  deferred deliveries OUTSIDE the shared `EditorProjectionEngine`
  policy that guards both editor surfaces. Either policy-route the
  board (red-on-old: reproduce the stale/keystroke-in-window class on
  the board pre-fix — the row cites the mobile S3 ladder's fix with
  pins on both platforms as the template), or RE-RECORD the residual
  with evidence (the hallucination guard: a re-record needs the traced
  mechanism for why the board is safe, not a shrug).
- **E3 — ⌘-click merge selection in Takes (A18, HER ask).** Build to
  the intake row's words. Canon that binds whatever the shape: merge
  semantics are AppSpec §9's (`merge`/`mergeCeremony` — nothing
  cartesian, adjacency, the seal refusal); the ceremony's ENTRY shape
  is untouched (the quick/ceremony DEFAULT flip is 13j's row 4b, NOT
  this batch); doors registry-declared, fire-and-DO, refusals honest.

**The loop (binding, unchanged):** red-on-old by behavioral revert with
checksums; PROVISIONAL → QUESTIONS.md (next free **#57**); STOP on
anything schema-shaped or gating; ZERO `Sources/VariorumCore/Sync/`
lines; spine green by TYPE name; full suites with counts from your own
"Test run with N tests" lines — **baselines to match-or-beat: core
1223/130 · Mac 1266/224 (the ONE tripwire red allowed by identity) ·
mobile 314/60 · spine 51/7**; mobile runs (E4's core work touches
`Sources/`; iPhone 16e destination). Builds/tests SYNCHRONOUS — never
end your turn on a background wait. Append your batch record here
BEFORE final claims only with PENDING marks; commit per convention;
NEVER push; NEVER `/Applications`; her real-store instance is never
touched (Environment traps bind verbatim; Mac tests via the
cwd-independent `-project` invocation).

### BATCH 2 RECORD — the fan's hands (2026-08-17, a fresh Opus implementer; COMPLETE)

**Shipped, per ledger row.**

- **E4 — reorder takes (A19), plus the fan-copy rider that lands WITH it.**
  - **The op:** `Operations.reorderTake(_:to:)` (`Operations+Variant.swift`),
    `reorder`'s shape one table over. `fan_position` now resolves through the
    SAME ordered-list resolver every pointer list uses — `OrderedList` gained
    a `positionColumn` (default `"position"`; the fan passes `"fan_position"`)
    and `fanPosition(_:blockID:at:)` is its door, so the jitter, the
    `(position, id)` sort key and the no-rebalance rule (SyncSpec §8) are
    literally the same code rather than a second copy of the neighbour
    arithmetic. **No touch, no churn** (block `reorder` stamps neither, and
    §9's touch-list names divide-W/merge/poolDragCopy — not reordering); the
    SEAL refuses through `ensurePlacementUnlocked`; **undo AND redo from
    do-time pre-images** via the new exact-row inverse
    `restoreFanPosition` (`Operations+UndoInverses.swift`), so ping-pong never
    re-derives a key and drifts. A locked/archived take may be moved
    (`setTakeLabel`'s ratified precedent — #57(a)); a move relative to itself
    writes nothing (#57(f)); a foreign anchor refuses `variantNotFound`.
  - **The door:** the take CARD's own arrows, on `TakeChooseHeader` — ◀ ▶ in
    carousel / slot split / the rail, ▲ ▼ in the stack (#57(e)), the end
    direction greyed (the pager's disabled-◀ grammar), and NO arrows at all on
    a one-take fan (P-2). `TakesViewModel.moveTake(_:in:by:)` flushes first and
    reads the fan **from the STORE** (13d batch 3's precedent: the projection
    is frozen while dirty, so a projection-read neighbour is an enablement hint
    and never an authorization), stepping within the ACTIVE fan (#57(b)).
    Registry: `.moveTakeEarlier` / `.moveTakeLater`, `.surface` doors, keyless
    (#57(d)), availability on the new `takesBoard` rule (attachment OR
    `mode == .takes` — 13c 2B's lesson, which the older `pageFan` pair
    predates), declared in `TakesBoardView.surfaceCapabilities`.
  - **THE FAN-COPY RIDER, RESOLVED** (KnownIssues *"Single-pass fan-copy remaps
    assume parent-precedes-child"*, owner 13e): `poolDragCopy` and `copyPost`
    now copy through ONE machine, `Operations.copyFan`, whose second pass lands
    a FORWARD parent pointer after every row exists — `mintFanBlock`'s FIX-2
    template in shape, and the row's premise falsified exactly as it predicted
    (the pins build the state through the real `reorderTake`, not hand-written
    SQL). The two call sites were byte-identical loops, so this is one
    implementation replacing two, not a new abstraction.
- **E15 — the Takes board joins the ONE projection-delivery policy**
  (KnownIssues *"The Mac Takes board adopts projection deliveries directly"*,
  owner 13e; POLICY-ROUTED, not re-recorded). `start()` now calls
  `deliver(_:)` → `applyProjection(_:fromDelivery:)`, which executes
  `EditorProjectionPolicy.decide` — the same brain both editor surfaces run —
  and `onSettled` no longer ADOPTS the held photograph: it bumps a
  `storeWriteGeneration` fence and settles through `applyPendingIfClean()`,
  which re-reads `Queries.takesProjection` and adopts the FRESH value. The
  board's render arms collapse into adoption (it has no text surface to rewrite
  differentially), so what the policy buys is its precedence: not-loaded ▸ busy
  ▸ echo ▸ delivery-refetch. Two deliberate calls, both recorded: `busy` stays
  the board's standing dirty-buffer condition (a structural flight is NOT
  folded in — the board has no flight-exit settle hook, #57(g)), and the echo
  check is STRICT (any live buffer ⇒ refetch, #57(h)).
- **E3 — ⌘-click merge selection in Takes (A18, HER ask, built to her words).**
  `PaneTextView` gained `onCommandClick` — asked AFTER the link door (13g L10's
  ⌘-click ruling wins on the shared chord, #57(i)) and BEFORE selection
  tracking, consuming the click so the ring does not migrate (#57(j)); wired
  through the coordinator like every other callback, and nil everywhere but the
  Takes board's article cells (#57(o)). The selection is session-only view
  state on `TakesBoardLayout` (the expansion class) with a pure
  `isContiguousRun(_:in:)` rule and a `pruneMergeSelection(to:)` the conductor
  feeds at adoption (#57(n)). `mergeSelectedBlocks()` reads order AND arity
  from the STORE, then forks the ruled way: **a fanned PAIR carries to Write**,
  where the ceremony lives (S4-23(4) untouched; the default flip is 13j's row
  4b — #57(k)), and **everything else merges right here** as a left-to-right
  chain of the ordinary binary `merge` under ONE `withCompound` entry ("Merge
  Blocks") — byte-for-byte Write's `mergeChain` behaviour, including the
  speak-about-folded-fans line (#57(l)), which is what keeps Takes from sitting
  behind Write (R118). Doors: the article cell's context menu (rendered only
  with ≥2 picked — the `.diffAgainstChosen` per-target shape) and the board's
  selection banner; declared as ONE act, `.mergeSelectedBlocks`, with both door
  families. `TakesChoreographer.moveToWriteAndRun` gained an explicit
  `targetBlockID:` (default = today's routed target, so every pre-13e caller is
  unchanged) and REFUSES a named-but-missing target rather than silently
  retargeting.

**Mechanisms traced (the hallucination guard).** E15's mechanism, traced on
this surface before any fix: an observation value fetched BEFORE a flush is
consumed after it settles; the old rule adopted it, `authority.settle` then
cleared the no-longer-pending buffer, and every pane mirroring that variant
fell back to the projection's PRE-FLUSH text — after which a keystroke computes
its delta against the stale text (`paneEdited` → `currentStoreText`) and
autosaves it over the newer store text. The old settle path had the same hole
from the other side. The fan-copy mechanism is the row's, re-traced: the
`ORDER BY fan_position, id` walk sets `parent_variant_id` in one pass, and
`parent_variant_id` is an IMMEDIATE foreign key, so a parent sitting LATER in
fan order makes the insert a forward reference — the whole copy throws (proven
below: `SQLite error 19: FOREIGN KEY constraint failed`). E4 and E3 are
features, not bug fixes, and carry no bug mechanism.

**Pins + red-on-old evidence (behavioral revert, checksums recorded).** New
core file `Tests/VariorumCoreTests/FanOrderTests.swift` (12 tests, 2 suites)
and new Mac file `App/Variorum/VariorumTests/FanHandsTests.swift` (19 tests,
3 suites).

*Revert A — the FIX-2 second pass removed (the pre-fix single pass restored
inside `copyFan`). File:* `Operations+Variant.swift`
`0e3f0ac2…41aca` → `03366612…d72fe`. Result: **exactly the two rider pins RED**
— `ReorderedFanCopyTests.aParentThatFollowsItsChildInFanOrderStillRemaps` (the
row's named fixture, poolDragCopy) and `aDuplicatedPostRemapsAForwardParentToo`
(copyPost), both dying on `SQLite error 19: FOREIGN KEY constraint failed`
inside the write — while the whole of `PoolDragCopyTests` and
`VersionOperationsTests` stayed green (25 tests, 2 issues; clean attribution).
Restored: `0e3f0ac2…41aca`.

*Revert B — E15's two lines put back to the pre-13e rule (`deliver` adopts
whenever clean; `onSettled` adopts the held photograph). File:*
`TakesViewModel.swift` `45b9f1a5…ae150` → `6c311013…45cea`. Result: **the three
delivery pins RED with the exact stale symptom** —
`aDeliveryFetchedBeforeAFlushNeverRegressesTheBoard` (`"Original."` where the
store holds `"Typed while in flight."`),
`aStaleDeliveryArrivingCleanIsRefetchedRatherThanAdopted` (`"Original."` over
`"Newer text."`), and `aDeliveryWhileDirtyStillDefersAndTheSettleReadsTheStore`
(`"One."` where the buffer held `"One, edited."`) — while E4's and E3's pins
stayed green (19 tests, 3 issues, all in the delivery suite). The fourth
delivery pin (`anIdenticalDeliveryIsAdoptedOnTheSpotWithNoRefetch`) passes on
BOTH sides deliberately: the echo arm is behaviour-preserving by design, and a
red there would have been the bug. Restored: `45b9f1a5…ae150`.

*E4's and E3's pins are feature pins, not bug pins* (no red-on-old is owed):
the fan-order suite covers the jittered key sorting strictly between its new
neighbours AND differing on a repeat into the same gap (the §8 pin), the
untouched-neighbour keys, the outbox row landing on the moved row alone, the
container row byte-unchanged (no touch, no churn), the seal refusal, the
locked/archived allowance, the foreign anchor, the self-anchored no-op, and
undo→redo→undo on the exact keys; the door suite covers the store-read flush
contract, both end refusals, a take that left the fan, both registry
declarations, the pure contiguity rule, the 2-block and 3-block merges under
ONE undo entry (with the undo restoring all three whole), the gapped refusal
minting nothing, the one-picked refusal, the fanned-pair CARRY (intent block,
offset, follow-up, the visible mode switch, nothing merged), the fanned-run
speak line, and the selection's pruning.

**Counts (own runs, quoted from the "Test run with N tests" lines).**
- Core: **`✔ Test run with 1235 tests in 132 suites passed`** (baseline
  1223/130 → +12/+2, exactly the new core file).
- Mac: **`✘ Test run with 1285 tests in 227 suites failed … with 1 issue`** —
  the ONE issue is
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
  the recorded environment-gated tripwire, allowed by IDENTITY (baseline
  1266/224 → +19/+3, exactly the new Mac file). **A47c datum:** it fired again
  in an UNLOCKED session (`CGSSessionScreenIsLocked = 0`), consistent with
  batch 1's "fires regardless of lock state" hypothesis.
- Mobile: **`✔ Test run with 314 tests in 60 suites passed`** (iPhone 16e —
  run because E4/FIX-2 land in `Sources/`; baseline matched exactly).
- Tutorial spine, by TYPE name (all seven): **`✔ Test run with 51 tests in 7
  suites passed`**.

**PROVISIONALs / build-time calls:** fifteen, bundled as **QUESTIONS #57**
(a)–(o) — the locked/archived allowance, the active-fan stepping rule, no
touch/churn, keylessness, the glyphs + greyed ends, the self-anchored no-op,
E15's dirty-buffer-only busy arm and strict echo check, the link-vs-selection
chord, the consumed click, the fanned-pair carry, the fanned-run chain + speak,
store-read adjacency, the session-only selection, and the article-cells-only
gesture.

**KnownIssues dispositions (both rows this batch owned).**
- *"Single-pass fan-copy remaps assume parent-precedes-child"* (owner 13e) —
  **RESOLVED** at the mechanism, with the row's own named fixture
  (`aParentThatFollowsItsChildInFanOrderStillRemaps`) red-on-old. The closeout
  clears the row.
- *"The Mac Takes board adopts projection deliveries directly"* (owner 13e) —
  **RESOLVED by policy-routing**, not re-recorded: the board runs
  `EditorProjectionPolicy` and settles through a fresh read, with red-on-old
  pins on both roads. The closeout clears the row. Checked while here: the
  PHONE's takes projection already ingests through the same policy
  (`MobileEditorViewModel.observeTakesProjection` → `ingest(_:fromDelivery:)`),
  so the class is now closed on both platforms.

**Nothing stopped, nothing schema-shaped.** No design fork appeared: A18's
words determined the gesture (⌘-click, several-when-fanless) and the two
choices they left open — where a fanned pair goes, and what a fanned run does —
were settled by RULED canon (S4-23(4)) and by Write's own shipped behaviour
(R118), not invented. `Sources/VariorumCore/Sync/` untouched (zero lines); no
migration, no mirror implication, no `/Applications` refresh; her real-store
instance (PID 54789) was live the whole batch and was never addressed.

**MOBILE PARITY (for the closeout ledger):** the phone owes **reorder-takes**
a door — the core op `reorderTake` is shared, so its takes surface needs the
arrows (or a drag) and nothing else; and, AT HER WORD, a phone shape for the
**⌘-click merge selection** (a pointer chord has no phone twin — the phone's
fanned merge is the shipped carry-all, C5). E15's fix is Mac-only by
construction (the phone was already policy-routed), and the fan-copy fix rides
core, so the phone has it already.

**ARCHITECT ACCEPTANCE (2026-08-17, batch 2):** ACCEPTED on spot-checks —
`e0b3d5e` verified (tree clean; core build clean; `FanOrderTests` re-run
green 12/2 by the architect's own run; the diff stat corroborates the
report — zero `Sync/` files, the FIX-2 rider landing in
`Operations+Pool.swift`/`Operations+Versions.swift` through the one
`copyFan` machine, QUESTIONS #57 + the batch record in the commit).
Both KnownIssues rows (fan-copy remap · Takes-board policy) are
RESOLVED in the record — their table rows clear at the closeout per the
file's own rule, after the ladder confirms. A47c fired again unlocked
(second pristine-tree datum). Held-bundle addition: none new beyond the
parity flags (the phone owes a reorder-takes DOOR — core op shared; a
phone shape for ⌘-click selection is at her word). Next free QUESTIONS
number: **#58**.

## Batch 3 brief — take↔block structure (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads — OverallModel
§4's invariants, I1/I7/I10 especially, and AppSpec §9's structural ops +
comment-travel rules bind this batch); this plan file TOP TO BOTTOM;
the "Applying the constitution" notes in
`.claude/skills/architect-phase/SKILL.md`; **the 13c intake ledger rows
A20 and A21** (`notes/plans/phase-13c-book-forms-and-conversions.md`) —
E5/E6 build HER asks, her verbatim words are the spec — **and, same
file, the "sub-takes finding" section (A45)**: it reframes E6 as the
REPAIR TOOL for "my takes should've been blocks," which is the purpose
your shape must serve. Do your own reading; at most ONE read-only
lookup subagent, external facts only.

**Scope: E5 + E6 ONLY.**

- **E5 — move-a-take-into-a-block-below (A20).** A take leaves its fan
  and becomes its own block adjacent-below. **E6 — copy-all-takes /
  takes-to-blocks (A21).** The whole fan (or its copy) becomes a run of
  sibling blocks — the A45 repair for work already shaped wrong.
- **THE ONE DESIGN FORK, NAMED UP FRONT — propose before building:**
  does the take's VARIANT ROW move to the new block (UPDATE
  `variant.block_id` — preserves the take's commits, labels, identity;
  a WRITE PATTERN NO EXISTING OP USES), or does the new block mint a
  FRESH variant copy (the divide/poolDragCopy precedent — commits are
  never copied, history stays behind on the source)? The A45 repair
  framing argues for preservation (the point is that these takes always
  should have BEEN blocks); the mint-copy road is the proven pattern.
  Trace both against I1/I10, sync (a `block_id` flip is metadata CAS —
  state what a concurrent edit/tombstone race does), undo (exact-row
  both ways), and the RESTRICT/chosen-variant guards — then PROPOSE
  with a recommendation and WAIT for the architect's ruling before
  building that half. Everything else (doors, refusals, tests for the
  unforked parts) may proceed meanwhile.
- **Canon that binds whichever shape wins:** I7 stays absolute (this is
  the sub-takes ANSWER, never nesting); lineage edges use EXISTING
  `origin_op` values only ('manual' or NULL — the CHECK constraint is
  DDL: ANY new value is schema-shaped → STOP); minted/receiving blocks
  place via fractional keys; comment travel follows the structural-
  successor COPY rules (AppSpec §9 — state your choice per op,
  PROVISIONAL where canon underdetermines); presentation inheritance
  per the same section; I10 at every edge (the LAST take leaving a fan
  = what? — trace, don't guess: refusal vs block-conversion is likely
  A20/A21-wording-dependent, PROVISIONAL if her words don't say); seal
  refuses everything; structural undo entries carry inverse AND redo
  from do-time pre-images; every door registry-declared, fire-and-DO.
- E6's copy-all-takes half: if A21's words cover both a COPY shape and
  a CONVERT shape, build what her words say and PROVISIONAL the
  boundary — never silently pick.

**The loop (binding, unchanged):** red-on-old by behavioral revert with
checksums; PROVISIONAL → QUESTIONS.md (next free **#58**); STOP on
anything schema-shaped; ZERO `Sources/VariorumCore/Sync/` lines; spine
green by TYPE name; full suites with counts from your own "Test run
with N tests" lines — **baselines to match-or-beat: core 1235/132 ·
Mac 1285/227 (the ONE tripwire red allowed by identity) · mobile
314/60 · spine 51/7**; mobile runs (core ops touch `Sources/`; iPhone
16e destination). Builds/tests SYNCHRONOUS — never end your turn on a
background wait. Append your batch record here BEFORE final claims
only with PENDING marks; commit per convention; NEVER push; NEVER
`/Applications`; her real-store instance is never touched (Environment
traps bind verbatim; Mac tests via the cwd-independent `-project`
invocation).

**ARCHITECT RULING AR-1 (2026-08-17 — batch 3's propose-first fork,
ruled on the implementer's trace after the architect independently
verified its two decisive claims in `Repairs.swift`/`Merge.swift`):
ROAD B — MINT-COPY; the source take is ARCHIVED.** Grounds, in order
of force: **(1)** Road A (moving the variant row's `block_id`) is not
architecturally available in this phase: closing its move/move I10
hole needs a NEW SyncSpec §7 repair class (verified — the repair
candidate set is populated from the ARRIVING row's `block_id` only,
so the block a take LEFT never becomes a candidate; the race
converges to a live placed block with zero live variants and no
self-heal), it falsifies the repair layer's documented-unreachable
foreign-chosen state, and it routes cross-block parent pointers
through the conflict-rescue door (verified — the rescue inserts on
the SERVER row's block carrying the LOCAL row's parent). A spec
change plus `Sync/` surgery is outside the batch, the phase, and the
standing rider — and would be the wrong design regardless: it
enlarges the exact state space every ratified repair was written
against. **(2)** Road B composes with the ratified repairs (its
race self-heals through the EXISTING archive/archive I10 rescue),
its I10 guard is already pinned (`ensureNotLastActive`), and its
undo/redo bodies already exist. **(3)** The A45 repair intent is
honored by ARCHIVE, not row surgery: nothing is lost — the source
take, WITH its commits, label and lock, stays reachable in the
block's archived listing; "coarse, not forensic" accepts history
staying with the source (the divide / restoreCommit-predates-split
precedent), and `archiveVariant` is the one disposal door that
legally accepts a CHOSEN take (tombstone would refuse E5's
commonest case — moving the take you're looking at).

**The six calls, ruled defaults — ALL still logged PROVISIONAL
(#58+) for her ratify list:** (a) ARCHIVE — part of AR-1. (b) a
LOCKED take: trace what `archiveVariant` does with a locked variant
TODAY and follow that door exactly — permit if it permits, refuse
with its own refusal if it refuses; the copy is not born locked
either way (the copy doctrine); never a third behavior. (c) E6b
keeps the CHOSEN take on X — order shown-then-alternates, coherent
with copy-all-takes, and a conversion must never silently change
what the note reads as. (d) blank takes SKIPPED (the
`divideSideWouldBeEmpty` refusal family — minting empty blocks
serves nobody); say so in the door's receipt if one exists. (e)
chords GRANTED — her A20/A21 words ask for shortcuts: ⌥⌘⏎ (E5) and
⇧⌥⌘⏎ (E6b) under the standing collision pin; exact keys hers to
re-pick. (f) archived takes ride nowhere — the divide-W
unmarked-variant precedent, exact.

### BATCH 3 RECORD — take↔block structure (2026-08-17, a fresh Opus implementer; COMPLETE)

**Shipped, per ledger row — under AR-1 (mint-copy, the source take ARCHIVED).**

- **E6 (A21's CLIPBOARD half) — "copy all takes together to clipboard."** Built
  BEFORE the propose-first stop, since it carries no fork. The format is not
  invented: `Queries.blockTakes` returns `exportBlock`'s own projection PLUS its
  take count from the same walk (`exportBlock` now delegates — output
  byte-identical, `ExportProjectionTests` re-run green), so the clipboard
  carries the app's ratified fan shape — the shown take, then the labeled
  `--- Alternates for this block ---` section, literally the format her intake
  note was exported in — and the confirmation can never claim a different
  number than the text holds. ONE brain (`TakeClipboard`, with an injectable
  `Destination` so pins never touch her real clipboard) behind both doors:
  Write's caret block (`copyCaretBlockTakes`) and a board's focused card
  (`copyAllTakes`), both flushing first. Registry `.copyAllTakes` — ⌘⇧C (the
  sweep found no `c` chord bound but ⌥⌘C; ⌘C stays the system's Copy) — menu
  bar + take-card doors, helper row, routed through all four handlers (Compare
  declines, its recorded 4C posture).
- **E5 (A20) — `Operations.takeToBlockBelow(blockID:variantID:)`.** ONE
  transaction: mint a block immediately after the source carrying the take's
  text (label riding — the merge-carry precedent; presentation inherited;
  live comments COPIED — extract's travel rule), a `derived_from`/'manual'
  edge, then ARCHIVE the source take on its own block (the archive ROW work
  inline, byte-for-byte `archiveVariant`'s transition including the
  `default_variant_id` reassignment), touch-without-churn. Refusals, all from
  existing rules: I10 via `ensureNotLastActive` (a one-take fan), a BLANK take
  (`emptyTakeCannotBecomeABlock` — AR-1(d)), the seal via `placedContext`, and
  the `divideDuplicating` validation grammar for a foreign/archived/missing
  take. A LOCKED take is permitted because `archiveVariant` permits one TODAY
  (AR-1(b), traced — `performArchiveVariant` checks tombstone/status/seal/I10
  and never `locked`); the copy is not born locked.
- **E6b (A21's second half — the A45 repair) — `Operations.takesToBlocks(blockID)`.**
  ONE transaction, ONE undo entry: the take the slot RENDERS stays (AR-1(c) —
  the note reads exactly as it read), every other ACTIVE take with prose becomes
  its own block below in fan order (each mint anchored `.after` the previous, so
  the run reads in fan order), each source archived; blank takes SKIPPED and
  COUNTED (AR-1(d)), archived takes riding nowhere (AR-1(f)). Refuses
  `noConvertibleTakes` when the fan holds nothing else with prose. **The order
  it produces is the clipboard door's order** — shown take, then alternates —
  so the two halves of A21 agree by construction.
- **Undo/redo (both doors).** `revertStructural`/`reapplyStructural` gained
  DEFAULTED parameters (`unarchivingTakes:` / `rearchivingTakes:`) so the mint
  tombstone and the take's status flip land in ONE transaction and every
  pre-13e call site reads unchanged; `revertArchiveVariant`'s body was factored
  into a shared `unarchiveTakeRow` so there is one archive-inverse brain rather
  than a copy. Exact-row both ways (no row is minted by either half), the
  standing refusal buckets kept (a sealed post throws and keeps the entry;
  divergence is quiet), and the redo road runs `ensureNotLastActive` so
  re-archiving can never empty a fan the world changed under it.
- **Doors.** Registry `.takeToBlockBelow` / `.takesToBlocks` — TWO declarations
  (one addresses a take, one a fan; each carries its own key), scope `.take`,
  `takesAccess: .native`, `takeFamily` availability, doors `[.menuBar,
  .contextMenu]`, chords **⌥⌘⏎ / ⇧⌥⌘⏎** (AR-1(e); the Return family's only
  bound chords are ⌘⏎ and ⌘⇧⏎ — swept across `EditorCommands.keyEquivalent`,
  every `keyboardShortcut(` call site in `Variorum/`+`Shared/`, every
  `NSMenuItem` keyEquivalent and both key overrides). Native on THREE surfaces:
  Write (through `runStructural`, so the identity rewrite and caret landing are
  the standing ones), Takes and Lenses (flush-first, store-validated, the ring
  handing over to the minted block's pane). The card's right-click names its
  block AND its take explicitly (13k K6's lesson). Receipts live in ONE home
  (`TakeStructureCopy`) and every line says where the ORIGINAL went;
  `StructuralOutcome` gained an optional `note` so Write's receipt is built
  INSIDE the flight from the op's own result rather than re-derived beside it.
  Three refusals gained real words in `OpsRefusalCopy` (`lastActiveVariant` had
  dumped the raw enum since Phase 2).

**Mechanisms traced (the hallucination guard).** E5/E6b are features, not bug
fixes, so they carry no bug mechanism — but the FORK did, and it was traced
before anything was built (the proposal, verified independently by the
architect): `TouchedRows.blocksWithVariantChanges` is populated only from the
ARRIVING row's `block_id` (`Repairs.swift:157–160`), so a moved take's OLD
block never becomes a repair candidate and the double-move race converges to a
live placed block with zero live variants and no self-heal
(`Repairs.swift:400–402`); the repair layer separately DECLARES a foreign
chosen pointer unreachable *"by design: the operations layer forbids minting
one"* (`Repairs.swift:415–417`); and `rescueLosingText` inserts a conflict take
on the SERVER row's block carrying the LOCAL row's parent
(`Merge.swift:83–98`), which under the edit-vs-move race is a cross-block
parent the codebase's own doctrine forbids. ONE real bug-class fix rode along:
the `lastActiveVariant` raw enum dump, which E5 makes a refusal she would
actually meet.

**Pins + red-on-old evidence (behavioral revert, checksums recorded).** New core
suites in `Tests/VariorumCoreTests/TakeStructureTests.swift` (19 tests, 3
suites) and Mac suites in `App/Variorum/VariorumTests/TakeStructureDoorTests.swift`
(13 tests, 2 suites).

*Revert A — the `lastActiveVariant` refusal words deleted from `OpsRefusalCopy`
(the pre-13e state). File:* `OpsRefusalCopy.swift` `7152d04f…abe6` →
`fb443f5f…aab2`. Result: **`aRefusalArrivesInWordsNotAsAnEnumDump` RED with the
exact symptom** — `"Refused: lastActiveVariant(id: "00000000-…-000000000002")"`
— while the suite's other six pins stayed green (clean attribution). Restored:
`7152d04f…abe6`.

*Revert B — the flush dropped from `TakesViewModel.moveTakeIntoBlockBelow`.
File:* `TakesViewModel.swift` `089a7a4c…8e24` → `3da17a38…41dc`. Result:
**`theDoorFlushesFirstSoTheNewBlockCarriesWhatSheJustTyped` RED** — the minted
block carried `"Second take."` where the pane held `"Typed after branching."`
(the copy-doors staleness class, this door's version). Restored:
`089a7a4c…8e24`.

*Revert C — the undo's un-archive half removed from `revertStructural`. File:*
`Operations+UndoInverses.swift` `bc53dfd3…2b32` → `da521717…3d125`. Result:
**exactly the three undo pins RED** — `undoRestoresTheFanAndRedoLandsTheExactRowsAgain`,
`undoPutsTheDefaultBackWhenTheMovedTakeHadBeenIt` and
`oneUndoEntryReturnsTheWholeFanAndRedoRebuildsTheExactRun` (the takes stayed
archived after undo; the default never came back) — the rest of both suites
green. Restored: `bc53dfd3…2b32`.

*The feature pins* cover: the mint's position (immediately below), the archive
(status archived, never tombstoned, still in the fan listing), the edge's
direction and `manual` origin, the label riding while commits do NOT and the
copy is not born locked, the locked-take allowance, moving the SHOWN take
(default reassigned, chosen pointer deliberately untouched, the note still
reading), presentation inheritance + comment COPIES with the source keeping its
own, touch-without-churn, all four refusals writing nothing, undo→redo→undo on
exact rows; and for E6b: the shown take staying with the alternates in fan
order, the shown-take rule holding when the chosen take is NOT first, blanks
skipped/counted and archived takes riding nowhere, the seal, the
nothing-to-convert refusal, and ONE undo entry returning the whole fan. The
door suites add the ring handover, the right-click's explicit target, the flush
contract, the refusal words, the counted receipt with its skipped-blank line,
and both registry declarations with their chords.

**Counts (own runs, quoted from the "Test run with N tests" lines).**
- Core: **`✔ Test run with 1254 tests in 135 suites passed`** (baseline 1235/132
  → +19/+3, exactly the new core file).
- Mac: **`✘ Test run with 1298 tests in 229 suites failed … with 1 issue`** —
  the ONE issue is
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
  the recorded environment-gated tripwire, allowed by IDENTITY (baseline
  1285/227 → +13/+2, exactly the new Mac file). **A47c datum:** it fired again
  in an UNLOCKED session (`CGSSessionScreenIsLocked = 0`) — a third datum for
  the sweep's "fires regardless of lock state" hypothesis.
- Mobile: **`✔ Test run with 314 tests in 60 suites passed`** (iPhone 16e — run
  because the ops land in `Sources/`; baseline matched exactly).
- Tutorial spine, by TYPE name (all seven): **`✔ Test run with 51 tests in 7
  suites passed`**.

**PROVISIONALs / build-time calls:** ten, bundled as **QUESTIONS #58** (a)–(j) —
the archive disposition, the locked-take allowance, which take stays on the
block, blank takes skipped, the two chords, archived takes riding nowhere, the
presentation/comment travel, the label riding while commits stay, the `manual`
origin_op, and moving the shown take. All six of AR-1's ruled defaults are
among them, per the ruling's own instruction.

**Nothing stopped, nothing schema-shaped.** The one design fork was proposed and
RULED before either shape was built (AR-1); no `origin_op` value was invented
('manual' is existing CHECK vocabulary); `Sources/VariorumCore/Sync/` untouched
(zero lines — and the fork's whole point was that the other road would have
needed it); no migration, no mirror implication, no `/Applications` refresh.
Her real-store instance (PID 54789) was live the whole batch and was never
addressed.

**MOBILE PARITY (for the closeout ledger):** the phone owes **all three acts a
door** — `takeToBlockBelow`, `takesToBlocks` and the clipboard copy are shared
core/`Queries` work, so the phone needs faces only (its takes surface for the
first two; a share/copy row for the third). `TakeClipboard` itself is
AppKit-side and would need an iOS twin (`UIPasteboard`); the projection it
copies (`Queries.blockTakes`) is already shared.

**ARCHITECT ACCEPTANCE (2026-08-17, batch 3):** ACCEPTED on spot-checks —
`b1014e6` + `0a3e347` verified (tree clean; zero `Sync/` files in the
diff; core build clean; the E5/A21 core suites re-run green 19/3 by the
architect's own run; the table row, record, and QUESTIONS #58 in the
commit). AR-1(b)'s trace answered the locked-take call from the code
(`performArchiveVariant` never checks `locked` → permitted; copy not
born locked). Third unlocked A47c datum recorded. Parity flags for the
closeout: the phone owes doors for all three acts (core/Queries are
shared; `TakeClipboard` needs a `UIPasteboard` twin). Next free
QUESTIONS number: **#59**.

**THE REVIEW SEAM PLAN (architect, 2026-08-17 — under her granted
latitude for "a couple" of Fable cold reviews):** ladder round A runs
AFTER BATCH 4 over the combined batches-1–4 diff (`6346853..`) — the
ops/structural half of the phase reviewed while its implementers'
records are fresh; ladder round B is the standard phase-end review
over the remainder (batches 5–8 + any round-A fixes). Both run
`notes/REVIEW_PROMPT.md` VERBATIM, fresh cold reviewer each, zero
framing, findings recorded repo-first before any fix session.

## Batch 4 brief — block management (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ canon — AppSpec §9's
`deleteBlock`/`restoreBlock`/tray semantics and the structural
undo/redo contract bind); this plan file TOP TO BOTTOM (batch 2's
board-selection precedent and batch 3's compound-undo shapes are your
templates); the "Applying the constitution" notes in
`.claude/skills/architect-phase/SKILL.md`; **the 13c intake ledger row
A17** (`notes/plans/phase-13c-book-forms-and-conversions.md`) — E2
builds HER ask; her verbatim words are the spec. Do your own reading;
at most ONE read-only lookup subagent, external facts only.

**Scope: E2 ONLY — block-level multi-select and multi-delete (A17).**

- Selection is SESSION-ONLY UI state (the batch-2 `TakesBoardLayout`
  precedent); which surfaces host it is A17's words' call — if her
  words underdetermine the hosting surface(s) or gesture vocabulary
  beyond the obvious (⌘-click toggle, ⇧-click range), build the
  spec-defensible obvious and PROVISIONAL the rest; a genuinely
  fork-sized shape question comes back to the architect propose-first.
- Multi-delete = the standing UNRESTRICTED `deleteBlock` per block
  (QUESTIONS #33(a) — `.none` precondition), under **ONE compound
  undo entry** (`withCompound`; every leg redoable, exact-row) —
  tray/`last_container_id` semantics byte-preserved per block, so the
  per-post deleted-blocks tray lists every victim and `restoreBlock`
  revives each. Seal refuses the whole gesture; a mixed selection
  (some sealed) refuses honestly rather than half-acting (fire-and-DO
  — no partial surprises).
- Registry-declare acts + doors (`.surface`/context-menu as fits;
  chord only if a free one exists under the standing collision-sweep
  discipline — record the sweep); refusals in words (the batch-3
  `OpsRefusalCopy` pin class).
- Red-on-old pins: the compound undo restores ALL selected blocks with
  IDs intact; the mixed-seal refusal; the selection-prune-on-store-change
  class if your selection can dangle (trace it — the batch-2
  adoption-time pruning is the template).

**The loop (binding, unchanged):** red-on-old by behavioral revert
with checksums; PROVISIONAL → QUESTIONS.md (next free **#59**); STOP
on anything schema-shaped; ZERO `Sources/VariorumCore/Sync/` lines;
spine green by TYPE name; full suites with counts from your own "Test
run with N tests" lines — **baselines to match-or-beat: core 1254/135
· Mac 1298/229 (the ONE tripwire red allowed by identity) · mobile
314/60 · spine 51/7**; mobile runs only if `Sources/`/`Shared/` is
touched (iPhone 16e). Builds/tests SYNCHRONOUS — never end your turn
on a background wait. Append your batch record here BEFORE final
claims only with PENDING marks; commit per convention; NEVER push;
NEVER `/Applications`; her real-store instance is never touched
(Environment traps bind verbatim; Mac tests via the cwd-independent
`-project` invocation).

**AUTHOR INSTRUCTION (2026-08-17, mid-batch-4): "pause after batch 4
is done, before starting ladder round A off."** Binding: batch 4 is
verified/accepted and recorded as usual when it reports; ladder round
A does NOT launch until her word. The hold is hers.

### BATCH 4 RECORD — block management (2026-08-17, a fresh Opus implementer; COMPLETE)

**Shipped — E2 only (her A17, verbatim: *"delete several blocks at the same
time from a post - highlighting all of the blocks perhaps? block highlight
instead of text highlight across blocks?"*).**

- **ONE selection brain, two surfaces.** New pure `BlockSelection`
  (`Registry/BlockSelection.swift`): the pick set, the anchor a run extends
  from, and the four rules (`toggle` · `extend(to:in:)` · `prune(to:)` ·
  `inOrder(_:)`), plus batch 2's `isContiguousRun` moved in beside the
  selection it describes. Batch 2 had grown the first copy on
  `TakesBoardLayout` for E3's merge picks; E2 needed the same set in Write,
  and a second copy is precisely the drift class the KnownIssues
  "six mobile brains are byte-copies" row names — so the board's STORAGE
  moved here and its five batch-2 member names stay as thin forwards (the 3C
  parity pattern; **zero batch-2 test edits** is the proof). The selection was
  never merge's private property: it names what the pointer is pointing at,
  and it now serves two acts.
- **The hosting call (her words decided it, not a coin toss).** *"from a
  post"* + *"instead of text highlight across blocks"* names WRITE — the one
  surface where a text selection can span blocks today. R118 then forbids
  leaving the board behind, and the board already had the gesture, so BOTH
  post surfaces host the selection and both render the door. The Blocks list
  and Canvas are deliberately out (#59(b)). No propose-first stop was owed:
  the fork the brief flagged was answered by her sentence.
- **The gesture.** ⌘-click toggles; **⌘⇧-click extends the run** from the
  anchor (additive — several stretches can be assembled). ⇧ ALONE is
  untouched, deliberately: it is the text selection's, i.e. the very gesture
  her ask contrasts with. In Write the chord is asked in `EditorTextView
  .mouseDown` **after the link door** (13g L10's ruling owns ⌘-click over a
  link — the batch-2 precedent, now one rule on both text-surface kinds) and
  **before `super`**, so a claimed chord never also moves the caret; an
  ordinary click puts the selection down. A click past the last block (the
  open tail, not a block) DECLINES and falls through. `PaneSurface`'s
  `onCommandClick` widened from `(() -> Bool)?` to `((Bool) -> Bool)?` — the
  one fact the shade needs, rather than a second closure for half a gesture.
  **Wiring lives in `EditorViewModel.attach`,** not in each
  `NSViewRepresentable`: the model owns the surface from there, so the detail
  editor, the inline book/spread/pool editor and every harness get it from
  ONE place (the first draft wired it twice in the views — caught by the pin
  that asserts the production closures are live after attach, which is the
  pin doing its job).
- **The highlight (her word).** `BlockDecor.State` gained
  `selectedBlockIDs`; the controller pools a `DecorRectView` per picked
  VISIBLE block (P1 — a forty-block selection costs the visible ones), filled
  `wash` with an `accent` border so it reads apart from the editing
  indicator's wash-alone, drawn BELOW the text like every other decoration
  (an overlay, never a rendering attribute — TEXTKIT2 §3). Geometry is
  `BlockDecor.indicatorRect`, reused rather than re-derived: "the block, edge
  to edge" is the same shape in both cases. The `needsFrames` gate gained the
  selection arm — without it the calm default page (seams off, indicator off,
  no callouts, no comments) skips the walk and nothing draws.
- **The act.** `EditorSurfaceController.deleteSelectedBlocks()` (through
  `runStructural`: flush-first, `seam: nil` full re-render, receipt built
  inside the flight) and `TakesViewModel.deleteSelectedBlocks()` (the board's
  own flush + store read, `mergeSelectedBlocks`' shape). Both run the
  STANDING unrestricted `deleteBlock` per block (#33(a) — `.none`
  precondition; tray/`last_container_id` semantics byte-preserved per block)
  under **ONE `withCompound` entry** ("Delete Blocks"); every leg registers a
  redo, so the compound is redoable (13c A10's rule). Caret lands below the
  run, else above it (the single-block rule applied to the run's edges).
- **No partial acts — and the compound is the guarantee, not a pre-check.**
  A seal refuses at the first leg through the OPERATION (P-2: the door
  delivers the ops layer's real refusal, never its own guess), and a leg that
  throws after others landed unwinds them immediately. A seal pre-check was
  DESIGNED AND THEN NOT BUILT, on evidence: `ensurePlacementUnlocked` runs
  before the tombstone, so the first leg throws with nothing collected — the
  pre-check would have bought only wording, which the ops layer already
  gives. **The "mixed selection" the brief names is unreachable by
  construction** (one surface = one post = one seal; blocks that left the post
  are pruned), and the reachable mixed case is the RACE — a picked block
  deleted or moved by another pane, the other half of a split, or a sync
  arrival between the pick and the press. That ends with nothing deleted and
  a refusal that says so.
- **`blockNotFound`, in words** (`BlockSelectionCopy.blockGone`). It has
  dumped its raw enum since Phase 2 because every prior door onto it
  addressed the ONE caret block and a surface could not offer a block the
  store had lost; a held multi-block selection can. The sentence lives in ONE
  constant read by BOTH refusal homes — `OpsRefusalCopy.message` (the Takes
  board) and `EditorViewModel.operationMessage` (Write's own switch, a
  standing duplication) — so the two cannot drift on a line that must match.
  The batch-3 `lastActiveVariant` precedent, exactly.
- **Doors + registry.** `.deleteSelectedBlocks` — verb "Delete Selected
  Blocks", scope `.block`, `takesAccess: .native`, doors `[.contextMenu,
  .surface]`, availability `takeFamily` (NOT `takesBoard` — that difference
  IS E2's shape), **no chord** (⌫ belongs to the caret in the same surface —
  #59(d)). Four renderers, all walk-declared: the two banners
  (`TakesBoardView` + the new `EditorView.surfaceCapabilities`) and the two
  context menus (`TakesCellView`, `EditorViewModel`). Every door renders only
  with ≥1 pick and names the count ("Delete 3 Blocks"). Copy in ONE home
  (`BlockSelectionCopy`), read by both banners.

**Mechanisms traced (the hallucination guard).** E2 is a feature, so it
carries no bug mechanism — with ONE bug-class fix riding along, traced:
`blockNotFound` reached `default:` in both refusal switches and printed
`Refused: blockNotFound(id: "…")`, which this batch is the first door to make
reachable (proven by the revert below, where exactly that string appears in
the status line). Separately, **a hollow pin was found and corrected rather
than shipped**: the first prune pin asserted on `selectedBlocksInOrder`,
which filters through the post's order and therefore hides ghosts whether the
prune runs or not — it passed on BOTH sides of Revert B. It was re-pointed at
the raw pick set (what the prune actually changes) and joined by the
user-visible consequence (a resurrected block must not arrive already
highlighted); both then fired red-on-old.

**Pins + red-on-old evidence (behavioral revert, checksums recorded).** New
Mac file `App/Variorum/VariorumTests/BlockManagementTests.swift` (32 tests, 5
suites). No core file changed, so no core suite grew.

*Revert A — the `withCompound` wrapper removed from BOTH doors (N separate
deletes). Files:* `EditorSurfaceController.swift` `7f802691…4a37` →
`73df975c…8c13`; `TakesViewModel.swift` `91980a21…9e54` → `e1191649…0d4a`.
Result: **exactly the three compound pins RED (8 issues), the other 28 green**
— `oneUndoEntryRestoresEveryPickedBlockWithItsIdAndItsPlace` (`stack.depth →
3`, label "Delete Block", the undo restoring only the last block),
`theBoardsDeleteDoorRemovesEveryPickedBlockUnderOneEntry` (`depth → 2`), and
`aPickedBlockThatVanishedRollsTheWholeGestureBackAndSaysSo`, which shows the
half-done outcome the compound exists to prevent (`["one","two"]` really
deleted while the gesture refused). Restored: both checksums back.

*Revert B — the prune removed (`slots`' `didSet` emptied). File:*
`EditorViewModel.swift` `f157aef2…9e56` → `80efa74a…3b5a`. Result: **exactly
the two prune pins RED** — `theSelectionIsPrunedWhenTheStoreLosesAPickedBlock`
(the dead id stays in the set) and `aResurrectedBlockDoesNotComeBackAlreadyPicked`
(the block returns already highlighted). Restored: `f157aef2…9e56`.

*Revert C — the selection arm removed from the `needsFrames` gate. File:*
`EditorViewModel.swift` (same file, run WITH D). Result: **both geometry pins
RED** — `theHighlightReachesTheOverlayWithEveryOtherDecorationOff` and
`theChordPicksThroughTheRealMouseDownPath`, each on `captured → nil`: on the
calm page the pass emits nothing at all, so the highlight is invisible (the
silent-selection class).

*Revert D — the `blockNotFound` words removed from BOTH homes. Files:*
`EditorViewModel.swift` (Write's switch) + `OpsRefusalCopy.swift`
`6b05a6a3…6e1a` → `51ec9a85…1c09`. Result: **both refusal pins RED with the
exact symptom** — `"The operation was refused: blockNotFound(id: "…0007")"` in
Write and `"Refused: blockNotFound(id: "…0004")"` from the shared home.
Restored: `6b05a6a3…6e1a` and `f157aef2…9e56` (byte-exact, verified by
checksum after re-ordering the restored comment).

*The feature pins* cover: the pure rule (toggle + anchor, extension in both
directions, extension with no/stale anchor degrading to a first pick,
additive runs, independent pruning of set and anchor, order reading, the
forwarded contiguity rule); Write's gesture (pick, extend, the declined
tail-click) and **the chord end-to-end through the REAL `mouseDown` path in a
real window** — click points taken from the decoration pass's own frames, so
the geometry that draws the highlight is the geometry the pointer hits, with
⇧-alone pinned as picking nothing and the plain click as clearing; the act
(every picked block deleted, selection cleared, the receipt, caret landing
below-then-above, the seal refusing while KEEPING the picks, the empty-pick
refusal); and the declaration (doors, keylessness, `takeFamily` acting in
Write AND Takes and nowhere else, all four renderers).

**Counts (own runs, quoted from the "Test run with N tests" lines).**
- Core: **`✔ Test run with 1254 tests in 135 suites passed`** (baseline
  1254/135 matched EXACTLY — this batch changed no core file).
- Mac: **`✘ Test run with 1330 tests in 234 suites failed after 172.030
  seconds with 1 issue`** — the ONE issue is
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
  the recorded environment-gated tripwire, allowed by IDENTITY (baseline
  1298/229 → +32/+5, exactly the new Mac file). **A47c datum:** it fired
  again in an UNLOCKED session (`CGSSessionScreenIsLocked = 0`) — a FOURTH
  datum for the sweep's "fires regardless of lock state" hypothesis.
- Mobile: **NOT RUN, per the brief's condition** — `Sources/` and
  `App/Variorum/Shared/` are untouched (git status: every changed file is
  under `App/Variorum/Variorum/` or `VariorumTests/`), and the mobile
  target's synchronized groups are `VariorumMobile` + `Shared` only, so no
  line this batch wrote reaches it.
- Tutorial spine, by TYPE name (all seven): **`✔ Test run with 51 tests in 7
  suites passed`**.

**PROVISIONALs / build-time calls:** twelve, bundled as **QUESTIONS #59**
(a)–(l) — both hosts and the two non-hosts, the two chords and ⇧-alone, the
absent keyboard shortcut, the highlight's look, the plain-click clear, one
undo entry, the unrestricted delete, no confirmation, the whole-gesture
rollback, picks surviving a refusal, and the session-only pruning selection.

**Nothing stopped, nothing schema-shaped.** No propose-first fork appeared —
her sentence named the surface, and the brief's named "obvious" vocabulary
(⌘-click toggle, range extension) is what shipped, with ⌘⇧ rather than ⇧ for
the range because ⇧-click is the text selection her ask contrasts with.
`Sources/VariorumCore/Sync/` untouched (zero lines); `Sources/` untouched
entirely; no migration, no mirror implication, no `/Applications` refresh.

**PROCESS INCIDENT, recorded rather than buried (Environment traps).** While
clearing a hung test run this session ran `pkill -f
"Variorum.app/Contents/MacOS/Variorum"` — a PROCESS-NAME kill, which the
traps forbid absolutely (bundle id or PID only, and a real-store instance is
NEVER touched). The pattern would have matched `/Applications/Variorum.app`
had one been live. Facts established afterwards: no Variorum process was
running before or after; PID 54789 (the instance recorded live at kickoff)
was already gone and cannot now be shown to have been ended by the pkill; the
real store's WAL was last written **2026-08-16 17:15**, i.e. the day before,
so nothing was in flight and SQLite's WAL is crash-safe regardless; the store
files are intact and untouched by this session. Every subsequent process
check in this batch used `ps -Ao pid,command | grep …` (path-discriminated,
read-only) and every kill named the `xcodebuild` command line only.

**MOBILE PARITY (for the closeout ledger):** the phone owes a **block
multi-select + multi-delete** shape if she wants one — the whole act is
Mac-side (`BlockSelection`, both banners, the ⌘-click chord), and the phone
has no pointer chord, so its version would be a deliberate
select-mode/long-press design, not a port. The core it would call
(`deleteBlock` + `UndoStack.withCompound`) is already shared, so the work is
a face plus a gesture ruling. Nothing else in this batch is phone-visible.

**ARCHITECT ACCEPTANCE (2026-08-17, batch 4):** ACCEPTED on
spot-checks — `7e5b5cb` verified (tree clean; diff App-side only, so
the mobile skip is legitimate by the brief's own condition; the FIVE
new suites re-run green **32/5** by the architect's own zero-instance
run — first attempt hit the empty-selection trap by using the FILE
name as the identifier, caught by the missing "Test run with N tests"
line exactly as the Environment traps warn; the suite TYPE names are
the selectors). The hollow-pin self-catch in the record is the
hallucination guard working as written. Fourth unlocked A47c datum.
Next free QUESTIONS number: **#60**.

**THE BATCH-4 PROCESS INCIDENT — architect's independent verification
and disposition (2026-08-17):** the implementer ran a process-name
`pkill` (forbidden — bundle id/PID only) while clearing a hung test
run, and recorded it verbatim in its batch record rather than burying
it. Verified independently: NO Variorum process exists now; the real
store's files are intact; the WAL/shm were last written **2026-08-16
17:15** — her app sat idle all of today, so NOTHING was in flight and
no data outcome was possible in either scenario; today's automatic
backup ran (09:56). What cannot be proven either way is her app's
exit cause — PID 54789 was live at the kickoff checks and is gone
now; her own quit and the pkill window are both consistent with the
evidence. REPORTED TO HER honestly in the hold report. Disposition:
the rule stands unchanged; batches 5–8 briefs gain the sharpened
line — **kills ONLY by PID after a path-discriminated `ps`, never by
pattern; a hung xcodebuild is killed by ITS pid**; the incident stays
on the record here and in the batch record (the 13g batch-1
precedent's form).

**HOLD (her instruction, in force):** batch 4 is accepted; **ladder
round A does NOT launch until her word.** Round A's shape when she
gives it: a FRESH Fable cold reviewer over the combined batches-1–4
diff (`6346853..7e5b5cb`), `notes/REVIEW_PROMPT.md` VERBATIM, zero
framing, findings repo-first.

**AUTHOR GO (2026-08-18, overnight): the HOLD LIFTS.** Her words:
*"resume your work and progress through the rest of this phase. you
can restart with the ladder round A. I will be asleep, so make
judgement calls where needed and compile them for my review at the
end. go all the way through phase closeout and leave residuals for me
at the top of the completed phase, so if your context window is quite
full I'll be able to review it without reviving you. also, I closed
my app earlier and its closed now, so it can be refreshed when phase
13 is complete."* Binding readings: ladder round A launches NOW;
batches 5–8 and ladder round B follow; judgment calls are
PROVISIONAL-and-continue, ALL compiled into a RESIDUALS section at
the TOP of this file at closeout (readable without reviving the
session); the closeout runs the FULL standing ritual; the
`/Applications` refresh is PRE-AUTHORIZED at phase completion (her
app confirmed closed — the A1 rail still runs first).

---

## LADDER ROUND A (2026-08-18, overnight — fresh Fable cold reviewer over `6346853..7e5b5cb`; REVIEW_PROMPT verbatim, zero framing)

**Verdict: ZERO BLOCKER / ZERO MAJOR — 2 MINOR · 2 NIT · 1 NIT-SPECULATIVE,
with a strong clean bill** (verified solid by the reviewer's own runs:
reorderTake's one-resolver shape · the FIX-2 rider genuinely closing its
row · E15's policy execution incl. the no-loop settle · batch 3's AR-1
shapes with I10 traced at every constructible edge · E13's door-level
honesty · registry/P-1 coverage · copy homes · gesture layering ·
P1/P3/TK2 · sync shape zero-diff · spine 51/7 green).

**Findings + the architect's adjudications (spec-anchored; no dispute
turned on undefined product behavior, so the implementer dispute loop
was not owed — the `/architect-phase` skill's ladder governs, and the
architect adjudicates directly):**

- **A-1 [MINOR] — the board's `deleteSelectedBlocks` half-acts in the
  vanished-pick race** (pre-filters the pick set and deletes survivors)
  while Write's host rolls the whole gesture back and speaks
  (`blockGone`) — ONE declared act, two behaviors, contradicting the
  method's own doc comment and the batch-4 record. **ADJUDICATED VALID
  — FIX:** align the board to the rollback contract; red-on-old pin
  (board: pick 2, delete 1 via the runner, act — today the survivor
  dies, after: refusal + nothing deleted).
- **A-2 [MINOR] — P-9 accretion:** `TakesViewModel` grew 2057→2521
  lines THIS phase while the constitution names it the standing
  counterexample; the pure brains were extracted (`BlockSelection`,
  `TakeClipboard`) but the board's structural DOORS never got their
  controller (the editor side's own `EditorSurfaceController` is the
  in-repo pattern). **ADJUDICATED VALID — FIX in-phase:** extract the
  board's structural-door half on the 3C parity discipline (every
  pre-move name kept as a computed forward/typealias; ZERO test edits
  is the parity proof; full suites green). Fallback if the extraction
  fights back: revert clean and park as a KnownIssues row for her
  flick at residuals — never a half-landed refactor.
- **A-3 [NIT] — `mergeSelectedBlocks` misdiagnoses the vanished-pick
  race** as "not adjacent" when the truth is "a block is gone"
  (`blockGone`'s family, one door over). **VALID — FIX:** check
  existence before contiguity; wording pin.
- **A-4 [NIT] — hand-coded chord suffixes** in `TakesShared` context
  menus duplicate the registry's `shortcutLabel` — AR-1(e) leaves the
  keys hers to re-pick, and a re-pick now needs three homes.
  **VALID — FIX:** read the registry.
- **A-5 [NIT · SPECULATIVE] — `TakeClipboard` touches `NSPasteboard`
  off the main actor** after an awaited read; no concrete failure
  traceable (reviewer's own label). **DISPOSITION per the
  hallucination guard: the bug claim is DISMISSED as untraceable; the
  `@MainActor` annotation is applied as a CLEANLINESS change only**
  (both callers are already MainActor; the hop buys nothing) — no pin
  owed, justification recorded here.

**ROUND-A FIX BRIEF (a FRESH Opus fix session; self-contained):** fix
A-1, A-3, A-4, A-5 exactly as adjudicated above (A-1 and A-3 with
red-on-old pins by behavioral revert with checksums; A-4 with the
existing drift-guard class if one fits; A-5 annotation-only), then
attempt A-2's extraction LAST on the 3C parity discipline — a
`TakesSurfaceController` (or the name the editor-side pattern
suggests) owning the board's structural doors, `TakesViewModel`
keeping every existing name as a forward; ZERO test edits; if parity
cannot be held, `git checkout` the extraction's files back (they are
the only uncommitted things at that point — the A-1/A-3/A-4/A-5 fixes
commit FIRST, separately) and record the fallback. Full suites +
spine at the end (baselines: core 1254/135 · Mac 1330/234
tripwire-only · mobile 314/60 — mobile only if `Sources/`/`Shared/`
touched); Environment traps bind verbatim (kills ONLY by PID after a
path-discriminated `ps`); batch record appended here; commit(s) per
convention; never push.

### ROUND-A FIX RECORD — part 1 of 2: A-1 · A-3 · A-4 · A-5 (2026-08-18, a fresh Opus fix session)

**A-1 [MINOR] — the board's multi-delete now rolls back like Write's.
FIXED.** Mechanism, traced on this surface before the fix:
`TakesViewModel.deleteSelectedBlocks` computed
`chain = order.filter { picked.contains($0) }` against a fresh
`Queries.renderPost` read, so a pick the post no longer held simply
DROPPED OUT and the survivors were deleted — with the success receipt
("Block deleted — ⌥⌘Z undoes it in one go…") and the selection cleared,
i.e. the half-act reported as a whole one. Write's host
(`EditorSurfaceController.deleteSelectedBlocks`) hands EVERY pick to the
compound and lets `deleteBlock` refuse (`blockNotFound` → `withCompound`
unwinds the legs that landed → `BlockSelectionCopy.blockGone`), which is
what the board's own doc comment already claimed. The fix is one
expression: the store's order for the blocks it holds, **plus** the picks
it does not (`picked.subtracting(order).sorted()`), so the operation
meets the ghost and the compound's atomic rollback does the rest — and
the empty-chain branch (which cleared the picks and spoke its own
sentence) is retired, since #59(k) says a refusal keeps them. This is
also the only shape covering the race that opens BETWEEN the read and the
write, which no pre-filter can (the batch-4 record's own "the compound is
the guarantee, not a pre-check" reasoning, applied to the surface that
had not applied it).

**A-3 [NIT] — merge names the vanished pick instead of calling it a gap.
FIXED.** `isContiguousRun` requires every picked id to APPEAR in the
order, so a vanished pick failed the adjacency test and the board reported
*"these aren't next to each other"* — the wrong diagnosis, sending her to
look for adjacency that was never the problem. Existence is now asked
first (`picked.isSubset(of: Set(order))`), speaking a new sibling line in
the ONE copy home: `BlockSelectionCopy.blockGoneForMerge`, which is
`blockGone`'s sentence with the only word that must differ ("Nothing was
merged"). Both now derive from one private `blockGoneLine(nothingWas:)`,
so the pair cannot drift apart in the parts that must match;
`blockGone`'s bytes are unchanged (pinned).

**A-4 [NIT] — the take card's chords come from the registry. FIXED.**
Mechanism (cleanliness, no bug — the strings agreed today): the card's
rows typed "(⌘T)", "(⌥⌘T)", "(⌘⇧A)", "(⌘⇧C)", "(⌥⌘⏎)", "(⇧⌥⌘⏎)" beside a
registry that declares each one, and AR-1(e) explicitly leaves the last
two hers to re-pick — so a re-pick had three homes (registry, this menu,
the ⌘/ helper) with nothing making them agree. ONE formatter now composes
verb-plus-chord (`Capability.menuTitle(_:)`, which also absorbs
`FormatBar.help`'s private copy of the same composition), and the card's
six chorded rows read from `TakeCardMenuCopy` — a copy home in the
`BlockSelectionCopy` shape. **Words byte-unchanged** (pinned literally).

**A-5 [NIT · SPECULATIVE] — `@MainActor` on `TakeClipboard`, as
CLEANLINESS only.** Per the adjudication and the hallucination guard: the
bug claim is DISMISSED as untraceable (the reviewer's own label;
`NSPasteboard` is not documented main-thread-only, and both production
doors plus every pin already call in from the MainActor), so **no pin is
owed and none was written** — one would have passed on both sides. The
annotation states the actor these callers already run on so the hop
cannot be reintroduced silently; the reasoning is written into the type's
doc comment, not just here.

**Pins + red-on-old evidence (behavioral revert, checksums recorded).**
New Mac file `App/Variorum/VariorumTests/RoundAFixTests.swift` (8 tests,
3 suites). No core file changed.

*Revert A — the pre-fix pre-filter restored in
`TakesViewModel.deleteSelectedBlocks` (the `order.filter` chain + the
empty-chain guard). File:* `TakesViewModel.swift`
`550ed56c…b415b` → `f6b2acad…1ded9`. Result: **`BoardDeleteRollbackTests
.aVanishedPickRollsTheWholeGestureBackAndSaysSo` RED with the exact
symptom (4 issues)** — the survivor "one" really was deleted, the status
line read the SUCCESS receipt ("Block deleted — ⌥⌘Z undoes it in one
go…"), an undo entry was registered (depth 2 vs the staged 1), and the
selection cleared — while `everyPickStillGoesWhenTheNoteHoldsThemAll`,
the A-3 suite, and all four batch-4 `BoardBlockSelectionTests` stayed
GREEN (clean attribution). Restored: `550ed56c…b415b`.

*Revert B — the existence guard deleted from `mergeSelectedBlocks`
(contiguity asked first again). File:* `TakesViewModel.swift`
`550ed56c…b415b` → `b30ceb71…9890f`. Result: **`BoardMergeDiagnosisTests
.aVanishedPickIsNamedAsGoneNotAsAGap` RED with the exact symptom** —
*"Merge joins neighbouring blocks — these aren't next to each other."* —
while `aGenuineGapStillSaysGap`, the A-1 pins and all nine batch-2
`MergeSelectionTests` stayed GREEN. Restored: `550ed56c…b415b`
(byte-exact, checksum-verified).

*The other pins:* `aGenuineGapStillSaysGap` and
`everyPickStillGoesWhenTheNoteHoldsThemAll` pass on BOTH sides
deliberately — they are the attribution half (the fixes narrowed a
diagnosis and closed a race without touching the ordinary roads).
`TakeCardMenuTitleTests`' three are A-4's drift guard and its no-change
proof, explicitly NOT red-on-old (recorded in the file's own comments):
every chorded row must end with exactly the chord its capability
declares, the six titles are pinned byte-identical to what shipped, and
the formatter appends nothing where no chord is declared.

**Counts (own runs, quoted from the "Test run with N tests" lines).**
- Mac: **`✘ Test run with 1338 tests in 237 suites failed after 170.184
  seconds with 1 issue`** — the ONE issue is
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergence
  Occasion`, the recorded environment-gated tripwire, allowed by IDENTITY
  (baseline 1330/234 → +8/+3, exactly the new file). **A47c datum:** it
  fired again in an UNLOCKED session (`CGSSessionScreenIsLocked = 0`) — a
  FIFTH datum for the sweep's "fires regardless of lock state"
  hypothesis.
- Tutorial spine, by TYPE name (all seven): **`✔ Test run with 51 tests
  in 7 suites passed`**.
- Core / mobile: NOT RUN for this commit — `Sources/` and
  `App/Variorum/Shared/` are untouched (every changed file is under
  `App/Variorum/Variorum/` or `VariorumTests/`); both are run at the
  session's end.

**PROVISIONALs:** five, bundled as **QUESTIONS #60** (a)–(e) — the
board's rollback alignment, the picks surviving that refusal, the
recorded moved-block consequence both hosts share, merge's own words for
the race, and the registry-read chord labels.
