# Variorum for iPhone — the standalone plan

## Kickoff message (paste-ready — this is how she starts it)

> You are the architect/orchestrator for **Variorum for iPhone**, a
> standalone project — NOT a numbered phase (the author decoupled it from
> the phase sequence on 2026-07-25). Run it under the `/architect-phase`
> skill: read `.claude/skills/architect-phase/SKILL.md` IN FULL first
> (constitution, machinery, environment invariants), then `CLAUDE.md`,
> then **this file IN FULL**, then the canon set —
> `notes/CoreDescription.md` (**pillar 8 is the one that governs you, and
> it was rewritten for this project**), `notes/OverallModel.md`,
> `notes/AppSpec.md`, `notes/SyncSpec.md`,
> `notes/DetailedPlanForPhases.md` (table + pointer + closeout log), and
> `notes/KnownIssuesAndTechDebt.md`. Then read what already exists on the
> phone: `notes/plans/phase-08-ios-capture.md` (what shipped and why it
> is shaped that way) and `notes/plans/phase-15-brief.md` (**history —
> its "no fan gestures" framing is superseded by pillar 8's 2026-07-25
> delta; mine it for the reading-views thinking only**).
>
> **This project OPENS with an author-attended design sitting, and it
> cannot be skipped.** The interaction shape is genuinely undecided —
> she floated four candidates and said *"either way"*. They are recorded
> below AS FLOATED. **Do not pre-commit one.** Bring her prototypes or
> concrete option sets, in question batches of ≤4, and record her
> rulings verbatim-faithful in this file the same turn.
>
> The bar she set, in her words: *"a thorough implementation of the app
> that is beautiful and easy to use"* and *"it's going to have to be a
> real and robust option."* This replaces the Phase 8 capture surface as
> the phone's identity; it does not extend it.
>
> Confirm repo state with `git log --oneline -10` and `git status`, and
> verify the current test baselines with your own runs before building
> on them.

---

## Working environment (set up 2026-08-02 at the author's request — mobile runs PARALLEL to the Mac phases)

- **This project runs in its own git worktree: `~/dev/variorum-mobile`,
  branch `mobile`** (the same repo, a second working directory). Mac-side
  phase work stays on `main` in `~/dev/variorum`; the two never edit the
  same files on disk, and Xcode/SwiftPM build state (DerivedData,
  `.build`) is per-directory, so parallel sessions and builds don't
  collide. **Start mobile sessions IN the worktree.**
- **No new Xcode project is needed:** `App/Variorum/Variorum.xcodeproj`
  already carries the `VariorumMobile` target (+ `VariorumMobileTests` /
  `VariorumMobileUITests`) from Phase 8. The design sitting decides
  whether to reshape that target or ask the author for a fresh one
  (project/target creation via the Xcode GUI is hers per CLAUDE.md).
- **Merge discipline:** merge `main` → `mobile` regularly (pick up
  Mac-side core changes early, while they're small); merge `mobile` →
  `main` at milestones, at the author's word. Push `origin mobile`
  after committing, at regular intervals (her 2026-08-03 rule change,
  superseding this section's original never-push line — plain pushing
  is delegated to sessions; history rewrites and force-pushes stay
  hers). **`Sources/VariorumCore` is the shared spine:** keep
  core-touching changes small and deliberate, and the standing rider
  holds — anything in `Sources/VariorumCore/Sync/` is Fable work.
- **The worktree isolates FILES, never the schema:** any schema change is
  still a SyncSpec §12 lockstep event against the ONE shared mirror —
  mirror-first, her explicit go — never a branch-local migration.
- The A4 dev-store fence applies unchanged (a Debug build resolves the
  dev store; her phone installs Release).

---

## RUN RECORD — the project OPENED 2026-08-03 (author-attended design sitting, in progress)

**Status:** running under `/architect-phase`; this session is the architect/
orchestrator. Preflight complete (SKILL.md + CLAUDE.md + this file + the canon
set + `phase-08-ios-capture.md` + `phase-15-brief.md`); repo clean on `mobile`
at `b3fbac3`, up to date with origin. Baselines by this session's own runs:
**core 1034/114 VERIFIED** (matches the 13k closeout exactly); mobile 14/4
re-running (the first attempt hit a simulator-destination resolution error,
not a test failure — record updates when it lands). Mac 1191/208 + spine 51/7
are Mac-side counts this project has not touched; they get their own
verification before any shared-core change lands. The 13b constitution
(P-1…P-9 + application notes) BINDS per the skill and is copied verbatim into
this file when the execution-plan sections are authored at the sitting's
close. Context updates since the brief was written, stated at the sitting:
**13g LANDED** (markdown-as-content formatting is stored content the phone can
render with no schema work), 13f landed the post→note UI-string sweep, 13k
landed the compact nav bar + nested lists; **13e is still PENDING** — the
take-management vocabulary it adds (reorder/move/copy-all) will grow after
whatever take UI this project ships.

### Sitting batch 1 — the interaction shape (2026-08-03; rulings verbatim-faithful)

- **M1 — Base surface: WRITE-TRUE — one continuous editor** (the Mac
  architecture on iOS: one TK2 `UITextView` over the whole note, block IDs
  riding ranges via the shared pure identity core, kept AppKit-free for
  exactly this). Her selection, notes verbatim: *"what are the differences in
  capability? this seems better and more useful for a phone app, but can i
  not still access the block i'm on?"* Answered in-sitting: block access is
  fully preserved — the caret's block is always known, and badges/menus/takes
  stay per-block; Write-true strictly dominates the block-focused alternative
  on capability (cross-block selection, seamless typing; nothing lost); its
  price is build cost + the TK2-on-iOS risk, de-risked by a throwaway spike
  per the Phase 6 precedent. Ruling stands as her selection.
- **M2 — Block doors: LONG-PRESS MENU ruled in; SWIPE selected but its
  meaning deliberately REOPENED by her.** Verbatim: *"i think it will still
  feel reasonably natural to swipe on a block because they're separate
  paragraphs - i think a quicker way to bring the menu up matters as well,
  but i'm a little conflicted because i think that swiping should maybe be
  how you can quickly access other takes? i think i'm open to a huge variety
  of ideas for how to accomplish this"* Implementation reading recorded (not
  re-asked): inside an editable text view, "long-press → menu" ships as the
  EXTENDED iOS text edit menu (custom block items on the native menu — zero
  conflict with the system text gestures), beside whatever further doors
  batch 2 settles.
- **M3 — Takes shape: NO option selected** — she floated a new idea instead,
  verbatim: *"i think swiping left and right for takes might also work
  well"* — batch 2 brings composed gesture-grammar options.
- **M4 — Take verbs: ALL FOUR cross in v1** — view + choose · new take ·
  edit any take · archive/delete a take (each an existing tested operation;
  the cost is UI surface, not model work). 13e's later Mac additions
  (reorder/move/copy-all) are adoptable afterwards; the execution plan states
  which parts are deliberately built ahead of 13e.

*(Baseline update, post-batch-1: **mobile 14/4 VERIFIED** — the destination
that works is iPhone 17 Pro / iOS 26.2, the Phase 8 record's own; the iPhone
16 simulators on this machine carry iOS 18.3, below the deployment target,
and resolve to nothing. Both project-relevant baselines now confirmed by this
session's own runs.)*

### Sitting batch 2 — swipe grammar, flip semantics, app shape, reading (2026-08-03; rulings verbatim-faithful)

- **M5 — Swipe FLIPS TAKES, ruled.** On a fanned block, horizontal swipe
  flips which take shows, in place — the fan as a horizontal carousel under
  the paragraph (the Mac R24 short-block horizontal strip made physical);
  non-fanned blocks don't respond. Menus keep two doors regardless: the
  long-press/extended-edit menu (M2) + the focused block's ⋯. This resolves
  M2's reopened conflict in favor of her second float — swipe belongs to
  takes; the menu's quick doors are long-press and ⋯.
- **M6 — Flip PEEKS; ✓ CHOOSES.** Her pick AGAINST the recommended
  canvas-rule reading (flip = chooseVariant), deliberately: flipping on the
  phone only previews; an explicit ✓ commits the choice. Consequence
  recorded with the ruling: the phone gains view-local display state the Mac
  pattern deliberately avoided — the peek must be visibly transient (which
  take is CHOSEN stays unambiguous), and the transiency rule (revert on
  leaving the block vs. sticky per session) is batch 3's confirm. The Mac
  canvas ‹›-chooses ruling is untouched; this is the PHONE's rule.
- **M7 — App shape: SHELF-FIRST, Today a button.** The phone opens on
  Books/the shelf (Journal pinned, her books, finish/extent faces); a
  prominent "Today's Entry" button rides the shelf (the Mac quick-entry-bar
  parallel; create-or-open, the notebook rule). Tab bar: **Shelf · Library**
  (Library = everything + search; bookless notes as a filter there — the
  Pool's phone home). The Today+tabs and Mac-mirror shapes were offered and
  declined.
- **M8 — READ FLOW SHIPS IN v1.** Opening a book offers the calm continuous
  reading column (the Mac Read mode's phone cousin — chapters, virtualized
  per P3); tapping into a note edits it in Write. The phone is the
  reading-in-bed surface; "real and robust" includes it.

### Sitting batch 3 — peek rules, structural scope, formatting, comments/callouts (2026-08-03; rulings verbatim-faithful)

- **M9 — Peek is STICKY WHILE THE NOTE IS OPEN**, ruled via her own words
  (no option button; verbatim): *"sticky while the note is open makes more
  sense to me - one day the mobile app might even be able to open a lens
  (not in a separate lens tab, in an option on the takes page i think from
  an overall menu or something, it would have to be simplified, but it's
  godo to keep the machinery)"*. So: peeked takes stay displayed until the
  note closes; a visible per-block peeking marker keeps chosen-vs-peeked
  unambiguous; ✓ remains the only cross-device commitment. **Direction
  recorded (not v1 scope): MOBILE LENSES SOMEDAY** — simplified, reached
  from the takes surface / an overall menu, never a separate lens tab; keep
  the machinery open to it (the sticky peek is deliberately lens-shaped).
- **M10 — Structural scope: DIVIDE + MERGE ship in v1; ceremonies stay
  Mac-only.** Her answer, verbatim: *"divide + merge with no ceremony means
  you can't do it when you have multiple takes on merge, right? I think
  that's fine honestly, this covers more of the accidental different blocks
  case"*. Answered in-sitting, one precision on her reading: the phone
  inherits the Mac's own no-ceremony paths — divide AUTO-PROCEEDS on a
  fanned block when the cut lands uniquely in every take (the ratified #10
  auto-proceed rule; `CutPropagation` is shared pure Domain) and refuses
  exactly where the Mac would open the W; merge is instant when neither
  side carries a fan and refuses to the Mac's pairing ceremony when one
  does (the base op COULD join chosen takes, but silently dropping her
  pairing options is exactly what the ceremony exists to prevent). Her
  accidental-different-blocks case is fully covered (fanless/unique-match).
  **Extract is deliberately NOT in v1** (recorded; trivially joinable later —
  `BoundarySnapping` is shared).
- **M11 — Formatting: FULL — render + typing behaviors + toolbar.** The 13g
  vocabulary renders; ⏎ list continuation, checkbox tap-toggle, Tab/⇧Tab
  nesting via keyboard accessory; a compact toolbar above the keyboard with
  the core acts. The phone writes like the Mac writes.
- **M12 — Comments & callouts: BOTH, view + edit.** Callout frames render
  on the page (13k's one-frame rule); comments behind the block menu as a
  sheet (view/add/edit/delete — existing ops); a commented block wears a
  small marker.

---

## Orientation

**Status:** the author's standing inputs for a mobile app that is *"a
real and robust option"* — collected 2026-07-25 so nothing depends on
the session that heard them. **This is a brief, not a plan:** it binds
only what she has actually ruled, and it exists so whoever authors the
real plan starts from her words rather than from scratch.

**Sequencing (her ruling, 2026-07-25):** mobile is **its own plan,
decided separately** — deliberately NOT a numbered phase in the 13
series and no longer Phase 15's line item. She was offered three
in-sequence slots (after 13c, after 13e, after formatting) and chose
none of them: *"i think i'm going to have to move that up / forward in
the plan or give it its own plan."* It is an **unslotted first-class
project row** on the master plan, like the Apple Notes import and the
Design & UI review, and it starts when she says so.

---

## What she actually wants (verbatim where it matters)

> *"i've realized that i really do need a thorough implementation of the
> app that is beautiful and easy to use."*

> *"it's going to have to be a real and robust option."*

The bar is explicitly **not** "capture plus a bit more." The existing
Phase 8 capture surface (journal entries, editing a block's active text,
one live `TextEditor` with read-cheap tap-to-focus siblings) is the
floor this replaces, not the shape it extends.

## The design candidates she floated — RECORDED AS FLOATED, NOT CHOSEN

She said *"either way"* and is genuinely undecided. **Do not
pre-commit any of these; they are the design sitting's to settle.**

- **A Write-like base** — *"something like the 'Write' mode would be
  perfect."*
- **Drag left and right on blocks** to reach their complex menus.
- **A small take button to click on.**
- **Or: takes only in stack mode**, with a button to expand and shrink
  it.

Her own framing of the pair: either the gesture-rich block surface, or
the stack-only take presentation — *"either way, it's going to have to
be a real and robust option."*

## What is already settled and BINDS

- **Takes are included on mobile.** CoreDescription pillar 8's "no
  variant/fan gestures there" is **superseded** by her explicit
  2026-07-25 ruling (the delta is applied in that file). The move began
  as a lean at Phase 13 sitting 8 (**R58**, *"i think i will include
  takes on mobile"*) and at the 2026-07-17 intake (*"much more limited"*
  than the Mac, takes for one block of one post at a time); it is now a
  decision.
- **Smaller than the Mac is still the rule.** "Real and robust" is not
  "everything the Mac has." A deliberately narrower take surface is the
  target; where the line falls is the sitting's.
- **The stack presentation is the mobile-inheritable pattern** — Phase
  13's canvas takes switcher was built minimal *deliberately* as the
  seed of this (R40/R58's thread). Reuse it rather than inventing.
- **One model, one core.** Mobile is a second client of the same
  `VariorumCore` + sync engine, never a separate data model
  (CoreDescription pillar 8's surviving half; the Phase 8 precedent).
  Journal restrictions stay a UI profile.
- **The A4 dev-store fence and Release-install rule** apply as recorded
  (QUESTIONS #4): a debug build on the device resolves the dev store
  where sync is fenced off, so the phone installs as **Release**.

## Open questions the plan-author inherits

1. **The interaction shape** — the four floated candidates above.
2. **How much take vocabulary crosses over** — viewing only? choose?
   branch? The 2026-07-17 note leaned "one block of one post at a time";
   R58 and this ruling both loosened the ceiling without setting a new
   one.
3. **Which Mac surfaces mobile mirrors** — Write is named; Outline (the
   book's writing surface, ruled at 13c) and the book spread are
   plausible and unasked.
4. **What ships against a moving target.** Formatting (13g, including
   the list/checkbox maker) and the takes/block work (13e) will change
   the vocabulary mobile mirrors. Building before they land means
   building some of it twice — she accepted that tradeoff implicitly by
   decoupling mobile from the sequence, but the plan should state which
   parts it is choosing to build twice.
5. **The iOS trailing-blank-lines defect** (KnownIssues, owner 15 —
   inherited here): editing a block on the phone accrues real stored
   trailing newlines. The fix must distinguish accidental accrual from
   the MEANINGFUL stored spacing the 2026-07-12 ruling created — never a
   blanket trim.

## Suggested shape of the work (a starting point, not a commitment)

The design sitting may reorder all of this. It exists so the project does
not start from a blank page.

| Stage | What | Gate |
|---|---|---|
| 0 | **The design sitting.** Her rulings on the interaction shape, how much take vocabulary crosses, which Mac surfaces mobile mirrors. Prototypes over prose where possible — she has said repeatedly that she rules better on something she can see | Her rulings recorded in this file, verbatim-faithful |
| 1 | **The surface audit.** What the phone has today (Phase 8 capture), what the Mac's Write/Takes vocabulary now is after 13c–13e, and the honest list of what will be built twice if this ships before formatting (13g) lands | A written list she can look at |
| 2 | **The writing surface.** The Write-equivalent, on the phone's own terms. Note: AppSpec §4's TK2 mandate targets the **Mac editor core**, not the phone — QUESTIONS #2 ratified SwiftUI `TextEditor` for capture, and whether a robust phone editor still wants it is an open call this project makes with evidence | Typing is pleasant on a real device; P1/P3 hold |
| 3 | **Takes on the phone** — the deliberately narrower surface pillar 8 now permits | Her acceptance; the take vocabulary is a subset by design, and the record says which subset and why |
| 4 | **The rest of the model** — reading views, books, navigation, per her design sitting | — |
| 5 | **The inherited defect** — the iOS trailing-blank-lines bug (below), fixed without a blanket trim | A pin distinguishing accidental accrual from meaningful stored spacing |

## Where the rest of the record lives

- `notes/CoreDescription.md` pillar 8 — the ratified supersession.
- `notes/plans/phase-13-ui-design.md` — R40 (canvas's minimal switcher
  as the mobile-inheritable pattern), R58 (the lean).
- `notes/AppSpec.md` §14 — the 2026-07-17 intake delta, items 3/4.
- `notes/plans/phase-15-brief.md` — the older orientation sketch, which
  this brief supersedes for mobile scope. Read it for the parts about
  reading views; treat its "no fan gestures" framing as superseded.
- `notes/plans/phase-08-ios-capture.md` — what exists on the phone today
  and why it is shaped that way.
