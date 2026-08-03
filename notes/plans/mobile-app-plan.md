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

### Sitting batch 4 — cast & device drops (2026-08-03)

- **M13 — Cast: ALL-FABLE** (architect · a fresh implementer per batch ·
  cold reviewers), her call — coherent with her recorded token-window lean
  (mobile is the main Fable spend of her two windows to Aug 6).
- **M14 — Device drops: Xcode Release installs now, TestFlight when
  stable.** Early rounds install via the standing A4 procedure (Release via
  Xcode, phone plugged in); once the app stabilizes she sets up the App
  Store Connect record and later drops ride TestFlight (the Fragments
  muscle is fresh).

### Her mid-sitting directive (2026-08-03, arrived during plan authoring — STANDING for this project; verbatim)

> *"it's your role to also make sure that phases are made at sensible
> points so that all the machinery we have for catching errors - the
> review ladders, writing tests, etc. all stays disciplined. while i do
> want you to handle the creation of variorum mobile more autonomously
> than i've been building variorum itself (I'm involved with basically
> every design decision there), it is still important that we stay true
> to that. also, do you think that the instructions are pretty clear for
> what to build in the app? are you interested in building me html
> mockups or do you think you have enough that going straight to the
> swift would be better? I'm truly open either way."*

Readings, recorded with the directive: **(1) Stage = phase discipline** —
each stage closes with the full ladder, tests-with-every-step, red-on-old
pins, and recorded counts before the next opens; the mobile acceptance
spine (below) makes P-6 real on the phone. **(2) The autonomy
calibration** — design ambiguities run PROVISIONAL-and-continue with her
bundle at stage gates rather than per-decision asks; author-only calls
remain hard stops. **(3) Mockups: BOTH, in parallel** (the architect's
answer, hers to override): the instructions ARE clear for what to build —
machinery goes straight to Swift (the spike first); the unruled part is
the LOOK, so the architect builds HTML mockups of the four key surfaces
as a parallel look track for her sittings (the Phase 13 mockup-canon
precedent). Machinery never waits on the look track; gesture FEEL is
judged on her device, not in HTML.

**THE SITTING IS CLOSED (2026-08-03) — fourteen rulings M1–M14, recorded
verbatim-faithful above.** The execution plan below is authored from them.
The brief sections later in this file ("What she actually wants", the
floated candidates, "What is already settled and BINDS") remain standing
inputs; the "Suggested shape of the work" table and the "Open questions the
plan-author inherits" list are **SUPERSEDED** by the sitting + this plan
(kept as history; all five inherited questions answered or owned —
1→M1/M5/M6/M9 · 2→M4 · 3→M7/M8 · 4→the built-ahead-of-13e statement below ·
5→ledger row L9).

### Look sitting round 1 (2026-08-03, her flick over mockups v1 — rulings verbatim-faithful)

Her message, verbatim: *"def only go for the iPhone 17 most recent iOS
simulators. some rulings from the mockup: keep both with its own switch.
the badge - copy the same icon we use for takes and don't show 2/3, just
show the little icon and users have to click on it. the sheet over the
page looks good. i think # of notes or tags matter most for the library
for books."*

- **LK1 — Simulators: iPhone 17 family on the MOST RECENT iOS runtime,
  always.** The environment trap hardens accordingly: when a newer
  runtime lands, move to it and re-verify (the TEXTKIT2 §5 discipline's
  simulator twin).
- **LK2 — The voice: the phone keeps BOTH voices with its OWN switch**
  (judging item 1) — a phone-local voice preference, deliberately NOT
  following the Mac's setting.
- **LK3 — The badge: the Mac takes icon, COUNT-FREE.** The phone's fan
  badge renders **⑂ alone** (the Mac fan badge's glyph — which on the Mac
  shows `⑂N`; her phone ruling drops the count): no k/n at rest, the tap
  is the door; counts appear once open (pill/browser). Mockups' ⧉ stand-in
  retired.
- **LK4 — The takes sheet-over-page RATIFIED** (*"the sheet over the page
  looks good"*).
- **LK5 — Book-row faces: NOTE COUNT and TAGS lead** (her words: *"# of
  notes or tags matter most for the library for books"*) — shelf/Library
  book rows lead with the number of notes and the book's tags; the other
  mocked faces (word progress, daily marker) rank behind. PROVISIONAL
  riding it: **✓ finished stays visible as a STATE, not a stat** (a
  finished book reads finished) — one line to drop if she rules
  otherwise.
- **Still open from the judging list (the next look round collects
  them):** item 2 (the peek pill's shape/position), item 4 (the tab bar's
  register), item 5 (the keyboard bar's act set), item 7 (the Read page's
  chrome). *(→ ALL RULED at round 2, below.)*

### Look sitting round 2 (2026-08-03, her flick over mockups v2 — rulings verbatim-faithful)

Her message, verbatim: *"choices: 1A  2A  3A 4A. 5 looks good but text
shouldn't go under the take icon - it looks a litle annoying. maybe just
reserve some space for it? also ues - definitely keep both spikes that
were created and commit them as well - they matter."*

- **LK6 — The peek pill: A** — the under-block pill (v1's shape; fades
  after a beat, back on any flip).
- **LK7 — The tab bar: A** — text-only (terminal lowercase / study
  normal-case; no icons).
- **LK8 — The keyboard bar: A** — the eight acts
  (B · I · # · lists · ☑ · ⇥ · ⑂ · ⋯).
- **LK9 — The Read page: A** — chapter caption + centered page meta.
- **LK10 — The badge RESERVES SPACE** (her words: *"text shouldn't go
  under the take icon … maybe just reserve some space for it?"*): on a
  fanned block, text never runs under ⑂ — the first line ends short of a
  reserved badge gutter. Implementation note for the owning batch (S2
  takes; the editor hosting is S1's): an exclusion rect at the block's
  first fragment's trailing corner, badge drawn as an OVERLAY (P-8:
  overlays, never rendering attributes).
- **LK11 — Both spike halves KEPT AND COMMITTED, her ratification**
  (*"definitely keep both spikes that were created and commit them as
  well - they matter"*): the in-process bench (`Spike/`) AND the
  real-touch UITest half (`TK2SpikeUITests`) — both already committed
  and pushed (`eecb4f5` · `0fd69cc`). The Stage 0 gate record's
  keep-the-spike deviation no longer rides the architect's reasoning
  alone; it is HER ruling now.

**The look canon is SETTLED for the v1 build** — mockups v1+v2 plus
LK1–LK11 are the styling canon S1–S4 build toward. Further look rounds
happen over REAL screenshots at stage gates (and at her word), not more
HTML.

---

## The settled shape (the sitting's synthesis — BINDING; built from M1–M14)

- **The editor: Write-true.** ONE continuous TK2 `UITextView` over the whole
  note (M1), block IDs riding ranges via the shared pure identity core
  (`BlockRangeIndex`, `EditorDocument`, crystallization/reconciler,
  `BoundarySnapping`, `SegmentationRules` — kept platform-neutral since
  Phase 9 for exactly this). Markdown-as-content renders styled, with the
  13g typing behaviors and a compact keyboard toolbar (M11); autosave/churn
  through the shared coordinators. The Mac's Write, on the phone's terms.
- **Blocks.** The caret's block is always known. Doors: the extended iOS
  text edit menu (M2's long-press reading), the focused block's ⋯, and the
  keyboard bar. Callout frames render; comments are a block-menu sheet with
  full CRUD and a small marker on commented blocks (M12).
- **Takes.** Fanned blocks wear the badge; horizontal swipe flips takes IN
  PLACE as a PEEK (M5/M6), sticky while the note is open with a visible
  peeking marker (M9); ✓ — on the flip pill or in the browser — is the ONLY
  act that chooses (`chooseVariant`); the takes browser (badge/expand)
  carries the four verbs: choose · new take · edit any · archive/delete
  (M4). Direction held open, never v1: simplified mobile LENSES from the
  takes surface (M9's note) — the sticky peek is deliberately lens-shaped.
- **Structural.** Divide + merge ship exactly where the Mac needs no
  ceremony — divide auto-proceeds on unique match via shared
  `CutPropagation`, fanless merge is instant; where the Mac would open a
  ceremony the phone refuses and names the Mac (M10). Extract deliberately
  absent from v1.
- **The app.** Shelf-first (M7): the Books/shelf home with the Today's
  Entry button (create-or-open, the notebook rule); tab bar **Shelf ·
  Library**; Library = everything + search, bookless notes a filter (the
  Pool's phone home). Books open into the Read flow (M8): the calm
  continuous column, chapters, virtualized per P3; tap into a note to
  write. The Phase 8 capture views RETIRE when their replacements land;
  the bootstrap/session/sync shells carry over unchanged.
- **Sync & store.** Unchanged Phase 8 machinery — the phone is a second
  client of the one core + engine; the A4 fence holds; Release installs
  (M14); **NO schema anywhere in v1** (a schema need is a SyncSpec §12
  lockstep event — stop, mirror-first, her explicit go).

**Built ahead of 13e (the inherited question 4, answered):** the takes
browser's management verbs are v1-scoped to M4's four; 13e's Mac additions
(reorder takes, move-take-into-block, copy-all/takes-to-blocks, takes-aware
find&replace) are ADOPTED AFTER 13e lands rather than pre-built. The
double-build risk is one additive second pass over the browser screen —
accepted. The swipe/peek grammar and everything else above is phone-native
and untouched by 13e.

## The binding principles (the 13b constitution — copied verbatim per the `/architect-phase` skill; BINDING for every batch)

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

*Application precisions carried with the constitution (13b's build record,
binding the same way):* P-1's scope is the ROUTED vocabulary, grown
incrementally (surface-local doors declare `.surface`, never mis-filed);
P-3 keeps TWO deliberate surface kinds — the FULL-DOCUMENT editor is never
absorbed into the pane surface, both kinds consult the ONE authority and
the ONE per-post autosave coordinator, and any liveness extension extends
the authority's one-live-ring contract ON the authority, never a second
mechanism beside it; storage-coupled code lives feature-side; parity
refactors keep every pre-move name as forwards so existing pins pass
UNMODIFIED; every equality-gated sink delivers its stored state AT WIRE
TIME, and overlay geometry refreshes trigger on EVERY input axis (storage
edits, width reflows, the first post-layout pass). *Phone reading of P-3:*
the continuous Write surface is the full-document kind (the Mac
`EditorTextView`'s iOS cousin over the same shared brain); read tiers
compose the pane pattern; ONE live editor per the P3 invariant — the
phone gets no second liveness mechanism.

## Execution plan — stages

Fresh Fable implementer per batch (M13); the review ladder per stage over
the combined diff; red-on-old absolute; every batch brief carries the
environment-traps section below verbatim. **Each stage CLOSES like a
phase** (her mid-sitting directive): the ladder runs, counts land in this
file by own runs, findings get written dispositions, and the next stage's
batch brief is authored before it opens. **The mobile acceptance spine
(P-6's analog): from Stage 1, a scripted walk suite (`MobileWalkTests`)
over the phone's happy paths — it grows with every stage, rides every
batch run, and a broken walk step is a regression by definition.**
Design ambiguities run PROVISIONAL-and-continue with her bundle at stage
gates (the autonomy calibration); author-only calls remain hard stops.

| Stage | What | Gate |
|---|---|---|
| 0 | **The TK2-on-iOS spike** (throwaway; the Phase 6 precedent). Prove on iOS 26.2: TK2 opt-in + the downgrade-canary story on `UITextView`; 50k-word scroll/height/jump/typing; **block-ID attribute survival under iOS-native mutations — autocorrect, dictation, predictive text** (the identity risk the Mac never had); the M5 horizontal-pan-over-block gesture coexisting with selection/scroll; edit-menu extension items; keyboard-avoidance reflow. Memo: `notes/plans/mobile-tk2-spike-memo.md` | Decision memo — the architect rules; any red flag goes to the author |
| 1 | **The editor core** — the continuous Write surface composing the shared identity brain + autosave/churn + markdown render & typing behaviors + the keyboard bar (M1/M11); the trailing-newlines defect pinned dead (L9) | Ladder; her feel round on device |
| 2 | **Takes** — badge, swipe-peek (sticky + marker), ✓, the browser with the four verbs; fanned divide/merge refusals (M4/M5/M6/M9/M10) | Ladder; her feel round |
| 3 | **The app shape** — shelf home + Today button + Library/search + navigation + new-note minting; the Phase 8 capture views retire (M7) | Ladder |
| 4 | **Read flow + comments/callouts + structural doors** (M8/M10/M12) | Ladder |
| 5 | **Device hardening + the sync round with her** — real-device convergence, offline, the S5 conflict check (Phase 8's still-pending device items fold in); on-device performance | Her checklist |
| — | **Design/beauty rounds** — iterative sittings with her over screenshots/TestFlight builds; the acceptance bar is hers (*"beautiful and easy to use"*) | Her acceptance |

### The ledger

| # | Item | Status |
|---|---|---|
| L1 | TK2-on-iOS spike + decision memo | **DONE 2026-08-03** — ADOPT ×6 ruled at the Stage 0 gate (the gate record below); the spike KEPT as the executable §5 form (the recorded deviation) |
| L2 | Editor core (identity, autosave, markdown render, keyboard bar) | pending (S1) |
| L3 | Takes surface (badge, swipe-peek, ✓, browser, four verbs) | pending (S2) |
| L4 | Shelf home + Today + Library/search + nav; capture views retire | pending (S3) |
| L5 | Read flow | pending (S4) |
| L6 | Comments & callouts, view + edit | pending (S4) |
| L7 | Divide/merge doors + ceremony refusals | pending (S4) |
| L8 | Formatting typing behaviors + toolbar (split across S1/S4 at batch briefs) | pending |
| L9 | iOS trailing-blank-lines defect — pinned dead in the new editor (accidental accrual vs the 2026-07-12 MEANINGFUL stored spacing — never a blanket trim; this row OWNS the KnownIssues entry) | pending (S1) |
| L10 | Device round + sync soak (incl. Phase 8's pending device items) | pending (S5) |
| L11 | Design/beauty rounds with her | pending (post-S5, iterative) |
| L12 | 13e-vocabulary adoption (reorder/move/copy-all, takes-aware F&R) | deferred BY DESIGN — after 13e lands |
| L13 | The look track: HTML mockups of the four key surfaces (shelf home · Write page with fanned block + peek pill · takes browser · Read flow) → her look sittings → the mobile styling canon S1–S4 build toward | **v1 FLICKED (LK1–LK5 ruled) · v2 DELIVERED** (`Spikes/MobileMockups/mobile-look-v2.html` — rulings applied; the four open items as lettered options: pill A/B/C · tabs A/B/C · keyboard bar A/B/C · Read A/B, plus the applied-rulings confirm frames) — her v2 flick pending |

## Environment traps (mobile — carried verbatim into every batch brief)

- Simulator destination: **iPhone 17 family on the MOST RECENT iOS
  runtime — her standing rule (LK1: "def only go for the iPhone 17 most
  recent iOS simulators")**. Today that is
  `-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'`;
  when a newer runtime lands, move to it and re-verify. The iPhone 16
  sims on this machine are iOS 18.3 — BELOW the deployment target; they
  resolve to nothing (the sitting's own trap).
- Mobile tests: `xcodebuild test -project App/Variorum/Variorum.xcodeproj
  -scheme VariorumMobile -destination …` from the repo root; confirm the
  "Test run with N tests" line; zsh `pipestatus`.
- The A4 fence: debug/simulator builds resolve the DEV store and never
  sync — safe by construction; NEVER point a debug build at the real
  store; her phone installs Release (M14).
- Shared-core discipline: touch `Sources/VariorumCore` only deliberately
  and small; before landing any shared-core change, verify core + Mac
  suite + spine by own runs (13k finals: core 1034/114 · Mac 1191/208
  with the recorded tripwire · spine 51/7); Mac tests run from
  `App/Variorum/`. `Sources/VariorumCore/Sync/` is Fable work (moot under
  the all-Fable cast, M13).
- Worktree: merge `main` → `mobile` regularly; `mobile` → `main` at
  milestones at her word; push `origin mobile` after commits.
- NO schema in v1; a schema need is a SyncSpec §12 lockstep event
  (mirror-first, her explicit go) — stop and report.
- NEVER add a custom build configuration (the 4G trap — SPM deps build
  Release under any configuration not named exactly "Debug", silently
  stripping DEBUG-gated oracles).
- Spike code lives under `App/Variorum/VariorumMobile/Spike/`,
  DEBUG-gated, its UITest half behind the separate `TK2SpikeUITests`
  scheme — **KEPT as the executable TEXTKIT2 §5 form for iOS point
  releases** (the Stage 0 gate record's recorded deviation; this bullet
  originally said deleted-at-stage-close). Re-run it after every iOS
  update before trusting an editor milestone. It never rides the
  baseline suite.

## Stage 0 batch brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, in full:** `CLAUDE.md` · this file (`notes/plans/mobile-app-plan.md`)
· `notes/TEXTKIT2_NOTES.md` · `notes/plans/phase-06-tk2-spike.md` (the Mac
precedent — mirror its inventory shape and memo form). You work in the
`~/dev/variorum-mobile` worktree on branch `mobile`.

**Objective:** learn the TK2-on-iOS facts on iOS 26.2 BEFORE the editor is
designed onto them. Throwaway spike, not production code.

**The inventory (each item gets measurements + an adopt/fallback verdict):**
1. **TK2 opt-in + downgrade canary:** construct `UITextView` TK2-explicitly;
   find and pin the iOS analog of the Mac's `willSwitchToNSLayoutManager`
   canary; enumerate any downgrade triggers hit.
2. **Scale:** a 50k-word document — typing latency at the tail and middle,
   scroll stability, height-estimate convergence, scroll-to-location
   fidelity (the Phase 6 inventory, iOS edition).
3. **Attribute survival under iOS-native mutations:** block-ID custom
   attributes riding ranges through autocorrect replacements, dictation
   insertions, predictive-text acceptances, and multi-stage (marked-text)
   input. This is the identity risk the Mac never had — measure drift
   honestly; it shapes Stage 1's reconciler.
4. **The M5 gesture:** a horizontal pan recognizer scoped to a block's
   fragment rects, coexisting with text selection, loupe, and vertical
   scroll; a peek-overlay proof (swap displayed text for a block range
   without storage writes).
5. **Edit-menu extension:** custom block items on the iOS text edit menu
   (`UIEditMenuInteraction`) — the M2 door's mechanism.
6. **Keyboard:** avoidance/reflow behavior with a bottom accessory bar (the
   M11 toolbar's home).

**Deliverable:** `notes/plans/mobile-tk2-spike-memo.md` — per-item evidence
and verdicts, exact OS/SDK/simulator cited, an overall
adopt/fallback-per-item recommendation for the architect to rule on. Spike
code committed under `App/Variorum/VariorumMobile/Spike/` (DEBUG-gated
screen reachable from the debug root — mechanics your call), to be deleted
at stage close.

**Constraints:** no `Sources/VariorumCore` changes (a need = report back);
no schema; no Mac-side touches; tests are not required for throwaway spike
code — the canary + measurements are the evidence; the environment-traps
section above binds; commit as you go with the standing trailer and push
`origin mobile` at bout end. Lookup exception: at most ONE Sonnet lookup
subagent at a time, EXTERNAL facts only (Apple docs, API signatures) —
never delegate repo reading, never web-search directly yourself.

## Stage 0 — CLOSED (the gate record; the architect's ruling, 2026-08-03)

**Verification before ruling (verify-don't-trust):** three commits
(`eecb4f5` · `0fd69cc` · `d0b49d3`, interleaved cleanly with the
look-round commit), diff scope confirmed by the architect's own
inspection — spike files + the DEBUG door + the UITest half + the memo,
**zero `Sources/VariorumCore` lines, zero schema, zero Mac-side files**;
the memo (`notes/plans/mobile-tk2-spike-memo.md`) read IN FULL; the
mobile suite re-verified by the architect's own run (**14/4 green** — the
throwaway UITest half rides its own `TK2SpikeUITests` scheme and never
touches the baseline).

**RULING: ADOPT on all six items — the Stage 0 gate PASSES.** The memo's
evidence is measured, carries its caveats honestly (Debug, simulator,
single point release), and includes the positive control a poll canary
needs (the deliberate `.layoutManager` downgrade, detected). **The memo's
seven Stage 1 obligations are BINDING plan content** — the Stage 1 brief
below folds them in. The headline (item 3: iOS strips custom attributes
on EVERY insertion path) changes an implementation mechanism, not a
capability: block-ID attributes become a derived projection re-stamped
from `BlockRangeIndex` after every edit (~0.04 ms/paragraph, measured),
with a DEBUG no-MISSING-runs audit. **No red flags for the author** —
the headline is reported to her for transparency, not as a gate.

**One recorded deviation from this plan's own earlier note (reason
stated, never silent):** the spike is **KEPT, not deleted** — the memo's
obligation 7 makes its auto-run the executable TEXTKIT2 §5 form for iOS
point releases, exactly as the Mac's Phase 6 spike survives as the §5
matrix's executable form (AppSpec §15). It stays DEBUG-gated under
`Spike/`, its UITest half behind the separate `TK2SpikeUITests` scheme;
the baseline suite never carries it. The environment-traps deletion
bullet is superseded by this record.

---

## Stage 1, batch 1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the run record M1–M14 +
LK1–LK5, the settled shape, the constitution, the environment traps, the
Stage 0 gate record above) · `notes/plans/mobile-tk2-spike-memo.md` (its
seven obligations BIND you) · `notes/TEXTKIT2_NOTES.md` · AppSpec §4 and
§9 (the ops this surface calls — `autosave`, `commit`; §7's `setting`
for type-time crystallization) · the Mac editor's pure identity brain —
locate and read `BlockRangeIndex`, `EditorDocument`, the
crystallization/reconciler path, `SegmentationRules`, `BoundarySnapping`
(App-side Editor feature + `VariorumCore/Domain`). You REUSE this brain;
you never fork it.

**Objective:** the continuous Write-true editor core on the phone (M1) —
one TK2 `UITextView` over a whole note, block identity live, autosave
flowing, the canary installed. This batch is the foundation; takes,
gestures, markdown, and the app shape are LATER batches.

**Scope, batch 1:**
1. **The pure-brain availability move:** make the shared identity brain
   compile into the mobile target (folder/target membership or a
   `Shared/` move — the 3C parity pattern: every pre-move name kept as
   forwards, ZERO test edits, the Mac suite untouched by your own run).
   No AppKit types may smuggle into the pure layer (the Phase 15
   brief's standing line — it is why this project is cheap).
2. **`MobileEditorTextView`:** a TK2-explicit `UITextView` wrapper + the
   checkpoint canary (obligation 2: assert-after-mutation + idle tick;
   debug asserts, release os_log + a visible diagnostic) +
   `keyboardLayoutGuide` avoidance + an `inputAccessoryView` bar shell
   (the M11 toolbar's home — its acts land in a later batch).
3. **Identity as projection (obligation 1):** render a post into the
   attributed document (block IDs as attributes via the shared mapping);
   edits report exact deltas; block-ID attributes RE-STAMPED from
   `BlockRangeIndex` after every edit; a DEBUG audit asserts no MISSING
   runs after reconciliation.
4. **Autosave/churn:** per-variant routing from block identity through
   the shared `AutosaveCoordinator`; `charDelta` from block-scoped
   deltas (retiring the Phase 8 whole-buffer `EditCost` NIT for the new
   surface).
5. **Crystallization at the tail** (type-time, §7's rule) + bulk entry
   on paste — through the shared segmentation brain.
6. **The L9 pin:** a red-on-old test proving the new editor never
   accrues trailing blank lines by accident while MEANINGFUL stored
   spacing (the 2026-07-12 rule) round-trips untouched.
7. **`MobileWalkTests` is BORN** (the acceptance spine): open note →
   type → autosave lands → identity intact → canary silent. It grows
   every stage and rides every batch run from now on.

**Explicitly NOT batch 1:** takes UI, the swipe/peek, markdown
render/typing behaviors (batch 2 — its brief is authored at this batch's
close), the app shape, Read flow, comments/callouts, retiring the Phase 8
capture views (they keep working untouched until S3 replaces them).

**Discipline:** tests with every step (VM/state-transition style — the
Phase 8 mobile tests are the house pattern); the environment traps bind
(iPhone 17 / most recent runtime, LK1); mobile suite + `MobileWalkTests`
green at bout end by your own runs — AND core `swift test` + the Mac
suite + the spine by your own runs IF you touched anything shared
(record exact counts; 13k baselines: core 1034/114 · Mac 1191/208 with
the recorded tripwire · spine 51/7); commit as you go with the standing
trailer; push `origin mobile` at bout end; **append your batch record to
this file** (what shipped, counts, interpretations for the reviewer,
PROVISIONALs). Lookup exception: ONE Sonnet lookup subagent at a time,
external facts only. The review ladder runs at STAGE end, not per batch.

## Stage 1, batch 1 — BATCH RECORD (implementer, 2026-08-03; commits `6264049` + `7316ae9`)

**All seven scope items shipped.** Per item:

1. **The pure-brain availability move (`6264049`)** — `BlockRangeIndex`,
   `CrystallizationPlanner`, `EditorProjectionEngine` (the surface ledger
   + projection policy), and `TextMetrics` git-mv'd to
   `App/Variorum/Shared/EditorBrain/` (both app targets sync the
   `Shared/` folder — ZERO pbxproj edits); `EditorDocument` SPLIT: the
   platform-neutral core (`EditorDocumentCore.swift` — attribute key,
   separator doctrine, `materializeCore(_:tail:base:)` taking
   caller-supplied base attributes, `blockID(at:in:)`) lives in
   EditorBrain, and the Mac keeps `baseFont`/`baseParagraphStyle`/
   `baseAttributes`/`materialize(_:tail:)` as a `nonisolated extension`
   forwarding to the core + `MarkdownStyling.style` — byte-identical
   behavior, every pre-move name intact, ZERO test edits.
   *Interpretation for the reviewer:* the brief named five brain pieces;
   `EditorProjectionEngine` + `TextMetrics` (its dependency) rode along —
   they ARE the projection discipline's pure brain and the same parity
   argument applies; nothing else moved.
2. **`MobileEditorTextView`** — TK2-explicit, canary, keyboard.
   **MEASURED TRAP (a batch finding future batches need):**
   `UITextView(usingTextLayoutManager: true)` is a bridged ObjC FACTORY
   (`+textViewUsingTextLayoutManager:`); invoked on a Swift SUBCLASS it
   returned an instance whose Swift stored properties were NEVER
   initialized — SIGSEGV at first ivar access (crash report
   `VariorumMobile-2026-08-03-031331.ips`, frame:
   `MobileEditorTextView.onCanaryFired.setter`). The shipped
   construction is the TRUE designated `init(frame:textContainer:)` over
   an explicit TK2 stack (`NSTextContentStorage` + `NSTextLayoutManager`
   + container, strong refs kept — the back-pointers are weak). The
   checkpoint canary (memo obligation 2): immediate checkpoint at arm +
   assert-after-mutation (called from the VM after every processed edit)
   + a 30 s idle tick; debug = hard assert (the Mac's N2 injectable
   seam), release = os_log fault + the VM's visible `canaryMessage`.
   `keyboardLayoutGuide` avoidance via `MobileWriteSurfaceView` (bottom
   edge pinned — obligation 4); the `inputAccessoryView` 44 pt bar SHELL
   (M11's acts deliberately later); the `isPasting` bulk hint (the Mac
   flag's shape).
3. **Identity as projection (obligation 1)** — `MobileEditorViewModel`
   materializes through the shared core with phone base attributes;
   edits report exact ranges via the storage delegate; block-ID
   attributes are RE-STAMPED from `BlockRangeIndex` over every edited
   range; a DEBUG audit walks the whole tiling after every edit (no
   MISSING runs, separators/tail unowned, index length == storage
   length) with an observable failure counter. **The iOS system-path
   answer:** gateless edits (autocorrect's `replace(_:withText:)`,
   dictation, marked-text commits) arrive at the storage delegate with
   no pending verdict and route via `fallbackVerdict` against the
   pre-edit index — nothing that lands in storage goes unrouted (tested
   with a gate-bypassing storage replacement).
4. **Autosave/churn** — per-variant routing through the SHARED
   `AutosaveCoordinator` (single-owner closures, the mobile shape);
   block-scoped `charDelta` retiring Phase 8's whole-buffer `EditCost`
   for this surface. **Measured iOS wrinkle:** `didProcessEditing` can
   WIDEN the coalesced `editedRange` under attribute fixing (a 5→6
   replacement reported length 7 → cost 13 instead of 11), so policed
   edits carry the EXACT cost captured at the gate
   (`range.length + replacement UTF-16`); system paths use the
   report-derived figure (approximate is fine — churn counters are
   approximate by design, SyncSpec §6).
5. **Crystallization** — the Mac's paths ported over the shared brain:
   type-time (the 2026-07-12 completes-when-the-next-begins timing),
   bulk on paste (`isPaste` through the gate; the k−1 gap rule
   round-trips), one-block journal semantics (first text mints THE
   block; Enter is content forever), the idle mint (2 s clock,
   marked-text skip — iOS multi-stage input makes this guard earn its
   keep), the leading-run attachment (typed trailing Enters become the
   preceding block's durable content), and the teardown backstop
   (`finish()` mints + attaches + flushes).
6. **The L9 pin** (`MobileTrailingNewlinesTests`, 5 tests) — accidental
   accrual refused (editless open/render/close cycles are byte-stable
   and write NOTHING — `flushCount == 0`; typing writes exactly the
   typed bytes across cycles); meaningful stored spacing round-trips
   byte-exactly (typed k−1 gaps via the attachment; pasted gaps; a
   neighbor's spacing under an adjacent edit) — NEVER a blanket trim.
   **Discrimination REVERT-VERIFIED (the 13k hollow-pin currency):**
   (a) a blanket-trim mutation at both VM record doors → 4 red issues
   (`deliberateTrailingEntersPersistAsContentAndNeverTrim` at every
   checkpoint: flush, teardown, re-open surface, re-store); (b) an
   accrual mutation (autosave text + "\n") → 6 red issues across
   `typingWritesExactlyTheTypedBytesAcrossCycles` (×3),
   `editingANeighborNeverTouchesStoredSpacing`, and walk 1 (×2);
   (c) removing the re-stamp → the DEBUG identity audit's FATAL STOP on
   the first stripped insertion ("block-ID attributes disagree with
   BlockRangeIndex"). All mutations reverted; final suite green.
   *Honest framing:* the Phase 8 defect's mechanism lives in the SwiftUI
   `TextEditor` view layer (never traced, not headless-reproducible);
   that surface is REPLACED, not patched — the pin guards the NEW
   editor's every store-write door in both directions. The KnownIssues
   row STAYS until the capture surface retires (S3); its resolution note
   belongs to that closeout.
7. **`MobileWalkTests` BORN** (2 walk steps, riding every run from now
   on): walk 1 — today's entry opened in the REAL TK2 view (explicit
   stack, canary armed), typed via the view's own `insertText`, autosave
   lands, ONE block, identity audit clean, desync count 0, canary
   silent, no refusal spoken, teardown byte-stable; walk 2 — fresh-note
   type-time crystallization + teardown mint, byte-stable surface.

**Counts, all by this implementer's own runs:**
- **Mobile: 38 tests / 11 suites GREEN** (single run, zero relaunches;
  the Phase 8 baseline 14/4 intact within it) — final run after all
  mutations reverted.
- **Shared-touch verification (after the parity move): core 1034/114
  GREEN · Mac 1191/208 with EXACTLY the one recorded environment-gated
  tripwire red, by identity
  (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`)
  · spine 51/7 GREEN.** Commit 2 touched only mobile-target files, so
  those runs stand.
- *Spine-command note for future records:* `-only-testing:
  VariorumTests/TutorialWalkTests` (the FILE name) selects ZERO Swift
  Testing tests on a plain xcodebuild run — the 51/7 figure comes from
  filtering the SEVEN suite type names (`TutorialBookShapeTests` ·
  `TutorialDoorTests` · `TutorialWritingActsTests` ·
  `TutorialTakesActsTests` · `TutorialStructureActsTests` ·
  `TutorialLookingActsTests` · `TutorialLibraryActsTests`).

**PROVISIONALs (for the stage-gate bundle):**
- **P1:** the cross-block refusal copy — *"This edit spans more than one
  block — edit inside one block for now."* — batch-1 wording; S4's M10
  doors (divide/merge) and any adopted compounds replace it.
- **P2:** `MobileEditorStyle`'s uniform paragraph gap (font-derived,
  0.35×pointSize, per-paragraph per the 2026-07-12 boundary-invisibility
  rule) — size and everything visual is the look track's (L13/LK2).
- **P3:** the DEBUG-gated "Write S1" door (a sheet over the capture root
  opening today's entry in the new editor) — NOT the app shape (S3's);
  exists so the feel round can reach the surface; capture views
  byte-untouched.
- **P4:** `MobileWriteScreen`'s status voice is three caption rows
  (canary / seal / status) — functional-unstyled placeholder chrome.

**Deliberate absences (recorded so the reviewer reads them as scope, not
holes):** no scroll anchoring at all this batch (obligation 3 honored by
having NO px anchoring; caret preserved by TEXT location on full render;
the hybrid jump primitive arrives when a batch needs restoration), no
edit-menu door (obligation 5's seam is batch 2+, M2), no soft-newline
⇧⏎ distinction (hardware-keyboard story, later batch), no markdown
render/typing behaviors (batch 2 by the brief), takes/badges/swipe
(S2), structural doors (S4). Device items (obligation 6 — live
autocorrect/dictation, loupe feel) ride the stage's feel round as the
memo assigns.

**NO `Sources/VariorumCore` lines; NO schema; NO Mac-side behavior
change** (the Mac diff is the parity move's mechanical split only).
Commits: `6264049` (parity move) · `7316ae9` (editor core + tests);
pushed to `origin mobile` at bout end with this record.

---

---

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
