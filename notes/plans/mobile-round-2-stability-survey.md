# Mobile round 2 — the cold stability survey

*A read-only inventory of the iPhone app's crash surface and its
architecture, written 2026-08-21 against branch `mobile` at `46ffa0c`.
No source file was modified. Every finding below carries a self-traced
mechanism or is labelled a SUSPICION; the repo's hallucination guard
binds this document exactly as it binds a review round.*

**SCOPE NOTE — one trap pair is deliberately excluded.** A separate
investigator owns the specific crash reached from
`UITextView.deleteBackward` → `MobileEditorViewModel.storageDidEdit` →
`BlockRangeIndex.applyBlockEdit` / `applyTailEdit`
(`BlockRangeIndex.swift:341/346/347`). This survey names the FAMILY
those two belong to and the other members of it, and states the
architectural fix that closes the whole family — but does not re-trace
that one path.

---

## 1. The architecture verdict

**The architecture is solid, and the crashing is not evidence against
it.** The load-bearing choices are right and they are held: identity
lives in one pure value type (`BlockRangeIndex`), not in text
attributes; the store validates every mutation independently of the
editor; the projection policy, the crystallization planner, the
markdown law, the structural planner and the snap rule are all pure,
shared with the Mac, and tested headlessly. Liveness is one authority
with one live editor. Every list is windowed with a probe row. Doors
that suspend re-verify their world afterwards. The 100k-word proving
ground is real and armed, including a memory ceiling. 314 mobile tests
back it.

The crashes come from one narrow, identifiable seam, not from the
shape of the app. `BlockRangeIndex` answers *questions* with refusals
(`.indexDesync`, "never a crash") but performs *mutations* behind
`precondition` — and preconditions survive `-O`, so they ship. The
verdict computed at the keyboard gate and the mutation applied at the
storage report are joined by a single untyped slot (`pendingVerdict`)
with nothing binding the verdict to the edit it was computed for. When
those two disagree, an editor designed to heal instead traps.

That is a defect at one seam, worth roughly a day. It is not a
rewrite, and nothing else found here rises to that class.

---

## 2. The reachable trap table

Ordered by how ordinary the gesture is. **Release matters:** `precondition`,
`preconditionFailure`, array subscripting and `Int(_: some BinaryFloatingPoint)`
all trap in `-O`; `assert` / `assertionFailure` are **compiled out**.
The mobile target's Release config uses the default optimization level
(no `-Ounchecked` anywhere in the `.pbxproj`), so the two halves behave
differently in her Xcode drops than in her Release installs — called
out per row.

| # | Site | Gesture | Verdict | What she sees |
|---|------|---------|---------|---------------|
| T1 | `Shared/EditorBrain/BlockRangeIndex.swift:341` `applyBlockEdit` · `:346`,`:347` `applyTailEdit` | Typing / backspace | **REACHABLE — OWNED ELSEWHERE** | Hard crash. Excluded by scope; listed as the family head. |
| T2 | `BlockRangeIndex.swift:353` `openTail()` — `precondition(tailLength == nil && !entries.isEmpty)` | **Return at the very end of a note** (the single most ordinary gesture in the app after typing) | **REACHABLE** — same stale-verdict mechanism as T1 (§2.1) | Hard crash in Release. |
| T3 | `BlockRangeIndex.swift:358` `closeTail()` — `precondition(tailLength == 0 && !entries.isEmpty)` | **Backspace on an empty just-opened tail** (Return then immediately Backspace — an everyday correction) | **REACHABLE** — same mechanism | Hard crash in Release. |
| T4 | `MobileEditorViewModel.swift:1075` `let entry = index.entries[entryIndex]` in `recordAutosave` | Typing | **REACHABLE, downstream of T1** — `applyBlockEdit` traps first on the same stale index, so this is the second door of one room, not a second bug | Hard crash in Release. |
| T5 | `MobileEditorViewModel.swift:1095` `assertionFailure("mobile editor surface desynced…")` inside `desyncRecovery()` | Any desync at all | **REACHABLE in DEBUG ONLY** — and this is the notable part: `desyncRecovery` is the app's *healing* path (flush, re-read, re-render). A Debug build stops the world on the exact path built to survive. | Debug/Xcode-run: crash. Release: silent, correct heal. Any Debug-build report of "it just died while typing" should be read against this line before anything else. |
| T6 | `MobileEditorViewModel.swift:1077` `assertionFailure("editable entry without a variant")` | Editing a slot the projection marked editable with no variant | **REACHABLE in DEBUG ONLY**; Release returns cleanly | Same asymmetry as T5. |
| T7 | `MobileEditorViewModel.swift:1477` identity-audit `assertionFailure` | Any keystroke whose re-stamp disagrees with the index | **DEBUG ONLY** (`#if DEBUG` block) — by design, and it is a good design | — |
| T8 | `BlockRangeIndex.swift:80` `preconditionFailure("entry index out of range")` in `range(ofEntryAt:)` | — | **GUARDED** — every one of the 12 mobile call sites derives `i` from `index.entries.firstIndex`/`.indices`, from a planner verdict computed against the same index in the same synchronous turn, or from `applyDifferential`'s `sameSequence` gate (`EditorProjectionEngine.swift:158` proves the counts equal before the loop at `MobileEditorViewModel.swift:581`) | — |
| T9 | `BlockRangeIndex.swift:368–370` `transferTailPrefixToLastEntry` | Typing newlines at a note's end | **GUARDED** — `attachLeadingTailRunIfNeeded` (`MobileEditorViewModel.swift:1153–1170`) checks `hasOpenTail`, a last entry, and `run > 0` counted from `tailText`, which is only ever assigned in lockstep with `tailLength` | — |
| T10 | `BlockRangeIndex.swift:385–386` `crystallize` | Typing past a paragraph | **GUARDED** — `finishMint` checks `index.tailRange` and `!outcome.applied.isEmpty` first, and the only write between the check and the call runs under `suppressEditProcessing` | — |
| T11 | `Shared/AuthSession.swift:189` `precondition(status == errSecSuccess, "SecRandomCopyBytes failed")` | Sign-in | **UNREACHABLE in practice**, deliberate and documented (14d cold review) — refusing loudly beats a deterministic all-zeros PKCE verifier. Leave it. | — |
| T12 | `MobileEditorTextView.swift:551` `current.mutableCopy() as! NSMutableParagraphStyle` | Any keystroke in a callout/gutter block | **UNREACHABLE** — `NSParagraphStyle.mutableCopy()` is documented to return `NSMutableParagraphStyle` | — |
| T13 | `MobileTakeHistorySheetView.swift:215–216` `Int(floor(top / rowPitch))`, `Int(ceil(bottom / rowPitch))` | Scrolling take history | **UNREACHABLE** — `rowPitch` is a non-zero constant (74) and `contentOffset` is bounded by a content size the view sets itself; no NaN or overflow path exists | — |
| T14 | `…/MobileTakesBrowserView.swift:179,572,715`, `MobileCommentsSheetView.swift:95`, `MobileTakeHistorySheetView.swift:98`, `MobileTakesChrome.swift:456`, `MobileEditorTextView.swift:780` — `required init?(coder:) { fatalError("not used") }` | — | **UNREACHABLE** — no nib or storyboard exists in the target; every one carries `@available(*, unavailable)` | — |
| T15 | `Spike/SpikeBench.swift:52,68` implicitly-unwrapped `UITextView!` / `UIPanGestureRecognizer!`; `SpikeScenarios.swift:34`, `SpikeBench.swift:95` `precondition` | — | **NOT SHIPPED** — the only doors are `#if DEBUG` (`MobileShellView.swift:110`, `MobileSettingsView.swift:225`) | — |

**Nothing else force-unwraps.** A full sweep found **zero** `try!` in
mobile or `Shared/`, exactly one `as!` (T12), and nine `!`
force-unwraps total — of which five are Spike-only, two are static URL
literals in `ProjectConfig`, and two are `URLComponents.url!` on
components built from a valid base (`AuthSession.swift:389,556`). No
dictionary force-lookups. No `removeFirst`/`first!`/`last!` on
possibly-empty collections anywhere. This is unusually clean, and it
means the trap surface really is the one seam above.

### 2.1 The mechanism behind T1–T4 — the one architectural finding

**PROVEN by code reading; the call graph is complete.**

`MobileEditorViewModel` runs a two-phase edit protocol:

1. `shouldChangeText(in:replacement:)` (`:952`) computes
   `index.verdict(replacing:…)` against the **pre-edit** index and
   stores the answer in one property, `pendingVerdict` (`:107`).
2. `storageDidEdit(_:changeInLength:)` (`:996`) consumes it:
   `let verdict = pendingVerdict ?? fallbackVerdict(…)`, then applies
   the matching mutation.

Nothing binds the two. `pendingVerdict` is a bare
`BlockRangeIndex.Verdict?` — no range, no document length, no
generation counter. So the consumed verdict is correct only under an
assumption the code never checks: *that the very next character edit to
reach storage is the edit this verdict was computed for.*

That assumption has real doors out of it, all of them ordinary:

- **UIKit consults the gate and then edits differently.** iOS batches
  autocorrect, predictive text and dictation into replacements wider
  than the keystroke that triggered them — `MobileSoul.md` §5.2 names
  this as a *platform truth*, and the file's own header records a
  measured case ("a 5→6 replacement reported length 7"). A verdict of
  `.block(index: i)` computed for one character, applied with the
  delta of a whole-word rewrite, is exactly `entries[i].length +
  lengthDelta < 0`.
- **A door arms the gate and the edit does not land.** `gateAllows`
  (`MobileMarkdownActs.swift:38`) arms the verdict from
  `inputReplace` (`:54`) and from `handleReturnKey`'s `.continueList`
  arm (`:180`) — and that arm has an early `return` at `:184`
  (`guard textView.textStorage.length == before + 1`) that can leave
  the slot armed. The stale verdict then waits for whatever edits next.
- **`fallbackVerdict` cannot rescue it**, because it only runs when
  `pendingVerdict` is `nil`. A stale non-nil verdict outranks the
  recomputation designed to be correct.

**Why this is the fix worth making, not a patch.** The refusal side of
this same type already has the right posture, stated in its own
comments: `verdict`'s `.indexDesync` arm carries *"Never a crash
(review round 1, MINOR 7): the view model's recovery re-renders from
the store, which is truth"* (`BlockRangeIndex.swift:123–126`), and
`StructuralGesturePlanner`'s header states the rule outright: *"The
pure layer never asserts (the Phase 7 MINOR-7 lesson): impossible
states answer with a refusal, and the caller recovers."*
`BlockRangeIndex`'s **mutators were never brought to that standard.**
They are the only part of the identity brain that answers an
impossible state by dying.

Two changes close T1, T2, T3 and T4 together:

- **(a) Bind the verdict to its edit.** Store the range and the
  document length the verdict was computed against; at consumption,
  if the reported edit does not match, discard and route through
  `fallbackVerdict` (which already computes correctly against the
  pre-edit index). This is a struct instead of an enum in one
  property.
- **(b) Make the mutators refuse.** `applyBlockEdit`, `applyTailEdit`,
  `openTail`, `closeTail` return a `Bool` (or `throws`) instead of
  trapping; `storageDidEdit` routes a `false` to the existing
  `desyncRecovery()`, which already flushes, re-reads and re-renders.
  The store is never at risk either way — operations validate against
  the DB, not the text view (AppSpec §15 risk 1) — so a refusal here
  costs one re-render and loses nothing.

Red-on-old pins are straightforward and headless: arm a verdict via
`shouldChangeText`, then drive a *different* replacement directly into
the `NSTextStorage` (the shape `MobileEditorTests.swift:80`'s
autocorrect test already uses, but with the gate armed first — which no
existing test does). That test crashes on today's code and passes
after.

---

## 3. Concurrency and lifecycle

**Isolation is correct.** Every `@Observable` class in
`VariorumMobile/` and `Shared/` carries `@MainActor` — verified by
sweep, no exceptions. `AppSession`, `AppServices`, the liveness
authority, all six editor siblings, all shell view models. No
`@Observable` state is mutated off-main anywhere.

**`MainActor.assumeIsolated` — eight sites, all sound.** Each sits in
a callback whose delivery queue is provably the main one:

| Site | Delivery guarantee |
|------|--------------------|
| `MobileEditorViewModel.swift:1563` (`NSTextStorageDelegate`) | `NSTextStorage` edits originate on the main thread from UIKit input; the storage is never mutated off-main in this codebase (every write goes through `programmaticReplace`, `renderFull`, or `applyVoiceChange`, all `@MainActor`) |
| `MobileEditorTextView.swift:60` (canary idle `Timer`) | `Timer.scheduledTimer` on the main run loop |
| `MobileTakesChrome.swift:363` (fade `Timer`), `:561` | same |
| `MobileTakesBrowserView.swift:161,167` (keyboard notifications) | `addObserver(forName:object:queue: .main)` — explicit |
| `Shared/SignInFlow.swift:91` | ASWebAuthenticationSession completion |

Two of these would still be more honestly written as
`MainActor.assumeIsolated`-free `@MainActor` closures, but none is a
defect and none is worth touching.

**FINDING C1 — the TK2 canary timer is never invalidated (PROVEN).**
`MobileFallbackCanary.arm(for:)` (`MobileEditorTextView.swift:52`)
schedules a repeating 30-second `Timer` on the main run loop.
`disarm()` exists (`:67`), is exposed as
`MobileEditorTextView.disarmCanary()` (`:739`) — and **nothing in
production calls it.** A repo-wide grep returns exactly two callers,
both in `MobileEditorTests.swift`. `MobileWriteView.makeUIView` builds
a fresh `MobileWriteSurfaceView` (and therefore a fresh text view and
canary) per note screen, and `model.attach(textView:)` arms it at
`:236`. Consequence: **one orphaned repeating main-run-loop timer per
note ever opened**, for the process's life.

Not a leak of the views — the block holds `[weak self, weak textView]`
correctly, so both deallocate and the tick returns early. Not a crash.
But it is an unbounded accumulation of main-thread wakeups that
defeats quiescence: open 200 notes in a long session and the main run
loop wakes 200 times every 30 seconds doing nothing. Fix: call
`disarmCanary()` from `MobileEditorViewModel.teardown()` (which
already runs on `onDisappear`, `MobileWriteView.swift:149–152`), or
from the text view's `deinit`. One line. Pin: assert
`canary.idleTimer == nil` after teardown.

**FINDING C2 — `MobileEditorStyle.storedVoice` is an unenforced
main-thread convention (LOW).**
`MobileEditorStyle.swift:48` is a `nonisolated(unsafe) private static
var` whose comment says "Main-thread written…, main-thread read." Every
read I traced is on the MainActor (`renderFull`,
`programmaticReplace`, `applyVoiceChange`, the chrome faces), so there
is no live race — but the compiler no longer checks it, and the voice
is read from `MarkdownFace.style` which is `nonisolated`. A future
off-main markdown pass (a plausible optimisation for the 100k Read
surface, §4) would silently make this a data race. Recording it as a
tripwire, not a bug.

**Lifecycle is well handled and I found no retain cycles.** Timer and
`UIAction` closures capture `[weak self]` throughout; gesture-target
and bar-button-item routers are deliberately retained by the text view
with the reason written down (`MobileEditorTextView.swift:120–127`);
`MobileTakesBrowserView` removes its notification tokens in `deinit`;
the TK2 stack's weak back-pointers are held strongly with an explicit
comment saying why (`:~565`). `MobileLivenessAuthority` holds editors
`weak` and prunes dead entries at every entry point.

**Cancellation is handled honestly.** All three observation loops
(`observeHeader`, `observeTakesProjection`, `loadOnce`) catch
`CancellationError` separately and stay silent, with the reasoning
recorded — a push-then-immediate-pop must not stringify a cancellation
into her status line.

**Re-entrancy: partially guarded, and the gap is cosmetic.**
`MobileStructural` guards every door with `structuralInFlight`
(`:55,72,191`) and — this is the good part — **re-verifies its world
after every suspension** by blockID, refusing on drift
(`:104–106`, `:223–226`). `MobileEditorViewModel` guards minting with
`mintInFlight`. What is *not* guarded: `MobileBlockMenu` fires twelve
bare `Task { await … }` blocks (`:116–269`) with no in-flight flag, so
rapid double-taps on a callout colour or a rename can run concurrent
operations. The store is safe (each is one transaction) and the worst
outcome is a lost update, not corruption — recording it, not
escalating it.

**P2 (all DB I/O off the main thread) — one launch-path exception
(LIKELY, not a crash).** `AppBootstrap.init` calls `open()`
*synchronously* (`AppBootstrap.swift:42`), and `AppBootstrap()` is
constructed as `@State` at `VariorumMobileApp.swift:29` — i.e. on the
main thread, before any view exists. `AppDatabase.openStore` runs the
migration set. On a warm store this is fast; on a first launch after a
schema addition, or on a large store, it is main-thread work in front
of first paint, and iOS's launch watchdog is the failure mode. This is
the *same family* as the KnownIssues "windowless launch" row, whose
captured mechanism was a synchronous main-thread Keychain hop at
`AuthSession.init` — **and that half is fixed** (13e batch 9, B-1: see
`AuthSession.swift:257–281`, the lazy `ensureLoadedFromStore`). The
store-open half was not part of that fix and is still synchronous. I
did not measure it, so this is LIKELY, not PROVEN; a measurement is
one `signpost` away.

---

## 4. Memory and the 100k bar (P1/P3)

**The Write surface is genuinely defended, and measurably so.** This
deserves saying plainly because it is the hardest thing in the app and
it was done right:

- Every list is windowed with a probe row: books 300
  (`MobileBookViewModel.swift:36,60–70`), scraps 200
  (`MobileScraps.swift:60,89–91`), library via `listingLimit`. Each
  carries a visible truncation marker rather than a silent cut, and
  the `count > window` comparison is exact so an exact-window list
  never false-positives.
- Echo detection never reads the surface — `EditorSurfaceLedger` holds
  per-variant text and word counts in memory
  (`EditorProjectionEngine.swift:28–104`), so the O(post-length)
  compare is gone.
- Chrome refresh is `.edit`-scoped on the keystroke road
  (`MobileEditorViewModel.swift:1044`), which is FB2-1's fix: the
  recorded measurement is 551 ms → 6 ms per keystroke at 100k and
  5,842 → 43 MiB walk memory.
- `blockRangesByID()` (`:840`) exists specifically to replace an
  O(decorated × entries) per-tick cost with one O(entries) walk.
- The DEBUG identity audit was rewritten to a single running-location
  walk to kill an O(entries²) per-keystroke cost (`:1433–1440`).
- `MobilePerfWalkTests` arms a **250 MiB memory ceiling** plus
  per-keystroke and per-scroll-step budgets against a real ~100k-word
  fixture, and asserts flatness in corpus size.

**FINDING M1 — the Read surface has no within-note bound, and no perf
pin at all (LIKELY; mechanism traced, not measured).**
`MobileReadNoteView` (`MobileReadView.swift:120–170`) virtualizes at
the **note** level — `LazyVStack` over notes, per-row lazy `.task`
text load — which is correct for a book of many notes and is what the
file's header claims. But *within* one realized row it materializes the
whole note:

1. `.task` reads the full rendered text
   (`Queries.renderPost` + `joinRenderedTexts`) — for a 100k-word note,
   roughly 600 KB of `String`;
2. `MobileReadPage.paragraphs(of:)` (`MobileReadPage.swift:75–108`)
   runs `MarkdownRendering.render` (a second full string plus a runs
   array), then builds **one `AttributedString` per display line** —
   on the order of 1,500–3,000 for that note, each carrying an
   `AttributeContainer`;
3. `ForEach(Array(paragraphs.enumerated()))` (`:141`) then creates a
   SwiftUI `Text` per paragraph inside that one row, all of which
   SwiftUI must size to lay the row out.

`MobileReadTests` covers `paragraphs(of:)` for correctness (markdown,
links, list clamping) but **`MobilePerfWalkTests` contains zero Read
coverage** — a grep for `Read` in that file returns nothing. So the
100k proving ground, which is the app's whole executable defence of her
stated bar, has never been pointed at this surface.

This is the same family as the standing KnownIssues row *"Within-post
virtualization escape hatch"* (owner: Phase 12), which is why it is not
an unowned finding — but that row was written for the Mac, where the
consequence is slowness. On the phone the consequence is jetsam, which
is a hard kill, and `MobileSoul.md` §2 says so explicitly. The cheap
first move is not a virtualizer: it is **a measurement**, and then a
per-note paragraph cap with the same visible-truncation grammar the
lists already use ("this note continues — tap to open it in Write"),
which is honest, tiny, and consistent with the surface's own tap-into-
Write gesture.

**No other unwindowed read found.** I checked the shell view models,
the takes browser (band-materialized,
`MobileTakeHistorySheetView.swift:207–233`), the block list, and the
tag manager. All bounded.

---

## 5. The god-object question — the honest answer

**`MobileEditorViewModel.swift` (1,567 lines) is large but is not a god
object, and I would not spend a phase splitting it.** The evidence:

- Six responsibilities are *already* extracted as sibling controllers
  under the recorded NIT-3 rule — `takes`, `takesBrowser`, `comments`,
  `structural`, `blockMenu`, `takeHistory` (`:52–76`). The VM routes
  to them and holds no takes/comments/structural policy.
- Every *decision* is already elsewhere and pure: `BlockRangeIndex`
  (routing), `EditorProjectionPolicy` (what a projection does),
  `CrystallizationPlanner`/`Reconciler`, `MarkdownSurfaceDoors`,
  `StructuralGesturePlanner`, `BoundarySnapping`. What remains in the
  VM is *execution* over four fields that genuinely form one machine —
  `index`, `slots`, `ledger`, `tailText` — and splitting a single
  coherent state machine across objects usually makes it less safe,
  not more.
- For calibration: the Mac's `EditorViewModel` and
  `EditorSurfaceController` are each larger than this file.

That said, four seams are real, in ascending cost. Two of them are
`MobileSoul.md` §3 debts (brains that should live in `Shared/`), which
makes them worth doing on principle rather than on size:

- **(S1) `restampProjection` (`:1385–1424`, ~40 lines).** Pure over
  (index, storage, range). Belongs in `Shared/EditorBrain` as a free
  function. It is the iOS identity mechanism and it is currently
  untestable except through a live VM. Cheapest, highest principle.
- **(S2) `auditIdentityProjection` (`:1428–1490`, ~60 lines, `#if
  DEBUG`).** Same shape — pure over (index, storage). Would give both
  platforms the same oracle.
- **(S3) The note-metadata doors — `lockNote`, `unlockNote`,
  `renameNote`, `setEntryDate`, `adoptHeader` (`:436`, `:705–815`,
  ~130 lines).** Zero coupling to index or storage; each is
  `run op → re-read header → adopt`. A `MobileNoteMetadataController`
  sibling drops straight into the existing pattern. Mechanical.
- **(S4) Crystallization — `armTailIdleMint`, `idleMintTail`,
  `attachLeadingTailRunIfNeeded`, `crystallizeIfNeeded`, `finishMint`
  (`:1112–1300`, ~190 lines).** The real seam, and the expensive one:
  it touches `index`, `tailText`, `ledger`, `autosave` and
  `mintInFlight`, so extracting it needs an explicit surface-state
  protocol. **The Mac carries the same code** (`EditorViewModel.swift`
  1144/1264), so this is a cross-platform hoist, not a mobile
  refactor — do it as one, or not at all.

**`MobileEditorTextView.swift` (781 lines) is a UIKit subclass with
clean MARK bands**, not a dumping ground. One natural file split
exists — the TK2 geometry helpers (`nearViewportBand`,
`firstLineGeometry`, `blockRectsUnion`, `lastLineEnd`, `:245–330`)
plus the paragraph-reservation walks (`:440–560`) are ~200 lines of
self-contained geometry that would read better as
`MobileEditorGeometry.swift`. Cosmetic; do it only if someone is in
the file anyway.

---

## 6. What is already well-pinned — do not spend here

Recording this explicitly so the next architect does not re-audit
ground that is solid:

- **Identity over the surface.** `identityAuditFailures == 0` and
  `desyncRecoveryCount == 0` are asserted at 20+ points across
  `MobileEditorTests`, `MobileMarkdownTests` and `MobileWalkTests`.
  The gate-less system paths (autocorrect via direct storage
  replacement, dictation, marked-text commits) have their own pin
  (`MobileEditorTests.swift:80`).
- **The projection race family.** `anAutosaveEchoNeverRewritesTheSurface`,
  `aDeliveryWhileDirtyDefersUntilSettleThenAppliesFresh`,
  `aStaleDeliveryAtACleanInstantNeverRewritesTheSurface` — the MAJOR-3
  clean-instant class is pinned on both platforms.
- **Post-suspension re-verification.**
  `divideReVerifiesTheCaretsBlockAfterTheFlushWindow` and its merge
  twin pin the flush-window drift guard.
- **Flush-before-structural.** Four separate pins that unflushed typing
  survives divide, fanned divide, merge and fanned merge.
- **The seal and the lock.** `aSealedNoteRefusesEveryEdit`,
  `aLockedTakeRefusesWithItsOwnMessage`, plus
  `lockNoteRefusesWhileAPendingFlushCannotLand`.
- **The TK2 canary** has a positive control
  (`theCheckpointDetectsARealDowngrade`) — the fallback detector is
  itself tested.
- **Perf.** A 250 MiB memory ceiling, per-keystroke and per-scroll
  budgets, and a corpus-flatness assertion, all against a real ~100k
  fixture.
- **The known crash-adjacent divergence is already handled where it
  matters.** `index.entries` outruns `slots` during the
  crystallization window (`finishMint` calls `index.crystallize` at
  `:1281` and never assigns `slots`) — and
  `StructuralGesturePlanner.swift:492` guards its `fanArities` lookup
  for exactly that reason, *with the window named in the comment*
  (`World.fanArities`, `:44–48`). The one remaining consumer of the
  coupling, `displaySlot`'s `slots[i] = slot` (`:928`), is currently
  saved by its callers: `flip` and `peek`
  (`MobileTakesController.swift:148,191`) both guard on
  `model.slot(for: blockID)`, which searches `slots`, and a freshly
  crystallized block is neither in `slots` nor fanned.
  **SUSPICION, recorded not escalated:** that is a caller-side
  accident, not an invariant. A future feature that reaches
  `displaySlot` for a block the projection has not echoed back — a
  lens applied to a just-typed block, a takes door on a fresh mint —
  makes `slots[i]` an out-of-range trap. If S4 (§5) or PL-10's
  reorder-takes work touches this area, make the coupling explicit
  (index the slot by blockID, or keep `slots` in lockstep through
  `crystallize`).

---

## 7. Recommended fix order

| # | Fix | Size | Why here |
|---|-----|------|----------|
| **1** | **Bind the verdict to its edit + make `BlockRangeIndex`'s mutators refuse instead of trap** (§2.1 (a)+(b)) | ~half a day + pins | Closes T1, T2, T3 and T4 *as a class* rather than one path, and brings the mutators to the posture the rest of the identity brain already holds. Red-on-old pin is easy and headless. **This is the one thing I would fix first.** Coordinate with the investigator holding T1 — same seam, one patch. |
| **2** | **Reconsider `desyncRecovery`'s `assertionFailure` (T5)** | 1 line + a comment | It stops the world in Debug on the exact path built to heal. Keep a counter (already there — `desyncRecoveryCount`) and let tests assert zero; do not kill her Xcode build for a state the code recovers from. Cheap, and it stops Debug crash reports from masking the real ones. |
| **3** | **Invalidate the canary timer at teardown (C1)** | 1 line + 1 pin | Proven, trivial, and removes an unbounded main-thread wakeup accumulation. |
| **4** | **Point the 100k proving ground at the Read surface, then cap paragraphs per note (M1)** | ~half a day measure, ~half a day cap | The bar is hers and explicit; this is the one surface the bar has never been aimed at. Measure before building anything — the cap may prove unnecessary, and the repo's guard forbids fixing on suspicion. |
| **5** | **Move `AppBootstrap`'s store open off the main thread** (§3, P2) | ~half a day | Measure first (signpost around `openStore`). Same family as the fixed Keychain hop; the remaining half of a known launch-path story. |
| **6** | **Hoist `restampProjection` and `auditIdentityProjection` to `Shared/EditorBrain` (S1, S2)** | ~2 hours | MobileSoul §3 debt; makes the iOS identity mechanism directly testable. Do it while in the file for fix 1. |
| **7** | **Extract the note-metadata doors (S3)** | ~2 hours | Optional. Only if the VM's size is bothering someone; it buys clarity, not safety. |
| **8** | **Add an in-flight guard to `MobileBlockMenu`'s twelve `Task` doors** | ~1 hour | Lowest priority — worst case today is a lost update, never corruption. |

**Not recommended:** splitting the crystallization machinery (S4) as a
mobile-only act. It is shared code by nature; do it as a cross-platform
hoist in a phase that owns both editors, or leave it.
