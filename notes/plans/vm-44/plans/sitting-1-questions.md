# VM-44 — sitting 1: the open questions (draft, not canon)

Every question the seven audits raised for the author, deduplicated and grouped by theme. Questions `her-words.md`
already answers are dropped and listed at the end under "Already ruled", with her quote.

**How to read an entry.** The question in one sentence; the options with what each costs; the readers'
recommendation where they gave one ("none given" otherwise — where the consolidator adds a fact, it says so); the
work-list rows that wait on it (W- ids in `master-work-list.md`); where it came from.
**[GATES DESIGN]** = mockups for that surface can't start until she answers. **[later ticket]** = design can proceed;
only a later build ticket waits.

---

## 1. Shell and wings

### SW-1 — How does a wing swipe live beside the Starred · Shelf · Library swipe? [GATES DESIGN]
Every root already pages Starred ‹ Shelf › Library with a horizontal swipe; she asked for a quick swipe between wings too.
- (a) The wing swipe lives only on the masthead's wing name or a thin wing strip under it; the rest of the screen keeps paging roots. Cost: a smaller swipe target, and a new strip on every root.
- (b) Wings change by the dropdown and by a swipe on the tab bar; roots keep the full-screen swipe. Cost: a swipe on a 14-pt bar needs the bar rebuilt first (W-007); hard to discover.
- (c) The full-screen swipe becomes the wing swipe; Starred · Shelf · Library become taps only. Cost: retires the root swipe she asked for earlier ("it's killing me", round-2 handoff §3 row 7c, quoted in E §2).
- Readers' recommendation: none given.
- Waits: W-018, W-017, W-007.
- From: A Q1; B Q3.

### SW-2 — What does switching wings do to notes already open? [GATES DESIGN]
Each of the three stacks can hold a pushed note or book.
- (a) Every stack pops to its root in the new wing (the Mac's "a deliberate switch lands in the wing's Bookcase", VX-833). Cost: open notes close.
- (b) Root pages re-scope; a pushed note stays open and shows "in ‹its wing›" (the Mac's follow). Cost: needs the WingFollow hoist (W-020).
- (c) Switching is allowed only from a root surface. Cost: simplest; no switch from inside a note.
- Readers' recommendation: none given.
- Waits: W-017, W-020.
- From: A Q2.

### SW-3 — Does the half-screen writing area (R27) still own the home screen once shelves and nine wings arrive? [GATES DESIGN]
Today the books get at most about eight rows above the quick-note box.
- (a) Keep R27 as ruled; the Bookcase lives inside the bounded region. Cost: shelves, solo and All squeezed into ~8 rows.
- (b) The Bookcase gets the screen; quick entry is a one-line bar at the foot (the Mac's own posture) that grows on focus. Cost: changes a ruled layout; the shelf's layout arithmetic is re-derived (W-024).
- (c) Split by context: the bounded region with few books, the full screen past a threshold. Cost: two layouts to keep.
- Readers' recommendation: none given.
- Waits: W-023, W-067, W-024, W-194 (the band sits above the quick entry).
- From: B Q2.

### SW-4 — How does the capture box file and make paragraphs on a keyboard with no ⇧⏎? [GATES DESIGN]
R-13u-4 (⏎ files, ⇧⏎ new paragraph) was ruled for both platforms and "never to be re-decided" (E §2); only the phone's mapping is open. Her lost-prose words: "we need full multi line editing clearly or some other solution because this was not it" (E §2).
- (a) ⏎ makes a new paragraph; a visible File / Open button files. Cost: the soft keyboard's Return no longer files.
- (b) ⏎ files and opens (today); paragraphs only by paste. Cost: keeps the one-paragraph box her lost-prose report rejected (consolidator's note).
- (c) ⏎ files without opening and clears the box for the next note; Open is a button. Cost: paragraphs still need another road.
- Readers' recommendation: none given.
- Waits: W-022 (and through it W-025, W-026, W-027).
- From: A Q5; E PL-27.

### SW-5 — Where does a phone quick note land? [later ticket]
Today: Home, bookless, untagged, no receipt. The Mac's quick-entry band lands in the current wing; the Mac's pad lands in Home wearing the quicknote tag (VX-841) and can redirect one capture to another wing, where it wears that wing's quicknote tag.
- (a) The current wing, bookless (the band's twin). Cost: smallest change once wings exist.
- (b) Home, with the quicknote tag and Home's quicknotes gathering (the pad's twin). Cost: lands away from where she stands.
- (c) The current wing, wearing that wing's quicknote tag (the pad's redirect, made the default). Cost: mints a tag per wing on first use.
- Readers' recommendation: none given (E: "needs her call inside the capture rebuild").
- Waits: W-027.
- From: E round-2 §6.6 (F2), §4 item 9; A·G6.

### SW-6 — Does the phone honour `receipt_style` (toast · quiet · off)? [GATES DESIGN]
The phone has no message seam; each screen keeps its own two lines and receipts never fade.
- (a) The phone honours the synced setting with its own quiet line. Cost: a seam that reads the setting.
- (b) The phone always uses a quiet line and ignores the setting. Cost: a synced setting with no phone meaning.
- (c) The phone shows toasts like the Mac's toast style. Cost: toasts over a small screen.
- Readers' recommendation: none given. Held since VM-4 §5 item 5.
- Waits: W-012.
- From: A Q3; E PL-22c, VM-4 §5.

---

## 2. Library and search

### LS-1 — What shape do note rows take, now that she wants previews? [GATES DESIGN]
Her word settles *that* rows preview (see Already ruled); the shape is open. It applies to the Library and to a book's contents list, where untitled entries read as the same raw date twice.
- (a) Cards as the only Library face: title, two preview lines, stamp. Cost: fewer rows per screen.
- (b) A list with one preview line under the title. Cost: one line may not tell journal entries apart.
- (c) A List / Cards toggle like the Mac's. Cost: two faces to build and keep.
- For a book's list, B adds: (i) the Library's one derivation (first words) with the day in the meta; (ii) day and time for journal entries, first words elsewhere; (iii) a two-line row with first words and a preview.
- Readers' recommendation: none given.
- Waits: W-040, W-079, W-032.
- From: A Q10; B Q12.

### LS-2 — Does phone search wait for wings, or search across wings? [later ticket]
Core search requires a wing by construction.
- (a) Ship search only after the wing face, scoped to the current wing. Cost: search waits for W-015.
- (b) Ship search first over Home only. Cost: misses eight of her nine wings until the wing face lands.
- (c) Rule an "all wings" phone search as a named exception to "wings isolate totally". Cost: a canon exception and a scope control.
- Readers' recommendation: none given.
- Waits: W-059.
- From: A Q4.

### LS-3 — Pool and Snippets: the names, and what the Snippets room does [GATES DESIGN]
The phone says Bookless and Scraps; the Mac says Pool and Snippets. Canon disagrees on reach: her gate words put "snippets" on the not-replicated list ("I can't think of how to easily do this on mobile without it being a mess"), but MobileSoul §4.5's ruled list names only "the scraps drag-into-note door", and §4.3 names "scraps viewing" as see-your-data; the ledger (PL-18c) owes a renamed, grouped room.
- Names: (a) adopt Pool, Snippets, groups; (b) keep Bookless and Scraps on the phone.
- Reach: (i) view and add only, block tags still Mac-side (today's "ruling 3"); (ii) the Mac's acts — edit, delete, move to group, tags; (iii) record Snippets as a phone exclusion.
- Readers' recommendation: none given (A notes ruling 3 predates the complete-app bar and is "worth re-asking").
- Waits: W-052, W-053, W-142.
- From: A Q7; E PL-18c, §3.

### LS-4 — Does the phone get Duplicate (with and without tags)? [later ticket]
E lists the VX-383 phone doors as "at her word".
- (a) Both doors, as on the Mac. Cost: the NoteDuplicate hoist.
- (b) Duplicate with Tags only. Cost: a smaller menu; a divergence to record.
- (c) Not on the phone for v1. Cost: a "do it on the Mac" gap (MobileSoul §4 item 4).
- Readers' recommendation: none given. (Options drafted by the consolidator from the Mac's two doors.)
- Waits: W-047.
- From: E PL-48 (VX-383); A·B13; C·N8.

---

## 3. Books

### BK-1 — What shape does the Bookcase take on the phone? [GATES DESIGN]
The 13i sitting ruled "the Bookcase/shelf strip as a list" but not the form.
- (a) A horizontally scrolling chip row of shelves (starred · Unshelved · each shelf · All) above the book list, solo by default. Cost: a strip that grows with shelves.
- (b) One sectioned list with shelves as collapsible headers (All only); solo by tapping a header. Cost: long scrolls with many shelves.
- (c) Two levels: Bookcase → a shelf's books. Cost: an extra tap to any book.
- Readers' recommendation: none given.
- Waits: W-067, W-069.
- From: B Q1.

### BK-2 — Which of the book's modes does the phone carry? [GATES DESIGN]
Today: the contents list (≈ Outline) and Read ▸ Scroll.
- (a) Keep both and add Index as an edit-in-place block list. Cost: a block-level book editor on a phone.
- (b) Add Read ▸ Pages (a paged reader) and stop there. Cost: no block editing across a book.
- (c) The contents list stays the only mode surface; the Mac-only modes go on the exclusion list. Cost: a recorded exclusion.
- Readers' recommendation: none given.
- Waits: W-075.
- From: B Q4; E PL-18b.

### BK-3 — Where do Arrivals live, and what is bulk judging on a phone? [GATES DESIGN]
- (a) A count chip in the book's toolbar that pushes a full-screen review, with swipe-to-Add / swipe-to-Dismiss rows and an Edit-mode multi-select for Add N / Dismiss N. Cost: a new screen and the multi-select grammar (VM-31).
- (b) An "Arrivals — N waiting" section at the top of the book's contents, judged in place. Cost: crowds the contents list.
- (c) A sheet over the contents with (a)'s grammar at a medium detent. Cost: a cramped review.
- Readers' recommendation: none given.
- Waits: W-101, W-103.
- From: B Q5.

### BK-4 — Does the phone's contents list wear the pin mark? [later ticket]
The Mac draws it on the tables of contents only, and the phone's contents list is its table of contents.
- (a) Yes, a muted pin on the row. (b) No mark; a small "pinned" group header instead. (c) No mark at all.
- Cost: small either way; (c) leaves the pinned group unexplained, as today.
- Readers' recommendation: none given.
- Waits: W-091.
- From: B Q6.

### BK-5 — What is the Book Panel on the phone, including next and previous within a book? [GATES DESIGN]
VM-6 names this as the sitting's item.
- (a) The masthead's Books sheet grows into it: the book's contents with the note marked, the switcher for shared notes, pins, Release. Cost: a heavy sheet.
- (b) A thin book strip on a note opened from a book ("note 3 of 12 · Chapter") with ‹ › to step and a tap for the contents. Cost: chrome above the prose.
- (c) Both. Cost: the most to build.
- Readers' recommendation: none given.
- Waits: W-089, W-088.
- From: B Q7.

### BK-6 — How much of the rule editor does the phone get? [GATES DESIGN]
Her complexity-test doctrine is MobileSoul §4.
- (a) The full boolean tree (the shared rule brain). Cost: the largest face; the hoist of RuleEditorModel.
- (b) A simplified face: any / all of tags, plus "starred", plus "not #tag"; nesting shown read-only and edited on the Mac. Cost: a partial editor.
- (c) Rules are see-only on the phone (the Collecting sentences). Cost: a "do it on the Mac" road the doctrine flags.
- Readers' recommendation: none given.
- Waits: W-074.
- From: B Q8.

### BK-7 — How much shelf management does the phone get? [later ticket]
- (a) Full: create, rename, glyph, delete, reorder shelves, move a book to a shelf. (b) See and file only: solo shelves and move a book; shelves are Mac-made. (c) See only.
- Cost: (a) the most doors; (c) a "do it on the Mac" road.
- Readers' recommendation: none given.
- Waits: W-069.
- From: B Q9.

### BK-8 — Does LK5's deferral of a book's word target and note limit still stand? [later ticket]
- (a) Keep them absent. (b) Show progress only. (c) Full editing in the settings pane.
- Readers' recommendation: none given.
- Waits: W-099.
- From: B Q10.

### BK-9 — Where does the daily Journal's "New Entry" live, beside the ✎ today badge that opens the day's first? [later ticket]
- (a) The Journal's contents foot ("+ New Entry"), the Mac's own placement. (b) Also on the Journal row as a second badge. (c) The quick-note box gains a "to Journal" filing.
- Readers' recommendation: none given.
- Waits: W-086.
- From: B Q11.

### BK-10 — Where does "put this note in a chapter" live? [later ticket]
Held since batch 10 (VM-4 §5 item 5); E marks it UNCLEAR.
- (a) "Move to Chapter ▸" in the note's menu inside a book (the Mac's place). Cost: needs W-078.
- (b) Also a chapter choice when making a new note in a book. Cost: a second door.
- Readers' recommendation: none given. (Options drafted by the consolidator from the Mac's door.)
- Waits: W-082.
- From: B·D5; E VM-4 §5.

---

## 4. The note

### NT-1 — What does Return do on the phone? [GATES DESIGN]
AppSpec says "the phone's Return model is its own"; today Return mid-note is a newline inside the block.
- (a) Adopt the Mac's model through the shared TypedReturn (new block, divide at word start, chains), with a bar or long-press door for the in-block newline. Cost: the editor seam; a newline door.
- (b) Keep Return as content; add a visible "new paragraph block" act on the bar plus "Make every newline a block" as the repair. Cost: structure drifts from what the Mac would make.
- (c) Adopt (a) but default the per-note switch OFF on the phone, with the switch in the masthead. Cost: two behaviours to explain.
- Readers' recommendation: none given.
- Waits: W-125, W-126.
- From: C Q1; E PL-21-1, PL-31.

### NT-2 — Backspace at a paragraph's start [later ticket]
The Mac's carves are ruled; the phone's absence is recorded "deliberately unbuilt".
- (a) Build both, exactly as the Mac: empty-block delete and texted-seam merge. (b) Build only the empty-block delete; keep the texted seam a deliberate merge.
- Readers' recommendation: none given.
- Waits: W-128.
- From: C Q2; E PL-24e.

### NT-3 — What does the phone's Copy copy? [later ticket]
Her R15 phone rule: "copy should follow what's on the screen". Her original ask: "copy everything i've written" (D).
- (a) Keep R15: the chosen or peeked text as Markdown, no title. Cost: a phone copy doesn't re-import whole on the Mac.
- (b) Match the Mac's Copy full text (the document format: title, tags, takes). Cost: pasting into another app carries Variorum's format.
- (c) Both: "Copy text" and "Copy with takes", the latter riding Export's share sheet. Cost: two doors.
- Readers' recommendation: none given.
- Waits: W-232 (and W-233 for (c)).
- From: C Q3; D Q9 (a)/(b).

### NT-4 — The note seal's word [later ticket]
The phone says "Lock Note"; the Mac and books say Seal; "lock" also names take locks and, soon, Lock Library Now.
- (a) Unify on Seal / Unseal. (b) Keep the phone's Lock.
- Readers' recommendation: none given. Consolidator's note: W-189 adds a third "lock" to the phone.
- Waits: W-155.
- From: C Q4.

### NT-5 — Where do commit and history live? [GATES DESIGN]
Her batch-9 move put history on each take card; Commit sits in the block ⋯.
- (a) The History & Lineage surface opened from the block ⋯, with Commit beside it. Cost: moves a door she placed.
- (b) Keep history on the take card only. Cost: a single-take block's history stays two levels deep.
- (c) Both doors.
- Readers' recommendation: none given.
- Waits: W-183, W-184, W-180.
- From: C Q5.

### NT-6 — Does a single note get a Read mode, and which note modes ship in v1? [GATES DESIGN]
Read is not on the exclusion list; the ledger owes "which modes are v1" (PL-18b).
- (a) A masthead `edit · read` switch to a calm page (the book Read's page, one note). Cost: a mode row and per-note memory follow.
- (b) None: Write is the phone's reading surface; Read stays book-only, recorded as a ruled compromise.
- Readers' recommendation: none given.
- Waits: W-159, W-160.
- From: C Q6; E PL-18b, PL-19a.

### NT-7 — Divide presets when the block is fanned [later ticket]
- (a) A small sheet of three plain rows (keep on top · keep on bottom · copy to both). (b) Keep the one default — the complexity test may show the presets unnecessary.
- Readers' recommendation: none given.
- Waits: W-137.
- From: C Q7; E PL-21-3.

### NT-8 — Merging beyond "Merge with Previous" [later ticket]
Her words: "i also only see merge with previous rather than a multi merge option? … let's think about that three dots menu a little more."
- (a) "Merge with Next" beside Previous. (b) Select blocks, then merge (the block list's multi-select). (c) Both.
- Readers' recommendation: none given (batch 9 proposed both (a) and (b)).
- Waits: W-138, W-144.
- From: E VM-4 §5 item 5; C·B5.

### NT-9 — Smart quotes, dashes and spelling on the phone (VX-438) [later ticket]
The same note gets different characters depending on which device typed them.
- (a) Mirror the Mac: quotes and dashes off, spellcheck off by default, a setting. (b) Keep iOS defaults. (c) One synced setting both platforms read.
- Readers' recommendation: none given.
- Waits: W-131.
- From: C Q8; VX-438.

### NT-10 — The comment marker and the callout glyph: follow the Mac's gutter rule? [later ticket]
- (a) Keep ●n at the last line's end. (b) Move both to the left gutter like the Mac (the measure never moves). (c) A count on the block's trailing edge beside ⑂.
- Readers' recommendation: none given.
- Waits: W-170.
- From: C Q9; E PL-10 (i)(ii), round-2 §6.2.

### NT-11 — Closing the comments sheet with words in it (VM-18) [later ticket]
- (a) Any close parks the draft (the Mac's rule: "clicking away should save your half typed comment on a draft"). (b) Done parks; dim-tap and swipe discard. (c) Ask before discarding.
- Readers' recommendation: none given.
- Waits: W-165.
- From: C Q10; E VM-18.

### NT-12 — Does "Undo New Block" show in the phone's undo door? [later ticket]
The stack already holds it; the receipt doesn't offer it.
- (a) Yes: offer Undo on the receipt and in the note ⋯. (b) No: keep mints out of the phone's undo door.
- Readers' recommendation: none given.
- Waits: W-140.
- From: E PL-23-4; C·B9.

### NT-13 — The lens-aware "show" filter on takes (VX-168) [later ticket]
- (a) Add it to the takes browser. (b) Leave it out and record a compromise.
- Readers' recommendation: none given (E: "takes umbrella, her call").
- Waits: W-178.
- From: E PL-53 (VX-168); C·T10.

### NT-14 — Find and replace: v1 or later? [later ticket]
- (a) v1, takes-aware, with the FindReplaceGate hoist. (b) Later; v1 keeps find only, checked against U7's rules.
- Readers' recommendation: none given.
- Waits: W-132.
- From: E PL-1d.

### NT-15 — Should block tags exist (VX-128)? [later ticket]
Open on the Mac too.
- (a) Yes, on both platforms. (b) No; retire the idea. (c) Mac only.
- Readers' recommendation: none given.
- Waits: W-143.
- From: C·B15; VX-128.

### NT-16 — Ratify VM-10's three PROVISIONALs (#200)? [later ticket]
The note's arrival scroll and place memory shipped on them.
- (a) Ratify as built. (b) Review on her phone first.
- Readers' recommendation: none given.
- Waits: nothing new (shipped behaviour).
- From: E VM-5 handoff, #200; C·E18.

### NT-17 — A Release-side identity-boundary belt? [later ticket]
Her risk call (E: low).
- (a) Add a Release-side belt. (b) Keep the Debug oracle only.
- Readers' recommendation: none given.
- Waits: W-163.
- From: E round-2 §6.7.

---

## 5. The lock and protection

Her words fix the shape: backgrounding keeps the library open "for a few minutes", a full close locks, and Lock Now exists (see Already ruled). What follows is what's left. CastleRules is silent on re-locking; decision 18 ("Lock after time away — 10 minutes default, offered 5 · 10 · 30 · never … re-lock on sleep / screen lock always on; Lock Library Now") is hers.

### LP-1 — How many minutes, and does the phone read the existing dial? [later ticket]
- (a) The existing per-device dial at its default of 10 minutes (5 · 10 · 30 · never); no new setting. Cost: none beyond the face.
- (b) The same dial with a phone default she names. Cost: a phone-specific default.
- (c) Add "Immediately" or a 1-minute step (today's behaviour as an opt-in). Cost: changes decision 18's offered set; the Mac renders it too or the phone carries a phone-only choice.
- Readers' recommendation: none given (D lays out three shapes, A/B/C, all keeping every Castle rule).
- Waits: W-187, W-188.
- From: D §2.6, §2.7 item 1.

### LP-2 — What happens when the phone itself locks? [later ticket]
- (a) Variorum locks too, as the Mac does on screen lock (decision 18's "always on"), using the signal where it works and the minutes otherwise.
- (b) Ignore device lock and rely on the minutes, since a locked phone is already a boundary. Cost: changes decision 18 for the phone; needs her explicit word.
- Either way the signal needs a device probe before copy promises it.
- Readers' recommendation: none given. D rules out the undocumented Darwin notification (App Review risk).
- Waits: W-187, W-190.
- From: D §2.5, §2.7 item 2.

### LP-3 — What does the app switcher show while the library is open in the background? [later ticket]
- (a) As today: the page, with the words and secret fields covered. Cost: the last page is visible in the switcher, even under Castle today.
- (b) Under Castle, the whole app covered whenever it isn't active. Cost: also hides the page during Control Center and notification pull-downs.
- (c) A cover only once the window has lapsed. Cost: not reliably possible — the snapshot is taken at leaving (INFERRED).
- Readers' recommendation: none given.
- Waits: W-192.
- From: D §2.7 item 3.

### LP-4 — After a relock that does happen, where does she land? [later ticket]
- (a) The Shelf, as today. (b) Back on the note and tab she left, remembered in memory only (nothing written while locked).
- Readers' recommendation: none given; D calls (b) "not a Castle rule; it is UX, and probably half of her pain" (INFERRED).
- Waits: W-191.
- From: D §2.7 item 4.

### LP-5 — Where does Lock Now live? [GATES DESIGN]
- (a) The "On this iPhone" section only (the Mac pane's twin). (b) Also the top of the Settings sheet. (c) Also a Home Screen quick action (INFERRED feasible).
- Readers' recommendation: none given; D: "a design call, not a rule".
- Waits: W-189.
- From: D §2.7 item 5.

### LP-6 — Should the dial's default differ on an "Always ask" phone? [later ticket]
Under Always ask a lapsed window costs typing the passphrase, not a glance.
- (a) One default for both gate styles. (b) A longer default under Always ask.
- Readers' recommendation: none given. (Options drafted by the consolidator from D's question.)
- Waits: W-188.
- From: D §2.7 item 6.

### LP-7 — The phone wording for leaving Castle (F-PH-2) and for rule 21's "this Mac" sentences (F-PH-1) [later ticket]
A phone-only Castle user can't leave Castle today, and the phone dead-ends if the account leaves Castle elsewhere.
- (a) Word them, so Use Standard, the follow out and the leaving join render on the phone.
- (b) Keep leaving Castle a Mac-only road and say so on the phone. Cost: conflicts with MobileSoul §4's no-redirect rule unless she rules it an exclusion.
- Readers' recommendation: none given.
- Waits: W-198, W-199.
- From: D Q4; E VM-28.

### LP-8 — The Private mark (and Copy for AI) on the phone [later ticket]
- (a) Show the eye only (see-your-data). (b) The eye plus a set/clear door — her hand, so MCPSpec's "no MCP road writes" fence isn't touched. (c) Nothing, because the phone has no AI door.
- Copy for AI rides the same answer.
- Readers' recommendation: none given.
- Waits: W-058, W-156.
- From: D Q7; E PL-52, PL-69; C·N11.

### LP-9 — A Copy door for the twelve words? [later ticket]
- (a) None (today). (b) A copy kept local to the device and expiring — the iOS twin of the Mac's concealed copy cleared at lock.
- Readers' recommendation: none given.
- Waits: W-197.
- From: D Q8.

### LP-10 — The VM-8 wording bundle: now, or still "stand as built"? [later ticket]
Her ruling was "Stand as built until my wording pass." The bundle: follow-locked doors hidden rather than refusing (P-VM8-9), "your backups" on a backup-less phone (F-U2-H), the doorless "You're in Castle." line, the twice-told follow notice.
- (a) Do the wording pass inside this effort, alongside VM-28. (b) Keep standing as built until later.
- Readers' recommendation: none given.
- Waits: W-208.
- From: E VM-8 bundle, #242; D·D-15, D-19.

---

## 6. First run and joining from a Mac

### FR-1 — What does a fresh phone show first? [GATES DESIGN]
Today a fresh phone shows the twelve words before anything else, and never asks for a passphrase (rule 3). Separately, SurfaceContracts calls the tour "Mac-only" while MobileSoul's exclusion list doesn't name it.
- (a) The phone's own band card above the quick entry, holding the words (with Copy), rule 3's reminder and E6, as VM-23 and VM-28 scope it. Cost: the smallest.
- (b) (a) plus a short phone welcome card offering a phone tour or guide that closes with the passphrase and words cards. Cost: a phone tour (the Mac's tour is Mac-local).
- (c) (a) only, with the pocket guide seeded at the first write as the phone's teacher. Cost: needs the guide in Release (FR-5).
- Readers' recommendation: none given.
- Waits: W-194, W-195, W-222.
- From: D Q2, §6.

### FR-2 — The road for a Mac user adding the phone [GATES DESIGN]
About twelve taps across four surfaces; the first thing shown is twelve words she doesn't need; the join door is at the bottom of a long scroll.
- (a) A first-open fork ("New to Variorum" / "I already use Variorum"); the second goes straight to Sign in and "Sync this library…", never minting throwaway words. Cost: a new first screen.
- (b) Keep the Settings road, but lead the empty state and the Protection screen with the join. Cost: the road stays long.
- (c) (b) plus a door on the Mac pointing to the phone app (there's none today).
- Readers' recommendation: none given.
- Waits: W-201, W-227 (and W-228).
- From: D Q3.

### FR-3 — What's New on the phone? [later ticket]
- (a) None; the App Store's notes stand in. (b) An in-app card from the shared notes. (c) A "What's new" row in Settings.
- Readers' recommendation: none given.
- Waits: W-226.
- From: D Q5; E PL-47 (13r) b; VM-4 §5.

### FR-4 — Ratify #146: the signed-out phone's sample book retires at sign-in? [later ticket]
Built PROVISIONAL at 18o; E found no ratify status.
- (a) Ratify as built. (b) Revisit with the phone's seed set.
- Readers' recommendation: none given.
- Waits: W-223.
- From: E §1e #146.

### FR-5 — Does a Release phone carry the pocket guide, and where is its door? [later ticket]
PB1-1 left this to her: "whether/where a Release phone carries a tutorial door (and whether the pocket guide should reach her real corpus at all)".
- (a) A Help row in Settings that seeds or opens the guide. (b) The guide seeded at the first write, as a book, with no separate door. (c) No guide in Release.
- Readers' recommendation: none given. (Options drafted by the consolidator from PB1-1's wording.)
- Waits: W-219 (and through it W-220, W-221).
- From: A·H10; D·D-49.

---

## 7. Look and sizing

Her direction is set (see Already ruled): the Mac's look, Study voice, the sea-glass palette, at phone-right sizes and spacing. What's left:

### LK-1 — Does the phone keep its own voice switch (LK2), defaulting to Study, or follow the synced voice? [later ticket]
- (a) Keep the phone-local switch, default Study. (b) Follow the synced `theme_voice`, with the phone's switch writing it. Cost: reverses LK2.
- Readers' recommendation: none given.
- Waits: W-006.
- From: A Q6; G Q4.

### LK-2 — Does the phone follow the synced palette or keep its own? [later ticket]
- (a) Follow the synced palette (the Mac's four-parameter road). (b) A phone-local palette like the voice.
- Readers' recommendation: none given.
- Waits: W-005.
- From: G Q5; E PL-22b.

### LK-3 — Does her R22/R25 ruling (eleven formatting acts on one row at 28 pt) stand? [GATES DESIGN]
- (a) Keep it. (b) Two rows, accepting a taller bar. (c) Fewer acts on the strip, the rest in a menu.
- Readers' recommendation: none given.
- Waits: W-135.
- From: G Q1.

### LK-4 — Is the "pale band" the Write keyboard bar, and what replaces it? [GATES DESIGN]
The quick-entry box has no button group; the keyboard bar draws an opaque band behind three glass buttons (see Contradictions settled).
- Confirm the surface, then: (a) drop the band and let iOS 26's glass buttons float; (b) keep a band but draw no per-button circles (one capsule, a look change she reserved).
- Readers' recommendation: none given.
- Waits: W-134, W-135.
- From: G Q2, §3.4; A§4.

### LK-5 — Does the text-only tab bar (LK7) stand? [GATES DESIGN]
- (a) Text only, but larger, with real hit areas. (b) Icons plus words (the v2 mockup's rejected B/C). (c) The system tab bar.
- Readers' recommendation: none given.
- Waits: W-007.
- From: G Q3.

### LK-6 — Terminal's lowercased chrome (W-14) [later ticket]
- (a) Keep lowercasing in Terminal. (b) Sentence case in both voices.
- Readers' recommendation: E: "likely mooted by her Study direction".
- Waits: W-006.
- From: E PL-42 (VX-306) b, #234.

---

## 8. Performance and the device session

### PD-1 — Which store does the on-phone trace use? [later ticket]
- (a) Her real store through a Release profiling build. Cost: same bundle id, so it replaces her installed app; confirm the phone is synced first and note the installed version to restore.
- (b) A Debug run on the dev store with the 100k fixture. Cost: unoptimized numbers with Debug checks — ratios only, never absolutes.
- (c) Both.
- Readers' recommendation: none given (F asks before step 0). The walks' seeded-library choice (her third message) doesn't settle this one.
- Waits: W-238.
- From: F§11 step 0.

### PD-2 — One plugged-in window for the trace, the device queue and the lock probe? [later ticket]
- (a) One window: the nine trace flows, VM-13's remaining walks and the device-lock probe. Cost: a long session.
- (b) Separate windows. Cost: more of her time at the desk.
- Readers' recommendation: E: ride VM-13's queue in "her plugged-in lag window".
- Waits: W-238, W-260, W-190.
- From: E VM-13b; D§2.5; F§11.

### PD-3 — May a current build go on her phone now? [later ticket]
Main is at sync marker 15; her phone build is probably marker 14 and so probably not syncing (INFERRED — confirm on the phone first). VM-32 waits on the same install.
- (a) Now, before the trace — an install, not new code. (b) At the trace window. (c) With the first wave's release.
- Readers' recommendation: E: "confirm on her phone before anything else"; keep VM-32 high with the marker install folded in.
- Waits: W-209 (and through it W-238, W-260, W-210).
- From: E §0 item 1, VM-32.

---

## 9. Scope and exclusions

### SC-1 — Compare after v1: which first? [later ticket]
She reopened Compare for after v1 (see Already ruled).
- (a) Her idea: notes as tabs you swipe between, lined up block by block (maps onto the Mac's PostAlignment rows). Cost: the four Compare hoists.
- (b) The smaller take diff first. Cost: a narrower compare.
- Readers' recommendation: none given.
- Waits: W-186, W-177.
- From: C Q11, §1i.

### SC-2 — Capture from outside the app? [later ticket]
- (a) None; the home box is the door. (b) A widget or Shortcuts action that files into Home's quicknotes, like the pad. (c) The share sheet as an import door.
- Readers' recommendation: none given.
- Waits: W-029.
- From: A Q9.

### SC-3 — A ⌘K equivalent? [later ticket]
- (a) None; search is the one finder. (b) Search also lists commands. (c) A per-screen "…" sheet carries what the palette reaches.
- Readers' recommendation: none given.
- Waits: W-066.
- From: A Q8.

### SC-4 — The library doors on the phone: Look inside, Open Library, Restore, Previous Libraries, Send or open a copy [later ticket]
Deferred to this catch-up by a PROVISIONAL (P-VX306-U3-18), and held as "her call" in the ledger (PL-48 (13x)).
- (a) Build them in v1. (b) Later. (c) Rule them a phone exclusion.
- Readers' recommendation: none given.
- Waits: W-207, W-206.
- From: D·D-30; E PL-42 (VX-306) a, PL-48 (13x).

### SC-5 — Import through the Files picker in v1? [later ticket]
- (a) v1. (b) Later.
- Readers' recommendation: none given.
- Waits: W-237.
- From: D Q9 (c).

### SC-6 — Crash reports [later ticket]
- (a) A MetricKit opt-in, default off, like the Mac's mail-draft road. (b) Rely on TestFlight and App Store Connect's own crash logs. (c) Both.
- Readers' recommendation: none given.
- Waits: W-216.
- From: D Q6; E PL-47 (13r) a.

### SC-7 — Settings search [later ticket]
- (a) v1. (b) Later.
- Readers' recommendation: E: "likely not v1".
- Waits: W-215.
- From: E PL-36; A·H7.

### SC-8 — Housekeeping at her word [later ticket]
- Canon pointers: MobileSoul §7 and CLAUDE.md still name the retired `~/dev/variorum-mobile` worktree; the parity ledger has duplicate numbers and rows filed under §7 (a doc fix "at her word", E §5).
- The round-2 4.5b cold review: E proposes "close as covered unless she objects".
- The VM-5 ratify bundle: #159's addendum, the unruled #192 / #194 / #195, and two PROVISIONAL lines ("No bookless notes — every note is in a book." · "unlock it to keep writing").
- Options for each: (a) yes, now; (b) at a later wording or doc pass.
- Waits: W-262, W-053.
- From: E §5, §1d.

### SC-9 — Record the AI surfaces as phone exclusions? [later ticket]
The phone runs no MCP server, so the book's Shared-with row, the AI section and the shared icon can never draw there; this is recorded in the ledger and in a design record, not in MobileSoul §4.5.
- (a) Add them to §4.5's ruled exclusions. (b) Leave them as by-construction notes.
- Readers' recommendation: B: "Confirm at design."
- Waits: nothing to build.
- From: B·I10; D·D-58, D-61.

---

## Gate count

21 of the 70 questions gate design: SW-1, SW-2, SW-3, SW-4, SW-6, LS-1, LS-3, BK-1, BK-2, BK-3, BK-5, BK-6, NT-1, NT-5, NT-6, LP-5, FR-1, FR-2, LK-3, LK-4, LK-5.

---

## Already ruled (dropped from the list above, with her words)

- **Wings: both a swipe and a dropdown.** *"I have 9, so UI options should work well with many. a quick swipe between them and also a dropdown option would be nice."* Answers B Q3 (c) ("dropdown only; no swipe") — ruled out. How the swipe coexists (SW-1) stays open.
- **Staying unlocked.** *"app staying unlocked for a few minutes damn."* · *"fully closing the app rather than just backgrounding it should make the library lock automatically though."* · *"and a lock now button should be there like the mac."* Answers whether backgrounding locks at once (no), whether a full close locks (yes), and whether Lock Now exists (yes). D shows the rule she's reversing was a planner's item, not hers.
- **Previews.** *"showing preview more lot apple notes so i know what each note is."* Answers whether rows carry a preview; the shape is LS-1.
- **The look.** *"the overall look of the app is fine aside from how everything is weirdly small and spaced, but honestly, just use the mac app as your visual direction. the study mode especially. the sea greeen theme"* Answers G Q4 (a) "keep Terminal" and G Q5 (c) "stay Classic" — both ruled out as directions; the design pass resizes and respaces rather than restyles. LK-1 and LK-2 keep only the mechanics.
- **The pale band.** *"I don't like that there's a whole pale band around the quick click buttons rather than just hte buttons themsleves"* Answers G Q2 (c) ("keep both as built") — ruled out. LK-4 keeps only which surface and which replacement.
- **Compare after v1.** *"I would like to have a compare mode, maybe with the notes as different tabs that you can swipe between and still have the notes line up block by block? … probably won't even be in v1 of the mobile app"* Reverses MobileSoul §4.5's Compare exclusion, after v1 (to record at approval). SC-1 keeps only which compare comes first.
- **No code during planning.** *"we shouldn't start writing code (unless you can't run the app because something is broken, in which case you can fix that to unblock everythinge else)"* Governs when the must-not-wait items in `dependency-notes.md` can start.
- **The device session can happen.** *"yes on the audit fan out, I will plug my phone in later."* Answers whether a plugged-in window exists; PD-1 and PD-2 keep its shape.
- **The walks' library.** *"you can maybe sync with the dev store if you'd like … you can seed a new library instead but that is an option."* The orchestrator chose a seeded library for the Debug phone walks. PD-1 is the separate question of which store the performance trace uses.
