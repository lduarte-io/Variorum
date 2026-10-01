# Phase 13i-b — GATHERINGS: intake · auto-tag · Arrivals · the rule grammar's faces · the Pool tuck

**STATUS: OPEN — kicked off 2026-10-01 by the author's `/architect-phase 13i-b` invocation,
immediately converted to an OVERNIGHT RUN at her word the same sitting ("run overnight, I'm
stepping away from the computer. bundle anything provisional for the morning."). The away-run
rules bind: PROVISIONAL-and-continue; every author call HELD and BUNDLED into § THE MORNING
BUNDLE; no deploys (none exist — zero schema, zero `Sync/`, marker stays 10); the
`/Applications` refresh held unless a sanctioned zero-instance window exists.**

The BINDING DESIGN is `notes/plans/phase-13i-sitting-record-2026-09-30.md` (§3 gatherings,
§4 books/intake/Arrivals, §8 the Pool tuck, §14 dispositions, §17–§24 her later rulings,
§25 the tutorial curriculum as secondary acceptance criteria) read THROUGH the 13i-a execution
record (`notes/plans/phase-13i-a-schema-event.md` — schema DEPLOYED, marker 10; its §9 carries
the hand-offs this phase owns). The brief (`phase-13i-smart-book-identity-brief.md`) is raw
material read through the record.

## KICKOFF MESSAGE (the one she pasted — kept as the run's charter)

> /architect-phase 13i-b — gatherings + intake mechanics, the second of the 13i five. The binding
> design is `notes/plans/phase-13i-sitting-record-2026-09-30.md` (§3 gatherings, §4 books/intake/
> Arrivals, §8 the Pool tuck, §14 dispositions, §17–§24 her later rulings, §25 the tutorial
> curriculum as secondary acceptance criteria) read THROUGH the 13i-a execution record
> (`notes/plans/phase-13i-a-schema-event.md` — the schema is DEPLOYED, marker 10; its §9 carries
> the hand-offs this phase owns). Standing cast; preflight per CLAUDE.md.

**Cast (hers: "standing cast"):** Fable orchestrates and cold-reviews (this session +
ONE fresh `fable-reviewer` ladder over the combined diff at the end), `opus-implementer` per
acceptance unit at xhigh, strictly sequential, a FRESH implementer per unit. Cross-model review
flow per CLAUDE.md (findings verbatim to the implementer; its agree/dispute back to the
reviewer, which makes the final call and implements its confirmed fixes itself). The diff is
expected to touch intake semantics and tombstone-means-decided data shapes — convergence-adjacent
even with zero `Sync/` lines — so the reviewer is `fable-reviewer`, the standing default.

---

## THE BINDING PRINCIPLES (the 13b constitution, copied per the architect-phase skill; its application notes bind alongside)

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

Also binding whole: the sitting record §1–§25 (every ruling), the §25 curriculum as secondary
acceptance criteria — **this phase's spine is lessons 3–4 + 10 and ritual R3** (no act here may
make a lesson sentence false; R3's sequence lands as a headless state-transition walk NOW, the
tutorial chapter's face being 13i-d's), the hallucination guard (red-on-old by behavioural revert
for every bug-class fix), and `notes/SessionResiliencyProtocol.md` end to end.

## §1 SCOPE and NON-SCOPE (the sitting record §15's 13i-b line + the 13i-a §9 hand-offs)

**13i-b ships:** event-driven intake + auto-tag + Arrivals (mechanics AND the ruled minimal
book-surface face), the rule grammar's editor face (replacing the v1 draft vehicle), the two
strengthening doors (Bind into a book · Make a book from this gathering) with the hand-drag
teaching moment, the starred-notes gathering + Quicknotes-stays-ordinary, the Pool tuck, the
in-book filter MECHANICS + `saveFilterAsGathering` (face 13i-d), and the three §9 hand-offs.

**13i-b does NOT ship (fenced, each with its owner):**
- **OWNERSHIP consultation at the doors** — intake's owned arms, the bind confirm's
  copy-in/leave-out listing for owned notes, the owned badges: ALL 13i-c (the sitting §6's door
  enumeration names bind-a-gathering and intake explicitly as 13i-c checklist items). This phase
  builds the intake DECISION TABLE whole (the owned arms present as pure Domain rules, pinned
  headlessly — the R2 repair already encodes the same semantics at convergence) but NO DOOR can
  mint an owned book yet, so nothing user-visible depends on them.
- **The Bookcase, shelves UI, the Bookcase-row arrival count, the Collecting pane, the grouped-by
  control, the vocabulary sweep, the in-book filter bar's FACE, the tutorial chapter's prose** —
  13i-d. (The Arrivals line atop the book's Index/Book surface IS this phase's — §3 below.)
- **Finished/Sealed operations and faces** — 13i-c. Intake HONORS today's `locked` (finished)
  flag; the finish CONFIRM's "N waiting at the door will be dismissed" line lands with the
  finish door's rework at 13i-c, while the dismissal MECHANICS (finishing dismisses pending
  arrivals, §24) land here op-side so `lockReading` is honest from today.
- **The daily Journal's doors/faces** — 13i-e. Schema/`Sync/`/`Server/` — ZERO (anything new is
  a §12 event and a design error here; the smell rule applies). The marker stays 10.

## §2 THE INTAKE DESIGN (the architecture this phase builds to; sitting §4, §14.1–6, §19, §24)

**One pure Domain decision, event hooks in Operations, materialization in the SAME transaction
as the act that fires it.**

1. **`Domain/IntakeDecision.swift` (new, pure):** given the book's facts (live? kind=book?
   rule present? locked? `intake_seating` — nil reads AUTO; `max_posts` vs member count; owned?)
   and the note's facts (matches the rule? already decided — ANY pair row, live or tombstoned?
   membered elsewhere? owned elsewhere? free?) → one verdict: `seat` (status='member', fan END,
   unsectioned) · `arrival` (status='arrival') · `nothing`. The ruled table:
   - no rule / dead book / gathering / locked book → `nothing` (a dead or paused book's intake
     runs nothing; a gathering assembles, never materializes).
   - pair already decided (tombstone-means-decided — the `shelveInDailyJournalBook` precedent
     generalized: ANY `reading_post` row for the pair) → `nothing`. *(AMENDED at the U1
     adjudication — P-13ib-U1-1: on an EVENT, a pair whose only history is DISMISSAL records
     rings again as a fresh ARRIVAL — §24's consequence sentence is the author's later ruling
     and refines this line for exactly that cell; a tombstoned MEMBER row stays decided against
     every occasion, and sweeps honor ANY row. The U1 RECORD carries the full shape.)*
   - at capacity (`max_posts` ≤ live member count) → `arrival` (intake waits at the door).
   - `intake_seating = 'arrivals'` (the join dial: "wait at Arrivals") → `arrival`.
   - plain book + ordinary note → `seat` (multi-membership is legal). Plain book +
     owned-elsewhere note → `arrival` (the bell; unreachable until 13i-c, pinned headlessly).
   - owned book + FREE note → `seat`-as-claim; owned book + membered note → `arrival`
     (both arms headless until 13i-c).
2. **The event hooks (Operations):** intake fires on the APPLYING ACT, never on state —
   `applyTag(toPost:)` (and every door that routes through it: the capture microsyntax, the
   bulk member-tag door, auto-tag itself), `setStarred(note, true)` (for rules carrying star
   terms), and the backfill/catch-up occasions below. Un-tag/un-star are NON-EVENTS (§19,
   ratified §24). The hook resolves the candidate books cheaply: rules referencing the applied
   tag's subtree (via `RuleGrammar.tagIDs` over live books' specs — reading rows are
   author-scale metadata, cost ∝ reading count, P1 holds) or any star term; evaluates
   `matchesRule` per candidate; applies the decision in the SAME transaction. Insert-only:
   intake only ever inserts fresh pairs.
3. **Backfill vs catch-up (ruled):** CREATION-time backfill (a book born from a tag — the spawn
   door, a rule set on a rule-less book) seats current matches DIRECTLY (birth = intent).
   RESUME catch-up (restoreReading, unlockReading, a rule EDIT on a book that had one) routes
   the gap's matches through ARRIVALS (gap = judgment). Both honor tombstone-means-decided.
4. **Finishing dismisses pending arrivals (§24's overrule):** `lockReading` tombstones the
   book's live `status='arrival'` rows in its transaction (born-tombstoned-equivalent decided
   rows — created and deleted rows standing as the decision record; synced as ordinary rows).
   Consequence recorded with it: a dismissed arrival returns only on a FRESH tagging act; the
   un-finish catch-up covers the gap only.
5. **The judgment ops (new):** `seatArrival(pairID)` (status → 'member', position at the END,
   unsectioned; refuses at capacity/locked/dead) · `dismissArrival(pairID)` (tombstone the row
   — the decision record) · and dismissal-at-scale rides `lockReading` (item 4). The copy-in
   arm (owned) is 13i-c's.
6. **AUTO-TAG (the outflow):** `auto_tag_id` on the book. Notes MINTED inside the book
   (`newPostInReading`) get the tag in the mint's transaction; notes ADDED by hand
   (`addPostToReading`) get it too — PROVISIONAL P-13ib-1 (§6), the sitting §14.6 reading
   ("adding to a book is real membership, with auto-tag covering the tagging"). Setting a rule
   offers "also tag the N current members now" (`tagAllMembers(readingID)` — applyTag in a
   loop, ONE transaction, one receipt; this is also the sitting §4's ruled bulk door). A book
   born from a tag (the spawn door) gets intake=T + auto-tag=T. Removing a rule never untags.
   The auto-tag's own application FIRES intake on other books (event-driven, idempotent by
   tombstone-means-decided; no loops — intake is insert-only and the pair decided).
7. **Sync posture (zero `Sync/` lines):** every write above is ordinary rows through the
   operations API (S1); two devices reacting to one act converge via the SHIPPED R1 status-aware
   pair dedupe (13i-a); dismissal-vs-seat races are the SHIPPED documented tombstones-win
   coexistence. The convergence suites already pin these — this phase adds NO repair and
   changes none. Any discovered need for one is a STOP-and-report, not a build.

## §3 THE ARRIVALS FACE (this phase's half; sitting §4's clutter mandate)

Invisible when empty (the common case). When occupied: ONE muted line atop the book's
Index/Book surface ("N at the door" — wording from the voice vocabulary, 13s re-voices later),
expanding INLINE to the pending rows with per-row judgment doors (Add · Dismiss; the copy-in
arm arrives with 13i-c). Never a persistent panel. Arrivals order: arrival rows list by
`created_at`; a seated arrival lands at the END, unsectioned (the unsectioned bin already
renders last). The Bookcase-row accent count is 13i-d's (no Bookcase exists). The note-side
membership chip stays SILENT about arrivals this phase — PROVISIONAL P-13ib-2 (§6).
P1: the line renders ∝ the pending set (a bounded per-book count query, observed; zero
corpus scans).

## §4 THE OTHER DELIVERABLES

- **The rule editor (replaces the v1 draft vehicle):** `SmartSpecSheet` + `Queries.legacyDraft`
  retire. The new face edits the v2 tree directly for the shapes the grammar offers — tag terms
  (picked by tag, stored by ID, displayed by live path; "(deleted tag)" for dead terms) and the
  star term, combined with and/or/not and grouping. GRANDFATHERED legacy terms render READ-ONLY
  ("this rule carries an old date/profile term") and are never offered (#166(d)). The editor
  serves gatherings AND books (a book's rule IS its intake; the sitting §4's Collecting-pane
  sentences are 13i-d's re-homing of this same face). It carries the join dial
  (`intake_seating`) and the auto-tag row for books, minimally faced. The write stays the one
  choke point (`setReadingQuerySpec`); a rule EDIT on a living book routes the gap through
  Arrivals (§2.3) and offers "also tag the N current members" when auto-tag is set (§2.6).
  `legacyDraft`'s retirement is total only if no other consumer remains — verify, else record.
- **The two strengthening doors (§3 of the record):** **Bind into a book** — in place, SAME row
  (§19.6 ratified: name, star, shelf spot survive): materialize the current assembly as
  `status='member'` rows in assembly order, `kind` → 'book', `sort_field` → manual; the rule
  STAYS and intake KEEPS RUNNING (supersedes N38-A's stop; `convertSmartReadingToCurated` is
  the mechanical precedent to recast — its undo/redo discipline rides). **Make a book from this
  gathering** — spawn: a sibling book, rule copied, intake=T (+ auto-tag if the rule is one
  tag? NO — auto-tag defaults OFF on spawn-from-gathering; the ruled auto-tag=T default is for
  "a book born from a tag", the from-tag mint; PROVISIONAL P-13ib-3, §6), creation-time
  backfill seats the current matches, the gathering survives. **The hand-drag teaching
  moment:** a hand-drag inside a gathering's view offers "Turn into a book to arrange by
  hand?" → the bind door (an OFFER on the status seam, P-2's fire-and-do).
- **The starred-notes gathering:** seeded as an ORDINARY gathering, rule `{"star":true}`,
  unshelved (§19.3's working-objects rule), no delete guard, re-makeable. Its assembly is the
  FIRST consumer of `ruleMatchSQL`'s `starredNoteIDs` context (the 'starred' setting's NOTE
  targets, cap `Operations.starLimit`) — wire every assembly/pool/chip call site that can meet
  a star term. Seeding: fresh stores AND existing ones, by the seeded-books silent-ensure
  discipline (tombstone-respecting: a deleted one stays deleted). Name + casing PROVISIONAL
  P-13ib-4 (§6). **Quicknotes stays an ordinary seeded gathering** (§20, ratified §23 —
  already true by the 13i-a recast; verify no special identity/guard survives, record).
- **The Pool tuck (§8):** the Pool's definition stays bookless; the VIEW tucks gathering-shown
  notes behind the masthead count — "Pool · 2 notes · 14 in gatherings · show" — and an
  empty-but-gathered Pool says it in the empty state. Mechanics: the pool query splits bookless
  into {shown-by-some-live-gathering} vs {not} (each gathering's `ruleMatchSQL` over the pool
  listing — cost ∝ listing × gathering count, bounded, P1's letter).
- **The in-book filter MECHANICS (§18.1; face 13i-d):** the query support for a view-local
  tag/star filter over a book's assembly (never mutating membership) + the
  `saveFilterAsGathering(readingID, filter)` op (rule = the book's tag association ∧ the
  filter — where the boolean grammar earns its keep). Headless: pins, no face.
- **The 13i-a §9 hand-offs:** (a) the wing-scoped subtree constraint in `ruleSQL` — add
  `applied.wing_id = root.wing_id` NOW as pure hardening (no door can mint cross-wing
  applications yet; the pin inserts the state directly — exactly what §9 licensed "once a door
  exists" is read as: once a PIN can exist, and it can, by direct row insertion); (b) the
  membership chip's "arriving" face — P-13ib-2, held; (c) the star term's `starredNoteIDs`
  wiring — taken by the starred-gathering work above, every call site enumerated.

## §5 ACCEPTANCE UNITS (four; evidence named before the first spawn — the sizing rule)

Sizing statement (PhaseSizingGuidance, said rather than assumed): FOUR units, ONE implementer
session each, strictly sequential; TWO are phase-sized (U1 — an op family; U3 — a new
panel + two doors), U2 and U4 smaller; one theme (gatherings + intake). Within the guidance's
letter (at most two phase-sized under one theme). Her standing word: "if you distribute
everything we've decided through the 5 phases it'll likely be fine."

- **U1 — INTAKE + AUTO-TAG + THE JUDGMENT OPS (operations/domain; §2 whole).** The decision
  table pure in Domain; the hooks; backfill/catch-up; finish-dismisses; `seatArrival` /
  `dismissArrival` / `tagAllMembers`; the `ruleSQL` wing-scoping hand-off (a). **Evidence:**
  exact state-transition suites per op/occasion (incl. the owned arms headless, the decided-pair
  no-ops, capacity, the dial, catch-up vs backfill), a headless soak (randomized
  tag/star/mint/judge sequences — invariants: no duplicate live pair, no arrival counted as
  member, intake never evicts), **and the R3 ritual as a headless walk** (`GatheringRitualTests`:
  tag two notes → gathering shows both → untag one → it leaves → bind → reorder → untag the
  other → it STAYS) — the phase's acceptance spine, plus lesson-sentence truth checks (§25
  lessons 3–4). Full core suite green.
- **U2 — THE ARRIVALS FACE (UI; §3).** The muted line + inline expansion + judgment doors on
  the book's Index/Book surface; receipts/refusals on the one status seam (18i's kinds); the
  capability registry carries the new acts (P-1). **Evidence:** mounted pins + the orchestrator's
  hands-on dev-store walk, both voices and appearances, captured (tag a note into a living
  book at capacity → it waits at the door → seat it → it lands at the end, unsectioned;
  dismiss → it never returns on rule-match, returns on a fresh tagging act).
- **U3 — THE RULE EDITOR + THE TWO DOORS (UI; §4 items 1–2).** The grammar face (tags + star,
  and/or/not; legacy terms read-only; `SmartSpecSheet`/`legacyDraft` retired), the join dial +
  auto-tag rows, bind-in-place, spawn, the hand-drag teaching offer. **CARRIES F-1 (mandatory,
  before the run's install):** the conversion sheet's "New tag matches will stop arriving
  here." is FALSE since U1 and its "(collecting)" sibling offer now DOUBLE-collects — the
  rebuilt bind door retires both. **And F-4's ruling (architect, 2026-10-01 — PROVISIONAL
  P-13ib-6):** the bind's structural UNDO leaves NO live member row on the reverted row — a
  gathering holds nothing (§1's table is the law); the inverse tombstones every live member
  row standing on it at the revert, intake-seated and hand-added alike (their notes keep
  showing wherever the rule matches them). **Evidence:** mounted pins
  (incl. "saving never silently drops a term" — the undraftable hazard retired WITH the draft
  vehicle) + the orchestrator's walk (edit a rule to tag ∧ star; bind a gathering and watch
  identity survive — same row id, name, star; spawn and watch backfill seat; the teaching
  moment on a drag).
- **U4 — STARRED GATHERING · QUICKNOTES VERIFY · THE POOL TUCK · FILTER MECHANICS (§4 items
  3–5).** **Evidence:** state-transition + query pins (star term end-to-end through the setting
  context; the tuck's split; `saveFilterAsGathering`'s minted rule) + the orchestrator's walk
  (star a note → the starred gathering shows it; unstar → it leaves instantly; the Pool
  masthead counts and the show toggle; empty-but-gathered state).

Then: ONE `fable-reviewer` ladder over the combined diff (REVIEW_PROMPT verbatim, zero framing;
findings repo-first; cap three rounds) → closeout (no deploy; canon deltas DRAFTED and
PROPOSED in the morning bundle, landing at her word — the 18l-c precedent; the MOBILE PARITY
line; the master plan; the handoff).

## §6 PROVISIONALS MADE AT THIS KICKOFF (the away-run's calls; each logged in QUESTIONS at close; § THE MORNING BUNDLE carries them)

- **P-13ib-1 — auto-tag applies on HAND-ADD too** (not only mint-inside). Ground: sitting
  §14.6's "adding to a book is real membership, with auto-tag covering the tagging." The
  alternative (mint-only) is one guard to add.
- **P-13ib-2 — the note-side membership chip says NOTHING about arrivals this phase.** Ground:
  arrivals are "NEVER counted/listed/worded as membership" (schema note), her clutter mandate,
  and the 13i-a §9 hand-off explicitly posed it as HER question — inventing a chip state
  autonomously would be new product behavior. The richer face is one chip-state to add.
- **P-13ib-3 — the SPAWN door copies the rule with intake=T but auto-tag OFF.** Ground: the
  ruled "intake=T + auto-tag=T" default attaches to "a book born from a TAG"; a gathering's
  rule may be a boolean tree with no single tag to flow out. Where the spawned rule IS one bare
  tag, the editor's auto-tag row is one click away.
- **P-13ib-4 — the starred gathering seeds in every store, unshelved, named "starred notes"
  (lowercase).** Ground: her master-plan instruction (build at 13i), §19.3's working-objects
  rule (unshelved), the quiet-vocabulary casing of her working surfaces. Name/casing is one
  constant.
- **P-13ib-5 — intake runs iff: live row · `kind='book'` · a readable rule present · not
  locked.** NULL `intake_seating` reads AUTO (join quietly). A MALFORMED rule runs no intake
  (fail closed, the standing per-consumer letter).

## §7 ENVIRONMENT TRAPS (binding; the standing invariant core, carried per the skill)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH;
real-store instances are treated by STORE, never quit/killed; no Release builds or
`/Applications` refreshes while one lives — and the refresh FOLLOWS the acceptance walks
(sizing rule 4), held to a sanctioned zero-instance window and otherwise bundled.
`xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`
with suite-level `-only-testing` only, confirming the "Test run with N tests" line (skips
counted — read the `skipped:` lines); zsh `pipestatus`; NEVER a custom build configuration
(non-"Debug" names strip the DEBUG oracles); suites beside a live session flash test windows —
prefer zero-instance windows; backups WAL-safe, UTC names, into `Backups/safety-copies/` (the
A1 rail) before ANY real-store touch (none is planned — zero schema; the dev store carries the
walks); never `git checkout` over uncommitted work; push after every commit; never force-push.
The dev store (`io.lduarte.Variorum.debug`) NEVER syncs; sync evidence is the fake-server
suites. Foreground waits only; poll logs with `grep -q … && break` loops (the `tail -f` trap).
Background-wait = death for subagents. Known full-run flake rows (KnownIssues 86 + the
load-flaky family): adjudicate by isolation + attribution before treating any red as this
phase's. Walk drives (cliclick/WalkKit) are DEV-STORE Debug only and need the machine
author-free with its own `caffeinate -d`; if the screen is locked overnight, record and fold
the walk into the morning.

## U1 RECORD — intake + auto-tag + the judgment ops (opus-implementer, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** no dev-store GUI walk (U1 is an op
family with no face; its evidence-of-kind is the plan §5's headless set — the first VISIBLE walk of
intake is U2's orchestrator walk); no face of any kind (U2/U3/U4); NOT the conversion sheet's
now-false sentence (FINDING F-1 below — U3's, and it must land before the run's install); no
QUESTIONS.md entries written (the plan §6 logs PROVISIONALs at close — each below carries its
QUESTIONS-ready paragraph); the gathering assembly's star context (U4's — intake alone passes the
live star list today); zero `Sync/`, `Server/`, migrations, schema — none was needed, no STOP
condition met.

**UNIT STATUS: CLOSED 2026-10-01 — every evidence item of the plan §5 U1 row green (below).**

### What U1 built (the design as shipped — a fresh session's map)

- **`Domain/IntakeDecision.swift`** — the pure table (§2.1): `intakeRuns` (live · book · readable
  rule · unfinished — P-13ib-5) and `verdict(book:note:occasion:)` → `seat` / `arrival` /
  `nothing`, over `PairState` (`fresh` · `live` · `leftAsMember` · `dismissed`), the ownership
  facts, capacity, the dial (nil = AUTO), and the occasion (`event` / `backfill` / `catchUp`).
- **`Operations+Intake.swift`** — `insertPostTag` is THE ONE `post_tag` insert road (applyTag
  (toPost:), the gathering collect door, auto-tag, tagAllMembers); the tagging event (candidates =
  live, unfinished BOOKS with a readable rule IN THE NOTE'S WING whose rule references a tag
  at-or-above the applied one — wing-scoped; each probed with `matchesRule` + the live star list);
  the starring event (a NOTE newly starred; books whose rule carries a star term); `intakeSweep`
  (backfill/catch-up over the rule's current matches with NO pair row of any kind, creation
  order); materialization (END, unsectioned, insert-only); `applyAutoTag`; `tagAllMembers`;
  `setReadingIntakeSeating` / `setReadingAutoTag` (books only, wing-scoped tag, no-op-guarded);
  `seatArrival` / `dismissArrival`; `dismissPendingArrivals`.
- **Hooks in existing ops:** `createReading` (+ `intakeSeating:` / `autoTagId:`; a BOOK born with a
  rule backfills — the op the spawn/from-tag doors will call), `setReadingQuerySpec` (NULL→rule =
  backfill; any other CHANGED rule = catch-up; byte-identical = nothing), `lockReading` (dismisses
  live arrivals on the finish stamp), `unlockReading` (catch-up iff it was finished),
  `restoreReading` (catch-up AFTER the exact-stamp revival), `addPostToReading` (seats a waiting
  arrival; auto-tag), `newPostInReading` (auto-tag after the membership), `setStarred` (the star
  event), `collectPostIntoSmartReading` (now through the one road). `liveMembership` is
  MEMBER-ONLY; `livePairRow` is the any-status uniqueness question; `assignPostToSection` filters
  members. New refusals: `arrivalNotFound`, `readingHasNoAutoTag` (copy is the faces' — U2/U3).
- **The §9 hand-off (a):** `ruleSQL` + its single-post twin wing-scoped.
- **The bind needs no recast:** `convertSmartReadingToCurated` already IS the op-side bind
  (same row, assembly materialized, rule left on the row ⇒ a living book).

### PROVISIONALs made in U1 (each QUESTIONS-ready; the morning bundle carries them)

- **P-13ib-U1-1 — A DISMISSAL yields to a FRESH applying act, and only as an ARRIVAL.** *(A spot
  where the rulings pull two ways — recorded per the brief.)* The sitting record §4 and this
  plan's §2.1 say ANY pair row decides ("intake only ever inserts fresh pairs"); §24 (and this
  plan's §2.4, U2's walk script, and the brief) say "a dismissed arrival returns only on a FRESH
  tagging act." Under the strict reading the second sentence is false (a dismissed note could
  never return by intake). Built: on an EVENT, a pair whose only history is dismissal records
  (tombstoned `arrival` rows) rings again as a NEW arrival row — never auto-seated over her "no";
  a pair with a tombstoned MEMBER row (removed, diverged) stays decided against every occasion
  (§20's "keeps intake from re-adding"); backfill and catch-up honour ANY row (the un-finish
  covers the gap only). *QUESTIONS paragraph:* "When a note you dismissed from a book's Arrivals
  is tagged again (or starred again, for a star rule), should it (a) come back to Arrivals —
  BUILT; (b) never come back by itself (only by adding it by hand); or (c) come back, and so
  should a note you REMOVED from the book? Removing stays permanent in (a) and (b)."
- **P-13ib-U1-2 — A hand-add of a note WAITING at the door seats that arrival** (the same row →
  member, at the position asked, auto-tag riding) instead of refusing "already in this book"
  (false — an arrival is never a member). *Options:* (a) seat it — BUILT; (b) refuse with a new
  "it's waiting at the door — add it from Arrivals" refusal; (c) the old `alreadyInReading`.
- **P-13ib-U1-3 — Intake seats and the judgment "Add" never apply the AUTO-TAG.** Auto-tag covers
  notes that did NOT come through the rule (minted here — ruled; added by hand — P-13ib-1).
  *Options:* (a) BUILT; (b) the judgment "Add" tags like a hand-add while intake's own seats
  don't; (c) every seat tags (no loop either way — intake is insert-only and pairs are decided —
  but a book's outflow would then chain into other books' intake).
- **P-13ib-U1-4 — The join dial and capacity govern BACKFILL too.** "Birth = intent" seats only
  where the table would seat; a book born with "wait at Arrivals" sends its current matches to
  Arrivals (§4: "a living book whose order is guarded routes EVERYTHING through judgment"); a
  capped birth seats up to the cap and bells the rest. *Option (b):* backfill ignores the dial.
- **P-13ib-U1-5 — A malformed → readable rule edit is a CATCH-UP**, not a backfill (the book
  "had" a rule; while malformed its intake ran nothing, so the gap is judgment). Only a NULL →
  rule write (and a book born with a rule) is backfill. *Option (b):* any first-READABLE rule
  backfills.
- **P-13ib-U1-6 — Which acts a rule HEARS:** a tagging act is heard only by books whose rule
  references a tag at-or-above the applied tag (the plan §2.2's "rules referencing the applied
  tag's subtree", read through §19's subtree matching); a starring act only by rules with a star
  term. So `NOT #x` never hears `#y`, and an act never sweeps in an unrelated undecided match.
  *Option (b):* every living book probes every act (state-ish — an unrelated tagging would pull
  in old matches).
- **P-13ib-U1-7 — Judgment on a FINISHED book:** `seatArrival` refuses (`lockedReading` —
  finished freezes the assembly); `dismissArrival` is allowed (only a sync race can put a bell on
  a finished book, and dismissing is what finishing does). *Option (b):* both refuse.
- **P-13ib-U1-8 — `tagAllMembers` scope:** live MEMBER rows whose note is live (archived members
  included — they are counted on the shelf), never arrivals; allowed on a finished book (tags are
  not the assembly); `nil` tag = the book's auto-tag, refusing `readingHasNoAutoTag` when unset.
  The two Collecting setters are likewise allowed on a finished book (they are not the assembly).
- **P-13ib-U1-9 — Silent outflow no-ops:** no auto-tag, a DANGLING one (its tag deleted — the
  read-time fallback class), a tag of another wing (unreachable belt), a note already wearing it.

### FINDINGS (for the orchestrator; none is a STOP condition)

- **F-1 (U3 MUST CARRY IT — a shipped sentence U1 made false):** `SmartConversionOfferSheet`
  (`App/Variorum/Variorum/Features/Readings/BookOrderAndConversion.swift:184`) tells her "New tag
  matches will stop arriving here." — FALSE since U1 (the bound book keeps collecting, §14.6), and
  its default-ON "Keep a fresh smart book collecting this filter" toggle now DOUBLE-collects (the
  sibling gathering shows the match AND the bound book seats it). U3's bind door retires this
  sheet; if U3 does not land before the run's install refresh, this sentence ships false. Not
  fixed here (a face; one unit = one surface). It is the ONLY such copy (grep across `App/`).
- **F-2 (existing data, morning bundle):** every book converted from a smart book BEFORE 13i-b
  kept its rule as provenance (N38-A), so from U1 it is a LIVING book (ruled — §14.6 "it keeps
  collecting"). Intake is event-driven: nothing moves until her next fresh tagging/starring act
  matching it; if such a conversion also minted a "(collecting)" sibling, a fresh match will show
  in the sibling AND seat in the book. Her real store was not inspected (never touched).
- **F-3 (mobile parity / version skew):** intake fires only on LOCAL acts (apply mode runs no
  operations; zero `Sync/` lines, per §2.7). The phone shares VariorumCore, so it runs intake from
  its NEXT build; tagging acts made on today's marker-10 phone build are not heard by any living
  book (a later catch-up — un-finish, rule edit, restore — bells them). No convergence hazard
  (no conflicting rows), and both devices acting on one pair converge through R1.
- **F-4 (U3's bind undo story):** `revertSmartConversion` tombstones only the rows the bind
  minted; rows INTAKE seated after the bind stay live on the reverted gathering (the pre-existing
  "a row she added by hand after converting is hers" class, now reachable without her hand).
  Invisible in the gathering's assembly, but they count as membership to the Pool exclusion and
  `readingsContaining`'s membership leg (which can then list that gathering twice). U3 should
  decide the undo's reach when it rebuilds the door.
- **F-5 (13i-c's wing doors):** `newPostInReading` mints the note in Home (`insertPost` takes no
  wing) whatever the book's wing — pre-existing, unreachable (no op mints a non-Home wing);
  `applyAutoTag`'s wing belt makes it silent rather than cross-wing.
- **F-6 (recorded readings, no action):** restoring a NOTE (`restoreContainer`) revives its tags
  but is not an applying act — no intake fires; copy doors (diverge, duplicateAsVersion) carry no
  tags and fire nothing; archiving/unarchiving is not an act (an archived note is never seated —
  the ambient-view rule; it can be belled later by a catch-up).

### U1 LIVE STATUS (per commit; every unverified claim PENDING)

- Preflight read in this session, not delegated: CLAUDE.md + canon, this plan whole, the sitting
  record §3/§4/§14/§19/§20/§24 (+ §1–§25 read through), the 13i-a record §3/§4/§9, the resiliency
  protocol, SyncSpec whole (convergence-adjacent: R1's status-aware pair dedupe is the posture §2.7
  leans on). No revert in flight. No subagents.
- Piece 1 (2205c2bf): the record opened.
- Piece 2 (this commit) — **the §9 hand-off (a), FIXED with its pin.** `ruleSQL`'s tag term gains
  `applied.wing_id = root.wing_id`; so does its single-post twin `hasLiveTagApplication` in
  `Operations+SmartCollect.swift` (the collect door's probe — left unscoped, the two probes would
  disagree about one term: the door would report `alreadyMatched` for a note the gathering does
  not show). Pin `RuleWingScopingTests` (3): the cross-wing state inserted by direct rows (a
  second wing's same-path twin tag applied to a Home note). **Red-on-old watched:** 2 of 3 red on
  the pre-fix tree (the gathering showed the note / the Pool lost it; the collect door said
  `alreadyMatched`), the control green; all 3 green after. Neighbor suites (assembly, collect,
  tagsAll, wings migration, membership chip, quicknote — 54 tests / 7 suites) green.
  Deliberately untouched: `assembleReading`'s GROUPING-tag `sectionSelect` (a display walk, not
  the rule predicate; no door can mint the state) — recorded, not hardened.
- Piece 3 (this commit — **WIP, compiling; `ArrivalMemberHygieneTests` deliberately RED until
  piece 4**): `Domain/IntakeDecision.swift` (the pure table, owned arms included),
  `RuleGrammar.referencesStar`, `Queries.starredNoteIDs` (the star term's context, cap-bounded);
  and the member-reader hygiene PINS written first — 6 pins by a direct arrival row
  (remove / reorder / assign-to-chapter / diverge refuse `postNotInReading` and leave the arrival
  standing; a hand-add of a waiting note SEATS that same row; the capacity gate still governs it).
  **Red-on-old watched: 6/6 red on the pre-fix tree, each for its mechanism** (the diverge pin
  sharpened once: its first red was an accidental `postHasNoBlocks`; with a block seeded, the old
  tree visibly diverged the ARRIVAL — tombstoned it and seated a copy).
- Piece 4 (this commit): **the engine and every hook.** `Operations+Intake.swift` — the ONE
  application road `insertPostTag` (applyTag(toPost:), the gathering collect door, auto-tag,
  tagAllMembers all route through it), the tagging event (candidates = live unfinished BOOKS with a
  readable rule in the note's wing whose rule references a tag at-or-above the applied tag,
  wing-scoped), the starring event (`setStarred` on a NOTE, newly added only; rules carrying a
  star term), `intakeSweep` (backfill/catch-up over current undecided matches, creation order),
  materialization (END, unsectioned), the facts readers, `applyAutoTag`, `tagAllMembers`,
  `setReadingIntakeSeating`, `setReadingAutoTag`, `seatArrival`, `dismissArrival`,
  `dismissPendingArrivals`. Hooks wired: `createReading` (+ `intakeSeating`/`autoTagId` params;
  BOOK + rule ⇒ backfill), `setReadingQuerySpec` (rule-less→rule ⇒ backfill; any other changed
  rule ⇒ catch-up), `lockReading` (dismisses arrivals), `unlockReading` (catch-up iff it was
  finished), `restoreReading` (catch-up after the exact-stamp revival), `addPostToReading` (seats
  a waiting arrival; auto-tag), `newPostInReading` (auto-tag after the membership). New refusals:
  `arrivalNotFound`, `readingHasNoAutoTag`. `liveMembership` is MEMBER-ONLY; `livePairRow` (any
  status) serves the conversion's uniqueness skip and the hand-add's seat; `assignPostToSection`
  filters members. `ArrivalMemberHygieneTests` 6/6 GREEN now. Neighbor suites (hygiene, wing
  scoping, conversion, reading ops, restore, stars, tags, collect, sections, quicknote, journal —
  106 tests / 14 suites) green after ONE honest test edit: `SmartConversionTests
  .keepCollectingMintsASecondSmartBookOnTheSameFilter` asserted "the converted book froze" — the
  superseded N38 shape A; the sitting record §14.6 rules the bound book KEEPS COLLECTING, and the
  pin now asserts the newcomer seated at the end of it.
- Piece 5 (9325d2c1): the exact state-transition suites — `IntakeDecisionTests` (every arm of the
  pure table; owned arms headless) + `IntakeOperationsTests` (39 transitions) — **52 green on
  first run**.
- **MUTATION CHECK — DONE, tree restored (no revert in flight).** Five single-mechanism reverts
  against the committed tree, each restored by `git checkout --`: M1 dismissal never yields to a
  fresh act → 5 pins red; M2 the tagging event without the star context → 1 red; M3 finishing
  without the dismissal sweep → 2 red; M4 catch-up seats instead of belling → 6 red; M5 every act
  heard by every rule → 2 red. The first pass exposed a HARNESS weakness, fixed in this commit:
  an index after a failed count `#expect` crashed the test process and swallowed later reports —
  every such count is now a `try #require` (10 sites); the re-run reports all 52 with zero crash
  lines. Intake suites unmutated: 61 tests / 4 suites green.
- Piece 6 (this commit): the owned arms at the OPS level, headless by direct `owned = 1` writes (3
  transitions: an owned living book claims a free note and bells a membered one without touching
  the other membership; a plain living book bells an owned-elsewhere note and seats a plainly
  membered one; a dead owned book owns nothing) — `IntakeOperationsTests` now 42. **The soak**
  `IntakeSoakTests` — 6 seeds × 300 steps over 15 acts (tag/untag, star/unstar, mint, hand-add,
  remove, seat, dismiss, finish/un-finish, rule edits incl. none + malformed, tagAllMembers,
  delete/restore book, archive/unarchive), the invariants asserted after EVERY step (no duplicate
  live pair; assembly/shelf count/chip/Pool agree with the live MEMBER rows exactly; no eviction,
  no demotion, no physical row loss; a removed member returns only by hand-add or a restore's
  revival; a finished book holds no bell; a gathering holds no rows; capacity never exceeded;
  I2/I10) — GREEN, telemetry asserting intake seated AND belled on every seed.
- **SOAK MUTATION CHECK — DONE, tree restored (no revert in flight).** S1 (the capacity arm
  removed) → caught on seed 1 (the capped book's assembly disagreed with its member rows); S2 (the
  shelf count without its member filter) → 1,319 issues. Both restored by `git checkout --`;
  `git status` clean before the next piece.
- Piece 7 (this commit): **`GatheringRitualTests` (3) — the acceptance spine, GREEN.** R3 as one
  headless walk (tag two → the gathering shows both and holds no rows → untag one, it LEAVES →
  bind in place: same row id, name, star, rule on the row → a third tagged note JOINS (keeps
  collecting) → reorder → untag the other, it STAYS); lessons 3 and 4, each sentence a comment
  above the behaviour that makes it true. Lesson 4's "copy it in" clause is 13i-c's arm (no op
  exists; nothing here makes it false). **The bind needed NO recast:** `convertSmartReadingToCurated`
  already flips the same row, materializes the assembly and leaves the rule on the row — and a
  book with a rule is a living book under U1 — so no minimal op-side recast was built (U3 owns
  the door's face and the retirement of the `keepCollecting` "(collecting)" offer).
- **VERIFICATION (this commit):** the FULL core suite `swift build && swift test` — **"Test run with
  1840 tests in 193 suites passed"** (1 skipped: the standing Supabase integration test, env-gated;
  baseline 1772/187 at 13i-a's post-close → +6 suites, the six U1 files). The Mac app `xcodebuild
  -scheme Variorum -destination 'platform=macOS' build` — **BUILD SUCCEEDED**; the mobile target
  (`VariorumMobile`, generic iOS Simulator) — **BUILD SUCCEEDED**. Zero instances throughout
  (`pgrep` clean). Mac suites that exercise a changed op (every `VariorumTests` file calling
  add/remove/reorder/assign/diverge/lock/unlock/restore/rule-write/star/applyTag/mint/convert/
  collect), suite-level `-only-testing` by STRUCT name in three batches: **161/30 (4 known issues —
  the standing `IndexTierMetricsTests` overTwoBlankLines rows) · 140/33 · 79/11 — all passed, 0
  skipped.** Mobile suites likewise (the iPhone 17 Pro 26.2 simulator; the 16 Pro runtime is 18.3,
  below target): **101/22 passed, 2 known issues (the standing tutorial fanned-divide rows), 0
  skipped.**
- **CLOSE (this commit):** `createReading`'s new kind refusal names the minted id (the id is minted
  first — the same UUID order as before). Re-verified AT THE END, after the last code edit: the
  FULL core suite **"Test run with 1840 tests in 193 suites passed"** (1 skipped — the standing
  env-gated Supabase integration test); Mac app BUILD SUCCEEDED; mobile BUILD SUCCEEDED; zero
  instances. The record above carries the design map, P-13ib-U1-1…9 and F-1…F-6. Ledger row 2
  flipped. No revert in flight; nothing uncommitted. U1 CLOSED.

## U2 RECORD — the Arrivals face (opus-implementer, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** the orchestrator's own hands-on walk
(the plan §5 names it; this unit walked its rows itself — below — and the orchestrator walks after
the close); no QUESTIONS.md entries written (the plan logs PROVISIONALs at close — each below
carries its QUESTIONS-ready paragraph); no new home for a QUIET receipt on the book's Index/Book
surfaces (F-U2-2 — the 18i seam's placement, not invented here); the conversion sheet's wrong "0
notes" count and F-1's false sentence (both U3's door — F-U2-3); no Bookcase-row count, no
membership-chip state, no Collecting pane, no rule editor, no finish-confirm line (fenced: 13i-d /
P-13ib-2 / 13i-d / U3 / 13i-c); no phone face (the mobile catch-up's); zero Operations, `Sync/`,
schema, migrations — the one core change is the Queries read support; no STOP condition met.

**UNIT STATUS: CLOSED 2026-10-01 — every evidence item of the plan §5 U2 row green and walked (below).**

### What U2 built (the design as shipped — a fresh session's map)

- **`Queries/ArrivalQueries.swift` (the unit's ONLY core change):** `Queries.bookArrivals(db,
  readingID:, limit:)` → `BookArrivals { count, rows }`, ONE shared predicate
  (`bookArrivalSource`): a live `status='arrival'` row of a live BOOK whose note is a live,
  un-archived post, oldest arrival first; `limit: 0` = the count alone.
  `AppDatabase.observeBookArrivals(_:limit:)`, `limit` REQUIRED. `CROSS JOIN` keeps the book's rows
  the driver (plan-pinned).
- **`Features/BookView/BookArrivals.swift`:** `ArrivalsCopy` (every word, pure) ·
  `ArrivalsLineFace.isShown` (the ONE visibility value — §23's composition point: 13i-d's details
  toggle hides arrivals by composing HERE, nothing to fight) · `BookArrivalsModel` (its own model,
  P-9 — observes the door with `limit` = 0 collapsed / 30 open, `toggle`, `seat` / `dismiss` through
  the runner, a receipt on success and the operation's own refusal in words on failure, both on
  `session.status`; a per-row in-flight guard greys the row's doors) · `BookArrivalsLine` (draws
  NOTHING when empty — not a line, not a hairline; one muted `VoicedButtonStyle(.quiet)` line +
  hairline when occupied; rows inline on her click: the note's name (her prose, never
  `chromeLabel`'d) · "arrived …" (`TimeStampFace.relative`, the one stamp vocabulary) · **add**
  (`.primary`) · **dismiss** (`.quiet`); the "and N more waiting" tail past the window; every
  fixed text `lineLimit(1)`; tokens only) · the DEBUG `ArrivalsLineProbe` (owned per line instance).
- **Wiring:** `BookView` owns the model (`@State`, injectable) and hands it to `BookIndexView` (the
  line stands ABOVE the pane's scroll view — outside the manifest-measured content, so the landing
  authority is untouched) and `SpreadBookView` (atop both pages). Both params default nil.
  Outline and Read carry no line (the ruling names Index/Book).
- **Registry (P-1):** `CapabilityID.seatArrival` / `.dismissArrival` — `.surface`, book scope, no
  key, no palette row, `always`, `takesAccess: .native` (the `.archiveNote` precedent: the target is
  the row the door carries). `BookArrivalsLine.surfaceCapabilities` is their one renderer; the walk
  union names it.
- **§25 lesson 4 stays true:** "add it … or dismiss it" are the two doors; "copy it in" is 13i-c's
  owned arm (no op exists — nothing here makes it false); "Finishing a book dismisses whatever is
  still waiting" is U1's `lockReading`, untouched.

### PROVISIONALs made in U2 (each QUESTIONS-ready; the morning bundle carries them)

- **P-13ib-U2-1 — WHERE on the surface the line stands:** atop the CONTENT — Index's rendered pane
  (right of the index column), Book's spread (above both pages) — never in the masthead or the
  index column. *Options:* (a) atop the content — BUILT; (b) in the index column under the masthead
  (and the navigator on Book); (c) the shared masthead, i.e. every mode. *Ground:* "atop the book's
  Index/Book surface" names the surface's top; the column is the MEMBERSHIP listing, and arrivals
  are "never listed/worded as membership"; (c) would put it on Outline/Read too. *QUESTIONS
  paragraph:* "The 'N at the door' line sits at the top of the book's text in Index and above the
  two pages in Book. Should it instead sit in the index column under the book's title, or in the
  book's header so every mode shows it?"
- **P-13ib-U2-2 — An ARCHIVED waiting note leaves the door while archived** and returns on
  unarchive (its row stands untouched) — the book view's ambient-view rule (an archived member does
  not render in a book either; intake never seats an archived note). *Options:* (a) BUILT; (b) list
  it with an "archived" mark; (c) list it plain. *QUESTIONS paragraph:* "If a note waiting at a
  book's door gets archived, should the door (a) hide it until it's unarchived — built; (b) show
  it marked 'archived'; or (c) show it as usual?"
- **P-13ib-U2-3 — The expansion is VIEW state:** collapsed by default, collapsed on every open of
  the book, folds shut when the last arrival is judged; never remembered, never opens itself.
  *Options:* (a) BUILT; (b) remember open/closed per book (local); (c) open by itself when new
  arrivals ring. *Ground:* her clutter mandate — "never a persistent panel".
- **P-13ib-U2-4 — The open line lists the first 30 (oldest first) and says "and N more
  waiting"; there is NO bulk dismiss door** (dismissal at scale rides finishing — plan §2.5; a
  "dismiss all" would be a new act no ruling makes). *Options:* (a) BUILT; (b) add "dismiss all";
  (c) list every row (unbounded).
- **P-13ib-U2-5 — The words:** "N at the door" (the plan §3's) · "arrived today 7:31 AM" · add /
  dismiss · receipts "“T” added at the end of the book[, outside the chapters]." / "Dismissed
  “T”." · refusals naming the road ("“B” is full — its cap is N notes. Raise the note cap in the
  book's settings (the gear), then add it." · "“B” is finished — its table of contents is done…
  Reopen it in the book's settings…" · "That note isn't waiting at the door any more — it was
  already judged."). Dismiss's words deliberately say nothing about whether the note can ring again
  (that rides P-13ib-U1-1, still hers). 13s re-voices all of it.

### FINDINGS (for the orchestrator; none is a STOP condition)

- **F-U2-1 (morning bundle — discovery):** a book OPENS into Outline (R2 / 13c 2A), where the ruled
  line does not stand; until 13i-d's Bookcase-row accent count lands, she sees arrivals only on
  visiting Index or Book. Built to the ruling (Index/Book); whether Outline should carry the line
  too is hers.
- **F-U2-2 (the 18i seam's placement — orchestrator's call):** a QUIET receipt draws only in the
  note bars and the live note box's footer (`QuietReceiptLine`'s three hosts). On Index/Book with
  no note live, Add's and Dismiss's receipts reach the seam (pinned) but draw nowhere under her
  default `.quiet` (they show under `.toast`). Walked: the act's evidence is the board itself — the
  note appears at the end, the row leaves, the count drops. Not invented around: a fourth host is a
  seam decision.
- **F-U2-3 (U3 — the conversion door it rebuilds):** walked live, the shelf's "Convert to a
  Hand-Shaped Book…" sheet said "Its current **0** notes stay" for a gathering whose row read
  "smart · 8w" (two notes) — and the conversion then KEPT 2 (its receipt said so). Observed, not
  traced (`SmartConversionCount.collected` is a `try?`-swallowed `assembleReading` count, or the
  sheet captured stale state); the same sheet carries F-1's false sentence. U3 retires it.
- **F-U2-4 (pre-existing, not this surface):** on the shelf, the conversion's quiet receipt drew
  OVER the shelf's "⌘k — find anything" hint text (overlapping glyphs). Recorded, not touched.
- **F-U2-5 (P1, said exactly):** the door's statements are ∝ the BOOK's live pair rows (members +
  arrivals), never the corpus (plan-pinned); strictly ∝ the pending set would need a
  `(reading_id, status)` index — a schema change, forbidden here. The held observation re-fetches
  at autosave rate while a book view shows the line (the note join reads `container`, which an
  autosave rewrites whole) — bounded by the book's rows; `removeDuplicates` keeps the face still.

### THE WALK (this unit's own; dev-store Debug build `io.lduarte.Variorum.debug`, 2026-10-01 07:21–07:36 MDT)

Machine author-free (HID idle 6,500 s+, unlocked, caffeinate holding the display, AX + Screen
Recording granted, her app absent; `guard.sh` before every act). Captures (gitignored)
`notes/plans/13ib-screens/u2/`: **01** terminal-light Index, line collapsed ("▸ 2 at the door") ·
**02** expanded (door four / door five · arrived today 7:28 am · add · dismiss) · **03** the
capacity REFUSAL toast ("“the door” is full — its cap is 3 notes. Raise the note cap…") · **04**
after raising the cap to 5, Add: door four SEATED at the END, in "unfiled" after door three; "1 at
the door"; "4 notes" · **05** Book (spread): the same line atop both pages · **06** Dismiss door
five: the line VANISHES (no panel, no hairline), membership untouched · **07** door five un-tagged
and re-tagged by hand (the masthead tag door — a fresh act): "▸ 1 at the door" again · **08** its
NEW row ("arrived today 7:31 am", not the dismissed 7:28 one) — P-13ib-U1-1's built truth, and NOT
auto-seated though the cap had room · **09** study-light Index expanded (Add / Dismiss / AM) · **10**
study-light collapsed · **11** study-light Book spread · **12** study-light OUTLINE: no line · **13**
study-dark Index expanded · **14** terminal-dark Index expanded · **15** terminal-dark Book spread.
The script, by shipped faces only: two notes minted through the shelf's quick-entry bar with
`{#door13ib}` (the capture microsyntax — fresh tag; the store's `u2walk`/`u3walk` tags were earlier
sessions' and not fresh) · Settings ▸ Tags ▸ Promote to Book → the gathering "the door" (smart ·
8w) · the shelf row's "Convert to a Hand-Shaped Book…" (the "(collecting)" sibling unticked — F-1's
double-collect) → "the door · 2 notes" · gear ▸ Note cap 3 · "+ new chapter" "part one", both members
filed in it · three more `{#door13ib}` captures: the third SEATED (end, unfiled), the fourth and
fifth WAITED (at capacity) — note five's chip read "in no book" (P-13ib-2 silent). Her dev settings
restored and read back (voice Terminal, Appearance Follow system — AX values `1,0` / `1,0,0`;
`appearanceChoice = system`); the instance quit by identity; zero instances after. The dev store
keeps the walk's book "the door", its tag and seven notes (dev store — harmless).

### U2 LIVE STATUS (per commit; every unverified claim PENDING)

- Preflight read in this session, not delegated: CLAUDE.md + canon, this plan whole (§1–§7, the U1
  RECORD, the ledger, the morning bundle), the sitting record §1–§6 and §18–§25 (§4, §23, §24 and
  §25 lesson 4 closely), the resiliency protocol whole. No editor-seam, `Sync/`, custody or schema
  work in this unit (SyncSpec / TEXTKIT2_NOTES not required). Code orientation: the U1 judgment ops
  (`Operations+Intake.swift` — `seatArrival` / `dismissArrival`), the book view (`BookView` /
  `BookIndexView` / `SpreadBookView` / `BookStructureModel`), the registry (`Capability` /
  `CapabilityRegistry` / the `.surface` walk), the status seam (`StatusCenter` — refuse / receipt),
  `TimeStampFace`, `VoiceControls`. No revert in flight. No subagents.
- Piece 1 (abe73479): the record opened.
- Piece 2 (this commit) — **the Queries read support, the unit's ONLY core change**
  (`Sources/VariorumCore/Queries/ArrivalQueries.swift`): `Queries.bookArrivals(db, readingID:,
  limit:)` → `BookArrivals { count, rows }` by ONE shared predicate (`bookArrivalSource` — a live
  `status='arrival'` row of a live BOOK whose note is a live, un-archived post; oldest arrival
  first), `limit: 0` = the count alone (the collapsed line); `AppDatabase.observeBookArrivals(_:
  limit:)` with `limit` REQUIRED (the `observeLibrary` discipline). P1: `CROSS JOIN` makes the
  book's own rows drive (a book-scoped index SEARCH) and each note a PK seek — ∝ the book's live
  pair rows, never the corpus (strictly-∝-pending would need a `(reading_id, status)` index = a
  schema change, forbidden here; recorded). `ArrivalQueriesTests` (12): empty/members-only door ·
  count + arrival order + row ids are the arrival rows · limit bounds rows never the count ·
  judged arrivals leave (seat → member, dismiss → gone) · other books never count · archived
  leaves and returns (P-13ib-U2-2) · deleted note / deleted book empty it · a gathering never has
  a door even with a stray row · nameless → its day · a rung-again note stands on its NEW row
  (P-13ib-U1-1) · BOTH statements' `EXPLAIN QUERY PLAN` (`SEARCH rp` first, the container a PK
  seek, no SCAN) · the observation delivers live — **12/12 green on first run** (new feature
  pins, not bug-class: no red-on-old applies).
- Piece 3 (this commit — **WIP, compiling: the face built and wired; Mac BUILD SUCCEEDED; pins
  NOT yet written, the walk-suite union edited but NOT yet run — PENDING**):
  `Features/BookView/BookArrivals.swift` — `ArrivalsCopy` (every word: the line "N at the door",
  helps, the "arrived …" stamp through `TimeStampFace.relative`, the "and N more waiting" tail, the
  two receipts, the refusals naming their roads), `ArrivalsLineFace.isShown` (the ONE visibility
  value — §23's composition point for 13i-d's details toggle), `BookArrivalsModel` (its own model,
  P-9: the observed door, `toggle`, `seat` / `dismiss` through the runner, receipts and refusals on
  `session.status`), `BookArrivalsLine` (draws NOTHING when empty; one quiet line + hairline when
  occupied; rows inline on her click; declares `.seatArrival` / `.dismissArrival` as its
  `surfaceCapabilities`), and the DEBUG `ArrivalsLineProbe` (the `TrayRowDoorProbe` pattern).
  Registry: `CapabilityID.seatArrival` / `.dismissArrival`, `.surface`, book scope, `always`,
  `takesAccess: .native` (the `.archiveNote` precedent). Wiring: `BookView` owns the model and
  passes it to `BookIndexView` (the line ABOVE the pane's scroll view — never inside the
  manifest-measured content) and `SpreadBookView` (atop both pages); both params default nil.
  `CapabilityRegistryTests`' surface union gains `BookArrivalsLine` (a justified edit, commented).
  (Superseded by piece 4: the pins are written and green.)
- Piece 4 (this commit): **the mounted pins** — `VariorumTests/BookArrivalsTests.swift` (10): the
  words pure (line, the "arrived …" stamp = `TimeStampFace.relative`, receipts, refusals naming
  their roads, never the enum; `isShown`/`hidden`) · the line ABSENT with nothing waiting (Index
  AND Book — nothing draws, not even a hairline) · PRESENT as "3 at the door", collapsed, on Index
  and on Book, and GONE on Outline and Read (the ruled surfaces only) · expands inline to one row
  per arrival ROW with exactly [Add, Dismiss] (no copy-in arm), folds back · Add seats the SAME
  row → member, at the END, unsectioned, the assembly ends with it after the chapter's members,
  the door answers one fewer, a RECEIPT on the seam naming where · Dismiss tombstones (status
  stays arrival, membership untouched), the emptied door folds shut, a receipt · the CAPACITY
  refusal (a full book under the quiet dial — intake waited at the door) spoken as a REFUSAL toast
  in the op's own terms, the bell still ringing · a row already judged refuses honestly
  ("already judged"), touching nothing · the last judgment makes the line vanish and the book's
  projection carries the seated note · the registry: the line is the two acts' one renderer,
  `.surface` only, book scope, no key, verbs = the drawn verbs. The probe is OWNED per line
  instance (SwiftUI mounts the arriving surface before unmounting the departing one — a bare
  forget would erase the new record). **Mac: `BookArrivalsTests` + `CapabilityRegistryTests` —
  "Test run with 38 tests in 2 suites passed", 0 skipped** (one pin edited before green: its
  "no parenthesis" check was too blunt for the capacity sentence's own "(the gear)" — it now
  checks for enum residue). (The count is 10 tests, not 9 — corrected in piece 5.)
- Piece 5 (this commit): **MUTATION CHECKS — DONE, tree restored (no revert in flight;** each run
  against the committed tree, restored by `git checkout --`, `git status` clean after each). M1
  `ArrivalsLineFace.isShown` → always true: **4 red** (the absent pin on BOTH Index and Book, the
  pure `isShown(.none)` check, the vanish pin, and the seat pin's door). M2 the Book (spread)
  wiring dropped: **1 red** (`theLineSaysHowManyWaitAtopIndexAndBook`'s Book leg) — and it showed
  `whenTheLastArrivalIsJudgedTheLineVanishes` (mounted on Book) passing silently without the line
  ever drawing, so that pin now asserts the line WAS there, open on its row, before the judgment.
  **Mac suites, suite-level `-only-testing` by struct name, counts read exactly:** the book
  surfaces A1 — **104 tests / 18 suites passed, 0 skipped** (BookArrivals, BookView, Spread,
  OutlineWritingSurface, BookFocusFold, BookRedesignMount, BookIndexEditing,
  BookIndexColumnHeights, BookCardHeightStability, BookLeavingSavepoint/Registry,
  BookOrderConversion, BookStructureModel, BookDrop, JournalBooks, DebugOracleTwoWindow,
  AscentDoor/Routing); A2 — **83 / 19 passed, 4 known issues (the standing `IndexTierMetricsTests`
  overTwoBlankLines rows), 0 skipped** (BookIndexLanding, BookOutlineCost/Landing/Rows,
  IndexClickCaret, IndexLandingCaret, IndexTierMetrics, PaneLineMetricsScope,
  InlineEditorWidthReflow, NoteBoxComposition/Geometry, OutlineLandingTeardown, OutlineRoom,
  PaneSurface, PanePublishDoor, PagedReadView, NavigatorReadRows, PaneBookBlur, PaneMount); B —
  the registry, the seam and **the tutorial spine** — **148 / 20 passed, 0 skipped**
  (CapabilityRegistry, StatusCenter, CommandRouter, ChordLegibility, the four declaration suites,
  and ALL eleven `TutorialWalkTests` suites). Zero instances throughout. 
- Piece 6 (this commit): **the walk — DONE** (THE WALK above: 15 captures, both voices × both
  appearances, every U2 evidence row walked live on the dev store); the record's body written
  (the design map, P-13ib-U2-1…5, F-U2-1…5).
- **CLOSE (this commit) — the final verification, after the last code edit:** the FULL core suite
  `swift build && swift test` — **"Test run with 1852 tests in 194 suites passed"** (1 skipped: the
  standing env-gated Supabase integration test; baseline 1840/193 at U1's close → +12 tests / +1
  suite, `ArrivalQueriesTests`); the Mac app `xcodebuild -scheme Variorum -destination
  'platform=macOS' build` — **BUILD SUCCEEDED**; the mobile target (`VariorumMobile`, generic iOS
  Simulator) — **BUILD SUCCEEDED**. The Mac suites (piece 5) ran after the last app/test edit and
  stand: 104/18 · 83/19 (4 standing known issues) · 148/20 incl. the tutorial spine, 0 skipped.
  Zero instances. No revert in flight; nothing uncommitted. Ledger row 3 flipped. U2 CLOSED.

## ORCHESTRATOR VERIFICATION — U2 (2026-10-01, before U3's spawn)

- Trail verified (8 commits, checkpoint discipline held, pushed, tree clean). The new suites
  re-run by the orchestrator's hand: `ArrivalQueriesTests` 12/12 · `BookArrivalsTests` 10/10
  GREEN. Captures reviewed (02: the expanded line on Index, the ruled quiet shape; 13: the
  Study dark room legible, nothing clipped — and it EVIDENCES P-13ib-U1-1's walk claim: door
  five back at the door at 7:31 after its 7:28 dismissal). The orchestrator's full hands-on
  drive rides the END-OF-PHASE acceptance walk (before the sanctioned install refresh);
  this verification is suites + captures + trail, stated honestly.
- **Dispositions:** F-U2-1 (books open into Outline, which carries no line) → the MORNING
  BUNDLE (her call; interim acceptable — Index/Book carry it, 13i-d's Bookcase count closes
  the gap). F-U2-2 (quiet receipts have no home on Index/Book while no note is live) →
  recorded; a KnownIssues row at closeout, owner 13i-d (the faces phase; the receipts reach
  the seam, pinned). F-U2-3 (the conversion sheet's wrong "current N notes stay" count) →
  U3's charter beside F-1 (the sheet is U3's to rebuild). F-U2-4 (the shelf's quiet receipt
  draws over its "⌘k" hint — pre-existing) → a KnownIssues row at closeout, owner 13i-d's
  polish sweep. F-U2-5 (P1 stated ∝ the book's live pair rows) → accepted as the honest
  letter; no row (the bound is the book, the `assembleReading` class).
- Noticed in capture 13, cosmetic + pre-existing: the book footer says "1 chapters" —
  13i-d's vocabulary/polish sweep's, recorded here so it is owned.

## U3 RECORD — the rule editor + the two strengthening doors + the teaching moment (opus-implementer, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** the gathering assembly's STAR context
(U4's — so a GATHERING rule's ★ arm shows nothing yet, and a bind of such a gathering materializes
none of its star matches: F-U3-3); the op's dead `keepCollecting`/`collectingName` parameters
(fenced — no Operations change beyond P-13ib-6: F-U3-4); the Collecting pane's sentence face and
any book-view/gear door for the editor (13i-d re-homes it); every ownership arm (13i-c — nothing
built or hinted); no mounted pin for F-U3-1 (its evidence is the walk's before/after pair — the edge
is SwiftUI's sheet `onDismiss`); no QUESTIONS.md entries written (the plan logs PROVISIONALs at
close — each below carries its QUESTIONS-ready paragraph); no phone face; the WalkKit hardening the
walk proved necessary (F-U3-5 — tooling, not this surface); zero `Sync/`, schema, migrations — no
STOP condition met.

**UNIT STATUS: CLOSED 2026-10-01 — every evidence item of the plan §5 U3 row green and walked (below).**

### What U3 built (the design as shipped — a fresh session's map)

- **`Domain/RuleEditing.swift`** — the editor's brain: path-addressed edits over `RuleTerm` ITSELF
  (add · addGroup born seeded · remove with upward pruning of groups THIS removal empties ·
  toggleNegation one layer — `.not` is a wrapper node · setCombinator), the row projection the face
  draws, `carriesLegacy`, `needsWrite` (structural equality; a malformed rule is never overwritten).
  A group holding a grandfathered term carries no remove door (`isRemovable`). Every stored shape is
  an editor state — "saving never silently drops a term" holds by construction (pinned as a
  property over a corpus). `Queries.membersMissingTag` — the offer's N, `tagAllMembers`' own
  predicate.
- **`Features/Readings/RuleEditor.swift`** — `RuleEditorCopy` · `RuleEditorModel` (`Identifiable`:
  the sheet's ITEM is the model; `load()` idempotent; `save()` writes only what changed — dial,
  auto-tag, then the rule through `setReadingQuerySpec` — and OFFERS `tagAllMembers` on the seam) ·
  `RuleEditorSheet` · the DEBUG `RuleEditorProbe`. Door: the shelf row's "Edit Rule…" for gatherings
  AND books (`.editRule`); the shelf refreshes its aggregates when the editor closes (F-U3-1).
  RETIRED: `SmartSpecSheet`, `ReadingsViewModel.setSmartSpec`, `Queries.legacyDraft` (no consumer
  remains; `Queries.SmartQuerySpec` stays — Promote to Book and the phone's create-book still hand
  the choke point a v1 draft).
- **`BookOrderAndConversion.swift`'s bind half** — `BindOffer` (the sheet's item, CARRYING the count
  — F-U2-3's fix shape), `BindCopy`, `BindIntoBookSheet`, the DEBUG `BindDoorProbe`. Doors: the
  shelf's "Bind into a Book…" (`.bindIntoBook`; hidden on a finished gathering) and "Make a Book from
  This Gathering…" (`.makeBookFromGathering` → a name prompt → `ShelfViewModel.spawnBook`, one runner
  closure: the live rule read inside it, E13's guard, `createReading(kind: .book, querySpec:,
  wingId:)`); the book navigator's "+ new chapter" on a gathering → `structure.openBindOffer(
  followUp: .createChapter, order:)`. `ShelfViewModel.bind` / `BookStructureModel.bind(order:)`.
- **The teaching moment** — `BookStructureModel.acceptDrop` (the one brain behind the navigator's and
  Outline's post drags) answers a POST drag on a GATHERING with `offerToBind`: an OFFER ("Turn into a
  book to arrange by hand?" — the sitting record §3 verbatim) whose act opens the bind confirm; a
  finished gathering hears the refusal. Index/Book/Read carry no post drag (nothing to hang there).
- **P-13ib-6** — `revertSmartConversion` tombstones every live pair row on the reverted row and
  hands the ids (a `LockIsolated` box) to `reapplySmartConversion`.

### PROVISIONALs made in U3 (each QUESTIONS-ready; the morning bundle carries them)

- **P-13ib-U3-1 — Grandfathered terms are read-only all the way down.** A legacy (date/profile) term
  has no door, and a GROUP that holds one has no remove door either (removing the group would take
  the old term with it); there is no "clear the whole rule" door, so a rule carrying an old term
  can't be emptied from this face. *Options:* (a) BUILT; (b) a legacy row gets a remove door (a
  deliberate act, not a silent drop); (c) a whole-rule "clear" door. *QUESTIONS paragraph:* "An old
  gathering's rule can carry a date or profile term the editor shows but can't edit. Should you be
  able to (a) never remove it here — built; (b) remove it with its own ✕; or (c) clear the whole
  rule in one go?"
- **P-13ib-U3-2 — The spawn asks for a name, prefilled "<gathering> (book)".** (Book names are unique
  by her E13 ruling, so the sibling can't share the gathering's name.) *Options:* (a) a prompt,
  prefilled — BUILT; (b) mint "<gathering> (book)" silently, rename later; (c) prefill something
  else. *QUESTIONS paragraph:* "Making a book from a gathering asks for the new book's name,
  suggesting '<gathering> (book)'. Keep the prompt, skip it with that default, or suggest another
  name?"
- **P-13ib-U3-3 — P-13ib-6's reach, read through its own law.** The ruling names "every live member
  row"; built for EVERY live pair row, waiting ARRIVALS included ("a gathering holds nothing" — a
  gathering has no door). The redo revives exactly the rows the undo took (the ids exist only at
  undo time), so a member she removed by hand BEFORE the undo stays removed after the redo (the old
  redo revived every do-time row). *Options:* (a) BUILT; (b) members only — an arrival stays live
  on the reverted gathering (invisible; it would block that pair's next bind); (c) the redo also
  revives do-time rows removed before the undo. *QUESTIONS paragraph:* "Undoing a bind empties the
  gathering again — members and anything waiting at its door alike — and redo brings back exactly
  what the undo took. OK as built, or should a waiting arrival survive the undo?"
- **P-13ib-U3-4 — The teaching offer's act opens the bind CONFIRM** (the count + the keeps-collecting
  truth), never a one-click bind; on a FINISHED gathering the drag hears a refusal instead (an
  offer that can only fail is not offered). *Options:* (a) BUILT; (b) the offer's button binds
  directly; (c) no answer at all on a finished gathering. *QUESTIONS paragraph:* "Dragging a note
  inside a gathering asks 'Turn into a book to arrange by hand?' and its button opens the usual
  Bind confirmation. Should the button bind straight away instead?"
- **P-13ib-U3-5 — When the save offers "also tag the N current members now":** on a BOOK, when the
  save set or changed the rule OR the auto-tag, an auto-tag is in place, and N > 0 — N counts the
  members not yet wearing the tag (exactly what `tagAllMembers` will tag). No offer when N = 0 or
  nothing relevant changed. *Options:* (a) BUILT; (b) only when the auto-tag itself changed; (c) a
  standing "tag the N members" button on the row instead of an offer. *QUESTIONS paragraph:* "Saving
  a book's rule or auto-tag offers to tag the members who don't wear the tag yet. Ask only when the
  auto-tag changes, keep asking on rule edits too (built), or show a standing button instead?"
- **P-13ib-U3-6 — An empty rule clears the rule.** Removing a rule's last term (or a group's last
  term up to the root) stores NO RULE — on a gathering that is the standing "shows every note"
  (the editor's empty state says so), on a book "collects nothing by itself". The editor never
  mints an empty group ("+ group" is born with its first term). *Options:* (a) BUILT; (b) refuse to
  save an empty rule on a gathering. *QUESTIONS paragraph:* "Taking the last term out of a
  gathering's rule leaves it with no rule, which shows every note (as a new gathering does). Fine,
  or should the editor refuse to save a gathering with no rule?"
- **P-13ib-U3-7 — The words** (13s re-voices): "Edit Rule…" (one verb, both kinds) · "Bind into a
  Book…" · "Make a Book from This Gathering…" · the bind body's truth sentence "It stays the same
  book on your shelf — same name, same star — and it keeps collecting after you bind it: new notes
  that match its rule join at the end." · the bind refusal "That's already a book — only a
  gathering binds into one." · the receipts "“X” is a book now — N notes bound in, in the order you
  had them. It keeps collecting." / "Made “X” — N notes joined, and it keeps collecting." · the
  offer "Also tag the N current members with #tag now? — Tag Them".

### FINDINGS (for the orchestrator; none is a STOP condition)

- **F-U3-1 (FIXED, walk-found):** the shelf's tags column and word counts are one-shot aggregates;
  a saved rule left the row reading "smart", no tag, until the shelf was re-entered (the retired
  sheet had the same gap). `onDismiss` refresh on the editor's sheet; evidence = the walk's
  before/after pair (17a pre-fix build, 17b fixed build).
- **F-U3-2 (recorded — a face, not this unit's):** the note masthead's membership chip loads
  one-shot (on open / on popover show), so a note seated by INTAKE while it is open still reads "in
  no book" until re-opened. Pre-existing behaviour, newly reachable through U1's intake (a tagging
  act from the masthead seats the open note). Owner suggestion: 13i-d (the faces/chip) or a
  standing-fixes entry.
- **F-U3-3 (U4 MUST CARRY IT):** `assembleReading`'s gathering arm passes no star context, so a
  GATHERING rule's ★ term matches nothing today — the editor offers ★ on gatherings (ruled grammar),
  and the BIND materializes through the same assembly (as does its count), so binding a `tag ∧ ★`
  gathering would mint zero star matches. Books' intake already passes the live star list (U1), so
  the walk's `tag ∧ ★` seat on a BOOK is real. U4's "wire every assembly/pool/chip call site that can
  meet a star term" must include `assembleReading` (→ the bind's materialization and
  `SmartConversionCount`).
- **F-U3-4 (fenced, recorded):** `convertSmartReadingToCurated(keepCollecting:collectingName:)`
  still accepts the dead "(collecting)" parameters (no door passes them since U3; core pins still
  exercise them). Retire at the next op touch (owner: the orchestrator's call — 13i-c touches the
  bind's owned-notes confirm).
- **F-U3-5 (walk tooling):** after Settings closes, activating the dev app did not raise its main
  window above another app's window, and `guard.sh` checks frontmost + point-in-window but not
  OCCLUSION — two right-clicks landed in the orchestrator's terminal frame (harmless: keystrokes
  are re-guarded). The mid-walk hardening (AXRaise + a topmost-window-at-point check via
  `CGWindowListCopyWindowInfo`) belongs in `Tools/WalkKit`.
- **F-U3-6 (pre-existing, already owned):** the shelf's report line persists and draws over the ⌘k
  hint — F-U2-4's class (13i-d polish). The finished-gathering drag refusal reuses "This book is
  locked — unlock it first." (the shared `lockedReading` words; 13i-d's vocabulary sweep).
- **Tutorial (P-6):** no lesson sentence went false. The seeded lessons name no convert/filter door
  and never say a bound book stops collecting; "promoted into a smart book that collects everything
  wearing it" stays true (13i-d's vocabulary sweep owns "smart"). No lesson prose rewritten — no
  re-seed consequence.

### U3 LIVE STATUS (per commit; every unverified claim PENDING)

- Preflight read in this session, not delegated: CLAUDE.md + canon, this plan whole (§1–§7, the U1
  RECORD, the U2 RECORD + the orchestrator's U2 verification, the ledger, the morning bundle), the
  sitting record whole (§1, §3, §4, §14.6, §17(d), §19, §20, §25 lesson 3 closely), the resiliency
  protocol whole. No `Sync/`, custody, schema or editor-seam work in this unit (SyncSpec /
  TEXTKIT2_NOTES not required). Code orientation: `SmartSpecSheet` + `Queries.legacyDraft` (its
  consumers: the sheet and ONE Mac test, `TimelineAndReadingsTests.aUIBuiltSmartSpecRoundTripsUnchanged`),
  `SmartConversionOfferSheet` + its two hosts (the shelf's menu door, BookView's "+ new chapter"),
  `convertSmartReadingToCurated` / `revertSmartConversion` / `reapplySmartConversion`, the U1
  Collecting setters + `tagAllMembers`, `RuleGrammar`, the registry + its walk, `StatusCenter`'s
  offer kind, `BookStructureModel.acceptDrop` (the ONE brain behind every post drag — navigator rows
  and Outline body rows). No revert in flight. No subagents.
- **The settled design (written before code):**
  - **A — the rule editor.** A pure Domain brain `RuleEditing` (path-addressed edits over
    `RuleTerm`: add a tag/star term, add a seeded group, remove, toggle negation, flip a group's
    and/or) whose state IS a `RuleTerm?` — a bijection with the stored grammar, so there is no
    "shape it cannot express": the undraftable hazard is gone by construction, not relocated.
    `.not` is a wrapper node (never a flag), so even `not(not x)` round-trips. Legacy terms render
    read-only and are never offered; a MALFORMED stored rule refuses editing entirely. An unedited
    Save writes NOTHING (structural equality — so non-canonical stored bytes can never fake a
    catch-up occasion on a book). The editor never mints an empty group (a group is born seeded;
    removing a group's last term removes the group; removing the root's last term clears the
    rule). Face: `RuleEditorSheet` + `RuleEditorModel` (`Features/Readings/RuleEditor.swift`), one
    shelf-menu door "Edit Rule…" for gatherings AND books; books add the join dial and the auto-tag
    row; Save that sets/changes the rule or the auto-tag with an auto-tag in place OFFERS "also tag
    the N current members" on the status seam (`tagAllMembers`). `SmartSpecSheet`,
    `ReadingsViewModel.setSmartSpec` and `Queries.legacyDraft` retire.
  - **B — Bind into a book.** `BindIntoBookSheet` replaces `SmartConversionOfferSheet`; the sheet
    item `BindOffer` CARRIES the derived count (F-U2-3's fix shape — the count is never a separate
    `@State` read inside a sheet closure); the "(collecting)" offer dies; the copy tells §14.6's
    truth (it keeps collecting). P-13ib-6: `revertSmartConversion` tombstones EVERY live pair row
    on the reverted row (a gathering holds nothing) on one stamp and records the ids; the redo
    revives exactly those ids (exact-row, AppSpec §9).
  - **C — Make a book from this gathering** (spawn): a shelf-menu door; a name prompt; composition
    in `ShelfViewModel` over `createReading(kind: .book, querySpec: <the gathering's rule>, wingId:)`
    — creation-time backfill seats; auto-tag OFF (P-13ib-3); the gathering survives.
  - **D — the teaching moment:** `BookStructureModel.acceptDrop` on a GATHERING answers a post drag
    with an OFFER ("Turn into a book to arrange by hand?") whose act opens the bind confirm.
  - **E — registry:** `.editRule`, `.bindIntoBook`, `.makeBookFromGathering` (shelf context menu).
- Piece 1 (4761d789): the record opened.
- Piece 2 (this commit) — **P-13ib-6, FIXED with its pins.** `revertSmartConversion` now
  tombstones EVERY live pair row on the reverted row (members and arrivals; one stamp) and returns
  their ids; the registration hands them to the redo through a `LockIsolated` box (the ids exist
  only at undo time), so `reapplySmartConversion` revives exactly what the undo took — status
  untouched (a waiting arrival returns waiting). Pins (core `SmartConversionTests`):
  `undoingABindLeavesNoLiveRowAndRedoBringsEveryRowBackByID` (an intake seat + a hand-add after the
  bind) and `undoingABindTakesAWaitingArrivalAndRedoReturnsItWaiting`. **Red-on-old watched: both
  red on the pre-fix tree, each exactly at "a gathering holds nothing"** (the old inverse left the
  intake row, the hand row and the arrival live); green after. ONE honest test edit:
  `undoTombstonesOnlyWhatTheConversionMintedNotWhatSheAddedByHand` asserted the superseded shape
  ("her row is hers") — rewritten as `undoTakesHerHandAddedRowTooAndAFreshBindStillWorks` (the
  ruled truth; the redo is her road back). Plus the §19.6 identity pin
  `bindingPreservesTheRowsIdentityNameStarShelfSpotAndWing` (shelf row staged by direct insert —
  no shelf door before 13i-d). Neighbour suites (conversion, ritual, intake ops + soak, arrival
  hygiene, reading ops): 84 tests / 6 suites green; conversion 24/24.
- Piece 3 (this commit) — **the editor's pure brain + the offer's count (core).**
  `Domain/RuleEditing.swift`: path-addressed edits over `RuleTerm` (add · addGroup-seeded · remove
  with upward pruning of groups THIS removal empties · toggleNegation one layer · setCombinator),
  the face's row projection (depth, negation count, add doors — a lone root gets the wrapping
  door), `carriesLegacy`, `needsWrite` (structural equality; malformed never overwritten). One
  refinement found while pinning: a group whose subtree holds a legacy term carries NO remove
  door (`isRemovable`) — read-only must not leak through a parent. `Queries/CollectingQueries.swift`:
  `membersMissingTag` — the SAME predicate `tagAllMembers` tags by. `RuleEditingTests` (13): the
  corpus round-trip + unedited-save-writes-nothing (incl. a non-canonical spelling), the
  every-edit-touches-only-its-node property over 15 shapes, legacy never removable through any
  parent, each edit exactly, the rows, the offer's count == `tagAllMembers`' return — **13/13 green
  on first run** (new surface: structural red-on-old).
- Piece 4 (this commit — **WIP, compiling: Mac TEST BUILD SUCCEEDED; the editor's mounted pins NOT
  yet written; the bind sheet still the old one — PENDING**): `Features/Readings/RuleEditor.swift`
  — `RuleEditorCopy` (every word), `RuleEditorModel` (`Identifiable` — the sheet's ITEM is the
  model, so no shelf re-render can rebuild her draft; edits are `RuleEditing`'s; `save` writes only
  what changed — dial, auto-tag, then the rule through `setReadingQuerySpec` — and OFFERS
  `tagAllMembers` on the seam when the rule or the auto-tag was set/changed with an auto-tag in
  place and `membersMissingTag` > 0), `RuleEditorSheet` (rows with depth/not/remove, the add doors
  — "+ tag ▾" over the wing's live tags, "+ starred", "+ group ▾" born seeded — the legacy notice,
  the malformed refusal, and for books the join dial chips + the auto-tag menu), the DEBUG
  `RuleEditorProbe`. The shelf row's menu: "Edit Rule…" for gatherings AND books (replacing "Edit
  Filter…"). Registry: `CapabilityID.editRule` (`.contextMenu`, book scope, `always`, `.native`);
  `ShelfView.contextMenuCapabilities` gains it. **RETIRED:** `SmartSpecSheet`,
  `ReadingsViewModel.setSmartSpec`, `Queries.legacyDraft` — verified no consumer remains (its only
  other consumer was the Mac test below). ONE honest test rewrite:
  `TimelineAndReadingsTests.aUIBuiltSmartSpecRoundTripsUnchanged` (pinned the retired face's lossy
  round trip) → `aUIBuiltRuleRoundTripsUnchanged` (the editor's exact round trip, the assembly
  applying it, clearing → match-all). `Queries.SmartQuerySpec` STAYS: two other doors (the tag
  manager's Promote to Book, the phone's create-book) still hand the choke point a v1 draft.
- Piece 5a (this commit — **WIP: `BindDoorTests` deliberately RED until piece 5b; no revert in
  flight**) — **F-U2-3 TRACED and PINNED before the fix.** The count itself was never wrong
  (`SmartConversionCount.collected` is pinned 3-of-3); the door's PLUMBING was: the shelf set a
  separate `@State convertCount`, then the sheet's item, and the sheet read the count inside its
  content closure — nothing in the shelf's body read `convertCount`, so no re-render captured the
  new value and the closure ran on a view value whose `@State` snapshot still held 0. Pin
  `BindDoorTests.theShelfsBindSheetPromisesTheCountTheGatheringShows` mounts the REAL `ShelfView`,
  drives its door function (the menu item's own body, factored into `openConvertOffer` — reached
  through a DEBUG hook, `BindDoorProbe.openShelfDoor`, since the shelf's `@State` is unreachable
  from outside) and reads what the presented sheet recorded on appear (`BindDoorProbe.shown`).
  **RED on the old plumbing: "shown.count → 0 == 2"** — F-U2-3 reproduced in process. **Mechanism
  confirmed by experiment:** a scratch `let _ = convertCount` in the shelf's body (a dependency →
  a fresh snapshot) turned the same pin GREEN; the scratch line was then removed (verified, `grep
  SCRATCH` = 0). The instrumentation added to the old tree changes no behaviour (the menu closure's
  body moved verbatim into one function; the probe is DEBUG-only).
- Piece 5b (this commit) — **the two doors rebuilt; F-U2-3 + F-1 FIXED; the teaching moment.**
  `BookOrderAndConversion.swift`'s conversion half → BIND: `BindOffer` (the sheet's ITEM, carrying
  its count + follow-up + the A31 order — one write presents it), `BindCopy` (every word: the
  truth sentence "it keeps collecting after you bind it: new notes that match its rule join at the
  end" replaces F-1's false "New tag matches will stop arriving here."; the spawn's words; the
  teaching offer verbatim from the sitting record §3, "Turn into a book to arrange by hand?"),
  `BindIntoBookSheet` (no "(collecting)" toggle — the ruling's clause), `BindDoorProbe` (DEBUG).
  Shelf: "Bind into a Book…" (hidden on a finished gathering, P-2) + "Make a Book from This
  Gathering…" (a name prompt prefilled "<name> (book)" — P-13ib-U3-2) on a gathering's menu;
  `ShelfViewModel.bind` (report "… is a book now — N notes bound in … It keeps collecting.") and
  `ShelfViewModel.spawnBook` (composition in ONE runner closure: the gathering read live inside
  it, E13's name guard, `createReading(kind: .book, querySpec: rule, wingId:)` — backfill seats,
  auto-tag off, the gathering untouched). Book view: the sheet hangs off `structure.bindOffer`;
  "+ new chapter" on a gathering → `openBindOffer(followUp: .createChapter, order:)`;
  `BookStructureModel.bind(order:)` (receipt on the seam). **The teaching moment:**
  `BookStructureModel.acceptDrop` on a GATHERING answers a POST drag (the navigator rows and the
  Outline body rows — the one brain behind both) with `offerToBind` — an OFFER whose act opens the
  bind confirm; nothing is filed or written; a finished gathering hears the refusal in words
  instead (no offer that can only fail). What it replaced: the drag reached `assignPostToSection`
  and came back as "That note isn't in this book." Index/Book/Read carry no post drag (recorded).
  Registry: `.bindIntoBook`, `.makeBookFromGathering` (`.contextMenu`, book scope, `always`,
  `.native`); `ShelfView.contextMenuCapabilities` names all four. Refusal copy:
  `wrongReadingKind(expected: .gathering)` now says "That's already a book — only a gathering
  binds into one." **F-U2-3's pin GREEN on the fix** (red on the old plumbing — piece 5a). Honest
  test edits: `BookOrderConversionTests` (the door's new API/words: the report pin now asserts the
  bind's truth and that no sibling exists; the refusal pin the new sentence) and `DoorSetTests`
  (the collector-name guard died with the collector → `theSpawnDoorsNameIsGuarded`, E13 on the
  new naming door). `RuleEditorModel.load()` made idempotent (a late `.task` load can never reset
  her draft). Mac TEST BUILD SUCCEEDED.
- Piece 6 (this commit) — **the mounted pins.** `BindDoorTests` (8): F-U2-3 through the real shelf
  + the presented sheet's ruled truth (keeps collecting; no "stop arriving"; no "(collecting)";
  "Bind into a Book") · the bind words at 0/1/N and the chapter variant (lesson 3's clause in
  each; the teaching offer verbatim) · binding through the shelf keeps the row (id, name, the row
  star AND the sidebar star, the rule; one row) and KEEPS COLLECTING (a fresh tag seats at the
  end) · the spawn (sibling book: rule copied, same wing, auto-tag nil, dial nil; backfill seated
  the matches as MEMBERS; the gathering untouched and holding no rows; the sibling hears a fresh
  match) · the teaching moment (a post drag on a gathering → an OFFER with the verbatim words and
  the bind label, nothing written, no "isn't in this book"; its act opens the bind confirm with
  the count) · a book's drag still files (reorders) with no offer · a finished gathering hears a
  refusal, never an offer · the chapter door opens the bind with its count, follow-up and view
  order. `RuleEditorTests` (8, mounted where the face matters): every shape drawn with its doors
  (root group: not but no remove — it holds the old term; the negated any-of; the dead tag as
  "(deleted tag)"; the legacy term drawn with NO door; the legacy notice; no Collecting rows on a
  gathering; Save disabled) · the add doors offer exactly the wing's live tags + the star (no
  dead tag, no other wing's, never a legacy term) · edits redraw and save writes exactly the tree ·
  an unedited save writes nothing, not even an outbox row, over a non-canonical spelling · a
  malformed rule is refused (notice, no rows, no add doors, edits refused) while a book's dial
  still saves and the rule's bytes stay · a rule edit on a living book sends the gap to the door
  (`bookArrivals` counts it; never seated) · setting an auto-tag OFFERS "Also tag the 2 current
  members with #work now?" and its act tags them with a receipt · no offer when there is nothing
  to tag. **Mac: BindDoorTests + RuleEditorTests + CapabilityRegistryTests — "Test run with 44
  tests in 3 suites passed", 0 skipped** (the registry walk green with `.editRule`,
  `.bindIntoBook`, `.makeBookFromGathering` declared and rendered).
- **MUTATION CHECKS — DONE, tree restored (no mutation in flight; `git status` clean after each
  restore by `git checkout --` from 3e1201ea).** Two runs of disjoint single-mechanism mutations
  over `BindDoorTests` + `RuleEditorTests`: M1 the teaching branch removed from `acceptDrop` → **2
  red** (the offer pin; the finished-gathering refusal pin); M2 `ruleChanged` by BYTES instead of
  structure → **1 red** (the unedited-save pin, 3 issues — the non-canonical spelling rewrote and
  queued an outbox row); M3 the editor's wing filter dropped → **1 red** (the add doors offered
  another wing's tag); M4 the keeps-collecting sentence dropped from the bind's body → **2 red**
  (the presented sheet's truth; the words at every count). Every new pin family bites.
- **THE WALK — DONE, 27 captures, both voices × both appearances** (dev-store Debug build `io.lduarte.Variorum.debug`, built from the clean
  tree at ada13430; machine author-free — HID idle 4,700 s+, AX + Screen Recording granted, her app
  absent, `guard.sh` before every act; captures gitignored under `notes/plans/13ib-screens/u3/`).
  **Terminal · light — DONE (16 captures):** 01 a gathering's shelf menu carries Edit Rule… · Bind
  into a Book… · Make a Book from This Gathering… · 02 the editor on a fresh gathering (`#bind13ib`
  added through "+ tag ▾"; `not` chip + remove; Save live) · 03 the gathering starred (sidebar) +
  pinned · 04 **the bind sheet promises "the 2 notes it shows become members"** (F-U2-3 fixed in
  hand) and says it keeps collecting; no "(collecting)" toggle · 05 after the bind: the SAME row,
  still pinned and starred, "2 notes"; the receipt "…is a book now — 2 notes bound in … it keeps
  collecting." · 06 a fresh `{#bind13ib}` capture → "3 notes" (keeps collecting) · 07 the BOOK's
  editor: `all of these ▾ #bind13ib ★ starred` + the join dial + the auto-tag row · 08 a plain
  note starred (⌘K Toggle Star) then tagged by hand through the masthead tag door → **seated:
  "4 notes"** (the tagging act on a `tag ∧ star` rule) · 09 the rule edited (★ removed; the group
  keeps `#bind13ib`, no silent collapse) + auto-tag `#walked` · 10 **the offer on the seam: "Also
  tag the 4 current members with #walked now? Tag Them"** (pressed) · 11 **the gap at the door:
  Index "▾ 1 at the door · arrived today 9:06 am · add · dismiss"** — `bind five` (tagged, unstarred)
  rung by the rule edit's catch-up, never seated · 12 the spawn's name prompt ("Make a book from
  “spawn walk”", prefilled "spawn walk (book)") · 13 the sibling "spawn walk (book) · 2 notes"
  (backfill seated both) beside the surviving gathering "spawn walk · smart"; receipt "made … — 2
  notes joined, and it keeps collecting." · 14 **the hand-drag teaching offer: "Turn into a book to
  arrange by hand? Bind into a Book…"** (a navigator row dragged onto another in the gathering;
  nothing moved, no "isn't in this book") · 15 the offer's act opened the bind confirm (title
  without the chapter clause; count 2) · 16 the navigator's "+ new chapter" → the chapter variant
  ("…to add chapters?", count 2, "bind & add chapter"). **Walk findings so far:** F-U3-1 (FIXED in
  this commit — the shelf's one-shot aggregates did not refresh when the editor closed, so a saved
  rule's tag/words appeared only on re-entering the shelf; `onDismiss` refresh added) · F-U3-2
  (recorded — the note masthead's membership chip is one-shot by design, so a note seated by intake
  WHILE OPEN still read "in no book" until re-opened, then "~/bind walk"; pre-existing face
  behaviour newly reachable through U1's intake; not this unit's surface) · a walk-tooling fact: the
  toast's 6 s clock can outlive a guarded click's latency (the first offer press landed after the
  toast had gone; re-walked with an immediate click — the offer's act works).
  **After the F-U3-1 rebuild (fixed build, 71277bd5):** 17a/17b the before/after pair — the pre-fix
  build's row read "smart", no tag, right after Save (17a); the fixed build's fresh gathering
  "refresh walk" reads "#spawn13ib · smart · 4w" the moment the editor closes (17b) — the fix's
  red-on-old evidence is this behavioural before/after on the real app (no mounted pin: the edge is
  SwiftUI's sheet `onDismiss`). **Study · light:** 18 the book's editor (the voice's own casing —
  "Collects…", "wait at Arrivals"; the stored rule and `#walked` read back; Save disabled) · 19 the
  bind sheet (count 2, the truth) · 20 the teaching offer. **Study · dark:** 21 the teaching offer ·
  22 its act → the bind confirm · 23 the book's editor. **Terminal · dark:** 24 the book's editor ·
  25 the shelf door's bind sheet (count 2) · 26 the teaching offer. All legible in the black room;
  tokens only; nothing clipped. **Walk notes:** (1) after closing Settings, activation did not raise
  the main window above the orchestrator's terminal, so two right-clicks landed in the TERMINAL'S
  frame (at most opening its context menu); `keys.sh` re-proves the dev app frontmost before every
  keystroke, so no text reached the terminal — and the Pool shows no stray notes. The helpers were
  hardened mid-walk: AXRaise the dev window and require it TOPMOST at the point
  (`CGWindowListCopyWindowInfo`) before every click — worth folding into `Tools/WalkKit` (left for
  the orchestrator; not this unit's surface). (2) One Escape on the book view's bind sheet did not
  dismiss it (every other Escape did; the sheet was then cancelled by its own Cancel button through
  AX) — no mechanism traced, so no speculative fix (the hallucination guard). Her dev settings
  restored and READ BACK: voice Terminal (AX `1,0`), Appearance Follow system (AX `1,0,0`;
  `appearanceChoice = system`); the instance quit by identity; zero instances; my `caffeinate`
  stopped. The dev store keeps the walk's books ("bind walk", "spawn walk", "spawn walk (book)",
  "refresh walk"), the tags `#bind13ib`/`#spawn13ib`, nine notes, and `#walked` on bind walk's four
  members (dev store — harmless).
- **CLOSE (this commit) — the final verification, after the last code edit (71277bd5's F-U3-1
  line):** the FULL core suite `swift build --build-tests && swift test` — **"Test run with 1868
  tests in 195 suites passed"** (1 skipped: the standing env-gated Supabase integration test;
  baseline 1852/194 at U2's close → +16 tests / +1 suite: `RuleEditingTests` 13 + 3 new conversion
  pins). The mobile target (`VariorumMobile`, generic iOS Simulator) — **BUILD SUCCEEDED**. The Mac
  app built inside the Mac suite runs; suite-level `-only-testing` by struct name, counts read
  exactly: **A — readings / conversion / shelf / book view / registry: "Test run with 144 tests in
  19 suites passed", 0 skipped, 0 known issues** (BindDoor, RuleEditor, CapabilityRegistry,
  BookOrderConversion, DuplicateBookNameDoor, BookAscentDeclaration, CalloutSwatch,
  CalloutEmojiPicker, TimelineAndReadings, BookArrivals, BookStructureModel, JournalBooks, BookDrop,
  BookView, BookFocusFold, OutlineWritingSurface, SpreadBookView, ShelfModel, PromoteAndPalette);
  **B — the status seam, the router and THE TUTORIAL SPINE (all eleven `TutorialWalkTests`
  suites): "Test run with 94 tests in 13 suites passed", 0 skipped, 0 known issues.** Zero instances
  throughout; `git status` clean. Ledger row 4 flipped. No revert in flight; nothing uncommitted.
  U3 CLOSED.

## ORCHESTRATOR VERIFICATION — U3 (2026-10-01, before U4's spawn)

- Trail verified (12 commits, discipline held — F-U2-3 pinned RED before its fix, P-13ib-6's
  pins watched red on the old inverse, mutations announced + restored; pushed, tree clean).
  Suites re-run by the orchestrator's hand: core `RuleEditingTests` + `SmartConversionTests`
  37/2 GREEN · Mac `BindDoorTests` + `RuleEditorTests` 16/2 GREEN. Captures reviewed: 04 (the
  bind sheet — count RIGHT, keeps-collecting spoken, identity promised), the 17a/17b F-U3-1
  before/after pair listed; full drive rides the end-of-phase walk.
- **Adjudications:** P-13ib-U3-3 SUSTAINED (the undo clears waiting arrivals too — an arrival
  row on a gathering is wrong-shaped; "no live row" is P-13ib-6's letter; redo revives exactly
  what undo took). F-U3-3 → U4's charter, LOUD (the gathering assembly's star context — the
  bind count and Pool flow through the same read). F-U3-4 (the conversion op's dead
  keepCollecting/collectingName params) → held for the LADDER-fix window or a closeout
  structure single; not U4's. F-U3-2 (the membership chip's one-shot staleness under an
  intake seat) → a KnownIssues row at closeout, owner 13i-d. F-U3-5 (walk tooling: raise the
  window + require-topmost-at-point) → folds into 17w's standing VisualWalk-hardening row
  (KnownIssues 97); no stray writes verified by the implementer (keystrokes re-guarded, Pool
  clean). F-U3-1's fix stands WITHOUT a mounted pin — an acknowledged deviation, recorded for
  the ladder: the dismissal-triggers-refresh shape is the whole-surface mount class the rig
  cannot drive (the standing KnownIssues row); the before/after captures are its evidence.
- Copy nit for the bundle/13s: the bind sheet's "It stays the same book on your shelf" speaks
  of the pre-bind GATHERING as a book; exact words would be "it stays on your shelf — same
  name, same star." Recorded, not patched (copy is hers).

## U4 RECORD — the star context · the starred gathering · Quicknotes verify · the Pool tuck · the filter mechanics (opus-implementer, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** PENDING — written at close.

**UNIT STATUS: IN PROGRESS.**

### The settled design (written before code)

- **A — the star context (F-U3-3).** `ruleMatchSQL` loses its `starredNoteIDs = []` default, and so do
  its two wrappers (`matchesRule`, `smartMembershipSQL`) — every caller must pass the context, so the
  compiler enumerates the sites and no future one can silently match nothing. The context is fetched
  LAZILY (only when the rule in hand references a star term — `RuleGrammar.referencesStar`) through
  `Queries.starredNoteIDs` (live NOTE targets only, star order; bounded by `Operations.starLimit`,
  which caps the WRITE side, so the `IN` list is ≤ 15 by construction). Site classes: the gathering
  ASSEMBLY (→ the book view, export, the bind's materialization + its count, the shelf count, the info
  panel, the phone's book view), the WORD COUNTS, the POOL, the membership CHIP, the Library card's
  gathering list, the COLLECT door's two probes; intake (U1) already passes it. A held observation that
  reads the context tracks the `setting` row, so un-starring evicts on the next tick (derived).
- **B — the starred-notes gathering.** Core op `ensureStarredNotesGathering()` (silent, never throws —
  the `fileAsQuicknote` shape): ONE write transaction; PRESENT = a live Home reading whose rule is
  exactly `{"star":true}` (any kind — a bind keeps the row) or wearing the reserved name (E13's
  sense — never mint a second same-named row); DELETED = a tombstoned Home reading with that rule or
  that name (`readingTombstoneExists`'s class, rule-keyed too); else MINT an ordinary gathering —
  rule `{"star":true}`, name `"starred notes"` (P-13ib-4, one constant), unshelved, unstarred, sort
  as Quicknotes (created, newest first). App side, `Shared/StarredGatheringSeeder` holds the
  per-store-variant DEVICE MARK and the sync gate (the `SampleLibrarySeeder` discipline); the Mac's
  launch task calls it after the sample books. The phone's occasion is DEFERRED to the mobile
  catch-up (its pins count readings at the first write — a second surface).
- **C — Quicknotes verify.** Read: kind gathering, rule `#quicknote`, no delete guard anywhere, no
  sync keeper, evict-on-untag derived (pinned since 13g). Found: the filing door RE-MINTS the
  gathering after she deletes it (the designation dangles ⇒ mint) — the daily Journal's "comes back"
  trait, which §20 explicitly withholds from Quicknotes. Fix (PROVISIONAL): a dangling designation
  is her decision — no re-mint; the note still lands tagged and the receipt stops claiming a
  Quicknotes landing that did not happen.
- **D — the Pool tuck.** `Queries.poolListing(db, window:)` — ONE statement classifies every
  bookless note (no live MEMBER row) as shown-by-some-live-gathering or not, with per-class counts and
  per-class windows (window functions); `poolPosts` keeps its contract (the untucked class) so the
  phone and the pins read the same split. The Pool's masthead reads "Pool · N notes · M in gatherings
  · show"; the click toggles the tucked run (view state); an empty-but-gathered Pool says so.
- **E — the in-book filter mechanics.** `assembleReading(…, filter: RuleTerm?)` — view-local, a read
  (never membership); the filter applies to the ASSEMBLY (after a cap, before the caller's window).
  `saveFilterAsGathering(readingID, filter:, name:)` mints a gathering whose rule = the reading's tag
  association ∧ the filter (PROVISIONAL reading of "association": a gathering's or living book's own
  rule, else the book's live auto-tag, else none — the filter alone, reported).

### U4 LIVE STATUS (per commit; every unverified claim PENDING)

- Preflight read in this session, not delegated: CLAUDE.md + canon, this plan whole (§1–§7, the U1/U2/U3
  RECORDS + the three orchestrator verifications, the ledger, the morning bundle), the sitting record §1–§4,
  §7–§9, §14, §17–§25 (§3, §8, §18.1, §19.3, §20, §25 lesson 10 closely), the resiliency protocol whole.
  No `Sync/`, custody, schema or editor-seam work planned (SyncSpec / TEXTKIT2_NOTES not required). No
  revert in flight. No subagents.
- Piece 1 (d9cff909): the record opened.
- Piece 2 (this commit — **WIP: `StarContextTests` deliberately RED until piece 3; no revert in
  flight**): the star-context pins written FIRST, one per site class (assembly incl. `NOT ★` and the
  tag ∧ ★ conjunction · a HELD observation hearing the un-star alone, deadline-bounded · the bind's
  materialization + the sheet's count · the shelf word counts · the Pool exclusion · the membership chip ·
  the Library card's gathering list · the collect door's two probes) + two boundary controls (wing +
  archive; a starred BOOK is never a note target). **Red-on-old watched: 9 of 11 red on the pre-fix
  tree, each at its own mechanism** (empty assembly; `NOT (0)` matching every tagged note; no
  re-emission on un-star — the old assembly never read the setting; bind count 0 and zero members
  bound; 0 words; the starred notes still in the Pool; no chip; no card line; the collect door refusing
  "tagging alone can't satisfy" for a note that already matched). The two controls pass on both sides
  by design (they guard the fix against over-matching). First run note: the observation pin's bare
  `next()` HUNG on the old tree (no re-emission) — rewritten deadline-bounded so red is a failure, not
  a hang.
- Piece 3 (this commit) — **A, the star context, FIXED (F-U3-3 closed).** `ruleMatchSQL`,
  `matchesRule` and `smartMembershipSQL` lose the `starredNoteIDs = []` default (the compiler now
  enumerates the sites — the complete list: the gathering arm of `assembleReading`; `bookWordCounts`;
  `poolPosts`; `readingsContaining`; `smartBookMembership` → `smartMembershipSQL`; the collect door's
  two probes; intake's `intakeEvent` + `intakeSweep`, which already passed it). `Queries.StarContext`
  is the ONE way a site gets the list: `ids(_:for:)` answers `[]` with NO read when the rule has no ★,
  else reads `starredNoteIDs` once per context (a loop over every gathering pays one setting read at
  most). A star gathering's held observation now tracks the `setting` row — un-starring re-emits.
  The one test caller (`SmartBookMembershipTests`' EXPLAIN pin) passes `[]` explicitly. **`StarContextTests`
  11/11 GREEN** (9 red before); neighbours (membership, collect, quicknote, wing scoping, assembly,
  conversion, intake ops, ritual, shelf queries, tagsAll, stars) — **165 tests / 16 suites green**.
- Piece 4 (this commit) — **B, the starred-notes gathering.** Core `Operations+StarredGathering.swift`:
  `starredNotesGatheringName = "starred notes"` (P-13ib-4's one constant) and
  `ensureStarredNotesGathering()` → `minted` / `alreadyPresent` / `deletedByTheReader` / `refused`,
  never throwing, ONE write transaction; the signature (live or tombstoned) is a HOME reading whose rule
  is exactly ★ OR that wears the reserved name (BookNaming's fold); the mint is an ordinary gathering —
  rule `{"star":true}`, profile `collection`, created/newest-first (Quicknotes' shape), unshelved,
  unstarred, no Collecting settings. App: `Shared/StarredGatheringSeeder` (per-store-variant device mark
  `StarredGatheringSeeded.<variant>`, the sample seeder's sync gate, one log line; a REFUSAL is not
  marked), called from the Mac window's `.task` after the sample books (`VariorumApp.swift`). Pins: core
  `StarredNotesGatheringTests` **9/9 green** (fresh store's row exactly; star shows / un-star leaves, no
  rows; an existing store gets it and nothing else moves; idempotent; deleted-stays-deleted even renamed
  first, and by name alone; restore is the ordinary door; her own ★ gathering and its BOUND book count
  as present; the reserved name in use is never twinned; only Home counts) — new surface, no prior
  behaviour to be red against. Mac `StarredGatheringSeederTests` **"Test run with 6 tests in 1 suite
  passed", 0 skipped** (unmarked → minted + marked; marked → never asked, even with no row/tombstone — a
  purge's state; her deletion recorded in the mark; an account store waits for its first clean round and
  is NOT marked; a synced account store seeds; the mark is per variant). The phone's occasion: DEFERRED
  (see the record's not-done line).
- Piece 5 (this commit) — **C, Quicknotes VERIFIED; one special-casing found and FIXED (PROVISIONAL
  P-13ib-U4-2).** Verified ordinary: `kind = gathering`, rule `#quicknote` by tag ID, NO delete guard
  (`deleteReading` is the plain tombstone; no face hides the door; no face reads the designation), NO
  sync keeper (zero `Sync/` mentions), unshelved at mint (no `shelf_id`), evict-on-untag derived (pinned
  since 13g, `theBookCOLLECTSTheTagAndRemovingTheTagLEAVESIt`, still green). FOUND: the filing door read
  a dangling `quicknote_book` designation as "none" and MINTED A FRESH Quicknotes at the next quick note
  — the daily Journal's comes-back trait (lesson 9), which §20 withholds ("no special identity, no delete
  guard … deleting the gathering breaks nothing — quick notes still land, still tagged, still findable in
  the tag's own listing, and the gathering is re-makeable in one gesture"; "two special books is one more
  than the design needs"). **Pinned first:** `QuicknoteShelfTests.deletingQuicknotesIsHerWordAndTheNext
  QuickNoteStillLandsTagged` — **RED on the pre-fix tree, 5 issues at the mechanism** (the filing claimed
  `.filed`; one live reading re-minted; the note shown by the twin so not in the Pool; after restoring
  the original the designation pointed at the twin and two live Quicknotes stood). **Fix:**
  `ensureQuicknotesBook` → `String?` — a designation that names nothing live is her decision
  (`Queries.quicknotesBookWasDesignated`, the synced setting row — the decision travels with the store);
  `fileAsQuicknote` gains `.taggedOnly(tagID:)`; the pad's receipt for it is
  `QuickNoteCopy.filedTaggedOnly` "Filed in the Pool — tagged #quicknote." (the success line would claim
  a landing that did not happen). GREEN after. **ONE honest test edit:** `aDanglingDesignationMintsAfresh
  AndALiveOneIsNeverReplaced` asserted the retired re-mint → `aLiveDesignationIsNeverReplacedAndADead
  OneNeverReadsLive` (its live-designation half kept whole). Mac pin `QuickNoteMintTests.afterSheDeletes
  QuicknotesTheReceiptSaysThePool`. Core quicknote + star suites **26 tests / 3 suites green**; Mac
  `QuickNoteMintTests` + `QuickNoteWordTests` + `NodSetTests` **"Test run with 19 tests in 3 suites
  passed", 0 skipped**.
- Piece 6 (this commit) — **D, the Pool tuck: the CORE split.** `Queries.poolListing(db, window:)` →
  `PoolListing { loose, tucked, looseCount, tuckedCount }` by ONE statement (`poolListingSQL`): every
  bookless note (no live MEMBER row — an arrival is not a home) classified ONCE by the OR of the live
  gatherings' rules (each the assembly's own letter: no rule = every note in its wing, malformed = tucks
  nothing, the ★ context through `StarContext`, each rule's truth COALESCEd to 0), then
  `ROW_NUMBER`/`COUNT(*) OVER (PARTITION BY shown)` — exact class sizes, ≤ `window` rows per class,
  newest touched first. `poolPosts(limit:)` = `poolListing(window:).loose` (the phone and every pin read
  the one split). P1 stated in the doc and pinned on the PLAN. `PoolTuckTests` (7): lesson 10 against
  the store's own truth (loose ∪ tucked = the bookless set exactly; tucked = what gatherings show; the
  member in neither) · exact counts beyond the window · un-tag / un-star untuck at once · each
  gathering's letter (none · malformed · no-rule = empty-but-gathered · wing-scoped) · an arrival is not a
  home · **a legacy term over a NULL column never hides a note (traced: the old exclusion `NOT (<rule>)`
  went NULL for a `{"profile":…}` rule against a profile-less note — every `createPost`/`importPost` note
  — and the note vanished from the Pool though no gathering showed it; red-on-old check NEXT, revert
  PENDING)** · the EXPLAIN plan (posts by `idx_container_kind`, the membership probe on
  `idx_reading_post_post`, tag terms on `uq_tag_path_live` + `uq_post_tag_live` — the shipped rule
  predicate's own plan, ∝ the taxonomy — no SCAN of `rp`/`pt`, no block/variant). **7/7 green**; with
  the neighbours (star context, wing scoping, quicknote, shelf queries, membership, the intake SOAK whose
  invariants include Pool agreement, the ritual, pool tray) **80 tests / 12 suites green**.
- **REVERT CHECK — DONE, tree restored (no revert in flight).** `poolPosts` alone swapped back to its
  pre-U4 `NOT (<rule>)` body against the committed 8a07852d: `aLegacyTermOverANullColumnNeverHidesA
  NoteFromThePool` **RED** (the plain note hidden — `pool → []`), the other six green; restored by `git
  checkout --`, `git status` clean. **F-U4-1 (a latent Pool bug, FIXED with the split):** since 13i-a's
  v2 rules, any grandfathered `{"profile":…}` / date-bound gathering emptied the Pool of every note
  lacking that column (NULL) — the notes every ordinary door mints.
- Piece 7 (this commit) — **D, the Pool tuck's FACE** (`Features/Pool/PoolPostsView.swift`). The model
  observes `poolListing` and keeps `posts` (loose), `tucked`, both exact counts and `showsTucked` (VIEW
  state — off on every visit, never remembered: P-13ib-U4-4); `adopt(_:)` is the observation's body and
  the pins' seam; `toggleTucked()` is the one click; the chips/previews read covers only the DRAWN rows.
  The masthead: "Pool" + "· N notes · M in gatherings ·" + the accent `VoicedButtonStyle(.primary)`
  "show"/"hide" (only when something is tucked); the tucked run renders after the loose cards under the
  Library's quiet section-label idiom ("in gatherings" over a hairline); the empty state says "No loose
  notes — all M bookless notes show in gatherings." when empty-but-gathered (never "the pool is empty"
  over tucked notes). Words in one pure home, `PoolTuckCopy` (number-agreeing; voice casing by
  `chromeLabel`; P-13ib-U4-5). Every chrome text `lineLimit`-ed; tokens only. DEBUG `PoolTuckProbe` (the
  `ArrivalsLineProbe` pattern; per-class row forgets). **Registry call (F):** the show/hide toggle is NOT
  declared — a view-local disclosure over rows the page already owns, the Arrivals line's own expansion
  precedent (U2 declared only the judgment acts); the cards' acts are unchanged and stay declared
  (`.tagNote`). Mac `PoolTuckFaceTests` (5): her shape verbatim + the count words · mounted: the
  gathered notes tuck (masthead "· 2 notes · 3 in gatherings ·", "show", loose drawn, none tucked) → the
  click draws the tucked run under its label ("hide") → back · the empty-but-gathered sentence and its
  show · the truly-empty Pool offers no toggle · starring tucks a note, un-starring brings it back (the
  starred gathering present). **"Test run with 9 tests in 3 suites passed", 0 skipped** (with
  `PoolPageTests` + `PoolCardPreviewTests`).
- Piece 8 (this commit) — **E, the in-book filter MECHANICS (headless).** `Queries.assembleReading(…,
  filter: RuleTerm?)`: a view-local read over the ASSEMBLY (never membership — no write, no outbox row;
  nil is byte-identical); the filter is the gathering grammar itself (wing-scoped, the ★ context lazy),
  inserted into each arm's WHERE so a book keeps its order and its chapters; on a CAPPED reading it runs
  over the capped assembly's ids instead (`filteredIDs`, the `CROSS JOIN` page-driven shape — ∝ the cap),
  so a filtered view never reaches a member past the cap; the caller's `limit` applies last.
  `Operations.saveFilterAsGathering(readingID, filter:, name:)` → `SavedFilterGathering { reading,
  association: .rule | .autoTag | .none }`, ONE transaction: a gathering whose rule =
  `RuleGrammar.conjoin(association, filter)` (pure, flat — a top-level AND spreads; an OR stays a term),
  in the source's wing, unshelved, unstarred; the source untouched (row snapshot pinned). Association
  (PROVISIONAL P-13ib-U4-6): any reading's READABLE rule (a gathering's or a living book's); a rule-less
  gathering → the filter alone, exactly (it shows everything in its wing); a book without a readable rule
  → its LIVE in-wing auto-tag, else none (the filter alone — reported so the face can say it gathers from
  the whole library); a MALFORMED gathering refuses (`smartFilterUnsatisfiable`, the collect door's
  wording). No name guard (E13's assert is the door's), no undo entry (`createReading`'s class).
  `ReadingFilterTests` (11): the book's view narrowed in its own order (tag, ★, ∧¬, ∨), writing nothing ·
  chapters survive · a gathering's view narrowed · the cap holds and the window applies last · the five
  association shapes incl. the flat conjunction, the dead auto-tag, the malformed book rule falling through,
  a gathering's saved filter = its filtered view (same predicate) · the refusals mint nothing · `conjoin`
  pure. **11/11 green** (new surface; mutation checks below).
- **MUTATION CHECKS — DONE, tree restored (no mutation in flight; `git status` clean after each restore
  by `git checkout --` from b48ca12e).** Core: M1 `StarContext.ids` always `[]` (F-U3-3 re-created
  globally) → **30 issues** across `StarContextTests`, `StarredNotesGatheringTests`, `PoolTuckTests` ·
  M2 the starred ensure ignores tombstones → **2 red** (deleted-stays-deleted, by rule and by name) · M3
  the Quicknotes ensure ignores the decided designation → **1 red, 5 issues** · M4 the capped-filter path
  removed → **1 red** (a member past the cap leaks into the filtered view) · M5 `conjoin` stops spreading
  → **2 red** · M7 the auto-tag association dropped → **2 red**. Mac: M8 the empty-but-gathered sentence
  collapsed to "the pool is empty" → **2 red** · M9 the tucked run drawn without the click → **2 red**.
  Every new pin family bites.

## §8 LEDGER (every row owned; statuses flip in the same commit as the work)

| # | Item | Status |
|---|---|---|
| 1 | Plan authored; kickoff PROVISIONALs recorded (§6) | DONE (this commit) |
| 2 | U1 — intake + auto-tag + judgment ops + ruleSQL wing scoping + the R3 ritual spine | **DONE 2026-10-01** — the U1 RECORD above (design map · P-13ib-U1-1…9 · F-1…F-6); evidence: `IntakeDecisionTests` 13 · `IntakeOperationsTests` 42 · `ArrivalMemberHygieneTests` 6 (red-on-old 6/6) · `RuleWingScopingTests` 3 (red-on-old 2/3, the third the control) · `IntakeSoakTests` 6 seeds × 300 steps · `GatheringRitualTests` 3 (R3 + lessons 3–4); 5+2 mutation checks bite; core 1840/193 green; Mac + mobile build; changed-op Mac suites 380/74 + mobile 101/22 pass. **F-1 is U3's to carry (a shipped sentence now false)** |
| 3 | U2 — the Arrivals face | **DONE 2026-10-01** — the U2 RECORD above (design map · P-13ib-U2-1…5 · F-U2-1…5 · THE WALK, 15 captures, both voices × both appearances); evidence: `ArrivalQueriesTests` 12 (incl. the EXPLAIN-plan pin) · `BookArrivalsTests` 10 mounted (absent/present on Index AND Book, gone on Outline/Read, expansion + both doors, Add at the END unsectioned, Dismiss, the capacity refusal on the seam, already-judged, vanish) · the registry walk (`BookArrivalsLine` the two acts' one renderer); 2 mutation checks bite; core 1852/194 green; Mac + mobile build; book-surface + registry + tutorial Mac suites 335/57 pass (4 standing known issues). **F-U2-3 joins F-1 in U3's charter** (the conversion sheet's wrong count) |
| 4 | U3 — the rule editor + bind/spawn + the teaching moment | **DONE 2026-10-01** — the U3 RECORD above (design map · P-13ib-U3-1…7 · F-U3-1…6 · THE WALK, 27 captures, both voices × both appearances); evidence: `RuleEditingTests` 13 (the every-edit-touches-only-its-node property; unedited/malformed write nothing; legacy never removable) · P-13ib-6 pins 2 (red-on-old watched) + the §19.6 identity pin · `BindDoorTests` 8 (F-U2-3 red-on-old through the real shelf, mechanism confirmed by experiment; F-1's truth; identity + keeps collecting; spawn; the teaching offer) · `RuleEditorTests` 8 mounted · the registry walk (`.editRule`, `.bindIntoBook`, `.makeBookFromGathering`); 4 mutation checks bite; core 1868/195 green; Mac + mobile build; Mac suites 144/19 + 94/13 incl. the tutorial spine. **F-U3-3 is U4's to carry** (the gathering assembly's star context also feeds the bind) |
| 5 | U4 — starred gathering · Quicknotes verify · Pool tuck · filter mechanics | NOT STARTED |
| 6 | The ladder (fresh `fable-reviewer`, combined diff) | NOT STARTED |
| 7 | Closeout + morning bundle + handoff (canon deltas PROPOSED, not applied) | NOT STARTED |

## THE MORNING BUNDLE (everything held for her; grows as the run proceeds)

1. The §6 PROVISIONALs (P-13ib-1 … P-13ib-5) — each built as stated, each one line/constant to
   overturn.
2. Her 13i-a carry-overs, still open: the #167 ratify + the three 13i-a §9 PROVISIONALs (the
   handoff's checklist).
3. The canon-delta PROPOSALS (drafted at closeout, landing at her word).
4. ~~The install refresh, if no zero-instance window existed overnight~~ — **SANCTIONED mid-kickoff,
   her words: "my app is quit and ready for reinstall."** The refresh runs at the run's END
   (after the walks and the ladder, per the sizing rule), behind the A1 rail, with a pgrep
   re-check at the moment. Her same message pinned the end review: "make sure you do a Fable
   review at the end" — ledger row 6 is that ladder, `fable-reviewer`, confirmed.
5. **U1's PROVISIONALs P-13ib-U1-1…9** (the U1 RECORD, each with a QUESTIONS-ready paragraph).
   The headline is **U1-1**: a note you DISMISSED from Arrivals comes back to the door on a
   fresh tagging/starring act (never auto-seated); a note you REMOVED as a member stays out
   for good — the adjudicated synthesis of §4's tombstone-means-decided and §24's "returns
   only on a fresh tagging act" (the architect sustained the build; the ruling note is at
   plan §2.1).
6. **F-2 — your existing converted books are LIVING books now** (they kept their rules as
   provenance; §14.6 rules they keep collecting). Nothing moves until your next matching tag
   or star; any "(collecting)" sibling from the old offer will double-collect with its book
   until U3's door rework (and the pair is yours to prune at will).
7. **F-3 — the phone runs intake from its NEXT build** (intake is local acts through shared
   core; no sync hazard — R1 converges both devices' rows). Tags made on the current phone
   build aren't heard by books until a catch-up occasion; a phone rebuild whenever convenient.
8. **P-13ib-6 (architect, with U3):** undoing a BIND leaves no live member row on the
   reverted gathering — a gathering holds nothing; every row tombstones at the revert,
   intake-seated and hand-added alike.
9. Anything the remaining units add (held taste calls, walk findings).

## HER MORNING SITTING — RULINGS (2026-10-01, mid-U4; recorded verbatim-faithful the same turn)

1. **F-U2-1 RULED — Outline carries the Arrivals line too.** Her words: *"i think the arrivals
   visibility could be added to outline."* Build: the same `BookArrivalsLine` wired into the
   book's Outline surface (the one renderer, a third host). **Owner: the architect's
   post-U4 adjudication batch** (small; lands before the ladder so the ladder reviews it cold).
2. **P-13ib-1 RATIFIED — auto-tag applies on hand-add.** Her words: *"I think that hand adding
   a note to a collecting book should apply the auto tag."* As built at U1.
3. **P-13ib-3 OVERRULED — the SPAWN door sets the auto-tag.** Her words: *"the spawn isn't
   adding the auto tag? it should."* Implementation reading (stated to her in the sitting
   reply; PROVISIONAL on the ambiguous arm only): where the copied rule references exactly ONE
   distinct tag, the spawned book's `auto_tag_id` is that tag; where the rule names several
   tags (an OR fan) or none (star-only), there is no single honest outflow — the spawn leaves
   it unset and the rule editor's row is one click (the ambiguous arm is bundled back to her).
   **Owner: the architect's post-U4 adjudication batch.**
4. **Her "can living books be killed?" — answered in the sitting reply, with one gap found:**
   intake stops by CLEARING the rule (Edit Rule…) or pauses by FINISHING; deleting the book
   is the ordinary Trash road. **VERIFY ITEM for the adjudication batch:** the U3 editor must
   be able to save an EMPTY rule as NULL on a book (the kill switch — P-13ib-5's "intake runs
   iff a readable rule is present"); on a GATHERING a cleared rule means match-all (the
   standing NULL-spec letter), so the editor's clear door should say which it will mean.
5. **P-13ib-U1-1 RATIFIED as built.** Her words: *"I think the new act on the note bringing it
   back to arrivals is fine - i would expect that. if there's a new tag on there, i might want
   it to come in. so yes, not dismissed forever. as build is good."* The §2.1 amendment and
   the U1 shape stand; the QUESTIONS entry closes as answered at the phase's close. **U1:** P-13ib-U1-1…9 (the U1 RECORD —
   U1-1 is the reconciliation of §4's tombstone-means-decided with §24's "returns on a fresh act");
   F-2 (pre-13i-b converted books are now living) and F-3 (the phone runs intake from its next build).
   **U2:** P-13ib-U2-1…5 (the U2 RECORD — where the line stands, archived waiting notes, the
   expansion as view state, the 30-row window with no bulk dismiss, the words); F-U2-1 (a book opens
   into Outline, where the ruled line does not stand — should Outline carry it too? hers) and F-U2-2
   (a QUIET receipt has no visible home on Index/Book while no note is live — the 18i seam's
   placement).
   **U3:** P-13ib-U3-1…7 (the U3 RECORD — legacy terms read-only all the way down, the spawn's name
   prompt, P-13ib-6's reach incl. arrivals and the exact redo, the teaching offer opening the
   confirm, when the tag-members offer asks, an empty rule clearing the rule, the words); F-U3-2
   (the note chip doesn't hear an intake seat while the note is open — a face, owner 13i-d) and
   F-U3-4 (the op's dead "(collecting)" parameters).

## LIVE STATUS (the resiliency protocol's record — updated per commit; every unverified claim marked PENDING)

- 2026-10-01 · kickoff: preflight complete (CLAUDE.md + canon, the master plan, KnownIssues
  whole, QUESTIONS' open tail #160–#167, the sitting record whole, the 13i-a execution record +
  handoff + deploy checklist banner, the resiliency protocol, the sizing guidance; SyncSpec
  full read NOT required — zero `Sync/` planned, §2.7 states the posture and the stop rule;
  TEXTKIT2_NOTES not required — no editor seam). Code orientation done (RuleGrammar,
  ReadingAssembly/ruleMatchSQL/legacyDraft, SmartCollect, Reading ops, stars, quicknote,
  arrival plumbing). Her overnight conversion recorded in the banner. This plan authored as
  the first act. No revert in flight. U1 spawns next.
