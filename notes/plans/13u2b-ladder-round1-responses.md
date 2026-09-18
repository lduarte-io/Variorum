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
