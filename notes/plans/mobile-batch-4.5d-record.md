# Batch 4.5d's FIX ROUND — the record (2026-08-30)

*Written as its own file because another agent holds
`notes/plans/mobile-round-2.md`. Two disjoint pieces: **(1)** §61's
fourteen findings, dispositioned; **(2)** **PL-10(b)**, the
duplicate-book-name guard on the phone.*

---

## 0. THE HEADLINE — §61's FIX ROUND WAS ALREADY DONE, AND §64 IS WRONG ABOUT IT

**§64 records that 4.5d's fix round "produced nothing recoverable" —
that it "had established baseline (475/77) and begun MAJOR 1's trace"
before dying on the API limit. That is false about the tree.** Thirteen
of §61's fourteen findings are **fixed in the committed code**, each
carrying a fix comment that **names the cold review as its source**
("until 4.5d's cold review", "restored (4.5d's cold review: …)",
"added at 4.5d's cold review", "a path that does not exist, until 4.5d's
cold review"). The fourteenth is a device-only item that no code change
can close.

The work is in **`1fc3036`** (the bar) and **`ad9d29a`** (the pins) —
the two commits the architect made on 2026-08-23 at 17:45 and 18:02.
So the dead session's fixes were **sitting uncommitted in the tree** and
the architect committed them **while writing a message saying they did
not exist**.

> **The lesson is §64's own, one turn further on.** §64 taught: *check
> the tree after an agent FAILS, not only after it succeeds* — and it
> found the harness revert by doing exactly that. **But it read the
> tree for CORRUPTION and never read it for WORK**, so it recorded a
> dead session's whole output as lost, dispatched the round again, and
> would have had a fresh implementer re-derive thirteen findings that
> were already answered. **A dying agent leaves BOTH: what it broke and
> what it built. Look for both.**

**And the fixes are good.** The one bug-class fix among them — the only
finding in §61 that is not documentation — is **proven red-on-old here
for the first time** (§1.1). Nobody had ever run that demonstration:
the session that wrote the pin died before reporting, and the architect
committed it unverified.

---

## 1. §61's FOURTEEN FINDINGS — DISPOSITIONS

| # | Finding (§61) | Disposition | Evidence |
|---|---|---|---|
| **MAJOR 1** | An inference (key-window theft) stated as fact and propagated into the briefs' binding preamble, a closeout obligation, and a live message | **ALREADY FIXED — verified at all five sites** | `MobileKeyboardBarGeometryTests.withHostedBar` states measured-vs-not, names the three counterexample hosts, records the untraced `rootViewController` difference, ends on *"NEVER READ A 1540 DESYNC FATAL AS HARNESS NOISE"*; briefs §0 (lines ~98–135) carries ESTABLISHED / NOT-established / the safe rule / the thing-not-to-carry-forward; handoff §7 obligation 2 withdraws the TEXTKIT2 routing; `mobile-round-2.md` §60 carries the correction banner; **`MobileSurfaceDriver.swift`'s §1b (4.5b's file, outside my fence) also carries it** |
| **MAJOR 2 (1)** | Handoff §6 item 4 said *"the built width is 28"*, made false by the fix | **ALREADY FIXED** | Handoff §6 item 4 now reads *"TWO REGIMES… CORRECTED 2026-08-22"*, 28 ≥ 375 pt / 23 at 320 |
| **MAJOR 2 (2)** | No Display-Zoom row in the device queue | **ALREADY FIXED** | Briefs §4b row **D9**, with *"Display Zoom RESTARTS THE DEVICE, so it must ride the same window as an install"* |
| **MAJOR 2 (3)** | 23 × 38 pt acts never rendered for a human | **OPEN — DEVICE-ONLY, NOT FIXABLE HERE** | Queued as D9; on her list as handoff §8 item 11. A simulator cannot settle legibility; §26's rule binds |
| **MINOR 1** | The rebuild seam's correctness rested on an assignment ORDER at a call site no pin drove (`weak var bar`) — *"Pinnable red-on-old"* | **ALREADY FIXED, AND NOW PROVEN** (§1.1) | `lastBuiltBarWidth` + `currentBarWidth()`'s arm 2; pin `aRebuiltBarKeepsHerWidthWhenTheOutgoingBarIsReleasedFirst` |
| **MINOR 2** | *"a 402 pt phone would allow 31 … to buy 3 pt"* — recomputed, `derived(402) = 30`, so 2 pt | **ALREADY FIXED** | The doc now reads *"derives **30** … would buy **2 pt**"*, with the correction's provenance stated |
| **MINOR 3** | The same paragraph led with superseded behaviour (*"sized to the narrowest HARDWARE class"*) | **ALREADY FIXED** | The block now LEADS with *"THE RULE, since this round's fit fix: 28 pt is a CEILING, and the strip is sized to the bar it is being built into"*; the hardware class survives only as the 28's provenance |
| **MINOR 4** | The clearance pin dropped R12's third clause (`== 4`), so the constant could drift 4 → 5 → 6 with every assertion passing | **ALREADY FIXED** | `theBarClearsEveryDrawnCellByTheRuledAirAtEveryWidth` asserts `air == barVerticalAir` **and** `air == 4` in both states, with the reason inline |
| **MINOR 5** | The coverage test's doc made the one claim the file exists to retire | **ALREADY FIXED** | *"one honesty note about its own first line, added at 4.5d's cold review: `resting == barHeight` **restates the harness**"* |
| **MINOR 6** | One derivation spelled two ways, in the file whose thesis is that duplicated derivations drift | **ALREADY FIXED — both instances** | `currentBarWidth()` is *"THE ONE PLACE the strip's width is resolved"*; `stripRendered(by:)` is *"the ONLY strip lookup in the file"* |
| **NIT 1** | `supportedBarWidths` doc overstated its list | **ALREADY FIXED** | The monotonicity paragraph: *"`min(28, derived(w)) == 28` for **every** w ≥ 375, not merely the sampled three"* |
| **NIT 2** | An inference stated as a measurement about bar-vs-content-row centring | **ALREADY FIXED** | *"the content row's insets are symmetric, so the bar's centre and the content row's centre are the SAME POINT… the data cannot distinguish which"* |
| **NIT 3** | *"Display Zoom relaunches the app"* — it restarts the **device** | **ALREADY FIXED** | `grep` for `relaunch` in both files: zero. Two sites say *"restarts the device"* |
| **NIT 4** | A dangling doc reference | **ALREADY FIXED** | `outdentButton`: *"`MarkdownEditing.Act.outdent` … this doc named it `MarkdownEditing.outdent`, a path that does not exist, until 4.5d's cold review"*. Every backticked symbol in the bar file was re-checked against the tree; the only unresolvable names are `restingBarHeight`/`expandedBarHeight`, which the prose explicitly narrates as **retired** |
| **NIT 5** | Muddled fixture ownership | **ALREADY FIXED** | `HostedBar`'s doc: *"The WINDOW is the fixture's real owner, not any one toolbar"*, and `tearDown()` empties the window |
| **NIT 6** | Duplicated doc paragraphs | **ALREADY FIXED** | Mechanical check: every doc line > 40 chars in both files, sorted, `uniq -d` → **zero duplicates** |

**Nothing was fixed by this session in piece 1.** Re-fixing work already
in the tree is the exact hazard the round's own protocol warns about;
the honest act was to verify and record.

### 1.1 THE ONE OWED DEMONSTRATION, RUN AT LAST — MINOR 1's red-on-old

§61 called MINOR 1 *"Pinnable red-on-old"*. The fix and its pin are in
the tree; **the red was never demonstrated**, because the session that
wrote them died before reporting and the architect committed them
unverified. Run here:

**The behavioural revert** — drop `currentBarWidth()`'s arm 2 (the
`lastBuiltBarWidth` fallback), i.e. the shipped pre-fix expression:

| pin | verdict under the revert |
|---|---|
| `aRebuiltBarKeepsHerWidthWhenTheOutgoingBarIsReleasedFirst` | ✘ **FAILED, 12 issues** — `(rebuilt.bounds.width → 320.0) == (barWidth → 402.0)`, then all eleven acts measuring 23 pt against 28 |
| `aRebuiltBarKeepsTheWidthTheBarWasAlreadyRendering` | ✔ **passed** — the sibling that rebuilds with the outgoing bar alive cannot witness it |
| the other four geometry pins | ✔ passed |

Restored → **6/1 green**. So the pin is real, it discriminates against
its own sibling, and the fix it guards is correct. **A red-on-old that
nobody ran is a claim, not a pin** — this one is now a pin.

### 1.2 STILL OPEN OUT OF §61

- **MAJOR 2 (3)** — the 23 pt strip at Display Zoom has still never been
  rendered for a human. **Device-queue D9**, and Display Zoom restarts
  the phone, so it must ride an install window. On her list as
  handoff §8 item 11. **Nothing a session can close.**

---

## 2. PL-10(b) — THE DUPLICATE-BOOK-NAME GUARD ON THE PHONE

### 2.1 What the ledger said, and what it actually needed

The parity ledger's PL-10(b) says *"one line each — `assertBookNameIsFree`
is in core; the Mac refuses at five doors."* **The line count is right
and the estimate is wrong**, in three ways:

1. **The sentence had no shared home.** `BookNameCopy` — her ruled
   wording from 13e E13 — lived in
   `Variorum/Registry/OpsRefusalCopy.swift`, **Mac-app-local**. Adding
   the guard "in one line" would have left the phone with a refusal it
   could not word, or a second copy of her sentence: MobileSoul §3's
   drift class, and a new row for the KnownIssues forked-brains ledger.
   **So the sentence was HOISTED to `App/Variorum/Shared/BookNameCopy.swift`.**
2. **A refusal needs an ARM, not just a guard.** `MobileCreateBookModel`
   caught everything as `String(describing: error)` — so wiring the
   guard alone would have shown her
   `duplicateBookName(name: "Ideas")`. `MobileBookDetailsModel` routes
   through `DeletionRefusal.words`, whose honest last resort still ends
   in the raw enum: *"That couldn't be done — duplicateBookName(name:
   "Ideas")."* A taken book name **is not a deletion refusal**, so it is
   not that home's to word; each door now routes it to `BookNameCopy`.
3. **The rename door needs `excluding:`, and getting that wrong is
   worse than no guard.** Without it a book cannot be recased into its
   own name — it collides with itself, and the door tells her *"A book
   named 'Poems' already exists"* about the book she is renaming.
   Pinned (§2.3, revert 2).

### 2.2 What landed

| file | change |
|---|---|
| `App/Variorum/Shared/BookNameCopy.swift` | **NEW — the hoist.** The enum moved verbatim; its doc updated from "five doors" to seven and given the hoist's provenance |
| `App/Variorum/Variorum/Registry/OpsRefusalCopy.swift` | `BookNameCopy` removed; `TakeStructureCopy`'s reference to it gains a one-line pointer to its new home. **Mac behaviour untouched — same symbol, new address** |
| `MobileCreateBook.swift` | `assertBookNameIsFree(bookName)` **inside** each of the three runner closures (the Mac's shape, for the operation's own stated reason: runner bodies are synchronous, so nothing lands between the read and the insert); a `duplicateBookName` catch arm speaking `BookNameCopy.refusal` |
| `MobileBookDetails.swift` | `assertBookNameIsFree(trimmed, excluding: id)` inside the rename's runner closure; `refusal(_:)` gains the one arm in front of `DeletionRefusal` |
| `MobileBooksTests.swift` | New suite `MobileBookNameGuardTests`, three pins |

**Deliberately NOT touched:** the two seeders
(`MobileTutorialSeeder`, `MobilePerfFixtureSeeder`) call `createReading`
directly and **must never refuse for a name reason** — that is the
operation's own documented rationale for being a door assert rather
than a guard inside the op. They were checked; they are the only other
mobile callers.

### 2.3 RED ON OLD — three reverts, three different failures

| revert | pin | what it showed |
|---|---|---|
| **1.** all three `assertBookNameIsFree` lines out of `create()` | `creatingRefusesAnExistingBookNameInEveryKind` | ✘ **7 issues** — every kind minted a second "Ideas", `lastError` nil, live `reading` count 4 vs 1 |
| **2.** the line out of `rename()` | `renamingRefusesAnotherBooksNameButNeverItsOwn` | ✘ **3 issues** — the store reads `IDEAS`, `nameLine → "IDEAS"`: **two live books wearing one name, arrived at through the door** |
| **3.** `excluding: id` dropped, guard kept | same pin | ✘ **3 issues, the OTHER half** — the first act now passes, the second fails: `lastError → "A book named “Poems” already exists"` on the book being renamed |

**And the four pre-existing book pins (`MobileBookCreateTests`,
`MobileBookDetailsTests`) stayed GREEN through reverts 1 and 2** — they
could never see this. That is why a shipped core guard sat unwired on
the phone for twelve days of daily use.

### 2.4 The hoist proof

**Mac suite: `Test run with 1843 tests in 312 suites`** — the 13p
closeout's count, **exact**, with **zero Mac test files edited**. The
one failure is the documented intermittent latency pin (§3).

---

## 3. TESTS

*[removed for publication]*
(accessibility flag verified `= 1` before any run, and left armed).
The UDID in the brief could not run the app at all — see §4 item 1.

| suite | result |
|---|---|
| **mobile** | **`Test run with 516 tests in 87 suites`** — 513/86 baseline **+ my 3 pins in 1 new suite**, exact. **1 real issue + 2 known issues** |
| mobile spine | rides inside the above, green |
| **Mac** | **`Test run with 1843 tests in 312 suites`** — 13p baseline, exact, **zero Mac test files edited**. **1 issue** |
| **core** | **`Test run with 1453 tests in 154 suites` PASSED** — baseline exact. `Sources/` is **byte-untouched** (`git diff -- Sources/` empty), so this is a control, not a claim about my change. *(An earlier core run on a heavily loaded box reported 1 issue and took 237 s against this run's 103 s — the P1 benchmark suite alone spent 172 s in `postRenderIsFlatInCorpusSize`. Green on the quiet re-run; the same load class as the two pins below.)* |

**The two mobile "known issues"** are 4.5b's own intentional diagnostic
pin (`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`),
recorded as expected in §64.

**The one real mobile issue** is
`MobilePerfWalkTests/typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
— 12.246 ms against a 12.0 ms floor under full-suite load. **Isolated
on the same tree it PASSES** (11.500 ms, and 10.487 ms in an earlier
isolated run): a load-dependent margin of ~4 %, the same shape as the
Mac's known latency pin. **Not mine** — this batch's diff contains zero
editor, perf or `Shared/EditorBrain` lines.

**The one Mac issue** is
`EditorWindowSmokeTests/rewriteStrategyLatencies(paragraphs: 250)` at
**52.19 ms** full-suite and **53.73 ms** isolated, against its 50 ms
budget. This is the **KnownIssues row owned by Phase 12** — measured
pre-existing on both trees, documented band 50.25–58.47 ms under load.
Not mine; my diff contains zero editor lines.

---

## 4. THINGS I FOUND THAT ARE NOT MINE

1. **🔴 THE ORCHESTRATOR'S SIMULATOR CANNOT RUN THE APP.** The prompt
   *[removed for publication]*
   booted and armed. It is an **iOS 18.3** device; the deployment target
   is iOS 26, so `xcodebuild` refuses the destination outright
   (*"Unable to find a destination matching the provided destination
   specifier"*). Two other iOS-18.3 phones were booted alongside it
   at the same time, which suggests **sibling agents were handed the
   same dead UDID**. Work ran on **iPhone 16e (26.2)** — 4.5d's own
   authoring device — after a detour through iPhone 17 Pro (see 2).
   **The environment block in `mobile-round-2.md` §9 says iPhone 17
   family on the newest runtime; the briefed UDID contradicts it.**
   *(The coordinator reached the same conclusion independently mid-run
   and re-pointed the brief at iPhone 16e — the device this session had
   already moved to.)*

2. **🔴 TWO AGENTS ON ONE SIMULATOR CONTAMINATE EACH OTHER'S RESULTS —
   and it is invisible.** Runs on iPhone 17 Pro produced repeated
   `Test crashed with signal kill`, shelf-layout pins reading
   `field.height → 14.0` (an unlaid-out field), and — decisively — a
   **failing test that does not exist in this worktree**
   (`MobileStarterJournalTests/theStarterEntryIsNotTodaysEntry`;
   `grep -rn` across `App/Variorum` returns nothing). DerivedData is
   **not** shared (each worktree hashes its own, verified via
   `info.plist`'s `WorkspacePath`), so the crossing point is the
   **simulator**: same bundle id, last installer wins, and a sibling
   agent's `.xctest` was executing under my `xcodebuild`. Moving to an
   uncontended device made every one of those failures vanish and
   produced the clean 516/87. **This belongs in the environment block
   beside the accessibility-flag warning: it is the same class —
   red over nothing — and it is worse, because the red names tests
   from someone else's branch.** *(The author also mentioned closing
   Xcode mid-run, which will have contributed to the churn; the
   phantom-test evidence is independent of that.)*

3. **§64's record is wrong** (§0 above) — a documentation defect in a
   plan file another agent holds. It should be corrected in place, both
   because §64 is cited in the handoff's batch map and because its
   lesson deserves the second half: **read a dead agent's tree for
   WORK, not only for corruption.**

4. **The handoff has no §9.** The brief cited *"handoff §9 — this
   session's verified state"*; `mobile-round-2-orchestrator-handoff.md`
   ends at §8. No substance appears lost — §2/§2b/§3 carry state — but
   the pointer is dangling.

---

## 5. WHAT THIS DID NOT DO

- **4.5d's MAJOR 2 (3)** — the 23 pt strip on a human's screen. D9.
- **The untraced `rootViewController` difference** behind the
  `makeKeyAndVisible` harness death stays untraced, exactly as §61 left
  it. It is not a fix-round item and inventing a mechanism for it is
  the failure this round has now recorded three times.
- **No `Sources/` line, no `Sync/` line, no schema.** Marker stays 7.
