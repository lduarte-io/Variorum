# Variorum for iPhone — Cold Architectural Review

*Written 2026-08-30 by a cold reviewer with no implementation context, at
the author's instruction: **"it should only write findings - not fix them.
I'm open to what you want to prompt it with, this is really a check of
overall quality and potential issues to get ahead of tech debt."***

**Scope:** the whole `App/Variorum/VariorumMobile/` target (66 files,
24,539 lines), plus `App/Variorum/Shared/` (15,696 lines) where it bears
on the phone. Core and the Mac target are out of scope except where a
finding names a **fork** between them.

**Method:** static reading against this project's own rubric — `CLAUDE.md`'s
architecture rules, `OverallModel.md` §4–6 and §9, `MobileSoul.md` §2–§4,
`TEXTKIT2_NOTES.md` §3 — plus targeted greps, cross-target copy diffing,
and one standalone measurement harness. **Every finding is labelled
`MEASURED` or `READ-ONLY`.** Nothing was fixed; no `.swift` file was
touched.

**One caveat on the tree, stated up front.** Another agent held
uncommitted work in this worktree during the review, including
`MobileEditorViewModel.swift`. Every finding below that touches a modified
file was **re-verified against committed `HEAD`** (`git show HEAD:<path>`)
so that nothing here is a report on someone else's work in progress. The
full mobile suite was deliberately **not** run, for the same reason: a
build of a tree mid-edit would have told me about their state, not the
architecture's. No simulator was used, so no result here can be
contaminated by the shared-device class.

**Line numbers are as of the working tree at review time.** Where a
finding cites a file that agent had open, the *code* was confirmed present
at `HEAD` but the *line* may have shifted — most notably
`MobileBlockHistory.swift` (renamed from `MobileTakeHistory.swift` and
restructured in their work), where the cited `:492` is `:222` at `HEAD`,
and `MobileBlockMenu.swift`, where `:369` is `:357`. Search the quoted
text rather than trusting the number if it does not land.

---

## 1. Verdict

**The mobile app's architecture is broadly sound, and markedly better
disciplined than "built fast across three rounds" would predict.** I found
**no BLOCKER**. I want to say that plainly rather than manufacture alarm,
because the honest headline is that the load-bearing ideas held:

- **`MobileSoul` §3's brains-in-core rule is real, not aspirational.** The
  identity brain, the projection policy, the crystallization planner, the
  cross-block planner, the recovery copy and the structural planner all
  live in `Shared/EditorBrain` and `Shared/`, and the phone composes them.
  The hoists recorded in the ledger actually happened.
- **P3's "exactly one live editor" is a mechanism, not a convention.**
  `MobileLivenessAuthority` is an explicit, documented, testable grantor
  with a registration set — the right shape.
- **P1 windowing is present** on every list I checked (`observeLibrary`
  limits, `poolPosts` limits, trash `window + 1` probe rows, `LazyVStack`
  everywhere it matters).
- **Latch discipline in the structural layer is textbook** — all seven
  sites in `MobileStructural.swift` guard, set, and `defer`-clear *before*
  any `await`. That is exactly right, and it is the pattern the rest of
  the app should be measured against.
- **The edit trace is bounded by construction** (a 300-event ring with
  reserved capacity) rather than by hope — the memory bar taken seriously.
- **Refusals genuinely are exhaustive** where the shared planner drives
  them: both the Mac's `RefusalCopy` and the phone's `spanRefusalMessage`
  switch without a `default:`, so a new shared `Refusal` case fails *both*
  builds until it gets words. That safety property survives the fork.

**What is actually wrong is one theme, repeated:** the app is disciplined
*where a hard lesson was paid for* and undisciplined *everywhere the same
lesson applies but was never re-derived.* The in-flight latch exists in 4
files and is missing in 20. The O(N²) accessor was found, measured, and
fixed in one brain — and left in place in its two nearest siblings, one of
which carries a doc comment asserting the opposite. Refusal copy has one
consolidated home for deletion and ten ad-hoc homes for everything else.
This is not decay; it is a pattern that was never swept to completion, and
sweeping is cheap now and expensive later. That is precisely the tech debt
the author asked to get ahead of.

**Counts:** 0 BLOCKER · 2 MAJOR · 4 MINOR · 2 NIT.

---

## 2. Findings

> **⚠️ DISPOSITIONED 2026-08-30 — and its sharpest case is STALE. READ THIS
> FIRST.** `assertBookNameIsFree` landed inside the create-book door's runner
> closure at `66606c0`, which is **not an ancestor** of this review's commit —
> so "the phone calls it at zero" was true of the tree read here and false at
> `HEAD` by the time this was dispositioned. Driven, a double tap on that door
> mints **one** book. The finding's CLASS is real and was acted on: a shared
> `MobileWriteLatch` now guards the **four** doors where a second flight mints
> an uncaught row. The per-door verdict table, the traced mechanisms and the
> proven reds are in `notes/plans/mobile-major-fix-round-record.md` (A1).
>
> **⚠️ AMENDED 2026-08-30 by the Fable sweep (finding 1): this banner said
> THREE, and three was one short.** `MobileLenses.adoptView` — a door on this
> review's own twenty-file list (*"`MobileLenses` (5)"*) that the fix round's
> verdict table never classified — mints an uncaught row too: its door is a
> persistent plain `Button { Task { … } }` that does not dismiss, it renders
> while `viewDiverges` (true for the whole first flight), it captures its picks
> before its first suspension, and `adoptPicksPreservingChosen` inserts its
> preservation `Lens` unconditionally on a table with no uniqueness. A double
> tap left TWO "chosen until …" lenses. **Latched at the Opus fix round the
> same day, red-on-old proven (`preservations → 2`).** The class argument
> stands; its claimed coverage did not.

### MAJOR 1 — Twenty write doors have no in-flight latch; the create-book door mints duplicates on a double tap

**What it is.** `MobileStructural`, `MobileEditorViewModel`,
`MobileUndoDoor` and `MobileBlockMenu` all carry a proper in-flight latch.
Twenty other phone files write through `session.runner.run` with **no
latch of any kind**, and their doors are SwiftUI `Button { Task { … } }` —
which spawns an independent unstructured task per tap.

**The traced mechanism** (`MobileCreateBook.swift`, the sharpest case):

```
Button { Task { if let id = await model.create() { dismiss(); onCreated(id) } } }
    .disabled(!model.canCreate)                      // :208
```

`model.create()` (`:95`) has `guard canCreate else { return nil }` and then
`await session.runner.run { ops.createReading(...) }` (`:102`). `canCreate`
(`:70`) is a pure function of `name`, `kind`, and `selectedTagPaths` —
**none of which change during the flight** — so `.disabled` stays `false`
for the whole await, the sheet stays presented (`dismiss()` runs *after*
the await), and the button stays hittable. Two taps inside the write
transaction produce two `Task`s, two `createReading` calls, and **two
books with the same name**.

Nothing downstream catches it: `assertBookNameIsFree` exists in core
(`Operations+Reading.swift:337`) and the Mac calls it at **six** sites —
`AppSettingsView:488`, `ReadingsViewModel:56,74`, `ShelfViewModel:179`,
`BookStructureModel:446,493`. **The phone calls it at zero.**

`MEASURED`? **`READ-ONLY`.** I traced this by reading and did not drive a
double tap. The window is one write transaction wide, which is small but
is exactly the window a fast double-tap or a laggy frame lands in.

**Where:** `App/Variorum/VariorumMobile/Features/Shell/MobileCreateBook.swift:95,102,188-208`.
The unlatched class also covers `MobileTakesBrowser` (7 writes),
`MobileLenses` (5), `MobileBlockHistory` (4), `MobileMembership` (3),
`MobileScraps`, `MobileTagManager`, `MobileReferences`, `MobileBookDetails`,
`MobileShelfViewModel`, `MobileStars`, `MobileTrashModel`,
`MobileLibraryViewModel`, `MobileComments`, `MobileNoteTags`,
`MobileTakesController`, `MobileTodayDoor`, `MobileQuickNote`,
`MobileTutorialSeeder`, `MobilePerfFixtureSeeder`.

**Why it matters.** Two identical books is a user-visible wrong outcome
the app has already decided it does not want — PL-10(b) owes the phone
this guard precisely because duplicate names are a defect. It is also
`OverallModel` §9's "an operation that feels tortured" inverted: a rule
applied in four files and skipped in twenty is architecture drift even
where each instance happens to work.

**Worth stating because it is easy to over-read this finding:** not every
unlatched door is a bug. `MobileTodayDoor` is safe *by the operation's own
idempotence* — `createOrOpenJournalEntry` is create-**or-open** inside one
serialized GRDB write, so a second flight opens rather than mints. That is
a good property, but it is the op's, not the door's, and it does not
generalise: `createReading` has no such arm.

**Remedy sketch (not a patch).** Two layers, in this order. (1) The
door-level latch: give the unlatched models the `MobileStructural` shape —
an `actInFlight` flag guarded/set/`defer`-cleared before the first await,
with the button reading it. Doing this once as a small shared modifier or
protocol would stop the twenty-first door repeating it. (2) The
authoritative layer: land PL-10(b)'s `assertBookNameIsFree` **inside the
`runner.run` closure**, the way all six Mac sites already do — a
caller-side pre-check would be a projection read, which is the 13c R3-1
lesson this codebase already documents at `deleteBlock(requiring:)`.
Layer 2 alone closes the duplicate-name outcome even if a double-fire
slips through; layer 1 alone does not close it for other mints.

**Suggested owner:** the mobile app project row — a mobile batch, naturally
alongside PL-10(b)'s guard, since the two remedies land at the same door.

---

> **✔ FIXED 2026-08-30.** A monotonic handoff token, minted synchronously at
> the tap and checked at entry and after every suspension: the last REQUESTED
> tab wins, never the last completed task. Two pins drive the stale-completes-
> last ordering and hold the user-visible half through the real gate (she can
> type in the visible editor; the hidden one refuses). Both proven red.
> Record: `notes/plans/mobile-major-fix-round-record.md` (A2).

### MAJOR 2 — The tab-switch liveness handoff is applied by unordered tasks while `tab` is set synchronously, so liveness can end up disagreeing with the visible tab

**What it is.** `MobileLivenessAuthority` is a well-built mechanism, but
the shell drives it from an unstructured `Task` with two suspension points
and no ordering token, while the `tab` state it is supposed to track is
assigned synchronously.

**The traced mechanism.** `MobileShellView.swift:292-307`:

```
guard tab != target else { return }
tab = target                                  // sync, immediate
let editors = router.editors
let quickNote = router.quickNote
Task {
    await quickNote.fileOnLeaving()           // suspension 1 (writes)
    await editors.tabDidBecomeVisible(target) // suspension 2
}
```

`tabDidBecomeVisible` (`MobileLivenessAuthority.swift:96`) then either
crowns the entering tab's heir via `takeLiveness` — itself containing
`await editor.autosave.flushNow()` and `await editor.refreshTakesFromStore()`
before `editor.noteLivenessGranted()` — or stands **every** editor down.

Two taps on different tabs (Shelf → Library → Shelf) pass the `guard`
both times, set `tab` twice, and spawn two independent tasks whose bodies
interleave across four suspension points backed by database work. Nothing
captures a generation, and nothing re-reads `tab` at apply time: each task
acts on the `target` it captured at spawn. If the task whose `target` is
**not** the final `tab` completes last, the liveness state it installs is
the one that stands.

Two concrete wrong end states follow:

- **The visible editor is not editable.** The last-completing task lands
  on a tab with no registered editor and runs
  `for entry in entries { entry.editor?.standDown() }` (`:101`), which sets
  `isEditable = false` on the editor the user is now looking at. She taps
  into her note and cannot type.
- **A hidden editor holds the pen.** The mirror: `noteLivenessGranted()`
  (`MobileEditorViewModel.swift:299`) sets `isLive = true` and
  `isEditable = true` on an editor on the *hidden* stack — which is
  precisely the state the authority's own header says is the law it
  exists to prevent ("the hidden stack's editor STANDS DOWN").

The same shape reaches `register` (`:71`), which also awaits inside
`takeLiveness`; a tab switch landing in that window resumes to grant
liveness to an editor the switch has just stood down.

`MEASURED`? **`READ-ONLY`.** I traced this from the call sites and the
suspension points; I did not drive it on a device. It is a race, so an
un-driven trace is the honest label — and it is exactly the kind of thing
that would show up as her saying "sometimes I tap into a note and it won't
let me type."

**Where:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift:292-307`
and `App/Variorum/VariorumMobile/Features/Shell/MobileLivenessAuthority.swift:71,96,105`.

**Why it matters.** P3 on the phone is `MobileSoul` §2's letter — "ONE live
editor ever" — and this is the one mechanism that enforces it. A grant
that can be applied out of order is not an authority. It is also a lifecycle
correctness issue against `CLAUDE.md`'s "no side effects constructed in
view models": the view constructs the task and the ordering guarantee lives
nowhere.

**Remedy sketch (not a patch).** Make the handoff ordered rather than
racing. The cheapest honest shape is a monotonic generation on the
authority: the shell increments and passes it, and `tabDidBecomeVisible`
returns without acting if a newer generation has already been requested —
so the last *request* wins rather than the last *completion*. A stronger
shape is to have the authority own the current tab and re-read it after
each await instead of trusting the captured `target`. Either way, the
`fileOnLeaving()` await should be inside the same ordered unit, since it
is what makes the window wide. A pin driving two switches with a stalled
flush would go red on today's code and green after.

**Suggested owner:** the mobile app project row (the shell is phone-only).
If 13u's item 1 work touches pane liveness, it should be aware of this
first — but the mechanism is the phone's shell, not a shared brain.

---

### MINOR 1 — `applyDifferential` is O(N²) in block count on **both** platforms, and its doc comment asserts the opposite

**What it is.** `BlockRangeIndex.range(ofEntryAt:)` walks the entries from
zero on every call (`Shared/EditorBrain/BlockRangeIndex.swift:74-81`). Both
platforms' `applyDifferential` call it **inside a loop over every block**,
making the loop quadratic in the note's block count — and both carry the
comment *"Cost ∝ changed blocks, never the post."* That claim is false as
written: the accessor runs for every `i` regardless of whether that block
changed, so the cost is paid in full even when **nothing** changed.

**The traced mechanism.**

```
for i in stride(from: new.count - 1, through: 0, by: -1) {
    let newText = new[i].text ?? ""
    let range = index.range(ofEntryAt: i)      // O(i)
    if viewText(range) != newText { … }
}
```

Σ O(i) over N entries = O(N²).

`MEASURED` — **yes**, and this is the one thing here I ran. I transcribed
`range(ofEntryAt:)` and the loop verbatim into a standalone harness
(`swiftc -O`, this machine) and compared them against the accumulation
pattern already proven in `CrossBlockEditPlanner.plan`:

| blocks | `applyDifferential` loop | accumulated (the existing fix) |
|---|---|---|
| 700 | 0.26 ms | 0.02 ms |
| 1,400 | 0.95 ms | 0.01 ms |
| 5,000 | 14.64 ms | 0.05 ms |
| 20,000 | 1,066.73 ms | 0.18 ms |

Both loops produced byte-identical guard sums at every N, which is the
same equivalence the shipped
`theWalkAgreesWithTheIndexsOwnAccessor` pin already asserts.

**I want to be precise about severity, because the numbers argue against
alarm.** This project's own figure for her 100k-word bar is ~1,400
paragraphs, where the measured cost is **0.95 ms** on this machine — not a
defect she would ever feel, even allowing that an A-series chip is slower
on a scalar loop. It becomes real at ~5,000 blocks and severe past that.
So this is graded MINOR **for its latency today** and reported at all for
two other reasons:

1. **The comment is actively wrong**, and it is the kind of comment a
   future reader trusts instead of re-measuring. A session optimising this
   road would read "cost ∝ changed blocks" and look elsewhere.
2. **This is the exact class the project already paid to learn.** The
   sibling in `CrossBlockEditPlanner` measured **23.8 s at 20,000 entries**
   on a keystroke road, and its fix is documented at length as *"arithmetic,
   not policy."* That fix was applied to one call site and its two nearest
   neighbours were left alone. The known-issues row names
   `planVisibleTakeEdit` — I confirmed that one is genuinely Mac-only
   (`EditorSurfaceController.swift:1816`; the phone uses the fixed hoisted
   planner), so **this is a different, unreported site, and it is on both
   platforms.**

**Where:** `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:661-668`
(verified identical at `HEAD`, line 658) and
`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:103-110`.

**Why it matters.** `OverallModel` §5's P1 is absolute in its wording — no
operation's cost may scale with total document size — and this road is
reached by ordinary sync deliveries, which `MobileSoul` §5.3 notes fire
*more* on the phone than between two desks, because offline is the phone's
normal.

**Remedy sketch (not a patch).** Lift the accumulation pass out of
`CrossBlockEditPlanner.plan` into `BlockRangeIndex` itself as an
`entryRanges` (or `starts`) accessor computed once, and have both
`applyDifferential`s consult it — then **sweep the class to completion**
rather than fixing three sites: every caller of `range(ofEntryAt:)` inside
a loop, on both platforms, each given a verdict of *fixed-with-a-pin* or
*provably safe*. Fix the comment in the same change. A pin at 5,000 blocks
would be red on today's code.

**Suggested owner:** **13u**, its item 8 — that row already owns the
editor-seam backlog and the surviving O(N²) twin, and 13u item 5 rewrites
this neighbourhood, so fixing it anywhere else means fixing it twice.

---

### MINOR 2 — The structural refusal vocabulary is forked across both app targets, and this fork is not on the known eight-brain list

**What it is.** `StructuralGesturePlanner.Refusal` lives in `Shared/`, so
both platforms consume one enum. Its **copy** lives twice: the Mac's
`RefusalCopy` (`Variorum/Features/Editor/RefusalCopy.swift`, an app-local
enum) and the phone's `spanRefusalMessage`
(`VariorumMobile/Features/Write/MobileStructural.swift:432`). Six of the
twelve sentences are byte-identical across the two targets; six diverge
deliberately, because the phone names its own doors under the no-redirect
principle.

**The traced mechanism.** Cross-target string diffing found 34 sentences
duplicated between `Variorum/` and `VariorumMobile/` with no `Shared/`
home. The structural family is the largest cluster:

- `"This block hasn't fully synced yet — try again once it arrives."` —
  `RefusalCopy.swift:19`, and **three times inline** on the phone
  (`MobileStructural.swift:99,228,439`)
- `"To merge, put the caret at a block seam or select across the blocks to join."` —
  `RefusalCopy.swift:33` / `MobileStructural.swift:460`
- `"This text isn't a block yet — it becomes one moments after you pause typing."`
- `"The editor lost track of the selection — try again."`
- `"The editor lost track of block boundaries — reloading from the store."` —
  `EditorViewModel.swift:3043` / `MobileEditorViewModel.swift:1964`
- `"This block has \(otherTakes) other takes — they keep this span."` —
  `EditorSurfaceController.swift:231` / `MobileStructural.swift:480`

`MEASURED`? **`READ-ONLY`** (a string-level diff of the two targets, which
is exact, but no behaviour was driven).

**Why it matters, and why it is smaller than it looks.** `MobileSoul` §3's
drift class: a rule that lives twice diverges silently when one platform is
edited. The `KnownIssuesAndTechDebt.md` eight-brain row enumerates
`ThemeStore`, `applyTypedPath`, `CalloutPalette`, `CalloutMenu.rows`, the
five deletion-copy homes, `TakeClipboard`, `BlockSelection` and
`TakesReplacePlan` — **this family is on none of them**, so today it has no
owner, which is the blank-owner state that file's own rule forbids.

The mitigating fact, which I checked specifically because I expected the
opposite: **both switches are exhaustive with no `default:`**, so a new
shared `Refusal` case fails *both* builds until it gets words. The
dangerous version of this fork — a phone that silently falls through to a
generic sentence while the Mac is forced to write copy — does not exist.
What remains is ordinary divergence: a Mac phase improving a sentence
leaves the phone's stale, and nothing announces it.

**Remedy sketch (not a patch).** Hoist to
`Shared/StructuralRefusalCopy.swift` holding the platform-neutral sentences
once, with a small explicit per-platform override table for the six that
genuinely differ — so the *divergences become declared and visible* rather
than being the accidental residue of two independently-edited switches.
Keep both switches exhaustive. The Mac's suite should ride unmodified,
which is this repo's own proof that a hoist moved an address and not a
behaviour. While in there, the phone's three inline copies of the gap-slot
sentence collapse to one.

**Suggested owner:** the mobile app project row, as an addendum to the
eight-brain row in `KnownIssuesAndTechDebt.md` — or **13u** if its item 5
seam rewrite touches this copy anyway, which is likely.

---

### MINOR 3 — `MobileEditorStyle.voice` is an unsynchronised mutable global that the test suite mutates while 81 of 86 suites run in parallel

**What it is.**

```
nonisolated enum MobileEditorStyle {
    nonisolated(unsafe) private static var storedVoice: ThemeVoice = .terminal
    static var voice: ThemeVoice { get { storedVoice } set { storedVoice = newValue } }
}
```

A process-global holding live UI state, with no actor isolation. The
comment asserts *"Main-thread written … main-thread read"*, but the enum is
`nonisolated`, so nothing in the type system enforces that claim — the
property is reachable from any isolation domain and the compiler will not
object.

**The traced mechanism, in the place it actually bites today — the test
suite.** `MobileBlockMenuTests.swift:132-133,157` mutates the global and
restores it with `defer`:

```
MobileEditorStyle.voice = .study
defer { MobileEditorStyle.voice = .terminal }
```

`MobileBlockMenuTests` is **not** `.serialized` (`:82`). Swift Testing runs
suites in parallel by default, and only **5 of 86** mobile suites carry
`.serialized` — and `.serialized` constrains a suite *internally*, it does
not stop other suites running concurrently with it. Meanwhile voice-dependent
rendering is real: `MobileCommentsSheetView.swift:320` is
`MobileEditorStyle.voice == .terminal ? text.lowercased() : text`, and
**eleven** non-serialized test files reference `chromeLabel` or
`lowercased()`. So a suite asserting terminal-voice lowercased chrome can
read `.study` mid-flight, through a global neither suite owns, and fail for
a reason that has nothing to do with what it tests.

`MEASURED`? **`READ-ONLY`.** I did not reproduce a flake. Reproducing a
parallel-execution race deliberately is expensive and I judged the
structural evidence — an unsynchronised global, mutated by a
non-serialized suite, read by eleven others — sufficient to report as a
hazard rather than as an observed failure. **If the suite has ever been
intermittently red on chrome casing, this is the first place to look.**

**Where:** `App/Variorum/VariorumMobile/Features/Write/MobileEditorStyle.swift:48-52`;
writers at `MobileWriteView.swift:141`, `MobileShellRouter.swift:59,67`.

**Why it matters.** `CLAUDE.md` is explicit: *"No global singletons;
everything flows through injected dependencies."* This is also the phone's
**third** home for voice state, beside `MobileVoicePreference` (the
UserDefaults truth) and the `VoiceTokens` passed down the view tree — and
the Mac's own `ThemeStore` is already named in the eight-brain row as *"the
clearest hoist in the file."* Any consolidation of voice state should know
this cache exists, or it will consolidate two of three homes.

**Remedy sketch (not a patch).** Two independent steps. (a) Cheap and
immediate: mark the mutating suites `.serialized`, or better, stop tests
mutating a global at all by having the affected helpers take the voice as a
parameter. (b) Structural: fold this cache into whatever owns voice state
when `ThemeStore` is hoisted, so the phone reads one home. Short of that,
`@MainActor` on the enum would at least make the comment's claim
compiler-enforced instead of aspirational.

**Suggested owner:** the mobile app project row for (a); the eight-brain
row's `ThemeStore` hoist for (b), so the two land together.

---

### MINOR 4 — Refusal presentation has ten homes and 71 raw `String(describing:)` dumps, against the project's own "refusals speak" doctrine

**What it is.** The phone raises errors to the user through **71**
occurrences of `String(describing: error)` (Mac: 63; `Shared/`: 10), and
maps `OperationError` to human sentences in **ten** separate
`refusal`/`refusalMessage` helpers, each with its own `default:` falling
back to a raw dump.

**The traced mechanism.** `OperationError.lockedPost` — one error — is
translated in **eight** places on the phone, into **five** different
sentences:

| site | sentence |
|---|---|
| `MobileComments.swift:153` | "This note is locked — unlock it to change comments." |
| `MobileBlockMenu.swift:369` | "This note is locked — unlock it to \(act)." |
| `MobileStructural.swift:848` | "This note is locked — unlock it to \(act)." |
| `MobileBlockHistory.swift:492` | "This note is locked — unlock it to \(act)." |
| `MobileUndoDoor.swift:276` | "This note is locked — unlock it first." |
| `MobileQuickNote.swift:141` | "This note is sealed, so it can't take new text…" |
| `MobileTakesBrowser.swift:566` | "This note is locked — unlock it to \(act)." |
| `MobileTakesController.swift:260` | *(distinct)* |

So one refused act reads five ways depending on which door she used —
including a "locked"/"sealed" vocabulary split. Everything not enumerated
in a given helper reaches her as a Swift enum description: e.g.
`MobileShelfViewModel.swift:64,74,106,116,192` and
`MobileLibraryViewModel.swift:111,127,165,190` assign
`lastError = String(describing: error)` with no mapping at all.

`MEASURED`? **`READ-ONLY`** (exhaustive grep across both targets, which is
exact for counts; no surface was driven to see a dump on screen).

**Why it matters.** This project's doctrine is that a refusal *speaks*, in
a human sentence, at the surface it happens on — raw dumps are a defect
here in a way they would not be in most codebases. And the codebase already
knows it: `Shared/RecoveryActs.swift:160`'s `DeletionRefusal` is documented
as *"the ONE deletion-refusal home (A1-18) — this table and the Trash's
covered different subsets of the same errors, so one refused act read two
ways depending on the door."* **That is this exact finding, diagnosed and
fixed for deletion and not generalised.** The remaining nine homes have the
same disease the consolidation was built to cure.

**Remedy sketch (not a patch).** Extend `DeletionRefusal`'s own pattern:
one shared home for the common `OperationError` vocabulary (`lockedPost`,
`lockedVariant`, `lockedReading`, `readingAtCapacity`, `gapSlot` …) with an
act/verb parameter for the tail, and let each door pass its verb rather
than restate the sentence. Settle "locked" vs "sealed" once while doing it.
The raw-dump fallbacks should stay — a genuinely unexpected error *should*
show something rather than lie — but the set of errors reaching one should
shrink to the genuinely unenumerated. A sweep test asserting that every
`OperationError` case a phone door can raise has non-dump copy would keep
it closed, mirroring how `RefusalCopy`'s exhaustive switch keeps the
planner side closed.

**Suggested owner:** the mobile app project row. Natural to fold into the
same batch as MINOR 2, since both are refusal-copy consolidation and would
otherwise touch the same files twice.

---

### NIT 1 — The crystallization loop is document-proportional on bulk entry

`MobileEditorViewModel.swift:1774-1779` calls `index.range(ofEntryAt:)`
inside `for (offset, block) in outcome.applied.enumerated()`, at indices
near the end of the tiling — so each call walks nearly the whole array.
With `applied == 1` (ordinary type-time crystallization) this is a single
O(N) walk per completed paragraph and costs nothing measurable. On **bulk
entry** — paste or import, where `applied` can be large — it is
O(applied × N).

`READ-ONLY`. Same remedy as MINOR 1 and it falls out for free once
`BlockRangeIndex` exposes precomputed ranges; listed separately only so the
sweep does not miss it. **Suggested owner:** 13u item 8, with MINOR 1.

### NIT 2 — `Write` and `Takes` are one feature in two folders

`CLAUDE.md`'s "one feature = one module, cross-feature interaction routes
through parent composition" is honoured in substance —
`MobileEditorViewModel` composes its siblings (`takes`, `takesBrowser`,
`comments`, `structural`, `blockMenu`, `blockHistory`, `undoDoor`) and the
views route through it. But those siblings are split across
`Features/Write/` and `Features/Takes/`, which reference each other's types
in both directions, so the folder boundary does not correspond to a module
boundary and reads as coupling when it is composition.

`READ-ONLY`. Cosmetic; no behaviour depends on it. Worth a rename or a
merge only if someone is in there anyway. **Suggested owner:** the mobile
app project row, opportunistic.

---

## 3. Already owned — confirmed still true (so nobody re-derives them)

- **The Read surface realizes every paragraph of a realized note.**
  `MobileReadView.swift:140` renders `ForEach(paragraphs)` in a plain
  `VStack`; the `LazyVStack` above it is lazy per **note**, not per
  paragraph, so one realized 100k-word note builds ~1,400 `Text` views.
  **This is already measured and owned** —
  `MobilePerfWalkTests.swift:889` `theReadSurfaceAtTheHundredKBarIsMeasured`
  is deliberately measure-only, states *"NO OPTIMIZATION IS BUILT HERE AND
  NO BUDGET IS ASSERTED"*, and already records the candidate remedy (a
  per-note paragraph cap wearing the visible-truncation grammar). Nothing
  to add; I confirm the shape is unchanged.
- **13l's L-c and L-d both genuinely landed.** I checked rather than
  trusted the handback: `AppBootstrap.init` now calls `beginOpening()`
  which runs the open in a `Task` with the roots rendering `.opening`
  (`Shared/AppBootstrap.swift:120-139,169-175`) — the synchronous
  main-thread migration set before first paint is gone; and
  `AppSession.postAutosaves` is now a refcounted `Hold` with
  `releaseAutosave(forPost:)` (`Shared/AppSession.swift:125-247`), **and
  the caller that motivated it actually calls it** —
  `MobileQuickNote.swift:954`, inside `reset()`, on both the hand-off and
  withdrawal roads.
- **The `planVisibleTakeEdit` O(N²) row is accurate about its scope.** It
  is Mac-only (`EditorSurfaceController.swift:1816`); the phone routes
  through the already-fixed hoisted `CrossBlockEditPlanner`. MINOR 1 above
  is a **different** site, so the row does not cover it.
- **The frozen-projection fan fence** (13u item 8) applies to the phone
  identically — `MobileEditorViewModel.swift:1364` and
  `MobileStructural.swift:351` pass `slots.map(\.activeVariantCount)`,
  and `slots` is the deliberately-frozen projection. Already owned by 13u;
  noted only to confirm it is both-platform.
- **The eight-brain fork row** is still live and still accurate.
  MINOR 2 and MINOR 3 above are **additions** to it, not restatements.

---

## 4. What I could not settle, and the experiment that would

1. **Whether MAJOR 2's liveness race actually fires in her hands.** The
   mechanism is clear from reading, but races need driving.
   **The experiment:** a mobile pin that registers an editor on tab A,
   injects a stalled `flushNow` (the harness already injects an autosave
   `sleep`), fires two `tabDoor` switches back to back, then asserts
   `authority.live` matches the final `tab` and that no non-live editor has
   `isEditable == true`. It should go red on today's code. That pin is
   worth more than the fix, because it is what stops the shape returning.

2. **Whether MAJOR 1's double-tap window is wide enough to hit by hand.**
   I established that the door is open for the length of one write
   transaction; I did not measure that transaction or attempt a double tap.
   **The experiment:** time `createReading` through `runner.run` on device,
   then drive two taps within it in a UI test. Note that the *remedy* does
   not depend on the answer — layer 2 (the guard inside the transaction) is
   owed anyway via PL-10(b) — so this experiment sets priority, not
   direction.

3. **Whether the test suite has ever flaked from MINOR 3's global.** I
   found the hazard structurally but have no failure history.
   **The experiment:** cheaper than reproducing the race — run the mobile
   suite repeatedly with parallelism forced high and watch for
   chrome-casing assertions failing non-deterministically. If the suite has
   a known intermittent, checking whether it is voice-dependent would settle
   this in one look.

4. **Read-mode memory at the 100k bar on a real device.** The existing pin
   measures the store read, the join, and the paragraph transform, and
   prints the footprint across them — but it explicitly does not measure
   what SwiftUI holds once ~1,400 `Text` views are realized, and a simulator
   would not be trustworthy for that anyway. **The experiment:** open the
   seeded mega-post in Read on her device with Instruments attached. This is
   the one item here that genuinely needs her hardware, and it is the same
   device-only class as PL-15's outstanding Face ID walk — worth batching
   with it rather than scheduling separately.

5. **The 20 unlatched doors beyond create-book.** I verified the *class* by
   grep and traced one member end to end; I did not trace the other
   nineteen individually, and some will be safe by their operation's
   idempotence the way `MobileTodayDoor` is. **The experiment:** a
   door-by-door pass giving each a verdict of *latched*, *safe by op
   idempotence* (naming which op and why), or *needs a latch*. That sweep is
   the actual deliverable; my finding only establishes it is owed.

---

*Findings only. No `.swift` file was modified, no fix was applied, and no
agent was spawned to apply one.*
