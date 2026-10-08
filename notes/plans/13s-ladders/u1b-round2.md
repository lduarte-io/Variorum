# 13s U1b — ladder round 2 (cold review of the round-1 fixes, FABLE reviewer, 2026-10-08)

**Scope (the brief's, verified against the log):** the three fix commits + the flagged
machinery — **63379bca** (MAJOR-1: the star engagement leg, the unit's ONE `Sync/`
change) · **4b272169** (MINOR-1: the classics door's adopted-arm receipt) ·
**92d4da7f** (the ratified in-window fan-order fix + two corrected pin oracles) ·
**27bb407e** (the DEBUG walk gate override, flagged for this seat's judgment). Scope
sweep: `git log eeba3cb0..HEAD` over `Sources/ Tests/` and the U1b App surfaces shows
EXACTLY these four commits plus the parallel ladders' own (U4's 96ac35ee/4a18ce00,
U2-round-2's eea127a7 — none touches a U1b file); the ONLY `Sync/` touch since round 1
is 63379bca (one file, 26 insertions + the one SELECT line). Round 1's record
(`u1b-round1.md`) read whole; anchors re-read at this seat: #186(a) and #186(g)
verbatim (`notes/QUESTIONS.md:2186ff` — both quoted accurately by the fix's comments),
the R-17y-5 letter in the mechanism's header, R-13s-39's fan-order ruling, the
REVIEW_PROMPT. This round re-reviews the fixes, not the unit afresh.

---

## FINDINGS

### NIT-1 · App/Variorum/Variorum/Registry/ShellActions.swift:415–416 · the classics door's HEADER comment still teaches the pre-fix two-voice contract

- The doc comment above `restoreClassicsGathering` ends *"Fire-and-DO; an adopted
  gathering is a refusal (the door changed nothing), a minted one a receipt"* — the
  exact reading 4b272169 retired: the adopted arm now speaks the arranged RECEIPT when
  `arranged.didAnything`. The inline comment at :434–440 says the new rule correctly;
  the header contradicts it one screen up. Same class, same fix commit: the
  disposition's own wording. Doc-accuracy only, no pin owed. Beside it, one wording
  note for the 13s revoice pass (not a separate finding): `alreadyWholeArranged(book:
  name, …)` renders *"“classics” is already whole — …"* for a GATHERING — "whole" is
  the member-completeness word; the constant's enum is marked PROVISIONAL
  13s-revoicable, so the reading rides that fence. Proposed: record-only, or the
  half-sentence updated at the next touch.

### NIT-2 · the fix-pass record's two counting slips (u1b-round1.md FIX DISPOSITIONS + the 63379bca / 92d4da7f commit messages) · claims a re-run contradicts by one

- **"the dedupe suite 19/19"** (the disposition and 63379bca's message): the suite is
  **18 tests in 1 suite** — verified by run at this seat and by `@Test` count (17 at
  round 1 + the one new pin = 18). GREEN, so nothing substantive — but the record's
  number is wrong and canon cites these records.
- **"THREE oracle arms corrected"** (92d4da7f's message): the committed diff carries
  TWO (the rendered-join arm, LaunchFurnitureTests:304; the quoted-name narrowing,
  SampleLibraryWelcomeTests:576ff) — the orchestrator's ~11:40 ratification already
  says "the two corrected pin oracles", correctly. Commit messages are immutable
  (never rewrite history); this record is the correction. Proposed: record-only —
  this entry IS the disposition.

---

## CLEAN BILL (checked specifically at this seat, found solid)

1. **MAJOR-1 is CLOSED — the mechanism traced whole.** Every path to `.foldable` in
   BOTH verdicts passes a star leg: `guideVerdict` reads the union star's two halves
   first (`reading.starred` now in its SELECT, :523/:530, + the list, :531) before any
   other leg; `noteVerdict`'s list leg (:715) sits before all signature building, and
   `noteVerdict` is the ONLY producer of container-grain signatures — it also serves
   every guide MEMBER note (:591), so a starred member engages the whole book copy and
   the family never folds. `StarTarget.Kind` is post|reading only (StarTarget.swift:24)
   — the "a pool cannot be starred" comment is accurate. The gathering grain's
   pre-existing column-vs-`bornStarred` axis is untouched and sufficient at settled
   state (the union write is ONE transaction over both stores —
   Operations+Appearance.swift:298–343 — so a starred reading's column always agrees
   once applied); only batch-split in-flight skew differs, which is #186(g)'s recorded
   class exactly as the fix's comment claims.
2. **The two-client pin re-verified RED-ON-OLD at this seat by behavioural revert:**
   the mechanism file swapped to `63379bca^`'s bytes (the new test kept),
   `herStarKeepsBothCopiesOnEveryGrain` → **3 issues** (all three expects — both
   grains folded the starred copy, both devices), exactly the record's claim; restored
   via `git checkout HEAD --`, `git diff --quiet` clean, re-run GREEN. The pin rides
   the REAL road: real ops `setStarred` on each grain, the fake server, the F2
   converge cadence (arrival batch defers, empty window decides) — never a synthetic
   classifier call — and it exercises the container grain's LIST leg specifically (a
   note's star is list-only) plus the book grain's union write (both halves).
3. **The `Sync/` diff is as narrow as the mechanism allows:** one helper + two
   engagement legs + one SELECT column, all inside `SeededFurnitureClassifier`; the
   engine's pass, occasions, fold executors and every other `Sync/` file untouched.
   `guideVerdict`'s list-half read is the union doctrine's belt (a list-only skewed
   reading still engages), deliberate and cheap — not bloat.
4. **The leg errs toward KEEPING, with one caveat stated honestly:** `starredIDs`
   reads the RAW stored list (`Queries.starredTargets`, AppearanceQueries.swift:328 —
   deliberately NOT liveness-filtered), id-only across kinds, so ghost/dead entries
   err-keep. The one opposite-direction corner — a whole-list decode failure reads
   `?? []` = no stars (the standing star fail-open doctrine) — is unreachable through
   any ops road (only `writeStar` writes the key, canonical JSON both sides of sync),
   and when hypothetically present there is no evidence a star existed; no
   red-on-old pin could ever stage it from ops. Hollow as a finding; recorded as
   reasoning per the guard.
5. **No new exposure opened by the star legs:** no seeder stars anything
   (grep-swept: the birth seeders, the shared sample-library seeders, the guide
   mint); the fresh launch's `'starred'` list is empty, so pristine pairs still fold
   — the suite's fold pins GREEN (18/18 at this seat). The Quicknotes gathering's
   born star is the gathering grain's own `bornStarred` comparison, column-only,
   untouched. The Mac REAL-SEED drift guard now routes through the new legs via
   `noteVerdict`; with a star-free fresh mint it stays foldable by construction — its
   post-fix RUN rides the next stage window with the rest of the Mac suites (already
   the record's stated obligation).
6. **Determinism holds:** the verdict reads SYNCED state only (the setting list +
   the reading column); converged devices compute identical verdicts — the pin's
   third expect (device A's count) proves the deciding side too.
7. **MINOR-1 is CLOSED:** the fix mirrors `restoreSeededBook`'s ruled arm verbatim
   (the same constant, the same `didAnything` guard — ShellActions.swift:433–440 vs
   :484–490); the truly-idle adoption keeps the refusal with the second-press pin's
   world commented to say why. The pin's staging is honest: `launchSeeds` runs
   `seedIfNeeded` + the starred-gathering seeder ONLY — never `arrangeWelcome` — so
   the world is the installed-base never-arranged store round 1 named; red-on-old by
   the old arm's unconditional refusal; the `owned == true` expect proves the
   arrangement really wrote. It runs PENDING the stage window per the fix-pass rules
   (no `xcodebuild test` at this seat) — the ladder's one remaining window obligation,
   named in the round-1 record.
8. **The fan-order fix (92d4da7f) is mechanism-true:** `branchVariant` seats a branch
   at `FractionalIndex.between(source.fanPosition, next)` — immediately AFTER its
   parent (Operations+Variant.swift:314–333, "a branch appears beside its source") —
   so two same-parent mints land in reverse mint order, and `texts.reversed()` is the
   correct inverse leaving the stored fan [original, take 1, take 2] (R-13s-39's
   faithful order). The fans oracle pins the order byte-exact against the seeder's own
   constants in `(fan_position, id)` order, so a regression cannot hide. The corrected
   rendered-join oracle matches `joinRenderedTexts`' actual separator
   (`blockJoinSeparator = "\n\n"`, PostRender.swift:367 — the paragraphs are
   end-trimmed, so no conditional-`"\n"` arm fires); the quoted-name narrowing is
   sound (the bare "classics" is a substring of the legitimately-kept `#classics`
   sentence; the disclosure convention quotes object names). The plan's REVERT STATE
   line flipped to RUNNING in this commit and back to NO REVERT IN FLIGHT after
   (plan line 731) — the protocol followed.
9. **The gate override (27bb407e) — Release-bytes claim and gate honesty JUDGED:**
   the `VARIORUM_SEED_GATE_UNOWNED` check sits entirely inside `#if DEBUG`; Release
   compiles `seedGate = productionSeedGate(fresh)` unconditionally. Said precisely:
   the OVERRIDE is zero Release bytes (the comment's referent — true); the
   `productionSeedGate` extraction itself does re-arrange Release code, but it is
   behavior-identical — the same two closures over the same `fresh`, strong capture
   preserved WITH its stated reason (a nil'd weak reference would read as "no
   account", the unsafe direction). `.unowned` is the PRE-EXISTING dev-store gate
   value (`{false}/{true}`, SampleLibrarySeeder.swift:869) — no new semantics
   invented; a forced seed still marks, so no re-seed loop; unit tests never execute
   `VariorumApp`'s launch closure, so no test contamination. The diagnosis narrative
   (Road 2 by design on a dev store: `belongsToAnAccount` true via the device-bound
   session, `hasSyncedCleanly` never, nothing marked) is coherent with the gate code
   read at this seat. Gate honest; claim honest as referenced.
10. **Suites at the review's end:** whole core **2425 tests in 280 suites + 40 in 6
    GREEN** — the fix pass's claimed finals reproduced at this seat;
    `SeededFurnitureDedupeTests` 18/18 (the count the record should say — NIT-2).
    The tree is clean on every U1b file (the one working-tree edit is the triage
    landing's `TutorialSeeder.swift`, not this unit's).
11. **Discipline:** no attribution trailers on any of the four commits; pathspec
    discipline held (each commit touches only its own surfaces); the custody-slot
    grant covers the one `Sync/` commit as arbitrated; no history rewrites.

---

**VERDICT: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT** — both NITs record-class (a stale
doc half-sentence + two counting slips this record corrects). No new BLOCKER/MAJOR, so
no round 3: **this is the U1b ladder's CLEAN BILL**, with the one standing obligation
unchanged from the record — MINOR-1's Mac pin (`theClassicsDoorSpeaksAReceipt…`) and
the Mac suites' post-fix run ride the next stage window.
