# 17y B-SEED — cold-review ladder ROUND 1 (Fable, 2026-10-05)

**Scope:** `git diff ba76a936..6f4ed4fd` (B-SEED, item (q) — the tutorial-seed trace; commit
`fdcdbbe7` inside the range is the orchestrator's record-only rulings file, reviewed as record
only). Reviewed cold in the worktree `~/dev/variorum-17y` under `notes/REVIEW_PROMPT.md`
verbatim; anchors: the 17y table row item (q), the B-SEED BRIEF, the B-SEED RECORD (map, not
evidence), CLAUDE.md + auto-loaded canon, QUESTIONS #183, the new KnownIssues row. No "Review
foci" section exists in the brief; the brief's FENCES were checked as mandatory items.

**Verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT.** Both NITs are record-only — one is already
dispositioned by the batch's own PROVISIONALs, the other has no realistic red-on-old pin and is
labeled honestly. No fix round is required on this diff unless the orchestrator rules otherwise.

## Findings (severity-ranked)

**[NIT] · App/Variorum/Variorum/Registry/ShellActions.swift:353 and :508 (reached via
TutorialSeeder.swift:324–325) · a user's FIRST press of a tutorial door during the birth seed
is swallowed silently — a new reachable surface for the pre-existing silent-latch return ·**
Evidence (traced): `performBirthSeed` holds the session latch for the whole guide seed (~1.4 s
on the walk's Debug build, the arrange-now road only — a store's true birth or its `pending`
resume); both doors `guard session.beginTutorialDoor() else { return }` with nothing spoken.
Pre-diff the silent return was reachable only by an actual DOUBLE press (13b NIT-6's accepted
shape); post-diff a single genuine press landing in the birth window does nothing and says
nothing — in tension with AppSpec §12 ("a door that did nothing speaks a refusal"), while
R-13r-11 (calm first open) cuts the other way. A red-on-old pin exists in principle (hold the
latch, press the door, expect a spoken refusal — red today). · Proposed fix: NONE this round —
this exact choice is recorded as P-17y-BSEED-4(a) with the alternative (b) (the door waits,
then opens), and QUESTIONS #183(e) carries it to the author in her words; raising it past the
recorded PROVISIONAL would relitigate a dispositioned call. Recorded so the ladder shows cold
review saw the §12 tension.

**[NIT · SPECULATIVE on the trigger] · App/Variorum/Shared/SampleLibrary/SampleLibraryWelcome.swift:359–364
+ TutorialSeeder.swift:334–336 · a `.refused` birth seed followed by a successful arrangement
marks the device `done` — the launch road then never retries the guide ·** Evidence: the hook's
outcome is deliberately discarded ("furniture… answers nothing and must never throw"); if the
one read or the restore throws while `arrange` succeeds, `save("done")` runs and the store
stays guideless with one log line — her reported symptom recreated on an error path, doors the
only road left (and the no-retrofit contract then forbids a later silent add). Mechanism real;
trigger contrived — every failure I can construct that hits the seed also hits the arrangement
(same store, same facade; both fail ⇒ `.failed`, mark stays `pending`, next launch retries),
except a sub-second TOCTOU (e.g. a `tutorial` tag minted by a concurrent sync apply between the
birth seed's read and its restore turn), which self-converges (the corpus that minted the tag
brings her guide). No realistic red-on-old pin without artificial fault injection ⇒ hollow as a
bug finding by the hallucination guard's own standard; recorded honestly as a corner, not a
defect. · Proposed fix: none; record-only.

## Clean bill — load-bearing things specifically checked and found solid

1. **The defect's mechanism, independently re-traced.** `git show ba76a936:App/Variorum/
   Variorum/VariorumApp.swift` (lines 180–250): the old launch path seeds books + starred +
   `arrangeAtLaunch` and never calls `TutorialSeeder`; the only mints were the doors
   (`ShellActions.swift:353`, `:508`). The record's ROAD 1 / ROAD 2 story checks out against
   `AuthSession.swift:116–130` (device-bound session, `WhenUnlockedThisDeviceOnly`) and the
   `SyncGate`/`firstRoundWait` grammar.
2. **`LaunchFurniture.seed` is a faithful move, production behavior unchanged.** Same order
   (books → starred → arrange), same arguments; `firstRoundWait` nil ⇒ the same 20 s default at
   both seeders (`SampleLibrarySeeder.swift:868/919`; `StarredGatheringSeeder.swift:61`); marks
   nil ⇒ the production UserDefaults roads; one gate value vs. per-site construction is
   equivalent (SyncGate holds closures, evaluated at call time). `VariorumApp` now calls this
   one function and nothing else.
3. **The hook's occasion is exactly the ruled one.** `decide` saves `pending` BEFORE returning
   nil (`SampleLibraryWelcome.swift:397`), so a crash inside the guide seed resumes next
   launch; `done`/`declined`/`undecided` never reach `beforeArranging` — never a retrofit
   (pinned; pin re-run by me). The arrangement's existing shelving step (`:249–254`) is what
   puts the guide on Welcome — no new shelving path.
4. **The decision table matches the doors' doctrine.** Live guide → her deletion (tombstone,
   `Queries.readingTombstoneExists`, ReadingAssembly.swift:196 — the seeded books' exact rule)
   → residue → seed; `cleanup` over an empty discovery is a no-op, so the birth seed can never
   delete; residue (her `tutorial`-tagged notes included) is never replaced silently — rv-b.log
   shows her tagged note destroyed when that guard is removed (red-on-old verified in the log).
   The `doorInFlight` path never registers the releasing `defer` (the guard precedes it), so
   the launch cannot steal a door's latch — pinned.
5. **Suites re-run first-hand on the fixed tree** (`DerivedData/17y-review`, zero Variorum
   instances before the run): `LaunchFurnitureTests` **6/6 passed**, `SampleLibraryWelcomeTests`
   **12/12 passed**. Evidence logs verified against the record's claims: `p2-red.log` (birth pin
   RED, exactly 2 issues), `rv-a.log` (2 issues, same pin), `rv-b.log` (8 issues across exactly
   the three guarded pins), `end-seeders.log` ("103 tests in 12 suites passed"), `end-spine.log`
   ("98 tests in 13 suites passed"), `phone-build.log` ("BUILD SUCCEEDED").
6. **The walk's evidence exists and corroborates.** The five captures are on disk (gitignored
   dir); B1 read directly: Welcome holds "the field guide · 41 notes · 10 ch", census 1 book ·
   1 gathering, quicknotes unshelved/starred, the status line silent, dev store. The record's
   NOT-DONE first line is honest (the signed-out road is not walkable on this machine —
   F-BSEED-4; walk B's `pending` staging disclosed).
7. **The fences held.** `git diff ba76a936..6f4ed4fd` touches zero `Sources/VariorumCore/Sync/`,
   custody, schema, mobile or seed-content lines; no new setting, mark or dependency; the one
   Shared change is a defaulted parameter + comments (the phone never calls `arrangeAtLaunch`
   — grepped; `VariorumMobile` builds per the log). The hard-stop rule (a tutorial dedupe
   family would be `Sync/`) was honored by taking the Jekyll precedent instead.
8. **F-BSEED-3's sync story verified structurally.** `Sync/` greps clean of any tutorial /
   field-guide keeper; `Book.dedupeCovered` excludes Jekyll (`SampleLibrarySeeder.swift:586–588`)
   and the guide was never in `allDedupeFacts()` — the two-guides-after-sign-in residual is
   real, correctly classed with Jekyll/starred/classics/quicknote, and properly owned
   (KnownIssues row, owner 13s; QUESTIONS #183(c) tells her before Monday).
9. **The signed-in road's corner (c)** — a corpus with a guide but no Sherlock reads fresh;
   the birth seed finds hers (`alreadyPresent`) and the arrangement adopts it onto Welcome,
   never a second guide — pinned, and the shelving-by-name behavior it rides is pre-existing
   (the old launch already passed `guideName:`).
10. **Doctrine and invariants.** Every write is an operation on the quiet facade — nothing on
    ⌥⌘Z (pinned), no ad-hoc rows, S1/S2 untouched, no view enforcing a rule; P1 clean (the seed
    is constant-size, once, at birth, after first paint); R-13r-11 honored (silent furniture,
    no ask, one log line in the seeders' existing `privacy: .public` outcome pattern); the
    QUESTIONS #183 entries match the built behavior clause by clause; no commit in the range
    carries a forbidden trailer.
11. **The test suite drives the production composition** — F-BSEED-2's structural fix is real:
    `LaunchFurnitureTests` calls the same `LaunchFurniture.seed` the window task calls; the old
    replica (`launchSeeds` in `SampleLibraryWelcomeTests`) survives only as the shared-brain
    pin, its stale defect-describing comment rewritten (comment-only, verified in the diff).

**Round 1 closes with no fix work owed.** The two NITs are recorded above with their
dispositions; both trace to choices the batch's PROVISIONALs already put in the author's hands.
