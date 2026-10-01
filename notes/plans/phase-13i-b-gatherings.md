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
     generalized: ANY `reading_post` row for the pair) → `nothing`.
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
  auto-tag rows, bind-in-place, spawn, the hand-drag teaching offer. **Evidence:** mounted pins
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

**NOT DONE BY THIS UNIT (first line, per the contract):** PENDING — filled at close.

### U1 LIVE STATUS (per commit; every unverified claim PENDING)

- Preflight read in this session, not delegated: CLAUDE.md + canon, this plan whole, the sitting
  record §3/§4/§14/§19/§20/§24 (+ §1–§25 read through), the 13i-a record §3/§4/§9, the resiliency
  protocol, SyncSpec whole (convergence-adjacent: R1's status-aware pair dedupe is the posture §2.7
  leans on). No revert in flight. No subagents.
- Piece 1 (this commit): the record opened. NEXT — piece 2: `Domain/IntakeDecision.swift` + the
  intake engine (`Operations+Intake.swift`) + the hooks.

## §8 LEDGER (every row owned; statuses flip in the same commit as the work)

| # | Item | Status |
|---|---|---|
| 1 | Plan authored; kickoff PROVISIONALs recorded (§6) | DONE (this commit) |
| 2 | U1 — intake + auto-tag + judgment ops + ruleSQL wing scoping + the R3 ritual spine | NOT STARTED |
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
5. Anything the units add (held taste calls, walk findings).

## LIVE STATUS (the resiliency protocol's record — updated per commit; every unverified claim marked PENDING)

- 2026-10-01 · kickoff: preflight complete (CLAUDE.md + canon, the master plan, KnownIssues
  whole, QUESTIONS' open tail #160–#167, the sitting record whole, the 13i-a execution record +
  handoff + deploy checklist banner, the resiliency protocol, the sizing guidance; SyncSpec
  full read NOT required — zero `Sync/` planned, §2.7 states the posture and the stop rule;
  TEXTKIT2_NOTES not required — no editor seam). Code orientation done (RuleGrammar,
  ReadingAssembly/ruleMatchSQL/legacyDraft, SmartCollect, Reading ops, stars, quicknote,
  arrival plumbing). Her overnight conversion recorded in the banner. This plan authored as
  the first act. No revert in flight. U1 spawns next.
