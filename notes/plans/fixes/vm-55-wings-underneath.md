# VM-55 — Run: Wings underneath (mobile catch-up, wave 1, umbrella 2)

**STATUS: OPEN 2026-11-19** — overnight run under `/run-phase vm-55`; stage coordinator `nov18`.
Ticket VM-55 (team VM, project "Mobile — the catch-up & launch") · branch `vm-55-wings-underneath` · worktree
`~/dev/variorum-vm-55` · Pro · ONE PR titled `VM-55: Wings underneath`.

## FOR A LATER READER

*Written at closeout. Until then this run is open and the sections below are its working record.*

---

## Her words

Tonight (2026-11-19), verbatim: "i want to get everything set up for an overnight session" · "the whole issue is
that i need to use my weekly limit up before tomorrow" · "i want one claude coordinator named nov18, then i want
all the VM in the first wave launched with instructions to talk to stage coordinator nov18, i want the vx-981 and
vx-980 added too. and add the high priority (private eye not shown on journal) to one of those runs - maybe the
MCP run, since it deals with the private mark."

What this umbrella answers (`notes/plans/vm-44/her-words.md`): "there are no different wings (!!) so everything
just shows up in one bunch but it's hard to find items in the library." · "I have 9, so UI options should work
well with many." · on which acts show a line: "Only removals and refusals" · "i feel like it'll feel too noisy" ·
"I think we need to word things more simply."

Mid-run, in chat (2026-11-19), verbatim: on the Protection screen's receipts being ticketed under the lock
umbrella (VM-103) at closeout — "yeah that's fine." · on the ladder — "also, up to 5 review rounds as long as a
major is found."

Rulings this run builds (`notes/plans/vm-44/plans/sitting-1-rulings.md`): SW-1 (the wing's name is the title on
every root; the swipe, dots and dropdown are wave 2) · SW-5 (a quick note lands in the current wing, in the Pool) ·
Receipts (no line for ordinary acts; a short line with Undo only when something leaves the page, and for
refusals) · Words (short and plain; the Mac's own words wherever a Mac face exists).

## The roster (the sub-issue listing of VM-55, read 2026-11-19 — eight members)

| Ticket | Title | Kind | Rows | Batch |
|---|---|---|---|---|
| VM-56 | The phone remembers which wing it is in, and every root says which | Feature | W-015, W-019 | 1 |
| VM-57 | Every list shows only the current wing | Feature | W-033 | 1 |
| VM-58 | New notes, books and tags are born in the current wing | Feature | W-034 | 1 |
| VM-59 | Tag suggestions and book pickers stay inside the note's own wing | Bug · Confirmed | W-035 | 1 |
| VM-60 | The tag manager shows and makes tags in the current wing | Feature | W-229 | 1 |
| VM-61 | One message line: Undo when something leaves the page, and refusals | Feature | W-012 | 2 |
| VM-62 | Refusals in plain words, never raw error text | Bug · Confirmed | W-013 | 2 |
| VM-63 | Move the Mac's wing brains to shared code | Debt · Confirmed | W-016 | 3 |

Order (Linear's blocked-by): VM-57, VM-58, VM-60 wait on VM-56 · VM-63 waits on VM-61 · VM-62 lands best after
VM-61 · VM-59 waits on nothing. Commit messages say `Part of VM-<member>`.

## The cast

Fable orchestrates · one `opus-implementer` per batch, a fresh one each batch, strictly one at a time · the cold
review is `fable-reviewer` (the standing default; batch 2 edits error-wording expressions inside the phone's
editor-seam files, and batch 1 changes what a shared default means on iOS) · a fresh reviewer per ladder round,
cap FIVE for this run at her word above (CLAUDE.md's standing cap of three is not edited on it): a round that
surfaces a new BLOCKER or MAJOR earns the next, up to round 5; a round with none closes the ladder.

## What every batch reads first (the implementer's own reading, never delegated)

`CLAUDE.md` and its loaded canon · `notes/MobileSoul.md` §1–§5 · `notes/SessionResiliencyProtocol.md` (the
CHECKPOINT PROTOCOL binds from the first commit) · `notes/plans/vm-44-mobile-catch-up-plan.md` ("The rules every
umbrella inherits") · `notes/plans/vm-44/plans/minted/umbrella-02.md` · `notes/plans/vm-44/plans/sitting-1-rulings.md` ·
`notes/plans/vm-44/audit/A-shell-library-wings.md` (§1D, §1F, §1I, §3.1 for every batch) · this file, whole ·
`notes/SurfaceContracts.md` — "The app" (the Messages bullet and the wing label) and "The Bookcase and books"
(the wing switcher bullet) · the batch's mockup build notes named below.

## The stage this window (the coordinator `nov18`'s protocol, received at kickoff)

- REQUEST → READY (a separate ping, exact TYPE lists) → GO (only from nov18, with the exact claim line) → RELEASE
  (release, then ONE result line). Claim name `vm-55`. Implementers relay through the orchestrator.
- `xcodebuild build` / `build-for-testing` and headless `swift build`/`swift test` need no stage; EVERY
  `xcodebuild test` (test-without-building included) and any simulator boot does.
- Never wait on her while holding a claim. Ask for more time before T−10; `Tools/stage renew` RESETS the clock.
- QUIET windows (every whole-Mac-target run, every merge-gate window): no whole-package `swift test`, no cold or
  full build-for-testing while one is announced.
- Result lines: executed counts or no verdict; `-only-testing` takes TYPE names in a zsh ARRAY; "Executed 0" with
  TEST SUCCEEDED counts only for a Swift Testing suite, with its pass count; name EVERY failing test; say the sim is
  shut down, no Variorum instance left, any new crash report or Problem Reporter window; say which reds were load
  re-runs (a timing red under load is re-run alone before it counts).
- The phone suites run on the window's one standing simulator (iPhone 17 Pro, iOS 26.2; its id is in the
  coordinator's messages, never in a record — the pre-push guard refuses it), shared by the four mobile runs one at
  a time: boot fresh inside the claim, let it settle, shut it down before release. The closing walk seeds its
  two-wing library on a DEDICATED device this run creates and deletes at close.
- This run's windows: batches 1 and 2 one READY each; batch 3 one claim, two legs (the Mac wing suites — the Mac
  test host is the dev-store Debug app, dismiss a What's New sheet — then the phone); the merge window is three
  claims in order: whole phone target · whole Mac target (QUIET) · the walk. The merge GO rests on whole-target
  phone AND Mac of the tree that merges; code landing after means one more whole-target window.
- Merge: ask nov18 first. Umbrella VM-78's VM-81 waits on this run's VM-62, which argues for this run merging
  before VM-78; batch 3's file moves are the hardest thing for the others to merge over — tell nov18 as soon as the
  merge is in sight.
- Overlaps nov18 tracks: `Shared/AppSession.swift` (VM-64) · `MobileEditorViewModel` (VM-64, VM-78) ·
  `MobileShellView` (VM-47) · `MobileShelfViewModel`, `MobileCreateBook`, `MobileMembership`, `MobileTrash*`
  (VM-78) · line-level type edits across most phone files (VM-47).
- DerivedData: one dir per batch under `App/Variorum/DerivedData/vm55-*`, superseded ones dropped.

## Scope calls made at kickoff (the orchestrator's; each is on the ratify list)

1. **No switcher in this run.** The swipe, dots, dropdown, follow and wing management are wave 2 (VM-72's
   umbrella; W-017, W-018, W-020, W-021). After this run the phone stands in the wing its device memory names
   (Home on a device that never switched) with no door to change it. Tests switch through `WingState.switchTo`;
   the simulator walk sets the memory key before launch. **For her:** a build of main between this merge and
   wave 2 would show her Home only on her phone — held for her next sitting, nothing installs tonight.
2. **No "Now in …" line and no line for a wing change** (VM-56's ruling; the mockup's build note "No line is
   shown for it"). The wing's name is drawn as the title on every root.
3. **Snippets stay the one room all wings share** (SurfaceContracts, Search; the library mockup's build note).
   Trash and Archived are per wing; Empty Trash empties what the Trash shows.
4. **Today's entry is born in the Journal's own wing** (Core already does it); every other mint is born in the
   current wing. The phone does not switch its wing when Today opens another wing's entry — the follow is wave 2.
5. **PROVISIONAL P-55-1 — `receipt_style` is not read on the phone.** SW-6 is not among her recorded rulings.
   Options: (a) the phone honours the synced setting; (b) the phone ignores it — the ruled shape (removals and
   refusals only) leaves the setting nothing to govern; (c) "off" also silences removal lines. Built: (b), on
   the note-write mockup's build note ("the synced receipt setting does not add lines on the phone").
6. **Protection faces are not touched.** `Features/Protection/` and `Shared/Protection/` are Castle faces
   (CastleRules is their contract, and the wave's custody slot is VM-64's). VM-61's audit row D-27 (Protection's
   receipts wait until the screen reopens) is the remainder; the closeout tickets it into the lock umbrella
   (VM-103) — confirmed by her mid-run ("yeah that's fine.").
7. **A line with Undo only where an undo road already exists** (structural undo, Put back, unarchive). No new
   undo road is invented here; a removal whose Undo needs one is named in the batch record and stays with the
   umbrella that owns its act.
8. **An existing phone receipt for an ordinary act stops showing** (her ruling). Batch 2 lists every line it
   drops, verbatim with its file, in its record, so she can call any of them back.
9. **Riders:** none offered — she is away; every open phone row already has an umbrella.

---

## BATCH 1 — the phone stands in one wing (VM-56, VM-57, VM-58, VM-60, VM-59)

> You are the implementer for batch 1 of the VM-55 run, in the worktree `~/dev/variorum-vm-55` on branch
> `vm-55-wings-underneath`. Read this file whole and the reading list above before any code. Build, in this
> order, committing and pushing per piece with the LIVE STATUS table below flipped in the same commit:
>
> **VM-56 — the current wing on the phone.** `WingState.readScope` returns the current wing on iOS too; the
> bootstrap attaches the device memory and the dead-wing revalidation on iOS (`Shared/AppBootstrap.swift`, the
> block that is `#if os(macOS)` today); a held wings observation returns the phone to Home when its wing is
> deleted here or arrives deleted by sync. Every root (Starred, the Shelf, the Library) draws the wing's name as
> its title — "Home" for the virtual wing, through `Shared/WingWords` — in today's tokens and layout (umbrella
> VM-47 owns sizes; do not restyle). No line is shown for a wing change. Check every Shared caller of
> `readScope` and `session.wing` for what changes on iOS once the scope is real (the Trash's Empty Trash counts
> through it — `Shared/RecoveryActs.swift`), and record each in the batch record.
>
> **VM-57 — every listing reads the current wing.** The reads in audit A §3.1's table: Library All/Notes,
> Bookless (Pool), Books and the Shelf, today's title search, Starred, Archived, Trash. Each Core read already
> takes `wingID:`; this is call sites only. Snippets stay unscoped (scope call 3). A listing re-reads when the
> wing changes. Keep each edit to the call site: umbrella VM-64 is changing how the Library pages in the same
> view model tonight, and VM-47 the faces — the narrower the diff, the cleaner the merge.
>
> **VM-58 — mints are born in the current wing.** New note, quick note (SW-5: the current wing, in the Pool),
> new book (the per-wing name guard is Core's), new top-level tag. Today's entry stays Core's: the Journal's own
> wing.
>
> **VM-60 — the tag manager** lists and makes tags in the current wing (`Shell/MobileTagManager.swift`).
>
> **VM-59 — the wing-blind pickers (a Bug: pin before fix, each pin red on the old code and verified by
> revert).** A note's tag suggestions read the note's own wing (`Write/MobileNoteTags.swift`; the twin mint goes
> through `Shared/TypedTagPath.swift`); the add-to-book sheet lists the note's own wing's books
> (`Write/MobileMembership.swift`); the gathering's tag picker writes terms from the book's own wing
> (`Shell/MobileCreateBook.swift`). Each picker reads its OWN note's or book's wing
> (`Queries.effectiveWing(ofPost:)` / `(ofReading:)`), never the app's current wing — the two differ whenever a
> note from another wing is open.
>
> **Tests:** view-model and state-transition tests per member in `App/Variorum/VariorumMobileTests/` (a
> two-wing fixture: same-name books and same-path tags in each wing, so a leak is visible); a pin that the Mac's
> `readScope` is unchanged; VM-59's three red-on-old pins. Build the Mac target too — `Shared/` compiles into
> both. `xcodebuild build` and `build-for-testing` need no stage; EVERY `xcodebuild test` does: when the batch
> is built and its tests are written, report READY to the orchestrator with the exact suites and minutes you
> need, and wait — the orchestrator relays to the coordinator and hands you the claim line. Never claim the
> stage yourself without that line. While you wait, keep working headless.
>
> **Report back with** what shipped per member, test counts, the readScope caller sweep, PROVISIONAL calls,
> commits, and anything that needs the author. Write the batch's record section below detailed enough to be
> reviewed against the spec.

Mockup build notes for this batch: `notes/plans/vm-44/design/mockups/home-wings-capture.html` (the wing band:
"A wing deleted on another device returns her to Home. Every listing and every new note, book and tag follows
the wing." · "Today already opens the Journal's wing in Core; the phone must follow it rather than mint in the
current wing.") and `library-and-search.html` ("Scoped to the wing." · "Snippets is the one room all wings share
and says so." — the saying is wave 2's face).

## BATCH 2 — one message line, and refusals in words (VM-61, VM-62)

> You are the implementer for batch 2 of the VM-55 run, in `~/dev/variorum-vm-55` on `vm-55-wings-underneath`.
> Batch 1 is on the branch; read its record section below, then this file whole and the reading list, plus
> audit C (`notes/plans/vm-44/audit/C-the-note.md` N1, N5, N20, §2.9, §2.11) and audit B
> (`B-books-family.md` §0.6, I3, I4, M2).
>
> **VM-61 — one message seam, one line.** `AppSession.status` and `StatusCenter` are Mac-only today
> (`Shared/AppSession.swift`, the `#if os(macOS)` block; `Variorum/Registry/StatusCenter.swift`). Give the
> phone the same seam — the kinds decided at the door (refusal · offer · receipt), one `session.status` both
> platforms speak through — so a brain hoisted to `Shared/` (batch 3's wing brains, and later umbrellas') needs
> no platform fork. The brain is shared; the phone owns only its face: ONE message line, hosted once by the
> shell, in today's tokens. The Mac's toast, quiet line and every Mac behaviour stay byte-identical — pin it.
> Her ruling governs what the phone SHOWS: nothing for ordinary acts; a short line with Undo when something
> leaves the page (a delete, a merge, an archive, a deleted tag); a line for a refusal. So on the phone a
> receipt with no removal behind it draws nothing, a refusal always draws, and a removal draws its line with
> Undo wired to the road that already exists (scope calls 5, 7, 8). The line fades by itself and never pushes
> the page's content. Move every per-screen error and receipt slot outside `Features/Protection/` onto the one
> line (scope call 6); inventory them first, in the record: file · the words · its class (refusal · removal ·
> ordinary) · what became of it.
>
> **VM-62 — refusals in words (a Bug: pin before fix).** 69 sites print `String(describing: error)` (the count
> per file is in the LIVE STATUS notes). Every one speaks a sentence through `Shared/OpsRefusalTable` — the
> Mac's sentence wherever a Mac face exists, short and plain where the table needs a new row (a new row is a
> DRAFT line for her wording pass: list each, verbatim, in the record). No phone surface may print a raw error
> again: land a pin that fails on any `String(describing: error)` reaching a rendered string in
> `VariorumMobile/`, red on the old tree. In the editor-seam files (`Write/MobileEditorViewModel.swift`,
> `Write/MobileStructural.swift`) change the error-to-words expression ONLY — no control flow, no seam
> behaviour; umbrella VM-64 is working in those files tonight.
>
> **Tests:** the seam's kinds and the phone's show-rule as pure tests; the Mac byte-identical pin; refusal
> sentences for the audit's named cases (Finish on a gathering, Reopen on a sealed book, rename, unseal, star);
> the no-raw-error pin. Stage rule as in batch 1: report READY with suites and minutes, wait for the claim line.
>
> **Report back with** the seam's shape and why, the inventory, the dropped ordinary lines, the draft sentences,
> test counts, PROVISIONAL calls, commits, anything for the author.

Mockup build notes for this batch: `notes/plans/vm-44/design/mockups/note-write.html` D2–D5 ("Ruled: a line
with Undo only for a merge, an archive, a delete; refusals always; nothing else." · "Do not bring back a line
per act behind a setting: the synced receipt setting does not add lines on the phone." · "A press that finds
nothing to undo says so (a refusal) and offers no Redo (VM-16)." — VM-16's door itself is umbrella VM-78's).

## BATCH 3 — the wing brains move to shared code (VM-63)

> You are the implementer for batch 3 of the VM-55 run, in `~/dev/variorum-vm-55` on `vm-55-wings-underneath`.
> Batches 1 and 2 are on the branch; read their record sections, this file whole and the reading list.
>
> **VM-63 — a hoist, no behaviour change.** Move the Mac's wing brains from
> `App/Variorum/Variorum/Core/Views/` and `Variorum/Workspace/` to `App/Variorum/Shared/`: `WingsModel`,
> `WingSwitcherBrain`, `WingFollow`'s rule, and the move-or-copy confirm's brain out of
> `WingDestinationSheet` (its facts and words; the SwiftUI sheet stays the Mac's face). They speak through the
> one status seam batch 2 made shared. Split a file where brain and AppKit face are mixed; the Mac's faces
> (`WingSwitcherMenu`, `WingSwitcherSheet`, `WingToolbarLabel`, the sheet view) stay where they are and call
> the moved brains. The phone gains NO face here — wave 2 composes them. Both targets build; the phone compiles
> every moved file. Use `git mv` so history follows. The Mac's behaviour is byte-identical: the existing Mac
> wing suites are the pin, plus a compile-level pin that the phone target can construct each hoisted brain.
> Stage rule as before: the Mac's wing suites and the phone's suites that construct `AppSession` need a claim —
> report READY with suites and minutes.
>
> **Report back with** what moved where, what was split and why, anything that could not move and the reason,
> test counts, commits.

---

## Review foci (written at plan time, before any implementation)

1. `readScope` on iOS: every Shared caller, and every Shared door that takes "what the surface shows" — does
   each now take exactly what the phone shows (the Trash's "a door may not take what it does not show")?
2. A wing that dies while the phone stands in it (deleted here; deleted by a sync apply): Home, with no stale
   listing left scoped to the dead id.
3. Pickers read their own note's or book's wing, never the app's current wing; no road still mints a twin tag
   or writes a rule term from another wing.
4. Snippets unscoped; Today's entry in the Journal's wing; every other mint in the current wing.
5. P1 and P2: no listing gained a read whose cost follows the corpus; every read off the main thread.
6. The Mac is unchanged: `readScope`, the toast and quiet line, the wing switcher's behaviour after the hoist.
7. The message seam is one brain with two faces — no phone fork of the kinds; a brain in `Shared/` speaks
   without a platform `#if`.
8. Her ruling holds on the phone: no line for an ordinary act; a refusal always speaks; Undo only over a real
   road.
9. No rendered raw error remains in `VariorumMobile/`, and the pin would catch a new one.
10. Editor-seam files changed in wording expressions only.
11. `Features/Protection/` and `Shared/Protection/` untouched.

## LIVE STATUS

| Piece | State |
|---|---|
| Kickoff: worktree, branch, in-flight row (`c269aa3d7` on main), this plan | DONE |
| Batch 1 — VM-56 | NOT-STARTED |
| Batch 1 — VM-57 | NOT-STARTED |
| Batch 1 — VM-58 | NOT-STARTED |
| Batch 1 — VM-60 | NOT-STARTED |
| Batch 1 — VM-59 | NOT-STARTED |
| Batch 2 — VM-61 | NOT-STARTED |
| Batch 2 — VM-62 | NOT-STARTED |
| Batch 3 — VM-63 | NOT-STARTED |
| Ladder round 1 | NOT-STARTED |
| The simulator walk (use-shaped evidence: a two-wing library, the three roots, a refusal line, a removal line with Undo) | NOT-STARTED |
| Closeout | NOT-STARTED |

Notes for the implementers:
- Baseline (the last recorded whole-target runs, not re-run at kickoff): whole phone 857 tests / 141 suites at
  VX-849's close with its declared knowns (`nothingUserFacingNamesTheMac` and four known issues); umbrella
  VM-78 owns the phone's red tests this wave. A failure outside your diff is recorded, not fixed.
- Raw-error sites on main at kickoff, 69 across 23 files: `Write/MobileEditorViewModel` 10 ·
  `Shell/MobileShelfViewModel` 5 · `Write/MobileStructural` 4 · `Shell/MobileStars` 4 · `Shell/MobileScraps` 4 ·
  `Shell/MobileLibraryViewModel` 4 · `Write/MobileReferences` 3 · `Write/MobileMembership` 3 ·
  `Write/MobileComments` 3 · `Takes/MobileLenses` 3 · `Takes/MobileBlockHistory` 3 · `Shell/MobileTagManager` 3 ·
  `Shell/MobileSettingsView` 3 · `Shell/MobileBookDetails` 3 · `Write/MobileUndoDoor` 2 · `Write/MobileBlockList` 2 ·
  `Takes/MobileTakesController` 2 · `Takes/MobileTakesBrowser` 2 · `Shell/MobileCreateBook` 2 ·
  `Write/MobileNoteTags` 1 · `Write/MobileBlockMenu` 1 · `Shell/MobileStarterJournal` 1 ·
  `Shell/MobileBookViewModel` 1.
- The Xcode project tracks `Shared/`, `Variorum/`, `VariorumMobile/` and the test folders as file-system
  synchronized groups: a new or moved file needs no project edit unless a membership exception names it.
- The other wave-1 umbrellas are live in their own worktrees tonight (VM-47 sizes and look · VM-64 timing and
  the two lags, holding the custody slot · VM-78 fixes). Merges serialize through `nov18`; the later merger
  merges main in. Keep diffs narrow and never restyle.
- Walk screens and logs stay local (the gitignored `*-screens` convention); nothing outside the worktree.

## Batch records

*(each implementer writes its own section here)*

### Batch 1 record

**What this batch did NOT do (first, by the protocol):** no wing switcher, swipe, dots, dropdown, follow or wing
management (scope call 1 — wave 2, VM-72); no "Now in …" line (scope call 2); no message seam and no raw-error
rewording (batch 2's VM-61/VM-62 — every `String(describing: error)` this batch touched is left as it was); no hoist
of the Mac's wing brains (batch 3's VM-63 — the phone's small wings holder below is the interim face-side holder);
no restyle (the titles change WORDS in today's path lines only — VM-47 owns sizes); nothing under
`Features/Protection/`, `Shared/Protection/`, `Sources/VariorumCore/Sync/`, custody or the editor seam; no Core
change. The use-shaped simulator walk is the run's, after batch 3. **PENDING at this line: the stage-window runs
(VM-59 red-on-old, then every suite green) — the LIVE STATUS below says which are in.**

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch
`vm-55-wings-underneath`. Reading list done in full before code (CLAUDE.md + loaded canon, MobileSoul §1–§5, the
resiliency protocol, the catch-up plan's inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1,
this file whole, SurfaceContracts' "The app" and "The Bookcase and books" wing bullets, both mockups' build notes).
DerivedData: one dir, `App/Variorum/DerivedData/vm55-b1` (gitignored), phone and Mac.

#### Batch 1 LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (b174f2754) |
| VM-56 — the current wing on the phone (readScope, bootstrap memory, held wings observation, root titles) | DONE (219b4ac62) — tests `MobileWingStandTests` (6) + the Mac pin `VM56MacWingScopePinTests` (2), committed a0c54c57c; runs PENDING the stage window |
| VM-57 — every listing reads the current wing | DONE (219b4ac62) — tests `MobileWingListingTests` (8), a0c54c57c; runs PENDING |
| VM-58 — mints in the current wing | DONE (301388409; the new root tag rides 9462d3854) — tests `MobileWingMintTests` (4), a0c54c57c; runs PENDING |
| VM-60 — the tag manager per wing | DONE (9462d3854) — tests `MobileWingTagManagerTests` (2), a0c54c57c; runs PENDING |
| VM-59 — the wing-blind pickers | DONE in code — pins a690c8262 (THE RED-ON-OLD TREE), fix 171f514ad (the green tree); the red run and the green run PENDING the stage window |
| Phone `build-for-testing` (`VariorumMobile`, the simulator's id) | DONE — green at 171f514ad |
| Mac `build-for-testing` (`Variorum`, macOS) | DONE — green at 171f514ad (same DerivedData dir) |
| Stage window | IN-PROGRESS — claim taken 03:50 (35 min). Leg 1 (phone, 32 suites) DONE: 251/251 passed (Swift Testing; XCTest "Executed 0"; no `skipped:` lines; the 2 known issues are `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`'s declared ones). xcodebuild hung after the run's last line and was stopped by hand at 04:00. Leg 2 (Mac) running. **Leg 3 — REVERT ABOUT TO BE IN FLIGHT:** the three VM-59 fix files go back to a690c8262 for the red-on-old run; if this line is the last word, restore with `git checkout HEAD -- App/Variorum/VariorumMobile/Features/Write/MobileNoteTags.swift App/Variorum/VariorumMobile/Features/Write/MobileMembership.swift App/Variorum/VariorumMobile/Features/Shell/MobileCreateBook.swift` and check `git diff` is empty. |

#### VM-56 — the phone stands in one wing (W-015, W-019)

- `Shared/WingState.swift` — `readScope` returns `currentID` on both platforms (the `#if os(macOS)` fork is gone; the
  Mac's answer is byte-identical — pinned by `VM56MacWingScopePinTests`).
- `Shared/AppBootstrap.swift` — the memory block is un-fenced: the bootstrap attaches `.standard` under
  `WingState.memoryKey` and runs the one-shot dead-wing revalidation on the phone too. (In a hosted test run the
  bootstrap opens nothing — VX-604 — so no suite reads the host's defaults through it.)
- `VariorumMobile/Features/Shell/MobileWing.swift` (new) — `MobileWingModel`: the HELD `Queries.wings` read (the
  `wing` table alone, P1), whose `adopt` takes the Mac `WingsModel.adopt`'s three steps over the SHARED `WingState`
  (`noteWingCount`, then `revalidate` — a wing deleted here or arriving deleted by sync returns the phone to Home);
  `currentName` — "Home" (`WingWords.home`) for the virtual wing, a live wing's own name, nil while a non-Home name is
  not yet read (never a false "Home"; a rename re-titles live). Held by the shell (`.task { await wingModel.track() }`).
  **Interim by design:** VM-63 (batch 3) hoists `WingsModel`; wave 2's face should compose that and fold this holder.
- The roots' title — `MobileStarredView`, `MobileShelfView`, `MobileLibraryView` gain `var wingName: String? = nil`
  (the shell passes `wingModel.currentName`; harnesses that omit it render as before) and their path lines lead with
  it: Study "Home · Library", Terminal "~/home/library" — today's line, today's tokens, words only
  (`MobileWingTitle.components`; **P-55-2, PROVISIONAL**, below). No line is shown for a wing change.
- **The readScope caller sweep (every Shared caller, what changes on iOS):**
  1. `Shared/RecoveryActs.swift` `TrashPurge.emptyTrashConfirm` (the ask-time count) — was every wing's Trash on the
     phone, now the current wing's — exactly what the phone's Trash room now lists (`MobileTrashModel`, VM-57).
     Pinned: `MobileWingListingTests.theTrashListsAndEmptiesTheCurrentWing` (the confirm counts 1 note).
  2. `TrashPurge.confirm(.emptyTrash)` (the act-time re-read) — same wing; pinned by the same test (the purge intent
     names the wing's note alone; the other wing's deleted note survives).
  3. `TrashPurge.deleteSelection` (VX-671's selection Delete Now) — now the current wing's present set; the phone has
     NO Trash multi-select today (audit E9), so no phone road reaches it; a future phone selection takes only what
     the room shows.
  4. `Shared/AppBootstrap.swift` — the attach + revalidate above (now both platforms).
  5. `Shared/AppSession.swift` `commandRouter.wingCount` — inside `#if os(macOS)`; unchanged.
  6. `Shared/TypedTagPath.swift` — never read `session.wing`: it resolves in the NOTE's effective wing (13i-d U5);
     unchanged, and the reason VM-59's suggestion fix is enough.
  No other Shared file reads `session.wing` or `readScope` (grep at 171f514ad).

#### VM-57 — every listing reads the current wing (W-033)

`MobileWingScope.follow(session.wing) { wing in … }` (in `MobileWing.swift`) runs a held listing ONCE PER WING: on a
change it cancels the run and AWAITS its end before the next starts (a task group racing the body against
`Observations { wing.currentID }`), so a listing never shows two wings and never stays scoped to a dead id; a body
that ends on its own (an observation error) ends the follow, exactly as before. The views' task lines are untouched —
the Mac keys its views' tasks on the wing instead; the phone's models follow it themselves so the re-read is a model
fact the pins drive. Call sites (each passes `wingID:` to the Core read it already made):

| Surface | Model · read | Note |
|---|---|---|
| Library All / Notes | `MobileLibraryViewModel.startAll` · `observeLibrary(…, wingID:)` | VM-64 is changing this model's paging tonight — the edit is the wrap + one argument |
| Pool (Bookless) | `startBookless` · `poolPosts(_:limit:wingID:)` | |
| Books (Shelf + the Library's Books filter, one model) | `MobileShelfViewModel.start` · `bookshelf(_:wingID:)` | pins + the daily id unchanged (ids) |
| Search (today's title catalog) | `MobileLibraryViewModel.search` · `searchCatalog(…, wingID:)` | the view's task re-keys on `[model.wingID, query]` so a standing query re-asks in a new wing (the one view-line change) |
| Starred | `MobileStarsModel.start` / `refresh` · `starred(_:wingID:)` | the Mac's read (P-13id-U5-10); P1 unchanged — the unscoped read already held `container` (VX-643's note), the filter adds point reads ∝ the stars |
| Archived | `MobileArchiveModel.start` · `observeArchivedPosts(limit:wingID:)` | per wing, as on the Mac |
| Trash | `MobileTrashModel.startTrash` · `observeTrash(…, wingID:)` | per wing; Empty Trash agrees (sweep above) |
| Snippets | `MobileScrapsModel` — untouched | scope call 3: the one shared room (pinned `snippetsStayTheOneSharedRoom`) |

Reads deliberately left store-wide (each a lookup or a store fact, not a wing listing): `MobileBookDetails.refresh`
(`bookshelf(db)` to find ONE book by id — scoping it would blank a book reached from another wing's note);
`MobileShelfViewModel.refreshTags` (maps keyed by book id, read for the shown books); `MobileStarterJournal`'s
virgin-store guards; the DEBUG tutorial and perf seeders. P1/P2: every changed read is the same Core read narrowed by
a wing fragment, off the main actor; the only new held read is the `wing` table's.

#### VM-58 — mints are born in the current wing (W-034)

- `MobileNewNoteDoor.mint` (both + New Note doors) — `createPost(title: nil, wingId: currentID)`: the note lands in
  the wing's Pool.
- `MobileQuickNoteModel.mintNow` — her SW-5: `importPost(…, wingId: currentID)`, the current wing's Pool (the Mac
  Bookcase entry bar's rule; the Mac's quick-note PAD's Home rule is a different surface).
- `MobileCreateBookModel` — reads the wing ONCE at open (`wingID`, the sheet's snapshot) and uses it for the per-wing
  name guard (`assertBookNameIsFree(_:inWing:)`, VX-816) and the mint (`createReading(…, wingId:)`) — the Mac's
  VX-889 rule ("one snapshot names the wing for the name guard, the mint and the rule's tag vocabulary"); VM-59 adds
  the third use.
- New top-level tag — the tag manager's root create and typed path (VM-60's commit, 9462d3854). A note's typed tag
  already mints in the NOTE's wing (`TypedTagPath`, unchanged).
- **Today — a call the orchestrator should see:** `MobileTodayDoor.open` now passes `standingWing: currentID` to
  `createOrOpenJournalEntry`. That is Core's own input and the Mac's own call (VX-435, her ruling "A fresh ⌘J mint
  when no Journal lives: the wing you're standing in"): a LIVING Journal's entry is still born beside the Journal,
  wherever it is (scope call 4 holds — pinned: from Home, Today opens Work's entry when the Journal is in Work); only
  when NO Journal lives do the entry and the fresh Journal land where she stands (before, on the phone, always Home).
  Not PROVISIONAL — Core's contract and her VX-435 words decide it; named here because the brief said "Today's entry
  stays Core's".
- Untouched mints: `newPostInReading` (Core mints in the book's wing), the snippet pool (`createPool` — shared), lens
  mints (per note), the starter Journal's first-run seed (a virgin store, Home), the DEBUG seeders.

#### VM-60 — the tag manager per wing (W-229, audit F1 + F2)

`MobileTagsModel` lists the current wing's vocabulary (`allTags(_:wingID:)`) and, in the SAME read, the wing's name
(`Queries.wingName` — the Mac `TagsViewModel.start`'s `Listing`), re-read per wing through the follow; the header
says the Mac's words, "Tags — in ‹wing›" (R-828-2), through `WingWords.tagsTitle` — HOISTED from the Mac's
`TagManagerCopy.title`, which now forwards (byte-identical, pinned by `VM56MacWingScopePinTests` and the existing
`SettingsTagsWingFollowTests`). A root tag is born in the current wing, a child in its parent's (the op's rule); the
"+ new tag" typed path resolves against the current wing's tags only and mints its missing root there
(`MobileTagsModel.createMissing` gains a defaulted `wingID:`, forwarding to `TypedTagPath.createMissing`).

#### VM-59 — the wing-blind pickers (W-035; a Bug, pin before fix)

**Mechanisms, traced in code (inputs → wrong state):**
1. *Note tags.* `MobileNoteTagsModel.refresh` read `Queries.allTags(db)` — every wing. The sheet offers
   `suggestions(allTags…)`; a tap calls `applyTypedPath(path)` → `TypedTagPath.apply`, which resolves the PATH in the
   note's effective wing. A path that exists only in another wing has no live match there, so `createMissing` mints
   a root of that path in the note's wing and applies it: a Work note offered Home's "homeonly" gains a NEW Work tag
   "homeonly" — a twin she never asked for.
2. *Add to book.* `MobileMembershipModel.refresh` listed `Queries.readings(db)` — every wing's books and gatherings,
   same-name twins indistinguishable. Picking another wing's book → `addPostToReading` refuses
   `crossWingMembership` ("move the note here first" — a road the phone lacks).
3. *The gathering picker.* `MobileCreateBookModel.loadTags` listed every wing's tags; the v1 spec's PATHS normalize in
   the reading's own wing (`Operations.normalizedRuleSpec`), so a picked path the book's wing lacks becomes a dead
   rule term — a gathering that cannot collect on it.

**Pins** (`VariorumMobileTests/MobileWingBlindPickerTests.swift`, type `MobileWingBlindPickerTests`, commit
a690c8262 — the red-on-old tree): `aNotesTagSuggestionsReadTheNotesOwnWing` (the app stands in Home, the note is
Work's: the suggestions are Work's alone, and tapping every one leaves Work's vocabulary at `["trip"]` — red on old:
the tap minted "homeonly" in Work); `theAddToBookSheetListsTheNotesOwnWingsBooks` (the app in Home, the note Work's:
the offers are Work's "Essays" and Work's gathering alone); `theGatheringPickerWritesTermsFromTheBooksOwnWing` (the
sheet opened in Work offers Work's tags alone, and the gathering made from them names `[workTrip]` and no dead term).
The two note pins stand the app in a DIFFERENT wing from the note, so a fix that read the current wing stays red.
**Red-on-old: PENDING (stage window). Green: PENDING.**

**Fix** (171f514ad): the note's sheets read `Queries.effectiveWing(db, ofPost:)` inside their one read and list that
wing's tags / books and gatherings; the gathering picker reads the sheet's wing snapshot (the wing it mints in).
`Shared/TypedTagPath.swift` needed no change (it already resolves in the note's wing).

#### Tests (all written; every run PENDING the stage window)

Phone (`VariorumMobileTests`), new: `MobileWingStandTests` 6 · `MobileWingListingTests` 8 · `MobileWingMintTests` 4 ·
`MobileWingTagManagerTests` 2 (file `MobileWingsTests.swift`, one two-wing fixture `TwoWingWorld`: a note "Field
notes", a book "Essays" and a tag "trip" in EACH wing, plus a Home-only tag) · `MobileWingBlindPickerTests` 3. Mac
(`VariorumTests`), new: `VM56MacWingScopePinTests` 2.

**PHONE SUITES (the green run; type names):** the five above, plus the regression leg over every model and view this
batch touched — `MobileLibraryTests` `MobileLibrarySortTests` `MobileNavigationTests` `MobileShelfTodayDoorTests`
`MobileStarsTests` `MobileTrashTests` `MobileTagManagerTests` `MobileNoteTagsTests` `MobileMembershipTests`
`MobileBookCreateTests` `MobileBookNameGuardTests` `MobileBookPinTests` `MobileBookDetailsTests` `MobileQuickNoteTests`
`MobileFilterTests` `MobileFilterRowGeometryTests` `MobileShelfPerfTests` `MobileScrapsTests` `MobileDeletionTests`
`MobileShellTests` `MobileEmptyStoreTests` `MobileDailyJournalArchiveTests` `MobileStarterJournalTests`
`MobileShelfLayoutBrainTests` `MobileShelfRenderedLayoutTests` (the two types file `MobileShelfLayoutTests.swift` declares — the coordinator caught the file name) `MobileWriteLatchTests` `MobileRefusalTableTests`.
**MAC SUITES:** `VM56MacWingScopePinTests` `SettingsTagsWingFollowTests` `WingSwitcherTests`.
Results: PENDING.

#### PROVISIONAL calls (for QUESTIONS at the merge moment — the orchestrator carries them)

- **P-55-2 — how a root says its wing before wave 2's band.** Her SW-1: "the wing's name is the title on every
  root"; today's roots have one path line and no title row. Options: (a) the wing's name LEADS the path line — "Home ·
  Library" / "~/home/library" — today's line and tokens, the page word kept until wave 2's bar carries it; (b) the
  wing's name REPLACES the page word ("Home", "Home · 6 books") — the mockup's end shape, the page named by the tab bar
  alone; (c) a title row of its own above the path line — a layout change, VM-47's and wave 2's. **Built: (a)** — it
  says which wing on every root without restyling or losing the page's name, and wave 2's band replaces the line
  whole.

#### Observations for the orchestrator (not fixed — outside this batch's unit)

1. **The Bookcase scopes by the literal `wing_id = ?`** (`Queries.bookcaseReadings` and its three count statements,
   `Sources/VariorumCore/Queries/ShelfQueries.swift`), not `wingScope`'s dangling rule — so a book whose wing died
   (the sync race the rule exists for) shows on NO Bookcase, Mac or phone, while its notes read as Home's in the
   Library. Core, both platforms; a ticket candidate (Books area).
2. **A TEST bootstrap that reaches ready attaches `.standard`** — on the Mac before this batch, on both platforms
   now — so a protection-road suite reads the test host's (the Debug app's) `wing.current`, and `revalidate` writes
   `""` there when the remembered wing is not in the test's store (WingState's own header says a pin must never
   touch the host's defaults). Harmless on the phone today (a phone never switched, so nothing is written); a ticket
   candidate for wave 2 (Tests & tooling).
3. **Copy that assumes Home** — the empty Shelf's "No books yet — Today's Entry starts your journal." and the empty
   Library's sign-in line read oddly in an empty non-Home wing; unreachable until wave 2's switcher. Wave 2's (VM-72).

#### Canon deltas believed owed (the orchestrator applies at the merge)

- `notes/MobileSoul.md` §6 — PL-45's wing row: the phone now stands in a wing (memory, revalidation, scoped listings,
  mints, per-wing pickers and tag manager); the switcher, follow and management remain (wave 2).
- `notes/SurfaceContracts.md` — none (the phone's surfaces enter as each umbrella ships them; the catch-up plan's own
  line).
- AppSpec — none.

## Ladder

*(rounds, findings, dispositions)*

## Closeout

*(results, the ratify list, tickets filed, the rulings reconciled, MOBILE PARITY, canon-size)*
