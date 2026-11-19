# VM-78 — Fixes to what's there: your handoff

**STATUS: DRAFT, refreshed on 2026-11-19.** It was refreshed after the editor finding below, your decision on it,
the badge fix's build and the third review round. Still ahead: the badge fix's test window, the merge, the fourth
review round and the final test gate. Every **PENDING(…)** slot is filled before the merge; nothing marked PENDING
has happened yet.

The record behind everything here is `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its FOR A LATER READER
section is the short version, and its Closeout section has the detail.

---

## Your checklist

- [ ] **The snap-back in the phone editor (VM-24) — you have decided; nothing is needed from you now.** It becomes
  its own run once wave 1 has merged (the next section). When that run starts it needs your hands: one session on
  your phone counting how often it happens, before the fix and again after.
- [ ] **Two provisional calls** (QUESTIONS PENDING(number)), each built the way the spec leans and waiting for your
  word:
  1. **An archived gathering in the phone's "add to a book" list.** Archived books there now say "(archived)". As
     built, an archived gathering says it too ("Quotes (archived) (by tagging)"). The Mac's chip leaves gatherings
     unmarked. Should both platforms mark it, or neither?
  2. **"Diverge" on a gathering's row** in a note's list of books. The phone no longer offers it there, because a
     gathering always refuses it. The Mac still offers it and then refuses with a sentence. No words of yours were
     found for either choice. Should the Mac follow the phone, the phone go back, or the two stay different on
     purpose?
- [ ] **The wording pass** — every line this run drafted, old beside new, is in the record's Closeout under "For her
  wording pass": the pocket guide's divide lesson, the "getting around" lesson's two sentences, the new-book sheet's
  three gathering lines, the sealed book's Reopen sentence on the phone ("This book is sealed, so it can't be
  reopened here." — does "here" read wrongly when the phone has no Unseal yet?), and whether the phone keeps a line
  at all after collecting a note into a gathering. Nothing in the editor work below adds words.
- [ ] **The tickets filed** — the list at the bottom.
- [ ] PENDING(the single wave-1 phone install, only if this run is the last of the four mobile runs to merge: the
  device build from merged main and a paste-ready kickoff for a fresh session at PENDING(where)).

## First: the snap-back in the phone editor (VM-24)

**What the trace found.** The phone's long-failing caret test was not a test setup problem. It shows a real
behaviour in how the phone editor decides which block an edit belongs to. Some ways of putting text in reach the
editor without it being told first: accepting an autocorrection or a prediction, dictating, committing text from
the candidate bar, and sometimes even an ordinary typed letter, when the keyboard slips a change of its own in
first. For those, the editor works out the block from TextKit's own report of what changed. TextKit sometimes
stretches that report past the end of the paragraph. When it does, the editor reads the change as crossing into
the next block, refuses it, and redraws the note from what is saved.

**What you would see.** The character or word you just put in snaps back to what was there before, with a flicker
as the note redraws. Your saved text is never at risk: nothing wrong is written, and anything you typed before it
is saved first. How often this happens on your phone has not been measured — the simulator cannot produce real
autocorrect, predictions or dictation. It looks like the same thing as an older watch item about the note
flickering (VX-68).

**You have decided.** You picked "Own run after wave 1 (Recommended)", and told the stage coordinator: "I chose the
own run after wave 1 option that vm-78 proposed. i want you to message them about this to lock the plan down, but
basically i want you to open a new session in tmux once wave 1 is done and merged, and tell it to architect-phase
that issue, reporting to you for stage details. just kick that off when wave1 is done for me."

**What happens next.** This run builds no fix for it. The caret test stays failing, on purpose and in plain sight —
it is the proof the fix has to turn green, and it is not hidden as a known issue. Once all four wave-1 mobile runs
have merged, the stage coordinator opens a new session that runs `/architect-phase vm-24`, reporting to the
coordinator for stage details. Its kickoff is written: `notes/plans/vm-24-unwarned-edit-routing.md`.

**What needs your hands, at that run's start.** One session on your phone with the editor's edit trace turned on:
typing with autocorrect on, accepting predictions, dictating, using the spelling menu and pasting, so the run counts
how often an edit arrives unannounced and how often a snap-back follows. That count is the "before"; the same
session after the fix is the "after". Putting a build on your phone for it is your hands too (the install runbook
is `notes/plans/vm-44/plans/vm-45-install-runbook.md`).

## The takes badges on long notes (VM-17)

**It was real.** On a long note with many blocks that have takes, scrolling down could leave a takes badge sitting
beside the wrong paragraph — one stood about 1,260 points from its own block — or a little above its own line, and
some blocks with takes showed no badge on their line at all. Jumping straight to a block was fine, and nothing piled
up at the top of the note, which is what the ticket had suspected.

**Its fix is built in this run.** The takes marks (the badge, the peek marker and the choosing pill) are now drawn only for text
the screen has actually laid out, and checked a second time in the same screen update, after the layout has
settled. Nothing off screen is measured or left standing. A small measurement chose the moment for that second
check. The fix is built and compiles; PENDING(its test window — the badge test shown failing on the old code and
passing on the new, with the other takes tests passing).

**A related finding, and a ticket if it is real.** The third review pointed out that the callout colours, their
glyphs and the comment marks are placed by the same old rule the badges had. Nobody had measured them, so a
measurement runs in the badge fix's test window. If it shows the problem, a ticket is filed with that failing
measurement as its proof (it is first in the list at the bottom); if it does not, the finding closes as unfounded.
PENDING(the measurement's result). Nothing for you to decide.

## What changed on the phone, in plain words

1. **Undo no longer offers to redo the wrong thing (VM-16).** If an undo found nothing to do — because the change
   had already been reversed some other way — the phone still said "Undid: X" and offered a Redo that would have
   re-applied a different change. Now it says the Mac's sentence ("Nothing to undo — X was already undone or
   changed since.") and offers nothing. The same for redo. PENDING: the wings run (vm-55) merges first and changes
   how every phone screen shows its messages, so this fix is re-applied on top of that, and its tests are shown
   failing on the old door and passing on the new one again.
2. **The undo warning says "committed" (VM-20).** It said "It is saved first"; it now says the Mac's "It is
   committed first".
3. **A restore keeps what it replaces (VM-43).** Restoring an older commit on the phone now keeps one quiet commit
   of the words it is about to replace, as the Mac does — your ruling at the November 10 sitting.
4. **The pocket guide's divide lesson tells the truth (VM-3).** It taught that other takes are copied onto both
   halves; the phone keeps them on the top block. The lesson is rewritten (a draft for your pass).
5. **The date chip follows the date (VM-84).** On a note with a title, changing its date left the chip showing the
   old day until something else changed. Now it updates at once.
6. **The Trash no longer flashes "empty" (VM-33).** Opening a Trash with things in it showed "Nothing in the Trash."
   for a moment first. The test proved this was real; now nothing shows until the list has loaded.
7. **Finish asks first (VM-81).** Finishing a book dismisses everything waiting at its Arrivals. The phone now asks
   — "Finish "‹name›"?" with "N waiting at Arrivals will be dismissed." — only when something is waiting, exactly as
   the Mac does. The "Open Arrivals first" button you asked to keep is not built yet; it needs the phone's Arrivals
   screen, which comes with VM-175.
8. **Book Details tells the truth and shows only doors that work (VM-81).** Its caption said a finished book
   "freezes its notes"; it now says the Mac's "Finished means the table of contents is done — the writing inside can
   still change." Finish is no longer drawn on a gathering (it always refused). Reopen on a sealed book now says a
   sentence instead of raw error text. "Diverge" is no longer offered on a gathering's row (your call 2 above).
9. **A starred archived book has a way out (VM-81).** Opening it from Starred showed an empty sheet. Now the sheet
   shows the book, marked archived, with an Unarchive button.
10. **The shelf sorts properly, with one star (VM-83).** "Zebra" sorted before "apple" and "Book 10" before "Book
    2". Now it is a–z, numbers in order, starred books first — the Mac's rule. Choosing a different order waits for
    the phone's Bookcase in wave 3, as you said. "Pin to Shelf Top" is gone: it was the star under another name.
11. **A gathering is called a gathering (VM-83).** The shelf, the delete button, its confirmation and its message,
    the note's book list, the new-book sheet and the Trash said "smart book" or "book"; they now say "gathering". A
    few spots are left for the tickets that own those screens (the record lists them).
12. **The collect message tells the truth (VM-21).** Collecting a note into a gathering by starring it said
    nothing about the star, and on an archived gathering it claimed the gathering shows the note. It now says the
    Mac's words: "Starred — the gathering shows it now." or "…once it's unarchived."
13. **The takes badges stay on their own lines (VM-17)** — above; PENDING its test window.
14. **A test that left the keyboard focus behind now lets go of it (VM-19).** It was suspected of upsetting the
    editor in later tests; that did not happen on this toolchain, so the fix stands as tidiness in the tests.

## The evidence, in a few lines

- Every fix in batches A and B and the review fixes was shown failing on the old code and passing on the new one,
  in stage windows on the simulator: batch B (68 tests), batch A (84 tests, plus the Mac's 110 tests over the words
  moved into shared code), the first review's fixes (75 tests), and two short follow-ups (4 tests and 11 tests).
- The editor window ran eleven test runs: the caret test failed exactly as expected while the trace tests beside it
  showed why, the badge test failed on the old code (proving the badge problem real), and the keyboard-focus test
  failed on the old version and passed on the fix.
- A measurement on the badge note showed the moment when the screen's layout has settled, which is the moment the
  fix now checks the badges again.
- PENDING: the badge fix's window and the callout-and-comment measurement; the whole phone test target and the Mac
  tests on the merged tree; the walk through each changed screen on the simulator, including a long note scrolled
  top to bottom.

## The review, in plain words

A fresh reviewer read the run three times. The first round found two major points — the run could not be called
reviewed until the editor work was read, and the badge test as first written could not see the problem it was
meant to catch — plus small fixes, all applied and proved. The second round found nothing major. The third round
read the editor findings and found one major point: the callout colours and comment marks share the badges' old
rule (the measurement and ticket above). It also corrected how far the snap-back reaches — an ordinary typed letter
can be caught by it too — and that correction is in the section on VM-24. The same round set the shape of the badge
fix, which was then built exactly. A fourth round is owed: it reads the badge fix with its test results and the undo
fix re-applied after the merge. PENDING(its outcome).

## What a later reader would otherwise trip on

- **The caret test is failing on purpose.** `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
  stays red on main after this merge, by your decision, until VM-24's own run fixes the editor. It is not wrapped as
  a known issue and must not be.
- **The verification checkout.** The orchestrator ran most stage windows from a separate throwaway copy of the
  branch (`~/dev/variorum-vm-78-pins`, with its own build folder) so an implementer could keep the worktree. It is
  removed at closeout with the worktree.
- **Some test result files are missing or cannot be opened.** Batch B's failing run kept no result file, and the
  failing runs of the round-1 fixes and of the VoiceOver-hint fix were stopped before Xcode finished writing theirs.
  The kept logs, under `App/Variorum/DerivedData/logs/` in the worktree, are the evidence, and they agree with the
  record.
- **The wings run's message line.** vm-55 moves every phone message onto one shared line and rewrites the undo
  door's tests. When this branch takes main behind it, VM-16 is re-applied on that line, and Book Details' refusal
  function meets VM-62's change at the same spot.
- **Two shared notes files clash with the search run on the way in.** `notes/MobileSoul.md` and
  `notes/SurfaceContracts.md` both collide in text with the search run that merged first (VX-980); both runs' lines
  are kept. This run's row in MobileSoul's parity ledger was drafted as number 75, which the search run already
  took, so it takes the next free number at the merge.
- **Measurement files leave before the full test run.** The editor trace tests and the badge measurement are
  already gone; the callout-and-comment measurement leaves in a named commit right after its window. If the badge
  fix were not to land in this run, the badge test would leave the branch too, in a named commit VM-17's ticket
  cites, rather than sit failing on main.
- **VM-20 and VM-19 were already closed** as duplicates when the plan was minted; their work is done here under
  VM-16 and VM-24.

## Tickets filed:

- [ ] **to mint on VM, only if the callout-and-comment measurement fails** (Medium · Bug · Editor) — Callout colours, their glyphs and comment marks can stand away from their own blocks on a long note.
- [ ] **to mint on VM** (Low · Bug · Library & sidebar) — The Archive room may show "Nothing archived." before its list loads (the Trash's old flash).
- [ ] **to mint on VM** (Low · Bug · Books) — A book's contents may show "No notes in this book yet." before its list loads.
- [ ] **to mint on VM, or a line on VM-218** (Low · Bug · Books) — Book Details' name row hides the book's name from VoiceOver.
- [ ] **to mint on VX** (Low · Debt · Books) — A core comment still describes the shelf's retired pin order.
- [ ] **to mint on VX, only if your answer to call 2 is that neither platform offers it** (Low · Bug · Books) — The Mac's book chip offers Diverge on a gathering's row, then refuses.

Not a new ticket: VM-24 stays open as the ticket for its own run.
