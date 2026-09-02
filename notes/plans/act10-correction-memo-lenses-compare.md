# Lenses + Compare — the design memo (R-cor-6)

**Status: PROPOSE-ONLY.** Written 2026-09-01 by the Act 10 correction round's orchestrator under her ruling
R-cor-6 (*"Lenses/Compare need a design … consider clearly what the point of each tab is, and make the UX of it
better. promote into note (takes ride) for example is kinda vague"*). Nothing here is built by this round
except the two MECHANICAL defects already in the ledger (rows 16/17/46: alignment; the anchor column that
renders nothing; the duplicated offer doors). **The build to this memo is its own phase**, kicked off at her
word after she rules on §7. The friction-doctrine form (P-5): behavior whole, edges enumerated, tradeoffs
listed, her rulings collected — the two 13b memos are the precedent.

**What this memo does NOT reopen:** the semantics. Lenses' core (`createLens`/`setLensChoice`/
`adoptLensPreservingChosen`/`promoteLens`/`promotePicks`, the one-live-ring `PaneTextAuthority` board, the
"a lens is the same structure with different choices" law — Phase 11a's ratified design, 13's R65/R80–R92,
13b's adopt-swap) and Compare's core (editable lenses-across-posts, ONE ring across two post contexts, up to
four columns, lineage rails, "follow this note's order", the N29 no-relationship honesty, the Diff sheet, the
version-link doors — 13b Stage 4) stay byte-unchanged. This is about what the two tabs are FOR, what a writer
sees first, what each door is called and where it stands. **The tutorial's own sentences are the spec (P-6)**
and are quoted where they settle a question.

---

## 0. Her words (the record)

- 2026-09-01 (the morning report): *"the use of lenses is still a bit unclear."* · *"the compare page has
  improved in terms of clarity for what's going on, but look at how horribly misaligned everything is!! on
  the other hand, the buttons added are quite useful and make it a lot more obvious how the tab is supposed
  to be helpful, so that's good. 'This note' is showing nothing though, which is really weird."*
- 2026-09-01 (the phone, R-cor-6): *"The changes made them a bit clearer (so they're improvements in one
  sense, even if they look bad), but it's still absolutely dizzying. I need you to consider clearly what the
  point of each tab is, and make the UX of it better. promote into note (takes ride) for example is kinda
  vague."*
- Standing (Act 10 item 15, her fifth wave): *"it's really a user FLOW … this is deeper than just UI and what
  buttons are there, it's about how the user experiences the page"*; her copy doctrine: *"an excellent,
  guiding, clear user experience with nice, generous buttons"* — a sentence only where truly necessary.

## 1. The point of each tab — one sentence each (this is the whole memo in miniature)

| tab | the question it answers | the unit | the one door "from looking to being" |
|---|---|---|---|
| **Takes** | *Which of this BLOCK's alternatives?* | one block, its fan, in place | ✓ chooses a take |
| **Lenses** | *How would THIS NOTE read if, block by block, I showed different takes?* | one note, several READINGS side by side (a reading = a saved set of per-block picks = a lens; "the note itself" is the first reading) | **Use this lens** (adopt — swaps the note's chosen takes; the outgoing chosen is kept as a lens) |
| **Compare** | *How does this note stand beside OTHER NOTES — its versions, its outline, its drafts?* | several notes, side by side, related paragraphs tied by lineage; every pane editable | none — Compare changes RELATIONSHIPS (mark/unmark as versions), not text (text edits land in each note directly) |

Field-guide sentences that already say this, verbatim: *"A LENS is a saved way of LOOKING at a note: for each
block, which take to show. It never changes the note."* · *"✓ Make this the note ADOPTS a column … Adopting
swaps, never destroys."* · *"A VERSION is a different NOTE related to this one … Mark = connect, duplicate =
copy + connect."* · *"Compare … the notes sit side by side, related blocks tied by lineage — and every pane is
EDITABLE."* The lessons are right; the boards do not yet SHOW these three sentences by their structure.

## 2. Why it reads as "dizzying" (the diagnosis, from the walk's captures 08/09 and hers 8/9/10/13)

1. **The two boards look alike while meaning different things.** Both are columns of prose with `⠿` handles,
   dashed "a column could stand here" slots, a header card per column, and a floating `＋ column` / `+ note`
   ghost — item 15 deliberately unified the stub grammar ("ONE vocabulary"), which made the two tabs
   *structurally* alike exactly where they should differ. A writer cannot tell from the shape whether the
   columns are readings of one note or several notes.
2. **Lenses uses four nouns for one thing** — *lens*, *column*, *way of looking*, *reading* — and its doors
   name mechanisms, not outcomes: "✓ Make this the note", "⧉ Duplicate as Version" (a NOTE act, sitting in
   a LENS card), "direct promote", "promote into note (takes ride)", "a fresh take on EVERY block, branched
   from what the note shows". Her example is exactly this class.
3. **Compare's first open shows an EMPTY anchor.** The offer page (two generous cards — the part she likes)
   sits below a "This note" header card with nothing under it, because "related blocks only" filters the
   anchor too and a titleless journal entry falls back to the literal "This note". The page teaches while
   the one thing the writer brought — their note — is missing.
4. **Two placements for the same acts.** "make outline note" and "+ note" are top-right buttons AND the two
   centered cards (row 46).
5. **Three toggle chips + a diff door + two buttons in one toolbar row**, in a different left edge from the
   cards, in a different baseline from the header — the misalignment she circled.
6. **The `＋ column` ghost floats mid-right at a random height** on both boards (captures 09/13).

## 3. LENSES — the intended behavior, whole

**The sentence the surface carries** (the empty state's one line and the `?` disclosure's first line):
*"A lens is one way this note could read — for every block, which take. Columns are lenses side by side; the
first column is the note as it is."*

**The board.**
- Column 1 is ALWAYS **the note** (its chosen takes), header "the note", never closable; lens columns follow.
- A lens column's header is a LENS card: **name** (editable in place; unnamed lenses auto-named "Lens 1…" —
  canon), one **fact line** that carries the information a lens exists for — *"differs from the note in k of
  n blocks"* (0 → "same as the note right now") — and the doors (below).
- In the body, a block where this column's pick differs from the note's is **washed** (the existing tint);
  the `‹ take k of n ›` switcher shows on hover of that block only (calm at rest). Same-as-note blocks are
  plain. **The difference is the content of a lens; the board should make it visible at a glance.**
- `⠿` reorder stays (one note, one order — all columns move together; canon S4-2d) with its gloss.

**The doors — three per lens column, outcome-named, in this order; every one keeps its current core op:**

| today | proposed label | gloss (hover) | core op |
|---|---|---|---|
| ✓ Make this the note | **Use this lens** | "The note shows these takes from now on. Your current choices are kept as a lens named 'chosen until <today>', so you can swap back." | `adoptLensPreservingChosen` / `adoptPicksPreservingChosen` |
| 💾 (save) | **Save as lens** (scratch columns only) | "Keep this way of reading, named." | `createLens` + choices |
| ⧉ … "promote into note (takes ride)" / "direct promote" | **New note from this lens** — with one checkbox in its confirm: **"bring every take along"** (off by default) | "Makes a separate, linked note whose text is what this column shows. With 'bring every take along', each block's other takes come too." | `promoteLens` / `promotePicks` (+ carry-fans) |
| ✕ | **Close** | "A named lens stays saved; a scratch column is discarded." | — |

- **"⧉ Duplicate as Version" LEAVES the Lenses header.** It is a NOTE act (a full copy + a version link), not a
  lens act; it lives in the note menu (where it already is) and in Compare's version doors. Its presence in a
  lens card is the single biggest source of "what is this tab for".
- **`＋ column`** is a fixed control at the END of the column strip (never floating): a menu of **a saved lens
  (listed by name, with its k-of-n line) · a new blank lens (starts as a mirror of the note) · a fresh take on
  every block** (the existing option, reworded: "a new lens where every block gets a new take to write").

**The empty state** (only the note column exists): one generous door in the empty second slot — **"Open
another reading beside this one"** — and under it the sentence above. Nothing else.

**Edges (decided here, not discovered by her):** a **sealed** note — columns render, switchers and adopt
disabled with "sealed — read-only" (canon); a lens whose pick **dangles** at an archived/deleted take —
the 13j ruling binds: say it LOUDLY on that block ("this take was archived — showing the note's") with a
**restore** door right there; **Use this lens** on a same-as-note column is a no-op that says so ("already
what the note shows"); a lens deleted elsewhere while open — the column empties with "this lens was
deleted" and a close door; the live ring — ONE across all columns (canon), and the ring's column header
reads "editing here" while live so the writer knows which reading their keystrokes land in.

## 4. COMPARE — the intended behavior, whole

**The sentence** (the empty slot's line and the `?`): *"Compare puts other notes beside this one — versions,
an outline, a draft — and ties related paragraphs by lineage. Every column is editable; nothing is copied."*

**The board.**
- Column 1 is ALWAYS **this note, rendered whole** — every block, always; "related blocks only" NEVER filters
  the anchor (row 17's mechanical fix lands this now). Its header is a NOTE card: the note's **display name**
  (the derived rule — a journal entry shows its day, never the literal "This note"), the line "this note",
  and one act: **open on its own**.
- **The offer lives IN the empty second slot** — the dashed slot she already likes, carrying its two rows as
  generous buttons: **"Compare with a note…"** (item 14's picker; versions of this note first, marked) and
  **"Make an outline of this note"** (with its one consequence line: "a linked note named 'outline of …',
  one block per paragraph, editable"). The top-right duplicates retire (row 46). Below the two rows, the
  note's existing **version peers** as direct open-beside rows (canon). Nothing centered below an empty
  column ever again.
- A peer column's header is a NOTE card: display name · **relationship line** ("version of this note" ·
  "outline of this note" · "linked by lineage" · **"no relationship — shown side by side"**, the N29
  honesty) · acts: **open on its own · swap with… · mark as versions / unmark · close**.
- **The toolbar collapses into one calm `view ▾` popover** holding the three toggles — *follow this note's
  order · lineage colors · related paragraphs only* — plus the standalone **diff** door. One row, one left
  edge, one baseline with the cards (row 16).
- Lineage rails and the wash stay as they are (canon); "related paragraphs only" stays **ON at first open**
  (the tutorial says so) but now with the anchor exempt, and it is **disabled with "no relationship yet"**
  when no peer has lineage to this note — the toggle can no longer produce an empty board.
- `＋ note` (a third/fourth column) is the same end-of-strip fixed control as Lenses' `＋ column` — never a
  floating ghost — up to four (canon).

**Edges:** a **sealed** peer renders read-only with the seal line; a peer **deleted** while open → the column
says so with close; a version link **removed** while open → the relationship line updates to "no
relationship", rails vanish, the column stays; **unmark** confirms in one line ("these two stop being versions
of each other — nothing is deleted"); the Diff sheet unchanged.

## 5. Telling the two tabs apart at a glance (structure, not sentences)

| | Lenses | Compare |
|---|---|---|
| column 1 | "the note" (pinned, unclosable) | this note (pinned, unclosable) |
| header card | LENS card: name · "differs in k of n" · Use / Save / New note | NOTE card: display name · relationship line · open / swap / versions |
| body tint | per-block wash where the pick differs | lineage rails by color across columns |
| add control | `＋ column` (lenses) at the strip's end | `＋ note` (notes) at the strip's end |
| empty second slot | "Open another reading beside this one" | "Compare with a note… / Make an outline of this note" |
| toolbar | none (the `?` only) | `view ▾` + diff |
| what a keystroke does | edits THIS note's take in that column | edits THAT note |

Nothing above is decoration; each row is a fact the two modes genuinely differ on, made visible.

## 6. Tradeoffs and the option she may prefer

- **(A) This memo's shape** — two tabs, structurally distinct, outcome-named doors (recommended).
- **(B) Merge Compare into Lenses** as "other notes are just more columns". Rejected by the memo: the unit
  differs (one note vs several), the doors differ (adopt vs relationship), and the one-ring contract across
  post contexts already lives in Compare's board; a merged board would need every card to say which note it
  is — the confusion compounded. Recorded because the shared architecture makes it cheap to ask.
- **(C) Rename the tab** — "Lenses" is the model's word and the tutorial's; candidates if she wants a plainer
  one: **Readings** ("readings of this note") or **Views**. The memo keeps "Lenses" (the term is taught, and
  "lens" survives in the doors) but the question is hers.
- **(D) Where "Duplicate as Version" lives** — the memo moves it OUT of the lens card (note menu + Compare's
  doors keep it). If she wants it reachable from Lenses, it becomes a fourth, visibly different door
  ("Copy this note as a version") rather than sitting among lens acts.

## 7. Her rulings to collect (the morning bundle carries this list)

**RULED so far (the Act 10 correction round's sitting, 2026-09-01 — R-cor-10(b), R-cor-11(1), R-cor-16):** **1 —
the memo's words stand** (Use this lens · Save as lens · New note from this lens, + "bring every take along"); **6 —
TWO tabs, structurally distinct** (shape A); **3's anchor-whole half and 4's anchor-exempt half are BUILT and ratified**
(batch D; the filter narrowed to peers); **the outline door's placement-per-state accepted** (D's row 46 — the memo's
§4 still settles the offer's final home in the slot). **Remaining for her: 2 · 3's offer-in-the-slot half · 4's
disabled-when-no-relationship half · 5 · 7 · 8 (when the build phase runs).**

1. The door vocabulary in §3's table — **Use this lens · Save as lens · New note from this lens** (+ "bring every take along") — as written, or her words.
2. **"Duplicate as Version" leaves the Lenses card** (§6 D).
3. **Compare's anchor always renders whole; the offer lives in the empty second slot; the top-right duplicates retire.**
4. **"related paragraphs only" stays ON at first open, anchor exempt, disabled when no relationship exists.**
5. **The Compare toolbar becomes one `view ▾` popover + diff.**
6. **Two tabs, not a merge** (§6 A vs B).
7. **The tab name** stays "Lenses" (§6 C) — or Readings / Views.
8. **When the build phase runs** — the memo's build is one bounded phase (two boards, no semantics); her slot.

## 8. The build phase (when she rules) — scope in one paragraph

Two files' flows (`LensesBoardView`, `CompareBoardView`) + the picker's Compare entry + the field guide's
two lessons re-cut to the new door names (the re-seed obligation rides). Semantics untouched — the proof is
the standing suites (`CompareComposition`/`CompareViewModel`/Takes) green UNMODIFIED, plus NEW pins only
where the memo states a behavior: the anchor never filtered · the offer slot's two doors · the k-of-n fact
line · "Use this lens" no-op copy on a same-as-note column · the dangling-pick loud line with its restore
door · the toggle disabled with no lineage · exactly ONE placement per act (a registry walk over both boards).
The acceptance gate is USE (the round's C-2): every §3/§4 door walked on the dev build with captures, in both
voices, before her walk.
