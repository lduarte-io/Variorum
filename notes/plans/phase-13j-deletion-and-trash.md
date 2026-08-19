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

## Environment traps (13j's binding copy — the 13e text verbatim with the phase-specifics tail updated; every batch brief carries THIS section)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH (the DerivedData test host matches mid-run;
`/Applications` = hers/real-store); real-store instances by STORE,
not path — **NEVER quit/kill one, and NEVER address a Variorum
instance by PROCESS NAME: bundle id (`io.lduarte.Variorum.debug`)
or PID only** (the 13g batch-1 incident's standing rule); no
Release builds or `/Applications` refreshes while a real-store
instance lives (one was LIVE at the 13j kickoff, PID 13761 —
re-check, never assume); Mac suites DO run beside her live app
(the Debug host's container holds the seeded design corpus); **Mac
test runs use the cwd-independent `-project` invocation** (the
second 13g standing rule): `xcodebuild test -project
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
author rule). **13j specifics:** the Mac suite is FULLY GREEN
since 13e — **ZERO allowed reds** (the A47c tripwire era ENDED at
the 13e disposition; any red is the batch's to explain);
`PoolDragTests` reads the physical ⌥ key — a real keypress during
a suite run can flake it (13k record); her real-store app was live
at kickoff and the sitting ran beside it — re-check instances
before any Release/install act.

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
launched at kickoff (19:27 UTC, background) — **VERIFIED GREEN:
1254 tests / 135 suites passed (33.9s), the 13e final exactly**;
the Mac/spine suites run at the sitting's first natural break so
the test host's windows don't flash over her live sitting — both
before any build work, either way. **Mac suite VERIFIED GREEN
post-sitting: 1413 tests / 256 suites, TEST SUCCEEDED (192s) —
the 13e final exactly, fully green, zero reds; the tutorial
spine's suites (`TutorialWalkTests.swift` types) ran green INSIDE
that full run — verified by inclusion** (batches still quote the
spine separately by TYPE name per the standing loop). Mobile
baseline launched from the MAIN tree (the `mobile` worktree
branch sits behind main since 13e landed on main; scheme
`VariorumMobile`, iPhone 16e sim) — **VERIFIED GREEN: 314 tests /
60 suites, TEST SUCCEEDED (23.5s), the 13e final exactly. ALL
FOUR BASELINES VERIFIED by the orchestrator's own runs.**

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

### Sitting round 1 — recovery map + J11 (2026-08-18)

- **J2 tray home RULED: the note's context bar + ••• menu** — her
  pick of the recommended shape: a quiet door in the note's own
  chrome, visible ONLY when the note has deleted/archived blocks
  (e.g. "⌫ 3"); opens a tray panel with per-row first-line preview,
  when it went, and Restore. Calm at rest.
- **J11 cadence RULED: on-note-close + shorter idle backstop** —
  every editing session that changed a note leaves one quiet
  savepoint (`kind:'auto'`) per edited take at close/leave; the
  existing `idle_commit_hours` default drops 24h → ~2h as the
  backstop for notes that stay open. The dedupe guard rides every
  path (unchanged take ⇒ no new row). Zero schema.
- **J11 setting RULED: ONE simple setting** — a single enum-valued
  setting ("Every session · Idle only · Only when I commit"-shaped;
  exact wording at build), synced like other settings, E2EE-clean
  (enum semantics, no prose — the `setting.value` column fence
  holds). Not full knobs; not settingless.
- **The graveyard question held OPEN by her counter-question
  (verbatim):** "what do you think the utility of a global lineage
  list is? what is the usecase here? i think it makes more sense
  per note if we do want to keep it (a lineage list and a deleted
  blocks list, but tbh that also seems quite confusing?). if a user
  has deleted a block completely, the idea that it deletes the
  previous version makes a certain amount of sense. offering whole
  note version history (with all the blocks, etc.) seems like it
  makes a lot more sense than this lineage history, but maybe i'm
  not seeing some potential use for it." → The architect's utility
  analysis + her ruling: round 2.

### Sitting round 2 — the graveyard's fate, tray grammar, note history (2026-08-18)

The architect's utility answer put to her (recorded in brief; the
full enumeration is the sitting transcript's): the global list's
only unique case — an original whose successors were ALL later
deleted — is covered per-note because released originals carry
`last_container_id` (stamped by divide-W/merge exactly so "a
released block deleted later still trays"); everything else is
served better contextually (J3's successor door), and the J4/J4b
default flips make orphaned-take originals rare going forward. The
spec's own rationale for the global view was a DEVELOPER safety
net — it survives as a debug query, not a room in the house.

- **J6 RULED: the global unplaced-blocks listing is REMOVED.**
  Released originals surface in the per-note tray + J3's lineage
  door on successors (the primary road). The Library recovery
  surface keeps notes & books; the "Place in pool" door dies with
  the section. (AppSpec §12's "unplaced-blocks utility view" line
  gets a ratified-supersession note at closeout, per this ruling.)
- **Tray grammar RULED: TWO quiet sections** — "Deleted & archived"
  and "Preserved originals" as labeled groups inside the one tray
  panel (she chose the visible distinction over the single-list
  shape). One "Put back" verb per row either way; rows carry
  first-line preview + when.
- **Whole-note version history RULED: future row + in-phase design
  brief** (the S4-16 deferral form — moved in time, never into
  vagueness). 13j authors the detailed brief as a deliverable: the
  session-grain text browser that the new cadence makes derivable,
  AND the structure-snapshot question (block order/membership at a
  time — new pointer-shaped rows, schema + §12 lockstep, its own
  design). A new master-plan row lands at closeout.
- **Cascade instinct steered, she accepted the carry:** no
  delete-cascades-to-ancestors semantics; instead the J1 purge
  design rules what happens to lineage-only originals when their
  whole descendant family purges (named edge, carried into the J1
  round).

### Sitting round 3 — the Trash (J1), designed WITH the GC horizon (2026-08-18)

Framing put to her (accepted without dispute): the horizon rule
means the 30-day clock is when things leave every surface; the
byte-removal janitor TRAILS invisibly until every device on the
account has seen the deletion (else a stale peer's re-push
resurrects it). Knowing "every device has seen it" needs a small
server-side addition (a per-device pull cursor) — **STOP-class:
the purge design memo returns for her explicit go before anything
server-shaped lands, mirror-first**. Purge takes the whole family
(blocks, takes, savepoints, edges, comments) including preserved
originals whose entire descendant family is going.

- **J1 scope RULED: everything deleted rides ONE uniform 30-day
  story — with her rider (verbatim):** "everything deleted, one
  uniform story, but have a delete now option WITHIN the trash
  (not from within the normal note). maybe you can sort the trash
  by blocks or note or whatever would be important for that to be
  a real option, but never accidental full delete from within a
  note, but an option for full delete without waiting." → Binding
  consequences: **Delete Now and Empty Trash live ONLY inside the
  Trash surface — no full-delete door exists in the note/editor
  context, ever**; the Trash surface gets sort/filter by kind
  (blocks · notes · books; date) so per-row Delete Now is a real
  usable option; the per-note tray's Deleted rows show the
  countdown quietly but carry no purge door.
- **J1 home RULED: the Library recovery surface, renamed "Trash"**
  — Archived (kept forever, no clock) stays its own calm section;
  Recently Deleted becomes the Trash with per-row "N days left" +
  Put back. No new sidebar room (R44 stands).
- **J1 doors RULED: Delete Now per row + Empty Trash, both
  confirm once, both in-Trash only** (per the rider above). Rows
  vanish from all surfaces immediately; bytes follow at the
  horizon.
- **J1 window RULED: fixed 30 days** — no setting; Delete Now is
  the impatience door.

### Sitting round 4 — ceremony doors, the lineage door, opening batch, cast (2026-08-18)

- **J4/J4b doors RULED: "Divide with Ceremony…" ⌥⌘⇧D · "Merge
  with Ceremony…" ⌥⌘⇧M** — the plain chord (⌘⇧D / ⌘⇧M) + ⌥, the
  same "deliberate variant" modifier the ⌥⌘Z family carries. Both
  in the Block menu, the block context menu, and the ⌘K palette —
  never only a buried item (her standing binding).
- **J3 grammar RULED: context menu only — NOT daily chrome. Her
  words (verbatim):** "I think context menu only. maybe also
  within the bottom bar? or is that what you mean by context item?
  I honestly feel like this will rarely matter to people so it
  shouldn't be part of the daily chrome, just accessible if
  needed." **Architect's clarification (given at the sitting):**
  the context menu is the right-click menu on the block; the
  bottom bar is persistent daily chrome — which her own criterion
  excludes. Shape as recorded: a right-click item ("See original
  from divide…" / "…from merge…") appearing ONLY when an unplaced
  original exists behind the block, opening a read-only peek of
  the original (takes visible) with "Put back in note" + "Open
  this note's tray"; the ⌘K palette carries the same act (a
  palette is summoned, not chrome — architect call inside her
  criterion, hers to strike). No hover glyph, no bottom-bar
  button.
- **J5 confirmed as stated** (no objection): the lens column
  speaks in place when a pick dangles — "This pick was archived —
  showing the default take" + one-click Restore. The restoration
  map is COMPLETE: in-note → the tray; from a successor → the
  lineage door; whole notes/books → the Trash's Put back; lens
  picks → the inline restore.
- **Opening batch RULED: the mini-round folds in** — batch 1 =
  J7 + J8 + J9 (J9's one precise trace first).
- **Cast RULED: the 13e shape** — Fable architect/orchestrator
  (this session) · a FRESH Opus implementer per batch · Fable cold
  reviews.

### Sitting round 5 — her post-close review ask + the J3 AMENDMENT (2026-08-18, same sitting resumed)

**Her message (verbatim):** "do you think that we've got everything
decided in a user friendly way? do you think there's something I'm
missing about how things are added and deleted that would be better
to handle differently? I also think it should be added to the
bottom bar note block where you see the history, since it is
lineage. it would make sense to me for it to be there. do you think
there's anything I haven't considered in the usability? I imagine
if things make sense naturally and intuitively to me after this
round will be the big question, but still, I want to make sure you
think we're in a good place design wise and rasie any last
questions if not"

- **J3 AMENDED by her ruling: the lineage door ALSO joins the
  block's History face** — "since it is lineage." Architect's
  reading of the surface (stated back to her, hers to correct):
  Write's bottom-bar per-block **History** toggle
  (`CommitBar.swift` → `CommitHistoryView`) and Takes'
  per-take History sheet (`TakesBottomBar`). When the block has an
  unplaced original, the history face carries a quiet lineage row
  ("From a divide on ‹date› — the original is preserved · See
  original") opening the same peek as the context-menu item. This
  COMPOSES with round 4's criterion rather than contradicting it:
  the history face is SUMMONED (behind the existing History
  toggle), so no new ambient chrome appears. Routed to batch 3.
- **The architect's audit at her ask — the ONE genuine gap found:
  DELETED TAKES.** The phase's own bar names takes ("deleting
  things — blocks, notes, takes — and getting them back is
  obvious, honest, and calm"), and the J1 scope ruling says
  "everything deleted" — but takes were never explicit in the
  Trash round, and the code has NO `restoreVariant` op and NO
  deleted-take query anywhere (verified by sweep this round): a
  deleted take is unreachable forever today. **Her ruling: YES —
  the FULL uniform story.** Deleted takes ride the same 30-day
  clock: quiet rows in the block's History face (beside commits
  and the lineage row — one "past" surface per block) with Put
  back, AND in the Trash under a Takes filter with block/note
  context. Archived takes keep NO clock (the archived-notes
  parallel). Needs a small restore op + a deleted-takes query —
  zero schema. Routing: the op + query + History-face rows →
  batch 3 (the recovery-doors batch); the Trash's Takes filter +
  clock inclusion → batch 6. Audit statements (design, correction invited — no
  question burned): Put back returns a block to its OLD position
  when neighbors survive (the tombstoned placement row keeps its
  fractional key — revival is free); a note deleted whole lists
  in the Trash as ONE note row, its cascade-deleted blocks never
  double-listed under the blocks filter (the exact-stamp machinery
  is the discriminator); Put back into a SEALED note diagnoses
  ("this note is marked complete — unseal to put it back"), the
  J8 refusal doctrine; the tray door's "⌫ N" badge counts DELETED
  blocks only (preserved originals show in the panel but don't
  inflate an urgent-looking count); the archived-vs-Trash
  distinction (kept-forever vs 30-days) is taught EXPLICITLY in
  J10's chapter; the phone inherits the Trash CLOCK automatically
  (store-level) but owes the tray/Trash FACES — the closeout's
  MobileSoul parity row.

Every agenda item ruled: J1 (rounds 3), J2 (1–2), J3 (4), J4/J4b
(4), J5 (4, as-stated), J6 (2 — the global listing REMOVED), J7–J9
(fold to batch 1), J10 (standing scope, late batch), J11 (1 —
close+idle-backstop cadence, one simple setting). Plus two closeout
deliverables born at the sitting: the whole-note-version-history
design brief + future master-plan row (round 2's deferral), and
the AppSpec §12 ratified-supersession note for the unplaced-blocks
utility view line. Nothing schema-shaped builds in any batch; the
J1 purge memo returns to her for the STOP-class go before anything
server-shaped lands.

## THE BATCH PLAN (architect's order, 2026-08-18 — adjustable on evidence; one FRESH Opus implementer per batch, strictly sequential; the 13e-shape ladder rides the phase)

| Batch | Scope | Status |
|---|---|---|
| 1 | **The mini-round:** J7 (⌘Z→⌥⌘Z status-line hint) · J8 (copy truth: the receipt's interim honesty + the diagnosing `.crossesBlockBoundary` refusal) · J9 (whole-block-selection delete → the delete compound; ONE precise trace FIRST) | **DONE 2026-08-18** — record below (core 1254/135 · Mac **1433/258 FULLY GREEN** · spine 51/7 · mobile 314/60; the J9 trace: the paragraph-end SEPARATOR owned by no entry — the open tail was NOT the decliner; QUESTIONS #66 logged — (b) fanned-block delete and (c) the superseded Phase-11 join outcome are HER calls; ARCHITECT-VERIFIED against commits `152f3fc`/`cc51792`) |
| 2 | **The tray (J2) + the graveyard removal (J6):** the context-bar door ("⌫ N", nonempty-only) + the two-section tray panel with Put back; the global unplaced section leaves the Library surface (pool door dies with it); the delete receipt/help copy graduates to naming the real tray + its door (J8(a)'s completion); **+ the batch-1 hand-off rider: the phone's two tray-promising receipts made TRUE on the phone's own terms** | **DONE 2026-08-18** — record below (core 1259/135 · Mac **1450/259 FULLY GREEN** · spine 51/7 · mobile 314/60; BOTH VERIFY-first flags answered — block-level archive is UNREACHABLE (section named "Deleted"), and `restoreBlock` places at the note's END, diverging from the round-5 design statement: **REPORTED, op UNTOUCHED, her call at QUESTIONS #67**; ARCHITECT-VERIFIED against `7e45d0d` — the core count REPRODUCED by the architect's own run, F2 ADJUDICATED into batch 3's rider, the Blocks-mode `traySection` consolidation held propose-only) |
| 3 | **DONE 2026-08-18** — record below (core 1278/136 · Mac **1467/261 FULLY GREEN** · spine 51/7 · mobile 314/60; the bridge RECONCILED — the peek is the destination, `TrayRequest.revealBlockID` KEPT as the peek's second action; the archived-take road VERIFIED as `unarchiveVariant` and reused unchanged; the F2 rider BUILT with both roads pinned; the capture caught two copy defects and both are fixed; QUESTIONS #68 logged; **ARCHITECT-VERIFIED against `b331ef6` — the core count REPRODUCED by the architect's own run; F2 was RATIFIED by her at round 6 while this batch ran, so the rider ships ruled, not provisional**). Scope: **The lineage door (J3, as AMENDED round 5) + lens-fallback loudness (J5) + deleted-take recovery (round 5):** the context-menu item + ⌘K palette act, the read-only original peek with Put back / Open tray; **the History-face lineage row** (Write's CommitBar history + Takes' history sheet — the summoned "past" surface); the lens column's in-place archived-pick notice + one-click Restore; **the deleted-take restore op + deleted-takes query + the History face's quiet deleted-take rows with Put back** (zero schema); **+ the F2 placement rider** (`restoreBlock` flips the surviving placement row — adjudication above) | **DONE** |
| 4 | **The defaults pair (J4/J4b):** divide default → `divideDuplicating` (the dormant core op wired); merge default → carry-all (composed from `mergeCeremony`, the phone's C5 the reference); "Divide with Ceremony…" ⌥⌘⇧D · "Merge with Ceremony…" ⌥⌘⇧M in Block menu + context menu + palette | **DONE 2026-08-18** — record below (core 1278/136 · Mac **1492/263 FULLY GREEN** · spine 51/7 · mobile NOT RUN, correctly — zero `Sources/`/`Shared/` lines; **the CHAIN-COMPOSITION answer: built, no edge beyond the brief's sentence** — each link composes through the one `CarryAllMerge` brain, unfanned links keep `ops.merge` byte-unchanged, the next link's displayed take is read off the op's own `sources` rather than inferred, and the compounding carry consequence is recorded at #69(a); the ⌥⌘⇧D/⌥⌘⇧M collision sweep found both FREE; five stale ceremony-default copy sites + three tutorial lessons aligned; ZERO core-op changes; QUESTIONS #69 logged with the ONE judgment call — the context menu's unconditional ceremony rows; ARCHITECT-VERIFIED against `55885ef` — #69(a) chain carry + #69(c) menu rows are her walk items) |
| 5 | **J11 — the savepoint cadence:** on-note-close auto-commit per edited take (deduped) + `idle_commit_hours` default 24→2 + the ONE enum setting ("Every session · Idle only · Only when I commit"-shaped) + the history view's quiet-run collapse (the legibility half) | **DONE 2026-08-19** — record below (core 1295/138 · Mac **1516/266 FULLY GREEN** · spine 51/7 · mobile 314/60; the LIFECYCLE ANSWER: a note is left when no pane of a window shows it — one entry, `AppSession.savepointOnLeaving`, off four existing funnels, no second lifecycle mechanism; `closeAutoCommit` is the SIXTH quiet occasion, gated with `idleAutoCommit` while the four INSURANCE occasions stay ungoverned; ZERO schema — one seeded setting VALUE, marker 6 stands; the Mac's intermittent canvas reds TRACED to load-dependent mouse-event rigs and proven PRE-EXISTING on a worktree at `43192a9`; two canon deltas owed at closeout; QUESTIONS #70 logged) |
| 6 | **J1 — the Trash:** the surface reshape (rename to Trash; Archived keeps no clock; per-row "N days left" + Put back; sort/filter by kind + date **incl. the round-5 Takes filter — deleted takes ride the clock with block/note context**; Delete Now per row + Empty Trash, confirm-once, IN-TRASH ONLY — no full-delete door in any note context, ever; a note deleted whole lists as ONE note row, cascade victims never double-listed) + the 30-day leave-all-surfaces clock; **+ BLOCK-LEVEL ARCHIVE (round-7 ruling):** `archiveBlock`/`unarchiveBlock` on the ruled shape (release placement + stamp; tray section takes back "Deleted & archived"; no countdown on archived rows; Put back via the ratified F2 road; structural-undo entries; doors + registry + receipts); **+ the Blocks-mode `traySection` routed to the one panel (round-7 ruling)**; **the purge design memo authored here** (client+server mechanics, the horizon, the per-device pull cursor, the lineage-only-originals edge) → STOP: her explicit go gates any server-shaped build | pending |
| 7 | **J10 — the tutorial deletion chapter** (walk-asserted per P-6: delete blocks in-tutorial, the tray, Put back, cross-block deletion, the Trash, the ceremony doors) + the whole-note-version-history design brief (round 2's deferral deliverable) | pending |

Ladder shape (the 13e precedent): ladder A after batch 4, ladder B
after batch 7 — fresh Fable cold reviewers on `REVIEW_PROMPT.md`
verbatim; adjustable on evidence. **LADDER A round 1 SPAWNED
2026-08-18** (fresh Fable, the prompt file pointed-to verbatim
with {PHASE}=13j, zero framing; findings land here repo-first when
it reports).

## Batch 1 brief — the mini-round (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads); this
plan file TOP TO BOTTOM (the P-1…P-9 constitution, the RUN RECORD's
sitting rulings, and the Environment traps above are all binding);
the 13e plan's "POST-CLOSE LIVE REPORTS" section
(`notes/plans/phase-13e-takes-block-management.md`, bottom) — her
three verbatim reports are this batch's founding evidence; the
`architect-phase` skill's "Applying the constitution" notes
(`.claude/skills/architect-phase/SKILL.md`).

**Scope — three items, all fully ruled:**

1. **J7 — the ⌘Z→⌥⌘Z hint (her live ruling, ready to build).**
   Plain ⌘Z pressed with nothing to undo in the text while the
   structural undo stack holds entries → the status line speaks:
   "Nothing to undo in the text — your last change was structural:
   ⌥⌘Z undoes it, ⇧⌥⌘Z redoes." The key is NEVER consumed; the two
   stacks stay canon-separate (2026-07-04). The symmetric case
   (⌘⇧Z with an empty text-redo while the structural REDO stack
   holds entries) is IN scope only if it lands under the same
   shape trivially — otherwise record it for the architect.
   Red-on-old pin: the hint fires exactly on (text-undo empty ∧
   structural stack nonempty), never otherwise.
2. **J8 — copy truth, two halves.** (a) The multi-delete
   receipt/help copy stops naming the nonexistent tray TODAY —
   interim wording says only what is true ("⌥⌘Z puts them back
   during this session"-shaped); batch 2 graduates it to naming
   the real tray. (b) `.crossesBlockBoundary`'s refusal stops
   guessing three causes and DIAGNOSES the actual blocker — the
   refusal carries WHICH condition declined (locked take / open
   tail / spans-a-seam / …), the enum-dump family one level up.
   Copy that names a cause the code didn't establish is the
   defect class itself — wire the copy to the real decliner.
3. **J9 — whole-block-selection delete routes to the delete
   compound. ONE PRECISE TRACE FIRST (the hallucination guard):**
   reproduce her case (a selection covering exactly one whole
   paragraph/block in a note carrying an OPEN TAIL — her
   screenshot report, the 13e POST-CLOSE section) and establish
   WHICH eligibility guard declines (the open-tail edge vs the
   ends-exactly-at-a-block-start edge vs other) — record the
   trace in the batch record BEFORE building. Then: a selection
   covering exactly N whole blocks (N ≥ 1) + delete routes to the
   13e batch-4 delete compound — ONE ⌥⌘Z-undoable entry
   (ghosts-first, redo carried) — and the text-edit road never
   refuses that intent again. Partial-block selections keep
   today's behavior. **If the trace surfaces edges beyond the
   ruled shape: STOP and report to the architect** (P-5 — the
   design-memo form, never improvised edges). Red-on-old pins:
   the route fires on whole-block selections (incl. the
   open-tail-present case), the refusal never appears for that
   intent, and the compound's undo restores exactly.

**Constraints:** zero schema; zero `Sources/VariorumCore/Sync/`
lines; registry discipline for any door/copy the work touches
(P-1); no invented product behavior — the rulings above are the
letter. The Environment traps bind verbatim: NEVER touch the
real-store instance; kills by PID/bundle-id only; no Release
builds or `/Applications` refreshes; implementer sessions NEVER
push.

**Verification (batch end, counts quoted):** core `swift test`
(baseline 1254/135); the Mac suite via the cwd-independent
`-project` invocation (baseline 1413/256, FULLY GREEN — zero
allowed reds); the tutorial spine by TYPE name (baseline 51/7);
mobile ONLY if `Sources/`/`Shared/` was touched (baseline 314/60,
iPhone 16e). Confirm the "Test run with N tests" line for every
run.

**Record (repo-first):** append the batch-1 record to this file —
the J9 trace, per-item what-shipped, pins named with their
red-on-old evidence (behavioral revert), suite counts, anything
unverified marked PENDING — then commit per convention. The
architect verifies before relying on it.

---

## BATCH 1 RECORD — the mini-round (2026-08-18; fresh Opus implementer)

**Scope built, to the letter of the sitting's rulings:** J7 (the
⌘Z→⌥⌘Z hint), J8 (copy truth, both halves), J9 (whole-block
selection + Delete → the delete compound, the ONE precise trace
first). Zero schema; zero `Sources/VariorumCore/Sync/` lines;
zero `Sources/` lines at all. No new capability-registry rows —
none of the three adds a routed DOOR (J7 is a sign on an existing
key; J9 is a keystroke road beside A7's and #34's, which are
likewise undeclared by the same precedent; J8 is copy). No
Release build, no `/Applications` refresh.

### THE J9 TRACE (done and recorded BEFORE the fix, per the brief)

**Executable, and it lives in the repo:**
`WholeBlockDeleteTests.swift`'s two `trace…` tests, written and
run green against the UNMODIFIED code before a line of the fix
existed.

**The mechanism, exactly.** A note of three blocks with an open
tail renders `Alpha one.\nBeta two.\nGamma three.\ntail` — entries
at `[0,10)`, `[11,20)`, `[21,33)`, separators at 10, 20, 33.
Selecting the middle paragraph the way a triple-click or a
drag-to-the-next-paragraph does yields `{11, 10}` — block 1 whole
PLUS the separator at 20. That separator is owned by NO entry (the
EditorDocument tiling doctrine), so `BlockRangeIndex.verdict`'s
containment fails in both directions and answers
`.refuse(.crossesBlockBoundary)` — correctly.

**WHICH eligibility guard declined — both planners, the SAME two
guards:**

1. `touched.count >= 2` — the span intersects exactly ONE entry's
   characters (`touched == [1]`; the intersection with Gamma is
   `{21, 0}`, length 0, because the span's upper bound IS Gamma's
   start);
2. the contiguity guard `range.upperBound <= range(ofEntryAt:
   last).upperBound` — 21 > 20, because the trailing separator sits
   one past the last touched entry.

`planCrossBlockEdit` and `planVisibleTakeEdit` both carry both
guards, so both return nil, `planEmptyBlockDeletion` and
`planSeamMerge` never see it (they require `range.length == 1`),
and `shouldChangeText` falls to the final `else` and speaks.

**THE OPEN TAIL IS NOT THE DECLINER.** The post-close write-up
named it as the likely culprit; the trace ruled it out — a
tail-free note declines identically on the same two guards
(`traceTheOpenTailIsNotTheDecliner`). The "ends-exactly-at-a-block-
start" suspicion was the *right family* and the wrong statement:
the span does not end at a block start, it ends one PAST the last
block's end, on a character no block owns.

**No edges beyond the ruled shape were surfaced by the trace**, so
the build proceeded per the brief. Two consequences of the ruled
shape that ARE recorded for her (QUESTIONS #66(b)/(c)) rather than
improvised around: what happens to a FANNED block on this road, and
the two-whole-paragraph case that used to join.

### WHAT SHIPPED

**J7 — the hint.** `EditorUndoHint` (new, pure): the fire rule is
`text stack empty ∧ structural stack non-empty`, per chord, with
the structural side read from `session.undoMenuState` — the SAME
projection the Edit menu's own enablement reads, so the sign and
the door can never disagree. `EditorTextView.undoHintChord(for:)`
(new, pure, `nonisolated`) classifies ⌘Z / ⌘⇧Z and deliberately
does NOT claim ⌥⌘Z / ⇧⌥⌘Z — those are already the doors the hint
points at. Wired in `performKeyEquivalent`, which **falls through
to `super` on every path**: the chord is never consumed, and the
integration pin asserts the return is `false`. The first-responder
gate keeps a split window's second editor quiet (both editors see
`performKeyEquivalent` and share the window's undo manager, so
without it one press would speak twice). Spoken via `showStatus`,
never `refuseFeedback` — nothing was refused, so nothing beeps.
**The redo mirror shipped** (it landed under the same shape
trivially, as the brief allowed). **The two stacks stay
canon-separate** — this adds a sign at the junction, not a bridge.

**J8(a) — the receipt's interim truth.** `BlockSelectionCopy
.deletedNote` / `.deleteHelp` no longer promise "this note's
deleted-blocks tray"; they say the true thing (⌥⌘Z, while this
session is open). The two hand-written single-block receipts
(Write's `deleteCaretBlock`, the Takes board's delete) now CALL
`deletedNote(1)` instead of carrying their own copy of the
sentence — one receipt, every delete door, so batch 2's graduation
is one edit. A shipped singular/plural bug went with it: the old
line said "Block deleted — ⌥⌘Z undoes it **in one go**" for a
single block.

**J8(b) — the refusal diagnoses.** `CrossBlockRefusal` (new,
pure): seven causes, each traced to the guard that produces it,
asked most-specific-first (seam-keystroke residue → open tail →
not-editable → partial coverage). The copy is split into a
`causeClause` (names ONE thing) and a `roadClause` (the way out) —
which is what let the pin hold the actual promise: **a pin caught
the first draft still guessing**, saying "an archived take or a
comment", and the fix was to split `carriesUnshownText`'s two kinds
into two causes rather than to weaken the pin. Both live doors onto
the old line now diagnose (`shouldChangeText`'s final else, with
the range and slots; `deleteInEveryTake`'s editability guard, which
already knew which of the two it hit). The enum's own
`message(for: .crossesBlockBoundary)` survives as the range-less
fallback, pointed at the residual cause, guessing nothing.

**J9 — the route.** `BlockRangeIndex.wholeBlockRun(covering:)`
(new, pure, in `Shared/`): does this span cover a contiguous run of
WHOLE entries plus at most one separator hanging off each end, and
nothing else? Ranges of exactly ONE character are excluded by
construction, so A7's empty-block carve and #34's texted-seam merge
keep every case they ruled — including their fan and
nothing-unshown authorizations, which this road must never route
around (pinned). `planWholeBlockDeletion` is PURELY GEOMETRIC and
carries no content guards at all — the 13c R3-1 lesson applied
rather than re-learned (a plan-time read of `model.slots` is an
enablement hint, never an authorization, because the projection is
deliberately frozen for a typing burst); the authorization is
`deleteBlock`'s own unrestricted door (#33(a)), and a sealed note
refuses at the first leg through the operation (P-2). It runs the
**shared** compound body extracted from `deleteSelectedBlocks`, so
"routes to the 13e batch-4 delete compound" is literally true and
the two doors cannot drift on the label ("Delete Blocks"), the
compound, or the receipt. Placed in the arm AFTER both seam carves
and BEFORE merge-then-edit. Type-overs are excluded
(`replacement.isEmpty`): a replacement spanning whole blocks keeps
its existing road, since a delete compound would drop the typed
characters.

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

Two new suites, **20 tests**: `WholeBlockDeleteTests` (10),
`UndoHintAndRefusalTests` (10).

| Revert | Pins that went RED | Restored |
|---|---|---|
| J9's routing arm disabled (`else if false, let whole = …`) | `aWholeParagraphSelectionDeletesTheBlock` (2 issues — texts unchanged; the REFUSAL spoke instead of the receipt) · `theRouteIsOneUndoEntryAndItRoundTrips` (2 — `stack.topLabel` nil) · `aRunOfWholeParagraphsGoesUnderOneEntry` (2). The four geometry pins and the two partial/type-over pins correctly stayed GREEN (pure brain + unchanged roads). | `EditorViewModel.swift` restored, checksum `16143846a0…` identical to pre-revert |
| J7's hint arm disabled (`if false, let chord = …`) | `commandZAfterAStructuralChangeSpeaksTheHintAndKeepsTheKey` | `EditorTextView.swift` restored, checksum `a4ab58f6c4…` |
| J8(a) copy reverted to the tray-naming line | `noDeleteReceiptPromisesATrayThatDoesNotExistYet` (2 issues) | `OpsRefusalCopy.swift` restored, checksum `d07609dec6…` |
| J8(b) refusal reverted to the shipped three-cause guess | `aPartialCrossBlockSelectionSpeaksTheDiagnosis` | `EditorViewModel.swift` restored, same checksum |

The two `trace…` tests pass on BOTH sides deliberately: they
characterize the mechanism (the verdict and the two planners'
declines), which the fix does not change — it adds a road beside
them. They are the permanent record of why, not a pin on the fix.

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1254 tests / 135 suites PASSED** (baseline exact)
- Mac (`-project` invocation) — **1433 tests / 258 suites PASSED,
  FULLY GREEN, zero reds** (baseline 1413/256 + this batch's 20
  tests in 2 suites)
- tutorial spine, by TYPE name (`TutorialBookShapeTests`,
  `TutorialDoorTests`, `TutorialWritingActsTests`,
  `TutorialTakesActsTests`, `TutorialStructureActsTests`,
  `TutorialLookingActsTests`, `TutorialLibraryActsTests`) —
  **51 tests / 7 suites PASSED** (baseline exact)
- mobile (`VariorumMobile`, iPhone 16e) — **314 tests / 60 suites
  PASSED** (baseline exact). Run because `Shared/EditorBrain/
  BlockRangeIndex.swift` was touched; the addition is a pure
  function no phone code calls yet.

### FOR THE ARCHITECT / HER

- **QUESTIONS #66** logged (seven lettered entries, her format):
  the trace's answer, and the two calls that are genuinely hers —
  **(b)** whether the whole-block road may delete a FANNED block
  (built to J9's letter + #33(a)'s unrestricted delete; the
  alternative is #34's keystroke rule, "a keystroke won't fold a
  fan away", and it is one guard line either way), and **(c)** the
  two-whole-paragraph case, which used to JOIN and leave an empty
  block and now deletes both (the ruled letter, but it supersedes
  a Phase-11-ratified outcome, so it is named).
- **PARITY / batch 2 hand-offs.** (i) The iPhone's two delete
  receipts still promise the tray (`MobileStructural.swift`,
  `MobileBlockMenu.swift`) — deliberately out of this Mac batch's
  scope, and the phone has no tray either; a parity-ledger row.
  (ii) **Batch 2's J8(a) graduation is now ONE edit**:
  `BlockSelectionCopy.deletedNote` + `.deleteHelp` are the only
  places the sentence lives. (iii) `BlockRangeIndex.wholeBlockRun`
  is in `Shared/`, so the phone can adopt the same road when its
  turn comes.
- **Environment.** Her real-store instance (PID 13761) was live at
  batch start and was NEVER touched — no kill, no quit, no
  `/Applications` write, no Release build. It was gone by the time
  the full-suite runs began (her own act; observed, not caused).
  Nothing else was running.
- **Nothing PENDING** — every claim above is from a run in this
  session.

## Batch 2 brief — the tray (J2) + the graveyard removal (J6) (a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads); this
plan file TOP TO BOTTOM (the P-1…P-9 constitution, sitting rounds
1–5 — the rulings are the letter — the Environment traps, and the
BATCH 1 RECORD above); the `architect-phase` skill's "Applying the
constitution" notes (`.claude/skills/architect-phase/SKILL.md`).

**Scope — four items:**

1. **The tray face (J2 — rulings: rounds 1, 2, 5).** The note's
   context bar (`Workspace/ContextBar.swift` is the likely home —
   verify) gains a quiet door visible ONLY when the note has tray
   content, reading "⌫ N" where **N counts DELETED blocks only**
   (round-5 statement: preserved originals never inflate an
   urgent-looking number); the note ••• menu carries the same act
   named in words. It opens the tray panel: **TWO quiet sections**
   — "Deleted & archived", then "Preserved originals" — each row a
   first-line preview + when it went + ONE **Put back** verb.
   Read-cheap tier only (P3 — no live editor in the tray).
   Queries: deleted = tombstoned blocks with `last_container_id` =
   this note (`idx_block_last_container` is the access path);
   preserved originals = LIVE blocks with NO live placement and
   `last_container_id` = this note. Standing windowed-observation
   discipline (visible truncation markers, probe-row +1).
   - **NO countdown in this batch:** the 30-day clock does not
     exist until batch 6 — showing "N days left" before the clock
     runs is the copy-truth defect class. Batch 6 adds it.
   - **Archived blocks: VERIFY, don't invent.** `block.archived_at`
     exists in schema; establish whether ANY shipped op sets it.
     If block-level archive is unreachable in the product, the
     first section lists deleted only and its label says
     "Deleted" (stay honest). Record the finding either way.
   - **Put back — deleted block:** `restoreBlock`. The round-5
     design statement says a put-back block returns to its OLD
     position when neighbors survive (the tombstoned placement
     row keeps its fractional key). **VERIFY the shipped op's
     actual placement behavior FIRST**; if it diverges (e.g.
     appends to the end), REPORT to the architect before touching
     op semantics — an ops-layer change needs its own
     state-transition tests and a deliberate record, never a
     silent edit.
   - **Put back — preserved original:** face-level composition
     over `placeBlock` (the W-reversal road; NO new op
     semantics): placed immediately AFTER its last live successor
     in this note when one exists, else at the note's end (the
     architect's recorded micro-placement call).
   - **Sealed note:** the tray still opens (reading is free); Put
     back delivers the op's real refusal worded as diagnosis —
     "This note is marked complete — unseal it to put this back."
     (the J8 doctrine; P-2).
   - Registry discipline (P-1): the tray act declared once with
     both doors (the context-bar `.surface` door + the ••• menu
     item); the registry walk asserts them.
2. **The graveyard removal (J6 — ruled round 2).** The "Unplaced
   blocks" section AND its "Place in pool" door leave the Library
   recovery surface (`RecoveryView`) entirely; dead code goes with
   them (and any registry declaration of the pool-add door). The
   surface keeps Archived (posts) · Deleted books · Recently
   Deleted unchanged — batch 6 reshapes those into the Trash.
3. **J8(a)'s graduation — the ONE edit** (batch 1 made it so):
   `BlockSelectionCopy.deletedNote` + `.deleteHelp` now tell the
   WHOLE truth — deleted blocks wait in this note's tray, named
   with its real door ("the ⌫ door in the note's bar"-shaped
   wording); ⌥⌘Z stays named for the immediate undo. Extend batch
   1's `noDeleteReceiptPromisesATrayThatDoesNotExistYet` pin to
   its graduated form (the tray EXISTS now — the pin asserts the
   copy names a real, rendered door).
4. **The phone-receipts rider (batch 1's hand-off).**
   `MobileStructural.swift` + `MobileBlockMenu.swift` delete
   receipts still promise a tray; the phone has NO tray. Make them
   TRUE on the phone's own terms: establish what the phone's real
   recovery road is today (its structural-undo affordance, if
   any); word the receipts to that road, promising nothing that
   lacks a face. If the phone genuinely has no road, the honest
   minimal receipt states the deletion plainly — the parity
   ledger already carries the tray-twin debt for closeout. NEVER
   redirect to the Mac in user-facing copy (the no-redirect
   principle, MobileSoul).

**Constraints:** zero schema; zero `Sources/VariorumCore/Sync/`
lines; ops-layer changes only as reported-then-ruled (the
`restoreBlock` placement question above); no invented product
behavior beyond the recorded rulings + the architect's
micro-placement call; the Environment traps bind verbatim
(re-check instances yourself — her real-store app may or may not
be live; NEVER touch it; kills by PID/bundle-id only; no Release
builds or `/Applications` refreshes; you NEVER push). Before Mac
suite runs, confirm no other `xcodebuild` run is active
(`pgrep -fl xcodebuild`).

**Hallucination guard:** red-on-old pins by behavioral revert for
every fix-class change. The tray's tests pin at minimum: the
badge rule (deleted-only count; hidden when empty), the
two-section split, Put back round-trips (deleted block → its old
position when neighbors survive, per the verified/ruled behavior;
original → placed after its last live successor), the sealed
diagnosis, and the graduated receipt truth.

**Verification (batch end, counts quoted):** core (baseline
1254/135); Mac via the cwd-independent `-project` invocation
(baseline **1433/258** after batch 1 — FULLY GREEN, zero allowed
reds); the spine by TYPE name (51/7 — the seven names are in the
BATCH 1 RECORD); mobile (314/60, iPhone 16e — the rider touches
mobile files). Confirm every "Test run with N tests" line.
Screenshot-verify the tray where the environment allows; else
record for the next drive.

**Record (repo-first):** append the BATCH 2 RECORD to this file —
what shipped per item, the archived-blocks and restoreBlock-
placement findings, pins + revert evidence with checksums, suite
counts, hand-offs — then commit per convention (CLAUDE.md
trailer). The architect verifies before relying on it.

---

## BATCH 2 RECORD — the tray (J2) + the graveyard removal (J6) (2026-08-18; fresh Opus implementer)

**Scope built, to the letter of the sitting's rulings:** the per-note tray
face (J2 — rounds 1, 2, 5), the global unplaced-blocks listing's removal
(J6 — round 2), the J8(a) receipt graduation, and the batch-1 phone-receipts
rider. **Zero schema; zero `Sources/VariorumCore/Sync/` lines.** Core changes
are QUERIES ONLY — no operation's semantics were touched (see VERIFY-2).
One new capability-registry row (`.showNoteTray`, two doors). No Release
build, no `/Applications` refresh.

### THE TWO VERIFY-FIRST FINDINGS (both established BEFORE the label / the pin)

**VERIFY-1 — is `block.archived_at` reachable? NO.** The column exists
(`Migrations.swift:425`), the model carries it (`Models/Block.swift:30`) and
`Sync/SyncSchema.swift` classifies it — but a sweep of every `archivedAt`
write in `Sources/VariorumCore` finds only `Operations+Container.swift:354/358`
(`archiveContainer` / `unarchiveContainer`, the CONTAINER's column), and
`grep -rn "archiveBlock"` over the whole repo returns nothing. **No shipped
operation ever writes a non-nil `block.archived_at`.** Consequence, taken:
the tray's first section is named **"Deleted"**, not the sitting's
provisional "Deleted & archived" — the brief's own instruction ("if
block-level archive is unreachable in the product… stay honest"). Pinned:
`theDeletedSectionDoesNotClaimAnArchivedStateNothingProduces`. Logged for
her at QUESTIONS #67 (Finding 1) with the build-a-block-archive alternative
named.

**VERIFY-2 — what does `restoreBlock` ACTUALLY do? It places at the END —
which DIVERGES from the round-5 design statement.** The op's own doc comment
states it (`Operations+Placement.swift:47–49`): *"The old placement row stays
tombstoned; a fresh placement lands at the end of `last_container_id`"*, and
`Operations+UndoInverses.swift:24–25` states the contrast explicitly —
*"Differs from the public `restoreBlock` tray gesture, which re-places fresh
at the end."* The exact-position machinery EXISTS but only on the undo path
(`revertDeleteBlock` flips the original placement row, position + chosen
variant intact); the tray gesture has never used it.

**What I did, per the brief:** built Put back on `restoreBlock` AS SHIPPED,
pinned the ACTUAL behaviour (`putBackReturnsADeletedBlockThroughRestoreBlock`
asserts the block lands last), worded the receipt to match ("Put back at the
end of this note."), and **touched no operation.** **REPORTED, not fixed** —
an ops-layer change needs its own state-transition tests and a deliberate
record. **Her call is at QUESTIONS #67 (Finding 2)**, with the concrete
alternative named: make `restoreBlock` flip a surviving tombstoned placement
row so Put back and ⌥⌘Z land in the same spot. It is a small change to a
shipped op with real sync-race questions (a placement row whose neighbours
moved, or whose container is since sealed), which is exactly why it is hers.

**A THIRD finding, unasked but load-bearing: the tray was not faceless — it
was BURIED.** `BlockTOCView.traySection` has rendered a deleted-blocks list
since Phase 11, inside the Blocks mode, only when non-empty. The plan's
"TODAY NO surface anywhere lists deleted blocks" is true of every surface she
WRITES in and false of the app as a whole. That sharpens rather than weakens
J2: her report was a findability finding, and the fix is a door in the note's
own chrome. The Blocks-mode section is left untouched (two views over one
query is the pointer religion, not duplication); noted for the closeout as a
possible consolidation.

### WHAT SHIPPED

**1 — The tray face (J2).**

- **Core, queries only** (`Queries/PoolAndTray.swift`, `Queries/Observations.swift`):
  `preservedOriginals(db, postID:, limit:)` — live, unplaced, `last_container_id`
  = this note, carrying its release stamp (the placement row's own
  `deleted_at`, not `block.updated_at`, which moves on any touch) AND its
  Put-back landing (the last live successor placed in this note, by one
  correlated subquery); `trayCounts(db, postID:)` — the badge's two numbers.
  **`trayCounts` deliberately never reads `variant`**: it is a HELD
  observation on an open note, GRDB tracks the tables a query reads, and
  joining preview text in would re-run it at autosave rate on the one table
  autosave writes (P1). The listings pay the join because they are opened
  deliberately. Observations: `observePreservedOriginals`, `observeTrayCounts`.
- **The face** (`Features/Tray/TrayPanel.swift`, new module): `TrayPath` (the
  ONE naming home — the `RecoveryPath` pattern), `TrayRequest` (the
  `CommentsRequest` shape), `TrayViewModel` (both listings, windowed 500 + the
  probe row, `adopt` test seam), `TrayPanel` (two labelled sections, one **Put
  back** per row, read-cheap `Text` rows — never a pane, P3), `TrayRefusalCopy`
  (the seal, diagnosed with its way out), `TrayRowPreview` (first line + the
  stamp, both pure).
- **The doors, ONE act declared once** (`.showNoteTray`, scope `.post`, doors
  `[.surface, .bottomBar]`, availability `noteScoped`): the context bar's
  **⌫ N** badge, rendered only when `deletedCount > 0`; and **"This Note's
  Tray…"** in the `note ▾` menu of BOTH bars (`CommitBar`, `TakesBottomBar`),
  always there — a badge that hides at zero cannot be the only way in.
- **How the badge sits with her K11 ruling** (recorded because two of her
  rulings meet here): K11 says the icon row *"should always look like this"*,
  and its stated reason is that *"adding a tag moves nothing she is aiming
  at"*; J2 asks for a door visible only when the note has deleted something.
  Both are kept — `ContextBarDoors.iconRow` is UNTOUCHED (pinned:
  `theFourConstantIconsAreUnchangedByTheTrayDoor`), so the four aiming targets
  stay a constant cluster, and the badge renders after them. The only thing
  that ever shifts is the tag cards, and only when she has just deleted
  something. Named for her at #67(b) with the far-right alternative.
- **Put back, both kinds.** Deleted → `restoreBlock` (VERIFY-2's real
  behaviour, said plainly). Preserved original → face-level composition over
  `placeBlock` at `.after(lastLiveSuccessor)` else `.end`, with the landing
  **re-read at act time** rather than taken from the listing (13c R3-1's
  lesson: a listing is a projection; an argument read from one is read from a
  snapshot). The sub-ms race is recorded in the code, not papered over.
- **Sealed:** the tray still opens and lists (reading is free); Put back
  delivers `TrayRefusalCopy.sealed` — *"This note is marked complete — unseal
  it to put this back."* — the J8 doctrine, P-2.
- **NO countdown**, deliberately: the 30-day clock is batch 6's, and showing
  "N days left" before it exists is the copy-truth defect class.

**2 — The graveyard removal (J6).** The "Unplaced blocks" section, its "Place
in pool" menu, `RecoveryViewModel.unplaced/pools/startUnplaced/place`, the
`UnplacedListing` type, `RecoveryPath.unplacedSection`/`.unplacedBlocks`, the
`.variorumRevealUnplacedBlock` notification, RootView's
`revealUnplacedBlockID` plumbing and `RecoveryView`'s whole reveal apparatus
are GONE. The surface keeps Archived · Deleted books · Recently Deleted
unchanged (batch 6 reshapes those). `Queries.unplacedBlocks` SURVIVES —
the sitting's words, *a debug query, not a room in the house* — pinned so its
removal would be deliberate.

**THE CONSEQUENCE THE BRIEF'S ONE SENTENCE DID NOT NAME, and how it was
handled.** `RecoveryPath.unplacedBlocks` was woven into **eight shipped copy
sites** (both ceremony explainers + the completion note, the merge receipts on
the instant AND ceremony paths, the Takes chain-merge receipt, the helper's
merge entry, `.showOriginBlock`'s declared refusal) and **two live doors**
pointed INTO the section (`revealOriginBlock` from Write and from the board).
Removing the room without them would have left eight sentences promising a
place that no longer exists — the exact defect class J8 exists to kill — and
two doors that can never act (P-2). So the removal carried its sweep:

- every copy site now reads `TrayPath.originalsPath` (or
  `.originalsPathWithDoor` where the sentence TEACHES the road), one constant,
  same arrow grammar — the destination moved, the voice did not;
- **`revealOriginBlock` (both view models) now opens THIS note's tray with
  the original's row marked** — no broadcast, no navigation, no leaving the
  note. This is the ruled destination applied to an existing door, not a new
  design: a divide-W/merge release stamps `last_container_id` with the note it
  left, so the original really is in that note's tray. **J3 (batch 3) owns the
  door's final form** (the read-only peek with Put back / Open tray); this is
  the bridge that keeps it honest meanwhile. A requested block the tray does
  not hold gets one quiet true line rather than a silent no-op.

**3 — J8(a)'s graduation (the ONE edit batch 1 promised).**
`BlockSelectionCopy.deletedNote` and `.deleteHelp` name the tray AND its real
door again, alongside ⌥⌘Z — two different promises, because ⌥⌘Z dies with the
session and the tray does not. Batch 1's interim pin
(`noDeleteReceiptPromisesATrayThatDoesNotExistYet`) is **graduated in place**
to `everyDeleteReceiptNamesTheTrayAndTheTrayHasARealDoor`: same claim (*a
receipt may only name a surface that has a door*), stronger form — it asserts
the copy names the tray AND that `.showNoteTray` is a declared act both
renderers carry, so the sentence cannot outlive its door.

**4 — The phone-receipts rider.** Established first: the phone has **no tray
face and no undo door** — `grep -rn "restoreBlock" App/Variorum/VariorumMobile`
returns nothing, and its `session.undoStack` use is compound-scoping only
(`MobileStructural.swift:376`). Parity C2 had kept the "deleted-blocks tray"
sentence on the reading that the tray was a FACT even without a phone face;
J8's doctrine — and her own morning report about the Mac's identical promise —
says a promise a user cannot act on is a place she goes looking for and does
not find. So: `MobileBlockMenuController.deleteConfirmDetail` = *"The block
leaves this note, with its takes. There's no undo here."*;
`MobileStructuralController.blockDeletedStatus` = *"Block deleted."* No
platform is named (no-redirect, MobileSoul §4), nothing is promised, and
"gone forever" is NOT claimed either (the block is tombstoned, not purged).
A SANCTIONED PIN FLIP on `MobileBlockMenuTests`, annotated in place, now
asserting both the no-redirect rule and the no-unbacked-promise rule.

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

One new suite, **17 tests** (`NoteTrayTests`), plus 5 new core query tests in
`PoolTrayQueryTests`. Every revert restored to a byte-identical checksum.

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A** — the badge always renders (`trayDoorShown` → `trayFace != nil`) | `theBadgeCountsDeletedOnlyAndHidesWhenThereAreNone` (2 issues — the empty case AND the originals-only case) | `ContextBar.swift`; the file then took ONE further deliberate doc-typo fix (`traysDoorShown` → `trayDoorShown`), so its recorded baseline is `447456fc7b…`, not the pre-revert `360623aef4…`. `TrayPanel.swift` restored byte-exact (`ef84ed66db…`) |
| **B+C** — the seal falls through to the generic ops copy; the original always lands at `.end` | `putBackUnderASealedNoteDiagnosesInsteadOfDumpingTheEnum` (got *"…to change takes or choices"*, the generic line) · `putBackReturnsAPreservedOriginalBesideItsSuccessors` | `TrayPanel.swift` → `ef84ed66db…` (identical) |
| **D+G** — the batch-1 interim receipt copy restored; `preservedOriginals` returns `[]` | `theDeleteReceiptNamesTheRealTrayAndItsRealDoor` (5) · `everyDeleteDoorStillSpeaksTheOneGraduatedReceipt` · `everyDeleteReceiptNamesTheTrayAndTheTrayHasARealDoor` (3) · `theTraySplitsDeletedFromPreservedOriginals` · `putBackReturnsAPreservedOriginalBesideItsSuccessors` (2) | `OpsRefusalCopy.swift` → `b5714f4eea…`; `PoolAndTray.swift` → `5203be3f06…` (both identical) |
| **E** — `revealOriginBlock` goes back to broadcasting at the removed room | `theDoorOpensThisNotesTrayAtTheOriginAndSpeaks` · `theBoardsProjectionCarriesTheOriginsAndItsDoorActs` (both: `trayRequest` nil) | `EditorViewModel.swift` → `aadca5d361…`; `TakesViewModel.swift` → `db202b937d…` (both identical) |
| **F** — one copy site points back at "Library → Archived & Deleted → Unplaced blocks" | `noShippedCopyStillPointsAtTheRemovedUnplacedListing` (2) | `DivideWCeremony.swift` → `790aa7b511…` (identical) |
| **G(mobile)** — the phone re-promises the tray | `deleteBlockTombstonesAndSpeaksTheTrayNote` (4 issues) | `MobileStructural.swift` → `f79f7393b6…`; `MobileBlockMenu.swift` → `76bcabae9d…` (both identical) |

**Four consequential pin edits, each annotated in place rather than
quietly relaxed** (all four failed on the batch's own first full run, which is
how they were found): `BookAscentTests`' `surfaceCapabilities` literal gains
`.showNoteTray` as its third recorded justified edit; `BoundaryFluidityTests`
and `MergeCeremonySheetTests` keep the identical CLAIM (*the lineage road stays
named*) with the destination updated; `UndoHintAndRefusalTests`' interim pin
graduates as described above.

### THE VISUAL LOOP

**The BADGE is captured** — `ContextBarCaptureTests` gains states 7
(`⌫ 1`) and 8 (`⌫ 3` with originals waiting), and its `bar(...)` helper
defaults to an empty tray so states **1–6 render byte-unchanged**, which is
itself the claim K11 cares about. Inspected: the badge sits after the four
constant icons, in the accent colour, before the tag cards; the at-rest bar is
identical to before. Path (sandboxed host):
`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/variorum-13k-batch3-screens`
— `cp` the `*-7-tray-badge-*.png` / `*-8-tray-badge-*.png` out to view.

**The PANEL cannot be captured offscreen — measured, not assumed.** A capture
arm was written against the same harness and rendered `ImageRenderer`'s
unsupported-view placeholder: SwiftUI `List` is NSTableView-backed. Recorded
in `NoteTrayTests` in the same register that harness uses for the book
dropdown's popover, and the arm was removed rather than left writing a broken
image. **The panel is a HAND-CHECK item for the next drive.**

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1259 tests / 135 suites PASSED** (baseline 1254/135 + 5)
- Mac (`-project` invocation) — **1450 tests / 259 suites PASSED, FULLY GREEN,
  zero reds** (baseline 1433/258 + 17 tests in 1 new suite)
- tutorial spine, by TYPE name (the seven from the batch-1 record) —
  **51 tests / 7 suites PASSED** (baseline exact)
- mobile (`VariorumMobile`, iPhone 16e) — **314 tests / 60 suites PASSED**
  (baseline exact). Run because the rider touched `VariorumMobile/`.

### FOR THE ARCHITECT / HER

- **QUESTIONS #67** logged (seven lettered entries + both VERIFY findings in
  her format). The one that is genuinely a decision: **VERIFY-2's alternative**
  — teach `restoreBlock` to flip a surviving tombstoned placement row so Put
  back lands where ⌥⌘Z lands. Recommended, but it is an ops change and hers.
- **BATCH 3 HAND-OFFS.** (i) `revealOriginBlock`'s tray landing is a BRIDGE —
  J3 replaces it with the read-only peek; `TrayRequest.revealBlockID` and the
  panel's mark/`revealMissing` line are the seam it can reuse or retire.
  (ii) `TrayPath` is the ONE naming home for anything else that points at the
  tray. (iii) The panel has no deleted-TAKE section — round 5 routed deleted
  takes to the block's History face, batch 3.
- **BATCH 6 HAND-OFFS.** The clock: `TrayItem.deletedAt` and
  `PreservedOriginal.releasedAt` are already on the rows (rendered as "when",
  no countdown). The tray's Deleted rows are where "N days left" goes, and per
  her round-3 rider they carry **no purge door** — Delete Now and Empty Trash
  are in-Trash only, forever.
- **PARITY LEDGER.** The phone owes a tray face (its receipts are now honest
  about not having one) — `preservedOriginals` / `trayCounts` / `trayBlocks`
  are all core, so the phone inherits the brains and owes only the face.
- **A CONSOLIDATION NOTE, propose-only:** `BlockTOCView.traySection` still
  renders its own small deleted-blocks list inside the Blocks mode. Left
  untouched (two views over one query is not duplication), but the closeout may
  want it routed to the one panel.
- **Environment.** No Variorum instance was running at any point in this batch
  (`pgrep` checked before every suite run and before the drill); no kill, no
  quit, no `/Applications` write, no Release build; no push. No other
  `xcodebuild` was active before any run.
- **Nothing PENDING** — every claim above is from a run in this session.

### Sitting round 6 — her return during batch 3 (2026-08-18)

**Her messages (verbatim):** "my variorum isn't currently running,
so you can refresh it when the batch is done. i'm ready for the
questions, please ask them in question mode with options that make
the pros and cons of each choice clear." — then, correcting: "I
said when the batch is done but I meant when the phase is done
really."

- **The `/Applications` refresh is AUTHORIZED for the PHASE
  CLOSEOUT** (her correction — the standing ritual's home for it);
  still gated on a zero-instance re-check + the A1 rail at
  execution time.
- The held bundle (#66/#67's genuine forks + the propose-only
  items) goes to her NOW in question mode, pros/cons explicit —
  rulings recorded below as they land. Entries not asked (66 a,
  d–g; 67 d–g) shipped to her existing rulings' letter and remain
  ratify-by-walk at the checkpoint.

**Round 6 rulings, question mode (pros/cons put in front of her):**

- **#66(b) RATIFIED as shipped:** whole-paragraph-selection Delete
  removes a fanned block, takes and all — one rule with ⌘-click +
  Delete under #33(a); the #34 alternative declined (its letter
  protects a MERGE folding takes into other text; a delete sets
  the block aside whole, tray-recoverable).
- **#66(c) RATIFIED as shipped:** N whole paragraphs + Delete
  removes all N — the Phase-11 join-and-leave-empty outcome is
  formally SUPERSEDED by her ratification (joins remain via
  partial-selection delete and merge).
- **#67 F2 RATIFIED (the PROVISIONAL resolves):** Put back returns
  a deleted block to its old spot when the placement row survives;
  end-of-note is the fallback. Batch 3's rider proceeds as ruled.
- **#67(a) RATIFIED as shipped:** the ⌫ badge counts DELETED
  blocks only and hides at zero; originals-only notes carry no
  badge (note ▾ + the History row are the roads).

**Her new question, mid-round (verbatim):** "do you think that we
should add block level archive? I think that it might be
worthwhile." → The architect's analysis + her ruling: round 7.

**Round 7 rulings, question mode (2026-08-18):**

- **BLOCK-LEVEL ARCHIVE RULED IN: built in 13j, riding batch 6.**
  Her lean confirmed against the architect's analysis (the Trash's
  clock removes the keep-forever road for a block; the pool-move
  loses the note tie; her original J2 wording assumed the state
  existed; `block.archived_at` has existed since v1 — ZERO schema,
  zero lockstep). The ruled shape: `archiveBlock` releases the
  placement (tombstoned) + stamps `archived_at` — the note renders
  on with no view-level filtering; the block appears in the tray's
  first section, which takes back its round-2 ruled name
  **"Deleted & archived"** (archived rows carry NO countdown —
  archive has no clock); Put back = clear `archived_at` + the
  ratified F2 placement road; `unarchiveBlock` the mirror;
  structural-undo entries like the archiveVariant class; doors +
  registry + receipts; the tutorial (batch 7) teaches the trio —
  Archive (kept forever, this note's tray) · Delete (30-day clock)
  · Move to scraps (material for anywhere) — as ONE story.
- **#67(b) RATIFIED as shipped:** the ⌫ badge sits after the four
  constant icons, before the tag cards.
- **#67(c) RATIFIED as shipped:** the name stays "This Note's
  Tray" (one constant; the Apple-familiar alternative declined —
  it would be false, the tray holds never-deleted things).
- **The Blocks-mode `traySection` RULED: routed to the one panel**
  — the section becomes a one-line door opening This Note's Tray
  (one surface, one truth). Riding batch 6 with the rest of the
  tray-family work.

## ARCHITECT ADJUDICATION after batch 2 (2026-08-18)

Verified against commit `7e45d0d`: tree clean, the record's shape
sound, and the CORE COUNT REPRODUCED by the architect's own run —
**1259/135 PASSED** (a burst of stale SourceKit diagnostics against
`PoolTrayQueryTests` claimed the new query members didn't exist;
the members are in the committed source and the suite is green —
indexing noise, recorded so nobody chases it).

- **Finding 1 (block archive unreachable) — ACCEPTED.** No op
  anywhere sets `block.archived_at`; the tray's first section is
  honestly named "Deleted". If a future phase makes block-level
  archive a product act, the tray grows the label back. No action.
- **Finding 2 (`restoreBlock` lands at the END, diverging from the
  round-5 design statement) — RULED (architect, PROVISIONAL under
  the standing rule; her ratify at QUESTIONS #67 F2):** the op
  ALIGNS to the recorded design AND the restore family's exact-row
  religion (`restoreContainer`/`restoreReading`/`revertDeleteBlock`
  all flip exact rows): when the tombstoned placement row for
  (block, its `last_container_id`) survives, Put back FLIPS it —
  the old fractional position revives, so Put back and ⌥⌘Z land a
  block in the same spot; fresh-at-end remains the fallback when
  no revivable row exists. Routed to batch 3 as a rider WITH
  state-transition tests; batch 2's Put-back pin and the "at the
  end of this note" receipt line follow the change. Grounds: the
  divergence is between two shipped behaviors on ONE gesture
  family; the exact-row shape is the family's rule everywhere
  else, and the design statement was recorded at the sitting with
  correction invited and none given.
- **Finding 3 (the Blocks-mode `traySection` predates J2) —
  HELD PROPOSE-ONLY** for her bundle (the Design & UI review
  class): two views over one query is legal; consolidation is a
  taste call, never autonomous.
- **The `revealOriginBlock` bridge — batch 3 reconciles** it with
  the ruled J3 grammar (the peek is the ruled destination; the
  tray stays the second action); keep or retire the
  `TrayRequest.revealBlockID` seam, recorded either way.
- The tray panel's screenshot is a HAND-CHECK item for the next
  drive (the ImageRenderer/NSTableView limit is measured and
  registered, not assumed).

## Batch 3 brief — the recovery doors (J3 + J5 + deleted takes + the placement rider; a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads); this
plan file TOP TO BOTTOM (the constitution, sitting rounds 1–5, the
Environment traps, BOTH batch records, and the adjudication
above); the `architect-phase` skill's "Applying the constitution"
notes.

**Scope — four items:**

1. **J3's final door grammar (rounds 4 + 5, as amended).** On a
   block with an unplaced original: a right-click context-menu
   item ("See original from divide…" / "…from merge…") rendered
   ONLY when one exists; the same act in the ⌘K palette; and **the
   History-face lineage row** — Write's per-block History
   (`CommitBar` → `CommitHistoryView`) and Takes' per-take History
   sheet each carry a quiet row when the block has a preserved
   original ("From a divide on ‹date› — the original is preserved
   · See original"). NO hover glyph, NO bottom-bar button (her
   not-daily-chrome criterion — the history face is summoned).
   The door opens a READ-ONLY PEEK of the original (its takes
   visible, read-cheap tier) with exactly two actions: **Put back
   in note** (the batch-2 tray composition) and **Open this
   note's tray**. **Reconcile the batch-2 bridge:** decide
   whether `revealOriginBlock` now opens the peek (the ruled
   destination) with the tray as its second action, and keep or
   retire the `TrayRequest.revealBlockID` seam — record which and
   why. Registry discipline for every door (P-1).
2. **J5 — the lens-fallback loudness (her standing ruling).** When
   a saved lens's pick dangles at an archived/deleted take
   (`effectiveLensSelection`'s read-time fallback), the lens
   column says it IN PLACE — "This pick was archived — showing
   the default take" (word to the actual state: archived vs
   deleted) — with a ONE-CLICK Restore. **VERIFY the existing
   archived-take restore road first** (the Takes board's archive
   history) and REUSE its op; the deleted-take case uses item 3's
   new op. Registry-declared; refusals diagnose (a sealed note
   refuses through the op, P-2).
3. **Deleted-take recovery (the round-5 ruling — the core half).**
   A small restore op (`restoreVariant`-shaped, the recovery-door
   class: NO undo entry — the door is the recovery, the
   `restoreBlock`/`restoreSection` family; PROVISIONAL-consistent)
   with exact state-transition tests: refuses a live take
   (`variantNotDeleted`-shaped), refuses under a dead block (the
   road is restore the block first), refuses under a sealed note;
   revives the take's own row (label, `fan_position`, parent
   pointer intact — a tombstone flip, never a re-mint). Plus
   `Queries.deletedTakes(blockID:)` + observation, and the
   History face's quiet deleted-take rows with Put back (NO
   countdown — batch 6's clock). Archived takes: byte-unchanged.
   Zero schema; `Sources/` is touched, so the MOBILE suite runs.
4. **The placement rider (adjudication F2 — PROVISIONAL #67 F2).**
   `restoreBlock` flips the surviving tombstoned placement row
   for (block, `last_container_id`) — old position revives —
   falling back to the shipped fresh-at-end mint when no revivable
   row exists. Exact state-transition tests (rows read/written,
   both roads); batch 2's `putBack` position pin and the receipt
   copy follow ("put back where it was" when the row revives).
   The undo-inverse path (`revertDeleteBlock`) is NOT in scope —
   it already lands exactly.

**Constraints:** zero schema; zero `Sources/VariorumCore/Sync/`
lines (the new op is Operations/, not Sync/); no invented product
behavior beyond the recorded rulings; the Environment traps bind
verbatim (re-check instances; never touch a real-store instance;
kills by PID/bundle-id only; no Release builds or `/Applications`
refreshes; you NEVER push). Before Mac suite runs, confirm no
other `xcodebuild` run is active.

**Hallucination guard:** red-on-old pins by behavioral revert,
checksums recorded. At minimum: the context-menu/palette doors
render exactly when an original exists; the History-face row
appears/acts; the peek's two actions; the lens notice fires only
on a dangling pick and its Restore round-trips; the deleted-take
op's refusal set and revival exactness; the placement rider's
both roads.

**Verification (batch end, counts quoted):** core (baseline
**1259/135**); Mac `-project` invocation (baseline **1450/259**
FULLY GREEN — zero allowed reds); spine by TYPE name (51/7);
mobile (314/60, iPhone 16e — core `Sources/` is touched). Confirm
every "Test run with N tests" line. Screenshot-verify where the
environment allows; else record for the next drive (the tray
panel's hand-check is already queued there).

**Record (repo-first):** append the BATCH 3 RECORD to this file —
what shipped per item, the bridge-reconciliation decision, the
archived-take-road finding, pins + revert evidence with
checksums, suite counts, hand-offs — then commit per convention.
The architect verifies before relying on it.

---

## BATCH 3 RECORD — the recovery doors (2026-08-18; fresh Opus implementer)

**Scope built, to the letter of the rulings:** J3's final door grammar
(rounds 4 + 5), J5's lens-fallback loudness, deleted-take recovery (the
round-5 ruling), and the F2 placement rider (the architect's
adjudication). **Zero schema; zero `Sources/VariorumCore/Sync/` lines.**
Two new capability rows (`.restoreTake`; `.showOriginBlock` gains
`.palette` + `.surface`). No Release build, no `/Applications` refresh,
no push.

### THE TWO ANSWERS THE BRIEF ASKED FOR

**THE BRIDGE RECONCILIATION — the peek is the destination; the tray seam
STAYS, demoted to the peek's second action.** Batch 2's
`revealOriginBlock` opened the note's tray with the original's row marked
and said in its own comment that J3 owned the final form. Both view
models now raise an `OriginPeekRequest` instead — the ruled read-only
peek — and `TrayRequest.revealBlockID` is KEPT because the peek's second
action (*"Open this note's tray"*) raises it, with the original's row
still marked. **Why keep rather than retire:** the seam's only purpose
was to answer "which one" in a long list, and that question is asked
exactly when someone leaves the peek for the whole tray. Retiring it
would have meant deleting the mark and the `revealMissing` line batch 2
built, then rebuilding both the first time a door wanted them.

**THE ARCHIVED-TAKE ROAD — VERIFIED, and REUSED unchanged.** The road is
`Operations.unarchiveVariant(id)` (`Operations+Deletion.swift:55`): a
status flip back to `.active`, refusing under a sealed post via
`ensurePlacementUnlocked`, registering no undo entry — the recovery-door
class already. Its shipped doors are the Takes board's archived-take card
(`TakesBoardView.swift:1121`), the Write takes panel
(`WriteTakesPanel.swift:205`) and `EditorViewModel:2190`, all through
`TakesViewModel.unarchiveTake`. J5's Restore calls the SAME op for the
archived case and 13j's new `restoreVariant` for the deleted one; no
second unarchive road was written.

### WHAT SHIPPED

**1 — J3's final grammar (rounds 4 + 5).** Three SUMMONED doors, no
ambient chrome (no hover glyph, no bottom-bar button):

- **the block's right-click row**, rendered only where a live unplaced
  original exists (unchanged P-2 condition), now saying WHICH act
  released it — `OriginPeekCopy.doorVerb(op:)` gives "See original from
  divide…" / "…from merge…" / "…from extract…", and any other or absent
  `origin_op` degrades to "See the original this came from…" rather than
  inventing a word. Both hosts render it (Write's `contextMenuItems`, the
  take card's specs);
- **⌘K**, via a new `RoutedCommand.showOriginBlock` handled in all three
  surface handlers, wired in `ShellActions.paletteActs` + `paletteAction`
  and mapped in `unhandledNote`. Context-blind by nature, so on a block
  with no original it SPEAKS (`OriginPeekCopy.noOriginHere`);
- **the History face's quiet lineage row** — her round-5 amendment
  (*"since it is lineage"*) — in Write's `CommitHistoryView` AND the
  Takes bar's history sheet, through ONE shared component
  (`BlockPastSection`), so the two faces cannot drift.

The door opens `OriginPeekPanel`: the original's own takes read-cheap
(`Text`, never a pane — P3), a heading naming the act and the date, and
exactly two actions. **Put back in note** runs the SAME composition the
tray's originals section runs — extracted to `PreservedOriginPutBack` so
two doors on one act cannot drift on the landing or the receipt — and
**Open this note's tray** raises the tray OVER the peek (a sheet on a
sheet, so closing it returns to the peek rather than to nothing).

**Core, to carry the words:** `Queries.unplacedOrigins` values grew from
a bare id to `UnplacedOrigin { blockID, originOp, at }` — a menu builder
runs synchronously off a held projection and cannot ask the store which
act released the block — plus a per-BLOCK overload (`ofBlock:`) the
History face and the peek read, using the EDGE's own `created_at` as the
date so no container is needed.

**2 — J5, the lens-fallback loudness.** `Queries.danglingLensPicks(lens:)`
is `effectiveLensSelection` seen from the other side, carrying WHY:
`.archived` · `.deleted` · `.gone` · `.foreign`. It rides
`TakesProjection.lensDangles` (the `unplacedOrigins` precedent — the
board already re-reads on exactly the writes that change it, and the map
is absent for lenses with nothing to say). The Lenses board renders
`dangleNotice` under the cell in BOTH column layouts, worded to the state
(`LensFallbackCopy`), with a **Restore** button only on the two states
that have a road — the other two say so instead of offering a button that
could only fail. Restore routes archived → `unarchiveVariant`, deleted →
`restoreVariant`. **Scope, recorded:** LENS columns only; a scratch
column's picks are view-local and cannot dangle across a session.

**3 — Deleted-take recovery (round 5).** `Operations.restoreVariant` —
recovery-door class, **no undo entry** — flips the tombstone and nothing
else: label, `fan_position`, parent, text and status all come back as
they were, and the take's commits (which never carried a tombstone) are
reachable again. Refusals: `variantNotDeleted` (new `OperationError`
case, with words in `OpsRefusalCopy`), `blockNotFound` under a dead block
(the road is restore the block first), `lockedPost` under a seal.
**`default_variant_id` is deliberately NOT re-pointed** — `deleteVariant`
captured `wasDefault` at do-time for its UNDO; a recovery door has no
such memory and guessing would move a pointer she has since set by hand.
Reads: `Queries.deletedTakes(blockID:)` + `observeDeletedTakes`, and
`Queries.blockPast` + `observeBlockPast` (the History face's one
projection). **NO countdown** — the 30-day clock is batch 6's. Archived
takes are byte-unchanged.

**P1 note, stated because it is the `trayCounts` finding one surface
over:** `observeBlockPast` reads `variant`, the one table autosave
writes, so it is held ONLY while the History face is on screen (the
view's `.task` owns the lifetime; `EditorViewModel.blockPast` is built on
open and dropped on close). Cost ∝ the block's own fan history and its
own edges, never the corpus.

**4 — The F2 placement rider (adjudication; PROVISIONAL #67 F2).**
`restoreBlock` now flips the tombstoned placement row for (block,
`last_container_id`) **stamp-matched** — the row THIS deletion took down,
exactly as `revertDeleteBlock` matches — so the old fractional position
and chosen variant revive and Put back lands where ⌥⌘Z lands. It returns
a new `BlockRestoreLanding` (`.itsOldPlace` / `.endOfNote` / `.unplaced`)
so the receipt reads the op's own answer instead of assuming one; the
tray's copy follows (`TrayPath.putBackWhereItWas` etc., all receipts in
one home). The fresh-at-end fallback survives for the case that has no
revivable row (a divide-W/merge release tombstones the placement at
RELEASE time, so a later `deleteBlock` on the unplaced block stamps
nothing). A sealed container refuses on BOTH roads, whole transaction
rolled back. `revertDeleteBlock` untouched, as the brief required.

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

Two new suites, **35 tests**: `RecoveryOpsTests` (19, core),
`RecoveryDoorsTests` (15, Mac) + `RecoveryFaceCaptureTests` (1, the
visual loop) — and one new arm in `NoteTrayTests`.

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A** — the placement revive disabled (`if false, let revivable = …`) | `restoreBlockRevivesTheExactPlacementRow` (4 issues) · `restoreBlockRevivesTheRowThisDeletionTookDown` (2) · `putBackAndStructuralUndoLandTheBlockInTheSameSpot` · `LockPlacementDeletionTests.restoreBlockResurrectsCascadeVictimsButNotIndependentDeletes` (4) · Mac `NoteTrayTests.putBackReturnsADeletedBlockToItsOwnPlace` (3) | `Operations+Placement.swift` → `4f256a71e40c…` (identical) |
| **B** — `restoreVariant`'s three guards dropped | `restoreVariantRefusesALiveTake` · `restoreVariantRefusesUnderADeadBlock` (2) · `restoreVariantRefusesUnderASealedNote` (2) | `Operations+Deletion.swift` → `63959b2bc35d…` (identical) |
| **C** — `danglingLensPicks` blinded (`for row in rows where false`) | `danglingLensPicksNamesEachStateAndSkipsTheHealthyOnes` (4) · Mac `onlyALensColumnWithADanglingPickShowsTheNotice` · `theNoticesRestoreRoundTripsBothStates` | `LensQueries.swift` → `50fb67594aab…` (identical) |
| **D** — `revealOriginBlock` back to the batch-2 tray bridge | `theContextRowOpensThePeekAtTheOriginAndItShowsItsTakes` · `OriginBlockDoorTests.theDoorOpensThePeekAtTheOrigin` | `EditorViewModel.swift` → `f8e539d0217f…` (identical) |
| **E** — `Queries.blockPast` returns an empty projection | `theHistoryFacesPastRegionCarriesLineageAndDeletedTakes` (4) | `EditorSupport.swift` → `5421f36ca545…` (identical) |
| **F** — `doorVerb` always generic | `theDoorsWordsNameTheActThatReleasedTheOriginal` (3) | `OriginPeek.swift` restored to `0080504ccf58…` (identical); the file then took ONE further deliberate fix (the date-only stamp, below), so its recorded baseline is **`d0eeeb6254ef…`** |

**Consequential pin edits, each annotated in place** (the batch-2
precedent — a RULED change, never a quietly relaxed pin):
`LockPlacementDeletionTests`' restore arm now asserts the revived row
(it asserted the opposite, which is the divergence F2 closed);
`NoteTrayTests`' Put-back arm moved with it and gained the fallback's own
arm; `OriginBlockDoorTests` keeps every W10 CLAIM with the door's new
verb, doors and destination; `LineageQueryTests` keeps its claims with
the richer value shape; `CapabilityRegistryTests`' `.surface` union gains
`BlockPastSection` and the routed-note list gains `.showOriginBlock`;
`BlockTOCTests`' restore message follows F2 (its assertion was already
true — the block it restores is the last one).

### THE VISUAL LOOP

**The block-past region IS captured** — `RecoveryFaceCaptureTests`, three
states × two voices, written to the sandboxed host's temp dir
(`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/variorum-13j-batch3-screens`;
`cp` them out to view). **It caught two real defects, both fixed:**

1. the lineage row read *"from a merge on aug 18, 2026 at 6:30 am — the
   original is p…"* — the sentence's own point truncated to make room for
   a minute nobody needs. Fixed at the source (`OriginPeekCopy.stamp` is
   date-only; a divide happens on a DAY) plus `lineLimit(2)` as the belt.
   The tray's rows keep their time deliberately;
2. an empty deleted TAKE rendered as **"(empty block)"**, because
   `TrayRowPreview.line`'s fallback was written for the tray's block
   rows. `BlockPastCopy.rowLabel` now says "(empty take)".

**Hand-check items for the next drive** (measured, not assumed — batch
2's finding stands): `OriginPeekPanel` and `TrayPanel` are SwiftUI
`List`s, i.e. NSTableView-backed, and `ImageRenderer` renders its
unsupported-view placeholder for them. The J5 dangle notice lives inside
the Lenses board's scrolling stack and has no offscreen host either.

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1278 tests / 136 suites PASSED** (baseline
  1259/135 + 19 in 1 new suite)
- Mac (`-project` invocation) — **1467 tests / 261 suites PASSED, FULLY
  GREEN, zero reds** (baseline 1450/259 + 17 in 2 new suites)
- tutorial spine, by TYPE name (the seven from the batch-1 record) —
  **51 tests / 7 suites PASSED** (baseline exact)
- mobile (`VariorumMobile`, iPhone 16e) — **314 tests / 60 suites
  PASSED** (baseline exact). Run because core `Sources/` was touched; the
  only changes after that run were three Mac-app files under
  `App/Variorum/Variorum/Features/Tray/` and test files, none of which
  the mobile target compiles.

### FOR THE ARCHITECT / HER

- **QUESTIONS #68** logged (six lettered entries in her format): F2 built
  as ruled (her ratify still stands), the no-undo-entry recovery class,
  the deliberate default-pointer decision, the four-state lens wording,
  the lens-columns-only scope, and the date-only lineage stamp.
- **A REGISTRY ASYMMETRY, propose-only:** `.restoreTake` is declared
  while the tray's own two Put backs (batch 2) are not. Both are inline
  rows on a recovery panel; P-1's scope note says the registry grows as
  work touches it, so this batch declared what it introduced and left
  batch 2's alone rather than retro-declaring. A tidy-up for the closeout
  or the Design & UI review row, never a silent fix.
- **BATCH 6 HAND-OFFS.** The Trash's Takes filter reads
  `Queries.deletedTakes`; the clock's per-row countdown belongs beside
  `BlockPastCopy`'s rows and the tray's, both of which already render a
  stamp and deliberately no countdown. `restoreVariant` is the Put-back
  op for a take wherever the Trash lists one.
- **PARITY LEDGER.** The phone inherits `restoreVariant`,
  `deletedTakes`, `blockPast`, `danglingLensPicks` and the F2 landing by
  construction (all core) and owes the FACES: a deleted-take row in its
  history, and its lens peeks' dangling-pick notice. The J3 peek is a Mac
  door today.
- **Environment.** No Variorum instance was running at any point in this
  batch (`pgrep` checked before every suite run); no kill, no quit, no
  `/Applications` write, no Release build; no push. No other `xcodebuild`
  was active before any run.
- **Nothing PENDING** — every claim above is from a run in this session.

## Batch 4 brief — the defaults pair (J4/J4b; a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads —
AppSpec §9's `divideDuplicating` and `mergeCeremony` entries are
this batch's core reading); this plan file TOP TO BOTTOM (the
constitution, sitting rounds 1–7 — the rulings are the letter —
the Environment traps, all three batch records, both
adjudications); the `architect-phase` skill's "Applying the
constitution" notes. Reference implementations: the PHONE's
fanned-divide door (mobile parity Stage A) and its CARRY-ALL merge
(parity C5) — read them as the reference for shape and receipts,
never as code to move (Mac faces are Mac-side).

**Scope — the two default flips + the two ceremony doors (rounds
3–4 rulings; her 2026-08-03/08-09 rulings underneath):**

1. **J4 — the divide default flips.** On a FANNED block, the
   divide gesture (⌘⇧D and every existing divide door) runs
   **`divideDuplicating`** — the core op shipped at mobile parity
   Stage A, dormant on the Mac since — instead of opening the W
   ceremony: the displayed take's halves seed B and C; every
   other active take duplicates WHOLE onto both; A released
   preserved (the op does all of this — the Mac work is the
   routing + the receipt). Single-take divide is byte-unchanged
   (plain `divide`). Start/end cuts refuse per the op
   (`invalidCut` — no parking outside the ceremony). The receipt
   tells the duplicate-shape truth (the phone's wording is the
   reference; her accepted consequence — a duplicated take chosen
   on both successors reads twice — is stated calmly, "quick to
   delete" her own words).
2. **J4's ceremony door.** "Divide with Ceremony…" **⌥⌘⇧D** — the
   Block menu, the block context menu, AND the ⌘K palette (round
   4: never only a buried item). Opens the existing W ceremony
   sheet exactly as today. Availability: fanned blocks only (the
   ceremony's standing precondition) — registry-declared; follow
   the registry's existing render/disable grammar (P-1/P-2).
3. **J4b — the merge default flips.** The fanned-pair merge
   gesture (⌘⇧M and every merge door) runs the **CARRY-ALL
   merge**: one pairing of the two displayed takes + every other
   active take carried whole — **composed from the Mac's own
   `mergeCeremony` op, zero core change** (the phone's C5 is the
   composition reference). The instant no-fan merge is
   byte-unchanged. N-way merge chains (the 9d supersession):
   verify how today's chain interacts with the fanned default and
   keep its shipped behavior for unfanned chains; a fanned link
   uses the carry-all composition pairwise — if the chain
   composition surfaces an edge beyond this sentence, STOP that
   half and report (P-5).
4. **J4b's ceremony door.** "Merge with Ceremony…" **⌥⌘⇧M** —
   same three doors; opens the pairing ceremony sheet as today
   (S4-23's ceremony untouched — it demotes, never degrades).
   Fanned-adjacency availability per the ceremony's standing
   precondition; registry-declared.

**Tutorial discipline (P-6):** the spine stays green. If any
tutorial step's COPY describes the old fanned defaults, align the
described flow to the ruled product (bounded, recorded in the
batch record — the tutorial follows rulings; a broken WALK is a
regression, a stale SENTENCE is a copy fix). The full deletion-
chapter overhaul remains batch 7's.

**Constraints:** zero schema; zero `Sources/VariorumCore/Sync/`
lines; ZERO core-op changes (both ops exist — this batch is
routing, doors, receipts, registry); no invented product behavior
— the rulings above are the letter; the Environment traps bind
verbatim (re-check instances yourself; NEVER touch a real-store
instance; kills by PID/bundle-id only; no Release builds or
`/Applications` refreshes; you NEVER push). Before Mac suite
runs, confirm no other `xcodebuild` run is active.

**Hallucination guard:** red-on-old pins by behavioral revert,
checksums recorded. At minimum: the fanned divide gesture mints
the duplicate shape (and does NOT open the ceremony); the fanned
merge composes carry-all (successor fan = the pairing + every
carried take, source fan order); both ceremony doors open their
sheets and fire from all three door kinds + keybinds; unfanned
divide/merge byte-unchanged; the registry walk covers the new
declarations.

**Verification (batch end, counts quoted):** core (baseline
**1278/136**); Mac `-project` invocation (baseline **1467/261**
FULLY GREEN — zero allowed reds); spine by TYPE name (51/7);
mobile ONLY if `Sources/`/`Shared/` is touched (baseline 314/60,
iPhone 16e — this batch should touch neither). Confirm every
"Test run with N tests" line.

**Record (repo-first):** append the BATCH 4 RECORD to this file —
what shipped per item, the chain-composition answer, pins + revert
evidence with checksums, suite counts, hand-offs — then commit per
convention. The architect verifies before relying on it. **Ladder
A follows this batch** (the plan's ladder shape), so leave the
record especially clean: the cold reviewer's anchor is the batch
records + dispositions.

## LADDER A — ROUND 1 (2026-08-18; fresh Fable cold reviewer, REVIEW_PROMPT.md verbatim, zero framing; findings recorded here BEFORE any fix session sees them)

The reviewer reproduced core **1278/136** with its own run and ran
the six new Mac suites (78 tests) targeted. Findings,
severity-ranked (compressed faithfully from the reviewer's report;
the mechanism sentences are the reviewer's):

- **A1 [BLOCKER] · `BlockPastSection.swift:141,201` — the History
  face's "past" region (the round-5 lineage row + deleted-take
  rows with Put back) can NEVER render in the real app: dead by
  construction.** `BlockPastModel.past` initializes empty →
  `isEmpty == true`; the body is `if !model.isEmpty { … .task {
  await model.start() } }` — the `.task` that STARTS the
  observation sits INSIDE the conditional that stays false until
  the observation delivers. No other caller invokes `start()`
  (`EditorViewModel.loadCommitHistory:2087`,
  `TakesBottomBar.openHistory:398` construct, never start). The
  green pins drove the declared `adopt` TEST SEAM directly —
  which is exactly why the suite stayed green over dead
  production wiring. Consequence: her ruled primary door for
  deleted takes does not exist on screen; the lens-dangle notice
  is the only live road. Fix shape: the `.task(id:)` outside the
  conditional (or hosts start the model), with a red-on-old pin
  that mounts against a real store WITHOUT calling `adopt` and
  polls for the row.
- **A2 [MAJOR] · `CrossBlockRefusal.swift:147–148` — a refusal
  actively teaches the WRONG door since batch 4:**
  `.seamBesideFan`'s road clause still says "use Merge Blocks
  (⌘⇧M) to pair the takes yourself" — but J4b flipped ⌘⇧M to
  carry-all; hand-pairing is ⌥⌘⇧M. Reachable: backspace on the
  seam beside an empty-looking fanned block. The texted-seam twin
  (`seamFanRefusal`) WAS updated by batch 4's sweep; this second
  home of the same sentence — inside J8(b)'s own file — was
  missed, and #69's "ALSO SWEPT" paragraph claims the seam
  refusal was fixed. The J8 copy-truth class in the phase whose
  bar is copy truth. Fix: word like the updated twin; pin red on
  old.
- **A3 [MINOR] · `BlockPastSection.swift:50,192–194` +
  `LensFallbackCopy.restoredDeleted` — the `restoreVariant`
  receipts claim the FAN for a take that revives ARCHIVED**
  (archive→delete is a shipped road; the exact flip revives
  `status` as it was — per ruling — so the take lands in the
  archived listing, and a lens pick still dangles as `.archived`
  after "showing its pick again"). Op right, copy wrong (J8
  class). Fix: word to the revived status; pin red on old.
- **A4 [MINOR] · ops doc comments contradict the F2 rider**
  (`Operations+UndoInverses.swift:23–25`,
  `Operations+Placement.swift:213–216` still describe
  restoreBlock as fresh-at-end). Clarity class.
- **A5 [MINOR] · `runMergeChain` + `mergeSelectedBlocks` — a
  fanned chain link whose `CarryAllMerge.compose` returns nil
  (cross-window take change between the one store read and the
  compound) falls to plain `ops.merge`, silently folding that fan
  to lineage** — the pair road refuses in exactly this state
  (`takesChangedMerge`), and the pre-13j chain at least spoke.
  Narrow race; a deterministic pin needs a small injection seam.
  Fix: refuse the link as the pair road does, naming the retry.
- **A6 [MINOR] · `TrayPanel.swift:187–191` /
  `PoolAndTray.swift:78` — `trayBlocks` is observed UNBOUNDED**
  (the 500-window applied in memory; the sibling
  `preservedOriginals` takes `limit` into SQL). Cost ∝ the note's
  whole deletion history. Fix: the `limit: window + 1` shape.
- **A7 [NIT] · `OriginPeekCopy.putBackDone`/`.putBackDoneAtEnd`
  dead + one duplicates a `TrayPath` string** (the drift trap the
  file's own header warns against). Fix: delete.
- **A8 [NIT] · `wholeBlockRun` can bracket one extra trailing
  EMPTY entry when adjacent zero-length entries exist** (lengths
  0,0,0, span `[0,2)` → run `0...2`). All-empty, undoable,
  cosmetic; pinnable through the pure function.

**Clean bill (headlines):** the F2 rider (one transaction,
stamp+container keyed, sync-shaped); `restoreVariant` exact;
ZERO schema / ZERO `Sync/` lines verified across the whole phase
diff; the tray queries' P1 discipline (`trayCounts` never reads
`variant`); J9 geometry preserving A7/#34 authorizations exactly;
J7's fall-through; J4/J4b store-not-projection with the collision
sweep independently re-checked; the J6 removal leaving no live
copy pointing at the dead room; mobile receipts honest.

### Round-1 dispositions (running)

- **A4 + A7 — FIXED at architect adjudication** (the 13e NIT
  precedent; clarity class, mechanisms re-verified by the
  architect — the dead constants grep zero call sites; both ops
  comments aligned to the F2 rider in place). No pins owed
  (clarity class), justification: a future maintainer wiring a
  new door to a documented behavior the op no longer has.
- **A1, A2, A3, A5, A6, A8 — entering the CROSS-MODEL FLOW**
  (CLAUDE.md: reviewer Fable, implementers Opus): findings go to
  the owning batch implementers VERBATIM for agree/dispute with
  rationale (batch 3: A1, A3, A6; batch 4: A2, A5; batch 1: A8);
  responses return to the REVIEWER, which makes the final call
  and implements its confirmed findings in its own session; suite
  green; the implementers get one sanity pass over the reviewer's
  diff; then ROUND 2 re-reviews fresh. Strictly sequential — one
  agent at a time.

### Cross-model flow — implementer responses (recorded before the reviewer sees them)

**Batch 3's implementer (A1, A3, A6): AGREE on all three**, with
fix-shaping context:

- **A1 — AGREE unreservedly** ("the constitution's own
  overlay/sink delivery law — I re-created the class"; the pins
  missed it because all five drive the `adopt` seam and the
  lifetime pin never asserts population — "a real hole in my own
  test design"). Fix-shape constraints: **(i) prefer the
  view-side task moved OUTSIDE the conditional (the Group form),
  NOT host-side `start()`** — `TakesBottomBar` holds `pastModel`
  in `@State` and never clears it on sheet dismissal, so a
  host-side start would leave the `variant` observation running
  after the sheet closes, breaking the held-only-while-on-screen
  P1 property; the Group form preserves it exactly. **(ii)** the
  proposed no-`adopt` red-on-old pin is the right shape;
  `RecoveryFaceCaptureTests` keeps `adopt` (synthetic states by
  design).
- **A3 — AGREE** (its own core pin
  `restoreVariantReturnsAnArchivedTakeArchived` asserts the exact
  flip; the copy path was never crossed because its round-trip
  test deleted an ACTIVE take). Constraints: **(i) the op's
  exactness is RULED (#68(b)) — the fix is copy/face-side ONLY**
  ("revive as active" would silently un-archive something she set
  aside); **(ii)** the receipt needs the post-restore status the
  op doesn't currently report — cheapest honest road: return the
  revived status from `restoreVariant` (a this-batch signature,
  no shipped caller depends on it); the lens notice truthfully
  CHANGES from "deleted" to "archived" with Restore still
  offered.
- **A6 — AGREE, plus two additions:** (i) provenance — batch 2's
  code (disposition wording the reviewer's call); (ii) **CLASS
  COMPLETENESS: a SECOND instance** — `BlockTOCView.swift:92`
  holds `observeTray(postID)`, the same unbounded `trayBlocks`
  fetch as a standing Blocks-mode observation with NO window at
  all. Fix shape: `limit:` defaulting `nil` keeps one-shot
  callers + four test sites compiling; both held observations
  pass `window + 1`.

**Batch 4's implementer (A2, A5): AGREE on both**, verified
read-only in its own session, with fix-shaping context:

- **A2 — AGREE** (its own grep confirms the one surviving phrase;
  "my copy sweep was site-directed, not phrase-directed — which
  is exactly how a second home of one sentence survives").
  Constraints: (i) the two homes are DELIBERATE (texted seam vs
  empty-looking seam — different guards, same promise) — updating
  the line restores truth, but a SHARED CONSTANT at the
  road-clause layer is the stronger close (preserves the
  causeClause/roadClause split batch 1's pin rides); (ii) the
  complete fix is the sweep's CLOSING FORM — a table over every
  user-facing site naming ⌘⇧M or ⌘⇧D, each cell
  current-or-fixed, not one line; (iii) TWO RECORDS OVERCLAIM and
  must be amended by whoever lands A2 — QUESTIONS #69's "ALSO
  SWEPT" paragraph and the batch-4 record's copy-sweep paragraph
  both say the seam refusal was fixed when only the texted twin
  was.
- **A5 — AGREE** ("the asymmetry is real, it is mine").
  Constraints: (i) refuse-the-link is necessarily
  REFUSE-THE-WHOLE-CHAIN (`withCompound` is atomic — the right
  outcome, matching the pair road and the no-partial-acts
  doctrine — but the copy must say the whole run refused); (ii) a
  bare `throw` lands in the J8 enum-dump class (raw description
  at BOTH call sites) — a typed error mapped to
  `takesChangedMerge` in both catches would be needed; (iii) **its
  recommendation, and the stronger shape: a PRE-COMPOUND
  validation** — every failure mode is knowable before the
  compound opens (validate each link's trailing side + the first
  leading side against the one store read), no rows touched, no
  new error type, and the pin needs NO injection seam (the
  validation is a pure function a test calls directly); (iv) a
  SECOND reachability candidate, board-only and UNVERIFIED: the
  board's `mergeSelectedBlocks` has no gap-slot guard (existence
  + contiguity only), so `displayed[id]` is nil for an unsynced
  block with no race required — Write's planner refuses
  `.gapSlot` for chains; whether the board's path reaches the
  silent fold depends on `ops.merge` on a gap block, NOT
  verified — a candidate for the reviewer to check, not a claim.

**Batch 1's implementer (A8): AGREE** — reproduced the arithmetic
from its own code (`starts=[0,1,2]`, `ends=[0,1,2]`, span `{0,2}`
→ run `0...2`), and CORRECTED its own comment's reasoning: the
"strictly increasing" note proves uniqueness WITHIN each lookup
and says nothing about the primary and secondary lookups both
having solutions — which collapse only for a zero-length entry
(the primary then grabs an entry AT the span's boundary).
Trailing-edge only (the leading edge has no mirror). NIT severity
sustained by the implementer ("empty by construction — no prose
reachable; one compound, one ⌥⌘Z; the receipt counts what went").
Cleanly pinnable through the pure function (no store, no AppKit:
`entries([0,0,0])`, span `{0,2}` → `0...2` today, `0...1` after).
Boundary to keep: the `range.length > 1` guard fences this
function off A7's carve and #34's seam — a disambiguation
reaching length-1 spans would route around ruled authorizations.

**All six flow findings: AGREE, unanimous.** The package returns
to the reviewer for final calls + its own fix pass (next entry).

### Sanity passes over the reviewer's fix diff (`d40e46a`; sequential, read-only)

**Batch 3 (A1/A3/A6): CLEAR on all three.** A1 — the Group form
cancels correctly on BOTH hosts (each host mounts the section
conditionally, so the flagged `@State pastModel` retention is now
inert; the `.task(id:)` re-fires on caret-block change because
Write builds a new model). A3 — exact-flip byte-unchanged (the
only body change is `return variant.status` from the fetched row;
#68(b) holds precisely); the lens chain genuinely two-click. A6 —
one-shot callers semantics-identical; the BlockTOC marker composes
with the K11 pin trivially (different surface, no shared state).
Two OBSERVATIONS recorded, neither a concern: (i) with the face
open, caret moves don't rebuild the past region — PRE-EXISTING
and identical to the savepoint list beside it (both halves move
only at `loadCommitHistory`); (ii) `BlockTOCViewModel` reads
`TrayViewModel.window` cross-module — the better trade vs a
second 500; noted in case a later pass hoists the constant.

**Batch 4 (A2/A5): CLEAR on both.** A2 — `fanFoldRoads` sits at
the road-clause layer as specified; `seamFanRefusal`'s assembled
output verified BYTE-IDENTICAL by hand-concatenation; the
`hasSuffix(fanFoldRoads)` pin on both speakers is a structural
close on the drift class itself; the record amendments name the
precise miss without softening. A5 — `chainComposes` validates
exactly the named class; the after-link-1 leading side re-proved
non-nil under the `joinedTake` reasoning; the atomicity constraint
satisfied BY CONSTRUCTION (refusal before `withCompound` opens);
the gap-slot dismissal re-traced in both directions (typed throw
before any join, whole compound rolled back); the one residual
(non-empty fan, nil rendered id) is unreachable under I10 + the
`default_variant_id` reassignment rule. One OBSERVATION, record
only, pre-existing and outside both findings:
**`noRenderableVariant` falls to `OpsRefusalCopy`'s `default:`
arm — "Refused: \(error)", the standing enum-dump family** —
loud and typed, but a raw dump as a sentence. **ARCHITECT
ROUTING: a batch-6 rider** (the enum-dump family's next sweep;
the phase's copy-truth bar makes it in-scope).

**Batch 1 (A8): CLEAR** — the fence proven VACUOUS for texted
entries algebraically (`starts[k] = ends[k] − length[k]` ⇒ any
`length ≥ 1` match passes the fence), walked over the batch-1
geometry pins concretely; the `length > 1` guard untouched
(outside the diff); no leading-edge mirror; BEYOND the brief:
no new nils possible (the inverting case is already guarded), and
the pin's tail case proves the fence didn't over-reach — plus a
second instance of the same class (`index([5,0])`, span `{0,6}`)
verified closed by the same line. Its offer to also pass over the
A2/A5 touches of batch-1 files was DECLINED with reasons: batch 4
verified those diffs including the byte-identity of batch 1's
clause split, and round 2 re-reviews everything — a fourth
consultation on a double-verified copy change buys nothing.

### ROUND 1 CLOSED (2026-08-18)

1 BLOCKER · 1 MAJOR · 4 MINOR · 2 NIT → ALL fixed (6 by the
reviewer per the cross-model flow, 2 at architect adjudication);
zero disputes; three sanity passes CLEAR with record-only
observations routed (the enum-dump straggler → batch 6 rider; the
window-constant hoist + caret-staleness parity noted). End state
verified by the architect's own run: core **1279/136**; the
reviewer's runs: Mac **1499/263 FULLY GREEN** · spine 51/7 ·
mobile 314/60. **ROUND 2 re-reviews fresh** (a real pass over the
fixes and what they touched; new BLOCKER/MAJOR ⇒ round 3).

## LADDER A — ROUND 2 (2026-08-18; fresh Fable cold reviewer) → LADDER A CLOSED

**NO new BLOCKER or MAJOR — round 3 not triggered.** The round-2
reviewer verified all eight round-1 findings genuinely closed AT
THEIR MECHANISMS (its clean bill re-proved A1's both-host
lifetime incl. the no-stale-model reload guard; A2's structural
close with its own phrase-directed grep across App/Shared/mobile;
A3's #68(b) byte-exactness with both production callers checked;
A5's branch-by-branch trace of `chainComposes` against both chain
bodies with every empty-side pass-through landing on a traced
typed refusal; A6 class-complete by its own caller sweep; A8's
fence probed beyond the pin; fix-pass count arithmetic checked;
zero schema / zero `Sync/` re-verified in both fix commits; its
own targeted suite runs green — 35/2 core, 92/8 + 22/2 + 38/2
Mac). **Residue: TWO NITs, dispositioned:**

- **R2-N1 — the A1 re-indent shipped one mis-indented closing
  brace** (`BlockPastSection.swift:251`; compiles and behaves
  correctly). **FIXED at architect adjudication** (whitespace-only
  re-indent; clarity class, no pin).
- **R2-N2 — the A1 zero-size container participates in stack
  spacing:** the Takes history sheet's `VStack(spacing: 8)` now
  renders a doubled (16 pt) gap when the block has NO past — the
  common case; a bare ViewBuilder `if` contributed nothing. The
  container is LOAD-BEARING for the fix (a `Group` rendering
  nothing runs no `.task`; host-side start was correctly rejected
  per the P1 constraint), so this is an accepted-consequence
  candidate. `CommitBar`'s host is spacing-0, unaffected.
  **ROUTED: a batch-6 rider** (absorb the section into the
  sheet's conditional spacing; verified at the next screenshot
  drive alongside the tray-panel hand-check).

**LADDER A CLOSED 2026-08-18.** Two rounds, three reviewer
sessions total this ladder (round 1 + its authorized fix pass in
the same session + round 2), zero open findings, zero disputes
all the way down. Post-ladder state: core **1279/136** · Mac
**1499/263 FULLY GREEN** · spine **51/7** · mobile **314/60**.
Batches 5–7 proceed; ladder B after batch 7.

## Batch 5 brief — the savepoint cadence (J11; a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads —
AppSpec §9's `commit`/`idleAutoCommit` entries and OverallModel
§3's mutability rule are this batch's core reading); this plan
file TOP TO BOTTOM (the constitution, sitting rounds 1–7 — round
1's J11 rulings are the letter — the Environment traps, all batch
records, the LADDER A record); the `architect-phase` skill's
"Applying the constitution" notes.

**The rulings (round 1, question mode):** cadence = **on-note-
close + shorter idle backstop** ("every editing session that
changed a note leaves one quiet savepoint per edited take when
you close/leave it; the existing idle timer drops from 24h to ~2h
as the backstop for notes that stay open; history reads as one
row per sitting; an unchanged take never re-commits"); setting =
**ONE simple enum** ("Every session (default) · Idle only · Only
when I commit"-shaped, exact wording at build; synced; E2EE-clean
— enum semantics, no prose, the `setting.value` column fence).

**Scope — four items:**

1. **On-close auto-savepoints.** When a note stops being the
   open/live note (tab closed · note switched away · window
   closed · app quit — map "close/leave" onto the app's ONE
   liveness authority, `PaneTextAuthority`/`AppSession`; never a
   second lifecycle mechanism), every DIRTY take under it gets
   one quiet `commit(kind:'auto')` — **deduped: only if the text
   changed since that variant's last commit** (the
   `idleAutoCommit` guard's exact pattern). Never at keystroke
   rate; off the main thread like autosave; a sealed note has no
   dirty buffers by construction (no-op naturally). The quick
   note and scraps follow the same rule through the same
   authority. Flush-first ordering: the pending buffer lands
   before the commit reads it (the standing copy-door precedent).
2. **The idle backstop drops 24h → 2h.** The `setting` seed for
   fresh stores AND a one-time value migration `'24'→'2'` **only
   if the stored value is still exactly `'24'`** (no UI has ever
   exposed it — but the guard keeps any hand-set value hers).
   Ordinary synced-setting CAS metadata; ZERO schema.
3. **The ONE cadence setting.** A synced setting key (e.g.
   `savepoint_cadence`), enum values for the three modes;
   Settings gets ONE row. Semantics: "Every session" (default) =
   on-close + the 2h idle backstop; "Idle only" = idle timer
   only; "Only when I commit" = BOTH cadence occasions off.
   **The INSURANCE occasions are NOT governed by this setting
   and stay ON in every mode** — post-seal, locking a dirty
   take, structural-undo divergence insurance, bridge landings
   (they insure what's about to become unreachable; OverallModel
   §3's doctrine) — state this in the setting's help copy so the
   setting never overclaims (the J8 bar).
4. **The history view's quiet-run collapse (the legibility
   half).** In BOTH history faces (Write's `CommitHistoryView` +
   Takes' history sheet), consecutive `kind:'auto'` rows collapse
   to one quiet line ("N quiet savepoints — show", expandable);
   deliberate commits always render prominent. The collapse
   grouping is a pure Domain-style brain with its own tests.
   **Coordinate with batch 3's past region in the same faces —
   the A1 no-adopt pin and the batch-3 pins must stay green**;
   read the LADDER A record's A1 material before touching these
   files (incl. R2-N2's routed spacing consequence — do not
   absorb it here unless trivially adjacent; it is batch 6's
   rider).

**Constraints:** zero schema; zero `Sources/VariorumCore/Sync/`
lines; the tutorial spine stays green (any lesson sentence
describing commit behavior aligns to the ruled cadence — bounded,
recorded; the deletion chapter stays batch 7's); no invented
product behavior; the Environment traps bind verbatim (re-check
instances; NEVER touch a real-store instance; kills by
PID/bundle-id only; no Release builds or `/Applications`
refreshes; you NEVER push). Before Mac suite runs, confirm no
other `xcodebuild` run is active.

**Hallucination guard:** red-on-old pins by behavioral revert,
checksums recorded. At minimum: on-close commits exactly the
dirty takes (clean → none; close-twice → one — the dedupe);
the three modes' occasion matrix (insurance occasions fire in
ALL modes); the 24→2 migration's only-if-default guard; the
collapse brain's grouping; both history faces render the
collapsed run and expand it.

**Verification (batch end, counts quoted):** core (baseline
**1279/136**); Mac `-project` invocation (baseline **1499/263**
FULLY GREEN — zero allowed reds); spine by TYPE name (51/7);
mobile — core `Sources/` IS touched (the seed/migration +
setting), so the MOBILE suite runs (baseline 314/60, iPhone
16e). Confirm every "Test run with N tests" line.

**Parity note for the record:** the cadence SEMANTICS are
document-level (synced settings), but the on-close HOOK is
per-platform — the phone owes its own hook through its own
lifecycle; write the hand-off line in your record (the closeout's
MobileSoul row carries it).

**Record (repo-first):** append the BATCH 5 RECORD to this file —
what shipped per item, the lifecycle-mapping decision (where
"close/leave" actually hooks), pins + revert evidence with
checksums, suite counts, hand-offs — then commit per convention.
The architect verifies before relying on it.

**HELD (2026-08-18): her mid-flight instruction — "pause before
launching batch 5." The brief above is complete and paste-ready;
NO implementer is spawned. Batch 5 launches only at her word.
→ RELEASED 2026-08-19: her word ("continue onto batch 5") —
spawned same day.**

### LADDER A ROUND 1 — THE REVIEWER'S FIX PASS (2026-08-18; the same Fable session, authorized per the cross-model flow)

**Final calls: ALL SIX findings CONFIRMED and FIXED; every
implementer constraint ACCEPTED (none overruled); the A5 gap-slot
candidate DISMISSED with the traced mechanism.** A4/A7 were already
landed at architect adjudication (911f4b7) — both diffs
sanity-swept in this pass: correct, nothing further.

**Per-finding disposition:**

- **A1 (BLOCKER) — FIXED, the Group form.** `BlockPastSection.body`
  now wraps the emptiness conditional in an always-present
  (zero-size when empty) `VStack` carrying the starting
  `.task(id:)`, so MOUNTING the section starts its observation;
  host-side `start()` was rejected exactly per the constraint
  (`TakesBottomBar`'s `@State pastModel` never clears on sheet
  dismissal — a host-driven start would leak the `variant`
  observation past the sheet's life; the view-side task cancels
  with the hierarchy, preserving held-only-while-on-screen, P1).
  The moved body kept its bytes (re-indented only);
  `RecoveryFaceCaptureTests` keeps `adopt` (synthetic states by
  design, per the constraint).
- **A2 (MAJOR) — FIXED, the structural close.** New
  `FannedDefaultsCopy.fanFoldRoads` — ONE home for the roads
  sentence — and BOTH speakers now end in it:
  `CrossBlockRefusal.roadClause(.seamBesideFan)` (was still
  teaching "⌘⇧M to pair the takes yourself") and
  `EditorSurfaceController.seamFanRefusal` (recomposed onto the
  constant; output byte-identical to batch 4's). The
  causeClause/roadClause split is untouched. **The sweep's closing
  form (the constraint's table):** every user-facing site naming
  ⌘⇧M/⌘⇧D was enumerated by phrase-directed grep — 22 sites; ONE
  was stale (this finding's, fixed); all others verified CURRENT:
  the batch-4 five (seamFanRefusal, both Takes-bar helps, both
  helper dictionary entries), the helper's shortcut rows, both
  one-word-take refusals (⌥⌘⇧D parking road), the three ceremony
  refusals in `FannedDefaultsCopy`, `EditorFind`'s
  merge-the-blocks-first road (claims merging, not pairing — true),
  and `OpsRefusalCopy`'s four Divide-splits roads (true under
  either default). **Both overclaiming records AMENDED in place**:
  QUESTIONS #69's "ALSO SWEPT" paragraph and the batch-4 record's
  copy-sweep paragraph each carry the correction note.
- **A3 (MINOR) — FIXED, copy-side only per the constraint; the
  offered op road taken.** `restoreVariant` now RETURNS the revived
  `VariantStatus` (`@discardableResult`; a this-batch signature —
  no shipped caller read a return; the exact-flip semantics are
  byte-unchanged, #68(b) ruled). The three faces read the op's own
  answer: the History face's receipt
  (`BlockPastCopy.restored(_:)` — new `takeRestoredArchived`), its
  Put-back help (worded to the row's status), and the lens restore
  (`LensFallbackCopy.restoredDeletedButArchived` — the notice then
  truthfully re-renders as `.archived` with Restore offering
  unarchive: the two-click chain, pinned). Core pins extended to
  assert both returned statuses.
- **A5 (MINOR) — FIXED, the pre-compound validation (the
  implementer's recommended shape).** New pure
  `CarryAllMerge.chainComposes(order:fans:displayed:)`, guarded at
  BOTH call sites (Write's `runMergeChain`, the board's
  `mergeSelectedBlocks`) BEFORE the compound opens — the whole run
  refuses with `takesChangedMerge`, nothing touched (the
  refuse-whole-chain constraint is satisfied by construction: a
  pre-compound refusal has no partial act to disclaim, and the
  constant's plural already reads as the run); no typed error was
  needed (constraint (ii) moot under the pre-compound shape).
  **The validation deliberately passes EMPTY sides through** — the
  op's typed refusal is the honest diagnosis there (below).
- **A6 (MINOR) — FIXED, both instances, the limit-defaulting-nil
  shape.** `Queries.trayBlocks(_:postID:limit:)` +
  `observeTray(_:limit:)` bound in SQL; `TrayViewModel.start()`
  passes `window + 1` for the deleted half (the originals half
  already did); **the flow's second instance closed**:
  `BlockTOCViewModel.startTray()` now passes the same window,
  adopts through the seam with a `trayTruncated` flag, and the
  Blocks-mode section renders a visible truncation marker (never a
  silent cut). One-shot callers and all four test sites compile
  unchanged (nil default). Provenance: batch 2's code (recorded
  per the constraint). Disposition class: architectural/P1
  discipline — the limit's own state-transition test
  (`trayBlocksHonoursItsLimit`, core) rather than a red-on-old
  claim.
- **A8 (NIT) — FIXED, the trailing fence; the length>1 fence
  untouched.** `wholeBlockRun`'s primary trailing lookup gains
  `&& starts[$0] < range.upperBound`: a zero-length entry sitting
  exactly AT the span's end has `ends == upperBound` without being
  covered (half-open span), and the primary lookup grabbed it —
  one more empty block than the selection covers. Trailing edge
  only, exactly as the implementer's arithmetic said (a zero-length
  entry at `range.location` IS inside the half-open span — no
  mirror). Non-empty entries are unaffected (the fence is vacuous
  for `length ≥ 1`).

**THE GAP-SLOT CANDIDATE (A5's flow rider) — VERIFIED and
DISMISSED.** The board's `mergeSelectedBlocks` indeed has no
gap-slot guard, and a gap's `displayed[id]` is nil with no race —
but the silent fold is NOT reachable through it: a gap slot is
`variantID == nil` at render (`PostRender.swift:56`), and
`ops.merge` → `placedContext` → `renderedVariant`
(`Operations+Structural.swift:23–40`) throws the TYPED
`noRenderableVariant` (or `blockNotFound` for a missing block row)
before any join — the whole compound rolls back and the catch
speaks. Loud on the OLD code and the new alike; there is also no
fan on a gap to fold. Consequence honored in the fix: the
validation passes empty-fan sides through so the op's diagnosis
(not "takes changed") is what she reads.

**PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed;
every revert restored byte-identical, `shasum -a 256`):**

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A1** — the `.task` back inside the emptiness conditional | `RecoveryDoorsTests.theHistoryFaceSectionStartsItsOwnObservationWhenMounted` (the mounted section never populated — the exact dead-wiring mechanism; all 17 adopt-driven siblings stayed green, which is the finding's own evidence) | `BlockPastSection.swift` → `42146f7267…` (identical) |
| **A2** — the road clause back to "use Merge Blocks (⌘⇧M) to pair the takes yourself" | `UndoHintAndRefusalTests.theSeamFanRoadTeachesTheFlippedDefaultsFromOneHome` (4 issues) | `CrossBlockRefusal.swift` → `7e2c6c36c7…` (identical) |
| **A3** — both doors back to the unconditional fan-claiming receipts | `RecoveryDoorsTests.putBackOfAnArchivedDeletedTakeDoesNotClaimTheFan` · `theLensRestoreOfAnArchivedDeletedPickSaysItCameBackArchived` (each caught its door claiming the fan / "showing its pick again") | `BlockPastSection.swift` → `42146f7267…`; `TakesViewModel.swift` → `35afcf040b…` (both identical) |
| **A5** — both pre-compound guards removed | `FannedDefaultsTests.aChainWithAStaleDisplayedTakeRefusesWholeAndTouchesNothing` (2 issues: the old code MERGED all three — "Merged 3 blocks" — and the fan folded silently; the repro is the frozen-projection property itself, choose-away + delete with no reload, no race needed) | `EditorSurfaceController.swift` → `c60b692f55…`; `TakesStructureController.swift` → `0d78e3703c…` (both identical) |
| **A8** — the trailing fence dropped | `WholeBlockDeleteTests.wholeBlockRunDoesNotGrabAZeroLengthEntryAtTheSpansEnd` (2 issues — `0...2` and `0...1`, the implementer's own arithmetic reproduced) | `BlockRangeIndex.swift` → `fe546d77e5…` (identical) |

Plus the pure A5 matrix
(`theChainValidationRefusesStaleDisplayedTakesAndPassesGapsThrough`
— the race class refused anywhere down the run; unfanned links
demand nothing; both gap directions pass through) and the A3 core
return-value asserts (extended in place in `RecoveryOpsTests`,
both statuses).

**SUITE COUNTS (end state, every "Test run with N tests" line
confirmed):** core `swift test` — **1279 / 136 PASSED** (baseline
1278/136 + the A6 limit test) · Mac `-project` invocation —
**1499 / 263 PASSED, FULLY GREEN, zero reds** (baseline 1492/263
+ 7: the A1/A2/A8 pins, both A3 pins, the A5 pair) · tutorial
spine by TYPE name — **51 / 7 PASSED** (exact) · mobile
(`VariorumMobile`, iPhone 16e) — **314 / 60 PASSED** (exact; run
because `Sources/` — the `restoreVariant` signature, the
`trayBlocks` limit — and `Shared/` — the A8 fence — were touched).
Zero schema; zero `Sources/VariorumCore/Sync/` lines; no Release
build, no `/Applications` write, no push; no Variorum instance
running at any check; no other `xcodebuild` active before any run.

**Round 2 re-reviews fresh** per the ladder — its anchor is this
record plus the findings above.

---

## BATCH 4 RECORD — the defaults pair (J4/J4b) (2026-08-18; fresh Opus implementer)

**Scope built, to the letter of the rulings:** J4 (the fanned divide default
flips to `divideDuplicating`), J4's ceremony door ("Divide with Ceremony…"
⌥⌘⇧D), J4b (the fanned merge default flips to the CARRY-ALL composed from
`mergeCeremony`), J4b's ceremony door ("Merge with Ceremony…" ⌥⌘⇧M). **ZERO
schema · ZERO `Sources/` lines of any kind · ZERO `Shared/` lines · ZERO
core-op changes** — the whole batch is routing, doors, receipts, registry and
copy, exactly as the brief fenced it. Two new capability rows
(`.divideWithCeremony`, `.mergeWithCeremony`). No Release build, no
`/Applications` refresh, no push.

### THE CHAIN-COMPOSITION ANSWER (the brief's named question)

**Verified, and BUILT — no edge beyond the brief's sentence appeared.**

- **What the chain did before:** `applyStructural`'s `.mergeChain` (and the
  Takes board's ⌘-click twin) ran `ops.merge` pairwise and NEVER consulted fan
  arity — a fanned link folded its takes to lineage and spoke about it.
- **What it does now:** each link composes through the same
  `CarryAllMerge.compose` the pair road uses. A link whose either side carries
  a live ACTIVE fan runs `mergeCeremony(pairings: [one], carries: [the rest])`;
  an unfanned link keeps `ops.merge` **byte-unchanged**. Link *k*'s LEADING
  side after the first is the previous link's own result, so the chain needs
  exactly ONE store read (all N fans, before the compound) and never re-reads
  mid-compound.
- **The one inference removed:** the next link needs the previous merged
  block's "displayed" take. Rather than assume index 0, `CarryAllMerge
  .joinedTake(of:)` reads the op's own `sources` correspondence for the
  `.pairing` entry — the core's chosen rule (`renderedPairing ?? 0`) always
  selects exactly that take for a one-pairing carry-all, so this is the op's
  answer, not ours.
- **The accepted consequence, recorded rather than discovered:** a carried
  take rides WHOLE and never receives the other side's text — the pair road's
  own ruled consequence. In a chain it compounds: the chosen take is all N
  chosen takes joined, while each source's alternates stand alone beside it.
  That is the same consequence applied twice, not a new class; her doctrine
  covers it ("quick to delete"). **Recorded for her ratify at QUESTIONS #69(a)**
  in case she wants chains excluded.
- **The receipt cannot lie about it:** the count is `takesOnMerged − 1`,
  accumulated from each link's actual result, so a link that fell to the plain
  road (genuinely unfanned, or a displayed take that vanished under the
  gesture) simply is not counted.

### WHAT SHIPPED

**1 — J4, the divide default.** `applyStructural`'s `.divideW` arm forks on
the DOOR: `ceremony` opens the W sheet exactly as before, the default runs
`runDuplicatingDivide`. That road (a) refuses a nil cut — a one-word take —
with the planner's own `.nothingToDo` copy plus the ceremony's parking road
named; (b) **flushes, then reads the live ACTIVE fan FROM THE STORE**; (c)
falls to the ordinary in-place divide when the store says unfanned (the
stale-projection case — `openMergeCeremony`'s own fallthrough shape, with the
locked-take refusal the planner would have given); (d) applies the F-3 guard
(the displayed take must still be in the live fan); (e) runs
`divideDuplicating` with `seam: nil` (A vanishes and two fresh blocks stand
where it stood — no seam vocabulary describes that; the W confirm's precedent)
and the caret at the SECOND successor's start, mirroring the plain divide's
caret rule.

**Why the store read is load-bearing here specifically, traced:** the planner's
`fanArities` come from `model.slots`, which is deliberately frozen while the
buffer is dirty. Before the flip a stale "fanned" merely showed a sheet that
re-read and recovered. After it, acting on a stale "fanned" would RELEASE A
instead of keeping it — a different OUTCOME, not a different view. Pinned from
the other side by `TakesDivideTests
.theForkIsReadFromTheStoreNotTheFrozenProjection`, which the flip makes
stronger (see the pin note there).

The plain `.divide` body was extracted to `runPlainDivide` so the fallback runs
THE SAME code rather than a copy (the 13e `deleteSelectedBlocks` /
`planWholeBlockDeletion` precedent), re-resolving its entry by BLOCK ID because
the fallback arrives after a flush.

**The Takes board's divide door flips with it** (13d Batch 3 made divide native
there): `divideFocused(ceremony:)`, with `prepareDivide` already having flushed,
read the store fan and verified the seed — so the board's road needs no second
read. Same op, same receipt words, ring on the second successor's leading take.

**2 — J4's ceremony door.** `.divideWithCeremony`, verb "Divide with
Ceremony…", `doors: [.menuBar, .contextMenu, .palette]`, `shortcutLabel
"⌥⌘⇧D"`, `takesAccess: .native` (the W sheet has mounted on both boards since
13d Batch 3 — nothing to carry), availability `divideAvailability`. The FANNED
precondition is the ACT's, not the context's — the registry cannot see arity —
so an unfanned target gets an operation-shaped refusal at the door
(`FannedDefaultsCopy.divideCeremonyNeedsAFan`, naming ⌘⇧D). This is the
`.showOriginBlock` split (P-2), and the same words are spoken by Write and by
the board.

**3 — J4b, the merge default.** `.merge`'s arm forks the same way. The
threshold is unchanged (any fan on either side); the fanned side now runs
`runCarryAllMerge` instead of opening the sheet: flush → read both fans from
the store → `CarryAllMerge.compose` → `mergeCeremony(pairings: [the two
displayed takes under the CANON join], carries: [every other active take])`.
**Zero core change.** The unfanned road runs `runInstantMerge`
**byte-unchanged** (the brief's letter — `mergedAwayTakes` and
`speakAboutMergedFans` are untouched with it), and the store-verified unfanned
fallback lands there too. Caret at the join, by the instant merge's own
arithmetic, off the joined take the op returns.

**The Takes board's ⌘-click merge selection flips too** — the row her ruling
names is "every merge door", and that door's own pre-13j comment named row 4b
as the owner of the flip. Its fanned-pair branch used to CARRY the pair to
Write for the sheet; there is nothing left to carry, so every pick — fanned or
not — now merges right there through one chain body with carry-all links. The
pairing ceremony still carries to Write, because that is where its sheet
mounts.

**4 — J4b's ceremony door.** `.mergeWithCeremony`, verb "Merge with
Ceremony…", the same three doors, `shortcutLabel "⌥⌘⇧M"`, `takesAccess:
.moveAndExecute`, availability `structural`. `openMergeCeremony` and
`confirmMergeCeremony` are **byte-unchanged** behind it (its own
stale-projection fallthrough to the instant merge included). An unfanned pair
refuses (`mergeCeremonyNeedsAFan`); a run of THREE OR MORE refuses naming the
chain road (`mergeCeremonyIsPairwise` — the pairing sheet has two columns by
construction, S4-23).

**THE COLLISION SWEEP (⌥⌘⇧D / ⌥⌘⇧M): both FREE.** Swept `EditorCommands
.keyEquivalent`'s whole table, every `.keyboardShortcut(` call site in
`Variorum/` and `Shared/` (58 distinct chords), every `NSMenuItem`
keyEquivalent (there are none), and the one `performKeyEquivalent` override
(⌘S, plus J7's non-consuming ⌘Z/⌘⇧Z hint arm). No `d` or `m` chord anywhere in
the app carries ⌥; the only ones are ⌘⇧D and ⌘⇧M themselves. Her round-4
reasoning holds literally: the plain chord + ⌥, the ⌥⌘Z family's modifier.

**THE COPY SWEEP (the J8 doctrine — copy naming a behaviour the app no longer
has is the defect class).** Five shipped sentences described the old defaults
and now describe the ruled product: the **seam-backspace refusal**
(`seamFanRefusal` — #34's ruling is untouched, but "Use Merge Blocks (⌘⇧M) to
pair the takes yourself" was false; it now names both roads and what each
does), the Takes bar's **Divide** and **Merge** helps, and the helper's
**"divide / the take ceremony"** and **"merge"** dictionary entries.
*(CORRECTED at ladder A round 1, finding A2 — the sweep was site-directed,
not phrase-directed, and MISSED the same sentence's second home:
`CrossBlockRefusal.roadClause(.seamBesideFan)`, the empty-looking seam's
diagnosis, kept teaching "⌘⇧M pairs" until the reviewer's fix pass landed the
shared `FannedDefaultsCopy.fanFoldRoads` constant both speakers now end in.)* The
helper's shortcut list gained ⌥⌘⇧D and ⌥⌘⇧M (the discoverability pin
`everyDeclaredShortcutIsFindableInTheHelper` requires it) and ⌘⇧D/⌘⇧M's rows
now say what they do to a fan.

**TUTORIAL (P-6 — the spine stays green; 51/7 by TYPE name).** Three lessons'
prose aligned, bounded and block-count-safe: **"divide"** gained a block
stating the fanned default in her own terms and its "From Takes" block stopped
claiming divide carries you to Write (false since 13d Batch 3 — a pre-existing
staleness in the very act this batch owns); **"the take ceremony"** now teaches
a SUMMONED door (⌥⌘⇧D) instead of the default; **"merge"** teaches carry-all
first and the pairing ceremony as the by-hand road, keeping every word
`TutorialWalkTests` pins ("pre-paired", "carry"). The staged spare take's own
line says both. One walk pin's LOCATOR moved with the prose (annotated in
place); its claim is byte-identical.

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

One new file, **two suites, 25 tests**: `FannedDefaultsTests` (21) and
`FannedDefaultsBoardTests` (4). Every revert restored to a byte-identical
checksum, verified by `shasum -a 256` before and after.

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A** — `.divideW`'s arm back to opening the ceremony unconditionally | `aFannedDivideDuplicatesInsteadOfOpeningTheCeremony` (4 issues) · `theDuplicatedTakesLandOnBothSuccessorsWithTheirLabels` · `theDuplicatingDivideIsOneStructuralUndoEntry` (2) · `theDivideReceiptTellsTheDuplicateShapeTruth` · `aLockedTakeDoesNotRefuseTheDuplicatingDivide` (3) — **11 issues over 5 tests** | `EditorSurfaceController.swift` → `fc0e0fe093e3` (identical) |
| **B** — `.merge`'s arm back to `openMergeCeremony` on any fan | `aFannedMergeCarriesEveryTakeOntoTheMergedBlock` (4) · `theCarriedTakesKeepTheirTextAndLabels` · `theMergeReceiptCountsWhatLanded` — **6 issues over 3 tests** | `EditorSurfaceController.swift` → `fc0e0fe093e3` (identical) |
| **C** — `CarryAllMerge.compose` returning `carries: []` | `aFannedMergeCarriesEveryTakeOntoTheMergedBlock` · `theCarriedTakesKeepTheirTextAndLabels` · `theMergeReceiptCountsWhatLanded` (2) · `aChainWithAFannedLinkCarriesEveryTakeAlong` · `theCompositionCarriesEveryOtherActiveTake` — **6 issues over 5 tests** | `FannedDefaults.swift` → `5708d94f7e84` (identical) |
| **D** — the three ceremony-door refusals deleted | `theDivideCeremonyDoorOnAnUnfannedBlockRefusesAndNamesThePlainDoor` (2) · `theMergeCeremonyDoorOnAnUnfannedPairRefuses` (2) · `theMergeCeremonyDoorOnAChainRefusesAndNamesTheChainRoad` (3) — **7 issues over 3 tests** | `EditorSurfaceController.swift` → `fc0e0fe093e3` (identical) |
| **E** — the BOARD's divide fork removed (pre-flip: always the sheet) | `theBoardsDivideDoorDuplicatesByDefault` (3 issues) | `TakesStructureController.swift` → `48497b6b3080` (identical) |
| **F** — the BOARD's merge links back to plain `ops.merge` | `aFannedPairMergesRightHereAndCarriesEveryTake` (2) · `aFannedRunOfThreeMergesHereAndCarriesEveryTakeAlong` (2) | `TakesStructureController.swift` → `48497b6b3080` (identical) |

*(A first cut of revert E used `guard ceremony, false else` — which left the
default road running and only reddened the ceremony pin. Recorded because it
is the drill working: the revert was re-cut to the genuine pre-flip shape and
the default pin went red as it must.)*

**Consequential pin edits, each annotated IN PLACE** (the batch-2/3 precedent
— a RULED change, never a quietly relaxed pin). Every one keeps its CLAIM and
moves only its door or its outcome:

- `MergeCeremonySheetTests` (whole suite): every ceremony opening moved to
  ⌥⌘⇧M; TWO pins deliberately keep the default door with a note saying why
  (`anUnfannedMergeStaysInstant`, `aThreeBlockChainBypassesTheCeremony` —
  whose outcome moved with the ruling: the spare now rides the chain).
- `DivideCeremonyCostTests` (whole suite, one header note): every opening moved
  to ⌥⌘⇧D; every cost bound and scan count is measured on the same sheet.
- `StructuralGestureTests`: `aFannedDivideRoutesToTheWCeremonyAndTouchesNoRows`
  → the ceremony door; the `DivideWCeremonyTests` suite's ONE opener → the
  ceremony door (a suite-level note); the round-2/3 fix suites' two openers;
  the differential-apply discriminator's opener;
  `contextMenuItemsFireAndSpeak`'s title literal gains the two ceremony rows.
- `TakesDivideTests`: six ceremony openings → `divideFocused(ceremony: true)`;
  **`theForkIsReadFromTheStoreNotTheFrozenProjection` got STRONGER** — its
  evidence was "a sheet opened", and is now the ACT itself (the duplicate
  shape, which the stale fan could not have produced).
- `FanHandsTests`: `aFannedPairCarriesToWriteForTheCeremony` →
  `aFannedPairMergesRightHereAndCarriesEveryTake` (the flip its own fence
  named), and `aFannedRunOfThree…SaysWhatBecameOfTheOtherTakes` →
  `…CarriesEveryTakeAlong` (the claim — a fan never folds away silently, and
  this surface is never behind Write — is unchanged; both surfaces' answer
  moved).
- `BoundaryFluidityTests.mergeOnFannedBlocksSpeaksAboutTheFan` → the ceremony
  door, where the lineage sentence still belongs (nothing goes to lineage on
  the default road).
- `EditorWindowSmokeTests`: two ceremony openings.
- `OriginBlockDoorTests`: two board ceremony openings.
- `TutorialWalkTests.theMergeCeremonyPairsAndCarriesTheStagedTakes`: the prose
  LOCATOR moved from "opens a small CEREMONY" (no longer true, and that is the
  point) to "Merge with Ceremony"; both promised words still asserted.

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1278 tests / 136 suites PASSED** (baseline exact; no
  `Sources/` line was touched)
- Mac (`-project` invocation) — **1492 tests / 263 suites PASSED, FULLY GREEN,
  zero reds** (baseline 1467/261 + this batch's 25 tests in 2 new suites), run
  AGAIN after every revert was restored
- tutorial spine, by TYPE name (`TutorialBookShapeTests`, `TutorialDoorTests`,
  `TutorialWritingActsTests`, `TutorialTakesActsTests`,
  `TutorialStructureActsTests`, `TutorialLookingActsTests`,
  `TutorialLibraryActsTests`) — **51 tests / 7 suites PASSED** (baseline exact)
- mobile — **NOT RUN, correctly**: `git status` confirms zero files under
  `Sources/` or `Shared/` and zero under `VariorumMobile/` (the brief's own
  expectation)

### FOR THE ARCHITECT / HER

- **QUESTIONS #69 logged** (five lettered entries in her format): the chain's
  compounding carry consequence; the ceremony doors' unfanned refusal (vs.
  performing the plain act); the two ceremony rows rendering unconditionally in
  Write's context menu; the one-word-take refusal naming the ceremony's
  parking; and the divide receipt's wording.
- **A JUDGMENT CALL, stated plainly with its alternative.** The two ceremony
  rows render UNCONDITIONALLY in Write's block context menu, like every other
  structural row there. That menu's grammar is the author's own 2026-07-09
  fire-and-speak posture, recorded in `contextMenuItems` — it already renders
  "Extract Selection" with no selection and "Merge Blocks" with no seam. The
  alternative (render only on a fanned target, the `.showOriginBlock` shape)
  is defensible under P-2 and is one condition away for divide; it is NOT
  cheap for merge, whose precondition needs a planner run at menu-build time,
  and rendering one conditionally and the other not would be two grammars for
  one pair. #69(c) is hers.
- **What is deliberately UNCHANGED:** `Operations.divideDuplicating` and
  `Operations.mergeCeremony` (zero core lines); `runInstantMerge`,
  `mergedAwayTakes`, `speakAboutMergedFans` (the brief's byte-unchanged
  clause — they now speak zero in practice, since every road that reaches them
  is store-verified unfanned; the two helpers are therefore effectively dead
  and were left alone rather than removed inside a defaults flip);
  `openMergeCeremony` / `confirmMergeCeremony` / the whole `DivideWCeremony`
  state machine and both sheets; the seam-backspace REFUSAL rule (#34's
  ruling — only its second sentence changed).
- **PARITY LEDGER.** Nothing new is owed: the phone SHIPPED both shapes first
  (parity Stage A's fanned divide, C5's carry-all merge) and this batch is the
  Mac catching up to them. What the Mac now has that the phone does not is the
  two CEREMONY doors (the phone has neither ceremony by her M-ruling) and the
  carry-all inside an N-way CHAIN (the phone merges pairwise only) — both
  deliberate, neither a debt.
- **Environment.** No Variorum instance was running at any point in this batch
  (`pgrep -fl 'Variorum.app/Contents/MacOS'` checked before every suite run and
  before every revert); no kill, no quit, no `/Applications` write, no Release
  build, no push. No other `xcodebuild` was active before any run.
- **Nothing PENDING** — every count and every claim above is from a run in this
  session.

---

## BATCH 5 RECORD — the savepoint cadence (J11) (2026-08-19; fresh Opus implementer)

**Scope built, to the letter of her sitting-round-1 rulings:** on-leaving
auto-savepoints, the idle backstop 24 h → 2 h, the ONE cadence setting with
the insurance occasions exempt, and the history faces' quiet-run collapse.
**ZERO schema** (one seeded `setting` VALUE — no table, no column, no index;
mirror untouched, `SyncSchema.lockstepVersion` still 6) · **ZERO
`Sources/VariorumCore/Sync/` lines** · no new capability-registry rows (a
Settings picker is not a routed door — the `defaultSegmentation` precedent
beside it) · no Release build, no `/Applications` refresh, no push.

Commits: `2d534cf` (the model half, on its own per CLAUDE.md's
model-changes rule) · `5c38dba` (the core half) · `e84d8f2` (the app half)
· `f092356` (the visual loop + the defect it caught).

### THE LIFECYCLE MAPPING — where "close/leave" actually hooks (the brief's named question)

**The definition, chosen and stated once: a note is LEFT when it stops being
shown by a window.** Every road calls ONE entry —
`AppSession.savepointOnLeaving(_:)` — and every RULE lives below it in
`Operations.closeAutoCommit`. **No second lifecycle mechanism was added:**
liveness stays `PaneTextAuthority`'s inside a surface and the per-post
autosave registry's across surfaces; this reads what the workspace already
knows.

| Road | Hook | Why there |
|---|---|---|
| navigate a pane away · close the split · Open-Beside displacing a pane | `WorkspaceModel.reportingDepartures`, wrapping every mutation of the shown set | `select` is the door every navigation funnels through (its own 13f batch-4 contract), so the signal is complete without instrumenting each door — the same argument that made `visit` the ONE recording point |
| a window closing | `SavepointOnLeave.windowClosing` from `RootView.onDisappear`; `SavepointOnLeave.leaving([postID])` from `NoteWindowView.onDisappear` | deliberately NOT routed through `onNotesLeft`: the workspace is not mutating, it is being torn down, and a teardown depending on a mutation firing is this phase's own ladder-A bug class |
| ⌘Q | the quit registration inside `AppSession.autosave(forPost:)` | that ONE registration point has covered every open post since 13b 1a; the closure now flushes AND savepoints, so quit is covered by construction |
| a quick note filing itself | `QuickNotePad.take()` — the one body its three triggers share | its note is open in no pane, so no other road would ever reach it, and a captured thought with no savepoint is the thin history she reported |

**Deliberately NOT a leaving, each with its reason (all three pinned or
stated in code):** closing an Open-strip row with ✕ (its own contract is
"closes a ROW and nothing else" — the pane goes on showing the note);
moving focus between two panes (both notes are on screen — the signal
compares SETS, which is exactly why); switching modes inside a note.

**WHY THE SIGNAL LIVES ON `WorkspaceModel` AND NOT IN A VIEW'S `.onChange`:**
the workspace already owns the shown set, and — the reason that decided it —
a view-side observer could not be driven by a test without mounting SwiftUI,
which is precisely how a starting `.task` inside a false conditional shipped
DEAD through five green pins at this phase's ladder A (finding A1). Every
pin below drives a real door.

**Flush-first is load-bearing, not tidiness:** `closeAutoCommit` reads
`working_text` ROWS and a leaving arrives inside the autosave debounce by
construction (she stops typing and navigates), so without the flush the
savepoint preserves the text of half a second ago — the 13e E10 copy-door
class, arriving at the cadence. It flushes the **existing** coordinator only
(`postAutosaves[postID]?`): minting one would cache a coordinator AND a quit
registration for a note that was never open, which is the quick note's case
exactly (caught by `QuickNoteMintTests` on the batch's first full run, fixed
at its cause rather than by moving the pin).

### WHAT SHIPPED

**1 — On-leaving savepoints.** `Operations.closeAutoCommit(_:)` is **the
SIXTH quiet auto-commit occasion** (OverallModel §3's list gains one — a
canon delta for the closeout, flagged below). Its body is `idleAutoCommit`'s
shared `autoCommitDirtyVariants`, so the dedupe is the same guard: a take
whose buffer already matches its latest commit writes nothing. What differs
is the two REFUSALS, and both differ for one reason — **a lifecycle moment
must never throw at a surface that is going away**: a vanished container and
a SEALED one each answer `[]` rather than `containerNotFound`/`lockedPost`
(sealing already insured its buffers, and seal-then-navigate-away is the
ordinary case, where the idle sweep's throw is a genuine race guard on a
candidate list). Locked takes are skipped, pools are accepted — both
inherited unchanged.

**2 — The backstop drops 24 h → 2 h.** `seedV1Settings` seeds `'2'`;
`v1_13_savepoint_backstop` moves an existing store **only if its value is
still exactly `'24'`**, so a hand-set value stays hers. `Queries
.idleCommitHours`' fallback follows the seed to 2 (unset and default must
mean one thing — the `defaultSegmentation` precedent). A data-only migration:
no DDL, no mirror change, no lockstep event.

**3 — The ONE cadence setting.** `SavepointCadence` (`every_session` ·
`idle_only` · `only_on_commit`) under the synced key `savepoint_cadence`,
**E2EE-clean by construction** — enum tokens, never prose, so `setting
.value`'s PLAIN classification and its column-fenced disclosure promise hold
untouched. **The gate lives INSIDE the two ops**, in their own write
transactions, so a future door cannot miss it; `autoCommitDirtyVariants` sits
BELOW the gate, which is what leaves the INSURANCE occasions (post-seal,
lock-dirty-take, structural-undo divergence, bridge landings) on in every
mode. Settings ▸ Writing gets one row beside the segmentation default, and
its help NAMES those four occasions in as many words — a setting reading as
"nothing else writes savepoints" while four occasions still do is the J8
copy-truth defect, in the phase whose bar is copy truth.

**4 — The quiet-run collapse.** `Domain/SavepointRuns` (core, so the phone
inherits the brain and owes only a face) groups CONSECUTIVE quiet savepoints;
it is generic over the row type because the two faces hold different values
(Write's carries the pre-split warning; the sheet holds bare `CommitPoint`s)
and show them in OPPOSITE orders (newest-first inline, oldest-first in the
sheet) — neither difference belongs in a grouping rule, and a run is
contiguous read either way. A deliberate savepoint is never folded into
anything; **a LONE quiet savepoint stays its own row** (build-time call,
#70(b) — "1 quiet savepoint — show" hides one line behind a click). Above it,
app-side, `SavepointHistoryFace` (the per-row render decision) and
`QuietRunRow` (the line) are shared by both faces — the `BlockPastSection`
precedent one region down the same panel. **Batch 3's past region is
untouched**: only the commit LIST changed in each face, and the A1 no-adopt
pin plus every batch-3 pin stayed green throughout. **R2-N2's spacing
consequence was NOT absorbed** — it is batch 6's rider and was not trivially
adjacent (it lives in the sheet's `VStack(spacing:)` around the past section,
not in the list).

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

Three new suites, **23 tests**: `SavepointCadenceTests` (11) +
`SavepointRunsTests` (5) in core; `SavepointOnLeaveTests` (10),
`SavepointHistoryFaceTests` (6), `QuietRunRowCaptureTests` (1) on the Mac.
Every revert restored **byte-identical**, verified by `shasum -a 256` AND
`git diff --quiet` against the committed baseline.

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A** — the savepoint half of the entry removed (pre-13j: leaving flushed and nothing else) | `leavingFlushesThenSavepointsWhatSheJustTyped` · `leavingTwiceWithNothingTypedWritesOneSavepoint` · `aWiredWorkspaceSavepointsTheNoteSheNavigatedAwayFrom` · `aClosingWindowSavepointsEverythingItsPanesWereShowing` (2 issues) · `theQuitDoorSavepointsEveryOpenNote` — **5 tests, 6 issues** | `AppSession.swift` → `8162d0d85a6a…` (identical) |
| **B** — flush-first dropped (savepoint without the flush) | `leavingFlushesThenSavepointsWhatSheJustTyped` · `theOnlyWhenICommitModeLeavesNothingBehind` (its "the flush still ran whatever the cadence says" half) · `aWiredWorkspaceSavepointsTheNoteSheNavigatedAwayFrom` · `aClosingWindowSavepointsEverythingItsPanesWereShowing` (2) · `theQuitDoorSavepointsEveryOpenNote` — **5 tests, 6 issues** | `AppSession.swift` → `8162d0d85a6a…` (identical) |
| **C** — the workspace's departure signal silenced (`if !departed.isEmpty, false`) | `navigatingAPaneAwayReportsExactlyThatNote` (3) · `focusMovingBetweenPanesLeavesNothing` (its closeSplit half) · `aWiredWorkspaceSavepointsTheNoteSheNavigatedAwayFrom` — **3 tests, 5 issues** | `WorkspaceModel.swift` → `33103c54745e…` (identical) |
| **D** — the quit registration back to flush-only | `theQuitDoorSavepointsEveryOpenNote` | `AppSession.swift` → `8162d0d85a6a…` (identical) |
| **E** — the cadence gate removed from `closeAutoCommit` | core `theThreeModesGovernTheTwoCadenceOccasionsAndNothingElse` (2) · Mac `theOnlyWhenICommitModeLeavesNothingBehind` | `Operations+Variant.swift` → `f785af3bb6dc…` (identical) |
| **F** — the collapse never fires (`run.count >= Int.max`) | `consecutiveQuietSavepointsCollapseAndDeliberateOnesNeverDo` (4) · `theGroupingIsOrderAgnostic` (2) · `theEdgesHoldEmptyAllQuietAllDeliberate` — **3 tests, 7 issues** | `SavepointRuns.swift` → `bfe3e1983ef5…` (identical) |
| **G** — the migration body emptied | `theMigrationMovesAStoreStillAtTheShippedDefault` | `Migrations.swift` → `adc12521d667…` (identical) |
| **H** — the lifecycle no-ops back to `idleAutoCommit`'s throwing guards | core `aSealedOrVanishedNoteIsAQuietNoOpNotARefusal` (caught `lockedPost`) | `Operations+Variant.swift` → `f785af3bb6dc…` (identical) |

**Recorded because it is the pins working, not a gap:** revert F left the Mac
`SavepointHistoryFaceTests` GREEN. That is correct and deliberate — those
tests construct `SavepointRuns.Row` values directly, because the face
RENDERS a row and does not group; grouping is core's concern and is pinned
there. Two concerns, two pins, neither standing in for the other.

**Two consequential pin edits, each annotated IN PLACE** (the batch-2/3/4
precedent — a RULED change, never a quietly relaxed pin), plus one comment
correction: `MigrationTests.settingsAreSeeded` and `IdleCommitSweepTests`'
default-reading test each keep their CLAIM with the ruled number;
`Phase8ServicesTests.notYetIdleUntouchedAndCleanPostsGetNoCommit` moves its
two probes (23 h/26 h → 1 h/4 h) to straddle the new bar, claim
byte-unchanged; its 26 h sibling's comment stops naming 24 as the bar (26 h
was never the bar, only a time past it).

### THE VISUAL LOOP — and the defect it caught

`QuietRunRowCaptureTests`: three states × two voices, light only (13g batch
2's finding), written to the sandboxed host's temp dir
(`~/Library/Containers/io.lduarte.Variorum.debug/Data/tmp/variorum-13j-batch5-screens`).

**It caught a real defect on its first run.** The collapsed line's verb was
`.buttonStyle(.link)`, which is AppKit-backed: the capture rendered a yellow
unsupported-view placeholder where "show" belongs — so the one inspectable
piece of this batch's chrome could not have been inspected. `.link` was also
off the app's own chrome vocabulary (P-8: `Theme/VoiceControls.swift` is THE
vocabulary). One change closes both: `VoicedButtonStyle(role: .quiet)` with
`tokens.chromeLabel`. **Inspected after the fix, both voices:** the run line
reads as quiet grey chrome and sits visually SUBORDINATE to the deliberate
savepoint row beneath it — which is the whole design requirement.

**Hand-check items for the next drive** (measured, not assumed — batch 2's
finding stands): the two history LISTS themselves are SwiftUI `List`s, i.e.
NSTableView-backed, so `ImageRenderer` draws its placeholder for them; the
collapse IN CONTEXT (a real run inside Write's inline history and inside the
Takes sheet) and the new Settings ▸ Writing row are hand-checks.

### THE MAC SUITE'S REDS — TRACED, AND NOT THIS BATCH'S (reported, per "any red is the batch's to explain")

The batch's first full Mac run came back with a canvas red, and the phase's
own rule is zero allowed reds. **Four full-suite runs plus one on a
worktree at the PRE-BATCH commit settled it:**

| Tree | Test set | Reds — every one a synthesized-mouse-event drag rig |
|---|---|---|
| batch 5 | full, 1516/266 | `CanvasDragTrackingTests.theResizeGripFollowsThePointerToo` |
| batch 5 | full, run 2 | the same one |
| batch 5 | full MINUS this batch's suites — 1499/263, the exact ladder-A test set | `CanvasDrag` ×2 **+** `CanvasBankTests.droppingACardOnTheStripReturnsItToTheBank` |
| **pre-batch `43192a9`** (a read-only `git worktree`, removed after) | full, 1499/263 | `CanvasBank` ×1 **+** `TakesSlotDragTests.theSlotHeightHandleFollowsThePointerOneToOneInsteadOfHalfOfIt` |
| batch 5 | full, final run | **NONE — 1516/266 FULLY GREEN** |

**The mechanism:** every failing assertion is the `midDrag == nil` shape —
the SwiftUI drag gesture had not begun when the rig's mid-drag closure ran.
Those rigs synthesize real `NSEvent`s through `NSApp.sendEvent` and pump the
runloop for fixed 0.03 s steps; under full-suite concurrency the events are
not recognized inside that window. **Standalone every one of them passes**
(verified). The subset differs run to run, and **the pre-batch tree fails the
same class**, so this is neither this batch's product code nor its tests: it
is a load/timing-dependent property of the mouse-event drag rigs on macOS
26.5.x — the same class as the A47c disposition already recorded in
TEXTKIT2_NOTES §3 (standalone green, full-suite red, load-dependent).
**ARCHITECT'S CALL:** whether this earns a §3 entry of its own, a rig
hardening (poll for gesture start instead of a fixed pump), or a
KnownIssues row. Nothing was changed in those rigs by this batch.

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1295 tests / 138 suites PASSED** (baseline 1279/136 +
  16 in 2 new suites)
- Mac (`-project` invocation) — **1516 tests / 266 suites PASSED, FULLY
  GREEN, zero reds** (baseline 1499/263 + 17 in 3 new suites)
- tutorial spine, by TYPE name (the seven from the batch-1 record) —
  **51 tests / 7 suites PASSED** (baseline exact)
- mobile (`VariorumMobile`, iPhone 16e) — **314 tests / 60 suites PASSED**
  (baseline exact). Run because core `Sources/` was touched.

### FOR THE ARCHITECT / HER

- **QUESTIONS #70** logged (six lettered entries in her format): where
  "leaving" is drawn and the three things deliberately not it; the
  no-collapse-of-one rule; the help copy naming the four insurance
  occasions; the only-if-still-default migration guard; the quick note's
  savepoint; and the two-windows consequence.
- **TWO CANON DELTAS OWED AT CLOSEOUT** (recorded, not applied — canon edits
  beyond an author's explicit ruling are not an implementer's):
  **(i) OverallModel §3's "five quiet automatic exceptions" becomes SIX** —
  her ruling adds leaving a note; **(ii) AppSpec §9 gains `closeAutoCommit`
  beside `idleAutoCommit`, and §7's `setting` seed comment now reads
  `('idle_commit_hours','2')`** with the new `savepoint_cadence` key beside
  it. Both are her rulings' direct consequences; neither changes an invariant
  or the schema.
- **PARITY / the phone's owed hook.** The SEMANTICS are document-level and
  the phone inherits them by construction: `closeAutoCommit`, the cadence
  read/write, the 2 h backstop and the run-collapse brain are all core, and
  the gate inside `idleAutoCommit` means the phone's shared
  `IdleCommitScheduler` already obeys the setting. What the phone OWES is
  **its own on-leaving HOOK** (its lifecycle is its own — scene phase, tab
  stacks) plus two faces: the cadence row in `MobileSettingsView` and the
  quiet-run collapse in its take history. `AppSession.savepointOnLeaving` is
  deliberately OUTSIDE the `#if os(macOS)` fence so the phone's hook is one
  call, never a second rule (MobileSoul's brains-in-core line).
- **BATCH 6 HAND-OFF.** R2-N2's spacing rider is untouched and still batch
  6's. Nothing in this batch touches the Trash, the tray or the clock.
- **Environment.** No Variorum instance was running at any point in this
  batch (`pgrep -fl 'Variorum.app/Contents/MacOS'` checked before every
  suite run and before every revert); no kill, no quit, no `/Applications`
  write, no Release build, no push. No other `xcodebuild` was active before
  any run. The pre-batch worktree used for the red-trace was created under
  the scratchpad and REMOVED (`git worktree list` clean); it never touched
  the working tree.
- **Nothing PENDING** — every count and every claim above is from a run in
  this session.

### Sitting round 8 — the purge design's author calls, ruled EARLY at her offer (2026-08-19, while batch 6 runs)

Her opening (verbatim): "what do you need to sak me about delete
now and empty trash? can I help with that now so that the design
can match the purge? or do we have to wait for batch 6?" — the
architect put the four genuinely-hers calls in question mode;
batch 6's memo is now written TO these rulings instead of as an
options catalog.

- **Purge-intent shape RULED: the ONE small synced `purge_intent`
  table** (table · row-id · requested-at; additive). **AND — her
  words, verbatim: "The small purge_intent table is fine and I'll
  authorize the DDL and mirror deploy right now - that's fine for
  them to have."** → Recorded as a PRE-AUTHORIZATION (the R53
  class): once the memo firms the concrete DDL (the table + the
  server-side content-free purged-ids ledger + the per-device
  pull cursor), the §12 lockstep event (marker 6→7) executes
  WITHOUT a further stop — mirror-first choreography unchanged.
  **Consequence flagged to her in the same reply: the marker bump
  makes her PHONE's marker-6 build visibly refuse to sync until a
  fresh phone build installs** (safe by design — outbox intact,
  offline free); the deploy window bundles the phone refresh (an
  author-assist moment — the tunnel install).
- **Horizon drop-out RULED: 60 days** — a device unseen that long
  leaves the horizon; the purged-ids ledger fences a returner
  (re-onboard, never resurrect).
- **Empty Trash RULED: everything, always** — the confirm names
  the full count; scoped removal = filter + per-row Delete Now.
- **Quiet-savepoint pruning RULED INTO the purge design** — the
  memo proposes the numbers ("once older than X, keep the newest
  N quiet per take"; deliberate ⌘S commits NEVER pruned) for her
  ratify.
- **Baked in without a question (her round-2 instinct, restated
  with objection invited, none raised): preserved originals whose
  entire descendant family purges age out with that family.**
- Scope discipline unchanged: batch 6 still BUILDS nothing
  schema-shaped — its memo now carries the deploy-ready DDL draft;
  the build (the lockstep execution + the Delete Now / Empty
  Trash doors + the janitor halves) is a follow-up slot the
  architect scopes at the memo's landing, cast per the standing
  Sync/ rider where the engine is touched.

**Round 8b — the lineage-originals bake-in REFINED at her return
(same day).** Her concern (verbatim): "I think it's fine for
preserved originals whose entire descendant family purges age out
with that family unless they're in some area in the note where it
seems to the user like they'll stay forever (like in the ancestry
area, and not in the trash area). we have to be sure that they'll
move over OR that it's communicated clearly when the block is
deleted like (the ancestor of this block has also been moved to
the trash) or something like that. the issue I don't want is for
someone to think the ancestor being there in that one ancestor
tray is their guaranteed backup and then they freely delete a
block only to realize the ancestor disappeared later. that makes
me wonder if it even should auto delete." The architect's
two-perspective analysis (put to her whole): auto-purge is what
"really deleted" MEANS — the original IS the pre-divide text, so
exempting it falsifies the Trash's core promise in the other
direction — and exemption recreates the orphan class (a live
original whose note purged has NO honest surface; the graveyard
reborn); her failure mode is a PLACEMENT defect, not a semantics
one. **RULED: AUTO-PURGE, VISIBLY MOVED OVER** — all DERIVED
state, zero new delete semantics: while ANY live descendant
exists, the original sits in "Preserved originals" with no clock
(truthfully permanent); the moment its LAST live descendant
enters the Trash, its row MOVES into the Trash countdown riding
the family's exact clock, labeled ("preserved original — goes
with its deleted blocks"); Put back of any descendant returns it
to the forever-section clockless; delete receipts + the Delete
Now confirm name it ("The original preserved from this block's
divide rides the Trash with it"). Whole-note delete: the original
rides under the note's ONE Trash row (never double-listed).
**Build routing: the derived at-risk state, the two listings'
split, and the receipts are batch 6 BUILD items (read-side, zero
schema); the purge rule itself stays the memo's.**

### Sitting round 9 — pruning numbers + the #69 forks (2026-08-19, question mode)

- **Pruning RULED: default 90 days / keep newest 10 quiet per
  take — PLUS a user setting with a "Never prune" choice.** Her
  words (verbatim): "what is the lift on making this a user
  setting? I think 90 days, N=10 is fine for a default, but I
  think users should be able to choose to never prune. it might
  be important for some users." Architect's lift answer (given):
  SMALL — one synced enum setting on the batch-5 shape
  ("History pruning: Standard (90 days, keep 10) · Never",
  default Standard, E2EE-clean); the purge janitor consults it
  before minting any savepoint purge-intent. Deliberate ⌘S
  commits never pruned in either mode. The memo carries the
  setting in its design.
- **#69(a) RATIFIED as shipped:** chains carry all too — one rule
  everywhere; extras stay "quick to delete."
- **#69(b) RATIFIED as shipped:** the ceremony chord always means
  the ceremony — refuse-and-point on a fanless block.
- **#69(c) RATIFIED as shipped:** both ceremony rows render
  always, the menu's standing grammar.
- Her batch-6b question answered in the same exchange: **the
  purge BUILD lands THIS PHASE as batch 6b** (after the memo,
  before batch 7/ladder B) — the lockstep execution, the Delete
  Now/Empty Trash doors, the janitor; the sync-touching half
  seated per the standing Sync/ rider (Fable); the deploy window
  bundles the phone refresh (needs her + the tunnel).
- **Round 9 addendum — the ONE-WINDOW sequencing (proposed to
  her, standing unless she splits it):** batch 6b BUILDS and
  tests the whole purge road headless (fake-server harness; the
  client migration v1_14 + marker-7 code lands DORMANT — no
  client writes what the mirror lacks, the §12 letter); the
  DEPLOY executes at ONE closeout-adjacent window: mirror deploy
  (marker 6→7, her pre-authorization) → fresh Mac Release into
  `/Applications` (her closeout authorization; zero-instance +
  A1 rail) → fresh PHONE build over the tunnel (the parity-round
  mechanism; her presence needed) → closeout. Her daily builds
  never stall longer than the window; she is needed ONCE. Her
  three answers recorded: the phone refresh is THIS session's
  act (the lockstep's own choreography; the mobile project's
  documented tunnel steps followed, or that one act handed to
  its session — same window either way); the Mac refresh
  likewise; **Fragments needs NO update** (it never reads the
  Variorum mirror; the bridge's purged-day behavior is
  Variorum-side, designed in the memo; any Fragments-side
  surprise routes through the contract file to her, never around
  her).

**PROCESS INCIDENT, self-reported (2026-08-19, the round-9
commit):** the architect staged with `git add -A` while batch 6
was LIVE in the same tree — commit `492b4f8` swept the
implementer's in-progress rig-hardening TEST files
(`CanvasBankTests`/`CanvasDragTests`/`TakesSlotDragTests`, ~200
lines) in with the round-9 records, and it is pushed. Harm
assessed LOW: the swept files are the rider's test rigs only
(product code untouched by that rider's letter); the tip stays
correct as batch 6 continues and commits its final state; history
carries one mislabeled intermediate. NOT reverted (reverting would
clobber the implementer's live work — the never-checkout-over-
uncommitted-work rule's spirit). Batch 6 notified so its record
attributes the rig work accurately. **RULE SHARPENED, binding on
this orchestrator from now on: while ANY implementer session is
live in the tree, the architect stages by EXPLICIT PATH only —
`git add -A`/`git add .` are off the table.**

## ARCHITECT ADJUDICATION after batch 5 (2026-08-19)

Verified against the five commits (`2d534cf…9d19d7a`): tree clean,
core **1295/138 REPRODUCED by the architect's own run**, pushed.

- **The intermittent canvas reds (the batch's needs-your-call item)
  — RULED: RIG HARDENING, a batch-6 rider.** The class (`midDrag
  == nil` in synthesized-mouse drag rigs, subset varying by run,
  proven PRE-EXISTING at `43192a9`) is a fixed-sleep anti-pattern
  the Environment traps already outlaw in spirit ("async-poll,
  never sync RunLoop pumping"): the rigs pump a fixed 0.03 s
  instead of polling for gesture start. A flaky class corrodes
  the zero-allowed-reds era faster than any single red — fix the
  rigs (poll-for-condition), product code untouched. HONESTY
  LINE, recorded: until the rider lands, Mac "FULLY GREEN" claims
  are final-run-green subject to this load-dependent class; a
  TEXTKIT2_NOTES §3 entry is NOT taken (the class is event
  synthesis under load, not TK2).
- The two canon deltas (OverallModel §3 five→SIX quiet occasions;
  AppSpec §9 `closeAutoCommit` + §7's seed comment + the
  `savepoint_cadence` setting) are CLOSEOUT duties — recorded on
  the closeout checklist, applied at the ritual as always.
- QUESTIONS #70's six entries join her checkpoint walk.

## Batch 6 brief — the Trash, block archive & the purge memo (J1 + rounds 5/7; a FRESH Opus implementer; self-contained)

**Read first, in full:** `CLAUDE.md` (+ the canon it loads —
AppSpec §7's tombstone conventions, §9's delete/restore family,
SyncSpec §2/§5/§9, and the KnownIssues "Tombstone GC" row are this
batch's core reading — J1 designs WITH that row, one design never
two); this plan file TOP TO BOTTOM (the constitution, sitting
rounds 1–7 — rounds 3/5/7 are this batch's letter — the
Environment traps, ALL batch records, the LADDER A record, both
adjudications); the `architect-phase` skill's "Applying the
constitution" notes.

**Scope — five build items + one design deliverable:**

1. **The Trash surface (round-3 rulings).** The Library recovery
   surface reshapes: Archived (posts) stays its own calm
   no-clock section; the deleted listings become **the Trash** —
   ONE listing over every deleted thing (notes · blocks · takes ·
   books), **sort/filter by kind + date**, per-row first-line
   preview + when it went + **"N days left"** + **Put back**
   (each kind's existing road: `restoreContainer` /
   `restoreBlock` / `restoreVariant` / `restoreReading`). A note
   deleted whole lists as ONE note row — cascade victims NEVER
   double-listed (the exact-stamp discriminator). Deleted blocks
   and takes carry note/block context ("from ‹note›"; if that
   note is itself in the Trash, say so) with an open-there door
   where the note is live. Windowed observations with visible
   markers (the A6 discipline — `limit` into SQL). Names/copy:
   "Trash" (the round-7 tray-name ruling keeps "This Note's
   Tray" distinct).
2. **The 30-day clock (read-side, ZERO schema).** Deleted things
   LEAVE EVERY SURFACE at `deleted_at` + 30 days: the Trash
   listings, the per-note tray's Deleted rows, and every recovery
   query gain the age fence; "N days left" computed at render.
   The per-note tray's Deleted rows now show the quiet countdown
   too (batch 2 deferred it here); archived rows and preserved
   originals NEVER show a clock. Restore surfaces stay honest
   through the window: Put back works to day 30, and past it the
   thing is unreachable — the bytes' physical removal is the
   MEMO's (below), and nothing in this batch pretends otherwise.
   **The Delete Now + Empty Trash doors are NOT built in this
   batch** — they are ruled (round 3) but their backing is a
   sync-visible purge-intent, which is schema-shaped and
   STOP-gated: they land at her explicit go on the memo. Render
   NO disabled doors (P-2).
3. **Block-level archive (the round-7 ruling — the ruled shape
   verbatim in that record).** `archiveBlock` releases the
   placement (tombstoned, stamp-matched like `deleteBlock`'s
   pattern) + stamps `block.archived_at`; the note renders on
   with no view-level filtering; refuses under a sealed note (a
   placement release is a pointer change the seal freezes) and
   refuses the last-block case only if the operations family
   already has such a guard (do NOT invent one — a note may go
   empty by deletion today; verify and match). `unarchiveBlock`
   mirrors: clears the stamp + revives the placement via the F2
   flip road (fresh-at-end fallback). Both register structural
   undo WITH redo halves (the archiveVariant class). The tray's
   first section takes back its ruled name **"Deleted &
   archived"** — archived rows listed, NO countdown, same Put
   back verb. Doors: the block context menu + the Block menu
   ("Archive Block"), registry-declared with honest receipts
   naming the tray; NO multi-select archive (not ruled — record
   as a walk candidate, don't build). `archived_at` is plain
   metadata CAS under sync (the existing classification carries
   the column — verify, don't re-classify).
4. **The Blocks-mode `traySection` routing (round-7 ruling):**
   the section becomes a one-line door opening This Note's Tray
   (its own bounded listing retires; the K11 iconRow pin
   untouched).
5. **Riders:** (a) **R2-N2** — absorb the history sheet's
   empty-past double gap into conditional spacing (the A1
   container stays load-bearing; verify the A1 no-adopt pin
   green); (b) **the enum-dump straggler** —
   `noRenderableVariant` (and any sibling the gap merge road can
   actually surface — verify reachability, word only the
   reachable) gets a real sentence in `OpsRefusalCopy` instead of
   the `default:` dump; (c) **the canvas drag-rig hardening**
   (adjudication above) — the synthesized-mouse rigs poll for
   gesture start instead of fixed 0.03 s pumps; product code
   untouched; run the canvas suites repeatedly enough to show the
   flake class closed (state your run count).
6. **THE PURGE DESIGN MEMO — authored as a deliverable**
   (`notes/plans/phase-13j-purge-memo.md`), NOT built: the
   client+server purge mechanics folding the Tombstone-GC
   KnownIssues row (ONE design); the horizon rule (purge only
   what every device has pulled past — the changefeed visibility
   skew and `sync_row_seq` facts bind); the server-side
   per-device pull-cursor addition; the purge-intent shape that
   backs Delete Now / Empty Trash (schema-shaped — options laid
   out with tradeoffs, §12 lockstep implications named); what
   purge does to the whole family incl. **lineage-only preserved
   originals whose entire descendant family purges** (the
   round-2 carried edge); the Fragments-bridge interaction (a
   purged journal day vs the bridge's sweep); GC of `kind:'auto'`
   savepoints (the J11 record's honest gap) as a candidate
   rider; S2's precise bend, stated. Plain language, her-facing,
   the P-5 memo form. **STOP discipline: nothing schema- or
   server-shaped builds; the memo returns to the author.**

**Constraints:** ZERO schema (the built half); zero
`Sources/VariorumCore/Sync/` lines; the tutorial spine stays
green (the deletion-chapter overhaul is batch 7's — but any
existing lesson sentence the renames stale gets the bounded copy
alignment); registry discipline for every new door; no invented
product behavior — rounds 3/5/7 are the letter; the Environment
traps bind verbatim (re-check instances; NEVER touch a real-store
instance; kills by PID/bundle-id only; no Release builds or
`/Applications` refreshes; you NEVER push). Before Mac suite
runs, confirm no other `xcodebuild` run is active. **Build order
inside the batch: the rig-hardening rider FIRST** (so your own
canvas runs are trustworthy), then the rest.

**Hallucination guard:** red-on-old pins by behavioral revert,
checksums recorded. At minimum: the age fence (day-29 visible +
restorable, day-31 gone from every surface); one-row-per-deleted-
note (no cascade double-listing); the archive ops' exact
state-transitions (both directions, seal refusal, undo/redo
round-trip, the F2-road revival); the tray section's countdown
on deleted rows only; the traySection door; each rider's pin
(R2-N2's spacing, the worded refusal, the rig poll under a
loaded run).

**Verification (batch end, counts quoted):** core (baseline
**1295/138**); Mac `-project` invocation (baseline **1516/266**
— zero allowed reds once your rig rider lands; quote the rider's
repeat-run evidence); spine by TYPE name (51/7); mobile — core
`Sources/` IS touched (the archive ops + queries), so the MOBILE
suite runs (baseline 314/60, iPhone 16e). Confirm every "Test
run with N tests" line.

**Parity note for the record:** the archive ops and the age
fences are core (the phone inherits the brains); the phone owes
the Trash/tray FACES + the archive doors — extend the standing
hand-off line.

**Record (repo-first):** append the BATCH 6 RECORD to this file —
what shipped per item, the memo's existence + its open questions
FOR HER, pins + revert evidence with checksums, the rig rider's
repeat-run evidence, suite counts, hand-offs — then commit per
convention. The architect verifies before relying on it.

---

## BATCH 6 RECORD — the Trash, block archive & the purge memo (2026-08-19; fresh Opus implementer)

**Scope built, to the letter of the rulings** (rounds 3, 5, 7, 8b, 9 and the
two mid-batch amendments the architect relayed): the Trash surface, the
read-side 30-day clock, block-level archive, the Blocks-mode routing, the
three riders, and **the purge design memo**
(`notes/plans/phase-13j-purge-memo.md`). **ZERO schema** — no migration, no
column, no index; `SyncSchema.lockstepVersion` still **6** — and **ZERO
`Sources/VariorumCore/Sync/` lines**. One new capability row
(`.archiveBlock`, two doors). No Release build, no `/Applications` refresh,
no push.

Commits: `c2f08f2` (core) · `8318c1e` (the app) · this record. **The rig
rider landed across `492b4f8` (swept into the architect's records commit
mid-flight — the self-reported incident) and the architect's subsequent
records commits**, not in one clean commit of mine; its final state is in the
tree and is what the runs below exercised.

### THE RIG RIDER — what the flake actually was (built FIRST, per the brief)

The adjudication called it a fixed-sleep anti-pattern and asked for
poll-for-gesture-start. Polling alone did NOT close it; the trace went two
steps further, and both steps are recorded because the first was my own
regression:

1. **A first cut put a full settle turn (layout + async suspension) between
   the synthesized events.** The canvas pins then failed **~1 run in 3
   STANDALONE** — worse than the load-only flake. Mechanism: a card's own
   realization is recomputed mid-drag (`realizedCards` keeps a card only
   while `dragOffsets[id] != .zero`, which is not yet true before the first
   `onChanged`), so a layout pass + suspension mid-sequence can tear the
   gesture's view down before it is recognized. **The event cadence is back
   to bare pumps**; all waiting moved AFTER the sequence.
2. **The real mechanism, and it is not timing per se:
   `NSHostingView.acceptsFirstMouse` is false, so a mouse-down into an
   INACTIVE window is swallowed as the activating click and never reaches the
   SwiftUI gesture.** Suites run in PARALLEL in this target, and any other
   hosted test making ITS window key takes key from the rig's panel
   mid-test — which is exactly why these pins pass solo and fail
   intermittently beside other suites, with a subset that varies run to run.
   The rigs now **re-assert key before every attempt** (the panel is
   non-activating, so it never steals focus from the machine's front app),
   and the poll's redrive is a **whole retry** — up, down, drag — because a
   lone drag event with no accepted down starts nothing.
3. `TakesSlotDragTests` got a third fix from the same drill: the handle probe
   SHORTENS the strip, which MOVES the handle, and one fixed settle turn was
   not enough under load — it now **polls for the layout to come back** before
   returning the point.

**Repeat-run evidence (all post-hardening, final shape):** solo
`CanvasDragTrackingTests` **6/6 green**; the three drag suites together
**11 consecutive green** (3 + 8); and **~10 FULL Mac suite runs** across the
batch with **zero drag-rig reds in any of them** (the reds those runs did
show were this batch's own pins and test worlds, each traced and fixed —
listed below). The last two full runs are clean end to end. Product code:
untouched by this rider.

### WHAT SHIPPED

**1 — The Trash (J1, round 3).** `Queries.trash` is ONE listing over notes ·
blocks · takes · books · stranded originals: filter by kind, sort newest or
oldest, per-row preview, "from ‹note›" context (and *"also in the Trash"*
when that note is gone too), one **Put back** verb routing to each kind's own
road (`restoreContainer` / `restoreReading` / `restoreBlock` /
`restoreVariant` / the tray's `placeBlock` composition), an **Open note**
door only where the note is live. Windowed with the probe row.

**What it deliberately does not list, each for one reason:** anything past
the window; a CASCADE VICTIM (a note deleted whole is ONE row — its blocks
come back with it, so a separate Put back would mean nothing); a stranded
original whose note is itself in the Trash (it rides the note's one row —
her round-8b letter).

**2 — The 30-day clock, read-side, zero schema.** `Domain/TrashWindow` is
the whole rule: `days = 30`, the boundary belongs to the thing being
recovered, "N days left" counts whole days with the last day a whole one, an
unparseable stamp reads as IN and wears no clock. **The fence is a REQUIRED
`now:` parameter** on `deletedPosts`, `deletedReadings`, `trayBlocks`,
`trayCounts`, `deletedTakes` and `blockPast` — required so a new surface must
decide rather than inherit a listing that quietly shows what it can no longer
recover. `archivedPosts` takes none, which is the archive distinction stated
in the signature. **The Delete Now / Empty Trash doors are NOT built and NOT
rendered greyed** (P-2, and the brief's fence); the surface's header says the
window in words so a countdown is never a bare threat.

**3 — Block-level archive (round 7).** `archiveBlock` releases the placement
(tombstoned, stamp-matched to `archived_at`) and stamps the block;
`unarchiveBlock` clears the stamp and revives THAT row (the ratified F2
road), falling back to fresh-at-end. The note renders on with **no
view-level filtering** — rendering walks live placements, so nothing had to
learn a new rule. Refusals: `blockAlreadyArchived` / `blockNotArchived` (new
cases, the `variantNotDeleted` class) and the seal in BOTH directions.
Structural undo WITH redo (the `archiveVariant` class). Doors: the Block menu
+ the block context menu, declared once, native in Write, Takes and Lenses
(R118). `archivedBlocks` gives the tray its listing; `preservedOriginals` now
EXCLUDES archived blocks — a deliberate set-aside is not a leftover, and
leaving them in would have let `placeBlock` re-place a block whose stamp was
never cleared.

**Two consequences named rather than assumed:** the ⌫ badge still counts
DELETED blocks only (her ratified #67(a)), so a note with only archived
blocks carries no badge — which is why the archive receipt names the `note ▾`
item, a door that is always there.

**And a DEFECT I found by checking my own record's claim, recorded because
the checking is the point.** This paragraph first said archived blocks were
excluded from `unplacedOrigins` too — they were not. That population is the
LINEAGE door's, whose "Put back in note" runs `placeBlock`, which knows
nothing about `archived_at`: an archived divide-original was offered there,
and placing it would have left a block that is IN the note and listed as
kept aside, in two places that mean opposite things. Both overloads now
exclude archived blocks (`theLineageDoorDoesNotOfferAnArchivedBlock`, revert
J), and `archivedBlocks` gained a belt — it lists only blocks with no live
placement — so even a future door that placed one without clearing the stamp
could not make the tray lie.

**4 — Her round-8b ruling, as derived state.** `originFamilyClocks` (per
note — the recursion is seeded by that note's own originals, so a held tray
observation costs those families and nothing else) and `strandedOriginals`
(corpus-wide, on a deliberately-opened surface). An original is permanent
while ANY descendant lives; when the last one is deleted its row MOVES into
the tray's clock-bearing section and into the Trash, wearing the family's
clock (the latest deletion among its descendants) and the words *"preserved
original — goes with its deleted blocks"*. Put back of any descendant returns
it to the forever section — pure derivation, pinned as a round trip. The
delete that strands one says so in its own receipt at every delete door
(`StrandedOriginals.note`, asked from the STORE after the delete lands).

**THE ONE MECHANISM THAT SURPRISED ME, traced and pinned:** deleting a block
cascade-tombstones its EDGES, so a family walk that required live edges found
no family at all for exactly the case it existed to detect — every stranded
original read as permanent. The walks now read `derived_from` past its
tombstones (lineage is a fact about what happened; `derived_from` has no
user-facing delete door), and revert B is that pin.

**5 — The Blocks-mode routing (round 7).** The section is a one-line door
opening This Note's Tray, and `BlockTOCViewModel.restoreBlock` — the second
Restore door — retires with the listing it served.

**6 — The riders.** (a) **R2-N2** absorbed as a VALUE
(`TakesBottomBar.pastSectionTopPadding(pastEmpty:)`) so the decision is
pinnable without measuring SwiftUI: the always-mounted A1 container keeps its
life and the sheet stops paying a stack gap for a zero-size view; the A1
no-adopt pin stayed green throughout. (b) **`noRenderableVariant`** gets a
real sentence, with reachability re-verified on the gap-slot road (it is the
last typed refusal those doors could still dump; `blockNotFound`, its sibling
there, already spoke). (c) the rig hardening above.

**7 — THE PURGE MEMO** — `notes/plans/phase-13j-purge-memo.md`, written TO
her rounds-8/8b/9 rulings rather than as an options catalog: what the two
halves of "really delete" mean; the horizon rule with the three binding sync
facts; the 60-day drop-out and the content-free purged-ids ledger that fences
a returner; Delete Now / Empty Trash mechanics; the janitor; family-complete
purge including the lineage-only originals; savepoint pruning at her ruled
90 days / keep-10 with its "Standard · Never" setting; the Fragments-bridge
check; S2's exact bend; and **deploy-ready DDL** — client `v1_14`
`purge_intent`, the mirror twin, `device_cursor`, `purged_row`,
`sync_horizon()`, the RPC edits, marker 6 → 7 — with the phone-refresh
consequence flagged for the deploy window.

### PINS + RED-ON-OLD EVIDENCE (behavioral revert, checksummed)

Two new suites, **23 tests**: `TrashAndArchiveTests` (13, core),
`TrashSurfaceTests` (10, Mac). Every revert restored **byte-identical**
(`shasum -a 256`, first 12 hex shown).

| Revert | Pins that went RED | Restored |
|---|---|---|
| **A** — the tray's age fence removed | `aDeletedThingLeavesEVERYSurfaceAtThirtyDays` (day-31 tray still listed 1) | `PoolAndTray.swift` → `4cd46d5a4f4f` (identical) |
| **B** — the family walk back to LIVE edges only | `anOriginalIsPermanentWhileADescendantLivesAndMovesWhenTheLastOneGoes` (the stranded listing came back empty) | `Trash.swift` → `ab8975b88b0b` (identical) |
| **C** — archive stops RELEASING the placement | `archiveReleasesThePlacementAndStampsTheBlock` (the note still rendered it) · `theArchiveDoorsRefuseWhatTheyMust` (the seal no longer refused — no pointer change to refuse) | `Operations+BlockArchive.swift` → `bccbf64fd7fb` (identical) |
| **D** — unarchive mints fresh at the end | `unarchivePutsTheBlockBackWhereItStood` (2 issues: `.endOfNote`, and the order) · `archiveIsOneStructuralEntryThatUndoesAndRedoes` | `Operations+BlockArchive.swift` → `bccbf64fd7fb` (identical) |
| **E** — the Trash lists cascade victims | `aNoteDeletedWholeIsONERowAndItsBlocksAreNeverDoubleListed` (3) · `aBlockWhoseNoteDiedLaterSaysSo` (2) · `aStrandedOriginalRidesTheNotesOneRowWhenTheWholeNoteGoes` | `Trash.swift` → `ab8975b88b0b` (identical) |
| **F** — the archive receipt silenced | `theWriteDoorArchivesTheCaretBlockAndSaysWhereItWent` (2) | `EditorSurfaceController.swift` → `68e0c85c27e4` (identical) |
| **G** — R2-N2 un-absorbed | `theHistorySheetStopsPayingForAnEmptyPastSection` | `TakesBottomBar.swift` → `9f86a8dfcbe6` (identical) |
| **H** — the enum dump restored | `theGapSlotRefusalSpeaksInsteadOfDumpingItsEnum` (3) | `OpsRefusalCopy.swift` → `363da0abfcfe` (identical) |
| **I** — the stranding sentence removed | `theDeleteReceiptNamesAnOriginalItJustStranded` | `TrayPanel.swift` → `8705fb25e33a` (identical) |
| **J** — the lineage door offers archived blocks again | `theLineageDoorDoesNotOfferAnArchivedBlock` | `Lineage.swift` → `4cdc96a6ce66` (identical) |

**Consequential pin edits, each annotated IN PLACE** (the batch-2/3/4/5
precedent — a RULED change, never a quietly relaxed pin):
`NoteTrayTests`' section-name pin GRADUATES (batch 2 named it "Deleted"
because no op could produce an archived block; round 7 built the state, so
the pin now asserts the heading may name "archived" only while the act is
declared and the tray can list one); `StructuralGestureTests`'
`contextMenuItemsFireAndSpeak` literal gains "Archive Block" (the ceremony
rows' own precedent); `LifecycleFacesTests`' two recovery-face pins keep
their claims through the Trash's shape (`adopt(archived:trash:)`, and the
book's restore road is now the Trash row's one Put back);
`BlockTOCTests`' restore arm runs the OP directly, since the mode's own
Restore door retired by her ruling.

**Three test-world fixes, called out because they are mine and they were
FOUND BY THE SUITE, not by me:** `AppSession` now snapshots a read-side
clock at construction, so three synthetic worlds that built a session outside
any dependency scope (`RecoveryFaceCaptureTests`, `BookCarryTests`,
`ShelfAndPaletteTests`' catalog filter) began reporting an unimplemented-date
issue. Each names its clock now. A static sweep of every
`AppSession(database:)` in the test target confirms none is left.

### THE VISUAL LOOP

**Not captured, measured rather than assumed — the batch-2/3 finding stands
and now covers this batch's two surfaces:** `TrayPanel`, `OriginPeekPanel`
and the Trash listing are SwiftUI `List`s (NSTableView-backed), and
`ImageRenderer` draws its unsupported-view placeholder for them. Writing a
capture arm would have produced a broken image, so none was written.

**HAND-CHECK ITEMS for the next drive** (the batch's whole face): the Trash
section — its filter menu, the sort toggle, a row's countdown beside its
"from ‹note›" context, and the Open-note door; the tray's first section with
all three row kinds visible at once (a deleted block with a countdown, an
archived block saying "kept — no clock", a stranded original with the family
clock and its sentence); the Blocks-mode one-line door; and the Takes history
sheet's spacing with an EMPTY past region (R2-N2's absorption, which is the
one item a screenshot answers better than a value pin).

### SUITE COUNTS (every "Test run with N tests" line confirmed)

- core `swift test` — **1308 tests / 139 suites PASSED** (baseline 1295/138
  + 13 in 1 new suite)
- Mac (`-project` invocation) — **1526 tests / 267 suites PASSED, FULLY
  GREEN, zero reds** (baseline 1516/266 + 10 in 1 new suite), and **green on
  three full runs, the last of them after the revert-J fix**
- tutorial spine, by TYPE name (the seven from the batch-1 record) —
  **51 tests / 7 suites PASSED** (baseline exact)
- mobile (`VariorumMobile`, iPhone 16e) — **314 tests / 60 suites PASSED**
  (baseline exact). Run because core `Sources/` was touched.

### FOR THE ARCHITECT / HER

- **THE MEMO'S OPEN QUESTIONS, and they are two and small** (everything else
  her rounds 8/8b/9 settled): **(i)** whether a device that returns after
  falling out of the horizon should re-onboard SILENTLY or say so first (the
  build's default: say so — a silent reload of a whole device is the kind of
  thing this phase exists to stop hiding); **(ii)** whether Delete Now should
  confirm every time or once per sitting (the build's default: every time).
  The memo also states once, plainly, that between day 30 and the janitor a
  thing is unreachable but its rows are still on disk — which is exactly what
  the purge exists to end.
- **QUESTIONS #71 logged** (five lettered entries in her format): the
  badge's archived exclusion; the Library door still reading "Archived &
  Deleted" while the section inside says "Trash"; the archived-blocks
  exclusion from preserved originals and from the lineage door; the Trash's
  kind filter carrying "Originals" as its own row; and the stranded row
  appearing in BOTH the note's tray and the global Trash.
- **BATCH 6b HAND-OFF.** The memo's §7 carries the build shape. Two seams it
  can reuse: `TrashWindow` already answers "is this past the window", and
  `Queries.trash` already enumerates exactly what Empty Trash would take.
- **BATCH 7 HAND-OFF.** The tutorial's deletion chapter now has three verbs
  to teach as one story — Archive (kept, this note's tray) · Delete (30-day
  clock) · Move to scraps (material for anywhere) — and the archived-vs-Trash
  distinction is the thing her round-5 statement asked be taught EXPLICITLY.
- **PARITY LEDGER.** The phone inherits by construction: `TrashWindow`, the
  fences, `Queries.trash`, `archiveBlock`/`unarchiveBlock`, `archivedBlocks`,
  the stranded-original derivation — all core. It OWES the faces: a Trash
  surface, the tray's countdown and archived rows, and the archive door.
- **Environment.** Her real-store instance was NOT running for most of the
  batch and WAS running (PID 65689, `/Applications`) for the final suite runs
  — never touched: no kill, no quit, no `/Applications` write, no Release
  build, no push. A `fragments`-project `xcodebuild` (another session's) was
  observed running early in the batch; it was left alone, and every Mac suite
  run reported below was started with no other `xcodebuild` active.
- **Nothing PENDING** — every count and every claim above is from a run in
  this session.
