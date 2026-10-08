# Chapter 06 — where things go (triage draft, U3 · R-13s-30)

Current seat: 6 of 10. Proposed seat: 6 (unchanged). Lessons: the five places · saving
a moment · what a copy carries · the two exits. Conventions: see `00-overview.md`.

---

## Lesson: the five places

### Final text

Nothing here goes anywhere you can't find. At any moment, everything you have ever
written is in exactly one of five places: where you left it · in Archive · in the Trash
· in this note's Versions · in this block's History. This lesson visits all five, and
the two after it teach the ones that are new.

One: where you left it. The ordinary case, said out loud because it is the one nobody
thinks to say. A note you wrote and did nothing else to sits in your Library exactly as
you left it, for as long as you keep it. The other four places exist only for things
you deliberately set aside, deliberately changed, or deliberately saved.

Two: Archive. Notes, forever, no clock. Right-click any note ▸ Archive and it leaves
the Library for Archived, its own item in the sidebar, with its own search. Nothing is
counting down and nothing needs remembering. It is still yours, still editable, still
exportable; archiving is about your Library's attention, not about the note. Unarchive
puts it back. (Blocks and takes archive too, and each waits where its context is: an
archived block in its note's tray, an archived take in its block's History. A thing set
aside stays next to what makes sense of it.)

Three: the Trash. What is leaving, for \(TrashWindow.days) days. Deleting a note, a
book or a block starts the clock, and all three wait it out behind the trash icon at
the top of the Library, every row saying how many days are left and which note it came
from, and Put back on any of them. A deleted take is the one thing that never rows
there: alone, out of its block, a take is too small to make sense of, so it waits in
that block's History instead.

Four: this note's Versions. Moments of the whole note, saved by hand. ⌘⇧S saves one;
note ▾ ▸ \(VersionsPath.menuLabel) lists them, newest first, each with Read, Restore
and Promote. A saved version is frozen at birth and stays out of your way, never in the
Library, never in Archived, because it is not another note. It is this note's past. The
next lesson is about the key.

Five: this block's History. Everything one block has been. The history door sits in the
bottom bar right beside commit, and it opens the Block History panel: each live take's
saved moments, the takes this block archived, the takes it deleted (with their clocks),
and \(BlockHistoryPath.cameFromSection), the blocks it came out of. Two lessons live in
there, and they are the two that follow.

Practice me: I'm here to be visited. Put your cursor in me and press history in the
bottom bar to read my (empty) past. Then come back after the next lesson and look
again.

A last honest word about the map: it is a map of places, not of promises about time.
Archive keeps forever; the Trash keeps for \(TrashWindow.days) days and then really
does delete; a note's Versions and a block's History keep for as long as the note or
the block does. Wherever something is, the surface it is on tells you which of those it
is. That is the whole design, and the reason there are five places instead of one.

### Change log

- ONE/TWO/THREE/FOUR/FIVE headers and WHERE YOU LEFT IT etc. → sentence-case lead-ins
  ("One: where you left it."); the five-place list itself keeps its middle dots.
- PRACTICE ME → "Practice me"; the act unchanged.
- Em dashes out; all interpolations kept (\(TrashWindow.days),
  \(VersionsPath.menuLabel), \(BlockHistoryPath.cameFromSection)).
- No claim changed; the honest-word closer kept whole.

---

## Lesson: saving a moment

### Final text

Two keys save two different sizes of the same idea, and the pair is worth learning
together. ⌘S saves a moment of this take (a commit: the block you're in, the take
you're looking at). ⌘⇧S saves a moment of this note (a version: all of it, as it
stands). One grain apart, one shift key apart.

⌘S's moments live exactly where you'd look for them: press history in the bottom bar,
immediately beside commit. That pairing is deliberate. Commit writes a moment, history
shows the moments, and the two sit together so the bar reads as the block's own time
controls. Every live take of the block has its own run in there, with the take you're
in already open.

Practice take: change a few words in me, press ⌘S, then press history. I'm where your
moment will be listed.

Restore beside a moment loads it back into the take. It does not overwrite anything:
moments only ever append, so restoring an old one and pressing ⌘S again just adds
another. That is the whole promise of a commit here. You can always come back,
including from the coming back.

⌘⇧S is the same idea one size up. It copies the whole note as it stands, every
paragraph on the page, every take on them, and keeps it under \(VersionsPath.menuLabel)
in the note ▾ menu. Restore makes the note say that again, and it saves where the note
is now first, so none of its words are lost. Promote turns a moment into a note of its
own, if you'd rather work with it than go back to it. What a copy carries, and what it
leaves behind, is the next lesson.

Which one to reach for? ⌘S when one paragraph is about to change and you might want
this wording back. ⌘⇧S before a rewrite, anything that will touch several blocks at
once. And you are not the only one saving: leaving a note quietly commits each take you
changed while you were in it, so the ⌘S you forget is mostly already taken for you.

### Change log

- THIS TAKE / THIS NOTE caps → the two parentheticals that also land the vocabulary:
  ⌘S's moment is named a commit, ⌘⇧S's a version, keeping the lesson's moment framing
  (the grain pairing is the teaching) while R-13s-31's label holds.
- "the whole promise of a savepoint here" → "of a commit here"; "quietly saves a
  moment for each take" → "quietly commits each take" (R-13s-31).
- PRACTICE TAKE → "Practice take"; the act unchanged.
- Em dashes out; \(VersionsPath.menuLabel) kept interpolated.

---

## Lesson: what a copy carries

### Final text

A copy carries the words, not the past. One rule, and it covers every gesture that
makes a second thing out of a first: saving a version of this note (⌘⇧S), duplicating a
note, dragging a piece out of Snippets into a draft. What arrives is the text and every
take on it, and nothing standing behind them.

So the moments do not travel. Commits stay on the take you pressed ⌘S on, in that
block's \(BlockHistoryPath.name); a copy's takes are born with one fresh moment of the
instant they were made and nothing before it. When you want the run of moments, you go
back to the block that has them, which is what the \(BlockHistoryPath.doorLabel) door
is for, and why it is worth knowing where the original is.

And a copy holds only what the note places: the paragraphs on the page, in their order.
A note keeps things beside its page that are not on it: blocks a divide or a merge set
aside whole (\(BlockHistoryPath.cameFromSection)), blocks you archived, blocks on their
way out in \(TrayPath.menuLabel). None of those are in a saved version. They belong to
the note and they stay with it, exactly where the map two lessons ago says they are.

Practice copy: put your cursor in me and press ⌘S to save a moment of this take. Now
press ⌘⇧S to save the whole note. Open note ▾ ▸ \(VersionsPath.menuLabel) and
\(VersionsPath.openVerb) the new moment: every word is there, mine included. The moment
you just saved is not. It is still here, in my history, where you left it.

This is why \(VersionsPath.restoreVerb) asks before it acts. It replaces the note's
paragraphs with the moment's, and the past of the paragraphs it replaces goes with
them: their saved moments, any take you deleted from them, any comment you deleted. The
confirm counts them and says so before you press it. \(VersionsPath.promoteVerb) is the
road that takes nothing. It makes the moment a note of its own and leaves everything
where it is.

None of this contradicts the map; it is the map applied to copies. A copy is a new
thing in the place you made it, and the past of the thing you copied stays exactly
where it already was. Which is the same reason nothing in this app is ever in two
places at once.

### Change log

- WORDS, MOMENTS, PLACES, NEW, NOT caps → plain prose; em dashes out.
- "Savepoints stay on the take" → "Commits stay on the take" (R-13s-31).
- PRACTICE COPY → "Practice copy"; the two-key act unchanged.
- All interpolations kept (\(BlockHistoryPath.name), \(BlockHistoryPath.doorLabel),
  \(BlockHistoryPath.cameFromSection), \(TrayPath.menuLabel), \(VersionsPath.*\)).

---

## Lesson: the two exits

### Final text

A paragraph can leave a page two different ways, and telling them apart answers the
question this whole chapter exists for: "I deleted a paragraph, so where is it?" The
rule is short. Deletion goes to the Trash; transformation goes to lineage.

The first exit: you deleted it. Triple-click the paragraph below and press ⌫. It leaves
the page onto a \(TrashWindow.days)-day clock, and it is now in two listings of the
same fact: \(TrayPath.menuLabel) (the tray icon at the top of the note,
\(TrayPath.leavingTab)) and the Trash in the Library. Put back in either one returns it
to the place it stood in. Deleted means leaving, and anything that is leaving always
says how long it has.

Exit one: triple-click me and press ⌫. I'm the deletion. Look for me under the tray's
\(TrayPath.leavingTab) view, and in the Trash, and put me back from either.

The second exit: it became something else. Select from the middle of the next paragraph
to the middle of the one after it and press ⌫. The two become one, quietly, the way any
editor would join them. But the two blocks you started with were not deleted. They were
kept whole, set aside, and the block they became remembers both.

Exit two, first half: select from somewhere in me all the way into the paragraph below,
and press ⌫.

Exit two, second half: and what we become will remember us both, by name.

Now look. Put your cursor in the joined paragraph and press history: its
\(BlockHistoryPath.cameFromSection) region lists both originals, not one of them, each
with its own text and a \(BlockHistoryPath.bringBackVerb) button that puts it into the
note again, beside what it became. Nothing counted down. Nothing was in the Trash. All
the app said at the time was one quiet line at the bottom, naming where the two
originals went, and this panel is where that line points.

One more thing, and it is the whole shape of a big selection. Select across several
paragraphs, press ⌫, and every block you touched gets exactly one of two fates, decided
by how much of it you selected. A block you covered whole leaves the page the first
way: to the Trash, with every take on it, together, so \(TrayPath.putBackVerb) returns
the whole family, not a piece of it. A block you covered only in part keeps its name
and its place, and only the take you can see loses its piece. The takes you are not
looking at are never touched.

The two ends then join, or they don't, and that is decided by where you cut. Cut in the
middle of a paragraph at both ends and the remainders become one paragraph, the way any
editor would join them: the second exit, with both originals kept whole under
\(BlockHistoryPath.cameFromSection). Cut at a paragraph break at either end (the top of
a block, the bottom of one, or a line break inside one) and the ends keep their own
blocks. You meant whole paragraphs, so whole paragraphs is what you get.

And there is one more way the ends stay apart: a take hanging on one of them. A
keystroke will never fold a fan away. The edit lands in the take you can see, the fan
stays where it is, and the two blocks stay two. When you do want them joined, merge
them deliberately and choose what the takes do.

Exit three, top: select from the middle of me…

Exit three, middle: …straight through all of me. I have two takes, and I go to the
Trash whole, both of them with me.

Exit three, bottom: …to the middle of me, and press ⌫. Then look: the top and I are one
paragraph, the middle is in the tray with both its takes, and one ⌥⌘Z puts all of it
back.

So, whenever something is missing: if you deleted it, look where things are leaving,
the note's tray, then the Trash. If you changed it (merged, divided), look inside what
it became, under \(BlockHistoryPath.cameFromSection). There is one place the two exits
meet, and it is honest about itself: a preserved original has no clock only while
something descended from it is alive, so deleting the last of those descendants moves
it, visibly, into the tray and onto the family's clock. The delete that does it says so
in its own receipt, while you are standing there.

### Staged content

- The middle block's second take: "the middle block's second take: it rides to the
  Trash too." (em dash → colon)

### Change log

- "The rule is four words long. DELETION GOES TO THE TRASH; TRANSFORMATION GOES TO
  LINEAGE." → "The rule is short. Deletion goes to the Trash; transformation goes to
  lineage." (the count was wrong; the caps are out; the rule is intact).
- EXIT ONE/TWO/THREE → "Exit one/two/three"; every staged act unchanged after the
  casing.
- **Port hook (load-bearing):** the seeder itself finds the staged middle block with
  `hasPrefix("EXIT THREE, middle")` — the prefix must become "Exit three, middle" in
  the same commit as the prose, or the staged take is silently never minted. The walk's
  `theChapterIsStagedForItsActs` count and the two-exits act tests re-pin with it.
- ONE MORE THING, WHOLE, IN PART, SEE, MOVES caps → plain prose; em dashes out.
- The rhetorical question's em dash → "so where is it?" (the guide's own sentence, not
  a UI quote).
- All interpolations kept (\(TrashWindow.days), \(TrayPath.menuLabel),
  \(TrayPath.leavingTab), \(TrayPath.putBackVerb),
  \(BlockHistoryPath.cameFromSection), \(BlockHistoryPath.bringBackVerb)).
