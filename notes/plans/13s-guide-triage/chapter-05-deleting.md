# Chapter 05 — deleting & getting it back (triage draft, U3 · R-13s-30)

Current seat: 5 of 10. Proposed seat: 5 (unchanged). Lessons: deleting blocks ·
archive · delete · scraps · the tray & the Trash · what a block leaves behind. Every
lesson's delete act is preserved (J10's mandate); the walk tests execute them.
Conventions: see `00-overview.md`.

---

## Lesson: deleting blocks

### Final text

Deleting is meant to be easy here, because nothing you delete is gone the moment you
delete it. A deleted block leaves the note keeping its takes and its commits, and it
waits: first on ⌥⌘Z, then in this note's tray, then in the Trash for
\(TrashWindow.days) days. This chapter has you delete things on purpose, so you know
exactly where each one landed.

The everyday way is the way you already know: select a whole paragraph and press ⌫.
Triple-click the next paragraph, or drag across it and a little past its end, then
delete. The block goes, and the note closes over it. (Select only the words inside a
paragraph and delete, and you get exactly what you asked for instead: an empty block,
still there, ready to type in.)

Scratch one: this paragraph exists to be deleted. Triple-click me and press ⌫.

Several at once: hold ⌘ and click each block you want (⌘⇧-click picks a whole run). A
banner appears above the page counting what you picked, with Delete N Blocks on it; the
right-click menu carries the same row. They all go under one undo. A multi-delete is
one mistake to reverse, not five.

Scratch two: ⌘-click me and the paragraph below, then press Delete 2 Blocks.

Scratch three: I'm the other half of that pair.

⌥⌘Z is the undo for all of it: one press brings back one delete however many blocks it
took, and ⇧⌥⌘Z deletes them again. If you reach for ⌘Z out of habit and there is
nothing left to undo in the text, the app says so at the bottom of the window and names
⌥⌘Z for you. Two undo stacks, kept separate on purpose, and a sign at the junction.

Everything you just deleted is in This Note's Tray. Open it with the tray icon at the
top of the note, beside Scraps and References. It opens in the panel on the right, and
it is always there. A note that has deleted blocks also wears a quiet ⌫ badge with the
count in the context bar above the page; clicking it opens the same panel. The next two
lessons live there.

### Change log

- SCRATCH ONE/TWO/THREE → "Scratch one/two/three"; the acts unchanged word for word
  after the colon. The walk tests that drive these blocks re-pin to the new casing at
  the landing.
- "its takes and its savepoints" → "its takes and its commits" (R-13s-31).
- Literal "30 days" → \(TrashWindow.days) (flagged promotion, overview item 3).
- Em dashes out; ONE undo → one undo; no door dropped.

---

## Lesson: archive · delete · scraps

### Final text

A block you don't want here has three different fates, and the difference between them
is the thing to learn once. Archive keeps it forever: out of the note, in this note's
tray, with no countdown. Delete starts the \(TrashWindow.days)-day clock: it waits in
the Trash, and then it really is gone. Moving a block out to Snippets cuts the tie to
this note altogether and leaves it as a scrap you can drag into anything.

Archive me: I'm worth keeping and I don't belong in this note today. Put your cursor in
me and use Block ▸ Archive Block; the right-click menu has the same row. I leave the
page and wait under the tray's \(TrayPath.archivedTab) view wearing "kept — no clock",
and Put back returns me to this exact spot.

Delete me: I've had my day. Block ▸ Delete Block, or triple-click me and press ⌫. I go
to the same tray's \(TrayPath.leavingTab) view with a countdown on me, and to the Trash
in the Library, and in \(TrashWindow.days) days I'm gone for real.

Move me out: I'm a decent line in the wrong note. Open Blocks (⌘6), find my row, and
use its ⋯ menu ▸ \(SnippetsCopy.moveOutRow). It opens onto your groups; pick one. I
become a scrap there, material for anywhere, and ⌥⌘Z brings me back if that wasn't what
you meant.

Which one? Archive when you want it kept and out of the way; delete when you mean it;
move it out when the words are fine and the home is wrong. All three are one ⌥⌘Z away
for as long as this session is open, and the two that leave something behind put it
somewhere you can find it.

### Change log

- ARCHIVE ME / DELETE ME / MOVE ME OUT → sentence case; the three acts unchanged.
- MOVE OUT TO SNIPPETS (concept mention) → plain prose; the row itself stays the
  interpolated \(SnippetsCopy.moveOutRow).
- Literal "30-day clock" and "in 30 days" → \(TrashWindow.days) (flagged promotion).
- The quoted tray badge "kept — no clock" keeps the UI's own dash (verbatim quote).
- All interpolations kept: \(TrayPath.archivedTab), \(TrayPath.leavingTab),
  \(SnippetsCopy.moveOutRow).

---

## Lesson: the tray & the Trash

### Final text

Every note keeps its own tray of what it set aside. Open it with the tray icon at the
top of the note: This Note's Tray, in the panel on the right. Or use the quiet ⌫ badge
in the context bar above the page, which opens the same panel. The badge counts deleted
blocks only and hides when there are none, which is exactly why the icon is always
there.

The tray offers two views at the top, each carrying its count.
\(TrayPath.archivedTab) holds what you set aside on purpose: kept, with no clock,
forever. \(TrayPath.leavingTab) holds everything of this note's that is counting down:
the blocks it deleted, the takes deleted on their own, and any original riding a
family's countdown. Under both sits one filter, \(RecoveryCopy.trayFilterAll) ·
\(RecoveryCopy.trayFilterBlocks) · \(RecoveryCopy.trayFilterTakes), so this note's
deleted takes are one click away with their number on the chip, never hidden under the
block cards; every card says which kind it is. One verb serves every row: Put back, and
a block returns to the place it stood in. (A block kept whole by a divide or a merge is
not leaving anything, so it is not here. It waits in the block it became, under
\(BlockHistoryPath.cameFromSection). The next lesson has it.)

The Library holds the other half, in two rooms. Archived is its own item in the
sidebar: calm and clockless, whole notes you set aside, each with Unarchive. The Trash
is behind the trash icon at the top of the Library, and it holds what is leaving:
notes, books and blocks, each row saying how many days it has left and which note it
came from. Filter it by kind, sort oldest first, and Put back works on any row. (A
deleted take never rows here: it waits in its own block's History, where its block and
its fan are there to make sense of it.)

Ending something early is deliberate, and it lives in exactly two kinds of place: the
Trash, and the \(TrayPath.leavingTab) view of a note's own tray. Delete Now ends one
row's remaining days; Empty Trash takes everything the Trash lists at once. Both ask
first. Delete Now asks every single time (there is no don't-ask to set), and Empty
Trash's question names the full count by kind before it takes anything, and says what
it leaves alone. Nowhere you write has such a door: not the page, not the block menu,
not a block's history. You have to go to where things are leaving to end anything for
good, which is why the Trash is worth visiting once before you need it.

Practice, and it is safe: go to the Library, right-click this very lesson ▸ Delete,
then open the Trash and Put back the row you find there. The lesson comes back into
this book, in this chapter, in its place. (And if you ever lose your nerve, Help ▸
Restore Tutorial… rebuilds the whole book.)

### Change log

- DELETED, LEAVING, WRITE caps → plain prose; em dashes out; sentence lengths brought
  down, content complete.
- All interpolations kept exactly (\(TrayPath.*\), \(RecoveryCopy.trayFilter*\),
  \(BlockHistoryPath.cameFromSection)).
- The practice act (delete this lesson, Put back from the Trash) kept word for word in
  substance.

---

## Lesson: what a block leaves behind

### Final text

A block remembers more than its text. Put your cursor in one and press history in the
bottom bar, the pair to commit, the same door on both bars. Everything this block has
been opens in the panel on the right: every take's saved moments, the takes it
archived, the takes it deleted, and where it came from.

This block has two takes. Put your cursor in the middle of it and press ⌘⇧D: the take
you are looking at splits across two new blocks, and the other take stays whole on the
first block. What became of the block you cut? It was kept: whole, off to one side, not
deleted.

Open history on either new block and its \(BlockHistoryPath.cameFromSection) region
shows the original itself ("From a divide on ‹date› — the original is preserved") with
Bring back beside it. Right-clicking the block ▸ See original from divide… and ⌘K land
in the same place. They wait there, with no clock, for as long as anything descended
from them is alive.

Merging keeps its blocks the same way, and says nothing at the time. Deliberately: a
message on every join would be noise. Merge two blocks (or select across them and
delete the seam) and the block you get lists both of the blocks it joined in
\(BlockHistoryPath.cameFromSection), each with its own Bring back, three of them if you
merged three. Nothing was deleted, so nothing is counting down; the next chapter has
you do it and find them.

Deleted takes wait in the same panel, under \(BlockPastCopy.deletedTakesHeader), each
with the days it has left. This paragraph carries a spare take for the experiment: open
its takes (⌘⇧T in Write, or the Takes tab, ⌘2, where every take card carries the same
menu) and on the spare card use \(TakeCardMenuCopy.menuGlyph) ▸
\(TakeCardMenuCopy.deleteTake). Then press history: the take is listed with Put back,
and it comes back with its label, its place in the fan and its commits intact. (A saved
lens pointing at a take you archived or deleted says so right in its column, with a
Restore button there.)

One honest thing about preserved originals, because it is the kind of promise that
should never surprise you: an original stays permanent only while something descended
from it is still alive. Delete the last of its descendants and the original moves,
visibly, into the note's tray, out of lineage and onto the family's
\(TrashWindow.days)-day clock, labelled "set aside by a divide or merge — kept until
its family goes". The delete that does it says so in its own receipt, while you are
standing there.

### Staged content

- The dividing block's second take: "The other take of the dividing block: I stay whole
  on the first block when you press ⌘⇧D, and the block we came from is kept preserved."
  (unchanged)
- The spare take: "the spare take: delete me from my own card's ⋯ menu (every take card
  has one, in Takes and in Write's takes panel), then put me back from the block's
  history panel." (em dash → colon; otherwise unchanged)

### Change log

- MERGING, BOTH, MOVES caps → plain prose; em dashes out of the guide's own sentences;
  the two quoted UI lines ("From a divide on ‹date› — the original is preserved";
  "set aside by a divide or merge — kept until its family goes") keep their own dashes
  (verbatim quotes of the panel's strings).
- "its savepoints intact" → "its commits intact" (R-13s-31).
- Literal "30-day clock" → \(TrashWindow.days) (flagged promotion).
- **Port hook:** `theDeletedSpareTakeWaitsInTheBlocksPast` finds the spare take by its
  prose, and the seeder stages takes by block index (index 1 and index 4, the seeder's
  own comment) — the landing moves the pins with the rephrased take text.
- All interpolations kept (\(BlockHistoryPath.cameFromSection),
  \(BlockPastCopy.deletedTakesHeader), \(TakeCardMenuCopy.menuGlyph),
  \(TakeCardMenuCopy.deleteTake)).
- Every act kept (the ⌘⇧D divide, the history visit, the spare-take delete and Put
  back).
