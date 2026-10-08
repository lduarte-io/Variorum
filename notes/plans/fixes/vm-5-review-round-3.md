# VM-5 — LADDER ROUND 3 (the focused pass over the fix wave)

**Cold reviewer:** Fable, 2026-10-06, zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim over THE WAVE'S DIFF ONLY
(`git diff 9a6aedaa..a055d92b` — six commits: pins `bf6619b4` · MAJOR-2
fix `4341490e` · MINOR-3 `bb912568` · MINOR-4 `43168427` · NIT-5
`45b82b97` · record `a055d92b`). Anchor: the round-2 findings,
dispositions and FIX WAVE record in `vm-5-stability-pass.md`. This is the
ladder's HARD CAP round: anything below that is not fixed is recorded for
the author, never looped on.

**Method.** Every file in the wave's diff read whole in this session plus
the surrounding code the fixes bind into (`ArmedEdit` in full, both
gates, both `storageDidEdit` consume arms, both `fallbackVerdict`s, the
whole `TailCrystallizer`, `BlockRangeIndex.verdict`, both `viewText`s and
`EditorSurfaceStorage.text`, both `desyncRecovery`s, `OrdinaryInputEdit`,
the phone's `finish()` teardown road, the Mac's teardown finalize at
`EditorViewModel.swift:725-775`). Targeted suites re-run on this tree:
Mac `ArmedEditTests` + `MacEditRoutingTests` + `BlockRangeIndexTests` +
`EditorEditRouteTableTests` — `✔ Test run with 63 tests in 4 suites
passed` — and mobile `MobileEditRoutingBindingTests` on the brief's
simulator — `✔ Test run with 7 tests in 1 suite passed`. Red-on-old
verified by mechanism trace (below), including an IN-TREE proof for
MAJOR 2: the shipped pure pin itself asserts `openTail.describes(...)` is
TRUE for the gate-less landing ("the geometry alone cannot tell the two
landings apart"), so the old binding's red is demonstrated live on this
tree, not only quoted.

---

## Findings (severity-ranked)

### NIT R3-1 · `Shared/EditorBrain/EditorEditRouting.swift:187-203` (`ArmedEdit.binds`) · the content read's RANGE SHAPE is correct only for EMPTY approvals, and nothing at the read says so

The read `landedText(NSRange(location: range.location, length:
replacementLength))` names the landed bytes exactly **because `.openTail`'s
approval is always empty** (`BlockRangeIndex.verdict:184-188` requires
`range.length == 0` at the document end), which makes `describes`' location
bound EXACT there (`>= range.location` at :148 plus the empty-range
`<= upperBound == location` at :154 ⇒ the landing starts precisely at
`range.location`, and `delta == replacementLength` pins its extent). For a
NON-empty approval, `describes` deliberately admits landings starting
strictly INSIDE the range (:152-153), so a future content-semantic verdict
that reused this read shape would read bytes at the approval's start while
the edit landed deeper in — misaligned, silently. The switch's own doc
("a new armable verdict must decide here whether its meaning is content")
forces the DECISION but not the read-shape caveat. Mechanism traced; no
current behavior is wrong — every present case is correct, which is why
this is a NIT and unpinnable (no failing-on-old test exists; the hazard is
a future author's). Fix: one doc line at the read ("this range names the
landed bytes only because an `.openTail` approval is empty — a content
check for a non-empty approval must derive its own range from
`editedRange`").

### NIT R3-2 · `Shared/EditorBrain/TailCrystallizer.swift:352-356` + `MobileEditorViewModel.swift:1847-1855` / `EditorViewModel.swift:1278-1286` · after a refused attachment inside the `.tail` consume arm, the host method keeps running against bookkeeping the recovery just declared untrustworthy

Traced, on the unreachable-today road only: `storageDidEdit`'s `.tail` arm
calls `crystallizeIfNeeded()`, which on a refused attachment runs
`desyncRecovery()` (disarm, bulk cleared, `forceFullRender`, async heal)
and returns — but the CALLER cannot see that, so `armTailIdleMint()` and
the method's tail (markdown restyle, `auditIdentityProjection()`, chrome
refresh) still run against the stale index. Consequences, each traced
benign: the idle clock re-arms at 2 s while the heal lands in ms and the
tick's own guards re-check the healed index; the DEBUG audit may count one
extra failure; the chrome pass redraws once over a surface the re-render
then replaces. Contrast: the four storage-edit mutators' refusals `return`
immediately (`:1836-1839` etc.). The band's four other exits have the same
shape, so this is a pre-existing structural property the wave EXTENDED
rather than introduced, on a road both callers' guards make unreachable
today (the wave's own record says so and I verified the guards). No pin
could go red on it — recorded as cleanliness for whoever next touches the
band, not for a loop.

**Nothing above NIT.** No BLOCKER, no MAJOR, no MINOR. The two NITs are
recorded for the author per the hard-cap rule; neither warrants a round 4.

---

## The brief's five hunt targets, each answered

**1. `ArmedEdit.binds` — adversarial question ONE (a legitimate non-"\n"
tail-opening landing?): NO SUCH LANDING EXISTS, by three independent
locks.** (a) The gate arms `.openTail` only when the proposed replacement
is EXACTLY `"\n"` — phone `replacement == "\n"`
(`MobileEditorViewModel.swift:1538`), Mac `replacement == "\n" &&
!softNewline` (`EditorViewModel.swift:1057`) — so a paste ending in a
newline ("abc\n"), an autocorrect commit ("x\n"), a dictation chunk, and
CRLF ("\r\n", 2 UTF-16 units) all fail `replacementIsSingleNewline` and
route `.block(last)` by containment (the verdict's entry loop takes
`upperBound`-inclusive location at the document end) — UNCHANGED by this
fix, since `binds` only adds a check to `.openTail` armings. (b) The
verdict itself (`BlockRangeIndex.swift:184-188`) requires an empty range
at the exact document end, so the approval is always `{docEnd, 0}` with
`replacementLength == 1`, and `describes` then pins any binding landing to
a one-unit insert at exactly `docEnd` — the read range IS the landed byte.
(c) `fallbackVerdict` on both platforms passes
`replacementIsSingleNewline: false`, so `.openTail` is unreachable except
through a bound arming. Therefore the only input `binds` newly declines is
a one-unit gate-less insert of a non-newline at the document end after an
armed-but-unlanded `"\n"` — the E1 mismatch class, which is exactly the
bug; and `.block(last)` is the TRUE routing for it (the character joined
the last block; the mobile pin's store assertion proves the autosave now
carries it). The fix traded nothing: no commoner misroute was created.

**Adversarial question TWO (are `.block`/`.tail`/`.closeTail` content-
semantic?): NO, each verified.** `.block` and `.tail`: any landed bytes in
the bound region are that region's content by I4 (internal newlines are
content; the autosave reads the real surface text, the bookkeeping applies
the report's own delta). `.closeTail` is geometry-UNIQUE, not merely
content-benign: its verdict requires an EMPTY tail
(`BlockRangeIndex.swift:191-193`), so the document ends one unit past the
separator and the ONLY possible net−1 edit starting at the separator
offset (which `describes`' bounds force) is the deletion of that one
separator — no replacement shape fits inside the document. The documented
extent residue for non-empty approvals (`describes`' own doc, :122-133)
persists for `.block`/`.tail` — pre-existing, documented at the code,
outside this wave's scope, and nothing observed produces it.

**2. The Mac consumer change: COHERENT AND COMPLETE.** Both consume sites
now bind through `binds` with their own `viewText` (Mac
`EditorViewModel.swift:1234-1239`, phone
`MobileEditorViewModel.swift:1800-1805`); grep proves NO production
consumer of `describes` remains anywhere (tests + the `binds` wrapper
only), so nothing Mac-side was left behind. The Mac's input paths cannot
produce a legitimate declined landing: `OrdinaryInputEdit.apply` is the
ONE arm+mutate door (gate and `replaceCharacters` inseparable, with a grep
pin against a second `shouldChangeText` call site), the soft-newline ⇧⏎
never arms `.openTail` (the `!softNewline` withhold), and
`typedNewlineWouldOpenTail()` (:1696, the `replacementIsSingleNewline:
true` call site) is a READ-ONLY predicate that parks nothing. The Mac's
`viewText` counts `surfaceTextReads` — the new read costs one O(1) counted
read per tail-opening keystroke only (the switch pays nothing on `.block`/
`.tail` keystrokes); no exact-count pin broke (63/4 green).

**3. MINOR 4's refusal roads: EVERY call site handled, and desyncRecovery
is the right road in both.** Grep sweep: the two mutators have exactly two
production callers — `attachLeadingTailRunIfNeeded:314` and
`finishMint:500`, both guarded; the host doors are one-line forwards on
both view models returning the index's Bool (no `@discardableResult`
anywhere in the chain, so a future ignoring caller is warned);
`recoverFromRefusedIndexMutation` = `desyncRecovery()` on both platforms,
and desyncRecovery disarms, clears bulk, flushes and re-ingests from the
store — strictly stronger than any partial cleanup. The crystallizer's
stop-before-plan arm is RIGHT: planning over bookkeeping the index
declined would mint blocks from a tail the index does not describe;
stopping and re-rendering from store truth lets the next edit replan over
healed state. Critical ordering verified: `finishMint` sets `mintInFlight
= false` at its FIRST line (:422), so the refused-crystallize road cannot
wedge the flight; its refusal arm settles (`applyPendingIfClean`) per the
protocol's every-exit contract; the refused-attachment road's missing
settle is subsumed by desyncRecovery's own re-ingest (NIT R3-2 records the
caller-visibility residue). The contract pins are honestly labeled
not-red-on-old, matching the disposition's doctrine-class acceptance.

**4. MINOR 3's disarm placement: CORRECT, and the arming/bulk split is
COHERENT.** The disarm sits after the transfer succeeds, before the
attribute stamp and the ledger/autosave records — all synchronous on the
main actor with no reentry window (both platforms' storage delegates guard
`.editedCharacters`, so the attribute-only `setBlockID` cannot re-enter
`storageDidEdit`; placing the disarm before the transfer would change
nothing, since the refusal road's desyncRecovery also nils the arming). No
LIVE legitimate arming can meet the attachment: the gate→landing pair is
synchronous within one input event; the consume road reaches the
attachment only after `pendingEdit = nil`; `finishMint` disarms before its
re-run; so only a STALE (armed-never-landed) verdict can be live at the
idle tick or teardown — and a stale arming is precisely what must not
survive an equal-length tiling move `describes`' length oracle cannot see.
Keeping the bulk intent is right: `bulkPending` is read by the PLAN
immediately after the attachment in `crystallizeIfNeeded`, and a paste
that parked it described text still sitting in the tail — the tiling move
did not consume it. The two deliberate keep-sites are named at their lines
(the NIT-4 doctrine), and the DECLINED-arming path still drops it
(`bulkPending = false` at both consume sites).

**5. The pins are REAL.** (a) MAJOR 2 mobile: I traced pre-fix `describes`
over the pin's drive — docLength 5==5, delta 1 == 1−0, location 5 ≥ 5 ∧
≤ 5 — forcing the bind, `index.openTail()`, and (the `.openTail` consume
arm records no autosave) a store stuck at "Alpha": the quoted red (tail 0 ·
block [5] · audit 1 · stored "Alpha") is what the code COMPELS, and the
shipped pure pin proves the describes-passes half live on this tree. The
Mac twin is the same binding line for line; its quoted red matches the
same mechanism. (b) MINOR 3: I re-derived the pin's geometry by hand —
pre-attachment entries [5]/sep 5/tail 9 over "Alpha\n\n\none\ntwo"; the
run-2 transfer gives entries [7]/tail 7; the stale `{6,1}` `.tail` arming
then binds the gate-less deletion (equal docLength — the invisible move),
`applyTailEdit(−1)` → tail 6 with entries [7] and "o" at the separator
offset — exactly the quoted red (block [7] · tail 6 · audit 1); post-fix
fallback containment puts `{6,1}` inside entry 0's range → `.block(0)` →
entries [6]/tail 7, the green's exact numbers. Every pin precondition is
itself asserted (mint in flight, the mint's seal-failure, the attachment's
move with bytes unmoved), and the chain is production roads only (the
seal reaches the store un-ingested — the busy-deferral shape; the failure
arm neither disarms nor attaches — verified at
`crystallizeIfNeeded:383-387`). (c) The MINOR 4 contract pins and the NIT
5 guard pin are labeled exactly what they are (not red-on-old; green both
sides respectively) — the hallucination guard honored by name. (d) No pin
is green-over-nothing: each binds a `let` result or asserts counters/store
state.

---

## Clean bill (checked, found solid)

- **The `binds` switch is exhaustive with the right partition**: `.openTail`
  pays the one content read; `.block`/`.tail`/`.closeTail` are geometry-
  safe (traced above); `.refuse` is never armed (both gates nil the arming
  on every refuse arm — verified at `MobileEditorViewModel.swift:1551-1593`,
  `EditorViewModel.swift:1086-1111`), and if a future gate armed one, the
  consume switch's `.refuse` arm takes the honest recovery anyway.
- **`landedText` is total**: `EditorSurfaceStorage.text` returns `""` for
  nil storage or an out-of-bounds range, which DECLINES the arming (""
  ≠ "\n") — fail-safe, never a throw; and for every reachable `.openTail`
  bind the read range is exactly in post-edit bounds
  (`docEnd + replacementLength == post-edit length`).
- **`describes` itself is byte-unchanged** and its nine unit pins ride
  unmodified; the new doc split (geometry half / binding) matches the code.
- **The band header's law is now TRUE of all six mutators**; the two new
  refusals mirror the four's folds (overflow on transfer, negative-length
  on crystallize), refuse-mutating-nothing is pinned, and the ordinary
  transfer's byte/total-neutrality is asserted in the same pin.
- **The host protocol's docs match the wiring**: `disarmPendingEdit` names
  both band callers and the arming-only scope (both implementations are
  `pendingEdit = nil` inside desyncRecovery-adjacent state, bulk intent
  untouched); `recoverFromRefusedIndexMutation` names its two callers and
  the shared road.
- **The teardown roads survive the Bool threading**: the phone's
  `finish()` attach-only pass and the Mac's quit-path finalize
  (`EditorViewModel.swift:762` → the shared `finishMint`) both route any
  refusal through the same recovery, and the Mac's post-finalize
  `flushNow` still lands the attachment's record inside the awaited task.
- **The NIT 5 comment is accurate where it matters**: `diagnose`'s one
  production caller holds no replacement; the guard pin walks every
  inter-entry separator (texted/empty-run/fanned edges, tail open,
  excluding the tail separator — which `interEntrySeparatorPair`
  deliberately never answers) across BOTH declared arm lists; and the
  comment's do-not-just-pass-the-fact instruction matches the trace
  (`.surfaceNotSettled`'s retry sentence is false for a type-over; a
  truthful new sentence is author copy).
- **Fences held**: the diff is exactly 4 `Shared/EditorBrain/` files, the
  two view models, 4 test files and the record — zero
  `Sources/VariorumCore/`, zero `Sync/`, zero schema, no build config; no
  commit carries a trailer (the 2026-09-04 rule checked on all six).
- **Suites re-derived on this tree**: Mac targeted 63/4 green; mobile
  binding 7/1 green — both matching the record's quoted lines; the wave
  record's remaining counts (mobile full 802/126 with the 4 standing known
  issues, Mac editor-brain 268/24 + 91/14, core 2204/247 + 40/6) are
  consistent with the given facts and the two runs I reproduced.
- **MAJOR 1 (VM-2) correctly untouched** per her ruling, and the record
  states it first; M27 stays dissolved — nothing in this wave re-enters
  the divide settle window.

**Verdict: the wave stands.** Both NITs are recorded for the author under
the hard-cap rule; neither needs a fix round.

---

## DISPOSITIONS (orchestrator — the hard-cap round; nothing loops)

| finding | disposition |
|---|---|
| NIT R3-1 (the binds read's shape is safe only for empty approvals) | **DOC LINE LANDED post-cap at the reviewer's own wording** (a comment, not a loop — no behavior, no pin) |
| NIT R3-2 (post-refusal tail-of-band executes against a recovering index; every consequence traced benign, road unreachable) | **RECORDED for the author** per the cap — the cleanliness shape rides the band's next deliberate touch |

THE LADDER CLOSES: round 1 (resolution) 0B/0M all fixed · round 2 (stability) M27 dissolved, 1 MAJOR fixed + VM-2 measured-and-held · round 3 (cap) 0B/0M/0m. The whole-round pass remains (a round-2 commitment, not a ladder round).
