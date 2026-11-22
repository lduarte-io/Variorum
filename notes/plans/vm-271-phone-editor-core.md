# VM-271 — the phone's editor core: the page is the truth (the design plan)

**Ticket: VM-271 (team VM, Umbrella, Urgent) · Project: Mobile — the catch-up & launch · Written at the Nov 22 sitting
(VX-1033) on branch `vx-1033-nov-22-sitting` · Status: DRAFT v2 — revised after its first cold review
(`notes/plans/vm-271-plan-cold-review-1.md`: three blockers and fifteen majors against v1, every one dispositioned in
§21). She agrees with it broadly and has asked for a second round: one general cold review and one sync-focused.
Nothing here is built.**

*How to read this file:* §0 is the kickoff a fresh session pastes. §1 is the short version. §2 is her words. §3–§13
are the design. §14–§16 are how it is proven, on the Mac and on her phone. §17 is the units and runs. §18–§22 are what
could stop it, the risks, what is hers to decide, the review's dispositions, and what is retired. Plain names used
here ("page", "break", "region", "her doors") are defined in §4; proposed type names are suggestions for the
implementer, not a contract.

**What changed from v1, in one paragraph.** v1 let the text view decide structure and made the library follow ("the
library follows the page"), with a put-back for anything that was not hers. The review showed that this binds text to
the wrong block and departs from the Mac's ruled results, because which paragraph break survives a native edit is not
which block her rules say survives, and because the rules read facts the page cannot carry (takes, comments, the
join's space, the divide's trim). v2 keeps accept-then-read for typing **inside** a block, where it survived every
attack, and replaces everything else: **a structural gesture is caught at the door she makes it through, the shared
rules decide the result, and the editor brings both the page and the library to that result.** The text view is never
left to decide structure.

---

## 0. Kickoff (for the first build session — do not start until §2's approval line is filled)

`/architect-phase vm-271` — the next unit of §17 not yet closed.

Read, in this order: this file whole; `notes/plans/vm-271-plan-cold-review-1.md` (its §3's table of Mac results and
its §5's UIKit assumptions are working references); `notes/plans/vx-1033/phone-editor-inventory.md` (what exists, with
signatures); `notes/plans/vx-1033/phone-editor-audit.md`; `notes/plans/vx-1033/ios-text-input-research.md`;
`notes/plans/vx-1033/design/phone-editor-proposal.html` (the page she chose from); `notes/TEXTKIT2_NOTES.md` whole;
`notes/MobileSoul.md` §2, §3 and §5; then the standing preflight. This is the editor seam: every ladder round is a
Fable cold review; the orchestrator never types editor code. The stage coordinator grants every hosted or simulator
test window and every install. **The Mac's editor does not change in this effort**: a diff that touches
`App/Variorum/Variorum/Features/Editor/`, or changes the behaviour of anything in `Shared/` or `Sources/` that the Mac
calls, is out of scope and stops the run. The two additive changes in §20.1 are the only shared-code changes this plan
foresees, and they need her word first.

---

## 1. FOR A LATER READER

- **What this is.** A new core for the phone's Write editor. One `UITextView`, as today, so selection and editing
  across paragraphs stay native.
- **Why.** Today's phone editor copies the Mac's design: approve each change first, keep a private map of which
  characters belong to which block, and redraw the page from the library when the map and the page disagree. An iPhone
  keyboard changes text without asking, keeps its own state about text it is still forming, and writes at stale
  positions when the page is redrawn underneath it. That produced lost letters and saved damage on her phone (VM-250)
  and a traced corruption window (VM-252). She chose this design over four others on 2026-11-22.
- **The six rules** (§3): the page describes itself · inside a block every change is accepted, then read · structure
  changes only through her doors, and her rules decide the result · the page changes from outside only through the
  text view's own calls or with the keyboard down · text still forming is never saved · a save never lands where she
  cannot see it.
- **What does not change.** The Mac's editor. The schema. Sync. What Return, backspace at a block's start and an edit
  across blocks do: the Mac's results, ruled once for both platforms.
- **How it reaches her.** Behind a cheap switch in Settings ▸ Diagnostics that only chooses which screen opens a note.
  No feature is made to work with both editors. The old editor is deleted in the run that moves the features over.
  Today's editor is not patched meanwhile, at her word, and mobile wave 2 waits for this effort, at her word.
- **Where it stands.** The status line at the top and §17's table.

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
fixes for it if we're going to change the whoel thing anyway."

On the switch: "ok I suppose a cheap switch for an early look is fine - I just want us to be strategic with the work,
but it makes sense to me to do a cheap try first. about the shape of the work - make plans for how we're going to do
this and I will follow them."

On the order: "i'll probably just wait and only run wave2 once this is done. I'd rather the core of the app be stable
before making more changes."

On v2 (2026-11-22): "ok - I agree with this plan broadly. I do agree that it needs a second cold review. It does make
sense that computing the block after isn't the right approach - not what the mac does and we need it to be
deterministic and follow a set of rules, not changing randomly with whatever non keyboard input showed up, or the
block system wouldn't make sense to people. I agree with running the probe in a new session - you can give me the
kickoff for that when it's time. saving checking it's still in this note - what's the exact issue here? what is still
in this note? the block? I think that makes sense - this is where we have to plan carefully sync wise, because we've
sidestepped a lot of issues with takes but we can't sidestep structural operations. spawn a cold review and a sync
focused cold review. backspace at block start joins with mac's exact rules - yes. return makes a block - yes, agreed.
not being able to type a newline within a block isn't an issue if you can press the newline button. also - will the
phone have a "newlines make blocks" setting to toggle like the mac? that would also ease a lot of the friction -
someone could just toggle that setting. i think that should be an option but it shouldn't be in settings, it should
live in the note."

**Approval:** *(empty — her word on this plan after its second round of reviews goes here, verbatim, with the date.)*

---

## 3. The six rules

A build choice that breaks one of these is wrong even if it passes its tests.

1. **The page describes itself.** Each block's start is marked on the paragraph break in front of it. The first
   block has no character in front of it, so its mark is held beside the page (the head) and is re-pointed like any
   other mark. Which block a character belongs to is read from the marks.
2. **Inside a block, every change is accepted, then read.** The editor does not need to know in advance what a
   change will be, who made it, or whether it asked. After any change to a region's characters it re-reads the
   region and saves what it says. This is the rule that makes autocorrect, predictions, dictation and every future
   keyboard road safe, and the review could not break it.
3. **Structure changes only through her doors, and her rules decide the result.** Joining, splitting, adding and
   removing blocks happen only when she makes a structural gesture: Return, backspace or delete at a block's edge,
   typing, cutting or pasting over a selection that crosses blocks, or a menu act. Each is caught where she makes it.
   The shared rules compute the result from the state before the gesture, exactly as on the Mac. The editor then
   brings the page and the library to that result. The text view is never left to decide which block survives.
4. **The page changes from outside only through the text view's own calls, or with the keyboard down.** The editor
   never edits the storage's characters directly while the text view has the keyboard. It checks again after every
   wait: a change planned before a wait is abandoned if the page, the keyboard or the text being formed has changed.
5. **Text still forming is never saved.** A grey prediction or a composition is cut out of what is saved. Nothing of
   it reaches the library until the keyboard commits it.
6. **A save never lands where she cannot see it.** Every save checks that its block is still in this note. A save the
   library will not take is rescued to where her words are on the page, and said. Nothing is held pending forever.

---

## 4. Vocabulary

| Plain name | Meaning | Proposed type |
|---|---|---|
| The page | The text view's storage: one string, UTF-16 offsets | — |
| A break | A `"\n"` on the page that carries the block-start mark. Every other `"\n"` is content inside a block (I4) | `PageMark` |
| The head | The first block's mark, held beside the page because no character precedes it | part of `PageMap` |
| A region | The text between two breaks, from the page's start to the first break, or from the last break to the end | `PageRegion` |
| A binding | What a region is bound to: a block and the take being shown, a token for an act still landing, or nothing yet (the open end) | `PageBinding` |
| The map | The ordered regions with offsets, bindings, flags and the two texts below. Kept in step by every change. It is also the `BlockRangeIndex` and the aligned slots the shared rules read | `PageMap` |
| The stored text | What the library holds for a region's take, as far as this editor knows. The compare-and-set base of the next save | `stored` |
| The settled text | The region's page text the last time nothing was forming in it. What a save sends | `settled` |
| Her doors | The places a structural gesture is caught: the text view's `insertText`, `deleteBackward`, `cut` and `paste`, and the menu's acts | `PageDoors` |
| The text view's own calls | `insertText(_:)` and `replace(_:withText:)`, which is how the keyboard itself edits | — |
| The gate | The text view's "should this change happen" question. Policy only (§9.1) | — |
| The saver | The note's one save queue: the session's existing coordinator, plus the editor's one task that runs acts in order | §11 |

(v1 called the two texts "a reading". That word is the codebase's name for a book, and the review showed one value
cannot do both jobs.)

---

## 5. The page's shape

### 5.1 Marks
The page is what today's `EditorDocument.materializeCore` builds: the blocks' texts in order, joined by a single
`"\n"`. The new core changes only the attributes, in a phone-only materialization:

- **Each separator carries the mark**, a new attribute key (proposed `io.lduarte.variorum.blockStart`), whose value
  is the binding of the region that begins after it.
- **The head** holds the first region's binding.
- **Characters inside a block carry no identity.** iOS never gives a typed character a custom attribute (measured,
  `notes/TEXTKIT2_NOTES.md` §3, VM-24) and system replacements drop custom keys (research §8), so an identity that
  rides every character is wrong after every keystroke. A mark on one character per block is touched only when a
  block boundary is.
- **An empty block is two breaks in a row**, or the head followed at once by a break.
- **A `"\n"` with no mark is content** (I4).

`EditorDocument.materializeCore`, `BlockRangeIndex` and the Mac's separator doctrine stay as they are.

### 5.2 Rules for marks (each is an invariant the tests hold)
- A mark is honoured only on a `"\n"`. A mark found on any other character is stripped.
- No two breaks carry the same binding. A second one that a change introduces (an undo restoring old attributes, a
  paste) is stripped and its newline is content.
- The map is the second witness. After every change the breaks next to it are checked. A break whose `"\n"` is still
  at the map's offset but has lost its mark is **re-marked from the map**, an attribute-only write, and counted.
- **The map is never rebuilt from the page.** (v1 said it could be; the review showed that a dropped mark would then
  silently join two blocks' text.) A mark the page has and the map does not is stripped. A break the map has whose
  character is gone is a struck break, handled by §8.
- The open end, text with no block yet, is allowed only as the last region (§10.5). The shared rules assume it.

### 5.3 What the map holds for each region
Its offset and length; its binding (block id and shown take id, or a token); the stored text and the settled text;
whether anything is forming in it; and the facts the shared rules read: how many live takes the block has, whether it
carries text she cannot see on the page (archived takes, comments), whether the shown take is locked, whether it is a
gap slot. For a block this editor minted, those facts are known without asking (one take, no comments).

**These facts are kept fresh while the keyboard is up.** A delivery from the library updates them at once. That is
metadata and writes nothing to the page. (v1 froze them, which made an accidental Return followed by backspace
refuse.)

The map serves the shared rules directly: it yields a `BlockRangeIndex` and the aligned
`[Queries.RenderedBlock]`-shaped slots they take, maintained incrementally so that a keystroke never builds them from
scratch (P1).

### 5.4 Regions she cannot edit
A locked take's region and a gap slot's region are read-only: the gate declines changes inside them, and a change
that reaches one anyway is undone (§8). A Return or a new-block act **next to** one is allowed, as on the Mac: it
mints a neighbour and touches nothing of theirs. For a sealed, stood-down or deleted note the editor keeps today's
face: the page shows a caret and the gate declines with the existing sentence.

---

## 6. Typing inside a region (rule 2)

After each pass of the storage that changed characters, the editor is told the range that changed and the change in
length by the storage's first notice (`willProcessEditing`; the second notice's range is sometimes stretched and is
not used). One pass may hold several edits; the union is enough, because the editor re-reads.

For a change that strikes no break:

1. The offsets of everything after the change shift by the length change.
2. The regions touching the range are re-read from the page.
3. **The forming range is cut out.** The marked-text range is read after the pass, not during the question, because
   it is not yet current then (research §1). The region's settled text is its page text minus the marked range.
4. If the settled text differs from what was last queued for saving, a save is queued **by value**: the text is
   captured now, not read again when the save fires.

Settling is also checked when no character changes: at `textViewDidChange`, at a selection change, and at the
dictation hooks. Accepting a prediction may commit text without a character edit.

Input that never marks its forming text (Korean) is saved as it changes. That is harmless: each save replaces the
last, and commits are covered by §11.5.

Cost: the touched regions and an offset shift. Nothing reads the whole note.

---

## 7. Her doors (rule 3)

Her structural gestures arrive at a small number of places, all of which a `UITextView` subclass can catch. The phone
already catches Return this way for list continuation, and it works on her phone today.

| Door | What arrives | Caught when |
|---|---|---|
| `insertText(_:)` | A typed character, Return, a paste from some keyboards | The text is `"\n"` (Return), or the selection crosses a break |
| `deleteBackward()` | Backspace | The caret is at a region's start, or the selection crosses a break |
| forward delete | A hardware keyboard's ⌦ | The caret is at a region's end, or the selection crosses a break. *Which call carries it is the probe's to find (§15.3)* |
| `cut(_:)`, `paste(_:)` | The edit menu and ⌘X, ⌘V | The selection crosses a break, or a paste lands at the open end (bulk entry) |
| The menu's acts | Divide, Merge, Extract, Make Block, New Block Below, Delete, Archive | Always |

Everything else that reaches these calls is ordinary typing and goes straight to the text view (`super`).

At a caught gesture the editor does four things, synchronously, inside the call the keyboard itself made:

1. **Ask the shared rule** what the gesture is, with the map's index and slots as they stand before the change:
   `TypedReturn.act` for Return, `EditorEditRoute.route` for a deletion or replacement, the planners for the menu.
   The new core passes its own arm list (proposed `pageArms`: the Mac's arms, with the phone's gap fence). It does not
   edit `phoneArms`, which the old editor still uses and a Mac suite pins.
2. **If the rule refuses**, nothing changes and the rule's sentence is said. This is where a backspace beside a fan,
   an archived take, a comment or a locked take is refused, from facts the map keeps fresh.
3. **Otherwise make the ruled page**, through the text view's own calls: the exact characters the rule's result has,
   with the marks §8's table gives. Because the edit is made inside the keyboard's own call, by the same calls the
   keyboard uses, the keyboard sees one ordinary edit.
4. **Queue the operation**, with a token on every region whose identity the operation may change (§8), and clear the
   text view's own undo (§12.3).

Because step 1 computes the result with the Mac's rules and step 3 writes exactly that result, the page equals the
Mac's page by construction, including the cases the review listed: the space a backspace-join puts between two
texts, the whitespace a divide trims at the cut, the cut's settle, a word carried down whole, a selection edge on a
boundary keeping the boundary, two ends that do not join when either sits at a paragraph break or either block has
takes.

**If a door proves unreliable on her phone** (the probe finds a gesture that does not arrive at its call), that
gesture falls back to the gate: the gate declines it, and the editor makes the ruled change through the text view's
own calls on the next turn of the main loop, after checking that the page has not changed and nothing is forming.
That is the shape React Native's text input adopted in October 2026 (research §3). Whether a declined key re-issued
this way upsets the keyboard is a probe question (§15.3, A8).

---

## 8. Identity: which region is which block after each act

The review's first blocker: v1 had no rule for this, and a wrong binding sends her next words silently into a block
that has left the note. This table is the rule. It is checked by the identity oracle (§14.2) against the real shared
rules and the real operations; **where this table and their code differ, the code wins and the table is corrected.**

Notation: `P` and `N` are the blocks before and after a seam. A token is a binding that waits for an operation's
result. "Re-point" changes which binding a break or the head carries; it is an attribute-only write.

### 8.1 Return (`TypedReturn.act`)
| The rule's answer | The page | Marks and tokens | The operation |
|---|---|---|---|
| `.content` (segmentation off, a selection, inside a list line, text in the open end) | The newline as typed. List continuation and the list exit run first, as on the Mac | None | None (the open end's own rule: §10.5) |
| `.emptyBlock(.below)` at block A | A `"\n"` inserted at the **end of A's region** (after any trailing whitespace) | The new `"\n"` carries token T. A keeps its mark | `newBlock(in:text:"",at:.after(A))` binds T |
| `.emptyBlock(.below, closingEmptyTail: true)` | Nothing inserted | The open end's break is re-pointed to token T | `newBlock` after the last block binds T |
| `.emptyBlock(.above)` at block A | A `"\n"` inserted at the **start of A's region** | A's old break (or the head) is re-pointed to token T; the new `"\n"` carries A | `newBlock(…, at:.before(A))` binds T |
| `.divideAtCaret` / `.divideAtWordStart`, A has one take | The whitespace at the cut is replaced by one `"\n"`, as `BoundarySnapping.seamTrimmedHalves` gives; at a run of newlines the run stays and its **last** newline is the break | The break carries token C. A keeps its mark | `divide(A, cut:)`; its result binds C. Both regions' stored texts become the halves the operation stored |
| The same, A has several takes | The same page | **Both** regions take tokens: A's break (or the head) is re-pointed to token B, the new break carries token C | Keep-on-top: `KeepOnTopDivide.compose` then `divideW` inside one undo entry. A is released; the result binds B and C, each showing the displayed take |

### 8.2 Backspace at a region's start, forward delete at its end (`EditorEditRoute`: the seam arms)
| The rule's answer | The page | Marks and tokens | The operation |
|---|---|---|---|
| Carve an empty block (`emptyBlockCarve` → carved, survivor) | One `"\n"` is removed: **the carved block's own break**. If the carved block is the first region, the survivor's break is removed and the head is re-pointed to the survivor | The survivor keeps its binding | `deleteBlock(carved, requiring: .emptyWithNothingUnshown(variantID:))` |
| Join two texted blocks, neither with takes or unshown text | N's break is replaced by the delete join (`MergeJoinRule.deleteKeystroke`: a space, or nothing when an edge is already whitespace or a side is empty) | P's break (or the head) is re-pointed to token M | `merge(P, N, joining: .deleteKeystroke)` binds M |
| Refuse (a fan, an archived take, a comment, a locked take, a gap) | Nothing | — | None; the sentence from `CrossBlockRefusal` |

### 8.3 A deletion or replacement whose selection crosses a break
| The rule's answer | The page | Marks and tokens | The operation |
|---|---|---|---|
| Delete whole blocks (`.deleteWholeBlocks`) | Each deleted block's text **and its own break** are removed. A deleted first region takes the following break with it and the head is re-pointed to the first survivor. If none survive the page is empty and the head is the open end | Survivors keep their bindings | `deleteBlock` for each, as the Mac's executor groups them |
| The clamp (`.editInBlock`) | The in-block edit only; the break stands | None | An ordinary save |
| The compound (`.editAcrossBlocks(plan)`), ends join | The span is replaced so the page reads the leading edge's new text followed at once by the trailing edge's new text. Covered blocks and their breaks are gone | The leading break (or the head) is re-pointed to token M | `CrossBlockCompound.apply` in one turn of the runner (it insures the takes, deletes the covered blocks, edits and merges). M is bound from its outcome |
| The compound, ends do not join (a cut at a paragraph break, or a fan on either end, read from the map) | The same, with one `"\n"` kept or inserted between the two edges | That `"\n"` carries the trailing block's binding. The leading edge keeps its own. If the first block is wholly covered and nothing was typed, it is deleted and the head (or its break) is re-pointed to the trailing block | The same call |
| Refuse, or refuse awaiting sync | Nothing | — | None; the sentence |

The phone's existing compound executor ends in a redraw from the library and is not used; the new core calls
`CrossBlockCompound.apply` itself.

### 8.4 The menu's acts
| Act | The page | Marks and tokens |
|---|---|---|
| Divide | As Return's divide, with the planner's cut | As §8.1 |
| Divide choosing takes, Merge choosing takes | The sheets lower the keyboard; the page is rebuilt when they close (§12) | — |
| Merge with Previous / Next | **No character changes**: every merge door uses the rendering join, so the `"\n"` stays as content | N's break loses its mark; P's break (or the head) is re-pointed to token M |
| Extract, Make Block | Breaks inserted or stamped at the span's edges, as the planner's plan gives | A token on each new region; the source keeps its mark where the operation keeps its identity |
| New Block Below | As `.emptyBlock(.below)` | As §8.1 |
| Delete Block, Archive Block | The block's text and its own break are removed; the head is re-pointed if it was first | Survivors keep their bindings |

### 8.5 The rule for tokens
A token goes on **every** region whose identity the operation might change, not only on new text: both halves of a
fanned divide, the survivor of a join, the joined span of a compound. A region with a token is not saved until the
operation's result binds it; its saves wait in order behind the operation. If the operation's outcome differs from
what the map expected (a race: another device added a take a moment ago, so a join is suppressed), the page is brought
to the outcome by inverting only the difference (§8.6), and it is said.

Doors that need a block's id (the takes button, the comments sheet, jump to a block, the ⋯ menu's block acts) are
unavailable on a region whose token is still unbound, for the moment the operation takes.

### 8.6 A struck break that did not come through her doors
Something removed a break without passing through §7: a keyboard proposal from a stale position, or a gesture
arriving by a call the doors do not catch.

1. **Whose was it?** It is hers only if its old range is exactly the selection she had, or it removed exactly the one
   break at her caret. Keyboard deletes always act at the text view's own selection, so this test does not admit a
   keyboard accident (the review tried and could not make one pass).
2. **If hers**, the shared rule is asked about the old range and the replacement, as if it had come through a door,
   and the page is brought from where the native edit left it to the ruled page, on the next turn, with §8's marks.
   The clamp's answer keeps the in-block part of her edit and puts the break back. A refusal undoes only the
   structure.
3. **If not hers**, or the rule refuses: **only the offending change is inverted.** The struck break is re-inserted
   at its position, tracked through any later edits, with its mark. Text typed since stays where it is. If a later
   edit has itself crossed that position, all the text stays in the surviving region and the line says so. Nothing is
   ever restored from saved text (v1 did that, and would have thrown away what she typed in the meantime).
4. The text view's own undo is cleared, so a shake cannot replay the damage.

Every such repair is counted and traced (§13). In ordinary writing the count is expected to be zero.

---

## 9. The gate, and what is said

### 9.1 The gate is policy only
It answers the text view's question for these reasons and no others:

1. the note is sealed, stood down or gone (today's three belts and sentences, unchanged);
2. the change falls inside a read-only region (§5.4), unless it is a Return or new-block act beside one;
3. the change would strike a break and is not shaped like hers (§8.6's test): declined, counted;
4. a gesture that has fallen back from its door (§7's last paragraph).

Otherwise it says yes. It arms nothing and routes nothing. It uses the multi-range form of the call (the single-range
form is deprecated at iOS 27) and treats a multi-range ask as one change over the union.

### 9.2 What the phone says
Her rule for the phone's message line stands: a line with Undo when something leaves the page, a line for a refusal,
nothing for ordinary acts. So a carved empty block and a block deleted by a selection get the removal line with Undo;
a refusal gets its sentence; a join and a Return say nothing. The Mac's receipts ("Blocks joined — ⌥⌘Z undoes it.")
are not copied. *(§20.7: hers to confirm.)*

---

## 10. More rules the page follows

### 10.1 Normalizing
Where an operation stores different text from what was typed (a divide trims the cut; a join adds a space), the page
is made to match **at the gesture**, inside the door, as §7 step 3 says. After every operation returns, each touched
region's stored text is set from the operation's result. So the next save's compare-and-set base is right and no
"conflict" take is minted by the editor's own act (the review's M2 and M3).

### 10.2 Return's in-block twin
With Return making a block, she needs a way to type a newline inside one. The phone has none today. The first build
that makes Return structural adds a "new line" key to the bar above the keyboard, and a hardware ⇧⏎ is read as the
same. Wave 3's capsule replaces the key later. A dictated "new line" does not arrive as a Return and is content.

### 10.3 The switch in the note
Her word (2026-11-22): the phone gets the Mac's "newlines make blocks" switch, and "it shouldn't be in settings, it
should live in the note." The Mac's switch is per note and writes the note's own segmentation, which syncs; "off" is
the note's segmentation set to one block. So a note switched off on the Mac is already Return-as-content in the new
core, and the phone needs only the face: a switch inside the note that writes the same value. It is built with the
structural gestures (U3b), which pulls VM-141 forward from wave 3. Where in the note it sits (the note's ⋯ sheet, the
bar above the keyboard, or both) is a design step for her at U3b's start.

### 10.4 Selections
A selection may be several ranges on iOS 26 and later. The doors treat a multi-range selection that crosses a break as
the rule treats its union.

### 10.5 The open end
New text at the end of a note has no block until it is minted. It is only ever the last region.

- **At a Return in it**, the shared planner (`CrystallizationPlanner`) says which completed paragraphs become
  blocks, with its trim. The page is normalized inside the door and the mints are queued, without registering undo,
  as today.
- **A paste there** is bulk entry: the paste door inserts the planner's pieces and stamps their breaks.
- **When she pauses**, the open end is minted on the same two-second idle clock today's editor uses, and at every
  durability moment (§11.5). The idle mint stores the text **exactly as it stands on the page**, with no trim, so
  nothing moves under her fingers. *(§20.3: hers to confirm.)*

---

## 11. Saving (rules 5 and 6)

### 11.1 One saver
The note's saves keep going through the session's existing `AutosaveCoordinator` for that note. Every flush road in
the app already goes there: sync's flush before a round, version saves, the copy family, note deletion, the leaving
commit, the lock's teardown, the takes sheet's card editor. A second writer would reopen the hole VX-683 closed.

Structural acts are run by **one task** owned by the editor, which for each queued act flushes **every** pending save
and then runs the operation on the session's runner. Swift gives no order across tasks, so everything else (the
debounce, the doors, deliveries, durability moments) only enqueues to that task. Every flush road also waits for acts
in flight. The liveness registry that today names the old editor's type learns to hold either editor.

### 11.2 What a save is
`Operations.autosave(variantID, text:, charDelta:, expectedText:)`, the text by value, `expectedText` the region's
stored text, compared as the library stores text. A landed save sets the stored text. If another writer changed the
row first, the operation already rescues the other text as a "conflict" take (S5, VX-849).

A delivery read while a save is in flight is a snapshot from before her words; the coordinator's existing
"unlanded" fence is honoured.

### 11.3 A save checks it is still in this note
Today `autosave` accepts a write into a take whose block has left the note (released by a merge on another device),
silently. And a save the library refuses (a remote seal, a locked take, a deleted block) is held pending forever, so
the words exist only on the page and are gone when she leaves. v1 inherited both.

The new core's saves carry the note's id, and the operation refuses when the take's block is not placed in that note.
This is one additive, optional parameter on `autosave` and on the coordinator's entry; without it everything behaves
as today, so the Mac is unchanged. **It is a change to an operation's contract and needs her word (§20.1).**

### 11.4 A save the library will not take is rescued
When a save is refused, or its block is gone from the note:

- **The block left the note** (merged, deleted or moved elsewhere): the region's text is kept as a new block at the
  region's place, the region is rebound to it, and the line says so.
- **The take was locked elsewhere**: the same, a new block beside it.
- **The note was sealed elsewhere**: nothing in the note can take text. The words stay on the page, typing stops,
  and the line says they are not saved and offers Copy. *(§20.2: the rescue's shape and words are hers.)*

Nothing stays pending without her knowing.

### 11.5 Durability moments
Leaving the note, backgrounding, a lock, sealing, and every door that makes a commit do the same things in order:
settle what is forming **by its kind**, mint the open end, flush the saver, wait for acts in flight. Only then do they
go on to what today's code does next.

| What is forming | At a durability moment |
|---|---|
| A grey inline prediction | Its marked suffix is discarded. It was never hers |
| Dictation | Accepted |
| A composition (Japanese, Chinese) | Accepted. *(§20.5: hers to confirm.)* |

v1 called `unmarkText()` for all three, which would have frozen a prediction's guess into a commit. Telling the kinds
apart, and what each call really does, are probe questions (§15.3).

### 11.6 What a kill can lose, stated plainly
If iOS ends the app without warning: up to the half-second debounce in an ordinary region; whatever was typed in a
region whose operation had not yet returned (measured in milliseconds on an ordinary note, longer on a very long one:
§14.5 measures it); the open end since the last idle mint (at most two seconds of typing). v1's "never lost by this
wait" was too strong.

---

## 12. Changing the page from outside (rule 4)

### 12.1 Three ways, and nothing else writes the page
| Way | When | Used for |
|---|---|---|
| An attribute-only write | Any time except over text that is forming | Marks; the markdown look; the typed-face reset; decor reservations |
| The text view's own calls | The text view has the keyboard. Inside her door's call, or on the next turn with nothing forming and the page unchanged since the plan | Her gestures; §8.6's repairs; changes from the library to regions she is not in |
| A whole rebuild | The text view does not have the keyboard | Opening a note; closing a sheet |

### 12.2 Changes from the library
The delivered projection is compared with the map, by block ids in order and by stored texts, not by reading the page.

- **Facts** (takes, comments, locks, gaps) update the map at once (§5.3).
- **A region with unsaved typing is never overwritten.** If the library's text for it has moved, her next save
  rescues the other text as a take.
- **Text changes to other regions, and structural changes** (a block added, removed, merged or moved on another
  device; a structural undo or redo she asked for) are applied without waiting for the keyboard to go down, through
  the text view's own calls, with nothing forming. If the change touches the region her caret is in, the keyboard is
  lowered, the page rebuilt, and the keyboard raised with the caret where it belongs. (v1 made all of these wait for
  the keyboard, which the review showed would let a whole typing session's saves land in a block that had left the
  note.)
- If the probe shows the text view's own calls are not safe while she is typing elsewhere (§18, K2), structural
  changes fall back to lower-rebuild-raise, and plain text changes to other regions wait.

**The caret** is kept by (region, offset in region), never by raw offset.

### 12.3 Undo
Two stacks that never interleave, as on the Mac. The structural undo door is the road back from a join, a divide, a
compound or a delete; its result reaches the page by §12.2. The text view's own undo covers typing inside regions and
is cleared after every structural change, every repair and every change made through the text view's own calls. It
is the responder chain's shared manager, so the clearing is scoped to this text view's actions.

### 12.4 Showing another take
A peek, a swap or a lens rebinds the region to that take and replaces its text. The map says whose text it is, and
typing during a peek saves into the take being shown, as today. A shown take that is locked makes the region
read-only. A divide in such a region passes the displayed take to the operation.

A swipe-peek is her native takes gesture and happens with the keyboard up. Doing it by lowering and raising the
keyboard would be a visible bounce on every peek, which is a cost to feel. The probe measures a peek done both ways
(§15.3), and "the keyboard never bounces on a peek" is part of her gate.

---

## 13. Settings at the start, and the checks that run in the shipped app

### 13.1 The text view's settings
| Setting | Start | Why |
|---|---|---|
| Inline predictions (`inlinePredictionType`) | Off; the bar above the keyboard stays | The grey guess is marked text in the page. Rule 5 handles it, but what accepting and rejecting write is undocumented. On after the probe shows it clean |
| Writing Tools (`writingToolsBehavior`) and iOS 27's automatic proofreading | Off, if the setting silences both (a probe question) | They rewrite the page in steps and may cross breaks. Saving is held across a session if one can still start |
| Text drag within the note | Off | A drag-move across a break is a structural act with no ruled meaning |
| Image glyphs and attachments | Off; paste is plain text | Blocks hold text |
| Autocorrect, the prediction bar, dictation, swipe typing, text replacements, spelling, smart punctuation | On | Ordinary in-region changes; rule 2 does not care how they arrive |
| TextKit 2 | Required; the canary stays | TextKit 1 has an iOS 27 bug that hides text during proofreading |

### 13.2 The checks
| Check | When | If it fails |
|---|---|---|
| The breaks next to a change are where the map says, marked, unique | Every change | Re-mark from the map, or strip the stray; count |
| **The page against the note's projection, in order** | On leaving a note after the flush; on demand in Diagnostics; during the trial also a few seconds after typing stops | Count and trace with block ids and lengths, never words. During the trial the line says a mismatch was found |
| A repair (§8.6) or a rescue (§11.4) happened | Every time | Count; trace; the line |

The page-against-projection check compares the sequence of block ids and their texts from `Queries.takesProjection`
with the map's bindings and the page's regions, with shown takes mapped. It leaves out regions with a token, text
that is forming, and the open end. Because the page is normalized at the gesture (§10.1) it expects no differences;
the one deliberate difference, the idle mint's untrimmed text, is not one, because that text is what was stored.
(v1's check compared each region with its own take, which a wrong binding passes.)

The edit trace gains the new core's counters. Copy still gives plain text with no words in it.

---

## 14. Proving it on the Mac

### 14.1 Where the code lives, and what that costs
The shared rules (`TypedReturn`, `EditorEditRoute`, `CrossBlockCompound`, the planners, `BlockRangeIndex`) are
compiled into the two apps, not into the core package, and their tests run in an app target under a stage claim. The
new core depends on them. So:

- **The geometry** (the map, the offset shift, marks' rules, the forming range, §8.6's tracking of a struck break)
  is pure, takes plain values, and lives in the core package's Domain, where `swift test` reaches it with no stage.
- **The composition** (the doors, the identity table, the saver's ordering) lives with the phone and is tested in
  the phone's test target, under stage claims. With wave 2 waiting, the stage is not contended.

Moving the shared rules into a package would let everything run headless, but it touches files the Mac compiles and
is not proposed here.

### 14.2 The identity oracle (U2)
The test that v1 lacked. For each step it runs the **real** shared rule and the **real** operations on an in-memory
library, from the same starting state as the editor's model, and asserts that afterwards **the sequence of block ids
with their texts in the library equals the editor's bindings with the page's regions.** A text-only comparison passes
every wrong binding; this one does not. Every row of §8 and every row of the review's table of Mac results (its §3) is
a named case.

### 14.3 The random-change test (U2)
Seeded runs of arbitrary changes against the real operations: typing, any range replaced with any text, her gestures
at every position, changes that strike breaks without being hers, text forming, several edits in one pass. Interleaved
with an **adversary** that changes the library as another device would (text, structure, locks, seals, deletes), with
refusals, and with **kill points**. After every step: the identity assertion; no text older than the debounce lost at
a kill; every refusal ends in a rescue or a sentence. A failing seed is kept as a named test. Each invariant is shown
red by a deliberately broken rule before it counts.

### 14.4 Order (U2 and U3a)
A model of the saver with injected delays (a slow runner, a debounce firing in the middle of an act, a flush road
arriving mid-act) asserts that saves and acts reach the library in the order the page changed.

### 14.5 Her performance bar (every unit)
MobileSoul §2's 100,000-word spot-check is part of every unit's evidence: reconciler microbenchmarks at 20,000 blocks
in U2 (the shape of `EditorSeamCostTests`); typing latency, scroll, open time and memory on the long fixture in U3a
onward; `MobileHerPathsPerfTests` as its own leg; and the time an operation takes to return on the long fixture, which
is §11.6's exposure.

### 14.6 Hosted and simulator tests (U3a onward)
A real `UITextView`, driven every way: ask-then-insert (the keyboard's road), the text view's own calls without
asking, direct storage changes (the worst case), `setMarkedText` and `unmarkText`, every door at every position. Each
test says which configuration it runs in, because the simulator's keyboard asks before every key and has no
predictions or dictation, and a connected hardware keyboard changes which calls are asked. The Mac's suites that read
the phone's source run at every run's first batch.

---

## 15. Proving it on her phone

### 15.1 Installs
The same app, installed in place over Wi-Fi with `devicectl` as on 2026-11-22
(`notes/plans/vm-44/plans/vm-45-install-runbook.md`). The stage coordinator grants each install. Before each one she
is asked two things, as the runbook asks: whether to take the safety copy, and the build's version label, which she
names.

### 15.2 The switch
Settings ▸ Diagnostics ▸ "New editor", stored on the device: **Off** (today's editor, the default until her gate) ·
**Chosen notes** (a note opens in the new editor after she picks "Open in the new editor" in its ⋯ menu) · **All
notes**. It only chooses which screen opens a note. Both editors read and write the same library through the same
operations.

### 15.3 The probe (U1)
A throwaway screen in Settings ▸ Diagnostics ▸ "Keyboard probe". Two pages: four short paragraphs with marked breaks,
and a long fixture of 50,000 words or more. The probe's text is a fixture and scripted input, not her notes, so it
logs **characters** as well as positions: that is the only way to tell a prediction from a composition. Before and
after every pass it snapshots the whole page and logs the true difference beside what the storage reported.

A second mode attaches the real editor's attribute writers (the markdown look, the typed-face reset, the paragraph
reservations that run on every layout).

She follows a script and presses Copy. What it settles:

| # | Question | Decides |
|---|---|---|
| 1 | Do marks survive every road? Does a character typed right after a break, or a `"\n"` typed there, ever inherit the mark? | §5 (K1) |
| 2 | Does the storage's first notice match the true change on every device road? | §6 |
| 3 | When is the marked range current: at the question, at each notice, at `textViewDidChange`, on the next turn? | §6 step 3 |
| 4 | The grey prediction: is it marked text; what do showing, accepting and rejecting write | §13.1 |
| 5 | What `unmarkText()` does with a prediction showing, while dictating, and mid-composition. Dictate, background, kill, reopen | §11.5 |
| 6 | **Her doors:** does every Return (software, hardware) reach `insertText`, with any autocorrection already applied? Does backspace reach `deleteBackward`? Which call carries forward delete, a held delete and a word delete, and with what ranges? | §7 |
| 7 | An edit made inside a door's call through the text view's own calls: are the bytes exact (no smart spacing), is the selection where it was put, does the keyboard carry on correctly when she types fast after it | §7 (K2) |
| 8 | A key **declined** at the gate and re-issued on the next turn: any lost following key, re-applied correction, or shift glitch (the review's A8) | §7's fallback |
| 9 | A change through the text view's own calls in **another** paragraph while she types, dictates or has a prediction showing; and a direct storage change, for contrast | §12.2 |
| 10 | Attribute-only writes during composition, dictation and predictions, including the real editor's writers | §12.1 |
| 11 | A peek done through the text view's own calls, and done by lowering and raising the keyboard: time and feel | §12.4 |
| 12 | Shake to undo after a door's edit, after a repair, after a break was added or removed | §12.3 |
| 13 | What a triple tap and the menu's Select select: is the trailing `"\n"` included | §8.3 |
| 14 | Copy across a break and paste elsewhere in the note: do marks come along | §5.2 |
| 15 | Is Writing Tools offered; does switching it off silence iOS 27's proofreading; what does accepting an underline write | §13.1 |
| 16 | On the long page: a tap after a fast scroll (FB15241823); typing latency | §14.5 |
| 17 | VoiceOver's text-editing rotor: which calls its edits arrive by | §7 |

Its answers go into `notes/TEXTKIT2_NOTES.md` §3 and into this file under a new "The probe's answers" heading. The
probe screen stays in Diagnostics afterwards: it is the tool for the session owed after every iOS update.

### 15.4 The trial builds
Each build of the new editor carries a **scripted self-test** in a scratch note: she performs a fixed sequence
(Return between words, Return in a block with takes, backspace at a seam, a paragraph deleted with its newline, select
all and retype, typing over a selection that starts at a paragraph's start), and the app compares the library's
resulting blocks with the Mac's expected result and shows pass or fail for each step. Then real writing, in notes she
chooses, for as long as she wants before trusting it. The trial also includes the durability steps: type the last
paragraph and kill the app; dictate, background, kill, reopen.

### 15.5 The safety net
- The first time the new editor changes a take in a session it keeps a quiet commit of that take as it was
  (`insureTakes`, deduped).
- §13.2's checks run, and a mismatch is said.
- Today's editor is one flip away.

### 15.6 Her gate
Passed when, over real writing: no lost letter; no jump; no page-against-projection mismatch; no repair or rescue she
did not cause; the self-test all green; the keyboard never bounces on a peek; and selecting, typing over, Return and
backspace across paragraphs feel right to her. Feel is hers alone to judge.

---

## 16. What her phone keeps meanwhile

Stated plainly, as the review asked. Until the new editor is her editor, her phone keeps today's: the traced window
in which a key typed after a refused edit can save wrong text (VM-252), dictation's guesses saved into a block and
possibly into a commit, and the open end unsaved if the app dies mid-dictation. That is her ruling: "it's not a HUGE
issue and doesn't come up that frequently, it's a HUGE issue for launch". VM-250 and VM-252 stay open as launch gates
and close when the old editor is deleted.

---

## 17. Units and runs

One acceptance unit per implementer session, at most two units per run, each closed on evidence of its own kind.
Cast for every run: Fable orchestrates and cold-reviews (the editor seam), Opus implements; a fresh implementer per
unit, a fresh reviewer per round. Every unit's evidence includes §14.5's performance leg and the Mac's
source-reading suites.

| Run | Unit | What is built | Evidence that closes it |
|---|---|---|---|
| **1 · Probe and core** | **U1 — the probe** | §15.3's screen, both pages, both modes, the log | Her pasted log; "The probe's answers" written; the settings of §13.1, the fallbacks of §7 and §12.2, and §18 settled; her calls in §20 that depend on it put to her |
| | **U2 — the core** | The map and its rules in the core package; the identity table as code; the saver's order model; `pageArms` | §14.2's identity oracle over every row of §8 and of the review's table; §14.3's random-change test with the adversary and kill points; §14.4; microbenchmarks at 20,000 blocks |
| **2 · The page in her hand** | **U3a — typing** | The text view, the storage observer, the editor model, saving through the session's coordinator with the placement check and the rescue, every durability road, the open end's mint, the checks, the switch with "Chosen notes", the base look. **Return is content and a seam declines, as on today's phone** | Hosted tests on every road; the order model against the real coordinator; the simulator typing test; **her trial on scratch and chosen notes**, with the durability steps |
| | **U3b — her doors** | Return, backspace and forward delete at a seam, edits across blocks, the "new line" key, the switch in the note (§10.3, VM-141), the gate as policy, §8.6's repairs, the self-test | The identity oracle's cases driven through a hosted text view; **her self-test green on her phone**; her feel |
| **3 · Acts and the first features** | **U4 — the menu and the library** | The menu's structural acts; the structural undo door; changes from the library by §12.2; take swap and peek | Hosted tests; a two-device session in which the Mac makes **structural** changes to a note open on the phone with its keyboard up; her session |
| | **U5a — the look and the tools** | The markdown look and typed-face reset, list continuation and Tab, the formatting bar, find, the tray, jump to a block, timing marks, the trace | A simulator walk of a fixture note in both editors, screen by screen |
| **4 · Everything moves, and the old editor goes** | **U5b — takes, lenses, badges and marks** | The takes sheet and pan, lenses, the badge, pill, callout and comment marks, placed for the new core (this absorbs VM-17, VM-239 and VM-179) | The walk; her trial with the switch on "All notes" |
| | **U6 — her gate, then retirement** | After §15.6 in her words: the old editor, its tests and the switch are deleted; wave 3's Writing members are re-scoped | The whole phone target and the Mac's source-reading suites green; canon deltas (§22) |

**Decisions that must be settled before run 2 starts** (the review's M15): her answers to §20.1 (the save's placement
check), §20.2 (the rescue), §20.3 (the idle mint), §20.4 and §20.6 (backspace joins; Return makes a block), and the
probe's answers. U2 does not need them.

**This is four runs and eight units**, which the sizing guidance asks to be said plainly. It is one umbrella with
its runs in order.

**What each run touches:** run 1 adds a Diagnostics screen and new files in the core package's Domain; run 2 adds
new files under the phone's `Features/Write/`, a branch in `MobileWriteView`, and (with her word) the two additive
parameters of §20.1 in `Sources/VariorumCore/Operations` and `Shared/AutosaveCoordinator.swift`; runs 3 and 4 move the
phone's features. None touches `Sources/VariorumCore/Sync/`, custody code, the schema, or the Mac's editor. The lock
umbrella (VM-103, wave 2) later rewrites the leaving moment this core plugs into; it starts after this effort.

---

## 18. What would stop it

| | What we would see | Then |
|---|---|---|
| **K1 — marks do not survive** | The probe shows ordinary roads replacing paragraph breaks with fresh, unmarked ones, or typed characters inheriting marks, often enough that re-marking is routine | Rework §5 so the map's offsets are the only identity and the page's newlines only a witness. If that cannot be made safe, the single text view is not viable and the choice returns to her |
| **K2 — her doors cannot edit safely** | The probe shows an edit made inside a door's call disturbing the keyboard (a lost following key, a correction applied at an old position), **and** the decline-and-re-issue fallback doing the same | The single text view cannot produce the Mac's results for Return and backspace without upsetting the keyboard. The choice returns to her: a custom text input (the proposal's option E) under this core, or results that differ from the Mac's |
| **K3 — the page goes wrong by itself** | With no outside change, the trial shows a lost letter or a mismatch | Trace it. If the text view misbehaves on a plain page, only a custom text input removes it |
| **K4 — it does not feel right** | Her judgment: carets, scroll, a keyboard bounce on a peek, selection | Fix what is fixable; the rest is hers to weigh |

K2 is the question v1 wrongly said the frequent keystrokes avoided. It is the first thing the probe answers, and it
decides the shape of run 2.

---

## 19. Risks

1. **The doors are the design's hinge** (K2). Mitigation: they are the first probe questions, and the phone already
   ships one (Return, for lists).
2. **The identity table is wrong somewhere.** Mitigation: the oracle against the real rules and operations, every row
   a named case; the self-test on her phone.
3. **Two shared-code changes** (§20.1) reach files the Mac compiles. Mitigation: both are optional parameters whose
   absence is today's behaviour; the Mac's suites run.
4. **Two editors in one app for three runs.** Mitigation: the switch only chooses a screen; no feature is made to
   work with both; the old editor's files are not edited until U6 deletes them.
5. **Copies of her text in memory** (the stored and settled texts), which the architecture rules warn against for view
   models. They are the editor's sanctioned exception today (the ledger), kept for regions touched in the session.
6. **A phone session is owed after every iOS update**, as for the Mac's editor. The probe screen stays for it.
7. **The long-note caret bug in TextKit 2** (FB15241823) is independent of this design and exists today. The probe
   measures it.
8. **Runner contention.** The saver shares the session's one runner with every surface; a long turn elsewhere
   stretches the moment a token stays unbound. Measured in §14.5.

---

## 20. Hers to decide

Each has a default the build follows and marks PROVISIONAL. Items 1–4 and 6 must be answered before run 2.

1. **A save checks it is still in this note** (§11.3) — *she leans yes ("I think that makes sense - this is where we
   have to plan carefully sync wise"), pending the sync-focused review she asked for:* an optional parameter on `Operations.autosave`, and on the
   shared coordinator's entry, that refuses a write into a block no longer placed in the note. It is additive and the
   Mac is unchanged without it, but it is a change to an operation's contract, which is hers alone. Default: **yes**.
   Without it, a block merged on the Mac while she types on the phone silently takes her words into lineage; the
   alternative is a check a moment before the write, which leaves a millisecond's gap.
2. **The rescue** (§11.4): the shape (a new block at the place; for a sealed note, words kept on the page with Copy)
   and its sentences. Drafts: "This paragraph changed on another device — your words were kept as a new block." ·
   "This note was sealed on another device — these words are not saved. Copy them before leaving."
3. **The idle mint stores the text as it stands**, untrimmed, while a Return trims as the Mac does (§10.5). Default:
   as written. The alternative is trimming under her fingers when she pauses.
4. **Backspace at a block's start joins, with the Mac's exact rules**, including its refusals. **RULED 2026-11-22:**
   "backspace at block start joins with mac's exact rules - yes."
5. **A composition is accepted at a durability moment**; a prediction's guess is discarded (§11.5). Default: as
   written.
6. **Return makes a block**, including "a caret inside a word takes the whole word down", with a "new line" key on
   the bar. **RULED 2026-11-22:** "return makes a block - yes, agreed. not being able to type a newline within a
   block isn't an issue if you can press the newline button." And the per-note switch (§10.3) is hers too, living in
   the note; where in the note is a design step at U3b.
7. **What the phone says** for a carve, a join and a Return (§9.2). Default: her message-line rule (removals and
   refusals only), not the Mac's receipts.
8. **The grey inline prediction** off at first. **Writing Tools and proofreading** off. **Dragging text within a
   note** off. Defaults: as written, each revisited after the probe.
9. **Shake to undo** covers typing inside regions and is cleared at every structural change. Default: the Mac's rule.
10. **The repair's sentence** (§8.6). Draft: "The keyboard changed two blocks at once — the break was put back."
11. **The trial's order:** scratch notes, then chosen notes, then all. And the safety copy and version label at each
    install, asked each time.
12. **A second cold review of this v2.** The first found blockers, which by her ladder rule earns another round. She
    asked for one review; a second is recommended and waits for her word.

---

## 21. The first cold review, dispositioned

`notes/plans/vm-271-plan-cold-review-1.md` (Opus, adversarial, 2026-11-22). The orchestrator read it whole and
spot-checked its load-bearing claims in the code (a save into a block with no placement passes `editableVariant`; a
refused save stays pending; `phoneArms` is pinned by a Mac suite).

| Finding | Disposition |
|---|---|
| **B1** no identity rule | **Accepted.** §8 is the table; the head is re-pointed like any mark (§3 rule 1); tokens on every re-identifiable region (§8.5); the identity oracle (§14.2) |
| **B2** the text view's type-over is not the Mac's compound; "the page wins" duplicates text | **Accepted.** "The page wins" is gone. The compound is computed at the door and the ruled page is written (§7, §8.3) |
| **B3** no road for a refused or diverted save; waiting for the keyboard widens it | **Accepted.** §11.3 (the placement check, her call §20.1), §11.4 (the rescue), §12.2 (structural deliveries and undo do not wait) |
| **M1** a seam backspace cannot follow | **Accepted, in a different shape from the one proposed.** The review proposes declining at the gate and re-issuing on the next turn. v2 catches the gesture in `deleteBackward`, inside the keyboard's own call, and makes the ruled edit there, with the map's fresh facts (§7). The review's shape is kept as the fallback, and its A8 is in the probe |
| **M2** operations normalize; stale compare-and-set bases mint conflict takes | **Accepted.** §10.1: the page is normalized at the gesture; stored texts come from the operation's result. The idle mint is the one adopt-the-page case, listed for her (§20.3) |
| **M3** "a reading" does two jobs | **Accepted.** Two fields, `stored` and `settled` (§4, §5.3); the word is retired |
| **M4** repairs throw away later typing | **Accepted.** §8.6: only the offending change is inverted; nothing is restored from saved text |
| **M5** slots and fresh flags | **Accepted.** §5.3 |
| **M6** the reconciler cannot be both headless and composed with the shared rules | **Accepted: the split** (§14.1), option (c). A new arm list `pageArms`; `phoneArms` untouched |
| **M7** the writer is not wired into the session | **Accepted.** §11.1: the session's coordinator stays the one saver; one task runs acts; every flush road waits |
| **M8** rule 5 widens a loss window; `unmarkText()` would save a guess | **Accepted.** Rule 5 is "the marked range is never saved" (§6 step 3); per-kind handling (§11.5) |
| **M9** nothing mints the open end | **Accepted.** §10.5 |
| **M10** the idle rebuild merges blocks | **Accepted.** §5.2: re-mark from the map; never rebuild from the page |
| **M11** the in-app check is blind and cries wolf | **Accepted.** §13.2: against the projection in order, with exclusions |
| **M12** unasked changes judged by a test narrower than the route | **Accepted.** §8.6 step 2 routes hers through the shared rule |
| **M13** lowering the keyboard as a routine tool | **Accepted.** §12.4; the probe's question 11; her gate |
| **M14** her performance bar missing | **Accepted.** §14.5, in every unit |
| **M15** unscheduled decisions; U3 too large | **Accepted.** U3 is split; the decisions gate run 2 (§17, §20) |
| MINORs | **Accepted:** the menu merge is an unmark (§8.4); which newline a divide stamps (§8.1); list order (§8.1); Returns beside locked and gap regions (§5.4); the sealed note's face kept (§5.4); unique bindings (§5.2); undo cleared after repairs and door edits (§12.3); the rebuild invariant restated (§5.2); multi-range asks (§9.1, §10.4); settle triggers and the marked range's timing (§6); proofreading (§13.1, the probe); the phone's own compound executor not reused (§8.3); re-check after every wait (rule 4); runner contention (§19.8); the old editor's files not edited (§19.4); receipts (§9.2, §20.7); dictated and hardware Returns (§10.2); the safety copy and label per install (§15.1); VoiceOver (the probe's question 17). **The re-mark tie-break of v1's put-back no longer exists**: v2 never re-marks from a replacement's text |
| NITs | **Accepted:** the peek's open line is closed (§12.4); §20 says which items gate run 2; the long-note question has its own probe page |
| The review's §9: "D, narrowed" | **Adopted as the design.** Its second concern is §16 |
| The review's §7: use the real operations, an adversary, kill points, a scripted self-test | **Accepted.** §14.2–§14.4, §15.4 |

---

## 22. What is retired, and what canon owes

**Deleted at U6, on the phone only:** the approve-first arming and binding, the fallback verdict, the desync repair,
the forced and differential renders under the keyboard, the keystroke fence, the per-character re-stamp, the phone's
copies of the edit route's executors, and the old editor's suites. The Mac keeps all of its own.

**Tickets this closes by replacement:** VM-250, VM-252, VM-226, VM-236, the class VX-68 watched. **Absorbed:** VM-17,
VM-239, VM-179 (U5b); VM-140 and VM-143 of wave 3's Writing (U3b). **Re-scoped at U6:** the rest of VM-137.

**Canon deltas owed at ship** (in place, the narrative in `notes/AppSpecRecord.md`): AppSpec §7's sentence "The
phone's Return model is its own"; §9's `autosave` entry if §20.1 is approved; `notes/SurfaceContracts.md`, The note
(the phone passages); `notes/MobileSoul.md` §5 and a parity row in §6; `notes/TEXTKIT2_NOTES.md` §3 (the probe's
findings) and §5 (the phone's row). No schema and no sync marker.
