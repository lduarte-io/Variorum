# 13u2b — LADDER ROUND 2 (fable-reviewer, cold, 2026-09-18)

**Scope:** round 1's fix diff `aecf0b52..39e06428` (fixes `a98ea4aa` · `48b5d80f` · `01272f20` ·
`6a820a03` · `761dcd02`; the close `cce9d3d8`/`39e06428`) and what it touched, per the round-2
anchor state in `notes/plans/13u2b-ladder-round1.md`: `LandingSettle.decide`'s at-top budget
branch and its policy interactions · the router's three carry doors (`takeCarriedFraction` /
`takeCarriedPlace` / `dropCarriedPlace`) and Read's carried seed · the two new pins + the new
truth-table cell · the comment/record amendments. Read cold per `notes/REVIEW_PROMPT.md`;
anchors: the round-1 findings file, the responses file
(`13u2b-ladder-round1-responses.md`), the phase plan (`phase-13u2b-landing-seam.md`).
A REAL pass, not a confirmation: every fix's mechanism re-traced from the code, every pin
checked against what its scope sentence claims, every amended comment checked against what
the code beside it does.

**Verification runs made this round** (zero instances verified first — `pgrep` empty; from
`App/Variorum`, suite-level `-only-testing`): `LandingAuthorityTests` +
`LandingSignpostTests` + `CommandRouterTests` — **15/3 green** · `ModeSwitchCarryTests` +
`ViewportCarryTests` — **14/2 green** (the new first-mount pin among them) ·
`BookOutlineLandingTests` + `ReadingFlowLandingTests` — **17/2 green, zero known issues**.
46 tests / 7 suites, all green on this tree. The full suite was NOT re-run (no fixes made
this round; the fix pass's own end verification — 2794/466, one red = row 58's byte-identical
environment condition — stands as the baseline per the ladder's rules).

---

## FINDINGS

**None.** 0 BLOCKER · 0 MAJOR · 0 MINOR · 0 NIT.

Under the hallucination guard I looked for the mechanism behind every candidate I could
construct against the new code, and each one either traced to a CORRECT outcome or to a
hazard round 1 already adjudicated and recorded. The candidates weighed and dismissed, so
round 3 (or any future reader) does not re-derive them:

1. **`jump(to:)`'s drop sits after an `await`** (`PostDetailView.swift:885-902` — the drop
   runs in the Task's continuation after the DB read). Traced interleaving: a routed mode
   switch landing during the suspension parks a fresh place, which the jump's continuation
   then drops — but the continuation ALSO overrides the mode to `.write`, so the arrival
   that fresh place was parked for is pre-empted and could never honestly consume it. Every
   interleaving lands coherently; the sub-millisecond hand-vs-hand race changes the mode
   (pre-existing jump behaviour), never the correctness of the carry. Not a finding — no
   inputs→wrong-outcome exists.
2. **A stale parked place surviving into a consuming arrival** (the shape MINOR 1 fixed,
   re-hunted on the new code). Exhaustive over the mode-writing roads: `switchMode` and the
   routed `applyMode` re-decide (overwrite/clear); `jump(to:)` drops; the blockless guard is
   provably unreachable with a loaded slot (no blocks ⇒ no capture; note-scoped slot cleared
   on note change — the amended comment's own argument, verified); a same-note detail
   remount's token-guarded no-op unregister can keep a slot loaded, but the remount arrives
   in the REMEMBERED mode, which is the non-participating mode in every shape that leaves a
   slot unconsumed — the consuming arrival cannot be reached. Post-fix, Write's arrival
   spends unconditionally on a postID match, which closed the one reachable door. Sound.
3. **`takeCarriedFraction`/`takeCarriedPlace` leaving the slot on a postID MISMATCH** (only
   a blockID mismatch spends). Traced: the slot can only ever hold the ACTIVE note's place
   (`carryPlaceAcrossModeSwitch` filters by `activePostID`; `registerDetail` clears on note
   change, `unregisterDetail` on teardown), so a postID-mismatched ask means an inline/other
   surface asking about a note whose slot cannot be loaded — and the note-scoped clears
   cover the lifecycle either way. No reachable wrong outcome.
4. **The seed's refused-carry fallback lands the possibly-stale FACT** (carried block not in
   `rows` → spend, fall to `landing`). At that point the carry cannot help (its block is
   unshowable) and the fact road is the pre-existing standing reveal — no better answer
   exists at that decision point. Not a finding.
5. **`decide`'s implicit `minimumHold ≤ timeBudget` invariant** (a hypothetical policy with
   hold > budget would give up at the top before its hold, and the truth-table's "the
   watchdog never overrules a landing that ARRIVED" comment would hold only conditionally).
   Both shipped rows satisfy it by 4× and the policy-table pin
   (`theTwoPoliciesCarryTheSurfacesShippedNumbers`) pins every shipped value; round 1's
   sanity pass already recorded exactly this as an observation-not-a-finding. Re-raising it
   would be manufacturing; noted here only so the adjudication is visible from this round too.

## THE MANDATED CHECKS, EXPLICITLY

**1. `LandingSettle.decide`'s at-top budget branch + policy interactions
(`LandingAuthority.swift:173-197`).** The order inside the branch is `done` → `giveUp` →
`wait`, which is the pre-hoist flow body's order exactly as the fix disposition claims:
`done` wins whenever the landing arrived AND the hold is over AND the veto clears (so the
watchdog never pre-empts an eligible finish — the line-71 truth-table cell); `giveUp` binds
past the budget under a standing veto; strict `>` matches the off-top branch. The Outline's
unreachability re-derived on the general case: its `mayFinish ≡ true` (its landing runner
passes no veto) and `minimumHold 1.0 < timeBudget 4` make the guard's residue
`elapsed < 1.0 ∧ elapsed > 4.0` — empty; byte-identical survives, exactly as promised. The
runner's `.giveUp` path files the signpost (`end=gaveup top=0` — "arrived, never certified"),
which un-silences the stuck case; the perpetual 4 Hz re-arm is bounded at ~budget+one look.

**2. The router's three carry doors + Read's seed.** `takeCarriedFraction`: spends on any
postID-matching ask, matched block or not — one-shot restored to meaning; the one production
caller (`parkCarriedPlacement`) traced, and its lagging-fact consequence (the Write mirror,
slot burned) is honestly recorded as the new KnownIssues row rather than papered over.
`takeCarriedPlace(postID:)`: block-agnostic consume-once, same spend rule — the shape the
UNIT 3 implementer named. `dropCarriedPlace`: no postID filter needed (traced — the slot can
only hold the active note's place, and `jump` runs inside the mounted detail). Read's seed
(`ReadModeView.swift:244-285`): takes the whole place FIRST (a refused carry still spends —
one-shot's letter), filters through `rows.contains` (a carry naming an unshowable block is
refused whole and the standing road runs), prefers the carried block over the router's fact
(#116(b)'s newer-fact doctrine — and the carry can never be older than the fact at seed time,
since `carryPlaceAcrossModeSwitch` overwrites the slot at every switch), and reports ONLY on
a carried landing so the lagging fact heals. **The U3-3 cross-file safety claim verified at
its source:** `CurrentBlockMemory.remember` (`CurrentBlockMemory.swift:65-70`) really does
keep a known offset when a nil-offset report names the SAME block, and in the lagging case
the carried block's offset was never held — the healing report loses nothing in either shape
of the staleness.

**3. The two new pins + the new truth-table cell — does each pin what its scope sentence
claims?**
- **The truth-table cell** (`LandingAuthorityTests.swift:98-107`,
  `top: 0, elapsed: 4.5, mayFinish: false → .giveUp(top: 0)`): red-on-old verified BY
  CONSTRUCTION against the pre-fix code (the minus side of the diff has no budget line in
  the at-top branch — that cell answered `.wait(0.25)`). The corrected "veto or no veto"
  comment now states both cells, truthfully.
- **The router one-shot pin**
  (`CommandRouterTests.theCarrySlotIsOneShotEvenWhenTheFirstAskMismatches`): red-on-old by
  construction (the pre-fix guard cleared only inside a full match, so the
  mismatched-then-matched ask answered 0.4); it also pins the fresh re-decide answering
  exactly once. Pins what it claims.
- **The first-mount carry pin**
  (`ModeSwitchCarryTests.aReadMountWhoseRouterFactWentStaleLandsTheSwitchsCarriedBlock`):
  the staging traced end to end through the real rig — settle the caret's report, verify the
  block flush with Write's top (`wrote ≤ 0.02`), stale the router's fact through its own
  public door, switch with NO settle-wait, assert the seed lands the carried block (and,
  geometry permitting, the fraction). Its scope sentence — it pins the seed's PREFERENCE
  deterministically, not the field's end-to-end timing — is exactly true and lives at the
  pin's own doc; the deciding one-line instrument (the responses file's ask) is kept in the
  pin with its reason. Red-on-old by construction (the pre-fix seed keyed its target off
  `focusedBlock` — the staged stale block). Pins what it claims.

**4. The comment/record amendments — do they state what the code does?** All verified
against the code: the probe registry's corrected doc (LIFO pick + postID filter — what it
discriminates and what it does not); `ViewportCarry.Place`'s amended consume rule ("spent by
the arrival's ask, matched or not" — matches both doors); the seed's U-20 dependency
sentence (verified at `CurrentBlockMemory.remember`); `switchMode`'s excluded-roads comment
with the blockless guard's safety-by-construction argument (each leg checked); `jump(to:)`'s
drop comment; `BookView.swift:1456-1468`'s voice-road comment (the width road one screen up
really does re-land `landingBox.topRow` behind its `previous > 0` mount guard; the voice
road really does only re-stand — the comment now says so and points at #115(b));
the UNIT 2 RECORD's residual-2 amendment (both deltas disclosed, the correction dated and
un-softened); QUESTIONS #115(b) (both guards verbatim — `stand(at:)`'s movement return AND
no landing in flight — with the mount asymmetry's reason and the honest pin-reachability
story); the new KnownIssues row (mechanism accurate against `parkCarriedPlacement`'s code;
owner named — 12, Hardening — per the file's own rule); the plan's ledger row 5 and the
UNIT 1 LIVE STATUS width-change line (qualified exactly as U1-B asked).

## CLEAN BILL (load-bearing things checked and found solid this round)

- **The fix diff's footprint:** every changed line in the five fix commits read; product
  code changes confined to the six files the dispositions name; zero
  `Sources/VariorumCore`, zero `Sync/`, zero `Persistence/`, zero schema; no new doors
  (P-1/P-2 silent); all-@MainActor, no new concurrency surface; P1/P-8 respected
  (`takeCarriedPlace` O(1); `lookup(matching:)` strictly removes the per-ask allocation).
- **`lookup(matching:)` equivalence:** `count == count ∧ zip.allSatisfy(id-equality)` is
  the old `entries.map(\.postID) == postIDs` predicate exactly, minus the allocation; the
  one hot caller adopts it, the two list-holding fetch callers rightly keep `lookup(_:)`.
- **The healing report's blast radius:** `select(report: true)` reaches
  `noteFocusedBlock` → the memory and the observed identity — traced through both staleness
  shapes (guard-dropped report / registerDetail overwrite); in both, the memory's entry for
  the carried block held no offset, so nothing is lost; in the fresh-fact case the report is
  a same-block no-op for the offset by U-20's rule.
- **PIN A/B untouched and green** (the pin file's fix-pass change is purely additive), the
  seven pre-existing flow pins and the unwrapped row-64 gate arm green in this round's runs;
  the two `!contains("gave up")` flow pins green, as the giveUp branch's unreachability on
  the settling road predicts.
- **The recorded-not-fixed calls re-weighed and upheld:** #115(b) (the voice arm — the
  mechanism is real, the guards are the right two, and the honest pin genuinely is
  unreachable without the seven-test helper or the load-flaky generator class; the guard's
  rule forbids fixing blind) and the Write-mirror row (the symmetric fix would split the
  page from the caret against #116(c)'s own trade — product-shaped, correctly parked with
  an owner). Both records say exactly what the code does today.
- **The round-1 record's arithmetic:** +2 tests over the 2792 baseline = the two new @Test
  functions (the third red-on-old is a cell in an existing test) — consistent.

**TALLY: 0 BLOCKER · 0 MAJOR · 0 MINOR · 0 NIT.** No new BLOCKER/MAJOR ⇒ no round 3 is
owed; the ladder CLOSES at this round's end per the standing rules. The row-64 closeout
disposition carries the load-flaky-arm note unchanged, as round 1 instructed.
