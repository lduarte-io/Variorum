# 13u2b Ladder Round 1 — the implementers' responses (verbatim substance, recorded by the orchestrator before the reviewer's final call)

**Tally of responses: 6 findings · 6 AGREE · 0 disputes.** Per the cross-model flow these go to the
reviewer for the final call on each; the reviewer implements confirmed fixes in its own session.
The full response texts arrived as session messages; the substance is recorded here verbatim-
faithfully because session messages are not records.

## UNIT 2's implementer — MAJOR 1 (the at-top branch never consults `timeBudget`)

**AGREE without reservation.** Sharpenings:
- **Provenance:** the hoist flattened the one asymmetry it had to preserve — the pre-hoist Outline
  checked the budget only below its at-top early-return (safe there because `mayFinish ≡ true` on
  that surface), while the pre-hoist flow ran the budget check UNCONDITIONALLY, which is what made
  a VETO safe — and the flow is the only surface with one. Unifying on the Outline's shape deleted
  the flow's only termination path for a vetoed landing. The reviewer's order (`done` → `giveUp` →
  `wait` inside the at-top branch) restores the flow's pre-hoist body exactly.
- **The Outline is provably unaffected** (`minimumHold` 1.0 < budget 4, `mayFinish ≡ true` ⇒ the
  new branch unreachable there) — "byte-identical" survives the fix.
- **The consequence is worse than a silenced signpost:** a perpetual 4 Hz `DispatchWorkItem`
  re-arm that only her scroll, a mode switch, or a fresh landing stops; `isPending` stuck true
  also re-arms on every `contentChanged`.
- **Field-shaped reachability:** `FlowLanding.settled` is fed by `StableSurface.settled` (one size
  held 0.15 s) — a near story above the target whose height keeps moving never announces, so the
  veto can genuinely stay false past 4 s.
- **Two corrections ride the fix:** the truth-table pin's comment (`LandingAuthorityTests.swift:94-98`,
  "veto or no veto…" — its premise holds only when `mayFinish` is true) must be corrected with the
  new cell; and the UNIT 2 RECORD's "residual 2 … the ONE behaviour delta" sentence is wrong — this
  second delta was undisclosed and the sentence must be amended when the fix lands.
- NIT 2 verified not its code (`git diff --name-only 81893e3c^..77f0f09c` — zero `BookViewModel.swift`
  lines); UNIT 1's.

## UNIT 3's implementer — MAJOR 2 · MINOR 1 · NIT 1

**MAJOR 2 (the first-mount carry defect) — AGREE, narrowing the reviewer's SPECULATIVE marker.**
The rig criticism is correct and endorsed: `ModeSwitchCarryTests` settle-waits on
`router.focusedBlock?.blockID == target` before switching (lines 204-206 / 300-302) — a wait
written for determinism that removed the very race her hands run; the stated red-on-old
(`requestMode(.read)` in the SAME turn as `putCaret`) is the right pin. **The two candidate links
cannot both be live, and the observed combination picks one:** both facts are assigned in ONE
synchronous body (`EditorViewModel.updateCaretContext()` 3247-3316 sets `caretBlockID` then calls
`noteFocusedBlock`), so if the click's report never ran, both would be B₁, the take would MATCH and
Read would land B₁ at the carried fraction — not what the walk saw. The walk saw B₁ at the STANDING
anchor, which requires the CAPTURE fresh (B₂) and the SEED's read stale (B₁). **The shipped
asymmetry that produces exactly that pair:** `caretBlockID` is assigned unconditionally while the
router's fact sits behind `noteFocusedBlock`'s `guard activePostID == postID` (CommandRouter:170),
and `registerDetail`'s note-change branch OVERWRITES `focusedBlockIdentity` with the remembered
block — either shape gives capture-fresh/router-stale, and explains the first-mount-only signature
neither reviewer candidate explains alone. **The deciding instrument, one line in the stated rig:**
read `router.focusedBlock?.blockID` immediately before `requestMode(.read)`. **Implementation note
for the fix:** the router exposes only `takeCarriedFraction(postID:blockID:)` (block up front);
seeding on the carried block needs a block-agnostic consume-once peek (`carriedPlace(for:)`), and
the seed must keep filtering through `rows.contains` so a carry naming a block Read cannot show
falls back to the standing road.

**MINOR 1 — AGREE, no reservation.** The chain contradicts its own record's "every switch
re-decides": `takeCarriedFraction` clears only on match; `jump(to:)` sets mode directly (the
re-decide never runs); Write's arrival consumes unconditionally. **Clear on ANY take is the right,
minimal fix** ("one-shot" restored to meaning); `jump(to:)` clearing the slot as it sets mode is
the same rule at the second door if the reviewer wants belt-and-braces.

**NIT 1 — AGREE, and the comment overclaims:** "another window… can never answer for the note this
switch is about" is true only ACROSS notes; same-note-two-windows lets the LIFO pick answer with
the other window's geometry. Whatever else is done, **the comment must be corrected**; the eventual
fix is keying the probe by the detail's registration token.

**Sanity-pass checklist (its own, for after the fixes):** the seed's carried-block preference still
refuses a block absent from `rows`; clear-on-any-take does not break Read's seed-then-land order
(Read takes once at seeding, Write once at the arrival park — neither asks twice); and
`ModeSwitchCarryTests`' two existing pins stay green WITHOUT their settle-wait re-added — that wait
is the thing the new pin exists to remove.

## UNIT 1's implementer — MINOR 2 · NIT 2

**MINOR 2 (the voice road drops her place) — AGREE; an OVERSIGHT, not a decision.** Its comment
("nothing else is needed here") was about the RE-RENDER only. The voice road is the STRONGER case
(re-wrap + line pitch + paragraph gap: 14-pt mono → 16-pt Iowan — every row moves further; #115's
reasoning applies unchanged). **The load-bearing sharpening the trace misses — the two roads are
NOT symmetric at MOUNT:** the width road guards `previous > 0` (the first report is arrival, not
change); the voice road has no analogue, and `tokens` DOES change once at mount on a Study store
(the theme store landing flips the compile-time fallback to her voice). A bare re-land would fire
DURING `landOutlineReveal`'s in-flight landing and override her navigation — turning the fix into
a worse defect on exactly the ascent-into-a-book road. **The guards:** `BookOutlineHeights.stand(at:)`
already returns whether the stamp moved (`restandOutlineHeights()` discards it) — re-land only on
`true`; AND skip while `outlineLanding != nil`. Belt-and-braces (both) is what it would write.
**On the pin:** the landing rig mounts `BookView` without a `ThemeStore`, so reaching the real
`.onChange(of: tokens)` road means touching a helper seven tests share; if the fixer cannot reach
the real road, record it under #115 as an unbuilt arm rather than pinning a DIFFERENT road.

**NIT 2 — AGREE; genuinely unmeasured, severity right.** `FlowExtentsCache.lookup` validates by
`==` on a list every caller must BUILD (O(entries) per call; `outlineSurfaceAnswer` runs per far
expanded row per body pass and per expanded row per manifest build). Two small fixes; **prefer
`matches(_:)` comparing element-wise without allocating** (count + `zip`) — it removes the
allocation for every caller, and the flow is the cache's other reader.

---

# SANITY PASSES over the reviewer's fix diff (`aecf0b52..cce9d3d8`)

## UNIT 3's implementer — NOT CLEAN: three items + one NIT-level note, none blocking, all for the reviewer's final word

**Verified itself (not on trust):** exactly three carry sites as claimed; `EditorViewModel.swift` and
`LandingOffsetTests.swift` untouched by the pass (0 lines — Write's park and its 12 pins
byte-unchanged); `rows.contains` survives and a refused carry still SPENDS before falling back;
PIN A/PIN B untouched (+111/−0 on the pin file) and re-run green; 41 tests / 6 suites green locally;
the capture doors and `carryPlaceAcrossModeSwitch` unchanged (drop is a SECOND clearing door);
one-shot holds under the peek (one slot, first asker spends, one mode branch mounts, the inline
editors excluded by `scrollView != nil`, a dying Write runs no second `.initialRender`); the
instrument re-run answered FRESH.

**Item 1 — the new pin's description overstates.** The pin DOES settle-wait, then stages the
staleness synthetically (`noteFocusedBlock(staleBlockID …)` after the wait) — a legitimate, MORE
deterministic rig, but it pins the seed's PREFERENCE (carry over fact), not the field's timing: if
a future change made the CAPTURE the lagging half, the pin stays green while the wash returns. Owed:
a scope sentence in the round-1 file so nobody reads it as end-to-end coverage of the field race.

**Item 2 — the Write direction's MIRROR is open, and spend-on-any-ask now burns the carry when it
bites.** `parkCarriedPlacement(fact:)` (untouched) asks with `fact.blockID` = the router's observed
identity at `.initialRender`; if the identity lags on a Read → Write switch as it did on
Write → Read, the ask spends the slot AND returns nil — the mirrored wash with the carry silently
consumed. Reachability genuinely lower (Read's `select()` reports synchronously in the body that
moves the selection, ReadModeView:412), but the router's own new doc — "the switch-time capture is
the NEWER fact" — now holds on only one of the two surfaces. Options: record-and-leave (Write's
arrival keying is rows-39/49 + U-20 territory; moving WHERE THE CARET lands is product-shaped and
outside this ladder), or Write asks `takeCarriedPlace(postID:)` and applies the fraction when the
place's block is in the index while leaving the caret's landing exactly as is. **The implementer
leans record-and-leave** — the alternative puts the page and the caret on different blocks in
precisely the case it exists for.

**Item 3 — the seed's `report: carried != nil` is safe for a NON-OBVIOUS reason the record should
state:** it does not lose her caret offset only because `CurrentBlockMemory.remember`'s
nil-means-UNKNOWN rule (17o batch b, U-20) keeps a known offset for the SAME block, and in the
lagging case the new block's offset was never held. Both traced, fine — but the comment explains
the healing, not the offset, and the safety is load-bearing on a rule in a different file. One
sentence owed at the code.

**NIT-level note:** `PostDetailView`'s blockless guard (`.task(id: postID)` → `mode = .write`) is
now the only mode-writing road covered by neither the re-decide nor the drop — harmless (nothing to
carry), but it belongs in the comment that names the excluded roads.

## UNIT 2's implementer — CLEAN, nothing raised

Verified byte-shape not spirit: the restored at-top order IS the pre-hoist flow body (same
predicate, same order, same strict `>`); the Outline's unreachability holds on the exact code and
the GENERAL case (the guard reduces to `elapsed < 1.0 ∧ elapsed > 4.0` — empty for any policy with
`minimumHold ≤ timeBudget`; both shipped rows satisfy by 4×; the invariant being implicit is an
observation, explicitly not a finding, with the policy-table pin covering every shipped value); the
corrected pin comment states both cells truthfully; the amended residual 2 discloses both deltas
without softening; and the signpost FILES on the new give-up road with the right semantics
(`end=gaveup top=0` = "arrived but never certified settled", distinguishable at a glance).
Re-ran 27 tests / 4 suites green including both `!contains("gave up")` pins, as the unreachability
argument predicts. Fix 5/6's cache overload verified additive and exactly equivalent on its
predicate. Scope check: only three of its files moved in the whole pass; BookView / ProseHeightModel
/ BookHeightManifest / ReadingFlowLandingTests 0 lines.

## UNIT 1's implementer — code CLEAN; two RECORD/COMMENT items raised (both one sentence, both originally its own)

**NIT 2's fix VERIFIED CLEAN in depth:** predicate equivalence proven on every state the cache can
hold (fresh/other-set/this-set; "partially loaded" is not a constructible state; the empty-book nil
preserved); BOTH hot roads consume the one changed site (the per-body-pass road via
`outlineSurfaceHeight`'s delegation, the manifest build via `outlineRowInput`); the standing list
form correct where kept (both callers build the list anyway, neither per-pass); the three cost pins
still measure what they claim (`BookOutlineExtentReads` untouched); re-run 36/36 green — and the
manifest build MEASURABLY IMPROVED: 0.675 ms / 0.0017 ms a row against the recorded 1.0–1.2 /
0.0026. One note, not an item: the fix removes the allocation, not the asymptote (comparisons take
the pointer-identity fast path; the code comment is precisely true). **#115(b) verified:** both
guards VERBATIM with the hazard; the wording promises nothing unbuilt. **Scope confirmed:** its
side of the pass is 2 lines in `BookViewModel.swift` + 13 in `ReadingFlowView.swift`, all its other
files 0.

**ITEM A (comment):** `BookView.swift:1456-1461` still ends *"nothing else is needed here"* — now
known false, at the site of the recorded-unbuilt defect, with no pointer to #115(b). The same class
the pass itself fixed for NIT 1. Suggested: the last clause becomes the pointer (the re-land owed
here, recorded unbuilt at #115(b) with its two guards). Comment-only.

**ITEM B (record):** the plan's UNIT 1 LIVE STATUS width-change line states the re-land unqualified
after naming both re-stand roads, so it parses as "the voice road re-lands too" — the one sentence
that can accidentally promise the fix exists, in the record the handoff points at. Suggested:
qualify the re-land to the width road, name (b) unbuilt. Record-only.
