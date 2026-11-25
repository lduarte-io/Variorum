# VM-271 — the phone's editor: where the design stands, for a fresh design session

**Written 2026-11-22, on branch `vx-1033-nov-22-sitting`, at the end of the Nov 22 sitting's work on VM-271.
Nothing is built. Nothing is approved. The author has moved this design out of that sitting into a standalone design
session that starts from the ground up. This file is what that session reads first.**

*How to read it:* §1 is her words and what the new session is. §2 is the problem. §3 is the road so far. §4 is what
the three reviews found. §5 is what the orchestrator recommended, exactly as it was told to her. §6 is her lean
against it. §7 is what holds whatever the design turns out to be. §8 is what nobody has measured. §9 is her rulings
so far. §10 is the files, in reading order. §11 is the state of the sitting this came from.

A note on authority. Her words, quoted, are hers. Everything else here is the previous orchestrator's account and
judgment (Fable, the Nov 22 sitting), checked against the code where §4 says so. None of it is a decision. The new
session is free to disagree with all of it.

---

## 1. Her words, and what the new session is

**Her decision (2026-11-22, verbatim), after both second-round reviews and the orchestrator's recommendation:**

"ok. hmm. I can see from how all of this is going that this is very castle-esque in effort and I think that I simply
need to start a new conversation and slow things down to the point where I understand everything and where it is
really thoroughly, the trade offs thoroughly, and think more about what the solution should be. I want you to make
sure that all of these findings on the review, what your suggested direction for v3, any important context from this
conversation, etc. is in an appropriate file / place, and give me a prompt about the information for a new session. I
want to start a new session and build our understanding of the problem space from the ground up, then see how it
intersects with the information here, etc. I'll tell it to look at this first so it gets an idea of the problem space
but I think that I just need an even bigger step back, since this problem seems to be much deeper than I was
initially aware of, so I'm raising it from being an offshoot of a catch all planning session to a new, fresh,
standalone design session. include everything you told me in this message - what you recommend, what it buys, what it
costs, what it leans on, etc. I will say that my initial lean is that v3 is not the correct approach at all - a note
that doesn't let you write a newline because it's waiting on sync is a broken app, honestly. but just write your v3
plans and pros and cons exactly as you told them to me, and I'll start this fresh."

**So the new session:**

- is a design session, not a build and not a plan-approval. Its first job is her understanding of the problem space,
  built from the ground up, at her pace;
- reads this file first to get the shape of the problem, then meets the rest of the material as the conversation
  reaches it;
- treats the plan (`notes/plans/vm-271-phone-editor-core.md`, draft v2) as **not approved and not the working
  design**. It is a record of one attempt and of what broke it;
- treats §5's direction as one recommendation that she leans against (§6).

**What went wrong with the pace, as the orchestrator reads it** (its own reading, not her words): within one sitting
the work went from her text-loss recording to a five-option page, a choice, a full plan, a review, a second plan, two
more reviews and a third direction. Each step was sound by itself, but the design kept changing at its centre faster
than she could weigh it, and the problem turned out to reach into sync and into the Mac. She compared the effort to
the Castle work. The new session should not start a plan or a review ladder until she says the understanding is
there.

---

## 2. The problem

### 2.1 What happens on her phone
Her recording of 2026-11-21 (ticket **VM-250**): typing at the end of a block while the keyboard was predicting lost
letters, damaged the next block, and the damage was saved. The editor audit then traced a second window (**VM-252**):
a key typed after a refused edit and before the page's repair can save wrong text into the wrong block. Her words on
it: "it seems like there is the whole problem that comes together from this wohle class of issue about page redrawing
beneath in progress keyboard text, and all of those issues. what's the root level solution?"

### 2.2 Why the Mac's design breaks on the phone
Today's phone editor copies the Mac's: approve each change before it happens, keep a private map of which characters
belong to which block, and redraw the page from the library when the map and the page disagree. On an iPhone:

- the keyboard changes text without asking (autocorrect, predictions, dictation, replacements), and the "may I"
  question is unreliable and partly deprecated at iOS 27;
- the keyboard keeps its own state about text it is still forming, and writes at stale positions when the page is
  redrawn underneath it;
- typed characters never carry the app's own attributes, so an identity that rides every character is wrong after
  every keystroke.

Sources: `notes/plans/vx-1033/ios-text-input-research.md`, `notes/TEXTKIT2_NOTES.md` §3,
`notes/plans/vx-1033/phone-editor-audit.md`.

### 2.3 What makes it deep
The app's atomic unit is the block, and a block has a permanent identity in the library. A text view holds one long
string. Something has to say, at every moment, which characters are which block, and three things can each claim to
know: the page (the text view), the editor's map, and the library. Every design so far is a different answer to "who
leads, and when do the others catch up". The hard cases are all at block boundaries:

- **Return, backspace at a block's start, and an edit across blocks** change structure, at typing speed, and their
  ruled results on the Mac are not what a stock text view does by itself (a join puts a space between two texts; a
  divide trims the cut; a caret inside a word takes the whole word down; a block with takes divides differently; two
  ends sometimes join and sometimes do not).
- **Those rules read facts only the library holds** (how many takes a block has, comments, locks, what the
  neighbours are).
- **Another device can change the same note at the same time**, and sync only notices a collision when two devices
  write the same row. A merge or a divide on one device and typing on the other do not touch the same row (§4.3).

### 2.4 The bar she set
- "I feel like a writing app where you can't select across multiple paragraphs is going to be difficult to use / be
  happy with for people. … this is the soul of the mobile app and how we make it a great app, rather than a mid one."
- "if we need a workaround / different approach on the phone, i don't want the phone's compromises to affect the mac
  editor's experience - i like where the mac is at and I'm wary of changing it to accomodate the phone."
- On structure: "we need it to be deterministic and follow a set of rules, not changing randomly with whatever non
  keyboard input showed up, or the block system wouldn't make sense to people."
- On sync: "this is where we have to plan carefully sync wise, because we've sidestepped a lot of issues with takes
  but we can't sidestep structural operations."
- On waiting (2026-11-22, of §5's direction): "a note that doesn't let you write a newline because it's waiting on
  sync is a broken app, honestly."
- The proposal page's own list of what a great phone editor has to do: it is one page · the keyboard just works ·
  every word lands in its block · nothing is lost or saved wrong · it stays fast · the Mac stays as it is.

---

## 3. The road so far

| Step | What | Where |
|---|---|---|
| 1 | Her recording read frame by frame; VM-250 filed | the ticket; frames are local only, never committed |
| 2 | Four audits: the phone editor, the phone app outside the editor, phone sync lag, the phone against the Castle rules | `notes/plans/vx-1033/` |
| 3 | Outside facts on iOS text input; a code inventory of what exists | `notes/plans/vx-1033/ios-text-input-research.md`, `phone-editor-inventory.md` |
| 4 | A design proposal page with five options | `notes/plans/vx-1033/design/phone-editor-proposal.html` |
| 5 | She chose option D, "the page is the truth" | her words in the plan's §2 |
| 6 | Plan v1 → the first cold review: three blockers | `notes/plans/vm-271-plan-cold-review-1.md` |
| 7 | Plan v2 (structure through "her doors", the Mac's shared rules decide) | `notes/plans/vm-271-phone-editor-core.md` |
| 8 | She agreed with v2 broadly and asked for two more reviews | the plan's §2 |
| 9 | The second cold review and the sync-focused review: both "not yet; the direction is right" | `notes/plans/vm-271-plan-cold-review-2.md`, `notes/plans/vm-271-plan-sync-review.md` |
| 10 | The orchestrator recommended a third shape ("the library goes first") | §5 below |
| 11 | She leaned against it and moved the design to a fresh session | §1, §6 |

**The five options on the proposal page:** A, keep today's editor and guard it · B, one block at a time (a text view
per block) · C, two layers · D, the page is the truth · E, build our own text input. Her words on B: "i feel like B's
cost is somewhat significant … not being able to drag and edit across a new line is frustrating." The page also has
a section on a question she raised herself, "should the phone default to not making new blocks on new lines?"

**The three shapes tried inside option D.** They differ only in who leads at a structural gesture:

| | Who leads | What broke it, or what it costs |
|---|---|---|
| **v1** | The page leads everything. The text view makes the change; the library follows the page | Which paragraph break survives a native edit is not which block the rules say survives. Text gets bound to the wrong block and results differ from the Mac's (review 1: B1, B2). She agreed: "computing the block after isn't the right approach - not what the mac does" |
| **v2** | The editor works out the ruled result from its own copy of the facts, writes the page at once, then sends the operation | The page runs ahead of the library. The copy of the facts is wrong for blocks the editor just made; a refusal has to be undone by hand; a change from another device can land in between (reviews 2 and sync) |
| **"v3"** (recommended, not adopted) | The library leads structure. The gesture is held, the operation runs, then the page is brought to the result | A structural key waits for the phone's own database. Her lean: not the right approach (§6) |

Typing inside one block was never in dispute: "accept every change, then read it" survived all three reviews.

---

## 4. What the reviews found

Each review file is complete and self-contained; this is the map. All three were Opus, cold, read-only.

### 4.1 The first cold review (of v1) — `notes/plans/vm-271-plan-cold-review-1.md`
Verdict: the central idea holds for typing inside one block and breaks at structure.
- **B1** no rule for which region is which block after a structural act; a wrong binding silently sends her next
  words into a block that has left the note.
- **B2** the text view's own type-over is not the Mac's compound; "the page wins" then duplicates text.
- **B3** no road for a save the library refuses or quietly diverts.
- Fifteen majors (M1–M15), a table of 22 cases where results would differ from the Mac's (its §3, a lasting
  reference), and 17 assumptions about UIKit (its §5).
- Its closing proposal, "D, narrowed": keep accept-then-read for typing; make every structural keystroke decline,
  decide against the library, and apply the result a moment later.

### 4.2 The second cold review (of v2) — `notes/plans/vm-271-plan-cold-review-2.md`
Verdict, in its words: "I would not approve v2 yet. The direction is right; the specification is not."
What it says v2 got right: most rows of the identity table; one saver; the forming text cut out of saves; the map
never rebuilt from the page.
- **N1** the plan never says what the editor does with its own page edits. Read literally, the editor saves its own
  edit as her typing and the operation then runs on text that already holds its own result (its example ends with a
  word cut in half in the library).
- **N2** the doors decide questions about takes from facts the map cannot have. Return in a block with takes, then
  backspace, silently drops the other takes out of the note; the Mac refuses that in words.
- **N3** regions an act rewrites but does not re-identify are not held, so the editor's own act mints a "conflict"
  take.
- **N4** v2's backspace join refuses beside an archived take, a comment or a locked take. The Mac refuses only when
  either block has more than one live take. *(The orchestrator's own error in v2; it contradicts her ruling.)*
- **N5** in new text at a note's end, the Mac's rule makes a block of a finished paragraph when the next paragraph's
  first character is typed, not at Return, and trims it. That moment has no door.
- **N6–N9** the rescue, the flush roads, the order at leaving, and deliveries racing the editor's own acts cannot be
  built on the shared save queue and session as they are; the shared-code changes are more than v2's two.
- **N10–N13** the page silently wins when an operation's result differs from it; whose change a struck break was;
  the undo of a refused act once she has typed past it; Return's rows omit the cut's own rule.
- **N14–N16** missing rows; the proof plan checks the editor against itself and not against the Mac; the note
  screen's own controls have no unit and two units are too large.
- Its §3 checks the identity table row by row; its §4.1 lists every road that reaches the page without a door; its
  §6 adds ten probe steps.
- Its strongest case against (§9): v2 is optimistic where the Mac is not, and "the design now has four copies of
  structure and text that must agree". Its alternative is a **split door**: act at once only where the result needs
  page geometry and facts the editor truly knows; decline, read and re-issue for everything that turns on a
  library-only fact.

### 4.3 The sync-focused review (of v2) — `notes/plans/vm-271-plan-sync-review.md`
**Her question, answered** ("what is still in this note? the block?"): yes, the block. Her words are saved into a
take; the take's block is in the note through one placement row. A merge, a divide of a block with takes, an archive
or a move on another device removes that placement without touching the take. So typing on one device and a merge on
the other touch different rows, sync accepts both with no conflict, and the note ends up showing the older copy of
the paragraph while her newer words sit in a block that is no longer in the note. Nothing says so.
- **B1** a structural act planned on one text and run on another overwrites the other device's words. A sync pull
  can land between the editor's decision and its operation; `divide` and `merge` do not check the text they were
  planned on. The MCP door already guards this same race, and the operations already accept such a check.
- **B2** words saved before the phone hears of a remote merge, divide-with-takes or archive are stranded, in every
  order of arrival. v2's save-time check catches only saves made after the phone has heard, which is the uncommon
  half.
- **M1–M8** structural deliveries onto the page are undefined for the region she is in; the doors authorize from
  the map where the Mac authorizes from the library; one rescue shape duplicates text and contradicts the model in
  three cases; keys held behind a refused act have no home; a refused save retries forever; the flush before every
  sync round cannot see the editor's queued acts; **the Mac has the same stranding hole today**; SyncSpec accepts
  duplicated paragraphs on the premise that "structural editing is desktop-only".
- Its §2 is a 28-cell table of phone act × Mac act, with where her words end in each. Its §11 lists twelve test
  groups for the existing two-client harness, with a stronger bar than convergence: every word either device typed
  is in the note, in a take of a placed block, in the Trash, or said.
- Its seven decisions for her (D1–D7) are in §5.1 below as the orchestrator put them to her.

### 4.4 What the orchestrator checked in the code, and what it did not
Checked, all holding (main at `b23550bc8`):
- a save into a take whose block has no placement is accepted silently; a refused save stays pending forever;
- `divide` and `merge` take an optional in-transaction check (`guardedBy`) and by themselves check neither the text
  they were planned on nor, for `merge`, the takes;
- the MCP door's own divide re-checks the takes and texts inside its transaction;
- sync's repairs treat a live block with no placement as legal;
- the flush before a sync round looks only at the save queues;
- the Mac's backspace join reads the takes from the library and refuses only on more than one live take; locked
  takes do not refuse;
- the Mac's structural door: "The store leads — the surface is never pre-written optimistically", and keys typed
  while an act lands are replayed after it;
- every save also writes the note's own row; note-level settings are server-wins under sync;
- divide, extract and merge copy comments to the blocks they make;
- the save queue keeps the first edit's base for a whole run, reports only the first error and cannot drop an
  entry;
- typed crystallization fires at the next paragraph's first character;
- SyncSpec §7's "desktop-only" sentence.

Not checked, or the reviewers' own inference:
- that restoring a note version on the Mac while the phone has unpushed words in that note loses them for good
  (sync review, cell 7): inferred, never run;
- every statement about how the iPhone keyboard behaves when a key is held, declined, or answered with a different
  edit: nobody has measured any of it (§8);
- how long a structural operation takes on her phone (§6).

---

## 5. What the orchestrator recommended, as it was told to her

She asked that this be recorded exactly. The two chat messages follow verbatim. The only edits are that file paths
are written relative to the repo and the messages' headings are set as bold lines.

### 5.1 After the sync review (2026-11-22)

> The sync review is in; the general one is still running. I read the sync review whole and checked its main claims
> against the code, and they hold. Plan v3 is not written: it waits for the general review and for our talk.
>
> The review is at `notes/plans/vm-271-plan-sync-review.md`, committed and pushed on the branch.
>
> **Your question: "what is still in this note? the block?"**
>
> Yes, the block. Your words are saved into a take, and the take's block is in the note through one placement row.
> A merge, a divide of a block with takes, an archive or a move on the Mac removes that placement without touching
> the take.
>
> So if you type in a paragraph on the phone while the Mac merges it, the two changes touch different rows. Sync
> accepts both with no conflict. The note ends up showing the Mac's older copy, and your newer words sit in a block
> that is no longer in the note. Nothing says so.
>
> **Two blockers**
>
> 1. **The plan's check looks at the wrong moment.** It refuses a save only once the phone knows the block left. The
>    phone usually learns seconds to minutes later, or at its next open, and by then your words are saved and
>    pushed.
>    - **Fix:** catch it when the phone hears. The editor that typed the words compares what it saved with what the
>      note now shows, and puts them back if they are missing.
>    - **For a merge:** your words go into the merged block in place when that fits exactly. Otherwise they become a
>      new block beside it, with a line saying so, and the paragraph shows twice (older and newer).
>    - **At open:** a second check covers the case where the editor was not alive to hear.
> 2. **A Return or backspace can run on text the page never showed.** If sync pulls in a Mac edit a moment before
>    you press Return, the page divides the old words and the library divides the new ones. Your next keystroke then
>    saves the old words over the Mac's, with no conflict take.
>    - **Fix:** every structural operation re-checks, inside its transaction, the text, takes and neighbours it was
>      planned on, and refuses if they moved.
>    - **Cost:** none to any operation's contract. The operations already accept such a check, and the MCP door
>      already uses one for this same race.
>
> **Also worth knowing**
>
> - **The Mac has the same stranding hole today.** Phone Return and backspace will make it more frequent on the Mac,
>   because they become divides and merges.
> - **SyncSpec's premise no longer holds.** It accepts duplicated paragraphs from two devices dividing one block
>   because "structural editing is desktop-only".
> - **The per-note switch can be dropped.** If it is flipped on one device while the other is typing in that note,
>   it can be lost. The same already applies to a seal or a take lock.
> - **One unconfirmed loss.** Restoring a note version on the Mac while the phone has unpushed words in that note may
>   lose them for good. The reviewer inferred this and did not run it. It needs a test and a ticket.
>
> **The calls this puts to you**
>
> | # | Question | My lean |
> |---|---|---|
> | 1 | Where stranded words are caught | When the phone hears, not at the save |
> | 2 | Whether `autosave` still gains the placement check | Drop it: call 1 covers it, and no operation changes |
> | 3 | A paragraph merged or divided elsewhere | Into the merged block when exact, else a new block |
> | 4 | A take locked or deleted elsewhere | A new take on the same block |
> | 5 | A block moved elsewhere | Your words follow it, and the line says where |
> | 6 | A block deleted or archived elsewhere | The delete wins and the line offers Put back, unless you were mid-typing there, in which case the paragraph is kept |
> | 7 | SyncSpec's accepted duplicates | Accept knowingly, rewrite the line, watch the rate in your trial |
> | 8 | The Mac's hole | A ticket, with the rule written as shared code so the Mac can adopt it later |
> | 9 | A Return refused because the library moved | Undone on the page and said; you press it again |
> | 10 | Words refused because the note was sealed or deleted elsewhere | Said plainly as not saved, with Copy |
>
> Call 6 is the one I hold least firmly. I'd take calls 1 and 2 first, since they replace the part of v2 you asked
> about.

She did not answer these ten calls. They are open.

### 5.2 After both reviews (2026-11-22) — the "v3" direction

> Both reviews are in. I read each one whole and checked their main claims against the code, and they hold. The
> second one is at `notes/plans/vm-271-plan-cold-review-2.md`, pushed on the branch.
>
> Both give the same verdict: v2 is not ready, and the direction is right. Typing inside a block (accept every
> change, then read it) survived both. The trouble is all in Return, backspace at a block's start, and edits across
> blocks.
>
> **The one thing both reviews found**
>
> v2 changes the page first and asks the library afterwards. It works out the result from its own copy of the facts
> about takes, comments and text, writes the page at once, then sends the operation. The Mac never does this: it
> runs the operation first and shows the result. Nearly every serious finding is a cost of that choice:
>
> - **The copy of the facts is wrong for blocks the editor just made.** Return in a paragraph with three takes, then
>   backspace to undo it, would join the halves and drop the other two takes out of the note without a word. The Mac
>   refuses that.
> - **A refusal has to be undone by hand.** If the library says no after the page has changed, the page must be put
>   back, and that is undefined once you have typed past it.
> - **Another device's edit can land in between.** This is the overwrite from the sync review.
> - **The editor can read its own page edit as your typing.** It then saves that before the operation runs, and the
>   library ends up with a word cut in half.
>
> **What I recommend for v3: for structure, the library goes first**
>
> 1. Return, backspace at a block's start, or an edit across blocks is caught at the door and held. Nothing on the
>    page changes yet.
> 2. The operation runs and re-checks the text, takes and neighbours it was planned on.
> 3. The page is brought to the operation's result with one small edit.
> 4. Keys typed in between are held and replayed, as the Mac does.
>
> Typing inside a block stays as it is.
>
> - **What it buys:** a refusal changes nothing on the page, the page can never run ahead of the library, and your
>   own Return reaches the page the same way a change from the Mac does. The hardest machinery in v2 goes away.
> - **What it costs:** a structural key waits for the library. I expect a few milliseconds on an ordinary note; that
>   is my estimate from the size of the operations, not a measurement. It is longer when something else holds the
>   database, such as a large sync catch-up, and then Return would hesitate.
> - **What it leans on:** the keyboard tolerating a held key and an edit made a moment later. That becomes the
>   probe's first question, with a delay dial so you can feel how long the wait can be. If only v2's way turns out
>   keyboard-safe, we build v2's way with everything the reviews require.
> - **One ruling of yours changes:** this morning you kept "a key typed while a divide or merge lands is refused and
>   said". In the new editor those keys would be held and replayed instead.
>
> **Two mistakes in v2 that were mine**
>
> - **The backspace join's refusals.** I listed an archived take, a comment and a locked take. The Mac refuses only
>   when either block has more than one live take. As written, backspace after a commented paragraph would refuse on
>   the phone and join on the Mac, against your "mac's exact rules" ruling.
> - **"Known without asking: one take, no comments."** This is false for any block a divide or merge produces,
>   because comments are copied and the other takes ride onto the top block.
>
> **Also yours, new from this review**
>
> - **New text at the end of a note.** The Mac trims a finished paragraph when you start the next one. On the phone
>   that means changing the line above your caret while you type, or storing the paragraph as typed. I'd store it as
>   typed: tidying text under the keyboard is what broke today's editor.
> - **Shared code.** v2 said two changes; it is more. The save queue must say which save was refused and drop it once
>   rescued, and the flush-before-sync and leaving roads must know about operations in flight. All are additive, but
>   they touch files the Mac compiles.
> - **Size.** It is more than eight units. The note screen's own controls (rename, lock, date, find, tags, versions,
>   comments) have no unit in v2, and two units are each too big for one session.
>
> v3 is not written. The ten calls from the sync review in my last message still stand, and none changes with this.
>
> Do you agree that for structure the library should go first, with the wait that brings?

### 5.3 Three things the orchestrator had in mind and did not say in chat
Recorded in the sitting record at the time; here so the account is whole.
- Return that only makes an empty block (at a paragraph's end or start, or in an empty block) reads no fact from the
  library. It could change the page at once even if every other structural key waits. That is the second review's
  "split door" in its smallest form.
- Under "the library goes first", her own Return and a structural change arriving from another device could reach
  the page by one and the same mechanism (bring the page to the library's structure with a small edit). That
  unification was the main reason for the recommendation.
- If the probe shows that an edit made a moment after a held key upsets the keyboard, and an edit made inside the
  keyboard's own call does not, the recommendation falls back to v2's shape with everything the reviews require. If
  neither is safe, a single text view cannot give the Mac's results and the choice returns to her (a custom text
  input, or results that differ from the Mac's).

---

## 6. Her lean against it

Her words (2026-11-22): "I will say that my initial lean is that v3 is not the correct approach at all - a note that
doesn't let you write a newline because it's waiting on sync is a broken app, honestly."

The orchestrator's notes for the new session's accuracy. These are its own, and they do not answer her objection:

- **What the wait in §5.2 is on.** It is the phone's own database write, never the server or the network. Sync comes
  into it only because a large pull, while it is being applied, holds that same local database, and a Return
  pressed then would wait for it. Whether she meant that case or the wait in general, the requirement she is stating
  is the same and it is a strong one: **a Return must never visibly wait.** The orchestrator's message put the cost
  in one line and did not weigh it as she does.
- **"A few milliseconds" was an estimate.** Nobody has measured a structural operation's round trip on her phone, on
  an ordinary note or a long one, with or without a sync apply in progress.
- **Her requirement removes more than §5.2.** Taken as a rule, "Return never waits" also rules out the first
  review's "D, narrowed" and the second review's split door for any gesture she expects to be instant. It points
  back toward the page changing at once, which is where v1 and v2 stood, and both of those were broken by what the
  page cannot know at that instant. So the question the new session inherits is not "v2 or v3". It is closer to:
  **what has to be true at the instant of the keystroke, what can be settled a moment later, and what does she see
  if the later answer is no.** Her earlier question belongs here too: "should the phone default to not making new
  blocks on new lines?"

---

## 7. What holds whatever the design turns out to be

Findings that do not depend on which shape is chosen. Several are about sync and the Mac, not the phone's editor.

1. **Typing inside one block is safe as "accept every change, then read it".** Three reviews tried to break it and
   could not.
2. **Stranded words exist today, on both platforms.** Typing on one device while another merges, divides (with
   takes), archives or moves that block leaves the newer words outside the note, silently. The Mac has it now. Any
   phone design that makes Return and backspace structural makes it more frequent. Catching it at the save does not
   work; the sync review's proposal is to catch it when the device hears, in the editor that typed the words.
3. **A structural operation can run on text nobody saw**, whenever a sync pull lands between a decision and its
   operation. The operations already accept an in-transaction check; her own doors pass none today.
4. **SyncSpec §7 accepts duplicated paragraphs from two devices dividing one block because "structural editing is
   desktop-only by product design".** Any design with structural keys on the phone ends that premise. It is hers to
   re-rule, and `notes/SyncSpec.md` is canon.
5. **A seal, a take lock, or a per-note setting changed on one device while the other is typing in that note can be
   dropped by sync.** Every save writes the note's own row, and note-level fields are server-wins. Existing behaviour
   for the seal and the lock.
6. **A possible permanent loss, unconfirmed:** restoring a note version on the Mac while the phone holds unpushed
   words in that note (§4.4). It needs a test before anyone relies on it either way.
7. **The shared save queue cannot support a rescue as it is**: a refused save retries forever, only the first error
   of a batch is reported, and nothing can drop an entry.
8. **The Mac's rules for the structural keys, as code**: the first review's §3 table and the second review's §3 are
   the reference for what "the Mac's exact results" means, including that a backspace join refuses only on more than
   one live take.
9. **What the phone app is like outside the editor** (the lifecycle seam, the lock after return): VM-266 to VM-270,
   from `notes/plans/vx-1033/phone-app-audit.md` and `phone-castle-rules-audit.md`. Separate from the editor, but
   the editor plugs into the leaving and lock moments.
10. **Phone sync is slow for reasons outside the editor** (no pull while open, a lock on every leaving, about 13
    calls a round): `notes/plans/vx-1033/phone-sync-lag-report.md`, VM-262 to VM-264.

---

## 8. What nobody has measured

Every shape so far rests on how the iPhone keyboard behaves, and none of it has been measured on her phone:

- whether a mark on a paragraph break survives every way text can change;
- what the keyboard does when a key is held or declined and the edit is made a moment later;
- what it does when a different edit is made inside its own call (a backspace answered with "replace the break by a
  space");
- what a grey inline prediction writes when shown, accepted and rejected, and what ending a composition does at the
  moment she leaves;
- which calls carry forward delete, a held delete and a word delete;
- how long a structural operation takes to return on her phone.

Plan v2's §15.3 designed a throwaway **probe screen** for these (17 questions), and the second review added ten more
(its §6). The probe is mostly independent of which design is chosen: its answers narrow the design space for all of
them. She had agreed it should run in its own session. The orchestrator's view is that it could usefully run before
any design is settled, since several of the forks above are decided by facts and not by preference.

---

## 9. Her rulings so far on the editor

These stand until she changes them. She is taking a bigger step back, so the new session should hold them as
"ruled so far" and ask before leaning on one.

- Option D chosen (2026-11-22): "I think that the page is the truth is a good approach."
- Today's editor is not patched: "i don't really think that just for me we need to fix the current editor if we're
  going to change the whole thing. it's not a HUGE issue and doesn't come up that frequently, it's a HUGE issue for
  launch". VM-250 and VM-252 stay open as launch gates.
- A cheap switch for an early look: "ok I suppose a cheap switch for an early look is fine - I just want us to be
  strategic with the work".
- Mobile wave 2 waits: "i'll probably just wait and only run wave2 once this is done. I'd rather the core of the app
  be stable before making more changes."
- "backspace at block start joins with mac's exact rules - yes."
- "return makes a block - yes, agreed. not being able to type a newline within a block isn't an issue if you can
  press the newline button."
- The Mac's per-note "newlines make blocks" switch comes to the phone: "i think that should be an option but it
  shouldn't be in settings, it should live in the note." (VM-141)
- The probe runs in a new session: "I agree with running the probe in a new session".
- From the wave-1 handoffs the same day, about today's phone editor: a key typed while a divide or merge lands is
  refused and said (VM-64, P-2-1), kept.
- The Mac's editor does not change in this effort. The Castle design is frozen.

Open, hers, and unanswered: the ten calls of §5.1; plan v2's §20 items 1–3, 5 and 7–11; everything in §5.2's "also
yours".

---

## 10. The files, in reading order

All on branch `vx-1033-nov-22-sitting` (worktree `~/dev/variorum-vx-1033` on the Pro), and on `main` once that
sitting's branch is merged.

1. **This file.**
2. `notes/plans/vx-1033/design/phone-editor-proposal.html` — the five options and the bar, written for her. The
   plainest account of the problem.
3. `notes/plans/vx-1033/phone-editor-audit.md` — how today's phone editor fails, traced.
4. `notes/plans/vx-1033/ios-text-input-research.md` — outside facts about iOS text input.
5. `notes/TEXTKIT2_NOTES.md` §3 — what has been measured.
6. `notes/plans/vm-271-phone-editor-core.md` — plan v2. **Not approved.** Read for its vocabulary, its identity
   table (§8) and its probe (§15.3).
7. `notes/plans/vm-271-plan-cold-review-1.md` — especially its §3 (Mac results) and §9.
8. `notes/plans/vm-271-plan-cold-review-2.md` — especially its §2 (N1–N3), §4.1 and §9.
9. `notes/plans/vm-271-plan-sync-review.md` — especially its §0, §2 (the matrix) and §12.
10. `notes/plans/vx-1033/phone-editor-inventory.md` — what exists in the code, with signatures.
11. `notes/plans/vx-1033-nov-22-sitting.md` — the sitting's record: her words through the day, the tickets, the
    other audits.
12. Canon the design touches: `notes/MobileSoul.md` §2, §3, §5; `notes/SyncSpec.md` (§1, §6, §7 at least, whole
    before any sync proposal); AppSpec §7's Return passage and §9.

Tickets: **VM-271** (Umbrella, Urgent) the editor core · **VM-250**, **VM-252** the two traced losses · **VM-141**
the per-note switch · VM-17, VM-239, VM-179, VM-226, VM-236 named by plan v2 as absorbed or closed by replacement.
No ticket exists yet for the stranded-words hole on the Mac, for SyncSpec §7's premise, or for the version-restore
race.

---

## 11. The state of the sitting this came from (VX-1033)

- The branch is pushed and **not merged**. It carries the audits, the research, the proposal page, the plan, the
  three reviews, this brief, the sitting's record, and three corrected lines in `notes/SurfaceContracts.md`
  (VX-1030).
- The sitting is not closed. Still owed at its close: the day's rulings written into `notes/QUESTIONS.md` in her
  words, an `notes/AppSpecRecord.md` entry, the handoff, the PR and merge, VX-1033 closed. The list is in the
  sitting record's RESUME HERE section.
- Her phone carries the wave-1 app with today's editor, installed 2026-11-22 over Wi-Fi.
