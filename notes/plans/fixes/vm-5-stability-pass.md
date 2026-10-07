# VM-5 — THE DEDICATED STABILITY PASS (batch 4.5's exit condition)

**Cold reviewer:** Fable, 2026-10-06, zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim under the pass's own brief (the
2026-08-22 review row, `mobile-round-2-orchestrator-handoff.md` §3): the
crash class and the editor's range/identity math only — adversarial, the
FIX reviewed, not the features. Target: `App/Variorum/Shared/EditorBrain/`
whole as it survives 13u1/18m on the merged tree
(`vm-5-the-catch-up-merge`), both platforms' storage-edit consumers, the
phone's liveness seam. **It owns M27** — verdict below, measured.

**Method note.** Three measurement probes were run in a SCRATCH test file
(`ZZVM5ReviewScratchProbes.swift`, suite `VM5StabilityReviewProbes`),
*[removed for publication]*
then deleted — `git status` clean after. Probe outputs are quoted at the
findings; each asserts CURRENT behaviour to measure it (a finding's pin is
the inverted, red-on-old form). The round's own §46 correction — a
mechanism traced by reading and never executed is the error class — is why
the probes ran at all.

**Baseline re-derived** (targeted, by struct name — the two-suites-per-file
trap honored): `MobileEditRoutingCrashTests` + `MobileStructuralTests` = 21
tests / 2 suites green; `MobileEditRoutingBindingTests` +
`MobileIdentityAuditSeparatorTests` + `MobileBulkArmingTests` = 13 tests /
3 suites green. The merge diff vs main `dd7cad84` re-derived as confined to
`App/Variorum/VariorumMobile/**` + `notes/**` — so `Shared/EditorBrain/` is
main's 13u/18m-laddered code byte-identical, and the core-suite context
facts stand by scope.

---

## M27 — REQUIRED VERDICT: **DISSOLVED on the merged tree** (measured, not only traced)

*M27 (§46, 2026-08-22, pre-batch-4 tree): the first typed edit after a
DIVIDE was unroutable and took `desyncRecovery` — divide only; not delete,
not a plain refresh. The record carries the symptom only; no mechanism was
ever traced.*

**Probe 1** drove the real door on the merged tree: a 2-block note
(`"Alpha beta. Gamma delta."` / `"Second block prose."`), `loadOnce`, then
`structural.divide(atSurfaceCaret: 12)` awaited, then the FIRST typed edits
— into the minted successor, then the surviving first half. Measured:

```
VM5-PROBE1 desync=0 audit=0 fullRenders=2
VM5-PROBE1 stored=["Alpha beta.Y", "Gamma delta.X", "Second block prose."]
```

`desyncRecoveryCount == 0`, `identityAuditFailures == 0`, both edits routed,
armed, consumed, and flushed into the CORRECT variants. No desync road ran.

**Why the architecture dissolved it (the trace):** `runDivide`
(`MobileStructural.swift:187-207`) settles through ONE awaited road —
`refreshTakesFromStore` → `ingest` → `EditorProjectionPolicy.decide`
(loaded, not busy, non-delivery, sequence changed → `.fullRender`) →
`renderFull` (`MobileEditorViewModel.swift:796-836`), which rebuilds
storage + index in one suppressed transaction AND structurally disarms the
pending verdict (`:821`). All four index-replacing doors disarm
(`renderFull` :821 · `applyDifferential` :862 · `displaySlot` :1474 ·
`finishMint` via `disarmPendingEdit`, `TailCrystallizer.swift:450`), and
the consume-time `ArmedEdit.describes` binding rejects any survivor — so
whatever the pre-batch-4 mechanism was, the post-divide first edit now
meets a coherent tiling and a disarmed gate, and no road through the shared
brain reproduces the symptom.

**Honest caveat:** the headless harness cannot exercise UIKit's caret
machinery around `runDivide`'s `selectedRange` write; if the original repro
was UIKit-input-path-specific, her device walk remains the final word. But
the recorded symptom required the ROUTING to fail, and the routing is what
the probe drove end to end. **Note also:** M27's neighborhood does hold a
real surviving defect — typing DURING the divide's settle window (MAJOR 1
below) — which is store-level, not routing-level: it is not M27, and it
does not resurrect it.

---

## Findings (severity-ranked)

### MAJOR 1 · `MobileStructural.swift:82-207` (divide; same shape at merge :211+, extract/make-block :357+, insertBlockBelow :518+) + `MobileEditorViewModel.swift:1492-1534` (the gate) · the phone's structural flights never fence typing, so the settle window takes a stale whole-block autosave — the Mac's own named "forbidden text-duplication class"

**Evidence (measured, probe 2).** The window's exact state was
constructed: divide committed in the store, surface + index still
pre-divide (precisely the state inside `runDivide`'s awaits — the
pre-commit flush window between `flushPendingText` and the op commit has
the same shape). One keystroke at the end of block A, then the flush:

```
VM5-PROBE2 stored after window keystroke: ["Alpha beta. Gamma delta.X", "Gamma delta."]
```

The keystroke routed `.block(0)` against the pre-divide index (routable —
no desync), `recordAutosave` read the WHOLE pre-divide surface text, and
`AutosaveCoordinator.flushNow` (`Shared/AutosaveCoordinator.swift:142-174`,
no compare-and-set — `ops.autosave` writes unconditionally) resurrected the
moved half into A's variant while C holds it too: **the divide is visibly
undone for A and the second half reads twice.** The merge twin is worse in
kind: a window keystroke's autosave lands in a RELEASED source's variant —
typed prose silently leaves the note (reachable only through lineage/tray).

**The Mac fences exactly this, and names it**
(`EditorSurfaceController.swift:2900-2945`, `runStructural`): *"the view is
non-editable for the few-ms flight so no keystroke can slip between the
flush and the operation (a stale whole-buffer autosave after a divide would
resurrect the moved half — the forbidden text-duplication class)"* — plus
18c R1-2's `beginDeferringKeystrokes` so the keys are deferred, never
dropped. The phone's `holdsTailForStructuralFlight: false` declaration
(`MobileEditorViewModel.swift:2245`) is justified in its doc ONLY for the
mint-duplication hazard ("its structural doors settle through ingest → the
projection policy") — the projection policy defers RENDERS; it cannot stop
the stale autosave. `structuralInFlight` on the phone gates only the other
structural doors; the gate (`shouldChangeText`) never consults it and the
view stays editable for the whole flight.

**Reachability:** the extract/make-block doors run from the selection edit
menu with the keyboard up (`MobileEditMenuSeam.swift:78-82`); divide/merge
run from the ⋯ sheet, where autocorrect/marked-text commits can land in the
window (the divide door has no marked-text bail — only the idle mint
does). The Mac judged the same few-ms window worth a hard fence.

**Pin (red on this tree):** probe 2 inverted — drive a keystroke in the
window (deterministically: op committed directly, surface pre-divide, the
production-window state), flush, and assert the store holds
`["Alpha beta.", "Gamma delta."]` with the keystroke refused-and-spoken or
deferred-and-replayed. Fails today with the duplicated half.

**Fix sketch:** the Mac's shape adapted — stand the surface down for the
flight (gate belt on `structural.structuralInFlight` speaking the existing
"Another structural change is still landing." + `isEditable` off across the
window), or defer-and-replay if the phone wants the Mac's R1-2 niceness.
The minimum correct fix is the gate belt: refuse-and-speak beats a silent
clobber.

### MAJOR 2 · `Shared/EditorBrain/EditorEditRouting.swift:137-152` (`ArmedEdit.describes`) + `MobileEditorViewModel.swift:1852-1858` (the `.openTail` consume arm) · the binding polices geometry and net change but never CONTENT — and `.openTail` is content-semantic: a stale "\n" arming binds a gate-less non-newline insert and corrupts the tiling

**Evidence (measured, probe 3).** One-block note `"Alpha"`, no tail. The
gate approves a typed `"\n"` at `{5,0}` — arms `.openTail`
(`shouldChangeText` returns true). The newline never lands (the
armed-but-never-landed class `ArmedEdit`'s own doc names; E1 PROVED
consult/perform mismatches occur on her hardware in ordinary use). The next
storage report is a gate-less 1-char insert of `"x"` at the same spot (the
suite's own `systemPathEdit` shape — autocorrect / dictation / marked-text
commit). `describes` passes all three oracles (docLength 5==5; delta 1 ==
1−0; empty-range inclusive location bound) → the arming BINDS → verdict
`.openTail` → `index.openTail()`:

```
VM5-PROBE3 tailLength=Optional(0) audit=1 desync=0
```

**The tiling is now corrupted:** the index says position 5 is a separator
with an empty tail behind it; the storage holds a visible character `"x"`
there. The DEBUG separator audit (`IdentityProjectionAudit.swift:101-111`,
M15 Q2's check) caught it — `identityAuditFailures == 1` — but **the audit
is `#if DEBUG`: Release neither detects nor heals.** In Release the "x" is
stranded — unowned, never autosaved (the ledger's text for the block stays
`"Alpha"`, so the next projection reads as a matching echo) — and silently
DROPPED at the next full render: one character of her prose, gone with no
sentence. Until then the model's and the store's tiling disagree with the
visible surface. `.closeTail`'s content-sensitivity is benign (while the
arming is fresh, the character at its offset IS the separator);
`.block`/`.tail` are content-agnostic — the hole is exactly `.openTail`.

**Reachability, honest:** needs the consulted-"\n"/performed-other pairing
as consecutive gate/report events. E1 proved the mismatch CLASS fires in
ordinary use ("iOS consulted the delegate about one edit and performed
another"); this exact content pairing is unobserved. The guard costs one
character read at consume.

**Pin (red on this tree):** probe 3 inverted — same drive; after the fix
the report must route via `fallbackVerdict` to `.block(0)` (`"Alphax"`,
`tailLength == nil`, `identityAuditFailures == 0`). Fails today
(`tailLength == 0`, audit fires).

**Fix sketch:** at consume, an armed `.openTail` additionally verifies the
landed byte (`viewText(editedRange) == "\n"` — or carry the approved
replacement's first scalar in `ArmedEdit` and compare); on mismatch decline
the arming and fall through to `fallbackVerdict`, which already answers
`.block(last)` correctly for this input.

### MINOR 3 · `Shared/EditorBrain/TailCrystallizer.swift:280-302` (`attachLeadingTailRunIfNeeded`) · the one index-CHANGING door that does not disarm the pending edit — outside the fix's own "clear the arming wherever the index is replaced" doctrine

The attachment grows the last entry over the tail's leading newline run and
shrinks the tail — **documentLength unchanged**, so `describes`' length
oracle cannot see the move (the doctrine's stated reason at `displaySlot`,
`MobileEditorViewModel.swift:1467-1474`: an equal-length tiling move is
invisible to the consume-time guard). A stale armed-never-landed `.tail`
verdict whose range sat in the transferred run can bind the next matching
gate-less edit there and route `applyTailEdit` for characters that now
belong to the last entry. The chain is long (stale arming + an idle-mint
attachment turn — the 2 s debounce makes it a genuinely separate main-actor
turn — + a matching gate-less edit), so the harm half is labeled
**SPECULATIVE**; the doctrine inconsistency is concrete: `renderFull`,
`applyDifferential`, `displaySlot` and `finishMint` all disarm; this door
is the odd one out, with no explanation at the line. Fix: one
`host.disarmPendingEdit()` in the attachment. Pin: arm `.tail` on a
newline-led tail, fire `idleMintTail`'s attachment, drive a gate-less edit
in the old run, assert fallback routing.

### MINOR 4 · `Shared/EditorBrain/BlockRangeIndex.swift:558-564, 572-584` · two mutators still `precondition`-trap while the band's header says THE MUTATORS REFUSE

The :492-522 comment converts exactly four mutators to refuse-not-trap;
`transferTailPrefixToLastEntry` and `crystallize` keep Release-surviving
traps — the exact family her two 2026-08-20 crash logs recorded. **No
red-on-old pin exists today** (traced: both callers guard every
precondition — the attachment guards tail-open/entries/run>0 with
`text`↔`tailLength` in lockstep by construction; `finishMint` guards
`tailRange` + non-empty `applied`, and the window between guard and call is
synchronous, with `replaceTailRegion`'s desync arm returning control
without closing the tail) — so by the hallucination guard this is a
cleanliness/doctrine finding, not a bug: the two are one new caller away
from reintroducing the shipped crash class, and
`StructuralGesturePlanner`'s header states the law as *the pure layer never
asserts*. Fix: the same refuse-`Bool` conversion; callers route `false` to
`requestFullRender`/`desyncRecovery`.

### NIT 5 · `Shared/EditorBrain/CrossBlockRefusal.swift:190` · `diagnose` hardcodes `isDeletion: true`

A REPLACEMENT over a lone separator would read as a "seam keystroke" —
unreachable today only because `clampedToBlockText`'s degenerate shape
(`CrossBlockCompound.swift:157-168`, #111) claims every such replacement
before the terminal diagnosis runs (traced through the route table). Worth
the real fact as a parameter, or a comment naming the shield, so a future
arm-list edit cannot make the mis-diagnosis live silently.

---

## Clean bill (checked, found solid)

- **The crash fix's core survives 18m intact, at both consumers:** the four
  converted mutators refuse (`BlockRangeIndex.swift:524-551`, overflow
  folded in, no `@discardableResult`); both `storageDidEdit`s consume the
  arming only through `describes` and route every refusal to
  `desyncRecovery`, with the canary checkpoint on the early-return roads;
  `fallbackVerdict`'s §3a lemma holds (negative-length guarded,
  out-of-tiling → honest recovery, never a trap).
- **`describes`' three oracles** each traced against the E1-observed shapes
  — starts-before rejection, the exact net-change identity (insertions
  constrained too), the asymmetric location bound with the empty-range
  insert case; the extent residue is honestly documented at the code.
- **Targeted suites re-run green** by struct name (21 + 13 tests; the
  two-suites-per-file trap honored); the merge diff vs `dd7cad84`
  re-derived as `VariorumMobile/**` + `notes/**` only.
- **`restampProjection`** clamps the stamp's extent to the index, never the
  report (TEXTKIT2 §3's rule); **`IdentityProjectionAudit`** is shared,
  closes the empty-entry hole, and its separator-character check caught
  probe 3's corruption exactly as designed (DEBUG-only — noted at MAJOR 2).
- **The 18m route table** honors the phone's declared arms (no seam carves,
  gap fence above the compound, `routeArms` pinned);
  `performCrossBlockRoute`'s undeclared arms fire the seam then speak the
  diagnosis; precedence rows carry their rulings.
- **`CrossBlockCompound`**: insures FIRST outside the undo compound, CASes
  every surviving end inside the transaction (`editTakesAtomically`
  `expectedText`), reads the fan from the STORE at run time, surfaces
  desync as a nil plan; the clamp road (`runClampedInBlockEdit`) re-verifies
  documentLength + expectedText before touching the input path. The
  ms-window verify→act residual is recorded at the code, as the round left
  it.
- **B45-2 closed as described**: `displaySlot`'s slot write is BY IDENTITY;
  the `entries`/`slots` lag is deliberately preserved for the guards that
  ride it.
- **The liveness seam as merged (4.5c-phone):** every refusal on the grant
  road is store-confirmed (`confirmNoteStillLive` before any refusal; the
  post-refresh belt re-confirms), the monotonic handoff token is re-checked
  after every suspension, the tombstone belt sits ABOVE the liveness belt in
  the gate so the truer sentence speaks, the stale deleted-note sentence is
  withdrawn at the grant, and `adoptHeader`'s relinquish half writes both
  directions (Put back heals).
- **The projection policy**: delivery arms (`refetchFresh`, busy-defer) and
  `applyPendingIfClean`'s marker restore on a failed read (F-2) hold as
  documented; deliveries never rewrite the surface.
- **`MobileMarkdownActs`**: every act rides the policed input path;
  `.continueList` cannot strand an arming (the internal consult re-arms and
  lands, or refuses and clears); `consumeDelete` replaces the keyboard's
  arming before any edit; `supportsTextReplacement == false` keeps the
  unmeasured system replace road closed.
- **UTF-16 discipline** holds through the snap brain
  (`snapToInteriorBoundary` → `BoundarySnapping`), the index, `ArmedEdit`'s
  lengths, and the churn arithmetic (`exactCost`).

---

## DISPOSITIONS (orchestrator, 2026-10-06 — the ladder's round 2; new MAJORs earn the focused round 3)

| finding | disposition |
|---|---|
| M27 | **DISSOLVED, measured** — the verdict this pass owed; recorded, nothing to fix. The device-walk caveat rides VM-13 (the gesture-matrix walk covers a post-divide first edit on hardware) |
| MAJOR 1 (no structural-flight keystroke fence) | **KNOWN AND TICKETED — VM-2** (archive row 95; PL-40's F-4). NOT fixed in this effort BY HER EXPLICIT RULING this session ("let's only do VM-10 post merge"); the pass's measured probe, pin shape and fix sketch are attached to VM-2 so its run starts warm. SURFACED to her in the report: the row is now MEASURED store corruption (duplication on divide, silent prose-loss on merge) — whether that changes its priority is hers |
| MAJOR 2 (`.openTail` arming binds content-blind; 1-char silent prose loss in Release) | **ACCEPTED — FIX WAVE** (Opus 5.5 implements per her cast; the reviewer's pin verbatim: the gate-less "x" after an armed-but-unlanded "\n" must route via fallbackVerdict to `.block(0)`, red today). NOTE: the fix touches `Shared/EditorBrain/` — the MERGE's zero-Shared fence stays true of the merge; the effort's verification widens to the Mac's editor-brain suites for this wave |
| MINOR 3 (`attachLeadingTailRunIfNeeded` skips the disarm doctrine) | **ACCEPTED — FIX WAVE** (one `host.disarmPendingEdit()`; doctrine class, pin if the probe shape is cheap, else the traced mechanism + justification stand per the guard) |
| MINOR 4 (two precondition-trapping mutators vs the refuse doctrine) | **ACCEPTED — FIX WAVE** (the refuse-Bool conversion; doctrine class — both callers guard today, so no red-on-old exists; recorded as such) |
| NIT 5 (`diagnose` hardcodes `isDeletion: true`) | **ACCEPTED — FIX WAVE** (pass the real fact or name the shield) |

---

## FIX WAVE (implementer — Opus 5.5, 2026-10-06)

**LIVE STATUS:** MAJOR 2 FIXED (both platforms, pins red→green, Mac twin
included); MINOR 3 FIXED (pin red→green); MINOR 4 + NIT 5 in progress;
final suites (mobile full, Mac editor-brain, core `swift test`) PENDING.
Scope is exactly the four ACCEPTED rows; MAJOR 1 (VM-2) untouched.

**Not done in this wave (stated first, per the record rule):** MAJOR 1 /
VM-2 (structural-flight keystroke fence) — not this wave's, by her ruling.

### MAJOR 2 — `.openTail` arming binds content-blind

**Mechanism, traced myself.** `shouldChangeText` (phone
`MobileEditorViewModel.swift:1536-1604`, Mac `EditorViewModel.swift`
twin) arms `.openTail` only for `replacement == "\n"` at the exact
document end of a tail-less, multi-block-capable note
(`BlockRangeIndex.verdict`, `replacementIsSingleNewline`). The consume
(`storageDidEdit`, phone :1795-1821, Mac :1229-1247) binds the arming
through `ArmedEdit.describes`, whose three oracles are geometry +
arithmetic only: same `documentLength`, `delta == replacementLength −
range.length` (1 == 1), and the inclusive location bound for an empty
approval (5 ≤ 5). A gate-less 1-char insert of ANY character at that
spot satisfies all three, so `.openTail` binds → `index.openTail()` →
the index declares offset 5 a separator with an empty tail behind it
while storage holds the visible character there. Nothing records it
(the `.openTail` arm records no autosave), so the store keeps "Alpha" and
the next full render drops the character. `.block`/`.tail` are
content-agnostic; `.closeTail` is a deletion (no landed bytes, and while
the arming is fresh the deleted character at its offset IS the
separator) — the hole is exactly `.openTail`. The SAME `ArmedEdit` is the
Mac consumer's binding, line for line, so the hole is both platforms'.

**Pin (mobile):** `MobileEditRoutingBindingTests.aStaleOpenTailArmingNeverBindsAGateLessCharacter`
(`App/Variorum/VariorumMobileTests/MobileEditRoutingTests.swift`).
*[removed for publication]*
`-only-testing:VariorumMobileTests/MobileEditRoutingBindingTests`):

```
✘ Test run with 7 tests in 1 suite failed after 0.281 seconds with 7 issues.
aStaleOpenTailArmingNeverBindsAGateLessCharacter — 4 issues:
  model.index.tailLength → 0                      (expected nil)
  model.index.entries.map(\.length) → [5]         (expected [6])
  model.identityAuditFailures → 1                 (expected 0)
  stored → "Alpha"                                (expected "Alphax" — the character never reached the store)
```

(The reviewer's probe 3 measured `tailLength=Optional(0) audit=1
desync=0`; reproduced exactly, plus the store half: the "x" is lost.)

**Pin (Mac twin):** `MacEditRoutingTests.aStaleOpenTailArmingNeverBindsAGateLessCharacter`
(`App/Variorum/VariorumTests/EditRoutingTests.swift`) — the Mac consumer
binds through the same `ArmedEdit`, so the hole was latent there too.
**RED on the pre-fix tree** (`-only-testing:VariorumTests/MacEditRoutingTests`):

```
✘ Test run with 6 tests in 1 suite failed after 0.248 seconds with 4 issues.
  model.index.tailLength → 0                      (expected nil)
  model.index.entries.map(\.length) → [5]         (expected [6])
  model.identityAuditFailures → 1                 (expected 0)
  storeSlots ≠ ["Alphax"]                         (value unprinted under `try`; the
                                                   assertion now binds a `let` first)
```

**Fix.** `ArmedEdit.binds(editedRange:delta:documentLength:landedText:)`
(`Shared/EditorBrain/EditorEditRouting.swift`) — `describes`' geometry,
then an EXHAUSTIVE verdict switch: `.openTail` binds only when the landed
`replacementLength` characters at the approval's location read
`EditorDocument.separator` (the gate's approved "\n" and, by
`openTail()`'s own doc, the separator); `.block/.tail/.closeTail/.refuse`
bind on geometry alone and never pay the read. BOTH consumers now bind
through it (`MobileEditorViewModel.storageDidEdit`,
`EditorViewModel.storageDidEdit`), passing their own `viewText`. A
declined arming falls to `fallbackVerdict`, which already answers
`.block(last)` for this input — no new routing. `describes` is unchanged
(its nine unit pins ride unmodified). The Mac consumer change is the
shared brain's consequence, not a second unit: leaving the Mac on
`describes` would ship a known latent twin of the fixed hole (this
file's own M13/MacEditRoutingTests precedent). Added one pure pin,
`ArmedEditTests.anOpenTailArmingBindsOnlyTheNewlineItMeans` (the rule +
the reader asked only for `.openTail`, exactly the landed bytes) — a
contract pin on the new API, not a red-on-old claim.

**Green after:** mobile `MobileEditRoutingBindingTests` — `✔ Test run with
7 tests in 1 suite passed after 0.225 seconds.`; Mac `MacEditRoutingTests`
+ `ArmedEditTests` — `✔ Test run with 16 tests in 2 suites passed after
0.207 seconds.`

### MINOR 3 — `attachLeadingTailRunIfNeeded` skips the disarm doctrine

**Mechanism, traced myself.** The attachment
(`TailCrystallizer.swift:280-302`) grows the last entry over the tail's
leading newline run and shrinks the tail by the same count —
`documentLength` unchanged, so `describes`' length oracle cannot see the
tiling move. Every other index-changing door disarms. **Which roads reach
the attachment with a LIVE arming:** the consume road reaches it only
after `storageDidEdit` has already consumed the arming; `finishMint`
disarms BEFORE its re-run; so only the idle tick (and the phone's
`finish()` teardown) can — and only if the tail is newline-led and
UNATTACHED at that tick. On the phone that state is produced by a
crystallization that skipped the attachment (the band's `!mintInFlight`
early return while a newline lands at the tail's start) and then ended
WITHOUT `finishMint` — the mint's FAILURE arm (`mintInFlight = false`,
report, settle; no disarm, no re-run). (A second road: `desyncRecovery`'s
re-render preserves an unattached tail, then an arming parks before the
already-armed idle clock fires. The Mac adds the structural-flight hold.)
The chain is long, as the reviewer labeled it — but every link is a
production road, so the pin builds it rather than a fiction.

**Pin (mobile):** `MobileEditRoutingBindingTests.theLeadingRunAttachmentDisarmsAStaleArming`
— the mint failure produced by a seal reaching the STORE the editor has
not ingested (the busy-deferral shape of a synced seal); every
precondition asserted in the pin (mint in flight; run still the tail's;
the mint failed with nothing crystallized; the attachment moved the
tiling with the bytes unmoved). **RED on the pre-fix tree** (same run):

```
theLeadingRunAttachmentDisarmsAStaleArming — 3 issues (every precondition green):
  model.index.entries.map(\.length) → [7]   (expected [6]: the stale .tail arming bound; the BLOCK's character was charged to the tail)
  model.index.tailLength → 6                (expected 7)
  model.identityAuditFailures → 1           (expected 0: the separator offset holds "o")
```

**Fix.** One `host.disarmPendingEdit()` in `attachLeadingTailRunIfNeeded`,
directly after the transfer, with the reason at the line; the host
protocol's doc for `disarmPendingEdit` now names both band callers and
states that it clears the ARMING only (both platforms' implementations are
`pendingEdit = nil`; the paste's bulk intent stays — the plan right after
the attachment may be reading it, and on the consume road the arming was
already consumed, so the disarm is a no-op there). **Isolation of the
red:** the red run was the fully pre-fix tree; the only other fix between
red and green is MAJOR 2's `binds`, whose switch returns `true` for a
`.tail` arming before any read — it cannot affect this pin, so the green
is the disarm's.

**Green after:** the same `MobileEditRoutingBindingTests` run above (7/7).
