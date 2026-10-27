# VX-502 — ladder round 1 (a fresh `fable-reviewer`, REVIEW_PROMPT verbatim, zero framing; 2026-10-27 ~03:20 MDT)

Diff reviewed: `origin/main...272fdda65` in `~/dev/variorum-vx-502`. Verdict: **0 BLOCKER · 1 MAJOR · 1 MINOR ·
1 NIT**, plus one gating condition the record already carries. The reviewer's findings and clean bill, as given:

## Findings

**[MAJOR] · `Sources/VariorumCore/Operations/Operations+PlaintextExportImport.swift:122–126` · the standing
feature-detect duty is enforced by nothing mechanical — the F6 class regenerates silently at the first future
migration that touches a read table.** Traced degradation: a future migration (say v1_33) that alters any
reader-touched table — e.g. adds a column decoded non-optionally by `Container`/`Tag`/`Variant`, or a new
table/column `plan()`'s SQL names — makes every export written before it pass the subset gate (its applied set is
still a subset) and then throw inside the read (RowDecodingError / "no such column") → `readPlaintextExport`'s
generic catch → `.unreadableCopy`: every pre-v1_33 real export refuses with the generic sentence, exactly the
user-visible class VX-502 exists to end. Nothing goes red: pins 1–2 strike only `grdb_migrations` ROWS of a
current-schema fixture, so the suite stays green through the regression, and the duty lives only as a comment at
the gate — a place the author of a migration never reads. Architectural finding (guards the future; no red-on-old
pin applies — teeth are by construction, the pin-3/RV-A2 shape). Fix shape: ONE standing era-frozen pin beside
pins 1–3 — a store migrated `migrate(upTo:)` the frozen v1_32 identifier (in-repo precedent: `WingsMigrationTests`
upTo v1_17; `Phase13icOutflowTests`; `MCPGrantSchemaTests`), seeded with minimal content by raw SQL (a wing'd
note with a take and a tag, a book with a chaptered member, a scrap), the writer's local-only drop applied
(`SyncSchema.localOnlyTables`), then `PlaintextExportReading.read` must return a plan holding that content. Red
the moment a future migration changes a read table without a feature-detect. Optionally a one-line pointer to
this pin at the head of Migrations.swift. Noted honestly: D-A2 ruled comment-only, so this is additive beyond the
plan's brief — but the plan's own standing duty is exactly what this mechanizes.

**[MINOR] · `App/Variorum/Shared/Protection/ProtectionCopyDoors.swift:469–472` · the preflight's doc overstates
its newer arm.** The doc says "a newer build's refusing in the sibling door's words" — but called on a stable
newer export this function returns `.refused(.unreadableCopy)`, never `newerSchemaRefusal`:
`LibraryClassifier.readPlaintext` answers `.newerSchema` BEFORE telling export from library, so the guard falls
through to `.unreadableCopy`. The `schemaNewer` catch is reachable only when the file gains an unknown identifier
between this function's own two staged reads — the record's F-A2 and the app pin's comment say this correctly;
the function's own doc doesn't. Risk: a later session trusting the doc wires a face expecting
`exportRefused(newerSchemaRefusal)` from this road. Fix: one clause in this doc mirroring the app test's comment.
Doc-only, no pin.

**[NIT] · `Tests/VariorumCoreTests/PlaintextExportImportTests.swift` (`forgetMigrations` helper) · the second
`#expect` (`remaining.count == known.count − identifiers.count`) is implied by the set-equality `#expect` above
it.** Redundant; harmless.

## Gating condition (restated; the record's piece-1 row already carries it)

`PlaintextExportBringInRoadTests` (the flipped preflight pin — NEVER executed, compiled only) and `U2WordsTests`
are stage-gated and PENDING: the round cannot close green until that `xcodebuild test` run lands. Scheduled as
the walk window's test batch (the coordinator's GO order: tests first).

## Clean bill (the reviewer's, condensed headings — the full text is the round's hand-back, in the orchestrator's
session; the load-bearing checks)

The gate is exactly her ratified rule (both pin-3 arms; the rename honest; red-on-old certain by construction AND
quoted). D-A2's verification RE-DONE independently column by column — every touched column born by v1_21; every
non-optional decoded property's column ≤ v1_18; `renderPost(throughLens: nil)` short-circuits past the lens
table; v1_31/v1_32 local-only and dropped. The VX-461 premise checked in-repo (sandbox ON for the Mac app target
both configurations; the cited commits exist; the phone has no export writer — VM-30). The two-stage story
coherent (a stable newer export refuses at the PICK with the ids as detail; the classifier's and the gate's
predicates are now the SAME rule — pre-fix they disagreed, which WAS F6). The dead face deleted whole. Pins green
on the final tree by the reviewer's own run (60/7). Scope and hygiene clean (no Sync/, custody, keychain, schema
or editor-seam line; writes untouched; commits trailer-free).

## THE ARCHITECT'S POSITIONS (the orchestrator, recorded BEFORE the implementer sees the findings — the
cross-model flow now runs: findings to the implementer VERBATIM for agree/dispute; a dispute returns to the
reviewer for the final call; the implementer applies what is confirmed; a fresh round-2 reviewer re-checks)

- **F-1 [MAJOR] — the architect's position: CONFIRM.** The era-frozen pin is the standing duty mechanized (P-7's
  harness discipline); a guard pin, teeth by construction (the pin-3/RV-A2 class), honestly additive beyond
  D-A2's comment-only ruling and ruled IN by the architect. One refinement offered to the implementer: VX-461
  means no content-bearing export predates v1_31, so freezing the era at v1_31's identifier (one era deeper than
  the reviewer's v1_32 shape) is strictly stronger if the migrator supports it cleanly — the implementer picks
  whichever the fixtures support and says why.
- **F-2 [MINOR] — the architect's position: CONFIRM.** Doc-only; the clause as the reviewer words it.
- **F-3 [NIT] — the architect's position: ACCEPT.** The redundant `#expect` deleted.
- **The gating condition — already scheduled** (the walk window's test batch runs before any dev-store act;
  the record's piece-1 row carries it).

*(The implementer's agree/dispute, the confirmed set, and the fixes' hashes and evidence land below WHEN THEY
HAPPEN — nothing in this section below this line exists yet.)*

## ROUND 1 FIXES (open — filled by the implementer's close, verified by the orchestrator)

**The implementer's positions (opus-implementer, unit A's own session, 2026-10-27): ALL THREE AGREED — no dispute.**

- **F-1 [MAJOR] — AGREE.** The mechanism is real and I re-traced it: pins 1–2 strike only `grdb_migrations` ROWS of a
  current-schema file, so a future migration that alters a reader-touched table leaves every one of them green while
  every older real export passes the subset gate and dies inside the read (a "no such column" or a non-optional record
  decode) → `readPlaintextExport`'s generic catch → `.unreadableCopy` — F6's user-visible class back. The comment at
  the gate is read by nobody adding a migration. **The era: `v1_31_protection_record` (the architect's refinement),
  chosen because** (a) it IS the floor — VX-461's fix reached users in the VX-329 merge (0.10), whose schema runs
  through v1_31, and every earlier app-written export is a 0-byte file (D-A2), so a v1_31 file is the oldest real
  export that can exist and the pin guards exactly that; (b) it costs nothing over v1_32 — v1_32 adds one local-only
  table the writer drops, so after the drop a v1_31-era file and a v1_32-era file are physically identical today, and
  the v1_31 file additionally lacks one more `grdb_migrations` row (the gate's subset arm on a physically-old file);
  (c) the migrator supports it cleanly (`migrate(_:upTo:)`, the `MCPGrantSchemaTests`/`WingsMigrationTests`
  precedents). Teeth: a guard pin (the pin-3 class, no red-on-old); a scratch probe — a temporary `v1_33` adding a
  column the reader then names — is to be run uncommitted and recorded below. Also taken from the reviewer's fix
  shape: the optional one-line pointer at the head of `Migrations.swift` (COMMENT-ONLY — said so for the whole-suite
  standing), and the gate's comment pointing at the pin.
- **F-2 [MINOR] — AGREE.** My own F-A2 traced it and the function's doc still said the opposite; a later face wired
  to that doc would expect `exportRefused(newerSchemaRefusal)` from a road that never gives it. The clause as worded.
- **F-3 [NIT] — AGREE.** Given the set-equality `#expect` (and every caller striking known identifiers), the count
  `#expect` adds nothing. Deleted.

**What landed (headless; every claim below run, the Mac suites excepted):**

- `91429974f` — the positions above; the round-1 fixes table opened in unit A's LIVE STATUS.
- `0e14d7bf8` — **F-2**: `ProtectionCopyDoors.readPlaintextExport`'s doc now says a newer export never plans or gets
  the newer words there (the classifier's `.newerSchema` comes first → `.refused(.unreadableCopy)`; the pick,
  `PickedCopy.classify`, refuses it in `LibraryOpenCopy.newerSchemaRefusal`'s words; the `schemaNewer` catch answers
  only a file changing between the function's two staged reads). **F-3**: the redundant count `#expect` deleted.
- `074c73023` — **F-1**: `PlaintextExportImportTests.anExportOfTheOldestExportEraStillReadsWhole` — a file migrated
  `upTo: "v1_31_protection_record"` (`oldestExportEra`, FROZEN), seeded by raw SQL in that era's columns (a wing; a note
  in it with two takes — the chosen and a labeled alternate — and a tag; a book with a chapter, the note membered under
  it; a snippet group with a scrap), `StorePlaintextExport.localOnlyTables` dropped as the writer drops them; asserts the
  file is of the era, then that the plan holds exactly that content and imports (1 note · 1 book · 1 snippet group · 1
  wing). Comment pointers: the head of `Migrations.swift` (three lines above `v1_1`) and the gate's standing-duty
  comment.
- `4f4a98cce` — the R1-c probe announced; then RUN UNCOMMITTED and RESTORED: a temporary `v1_33_probe` (`ALTER TABLE
  container ADD COLUMN probe TEXT NOT NULL DEFAULT ''`) + the reader's notes query naming `probe` → `✘ Test
  anExportOfTheOldestExportEraStillReadsWhole() … Caught error: SQLite error 1: no such column: probe` with pins 1–3 and
  both standing tests ✔ (`✘ Test run with 6 tests in 1 suite failed … with 1 issue`) — the traced degradation, invisible
  to pins 1–2, caught by the era pin. Restored (`git checkout --`, `git diff --exit-code` clean).
- **Evidence on the final tree** (`4f4a98cce`'s code = `074c73023`): `swift build` → `Build complete!` ·
  `--filter PlaintextExportImportTests` → `✔ Test run with 6 tests in 1 suite passed` · the adjacent filter → `✔ Test
  run with 61 tests in 7 suites passed`. Beyond the pin, the doc clause and the deleted expect the round's diff is
  COMMENT-ONLY (the two pointers), so the unit close's whole-suite runs stand.
- **PENDING (the orchestrator's, unchanged):** `PlaintextExportBringInRoadTests` and `U2WordsTests` under a stage
  claim — the gating condition above.
