# VM-271 — the phone's editor core: the page is the truth (the design plan)

**Ticket: VM-271 (team VM, Umbrella, Urgent) · Project: Mobile — the catch-up & launch · Written at the Nov 22 sitting
(VX-1033) on branch `vx-1033-nov-22-sitting` · Status: DRAFT v1 — awaiting its cold review and her approval. Nothing
here is built.**

*How to read this file:* §0 is the kickoff a fresh session pastes. §1 is the short version. §2 is her words. §3–§11 are
the design, the part a cold reviewer attacks and an implementer builds from. §12–§13 are how it is proven, on the Mac
and on her phone. §14 is the units and runs. §15–§18 are what could stop it, what is still hers to decide, what gets
deleted and what canon owes. Plain names used here ("page", "break", "region", "the door") are defined in §4; the
proposed type names are suggestions for the implementer, not a contract.

---

## 0. Kickoff (for the first build session — do not start until §2's approval line is filled)

`/architect-phase vm-271` — run 1 of this plan ("Probe and core": units U1 and U2 in §14).

Read, in this order: this file whole; `notes/plans/vx-1033/design/phone-editor-proposal.html` (the page she chose
from); `notes/plans/vx-1033/phone-editor-audit.md` (what is wrong with today's editor and why);
`notes/plans/vx-1033/ios-text-input-research.md` (outside facts, each with its source);
`notes/plans/vx-1033/phone-editor-inventory.md` (what exists, with signatures); `notes/TEXTKIT2_NOTES.md` whole;
`notes/MobileSoul.md` §3 and §5; then the standing preflight. This is the editor seam: every ladder round is a Fable
cold review; the orchestrator never types editor code. The stage coordinator grants every hosted or simulator test
window; U2's headless suites need no stage. **The Mac's editor does not change in this effort** — a diff that touches
`App/Variorum/Variorum/Features/Editor/` or changes the behaviour of a `Shared/EditorBrain` rule the Mac calls is out
of scope and stops the run.

---

## 1. FOR A LATER READER

- **What this is.** A new core for the phone's Write editor. One `UITextView`, as today, so selection and editing
  across paragraphs stay native. The roles flip: while she types, the page is the truth and the library follows it.
- **Why.** Today's phone editor copies the Mac's design: approve each change first, keep a private map of which
  characters belong to which block, and redraw the page from the library when the map and the page disagree. An iPhone
  keyboard changes text without asking, keeps its own state about text it is still forming, and writes at stale
  positions when the page is redrawn underneath it. That produced lost letters and saved damage on her phone (VM-250)
  and a traced corruption window (VM-252). She chose this design over four others on 2026-11-22.
- **The five rules** (§3): the page describes itself · every change is accepted, then read · the library follows the
  page · the page changes from outside only through the keyboard's own door, or with the keyboard down · text the
  keyboard is still forming is not saved until it settles.
- **What does not change.** The Mac's editor. The schema. Sync. Every operation's meaning. Her rules for what Return,
  backspace and an edit across blocks do (the Mac's, ruled once for both platforms).
- **How it reaches her.** Behind a switch in Settings ▸ Diagnostics, with today's editor one flip away, first on
  notes she chooses. Today's editor is not patched meanwhile, at her word.
- **Where it stands.** See the status line at the top and §14's table.

---

## 2. Her words, and the approval line

On the problem (2026-11-22): "it seems like there is the whole problem that comes together from this wohle class of
issue about page redrawing beneath in progress keyboard text, and all of those issues. what's the root level solution?
we need to think deeply from a system perspective on how we can fix this and make the app performant and work
correctly. do we need a separate phone editor core because of all of this random extra stuff? … if we need a
workaround / different approach on the phone, i don't want the phone's compromises to affect the mac editor's
experience - i like where the mac is at and I'm wary of changing it to accomodate the phone."

On the bar: "I feel like a writing app where you can't select across multiple paragraphs is going to be difficult to
use / be happy with for people. … this is the soul of the mobile app and how we make it a great app, rather than a
mid one."

Her decision: "ok i read your recommendation, I think that the page is the truth is a good approach. make a full
design plan for that, then spawn one cold review of the plan that is adversarially focused on where it breaks, what
needs to be improved, handled, etc. that being said - i'm not that worried about the current editor being buggy, i
don't really think that just for me we need to fix the current editor if we're going to change the whole thing. it's
not a HUGE issue and doesn't come up that frequently, it's a HUGE issue for launch, but I don't think we need to build
fixes for it if we're going to change the whoel thing anyway. how can we test this on my phone? I want to get this
issue sorted and this plan done - that's my current top priority."

**Approval:** *(empty — her word on this plan after the cold review goes here, verbatim, with the date.)*

---

## 3. The five rules

Everything below follows from these. A build choice that breaks one is wrong even if it passes its tests.

1. **The page describes itself.** Which block a character belongs to can be worked out from the page alone, with no
   outside map. Each block's start is marked on the paragraph break in front of it. The editor's map of blocks is a
   cache of what the page says, and can be rebuilt from the page at any moment without asking the library.
2. **Every change is accepted, then read.** The editor never needs to know in advance what a change will be, who made
   it, or whether it asked. After any change to the page's characters it re-reads the paragraphs around the change and
   works out what the page now says. Being asked first is used for one thing only: declining a change the rules do not
   allow (§8.6). Correctness never depends on being asked.
3. **The library follows the page.** What is saved is what the page says. Blocks join, split, appear and disappear in
   the library because the page already shows it. The library is never used to overrule the page while she is typing.
4. **The page changes from outside only through the keyboard's own door, or with the keyboard down.** The editor never
   edits the text view's storage characters directly while the text view has the keyboard. A change it must make then
   goes through the text view's own insert and replace calls, on the next turn of the main loop, and never while text
   is being formed. Everything else waits until the keyboard is down, when the page may be rebuilt whole.
5. **Text still forming is not saved.** A region the keyboard is still composing in (a grey prediction, a
   composition, a Writing Tools session) is not written to the library until it settles. At a durability moment
   (leaving the note, backgrounding, a lock) the editor ends the composition first and then saves everything.

What the rules buy: no "the map and the page disagree" state exists (rule 1), so no repair-by-redraw exists; no input
road has to be listed (rule 2); nothing redraws under the keyboard (rules 3 and 4); a guess is never saved as her text
(rule 5).

---

## 4. Vocabulary

| Plain name | Meaning | Proposed type |
|---|---|---|
| The page | The text view's storage: one string, UTF-16 offsets | — |
| A break | A `"\n"` on the page that carries the block-start mark. Every other `"\n"` is content inside a block (I4) | `PageMark` (the attribute key and its value) |
| A region | The text between two breaks, or from the page's start to the first break, or from the last break to the end. One region is one block's text, or text that has no block yet | `PageRegion` |
| A reference | What a region is bound to: a minted block and the take being shown, a pending act that will mint one, or nothing yet (unminted) | `PageRef` |
| The map | The ordered list of regions with their offsets, references and flags. A cache of the page | `PageMap` |
| A reading | A region's text as last read while settled. The base for the next save and for a put-back | held in the map |
| Settled | Nothing is being formed in the region: no marked text, no Writing Tools session, no put-back owed | a flag on the region |
| The door | The text view's own text-input calls, `replace(_:withText:)` and `insertText(_:)`, which is how the keyboard itself edits | `PageDoor` |
| The writer | The one serial queue that turns what the page says into operations, in order | `PageWriter` |
| The reconciler | The pure rule that, given the map and one change, says what the page now says and what the library owes | `PageReconciler` (Core, headless) |
| The gate | The text view's "should this change happen" call. Policy only (§8.6) | — |

---

## 5. The page's shape

### 5.1 Breaks carry the marks
The page is what today's `EditorDocument.materializeCore` builds: the blocks' texts in order, joined by a single
`"\n"`. Today that separator carries no block attribute and belongs to neither neighbour, and every character of a
block carries `blockIDAttribute`. The new core changes only the attributes:

- **Each separator carries the mark**, a new attribute key (proposed `io.lduarte.variorum.blockStart`), whose value is
  the reference of the block that begins after it.
- **The first region has no character in front of it**, so its reference is held by the map's head. Nothing on the
  page can lose it.
- **Characters inside a block carry no identity attribute.** iOS never gives a newly typed character a custom
  attribute (measured, `notes/TEXTKIT2_NOTES.md` §3, VM-24), and system replacements drop custom keys from the
  characters they replace (research §8). An identity that rides every character would be wrong after every keystroke
  and would need the re-stamp today's editor does. A mark on one character per block is touched only when a block
  boundary is.
- **An empty block is two breaks in a row** (or the head followed at once by a break). Today's design needs the
  outside map for this case, because a zero-length range cannot carry an attribute; here the breaks around it say it.
- **A `"\n"` with no mark is content.** A block may hold several paragraphs; her rule that a newline inside a block is
  content (I4) is exactly "an unmarked newline".

This is a phone-only materialization. `EditorDocument.materializeCore`, `BlockRangeIndex` and the separator doctrine
stay as they are for the Mac.

### 5.2 Two witnesses for every break
A break is known two ways: the mark on its character, and the map's record of its offset. After every change both are
checked for the breaks next to the change:

- the character is there and marked: nothing to do;
- the character is there, untouched by the change, but its mark is gone (a system road rewrote attributes): the mark is
  put back from the map, an attribute-only write, and counted;
- the character was replaced or removed by the change: §6 decides what that means.

On idle, and when a note is left, the whole page's marks are walked and compared with the map. A difference with no
change to explain it rebuilds the map from the page and is counted and traced (§11). The map never overrules the page's
characters.

### 5.3 Regions without a block yet
New text may have no block for a moment: the first words in an empty note, a paragraph just opened by Return, the far
side of a divide that is still landing. Its region carries a pending or unminted reference. Its saves wait in the
writer until the act that mints its block returns the ids (§7.4). Text in such a region is never lost by this wait:
it is on the page, and every durability moment flushes the writer.

### 5.4 Regions she cannot edit
A locked take, a gap slot (a block whose text has not arrived by sync), and every region of a sealed note are
read-only. For a sealed, stood-down or deleted note the text view is not editable at all. For a single read-only
region the gate declines changes that touch it, and a change that reaches it anyway is put back (§6.4).

---

## 6. Reading a change (the reconciler)

A pure function in the core package, with no UIKit and no database: given the map and one change, it returns the new
map and a list of effects. It is total: it has an answer for every possible change, and it never refuses.

### 6.1 What it is told
- **The change:** the range that changed, in the page's new offsets, and the change in length. This comes from the
  storage's first notice (`willProcessEditing`), which carries the exact characters on every road measured so far; the
  second notice's range is sometimes stretched to the paragraph's end and is not used. One pass may hold several
  separate edits (iOS 26 selections can be several ranges); the reconciler treats the reported range as "something in
  here changed" and re-reads, so it does not need them apart.
- **What the page now holds there:** the characters of the changed range, and where the marks are inside it.
- **What is forming:** the marked-text range, if any; whether a Writing Tools session is open.
- **Whose it was** (§6.3): whether the gate was asked about exactly this change, and the caret or selection just
  before it.

### 6.2 What it does
1. **Old range.** From the new range and the length change it works out which old offsets were replaced.
2. **Breaks.** A break whose old offset was inside the old range was struck. A break after it shifts by the length
   change. Inside the new range it looks for marked characters: a struck break that is still there, marked, survives
   (for example a system undo that puts back exactly what was removed).
3. **No break lost** (nearly every keystroke): the regions touching the range are re-read. One that has text forming
   is flagged unsettled. Otherwise its text is compared with its reading, and a difference becomes a save effect.
4. **New unmarked newlines** are content, unless something claims them: the Return act (§8.1), bulk entry at an
   unminted end (§8.5). A claim stamps the mark and adds its effect.
5. **A break lost** is classified by §6.3 and becomes a join, a deletion, a compound (§8), or a put-back (§6.4).

Cost: the regions next to the change, plus shifting the offsets after it. Nothing reads the whole note. This keeps
P1.

### 6.3 Whose change was it
The page is the truth about text. But a lost break changes structure, and structure changes only when she means it
(I4). So a lost break is hers only when one of these holds:

- **It was asked and approved:** the gate was asked about exactly this change (same range, same replacement length,
  same page length), found that its range was her selection or the break next to her caret, and the shared rule
  allowed it (§8.6).
- **Its shape is unmistakably hers:** the change removed exactly the one break next to her caret and nothing else
  (a backspace at a block's start, or a forward delete at its end), or its old range is exactly the selection she had.
  This covers keyboards and roads that do not ask (a hardware keyboard, a held delete key).

Anything else that removes a break is the keyboard's doing, not hers.

### 6.4 The put-back
A break lost to a change that was not hers is repaired so that, for her, nothing happened:

1. **Re-mark.** If the replacement text has a `"\n"` at the same place the break stood, measured from the start or
   from the end of the replaced range, that newline is the break. Stamp it. An attribute-only write. No character
   changes, nothing to say.
2. **Put back.** Otherwise the regions on both sides are restored from their readings: on the next turn of the main
   loop, once nothing is forming, the damaged span is replaced through the door with the two readings and their break,
   and the mark is stamped. The message line says so once. The affected regions are unsettled, and nothing of them is
   saved, until the put-back lands.

The same put-back answers a change that reached a read-only region, and a structural keystroke the library then
refused (§8.7). It is the only place the new core discards something the keyboard did, and it is counted and traced
every time (§11). In ordinary writing the count is expected to be zero; the probe and the trial measure it.

### 6.5 What it guarantees (the invariants the tests hold it to)
- After every change, the page's regions and the map agree in number, order and offsets.
- Applying the returned effects to a model library makes the library's blocks, joined by breaks, equal to the page,
  except for regions flagged unsettled or pending.
- A region the change did not touch produces no effect.
- A break is never lost without a join, a deletion, a compound or a put-back in the effects.
- Rebuilding the map from the page's marks alone gives the same map.
- The same change read twice gives the same result; a change that changes nothing gives none.

---

## 7. Saving

### 7.1 One writer, in order
All of a note's writes go through one serial writer that owns the bindings from references to block and take ids. The
order of effects is the order the page changed. A save for a region is debounced as today (the existing half-second
pause) and always flushed ahead of any structural effect that names that region, so an operation that reads a block's
text from the library finds what the page said.

### 7.2 What a save is
`Operations.autosave(variantID, text:, charDelta:, expectedText:)` with `expectedText` set to the region's reading,
compared as the library stores text (`StoredText`). If the row no longer holds that text because another writer got
there first, the operation already rescues: her text keeps the row and the other text becomes a "conflict" take
(S5, VX-849). The new core adds nothing here and removes nothing.

### 7.3 Settling
A region with text forming is not saved (rule 5). The signal is the marked-text range: iOS delivers its grey inline
prediction as marked text (research §2), and compositions are marked. When the range clears, the region is read and
its save queued. Two cautions the research found:

- **Some input never marks** (Korean composes without it). For such input the forming text is saved as it changes.
  This is harmless: each save replaces the last, and only a commit freezes text, which §7.5 covers.
- **Writing Tools** rewrites the page over several steps. Saving is held from its "will begin" to its "did end".
  The starting policy is that Writing Tools is off in this text view (§10).

### 7.4 Pending regions
A structural effect (a mint, a divide, a join, a compound) is sent to the writer with a token; the region on the page
carries the token as its reference from the instant the page shows the result. The operation returns the new block
and take synchronously to the writer, which binds the token. Saves for a pending region wait behind its act. If the
act is refused (§8.7), the writer says so and the page is put right; no text is dropped.

### 7.5 Durability moments
Leaving the note, backgrounding, a lock, sealing the note, and every door that makes a commit (⌘S on a hardware
keyboard, the commit button, the leaving commit) do the same three things in order: end any composition
(`unmarkText()`, which accepts it), read every unsettled region, and flush the writer. Only then do they go on to
what today's code does next (the quiet commits through `closeAutoCommit(_:takes:)`, the sync round, the lock). So a
commit never freezes a guess, and the end of a note being dictated is never left unsaved (the audit's findings 3
and 4).

---

## 8. Structure from the page

Her rules for what these keys do are the Mac's, ruled once for both platforms and encoded in the shared rules
(`TypedReturn`, `EditorEditRoute` and its arms, `CrossBlockCompound`, `MergeJoinRule`, `BoundarySnapping`). The new
core changes how the phone arrives at the same results. Where the phone runs fewer arms than the Mac today (it has no
seam arms: a backspace at a block's start is refused with a sentence), this plan adopts the Mac's arms; that is her
standing ruling for wave 3 ("Return makes a new block and backspace joins blocks … as on the Mac", VM-137, NT-1), and
§17 lists it for her confirmation.

Two shapes cover every case:

- **Follow.** Where what the text view does by itself is already the ruled result, the editor lets it happen and makes
  the library agree.
- **Decline and re-issue.** Where the ruled result differs from what the text view would do, the gate declines the
  change and the editor makes the ruled change through the door on the next turn, after checking the page has not
  changed meanwhile. (React Native's text input moved to this shape in October 2026; research §3.)

### 8.1 Return
With the note's segmentation switch on, Return is a structural key (`TypedReturn.act`): at a block's end, an empty
block below; inside its text, a divide at the caret, where a caret inside a word divides at that word's start so the
whole word goes down; at its start, an empty block above; in an empty block, another below. With the switch off,
Return is a newline inside the block.

The phone already catches Return in the text view's `insertText` (the list-continuation door), which is the one place
the software keyboard, a hardware keyboard and a test all arrive. The new core keeps that single catch: it asks
`TypedReturn` for the act, moves the caret if the rule says so (the word's start), lets the newline be inserted by the
text view itself, and claims that newline as a break (§6.2 step 4) with a pending reference. The effect is the mint or
the divide. A fanned block divides keep-on-top, as ruled. A list line still continues its list after the newline, as
today. Nothing is redrawn: the only write is one attribute.

### 8.2 Backspace at a block's start, forward delete at its end
The text view deletes the break's character itself. The page then reads as one region, which is what a join looks
like. The effect is the shared rule's: the empty-block carve (`deleteBlock` with its "empty with nothing unshown"
precondition) or the seam merge, with the delete roads' own join. Where the rule refuses (the Mac's cases), the gate
declines before anything changes and the sentence is said; a join that arrives without asking and is refused is put
back (§8.7).

### 8.3 Typing, cutting or pasting over a selection that crosses blocks
The text view replaces the selection as any editor does: the first block's head, the new text, the last block's tail,
on one line. That is the Mac's compound result. The effect is the existing compound (whole blocks inside the selection
go to the tray, the edges are edited and joined, the takes it edits are insured with quiet commits, one undo entry),
run by the executor the phone already has. After it returns, the joined region's text on the page is compared with
what the compound produced; if they differ, the page wins and a save follows.

A selection whose ruled result is narrower than what the text view would do (the clamp: an edit that only brushes a
break) is declined and re-issued as the in-block edit.

### 8.4 The menu's acts
Divide, Merge with Previous, Merge with Next, Extract, Make Block, New Block Below, Delete Block, Archive Block.
Each computes its plan from the page and the shared planner as today, then:

- **changes the page through the door** if it needs a character (a new break's newline, a removed break, a removed
  block's text), or by one attribute if it does not (a divide at an existing newline is only a stamp);
- **queues its operation** with a token, like a keystroke's.

The landing no longer ends in a redraw from the library, so the keystroke fence around it (VM-2) has nothing to
protect: a key typed while the operation is in flight lands on a page that already shows the result, and its save
waits behind the operation in the writer.

If the probe shows the door is not safe at some moment (§15, K2), these acts lower the keyboard first, change the
page, and raise it again with the caret where the plan puts it.

### 8.5 The end of a note, and bulk entry
Her rules for when fresh text becomes blocks stay the shared planner's (`CrystallizationPlanner`, the note's
segmentation). What changes is that a paragraph becoming a block is one attribute: the newline that ended it is
stamped, and the mint is queued without registering undo, as crystallization does today. The idle mint and the
leaving mint become "flush the writer". A paste at an unminted end segments by the same planner; a paste inside a
block is content.

### 8.6 The gate, as policy only
The gate answers the text view's question for these reasons and no others:

1. the note is sealed, stood down or gone (today's three belts, unchanged);
2. the change touches a read-only region (§5.4);
3. the change would strike a break and is not hers by §6.3's first test, or the shared rule refuses it: declined, and
   said where the rule has a sentence;
4. the change is one of the decline-and-re-issue cases.

Otherwise it says yes and remembers what it was asked (range, replacement length, page length, selection), so the
reconciler can tell an asked change from an unasked one. It arms nothing and routes nothing. It uses the multi-range
form of the call (the single-range form is deprecated at iOS 27).

### 8.7 When the library refuses after the page has changed
A race can make an operation refuse a change the page already shows (another device sealed the note; the block changed
under the plan). The page is then put right so that it matches the library, with no text lost:

- a refused mint or divide: the pending break loses its mark and its newline becomes content of the block before it,
  which is then saved normally; the refusal is said;
- a refused join or compound: the regions are put back from their readings through the door (§6.4), and the refusal is
  said.

### 8.8 Undo
Two stacks that never interleave, as on the Mac (OverallModel §3). The structural undo door stays the road back from
a join, a divide, a compound or a delete. The text view's own undo (shake, three-finger swipe, ⌘Z) covers typing
inside blocks; it is cleared at every structural change, the Mac's rule, so it can never replay across a break that
has since moved. A structural undo changes the page through the door, or with the keyboard down, like any outside
change (§9).

---

## 9. Changing the page from outside

Three ways, and nothing else writes the page:

| Way | When | Used for |
|---|---|---|
| **An attribute-only write** | Any time, but never over text that is forming | Stamping or repairing a mark; the markdown look; the typed-face reset |
| **The door** | The text view has the keyboard; next turn of the main loop; nothing forming; the page unchanged since the plan was made | A structural act's character change; a put-back; list continuation and the formatting acts (as today) |
| **A whole rebuild** | The text view does not have the keyboard | Opening a note; applying everything that waited |

**Changes from the library** (a sync from another device, a take chosen in the sheet, a lens, a structural undo):
the delivered projection is compared with the page region by region.

- A region with unsaved typing is never overwritten. If the library's text for it has moved, her next save rescues
  the other text as a take (§7.2).
- The editor's own saves coming back change nothing.
- Everything else is a list of small changes (replace this region's text, add this region, remove that one). They
  wait while anything is forming. Whether they then go through the door at once or wait for the keyboard to go down is
  decided by the probe (§12.3, question 3); the plan's default until then is **wait for the keyboard to go down**,
  except a change she asked for on the block she is in (a take swap), which lowers the keyboard, changes the page and
  raises it again.

**The caret** is never set by raw offset after an outside change. It is kept by (region, offset in region), and when
the door is used above it the shift is applied to the selection explicitly.

**Showing another take** (a peek, a swap, a lens) rebinds the region to that take and replaces its text by one of the
ways above. The page stays the truth about text; the map says whose text it is. Typing during a peek saves into the
take being shown, exactly as the page says. *(To confirm against the inventory: what today's peek saves.)*

---

## 10. The text view's settings at the start

Each is a conservative starting point. The probe (§12.3) is what earns loosening one; each is listed for her in §17.

| Setting | Start | Why |
|---|---|---|
| Inline predictions (`inlinePredictionType`) | Off; the bar above the keyboard stays | The grey guess is marked text in the page. Rule 5 handles it, but what accepting and rejecting it write is undocumented. On after the probe shows it clean |
| Writing Tools (`writingToolsBehavior`) | Off | Rewrites the page in steps, may cross breaks, may add attributes. Her policy call (the audit's finding 8) |
| Text drag within the note | Off | A drag-move is a delete in one place and an insert in another; across a break it is a structural act with no ruled meaning |
| Image glyphs and attachments | Off; paste is plain text | Blocks hold text |
| Autocorrect, the prediction bar, dictation, swipe typing, text replacements, spelling, smart punctuation | On, as the system has them | Ordinary in-region changes; rule 2 does not care how they arrive |
| TextKit 2 | Required; the canary stays | TextKit 1 has an iOS 27 bug that hides text during proofreading, and loses multi-range selection |
| Find (`isFindInteractionEnabled`) | As today, until U5 | The system's find-and-replace changes the page through the door, which the new core reads like any change; adopting it is U5's question |

---

## 11. Checks that run in the shipped app

Her trust is the point, so the app checks itself and says what it finds. None of these reads the whole note on a
keystroke.

| Check | When | Cost | If it fails |
|---|---|---|---|
| The breaks next to a change are where the map says, and marked | Every change | The neighbours of the change | Repair the mark or rebuild the map from the page; count |
| The whole page's marks against the map | On idle; on leaving | One walk of the marks | Rebuild from the page; count; trace |
| The page against the library, region by region | On leaving a note, after the flush; on demand in Diagnostics; during the trial also a few seconds after typing stops | One read of the note, off the main thread | Count and trace with block ids and lengths, never words. During the trial the message line says a mismatch was found and where to look |
| A put-back happened | Every time | — | Count; trace; the message line, once |

The edit trace (`MobileEditTrace`) gains the new core's counters: changes read; breaks struck, kept, re-marked, put
back; joins, divides, mints and compounds by keystroke; saves held for forming text; outside changes waited and
applied; every check's failures. Copy still gives plain text with no words in it.

---

## 12. Proving it

### 12.1 On the Mac, with no phone and no simulator (U2)
The reconciler and the writer's ordering are pure and live where `swift test` reaches them, so they need no stage.

- **State-transition tests** for every case in §6 and §8: each structural keystroke at each position, each
  classification, each put-back, pending regions, refusals.
- **The random-change test.** A model page and a model library. Thousands of seeded runs of arbitrary changes: any
  range replaced with any text, with and without being asked, with breaks inside, at the page's ends, in empty
  regions, with text forming, several edits in one pass. After every step the invariants of §6.5 are asserted. A
  failing seed is kept as a named test. This is the test that stands in for "we cannot list what the keyboard does".
- **It has to be able to fail:** each invariant is shown red by a deliberately broken rule before it counts.

### 12.2 In a hosted text view and the simulator (U3 onward)
Real `UITextView`, driven every way: ask-then-insert (the keyboard's road), `replace(_:withText:)` and `insertText`
without asking, direct storage changes (the worst case), `setMarkedText` and `unmarkText`, a selection replaced
across breaks, Return and backspace at every position. After each, the page-against-library check must pass. One
simulator UI test types a scripted passage across several blocks with the real software keyboard and checks the
library.

The simulator's keyboard asks before every key and has no predictions or dictation (recorded at VM-24). So the hosted
tests prove the core is indifferent to how a change arrives; they cannot show what her keyboard does. That is the
phone's job.

### 12.3 The probe, on her phone, first (U1)
A throwaway screen in Settings ▸ Diagnostics ▸ "Keyboard probe": a plain text view with four short paragraphs and
marked breaks, none of the editor attached, and a log of everything that happens underneath. The log holds kinds,
positions, lengths and flags. It never holds her words, so it can be pasted into a session and kept in the record.

She follows a script of about a dozen steps (typing, autocorrect, the prediction bar, the grey prediction accepted and
rejected, dictation, the spelling menu, a text replacement, swipe typing, paste, a held delete across a break, shake
to undo, and typing while the probe changes another paragraph), pressing Copy at the end. The questions it answers:

1. **Do the marks survive?** After each road: is every break still marked; do new characters ever carry the mark; does
   any road replace a paragraph break with a fresh one.
2. **What is the grey prediction, exactly?** Is it marked text in the page; what do accepting and rejecting write; is
   the gate asked.
3. **Is the door safe, and when?** While she types, dictates, or has a prediction showing, the probe changes another
   paragraph three ways (a direct storage change, the door at once, the door on the next turn) and stamps an attribute
   on the paragraph she is in. For each: any lost or doubled letter, a correction applied at an old position, a killed
   dictation, a moved caret?
4. **Which roads ask first**, and does what they ask match what they do.
5. **Dictation:** is its forming text marked; is there a signal that it has ended.
6. **System undo:** what it replaces after a break was added or removed; whether it restores attributes.
7. **A held delete:** does it ask at each step; what arrives when it crosses a break.
8. **Is Writing Tools offered on her phone**, and what does a rewrite do to the page.
9. **Typing attributes:** what a new character inherits after a tap, next to a break.
10. **The long-note caret bug** (a tap after a fast scroll landing far away, FB15241823): does it show at her note
    lengths.

Its answers go into `notes/TEXTKIT2_NOTES.md` §3 and into this file under a new "The probe's answers" heading, and
they settle §10's starting settings, §9's default, and the kill criteria in §15.

### 12.4 The trial, on her phone (U3's gate and U5's gate)
See §13.

---

## 13. On her phone

**How it gets there.** The same app, installed in place over Wi-Fi with `devicectl` as on 2026-11-22
(`notes/plans/vm-44/plans/vm-45-install-runbook.md`; no cable was needed). Each build is made from a named commit
into its own DerivedData folder, and the stage coordinator grants the install.

**The switch.** Settings ▸ Diagnostics ▸ "New editor", stored on the device, not in the library:

- **Off** — today's editor everywhere (the default until her gate).
- **Chosen notes** — a note opens in the new editor only after she picks "Open in the new editor" in that note's ⋯
  menu. The choice is remembered per note on the device.
- **All notes.**

Both editors read and write the same library through the same operations, so a note is the same note in either, and
flipping back needs no conversion. One difference is expected and is hers by ruling: the new editor's Return makes
blocks, so a note written in it has more blocks than the old phone editor would have made, as on the Mac.

**The safety net during the trial.**
- The first time the new editor changes a take in a session, it first keeps a quiet commit of that take as it was
  (`insureTakes`, deduped). There is always a road back.
- §11's checks run, and during the trial a mismatch is said on the message line.
- Today's editor is one flip away.

**What she does.** First the probe (about ten minutes, once). Then, when U3's build arrives: the switch on "Chosen
notes", a scratch note, a short script (the recording's own scenario among its steps: type at the end of a block that
has a block below, wait for a prediction, keep typing; select across three paragraphs and type; backspace at the
start of a block; Return in the middle of a paragraph), then real writing in notes she chooses, for as long as she
wants before trusting it. Edit trace ▸ Copy gives the session's counts. A screen recording of anything odd is the
best evidence there is.

**Her gate** is passed when, over real writing: no lost letter, no jump, no page-against-library mismatch, no
put-back she did not cause, and selecting, typing over, Return and backspace across paragraphs feel right to her.
Feel is hers alone to judge.

---

## 14. Units and runs

Per the sizing guidance: one acceptance unit per implementer session, at most two phase-sized units per run, a unit
closes on evidence of its own kind. Cast for every run: Fable orchestrates and cold-reviews (the editor seam), Opus
implements, both at xhigh; a fresh implementer per unit, a fresh reviewer per round.

| Run | Unit | What is built | Evidence that closes it |
|---|---|---|---|
| **1 · Probe and core** | **U1 — the probe** | The Diagnostics probe screen and its log; a build on her phone | Her pasted log; "The probe's answers" written; §10, §9's default and §15 settled in her words where they are her calls |
| | **U2 — the core, headless** | `PageMap`, `PageReconciler`, the effect list, the writer's ordering model, in the core package | The state-transition suites and the random-change test green; each invariant shown red by a broken rule; no stage used |
| **2 · The page in her hand** | **U3 — typing** | The text view, the storage observer, the editor model, the writer on real operations; open, type, save, leave; Return, backspace and cross-block edits; the gate as policy; the put-back; §11's checks; the switch with "Chosen notes"; the base look | Hosted tests on every road of §12.2; the simulator typing test; then **her trial on scratch notes and chosen notes** |
| | **U4 — acts and outside changes** | The menu's structural acts through the door; the structural undo door; changes from the library; take swap | Hosted tests; a two-device session (the Mac edits a note open on the phone); her session |
| **3 · Everything moves over** | **U5 — the features** | The markdown look and typed-face reset, list continuation and Tab, the formatting bar, takes (peek, pan, sheet), lenses, badges and marks, find, the tray, jump to a block, timing marks, the trace | A simulator walk of a fixture note in both editors, screen by screen; her trial with the switch on "All notes" |
| | **U6 — her gate** | Nothing | §13's gate, in her words |
| **4 · Retirement** (with wave 3's Writing) | **U7** | The switch's default flips; the old editor and its tests are removed; wave 3's members are re-scoped onto the new core | The whole phone target and the Mac's source-reading suites green; canon deltas (§18) |

U1 and U2 do not depend on each other and may run in either order inside run 1; U1's phone session should not wait
for U2. Run 2 does not start until the probe's answers are in, because they decide U3's settings.

**This plan is larger than two units**, which the sizing guidance asks to be said to her plainly: it is four runs.
It is presented as one umbrella with its runs in order, not split silently.

**What each run touches** (for the in-flight table and the coordinator): run 1 adds a Diagnostics screen under the
phone's Shell/Settings and new files in the core package's Domain; runs 2 and 3 add new files under the phone's
`Features/Write/` and touch `MobileWriteView` and the features' call sites; none touches `Sources/VariorumCore/Sync/`,
custody code, the schema, or the Mac's editor. The badge-and-marks run (VM-17, VM-239, VM-179) works in the same
feature files as U5 and must not run beside it.

---

## 15. What would stop it

| | What we would see | Then |
|---|---|---|
| **K1 — marks do not survive** | The probe shows ordinary roads replacing paragraph breaks with fresh, unmarked ones often enough that re-marking and put-backs are routine | Rework §5: identity from the map's offsets with the page's newlines as the only witness. If that cannot be made safe either, the single text view is not viable and the choice returns to her |
| **K2 — the door is not safe while the keyboard is up** | The probe shows a change through the door disturbing the keyboard even on the next turn with nothing forming | The design stands; §8.4's acts and §9's changes lower the keyboard first. Ordinary typing, Return, backspace and cross-block edits use no programmatic character change and are unaffected |
| **K3 — the page itself goes wrong** | With no outside change at all, the trial shows a lost letter or a page-against-library mismatch | Trace it. If the cause is ours, fix it. If the text view misbehaves by itself on a plain page, only a custom text input (the proposal's option E) removes it, and the core built here goes under it |
| **K4 — it does not feel right** | Her judgment in the trial: carets, scroll, the keyboard dropping, selection | Fix what is fixable; what is not is hers to weigh against the alternatives |

---

## 16. Risks

1. **An unknown system road that damages a break in a way the put-back handles badly** (a visible flicker at the
   caret). Mitigation: the probe's road matrix; the count in the trace; the random-change test for the rule itself.
2. **Two editors in one app for several runs.** The features must work with both. Mitigation: U3 ships the new editor
   with a small feature set on chosen notes, so nothing of the old editor's is changed until U5; U5 moves features
   over behind a narrow interface, and the old editor's tests keep running until U7.
3. **The Mac's tests that read the phone's source** (133 files at VM-47's count) meeting new phone files.
   Mitigation: every run runs those suites at its first batch (the lesson of VM-64's gate).
4. **Readings are copies of her text in memory**, which the architecture rules warn against for view models.
   They are the editor's sanctioned exception today (the ledger) and are kept only for regions touched in the session.
5. **The put-back discards something the keyboard did.** It is the one lossy act. It is said, counted and traced, and
   it only ever discards a change that crossed a block boundary without being hers.
6. **A phone session is needed after every iOS update**, as for the Mac's editor (TEXTKIT2_NOTES §5). The probe screen
   stays in Diagnostics for that.
7. **The long-note caret bug in TextKit 2** is independent of this design and exists in today's editor too. The probe
   measures it.

---

## 17. Hers to decide

Each is built at the default and marked PROVISIONAL until she rules; none gates run 1.

1. **Backspace at a block's start joins, with the Mac's exact rules**, including the cases where the Mac refuses.
   Default: yes (her wave-3 ruling).
2. **Return makes a block**, including "a caret inside a word takes the whole word down". Default: yes (NT-1), behind
   the note's segmentation switch as on the Mac.
3. **The grey inline prediction** off at first, on after the probe shows it clean. Default: as written.
4. **Writing Tools** off in the editor. Default: off until she rules how it should behave.
5. **Shake to undo** covers typing inside blocks and is cleared at every structural change. Default: the Mac's rule.
6. **Dragging text within a note** off. Default: off.
7. **Changes from another device while the keyboard is up** wait until it goes down, unless the probe shows the door
   safe. Default: wait.
8. **The put-back's sentence** on the message line. Draft: "The keyboard changed two blocks at once — nothing was
   changed." Her wording.
9. **The trial's order:** scratch notes, then chosen notes, then all. Default: as written.

---

## 18. What is retired, and what canon owes

**Retired at U7, on the phone only:** the approve-first arming and binding, the fallback verdict, the desync repair,
the forced full render and the differential render under the keyboard, the keystroke fence, the per-character
re-stamp, the phone's use of `BlockRangeIndex` as the authority. The Mac keeps all of its own.

**Tickets this closes by replacement:** VM-250, VM-252, VM-226, VM-236, the class VX-68 watched. **Re-scoped:** wave
3's Writing (VM-137): VM-140 and VM-143 become "done by the core"; the rest are faces on it. **Unaffected:** VM-17,
VM-239 (badges and marks beside a block) stay their own run.

**Canon deltas owed at ship** (applied in place, the narrative in `notes/AppSpecRecord.md`): AppSpec §7's sentence
"The phone's Return model is its own" and the editor paragraphs of §4 and §12 where the phone now differs in
mechanism; `notes/SurfaceContracts.md`, The note (the phone passages); `notes/MobileSoul.md` §5 and a parity row;
`notes/TEXTKIT2_NOTES.md` §3 (the probe's findings) and §5 (the phone's row in the per-version matrix). No schema, no
sync marker, no operation's contract.
