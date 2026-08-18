# Phase 13j — Deletion, the Trash & the recovery story (A USABILITY PHASE)

**Status: OPEN — launched 2026-08-18 (same day as authoring) via
`/architect-phase`; the author-attended OPENING DESIGN SITTING is IN
PROGRESS (run record at the bottom of this file); cast confirmed at
the sitting. Authoring provenance: written 2026-08-18 at her
instruction, the morning after 13e closed ("go ahead and make
writing the 13j plan next the next priority and just fold in the
mini round… once all my extra comments are recorded… I'll just
launch the 13j plan").**

## HER MANDATE (verbatim-faithful — this phase's emphasis)

> "emphasize in the 13j plan that it's a useability focused plan and
> an html mockup can be made to ask my opinion on at the start if
> needed or the question tool can be used. this is shoring up a
> major gap."

> "I think it's a bad sign if I'm confused or find the app
> unintuitive or frustrating because then other people have little
> hope."

The bar, stated plainly: **at this phase's end, deleting things —
blocks, notes, takes — and getting them back is obvious, honest, and
calm.** Every refusal diagnoses; every receipt tells the truth about
where things went; every recovery surface answers "which note was
this from?"; and the tutorial walks the whole story. The friction
doctrine (P-5) binds hard: her three morning-after reports ARE the
repeated-pushback signal — design memos before contested builds.

## Kickoff message (paste-ready for the orchestrator she invokes)

> You are running Variorum Phase 13j under the shape the author
> picks at kickoff (`/architect-phase` has run every phase since
> 13c; confirm the cast, never assume). Read IN FULL first:
> `CLAUDE.md` + the canon it loads (AppSpec §14's 13e delta is the
> latest state), this plan TOP TO BOTTOM, the 13e plan's
> "Environment traps" section (binding, as every phase — it carries
> both 13g standing rules and the kills-by-PID-only sharpening),
> the 13e plan's "POST-CLOSE LIVE REPORTS" section (her verbatim
> reports are this phase's founding evidence), and the KnownIssues
> "Tombstone GC" row (J1 designs WITH it — one design, never two).
> Copy the P-1…P-9 constitution into this file verbatim if running
> under `/architect-phase`. Verify the baselines with your own runs
> (13e finals: core 1254/135 · Mac 1413/256 FULLY GREEN — zero
> allowed reds · mobile 314/60 · spine 51/7). **OPEN WITH THE
> AUTHOR-ATTENDED DESIGN SITTING** (the agenda below) — her mandate
> invites an HTML mockup or the question tool for the taste calls;
> nothing schema-shaped builds before her rulings there.

## Goal

Deleting actually gets rid of things — safely, visibly, and
understandably. The recovery story becomes a story: one per-note
tray, one honest global surface, a Trash with a clock, refusals
that diagnose, receipts that tell the truth, and a tutorial that
teaches all of it.

## THE LEDGER

**Her standing 13j items (from the master plan's row, verbatim-faithful):**

| # | Item | Source |
|---|------|--------|
| J1 | **The Trash / true delete for notes.** Her words (2026-08-01): "some kind of 'true delete' should be added for posts (going to a Trash for 30 days before really deleting), because I already have posts in my library i don't want to have. that seems like an obvious pre-ship feature." The 30-day-then-really-delete half IS a physical purge — design WITH the Tombstone-GC KnownIssues row (sync-aware horizon: purge never strands a peer; all devices past the seq); S2 (deletes are tombstones) bends only by that design, never a shortcut. A GC/purge design that firms toward schema or a §12 lockstep event is a STOP for her explicit go | her 13g round-5 instruction |
| J2 | **The per-note deleted/archived-blocks tray — the FACE.** Her words (2026-08-01): "you need to be able to see the archived blocks (or deleted blocks) that are associated with a particular post, because just going to the library you get a little lost." Sharpened 2026-08-18: TODAY NO surface anywhere lists deleted blocks — `restoreBlock`/`last_container_id` are faceless ops, so past the session's ⌥⌘Z window a deleted block is unreachable by any click, while the shipped receipt copy CLAIMS "they wait in this note's deleted-blocks tray." The tray face is the fix; the copy tells the truth the moment it exists | her ruling + the 13e post-close trace |
| J3 | **The lineage door to unplaced originals.** Her words (2026-08-03): "there needs to be some way to see unplaced blocks from a block that was derived from them" — the divide-W/merge released-original case: a door ON the successor block to its unplaced original, not only the global list. (The 13f W10b reveal-marking exists; the DOOR grammar is this row's) | her mobile-gate ruling |
| J4 | **The Mac divide-default flip + the deliberate ceremony door.** Her 2026-08-03 ruling: the DEFAULT divide on a fanned block becomes her duplicate shape (`divideDuplicating` — the core op shipped at mobile parity Stage A, DORMANT on the Mac since); the W ceremony demotes to a summonable OPTION — and her explicit follow-up binds the shape: the Mac keeps a DELIBERATE door ("divide with ceremony" or similar) AND a keybind; never only a buried menu item | Q-M2's Mac half |
| J4b | **The Mac adopts the CARRY-ALL MERGE as its quick fanned-merge default** (her 2026-08-09 ruling): one pairing of the two displayed takes + every other active take carried whole — composed from the Mac's own `mergeCeremony`, zero core change; the pairing ceremony demotes to a deliberate door + keybind exactly like J4. The phone's C5 implementation is the reference | her post-parity ruling |
| J5 | **The restoration-doors design sitting** (her 2026-08-03 instruction): where the doors to restore archived/deleted things live GENERALLY — and one door already ruled: when a saved lens's pick dangles at an archived/deleted take (`effectiveLensSelection`'s read-time fallback), the Mac must "say loudly if that take was archived and this is a fallback WITH a button for quick restore" | her mobile-gate ruling |

**Her 2026-08-18 morning-after additions (the founding reports — verbatim in the 13e plan's POST-CLOSE section):**

| # | Item | Source |
|---|------|--------|
| J6 | **The "graveyard" redesign — the unplaced-blocks view.** Her words: "what is that cursed table of lost hopes and dreams? if a user ever gets there (which I'm wondering if they should at all tbh), there should at least be a button to see it in the context of the post it was deleted from (i.e. open the post and open the tray of deleted items in that post). why are we even offering to auto add deleted blocks to the snippets pool? it doesn't make that much sense to me." The sitting rules: whether the surface survives at all; per-row CONTEXT (which note it came from + open-there); the pool-add door's fate; sorting/grouping (her report: "all unsorted"). FACT for the design: the rows are LIVE unplaced blocks (divide-W/merge released originals), NOT deleted blocks — the surface conflating the two in her reading is itself the finding. Also: how she REACHED it is unreproducible to her ("I've been trying to recreate whatever got me there… I just can't") — the roads in (Library toolbar → Archived & Deleted; the W10b lineage reveal) get named in-product and in the tutorial, or the surface goes | her 2026-08-18 reports |
| J7 | **The ⌘Z→⌥⌘Z hint (her ruling, 2026-08-18): "if a user is spamming command z, i think it should prompt them to do a structural undo if it's not doing a regular undo."** Shape: plain ⌘Z with nothing to undo in the text while the structural stack holds entries → the status line speaks ("Nothing to undo in the text — your last change was structural: ⌥⌘Z undoes it, ⇧⌥⌘Z redoes."); the key is never consumed; the two stacks stay canon-separate (2026-07-04) | her ruling — the folded mini-round |
| J8 | **Receipt & refusal COPY TRUTH.** (a) The multi-delete receipt/help stop naming the nonexistent tray until J2 exists — then name it and its real door. (b) `.crossesBlockBoundary`'s refusal stops GUESSING ("a locked take, unsynced text, or text that isn't a block yet") and DIAGNOSES the actual blocker per-refusal (the enum-dump family one level up). Her screenshot report: "the reason is really unclear to me why right now" | the folded mini-round |
| J9 | **Whole-block-selection delete routes to the delete compound.** Her screenshot: selecting ONE whole paragraph + delete REFUSED. Traced (13e post-close): the selection includes the inter-block seam → the edit reads cross-block → the Phase-11/13d compound declined eligibility (likely the open tail or the ends-at-block-start edge — ONE precise trace owed first). The fix: a selection covering exactly N whole blocks becomes the batch-4 delete compound (ONE ⌥⌘Z-undoable entry — with J7's hint, discoverable); the text-edit road never refuses that intent again. Her words: "what kind of writing app won't let you delete a paragraph?" If the trace surfaces more edges: the P-5 design memo form before building | her report — the folded mini-round |
| J10 | **The tutorial's deletion chapter — a real overhaul.** Her instruction: "the tutorial also needs to be updated more throughly in 13j to encourage users to delete blocks during the tutorial, it should have a clearly reproducable path to that table of doom if it still exists (which it might idk why it even does), guide users through cross block deletion, restoral, etc." Also her standing report: "the tutorial's actual content is still out of date because the tutorial doesn't make enough sense about it to me." Tutorial-as-spec (P-6) binds: the new chapter's flow becomes walk-asserted like every happy path; the Restore-Tutorial re-seed rides the closeout ritual | her instruction |
| J11 | **The auto-commit cadence question (design sitting).** Her observation: "I haven't been seeing auto commits in the history… there should be autocommits in the history at some cadence, even if just when the note is closed or when it's edited. or are commits staying only a deliberate thing? … unless you've been remembering to commit version history is kind of weak right now." THE CURRENT CANON, for the sitting's table: commits are deliberate (⌘S) plus FIVE quiet auto occasions — post-seal, locking a dirty take, the 24-HOUR idle timer (`idle_commit_hours`, wired via `IdleCommitScheduler`), structural-undo divergence insurance, bridge landings. The everyday cadence is therefore the 24h idle one — which is exactly why her history looks thin. The sitting rules the cadence she wants (candidates: on-note-close · per-N-edits/churn-threshold · a shorter idle default · daily) — commit VOLUME vs history LEGIBILITY is the tradeoff to put in front of her (auto rows are `kind:'auto'`, visually quiet and prunable by design). Zero schema either way; `idle_commit_hours` is already a setting | her 2026-08-18 question |

## THE OPENING DESIGN SITTING (author-attended; agenda)

1. **The Trash design (J1)** WITH the GC horizon — one design: what
   enters the Trash (notes; blocks?), the 30-day clock's face, what
   "really delete" means under sync (the horizon rule), what S2's
   bend looks like precisely. STOP-class: anything schema/lockstep.
2. **The recovery map (J2/J3/J6)** — one coherent story for: the
   per-note tray (where it lives: the note's context bar? the block
   menu?), the global surface's fate and its per-row context door,
   the lineage door's grammar. **An HTML mockup of the recovery map
   is the invited artifact here** (her mandate) — or question-tool
   batches; her taste rules before build.
3. **The defaults flip pair (J4/J4b)** — the divide + merge quick
   defaults and their ceremony doors/keybinds (her rulings are
   made; the sitting confirms door wording + keybinds only).
4. **The restoration doors generally (J5)** + the ruled lens
   fallback loudness.
5. **The auto-commit cadence (J11)** — her pick from the candidates
   table.
6. Scope confirmation + cast confirmation (the standing steps).

## Binding constraints

- The P-1…P-9 constitution (copy in verbatim at kickoff under
  `/architect-phase`); the registry grows with every new door.
- **S2 bends only by J1's ruled design** — purge never strands a
  sync peer (the horizon rule); tombstones remain the only delete
  everywhere else. Any schema or §12 lockstep need is a STOP for
  her explicit go, mirror-first as always.
- Restore surfaces stay honest through the Trash window (the master
  plan row's own verification line).
- The 13e Environment traps section binds verbatim (both 13g
  standing rules + kills-by-PID-only); Mac tests via the
  cwd-independent `-project` invocation; suite selection by TYPE
  name with the count line confirmed.
- Zero `Sources/VariorumCore/Sync/` lines without the standing
  rider; the hallucination guard absolute (red-on-old by behavioral
  revert with checksums; J9's trace before its fix).
- Every PROVISIONAL → `notes/QUESTIONS.md` (next free number:
  **#66**).
- The tutorial spine green every batch (P-6); J10's new chapter
  joins it; the closeout re-seeds the field guide via the product
  door behind the A1 rail.

## The P-1…P-9 constitution (copied VERBATIM at kickoff 2026-08-18, per the `/architect-phase` rule; provenance `notes/plans/phase-13b-make-it-work.md` — phase-specific names inside are the rules' worked examples, kept as written; the rules are general and BINDING here)

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

*(The "Applying the constitution" precision notes bind by reference:
`.claude/skills/architect-phase/SKILL.md`.)*

## Baselines at open (verify with your own runs)

The 13e finals: core **1254/135** · Mac **1413/256 — FULLY GREEN,
zero allowed reds** (any red is the batch's to explain) · mobile
**314/60** · spine **51/7**. No schema since v1_12; mirror at
lockstep marker **6**.

## Verification

Per-batch: the standing loop (build → red-on-old pins → the spine
green by TYPE name → full suites with counts quoted; mobile when
`Sources/`/`Shared/` is touched — iPhone 16e). Review shape: the
author sets it at kickoff. **13j's closeout authors the next
phase's plan at her pick** (the standing ritual), writes the
MobileSoul parity line (J4/J4b change Mac defaults the phone
already has — likely "nothing mobile-visible NEW"; the tray/Trash
faces may owe phone twins — the closeout's call), and runs the full
closeout ritual including the `/Applications` refresh at her
authorization.

---

## RUN RECORD

### Kickoff (2026-08-18) — the opening design sitting, author-attended

Orchestrator: Fable under `/architect-phase`, at her invocation.
Mandatory reading done IN FULL before the sitting (CLAUDE.md + the
canon it loads; this plan top to bottom; the 13e plan's Environment
traps + POST-CLOSE LIVE REPORTS sections; the Tombstone-GC
KnownIssues row). Constitution copied in verbatim (section above).
Kickoff environment facts: **her real-store instance is LIVE (PID
13761, `/Applications` path — by STORE: never touched; no Release
builds or `/Applications` refreshes this session without a
sanctioned zero-instance window)**. Baselines: the core suite
launched at kickoff (19:27 UTC, background — result recorded when
it lands); the Mac/spine suites run at the sitting's first natural
break so the test host's windows don't flash over her live sitting
— both before any build work, either way.

**Her opening note (verbatim):** "I will add as a note that i'm
here for the design sitting. let's answer all the questions that
are open first and from a usability and app beauty and ease
perspective.  unplaced blocks sound like they need rethinking in
general? I also think that I do need to talk about the pros and
cons of the J11 questions, especially in how much storage it might
take up depending on the cadance and if it should be a user
setting."

Sitting order set from her note: the recovery map leads (J2/J3/J6
— her unplaced-blocks rethink) together with J11's pros/cons
(storage-by-cadence + the user-setting question, analysis put in
front of her before the ask); then J1 (the Trash WITH the GC
horizon), J4/J4b door wording + keybinds, J5, the J7–J10 fold-in
confirmation, scope + cast confirmation.

*(Her rulings land below, verbatim-faithful, the turn they happen.)*
