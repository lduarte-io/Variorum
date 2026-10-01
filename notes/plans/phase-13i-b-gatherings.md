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

## §8 LEDGER (every row owned; statuses flip in the same commit as the work)

| # | Item | Status |
|---|---|---|
| 1 | Plan authored; kickoff PROVISIONALs recorded (§6) | DONE (this commit) |
| 2 | U1 — intake + auto-tag + judgment ops + ruleSQL wing scoping + the R3 ritual spine | **DONE 2026-10-01** — the U1 RECORD above (design map · P-13ib-U1-1…9 · F-1…F-6); evidence: `IntakeDecisionTests` 13 · `IntakeOperationsTests` 42 · `ArrivalMemberHygieneTests` 6 (red-on-old 6/6) · `RuleWingScopingTests` 3 (red-on-old 2/3, the third the control) · `IntakeSoakTests` 6 seeds × 300 steps · `GatheringRitualTests` 3 (R3 + lessons 3–4); 5+2 mutation checks bite; core 1840/193 green; Mac + mobile build; changed-op Mac suites 380/74 + mobile 101/22 pass. **F-1 is U3's to carry (a shipped sentence now false)** |
| 3 | U2 — the Arrivals face | NOT STARTED |
| 4 | U3 — the rule editor + bind/spawn + the teaching moment | NOT STARTED |
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
9. Anything the remaining units add (held taste calls, walk findings). **U1:** P-13ib-U1-1…9 (the U1 RECORD —
   U1-1 is the reconciliation of §4's tombstone-means-decided with §24's "returns on a fresh act");
   F-2 (pre-13i-b converted books are now living) and F-3 (the phone runs intake from its next build).

## LIVE STATUS (the resiliency protocol's record — updated per commit; every unverified claim marked PENDING)

- 2026-10-01 · kickoff: preflight complete (CLAUDE.md + canon, the master plan, KnownIssues
  whole, QUESTIONS' open tail #160–#167, the sitting record whole, the 13i-a execution record +
  handoff + deploy checklist banner, the resiliency protocol, the sizing guidance; SyncSpec
  full read NOT required — zero `Sync/` planned, §2.7 states the posture and the stop rule;
  TEXTKIT2_NOTES not required — no editor seam). Code orientation done (RuleGrammar,
  ReadingAssembly/ruleMatchSQL/legacyDraft, SmartCollect, Reading ops, stars, quicknote,
  arrival plumbing). Her overnight conversion recorded in the banner. This plan authored as
  the first act. No revert in flight. U1 spawns next.
