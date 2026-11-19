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

On the interim wing door (2026-11-19, in chat), verbatim: "yeah - go ahead and add the plain interim door to this
run. then i can just install the build from after wave 1. i'll talk to vm-64 about this." Then, on the phone
install: "ok - this resolves the previous blocker. i'll tell everyone. but now, i'll plan to have the wave 1 build
installed on my phone after the last vm has merged in, by the last one. sound good? the phone step is the single
wave-1 install after all four runs have merged. whoever is last can probably do it overnight over wifi." The
orchestrator's answer: one install after all four merge, yes; unattended over wifi, no as the
install runbook stands (`notes/plans/vm-44/plans/vm-45-install-runbook.md` — the phone unlocked and awake at three
points, Variorum fully quit before the safety copy, cable-proven only); offered instead: the last merger builds
the Release app overnight and checks main's sync marker against production's, and the install runs at her first
touch in the morning.
Her answer, verbatim: "ok i'll do the hands part in the morning." — SETTLED: the last wave-1 merger builds the
Release phone app overnight from main's final wave-1 merge commit (signing verified, main's sync marker checked
against production's, the runbook's read) and leaves her morning block; the safety copy and the install run in
the morning with her at the phone. The coordinator names the last merger; the install is a REQUEST through it.

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
| VM-225 | An interim wing door: tap the wing's name on a root and pick from a list (minted mid-run at her word; a sub-issue of VM-55) | Feature | — (the tap half of W-017, pulled forward) | 4 |

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

1. **(SUPERSEDED mid-run by her word — batch 4, VM-225: a plain interim door joins this run; the rest of this
   call stands as written for the swipe, dots, management and follow.)** **No switcher in this run.** The swipe, dots, dropdown, follow and wing management are wave 2 (VM-72's
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

**Split at spawn into 2a (VM-61) and 2b (VM-62), a fresh implementer each. ONE stage window for both, run by 2b
(decided 05:10, when 2a stood READY behind a long queue: 2a's two legs were withdrawn, 2b builds on 2a's
built-for-testing-green tree at once, and 2b's window runs the whole phone target and the Mac leg over both
members — the original one-window shape of batch 2; 2b flips 2a's PENDING results and owns any red in them)** —
batch 1's five small members took one implementer past the 500k guideline, and these two are each a unit of
their own (the seam and its one line; the 69 sites and their pin). 2a builds the kickoff's VM-61 paragraph, its
tests and its record, and stops; 2b reads 2a's record and builds the VM-62 paragraph, and first applies P-55-11 (the orchestrator's check of 2a,
under Batch records: the directions among 2a's silenced lines keep their line). Everything else in the
kickoff binds both.

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

**Batches 3 and 4 share ONE stage window (decided at batch 2's close, requested of the coordinator): the whole
phone target, then the whole Mac target as its own QUIET claim — run by batch 4's implementer on the tree that
holds both.** So batch 3 has NO window of its own, superseding the "report READY" line of the kickoff below: its
implementer ends its turn at `BUILT` — both targets build-for-testing green, tests written, the record closed
with every run marked PENDING for the shared window — and names every file moved, split or newly added (the
coordinator trial-merges that list against the other wave-1 branches). Two more bindings for the hoist, from
batch 2: (1) the Mac's behaviour is byte-identical, which includes the status seam — a hoisted brain speaks
exactly the kinds it spoke on the Mac (a receipt stays a receipt; never `removal`, `withdraw` or the phone's
placement — `VM61MacStatusSeamPinTests` scans `Variorum/` for those roads, and a moved file leaves that scan, so
say in the record what now guards the moved brains); (2) merge order — this run is planned as the wave's FIRST
mobile merger, so the hoist does not wait for, and must not assume, any other umbrella's code.

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

## BATCH 4 — the interim wing door (VM-225)

**Carried from batch 3's record to this batch:** (1) the hoisted `WingsModel.currentName` answers "Home" before
the wings have been read, while batch 1's `MobileWingModel.currentName` answers nil until loaded — folding the two
must keep batch 1's rule (never a false "Home"; `MobileWingStandTests` pins it); (2) P-55-13 — four sentences the
shared brain speaks name Mac doors or keys ("unseal it", "Delete Wing…", "⏎ chooses · esc closes"): the interim
door must not put any of them on a phone screen; if the plain list can reach one, give the door its own plain
words as a DRAFT for her wording pass and say so.

**Batch 4's implementer also runs the ONE shared window for batches 3 and 4** (the note under BATCH 3): it reports
READY for the whole phone target and the whole Mac target once both targets build-for-testing green with its own
tests written, flips batch 3's PENDING results in batch 3's record, and owns any red in the hoist's suites.

Her word mid-run (2026-11-19, in chat), verbatim: "yeah - go ahead and add the plain interim door to this run. then
i can just install the build from after wave 1. i'll talk to vm-64 about this." — in answer to the orchestrator's
offer: "Tap the wing's name on a root, pick from a list of your wings, land on that wing's Bookcase. That is the
tap half of what you ruled for the wing title; the swipe, dots, wing management and following a note stay in
wave 2." It supersedes scope call 1's "no door": after this run the phone can change wings, plainly.

> You are the implementer for batch 4 of the VM-55 run, in `~/dev/variorum-vm-55` on `vm-55-wings-underneath`.
> Batches 1–3 are on the branch; read their record sections, this file whole and the reading list, plus the wing
> switcher frames and build notes of `notes/plans/vm-44/design/mockups/home-wings-capture.html`.
>
> **VM-225 — a plain interim door, one acceptance unit.** On each root (Starred, the Shelf, the Library) the
> wing's name in the path line (batch 1's P-55-2 shape) is a door: a tap opens a plain native list of the wings in
> the switcher's order (Home first), the current one marked; a pick switches the app's wing through the shared
> `WingState`, lands on that wing's Bookcase — the current wing included (the mockup's build note) — and every
> root re-scopes (batch 1's follow). No line is shown for the switch (her ruling: only removals and refusals).
> Compose the wing brains batch 3 moved to `Shared/` (the rows, the order, the adopt and revalidate); fold batch
> 1's interim `MobileWingModel` into them where they now cover it — never fork a brain on the phone. The list is
> read when it opens, off the main thread. The door's hit area is at least 44 pt tall; otherwise today's tokens
> and layout, no restyle (umbrella VM-47 owns sizes, wave 2 replaces this door whole).
> **Not in this batch:** the swipe and its dots, sizes beside the names, the ⋯ and wing management (make, rename,
> delete, move everything), following a note to its wing, moving or copying a note or book to a wing — all wave 2
> (VM-80 and umbrella VM-72).
> **PROVISIONAL calls to make and record** (2–3 options each, build the most defensible): what a switch does to
> screens already pushed on the three stacks (unruled until VM-80; the least destructive reading — nothing she
> has open is closed — unless the code makes that unsafe, and say why); whether the name is a door while the
> library has one wing (the Mac's ⌘L speaks a note there); the empty-wing lines that assume Home (batch 1's
> observation 3) only if a one-word fix exists in the Mac's own words — otherwise leave them and say so.
> **Tests:** the pick's state transitions (switch, land on the Bookcase, re-scope, remembered across a rebuilt
> session), the dead-wing return while the list is open, the one-wing case, a geometry check of the door's hit
> area. Stage rule as before: report READY with TYPE names and minutes, wait for the claim line.
>
> **Report back with** what shipped, how the hoisted brains were composed and what was folded, the PROVISIONAL
> calls, test counts, commits, anything for the author.

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
| Batch 1 — VM-56 | DONE (219b4ac62) — the batch closed green at 205abd983: phone 251 tests / 32 suites, Mac 13 / 3 |
| Batch 1 — VM-57 | DONE (219b4ac62) — the batch closed green at 205abd983: phone 251 tests / 32 suites, Mac 13 / 3 |
| Batch 1 — VM-58 | DONE (301388409) — the batch closed green at 205abd983: phone 251 tests / 32 suites, Mac 13 / 3 |
| Batch 1 — VM-60 | DONE (9462d3854) — the batch closed green at 205abd983: phone 251 tests / 32 suites, Mac 13 / 3 |
| Batch 1 — VM-59 | DONE (pins a690c8262, fix 171f514ad; red on old 3/3 in the stage window) — the batch closed green at 205abd983: phone 251 tests / 32 suites, Mac 13 / 3 |
| Batch 2a — VM-61 | DONE — its suites ran in batch 2's one window (run by 2b, three claims, 05:56–07:39): the Mac leg 1243/1245 + its Mac pin's re-run green after a test-only fix (8fa80d315, a false positive); the whole phone target 924 of 928 clean + 2 with declared known issues, VM-24's red main's, and one REAL defect its own host pin caught (the line ignored the home-indicator inset) — fixed b811aa743, re-run green (16/16 over the line's four types). Records: "Batch 2a record" and "Batch 2b record" (2a follow-ups 1 and 2) |
| Batch 2b — VM-62 (+ P-55-11, + batch 2's one stage window) | DONE — P-55-11 (be6f1d0c7) and VM-62 (pins 69005ad4a/15f788dfd, fix e8609cc6f) green in the whole phone target and the Mac leg; VM-62's red-on-old RAN at 15f788dfd from a snapshot worktree: the scan red (97 lines) and all five per-case pins red, the stripper oracle green; the window's two 2a follow-ups fixed and re-run green. Record: "Batch 2b record" |
| Batch 3 — VM-63 | DONE but one re-run — its suites ran in the shared window (batch 4's, 2026-11-19): every phone suite green (the hoist pin 5/5, whole phone target); a targeted Mac leg of its groups A–D + `CapabilityRegistryTests` + `StatusCenterTests` green but one test, the new `VM63MacWingBrainsHoistPinTests` pin's test-side dependency scope (fixed c75bdb9af; its re-run alone PENDING). Records: "Batch 3 record", "Batch 4 record" |
| Main merged in at the seam after batch 3 | DONE (871bde99a — main 359ae214d, VX-980's merge; clean, by the orchestrator; NOT yet built or tested on this branch — batch 4's builds and the shared window are the first on the merged tree) |
| Batch 4 — VM-225 (the interim wing door) + the shared window for batches 3 and 4 | DONE but one re-run — the door (5c80d058b) green in the whole phone target but the shell pin's test-side premise (fixed 931c77f79); the shared window ran (the whole phone target; a targeted Mac leg in place of the whole Mac target, which runs once at the merge gate); both targets build for testing green at c75bdb9af. PENDING: the follow-up claim — `MobileWingDoorShellTests` and `VM63MacWingBrainsHoistPinTests` alone on c75bdb9af's products. See "Batch 4 record" |
| Ladder round 1 | IN-PROGRESS — a fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim; the diff is `origin/main...vm-55-wings-underneath` at 5fea9a453 plus this notes commit; findings in `notes/plans/fixes/vm-55-ladder-round1.md` |
| The simulator walk (use-shaped evidence: a two-wing library, the three roots, a refusal line, a removal line with Undo) | NOT-STARTED |
| Closeout | NOT-STARTED |

Notes for the implementers:
- Baseline, CORRECTED 05:10 from the coordinator: the freshest whole-phone-target run of main's tree is umbrella
  VM-47's at 04:40 tonight, whose ONLY pre-existing red was VM-24's caret test,
  `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`. `nothingUserFacingNamesTheMac`
  (`MobileStructuralTests`) was NOT red there — the kickoff note that called it a standing known came from an
  October record and was stale. So: expect VM-24's red; if `nothingUserFacingNamesTheMac` is red on this branch it
  is THIS run's (a rendered string naming the Mac) and the batch that drew it fixes it. Every result line says which
  reds are on main and which are the branch's. A failure outside your diff is recorded, not fixed.
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
- Machinery seen in batch 1's window: after a phone run's verdict line lands, `xcodebuild` may not exit (it sat
  about five minutes printing only `IDESchemeActionSDKRecord … invalidDigitCount` lines, twice). Poll the log for
  the verdict line, never for the exit; stop your own process once the verdict is in.
- Batch 1 left ONE DerivedData dir with the fixed tree's products for both targets: `App/Variorum/DerivedData/vm55-b1`
  — later batches build incrementally into it rather than starting a cold one.
- Main moved under this run at 08:40 (VX-980: Mac search and Settings files, two `Registry/Capability*` lines, six Core
  search files) and is merged in at 871bde99a. ~~The coordinator's caveat: those Core search changes passed the whole
  Mac target and Core's headless suite but had NOT run under the phone-hosted suites when they merged — so on the
  merged tree a red in a phone listing, filter, tag or Trash suite may be main's, not this run's: name it and tell
  the orchestrator BEFORE chasing it.~~ LIFTED (the coordinator, relayed to batch 4): the targeted phone leg on main
  359ae214d ran green at 08:55 (128 tests in 13 suites, zero failed — the listing, filter, tag, Trash, stars,
  navigation, deletion, tray and versions suites; only MobileTrashTests' designed known issue). So on the merged tree
  the ONE pre-existing phone red is still VM-24's caret test; any other red is this branch's. The ledger's next free
  QUESTIONS number is #277; MobileSoul's newest parity row is PL-75.
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
change. The use-shaped simulator walk is the run's, after batch 3. The evidence this batch closes on is the
state-transition and view-model suites over a two-wing fixture, run in the stage window of 2026-11-19 03:50–04:02 —
all green, VM-59's pins red on the old tree (below).

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch
`vm-55-wings-underneath`. Reading list done in full before code (CLAUDE.md + loaded canon, MobileSoul §1–§5, the
resiliency protocol, the catch-up plan's inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1,
this file whole, SurfaceContracts' "The app" and "The Bookcase and books" wing bullets, both mockups' build notes).
DerivedData: one dir, `App/Variorum/DerivedData/vm55-b1` (gitignored), phone and Mac.

#### Batch 1 LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (b174f2754) |
| VM-56 — the current wing on the phone (readScope, bootstrap memory, held wings observation, root titles) | DONE (219b4ac62) — `MobileWingStandTests` 6/6 green; the Mac pin `VM56MacWingScopePinTests` 2/2 green (tests a0c54c57c) |
| VM-57 — every listing reads the current wing | DONE (219b4ac62) — `MobileWingListingTests` 8/8 green |
| VM-58 — mints in the current wing | DONE (301388409; the new root tag rides 9462d3854) — `MobileWingMintTests` 4/4 green |
| VM-60 — the tag manager per wing | DONE (9462d3854) — `MobileWingTagManagerTests` 2/2 green |
| VM-59 — the wing-blind pickers | DONE — pins a690c8262: 3/3 RED on the old tree (7 issues), 3/3 GREEN on the fix 171f514ad |
| Phone `build-for-testing` (`VariorumMobile`, the simulator's id) | DONE — green at 171f514ad |
| Mac `build-for-testing` (`Variorum`, macOS) | DONE — green at 171f514ad (same DerivedData dir) |
| Stage window | DONE — claim 03:50, released 04:02:45 (`Tools/stage release --who vm-55`). Leg 1 phone (32 suites): 251/251 passed. Leg 2 Mac (3 suites): 13/13 passed. Leg 3 red-on-old: exactly 3 reds, restored, `git diff` empty, green products rebuilt after the release. Simulator shut down; no Variorum instance; no new `Variorum-*.ips`; no Problem Reporter. Results below. **No revert is in flight.** |

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
**Red-on-old — RAN (04:02, the tree at a690c8262's three files, the diff verified to be exactly 171f514ad
reversed): 3 tests, 3 failed, 7 issues, every one a pin's own assert —** `aNotesTagSuggestionsReadTheNotesOwnWing` (L56
the list held Home's tags; L58 "homeonly" was offered to a Work note; **L67 Work's vocabulary became
`["homeonly", "trip"]` — the twin minted, observed**); `theAddToBookSheetListsTheNotesOwnWingsBooks` (L84 both
"Essays" offered; L86 both gatherings); `theGatheringPickerWritesTermsFromTheBooksOwnWing` (L103 every wing's tags
offered; **L112 the gathering's rule named a term that is not a live Work tag — the dead term, observed**). **Green on
171f514ad: 3/3** (inside the phone leg). Restored with `git checkout HEAD --`; `git diff` empty.

**Fix** (171f514ad): the note's sheets read `Queries.effectiveWing(db, ofPost:)` inside their one read and list that
wing's tags / books and gatherings; the gathering picker reads the sheet's wing snapshot (the wing it mints in).
`Shared/TypedTagPath.swift` needed no change (it already resolves in the note's wing).

#### Tests and results (stage window 2026-11-19 03:50–04:02)

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

**Results.**
- **Phone leg** (`test-without-building` on the green tree, 171f514ad, the iPhone 17 Pro / iOS 26.2 simulator booted
  fresh): Swift Testing "Test run with 251 tests in 32 suites passed after 178.097 seconds with 2 known issues";
  XCTest "Executed 0 tests" (Swift Testing suites); no `skipped:` lines. The 2 known issues are the declared ones in
  `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` (pre-existing,
  `withKnownIssue`). Reds: none; no load re-runs. **Machinery note:** xcodebuild did not exit after the run's last
  line (it sat ~5 minutes, its only output the `IDESchemeActionSDKRecord … invalidDigitCount` lines) and was stopped
  by hand; the red-on-old run's xcodebuild did the same. The verdict lines had landed both times.
- **Mac leg** (the dev-store Debug test host): "Test run with 13 tests in 3 suites passed after 0.893 seconds"; XCTest
  "Executed 0"; no `skipped:` lines; xcodebuild exit 0. Reds: none. No What's New sheet; no instance left.
- **Red-on-old** (VM-59): above, under the pins.

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

### Batch 2a record

**What this batch did NOT do (first, by the protocol):** nothing of VM-62 (batch 2b's) — no raw-error site is reworded;
where a slot that moves carries `String(describing: error)` today, its words ride onto the line unchanged and the site
is listed below for 2b. No new undo road (scope call 7). No restyle (VM-47 owns sizes: the line wears today's tokens).
Nothing under `Features/Protection/`, `Shared/Protection/`, `Sources/VariorumCore/Sync/` or custody. No Core change.
The use-shaped simulator walk is the run's, at the end.

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch
`vm-55-wings-underneath`. Reading done in full before code (CLAUDE.md + loaded canon, MobileSoul §1–§5, the resiliency
protocol, the catch-up plan's inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1, audit C N1/N5/N20
and §2, audit B §0.6/I3/I4/M2, this file whole, SurfaceContracts' Messages and wing bullets, the note-write mockup's D
frames and build notes, the home-wings, library-and-search, trash-archive-tags, comments-and-callouts and takes mockups'
line notes, `wording-list-2.md`). DerivedData: `App/Variorum/DerivedData/vm55-b1` (incremental, both targets).

#### Batch 2a LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (f058dcea5) |
| The seam shared (`StatusCenter` to `Shared/`, `session.status` on both platforms, the phone's placement rule) | DONE (88a124d84) |
| The phone's one line (the face, hosted once by the shell) | DONE (b6d5340f8) |
| The slots moved onto the line (Shell, Write, Takes) | DONE (c579da398) |
| The note's Undo never outlives its moment (any later word from the note takes its structural Undo line back) | DONE (96f79ccc2, in `MobileLine.say`) |
| Tests (the seam's kinds, the phone's show rule, the host, each door, the rewritten placement pins, the Mac pin) | DONE (96f79ccc2, 64df336d8) — results from batch 2's window (run by 2b): all GREEN — the Mac pin after its test-only fix (8fa80d315, a false positive; re-run 4/4), the host pin after the line's inset fix it caught (b811aa743; re-run with the line's four types 16/16); every other suite green in the whole phone target and the Mac leg |
| The inventory, the dropped lines, the 2b carry-over, the PROVISIONALs | DONE (this commit) |
| Phone `build-for-testing` (`VariorumMobile`, the window's simulator) | DONE — green at the commit after 4df669dd7 (the face fills the window: the door's frame in window coordinates, the foot measured from the window's foot — found on re-reading before READY, never run red) |
| Mac `build-for-testing` (`Variorum`, macOS) | DONE — green at 64df336d8 (same DerivedData dir; nothing compiled into the Mac changed after it) |
| The line and the lock (the coordinator's check before READY: relock, the app-switcher snapshot, the non-ready states) | DONE (6699560ce) — traced below; the snapshot road WAS open and is closed in the host (`Probe` follows its scene's edges); pin `MobileMessageLineSceneTests`; both targets rebuilt for testing green at 6699560ce |
| Stage window | DONE — RUN BY 2b (batch 2's one window, three claims, 05:56–07:39). Mac leg 1243/1245 (one false positive in its Mac pin, fixed test-only 8fa80d315, re-run green: 4/4); the whole phone target 928 tests — 924 passed, 2 with declared known issues, VM-24's red (main's), and one REAL branch defect its own host pin caught (fixed b811aa743, re-run green: `MobileMessageLineHostTests`, `MobileMessageLineGeometryTests`, `MobileLineDoorTests`, `MobileMessageLineInsetTests` 16/16). Every other 2a suite green. Detail: "Batch 2b record" ▸ the window's results. |

#### What shipped — the seam's shape, and why

**One seam, one brain, two faces.** `StatusCenter` moved (`git mv`) from the Mac's `Variorum/Registry/` to
`Shared/StatusCenter.swift`, and `AppSession.status` left the `#if os(macOS)` block: both platforms speak through ONE
`session.status`, the kinds decided at the door (refusal · offer · receipt — the three are unchanged). What differs per
platform is only WHERE a message shows — the placement — and that is one pure rule,
`StatusCenter.slot(kind:leavesPage:placement:receiptStyle:)`:

- the Mac's placement (`.receiptStyle`, the build's default there) is the shipped rule, unchanged: refusals and offers
  toast; a receipt toasts, sits on the quiet line, or is dropped, as `receipt_style` says;
- the phone's placement (`.phoneLine`, the build's default there) is her VM-44 ruling: refusals and offers always draw;
  a receipt draws only when its door says it took something OFF THE PAGE; `receipt_style` is never read (P-55-1). The
  phone has one slot (`current`); a dropped ordinary receipt leaves what is on screen alone (the Mac `.off` rule).

Three additions to the shared seam, each defaulted so every Mac item and pin reads unchanged: `Item.leavesPage` (set only
by the new `removal(_:undo:owner:)` door — a receipt in kind, so on the Mac it routes exactly as `receipt(_:)`; it may
carry its Undo with no words, the one exception to the empty-text guard, for the merge's shipped bare Undo); `Item.owner`
and `withdraw(owner:)` (a speaker takes back only its own line, only while it shows — the note screen's structural Undo
dies with the note). `deliver` was split into `deliver` → `place` so `removal` shares the routing step; the Mac's order
(route, replace, re-arm the 6 s clock) and its log line are unchanged. No Mac caller sets the placement, says `removal`
or `withdraw`s (source-scanned by the Mac pin).

**Why a shared brain and not a phone fork:** MobileSoul §3 and review focus 7 — a brain hoisted to `Shared/` (batch 3's
`WingsModel`, later umbrellas') speaks `session.status.refuse/receipt/removal` with no platform `#if`; each platform's
face decides where it shows from the class the door gave. The phone's show rule is a ruled compromise (her VM-44 words),
recorded once, in the one routing rule — not a second copy of the kinds.

**The phone's face — `VariorumMobile/Features/Shell/MobileMessageLine.swift`.** ONE line, hosted ONCE by the shell
(`MobileShellView`'s background installs it), drawing `session.status.current`: the words in `tokens.small` (a refusal in
the alarm ink every phone error slot wore; a removal in the muted ink and chrome casing every phone receipt wore; an offer
in ink), its door in the accent, on `tokens.room` with the tab bar's hairline — today's tokens, no restyle (VM-47 owns
sizes). It fades on the seam's own clock (`dismissAfter`, 6 s — the one auto-dismiss policy, refusals included:
P-55-3), animates in and out with an opacity transition, and announces its words to VoiceOver (it lives in its own
window). **It never pushes content: it floats in its own passthrough window** over the shell's scene
(`MobileMessageLineHost` → `MobileMessageLineWindow`, level `.normal + 1`), because half the phone's slots lived inside
SwiftUI sheets and a SwiftUI overlay on the shell draws UNDER a presented sheet (P-55-10). The window never becomes key
(`canBecomeKey == false`, shown with `isHidden = false`), so the focused text keeps the keyboard; it takes a touch ONLY on
the line's door (`takesTouch` against a frame the face reports — never SwiftUI's internal views, per the iOS 18/26
hit-test reports on hosting-controller-root windows); it rides above the tab bar on a root (the bar's MEASURED height,
via `onGeometryChange` on the shell's `tabBar`) and above the keyboard (the keyboard-frame notifications converted from
screen coordinates — the overlay is never key, so it does not rely on a non-key window's keyboard safe area; iOS keeps the
keyboard above every app window). It goes when the shell goes (the probe leaves its window, or is dismantled), so a line
never outlives the library it spoke for. The external facts behind these choices came from ONE Sonnet lookup (UIKit
window levels, keyboard frames, the iOS 18/26 passthrough reports); the unverified ones are pinned in the stage window by
`MobileMessageLineHostTests`.

**The doors' vocabulary — `VariorumMobile/Features/Shell/MobileLine.swift`.** A phone door says its class —
`.refusal`, `.ordinary`, `.removal(Undo?)` — and a removal's Undo is only ever a road that already exists (scope call 7):
`.structural` (the note's M20 door, `MobileUndoDoor.beginUndo(from: .receipt)`, so A12's warning still presents from
the note's masthead host), `.putBackNote` / `.putBackBook` (the Trash's own Put back ops — `TrashPutBack`'s `.note` and
`.book` arms, `restoreContainer` / `restoreReading`), `.unarchiveBook` (`unarchiveReading`). A landed Undo says nothing (a
restoration is ordinary); a refused one speaks the deletion story's words. **M20's stale-Undo law, carried onto the
line:** a structural Undo names the stack's top as it was, so ANY later word from the same note (a refusal, a removal, an
ordinary act the line drops, a success clearing its slot, an undo pressed in the ⋯ sheet) first takes back that note's
standing Undo line (`MobileLine.say` with the note's door) — the masthead's `statusMessage` `didSet` guarded exactly this
("a stale Undo button left standing beside a NEW sentence would offer to reverse something the sentence does not name").

**How the slots moved.** Every phone model keeps its slot property (`lastError`, `receipt`, `lastReport`,
`doorRefusal`, `status`, `statusMessage`/`statusAction`) as its own record of what it last said — the existing pins read
them; the Mac's AD-14 precedent ("view models keep their `statusMessage` properties … the app-level PRESENTATION is this
center's") — and hands the words to the seam with its door's class: a slot that only ever holds a refusal speaks from its
`didSet` (`MobileLine.refuse`); a mixed slot speaks through one explicit funnel per model (`say(_:as:)` /
`report(_:…)`). No screen draws its own slot any more. The note's masthead lost its status row and the receipt's
Undo/Redo buttons (`receiptAction`); the ⋯ sheet lost its `reportLine`; the note screen withdraws its own structural Undo
line in `onDisappear`.

**In the phone's editor-seam files, only the expressions that hand words to the seam changed** (no control flow, no seam
behaviour — focus 10). `Write/MobileEditorViewModel.swift`: `report(_:action:)` gained `line:` (default `.refusal`, the
class of all ~100 bare writers) and one forwarding line `MobileLine.say(message, as: line, session: session, door:
undoDoor)`; five direct `statusMessage = …` writes became `report(…)` (the autosave `onError` closure; the three
observation/delivery catches; `refuse(_:)`; `reportOperationError(_:)`) — the same assignment through the funnel; three
receipts gained their class (`copyNote` binds its outcome to pass `copied.line`; `deleteNote` → `.removal(.putBackNote(
postID))`; `saveVersion` → `.ordinary`). `Write/MobileStructural.swift`: nine `model.report(…)` receipts gained `line:` —
divide, extract, Make Block, New Block Below `.ordinary`; merge, block delete, archive, whole-paragraph delete, the
cross-block compound `.removal(.structural)`. `Shared/EditorBrain/` and `Write/MobileEditorTextView.swift` untouched.

#### The line and the lock (answered from the code at the coordinator's ask, before the stage window)

Who owns the overlay window's lifetime: **the shell.** `MobileShellView`'s `.background(MobileMessageLineHost(…))` places
one `Probe`; the probe raises the overlay when it joins a window with a scene (`didMoveToWindow`) and takes it down when it
leaves its window or SwiftUI dismantles it (`takeDown`: hidden, root controller dropped, released). The shell exists only
while `AppBootstrap.state` is `.ready` (`VariorumMobileApp`'s `switch bootstrap.state` — every other case renders a
different view, with no animation or transition on the switch).

1. **A relock while a line stands — the line cannot show over the lock screen.** `AppBootstrap.lockOnNewRoad()` (Lock Now,
   the relock coordinator's idle dial and full-close roads all end at `bootstrap.lock()`) runs `onWillLock`, then sets
   `state = .opening` synchronously and only later `finish(.roadLobby …)`. `.opening` replaces the shell with
   `MobileStoreOpeningView` in the same update, so the probe is dismantled and the overlay hidden before the lobby (a
   later state, after a detached task) can draw. The `StatusCenter` is the closed session's; the reopen mints a fresh one.
   Pin: `MobileMessageLineSceneTests` (the dismantle road: overlay gone and hidden, the scene no longer observed) and
   `MobileMessageLineHostTests` (the leave-the-window road).
2. **The app-switcher snapshot — it COULD show there; closed now.** `SnapshotPrivacy` is not a covering view: it is
   `.redacted(reason: .privacy)` applied to the shell's SwiftUI tree (and its presented sheets, through the environment)
   while the scene is not active, redacting only `privacySensitive` spans. An environment cannot reach a separate
   window's hosting controller, so a standing line would have ridden into the snapshot unredacted, above the page. (No
   line carries a `privacySensitive` span — Protection's faces do not speak through it — so it carried at most what the
   page shows; it was still a road the cover did not close.) **Fixed in the host only** (`Shell/MobileMessageLine.swift`,
   `Probe`): it observes its own scene — `UIScene.willDeactivateNotification` hides the overlay (posted synchronously
   before iOS snapshots the scene; a SwiftUI scene phase lands a pass later), `didEnterBackgroundNotification` hides it
   and withdraws every standing line (`status.clear()` — a 6 s line never outlives her leaving the app),
   `didActivateNotification` shows it again; an overlay raised over a scene that is not active starts hidden. A transient
   interruption (Control Center, a system alert) hides a line without losing it. `SnapshotPrivacy.swift`, Protection and
   the app file are untouched. Pin: `MobileMessageLineSceneTests.theLineNeverShowsOverAnInactiveSceneNorPastItsShell`
   (drives the three edges and asserts hidden / kept / withdrawn / shown, and that the observer is registered on its own
   scene).
3. **Any non-ready state (the lobby, library-missing, failed, the words card, the interlude, opening) — the line cannot
   show there.** Every road out of `.ready` assigns another `State` case (`state = .opening` at the reopen and lock seams,
   `finish(…)` for the lobby and the faces), and each case renders a view other than the shell, so the probe is
   dismantled and the overlay is down before the replacing view draws — the same mechanism as 1, pinned by the same
   dismantle pin.

#### The inventory (every per-screen message slot outside `Features/Protection/`, at kickoff)

Class: **refusal** (always draws) · **removal** (draws, with Undo where a road exists) · **ordinary** (draws nothing — her
ruling). "raw" = the words are `String(describing: error)` today, carried unchanged for 2b.

| File (slot) | The words | Class | What became of it |
|---|---|---|---|
| `Shell/MobileLibraryViewModel` + `MobileLibraryView` (`lastError`) | the listing, Pool, search and mint errors (raw) | refusal | the line (`didSet`); the Library's red slot removed |
| same (`receipt`) | "Note moved to the Trash — 30 days to put it back." (`RecoveryCopy.movedToTrashReceipt(.note)`) | removal | the line, Undo = Put back (`restoreContainer`) |
| `Shell/MobileStars` (`lastError` via `speak(_:at:)`/`speakHomeless`; drawn by the Library, Shelf and Starred roots through `error(on:)`) | "Refused: …" (raw `\(error)`) · store-read errors (raw) | refusal | the line; the three per-root slots removed (D2's per-root homes are moot with one line at the foot) |
| `Shell/MobileShelfViewModel` + `MobileShelfView` (`lastError`) | read, pin, mint and Today errors (raw) · delete/archive refusals (`DeletionRefusal`, `OpsRefusalCopy`) | refusal | the line |
| same (`lastReport`) | "Book moved to the Trash — 30 days to put it back." | removal | the line, Undo = Put back (`restoreReading`) |
| same (`lastReport`) | "Archived “‹name›” — it comes back when a day arrives (Today’s Entry)." | removal | the line, Undo = unarchive (`unarchiveReading`) |
| same (`lastReport`) | the Today door's shelving notes ("Entry saved. Your daily journal book is finished, so it wasn't added — …" and its four siblings, `MobileTodayDoor.shelvingNote`) | refusal (a direction: the entry was not filed — the Mac ⌘J door's own `status.refuse(note)`; P-55-7) | the line |
| `Shell/MobileBookViewModel` + `MobileBookView` (`lastError`, the header) and `Read/MobileReadView` (`lastError`) | the book's read errors (raw) | refusal | the line |
| same (`doorRefusal`, beneath + New Note / + New Chapter) | `MobileMembershipModel.refusal` words ("“X” is finished — reopen it…", "“X” is at its note cap.") | refusal | the line (at the screen's foot — never a screen away from the door) |
| `Shell/MobileTrashModel` + `MobileTrashView` (`lastError`) | put back / purge / listing refusals | refusal | the line |
| same (`receipt`) | Put back: `TrashPutBack.run`'s receipts ("Put back where it was." · "Put back where it came from." · the end-of-note and unplaced landings · "‹Kind› put back." · "“‹book›” is back with its N notes." · the take editions) | ordinary (a restoration — P-55-4) | dropped (listed below) |
| same (`receipt`) | "The Trash is empty — nothing to delete." | refusal (a door that did nothing) | the line |
| same (`receipt`) | Delete Now / Empty Trash: `TrashPurge.confirm`'s receipts (her 13j now/janitor sentences) | removal, no Undo (a purge has no road back) | the line |
| `Shell/MobileArchiveModel` + `MobileArchiveView` (`lastError`) | unarchive / listing refusals | refusal | the line |
| same (`receipt`) | "Unarchived — it's back in the library." | ordinary (P-55-4) | dropped |
| `Shell/MobileScraps` (`lastError`) | observation, refresh and mint errors (raw) | refusal | the line |
| `Shell/MobileTagManager` (`lastError`, in the tag sheet) | "Tag names can't be empty or contain “/”." · "A tag named “…” already exists." · "That tag no longer exists." · "Refused: …" (raw) · the empty typed-path hint · read errors (raw) | refusal | the line, above the sheet |
| `Shell/MobileBookDetails` (`lastError`, in the sheet) | rename / Finish / designate / delete / archive refusals (raw in three arms) | refusal | the line, above the sheet |
| same (no slot today) | delete and archive answered nothing here, while the shelf row's same acts spoke | removal | NEW here: the shelf row's own lines, with Put back / unarchive (P-55-8) |
| `Shell/MobileCreateBook` (`lastError`, in the sheet) | `BookNameCopy.refusal` ("A book named …") · tag-load and mint errors (raw) | refusal | the line, above the sheet |
| `Shell/MobileQuickNote` (`lastError`, under the box) | `MobileQuickNoteCopy.refusal` (the filing refusals) | refusal | the line; her words stay in the box |
| same (`boundaryNote`) | "earlier paragraphs live in the note — tap open ↵ to edit them" · "this note is saved — tap open ↵ to keep writing in it" | not a message — the box's standing state caption | stays (the capture box is VM-72's) |
| `Shell/MobileSettingsView` (`tutorialNote`, `perfNote` — `#if DEBUG`) | the DEBUG developer doors' readouts ("Seeding…", "Left as it was.", raw) | n/a — DEBUG instruments, not product surfaces | stays; its three raw sites are 2b's |
| `Shell/MobileStarterJournal` (`Outcome.refused`) | raw | n/a — never surfaced | untouched |
| `Write/MobileEditorViewModel` + `MobileWriteView`'s masthead status row (`statusMessage` + `statusAction`) | every editor gate, structural, takes, comments and block-menu refusal (the funnel's ~100 writers; raw in ten) | refusal (the funnel's default) | the line; the masthead row and its Undo/Redo removed |
| same | "Copied this note to the clipboard." | ordinary | dropped |
| same | "Copied this note to the clipboard — it has callout blocks, so the copy carries the takes saved in the note rather than the one on screen." | refusal class — a direction (P-55-7) | the line |
| same | "This note has no text to copy." · "Copy failed: …" (raw detail) | refusal | the line |
| same | "Note moved to the Trash — 30 days to put it back." (the ⋯ sheet's delete) | removal | the line, Undo = Put back; it survives the note's pop (owner nil) |
| same | "Saved a version — the whole note as it is now, in Versions." | ordinary | dropped |
| `Write/MobileStructural` (via `report`) | "Block deleted — ‹the tray's road›." (+ the stranded-originals note) | removal | the line, Undo = structural |
| same | "Block archived — ‹archivedForever›, in ‹the tray's archived road›." | removal | the line, Undo = structural |
| same | `blocksDeletedStatus(n)` (whole-paragraph delete) | removal | the line, Undo = structural |
| same | merge: a bare Undo, no words | removal (P-55-5) | the line, its Undo alone |
| same | the cross-block compound (select across paragraphs + ⌫/type): a bare Undo, no words | removal (it merges blocks — P-55-9) | the line, its Undo alone |
| same | divide: a bare Undo | ordinary | dropped (the ⋯ sheet's "Undo Divide" stays) |
| same | extract: "This block has 1 other take — it keeps this span." / "This block has N other takes — they keep this span." + a bare Undo | ordinary | dropped |
| same | Make Block: a bare Undo | ordinary | dropped |
| same | "New block added below — type away." | ordinary | dropped |
| `Write/MobileUndoDoor` (via `report`) | "Undid: ‹label›" + Redo · "Redid: ‹label›" + Undo | ordinary (the Mac `ShellActions`' class) | dropped (Undo and Redo stay in the ⋯ sheet) |
| same | "No structural change to undo." · "No structural change to redo." · "Undo cancelled — nothing changed." · the undo/redo-failed sentences · "Another structural change is still landing." | refusal | the line |
| `Write/MobileNoteActions` (`reportLine`, the ⋯ sheet's copy of `statusMessage`) | everything the funnel said while the sheet was up | — | removed: the line draws above the sheet |
| `Write/MobileNoteTags` (`status`, in the sheet) | the typed-path hint · `MobileTagsModel.refusal` words · read errors (raw) | refusal | the line (`didSet`) |
| `Write/MobileMembership` (`status`, in the sheet) | "Added to “X”." | ordinary | dropped |
| same | "Added by tagging #… — “X” collects by filter." | ordinary | dropped |
| same | "Already collected — it matches “X”'s filter." | refusal (did nothing — P-55-7) | the line |
| same | "“X” can't take this note: …" · the membership refusals · read and collect errors (raw) | refusal | the line |
| same | "Removed from “X” — the note itself is untouched." | ordinary (a pointer leaves, the note stays — P-55-4) | dropped |
| same | "Diverged — “X” holds the copy now, in the same place; the original is untouched elsewhere." | ordinary | dropped (the sheet's door to the copy stays) |
| `Write/MobileReferences` (`status`, in the sheet) | "Not a loadable link: …" · read/add/remove errors (raw) | refusal | the line (`didSet`) |
| `Write/MobileBlockList` (`status`, in the sheet) | read errors (raw) | refusal | the line (`didSet`) |
| `Write/MobileNoteTray` (`status`, in the sheet) | Put back: `RecoveryCopy.landingReceipt`, `PreservedOriginPutBack`'s receipts, `takeRestoredReceipt` | ordinary (P-55-4) | dropped |
| same | a take's Delete Now: `TrashPurge.confirm`'s receipt | removal, no Undo | the line |
| same | put back / purge / read refusals | refusal | the line |
| `Write/MobileVersions` (`status`, the pushed screen's foot) | "The note says this again — and where it was a moment ago is saved in Versions, so you can go back." · "This moment is a note of its own now, in the Library. It has left Versions." | ordinary | dropped |
| same | "The moment moved to the Trash — 30 days to put it back." | removal | the line, Undo = Put back (`restoreContainer`) |
| same | `VersionActs.words` refusals | refusal | the line |
| `Write/MobileComments` (via `report`) | comment refusals · read errors (raw) | refusal | the line |
| same (`restoredLabel` in the overlay) | the parked draft's caption | not a message — a draft-state caption | stays (comments are VM-192's) |
| `Write/MobileBlockMenu` (via `report`) | "Another act is still landing." · the callout/name refusals · the delete confirm's direction | refusal | the line |
| `Takes/MobileTakesBrowser` (via `report`) | "Take moved up." · "Take moved down." | ordinary | dropped |
| same | "That take is now the block below — the original is archived on its block, in the archived list under its takes." + Undo | removal (an archive) | the line, Undo = structural |
| same | `convertedNote` ("N takes are now their own blocks below — this block still shows the take it showed, and the originals are archived on it." + the blank-takes clause) + Undo | removal (archives) | the line, Undo = structural |
| same | the browser's verb refusals (raw in two) | refusal | the line |
| `Takes/MobileTakesController` (via `report`) | the choose ✓'s refusals (raw in two) | refusal | the line |
| `Takes/MobileBlockHistory` + `MobileBlockHistorySheetView` (`status`, the overlay's label; `commitNow` via `report`) | "Committed — a saved moment of this take is kept." | ordinary | dropped |
| same | "Saved moment restored into this take — the moments themselves are never overwritten, so nothing was lost." · "Take unarchived — it's back in this block's fan." · "Take put back — it's in this block's fan again." (and its archived edition) · the bring-back-an-original receipts | ordinary (P-55-4) | dropped |
| same | the history's refusals (raw in three) | refusal | the line; the overlay's status label stood down |
| `Takes/MobileLenses` (`status`, in the sheet) | "Adopted — the note now shows this view. The old arrangement is kept as the lens “‹name›”." · "Take unarchived — this lens is showing its pick again." · "Take put back — this lens is showing its pick again." (and its archived edition) | ordinary | dropped |
| same | "That take isn't here to restore — pick another one for this block." · the lens refusals · read errors (raw) | refusal | the line |
| `Write/MobileWriteView` (`canaryMessage`) | the TK2 canary's release diagnostic | not the seam's — a release-posture diagnostic | stays |
| same (the sealed state line + Unlock) | "this note is locked" + its door | state, not a message | stays |
| `Features/Protection/` (`MobileProtectionReceipts`) | Protection's receipts | — | untouched (scope call 6; its remainder is VM-103's at closeout) |

**Removal acts that say nothing today and stay silent** (their lines and words belong to their umbrellas — named, not
built): a comment's delete (VM-192; the drafted line "Comment deleted", `wording-list-2.md`, waits on her wording pass);
a take's delete or archive in the takes browser (VM-186; draft "Take deleted"); a tag's delete in the tag manager (VM-96 —
"Undo after deleting a tag"; the Mac has no line for a single tag); a lens's delete (no words exist anywhere).

**No phone door raises an offer today** (the one `status.offer` in shared code, the multi-book note, sits in
`AppSession`'s macOS block). The seam carries the kind and the face draws one always, with its door (P-55-6).

#### Every ordinary-act line that stops showing on the phone, verbatim (so she can call any of them back)

1. `Write/MobileNoteClipboard.swift` — "Copied this note to the clipboard."
2. `Shared/VersionsCopy.swift` via `Write/MobileEditorViewModel.swift` (Save a Version) — "Saved a version — the whole
   note as it is now, in Versions."
3. `Write/MobileStructural.swift` (New Block Below) — "New block added below — type away."
4. `Write/MobileStructural.swift` (Extract on a fanned block) — "This block has 1 other take — it keeps this span." /
   "This block has ‹N› other takes — they keep this span."
5. `Write/MobileStructural.swift` — the bare Undo button after a divide, an extract and Make Block (no words; the ⋯ sheet's
   Undo row stays).
6. `Shared/StructuralUndoCopy.swift` via `Write/MobileUndoDoor.swift` — "Undid: ‹label›" with its Redo button, and
   "Redid: ‹label›" with its Undo button (R10's receipt ping-pong; the ⋯ sheet's rows stay).
7. `Takes/MobileTakesBrowser.swift` — "Take moved up." · "Take moved down."
8. `Takes/MobileBlockHistory.swift` — "Committed — a saved moment of this take is kept."
9. `Shared/BlockHistoryFace.swift` via `Takes/MobileBlockHistory.swift` — "Saved moment restored into this take — the
   moments themselves are never overwritten, so nothing was lost." · "Take unarchived — it's back in this block's fan." ·
   "Take put back — it's in this block's fan again." · ~~"Take put back — it was archived, so it's in this block's archived
   takes, not the fan. Unarchive it there to bring it back."~~ (called back — a direction, P-55-11, batch 2b) · the
   bring-back-an-original receipt "Put back where it came from." (`PreservedOriginPutBack`) — ~~its end-of-note edition~~
   (called back, P-55-11).
10. `Shared/RecoveryCopy.swift` via `Write/MobileNoteTray.swift` and `Shell/MobileTrashModel.swift` (Put back) — "Put back
    where it was." · "Put back where it came from." · ~~the end-of-note and unplaced landings (`putBackAtEnd`,
    `putBackUnplaced`)~~ (called back — directions, P-55-11, batch 2b) · "‹Kind› put back." · "“‹book›” is back with its
    note." / "… with its ‹N› notes." · ~~"Take put back — it was archived when it was deleted, so it's among its block's
    archived takes, not the fan. Unarchive it there to bring it back."~~ (called back, P-55-11) (and the active-take
    edition, "Take put back.", which stays silent).
11. `Shell/MobileArchiveModel.swift` — "Unarchived — it's back in the library."
12. `Shared/VersionsCopy.swift` via `Write/MobileVersions.swift` — "The note says this again — and where it was a moment
    ago is saved in Versions, so you can go back." · "This moment is a note of its own now, in the Library. It has left
    Versions."
13. `Write/MobileMembership.swift` — "Added to “‹book›”." · ~~"Added by tagging #‹tags› — “‹book›” collects by
    filter."~~ (called back — a direction, P-55-11, batch 2b) · "Removed from “‹book›” — the note itself is untouched." ·
    "Diverged — “‹book›” holds the copy now, in the same place; the original is untouched elsewhere."
14. `Takes/MobileLenses.swift` — "Adopted — the note now shows this view. The old arrangement is kept as the lens
    “‹name›”." · "Take unarchived — this lens is showing its pick again." · "Take put back — this lens is showing its pick
    again." · ~~its archived edition, "Take put back — it came back archived, so this pick still shows the note's take.
    Restore again to unarchive it."~~ (called back — a direction, P-55-11, batch 2b).

The models still hold each sentence (the pins read them); calling one back is a one-word class change at its door.
*(Struck lines: called back by P-55-11 — the orchestrator's ruling, applied by batch 2b; see "Batch 2b record".)*

#### Raw-error sites carried over for batch 2b (VM-62)

The count is unchanged: **69 `String(describing: error)` sites across the same 23 files** (the LIVE STATUS notes' table
above). Every one now reaches a rendered string through the one line rather than a per-screen slot: through a slot's
`didSet` (`MobileLine.refuse`), a model's funnel (`say(_:as:)`, `report(_:…)`), or the editor's `report`. Ten carried
expressions changed SHAPE only (the raw text is byte-identical), so 2b's grep finds them at:
`Write/MobileEditorViewModel.swift` — `self?.report(String(describing: error))` (the autosave `onError`),
`report(String(describing: error))` ×3 (the observation and delivery catches), `report(OpsRefusalCopy.words(for: error,
roads: .phone) ?? String(describing: error))` (`reportOperationError`); `Takes/MobileBlockHistory.swift` —
`report(.refusal(String(describing: error)))` (the refresh catch); `Write/MobileMembership.swift` —
`say(String(describing: error), as: .refusal)` ×2 (refresh, collect); `Takes/MobileLenses.swift` —
`say(String(describing: error), as: .refusal)` ×2. Also for 2b's no-raw-error pin: the line renders `Item.text` in
`Shell/MobileMessageLine.swift` — every raw site's words reach the screen THERE now.

#### Tests (written; results: DONE in batch 2's window — all green after the window's two follow-ups; see "Batch 2b record" ▸ the window's results)

Phone (`VariorumMobileTests`), new — file `MobileMessageLineTests.swift`, four types: `MobileLineShowRuleTests` (11: the
phone's placement; the show-rule table over every kind × style; ordinary dropped AT the seam; refusal; removal with its
Undo; the wordless-Undo exception; an ordinary act never sweeps a refusal; `receipt_style` not read; the fade; a
speaker's withdrawal; the copy outcomes' classes) · `MobileMessageLineGeometryTests` (3: `footOffset`, `takesTouch`,
`keyboardOverlap`) · `MobileMessageLineSceneTests` (1: never over an inactive scene, never in the app-switcher snapshot,
withdrawn on the way to the background, gone with its shell) · `MobileMessageLineHostTests` (1: the host in a REAL scene window under a presented sheet — level,
never key, a touch only on the door, above the tab bar's inset and then the keyboard, nothing after the line goes, the
overlay goes with the probe) · `MobileLineDoorTests` (11: a deleted note's line + Undo = Put back, store read back; a
deleted book from the row and from Book Details, same line, Undo = Put back; the Journal's archive + Undo = unarchive; a
block delete with the note's own Undo, withdrawn as the note goes, pressed → the block back; the merge's wordless Undo,
pressed → unmerged; a confirmed Delete Now with no Undo; ordinary acts silent (divide, New Block Below, a star, joining a
book); a Put back silent; refusals always (the seal's gate, Empty Trash with nothing, a finished book); the note's Undo
never outlives its moment (a later ordinary act, an undo from the ⋯ sheet); nothing to undo refuses).

Phone, rewritten to the new placement (each pinned the per-screen slot this batch retires): `MobileUndoDoorTests` —
`theReceiptsUndoButtonPutsDeletedBlocksBack` (now the LINE's real Undo button, activated through UIKit),
`theReceiptsRedoButtonReAppliesWhatWasUndone` (a landed undo says nothing on the line; Redo through the ⋯ sheet's real
row), `aSilentStructuralActStillWearsTheUndoDoor` (a divide says nothing on the line; Undo through the ⋯ sheet's real row),
and the two A12 pins (they press the receipt surface's door — the one the line presses — since a divide draws no line;
the alert host and the confirm→act edge are unchanged); `MobileDeletionTests.aRefusedDeleteIsSpokenOnTheSheetThatRaisedIt`
(the refusal reaches the one line as a refusal while the sheet stays up, and the sheet keeps no slot);
`MobileNavigationTests.aRefusedBookDoorSpeaksBesideTheDoorSheTapped` (the door's refusal reaches the one line; the page
keeps no slot).

Mac (`VariorumTests`), new: `VM61MacStatusSeamPinTests` (4: the Mac's placement is her receipt style; the routing table
over every kind × style, a removal routing exactly as a receipt; the slots as shipped — quiet, toast, off, one message at
a time, the 6 s clock, the standing offer; a source scan that no Mac door says `status.removal(`, `.withdraw(owner:` or
`.placement =`). The existing Mac seam suites (`StatusCenterTests`, `StatusSeamVocabularyTests`,
`ConfirmationsSettingTests` …) ride the move unchanged.

**How each would fail on a regression** (VM-61 is a Feature; red-on-old does not bind): the file headers of
`MobileMessageLineTests.swift` and `VM61MacStatusSeamPinTests.swift` say it per pin — a phone placement that drew
ordinary receipts, dropped removals or read the style reds the table and the door pins; a wrong or missing Undo road reds
the press-and-read-the-store pins; a stale structural Undo reds `theNotesUndoNeverOutlivesItsMoment`; a host that sat
over the bar or the keyboard, took touches off its door or became key reds the host pin; a Mac build on the phone's
placement, an edit to the Mac branch, or a Mac door taking a phone road reds the Mac pin.

#### PROVISIONAL calls (for QUESTIONS at the merge moment — the orchestrator carries them)

- **P-55-3 — a refusal's lifetime on the phone.** Options: (a) every line rides the seam's one clock and fades by itself
  (the kickoff's "the line fades by itself"; the Mac's one auto-dismiss policy, which fades refusal toasts too); (b) a
  refusal stays until her ✕ or her next act (the captions of the note-write mockup's D5 and the home-wings frames 12 and
  28); (c) refusals hold a longer clock than removals. **Built: (a)**, no ✕ (the ✕ belongs to (b)).
- **P-55-4 — what "leaves the page" covers.** Her list is "a delete, a merge, an archive, a deleted tag". Options: (a)
  her list and its kin — note/book/block/paragraph/version deletes, merges (the cross-block join included), archives
  (blocks, the Journal, the takes the take-to-block doors archive), and the Trash's confirmed purges (no Undo — her 13j
  receipt sentences); restorations (Put back, unarchive, restore a commit, bring back) and pointer acts (leaving a book,
  diverging) are ordinary; (b) the trash-archive-tags mockup's reading — Put back and Unarchive also keep a line, drawn
  there with an "Open ›" door (wave 2's VM-96 face), while a confirmed Delete Now says nothing; (c) every row that leaves
  any page. **Built: (a).**
- **P-55-5 — the merge's and the cross-block join's words.** Options: (a) the shipped bare Undo, no words, now on the
  line; (b) the drafted "Merged" (`wording-list-2.md` — waits on her wording pass); (c) silence, the Undo in the ⋯ sheet
  only. **Built: (a)** — no new words, her "a line with Undo" for a merge.
- **P-55-6 — an offer on the phone.** No phone door raises one today. Options: (a) the seam carries the kind and the line
  draws an offer always, with its door (the Mac's "a question she cannot see is not asked"); (b) never drawn (her ruling
  names only removals and refusals); (c) drawn only with its door, like a removal. **Built: (a)** — drawn in ink.
- **P-55-7 — directions.** Sentences that report an outcome different from what she asked: the copy that could not
  follow the screen, "Already collected — …", the Today door's shelving notes. Options: (a) the refusal class (the Mac's
  `direct` — "a direction she must see"; the Mac ⌘J door speaks the shelving note as a refusal; "a door that did nothing
  speaks a refusal"); (b) ordinary (silent). **Built: (a).**
- **P-55-8 — Book Details' delete and archive now speak.** The shelf row's same acts had a line; the sheet's did not.
  Options: (a) the same act says the same line, with the same Undo road; (b) leave the sheet's doors silent as shipped.
  **Built: (a).**
- **P-55-9 — the cross-block compound is a removal.** Options: (a) a removal — it merges the touched blocks, and its
  bare Undo was R13's recorded replacement for the confirm she gave up; (b) typing, no line (the note-write mockup's
  carve note "No line: it is typing" for ⌫ at a seam). **Built: (a).**
- **P-55-10 — where the one line lives over a sheet.** Options: (a) ONE overlay at the screen's foot above everything the
  shell presents (its own passthrough window); (b) a line per presentation (the comments mockup draws its delete line "at
  the top of the sheet"); (c) a SwiftUI overlay on the shell only — a refusal raised in a sheet unseen until the sheet
  closes. **Built: (a)** — the brief's "hosted once by the shell" and "a refusal always draws".

#### Observations for the orchestrator (not fixed — outside this batch's unit)

1. **Stale docs naming the old seam:** `Features/Protection/MobileProtectionDoors.swift:185` says "The phone has no
   status seam (no toast, no `StatusCenter`)" — Protection is fenced (scope call 6), so it waits for VM-103 or the
   closeout; `Shared/SyncStatusViews.swift:~737` gives "the session's StatusCenter is a Mac member" as one of two reasons
   for its `#if os(macOS)` (the other — the restore hold is Mac-only — still holds), left untouched to keep this diff
   narrow.
2. **The Protection screen's receipts** (`MobileProtectionReceipts`) stay its own (scope call 6; audit row D-27 → VM-103).
3. **The one line has no ✕** (P-55-3 (a)); with VM-47's sizes the door's 44 pt hit area arrives there, not here.
4. **Batch 3's hoisted brains** can now say `session.status.removal(…, undo:)` from `Shared/`; on the Mac a removal is a
   receipt with an action, so the Mac's toast/quiet line would draw that action — a Mac behaviour change a hoist would
   own (the Mac pin's routing table holds the class; it does not hold an action's presence).

#### Canon deltas believed owed (the orchestrator applies at the merge)

- `notes/SurfaceContracts.md` "The app", the Messages bullet — the phone's half of the one seam: one line hosted by the
  shell over everything it presents; refusals and offers always; a receipt only when something left the page, with Undo
  over an existing road (structural undo, Put back, unarchive); ordinary acts draw nothing; `receipt_style` not read on
  the phone (P-55-1); the line fades on the seam's clock. Pointer: this record.
- `notes/MobileSoul.md` §6 — PL-22's receipts face call: answered by her VM-44 ruling and built here.
- AppSpec §12 "Messages carry a kind…" — at most one clause: the seam is both platforms'; the phone's placement is her
  ruled compromise (pointer to SurfaceContracts).

### The orchestrator's check of batch 2a (before its stage window; she is away — ruled PROVISIONAL)

Her leaving, as relayed by the coordinator `nov18` at 04:16 (her words to it, not to this session), verbatim: "ok
i'm off the mac. variorum is closed. i'm leaving for overnight. good luck with everything, tell all my sessions
that i'm off, rule provisionally in my absence, i'll check in in the morning (which is depressingly soon)."

Read: 2a's record whole. Three things follow.

1. **P-55-11 (PROVISIONAL, the orchestrator's) — a direction keeps its line.** Among the fourteen groups of
   ordinary lines 2a silenced, a few do more than confirm: they tell her the act landed somewhere other than where
   she would look, or did something beyond what she asked. Options: (a) all fourteen groups silent, as 2a built;
   (b) the directions among them keep a line, in P-55-7's class — the same rule 2a already applied to "Already
   collected" and the shelving notes; (c) every Put back and Unarchive keeps a line (the trash-archive-tags
   mockup's reading; wave 2's VM-96 face). **Ruled: (b)**, applied by batch 2b. The directions: a take put back
   that returns ARCHIVED rather than to the fan (the Block History, Trash and lens editions); a block put back at
   the end of the note or unplaced because its place is gone (`putBackAtEnd`, `putBackUnplaced`); "Added by
   tagging #‹tags› — “‹book›” collects by filter." (the add applied tags she did not ask for by name). Every other
   line in 2a's list stays silent and stays on her call-back list.
2. **The line's overlay window versus the lock.** P-55-10 hosts the line in its own window above everything the
   shell presents, and a line can carry a note's or book's title. Asked of 2a before its window: can a standing
   line sit over the lock screen after a relock, show in the app-switcher snapshot above the privacy cover, or
   outlive the shell in a non-ready state? Its answer (its record's "The line and the lock"): the lock screen and every non-ready state, no — the shell and
   its overlay are down before they draw; the app-switcher snapshot, YES — the privacy redaction rides the shell's
   environment and never reached the separate window. Fixed in `Shell/MobileMessageLine.swift` alone (6699560ce:
   the line hides as its scene resigns active and is withdrawn in the background), pinned by
   `MobileMessageLineSceneTests`.
3. **For umbrella VM-78 (told through the coordinator at this run's READY):** the phone's undo door no longer
   draws "Undid: ‹label›" with its Redo button — the ⋯ sheet's Undo and Redo rows stay; VM-16's fix lands on the
   one line's vocabulary (`Shell/MobileLine.swift`) when VM-78 merges this run's main in.

Kept as 2a built, on her ratify list: P-55-3 (a refusal fades on the seam's clock, no ✕ — the mockup captions
draw a refusal that stays until her ✕ or next act) · P-55-4 · P-55-5 · P-55-6 · P-55-8 · P-55-9 · P-55-10 · the
commit's line silent in Block History (the note-write mockup keeps a commit line with "Name…" for the future
quick row — that face is its own ticket's).

### Batch 2b record

**What this batch did NOT do (first, by the protocol):** *(kept current; final at the batch's close)* nothing under
`Features/Protection/`, `Shared/Protection/`, `Sources/VariorumCore/Sync/`, custody/keychain code or
`Shared/AppBootstrap.swift`; no Core change; no seam behaviour or control flow changed in the editor-seam files (the
error-to-words expressions only — each line named below); no Mac sentence changed; no restyle; no new undo road; no new
table row; the raw-error renders that live in fenced Shared code (the store-open failure's reason, the account deletion's
error, Protection's faces) are NOT reworded — named below for VM-103. The use-shaped simulator walk is the run's, at the
end. *(Final at the batch's close, 07:45.)*

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch
`vm-55-wings-underneath`. Reading done in full before code: CLAUDE.md + loaded canon, MobileSoul §1–§5, the resiliency
protocol, the catch-up plan's inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1, audit C N1/N5/§2.11,
audit B §0.6/I3/I4/M2, this file whole (2a's record whole, the orchestrator's check), SurfaceContracts' Messages and wing
bullets, the note-write mockup's D and G4 build notes, TEXTKIT2_NOTES §0/§4 (the seam files are touched in expressions
only). DerivedData: `App/Variorum/DerivedData/vm55-b1` (incremental, both targets).

#### Batch 2b LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (this commit) |
| P-55-11 — a direction keeps its line (Trash, tray, Block History, lenses, membership; the shared answer) | DONE (be6f1d0c7) — `MobileLineDirectionTests` 9/9 GREEN in the whole phone target (07:06–07:19); the Mac's put-back faces green in the Mac leg |
| VM-62 pin (red on this tree) | DONE (69005ad4a, strengthened at 15f788dfd) — RED ON OLD (07:36–07:37, the snapshot at 15f788dfd): `noPhoneSourceRendersARawError` failed, 97 offending lines; GREEN on the fix (whole phone target) |
| VM-62 per-case pins (Finish on a gathering, Reopen on a sealed book, rename, unseal, star) | DONE (69005ad4a, type `MobileRefusalSentencePinTests`) — RED ON OLD: all five failed, 3 issues each, the old texts the dumps (quoted in the results); GREEN on the fix |
| VM-62 fix | DONE (e8609cc6f) — GREEN: `MobileRefusalFallbackTests`, the rewritten `MobileRefusalTableTests`, every suite over a changed phone file (whole phone target) and `VM62MacRefusalWordsPinTests` + the Mac refusal/recovery suites (the Mac leg) |
| Phone + Mac `build-for-testing` at the batch's last code commit | DONE — phone green at b811aa743 (the line's inset fix) into `vm55-b1`; Mac green at 8fa80d315 (the pin fix; nothing the Mac compiles changed after it) |
| Stage window (2a's suites + 2b's; red-on-old) | DONE — three claims, 05:56–07:39, all released. Leg 2 Mac (1243/1245, one false positive → 8fa80d315); leg 1 whole phone target (928: 924 clean, 2 declared known issues, VM-24's main red, one real 2a defect → b811aa743); the last claim: (a) `VM61MacStatusSeamPinTests` 4/4 green, (b) the line's four types 16/16 green, (c) VM-62 red-on-old from the snapshot — 6 of 7 red as designed. Simulator shut down, no instance, no Problem Reporter, no new .ips; the snapshot worktree removed. |

#### P-55-11 — a direction keeps its line (the orchestrator's ruling, applied)

Every door that speaks a restoration now says whether its answer is a DIRECTION — the act landed somewhere other than
where she would look — and a direction speaks on the one line in P-55-7's class (`.refusal`, always drawn; the Mac's
`direct`); the model's own record is unchanged (a receipt stays a receipt — the existing pins on `trash.receipt`,
`tray.status`, `blockHistory.status` and `lenses.status` still hold). The fact lives beside the words it chooses
between, in `Shared/`, so the class and the sentence can never disagree:

- `Shared/RecoveryCopy.swift` — `isDirection(_ landing:)` (`.endOfNote`, `.unplaced` → true; `.itsOldPlace` → false) and
  `isDirection(_ status:)` (`.archived` → true), beside `landingReceipt` / `takeRestoredReceipt`.
- `Shared/RecoveryActs.swift` — `TrashPutBack.Outcome.isDirection`; `TrashPutBack.Answer` (receipt + flag);
  `TrashPutBack.answer(session:item:)` and `PreservedOriginPutBack.answer(session:postID:blockID:)` (an original with no
  successor left lands at the note's end — a direction; "Put back where it came from." is not). Both `run`s forward to
  their `answer` and return `.receipt`, so every Mac caller (`RecoveryView`, `TrayPanel`, `LineageFaceModel`, the bulk
  put back) reads byte-identical receipts.

The doors (the one-word class change each, plus the flag it reads):

| Door | The direction | Change |
|---|---|---|
| `Shell/MobileTrashModel.putBack` | an archived take; a block at the end / set aside; an original at the end | `TrashPutBack.answer` → `as: answer.isDirection ? .refusal : .ordinary` |
| `Write/MobileNoteTray` `putBackArchived` / `putBackDeleted` / `putBackOriginal` / `putBackTake` | the same four, from the note's tray | `report(…, direction:)`; `report` classes `isRefusal || direction` as `.refusal` |
| `Takes/MobileBlockHistory` `putBackTake` / `bringBack` | an archived take; an original at the end | `report(…, direction:)`, the same rule |
| `Takes/MobileLenses.restoreDangling` | a deleted pick that comes back archived (the pick still dangles) | `line = .refusal` when `RecoveryCopy.isDirection(restored)` |
| `Write/MobileMembership.collect` | "Added by tagging #‹tags› — “‹book›” collects by filter." | `.ordinary` → `.refusal` |

Every other line in 2a's list stays silent (its "stops showing" list above is updated in place, the called-back lines
struck with a pointer here). Pins — `VariorumMobileTests/MobileLineDirectionTests.swift`, type `MobileLineDirectionTests`
(9): each direction speaks with its exact words as a refusal, each door's twin that lands where she would look says
nothing (`session.status.current == nil`): the Trash's archived vs active take; the tray's archived vs active take; Block
History's; a lens pick back archived vs back in the fan; a block at the end of its note (the core's divide-W-then-delete
fallback fixture) and a block whose note is gone, through the Trash; the tray's end landing, an original beside its
successor (silent) and the other original after the successor's delete (the end — speaks); collect-by-tagging speaks while
joining a book stays silent; and the pure predicate table. Results: 9/9 GREEN in the whole phone target (07:06–07:19).

#### VM-62 — red-on-old, the method (written before the fix)

The pins are committed ALONE, on the tree with 2a + P-55-11 and none of the fix (69005ad4a, then strengthened by the
commit "VM-62: the pin also catches the Refused idiom under any name" — a pathspec commit of the pin file and this record
only, so its tree still holds none of the fix); they compile there (the
per-case pins name their expected sentences through `OpsRefusalCopy.words(for:roads:)`, which exists on that tree). The
red-on-old run is made **AT the strengthened pin commit** (named by hash in this record's next commit): in the stage window, after the green legs, the worktree is checked out DETACHED
at this commit (`git checkout <pin-commit>`), the phone target is built for testing into `vm55-b1` (incremental), the two
pin types run (`-only-testing` `MobileNoRawErrorPinTests` `MobileRefusalSentencePinTests`), and the branch is checked
back out (`git checkout vm-55-wings-underneath`), `git status` clean, the green products rebuilt after the release. **A
successor finding the worktree detached at this commit is mid-red-on-old: `git checkout vm-55-wings-underneath` restores
it — nothing uncommitted is ever left across it.** Expected red: the scan names every offending line (97 on that tree, per
the throwaway mirror of the scan in the session scratchpad), and each of the five per-case pins fails on its slot/line
text (the old doors spoke the dump or "Refused: …").

The strengthened pin commit, by hash: **15f788dfd** (the red-on-old checkout target).

**REPLACED at the coordinator's word (07:25) — no revert in place.** The red-on-old does NOT check out the pin commit in
this worktree and never replaces `vm55-b1`'s products. Instead a DETACHED SNAPSHOT worktree at 15f788dfd,
`~/dev/variorum-vm-55-pin` (`git worktree add --detach`), is built for testing HEADLESS before READY into its own DerivedData
dir, `variorum-vm-55-pin/App/Variorum/DerivedData/vm55-pin` (a cold build, no stage); in the claim the two pin types run
from the snapshot (xcodebuild run IN the snapshot worktree, so the source scan reads the pin tree's sources); after the
release the snapshot is removed (`git worktree remove`, its DerivedData with it). This worktree stays on the branch
throughout — nothing is reverted here at any point.

#### VM-62 — refusals in plain words (a Bug: the mechanism, the pins, the fix)

**Mechanism, traced (inputs → wrong output).** A phone door catches an error and hands its words to the one line (2a's
`MobileLine` / a slot's `didSet` / the editor's `report`). Three expression shapes put raw error text there: (1) 69 sites
wrote `String(describing: error)` — the enum dump, e.g. `wrongReadingKind(id: "…", expected: …)`; (2) three wrote the
`"Refused: \(…)"` idiom (`MobileStars`, `MobileMembership`, and `MobileTagManager` under the name `op`); (3) about thirty
reached a dump ONE STEP DOWN, in shared code: `DeletionRefusal.words`/`.fallback` end in "That couldn't be done — ‹the
dump›." and `VersionActs.words` falls to it. The audit's named cases, each traced: **Finish on a gathering** —
`MobileBookDetailsModel.setFinished(true)` → `lockReading` throws `wrongReadingKind(expected: .book)` → `refusal(_:)` →
`DeletionRefusal.words` → no arm → `fallback` → "That couldn't be done — wrongReadingKind(…)." (B §0.6/I3); **Reopen on a
sealed book** — `unlockReading` throws `readingSealed` → the same road → the dump (B I4); **rename** — the note's
`renameNote` → `renameContainer` on a note gone under it throws `containerNotFound` → `report(String(describing:))` (C N1);
**unseal** — `unlockNote` → `unlockPost` throws `noteInSealedBook` → `report(String(describing:))` (C N5); **star** —
`MobileStarsModel.toggle` on a note gone under the press → `setStarred` throws `containerNotFound` → `"Refused: \(error)"`
(B M2).

**The pins — committed alone, before the fix** (69005ad4a, strengthened at 15f788dfd; file
`VariorumMobileTests/MobileRawErrorPinTests.swift`):

- `MobileNoRawErrorPinTests` (2) — **what it checks:** every `.swift` file under `VariorumMobile/` (all folders, Protection
  and Spike included), comments stripped and code + string contents kept (line numbers preserved), fails on any line
  holding `String(describing:`, `String(reflecting:`, `.localizedDescription`, an interpolated `\(error)` / `\(err)` /
  `\(failure)` / `\(op)`, the `"Refused: \(…)"` idiom under any binding, or a call to `DeletionRefusal.fallback(` /
  `DeletionRefusal.words(` / `OpsRefusalCopy.message(` / `VersionActs.words(`. Exempt: an `os.Logger` call line or a wrapped
  line of one (an `OSLogMessage` `privacy:` argument), and two named never-surfaced lines in `MobileStarterJournal.swift`
  (its `.refused` outcome, which only the first-write notice logs) — each exemption must match exactly one line. Plus an
  oracle test of the comment stripper. **What it cannot see:** (1) Shared code the phone renders that dumps inside itself
  (below, "Remainders"); (2) an error under another name outside the "Refused:" idiom, or passed through a variable first —
  it matches names, not types; (3) whether a forbidden expression would render — it forbids them everywhere in phone code
  but the log; (4) a `//` inside a literal nested in an interpolation can hide the rest of that line (the
  `stringLiteralContents` walk's recorded limit). Red on old: 97 offending lines (the throwaway mirror's count).
- `MobileRefusalSentencePinTests` (5) — each named refusal through its REAL door over a real store, asserting the shared
  table's phone-road sentence (`OpsRefusalCopy.words(for:roads: .phone)`) on the model's slot AND on the one line (kind
  `.refusal`), and no case name on the screen: `finishOnAGatheringSpeaksTheTablesSentence`,
  `reopenOnASealedBookSpeaksTheTablesSentence`, `renamingANoteThatIsGoneSpeaksTheTablesSentence`,
  `unsealingANoteInASealedBookSpeaksTheTablesSentence`, `starringANoteThatIsGoneSpeaksTheTablesSentence`.

**The fix (e8609cc6f).**

- `Shared/OpsRefusalTable.swift` — `OpsRefusalCopy.unexpectedFailure` (the ONE plain fallback, DRAFT — P-55-12) and
  `OpsRefusalCopy.sentence(for:roads:)`: the table's words, else the plain fallback, the raw detail to the unified log
  (`io.lduarte.Variorum` / `refusals`, `notice`, `String(reflecting:)`). **No table row added; no row's words moved** (the Mac
  pin holds a spread, and `words(for:)`'s switch is untouched).
- `Shared/RecoveryActs.swift` — `DeletionRefusal` split into `knownWords(_:act:)` (its arms, nil where none) and its last
  resort: `words` = `knownWords ?? fallback` (byte-identical); the phone's `sentence(_:act:roads:)` = `knownWords ??
  OpsRefusalCopy.sentence`; `plainFallback(_:roads:)` = `fallback`'s twin (a `RecoveryRefusal`'s sentence, else the table,
  else the plain fallback — never the deletion arms, which a `fallback` door never meant).
- `Shared/VersionActs.swift` — the same split: `knownWords(_:seal:)`; `words` byte-identical; the phone's
  `sentence(_:roads:)` = `knownWords(seal: roads.seal) ?? DeletionRefusal.sentence(roads:)`.
- Every phone site moved onto these roads (by file, the changed lines at e8609cc6f): `Shell/MobileArchiveModel` 108,140,142 ·
  `MobileBookDetails` 99,171,194,212,235 (+doc 228) · `MobileBookViewModel` 147 · `MobileCreateBook` 78,189 ·
  `MobileLibraryViewModel` 333,353,400,425,494 · `MobileLine` 148,162 · `MobileScraps` 142,171,190,222 ·
  `MobileSettingsView` 448,476,510 (the DEBUG developer readouts) · `MobileShelfViewModel` 88,101,141,151,215,232,248 ·
  `MobileStars` 146,159,182,211–213 (the two catch arms merged — both spoke at the door's root) · `MobileTagManager`
  88,100,190,200 · `MobileTrashModel` 112,148,153,223,251 · `Takes/MobileBlockHistory` 283,578,588 · `MobileLenses`
  303,330,557 · `MobileTakesBrowser` 872,926 (+doc 868) · `MobileTakesController` 251,264 (+doc 257) · `Write/MobileBlockList`
  147,169 · `MobileBlockMenu` 461,468 (+doc 458) · `MobileComments` 137,290,296 (+doc 286) · `MobileMembership`
  122,161,201,215 (+doc 198) · `MobileNoteTags` 93 · `MobileNoteTray` 187,395,397 · `MobileReferences` 132,158,171 ·
  `MobileUndoDoor` 303,310 (+doc 297) · `MobileVersions` 150,178,202,218,236.
- **The editor-seam files — the error-to-words EXPRESSION only, no control flow, no seam behaviour (focus 10):**
  `Write/MobileEditorViewModel.swift` lines 227 (autosave `onError`), 595, 663, 676 (the observation/delivery catches), 1079
  (the copy failure's `.failed(…)` detail), 1203 (rename), 1262 (Save a Version: `VersionActs.sentence`), 1298
  (`deleteNoteRefusal`: `DeletionRefusal.sentence(act: .delete)`), 1320 (seal/unseal), 1355, 1358 (entry date),
  2323 (`reportOperationError`), and two doc comments made true again (1291–1292, 2320–2321);
  `Write/MobileStructural.swift` lines 140, 281 (the fan reads' catches), 965 (`refusalMessage`'s non-op guard), 1014 (its
  `default`). `Shared/EditorBrain/`, `MobileEditorTextView`, `BlockRangeIndex` untouched.

**Sentences — the DRAFTS for her wording pass (new or newly composed words), verbatim, with their sites:**

1. **"That couldn't be done."** — `OpsRefusalCopy.unexpectedFailure` (`Shared/OpsRefusalTable.swift`); spoken at every phone
   site above wherever no table or family has words (a failed store read, an unworded case). PROVISIONAL P-55-12.
2. **"Copy failed: That couldn't be done."** — the note's Copy door on a failed read (`Write/MobileEditorViewModel.swift:1079`
   → `MobileNoteClipboard.Outcome.failed`'s "Copy failed: ‹detail›" — the Mac's own shape, `TakeClipboard`'s "Copy failed:
   ‹OpsRefusalCopy.message›"); "Copy failed: ‹the table's sentence›" where the table words the case.

**Existing sentences the phone now reaches where it dumped before** (no new words; for her eye, since two are the table's
PHONE-ROAD forms — the phone has no book Unseal door yet, so the shared table's book-seal road is `verb: nil`):
Finish on a gathering — "That isn't a book — a gathering shows the notes its rule matches and holds none of its own." (the
Mac's own `wrongReadingKind` sentence) · Reopen on a sealed book — "This book is sealed, so it can't be reopened here."
(the Mac's: "This book is sealed — unseal it to reopen it.") · unsealing a note in a sealed book — "This note is in a book
that is sealed, so it can't be changed here." (the Mac's: "… — unseal the book to change it.") · a note gone under a rename
or a star — "That note isn't there any more — it may have just been deleted." (the Mac's, byte for byte — its StarsModel
speaks `OpsRefusalCopy.message`) · the autosave refused by a seal arriving by sync — "This note is locked — unlock it
first." (the table's phone-road sentence, was `lockedPost(id: …)`).

**Tests.** Phone: the pins above; `MobileRefusalFallbackTests` (5, `VariorumMobileTests/MobileRefusalFallbackTests.swift` —
the plain fallback; the table first; the deletion and versions families keep every arm and end plain while their Mac
roads keep the shipped last resort; no phone road carries a case name or an associated value over a spread of 16 errors).
**Two justified edits** of guards that pinned the dump VM-62 retires (`MobileRefusalTableTests`):
`eachSiteKeepsItsOwnFallbackWhereTheTableHasNoWords` → `eachSiteSpeaksThePlainFallbackWhereTheTableHasNoWords` (five sites
now speak the plain fallback for `referenceNotFound`); `theCrystallizersErrorVoiceSpeaksTheTable`'s last line (a
non-operation error now speaks the plain fallback, not its description). Mac: `VM62MacRefusalWordsPinTests` (4,
`VariorumTests/VM62MacRefusalWordsPinTests.swift` — `DeletionRefusal.words`/`.fallback`, `VersionActs.words`,
`OpsRefusalCopy.message` answer as shipped; a spread of rows unchanged and none added; a source scan that no Mac file
speaks the phone's new roads). Results: GREEN — the phone suites in the whole phone target (07:06–07:19), the Mac pin in
the Mac leg (05:56–06:05); red-on-old for the pins at 15f788dfd in the last claim (07:35–07:39) — see the window's results.

**PROVISIONAL (for QUESTIONS at the merge moment — the orchestrator carries it):**

- **P-55-12 — the one plain fallback's words.** Options: (a) "That couldn't be done." — the shared deletion fallback's own
  sentence with the dump dropped (both platforms already speak its stem); (b) "Something went wrong — try again." — the
  Protection faces' register (`ProtectionWords.somethingWentWrong`); (c) a fallback per door naming its act ("This list
  couldn't be read.", "The tag wasn't saved.") — plainer, but some thirty new lines for her pass. **Built: (a)** — the
  brief's "ONE plain fallback sentence from the table", the closest existing words, claiming nothing about what changed.

**Remainders — raw error text the phone can still render that this batch could not reach (fenced, named for their
owners; the pin cannot see them):**

1. The store-open failure screen (`VariorumMobile/MobileStoreFailureView.swift`) renders `error.reason`, which
   `Shared/AppBootstrap.swift` (lines ~466 and ~1536) builds from `String(describing: error)` — the Mac's
   `StoreFailureView` shows the same. `AppBootstrap` is the store-open/custody road: **VM-103's remainder** (the lock
   umbrella), with D-27.
2. The account's deletion failure (`Shared/AppServices.swift` ~644–646: a non-network error becomes `String(describing:)`
   in `account.lastError`), rendered by `Shared/AuthViews.swift`'s `AccountView` — on the phone from the Protection screen
   and the sync row. Custody/account: **VM-103's remainder** (or the first-run umbrella VM-197's account face).
3. `Features/Protection/`: the grep finds no raw-error expression there; it renders `lobby.lastError`
   (`MobileLibraryMissingView`, from `AppBootstrap`'s `create()`) and `ErrorCauseNote` — the verbatim cause is her R94
   ruling (the sync row's "detail renders inline"), not a dump to fix. **VM-103's** to read with the rest.
4. Shared helpers with a `String(describing:)` the phone does not render today (`PlaintextExportModel`, `MarkdownInsurance`,
   `StarredGatheringSeeder`, `SampleLibrary*`, `IdleCommitScheduler.lastError`) — none reached from `VariorumMobile/`;
   listed so the next face that renders one knows.

**Observations for the orchestrator (not fixed — outside this unit):** `.lockedReading` stays Mac-half-only in the table
(its sentence says "unseal", the Mac's door word); the phone speaks it through `DeletionRefusal`'s platform-neutral arm
wherever a deletion-family door meets it, and a non-deletion phone door meeting it would now speak the plain fallback
(none found). `MobileMembership`'s, `MobileQuickNote`'s and the other door-local arms are unchanged.

**Canon deltas believed owed (the orchestrator applies at the merge):** `notes/SurfaceContracts.md` "The app", the
Messages bullet (the phone's half, extending 2a's owed delta): a refusal on the phone always speaks in words — the shared
table's sentence where it has one (the Mac's wherever the road is the same), else one plain fallback; the raw detail goes to
the log, never the screen (VM-62); and a restoration that landed somewhere other than where she would look keeps its line
as a direction (P-55-11). AppSpec — none. MobileSoul §6 — none beyond 2a's.

#### Batch 2's one stage window (READY — the legs, by TYPE)

Leg 1 — **the whole phone target** (`-only-testing:VariorumMobileTests`; 2a's reason stands: nearly every phone test file
touches a changed type, and 2b changed thirty phone files' error expressions), test-without-building on e8609cc6f's
products, the window's standing simulator booted fresh. ~25 min (batch 1's 32-suite slice took 3 min; the target is ~5×
that, plus the host and pointer suites).

Leg 2 — **the Mac**, the dev-store Debug test host, test-without-building on e8609cc6f's products. 2a's 41-type READY list
is NOT in this repo record (its READY line points at "the stage window" without naming the types); the orchestrator's copy
of it may stand in for the first group below. As written here: **(A) the types every Mac test file that reads the seam
names or its slots declares** (`StatusCenter`, `StatusToast`, `QuietReceiptLine`, `.status.current`/`.quietLine` — a
superset of 2a's 41), and **(B) every Mac type whose file names what 2b changed in `Shared/`** (`OpsRefusalCopy`,
`OpsRefusalRoads`, `SealedNoteCopy`, `DeletionRefusal`, `VersionActs`, `TrashPutBack`, `PreservedOriginPutBack`,
`RecoveryRefusal`, the landing/take receipts, the tray/recovery/lineage/versions faces) — 172 types in all, each declared
exactly once (checked). ~15 min.

(A) `AscentDoorTests AscentRoutingTests AutosaveRegistryLifecycleTests AutosaveRegistryReleaseGuardTests BindDoorTests
BlockHistoryPaletteDoorTests BlockTOCStatusTests BookAnchorTests BookArrivalsReviewTests BookArrivalsTests BookCarryTests
BookcaseBoardBrainTests BookcaseStarredShelfBrainTests BookcaseStarredShelfDropTests BookcaseViewModelTests
BookChooserOrderTests BookIndexEditingTests BookNamePerWingDoorTests BookPanelActingTests BookPanelBrainTests
BookPanelDeclarationTests BookPanelDragGateTests BookSettingsSheetTests BookStateDoorsTests BoundaryFluidityTests
CalmAsksTests CaptureMicrosyntaxDoorTests CommandRouterTests ConfirmationsSettingTests ContextBarTests CopyAllTakesDoorTests
DestructiveUndoWarningTests DivergeDoorTests DuplicateDoorsTests EncryptionBookDoorTests FormattingSurfacesTests
LaunchFurnitureTests MCPGonePlaceNamesTests MCPNavigationTests MCPShareFacesCaptureTests MCPShowOfferFacesTests
MCPTrailDoorTests MCPTrailFoldTests MCPTrailHandDoorTests MCPTrailHandModelTests MCPTrailModelTests MCPWingFacesTests
MembershipChoiceTests MoveAndExecuteTests MoveToShelfGateTests MultiBookEditNoteRuleTests MultiBookEditNoteTriggerTests
OutflowChooserTests PagedAnchorReportTests PrinceFreshStoreTests PrinceSeedTests PrivateMarkFaceTests
QuickEntryFileWithoutOpeningDeclarationTests QuickEntryFileWithoutOpeningKeyTests QuickEntryFileWithoutOpeningModelTests
QuickNoteDoorTests QuickNoteMintTests QuickNoteParkTests QuickNoteWindowTests QuickNoteWordTests RemoveReleaseDoorTests
RuleEditorMakeTagTests RuleEditorTests SampleLibraryWelcomeTests SealDoorTests SealedBookMemberDoorTests
SearchPickerBrainTests StaleWriteIntentTests StarActingTests StarDeclarationTests StarTargetingTests StatusCenterTests
StatusSeamVocabularyTests StatusToastPlacementRuleTests StatusToastPlacementShellTests TakesLandingTests TakesWordCountTests
TakeToBlockDoorTests TimelineAndReadingsTests TourClosingCardTests TourEndCardAsideGateTests TourEndCardTests
TourEngineTests TourEntryTests TourPoolTuckTests TourScriptTests TourSpotlightTests TutorialBookShapeTests
TutorialDeletionActsTests TutorialDoorTests TutorialFannedMatrixTests TutorialLibraryActsTests TutorialLookingActsTests
TutorialPrivacyChapterTests TutorialStructureActsTests TutorialTakesActsTests TutorialWherePlacesActsTests
TutorialWritingActsTests VM61MacStatusSeamPinTests VocabularySweepTests VX385PoolQuietReceiptTests
VX775ActivityLogFailureDoorTests`

(B, the ones not already in A) `ArchivedBooksGroupTests ArchivedMarkTests BlockHighlightTests BlockHistoryPaneTests
BlockSelectionRegistryTests BlockSelectionRuleTests BoardBlockSelectionTests BookArchiveDeclarationTests
BookArchiveDoorActTests BookSettingsArchiveRowTests CapabilityRegistryTests ChromeMinHeightTests ComesBackReceiptTests
CommentPanelFixLeg2Tests CommentPanelGeometryRuleTests CommentPanelWordsTests CommentTextAreaMountedTests
CommitVocabularyTests CompareCompositionTests CompareViewModelTests FreeTypedTagTests GatheringKindWordTests
IAAndTrashShapeTests LifecycleFacesTests LineageFaceModelTests MCPWireRefusalSweepTests NoteTrayTests NoteVersionsPaneTests
OpsRefusalTableIntegrityTests PaletteDerivationTests RecoveryDoorsTests RefusalTableConvergenceTests SavepointCommitDoorTests
SavepointNameAskTests SavepointNameCopyTests SavepointNameFaceTests SavepointRenameDoorTests SavepointSealedDoorTests
SavepointTakesDoorTests SideColumnTests SnippetGroupTrashTests SurfaceSizeMemoryTests TagAndFolderTests TakeCardDoorTests
TrashBookNotesTests TrashConfirmEdgeTests TrashEmptyBlockSweepTests TrashFirstPaintTests TrashMessageBandTests
TrashMultiSelectTests TrashPoolHonestyTests TrashPurgeDoorsTests TrashPurgeSharedLayerTests TrashSurfaceTests
TrayArchivedTruncationTests TrayFilterTests TrayPanelMoveTests TrayPanelShapeTests VersionDoorsTests
VM62MacRefusalWordsPinTests VX347CommitLeavesMountTests VX889GatheringMintWingTests WingBookMoveDoorTests
WingContentsArchivedWordsTests WriteBlockSelectionTests`

Leg 3 — **red-on-old** (VM-62's pins; the method above): detached at 15f788dfd, phone build-for-testing into `vm55-b1`,
`-only-testing` `MobileNoRawErrorPinTests` `MobileRefusalSentencePinTests` on the same simulator, back to the branch.
~12 min (most of it the incremental build). After the release: the green products rebuilt (build only).

**Results.**

- **Leg 2 — the Mac** (claim `vm-55`, 05:56:15 → released 06:05:05; renewed once by the coordinator at 06:03:42; the
  dev-store Debug test host; test-without-building on e8609cc6f's products, the 172 types above): Swift Testing **"Test run
  with 1245 tests in 172 suites failed after 455.826 seconds with 1 issue"** — 1243 passed, 1 skipped (`captureTheShareFaces`,
  its suite "13n-c U3 — the share faces, captured (a harness)" gated off), **1 failed**; XCTest "Executed 0 tests" (Swift
  Testing suites). No load re-run: the red is a source scan, deterministic, not timing or pointer. No What's New sheet drawn;
  no Variorum instance left (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"` both empty); no Problem Reporter; no new
  `Variorum-*.ips` (the newest are `VariorumMobile-*` from 05:39–05:45, before the claim — another run's). Machinery
  honesty: the FIRST launch inside the claim selected nothing — the type list sat in an unquoted zsh variable, which zsh does
  not word-split, so xcodebuild got ONE `-only-testing` argument naming no test ("Executed 0", no Swift Testing line, 0
  tests run; log `vm55-b2-mac-test-unsplit.log`); re-launched at once with one argument per type (`xargs`), the run above.
- **The red — `VM61MacStatusSeamPinTests.noMacDoorSaysRemovalWithdrawsOrSetsThePlacement` (2a's Mac pin, VM-61): this
  branch's, and a FALSE POSITIVE.** The issue: `the Mac took a phone road: ["WingToolbarLabel.swift:217: .placement ="]`.
  Traced: the pin's source scan forbids the bare substring `.placement =` anywhere in `App/Variorum/Variorum/`; line 217 of
  `Core/Views/WingToolbarLabel.swift` is `self.placement = placement` in `WingLabelPlacementView.init` — the wing label's
  LAYOUT placement (`WingLabelSpace.Placement`, VX-833/VX-844, on main long before this run), nothing to do with
  `StatusCenter.placement`. No Mac door sets the seam's placement, says `status.removal(` or `withdraw(owner:` (the pin's
  other two words found nothing); the Mac's seam behaviour is pinned green by the same suite's three other tests and by
  `StatusCenterTests`, `StatusSeamVocabularyTests`, `StatusToastPlacement*Tests`. Not main's: the pin is new on this branch.
  **The smallest fix (NOT applied — the phone leg needs a still tree; the coordinator sequences it):** in
  `VariorumTests/VM61MacStatusSeamPinTests.swift:113`, narrow the third word to the seam's own spelling and the one value
  that matters — `["status.removal(", ".withdraw(owner:", "status.placement =", ".phoneLine"]` (grep at 83183bfc3: neither
  `status.placement` nor `.phoneLine` occurs in the Mac sources, so the narrowed scan is green and still trips on a Mac door
  that sets the seam to the phone's placement). Test-only; it changes no product the phone leg runs. After it, the one
  suite re-runs alone (`-only-testing:VariorumTests/VM61MacStatusSeamPinTests`, under a claim).
- **Leg 1 — the whole phone target** (claim `vm-55`, 07:06:17 → released 07:19:19; the standing iPhone 17 Pro simulator booted
  fresh 07:06:25 and settled 30 s; test-without-building on e8609cc6f's products — the phone products untouched since; the
  tree still — nothing edited from launch to verdict; `-only-testing:VariorumMobileTests` as one literal argument, 39 tests
  seen starting within 45 s): Swift Testing **"Test run with 928 tests in 155 suites failed after 504.576 seconds with 7
  issues (including 4 known issues)"** — 924 passed, 2 passed with their DECLARED known issues (`MobileTrashTests.
  anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` 2, `MobileTutorialWalkTests.
  theFannedDivideLessonLandsTheDuplicateShape` 2 — both `withKnownIssue` on main, files untouched by this branch), 0
  skipped, **2 failed**; XCTest "Executed 0" (Swift Testing suites). One test run, no host relaunch. xcodebuild lingered
  after the verdict (the `invalidDigitCount` lines) and was stopped by hand.
  - **Red 1 — `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)`**, 2 of its 3
    cases ("hi", "hello there"): **main's**, VM-24's known red (the corrected baseline).
  - **Red 2 — `MobileMessageLineHostTests.theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch`: THIS BRANCH'S (2a, VM-61), a
    REAL defect.** Re-run ALONE inside the claim (07:17:40): red again, identically — not load. Below, as 2a's second
    follow-up.
  - Everything this batch built is green: `MobileLineDirectionTests` (P-55-11), `MobileNoRawErrorPinTests`,
    `MobileRefusalSentencePinTests`, `MobileRefusalFallbackTests`, `MobileRefusalTableTests` (the two justified edits), and
    `MobileStructuralTests.nothingUserFacingNamesTheMac` (green — no rendered string of this run names the Mac). Every other
    2a suite is green too: `MobileLineShowRuleTests`, `MobileMessageLineGeometryTests`, `MobileMessageLineSceneTests`,
    `MobileLineDoorTests`, and the rewritten placement pins in `MobileUndoDoorTests`, `MobileDeletionTests`,
    `MobileNavigationTests`.
  - After: simulator shut down; no Variorum instance (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"` empty); no Problem
    Reporter; no new `VariorumMobile-*.ips` or `Variorum-*.ips` (the newest are from 05:39–05:45, before the claim).

#### 2a follow-up 2 — the one line sits below the tab bar's top and in the home-indicator zone (a REAL defect, traced)

- **The red:** `theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch`, `VariorumMobileTests/MobileMessageLineTests.swift:304` —
  "above the tab bar's inset — door (129.67, 808.0, 28.67, 14.0), safe 34.0": `door.maxY` 822 against the bound 796.5
  (874 − 34 − 44 + 0.5). Run twice (the whole target, and alone): the same frame both times.
- **Mechanism, traced:** the face (`Shell/MobileMessageLine.swift`, `MobileMessageLineView.body`, lines ~101–120) lays the
  line out inside `GeometryReader { proxy in … }.ignoresSafeArea()` and lifts it by `footOffset(keyboardOverlap:,
  safeBottom: proxy.safeAreaInsets.bottom, chromeInset:)`. With `.ignoresSafeArea()` on the reader, the proxy reports a
  bottom inset of **0**, so the lift is `max(0, 0 + 44, 0) = 44` — the line's foot at the window's foot − 44 (the door's
  bottom at 874 − 44 − 8, the line's own vertical padding = 822, exactly the red). The rule `footOffset` is right (its pure
  pin is green); its INPUT is wrong. **In the app:** every root's tab bar is the last row of a VStack INSIDE the safe area
  (`MobileLibraryView`/`MobileShelfView`/`MobileStarredView` — only their background ignores it), so the measured
  `tabBarHeight` excludes the home indicator; the line therefore sits one home-indicator inset (34 pt on this device) too
  low — over the top of the tab bar's doors on every root — and, inside a note (no bar), in the home-indicator zone. The
  keyboard case is unaffected (its overlap exceeds the inset).
- **The smallest fix (NOT applied — the coordinator sequences it):** take the bottom inset from UIKit, which the host
  already holds, instead of the ignoring reader: a `safeBottom` on `MobileMessageLineModel`, set by the overlay window
  (`MobileMessageLineWindow`: override `safeAreaInsetsDidChange()` → `model.safeBottom = safeAreaInsets.bottom`, and once
  as it is raised), and the face's `safeBottom: model.safeBottom` in place of `proxy.safeAreaInsets.bottom` (the
  `.ignoresSafeArea()` stays — the door's frame must stay in window coordinates). Three lines in one file, phone-only,
  no Shared change; the pin goes green unchanged. **Re-run after it:** `MobileMessageLineHostTests` alone, plus
  `MobileMessageLineGeometryTests` and `MobileLineDoorTests` (they read the door frame).
- **The fix as built (b811aa743, at the coordinator's sequencing; phone only, `Shell/MobileMessageLine.swift`):**
  `MobileMessageLineModel.safeBottom` (new); the face passes `safeBottom: model.safeBottom` (the reader no longer reads its
  proxy); the overlay's CONTROLLER feeds it — `viewSafeAreaInsetsDidChange()` and `viewWillLayoutSubviews()` set
  `model.safeBottom = view.safeAreaInsets.bottom`, guarded so the observed write never loops a layout. (The controller,
  not the window as first proposed: the controller is what holds the model; same inset, same moment.) `.ignoresSafeArea()`
  stays. **The pin** is the feature's own host test, red at e8609cc6f's products in the whole phone target (07:06–07:19,
  door maxY 822 against 796.5, inset 34; red again alone at 07:17:40); it now also asserts `model.safeBottom` equals the
  window's inset. **The geometry suite never drove a real inset** — `MobileMessageLineGeometryTests` feeds `footOffset`
  numbers directly, which is how a zero input passed — so a sibling type, `MobileMessageLineInsetTests` (1 test, 2 cases:
  a fed inset of 34 — a device with a home indicator — and of 0 — one without), stands the face in a real window under the
  tab bar's 44 and asserts the door sits above the bar and the inset and close above them (≤ 30 pt). On the old face the
  34 case is red (it read zero). Phone `build-for-testing` green at b811aa743 into `vm55-b1`; nothing the Mac compiles
  changed. **Re-run: DONE GREEN** — the last batch-2 claim (07:35–07:39), leg (b), on b811aa743's products: "Test run
  with 16 tests in 4 suites passed" — `theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch` RAN and passed,
  `MobileMessageLineInsetTests.theLineSitsAboveTheBarOnTheInsetItIsFed` passed both cases (34, 0), the geometry rules 3/3,
  `MobileLineDoorTests` 11/11.
- **The last claim** (claim `vm-55`, 07:35:31 → released 07:39:00; tests only; the standing simulator booted fresh at
  07:35:38 for (b) and (c)):
  - **(a) Mac**, `vm55-b1` (Mac products of 8fa80d315): "Test run with 4 tests in 1 suite passed" —
    `noMacDoorSaysRemovalWithdrawsOrSetsThePlacement` GREEN (2a follow-up 1 closed). The branch tree was still through it.
  - **(b) Phone**, `vm55-b1` (phone products of b811aa743): "Test run with 16 tests in 4 suites passed" —
    `MobileMessageLineHostTests` 1 (`theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch` RAN and passed),
    `MobileMessageLineGeometryTests` 3, `MobileLineDoorTests` 11, `MobileMessageLineInsetTests` 1 (2 cases) (2a follow-up 2
    closed).
  - **(c) VM-62's red-on-old**, run from the snapshot worktree at 15f788dfd with its own cold-built products (`vm55-pin`,
    built headless before the claim): "Test run with 7 tests in 2 suites failed after 15.938 seconds with 16 issues" —
    `MobileNoRawErrorPinTests.noPhoneSourceRendersARawError` RAN and FAILED ("97 found" — the throwaway mirror's count,
    exactly), `theStripperDropsCommentsAndKeepsCodeAndStrings` passed (the oracle); every
    `MobileRefusalSentencePinTests` case RAN and FAILED, 3 issues each (slot, line, case name), the old texts verbatim:
    `finishOnAGatheringSpeaksTheTablesSentence` — "That couldn't be done — wrongReadingKind(id: "…", expected:
    VariorumCore.ReadingKind.book)."; `reopenOnASealedBookSpeaksTheTablesSentence` — "That couldn't be done —
    readingSealed(id: "…")."; `renamingANoteThatIsGoneSpeaksTheTablesSentence` — `containerNotFound(id: "…")`;
    `unsealingANoteInASealedBookSpeaksTheTablesSentence` — `noteInSealedBook(postID: "…", readingID: "…")`;
    `starringANoteThatIsGoneSpeaksTheTablesSentence` — "Refused: containerNotFound(id: "…")". Green on the fix (the whole
    phone target, leg 1). xcodebuild lingered after the verdict and was stopped by hand; the log is kept locally
    (`App/Variorum/DerivedData/vm55-b2-last-c-pinred.log`).
  - After: simulator shut down; no Variorum instance; no Problem Reporter; no new `VariorumMobile-*.ips` / `Variorum-*.ips`
    (newest still 05:45, before the window). The snapshot worktree was removed after the release (`git worktree remove`;
    the folder and its `vm55-pin` DerivedData gone). This worktree stayed on the branch, unreverted, throughout.

#### 2a follow-up — the Mac seam pin's false positive (owned by 2b, per the brief)

- **The red:** `VM61MacStatusSeamPinTests.noMacDoorSaysRemovalWithdrawsOrSetsThePlacement`, the Mac leg (above) — its scan's
  bare `.placement =` matched `Core/Views/WingToolbarLabel.swift:217`, `self.placement = placement` (the wing label's
  layout placement, VX-833), not the seam's. No Mac behaviour was wrong; the pin was over-broad.
- **The fix (8fa80d315, test-only, at the coordinator's sequencing):** the scan's words are now `"status.removal("`,
  `".withdraw(owner:"`, `"status.placement ="`, `".phoneLine"`; the pin's doc states the trade — it still catches a Mac
  door setting the seam's placement through `status`, or naming the phone's placement anywhere; it no longer catches one
  setting it through a binding not named `status` to a value other than `.phoneLine`. A grep of the Mac sources at the fix
  finds none of the four words. Only the Mac test bundle was rebuilt (`build-for-testing`, scheme Variorum, macOS, into
  `vm55-b1`); nothing that compiles into the phone changed, and the phone products built at e8609cc6f stand.
- **Re-run: DONE GREEN** — `VM61MacStatusSeamPinTests` alone, the last claim's leg (a), 07:35–07:36: 4/4 passed,
  `noMacDoorSaysRemovalWithdrawsOrSetsThePlacement` green.

### Batch 3 record

**What this batch did NOT do (first, by the protocol):** *(final at BUILT, d91f97ca5)* no test run of any kind — this
batch has NO stage window (the note under BATCH 3): every suite below is PENDING for the ONE shared window batch 4's
implementer runs (the whole phone target, then the whole Mac target as its own QUIET claim). No phone face and no phone
behaviour (the phone only COMPILES the moved brains; nothing in `VariorumMobile/` constructs them — batch 4 composes
them). No Mac behaviour change (no Mac caller, word, kind or flow edited — the moved code is byte-for-byte except the
seams named below). Nothing under `Features/Protection/`, `Shared/Protection/`, `Sources/VariorumCore/Sync/`, custody or
the editor seam; no Core change; `Shared/AppSession.swift` untouched.

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch
`vm-55-wings-underneath`. Reading done in full before code: CLAUDE.md + loaded canon, MobileSoul §1–§5, the resiliency
protocol, the catch-up plan's inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1, this file whole
(batch 1's record — `MobileWingModel`/`MobileWingScope`; 2a's — the shared seam and its observation 4; 2b's; the BATCH 4
section), SurfaceContracts' Messages bullet, the wing label and the wing switcher bullet. DerivedData:
`App/Variorum/DerivedData/vm55-b1` (incremental, both targets).

#### Batch 3 LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (635f351d6) |
| The moves and splits (both targets' sources) | DONE (4fad0a2cf — committed NOT YET BUILT, said so in its message; a QUIET window held every full build) — the table below |
| Test-file edits (the moved face's source pin; the VM-61 and VM-62 Mac pins' scans extended to the hoisted files) | DONE (4fad0a2cf; the VM-62 scan 1081c42bd) — GREEN in the shared window's targeted Mac leg (09:39–09:44, products 5c80d058b): `WingPaletteDoorsTests`, `VM61MacStatusSeamPinTests`, `VM62MacRefusalWordsPinTests` all passed |
| The Mac seam pin (`VM63MacWingBrainsHoistPinTests`, 2 tests — the refusal words' road, no platform fork) | DONE (34b332fba) — the targeted Mac leg: `theHoistedBrainsCarryNoPlatformForkAndNoFace` GREEN; `theMacsWingsBrainSpeaksTheMacsRefusalWords` RED, 1 issue, red again ALONE (09:44) — a TEST-SIDE defect: every assertion held, but its `withDependencies` set only the database and `AppSession.init` reads `\.date`, so swift-dependencies recorded an issue for the live value. Fixed test-only (c75bdb9af — the scope supplies date and uuid, the Mac wing suites' own harness shape; Mac `build-for-testing` green at c75bdb9af). Its re-run alone is PENDING (batch 4's follow-up claim) |
| The phone compile-level pin (`MobileWingBrainsHoistTests`, 5 tests) | DONE (4fad0a2cf) — GREEN 5/5 in the shared window's whole phone target (09:20–09:37, products 5c80d058b) |
| Mac `build-for-testing` (`Variorum`, macOS, `vm55-b1`) | DONE — GREEN at d91f97ca5 ("** TEST BUILD SUCCEEDED **", exit 0; log `DerivedData/vm55-b3-mac-build2.log`). The first run, at 9fb315ad6 after the QUIET window's all-clear (08:33), was green too with ONE warning in the new pin (an `await` on the synchronous `withDependencies` overload) — fixed test-only in d91f97ca5 and rebuilt green; no diagnostic in any moved, split or new file |
| Phone `build-for-testing` (`VariorumMobile`, the window's standing simulator, `vm55-b1`) | DONE — GREEN at 9fb315ad6 ("** TEST BUILD SUCCEEDED **", exit 0; log `DerivedData/vm55-b3-phone-build.log`; no diagnostic in any moved or new file). Nothing the phone compiles changed after it (d91f97ca5 is a Mac test file) |
| **BUILT** | Both targets build for testing green; every source and test commit compiled. Nothing remains but the suites, which run in the ONE shared window batch 4's implementer holds (the TYPE lists below) — every result PENDING there |
| The shared window's suites (run by batch 4's implementer) | DONE but one re-run — the whole phone target (949 tests: every batch-3 phone suite green — the hoist pin 5/5, batch 1's wing suites, `nothingUserFacingNamesTheMac`) and a TARGETED Mac leg in place of the whole Mac target (the coordinator and the orchestrator's call: groups A–D below plus `CapabilityRegistryTests` and `StatusCenterTests`, 74 types; the whole Mac target runs once at the merge gate): 537 tests, 535 passed, the one red the VM-63 pin's test-side scope (fixed c75bdb9af, re-run PENDING). Detail: "Batch 4 record" ▸ the shared window's results |

#### The brain/face table (file by file — every `Wing*` file in `Core/Views/` and `Workspace/`, plus the one non-wing file a moved brain needed)

**The line, as drawn:** a piece MOVES when it is wing logic a phone face would compose — platform-neutral state, reads,
decisions, acts, and the words those acts speak; it STAYS when it is a face (a SwiftUI or AppKit view, an alert, a key
monitor), a face's words, the grammar of a Mac-only surface (the keyboard chords, ⌘K's palette, the sidebar's Open list,
the ⌘L sheet), or names a Mac-only type. Where a moved piece needed something Mac-only, the Mac-only part stays as an
extension in a Mac file, or is handed in (the seams, below).

| File (before) | What it is | Disposition | Why |
|---|---|---|---|
| `Variorum/Core/Views/WingsModel.swift` | the wings' brain (`WingsModel` — rows, names, destinations, the switch and the deliberate landing, mint / rename / delete, the note move/copy asks and acts, the wing-act signal, the MCP reach projection), the words the brain speaks, the open note's wing context (`NoteMenuWingContext`), the Mac's face words (`WingCopy`), and three faces | **SPLIT.** `git mv` to `Shared/WingsModel.swift` (the class, `NoteMenuWingContext`, the five sentences the class speaks — the larger half, so history follows the brain); the Mac's half of the class (its `init(session:)` with the Mac's refusal words, `watchSharing`, `answer(_:)`) and every face word of `WingCopy` to a new `Variorum/Core/Views/WingsModel+Mac.swift`; the faces (`WingNoteDoors`, `wingMoveConfirm`, `noteMenuWingDoors`) to a new `Variorum/Core/Views/WingNoteDoors.swift` | named by the brief; the three Mac-only facts are seams; the faces and their words stay the Mac's |
| `Variorum/Core/Views/WingSwitcherBrain.swift` | the switcher's pure state machine and `next(after:in:)` | **MOVED whole** (`git mv`) to `Shared/WingSwitcherBrain.swift` — byte for byte but its header comment | named; Foundation and the picker's query rule only |
| `Variorum/Core/Views/SearchPicker.swift` *(not a wing file)* | the one picker's brain and face | **SPLIT (one function).** `SearchPickerBrain.normalized` — the type's declaration — to a new `Shared/SearchPickerBrain.swift`, byte for byte; the Mac file's `nonisolated enum SearchPickerBrain {` became `nonisolated extension SearchPickerBrain {` holding the rest | `WingSwitcherBrain.visible` calls it ("the ONE picker brain's sameness"): moving the rule with its caller keeps one rule, never a copy |
| `Variorum/Workspace/WingFollow.swift` | the cross-wing follow: the rule (`Decision`, `decision(current:subjectWing:)`, the "Now in …" words), the pane subject's wing (`SidebarSelection`), the follow act and its per-window wiring (`WorkspaceModel`), the Open rows' indicator reads and hover | **SPLIT.** The rule to a new `Shared/WingFollowRule.swift`, which declares `WingFollow`; the rest stays in place as `nonisolated extension WingFollow` (`indicatorHelp`, `subjectWing`, `crossWingNames`, `crossWingIDs`) and `@MainActor extension WingFollow` (`follow`, `wire`) | "WingFollow's rule" is named; the hoisted `WingsModel.goTo` speaks `nowIn`; the act names Mac-only types; the indicator serves the Mac's Open list and sidebar rows |
| `Variorum/Core/Views/WingBookMoves.swift` | the book-move half: the door's drawing rule (`WingBookMoveDoor`), the two asks and acts (an extension of `WingsModel`), the verbs, the confirms' titles and messages, the words the acts speak, the two confirm alerts | **SPLIT.** The drawing rule, the asks, the acts, their facts (`BookMoveAsk`, `ContentsMoveAsk`) and the four sentences the acts speak to a new `Shared/WingBookMoveBrain.swift`; the verbs, the confirms' titles and messages and the two alerts stay | an extension of the named brain; the confirms are faces, and `bookMoveMessage` reads the Mac's `BookStateCopy.waitingLine` |
| `Variorum/Core/Views/WingDestinationSheet.swift` | ⌘K's listing (`WingPaletteDoors`), the ⌥⌘L chords (`WingChords`), the selector's model (`WingDestinationModel`), its `open` resolution, the sheet, the DEBUG oracle, the selector's words | **SPLIT.** `WingDestinationModel` and its words (the prompt, the foot) to a new `Shared/WingDestinationModel.swift`; the rest stays, `open` as `extension WingDestinationModel` | named — "the move-or-copy confirm's brain (its facts and words)"; `open` reads `ShellRouter`, `CapabilityRegistry` and the Mac's grey-door words; the listing and chords are Mac grammar |
| `Variorum/Core/Views/WingSwitcherMenu.swift` | the masthead ▾ menu | **STAYS** | a face (named by the brief) |
| `Variorum/Core/Views/WingSwitcherSheet.swift` | ⌘L's sheet: its per-open model (`WingSwitcherModel`), the keys only a monitor sees (`WingSwitcherKeys`, NSEvent), the monitor, the sheet | **STAYS** | a face (named); its model is ⌘L's keyboard grammar (typing, held-⌘ L) over the hoisted brain, and its one act is the hoisted `switchSaying` |
| `Variorum/Core/Views/WingToolbarLabel.swift` | the toolbar's "in ‹wing›" label: its layout rules (`WingLabelSpace`, `WingMarqueePlan`), the marquee, the slot, an AppKit edge probe | **STAYS** | a face (named); its pure rules are the Mac toolbar's geometry |
| `Variorum/Core/Views/OneWingChord.swift` | the grey-chord monitor for ⌘L / ⌥⌘L / ⇧⌥⌘L (NSEvent) | **STAYS** | Mac keyboard |
| `Variorum/Workspace/WingNumberKeys.swift` | ⌘1–⌘9: the pure decision, the NSEvent reading, the responder classification, the monitor | **STAYS** | Mac keyboard; its words name ⌘ chords (`WingCopy.noWingAtNumber`) |

#### Every file this batch moved, split or added (exact — for the coordinator's trial merge)

Paths under `App/Variorum/`.

- **Moved (`git mv`, rename-detected):** `Variorum/Core/Views/WingsModel.swift` → `Shared/WingsModel.swift` (then split — see
  above); `Variorum/Core/Views/WingSwitcherBrain.swift` → `Shared/WingSwitcherBrain.swift` (header comment only).
- **Added:** `Shared/SearchPickerBrain.swift` · `Shared/WingFollowRule.swift` · `Shared/WingBookMoveBrain.swift` ·
  `Shared/WingDestinationModel.swift` · `Variorum/Core/Views/WingsModel+Mac.swift` · `Variorum/Core/Views/WingNoteDoors.swift`
  · `VariorumMobileTests/MobileWingBrainsHoistTests.swift` · `VariorumTests/VM63MacWingBrainsHoistPinTests.swift`.
- **Edited (the remaining half of a split):** `Variorum/Core/Views/SearchPicker.swift` (`normalized` out; `enum` →
  `extension`) · `Variorum/Workspace/WingFollow.swift` (the rule out; the rest as extensions) ·
  `Variorum/Core/Views/WingBookMoves.swift` (the rule, the acts and their words out) ·
  `Variorum/Core/Views/WingDestinationSheet.swift` (the model and its words out).
- **Edited tests:** `VariorumTests/WingPaletteDoorsTests.swift` (one source pin's path) ·
  `VariorumTests/VM61MacStatusSeamPinTests.swift` (the scan reads the hoisted files) ·
  `VariorumTests/VM62MacRefusalWordsPinTests.swift` (the same).
- **Not touched:** `Shared/AppSession.swift`, every `VariorumMobile/` source, `Variorum.xcodeproj`, Core, Sync, Protection,
  the editor seam.

**The Xcode project:** `Variorum/`, `Shared/`, `VariorumMobile/` and the test folders are file-system-synchronized root
groups, and `project.pbxproj` holds NO membership exceptions (`grep membershipExceptions` — none), so every move and
addition joins its targets by folder with no project edit: `Shared/` compiles into both app targets. Checked too: no two
Swift files share a basename within either app target or the phone test target (swiftc refuses a duplicate filename in
one module — the reason the shared rule is `WingFollowRule.swift`, not a second `WingFollow.swift`). Both app targets build
with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so a moved declaration keeps the isolation it had.

#### The seams — each Mac-only thing a moved brain needed, and how it is passed in

1. **The refusal words.** `WingsModel` spoke `OpsRefusalCopy.message(for:)` at eight sites (five in the class, three in the
   book-move half); that one-argument form is the MAC's half of the table (`Variorum/Registry/OpsRefusalCopy.swift`: its own
   arms, then the shared table on `OpsRefusalRoads.mac`), absent on the phone. Now the brain holds
   `refusalWords: (Error) -> String`, set by its designated `init(session:refusalWords:)`, and every site speaks
   `session.status.refuse(refusalWords(error))`. The Mac's `convenience init(session:)` (`WingsModel+Mac.swift`) passes
   `{ OpsRefusalCopy.message(for: $0) }` — so all three Mac construction sites (`RootView`, `NoteWindowView`,
   `QuickNoteView`) and every Mac pin, which all say `WingsModel(session:)`, compile unchanged and speak the same words. A
   phone composition hands its own road (`OpsRefusalCopy.sentence(for:roads: .phone)` — what the phone pin passes).
   Precedent: `MCPHostHooks.refusalWords` (`Features/MCP/MCPDoor.swift`), the Mac's table handed into a shared host the same
   way.
2. **The MCP reach on the switcher's rows.** `watchSharing()` holds `Queries.mcpWingReaches` through `MCPRowReach.hold` — a
   Mac file (the MCP door is the Mac's). It moved to the Mac extension unchanged but for its landing: the closure that did
   `guard let self, self.reach != value …; self.reach = value` now calls the brain's new `adoptReach(_:)`, which does exactly
   that (the setter stays `private(set)`). The `reach` projection itself stays on the shared class (a Core type); on the
   phone nothing fills it.
3. **The ⌘digit chord's answer.** `answer(_ decision: WingNumberKeys.Decision)` moved verbatim to the Mac extension
   (`WingNumberKeys` imports AppKit).
4. **Where a deliberate switch lands** — `landInBookcase: () -> Void` was already a closure the owning window wires
   (`RootView.wireWingLanding`); unchanged.
5. **Resolving a ⌘K / ⌥⌘L request into a selector** — `WingDestinationModel.open(_:wings:session:)` stays a Mac extension
   (`ShellRouter.WingDestinationRequest`, `CapabilityRegistry`, the Mac's grey-door words); the model's own init is shared.
6. **The follow act** — `WingFollow.follow(_:session:stillShown:)`, `wire(workspace:session:)` and `subjectWing(_:_:)` stay
   Mac extensions (`SidebarSelection`, `WorkspaceModel`); the shared rule is what they call.

No `#if os(…)` was added anywhere; no moved file imports AppKit, UIKit or SwiftUI (the shared `WingsModel.swift` dropped the
SwiftUI import its faces needed).

#### The status seam on the hoisted brains (the batch-2 binding)

Every `session.status` call in the moved code is the same call it was: `refuse` (thirteen sites, the eight refusal-words
ones included) and `receipt` (seven: mint, delete, move, copy, book move, move everything, and the said switch's "Now in
…").
None says `removal`, `withdraw`s, or sets the placement. **What guards that now** that the files left `Variorum/`:
`VM61MacStatusSeamPinTests.noMacDoorSaysRemovalWithdrawsOrSetsThePlacement` reads each hoisted file by name
(`hoistedMacBrains` — the six `Shared/` files this batch made or moved) for the same four narrowed words, and requires each
name to exist (a rename or a stale entry trips it instead of leaving a brain unscanned);
`VM62MacRefusalWordsPinTests.noMacDoorTakesThePhonesRoad` reads the same list for the phone's refusal roads (a hoisted brain
that named `OpsRefusalCopy.sentence(` itself, instead of speaking the words it is handed, would change the Mac's words). On
the phone side, `MobileWingBrainsHoistTests.aRefusalSpeaksTheHandedInWordsAndALandedActSaysAReceipt` runs a refusal (it
lands as `.refusal` in the handed-in words) and a landed mint (its receipt draws nothing on the phone's line — a `removal`
would). *A throwaway mirror of both scans over the tree at the record commit found no hit.* (The real runs: both scans GREEN in the targeted Mac leg; the phone pin GREEN in the whole phone target — 2026-11-19, products 5c80d058b.)

#### Byte-identical on the Mac — what would fail, per moved brain, had its behaviour changed

VM-63 is Debt (a hoist): red-on-old does not bind. The pins are the Mac suites that already drive each brain, unedited but
for one source pin's path — plus, for the one seam that changed text on the Mac's path (the refusal words), the new
`VM63MacWingBrainsHoistPinTests` (the wing suites provoke only worded refusals, where the Mac's road and the phone's
agree):

- **`WingsModel`** (rows, names, destinations, switch, mint, rename, delete, the note acts, the signal, the reach):
  `WingSwitcherTests` — Home-first rows and destinations; the mint's receipt `WingCopy.minted` and the taken-name refusal
  in the Mac's own words, "Home is the built-in wing's name — pick another." (THROUGH the refusal-words seam — a wrong seam
  reds it); the non-empty delete's refusal naming what remains, the delete's receipt and the return Home; the note doors'
  `moved` / `frozen` / `copied` sentences. `WingDeliberateLandingTests` — `goTo` saying, landing and the in-place cycle.
  `WingDestinationsDeadWingTests` — the dead-wing heal in `destinations(from:)`. `WingPaletteDoorsTests` — the wing-act
  signal across all four acts, a refusal signalling nothing, `NoteMenuWingContext`'s load key and gates. `MCPSharedRowsTests`
  and `MCPSharedIconClickTests` — `watchSharing` filling `reach` (through `adoptReach`). `WingNumberKeysTests` — `answer`
  going the deliberate road or refusing. `SidebarNoteRowMenuTests`, `MCPWingFacesTests`, `BookcaseCensusMenuTests`,
  `MCPAsksWaitCaptureTests`, `VocabularySweepTests` — the faces over it.
- **The book-move half** (`WingBookMoveDoor`, `bookMoveAsk`, `moveBook`, `contentsMoveAsk`, `moveContents`):
  `WingBookMoveDoorTests` — the drawing rule, the ask counting and listing then acting, the frozen stay-behind refusing at
  the door, the bulk ask, its receipts and the confirms' words; `BookDoorsEverywhereTests` — the drawing rule.
- **`WingSwitcherBrain`:** `WingSwitcherChordTests` — opens on the current wing, held ⌘ + L cycles and a release commits, a
  press-and-release stays open, typing filters and ⏎ commits the first match, a typed change ends the cycle, a row click
  commits the current row, the masthead cycle wraps and one wing is no cycle door.
- **`SearchPickerBrain.normalized`:** `SearchPickerBrainTests` (and the picker's hosts: `RuleEditorMakeTagTests`,
  `AddToBookMintTests`, `MCPGrantSheetTests`, `SearchPickerPanelGeometryTests`).
- **`WingFollow`'s rule:** `WingFollowDecisionTests.onlyAnotherWingIsFollowed`; `WingFollowTests` and
  `JournalWingFollowTests` — the follow's switch and its "Now in …" receipt; `WingDeliberateLandingTests` — the same words
  from a said switch.
- **`WingDestinationModel`:** `WingPaletteDoorsTests` — the selector's rows (the act's own destinations), its choice running
  the existing acts and confirms, the keyboard ask; `WingDestinationsDeadWingTests`.

And the source walks whose result could move when code moves between `Variorum/` and `Shared/` (each walks both, or reads a
named file): listed in the Mac TYPE list below.

#### The tests this batch wrote or edited

- **New, phone:** `VariorumMobileTests/MobileWingBrainsHoistTests.swift`, type `MobileWingBrainsHoistTests` (5):
  `theWingsBrainReadsItsRowsOnThePhone` (a two-wing store — batch 1's `TwoWingWorld` — read by `load()`: Home alone before,
  Home then Work after, the count on `WingState`, names with a dangling id read as Home's, destinations, the next wing
  wrapping) · `theSwitcherBrainStepsAndFiltersOnThePhone` (`next(after:in:)` across three rows, wrapping, an unknown current,
  one wing → nil; the brain's highlight, the `#`-dropping filter, ⏎) · `theFollowRuleAndItsWordsOnThePhone` ·
  `theDestinationSelectorAndTheBookMoveAskBuildOnThePhone` (the selector over the wings' rows, its prompt and foot; the book
  move's ask with its preview — the destination's twin named; an ask says nothing) ·
  `aRefusalSpeaksTheHandedInWordsAndALandedActSaysAReceipt`. Results PENDING (the shared window).
- **New, Mac:** `VariorumTests/VM63MacWingBrainsHoistPinTests.swift`, type `VM63MacWingBrainsHoistPinTests` (2):
  `theMacsWingsBrainSpeaksTheMacsRefusalWords` — the one seam that changed text on the Mac's path, pinned where the wing
  suites cannot see it: they only provoke WORDED refusals (the taken-name one), on which the Mac's `message(for:)` and the
  phone's `sentence(for:roads:)` agree; this pin drives `WingsModel(session:).refusalWords` on the cases where the roads
  part — the Mac-only arms `lockedReading` and `wingMoveChangedSince`, and an error no table words (described on the Mac,
  the plain fallback on the phone's road) — and asserts the Mac's words, and that each case does part the roads ·
  `theHoistedBrainsCarryNoPlatformForkAndNoFace` — no `#if os(` and no AppKit / UIKit / SwiftUI import in the hoisted files
  (review focus 7; the phone target compiling them is the other half). A mirror of the scan over the tree finds none.
  Results PENDING (the shared window).
- **Edited, Mac:** `WingPaletteDoorsTests` (one `Self.source(...)` path, marked A JUSTIFIED EDIT — the bar's modifier is a
  face and lives in `WingNoteDoors.swift` now, byte for byte); `VM61MacStatusSeamPinTests` and `VM62MacRefusalWordsPinTests`
  (each scan also reads the hoisted files, above). No Mac assertion changed.
- **Mac tests that reach a moved type through the Mac module** keep compiling: `Shared/` compiles into the `Variorum`
  module, so `@testable import Variorum` still sees every moved type under its own name, and every Mac construction site
  says `WingsModel(session:)`, which the Mac's convenience init answers. CONFIRMED: the Mac `build-for-testing` compiled the
  whole `VariorumTests` bundle green at d91f97ca5 with no change to any of those files.

#### For the shared window (run by batch 4's implementer) — RUN 2026-11-19 (results in "Batch 4 record" ▸ the shared window's results): the phone list in the whole phone target, green; groups A–D in the targeted Mac leg, green but the VM-63 pin's one test (test-side, fixed c75bdb9af, re-run PENDING)

**Phone:** the whole phone target (the window's plan). Focused, for attribution: `MobileWingBrainsHoistTests` (new) ·
`MobileWingStandTests` `MobileWingListingTests` `MobileWingMintTests` `MobileWingTagManagerTests`
`MobileWingBlindPickerTests` (batch 1's wing suites — the fixture the new pin borrows) · `MobileNoRedirectSweepTests` (its
`nothingUserFacingNamesTheMac` walks `Shared/`'s literals, which gained the moved words; a mirror finds no word-bounded
"Mac" in them).

**Mac:** the whole Mac target (the window's plan, its own QUIET claim). Focused, for attribution, by group:
- (A) every type whose file names a moved type (`WingsModel` and its asks, `WingSwitcherBrain`, `WingFollow`, `WingCopy`,
  `WingDestinationModel`, `NoteMenuWingContext`, `WingBookMoveDoor`, `SearchPickerBrain`): `AddToBookMintTests
  BookDoorsEverywhereTests BookcaseCensusMenuTests LineageFaceModelTests MCPAsksWaitCaptureTests MCPGrantSheetTests
  MCPSharedIconClickTests MCPSharedRowsTests MCPWingFacesTests SearchPickerPanelGeometryTests SearchPickerBrainTests
  RuleEditorMakeTagTests SidebarNoteRowMenuTests TutorialBooksLessonTests TutorialBooksRitualTests VM61MacStatusSeamPinTests
  VocabularySweepTests WingBookMoveDoorTests WingChordsAndLabelDoorTests WingDeliberateLandingTests
  WingDestinationsDeadWingTests WingFollowDecisionTests WingFollowTests JournalWingFollowTests WingNumberKeysTests
  WingPaletteDoorsTests WingSwitcherChordTests WingSwitcherTests VM63MacWingBrainsHoistPinTests` (29, the new pin last)
- (B) every type whose file names a piece left in a split file: `AlertCancelSweepTests ShiftEntryDateDoorTests
  VersionDoorsTests` (3)
- (C) the source walks over `Variorum/` and `Shared/`: `BadgeFamilySplitTests ChromeLineLimitTests ChromeMenuRowSizeTests
  CommitsPageLedgerTests DragTypeDeclarationTests DuplicateDoorsTests IndexTierMetricsTests PaneLineMetricsScopeTests
  MCPAsksWaitTests MCPIconTwinsTests MarkdownPaletteWritersTests NoLiteralColourTests OneInputPathTests
  OneRefreshAuthorityCompositionTests OneRefreshAuthorityRaceTests PaletteDerivationTests PaneFindFaceTests
  Phase9cAuthWiringTests FollowDoneNoticeTests ProtectionFileLeavesTests WordsFieldsConcealTests SidebarLayoutTests
  OneTimeCodeAutoFillTests ShellChromeTests StatusSeamVocabularyTests TourScriptTests TourSpotlightTests TourEngineTests
  TourPoolTuckTests TourEntryTests TourEndCardTests TourClosingCardTests TourEndCardAsideGateTests UnfiledWordTests
  VM62MacRefusalWordsPinTests VersionSchemeTests WhatsNewTests` (37)
- (D) the wing neighbours (batch 1's Mac pins and the label): `VM56MacWingScopePinTests SettingsTagsWingFollowTests
  QuickEntryWingLabelTests` (3)

#### PROVISIONAL (for QUESTIONS at the merge moment — the orchestrator carries it)

- **P-55-13 — sentences in the shared brain that name a Mac door or key.** Four sentences the moved acts speak name the
  Mac's own doors: `WingCopy.frozen` and `bookFrozen` ("reopen it (or unseal it)" — the phone has no book Unseal door yet:
  `OpsRefusalRoads.phone.bookSeal.verb` is nil), `nothingToMove` ("Delete Wing… can take it." — the Mac's menu verb), and the
  selector's `destinationFoot` ("⏎ chooses · esc closes"). The OpsRefusalTable doctrine (MobileSoul §4 item 4, read from the
  other side) keeps a platform's door words out of a shared home — as ROADS a platform fills. Options: (a) move them byte for
  byte — the Mac's words cannot change, and no phone surface speaks them until a phone face composes the act, whose umbrella
  then words the phone's half; (b) turn the door words into roads now (a `WingRoads` the Mac fills with today's words and the
  phone with its own or nil) — a phone wording call made before any phone face, and with no face to read it against; (c)
  keep the four sentences in the Mac's half and hand them in like the refusal words — a wider seam for words no phone face
  says yet. **Built: (a)** — the batch-2 binding (byte-identical on the Mac) and the brief's "the phone gains no face"; batch
  4's door composes the rows and the switch only, none of these four.

#### Observations for the orchestrator and batch 4 (not fixed — outside this unit)

1. **Folding `MobileWingModel` (batch 4):** the shared brain covers its `track` / `load` / `adopt` (the same three steps)
   and `rows`, but NOT its "never a false Home": `WingsModel.currentName` answers `name(of:)`, which falls back to "Home" for
   a wing it has not read yet, while batch 1's `MobileWingModel.currentName` answers nil until the held read has landed
   (`loaded`). A fold that reads `WingsModel.currentName` for the roots' title would briefly say "Home" in a non-Home wing on
   launch. A phone face's own "has it loaded" fact, or reading `rows` for the current id, keeps batch 1's behaviour — batch
   4's call.
2. **Constructing it on the phone:** `WingsModel(session:refusalWords: { OpsRefusalCopy.sentence(for: $0, roads: .phone) })`
   (the phone pin's road); `goTo(_:saying:landing:)` lands through `landInBookcase`, which the phone's composition wires; a
   said switch speaks a receipt, which the phone's line does not draw (her ruling: no line for a switch).
3. **`WingCopy` now lives in four files:** declared in `Shared/WingsModel.swift` (the sentences the class speaks), extended in
   `Shared/WingBookMoveBrain.swift` and `Shared/WingDestinationModel.swift` (the acts' and the selector's words) and, for the
   Mac's faces, in `Variorum/Core/Views/WingsModel+Mac.swift` and `WingBookMoves.swift`. Each file's header says which.
4. **Left with the Mac by the line above, one move away if a phone surface ever needs them:** `WingFollow.crossWingNames` /
   `crossWingIDs` (pure reads for the sidebar's Open list and note rows — a phone list of another wing's notes, e.g. the
   all-wings search switch of LS-2, would want them); `WingSwitcherModel` (the ⌘L sheet's typing and held-⌘ state).
5. The shared brain's `reach` projection is filled only by the Mac's `watchSharing` (the MCP door is the Mac's); on the phone
   it stays empty.

#### Canon deltas believed owed (the orchestrator applies at the merge)

- `notes/MobileSoul.md` §6 — the wings' parity row: the wing brains now live in `Shared/` (VM-63) — `WingsModel` with its
  book-move half, `WingSwitcherBrain`, `WingFollow`'s rule, the destination selector's model, `NoteMenuWingContext` and the
  book door's drawing rule; the phone composes them (batch 4's door; wave 2's switcher, management and moves).
- `notes/SurfaceContracts.md`, AppSpec — none (no behaviour changed; AppSpec §2 already names `App/Variorum/Shared/` as the
  cross-platform brains' home).

### Batch 4 record

**What this batch did NOT do (first, by the protocol):** *(updated after the shared window, c75bdb9af)* **two re-runs are still
owed** — `MobileWingDoorShellTests` (phone) and batch 3's `VM63MacWingBrainsHoistPinTests` (Mac), each red on a test-side premise
in the window and fixed test-only since; and the WHOLE Mac target did not run here (a targeted 74-type leg did — the whole target
runs once at the merge gate). Not the swipe or its dots, sizes beside the names, the ⋯ or wing
management (make, rename, delete, move everything), following a note to its wing, or moving or copying a note or book to a wing
(all wave 2 — VM-80, umbrella VM-72); no restyle of the roots beyond the door itself (the path line keeps its tokens, sizes and
letters; it is 10 pt taller so the door's 44 pt target is real — P-55-17); no fix to the empty-wing lines (P-55-16); no line of
the shared `WingsModel` / `WingSwitcherBrain` changed (one word, the list's header, moved into `WingWords` with the Mac's
`WingCopy` forwarding to it — the batch's only Mac-compiled change); nothing under `Features/Protection/`,
`Shared/Protection/`, `Sources/VariorumCore/Sync/`, custody/keychain or the editor seam; no Core change; no merge of main. The
run's use-shaped simulator walk is the run's, after the ladder.

Implementer: `opus-implementer` (Opus, xhigh), one session. Worktree `~/dev/variorum-vm-55`, branch `vm-55-wings-underneath`.
Reading done in full before code: CLAUDE.md + loaded canon, MobileSoul §1–§5, the resiliency protocol, the catch-up plan's
inherited rules, umbrella-02, sitting-1 rulings, audit A §1D/§1F/§1I/§3.1, this file whole (batches 1, 2a, 2b and 3's
records), SurfaceContracts' Messages bullet, the wing label and the wing switcher bullet, the home-wings-capture mockup's
frames 5–15 and its build notes, wording list 1's wing rows. DerivedData: `App/Variorum/DerivedData/vm55-b1` (incremental).

#### Batch 4 LIVE STATUS

| Piece | State |
|---|---|
| Record skeleton | DONE (this commit) |
| 0 — build the merged tree (main 359ae214d merged at 871bde99a) | DONE — at fb6b90ee0, both targets `build-for-testing` GREEN, nothing to fix: phone ("** TEST BUILD SUCCEEDED **", no `error:`; log `DerivedData/vm55-b4-phone-merge-build.log`), then Mac (same; `vm55-b4-mac-merge-build.log`). No diagnostic in any file this run moved, split or added; the warnings are pre-existing ones in untouched test files. So no semantic conflict with VX-980's Mac search/Settings/Capability changes showed at compile time. |
| 1 — VM-225, the interim wing door (code + pins) | DONE (5c80d058b; the shell pin's voice fix 931c77f79) — GREEN in the whole phone target but one pin: 18 of 19 batch-4 tests passed; `MobileWingDoorShellTests` red on a test-side premise (the unvoiced header), fixed test-only 931c77f79, its re-run alone PENDING |
| Phone + Mac `build-for-testing` on the final tree | DONE — both GREEN at 5c80d058b into `vm55-b1`: phone ("** TEST BUILD SUCCEEDED **", exit 0, no diagnostic in any file this batch touched; log `vm55-b4-phone-build3.log`), Mac (same; `vm55-b4-mac-build1.log`). The record commits after it change no product. |
| READY for the shared window (batches 3 + 4) | DONE (the report ending this session's first turn) — the two claims and the TYPE lists below |
| The shared window — claim (i) the whole phone target | DONE (09:20:51–09:37:32, products 5c80d058b) — 949 tests in 161 suites: 947 passed (2 with declared known issues), 2 failed (VM-24's main red; this branch's `MobileWingDoorShellTests`, red again alone), 0 skipped. Below |
| The shared window — claim (ii) — CHANGED to a targeted Mac leg (74 types, not QUIET; the whole Mac target runs once at the merge gate — the coordinator's and the orchestrator's call) | DONE (09:39:23–09:44:18, products 5c80d058b) — 537 tests in 74 suites: 535 passed (2 with declared known issues), 1 failed (batch 3's `VM63MacWingBrainsHoistPinTests` test-side scope, red again alone; fixed test-only c75bdb9af), 1 skipped (a gated capture harness). Below |
| Fixes after the release (test-only) and the rebuild | DONE — 931c77f79 (the phone shell pin compares the voiced header; the same unvoiced premise removed from the list pin and the plain-line pin, latent there because they host in Study), c75bdb9af (the Mac hoist pin's dependency scope). Both targets `build-for-testing` GREEN at c75bdb9af (`vm55-b4-phone-build4.log`, `vm55-b4-mac-build2.log`) |
| The follow-up claim: `MobileWingDoorShellTests` alone (phone) + `VM63MacWingBrainsHoistPinTests` alone (Mac), on c75bdb9af's products | PENDING |

#### What shipped — VM-225 (5c80d058b)

**The door.** On each root — Starred, the Shelf, the Library — the wing's name in the path line (batch 1's P-55-2 line) is a
door. The line stays ONE text with the same letters (`MobileWingTitle.doorParts` → `MobileWingPath.title`, an
`AttributedString`: the voice's prefix and the rest in the line's muted ink, the wing's name in the accent), so wrapping and
wording are batch 1's; the whole title is the door's target (P-55-17). A tap opens the plain list. Files:
`VariorumMobile/Features/Shell/MobileWingDoor.swift` (new — the face model, the path-line door, the list) and one input per
root (`var onWingDoor: (() -> Void)? = nil` beside `wingName`, and the path line's `Text` replaced by `MobileWingPath` —
`MobileStarredView`, `MobileShelfView` (its "  ·  N books" rides as `trailing`), `MobileLibraryView`). A root given no door
(every existing harness) draws exactly batch 1's `Text` (pinned: `withoutADoorTheLineIsPlainText`).

**The target is 44 pt tall, and real.** The line is about 34 pt (its 14 pt top padding, the 11.5 pt text, its 6 pt bottom
padding). A target hung invisibly beyond it would reach up into the status bar's inset (the system answers touches there — tap
to scroll to top — so the app cannot count on them) or down into the search field / the books / the first row, which are drawn
after the line and win the touch. So the button's label spans the line's own paddings and a 44 pt minimum, and negative
padding hands those paddings back to the line's layout: the target covers the line top to bottom and the line grows only by
the remainder — 10 pt at today's size (34 → 44), the text 5 pt lower, everything under the line 10 pt lower, nothing else
changed (`MobileWingDoorMetrics` names the 44 and the roots' 14/6; the geometry pins measure the real roots, so a VM-47 change
to those paddings that left the target spilling out of the line goes red). The width is the whole title (≥ 44 pt for any name
plus its page word).

**The list** (`MobileWingListSheet`, presented by the shell, `.presentationDetents([.medium, .large])`): the phone's sheet idiom
(`MobileMembershipSheet`'s title row with Done, rows below, padding 20, `tokens.room`) in today's tokens. Header: the Mac's own,
"Wings — each a separate library" (its ▾ list's header) — hoisted to `WingWords.switcherHeader`, the Mac's
`WingCopy.switcherHeader` now forwarding byte for byte (`Variorum/Core/Views/WingsModel+Mac.swift`, the VM-60 `tagsTitle`
precedent; the Mac's `VocabularySweepTests` pins the value). Rows: the wings in the switcher's order, Home first, each a real
button at least 44 pt tall, the current one marked with "✓" in the accent and the `.isSelected` trait. Nothing else: no
sizes, no ⋯, no management, no Snippets line (wave 2). It READS when it opens (`.task` → `MobileWingDoor.listOpened()` →
`WingsModel.load()`: `Queries.wings`, the `wing` table alone, through the database's reader, off the main thread — P1/P2).

**A pick** (`MobileWingDoor.pick`): `WingSwitcherBrain.pick(id)` answers `.commit(id)` (the current row too — VX-833); the wings
are read again (a row may name a wing that died while the list stood open); if the wing is gone, NOTHING switches or lands, the
list stays up without that row, and the door speaks a refusal in the shared table's existing words, "That library isn't there
any more — nothing changed." (`wingNotFound`, through the brain's handed-in phone road — AppSpec's "a door that did nothing
speaks a refusal"); otherwise the list closes, a capture draft is filed in its own wing when the wing is about to change
(P-55-18), and `WingsModel.goTo(id, saying: false)` — the deliberate road, silent as the Mac's ▾ list is — switches the shared
`WingState` (written through to the device memory) and calls `landInBookcase`. The door counts that landing (`landings`); the
shell answers each count with `selectPage(.shelf)` — its one page road (the quick-note filing on a leaving, the liveness
hand-off, the settle). Every root's held listing re-reads in the new wing through batch 1's `MobileWingScope.follow`; the roots'
title re-reads from the same brain. **No line is shown for the switch** (her ruling; a said switch would be a receipt, which the
phone's line drops anyway, but the road says nothing at all).

#### How the hoisted brains were composed, and what was folded

- **`WingsModel` (Shared, VM-63)** is now what the shell holds: `MobileWingDoor.phoneWings(session)` builds it with the phone's
  refusal road (`OpsRefusalCopy.sentence(for:roads: .phone)` — batch 3's seam, as its own pin constructs it). The shell's held
  `.task { await wings.track() }` replaces batch 1's; the door composes its `load()` (the open read and the pick's re-read), its
  `switcherRows`, `currentID`, `goTo(_:saying:)`, `landInBookcase` and `refusalWords`. **No line of the shared brain changed.**
- **`WingSwitcherBrain` (Shared, VM-63)** gives the list its rows, the marked row (`currentID`) and what a pick means
  (`pick(_:)` → `.commit`).
- **FOLDED: batch 1's `MobileWingModel`** (in `MobileWing.swift`) is deleted. Its `track` / `load` / `adopt` were the shared
  brain's own three steps (count, then revalidate — a dead wing returns the phone Home), so the shared brain covers them whole.
  The one thing the brain does NOT say is batch 1's title rule — never a false "Home" before the wings are read
  (`WingsModel.currentName` falls back to "Home" for an unread id, right for its Mac faces, wrong for a title) — so the rule
  stays on the phone as a pure read over the brain's rows: `MobileWingTitle.name(currentID:wings:)` / `name(of:)` ("Home" for
  '', a live wing's name once read, nil before). The shell's three roots read it.
- **`MobileWingStandTests` — a JUSTIFIED EDIT of three pins** (they constructed the folded type): `aWingDeletedHereReturnsThePhoneHome`
  (the held read's delivery is now "its rows name the wing", the folded holder's `loaded`), `aWingArrivingDeletedBySync…`
  (the construction only), `everyRootIsTitledWithTheWingsName` (the title through `MobileWingTitle.name(of:)`, every assertion
  kept — Home without a read, nil while unread, Work after, Office after a rename — plus one added line showing WHY the rule
  stays phone-side: the brain's own `currentName` says "Home" for the unread id). Each still fails if its fact breaks.
- **Kept, not folded:** `MobileWingScope.follow` (the listings' once-per-wing run — no shared brain does it) and
  `MobileWingTitle.components` (batch 1's line words).

#### Words — what the door can put on a phone screen (P-55-13's binding)

No NEW words. The door composes the rows and the switch only, so none of P-55-13's four Mac-worded sentences (the move acts'
`frozen` / `bookFrozen`, `nothingToMove`, the selector's `destinationFoot`) is reachable; no draft was needed. Everything the
door shows: the list's header "Wings — each a separate library" (the Mac's ▾ list's own, hoisted) · "Done" (the phone's
sheets' shipped word) · "✓" (the mark; the Mac's list wears the native checkmark, the mockup's frame 8 draws "✓") · the wings'
names · the one refusal, "That library isn't there any more — nothing changed." (the shared table's existing `wingNotFound`
row). Pinned: `nothingTheDoorCanSayNamesAMacDoor`. The mockup's drafted heading "Wings" (`wording-list-1.md` row 25, awaiting
her pass) is NOT used — the Mac's words where a Mac face exists, and a draft waits for her pass.

#### PROVISIONAL calls (for QUESTIONS at the merge moment — the orchestrator carries them)

- **P-55-14 — what a switch does to screens already pushed on the three stacks.** (a) Leave every stack as it stands — nothing
  she has open is closed; (b) pop all three stacks to their roots, a fresh library under every root; (c) pop only the screens
  showing another wing's things. **Built: (a)**, the least destructive, and safe: a pushed note or book reads by its own id
  (VM-59's pickers read the note's own wing; Book Details finds its book store-wide — batch 1), never by the current wing. In
  the shipped shell the door is reachable only on a root, a page is left only from its root, and every writer of the three paths
  (all in `MobileShellView`, checked) pushes onto the visible stack — so a switch normally finds every stack at its root. The
  one edge: a STANDING shell adopting a protection request (`adoptProtectionRequest`) selects the Shelf while another stack
  may still hold a screen; (a) leaves that screen too. The Shelf's own stack is never left holding a screen while hidden, so the
  landing always shows the Bookcase itself. The question becomes live with wave 2's follow (VM-80), where a note from another
  wing can be open.
- **P-55-15 — whether the name is a door while the library has one wing.** (a) A door always — the list opens with Home alone,
  marked, and its pick lands on Home's Bookcase (the Mac's ▾ list opens with one wing; the mockup's build note "With one wing
  it still opens"); (b) no door with one wing (nothing to switch to — P-2), the title plain; (c) a door that speaks a note, as
  the Mac's ⌘L does (`WingCopy.switchWingUnavailable`) — its words name Mac doors (New Wing… under the Bookcase, ⌘L) and the
  phone has no New Wing door yet, so it could only redirect to the Mac (MobileSoul §4's no-redirect). **Built: (a)** — one shape
  for one wing or nine, and a door that acts (it lands); wave 2's ⋯ will then have its home.
- **P-55-16 — the empty-wing lines that assume Home** (batch 1's observation 3). Now reachable: the door can stand the phone in
  an empty non-Home wing, whose Bookcase says "No books yet — Today's Entry starts your journal." and "Have an account?
  Settings ▸ Sync signs you in." (and the Library its sign-in line). The brief: fix only if a one-word fix exists in the Mac's
  own words. None does — the Mac's empty Bookcase says a different sentence ("No books yet — create one, or just start typing
  below.", `ShelfView`), and the phone's lines are not one word away from it. Options: (a) leave them (built); (b) adopt the
  Mac's Bookcase sentence whole — a sentence swap, not a one-word fix; (c) hide the sign-in line once a second wing exists — a
  new rule. **Left as they are**; wave 2's VM-72 owns the empty-wing faces (its drafted "No books here yet." / "1 note is in the
  Library." wait in `wording-list-1.md` rows 23–24).
- **P-55-17 — the door's face.** (a) The wing's name in the accent (the ink of every other text door on these lines — + New
  Note, Settings), the whole title the target, the line grown 10 pt so the 44 pt target is real; (b) the name unchanged in the
  muted ink with an invisible overhang and no layout change — a door nothing says is a door, and a target whose part above the
  line sits in the status bar's inset and whose part below loses to the field or rows drawn after it; (c) as (a) plus the Mac's
  "▾" after the name (its masthead "Home ▾") — a new glyph mid-path ("Home ▾ · Library", "~/home ▾/library"). **Built: (a)**.
- **P-55-18 — a capture draft on a switch.** The phone's box mints as she types (about a second in — VM-58: in the current
  wing), unlike the Mac's bar, which mints at ⏎ in the wing she stands in then. A switch from the Shelf with words in the box:
  (a) leave the box alone — a minted draft keeps writing into the wing it was minted in while the box sits under another wing's
  name, and an unminted tail mints in the NEW wing; (b) file the box first, in the wing it was written in, exactly as every page
  change files it (A5-8 — `selectPage`'s leaving), so the box is empty in the new wing; (c) carry the draft to the new wing (a
  move — wave 2's act, and a write she did not ask for). **Built: (b)** — only when the wing actually changes (picking the
  current wing files nothing). Pinned on a REAL box: `aSwitchFilesTheCaptureDraftInTheWingItWasWrittenIn` (an unminted draft
  lands in Home's Pool, the box empty in Work).

#### Tests (written; every result PENDING — the shared window)

Phone, new — file `VariorumMobileTests/MobileWingDoorTests.swift`, four types:
- `MobileWingDoorTests` (8): `aPickSwitchesLandsOnTheBookcaseAndEveryRootRescopes` (the list's order and mark; the switch, one
  landing, the list closed, no line, the title; the Shelf's books, the Library and Starred held listings re-read in Work) ·
  `pickingTheCurrentWingLandsAndSwitchesNothing` (lands, switches nothing, files nothing, says nothing) ·
  `theListIsReadWhenItOpens` (a wing the brain never read is on the list once it opens) ·
  `thePickIsRememberedAcrossARebuiltSession` (a scratch defaults suite, never the host's: the pick writes the memory; a second
  `AppSession` over the same store attaching the same memory stands in Work, and its own wings read keeps it) ·
  `aWingThatDiesWhileTheListIsOpenReturnsThePhoneHome` (Work arrives deleted by sync while the list is open: Home, the row gone,
  Home marked, the list still up; a stale pick of Work switches nothing, lands nothing, keeps the list, and speaks the table's
  refusal) · `withOneWingTheListOpensWithHomeAlone` · `aSwitchFilesTheCaptureDraftInTheWingItWasWrittenIn` (a real
  `MobileQuickNoteModel`, clocks off) · `theLineReadsTheSameWithItsDoor` (both voices: the pieces put together are
  `VoiceTokens.path` plus the Shelf's count; the drawn `AttributedString` is those letters) · `nothingTheDoorCanSayNamesAMacDoor`.
- `MobileWingDoorGeometryTests` (4) — the REAL roots hosted in a real window with a 20 pt top safe-area inset (the smallest
  status bar a supported phone has, fed the way the device feeds it): `theStarredRootsDoor`, `theShelfRootsDoor`,
  `theLibraryRootsDoor` — the door found by the name with a button trait; its target ≥ 44 pt tall AND wide, starting below the
  inset, reaching no lower than the top of the first thing drawn under the line; `accessibilityActivate()` fires it ·
  `withoutADoorTheLineIsPlainText` (no door wired: no button carries the name, the line's text is batch 1's).
- `MobileWingListSheetTests` (1): `theListsRowsAreTheWingsInOrderAndARowPressLands` (the sheet hosted: its own `.task` read
  fills it; the Mac's header; rows Home then Work as real buttons, Home `.selected`, each ≥ 44 pt; a press on Work switches and
  lands, the list closed).
- `MobileWingDoorShellTests` (1): `fromTheLibraryAPickLandsOnTheWingsBookcase` — the MOUNTED shell: to the Library by its tab
  door; the name "Home" opens a real sheet with the header; "Work" pressed; the shared wing is Work, the sheet gone, the Shelf's
  tab door selected (landed on the Bookcase), the title door names Work, no line.
Phone, edited: `MobileWingStandTests` (the fold — above).

#### Observations for the orchestrator (not fixed — outside this unit)

1. **The Mac's lists can commit a wing that died while open.** ⌘L's sheet and the ▾ list hand `goTo` the row's id with no re-read,
   so a wing deleted by sync while the sheet stands open can be picked: `WingState.switchTo(deadID)` stands the Mac in it until
   the next `adopt` (none comes — the wings read already delivered). The phone's door re-reads and refuses; a Mac ticket candidate
   (Bug · Suspected · Library & sidebar).
2. **The status-bar claim behind P-55-17 is not measured in process** (an in-process pin cannot deliver a touch through the
   status bar); the run's closing simulator walk taps the real door, and a tap just above the line there would show it.
3. **No accessibility hint on the door** — VoiceOver says "Home, button" (the name is the label, as the tab doors'). A hint would
   be new words; listed for the VoiceOver audit (VM-216) or wave 2's face.
4. **For VM-47's merge:** the three roots' path lines now call `MobileWingPath`, and the door's target assumes the roots' 14 / 6
   pt line paddings (`MobileWingDoorMetrics`). A size change to the line should move those two numbers with it; the geometry pins
   measure the real roots and catch a target that spills out of the line.

#### Canon deltas believed owed (the orchestrator applies at the merge)

- `notes/MobileSoul.md` §6 — PL-45's wing row: the phone can switch wings (the interim door: the name on every root opens a plain
  list; a pick lands on the wing's Bookcase); the swipe, dots, sizes, management, follow and moves remain wave 2's.
- `notes/SurfaceContracts.md` — none (the phone's surfaces enter as each umbrella ships them; the catch-up plan's own line).
- AppSpec — none.

#### The shared window for batches 3 and 4 (READY — the two claims)

**Claim (i) — the whole phone target** (`-only-testing:VariorumMobileTests`, one literal argument; test-without-building on
5c80d058b's phone products in `vm55-b1`; the window's standing simulator booted fresh, settled 30 s, shut down before release).
About 25 min held (batch 2's whole target ran 928 tests in about 8.5 min of test time; boot, settle and the verdict wait around
it). Expected red from main: VM-24's `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` (2 of 3 cases) only.
New and changed types to call out by name: batch 4 — `MobileWingDoorTests` `MobileWingDoorGeometryTests`
`MobileWingListSheetTests` `MobileWingDoorShellTests` (new), `MobileWingStandTests` (three pins edited for the fold); batch 3 —
`MobileWingBrainsHoistTests` (new). Neighbours whose code this batch touched: `MobileWingListingTests` `MobileWingMintTests`
`MobileWingTagManagerTests` `MobileWingBlindPickerTests` (the fixture's suites) · `MobileNavigationTests` `MobileFilterTests`
`MobileVersionsTests` (they mount the shell, which now holds the door and the shared brain) · `MobileEmptyStoreTests`
`MobileDeletionTests` `MobileShelfRenderedLayoutTests` `MobileShelfLayoutBrainTests` `MobileFilterRowGeometryTests` (they
host the roots with no door — the plain line's road) · `MobileStructuralTests` (`nothingUserFacingNamesTheMac`) ·
`MobileNoRawErrorPinTests`.

**Claim (ii) — the whole Mac target** (scheme Variorum, platform=macOS, no `-only-testing` filter; a QUIET claim;
test-without-building on 5c80d058b's Mac products in `vm55-b1`; the dev-store Debug test host — a What's New sheet dismissed, no
instance left, a Finder "Moving to Trash" window left alone). About 60 min held (tonight's whole Mac target on another run was
about 6,400 tests in roughly 50 minutes). New and changed types to call out: batch 3's — `VM63MacWingBrainsHoistPinTests` (new),
`VM61MacStatusSeamPinTests` `VM62MacRefusalWordsPinTests` `WingPaletteDoorsTests` (edited), and its four attribution groups
(A)–(D) in "Batch 3 record" ▸ "For the shared window"; batch 4's one Mac-compiled change, the hoisted header's forward —
`VocabularySweepTests` (it pins `WingCopy.switcherHeader`), with `WingSwitcherTests` and `WingSwitcherChordTests` beside it.
*(Claim (ii) was changed at the GO to a targeted Mac leg — below.)*

#### The shared window's results (2026-11-19)

**Claim (i) — the whole phone target** (claim `vm-55` 09:20:51 → released 09:37:32; the standing iPhone 17 Pro simulator booted
fresh, settled 30 s; `test-without-building` on 5c80d058b's products, `-only-testing:VariorumMobileTests` one literal argument;
tests selected and starting by 09:23:50; the tree still from launch to verdict): Swift Testing **"Test run with 949 tests in 161
suites failed after 508.188 seconds with 7 issues (including 4 known issues)"** — 947 passed (945 clean; 2 with their DECLARED
known issues: `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` 2,
`MobileTutorialWalkTests.theFannedDivideLessonLandsTheDuplicateShape` 2), **2 failed**, 0 skipped (no `skipped:` lines); XCTest
"Executed 0". xcodebuild lingered after the verdict and was stopped by hand after 90 s. Log `DerivedData/vm55-b4-phone-window.log`.
- **Red 1 — `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`**, 2 of 3 cases ("hi",
  "hello there"): **main's**, VM-24's known red.
- **Red 2 — `MobileWingDoorShellTests.fromTheLibraryAPickLandsOnTheWingsBookcase`: THIS BRANCH'S, test-side.** 1 issue at
  `MobileWingDoorTests.swift:496`: labels were `["wings — each a separate library", "Done", "Home", "Work"]`, expected
  "Wings — each a separate library". **Traced:** the mounted shell runs in the Terminal voice (the test world's default), which
  lowercases chrome on every phone sheet title (`tokens.chromeLabel`); the pin compared the drawn header with the unvoiced
  constant. Every other expectation in the test passed — the name opened a real sheet, "Work" was pressed, the shared wing
  switched, the sheet went, it landed on the Shelf's Bookcase, the title door named Work, no line. **Re-run ALONE in the claim
  (09:37): red again, identically** — deterministic, not load. **Fixed test-only (931c77f79):** the pin compares the header as
  the shell's voice draws it. The same unvoiced premise was latent in two more batch-4 pins that host in Study (the list pin's
  header, the plain-line pin's "Home · Starred" literal) — both now compare what the voice draws. Every door label the pins
  find by name ("Home", "Work", the tab doors) is an explicit accessibility label — a name, never voiced — so it is right in
  both voices. **Re-run alone PENDING** (the follow-up claim).
- **The new and changed types:** batch 4 — `MobileWingDoorTests` 9/9 · `MobileWingDoorGeometryTests` 4/4 (the 44 pt target on
  all three real roots) · `MobileWingListSheetTests` 1/1 · `MobileWingDoorShellTests` 0/1 (above) · `MobileWingStandTests` 6/6
  (the fold's edited pins); batch 3 — `MobileWingBrainsHoistTests` 5/5; batch 1's VM-57/58/59/60 suites green; the sweeps —
  `MobileStructuralTests.nothingUserFacingNamesTheMac` passed, `MobileNoRawErrorPinTests` 2/2.
- After: simulator shut down; no Variorum instance (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"` empty); no Problem
  Reporter; no new `Variorum*-*.ips` (newest 05:45, before the window).

**Claim (ii) — CHANGED at the GO to a targeted Mac leg** (the coordinator's and the orchestrator's call: 74 types, not QUIET; the
whole Mac target runs once at the merge gate). The types: batch 3's groups (A) 29, (B) 3, (C) 37, (D) 3, plus
`CapabilityRegistryTests` and `StatusCenterTests`, one `-only-testing:VariorumTests/<Type>` argument each (each checked declared
once). Claim `vm-55` 09:39:23 → released 09:44:18; `test-without-building` on 5c80d058b's Mac products; the dev-store Debug test
host; tests starting by 09:39:45; the tree still. Swift Testing **"Test run with 537 tests in 74 suites failed after 199.619
seconds with 5 issues (including 4 known issues)"** — 535 passed (533 clean; 2 with DECLARED known issues,
`IndexTierMetricsTests`' `theBookIndexsLivePaneIsItsReadTierLineForLine` and `theReadEditLivePaneIsItsReadTierLineForLine`, 2
each), **1 failed**, 1 skipped (`MCPAsksWaitCaptureTests` — "13n-c U4 — asks wait + the keyboard, captured (a harness)", gated
off by design). xcodebuild exited on its own. Log `DerivedData/vm55-b4-mac-leg.log`.
- **The red — `VM63MacWingBrainsHoistPinTests.theMacsWingsBrainSpeaksTheMacsRefusalWords` (batch 3's new pin): THIS BRANCH'S,
  test-side.** "@Dependency(\.date) has no test implementation, but was accessed from a test context" at `AppSession.swift:858`:
  the pin's `withDependencies` set only the database, and `AppSession.init` reads the date. Every assertion held (the three
  parting cases spoke the Mac's words; the log shows the phone road's plain fallback being asked for comparison). Not a pointer
  or timing red; **re-run ALONE in the claim (09:44): red again, identically.** **Fixed test-only (c75bdb9af):** the scope
  supplies `date` and `uuid`, the Mac wing suites' own harness shape. **Re-run alone PENDING** (the follow-up claim).
- **Green on the merged tree:** the whole wing family (`WingSwitcherTests`, `WingSwitcherChordTests`, `WingDeliberateLandingTests`,
  `WingDestinationsDeadWingTests`, `WingFollowDecisionTests`, `WingFollowTests`, `JournalWingFollowTests`, `WingNumberKeysTests`,
  `WingPaletteDoorsTests`, `WingBookMoveDoorTests`, `WingChordsAndLabelDoorTests`), `VM61MacStatusSeamPinTests`,
  `VM62MacRefusalWordsPinTests`, `VocabularySweepTests` (the hoisted header's forward), group (C)'s source walks, group (D),
  `CapabilityRegistryTests` and `StatusCenterTests` — every one of the 74 types but the VM-63 pin's one test.
- After: no Variorum instance; no Problem Reporter; no new `Variorum*-*.ips`; no What's New interference seen (the run completed
  its 537 tests in one launch).

## Ladder

Cap FIVE rounds at her word ("up to 5 review rounds as long as a major is found"): a round that surfaces a new
BLOCKER or MAJOR earns the next; a round with none closes the ladder. A fresh `fable-reviewer` per round, the
prompt `notes/REVIEW_PROMPT.md` verbatim. Cross-model flow: findings go verbatim to a fresh `opus-implementer`
(every batch implementer is past the context guideline), its agree-or-dispute returns to the reviewer for the
final call, the implementer applies the confirmed fixes with red-on-old pins, and the next round's fresh
reviewer re-checks them. Each round's findings file is `notes/plans/fixes/vm-55-ladder-round<N>.md`; the
dispositions land here before the next round is spawned.

Owed to the first fix window (two re-runs of test-only fixes made after the shared window, both built green at
c75bdb9af): the phone wing-door types (`MobileWingDoorShellTests`, `MobileWingListSheetTests`,
`MobileWingDoorTests`, `MobileWingDoorGeometryTests`, `MobileWingStandTests`) and the Mac
`VM63MacWingBrainsHoistPinTests`.

### Round 1

*(spawned 2026-11-19 ~09:55 at 5fea9a453 + this notes commit)*

*(rounds, findings, dispositions)*

## Closeout

*(results, the ratify list, tickets filed, the rulings reconciled, MOBILE PARITY, canon-size)*
