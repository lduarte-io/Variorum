# VM-55 — Wings underneath: your morning handoff

**STATUS: DRAFT (2026-11-19) — built, reviewed and walked; the merge gate's two full runs and the merge itself are still to come. This line is replaced when the run merges.**

*How to read the ids in this file:* **VM-NNN** and **VX-NNN** are tickets on the board. **P-55-N** is a
provisional call built while you were away, waiting for you; all of them are QUESTIONS #277. A **window** is a
test run on the shared Mac, granted by **nov18** (tonight's stage coordinator session). The **ladder** is the cold
code review.

---

## What happened tonight, in plain words

You asked for wave 1 of the mobile catch-up to run overnight. This is its second umbrella: the phone learns
wings, gets one message line, and stops showing raw error text. It ran as four batches, each built by a fresh
builder, then one cold review, a walk in the simulator, and the full test suites on both apps. Two things joined
mid-run at your word: the plain interim wing door, and up to five review rounds.

Here is each piece:

1. **The phone stands in one wing (VM-56, VM-57, VM-58, VM-60).** The phone remembers its wing between launches,
   and drops back to Home if that wing is deleted, here or by sync. The Library, Pool, books, Starred, Archived,
   Trash and today's title search show that wing only; Snippets stay the one room all wings share. Empty Trash
   empties only the wing it shows. New notes, quick notes, books and top-level tags are born in the wing you
   stand in. Today's entry is still born beside the Journal, wherever the Journal lives. The tag manager is
   headed "Tags — in ‹wing›" and lists and makes that wing's tags.

2. **The pickers stay in the note's own wing (VM-59, a real bug).** A note's tag suggestions used to list every
   wing's tags, and tapping one made a twin tag in the note's wing. The add-to-book sheet offered other wings'
   books, which could only refuse. The gathering's tag picker could write a rule term that matches nothing. Each
   picker now reads its own note's or book's wing. Three tests fail on the old code and pass on the fix.

3. **One message line (VM-61).** Every screen used to keep its own error and receipt lines. There is now one
   line, drawn once above everything, including sheets. It follows your rule: nothing for ordinary acts; a line
   with Undo when something leaves the page; a line for a refusal. It sits above the tab bar and above the
   keyboard, fades by itself, and hides as the app leaves the foreground so it never shows in the app switcher.
   The Mac's messages are unchanged, byte for byte, and pinned.

4. **Refusals in plain words (VM-62, a real bug).** About a hundred places on the phone printed raw error text
   such as "That couldn't be done — wrongReadingKind(…)". Each now speaks the sentence the Mac already uses, or
   one plain fallback when nothing has words for the failure. A test scans the phone's source and fails if a raw
   error can reach the screen again.

5. **The Mac's wing brains moved to shared code (VM-63).** Nothing you can see. The wing switcher's logic now
   lives where both apps compile it, so wave 2's switcher is a face over it, not a rewrite. The Mac behaves
   exactly as before.

6. **The interim wing door (VM-225, added at your word).** On Starred, the Shelf and the Library, tap the wing's
   name in the top line. A plain list of your wings opens, Home first, the current one ticked. Pick one and you
   land on its Bookcase. This is what makes a build of main usable on your phone before wave 2.

**The review.** One fresh Fable reviewer read the whole run cold and found no blocker and no major: two minor
points and five nits. Under your five-round rule a round with no major closes the review, so it closed at round 1.
Three small fixes came out of it: a "standing" offer can no longer get stuck invisibly on the phone; two new log
lines no longer write your words or an error's detail as public text; and VoiceOver reads the wing door as "Home,
Library, button" again.

**What the test windows caught along the way** (each fixed, none left open):
- The message line sat 34 points too low on a phone with a home indicator, over the tab bar's buttons. Its own
  test caught it.
- Four of this run's own new tests were wrong about the app, not the app about them (a scan that matched an
  unrelated line; a missing test clock; a lowercase title in the Terminal voice, in three tests).

**The walk.** On a simulator made for the purpose, with a small seeded library of two wings (Home and Work), in
Study and then the key rows again in Terminal. Eleven of twelve checks passed, each judged from its screenshot:
every root names its wing and lists only that wing's things; the wing door's list opens with the current wing
ticked, and a pick lands on the other wing's Bookcase with no line shown; a new note and a quick note land in the
wing stood in; "Tags — in Work" lists only Work's tags; with the app standing in Home, a Work note's tag
suggestions and add-to-book sheet offered only Work's; Finish on a gathering spoke its sentence in words and faded
by itself; deleting a note drew "Note moved to the Trash — 30 days to put it back." with Undo just above the tab
bar, and Undo brought it back; starring a note said nothing; with the keyboard up the line sat above the keyboard;
the wing survived going to the background and a relaunch; VoiceOver reads the door as "Work, Starred, button". The
twelfth check, a direction keeping its line, was not walked by hand: the driver looked for a deleted take in the
Trash, which never lists takes, so that check rests on its test. Nothing was installed on your phone.

**Seen on the walk that is not this run's** (none fixed here): the capture box keeps the keyboard up across a page
change (it belongs with your keyboard report in the wave 2 capture umbrella, VM-72); in Terminal the Shelf's top
line wraps its book count onto a second line (sizes are VM-47's); a gathering still reads "smart" (VM-78's);
Book Details still offers Finish on a gathering, a door that can only refuse (the book-settings umbrella, VM-156).

**The full suites, on the tree that merged.** PENDING — the whole phone test target and the whole Mac test target, run through nov18 on the tree that merges.

---

## Your checklist

- [ ] Read the decisions below (they are QUESTIONS #277). Nineteen were built provisionally.
- [ ] Look over the lines that no longer show, at the end of this file. Any one comes back with a one-word change.
- [ ] The wording pass: the new sentences are listed below.
- [ ] Say whether "up to 5 review rounds as long as a major is found" was for tonight's runs or is a standing
      change. I read it as this run's rule and did not edit CLAUDE.md.
- [ ] The phone install is NOT this run's: it merged first of the four mobile runs. Whichever merges last builds
      the wave-1 phone app overnight, and the install waits for you at the phone, as you said ("ok i'll do the
      hands part in the morning.").
- [ ] The filed tickets at the bottom.

---

## Decisions waiting on you

Each was built at its most defensible option. "Built" names what is in the app.

### Wings
- **P-55-2 — how a root says its wing before wave 2's title band.** (a) The wing's name leads today's top line
  ("Home · Library"). **Built.** (b) The name replaces the page word. (c) A title row of its own.
- **P-55-14 — what a wing switch does to screens you have open.** (a) Nothing is closed; the roots re-scope.
  **Built.** (b) Every stack pops to its root. (c) Switching only from a root.
- **P-55-15 — the wing's name when you have only one wing.** (a) Still a door; the list shows Home alone.
  **Built.** (b) Plain text until a second wing exists.
- **P-55-17 — the interim door's look.** The name in the accent colour, the whole title the tap target, and the
  top line 10 points taller so the target is a real 44 points. **Built**; wave 2's band replaces it.
- **P-55-18 — a half-typed quick note when you switch wings.** (a) The switch files it first, into the wing it
  was written in. **Built.** (b) It follows you to the new wing. (c) The switch is refused while a draft stands.
- **P-55-16 — the empty-Shelf and empty-Library lines assume Home.** Left as they are; VM-231 carries them.
- **P-55-13 — four sentences in the shared wing code name Mac doors or keys.** Moved unchanged; no phone screen
  says them yet; VM-231 carries them.

### The message line
- **P-55-1 — the receipts setting on the phone.** (a) Honoured. (b) Not read, because "only removals and
  refusals" leaves it nothing to govern. **Built.** (c) "Off" also silences removal lines.
- **P-55-3 — how long a refusal stays.** (a) It fades by itself, with no ✕. **Built.** (b) It stays until your ✕
  or your next act; two mockup captions draw this. (c) A longer clock for refusals.
- **P-55-4 — what counts as leaving the page.** (a) Deletes, merges, archives, and the Trash's confirmed purges
  (no Undo there); putting something back says nothing. **Built.** (b) Put back and Unarchive also keep a line,
  with Open ›. (c) Every row that leaves any page.
- **P-55-5 — the merge's line.** (a) A bare Undo, no words. **Built.** (b) "Merged", drafted, waiting on your
  wording pass. (c) Silence, with Undo in the ⋯ sheet only.
- **P-55-7 and P-55-11 — directions keep their line.** A direction tells you the act landed somewhere you
  wouldn't look, or did more than you asked: "Already collected — …", the shelving notes, a take put back as
  archived, a block put back at the end of its note, "Added by tagging #… — “…” collects by filter." **Built:**
  they speak. The alternative is silence, like other ordinary acts.
- **P-55-19 — a direction's colour.** A direction rides the refusal class, and the phone draws every refusal in
  the alarm red, so "Put back where it came from." reads like an error. (a) Keep. **Built**, unruled until now.
  (b) A neutral colour for directions.
- **P-55-8 — Book Details' delete and archive.** (a) They speak the same line and Undo as the Shelf row's.
  **Built.** (b) Silent, as before.
- **P-55-9 — an edit across blocks.** (a) A removal, with its bare Undo. **Built.** (b) Typing, no line.
- **P-55-10 — where the line lives over a sheet.** (a) One line above everything. **Built.** (b) A line per
  sheet. (c) The main screen only, so a refusal raised in a sheet waits until it closes.
- **P-55-6 — an offer on the phone.** No phone door raises one today. **Built:** it would show, with its door,
  and fade like any line.
- **P-55-12 — the fallback's words.** (a) "That couldn't be done." **Built**, a draft. (b) "Something went
  wrong — try again." (c) A fallback per door.

## The new sentences, for your wording pass

- "That couldn't be done." — the fallback when nothing has words for a failure.
- "Copy failed: That couldn't be done." — the note's Copy door, when the copy fails.
- "This book is sealed, so it can't be reopened here." and "This note is in a book that is sealed, so it can't be
  changed here." — existing phone sentences, now actually reached.
- "That library isn't there any more — nothing changed." — an existing sentence, now said when you pick a wing
  that was deleted while the list was open.
- "Wings — each a separate library" (the list's heading) and "Tags — in ‹wing›" are the Mac's own, reused.

## The lines that no longer show

Your rule was "Only removals and refusals". These ordinary-act lines stopped showing on the phone. The record
lists each with its file (`notes/plans/fixes/vm-55-wings-underneath.md`, batch 2a).

- "Copied this note to the clipboard."
- "Saved a version — the whole note as it is now, in Versions."
- "New block added below — type away."
- "This block has ‹N› other takes — they keep this span."
- The bare Undo button after a divide, an extract and Make Block.
- "Undid: ‹label›" with its Redo button, and "Redid: ‹label›" with its Undo button. The ⋯ sheet's Undo and Redo
  rows stay.
- "Take moved up." and "Take moved down."
- "Committed — a saved moment of this take is kept."
- The plain restore, unarchive and put-back lines ("Put back where it was.", "Take unarchived — it's back in this
  block's fan.", "Unarchived — it's back in the library.", and their kin).
- The two Versions lines after restoring or promoting a version.
- "Added to “‹book›”.", "Removed from “‹book›” — the note itself is untouched.", and "Diverged — …".
- The lens lines ("Adopted — …", and a pick restored).

## Things a later reader would otherwise trip on

- The record is `notes/plans/fixes/vm-55-wings-underneath.md`; read its FOR A LATER READER section first.
- The interim wing door is temporary. VM-80 replaces it whole, and a note on VM-80 says what exists.
- The Protection screen was not touched: its messages still use their own lines (VM-229), and two failures there
  can still show raw error text (VM-230). Both sit under the lock umbrella, VM-103.
- `Tools/canon-size`: 143,078 of 150,000 (headroom 6,922); no crossing.

## Tickets filed
Tickets filed:
- [ ] VM-225 (High, Feature, In Progress): the interim wing door; built in this run and closes at the merge.
- [ ] VM-229 (Medium, Improvement, Todo): the Protection screen's messages join the phone's one message line (under the lock umbrella, VM-103).
- [ ] VM-230 (Medium, Bug, Todo): the library-open failure screen and a failed account deletion still show raw error text (under VM-103).
- [ ] VX-1021 (Medium, Bug, Backlog): a book whose wing was deleted shows on no Bookcase, Mac or phone.
- [ ] VM-231 (Low, Improvement, Todo): wing words for the phone — the empty-wing lines, and four sentences that name Mac doors (under VM-72).
- [ ] VX-1022 (Low, Bug, Backlog): the Mac's wing switcher can switch into a wing deleted while its list stood open.
- [ ] VX-1023 (Low, Debt, Backlog): a test that boots the app fully reads and can write the test host's remembered wing.
- [ ] VX-1024 (Low, Debt, Backlog): the sample library's welcome arrangement logs a raw error as public text.

Comments were left on VM-80 (the wave 2 switcher now replaces an existing door, and four provisional calls bear on
it) and on VM-216 (the wing door has no VoiceOver hint yet). The four VX tickets are parked in Backlog, each with
its reason, as riders for the next run in their areas.
