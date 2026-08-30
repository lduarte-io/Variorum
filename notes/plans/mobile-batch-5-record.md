# Mobile Round 2 — BATCH 5 RECORD (the shelf layout)

*Written 2026-08-30 by the batch-5 implementer, in its own worktree
(`worktree-agent-a482cba77d19d2fff`, off `main` at `299afe5`). This file
is deliberately a NEW file: `mobile-round-2.md` is another agent's.*

**Her complaint, twice, and the reason this batch exists:** *"I still see
today's entry where i don't want it and the quick note where i don't want
it."*

---

## 0. THE HEADLINE NUMBERS, up front

> **⚠️ THIS FILE COVERS TWO PASSES.** The first built R26/R27/R27b. She
> then read the result and ruled two refinements — **the box is one line
> until she clicks into it**, and **the shelf is bounded so there is
> always decent room to write** — which are §7 below. The numbers in this
> section are the FINAL ones.

| | |
|---|---|
| mobile suite | **556 tests / 91 suites — PASSED**, exit 0, zero restarts (baseline 513/86 ⇒ **+43 tests, +5 suites**) |
| `git diff -- Sources/` | **empty** |
| `Shared/` lines | **zero** — so the Mac suite is unaffected by construction |
| `Sync/`, schema, marker | untouched; marker stays **7** |
| **§53 row 7's answer** | a capture's mint costs **6.8 ms** against a bare store and **5.9 ms** against the full 100k-word / 300-note / 6-book corpus — **ratio 0.87×, FLAT.** No fix earned |
| **R27.3, measured** | the writing region renders **466 pt of a 932 pt phone = exactly 50.0%** |
| **§53 row 6, measured** | in a keyboard-sized room (596 pt) the writing region holds **254 pt (42.6%)** and the BOOKS shrink 378 → 254 |

**Simulator note, and it is a correction to the brief.** The brief named
*[removed for publication]*
on **iOS 18.3**, below this app's iOS 26 deployment target, so `xcodebuild`
does not list it as a destination for the `VariorumMobile` scheme at all —
nothing can run there. **Every iPhone 16-series simulator on this machine
is 18.3 and therefore invalid for this project.** The 18.3 device was left
booted and armed, untouched.

**All FINAL results here were produced on iPhone 17
*[removed for publication]*
*[removed for publication]*
then reassigned this batch off that device because **two agents sharing one
simulator contaminate each other invisibly — same bundle id, last installer
*[removed for publication]*
it, so no result in this file depends on the shared device.

*(Geometry pins host the surface at an explicit 430 × 932 — iPhone 16 Pro
Max points — so the simulator's own screen is not what they measure.)*

---

## 1. WHAT SHIPPED

### R26 / R27 — the layout (`MobileShelfLayout.swift`, new; `MobileShelfView.swift`)

The shelf is now, top to bottom: **path line · the bounded books region ·
the quick-note box · status rows · tab bar.** The proportions are a pure
brain rather than a pile of modifiers, because she ruled a RULE:

- **`visibleBookRowCap = 8`** — her *"more than ~8 books … you have to
  scroll through the books"*. Past it the LIST scrolls inside itself.
- **`maximumBooksShare = 0.5`** — her *"about half the phone screen"*.
- **`minimumWritingHeight`** — a floor, so a small phone or a keyboard
  cannot reduce the box to a line. When the floor bites, the books yield
  further. *(Her 2026-08-30 ruling raised this to a GUARANTEE and
  re-derived it from lines — 140 pt. See §7b.)*
- `split(region:bookRows:starredRows:extraRows:writing:)` **partitions the
  region exactly** (`books + writing == region` for every input, pinned).

The region itself comes from a `GeometryReader` wrapped around exactly the
books+writing area, so it already carries the safe areas, the path line,
the status rows, the tab bar **and the keyboard's inset** — the brain never
guesses at any of them.

The quick-note box takes the whole writing region and its field wraps into
it (`writingLineCap`, derived from the region so it fills a big phone and
cannot overflow a small one). **⏎ is unchanged** — A5-1/A5-2 are untouched;
this is wrapping, never several paragraphs.

### R26.2 / R26.3 — Today's Entry is a badge

`✎ today` now rides the **daily journal book's own row** as a small
bordered badge (measured **65.7 pt wide** against the old door's 390 pt),
with **no blinking cursor** — the blinking block is the terminal voice's
quick-entry idiom and it went home to the quick-note box, which is now the
only place it renders.

**§40's open consequence, answered (implementer proposes → recorded here
for the architect):** when NO row on the shelf can carry the badge — a
fresh account with no Journal, or one she deleted — the door falls back to
**its own row at the end of the books list**. One rule, one fallback,
reachable in every state, and inside the bounded region so it can never eat
the writing area. Pressing it there runs the ordinary core path, which
creates and pins a Journal when none is designated (AppSpec §9, her 13d
#37(iii) ruling) — so a shelf gets its Journal back *by her asking*, never
by the app putting furniture back.

### R27b — the starter Journal (`MobileStarterJournal.swift`, new)

A genuinely new store gets a **Journal** book (curated · `profile:
'journal'` · `entry_date` ascending · designated daily · shelf-pinned —
byte-identical in shape to the core's own first-press creation) holding
**one** introduction note.

**Seed once, never re-seed**, which is the whole difficulty of her second
clause. A discover-by-name seeder — the `MobileTutorialSeeder` shape —
would put the book back the moment she deleted it, which is exactly what
she ruled out. **Two independent guards**, each pinned on its own:

1. a **per-store-variant `UserDefaults` mark** (the `IdleCommitScheduler`
   precedent — debug and release share a defaults domain, so an unscoped
   key would let a dev-store seed suppress her real store's), written only
   *after* the seed lands;
2. a **virgin-store guard** — no live book AND no live note. This is what
   protects a phone syncing an existing account down, and it makes a seed
   interrupted by an app kill safe to re-attempt without ever minting a
   second Journal.

It runs from `MobileShellView`'s `.task`, not the shelf view's,
deliberately: several suites host the shelf alone, and furniture must not
appear inside a pin's world.

### R24 — **NOT DONE. Fenced, and this is the one scope item I did not deliver.**

R24 lives entirely in `Features/Write/`, which the brief explicitly
forbids. I did not reach across. **The whole change is three sites:**

| file:line | now | R24 |
|---|---|---|
| `Features/Write/MobileReferences.swift:52` | `count == 0 ? "more info" : "more info · \(count)"` | `"info"` / `"info · \(count)"` |
| `Features/Write/MobileReferences.swift:185` | `Text(tokens.chromeLabel("More Info"))` | `"Info"` |
| `Features/Write/MobileWriteView.swift:424` | `.accessibilityLabel("More Info")` | `"Info"` |

Two pins move with it: `MobileReferencesTests.swift:160-161`.

---

## 2. VERIFICATION — WHAT WAS DRIVEN, AND HOW

### The red-on-old, established by reverting ONE file

`MobileShelfView.swift` was checked out to `HEAD` (the new brain, faces
constants and view-model additions are all additive, so the old view still
compiles against them) and the new pins were run against it. **This is
measured evidence, not an argument:**

| pin | on the OLD tree | on the NEW tree |
|---|---|---|
| `quickNoteSitsBelowTheBooks` | **field.minY 98 vs books maxY 286** — the box sat ABOVE the books, which is her sentence | field.minY 350, books end 244 ✔ |
| `theWritingRegionIsGenerousOnARealShelf` | writing region 14 pt | **466 pt = 50.0% of the screen** ✔ |
| `writingKeepsItsShareUnderAKeyboardSizedRegion` | 14 pt | **254 pt = 42.6%**, books 378 → 254 ✔ |
| `fortyBooksDoNotMoveTheWritingField` | 14 pt | 466 pt, books capped at 378 ✔ |
| `theDoorIsABadgeAndNotAFullWidthButton` | **badge width 390 pt**, 100.5 pt away from the Journal row | **65.7 pt**, on the row ✔ |

`theRowHeightConstantsMatchWhatRenders` passes on BOTH sides — it is a
constants-drift guard, not a bug pin, and it is labelled as such rather
than counted as evidence.

### Three things the pins caught that reading would not have

1. **The label match was case-sensitive and the terminal voice lowercases
   chrome.** `contains("Ledger")` found nothing, so the positional pin
   failed *for the right-looking wrong reason* — the round's own
   green-over-nothing class, inverted. Caught precisely because the
   red-on-old exercise was run rather than asserted.
2. **The "Quick note" accessibility element is NOT the writing region** —
   it reports the text view's own one-line box (14 pt) sitting at the top
   of the area. A throwaway view-tree probe established this; the pins now
   measure the real `UIScrollView` (the books region) and derive the
   writing region as the residual, which is also the honest measurement of
   the SPLIT that R27 actually rules. The probe was deleted.
3. **A book row's accessibility frame was 17 pt against a 39 pt row**,
   because my first draft moved the row's padding outside the Button. Fixed
   by putting the padding back **inside the button's label** — which is
   also the better product answer: the whole row height is the tap target
   again.

### §53 row 7 — the mint measurement (`MobileShelfPerfTests.swift`, new)

Reuses `PerfWorlds`' existing big/small worlds (the ~100k-word mega post +
300 notes across six books, against 12 notes and no mega post), so this
file costs the suite nothing beyond its own legs.

```
PERF[sim] quick-note MINT — bare corpus 6.810 ms · full corpus 5.907 ms · ratio 0.87x
PERF[sim] quick-note MINT (12-paragraph paste) — bare 26.506 ms · full 24.352 ms · ratio 0.92x
PERF[sim] quick-note KEYSTROKE — bare 0.0055 ms · full 0.0053 ms
PERF[sim] shelf observation ticks across a bookless mint — 1 → 1
```

**Plainly: the number is fine, and it is fine for a structural reason, not
a lucky one.** The sweep's stated worry was that *"typing on the shelf
schedules sync rounds at autosave rate against a held books observation."*
That observation reads `reading`, `reading_post` and `reading_section` —
**never `container`** — so a bookless capture cannot wake it. That is
asserted as a **fact about what the store notifies** (an observation tick
count, 1 → 1), not as a timing, so it cannot pass merely by being fast.

The ~26 ms of a 12-paragraph paste is segmentation plus twelve block
inserts, and it too is flat. **No fix earned; the measurement is the
deliverable, as §53 said.**

### The suite

*[removed for publication]*
→ **`Test run with 545 tests in 91 suites passed after 129.462 seconds
with 2 known issues`**, exit 0.

The 2 known issues are the pre-existing deliberate `withKnownIssue` in
`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosed…` — not mine, not
new.

**⚠️ Flakiness seen, and the diagnosis CORRECTED — read this before
*[removed for publication]*
*"Simulator device failed to launch"* and *"Restarting after unexpected
exit, crash, or test timeout"* at six unrelated tests, and one reported a
nonsense total (87 tests). I first attributed this to machine load — the
author had closed Xcode mid-run, and another simulator was booted at the
same time.

**That was only half right.** The coordinator relayed a finding from
another agent in this run: **two agents sharing one simulator contaminate
each other invisibly.** DerivedData is genuinely per-worktree, so that is
not the crossing point; the SIMULATOR is — same bundle id, **last installer
wins**, so one agent's build runs under the other's test plan. Its
symptoms were exactly mine (repeated `signal kill`, layout pins reading
nonsense heights) plus one that settles it: a failing test **that did not
exist in that worktree at all**. That retro-explains at least one of my two
"environmental" run deaths and the 87-test total.

**The rule to carry:** a restart cluster spread across unrelated suites is
environmental, and *"environmental"* should mean **check who else is on
your simulator** before it means machine load. On the reassigned device
every run in this file was clean with **zero** restarts.

---

## 3. PROVISIONALs — hers to rule

1. **The introduction copy** (`MobileStarterJournal.entryTitle` /
   `.entryText`). Drafted, marked PROVISIONAL in the source, and on her
   13s list: she writes the app's corpus in her own voice. It deliberately
   teaches ONE thing — what the book is and how a day gets into it — rather
   than becoming a second pocket guide.
2. **The badge's short word, `✎ today`.** It rides a row that already
   carries a name and a meta column, and phone width is the scarce thing.
   The SPOKEN label stays the full "Today's Entry", so nothing an assistive
   reader hears changed.
3. **The daily book's row drops the word "daily" from its meta line** when
   it wears the badge. One marker for one fact. This is a VIEW-level call:
   `MobileShelfFaces.meta(…, isDaily:)` is untouched and every other
   surface still reads it exactly as before.
4. **The starter note sorts to the END of the Journal book** once real days
   arrive — pinned as behaviour, with the reason in the pin. It carries no
   `entry_date` on purpose: a fabricated past day would sort it first but
   would make it a DAY, and **the Fragments bridge pushes by `entry_date`**,
   so it would invent a journal entry in her other app for a day she never
   wrote.
5. **The starred section rides inside the bounded books region.** Her
   ruling is about books; nothing above the writing area may grow without
   limit, so stars scroll with them. *(Her batch-10 item — *"I don't like
   where it appears above the shelf"* — is a different question and is not
   pre-empted here.)*
6. **The box's type is still `tokens.small` (11.5 pt).** R27 makes this the
   shelf's main writing surface, and 11.5 pt for a main writing surface is
   worth her eye. Changing it would be inventing; flagged instead.
7. **A short shelf leaves the box very tall.** With two books the writing
   region is most of the screen. That is the ruling working as written
   ("the main area still can be new note"), but it means a large empty
   dashed rectangle on a fresh install — a taste call for her walk.

## 4. THE HONEST RESIDUAL

**A user who deletes the starter book AND its entry (leaving a genuinely
empty store) and then deletes and reinstalls the app gets the starter book
once more** — the `UserDefaults` mark dies with the install and the store
looks new again. Closing it needs a *synced* marker, and the `setting`
table has **no public write door from app code** (`Operations.upsertSetting`
is internal), which would be a `Sources/` change this batch is fenced from.
Narrow, non-destructive, named rather than hidden. Recorded in the source
header too.

## 5. THINGS I FOUND THAT ARE NOT MINE

- **The brief's simulator is unusable for this project** (iOS 18.3 vs an
  iOS 26 deployment target). Worth correcting wherever it came from before
  another batch loses time to it.
- **`MobileTutorialSeeder.swift:661` warns**: *"main actor-isolated static
  property 'doorTitle' can not be referenced from a nonisolated context"*.
  Pre-existing, untouched, not mine.
- **`MobileStructural.swift:91` warns**: unused `intra`. Pre-existing.
- **R24 is fenced** (§1) and needs one minute from whoever holds
  `Features/Write/`.

## 6. FILES

**New:** `VariorumMobile/Features/Shell/MobileShelfLayout.swift` ·
`…/MobileStarterJournal.swift` ·
`VariorumMobileTests/MobileShelfLayoutTests.swift` ·
`…/MobileShelfTodayDoorTests.swift` · `…/MobileStarterJournalTests.swift` ·
`…/MobileShelfPerfTests.swift`

**Modified:** `…/Shell/MobileShelfView.swift` (the layout, the badge, the
fallback row, the row's tap target, **the writing state**) ·
`…/Shell/MobileQuickNote.swift` (the box's `writingHeight` and its **two
shapes**, plus `isFocused`/`setFocused` — the ⏎ road, the mint clock and
every A5 rule are untouched) · `…/Shell/MobileShelfFaces.swift` (the Today
door's words, one home) · `…/Shell/MobileShelfViewModel.swift`
(`rowMeta(showingDailyMarker:)` defaulted true; `observationTicks` for the
§53 row 7 structural pin) · `…/Shell/MobileShellView.swift` (the seed
`.task`).

*(The refinements added no files — her two rulings landed inside the
brain, the box and the shelf, and their pins joined the existing suites.)*

## 7. HER TWO REFINEMENTS (2026-08-30, after reading the result)

### 7a. *"the box should be one line until you click into it"*

The shelf now has **two resting shapes**, and they are a layout fact
rather than a decoration:

| | books | writing |
|---|---|---|
| **at rest**, 430 × 932 | **774 pt** | **70 pt** — one line + chrome |
| **focused**, same shelf | 378 pt | **466 pt (50.0%)** |

At rest the **~8-row cap does not apply**, and that is deliberate: the cap
exists only to protect a writing area, and at rest there is none to
protect — capping there would mint dead air above a collapsed box. So her
own stated consequence falls out exactly: *a one-line box at rest gives
the books more room* (378 → 774 pt, measured).

**The whole chain is driven, not assumed.** `focusingTheRealFieldOpensTheBox`
takes focus by calling `becomeFirstResponder()` on the field's real
backing text view, found by walking the view tree — UIKit's actual focus
road — and measures **70 pt → 466 pt**, then resigns and measures the
return to 70. *(Recorded because I tried the obvious thing first:
`accessibilityActivate()` returns **false** on this field. It joins
`MobileSurfaceDriver`'s own list of what that dispatch cannot reach. A pin
that had silently fallen back to poking the model would have proven
nothing about the link her ruling rides.)*

**RED-ON-OLD:** with the previous always-expanded behaviour restored (one
argument), at rest the writing region measured **466 pt** and books
**378 pt**, and focusing changed nothing (466 → 466). Both new pins fail
there and pass here.

**The sub-question, decided and flagged: on blur WITH TEXT still in it,
the box collapses anyway.** PROVISIONAL. Reasons for the literal reading:
her sentence is about focus, not emptiness; the text is already durable
(the mint clock has fired, or leaving the shelf files it); and a box that
stayed open whenever it held something would make the shelf's layout
depend on invisible state. The saved indicator and the `open ↵` door stay
visible in the collapsed row, so nothing about the note goes quiet. **The
alternative — collapse only when empty — is defensible and is hers to
pick.**

### 7b. *"the shelf should be bounded so it always has a decent amount of room to write"*

Treated as raising the existing floor to a **guarantee**, and the floor is
now stated **in lines**, because that is what "room to write" means and a
pixel count would drift the moment the type or the chrome changed:

```
guaranteedWritingLines = 6
minimumWritingHeight   = 6 × smallLineHeight + writingBoxChromeHeight = 140 pt
```

**The promise is pinned, not the arithmetic.**
`theWritingFloorIsAGuaranteeInEveryShelfState` asserts
`writing >= min(region, minimumWritingHeight)` across **2,408 shelf
states** — regions from 60 to 900 pt, 0–200 books, 0–40 stars, with and
without the Today fallback row — so a later layout change that computes
the split differently fails loudly instead of eroding the floor quietly.

**Measured on every screen in the device envelope**, box open, forty books,
stars present:

| screen | books | writing |
|---|---:|---:|
| 430 × 932 (16 Pro Max) | 378 | **466** |
| 430 × 596 (keyboard up) | 254 | **254** |
| 393 × 852 (17 / 16 Pro) | 378 | **386** |
| 393 × 516 (keyboard up) | 214 | **214** |
| 375 × 667 (SE-class) | 290 | **289** |
| 375 × 376 (keyboard up) | 144 | **144** |
| 320 × 693 (Display Zoom) | 296 | **296** |
| 320 × 402 (keyboard up) | 150 | **150** |
| 320 × 693 **at AX5** (largest Dynamic Type) | 296 | **296** |

The worst case in the envelope is **144 pt against a 140 pt floor.**

**Dynamic Type cannot erode it, and that is pinned as a property rather
than hoped for:** the row heights are estimates and real rows are TALLER
at large text sizes, but the books' share is `min(natural, caps)`, so an
estimate that is too small can only shrink the books' share — which can
only make the writing region *larger*. The error is one-directional
(`underestimatingTheBooksOnlyEverGivesWritingMore`).

**Their interaction, which was the one place the two rulings could have
fought:** `openingTheBoxNeverLandsBelowTheFloor` sweeps every region and
asserts that opening the box both clears the floor and never gives her
*less* room than resting did.

### 7c. PROVISIONALs her two rulings CLOSED

- **§3 item 7 — "a short shelf leaves the box very tall", the large empty
  dashed rectangle on a near-empty shelf.** She ruled it, in this
  direction: one line at rest. **Closed.**
- **§3 item 3's neighbour is untouched** — the badge, the meta word and
  the starter copy are all still open.

**Still open, and one new:** §3 items 1–6 stand, plus **the blur-with-text
sub-question in 7a**.
