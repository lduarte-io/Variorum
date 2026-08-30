# Mobile Round 2 — BATCH 5 RECORD (the shelf layout)

*Written 2026-08-30 by the batch-5 implementer, in its own worktree
(`worktree-agent-a482cba77d19d2fff`, off `main` at `299afe5`). This file
is deliberately a NEW file: `mobile-round-2.md` is another agent's.*

**Her complaint, twice, and the reason this batch exists:** *"I still see
today's entry where i don't want it and the quick note where i don't want
it."*

---

## 0. THE HEADLINE NUMBERS, up front

| | |
|---|---|
| mobile suite | **545 tests / 91 suites — PASSED**, exit 0, zero restarts (baseline 513/86 ⇒ **+32 tests, +5 suites**) |
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
nothing can run there. I used the round's own standing destination instead
(§9's LK1 rule): **iPhone 17 Pro `<simulator-udid>`,
iOS 26.2**, whose accessibility flag I verified `= 1` before running
anything. **The 18.3 device was left booted and armed, untouched.**

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
- **`minimumWritingHeight = 132`** — a floor, so a small phone or a
  keyboard cannot reduce the box to a line. When the floor bites, the
  books yield further.
- `split(region:bookRows:starredRows:extraRows:)` **partitions the region
  exactly** (`books + writing == region` for every input, pinned).

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

**⚠️ Flakiness seen and diagnosed, so nobody re-derives it:** two earlier
full runs died with *"Simulator device failed to launch"* and *"Restarting
after unexpected exit, crash, or test timeout"* at six unrelated tests. The
author closed Xcode mid-run (she said so), and a second simulator
(iPhone 16e) was booted by another agent at the same time — machine load,
the same covariate `KnownIssuesAndTechDebt.md`'s latency row records. After
a simulator restart the run was clean with **zero** restarts. **A restart
cluster spread across unrelated suites is environmental; one that recurs at
the same test is not.**

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
fallback row, the row's tap target) · `…/Shell/MobileQuickNote.swift`
(the box's `writingHeight` — face only; no model, no ⏎, no A5 rule
touched) · `…/Shell/MobileShelfFaces.swift` (the Today door's words, one
home) · `…/Shell/MobileShelfViewModel.swift` (`rowMeta(showingDailyMarker:)`
defaulted true; `observationTicks` for the §53 row 7 structural pin) ·
`…/Shell/MobileShellView.swift` (the seed `.task`).
