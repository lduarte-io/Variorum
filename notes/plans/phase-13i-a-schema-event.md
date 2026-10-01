# Phase 13i-a — THE SCHEMA EVENT (wings · shelves · the gathering/book recast · the 13i lockstep bundle)

**STATUS: OPEN — kicked off 2026-09-30 by the author's `/architect-phase 13i-a` invocation, the same
day the design sitting closed.** The BINDING DESIGN is `notes/plans/phase-13i-sitting-record-2026-09-30.md`
(§1–§25, fully ruled; §11 is this run's charter, §15 its scope line) — this file carries the
EXECUTION: the concrete schema, the sync design, the units, the ledger, and the records. The brief
(`notes/plans/phase-13i-smart-book-identity-brief.md`) is raw material read through the record.
13r stands OPEN-PAUSED at its own kickoff (its plan file's banner); she resumes it at her word —
this run does not touch it.

**Cast (the sitting's §15 line + the standing Sync rider):** 13i-a is FABLE WORK end to end — the
orchestrator-architect (this session) implements both units (the RUN B / 13y precedent: there is no
fable-implementer agent type, and the rider fences `Sources/VariorumCore/Sync/` to Fable); ONE
fresh `fable-reviewer` ladder runs over the combined diff (same-model flow: the orchestrator
arbitrates against the spec). Sizing honesty per `notes/PhaseSizingGuidance.md`: TWO acceptance
units in one orchestrator-implementer session deviates from the one-unit-per-implementer-session
letter under the Sync-rider precedent; the resiliency protocol (commit per piece, push every
commit, LIVE STATUS from the first commit) is the compensating discipline. The author may redirect.

**The lockstep:** ONE SyncSpec §12 event, marker **9 → 10**, landed before strangers (the
2026-08-25 bundling note executed — EVERY schema need 13i b–e will consume lands HERE, so no second
event is ever needed). Choreography: mirror first, then both her builds, in ONE window —
**the mirror deploy runs only on her explicit go** (CLAUDE.md; the R53 precedent), and the
`/Applications` install refresh is HELD until the deploy lands (a marker-10 client against the
marker-9 mirror refuses to sync by design — never strand her daily drive). The deploy checklist is
§8 below.

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

Also binding whole: the sitting record §1–§25 (every ruling), the §25 tutorial curriculum as
secondary acceptance criteria (no 13i-a act may make a lesson sentence false), SyncSpec in full,
and the hallucination guard (red-on-old by behavioural revert for every bug-class fix).

## §1 THE KICKOFF RULINGS (2026-09-30, at this run's open — recorded verbatim-faithful; the sitting record's addendum points here)

- **R-13ia-1 — TAGS ARE PER-WING**, with her adoption rider: *"per wing tags, but ensure that
  duplication of tag display names is handled properly (if I move something tagged writing to a
  different wing that already has a 'writing' tag, it should probably convert to being that ID)"*.
  So: the tag vocabulary is wing-scoped (uniqueness `(wing_id, path)` over live rows); the
  cross-wing MOVE/COPY doors resolve each carried tag BY PATH in the destination wing — an
  existing live tag with that path adopts the application onto ITS id; a missing path mints.
  ("probably" preserved — the adoption rule is her lean, built as stated; the doors themselves
  are 13i-b/c work, the schema and repair here must support it, and they do by construction.)
- **R-13ia-2 — HOME IS VIRTUAL.** The default wing is the schema's built-in: `wing_id = ''`
  everywhere means Home; NO Home row exists. Undeletable and convergence-proof by construction;
  the existing corpus is in Home with zero row rewrites and zero repush. The `wing` table holds
  only additional wings. (Renaming Home was never ruled; if ever wanted it is a settings nicety,
  not a row rename.)

## §2 SCOPE (sitting record §11/§15) and NON-SCOPE

**13i-a ships:** the client migration (one lockstep bundle, §3), the model/enum recast and its
mechanical sweep across all three targets, the v2 rule-grammar decoder (assembly
behavior-preserving), the daily marker (`profile='daily'`: the mint's stamp + the migration's
one-time stamp of the designated book), the journal-trait setter op, the serializer
classifications, the SyncSpec §7 repairs with convergence suites (§5), the mirror DDL artifact +
deploy checklist (§8), and the canon §7/§12 text amendments.

**13i-a does NOT ship (fenced, each with its owner):** intake/materialization mechanics, Arrivals
faces, the rule-editing grammar faces, the bind/spawn doors, the Pool tuck (all 13i-b); Owned /
Finished / Sealed operations, the door enumeration, the edit-law refusals, the cross-wing
move/copy doors and the tag-adoption execution (13i-c); the Bookcase, shelves UI, glyphs, Welcome
seeding, the classics lesson, starred-absorbs-pins faces, the Collecting pane, the vocabulary
sweep (13i-d); the daily Journal's doors, designation derivation and faces (13i-e). The schema
for ALL of it lands now — that is the bundling rule.

## §3 THE CLIENT MIGRATION — `v1_18_wings_shelves_books` (one migration, marker gate 10)

### New tables

```sql
CREATE TABLE wing (            -- additional wings ONLY; Home is virtual ('')
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  name         TEXT NOT NULL,          -- duplicate names legal (no natural key — no repair class)
  position     TEXT NOT NULL,          -- switcher order; fractional index
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  sync_version INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE shelf (           -- `reading_section` one level up (record §7)
  id           TEXT PRIMARY KEY,
  owner_id     TEXT,
  wing_id      TEXT NOT NULL DEFAULT '',   -- '' = Home
  name         TEXT NOT NULL,              -- duplicate names legal
  glyph        TEXT,                       -- one grapheme, monochrome (record §7); NULL = none
  role         TEXT,                       -- NULL | 'welcome' (the seed marker — the keeper repair's key)
  position     TEXT NOT NULL,              -- strip order (All stacks in strip order, §24)
  created_at   TEXT NOT NULL,
  updated_at   TEXT NOT NULL,
  deleted_at   TEXT,
  sync_version INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_shelf_wing ON shelf(wing_id, position);
```

Both gain the standard outbox triggers. No cascade triggers: deleting a wing/shelf never touches
its contents at the trigger layer (a shelf delete returns books to UNSHELVED by reading the
dangling pointer — §19's ruling; wing-delete semantics are 13i-b/d design, no op ships here).

### New columns (all additive `ALTER TABLE ADD COLUMN`; `''` wing sentinel avoids the NULL-distinct
### index trap and means NO existing row is rewritten)

```sql
ALTER TABLE container    ADD COLUMN wing_id TEXT NOT NULL DEFAULT '';
ALTER TABLE tag          ADD COLUMN wing_id TEXT NOT NULL DEFAULT '';
ALTER TABLE reading_post ADD COLUMN status  TEXT NOT NULL DEFAULT 'member'
                           CHECK (status IN ('member','arrival'));
-- reading's additions ride its REBUILD below:
--   wing_id        TEXT NOT NULL DEFAULT ''
--   shelf_id       TEXT               -- NULL or dangling = UNSHELVED (§19 ruling)
--   shelf_position TEXT               -- NULL = never placed ("my order" appends them, §24)
--   starred        INTEGER NOT NULL DEFAULT 0   -- absorbs pins (§7)
--   owned          INTEGER NOT NULL DEFAULT 0   -- 13i-c's flag, landed now
--   sealed_at      TEXT               -- Sealed = Finished + text immutability; the exact-stamp key (§5)
--   hide_owned     INTEGER            -- NULL = follow the global default (gatherings; §6)
--   intake_seating TEXT CHECK (intake_seating IN ('auto','arrivals') OR intake_seating IS NULL)
--                                     -- the join dial (§4); NULL on gatherings
--   auto_tag_id    TEXT REFERENCES tag(id) ON DELETE SET NULL   -- the outflow (§4)
```

### The reading REBUILD (the one non-additive act)

`reading.kind`'s CHECK must change (`'curated','smart'` → `'book','gathering'`), which SQLite only
does by table rebuild: recreate `reading` with the new CHECK + the new columns above, copy rows
with `kind` mapped (`CASE WHEN kind='smart' THEN 'gathering' ELSE 'book' END`), then recreate its
FOUR triggers (`cascade_reading_tombstone`, `cascade_reading_tombstone_section`, the two outbox
captures), with FK enforcement handled per GRDB's migration discipline (deferred checks).
**The copy fires NO outbox triggers, so the migration EXPLICITLY ENQUEUES every live `reading`
row** (the repairs' explicit-outbox pattern) — without this the mirror never learns the recast
values; `sync_version` is preserved by the copy so CAS keeps working, and both devices running the
same migration converge by ordinary server-wins. The serializer's APPLY must read an absent/NULL
new column as its default (`''` wing, `'member'` status) — old mirror rows predate the columns;
pinned. **Pins owed:** a schema-equivalence pin (fresh store vs migrated store — identical
`sqlite_master` shapes for `reading` incl. triggers), a trigger walk (outbox capture fires on the
rebuilt table; `_sync_applying` suppression intact), tombstone/sync_version preservation, and the
enqueue-all-live-readings assertion.

### Index rebuild (per-wing tags, R-13ia-1)

```sql
DROP INDEX uq_tag_path_live;
CREATE UNIQUE INDEX uq_tag_path_live ON tag(wing_id, path) WHERE deleted_at IS NULL;
```

### Data migrations (inside v1_18; ordinary writes — the outbox captures them, and they first
### push at the deploy window since the engine refuses until the marker reads 10)

1. **The kind recast** rides the rebuild's CASE (above). Quicknotes (today a smart book) becomes a
   gathering by this alone (record §3).
2. **`query_spec` v1 → v2** for rows carrying one (§4 below): each v1 `tags`/`tagsAll` PATH
   resolves to the live tag ID with that path (all Home at migration); an unresolvable path
   becomes a dead term (matches nothing, displays "(deleted tag)" — §19's rule); v1
   `profile`/`entryDate*` terms carry as GRANDFATHERED legacy terms (assembly honors them;
   the 13i-b edit grammar never offers them — #166(d)'s letter holds for new rules).
3. **Pins → starred:** every live reading id in the `shelf_pins` setting gets `starred = 1`; the
   setting key is retired-as-read (left in place — settings are never tombstoned; no reader
   remains).
4. **The daily marker:** the designated daily book (the live `daily_journal_book` setting →
   a live reading with `profile='journal'`) gets `profile='daily'` (the identity memo's edge 1;
   idempotent, same-value CAS-safe on every device). No designation / dangling ⇒ no stamp.
5. **NO wing stamping** — virtual Home (R-13ia-2) means the defaults already say it.

### Model/code recast (same unit, mechanical)

`ReadingKind` becomes `case book = "book", gathering = "gathering"`; every site across
`Sources/`, `App/Variorum/`, `App/Variorum/Shared/`, `VariorumMobile/` and the test targets
follows. Honest test edits (a renamed vocabulary, not a parity refactor) — counts watched, no
assertion weakened. UI strings may keep today's words ("smart book") until 13i-d's sweep; faces
change NOTHING behaviorally this run. `Wing` and `Shelf` record types mint. The daily MINT
(`shelveInDailyJournalBook`'s ensure) writes `profile='daily'`;
`Queries.isDailyJournalMintShape` re-keys to `kind='book' AND profile='daily'` (the ONE pure
function the mint stamps and the repair filters — the no-drift property kept; the name leg and
#85(a)'s renamed corner die). The journal-trait setter op lands (§11's named op:
`setJournalTrait(reading, on:)` — on ⇒ `profile='journal'`, off ⇒ `'book'`; a `'daily'` reading
refuses — its trait is constitutive; flipping never rewrites existing entries — §10). ⌘J and all
designation READERS are untouched (13i-e rewires them; the setting stays truth until then).

## §4 THE v2 RULE GRAMMAR (storage + decoder now; editing faces 13i-b)

`query_spec` keeps its NAME and column; its FORMAT recast rides the marker (a §12
meaning-change, designed here as the spec demands). v2 is a JSON boolean tree: nodes
`{"and":[…]}`, `{"or":[…]}`, `{"not":…}`; leaves `{"tag":"<tag id>"}` (subtree matching by the
tag's live path — §19: rules reference IDs, never paths; `renameTag` can never break a rule),
`{"star":true}`, and the grandfathered legacy leaves `{"profile":…}`, `{"entryDateFrom/To":…}`
(migration-minted only). The decoder + `smartMatchSQL` successor live in `Queries` as pure
functions; **parity pins:** every migrated v1 spec assembles the SAME post set as before
(fixtures across tags/tagsAll/profile/date shapes). A malformed spec keeps today's tolerance.
`assembleReading` additionally gains the `status='member'` filter (an arrival row never renders
as a member, even before 13i-b exists — pinned). Wing scoping of assembly: a gathering assembles
over ITS wing's posts (`c.wing_id = r.wing_id`) — vacuously unchanged today (one wing) and
correct from birth.

## §5 SYNC — the §7 repairs, classifications, and suites (all `Sync/` — Fable)

**Serializer classifications (the PRAGMA completeness walk makes omissions build-failing):**
`wing`: name ENCRYPTED; position/stamps/ids PLAIN. `shelf`: name ENCRYPTED, glyph ENCRYPTED;
role/wing_id/position/stamps PLAIN. `reading` additions: ALL PLAIN (ids, enums, flags, stamps,
positions — content-free). `reading_post.status`, `container.wing_id`, `tag.wing_id`: PLAIN.
`query_spec`: keeps its CURRENT class (verified at build; the v2 format is ids/operators — if it
is ENCRYPTED today it stays so). The E2EE disclosure delta is structure-only (shelf/star/owned
flags and counts), recorded in the §12 entry at the deploy.

**The repairs (each: deterministic, idempotent, explicit outbox rows, a convergence test
asserting the outbox row — SyncSpec §7's standing rules):**

- **R1 — `reading_post` pair dedupe, status-aware (amends the existing pure-duplicate rule):**
  duplicates keep the smaller id; the kept row's `status` resolves to `'member'` if EITHER was
  (a seating outranks the bell); positions CAS as before. Born-tombstoned dismissal rows ride
  ordinary row sync and the same dedupe (tombstone-means-decided, record §4).
- **R2 — OWNED exclusivity (PROVISIONAL shape → QUESTIONS #167):** when live memberships meet
  that an owned book's exclusivity forbids (a note membered in an owned book AND anywhere else),
  the EARLIER-accepted act stands (accepted-beats-unaccepted — a never-accepted row ranks seq 0
  per §3, carrying no authority; then lower `server_seq`); the later conflicting row repairs to
  what its door would have done knowing the truth: a later OWNED-side membership DEMOTES to
  `status='arrival'` (the bell — exactly intake's rule for a membered note, record §6), a later
  plain-side membership beside a standing owned one is TOMBSTONED (the ownership promise
  defended at the door — her round-4 acceptance). Nothing destroyed, nothing silent: both shapes
  leave the visible record their doors would have.
- **R3 — tag path dedupe re-scoped `(wing_id, path)`** (R-13ia-1): keep lexically smaller id,
  re-point applications, tombstone the duplicate — within a wing; identical paths in two wings
  are now legal and untouched.
- **R4 — the daily keeper re-keyed:** candidate iff live, `kind='book'`, `profile='daily'`
  (through the one re-keyed `isDailyJournalMintShape`). Mechanics unchanged (smaller id keeps;
  memberships/chapters re-point BEFORE tombstones; arrival-order independent; designation
  converges). The name-shape interim retires; a RENAMED daily book now converges (#85(a)'s
  corner closes).
- **R5 — the Welcome-shelf keeper:** two `role='welcome'` shelves in one wing (two devices'
  future seeders racing) converge — smaller id keeps, `reading.shelf_id` pointers re-point,
  loser tombstoned. Lands now (schema + repair) so 13i-d's seeder is born convergent.
- **Documented, not repaired:** a dismissal racing a seat on ONE row is tombstones-win (the
  dismissal stands; re-adding is one hand gesture) — a convergence test documents it, per the
  concurrent-divide precedent.

**Harness:** the fake server gains `wing`/`shelf` mirrors + the new columns + marker 10;
`SyncSchema.lockstepVersion` → 10; convergence suites per repair (two in-memory clients), plus
one pristine-copy-dedupe regression run (the classifier must be unperturbed by shelf/starred
metadata — `shelf_id`/`starred` on a READING row are not engagement; asserted).

## §6 ACCEPTANCE UNITS (two; evidence named before the build — the sizing rule)

- **U1 — THE SCHEMA + THE RECAST** (client): §3 + §4 whole. **Evidence:** the migration pins
  (schema equivalence, trigger walk, recast/pins→starred/daily-stamp data pins), the v2 parity
  pins, state-transition suites updated and green, the FULL core + Mac + mobile suites green,
  and a hands-on dev-store walk (the store migrates live; library/books/journal/snippets behave;
  nothing user-visible changed).
- **U2 — SYNC + THE EVENT'S ARTIFACTS** (`Sync/` + `Server/`): §5 whole + the SyncSpec §7/§12
  text + `Server/supabase/13_phase13i_wings.sql` + the deploy checklist. **Evidence:** the
  convergence suites green (every repair's outbox row asserted; idempotence; the documented
  race); the artifact line-read in the ladder. The DEPLOY itself is HER window (§8) — the
  phase's acceptance includes it; if she is away at the ladder's close, the phase HOLDS OPEN
  with the checklist bundled.

Then: ONE `fable-reviewer` ladder over the combined diff (REVIEW_PROMPT verbatim, zero framing;
findings repo-first; the orchestrator arbitrates same-model disputes against the spec; cap
three rounds) → her deploy window → closeout (canon deltas as ruled: AppSpec §7 DDL contract
lines + §6 wing convention + §9's setter line, SyncSpec §7 paragraphs + the §12 entry at the
deploy; the MOBILE PARITY line; the master plan; the handoff).

## §7 ENVIRONMENT TRAPS (binding; the standing invariant core)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store
instances are treated by STORE, never quit/killed; no Release builds or `/Applications` refreshes
while one lives — and THIS run's refresh is additionally HELD for the deploy window (§8).
`xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/` with
suite-level `-only-testing` only, confirming the "Test run with N tests" line (skips counted —
read the `skipped:` lines); zsh `pipestatus`; NEVER a custom build configuration (non-"Debug"
names strip the DEBUG oracles); suites beside a live session flash test windows — prefer
zero-instance windows; backups WAL-safe, UTC names, into `Backups/safety-copies/` (the A1 rail)
before ANY real-store touch; never `git checkout` over uncommitted work; push after every commit;
never force-push. The dev store (`io.lduarte.Variorum.debug`) NEVER syncs (fenced) — sync
evidence is the fake-server suites, never the production mirror. Foreground waits only; poll logs
with `grep -q … && break` loops (the `tail -f` trap). Background-wait = death for subagents.

## §8 THE DEPLOY CHECKLIST (HER WINDOW — mirror → Mac → phone, one sitting; the 13j/13y shape)

1. Zero-instance window; A1 safety copy of the real store into `Backups/safety-copies/`.
2. The mirror: `Server/supabase/13_phase13i_wings.sql` executed (her go — by her hand via `!`, or
   by the architect through the PAT at her word; the 13y read-fix-re-run road on any live error).
   Verify: `sync_schema_version()` = 10; `wing`/`shelf` present, zero rows, RLS forced; the new
   columns live; the grant sweep clean.
3. The Mac: Release build (lockstep 10) → `/Applications` (codesign verified); relaunch runs
   `v1_18`; her first round pushes the recast rows; verify a clean round + the marker handshake.
4. The phone: her Xcode run to device (same build family); its first round converges.
5. Both devices' rounds verified (outbox empty, no repair storms); the §12 running-record entry
   written THEN (the event is recorded when it happened, not before).
   Until the window completes, both installed marker-9 builds would refuse against a marker-10
   mirror — which is why NOTHING deploys before her go, and the install refresh waits.

## §9 PROVISIONALS AND OPEN ITEMS (each logged in QUESTIONS at close)

- **#167 (new):** the R2 owned-exclusivity repair shape (demote-to-arrival / tombstone-the-later —
  spec-derived from record §6's intake rule; hers to re-shape).
- The grandfathered legacy rule terms (§4) — behavior-preserving, recorded; 13i-b's grammar faces
  never offer them.
- `setJournalTrait` refusing on `'daily'` — constitutive-trait reading, PROVISIONAL.
- The `shelf.role` marker + R5 keeper — architect mechanism under the bundling rule (a column
  impossible to add later without a second event), recorded for her awareness.

## §10 LEDGER (every row owned; statuses flip in the same commit as the work)

| # | Item | Status |
|---|---|---|
| 1 | v1_18 migration (tables, columns, rebuild, index, data migrations) | DONE (commit 1 — incl. the explicit enqueue-all-readings; schema pins in MigrationTests) |
| 2 | ReadingKind recast sweep (3 targets + tests) | DONE for core + the sed sweep of App targets (commit 1); the Mac/mobile BUILDS verify next |
| 3 | Wing/Shelf models + records | DONE (commit 1) |
| 4 | v2 grammar decoder + parity pins + the `status='member'` filter | DONE (commit 1 — `Domain/RuleGrammar`; every consumer keeps its v1-letter malformed semantics (fail-closed per site, restored after the first run caught the laundering); the write choke point normalizes v1 drafts, stores undecodable bytes RAW) |
| 5 | Daily marker: mint stamp + migration stamp + predicate re-key | DONE (commit 1 — `dailyJournalBookProfile`='daily' + `journalTraitProfile`='journal' split; the name leg dropped; #85(a)'s corner CLOSED and the keeper pin flipped to say so) |
| 6 | `setJournalTrait` op + pins | OP DONE (commit 1); dedicated pins ride the U1 close |
| 7 | Serializer classifications + completeness walk green | DONE (commit 1 — wing name ENCRYPTED; shelf name+glyph ENCRYPTED; everything else PLAIN; `query_spec` stays ENCRYPTED, its pre-13i class) |
| 8 | Repairs R1–R5 + convergence suites | DONE (U2 commit — `Phase13iRepairTests` 8 convergence tests incl. outbox asserts + the documented coexistence; R2 PROVISIONAL #167) |
| 9 | Fake server marker 10 + mirrors | DONE (registry-derived; marker 10; all suites green against it) |
| 10 | `13_phase13i_wings.sql` + deploy checklist | DONE (the artifact in U1 commit 1 — the DDL pins demanded it beside the registry; the checklist `notes/plans/13i-a-deploy-checklist.md` in the U2 commit) |
| 11 | SyncSpec §7/§12 text amendments | §7 DONE (the U2 commit: per-wing tag identity, status-aware pairs, the built daily-marker keeper + #85(a) closed, the two new repair paragraphs); the §12 running-record entry is written AT the deploy |
| 12 | The ladder (fresh `fable-reviewer`, combined diff) | ROUND 1 DONE (2 BLOCKER · 3 MAJOR · 4 MINOR · 1 NIT — `notes/plans/13ia-ladder-round1.md`, every finding dispositioned); THE FIX SET LANDED with revert-verified pins (the ladder file + the two fix commits; M-2's first pin proven hollow by revert, sharpened, and it then caught ShelfOrder's double-listing — fixed); ROUND 2 RUNNING (fresh reviewer over the fixes) |
| 13 | Her deploy window (§8) | **GO GRANTED (2026-10-01, her message: "i have closed my real store, you can refresh, and you can do the remote sync push and all of that")** — executes AFTER the ladder closes (the checklist's own first gate); the Mac half is the session's, the PHONE's refresh is hers (it will visibly refuse to sync until she installs the marker-10 build — the §12 grammar) |
| 14 | Closeout + handoff | NOT-STARTED |

## LIVE STATUS (the resiliency protocol's record — updated per commit; every unverified claim marked PENDING)

- 2026-09-30 · kickoff: preflight complete (CLAUDE.md + canon, master plan, KnownIssues, QUESTIONS'
  open tail incl. #166, the sitting record whole, the brief, the daily-Journal memo, SyncSpec in
  full, the resiliency protocol; TEXTKIT2_NOTES not required — no editor seam). Her two kickoff
  rulings recorded (§1). This plan authored as the first act. No revert in flight. U1 opens next.
- U1 commit 1: the schema event's CORE whole — v1_18 + recast + v2 grammar + daily re-key +
  classifications + the mirror artifact + marker 10. **Core suite GREEN: 1751 tests / 184 suites.**
  Honest test-edit inventory (a renamed vocabulary + two ruled behavior flips, no assertion
  weakened): the kind sweep across test fixtures; pins flipped TO THE RULED TRUTH — the renamed
  daily Journal CONVERGES (#85(a) closed), deliberate notebooks mint the TRAIT; the pin-list suites
  rewritten to the starred-column semantics (the self-heal became by-construction; restore brings
  the star back — an upgrade the old stored list could not make); the v1-draft expectation pins
  read the NORMALIZED stored value; era-frozen DDL pins (the 13y floor, the superseded overlay)
  subtract the 13i-born tables with the reason at the pin. Next: the Mac + mobile builds/sweeps,
  the trait-setter pins, the dev-store walk — then U1 closes.
- **U1 + U2 CLOSED (2026-10-01).** U2: the repairs + `Phase13iRepairTests` (8) + `JournalTraitTests`
  (3) + SyncSpec §7 text + the deploy checklist. U1's face tail: the rule-editor DRAFT READER
  (`Queries.legacyDraft` — the blank-builder regression caught at the Mac build and closed),
  `Queries.ruleTagPaths` + both shelf faces on the resolved map, the quicknotes mint ensures its
  tag before the rule. **FINALS: core 1762/186 GREEN · Mac 3427/565 green (the 5 standing
  known-issue rows; the two recast pins fixed in-run) · mobile 656/114 = 4 known + the standing
  attributed Jekyll offender (pre-existing, untouched).** THE WALK (dev store, Debug build,
  captures in the session scratchpad `13ia-walk*/`): the store migrated LIVE through v1_18 —
  the shelf renders with starred floating (pins absorbed), both gatherings assemble through v2
  rules with word counts and resolved rule tags, ⌘J minted today's entry into ~/journal (the
  'daily' mint + shelving), the Library lists everything; the debug instance quit cleanly, her
  real instance untouched throughout.
- **HER GO (2026-10-01, mid-run):** real store closed; refresh + the mirror deploy authorized.
  Order held: the LADDER first (the checklist's gate), then the window.
