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
before any build work, either way.

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

### THE SITTING IS CLOSED (2026-08-18) — scope confirmed

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
| 1 | **The mini-round:** J7 (⌘Z→⌥⌘Z status-line hint) · J8 (copy truth: the receipt's interim honesty + the diagnosing `.crossesBlockBoundary` refusal) · J9 (whole-block-selection delete → the delete compound; ONE precise trace FIRST) | pending — brief below |
| 2 | **The tray (J2) + the graveyard removal (J6):** the context-bar door ("⌫ N", nonempty-only) + the two-section tray panel with Put back; the global unplaced section leaves the Library surface (pool door dies with it); the delete receipt/help copy graduates to naming the real tray + its door (J8(a)'s completion) | pending |
| 3 | **The lineage door (J3) + lens-fallback loudness (J5):** the context-menu item + ⌘K palette act, the read-only original peek with Put back / Open tray; the lens column's in-place archived-pick notice + one-click Restore | pending |
| 4 | **The defaults pair (J4/J4b):** divide default → `divideDuplicating` (the dormant core op wired); merge default → carry-all (composed from `mergeCeremony`, the phone's C5 the reference); "Divide with Ceremony…" ⌥⌘⇧D · "Merge with Ceremony…" ⌥⌘⇧M in Block menu + context menu + palette | pending |
| 5 | **J11 — the savepoint cadence:** on-note-close auto-commit per edited take (deduped) + `idle_commit_hours` default 24→2 + the ONE enum setting ("Every session · Idle only · Only when I commit"-shaped) + the history view's quiet-run collapse (the legibility half) | pending |
| 6 | **J1 — the Trash:** the surface reshape (rename to Trash; Archived keeps no clock; per-row "N days left" + Put back; sort/filter by kind + date; Delete Now per row + Empty Trash, confirm-once, IN-TRASH ONLY — no full-delete door in any note context, ever) + the 30-day leave-all-surfaces clock; **the purge design memo authored here** (client+server mechanics, the horizon, the per-device pull cursor, the lineage-only-originals edge) → STOP: her explicit go gates any server-shaped build | pending |
| 7 | **J10 — the tutorial deletion chapter** (walk-asserted per P-6: delete blocks in-tutorial, the tray, Put back, cross-block deletion, the Trash, the ceremony doors) + the whole-note-version-history design brief (round 2's deferral deliverable) | pending |

Ladder shape (the 13e precedent): ladder A after batch 4, ladder B
after batch 7 — fresh Fable cold reviewers on `REVIEW_PROMPT.md`
verbatim; adjustable on evidence.

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
