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
| L2 | Editor core (identity, autosave, markdown render, keyboard bar) | **DONE** (S1, batches 1–3; ladder CLOSED at round 2) |
| L3 | Takes surface (badge, swipe-peek, ✓, browser, four verbs) | pending (S2) |
| L4 | Shelf home + Today + Library/search + nav; capture views retire | pending (S3) |
| L5 | Read flow | pending (S4) |
| L6 | Comments & callouts, view + edit | pending (S4) |
| L7 | Divide/merge doors + ceremony refusals | pending (S4) |
| L8 | Formatting typing behaviors + toolbar (split across S1/S4 at batch briefs) | **S1 half DONE** (render + behaviors + the six live acts; ⑂/⋯ join in S2; strikethrough/code/link ACTS recorded for the gate — LK8's eight has no such buttons) |
| L9 | iOS trailing-blank-lines defect — pinned dead in the new editor (accidental accrual vs the 2026-07-12 MEANINGFUL stored spacing — never a blanket trim; this row OWNS the KnownIssues entry) | **DONE in the new editor** (the L9 pin, revert-verified both directions; the KnownIssues row STAYS until S3 retires the capture surface — its resolution note belongs to that closeout) |
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

## Stage 1, batch 1 — ACCEPTED (architect, 2026-08-03)

Verified before accepting: the three commits inspected (diff scope —
`Shared/EditorBrain/` + mobile Write feature + tests + the record; ONE
Mac file, the forward-keeping `EditorDocument` split, covered by the
implementer's own Mac/spine runs; zero `Sources/VariorumCore`, zero
schema), the batch record read in full, and **mobile 38/11 re-confirmed
by the architect's own run**. The four PROVISIONALs (P1–P4) join the
stage-gate bundle beside LK5's ✓-finished note. **LK10 ASSIGNED to S2**
(the badge's own batch brings the exclusion-rect gutter; the editor
hosts it then — recorded against the batch-1 heads-up). The batch-1
findings (the `UITextView` factory trap; the widened `editedRange`
cost rule; the spine type-name selector) are machinery lessons carried
in `notes/plans/mobile-architect-handoff.md`.

---

## Stage 1, batch 2 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the run record M1–M14
+ LK1–LK11, the settled shape, the constitution, the environment traps,
the Stage 0 gate record, the batch 1 brief + record + acceptance) ·
`notes/plans/mobile-tk2-spike-memo.md` · AppSpec §14's 13k delta (the
nested-lists law: Tab/⇧Tab two-space unit, list-only column-0 widening,
drawn-indent clamp 6, ⏎ continuation/outdent rules, `actKeepsIndent`) ·
the Mac's markdown brain IN CODE — locate and read
`Theme/MarkdownStyling.swift` and the markdown-editing machinery (lead
plans, ⏎ continuation, Tab/⇧Tab, the outdent unit — grep the Mac Editor
feature; the 13g/13k pins name the law).

**Objective (M11's first half):** the phone renders and TYPES the
markdown vocabulary exactly as the Mac does — one brain, byte-identical
stored outcomes.

**Scope, batch 2:**
1. **The markdown brain's parity availability** — the batch-1 pattern:
   tokenizer/lead-plan/continuation/indent logic becomes ONE shared
   brain both targets compile (split-with-forwards where a file is
   platform-typed; per-platform attribute EMISSION stays thin and
   view-side); ZERO test edits; core + Mac + spine green by your own
   runs after the move.
2. **Render on the mobile editor:** display == stored, dimmed markers,
   headings/bold/italic/lists/checkboxes/nesting per the 13k law
   (drawn-indent clamp 6; indented headings stay plain text), the
   inline-code chip in `MobileEditorStyle`'s neutral values (the voice
   pass is a later batch — L13's canon applies then). Styling must
   NEVER mutate stored bytes — the identity audit and L9 pin stay green
   throughout.
3. **Typing behaviors through the one brain:** ⏎ list continuation
   (end-of-line law; a continued checkbox is born unchecked; lead-only
   exits; ⏎ on an empty nested item outdents first, exits at the
   margin), Tab/⇧Tab nesting (two-space unit, the ONE shared outdent
   unit), re-leading under `actKeepsIndent` (a heading act on a nested
   item mints a working column-0 heading — the 13k MAJOR's law).
4. **Checkbox tap-toggle:** a tap on the checkbox glyph toggles it — an
   ordinary policed edit through the pipeline (never a storage bypass).
5. **The keyboard bar's SIX formatting acts live** (B · I · # · •– ·
   ☑ · ⇥ — LK8's eight minus ⑂ and ⋯, which arrive WITH their surfaces
   in S2; a door that can never act isn't rendered, P-2 — recorded as
   the application, not a deviation from LK8).
6. **`MobileWalkTests` grows a markdown walk:** type a list → ⏎
   continues → Tab nests → toggle a checkbox → a heading act at depth →
   stored bytes byte-checked against the Mac brain's expected output →
   canary silent, identity audit clean.

**Explicitly NOT batch 2:** takes/badges/swipe/⑂ (S2), the edit-menu
door (S2), ⋯ (with its menu), the voice-token pass (a later look-canon
application batch), the app shape (S3), Read flow (S4).

**Discipline:** exactly the batch-1 brief's — tests with every step;
the environment traps bind; mobile + MobileWalkTests green at bout end
by your own runs, AND core + Mac + spine by your own runs if anything
shared moved (record exact counts; the spine needs the SEVEN suite TYPE
names — the batch-1 record lists them); NO `Sources/VariorumCore`
lines; NO schema; commit as you go with the standing trailer; push
`origin mobile` at bout end; **append your batch record to this file**;
ONE Sonnet lookup subagent at a time, external facts only. The ladder
runs at STAGE end.

## Stage 1, batch 2 — BATCH RECORD (implementer, 2026-08-03; commits `1a21024` + `32726b8`)

**All six scope items shipped.** Per item:

1. **The parity availability (`1a21024`)** — the FIRST finding shaped the
   move: **the pure LAW was already shared** — `MarkdownSyntax` /
   `MarkdownEditing` (tokenizer, lead plans, ⏎ verdict incl. the
   outdent-first rule, the ONE `outdentUnitLength`, `actKeepsIndent`,
   `checkboxToggle`) live in `Sources/VariorumCore/Domain`, compiled by
   both targets since 13g/13k, and `MarkdownRendering.maxDrawnIndentLevel`
   (the clamp-6) with them. What was platform-typed was the SURFACE
   arithmetic and the styling algorithm, and those moved: **(a)**
   `Shared/EditorBrain/MarkdownSurfaceDoors.swift` — the
   line-lookup-and-rebase every door repeats (act plans → document-offset
   edits + selection; the ⏎ verdict rebased; the checkbox 3-for-3; the
   link address), Foundation-only, the EditorBrain no-UI-framework charter
   intact; **(b)** `Shared/MarkdownFace/MarkdownFaceCore.swift` — the
   13g/13k styling algorithm transplanted VERBATIM (face-attribute
   clear/restore, chip-first over the whole span, markers-then-content
   composition, the +1 line-widening, the zero-write fast path),
   parameterized over caller-supplied base font + palette, with
   conditional `NSFont`/`UIFont` typealiases **in its OWN `Shared/`
   subfolder** — deliberately NOT in EditorBrain, whose charter forbids UI
   frameworks (the one structural interpretation for the reviewer). The
   Mac keeps every pre-move name as forwards (`MarkdownStyling` holds the
   voice-token Palette + storage; `MarkdownActs.apply/listReturn/
   toggleCheckbox/linkAddress` consume the shared doors with their
   NSTextView trio unchanged). **ZERO test edits**; per-platform attribute
   EMISSION stays thin and view-side exactly as the brief drew it.
2. **Render (`32726b8`)** — the face at the three Mac-parallel hooks:
   `renderFull` (full materialization → `MarkdownFace.style`, the
   `EditorDocument.materialize` forward's shape), `storageDidEdit`
   (line-scoped restyle following every keystroke — the Mac's exact hook;
   the observer's `.editedCharacters` guard keeps attribute writes from
   re-entering), `programmaticReplace` (re-derive after the base reset —
   the `applySeamEdit` posture; rides the differential and mint paths).
   Neutral values in `MobileEditorStyle.markdownPalette` (secondary
   label / system link / `secondarySystemFill` chip — the Mac
   systemFallback's iOS cousins; the voice pass is L13's). Display ==
   stored byte-for-byte throughout; the identity audit and the L9 pin ran
   green in every suite run. **Clamp-6 note for the reviewer:** the
   editing face renders nesting as LITERAL STORED SPACES (display ==
   stored) exactly as the Mac's Write editor does — the drawn-indent
   clamp lives in shared `MarkdownRendering` and applies to
   lead-substituting READING surfaces (S4's Read flow inherits it); no
   editing surface on either platform clamps, so there is nothing to
   clamp here.
3. **Typing behaviors** — ⏎ via the `insertText` override (the honest iOS
   intercept: software return, hardware return, and the tests' typing
   proxy all arrive there; marked-text composition stays ordinary):
   `MobileMarkdownActs.handleReturnKey` keeps the newline THE untouched
   keystroke (`super.insertText("\n")`) with the lead a SECOND policed
   insertion — the K5 doctrine's letter — and the exit/outdent halves
   consume with policed deletions through the one shared unit; the
   continuation pre-gates the newline so a sealed note refuses exactly
   where the Mac's own delegate would. Hardware Tab/⇧Tab as
   `UIKeyCommand`s (`wantsPriorityOverSystemBehavior`) sharing
   `performTabKey`/`performShiftTabKey` with the bar's ⇥; empty plan =
   the ordinary policed `"\t"` (the `indentLists` fallthrough shape).
   Re-leading under `actKeepsIndent` is the shared brain's — pinned at
   depth (heading act on a nested item mints the working column-0
   heading; bullet→checklist keeps nesting).
4. **Checkbox tap-toggle** — an ordinary policed 3-for-3 through the gate
   (never a storage bypass): `MobileCheckboxTapRouter` decides
   strictly-inside at `shouldReceive` (a tap anywhere else is never
   consumed — the Mac's before-`super.mouseDown` claim in UIKit's
   grammar), the caret goes back where it was, sealed notes consume the
   tap and speak the refusal (the Mac's exact posture).
5. **The bar's SIX live acts** — B · I · # · • · ☑ · ⇥ (LK8's eight minus
   ⑂/⋯, which arrive WITH their surfaces in S2 — P-2's application, not a
   deviation), every act firing `MobileMarkdownActs.apply` = pre-gate +
   select + `insertText`/`deleteBackward` (UIKit's ordinary input path:
   the storage delegate reports, the verdict routes, autosave/churn/
   refusals for free — proven by the store-landing assertions).
6. **The markdown walk (walk 3)** — type a list → ⏎ continues → the empty
   item EXITS (K5) → Tab nests the minted item → the bar re-leads it as a
   checklist (nesting survives) → the tap checks the box → the nested
   continuation (a content newline, I4) → the heading act at depth mints
   the column-0 heading → **stored bytes byte-checked**:
   `["- milk", "  - [x] eggs\n# Title"]`, canary silent, audit clean,
   zero desync, no refusal spoke.

**BUG-CLASS FIX (traced, pinned, revert-verified):** the batch-1 iOS
re-stamp took its EXTENT from the `didProcessEditing` report, and iOS
attribute fixing WIDENS that report (the batch-1 measured wrinkle) —
walk3 caught the widening CROSSING A BOUNDARY: a 2-char indent insert at
a block's line start reported `+9`, the whole edited paragraph INCLUDING
its terminating newline — the block SEPARATOR — which then wore an owner
(diagnostic evidence: entries len 6/len 8, attribute runs `[7,+9]`; the
DEBUG audit's fatal stop caught it, exactly its job). Fix:
`restampProjection(over:)` re-derives the projection over the touched
range FROM `BlockRangeIndex` (entry intersections gain their IDs;
separators and the tail shed any) — extent from the AUTHORITY, so a
widened report can only re-stamp what is true. O(entries) integer walk
with early break, iOS-only (the Mac inherits, never re-stamps); the
prefix-sum bisect is the recorded upgrade if corpus scale ever measures
it. **Pin:** `aWidenedAttributeFixReportNeverPoisonsTheSeparator` — DIES
at the identity audit on the pre-fix mechanism (revert-verified: the
`.block` arm restored to the raw-report stamp → the pin run crashed;
restored → full suite green).

**RECORDED FINDING for the architect (documented, deliberately NOT
fixed — core is out of batch scope):** a fresh-typed INDENTED list line
at the OPEN TAIL loses its indent when the paragraph crystallizes.
Mechanism: `SegmentationRules.crystallizedBoundary` (core, Phase 2 —
pinned there: *"horizontal whitespace still trims off piece edges"*)
trims the minted paragraph, and that law predates 13k K8, which made
leading indent MEANINGFUL on list lines. **SHARED behavior — the Mac's
tail path is byte-identical**, so the one-brain claim holds and the
phone reproduces the Mac's law exactly; the asymmetry it produces (the ⏎
continuation's lead KEEPS the indent while the minted line lost its own)
is visible on both platforms when a nested list is typed fresh at a
note's end. Reconciling the Phase-2 trim with K8 is a CORE-law call
(`Sources/VariorumCore` + a pinned Phase-2 behavior = not this batch's to
change); documented by
`tailCrystallizationTrimsLeadingIndent_recordedFinding` (the Phase 5
concurrent-divide documentation pattern) so a future deliberate fix flips
it knowingly.

**Also this batch (architecture, for the reviewer):** the
UITextViewDelegate gate moved INTO the VM (`MobileEditorGateDelegate`,
installed at `attach(textView:)`; the SwiftUI face's Coordinator retired)
— every host of the surface polices identically, which is what let the
walk tests exercise the real gate; the batch-1 keyboard-bar SHELL enum
was replaced by `MobileKeyboardBarController` (its own file).

**Counts, all by this implementer's own runs:**
- **Mobile: 68 tests / 15 suites GREEN** (single run, zero relaunches;
  batch-1's 38/11 intact within it) — final run after the revert-check
  was restored. New: `MobileMarkdownRenderTests` (4, incl. the
  `MarkdownScanCount` line-scope P1 pin), `MobileMarkdownReturnTests`
  (10, incl. the trim-finding documentation), `MobileMarkdownActsTests`
  (11, incl. the widen pin and the six-act bar walk),
  `MobileCheckboxTapTests` (3, real laid-out geometry), walk 3.
- **Shared-move verification (after commit `1a21024`, which is the ONLY
  commit touching shared/Mac files): core 1034/114 GREEN · Mac 1191/208
  with EXACTLY the one recorded environment-gated tripwire red, BY
  IDENTITY (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
  re-confirmed in isolation) · spine 51/7 GREEN** (the seven suite type
  names). Commit `32726b8` touches only mobile-target files, so those
  runs stand for the bout.

**PROVISIONALs (for the stage-gate bundle):**
- **P5:** the # button CYCLES (none→H1→H2→H3→clear) — one button where
  the Mac has a three-child submenu; a selection cycles off its START
  line's state.
- **P6:** the bar's ⇥ carries both directions — tap indents, LONG-PRESS
  outdents (the software keyboard has no Tab key, so ⇥ IS the phone's
  Tab; outdent's other doors: hardware ⇧Tab and K8's ⏎-outdent-first).
- **P7:** undo across the door edits is UIKit's own input-path
  registration where the edits ride `insertText`/`deleteBackward`
  (continuation leads, acts, toggles); no bespoke undo grouping was
  added, and the phone's act-undo story (the Mac's one-group-per-act ⌘Z
  contract) is deliberately deferred to a later batch with the editor's
  broader undo review.
- **P8:** hardware ⇧⏎ reaches the ⏎ door like any return — the phone has
  no soft-newline story yet (batch-1's recorded absence); when it lands,
  it must gain the Mac's ⇧⏎ exclusion.
- **P9:** acts and the tap bail under marked text (mutating mid-IME
  composition would rewrite the composition region — the idle-mint's
  guard applied to the doors); the Mac has no such guard because AppKit's
  acts run through NSTextView's own trio.

**Deliberate absences (scope, not holes):** ⑂ and ⋯ on the bar (S2, with
their surfaces); the edit-menu door (S2); the voice-token pass over the
face palette (the look-canon application batch; values are neutral
system colors); strikethrough/code/link ACTS on the bar (LK8's ruled
eight has no such buttons — the vocabulary still RENDERS and types by
hand; the Mac reaches those acts through menus the phone doesn't have
yet — recorded for the stage gate rather than invented); no capability
registry rows yet (the registry is a later-stage move; the bar's act
table + walk assertion is the interim); the trim-finding's core fix
(above — the architect's call).

**NO `Sources/VariorumCore` lines; NO schema; NO Mac-side BEHAVIOR
change** (the Mac diff is the forwards-keeping parity move only, covered
by the recorded runs). Commits: `1a21024` (parity move) · `32726b8`
(mobile markdown) · the record commit; pushed to `origin mobile` at bout
end.

## Stage 1, batch 2 — ACCEPTED + the trim-law ADJUDICATION (architect, 2026-08-03)

**Acceptance:** verified before accepting — commits and diff scope
inspected (zero `Sources/VariorumCore`, zero schema; the two Mac files
are the forwards-keeping seams, zero test edits, baselines verified by
the implementer's recorded own runs), the batch record read, and
**mobile 68/15 re-confirmed by the architect's own run**. P5–P9 join the
stage-gate bundle.

**THE TRIM-LAW RULING (the batch-2 recorded finding, adjudicated).**
Mechanism re-traced by the architect first-hand:
`SegmentationRules.bulkSegments` trims each segmented line with
`trimmingCharacters(in: .whitespaces)` (and the crystallization boundary
shares the doctrine) — a Phase 2 rule that PREDATES 13k K8, under which
leading indent on LIST LINES is meaningful nesting content. So a pasted
nested list flattens, and a tail-typed nested item loses its depth at
crystallization — on BOTH platforms. **RULING: the trim law aligns to
K8's own boundary — a segmented line whose trimmed form is a LIST LEAD
(the shared `MarkdownSyntax` law) KEEPS its leading horizontal
whitespace; every other line trims exactly as before.** List-only — the
tokenizer's column-0 widening mirrored precisely; indented non-list
lines (headings included) keep the old trim; sentence-mode behavior
untouched and recorded. Spec basis: K8 is her ratified law and the newer
one; the Phase 2 trim is an implementation rule that never contemplated
this vocabulary; CLAUDE.md's align-implementation-to-spec duty applies.
Duties riding the ruling: the fix lands in core `Domain` (NOT `Sync/` —
in-mandate; small and deliberate per the worktree rule); red-on-old —
the batch-2 recorded-finding test FLIPS into the pin, plus a
paste-nested-list pin; any existing Phase 2 pin that literally asserts
the old trim on LIST-shaped input is SUPERSEDED by this adjudication and
updated citing it (enumerated in the batch record — the one sanctioned
test-edit class); every trim site at a segmentation door gets the ONE
rule (bulk + crystallization, sites enumerated). **The Mac inherits the
fix** (pasted/tail-typed nested lists stop flattening there too) —
reported to the author the same turn as this record.

---

## Stage 1, batch 3 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the run record M1–M14
+ LK1–LK11, the constitution, the environment traps, the Stage 0 gate
record, batch 1 + 2 briefs/records/acceptances INCLUDING the trim-law
adjudication directly above — it binds your item 1) ·
`notes/plans/mobile-tk2-spike-memo.md` ·
`App/Variorum/Variorum/Theme/VoiceTokens.swift` (the token layer — both
voices + `ReadingPageTokens`) · `Spikes/MobileMockups/mobile-look-v1.html`
and `-v2.html` (the RATIFIED look canon; the LK rulings say what is
settled).

**Objective:** (a) the trim-law fix per the adjudication; (b) the look
canon lands on the Write surface — the phone stops being unstyled.

**Scope, batch 3:**
1. **The trim-law fix** (core `Domain`) EXACTLY per the adjudication
   above — the rule, the pins, the superseded-pin handling, all four
   suites green by your own runs (this batch touches core, so core +
   Mac + spine are mandatory; the Mac-side behavior delta is EXPECTED
   and enumerated in your record).
2. **`VoiceTokens` availability to the phone** — the token layer is
   SwiftUI (`Color`/`Font`, cross-platform); make it compile into the
   mobile target via the established parity pattern (Mac-only chrome
   consumers stay Mac-side; verify the fonts on iOS — Iowan Old Style
   ships there; the mono face via the system monospaced design).
3. **The phone-local voice switch (LK2):** a stored mobile preference —
   both voices, deliberately NOT synced and NOT the Mac's setting; a
   minimal switch door for now (the real Settings home is S3's —
   PROVISIONAL placement, record it).
4. **The Write surface styled to canon:** voice room/surface/ink +
   title masthead; the markdown palette per voice (per-voice code-chip
   tint, dimmed markers — the Mac's face); the paragraph gap per canon;
   the keyboard bar restyled per voice (terminal's lowercase idioms).
   Boundaries stay invisible at rest; the dotted-seam toggle is UNRULED
   for mobile — record its absence as deliberate. Dark rides the token
   layer's dark values on the system scheme (R51 black rooms); record
   what ships.
5. **The walk grows:** switch the voice → the face changes while stored
   bytes stay byte-identical; the L9 pin and identity audit stay green
   under styling.

**Explicitly NOT batch 3:** takes/badges/swipe/⑂ (S2), ⋯/the edit-menu
door (S2), the app shape/tab bar/shelf (S3 — LK7's text-only tab bar
lands there), Read flow (S4).

**Discipline:** the batch 1/2 brief's, verbatim — tests with every
step; the environment traps bind; counts by your own runs (mobile +
walk always; core + Mac + spine mandatory this batch); NO
`Sources/VariorumCore/Sync/` lines; NO schema; red-on-old for every
bug-class fix; commit as you go with the standing trailer; push
`origin mobile` at bout end; **append your batch record to this file**;
ONE Sonnet lookup subagent at a time, external facts only. The ladder
runs at STAGE end — batch 3 is Stage 1's LAST planned batch, so flag
anything you believe the ladder must weigh.

## Stage 1, batch 3 — BATCH RECORD (implementer, 2026-08-03; commits `96a7f8b` · `a43aef4` · `57d7492` · `4678778` + the record commit)

**All five scope items shipped — plus ONE environment fix the batch's own
pins forced (the WRONG-CORE trap, below, the ladder's first flag).**

**1 — THE TRIM-LAW FIX (`a43aef4`, the dedicated core commit).** Exactly
per the adjudication: `SegmentationRules.trimmedPiece` is the ONE
per-piece edge-trim rule, consulted by BOTH paragraph-mode doors — a
piece that reads as a LIST LEAD keeps its leading horizontal whitespace
and still trims its trailing edge; every other piece trims exactly as
before. The predicate is the NEW `MarkdownSyntax.isListLead` (core
Domain, housed beside the tokenizer it mirrors — space/tab indent run +
`"- "`, checkboxes matching as the bullet shape — so the two laws cannot
drift; made `public` to match its law-siblings `leadingWhitespace`/
`indentUnit`). **The trim-site enumeration (the every-site duty):**
(i) `bulkSegments`' paragraph arm — GETS the rule; (ii)
`crystallizedBoundary` — GETS the rule; (iii) the sentence scanner's
`flush` — UNTOUCHED per the adjudication's own scope line, recorded by
`sentenceModeStillFlattensListShapedLines_recordedBoundary`; (iv)
non-sites considered and left: `isBlank` (a test, not a trim),
`MarkdownEditing.swift:308` (the ⏎ door's content-emptiness check —
not a segmentation door), `DisplayTitle`'s absence test. Grep evidence:
no other `trimmingCharacters` in Domain/Shared/mobile-app; the consumers
(`CrystallizationPlanner`, `Operations+Import`, Mac `ImportModel`) hold
NO local trims, so the fix propagates through the one law.
**New pins (core `SegmentationRulesTests`, +5):** bulk keeps space AND
tab leads (checkbox included) · the kept lead composes with the
2026-07-12 k−1 spacing rule (trailing edge still trims) · indented
NON-list lines (heading → working column-0 heading, prose, `-x`) still
trim — the LIST-ONLY boundary · crystallization keeps the tail-typed
nested item's depth · the sentence-mode flattening recorded. **Mobile:**
the batch-2 documentation test FLIPPED into
`tailCrystallizationKeepsAListLinesIndent_adjudicationPin` exactly as its
own comment promised, plus `pastedNestedListKeepsItsIndent_adjudicationPin`
at the bulk door.

**THE WRONG-CORE ENVIRONMENT TRAP (`96a7f8b` — found BY the trim pins;
every future worktree session depends on knowing it):** the pbxproj's
local-package reference was `../../../variorum` — a path that ESCAPES the
repo (project dir + `../../..` = `~/dev`, + `/variorum` = the MAIN
checkout). In `~/dev/variorum` the two spellings coincide; in THIS
worktree every app-target build (Mac suite, mobile suite, both apps)
silently compiled `~/dev/variorum`'s `VariorumCore`. Discovered when the
trim fix was in the worktree's core and the simulator run still
flattened. Repointed to `../..` (the repo root): resolves IDENTICALLY in
the main checkout — a no-op at merge — and correctly in every worktree.
**Batches 1–2's recorded counts STAND:** `Sources/VariorumCore` was
diffed between the two checkouts at discovery and the ONLY differing
files were this batch's own two — the cores were byte-identical for the
whole prior window. Rider: re-resolution under the corrected path bumped
the workspace `Package.resolved`'s `swift-concurrency-extras` 1.4.0 →
1.4.1 (a patch inside the already-declared range — no new dependency;
every green run this bout used 1.4.1; the CLI's root `Package.resolved`
is untouched). *(Amended per round-1 MINOR 1: the same re-resolution
ALSO bumped `xctest-dynamic-overlay` 1.10.1 → 1.11.0 — likewise inside
its already-declared range, likewise no new dependency; the original
rider under-enumerated. Both are transitive updates of long-declared
point-free dependencies; the author-only new-dependency trigger does
not apply.)*

**Revert evidence (the trim fix):** deliberate behavioral revert — both
doors restored to the old full trim — ran the core suite: EXACTLY the
three keep-lead pins red with the flattened outputs
(`["- milk", "- eggs", "- [ ] flour"]` · `["- a\n", "- b"]` · blockText
`"- deep"`), the two boundary pins (indented-non-list, sentence-recorded)
still green — the pins discriminate; restored → 23/23. The MOBILE pins'
red-on-old is the ORGANIC run: the pre-path-fix simulator run compiled
the main checkout's core — byte-identical to this branch's pre-fix law —
and both adjudication pins failed with exactly the flattened outputs
(`"- deep\n  - "` / the flattened triple); after the path fix, green. (No
second deliberate mobile revert was run on top; stated so the ladder
weighs the evidence as it is.)

**Superseded-pin enumeration: the sanctioned class is EMPTY.** Sweep:
every test file touching the two doors was enumerated
(`SegmentationRulesTests` — both Phase-2 trim pins are PROSE-shaped, kept
byte-unchanged, each gaining a COMMENT-ONLY clarification citing the
adjudication (the only two test-file touches outside the mobile flip;
zero assertions changed); `ImportOperationTests` — whitespace-only
fixture; `BoundarySnappingTests` — none), plus a broad list-literal grep
across all three test trees (hits only in tokenizer/editing/rendering/
face/tutorial suites that never call the doors) and the seven Mac
crystallization-adjacent files (zero list-shaped input). The ONE test
asserting old-trim-on-list was the mobile recorded-finding test — flipped
under its own separate duty.

**Mac-delta enumeration (the EXPECTED inheritance; zero TEST deltas):**
(1) bulk paste at the Mac tail: nested list lines keep their indent
(previously flattened); (2) Mac type-time/idle/teardown crystallization:
a tail-typed indented list line keeps its depth — the batch-2 asymmetry
(continuation lead kept, minted line stripped) is gone; (3) markdown/text
IMPORT (`Operations.importBlocks`, the 11b drop-in): imported nested list
lines now store their indent; (4) sentence mode: unchanged everywhere;
(5) the Mac SUITE: 1191/208 with only the recorded tripwire — NO Mac pin
asserted the old trim on list-shaped input, so no test moved.

**2 — VoiceTokens TO THE PHONE (`57d7492`):** `VoiceTokens.swift`
(tokens + idioms + `ReadingPageTokens` + `Color(hex:)`) git-mv'd VERBATIM
to `Shared/Theme/` — both targets compile the ONE canon via the
synchronized-folder pattern (zero pbxproj edits, zero test edits, no
forwards needed — the file's names are unchanged and the Mac's consumers
are untouched; Mac build verified green after the move). **FINDING,
measured:** Iowan Old Style on iOS 26.2 is a **HIDDEN system font** —
absent from `UIFont.familyNames`, resolvable by PostScript name
(`IowanOldStyle-Roman`), and the resolved font reports the real family.
Pinned precisely (`MobileVoiceTests`); the serif-design fallback stays
the never-reached net, and the pin is the tripwire if a future iOS pulls
hidden-font resolution (LK1's re-verify-per-runtime discipline). The
mono face rides the system monospaced design, pinned.

**3 — LK2's SWITCH (`4678778`):** `MobileVoicePreference` — a
phone-local `UserDefaults` store (the Mac ⌘⇧I sticky-fold precedent),
deliberately NOT the synced `'theme_voice'` row; default terminal (the
leading voice, R1). The door: a masthead text button in the chrome
register (current voice's name; tap flips voice + preference + the open
surface). The test harness pins every world to the terminal voice so
LK2's store can never leak simulator state into byte/attribute
expectations.

**4 — THE WRITE SURFACE STYLED TO CANON (`4678778`):**
`MobileEditorStyle` now resolves EVERY surface-write value from the
shared `VoiceTokens` per the live voice — cached per-voice `Face`s
(object-stable colors, the attribute-equality bar), DYNAMIC UIColors so
dark rides the system scheme with the token layer's own dark values
(**R51's fully black rooms pinned at the UIKit derivation, both
voices**), the markdown palette per voice exactly as the Mac's
`Palette(tokens:)` maps it (marker = muted, link = accent, the 13k K10
per-voice code chip), typography at the token layer's own numbers
(terminal mono 14 / study Iowan 16, `UIFontMetrics(.body)`-scaled for
Dynamic Type — identity at default size, so tests stay deterministic),
and the paragraph gap moved to the Mac's OWN 0.5×pointSize rule
(`EditorTypography`'s constant; batch 1's 0.35 stood in). The view:
`applyVoiceChrome` (room background, accent caret/selection tint, voice
typing attributes, the bar rebuilt + `reloadInputViews`). The bar:
voice surface + hairline top, muted act glyphs, mono chrome in terminal /
sans in study (the mockups' own chrome rule — study chrome is sans even
though study prose is serif). The masthead: the note's name via the
shared `DisplayTitle` chain (the 13k K1 rule rides free) in the voice's
title type on the voice room; status rows restyled into the chrome
register (canary keeps red — a diagnostic, not chrome). **The switch on
an OPEN note:** `applyVoiceChange` — ATTRIBUTES ONLY, never a character:
face bookkeeping dropped wholesale, the new base laid over the full range
with ADDs (the block-ID projection untouched), the markdown face
re-derived fresh with the new palette. O(open note), the same cost class
as opening the note, spent at a deliberate settings flip — never a
keystroke (recorded; the Mac's theme adoption is the precedent).

**5 — THE WALK GROWS (`4678778`):** walk 4 — paste a voiced document
(heading · nested checkbox list riding the trim fix · inline code) →
switch to study → **surface bytes byte-identical, stored bytes untouched
after a flush, fonts/palette provably follow (Iowan prose, study marker +
chip objects), typing attributes follow** → switch back → byte-identical
again, terminal face restored; identity audit clean, canary silent, no
refusal spoke. The L9 pin and identity audit ran green in every suite run
of the bout (display == stored held throughout the styling work).

**Counts, all by this implementer's own runs:**
- **Core: 1039/114 GREEN** (1034 + the 5 trim pins), `swift test`.
- **Mobile: 76/16 GREEN** (68 → 69 at the trim commit → 76 with
  `MobileVoiceTests` (6) + walk 4; single runs, zero relaunches).
- **Mac: 1191/208 with EXACTLY the one recorded environment-gated
  tripwire red, BY IDENTITY**
  (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`)
  — the 13k baseline reproduced; zero deltas from the trim fix.
- **Spine: 51/7 GREEN** (the seven suite type names).

**Interpretations for the cold reviewer:** (1) "whose trimmed form is a
LIST LEAD" is implemented as the TOKENIZER'S OWN test (indent run +
`"- "`), not literal trim-then-retest — identical for space/tab leads;
for exotic whitespace (NBSP) the tokenizer mirror is the conservative
reading (such a line would not RENDER as a list, so sparing its lead buys
nothing) — the adjudication's "column-0 widening mirrored precisely"
clause ruled between the readings. (2) "every other line trims exactly as
before" read as: only the LEADING whitespace of a list lead is spared —
its trailing edge trims as always. (3) The pbxproj fix is in-mandate as
an environment-correctness fix without which the batch's pins could not
test the batch's code; it is a no-op on main by construction. (4) The
walk-4 paste drives the storage door (`typeEdit`, the house harness
pattern) — the UIPasteboard path itself is batch 1's `isPasting` pin's.
(5) `applyVoiceChange` deliberately re-derives the WHOLE face rather
than patching colors: the face bookkeeping remembers restore colors of
the OLD voice, so a partial patch is the stale-restore bug class.

**PROVISIONALs (P10–P14, for the stage-gate bundle):**
- **P10:** typography sizes — the token layer's own numbers (mono 14 /
  Iowan 16), metrics-scaled; the mockups' phone frames hint slightly
  larger; her on-device feel round rules.
- **P11:** the switch door's form and placement (a masthead text button;
  the real Settings home is S3's) and the terminal default.
- **P12:** the accent caret/selection tint (`tintColor` = the voice
  accent) — a canon application, not a literal ruling.
- **P13:** the bar's chrome mapping — mono 14 terminal / sans 14 study,
  glyph ink = muted (the mockup kbar's register).
- **P14:** the masthead status rows keep functional coloring (canary
  red) in the voice's small type — P4's placeholder carried, restyled
  minimally.

**Deliberate absences (scope, not holes):** the dotted-seam toggle
(UNRULED for mobile — recorded per the brief); a phone-local dark
override (dark rides the SYSTEM scheme with token dark values — what
ships, recorded); ⑂/⋯ on the bar (S2, with their surfaces); the
edit-menu door (S2); visual/screenshot verification of the styled
surface (machine-verified attributes only — flagged below).

**LADDER-ATTENTION FLAGS (batch 3 closes Stage 1's planned scope):**
1. **The wrong-core trap** — the ladder should re-confirm the
   batches-1–2-counts-stand reasoning (the byte-identical diff at
   discovery) and note that MAIN receives the pbxproj fix at merge (a
   no-op there). The class it kills: a parallel main-side core change
   silently entering this worktree's app builds.
2. **The tripwire** red reproduced by identity this run — covariate
   UNKNOWN stands (13k's refutation); its owner is the 13e kickoff
   sweep, not this project.
3. **No visual inspection** of the styled Write surface this batch —
   the 13b "machine-verified, never visually inspected" class; her
   device feel round is the stage gate's instrument.
4. **SourceKit warning, PRE-EXISTING:** `SegmentationRules.swift`
   `sentences(in:)` `var characters` (never mutated; Phase 2 code,
   `9fe1d7b`) — inside the sentence scanner the adjudication scoped
   OUT; left untouched deliberately; a one-word fix if the ladder
   wants it.
5. **Two comment-only edits** on Phase-2 prose trim pins (enumerated
   above) — zero assertions changed; verify and wave through.
6. **S2 forward-duty:** the badge/peek/browser batches must style from
   `MobileEditorStyle.face` / `VoiceTokens`, never literals (P-8) —
   the face layer now exists for them.
7. **The organic-vs-deliberate mobile revert evidence** (above) — the
   ladder should judge whether the organic pre-fix-core run satisfies
   red-on-old for the two mobile pins, or ask for a repeat.

**NO `Sources/VariorumCore/Sync/` lines anywhere in the bout; NO schema;
the Mac-side diff is the trim law (expected, enumerated) + the moved
token file + the pbxproj path fix.** Commits: `96a7f8b` (environment) ·
`a43aef4` (trim law + pins) · `57d7492` (token move) · `4678778` (the
look canon) · the record commit; pushed to `origin mobile` at bout end.

## Stage 1, batch 3 — ACCEPTED; STAGE 1 BUILD COMPLETE — the ladder OPENS (architect, 2026-08-03)

**Acceptance:** verified — diff scope inspected (core touch = exactly the
two adjudicated `Domain` files + their tests, a dedicated commit; zero
`Sync/`, zero schema; the pbxproj change is the wrong-core path fix, the
`Package.resolved` rider recorded), push state confirmed
(`origin/mobile` at `3e4d27e`, tree clean), the batch record read, and
**mobile 76/16 re-confirmed by the architect's own run**. The wrong-core
environment trap joins the machinery lessons (the handoff carries it);
P10–P14 join the stage-gate bundle (now P1–P14 + LK5's ✓-finished note).
The implementer's seven ladder-attention flags stand recorded in its
batch record for the reviewer's anchor.

**THE STAGE 1 REVIEW LADDER — round 1 (fresh cold reviewer, spawned at
this record):** review target = the stage's combined diff,
**`00d2c42..3e4d27e`** (batches 1–3 + the architect's brief/acceptance
records; Stage 0's spike was ruled at its own gate and is context, not
target). The reviewer runs `notes/REVIEW_PROMPT.md` VERBATIM with zero
framing from the architect; its anchors are this file's batch records +
dispositions (recorded for exactly this purpose). Findings land
repo-first in this file before any fix session sees them; fixes with
traced mechanisms + revert-verified red-on-old pins; round 2 re-reviews
fresh; a new BLOCKER/MAJOR forces round 3; hard cap three rounds.

## Stage 1 review — round 1 findings (cold reviewer, 2026-08-03)

**Scope of this review, done in-session:** `notes/REVIEW_PROMPT.md` run
verbatim; the FULL combined diff `00d2c42..3e4d27e` read file-by-file
(every new source/test file in full; every modified Mac/core file as a
diff; the moved files confirmed rename-only); this file's batch records
+ dispositions as anchor; **all three load-bearing suite counts
re-verified by the reviewer's OWN runs** — core `swift test`
**1039/114 GREEN**; mobile (iPhone 17 Pro / iOS 26.2) **76/16 GREEN**;
Mac **1191/208 with EXACTLY one red, BY IDENTITY the recorded tripwire**
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`;
the spine's seven tutorial suites green within the run). No fixes made —
read-only per the prompt; adjudication and fixes are the ladder's next
step. No "Review foci" section exists for this project; the batch-3
record's seven ladder-attention flags served that role and each is
dispositioned below.

### Findings

**BLOCKER — none found.** (Stated per the hallucination guard: nothing
at this severity survived a traced-mechanism test.)

**MAJOR — none found.**

- **[MINOR] · notes/plans/mobile-app-plan.md, batch-3 record ("Rider:
  …") + `App/…/xcshareddata/swiftpm/Package.resolved` · the recorded
  Package.resolved rider under-enumerates the re-resolution** · Evidence:
  the diff bumps TWO pins — `swift-concurrency-extras` 1.4.0 → 1.4.1
  (recorded) **and `xctest-dynamic-overlay` 1.10.1 → 1.11.0 (a
  minor-version bump, larger than the recorded one — unrecorded)**. Both
  are within already-declared ranges (no new dependency; no author-only
  trigger), and every green run this bout used the new resolution — but
  the record's enumeration is what the acceptance verified against, and
  half the delta is missing from it. Proposed fix: amend the batch-3
  record (and the handoff's echo) to name both bumps — doc-only, the
  record-accuracy class, no pin applicable.

- **[MINOR] · App/Variorum/VariorumMobile/Features/Write/MobileEditorStyle.swift:48
  (`storedVoice`) + MobileWalkTests.walk4 / MobileVoiceTests.surfaceWriteValuesFollowTheLiveVoice ·
  cross-test shared mutable voice can flake attribute assertions under
  Swift Testing parallelism** · Mechanism, traced: `MobileEditorStyle.voice`
  is process-global; the two voice-flipping tests set `.study` and
  restore only at test end (defer), with REAL suspension points inside
  the flipped window (`await flushNow`, `try await storedBlockTexts`).
  All editor tests are `@MainActor` — serialized, but INTERLEAVED at
  awaits — so a concurrently running test that materialized its surface
  under terminal can resume into its attribute assertions while the
  global reads study (e.g. a render test's `marker ==
  …markdownPalette.marker` comparing across the flip). NOT an observed
  failure (the reviewer's own run was green; every recorded run was) —
  a flake-hazard class, honestly labeled: byte expectations are immune
  (display == stored is voice-independent), only attribute expectations
  race. Proposed fix: `.serialized` on the two voice-flipping suites, or
  arrange the flipped window to contain no suspension points — test-infra
  class; a red-on-old pin would mean constructing the race and is not
  applicable.

- **[NIT] · Sources/VariorumCore/Domain/SegmentationRules.swift:152
  (`trimmedPiece`) · degenerate corner between the adjudication's two
  arms** · An indented EMPTY list item (`"  - "`) reads `isListLead ==
  true` on the raw line, then the (ruled) trailing trim eats the lead's
  own trailing space — storing `"  -"`: leading indent kept on a piece
  that no longer reads as a list, and whose TRIMMED form (`"  -"`) is
  not a list lead either, so it sits between "keeps a list-lead's
  indent" and "every other piece trims exactly as before". Inherent to
  composing the ruling's own trailing-trim clause with the
  tokenizer-mirror reading; input is degenerate (a pasted empty nested
  item), no rendering or behavior class breaks, and the old law's
  outcome (`"-"`) was equally degenerate. Record-the-corner (a comment
  line) or dismiss; not worth a rule change.

- **[NIT] · Sources/VariorumCore/Domain/SegmentationRules.swift:182
  (`sentences(in:)`, `var characters`) · flag-4 concurred** ·
  never-mutated `var` (pre-existing Phase 2 code, correctly outside the
  adjudication's scope); one-word `let` fix whenever a batch is already
  in the file.

- **[NIT] · App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift
  (974 lines) · P-9 watch, advisory** · The VM is cohesive TODAY — it is
  wiring over shared brains (projection policy, ledger, planner,
  reconciler all live in Shared/EditorBrain and are composed, not
  reimplemented) — but it already carries projection discipline, edit
  routing, crystallization, voice switching, and the identity audit, and
  it is one batch from the `TakesViewModel`-at-890-lines line P-9 names.
  S2's takes/swipe/peek machinery must land as sibling objects consulting
  this VM, never as growth inside it. Advisory, not a defect; no
  degradation exists yet to trace.

### The seven ladder-attention flags, dispositioned

1. **Wrong-core trap:** the fix is verified correct-by-construction —
   `relativePath` resolves from the `.xcodeproj`'s directory
   (`App/Variorum`), so `../..` names the repo root in EVERY checkout
   (worktree and main alike; a no-op at merge), where
   `../../../variorum` named `~/dev/variorum` absolutely. Today's state
   is coherent under the reviewer's own three suite runs (all on the
   corrected path, all matching the records). The batches-1–2
   counts-stand reasoning rests on the recorded byte-identical core diff
   AT DISCOVERY — historical, not re-verifiable now; accepted as
   recorded evidence, consistent with everything re-runnable.
2. **The tripwire:** reproduced BY IDENTITY in the reviewer's own Mac
   run — exactly one red, the named test. Covariate-UNKNOWN stands;
   the owner remains the 13e kickoff sweep, not this project. Correct.
3. **No visual inspection of the styled surface:** stands as recorded
   scope — machine-verified attributes only; her device feel round is
   the gate's instrument. Nothing for a code review to add.
4. **SourceKit `var characters` warning:** concurred as NIT above.
5. **The two comment-only Phase-2 pin edits:** verified against the
   diff — comment lines only, zero assertions changed. Waved through.
6. **S2 forward-duty (style from `MobileEditorStyle.face`/tokens, never
   literals):** noted; rides with the P-9 advisory above.
7. **Organic-vs-deliberate mobile revert evidence: RULED ADEQUATE.**
   The organic pre-path-fix simulator run IS the two mobile pins
   failing on byte-identical pre-fix law (main's core == this branch's
   pre-fix trim), with the exact flattened outputs recorded — that is
   red-on-old, achieved organically — and the core-side deliberate
   revert independently discriminates the same law (exactly the three
   keep-lead pins red, the two boundary pins green). A repeated mobile
   revert would prove nothing the core revert does not already prove.

### Clean bill (load-bearing things specifically checked, found solid)

- **Counts:** all three suites re-run by the reviewer (above) — every
  recorded figure reproduced exactly, tripwire by identity.
- **The trim law:** ONE rule (`trimmedPiece`) at BOTH paragraph-mode
  doors; the reviewer's own caller sweep confirms the site enumeration
  (Operations+Import ×2 and CrystallizationPlanner ×3 all route through
  `bulkSegments`/`crystallizedBoundary`; the only other Domain trims are
  the sentence-scanner flush, `DisplayTitle`'s absence test, and the ⏎
  door's content-emptiness check — all correctly out of scope).
  `isListLead` is an EXACT tokenizer mirror (`leadingWhitespace` is
  space/tab-only, so NBSP-indented lines conservatively trim, matching
  the recorded interpretation; the `"- "` requirement matches
  `leadingSpan` including the checkbox-as-bullet-shape free ride); the
  manual trailing trim mirrors `.whitespaces` exactly. The five core
  pins + two mobile adjudication pins are real and discriminating.
- **Parity moves:** four EditorBrain files + VoiceTokens moved with ZERO
  content changes (rename-only in the diff); the Mac keeps every
  pre-move name as a forward with byte-identical algorithm —
  `MarkdownFaceCore` is line-for-line the Mac's styling algorithm
  parameterized over base font + palette (checked against the removed
  Mac code hunk-by-hunk); zero test edits outside the two sanctioned
  classes; EditorBrain's no-UI-framework charter holds (Foundation +
  VariorumCore only; the UIKit/AppKit typealiases live in
  MarkdownFace's own Shared subfolder, as recorded).
- **Identity-as-projection:** `restampProjection` takes its extent from
  the index authority (the widen pin's mechanism traced and verified);
  the DEBUG audit walks the full tiling per edit; gateless system edits
  route via `fallbackVerdict` against the pre-edit index (pinned with a
  genuine gate-bypassing storage replacement); display == stored held
  through render, restyle, programmatic replace, and the voice switch
  (attribute-only writes; the `.editedCharacters` guard keeps them
  inert).
- **The gate:** ONE VM-owned delegate every host shares; sealed /
  locked-take / cross-block / desync refusals all speak (pinned);
  acts, ⏎, Tab/⇧Tab, and the checkbox tap all ride the ordinary
  policed input path (pre-gate idempotent with the keyboard's own
  consult; consumed keystrokes leave no stray newline; a mid-plan
  refusal skips without corrupting the rest).
- **P1 discipline:** line-scoped restyle pinned by `MarkdownScanCount`
  (< 100 scanned on a 6k-char-neighbor keystroke); block-scoped
  autosave cost with gate-exact figures (the widened-report wrinkle
  handled, system paths honestly approximate per SyncSpec §6); the
  O(entries) integer re-stamp walk is honestly recorded with its
  bisect upgrade path.
- **The canary:** TK2-explicit construction through the true designated
  init (the ObjC-factory SIGSEGV trap documented in-file); the
  checkpoint poll carries a REAL positive control — a deliberate
  `.layoutManager` downgrade, detected in-suite.
- **The L9 family:** both directions covered (accrual refused with
  `flushCount == 0` on editless cycles; typed/pasted meaningful spacing
  round-trips byte-exactly; a neighbor's edit never touches stored
  spacing) — the recorded revert discrimination is consistent with the
  pin structure.
- **Rulings honored where built:** LK2 phone-local UNSYNCED voice
  (UserDefaults, terminal default, the ⌘⇧I precedent); LK8-minus-⑂/⋯ as
  P-2's application (the bar's act table pinned); R51 fully black dark
  rooms pinned AT the UIKit derivation with a light-side negative
  control; K1's DisplayTitle chain on the masthead; K5/K8/K10 and
  `actKeepsIndent` byte-parity pinned against the shared law; M1's
  Write-true shape with the constitution's phone reading of P-3 (the
  full-document editor kind, one live surface, no second liveness
  mechanism).
- **Boundaries:** NO schema; NO `Sources/VariorumCore/Sync/` lines; no
  new dependencies (the resolution bumps are within declared ranges);
  `renderedText`/export bodies/the bridge's join brain untouched by the
  diff; the pbxproj change is exactly the wrong-core path fix; the
  Phase 8 capture views untouched; the spike outside the target as
  ruled.

## Stage 1 review — round 1 DISPOSITIONS + the fix pass (architect at adjudication, 2026-08-03)

Zero BLOCKER/MAJOR — the small fixes applied by the architect at
adjudication (the skill's sanctioned class); every finding dispositioned:

- **MINOR 1 — AGREED; doc fix applied.** The batch-3 `Package.resolved`
  rider under-enumerated: `xctest-dynamic-overlay` 1.10.1 → 1.11.0 rode
  the same re-resolution. The rider is amended in place, visibly marked;
  both bumps are in-range transitive updates of long-declared
  dependencies — the author-only new-dependency trigger does not apply.
  No pin (doc class).
- **MINOR 2 — AGREED AS NARROWED; fixed.** Both suites are `@MainActor`,
  so the synchronous `surfaceWriteValuesFollowTheLiveVoice` was already
  atomic (its flip window holds no suspension point — the mechanism
  cannot occur there); the finding narrows to walk 4, whose `.study`
  window held exactly ONE await (the mid-window flush). Fix: the flush +
  stored-bytes check moved AFTER the round-trip restore — the flip
  window is now await-free and MainActor-atomic; discrimination
  preserved (a byte change under study still fails the synchronous
  check at the flip; store damage from either switch still lands at the
  moved flush-check against the pre-switch bytes). No red-on-old pin —
  a test-hygiene fix of an unobserved interleaving hazard; a
  deterministic pin would require constructing the race itself
  (justification per the architectural-finding rule).
- **NIT 1 — RECORDED, no code change.** The `"  - "` degenerate: kept
  lead + the ruled trailing trim compose to `"  -"`, which reads as
  plain text. Reachable only at a segmentation door (the editor's
  ⏎-on-empty-item outdents instead); the stored bytes are the lawful
  composition of the two arms; harmless. A one-line special case exists
  if real use ever surfaces it.
- **NIT 2 — FIXED.** `var characters` → `let` (`sentences(in:)`; the
  compiler's own never-mutated proof; zero behavior).
- **NIT 3 — ACCEPTED as binding advisory.** The S2 brief will require
  the takes/swipe machinery to land as sibling types beside
  `MobileEditorViewModel`, never as VM growth (the P-9 watch; the
  `TakesViewModel` counterexample stands).

Verification of the fix pass, by the architect's own runs:
SegmentationRules **23/1 GREEN** (the `let` fix's suite) · mobile
**76/16 GREEN** (walk 4's reordered flush included). **Round 2 spawns on
the fixes and what they touched.**

## Stage 1 review — round 2 (fresh cold reviewer, 2026-08-03)

**Scope, done in-session per the ladder's round-2 rule (a real pass over
the fixes and what they touched, never a rubber stamp):** the fix commit
`1e3c441..5608810` read in full; the three touched files read WHOLE
(`MobileWalkTests.swift`, `SegmentationRules.swift`, this file's round-1
findings + dispositions sections); every round-1 disposition re-traced
by this reviewer's own mechanism walk — including the two ruled without
code change; counts re-verified by this reviewer's OWN runs — core
`swift test` **1039/114 GREEN**, mobile (iPhone 17 Pro / iOS 26.2)
**76/16 GREEN**. The Mac suite was NOT run, deliberately: the fix's only
shared-code line is the `var`→`let` (compiler-proven behavior-neutral —
the binding is read-only through the scanner — and the full core suite,
every SegmentationRules pin included, is green over it); no trace
implicates shared behavior beyond what the core run covers.

### Verdicts on the round-1 dispositions

- **MINOR 1 (the Package.resolved rider) — HOLDS.** The stage-1
  `Package.resolved` delta verified by this reviewer's own diff read:
  EXACTLY two pin bumps (`swift-concurrency-extras` 1.4.0 → 1.4.1 and
  `xctest-dynamic-overlay` 1.10.1 → 1.11.0) plus the originHash — the
  amended rider now enumerates both, byte-accurate, no new dependency
  identity anywhere in the delta. Round 1's proposed "(and the
  handoff's echo)" clause is VACUOUS, verified: no handoff or other doc
  echoes the rider (a grep over `notes/` hits only this file and the
  unrelated Phase 7 plan), so the plan-file amendment IS the complete
  fix, not a partial one.
- **MINOR 2 (the voice-flip interleave hazard) — HOLDS, both halves.**
  The narrowing's premise, verified: `surfaceWriteValuesFollowTheLiveVoice`
  is a synchronous (non-async) test in a `@MainActor` suite — a sync
  body on the main actor cannot suspend, so its flip window was already
  atomic and no change was the correct change. The fix, traced: walk
  4's `.study` window (set line 258 → restore line 276) now contains
  only synchronous work — `applyVoiceChange()` is a non-async func
  (compiler-enforced await-free, its defer chain included), and
  attribute reads/`#expect`s suspend nothing — so the window is
  MainActor-atomic. The roster premise checked suite-by-suite: **all 16
  mobile suites are `@MainActor`**, and the test target's only
  voice-write sites are walk 4, the sync voice test, and the harness's
  per-world terminal pin (`withEditorWorld`). Discrimination preserved,
  traced through `AutosaveCoordinator`: a character-mutating restyle
  fails the SYNCHRONOUS byte check at the flip in either version
  (before any flush could matter), and store-bound damage lands in
  `pending` via `record` so the MOVED flush still writes it and fails
  the stored-bytes check against the pre-switch snapshot. The no-pin
  justification is sound — the only deterministic red-on-old would be
  constructing the race itself, and the hazard was never observed.
- **NIT 1 (the `"  - "` degenerate) — HOLDS.** Re-traced independently:
  `isListLead("  - ")` is true (`leadingWhitespace` = two spaces,
  remainder `"- "`), so the kept-lead arm's trailing trim stores
  `"  -"` — which re-reads as plain text: the lawful composition of the
  two ruled arms, exactly as recorded. Reachable only through a
  segmentation door (the live editor's ⏎-on-an-empty-item is consumed
  by the K5 exit first — walk 3 pins it). Record-only is the right
  disposition.
- **NIT 2 (`var` → `let`) — HOLDS.** `characters` is read-only through
  the sentence scanner (indexed reads and `.count`); the genuinely
  mutated bindings (`results`, `current`, `index`, `lookahead`) remain
  `var`. Zero behavior; the core suite is green over it.
- **NIT 3 (the S2 sibling-types advisory) — HOLDS as recorded.** The
  binding advisory sits in the dispositions section for the S2 brief to
  carry; nothing further is verifiable until that brief exists.

### New findings

**NONE at any severity — no BLOCKER, no MAJOR, no MINOR, no NIT.**
(Stated per the hallucination guard: nothing with a concrete traceable
mechanism surfaced in the fix commit or the files it touched.) One
forward NOTE, deliberately not a finding: the MINOR-2 fix's atomicity
rests on the all-`@MainActor` roster — a future non-MainActor suite
reading voice-dependent attributes would reopen the hazard class;
`MobileEditorStyle`'s header already states the main-thread contract,
and the harness pins terminal per world, so the guard exists in the
code as it stands.

### Counts (this reviewer's own runs)

- Core `swift test`: **1039 tests / 114 suites — ALL GREEN.**
- Mobile (iPhone 17 Pro, iOS 26.2): **76 tests / 16 suites — ALL
  GREEN** (walk 4's reordered flush in the run).
- Mac: not run — justified above (no shared-behavior trace beyond the
  core-covered `let`).

**Round-2 verdict: every round-1 disposition HOLDS; ZERO new findings;
nothing forces round 3 from this pass.** Adjudication is the
architect's.

## STAGE 1 — CLOSED (the architect's closeout, 2026-08-03; the ladder closed at round 2)

**What shipped (batches 1–3, every batch accepted after verify-don't-trust):**
the continuous Write-true editor core — the shared identity brain in
`Shared/EditorBrain/` (parity, zero test edits), the TK2-explicit view +
checkpoint canary, identity-as-projection re-stamped per edit with the
DEBUG audit, block-scoped autosave/churn, the crystallization family, the
full markdown vocabulary through ONE brain (render display==stored,
⏎/Tab/⇧Tab behaviors, checkbox tap, the six-act bar), the trim-law fix
per the adjudication (the Mac inherits; superseded-pin sweep empty), the
look canon applied (both voices, the LK2 phone-local switch, R51 black
pinned), the L9 trailing-newlines pin, and `MobileWalkTests` (4 walks)
riding every run. **The ladder: round 1 = 0 BLOCKER / 0 MAJOR / 2 MINOR
/ 3 NIT, all dispositioned + fixed at adjudication; round 2 (fresh
reviewer) = all five dispositions HOLD, ZERO new findings, counts
re-verified by its own runs. Closed at round 2 per the ladder's rule.**

**Final Stage 1 counts (verified by three independent sessions' own
runs):** core **1039/114** · mobile **76/16** · Mac **1191/208** (the one
recorded environment-gated tripwire, by identity) · spine **51/7**. NO
schema; NO `Sources/VariorumCore/Sync/` lines; the core diff = the two
adjudicated Domain files; no new dependencies (two in-range transitive
bumps, enumerated).

**THE STAGE GATE — the author's bundle (answer whenever; NOTHING gates
S2's build):**
1. **P1–P14** (the PROVISIONAL list across the three batch records:
   cross-block refusal wording · paragraph-gap size · the DEBUG Write
   door · placeholder status chrome · #-cycle H1→H2→H3→clear · ⇥
   long-press = outdent · the deferred undo story · hardware ⇧⏎
   continues lists · marked-text bails · typography sizes · switch-door
   form/default · accent caret tint · bar chrome mapping · masthead
   status coloring).
2. **LK5's rider:** ✓ finished stays visible as a STATE on book rows.
3. **The missing bar acts note:** strikethrough/code/link have no LK8
   buttons — vocabulary types by hand; acts wait for her word.
4. **THE FEEL ROUND (the gate's instrument — the styled surface has
   never been visually inspected):** the S1 Write surface lives behind a
   DEBUG door (P3 — the app shape is S3's), so the feel round is a
   TETHERED DEBUG RUN to her phone (Xcode → run to device; the A4 fence
   gives it the dev store — right for a feel round; her real-store
   Release install stays on the Phase 8 surface until S3). What to
   judge: typing feel, the markdown behaviors under the real keyboard,
   live autocorrect/dictation (the memo's obligation-6 device items),
   both voices, dark, the paragraph gap, typography sizes (P10).

**Stage 2 OPENS (takes) — its batch 1 brief below;** the NIT-3 advisory
BINDS it (sibling types beside the VM, never VM growth).

---

## Stage 2, batch 1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the run record M1–M14
+ LK1–LK11, the constitution + application notes, the environment traps,
the Stage 0 gate record, EVERY S1 batch brief/record/acceptance, the
ladder rounds 1–2 + dispositions, the Stage 1 closeout above) ·
`notes/plans/mobile-tk2-spike-memo.md` (items 4/5 are this batch's
ground: the fragment-rect pan + peek overlay, the edit-menu extension
with its iOS-27 seam note) · the Mac's takes vocabulary in code — the
v2 card grammar and choose/branch/blank/archive/delete door shapes
(`App/Variorum/Variorum/Features/Takes/`, read to mirror semantics,
never port AppKit).

**Objective:** takes arrive on the phone (M4/M5/M6/M9 + LK3/LK6/LK10) —
the badge, the swipe-peek, and ✓. (The full browser with the four verbs
is batch 2; this batch is the in-page experience.)

**Scope, batch 1:**
1. **The fan badge (LK3):** fanned blocks wear **⑂ alone** — count-free,
   an OVERLAY at the block's first fragment's trailing corner (P-8), with
   **LK10's reserved gutter**: an exclusion rect so the first line's text
   NEVER runs under the badge; non-fanned blocks carry nothing and
   reserve nothing.
2. **The swipe-peek (M5/M6/M9, LK6):** a delegate-gated horizontal
   `UIPanGestureRecognizer` scoped by the fanned block's fragment rects
   (the spike's proven shape — horizontal-dominance gate,
   never-simultaneous-with-scroll): swipe flips which take DISPLAYS in
   place as a **PEEK** — zero storage writes (display-swap through the
   render path; the identity audit stays clean); **sticky while the note
   is open** (M9), reverting on close; a visible per-block peeking
   marker keeps chosen-vs-peeked unambiguous; non-fanned blocks don't
   respond.
3. **The pill (LK6):** the under-block pill during flips — ‹ take k of
   n · label › with **✓** — fading after a beat, back on any flip; ✓ is
   the ONLY act that chooses (`chooseVariant` through the ops; refusals
   speak — sealed posts etc.).
4. **Editing a peeked block:** typing into a block whose display is
   peeked edits THE PEEKED TAKE's `working_text` (everything visible in
   an editing surface is editable — R8/R23's letter; route autosave to
   the displayed variant), never silently the chosen one. If this
   surfaces a genuine product ambiguity in the wild, PROVISIONAL it and
   record.
5. **Structure per NIT 3 (BINDING):** the take machinery lands as
   sibling types (e.g. a peek controller / fan projection provider)
   beside `MobileEditorViewModel` — composition, never VM growth; the
   VM gains only thin routing.
6. **The walk grows:** a fanned block → swipe flips the peek (bytes in
   store untouched) → the marker shows → ✓ chooses (the store's
   chosen_variant changes; the Mac would follow) → identity audit clean,
   canary silent.

**Explicitly NOT batch 1:** the takes browser + new/edit-any/archive
verbs (batch 2, with the bar's ⑂ and the edit-menu "Block Takes" door),
⋯/the block menu, the app shape (S3), Read flow (S4).

**Discipline:** the standing set, verbatim from the S1 briefs — tests
with every step; the environment traps bind; mobile + walks green at
bout end by your own runs (+ core/Mac/spine ONLY if anything shared
moves — none is expected this batch); NO `Sources/VariorumCore` lines
(fan queries exist — `Queries`/`chooseVariant` are standing vocabulary;
a genuine core need = stop and report); NO schema; red-on-old for
bug-class fixes; commit as you go with the standing trailer; push at
bout end; **append your batch record to this file**; ONE Sonnet lookup
at a time, external facts only. The S2 ladder runs at stage end.

## Stage 2, batch 1 — BATCH RECORD (implementer, 2026-08-03; commits `ba6b2d9` + the record commit)

**All six scope items shipped.** Per item:

1. **The fan badge (LK3/LK10)** — fanned blocks wear **⑂ alone**
   (`MobileTakesChromeController.badgeGlyph`, the Mac glyph, count-free)
   as an OVERLAY view at the block's first fragment's trailing corner
   (P-8), with **LK10's gutter as an exclusion rect** at that corner:
   the first line ends short of the badge, pinned by REAL WRAP GEOMETRY
   (an unbroken 200-char run: the fanned block's first line measured
   ≤ containerWidth − 30, the fanless twin's measured PAST that line —
   the discrimination that proves the exclusion did it, not the text).
   Non-fanned blocks carry nothing and reserve nothing (exclusion count
   pinned at exactly the fanned block's one). The badge TAP reveals the
   pill (counts appear once open — LK3's letter; PROVISIONAL P15: batch
   2 repoints the tap at the takes browser). Convergence note: the
   gutter's Y is the fragment's own minY and its height the first
   line's — both unchanged by the exclusion itself — and the write is
   equality-gated, so the layoutSubviews→refresh hook cannot loop.
2. **The swipe-peek (M5/M6/M9)** — `MobileTakesPanRouter`: the spike's
   PROVEN configuration verbatim (delegate-gated horizontal
   `UIPanGestureRecognizer`, 1.5× horizontal-dominance gate at
   shouldBegin, `shouldRecognizeSimultaneouslyWith` = false, 30 pt flip
   threshold, marked-text bail), scoped by fragment HIT-TEST → surface
   offset → the index authority (`blockID(atSurfaceOffset:)` — zero-
   length entries match at their location); non-fanned blocks never
   begin the gesture (pinned). **The peek itself is a PROJECTION
   OVERLAY, not a cover view** (the one structural interpretation for
   the reviewer, #1 below): `MobileTakesController.overlay(_:)` maps
   every ingested projection — a peeked slot's variantID/text/lock
   become the PEEKED take's before the policy/ledger/index see it — and
   `flip` applies a surgical single-slot display swap
   (`MobileEditorViewModel.displaySlot`). ZERO store writes pinned
   THREE ways: stored texts byte-unchanged, `chosen_variant_id`
   unmoved, **`sync_outbox` row count unchanged** across flips. Sticky
   while open (M9): peek state lives in the controller whose lifetime
   is the open note; pinned sticky across a flush + fresh delivery
   (which lands as an ECHO — `fullRenderCount` unchanged). The MARKER:
   the ratified v1 mockup's `.peeked` grammar — the `takeTint` wash
   behind the text (subview index 0, pinned) with a 2.5 pt `takeLine`
   edge bar — visible exactly while peeked; flipping ONTO the chosen
   take ENDS the peek (displaying truth is not a peek — M6's
   unambiguity rule made mechanical; the fulfilled-peek rule does the
   same when the STORE catches up, e.g. the Mac choosing the peeked
   take — pinned both ways).
3. **The pill (LK6, shape A)** — under the block on any flip: ‹ take
   k/n · label › with **✓ while peeked**; displaying chosen truth
   renders the "✓ chosen" STATE and no ✓ door (P-2 — pinned both
   states). Fades after a beat (2.4 s timer, alpha animation; back on
   any flip); ‹ › are tap-flip doors (the same act the swipe performs —
   PROVISIONAL P16). ✓ = `chooseDisplayed` → `Operations.chooseVariant`
   (I3's setter, the Mac's own door); on success the peek ends and the
   delivery confirms as an echo; **refusals speak** — the sealed post
   pinned verbatim ("This note is locked — unlock it on the Mac to
   choose a take."), the chosen pointer unmoved, and the PEEK SURVIVES
   the refusal (reading is free under seal).
4. **Editing a peeked block edits the PEEKED take** — free BY
   CONSTRUCTION from the overlay: the index entry's variantID IS the
   displayed take, so the standing gate/autosave route there with no
   second mechanism. Pinned: typing into the peeked block flushes to
   the peeked `working_text`, the chosen take's text AND the pointer
   untouched; a LOCKED peeked take refuses with the standing
   lockedVariant copy; a SEALED note refuses typing at the standing
   gate while the peek itself (display-only) still works. Text
   resolution is LEDGER-FIRST (`surfaceKnownText`): flipping away from
   a just-edited take and back shows the EDITED bytes pre-flush
   (pinned). No product ambiguity surfaced in the wild — nothing to
   PROVISIONAL on this item beyond the recorded remote-edit consequence
   (interpretation #4).
5. **NIT-3 honored (binding)** — the machinery is TWO SIBLING types
   plus pixels: `Features/Takes/MobileTakesController.swift` (state +
   overlay + flip + choose + pill content, ~230 lines) and
   `Features/Takes/MobileTakesChrome.swift` (chrome controller + pill
   view + pan router, ~430 lines). The VM gained ONLY routing: the
   `ingest` door (observation switched to the STANDING
   `AppDatabase.observeTakes` — slots + fans in ONE coherent read, the
   Mac Takes board's own observation, cost ∝ post), the dirty-safe
   `displaySlot`, and five one-liner helpers (slot lookup, ledger read,
   status voice, marked-text probe, block-at-offset). VM 974 → 1104
   lines, all of it routing/plumbing per the advisory's letter.
6. **The walk grew (walk 5)** — fanned block wears ⑂ + the one gutter →
   flip peeks (STORE BYTES checked: texts + chosen pointer unmoved) →
   the marker shows → typing edits the peeked take (store-byte checked
   on BOTH variants) → ✓ chooses (`chosen_variant_id` moves to the
   take; the Mac would follow) → marker ends → identity audit 0, desync
   0, canary silent, no refusal spoke → teardown lands exactly the
   walk's bytes.

**Counts, all by this implementer's own runs (iPhone 17 Pro / iOS
26.2):** **mobile 97 tests / 18 suites GREEN** (single run, zero
relaunches; S1's 76/16 intact within — the L9 pin and identity audit
ran green in every suite run of the bout). New: `MobileTakesTests` (12)
· `MobileTakesChromeTests` (7) · walk 5. **Core / Mac / spine
deliberately NOT run:** the bout's diff touches ONLY mobile-target
files (`git diff --stat` at commit: 2 new Takes sources + 3 Write-
feature files + 3 test files — zero `Sources/VariorumCore`, zero
`Shared/`, zero Mac-side, zero pbxproj), so the brief's only-if-shared
condition never fired.

**Discrimination evidence (no bug-class fixes this batch, so no
red-on-old pins were owed; the 13k hollow-pin currency applied to the
NEW pins instead — five deliberate mutations, each run against the
targeted suites, each caught, the tree byte-restored after (final
`git diff` EMPTY against the batch commit; final full suite 97/18
green):**
- **A — overlay routes edits to the CHOSEN take** (peekedSlot keeps
  `slot.variantID`): `typingIntoAPeekedBlockEditsThePeekedTake` red
  (a1 edited, a2 not) + walk 5 red at both store checks + 2 collateral.
- **B — the gutter dropped** (exclusion never appended):
  `textNeverRunsUnderTheBadge` red with measured evidence (first-line
  width 380.8 > reserved 364) + the exclusion-count pin red.
- **C — fan-cache-first text resolution** (ledger consult removed):
  `anEditedPeekSurvivesFlippingAwayAndBack` red exactly (the flip-back
  showed the stale photograph).
- **D — the marker never draws:** both chrome marker pins red + walk 5
  red at the marker line.
- **E — ✓ decorative** (the ops call removed; peek clears anyway):
  `chooseCommitsThePeekThroughOperations` red (pointer unmoved) +
  `chooseUnderASealedNote…` red (no refusal spoke AND the peek wrongly
  ended) + walk 5 red at the choose + teardown checks.

**Interpretations for the cold reviewer:**
1. **"Zero storage writes" read as zero STORE writes** (DB + outbox,
   pinned) — the `NSTextStorage` necessarily changes: scope item 4
   requires the peeked text to be EDITABLE, which an opaque cover view
   (the spike's throwaway proof shape) cannot host, and the brief's own
   words rule the render path ("display-swap through the render path;
   the identity audit stays clean"). The spike's `storageUntouched=YES`
   measured the display PRIMITIVE; the shipped peek is the projection
   overlay that primitive de-risked.
2. **The VM's observation moved `observePost` → `observeTakes`** (the
   standing Phase 11 A3 read): slots + fans arrive from ONE transaction,
   so the overlay can never see a fan/slot mismatch. Cost ∝ the post
   (the Mac board's own observation); the phone pays it per delivery.
3. **`displaySlot` is deliberately SURGICAL** — one entry rebuilt in
   place, `ledger.recordEdit` for the displayed variant only, never a
   whole-index rebuild from `slots` and never `ledger.adopt`: other
   blocks may be DIRTY mid-flip, and their slot texts are stale
   photographs — a wholesale rebuild would desync entry lengths from
   the surface and regress the ledger's dirty texts. (Deliveries can't
   hit this because the policy defers while busy; the flip runs any
   time.)
4. **Ledger-first resolution's recorded consequence:** a REMOTE edit of
   the very take being peeked stays invisible until the peek ends (the
   surface's own record self-perpetuates); true concurrent edits of one
   variant are S5's conflict-as-variant, exactly as on the Mac's live
   surface. Chosen-side remote edits DO land (originals refresh each
   delivery) and show the moment the peek ends.
5. **The two-take carousel is chosen→take→chosen** — flipping onto the
   chosen take ends the peek rather than "peeking the chosen" (M6's
   chosen-vs-peeked unambiguity; also why ✓ is never offered there,
   P-2).
6. **✓ does NOT flush the pending buffer first:** `chooseVariant`
   repoints and reads no text, so the R1-4 flush-first class (doors
   that COPY text at a dirty moment) does not apply; the pending edit
   flushes on its own clock to the same variant either way. Noted
   against the KnownIssues copy-doors row so the parallel is on record.
7. **Gesture-feel evidence split, per the spike memo:** the dominance
   gate/simultaneity config and flip threshold are the spike's
   real-touch-PROVEN values; this batch's tests pin the SCOPING BRAIN
   (hit-test → fanned) and the installed configuration (one pan, the
   router its delegate). Live-touch dominance, loupe/caret-drag
   coexistence, and the badge's finger-feel are the memo's obligation-6
   DEVICE items — they ride the S2 feel round, not the simulator suite.
8. **Peeking a SEALED note is allowed** (the flip is reading; the seal
   freezes authoring — the S5-outranks-the-seal doctrine's reading),
   while typing and ✓ under it refuse with the standing copy. Pinned.

**PROVISIONALs (P15–P19, for the stage-gate bundle):**
- **P15:** the badge tap's interim door = reveal the pill; batch 2
  repoints it at the takes browser (LK3's "the tap is the door").
- **P16:** the pill's ‹ › render as real tap-flip doors (the swipe's
  own act, no new semantics) — the mockup drew them as glyphs.
- **P17:** the peek marker's exact form — `takeTint` wash behind the
  text + 2.5 pt `takeLine` edge bar, BOTH voices (the ratified study
  mockup's edge bar was the SEAM color; shipped one-token takeLine —
  one line to change at a look round).
- **P18:** flip grammar — swipe LEFT = next take, wrapping carousel
  (the spike's convention); 30 pt threshold, 1.5× dominance.
- **P19:** visual constants — 30 pt gutter, chrome-12 badge/pill type,
  28 pt pill, 2.4 s fade; all look-track material (P-8 discipline held:
  every color/font resolves from `MobileEditorStyle.face`/tokens).

**Deliberate absences (scope, not holes):** the takes BROWSER + the
four verbs, the bar's ⑂, the edit-menu "Block Takes" door, and ⋯ (ALL
batch 2 by the brief — the M4 vocabulary lands there); the app shape
(S3); Read flow (S4); no capability-registry rows (the standing S1
posture — the pinned chrome tests are the interim); no pill/marker
VISUAL inspection beyond machine-verified attributes (the 13b class —
the S2 feel round is the instrument, where the marker's behind-canvas
z-order and the fade also get eyes); an EMPTY-rendering fanned block's
badge geometry is untested (rare corner; the browser is its real door);
RTL layout unconsidered (gutter assumes trailing = right); the caret
may clamp when flipping the very block being edited (programmatic-
replace posture, recorded); text undo clears on flip (the
differential's own removeAllActions posture).

**Environment note (echoes the S1 spine lesson):** a PER-TEST
`-only-testing:` selector (`…/MobileWalkTests/walk5_…`) silently
selects ZERO Swift Testing tests; SUITE-level selectors work. The
mutation-D run was repeated at suite level when the 7-test count
exposed it.

**NO `Sources/VariorumCore` lines; NO schema; NO `Sync/` lines; NO
Mac-side or `Shared/` touches** (the whole diff is mobile-target).
Commits: `ba6b2d9` (the takes surface + suites) · the record commit;
pushed to `origin mobile` at bout end.

## Stage 2, batch 1 — ACCEPTED (architect, 2026-08-03)

Verified — diff scope inspected (mobile-target only: the two sibling-type
files under `Features/Takes/`, thin VM/view/style touches, tests, the
record; zero `Sources/VariorumCore`, zero `Shared/`, zero Mac-side, zero
pbxproj — the only-if-shared verification condition correctly never
fired), the batch record read, and **mobile 97/18 re-confirmed by the
architect's own run**. The projection-overlay interpretation (the peek
rides the render path because scope item 4's editability demands it;
"zero storage writes" = zero STORE writes, pinned three ways including
the outbox row count) is ACCEPTED as the correct reading of the brief.
P15–P19 join the stage-gate bundle. The environment note joins the
machinery lessons (per-test `-only-testing:` selectors silently select
zero Swift Testing tests — suite-level only). Ledger L3: batch 1's half
DONE (badge · swipe-peek · ✓); the browser + four verbs are batch 2's.

---

## Stage 2, batch 2 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the run record M1–M14
+ LK1–LK11, the constitution + application notes, the environment traps,
the S1 records + ladder + closeout, the S2 batch 1 brief + RECORD +
acceptance — batch 1's sibling types and P15's interim badge-tap door
are your ground) · `notes/plans/mobile-tk2-spike-memo.md` item 5 (the
edit-menu mechanism + its iOS-27 one-seam note) · the Mac's takes
vocabulary in `App/Variorum/Variorum/Features/Takes/` (mirror the verb
SEMANTICS and refusal shapes; never port AppKit) ·
`Spikes/MobileMockups/mobile-look-v1.html` §3 (the RATIFIED
sheet-over-page browser shape, LK4).

**Objective:** the takes browser with all four ruled verbs (M4), and the
remaining doors — the bar's ⑂ and the edit-menu item.

**Scope, batch 2:**
1. **The browser (LK4 — the ratified sheet-over-page):** the expand door
   (badge tap repoints here — P15 retires; the pill stays the in-page
   flip's face) opens a sheet over the dimmed page; take cards in fan
   order (the v2 card grammar's phone cousin per the mockup: label row,
   ✓-ringed chosen, the PEEKING state visible); Done closes; the sheet
   follows the live voice.
2. **The four verbs (M4), each through the standing ops with refusals
   that speak:** ✓ CHOOSE on any card (`chooseVariant`); **NEW TAKE** —
   branch-this-one (copy) and blank, the two Mac gestures
   (`branchVariant` / `newBlankVariant`); **EDIT ANY TAKE** — a tapped
   card upgrades to the ONE live editor (P3 — exactly one live pane
   anywhere; the in-page editor stands down while a card is live; the
   peeked/chosen autosave routing from batch 1 is the proven pattern);
   **ARCHIVE / DELETE** under each card's ⋯ (`archiveVariant` /
   `deleteVariant` — I10 guards the last take and the chosen-slot
   RESTRICT class refuses through the ops' own errors; the refusal copy
   is the op's real message). Recovery surfaces (deleted/archived take
   resurrection) stay Mac-side in v1 — a DELIBERATE ABSENCE recorded
   for the stage gate, not a hole.
3. **The bar's ⑂ act JOINS** (LK8's seventh — opens the browser on the
   caret's block; P-2 is satisfied now that the door can act). ⋯ stays
   OUT (its block menu — callout/comment/name — is S4's; recorded).
4. **The edit-menu door (M2; spike item 5):** the custom "Takes…" item
   on the iOS text edit menu via
   `textView(_:editMenuForTextIn:suggestedActions:)`, isolated behind
   ONE seam (the iOS-27 deprecation note) — opens the browser on the
   caret's block. Never a second `UIEditMenuInteraction`.
5. **Structure per NIT 3 (BINDING):** the browser lands as sibling
   types (a browser controller beside batch 1's takes controller); the
   VM gains only routing.
6. **Walk 6:** badge → the browser opens → blank take minted → edited
   in the sheet → ✓ chosen → the OLD take archived → store rows
   byte-checked at each step → the I10 refusal on the last live take
   SPEAKS → Done → the page shows the new chosen text → identity audit
   clean, canary silent.

**Explicitly NOT batch 2:** ⋯/the block menu (S4-adjacent), divide/merge
doors (S4), the app shape (S3), Read flow (S4), reorder/move/copy-all
(L12 — after 13e).

**Discipline:** the standing set verbatim — tests with every step; the
environment traps bind (suite-level `-only-testing` only); mobile +
walks green at bout end by your own runs (+ core/Mac/spine only if
anything shared moves — none expected; a genuine core need = stop and
report); NO schema; NO `Sources/VariorumCore/Sync/` lines; red-on-old
for bug-class fixes; commit as you go with the standing trailer; push
at bout end; **append your batch record to this file**; ONE Sonnet
lookup at a time, external facts only. Batch 2 closes S2's planned
scope — flag anything the stage-end ladder must weigh.

## Stage 2, batch 2 — BATCH RECORD (implementer, 2026-08-03; commit `005dec2` + the record commit)

**All six scope items shipped.** Per item:

1. **The browser (LK4)** — `MobileTakesBrowserView`
   (`Features/Takes/MobileTakesBrowserView.swift`): the ratified mockup
   §3 shape LITERALLY — dim over the page (ink-based 0.25 scrim, P-8),
   the sheet from 120 pt down with 22 pt top corners, the shead
   ("takes · block k of n" · done), take cards in fan order (meta row:
   ✓-chosen state / peeking / take N · label · ✓ door · ⋯; body below;
   the peeked card wears the in-page marker's takeTint/takeLine
   grammar), the footer new-take row (+ new take · branch this one ⧉ ·
   blank ○). Terminal lowercases its chrome, study keeps case; every
   color/font resolves from `MobileEditorStyle.face` (the S1 flag-6
   duty). **The presentation MECHANISM is an interpretation (#1
   below):** an in-place OVERLAY over the page in the SAME screen — the
   mockup's own geometry (`.dim` + `.sheet` are divs over the page, its
   caption: "not a separate screen — the page stays visible behind
   it") — never a UIKit modal, which also makes the sheet drivable by
   the house harness. Done closes; a dim tap closes too (P25). The
   sheet follows the live voice (re-rendered at `applyVoiceChange`).
2. **The four verbs (M4)** — `MobileTakesBrowserController`
   (`Features/Takes/MobileTakesBrowser.swift`), every verb a STANDING
   op with its real refusal speaking: **✓ CHOOSE** on any card
   (`chooseVariant`; success ends any peek on the block — the explicit
   ✓ decides what the page shows, interpretation #4 — and the sealed
   refusal speaks the batch-1 choose copy, pinned); **NEW TAKE** — the
   two Mac gestures verbatim: branch-this-one (`branchVariant` from
   the DISPLAYED take — peek-aware, P21) and blank (`newBlankVariant`);
   minting NEVER chooses (R90, pinned) and the minted card goes LIVE
   for editing (the Mac's ring-follow, the phone's reading); **EDIT ANY
   TAKE** — a tapped card upgrades to THE one live editor: a single
   reused plain `UITextView` (`cardEditor`, interpretation #6) that
   MOVES between cards (pinned), gated at the door (sealed/locked
   refuse with the standing copies BEFORE typing) and belt-gated per
   keystroke; card edits route to the edited take's autosave through
   the VM's ONE ledger (`recordTakeEdit` — the batch-1 variant-routed
   pattern; the sheet and the in-page peek can never disagree on a
   take's bytes, pinned); **ARCHIVE / DELETE** under each card's ⋯
   (`archiveVariant`/`deleteVariant`) — I10 and the chosen-slot guard
   heard through the ops' OWN errors, in phone words for the everyday
   cases and the ops' words for the rest (P23). **Recovery surfaces
   (archived/deleted take listing + resurrection) stay Mac-side — the
   brief's DELIBERATE ABSENCE, recorded for the stage gate.** Verbs
   each settle through `refreshTakesFromStore` (flush → ONE fresh
   coherent read → ingest), so the browser is deterministic with or
   without the observation; a block deleted elsewhere force-closes the
   sheet (pinned).
3. **The bar's ⑂ (LK8's seventh)** — joins after ⇥ (`actLabels` now
   seven; ⋯ stays OUT until its block menu exists, S4 — P-2, recorded).
   Opens the browser on the CARET's block via boundary-tolerant
   resolution (`blockIDNearOffset` — a caret at a block's very end
   rests on the separator seat and still resolves ITS block, pinned);
   a fanless block opens too (the browser IS the fan-birth door — the
   9d "Show Takes" chicken-and-egg, the phone's edition, pinned); the
   open tail hears an honest refusal ("Tap into a block first — takes
   live on blocks.", P23). The six-act bar pin FLIPPED to seven with
   in-order label extraction (the sanctioned class — its own comment
   named this batch).
4. **The edit-menu door (M2; spike item 5)** — ONE seam file
   (`Features/Takes/MobileEditMenuSeam.swift`): the documented iOS 26
   delegate method (`textView(_:editMenuForTextIn:suggestedActions:)`)
   implemented as an extension of the ONE gate delegate, returning
   `UIMenu(children: suggested + [Takes…])` — NEVER a second
   `UIEditMenuInteraction`. The item is offered exactly where a block
   resolves (the tail/gap gets no item — P-2, pinned both ways); the
   target brain (`MobileEditMenu.takesTarget`) is test-visible. The
   iOS-27 note honored: mechanism + item + method all in the one file
   (the successor API is a one-file swap). No deprecation warning
   surfaced on the 26.2 SDK build (the memo's note was docs-level).
5. **NIT-3 honored (binding)** — TWO new sibling types beside batch
   1's: the browser controller (~330 lines, state + verbs + refusal
   copy) and the browser view (~460 lines, pixels). The VM gained ONLY
   routing (+71 lines): the `takesBrowser` composition, `ingest`'s
   one-line `projectionDidChange` forward, `blockIDNearOffset`,
   `openTakesBrowser(blockID:)`/`openTakesBrowserAtCaret()`,
   `refreshTakesFromStore`, `recordTakeEdit`, and `report` widened to
   `String?` (interpretation #9 — success clears the prior refusal,
   the Mac `run()`'s posture; every existing call site compiles
   unchanged). `MobileTakesController` gained two small doors the
   browser consults (`chosenVariantID` originals-aware truth;
   `endPeek`); the text view gained the browser-view retention + a
   weak `editorModel` back-reference (the bar's route).
6. **Walk 6** (`MobileWalkTests.walk6_takesBrowserFourVerbs`) — badge →
   the sheet opens over the page (page stands down) → blank minted
   (chosen untouched, the minted card live) → edited through the card
   editor's own input path → ✓ chosen (the pointer moves; the Mac
   would follow) → BOTH old takes archived → **store rows byte-checked
   at every step** (texts per variant, chosen pointer, statuses) →
   **the I10 refusal on the last live take SPEAKS** (the archive door;
   the delete attempt hears the ops' chosen-slot guard first —
   interpretation #5) → Done → the page shows the new chosen text →
   identity audit 0, desync 0, canary silent → teardown lands exactly
   the walk's bytes.

**Counts, all by this implementer's own runs (iPhone 17 Pro / iOS
26.2):** **mobile 123 tests / 20 suites GREEN** (single run, zero
relaunches; batch 1's 97/18 intact within — the L9 pin and identity
audit ran green in every suite run of the bout). New:
`MobileTakesBrowserTests` (18, the brain headless) ·
`MobileTakesBrowserSurfaceTests` (7, pixels + ⑂ + the edit menu) ·
walk 6; the two flipped pins re-shaped in place. **Core / Mac / spine
deliberately NOT run:** the bout's diff is mobile-target only
(`git diff --stat` at commit: 12 files, all under
`App/Variorum/VariorumMobile{,Tests}` — zero `Sources/VariorumCore`,
zero `Shared/`, zero Mac-side, zero pbxproj), so the brief's
only-if-shared condition never fired.

**Discrimination evidence (no bug-class fixes this batch, so no
red-on-old pins were owed; the 13k hollow-pin currency applied to the
NEW pins — five deliberate mutations, each run against targeted
suites, each caught, the tree byte-restored after (final `git diff`
EMPTY against the batch commit; final full suite 123/20 GREEN):**
- **A — browser ✓ decorative** (the op call removed; peek-end +
  refresh kept): `chooseMovesThePointerAndEndsAnyPeek` red ×3 (pointer
  unmoved, page unhealed, ring unmoved) + `chooseUnderASealedNote…`
  red (nothing left to refuse) + walk 6 red ×3.
- **B — card edits route to the CHOSEN take** (`cardTextDidChange`
  re-pointed at the chosen): `cardEditsRouteToTheEditedTakeOnly` red
  ×4 (a1 corrupted, a2 untouched, ledger/card stale) +
  `aTappedCardHostsTheOneLiveEditor…` red ×3 + walk 6 red ×3.
- **C — lifecycle refusals swallowed** (`report(nil)` in the catch):
  `deletingTheChosenTakeRefuses…` + `theLastActiveTakeRefuses…_I10`
  (×2) + `deletingALockedTakeRefuses…` + walk 6 (×2) all red.
- **D — the badge tap left at P15** (showPill restored):
  `theBadgeTapOpensTheBrowserNotThePill_P15Retired` (chrome) +
  `theBadgeTapOpensTheBrowser_P15Retired` (browser) + walk 6, all red.
- **E — the page never stands down** (`isEditable = false` dropped):
  `theSheetOpensOverTheDimmedPage…` + `aTappedCardHostsTheOneLive…` +
  walk 6, all red.

**One traced FINDING, mirrored rather than papered over
(interpretation #5):** `deleteVariant`'s guard ORDER — the chosen-slot
guard (`variantIsChosen`) runs BEFORE I10's `lastActiveVariant`
(`Operations+Deletion.swift`, `performDeleteVariant`), and a block's
last remaining take is usually ALSO the pointer's target — so
delete-on-a-last-chosen-take speaks the chosen-slot refusal, and I10
through the DELETE door is reachable exactly when the pointer targets
no live take (the chosen take archived → the slot renders the block
default). The pins hear BOTH orders (`theLastActiveTakeRefuses…_I10`
archives the chosen first, then hears I10 on both doors; the walk's
delete beat hears the chosen-slot guard); the archive door speaks I10
directly (no chosen guard exists there — archiving a chosen take is
the ops' own read-time-fallback semantics, also pinned). This is the
op's REAL refusal order per the brief's own "the refusal copy is the
op's real message" — no copy was invented to make I10 win.

**Interpretations for the cold reviewer:**
1. **The sheet's presentation mechanism** — an in-place overlay in the
   same screen, NOT a modal `UISheetPresentationController`: the
   ratified mockup draws exactly this (absolute-positioned dim + sheet
   over the page; "the page stays visible behind it"), batch 1's
   overlay precedent applies, and the house harness can drive it.
   System-sheet physics (drag-to-dismiss detents) is an S3/look-round
   option if her feel round wants it (P20).
2. **"The in-page editor stands down while a card is live"** shipped
   as the stricter superset: it stands down while the sheet is OPEN
   (the dim already blocks page touches; a live-but-covered page
   editor would be a second liveness ambiguity) and is restored at
   close — P22; pinned both transitions.
3. **"Branch this one"** branches the page's DISPLAYED take (the
   peeked take while peeking, else the shown chosen) — the coherent
   "this one" (it is also what ✓ acts on) — P21; pinned both states.
4. **A browser ✓ ends any peek on the block even when choosing a
   DIFFERENT take than the peek** — the explicit ✓ is THE deciding
   act; keeping a stale peek over a fresh explicit choice would show
   neither truth nor decision (M6's unambiguity read into the
   browser). Pinned (`chooseADifferentTakeThanThePeek…`). The batch-1
   pill door (`chooseDisplayed`) is byte-untouched.
5. The guard-order finding above.
6. **The card editor is a plain `UITextView`** — one take's text, no
   block index, no separators: the pane class. The TK2-explicit
   construction + checkpoint canary guard the CONTINUOUS page surface
   (P1's mechanism); a one-take card needs neither. Its delegate is
   the browser view forwarding to the controller's gate (identity
   pinned).
7. **Verbs flush-then-refresh** (`refreshTakesFromStore`): the flush
   serves DELIVERY ADOPTION (a dirty buffer would defer the ingest),
   not the op — batch 1's interpretation 6 (✓ itself needs no flush)
   stands uncontradicted.
8. **The surface tests drive the card editor via `insertText` + an
   explicit `textViewDidChange(_:)` call** — UIKit's delegate dispatch
   for programmatic `insertText` is not contractual in the headless
   harness; the wiring is pinned by delegate IDENTITY and the routing
   by store-byte checks. A double-fire (if UIKit also dispatched)
   records the same text twice — harmless by construction (same
   bytes; churn approximate per SyncSpec §6).
9. **`report(String)` → `report(String?)`** — the one batch-1 API
   signature touched (success clears the prior refusal, the Mac
   `run()` posture); every existing call site passes a non-optional
   String and compiles unchanged.
10. **The card ⋯ menu's actions and the dim-tap door are pinned by
    presence/titles, not by invoking their `UIAction` handlers**
    (UIKit exposes no public invoke); the verbs they call are pinned
    directly, and mutation C shows the refusal path discriminates.

**PROVISIONALs (P20–P26, for the stage-gate bundle; numbering
continues batch 1's):**
- **P20:** the sheet's mechanism + geometry — in-screen overlay, top
  120 pt, 22 pt corners, ink-based 0.25 scrim, face.surface sheet /
  face.card cards (look-track material; system-sheet physics an
  option).
- **P21:** "branch this one" = the DISPLAYED (peek-aware) take.
- **P22:** the stand-down scope = the whole open-sheet window.
- **P23:** the refusal wordings — the I10 copy ("This is the block's
  only take — a block always keeps one. Deleting the whole block is a
  Mac gesture for now."), the chosen-slot copy, the locked-take copy,
  the per-verb sealed copies, and the bar's tail refusal.
- **P24:** card grammar constants — 120 pt live-card editor height,
  corner 10, edge bar 2.5, chrome 12/13, "(empty take)" placeholder —
  all look-track.
- **P25:** a tap on the dimmed page margin closes the sheet (the
  sheet-over-page convention; the mockup drew no such door).
- **P26:** the ⋯ menu's item titles ("Archive Take" / "Delete Take",
  system menu register — not voice-cased chrome; the system edit
  menu's "Takes…" item likewise).

**Deliberate absences (scope, not holes):** recovery surfaces
(archived/deleted take listing + resurrection) — Mac-side in v1 per
the brief, RECORDED for the stage gate; archived takes never appear in
the browser (the fan is active-only by definition — coherent with the
same absence); ⋯/the block menu (S4), divide/merge doors (S4), the app
shape (S3), Read flow (S4), reorder/move/copy-all (L12 — after 13e);
**no keyboard-guide constraint on the sheet** (the browser view pins
to the surface container's bounds; the software keyboard may cover
lower cards while a card is live — a DEVICE feel-round item; the fix
is one constraint if wanted); no capability-registry rows (the
standing S1 posture); no visual inspection beyond machine-verified
attributes (the 13b class — the S2 feel round is the instrument); the
sheet is not driven by real touch (the card tap, ⋯ menu, dim tap ride
gesture/menu machinery pinned at the wiring level; the S2 feel round
covers finger-feel per the memo's obligation 6).

**LADDER-ATTENTION FLAGS (batch 2 closes Stage 2's planned scope —
the stage-end ladder opens on the S2 combined diff):**
1. **The guard-order finding** (interpretation #5): the walk's brief
   line "the I10 refusal on the last live take SPEAKS" is satisfied
   through the archive door and delete's one true path — the ladder
   should confirm this reading against the brief's "the refusal copy
   is the op's real message" (an alternative would override the op's
   order in copy, which this batch deliberately did not do).
2. **The stand-down superset** (P22) vs the brief's "while a card is
   live" letter.
3. **The overlay-not-modal mechanism** (P20) — the LK4 ratified SHAPE
   is honored literally; the mechanism is the recorded interpretation.
4. **The two sanctioned pin flips** (P15's badge door; the six→seven
   act bar pin) — both flips were named in advance by their own
   records; verify and wave through (the S1 round-1 comment-only
   class).
5. **The keyboard-avoidance absence** on the sheet (device item).
6. **VM growth +71 lines, all routing** (the P-9 watch): enumerate
   against interpretation/item 5's list; the browser brains are
   sibling files.
7. **`report`'s optional widening** — one signature, zero call-site
   edits; confirm no caller depended on non-nil semantics.
8. **The S2 feel round** now covers BOTH batches' device items (the
   swipe dominance/loupe feel from batch 1; the sheet's finger-feel,
   card editing under the real keyboard, and the keyboard-over-cards
   question from this batch).

**NO `Sources/VariorumCore` lines; NO schema; NO `Sync/` lines; NO
Mac-side or `Shared/` touches** (the whole diff is mobile-target).
Commits: `005dec2` (the browser + doors + suites) · the record
commit; pushed to `origin mobile` at bout end.

## Stage 2, batch 2 — ACCEPTED; STAGE 2 BUILD COMPLETE — the ladder OPENS (architect, 2026-08-03)

**Acceptance:** verified — diff scope inspected (mobile-target only:
three new sibling-type files, thin VM/bar/view touches, tests, the
record; zero shared, zero core, zero pbxproj), the batch record read,
push state confirmed, and **mobile 123/20 re-confirmed by the
architect's own run**. The overlay-not-modal presentation reading and
the two sanctioned pin flips (P15's badge door; the six→seven bar pin)
are ACCEPTED. The `deleteVariant` guard-order finding is CORRECTLY
mirrored, never changed (core behavior, Mac-identical, pinned both
ways). P20–P26 join the stage-gate bundle (now P1–P26 + LK5's rider +
the missing-acts note). The eight ladder flags stand recorded for the
reviewer's anchor; the sheet's missing keyboard-guide constraint joins
the S2 feel round's device items.

**THE STAGE 2 REVIEW LADDER — round 1 (fresh cold reviewer, spawned at
this record):** review target = the stage's combined diff,
**`c8174ed..40256ca`** (S2 batches 1–2 + the architect's records). The
reviewer runs `notes/REVIEW_PROMPT.md` VERBATIM with zero framing; its
anchors are this file's S2 batch records + the eight flags. Findings
land repo-first in this file; the same-model flow holds (the architect
adjudicates against the spec; fixes with traced mechanisms +
revert-verified pins; round 2 re-reviews fresh; hard cap three).

---

## Stage 2 review — round 1 findings (cold reviewer, 2026-08-03)

**Scope of this review, done in-session:** `notes/REVIEW_PROMPT.md` run
verbatim; the FULL combined diff `c8174ed..40256ca` read file-by-file
(all five new Takes sources + the seam file in full; the VM / bar /
style / text-view hunks; all four test files in full; the record
commits), plus the shared code the new code leans on read in the core
(`TakesQueries.takesProjection`/`activeFans`, `Operations+Deletion`,
`EditorProjectionEngine`, `AutosaveCoordinator`); anchors = this file's
S2 batch records + the eight recorded ladder-attention flags, each
dispositioned below. **Counts re-verified by this reviewer's OWN runs:**
core `swift test` **1039/114 GREEN**; mobile (iPhone 17 Pro / iOS 26.2)
**123/20 GREEN** (single run). The Mac suite deliberately NOT run: this
reviewer's own `git diff --stat` read confirms the stage diff carries
zero `Sources/VariorumCore`, zero `Shared/`, zero Mac-side, zero pbxproj
lines — no trace implicates shared code. Read-only per the prompt; no
fixes made. No "Review foci" section exists for this project; the eight
flags served that role.

### Findings

**[BLOCKER] · `Features/Takes/MobileTakesController.swift:162,166`
(`flip`'s original capture/restore) · flip-back restores the CHOSEN take
from the stale `slots` photograph, ledger-blind — typed-but-unflushed
text on the flipped block visibly reverts, and typing on the reverted
base permanently clobbers the edit.** Mechanism, traced end to end:
(1) type into a block's displayed chosen take — `storageDidEdit`
(`MobileEditorViewModel.swift:606-658`) records the edit in the ledger +
autosave but `slots` is never refreshed (the only writer of `slots[i]`
is `displaySlot`, VM:545), so the photograph lags the surface — the VM's
own `displaySlot` comment names slot texts "stale photographs" while
dirty. (2) Flip-on inside the dirty window: `let original =
originals[blockID] ?? current` (line 162) captures the STALE slot;
nothing heals it before a post-flush echo delivery (deferred deliveries
never adopt `slots`, and `overlay` refreshes `originals` only for
blocks ALREADY peeked — flip-on is the un-refreshed moment). (3) Flip
back before that delivery: `displaySlot(original)` (line 166) replaces
the surface text with the stale bytes AND `ledger.recordEdit(chosen,
staleText)` (VM:534-566) overwrites the surface's own truth record.
(4) Two arms: **(a)** no further typing — the pending autosave entry
(text captured at record time, `AutosaveCoordinator.swift:106-116`)
still flushes the edited bytes and the settle differential restores
them: a visible revert-then-reappear glitch, self-healing; **(b)** the
user types into the reverted block first (exactly what a revert
invites) — `recordAutosave` reads the stale-based surface and
`autosave.record` REPLACES the pending entry (or the next flush
overwrites the already-flushed store text): the earlier typing is
PERMANENTLY lost from `working_text`, no commit anywhere. The window is
the debounce+delivery gap (≥500 ms; extended indefinitely by continued
typing since `record` reschedules) — type-swipe-swipe with real fingers
reaches it. The asymmetry is the tell: the PEEKED direction resolves
ledger-first by design (`peekedSlot`, line 248 —
`surfaceKnownText(variantID:) ?? take.workingText`, pinned by
`anEditedPeekSurvivesFlippingAwayAndBack`); the CHOSEN direction got no
such consult, and the existing pin edits only the peeked take (whose
chosen-side photograph happens fresh), so it cannot see this. Proposed
fix: resolve the restore ledger-first symmetrically — rebuild the
original slot's text as `surfaceKnownText(original.variantID) ??
original.text` at capture and/or restore (one helper mirroring
`peekedSlot`). Red-on-old pin: type into the chosen take with the
debounce held open (the injected sleep), flip away, flip back — assert
surface AND ledger hold the edited bytes (red on old at both), then
flush and assert the store does.

**[MAJOR] · `Features/Takes/MobileTakesBrowser.swift:205-212 + 223-237`
(`branchDisplayed`/`mint`) · "branch this one" copies `working_text`
past a dirty buffer — the op runs BEFORE any flush; the 13f R1-4 class
on a NEW door.** Mechanism: `mint` calls `runner.run {
ops.branchVariant(...) }` (line 228), which copies the source variant's
text from the STORE; the flush inside `refreshTakesFromStore` runs only
AFTER the mint (line 230). Typed-but-unflushed text on the displayed
take — in-page typing, or a card edit routed via `recordTakeEdit`
(VM:521) — is missing from the copy, and VISIBLY so: cards render
ledger-first (`cards()`, line 102), so the source card shows the edited
bytes while the just-minted "branch of this one" shows older bytes.
Recoverable (the original's flush still lands; loss is the copy's
completeness) — exactly the KnownIssues "copy doors read the store past
a dirty buffer" class, but that row deliberately covers the OLD Mac
doors; the 13f ladder's R1-4 ruling made NEW doors flush first (the
`AppSession.divergeForBook` precedent), and this door is new in this
diff. Batch-2 interpretation #7 defends the ✓ door correctly
(`chooseVariant` reads no text) but does not cover branch, which does.
Proposed fix: flush before the mint in `branchDisplayed` (blank copies
no text and needs nothing). Red-on-old pin: record an unflushed edit on
the displayed take, `branchDisplayed()`, assert `mint.workingText`
equals the edited bytes.

**[MINOR] · `MobileTakesBrowser.swift:269-280` (`cardGateAllows`) · the
per-keystroke belt checks the SEAL only — its own doc comment claims
"the sealed/locked belt re-checked per keystroke," and the locked half
is not in the code.** Mechanism: `beginEditing` refuses a locked take
at the door (line 251), but a take that becomes locked WHILE its card
is live (a remote lock arriving by sync — the phone has no lock door)
keeps its editor (`projectionDidChange` resigns only when the take
VANISHES, lines 169-172) and `cardGateAllows` admits every keystroke
(only `model.isSealed`, line 275). The flush then refuses
(`lockedVariant` — store safe, `onError` speaks raw), and the
typed-after-lock text never lands; Done → `refreshTakesFromStore`
re-reads the store and drops it. The PAGE gate refuses this same state
per keystroke (index entries carry `variantLocked` → `editable`), so
the gap is one surface wide. Narrow race. Proposed fix: consult the
live card's `isLocked` in the belt (and/or resign the editor when the
card turns locked at `projectionDidChange`) with the standing copy;
red-on-old pin: lock the variant via ops mid-edit, deliver, assert the
next `cardGateAllows` refuses.

**[MINOR] · `MobileTakesBrowserView.swift:283-293` (`attachCardEditor`)
+ `MobileTakesBrowser.swift:244-259` (`beginEditing`) · no
`becomeFirstResponder` anywhere in the chain — "the minted card goes
LIVE for editing so she is typing instantly" holds structurally
(editor attached, editable) but focus never rises.** Evidence: a grep
over the shipped mobile sources finds `becomeFirstResponder` only in
the Spike; the beginEditing → render → attach chain never calls it. On
device, tapping a card body (or minting) seats the editor without
raising the keyboard — a second tap is needed, which is exactly the
friction the record's "typing instantly" claim denies. Honest caveat:
keyboard focus is weakly pinnable headless (first-responder needs a
window), so this is a fix-plus-feel-round item, not a red-on-old class.
Proposed fix: one `becomeFirstResponder()` after attach, judged at the
S2 feel round; note the interplay with flag 5 (once focus rises, the
missing keyboard-guide constraint bites more often).

**[MINOR] · `MobileEditorTextView.swift:139-144` (`layoutSubviews` →
`takesChrome.refresh()`) + `MobileTakesChrome.swift:81-168, 279-318` ·
the per-scroll-tick chrome refresh enumerates fragments with
`.ensuresLayout` for EVERY fanned block in the post, on-screen or
not.** Mechanism (the cost SHAPE is concrete; the magnitude is
unmeasured — that half honestly SPECULATIVE): UIScrollView lays out on
every content-offset tick; each `refresh()` walks `model.slots where
slot.hasFan` (line 93) and per fanned block resolves a document
location and forces its first fragment's layout (`.ensuresLayout`,
line 286), plus `blockRectsUnion` over every peeked block's whole
range. Cost per tick ∝ the post's fanned+peeked blocks, not the
viewport — and forcing layout of far-off-screen fragments works
against TK2's viewport laziness (TEXTKIT2 §2) at 60–120 Hz while
scrolling. The file header records "cost ∝ the post's fanned blocks
(opt-in and rare)" as the accepted call — the per-tick multiplication
is the unrecorded half. Fine at real fan counts; a fan-heavy long note
may jank. Proposed: measure at the device round; if real, gate the
badge walk by viewport intersection or cache first-line geometry keyed
on a layout generation. No pin owed unless it proves a perf defect.

**[NIT] · `MobileTakesController.swift:183-197` (`chooseDisplayed`) ·
the pill's ✓ never clears a prior refusal on success.** The browser
verbs adopted the Mac `run()` clearing posture (`report(nil)`); the
batch-1 door was left un-aligned. Concrete: a sealed refusal spoke via
the pill → she unseals on the Mac → delivery → pill ✓ succeeds →
`statusMessage` still shows the stale locked-note copy. One
`model?.report(nil)` on the success path aligns it (the `String?`
widening exists for exactly this).

**[NIT] · `MobileTakesController.swift:101-110` (`adoptFans` prune) +
`MobileEditorViewModel.swift:206-213` (`ingest`'s unconditional chrome
refresh) · a DEFERRED delivery that prunes a peek removes the marker
while the pruned take's text stays on the surface.** Mechanism: peek
block A; be dirty elsewhere; the peeked take is archived remotely; the
delivery's `adoptFans` prunes the peek and `ingest`'s trailing
`takesChrome.refresh()` removes the marker — but the slot apply DEFERS
(`deferUntilClean`), so until the settle lands, A displays non-chosen
text wearing no marker (M6's chosen-vs-peeked unambiguity, briefly
false). Sub-second, self-healing, store never wrong; the batch record's
"the display heals through the accompanying slot apply" describes only
the non-deferred case. Record the corner, or defer the prune's chrome
effect to the apply.

No other findings at any severity; every severity level above carries
at least one entry (nothing at BLOCKER/MAJOR beyond the two named).

### The eight ladder-attention flags, dispositioned

1. **The guard-order finding — CONFIRMED, the mirror is exact.** My own
   core read (`Operations+Deletion.swift`): delete = locked (:89) →
   placement seal (:92) → chosen-slot COUNT guard (:93-99) →
   `ensureNotLastActive` (:100); archive (:33-52) has NO chosen guard
   and hits `ensureNotLastActive` (:43). So delete-on-a-last-and-chosen
   take truly speaks chosen-slot first, I10 through delete is reachable
   exactly when the pointer targets no live take, and the archive door
   speaks I10 directly — precisely what the pins hear
   (`theLastActiveTakeRefusesArchiveAndDelete_I10` reaches I10 through
   delete only after archiving the chosen; the walk hears
   chosen-slot-first). Overriding the order in copy would have invented
   behavior; mirroring was right.
2. **The stand-down superset (P22) — SOUND.** Verified in `render()`
   (`isEditable = false` at open, restored at close, pinned both
   transitions). Zero live panes while the sheet is open with no live
   card is the read-mode state, not a P3 violation (the rule is
   only-the-focused-unit-is-live); the superset also kills the
   live-but-covered ambiguity the record names. The brief's letter is
   exceeded, never violated. P22 to the gate as recorded.
3. **Overlay-not-modal (P20) — ACCEPTABLE interpretation.** The
   ratified mockup's literal geometry is honored (dim + sheet over the
   page, page visible behind); harness-drivability is real (the pixel
   suite and walk 6 drive it headlessly). The trade is honestly
   recorded: no system detents/physics, and flag 5's keyboard-guide
   absence is a consequence of not riding the system sheet. Hers at the
   gate/feel round.
4. **The two pin flips — VERIFIED SANCTIONED, waved through.** The
   six-act pin's pre-flip comment named ⑂'s S2 arrival ("they arrive
   WITH their surfaces in S2" — my own read of the old hunk); its
   seven-act form now pins ORDER over laid-out items, stronger than the
   old split. The badge pin's interim form (my own read of `ba6b2d9`)
   pinned P15's door with "the tap is a look," and P15's record named
   the batch-2 repoint in advance; the flipped forms pin the new truth
   plus nothing-peeked/nothing-written.
5. **The keyboard-avoidance absence — STANDS as a device item**, with
   one rider: it compounds with the missing `becomeFirstResponder`
   (MINOR above) — today focus never rises headless, so the exposure
   is partly latent; fixing focus makes the missing constraint bite.
   Weigh the two together at the feel round.
6. **VM growth +71, all routing — P-9 HONORED.** Enumerated by my own
   hunk read: composition + wiring, the ONE projection door (`ingest`),
   pure lookups, browser doors, `refreshTakesFromStore`,
   `recordTakeEdit`, the `report` widening, and `displaySlot`.
   `displaySlot` is the one arguable entry and it is surface-apply
   machinery (index/storage/ledger) — the VM's own concern — not a
   takes decision; the decisions live in the sibling files.
7. **`report(String?)` — SAFE.** `statusMessage` is already `String?`
   (VM:65); every pre-existing caller passes non-optional and no reader
   depends on non-nil (writes are VM-internal; the face renders the
   optional). The widening adds behavior only where `nil` is now
   passed. Adjacent: NIT 1 above — the batch-1 pill door was left
   outside the clearing posture the widening was built for.
8. **The S2 feel round — STANDS**, with this review's riders: the
   marker's behind-canvas z-order (machine-pinned at subview index 0;
   eyes still owed), the second-tap focus gap (MINOR above), the
   scroll-cost question on a fan-heavy note (MINOR above), and the
   badge's tap target (≈26 pt × line height — under the 44 pt HIG
   floor; look-track material).

### Clean bill (load-bearing things specifically checked, found solid)

- **Counts:** core 1039/114 and mobile 123/20 reproduced exactly by my
  own runs; the recorded figures are real.
- **Boundaries:** zero `Sources/VariorumCore`, `Shared/`, Mac-side,
  pbxproj, schema, or `Sync/` lines in the stage diff (my own stat
  read); no new dependencies; `renderedText`/export bodies/the bridge
  untouched by construction.
- **The zero-store-write peek:** pinned three ways INCLUDING the
  `sync_outbox` row count; `displaySlot`'s path traced — no autosave,
  no DB, no ledger-dirty writes (the ledger's `recordEdit` is
  bookkeeping, not dirtiness — verified in `EditorSurfaceLedger`).
- **The one projection door:** every store delivery routes ingest →
  adoptFans → overlay → policy. The raw-slots-bypass hazard I chased
  does not exist: post-attach, `pendingProjection` is a MARKER only —
  `applyPendingIfClean` discards the held value and re-reads fresh
  through `ingest` (VM:415-429); the only raw apply is the pre-attach
  seam, where no peek can exist.
- **✓ the only choosing act:** `chooseVariant` through ops on both
  doors; the sealed refusal pinned verbatim; the peek survives the
  refusal; minting never chooses (R90, pinned); the browser ✓ ending
  any peek (interpretation #4) is M6's unambiguity read coherently.
- **Refusals are the ops' own:** I10 / chosen-slot / locked / sealed
  heard through `OperationError`, phone words for the everyday cases
  only, `String(describing:)` for the rest — no invented behavior.
- **P3 in the sheet:** ONE reused card editor moving between cards
  (identity pinned); the page stood down and restored (pinned both
  transitions); card edits route through the ONE ledger + coordinator
  (`recordTakeEdit`) so sheet and page cannot disagree on bytes —
  pinned pre- and post-flush.
- **The seam file:** the one documented delegate method on the ONE gate
  delegate; no second `UIEditMenuInteraction`; the item offered exactly
  where a block resolves (pinned both ways); mechanism + item + method
  all in the one file per the iOS-27 note.
- **The bar:** seven acts in LK8's order, order-pinned over laid-out
  items; ⑂'s caret resolution boundary-tolerant including the separator
  seat (pinned); the tail refusal speaks (P-2); the fan-birth door on
  fanless blocks real (`takesProjection` provides fans for every
  non-gap block — verified in core — so a single-take block's browser
  shows its one card).
- **LK10's gutter:** pinned by real wrap geometry WITH the fanless
  discrimination twin; exclusion count exact; the refresh loop-safety
  traced (equality gates make the steady state write-free, so the
  `layoutSubviews` hook cannot oscillate).
- **M6/M9 mechanics:** flip-onto-chosen ends the peek; remote choose
  fulfills; remote archive prunes; sticky across deliveries with the
  echo pinned (`fullRenderCount` unchanged).
- **The walks:** store-byte checks at every step, teardown byte-exact,
  identity audit 0, desync 0, canary silent — green in my own runs.
- **Voice discipline:** every color/font in all five new files resolves
  from `MobileEditorStyle.face`/tokens (the S1 flag-6 duty); terminal
  lowercasing through one `chromeCase`; the chrome voice-flip test's
  window is await-free (consistent with the S1 round-2 posture).
- **Wiring/memory:** the chrome/browser/VM triangle carries weak
  back-references throughout — no retain cycle.

## Stage 2 review — round 1 ADJUDICATION (architect, 2026-08-03; the fix session spawns on this record)

Every finding adjudicated against the spec; the BLOCKER/MAJOR fixes go
to a FRESH fix session per the same-model ladder flow (bug-class fixes
need traced mechanisms + red-on-old pins verified by behavioral revert —
not architect-at-adjudication work):

- **BLOCKER — AGREED; fix owed.** The mechanism is concrete and is the
  known stale-projection class (the Phase 8 review's MAJOR family; the
  forbidden outcome — "nothing typed is ever lost" — outranks
  everything). The peeked direction was ledger-first BY DESIGN; the
  chosen direction must be SYMMETRIC: ledger-first resolution at both
  flip-capture and flip-restore. Red-on-old pin per the reviewer's
  specification (type into the chosen take → flip away and back inside
  the debounce window → the typed bytes survive on surface, in the
  ledger, and in the store).
- **MAJOR — AGREED; fix owed.** `branchDisplayed` copies past a dirty
  buffer — the 13f R1-4 class (a door offered at a possibly-dirty
  moment flushes FIRST; the copy must carry the keystrokes that
  summoned it). Flush before the mint; red-on-old pin per the
  specification.
- **MINOR 1 — AGREED; fix owed.** The card gate's claimed sealed/locked
  belt must be real: extend to the locked-take state with keep-pending
  on refusal (a remote lock mid-card-edit must never lose typed text —
  the Phase 7/8 keep-pending posture). Pin the keep-pending half.
- **MINOR 2 — AGREED; fix owed.** The card editor takes first responder
  on activation (one tap, not two); walk-assert where drivable; the
  on-device feel rider stands.
- **MINOR 3 — AGREED AS SHAPE; fix the SHAPE, measure the magnitude.**
  A per-scroll-tick refresh forcing layout for EVERY fanned block in
  the post violates the invalidation-∝-realized-rows law (P-8)
  structurally, whatever the measured cost. Scope the per-tick chrome
  refresh to the near-viewport range (the TK2 viewport is queryable);
  pin the call-shape if drivable, else record honestly; the device
  round measures.
- **NIT 1 — AGREED; fix owed** (one line: the pill's ✓ clears the prior
  refusal on success — `report(nil)`, the browser verbs' own pattern).
- **NIT 2 — RECORDED, no change** (the pruned-peek marker gap is a
  self-healing transient of a background prune racing a display; the
  M6-unambiguity cost is momentary and the next delivery repairs it —
  a fix would need the prune to synchronously re-enter display code it
  deliberately stays out of).

All eight flag verdicts ACCEPTED as returned (the guard-order mirror
confirmed against the real op order; both pin flips verified
sanctioned; the four feel-round riders join the gate bundle).

## Stage 2 review — round 1 FIX-PASS RECORD (fix session, 2026-08-03; commits `2f824e7` · `398ae6e` · `4f4672c` · `e2f6550`, pushed)

Every adjudicated fix built EXACTLY per the adjudication, each preceded
by this session's OWN trace of the mechanism (the hallucination guard;
all six reproduced — nothing refuted), each bug-class fix landed with a
red-on-old pin verified by BEHAVIORAL REVERT (the pre-fix mechanism
temporarily restored, the pin watched fail with recorded issue counts,
the fix restored, green re-confirmed). Per finding:

**BLOCKER — flip capture/restore go ledger-first (commit `2f824e7`).**
*Own trace:* `slots[i]` is written ONLY at adoption points (`renderFull`
/ `applyDifferential` / `adoptEcho` / `displaySlot`) — never per
keystroke (`storageDidEdit` → `recordAutosave` writes ledger + autosave
only) — so `flip`'s `originals[blockID] ?? current` captured a stale
photograph and `displaySlot(original)` restored it AND overwrote the
ledger's record for the chosen variant (`displaySlot`'s own
`ledger.recordEdit`); typing on the reverted base then had
`autosave.record` REPLACE the pending entry (whole-buffer text) —
arm (b)'s permanent loss confirmed byte-for-byte. *Fix:*
`resolvedOriginal(_:)` — `peekedSlot`'s symmetric twin (rebuilds the
slot with `surfaceKnownText(variantID) ?? photograph`) — consulted at
BOTH the capture (`originals[blockID] ?? resolvedOriginal(current)`)
and the restore (`displaySlot(resolvedOriginal(original))`), per the
adjudication's letter. The restore-side consult also heals `originals`
staleness from any other road (e.g. a browser-card edit of the chosen
take mid-peek; `overlay`'s refresh of `originals` from a DEFERRED
delivery's stale raw slot). *Pins:*
`anEditedChosenTakeSurvivesFlippingAwayAndBack` (the reviewer's exact
specification: typed bytes on surface + in ledger post-round-trip, then
flush → store) and `typingAfterAFlipRoundTripNeverLosesTheEarlierEdit`
(arm (b): both edits reach `working_text`). *Revert evidence:* pre-fix
mechanism restored → **3 issues** — surface reverted to the stale
photograph, ledger overwritten (the specified red-on-old at BOTH), and
the store LOST the earlier edit in arm (b); 13 sibling tests stayed
green (the pins discriminate); fix restored → 15/15.

**MAJOR — `branchDisplayed` flushes before the mint (commit
`398ae6e`).** *Own trace:* `branchVariant` copies `source.workingText`
from the STORE (`Operations+Variant.swift:153`); the only flush on the
door's path was inside `refreshTakesFromStore`, AFTER `runner.run` —
so the copy missed unflushed keystrokes while `cards()` showed them
ledger-first on the source card. *Fix:* `await model.autosave.flushNow()`
in `branchDisplayed` before `mint` — the 13f R1-4 shape; blank
deliberately untouched (copies no text), ✓ deliberately untouched
(batch-1 interpretation 6 stands, per the adjudication). *Pin:*
`branchDisplayedCarriesUnflushedEditsIntoTheCopy` (unflushed in-page
edit on the displayed take → branch → the returned mint AND its store
row hold the edited bytes). *Revert evidence:* flush commented out →
**2 issues** — stale bytes in `mint.workingText` and in the mint's
store row (the source's own flush still landed after, exactly the
"loss is the copy's completeness" framing); fix restored → 19/19.

**MINOR 1 — the card gate's locked belt made real (commit `398ae6e`).**
*Own trace:* `cardGateAllows` checked `model.isSealed` only; a take
locked remotely mid-card-edit stays in `cards()` (fans adopt
UNCONDITIONALLY in `ingest` even while the dirty buffer defers the slot
apply), `projectionDidChange` resigns only on VANISH — so keystrokes
were admitted that only the flush could refuse. *Fix:* the belt
consults the live card's `isLocked` and refuses with the STANDING
locked-take copy; it deliberately does NOT resign the editor (the page
gate's own refuse-and-speak posture — the pre-lock text stays visible
ledger-first on the card). *Pin:*
`aRemoteLockMidCardEditRefusesTheNextKeystrokeAndKeepsPendingText` —
the gate refusal red-on-old, PLUS the adjudicated keep-pending half
asserted through BOTH refusals: the pre-lock bytes survive the gate
refusal (ledger + `isDirty`) and the flush's own `lockedVariant`
refusal (entry back in pending, store byte-safe). *Revert evidence:*
belt short-circuited → **2 issues** — the post-lock keystroke admitted,
no refusal spoke (the keep-pending assertions passed on old too, as
expected — the coordinator's posture was never the defect); fix
restored → green.

**MINOR 2 — the card editor takes first responder on activation
(commit `4f4672c`).** *Own trace:* grep confirms `becomeFirstResponder`
appeared nowhere outside the Spike; the beginEditing → render →
attachCardEditor chain seated an editable editor with no focus — the
second tap the record's "typing instantly" denied. *Fix:* one
`becomeFirstResponder()` on the ATTACH TRANSITION only (the
`superview !== card` branch — never the per-render restyle), windowless
no-op harmless. *Pin — DRIVABLE, better than the finding hoped:*
`beginEditingRaisesKeyboardFocusOnTheCardEditor`, WINDOW-HOSTED
(UIWindow + makeKeyAndVisible in the harness works): focus rises at
activation, FOLLOWS the editor across a card move, resigns at Done.
*Revert evidence:* call commented out → **2 issues** (no focus at
activation, none at the move); fix restored → green. The on-device
keyboard-feel rider (and its flag-5 interplay — the sheet's missing
keyboard-guide constraint now bites more often) stands for the S2 feel
round as adjudicated.

**MINOR 3 — the per-tick chrome refresh scoped to the near viewport
(commit `e2f6550`).** *Own trace:* `layoutSubviews` fires per
content-offset tick and `refresh()` walked EVERY fanned block with
`.ensuresLayout` (+ `blockRectsUnion` over every peeked block) — cost
per tick ∝ the post's fanned+peeked blocks, forcing far-off-screen
fragment layout against TK2's own laziness: the P-8 shape violation,
confirmed. *Fix (the SHAPE, per the adjudication; magnitude stays the
device round's):* `refresh(scope:)` — `.document` (default; every
existing content/geometry call site unchanged) vs `.nearViewport` (the
layoutSubviews hook): the TK2 viewport queried as a character band
(`textViewportLayoutController.viewportRange`, padded one viewport
length each side; unavailable ⇒ everything-near, the honest fallback),
geometry forced ONLY for blocks intersecting it. Off-band chrome keeps
its content-anchored frames (scrolling never moves subviews of the
scroll view); off-band GUTTER EXCLUSIONS survive from a per-block cache
(`exclusionByBlock`) — dropping one would reflow the document per tick,
the trap the naive scoping would have built. A width change escalates
the tick to a full pass (every rect moves); the equality gates are
unchanged, so the steady state stays write-free. *Pin — the call shape
proved DRIVABLE headless (viewportRange is real in the harness):*
`perTickRefreshResolvesOnlyNearViewportGeometry` — a 61-block post
(contentSize > 2000 pt over a 700 pt viewport), two fanned blocks near
and far: the `.nearViewport` pass resolves ONLY the near block (test
seam `lastGeometryResolvedBlockIDs`), the far badge and BOTH exclusions
survive, and the `.document` pass resolves both. *Revert evidence:*
band neutralized (the pre-fix everything-forced tick) → **1 issue** —
the far block layout-forced on the tick; fix restored → 8/8.

**NIT 1 — the pill's ✓ clears the prior refusal (commit `4f4672c`).**
*Own trace:* `chooseDisplayed`'s success path lacked the browser verbs'
`report(nil)` — the exact staleness the `String?` widening was built
for. *Fix:* one `model?.report(nil)` on success. *Pin (cheap and
discriminating, so pinned despite NIT class):*
`aSuccessfulChooseClearsThePriorRefusal` — sealed refusal spoken →
unseal → ✓ succeeds → message nil. *Revert evidence:* line removed →
**1 issue** (the stale locked-note copy survived success); restored →
green.

**NIT 2 — untouched, as adjudicated** (recorded-only; nothing built).

**Counts, all by this session's own runs (iPhone 17 Pro / iOS 26.2):
full mobile suite 130 tests / 20 suites GREEN** (single run; the
baseline 123/20 + this pass's SEVEN pins; MobileWalkTests, the L9 pin,
and the identity audit all green within — walks 5/6 byte-checks
untouched). **Core / Mac / spine deliberately not run:** the fix-pass
diff (`4652e01..e2f6550`, 8 files, +464/−24) is mobile-target only —
zero `Sources/VariorumCore`, zero `Shared/`, zero Mac-side, zero
pbxproj, zero schema, zero `Sync/` — so the only-if-shared condition
never fired. Commits pushed to `origin mobile`.

*Notes for the round-2 reviewer:* (1) the BLOCKER fix deliberately did
NOT touch `overlay`'s `originals[slot.blockID] = slot` refresh — a
deferred delivery can still park a stale raw slot there, but the
restore-side `resolvedOriginal` consult makes that staleness harmless
(text is re-resolved ledger-first at the only point it is consumed);
building a third consult into `overlay` would have exceeded the
adjudication's letter. (2) MINOR 1's belt reads `cards()` per
keystroke — cost ∝ the open block's fan (opt-in and rare), the same
class as `cards()`' other per-render callers. (3) MINOR 3's
`.document` default keeps every pre-existing `refresh()` call site
byte-identical in behavior; the ONLY behavioral change is the
layoutSubviews tick. (4) The pill's off-band arm leaves a visible pill
untouched mid-scroll rather than hiding it — it fades on its own 2.4 s
timer; judged the honest reading of "off-band chrome untouched".

---

## Stage 2 review — round 2 (fresh cold reviewer, 2026-08-03)

**Scope, done in-session (a REAL pass, not a rubber-stamp):**
`notes/REVIEW_PROMPT.md` read first and followed; the FULL fix diff
`4652e01..e2f6550` read hunk-by-hunk; every touched file read IN FULL
(`MobileTakesController` · `MobileTakesBrowser` · `MobileTakesBrowserView`
· `MobileTakesChrome` · `MobileEditorTextView` + all three test files),
plus the shared machinery the fixes lean on read in full
(`MobileEditorViewModel`, `AutosaveCoordinator`,
`EditorSurfaceLedger`/`EditorProjectionPolicy`, the mobile test harness);
anchors = the round-1 findings, the ADJUDICATION, and the FIX-PASS
RECORD above. **Counts by this reviewer's OWN runs:** full mobile suite
on HEAD (iPhone 17 Pro / iOS 26.2) — **130 tests / 20 suites GREEN**
(single run; the recorded figure reproduced exactly).
**Independent red-on-old verification against the ACTUAL pre-fix tree:**
a scratch git worktree at `4652e01` (outside this checkout; removed
after) with the post-fix `MobileTakesTests.swift` +
`MobileTakesBrowserTests.swift` overlaid (standing APIs only) — **38
passed / 6 failed, and the six failures are EXACTLY the six
standing-API pins**, each failure text matching this reviewer's own
traced mechanism: the surface reverted to the stale photograph
(`anEditedChosenTakeSurvivesFlippingAwayAndBack`); the store LOST the
earlier edit — the forbidden outcome
(`typingAfterAFlipRoundTripNeverLosesTheEarlierEdit`); the mint carried
the store's older bytes (`branchDisplayedCarriesUnflushedEditsIntoTheCopy`);
the seal-only belt admitted the post-lock keystroke
(`aRemoteLockMidCardEditRefusesTheNextKeystrokeAndKeepsPendingText`);
focus never rose (`beginEditingRaisesKeyboardFocusOnTheCardEditor`);
the stale refusal survived success (`aSuccessfulChooseClearsThePriorRefusal`).
Every sibling test stayed green — the pins discriminate. The MINOR-3
pin could not ride the overlay (it references the fix's new
`refresh(scope:)`/`lastGeometryResolvedBlockIDs` API, which does not
exist pre-fix); its verification rests on this reviewer's own call-shape
trace plus the fix session's recorded band-neutralization revert.
**The mobile-target-only claim VERIFIED by my own stat read:** 8 files,
+464/−24, all under `App/Variorum/VariorumMobile{,Tests}` — zero
`Sources/VariorumCore`, zero `Shared/`, zero Mac-side, zero pbxproj,
zero schema, zero `Sync/`; core/Mac/spine deliberately NOT run (the
only-if-shared condition never fired). Read-only in this checkout
throughout; no fixes made.

### Verdicts per round-1 disposition

**BLOCKER (flip capture/restore ledger-first) — HOLDS.** My own trace:
`flip` line 166 (`originals[blockID] ?? resolvedOriginal(current)`) and
line 170 (`displaySlot(resolvedOriginal(original))`) consult the ledger
at BOTH points; `resolvedOriginal` is `peekedSlot`'s exact twin
(identity fields copied intact — blockID/placement/position/counts/
lock; text `surfaceKnownText ?? photograph`). The freshness argument
closes: `ledger.adopt` runs ONLY at clean adoption points
(`EditorProjectionPolicy` defers every delivery while
`autosave.isDirty`), so a dirty variant's ledger record survives until
its flush lands — and the `?? photograph` fallback is reachable only
post-flush, when the photograph a delivery parked carries store truth.
The fix session's note (1) verified by my own trace: `overlay` line 133
still parks a possibly-stale raw slot in `originals` under a DEFERRED
delivery, and the restore-side consult is exactly what makes that
harmless (re-resolved at the only consumption point). **The
stale-photograph sweep found no other text consumer:** `cards()` and
`peekedSlot` are ledger-first; `chosenVariantID` reads IDs only;
`renderFull`/`applyDifferential` are store-truth applications gated by
the deferral; `branchDisplayed` post-fix flushes; the chrome reads
geometry only. Red-on-old reproduced on the pre-fix tree by my own run,
both pins, arm (b)'s store loss included.

**MAJOR (`branchDisplayed` flushes before the mint) — HOLDS.**
`flushNow` sits before `mint`; `displayed` is captured BEFORE the flush
suspension — the honest reading (she branches what she was looking at
even if a delivery lands mid-flush). **Blank untouched IS sound:**
`newBlankVariant` reads no text from anywhere — a dirty buffer cannot
shape it. **✓ untouched IS sound:** `chooseVariant` repoints
`chosen_variant_id` and reads no text; the previously-displayed take's
pending autosave entry still flushes to its own row, so no loss shape
exists on that door (batch-1 interpretation 6 confirmed against the
op). Red-on-old reproduced. One residual corner recorded as NEW NIT 1
below — outside the adjudication's letter, nothing lost.

**MINOR 1 (the card gate's locked belt) — HOLDS.** The belt consults
the live card's `isLocked` with the standing copy; my trace confirms
the mechanism the comment claims: fans adopt UNCONDITIONALLY in
`ingest` (before the slot apply can defer), so the belt sees a remote
lock the moment the delivery lands; keystrokes and deliveries serialize
on the main actor, and `projectionDidChange` resigns on VANISH before
any next keystroke, so the `?.isLocked == true` nil-arm (vanished take)
has no admitting window. Keep-pending verified in
`AutosaveCoordinator.flushNow` (a refused entry re-enters `pending`;
newer text wins the merge) — and the fix record's honesty checks out:
the keep-pending assertions passed on old too (my run confirms the old
tree failed ONLY the gate half), the coordinator's posture was never
the defect. Cost class: the belt's `cards()` read is ∝ the open block's
fan — the recorded per-render family. Red-on-old reproduced.

**MINOR 2 (first responder on card activation) — HOLDS.**
`becomeFirstResponder()` fires on the ATTACH TRANSITION only
(`superview !== card`); my trace confirms no focus churn: card views
are REUSED by variantID across renders (a delivery re-render never
re-attaches, never resets `cardEditor.text`, never re-raises focus),
attach is unreachable while the browser is closed, and activation is
always user- or mint-initiated (the page editor already stood down).
Windowless it is a no-op. The window-hosted pin red-on-old reproduced
by my own run. The flag-5 rider STANDS for the feel round: the sheet
fills the keyboard-avoiding host but carries no keyboard-guide
constraint of its own, so the footer row sits where the keyboard now
actually rises.

**MINOR 3 (near-viewport per-tick scope) — HOLDS as the adjudicated
shape fix.** My own trace of the call shape: the band is the queryable
`viewportRange` padded ONE viewport (min 512 chars) each side;
`.document` remains the default so every content/geometry input axis
(edits via `storageDidEdit`, projections via `ingest`, flips via
`displaySlot`, voice, load) still resolves everything — the ONLY
behavioral change is the `layoutSubviews` tick, exactly as recorded.
**The stale-geometry question interrogated axis-by-axis:** content
edits → `.document`; projections/flips/voice → `.document`; width →
the escalation (`containerWidth != lastFullPassWidth` forces a full
pass and re-records — rotation/reflow covered; the first-ever tick
escalates too since the sentinel starts at −1); TK2
estimate-refinement drift mid-scroll is the ONE uncovered axis, and it
is bounded by construction — **a VISIBLE block is always in-band**
(`viewportRange` IS the laid-out character region; the band is a
character superset of anything on screen), so on-screen chrome is
always freshly resolved and only off-screen chrome can drift, healing
with a full viewport of lead as its block approaches. The
cache-lifecycle trap checked: `exclusionByBlock` moves in lockstep with
`badges` (the cleanup loop removes both; a fanned-but-uncached off-band
block falls through to a ONE-TIME heal resolve, never a per-tick
repeat); the pill arm's new early `return` is covered by the
`refreshing` defer; `near()`'s overlap math handles zero-length
entries; the equality gates are unchanged so the steady state stays
write-free. The call-shape pin is real on HEAD (green within my 130).
**Rider for the DEVICE round (the adjudication's magnitude half):** the
one drift shape that could show wrong pixels is a badge/gutter whose
cached Y drifts INTO the visible region while its block stays off-band —
it requires estimate error exceeding the one-viewport pad and repairs
only at band entry or the next `.document` pass. If the device round
ever sees a ⑂ floating without its block on a very long fan-heavy note,
the remedies are a larger pad or keying the cache on a layout
generation; mechanism named here so the round knows what it is looking
at (magnitude honestly unmeasured, per the adjudication).

**NIT 1 (the pill's ✓ clears the prior refusal) — HOLDS.**
`report(nil)` on `chooseDisplayed`'s success path — the browser verbs'
own posture; red-on-old reproduced by my own run.

**NIT 2 (deferred-prune marker gap) — HOLDS as adjudicated
(recorded-only).** My own diff read confirms `adoptFans`/`ingest` carry
zero fix-pass lines; the transient stays exactly as round 1 recorded
it.

### New findings

**NEW BLOCKER: none. NEW MAJOR: none. NEW MINOR: none.**

**[NIT] · `MobileTakesBrowser.swift:205-221` (`branchDisplayed`) · the
flush-first fix cannot carry bytes a REFUSED flush keeps pending — the
branch then mints older text on the very road the refusal copy
recommends.** Mechanism, traced: bytes typed on a take's card BEFORE a
remote lock arrives stay pending (MINOR 1's keep-pending — the belt
refuses only keystrokes AFTER the delivery); `branchDisplayed`'s
`flushNow` retries the refused entry and is refused again
(`lockedVariant`, keep-pending, error spoken raw via `onError`); the
mint proceeds and `branchVariant` copies the STORE's locked bytes — so
the fresh branch shows older text than the source card (which renders
the pending bytes ledger-first), and "branch it or unlock it on the
Mac to edit" is precisely the road the copy sends her down. Nothing is
lost (the entry stays pending and visible; the store is byte-safe) and
the window is narrow; pinnable (type on a card → remote-lock → deliver
→ branch → mint text == store ≠ pending), but the FIX direction is a
product call — seeding the mint from the ledger would carry refused
bytes past the lock's insure-what-it-protects semantics, while refusing
the branch door under a refused flush would close the recommended road.
Record as the documented corner, or route to `notes/QUESTIONS.md` at
the architect's discretion; deliberately NOT fixed by this round.

### Counts

Mobile **130/20 GREEN** on HEAD (my own run). Pre-fix overlay run: 38
passed / 6 failed — exactly the six standing-API pins, siblings all
green. Core / Mac / spine not run: the fix diff carries zero shared
lines (verified by my own stat read), so the only-if-shared condition
never fired.

### Clean bill (load-bearing things specifically checked, found solid)

- The fix-pass diff's boundary claim (8 files, +464/−24,
  mobile-target-only) — my own stat + hunk read.
- `resolvedOriginal` copies every identity field intact (blockID,
  placementID, position, both counts, comment count, lock) — no
  projection drift rides the text substitution; the `known != slot.text`
  no-op arm returns the slot unchanged.
- The ledger-freshness invariant the BLOCKER fix rests on
  (`adopt` only at clean adoption points; deferral while dirty) —
  traced through `EditorProjectionPolicy.decide` and both adopt sites.
- The MAJOR pin also asserts the SOURCE row flushed (`storedText(a1) ==
  edited`) — the fix's flush is proven, not just the copy's bytes.
- MINOR 1's belt admits no vanished-take window (main-actor
  serialization + resign-on-vanish traced).
- MINOR 2: card views reused by variantID — re-renders never re-attach,
  reset text, or re-raise focus; `detachCardEditor` resigns and clears.
- MINOR 3: every pre-existing `refresh()` call site is byte-identical
  in behavior (`.document` default); the `layoutSubviews` hook is the
  one change; escalation covers the first-ever tick (sentinel −1).
- The harness's debounce hold is real (injected sleep throws
  `CancellationError` — dirty state holds until an explicit flush), so
  the pins' "inside the debounce window" framing is genuine, not
  timing-dependent.
- Worktree state: clean at `5342aaa`, up to date with `origin/mobile`
  at review start; the scratch pre-fix worktree was created outside
  this checkout and removed after the run.

## STAGE 2 — CLOSED (the architect's closeout, 2026-08-03; the ladder closed at round 2)

**What shipped (batches 1–2 + the ladder's fix pass, every step accepted
after verify-don't-trust):** takes on the phone whole — the count-free ⑂
badge with LK10's reserved gutter · the sticky swipe-peek with marker +
under-block pill · ✓ as the only choosing act · peeked-take editing ·
the LK4 sheet-over-page browser with all four M4 verbs through the
standing ops (refusals speaking, I10 heard) · the bar's ⑂ · the one-seam
edit-menu door — all as sibling types per NIT 3. **The ladder: round 1 =
1 BLOCKER (the flip-back stale-photograph text-loss class — caught
before any device ever saw it) + 1 MAJOR (flush-before-mint) + 3 MINOR +
2 NIT; all adjudicated and fixed with revert-verified pins; round 2
(fresh reviewer) = all seven dispositions HOLD with red-on-old
INDEPENDENTLY reproduced on the pre-fix tree (6/6 pins discriminate),
zero new BLOCKER/MAJOR/MINOR, one new NIT. Closed at round 2.**

**Final counts:** mobile **130/20 GREEN** (three sessions' own runs) ·
core/Mac/spine stand at the S1 finals (this stage's diff verified
mobile-target-only by three independent reads). NO schema; NO core
lines; NO new dependencies.

**The round-2 NIT — PRODUCT-FLAVORED, routed to the author (the gate
bundle's question Q-M1):** `branchDisplayed` under a REFUSED flush (you
typed into a take that a remote lock then froze; the refusal recommends
branching — but the branch mints the store's locked bytes, not your
pending ones, while the card still shows the pending bytes). Nothing is
lost; the window is narrow. Two shapes, hers to pick: **(a)
seed-from-ledger** — the branch copies what the card SHOWS (your pending
bytes become the new take's text; the recommended road just works), or
**(b) refuse-the-door** — branching refuses while a flush is pending on
a locked take, naming the state. (a) reads as the spec-truer shape (the
door's whole point is carrying your work out from under the lock);
neither is built until she rules.

**Ledger:** L3 **DONE** (S2 whole). **The stage-gate bundle is
COMPLETE:** P1–P26 · LK5's ✓-finished rider · the missing-bar-acts note
· Q-M1 above · the feel round (BOTH stages' device items: live
autocorrect/dictation, loupe-under-pan, the sheet's keyboard constraint,
marker z-order, the ~26 pt badge target, the ⑂-drift rider, second-tap
focus). **Stage 3 (the app shape) opens below.**

---

## Stage 3, batch 1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Read first, IN FULL:** `CLAUDE.md` · this file (the rulings M1–M14 +
LK1–LK11, the constitution + application notes, the environment traps,
the S1/S2 records + ladders + closeouts) · the Mac's shelf/library
vocabulary in code (`App/Variorum/Variorum/Features/Library/` — mirror
semantics: `DisplayTitle`, the daily-book door `shelveInDailyJournalBook`
/ `createOrOpenJournalEntry`, `Queries.searchCatalog`, `observeLibrary`;
never port AppKit/SwiftUI-Mac chrome) · `Spikes/MobileMockups/
mobile-look-v1.html` §1 (the RATIFIED shelf shape) + the LK5/LK7
rulings.

**Objective (M7):** the phone gets its real shape — shelf-first home,
Today a button, tabs Shelf · Library — and the Phase 8 capture views
RETIRE.

**Scope, batch 1:**
1. **The shelf home:** books in the live voice (terminal › marker /
   lowercase idioms; study normal — the canon), **LK5 faces: note count
   + tags lead, ✓ finished as a STATE**; pinned books first (the Mac's
   shelf order vocabulary); tapping a book → its note list (chapters
   honored; the Read flow itself is S4's); tapping a note → THE editor
   (S1/S2's Write surface becomes the app's editor — the DEBUG "Write
   S1" door retires with P3).
2. **Today's Entry button** — create-or-open (`createOrOpenJournalEntry`)
   + the shared daily-book shelving door, opening straight into the
   editor (cold launch → typing in two taps).
3. **The tab bar (LK7):** text-only, Shelf · Library, voice-cased.
4. **Library:** everything, newest-first per the standing sort
   vocabulary; search over `searchCatalog`'s existing scope (titles/
   names/scrap prefixes — body search is the future roadmap row, NOT
   invented here); the bookless filter (the Pool's phone home, M7).
5. **The Phase 8 capture views RETIRE** (EntryList/EntryEditor/
   CaptureRouter replaced by the new shape; `SyncSetupView`/status and
   the bootstrap/session shells carry over) — **and the KnownIssues
   iOS-trailing-blank-lines row RESOLVES at this batch's record** (the
   defective surface is gone; the L9 pin guards its replacement; write
   the resolution note for the row per the KnownIssues rule).
6. **The voice switch's real home:** a minimal Settings surface off the
   shelf (P11's placement lands; the masthead door retires or stays at
   the implementer's judgment, recorded).
7. **The walk grows:** cold launch → shelf renders (LK5 faces
   byte-checked) → Today → type → the entry lands + shelves into the
   daily book → Library search finds it → back → the note reopens in
   the editor.

**Explicitly NOT batch 1:** the Read flow (S4), comments/callouts (S4),
divide/merge doors (S4), ⋯/the block menu (S4), reorder within books,
book creation/editing surfaces (Mac-side for v1 — recorded).

**Discipline:** the standing set verbatim (tests with every step; traps
bind; mobile + walks green by own runs + core/Mac/spine only if shared
moves — none expected; NO schema; NO `Sync/` lines; red-on-old for
bug-class fixes; sibling types per the P-9 watch; commit with the
trailer; push at bout end; append your batch record to this file; ONE
Sonnet lookup at a time). Batch 1 closes S3's planned scope — flag
anything the stage ladder must weigh.

## Stage 3, batch 1 — BATCH RECORD (implementer, 2026-08-03; commit `e531f6d` + the record commit)

**All seven scope items shipped.** Per item:

1. **The shelf home** — `Features/Shell/` (a new feature module — eleven
   files, sibling types throughout; no existing VM grew).
   `MobileShelfViewModel` mirrors the Mac `ShelfViewModel`'s cost tiers
   exactly: books + pins + the daily designation ride ONE held
   observation (author-scale); the tags column is a ONE-SHOT
   `refreshTags()` on appearance. **LK5's faces live in a PURE brain**
   (`MobileShelfFaces`, pinned): the meta line is count · tags · daily —
   note count + tags LEAD, the daily marker ranks behind, and **✓
   finished is a STATE riding the NAME** (" ✓" suffix + accent ink — the
   Mac shelf row's own grammar), never a meta stat. Tags display
   LEAF-ONLY (the 13k K3 doctrine; the Mac shelf shows paths — phone
   width demanded the ruling's reading). Order mirrors
   `ShelfViewModel.ordered` SEMANTICS (pins first in pin order, then
   journal-profile by name, then the rest by name). Book names go
   through `tokens.chromeLabel` (terminal lowercases them — the Mac's
   own grammar, the mockup's own look). Tapping a book pushes its note
   list (`MobileBookViewModel` — ONE held observation delivering the
   reading row + assembly coherently, window 300 + probe row so an
   exact-window book never false-positives the truncation marker;
   **chapters honored by grouping on the assembly's OWN section
   transitions** — never a re-sort; section labels show leaves). Tapping
   a note pushes **THE editor** — `MobileWriteScreen` is the app's
   editor now; **the DEBUG "Write S1" door RETIRED** with the capture
   root (the Stage 0 spike's auto-run cover + a manual door SURVIVE — the
   cover at the shell root, the door in Settings — the gate record's
   KEPT deviation honored).
2. **Today's Entry** — `MobileTodayDoor`: create-or-open
   (`createOrOpenJournalEntry`) + the SHARED daily-book shelving door
   (`shelveInDailyJournalBook`) in ONE runner closure — the Mac
   `JournalBooks.openToday` composition; the phone's shelving WORDINGS
   carried byte-for-byte from the retired capture door (every outcome
   points at the Mac; a clean shelving says nothing). The shelf button
   pushes the editor with `focus: true` → `becomeFirstResponder()` after
   `start()` — cold launch → Today → TYPING (interpretation #1).
3. **The tab bar (LK7, shape A)** — text-only Shelf · Library,
   voice-cased via `chromeLabel` (terminal lowercase / study normal),
   hairline top rule, on-ink/off-faint. BOTH tab stacks stay ALIVE
   (opacity-switched ZStack) so each keeps its navigation state; the bar
   renders on tab ROOTS only (pushed screens lose it — the mockup's own
   geometry).
4. **Library** — `MobileLibraryViewModel`: everything via the STANDING
   sort (`observeLibrary` last-touched desc, bounded 200); search =
   `Queries.searchCatalog`'s EXISTING scope, ONE-SHOT per typed query
   with stale-result dropping — **body search deliberately NOT invented,
   PINNED** (`searchNeverInventsBodySearch`: prose containing
   "xylophone" yields zero hits); the bookless filter holds
   `Queries.poolPosts` (the Pool's phone home — derived smart membership
   counts as being in a book, the core query's rule). Hit navigation is
   a pure pinned function: book → book list, post → editor, block → its
   HOME NOTE; **a pool-home block hit renders NO row** (P-2 — no phone
   door exists). Plus the stage-row's **"+ new note" minting door** on
   the Library path line: `createPost(title: nil)` (13g R6-3 — no stored
   placeholder; the K1 display brain shows its day), opened focused; a
   bookless mint lands in the Pool filter honestly (interpretation #2).
5. **The Phase 8 capture views RETIRED** — `Features/Capture/` deleted
   whole (EntryList/EntryEditor/CaptureRouter + their VMs, and `EditCost`
   with them), `MobileRootView` deleted, the app root rewired to
   `MobileShellView`. `SyncStatusRow` (Shared) carries over — its home
   is now Settings; the bootstrap/session shells
   (`AppBootstrap`/`AppServices`/`MobileStoreFailureView`) carry over
   unchanged. `CaptureRouter` is replaced by **`MobileShellRouter`**
   (the same weak-active-editor shape re-pointed at
   `MobileEditorViewModel`, plus the LK2 voice authority);
   `performBackgroundFlush` keeps its extracted-for-tests shape over the
   new editor's `finish()`. **The KnownIssues iOS-trailing-blank-lines
   row RESOLVED and removed** (the resolution note below). **The test
   surface retired with it:** `VariorumMobileTests.swift`'s 14 tests / 4
   suites tested the deleted types; the load-bearing pins are
   RE-POINTED (the mapping in interpretation #5), `SeededGenerator`
   moved verbatim into `MobileEditorTestSupport.swift`.
6. **The voice switch's real home** — `MobileSettingsView` off the shelf
   path line: the two voices (terminal `›` selection marker; study ✓),
   the sync status row, the DEBUG spike door. **The S1 masthead switch
   door RETIRED (P11's placement lands; the implementer's judgment,
   recorded: two doors for one preference was clutter — Settings is the
   deliberate door).** `MobileShellRouter` is the ONE voice authority:
   `setVoice` reaches the stored preference + `MobileEditorStyle` + any
   OPEN surface (`applyVoiceChange`); `MobileWriteScreen`'s chrome reads
   `router.voice` (observable), so an editor open in the OTHER tab
   follows a Settings flip — surface and masthead both.
7. **Walk 7** (`walk7_shelfTodayLibraryColdLaunch`) — cold launch → the
   shelf observes and renders → **LK5 faces BYTE-CHECKED in the live
   voice** ("essays" / "2 notes · #goals" · "poems ✓" · "smart ·
   #books") → Today (day-injected) → the entry shelved into the
   CREATED-AND-PINNED Journal book (`journalMembers == [todayID]`) →
   typed in the REAL TK2 editor (walk-1 surface; identity audit 0,
   desync 0, canary silent) → Library lists it newest-first, search
   finds it by its day (named by the one display brain), destination
   routes to the note → the note reopens in a fresh editor byte-exact.

**Counts, all by this implementer's own runs (iPhone 17 Pro / iOS
26.2):** **full mobile suite 133 tests / 18 suites GREEN** — run green
TWICE (at the build commit, and again after every mutation was
reverted; single runs, zero relaunches; the L9 pin and identity audit
green within every run). Arithmetic against the 130/20 baseline: −14
(the Phase 8 capture tests, retired WITH their surface) + 17 new
(`MobileShellTests` 10 · `MobileLibraryTests` 6 · walk 7); suites −4
(the retired file's) +2. **Core / Mac / spine deliberately NOT run:**
the bout's diff is mobile-target only (`git diff --stat` at commit: 24
files, all under `App/Variorum/VariorumMobile{,Tests}` — zero
`Sources/VariorumCore`, zero `Shared/` sources (the one `Shared/`-named
touch is the TEST-target support file), zero Mac-side, zero pbxproj —
the synchronized-folder pattern absorbed every add/delete), so the
only-if-shared condition never fired.

**Discrimination evidence (no bug-class fixes this batch, so no
red-on-old was owed; the 13k hollow-pin currency applied to the NEW
pins — SIX deliberate mutations, each run against targeted suites, each
caught, the tree byte-restored after each (`git checkout`; final
`git diff HEAD` EMPTY against the batch commit; final full suite 133/18
GREEN):**
- **A — the Today door drops the shelving half** (mint-and-stop, the
  pre-13c defect): **6 issues** — `theTodayDoorJoinsTheDailyJournalBook`
  ×2, `theTodayMintIsNeverBlocked…` ×2 (no Journal minted, no
  membership), walk 7 ×1 (`journalMembers == []`), and
  `theTodayDoorNeverReShelves…` ×1 (its setup throws
  `postNotInReading` — nothing was ever shelved to remove; the same
  honest failure mode the Phase 8 record noted for this pin).
- **B — LK5 regressed** (tags dropped from the meta + "finished"
  prepended as a stat): **7 issues** — `lk5FacesLeadWithCountAndTags`
  ×3, `finishedIsAStateOnTheName…` ×2, walk 7's face byte-checks ×2.
- **C — the bookless filter reads the whole library** (`poolPosts` →
  `Queries.library`): **2 issues** — the shelved note listed; the
  filter never drained. Siblings green.
- **D — the P-2 pool-home filter dropped from search** (`hits =
  found`): **1 issue** — the pool-home block hit rendered a door.
- **E — the background flush drops the editor's `finish()`**: **2
  issues** — stored text stale AND `isDirty` still true.
- **F — `setVoice` never reaches the open surface** (`applyVoiceChange`
  dropped): **1 issue** — the surface kept the terminal mono font under
  a study flip.
- **G — shelf ordering ignores pins**: **3 issues** — the pure ordering
  pin + the observation test's order and (index-shifted) meta checks.

**THE KNOWNISSUES RESOLUTION (the brief's assigned duty — the row
removed from `notes/KnownIssuesAndTechDebt.md` with this note as the
recorded resolution):** *iOS capture editor accrues trailing blank
lines* (9c gate 5, 2026-07-11) is **RESOLVED BY REPLACEMENT, 2026-08-03
(mobile S3 batch 1, commit `e531f6d`)**. The defective surface — the
Phase 8 SwiftUI `TextEditor` capture editor whose live-editor
binding/focus-handoff accrued real stored trailing newlines — **no
longer exists**: this batch deleted `Features/Capture/` whole, and
every phone edit now flows through the S1 Write-true editor
(`MobileEditorViewModel` over the TK2 surface). Its replacement is
guarded in BOTH directions by **the L9 pin**
(`MobileTrailingNewlinesTests`, S1 batch 1 — revert-verified there):
accidental accrual refused (editless open/render/close cycles are
byte-stable and write NOTHING; typing writes exactly the typed bytes),
while MEANINGFUL stored spacing (the 2026-07-12 ruling) round-trips
byte-exactly — never a blanket trim, exactly as the row demanded. The
row's mechanism was never traced on the retired surface (recorded
honestly in the S1 batch-1 record: view-layer, not
headless-reproducible); the resolution is the surface's retirement plus
the pin on its successor, which is what the row's owner (this project)
shipped.

**Interpretations for the cold reviewer:**
1. **"Straight into the editor (cold launch → typing in two taps)"**
   read as focus-on-arrival: the Today door (and "+ new note") push
   `MobileRoute.note(id, focus: true)` and the screen calls
   `becomeFirstResponder()` AFTER `model.start()` — launch → tap Today →
   typing. Ordinary note opens (lists, search) pass `focus: false` —
   reading first is those doors' posture. A sealed note's raise is
   harmless: the gate still refuses and speaks (focus never bypasses
   the police).
2. **The stage-row's "new-note minting"** (named on the S3 stage row,
   not in the brief's seven letters) shipped as the Library "+ New
   Note" door. It mints BOOKLESS (the Mac ⌘N semantics) — the Pool
   filter lists it, which is the honest home until she shelves it.
3. **LK5's exact composition** — count · tags · daily, finished on the
   name: the ruling ranks faces, not strings; word progress, chapter
   counts, and caps are DELIBERATELY ABSENT from the phone shelf
   (each one aggregate away — the corpus-scale `bookWordCounts`
   deliberately never fetched on the phone's home).
4. **Count wording** — journal-profile books say "entries" (the
   ratified mockup's own word), others "notes", both singularized
   ("1 entry") where the Mac's `metaColumn` says "1 notes"; my face
   function, my strings, pinned (P31 — one line to change).
5. **The retired tests' mapping** (14 out, every load-bearing pin
   re-pointed): the A1-class daily-book trio →
   `theTodayDoorJoinsTheDailyJournalBook` /
   `theTodayMintIsNeverBlockedAndCreatesThePinnedJournal` /
   `theTodayDoorNeverReShelvesAnEntryTheAuthorRemoved` (setups and
   assertions carried; the door under test is the new shared-composition
   door); `theListingStaysBounded` → `theListingIsBoundedAndNewestFirst`;
   `theBackgroundTransitionLandsPendingTextInTheStore` → the same-named
   pin over `MobileEditorViewModel.finish` through the new router;
   `observationDeliversOnEntryCreationAndEdit` → the shelf/book/library
   observation tests + walk 7. The capture-EDITOR tests (first-keystroke
   mint, edit-then-flush routing, fanned-block-edits-chosen, sealed
   refusals + keep-pending, the two stale-projection races, `EditCost`)
   retired WITHOUT re-pointing: their CLASSES are the S1/S2 editor
   suites' standing coverage (walks 1–2, the gate/seal pins, the
   projection-policy deferral machinery — the new editor's own
   stale-photograph discipline was the S2 ladder's BLOCKER work), and
   `EditCost` was retired for the new surface at S1 batch 1 by design
   (block-scoped `charDelta`). Flagged for the ladder (flag 1).
6. **Both tab stacks alive** (opacity + `allowsHitTesting(false)` +
   `accessibilityHidden`) so each tab keeps its navigation state; an
   `if`-switch would reset the hidden stack's path.
7. **The shell router is the ONE voice authority** — `MobileShellView`,
   `MobileSettingsView`, and `MobileWriteScreen` all derive chrome from
   `router.voice`; the screen keeps a fallback read for router-less
   (harness/preview) construction, and its init's
   `MobileEditorStyle.voice` set is idempotent under a router.
8. **Mirrored semantics, never Mac chrome** — `ordered()` is
   `ShelfViewModel.ordered`'s algorithm; the meta's count/smart split is
   `metaColumn`'s; smart-book tags decode the spec exactly as
   `tagsColumn` does; book names take `chromeLabel` casing (the Mac
   shelf's own `chromeLabel(reading.name)`).
9. **`Reading.fetchOne` by raw SQL** in the book VM (live-row
   predicate inline) — the same read the shelf query family uses;
   nothing new invented.

**PROVISIONALs (P27–P34, for the stage-gate bundle; numbering continues
S2's):**
- **P27:** Settings' form and placement — the shelf path line's
  trailing "Settings" door; a voiced sheet holding voice rows + the
  sync status row + the DEBUG spike door. **Ambient sync visibility
  retired with the capture root** — the status row's home is Settings
  now (if she misses it at a glance, the 13l sync-status-face candidate
  is the natural door back).
- **P28:** pushed screens keep the SYSTEM navigation back door (inline,
  title-less on the editor; the book list inline) while tab roots hide
  the bar entirely — functional nav chrome; its voice is look-track.
- **P29:** focus-on-arrival rides ONLY the Today and + New Note doors
  (interpretation #1); every other open reads first.
- **P30:** the terminal shelf reserves the selection-marker column for
  alignment but marks NO row at rest (the mockup's `sel` row is a Mac
  selection concept; phone rows are doors).
- **P31:** the count wording (entries/notes, singularized) —
  interpretation #4.
- **P32:** the book list's window (300 + probe) and the truncation
  marker's wording ("Showing the first N notes — the full book lives on
  the Mac").
- **P33:** "+ New Note" placement (the Library path line) and its
  bookless-mint consequence.
- **P34:** the empty-shelf line ("No books yet — Today's Entry starts
  your journal.") and the library's "Nothing found." empty state.

**Deliberate absences (scope, not holes):** the Read flow ·
comments/callouts · divide/merge doors · ⋯/the block menu (ALL S4 by
the brief); reorder within books; book creation/editing/management
surfaces — pin, finish, extents, designation, conversion, drag-into —
stay Mac-side in v1 (the shelf RENDERS their states; recorded per the
brief's "Explicitly NOT"); minting inside a book (Today covers the
daily case; a book's "+ new entry" is unruled for the phone); word
progress on shelf rows (LK5-demoted — interpretation #3); ambient
sync-status chrome (P27); **no SwiftUI-hosting test drives
`MobileWriteScreen`'s `.task` wiring** (router registration,
focus-on-arrival, onDisappear finish) — the router+flush BRAIN is
pinned headless and the wiring is three lines of screen code; the house
harness drives VMs and UIKit views, not hosted SwiftUI (the 13b
machine-verified class; her device round sees the keyboard rise); no
visual inspection of any new surface (the look round over real
screenshots is the instrument); no capability-registry rows (the
standing S1 posture); RTL unconsidered (the standing S2 note's class);
the `.task(id:)` search runs a bounded one-shot per keystroke (the Mac
⌘K discipline) — unmeasured, flagged.

**LADDER-ATTENTION FLAGS (batch 1 closes Stage 3's planned scope — the
stage ladder opens on the S3 diff):**
1. **The retired-tests mapping** (interpretation #5): the ladder should
   weigh whether any retired capture-test CLASS lacks a standing
   equivalent over the new editor — the stale-projection races are the
   sharpest candidates (the S1/S2 deferral machinery + the S2 BLOCKER
   pins are the claimed coverage).
2. **The walk-7 byte-checks encode P31's wording** — a gate re-rule on
   the count words flips the walk's literals (one place).
3. **The screen-wiring absence** (deliberate-absences note): if the
   ladder wants it driven, a UIWindow-hosted UIHostingController
   harness is the shape — weigh cost against the three lines.
4. **The ZStack-alive tab shape** (interpretation #6): two live root
   views at all times — P3-clean (no live editor exists on either
   root), but the ladder should confirm no held-observation
   double-cost concern (both roots' observations run while the app is
   open; all are bounded author-scale).
5. **The Settings sync-row relocation** (P27) — product-flavored if
   she misses ambient visibility; nothing gates on it.
6. **The KnownIssues removal** — verify the resolution note above
   satisfies the rule's letter (resolution recorded at the closing
   batch; the L9 pin + the retirement cited; no sweep, no trim
   anywhere).

**NO `Sources/VariorumCore` lines; NO `Shared/` source lines; NO
Mac-side lines; NO pbxproj lines; NO schema; NO `Sync/` lines** (the
whole diff is mobile-target + this file + the KnownIssues row).
Commits: `e531f6d` (the app shape + retirement + suites) · the record
commit; pushed to `origin mobile` at bout end.

## Stage 3, batch 1 — ACCEPTED; STAGE 3 BUILD COMPLETE — the ladder OPENS (architect, 2026-08-03)

**Acceptance:** verified — scope inspected (mobile-target + this file +
the sanctioned KnownIssues row edit; zero core/Shared/Mac/pbxproj/
schema/`Sync/`), the batch record read, push confirmed, and **mobile
133/18 re-confirmed by the architect's own run** (the −14/+17 test
arithmetic accepted: the Phase 8 tests retired WITH their surface; the
retired-tests mapping is ladder flag 1's to weigh). The KnownIssues
trailing-newlines resolution ACCEPTED (resolved by replacement, the L9
pin cited — the rule's letter: the closing record notes the
resolution). P27–P34 join the gate bundle (now P1–P34). Ledger **L4
DONE**.

**THE STAGE 3 REVIEW LADDER — round 1 (fresh cold reviewer, spawned at
this record):** target = **`2ba90d7..774305e`**; `REVIEW_PROMPT.md`
VERBATIM, zero framing; anchors = the S3 batch record + its six flags
(flag 1 — whether any retired capture-test class lacks a standing
new-editor equivalent, stale-projection races sharpest — deserves the
reviewer's particular weight). Findings repo-first; the same-model flow
holds; hard cap three rounds.

---

## Stage 3 review — round 1 findings (cold reviewer, 2026-08-03)

**Scope of this review, done in-session:** `notes/REVIEW_PROMPT.md` run
verbatim; the FULL combined diff `2ba90d7..774305e` read file-by-file
(all eleven new `Shell/` sources; the `MobileWriteView` /
`VariorumMobileApp` / test-support hunks; the five deleted Capture
sources AND the deleted `VariorumMobileTests.swift` read whole from the
old tree — flag 1's audit demanded the retired tests themselves; all
three new test files in full; the notes hunks), plus the shared code the
new code leans on read at the source (`ShelfViewModel.ordered` /
`ShelfView.metaColumn` / `tagsColumn` · `JournalBooks.openToday` ·
`Queries.searchCatalog`/`poolPosts`/`assembleReading`/`observeLibrary` ·
`AppDatabase.observe`/`read` · `EditorProjectionEngine.decide` ·
`AutosaveCoordinator` · `AppSession.autosave(forPost:)` · GRDB 7's
`DatabaseReader.read` cancellation contract, read in the checkout).
Anchors = the S3 batch record + its six flags, each dispositioned below.
**Counts by this reviewer's OWN run (iPhone 17 Pro / iOS 26.2): mobile
133 tests / 18 suites GREEN** (single run). Core/Mac/spine deliberately
NOT run: my own `git diff --stat` read confirms the stage diff is
mobile-target + this file + the sanctioned KnownIssues row — zero
`Sources/VariorumCore`, zero `Shared/` sources (the one `Shared/`-named
touch is the TEST-target support file), zero Mac-side, zero pbxproj,
zero schema, zero `Sync/`. Read-only per the prompt; no fixes made. No
"Review foci" section exists for this project; the six flags served
that role.

### Findings

**[BLOCKER] · `MobileShellView.swift:68–90` (both tab stacks alive) +
`MobileEditorViewModel.swift:134` (a PER-INSTANCE `AutosaveCoordinator`)
· the S3 shell makes TWO live editors on ONE post reachable, each with
its own autosave pipeline — the constitution's one-live-editor /
one-per-post-coordinator law has no enforcement on the phone, and the
reachable outcome is permanent text loss.** Mechanism, traced: (1) both
tab stacks stay alive by design (opacity-switched; interpretation #6),
and each can hold a pushed `.note` — the SAME post is reachable from
both (Today's entry via the shelf button; the same entry is the Library
listing's newest row; nothing anywhere deduplicates or arbitrates). A
hidden stack's pushed `MobileWriteScreen` never fires `onDisappear`
(opacity is not removal), so its editor stays fully live: TK2 view,
observations, ledger, coordinator. (2) `MobileEditorViewModel.init`
mints its OWN `AutosaveCoordinator` instead of the session's per-post
door — `AppSession.autosave(forPost:)` (`AppSession.swift:86`) exists
precisely because "TWO debounced pipelines could run over one post at
once … and flush a stale buffer OVER a newer one — the ordering was
luck" (N3, 13b 1a), and this plan's own constitution carries the phone
reading: *"both kinds consult the ONE authority and the ONE per-post
autosave coordinator"* and *"ONE live editor per the P3 invariant — the
phone gets no second liveness mechanism"* (Binding principles, P-3
application). (3) The loss: open post X in the shelf tab (editor A) and
in the Library tab (editor B). Type into A; switch tabs within A's
debounce (500 ms — or while its flush is in flight) and type into B. B's
surface never saw A's text (it lives only in A's coordinator), so B
records the whole-block text from its own pre-A base; A's flush lands
W_A, then B's flush overwrites it with a text that never contained A's
edit — A's typing is PERMANENTLY gone from `working_text`, no commit, no
conflict variant, and the user was looking at B the whole time.
Type-swipe-type with real fingers reaches this (the S2 BLOCKER's own
reachability standard). Note honestly: the init line PREDATES this diff
(S1 batch 1) — at S1/S2 exactly one editor could exist, so the shape was
harmless; THIS diff's shell is what makes two simultaneous editors
reachable, which is why it lands here. Note also that adopting
`autosave(forPost:)` alone is NOT sufficient: with one coordinator, B's
whole-buffer record still replaces A's pending entry from a stale
surface base — the real fix is the Mac's OTHER half too, one live
editor per post (a registry/authority that prevents or hands off the
second live surface; teardown-or-refresh on tab re-entry is the cheapest
honest shape). Red-on-old pin: two VMs on one post headless, type in
both within the debounce, flush both, assert the store holds the later
surface's base INCLUDING the earlier edit — red on old.

**[MAJOR] · `MobileShellRouter.swift:33` (single-slot `activeEditor`) +
`MobileWriteView.swift:81,92` (register-once/deregister-on-pop wiring) ·
the background flush covers only the most recently REGISTERED editor —
the exact Phase 8 review-round-2 protected class ("a background kill
lost it silently") resurfaces for any second open editor.** Mechanism,
traced: `.task` sets `activeEditor = model` once per screen lifetime
(never re-fires on tab re-entry — the view never disappears), and
`onDisappear` nils it only when the popping screen IS the registered
one. Two arms: **(a)** editor A open on the shelf stack, editor B opened
later on the Library stack ⇒ `activeEditor == B` forever after; switch
back to the shelf, type into A, press home within A's debounce —
`performBackgroundFlush(editor: B)` flushes a clean B and A's pending
burst dies with the suspension. **(b)** open A, open B, pop B ⇒
`activeEditor == nil` while A sits open and dirty — the flush covers
nothing at all. The re-pointed pin
(`theBackgroundTransitionLandsPendingTextInTheStore`) drives ONE editor
and cannot see either arm. Same root as the BLOCKER: the router's
single slot doesn't model two alive stacks. Proposed fix: registration
becomes a SET (register on appear, deregister on disappear, flush ALL —
or fall out of the BLOCKER's one-live-editor authority, which collapses
the set to one by construction). Red-on-old pin: two registered-then-
one-popped sequences at the router level, assert both stores after
`performBackgroundFlush` — red on old in both arms.

**[MAJOR] · `MobileWriteView.swift:82–88` · focus-on-arrival is DEAD
CODE — `await model.start()` never returns while the editor lives, so
the Today door's "straight into typing" (brief scope item 2's letter:
"cold launch → typing in two taps") does not function; the keyboard
never rises.** Mechanism, traced: `MobileEditorViewModel.start()`
(`MobileEditorViewModel.swift:178–183`) is `withTaskGroup` over TWO
infinite observation loops (`observeHeader` / `observeTakesProjection` —
`for try await` over held observations that end only at cancellation),
and `withTaskGroup` returns only when all children finish — so
`if beginEditing { model.textView?.becomeFirstResponder() }` is
unreachable until the `.task` is CANCELLED, i.e. it runs (as a no-op) at
view teardown. The S1 screen had nothing after the await; this diff
added the focus call behind it. The batch record's interpretation #1
describes the intended behavior as shipped; it is machine-unverified by
the recorded screen-wiring absence (flag 3) and does not work. Proposed
fix: run `start()` unstructured (`Task { await model.start() }` owned by
the screen, cancelled in `onDisappear`) or as its own `.task`, and raise
focus after `loadOnce()`/first render settles; extract the arrival
routine so it is pinnable. Red-on-old pin: a UIWindow-hosted screen (or
the extracted arrival function over a windowed view — the
`beginEditingRaisesKeyboardFocusOnTheCardEditor` harness pattern),
assert first-responder after arrival — red on old.

**[MAJOR] · flag 1's audit — `EditorProjectionEngine.decide`
(`Shared/EditorBrain/EditorProjectionEngine.swift:129–141`) +
`MobileEditorViewModel.applyProjection/applyDifferential` · the retired
`StaleProjectionTests` guaranteed more than the standing coverage does:
the Phase 8 surface NEVER adopted a delivered value ("every delivery is
only a signal; the authoritative application is a FRESH read stamped
with `readGeneration`" — the deleted VM's own header), while the new
editor adopts a CLEAN-INSTANT delivery directly — a stale photograph
consumed after a newer flush regresses the surface AND the ledger, and a
keystroke in that window flushes stale-based text over the newer store
text (the retired text-loss pin's forbidden class).** Mechanism, traced:
a delivery fetched before flush W2 can be CONSUMED after `flushNow()`
returns and `isDirty` clears (the observation loop's continuation and
the flush continuation are unordered on the MainActor; GRDB orders
deliveries only against each other). At that instant
`EditorProjectionPolicy.decide(busy: false, matchesSurface: false —
the ledger holds W2's text, sameSequence: true)` → `.differential` →
`applyDifferential` rewrites the block's surface text to the stale bytes
AND `ledger.adopt(new)` overwrites the surface's truth record; a
keystroke before the healing delivery builds on the stale base and its
flush clobbers W2 (then `applyPendingIfClean`'s fresh read faithfully
adopts the damage). The stale-EMPTY analog: `sameSequence` false →
`.fullRender([])` blanks the just-minted surface; typing in the gap
re-mints — the retired double-mint pin's class in the new shape. The
standing pins cover the BUSY path only
(`aDeliveryWhileDirtyDefersUntilSettleThenAppliesFresh`,
`anAutosaveEchoNeverRewritesTheSurface`); no pin drives a stale
non-matching delivery at a clean instant. Two honest calibrations: the
window is delivery-latency-sized (ms, scheduler-dependent — narrower
than the S2 BLOCKER's user-extendable window), and the Mac editor
shares this policy shape, so the exposure is plausibly shared — which
argues for a policy-level treatment (a freshness/generation guard on
clean-instant adoption, the retired VM's own pattern), not a mobile-only
patch; that routing is adjudication's (a `Shared/` change fires the
core/Mac verification duty). Red-on-old pin, deterministic regardless
of scheduler: capture `model.slots` pre-edit, edit + `flushNow`, then
drive `applyProjection(stalePhotograph)` directly (the retired pins' own
drive shape) and assert surface AND ledger keep the flushed bytes — red
on old.

**[MINOR] · `MobileLibraryViewModel.swift:100–113` (`search`'s catch) ·
a cancelled in-flight search surfaces as a PERSISTENT red error line —
the catch lacks the `CancellationError` filter its own siblings have,
lacks the staleness guard the Mac's search catch has, and `lastError` is
never cleared on success.** Mechanism, traced: `.task(id: query)`
(`MobileLibraryView.swift:50`) cancels the in-flight search on every
keystroke and on the root's disappearance (a pushed route covers it);
GRDB 7's async `read` throws `CancellationError` when the task is
cancelled (`DatabaseReader.swift:216`, read in the checkout); `search`'s
`catch` sets `lastError = String(describing: error)` with no
`catch is CancellationError {}` arm (compare `startAll`/`startBookless`
lines 67/83 in the SAME file) and no `activeQuery` guard (the Mac's
`LibraryCatalogView.swift:68–71` guards its catch by generation AND sets
`lastError = nil` on success); nothing ever clears it, so the red line
sits under the Library until another error overwrites it. Proposed fix:
the sibling filter + guard the catch on `activeQuery == trimmed` + clear
on success. Red-on-old pin: cancel a wrapping task before `search`
lands, assert `lastError == nil` — red on old.

**[MINOR] · `MobileShellRouter.swift:53` (`setVoice` →
`activeEditor?.applyVoiceChange()`) · the voice flip restyles only the
REGISTERED editor's storage — a second open editor keeps the old voice's
fonts/ink under a new-voice masthead until reopened.** Mechanism: same
single-slot root as the MAJOR above — with editors open on both stacks,
only `activeEditor` gets `applyVoiceChange()`; the other's chrome
follows `router.voice` (observable) while its TK2 storage attributes
stay in the old voice — a mixed-voice surface the record's claim ("an
editor open in the OTHER tab follows a Settings flip — surface and
masthead both") does not cover; the pin drives one editor. Collapses
with the registration-set (or one-live-editor) fix; recorded so the fix
is verified against TWO editors.

**[NIT] · `Theme/MobileVoicePreference.swift:17–18` · the header's
PROVISIONAL-placement note is now stale** — it still says the switch
door "currently rides the Write masthead; its real Settings home is
S3's", and this batch executed exactly that move. One comment edit.

**[NIT] · `MobileBookView.swift:68` vs `MobileShelfFaces.name` · one
face, two spellings** — the book header renders
`chromeLabel(reading.name) + (locked ? " ✓" : "")` while the shelf
renders `chromeLabel(name + " ✓")`; identical bytes today (casing never
touches "✓"), but the finished-state grammar lives in `MobileShelfFaces.
name(for:)` and the header should call it rather than respell it.

### The six ladder-attention flags, dispositioned

1. **The retired-tests mapping — PARTIAL; one class-gap found (the
   MAJOR above).** Audited test-by-test against the deleted file read
   whole: the A1-class daily-book trio re-pointed faithfully (setups and
   assertions compared side-by-side — carried, with the #37(iii)
   wording-checks extended by `.wrongKind`); the bounded listing →
   `theListingIsBoundedAndNewestFirst` (faithful, adds newest-first);
   the background-flush pin → same-named over `finish()` (faithful for
   ONE editor; see the MAJOR for what it cannot see); the observation
   test → shelf/book/library observation tests + walk 7 (covered);
   first-keystroke-mint/no-double-mint → walk 2 +
   `typingPastAParagraphCrystallizes…` +
   `aJournalEntryMintsExactlyOneBlock…` (covered);
   edit-then-flush-right-variant →
   `aBlockEditAutosavesExactlyItsVariant…` (covered); fanned-block-
   edits-chosen → the S2 suites
   (`typingIntoAPeekedBlockEditsThePeekedTake`,
   `cardEditsRouteToTheEditedTakeOnly`, walk 5) (covered); the sealed
   pair → `aSealedNoteRefusesEveryEdit` (gate) + the shared
   coordinator's Mac pins (`oneRefusalNeverDropsASiblingsSave`,
   `newerTypingSupersedesAFailedEntry`) + S2's
   `aRemoteLockMidCardEditRefusesTheNextKeystrokeAndKeepsPendingText`
   (covered piecewise; the exact remote-SEAL-mid-typing composition is
   unpinned mobile-side but every mechanism in it is); `EditCost`
   retired by design at S1 (recorded, accepted). **The gap: the two
   `StaleProjectionTests` — their CLEAN-INSTANT guarantee (deliveries
   are signals, adoption only from generation-checked fresh reads) is
   not carried by the new editor or its pins**; the claimed standing
   equivalent covers the busy path only. The mapping's claim is
   therefore overbroad by exactly this class.
2. **Walk-7 byte-checks encode P31 — confirmed, acceptable.** The
   wording lives in ONE brain (`MobileShelfFaces.meta`) + the walk's
   literals; a gate re-rule flips one function and a handful of test
   strings. No action.
3. **The screen-wiring absence — NOT acceptable as-is.** The "three
   lines of screen code" now carry real policy (who is the active
   editor; when focus rises), and TWO of this round's findings (the
   registration MAJOR, the dead-focus MAJOR) plus the BLOCKER's
   reachability live exactly in that unverified wiring. Verdict: the
   fixes should pull the policy into a testable brain (a registration
   set / arrival routine), after which the wiring is genuinely thin and
   the absence is honest again.
4. **The ZStack-alive tab shape — fetch cost fine; the flag's framing
   missed the real hazard.** The double-observation cost is bounded and
   author-scale (shelf: tiny held snapshot; library: the documented
   bounded top-200 — worst case one bounded re-fetch per autosave
   flush while hidden; `AppDatabase.observe`'s "on-screen projections
   only" letter is technically deviated, at recorded author-scale). But
   "no live editor exists on either ROOT" was the wrong question:
   pushed screens stay alive too, and that is the BLOCKER's mechanism.
   Verdict: cost accepted; the liveness consequence goes to the
   BLOCKER's fix.
5. **The Settings sync-row relocation (P27) — product-flavored, nothing
   gates.** Correctly PROVISIONAL in the gate bundle; the 13l
   sync-status-face candidate is the recorded door back if she misses
   ambient visibility. No action.
6. **The KnownIssues removal — the rule's letter is satisfied and the
   resolution is honest.** Exactly one row removed (verified in the
   diff); the owner was this project (re-owned 2026-07-25); the
   resolution note is recorded at the closing batch's record with the
   mechanism-never-traced admission kept rather than papered over; the
   L9 pin covers BOTH directions against the successor editor (all five
   `MobileTrailingNewlinesTests` read: accrual refused byte-stable,
   meaningful spacing round-trips, neighbor edits never touch stored
   spacing — never a blanket trim). Accepted.

### Counts (this reviewer's own runs)

- **Mobile: 133 tests / 18 suites GREEN** (iPhone 17 Pro / iOS 26.2,
  single run, zero relaunches — matches the batch record and the
  architect's acceptance run). The −14/+17 arithmetic re-verified
  against the deleted file (6+5+2+1 out; 10 shell + 6 library + walk 7
  in; suites −4 +2 = 18).
- Core / Mac / spine: deliberately not run (mobile-target-only diff,
  verified by my own diffstat read; no finding required a shared-code
  run to trace — the `EditorProjectionEngine` reading implicates shared
  DESIGN but the diff carries zero shared lines).

### Clean bill (load-bearing things specifically checked, found solid)

- **The Today door's composition** — both halves in ONE runner closure
  (`MobileTodayDoor.open`), byte-mirroring `JournalBooks.openToday`
  including the round-2 designation-read-inside-the-runner discipline;
  the shelving wordings carried byte-for-byte from the retired door
  (diffed by eye against the old tree) with every reportable outcome
  speaking and the clean path silent.
- **`MobileShelfFaces.ordered`** — line-compared against
  `ShelfViewModel.ordered`: byte-equivalent semantics (pins in pin
  order, journals by name, rest by name).
- **LK5's faces** — count · tags · daily with finished-on-the-name
  matches the ruling and its rider; the count/smart split matches the
  Mac `metaColumn`'s (smart books never show a derived count); tags
  leaf-only per 13k K3; word progress/chapters/caps deliberately absent
  (interpretation #3, coherent with LK5's ranking).
- **Search scope not widened** — `searchCatalog` untouched; the
  never-invent-body-search pin is real (prose "xylophone" yields zero);
  the P-2 pool-home filter is enforced twice (VM filter + pure
  `destination`), both pinned.
- **The bookless filter** — `Queries.poolPosts` exactly (derived smart
  membership counts as in-a-book; empty-spec rule rides free); the
  drain-on-shelve path pinned live.
- **The book list** — ONE held observation delivering reading row +
  assembly coherently; window 300 + probe row (the Phase 10 discipline,
  no exact-window false positive); chapters grouped on the assembly's
  OWN section transitions (pure, pinned) — never a re-sort; section
  labels leaf-only; row names through the ONE display brain (13k K1),
  pinned for the nameless-date case.
- **The re-pointed pins** — setups and assertions carried faithfully
  (the Today trio, the bounded listing, the background flush for the
  single-editor case).
- **Walk 7** — drives the REAL TK2 surface (identity audit 0, desync 0,
  canary silent), byte-checks LK5 faces in the live voice, verifies the
  created-and-pinned Journal shelving, search-by-day through the one
  display brain, and byte-exact reopen.
- **The voice authority's single-editor path** — `setVoice` is
  MainActor-atomic end-to-end; preference + `MobileEditorStyle` + open
  surface verified against real storage fonts in the pin; the screen's
  router-less fallback is init-idempotent under a router.
- **`.post` search hits can never route a POOL into the editor** —
  `searchCatalog`'s post arm is `kind = 'post'` only (read at the
  source); pools reach the phone only as filtered-out block homes.
- **Scope discipline** — zero core/Shared-source/Mac/pbxproj/schema/
  `Sync/` lines in the diff (own diffstat read); the synchronized-folder
  pattern absorbed every add/delete; `SeededGenerator` moved verbatim.
- **The KnownIssues resolution** (flag 6 above) and the L9 pin's
  bidirectional coverage.

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
