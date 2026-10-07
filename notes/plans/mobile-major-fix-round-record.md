# The MAJOR fix round — five findings, five dispositions

*Written 2026-08-30 by the implementer of the round. Its subject is the
five MAJOR findings carried by three review documents:
`notes/plans/mobile-architecture-review.md` (MAJOR 1, MAJOR 2),
`notes/plans/mobile-batch-5-cold-review.md` (the starter-Journal seed), and
`notes/plans/mobile-batch-6a-cold-review.md` (M1, M2).*

**Counts at the end: mobile 582/93 green · core 1453/154 green.** (Baselines
568/92 and 1453/154; the round adds 14 pins in 1 new suite and changes no
core test.) **The Mac suite was not run and no claim is made about it,
because no Mac file was touched** — `git status` over `App/Variorum/Variorum`,
`App/Variorum/Shared` and `App/Variorum/VariorumTests` is empty, and
`VariorumMobile` is its own `PBXFileSystemSynchronizedRootGroup`, so nothing
in this diff is compiled into the Mac target.

**Rails held:** zero `Sources/` lines (`git diff -- Sources/` is empty), zero
`Sync/`, no schema, marker still 7, no build-configuration file,
`App/Variorum/Shared/EditorBrain/` and the cross-block planner untouched.

---

## How the reds were proven

Every fix below landed with a pin, and **every pin was proven red by
reverting the fix's behaviour and running it** — not by reasoning that it
would fail. Three of the five pins compile unchanged against the pre-fix
code and were run against it directly. Two (B1, A2) required a signature
that did not exist before, so the revert removed **only the behaviour**,
keeping the signature, which is the same evidence with none of the noise.
The exact failure text is recorded per finding.

**One pin was caught being hollow and was rewritten.** The first C1 pin
asked the label `sizeThatFits` how tall it wanted to be — and `UILabel`
honours `numberOfLines` in that answer, so a truncated label reported
exactly its truncated height and the pin passed on the pre-fix code. It is
recorded here rather than quietly fixed, because it is the hallucination
guard working in the direction it is usually not: the fix was real and the
*pin* was the thing that wasn't.

---

## B1 — the starter Journal seeded before sign-in was possible · **FIXED**

*(`mobile-batch-5-cold-review.md`, MAJOR. Taken first because it is the one
finding here that could write to her real synced corpus.)*

**Traced, and confirmed.** `MobileStarterJournal.seedIfNeeded` decides "this
store is new" from two purely LOCAL reads (`Queries.readings` +
`Queries.library(limit: 1)`), and it was invoked from a `.task` on
`MobileShellView` — a sibling of the `.task` in `VariorumMobileApp` that
constructs `AppServices` and awaits `start()`. The two are concurrent and
unordered, and the race is not close: the local read is milliseconds, a
first pull is a network round trip. The review's point 4 is the sharper
half and it holds — the only surface offering sign-in
(`Shared/AuthViews.swift`, reached through `MobileSettingsView`) lives
*inside* the shell whose appearance fires the seed, so on a fresh install
there is no ordering in which sign-in precedes it.

The consequence is what makes it a MAJOR rather than a cosmetic mis-order:
`reading`, `reading_post` and `container` are synced tables with trigger-fed
outboxes (SyncSpec §3), so the spurious book, its designation, its shelf pin
and its note are ordinary inserts that propagate to every device on the
account. The `daily_journal_book` designation converges back to hers by CAS,
but **the duplicate book does not converge away** — nothing in SyncSpec §6's
matrix or §7's repairs touches it, and by design nothing should.

**The fix.** The gate the review named, built over the machinery it named.

- `MobileStarterJournal.SyncGate` carries two facts — *does this store
  belong to an account* and *has a round finished cleanly* — injected as
  closures, so the seeder never learns what a scheduler is and a pin drives
  every state without composing a transport.
- The production gate reads `sync.isConfigured || account.variorum != nil`
  and `sync.status.lastSuccessAt != nil`. The **account** half matters:
  `connectSyncIfAllowed` returns before `sync.configure` when owner adoption
  fails, so `isConfigured` alone would read `false` on a signed-in device
  whose chain never composed — the unsafe direction.
- Order inside `seedIfNeeded`: the cheap local `storeIsNew` first (so the
  wait is never paid on an ordinary launch), then — only if the store
  belongs to an account — a bounded wait for the first clean round, then
  `storeIsNew` **again**. A timeout returns the new `.awaitingFirstSync`
  and **does not set the mark**, so the next launch simply asks again.
- The wait POLLS rather than subscribing, deliberately:
  `SyncSession.onRoundCompleted` is a **single** closure already owned by
  `AppServices` (it is what triggers the Fragments bridge after every
  round). A second subscriber would have to displace the first, and
  furniture must not be able to break the bridge. The cost is one cheap
  main-actor read every 100 ms, on a virgin store only, at most once per
  launch.
- The call site **moved** from `MobileShellView` to `VariorumMobileApp`'s
  own task, **after `await fresh.start()`** — which is where the sign-in
  question is settled (`start()` awaits `auth.currentUserID` and
  `connectSyncIfAllowed`). This also removes the concurrency the review's
  point 2 named, rather than gating around it.

**Pins** (`MobileStarterJournalTests`, four new):
`aSignedInDeviceDeclinesUntilItsFirstCleanRound` ·
`herCorpusArrivingDuringTheWaitCancelsTheSeed` (the finding's own script) ·
`anEmptyAccountStillGetsTheBookOnceSyncHasSpoken` (the gate defers the
question, it does not answer it in the negative) ·
`aDeviceWithNoAccountSeedsWithoutWaiting` (a first launch must not wait on a
network nobody is using).

**Proven red** — gate removed, signature kept:

```
✘ aSignedInDeviceDeclinesUntilItsFirstCleanRound
    (outcome → .seeded(readingID: "0000…0000")) == .awaitingFirstSync
    (mark.seeded → true) must be false
    (books → [Reading(name: "Journal", profile: "journal", …)]).isEmpty → false
✘ herCorpusArrivingDuringTheWaitCancelsTheSeed
    (books.count → 2) == 1
```

`books.count → 2` is the duplicate Journal, exactly as the review described.

### The residual, and it is hers

A genuinely fresh install where nobody is signed in seeds at once — correctly,
because the store really is this device's — and if she **then** signs into an
existing account from Settings, her own Journal arrives beside the starter
one. **The gate cannot close that**, because the sign-in door lives inside
the shell the seed launches with. Closing it needs a product decision — an
explicit first-run moment she can see, or a post-sign-in reconciliation —
and that is the review's own "alternative worth weighing at the same call".
It is recorded in the file's header as the second honest residual.
**What the gate does close is every case where the account was already known
at launch** — the reinstall, the second device, the ordinary relaunch — which
is the one that reaches her real corpus with her doing nothing at all.

---

## C2 — a fanned block reported "one take" and drew no take sections · **FIXED**

*(`mobile-batch-6a-cold-review.md`, M2.)*

**Traced, and confirmed.** `MobileBlockHistoryController.rows()` routed on
`history.isEmpty`, and `Queries.BlockHistory.isEmpty`
(`Sources/VariorumCore/Queries/EditorSupport.swift:252`) is
`takes.allSatisfy { savepoints[$0.id]?.isEmpty ?? true } && archivedTakes.isEmpty
&& deletedTakes.isEmpty && origins.isEmpty` — **it says nothing about how many
live takes there are.** So any block she had fanned and not yet committed —
the everyday state after `branchVariant` — fell down that arm and was
answered with *"This block has no past yet: **one take**, no saved moments,
nothing set aside, and nothing it came out of."* A false count, and every
take section hidden, on the one surface whose whole thesis is honest
reporting.

**The fix, and exactly how far it converges to the Mac.** The sentence is now
reserved for the case where it is TRUE: `if history.isEmpty, active.count <= 1`.
Above one take, region 1 draws with one header per live take — which is what
the Mac does (`BlockHistoryPane.swift:475` guards `nothingHere` on
`activeTakes.isEmpty` and draws its take sections unconditionally).

**Where I stopped short of literal convergence, and why — this is a
one-line taste call for the author.** Copying the Mac's guard verbatim would
also retire the sentence for the ORDINARY one-take, no-history block, which
would then show a Savepoints header plus a collapsed "this take · 0" row
instead of the calm one-line answer the phone shipped with. I did not do
that, for three reasons: I10 makes the Mac's branch practically unreachable,
so there is no reachable Mac behaviour to converge *to* in that state; the
sentence is true there; and it would require rewriting the existing green pin
`anOrdinaryBlockHasNoPastAndTheCopySaysWhat`, i.e. changing shipped face
behaviour nobody ruled. **Every reachable multi-take state now matches the
Mac.** If she wants the calm sentence gone entirely, it is one line and one
pin.

**Pin:** `aFannedBlockShowsItsTakesInsteadOfClaimingItHasOne` — seed a block,
`branchVariant` it, commit nothing, assert two `.takeHeader` rows, the
Savepoints section drawn, and `nothingHere` absent.

**Proven red** (the guard reverted; the pin compiles unchanged on old code):

```
✘ !(rows.contains(.quiet("This block has no past yet: one take, …"))) → true
✘ (sectionTitles(rows) → []) == ["Savepoints"]
✘ (takeHeaders.count → 0) == 2
```

---

## A1 — twenty write doors with no in-flight latch · **PARTLY DISMISSED WITH EVIDENCE, PARTLY FIXED**

*(`mobile-architecture-review.md`, MAJOR 1.)*

### The finding's sharpest case no longer reproduces — and this is a real correction

The review's headline outcome is *"two books with the same name"*, and its
evidence is *"`assertBookNameIsFree` … the phone calls it at **zero**"*.
**That was true when the review was written and is not true now.** The guard
landed at `66606c0` ("4.5d's fix round … plus PL-10(b), the duplicate-book-name
guard the phone never had"), and `git merge-base --is-ancestor 66606c0 <the
review's commit>` answers **NO** — the review predates it. The call sits
**inside the runner closure** at all three arms of
`MobileCreateBookModel.create`, exactly where the review's own layer 2 asked
for it and exactly where the six Mac sites put it.

I did not take that on trust. Driven on the pre-latch tree, a concurrent
double tap on this door produces **one book** — the second flight's
`assertBookNameIsFree` throws inside its own transaction. So **the
duplicate-book outcome is closed, and it was closed by the layer beneath the
door, not by anything in this round.**

### What genuinely remains, traced door by door

The review's own caution is the discipline here — *"not every unlatched door
is a bug"* — so I did not sweep twenty files. A door is only a defect when a
second flight **mints a second row with nothing beneath it to notice**:

| door | second flight | verdict |
|---|---|---|
| `MobileComments` (`addBlockComment`) | a second identical comment | **defect** — `block_comment` has NO uniqueness BY DESIGN (AppSpec §7: a note has no natural key), so nothing beneath the door can ever catch it |
| `MobileTakesBrowser` branch / blank | a second take in the fan | **defect** — the fan is a list; `branchVariant` has no arm that could notice |
| `MobileCreateBook` | refused by core | **outcome safe**; the remaining harm is a refusal shown for a gesture made once |
| `MobileTodayDoor` | opens rather than mints | **safe by the operation** — the review says so and it is right |
| `MobileMembership`, `MobileTagManager`, tag/edge/reading-membership doors | refused by a live-unique index or an `alreadyInReading` guard | **outcome safe** |
| `choose` / `setTakeLabel` / lock toggles | last-write-wins on one row | **not a duplication class** — a latch there would only hide a second tap that changed nothing |
| `MobileLenses.adoptView` *(added 2026-08-30 by the Fable sweep, finding 1)* | a second preservation lens | **defect** — the `lens` table has no uniqueness (the only lens-side live-unique index is `uq_lens_choice_live` on `(lens_id, block_id)`), and `adoptPicksPreservingChosen` inserts its preservation row UNCONDITIONALLY, ahead of any pick validation. **LATCHED at the Opus fix round the same day** |

### The fix

`App/Variorum/VariorumMobile/Features/Shell/MobileWriteLatch.swift` — the
latch `MobileStructural`, `MobileUndoDoor` and `MobileBlockMenu` each
hand-rolled, in one place, so the twenty-first door does not hand-roll it
again. It is a **UI-turn latch, not a lock**: `SerializedRunner` already
guarantees two writes never interleave in the store; what it cannot know is
that the second write was never *asked for*. That is the door's question, so
the door answers it. A declined flight returns `nil`, distinguishable from a
refusal, so it is never reported as one; a `defer` clears the latch on every
road out, including a thrown one — a door that can wedge shut would be worse
than the duplicate.

It is **phone-local, not `Shared/`**, deliberately: the Mac's doors are not
SwiftUI `Button { Task { … } }` over these models, and batch 6a's own m5
finding is about a shared home carrying things only one platform uses.

Adopted at the three doors above (`MobileComments.run` — one funnel covering
all five comment verbs; `MobileTakesBrowser.branchDisplayed` and `mint`;
`MobileCreateBookModel.create`) — **and, since the Fable sweep's finding 1
the same day, at a FOURTH: `MobileLensesModel.adoptView`** (see the table
row and the correction below). `saveIntoActiveLens` is deliberately left
unlatched beside it: its upsert-and-clear writes converge, so a second
flight lands the same state.

**Pins** (`MobileWriteLatchTests`, six new): the latch's own contract and its
clear-on-exit, plus the three doors driven with two real concurrent `Task`s —
the review's traced mechanism literally.

**Proven red** (latch adoption reverted at all three doors; the pins compile
unchanged on that code):

```
✘ twoTapsOnAddCommentLeaveOneComment      (count → 2) == 1
✘ twoTapsOnBranchLeaveOneNewTake          (takes → 3) == 2
✘ twoTapsOnBlankTakeLeaveOneNewTake       (takes → 3) == 2
✘ twoTapsOnCreateBookLeaveOneBookAndNoRefusal
      (model.lastError → "A book named “Fieldwork” already exists — pick a
       different name, or rename that one first.") == nil
```

The last line is the correction stated as evidence: **one book**, and a
refusal for a gesture she made once.

**The fourth pin, added 2026-08-30 with the sweep's finding-1 fix**
(`twoTapsOnAdoptLeaveOnePreservationLens`), proven red the same way — the
latch removed from `adoptView`, the pin compiling unchanged:

```
✘ twoTapsOnAdoptLeaveOnePreservationLens   (preservations → 2) == 1
```

### Left open, and it now has this file to point at

Sixteen other unlatched files remain unlatched, on purpose. The table above
verdicts the classes; what has NOT been done is a per-door trace of every one
of them. Each is either safe by its operation or costs a refusal message at
worst.

**⚠️ CORRECTION, 2026-08-30 (the Fable sweep, finding 1 — ACCEPTED, zero
disputes).** This paragraph used to end *"and none of them can mint an
uncaught duplicate row by the reasoning above"*. **That universal sentence
was false, and the hedge beside it — "that reasoning is a class argument, not
seventeen traces" — is exactly why.** `MobileLenses.adoptView` was on the
review's own twenty-file list, was never classified in the table above, and
mints an uncaught duplicate preservation lens on a double tap. It is now
latched and pinned (the table row + the pin above); the count above dropped
from seventeen to sixteen with it. **The rule this leaves behind: a class
argument may be stated as a class argument and never as coverage.** The
remaining sixteen are still un-traced, and a mobile batch adopting the latch
as it touches each door is still the right shape.

**One door is safe only by its HOST, and the next batch to touch it must
know that.** `MobileBlockHistory.commitNow` appends a savepoint with no
dedupe — manual `commit` always inserts (`Operations+Variant.swift:38-58`) —
so a second flight would leave two savepoints of one moment. Today its ONE
caller is a `UIMenu` action (`MobileBlockMenu.swift:156-158`), which dismisses
on the first tap, so the door cannot fire twice. **If batch 6b or 9 gives the
Block History sheet its own commit BUTTON, that door needs the latch** — a
persistent `Button { Task { … } }` removes the only thing protecting it.

---

## A2 — the tab-switch liveness handoff applied out of order · **FIXED**

*(`mobile-architecture-review.md`, MAJOR 2. The reviewer judged "the pin is
worth more than the fix"; both are here.)*

**Traced, and confirmed.** `MobileShellView.tabDoor` assigns `tab`
**synchronously** and hands the liveness handoff to an unstructured `Task`
carrying the `target` it captured at spawn. That task awaits
`quickNote.fileOnLeaving()` (writes) and then
`editors.tabDidBecomeVisible(target)`, which awaits
`editor.autosave.flushNow()` and `editor.refreshTakesFromStore()` before
`noteLivenessGranted()`. Four suspension points of database work, two
independent tasks, and **nothing capturing an order** — so on two quick taps
the task that finished LAST installed the liveness that stood.

Both wrong end states are the ones this authority exists to forbid: the
**visible** editor stood down (she taps into her note and cannot type), or a
**hidden** editor holding the pen — which the file's own header calls the law
it enforces. The same shape reaches `register`, which awaits inside
`takeLiveness` too.

**The fix.** A monotonic `handoffGeneration` on the authority. `beginHandoff()`
mints the newest token and is called **synchronously at the tap, in the same
turn as the `tab` assignment**, so the order of REQUESTS is fixed before any
task runs. `tabDidBecomeVisible` and `takeLiveness` take that token and check
it **at entry and after every suspension**; a grant that finds a newer token
abandons itself and installs nothing. `register` mints its own token, because
a push IS a request for the pen. The token parameter defaults to nil (mint
one here), which is right for a caller with nothing to race and keeps every
existing call site and pin unmodified — that the whole existing liveness suite
rides untouched is the proof this changed an ordering and not a behaviour.

**Pins** (`MobileLivenessTests`, two new):
`theLastRequestedTabWinsEvenWhenTheStaleHandoffLandsLast` and its mirror.
They drive two handoffs REQUESTED in order with the stale one COMPLETING
last — the ordering a stalled flush produces. **Ordering is expressed through
the tokens rather than by racing a real database, deliberately: a pin about
ordering must not itself depend on timing to fail.** The user-visible half is
driven through the real gate — `typeEdit` on the visible editor must succeed
and on the hidden one must be refused — so the pin holds *"I tap into my note
and it won't let me type"*, not merely a flag.

**Proven red** (the three `isCurrent` guards removed, every signature kept):

```
✘ theLastRequestedTabWinsEvenWhenTheStaleHandoffLandsLast
    (editors.live) === (shelfEditor)          → failed
    shelfEditor.isLive → false
    !(libraryEditor.isLive → true)            → failed
    typeEdit(shelfEditor, …)                  → failed   ← she cannot type
    !typeEdit(libraryEditor, …)               → failed   ← the hidden pen
✘ theMirrorHoldsToo_libraryRequestedLastKeepsThePen   (3 issues)
```

---

## C1 — both long section explainers truncated · **FIXED**

*(`mobile-batch-6a-cold-review.md`, M1.)*

**Traced, confirmed, and independently re-measured.** `MobileBlockHistoryCell`
set `metaLabel.numberOfLines = 2` once in `init` and never again; the
`.sectionHeader` case puts the region's *explainer* in that label; and
`heightForRowAt` returned a fixed **52pt** for every section header. The
review's "jointly wrong" claim is exact — and my measurements on the assigned
simulator land within a percent of its table:

| explainer | review says | measured here | gets |
|---|---|---|---|
| `BlockHistoryPath.explainer` (Savepoints) | 41.3pt | **41.17pt** | 27.67pt |
| `OriginPeekCopy.explainer` (Came from) | 55.0pt | **54.89pt** | 27.67pt |

What was lost is not decoration: the Savepoints tail names the fourth region,
and the Came-from tail is the sentence explaining the **Bring back** button
rendered inches away.

**The fix, both halves.**
- `configure` now **resets both line caps on every call** — the recycled-cell
  rule this file's own header states, which `init`-once quietly broke — and
  the `.sectionHeader` case sets `metaLabel.numberOfLines = 0`.
- `heightForRowAt` **measures** section-header rows through
  `MobileBlockHistoryCell.sectionHeaderHeight`, which is `layoutSubviews`'
  arithmetic run ahead of time: same fonts, same `chromeCase` transform, same
  12pt insets and 4pt padding, no act button. Every other row kind keeps its
  pure `Row.height` pitch, which is what keeps this table cheap.
- `Row.height`'s 52 survives as `Row.sectionHeaderFloor`, so short headers
  keep the shipped rhythm and only the long explainers grow.

**Pin:** `bothLongExplainersFitTheRowsTheSheetGivesThem` — on the REAL mounted
sheet in a key window at 402pt, through the REAL delegate height and the REAL
cell layout, for **every** section header the face draws, with the cell
configured as a `.takeHeader` first so it arrives out of the recycle pool
wearing another row's caps.

**Proven red, twice, because the two constraints are independent:**

```
# both halves reverted
✘ (cell.metaLabel.numberOfLines → 2) == 0
✘ (cell.metaLabel.bounds.height → 27.67) >= (needed - 0.5 → 40.67)   # Savepoints
✘ (cell.metaLabel.bounds.height → 27.67) >= (needed - 0.5 → 54.39)   # Came from

# ONLY the row height reverted — the line cap fixed
✘ (cell.metaLabel.frame.maxY → 62.33) <= (contentView.bounds.height + 0.5 → 52.5)
✘ (cell.metaLabel.frame.maxY → 76.0)  <= (contentView.bounds.height + 0.5 → 52.5)
```

`titleLabel` and `metaLabel` moved from `private` to internal for one reason,
stated at the declaration: a silently truncated explainer is invisible to a
`rows()` pin and to a subview census, so the only way to hold *"the sentence
really fits"* is to read the laid-out label.

### The hollow pin, recorded

The first version of this pin asked `cell.metaLabel.sizeThatFits(…)` for the
height it needed. **`UILabel` honours `numberOfLines` in that answer**, so a
label capped at two lines reported exactly its two-line height and the pin
passed on the pre-fix code — a fix that was real, with a pin that proved
nothing. The corrected pin measures the text's unbounded height independently
via `NSString.boundingRect` with the label's own font, and additionally
asserts `numberOfLines == 0`. The trap is worth naming for the next person:
**never ask the truncating view how much it needs.**

---

## Things I found that are not mine

1. **`m3` is still open and I deliberately did not fix it.**
   `MobileBlockHistoryCell.configure` sets `metaLabel.textAlignment = .right`
   in the `.takeHeader` case and never resets it, so a recycled cell can wear
   another row's alignment — the same recycling class as M1, one line from the
   line-cap reset I did add (`metaLabel.textAlignment = .natural`). It is a
   MINOR and outside this round's five; doing half of a neighbour's finding
   invites the question of why the other half. **Named here so it is not
   re-derived.**

2. **`mobile-architecture-review.md`'s MAJOR 1 needs a correction note.**
   Its "the phone calls it at zero" was true at the tree it read and false at
   `HEAD`, because `66606c0` landed the guard afterwards. The review is not
   wrong about the class; it is stale about the sharpest instance. A reader
   coming to it cold should be pointed at this file.

3. **The stray `project.pbxproj` reorder was left unstaged, as instructed.**
   It is 2 lines and is not mine.

4. **The pre-existing `MobileStructural.swift:91` warning** (`immutable value
   'intra' was never used`) is untouched and predates this round.
