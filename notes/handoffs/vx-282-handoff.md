# VX-282 handoff — Editor & notes fixes (2026-10-14)

**Run:** VX-282 "Run: Editor & notes fixes" · PR #160, merged to `main` as merge commit `19be2f01` · the record
`notes/plans/fixes/vx-282-editor-notes-fixes.md` (every unit, stage window, walk, finding and disposition) · built
overnight 2026-10-13/14 under your mandate: *"continue on through the night ending in a merge to main … Rule
provisionally in my absence and leave me a handoff with any needed information to note down."*

## Your checklist

1. **Ratify or reverse the provisional calls — QUESTIONS #220–#224.** Each was built as stated, with a line to
   reverse it. The ones most worth your eye in daily use:
   - **#220, the italics fix (VX-296):**
     - **The opening star doesn't yield to the caret, only the closing one does** (your ruling's letter). The opening
       side still flips if you backspace the first word away.
     - **The rule covers every emphasis closer** (`*`, `**`, `~~`, `_`), not just the italic star. ⌘B's pair flickered
       worse than ⌘I's.
     - **⌘I/⌘B still read the old grammar**, so at `*hello |*` the face shows italics but ⌘I adds a new pair.
     - **A new flicker class, disclosed:** with the caret parked just before an inner star in a span that already
       stood (`*foo *bar*`), the span shortens while the caret sits there. The option is to rescue only where no span
       already covers that star.
     - **Plainly said:** the fix lives inside the markdown grammar's code, though every reader except the live editor
       reads exactly as before. The ticket you approved said the grammar would be untouched.
   - **#221, the take panel (VX-154), eight calls:**
     - ⌘S with nothing clicked commits the take the block shows, and the ring moves onto it.
     - The nine verbs that cut, join or add blocks are grey while the panel is up.
     - ⌘⇧T closes the panel.
     - The ⌘S name field covers the panel's first card, which can be the very take being committed.
   - **#222, the capture box:** undo is the box's own, and filing ends it.
   - **#223, the kept comment draft (VX-257):**
     - one draft at a time, the newest;
     - Close keeps it too;
     - it comes back silently with the caret at the end;
     - emptying the box lets it go.
   - **#224, launch focus (VX-326):**
     - the ask is decided when the box reaches its window, on that window alone;
     - only a window that OPENS on the Bookcase asks; coming back to the Bookcase doesn't (VX-332).
2. **New tickets, pre-launch or not is your call on each:**
   - **VX-319:** Write's word count reads one short after a carve.
   - **VX-320:** Export Block exports the caret block under the take panel.
   - **VX-321:** "archived · n" in Move Take's receipt.
   - **VX-322:** the capture box's focus flag across a re-attach. Untraced.
   - **VX-325:** ⌘K queues behind the take panel.
   - **VX-331:** the restore confirm counts deleted takes past 30 days.
   - **VX-332:** coming back to the Bookcase doesn't focus quick entry.
   - **VX-334:** ⌃⌘↑/↓ act under the take panel.
   - **VX-335:** two ⌫ presses in one main-actor turn. Only seen in a test.
   - **VX-337:** two Takes tests fail only under whole-target load.
   - **VM-18:** the phone's comment sheet still drops a half-typed comment.
   - **VM-19:** a phone test-posture gap that can desync the editor.
3. **Seeing it:** this merge did NOT refresh `/Applications`. Your rule is that only the night's last merge does,
   and the coordinator named VX-246 as last. After the night's refresh:
   - type inside `*hello*` word by word: the italics hold at each space;
   - in an empty block, ⌫ moves the caret up into the line above;
   - open a block's ⑂ take panel and press ⌘S: the commit lands on the panel's take;
   - type half a comment in the Takes margin popover, click away, reopen: it's back;
   - quit and relaunch onto the Bookcase: the caret is in quick entry.

## What shipped

- **VX-290 — the empty-block backspace.**
  - The caret lands where the deleted line break was. ⌫ moves you up; ⌦ keeps you in place; the ⏎⌫ "oops" lands back where you were.
  - Delete Block and archive keep their own landing.
  - The walk held all five rows, including two real presses 30 ms apart.
- **VX-296 — the italics flicker, your fix (a), on the Mac and the phone.**
  - While your caret sits right after the space before a closing marker, the span stays styled.
  - Leaving a trailing space behind un-styles it honestly.
  - Only an editor you can type in honours a caret. A sealed note's doesn't.
  - Arithmetic (`2 * 3 * 4`) stays plain at every caret position.
- **VX-154 — Write's take panel acts on its own block.** Every command about a block or a take now acts on the panel's block, or greys out. It never acts on Write's caret block beneath the sheet.
- **VX-193 — the capture box's own undo.**
  - It fixes the real, live-reproduced bug: ⌘Z after an empty filing raised an exception, and undo in that box then stopped working.
  - The ticket's headline (⏎ filing undone words) did NOT reproduce in use, only under test-driven undo. Its re-sync stays as a harmless belt.
- **VX-112 — focus re-take.** The box re-takes the keyboard only when it held it, and never steals it. Your tour-time sighting was Terminal's decorative block cursor, which shows exactly when the box does NOT hold the caret.
- **VX-326 (joined at your word) — launch focus.** Launching, unlocking or opening a new window onto the Bookcase now puts the caret in quick entry, unless something else holds the keyboard.
- **VX-257 — the kept comment draft.** A half-typed comment survives any close except ⎋, and comes back on reopen at that block. That covers all four places the panel opens, including the take panel's nested sheet.
- **VX-183:** the comments panel's doors are declared in the capability registry. They look and act the same.
- **VX-182:** the version-restore confirm no longer counts deleted takes already queued for permanent deletion.
- **VX-229 — dismissed as hollow in use.** In the running app, a heap count after repeated popover and sheet closes found 0 panels, 0 observers and 0 areas alive. The "leak" exists only in the test runner, recorded there as known issues.
- **Also:** `CommentsPanel` and `CommentTextArea` moved to `Core/Views/` (the shared-home rule; two features use them).

## How it was checked

- **Each unit was proven three ways:** tests that fail on the old code (proven by building the old code), a Mac test batch, and a walk on the dev store. U2 and the C-1 fix also ran the phone suites.
- **The ladder:**
  - Opus round 1: 0 blockers, 0 majors, 6 minor, 4 nits. All agreed, and the three bugs were fixed with failing-first tests.
  - The run's one Fable review, round 2: 0 blockers, 0 majors, 2 minor, 3 nits. All confirmed, and two were fixed failing-first.
  - I checked the final round's fixes line by line.
- **Closeout on the merged code:**
  - The whole Mac target: 4,666 tests / 767 suites. The reds are only the ones standing on main (VX-115, ChromeLineLimit's six sites, VX-167) plus VX-337's two load flakes.
  - The whole phone target at the exact final code: 824 / 129. The only red is the standing `nothingUserFacingNamesTheMac`.
  - Headless: core 2,809/322 · MCP 212/41 · workbook 40/6.
- **One closeout surprise (C-1):** a phone crash in the whole-phone run.
  - Decided by a test-only decider: it's an older phone test-posture gap (VM-19), not the italics fix.
  - The italics test suite now sets up its own window properly.
  - A phone guard I'd added was proven not to matter and was reverted.

## Notes

- Zero `Sync/`, custody, Keychain or schema lines; marker 13 untouched.
- **FYI (no ticket):** VX-179's comments panel carries the same undo re-sync pair and stale-monitor test on the same probe-only basis as VX-193 and VX-229. Both are harmless, recorded in the run's § U5.
- **Machinery honesty:** two agents overlapped briefly once. That was record-only, and it's noted in the record.
- MOBILE PARITY: `notes/MobileSoul.md` PL-54. The merge-moment ledgers are `3ddec585` (AppSpec §9/§12/§14, MobileSoul, the in-flight row).
